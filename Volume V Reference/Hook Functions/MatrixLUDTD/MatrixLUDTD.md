# MatrixLUDTD

MatrixLUDTD
V-547
Details
The input matrix srcWave is an MxN real or complex wave of single or double precision. Use MatrixLUDTD if 
your input is tri-diagonal.
The main results of the factorization are stored in the waves M_Lower, M_Upper and M_Pt. Alternatively the 
lower and upper factors can be combined and stored in the wave M_LUFactors (see /CMF). The waves 
M_Lower, M_Upper and M_LUFactors have the same data type as the input wave. M_Pt is always double 
precision.
When the input matrix srcWave is square (NxN), the resulting matrices have the same dimensions (NxN). You 
can reconstruct the input using the MatrixOp expression:
MatrixOp/O rA=(M_Pt^t) x (M_Lower x M_Upper)
If the input matrix is rectangular (NxM) the reconstruction depends on the size of N and M. If N<M:
MatrixOp/O rA=(M_Pt^t) x (subRange(M_lower,0,N-1,0,N-1) x M_Upper)
If N>M:
MatrixOp/O rA=(M_Pt^t) x M_lower x subRange(M_Upper,0,M-1,0,M-1)
The variable V_flag is set to zero if the operation succeeds and to 1 otherwise (e.g., if the input is singular). When 
you use the /B flag the polarity of the matrix is returned in the variable V_LUPolarity. The variables V_Sum and 
V_min are also set by some of the flag options above.
See Also
MatrixLUDTD, MatrixLUBkSub, MatrixLinearSolve, MatrixLinearSolveTD, MatrixLLS, MatrixOp
Matrix Math Operations on page III-138 for more about Igor’s matrix routines.
MatrixLUDTD
MatrixLUDTD [flags] srcMain, srcUpper, srcLower
The MatrixLUDTD operation computes the LU factorization of a tri-diagonal matrix. The general form of 
the factorization/decomposition is expressed in terms of matrix products:
M_Pt x triDiagonalMat = M_Lower x M_Upper
triDiagonalMat is the matrix defined by the main diagonal specified by srcMain, the upper diagonal 
specified by srcUpper, and the lower diagonal specified by srcLower.
M_Pt is an output wave created when the /PMAT flag is present. M_Lower and M_Upper are output waves 
created when the /FM flag is present. M_Pt is the transpose of the permutation matrix, M_Lower is a lower 
triangular matrix with 1's on the main diagonal and M_Upper is an upper triangular (or trapezoidal) 
matrix.
Flags
Details
You specify the tridiagonal matrix using three 1D waves of the same data type (single or double precision 
real or complex).
If /FM is present the output of the operation consists of two 2D waves and one 1D wave:
M_Lower is a lower triangular matrix with 1's on the main diagonal.
/MIND
Finds the minimum magnitude diagonal element of M_Upper and stores it in V_min. This 
feature is useful if you want to investigate the behaviour of the determinant of the matrix 
when it is close to being singular.
/PMAT
Saves the transpose of the permutation matrix in the wave M_Pt in the current data folder. 
Note that the permutation matrix is orthogonal and so the inverse of the matrix is equal 
to its transpose.
/SUMP
Computes the sum of the phases of the elements on the main diagonal of M_Upper and 
store in the variable V_Sum. Note that the variable is initialized to NaN and that it is not 
set unless this flag is specified and M_Upper is complex.
/FM
The full matrix output is stored in the waves M_Lower and M_Upper in the current data 
folder.
