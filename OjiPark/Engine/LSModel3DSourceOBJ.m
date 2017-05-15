//
//  LSModel3DSourceOBJ.m
//  miniEngine3D
//
//  Created by Sowinski Lukasz on 7/31/12.
//  Copyright (c) 2012 Lukasz Sowinski. All rights reserved.
//

#import "LSModel3DSourceOBJ.h"
#import "LSMaterial3D.h"
#import "LSMaterial3DCache.h"
#import "NSExtensions.h"

@interface LSModel3DSourceOBJ () 
@end

@implementation LSModel3DSourceOBJ

#pragma mark -
#pragma mark OBJ files

-(instancetype) init {
    self = [super init];
    if (self) {
        _entries = [NSMutableDictionary dictionary];
    }
    return self;
}

-(instancetype) initWithSourceName:(NSString*)aName {
    self = [self init];
    [self processOBJSource:aName];
    return self;
}

-(void) processOBJSource:(NSString*)aName {
    _name = aName.stringByDeletingPathExtension;
    [self processOBJSourceVertices];
    
    [[LSMaterial3DCache sharedCache] processOBJSourceMaterials: _name];
}

-(void) processOBJSourceVertices {
        
    const int kUnitBufferSize = 1000;
    
    NSString* fname = [[NSBundle mainBundle] extendedPathForResource:_name ofType:@"obj"];
    NSString* raw   = [NSString stringWithContentsOfFile:fname encoding:NSUTF8StringEncoding error:nil];
    NSArray*  lines = [raw componentsSeparatedByString:@"\n"];
    
    if (!fname) {
        NSLog(@"Model file not found!");
        return;
    }
    
    _v_size  = 0;
    _vt_size = 0;
    _vn_size = 0;
    
    LSModel3DSourceOBJEntry* entry = nil;
    
    int vertexHook;
    GLKVector3 box0;
    GLKVector3 box1;
    GLKVector3 gravity;
    
    // TODO: drop gravityCount, if possible
    int gravityCount = 0;

    NSRange   objectRange = NSMakeRange(0, 0);
    NSString* mtlKey = nil;
    int i = 0;
    for (NSString* line in lines) {
        
        NSArray* components = [line componentsSeparatedByString:@" "];
        
        bool lastLine = (i+1 == lines.count);
        
        if ([line hasPrefix:@"usemtl "]) {
            mtlKey = [line substringFromIndex:(@"usemtl ").length];
            entry.materialKey = mtlKey;
        }
        
        if ([line hasPrefix: @"o "] || lastLine) {
            if (objectRange.length > 0 && entry) {
                if (lastLine) objectRange.length++;
                entry.faces = [[lines subarrayWithRange:objectRange] componentsJoinedByString:@"\n"];
                entry.box0 = box0; // TODO: this will omit the last point of the file
                entry.box1 = box1;
                entry.firstVertex = GLKVector3MakeWithArray(_v+vertexHook);
                entry.gravity = GLKVector3MultiplyScalar(gravity, 1.0/gravityCount);
            }
        }
        
        if ([line hasPrefix: @"o "]) {
            entry = [[LSModel3DSourceOBJEntry alloc] init];
            entry.name = [line substringFromIndex:2];
            objectRange = NSMakeRange(0, 0);
            _entries[entry.name] = entry;
            box0 = entry.box0;
            box1 = entry.box1;
            gravity = GLKVector3Make(0, 0, 0);
            gravityCount = 0;
            vertexHook = 3*_v_size;
        }
        if ([line hasPrefix: @"v " ]) {
            if (_v_size % kUnitBufferSize == 0) {
                _v  = realloc(_v, 3*sizeof(float)*(_v_size+kUnitBufferSize));
            }
            _v[3*_v_size+0] = [components[1] floatValue];
            _v[3*_v_size+1] = [components[2] floatValue];
            _v[3*_v_size+2] = [components[3] floatValue];
            _v_size++;
        }
        
        if ([line hasPrefix: @"vn " ]) {
            if (_vn_size % kUnitBufferSize == 0) {
                _vn  = realloc(_vn, 3*sizeof(float)*(_vn_size+kUnitBufferSize));
            }
            _vn[3*_vn_size+0] = [components[1] floatValue];
            _vn[3*_vn_size+1] = [components[2] floatValue];
            _vn[3*_vn_size+2] = [components[3] floatValue];
            _vn_size++;
            if ([components[1] floatValue] == 0 && [components[2] floatValue] == 0 && [components[3] floatValue] == 0) {
                printf("Error:     null normal (#%d)!\n", _vn_size);
            }
        }
        
        if ([line hasPrefix: @"vt " ]) {
            if (_vt_size % kUnitBufferSize == 0) {
                _vt  = realloc(_vt, 2*sizeof(float)*(_vt_size+kUnitBufferSize));
            }
            _vt[2*_vt_size+0] = [components[1] floatValue];
            _vt[2*_vt_size+1] = [components[2] floatValue];
            _vt_size++;
        }
        
        if ([line hasPrefix: @"f " ] || [line hasPrefix: @"usemtl "] || [line hasPrefix: @"s " ]) {
            if (!objectRange.location) objectRange.location = i;
            objectRange.length = i-objectRange.location+1;
        }
        
        if ([line hasPrefix: @"f " ]) {
            for (NSString* index_str in components) {
                if ([index_str isEqualToString:@"f"]) continue;
                int index = ([index_str componentsSeparatedByString:@"/"][0]).intValue-1;
                for (int j=0; j<3; j++) {
                    box0.v[j] = MIN(box0.v[j], _v[3*index+j]);
                    box1.v[j] = MAX(box1.v[j], _v[3*index+j]);
                    gravity.v[j] += _v[3*index+j];
                }
                gravityCount++;
            }
        }
        
        i++;
        
    }
    
    if (_v_size)   _v=realloc(_v,  3*sizeof(float)* _v_size);
    if (_vn_size) _vn=realloc(_vn, 3*sizeof(float)*_vn_size);
    if (_vt_size) _vt=realloc(_vt, 2*sizeof(float)*_vt_size);
    
}

-(void)dealloc {
    free(_v);
    free(_vt);
    free(_vn);
}

@end


@implementation LSModel3DSourceOBJEntry
-(instancetype) init {
    self = [super init];
    if (self) {
        self.box0 = GLKVector3Make( FLT_MAX,  FLT_MAX,  FLT_MAX);
        self.box1 = GLKVector3Make(-FLT_MAX, -FLT_MAX, -FLT_MAX);
    }
    return self;
}
@end

