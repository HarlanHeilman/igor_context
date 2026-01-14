# MatrixSVD

MatrixSVD
V-584
See Also
Matrix Math Operations on page III-138 for more about Igor’s matrix routines.
MatrixSVD 
MatrixSVD [flags] matrixWave
The MatrixSVD operation uses the singular value decomposition algorithm to decompose an MxN 
matrixWave into a product of three matrices. The default decomposition is into MxM wave M_U, min(M,N) 
wave W_W and NxN wave M_VT.
Flags
/B
Use this flag for backwards compatibility with Igor Pro 3. This option applies 
only to real valued input waves. Note that no other flag can be combined with /B. 
Here the decomposition is such that:
/DACA
Replaces the standard LAPACK algorithm with one that is based on a divide and 
conquer approach. For a typical 1000x1000 matrix this provides a 6x speed 
improvement.
Added in Igor Pro 7.00.
/INVW
Saves the inverse of the elements in W_W. The results are then stored in wave 
W_InvW.
/O
Overwrites matrixWave with the first columns of U. Use this flag to if you need to 
conserve memory. See also related settings of /U and /V.
/PART =nVals
Performs a partial SVD computing only nVals singular values (stored in W_W) 
and the associated vectors in the matrix M_U and M_V. If you use this flag the 
operation ignores all other flags except /PDEL. The partial SVD is computed 
using the Power method of Nash and Shlien.
The /PART flag was added in Igor Pro 7.00.
/PDEL=del
Sets the convergence threshold which defaults to 1e-6. Larger positive values 
result in faster execution but may lead to less accurate results.
The /PDEL flag was added in Igor Pro 7.00.
/U =UMatrixOptions
/V=VMatrixOptions
/Z
No error reporting.
U*W*V^T = matrixWave
U:
MxN column-orthonormal matrix.
W:
NxN diagonal matrix of positive singular values.
V:
NxN orthonormal matrix.
UMatrixOptions can have the following values:
0:
All columns of U are returned in the wave M_U (default).
1:
The first min(m,n) columns of U are returned in the wave M_U.
2:
The first min(m,n) columns of U overwrite matrixWave (/O must be 
specified).
3:
No columns of U are computed.
VMatrixOptions can have the following values:
0:
All rows of V^T are returned in the wave M_VT (default).
1:
The first min(m,n) rows of V^T are returned in the wave M_VT.
2:
The first min(m,n) rows of V^T are overwritten on matrixWave (/O must 
be specified)
3:
No rows of V^T are computed.
