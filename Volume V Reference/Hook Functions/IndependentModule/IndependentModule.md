# IndependentModule

IndependentModule
V-437
Examples 
To see what one of the windowing filters looks like:
Make/N=(80,80) wShape
// Make a matrix
ImageWindow/I/O Blackman wShape
// Replace with windowing filter
Display;AppendImage wShape
// Display windowing filter
Make/N=2 xTrace={0,79},yTrace={39,39}
// Prepare for 1D section
AppendToGraph yTrace vs xTrace
ImageLineProfile srcWave=wShape, xWave=xTrace, yWave=yTrace
Display W_ImageLineProfile
// Display 1D section of filter
See Also
The WindowFunction operation for information about 1D applications.
Spectral Windowing on page III-275. Chapter III-11, Image Processing contains links to and descriptions 
of other image operations.
See FFT operation for other 1D windowing functions for use with FFTs; DSPPeriodogram uses the same 
window functions. See Correlations on page III-362.
DPSS
References
For further windowing information, see page 243 of:
Pratt, William K., Digital Image Processing, John Wiley, New York, 1991.
IndependentModule 
#pragma IndependentModule = imName
The IndependentModule pragma designates groups of one or more procedure files that are compiled and 
linked separately. Once compiled and linked, the code remains in place and is usable even though other 
procedures may fail to compile. This allows functioning control panels and menus to continue to work 
regardless of user programming errors.
See Also
Independent Modules on page IV-238, The IndependentModule Pragma on page IV-55 and #pragma.
Kaiser:
where I0{…} is the zeroth-order Bessel function of the first kind and a is 
the design parameter specified by /P=param.
KaiserBessel20:  = 2.0
KaiserBessel25:  = 2.5
KaiserBessel30:  = 3.0
I0 ω a
L −1
2
⎛
⎝⎜
⎞
⎠⎟
2
−n −L −1
2
⎛
⎝⎜
⎞
⎠⎟
2
⎛
⎝
⎜
⎞
⎠
⎟
I0 ω a
L −1
2
⎛
⎝⎜
⎞
⎠⎟
⎛
⎝⎜
⎞
⎠⎟
0 ≤n ≤L −1
w(n) =
I0 πα 1−
n
L / 2
⎛
⎝⎜
⎞
⎠⎟
2
⎛
⎝
⎜
⎞
⎠
⎟
I0 πα
(
)
0 ≤n ≤L
2
I0(x) =
x2 / 4
(
)
k
k!
( )
2
.
k=0
∞
∑
