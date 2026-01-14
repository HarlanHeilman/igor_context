#pragma rtGlobals=1
#pragma version=6.38		// shipped with Igor 6.38
#pragma igorversion=6.2	// for ImageInterpolate/PFTL

// XYZtoMatrix
//
// The XYZtoMatrix procedure file contains 4 macros to convert X, Y, and Z values
// into a 2-D matrix of Z values:
//
// NOTE: All of these routines work with waves in only the current data folder.
//
// XYZtoMatrix() interpolates three waves containing X, Y, and Z values
// into a matrix of Z values that spans the min and max X and Y.
//
// XYGridandZtoMatrix() rearranges three waves containing X, Y, and Z values
// that comprise a regularly-spaced grid of X and Y values
// (already sorted in either column-major or row-major order)
// into a matrix of Z values that spans the min and max X and Y.
//
// XYZtoMatrixRange() interpolates three waves containing X, Y, and Z values
// into a matrix of Z values over a specified X and Y range.
//
// XYZTripletToMatrix() interpolates an XYZ triplet wave into a matrix.
//
// Version 5.02: fixed x and y range bugs in XYZTripletToMatrix().
// Version 6.02: Added XYGridandZtoMatrix().
// Version 6.2: Fixed XYGridandZtoMatrix() for descending X and Y values, added /PFTL=1e-5 to ImageInterpolate
// Version 6.38: Fixed error that produced matrix with one too few rows and columns.
//				Added menu definition, which calls more rationally-organized XYZtoMatrixEx.
//				Added point-finding tolerance and missing Z value parameters to new XYZTripletToMatrixEx.
//				Added input parameter memories.
//				XYZToTripletToXYZ menus aren't enabled.

#include <XYZToTripletToXYZ>, menus=0

Menu "Macros"	// the traditional location
	"XYZ Waves to Matrix", XYZtoMatrixEx()
	"XYZ to Matrix Range", XYZtoMatrixRange()
	"XYZ Triplet to Matrix", XYZTripletToMatrixEx()
	"XY Grid and Z to Matrix", XYGridandZtoMatrix()
End

