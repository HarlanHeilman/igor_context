# WindowFunction

Window
V-1097
See Also
CWT, FFT, and WaveTransform operations.
For further discussion and examples see Wigner Transform on page III-281.
References
Wigner, E. P., On the quantum correction for thermo-dynamic equilibrium, Physics Review, 40, 749-759, 
1932.
Bartelt, H.O., K.-H. Brenner, and A.W. Lohman, The Wigner distribution function and its optical 
production, Optics Communications, 32, 32-38, 1980.
Window 
Window macroName([parameters]) [:macro type]
The Window keyword introduces a macro that recreates a graph, table, layout, or control panel window. 
The macro appears in the appropriate submenu of the Windows menu. Window macros are automatically 
created when you close a graph, table, layout, control panel, or XOP target window. You should use Macro, 
Proc, or Function instead of Window for your own window macros. Otherwise, it works the same as Macro.
See Also
The Macro, Proc, and Function keywords. Data Folders and Window Recreation Macros on page II-111 
for details.
Macro Syntax on page IV-118 for further information.
WindowFunction 
WindowFunction [/FFT[=f] /DEST=destWave] windowKind, srcWave
The WindowFunction operation multiplies a one-dimensional (real or complex) srcWave by the named 
window function.
By default the result overwrites srcWave.
Parameters
Flags
srcWave
A one-dimensional wave of any numerical type. See ImageWindow for windowing 
two-dimensional data.
windowKind
Specifies the windowing function. Choices for windowKind are:
Bartlett, Blackman367, Blackman361, Blackman492, Blackman474, Cos1, Cos2, Cos3, 
Cos4, Hamming, Hanning, KaiserBessel20, KaiserBessel25, KaiserBessel30, Parzen, 
Poisson2, Poisson3, Poisson4, Riemann, and an assortment of flat-top windows listed 
under FFT.
See FFT for window equations and details. The equations assume that /FFT=1.
/DEST=destWave
Creates or overwrites destWave with the result of the multiplication of srcWave and the 
window function.
When used in a function, the WindowFunction operation by default creates a real 
wave reference for the destination wave. See Automatic Creation of WAVE 
References on page IV-72 for details.
/FFT [=1]
The window interval is 0…N=numpnts(srcWave). This sets the first value of srcWave 
to zero, but not the last value. This is appropriate for windowing data in preparation 
for Fourier Transforms, and is the same algorithm used by FFT.
The window interval is 0…N=numpnts(srcWave)-1 if /FFT is missing or /FFT=0. 
This sets the first and last value of srcWave to 0. This is the (only) algorithm that the 
Hanning operation uses.
