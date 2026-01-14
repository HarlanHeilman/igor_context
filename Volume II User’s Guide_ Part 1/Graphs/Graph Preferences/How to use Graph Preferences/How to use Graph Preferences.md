# How to use Graph Preferences

Chapter II-13 — Graphs
II-349
in the Miscellaneous Settings dialog, with the Repeat Wave Style Prefs in Graphs checkbox. With that box 
selected, the fifth and sixth waves would get the first and second captured styles; if deselected, they would 
both get the factory default style, as would any other waves subsequently appended to the graph.
The XY Plots:Axes and Axis Labels preferences category captures all of the axis-related settings for axes in 
the graph. Only axes used by XY or waveform plots have their settings captured. Axes used solely for a cat-
egory, image, or contour plot are ignored. The settings for each axis are associated with the name of the axis 
it was captured from.
Even if preferences are on when a new graph with waves is created or when a wave is newly appended to 
an existing graph, the wave is still displayed using the usual default left and bottom axes unless you explic-
itly specify another named axis. The preferred axes are not automatically applied, but they are listed by 
name in the New Graph, and the various Append to Graph dialogs, in the two Axis pop-up menus so that 
you may select them.
For example, suppose you capture preferences for an XY plot using axes named MyRightAxis and MyTo-
pAxis. These names will appear in the X Axis and Y Axis pop-up menus in the New Graph and Append 
Traces to Graph dialogs.
•
If you choose them in the New Graph dialog and click Do It, a graph will be created containing newly-
created axes named MyRightAxis and MyTopAxis and having the axis settings you captured.
•
If you have a graph which already uses axes named MyRightAxis and MyTopAxis and choose these 
axes in the Append Traces to Graph dialog, the traces will be appended to those axes, as usual, but 
no captured axis settings will be applied to these already-existing axes.
Captured axes may also be specified by name on the command line or in a procedure, provided preferences 
are on:
Function AppendWithCapturedAxis(wav)
Wave wav
Variable oldPrefState
Preferences 1; oldPrefState = V_Flag
// Turn preferences on
Append/L=MyCapturedAxis wav
// Note: MyCapturedAxis must
// be vertical to use /L
Preferences oldPrefState
// Restore old prefs setting
End
The Category Plots:Axes and Axis Labels and Category Plots:Wave Styles are analogous to the correspond-
ing settings for XY plots. Since they are separate preference categories, you have can independent prefer-
ences for category plots and for XY plots. Similarly, preferences for image and contour plots are 
independent of preferences for other types. See Chapter II-14, Category Plots, Chapter II-15, Contour Plots, 
and Chapter II-16, Image Plots.
How to use Graph Preferences
Here is our recommended strategy for using graph preferences:
1.
Create a new graph containing a single trace. Use the axes you will normally use.
2.
Make the graph appear as you prefer using the Modify Graph dialog, Modify Trace Appearance 
dialog, the Modify Axis dialog, etc. Move the graph to where you prefer it be positioned.
3.
Choose the GraphCapture Graph Prefs menu to display the Capture Graph Preferences dialog. 
Check the checkboxes corresponding to the categories you want to capture, and click Capture Prefs.
4.
Choose MiscMiscellaneous Settings to display the Miscellaneous Settings dialog. In the Graphs 
section, check the Repeat Wave Style Prefs checkbox, and click Save Settings.
