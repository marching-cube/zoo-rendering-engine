//
//  LSProgram3DAttributes.h
//  RubikCube
//
//  Created by Sowinski Lukasz on 11/5/12.
//  Copyright (c) 2012 Sowinski Lukasz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSProgram3DAttributes : NSObject <NSCoding>

#pragma mark -
#pragma mark Initialization

+(instancetype) attributesFull;
+(instancetype) attributesNoUV;
+(instancetype) attributesPosition;
+(instancetype) attributesSkybox;
+(instancetype) attributesSimple2D;
+(instancetype) attributesFull2D;

-(void) enableTangentBinormal;

#pragma mark -
#pragma mark Properties

@property (NS_NONATOMIC_IOSONLY, readonly) int size;
@property (NS_NONATOMIC_IOSONLY, readonly) void *positionStride;
@property (NS_NONATOMIC_IOSONLY, readonly) void *normalStride;
@property (NS_NONATOMIC_IOSONLY, readonly) void *tangentStride;
@property (NS_NONATOMIC_IOSONLY, readonly) void *binormalStride;
@property (NS_NONATOMIC_IOSONLY, readonly) void *uvStride;

@property int verticesPerFace;
@property int positionSize;
@property int normalSize;
@property int tangentSize;
@property int binormalSize;
@property int uvSize;

@end
