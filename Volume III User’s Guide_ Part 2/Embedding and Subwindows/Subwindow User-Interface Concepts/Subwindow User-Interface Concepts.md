# Subwindow User-Interface Concepts

Chapter III-4 — Embedding and Subwindows
III-84
The graph area is the total area of the graph window. The frame area is the total area of the graph window 
excluding the areas occupied by control bars.
User-defined guides can be based on built-in or other user-defined guides. They can be defined as being 
either a fixed distance from another guide or a relative distance between two guides.
Reference points of a subwindow that can be attached to guides include the outer left, right, top and bottom 
for all subwindow types and, for graphs only, the interior plot area.
Guides are especially useful when creating stacked graphs. By attaching the plot left (PL) location on each 
graph to a user-defined guide, all left axes will be lined up and will move in unison when you drag the 
guide around. This is illustrated in Layout Mode and Guide Tutorial on page III-86.
Frames
You can specify a frame style for each subwindow. Frames, if any, are drawn inside the rectangle that 
defines the location of the subwindow and the normal content is then inset by the frame thickness. Frames 
can also be specified for base graph and panel windows. This is handy when you want to include a frame 
when you export or print a graph. You can adjust the frame for a window or subwindow by right-clicking 
(Windows) or Control-clicking (Macintosh) in drawing mode.
Subwindow User-Interface Concepts
Each host window has two main modes corresponding to the top two icons in 
the window’s tool palette. Choose Show Tools from the Graph or Panel menu 
to show the tool palette. Clicking the top icon selects operate mode and clicking 
the second icon selects drawing mode.
When using subwindows, there is a third mode: subwindow layout mode (see Subwindow Layout Mode 
and Guides on page III-85).
When not using subwindows, a particular window is the target window — the default window for 
command-line commands that do not explicitly specify a window. The addition of subwindows leads to the 
analogous concept of the active subwindow.
You make a subwindow the active subwindow by clicking it. In operate mode the active subwindow is indi-
cated by a green and blue border. In drawing mode it is indicated by a heavy black border with the name 
of the subwindow shown in the upper left corner.
Panel subwindows are exceptions in that clicking them in operate mode does not make them the active sub-
window. You must click them while in drawing mode.
FR
GR
FL and GL
ControlBar/R 78
Operate mode
Drawing mode
