//
//  LSViewController3D.h
//  miniEngine3D
//
//  Created by Lukasz Sowinski (niman.gosen.en@gmail.com) on 7/4/12.
//  Copyright (c) 2012 Lukasz Sowinski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@class LSModel3D;
@class LSContext3D;

@interface LSViewController3D : UIViewController  {
    
    __weak   CADisplayLink* displayLink;
    __strong LSModel3D* model;
    __strong LSContext3D* context;
    double _rotation;
    
    CGPoint panTranslationBackup;
    float   pinchScaleBackup;
    
    bool    shadowWasRendered;
    
    __strong UILabel* fpsLabel;
    
    uint64_t measurementTime;
    uint64_t startTime;
    uint64_t endTime;
    float    performance;
    int      performanceSkipCounter;
    double   mach_multiplier;
    
    CGSize   viewPort;
    
}

@property CFTimeInterval updateTimestamp;

-(void) loadModelNamed:(NSString*)mname;

//-(instancetype) initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;
//-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_DESIGNATED_INITIALIZER;
//-(instancetype) initWithModelNamed:(NSString*)mname NS_DESIGNATED_INITIALIZER;

@end
