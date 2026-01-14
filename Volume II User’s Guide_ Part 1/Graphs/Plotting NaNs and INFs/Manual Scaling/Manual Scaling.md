# Manual Scaling

Chapter II-13 — Graphs
II-285
You can override the default, instructing Igor to draw lines through NaNs. See Gaps on page II-303 for details.
Scaling Graphs
Igor provides several ways of scaling waves in graphs. All of them allow you to control what sections of your 
waves are displayed by setting the range of the graph’s axes. Each axis is either autoscaled or manually scaled.
Autoscaling
When you first create a graph all of its axes are in autoscaling mode. This means that Igor automatically 
adjusts the extent of the axes of the graph so that all of each wave in the graph is fully in view. If the data 
in the waves changes, the axes are automatically rescaled so that all waves remain fully in view.
If you manually scale any axis, that axis changes to manual scaling mode. The methods of manual scaling 
are described in the next section. Axes in manual scaling mode are never automatically scaled.
If you choose Autoscale Axes from the Graph menu all of the axes in the graph are autoscaled and returned 
to autoscaling mode. You can set individual axes to autoscaling mode and can control properties of auto-
scaling mode using the Axis Range tab of the Modify Axis dialog described in Setting the Range of an Axis 
on page II-286.
Manual Scaling
You can manually scale one or more axes of a graph using the mouse. Start by clicking the mouse and drag-
ging it diagonally to frame the region of interest. Igor displays a dashed outline around the region. This 
outline is called a marquee. A marquee has handles and edges that allow you to refine its size and position.
To refine the size of the marquee move the cursor over one of the handles. The cursor changes to a double 
arrow which shows you the direction in which the handle moves the edge of the marquee. To move the 
edge click the mouse and drag.
To refine the position of the marquee move the cursor over one of the edges away from the handles. The 
cursor changes to a hand. To move the marquee click the mouse and drag.
When you click inside the region of interest Igor presents a pop-up menu from which you can choose the 
scaling operation.
Choose the operation you want and release the mouse. These operations can be undone and redone; just 
press Command-Z (Macintosh) or Ctrl+Z (Windows).
The Expand operation scales all axes so that the region inside the marquee fills the graph (zoom in). It sets 
the scaling mode for all axes to manual.
The Horiz Expand operation scales only the horizontal axes so that the region inside the marquee fills the graph 
horizontally. It has no effect on the vertical axes. It sets the scaling mode for the horizontal axes to manual.
The Vert Expand operation scales only the vertical axes so that the region inside the marquee fills the graph 
vertically. It has no effect on the horizontal axes. It sets the scaling mode for the vertical axes to manual.
1.5
1.0
0.5
0.0
120
100
80
60
40
20
0
-INF at X = 64
NaN at X = 40
