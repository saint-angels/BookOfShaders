Shader "Custom/Dissolve" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _SliceGuide("Slice Guide (RGB)", 2D) = "white" {}
        _SliceAmount("Slice Amount", Range(0.0, 1.0)) = 0
 
        _BurnSize("Burn Size", Range(0.0, 1.0)) = 0.15
        _BurnRamp("Burn Ramp (RGB)", 2D) = "white" {}
        _BurnColor("Burn Color", Color) = (1,1,1,1)
 
        _EmissionAmount("Emission amount", float) = 2.0
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
        Cull Off
        CGPROGRAM
        #pragma surface surf Lambert addshadow
        #pragma target 3.0
		#include "SimplexNoise3D.hlsl"
 
        fixed4 _Color;
        sampler2D _MainTex;
        sampler2D _SliceGuide;
        sampler2D _BumpMap;
        sampler2D _BurnRamp;
        fixed4 _BurnColor;
        float _BurnSize;
        float _SliceAmount;
        float _EmissionAmount;
 
        struct Input {
            float2 uv_MainTex;
        };

		float GetNoise(float2 i_uv)
		{
			//Getting the noise
                const float epsilon = 0.0001;
                float2 uv = i_uv * 4.0 + float2(0.2, 0.5) * _Time.y;
                float noise_val = 0.5;
                float s = 1.0;
                float w = 0.25;
               
                for (int i = 0; i < 6; i++)
                {
                    float3 coord = float3(uv * s, _Time.y);
                    float3 period = float3(s, s, 1.0) * 2.0;
                    noise_val += snoise(coord) * w;

                    //o +=  (coord) * w;
                    s *= 2.0;
                    w *= 0.5;
                }
				return noise_val;
		}
 
 
        void surf (Input IN, inout SurfaceOutput o) {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            half test = GetNoise(IN.uv_MainTex) - _SliceAmount;
            clip(test);
             
            if (test < _BurnSize && _SliceAmount > 0) {
                o.Emission = tex2D(_BurnRamp, float2(test * (1 / _BurnSize), 0)) * _BurnColor * _EmissionAmount;
            }
 
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}