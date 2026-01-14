# Quad Objects

Chapter II-17 — 3D Graphics
II-438
Quad Objects
A quad object fills the sheet connecting the four vertices that are positioned sequentially in any direction 
starting from the first vertex. A quad object is always drawn filled. The fill color is determined by the inter-
nal color attribute, an embedded color attribute, or a global color attribute, in that order of precedence. 
Normals to the quad are calculated on a per-vertex basis. This gives rise to gradual shading when lighting 
calculations are enabled. For example, here are commands to create a quad:
AppendToGizmo/D quad={1,0,1,-1,0,1,-1,0,0,1,0,0}
ModifyGizmo modifyObject=quad0, objectType=quad, property={colorType,2}
ModifyGizmo modifyObject=quad0, objectType=quad, 
property={colorValue,0,1,0,0,1}
ModifyGizmo modifyObject=quad0, objectType=quad, 
property={colorValue,1,1.5259e-05,0.6,0.30425,1}
ModifyGizmo modifyObject=quad0, objectType=quad, 
property={colorValue,2,1.5259e-05,0.244434,1,1}
ModifyGizmo modifyObject=quad0, objectType=quad, 
property={colorValue,3,0,0,0,1}

Chapter II-17 — 3D Graphics
II-439
When creating a quad, you may find it easier to create the quad using simple coordinates in either the X, Y, 
or Z planes and then use translate and rotate operations to position the quad in the desired final orientation.
This table lists some basic quad examples with unit dimensions.
Here is what the seven quads described in the table look like after applying different colors:
Quad Orientation
Command
XZ Plane
quad={1,0,1,-1,0,1,-1,0,-1,1,0,-1}
XY Plane
quad={1,1,0,-1,1,0,-1,-1,0,1,-1,0}
YZ Plane
quad={0,1,1,0,1,-1,0,-1,-1,0,-1,1}
Oblique Z Plane, +X, +Y
quad={1,0,1,1,0,-1,0,1,-1,0,1,1}
Oblique Z Plane, -X, +Y
quad={-1,0,1,-1,0,-1,0,1,-1,0,1,1}
Oblique Z Plane, -X, -Y
quad={-1,0,1,-1,0,-1,0,-1,-1,0,-1,1}
Oblique Z Plane, +X, -Y
quad={1,0,1,1,0,-1,0,-1,-1,0,-1,1}
