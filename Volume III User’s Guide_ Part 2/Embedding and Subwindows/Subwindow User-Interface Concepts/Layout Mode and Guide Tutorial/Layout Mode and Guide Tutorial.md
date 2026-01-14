# Layout Mode and Guide Tutorial

Chapter III-4 — Embedding and Subwindows
III-86
more handles are attached to guides and you drag the subwindow using the frame, all attachments are 
deleted.
A graph subwindow is drawn using two frames. The inner frame represents the plot area of the graph. Its 
handles can be attached to guides to allow easy alignment of multiple graph subwindows.
You can create user-defined guides by pressing Alt (Windows) or Option (Macintosh) and then click-drag-
ging an existing guide. By default, the new guide will be a fixed distance from its parent.
You can convert the new guide to relative mode, where the guide position is specified as a fraction of the 
distance between two other guides. You do this by right-clicking (Windows) or Control-click (Macintosh) on 
the new guide to display a contextual menu and then choosing a partner guide from the “make relative to” 
submenu.
You can also use the contextual menu to convert a relative guide to fixed or to delete a guide, if it is not in 
use.
The contextual menu appears only for user-defined guides, not for built-in guides.
Layout Mode and Guide Tutorial
In a new experiment, execute these commands:
Make/O jack=sin(x/8),sam=cos(x/8)
Display
Display/HOST=# jack
ShowTools/A
The first Display command created an empty graph and the second inserted a subgraph. The graph is in 
operate mode and it looks like this:
Click the lower icon in the tool palette to enter drawing mode and notice the subwindow is drawn with a 
black frame with the name of the subwindow (G0):

Chapter III-4 — Embedding and Subwindows
III-87
Use the arrow tool to click on the black frame around the subgraph. You are now in subwindow layout 
mode as indicated by the rectangles with handles on each edge of the subgraph.
Position the mouse over the outer rectangle until the cursor changes to a four-headed arrow. Drag the sub-
window up as high as it will go and then drag the bottom handle up to just above the halfway point so that 
the subgraph is in the upper half of the window.
Click outside the subwindow to leave subwindow layout mode and then click again to select the main 
(empty) graph as the active subwindow. Right-click (Windows) or Control-click (Macintosh) below the sub-
graph and choose the NewGraph from the pop-up menu:

Chapter III-4 — Embedding and Subwindows
III-88
Pick sam as the Y wave in the resulting dialog and click Do It. This creates a new subwindow and makes it 
active. Click on the heavy frame to enter subwindow layout mode for the new subgraph and position it in 
the lower half of the window.
While still in subwindow layout mode for the second graph, notice the red and green dashed lines around 
the periphery. These are fixed guides and are properties of the base window. Press Alt (Windows) or Option 
(Macintosh) and move the mouse over the left hand dashed line. When you notice the cursor changing to a 
two headed arrow, click and drag to the right about 3 cm to create a user-defined guide.
Use the same technique to create another user-defined guide based on the right edge also inset by about 3 
cm:
Move the mouse over the new guides and notice the cursor changes to a two headed arrow indicating they 
can be moved.
While still in subwindow layout mode for the second graph, click in the black handle centered on the left 
axis and drag the handle over the position of the left user guide. Notice that it snaps into place when it is 
near the guide. Release the mouse button and use the same technique to connect the right edge of the plot 
area to the right user guide.
Now place the top subgraph in subwindow layout mode and connect its left and right plot area handles to 
the user guides:

Chapter III-4 — Embedding and Subwindows
III-89
While still in subwindow layout mode, drag the user guides around and notice that both graphs follow.
The two guides we created are a fixed distance from another guide (the frame left (FL) and frame right (FR) 
in this case). We will now create a relative guide.
Press Alt (Windows) or Option (Macintosh) and move the mouse over the bottom dashed line near the 
window frame. When you notice the cursor changing to a two headed arrow, click and drag up to about the 
middle of the graph to create another user-defined guide. Position the mouse over the new guide, right-
click (Windows) or Control-click (Macintosh), and choose Make Relative toFT from the pop-up menu.
Now, as you resize the window, the guide remains at the same relative distance between the bottom (FB) 
and the top (FT).
Use the handles to attach the bottom of the top graph to the new guide and then put the bottom graph into 
subwindow layout mode and attach its top to the guide:
