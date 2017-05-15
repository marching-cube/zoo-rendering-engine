//
//  LSMaterial3D.m
//  OjiPark
//
//  Created by Sowinski Lukasz on 1/22/13.
//  Copyright (c) 2013 Mouse Inc. All rights reserved.
//

#import "LSMaterial3D.h"
#import <GLKit/GLKit.h>
#import "NSExtensions.h"

@implementation LSMaterial3D

- (instancetype)init
{
    return [super init];
}

-(instancetype) initWithConf:(NSString*)conf {
    self=[super init];
    if (self) {
        [self loadOBJMaterial:conf];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)coder
{
    self=[super init];
    if (self) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.ambientColor = [coder decodeGLKVector4ForKey:@"ambientColor"];
        self.ambientIntensity = [coder decodeFloatForKey:@"ambientIntensity"];
        self.diffuseColor = [coder decodeGLKVector4ForKey:@"diffuseColor"];
        self.diffuseIntensity = [coder decodeFloatForKey:@"diffuseIntensity"];
        self.specularColor = [coder decodeGLKVector4ForKey:@"specularColor"];
        self.specularIntensity = [coder decodeFloatForKey:@"specularIntensity"];
        self.specularExponent = [coder decodeFloatForKey:@"specularExponent"];
        self.textureName = [coder decodeObjectForKey:@"textureName"];
        self.bumpTextureName = [coder decodeObjectForKey:@"bumpTextureName"];
        
        // TODO: openGL - should be reloaded
        self.texture = [coder decodeIntForKey:@"texture"];
        self.bumpTexture = [coder decodeIntForKey:@"bumpTexture"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeGLKVector4:self.ambientColor forKey:@"ambientColor"];
    [coder encodeFloat:self.ambientIntensity forKey:@"ambientIntensity"];
    [coder encodeGLKVector4:self.diffuseColor forKey:@"diffuseColor"];
    [coder encodeFloat:self.diffuseIntensity forKey:@"diffuseIntensity"];
    [coder encodeGLKVector4:self.specularColor forKey:@"specularColor"];
    [coder encodeFloat:self.specularIntensity forKey:@"specularIntensity"];
    [coder encodeFloat:self.specularExponent forKey:@"specularExponent"];
    [coder encodeObject:self.textureName forKey:@"textureName"];
    [coder encodeObject:self.bumpTextureName forKey:@"bumpTextureName"];
    
    // TODO: openGL - should be reloaded
    [coder encodeInt:self.texture forKey:@"texture"];
    [coder encodeInt:self.bumpTexture forKey:@"bumpTexture"];
}

-(GLKVector4)ambientColorAdjusted {
    return GLKVector4Make(self.ambientColor.r*self.ambientIntensity, self.ambientColor.g*self.ambientIntensity, self.ambientColor.b*self.ambientIntensity, self.ambientColor.a);
}

-(GLKVector4)diffuseColorAdjusted {
    return GLKVector4Make(self.diffuseColor.r*self.diffuseIntensity, self.diffuseColor.g*self.diffuseIntensity, self.diffuseColor.b*self.diffuseIntensity, self.diffuseColor.a);
}

-(GLKVector4)specularColorAdjusted {
    return GLKVector4Make(self.specularColor.r*self.specularIntensity, self.specularColor.g*self.specularIntensity, self.specularColor.b*self.specularIntensity, self.specularColor.a);
}

-(void) loadOBJMaterial:(NSString*)conf
{
    
    NSArray* supported = @[@"newmtl", @"Ka", @"Kd", @"Ks", @"Ns", @"map_Kd", @"map_Ka", @"map_Ks", @"map_Bump", @"d", @"Tr", @"Ni", @"illum"];
    
    self.ambientIntensity  = 1;
    self.diffuseIntensity  = 1;
    self.specularIntensity = 1;
    
    for (NSString* line in [conf componentsSeparatedByString:@"\n"])
    {
        NSString* cmd = [line componentsSeparatedByString:@" "][0];
        if (![supported containsObject:cmd]) printf("Warning:   unsupported material paramter '%s'\n", cmd.UTF8String);
        
        // load
        if ([line hasPrefix:@"newmtl "]) self.name = [line substringFromIndex:(@"newmtl ").length];
        if ([line hasPrefix:@"Ka "]) self.ambientColor  = [self colorFromText:line];
        if ([line hasPrefix:@"Kd "]) self.diffuseColor  = [self colorFromText:line];
        if ([line hasPrefix:@"Ks "]) self.specularColor = [self colorFromText:line];
        if ([line hasPrefix:@"Ns "]) self.specularExponent = [line substringFromIndex:(@"Ns ").length].floatValue;
        if ([line hasPrefix:@"map_Kd "]) self.textureName = [line substringFromIndex:(@"map_Kd ").length];
        if ([line hasPrefix:@"map_Bump "]) self.bumpTextureName = [line substringFromIndex:(@"map_Bump ").length];
        
        //verify
        if ([line hasPrefix:@"map_Ka "]) NSLog(@"Warning! 'map_Ka' not supported!");
        if ([line hasPrefix:@"map_Ks "]) NSLog(@"Warning! 'map_Ks' not supported!");
        if ([line hasPrefix:@"d "]  && [line substringFromIndex:(@"d ").length].floatValue != 1) printf("Warning:   unsupported value of 'd'\n");
        if ([line hasPrefix:@"Tr "] && [line substringFromIndex:(@"Tr ").length].floatValue != 1) printf("Warning:   unsupported value of 'Tr'\n");
        if ([line hasPrefix:@"Ni "] && [line substringFromIndex:(@"Ni ").length].floatValue != 1) printf("Warning:   unsupported value of 'Ni'\n");
        if ([line hasPrefix:@"illum "]) {
            int illum = [line substringFromIndex:(@"illum ").length].intValue;
            if (illum > 2)  printf("Warning:   unsupported shading model 'illum'!\n");
        }
    }
}

-(GLKVector4) colorFromText:(NSString*) text
{
    GLKVector4 color = GLKVector4Make(0, 0, 0, 1);
    NSArray* elements = [text componentsSeparatedByString:@" "];
    for (int i=1; i<elements.count; i++)
        color.v[i-1] = [elements[i] floatValue];
    return color;
}

@end
