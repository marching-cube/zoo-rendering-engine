//
//  LSBuffer3D.m
//  OjiPark
//
//  Created by Sowinski Lukasz on 03/02/2013.
//  Copyright (c) 2013 Mouse Inc. All rights reserved.
//

#import "LSBuffer3D.h"
#import "LSProgram3DAttributes.h"

@implementation LSBuffer3D

@synthesize attributes;
@synthesize vertexBuffer;
@synthesize vertexCount;
@synthesize faceBuffer;
@synthesize faceCount;

- (instancetype)init
{
    return [super init];
}

-(instancetype) initWithAttributes:(LSProgram3DAttributes*)theAttributes modelSource:(LSModel3DSourceOBJ*)modelSource
{
    self = [super init];
    if (self) {
        attributes = theAttributes;
        vertexIndexMap = [NSMutableDictionary dictionary];
        _modelSource = modelSource;
    }
    return self;
}

-(void) shiftIndexes:(int)fshift
{
    for (int i=0; i< self.faceCount*3; i++) {
        faceBuffer[i] += fshift;
    }
}

-(void) addFaceFromLine:(NSString*)line
{
    float* v  = ((LSModel3DSourceOBJ*)_modelSource).v;
    float* vt = ((LSModel3DSourceOBJ*)_modelSource).vt;
    float* vn = ((LSModel3DSourceOBJ*)_modelSource).vn;
    
    int perVertex = attributes.size/sizeof(float);
    
    faceBuffer = realloc(faceBuffer, sizeof(GLushort)*(faceCount+1)*3);

    NSArray* vertices = [[line substringFromIndex:2] componentsSeparatedByString:@" "];

    int idx, stride;
    int i = 0;
    for (NSString* vdescription in vertices)
    {
        NSNumber* index = vertexIndexMap[vdescription];
        
        // create new vertex data, if necessary
        if (!index) {
            
            vertexBuffer = realloc(vertexBuffer, sizeof(GLfloat)*(vertexCount+1)*perVertex);
            
            // vertex
            if (attributes.positionSize) {
                idx  = ([vdescription componentsSeparatedByString:@"/"][0]).intValue-1;
                stride = (int)attributes.positionStride/sizeof(float);
                vertexBuffer[perVertex*vertexCount+stride+0] = v[3*idx+0];
                vertexBuffer[perVertex*vertexCount+stride+1] = v[3*idx+1];
                vertexBuffer[perVertex*vertexCount+stride+2] = v[3*idx+2];
            }
            
            // normal
            if (attributes.normalSize) {
                idx = ([vdescription componentsSeparatedByString:@"/"][2]).intValue-1;
                stride = (int)attributes.normalStride/sizeof(float);
                vertexBuffer[perVertex*vertexCount+stride+0] = vn[3*idx+0];
                vertexBuffer[perVertex*vertexCount+stride+1] = vn[3*idx+1];
                vertexBuffer[perVertex*vertexCount+stride+2] = vn[3*idx+2];
            }
            
            // UV
            if (attributes.uvSize) {
                idx = ([vdescription componentsSeparatedByString:@"/"][1]).intValue-1;
                stride = (int)attributes.uvStride/sizeof(float);
                if (idx == -1) printf("error:    missing uv data for line '%s'\n", line.UTF8String);
                vertexBuffer[perVertex*vertexCount+stride+0] =   vt[2*idx+0];
                vertexBuffer[perVertex*vertexCount+stride+1] = 1-vt[2*idx+1];
            }
            
            index = @(vertexCount);
            vertexIndexMap[vdescription] = index;
            vertexCount++;
        }
        
        faceBuffer[3*faceCount+i] = index.unsignedShortValue;
        i++;
    }
    
    faceCount++;

}

