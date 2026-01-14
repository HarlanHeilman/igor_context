# Creating Graphs

Chapter II-13 — Graphs
II-277
data readouts as you glide the cursors through your data (see Info Panel and Cursors). You can edit your 
data graphically (see Drawing and Editing Waves on page III-73).
Igor graphs are fast. They are updated almost instantly when you make a change to your data or to the 
graph. In fact, Igor graphs can be made to update in a nearly continuous fashion to provide a real-time oscil-
loscope-like display during data acquisition (see Live Graphs and Oscilloscope Displays)
You can also control virtually every detail of a graph. When you have the graph just the way you like it, you 
can create a template called a “style macro” to make it easy to create more graphs of the same style in the 
future (see Graph Style Macros). You can also set preferences from a reference graph so that new graphs 
will automatically be created with the settings you prefer (see Graph Preferences).
You can print or export graphs directly, or you can combine several graphs in a page layout window prior to 
printing or exporting. You can export graphs and page layouts in a wide variety of graphics formats.
A graph can exist as a standalone window or as a subwindow of another graph, a page layout, or a control 
panel (see Embedding and Subwindows on page III-79).
The Graph Menu
The Graph menu contains items that apply only to graph windows. The menu appears in the menu bar only 
when the active or target window is a graph.
When you choose an item from the Graph menu it affects the top-most graph.
Typing in Graphs
If you type on the keyboard while a graph is the top window, Igor brings the command window to the front 
and your typing goes into the command line. (The only exception to this is when a graph contains a selected 
SetVariable control.)
Graph Names
Every graph that you create has a window name which you can use to manipulate the graph from the 
command line or from a procedure. When you create a new graph, Igor assigns it a name of the form 
“Graph0”, “Graph1” and so on. When you close a graph, Igor offers to create a window recreation macro 
which you can invoke later to recreate the graph. The name of the window recreation macro is the same as 
the name of the graph.
The graph name is not the same as the graph title which is the text that appears in the graph’s window frame. 
The name is for use in procedures but the title is for display purposes only. You can change a graph’s name 
and title using the Window Control dialog which you can access by choosing Win-
dowsControlWindow Control.
Creating Graphs
You create a graph by choosing New Graph from the Windows menu.
You can also create a graph by choosing New Category Plot, New Contour Plot or New Image Plot from 
the New submenu in the Windows menu.
You select the waves to be displayed in the graph from the Y Waves list. The wave is displayed as a trace 
in the graph. A trace is a visual representation of a wave or an XY pair. By default a trace is drawn as a series 
of lines joining the points of the wave or XY pair.
Each trace has a name so you can refer to it from a procedure. By default, the trace name is he same as the 
wave name or Y wave in the case of an XY pair. However, there are exceptions. If you display the same 

Chapter II-13 — Graphs
II-278
wave multiple times in a given graph, the traces will have names like wave0, wave0#1, and wave0#2. wave0 
is equivalent to wave0#0. Such names are called trace instance names.
You can also programmatically specify a trace’s name using the Display or AppendToGraph operations. 
This is something an Igor programmer would do, typically to better distinguish multiple traces with the 
same Y wave.
Often the data values of the waves that you select in the Y Waves list are plotted versus their calculated X 
values. This is a waveform trace. The calculated X values are derived from the wave’s X scaling; see Wave-
form Model of Data on page II-62.
If you want to plot the data values of the Y waves versus the data values of another wave, select the other 
wave in the X Wave list. This is an XY trace. In this case, X scaling is ignored; see XY Model of Data on page 
II-63.
If the lengths of the X and Y waves are not equal, then the number of points plotted is determined by the 
shorter of the waves.
The New Graph dialog has a simple mode and an advanced mode. In the simple mode, you can select mul-
tiple Y waves but just one X wave. If you have multiple XY pairs with distinct X waves, click the More 
Choices button to use the advanced mode. This allows you to select a different X wave for each Y wave.
You can specify a title for the new window. The title is not used except to form the title bar of the window. 
It is not used to identify windows and does not appear in the graph. If you specify no title, Igor will choose 
an appropriate title based on the traces in the graph and the graph name. Igor automatically assigns graph 
names of the form “Graph0”. The name of a window is important because it is used to identify windows in 
commands. The title is for display purposes only and is not used in commands.
If you have created style macros for the current experiment they will appear in the Style pop-up menu. See 
Graph Style Macros on page II-350 for details.
Normally, the new graph is created using left and bottom axes. You can select other axes using the pop-up 
menus under the X and Y wave lists. Picking L=VertCrossing automatically selects B=HorizCrossing and 
vice versa. These free axes are used when you want to create a Cartesian type plot where the axes cross at 
(0,0).
You can create additional free axes by choosing New from the pop-up menu. This displays the New Free 
Axis dialog. Axes created this way are called “free axes” because they can be freely positioned nearly any-
where in the graph window. The standard left, bottom, right, and top axes always remain at the edge of the 
plot area.
You should give the new axis a name that describes its intended use. The name must be unique within the 
current graph and can’t contain spaces or other nonalphanumeric characters. The Left and Right radio 
buttons determine the side of the axis on which tick mark labels will be placed. They also define the edge 
of the graph from which axis positioning is based.
You can create a blank graph window containing no traces or axes by clicking the Do It button without selecting 
any Y waves to plot. Blank graph windows are mostly used in programming when traces are appended later 
using AppendToGraph.
The New Graph dialog comes in two versions. The simpler version shown above is suitable for most pur-
poses. If, however, you have multiple pairs of XY data or when you will be using more than one pair of axes, 
you can click the More Choices button to get a more complex version of the dialog.
Using the advanced mode of the New Graph dialog, you can create complex graphs in one step. You select 
a wave or an XY pair using the Y Waves and X Wave lists, and then click the Add button. This moves your 
selection to the trace specification list below. You can then add more trace specifications using the Add 
button. When you click Do It, your graph is created with all of the specified traces.
