# Axis Relative (Graphs Only)

Chapter III-3 — Drawing
III-67
and then paste it in another smaller window it will be placed where the coordinates specify, even if it is 
offscreen. If you think this has happened, use the Mover pop-up menu to retrieve any offscreen objects or 
expand the window until the stray objects are visible.
Relative
In this mode, coordinates are measured as fractions of the size of the window. Coordinate values x=0, y=0 
represent the top-left corner while x=1,y=1 corresponds to the bottom-right corner. Use this mode if you 
want your drawing object to remain in the same relative position as you change the window size.
This mode will produce near but not exact WYSIWYG results in graphs. This is because the margins of a 
graph depend on many factors and only loosely on the window size. This mode gives good results for 
objects that don’t have to be positioned precisely, such as an arrow pointing from near a trace to near an 
axis. It would not be suitable if you want the arrow to be positioned precisely at a particular data point or 
at a particular spot on an axis. For that you would use one of the next three coordinate systems.
Plot Relative (Graphs Only)
This system is just like Relative except it is based on the plot rectangle rather than the window rectangle. 
The plot rectangle is the rectangle enclosed by the default left and bottom axes and their corresponding 
mirror axes. The coordinates x=0, y=0 represent the top-left corner while x=1,y=1 corresponds to the bottom-
right corner. This is the default and recommended mode for graphs.
The Plot Relative system is ideal for objects that should maintain their size and location relative to the axes. 
A good example is cut marks as used with split axes. In most cases, Plot Relative or Axis Relative is a better 
choice than the more complex Axis-Based (Graphs Only) system discussed below.
Axis Relative (Graphs Only)
This system is just like Plot Relative except it is based on the plot rectangle expanded by any axis standoff. 
If there is no axis standoff, the result is the same as using Plot Relative. Axis standoff is described under 
Axis Tab on page II-307.
Axis Relative coordinates require Igor Pro 9.00 or later.
The Axis Relative system is ideal for objects that should maintain their size and location relative to the axes 
including the standoff areas. A good example is a background highlighting color rectangle that starts or 
ends at the expanded rectangle's edges, avoiding a standoff gap.
The following graphic shows two rectangles, each with an X range of 0 to 1 but using axis relative mode for 
the top rectangle and plot relative mode for the bottom rectangle:
(1,1) Relative
(1,1) Plot Relative
(0,0) Plot Relative
(0,0) Relative
Plot Area
