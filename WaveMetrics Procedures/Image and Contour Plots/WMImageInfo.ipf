#pragma rtGlobals=1		// Use modern global access method.
#pragma version=8.04		// Released with Igor 8.04

#include <Graph Utility Procs>	// for WMGetRECREATIONInfoByKey

// Revisions:
//		5/2/2007, version 6.02: fixed WM_ImageColorLookupWave(). It failed to find the lookup wave because the extra space character was missing from the key.
//		8/27/2009, version 6.03: fixed WM_ImageColorLookupWave() to work correctly with liberal wave names.
//		7/30/2014, version 6.35: added WM_ImageColorIndexWave(). Used WMGetRECREATIONInfoByKey to extract from ImageInfo.
//		9/18/2014, version 6.355: fixed WM_ImageColorTabInfo and WM_ImageColorIndexWave bugs, and WM_ImageColorLookupWave works when there is no lookup wave.
//		9/24/2014, version 6.356: fixed WM_ImageColorTabInfo and WM_ImageColorIndexWave bugs related to data folders.
//		9/24/2014, version 6.37: WM_GetColorTableMinMax() returns correct values if the image wave is complex. Added WM_ImageDisplayedAxisRanges().
//		9/24/2014, version 6.38: WM_ImageColorLookupWave() works properly when the image has no lookup wave.
//		11/09/2016, version 7.02: WM_GetColorTableMinMax() works properly for Color Table Waves.
//		02/27/2017, version 7.03: WM_GetColorTableMinMax() works properly when a complex image with non-default X or Y scaling is autoscaled to visible XY
//		08/20/2019, version 8.04: WM_GetColorTableMinMax() works with images that have only one row and/or column.
//
// WM_GetColorTableMinMax
//
//	Returns the color table minimum and maximum through colorMin and colorMax.
//
//	Return value is truth that the colormin and max were returned sucessfully in colorMin and colorMax.
//
//	This routine is not appropriate for RGB Direct Color or Explicit Mode image plots.
//
Function WM_GetColorTableMinMax(graphName, imageName, colorMin, colorMax)
	String graphName, imageName
	Variable &colorMin, &colorMax

	colorMin= NaN
	colorMax= NaN
	
	if( strlen(imageName) == 0 )
		imageName= StringFromList(0,ImageNameList(graphName,";"))
	endif
	Wave/Z image= ImageNameToWaveRef(graphName,imageName)
	String infoStr= ImageInfo(graphName, imageName, 0)
	Variable colorMode= NumberByKey("COLORMODE",infoStr)
	String ctabInfo= WM_ImageColorTabInfo(graphName, imageName)
	if(  ((colorMode == 1) || (colorMode == 6)) && (strlen(ctabInfo) >0) && (WaveExists(image) == 1) )
		String mnStr= StringFromList(0,ctabInfo,",")		// could be *
		String mxStr= StringFromList(1,ctabInfo,",")		// could be *
		colorMin= str2num(mnStr)					// NaN if mnStr is "*"
		colorMax= str2num(mxStr)					// NaN if mxStr is "*"
		if( (CmpStr(mnStr,"*") == 0) || (CmpStr(mxStr,"*") == 0) )
			Variable ctabAutoscale= str2num(WMGetRECREATIONInfoByKey("ctabAutoscale",infoStr)) 
			Variable onlyDisplayedXY= ctabAutoscale & 0x1
			Variable onlyDisplayedPlane= (ctabAutoscale & 0x2) && (DimSize(image,2) > 0)
			Variable displayedPlane= str2num(WMGetRECREATIONInfoByKey("plane",infoStr))
			Variable wType= WaveType(image)
			Variable isComplex=  wType & 0x01
			if (isComplex)
				Variable cmplxMode= str2num(WMGetRECREATIONInfoByKey("imCmplxMode",infoStr))
				switch (cmplxMode)
					default:
					case 0:	//	magnitude
						MatrixOP/FREE image2= mag(image)
						break
					case 1:	//	real
						MatrixOP/FREE image2= real(image)
						break
					case 2:	//	imaginary
						MatrixOP/FREE image2= imag(image)
						break
					case 3:	//	phase
						MatrixOP/FREE image2= phase(image)
						break
				endswitch
				CopyScales/P image, image2 // 7.03: MatrixOp doesn't copy the scaling from the source wave.
				WAVE image= image2
			endif
			if( onlyDisplayedPlane )
				Duplicate/FREE/R=[][][displayedPlane] image, image3
				Wave image = image3
			endif
			if( onlyDisplayedXY )
				Variable xmin, xmax, ymin, ymax
				WM_ImageDisplayedAxisRanges(graphName, imageName, xmin, xmax, ymin, ymax)
				Duplicate/FREE/R=(xmin,xmax)(ymin,ymax) image, image4
				Wave image = image4
			endif
			if( CmpStr(mnStr,"*") == 0 )
				colorMin= WaveMin(image)
			endif
			if( CmpStr(mxStr,"*") == 0 )
				colorMax= WaveMax(image)
			endif
		endif
	endif
	return numtype(colorMin) == 0 && numtype(colorMax) == 0
