//
//  LSHelper3D.h
//  miniEngine3D
//
//  Created by Lukasz Sowinski (niman.gosen.en@gmail.com) on 7/4/12.
//  Copyright (c) 2012 Lukasz Sowinski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class LSView3D;
@class LSProgram3D;
@class LSProgram3DAttributes;

@interface LSContext3D : NSObject
{
    GLuint  framebuffer;
    GLuint  colorbuffer;
    GLuint  depthbuffer;
    GLuint  resolveFramebuffer;
    GLuint  resolveColorbuffer;
    GLuint  shadowFramebuffer;

    NSMutableDictionary* programs;
    NSMutableDictionary* shadowPrograms;
    LSProgram3D*         skyboxProgram;

    GLuint  shadowTexture;

    GLuint* texture;
    GLuint  textureCount;
    
    GLuint b_readFramebuffer;
}

-(void) activateContext;
-(void) deactivateContext;

-(void) createDefaultFramebufferWithView:(LSView3D*)view;
-(void) createMultisamplingFramebufferWithView:(LSView3D*)view;
-(void) createShadowFramebufferWithView:(LSView3D*)view;

-(void) resolveMultisampling;
-(void) discardBuffers;
-(void) presentFrame;


-(LSProgram3D*) programForShader:(NSString*)shaderLine;
-(LSProgram3D*) programForShader:(NSString*)shaderLine attributes:(LSProgram3DAttributes*)attributes;
-(LSProgram3D*) shadowProgramForProgram:(LSProgram3D*)program;
-(GLuint) createImageTexture:(NSString*)name;
-(GLuint) createCubeTexture:(NSString*)name;

@property GLuint  framebuffer;
@property GLuint  colorbuffer;
@property GLuint  depthbuffer;
@property GLuint  resolveFramebuffer;
@property GLuint  resolveColorbuffer;
@property GLuint  shadowFramebuffer;
@property GLuint  shadowTexture;

@property (weak)  LSProgram3D*  activeProgram;

@property GLuint* texture;
@property GLuint  textureCount;

@property (strong) EAGLContext* egl_context;

#pragma mark -
#pragma mark Refactoring

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *programs;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *shadowPrograms;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *shadowProgramKeys; // TODO: not so happy here
-(void) activateProgram:(LSProgram3D*)program;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) LSProgram3D *skyboxProgram;

@end
