//
//  LSObject3D.m
//  miniEngine3D
//
//  Created by Lukasz Sowinski (niman.gosen.en@gmail.com) on 7/4/12.
//  Copyright (c) 2012 Lukasz Sowinski. All rights reserved.
//

#import "LSObject3D.h"
#import "LSModel3D.h"
#import "LSObject3DConf.h"
#import "LSObject3DFragment.h"
#import "LSView3D.h"
#import "LSModel3DSourceOBJ.h"
#import "LSMaterial3D.h"
#import "LSMaterial3DCache.h"
#import "LSBuffer3D.h"
#import "LSProgram3DAttributes.h"
#import "LSProgram3D.h"
#import "NSExtensions.h"

@interface LSObject3D ()

// general
@property bool       cloned;
//@property (weak)     LSObject3D* cloneLink;

// data
@property NSMutableArray*   fragments;

// others
@property (strong, nonatomic) id modelSource; // TODO: changed weak -> strong to make it work with newer iOS
@property (strong) NSString*   objectKey;


@end

@implementation LSObject3D


#pragma mark -
#pragma mark Initialization

-(NSString *)description
{
    return [NSString stringWithFormat: @"object: %@", self.objectKey];
}


+(instancetype) object3DWithOBJModelSource:(LSModel3DSourceOBJ*)aModelSource
                       objectKey:(NSString*)aObjectKey
                      objectConf:(LSObject3DConf*)objectConf
{
    if (objectConf.delete || objectConf.cloneName) return nil;
    LSObject3D* object = [[LSObject3D alloc] initObject3DWithOBJModelSource:aModelSource objectKey:aObjectKey];
    [objectConf copyContents:object];
    if (object.stripTextures || [[LSView3D mainView] stripTextures]) [object stripTexture];
    [object queryData];
    return object;
}

