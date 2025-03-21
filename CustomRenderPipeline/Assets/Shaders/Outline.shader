Shader "Outline"
{
    Properties
    {
        [HDR]_OutlineColor("Outline Color", Color) = (1, 1, 1, 1)
        _OutlineWidth("Outline Width", Range(0, 0.005)) = 0.002
    }
    SubShader
    {
        Tags { 
            "RenderType"="Opaque" 
            "RenderPipeline" = "UniversalPipeline"
        }

        Cull Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include  "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include  "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                uint vertexID : SV_VertexID;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                half2 offsets[8] : TEXCOORD1;
            };

            TEXTURE2D_X(_OutlineTex);
            SAMPLER(sampler_linear_clamp_OutlineTex);
            half4 _OutlineColor;
            half _OutlineWidth;

            Varyings vert (Attributes IN)
            {
                Varyings o;
                o.positionCS = GetFullScreenTriangleVertexPosition(IN.vertexID);
                o.uv = GetFullScreenTriangleTexCoord(IN.vertexID);
                half rate = _ScreenParams.x / _ScreenParams.y;
                o.offsets[0] = half2(-1, rate) * _OutlineWidth;
                o.offsets[1] = half2(0, rate) * _OutlineWidth;
                o.offsets[2] = half2(1, rate) * _OutlineWidth;
                
                o.offsets[3] = half2(-1, 0) * _OutlineWidth;
                // o.offsets[4] = half2(0, 0) * _OutlineWidth;
                o.offsets[4] = half2(1, 0) * _OutlineWidth;
                
                o.offsets[5] = half2(-1, -rate) * _OutlineWidth;
                o.offsets[6] = half2(0, -rate) * _OutlineWidth;
                o.offsets[7] = half2(-1, -rate) * _OutlineWidth;
                return o;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                // sample the texture
                const half rowX[8] = {
                    -1, 0, 1,
                    -2,  2,
                    -1, 0, 1
                };
                const half colY[8] = {
                    -1, -2, -1,
                     0,    0,
                     1,  2,  1
                };
                half gx = 0;
                half gy = 0;
                half mask = 0;
                for (int i = 0; i < 8; ++i)
                {
                    mask = SAMPLE_TEXTURE2D_X(_OutlineTex, sampler_linear_clamp_OutlineTex, IN.uv + IN.offsets[i]).a;
                    gx += mask * rowX[i];
                    gy += mask * colY[i];
                };
                const half alpha = SAMPLE_TEXTURE2D_X(_OutlineTex, sampler_linear_clamp_OutlineTex, IN.uv).a;
                half4 col = _OutlineColor;
                col.a = saturate(abs(gx) + abs(gy)) * (1 - alpha);
                return col;
            }
            ENDHLSL
        }
    }
}
