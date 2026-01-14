# Changes in X Scaling and Units

Chapter III-9 — Signal Processing
III-271
Magic Number of Points and the IFFT
When performing the inverse FFT, the input is always complex, but the result may be either real or complex.
Because versions of Igor prior to 3.0 only allowed an integral power of two (2n) to be forward-transformed, 
Igor could tell from the number of points in the forward-transformed wave what kind of result to create for 
the inverse transform. To ensure compatibility, Igor versions 3.0 and after continue to treat certain numbers 
of points as “magical.”
If the number of points in the wave is an integral power of two (2n), then the wave resulting from the IFFT 
is complex. If the number of points in the wave is one greater than an integral power of two (1+2n), then the 
wave resulting from the IFFT is real and of length (2n+1).
If the number of points is not one of the two magic values, then the result from the inverse transform is real 
unless the complex result is selected in the Fourier Transforms dialog.
Changes in X Scaling and Units
The FFT operation changes the X scaling of the transformed wave. If the X-units of the transformed wave 
are time (s), frequency (Hz), length (m), or reciprocal length (m-1), then the resulting wave units are set to 
the respective conjugate units. Other units are currently ignored. The X scaling’s X0 value is altered depend-
ing on whether the wave is real or complex, but dx is always set the same:
If the original wave is real, then after the FFT its minimum X value (X0) is zero and its maximum X value is:
If the original wave is complex, then after the FFT its maximum X value is XN/2 - dXFFT, its minimum X 
value is -XN/2, and the X value at point N/2 is zero.
The IFFT operation reverses the change in X scaling caused by the FFT operation except that the X value of 
point 0 will always be zero.
FFT
IFFT
FFT
IFFT
IFFT
150
100
50
0
-50
-100
-500
0
500
Hz
150
100
50
0
-50
-100
500
0
Hz
real
2•N points
complex
2•N points
complex
1+2
N-1 points
complex
2•N points
complex
1+N points
real
2
N points
complex
2
N points
complex
2
N points
two-sided
spectrum
one-sided
spectrum
xFFT
1
N xoriginal

--------------------------------
=
where, N
original length of wave

xN 2

N
2--- xFFT

N
2---
1
N xoriginal

--------------------------------

=
=
1
2 xoriginal

-------------------------------
=
Nyquist Frequency
=
