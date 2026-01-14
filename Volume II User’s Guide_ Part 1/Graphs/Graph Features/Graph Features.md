# Graph Features

Chapter II-13 — Graphs
II-276
Overview
Igor graphs are simultaneously:
•
Publication quality presentations of data.
• Dynamic windows for exploratory data analysis
This chapter describes how to create and modify graphs, how to adjust graph features to your liking, and 
how to use graphs for data exploration. It deals mostly with general graph window properties and with 
waveform and XY plots.
These other chapters discuss material related to graphs:
Category Plots on page II-355, Contour Plots on page II-365, Image Plots on page II-385
3D Graphics on page II-405, Drawing on page III-61, Annotations on page III-33
Exporting Graphics (Macintosh) on page III-95, Exporting Graphics (Windows) on page III-101
Graphics Technology on page III-506
A single graph window can contain one or more of the following:
The various kinds of plots can be overlaid in the same plot area or displayed in separate regions of the graph. 
Igor also provides extensive control over stylistic factors such as font, color, line thickness, dash pattern, etc.
Graph Features
Igor graphs are smart. If you expand a graph to fill a large screen, Igor will adjust all aspects of the graph to 
optimize the presentation for the larger graph size. The font sizes will be scaled to sizes that look good for the 
large format and the graph margins will be optimized to maximize the data area without fouling up the axis 
labeling. If you shrink a graph down to a small size, Igor will automatically adjust axis ticking to prevent tick 
mark labels from running into one another. If Igor’s automatic adjustment of parameters does not give the 
desired effect, you can override the default behavior by providing explicit parameters.
Igor graphs are dynamic. When you zoom in on a detail in your data, or when your data changes, perhaps 
due to data transformation operations, Igor will automatically adjust both the tick mark labels and the axis 
labels. For example, before zooming in, an axis might be labeled in milli-Hertz and later in micro-Hertz. No 
matter what the axis range you select, Igor always maintains intelligent tick mark and axis labels.
If you change the values in a wave, any and all graphs containing that wave will automatically change to 
reflect the new values.
You can zoom in on a region of interest (see Manual Scaling), expand or shrink horizontally or vertically, 
and you can pan through your data with a hand tool (see Panning). You can offset graph traces by simply 
dragging them around on the screen (see Trace Offsets). You can attach cursors to your traces and view 
Waveform plots
Wave data versus X values (scaled point number)
XY plots
Y wave data versus X wave data
Category plots
Numeric wave data versus text wave data
Image plots
Display of a matrix of data
Contour plots
Contour of a matrix or an XYZ triple
Axes
Any number of axes positioned anywhere
Annotations
Textboxes, legends and dynamic tags
Cursors
To read out XY coordinates
Drawing elements
Arrows, lines, boxes, polygons, pictures …
Controls
Buttons, pop-up menus, readouts …
