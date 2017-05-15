//
//  LSContext3D
//  miniEngine3D
//
//  Created by Lukasz Sowinski (niman.gosen.en@gmail.com) on 7/4/12.
//  Copyright (c) 2012 Lukasz Sowinski. All rights reserved.
//

#import "LSContext3D.h"
#import "LSView3D.h"
#import "LSProgram3D.h"
#import "NSExtensions.h"

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

@implementation LSContext3D

@synthesize framebuffer;
@synthesize colorbuffer;
@synthesize depthbuffer;
@synthesize resolveFramebuffer;
@synthesize resolveColorbuffer;
@synthesize shadowFramebuffer;
@synthesize shadowTexture;

@synthesize activeProgram;
@synthesize texture;
@synthesize textureCount;

-(instancetype) init
{
    self=[super init];
    if (self) {
        programs = [NSMutableDictionary dictionary];
        shadowPrograms = [NSMutableDictionary dictionary];
        self.egl_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        b_readFramebuffer = -1;
    }
    return self;
}

-(void)dealloc
{
    glDeleteFramebuffers(1, &framebuffer);
    glDeleteRenderbuffers(1, &colorbuffer);
    glDeleteRenderbuffers(1, &depthbuffer);
    
    glDeleteFramebuffers(1, &resolveFramebuffer);
    glDeleteRenderbuffers(1, &resolveColorbuffer);

    glDeleteFramebuffers(1, &shadowFramebuffer);
    glDeleteTextures(1, &shadowTexture);

    glDeleteTextures(textureCount, texture);

    free(texture);
    
    [self deactivateContext];
}

-(void) activateContext
{
    [EAGLContext setCurrentContext:self.egl_context];
}

-(void) deactivateContext
{
    [EAGLContext setCurrentContext:nil];
}


#pragma mark -
#pragma mark Framebuffer

-(void) createDefaultFramebufferWithView:(LSView3D*)view
{

    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    
    glGenRenderbuffers(1, &colorbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorbuffer);
    [self.egl_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)view.layer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorbuffer);
    
    glGenRenderbuffers(1, &depthbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, view.frame.size.width*view.contentScaleFactor, view.frame.size.height*view.contentScaleFactor);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthbuffer);
    
    int status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"glCheckFramebufferStatus: %d", status);
    }
    
}

-(void) createMultisamplingFramebufferWithView:(LSView3D*)view
{
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    
    glGenRenderbuffers(1, &colorbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorbuffer);
    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_RGBA8_OES, view.frame.size.width*view.contentScaleFactor, view.frame.size.height*view.contentScaleFactor);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorbuffer);
    
    glGenRenderbuffers(1, &depthbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthbuffer);
    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_DEPTH_COMPONENT16, view.frame.size.width*view.contentScaleFactor, view.frame.size.height*view.contentScaleFactor);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthbuffer);
    
    int status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"1glCheckFramebufferStatus: 0x%x", status);
    }
    
    glGenFramebuffers(1, &resolveFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, resolveFramebuffer);
    
    glGenRenderbuffers(1, &resolveColorbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, resolveColorbuffer);
    [self.egl_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)view.layer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, resolveColorbuffer);
    
    status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"2glCheckFramebufferStatus: 0x%x", status);
    }
}

-(void) createShadowFramebufferWithView:(LSView3D*)view
{
    
    glGenFramebuffers(1, &shadowFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, shadowFramebuffer);
    
    glActiveTexture(GL_TEXTURE1);
    glGenTextures(1, &shadowTexture);
    glBindTexture(GL_TEXTURE_2D, shadowTexture);

    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );

    int retina = ([[LSView3D mainView] shadowRetina] ? 2 : 1);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, view.frame.size.width*retina, view.frame.size.height*retina, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);

    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, shadowTexture, 0);    
    
    int status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"glCheckFramebufferStatus: %d", status);
    }
    
}

#pragma mark -
#pragma mark Rendering

-(void) resolveMultisampling
{
    if ([[LSView3D mainView] multisampling]) {
        if (b_readFramebuffer != framebuffer) {
            b_readFramebuffer  = framebuffer;
            glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, framebuffer);
        }
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, resolveFramebuffer);
        glResolveMultisampleFramebufferAPPLE();
    }
}

-(void) discardBuffers
{
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    if ([[LSView3D mainView] multisampling]) {
        const GLenum discards[]  = {GL_DEPTH_ATTACHMENT, GL_COLOR_ATTACHMENT0};
        glDiscardFramebufferEXT(GL_FRAMEBUFFER,2,discards);
    } else {
        const GLenum discards[]  = {GL_DEPTH_ATTACHMENT};
        glDiscardFramebufferEXT(GL_FRAMEBUFFER,1,discards);
    }
    
    //    const GLenum discards[]  = {GL_COLOR_ATTACHMENT0};
    //    glBindFramebuffer(GL_FRAMEBUFFER, context.shadowFramebuffer);
    //    glDiscardFramebufferEXT(GL_FRAMEBUFFER,1,discards);
    
}

