//
//  LSMaterial3DCache.m
//  OjiPark
//
//  Created by Sowinski Lukasz on 1/24/13.
//  Copyright (c) 2013 Mouse Inc. All rights reserved.
//

#import "LSMaterial3DCache.h"
#import "LSMaterial3D.h"
#import "NSExtensions.h"

@implementation LSMaterial3DCache

+(LSMaterial3DCache*) sharedCache
{
    static LSMaterial3DCache* sharedCache = nil;
    if ( nil == sharedCache ) {
        sharedCache = [[self alloc] init];
    }
    return sharedCache;
}

-(instancetype) init
{
    self=[super init];
    if (self) {
        cache = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void) processOBJSourceMaterials:(NSString*)modelName
{
    NSString* fname = [[NSBundle mainBundle] extendedPathForResource:modelName ofType:@"mtl"];
    NSString* raw   = [NSString stringWithContentsOfFile:fname encoding:NSUTF8StringEncoding error:nil];
    NSArray*  lines = [raw componentsSeparatedByString:@"\n"];
    
    if (!fname) {
        NSLog(@"Material file not found!");
        return;
    }
    
    NSString* materialKey = nil;
    NSRange   materialRange;
    int i = 0;
    for (NSString* line in lines) {
        
        if ([line hasPrefix:@"newmtl "]) {
            materialKey = [line substringFromIndex: (@"newmtl ").length];
            materialRange = NSMakeRange(i, 0);
        }
        
        if ([line isEqualToString:@""] && materialKey) {
            materialRange.length = i-materialRange.location;
            NSString* conf = [[lines subarrayWithRange:materialRange] componentsJoinedByString:@"\n"];
            LSMaterial3D* material = [[LSMaterial3D alloc] initWithConf:conf];
            cache[materialKey] = material;
            materialKey = nil;
        }
        
        i++;
    }
    
}

-(LSMaterial3D*) materialForKey:(NSString*)key
{
    return cache[key];
}


@end
