//
//  LSViewController3D.m
//  miniEngine3D
//
//  Created by Lukasz Sowinski (niman.gosen.en@gmail.com) on 7/4/12.
//  Copyright (c) 2012 Lukasz Sowinski. All rights reserved.
//

#import "LSViewController3D.h"
#import "LSContext3D.h"
#import "LSModel3D.h"
#import "LSView3D.h"
#import "LSAnimation3D.h"
#import "LSProgram3D.h"

#include <mach/mach_time.h>

@interface LSViewController3D ()

@end

@implementation LSViewController3D

//- (instancetype)initWithCoder:(NSCoder *)coder
//{
//    return [super initWithCoder:coder];
//}
//
//-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//}
//
//-(instancetype) initWithModelNamed:(NSString*)mname
//{
//    self = [super initWithCoder:nil];
//    if (self) {
//        context = [[LSContext3D alloc] init];
//        model  = [[LSModel3D alloc] initModelNamed:mname context:context];
//        mach_timebase_info_data_t info;
//        mach_timebase_info(&info);
//        mach_multiplier = (double)info.numer / (double)info.denom / 1000000;
//    }
//    return self;
//}

-(void) loadModelNamed:(NSString*)mname {
    context = [[LSContext3D alloc] init];
    model  = [[LSModel3D alloc] initModelNamed:mname context:context];
    mach_timebase_info_data_t info;
    mach_timebase_info(&info);
    mach_multiplier = (double)info.numer / (double)info.denom / 1000000;
}

-(void) loadView
{
    self.view = [LSView3D mainView];
    if ([[LSView3D mainView] showfps]) {
        fpsLabel = [[UILabel alloc] init];
        fpsLabel.backgroundColor = [UIColor clearColor];
        fpsLabel.text = @"000fps";
        [fpsLabel sizeToFit];
        [self.view addSubview:fpsLabel];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [context activateContext];
    
    LSView3D* view = (LSView3D*)self.view;
    
    [view addGestureRecognizer: [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)]];
    [view addGestureRecognizer: [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)]];

    [self setupGL];
}

-(void) pan:(UIPanGestureRecognizer*) panRecognizer
{
    CGPoint translation = [panRecognizer translationInView:self.view];
    if (panRecognizer.state == UIGestureRecognizerStateBegan) {
        panTranslationBackup = model.sceneAnimation.panTranslation;
    }
    model.sceneAnimation.panTranslation = CGPointMake(panTranslationBackup.x+translation.x, panTranslationBackup.y+translation.y);
    model.gyroAnimation.panTranslation  = model.sceneAnimation.panTranslation;
}

-(void) pinch:(UIPinchGestureRecognizer*)pinchRecognizer
{
    float scale = pinchRecognizer.scale;
    if (pinchRecognizer.state == UIGestureRecognizerStateBegan) {
        pinchScaleBackup = model.sceneAnimation.pinchScale;
    }
    model.sceneAnimation.pinchScale = pinchScaleBackup * scale;
    model.gyroAnimation.pinchScale  = model.sceneAnimation.pinchScale;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self analyzeTouch: [touches anyObject]];
}

-(GLKVector3) touchPointToModel:(CGPoint)point
{
    GLKVector2 p = GLKVector2Make(-1+2*point.x/self.view.bounds.size.width, 1-2*point.y/self.view.bounds.size.height);
    
    GLKMatrix4 m = GLKMatrix4Invert(model.switchAnimation.modelViewMatrixProjection, nil);
    
    GLKVector4 v0 = GLKMatrix4MultiplyVector4(m, GLKVector4Make(p.x, p.y, -1, 1));
    GLKVector4 v1 = GLKMatrix4MultiplyVector4(m, GLKVector4Make(p.x, p.y,  0, 1));
    
    GLKVector3 w0 = GLKVector3Make(v0.x/v0.w, v0.y/v0.w, v0.z/v0.w);
    GLKVector3 w1 = GLKVector3Make(v1.x/v1.w, v1.y/v1.w, v1.z/v1.w);
    
    GLKVector3 d = GLKVector3Subtract(w1, w0);

    return GLKVector3Subtract(w0, GLKVector3MultiplyScalar(d, w0.y/d.y));
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    model.lookAnimation.rotate = false;
    model.lookAnimation.move = false;
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    model.lookAnimation.rotate = false;
    model.lookAnimation.move = false;
}

-(void) analyzeTouch:(UITouch*)touch
{
    CGPoint point = [touch locationInView:self.view];
    
    model.lookAnimation.rotate = false;
    
    if (point.x <  self.view.bounds.size.width/3) {
        model.lookAnimation.rotate = +1;
    } else  if (point.x > 2*self.view.bounds.size.width/3){
        model.lookAnimation.rotate = -1;
    } else {
        model.lookAnimation.move = true;
    }
}

-(void)viewDidUnload
{
    [super viewDidUnload];
    [self tearDownGL];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self tearDownGL];
    self.view = nil;
    [LSView3D destroyView]; // TODO: this restarts parameters
}

