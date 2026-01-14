# Controls in Graphs

Chapter III-14 — Controls and Control Panels
III-441
Action Procedures for Multiple Controls
You can use the same action procedure for different controls of the same type, for all the buttons in one 
window, for example. The name of the control is passed to the action procedure so that it can know which 
control was clicked. This is usually the name of the control in the target/active window, which is what most 
control operations assume.
Controls in Graphs
The combination of controls and graphs provides a nice user interface for tinkering with data. You can 
create such a user interface by embedding controls in a graph or by embedding a graph in a control panel. 
This section explains the former technique, but the latter technique is usually recommended. See Chapter 
III-4, Embedding and Subwindows for details.
Although controls can be placed anywhere in a graph, you can and should reserve an area just for controls 
at the edge of a graph window. Controls in graphs operate much more smoothly if they reside in these 
reserved areas. The ControlBar operation (page V-88) or the Control Bar dialog can be used to set the height 
of a nonembedded control area at the top of the graph.
The simplest way to add a panel is to click near the edge of the graph and drag out a control area:
Click just inside the top, right, 
bottom, or left edge of the 
graph.
Drag the dashed line to define the 
inside edge of the embedded panel.
