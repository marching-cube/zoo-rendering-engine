//
//  DeveloperModeViewController.h
//  OjiPark
//
//  Created by Sowinski Lukasz on 8/10/12.
//  Copyright (c) 2012 Sowinski Lukasz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(unsigned int, LSOptionType) {
    kOptionTypeNone                 = 0,
    kOptionTypeModel                = -1,
    kOptionTypeCustom               = -2,
    kOptionTypeBool                 = 1,
    kOptionTypeBoolWithSuboptions   = 2,
    kOptionTypeFloat                = 3
    
};

@interface DeveloperModeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    __strong NSMutableArray* sections;
    __strong NSMutableArray* sectionNames;
    __strong NSMutableDictionary* optionMap;
    __strong UITextField *detailedOptionField;
    __weak   UISwitch    *detailedOptionSwitch;
    __strong NSString*    modelName;
}

- (IBAction)launchChooseModel:(id)sender;
- (IBAction)launchModel:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)resetOptions:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

-(void) updateModelName:(NSString*)newModelName;

@end


@interface DeveloperModeOption : NSObject

@property (strong) NSString*          name;
@property (strong) NSString*          key;
@property               float         defaultState;
@property               float         state;
@property               LSOptionType  type;
@property (weak)        id            optional;
@property (weak)        id            exclusive;

-(void) load;
-(void) save;

@end
