# MatrixSparse TOCSC

Chapter III-7 — Analysis
III-159
Output: A sparse matrix in CSR format represented by W_CSRValues, W_CSRColumns, and W_CSRPoint-
erB.
MatrixSparse SMSM Example
Function DemoMatrixSparseSMSM()
// Create sparse matrix A in CSR format
Make/FREE/D/N=(11) valuesA = {1,25,26,44,16,22,28,5,11,36,42}
Make/FREE/L/N=(11) columnsA = {0,4,4,7,2,3,4,0,1,5,6}
Make/FREE/L/N=(6) ptrBA = {0,2,4,4,7,9}
// Create sparse matrix G in CSR format
Make/FREE/D/N=(8) valuesG = {1,10,26,6,14,38,15,23}
Make/FREE/L/N=(8) columnsG = {0,1,3,0,1,4,1,2}
Make/FREE/L/N=(8) ptrBG = {0,1,3,3,3,3,6,8}
// Compute product MatrixA x MatrixG
MatrixSparse rowsA=6, colsA=8, csrA={valuesA,columnsA,ptrBA}, rowsG=8, 
colsG=5, csrG={valuesG,columnsG,ptrBG}, operation=SMSM
WAVE W_CSRValues, W_CSRColumns, W_CSRPointerB
// Outputs from SMSM
// Print the 1D waves representing the output CSR sparse matrix
Print W_CSRValues
Print W_CSRColumns
Print W_CSRPointerB
End
MatrixSparse TOCOO
TOCOO produces a sparse output matrix in COO format equivalent to the input matrix which may be in 
dense, CSC, or CSR format.
Inputs: A dense matrix specified by the matrixB keyword or a sparse matrix specified by the cscA or csrA 
keywords.
Output: A sparse matrix in COO format represented by W_COOValues, W_COORows, and W_COOCol-
umns.
MatrixSparse TOCOO Example
Function DemoMatrixSparseTOCOO()
// Create the Wikipedia example 4x4 matrix in CSR format
Make/FREE/D values = {5, 8, 3, 6}
Make/FREE/L columns = {0, 1, 2, 1}
Make/FREE/L ptrB = {0, 0, 2, 3, 4}
// Create a sparse matrix in COO format from the CSR matrix
MatrixSparse rowsA=4, colsA=4, csrA={values,columns,ptrB}, operation=TOCOO
WAVE W_COOValues, W_COORows, W_COOColumns
// Outputs from TOCOO
// Print the 1D waves representing the COO sparse matrix
Print W_COOValues
Print W_COORows
Print W_COOColumns
End
MatrixSparse TOCSC
TOCSC produces a sparse output matrix in CSC format equivalent to the input matrix which may be in 
dense, COO, or CSR format.
Inputs: A dense matrix specified by the matrixB keyword or a sparse matrix specified by the cooA or csrA 
keywords.
