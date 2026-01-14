# Drawing Layers

Chapter III-3 — Drawing
III-68
Both rectangles use axis-based coordinates, described next, for their Y coordinates.
Axis-Based (Graphs Only)
The pop-up menu for the X coordinate system includes a list of the horizontal axes and the pop-up menu 
for the Y coordinate includes a list of the vertical axes. When you choose an axis coordinate system, the posi-
tion on the screen is calculated just as it is for wave data plotted against that axis, with the exception that 
drawing object coordinates are not limited to the plot area. This mode is ideal when you want an object to 
stick to a feature in a wave even if you zoom in and out.
Axes are treated as if they extend to infinity in both directions. For this reason along with the fact that axis 
ranges can be very dynamic, it is very easy to end up with objects that are offscreen. You can use the Mover 
pop-up menu Retrieve submenu to retrieve objects or, if you press Option (Macintosh) or Alt (Windows) before 
clicking the Mover icon, you can edit the numerical coordinates of each offscreen object. You can also end up 
with objects that are huge or tiny. It is best to have the graph in near final form before using axis-based 
drawing objects.
Axis-based coordinates are of particular interest to programmers but are also handy for a number of inter-
active tasks. For example you can easily create a rectangle that shades an exact area of a plot. If you use axis 
coordinate systems then the rectangle remains correct as the graph is resized and as the axis ranges are 
changed. You can also create precisely positioned drop lines and scale (calibrator) bars.
Drawing Layers
Layers allow you to control the front-to-back layering of drawing objects relative to other window compo-
nents. For example, if you want to demarcate a region of interest in a graph, you can draw a shaded rectan-
gle into a layer behind the graph traces. If you drew the same rectangle into a layer above the traces then 
the traces would be covered up.
Each window type supports a number of separate drawing layers. For example, in graphs, Igor provides 
three pairs of drawing layers. You can see the layer structure for the current window and change to a dif-
ferent layer by clicking the layer icon. The current layer is indicated by a check mark.
Drawing layers have names. This table shows the names of the layers and which window types support 
which layers:
Graphs
Page Layouts
Control Panels
ProgBack
ProgBack
ProgBack
UserBack
UserBack
UserBack
ProgAxes
Standoff Gap
-0.2
-0.1
0.0
0.1
0.2
11.0
10.9
10.8
10.7
10.6
10.5
10.4
10.3
10.2
10.1
10.0
DrawRect with xcoord = axrel (Axis Relative)
DrawRect with xcoord = prel (Plot Relative)
