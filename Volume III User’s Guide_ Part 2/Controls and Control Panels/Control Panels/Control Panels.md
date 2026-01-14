# Control Panels

Chapter III-14 — Controls and Control Panels
III-442
The background color of a control area or embedded panel can be set by clicking the background to exit any 
subwindow layout mode, then Control-clicking (Macintosh) or right-clicking (Windows) in the background, 
and then selecting a color from the contextual menu’s pop-up color palette. See Control Background Color 
on page III-437 for details.
The contextual menu adjusts the style of the frame around the panel.
You can use the same contextual menu to remove an embedded panel, leaving only the bare control area 
underneath. Remove the control area by dragging the inside edge back to the outside edge of the graph.
Drawing Limitations
The drawing tools can not be used in bare control areas of a graph. If you want to create a fancy set of con-
trols with drawing tools, you have to embed a panel subwindow into the graph.
Updating Problems
You may occasionally run into certain updating problems when you use controls in graphs. One class of 
update problems occurs when the action procedure for one control changes a variable used by a ValDisplay 
control in the same graph and also forces the graph to update while the action procedure is being executed. 
This short-circuits the normal chain of events and results in the ValDisplay not being updated.
You can force the ValDisplay to update using the ControlUpdate operation (page V-94). Another solution 
is to use a control panel instead of a graph.
The ControlUpdate operation can also solve problems in updating pop-up menus. This is described above 
under Creating PopupMenu Controls on page III-426.
Control Panels
Control panels are windows designed to contain controls. The NewPanel creates a control panel.
Drawing tools can be used in panel windows to decorate control panels. Control panels have two drawing 
layers, UserBack and ProgBack, behind the controls and one layer, Overlay, in front of the controls. See 
Drawing Layers on page III-68 for details.
PRight is the name of the resulting 
embedded panel subwindow. The 
label disappears in “operate” mode.
Adjust the position of the embedded 
window by clicking the subwindow frame 
and dragging its handles. The dashed 
lines represent the edges of the plot and 
graph areas, and the subwindow frame 
snaps and attaches to them.
