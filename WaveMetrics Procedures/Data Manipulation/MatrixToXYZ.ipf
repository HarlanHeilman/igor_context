#pragma version= 4.05
// MatrixToXYZ
// This procedure file contains two macros to convert a 2-D matrix of Z values
// into three separate X, Y, and Z waves.
//
// MatrixToXYZ converts the entire matrix into X, Y, and Z waves.
// MatrixToXYZRange converts a given XY domain into X, Y, and Z waves.
//
// added 10/7/2001 for Igor 4.05:
// MatrixToXYZTriplet converts the entire matrix of Z values into one XYZ triplet wave.
//

#include <Multi-dimensional Utilities>

// MatrixToXYZ converts a 2-D matrix of Z values into three waves containing X, Y, and Z values
// that spans the min and max X and Y.
// The output waves are named by appending "X", "Y", and "Z" to the given basename.
Macro MatrixToXYZ(mat,base,mktbl,mkgrf)
	String mat,base="wave"
	Variable mktbl=2,mkgrf=2
	Prompt mat,"2D Matrix Wave",popup,WaveList("*",";","DIMS:2")
	Prompt base,"Output wave basename (outputs have X, Y, and Z suffixes)"
	Prompt mktbl,"Put waves in new table?",popup,"Yes;No"
	Prompt mkgrf,"Display waves in new graph?",popup,"Yes;No"

	Silent 1;PauseUpdate
	if( WaveDims($mat) != 2)
		Abort mat+" is not a two-dimensional wave!"
	endif
	
	// Determine full X and Y Ranges
	Variable rows=DimSize($mat,0)
	Variable cols=DimSize($mat,1)
	Variable xmin,ymin,dx,dy
	xmin=DimOffset($mat,0)
	dx=DimDelta($mat,0)
	ymin=DimOffset($mat,1)
	dy=DimDelta($mat,1)
	
	// Make X, Y, and Z waves
	String wx=base+"X"
	String wy=base+"Y"
	String wz=base+"Z"
	Make/O/N=(rows*cols) $wx,$wy,$wz
	$wx= xmin + dx * mod(p,rows)		// X varies quickly
	$wy= ymin + dy * floor(p/rows)	// Y varies slowly
	$wz= $mat($wx[p])($wy[p])
	Preferences 1
	if( mktbl == 1)
		Edit $wx,$wy,$wz
	endif
	if( mkgrf == 1)
		Display $wx,$wy,$wz
	endif
End