//
// XYZtoMatrix interpolates
// three waves containing X, Y, and Z values
// into a matrix of Z values that spans the min and max X and Y.
//
// This missing parameter dialog is more rationally organized than XYZtoMatrix
Macro XYZtoMatrixEx(wx,rows,wy,cols,wz,mat,outerValue,pftl,mktbl,mkimg)
	String wx= StrVarOrDefault("root:Packages:WMXYZtoMatrix:XYZToMatrixEx:wx", "")
	String wy= StrVarOrDefault("root:Packages:WMXYZtoMatrix:XYZToMatrixEx:wy", "")
	String wz= StrVarOrDefault("root:Packages:WMXYZtoMatrix:XYZToMatrixEx:wz", "")
	String mat= StrVarOrDefault("root:Packages:WMXYZtoMatrix:XYZToMatrixEx:mat", "matrix")
	Variable rows=NumVarOrDefault("root:Packages:WMXYZtoMatrix:XYZToMatrixEx:rows", 20)
	Variable cols=NumVarOrDefault("root:Packages:WMXYZtoMatrix:XYZToMatrixEx:cols", 20)
	Variable mktbl=NumVarOrDefault("root:Packages:WMXYZtoMatrix:XYZToMatrixEx:mktbl", 2)
	Variable mkimg=NumVarOrDefault("root:Packages:WMXYZtoMatrix:XYZToMatrixEx:mkimg", 2)
	Variable outerValue=NumVarOrDefault("root:Packages:WMXYZtoMatrix:XYZToMatrixEx:outerValue", NaN)// holes
	Variable pftl=NumVarOrDefault("root:Packages:WMXYZtoMatrix:XYZToMatrixEx:pftl", 1e-5)// overcome perturbation
	Prompt wx,"X Wave",popup,WaveList("*",";","DIMS:1")
	Prompt rows,"number of rows (X) for matrix"
	Prompt wy,"Y Wave",popup,WaveList("*",";","DIMS:1")
	Prompt cols,"number of columns (Y) for matrix"
	Prompt wz,"Z Wave",popup,WaveList("*",";","DIMS:1")
	Prompt mat,"Output matrix name"
	Prompt outerValue,"Z value outside XY domain"
	Prompt pftl,"Point-finding tolerance"
	Prompt mktbl,"Put matrix in new table?",popup,"Yes;No"
	Prompt mkimg,"Display matrix as image?",popup,"Yes;No"

	Silent 1;PauseUpdate
	
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:WMXYZtoMatrix
	NewDataFolder/O root:Packages:WMXYZtoMatrix:XYZToMatrixEx
	String/G root:Packages:WMXYZtoMatrix:XYZToMatrixEx:wx = wx
	String/G root:Packages:WMXYZtoMatrix:XYZToMatrixEx:wy = wy
	String/G root:Packages:WMXYZtoMatrix:XYZToMatrixEx:wz = wz
	String/G root:Packages:WMXYZtoMatrix:XYZToMatrixEx:mat = mat
	
	Variable/G root:Packages:WMXYZtoMatrix:XYZToMatrixEx:rows= rows
	Variable/G root:Packages:WMXYZtoMatrix:XYZToMatrixEx:cols= cols
	Variable/G root:Packages:WMXYZtoMatrix:XYZToMatrixEx:mktbl= mktbl
	Variable/G root:Packages:WMXYZtoMatrix:XYZToMatrixEx:mkimg= mkimg
	Variable/G root:Packages:WMXYZtoMatrix:XYZToMatrixEx:outerValue= outerValue
	Variable/G root:Packages:WMXYZtoMatrix:XYZToMatrixEx:pftl=pftl

	if( !WaveExists($wx) || WaveDims($wx) != 1)
		Abort wx+" is not a one-dimensional wave!"
	endif
	if( !WaveExists($wy) || WaveDims($wy) != 1)
		Abort wy+" is not a one-dimensional wave!"
	endif
	if( !WaveExists($wz) || WaveDims($wz) != 1)
		Abort wz+" is not a one-dimensional wave!"
	endif

 	// ImageInterpolate requires triplet wave
 	String tripletName="tempTriplet"
 	WMXYZToXYZTriplet($wx,$wy,$wz, tripletName)

	XYZTripletToMatrixEx(tripletName,mat,rows,cols,NaN,NaN,NaN,NaN,outerValue,pftl)

	KillWaves/Z $tripletName
	
	Preferences 1
	if( mktbl == 1)
		Edit $mat
	endif
	if( mkimg == 1)
		NewImage $mat
	endif
End

// Legacy interface
Proc XYZtoMatrix(wx,mat,wy,rows,wz,cols,mktbl,mkimg)
	String wx,wy,wz,mat="matrix"
	Variable rows=20,cols=20,mktbl=2,mkimg=2
	Prompt wx,"X Wave",popup,WaveList("*",";","DIMS:1")
	Prompt mat,"Output matrix name"
	Prompt wy,"Y Wave",popup,WaveList("*",";","DIMS:1")
	Prompt rows,"number of rows (X) for matrix"
	Prompt wz,"Z Wave",popup,WaveList("*",";","DIMS:1")
	Prompt cols,"number of columns (Y) for matrix"
	Prompt mktbl,"Put matrix in new table?",popup,"Yes;No"
	Prompt mkimg,"Display matrix as image?",popup,"Yes;No"

	Silent 1;PauseUpdate

	if( !WaveExists($wx) || WaveDims($wx) != 1)
		Abort wx+" is not a one-dimensional wave!"
	endif
	if( !WaveExists($wy) || WaveDims($wy) != 1)
		Abort wy+" is not a one-dimensional wave!"
	endif
	if( !WaveExists($wz) || WaveDims($wz) != 1)
		Abort wz+" is not a one-dimensional wave!"
	endif

 	// ImageInterpolate requires triplet wave
 	String tripletName="tempTriplet"
 	WMXYZToXYZTriplet($wx,$wy,$wz, tripletName)

	XYZTripletToMatrix(tripletName,mat,rows,cols,NaN,NaN,NaN,NaN,mktbl,mkimg)

	KillWaves/Z $tripletName
End

