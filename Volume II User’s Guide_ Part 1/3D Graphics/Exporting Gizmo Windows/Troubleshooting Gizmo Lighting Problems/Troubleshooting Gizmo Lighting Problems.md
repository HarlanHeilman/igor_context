# Troubleshooting Gizmo Lighting Problems

Chapter II-17 — 3D Graphics
II-469
Matrix4x4 Objects
Matrix4x4 objects are used with Gizmo operations that affect the transformation matrix. The encapsulate a 
2D wave with 4 rows and 4 columns.
Gizmo Subwindows
You can embed a Gizmo subwindow in a graph, panel or layout window. Here is a simple example:
NewPanel/N=MyPanel
NewGizmo/HOST=MyPanel/JUNK=2
You can direct any ModifyGizmo commands using full subwindow specification. For example, to change 
the colormap of the demo surface you can execute:
ModifyGizmo/N=MyPanel#GZ0 modifyObject=sampleSurface, objectType=surface, 
property={surfaceCTab,Blue}
For more information see Subwindow Syntax on page III-92.
Gizmo Troubleshooting
This section provides tips for resolving problems you may encounter while using Gizmo.
Troubleshooting Gizmo Lighting Problems
1.
Make sure that the light object appears in the display list above the objects that you expect to be illumi-
nated.
2.
Check that your light specifies non-black colors for the ambient, diffuse and specular components.
3.
Start with directional light which has fewer options than positional light with less to go wrong. Open 
the Light Properties dialog, check the Live Update checkbox, change the direction controls and check 
for changes in the scene. If you do not see changes in the scene then the direction of the light is more 
than likely not the problem.
4.
Verify that you have checked the Compute Normals checkbox for each object that you expect to be illu-
minated.
5.
Check that the normal orientation is what you expect. In the case of quadric objects, toggle the normals 
orientation between inside and outside. For other objects, consider the definitions of front and back sur-
faces. If you have doubt, add a front face operation to the display list right before an object. The opera-
tion allows you to define the direction representing front and back surfaces.
