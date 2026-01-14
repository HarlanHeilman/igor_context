// MatrixToMatrix
// interpolates or decimates a 2D matrix by an even multiple
#pragma version=5.0
#pragma igorversion=5.0
#pragma rtGlobals=1		// Use modern global access method.

Macro MatrixToMatrix(inMatrix,outMatrix,factor,mktbl,mkimg)
	String inMatrix,outMatrix="matrix"
	Variable factor=2	// double each dimension, 4 times as many points
	Variable mktbl=2,mkimg=2
	Prompt inMatrix,"Input 2D matrix",popup,WaveList("*",";","DIMS:2")
	Prompt outMatrix,"Output matrix name"
	Prompt factor "Interpolation factor (2 doubles rows and columns, 0.5 halves them)"
	Prompt mktbl,"Put output matrix in new table?",popup,"Yes;No"
	Prompt mkimg,"Display output matrix as image?",popup,"Yes;No"

	Silent 1;PauseUpdate
	if( !WaveExists($inMatrix) || WaveDims($inMatrix) != 2 )
		Abort inMatrix+" is not a two-dimensional wave."
	endif

	Variable x0= DimOffset($inMatrix,0)
	Variable rows= DimSize($inMatrix,0)
	Variable xn= x0 + (rows-1)*DimDelta($inMatrix,0)
	Variable newRows= rows*factor
	Variable dx= (xn-x0) / (newRows-1)
	
	Variable y0= DimOffset($inMatrix,1)
	Variable cols= DimSize($inMatrix,1)
	Variable yn= y0 + (cols-1)*DimDelta($inMatrix,1)
	Variable newCols= cols*factor
	Variable dy= (yn-y0) / (newCols-1)

	ImageInterpolate/S={(x0),(dx),(xn),(y0),(dy),(yn)} bilinear $inMatrix
	Duplicate/O M_InterpolatedImage, $outMatrix
	KillWaves/Z M_InterpolatedImage

	Preferences 1
	if( mktbl == 1)
		Edit $outMatrix
	endif
	if( mkimg == 1)
		NewImage $outMatrix
	endif
EndMacro
