# Time Frequency Analysis

Chapter III-9 — Signal Processing
III-280
The PowerSpectralDensity functions take a long data wave on input and calculate the power spectral 
density function. These procedures have the following features:
• Automatic display of the results.
• Original data is untouched.
• Pop-up list of windowing functions.
• User setable segment length.
Use #include <Power Spectral Density> in your procedure file to access these functions. See The 
Include Statement on page IV-166 for instructions on including a procedure file.
PSD Demo Experiment
The PSD Demo experiment (in the Examples:Analysis: folder) uses the PowerSpectralDensity procedure 
and explains how it works in great detail, including justification for the scaling applied to the result.
Hilbert Transform
The Hilbert transform of a function f(x) is defined by
.
The integral is evaluated as a Cauchy principal value. For numerical computation it is customary to express 
the integral as the convolution
.
Noting that the Fourier transform of (-1/x) is i*sgn(x), we can evaluate the Hilbert transform using the convo-
lution theorem of Fourier transforms. The HilbertTransform operation (see page V-348) is a convenient short-
cut. In the next example we compute the Hilbert transform of a cosine function that gives us a sine function:
Make/N=512 cosWave=cos(2*pi*x*20/512)
HilbertTransform/Dest=hCosWave cosWave
Display cosWave,hCosWave
ModifyGraph rgb(hCosWave)=(0,0,65535)
Time Frequency Analysis
When you compute the Fourier spectrum of a signal you dispose of all the phase information contained in 
the Fourier transform. You can find out which frequencies a signal contains but you do not know when 
these frequencies appear in the signal. For example, consider the signal
.
The spectral representation of f(t) remains essentially unchanged if we interchange the two frequencies f1 
and f2. In other words, the Fourier spectrum is not the best analysis tool for signals whose spectra fluctuate 
in time. One solution to this problem is the so-called “short time Fourier Transform”, in which you can 
compute the Fourier spectra using a sliding temporal window. By adjusting the width of the window you 
can determine the time resolution of the resulting spectra.
Two alternative tools are the Wigner transform and the Continuous Wavelet Transform (CWT).
FH x

1
--
f t
t
x
–
--------- td

–


=
FH x

1
–
x
-----




f x


=
f t
2f1t


sin
0
t
t1


2f2t


sin
t1
t
t2





=
