//
//  NSExtensions.m
//  OjiPark
//
//  Created by Sowinski Lukasz on 3/12/13.
//  Copyright (c) 2013 Mouse Inc. All rights reserved.
//

#import "NSExtensions.h"

@implementation NSCoder (GLK)

-(GLKVector3) decodeGLKVector3ForKey:(NSString*)key
{
    NSUInteger length = 0;
    const void* data = [self decodeBytesForKey:key returnedLength:&length];
    if (length == sizeof(float)*3) return GLKVector3MakeWithArray((float*)data);
    return GLKVector3Make(0, 0, 0);
}

-(void) encodeGLKVector3:(GLKVector3)vector forKey:(NSString*)key
{
    [self encodeBytes:(void*)vector.v length:sizeof(float)*3 forKey:key];
}

-(GLKVector4) decodeGLKVector4ForKey:(NSString*)key
{
    NSUInteger length = 0;
    const void* data = [self decodeBytesForKey:key returnedLength:&length];
    if (length == sizeof(float)*4) return GLKVector4MakeWithArray((float*)data);
    return GLKVector4Make(0, 0, 0, 0);
}

-(void) encodeGLKVector4:(GLKVector4)vector forKey:(NSString*)key
{
    [self encodeBytes:(void*)vector.v length:sizeof(float)*4 forKey:key];
}

@end


@implementation NSBundle (Extension)

- (NSString *)extendedPathForResource:(NSString *)name
{
    return [self extendedPathForResource:name ofType:nil];
}

- (NSString *)extendedPathForPVRTC:(NSString *)name
{
    return [[NSBundle mainBundle] extendedPathForResource: name.stringByDeletingPathExtension ofType:@"pvrtc"];
}

- (NSString *)extendedPathForResource:(NSString *)name ofType:(NSString *)extension
{
    if (extension == nil) {
        extension = name.pathExtension;
        name = name.stringByDeletingPathExtension;
    }
    NSString* fname = [[NSBundle mainBundle] pathForResource:name ofType:extension];
    if (fname == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *documentRoot = paths[0];
        fname = [documentRoot stringByAppendingPathComponent: [name stringByAppendingPathExtension:extension]];
    }
    return ([[NSFileManager defaultManager] fileExistsAtPath:fname] ? fname : nil);
}

@end

