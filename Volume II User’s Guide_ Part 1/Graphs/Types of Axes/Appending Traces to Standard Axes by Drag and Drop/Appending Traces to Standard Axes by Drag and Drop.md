# Appending Traces to Standard Axes by Drag and Drop

Chapter II-13 — Graphs
II-280
Appending Traces 
You can append waves to a graph as a waveform or XY plot by choosing Append Traces to Graph from the 
Graph menu. This presents a dialog identical to the New Graph dialog except that the title and style macro 
items are not present. Like the New Graph dialog, this dialog provides a way to create new axes and pairs 
of XY data. The Append to Graph submenu in the Graph menu allows you to append category plots, 
contour plots and image plots.
Appending Traces by Drag and Drop
You can append waves to a graph by dragging them from the Data Browser or from the Waves in Window 
list of the Window Browser.
The following sections present a guided tour showing how to use drag and drop. You can execute the 
example commands by selecting the line or lines and pressing Control-Enter (Macintosh) or Ctrl+Enter (Win-
dows).
Drag and Drop Tour
1.
Choose File->New Experiment.
2.
Execute this command to create waves used in the tour:
Make/O wave0=sin(x/8), wave1=cos(x/8), wave2=wave0*wave1, xwave=x/8
3.
Choose Data->Data Browser.
We will drag icons from the Data Browser into a graph window.
4.
Execute this command to create an empty graph:
Display
Appending Traces to Standard Axes by Drag and Drop
You can append a trace using any of the four standard axes by dragging and hovering over the Left, Top, 
Right, or Bottom drop targets shown below. Dropping a wave in the middle of the graph appends a trace 
using the left and bottom axes.
1.
Select wave0 in the Data Browser and drag it to the middle of the graph.
When the mouse enters the graph, a number of drop targets appear.
2.
Release the mouse to drop the wave in the middle of the graph window.
Dropping the wave in the middle of the graph adds a trace to the left and bottom axes. An Append-
ToGraph command appears in the history area of the command window.
