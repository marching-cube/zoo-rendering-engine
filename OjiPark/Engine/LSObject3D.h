//
//  LSObject3D.h
//  miniEngine3D
//
//  Created by Lukasz Sowinski (niman.gosen.en@gmail.com) on 7/4/12.
//  Copyright (c) 2012 Lukasz Sowinski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "LSObject3DConf.h"
#import "LSContext3D.h"

@class LSAnimation3DBasic;
@class LSModel3DSourceOBJ;
@class LSMaterial3D;
@class LSBuffer3D;
@class LSObject3DFragment;

@interface LSObject3D : LSObject3DConf <NSCoding> {
    int         headerSize;
    bool        statusQueried;
    bool        statusLoaded;
    bool        stripedTexture;
}

// general
@property            NSString*  name;
@property (readonly) bool       cloned;
//@property (readonly, weak)      LSObject3D* cloneLink;
//@property (          weak)      LSObject3D* gravityLink;
@property           GLKVector3  box0;
@property           GLKVector3  box1;
@property (readonly) NSMutableArray* fragments;

// shader uniforms - configuration
@property           GLKVector3  offset;
@property           float cloneScale;
@property           float cloneRotation;
@property           GLKVector3 cloneRotationOffset;
@property (strong)  LSAnimation3DBasic*      animation;

// Temporary
@property           GLKVector3  firstVertex;
@property           GLKVector3  gravity;
@property  (strong)  NSMutableDictionary* buffers;

@property (NS_NONATOMIC_IOSONLY, readonly, strong) LSBuffer3D *currentBuffer;




+(instancetype) object3DWithOBJModelSource:(LSModel3DSourceOBJ*)aModelSource objectKey:(NSString*)aObjectKey objectConf:(LSObject3DConf*)objectConf;

-(void) loadOBJInstanceDataByCloning:(LSObject3D*)object;

-(LSObject3D*) cloneObjectWithNewKey:(NSString*)newKey;

//-(void) printFaces:(int)count starting:(int)first;
//-(void) printFaceStatistics:(int)count starting:(int)first;

-(void) loadData;
-(void) queryData;
-(void) reQueryData;
-(void) unloadData;

-(void) normalizeVertexData;
-(void) shiftFragmentBuffer:(LSBuffer3D*)buffer indexes:(int)fshift vertices:(int)vshift;
-(void) stripTexture;

@end

