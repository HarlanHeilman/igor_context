# Box Smoothing

Chapter III-9 — Signal Processing
III-295
Box Smoothing
Box smoothing is similar to a moving average, except that an equal number of points before and after the 
smoothed value are averaged together with the smoothed value. The Points parameter is the total number 
of values averaged together. It must be an odd value, since it includes the points before, the center point, 
and the points after. For instance, a value of 5 averages two points before and after the center point, and the 
center point itself:
Make/O/N=32 wave0=0; wave0[15]=1; Smooth/B 5,wave0
//Smooth impulse
Display wave0; ModifyGraph mode=8,marker=8
// Observe coefficients
The following graph shows the frequency response of the box smoothing algorithm.
1.0
0.9
0.8
0.7
0.6
0.5
0.4
0.3
0.2
0.1
0.0
response
50
40
30
20
10
0
% Sampling Frequency
4th Order
Savitzky-Golay Smoothing
 7 points
 11 points
 25 points
0.20
0.15
0.10
0.05
0.00
30
25
20
15
10
5
0
1.0
0.9
0.8
0.7
0.6
0.5
0.4
0.3
0.2
0.1
0.0
response
50
40
30
20
10
0
% Sampling Frequency
Box Smoothing
 1 point
 3 points
 5 points
 7 points
 11 points
 25 points
 51 points
