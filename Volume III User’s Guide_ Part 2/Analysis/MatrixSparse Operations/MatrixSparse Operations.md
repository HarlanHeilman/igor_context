# MatrixSparse Operations

Chapter III-7 — Analysis
III-156
The conversion operations (TOCOO, TOCSC, TOCSR, TODENSE) accept inputs in COO, CSC, CSR, or 
dense formats.
MatrixSparse Index Data Type
Index waves, containing row or column indices or indices into values waves (i.e., pointer waves), must be 
signed 64-bit integer waves which are typically created using Make/L.
MatrixSparse Transformations
You can optionally tell MatrixSparse to operate on a transformed version of an input sparse matrix. The 
available transformations are named T for transpose, H for Hermitian, and N for no transformation 
(default).
The opA keyword tells MatrixSparse to operate on a transformed version of sparse matrix A. For example 
this command:
MatrixSparse rowsA=4, colsA=4, csrA={values,columns,ptrB}, opA=T, 
vectorX=vector, operation=MV
operates on a transposed version of sparse matrix A.
The opG keyword tells MatrixSparse to operate on a transformed version of sparse matrix G.
Optional Sparse Matrix Information
The MatrixSparse sparseMatrixType keyword allows you to provide optional information characterizing 
the sparse matrix inputs. If you know the characteristics of a sparse matrix input, you can use sparseMa-
trixType to pass this information to MatrixSparse. This can improve performance.
The syntax of the sparseMatrixType keyword is:
sparseMatrixType={smType,smMode,smDiag}
All of the parameters are keywords.
smType: GENERAL, SYMMETRIC, HERMITIAN, TRIANGULAR, DIAGONAL, BLOCK_TRIANGULAR, 
or BLOCK_DIAGONAL.
smMode: LOWER or UPPER.
smDiag: DIAG or NON_DIAG.
MatrixSparse Operations
This section documents each of the operations supported by MatrixSparse. It is assumed that you have read 
and understood the background material presented under Sparse Matrices on page III-151.
The following sections use these abbreviations:
Symbol
Stands For
Specified By Keywords
smA
Sparse matrix A
rowsA, colsA, csrA (1)
smG
Sparse matrix G
rowsG, colsG, csrG (1)
dmB
Dense matrix B
matrixB
dmC
Dense matrix C
matrixC
vX
Vector X
vectorX
vY
Vector Y
vectorY
alpha
Scalar value alpha
alpha and, for complex input, alphai