-(void) addTangentsAndBinormals
{
    if (attributes.tangentSize == 0) return;
    
    int perVertex = attributes.size/sizeof(float);

    GLKVector3 tangent;
    GLKVector3 binormal;
    
    GLushort* faceCursor = faceBuffer;

    int stride;
    for (int i=0; i<vertexCount; i++)
    {
        while (*faceCursor != i) faceCursor++;
        GLushort face_i = (faceCursor-faceBuffer);
        NSAssert((int)face_i<faceCount*3, @"overflow");
        int indexes[3] = {i, faceBuffer[face_i-face_i%3+(face_i%3+1)%3], faceBuffer[face_i-face_i%3+(face_i%3+2)%3]};
        
        [self calculateTangent:&tangent binormal:&binormal forIndexes:indexes];
        
        // tangent
        if (attributes.tangentSize) {
            stride = (int)attributes.tangentStride/sizeof(float);
            vertexBuffer[perVertex*i+stride+0] = tangent.v[0];
            vertexBuffer[perVertex*i+stride+1] = tangent.v[1];
            vertexBuffer[perVertex*i+stride+2] = tangent.v[2];
        }
        
        // binormal
        if (attributes.binormalSize) {
            stride = (int)attributes.binormalStride/sizeof(float);
            vertexBuffer[perVertex*i+stride+0] = binormal.v[0];
            vertexBuffer[perVertex*i+stride+1] = binormal.v[1];
            vertexBuffer[perVertex*i+stride+2] = binormal.v[2];
        }
    }
}

-(void) calculateTangent:(GLKVector3*)tangent binormal:(GLKVector3*)binormal forIndexes:(int*)indexes
{
    int perVertex = attributes.size/sizeof(float);
    
    GLKVector3 position[3];
    GLKVector3 normal[3];
    GLKVector2 uv[3];

    for (int j=0; j<3; j++) {
        float* ptr = vertexBuffer+indexes[j]*perVertex;
        position[j] = GLKVector3MakeWithArray(ptr+(int)attributes.positionStride/sizeof(float));
        normal[j] = GLKVector3MakeWithArray(ptr+(int)attributes.normalStride/sizeof(float));
        uv[j]  = GLKVector2MakeWithArray(ptr+(int)attributes.uvStride/sizeof(float));
    }
    
    int k = (GLKVector2Distance(uv[0], uv[1]) > 0 ? 1 : 2);

    *tangent = GLKMakeTangent(normal[0], GLKVector3Subtract(position[0], position[k]), GLKVector2Subtract(uv[0], uv[k]));
    *binormal = GLKMakeBinormal(normal[0], *tangent);
    
    NSAssert(GLKVector2Distance(uv[0], uv[k]), @"null dUV");
    NSAssert(!isnan((*tangent).x), @"nan tangent");
}

GLKVector3 GLKMakeTangent(GLKVector3 normal, GLKVector3 dPos, GLKVector2 dUV)
{
    normal  = GLKVector3Normalize(normal);
    dPos = GLKVector3Normalize(dPos);
    dUV  = GLKVector2Normalize(dUV);

    GLKVector3 base0 = GLKVector3Subtract(dPos, GLKVector3MultiplyScalar(normal, GLKVector3DotProduct(dPos, normal)));
    GLKVector3 base1 = GLKVector3CrossProduct(normal, base0);
    
    return GLKVector3Add(GLKVector3MultiplyScalar(base0, dUV.x), GLKVector3MultiplyScalar(base1, dUV.y));
}

GLKVector3 GLKMakeBinormal(GLKVector3 normal, GLKVector3 tangent)
{
    return GLKVector3CrossProduct(tangent, GLKVector3Normalize(normal));
}


#pragma mark -
#pragma mark Statistics

-(void) printFaces
{
    int perVertex = attributes.size/sizeof(float);
    char* format = "$f";
    
    for (int i=0; i<faceCount; i++) {
        for (int j=0; j<3; j++) {
            GLushort idx = perVertex*faceBuffer[3*i+j];
            printf("%d %d ", i, j);
            if (attributes.positionSize) {
                printf(format, vertexBuffer[idx+(int)attributes.positionStride/sizeof(float)+0]);
                printf(format, vertexBuffer[idx+(int)attributes.positionStride/sizeof(float)+1]);
                printf(format, vertexBuffer[idx+(int)attributes.positionStride/sizeof(float)+2]);
            }
            if (attributes.normalSize) {
                printf(format, vertexBuffer[idx+(int)attributes.normalStride/sizeof(float)+0]);
                printf(format, vertexBuffer[idx+(int)attributes.normalStride/sizeof(float)+1]);
                printf(format, vertexBuffer[idx+(int)attributes.normalStride/sizeof(float)+2]);
            }
            if (attributes.uvSize) {
                printf(format, vertexBuffer[idx+(int)attributes.uvStride/sizeof(float)+0]);
                printf(format, vertexBuffer[idx+(int)attributes.uvStride/sizeof(float)+1]);
            }
            printf("\n");
        }
    }
}


@end
