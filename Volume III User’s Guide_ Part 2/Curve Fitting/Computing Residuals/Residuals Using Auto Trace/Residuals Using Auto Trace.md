# Residuals Using Auto Trace

Chapter III-8 — Curve Fitting
III-219
In this case, a wave called “LineYData” was fit with a straight line model. _auto trace_ was selected for both 
the destination (/D flag) and the residual (/R flag), so the waves fit_LineYData and Res_LineYData were cre-
ated. The third line above gives the equation for calculating the residuals. You can copy this line if you wish 
to recalculate the residuals at a later time. You can edit the line if you want to calculate the residuals in a 
different way. See Calculating Residuals After the Fit on page III-220.
Residuals Using Auto Trace
If you choose _auto trace_ from the Residual menu, it will automatically create a wave for residual values 
and, if the Y data are displayed in the top graph, it will append the residual wave to the graph.
The automatically-created residual wave is named by prepending “Res_” to the name of the Y data wave. 
If the resulting name is too long, it will be truncated. If a wave with that name already exists, it will be 
reused, overwriting the values already in the wave. If a wave does not exist already, the newly-created 
wave is automatically filled with NaN. The residual wave is made with the same number of points as the 
data wave, with one residual value calculated for each data point.
Residual values are stored only for data points that actually participate in fitting. That is, if you fit to a sub-
range of the data, or use a mask wave to eliminate some points from fitting, residuals are stored only for 
the data used in fitting and the other points are not disturbed. This allows you to use the auto-residual 
option to build up the residuals from a piece-wise fit, where parts of the data are fit in succession. It also 
means that sometimes Igor will leave behind stale values. To prevent that, pre-fill your residual wave with 
a value of your choice.
If you fit the same data again, the same residual wave will be used. Thus, to preserve a previous result, you 
must rename the residual wave. This can be done using the Rename item in the Data menu, or the Rename 
command on the command line.
Residuals are displayed on a stacked graph like those above. This is done by shortening the axis used to 
display the Y data, and positioning a new free axis above the axis used for the Y data. The residual plot occu-
pies the space made by shortening the data axis. The axis that Igor creates is given a name derived from the 
axis used to display the Y data, either “Res_Left” or “Res_Right” if the Y data are displayed on the standard 
axes. If the data axis is a named free axis, the automatically-generated axis is given a name created by pre-
pending “Res_” to the name of the data axis.
Igor tries hard to make the appended residual plot look nice by copying the formatting of the Y data trace and 
making the residual trace identical so that you can identify which residual trace goes with a given Y data trace. 
The axis formatting for the residual axis is copied from the vertical axis used for the data trace, and the residual 
axis is positioned directly above the data axis. Any other vertical axes that might be in the way are also short-
ened to make room. Here are two examples of graphs that have been modified by the auto-trace residuals:
It is likely that the automatic formatting won’t be quite what you want, but it will probably be close enough 
that you can use the Modify Axis and Modify Trace Appearance dialogs to tweak the formatting. For details 
see Chapter II-13, Graphs, especially the sections Creating Graphs with Multiple Axes on page II-324 and 
Creating Stacked Plots on page II-324.
5
4
3
2
1
0
-1.0
-0.5
0.0
0.5
1.0
120
100
80
60
40
20
0
120
80
40
0
-0.4
0.0
0.4
0
4
2
0
-1.0
-0.5
0.0
0.5
1.0
0.8
0.4
0.0
120
100
80
60
40
20
0
0.0
0
