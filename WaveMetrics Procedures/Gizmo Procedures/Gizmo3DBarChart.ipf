#pragma rtGlobals=1		// Use modern global access method.

// 09APR03
// The following function takes a 2D matrix wave corresponding the the height of bars
// and creates a 3D parametric wave for Gizmo.  minValue is the value at which the lower
// plane is set and should have some reasonable relationship to the distribution of bar heights.
Function WM_Make3DBarChartParametricWave(inWave,minValue)
	wave inWave
	Variable minValue
	
	Variable rows=DimSize(inWave,0)
	Variable cols=DimSize(inWave,1)
	Variable newRows=4*rows+2
	Variable newCols=4*cols+2
	
	Make/O/N=(newRows,newCols,3) 	fakeWave=minValue
	
	Variable i,j,xVal,yVal
		
	// first load the x and y  planes
	fakeWave[][][0]=p<1 ? 0 : trunc((p-1)/2)+1
	fakeWave[][][1]=q<1 ? 0 : trunc((q-1)/2)+1
	

	xVal=0
	for(i=2;i<newRows;i+=4)
		yVal=0
		for(j=2;j<newCols;j+=4)
			fakeWave[i][j][2]=inWave[xVal][yVal]
			fakeWave[i][j+1][2]=inWave[xVal][yVal]
			yVal+=1
		endfor
		yVal=0
		for(j=2;j<newCols;j+=4)
			fakeWave[i+1][j][2]=inWave[xVal][yVal]
			fakeWave[i+1][j+1][2]=inWave[xVal][yVal]
			yVal+=1
		endfor
		xVal+=1
	endfor
End
	