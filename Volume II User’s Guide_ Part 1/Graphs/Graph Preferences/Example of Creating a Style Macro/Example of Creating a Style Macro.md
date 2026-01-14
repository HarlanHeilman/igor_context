# Example of Creating a Style Macro

Chapter II-13 — Graphs
II-350
Saving and Recreating Graphs
If you click in the close button of a graph window, Igor asks you 
if you want to save a window recreation macro.
Igor presents the graph’s name as the proposed name for the 
macro. You can replace the proposed name with any valid 
macro name.
If you want to make a macro so you can recreate the graph later, click Save. Igor then creates a macro which, 
when invoked, will recreate the graph with its size, position and presentation intact. Igor saves the recre-
ation macro is placed in the procedure window where you can inspect, modify or delete it as you like.
The macro name appears in the Graph Macros submenu of the Windows menu. You can invoke the macro 
by choosing it from that submenu or by executing the macro from the command line. The window name of 
the recreated graph will be the same as the name of the macro that recreated it.
If you are sure that you never want to recreate the graph, you can press Option (Macintosh) or Alt (Windows) 
while you click the close button of the graph window. This closes the graph without presenting the dialog 
and without saving a recreation macro.
For a general discussion of saving, recreating, closing windows, see Chapter II-4, Windows.
Graph Style Macros
The purpose of a graph style macro is to allow you to create a number of graphs with the same stylistic 
properties. Igor can automatically generate a style macro from a prototype graph. You can manually tweak 
the macro if necessary. Later, you can apply the style macro to a new graph.
For example, you might frequently want to make a graph with a certain sequence of markers and colors and 
other such properties. You could use preferences to accomplish this. The style macro offers another way 
and has the advantage that you can have any number of style macros while there is only one set of prefer-
ences.
You create a graph style macro by making a prototype graph, setting each of the elements to your taste and 
then, using the Window Control dialog, instructing Igor to generate a style macro for the window.
You can apply the style macro when you create a graph using the New Graph dialog. You can also apply it 
to an existing graph by choosing the macro from the Graph Macros submenu of the Windows menu.
Example of Creating a Style Macro
As an example, we will create a style macro that defines the color and line type of five traces.
Since we want our style macro to define a style for five traces, we start by making a graph with five waves:
Make wave0=p, wave1=10+p, wave2=20+p, wave3=30+p, wave4=40+p
Display wave0, wave1, wave2, wave3, wave4
Now, using the Modify Trace Appearance dialog, we set the color and line style for each of the waves to 
our liking.
Now we're ready to generate the style macro. With the graph the active window, we choose Win-
dowsControlWindow Control to display the Window Control dialog in which we check the Create 
Style Macro checkbox.
