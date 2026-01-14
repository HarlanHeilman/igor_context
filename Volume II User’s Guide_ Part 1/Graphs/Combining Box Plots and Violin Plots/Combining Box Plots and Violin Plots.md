# Combining Box Plots and Violin Plots

Chapter II-13 — Graphs
II-345
Marker sizes can range from 0 to 200. See Markers on page II-291 for a table of marker styles and the asso-
ciated marker numbers.
The marker colors, marker sizes and marker styles set by these waves override whatever other settings have 
been made. So if you have selected a particular marker for box plot outliers, for instance, but an outlier data 
point has a marker set via a marker wave, the marker is taken from the wave.
The marker color, marker size and marker style waves are not required to have the same number of rows 
as the dataset wave. If there are extra rows the extras are ignored. If there are too few rows, the extra data 
points take their color, size, color and style from the normal color, size and style settings.
Combining Box Plots and Violin Plots
One problem with a box plot is that it hides the true distribution of your data. If your data is bimodal, it still 
shows you only a box with a median line and whiskers. But a violin plot lacks the statistical information 
contained in a box plot. A common solution is to combine the two—put a box plot in the middle of a violin 
plot.
To do this in Igor, first create a violin plot using WindowsNewNew Violin Plot. We did this with the 
Run1 dataset from the violin plot example:
DifferentMarke MarkerNumber MarkerSizes
0
1.12358
16
5
-0.670571
16
5
0.696167
16
5
-0.48165
19
5
-0.888855
19
7
-1.81002
19
7
0.883285
19
10
-0.854401
18
10
-0.908264
18
10
-0.682166
18
4
-0.979681
18
4
1.90386
17
4
1.79543
17
4
1.20602
60
4
1.28203
60
4
2.13408
60
5
1.78677
60
5
1.04066
29
5
3.2046
29
6
2.31871
29
6
3
2
1
0
-1
Data Set 1

Chapter II-13 — Graphs
II-346
We have chosen a fill color and we are not showing the data points.
Now add a box plot by choosing GraphAppendBox Plot. Because we are using a category X axis, the 
plots are side-by-side. Double-click the violin plot trace and select Keep With Next as the grouping mode:
For best appearance, you should make the box plot narrower, and most likely fill the box with contrasting 
color. Here we set the box width to 0.1 and chose to fill the box with white. We don't show the data points, 
but if you wish to, it is best to show the data points using the box plot trace so that fills don't obscure the 
data points.
-8
-6
-4
-2
0
2
4
6
data set 1
data set 2
data set 3
-8
-6
-4
-2
0
2
4
6
data set 1
data set 2
data set 3
