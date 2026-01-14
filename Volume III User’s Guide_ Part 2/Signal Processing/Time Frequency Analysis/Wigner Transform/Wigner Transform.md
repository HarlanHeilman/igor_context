# Wigner Transform

Chapter III-9 — Signal Processing
III-281
Wigner Transform
The Wigner transform (also known as the Wigner Distribution Function or WDF) maps a 1D time signal U(t) into 
a 2D time-frequency representation. Conceptually, the WDF is analogous to a musical score where the time axis 
is horizontal and the frequencies (notes) are plotted on a vertical axis. The WDF is defined by the equation
Note that the WDF W(t,) is real (this can be seen from the fact that it is a Fourier transform of an Hermitian 
quantity). The WDF is also a 2D Fourier transform of the Ambiguity function.
The localized spectrum can be derived from the WDF by integrating it over a finite area dtdn. Using Gauss-
ian weight functions in both t and n, and choosing the minimum uncertainty condition dtdn=1, we obtain 
an estimate for the local spectrum
For an application of the WignerTransform operation (see page V-1095), consider the two-frequency signal:
Make/N=500 signal
signal[0,350]=sin(2*pi*x*50/500)
signal[250,]+=sin(2*pi*x*100/500)
WignerTransform /GAUS=100 signal
DSPPeriodogram signal
// Spectrum for comparison
Display signal
The signal used in this example consists of two “pure” frequencies that have small amount of temporal overlap:
Display; AppendImage M_Wigner
The temporal dependence is clearly seen in the Wigner transform. Note that the horizontal (time) transi-
tions are not sharp. This is mostly due to the application of the minimum uncertainty relation dtdn=1 but it 
is also due to computational edge effects. By comparison, the spectrum of the signal while clearly showing 
W t 



xU t
x 2

+

Ut
x 2

–

e i2x
–
d

–


=
Wˆ t t
;



U t'

2t
t'
–
t
---------



2
–
i2t'
–


exp
exp
t'
d

2

-1.5
-1.0
-0.5
0.0
0.5
1.0
1.5
400
300
200
100
0
0.5
0.4
0.3
0.2
0.1
0.0
500
400
300
200
100
0
