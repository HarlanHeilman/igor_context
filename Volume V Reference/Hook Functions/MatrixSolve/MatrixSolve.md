# MatrixSolve

MatrixSchur
V-579
Details
Matrix balancing is usually called internally by LAPACK routines when there is large variation in the 
magnitude of matrix elements. Following matrix balancing the computed eigenvalues are expected to be 
more accurate but the resulting eigenvectors are not the correct eigenvectors of the original pre-balanced 
matrix. MatrixReverseBalance is then applied to the balanced eigenvectors in order to obtain the 
eigenvectors of the original matrix.
The operation uses outputs from MatrixBalance as inputs. Pass the W_scale output from MatrixBalance as 
the scaleWave parameter. Pass the V_min and V_max outputs from MatrixBalance as the /LH low and high 
parameters. See MatrixBalance for an example.
Output Variables
References
The operation uses the following LAPACK routines: sgebak, dgebak, cgebak, and zgebak.
See Also
MatrixBalance
MatrixSchur 
MatrixSchur [/Z] srcMatrix
The MatrixSchur operation computes for an NxN nonsymmetric srcMatrix, the eigenvalues, the real Schur 
form A and the matrix of Schur vectors V.
The Schur factorization has the form: S = V x A x (V^T), where V^T is the transpose (use V^H if S is complex) 
and x denotes matrix multiplication.
Flags
Details
The operation creates:
The variable V_flag is set to 0 when there is no error; otherwise it contains the LAPACK error code.
Examples
You can test this operation for an N-by-N source matrix:
Make/D/C/N=(5,5) M_S=cmplx(enoise(1),enoise(1))
MatrixSchur M_S
MatrixOp/O unitary=(M_V^h) x M_V
// Check unitary
MatrixOp/O diff=abs(M_S-M_V x M_A x (M_V^H))
// Check decomposition
See Also
Matrix Math Operations on page III-138 for more about Igor’s matrix routines and for background 
references with details about the LAPACK libraries.
MatrixSolve 
MatrixSolve method, matrixA, vectorB
The MatrixSolve operation was superseded by MatrixLLS and is included for backward compatibility only.
Used to solve matrix equation Ax=b using the method of your choice. Choices for method are:
V_Flag
Set to zero when the operation succeeds. Otherwise, when V_flag is positive the value 
is a standard Igor error code. When V_flag is negative it is an indication of an invalid 
input parameter.
 /Z
No error reporting.
 M_A
Upper triangular matrix containing the Schur form A.
 M_V
Unitary matrix containing the orthogonal matrix V of the Schur vectors.
 W_REigenValues
 W_IEigenValues
Waves containing the real and imaginary parts of the eigenvalues when srcMatrix is 
a real wave. If srcMatrix is complex, the eigenvalues are stored in W_eigenValues.
