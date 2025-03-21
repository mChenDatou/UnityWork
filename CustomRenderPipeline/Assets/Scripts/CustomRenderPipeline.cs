using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class CustomRenderPipeline : RenderPipeline
{
    public CameraRenderer cameraRender = new CameraRenderer();

    public CustomRenderPipeline()
    {

    }

    protected override void Render(ScriptableRenderContext context, Camera[] cameras)
    {
        foreach (var camera in cameras)
        {
            cameraRender.Render(context, camera);
        };
    }
}
