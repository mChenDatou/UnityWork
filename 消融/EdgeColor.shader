Shader "CDT/Dissolve/EdgeColor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex("Noise", 2D) = "white" {}
        [HDR]_EdgeColor("EdgeColor", Color) = (1, 1, 1, 1)
        _FillAmount("FillAmount", Range(0.0, 1.0)) = 0.5
        _lineWidth("LineWidth", Range(0.1, 0.2)) = 0.1

    }
    SubShader
    {
        Tags { "Queue"="Geometry" "RenderType"="Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            
            Cull Off //要渲染背面保证效果正确

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uvMainTex : TEXCOORD0;
                float2 uvNoiseTex : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float4 _EdgeColor;
            float _FillAmount;
            float _lineWidth;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uvMainTex = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvNoiseTex = TRANSFORM_TEX(v.uv, _NoiseTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uvMainTex);
                //镂空
                fixed noiseR = tex2D(_NoiseTex, i.uvNoiseTex).r;
                clip(noiseR - _FillAmount);
                //边缘颜色过渡
                float t = 1.0 - smoothstep(0.0, _lineWidth, noiseR - _FillAmount);
                col.rgb = lerp(col.rgb, _EdgeColor.rgb, t * step(0.0001, _FillAmount));
                return col;
            }
            ENDCG
        }
    }
}
