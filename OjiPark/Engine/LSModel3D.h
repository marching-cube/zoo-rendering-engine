//
//  LSModel3D.h
//  miniEngine3D
//
//  Created by Lukasz Sowinski (niman.gosen.en@gmail.com) on 7/6/12.
//  Copyright (c) 2012 Lukasz Sowinski. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LSContext3D;
@class LSModel3DConf;
@class LSAnimation3DScene;
@class LSAnimation3DLook;
@class LSAnimation3DShadowScene;
@class LSAnimation3DRotation;
@class LSAnimation3DBasic;
@class LSAnimation3DGyro;
@class LSProgram3D;


@interface LSModel3D : NSObject <NSCoding> {
    __strong NSString*          modelName;
    __strong NSMutableArray*    objects;
    __strong NSDictionary*      modelSource;
    __strong LSModel3DConf*     modelConf;
    __weak   LSContext3D*       context;
    
    float update_t;
    
    __strong NSMutableDictionary* textures;
    
    __strong NSMutableDictionary* renderingMap;

}

@property (strong) LSAnimation3DLook*  lookAnimation;
@property (strong) LSAnimation3DScene* sceneAnimation;
@property (strong) LSAnimation3DGyro*  gyroAnimation;
@property (strong) LSAnimation3DShadowScene* shadowSceneAnimation;
@property (strong) LSAnimation3DBasic* switchAnimation;

-(instancetype) init NS_DESIGNATED_INITIALIZER;
-(instancetype) initModelNamed:(NSString*)mname context:(LSContext3D*)aHelper NS_DESIGNATED_INITIALIZER;
-(void) renderObjects:(LSProgram3D*)program;
-(void) renderShadows:(LSProgram3D*)program;
-(void) renderSkybox:(LSProgram3D*)program;
-(void) loadObjects;

-(void) updateAnimations:(NSTimeInterval)t;

@end
