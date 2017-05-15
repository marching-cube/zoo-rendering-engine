//
//  LSBuffer3D.h
//  OjiPark
//
//  Created by Sowinski Lukasz on 03/02/2013.
//  Copyright (c) 2013 Mouse Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSContext3D.h"
#import "LSModel3DSourceOBJ.h"

@class LSProgram3DAttributes;

@interface LSBuffer3D : NSObject
{
    NSMutableDictionary* vertexIndexMap;
}

-(instancetype) init NS_DESIGNATED_INITIALIZER;
-(instancetype) initWithAttributes:(LSProgram3DAttributes*)theAttributes modelSource:(LSModel3DSourceOBJ*)modelSource NS_DESIGNATED_INITIALIZER;
-(void) addFaceFromLine:(NSString*)line;
-(void) addTangentsAndBinormals;
-(void) shiftIndexes:(int)fshift;

@property LSModel3DSourceOBJ* modelSource;

@property LSProgram3DAttributes* attributes;
@property GLfloat*   vertexBuffer;
@property GLushort   vertexCount;
@property GLushort*  faceBuffer;
@property GLushort   faceCount;

@end
