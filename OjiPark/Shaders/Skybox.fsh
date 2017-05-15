//
//  Skybox.fsh
//  OpenGLDemo
//
//  Created by Lukasz Sowinski (niman.gosen.en@gmail.com) on 5/14/12.
//  Copyright (c) 2012 Lukasz Sowinski. All rights reserved.
//

uniform samplerCube tex0;
varying mediump vec3 uv;

void main() {
    gl_FragColor = textureCube(tex0, uv);
//    gl_FragColor = vec4(uv, 1.0);
}