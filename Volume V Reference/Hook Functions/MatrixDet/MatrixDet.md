# MatrixDet

MatrixDet
V-533
where * denotes complex conjugation. If you use the optional waveB then the matrix is the cross correlation 
matrix. waveB must have the same length of waveA but it does not have to be the same number type.
Flags
The flags are mutually exclusive; only one matrix can be generated at a time.
Examples
The covariance matrix calculation is equivalent to:
Variable N=1/(DimSize(waveA,0)-1)
Variable ma=mean(waveA,-inf,inf)
Variable mb=mean(waveB,-inf,inf)
waveA-=ma
waveB-=mb
MatrixTranspose/H waveB
MatrixMultiply waveA,waveB
M_product*=N
See Also
Matrix Math Operations on page III-138 for more about Igor’s matrix routines.
References
Hayes, M.H., Statistical Digital Signal Processing And Modeling, 85 pp., John Wiley, 1996.
MatrixDet 
matrixDet(dataMatrix)
The MatrixDet function returns the determinant of dataMatrix. The matrix wave must be a real, square 
matrix or else the returned value will be NaN.
Details
The function calculates the determinant using LU decomposition. If, following the decomposition, any one of 
the diagonal elements is either identically zero or equal to 10-100, the return value of the function will be zero.
/COV
Calculates the covariance matrix.
The covariance matrix for the same input is formed in a similar way after subtracting from 
each vector its mean value and then dividing the resulting matrix elements by (n-1) where 
n is the number of elements of waveA.
Results are stored in the M_Corr or M_Covar waves in the current data folder.
/DEGC
Calculates the complex degree of correlation. The degree of correlation is defined by:
where M_Covar is the covariance matrix and Var(wave) is the variance of the wave.
The complex degree of correlation should satisfy: 
x1
x2
x3

xn
⎡
⎣
⎢
⎢
⎢
⎢
⎢
⎢
⎤
⎦
⎥
⎥
⎥
⎥
⎥
⎥
y1
y2
y3
…
yn
⎡⎣
⎤⎦
*
=
x1y1
*
x1y2
*
x1y3
*
…
x1yn
*
x2y1
*
x2y2
*
x2y3
*
x2yn
*
x3y1
*
x3y2
*
x3y3
*
x3yn
*

xny1
*
xny2
*
xny3
*

xnyn
*
⎡
⎣
⎢
⎢
⎢
⎢
⎢
⎢
⎢
⎤
⎦
⎥
⎥
⎥
⎥
⎥
⎥
⎥
degC =
M _Covar
Var(waveA)⋅Var(waveB)
,
0 ≤degC ≤1.
