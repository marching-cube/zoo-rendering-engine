//
//  DeveloperModeViewController.m
//  OjiPark
//
//  Created by Sowinski Lukasz on 8/10/12.
//  Copyright (c) 2012 Sowinski Lukasz. All rights reserved.
//

#import "DeveloperModeViewController.h"
#import "ModelChoiceViewController.h"
#import "LSViewController3D.h"
#import "LSView3D.h"
#import "ModelViewController.h"
#import "LSAnimation3D.h"
#import "NSExtensions.h"

@implementation DeveloperModeViewController
@synthesize tableView;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        NSString* fname = [[NSBundle mainBundle] extendedPathForResource:@"devoptions.txt"];
        NSString* conf = [NSString stringWithContentsOfFile:fname encoding:NSUTF8StringEncoding error:nil];
        
        NSMutableArray* options;
        sectionNames = [NSMutableArray array];
        sections = [NSMutableArray array];
        optionMap = [NSMutableDictionary dictionary];
        
        DeveloperModeOption* prevOption = nil;
        
        for (NSString* line in [conf componentsSeparatedByString:@"\n"]) {
            if (line.length < 2) continue;
            NSString* nline = [line stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];;
            while ([nline rangeOfString:@"\t\t"].location != NSNotFound) {
                nline = [nline stringByReplacingOccurrencesOfString:@"\t\t" withString:@"\t"];
            }
            NSArray* components = [nline componentsSeparatedByString:@"\t"];
            if (components.count < 2) {
                options = [NSMutableArray array];
                [sectionNames addObject:nline];
                [sections addObject: options];
                prevOption = nil;
                continue;
            }
            DeveloperModeOption* option = [[DeveloperModeOption alloc] init];
            option.name = components[0];
            option.key  = components[1];
            option.defaultState = [components[2] floatValue];
            for (int i=3; i<components.count; i++) {
                NSString* param = components[i];
                // TYPE
                if ([param hasPrefix:@"%"]) {
                    param = [param substringFromIndex:1];
                    if ([param isEqualToString:@"A"]) { option.type = kOptionTypeModel; }
                    else if ([param isEqualToString:@"B"]) { option.type = kOptionTypeCustom; }
                    else if ([param isEqualToString:@"f"]) { option.type = kOptionTypeFloat; }
                }
                // OPTIONAL
                if ([param hasPrefix:@"o"]) {
                    option.optional =  (prevOption && prevOption.optional == nil ? prevOption : prevOption.optional);
                    ((DeveloperModeOption*)option.optional).type = kOptionTypeBoolWithSuboptions;
                }
                // EXCLUSIVE
                if ([param hasPrefix:@"e"]) {
                    option.exclusive = option;
                    if ( prevOption && prevOption.exclusive) {
                        option.exclusive = prevOption;
                        DeveloperModeOption* ref = prevOption;
                        while (prevOption != ref.exclusive) ref = ref.exclusive;
                        ref.exclusive = option;
                    }
                }
            }
            [option load];
            [options addObject:option];
            optionMap[option.key] = option;
            prevOption = option;
            

        }
        
        modelName = [[NSUserDefaults standardUserDefaults] stringForKey:@"ojipark.developer.model"];
        if (modelName == nil || modelName.length == 0) modelName = @"ball.obj";
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)launchChooseModel:(id)sender
{
    ModelChoiceViewController* viewController = [[ModelChoiceViewController alloc] init];
    viewController.delegate = self;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)launchModel:(id)sender
{
    LSView3D* view = [LSView3D mainView];
    view.animationMode = kLSAnimationModeSceneRotation;

    if (((DeveloperModeOption*)optionMap[@"ojipark.developer.customsettings"]).state) {
        view.multisampling  =  ((DeveloperModeOption*)optionMap[@"ojipark.developer.multisampling"]).state;
        view.mipmaps        =  ((DeveloperModeOption*)optionMap[@"ojipark.developer.mipmaps"]).state;
        view.stripShadows   =  ((DeveloperModeOption*)optionMap[@"ojipark.developer.stripshadows"]).state;
        view.stripTextures  =  ((DeveloperModeOption*)optionMap[@"ojipark.developer.striptextures"]).state;
        view.culling        =  ((DeveloperModeOption*)optionMap[@"ojipark.developer.culling"]).state;
        view.phong          =  ((DeveloperModeOption*)optionMap[@"ojipark.developer.phong"]).state;
        view.perfragment    =  ((DeveloperModeOption*)optionMap[@"ojipark.developer.perfragment"]).state;
        view.debugShadow    =  ((DeveloperModeOption*)optionMap[@"ojipark.developer.debugshadow"]).state;
        view.showfps        =  ((DeveloperModeOption*)optionMap[@"ojipark.developer.showfps"]).state;
        view.fresnel        =  ((DeveloperModeOption*)optionMap[@"ojipark.developer.fresnel"]).state;
        view.fresnel_param0 =  ((DeveloperModeOption*)optionMap[@"ojipark.developer.fresnel.param0"]).state;
        view.fresnel_param1 =  ((DeveloperModeOption*)optionMap[@"ojipark.developer.fresnel.param1"]).state;
        view.wglow          =  ((DeveloperModeOption*)optionMap[@"ojipark.developer.whiteglow"]).state;
        view.bglow          =  ((DeveloperModeOption*)optionMap[@"ojipark.developer.blackglow"]).state;
        view.blending       =  ((DeveloperModeOption*)optionMap[@"ojipark.developer.blending"]).state;
        view.lightEnabled   =  ((DeveloperModeOption*)optionMap[@"ojipark.developer.lightenabled"]).state;
        view.redLight       =  ((DeveloperModeOption*)optionMap[@"ojipark.developer.redlight"]).state;
        view.bluesky        =  ((DeveloperModeOption*)optionMap[@"ojipark.developer.bluesky"]).state;
        view.quantify8      =  ((DeveloperModeOption*)optionMap[@"ojipark.developer.quantify8"]).state;
        view.quantify4      =  ((DeveloperModeOption*)optionMap[@"ojipark.developer.quantify4"]).state;
        view.alphadiscard   =  ((DeveloperModeOption*)optionMap[@"ojipark.developer.alphadiscard"]).state;
        view.globalambient  =  ((DeveloperModeOption*)optionMap[@"ojipark.developer.globalambient"]).state;
        view.hemisphere     =  ((DeveloperModeOption*)optionMap[@"ojipark.developer.hemisphere"]).state;
        view.pvrtc          =  ((DeveloperModeOption*)optionMap[@"ojipark.developer.pvrtc"]).state;
        if (((DeveloperModeOption*)optionMap[@"ojipark.developer.sunposition"]).state) {
            view.lightPositionModel = GLKVector3Normalize(GLKVector3Make(0, 1, 0));
        } else {
            view.lightPositionModel = GLKVector3Normalize(GLKVector3Make(1, 1, 0));
        }
    }
    
    // TODO: more shadows params
    // TODO: shadow retina / shadow dynamic
    ModelViewController* viewController = [[ModelViewController alloc] init];
    [viewController loadModelNamed:modelName];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)resetOptions:(id)sender {
    for (int i=1; i<sections.count; i++) {
        for (DeveloperModeOption* option in sections[i]) {
            option.state = option.defaultState;
            [option save];
        }
    }
    [tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, sections.count-1)]
             withRowAnimation:UITableViewRowAnimationBottom];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (((DeveloperModeOption*)optionMap[@"ojipark.developer.customsettings"]).state) {
        return sectionNames.count;
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return sectionNames[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 0;
    for (DeveloperModeOption* option in sections[section]) {
        count += (option.optional == nil || ((DeveloperModeOption*)option.optional).state != 0);
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    int idx=0, i=0;
    while (idx <= indexPath.row) {
        DeveloperModeOption* option = (DeveloperModeOption*)sections[indexPath.section][i];
        if (option.optional == nil || ((DeveloperModeOption*)option.optional).state != 0) idx++;
        i++;
    }
    i--;

    DeveloperModeOption* option = (DeveloperModeOption*)sections[indexPath.section][i];
    UITableViewCell* cell;
    
    if (option.type == kOptionTypeBool || option.type == kOptionTypeBoolWithSuboptions || option.type == kOptionTypeCustom) {
        NSString* identifier = @"Cell0";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.accessoryView = [[UISwitch alloc] init];
            [(UISwitch*)cell.accessoryView addTarget:self action:@selector(switchFlipped:) forControlEvents: UIControlEventValueChanged];
        }
        
        cell.textLabel.text = option.name;
        cell.accessoryView.tag = i + 1000*indexPath.section;
        ((UISwitch*)cell.accessoryView).on = option.state;
        
    }
    
    if (option.type == kOptionTypeFloat) {
        NSString* identifier = @"Cell1";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.accessoryView = [[UISlider alloc] init];
            [(UISlider*)cell.accessoryView addTarget:self action:@selector(sliderAdjusted:) forControlEvents: UIControlEventValueChanged];
            [(UISlider*)cell.accessoryView setContinuous: YES];
            UILabel* label = [[UILabel alloc] initWithFrame: CGRectMake(150, 8, 50, 23)];
            label.textAlignment = UITextAlignmentRight;
            label.backgroundColor = [UIColor clearColor];
            label.text = @"100%";
            label.tag = 10;
            [cell addSubview:label];
        }
        
        UILabel* label = (UILabel*)[cell viewWithTag:10];
        cell.textLabel.text = option.name;
        cell.accessoryView.tag = i + 1000*indexPath.section;
        ((UISlider*)cell.accessoryView).value = option.state;
        label.text = [NSString stringWithFormat:@"%d%%", (int)(((UISlider*)cell.accessoryView).value*100)];
    }
    
    if (option.type == kOptionTypeModel) {
        NSString* identifier = @"Cell2";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.accessoryView = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        }
        
        UIButton* btn = (UIButton*)cell.accessoryView;
        btn.frame = CGRectMake(0, 0, 150, 30);
        [btn removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(launchChooseModel:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle: modelName forState:UIControlStateNormal];
        cell.textLabel.text = option.name;

    }
    
    if (cell == NULL) {
        @throw @"Incorrect setup";
    }
    
    return cell;

}

