//
//  LSObject3DFragment.h
//  OjiPark
//
//  Created by Sowinski Lukasz on 2/22/13.
//  Copyright (c) 2013 Mouse Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LSMaterial3D;
@class LSProgram3D;
@class LSProgram3DAttributes;

@interface LSObject3DFragment : NSObject <NSCoding>

@property (weak) LSMaterial3D* material;
@property        bool          uv;
@property        LSProgram3D*  program;
@property        LSProgram3D*  shadowProgram;
@property        GLushort      faceOffset;
@property        GLushort      faceCount;
@property        GLushort      vertexOffset;
@property        GLushort      vertexCount;
@property        bool          dshadow;

@property (NS_NONATOMIC_IOSONLY, readonly, strong) LSProgram3DAttributes *attributes;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *shaderParameters;

@end
