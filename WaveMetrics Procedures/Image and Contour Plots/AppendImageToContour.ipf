#pragma rtGlobals=1		// Use modern global access method.
#pragma version=6.02		// Released with Igor 6.02
#include <Image Contour Slicing>
//
// AppendImageToContour.ipf
// version 6.02 - 08/07/2007, JP:
//				Better menu text for WMAppendFillBetweenContours.
// version 6.01 - 04/23/2007, JP:
//				Works better with matrix contours using x and y waves to provide the coordinates.
// version 6 - 09/05/2006, JP:
//				Demoted AppendImageToContour to Proc (which removed a Macros menu item,
//				added Graph menu item, added slicing option (which is what the #include
//				<Image Contour Slicing> is for).
// version 2.0 - 01/24/2001, JP
//				Created image name is made unique, user prompted to remove existing image.
//

Menu "Graph"
	"Append Image or Fill Between Contours", WMAppendFillBetweenContours()
End

Function WMAppendFillBetweenContours()

	String graphName= WinName(0,1)	// top graph
	String contours= ContourNameList("",";")
	if( strlen(graphName) == 0 || strlen(contours) == 0 )
		DoAlert 0, "Need a contour plot in top graph to do this!"
		return 0
	endif

	String contourInstanceName= StringFromList(0,contours)
	if( ItemsInList(contours) > 1 )
		Prompt contourInstanceName,"contour plot to fill",popup,ContourNameList("",";")
		DoPrompt "Append Image or Fill between Contours", contourInstanceName
		if( V_Flag != 0 )
			return 0
		endif
	endif

	WAVE contourImage= ContourNameToWaveRef(graphName,contourInstanceName)	// matrix wave, triplet wave, or z wave of x,y,z contour
	String info=ContourInfo(graphName,contourInstanceName,0)
	String haxis= StringByKey("XAXIS",info)
	String vaxis= StringByKey("YAXIS",info)
	String xwavePath= StringByKey("XWAVE",info)
	String ywavePath= StringByKey("YWAVE",info)
	String zwavePath= StringByKey("ZWAVE",info)
	String flags= StringByKey("AXISFLAGS",info)
	String type=StringByKey("DATAFORMAT",info)

	// choose rows, cols (for xyz contours) based on plot area in pixels,
	GetWindow $graphName, psizeDC	// pixels V_left, V_right, V_top, and V_bottom
	Variable rows=V_right-V_left
	Variable cols=V_bottom-V_top
	String commands=WinRecreation(graphName,4)
	Variable swapXY = strsearch(commands, "swapXY=1",0) >= 0
	if( swapXY )
		Variable tmp= rows
		rows= cols
		cols=tmp	
	endif
	// limit default to something speedy
	if( rows > 1024 )
		rows= 1024
	endif
	if( cols > 1024 )
		cols= 1024
	endif
	
	// Propose an expansion (for matrix contours) that fills the plot area pixels
	Variable expansion=ceil(rows/DimSize(contourImage,0))
	expansion= max(expansion, ceil(cols/DimSize(contourImage,1)))
	Variable sliceYN=1// Yes
	Prompt sliceYN, "Flat color between contours?", popup, "Yes;No;"

