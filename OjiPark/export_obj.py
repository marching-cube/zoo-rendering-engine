import bpy
import sys
 
argv = sys.argv
argv = argv[argv.index("--") + 1:] # get all args after "--"
 
obj_out = argv[0]
 
bpy.ops.export_scene.obj(filepath=obj_out, axis_forward='-Z', axis_up='Y', use_normals=1, use_triangles=1)