# Box Plots

Chapter II-13 — Graphs
II-331
each box or violin to be displayed in the trace. If your data is in a 2D wave, turn on the One Multicolumn 
Wave checkbox below the list on the left.
If you are using 1D waves, after you have transferred the list of waves to the righthand list, you can reorder 
the waves by dragging up or down. The order of the waves in the list sets the order of the plots in the trace. 
If you use a multicolumn wave, the order is set by the columns in the wave.
You may also need to select an X wave. If you select _calculated_, the positions of the plots along the X axis 
are computed by Igor. For a list of 1D waves, the plots are positioned at 0, 1, 2, .... If your datasets are 
columns in a multicolumn wave, choosing _calculated_ results in plots positioned according to the Y 
scaling of the wave, that is, the scaled values of the column dimension indices.
The X Wave menu contains both numeric and text waves. Choosing a numeric wave allows you to position 
each plot at an arbitrary point on the X axis. Choosing a text wave results in a category X axis (see Category 
Plots on page II-355). The waves shown in the X Wave menu are limited to those waves that have the one 
point for each selected dataset.
The New Box Plot or New Violin Plot dialog can also make a new text wave for you. Selecting “_new text 
wave_” from the X Wave menu causes the dialog to generate commands which make a new text wave of 
the appropriate length, fill it with placeholder text, and display it in a table for editing. The result is a cate-
gory X axis using the new text wave.
You can give your new trace a custom name by checking the Trace Name checkbox and entering the name 
in the associated edit box. A custom name is especially useful when you use a list of 1D waves because the 
default trace name, based on the name of the first data wave, is confusing.
The X Axis, Y Axis and Swap XY Axes controls work the same way as they do in the New Graph dialog (see 
Creating Graphs on page II-277).
A graph can hold more than one box plot or violin plot trace and you can mix the two. To add another box 
plot or violin plot, choose GraphAppend to GraphBox Plot or GraphAppend to GraphViolin 
Plot.
Box Plots
The box plot, or box and whisker plot, was invented by John W. Tukey to present an easy-to-understand 
display of the distribution of the data points (see Box Plot Reference on page II-337).
A box plot has several parts:
The bottom and top of the box are at the first and third quartiles of the dataset, with a line drawn across the 
box to represent the median value. Thus, the box gives an indication of the width of the distribution and 
the median line an indication of the central location of the distribution. The whiskers represent more infor-
mation about the width of the data distribution such as the length of tails or the symmetry of the distribu-
Median
First quartile, lower hinge, 25
th percentile
Third quartile, upper hinge, 75
th percentile
Lower whisker
Upper whisker
Outlier
Far outlier
IQR