// MatrixToXYZRange converts 2-D matrix of Z values into three waves into
// containing X, Y, and Z values that span the given (or auto) X and Y range.
Macro MatrixToXYZRange(mat,base,minx,maxx,miny,maxy,mktbl,mkgrf)
	String mat,base="wave"
	Variable minx=NaN,maxx=NaN,miny=NaN,maxy=NaN
	Variable mktbl=2,mkgrf=2
	Prompt mat,"2D Matrix Wave",popup,WaveList("*",";","DIMS:2")
	Prompt base,"basename for X, Y, Z output waves"
	Prompt minx,"matrix min X, or NaN for auto min X"
	Prompt maxx,"matrix max X, or NaN for auto max X"
	Prompt miny,"matrix min Y, or NaN for auto min Y"
	Prompt maxy,"matrix max  Y, or NaN for auto max Y"
	Prompt mktbl,"Put waves in new table?",popup,"Yes;No"
	Prompt mkgrf,"Display waves in new graph?",popup,"Yes;No"

	Silent 1;PauseUpdate
	if( WaveDims($mat) != 2)
		Abort mat+" is not a two-dimensional wave!"
	endif
	
	// Determine full X and Y Ranges
	Variable rows=DimSize($mat,0)	// rows in entire matrix
	Variable cols=DimSize($mat,1)		// columns in entire matrix
	Variable xmin,xmax,ymin,ymax,dx,dy
	xmin=DimOffset($mat,0)
	dx=DimDelta($mat,0)
	xmax=xmin+dx*(rows-1)
	ymin=DimOffset($mat,1)
	dy=DimDelta($mat,1)
	ymax=ymin+dy*(cols-1)
	
	// Substitute auto values where requested
	if( numtype(minx)!=0 )
		minx= xmin	// use auto min
	endif
	if( numtype(maxx)!=0 )
		maxx= xmax
	endif
	if( numtype(miny)!=0 )
		miny= ymin
	endif
	if( numtype(maxy)!=0 )
		maxy= ymax
	endif
	string range
	// check user's Xs
	sprintf range,"x min=%g, x max=%g",xmin,xmax
	if( limit(minx,xmin,xmax)!=minx)
		Abort "min X isn't between "+range
	endif
	if( limit(maxx,xmin,xmax)!=maxx)
		Abort "max X isn't between "+range
	endif
	// Check Ys
	sprintf range,"y min=%g, y max=%g",ymin,ymax
	if( limit(miny,ymin,ymax)!=miny)
		Abort "min Y isn't between "+range
	endif
	if( limit(maxy,ymin,ymax)!=maxy)
		Abort "max Y isn't between "+range
	endif
	// Determine the equivalent row and column ranges
	Variable firstRow= x2pntMD($mat,0,minx)
	Variable lastRow= x2pntMD($mat,0,maxx)
	Variable firstCol= x2pntMD($mat,1,miny)
	Variable lastCol= x2pntMD($mat,1,maxy)
	Variable xyzrows=lastRow-firstRow+1
	Variable xyzcols=lastCol-firstCol+1
	minx= pnt2xMD($mat,0,firstRow)		// make sure minx corresponds exactly to a matrix row
	miny= pnt2xMD($mat,1,firstCol)		// make sure minyx corresponds exactly to a matrix column
	
	// Make X, Y, and Z waves
	String wx=base+"X"
	String wy=base+"Y"
	String wz=base+"Z"
	Make/O/N=(xyzrows*xyzcols) $wx,$wy,$wz
	$wx= minx + dx * mod(p,xyzrows)		// X varies quickly
	$wy= miny + dy * floor(p/xyzrows)	// Y varies slowly
	$wz= $mat($wx[p])($wy[p])
	Preferences 1
	if( mktbl == 1)
		Edit $wx,$wy,$wz
	endif
	if( mkgrf == 1)
		Display $wx,$wy,$wz
	endif
End

// added 10/7/2001
// MatrixToXYZTriplet converts a 2-D matrix of Z values into one triplet wave
// containing all of the X, Y, and Z values in columns 0, 1, and 2 respectively.
//
Macro MatrixToXYZTriplet(mat,output,mktbl)
	String mat,output="triplet"
	Variable mktbl=2,mkgrf=2
	Prompt mat,"2D Matrix Wave",popup,WaveList("*",";","DIMS:2")
	Prompt output,"Output triplet wave name"
	Prompt mktbl,"Put triplet in new table?",popup,"Yes;No"

	Silent 1;PauseUpdate
	if( WaveDims($mat) != 2)
		Abort mat+" is not a two-dimensional wave!"
	endif

	output= CleanupName(output,1)	// allow liberal names
	if( strlen(output) == 0 )
		Abort "Please enter an name for the output wave"
	endif

	fMatrixToXYZTriplet($mat,output)
	
	Preferences 1
	if( mktbl == 1)
		Edit $output
	endif
End

Function fMatrixToXYZTriplet(matrixWave, outputName)
	Wave matrixWave
	String outputName	
	
	Variable dimx=DimSize(matrixWave,0)
	Variable dimy=DimSize(matrixWave,1)
	Variable rows=dimx*dimy
	Make/O/N=(rows,3) $outputName
	WAVE TripletWave= $outputName
	
	Variable xStart,xDelta
	Variable yStart,yDelta
	
	xStart=DimOffset(matrixWave,0)
	yStart=DimOffset(matrixWave,1)
	xDelta=DimDelta(matrixWave,0)
	yDelta=DimDelta(matrixWave,1)
	
	Variable i,j,count=0
	Variable xVal,yVal
	for(i=0;i<dimy;i+=1)		// i is y (column)
		yVal=yStart+i*yDelta
		for(j=0;j<dimx;j+=1)	// j is x (row)
			xVal=xStart+j*xDelta
			TripletWave[count][0]=xVal
			TripletWave[count][1]=yVal
			TripletWave[count][2]= matrixWave[j][i]	// [row][col]
			count+=1
		endfor
	endfor
End