- (void)setupGL
{
    glEnable(GL_DEPTH_TEST);
    if ([[LSView3D mainView] blending]) {
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glEnable(GL_BLEND);
    }
    
    viewPort = self.view.frame.size;
    glViewport(0, 0, viewPort.width*self.view.contentScaleFactor, viewPort.height*self.view.contentScaleFactor);
    
    if ([[LSView3D mainView] culling]) {
        glEnable(GL_CULL_FACE);
    } else {
        glDisable(GL_CULL_FACE);
    }

    [context activateContext];
    
    // framebuffers
    if (((LSView3D*)self.view).multisampling) {
        [context createMultisamplingFramebufferWithView: (LSView3D*)self.view];
    } else {
        [context createDefaultFramebufferWithView: (LSView3D*)self.view];
    }
    if (!((LSView3D*)self.view).stripShadows) {
        [context createShadowFramebufferWithView:(LSView3D*)self.view];
    }
    
    [model  loadObjects];
    
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawFrame:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

}

- (void)tearDownGL
{
    context = nil;
    [displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)updateAnimation
{
    [model updateAnimations:_rotation];
    
    _rotation += MIN(displayLink.timestamp-_updateTimestamp, 1) * 0.5f;
    _updateTimestamp = displayLink.timestamp;
    
}


- (void)drawFrame:(id)sender
{
//    [self performanceMeasurementStart];
    
    [self updateAnimation];
    
    [self renderShadowTexture];
    [self renderScreenFrame];
    
    [context resolveMultisampling];
    [context discardBuffers];
    [context presentFrame];
    
//    [self performanceMeasurementEnd];
}

- (GLKVector3)lightColor
{
    GLKVector3 lightColor;
    if ([[LSView3D mainView] lightEnabled]) {
        if ([[LSView3D mainView] redLight]) {
            lightColor = GLKVector3Make(1, .75, .75);
        } else {
            lightColor = GLKVector3Make(1, 1, 1);
        }
    } else {
        lightColor = GLKVector3Make(0, 0, 0);
    }
    return lightColor;
}

-(void) renderScreenFrame
{
    glBindFramebuffer(GL_FRAMEBUFFER, context.framebuffer);
    
    // TODO: this should be moved to setup, but shadows clear their own red color
    if ([[LSView3D mainView] bluesky]) {
        glClearColor(135.0/255, 206.0/255, 250.0/255, 1.0f);
    } else {
        glClearColor(0.0/255, 0.0/255, 0.0/255, 1.0f);
    }
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
//    if ([[LSView3D mainView] shadowRetina]) {
//        glViewport(0, 0, viewPort.width*self.view.contentScaleFactor, viewPort.height*self.view.contentScaleFactor);
//    }

    for (LSProgram3D* program in context.programs) {
        
        [context activateProgram: program];
        
        LSAnimationMode mode = [[LSView3D mainView] animationMode];
        [model.switchAnimation animate:_rotation inMode: mode];

        GLKVector3 lightPositionCamera = GLKVector3Normalize(GLKMatrix3MultiplyVector3(model.switchAnimation.normalMatrix, [[LSView3D mainView] lightPositionModel]));
        [context.activeProgram loadLightPositionCamera: lightPositionCamera];

// TODO: This should be dropped for non debugging
        [context.activeProgram loadLightColor:[self lightColor]];
        
        [model renderObjects: program];
    }
    
    [context activateProgram: context.skyboxProgram];
    [model renderSkybox: context.skyboxProgram];

//    glDisable(GL_DEPTH_TEST);
//    glBindVertexArrayOES(0);
}

-(void) renderShadowTexture
{
    
    if (![[LSView3D mainView] shadowDynamic] && shadowWasRendered) return;
    if ( [[LSView3D mainView] stripShadows]) return;
    
    glDisable(GL_DEPTH_TEST);
    
    glBindFramebuffer(GL_FRAMEBUFFER, context.shadowFramebuffer);

    // TODO: why is this red?
    glClearColor(1.0, 0.0, 0.0, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
//    if ([[LSView3D mainView] shadowRetina]) {
//        glViewport(0, 0, 2*viewPort.width, 2*viewPort.height);
//    }
    
    for (LSProgram3D* program in context.shadowPrograms) {
        [context activateProgram: program];
        [model renderShadows:program];
    }
    
    shadowWasRendered = TRUE;
    
//    glBindVertexArrayOES(0);
    
    glEnable(GL_DEPTH_TEST);
    
    // TODO: discard dynamic shadows?

}

-(void) performanceMeasurementStart
{
    if (![[LSView3D mainView] showfps]) return;
    startTime = mach_absolute_time();
}

-(void) performanceMeasurementEnd
{
    if (![[LSView3D mainView] showfps]) return;
    glFinish();
    endTime = mach_absolute_time();
    if ((endTime-measurementTime)*mach_multiplier < 250) return;
    double elapsed = (endTime - startTime) * mach_multiplier;
    fpsLabel.text = [NSString stringWithFormat:@"%03dfps", (int)(1000/elapsed)];
    measurementTime = startTime;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return true;
}

@end



