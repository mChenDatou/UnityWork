Shader "CDT/DirectionalGlowFade"
{
    Properties{
    	[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
    	_UberNoiseTexture("Uber Noise Texture", 2D) = "white" {}
    	_PixelsPerUnit("Pixels Per Unit", Float) = 100
		_DirectionalGlowFadeFade("Directional Glow Fade: Fade", Float) = 0
		_DirectionalGlowFadeRotation("Directional Glow Fade: Rotation", Range( 0 , 360)) = 0
		[HDR]_DirectionalGlowFadeEdgeColor("Directional Glow Fade: Edge Color", Color) = (11.98431,0.6901961,0.6901961,0)
		_DirectionalGlowFadeWidth("Directional Glow Fade: Width", Float) = 0.1
		_DirectionalGlowFadeNoiseScale("Directional Glow Fade: Noise Scale", Vector) = (0.4,0.4,0,0)
		_DirectionalGlowFadeNoiseFactor("Directional Glow Fade: Noise Factor", Float) = 0.2
		[Toggle]_DirectionalGlowFadeInvert("Directional Glow Fade: Invert", Float) = 0
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
            uniform sampler2D _UberNoiseTexture;
            uniform float _PixelsPerUnit;
            uniform float4 _DirectionalGlowFadeEdgeColor;
			uniform float _DirectionalGlowFadeInvert;
			uniform float _DirectionalGlowFadeRotation;
			uniform float _DirectionalGlowFadeFade;
			uniform float2 _DirectionalGlowFadeNoiseScale;
			uniform float _DirectionalGlowFadeNoiseFactor;
			uniform float _DirectionalGlowFadeWidth;

            
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
            
            float MyCustomExpression16_g12139( float linValue )
			{
				#ifdef UNITY_COLORSPACE_GAMMA
				return linValue;
				#else
				linValue = max(linValue, half3(0.h, 0.h, 0.h));
				return max(1.055h * pow(linValue, 0.416666667h) - 0.055h, 0.h);
				#endif
			}
            
            
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
				float2 texCoord435 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 staticSwitch8_g11874 = tex2D( _MainTex, texCoord435 );
				float2 staticSwitch1_g11662 = ( texCoord435 / ( _PixelsPerUnit * (_MainTex_TexelSize).xy ) );
				
				float2 temp_output_171_0_g12138 = staticSwitch1_g11662;
				float3 rotatedValue136_g12138 = RotateAroundAxis( float3( 0,0,0 ), float3( temp_output_171_0_g12138 ,  0.0 ), float3( 0,0,1 ), ( ( ( _DirectionalGlowFadeRotation / 180.0 ) + -0.25 ) * UNITY_PI ) );
				float3 break130_g12138 = rotatedValue136_g12138;
				float linValue16_g12139 = tex2D( _UberNoiseTexture, ( temp_output_171_0_g12138 * _DirectionalGlowFadeNoiseScale ) ).r;
				float localMyCustomExpression16_g12139 = MyCustomExpression16_g12139( linValue16_g12139 );
				float temp_output_168_0_g12138 = max( ( ( break130_g12138.x + break130_g12138.y + _DirectionalGlowFadeFade + ( localMyCustomExpression16_g12139 * _DirectionalGlowFadeNoiseFactor ) ) / max( _DirectionalGlowFadeWidth , 0.001 ) ) , 0.0 );
				float temp_output_161_0_g12138 = step( 0.1 , (( _DirectionalGlowFadeInvert )?( ( 1.0 - temp_output_168_0_g12138 ) ):( temp_output_168_0_g12138 )) );
				float4 temp_output_1_0_g12138 = staticSwitch8_g11874;
				float clampResult154_g12138 = clamp( temp_output_161_0_g12138 , 0.0 , 1.0 );
				float4 appendResult3_g12138 = (float4(( ( (_DirectionalGlowFadeEdgeColor).rgb * ( temp_output_161_0_g12138 - step( 1.0 , (( _DirectionalGlowFadeInvert )?( ( 1.0 - temp_output_168_0_g12138 ) ):( temp_output_168_0_g12138 )) ) ) ) + (temp_output_1_0_g12138).rgb ) , ( temp_output_1_0_g12138.a * clampResult154_g12138 )));
				fixed4 c = appendResult3_g12138;
				c.rgb *= c.a;
				return c;
            }
            ENDCG
        }
    }
}
