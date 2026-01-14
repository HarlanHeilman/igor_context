# Example: Low Pass FIR Filter

Chapter III-9 — Signal Processing
III-304
It is also helpful if you know the frequency content of the input wave before filtering. Use the Analy-
sisTransformsFourier dialog:
This signal has two interesting bands of frequencies: 0 to 4.5KHz and 4.5 to about 10KHz.
For illustrative purposes, let's walk through designing two filters that isolate each band, a low pass filter 
and a high pass filter.
Example: Low Pass FIR Filter
A low pass filter can be designed to keep the signal frequencies below 4.5KHz and reject higher frequencies.
An infinitely sharp cutoff between those frequencies isn't practical – it takes an infinite number of coeffi-
cients – so we specify two frequencies over which the transition from pass band to reject band happens. The 
smaller this transition band is, the more coefficients are needed to get a useful rejection of the higher fre-
quencies.
Let's choose a 200 Hz transition width (4400 to 4600 Hz) and look at the frequency response with a reason-
able number of coefficients (the default of 101):