-(void) switchFlipped:(UISwitch*)sender
{
    DeveloperModeOption* option = sections[sender.tag/1000][sender.tag%1000];
    option.state = sender.on;
    [option save];
    
    bool exclusion = FALSE;
    if (option.exclusive) {
        DeveloperModeOption* ref = option.exclusive;
        while (ref != option) {
            ref.state = FALSE;
            [ref save];
            ref = ref.exclusive;
            exclusion = TRUE;
        }
    }
        
    if (option.type == kOptionTypeCustom || option.type == kOptionTypeBoolWithSuboptions || exclusion) [tableView reloadData];
}

-(void) sliderAdjusted:(UISlider*)slider {
    DeveloperModeOption* option = sections[slider.tag/1000][slider.tag%1000];
    option.state = slider.value;
    [option save];

    UIView* parent = slider.superview ;
    for (UIView* view in parent.subviews) {
        if ([view isMemberOfClass:[UILabel class]]) {
            UILabel* label = (UILabel*)view;
            label.text = [NSString stringWithFormat:@"%d%%", (int)(slider.value*100)];
            break;
        }
    }
}

-(void) updateModelName:(NSString*)newModelName
{
    modelName = newModelName;
    [[NSUserDefaults standardUserDefaults] setObject:modelName forKey:@"ojipark.developer.model"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [tableView reloadData];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end


@implementation DeveloperModeOption

-(instancetype) init {
    self=[super init];
    if (self) {
        self.type       = kOptionTypeBool;
        self.optional   = nil;
        self.exclusive  = nil;
    }
    return self;
}

-(void) load
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:self.key]) {
        self.state = [[NSUserDefaults standardUserDefaults] floatForKey:self.key];
    } else {
        self.state = self.defaultState;
    }
}

-(void) save
{
    [[NSUserDefaults standardUserDefaults] setFloat:self.state  forKey:self.key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
