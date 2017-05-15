//
//  LSMaterial3DCache.h
//  OjiPark
//
//  Created by Sowinski Lukasz on 1/24/13.
//  Copyright (c) 2013 Mouse Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LSMaterial3D;

@interface LSMaterial3DCache : NSObject {
    NSMutableDictionary* cache;
}

+(LSMaterial3DCache*) sharedCache;
-(void) processOBJSourceMaterials:(NSString*)modelName;

-(LSMaterial3D*) materialForKey:(NSString*)key;

@end
