# conj

conj
V-84
at compile time, Igor creates an automatic local wave reference variable named DestWaveName. At 
runtime, if the wave reference variable is NULL, the name is taken to be a literal name and a wave of that 
name is created in the current data folder.
If the wave reference variable is not NULL, as would occur after the first call to Concatenate in a loop, then 
the referenced wave is overwritten no matter where it is located.
If your intention is to create or overwrite a wave in the current data folder, you should use one of the 
following two methods:
Concatenate/O ..., $"DestWaveName"
WAVE DestWaveName
// Needed only if you subsequently reference the dest wave
or
Concatenate/O ....., DestWaveName
// Then after you are finished using DestWaveName...
WAVE DestWaveName=$""
Examples
// Given the following waves:
Make/N=10 w1,w2,w3
Make/N=11 w4
Make/N=(10,7) m1,m2,m3
Make/N=(10,8) m4
Make/N=(9,8) m5
// Concatenate 1D waves
Concatenate/O {w1,w2,w3},wdest
// wdest is a 10x3 matrix
Concatenate {w1,w2,w3},wdest
// wdest is a 10x6 matrix
Concatenate/NP/O {w1,w2,w3},wdest
// wdest is a 30-point 1D wave
Concatenate/O {w1,w2,w3,w4},wdest
// wdest is a 41-point 1D wave
// Concatenate 2D waves
Concatenate/O {m1,m2,m3},wdest
// wdest is a 10x7x3 volume
Concatenate/NP/O {m1,m2,m3},wdest
// wdest is a 10x21 matrix
Concatenate/O {m1,m2,m3,m4},wdest
// wdest is a 10x29 matrix
Concatenate/O {m4,m5},wdest 
// wdest is a 152-point 1D wave
Concatenate/O/NP=0 {m4,m5},wdest 
// wdest is a 19x8 matrix
// Concatenate 1D and 2D waves
Concatenate/O {w1,m1},wdest
// wdest is a 10x8 matrix
Concatenate/O {w4,m1},wdest
// wdest is a 81-point 1D wave
// Append rows to 2D wave
Make/O/N=(3,2) m6, m7
Concatenate/NP=0 {m6}, m7
// m7 is a 6x2 matrix
// Append columns to 2D wave
Make/O/N=(3,2) m6, m7
Concatenate/NP=1 {m6}, m7
// m7 is a 3x4 matrix
// Append layer to 2D wave
Make/O/N=(3,2) m6, m7
Concatenate/NP=2 {m6}, m7
// m7 is a 3x2x2 volume
// The last command has the same effect as:
// Concatenate {m6}, m7
// Both versions extend add a third dimension to m7
See Also
Duplicate, Redimension, SplitWave
conj 
conj(z)
The conj function returns the complex conjugate of the complex value z.
See Also
cmplx, imag, magsqr, p2rect, r2polar, and real functions.
