# MatrixFactor

MatrixFactor
V-538
MatrixFactor
MatrixFactor [ flags ] srcWave
The MatrixFactor operation computes two real-valued output matrices, conceptually called matA and 
matB, whose matrix product minimizes the Frobenius norm of:
| srcWave - (matA x matB) |
The MatrixFactor operation was added in Igor Pro 9.00.
Flags
Details
srcWave must be a single or double precision real wave.
If you specify the factorization output waves using /DSTA and /DSTB, they must have the same numeric 
type.
If you omit /DSTA or /DSTB, MatrixFactor produces output waves named factorAMat and factorBMat with 
the same numeric type as srcWave.
The algorithm produces a non-unique solution that may depend on the initialization of the two factors. The 
default initialization, used if you omit /INIA and /INIB, uses Igor's random number generator. If you want 
to investigate convergence you can generate your own initial values and specify them using the /INIA and 
/INIB flags. If you want to provide your own initial values you must provide them for both matA and matB 
via both /INIA and /INIB. You can run MatrixFactor once and use the outputs as initial values for a second 
run.
We recommend using double precision waves because the algorithm involves iterations where the 
Frobenius norm is computed. For large matrices or for a large number of iterations the calculation is 
strongly susceptible to roundoff errors which may cause it to fail to converge.
/COMC=cCols
Sets the common dimension in the factorization so that, for srcWave with m rows and 
n columns, the factorization will be (m x cCols) matA and (cCols x n) matB. If you omit 
/COMC, cCols defaults to m/2.
/CORR=cRate
Sets the correction factor for the learning rate. The default value is 0.9.
/DSTA=wA
Specifies the output wave representing matA.
/DSTB=wB
Specifies the output wave representing matB.
/FREE
Creates output waves as free waves.
/INIA=iwA
Specifies an initial solution matrix for matA. The wave must have the same 
dimensions as matA and the same numeric type as srcWave.
/INIB=iwB
Specifies an initial solution matrix for matB. The wave must have the same 
dimensions as matB and the same numeric type as srcWave.
/ITER=nIters
Sets the maximum number of iterations. By default nIters is 1E7.
/LRNR=lRate
Sets the initial learning rate of the algorithm. The default value of lRate is 0.01.
/OUT=type
Sets restrictions on the output. The default value for type is 0 and there are no 
restrictions on the elements of the output. Set type=1 for non-negative output elements 
or type=2 for positive output elements.
/TOL=tolerance
Use /TOL to terminate iterations when the average Frobenius norm per input point 
falls below the tolerance value. By default tolerance is 1E-9 for single precision floating 
point input wave and 1E-15 for double precision input.
/Q
Quiet - do not print diagnostic information to the history area and do not display 
progress bar.
/Z
Errors are not fatal and do not abort procedure execution. Your procedure can inspect 
the V_flag variable to see if the operation succeeded. V_flag will be zero if it 
succeeded or nonzero if it failed.
