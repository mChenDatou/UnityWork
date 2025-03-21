using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class OutlinePassFeature : ScriptableRendererFeature
{
    class OutlineRenderPass : ScriptableRenderPass
    {
        public static readonly List<ShaderTagId> _shaderTagIds = new List<ShaderTagId>() 
        {
            new ShaderTagId("SRPDefaultUnlit"),        
            new ShaderTagId("UniversalForward"),        
            new ShaderTagId("UniversalForwardOnly")        
        };
        private readonly Material _outlineMat;
        private readonly FilteringSettings _filteringSettings;
        private readonly MaterialPropertyBlock _propertyBlock;
        private readonly int _shaderProp_Outline_Tex_ID = Shader.PropertyToID("_OutlineTex");
        private RTHandle _rt;
        public OutlineRenderPass(Material mat)
        {
            this._outlineMat = mat;
            this.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
            this._filteringSettings = new FilteringSettings(RenderQueueRange.opaque, layerMask : 1, renderingLayerMask: 2);
            this._propertyBlock = new MaterialPropertyBlock();
        }

        public void Dispose()
        {
            this._rt.Release();
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            ResetTarget();
            RenderTextureDescriptor desc = renderingData.cameraData.cameraTargetDescriptor;
            desc.msaaSamples = 1;
            desc.depthBufferBits = 0;
            desc.colorFormat = RenderTextureFormat.ARGB32;
            RenderingUtils.ReAllocateIfNeeded(ref _rt, desc, name : "OutLine");
        }

        // Here you can implement the rendering logic.
        // Use <c>ScriptableRenderContext</c> to issue drawing commands or execute command buffers
        // https://docs.unity3d.com/ScriptReference/Rendering.ScriptableRenderContext.html
        // You don't have to call ScriptableRenderContext.submit, the render pipeline will call it at specific points in the pipeline.
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmb = CommandBufferPool.Get(name:"Outline command");
            cmb.SetRenderTarget(this._rt);
            cmb.ClearRenderTarget(true, true, Color.clear);

            DrawingSettings drawingSettings = CreateDrawingSettings(_shaderTagIds, ref renderingData, SortingCriteria.None);
            RendererListParams listParams = new RendererListParams(renderingData.cullResults, drawingSettings, this._filteringSettings);
            RendererList list = context.CreateRendererList(ref listParams);
            cmb.DrawRendererList(list);
            
            cmb.SetRenderTarget(renderingData.cameraData.renderer.cameraColorTargetHandle);
            this._propertyBlock.SetTexture(_shaderProp_Outline_Tex_ID, this._rt);
            cmb.DrawProcedural(Matrix4x4.identity, this._outlineMat, 0, MeshTopology.Triangles, 3, 1, this._propertyBlock);

            context.ExecuteCommandBuffer(cmb);
            cmb.Clear();
            CommandBufferPool.Release(cmb);
        }

        // Cleanup any allocated resources that were created during the execution of this render pass.
        public override void OnCameraCleanup(CommandBuffer cmd)
        {

        }
    }
    
    [SerializeField]
    private Material _mat;
    private OutlineRenderPass _outlineRenderPass;

    private bool _isMatVailid => _mat && _mat.shader && _mat.shader.isSupported;

    public override void Create()
    {
        if (!this._isMatVailid) 
        {
            return; 
        };

        this._outlineRenderPass = new OutlineRenderPass(this._mat);

    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (this._outlineRenderPass == null)
        {
            return;
        };
        renderer.EnqueuePass(this._outlineRenderPass);
    }

    protected override void Dispose(bool disposing)
    {
        base.Dispose(disposing);
        this._outlineRenderPass?.Dispose();
    }
}


