//
//  LSObject3DFragment.m
//  OjiPark
//
//  Created by Sowinski Lukasz on 2/22/13.
//  Copyright (c) 2013 Mouse Inc. All rights reserved.
//

#import "LSObject3DFragment.h"
#import "LSMaterial3D.h"
#import "LSProgram3D.h"
#import "LSProgram3DAttributes.h"

@implementation LSObject3DFragment

-(instancetype)initWithCoder:(NSCoder *)coder
{
    self=[super init];
    if (self) {
        // TODO: optimise
        self.material = [coder decodeObjectForKey:@"material"];
        self.uv = [coder decodeBoolForKey:@"uv"];
        self.program = [coder decodeObjectForKey:@"program"];
        self.shadowProgram = [coder decodeObjectForKey:@"shadowProgram"];
        self.faceOffset = [coder decodeFloatForKey:@"faceOffset"];
        self.faceCount = [coder decodeFloatForKey:@"faceCount"];
        self.vertexOffset = [coder decodeFloatForKey:@"vertexOffset"];
        self.vertexCount = [coder decodeFloatForKey:@"vertexCount"];
        self.dshadow = [coder decodeBoolForKey:@"dshadow"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    // TODO: optimise
    [coder encodeObject:self.material forKey:@"material"];
    [coder encodeBool:self.uv forKey:@"uv"];
    [coder encodeObject:self.program forKey:@"program"];
    [coder encodeObject:self.shadowProgram forKey:@"shadowProgram"];
    [coder encodeInteger:self.faceOffset forKey:@"faceOffset"];
    [coder encodeInteger:self.faceCount forKey:@"faceCount"];
    [coder encodeInteger:self.vertexOffset forKey:@"vertexOffset"];
    [coder encodeInteger:self.vertexCount forKey:@"vertexCount"];
    [coder encodeBool:self.dshadow forKey:@"dshadow"];
}

-(NSString *)description
{
    return [NSString stringWithFormat: @"fragment material:'%@' program:%d f:%d+%d v:%d+%d",
            self.material.name, [self.program gl_program], self.faceOffset, self.faceCount, self.vertexOffset, self.vertexCount];
}

-(LSProgram3DAttributes*) attributes
{
    LSProgram3DAttributes* attributes = (self.uv ? [LSProgram3DAttributes attributesFull] : [LSProgram3DAttributes attributesNoUV]);
    if (self.material.bumpTextureName) [attributes enableTangentBinormal];
    return attributes;
}

-(NSString*) shaderParameters
{
    NSMutableString* shaderParameters = [NSMutableString string];
    if (self.uv) [shaderParameters appendString:@"#uv"];
    if (self.dshadow) [shaderParameters appendString:@"#shadow"];
    if (self.material.bumpTextureName) [shaderParameters appendFormat:@"#bumps#perfragment"]; // duplicate???
    if ([self.material.textureName hasPrefix:@"z_tree"]) [shaderParameters appendFormat:@"#alphadiscard"];
    return shaderParameters;
}


@end
