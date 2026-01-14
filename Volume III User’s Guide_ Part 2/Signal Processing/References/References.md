# References

Chapter III-9 — Signal Processing
III-316
You can apply the saved IIR filter to other data using the FilterIIR operation:
Duplicate/O otherData, otherDataFiltered
FilterIIR/DIM=0/COEF=savedIIRfilter otherDataFiltered
You can also apply the saved IIR filter to other data using the Select Filter Coefficients Wave tab of the 
Filter dialog.
Rotate Operation
The Rotate operation (see page V-810) rotates the data values of the selected waves by a specified number 
of points. Choose DataRotate Waves to display the Rotate dialog.
Think of the data values of a wave as a column of numbers. If the specified number of points is positive the 
points in the wave are rotated downward. If the specified number of points is negative the points in the 
wave are rotated upward. Values that are rotated off one end of the column wrap to the other end.
The rotate operation shifts the X scaling of the rotated wave so that, except for the points which wrap 
around, the X value of a given point is not changed by the rotation. To observe this, display the X scaling 
and data values of the wave in a table and notice the effect of Rotate on the X values.
This change in X scaling may or may not be what you want. It is usually not what you want if you are rotat-
ing an XY pair. In this case, you should undo the X scaling change using the SetScale operation:
SetScale/P x,0,1,"",waveName
// replace waveName with name of your wave
Also see the example of rotation in Spectral Windowing on page III-275.
For multi-dimensional wave rotation, see the MatrixOp rotateRows, rotateCols, rotateLayers, and rotate-
Chunks functions.
Unwrap Operation
The Unwrap operation (see page V-1050) scans through each specified wave trying to undo the effect of a 
modulus operation. For example, if you perform an FFT on a wave, the result is a complex wave in rectangular 
coordinates. You can create a real wave which contains the phase of the result of the FFT with the command:
wave2 = imag(r2polar(wave1))
However the rectangular-to-polar conversion leaves the phase information modulo 2. You can restore the 
continuous phase information with the command:
Unwrap 2*Pi, wave2
The Unwrap operation is designed for 1D waves only. Unwrapping 2D data is considerably more difficult. 
See the ImageUnwrapPhase operation on page V-433 for more information
Choose AnalysisUnwrap to display the Unwrap Waves dialog.
References
Cleveland, W.S., Robust locally weighted regression and smoothing scatterplots, J. Am. Stat. Assoc., 74, 829-
836, 1977.
Marchand, P., and L. Marmet, Binomial smoothing filter: A way to avoid some pitfalls of least square poly-
nomial smoothing, Rev. Sci. Instrum., 54, 1034-41, 1983.
Press, W.H., B.P. Flannery, S.A. Teukolsky, and W.T. Vetterling, Numerical Recipes in C, 2nd ed., 994 pp., 
Cambridge University Press, New York, 1992.

Chapter III-9 — Signal Processing
III-317
Savitzky, A., and M.J.E. Golay, Smoothing and differentiation of data by simplified least squares proce-
dures, Analytical Chemistry, 36, 1627–1639, 1964.
Wigner, E. P., On the quantum correction for thermo-dynamic equilibrium, Physics Review, 40, 749-759, 1932.

Chapter III-9 — Signal Processing
III-318
