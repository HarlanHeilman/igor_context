# How to Use Category Plot Preferences

Chapter II-14 — Category Plots
II-364
The names of captured category plot axes are listed in the X Axis pop-up menu of the New Category Plot 
and Append Category Plot dialogs.
For example, suppose you capture preferences for a category plot that was created with the command:
AppendToGraph/R=myRightAxis/T=myTopAxis ywave vs textwave
Since only the X axis is a category axis, “myTopAxis” appears in the X Axis pop-up menu in the category 
plot dialogs. The Y Axis pop-up menu is unaffected.
•
If you choose “myTopAxis” in the X Axis pop-up menu of the New Category Plot dialog and click 
Do It, a graph is created containing a newly-created X axis named “myTopAxis” and having the axis 
settings you captured.
•
If you have a graph which already uses an axis named “myTopAxis” as a category axis and you 
choose it from the X Axis pop-up menu in the Append Category Plot dialog, the category plot uses 
the axis, but no captured axis settings are applied to it.
You can capture category plot axis settings for the standard left or bottom axis, and Igor will save the set-
tings separately from left and bottom axis preferences captured for XY, image, and contour plots.
Category Plot Wave Styles
The captured category plot wave styles are automatically applied to a category plot when it is first created 
provided preferences are turned on — see How to Use Preferences on page III-516. “Wave styles” refers to 
the various trace-specific settings for category plot numeric waves in the graph. The settings include trace 
mode, line style, stacking mode, fill pattern, colors, etc., as set by the Modify Trace Appearance dialog.
If you capture the category plot preferences from a graph with more than one category plot, the first cate-
gory plot appended to a graph gets the wave style settings from the category first appended to the proto-
type graph. The second category plot appended to a graph gets the settings from the second category plot 
appended to the prototype graph, etc. This is similar to the way XY plot wave styles work.
How to Use Category Plot Preferences
Here is our recommended strategy for using category preferences:
1.
Create a new graph containing a single category plot.
2.
Use the Modify Trace Appearance dialog and the Modify Axes dialogs to make the category plot 
appear as you prefer.
3.
Choose Capture Graph Prefs from the Graph menu. Select the Category Plot checkboxes, and click 
Capture Prefs.
