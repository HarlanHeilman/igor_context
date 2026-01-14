# Other Windows

Chapter III-9 — Signal Processing
III-278
By smoothing the ends of the wave to zero, there is no discontinuity when wrapping around the ends.
In applying a window to the data, energy is lost. Depending on your application you may want to scale the 
output to account for coherent or incoherent gain. The coherent gain is sometimes expressed in terms of 
amplitude factor and it is equal to the sum of the coefficients of the window function over the interval. The 
incoherent gain is a power factor defined as the sum of the squares of the same coefficients. In the case that 
we are considering the correction factor is just the reciprocal of the coherent gain of the Hanning window 
so we can multiply the FFT amplitudes by 2 to correct for them:
cosWave *= 2
// Account for coherent gain
FFT /OUT=3 /DEST=cosWaveH cosWave
Display cosWaveH
ModifyGraph mode=4, marker=8
Note that frequency values in the neighborhood of the peak are less affected by the leakage, and that the 
amplitude is closer to the ideal of 64.
Other Windows
The Hanning window is not the ultimate window. Other windows that suppress more leakage tend to 
broaden the peaks. The FFT and WindowFunction operations have the following built-in windows: Han-
ning, Hamming, Bartlett, Blackman, Cosa(x), KaiserBessel, Parzen, Riemann, and Poisson.
1.0
0.5
0.0
-0.5
-1.0
120
100
80
60
40
20
0
coherent gain ≡
0
1
∫
1−cos 2πx / N
(
)
2
dx = 0.5
50
40
30
20
10
0
0.5
0.4
0.3
0.2
0.1
0.0
