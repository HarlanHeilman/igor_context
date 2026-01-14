# FFT Amplitude Scaling

Chapter III-9 — Signal Processing
III-272
FFT Amplitude Scaling
Various programs take different approaches to scaling the amplitude of an FFTed waveform. Different 
scaling methods are appropriate for different analyses and there is no general agreement on how this is 
done. Igor uses the method described in Numerical Recipes in C (see References on page III-316) which 
differs from many other references in this regard.
The DFT equation computed by the FFT for a complex waveorig with N points is:
waveorig and waveFFT refer to the same wave before and after the FFT operation.
The IDFT equation computed by the IFFT for a complex waveFFT with N points is:
To scale waveFFT to give the same results you would expect from the continuous Fourier Transform, you 
must divide the spectral values by N, the number of points in waveorig.
However, for the FFT of a real wave, only the positive spectrum (containing spectra for positive frequen-
cies) is computed. This means that to compare the Fourier and FFT amplitudes, you must account for the 
identical negative spectra (spectra for negative frequencies) by doubling the positive spectra (but not 
waveFFT[0], which has no negative spectral value).
For example, here we compute the one-sided spectrum of a real wave, and compare it to the expected 
Fourier Transform values:
Make/N=128 wave0
SetScale/P x 0,1e-3,"s",wave0 // dx=1ms,Nyquist frequency is 500Hz
wave0= 1 - cos(2*Pi*125*x)
// signal frequency is 125Hz, amp. is -1
Display wave0;ModifyGraph zero(left)=3
FFT wave0
Igor computes the “one-sided” spectrum and updates the graph:
waveFFT n

waveorig k
e2i kn N


, where i
1
–
=

k
0
=
N
1
–

=
waveIFT n

1
N---
waveFFT k
e 2
– i kn N


, where i
1
–
=

k
0
=
N
1
–


=
2.0
1.5
1.0
0.5
0.0
0.12
0.10
0.08
0.06
0.04
0.02
0.00
s
