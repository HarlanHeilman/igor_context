# MatrixCondition

MatrixCondition
V-531
mat[0][0] = {2,88,164}
mat[0][1] = {0,1,1}
mat[0][2] = {1e-05,0,1}
MatrixBalance mat
Wave W_scale,M_Balanced
Print "EqualWaves(input,output,-1)", EqualWaves(mat,M_Balanced,-1)
// Calculate right eigenvectors for the original matrix
MatrixEigenV/R mat
Wave/Z M_R_eigenVectors
Duplicate/O M_R_eigenVectors, origEigenVectors
Wave/Z W_eigenValues
Duplicate/O W_eigenValues,origEigenValues
// Calculate the right eigenvectors for the balanced matrix
MatrixEigenV/R M_Balanced
Wave/Z M_R_eigenVectors
Wave/Z W_eigenValues
MatrixOP/O/FREE tmp = sum(abs(origEigenValues-W_eigenValues))
if (tmp[0] > 0.1)
Print "Eigenvalues difference"
else
Print "Eigenvalues OK"
endif
// Reverse the balance and compare with original eigenvectors
MatrixReverseBalance/J=P/SIDE=R/LH={V_min,V_max} W_Scale,M_R_eigenVectors
Wave/Z M_RBEigenvectors
MatrixOP/O/FREE tmp = sum(abs(M_RBEigenvectors-origEigenVectors))
if (tmp[0] > 0.1)
Print "Eigenvectors difference on reverse"
else
Print "Eigenvectors ok on reverse"
endif
End
References
The operation uses the following LAPACK routines: sgebal, dgebal, cgebal, and zgebal.
See Also
MatrixReverseBalance
MatrixCondition
MatrixCondition(wave2D, mode)
MatrixCondition returns the estimated reciprocal of the condition number of a 2D square matrix wave2D.
The condition number is the product of the norm of the matrix with the norm of the inverse of the matrix 
(see details below). The type of norm is determined by the value of the mode parameter. 1-norm is used if 
mode is 1 and infinity-norm is used otherwise.
The MatrixCondition function was added in Igor Pro 7.00.
Details
The function uses LAPACK routines to estimate the reciprocal condition number by first obaining the norm 
of the input matrix and then using LU decomposition to obtain the norm of the inverse of the matrix. The 
estimate returned is
where the norms are selected by the choice of the mode parameter. The 1-norm of matrix A with elements 
aij is defined as
reciprocalCon =
1
wave2D * wave2D−1 ,
A 1 =
max
1≤j ≤n
aij ,
i=1
m
∑
