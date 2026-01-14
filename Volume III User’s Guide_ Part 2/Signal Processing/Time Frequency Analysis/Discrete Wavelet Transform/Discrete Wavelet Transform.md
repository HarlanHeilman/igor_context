# Discrete Wavelet Transform

Chapter III-9 — Signal Processing
III-283
CWT /M=1/OUT=4/SMP2=1/R2={1,1,40}/WBI1=Morlet/FSCL /ENDM=2 signal
Rename M_CWT, M_CWT2
Display as "Morlet Direct Sum"; AppendImage M_CWT2
Using the complex Morlet wavelet in the direct sum method (/M=1) and displaying the squared magnitude 
we get:
CWT /M=1/OUT=4/SMP2=1/R2={1,1,40}/WBI1=MorletC/FSCL /ENDM=2 signal
Rename M_CWT, M_CWT3
Display as "Complex Morlet Direct Sum"; AppendImage M_CWT3
It is apparent that the last image has essentially the same results as the one generated using the FFT 
approach but in this case the edge effects are completely absent.
Discrete Wavelet Transform
The DWT is similar to the Fourier transform in that it is a decomposition of a signal in terms of a basis set 
of functions. In Fourier transforms the basis set consists of sines and cosines and the expansion has a single 
parameter. In wavelet transform the expansion has two parameters and the functions (wavelets) are gener-
ated from a single “mother” wavelet using dilation and offsets corresponding to the two parameters.
50
40
30
20
10
1000
800
600
400
200
0
50
40
30
20
10
1000
800
600
400
200
0
50
40
30
20
10
1000
800
600
400
200
0
