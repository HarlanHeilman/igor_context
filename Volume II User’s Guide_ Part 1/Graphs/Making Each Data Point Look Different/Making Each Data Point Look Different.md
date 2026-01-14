# Making Each Data Point Look Different

Chapter II-13 — Graphs
II-343
The order in which you make these settings is important. If you change an overall setting, any correspond-
ing values for individual datasets are reset to the overall value. So to make the box plot above with light 
blue overall, and light green for the second dataset, you need to first set the light blue color for the entire 
trace followed by setting the light green color for the second dataset only. You do not need to close the 
dialog between these two changes.
Making Each Data Point Look Different
Sometimes the data points in a single dataset come from different sources, or represent different conditions, 
and you would like to show that in the graph. Using an auxiliary wave you can set the marker color, marker 
size or marker style for each data point. Controls for these settings appear in the Markers tab of the Modify 
Box Plot dialog.
For instance, this table shows a fake dataset in the first column and a corresponding three-column wave to 
specify the marker color for each data point:
We made a box plot with that dataset and selected the wave BoxPlotColors to set the marker colors for the 
data points:
8
6
4
2
0
-2
Run 1
Run 2
Run 3
8
6
4
2
0
-2
Run 1
Run 2
Run 3
DifferentMarke BoxPlotColors[ BoxPlotColors[ BoxPlotColors[
Data Set 1
0
1
2
1.12358
32768
40777
65535
-0.670571
32768
40777
65535
0.696167
32768
40777
65535
-0.48165
5545.79
58663.6
17962.9
-0.888855
5546
58664
17963
-1.81002
5546
58664
17963
0.883285
5546
58664
17963
-0.854401
65535
43690
0
-0.908264
65535
43690
0
-0.682166
65535
43690
0
-0.979681
65535
43690
0
1.90386
65535
43690
0
1.79543
5546
58664
17963
1.20602
5546
58664
17963
1.28203
32768
40777
65535
2.13408
32768
40777
65535
1.78677
32768
40777
65535
1.04066
65535
43690
0
3.2046
65535
43690
0
2.31871
65535
43690
0

Chapter II-13 — Graphs
II-344
The result is this box plot: 
The color wave for this figure was created using the Color Wave Editor package, accessed by choosing 
DataPackagesColor Wave Editor.
Similarly, you can set each data point marker to a different size or to a different marker style using a 1D 
wave with a size or marker number for each data point. For instance:
3
2
1
0
-1
Data Set 1
