//
//  LSModel3D.m
//  miniEngine3D
//
//  Created by Lukasz Sowinski (niman.gosen.en@gmail.com) on 7/6/12.
//  Copyright (c) 2012 Lukasz Sowinski. All rights reserved.
//

#import "LSModel3D.h"
#import "LSObject3D.h"
#import "LSObject3DFragment.h"
#import "LSContext3D.h"
#import "LSModel3DConf.h"
#import "LSModel3DSourceOBJ.h"
#import "LSObject3DConf.h"
#import "LSAnimation3D.h"
#import "LSView3D.h"
#import "LSMaterial3D.h"
#import "LSMaterial3DCache.h"
#import "LSBuffer3D.h"
#import "LSProgram3D.h"

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

@implementation LSModel3D

-(instancetype)init {
    self = [super init];
    return self;
}

-(instancetype) initModelNamed:(NSString*)mname context:(LSContext3D*)aHelper
{
    self=[super init];
    if (self) {
        context = aHelper;
        modelName = mname;
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)coder
{
    // TODO: optimise
    //    __weak   LSContext3D*       context;
    //    __strong NSMutableDictionary* textures;
    self=[self init];
    if (self) {
        modelName = [coder decodeObjectForKey:@"modelName"];
        objects = [coder decodeObjectForKey:@"objects"];
        modelSource = [coder decodeObjectForKey:@"modelSource"];
        modelConf = [coder decodeObjectForKey:@"modelConf"];
        renderingMap = [coder decodeObjectForKey:@"renderingMap"];
        self.lookAnimation = [coder decodeObjectForKey:@"lookAnimation"];
        self.sceneAnimation = [coder decodeObjectForKey:@"sceneAnimation"];
        self.gyroAnimation = [coder decodeObjectForKey:@"gyroAnimation"];
        self.shadowSceneAnimation = [coder decodeObjectForKey:@"shadowSceneAnimation"];
        self.switchAnimation = [coder decodeObjectForKey:@"switchAnimation"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    // TODO: optimise
//    __weak   LSContext3D*       context;
//    __strong NSMutableDictionary* textures;
    [coder encodeObject:modelName forKey:@"modelName"];
    [coder encodeObject:objects forKey:@"objects"];
    [coder encodeObject:modelSource forKey:@"modelSource"];
    [coder encodeObject:modelConf forKey:@"modelConf"];
    [coder encodeObject:renderingMap forKey:@"renderingMap"];
    [coder encodeObject:self.lookAnimation forKey:@"lookAnimation"];
    [coder encodeObject:self.sceneAnimation forKey:@"sceneAnimation"];
    [coder encodeObject:self.gyroAnimation forKey:@"gyroAnimation"];
    [coder encodeObject:self.shadowSceneAnimation forKey:@"shadowSceneAnimation"];
    [coder encodeObject:self.switchAnimation forKey:@"switchAnimation"];
}

#pragma mark -
#pragma mark loadObjects

-(void) loadObjects
{
    // create objects
    modelConf   = [[LSModel3DConf alloc] initWithModelName:modelName];
    [self enumerateOBJObjects];
    [self loadMeshOpenGL];
    [self createAnimations];
    [self generateRenderingMap];
    [self printStatistics];
}

-(void) loadMeshOpenGL
{
    // query object data
    [self loadData];
    [self loadPrograms];
    [self addTangentsAndBinormals];

    // Object programs
    for (LSProgram3D* program in context.programs) {
        GLuint totalVertexCount = [self totalVertexCountForProgram: program];
        GLuint totalFaceCount = [self totalFaceCountForProgram: program];
        [context activateProgram:program];
        [program createBuffersForVertexCount:totalVertexCount faceCount:3*totalFaceCount];
        [program formatBuffers];
        [self copyData];
//        [self dumpData: program.shaderLine];
//        [self verifyBinary:program.shaderLine];
        printf("Shader%d:   %s (%d,%d)\n", program.gl_program, (program.shaderLine).lowercaseString.UTF8String, totalFaceCount, totalVertexCount);
    }
    [self unloadData];
    
    // Shadow programs
    for (NSString* programKey in context.shadowProgramKeys) {
        LSProgram3D* program = [context programForShader:programKey];
        LSProgram3D* shadowProgram = [context shadowProgramForProgram: program];
        [shadowProgram formatShadowShaderForProgram:program];
        printf("Shader%d*:  %s (%s)\n", shadowProgram.gl_program, (shadowProgram.shaderLine).lowercaseString.UTF8String, (program.shaderLine).UTF8String);
    }
    
    // Skybox program
    [context activateProgram:context.skyboxProgram];
    [context.skyboxProgram createBuffersForVertexCount:8 faceCount:14];
    [context.skyboxProgram formatBuffers];
    context.skyboxProgram.primitiveType = GL_TRIANGLE_STRIP;
    [self copySkyboxData];
    printf("Shader%d:   %s (%d,%d)\n", context.skyboxProgram.gl_program, (context.skyboxProgram.shaderLine).lowercaseString.UTF8String, 12, 8);
    
    // textures
    [self mapTextures];
    GLuint skyboxTexture = [context createCubeTexture:@"skybox.png"];
    textures[@"skybox"] = @(skyboxTexture);

    [context activateProgram: nil];

    modelSource = nil;
    modelConf   = nil;
}

-(void) generateRenderingMap
{
    renderingMap = [NSMutableDictionary dictionary];
    for (LSProgram3D* program in context.programs) {
        NSMutableDictionary* materialMap = [NSMutableDictionary dictionary];
        for (LSObject3D* object in objects) {
            for (LSObject3DFragment* fragment in object.fragments) {
                if (fragment.program != program) continue;
                NSMutableArray* fragmentMap = materialMap[fragment.material.name];
                if (fragmentMap == nil) {
                    fragmentMap = [NSMutableArray array];
                    materialMap[fragment.material.name] = fragmentMap;
                }
                [fragmentMap addObject: @[object, fragment]];
            }
        }
        renderingMap[program.shaderLine] = materialMap;
    }
}

-(void) createAnimations
{
    // animations - default
    LSAnimation3DProjection* projection = [LSAnimation3DProjection animation];
    projection.view = [LSView3D mainView];
    _lookAnimation   = [LSAnimation3DLook animationWithParent:projection];
    _sceneAnimation  = [LSAnimation3DScene animationWithParent:projection];
    _gyroAnimation   = [LSAnimation3DGyro animationWithParent:projection];
    if (![[LSView3D mainView] stripShadows]) {
        LSAnimation3DShadowProjection* projection = [LSAnimation3DShadowProjection animation];
        _shadowSceneAnimation  = [LSAnimation3DShadowScene animationWithParent:projection];
        _switchAnimation = [LSAnimation3DModeSwitch animationWithAnimations: @[_sceneAnimation, _lookAnimation, _gyroAnimation, _shadowSceneAnimation]];
    } else {
        _switchAnimation = [LSAnimation3DModeSwitch animationWithAnimations: @[_sceneAnimation, _lookAnimation,  _gyroAnimation]];
    }
    
    // animations - custom
    NSMutableArray* animationQueue = [NSMutableArray arrayWithArray:objects];
    while (animationQueue.count > 0) {
        NSMutableArray* nextAnimationQueue = [NSMutableArray array];
        for (LSObject3D* object in animationQueue) {
            if (object.animated && !object.animation) {
                if ([self resolveCustomAnimation:object parent:_switchAnimation]) {
                    [nextAnimationQueue addObject:object];
                }
            } else if (!object.animated) {
                object.animation = _switchAnimation;
            }
        }
        animationQueue = nextAnimationQueue;
    }
    for (LSObject3D* object in objects) {
        if (object.cloned) {
            object.animation = [LSAnimation3DClone animationWithParent:object.animation object:object];
        }
    }
}

-(bool) resolveCustomAnimation:(LSObject3D*)object parent:(LSAnimation3DBasic*)parent
{
    if (object.animated && !object.animation) {
        LSAnimation3DBasic* parentAnimation = parent;
        if (object.parentName && ![object.parentName isEqualToString:@""]) {
            for (LSObject3D* parentObject in objects) {
                if ([parentObject.name isEqualToString:object.parentName]) {
                    parentAnimation = parentObject.animation;
                    break;
                }
            }
        }
        if (parentAnimation) {
            LSAnimation3DRotation* animation = [LSAnimation3DRotation animationWithParent:parentAnimation object:object];
            [animation defineRotationAxis:object.axis anchor:object.anchor];
            animation.speed = object.speed;
            object.animation = animation;
        } else {
            return true;
        }
    }
    return false;
}

-(void) enumerateOBJObjects
{
    objects     = [NSMutableArray array];
    LSModel3DSourceOBJ* source = [[LSModel3DSourceOBJ alloc] initWithSourceName:modelName];
    
    // TODO: >>> REFACTOR

    NSMutableDictionary* cloneQueue = [[NSMutableDictionary alloc] init];
    for (NSString* entryName in source.entries) {
        LSModel3DSourceOBJEntry* entry = (source.entries)[entryName];
        LSObject3DConf* objectConf = [modelConf objectForKey: entry.name];
        LSObject3D* object = [LSObject3D object3DWithOBJModelSource:source objectKey:entry.name objectConf:objectConf];
        if (objectConf.cloneName) cloneQueue[entry.name] = objectConf.cloneName;
        if (!object) continue;
        [objects addObject:object];
    }
    
    // clone run
    for (NSString* objectKey in cloneQueue) {
        NSString* cloneName = cloneQueue[objectKey];
        LSObject3D* selectObject = nil;
        for (LSObject3D* object in objects) {
            if ([object.name isEqualToString:cloneName]) {
                selectObject = object;
                break;
            }
        }
        LSModel3DSourceOBJEntry* entry = (source.entries)[objectKey];
        LSObject3D* object = [selectObject cloneObjectWithNewKey:objectKey];
        object.box0 = entry.box0;
        object.box1 = entry.box1;
        object.name = entry.name;
        object.firstVertex = entry.firstVertex;
        object.gravity = entry.gravity;
        [object loadOBJInstanceDataByCloning:selectObject];
        if (object) {
            [objects addObject:object];
        }
    }

    // TODO: <<< REFACTOR

}

-(GLuint) totalFaceCountForProgram:(LSProgram3D*)program
{
    GLuint totalFaceCount = 0;
    for (LSObject3D* object in objects) {
        if (object.cloned) continue;
        for (LSObject3DFragment* fragment in object.fragments) {
            if (fragment.program == program) {
                totalFaceCount += fragment.faceCount;
            }
        }
    }
    return totalFaceCount;
}

-(GLuint) totalVertexCountForProgram:(LSProgram3D*)program
{
    GLuint totalVertexCount = 0;
    for (LSObject3D* object in objects) {
        if (object.cloned) continue;
        for (LSObject3DFragment* fragment in object.fragments) {
            if (fragment.program == program) {
                totalVertexCount += fragment.vertexCount;
            }
        }
    }
    return totalVertexCount;
}


-(void) loadData
{
    for (LSObject3D* object in objects)
    {
        if (object.cloned) {
            continue;
        }
        [object loadData];
        [object normalizeVertexData];
        
        // TODO: refactor - this is debug code
//        for (LSObject3DFragment* fragment in object.fragments) {
//            printf("fragment: '%s' %d fra:%d/%d obj:%d/%d+%d\n", [object.name UTF8String], fragment.program, fragment.faceCount, fragment.vertexCount, object.faceCount, object.vertex0Count, object.vertex1Count);
//        }

    }
}

-(void) loadPrograms
{
    NSMutableString* shaderOptions = [NSMutableString stringWithString:@"Render"];
    if ([[LSView3D mainView] fresnel])      [shaderOptions appendString:@"#fresnel"];
    if ([[LSView3D mainView] bglow])        [shaderOptions appendString:@"#bglow"];
    if ([[LSView3D mainView] wglow])        [shaderOptions appendString:@"#wglow"];
    if ([[LSView3D mainView] quantify8])    [shaderOptions appendString:@"#quantify8"];
    if ([[LSView3D mainView] quantify4])    [shaderOptions appendString:@"#quantify4"];
    if ([[LSView3D mainView] alphadiscard]) [shaderOptions appendString:@"#alphadiscard"];
    if ([[LSView3D mainView] hemisphere])   [shaderOptions appendString:@"#hemisphere"];
    if ([[LSView3D mainView] perfragment]) {
        [shaderOptions appendString:@"#perfragment"];
    } else {
        [shaderOptions appendString:@"#phong"];
    }

    for (LSObject3D* object in objects)
    {
        bool shadowCast    = (object.cshadow && ![[LSView3D mainView] stripShadows]);
        for (LSObject3DFragment* fragment in object.fragments)
        {
            NSString* specificShaderOptions = [shaderOptions stringByAppendingString: fragment.shaderParameters];
            fragment.program = [context programForShader: specificShaderOptions attributes: fragment.attributes];
            if (shadowCast) fragment.shadowProgram = [context shadowProgramForProgram: fragment.program];
        }
    }
}

-(void) addTangentsAndBinormals
{
    for (LSObject3D* object in objects) {
        for (LSBuffer3D* buffer in (object.buffers).allValues) {
            [buffer addTangentsAndBinormals];
        }
    }
}


// TODO: Refactor these two methods -> move to program
-(void) copyData
{
    unsigned short vertexOffset = 0;
    unsigned short faceOffset = 0;
    
    for (LSObject3D* object in objects)
    {
        LSBuffer3D* currentBuffer = [object currentBuffer];
        if (currentBuffer.faceCount > 0)
        {
            [object shiftFragmentBuffer: currentBuffer indexes:vertexOffset vertices:faceOffset];
            [context.activeProgram copyFaceData:   currentBuffer.faceBuffer   from:3*faceOffset count:3*currentBuffer.faceCount];
            [context.activeProgram copyVertexData: currentBuffer.vertexBuffer from:vertexOffset count:currentBuffer.vertexCount];
            faceOffset += currentBuffer.faceCount;
            vertexOffset += currentBuffer.vertexCount;
        } 
    }
}

-(void) copySkyboxData
{
    float vertices[24*2] = {
        -1.0, -1.0,  1.0, -1.0, -1.0,  1.0,
        1.0, -1.0,  1.0, 1.0, -1.0,  1.0,
        -1.0,  1.0,  1.0, -1.0,  1.0,  1.0,
        1.0,  1.0,  1.0, 1.0,  1.0,  1.0,
        -1.0, -1.0, -1.0, -1.0, -1.0, -1.0,
        1.0, -1.0, -1.0, 1.0, -1.0, -1.0,
        -1.0,  1.0, -1.0, -1.0,  1.0, -1.0,
        1.0,  1.0, -1.0, 1.0,  1.0, -1.0,
    };
    
    GLushort indices[14] = {0, 1, 2, 3, 7, 1, 5, 4, 7, 6, 2, 4, 0, 1};
    
    [context.activeProgram copyFaceData:   indices  from:0 count:14];
    [context.activeProgram copyVertexData: vertices from:0 count:8];
}

-(void) dumpData:(NSString*)name
{
    int size = 0;
    
    GLushort* faceDump = 0;
    GLfloat*  vertexDump = 0;
    
    unsigned short vertexOffset = 0;
    unsigned short faceOffset = 0;
    
    for (LSObject3D* object in objects)
    {
        LSBuffer3D* currentBuffer = [object currentBuffer];

        if (currentBuffer.faceCount > 0)
        {
            size = currentBuffer.attributes.size/sizeof(GLfloat);
            
            [object shiftFragmentBuffer: currentBuffer indexes:vertexOffset vertices:faceOffset];
            faceDump = realloc(faceDump, 3*(faceOffset+currentBuffer.faceCount)*sizeof(GLushort));
            vertexDump = realloc(vertexDump, size*(vertexOffset+currentBuffer.vertexCount)*sizeof(GLfloat));
            memcpy(faceDump+3*faceOffset, currentBuffer.faceBuffer, 3*currentBuffer.faceCount*sizeof(GLushort));
            memcpy(vertexDump+size*vertexOffset, currentBuffer.vertexBuffer, size*currentBuffer.vertexCount*sizeof(GLfloat));
            faceOffset += currentBuffer.faceCount;
            vertexOffset += currentBuffer.vertexCount;
        }
    }
    
    NSData* fdata = [NSData dataWithBytes:faceDump length:sizeof(GLushort)*3*faceOffset];
    NSString* fname = [NSTemporaryDirectory() stringByAppendingPathComponent: [name stringByAppendingPathExtension:@"fd"]];
    [fdata writeToFile:fname atomically:true];
    
    NSData* vdata = [NSData dataWithBytes:vertexDump length:sizeof(GLfloat)*size*vertexOffset];
    NSString* vname = [NSTemporaryDirectory() stringByAppendingPathComponent: [name stringByAppendingPathExtension:@"vd"]];
    [vdata writeToFile:vname atomically:true];
    
    NSString* idata = [NSString stringWithFormat:@"%d %d %d", faceOffset, vertexOffset, size];
    NSString* iname = [NSTemporaryDirectory() stringByAppendingPathComponent: [name stringByAppendingPathExtension:@"txt"]];
    [idata writeToFile:iname atomically:true encoding:NSUTF8StringEncoding error:nil];
    
    free(faceDump);
    free(vertexDump);
}

-(void) verifyBinary:(NSString*)name
{
    NSString* fname = [NSTemporaryDirectory() stringByAppendingPathComponent: [name stringByAppendingPathExtension:@"fd"]];
    NSData* fdata = [NSData dataWithContentsOfFile:fname];
    
    NSString* vname = [NSTemporaryDirectory() stringByAppendingPathComponent: [name stringByAppendingPathExtension:@"vd"]];
    NSData* vdata = [NSData dataWithContentsOfFile:vname];
    
    NSString* iname = [NSTemporaryDirectory() stringByAppendingPathComponent: [name stringByAppendingPathExtension:@"txt"]];
    NSString* idata = [NSString stringWithContentsOfFile:iname encoding:NSUTF8StringEncoding error:nil];
    
    // size test
    int fsize = [idata componentsSeparatedByString:@" "][0].intValue;
    int vsize = [idata componentsSeparatedByString:@" "][1].intValue;
    int perVertex = [idata componentsSeparatedByString:@" "][2].intValue;
    
    NSAssert(fsize && vsize && perVertex, @"description file info not null");
    NSAssert([fdata length] == fsize*3*sizeof(GLushort), @"face description matches binary size");
    NSAssert([vdata length] == vsize*perVertex*sizeof(GLfloat), @"vertex description matches binary size");
    
    // valid indexes
    GLushort* fbytes = (GLushort*)fdata.bytes;
    for (int i=0; i<fsize*3; i++) {
        NSAssert(fbytes[i] < vsize, @"valid indexes");
    }
    
    // limited values
    GLfloat* vbytes = (GLfloat*)vdata.bytes;
    for (int i=0; i<vsize; i++) {
        for (int j=0; j<perVertex; j++) {
            float value = vbytes[i*perVertex+j];
            if (isnan(value)) printf("unbound value: %f (attribute %d/%d)\n", value, j+1, perVertex);
            if (fabsf(value)>30) printf("unbound value: %f (attribute %d/%d)\n", value, j+1,perVertex);
            NSAssert(fabsf(value)<30, @"limited values");
        }
    }
    
    NSLog(@"binary data validated succesfully: %@", name);

}


-(void) unloadData
{
    for (LSObject3D* object in objects)
    {
        [object unloadData];
    }
}

-(void) mapTextures
{
    for (LSObject3D* object in objects) {
        LSObject3DConf* objectConf = (modelConf.objects)[object.name];
        for (LSObject3DFragment* fragment in object.fragments) {
            NSString* textureName = (objectConf.textureName ? objectConf.textureName : fragment.material.textureName);
            fragment.material.texture = [self textureForName: textureName];
            fragment.material.bumpTexture = [self textureForName: fragment.material.bumpTextureName];
        }
    }
}

-(GLuint) textureForName:(NSString*)name
{
    if (!textures) textures = [NSMutableDictionary dictionary];

    GLuint texture;
    if (!name) return 0;
    NSNumber* textureNo = textures[name];
    if (textureNo) {
        texture = textureNo.unsignedShortValue;
    } else {
        texture = [context createImageTexture:name];
        textures[name] = @(texture);
    }
    return texture;
}

-(void) printStatistics
{
    printf("Model:     %s\n", [modelName cStringUsingEncoding:NSUTF8StringEncoding]);
    
    int tvc = 0, tfc = 0;
    for (LSProgram3D* program in context.programs) {
        tvc += [self totalVertexCountForProgram: program];
        tfc += [self totalFaceCountForProgram: program];
    }
    printf("Objects:   %lu\n", (unsigned long)objects.count);
    printf("Vertices:  %d\n", tvc);
    printf("Faces:     %d\n", tfc);
    printf("\n");
    
//    [self debugRenderingMap];
}

-(void) debugRenderingMap
{
    for (LSProgram3D* program in context.programs) {
        NSDictionary* materialMap = renderingMap[program.shaderLine];
        for (NSString* name in materialMap.allKeys) {
            for (NSArray* pair in materialMap[name]) {
                LSObject3D* object = pair[0];
                LSObject3DFragment* fragment = pair[1];
                printf("%d %s %s %d %d\n", [fragment.program gl_program], (object.name).UTF8String, (fragment.material.name).UTF8String, fragment.material.texture, fragment.material.bumpTexture);
            }
        }
        printf("\n");
    }
}

#pragma mark -
#pragma mark renderObjects

-(void) renderObjects:(LSProgram3D*)program
{
    
    glPushGroupMarkerEXT(0, "renderObjects");

    // TOOD: some condition?! should this really be called every time?
    [context.activeProgram loadMVPLight: _shadowSceneAnimation.modelViewMatrixProjection]; // TODO : bad bad bad
    NSDictionary* materialMap = renderingMap[program.shaderLine];
    
    for (NSString* name in materialMap.allKeys) {
        
        LSMaterial3D* material = [[LSMaterial3DCache sharedCache] materialForKey:name];
        
        NSArray* fragments = materialMap[name];

        [context.activeProgram loadMaterial: material];
        
        for (NSArray* pair in fragments)
        {
            LSObject3D* object = pair[0];
            LSObject3DFragment* fragment = pair[1];

//            [context.activeProgram loadOffset: object.offset];
            
            // TODO: this is called too often
            if ([[LSView3D mainView] debugShadow]) {
                if (!object.cshadow) continue;
                [context.activeProgram loadMVP: _shadowSceneAnimation.modelViewMatrixProjection];
                [context.activeProgram loadNormalMatrix: _shadowSceneAnimation.normalMatrix];
            } else {
                LSAnimationMode mode = [[LSView3D mainView] animationMode];
                [object.animation animate:update_t inMode: mode];
                [context.activeProgram loadMVP: object.animation.modelViewMatrixProjection];
                [context.activeProgram loadNormalMatrix: object.animation.normalMatrix];
            }

            [context.activeProgram drawFragment:fragment];
            
        }
    }
    
    glPopGroupMarkerEXT();

}

-(void) renderSkybox:(LSProgram3D*)program
{
    glPushGroupMarkerEXT(0, "renderSkybox");
    
    GLuint skyboxTexture = [textures[@"skybox"] intValue];
    
    LSAnimationMode mode = [[LSView3D mainView] animationMode];
    [self.switchAnimation animate:update_t inMode: mode];
    
    [program loadMVP: self.switchAnimation.modelViewMatrixProjection];
    [program loadCubeTexture: skyboxTexture];
    [program drawFaces:14 offset:0];
    
    glPopGroupMarkerEXT();
}

-(void) renderShadows:(LSProgram3D*)program
{
    glPushGroupMarkerEXT(0, "renderShadows");
    
    // TODO: it should be possible to render the whole object shadow regardless of program ?
    
    for (LSObject3D* object in objects) {
        
        if (!object.cshadow) continue;

        for (LSObject3DFragment* fragment in object.fragments) {
        
            if (fragment.shadowProgram != program) continue;
            
            [object.animation animate:update_t inMode: kLSAnimationModeShadow];
            
//            [context.activeProgram loadOffset: object.offset];
            [program loadMVP: object.animation.modelViewMatrixProjection];
            [program drawFragment:fragment];
        }
    }
    
    glPopGroupMarkerEXT();
    
}

-(void) updateAnimations:(NSTimeInterval)t
{
    update_t = t;
}



@end

