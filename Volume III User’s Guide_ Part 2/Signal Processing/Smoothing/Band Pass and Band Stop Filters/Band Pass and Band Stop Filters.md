# Band Pass and Band Stop Filters

Chapter III-9 — Signal Processing
III-312
IIR Designs
The IIR filters created using the Filter Design and Application dialog are based on tranforms of analog But-
terworth filters, a standard smooth-response filter of the electrical and mechanical engineering worlds. See 
IIR Filters on page III-300 for details.
Use the Igor Filter Design Laboratory to design IIR filters based on transforms of analog Bessel and Cheby-
shev filters. See the “Igor Filter Design Laboratory”help file for details.
Like the IIR Filters, the easily-designed IIR filters are specified in terms of filter type (low pass, high pass, 
notch) and design frequencies.
Choosing IIR Band Frequencies
Unlike FIR Design, the IIR Design uses a single cutoff frequency to define pass and reject bands. You can 
think of the cutoff frequency as the frequency where the response begins to "cut off" (reject) frequency com-
ponents of the signal. "Begins" is chosen to be at the -3 dB point of the response, the so-called "half-power" 
amplitude, where the gain is 1/sqrt(2) = 0.707107:
Band Pass and Band Stop Filters
A filter that passes or rejects a range of frequencies that do not include 0 or the Nyquist frequency is called 
a band pass or band stop filter. Such filters are useful only for preserving or rejecting a narrow range of fre-
quencies. A notch filter is a kind of band stop filter that has its own special implementation.
Band pass and band stop filters both use the Low Pass and High Pass settings of the dialog. The difference 
is which cutoff frequency is lower than the other.
