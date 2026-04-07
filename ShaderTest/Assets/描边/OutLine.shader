Shader "CDT/OutLine"
{
    Properties{
    	[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_OuterOutlineFade("Outer Outline: Fade", Range( 0 , 1)) = 1
		[HDR]_OuterOutlineColor("Outer Outline: Color", Color) = (0,0,0,1)
		_OuterOutlineWidth("Outer Outline: Width", Float) = 0.04
		_OuterOutlineDistortionIntensity("Outer Outline: Distortion Intensity", Vector) = (0.01,0.01,0,0)
    	_UberNoiseTexture("Uber Noise Texture", 2D) = "white" {}
		_OuterOutlineNoiseScale("Outer Outline: Noise Scale", Vector) = (4,4,0,0)
		_OuterOutlineNoiseSpeed("Outer Outline: Noise Speed", Vector) = (0,0.1,0,0)
		_OuterOutlineTintTexture("Outer Outline: Tint Texture", 2D) = "white" {}
		_OuterOutlineTextureSpeed("Outer Outline: Texture Speed", Vector) = (0.5,0,0,0)
		[Toggle] _OuterOutlineOutlineOnlyToggle("Outer Outline: Outline Only Toggle", Int) = 0
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
            uniform float4 _OuterOutlineColor;
			uniform sampler2D _OuterOutlineTintTexture;
			uniform float2 _OuterOutlineTextureSpeed;
			uniform float _OuterOutlineFade;
			uniform float2 _OuterOutlineNoiseSpeed;
			uniform float2 _OuterOutlineNoiseScale;
			uniform float2 _OuterOutlineDistortionIntensity;
			uniform float _OuterOutlineWidth;
            uniform sampler2D _UberNoiseTexture;
            uniform int _OuterOutlineOutlineOnlyToggle;
            
			float MyCustomExpression16_g12064( float linValue )
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
				float4 staticSwitch8_g11874 = tex2D( _MainTex, texCoord435 ) * IN.color;
				float3 staticSwitch199_g12063 = tex2D( _OuterOutlineTintTexture,  texCoord435 +  _OuterOutlineTextureSpeed * _Time.y   ).rgb * _OuterOutlineColor.rgb ;
				float temp_output_182_0_g12063 =  ( 1.0 - staticSwitch8_g11874.a ) * min(  _OuterOutlineFade * 3.0  , 1.0 ) ;
				float staticSwitch203_g12063 = lerp(temp_output_182_0_g12063, 1.0, step(0.5 ,_OuterOutlineOutlineOnlyToggle));
				float3 lerpResult178_g12063 = lerp(staticSwitch8_g11874.rgb , staticSwitch199_g12063 , staticSwitch203_g12063);
				float3 lerpResult170_g12063 = lerp( lerpResult178_g12063 , staticSwitch199_g12063 , staticSwitch203_g12063);
				float linValue16_g12064 = tex2D( _UberNoiseTexture,  (  _Time.y * _OuterOutlineNoiseSpeed  + texCoord435 ) * _OuterOutlineNoiseScale  ).r;
				float localMyCustomExpression16_g12064 = MyCustomExpression16_g12064( linValue16_g12064 );
				float2 staticSwitch157_g12063 = ( localMyCustomExpression16_g12064 - 0.5 ) * _OuterOutlineDistortionIntensity;
				//float2 staticSwitch157_g12063 = float2( 0,0 );
				float2 temp_output_131_0_g12063 = staticSwitch157_g12063 + texCoord435;
				float2 appendResult2_g12065 = float2(_MainTex_TexelSize.z , _MainTex_TexelSize.w);
				float2 temp_output_25_0_g12063 = 100.0 / appendResult2_g12065;
				float lerpResult168_g12063 = lerp( staticSwitch8_g11874.a , min( ( max( max( max( max( max( max( max( tex2D( _MainTex, ( temp_output_131_0_g12063 + ( ( _OuterOutlineWidth * float2( 0,-1 ) ) * temp_output_25_0_g12063 ) ) ).a , tex2D( _MainTex, ( temp_output_131_0_g12063 + ( ( _OuterOutlineWidth * float2( 0,1 ) ) * temp_output_25_0_g12063 ) ) ).a ) , tex2D( _MainTex, ( temp_output_131_0_g12063 + ( ( _OuterOutlineWidth * float2( -1,0 ) ) * temp_output_25_0_g12063 ) ) ).a ) , tex2D( _MainTex, ( temp_output_131_0_g12063 + ( ( _OuterOutlineWidth * float2( 1,0 ) ) * temp_output_25_0_g12063 ) ) ).a ) , tex2D( _MainTex, ( temp_output_131_0_g12063 + ( ( _OuterOutlineWidth * float2( 0.705,0.705 ) ) * temp_output_25_0_g12063 ) ) ).a ) , tex2D( _MainTex, ( temp_output_131_0_g12063 + ( ( _OuterOutlineWidth * float2( -0.705,0.705 ) ) * temp_output_25_0_g12063 ) ) ).a ) , tex2D( _MainTex, ( temp_output_131_0_g12063 + ( ( _OuterOutlineWidth * float2( 0.705,-0.705 ) ) * temp_output_25_0_g12063 ) ) ).a ) , tex2D( _MainTex, ( temp_output_131_0_g12063 + ( ( _OuterOutlineWidth * float2( -0.705,-0.705 ) ) * temp_output_25_0_g12063 ) ) ).a ) * 3.0 ) , 1.0 ) , _OuterOutlineFade);
				float staticSwitch200_g12063 = lerp(1, temp_output_182_0_g12063, step(0.5 ,_OuterOutlineOutlineOnlyToggle)) * lerpResult168_g12063;
				float4 appendResult174_g12063 = float4(lerpResult170_g12063 , staticSwitch200_g12063);
				float4 staticSwitch13_g12026 = appendResult174_g12063;
				staticSwitch13_g12026.rgb *= staticSwitch13_g12026.a;
                return staticSwitch13_g12026;
            }
            ENDCG
        }
    }
}
