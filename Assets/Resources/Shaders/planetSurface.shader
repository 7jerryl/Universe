// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: commented out 'float4x4 _Object2World', a built-in variable
// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/planetSurface" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_Detail ("Land Detail", 2D) = "gray" {}
		_Detail2 ("Water Detail", 2D) = "gray" {}
		_Detail3 ("Cloud Detail", 2D) = "gray" {}
		_Detail4 ("Land Detail2", 2D) = "gray" {}
		_BumpMap ("Bumpmap", 2D) = "bump" {}
		_Clouds ("Clouds", 2D) = "white" {}
		_RimColor ("Rim Color", Color) = (0.0, 0.0, 0.0, 0.0)
		_RimPower ("Rim Power", Range(1.0,3.0)) = 0.5
		_Center ("Center", Float) = (0.0, 0.0, 0.0, 0.0)
		_SpecColor ("Specular Color", Color) = (1,1,1,1)
		_SpecPower ("Specular Power", Range (0.05, 1)) = 0.078125
		_CloudColor ("Cloud Color", Color) = (1,1,1,1)
		_CloudMovement ("Cloud Movement", Float) = (0.0, 0.0, 0.0, 0.0)
		_Center ("Center", Float) = (0.0, 0.0, 0.0, 0.0)
		_Star ("Star", Float) = (0.0, 0.0, 0.0, 0.0)
		_Distance ("Object Distance From Player", Float) = 1.0
    }
    SubShader {
		Tags { "RenderType" = "Opaque" }

		Cull Back

		CGPROGRAM
		
		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		#pragma surface surf BlinnPhong vertex:vert

		#include "Noise.cginc"

		struct Input {
			float2 uv_MainTex;

			float3 viewDir;
			float3 worldPos;
			float3 emission;

			float intensity;
			float2 equator;
		};

		sampler2D _MainTex;
		sampler2D _BumpMap;
		sampler2D _Clouds;
		sampler2D _Detail;
		sampler2D _Detail2;
		sampler2D _Detail3;
		sampler2D _Detail4;
		float4 _Center;
		float4 _Star;
		float4 _RimColor;
		float _RimPower;
		float _SpecPower;
		float2 _CloudMovement;
		float4 _CloudColor;
		float _Distance;

		void vert (inout appdata_full v, out Input o) {
			/*
			float U = 1.0 / 1024, V = 1.0 / 512;
			
			fixed4 tex = tex2Dlod(_MainTex, v.texcoord),
				tl = tex2Dlod(_MainTex, v.texcoord - float4(U, 0, 0, 0)),
				tr = tex2Dlod(_MainTex, v.texcoord + float4(U, 0, 0, 0)),
				tt = tex2Dlod(_MainTex, v.texcoord - float4(0, V, 0, 0)),
				tb = tex2Dlod(_MainTex, v.texcoord + float4(0, V, 0, 0)),
				ttl = tex2Dlod(_MainTex, v.texcoord - float4(U, V, 0, 0)),
				ttr = tex2Dlod(_MainTex, v.texcoord + float4(U, -V, 0, 0)),
				tbl = tex2Dlod(_MainTex, v.texcoord - float4(U, -V, 0, 0)),
				tbr = tex2Dlod(_MainTex, v.texcoord + float4(U, V, 0, 0));

			float2 equator = 1.0 - abs(2 * (v.texcoord - 0.5));
			float eqdist = min(equator.x, equator.y),
				height = 2 * (0.25 - tex.a),
				hills = simplex(37 * equator);

			if (_Distance < 1)
			{
				height *= (1 - _Distance);

				if (height > 0)
					v.vertex.xyz += 100 * height * (1 + hills) * v.normal.xyz;
				else if (height >= -0.005)
					v.vertex.xyz += 5 * (1 + hills) * v.normal.xyz;
				else if (tex.a > 0.45 && tl.a > 0.45 && tr.a > 0.45 && tt.a > 0.45 && tb.a > 0.45
					&& ttl.a > 0.45 && ttr.a > 0.45 && tbl.a > 0.45 && tbr.a > 0.45)
					v.vertex.xyz += 10 * max(0, sin(-_Time.xyz / 4 + v.vertex.xyz)) * v.normal.xyz;
			}
			*/
			UNITY_INITIALIZE_OUTPUT(Input, o);
			fixed4 tex = tex2Dlod(_MainTex, v.texcoord);
			
			o.worldPos = mul(unity_ObjectToWorld, v.vertex);
			o.viewDir = WorldSpaceViewDir(v.vertex);

			float3 lightDirection = -normalize(_WorldSpaceLightPos0.xyz);//normalize(o.worldPos - _Star.xyz);
			float3 normal = normalize(o.worldPos - _Center);
			float emissIntensity = pow(1 - dot(normal, lightDirection), 2) / 2;
			half rim = 1.2 - saturate(dot(normalize(o.viewDir), normal));
			float waterGlow = max(_Distance, 0.2);

			if (_Distance < 0.1)
			{
				waterGlow *= (tex.a >= 0.5);
			}
			
			o.intensity = (1 - dot(normal, lightDirection)) / 2;
			o.emission = pow(emissIntensity * _RimColor.rgb * pow (rim, 2 * _RimPower) * waterGlow, 2);
			o.equator = 1.0 - abs(2 * (v.texcoord - 0.5));//min(equator.x, pow(equator.y, 4));
		}

		void surf(Input IN, inout SurfaceOutput o) 
		{
			float2 
				uv_Clouds = IN.uv_MainTex + _Time[1] * _CloudMovement + _Center.xz / 100000,
				uv_BumpMap = IN.uv_MainTex,
				uv_Detail = float2(25.0, 25.0) * IN.uv_MainTex,
				uv_Detail2 = float2(13.0, 13.0) * IN.uv_MainTex,
				uv_Detail3 = float2(50.0, 50.0) * IN.uv_MainTex,
				uv_Detail4 = float2(250.0, 250.0) * IN.uv_MainTex;

			float2 seed = IN.uv_MainTex + (_Center.xz + _Center.y) / 100000;

			//IN.uv_MainTex += sin((IN.uv_MainTex.x + IN.uv_MainTex.y) * 1000) * 0.0005;//simplex(IN.uv_MainTex * 1000) * 0.0005;
			IN.uv_MainTex += simplex(IN.uv_MainTex * 1000) * 0.0005;

			fixed4 tex = tex2D(_MainTex, IN.uv_MainTex),
				clouds = tex2D(_Clouds, uv_Clouds);

			float centerMultiplier = min(IN.equator.x, pow(IN.equator.y, 4));

			clouds = _CloudColor * clouds * _Distance;

			o.Specular = _SpecPower;
			o.Gloss = 0.7 * pow(IN.intensity, 2) * (tex.a > 0.4) * tex.a * (1 - clouds);// * _Distance;
			o.Albedo = tex.rgb;
			o.Alpha = tex.a;
			o.Normal = UnpackNormal(tex2D(_BumpMap, uv_BumpMap));
			o.Emission = IN.emission;

			//5 * pow(intensity, 2) * _RimColor.rgb * pow (rim, _RimPower); 
			//pow(emissIntensity * _RimColor.rgb * pow (rim, _RimPower) * max(_Distance, 0.2) * (tex.a > 0.4), 4) * 8;

			if (tex.a < 0.4/* && _Distance < 0.4 || tex.a >= 0.4 && _Distance < 0.001*/)
				o.Albedo *= (0.5 * (1 + _Distance) * tex2D(_Detail, uv_Detail).rgb
					+ 0.5 * tex2D(_Detail4, uv_Detail4).rgb * (1 - _Distance)) * 2;
			else
			{
				//if (tex.a < 0.49)
				/*
                float
                    center = tex2D(_MainTex, IN.uv_MainTex).a,
                    left = tex2D(_MainTex, IN.uv_MainTex + float2(-1.0, 0.0) / float2(1024.0, 512.0)).a,
                    right = tex2D(_MainTex, IN.uv_MainTex + float2(1.0, 0.0) / float2(1024.0, 512.0)).a,
                    top = tex2D(_MainTex, IN.uv_MainTex + float2(0.0, -1.0) / float2(1024.0, 512.0)).a,
                    bottom = tex2D(_MainTex, IN.uv_MainTex + float2(0.0, 1.0) / float2(1024.0, 512.0)).a,
                    tl = tex2D(_MainTex, IN.uv_MainTex + float2(-1.0, -1.0) / float2(1024.0, 512.0)).a,
                    tr = tex2D(_MainTex, IN.uv_MainTex + float2(-1.0, 1.0) / float2(1024.0, 512.0)).a,
                    bl = tex2D(_MainTex, IN.uv_MainTex + float2(1.0, -1.0) / float2(1024.0, 512.0)).a,
                    br = tex2D(_MainTex, IN.uv_MainTex + float2(1.0, 1.0) / float2(1024.0, 512.0)).a;

				if (!(center >= 0.4 && left >= 0.4 && right >= 0.4 && top >= 0.4 && 
					bottom >= 0.4 && tl >= 0.4 && tr >= 0.4 && bl >= 0.4 && br >= 0.4))
					o.Albedo = tex2D(_MainTex, IN.uv_MainTex + simplex(IN.uv_MainTex * 1000 + 2 * _Time[0]) * 0.0005);
					*/
				o.Albedo = tex2D(_MainTex, IN.uv_MainTex + simplex(IN.uv_MainTex * 1000 + 2 * _Time[0]) * 0.0005);
				o.Albedo *= (1 - centerMultiplier + tex2D(_Detail2, uv_Detail2 + _Time[0] * 0.02).rgb * 2 * centerMultiplier) * 1.2;
			}
			/*
			else
				o.Albedo *= 0.8 * (1 - h + tex2D(_Detail2, uv_Detail2 + _Time[0] * 0.02).rgb * 2 * h);
				*/

			o.Albedo = (1 - clouds) * o.Albedo + min(clouds * tex2D(_Detail3, uv_Detail3).rgb * 8 * IN.intensity, 6);
		}
		ENDCG
    } 
    Fallback "Specular"
}
