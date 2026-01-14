# Box Plot Outlier Methods

Chapter II-13 — Graphs
II-334
of the box width. If the specified width is insufficient to separate the points, they will overlap as needed. If 
the width is greater than necessary, only as much offset as necessary is applied.
In usual practice the fences are not shown.
Box Plot Outlier Methods
By default, Igor follow Tukey in defining outliers and far outliers based on the fences, with "outliers" being 
points outside the inner fences and "far outliers" being points beyond the outer fences. While not usually 
shown in practice, you can tell Igor to include the fences on the plot using the command ModifyBoxPlot 
showFences=1. The outliers are shown as filled circles and the far outliers are large filled squares.
Igor offers four options to control which data points are outliers and far outliers:
Option 0:
Tukey's definition. Outliers are any data points beyond the inner fences, 
far outliers are any data points beyond the outer fences.
Option 1:
Any points beyond the ends of the whiskers are outliers. There are no far 
outliers. For this option, the whiskers were set to option 6, 2nd and 98th 
percentiles.
Option 2:
Outliers and far outliers are points beyond an arbitrary factor times the 
standard deviation of the mean. In this case, those factors are 1 and 2. The 
whisker lengths are set to option 7, arbitrary factor times the standard 
deviation of the mean. The factor is set to 2. The white diamond shows the 
mean value.
Option 3:
Outliers and far outliers are determined by four arbitrary data values. In 
this case the values are -2, -1.5, 1 and 2.6.
0
1
4
3
2
1
0
-1
-2
-3
-4
3
2
