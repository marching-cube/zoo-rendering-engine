//
//  LSAnimation3D.h
//  miniEngine3D
//
//  Created by Sowinski Lukasz on 7/27/12.
//  Copyright (c) 2012 Lukasz Sowinski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
@class  LSObject3D;

typedef NS_ENUM(unsigned int, LSAnimationMode) {
    kLSAnimationModeSceneRotation,
    kLSAnimationModeWalk,
    kLSAnimationModeGyro,
    kLSAnimationModeShadow
};

@interface LSAnimation3DBasic : NSObject <NSCoding> {
    NSTimeInterval                update_t;
    LSAnimationMode               update_mode;
    __strong LSAnimation3DBasic*  parent;
    __weak LSObject3D*            object;
    
    GLKMatrix4 modelViewMatrix;
    GLKMatrix4 modelViewMatrixProjection;
    GLKMatrix3 normalMatrix;
    
    GLKMatrix4 animationMatrix;
    
    NSTimeInterval speed;
    
}

@property GLKMatrix4 modelViewMatrix;
@property GLKMatrix4 modelViewMatrixProjection;
@property GLKMatrix3 normalMatrix;
@property NSTimeInterval speed;

+(id) animationWithParent:(LSAnimation3DBasic*) aParent object:(LSObject3D*) object;
+(id) animationWithParent:(LSAnimation3DBasic*) aParent;
+(id) animation;

-(void) animate:(NSTimeInterval)t inMode:(LSAnimationMode)aMode;

@end

@interface LSAnimation3DModeSwitch : LSAnimation3DBasic {
    NSArray* animations;
}
+(id) animationWithAnimations:(NSArray*)aanimations;
-(instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;
-(instancetype) initAnimationWithAnimations:(NSArray*)aanimations NS_DESIGNATED_INITIALIZER;
@end

@interface LSAnimation3DProjection : LSAnimation3DBasic
@property (weak) UIView* view;
@end

@interface LSAnimation3DScene : LSAnimation3DBasic
@property CGPoint panTranslation;
@property CGFloat pinchScale;
@end

@interface LSAnimation3DLook : LSAnimation3DBasic {
    float stamp;
}

@property GLKVector3 position;
@property GLKVector3 lookAt;
@property bool move;
@property int  rotate;
@end

@interface LSAnimation3DShadowProjection : LSAnimation3DBasic
@end

@interface LSAnimation3DShadowScene : LSAnimation3DBasic
@end

@interface LSAnimation3DRotation : LSAnimation3DBasic {
    GLKVector3 axis;
    GLKVector3 anchor;
}

-(void) defineRotationAxis:(GLKVector3)aAxis anchor:(GLKVector3)aAnchor;

@end

@interface LSAnimation3DGyro : LSAnimation3DBasic {
    float pitch, roll, yaw;
}
@property CGPoint panTranslation;
@property CGFloat pinchScale;
@end

@interface LSAnimation3DClone : LSAnimation3DBasic
@end
