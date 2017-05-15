//
//  LSAnimation3D.m
//  miniEngine3D
//
//  Created by Sowinski Lukasz on 7/27/12.
//  Copyright (c) 2012 Lukasz Sowinski. All rights reserved.
//

#import "LSAnimation3D.h"
#import "LSObject3D.h"
#import "LSView3D.h"
#import <CoreMotion/CoreMotion.h>
#import "NSExtensions.h"

@implementation LSAnimation3DBasic

@synthesize modelViewMatrix;
@synthesize modelViewMatrixProjection;
@synthesize normalMatrix;
@synthesize speed;

+(id) animation {
    return [[self alloc] initAnimationWithParent:nil object:nil];
}

+(id) animationWithParent:(LSAnimation3DBasic*) aParent {
    return [[self alloc] initAnimationWithParent:aParent object:nil];
}

+(id) animationWithParent:(LSAnimation3DBasic*) aParent object:(LSObject3D*) object {
    return [[self alloc] initAnimationWithParent:aParent object:object];
}

-(instancetype) initAnimationWithParent:(LSAnimation3DBasic*) aParent object:(LSObject3D*) aObject {
    self = [super init];
    if (self) {
        parent = aParent;
        object = aObject;
        speed  = 1;
        update_t = -1;
        [self animate:0 inMode:kLSAnimationModeSceneRotation];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)coder
{
    parent = [coder decodeObjectForKey:@"parent"];
    object = [coder decodeObjectForKey:@"object"];
    return [self initAnimationWithParent:parent object:object];
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:parent forKey:@"parent"];
    [coder encodeObject:object forKey:@"object"];
}

-(void) animate:(NSTimeInterval)t inMode:(LSAnimationMode)aMode
{
    if (update_t < t) {
        [self updateAnimation:t];
    }
    if (update_t < t || update_mode != aMode) {
        [parent animate:t inMode:aMode];
        if (parent) {
            modelViewMatrix             = GLKMatrix4Multiply(parent.modelViewMatrix, animationMatrix);
            modelViewMatrixProjection   = GLKMatrix4Multiply(parent.modelViewMatrixProjection, animationMatrix);
        } else {
            modelViewMatrix             = GLKMatrix4Identity; // projection trick
            modelViewMatrixProjection   = animationMatrix;
        }
        normalMatrix                    = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    }
    update_t = t;
    update_mode = aMode;
}

-(void) updateAnimation:(NSTimeInterval)t {
    animationMatrix = GLKMatrix4Identity;
}

@end

@implementation LSAnimation3DModeSwitch

//-(instancetype) initAnimationWithParent:(LSAnimation3DBasic*) aParent object:(LSObject3D*) aObject {
//    printf("error:    You should not initialize %s with %s!\n", [[self class] description].UTF8String, __PRETTY_FUNCTION__);
//    return nil;
//}

+(id) animationWithAnimations:(NSArray*)aanimations {
    return [[self alloc] initAnimationWithAnimations:aanimations];
}

