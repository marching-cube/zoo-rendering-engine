//
//  Phong.fsh
//  OpenGLDemo
//
//  Created by Lukasz Sowinski (niman.gosen.en@gmail.com) on 5/14/12.
//  Copyright (c) 2012 Lukasz Sowinski. All rights reserved.
//

const highp vec4 unpackFactors = vec4(1.0/256.0/256.0/256.0, 1.0/256.0/256.0, 1.0/256.0, 1.0);
const highp vec4 gammaFactors  = vec4(1.0/2.2, 1.0/2.2, 1.0/2.2, 1.0);

#ifdef PERFRAGMENT
uniform highp vec4  ambientColorAdjusted;
uniform highp vec4  diffuseColorAdjusted;
uniform highp vec4  specularColorAdjusted;
uniform highp float specularExponent;
uniform highp mat3  normalMatrix;
uniform highp vec3  lightPositionCamera;
uniform lowp  vec3  lightColor;
#ifdef FRESNEL
uniform highp float fresnelF0;
uniform highp float fresnelPOW;
#endif
#endif

#ifdef UV
uniform sampler2D tex0;
#endif
#ifdef SHADOW
uniform sampler2D tex1;
#endif
#ifdef BUMPS
uniform sampler2D tex2;
#endif

#ifdef PERFRAGMENT
varying highp vec3 v_normal;
#else
varying highp vec4 v_color;
#endif
#ifdef UV
varying highp vec2 v_uv;
#ifdef BUMPS
#ifdef PERFRAGMENT
varying highp vec3 v_tangent;
varying highp vec3 v_binormal;
#endif
#endif
#endif
#ifdef SHADOW
varying highp vec4 v_lposition;
#endif


void main()
{
    highp float  intensity = 1.0;

#ifdef PERFRAGMENT
    highp vec3 eyeNormal = normalize(normalMatrix * v_normal);
#ifdef BUMPS
    highp vec3 eyeTangent = normalize(normalMatrix * v_tangent);
    highp vec3 eyeBinormal = normalize(normalMatrix * v_binormal);
    highp vec4 bump  = 2.0*(texture2D(tex2, v_uv)-0.5);
    eyeNormal = normalize(eyeNormal/4.0 - bump.x*eyeTangent + bump.y*eyeBinormal);
#endif
    
#if defined HEMISPHERE && !defined PERFRAGMENT
    highp float nDotLN = clamp( 0.5+0.5*dot(eyeNormal, lightPositionCamera), 0.0, 1.0);
#else
    highp float nDotLN = clamp( dot(eyeNormal, lightPositionCamera), 0.0, 1.0);
#endif
    highp float nDotRV = clamp( dot(normalize(reflect(-lightPositionCamera, eyeNormal)), vec3(0.0, 0.0, 1.0)), 0.0, 1.0);

#ifdef FRESNEL
    highp float nDotHN = dot( eyeNormal, normalize(vec3(0.0, 0.0, 1.0)+lightPositionCamera));
    highp float base = 1.0 - dot( vec3(0.0, 0.0, 1.0), normalize(vec3(0.0, 0.0, 1.0)+lightPositionCamera) );  
    highp float exponential = pow( base, fresnelPOW*10.0 );  
    highp float ffactor = exponential + fresnelF0 * ( 1.0 - exponential );  

    highp vec4   color = (ambientColorAdjusted + (diffuseColorAdjusted*nDotLN + specularColorAdjusted*pow(nDotHN, specularExponent)*ffactor)*vec4(lightColor, 1.0));
#else
    highp vec4   color = (ambientColorAdjusted + (diffuseColorAdjusted*nDotLN + specularColorAdjusted*pow(nDotRV, specularExponent))*vec4(lightColor, 1.0));
#endif
#else
	highp vec4   color     = v_color;
#endif

#ifdef SHADOW
	highp vec2   lposition = v_lposition.xy/v_lposition.w;
    highp float  ldepth    = -v_lposition.z/v_lposition.w;
    
    highp vec2   s_uv      = clamp((1.0+lposition)/2.0, 0.0, 1.0);
    highp float  sdepth    = dot(texture2D(tex1, s_uv), unpackFactors);
    
    intensity  *=  (sdepth > ldepth ? 1.0 : 0.3) ;
#endif
    
    color = pow(color, gammaFactors) ;

#ifdef UV
	color      *= texture2D(tex0, v_uv);
#endif

#ifdef WGLOW
#ifdef PERFRAGMENT
// TODO: optimize, copy to
//    highp float glow   = pow (1.0 - clamp( dot(normalize(eyeNormal+lightPositionCamera), vec3(0.0, 0.0, 1.0)), 0.0, 1.0), 2.0);
    
// ATTEMPT 1
    highp float glow   = pow (1.0 - clamp( -.7+dot(normalize(eyeNormal+vec3(0.0, 0.0, 1.0)), vec3(0.0, 0.0, 1.0)), 0.0, 1.0), 8.0);
    color = mix(color, vec4(1.0, 1.0, 1.0, 1.0), glow);

// ATTEMPT 2
//    highp float glow   = pow ( clamp( 1.0-dot(eyeNormal, vec3(0.0, 0.0, 1.0)), 0.0, 1.0), 2.0);
//    color = (color + vec4(0.1, 0.1, 0.1, 0.0))* (1.0+glow);


#endif
#endif

#ifdef BGLOW
#ifdef PERFRAGMENT
//    highp float glow   = pow (1.0 - clamp( dot(normalize(eyeNormal+lightPositionCamera), vec3(0.0, 0.0, 1.0)), 0.0, 1.0), 2.0);
//    color = mix(color, vec4(0.0, 0.0, 0.0, 0.0), glow);

// TODO: optimize, copy to 
//    highp float glow   = pow (1.0 - clamp( -0.1+dot(normalize(eyeNormal+vec3(0.0, 0.0, 1.0)), vec3(0.0, 0.0, 1.0)), 0.0, 1.0), 2.0);
    highp float glow   = pow (1.0 - clamp( +.1+dot(eyeNormal, vec3(0.0, 0.0, 1.0)), 0.0, 1.0), 3.0);
    intensity *= step(glow, 0.1);
// TODO: more ambient

#endif
#endif

#ifdef QUANTIFY8
	gl_FragColor = clamp((ceil((color*intensity)*8.0))/8.0, 0.0, 1.0);
#else
#ifdef QUANTIFY4
    gl_FragColor = clamp((ceil((color*intensity)*4.0))/4.0, 0.0, 1.0);
#else
	gl_FragColor = vec4(clamp(color.rgb*intensity, 0.0, 1.0), color.a);
#endif
#endif
    
#ifdef ALPHADISCARD
    if (gl_FragColor.a == 0.0) discard;
#endif

}
