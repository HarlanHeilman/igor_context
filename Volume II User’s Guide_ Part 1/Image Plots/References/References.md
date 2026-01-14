# References

Chapter II-16 — Image Plots
II-404
Image Axis Preferences
Only axes used by the image plot have their settings captured. Axes used solely for an XY, category, or 
contour plot are ignored.
The image axis preferences are applied only when axes having the same name as the captured axis are 
created by an AppendImage command. If the axes existed before AppendImage is executed, they are not 
affected by the image axis preferences.
The names of captured image axes are listed in the X Axis and Y Axis pop-up menus of the New Image Plot 
and Append Image Plot dialogs. This is similar to the way XY plot axis preferences work.
For example, suppose you capture preferences for an image plot using axes named “myRightAxis” and 
“myTopAxis”. These names will appear in the X Axis and Y Axis pop-up menus in image plot dialogs.
If you choose them in the New Image Plot dialog and click Do It, a graph will be created containing newly-
created axes named “myRightAxis” and “myTopAxis” and having the axis settings you captured.
If you have a graph which already uses axes named “myRightAxis” and “myTopAxis” and choose these 
axes in the Append Image Plot dialog, the image will be appended to those axes, as usual, but no captured 
axis settings will be applied to these already-existing axes.
You can capture image axis settings for the standard left and bottom axes, and Igor will save these sepa-
rately from left and bottom axis preferences captured for XY, category, and contour plots. Igor will use the 
image axis settings for AppendImage commands only.
How to Use Image Preferences
Here is our recommended strategy for using image preferences:
1.
Create a new graph containing a single image plot. Use the axes you will normally use, even if they are 
left and bottom. You can use other axes, too (select New Axis in the New Image Plot and Append Image 
Plot dialogs).
2.
Use the Modify Image Appearance, Modify Graph, and Modify Axis dialogs to make the image 
plot appear as you prefer.
3.
Choose Capture Graph Prefs from the Graph menu. Select the Image Plots category, and click Cap-
ture Prefs.
Image Plot Shortcuts
Since image plots are drawn in a normal graph, all of the Graph Shortcuts (see page II-353) apply. Here we 
list those which apply specifically to image plots.
References
Light, Adam, and Patrick J. Bartlein, The End of the Rainbow? Color Schemes for Improved Data Graphics, 
Eos, 85, 385-391, 2004.
Wyszecki, Gunter, and W. S. Stiles, Color Science: Concepts and Methods, Quantitative Data and Formula, 628 
pp., John Wiley & Sons, 1982.
Action
Shortcut (Macintosh)
Shortcut (Windows)
To modify the appear-
ance of the image plot 
as a whole
Control-click in the plot area of the 
graph and choose Modify Image from 
the pop-up menu.
Right-click in the plot area of the graph 
and choose Modify Image from the pop-
up menu.
