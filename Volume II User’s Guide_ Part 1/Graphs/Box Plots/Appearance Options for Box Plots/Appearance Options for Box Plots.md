# Appearance Options for Box Plots

Chapter II-13 — Graphs
II-335
Notched Box Plots
A notched box plot shows the 95% confidence interval of the median in addition to the various percentiles 
usually shown:
The notches are at median ± 1.57 * IQR/sqrt(n) where n is the number of data points in the dataset repre-
sented by the box plot. Two box plots have a high probability of significantly different median values if the 
notches don't overlap. 
You make a notched box plot by right-clicking on the box plot trace and selecting Modify Box Plot. In the 
Modify Box Plot dialog, General tab, turn on the Notched checkbox.
Appearance Options for Box Plots
To change the appearance of a box plot, select Modify Box Plot from the Graph menu or right-click on a box 
plot trace and select Modify Box Plot from the contextual menu.
You can change the color, width and dash style for the lines. Those settings can be made individually for 
each component: the box, the whiskers, the median line and whisker caps.
We regard the fences as an incidental detail. You can show the fences in order to understand the display 
better, but we have not seen them used for publication purposes. Consequently, the lines for the fences are 
not modifiable.
You can control the width of the whisker caps—to omit the caps (the default), set the width to zero. A frac-
tional width sets the size of the cap as a fraction of the box width. This is useful to make the cap width con-
sistent when resizing the graph. A width greater than 1 is taken to be an absolute width in points.
The plots that follow are drawn horizontally to save space. You can achieve that effect by choosing Modify 
Graph from the Graph menu, and then turning on the Swap XY checkbox. Alternately, you can turn on the 
Swap X Y Axes checkbox in the New Box Plot or the Append Box Plot dialog to apply the swap to just one 
box plot trace.
Median
95% Conﬁdence Interval

Chapter II-13 — Graphs
II-336
The box can be filled with a color. The box fill color is drawn before the markers so that whatever choices 
you make for the markers will not be overdrawn by the fill color.
You can select a different marker for non-outlier data, outliers and far outliers. In the plot above, regular 
data points and outliers are drawn with the hollow circle marker, and outliers have been made larger than 
the regular data points to emphasize them. The far outlier (there is just one) is drawn with a filled circle 
marker.
You can achieve some special effects by using a hollow marker and selecting a fill color for the marker For 
instance, in this plot the hollow circle marker is used for the regular data points, and the fill color is enabled 
and set to white:
The lines making the box, median and whiskers are on top of the markers so that the markers don't obscure 
the lines. Sometimes you may wish to have the markers on top. With this dataset, that may obscure the lines 
too much. To achieve this effect, on the Markers tab turn on the Draw Data Points on Top checkbox. You 
can separately control drawing the mean marker and median marker:
You can choose to show all the raw data, as above, or you can choose to show no raw data points, only out-
liers and far outliers, or just the far outliers. This plot shows outliers and far outliers:
The plots above apply jitter to the data points; that is, if the markers would overlap a lateral offset is applied 
so that you can see all of them. You can specify a width for the jitter that sets a maximum lateral offset. If 
the offset is too small to completely separate the markers, they will overlap to some degree. If an offset is 
not required for a given marker, it is not offset.
You will sometimes see a box plot in which the data points are shown as a "rug plot", that is, each data point 
is represented by a thin line. That is another way to allow all the data points to be seen, as long as there 
aren't too many. To do this, use the line marker and set the jitter to zero. In this plot the marker for normal 
points, outliers and far outliers is the same vertical line marker (marker 10) with the size set to 8. The caps 
were set to zero and the extreme data points look like caps.
