# The Plot Pane

Chapter II-8 — Data Folders
II-116
The info pane appears below the main list. When you select an object in the main list, its properties or con-
tents appear in the info pane. For example, when you select a variable, its name and value are displayed in 
the info pane.
If you select a wave in the main list, the info pane displays various properties of the wave, such as type, 
size, dimensions, units, start X, delta Xand note. Each of these fields is displayed as a blue label followed by 
a plain text value. You can control which properties are displayed using the Data Browser category of the 
Miscellaneous Settings Dialog.
If you select a data folder, the info pane may display notes for the data folder. See Data Folder Notes on 
page II-120 for details.
You can edit the name and value of a numeric or string variable, or the name and properties of a wave, by 
clicking the Edit Object Properties button at the top right corner of the info pane. The button appears only 
when a single object is selected. Clicking it displays the Edit Object Properties dialog.
The info pane can also display statistics for any selected wave. To show wave statistics, click the sigma icon 
at the top of the info pane. To change back to normal mode, click the i icon.
You can copy the text displayed in the info pane to the clipboard by clicking the clipboard button at the top 
of the info pane.
You can control various aspects of the info pane display by right-clicking and choosing an item from the 
Settings submenu. The options include how white space is displayed, parenthesis matching, syntax color-
ing, and word wrap.
The Plot Pane
To view the plot pane, check the Plot checkbox.
The plot pane provides a graphical display of a single selected wave. The plot pane is situated below the 
main list and the info pane. It displays a small graph or image of a wave selected in the main list above it. 
The plot pane does not display text waves or more than one wave at a time.
You can control various properties of the plot pane by right-clicking and using the resulting pop-up menu.
You can toggle the display of axes by choosing Show Axes from the pop-up menu. You can also toggle 
between showing a plot of the selected wave and a plot of a 1D histogram by choosing Show Plot or Show 
Histogram.
Simple 1D real waves are drawn in red on a white background. Complex 1D waves are drawn as two traces 
with the real part drawn in red and the imaginary in blue. The mode, line style, line size, marker, marker 
size, and color of the trace can all be configured using the pop-up menu. 
2D waves are displayed as an image that by default is scaled to the size of the plot pane and uses the 
Rainbow color table by default. You can change the aspect ratio and color table via the pop-up menu.
By default, images are displayed with the left axis reversed - that is, the Y value increases from top to 
bottom, consistent with the behavior of the NewImage operation. You can disable this by choosing Reverse 
Left Axis from the pop-up menu.
When you select a 3D or 4D wave in the main list, the plot pane displays one layer of the wave at a time. 
Controls at the top of the plot pane allow you to choose which layer is displayed. You can start the plot pane 
cycling through the layers using the play button and stop it using the stop button.
If the dimensionality of the selected wave is such that it could be interpreted as containing RGB or RGBA 
data, Igor displays the Automatically Detect RGB(A) checkbox. If you check it, Igor displays the data as an 
RGB(A) composite image. Otherwise the image data is displayed using a color table, just as with 2D data.
