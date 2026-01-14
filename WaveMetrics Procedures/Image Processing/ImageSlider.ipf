#pragma rtGlobals=2		// Need new syntax
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#include <Image Common>
#include <Image Threshold Panel>

//*******************************************************************************************************
// AG 24JAN02
// Procedure to add a slider to 3D images in order to simplify the display
// of different layers.  Modified from LH procedure AxisSlider.ipf
// 01SEP06
// Changed the ValDisplay to SetVariable so that the control up and down arrows can be used to precisely move by one frame.
// 09JUN10 added support for 4D RGB stack (suggested by Mario M. Dorostkar).
// ST 01JUN21
// Added correct limits for the variable control and a Done button to remove the slider.
// Slightly adjusted the control positions and made sure that the controls cannot get too small if the graph is too narrow.
// Now the controls resize together with the graph.
// AL 31May2022
// * Fixed controls to reflect the displayed plane when user changes plane using ModifyImage plane=#.
// * Rename data folder used by package if the graph is renamed.
// JP 15JUN22
// Z Scale of image's layer is the help text for the setVariable and slider.
//*******************************************************************************************************

static StrConstant WMkSliderDataFolderBase = "root:Packages:WM3DImageSlider:"

Function WM3DImageSliderProc(name, value, event)
	String name			// name of this slider control
	Variable value		// value of slider
	Variable event		// bit field: bit 0: value set; 1: mouse down, //   2: mouse up, 3: mouse moved

	String dfSav= GetDataFolder(1)
	String grfName= WinName(0, 1)
	SetDataFolder $(WMkSliderDataFolderBase + grfName)

	NVAR gLayer
	SVAR imageName

	ModifyImage  $imageName plane=(gLayer)
	
	String helpStr=""
	WAVE/Z imageW = ImageNameToWaveRef(grfName, imageName)
	if( WaveExists(imageW) )
		Variable zScale = DimOffset(imageW,2) + gLayer * DimDelta(imageW,2)
		helpStr= "Z scale = "+num2str(zScale)
	endif
	ModifyControlList "WM3DVal;WM3DAxis;" win=$grfName, help={helpStr}

	SetDataFolder dfSav

	// 08JAN03 Tell us if there is an active LineProfile
	SVAR/Z imageGraphName=root:Packages:WMImProcess:LineProfile:imageGraphName
	if(SVAR_EXISTS(imageGraphName))
		if(cmpstr(imageGraphName,grfName)==0)
			ModifyGraph/W=$imageGraphName offset(lineProfileY)={0,0}			// This will fire the S_TraceOffsetInfo dependency
		endif
	endif	
		
	SVAR/Z imageGraphName=root:Packages:WMImProcess:ImageThreshold:ImGrfName
	if(SVAR_EXISTS(imageGraphName))
		if(cmpstr(imageGraphName,grfName)==0)
			WMImageThreshUpdate()
		endif
	endif
	
	return 0				// other return values reserved
End

//*******************************************************************************************************
constant kImageSliderLMargin= 150		// ST: 210601 - more space for the quit button

Function WMAppend3DImageSlider()
	String grfName= WinName(0, 1)
	DoWindow/F $grfName
	if( V_Flag==0 )
		return 0			// no top graph, exit
	endif


	String iName= WMTopImageGraph()		// find one top image in the top graph window
	if( strlen(iName) == 0 )
		DoAlert 0,"No image plot found"
		return 0
	endif
	
	Wave w= $WMGetImageWave(iName)	// get the wave associated with the top image.	
	if(DimSize(w,2)<=0)
		DoAlert 0,"Need a 3D image"
		return 0
	endif
	
	ControlInfo WM3DAxis
	if( V_Flag != 0 )
		return 0			// already installed, do nothing
	endif
	
	String dfSav= GetDataFolder(1)
	NewDataFolder/S/O root:Packages
	NewDataFolder/S/O WM3DImageSlider
	NewDataFolder/S/O $grfName
	
	// 09JUN10 Variable/G gLeftLim=0,gRightLim=DimSize(w,2)-1,gLayer=0
	Variable/G gLeftLim=0,gRightLim,gLayer=0
	if((DimSize(w,3)>0 && (dimSize(w,2)==3 || dimSize(w,2)==4)))		// 09JUN10; will also support stacks with alpha channel.
		gRightLim=DimSize(w,3)-1					//image is 4D with RGB as 3rd dim
	else
		gRightLim=DimSize(w,2)-1					//image is 3D grayscale
	endif
	
	String/G imageName=nameOfWave(w)
	ControlInfo kwControlBar
	Variable/G gOriginalHeight= V_Height			// we append below original controls (if any)
	ControlBar gOriginalHeight+30

	GetWindow kwTopWin,gsize
	Variable scale = ScreenResolution / 72										// ST: 210601 - properly scale position for windows
	Variable left = V_left*scale
	Variable right = limit(V_right*scale, left+kImageSliderLMargin+50,inf)		// ST: 210601 - make sure the controls get not too small
	
	Slider WM3DAxis,pos={left+10,gOriginalHeight+10},size={right-left-kImageSliderLMargin,16},proc=WM3DImageSliderProc		// ST: 210601 - shift slider slightly down
	// uncomment the following line if you want do disable live updates when the slider moves.
	// Slider WM3DAxis live=0	
	Slider WM3DAxis,limits={0,gRightLim,1},value= 0,vert= 0,ticks=0,side=0,variable=gLayer	
	
	SetVariable WM3DVal,pos={right-kImageSliderLMargin+15,gOriginalHeight+6},size={60,18}	// ST: 210601 - control slightly higher to line up with the slider
	SetVariable WM3DVal,limits={0,gRightLim,1},title=" ",proc=WM3DImageSliderSetVarProc		// ST: 210601 - apply same limits as slider
	SetVariable WM3DVal,value=gLayer

	Variable zScale = DimOffset(w,2) + gLayer * DimDelta(w,2)
	String helpStr= "Z scale = "+num2str(zScale)
	ModifyControlList "WM3DVal;WM3DAxis;" help={helpStr}

	Button WM3DDoneBtn,pos={right-kImageSliderLMargin+85,gOriginalHeight+6},size={50,18}	// ST: 210601 - button to remove the slider again
	Button WM3DDoneBtn,title="Done",proc=WM3DImageSliderDoneBtnProc

	ModifyImage $imageName plane=0
	// 
	WaveStats/Q w
	ModifyImage $imageName ctab= {V_min,V_max,,0}	// missing ctName to leave it unchanged.
	
	SetWindow $grfName hook(WM3Dresize)=WM3DImageSliderWinHook
	
	SetDataFolder dfSav
