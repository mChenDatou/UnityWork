Shader "CDT/GaussianBlur"
{
    Properties{
    	[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _PixelateFade("Pixelate: Fade", Range( 0 , 1)) = 1
        _PixelatePixelsPerUnit("Pixelate: Pixels Per Unit", Float) = 100
        _PixelatePixelDensity("Pixelate: Pixel Density", Float) = 16
    }
 
    SubShader
    {
		LOD 0

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float2 texcoord  : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            uniform float _PixelatePixelDensity;
            uniform float _PixelatePixelsPerUnit;
            uniform float _PixelateFade;
 
 
            v2f vert( appdata_t IN  )
            {
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
            	float2 _ZeroVector = float2(0,0);
				
				IN.vertex.xyz += float3( _ZeroVector ,  0.0 ); 
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color;
                return OUT;
            }

			fixed4 frag(v2f IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );
				float2 texCoord363 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
                float2 appendResult35_g11732 = (float2(_MainTex_TexelSize.z , _MainTex_TexelSize.w));
                float2 MultFactor30_g11732 = ( ( _PixelatePixelDensity * ( appendResult35_g11732 / _PixelatePixelsPerUnit ) ) * ( 1.0 / max( _PixelateFade , 1E-05 ) ) );
                float2 clampResult46_g11732 = clamp( ( floor( ( MultFactor30_g11732 * ( texCoord363 + ( float2( 0.5,0.5 ) / MultFactor30_g11732 ) ) ) ) / MultFactor30_g11732 ) , float2( 0,0 ) , float2( 1,1 ) );
				float4 staticSwitch8_g11744 = tex2D( _MainTex, clampResult46_g11732 );
				half4 color = staticSwitch8_g11744;
                color.rgb *= color.a;

                return color;
            }
            ENDCG
        }
    }
}
