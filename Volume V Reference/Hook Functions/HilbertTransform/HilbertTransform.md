# HilbertTransform

HilbertTransform
V-348
Flags
See Also
The ShowTools operation.
HilbertTransform 
HilbertTransform [/Z][/O][/DEST=destWave] srcWave
The HilbertTransform operation computes the Hilbert transformation of srcWave, which is a real or complex 
(single or double precision) wave of 1-3 dimensions. The result of the HilbertTransform is stored in 
destWave, or in the wave W_Hilbert (1D) or M_Hilbert in the current data folder.
Flags
Details
The Hilbert transform of a function f(x) is defined by:
Theoretically, the integral is evaluated as a Cauchy principal value. Computationally one can write the 
Hilbert transform as the convolution:
which by the convolution theorem of Fourier transforms, may be evaluated as the product of the transform 
of f(x) with -i*sgn(x) where:
/A
Sizes the window automatically to make extra room for the tool palette. This 
preserves the proportion and size of the actual graph area.
/W=winName
Hides the tool palette in the named window. This must be the first flag specified when 
used in a Proc or Macro or on the command line.
winName must be either the name of a top-level window or a path leading to an 
exterior panel window (see Exterior Control Panels on page III-443).
/DEST=destWave
Creates a real wave reference for the destination wave in a user function. See 
Automatic Creation of WAVE References on page IV-72 for details.
/O
Overwrites srcWave with the transform.
/PAD={dim1 [, dim2, dim3, dim4]}
Converts srcWave into a padded wave of dimensions dim1, dim2…. The padded wave 
contains the original data at the start of the dimension and adds zero entries to each 
dimension up to the specified dimension size. The dim1… values must be greater than 
or equal to the corresponding dimension size of srcWave. If you need to pad just the 
lowest dimension(s) you can omit the remaining dimensions; for example, 
/PAD=dim1 will set dim2 and above to match the dimensions in srcWave.
This flag was added in Igor Pro 7.00.
/Z
No error reporting.
F(t) = 1
πt
f (x)dx
x −t .
−∞
∞
∫
F(t) = −1
πt ∗f (t),
sgn(x) =
−1
x < 0
0
x = 0
1
x > 0
.
⎧
⎨⎪
⎩⎪
