# MatrixReverseBalance

MatrixRank
V-578
See Also
Using MatrixOp on page III-140
Matrix Math Operations on page III-138 for more about Igor’s matrix routines
FastOp
MatrixRank 
matrixRank(matrixWaveA [, conditionNumberA])
The matrixRank function returns the rank of matrixWaveA subject to the specified condition number.
The matrix is not considered to have full rank if its condition number exceeds the specified 
conditionNumberA.
If the optional parameter conditionNumberA is not specified, Igor Pro uses the value 1020.
matrixRank supports real and complex single precision and double precision numeric wave data types.
The value of conditionNumberA should be large enough but taking into account the accuracy of the 
numerical representation given the numeric data type.
If there are any errors the function returns NaN.
See Also
Matrix Math Operations on page III-138 for more about Igor’s matrix routines.
MatrixReverseBalance
MatrixReverseBalance [flags] scaleWave, eigenvectorsWave
MatrixReverseBalance inverse-transforms left or right eigenvectors contained in eigenvectorsWave that were 
computed for a matrix that was balanced using MatrixBalance. The results are the eigenvectors of the pre-
balanced matrix. scaleWave is W_scale as returned by MatrixReverseBalance.
MatrixBalance was added in Igor Pro 9.00.
Parameters
eigenvectorsWave must be single-precision or double-precision floating point, real or complex, and must 
contain no NaNs. MatrixReverseBalance returns an error if these conditions are not met.
Flags
/DSTM=dest
Specifies the destination wave for the inverse-transformed eigenvectors. If you omit 
/DSTM, the output is saved in M_RBEigenvectors in the current data folder.
/FREE
Create free destination wave when it is specified via /DSTM.
/J=job
You should use the same value for job as was used in the original balancing.
/LH={low,high}
Specifies the zero-based low and high indices that were returned by MatrixBalance in 
V_min and V_max respectively.
/Z
Suppresses error reporting. If you use /Z, check the V_Flag output variable to see if 
the operation succeeded.
job is the type of backward transformation required. It is one of the following 
letters:
N
srcWave is not permuted or scaled.
P
srcWave is permuted but not scaled.
S
srcWave is scaled but not permuted. The scaling applies a diagonal 
similarity transformation to make the norms of the various columns 
close to each other.
B
srcWave is both scaled and permuted (default).
