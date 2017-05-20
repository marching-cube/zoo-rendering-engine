//
//  ModelViewController.m
//  OjiPark
//
//  Created by Sowinski Lukasz on 8/23/12.
//  Copyright (c) 2012 Lukasz Sowinski (niman.gosen.en@gmail.com). All rights reserved.
//

#import "ModelViewController.h"
#import "LSModel3D.h"
#import "LSAnimation3D.h"
#import "LSView3D.h"

@implementation ModelViewController

-(void)loadView
{
    [super loadView];
    
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, 44);
    UIToolbar* aToolbar = [[UIToolbar alloc] initWithFrame: rect];
    
    NSArray* items = @[[[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(zoomIn:)],
                        [[UIBarButtonItem alloc] initWithTitle:@"-" style:UIBarButtonItemStylePlain target:self action:@selector(zoomOut:)],
                        [[UIBarButtonItem alloc] initWithTitle:@"C" style:UIBarButtonItemStylePlain target:self action:@selector(center:)],
                        [[UIBarButtonItem alloc] initWithTitle:@"GPS" style:UIBarButtonItemStylePlain target:self action:@selector(gps:)],
                        [[UIBarButtonItem alloc] initWithTitle:@"Walk" style:UIBarButtonItemStylePlain target:self action:@selector(walk:)],
                        [[UIBarButtonItem alloc] initWithTitle:@"Demo" style:UIBarButtonItemStylePlain target:self action:@selector(demo:)],
                        [[UIBarButtonItem alloc] initWithTitle:@"X" style:UIBarButtonItemStylePlain target:self action:@selector(close:)]];
    aToolbar.items = items;
    aToolbar.barStyle = UIBarStyleBlackTranslucent;
    [self.view addSubview:aToolbar];
    toolbar = aToolbar;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    toolbar.frame = CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44);
}

-(void)center:(id)sender
{
    model.sceneAnimation.pinchScale = 1;
    model.gyroAnimation.pinchScale  = 1;
    model.sceneAnimation.panTranslation = CGPointZero;
    model.gyroAnimation.panTranslation  = CGPointZero;
}

-(void)zoomIn:(id)sender
{
    model.sceneAnimation.pinchScale = model.sceneAnimation.pinchScale*0.8;
    model.gyroAnimation.pinchScale  = model.gyroAnimation.pinchScale*0.8;
}

-(void)zoomOut:(id)sender
{
    model.sceneAnimation.pinchScale = model.sceneAnimation.pinchScale/0.8;
    model.gyroAnimation.pinchScale  = model.gyroAnimation.pinchScale/0.8;
}

-(void)gps:(id)sender
{
    LSView3D* view = (LSView3D*)self.view;
    view.animationMode = kLSAnimationModeGyro;
}

-(void)walk:(id)sender
{
    LSView3D* view = (LSView3D*)self.view;
    view.animationMode = kLSAnimationModeWalk;
}

-(void)demo:(id)sender
{
    LSView3D* view = (LSView3D*)self.view;
    view.animationMode = kLSAnimationModeSceneRotation;
}

-(void)close:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
