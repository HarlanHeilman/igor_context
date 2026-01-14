# Other FIR Designs using IFDL

Chapter III-9 — Signal Processing
III-311
The FilterFIR operation uses high-precision calculations to get a deep notch at the selected frequency, pre-
ferring to adjust the frequency to get deeper notches. The Improve Notch Accuracy value (nMult in the Fil-
terFIR documentation) indirectly sets the number of coefficients used to implement the notch.
Here is the result of this filter design:
The frequency response on the right does not look all that different but the filtered signal on the left has 
much less of the interfering 60 Hz signal.
Other FIR Designs using IFDL
The FIR filters created using the Filter Design and Application dialog are simple filters created by applying 
a "window" shape - such as the Hanning WindowFunction - to truncated sin(x)/x kernels.
The filters are functional but require a lot of coefficients to get high performance (steep filter transition 
bands, good rejection of unwanted frequencies). Often these aren't important shortcomings, but if the 
designed filter is intended for actual electronic implementation, those extra coefficients get expensive.
High-performance FIR filters using far fewer coefficients can be computed by using the Igor Filter Design 
Laboratory package. It optimizes both filter response and the number of filter coefficients using the Remez 
Exchange algorithm as described in the seminal paper by [McClellan], Parks, and Rabiner. See the Remez 
operation for additional references. See the “Igor Filter Design Laboratory” help file for details.
