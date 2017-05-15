//
//  LSView3D.m
//  miniEngine3D
//
//  Created by Lukasz Sowinski (niman.gosen.en@gmail.com) on 7/20/12.
//  Copyright (c) 2012 Lukasz Sowinski. All rights reserved.
//

#import "LSView3D.h"
#import <QuartzCore/QuartzCore.h>

#import "LSAnimation3D.h"

@implementation LSView3D

static id mainView = nil;

+(id) mainView {
    if (!mainView) {
        mainView = [[self alloc] init];
    }
    return mainView;
}

+(void) destroyView {
    mainView = nil;
}

-(instancetype) init {
    self=[super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.layer.opaque       = TRUE;
        self.contentScaleFactor = 2;
        self.mipmaps            = TRUE;
        self.multisampling      = TRUE;
        self.stripShadows       = true;
        self.stripTextures      = FALSE;
        self.shadowRetina       = TRUE;
        self.shadowDynamic      = TRUE;
        self.debugShadow        = FALSE;
        self.culling            = FALSE;
        self.phong              = TRUE;
        self.perfragment        = FALSE;
        self.animationMode        = kLSAnimationModeSceneRotation;
        self.showfps            = TRUE;
        self.fresnel            = FALSE;
        self.fresnel_param0     = 0.05;
        self.fresnel_param1     = 0.20;
        self.wglow              = FALSE;
        self.bglow              = FALSE;
        self.blending           = FALSE;
        self.lightEnabled       = TRUE;
        self.redLight           = FALSE;
        self.quantify8          = FALSE;
        self.quantify4          = FALSE;
        self.alphadiscard       = FALSE;
        self.globalambient      = FALSE;
        self.bluesky            = TRUE;
        self.hemisphere         = TRUE;
        self.pvrtc              = true;
        self.lightPositionModel = GLKVector3Normalize(GLKVector3Make(1, 1, 0));
    }
    return self;
}

+(Class)layerClass {
    return [CAEAGLLayer class];
}

@end
