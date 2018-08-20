Shader "Unlit/FenceShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			float plot(fixed x, fixed y)
			{
				x = pow(x, 1.3);
				return smoothstep(x-0.02, x, y) - smoothstep(x, x + 0.02, y);
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				// fixed4 col = tex2D(_MainTex, i.uv);
				float value = smoothstep(0.1, 0.7, i.uv.x);
				fixed3 col = fixed3(value,value,value);

				float pct = plot(i.uv.x, i.uv.y);

				col = (1.0 - pct) * col + pct * fixed3(0,1,0);
				
				return fixed4(col, 1);
			}
			ENDCG
		}
	}
}
