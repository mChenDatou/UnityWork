using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class CameraRenderer
{
    private ScriptableRenderContext context;
    private Camera camera;
    private CullingResults cullingResults;
    static ShaderTagId unlitShaderTagId = new ShaderTagId("SRPDefaultUnlit");

    const string bufferName = "Render Camera";

    CommandBuffer buffer = new CommandBuffer
    {
        name = bufferName
    };
    public void Render(ScriptableRenderContext context, Camera camera)
    {
        this.context = context;
        this.camera = camera;

        if (!Cull())
        {
            return;
        }

        this.Setup();
        this.DrawVisibleGeometry();
        this.Submit();
    }

    private void DrawVisibleGeometry()
    {
        SortingSettings sortingSettings = new SortingSettings(camera) 
        {
            criteria = SortingCriteria.CommonOpaque
        };
        DrawingSettings drawingSettings = new DrawingSettings(unlitShaderTagId, sortingSettings);
        FilteringSettings filteringSetting = new FilteringSettings(RenderQueueRange.opaque);
        this.context.DrawRenderers( cullingResults, ref drawingSettings, ref filteringSetting);
        this.context.DrawSkybox(this.camera);

        //sortingSettings.criteria = SortingCriteria.CommonTransparent;
        //drawingSettings.sortingSettings = sortingSettings;
        //filteringSetting.renderQueueRange = RenderQueueRange.transparent;
        //this.context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSetting);

    }

    private void Submit()
    {
        this.buffer.EndSample(bufferName);
        this.context.Submit();
    }

    private void Setup()
    {
        this.context.SetupCameraProperties(this.camera);
        this.buffer.BeginSample(bufferName);
        this.buffer.ClearRenderTarget(true, true, Color.clear);
        this.ExecuteBuffer();
    }

    private void ExecuteBuffer()
    {
        this.context.ExecuteCommandBuffer(this.buffer);
        this.buffer.Clear();
    }

    bool Cull()
    {
        if (camera.TryGetCullingParameters(out ScriptableCullingParameters p))
        {
            cullingResults = context.Cull(ref p);
            return true;
        };
        return false;
    }
}