End

//
// WM_ImageDisplayedAxisRanges
//
//		Returns x and y axis ranges displayed for the named image.
//		Returned values are not affected by ModifyGraph swapXY.
//
//		Currently does not handle log axes or image with X/Y coordinate waves specially.
//
//	Returns 0 if the named image isn't found.
//
Function WM_ImageDisplayedAxisRanges(graphName, imageName, xmin, xmax, ymin, ymax)
	String graphName, imageName
	Variable &xmin, &xmax, &ymin, &ymax
	
	Variable success= 0
	xmin= NaN
	xmax= NaN
	ymin= NaN
	ymax= NaN
	
	if( strlen(imageName) == 0 )
		imageName= StringFromList(0,ImageNameList(graphName,";"))
	endif
	String info=ImageInfo(graphName,imageName,0)
	Wave/Z image= ImageNameToWaveRef(graphName,imageName)
	if( strlen(info) && WaveExists(image) )
		String xaxis=StringByKey("XAXIS",info)
		String yaxis=StringByKey("YAXIS",info)
		GetAxis/W=$graphName/Q $xaxis
		if( V_Min > V_Max )	// reversed x axis?
			xmin= V_Max
			xmax= V_Min
		else
			xmin= V_Min
			xmax= V_Max
		endif
		GetAxis/W=$graphName/Q $yaxis
		if( V_Min > V_Max )	// reversed y axis?
			ymin= V_Max
			ymax= V_Min
		else
			ymin= V_Min
			ymax= V_Max
		endif
		// limit displayed axis range to max image scaling range
		Variable imageXMin,  imageXMax, dx= DimDelta(image,0)
		if( dx < 0 )	// reversed x scaling?
			imageXMax= DimOffset(image,0) - dx/2
			imageXMin= imageXMin + DimDelta(image,0) * (DimSize(image,0)-1) +  dx/2
		else
			imageXMin= DimOffset(image,0) - dx/2
			imageXMax= imageXMin + DimDelta(image,0) * (DimSize(image,0)-1) +  dx/2
		endif
		xmin= limit(xmin, imageXMin, imageXMax)
		xmax= limit(xmax, imageXMin, imageXMax)
		
		Variable imageYMin,imageYMax, dy= DimDelta(image,1)
		if( dy < 0 )	// reversed y scaling?
			imageYMax= DimOffset(image,1) - dy/2
			imageYMin= imageYMin + DimDelta(image,1) * (DimSize(image,1)-1) + dy/2
		else
			imageYMin= DimOffset(image,1) - dy/2
			imageYMax= imageYMin + DimDelta(image,1) * (DimSize(image,1)-1) + dy/2
		endif

		ymin= limit(ymin, imageYMin, imageYMax)
		ymax= limit(ymax, imageYMin, imageYMax)
		
		success= 1
	endif
	
	return success
