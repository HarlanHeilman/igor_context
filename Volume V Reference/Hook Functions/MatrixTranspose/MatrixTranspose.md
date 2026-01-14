# MatrixTranspose

MatrixTrace
V-585
Details
The singular value decomposition is computed using LAPACK routines. The diagonal elements of matrix 
W are returned as a 1D wave named W_W. If /B is used W_W will have N elements. Otherwise the number 
of elements in W_W is min(M,N).
The matrix V is returned in a matrix wave named M_V if /B is used otherwise the transpose V^T is returned 
in the wave M_VT.
All output objects are created in the current data folder.
The variable V_flag is set to zero if the operation succeeds. It is set to 1 if the algorithm fails to converge.
The variable V_SVConditionNumber is set to the condition number of the input matrix. The condition 
number is the ratio of the largest singular value to the smallest.
Example
Make/O/D/N=(10,20) A=gnoise(10)
MatrixSVD A
MatrixOp/O diff=abs(A-(M_U x DiagRC(W_W,10,20) x M_VT))
Print sum(diff,-inf,inf)
References
J.C. Nash and S.Shlien "Simple Algorithms for the Partial Singular Value Decomposition", The Comp. J. (30) 
No. 3 1987.
See Also
The MatrixOp operation for more efficient matrix operations.
Matrix Math Operations on page III-138 for more about Igor’s matrix routines and for background 
references with details about the LAPACK libraries.
MatrixTrace 
matrixTrace(dataMatrix)
The matrixTrace function calculates the trace (sum of diagonal elements) of a square matrix. dataMatrix can 
be of any numeric data type.
If the matrix is complex, it returns the sum of the magnitudes of the diagonal elements.
See Also
Matrix Math Operations on page III-138 for more about Igor’s matrix routines.
MatrixTranspose 
MatrixTranspose [/H] matrix
The MatrixTranspose operation Swaps rows and columns in matrix.
Does not take complex conjugate if data are complex. You can do that as a follow-on step.
Swaps row and column labels, units and scaling.
This works with text as well as numeric waves. If the matrix has zero data points, it just swaps the row and 
column scaling.
Flags
See Also
The MatrixOp operation for more efficient matrix operations.
Matrix Math Operations on page III-138 for more about Igor’s matrix routines.
/H
Computes the Hermitian conjugate of a complex wave.
