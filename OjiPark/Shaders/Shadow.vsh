//
//  Shadow.vsh
//  OpenGLDemo
//
//  Created by Lukasz Sowinski (niman.gosen.en@gmail.com) on 5/14/12.
//  Copyright (c) 2012 Lukasz Sowinski. All rights reserved.
//

attribute vec3 a_position;

uniform mat4 modelViewProjectionMatrix;
uniform vec4 offset;

void main()
{
    gl_Position = modelViewProjectionMatrix * (vec4(a_position, 1.0) + offset);
}