//
// XYZtoMatrixRange interpolates
// three waves containing X, Y, and Z values
// into a matrix of Z values that spans the given (or auto) X and Y range
//
Macro XYZtoMatrixRange(wx,mat,wy,rows,wz,cols,xmin,xmax,ymin,ymax)
	String wx= StrVarOrDefault("root:Packages:WMXYZtoMatrix:XYZtoMatrixRange:wx", "")
	String wy= StrVarOrDefault("root:Packages:WMXYZtoMatrix:XYZtoMatrixRange:wy", "")
	String wz= StrVarOrDefault("root:Packages:WMXYZtoMatrix:XYZtoMatrixRange:wz", "")
	String mat= StrVarOrDefault("root:Packages:WMXYZtoMatrix:XYZtoMatrixRange:mat", "matrix")
	Variable rows=NumVarOrDefault("root:Packages:WMXYZtoMatrix:XYZtoMatrixRange:rows", 20)
	Variable cols=NumVarOrDefault("root:Packages:WMXYZtoMatrix:XYZtoMatrixRange:cols", 20)
	Variable xmin=NumVarOrDefault("root:Packages:WMXYZtoMatrix:XYZtoMatrixRange:xmin", NaN)
	Variable xmax=NumVarOrDefault("root:Packages:WMXYZtoMatrix:XYZtoMatrixRange:xmax", NaN)
	Variable ymin=NumVarOrDefault("root:Packages:WMXYZtoMatrix:XYZtoMatrixRange:ymin", NaN)
	Variable ymax=NumVarOrDefault("root:Packages:WMXYZtoMatrix:XYZtoMatrixRange:ymax", NaN)
	Prompt wx,"X Wave",popup,WaveList("*",";","DIMS:1")
	Prompt mat,"Output matrix name"
	Prompt wy,"Y Wave",popup,WaveList("*",";","DIMS:1")
	Prompt rows,"number of rows for matrix"
	Prompt wz,"Z Wave",popup,WaveList("*",";","DIMS:1")
	Prompt cols,"number of columns for matrix"
	Prompt xmin,"matrix min X, or NaN for auto min X"
	Prompt xmax,"matrix max X, or NaN for auto max X"
	Prompt ymin,"matrix min Y, or NaN for auto min Y"
	Prompt ymax,"matrix max  Y, or NaN for auto max Y"

	Silent 1;PauseUpdate
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:WMXYZtoMatrix
	NewDataFolder/O root:Packages:WMXYZtoMatrix:XYZtoMatrixRange
	String/G root:Packages:WMXYZtoMatrix:XYZtoMatrixRange:wx = wx
	String/G root:Packages:WMXYZtoMatrix:XYZtoMatrixRange:wy = wy
	String/G root:Packages:WMXYZtoMatrix:XYZtoMatrixRange:wz = wz
	String/G root:Packages:WMXYZtoMatrix:XYZtoMatrixRange:matrix = matrix
	Variable/G root:Packages:WMXYZtoMatrix:XYZtoMatrixRange:rows = rows
	Variable/G root:Packages:WMXYZtoMatrix:XYZtoMatrixRange:cols = cols
	Variable/G root:Packages:WMXYZtoMatrix:XYZtoMatrixRange:xmin = xmin
	Variable/G root:Packages:WMXYZtoMatrix:XYZtoMatrixRange:xmax = xmax
	Variable/G root:Packages:WMXYZtoMatrix:XYZtoMatrixRange:cols = cols
	Variable/G root:Packages:WMXYZtoMatrix:XYZtoMatrixRange:ymin = ymin
	Variable/G root:Packages:WMXYZtoMatrix:XYZtoMatrixRange:ymax = ymax

	if( !WaveExists($wx) || WaveDims($wx) != 1)
		Abort wx+" is not a one-dimensional wave!"
	endif
	if( !WaveExists($wy) || WaveDims($wy) != 1)
		Abort wy+" is not a one-dimensional wave!"
	endif
	if( !WaveExists($wz) || WaveDims($wz) != 1)
		Abort wz+" is not a one-dimensional wave!"
	endif

 	// ImageInterpolate requires triplet wave
 	String tripletName="tempTriplet"
 	WMXYZToXYZTriplet($wx,$wy,$wz, tripletName)

	XYZTripletToMatrix(tripletName,mat,rows,cols,xmin,xmax,ymin,ymax,2,2)

	KillWaves/Z $tripletName
End


