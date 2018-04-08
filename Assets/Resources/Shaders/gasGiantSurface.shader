Shader "Custom/gasGiantSurface" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Detail ("Gas Detail", 2D) = "gray" {}
		_BumpMap ("Bumpmap", 2D) = "bump" {}
		_RimPower ("Rim Power", Range(1.0,3.0)) = 0.5
		_Center ("Center", Float) = (0.0, 0.0, 0.0, 0.0)
		_CloudMovement ("Cloud Movement", Float) = (0.0, 0.0, 0.0, 0.0)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#include "Noise.cginc"
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf BlinnPhong

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		float noise(float2 position, int octaves, float frequency, float persistence) {
			float total = 0.0; // Total value so far
			float maxAmplitude = 0.0; // Accumulates highest theoretical amplitude
			float amplitude = 1.0;

			// Get the noise sample
			total += ((1.0 - abs(simplex(position * frequency))) * 2.0 - 1.0) * amplitude;

			// Make the wavelength twice as small
			frequency *= 2.0;

			// Add to our maximum possible amplitude
			maxAmplitude += amplitude;

			// Reduce amplitude according to persistence for the next octave
			amplitude *= persistence;

			// Scale the result by the maximum amplitude
			return total / maxAmplitude;
		}

		sampler2D _MainTex;
		sampler2D _BumpMap;
		sampler2D _Detail;

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMap;
			float2 uv_Detail;
			float3 viewDir;
			float3 worldPos;
		};

		fixed4 _Color;
		float4 _Center;
		float2 _CloudMovement;
		float _RimPower;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)
		
		void surf(Input IN, inout SurfaceOutput o)
		{
			float2 seed = IN.uv_MainTex + _Center.xz + _Center.y + _Time[1] * _CloudMovement,
				equator = max(1.0 - abs(2 * (IN.uv_MainTex - 0.5)), 0);

			IN.uv_MainTex += noise(seed, 1, 80.0, 1) * 0.005 * pow(equator.x, 0.6);

			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
			o.Albedo = c.rgb;
			o.Alpha = c.a;
			half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));
			float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
			float3 normal = normalize(IN.worldPos - _Center);
			float intensity = dot(normal, lightDirection) + 0.7;
			o.Emission = intensity * c.rgb * pow (rim, _RimPower);
			o.Albedo *= pow(tex2D(_Detail, IN.uv_MainTex + IN.uv_Detail).rgb, 0.2) * 2;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
