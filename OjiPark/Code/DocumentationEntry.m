//
//  DocumentationEntry.m
//  OjiPark
//
//  Created by Sowinski Lukasz on 8/30/12.
//  Copyright (c) 2012 Mouse Inc. All rights reserved.
//

#import "DocumentationEntry.h"
#import "NSExtensions.h"

@implementation DocumentationEntry

-(void)loadView {
    NSString* fname = [[NSBundle mainBundle] extendedPathForResource: self.name];
    UITextView* view = [[UITextView alloc] init];
    view.text = [NSString stringWithContentsOfFile:fname encoding:NSUTF8StringEncoding error:nil];
    self.view = view;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:FALSE animated:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:TRUE animated:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
