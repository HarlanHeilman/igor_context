# Savitzky-Golay Smoothing

Chapter III-9 — Signal Processing
III-294
Binomial Smoothing
The Binomial smoothing operation is a Gaussian filter. It convolves your data with normalized coefficients 
derived from Pascal’s triangle at a level equal to the Smoothing parameter. The algorithm is derived from 
an article by Marchand and Marmet (1983).
This graph shows the frequency response of the binomial smoothing algorithm expressed as a percentage 
of the sampling frequency. For example, if your data is sampled at 1000 Hz and you use 5 passes, the signal 
at 200 Hz (20% of the sampling frequency) will be approximately 0.1.
Savitzky-Golay Smoothing
Savitzky-Golay smoothing uses a different set of precomputed coefficients popular in the field of chemistry. 
It is a type of Least Squares Polynomial smoothing. The amount of smoothing is controlled by two param-
eters: the polynomial order and the number of points used to compute each smoothed output value. This 
algorithm was first proposed by A. Savitzky and M.J.E. Golay in 1964. The coefficients were subsequently 
corrected by others in 1972 and 1978; Igor uses the corrected coefficients.
The maximum Points value is 32767; the minimum is either 5 (2nd order) or 7 (4th order). Note that 2nd and 
3rd order coefficients are the same, so we list only the 2nd order choice. Similarly, 4th and 5th order coeffi-
cients are identical.
Even though Savitzky-Golay smoothing has been widely used, there are advantages to the binomial 
smoothing as described by Marchand and Marmet in their article.
The following graphs show the frequency response of the Savitzky-Golay algorithm for 2nd order and 4th order 
smoothing. The large responses in the higher frequencies show why binomial smoothing is often a better choice.
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
Binomial Smoothing
 1 pass
 2 passes
 3 passes
 5 passes
 7 passes
 11 passes
 25 passes
 51 passes
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
2nd Order
Savitzky-Golay Smoothing
 5 points
 7 points
 11 points
 25 points