//
// XYZTripletToMatrixEx interpolates
// one triplet wave containing all of the X, Y, and Z values in columns 0, 1, and 2 respectively
// into a matrix that spans the given x and y ranges.
// Specify NaN to use the corresponding min or max range value.
//
Macro XYZTripletToMatrixEx(wtriplet,mat,rows,cols,xmin,xmax,ymin,ymax,outerValue,pftl)
	String wtriplet= StrVarOrDefault("root:Packages:WMXYZtoMatrix:XYZTripletToMatrixEx:wtriplet", "")
	String mat= StrVarOrDefault("root:Packages:WMXYZtoMatrix:XYZTripletToMatrixEx:mat", "matrix")
	Variable rows=NumVarOrDefault("root:Packages:WMXYZtoMatrix:XYZTripletToMatrixEx:rows", 20)
	Variable cols=NumVarOrDefault("root:Packages:WMXYZtoMatrix:XYZTripletToMatrixEx:cols", 20)
	Variable xmin=NumVarOrDefault("root:Packages:WMXYZtoMatrix:XYZTripletToMatrixEx:xmin", NaN)
	Variable xmax=NumVarOrDefault("root:Packages:WMXYZtoMatrix:XYZTripletToMatrixEx:xmax", NaN)
	Variable ymin=NumVarOrDefault("root:Packages:WMXYZtoMatrix:XYZTripletToMatrixEx:ymin", NaN)
	Variable ymax=NumVarOrDefault("root:Packages:WMXYZtoMatrix:XYZTripletToMatrixEx:ymax", NaN)
	Variable outerValue=NumVarOrDefault("root:Packages:WMXYZtoMatrix:XYZTripletToMatrixEx:outerValue", NaN)// holes
	Variable pftl=NumVarOrDefault("root:Packages:WMXYZtoMatrix:XYZTripletToMatrixEx:pftl", 1e-5)// overcome perturbation
	Prompt wtriplet,"3-column XYZ wave",popup,WaveList("*",";","DIMS:2,MINCOLS:3,MAXCOLS:30")
	Prompt mat,"Output matrix name"
	Prompt rows,"number of rows (X) for matrix"
	Prompt cols,"number of columns (Y) for matrix"
	Prompt xmin,"matrix min X, or NaN for auto min X"
	Prompt xmax,"matrix max X, or NaN for auto max X"
	Prompt ymin,"matrix min Y, or NaN for auto min Y"
	Prompt ymax,"matrix max Y, or NaN for auto max Y"
	Prompt outerValue,"Z value outside XY domain"
	Prompt pftl,"Point-finding tolerance"

	Silent 1;PauseUpdate
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:WMXYZtoMatrix
	NewDataFolder/O root:Packages:WMXYZtoMatrix:XYZTripletToMatrixEx
	String/G root:Packages:WMXYZtoMatrix:XYZTripletToMatrixEx:wtriplet = wtriplet
	String/G root:Packages:WMXYZtoMatrix:XYZTripletToMatrixEx:matrix = matrix
	Variable/G root:Packages:WMXYZtoMatrix:XYZTripletToMatrixEx:rows = rows
	Variable/G root:Packages:WMXYZtoMatrix:XYZTripletToMatrixEx:cols = cols
	Variable/G root:Packages:WMXYZtoMatrix:XYZTripletToMatrixEx:xmin = xmin
	Variable/G root:Packages:WMXYZtoMatrix:XYZTripletToMatrixEx:xmax = xmax
	Variable/G root:Packages:WMXYZtoMatrix:XYZTripletToMatrixEx:ymin = ymin
	Variable/G root:Packages:WMXYZtoMatrix:XYZTripletToMatrixEx:ymax = ymax
	Variable/G root:Packages:WMXYZtoMatrix:XYZTripletToMatrixEx:outerValue = outerValue
	Variable/G root:Packages:WMXYZtoMatrix:XYZTripletToMatrixEx:pftl = pftl

	if( !WaveExists($wtriplet) || WaveDims($wtriplet) != 2 || DimSize($wtriplet,1) < 3)
		Abort wtriplet+" is not a triplet wave!"
	endif

	// determine the X and Y bounds of the triplet data
	Variable tripletRows= DimSize($wtriplet,0)
	ImageStats/M=1/G={0, tripletRows-1, 0,0} $wtriplet
	if(numtype(xmin)!=0)
		xmin=  V_min
	endif
	if(numtype(xmax)!=0)
		xmax= V_max
	endif
	ImageStats/M=1/G={0, tripletRows-1, 1,1} $wtriplet
	if(numtype(ymin)!=0)
		ymin= V_min
	endif
	if(numtype(ymax)!=0)
		ymax= V_max
	endif

	Variable dx= (xmax-xmin) / (rows-1)
	if( dx <= 0 )
		Abort "max X must be greater than min X!"
	endif
	xmax += dx + dx/2	// version 6.38: ImageInterpolate computes nXPoints=floor(abs(xmax-xmin)/dx)

	Variable dy= (ymax-ymin) / (cols-1)
	if( dy <= 0 )
		Abort "max Y must be greater than min Y!"
	endif
	ymax += dy + dy/2
	
	ImageInterpolate/DEST=$mat/PFTL=(pftl)/E=(outerValue)/S={(xmin),(dx),(xmax),(ymin),(dy),(ymax)} Voronoi, $wtriplet

