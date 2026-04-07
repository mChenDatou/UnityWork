Shader "CDT/Shine"
{
    Properties{
    	[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
    	_PixelsPerUnit("Pixels Per Unit", Float) = 100
    	_ShineFade("Shine: Fade", Range( 0 , 1)) = 1
		[HDR]_ShineColor("Shine: Color", Color) = (11.98431,11.98431,11.98431,0)
		_ShineSaturation("Shine: Saturation", Range( 0 , 1)) = 0.5
		_ShineContrast("Shine: Contrast", Float) = 2
		_ShineWidth("Shine: Width", Float) = 0.1
		_ShineSpeed("Shine: Speed", Float) = 5
		_ShineRotation("Shine: Rotation", Range( 0 , 360)) = 30
		_ShineSmooth("Shine: Smoothness", Float) = 1
		_ShineFrequency("Shine: Frequency", Float) = 0.3
		[Toggle(_SHINEMASKTOGGLE_ON)] _ShineMaskToggle("Shine: Mask Toggle", Float) = 0
		[NoScaleOffset]_ShineMask("Shine: Mask", 2D) = "white" {}
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
            uniform float _ShineSaturation;
			uniform float _ShineContrast;
			uniform float4 _ShineColor;
			uniform float _ShineRotation;
			uniform float _ShineFrequency;
			uniform float _ShineSpeed;
			uniform float _ShineWidth;
			uniform float _ShineSmooth;
			uniform float _ShineFade;
			uniform sampler2D _ShineMask;
			uniform float4 _ShineMask_ST;
            uniform float _PixelsPerUnit;
            
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
				float2 staticSwitch1_g11662 = texCoord435 / ( _PixelsPerUnit * _MainTex_TexelSize.xy );
				float4 staticSwitch8_g11874 = tex2D( _MainTex, texCoord435 );
				float3 temp_output_57_0_g12076 = (staticSwitch8_g11874).rgb;
				float3 temp_cast_69 = ( ( staticSwitch8_g11874.x + staticSwitch8_g11874.x + staticSwitch8_g11874.y + staticSwitch8_g11874.y + staticSwitch8_g11874.y + staticSwitch8_g11874.z ) / 6.0 ).xxx;
				float3 lerpResult92_g12076 = lerp( temp_cast_69 , temp_output_57_0_g12076 , _ShineSaturation);
				float3 temp_cast_70 = max( max( _ShineContrast , 0.001 ) , 0.0001 ).xxx;
				float3 rotatedValue69_g12076 = RotateAroundAxis( float3( 0,0,0 ), float3( _ShineFrequency * staticSwitch1_g11662 ,  0.0 ), float3( 0,0,1 ),  _ShineRotation / 180.0  * UNITY_PI );
				float temp_output_103_0_g12076 = _ShineFrequency * _ShineWidth;
				float clampResult80_g12076 = clamp(( sin( rotatedValue69_g12076.x -  _Time.y * _ShineSpeed * _ShineFrequency ) - ( 1.0 - temp_output_103_0_g12076 ) ) / temp_output_103_0_g12076  * _ShineSmooth  , 0.0 , 1.0 );
				float2 uv_ShineMask = IN.texcoord.xy * _ShineMask_ST.xy + _ShineMask_ST.zw;
				float4 tex2DNode3_g12077 = tex2D( _ShineMask, uv_ShineMask );
				float staticSwitch98_g12076 = _ShineFade * ( tex2DNode3_g12077.r * tex2DNode3_g12077.a );
				float4 appendResult8_g12076 = float4( temp_output_57_0_g12076 +  ( pow( max( lerpResult92_g12076 , float3( 0.0001,0.0001,0.0001 ) ) , temp_cast_70 ) * _ShineColor).rgb  * clampResult80_g12076 * staticSwitch98_g12076  , staticSwitch8_g11874.a);
				appendResult8_g12076.rgb *= appendResult8_g12076.a;
                return appendResult8_g12076;
            }
            ENDCG
        }
    }
}
