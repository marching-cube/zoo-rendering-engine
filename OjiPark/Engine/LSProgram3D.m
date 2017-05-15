//
//  LSProgram3D.m
//  OjiPark
//
//  Created by Sowinski Lukasz on 2/21/13.
//  Copyright (c) 2013 Mouse Inc. All rights reserved.
//

#import "LSProgram3D.h"
#import "LSContext3D.h"
#import "LSMaterial3D.h"
#import "LSView3D.h"
#import "LSObject3D.h"
#import "LSObject3DFragment.h"
#import "LSProgram3D.h"
#import "LSContext3D.h"

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

@implementation LSProgram3D

@synthesize primitiveType;

static GLuint active_program = -1;

-(instancetype) init {
    return [super init];
}

-(instancetype) initWithShaderLine:(NSString*)aShaderLine attributes:(LSProgram3DAttributes*)theAttributes context:(LSContext3D*)aContext
{
    self=[super init];
    if (self) {
        context = aContext;
        shaderLine = aShaderLine;
        attributes = theAttributes;
        gl_program = [self createProgram];
        [self loadProgramHooks];
        primitiveType = GL_TRIANGLES;
        verticesPerFace = 3;
    }
    return self;
}

-(void)dealloc
{
    glDeleteProgram(gl_program);
    if (shadowOnly == false) {
        glDeleteBuffers(2, vbo);
        glDeleteVertexArraysOES(1, &vao);
    }
}

-(NSString*) shaderLine
{
    return shaderLine;
}

-(void) activate
{
    if (active_program != gl_program) {
        active_program  = gl_program;
        glUseProgram(active_program);
        glBindVertexArrayOES(vao);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo[1]);
    }
}

-(void) deactivate
{
    active_program  = 0;
    glBindVertexArrayOES(0);
    glUseProgram(0);
}

-(void)loadProgramHooks
{
    glUseProgram(gl_program);
    
    gl_position     = glGetAttribLocation(gl_program, "a_position");
    gl_normal       = glGetAttribLocation(gl_program, "a_normal");
    gl_tangent      = glGetAttribLocation(gl_program, "a_tangent");
    gl_binormal     = glGetAttribLocation(gl_program, "a_binormal");
    gl_uv           = glGetAttribLocation(gl_program, "a_uv");
    
    gl_lpc          = glGetUniformLocation(gl_program, "lightPositionCamera");
    gl_lc           = glGetUniformLocation(gl_program, "lightColor");
    gl_offset       = glGetUniformLocation(gl_program, "offset");
    gl_mvp          = glGetUniformLocation(gl_program, "modelViewProjectionMatrix");
    gl_mvpl         = glGetUniformLocation(gl_program, "modelViewProjectionMatrixLightSource");
    gl_nm           = glGetUniformLocation(gl_program, "normalMatrix");

    gl_diffuse      = glGetUniformLocation(gl_program, "diffuseColorAdjusted");
    gl_ambient      = glGetUniformLocation(gl_program, "ambientColorAdjusted");
    gl_specular     = glGetUniformLocation(gl_program, "specularColorAdjusted");
    gl_specular_exp = glGetUniformLocation(gl_program, "specularExponent");
    gl_fresnel_f0   = glGetUniformLocation(gl_program, "fresnelF0");
    gl_fresnel_pow  = glGetUniformLocation(gl_program, "fresnelPOW");
    gl_tex0         = glGetUniformLocation(gl_program, "tex0");
    gl_tex1         = glGetUniformLocation(gl_program, "tex1");
    gl_tex2         = glGetUniformLocation(gl_program, "tex2");

    glUseProgram(0);

    *lc = -1;
    *lpc = -1;
    *nm = -1;
    *mvp = -1;
    *mvpl = -1;
    *offset = -1;
    *diffuse = -1;
    *ambient = -1;
    *specular = -1;
    specular_exp = -1;
    fresnel_pow = -1;
    fresnel_f0 = -1;
    btex0 = -1;
    tex0  = -1;
    btex1 = -1;
    tex1  = -1;
    btex2 = -1;
    tex2  = -1;

    offset[3] = 0;
}

