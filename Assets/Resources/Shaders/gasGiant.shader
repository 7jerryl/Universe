Shader "Custom/gasGiant"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Center ("Center", Float) = (0.0, 0.0, 0.0, 0.0)
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
			#include "Noise.cginc"

			float noise(float2 position, int octaves, float frequency, float persistence) {
				float total = 0.0; // Total value so far
				float maxAmplitude = 0.0; // Accumulates highest theoretical amplitude
				float amplitude = 1.0;
				for (int i = 0; i < octaves; i++) {

					// Get the noise sample
					total += ((1.0 - abs(simplex(position * frequency))) * 2.0 - 1.0) * amplitude;

					// Make the wavelength twice as small
					frequency *= 2.0;

					// Add to our maximum possible amplitude
					maxAmplitude += amplitude;

					// Reduce amplitude according to persistence for the next octave
					amplitude *= persistence;
				}

				// Scale the result by the maximum amplitude
				return total / maxAmplitude;
			}

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Center;
			
			v2f vert (appdata_full v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;

				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = 1;
				float2 seed = i.uv + _Center.xz + _Center.y;
				float2 equator = max(1.0 - abs(2 * (i.uv - 0.5)), 0);
				float3 normal = float3(0.5, 0.5, 1);
				/*
				i.uv += noise(seed, 4, 40.0, 0.8) * 0.01 * pow(equator.x, 0.6);

				float2 yseed = i.uv.y + _Center.xz + _Center.y,
					yseedl = i.uv.y + _Center.xz + _Center.y - float2(2, 0) / 1024,
					yseedr = i.uv.y + _Center.xz + _Center.y - float2(0, 2) / 512;

				float line_i = max(0.1, simplex(yseed * 13) + simplex(yseed * 51) + simplex(yseed * 96)),
					line_i_l = max(0.1, simplex(yseedl * 13) + simplex(yseedl * 51) + simplex(yseedl * 96)),
					line_i_t = max(0.1, simplex(yseedr * 13) + simplex(yseedr * 51) + simplex(yseedr * 96));
					
				line_i = max(0, min(line_i, pow(equator.y, 6)));
				line_i_l = max(0, min(line_i_l, pow(equator.y, 6)));
				line_i_t = max(0, min(line_i_t, pow(equator.y, 6)));

				float 
					height = line_i,
					lheight = line_i_l,
					theight = line_i_t;
				
				height = (height > 0 ? height : 0);
				lheight = (lheight > 0 ? lheight : 0);
				theight = (theight > 0 ? theight : 0);

				if (height > 0.05)
				{
					normal = float3(lheight - height, theight - height, 1);
					normal = normalize(normal);
					normal.xy = (normal.xy + 1) / 2;
				}
				*/

				col.xyz = normal;

				return col;
			}
			ENDCG
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "Noise.cginc"

			float noise(float2 position, int octaves, float frequency, float persistence) {
				float total = 0.0; // Total value so far
				float maxAmplitude = 0.0; // Accumulates highest theoretical amplitude
				float amplitude = 1.0;
				for (int i = 0; i < octaves; i++) {

					// Get the noise sample
					total += ((1.0 - abs(simplex(position * frequency))) * 2.0 - 1.0) * amplitude;

					// Make the wavelength twice as small
					frequency *= 2.0;

					// Add to our maximum possible amplitude
					maxAmplitude += amplitude;

					// Reduce amplitude according to persistence for the next octave
					amplitude *= persistence;
				}

				// Scale the result by the maximum amplitude
				return total / maxAmplitude;
			}

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Center;
			
			v2f vert (appdata_full v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;

				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = 1;
				float2 seed = i.uv + _Center.xz + _Center.y,
					equator = max(1.0 - abs(2 * (i.uv - 0.5)), 0);
					
				// Get the three threshold samples
				float s = 0.6;
				float t1 = simplex(seed * 4.0) - s;
				float t2 = simplex((seed + 6400.0) * 2.0) - s;
				float t3 = simplex((seed + 12800.0) * 2.0) - s;
				// Intersect them and get rid of negatives
				float threshold = max(t1 * t2 * t3, 0.0) * equator;
				// Storms
				float storms = simplex(seed * 0.1) * threshold * equator;

				i.uv += noise(seed, 4, 30.0, 0.8) * 0.01 * pow(equator.x, 0.6) + storms;

				float2 yseed = i.uv.y + _Center.xz + _Center.y;

				float line_i = (simplex(yseed * 9) + simplex(yseed * 21) + simplex(yseed * 51)),
					r1 = abs(simplex((_Center.xz + _Center.y) * 0.1031 + 0.992)),
					g1 = abs(simplex((_Center.xz + _Center.y) * 0.9012 + 0.281)),
					b1 = abs(simplex((_Center.xz + _Center.y) * 0.4013 + 0.373)),
					r2 = abs(simplex((_Center.xz + _Center.y) * 0.5012 + 0.462)),
					g2 = abs(simplex((_Center.xz + _Center.y) * 0.8032 + 0.873)),
					b2 = abs(simplex((_Center.xz + _Center.y) * 0.6039 + 0.183));

				line_i = max(0, min(line_i, pow(equator.y, 6)));

				col = line_i * fixed4(r1, g1, b1, 1) + 
					0.7 * min(1, 0.5 + 1 - line_i) * fixed4(r2, g2, b2, 1);

				return col;
			}
			ENDCG
		}
	}
}
