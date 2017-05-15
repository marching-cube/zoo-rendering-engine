//
//  LSObject3DConf.h
//  miniEngine3D
//
//  Created by Lukasz Sowinski (niman.gosen.en@gmail.com) on 7/22/12.
//  Copyright (c) 2012 Lukasz Sowinski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface LSObject3DConf : NSObject <NSCoding>

@property           bool        flat;
@property           bool        delete;
@property           bool        nflip;
@property           bool        stripTextures;
@property (strong)  NSString*   cloneName;
@property (strong)  NSString*   parentName;
@property (strong)  NSString*   textureName;
@property           bool        dshadow;
@property           bool        cshadow;

@property           bool        animated;
@property           GLKVector3  anchor;
@property           GLKVector3  axis;
@property           float       speed;

-(void) copyContents:(LSObject3DConf*)conf;

@end