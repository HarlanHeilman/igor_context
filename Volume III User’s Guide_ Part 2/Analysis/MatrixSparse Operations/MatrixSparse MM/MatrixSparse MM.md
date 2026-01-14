# MatrixSparse MM

Chapter III-7 — Analysis
III-157
(1) For the matrix format conversion operations TOCOO, TOCSC, TOCSR, and TODENSE, you can also use 
the cooA and cscA keywords to specify the input sparse matrix in COO or CSC format. For all other oper-
ations you must use csrA and csrG to specify the input matrices in CSR format.
(2) The output sparse matrix, smOut, is represented in CSR format by waves W_CSRValues, W_CSRCol-
umns, and W_CSRPointerB.
MatrixSparse ADD
ADD computes the sum of sparse matrices A and G which must be in CSR format. Symbolically:
smOut = smA + smG
Inputs: Sparse matrix A and sparse matrix G, both in CSR format.
Output: A sparse matrix in CSR format represented by W_CSRValues, W_CSRColumns, and W_CSRPoint-
erB.
MatrixSparse ADD Example
Function DemoMatrixSparseADD()
// Create smA in CSR format
Make/FREE/D/N=(11) valuesA = {1,25,26,44,16,22,28,5,11,36,42}
Make/FREE/L/N=(11) columnsA = {0,4,4,7,2,3,4,0,1,5,6}
Make/FREE/L/N=(6) ptrBA = {0,2,4,4,7,9}
// Create smG in CSR format
Make/FREE/D/N=(3) valuesG ={1,2,3}
Make/FREE/L/N=(3) columnsG ={0,1,2}
Make/FREE/L/N=(4) ptrBG = {0,1,2,3,3,3,3,3,3}
// Compute smA + smG
MatrixSparse rowsA=6, colsA=8, csrA={valuesA,columnsA,ptrBA}, rowsG=6, 
colsG=8, csrG={valuesG,columnsG,ptrBG}, operation=ADD
WAVE W_CSRValues, W_CSRColumns, W_CSRPointerB
// Outputs from ADD
// Print the 1D waves representing the output CSR sparse matrix
Print W_CSRValues
Print W_CSRColumns
Print W_CSRPointerB
End
MatrixSparse MM
MM computes the product of a sparse matrix and a dense matrix. Symbolically:
M_MMOut = alpha*smA*dmB + beta*dmC
Inputs: alpha, sparse matrix A in CSR format, dense matrix B, and optionally beta and dense matrix C.
If you leave beta with its default value of 0 by omitting the beta keyword, the beta*dmC term is not com-
puted and you do not need to specify the dmC input.
Output: Dense matrix M_MMOut.
beta
Scalar value beta
beta and, for complex input, betai
smOut
Output sparse matrix
N/A (2)
Symbol
Stands For
Specified By Keywords
