# MatrixSparse TODENSE

Chapter III-7 — Analysis
III-160
Output: A sparse matrix in CSC format represented by W_CSCValues, W_CSCRows, and W_CSCPointerB.
MatrixSparse TOCSC Example
Function DemoMatrixSparseTOCSC()
// Create the Wikipedia example 4x4 matrix in dense format
Make/FREE/D/N=(4,4) dense
dense[0][0] = {0,5,0,0}
dense[0][1] = {0,8,0,6}
dense[0][2] = {0,0,3,0}
dense[0][3] = {0,0,0,0}
// Create a sparse matrix in CSC format from the dense matrix
// MatrixSparse requires rowsA and colsA even though they are not used here
MatrixSparse rowsA=4, colsA=4, matrixB=dense, operation=TOCSC
WAVE W_CSCValues, W_CSCRows, W_CSCPointerB
// Outputs from TOCSC
// Print the 1D waves representing the CSC sparse matrix
Print W_CSCValues
Print W_CSCRows
Print W_CSCPointerB
End
MatrixSparse TOCSR
TOCSR produces a sparse output matrix in CSR format equivalent to the input matrix which may be in 
dense, COO, or CSC format.
Inputs: A dense matrix specified by the matrixB keyword or a sparse matrix specified by the cooA or cscA 
keywords.
Output: A sparse matrix in CSR format represented by W_CSRValues, W_CSRColumns, and W_CSRPoint-
erB.
MatrixSparse TOCSR Example
Function DemoMatrixSparseTOCSR()
// Create the Wikipedia example 4x4 matrix in dense format
Make/FREE/D/N=(4,4) dense
dense[0][0] = {0,5,0,0}
dense[0][1] = {0,8,0,6}
dense[0][2] = {0,0,3,0}
dense[0][3] = {0,0,0,0}
// Create a sparse matrix in CSR format from the dense matrix
// MatrixSparse requires rowsA and colsA even though they are not used here
MatrixSparse rowsA=4, colsA=4, matrixB=dense, operation=TOCSR
WAVE W_CSRValues, W_CSRColumns, W_CSRPointerB
// Outputs from TOCSR
// Print the 1D waves representing the CSR sparse matrix
Print W_CSRValues
Print W_CSRColumns
Print W_CSRPointerB
End
MatrixSparse TODENSE
TODENSE produces a dense output matrix equivalent to the sparse input matrix which may be in COO, 
CSC, or CSR format.
Inputs: A sparse matrix specified by the cooA, cscA, or csrA keywords.
Output: Dense output matrix M_cooToDense, M_cscToDense, or M_csrToDense.
