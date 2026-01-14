#pragma rtGlobals= 1
#pragma version=8.04	// this version shipped with Igor 8.04
#pragma IgorVersion=4	// DoPrompt added for Igor 4
//
//	Version 8.04, JP191007: fAutoSizeImage() quits without DoPrompt dialog if no images, added /HELP to DoPrompt.
//	Version 6.05, JP080926: Made independent module-compatible.
//	Version 1.2, LH971111: added -1 as flipVert flag to mean no change.
//	Version 1.1, LH970912: used new ScreenResolution constant to get proper results under Windows.
//
//	This package makes it easy to properly size images, especially photographs.
//	It adds "Autosize Image" to the Macros menu.
//
//	In the dialog from AutoSizeImage:
//	Choose Yes from Flip Vertical if you are displaying a photograph
//	Set the multiplier to zero to let the package try to find a proper size
//	or enter your own multiplier to force the image to be a particular size.
//	The size in Points will be the size of the dimensions of the matrix
//	times your multiplier. The size will be fixed if you enter your own
//	multiplier but will be resizeable if you enter zero.

//	You might find it handy to call the fAutoSizeImage function from your
//	own code.

Menu "Macros"
	"Autosize Image", /Q, fAutoSizeImage()
End

StrConstant ksHelp="Set multiplier to 0 for autosize or a multiplier. For example, a multiplier = 2 results in 2 points per pixel. Use Flip Vertical to display a photograph."

// this works in independent modules that #include <Autosize Images>
Function fAutoSizeImage()

	String images= ImageNameList("", ";")
	Variable numImages= ItemsInList(images)
	if( numImages < 1 )
		DoAlert 0, "Graph "+WinName(0,1)+" contains no images to autosize!"
		return -1
	endif

	Variable forceSize= NumVarOrDefault("root:Packages:WMAutoSizeImages:forceSizeSav",0)
	Variable flipVert= NumVarOrDefault("root:Packages:WMAutoSizeImages:flipVertSav",1)+2
	Prompt forceSize,"Enter multiplier for forced image size or zero to autosize"
	Prompt flipVert,"Flip vertical (images)",Popup "No change;Yes;No"

	DoPrompt/HELP=ksHelp "Autosize Image", forceSize, flipVert
	if( V_Flag == 0 )	
		DoAutoSizeImage(forceSize,flipVert-2)
	endif
End

// for old routines
Proc AutoSizeImage(forceSize,flipVert)
	Variable forceSize= NumVarOrDefault("root:Packages:WMAutoSizeImages:forceSizeSav",0)
	Variable flipVert= NumVarOrDefault("root:Packages:WMAutoSizeImages:flipVertSav",1)+2
	Prompt forceSize,"Enter multiplier for forced image size or zero to autosize"
	Prompt flipVert,"Flip vertical (images)",Popup "No change;Yes;No"
	
	DoAutoSizeImage(forceSize,flipVert-2)
end

Function DoAutoSizeImage(forceSize,flipVert)
	variable forceSize,flipVert
	
	if( (forceSize != 0) )
		if( (forceSize<0.1) %| (forceSize>20) )
			Abort "Unlikely value for forceSize; usually 0 or between .1 and 20"
			return 0
		endif
	endif
	String imagename= ImageNameList("", ";")
	Variable p1= strsearch(imagename, ";", 0)
	if( p1 <= 0 )
		Abort "Graph contains no images"
		return 0
	endif

	// Remember input for next time
	String dfSav= GetDataFolder(1);
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S WMAutoSizeImages
	Variable/G forceSizeSav= forceSize
	Variable/G flipVertSav= flipVert
	SetDataFolder dfSav
	
	 imagename= imagename[0,p1-1]
	Wave w= ImageNameToWaveRef("",imagename)
	Variable height= DimSize(w,1)
	Variable width= DimSize(w,0)
	do
		if( forceSize )
			height *= forceSize;
			width *= forceSize;
			break
		endif
		variable maxdim= max(height,width)
		NewDataFolder/S tmpAutoSizeImage
		Make/O sizes={20,50,100,200,600,1000,2000,10000,50000,100000}		// temp waves used as lookup tables
		Make/O scales={16,8,4,2,1,0.5,0.25,0.125,0.0626,0.03125}
		Variable nsizes= numpnts(sizes),scale= 0,i= 0
		do
			if( maxdim < sizes[i] )
				scale= scales[i]
				break;
			endif
			i+=1
		while(i<nsizes)
		KillDataFolder :			// zap our two temp waves that were used as lookup tables
		if( scale == 0 )
			Abort "Image is bigger than planned for"
			return 0
		endif
		width *= scale;
		height *= scale;
	while(0)

	String axname= ImageInfo("",imagename,0)
	Variable p0= strsearch(axname, "YAXIS:", 0)
	p0=  strsearch(axname, ":", p0)
	p1=  strsearch(axname, ";", p0)
	if( flipVert != -1 )
		if( flipVert )
			SetAxis/A $(axname[p0+1,p1-1])
		else
			SetAxis/A/R $(axname[p0+1,p1-1])
		endif
	endif
	width *= 72/ScreenResolution					// make image pixels match screen pixels
	height *= 72/ScreenResolution					// make image pixels match screen pixels
	ModifyGraph width=width,height=height
	DoUpdate
	if( forceSize==0 )
		ModifyGraph width=0,height=0
	endif
end
 