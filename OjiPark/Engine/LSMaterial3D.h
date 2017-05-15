//
//  LSMaterial3D.h
//  OjiPark
//
//  Created by Sowinski Lukasz on 1/22/13.
//  Copyright (c) 2013 Mouse Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface LSMaterial3D : NSObject <NSCoding>

@property               NSString*   name;

@property (readonly)    GLKVector4  ambientColorAdjusted;
@property               GLKVector4  ambientColor;
@property               GLfloat     ambientIntensity;
@property (readonly)    GLKVector4  diffuseColorAdjusted;
@property               GLKVector4  diffuseColor;
@property               GLfloat     diffuseIntensity;
@property (readonly)    GLKVector4  specularColorAdjusted;
@property               GLKVector4  specularColor;
@property               GLfloat     specularIntensity;
@property               GLfloat     specularExponent;
@property               int         texture;
@property               int         bumpTexture;

@property NSString*   textureName;
@property NSString*   bumpTextureName;

-(instancetype) init NS_DESIGNATED_INITIALIZER;
-(instancetype) initWithConf:(NSString*)conf NS_DESIGNATED_INITIALIZER;
-(instancetype) initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

@end