-(void) presentFrame
{
    if ([[LSView3D mainView] multisampling]) {
        glBindRenderbuffer(GL_RENDERBUFFER, resolveColorbuffer);
        [self.egl_context presentRenderbuffer:GL_RENDERBUFFER];
    } else {
        glBindRenderbuffer(GL_RENDERBUFFER, colorbuffer);
        [self.egl_context presentRenderbuffer:GL_RENDERBUFFER];
    }
}

#pragma mark -
#pragma mark Default buffer code

typedef struct _PVRTexHeader
{
    uint32_t headerLength;
    uint32_t height;
    uint32_t width;
    uint32_t numMipmaps;
    uint32_t flags;
    uint32_t dataLength;
    uint32_t bpp;
    uint32_t bitmaskRed;
    uint32_t bitmaskGreen;
    uint32_t bitmaskBlue;
    uint32_t bitmaskAlpha;
    uint32_t pvrTag;
    uint32_t numSurfs;
} PVRTexHeader;

- (void) loadGLTextureTarget:(GLenum)target fromImageFile:(NSString*)name
{
    NSString* fname = [[NSBundle mainBundle] extendedPathForResource:name];
    if (!fname) return;
    
    UIImage*  image = [UIImage imageWithContentsOfFile:fname];
    CGDataProviderRef provider = CGImageGetDataProvider(image.CGImage);
    NSData* data = (__bridge_transfer NSData*)CGDataProviderCopyData(provider);
    
    int bitsPerPixel   = 8*data.length/image.size.width/image.size.height;
    GLenum  format = (bitsPerPixel == 24 ? GL_RGB : GL_RGBA);
    
    if ( data == nil || image.size.width == 0 || image.size.height == 0) {
        printf("Failed to read pixel data from a file %s\n", name.UTF8String);
    }
    
    glTexImage2D(target, 0, format, image.size.width, image.size.height, 0, format, GL_UNSIGNED_BYTE, data.bytes);
    
    [self checkTexImage2DErrors:name size:CGSizeMake(image.size.width, image.size.height) format:format];
}

- (void) loadGLTextureTarget:(GLenum)target fromCompressedFile:(NSString*)name
{
    NSString* fname = [[NSBundle mainBundle] extendedPathForResource: name.stringByDeletingPathExtension ofType:@"pvrtc"];
    if (!fname) return;
    
    NSData* data = [NSData dataWithContentsOfFile: fname];
    
    const PVRTexHeader* header = (const PVRTexHeader*)data.bytes;
    
    int mipmaps = CFSwapInt32LittleToHost(header->numMipmaps);
    bool hasAlpha = CFSwapInt32LittleToHost(header->bitmaskAlpha);
    int bpp = CFSwapInt32LittleToHost(header->bpp);
    CGSize size = CGSizeMake(CFSwapInt32LittleToHost(header->width), CFSwapInt32LittleToHost(header->height));;
    GLenum format;

    if (bpp == 2) {
        format = (hasAlpha ? GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG : GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG);
    } else {
        format = (hasAlpha ? GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG : GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG);
    }
    
    void* ptr = (void*)data.bytes + CFSwapInt32LittleToHost(header->headerLength);
    
    int level = 0;
    int levelWidth = size.width;
    int levelHeight = size.height;
    while (levelWidth > 0 && level <= mipmaps) {
        int imageSize = MAX(levelWidth*levelHeight*bpp/8, 32);
        glCompressedTexImage2D(target, level, format, levelWidth, levelHeight, 0, imageSize, ptr);
        ptr += imageSize;
        level++;
        levelWidth /= 2;
        levelHeight /= 2;
    }
    
    [self checkTexImage2DErrors:name size:size format:format];
}


-(GLuint) createImageTexture:(NSString*)name
{
    textureCount++;
    texture = realloc(texture, sizeof(GLuint)*textureCount);
    
    glActiveTexture(GL_TEXTURE0);
    glGenTextures( 1, &texture[textureCount-1] );
    glBindTexture( GL_TEXTURE_2D, texture[textureCount-1] );
    
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );
    
    bool compressed = [[LSView3D mainView] pvrtc] && ([[NSBundle mainBundle] extendedPathForPVRTC:name] != nil);
    
    if ([[LSView3D mainView] mipmaps]) {
        glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR );
    }
    
    if (compressed) {
        [self loadGLTextureTarget:GL_TEXTURE_2D fromCompressedFile:name];
    }
    else {
        [self loadGLTextureTarget:GL_TEXTURE_2D fromImageFile:name];
    }

    if ([[LSView3D mainView] mipmaps] && !compressed) {
        glGenerateMipmap(GL_TEXTURE_2D);
    }
    
    glBindTexture( GL_TEXTURE_2D, 0);
    
    return texture[textureCount-1];
}

