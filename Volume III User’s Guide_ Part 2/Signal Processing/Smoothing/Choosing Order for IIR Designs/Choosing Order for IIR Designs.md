# Choosing Order for IIR Designs

Chapter III-9 — Signal Processing
III-313
If the low pass cutoff frequency is less than high pass cutoff frequency, the result is a band stop filter:
If the high pass cutoff frequency is less than low pass cutoff frequency, the result is a band pass filter:
Choosing Order for IIR Designs
Instead of adjusting the number of coefficients to alter the performance of the filtering, IIR designs use a 
filter "order". Essentially, each order represents another layer of recursive filtering. A higher-order filter has 
steeper band transitions, more phase shift, and can be numerically less stable. Increasing the order from 1 
to 6 creates a much steeper transition:
