//
//  LSModel3DConf.m
//  miniEngine3D
//
//  Created by Lukasz Sowinski (niman.gosen.en@gmail.com) on 7/12/12.
//  Copyright (c) 2012 Lukasz Sowinski. All rights reserved.
//

#import "LSModel3DConf.h"
#import "LSObject3DConf.h"
#import "NSExtensions.h"

@implementation LSModel3DConf

-(instancetype)init {
    self = [super init];
    return self;
}

-(instancetype) initWithModelName:(NSString*)aModelName {
    self=[super init];
    if (self) {
        modelName = aModelName;
        _objects   = [NSMutableDictionary dictionary];
        defaultObjectConf = [[LSObject3DConf alloc] init];
        [self loadConfigurationFile];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)coder
{
    self=[self init];
    if (self) {
        // TODO: optimise
        modelName = [coder decodeObjectForKey:@"modelName"];
        defaultObjectConf = [coder decodeObjectForKey:@"defaultObjectConf"];
        _objects = [coder decodeObjectForKey:@"objects"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    // TODO: optimise
    [coder encodeObject:modelName forKey:@"modelName"];
    [coder encodeObject:defaultObjectConf forKey:@"defaultObjectConf"];
    [coder encodeObject:_objects forKey:@"objects"];
}

-(void) loadConfigurationFile
{
    NSString* confName = [modelName.stringByDeletingPathExtension stringByAppendingPathExtension:@"txt"];
    NSString* fname = [[NSBundle mainBundle] extendedPathForResource:confName];
    NSString* raw   = [NSString stringWithContentsOfFile:fname encoding:NSUTF8StringEncoding error:nil];
    
    NSString* selectName = nil;
    
    NSMutableArray* parentNameQueue = [NSMutableArray array];
    [parentNameQueue addObject: @""];

    for (NSString* line in [raw componentsSeparatedByString:@"\n"]) {
        
        // preprocess
        NSString* nline = [self fullTrim:line];
        if (nline.length == 0) continue;
        if ([nline hasPrefix:@"//"]) continue;
        if ([nline hasPrefix:@";"] ) continue;

        NSArray* items = [nline componentsSeparatedByString:@" "];
        NSString* objectName = items[0];
        
        // objectConf
        LSObject3DConf* objectConf;
        if ([objectName hasPrefix:@"default"]) { 
            objectConf = defaultObjectConf;
        } else {
            objectConf = (self.objects)[objectName];
            if (!objectConf) {
                objectConf = [defaultObjectConf copy];
                (self.objects)[objectName] = objectConf;
                if ([objectConf.parentName isEqualToString:@""]) objectConf.parentName = nil;
            }
        }

        // commands
        for (int i=1; i<items.count; i++) {
            NSString* command = items[i];
            if ([command hasPrefix:@"select"])    selectName = objectName;
            if ([command hasPrefix:@"-select"])   selectName = nil;
            if ([command hasPrefix:@"instance"])  objectConf.cloneName  = selectName;
            if ([command hasPrefix:@"-instance"]) objectConf.cloneName  = nil;
            
            if ([command hasPrefix:@"parent"])    { objectConf.parentName = parentNameQueue.lastObject; [parentNameQueue addObject:objectName]; }
            if ([command hasPrefix:@"-parent"])   { [parentNameQueue removeLastObject]; objectConf.parentName = parentNameQueue.lastObject; }
            
            if ([command hasPrefix:@"flat"])      objectConf.flat   = TRUE;
            if ([command hasPrefix:@"-flat"])     objectConf.flat   = FALSE;
            if ([command hasPrefix:@"smooth"])    objectConf.flat   = FALSE;
            if ([command hasPrefix:@"-smooth"])   objectConf.flat   = TRUE;
            if ([command hasPrefix:@"delete"])    objectConf.delete = TRUE;
            if ([command hasPrefix:@"-delete"])   objectConf.delete = FALSE;
            if ([command hasPrefix:@"nflip"])     objectConf.nflip  = TRUE;
            if ([command hasPrefix:@"-nflip"])    objectConf.nflip  = FALSE;

            if ([command hasPrefix:@"add"])       objectConf.delete = FALSE;
            if ([command hasPrefix:@"-add"])      objectConf.delete = TRUE;
            if ([command hasPrefix:@"notex"])     objectConf.stripTextures = TRUE;
            if ([command hasPrefix:@"-notex"])    objectConf.stripTextures = FALSE;
            if ([command hasSuffix:@".png"])      objectConf.textureName = command;
            if ([command hasPrefix:@"dshadow"])   objectConf.dshadow = TRUE;
            if ([command hasPrefix:@"-dshadow"])  objectConf.dshadow = FALSE;
            if ([command hasPrefix:@"cshadow"])   objectConf.cshadow = TRUE;
            if ([command hasPrefix:@"-cshadow"])  objectConf.cshadow = FALSE;
            
            if ([command hasPrefix:@"rotate"])   {
                NSArray* params = [[command componentsSeparatedByString:@":"][1] componentsSeparatedByString:@","];
                objectConf.axis = GLKVector3Make(1, 0, 0);
                objectConf.anchor = GLKVector3Make(0.5, 0.5, 0.5);
                objectConf.animated = TRUE;
                objectConf.speed = 1;
                if (params.count > 0) {
                    if ([params[0] isEqualToString:@"x"]) objectConf.axis = GLKVector3Make(1, 0, 0);
                    if ([params[0] isEqualToString:@"y"]) objectConf.axis = GLKVector3Make(0, 1, 0);
                    if ([params[0] isEqualToString:@"z"]) objectConf.axis = GLKVector3Make(0, 0, 1);
                }
                if (params.count > 1) {
                    if ([params[1] isEqualToString:@"c"]) objectConf.anchor = GLKVector3Make(0.5, 0.5, 0.5);
                    if ([params[1] isEqualToString:@"tz"]) objectConf.anchor = GLKVector3Make(0.5, 0.5, 1.0);
                    if ([params[1] isEqualToString:@"ty"]) objectConf.anchor = GLKVector3Make(0.5, 1.0, 0.5);
                }
                if (params.count > 2) {
                    objectConf.speed = [params[2] floatValue];
                }
            }

        }

        if (!objectConf.parentName) objectConf.parentName = parentNameQueue.lastObject;
        
    }
}

-(NSString*) fullTrim:(NSString*)line {
    NSString* nline = [line stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
    while (nline.length && [nline characterAtIndex:0] == ' ')                   nline = [nline substringFromIndex:1];
    while (nline.length && [nline characterAtIndex:nline.length-1] == ' ')    nline = [nline substringToIndex:nline.length-2];
    while (nline.length && [nline rangeOfString:@"  "].location != NSNotFound)  nline = [nline stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    return nline;
}

-(LSObject3DConf*) objectForKey:(NSString*)key {
    LSObject3DConf* objectConf = _objects[key];
    return (objectConf ? objectConf : defaultObjectConf);
}

@end
