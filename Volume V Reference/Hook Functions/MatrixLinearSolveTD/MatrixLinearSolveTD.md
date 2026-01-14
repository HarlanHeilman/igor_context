# MatrixLinearSolveTD

MatrixLinearSolveTD
V-543
Flags
Details
If /O is not specified, the operation also creates the n-by-n wave M_A and the n-by-nrhs solution wave M_B.
The variable V_flag is created by the operation. If the operation completes successfully, V_flag is set to zero, 
otherwise it is set to the LAPACK error code.
See Also
Matrix Math Operations on page III-138 for more about Igor’s matrix routines and for background 
references with details about the LAPACK libraries.
MatrixLinearSolveTD 
MatrixLinearSolveTD [/Z] upperW, mainW, lowerW, matrixB
The MatrixLinearSolveTD operation solves the linear system TDMatrix*X = matrixB. In the matrix product on 
the left hand side, TDMatrix is a tridiagonal matrix with upper diagonal upperW, main diagonal mainW, and 
lower diagonal lowerW. It solves for vector(s) X depending on the number of columns (NRHS) in matrixB.
/M=method
/D={sub,super}
Specifies a band diagonal matrix. The subdiagonal (sub) and superdiagonal (super) 
size must be positive integers.
/L
Uses the lower triangle of matrixA. /L and /U are mutually exclusive flags.
/U
Uses the upper triangle of matrixA. /U is the default.
/O
Overwrites matrixA and matrixB with the results of the operation. This will save on 
the amount of memory needed.
/Z
No error reporting.
Determines the solution method which best suites input matrixA.
method=1:
Uses simple LU decomposition (default). See also LAPACK 
documentation for SGESV, CGESV, DGESV, and ZGESV.
Creates the wave W_IPIV that contains the pivot indices that define 
the permutation matrix P. Row (i) if the matrix was interchanged 
with row ipiv(i).
method=2:
If matrixA is band diagonal, you also have to specify /D. See also 
LAPACK documentation for SGBSV, CGBSV, DGBSV, and 
ZGBSV.
Creates the wave W_IPIV, which contains the pivot indices that 
define the permutation matrix P. Row (i) if the matrix was 
interchanged with row ipiv(i). Also note that if you are using the 
/O flag, the overwritten waves may have a different dimensions.
method=4:
For tridiagonal matrix; still expecting full matrix in matrixA, but 
it will ignore the data in the elements outside the 3 diagonals. 
See also LAPACK documentation for SGTSV, CGTSV, DGTSV, 
and ZGTSV.
method=8:
Symmetric/hermitian. See also LAPACK documentation for 
SPOSV, CPOSV, DPOSV, and ZPOSV.
method=16:
Complex symmetric (complex only). See also LAPACK 
documentation for CSYSV and ZSYSV.
