# MatrixLUD

MatrixLUBkSub
V-546
See Also
Matrix Math Operations on page III-138 for more about Igor’s matrix routines and for background 
references with details about the LAPACK libraries.
MatrixLUBkSub 
MatrixLUBkSub matrtixL, matrixU, index, vectorB
The MatrixLUBkSub operation provides back substitution for LU decomposition.
Details
This operation is used to solve the matrix equation Ax=b after you have performed LU decomposition (see 
MatrixLUD). Feed this routine M_Lower, M_Upper and W_LUPermutation from MatrixLUD along with 
your right-hand-side vector b. The solution vector x is returned as M_x. The array b can be a matrix 
containing a number of b vectors and the M_x will contain a corresponding set of solution vectors.
Generates an error if the dimensions of the input matrices are not appropriate.
See Also
Matrix Math Operations on page III-138 for more about Igor’s matrix routines.
MatrixLUD 
MatrixLUD [flags] matrixA
The MatrixLUD operation computes the LU factorization of a matrix. The general form of the 
factorization/decomposition is expressed in terms of matrix products:
M_Pt x srcWave = M_Lower x M_Upper
M_Pt, M_Lower and M_Upper are outputs created by MatrixLUD.
M_Pt is the transpose of the permutation matrix, M_Lower is a lower triangular matrix with 1's on the main 
diagonal and M_Upper is an upper triangular (or trapezoidal) matrix.
The MatrixLUD operation was substantially changed in Igor Pro 7.00. See the /B flag for information about 
backward compatibility.
Flags
/B
This flag is provided for backward compatibility only; it is not compatible with any other 
flag. /B makes MatrixLUD behave as it did in Igor Pro 6. This flag is deprecated and will 
be removed in a future version of Igor.
The input is restricted to a 2D real valued, single or double precision square matrix. The 
outputs (all double precision) are stored in the waves M_Upper, M_Lower and 
W_LUPermutation in the current data folder.
The W_LUPermutation output wave was needed for solving a linear system of equations 
using the back substitution routine, MatrixLUBkSub. For better computation methods 
see MatrixLinearSolve, MatrixLinearSolveTD and MatrixLLS.
/CMF
Uses Combined Matrix Format where the upper and lower matrix factors are combined 
into a single matrix saved in the wave M_LUFactors in the current data folder. The upper 
matrix factor is constructed from the main and from the upper diagonals of M_LUFactors. 
The lower matrix factor is constructed from the lower diagonals of M_LUFactors and 
setting the main diagonal to 1.
/MIND
Finds the minimum magnitude diagonal element of M_Upper and store it in V_min. This 
is useful for investigating the behavior of the determinant of the matrix when it is close to 
being singular.
/PMAT
Saves the transpose of the permutation matrix in a double precision wave M_Pt in the 
current data folder. Note that the permutation matrix is orthogonal and so the inverse of 
the matrix is equal to its transpose.
/SUMP
Computes the sum of the phases of the elements on the main diagonal of M_Upper and 
store in the variable V_Sum. V_Sum is initialized to NaN and is set only if /SUMP is 
specified and M_Upper is complex.
