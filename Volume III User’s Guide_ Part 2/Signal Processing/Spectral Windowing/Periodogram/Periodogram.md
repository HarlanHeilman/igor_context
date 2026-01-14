# Periodogram

Chapter III-9 — Signal Processing
III-279
You can create other windows by writing a user-defined function or by executing a simple wave assign-
ment statement such as this one which applies a triangle window:
Use point indexing to avoid X scaling complications. You can determine the effect a window has by applying it 
to a perfect cosine wave, preferably a cosine wave at 1/4 of the sampling frequency (half the Nyquist frequency).
Other windows are provided in the WaveMetrics-supplied “DSP Window Functions” procedure file.
Multidimensional Windowing
When performing FFTs on images, artifacts are often produced because of the sharp boundaries of the 
image. As is the case for 1D waves, windowing of the image can help yield better results from the FFT.
To window images, you will need to use the ImageWindow operation, which implements the Hanning, 
Hamming, Bartlett, Blackman, and Kaiser windowing filters. See the ImageWindow operation on page 
V-435 for further details. For a windowing example, see Correlations on page III-362.
Power Spectra
Periodogram
The periodogram of a signal s(t) is an estimate of the power spectrum given by
,
where F(f) is the Fourier transform of s(t) computed by a Discrete Fourier Transform (DFT) and N is the nor-
malization (usually the number of data points).
You can compute the periodogram using the FFT but it is easier to use the DSPPeriodogram operation, 
which has the same built-in window functions but you can also select your own normalization to suppress 
the DC term or to have the results expressed in dB as:
20log10(F/F0)
or
10log10(P/P0)
where P0 is either the maximum value of P or a user-specified reference value.
DSPPeriodogram can also compute the cross-power spectrum, which is the product of the Fourier trans-
form of the first signal with the complex conjugate of the Fourier transform of the second signal:
where F(f) and G(f) are the DFTs of the two waves.
Power Spectral Density Functions
The PowerSpectralDensity routine supplied in the “Power Spectral Density” procedure file computes 
Power Spectral Density by averaging power spectra of segments of the input data. This is an early proce-
dure file that does not take advantage of the new built-in features of the FFT or DSPPeriodogram opera-
tions. The procedure is still supported for backwards compatibility.
data *= 1-abs(2*p/numpnts(data)-1)
P f
F f2
N
---------------
=
P f
F fG* f
N
------------------------
=
