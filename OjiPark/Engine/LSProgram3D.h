//
//  LSProgram3D.h
//  OjiPark
//
//  Created by Sowinski Lukasz on 2/21/13.
//  Copyright (c) 2013 Mouse Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "LSProgram3DAttributes.h"
#import "LSContext3D.h"

@class LSMaterial3D;
@class LSObject3DFragment;
@class LSContext3D;

@interface LSProgram3D : NSObject
{
    NSString* shaderLine;
    
    LSProgram3DAttributes* attributes;
    LSMaterial3D* material;
    __weak LSContext3D* context;
    
    bool shadowOnly;
    
    GLuint primitiveType;
    GLuint verticesPerFace;
    GLuint vbo[2];
    GLuint vao;
    
    GLuint gl_program;
    
    GLuint gl_position;
    GLuint gl_normal;
    GLuint gl_tangent;
    GLuint gl_binormal;
    GLuint gl_uv;
    
    GLuint gl_offset;
    GLuint gl_mvp;
    GLuint gl_mvpl;
    GLuint gl_nm;
    GLuint gl_lpc;
    GLuint gl_lc;

    GLuint gl_diffuse;
    GLuint gl_ambient;
    GLuint gl_specular;
    GLuint gl_specular_exp;
    GLuint gl_fresnel_f0;
    GLuint gl_fresnel_pow;
    GLuint gl_tex0;
    GLuint gl_tex1;
    GLuint gl_tex2;

    GLfloat lpc[3];
    GLfloat lc[3];
    GLfloat nm[9];
    GLfloat mvp[16];
    GLfloat mvpl[16];
    GLfloat offset[4];
    GLfloat diffuse[4];
    GLfloat ambient[4];
    GLfloat specular[4];
    GLfloat specular_exp;
    GLfloat fresnel_f0;
    GLfloat fresnel_pow;
    
    GLuint  btex0;
    GLfloat tex0;
    GLuint  btex1;
    GLfloat tex1;
    GLuint  btex2;
    GLfloat tex2;

}

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *shaderLine;

-(instancetype) init NS_DESIGNATED_INITIALIZER;
-(instancetype) initWithShaderLine:(NSString*)aShaderLine attributes:(LSProgram3DAttributes*)theAttributes context:(LSContext3D*)aContext NS_DESIGNATED_INITIALIZER;

-(void) activate;
-(void) deactivate;

-(void) drawFragment:(LSObject3DFragment*)fragment;
-(void) drawFaces:(int)count offset:(int)foffset;

-(void) loadLightColor:(GLKVector3)lightColor;
-(void) loadLightPositionCamera:(GLKVector3)lightPositionCamera;
-(void) loadNormalMatrix:(GLKMatrix3)normalMatrix;
-(void) loadMVP:(GLKMatrix4)aMvp;
-(void) loadMVPLight:(GLKMatrix4)aMvpl;
-(void) loadOffset:(GLKVector3)aOffset;
-(void) loadMaterial:(LSMaterial3D*)aMaterial;
-(void) loadCubeTexture:(GLuint)texture;

-(void) createBuffersForVertexCount:(int)vertexCount faceCount:(int)faceCount;
-(void) copyVertexData:(GLfloat*)data from:(int)start count:(int)count;
-(void) copyFaceData:(GLushort*)data from:(int)start count:(int)count;
-(void) formatBuffers;
-(void) formatShadowShaderForProgram:(LSProgram3D*)baseProgram;


#pragma mark -
#pragma mark Refactoring

@property (NS_NONATOMIC_IOSONLY, readonly) GLuint gl_program;
@property (NS_NONATOMIC_IOSONLY, readonly) GLuint size;
@property (NS_NONATOMIC_IOSONLY, getter=isActive, readonly) bool active;
@property GLuint primitiveType;

@end