-(GLuint) vao  { return vao; }
-(GLuint) vbo0 { return vbo[0]; }
-(GLuint) vbo1 { return vbo[1]; }
-(LSProgram3DAttributes*) attributes { return attributes; }

#pragma mark -
#pragma mark Draw

-(void) drawFragment:(LSObject3DFragment*)fragment
{
//    printf("draw%d: %s %d+%d\n", fragment.program.gl_program, [fragment.material.name UTF8String], fragment.faceOffset, fragment.faceCount);
//    printf("draw%d: %ld %ld\n", fragment.program.gl_program, (sizeof(GLushort)*fragment.faceOffset*3), sizeof(GLushort)*fragment.faceCount*3);
    glDrawElements(GL_TRIANGLES, fragment.faceCount*3, GL_UNSIGNED_SHORT, (void*)(sizeof(GLushort)*fragment.faceOffset*3));
}

-(void) drawFaces:(int)count offset:(int)foffset
{
    glDrawElements(primitiveType, count, GL_UNSIGNED_SHORT, (void*)(sizeof(GLushort)*foffset));
}

#pragma mark -
#pragma mark Uniforms

-(void) loadLightColor:(GLKVector3)lightColor
{
    if (gl_lc != -1) {
        if (memcmp(lc, lightColor.v, 3*sizeof(GLfloat))) {
            memcpy(lc, lightColor.v, 3*sizeof(GLfloat));
            glUniform3fv(gl_lc, 1, lc);
        }
    }
}

-(void) loadLightPositionCamera:(GLKVector3)lightPositionCamera
{
    if (gl_lpc != -1) {
        if (memcmp(lpc, lightPositionCamera.v, 3*sizeof(GLfloat))) {
            memcpy(lpc, lightPositionCamera.v, 3*sizeof(GLfloat));
            glUniform3fv(gl_lpc, 1, lpc);
        }
    }
}

-(void) loadNormalMatrix:(GLKMatrix3)normalMatrix
{
    if (gl_mvp != -1) {
        if (memcmp(nm, normalMatrix.m, 9*sizeof(GLfloat))) {
            memcpy(nm, normalMatrix.m, 9*sizeof(GLfloat));
            glUniformMatrix3fv(gl_nm, 1, 0, nm);
        }
    }
}

-(void) loadMVP:(GLKMatrix4)aMvp
{
    if (gl_mvp != -1) {
        if (memcmp(mvp, aMvp.m, 16*sizeof(GLfloat))) {
            memcpy(mvp, aMvp.m, 16*sizeof(GLfloat));
            glUniformMatrix4fv(gl_mvp, 1, 0, mvp);
        }
    }
}

-(void) loadMVPLight:(GLKMatrix4)aMvpl
{
    if (gl_mvpl != -1) {
        if (memcmp(mvpl, aMvpl.m, 16*sizeof(GLfloat))) {
            memcpy(mvpl, aMvpl.m, 16*sizeof(GLfloat));
            glUniformMatrix4fv(gl_mvpl, 1, 0, mvpl);
        }
    }
}

-(void) loadOffset:(GLKVector3)aOffset
{
    if (gl_offset != -1) {
        if (memcmp(offset, aOffset.v, 3*sizeof(GLfloat))) {
            memcpy(offset, aOffset.v, 3*sizeof(GLfloat));
            glUniform4fv(gl_offset, 1, offset);
        }
    }
}

//TODO: LSView3D should not keep all these configuration data
//TODO: shadowTexture is still stored in LSHelper3D

