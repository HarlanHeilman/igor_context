# Histograms

Chapter III-7 — Analysis
III-125
If you are working with large amounts of data and you are concerned about computation speed you might 
be able to take advantage of the /M flag that limits the calculation to the first order moments.
If you are working with 2D or 3D waves and you want to compute the statistics for a domain of an arbitrary 
shape you should use the ImageStats operation (see page V-414) with an ROI wave.
Histograms
A histogram totals the number of input values that fall within each of a number of value ranges (or “bins”) 
usually of equal extent. For example, a histogram is useful for counting how many data values fall in each 
range of 0-10, 10-20, 20-30, etc. This calculation is often made to show how students performed on a test:
The usual use for a histogram in this case is to figure out how many students fall into certain numerical 
ranges, usually the ranges associated with grades A, B, C, and D. Suppose the teacher decides to divide the 
0-100 range into 4 equal parts, one per grade. The Histogram operation (see page V-349) can be used to 
show how many students get each grade by counting how many students fall in each of the 4 ranges.
We start by creating a wave to hold the histogram output:
Make/N=4/D/O studentsWithGrade
Next we execute the Histogram command which we generated using the Histogram dialog:
Histogram/B={0,25,4} scores,studentsWithGrade
The /B flag tells Histogram to create four bins, starting from 0 with a bin width of 25. The first bin counts 
values from 0 up to but not including 25.
The Histogram operation analyzes the source wave (scores), and puts the histogram result into a destina-
tion wave (studentsWithGrade).
Let’s create a text wave of grades to plot studentsWithGrade versus a grade letter in a category plot:
Make/O/T grades = {"D", "C", "B", "A"}
Display studentsWithGrade vs grades
SetAxis/A/E=1 left
Everything looks good in the category plot. Let’s double-check that all the students made it into the bins:
Print sum(studentsWithGrade)
 23
There are two missing students. They are ones who scored 100 on the test. The four bins we defined are actually:
Bin 1:
0 - 24.99999
Bin 2:
25 - 49.99999
Bin 3:
50 - 74.99999
Bin 4:
75 - 99.99999
100
80
60
40
20
0
Score
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
Student ID
 Two students scored 100 
 One student scored 0 

Chapter III-7 — Analysis
III-126
The problem is that the test scores actually encompass 101 values, not 100. To include the perfect scores in 
the last bin, we could add a small number such as 0.001 to the bin width:
The students who scored 25, 50 or 75 would be moved down one grade, however. Perhaps the best solution 
is to add another bin for perfect scores:
Make/O/T grades= {"D", "C", "B", "A", "A+"}
Histogram/B={0,25,5} scores,studentsWithGrade
For information on plotting a histogram, see Chapter II-14, Category Plots and Graphing Histogram 
Results on page III-127.
This example was intended to point out the care needed when choosing the histogram binning. Our 
example used “manual binning”.
The Histogram operation provides five ways to set binning. They correspond to the radio buttons in the 
Histogram dialog:
Bin 1:
0 - 25.00999
Bin 2:
25.001 - 49.00199
Bin 3:
50.002 - 74.00299
Bin 4:
75.003 - 100.0399
Bin Mode
What It Does
Manual bins
Sets number of points and X scaling of the destination (output) wave based on 
parameters that you explicitly specify.
Auto-set bins
Sets X scaling of destination wave to cover the range of values in the source wave.
Does not change the number of points (bins) in the destination wave. Thus, you 
must set the number of destination wave points before computing the histogram.
When using the Histogram dialog, if you select Make New Wave or Auto from the 
Output Wave menu, the dialog must be told how many points the new wave should 
have. It displays the Number of Bins box to let you specify the number.
Set bins from destination 
wave
Does not change the X scaling or the number of points in the destination wave. 
Thus, you need to set the X scaling and number of points of the destination 
wave before computing the histogram.
When using the Histogram dialog, the Set from destination wave radio button is 
only available if you choose Select Existing Wave from the Output Wave menu.
Auto-set bins: 1+log2(N)
Examines the input data and sets the number of bins based on the number of input 
data points. Sets the bin range the same as if Auto-set bin range were selected.
Auto-set bins: 
3.49*Sdev*N^-1/3
Examines the input data and sets the number of bins based on the number of 
input data points and the standard deviation of the data. Sets the bin range the 
same as if Auto-set bin range were selected.
Freedman-Diaconis 
method
Sets the optimal bin width to
binWidth = 2 * IQR * N-1/3
where IQR is the interquartile distance (see StatsQuantiles) and the bins are 
evenly-distributed between the minimum and maximum values.
Added in Igor Pro 7.00.
