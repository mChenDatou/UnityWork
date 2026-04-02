Shader "CDT/FullGlowDissolve"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    	_UberNoiseTexture("Noise Texture", 2D) = "white" {}
    	_Color ("Tint", Color) = (1,1,1,1)
		_FullGlowDissolveFade("Fade", Range( 0 , 1)) = 0.5
		_FullGlowDissolveWidth("Width", Float) = 0.5
		[HDR]_FullGlowDissolveEdgeColor("Edge Color", Color) = (11.98431,0.627451,0.627451,0)
		_FullGlowDissolveNoiseScale("Noise Scale", Vector) = (0.1,0.1,0,0)
    	_PixelsPerUnit("Pixels Per Unit", Float) = 100
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
            uniform sampler2D _UberNoiseTexture;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            uniform fixed4 _Color;
			uniform float4 _FullGlowDissolveEdgeColor;
			uniform float2 _FullGlowDissolveNoiseScale;
			uniform float _FullGlowDissolveFade;
			uniform float _FullGlowDissolveWidth;
            uniform float _PixelsPerUnit;
            
			float MyCustomExpression16_g12143( float linValue )
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
				OUT.color = IN.color * _Color;
                return OUT;
            }

			fixed4 frag(v2f IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );
				float2 texCoord435 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 staticSwitch8_g11874 = tex2D( _MainTex, texCoord435);
				float2 staticSwitch1_g11662 =  texCoord435 / ( _PixelsPerUnit * _MainTex_TexelSize.xy ) ;
				float linValue16_g12143 = tex2D( _UberNoiseTexture,  staticSwitch1_g11662 * _FullGlowDissolveNoiseScale  ).r;
				float localMyCustomExpression16_g12143 = MyCustomExpression16_g12143( linValue16_g12143 );
				float temp_output_5_0_g12142 = localMyCustomExpression16_g12143;
				float temp_output_61_0_g12142 = step( temp_output_5_0_g12142 , _FullGlowDissolveFade );
				float temp_output_53_0_g12142 = max(  _FullGlowDissolveFade * _FullGlowDissolveWidth  , 0.001 );
				float4 temp_output_1_0_g12142 = staticSwitch8_g11874;
				float4 appendResult3_g12142 = float4(_FullGlowDissolveEdgeColor.rgb * ( temp_output_61_0_g12142 - step( temp_output_5_0_g12142, 
													_FullGlowDissolveFade * ( 1.01 + temp_output_53_0_g12142 )  - temp_output_53_0_g12142  ) )  + temp_output_1_0_g12142.rgb,
													temp_output_1_0_g12142.a * temp_output_61_0_g12142 );
				fixed4 c = appendResult3_g12142;
				c.rgb *= c.a;
				return c;
            }
            ENDCG
        }
    }
}