End

// Legacy interface
Proc XYZTripletToMatrix(wtriplet,mat,rows,cols,xmin,xmax,ymin,ymax,mktbl,mkimg)
	String wtriplet, mat="matrix"
	Variable rows=20,cols=20,xmin=NaN,xmax=NaN,ymin=NaN,ymax=NaN
	Variable mktbl=2,mkimg=2
	Prompt wtriplet,"3-column XYZ wave",popup,WaveList("*",";","DIMS:2,MINCOLS:3,MAXCOLS:30")
	Prompt mat,"Output matrix name"
	Prompt rows,"number of rows (X) for matrix"
	Prompt cols,"number of columns (Y) for matrix"
	Prompt xmin,"matrix min X, or NaN for auto min X"
	Prompt xmax,"matrix max X, or NaN for auto max X"
	Prompt ymin,"matrix min Y, or NaN for auto min Y"
	Prompt ymax,"matrix max Y, or NaN for auto max Y"
	Prompt mktbl,"Put matrix in new table?",popup,"Yes;No"
	Prompt mkimg,"Display matrix as image?",popup,"Yes;No"

	if( !WaveExists($wtriplet) || WaveDims($wtriplet) != 2 || DimSize($wtriplet,1) < 3)
		Abort wtriplet+" is not a triplet wave!"
	endif

	// determine the X and Y bounds of the triplet data
	Variable tripletRows= DimSize($wtriplet,0)
	ImageStats/M=1/G={0, tripletRows-1, 0,0} $wtriplet
	if(numtype(xmin)!=0)
		xmin=  V_min
	endif
	if(numtype(xmax)!=0)
		xmax= V_max
	endif
	ImageStats/M=1/G={0, tripletRows-1, 1,1} $wtriplet
	if(numtype(ymin)!=0)
		ymin= V_min
	endif
	if(numtype(ymax)!=0)
		ymax= V_max
	endif

	Variable dx= (xmax-xmin) / (rows-1)
	if( dx <= 0 )
		Abort "max X must be greater than min X!"
	endif
//	xmax += dx + dx/2	// version 6.38: ImageInterpolate computes nXPoints=floor(abs(xmax-xmin)/dx)

	Variable dy= (ymax-ymin) / (cols-1)
	if( dy <= 0 )
		Abort "max Y must be greater than min Y!"
	endif
//	ymax += dy + dy/2

	Variable pftl=1e-5			// overcome perturbation
	Variable outerValue= NaN	// holes
	ImageInterpolate/DEST=$mat/PFTL=(pftl)/E=(outerValue)/S={(xmin),(dx),(xmax),(ymin),(dy),(ymax)} Voronoi, $wtriplet

	Preferences 1
	if( mktbl == 1)
		Edit $mat
	endif
	if( mkimg == 1)
		NewImage $mat
	endif
End

