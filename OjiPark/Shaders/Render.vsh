//
//  Phong.vsh
//  OpenGLDemo
//
//  Created by Lukasz Sowinski (niman.gosen.en@gmail.com) on 5/14/12.
//  Copyright (c) 2012 Lukasz Sowinski. All rights reserved.
//

attribute vec3 a_position;
attribute vec3 a_normal;
#ifdef UV
attribute vec2 a_uv;
#ifdef BUMPS
attribute vec3 a_tangent;
attribute vec3 a_binormal;
#endif
#endif

uniform mat4 modelViewProjectionMatrix;
#ifdef SHADOW
uniform mat4 modelViewProjectionMatrixLightSource;
#endif
uniform vec4 offset;
#ifndef PERFRAGMENT
uniform mat3 normalMatrix;
uniform vec3 lightPositionCamera;
uniform vec3 lightColor;
uniform vec4 diffuseColorAdjusted;
#ifdef PHONG
uniform vec4  ambientColorAdjusted;
uniform vec4  specularColorAdjusted;
uniform float specularExponent;
#ifdef FRESNEL
uniform float fresnelF0;
uniform float fresnelPOW;
#endif
#endif
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

#ifdef PERFRAGMENT
    v_normal  = a_normal;
#ifdef BUMPS
    v_tangent = a_tangent;
    v_binormal  = a_binormal;
#endif
#else
    vec3 eyeNormal = normalize(normalMatrix * a_normal);
    
#if defined HEMISPHERE && !defined PERFRAGMENT
    float nDotLN = clamp( 0.5+0.5*dot(eyeNormal, lightPositionCamera), 0.0, 1.0);
#else
    float nDotLN = clamp( dot(eyeNormal, lightPositionCamera), 0.0, 1.0);
#endif
    float nDotRV = clamp( dot(normalize(reflect(-lightPositionCamera, eyeNormal)), vec3(0.0, 0.0, 1.0)), 0.0, 1.0);

#ifdef PHONG
#ifdef FRESNEL
    float nDotHN = dot( eyeNormal, normalize(vec3(0.0, 0.0, 1.0)+lightPositionCamera));
    float base = 1.0 - dot( vec3(0.0, 0.0, 1.0), normalize(vec3(0.0, 0.0, 1.0)+lightPositionCamera) );  
    float exponential = pow( base, fresnelPOW*10.0  );  
    float ffactor = exponential + fresnelF0 * ( 1.0 - exponential );
    
    v_color = clamp( ambientColorAdjusted +
                     (diffuseColorAdjusted * nDotLN +
                     specularColorAdjusted* pow(nDotHN, specularExponent)*ffactor)*vec4(lightColor, 1.0),
                    0.0, 1.0);
#else
    v_color = clamp( ambientColorAdjusted +
                     (diffuseColorAdjusted * nDotLN +
                     specularColorAdjusted* pow(nDotRV, specularExponent))*vec4(lightColor, 1.0),
                    0.0, 1.0);
#endif
#else
    v_color = vec4(diffuseColorAdjusted.rgb * nDotLN *lightColor, 1.0);
#endif 
#endif

#ifdef WGLOW
#ifndef PERFRAGMENT
//    highp float glow   = pow (1.0 - clamp( dot(normalize(eyeNormal+lightPositionCamera), vec3(0.0, 0.0, 1.0)), 0.0, 1.0), 2.0);
//    v_color = mix(v_color, vec4(1.0, 1.0, 1.0, 1.0), glow);

// ATTEMPT 1
    highp float glow   = pow (1.0 - clamp( -.7+dot(normalize(eyeNormal+vec3(0.0, 0.0, 1.0)), vec3(0.0, 0.0, 1.0)), 0.0, 1.0), 8.0);
    v_color = mix(v_color, vec4(1.0, 1.0, 1.0, 1.0), glow);

#endif
#endif

#ifdef BGLOW
#ifndef PERFRAGMENT
//    highp float glow   = pow (1.0 - clamp( dot(normalize(eyeNormal+lightPositionCamera), vec3(0.0, 0.0, 1.0)), 0.0, 1.0), 2.0);
//    v_color = mix(v_color, vec4(0.0, 0.0, 0.0, 0.0), glow);
    
// ATTEMPT 1    
    float glow   = pow (1.0 - clamp( +.1+dot(eyeNormal, vec3(0.0, 0.0, 1.0)), 0.0, 1.0), 3.0);
    v_color *= step(glow, 0.1);

#endif
#endif
    
	gl_Position = modelViewProjectionMatrix * (vec4(a_position, 1.0) + offset);

#ifdef UV
	v_uv      = a_uv;
#endif    
#ifdef SHADOW
    v_lposition = modelViewProjectionMatrixLightSource * (vec4(a_position, 1.0) + offset);
#endif 
}
