# RatioFromNumber

Quit
V-786
See Also
The hcsr, pcsr, vcsr, xcsr, and zcsr functions.
Programming With Cursors on page II-321.
Quit 
Quit [/N/Y]
The Quit operation quits Igor Pro.
Flags
r 
r
The r function returns the current layer index of the destination wave when used in a multidimensional 
wave assignment statement. The corresponding scaled layer index is available as the z function.
Details
Unlike p, outside of a wave assignment statement, r does not act like a normal variable.
See Also
Waveform Arithmetic and Assignments on page II-74. For other dimensions, the p, q, s, and t functions. 
For scaled dimension indices, the x, y, z, and t functions.
r2polar 
r2polar(z)
The r2polar function returns a complex value in polar coordinates derived from the complex value z, which 
is assumed to be in rectangular coordinates. The magnitude is stored in the real part and the angle (in 
radians) is stored in the imaginary part of the returned complex value.
Examples
Assume waveIn and waveOut are complex.
waveOut= r2polar(waveIn)
sets each point of waveOut to the polar coordinates derived from the real and imaginary parts of waveIn.
You may get unexpected results if the number of points in waveIn differs from the number of points in waveOut.
See Also
The functions cmplx, conj, imag, p2rect, and real.
RatioFromNumber 
RatioFromNumber [flags] num
The RatioFromNumber operation computes two integers whose ratio is equal to num ± maxError (/MERR 
flag). The ratio is returned in V_numerator and V_denominator.
Parameters
num is the number to approximate by V_numerator/V_denominator.
Flags
/N
Quits without saving changes and without dialog.
/Y
Saves current experiment before quitting without putting up dialog unless current 
experiment is “Untitled”.
/MERR=maxError
Specifies the maximum tolerable error. The computed ratio differs from num by 
no more than maxError (default value is num*1e-6).
maxError must be a value between 0 and num. See Details about setting maxError 
to 0.
