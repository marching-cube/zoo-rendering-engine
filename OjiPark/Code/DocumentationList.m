//
//  DocumentationList.m
//  OjiPark
//
//  Created by Sowinski Lukasz on 8/26/12.
//  Copyright (c) 2012 Mouse Inc. All rights reserved.
//

#import "DocumentationList.h"
#import "DocumentationEntry.h"

@interface DocumentationList ()

@end

@implementation DocumentationList

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadView {
    UITableView* view = [[UITableView alloc] init];
    view.dataSource = self;
    view.delegate = self;
    self.view = view;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:FALSE animated:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:TRUE animated:animated];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) cell = [[UITableViewCell alloc] init];
    
    if (indexPath.row == 0) cell.textLabel.text = @"Model configuration files";
    if (indexPath.row == 1) cell.textLabel.text = @"Shader compilation";
    if (indexPath.row == 2) cell.textLabel.text = @"Comments";
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* name;
    if (indexPath.row == 0) name = @"doc.config.txt";
    if (indexPath.row == 1) name = @"doc.shader.txt";
    if (indexPath.row == 2) name = @"doc.comments.txt";
    DocumentationEntry* entry = [[DocumentationEntry alloc] init];
    entry.name = name;
    [self.navigationController pushViewController:entry animated:YES];
}

@end
