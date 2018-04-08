Shader "Hidden/MainEffects"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_CloudTex ("Clouds", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		_Distance ("Distance", Float) = 0.0
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Noise.cginc"

			float random(float2 p)
			{
				// We need irrationals for pseudo randomness.
				// Most (all?) known transcendental numbers will (generally) work.
				const float2 r = float2(
					23.1406926327792690,  // e^pi (Gelfond's constant)
					2.6651441426902251); // 2^sqrt(2) (Gelfond–Schneider constant)
				return frac(cos(fmod(123456789., 1e-7 + 256. * dot(p,r))));  
			}

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _CloudTex;
			fixed4 _Color;
			float _Distance;

			/*
			fixed4 blur(float2 uv)
			{
				float u = 1.0 / 1080.0, v = 1.0 / 720.0;

				fixed4 
					col = tex2D(_MainTex, uv),
					lcol = tex2D(_MainTex, uv + float2(-u, 0.0)),
					rcol = tex2D(_MainTex, uv + float2(u, 0.0)),
					tcol = tex2D(_MainTex, uv + float2(0.0, -v)),
					bcol = tex2D(_MainTex, uv + float2(0.0, v)),
					ltcol = tex2D(_MainTex, uv + float2(-u, -v)),
					lbcol = tex2D(_MainTex, uv + float2(-u, v)),
					rtcol = tex2D(_MainTex, uv + float2(u, -v)),
					rbcol = tex2D(_MainTex, uv + float2(u, v));

				col += lcol + rcol + tcol + bcol + ltcol + lbcol + rtcol + rbcol;

				col /= 9.0;

				return col;
			}
			*/

			fixed4 frag (v2f i) : SV_Target
			{
				/*
				float h = clamp(distance(i.uv, 0.5), 0.0, 1.0) * 2;

				float theta = random(_Distance) * 0.5 + _Time[0] * 0.1,
					sinT = sin(theta),
					cosT = cos(theta);
				float2x2 rotationMatrix = float2x2(cosT, -sinT, sinT, cosT);

				float2 coord = (0.75 + pow(abs(sin(_Time[0]) / 4), 1.3)) * (mul(i.uv, rotationMatrix) + _Time[0] * 0.2);
				*/
				
				float pDistance = max(clamp(_Distance, 0.0, 1.0), 0.7);

				fixed4 col = tex2D(_MainTex, i.uv);
				
				col = (pDistance) * col + (1 - pDistance) * _Color;

				/*
				fixed4 col = tex2D(_MainTex, i.uv);

				float pDistance = clamp(_Distance, 0.0, 1.0);
					
				col = pDistance * col + (pDistance < 1.0) * (1 - pDistance) * (tex2D(_CloudTex, coord + random(_Distance)) + h)
					* _Color * max(simplex(i.uv * 0.1 + random(_Distance)), 0.5);

					*/

				return col;
			}
			ENDCG
		}
	}
}
