//
//  LSModel3DConf.h
//  miniEngine3D
//
//  Created by Lukasz Sowinski (niman.gosen.en@gmail.com) on 7/12/12.
//  Copyright (c) 2012 Lukasz Sowinski. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LSObject3DConf;

@interface LSModel3DConf : NSObject <NSCoding> {
    __strong NSString*              modelName;
    __strong LSObject3DConf*        defaultObjectConf;
}

-(instancetype) init NS_DESIGNATED_INITIALIZER;
-(instancetype) initWithModelName:(NSString*)aModelName NS_DESIGNATED_INITIALIZER;
-(LSObject3DConf*) objectForKey:(NSString*)key;

@property (readonly) NSMutableDictionary*   objects;

@end
