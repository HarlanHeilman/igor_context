# IIR Filters

Chapter III-9 — Signal Processing
III-300
Typically filters are designed by specifying frequency "bands" that define a range of frequencies and the 
desired response amplitude (gain) and phase in that band.
The range of frequencies that are possible range from 0 to one-half the sampling frequency of the signal, 
which is called the "Nyquist frequency". In the example of musicWave, the Nyquist frequency is 22,050 Hz, 
so filter designs for that waveform define frequency bands that end no higher than 22,050 Hz.
Filter Design Output
The result of a filter design is a set of filter "coefficients" that are used to implement the filtering. The coef-
ficient values and format depend on the filter design type, number of bands, band frequencies, and other 
parameters that define the filter response. The formats for FIR and IIR designs are quite different.
FIR Filters
Finite Impulse Response (FIR) means that the filter's time-domain response to an impulse ("spike") is zero 
after a finite amount of time:
An FIR filter is a finite length, evenly-spaced time series of impulses with varying amplitudes that is con-
volved with an input signal to produce a filtered output signal.
The impulse response amplitudes are termed "weighting factors" or "coefficients". They are identical to the 
filter's response to a unit impulse. You can observe an FIR filter's frequency response by simply computing 
the FFT of the coefficients. If you set the X scaling of the coefficients to match the sampling frequency of the 
data it will be applied to, the FFT result's frequency range will be scaled to the data's Nyquist frequency. 
For default X scaling, the frequency range will be 0 to 0.5 Hz:
FIR filters are valued for their completely linear phase (constant delay for all frequencies), but they gener-
ally need many more coefficients than IIR filters do to achieve similar frequency responses. Consequently, 
electronic digital realizations of FIR filters are usually more expensive than the corresponding IIR filter.
You supply FIR coefficients to the FilterFIR operation along with the input waveform to compute the fil-
tered output waveform.
IIR Filters
The response of an Infinite Impulse Response (IIR) filter continues indefinitely, as it does for analog elec-
tronic filters that employ inductors and capacitors:

Chapter III-9 — Signal Processing
III-301
An IIR filter is a set of coefficients or weights a0, a1, a2,… and b0, b1, b2… whose values and use depend 
on the digital implementation topology. Unlike the FIR filter, these coefficients are not the same as the fil-
ter's response to a unit impulse. See the “IIR Filter Design” topic in the “Igor Filter Design Laboratory” help 
file for further explanation.
IIR filters can realize quite sophisticated frequency responses with very few coefficients. The drawbacks are 
non-linear phase, potential for numerical instability (oscillation) when realized using limited-precision 
arithmetic, and the indirect design methodology (frequency transformations of conventional analog filter 
methods).
Igor uses two IIR implementations:
•
Direct Form I (DF I)
•
Cascaded Bi-Quad Direct Form II (DF II)
The IIR coefficients are represented in three forms:
•
DF I
•
DF II
•
"zeros and poles" form
The zeros and poles form is discussed under “IIR Analog Prototype Design Graph” in the “Igor Filter 
Design Laboratory” help file.
You supply IIR coefficients to the FilterIIR operation along with the input waveform to compute the filtered 
output waveform. The format of IIR design coefficients depends on the implementation, as you can see in 
tables showing coefficients for Direct Form 1, Cascaded Bi-Quad Direct Form II, and pole-zero implemen-
tations of the same filter design.
