Shader "Custom/GuideMask_Broader"
{
    Properties
    {
         _MainTex ("Sprite Texture", 2D) = "white" { }
        
         _Color ("Tint", Color) = (1.000000,1.000000,1.000000,1.000000)
        
         _StencilRef ("_StencilRef", Float) = 0.000000
         _StencilComp ("_StencilComp", Float) = 8.000000
         _StencilPassOp ("_StencilPassOp", Float) = 0.000000
         _StencilFailOp ("_StencilFailOp", Float) = 0.000000
    
        
    }
    SubShader
    {
        Tags { "QUEUE"="Transparent" "IGNOREPROJECTOR"="true" "RenderType"="Transparent" "CanUseSpriteAtlas"="true" "PreviewType"="Plane" }
 
        Blend SrcAlpha OneMinusSrcAlpha
        ZTest [unity_GUIZTestMode]
        ZWrite Off
        Cull Off
        
        Stencil {
           Ref [_StencilRef]
           ReadMask 255
           WriteMask 255
           Comp [_StencilComp]
           Pass [_StencilPassOp]
           Fail [_StencilFailOp]
        }
 
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
 
            #include "UnityCG.cginc"
 
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR; 
            };
 
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
            };
 
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
 
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                o.color = v.color;
                return o;
            }
 
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                
                col *= _Color;
                col.a *= i.color.a;
                
                return col;
            }
            ENDCG
        }
    }
}