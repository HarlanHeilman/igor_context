# Correlation

Chapter III-9 — Signal Processing
III-286
Use acausal convolution when the source wave contains an impulse response where the middle point of the 
source wave corresponds to no delay (t = 0).
Correlation
You can use correlation to compare the similarity of two sets of data. Correlation computes a measure of 
similarity of two input signals as they are shifted by one another. The correlation result reaches a maximum 
at the time when the two signals match best. If the two signals are identical, this maximum is reached at t = 
0 (no delay). If the two signals have similar shapes but one is delayed in time and possibly has noise added 
to it then correlation is a good method to measure that delay.
2
1
0
20
15
10
5
0
0.2
0.0
7
0
zero-delay point
srcWave
sum(srcWave) = 1
 Original destWave
(15 points)
destWave_conv
Convolved output has 
no additional points
Circular Convolution
2
1
0
20
15
10
5
0
0.2
0.0
6
4
2
0
srcWave zero-delay point
= trunc(numpnts(srcWave)/2)
 Original destWave
(15 points)
destWave_conv
Convolved output is shifted left by 
trunc(numpnts(srcWave)/2) = 4 points
compared to linear convolution
Acausal Convolution
