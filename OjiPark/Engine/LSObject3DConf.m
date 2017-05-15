//
//  LSObject3DConf.m
//  miniEngine3D
//
//  Created by Lukasz Sowinski (niman.gosen.en@gmail.com) on 7/22/12.
//  Copyright (c) 2012 Lukasz Sowinski. All rights reserved.
//

#import "LSObject3DConf.h"
#import "NSExtensions.h"

@implementation LSObject3DConf

-(id) copy
{
    LSObject3DConf* conf = [[LSObject3DConf alloc] init];
    [self copyContents:conf];
    return conf;
}

-(void) copyContents:(LSObject3DConf*)conf
{
    conf.flat = self.flat;
    conf.delete = self.delete;
    conf.nflip = self.nflip;
    conf.cloneName = self.cloneName;
    conf.textureName = self.textureName;
    conf.stripTextures = self.stripTextures;
    conf.dshadow = self.dshadow;
    conf.cshadow = self.cshadow;
    conf.animated = self.animated;
    conf.axis = self.axis;
    conf.anchor = self.anchor;
    conf.speed = self.speed;
    conf.parentName = self.parentName;
}

-(instancetype)initWithCoder:(NSCoder *)coder
{
    self=[super init];
    if (self) {
        // TODO: remove obsolete
        self.flat = [coder decodeBoolForKey:@"flat"];
        self.delete = [coder decodeBoolForKey:@"delete"];
        self.nflip = [coder decodeBoolForKey:@"nflip"];
        self.stripTextures = [coder decodeBoolForKey:@"stripTextures"];
        self.cloneName = [coder decodeObjectForKey:@"cloneName"];
        self.parentName = [coder decodeObjectForKey:@"parentName"];
        self.textureName = [coder decodeObjectForKey:@"textureName"];
        self.dshadow = [coder decodeBoolForKey:@"dshadow"];
        self.cshadow = [coder decodeBoolForKey:@"cshadow"];
        self.animated = [coder decodeBoolForKey:@"animated"];
        if (self.animated) {
            self.speed = [coder decodeFloatForKey:@"speed"];
            self.anchor = [coder decodeGLKVector3ForKey:@"anchor"];
            self.axis = [coder decodeGLKVector3ForKey:@"axis"];
        }
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    // TODO: remove obsolete
    [coder encodeBool:self.flat forKey:@"flat"];
    [coder encodeBool:self.delete forKey:@"delete"];
    [coder encodeBool:self.nflip forKey:@"nflip"];
    [coder encodeBool:self.stripTextures forKey:@"stripTextures"];
    [coder encodeObject:self.cloneName forKey:@"cloneName"];
    [coder encodeObject:self.parentName forKey:@"parentName"];
    [coder encodeObject:self.textureName forKey:@"textureName"];
    [coder encodeBool:self.dshadow forKey:@"dshadow"];
    [coder encodeBool:self.cshadow forKey:@"cshadow"];
    [coder encodeBool:self.animated forKey:@"animated"];
    if (self.animated) {
        [coder encodeFloat:self.speed forKey:@"speed"];
        [coder encodeGLKVector3:self.anchor forKey:@"anchor"];
        [coder encodeGLKVector3:self.axis forKey:@"axis"];
    }

}



@end
