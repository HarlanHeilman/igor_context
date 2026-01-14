# MatrixMultiplyAdd

MatrixMultiplyAdd
V-549
MatrixMultiply B,C
MatrixMultiply A,M_product
Details
Supports multiplication of complex matrices.
An error is generated if the dimensioning of the input arrays is invalid.
See Also
MatrixOp and MatrixMultiplyAdd for more efficient matrix operations.
Matrix Math Operations on page III-138 for more about Igor’s matrix routines.
FastOp for additional efficient non-matrix operations.
MatrixMultiplyAdd 
MatrixMultiplyAdd [/ZC or /DC] [/A=alpha] [/B=beta] matA[/T], matB[/T] matC
The MatrixMultiplyAdd operation calculates the matrix expression:
matC = alpha*matA x matB + beta*matC
where * indicates scalar multiplication and x indicates matrix multiplication.
MatrixMultiplyAdd uses the LAPACK library for fast computation. It was added in Igor Pro 9.00.
Use /B=0 for just matrix multiply with no addition. In this case, the beta*matC term is not evaluated.
Parameters
matA, matB and matC must be of the same number type and must be single or double precision real or 
complex.
If matA is an NxP matrix then matB must be a PxM matrix and the product is an NxM matrix. If these 
conditions are violated MatrixMultiplyAdd generates an error.
Include the /T flag after matA and/or matB to indicate that the transpose of matA and/or matB should be 
used.
If matC is a NULL wave reference, then a free wave is created and a reference to it is stored in the wave 
reference matC.
Flags
Details
matA and matB must exist but, when running in a user-defined function, matC may or may not exist. If it 
does not exist, MatrixMultiplyAdd creates a free output wave, creates a wave reference named matC, and 
stores a reference to the free output wave in matC.
/A=alpha
alpha is the scalar value multiplied with matA. It defaults to 1.
/B=beta
beta is the scalar value multiplied with matB. It defaults to 1. Use /B=0 to omit the beta*matC 
term.
/DC
Duplicates the wave referenced by matC as a free wave, performs the calculation with the 
duplicate as the destination, and stores a reference to the free wave in matC.
/DC is allowed only when calling MatrixMultiplyAdd from a user-defined function. It is 
an error to use /DC from the command line or in a macro.
/T
Used after matA and/or matB, /T indicates tells MatrixMultiplyAdd to use the transform 
of matA and/or matB in the calculation.
/ZC
Clears the input wave reference matC. This guarantees that matC is NULL which causes 
MatrixMultiplyAdd to create a free output wave and store a reference to it in matC.
When using MatrixMultiplyAdd in a loop, use /ZC to clear the input wave reference to 
ensure that a new free wave is created each time through the loop rather than re-using the 
same output wave.
/ZC is allowed only when calling MatrixMultiplyAdd from a user-defined function. It is 
an error to use /ZC from the command line or in a macro.