-(instancetype) initAnimationWithAnimations:(NSArray*)aanimations {
    self=[super init];
    if (self) {
        animations = aanimations;
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)coder
{
    self=[super initWithCoder:coder];
    if (self) {
        animations = [coder decodeObjectForKey:@"animations"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:animations forKey:@"animations"];
}

-(void) animate:(NSTimeInterval)t inMode:(LSAnimationMode)aMode {
//    NSLog(@"%d %s %@ %@", aMode, __PRETTY_FUNCTION__, [self class], object.name);
    if (update_t < t || update_mode != aMode) {
        parent = animations[aMode];
        [parent animate:t inMode:aMode];
        modelViewMatrix             = parent.modelViewMatrix;
        modelViewMatrixProjection   = parent.modelViewMatrixProjection;
        normalMatrix                = parent.normalMatrix;
    }
    update_t = t;
    update_mode = aMode;
}

@end

@implementation LSAnimation3DProjection

-(void) updateAnimation:(NSTimeInterval)t {
    float aspect = fabsf(self.view.frame.size.width/self.view.frame.size.height);
    animationMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(35.0f), aspect, 0.1f, 100.0f);
}

@end

@implementation LSAnimation3DScene

@synthesize panTranslation;
@synthesize pinchScale;

-(instancetype) initAnimationWithParent:(LSAnimation3DBasic*) aParent object:(LSObject3D*) aObject {
    self=[super initAnimationWithParent:aParent object:aObject];
    if (self) {
        pinchScale = 1;
    }
    return self;
}


-(void) updateAnimation:(NSTimeInterval)t {
//    t = M_PI_2+M_PI;
    // user pan
    animationMatrix = GLKMatrix4MakeTranslation( panTranslation.x/50.0, -panTranslation.y/50.0, -10+(pinchScale < 1 ? -1/pinchScale : pinchScale));

    // rotate along y axis
//    animationMatrix = GLKMatrix4Translate(animationMatrix, 0, +2.5-2.94029-2, -1.5-1-1-2);
    animationMatrix = GLKMatrix4Translate(animationMatrix, 0, +2.5-2.94029-2, -1.5-1-1-2-5);
    animationMatrix = GLKMatrix4Rotate(animationMatrix, t*speed, 0.0f, 1.0f, 0.0f);
}

@end

@implementation LSAnimation3DLook

@synthesize position;
@synthesize lookAt;

-(instancetype) initAnimationWithParent:(LSAnimation3DBasic*) aParent object:(LSObject3D*) aObject
{
    self=[super initAnimationWithParent:aParent object:aObject];
    if (self) {
        position = GLKVector3Make(2.2, -7.3, 0.2);
        lookAt   = GLKVector3Make(0, 0, -1);
        position = GLKVector3Make(1.3, 0.1, 5.5); // 4.2
    }
    return self;
}


-(void) updateAnimation:(NSTimeInterval)t
{
    if ( self.move   ) position = GLKVector3Add(GLKVector3MultiplyScalar(lookAt, t-stamp), position);
    if ( self.rotate ) lookAt   = GLKMatrix3MultiplyVector3(GLKMatrix3MakeYRotation((t-stamp)*self.rotate*1.5), lookAt);
    
    animationMatrix = GLKMatrix4MakeLookAt( position.x, position.y, position.z,
                                            position.x + lookAt.x, position.y + lookAt.y, position.z + lookAt.z,
                                            0, 1, 0 );
    
    stamp = t;
}

@end


@implementation LSAnimation3DShadowProjection
-(void) updateAnimation:(NSTimeInterval)t {
// TODO: This is only applicable to one model. Generlize!
    const float kScaleX = 2.5*1.5;
    const float kScaleY = 2.9*1.8;
    animationMatrix = GLKMatrix4MakeOrtho(-kScaleX, kScaleX, -kScaleY, kScaleY, 0.1f, 100.0f);
}
@end

@implementation LSAnimation3DShadowScene
-(void) updateAnimation:(NSTimeInterval)t {
// TODO: This is only applicable to one model. Generlize!
    const float kShiftX = 3+2.7;
    const float kShiftY = 5.7;
    const float kShiftZ = 0;
    GLKVector3 lightPositionModel = [[LSView3D mainView] lightPositionModel];
    animationMatrix  = GLKMatrix4MakeLookAt(lightPositionModel.x+kShiftX, lightPositionModel.y+kShiftY, lightPositionModel.z+kShiftZ, kShiftX, kShiftY, kShiftZ, 0, 0, 1);

}
@end

@implementation LSAnimation3DRotation : LSAnimation3DBasic

-(instancetype)initWithCoder:(NSCoder *)coder
{
    self=[super initWithCoder:coder];
    if (self) {
        axis = [coder decodeGLKVector3ForKey:@"axis"];
        anchor = [coder decodeGLKVector3ForKey:@"anchor"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeGLKVector3:axis forKey:@"axis"];
    [coder encodeGLKVector3:anchor forKey:@"anchor"];
}

-(void) defineRotationAxis:(GLKVector3)aAxis anchor:(GLKVector3)aAnchor {
    axis   = aAxis;
    anchor = aAnchor;
}

-(void) updateAnimation:(NSTimeInterval)t
{
    // TODO: these do not have to be obtained every iteration
    GLKVector3 center = GLKVector3Make(object.box0.x*(1-anchor.x) + object.box1.x*anchor.x,
                                       object.box0.y*(1-anchor.y) + object.box1.y*anchor.y,
                                       object.box0.z*(1-anchor.z) + object.box1.z*anchor.z);
    
    GLKVector3 shift = GLKVector3Make(object.offset.x+center.x, object.offset.y+center.y, object.offset.z+center.z);

    animationMatrix = GLKMatrix4Identity;
    animationMatrix = GLKMatrix4Translate(animationMatrix,  shift.x,  shift.y,  shift.z);
    animationMatrix = GLKMatrix4Rotate(animationMatrix, t*speed, axis.x, axis.y, axis.z);
    animationMatrix = GLKMatrix4Translate(animationMatrix, -shift.x, -shift.y, -shift.z);
}

@end

@implementation LSAnimation3DGyro

static CMMotionManager* motionManager = nil;

@synthesize panTranslation;
@synthesize pinchScale;

-(instancetype) initAnimationWithParent:(LSAnimation3DBasic*) aParent object:(LSObject3D*) aObject {
    self=[super initAnimationWithParent:aParent object:aObject];
    if (self) {
        if (!motionManager) {
            motionManager = [[CMMotionManager alloc] init];
            [motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXMagneticNorthZVertical];
            motionManager.showsDeviceMovementDisplay = TRUE;
        }
        pinchScale = 1;
    }
    return self;
}

-(void) updateAnimation:(NSTimeInterval)t {
    
    const float kPassFilter = .1;

    CMAttitude* attitude = motionManager.deviceMotion.attitude;
    
    pitch = (1-kPassFilter)*pitch+kPassFilter*attitude.pitch;
    roll  = (1-kPassFilter)*roll +kPassFilter*attitude.roll;
    yaw   = (1-kPassFilter)*yaw  +kPassFilter*attitude.yaw;

    // TODO: more precise values should be obtained from projections
    animationMatrix = GLKMatrix4MakeTranslation( panTranslation.x/50.0, -panTranslation.y/50.0, -10+(pinchScale < 1 ? -1/pinchScale : pinchScale));

    animationMatrix = GLKMatrix4Rotate(animationMatrix, pitch, -1, 0, 0);
    animationMatrix = GLKMatrix4Rotate(animationMatrix, roll, 0, -1, 0);
    animationMatrix = GLKMatrix4Rotate(animationMatrix, yaw, 0, 0, -1);
    
    animationMatrix = GLKMatrix4Multiply(animationMatrix, GLKMatrix4MakeRotation(M_PI/2, 1, 0, 0));
    
}

@end

@implementation LSAnimation3DClone

-(void) updateAnimation:(NSTimeInterval)t
{
    animationMatrix = GLKMatrix4Identity;
    if (object.cloned) {
        animationMatrix = GLKMatrix4Translate(animationMatrix, object.offset.x, object.offset.y, object.offset.z);
        if (object.cloneScale != 1 || object.cloneRotation != 0) {
            animationMatrix = GLKMatrix4Translate(animationMatrix,  object.cloneRotationOffset.x,  object.cloneRotationOffset.y,  object.cloneRotationOffset.z);
            animationMatrix = GLKMatrix4Rotate(animationMatrix, object.cloneRotation, 0, 1, 0);
            animationMatrix = GLKMatrix4Scale(animationMatrix, object.cloneScale, object.cloneScale, object.cloneScale);
            animationMatrix = GLKMatrix4Translate(animationMatrix, -object.cloneRotationOffset.x, -object.cloneRotationOffset.y, -object.cloneRotationOffset.z);

        }
    }
}

@end


