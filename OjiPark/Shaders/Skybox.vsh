//
//  Skybox.vsh
//  OpenGLDemo
//
//  Created by Lukasz Sowinski (niman.gosen.en@gmail.com) on 5/14/12.
//  Copyright (c) 2012 Lukasz Sowinski. All rights reserved.
//

attribute vec3 a_position;
attribute vec3 a_uv;

uniform mat4 modelViewProjectionMatrix;
varying mediump vec3 uv;

void main()
{
	uv = a_uv;
    gl_Position = modelViewProjectionMatrix * vec4(a_position.x*20.0,a_position.y*20.0+0.5,a_position.z*20.0, 1.0);
}
