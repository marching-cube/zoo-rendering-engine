//
//  NSExtensions.h
//  OjiPark
//
//  Created by Sowinski Lukasz on 3/12/13.
//  Copyright (c) 2013 Mouse Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface NSCoder (GLK)

-(GLKVector3) decodeGLKVector3ForKey:(NSString*)key;
-(void) encodeGLKVector3:(GLKVector3)vector forKey:(NSString*)key;
-(GLKVector4) decodeGLKVector4ForKey:(NSString*)key;
-(void) encodeGLKVector4:(GLKVector4)vector forKey:(NSString*)key;

@end

@interface NSBundle (Extension)

- (NSString *)extendedPathForPVRTC:(NSString *)name;
- (NSString *)extendedPathForResource:(NSString *)name;
- (NSString *)extendedPathForResource:(NSString *)name ofType:(NSString *)ext;

@end
