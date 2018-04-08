#ifndef PSEUDO_NOISE
#define PSEUDO_NOISE

//////////////////////////////////////////////////////////////////////////////////
//
// All shader code originally from
//  https://github.com/stegu/webgl-noise/wiki
//  I've blindly ported them to further experiment with later on,
//  but I've tested all except the gradient and 4d ones and they
//  seem to be working. Excuse any errors :)
//
//  Have fun!
//
//        - @yankooliveira
//
//////////////////////////////////////////////////////////////////////////////////
 
//////////////////////////////////////////////////////////////////////////////////
// Helper functions
//////////////////////////////////////////////////////////////////////////////////
 
float2 fade(float2 t) {
	return t*t*t*(t*(t*6.0 - 15.0) + 10.0);
}
 
float3 fade(float3 t) {
	return t*t*t*(t*(t*6.0 - 15.0) + 10.0);
}
 
float4 fade(float4 t) {
	return t*t*t*(t*(t*6.0 - 15.0) + 10.0);
}
 
// Modulo 7 without a division
float4 mod7(float4 x) {
	return x - floor(x * (1.0 / 7.0)) * 7.0;
}
 
// Modulo 7 without a division
float3 mod7(float3 x) {
	return x - floor(x * (1.0 / 7.0)) * 7.0;
}
 
float2 mod289(float2 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}
 
// Modulo 289 without a division (only multiplications)
float3 mod289(float3 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}
 
float4 mod289(float4 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}
 
float mod289(float x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}
 
// Permutation polynomial: (34x^2 + x) mod 289
float3 perm(float3 x) {
	return mod289((34.0 * x + 1.0) * x);
}
 
float4 perm(float4 x) {
	return mod289(((x*34.0) + 1.0)*x);
}
 
float perm(float x) {
	return mod289(((x*34.0) + 1.0)*x);
}
 
float4 tInvSqrt(float4 r)
{
	return 1.79284291400159 - 0.85373472095314 * r;
}
 
float4 lessThan(float4 x, float4 y) {
	return 1 - step(y, x);
}
 
float4 grad4(float j, float4 ip)
{
	const float4 ones = float4(1.0, 1.0, 1.0, -1.0);
	float4 p, s;
 
	p.xyz = floor(frac(float3(j,j,j)* ip.xyz) * 7.0) * ip.z - 1.0;
	p.w = 1.5 - dot(abs(p.xyz), ones.xyz);
	s = float4(lessThan(p, float4(0,0,0,0)));
	p.xyz = p.xyz + (s.xyz*2.0 - 1.0) * s.www;
 
	return p;
}
 
///////////////////////////////////////////////////////////////////////////
//3d noise
//
// Description : Array and textureless GLSL 2D/3D/4D simplex
//               noise functions.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : stegu
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//               https://github.com/stegu/webgl-noise
//
///////////////////////////////////////////////////////////////////////////
 