//
// XYGridandZtoMatrix rearranges three waves containing X, Y, and Z values
// that comprise a regularly-spaced grid of X and Y values
// (already sorted in either column-major or row-major order)
// into a matrix of Z values that spans the min and max X and Y.
Macro XYGridandZtoMatrix(wx,mat,wy,mktbl,wz,mkimg)
	String wx= StrVarOrDefault("root:Packages:WMXYZtoMatrix:XYGridandZtoMatrix:wx", "")
	String wy= StrVarOrDefault("root:Packages:WMXYZtoMatrix:XYGridandZtoMatrix:wy", "")
	String wz= StrVarOrDefault("root:Packages:WMXYZtoMatrix:XYGridandZtoMatrix:wz", "")
	String mat= StrVarOrDefault("root:Packages:WMXYZtoMatrix:XYGridandZtoMatrix:mat", "matrix")
	Variable mktbl=NumVarOrDefault("root:Packages:WMXYZtoMatrix:XYGridandZtoMatrix:mktbl", 2)
	Variable mkimg=NumVarOrDefault("root:Packages:WMXYZtoMatrix:XYGridandZtoMatrix:mkimg", 2)
	Prompt wx,"X Wave",popup,WaveList("*",";","DIMS:1")
	Prompt mat,"Output matrix name"
	Prompt wy,"Y Wave",popup,WaveList("*",";","DIMS:1")
	Prompt wz,"Z Wave",popup,WaveList("*",";","DIMS:1")
	Prompt mktbl,"Put matrix in new table?",popup,"Yes;No"
	Prompt mkimg,"Display matrix as image?",popup,"Yes;No"

	Silent 1;PauseUpdate

	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:WMXYZtoMatrix
	NewDataFolder/O root:Packages:WMXYZtoMatrix:XYGridandZtoMatrix
	String/G root:Packages:WMXYZtoMatrix:XYGridandZtoMatrix:wx = wx
	String/G root:Packages:WMXYZtoMatrix:XYGridandZtoMatrix:wy = wy
	String/G root:Packages:WMXYZtoMatrix:XYGridandZtoMatrix:wz = wz
	String/G root:Packages:WMXYZtoMatrix:XYGridandZtoMatrix:mat = mat
	Variable/G root:Packages:WMXYZtoMatrix:XYGridandZtoMatrix:mktbl = mktbl
	Variable/G root:Packages:WMXYZtoMatrix:XYGridandZtoMatrix:mkimg = mkimg

	if( !WaveExists($wx) || WaveDims($wx) != 1)
		Abort wx+" is not a one-dimensional wave!"
	endif
	if( !WaveExists($wy) || WaveDims($wy) != 1)
		Abort wy+" is not a one-dimensional wave!"
	endif
	if( !WaveExists($wz) || WaveDims($wz) != 1)
		Abort wz+" is not a one-dimensional wave!"
	endif

	// Determine if x values vary most rapidly, or if y values vary most rapidly
	Variable yCols, xRows, xVariesMostRapidly
	Variable pnts= numpnts($wx)	// must be same for all waves
	WaveStats/Q $wx
	Variable delta=(V_max-V_min) / pnts
	if( abs($wx[0] - $wx[1] ) < delta )	// 	If adjacent X values differ by less than a linear increment from min to max, they're "constant".
		xVariesMostRapidly= 0			// the x values are all one value for a while, then switch to the next x value on the grid.
		yCols= WMRunLessThanDelta($wx,delta)
		xRows= pnts / yCols
	else
		xVariesMostRapidly= 1			// presumably the x values increment while the y's are all one value for a while.
		WaveStats/Q $wy
		delta=(V_max-V_min) / pnts
		xRows= WMRunLessThanDelta($wy,delta)
		yCols= pnts / xRows
	endif
	Make/O/N=(xRows, yCols)/D $mat
	SetScale/I x, $wx[0], $wx[pnts-1], WaveUnits($wx, 0), $mat
	SetScale/I y, $wy[0], $wy[pnts-1], WaveUnits($wy, 0), $mat

	if( xVariesMostRapidly )
		$mat = $wz[q*xrows+p]
	else
		$mat = $wz[p*ycols+q]
	endif
	
	Preferences 1
	if( mktbl == 1)
		Edit $mat
	endif
	if( mkimg == 1)
		NewImage $mat
	endif
End

Function  WMRunLessThanDelta(w,delta)
	Wave w
	Variable delta
	
	Variable i
	Variable n=numpnts(w)
	for(i=0; i<n-1; i+=1 )
		if( abs(w[i+1] - w[i] ) >= delta )
			break
		endif
	endfor
	return i+1
End
