//
//  LSProgram3DAttributes.m
//  RubikCube
//
//  Created by Sowinski Lukasz on 11/5/12.
//  Copyright (c) 2012 Sowinski Lukasz. All rights reserved.
//

#import "LSProgram3DAttributes.h"

@implementation LSProgram3DAttributes

#pragma mark -
#pragma mark Initialization

-(instancetype) init
{
    self = [super init];
    if (self) {
        self.positionSize = 0;
        self.normalSize = 0;
        self.uvSize = 0;
        self.tangentSize = 0;
        self.binormalSize = 0;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.positionSize = [coder decodeIntForKey:@"positionSize"];
        self.normalSize = [coder decodeIntForKey:@"normalSize"];
        self.uvSize = [coder decodeIntForKey:@"uvSize"];
        self.tangentSize = [coder decodeIntForKey:@"tangentSize"];
        self.binormalSize = [coder decodeIntForKey:@"binormalSize"];

    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt:self.positionSize forKey:@"positionSize"];
    [coder encodeInt:self.normalSize forKey:@"normalSize"];
    [coder encodeInt:self.uvSize forKey:@"uvSize"];
    [coder encodeInt:self.tangentSize forKey:@"tangentSize"];
    [coder encodeInt:self.binormalSize forKey:@"binormalSize"];
}

+(instancetype) attributesFull {
    LSProgram3DAttributes* attributes = [[self alloc] init];
    attributes.positionSize = 3;
    attributes.normalSize = 3;
    attributes.uvSize = 2;
    return attributes;
}

+(instancetype) attributesNoUV {
    LSProgram3DAttributes* attributes = [[self alloc] init];
    attributes.positionSize = 3;
    attributes.normalSize = 3;
    attributes.uvSize = 0;
    return attributes;
}

+(instancetype) attributesPosition {
    LSProgram3DAttributes* attributes = [[self alloc] init];
    attributes.positionSize = 3;
    attributes.normalSize = 0;
    attributes.uvSize = 0;
    return attributes;
}

+(instancetype) attributesSkybox {
    LSProgram3DAttributes* attributes = [[self alloc] init];
    attributes.positionSize = 3;
    attributes.normalSize = 0;
    attributes.uvSize = 3;
    return attributes;
}

+(instancetype) attributesSimple2D {
    LSProgram3DAttributes* attributes = [[self alloc] init];
    attributes.positionSize = 2;
    attributes.normalSize = 0;
    attributes.uvSize = 0;
    return attributes;
}

+(instancetype) attributesFull2D {
    LSProgram3DAttributes* attributes = [[self alloc] init];
    attributes.positionSize = 2;
    attributes.normalSize = 0;
    attributes.uvSize = 2;
    return attributes;
}

-(void) enableTangentBinormal
{
    self.tangentSize = self.normalSize;
    self.binormalSize = self.normalSize;
}

#pragma mark -
#pragma mark Properties

-(int) size
{
    return (self.positionSize+self.normalSize+self.uvSize+self.tangentSize+self.binormalSize)*sizeof(float);
}

-(void*) positionStride
{
    return (void*)0;
}

-(void*) normalStride
{
    return self.positionStride+self.positionSize*sizeof(float);
}

-(void*) uvStride
{
    return self.normalStride+self.normalSize*sizeof(float);;
}

-(void*) tangentStride
{
    return self.uvStride+self.uvSize*sizeof(float);;
}

-(void*) binormalStride
{
    return self.tangentStride+self.tangentSize*sizeof(float);;
}



@end