//	if( CmpStr(type,"Matrix") == 0 )
	WAVE/Z wx=$xwavePath
	WAVE/Z wy=$ywavePath
	Variable isMatrixInterpolation= (CmpStr(type,"Matrix") == 0) && !WaveExists(wx) && !WaveExists(wy)
	if( isMatrixInterpolation )
		Prompt expansion,"interpolation factor"
		DoPrompt "Append Image or Fill between Matrix Contours",  sliceYN, expansion
		rows= expansion * DimSize(contourImage,0)
		cols=  expansion * DimSize(contourImage,1)
	else
		Prompt rows,"number of rows"
		Prompt cols,"number of cols"
		DoPrompt "Append Image or Fill between XYZ Contours", sliceYN, rows, cols
	endif
	if( V_Flag != 0 )
		return 0
	endif
	Variable doSlice= sliceYN == 1	// 1 is Yes, 2 is No

	// pathToImage is the image we want to display. It COULD be just the matrix contour's image
	String pathToImage= WMCreateImageForContour(graphName,contourInstanceName,doSlice,rows,cols)
	Wave image= $pathToImage
	Variable imageAlreadyDisplayed= ImageIsDisplayed(graphName,image)
	if( imageAlreadyDisplayed )
		return 0
	endif 

	// Avoid having BOTH the matrix contour image and an interpolated/sliced image in the graph
	String pathToContourWave= GetWavesDataFolder(contourImage,2)
	Variable contourDisplayedAsImage=  ImageIsDisplayed(graphName,contourImage)
	
	String pathForPossiblyExtantImage= WMCreatedContourImagePath(contourImage)	// NOT the matrix wave; a (re-)created wave, may not even exist.
	WAVE/Z possiblyExtantCreatedImage= $pathForPossiblyExtantImage
	Variable possiblyExtantDisplayedAsImage=  WaveExists(possiblyExtantCreatedImage) && ImageIsDisplayed(graphName,possiblyExtantCreatedImage)

	// we're either going to replace an image or append an image
	String imageInstanceName
	if( contourDisplayedAsImage )
		imageInstanceName= ImageDisplayedName(graphName, contourImage)
		ReplaceWave/W=$graphName image=$imageInstanceName, image

	elseif( possiblyExtantDisplayedAsImage )
		imageInstanceName= ImageDisplayedName(graphName, possiblyExtantCreatedImage)
		ReplaceWave/W=$graphName image=$imageInstanceName, image
	else
		String cmd
		sprintf cmd,"AppendImage%s %s",flags,pathToImage
		Execute cmd
	endif
	return 1	// truth an image was appended or altered
End

// inverse of ImageNameToWaveRef()
static Function/S ImageDisplayedName(graphName, image)
	String graphName
	Wave image
	
	String pathToImage=  GetWavesDataFolder(image,2)
	String images=ImageNameList(graphName,";")
	Variable i=0
	do
		String imageName= StringFromList(i, images)
		if( strlen(imageName) == 0 )
			break
		endif
		Wave w= ImageNameToWaveRef(graphName,imageName)
		String pathToW=GetWavesDataFolder(w,2)
		if( CmpStr(pathToImage, pathToW) == 0 )
			return imageName
		endif
		i+=1
	while(1)

	return ""
End

static Function ImageIsDisplayed(graphName,image)
	String graphName
	Wave image
	
	String imageInstanceName= ImageDisplayedName(graphName, image)
	return strlen(imageInstanceName) > 0
End


//
// WMCreateImageForContour is the main routine for users.
//
// Usage:	Wave interpolatedImage= $WMCreateImageForContour("Graph0","myMatrixContour",1,4)
//			AppendImage/W=Graph0 interpolatedImage
//
Function/S WMCreateImageForContour(graphName,contourInstanceName,slice,rows,cols)
	String graphName,contourInstanceName
	Variable slice		// set to non-zero to make images with identical values within a contour level.
	Variable rows,cols	// size of image
	
	WAVE contourImage= ContourNameToWaveRef(graphName,contourInstanceName)	// matrix wave, triplet wave, or z wave of x,y,z contour
	String info=ContourInfo(graphName,contourInstanceName,0)
	String type=StringByKey("DATAFORMAT",info)
	String xwavePath= StringByKey("XWAVE",info)
	String ywavePath= StringByKey("YWAVE",info)
	WAVE/Z wx=$xwavePath
	WAVE/Z wy=$ywavePath
	Variable doContourZ= CmpStr(type,"XYZ") == 0 || WaveExists(wx) || WaveExists(wy)
	
	if( doContourZ || slice || (rows != DimSize(contourImage,0) || cols != DimSize(contourImage,1)) )
		String outPath= WMCreatedContourImagePath(contourImage)
		if( doContourZ )
			Make/O/N=(rows,cols) $outPath
			Wave image=$outPath
			String haxis= StringByKey("XAXIS",info)
			String vaxis= StringByKey("YAXIS",info)
			GetAxis/W=$graphName/Q $haxis
			SetScale/I x, V_min, V_max, "",image
			GetAxis/W=$graphName/Q $vaxis
			SetScale/I y, V_min, V_max, "",image
			image= ContourZ(graphName,contourInstanceName,0,x,y)
		else
			Variable x0= DimOffset(contourImage,0)
			Variable xn= x0+(DimSize(contourImage,0)-1)*DimDelta(contourImage,0)
			Variable dx= (xn-x0)/(rows-1)

			Variable y0= DimOffset(contourImage,1)
			Variable yn= y0+(DimSize(contourImage,1)-1)*DimDelta(contourImage,1)
			Variable dy= (yn-y0)/(cols-1)
			
			ImageInterpolate /S={x0,dx,xn,y0,dy,yn} Bilinear  contourImage	// output is M_InterpolatedImage
			Duplicate/O M_InterpolatedImage, $outPath
			WAVE image= $outPath
			CopyScales/I contourImage, image
			KillWaves/Z M_InterpolatedImage
		endif
				
		if( slice )
			WMSliceImageAtContours(graphName,contourInstanceName,image)
		endif
	else
		WAVE image= contourImage
	endif

	return GetWavesDataFolder(image,2)	// the path to the created interpolated image