-(void) loadMaterial:(LSMaterial3D*)aMaterial
{
    material = aMaterial;
    
    if (gl_diffuse != -1) {
        if (memcmp(diffuse, material.diffuseColorAdjusted.v, 4*sizeof(GLfloat))) {
            memcpy(diffuse, material.diffuseColorAdjusted.v, 4*sizeof(GLfloat));
            glUniform4fv(gl_diffuse, 1, diffuse);
        }
    }
    
    if (gl_ambient != -1) {
        if ([[LSView3D mainView] globalambient]) {
            GLfloat dambient[4] = {
                0.2*material.diffuseColorAdjusted.v[0],
                0.2*material.diffuseColorAdjusted.v[1],
                0.2*material.diffuseColorAdjusted.v[2],
                1.0 };
            if (memcmp(ambient, dambient, 4*sizeof(GLfloat))) {
                memcpy(ambient, dambient, 4*sizeof(GLfloat));
                glUniform4fv(gl_ambient, 1, ambient);
            }
        } else {
            if (memcmp(ambient, material.ambientColorAdjusted.v, 4*sizeof(GLfloat))) {
                memcpy(ambient, material.ambientColorAdjusted.v, 4*sizeof(GLfloat));
                glUniform4fv(gl_ambient, 1, ambient);
            }
        }
    }
    
    if (gl_specular != -1) {
        if (memcmp(specular, material.specularColorAdjusted.v, 4*sizeof(GLfloat))) {
            memcpy(specular, material.specularColorAdjusted.v, 4*sizeof(GLfloat));
            glUniform4fv(gl_specular, 1, specular);
        }
        
        if (specular_exp != material.specularExponent) {
            specular_exp  = material.specularExponent;
            glUniform1f(gl_specular_exp, specular_exp);
        }
    }
    
    if (gl_fresnel_f0 != -1) {
        if ([[LSView3D mainView] fresnel]) {
            if (fresnel_f0 != [[LSView3D mainView] fresnel_param0] ) {
                fresnel_f0  = [[LSView3D mainView] fresnel_param0];
                glUniform1f(gl_fresnel_f0,  fresnel_f0);
            }
            if (fresnel_pow != [[LSView3D mainView] fresnel_param1] ) {
                fresnel_pow  = [[LSView3D mainView] fresnel_param1];
                glUniform1f(gl_fresnel_pow,  fresnel_pow);
            }
        }
    }

// TODO: tex0 should probably be shared among programs
    if (gl_tex0 != -1) {
        if (attributes.uvSize > 0) {
//            if (btex0 != material.texture) {
                btex0  = material.texture;
                glActiveTexture(GL_TEXTURE0);
                glBindTexture(GL_TEXTURE_2D, btex0);
//            }
            if (tex0 != 0) {
                tex0  = 0;
                glUniform1i(gl_tex0, tex0);
            }
        }
    }
    
    if (gl_tex1 != -1) {
        if (btex0 != context.shadowTexture) {
            btex0  = context.shadowTexture;
            glActiveTexture(GL_TEXTURE1);
            glBindTexture(GL_TEXTURE_2D, btex0);
        }
        if (tex1 != 1) {
            tex1  = 1;
            glUniform1i(gl_tex1, tex1);
        }
    }
    
    if (gl_tex2 != -1) {
        if (btex0 != material.bumpTexture) {
            btex0  = material.bumpTexture;
            glActiveTexture(GL_TEXTURE2);
            glBindTexture(GL_TEXTURE_2D, btex0);
        }
        if (tex2 != 1) {
            tex2  = 2;
            glUniform1i(gl_tex2, tex2);
        }
    }


}

-(void) loadCubeTexture:(GLuint)texture
{
    if (gl_tex0 != -1) {
//        if (attributes.uvSize > 0) {
            btex0  = texture;
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_CUBE_MAP, btex0);
            if (tex0 != 0) {
                tex0  = 0;
                glUniform1i(gl_tex0, tex0);
            }
//        }
    }
}


#pragma mark -
#pragma mark Shadow


-(void)formatShadowShaderForProgram:(LSProgram3D*)baseProgram
{
    vao = [baseProgram vao];
    vbo[0] = [baseProgram vbo0];
    vbo[1] = [baseProgram vbo1];
    attributes = [baseProgram attributes];
    
    [self formatBuffers];
    
    shadowOnly = true;
}

-(void) loadShadow
{
    if (gl_tex1) {
        if (tex1 != context.shadowTexture) {
            tex1  = context.shadowTexture;
            glActiveTexture(GL_TEXTURE1);
            glBindTexture(GL_TEXTURE_2D, tex1);
            glUniform1i(gl_tex1, 1);
        }
    }
}

