#pragma rtGlobals=1		// Use modern global access method.
#pragma version=6.23		// Released with Igor 6.23
#pragma IgorVersion= 6.0	// Threadsafe and MultiThread

// #include <Image Contour Slicing>
//
// Image Contour Slicing
//
//	Used to create sliced (or plateau-d) images that have the same value within a contour level.
//
//	The interpolation routines improve the appearance near the contour lines themselves.
//
//	IMPORTANT:
//
//		These routines provide a crude fill-between-contour-levels appearance for only Matrix contour plots
//		that have no associated x or y waves providing coordinates.
//
//		For XYZ contours (or matrix contours that use x or y waves) use the newer AppendImageToContour.ipf:
//
//		#include <AppendImageToContour>
//
//	JP110818, 6.23: WMSliceAtLevels() no longer alters inputs that are NaN or Inf, is Threadsafe.

//
// WMCreateImageForMatrixContour is the main routine for users.
//
// Usage:	Wave interpolatedImage= $WMCreateImageForMatrixContour("Graph0","myMatrixContour",1,4)
//			AppendImage/W=Graph0 interpolatedImage
//
Function/S WMCreateImageForMatrixContour(graphName,contourInstanceName,slice,expansion)
	String graphName,contourInstanceName
	Variable slice		// set to non-zero to make images with identical values within a contour level.
	Variable expansion	// interpolation factor, an integer greater than one and less than your exasperation level.
	
	WAVE contourImage= ContourNameToWaveRef(graphName,contourInstanceName)	// expected to be matrix wave.
	
	if( (slice != 0) + (expansion != 1) )
		String outPath= WMCreatedContourImagePath(contourImage)
		WAVE image= $WMCreateInterpolatedImage(contourImage,expansion,outPath)
		
		if( slice )
			WMSliceImageAtContours(graphName,contourInstanceName,image)
		endif
	else
		WAVE image= contourImage
	endif

	return GetWavesDataFolder(image,2)	// the path to the created interpolated image
End

// WMCreatedContourImagePath fabricates a full path to a (probably not-yet-existant)
// interpolated image wave based on the name and path of the source image
//
Function/S WMCreatedContourImagePath(image)
	Wave image
	
	String imageOutput= CleanupName(NameOfWave(image)[0,27]+"Img",0)
	String outPath= GetWavesDataFolder(image,1)+imageOutput
	return outPath
End

Function/S WMCreateInterpolatedImage(image,expansion,interpolatedOutWaveName)
	Wave image
	Variable expansion
	String interpolatedOutWaveName	// could be path, in which case it had better not be <current DF>:M_InterpolatedImage
	
	ImageInterpolate /F={expansion,expansion} Bilinear  image	// output is M_InterpolatedImage
	
	if( Cmpstr(interpolatedOutWaveName,"M_InterpolatedImage") != 0 )
		Duplicate/O M_InterpolatedImage, $interpolatedOutWaveName
		WAVE w= $interpolatedOutWaveName
		CopyScales/I image, w
		KillWaves/Z M_InterpolatedImage
	else
		WAVE w= M_InterpolatedImage
	endif
	
	return GetWavesDataFolder(w,2)
End

// Values that fall between the values in the (1-d) levels wave
// are set to the value of the bigger value.
// Values less than the smallest level are set to bottomLevel.
// Values that are greater than the highest level are set to the highest level. 
// levelsWave must be sorted ascending, and bottomLevel must be <= than any possible val.
Threadsafe Function WMSliceAtLevels(val,levelsWave,bottomLevel)
	Variable val
	Wave levelsWave
	Variable bottomLevel	// usually V_Min or 0
	
	if( numtype(val) != 0 )	// JP110818
		return val
	endif
	
	if( val <= bottomLevel )
		return bottomLevel
	endif
	
	Variable pt= BinarySearch(levelsWave,val)
	if( pt == -1 )
		return bottomLevel
	endif
	Variable n= numpnts(levelsWave)
	if( pt == -2 )
		return levelsWave[n-1]
	endif
	return levelsWave[pt]
End

Function/S WMSliceImageAtContours(graphName,contourInstanceName,image)
	String graphName,contourInstanceName
	Wave image

	// Get levels from the contour plot:
	String info= contourinfo(graphName,contourInstanceName,0)	// one of the entries is "LEVELS:1,3,5;"
	String levelsStr= StringByKey("LEVELS", info)
	Variable numLevels= ItemsInList(levelsStr,",")
	Make/O/N=(numLevels) WM_levels= str2num(StringFromList(p,levelsStr,","))
	ImageStats/M=1 image
	
	// slice the image.
	MultiThread image= WMSliceAtLevels(image[p][q],WM_levels,V_Min)
	KillWaves/Z WM_levels
	return GetWavesDataFolder(image,2)
End