End

//
// WM_ColorTableForImage
//
//		Returns the name of the color table used by the named image, or the path from the root data folder to a color table wave.
//
//	Returns "" if the named image isn't found.
//
Function/S WM_ColorTableForImage(graphName, imageName)
	String graphName, imageName

	String colorTable=""
	String ctabInfo= WM_ImageColorTabInfo(graphName, imageName)
	if( strlen(ctabInfo) )
		colorTable= StringFromList(2,ctabInfo,",")				// third item is color table or path to color table wave
	endif
	return colorTable
End

//
// WM_ColorTableReversed
//
//		Returns the color table reversal value used by the named image
//
//	Returns NaN if the named image isn't found.
//
Function WM_ColorTableReversed(graphName, imageName)
	String graphName, imageName

	Variable reversed= NaN

	String ctabInfo= WM_ImageColorTabInfo(graphName, imageName)
	if( strlen(ctabInfo) )
		reversed= str2num(StringFromList(3,ctabInfo,","))		// 1 if color table is reversed
	endif
	return reversed
End

//
// WM_ImageColorTabInfo
//
//	Returns the color start, end, color table name or wave, and reversal flag as a string without the enclosing {}
//
Function/S WM_ImageColorTabInfo(graphName,imageName)
	String graphName, imageName

	String info= ImageInfo(graphName, imageName, 0)
	if( strlen(info) )
		String ctabInfo= WMGetRECREATIONInfoByKey("ctab",info)	// " {*,*,Rainbow,0}"
		ctabInfo= RemoveLeadingSpaces(ctabInfo)					// "{*,*,Rainbow,0}"
		info= ctabInfo[1,strlen(ctabInfo)-2]							// "*,*,Rainbow,0"
	endif
	return info
End

static Function/S RemoveLeadingSpaces(str)
	String str
	
	Variable i, n= strlen(str)
	for(i=0; i<n; i+=1 )
		if( CmpStr(str[i]," ") != 0 )
			return str[i,n-1]
		endif
	endfor
	return ""	// all spaces!
End

static Function/S FullPathFromRelative(relativePath)
	String relativePath	// relative the current data folder
	
	relativePath= RemoveLeadingSpaces(relativePath)
	// Now we have a relative path from CURRENT data folder, either a bare wave name,
	// or something like :subfolder:cindexWave
	// A bare liberal name like 'my wave with space' needs a ":" prefix for the Wave/Z statement to succeed.
	Variable pos= strsearch(relativePath, ":", 0)
	if( pos < 0 )
		relativePath= ":"+relativePath
	endif
	WAVE/Z w= $relativePath
	String fullPath=""
	if( WaveExists(w) )
		fullPath= GetWavesDataFolder(w,2)	// possibly quoted folders and wave name
	endif
	return fullPath
End

//
// WM_ImageColorLookupWave
//
//		Returns the full path to the image's lookup wave or "" if not specified or if the wave no longer exists.
//
Function/S WM_ImageColorLookupWave(graphName,imageName)
	String graphName, imageName

	String info= ImageInfo(graphName, imageName, 0)
	if( strlen(info) )
		String relativePath= WMGetRECREATIONInfoByKey("lookup",info)	// returns path relative to current data folder.
		// 6.38: check for "$"""
		Variable pos= strsearch(relativePath, "$\"\"", 0)
		if( pos < 0 )	// if not $"", parse relative path.
			info= FullPathFromRelative(relativePath)
		endif
	endif
	return info
End

//
// WM_ImageColorIndexWave
//
//		Returns the full path to the image's cindex wave or "" if not specified or if the wave no longer exists.
//
Function/S WM_ImageColorIndexWave(graphName,imageName)
	String graphName, imageName

	String info= ImageInfo(graphName, imageName, 0)
	if( strlen(info) )
		String relativePath= WMGetRECREATIONInfoByKey("cindex",info)
		info= FullPathFromRelative(relativePath)
	endif
	return info
End