float simplex3d(float3 v)
{
	const float2  C = float2(1.0 / 6.0, 1.0 / 3.0);
	const float4  D = float4(0.0, 0.5, 1.0, 2.0);
 
	// First corner
	float3 i = floor(v + dot(v, C.yyy));
	float3 x0 = v - i + dot(i, C.xxx);
 
	// Other corners
	float3 g = step(x0.yzx, x0.xyz);
	float3 l = 1.0 - g;
	float3 i1 = min(g.xyz, l.zxy);
	float3 i2 = max(g.xyz, l.zxy);
 
	//   x0 = x0 - 0.0 + 0.0 * C.xxx;
	//   x1 = x0 - i1  + 1.0 * C.xxx;
	//   x2 = x0 - i2  + 2.0 * C.xxx;
	//   x3 = x0 - 1.0 + 3.0 * C.xxx;
	float3 x1 = x0 - i1 + C.xxx;
	float3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
	float3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y
 
									// Permutations
	i = mod289(i);
	float4 p = perm(perm(perm(
		i.z + float4(0.0, i1.z, i2.z, 1.0))
		+ i.y + float4(0.0, i1.y, i2.y, 1.0))
		+ i.x + float4(0.0, i1.x, i2.x, 1.0));
 
	// Gradients: 7x7 points over a square, mapped onto an octahedron.
	// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
	float n_ = 0.142857142857; // 1.0/7.0
	float3  ns = n_ * D.wyz - D.xzx;
 
	float4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)
 
	float4 x_ = floor(j * ns.z);
	float4 y_ = floor(j - 7.0 * x_);    // mod(j,N)
 
	float4 x = x_ *ns.x + ns.yyyy;
	float4 y = y_ *ns.x + ns.yyyy;
	float4 h = 1.0 - abs(x) - abs(y);
 
	float4 b0 = float4(x.xy, y.xy);
	float4 b1 = float4(x.zw, y.zw);
 
	//float4 s0 = float4(lessThan(b0,0.0))*2.0 - 1.0;
	//float4 s1 = float4(lessThan(b1,0.0))*2.0 - 1.0;
	float4 s0 = floor(b0)*2.0 + 1.0;
	float4 s1 = floor(b1)*2.0 + 1.0;
	float4 sh = -step(h, float4(0, 0, 0, 0));
 
	float4 a0 = b0.xzyw + s0.xzyw*sh.xxyy;
	float4 a1 = b1.xzyw + s1.xzyw*sh.zzww;
 
	float3 p0 = float3(a0.xy, h.x);
	float3 p1 = float3(a0.zw, h.y);
	float3 p2 = float3(a1.xy, h.z);
	float3 p3 = float3(a1.zw, h.w);
 
	//Normalise gradients
	float4 norm = tInvSqrt(float4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
	p0 *= norm.x;
	p1 *= norm.y;
	p2 *= norm.z;
	p3 *= norm.w;
 
	// Mix final noise value
	float4 m = max(0.6 - float4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
	m = m * m;
	return 42.0 * dot(m*m, float4(dot(p0, x0), dot(p1, x1),
		dot(p2, x2), dot(p3, x3)));
}
 
///////////////////////////////////////////////////////////////////////////
// Cellular noise ("Worley noise") in 2D in GLSL.
// Copyright (c) Stefan Gustavson 2011-04-19. All rights reserved.
// This code is released under the conditions of the MIT license.
// See LICENSE file for details.
// https://github.com/stegu/webgl-noise
///////////////////////////////////////////////////////////////////////////
 
// Cellular noise, returning F1 and F2 in a float2.
// Standard 3x3 search window for good F1 and F2 values
float2 cellular(float2 P) {
#define K 0.142857142857 // 1/7
#define Ko 0.428571428571 // 3/7
#define jitter 1.0 // Less gives more regular pattern
	float2 Pi = mod289(floor(P));
	float2 Pf = frac(P);
	float3 oi = float3(-1.0, 0.0, 1.0);
	float3 of = float3(-0.5, 0.5, 1.5);
	float3 px = perm(Pi.x + oi);
	float3 p = perm(px.x + Pi.y + oi); // p11, p12, p13
	float3 ox = frac(p*K) - Ko;
	float3 oy = mod7(floor(p*K))*K - Ko;
	float3 dx = Pf.x + 0.5 + jitter*ox;
	float3 dy = Pf.y - of + jitter*oy;
	float3 d1 = dx * dx + dy * dy; // d11, d12 and d13, squared
	p = perm(px.y + Pi.y + oi); // p21, p22, p23
	ox = frac(p*K) - Ko;
	oy = mod7(floor(p*K))*K - Ko;
	dx = Pf.x - 0.5 + jitter*ox;
	dy = Pf.y - of + jitter*oy;
	float3 d2 = dx * dx + dy * dy; // d21, d22 and d23, squared
	p = perm(px.z + Pi.y + oi); // p31, p32, p33
	ox = frac(p*K) - Ko;
	oy = mod7(floor(p*K))*K - Ko;
	dx = Pf.x - 1.5 + jitter*ox;
	dy = Pf.y - of + jitter*oy;
	float3 d3 = dx * dx + dy * dy; // d31, d32 and d33, squared
									// Sort out the two smallest distances (F1, F2)
	float3 d1a = min(d1, d2);
	d2 = max(d1, d2); // Swap to keep candidates for F2
	d2 = min(d2, d3); // neither F1 nor F2 are now in d3
	d1 = min(d1a, d2); // F1 is now in d1
	d2 = max(d1a, d2); // Swap to keep candidates for F2
	d1.xy = (d1.x < d1.y) ? d1.xy : d1.yx; // Swap if smaller
	d1.xz = (d1.x < d1.z) ? d1.xz : d1.zx; // F1 is in d1.x
	d1.yz = min(d1.yz, d2.yz); // F2 is now not in d2.yz
	d1.y = min(d1.y, d1.z); // nor in  d1.z
	d1.y = min(d1.y, d2.x); // F2 is in d1.y, we're done.
	return sqrt(d1.xy);
}
 
///////////////////////////////////////////////////////////////////////////
// Cellular noise, returning F1 and F2 in a float2.
// Speeded up by using 2x2 search window instead of 3x3,
// at the expense of some strong pattern artifacts.
// F2 is often wrong and has sharp discontinuities.
// If you need a smooth F2, use the slower 3x3 version.
// F1 is sometimes wrong, too, but OK for most purposes.
///////////////////////////////////////////////////////////////////////////
 
float2 cellular2x2(float2 P) {
#define K3 0.142857142857
#define K2 0.0714285714285
#define jitter2x2 0.8 // jitter 1.0 makes F1 wrong more often
	float2 Pi = mod289(floor(P));
	float2 Pf = frac(P);
	float4 Pfx = Pf.x + float4(-0.5, -1.5, -0.5, -1.5);
	float4 Pfy = Pf.y + float4(-0.5, -0.5, -1.5, -1.5);
	float4 p = perm(Pi.x + float4(0.0, 1.0, 0.0, 1.0));
	p = perm(p + Pi.y + float4(0.0, 0.0, 1.0, 1.0));
	float4 ox = mod7(p)*K3 + K2;
	float4 oy = mod7(floor(p*K3))*K3 + K2;
	float4 dx = Pfx + jitter2x2*ox;
	float4 dy = Pfy + jitter2x2*oy;
	float4 d = dx * dx + dy * dy; // d11, d12, d21 and d22, squared
								// Sort out the two smallest distances
#if 0
								// Cheat and pick only F1
	d.xy = min(d.xy, d.zw);
	d.x = min(d.x, d.y);
	return float2(sqrt(d.x)); // F1 duplicated, F2 not computed
#else
								// Do it right and find both F1 and F2
	d.xy = (d.x < d.y) ? d.xy : d.yx; // Swap if smaller
	d.xz = (d.x < d.z) ? d.xz : d.zx;
	d.xw = (d.x < d.w) ? d.xw : d.wx;
	d.y = min(d.y, d.z);
	d.y = min(d.y, d.w);
	return sqrt(d.xy);
#endif
}
 
///////////////////////////////////////////////////////////////////////////
// Cellular noise, returning F1 and F2 in a float2.
// Speeded up by using 2x2x2 search window instead of 3x3x3,
// at the expense of some pattern artifacts.
// F2 is often wrong and has sharp discontinuities.
// If you need a good F2, use the slower 3x3x3 version.
///////////////////////////////////////////////////////////////////////////
float2 cellular2x2x2(float3 P) {
#define K4 0.142857142857 // 1/7
#define Kp 0.428571428571 // 1/2-K4/2
#define L_2x2x2 0.020408163265306 // 1/(7*7)
#define Kz 0.166666666667 // 1/6
#define Kzo 0.416666666667 // 1/2-1/6*2
#define jitter2x2x2 0.8 // smaller jitter gives less errors in F2
	float3 Pi = mod289(floor(P));
	float3 Pf = frac(P);
	float4 Pfx = Pf.x + float4(0.0, -1.0, 0.0, -1.0);
	float4 Pfy = Pf.y + float4(0.0, 0.0, -1.0, -1.0);
	float4 p = perm(Pi.x + float4(0.0, 1.0, 0.0, 1.0));
	p = perm(p + Pi.y + float4(0.0, 0.0, 1.0, 1.0));
	float4 p1 = perm(p + Pi.z); // z+0
	float4 p2 = perm(p + Pi.z + float4(1,1,1,1)); // z+1
	float4 ox1 = frac(p1*K4) - Kp;
	float4 oy1 = mod7(floor(p1*K4))*K4 - Kp;
	float4 oz1 = floor(p1*L_2x2x2)*Kz - Kzo; // p1 < 289 guaranteed
	float4 ox2 = frac(p2*K4) - Kp;
	float4 oy2 = mod7(floor(p2*K4))*K4 - Kp;
	float4 oz2 = floor(p2*L_2x2x2)*Kz - Kzo;
	float4 dx1 = Pfx + jitter2x2x2*ox1;
	float4 dy1 = Pfy + jitter2x2x2*oy1;
	float4 dz1 = Pf.z + jitter2x2x2*oz1;
	float4 dx2 = Pfx + jitter2x2x2*ox2;
	float4 dy2 = Pfy + jitter2x2x2*oy2;
	float4 dz2 = Pf.z - 1.0 + jitter2x2x2*oz2;
	float4 d1 = dx1 * dx1 + dy1 * dy1 + dz1 * dz1; // z+0
	float4 d2 = dx2 * dx2 + dy2 * dy2 + dz2 * dz2; // z+1
 
													// Sort out the two smallest distances (F1, F2)
#if 0
													// Cheat and sort out only F1
	d1 = min(d1, d2);
	d1.xy = min(d1.xy, d1.wz);
	d1.x = min(d1.x, d1.y);
	return float2(sqrt(d1.x));
#else
													// Do it right and sort out both F1 and F2
	float4 d = min(d1, d2); // F1 is now in d
	d2 = max(d1, d2); // Make sure we keep all candidates for F2
	d.xy = (d.x < d.y) ? d.xy : d.yx; // Swap smallest to d.x
	d.xz = (d.x < d.z) ? d.xz : d.zx;
	d.xw = (d.x < d.w) ? d.xw : d.wx; // F1 is now in d.x
	d.yzw = min(d.yzw, d2.yzw); // F2 now not in d2.yzw
	d.y = min(d.y, d.z); // nor in d.z
	d.y = min(d.y, d.w); // nor in d.w
	d.y = min(d.y, d2.x); // F2 is now in d.y
	return sqrt(d.xy); // F1 and F2
#endif
}
 
float2 cellular(float3 P) {
#define K6 0.142857142857 // 1/7
#define Kr 0.428571428571 // 1/2-K6/2
#define L_3d 0.020408163265306 // 1/(7*7)
#define Kz1 0.166666666667 // 1/6
#define Kzp 0.416666666667 // 1/2-1/6*2
#define jitter1 1.0 // smaller jitter1 gives more regular pattern
 
	float3 Pi = mod289(floor(P));
	float3 Pf = frac(P) - 0.5;
 
	float3 Pfx = Pf.x + float3(1.0, 0.0, -1.0);
	float3 Pfy = Pf.y + float3(1.0, 0.0, -1.0);
	float3 Pfz = Pf.z + float3(1.0, 0.0, -1.0);
 
	float3 p = perm(Pi.x + float3(-1.0, 0.0, 1.0));
	float3 p1 = perm(p + Pi.y - 1.0);
	float3 p2 = perm(p + Pi.y);
	float3 p3 = perm(p + Pi.y + 1.0);
 
	float3 p11 = perm(p1 + Pi.z - 1.0);
	float3 p12 = perm(p1 + Pi.z);
	float3 p13 = perm(p1 + Pi.z + 1.0);
 
	float3 p21 = perm(p2 + Pi.z - 1.0);
	float3 p22 = perm(p2 + Pi.z);
	float3 p23 = perm(p2 + Pi.z + 1.0);
 
	float3 p31 = perm(p3 + Pi.z - 1.0);
	float3 p32 = perm(p3 + Pi.z);
	float3 p33 = perm(p3 + Pi.z + 1.0);
 
	float3 ox11 = frac(p11*K6) - Kr;
	float3 oy11 = mod7(floor(p11*K6))*K6 - Kr;
	float3 oz11 = floor(p11*L_3d)*Kz1 - Kzp; // p11 < 289 guaranteed
 
	float3 ox12 = frac(p12*K6) - Kr;
	float3 oy12 = mod7(floor(p12*K6))*K6 - Kr;
	float3 oz12 = floor(p12*L_3d)*Kz1 - Kzp;
 
	float3 ox13 = frac(p13*K6) - Kr;
	float3 oy13 = mod7(floor(p13*K6))*K6 - Kr;
	float3 oz13 = floor(p13*L_3d)*Kz1 - Kzp;
 
	float3 ox21 = frac(p21*K6) - Kr;
	float3 oy21 = mod7(floor(p21*K6))*K6 - Kr;
	float3 oz21 = floor(p21*L_3d)*Kz1 - Kzp;
 
	float3 ox22 = frac(p22*K6) - Kr;
	float3 oy22 = mod7(floor(p22*K6))*K6 - Kr;
	float3 oz22 = floor(p22*L_3d)*Kz1 - Kzp;
 
	float3 ox23 = frac(p23*K6) - Kr;
	float3 oy23 = mod7(floor(p23*K6))*K6 - Kr;
	float3 oz23 = floor(p23*L_3d)*Kz1 - Kzp;
 
	float3 ox31 = frac(p31*K6) - Kr;
	float3 oy31 = mod7(floor(p31*K6))*K6 - Kr;
	float3 oz31 = floor(p31*L_3d)*Kz1 - Kzp;
 
	float3 ox32 = frac(p32*K6) - Kr;
	float3 oy32 = mod7(floor(p32*K6))*K6 - Kr;
	float3 oz32 = floor(p32*L_3d)*Kz1 - Kzp;
 
	float3 ox33 = frac(p33*K6) - Kr;
	float3 oy33 = mod7(floor(p33*K6))*K6 - Kr;
	float3 oz33 = floor(p33*L_3d)*Kz1 - Kzp;
 
	float3 dx11 = Pfx + jitter1*ox11;
	float3 dy11 = Pfy.x + jitter1*oy11;
	float3 dz11 = Pfz.x + jitter1*oz11;
 
	float3 dx12 = Pfx + jitter1*ox12;
	float3 dy12 = Pfy.x + jitter1*oy12;
	float3 dz12 = Pfz.y + jitter1*oz12;
 
	float3 dx13 = Pfx + jitter1*ox13;
	float3 dy13 = Pfy.x + jitter1*oy13;
	float3 dz13 = Pfz.z + jitter1*oz13;
 
	float3 dx21 = Pfx + jitter1*ox21;
	float3 dy21 = Pfy.y + jitter1*oy21;
	float3 dz21 = Pfz.x + jitter1*oz21;
 
	float3 dx22 = Pfx + jitter1*ox22;
	float3 dy22 = Pfy.y + jitter1*oy22;
	float3 dz22 = Pfz.y + jitter1*oz22;
 
	float3 dx23 = Pfx + jitter1*ox23;
	float3 dy23 = Pfy.y + jitter1*oy23;
	float3 dz23 = Pfz.z + jitter1*oz23;
 
	float3 dx31 = Pfx + jitter1*ox31;
	float3 dy31 = Pfy.z + jitter1*oy31;
	float3 dz31 = Pfz.x + jitter1*oz31;
 
	float3 dx32 = Pfx + jitter1*ox32;
	float3 dy32 = Pfy.z + jitter1*oy32;
	float3 dz32 = Pfz.y + jitter1*oz32;
 
	float3 dx33 = Pfx + jitter1*ox33;
	float3 dy33 = Pfy.z + jitter1*oy33;
	float3 dz33 = Pfz.z + jitter1*oz33;
 
	float3 d11 = dx11 * dx11 + dy11 * dy11 + dz11 * dz11;
	float3 d12 = dx12 * dx12 + dy12 * dy12 + dz12 * dz12;
	float3 d13 = dx13 * dx13 + dy13 * dy13 + dz13 * dz13;
	float3 d21 = dx21 * dx21 + dy21 * dy21 + dz21 * dz21;
	float3 d22 = dx22 * dx22 + dy22 * dy22 + dz22 * dz22;
	float3 d23 = dx23 * dx23 + dy23 * dy23 + dz23 * dz23;
	float3 d31 = dx31 * dx31 + dy31 * dy31 + dz31 * dz31;
	float3 d32 = dx32 * dx32 + dy32 * dy32 + dz32 * dz32;
	float3 d33 = dx33 * dx33 + dy33 * dy33 + dz33 * dz33;
 
	// Sort out the two smallest distances (F1, F2)
#if 0
	// Cheat and sort out only F1
	float3 d1 = min(min(d11, d12), d13);
	float3 d2 = min(min(d21, d22), d23);
	float3 d3 = min(min(d31, d32), d33);
	float3 d = min(min(d1, d2), d3);
	d.x = min(min(d.x, d.y), d.z);
	return float2(sqrt(d.x)); // F1 duplicated, no F2 computed
#else
	// Do it right and sort out both F1 and F2
	float3 d1a = min(d11, d12);
	d12 = max(d11, d12);
	d11 = min(d1a, d13); // Smallest now not in d12 or d13
	d13 = max(d1a, d13);
	d12 = min(d12, d13); // 2nd smallest now not in d13
	float3 d2a = min(d21, d22);
	d22 = max(d21, d22);
	d21 = min(d2a, d23); // Smallest now not in d22 or d23
	d23 = max(d2a, d23);
	d22 = min(d22, d23); // 2nd smallest now not in d23
	float3 d3a = min(d31, d32);
	d32 = max(d31, d32);
	d31 = min(d3a, d33); // Smallest now not in d32 or d33
	d33 = max(d3a, d33);
	d32 = min(d32, d33); // 2nd smallest now not in d33
	float3 da = min(d11, d21);
	d21 = max(d11, d21);
	d11 = min(da, d31); // Smallest now in d11
	d31 = max(da, d31); // 2nd smallest now not in d31
	d11.xy = (d11.x < d11.y) ? d11.xy : d11.yx;
	d11.xz = (d11.x < d11.z) ? d11.xz : d11.zx; // d11.x now smallest
	d12 = min(d12, d21); // 2nd smallest now not in d21
	d12 = min(d12, d22); // nor in d22
	d12 = min(d12, d31); // nor in d31
	d12 = min(d12, d32); // nor in d32
	d11.yz = min(d11.yz, d12.xy); // nor in d12.yz
	d11.y = min(d11.y, d12.z); // Only two more to go
	d11.y = min(d11.y, d11.z); // Done! (Phew!)
	return sqrt(d11.xy); // F1, F2
#endif
}
 
// Classic Perlin noise
float perlin(float2 P)
{
	float4 Pi = floor(P.xyxy) + float4(0.0, 0.0, 1.0, 1.0);
	float4 Pf = frac(P.xyxy) - float4(0.0, 0.0, 1.0, 1.0);
	Pi = mod289(Pi); // To avoid truncation effects in permutation
	float4 ix = Pi.xzxz;
	float4 iy = Pi.yyww;
	float4 fx = Pf.xzxz;
	float4 fy = Pf.yyww;
 
	float4 i = perm(perm(ix) + iy);
 
	float4 gx = frac(i * (1.0 / 41.0)) * 2.0 - 1.0;
	float4 gy = abs(gx) - 0.5;
	float4 tx = floor(gx + 0.5);
	gx = gx - tx;
 
	float2 g00 = float2(gx.x, gy.x);
	float2 g10 = float2(gx.y, gy.y);
	float2 g01 = float2(gx.z, gy.z);
	float2 g11 = float2(gx.w, gy.w);
 
	float4 norm = tInvSqrt(float4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
	g00 *= norm.x;
	g01 *= norm.y;
	g10 *= norm.z;
	g11 *= norm.w;
 
	float n00 = dot(g00, float2(fx.x, fy.x));
	float n10 = dot(g10, float2(fx.y, fy.y));
	float n01 = dot(g01, float2(fx.z, fy.z));
	float n11 = dot(g11, float2(fx.w, fy.w));
 
	float2 fade_xy = fade(Pf.xy);
	float2 n_x = lerp(float2(n00, n01), float2(n10, n11), fade_xy.x);
	float n_xy = lerp(n_x.x, n_x.y, fade_xy.y);
	return 2.3 * n_xy;
}
 
// Classic Perlin noise, periodic variant
float perlinPeriodic(float2 P, float2 rep)
{
	float4 Pi = floor(P.xyxy) + float4(0.0, 0.0, 1.0, 1.0);
	float4 Pf = frac(P.xyxy) - float4(0.0, 0.0, 1.0, 1.0);
	Pi = fmod(Pi, rep.xyxy); // To create noise with explicit period
	Pi = mod289(Pi);        // To avoid truncation effects in permutation
	float4 ix = Pi.xzxz;
	float4 iy = Pi.yyww;
	float4 fx = Pf.xzxz;
	float4 fy = Pf.yyww;
 
	float4 i = perm(perm(ix) + iy);
 
	float4 gx = frac(i * (1.0 / 41.0)) * 2.0 - 1.0;
	float4 gy = abs(gx) - 0.5;
	float4 tx = floor(gx + 0.5);
	gx = gx - tx;
 
	float2 g00 = float2(gx.x, gy.x);
	float2 g10 = float2(gx.y, gy.y);
	float2 g01 = float2(gx.z, gy.z);
	float2 g11 = float2(gx.w, gy.w);
 
	float4 norm = tInvSqrt(float4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
	g00 *= norm.x;
	g01 *= norm.y;
	g10 *= norm.z;
	g11 *= norm.w;
 
	float n00 = dot(g00, float2(fx.x, fy.x));
	float n10 = dot(g10, float2(fx.y, fy.y));
	float n01 = dot(g01, float2(fx.z, fy.z));
	float n11 = dot(g11, float2(fx.w, fy.w));
 
	float2 fade_xy = fade(Pf.xy);
	float2 n_x = lerp(float2(n00, n01), float2(n10, n11), fade_xy.x);
	float n_xy = lerp(n_x.x, n_x.y, fade_xy.y);
	return 2.3 * n_xy;
}
 
float perlin3d(float3 P)
{
	float3 Pi0 = floor(P); // Integer part for indexing
	float3 Pi1 = Pi0 + float3(1,1,1); // Integer part + 1
	Pi0 = mod289(Pi0);
	Pi1 = mod289(Pi1);
	float3 Pf0 = frac(P); // Fractional part for interpolation
	float3 Pf1 = Pf0 - float3(1,1,1); // Fractional part - 1.0
	float4 ix = float4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
	float4 iy = float4(Pi0.yy, Pi1.yy);
	float4 iz0 = Pi0.zzzz;
	float4 iz1 = Pi1.zzzz;
 
	float4 ixy = perm(perm(ix) + iy);
	float4 ixy0 = perm(ixy + iz0);
	float4 ixy1 = perm(ixy + iz1);
 
	float4 gx0 = ixy0 * (1.0 / 7.0);
	float4 gy0 = frac(floor(gx0) * (1.0 / 7.0)) - 0.5;
	gx0 = frac(gx0);
	float4 gz0 = float4(0.5, 0.5, 0.5, 0.5) - abs(gx0) - abs(gy0);
	float4 sz0 = step(gz0, float4(0,0,0,0));
	gx0 -= sz0 * (step(0.0, gx0) - 0.5);
	gy0 -= sz0 * (step(0.0, gy0) - 0.5);
 
	float4 gx1 = ixy1 * (1.0 / 7.0);
	float4 gy1 = frac(floor(gx1) * (1.0 / 7.0)) - 0.5;
	gx1 = frac(gx1);
	float4 gz1 = float4(0.5, 0.5, 0.5, 0.5) - abs(gx1) - abs(gy1);
	float4 sz1 = step(gz1, float4(0,0,0,0));
	gx1 -= sz1 * (step(0.0, gx1) - 0.5);
	gy1 -= sz1 * (step(0.0, gy1) - 0.5);
 
	float3 g000 = float3(gx0.x, gy0.x, gz0.x);
	float3 g100 = float3(gx0.y, gy0.y, gz0.y);
	float3 g010 = float3(gx0.z, gy0.z, gz0.z);
	float3 g110 = float3(gx0.w, gy0.w, gz0.w);
	float3 g001 = float3(gx1.x, gy1.x, gz1.x);
	float3 g101 = float3(gx1.y, gy1.y, gz1.y);
	float3 g011 = float3(gx1.z, gy1.z, gz1.z);
	float3 g111 = float3(gx1.w, gy1.w, gz1.w);
 
	float4 norm0 = tInvSqrt(float4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
	g000 *= norm0.x;
	g010 *= norm0.y;
	g100 *= norm0.z;
	g110 *= norm0.w;
	float4 norm1 = tInvSqrt(float4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
	g001 *= norm1.x;
	g011 *= norm1.y;
	g101 *= norm1.z;
	g111 *= norm1.w;
 
	float n000 = dot(g000, Pf0);
	float n100 = dot(g100, float3(Pf1.x, Pf0.yz));
	float n010 = dot(g010, float3(Pf0.x, Pf1.y, Pf0.z));
	float n110 = dot(g110, float3(Pf1.xy, Pf0.z));
	float n001 = dot(g001, float3(Pf0.xy, Pf1.z));
	float n101 = dot(g101, float3(Pf1.x, Pf0.y, Pf1.z));
	float n011 = dot(g011, float3(Pf0.x, Pf1.yz));
	float n111 = dot(g111, Pf1);
 
	float3 fade_xyz = fade(Pf0);
	float4 n_z = lerp(float4(n000, n100, n010, n110), float4(n001, n101, n011, n111), fade_xyz.z);
	float2 n_yz = lerp(n_z.xy, n_z.zw, fade_xyz.y);
	float n_xyz = lerp(n_yz.x, n_yz.y, fade_xyz.x);
	return 2.2 * n_xyz;
}
 
// Classic Perlin noise, periodic variant
float perlin3dPeriodic(float3 P, float3 rep)
{
	float3 Pi0 = fmod(floor(P), rep); // Integer part, modulo period
	float3 Pi1 = fmod(Pi0 + float3(1,1,1), rep); // Integer part + 1, mod period
	Pi0 = mod289(Pi0);
	Pi1 = mod289(Pi1);
	float3 Pf0 = frac(P); // Fractional part for interpolation
	float3 Pf1 = Pf0 - float3(1,1,1); // Fractional part - 1.0
	float4 ix = float4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
	float4 iy = float4(Pi0.yy, Pi1.yy);
	float4 iz0 = Pi0.zzzz;
	float4 iz1 = Pi1.zzzz;
 
	float4 ixy = perm(perm(ix) + iy);
	float4 ixy0 = perm(ixy + iz0);
	float4 ixy1 = perm(ixy + iz1);
 
	float4 gx0 = ixy0 * (1.0 / 7.0);
	float4 gy0 = frac(floor(gx0) * (1.0 / 7.0)) - 0.5;
	gx0 = frac(gx0);
	float4 gz0 = float4(0.5, 0.5, 0.5, 0.5) - abs(gx0) - abs(gy0);
	float4 sz0 = step(gz0, float4(0,0,0,0));
	gx0 -= sz0 * (step(0.0, gx0) - 0.5);
	gy0 -= sz0 * (step(0.0, gy0) - 0.5);
 
	float4 gx1 = ixy1 * (1.0 / 7.0);
	float4 gy1 = frac(floor(gx1) * (1.0 / 7.0)) - 0.5;
	gx1 = frac(gx1);
	float4 gz1 = float4(0.5, 0.5, 0.5, 0.5) - abs(gx1) - abs(gy1);
	float4 sz1 = step(gz1, float4(0,0,0,0));
	gx1 -= sz1 * (step(0.0, gx1) - 0.5);
	gy1 -= sz1 * (step(0.0, gy1) - 0.5);
 
	float3 g000 = float3(gx0.x, gy0.x, gz0.x);
	float3 g100 = float3(gx0.y, gy0.y, gz0.y);
	float3 g010 = float3(gx0.z, gy0.z, gz0.z);
	float3 g110 = float3(gx0.w, gy0.w, gz0.w);
	float3 g001 = float3(gx1.x, gy1.x, gz1.x);
	float3 g101 = float3(gx1.y, gy1.y, gz1.y);
	float3 g011 = float3(gx1.z, gy1.z, gz1.z);
	float3 g111 = float3(gx1.w, gy1.w, gz1.w);
 
	float4 norm0 = tInvSqrt(float4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
	g000 *= norm0.x;
	g010 *= norm0.y;
	g100 *= norm0.z;
	g110 *= norm0.w;
	float4 norm1 = tInvSqrt(float4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
	g001 *= norm1.x;
	g011 *= norm1.y;
	g101 *= norm1.z;
	g111 *= norm1.w;
 
	float n000 = dot(g000, Pf0);
	float n100 = dot(g100, float3(Pf1.x, Pf0.yz));
	float n010 = dot(g010, float3(Pf0.x, Pf1.y, Pf0.z));
	float n110 = dot(g110, float3(Pf1.xy, Pf0.z));
	float n001 = dot(g001, float3(Pf0.xy, Pf1.z));
	float n101 = dot(g101, float3(Pf1.x, Pf0.y, Pf1.z));
	float n011 = dot(g011, float3(Pf0.x, Pf1.yz));
	float n111 = dot(g111, Pf1);
 
	float3 fade_xyz = fade(Pf0);
	float4 n_z = lerp(float4(n000, n100, n010, n110), float4(n001, n101, n011, n111), fade_xyz.z);
	float2 n_yz = lerp(n_z.xy, n_z.zw, fade_xyz.y);
	float n_xyz = lerp(n_yz.x, n_yz.y, fade_xyz.x);
	return 2.2 * n_xyz;
}
 
//
// GLSL textureless classic 4D noise "cnoise",
// with an RSL-style periodic variant "pnoise".
// Author:  Stefan Gustavson (stefan.gustavson@liu.se)
// Version: 2011-08-22
//
// Many thanks to Ian McEwan of Ashima Arts for the
// ideas for permutation and gradient selection.
//
// Copyright (c) 2011 Stefan Gustavson. All rights reserved.
// Distributed under the MIT license. See LICENSE file.
// https://github.com/stegu/webgl-noise
//
 
// Classic Perlin noise
float perlin4d(float4 P)
{
	float4 Pi0 = floor(P); // Integer part for indexing
	float4 Pi1 = Pi0 + 1.0; // Integer part + 1
	Pi0 = mod289(Pi0);
	Pi1 = mod289(Pi1);
	float4 Pf0 = frac(P); // Fractional part for interpolation
	float4 Pf1 = Pf0 - 1.0; // Fractional part - 1.0
	float4 ix = float4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
	float4 iy = float4(Pi0.yy, Pi1.yy);
	float4 iz0 = float4(Pi0.zzzz);
	float4 iz1 = float4(Pi1.zzzz);
	float4 iw0 = float4(Pi0.wwww);
	float4 iw1 = float4(Pi1.wwww);
 
	float4 ixy = perm(perm(ix) + iy);
	float4 ixy0 = perm(ixy + iz0);
	float4 ixy1 = perm(ixy + iz1);
	float4 ixy00 = perm(ixy0 + iw0);
	float4 ixy01 = perm(ixy0 + iw1);
	float4 ixy10 = perm(ixy1 + iw0);
	float4 ixy11 = perm(ixy1 + iw1);
 
	float4 gx00 = ixy00 * (1.0 / 7.0);
	float4 gy00 = floor(gx00) * (1.0 / 7.0);
	float4 gz00 = floor(gy00) * (1.0 / 6.0);
	gx00 = frac(gx00) - 0.5;
	gy00 = frac(gy00) - 0.5;
	gz00 = frac(gz00) - 0.5;
	float4 gw00 = float4(0.75, 0.75, 0.75, 0.75) - abs(gx00) - abs(gy00) - abs(gz00);
	float4 sw00 = step(gw00, float4(0, 0, 0, 0));
	gx00 -= sw00 * (step(0.0, gx00) - 0.5);
	gy00 -= sw00 * (step(0.0, gy00) - 0.5);
 
	float4 gx01 = ixy01 * (1.0 / 7.0);
	float4 gy01 = floor(gx01) * (1.0 / 7.0);
	float4 gz01 = floor(gy01) * (1.0 / 6.0);
	gx01 = frac(gx01) - 0.5;
	gy01 = frac(gy01) - 0.5;
	gz01 = frac(gz01) - 0.5;
	float4 gw01 = float4(0.75, 0.75, 0.75, 0.75) - abs(gx01) - abs(gy01) - abs(gz01);
	float4 sw01 = step(gw01, float4(0, 0, 0, 0));
	gx01 -= sw01 * (step(0.0, gx01) - 0.5);
	gy01 -= sw01 * (step(0.0, gy01) - 0.5);
 
	float4 gx10 = ixy10 * (1.0 / 7.0);
	float4 gy10 = floor(gx10) * (1.0 / 7.0);
	float4 gz10 = floor(gy10) * (1.0 / 6.0);
	gx10 = frac(gx10) - 0.5;
	gy10 = frac(gy10) - 0.5;
	gz10 = frac(gz10) - 0.5;
	float4 gw10 = float4(0.75, 0.75, 0.75, 0.75) - abs(gx10) - abs(gy10) - abs(gz10);
	float4 sw10 = step(gw10, float4(0, 0, 0, 0));
	gx10 -= sw10 * (step(0.0, gx10) - 0.5);
	gy10 -= sw10 * (step(0.0, gy10) - 0.5);
 
	float4 gx11 = ixy11 * (1.0 / 7.0);
	float4 gy11 = floor(gx11) * (1.0 / 7.0);
	float4 gz11 = floor(gy11) * (1.0 / 6.0);
	gx11 = frac(gx11) - 0.5;
	gy11 = frac(gy11) - 0.5;
	gz11 = frac(gz11) - 0.5;
	float4 gw11 = float4(0.75, 0.75, 0.75, 0.75) - abs(gx11) - abs(gy11) - abs(gz11);
	float4 sw11 = step(gw11, float4(0, 0, 0, 0));
	gx11 -= sw11 * (step(0.0, gx11) - 0.5);
	gy11 -= sw11 * (step(0.0, gy11) - 0.5);
 
	float4 g0000 = float4(gx00.x, gy00.x, gz00.x, gw00.x);
	float4 g1000 = float4(gx00.y, gy00.y, gz00.y, gw00.y);
	float4 g0100 = float4(gx00.z, gy00.z, gz00.z, gw00.z);
	float4 g1100 = float4(gx00.w, gy00.w, gz00.w, gw00.w);
	float4 g0010 = float4(gx10.x, gy10.x, gz10.x, gw10.x);
	float4 g1010 = float4(gx10.y, gy10.y, gz10.y, gw10.y);
	float4 g0110 = float4(gx10.z, gy10.z, gz10.z, gw10.z);
	float4 g1110 = float4(gx10.w, gy10.w, gz10.w, gw10.w);
	float4 g0001 = float4(gx01.x, gy01.x, gz01.x, gw01.x);
	float4 g1001 = float4(gx01.y, gy01.y, gz01.y, gw01.y);
	float4 g0101 = float4(gx01.z, gy01.z, gz01.z, gw01.z);
	float4 g1101 = float4(gx01.w, gy01.w, gz01.w, gw01.w);
	float4 g0011 = float4(gx11.x, gy11.x, gz11.x, gw11.x);
	float4 g1011 = float4(gx11.y, gy11.y, gz11.y, gw11.y);
	float4 g0111 = float4(gx11.z, gy11.z, gz11.z, gw11.z);
	float4 g1111 = float4(gx11.w, gy11.w, gz11.w, gw11.w);
 
	float4 norm00 = tInvSqrt(float4(dot(g0000, g0000), dot(g0100, g0100), dot(g1000, g1000), dot(g1100, g1100)));
	g0000 *= norm00.x;
	g0100 *= norm00.y;
	g1000 *= norm00.z;
	g1100 *= norm00.w;
 
	float4 norm01 = tInvSqrt(float4(dot(g0001, g0001), dot(g0101, g0101), dot(g1001, g1001), dot(g1101, g1101)));
	g0001 *= norm01.x;
	g0101 *= norm01.y;
	g1001 *= norm01.z;
	g1101 *= norm01.w;
 
	float4 norm10 = tInvSqrt(float4(dot(g0010, g0010), dot(g0110, g0110), dot(g1010, g1010), dot(g1110, g1110)));
	g0010 *= norm10.x;
	g0110 *= norm10.y;
	g1010 *= norm10.z;
	g1110 *= norm10.w;
 
	float4 norm11 = tInvSqrt(float4(dot(g0011, g0011), dot(g0111, g0111), dot(g1011, g1011), dot(g1111, g1111)));
	g0011 *= norm11.x;
	g0111 *= norm11.y;
	g1011 *= norm11.z;
	g1111 *= norm11.w;
 
	float n0000 = dot(g0000, Pf0);
	float n1000 = dot(g1000, float4(Pf1.x, Pf0.yzw));
	float n0100 = dot(g0100, float4(Pf0.x, Pf1.y, Pf0.zw));
	float n1100 = dot(g1100, float4(Pf1.xy, Pf0.zw));
	float n0010 = dot(g0010, float4(Pf0.xy, Pf1.z, Pf0.w));
	float n1010 = dot(g1010, float4(Pf1.x, Pf0.y, Pf1.z, Pf0.w));
	float n0110 = dot(g0110, float4(Pf0.x, Pf1.yz, Pf0.w));
	float n1110 = dot(g1110, float4(Pf1.xyz, Pf0.w));
	float n0001 = dot(g0001, float4(Pf0.xyz, Pf1.w));
	float n1001 = dot(g1001, float4(Pf1.x, Pf0.yz, Pf1.w));
	float n0101 = dot(g0101, float4(Pf0.x, Pf1.y, Pf0.z, Pf1.w));
	float n1101 = dot(g1101, float4(Pf1.xy, Pf0.z, Pf1.w));
	float n0011 = dot(g0011, float4(Pf0.xy, Pf1.zw));
	float n1011 = dot(g1011, float4(Pf1.x, Pf0.y, Pf1.zw));
	float n0111 = dot(g0111, float4(Pf0.x, Pf1.yzw));
	float n1111 = dot(g1111, Pf1);
 
	float4 fade_xyzw = fade(Pf0);
	float4 n_0w = lerp(float4(n0000, n1000, n0100, n1100), float4(n0001, n1001, n0101, n1101), fade_xyzw.w);
	float4 n_1w = lerp(float4(n0010, n1010, n0110, n1110), float4(n0011, n1011, n0111, n1111), fade_xyzw.w);
	float4 n_zw = lerp(n_0w, n_1w, fade_xyzw.z);
	float2 n_yzw = lerp(n_zw.xy, n_zw.zw, fade_xyzw.y);
	float n_xyzw = lerp(n_yzw.x, n_yzw.y, fade_xyzw.x);
	return 2.2 * n_xyzw;
}
 
// Classic Perlin noise, periodic version
float perlin4dPeriodic(float4 P, float4 rep)
{
	float4 Pi0 = fmod(floor(P), rep); // Integer part modulo rep
	float4 Pi1 = fmod(Pi0 + 1.0, rep); // Integer part + 1 mod rep
	Pi0 = mod289(Pi0);
	Pi1 = mod289(Pi1);
	float4 Pf0 = frac(P); // Fractional part for interpolation
	float4 Pf1 = Pf0 - 1.0; // Fractional part - 1.0
	float4 ix = float4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
	float4 iy = float4(Pi0.yy, Pi1.yy);
	float4 iz0 = float4(Pi0.zzzz);
	float4 iz1 = float4(Pi1.zzzz);
	float4 iw0 = float4(Pi0.wwww);
	float4 iw1 = float4(Pi1.wwww);
 
	float4 ixy = perm(perm(ix) + iy);
	float4 ixy0 = perm(ixy + iz0);
	float4 ixy1 = perm(ixy + iz1);
	float4 ixy00 = perm(ixy0 + iw0);
	float4 ixy01 = perm(ixy0 + iw1);
	float4 ixy10 = perm(ixy1 + iw0);
	float4 ixy11 = perm(ixy1 + iw1);
 
	float4 gx00 = ixy00 * (1.0 / 7.0);
	float4 gy00 = floor(gx00) * (1.0 / 7.0);
	float4 gz00 = floor(gy00) * (1.0 / 6.0);
	gx00 = frac(gx00) - 0.5;
	gy00 = frac(gy00) - 0.5;
	gz00 = frac(gz00) - 0.5;
	float4 gw00 = float4(0.75, 0.75, 0.75, 0.75) - abs(gx00) - abs(gy00) - abs(gz00);
	float4 sw00 = step(gw00, float4(0, 0, 0, 0));
	gx00 -= sw00 * (step(0.0, gx00) - 0.5);
	gy00 -= sw00 * (step(0.0, gy00) - 0.5);
 
	float4 gx01 = ixy01 * (1.0 / 7.0);
	float4 gy01 = floor(gx01) * (1.0 / 7.0);
	float4 gz01 = floor(gy01) * (1.0 / 6.0);
	gx01 = frac(gx01) - 0.5;
	gy01 = frac(gy01) - 0.5;
	gz01 = frac(gz01) - 0.5;
	float4 gw01 = float4(0.75, 0.75, 0.75, 0.75) - abs(gx01) - abs(gy01) - abs(gz01);
	float4 sw01 = step(gw01, float4(0, 0, 0, 0));
	gx01 -= sw01 * (step(0.0, gx01) - 0.5);
	gy01 -= sw01 * (step(0.0, gy01) - 0.5);
 
	float4 gx10 = ixy10 * (1.0 / 7.0);
	float4 gy10 = floor(gx10) * (1.0 / 7.0);
	float4 gz10 = floor(gy10) * (1.0 / 6.0);
	gx10 = frac(gx10) - 0.5;
	gy10 = frac(gy10) - 0.5;
	gz10 = frac(gz10) - 0.5;
	float4 gw10 = float4(0.75, 0.75, 0.75, 0.75) - abs(gx10) - abs(gy10) - abs(gz10);
	float4 sw10 = step(gw10, float4(0, 0, 0, 0));
	gx10 -= sw10 * (step(0.0, gx10) - 0.5);
	gy10 -= sw10 * (step(0.0, gy10) - 0.5);
 
	float4 gx11 = ixy11 * (1.0 / 7.0);
	float4 gy11 = floor(gx11) * (1.0 / 7.0);
	float4 gz11 = floor(gy11) * (1.0 / 6.0);
	gx11 = frac(gx11) - 0.5;
	gy11 = frac(gy11) - 0.5;
	gz11 = frac(gz11) - 0.5;
	float4 gw11 = float4(0.75, 0.75, 0.75, 0.75) - abs(gx11) - abs(gy11) - abs(gz11);
	float4 sw11 = step(gw11, float4(0, 0, 0, 0));
	gx11 -= sw11 * (step(0.0, gx11) - 0.5);
	gy11 -= sw11 * (step(0.0, gy11) - 0.5);
 
	float4 g0000 = float4(gx00.x, gy00.x, gz00.x, gw00.x);
	float4 g1000 = float4(gx00.y, gy00.y, gz00.y, gw00.y);
	float4 g0100 = float4(gx00.z, gy00.z, gz00.z, gw00.z);
	float4 g1100 = float4(gx00.w, gy00.w, gz00.w, gw00.w);
	float4 g0010 = float4(gx10.x, gy10.x, gz10.x, gw10.x);
	float4 g1010 = float4(gx10.y, gy10.y, gz10.y, gw10.y);
	float4 g0110 = float4(gx10.z, gy10.z, gz10.z, gw10.z);
	float4 g1110 = float4(gx10.w, gy10.w, gz10.w, gw10.w);
	float4 g0001 = float4(gx01.x, gy01.x, gz01.x, gw01.x);
	float4 g1001 = float4(gx01.y, gy01.y, gz01.y, gw01.y);
	float4 g0101 = float4(gx01.z, gy01.z, gz01.z, gw01.z);
	float4 g1101 = float4(gx01.w, gy01.w, gz01.w, gw01.w);
	float4 g0011 = float4(gx11.x, gy11.x, gz11.x, gw11.x);
	float4 g1011 = float4(gx11.y, gy11.y, gz11.y, gw11.y);
	float4 g0111 = float4(gx11.z, gy11.z, gz11.z, gw11.z);
	float4 g1111 = float4(gx11.w, gy11.w, gz11.w, gw11.w);
 
	float4 norm00 = tInvSqrt(float4(dot(g0000, g0000), dot(g0100, g0100), dot(g1000, g1000), dot(g1100, g1100)));
	g0000 *= norm00.x;
	g0100 *= norm00.y;
	g1000 *= norm00.z;
	g1100 *= norm00.w;
 
	float4 norm01 = tInvSqrt(float4(dot(g0001, g0001), dot(g0101, g0101), dot(g1001, g1001), dot(g1101, g1101)));
	g0001 *= norm01.x;
	g0101 *= norm01.y;
	g1001 *= norm01.z;
	g1101 *= norm01.w;
 
	float4 norm10 = tInvSqrt(float4(dot(g0010, g0010), dot(g0110, g0110), dot(g1010, g1010), dot(g1110, g1110)));
	g0010 *= norm10.x;
	g0110 *= norm10.y;
	g1010 *= norm10.z;
	g1110 *= norm10.w;
 
	float4 norm11 = tInvSqrt(float4(dot(g0011, g0011), dot(g0111, g0111), dot(g1011, g1011), dot(g1111, g1111)));
	g0011 *= norm11.x;
	g0111 *= norm11.y;
	g1011 *= norm11.z;
	g1111 *= norm11.w;
 
	float n0000 = dot(g0000, Pf0);
	float n1000 = dot(g1000, float4(Pf1.x, Pf0.yzw));
	float n0100 = dot(g0100, float4(Pf0.x, Pf1.y, Pf0.zw));
	float n1100 = dot(g1100, float4(Pf1.xy, Pf0.zw));
	float n0010 = dot(g0010, float4(Pf0.xy, Pf1.z, Pf0.w));
	float n1010 = dot(g1010, float4(Pf1.x, Pf0.y, Pf1.z, Pf0.w));
	float n0110 = dot(g0110, float4(Pf0.x, Pf1.yz, Pf0.w));
	float n1110 = dot(g1110, float4(Pf1.xyz, Pf0.w));
	float n0001 = dot(g0001, float4(Pf0.xyz, Pf1.w));
	float n1001 = dot(g1001, float4(Pf1.x, Pf0.yz, Pf1.w));
	float n0101 = dot(g0101, float4(Pf0.x, Pf1.y, Pf0.z, Pf1.w));
	float n1101 = dot(g1101, float4(Pf1.xy, Pf0.z, Pf1.w));
	float n0011 = dot(g0011, float4(Pf0.xy, Pf1.zw));
	float n1011 = dot(g1011, float4(Pf1.x, Pf0.y, Pf1.zw));
	float n0111 = dot(g0111, float4(Pf0.x, Pf1.yzw));
	float n1111 = dot(g1111, Pf1);
 
	float4 fade_xyzw = fade(Pf0);
	float4 n_0w = lerp(float4(n0000, n1000, n0100, n1100), float4(n0001, n1001, n0101, n1101), fade_xyzw.w);
	float4 n_1w = lerp(float4(n0010, n1010, n0110, n1110), float4(n0011, n1011, n0111, n1111), fade_xyzw.w);
	float4 n_zw = lerp(n_0w, n_1w, fade_xyzw.z);
	float2 n_yzw = lerp(n_zw.xy, n_zw.zw, fade_xyzw.y);
	float n_xyzw = lerp(n_yzw.x, n_yzw.y, fade_xyzw.x);
	return 2.2 * n_xyzw;
}
 
//
// Description : Array and textureless GLSL 2D simplex noise function.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : stegu
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//               https://github.com/stegu/webgl-noise
//
 
float simplex(float2 v)
{
	const float4 C = float4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
		0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
		-0.577350269189626,  // -1.0 + 2.0 * C.x
		0.024390243902439); // 1.0 / 41.0
							// First corner
	float2 i = floor(v + dot(v, C.yy));
	float2 x0 = v - i + dot(i, C.xx);
 
	// Other corners
	float2 i1;
	//i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
	//i1.y = 1.0 - i1.x;
	i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
	// x0 = x0 - 0.0 + 0.0 * C.xx ;
	// x1 = x0 - i1 + 1.0 * C.xx ;
	// x2 = x0 - 1.0 + 2.0 * C.xx ;
	float4 x12 = x0.xyxy + C.xxzz;
	x12.xy -= i1;
 
	// Permutations
	i = mod289(i); // Avoid truncation effects in permutation
	float3 p = perm(perm(i.y + float3(0.0, i1.y, 1.0))
		+ i.x + float3(0.0, i1.x, 1.0));
 
	float3 m = max(0.5 - float3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
	m = m*m;
	m = m*m;
 
	// Gradients: 41 points uniformly over a line, mapped onto a diamond.
	// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)
 
	float3 x = 2.0 * frac(p * C.www) - 1.0;
	float3 h = abs(x) - 0.5;
	float3 ox = floor(x + 0.5);
	float3 a0 = x - ox;
 
	// Normalise gradients implicitly by scaling m
	// Approximation of: m *= inversesqrt( a0*a0 + h*h );
	m *= 1.79284291400159 - 0.85373472095314 * (a0*a0 + h*h);
 
	// Compute final noise value at P
	float3 g;
	g.x = a0.x  * x0.x + h.x  * x0.y;
	g.yz = a0.yz * x12.xz + h.yz * x12.yw;
	return 130.0 * dot(m, g);
}
 
 
 
float simplex3dGradient(float3 v, out float3 gradient)
{
	const float2  C = float2(1.0 / 6.0, 1.0 / 3.0);
	const float4  D = float4(0.0, 0.5, 1.0, 2.0);
 
	// First corner
	float3 i = floor(v + dot(v, C.yyy));
	float3 x0 = v - i + dot(i, C.xxx);
 
	// Other corners
	float3 g = step(x0.yzx, x0.xyz);
	float3 l = 1.0 - g;
	float3 i1 = min(g.xyz, l.zxy);
	float3 i2 = max(g.xyz, l.zxy);
 
	//   x0 = x0 - 0.0 + 0.0 * C.xxx;
	//   x1 = x0 - i1  + 1.0 * C.xxx;
	//   x2 = x0 - i2  + 2.0 * C.xxx;
	//   x3 = x0 - 1.0 + 3.0 * C.xxx;
	float3 x1 = x0 - i1 + C.xxx;
	float3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
	float3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y
 
								// Permutations
	i = mod289(i);
	float4 p = perm(perm(perm(
		i.z + float4(0.0, i1.z, i2.z, 1.0))
		+ i.y + float4(0.0, i1.y, i2.y, 1.0))
		+ i.x + float4(0.0, i1.x, i2.x, 1.0));
 
	// Gradients: 7x7 points over a square, mapped onto an octahedron.
	// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
	float n_ = 0.142857142857; // 1.0/7.0
	float3  ns = n_ * D.wyz - D.xzx;
 
	float4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)
 
	float4 x_ = floor(j * ns.z);
	float4 y_ = floor(j - 7.0 * x_);    // mod(j,N)
 
	float4 x = x_ *ns.x + ns.yyyy;
	float4 y = y_ *ns.x + ns.yyyy;
	float4 h = 1.0 - abs(x) - abs(y);
 
	float4 b0 = float4(x.xy, y.xy);
	float4 b1 = float4(x.zw, y.zw);
 
	//float4 s0 = float4(lessThan(b0,0.0))*2.0 - 1.0;
	//float4 s1 = float4(lessThan(b1,0.0))*2.0 - 1.0;
	float4 s0 = floor(b0)*2.0 + 1.0;
	float4 s1 = floor(b1)*2.0 + 1.0;
	float4 sh = -step(h, float4(0,0,0,0));
 
	float4 a0 = b0.xzyw + s0.xzyw*sh.xxyy;
	float4 a1 = b1.xzyw + s1.xzyw*sh.zzww;
 
	float3 p0 = float3(a0.xy, h.x);
	float3 p1 = float3(a0.zw, h.y);
	float3 p2 = float3(a1.xy, h.z);
	float3 p3 = float3(a1.zw, h.w);
 
	//Normalise gradients
	float4 norm = tInvSqrt(float4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
	p0 *= norm.x;
	p1 *= norm.y;
	p2 *= norm.z;
	p3 *= norm.w;
 
	// Mix final noise value
	float4 m = max(0.6 - float4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
	float4 m2 = m * m;
	float4 m4 = m2 * m2;
	float4 pdotx = float4(dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3));
 
	// Determine noise gradient
	float4 temp = m2 * m * pdotx;
	gradient = -8.0 * (temp.x * x0 + temp.y * x1 + temp.z * x2 + temp.w * x3);
	gradient += m4.x * p0 + m4.y * p1 + m4.z * p2 + m4.w * p3;
	gradient *= 42.0;
 
	return 42.0 * dot(m4, pdotx);
}
 
 
// (sqrt(5) - 1)/4 = F4, used once below
#define F4 0.309016994374947451
 
float simplex4dGradient(float4 v)
{
	const float4  C = float4(0.138196601125011,  // (5 - sqrt(5))/20  G4
		0.276393202250021,  // 2 * G4
		0.414589803375032,  // 3 * G4
		-0.447213595499958); // -1 + 4 * G4
 
								// First corner
	float4 i = floor(v + dot(v, float4(F4, F4, F4, F4)));
	float4 x0 = v - i + dot(i, C.xxxx);
 
	// Other corners
 
	// Rank sorting originally contributed by Bill Licea-Kane, AMD (formerly ATI)
	float4 i0;
	float3 isX = step(x0.yzw, x0.xxx);
	float3 isYZ = step(x0.zww, x0.yyz);
	//  i0.x = dot( isX, float3( 1.0 ) );
	i0.x = isX.x + isX.y + isX.z;
	i0.yzw = 1.0 - isX;
	//  i0.y += dot( isYZ.xy, float2( 1.0 ) );
	i0.y += isYZ.x + isYZ.y;
	i0.zw += 1.0 - isYZ.xy;
	i0.z += isYZ.z;
	i0.w += 1.0 - isYZ.z;
 
	// i0 now contains the unique values 0,1,2,3 in each channel
	float4 i3 = clamp(i0, 0.0, 1.0);
	float4 i2 = clamp(i0 - 1.0, 0.0, 1.0);
	float4 i1 = clamp(i0 - 2.0, 0.0, 1.0);
 
	//  x0 = x0 - 0.0 + 0.0 * C.xxxx
	//  x1 = x0 - i1  + 1.0 * C.xxxx
	//  x2 = x0 - i2  + 2.0 * C.xxxx
	//  x3 = x0 - i3  + 3.0 * C.xxxx
	//  x4 = x0 - 1.0 + 4.0 * C.xxxx
	float4 x1 = x0 - i1 + C.xxxx;
	float4 x2 = x0 - i2 + C.yyyy;
	float4 x3 = x0 - i3 + C.zzzz;
	float4 x4 = x0 + C.wwww;
 
	// Permutations
	i = mod289(i);
	float j0 = perm(perm(perm(perm(i.w) + i.z) + i.y) + i.x);
	float4 j1 = perm(perm(perm(perm(
		i.w + float4(i1.w, i2.w, i3.w, 1.0))
		+ i.z + float4(i1.z, i2.z, i3.z, 1.0))
		+ i.y + float4(i1.y, i2.y, i3.y, 1.0))
		+ i.x + float4(i1.x, i2.x, i3.x, 1.0));
 
	// Gradients: 7x7x6 points over a cube, mapped onto a 4-cross polytope
	// 7*7*6 = 294, which is close to the ring size 17*17 = 289.
	float4 ip = float4(1.0 / 294.0, 1.0 / 49.0, 1.0 / 7.0, 0.0);
 
	float4 p0 = grad4(j0, ip);
	float4 p1 = grad4(j1.x, ip);
	float4 p2 = grad4(j1.y, ip);
	float4 p3 = grad4(j1.z, ip);
	float4 p4 = grad4(j1.w, ip);
 
	// Normalise gradients
	float4 norm = tInvSqrt(float4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
	p0 *= norm.x;
	p1 *= norm.y;
	p2 *= norm.z;
	p3 *= norm.w;
	p4 *= tInvSqrt(dot(p4, p4));
 
	// Mix contributions from the five corners
	float3 m0 = max(0.6 - float3(dot(x0, x0), dot(x1, x1), dot(x2, x2)), 0.0);
	float2 m1 = max(0.6 - float2(dot(x3, x3), dot(x4, x4)), 0.0);
	m0 = m0 * m0;
	m1 = m1 * m1;
	return 49.0 * (dot(m0*m0, float3(dot(p0, x0), dot(p1, x1), dot(p2, x2)))
		+ dot(m1*m1, float2(dot(p3, x3), dot(p4, x4))));
 
}

#endif // PSEUDO_NOISE