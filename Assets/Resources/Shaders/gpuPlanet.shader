Shader "Custom/gpuPlanet"
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
				float2 seed = i.uv + (_Center.xz + _Center.y) / 100000;
				// sample the texture
				float height = simplex(seed * 11) + 0.5 * simplex(seed * 21) + 0.5 * simplex(seed * 43) + 0.2 * simplex(seed * 89);

				float2 equator = 1.0 - abs(2 * (i.uv - 0.5));
				float h = min(equator.x, pow(equator.y, 2));

				height *= h;
				
				fixed4 col = height;

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
				float2 
					seed = i.uv + (_Center.xz + _Center.y) / 100000,
					lseed = i.uv + float2(2, 0) / 1024 + (_Center.xz + _Center.y) / 100000,
					tseed = i.uv + float2(0, 2) / 512 + (_Center.xz + _Center.y) / 100000;

				// sample the texture
				float 
					height = simplex(seed * 7) + 0.5 * simplex(seed * 10) + 0.5 * simplex(seed * 29) + 0.3 * simplex(float2(seed.x * 2, seed.y) * 31) + 0.2 * simplex(float2(seed.x * 2, seed.y) * 77),
					lheight = simplex(lseed * 7) + 0.5 * simplex(lseed * 10) + 0.5 * simplex(lseed * 29) + 0.3 * simplex(float2(lseed.x * 2, lseed.y) * 31) + 0.2 * simplex(float2(lseed.x * 2, lseed.y) * 77),
					theight = simplex(tseed * 7) + 0.5 * simplex(tseed * 10) + 0.5 * simplex(tseed * 29) + 0.3 * simplex(float2(tseed.x * 2, tseed.y) * 31) + 0.2 * simplex(float2(tseed.x * 2, tseed.y) * 77);
				float3 normal = float3(0.5, 0.5, 1);

				float2 equator = 1.0 - abs(2 * (i.uv - 0.5));
				float h = min(equator.x, pow(equator.y, 2));
				
				height *= h;
				lheight *= h;
				theight *= h;
				
				height = (height > 0 ? height : 0);
				lheight = (lheight > 0 ? lheight : 0);
				theight = (theight > 0 ? theight : 0);

				if (height > 0.05)
				{
					normal = float3(lheight - height, theight - height, 1);
					normal = normalize(normal);
					normal.xy = (normal.xy + 1) / 2;
				}

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
				float2 seed = i.uv + (_Center.xz + _Center.y) / 100000;
				// sample the texture
				float 
					height = simplex(seed * 7) + 0.5 * simplex(seed * 10) + 0.5 * simplex(seed * 29) + 0.2 * simplex(seed * 73),
					landVar = simplex(seed * 4),
					r1 = abs(simplex(((_Center.xz + _Center.y) / 100000) * 0.1031 + 0.121)),
					g1 = abs(simplex(((_Center.xz + _Center.y) / 100000) * 0.3012 + 0.238)),
					b1 = abs(simplex(((_Center.xz + _Center.y) / 100000) * 0.4013 + 0.349)),
					r2 = abs(simplex(((_Center.xz + _Center.y) / 100000) * 0.5012 + 0.321)),
					g2 = abs(simplex(((_Center.xz + _Center.y) / 100000) * 0.1032 + 0.281)),
					b2 = abs(simplex(((_Center.xz + _Center.y) / 100000) * 0.2039 + 0.109)),
					r3 = abs(simplex(((_Center.xz + _Center.y) / 100000) * 0.9193 + 0.120)),
					g3 = abs(simplex(((_Center.xz + _Center.y) / 100000) * 0.4444 + 0.149)),
					b3 = abs(simplex(((_Center.xz + _Center.y) / 100000) * 0.9019 + 0.389));

				float2 equator = 1.0 - abs(2 * (i.uv - 0.5));
				float h = min(equator.x, pow(equator.y, 2));

				height *= h;

				height = height > 0 ? height : 0;

				fixed4 
					landCol = max(landVar, 0.5) * fixed4(r1, g1, b1, 0) + max((1 - landVar), 0.5) * fixed4(r3, g3, b3, 0),
					waterCol = fixed4(r2, g2, b2, 1),
					coastCol = fixed4(landCol.x + waterCol.x, landCol.y + waterCol.y, landCol.z + waterCol.z, 0.5);

				fixed4 col = height > 0.05 ? (height > 0.1 ? landCol : coastCol) : waterCol;

				col.a /= 2;
 
				return col;
			}
			ENDCG
		}
	}
}
