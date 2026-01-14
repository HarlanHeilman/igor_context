# List of MatrixSparse Operations

Chapter III-7 — Analysis
III-154
Make/FREE/D vector = {1, 1, 1, 1}
// Double-precision floating point
// Multiply the sparse matrix by the vector
MatrixSparse rowsA=4, colsA=4, csrA={values,columns,ptrB}, vectorX=vector, 
operation=MV
// Create wave references for output sparse matrix
WAVE W_MV
// Output from MV
Print 
// Prints W_MV[0]= {0,13,3,6}
End
The three Make commands at the start define a sparse matrix in CSR format using free waves. The values 
wave must be single-precision or double-precision floating point, real or complex, without INFs or NaNs. 
The waves containing indices, columns and ptrB in this case, must be 64-bit signed integer.
The next Make statement creates a vector which must have the same data type as the values wave.
The sparse input matrix is defined by the rowsA, colsA, and csrA keywords.
The input vector is specified by the vectorX keyword.
The operation keyword specifies the operation to be performed, MV in this case.
The output in this case is a wave named W_MV created in the current directory. It is a vector with the same 
data type as the values wave.
Different MatrixSparse operations require different inputs and create different outputs.
List of MatrixSparse Operations
Here are the operations supported by MatrixSparse.
Operation
What It Does
ADD
Adds two sparse matrices producing a sparse output matrix. See MatrixSparse ADD 
on page III-157 for details.
MM
Computes the product of a sparse matrix and a dense matrix producing a dense 
output matrix. See MatrixSparse MM on page III-157 for details.
MV
Computes the product of a sparse matrix and a vector producing a sparse output 
matrix. See MatrixSparse MV on page III-158 for details.
SMSM
Computes the product of two sparse matrices producing a sparse output matrix. See 
MatrixSparse SMSM on page III-158 for details.
TOCOO
Produces a sparse output matrix in COO format equivalent to the input matrix which 
may be in dense, CSC, or CSR format. See MatrixSparse TOCOO on page III-159 for 
details.
TOCSC
Produces a sparse output matrix in CSC format equivalent to the input matrix which 
may be in dense, COO, or CSR format. See MatrixSparse TOCSC on page III-159 for 
details.
TOCSR
Produces a sparse output matrix in CSR format equivalent to the input matrix which 
may be in dense, COO, or CSC format. See MatrixSparse TOCSR on page III-160 for 
details.
TODENSE
Produces a dense output matrix equivalent to the sparse input matrix which may be 
in COO, CSC, or CSR format. See MatrixSparse TODENSE on page III-160 for 
details.
TRSV
Solves a system of linear equations for a triangular sparse input matrix. See 
MatrixSparse TRSV on page III-161 for details.
