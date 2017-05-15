//
//  ModelChoiceViewController.m
//  OjiPark
//
//  Created by Sowinski Lukasz on 8/10/12.
//  Copyright (c) 2012 Sowinski Lukasz. All rights reserved.
//

#import "ModelChoiceViewController.h"
#import "DeveloperModeViewController.h"

@interface ModelChoiceViewController () {
    NSArray* models;
}

@end

@implementation ModelChoiceViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        NSString *bundleRoot = [NSBundle mainBundle].bundlePath;
        NSArray *dirContents1 = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundleRoot error:nil];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *documentRoot = paths[0];
        NSArray *dirContents2 = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentRoot error:nil];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(self like  %@)", @"*.obj"];
        models = [[dirContents1 arrayByAddingObjectsFromArray:dirContents2] filteredArrayUsingPredicate:predicate];
        
        self.title = @"Documentation list";
    }
    return self;
}

-(void)loadView
{
    UITableView* view = [[UITableView alloc] init];
    view.delegate = self;
    view.dataSource = self;
    self.view = view;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self.navigationController setNavigationBarHidden:FALSE animated:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:TRUE animated:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return models.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = models[indexPath.row];

    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate updateModelName: models[indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
