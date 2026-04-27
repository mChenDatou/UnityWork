Shader "CDT/Glitch"
{
    Properties{
    	[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
    	_UberNoiseTexture("Uber Noise Texture", 2D) = "white" {}
    	_PixelsPerUnit("Pixels Per Unit", Float) = 100
		_GlitchFade("Glitch: Fade", Range( 0 , 1)) = 1
		_GlitchMaskMin("Glitch: Mask Min", Range( 0 , 1)) = 0.4
		_GlitchMaskScale("Glitch: Mask Scale", Vector) = (0,0.2,0,0)
		_GlitchMaskSpeed("Glitch: Mask Speed", Vector) = (0,4,0,0)
		_GlitchHueSpeed("Glitch: Hue Speed", Float) = 1
		_GlitchBrightness("Glitch: Brightness", Float) = 4
		_GlitchNoiseScale("Glitch: Noise Scale", Vector) = (0,3,0,0)
		_GlitchNoiseSpeed("Glitch: Noise Speed", Vector) = (0,1,0,0)
		_GlitchDistortion("Glitch: Distortion", Vector) = (0.1,0,0,0)
		_GlitchDistortionScale("Glitch: Distortion Scale", Vector) = (0,3,0,0)
		_GlitchDistortionSpeed("Glitch: Distortion Speed", Vector) = (0,1,0,0)
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
			uniform float2 _GlitchDistortionSpeed;
			uniform float2 _GlitchDistortionScale;
			uniform float2 _GlitchDistortion;
			uniform float2 _GlitchMaskSpeed;
			uniform float2 _GlitchMaskScale;
			uniform float _GlitchMaskMin;
			uniform float _GlitchFade;
            uniform float _GlitchBrightness;
			uniform float2 _GlitchNoiseSpeed;
			uniform float2 _GlitchNoiseScale;
			uniform float _GlitchHueSpeed;
            
            float MyCustomExpression16_g12072( float linValue )
			{
				#ifdef UNITY_COLORSPACE_GAMMA
				return linValue;
				#else
				linValue = max(linValue, half3(0.h, 0.h, 0.h));
				return max(1.055h * pow(linValue, 0.416666667h) - 0.055h, 0.h);
				#endif
			}
            
            float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
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
				float2 staticSwitch1_g11662 = ( texCoord435 / ( _PixelsPerUnit * (_MainTex_TexelSize).xy ) );
				
				float2 temp_output_18_0_g11671 = staticSwitch1_g11662;
				float2 glitchPosition154 = temp_output_18_0_g11671;
				float linValue16_g11778 = tex2D( _UberNoiseTexture, ( ( glitchPosition154 + ( _GlitchDistortionSpeed * _Time.y ) ) * _GlitchDistortionScale ) ).r;
				float localMyCustomExpression16_g11778 = MyCustomExpression16_g12072( linValue16_g11778 );
				float linValue16_g11672 = tex2D( _UberNoiseTexture, ( ( temp_output_18_0_g11671 + ( _GlitchMaskSpeed * _Time.y ) ) * _GlitchMaskScale ) ).r;
				float localMyCustomExpression16_g11672 = MyCustomExpression16_g12072( linValue16_g11672 );
				float glitchFade152 = ( max( localMyCustomExpression16_g11672 , _GlitchMaskMin ) * _GlitchFade );
				float2 staticSwitch62 = ( texCoord435 + ( ( localMyCustomExpression16_g11778 - 0.5 ) * _GlitchDistortion * glitchFade152 ) );
				float4 staticSwitch8_g11874 = tex2D( _MainTex, staticSwitch62 );
				float4 temp_output_1_0_g12071 = staticSwitch8_g11874;
				float4 break2_g12073 = temp_output_1_0_g12071;
				float temp_output_34_0_g12071 = _Time.y;
				float linValue16_g12072 = tex2D( _UberNoiseTexture, ( ( glitchPosition154 + ( _GlitchNoiseSpeed * temp_output_34_0_g12071 ) ) * _GlitchNoiseScale ) ).r;
				float localMyCustomExpression16_g12072 = MyCustomExpression16_g12072( linValue16_g12072 );
				float3 hsvTorgb3_g12074 = HSVToRGB( float3(( localMyCustomExpression16_g12072 + ( temp_output_34_0_g12071 * _GlitchHueSpeed ) ),1.0,1.0) );
				float3 lerpResult23_g12071 = lerp( (temp_output_1_0_g12071).rgb , ( ( ( break2_g12073.x + break2_g12073.x + break2_g12073.y + break2_g12073.y + break2_g12073.y + break2_g12073.z ) / 6.0 ) * _GlitchBrightness * hsvTorgb3_g12074 ) , glitchFade152);
				float4 appendResult27_g12071 = (float4(lerpResult23_g12071 , temp_output_1_0_g12071.a));
				float4 staticSwitch57 = appendResult27_g12071;
				fixed4 c = staticSwitch57;
				c.rgb *= c.a;
				return c;
            }
            ENDCG
        }
    }
}
