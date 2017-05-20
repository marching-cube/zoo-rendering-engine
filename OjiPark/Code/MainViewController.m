//
//  MainViewController.m
//  OjiPark
//
//  Created by Sowinski Lukasz on 8/10/12.
//  Copyright (c) 2012 Sowinski Lukasz. All rights reserved.
//

#import "MainViewController.h"
#import "LSViewController3D.h"
#import "DeveloperModeViewController.h"
#import "ModelViewController.h"
#import "DocumentationList.h"


@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:TRUE animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)launchOjiParkMap:(id)sender
{
    ModelViewController* viewController = [[ModelViewController alloc] init];
    [viewController loadModelNamed:@"map20130224.obj"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)launchDocumentation:(id)sender
{
    DocumentationList* viewController = [[DocumentationList alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
