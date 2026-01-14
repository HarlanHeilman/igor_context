# Hanning Window

Chapter III-9 — Signal Processing
III-277
When we rotate this data as before, you can see what the FFT will perceive to be a discontinuity between 
the point 127 and point 0 of the unrotated data. In this next graph, the original point 127 has been rotated 
to x= -1 and point 0 is still at x=0.
Rotate 3, cosWave
SetAxis bottom, -5, 20
When the FFT of this data is computed, the discontinuity causes “leakage” of the main cosine peak into sur-
rounding magnitude values.
FFT /OUT=3 /DEST=cosWaveF cosWave
SetAxis/A
How does all this relate to spectral windowing? Spectral windowing reduces this leakage and gives more 
accurate FFT results. Specifically, windowing reduces the number of adjacent FFT values affected by leak-
age. A typical window accomplishes this by smoothly attenuating both ends of the data towards zero.
Hanning Window
Windowing the data before the FFT is computed can reduce the leakage demonstrated above. The Hanning 
window is a simple raised cosine function defined by the equation:
Let us apply the Hanning window to the 16.5 cycle cosine wave data:
Make/O/N=128 cosWave=cos(2*pi*p*16.5/128)
Hanning cosWave
Display cosWave
ModifyGraph mode=4, marker=8
1.0
0.5
0.0
-0.5
-1.0
20
15
10
5
0
-5
s
40
30
20
10
0.5
0.4
0.3
0.2
0.1
0.0
Hz
hanning[p] =
1−cos
2π p
N −1
⎛
⎝⎜
⎞
⎠⎟
2
