#pragma rtGlobals=1		// Use modern global access method.

// The following function performs a recursive least squares for estimating a scalar quantity x from N measurements.
// zVector=hVector*x+vVector.  Here zVector contains the measurements, hVector contains various factors for x and vVector
// contains the errors in the individual measurements.
// To get an estimate for x you pass the two vectors to the following function.  If you are not interested in the progression of the
// computation to the final estimate you can uncomment the KillWaves command and the function will clean up after itself.  The 
// function is based on: "Handbook of Digital Signal Processing Engineering Applications",  ed. D.F. Elliott, AP NY 1987. pp. 900-
// 905.
// For example:
// make/n=3 zvector,hvector
// zvector={3,0,-2}
// hvector={2,-1,-2}
// print doScalarLeastSquaresEstimation(zvector,hvector)
//  1.11111
// Note: if you are trying to estimate a vector x (not a scalar), then use the built-in operation MatrixLLS.
// 16JUL03 AG

Function doScalarLeastSquaresEstimation(zVector,hVector)
	Wave zVector,hVector
	
	// check dimensionality:
	Variable numRows=DimSize(zVector,0)
	if(DimSize(hVector,0)!=numRows || DimSize(hVector,1)!=0 || DimSize(zVector,1)!=0)
		Abort "Incorrect input dimensionality."
		return 0
	endif
	
	// create the output wave.
	Make/O/N=(numRows) W_LSEstimates=0
	
	Variable curP,curK
	Variable nextP,nextK,nextC
	
	Variable i
	
	curP=1/(hVector[0]*hVector[0])
	W_LSEstimates[0]=curP*hVector[0]*zVector[0]
	
	for(i=1;i<numRows;i+=1)
		nextC=1./(hVector[i]*curP*hVector[i]+1)
		nextK=curP*hVector[i]*nextC
		nextP=(1-nextK*hVector[i])*curP
		W_LSEstimates[i]=W_LSEstimates[i-1]+nextK*(zVector[i]-hVector[i]*W_LSEstimates[i-1])
		
		curP=nextP
		curK=nextK
	endfor
	
	// KillWaves/Z W_LSEstimates
	return W_LSEstimates[i]
End