#pragma mark -
#pragma mark Data

-(void) createBuffersForVertexCount:(int)vertexCount faceCount:(int)faceCount
{    
    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);
    
    glGenBuffers(2, vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo[0]);
    glBufferData(GL_ARRAY_BUFFER, [attributes size]*vertexCount, NULL, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo[1]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLushort)*faceCount, NULL, GL_STATIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
    glBindVertexArrayOES(0);
}

-(void) copyVertexData:(GLfloat*)data from:(int)start count:(int)count
{
    glBindVertexArrayOES(vao);
    glBindBuffer(GL_ARRAY_BUFFER, vbo[0]);
    glBufferSubData(GL_ARRAY_BUFFER, [attributes size]*start, [attributes size]*count, data);
    glBindVertexArrayOES(0);
}

-(void) copyFaceData:(GLushort*)data from:(int)start count:(int)count
{
    glBindVertexArrayOES(vao);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo[1]);
    glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLushort)*start, sizeof(GLushort)*count, data);
    glBindVertexArrayOES(0);
}

-(void) formatBuffers
{    
    glBindVertexArrayOES(vao);
    glBindBuffer(GL_ARRAY_BUFFER, vbo[0]);
    
    if (gl_position != -1) {
        glVertexAttribPointer(gl_position, attributes.positionSize, GL_FLOAT, GL_FALSE, attributes.size, attributes.positionStride);
        glEnableVertexAttribArray(gl_position);
    }
    if (gl_normal != -1) {
        glVertexAttribPointer(gl_normal, attributes.normalSize, GL_FLOAT, GL_FALSE, attributes.size, attributes.normalStride);
        glEnableVertexAttribArray(gl_normal);
    }
    if (gl_tangent != -1) {
        glVertexAttribPointer(gl_tangent, attributes.tangentSize, GL_FLOAT, GL_FALSE, attributes.size, attributes.tangentStride);
        glEnableVertexAttribArray(gl_tangent);
    }
    if (gl_binormal != -1) {
        glVertexAttribPointer(gl_binormal, attributes.binormalSize, GL_FLOAT, GL_FALSE, attributes.size, attributes.binormalStride);
        glEnableVertexAttribArray(gl_binormal);
    }
    if (gl_uv != -1) {
        glVertexAttribPointer(gl_uv, attributes.uvSize, GL_FLOAT, GL_FALSE, attributes.size, attributes.uvStride);
        glEnableVertexAttribArray(gl_uv);
    }
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo[1]);
	glBindVertexArrayOES(0);
}


#pragma mark -  OpenGL ES 2 shader compilation

- (GLuint)createProgram
{
    GLuint vertShader = 0, fragShader = 0;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    NSArray*  components = [shaderLine componentsSeparatedByString:@"#"];
    NSString* shaderName = components[0];
    NSArray*  options = (components.count > 1 ? [components subarrayWithRange:NSMakeRange(1, components.count-1)] : nil);
    
    // Create shader program.
    GLuint program_ = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname options:options]) {
        NSLog(@"Failed to compile vertex shader");
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname options:options]) {
        NSLog(@"Failed to compile fragment shader");
    }
    
    glAttachShader(program_, vertShader);
    glAttachShader(program_, fragShader);
    
    // Link program.
    if (![self linkProgram:program_]) {
        NSLog(@"Failed to link program: %d", program_);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program_) {
            glDeleteProgram(program_);
        }
    }
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(program_, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(program_, fragShader);
        glDeleteShader(fragShader);
    }
    
    return program_;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file options:(NSArray*)options
{
    GLint status;
    const GLchar *gl_source;
    
    NSMutableString* source = [NSMutableString string];
    for (NSString* option in options) {
        [source appendFormat:@"#define %@\n", option.uppercaseString];
    }
    [source appendString:[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil]];
    
    gl_source = (GLchar *)source.UTF8String;
    if (!gl_source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &gl_source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}


#pragma mark -
#pragma mark Refactoring

-(GLuint) gl_program { return gl_program; }
-(GLuint) size { return [attributes size]; }
-(bool) isActive { return self.gl_program == active_program; }

@end
