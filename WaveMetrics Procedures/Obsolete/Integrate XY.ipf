// IntegrateXYPro(xWave, yWave, yDestWaveName)
//	Produces trapezoidal integration of XY pair, new wave yDestWaveName contains integration.
//	The XY pair is assumed to be sorted.
//	You can sort with: Sort xWave, xWave, yWave
//	Works only with Igor Pro
Function IntegrateXYPro(xWave, yWave, yDestWaveName)
	Wave/D xWave, yWave						// input X, Y waves
	String yDestWaveName						// name to use for output wave
	
	Duplicate/O/D yWave, $yDestWaveName
	
	Wave/D yDest = $yDestWaveName
	yDest[0]=0
	yDest[1,]= yDest[p-1] + 0.5*(yWave[p] + yWave[p-1]) * (xWave[p] - xWave[p-1])
End

// IntegrateXY(xWave, yWave)
//	Produces trapezoidal integration of XY pair, replacing contents of yWave
//	The XY pair is assumed to be sorted.
//	You can sort with: Sort xWave, xWave, yWave
//	Works with Igor Pro or Igor 1.2
Function IntegrateXY(xWave, yWave)
	Wave/D xWave, yWave						// input/output X, Y waves
	
	Variable/D yp,ypm1,sum=0
	Variable pt=1,n=numpnts(yWave)
	ypm1=yWave[0]
	yWave[0]= 0
	do
		yp= yWave[pt]
		sum +=  0.5*(yp + ypm1) * (xWave[pt] - xWave[pt-1])
		yWave[pt]= sum
		ypm1= yp
		pt+=1
	while( pt<n )
End
