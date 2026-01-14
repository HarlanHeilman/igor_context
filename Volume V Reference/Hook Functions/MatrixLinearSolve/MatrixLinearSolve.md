# MatrixLinearSolve

MatrixLinearSolve
V-542
Flags
Examples
Make/O/N=(2,2) mat0 = {{2,3},{1,7}}
MatrixInverse mat0
// Creates wave M_inverse
MatrixOp/O/T=1 mat1 = M_inverse x mat0
// Check result
Make/O/D/N=(4,6) mat1 = enoise(4)
MatrixInverse/P mat1
MatrixOP/O/T=1 aa = mat1 x M_Inverse
MatrixOP/O/P=1 avgAbsErr = sum(abs(mat1 x M_Inverse - identity(4)))/12
See Also
The MatrixOp operation for more efficient matrix operations.
Matrix Math Operations on page III-138 for more about Igor’s matrix routines.
References
See sec. 5.5.4 of:
Golub, G.H., and C.F. Van Loan, Matrix Computations, 2nd ed., Johns Hopkins University Press, 1986.
MatrixLinearSolve 
MatrixLinearSolve [flags] matrixA matrixB
The MatrixLinearSolve operation solves the linear system matrixA *X=matrixB where matrixA is an N-by-N 
matrix and matrixB is an N-by-NRHS matrix of the same data type.
/D
Creates the wave W_W that contains eigenvalues of the singular value decomposition (SVD) 
for the pseudo-inverse calculation. If one or more of the eigenvalues are small, the matrix may 
be close to singular.
/G
Calculates only the direct inverse; does not affect calculation of pseudo-inverse. By default, it 
calculates the inverse of the matrix using LU decomposition. The inverse is calculated using 
Gauss-Jordan method. The only advantage in using Gauss-Jordan is that it is more likely to 
flag singular matrices than the LU method.
/O
Overwrites the source with the result.
/P
Calculates the pseudo-inverse of a matrix using the SVD algorithm. The calculated pseudo-
inverse is a unique minimal solution to the problem:
min
X∈n×m AX −Im .
