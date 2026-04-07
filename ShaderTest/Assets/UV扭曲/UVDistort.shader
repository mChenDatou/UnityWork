Shader "CDT/UVDistort"
{
    Properties{
    	[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
    	[NoScaleOffset]_UVDistortMask("UV Distort: Mask", 2D) = "white" {}
        _UVDistortFade("UV Distort: Fade", Range( 0 , 1)) = 1
        _UVDistortFrom("UV Distort: From", Vector) = (-0.02,-0.02,0,0)
        _UVDistortTo("UV Distort: To", Vector) = (0.02,0.02,0,0)
        _UVDistortSpeed("UV Distort: Speed", Vector) = (2,2,0,0)
        _UVDistortNoiseScale("UV Distort: Noise Scale", Vector) = (0.1,0.1,0,0)
    	_UberNoiseTexture("Uber Noise Texture", 2D) = "white" {}
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
            uniform float2 _UVDistortFrom;
            uniform float2 _UVDistortTo;
            uniform float2 _UVDistortSpeed;
            uniform float2 _UVDistortNoiseScale;
            uniform float _UVDistortFade;
            uniform sampler2D _UVDistortMask;
            uniform float4 _UVDistortMask_ST;
            uniform sampler2D _UberNoiseTexture;
 
            float MyCustomExpression16_g11789( float linValue )
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
				float linValue16_g11789 = tex2D( _UberNoiseTexture,  ( texCoord435 +  _UVDistortSpeed * _Time.y  ) * _UVDistortNoiseScale  ).r;
				float localMyCustomExpression16_g11789 = MyCustomExpression16_g11789( linValue16_g11789 );
				float2 lerpResult21_g11786 = lerp( _UVDistortFrom , _UVDistortTo , localMyCustomExpression16_g11789);
				float2 appendResult2_g11788 = float2(_MainTex_TexelSize.z , _MainTex_TexelSize.w);
				float2 uv_UVDistortMask = IN.texcoord.xy * _UVDistortMask_ST.xy + _UVDistortMask_ST.zw;
				float4 tex2DNode3_g11787 = tex2D( _UVDistortMask, uv_UVDistortMask );
				float staticSwitch29_g11786 =  _UVDistortFade * ( tex2DNode3_g11787.r * tex2DNode3_g11787.a ) ;
				float2 staticSwitch5_g11779 =  texCoord435 + lerpResult21_g11786 * ( 100.0 / appendResult2_g11788 ) * staticSwitch29_g11786;
				fixed4 staticSwitch8_g11874 = tex2D( _MainTex, staticSwitch5_g11779 );
				staticSwitch8_g11874.rgb *= staticSwitch8_g11874.a;
                return staticSwitch8_g11874;
            }
            ENDCG
        }
    }
}
