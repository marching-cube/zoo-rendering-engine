//
//  LSView3D.h
//  miniEngine3D
//
//  Created by Lukasz Sowinski (niman.gosen.en@gmail.com) on 7/20/12.
//  Copyright (c) 2012 Lukasz Sowinski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface LSView3D : UIView

@property bool  multisampling;
@property bool  mipmaps;
@property bool  stripShadows;
@property bool  stripTextures;
@property bool  shadowRetina;
@property bool  shadowDynamic;
@property bool  debugShadow;
@property bool  culling;
@property bool  phong;
@property bool  perfragment;
@property int   animationMode;
@property bool  showfps;
@property GLKVector3 lightPositionModel;

@property bool  lightEnabled;
@property bool  redLight;
@property bool  bluesky;

@property bool  quantify8;
@property bool  quantify4;
@property bool  alphadiscard;

@property bool  blending;
@property bool  globalambient;

// per sampler settings
@property bool  fresnel;
@property float fresnel_param0;
@property float fresnel_param1;

@property bool  wglow;
@property bool  bglow;

@property bool  hemisphere;
@property bool  pvrtc;

+(id) mainView;
+(void) destroyView;

@end
