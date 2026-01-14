# Redimension

ReadVariables
V-788
Structure RectF
float top
float left
float bottom
float right
EndStructure
ReadVariables 
ReadVariables
The ReadVariables operation reads variables into an experiment.
ReadVariables is used automatically when you open an experiment. You need not invoke it.
real 
real(z)
The real function returns the real component of the complex value z.
See Also
The functions cmplx, conj, imag, p2rect, and r2polar.
Redimension 
Redimension [flags] waveName [, waveName]…
The Redimension operation remakes the named waves, preserving their contents as much as possible.
Flags
/B
Converts waves to 8-bit signed integer or unsigned integer if /U is present.
/C
Converts real waves to complex.
/D
Converts single precision waves to double precision.
/E=e
/I
Converts waves to 32-bit signed integer or unsigned integer if /U is present.
/L
Converts waves to 64-bit signed integer or unsigned integer if /U is present. Requires Igor Pro 
7.00 or later.
/N=n
n is the new number of points each wave will have. Multidimensional waves are converted to 
1 dimension. If n =-1, the wave is converted to a 1-dimensional wave with the original number 
of rows.
/N=(n1, n2, n3, n4)
n1, n2, n3, n4 specify the number of rows, columns, layers, and chunks each wave will have. 
Trailing zeros can be omitted (e.g., /N=(n1, n2, 0, 0) can be abbreviated as /N=(n1, n2)). If any 
dimension size is to remain unchanged, pass -1 for that dimension.
/R
Converts complex waves to real by discarding the imaginary part.
/S
Converts double precision waves to single precision.
/U
Converts integer waves to unsigned.
/W
Converts waves to 16-bit integer (unsigned integer if /U is present).
/Y=type
Specifies wave data type. See details below.
Controls the redimension mode:
e=0:
No special action (default).
e=1:
Force reshape without converting or moving data.
e=2:
Perform endian swap. See FBinRead for a discussion of endian byte ordering.