-(GLuint) createCubeTexture:(NSString*)name
{
    textureCount++;
    texture = realloc(texture, sizeof(GLuint)*textureCount);
    
    glActiveTexture(GL_TEXTURE0);
    glGenTextures( 1, &texture[textureCount-1] );
    glBindTexture( GL_TEXTURE_CUBE_MAP, texture[textureCount-1] );
    
    glTexParameterf( GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameterf( GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameterf( GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_REPEAT );
    glTexParameterf( GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_REPEAT );
    
    if ([[LSView3D mainView] mipmaps]) {
        glTexParameterf( GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST );
    }

    int targets[6] = {
        GL_TEXTURE_CUBE_MAP_POSITIVE_X,
        GL_TEXTURE_CUBE_MAP_NEGATIVE_X,
        GL_TEXTURE_CUBE_MAP_POSITIVE_Y,
        GL_TEXTURE_CUBE_MAP_NEGATIVE_Y,
        GL_TEXTURE_CUBE_MAP_POSITIVE_Z,
        GL_TEXTURE_CUBE_MAP_NEGATIVE_Z
    };
    char* suffixes[6] = {"right", "left", "top", "down", "front", "back"};
    
    bool compressed = false;
    for (int i=0; i<6; i++) {
        NSString* cname = [NSString stringWithFormat:@"%@_%s.%@", name.stringByDeletingPathExtension, suffixes[i], name.pathExtension];
        compressed = compressed || ([[LSView3D mainView] pvrtc] && ([[NSBundle mainBundle] extendedPathForPVRTC:cname] != nil));
        if (compressed) {
            [self loadGLTextureTarget:targets[i] fromCompressedFile:cname];
        }
        else {
            [self loadGLTextureTarget:targets[i] fromImageFile:cname];
        }
    }
    
    if ([[LSView3D mainView] mipmaps] && !compressed) {
        glGenerateMipmap(GL_TEXTURE_CUBE_MAP);
    }
    
    glBindTexture( GL_TEXTURE_CUBE_MAP, 0);
    
    return texture[textureCount-1];
}

-(void) checkTexImage2DErrors:(NSString*)name size:(CGSize)size format:(GLenum)format
{
    int error = glGetError();
    if (error ==0 && size.width > 0 && size.height > 0) {
        NSString* tname = name;
        if (GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG <= format && format <= GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG) {
            tname = [NSString stringWithFormat:@"%@.%@", name.stringByDeletingPathExtension, @"pvrtc"];
        }
        printf("Texture%02d: %s (%dx%d)\n", texture[textureCount-1], tname.UTF8String, (int)size.width, (int)size.height);
    }
    else {
        printf("Texture%02d: %s failed with glError: %d\n", texture[textureCount-1], name.UTF8String, error);
    }
}

- (LSProgram3D*) programForShader:(NSString*)shaderLine
{
    return programs[shaderLine];
}

- (LSProgram3D*) programForShader:(NSString*)shaderLine attributes:(LSProgram3DAttributes*)attributes
{
    LSProgram3D* program = programs[shaderLine];
    if (program == false) {
        program = [[LSProgram3D alloc] initWithShaderLine:shaderLine attributes:attributes context:self];
        programs[shaderLine] = program;
//        printf("Shader%d:   %s\n", program.gl_program, [[shaderLine lowercaseString] cStringUsingEncoding:NSUTF8StringEncoding]);
    }

    return program;
}

-(LSProgram3D*) shadowProgramForProgram:(LSProgram3D*)program
{
    LSProgram3D* shadowProgram = shadowPrograms[program.shaderLine];
    if (shadowProgram == false) {
        LSProgram3DAttributes* attributes = [LSProgram3DAttributes attributesPosition];
        shadowProgram = [[LSProgram3D alloc] initWithShaderLine:@"Shadow" attributes:attributes context:self];
        shadowPrograms[program.shaderLine] = shadowProgram;
//        printf("Shader%d*:  %s\n", shadowProgram.gl_program, [[shadowProgram.shaderLine lowercaseString] cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    return shadowProgram;
}

#pragma mark -
#pragma mark Refactoring

-(NSArray*) programs
{
    return programs.allValues;
}
-(NSArray*) shadowPrograms
{
    return shadowPrograms.allValues;
}
-(NSArray*) shadowProgramKeys
{
    return shadowPrograms.allKeys;
}
-(void) activateProgram:(LSProgram3D*)program
{
    if (program) {
        [program activate];
    } else {
        [activeProgram deactivate];
    }
    activeProgram = program;
}

-(LSProgram3D*)skyboxProgram
{
    if (!skyboxProgram) {
// TODO: Messege about skybox program being created
        skyboxProgram = [[LSProgram3D alloc] initWithShaderLine:@"Skybox" attributes:[LSProgram3DAttributes attributesSkybox] context:self];
    }
    return skyboxProgram;
}

@end


