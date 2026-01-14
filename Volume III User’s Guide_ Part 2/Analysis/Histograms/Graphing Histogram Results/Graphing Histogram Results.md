# Graphing Histogram Results

Chapter III-7 — Analysis
III-127
Histogram Caveats
If you use the “Set bins from destination wave” mode, you must create the destination wave, using the 
Make operation, before computing the histogram. You also must set the X scaling of the destination wave, 
using the SetScale.
The Histogram operation does not distinguish between 1D waves and multidimensional waves. If you use 
a multidimensional wave as the source wave, it will be analyzed as if the wave were one dimensional. This 
may still be useful - you will get a histogram showing counts of the data values from the source wave as 
they fall into bins.
If you would like to perform a histogram of 2D or 3D image data, you may want to use the ImageHistogram 
operation (see page V-379), which supports specific features that apply to images only.
Graphing Histogram Results
Our example above displayed the histogram results as a category plot because the bins corresponded to text 
values. Often histogram bins are displayed on a numeric axis. In this case you need to know how Igor dis-
plays a histogram result.
For example, this histBins destination wave has 12 points (bins), the first bin starting at -3, and each bin is 
0.5 wide. The X scaling is shown in the table:
When histBins is graphed in both bars and markers modes, it looks like this:
Note that the markers are positioned at the start of the bars. You can offset the marker trace by half the bin 
width if you want them to appear in the center of the bin.
Alternatively, you can make a second histogram using the Bin-Centered X Values option. In the Histogram 
dialog, check the Bin-Centered X Values checkbox.
Point
histBins.x
histBins.d
0
-3
14
1
-2.5
8
2
-2
8
3
-1.5
7
4
-1
8
5
-0.5
14
6
0
14
7
0.5
6
8
1
8
9
1.5
13
10
2
14
11
2.5
15
15
10
5
0
3
2
1
0
-1
-2
-3
 
 
First bin ends just before x = -2.5
Last bin ends just before x=3
Last bin starts at x = 2.5
First bin starts at x = -3
8 source values >= -1 and < -0.5
Histogram /B={-3,0.5,12} data, histBins 
(12 bins, each 0.5 X units wide)