End

// AppendImageToContour is included for version 2 backward compatibility
Proc AppendImageToContour(plot,n)
	String plot
	Variable n=20
	Prompt plot,"contour plot",popup,ContourNameList("",";")
	Prompt n,"number of rows (and columns) for image"

	Silent 1;PauseUpdate
	String info=ContourInfo("",plot,0)
	String haxis= StringByKey("XAXIS",info)
	String vaxis= StringByKey("YAXIS",info)
	String xwave= StringByKey("XWAVE",info)
	String ywave= StringByKey("YWAVE",info)
	String zwave= StringByKey("ZWAVE",info)
	String flags= StringByKey("AXISFLAGS",info)
	String type=StringByKey("DATAFORMAT",info)
	Variable doContourZ= CmpStr(type,"XYZ") == 0
	// Make matrix that spans displayed X and Y
	String image=zwave
	String images=ImageNameList("",";")
	if( doContourZ )
		if( strlen(images) )
			// ask user whether to an remove existing image
			AICRemoveImageFromGraph()
		endif
		image=CleanupName(image+"Img",1)	// not necessarily a unique name
		if( exists(image) )
			image=UniqueName(image,1,0)
		endif
		Make/O/N=(n,n) $image				// overwrite
		GetAxis/Q $haxis
		SetScale/I x, V_min, V_max, "",$image
		GetAxis/Q $vaxis
		SetScale/I y, V_min, V_max, "",$image
		$image= ContourZ("",plot,0,x,y)
	else // Matrix contour
		if( (strlen(xwave) + strlen(ywave)) > 0)	// these grid waves won't work with images
			DoAlert 0, "Can't append image because contour grid wave(s) don't work with image plots."
			return
		endif
		// if already in graph, don't append again
		if( FindListItem(image, images) >= 0 )
			DoAlert 0, image+" is already displayed as an image!"
			return
		endif
	endif
	String cmd
	sprintf cmd,"AppendImage%s %s",flags,PossiblyQuoteName(image)
	Execute cmd
End

// AICRemoveImageFromGraph is included for version 2 backward compatibility
Proc AICRemoveImageFromGraph(image,deleteImage)
	String image
	Variable deleteImage=2	// No by default. Change to =1 for Yes by default.
	Prompt image,"Remove existing image?",popup,ImageNameList("",";")+"_don't remove any images_;"
	Prompt deleteImage,"Delete removed image (if unused)?",popup,"Yes;No;"

	String images=ImageNameList("",";")
	if( FindListItem(image, images) >= 0 )
		RemoveImage/Z $image
		if( deleteImage == 1 )
			KillWaves/Z $image
		endif
	endif
End