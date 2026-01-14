# Graph Expansion

Chapter II-13 — Graphs
II-352
1.
Open the New Graph dialog, select the waves to be displayed in the graph, and choose Graph0Style 
from the Style pop-up menu in the dialog. Click Do It.
Igor automatically generates the Preferences Off and Preferences On commands to apply the style to the 
new graph without being affected by preferences.
Limitations of Style Macros
Igor automatically generates style macro commands to set all of the properties of a graph that you set via 
the ModifyGraph, Label and SetAxis operations. These are the properties that you set using the Modify 
Trace Appearance, Modify Graph, and Modify Axis dialogs.
It does not generate commands to recreate annotations or draw elements. Igor’s assumption is that these 
things will be unique from one graph to the next. If you want to include commands to create annotations 
and draw elements in a graph, you must add the appropriate commands to the macro.
Where to Store Style Macros
If you want a style macro to be accessible from a single experiment only, you should leave them in the main 
procedure window of that experiment. If you want a style macro to be accessible from any experiment then 
you should store it in an auxiliary procedure file. See Chapter III-13, Procedure Windows for details.
Graph Pop-Up Menus
There are a number of contextual pop-up menus that you can use to quickly set colors and other graph 
properties. To display a contextual menu on Macintosh, press the Control key and click. On Windows, click 
using the right mouse button.
Different contextual menus are available for clicks on traces, the interior of a graph (but not on a trace) and 
axes. If you press the Shift key before a contextual click on a trace or axis, the menu will apply to all traces 
or axes in the graph.
Sometimes it is difficult to contextual click in the plot area of a graph and not hit a trace. In this case, try 
clicking outside the plot area, but not on an axis.
Graph Expansion
Normally, graphs are shown actual size but sometimes, when working with very small or very large 
graphs, it is easier to work with an expanded or contracted screen representation. You can set an expansion 
or contraction factor for a graph using the Expansion submenu in the Graph menu or using the contextual 
menu for the graph body, away from traces or axes.
The expansion setting affects only the screen representation. It does not affect printing or exporting.
