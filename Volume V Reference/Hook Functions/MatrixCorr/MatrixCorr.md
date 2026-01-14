# MatrixCorr

MatrixConvolve
V-532
and the infinity-norm is defined by
The function returns a NaN if there is any error in the input parameters. 
References
http://en.wikipedia.org/wiki/Matrix_norm
See Also
MatrixSVD provides a condition number for L2 norm using the ratio of singular values.
The MatrixOp operation for more efficient matrix operations.
Matrix Math Operations on page III-138 for more about Igor's matrix routines.
MatrixConvolve 
MatrixConvolve [/R=roiWave] coefMatrix, dataMatrix
The MatrixConvolve operation convolves a small coefficient matrix coefMatrix into the destination 
dataMatrix.
Flags
Details
On input coefMatrix contains an NxM matrix of coefficients where N and M should be odd. Generally N and 
M will be equal. If N and M are greater than 13, it is more efficient to perform the convolution using the 
Fourier transform (see FFT).
The convolution is performed in place on the data matrix and is acausal, i.e., the output data is not shifted.
Edges are handled by replication of edge data.
When dataMatrix is an integer type, the results are clipped to limits of the given number type. For example, 
unsigned byte is clipped to 0 to 255.
MatrixConvolve works also when both coefMatrix and dataMatrix are 3D waves. In this case the convolution 
result is placed in the wave M_Convolution in the current data folder, and the optional /R=roiWave is 
required to be an unsigned byte wave that has the same dimensions as dataMatrix.
This operation does not support complex waves.
See Also
MatrixFilter and ImageFilter for filter convolutions.
Matrix Math Operations on page III-138 for more about Igor’s matrix routines.
The Loess operation.
MatrixCorr 
MatrixCorr [/COV][/DEGC] waveA [, waveB]
The MatrixCorr operation computes the correlation or covariance or degree of correlation matrix for the 
input 1D wave(s).
If we denote elements of waveA by {xi} and elements of waveB by {yi} then the correlation matrix for these 
waves is the vector product of the form:
/R=roiWave 
Modifies only data contained inside the region of interest. The ROI wave should be 8-
bit unsigned with the same dimensions as dataMatrix. The interior of the ROI is 
defined by zeros and the exterior is any nonzero value.
A ∞=
max
1≤i ≤m
aij .
j=1
n
∑
