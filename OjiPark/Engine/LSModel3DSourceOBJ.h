//
//  LSModel3DSourceOBJ.h
//  miniEngine3D
//
//  Created by Sowinski Lukasz on 7/31/12.
//  Copyright (c) 2012 Lukasz Sowinski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface LSModel3DSourceOBJ : NSObject

-(instancetype) initWithSourceName:(NSString*)aName;

@property (readonly) float* v;
@property (readonly) float* vt;
@property (readonly) float* vn;
@property (readonly) int v_size;
@property (readonly) int vt_size;
@property (readonly) int vn_size;
@property (strong, readonly) NSString* name;
@property (strong, readonly) NSMutableDictionary* entries;

@end

@interface LSModel3DSourceOBJEntry : NSObject
@property (strong) NSString* name;
@property (strong) NSString* materialKey;
@property (strong) NSString* faces;
@property         GLKVector3 offset;
@property         GLKVector3 box0;
@property         GLKVector3 box1;
@property         GLKVector3 firstVertex;
@property         GLKVector3 gravity;
@end
