//
//  Shadow.fsh
//  OpenGLDemo
//
//  Created by Lukasz Sowinski (niman.gosen.en@gmail.com) on 5/14/12.
//  Copyright (c) 2012 Lukasz Sowinski. All rights reserved.
//

const highp vec4 packFactors = vec4(256.0 * 256.0 * 256.0, 256.0 * 256.0, 256.0, 1.0);
const highp vec4 cutoffMask  = vec4(0.0, 1.0/256.0, 1.0/256.0, 1.0/256.0);

void main() {
    highp vec4 packedVal = vec4(fract(packFactors*gl_FragCoord.z));
    gl_FragColor = packedVal - packedVal.xxyz*cutoffMask;
}