End

//*******************************************************************************************************
Function WM3DImageSliderSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		// comment the following line if you want to disable live updates.
		case 3: // Live update
			Variable dval = sva.dval
			WM3DImageSliderProc("",0,0)
			break
	endswitch

	return 0
End

//*******************************************************************************************************
Function WM3DImageSliderDoneBtnProc(bs) : ButtonControl		// ST: 310601 - removes the slider controls
	STRUCT WMButtonAction &bs
	if (bs.eventCode == 2)
		DFREF valDF = $(WMkSliderDataFolderBase + bs.win)
		NVAR originalHeight = valDF:gOriginalHeight
		SetWindow $(bs.win) hook(WM3Dresize)=$""
	
		ControlBar originalHeight
		KillControl/W=$bs.win WM3DAxis
		KillControl/W=$bs.win WM3DVal
		KillControl/W=$bs.win WM3DDoneBtn
		KillDataFolder/Z valDF
	endif
	return 0
End
//*******************************************************************************************************

Function WM3DImageSliderWinHook(s)							// ST: 310601 - graph hook to resize the controls dynamically
	STRUCT WMWinHookStruct &s
	if (s.EventCode == 6)	// resize
		DFREF valDF = $(WMkSliderDataFolderBase + s.winName)
		NVAR gOriginalHeight = valDF:gOriginalHeight
		
		Variable left = s.winRect.left
		Variable right = limit(s.winRect.right, left+kImageSliderLMargin+50,inf)
		
		Slider WM3DAxis		,win=$(s.winName)	,pos={left+10,gOriginalHeight+10}						,size={right-left-kImageSliderLMargin,16}
		SetVariable WM3DVal	,win=$(s.winName)	,pos={right-kImageSliderLMargin+15,gOriginalHeight+6}	,size={60,18}
		Button WM3DDoneBtn	,win=$(s.winName)	,pos={right-kImageSliderLMargin+85,gOriginalHeight+6}	,size={50,18}
	elseif (s.EventCode == 8)	// modified
		DFREF valDF = $(WMkSliderDataFolderBase + s.winName)
		SVAR/Z/SDFR=valDF imageName
		NVAR/Z/SDFR=valDF gLayer
		if (SVAR_Exists(imageName) && NVAR_Exists(gLayer))
			String info = ImageInfo(s.winName, imageName, 0)
			Variable pos = strsearch(info, "RECREATION", 0)
			if (pos >= 0)
				// If the user executes ModifyImage plane=#, make sure that the plane
				// number displayed in the SetVariable control and the slider reflect the change.
				String rec = info[pos + 11, strlen(info) - 1] // strlen("RECREATION:") = 11
				Variable plane = NumberByKey("plane", rec, "=", ";", 0)
				if (numtype(plane) == 0 && (gLayer != plane))
					gLayer = plane
					WM3DImageSliderProc("",0,0)
				endif
			endif
		endif
	elseif (s.EventCode == 13)	// renamed
		// Rename the data folder containing this package's globals.
		DFREF oldDF = $(WMkSliderDataFolderBase + s.oldWinName)
		if (DataFolderRefStatus(oldDF) == 1)
			RenameDataFolder oldDF, $(s.winName)
		endif
	endif		
		
	return 0
End