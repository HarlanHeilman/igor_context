# GraphWaveDraw, GraphWaveEdit, and GraphNormal

Chapter III-3 — Drawing
III-75
As you can see from the format of the commands, generally all you specify in the commands themselves 
are the coordinates. Properties such as color and line thickness are specified by SetDrawEnv commands 
preceding the Draw<object> commands. The exception is DrawText where you specify the text to be drawn.
DrawPoly and DrawBezier Operations
The DrawPoly operation on page V-176 and DrawBezier operation on page V-174 come in the following 
two types:
•
Literal: You can specify the vertices or control points with a set of literal numbers. (Polygons and 
bezier curves created interactively are always of the literal variety.)
•
Wave: You can use waves to define the vertices or control points.
Because polygons and bezier curves can be of unlimited length, the /A flag allows object definitions to 
extend over multiple lines.
It is legal to specify a polygon with only a single point. Use this to set up a loop to append vertices to the 
origin vertex. Note that if you fail to add vertices and leave the polygon with just one vertex then the user 
will not be able to see or select the polygon.
Literal Versus Wave
As a programmer, you must choose either the literal or the wave polygon type when creating a polygon or 
bezier curve. This section explains the differences between the two.
The advantage of the literal method is that it does not clutter the experiment with numerous waves that may 
be distracting to the user. It also has the advantage that all such objects are independent of one another.
With the wave method, objects are not independent. If the user duplicates an object, or runs a window recreation 
macro several times, then all the objects would be linked via the wave. If the user then edits one of the objects, 
those edits would affect all of the associated objects; this could also be considered an advantage of the method.
A disadvantage of the literal method is that when Igor creates a recreation macro for a window containing 
literal method objects then all of the vertices or control points have to be specified in text. This can create 
huge macros that take a lot of time to create and to run. Because Igor uses the recreation macro technique 
when saving and restoring experiments, the use of large literal method objects can dramatically lengthen 
experiment save and restore time.
Wave method objects do not have this disadvantage. One nifty feature of the wave method is that you can 
read back the vertices or control points after the user has edited the object. Another advantage of the wave 
method is that you can calculate new vertices or control points at any time and the dependent objects will 
be automatically updated. 
Screen Representation
It is important to note that the value of the first polygon vertex does not determine the location of the first 
vertex on the screen. The location is specified by the xOrg, yOrg parameters. Effectively the value of the first 
vertex is subtracted from all the vertices and then the value of the origin is added to all vertices. Thus the fol-
lowing commands create the exact same representation on the screen:
DrawPoly 120,50,1,1,{0,0,20,40,60,15}
DrawPoly 120,50,1,1,{200,300,220,340,260,315}
When programming, the first vertex is usually 0,0. The hScaling, vScaling parameters are probably not of 
any interest to programmers; use 1 for both values.
GraphWaveDraw, GraphWaveEdit, and GraphNormal
These operations relate to graph modes that are only tangentially related to drawing.
•
GraphWaveDraw puts the graph in a mode where the user can draw a wave using the same user 
interface as polygon drawing.
•
GraphWaveEdit allows the user to edit a wave using the same user interface as polygon editing.