-(instancetype) initObject3DWithOBJModelSource:(LSModel3DSourceOBJ*)aModelSource objectKey:(NSString*)aObjectKey
{
    self=[super init];
    if (self) {
        _modelSource = aModelSource;
        _objectKey = aObjectKey;
        _name = aObjectKey;
        self.fragments = [NSMutableArray array];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)coder
{
    self=[super initWithCoder:coder];
    if (self) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.box0 = [coder decodeGLKVector3ForKey:@"box0"];
        self.box1 = [coder decodeGLKVector3ForKey:@"box1"];
        self.cloned = [coder decodeBoolForKey:@"cloned"];
        if (self.cloned) {
            self.offset = [coder decodeGLKVector3ForKey:@"offset"];
            self.cloneScale = [coder decodeFloatForKey:@"cloneScale"];
            self.cloneRotation = [coder decodeFloatForKey:@"cloneRotation"];
            self.cloneRotationOffset = [coder decodeGLKVector3ForKey:@"cloneRotationOffset"];
        }
        self.fragments = [coder decodeObjectForKey:@"fragments"];
        self.animation = [coder decodeObjectForKey:@"animation"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject: self.name forKey:@"name"];
    [coder encodeGLKVector3:self.box0 forKey:@"box0"];
    [coder encodeGLKVector3:self.box1 forKey:@"box1"];
    [coder encodeBool: self.cloned forKey:@"cloned"];
    if (self.cloned) {
        [coder encodeGLKVector3:self.offset forKey:@"offset"];
        [coder encodeFloat:self.cloneScale forKey:@"cloneScale"];
        [coder encodeFloat:self.cloneRotation forKey:@"cloneRotation"];
        [coder encodeGLKVector3:self.cloneRotationOffset forKey:@"cloneRotationOffset"];
    }
    [coder encodeObject: self.fragments forKey:@"fragments"];
    [coder encodeObject: self.animation forKey:@"animation"];
}

-(LSObject3D*) cloneObjectWithNewKey:(NSString*)newKey
{
    
    if ([self.objectKey isEqualToString:newKey]) return nil;

    LSObject3D* object = [[LSObject3D alloc] init];
    
    [self copyContents: object];
    
    object.buffers           = self.buffers;
    
    object.cloned            = true;
//    object.cloneLink         = self;
//    object.gravityLink       = self.gravityLink;

    object.offset            = self.offset;
    
    object.modelSource       = self.modelSource;
    object.objectKey         = newKey;

    object.animation         = nil;
    
    object.box0              = self.box0;
    object.box1              = self.box1;
    object.firstVertex       = self.firstVertex;
    object.gravity           = self.gravity;

    // TODO: should be a copy ?
    object.fragments         = self.fragments;

    return object;
}

-(void)dealloc
{
    [self unloadData];
}

-(void) reQueryData
{
    statusQueried = FALSE;
    [self unloadData];
    [self queryData];
}

-(void) unloadData
{
    self.buffers = nil;
    statusLoaded = FALSE;
}

-(void) normalizeVertexData
{
    // nothing now
}

-(void) shiftFragmentBuffer:(LSBuffer3D*)buffer indexes:(int)fshift vertices:(int)vshift
{
    [buffer shiftIndexes: fshift];
    for (LSObject3DFragment* fragment in self.fragments) {
        if ([self bufferForFragment:fragment] == buffer) {
            fragment.vertexOffset += fshift;
            fragment.faceOffset   += vshift;
        }
    }
}

-(void) stripTexture
{
    if (statusQueried) printf("Warning:   stripTexture should not be called after object was queried!\n");
    stripedTexture = TRUE;
}

-(void) loadData
{
    if (!statusQueried) return;
    if (statusLoaded) return;
    
    self.buffers = [NSMutableDictionary dictionary];
    
    LSBuffer3D* buffer = nil;

    LSModel3DSourceOBJEntry* entry = ((LSModel3DSourceOBJ*)_modelSource).entries[self.name];
    NSArray*  lines = [entry.faces componentsSeparatedByString:@"\n"];
        
    LSObject3DFragment* fragment = nil;
    
    // process faces
    for (NSString* line in lines)
    {
        if ([line hasPrefix:@"usemtl"])
        {
            NSString* mtlKey = [line substringFromIndex: (@"usemtl ").length];
            fragment = [self addFragmentForKey: mtlKey];
            buffer = [self bufferForFragment:fragment];
            fragment.faceOffset = buffer.faceCount;
            fragment.vertexOffset = buffer.vertexCount;
        }
        if ([line hasPrefix:@"f"] && [line componentsSeparatedByString:@" "].count > 3)
        {
            if (fragment == nil) printf("error:    no material defined for this face\n");
            [buffer addFaceFromLine: line];
            fragment.vertexCount = buffer.vertexCount-fragment.vertexOffset;
            fragment.faceCount++;
        }
    }
    
    statusLoaded = true;
    
}

-(LSBuffer3D*) currentBuffer
{
    for (LSObject3DFragment* fragment in self.fragments) {
        if ([fragment.program isActive]) {
            return [self bufferForFragment:fragment];
        }
    }
    return nil;
}

-(LSBuffer3D*) bufferForFragment:(LSObject3DFragment*)fragment
{
    LSBuffer3D* buffer = (self.buffers)[fragment.shaderParameters];
    if (buffer == nil) {
        buffer = [[LSBuffer3D alloc] initWithAttributes: fragment.attributes modelSource:_modelSource];
        (self.buffers)[fragment.shaderParameters] = buffer;
    }
    return buffer;
}

-(LSObject3DFragment*) addFragmentForKey:(NSString*)mtlKey
{
    LSMaterial3D* material = [[LSMaterial3DCache sharedCache] materialForKey: mtlKey];
    
    bool textureCondition = ((material.textureName != nil) && !stripedTexture);
    bool shadowDisplay = (self.dshadow && ![[LSView3D mainView] stripShadows]);

    LSObject3DFragment* fragment = [[LSObject3DFragment alloc] init];
    fragment.uv = textureCondition;
    fragment.material = material;
    fragment.faceOffset = 0;
    fragment.faceCount = 0;
    fragment.dshadow = shadowDisplay;
    
    [self.fragments addObject: fragment];
    
    return fragment;
}

-(void) queryData
{
    
    if (statusQueried) return;
    
    LSModel3DSourceOBJEntry* entry = ((LSModel3DSourceOBJ*)_modelSource).entries[self.name];

    NSArray*  lines = [entry.faces componentsSeparatedByString:@"\n"];
    
    _box0 = entry.box0;
    _box1 = entry.box1;
    _firstVertex = entry.firstVertex;
    _gravity = entry.gravity;
    _offset = GLKVector3Make(0, 0, 0);

    if (!lines || lines.count < 2) {
        printf("Warning:   No face data available!\n");
        return;
    }
    
    for (NSString* line in lines) {
        if ([line hasPrefix:@"f"]) {
            if ([line componentsSeparatedByString:@" "].count <= 3) {
                printf("Warning:   incomplete face: %s : %s\n", (self.name).UTF8String, line.UTF8String);
            }
        }
    }
    
    statusQueried = TRUE;
    statusLoaded  = FALSE;

}

-(void) loadOBJInstanceDataByCloning:(LSObject3D*)object
{
    _offset = GLKVector3Subtract(self.centerBottom, object.centerBottom);
    _cloneScale = (self.box0.y-self.box1.y)/(object.box0.y-object.box1.y);
    _cloneRotation = [self calculateObjectRotation:self against:object];
    _cloneRotationOffset = object.centerBottom; // TODO: redundancy
}

-(float) calculateObjectRotation:(LSObject3D*)object against:(LSObject3D*)reference
{
    GLKVector2 v0 = GLKVector2Make(reference.firstVertex.x-reference.gravity.x,
                                   reference.firstVertex.z-reference.gravity.z);
    GLKVector2 v1 = GLKVector2Make(object.firstVertex.x-object.gravity.x,
                                   object.firstVertex.z-object.gravity.z);
    GLKVector2 vn = GLKVector2Make(v0.y, -v0.x);
    float dot1 = GLKVector2DotProduct(GLKVector2Normalize(v0), GLKVector2Normalize(v1));
    float dot2 = GLKVector2DotProduct(GLKVector2Normalize(vn), GLKVector2Normalize(v1));

    return (dot2>0 ? acosf(dot1) : -acosf(dot1)) ;
}

-(void) calculateThreePointNormal:(float*)points times:(int)repeat length:(int)h
{
    float v1[3] = {points[h*0+0]-points[h*1+0], points[h*0+1]-points[h*1+1], points[h*0+2]-points[h*1+2]};
    float v2[3] = {points[h*0+0]-points[h*2+0], points[h*0+1]-points[h*2+1], points[h*0+2]-points[h*2+2]};
    
    float  n[3];
    n[0] =  v1[1]*v2[2]-v1[2]*v2[1];
    n[1] = -v1[0]*v2[2]+v1[2]*v2[0];
    n[2] =  v1[0]*v2[1]-v1[1]*v2[0];
    
    for (int i=0; i<repeat; i++) {
        for (int j=0; j<3; j++) {
            points[h*i+3+j] = n[j];
        }
    }

}

-(GLKVector3) center
{
    return GLKVector3MultiplyScalar(GLKVector3Add(self.box0, self.box1), 0.5);
}

-(GLKVector3) centerBottom
{
    return GLKVector3Make((self.box0.x+self.box1.x)/2, self.box0.y, (self.box0.z+self.box1.z)/2);
}


@end
