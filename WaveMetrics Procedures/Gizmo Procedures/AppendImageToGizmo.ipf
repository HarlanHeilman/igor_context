#pragma rtGlobals=3		// Use modern global access method.
#pragma moduleName=GizmoAppendImage
#pragma version=6.2		// Shipped with Igor 6.2
#pragma IgorVersion=6.2	// for Gizmo-related improvements, #pragma rtGlobals=3

#include <PopupWaveSelector>
#include <GizmoTextures>,menus=0		// Makes a texture from an image wave or graph
#include <GizmoBlending>
#include <GizmoUtils>, version>=6.2		// for TopGizmo, etc.

// AppendImageToGizmo.ipf
//
// Appends images made from matrix surfaces or RGB waves and displays them in a selectable plane in Gizmo.
// Images can be made from the projection of matrix surfaces onto the X or Y planes.
// These projected images can be colored using the surface's colors or be made all one color.
//
//  RGB images can be used to colorize planes in nearly any axis, including the background.
// The RGB images can be painted as a parametric surface (which can be slow, but is usually sharp),
// or as a surface (which is fast, but can be blurry).
//
// The user interface is implemented by WMGizmoImagePanel()


// Public Revisions:
// JP100702: fixed MakeGizmoSurfaceImageColorWave() to work without error when the surface wave has NaNs or Infs in it.
// JP100723: lowered texture size minimum from 128 to 16.
// JP100810: Hid the data folder path custom control. Made "Use a Texture to display the image" the default Image Type.
 
// ====================== GUI (Panel) routines =========================

static StrConstant ksPanelName="AppendImageToGizmoPanel"

static Constant kMinGizmoWidth= 250	// pixels
static Constant kMinGizmoHeight= 250	// pixels

//#define GIZMO_IMAGE_DEBUGGING

// Main Public Routine
Function WMGizmoImagePanel()	// Also see UpdateGizmoImagePanel() and NewGizmoImage()

	DoWindow/F $ksPanelName
	if(V_Flag==0)
		NewPanel/N=$ksPanelName /W=(291,48,769,535)/K=1 as "Append Image to Gizmo"
		ModifyPanel fixedSize=1, noEdit=1
		DefaultGuiFont/W=#/Mac popup={"_IgorMedium",12,0},all={"_IgorMedium",12,0}
		DefaultGuiFont/W=#/Win popup={"_IgorMedium",0,0},all={"_IgorMedium",0,0}

		// Transfer panel-specific control settings from globals (or defaults) to controls here.
	
		// NOTE: transfer control settings from image-specific globals (or defaults) to controls in UpdateGizmoImagePanel(),
		// NOT here.

		// debugging controls
		//Button debugShowAll pos={360,8}, size={175,20},proc=GizmoAppendImage#ShowAllControlsButtonProc,title="Show All Controls"
		//Button showProcedure pos={167,460}, size={140,20},proc=GizmoAppendImage#ShowProcedureFileButtonProc,title="Show Procedure File"
		//Button updatePanel,pos={435,36},size={100,20},proc=GizmoAppendImage#DebuggingUpdatePanelButtonProc,title="Update Panel"

		String cmd

		String/G $PanelDFVar("topGizmo")
		CustomControl gizmoName pos={138,463}, size={180,15}, proc=GizmoAppendImage#GizmoLinkControlProc
		CustomControl gizmoName,fSize=9,frame=0, value=$PanelDFVar("topGizmo"), title=""
		CustomControl gizmoName, userData(mouseState)="Up"

		// controls at top
		String/G $PanelDFVar("dfPath")
		Variable top= 24
#ifdef GIZMO_IMAGE_DEBUGGING
		// debugging controls
		CustomControl dataFolder pos={22,8}, size={452,15}, proc=GizmoAppendImage#DataFolderLinkcontrolproc
		CustomControl dataFolder,fSize=9,frame=0, value=$PanelDFVar("dfPath"), title=""
		CustomControl dataFolder, userData(mouseState)="Up"
		top += 10
#endif

		PopupMenu imagesPopup,pos={21,top},size={210,20},title="Gizmo Images"
		PopupMenu imagesPopup,mode=1,popvalue="_new_",value= #"GizmoAppendImage#ListOfGizmoImages(\"\",1)"
		PopupMenu imagesPopup proc=GizmoAppendImage#GizmoImagesPopMenuProc

		Button removeImage,pos={280,top},size={120,20},proc=GizmoAppendImage#RemoveImageButtonProc,title="Remove..."

		// tab control
		
		TabControl tab0,pos={13,68},size={451,355}
		TabControl tab0,tabLabel(0)="Image Source",tabLabel(1)="Image Type"
		TabControl tab0,tabLabel(2)="Placement",tabLabel(3)="Appearance"
		TabControl tab0,proc=GizmoAppendImage#TabProc, value= 0
		
		// This control appears in all tabs EXCEPT tab0
			TitleBox source,pos={172,103},size={139,12},disable=2,title="Image from surface0: root:twod"
			TitleBox source,fSize=9,frame=0,anchor= MT

		// tab 0: Image Source
		
			CheckBox fromSurface,pos={40,133},size={172,16},title="From Gizmo Matrix Surface"
			CheckBox fromSurface,value= 0,mode=1,proc=GizmoAppendImage#SourceRadioProc
			PopupMenu matrixSurfaces pos={218,133}, size={80,20},proc=GizmoAppendImage#MatrixSurfacesPopMenuProc
		
			CheckBox fromRGBWave,pos={39,169},size={147,16},title="From RGB Image Wave"
			CheckBox fromRGBWave,value= 0,mode=1,proc=GizmoAppendImage#SourceRadioProc

			// +++++ rgb wave selector button
			Button rgbWavePopupSelector pos={194,169}, size={145,20}, fSize=9
			cmd= "GizmoAppendImage#RGBWavePopupSelectorNotify"	// don't use GetIndependentModuleName()+"#": FUNCRefs aren't cross-IM
			MakeButtonIntoWSPopupButton(ksPanelName, "rgbWavePopupSelector", cmd, options=PopupWS_OptionFloat)	// float to avoid main panel activate hook events

			Variable sortKind= NumVarOrDefault(PanelDFVar("rgbSortKind"),WMWS_sortByName)
			Variable sortReverse= NumVarOrDefault(PanelDFVar("rgbSortReverse"),0)
			PopupWS_SetGetSortOrder(ksPanelName, "rgbWavePopupSelector", sortKind, sortReverse)

			cmd= "GizmoAppendImage#RGBWavePopupSelectorFilter"
			PopupWS_MatchOptions(ksPanelName, "rgbWavePopupSelector", nameFilterProc=cmd)
			// ------ rgb wave selector button
			
			// +++++ RGB Wave preview subwindow
			Display/W=(356,105,456,200)/HOST=# 
			ModifyGraph margin=-1
			ModifyGraph nticks=0,standoff=0,axThick=0,noLabel=2
			RenameWindow #,Preview
			SetActiveSubwindow ##
			SetWindow $(ksPanelName+"#Preview") hide=1, needUpdate=0
			// ------ RGB Wave preview subwindow

			Button loadRGBFromFile,pos={62,206},size={230,20},title="Load RGB Image Wave from File...",proc=GizmoAppendImage#LoadRGBFileButtonProc
		
			// +++++ Make RGB from Graph
			CheckBox showMakeRGBfromGraphControls,pos={75,234},size={179,16},proc=GizmoAppendImage#ShowHideGraphRGBControlsCheck,title="Make RGB Wave from Graph"

			Variable/G $PanelDFVar("showMakeRGBfromGraphControls")	// defaults to 0, unchecked.
			CheckBox showMakeRGBfromGraphControls,mode=2, variable=$PanelDFVar("showMakeRGBfromGraphControls")

			// initially hidden controls, depending on stored value

			NVAR showMakeRGBfromGraphControls= $PanelDFVar("showMakeRGBfromGraphControls")
			Variable disable= showMakeRGBfromGraphControls ? 0 : 1
			GroupBox makeRGBGroup pos={37,253}, size={408,116},disable=disable

			PopupMenu graphWindowPopup pos={53,262}, size={71,20},disable=disable,proc=GizmoAppendImage#GraphWindowPopMenuProc
			cmd= GetIndependentModuleName()+"#GizmoAppendImage#ListOfGraphs(1)"
			PopupMenu graphWindowPopup,mode=1,value= #cmd

			CheckBox previewGraphCheck pos={224,264}, size={208,16},title="Choosing Graph brings it forward",disable=disable
			CheckBox previewGraphCheck,value= 1
			
			TitleBox graphTitle pos={108,289}, size={154,12},title="Graph0: wave0, wave1",fSize=9,frame=0,disable=disable

			Button resizeGraph pos={53,311}, size={250,20},proc=GizmoAppendImage#OptimizeGraphForRGBButtonProc,title="Optimize Graph Size for Texture",disable=disable
		
			String str= StrVarOrDefault(PanelDFVar("rgbWaveNamePrototype"),"rgbImage0")
			String/G $PanelDFVar("rgbWaveNamePrototype")= str
			SetVariable rgbWaveName,pos={51,340},size={290,19},bodyWidth=125,title="RGB Wave Name Prototype:",disable=disable
			SetVariable rgbWaveName,variable=$PanelDFVar("rgbWaveNamePrototype")

			Button makeRGBfromGraph pos={347,311}, size={80,20},proc=GizmoAppendImage#MakeRGBFromGraphButtonProc,title="Make RGB",disable=disable

			CheckBox overwriteRGB pos={351,342}, size={74,16},title="Overwrite",value= 0,disable=disable

			// -------- Make RGB from Graph

		// tab 1: Image Type
		
			CheckBox useSurface,pos={73,147},size={285,16},title="Use a Surface to display the image"
			CheckBox useSurface,value= 1,mode=1,proc=GizmoAppendImage#ImageTypeUseCheckProc

			GroupBox textureGroup,pos={65,176},size={343,82}

			CheckBox useTexture,pos={73,184},size={98,16},title="Use a Texture to display the image"
			CheckBox useTexture,value= 0,mode=1,proc=GizmoAppendImage#ImageTypeUseCheckProc

			PopupMenu textureWidthPop,pos={95,219},size={139,20},proc=GizmoAppendImage#TextureSizePopMenuProc,title="Width (pixels)"
			PopupMenu textureWidthPop,mode=1,popvalue="auto",value= #"\"auto;16;32;64;128;256;512;1024;2048;4096;\""
			
			PopupMenu textureHeightPop,pos={246,219},size={143,20},proc=GizmoAppendImage#TextureSizePopMenuProc,title="Height (pixels)"
			PopupMenu textureHeightPop,mode=1,popvalue="auto",value= #"\"auto;16;32;64;128;256;512;1024;2048;4096;\""
			
		// tab 2: Placement

			GroupBox placementGroup pos={77,127}, size={361,179}

			PopupMenu positionAxis,pos={90,132},size={261,20},proc=GizmoAppendImage#ImagePlacementPopMenuProc,title="Image Placement"
			cmd=GetIndependentModuleName()+"#GizmoAppendImage#ImagePlacementPopupList()"
			PopupMenu positionAxis, mode=1,value=#cmd

			PopupMenu coordinatesPopup,pos={137,158},size={169,20},proc=GizmoAppendImage#CoordinatesPopMenuProc,title="Coordinate System"
			cmd= GetIndependentModuleName()+"#GizmoAppendImage#ImageCoordinatesPopupList()"
			PopupMenu coordinatesPopup,mode=1,value=#cmd

			// These checkboxes need their title and enable state changed
			// change based on the value of PopupMenu positionAxis
			// and whether the image is from a surface or an RGB image
			CheckBox atMax,pos={137,185},size={192,16},title="at Z axis maximum (1.22629)"
			CheckBox atMax,value= 0,mode=1,proc=GizmoAppendImage#PlacementRadioCheckProc
	
			CheckBox atMin,pos={137,284},size={162,16},title="at Z axis minimum (-0.1)"
			CheckBox atMin,value= 0,mode=1,proc=GizmoAppendImage#PlacementRadioCheckProc
	
			CheckBox atSurfaceDataMax,pos={137,210},size={210,16},disable=2,title="at surface0 maximum (1.22629)"
			CheckBox atSurfaceDataMax,value= 0,mode=1,proc=GizmoAppendImage#PlacementRadioCheckProc
	
			CheckBox atSurfaceDataMin,pos={137,259},size={179,16},disable=2,title="at surface0 minimum (-0.1)"
			CheckBox atSurfaceDataMin,value= 0,mode=1,proc=GizmoAppendImage#PlacementRadioCheckProc
	
			CheckBox atUserValue,pos={137,235},size={41,16},title="at Z"
			CheckBox atUserValue,value= 0,mode=1,proc=GizmoAppendImage#PlacementRadioCheckProc
	
			SetVariable atValue pos={228,233}, size={150,19},proc=GizmoAppendImage#AtValueSetVarProc,title="="
			
			// Shim
			GroupBox shimGroup,pos={77,315},size={361,59}
			
			CheckBox shimCheck,pos={98,324},size={212,16},proc=GizmoAppendImage#ShimCheckProc,title="Offset image away from min/max"
			CheckBox shimCheck,value= 0
		
			SetVariable shimPercent,pos={117,347},size={139,19},bodyWidth=80,proc=GizmoAppendImage#ShimPctSetVarProc,title="Offset by"
			SetVariable shimPercent,format="%g %%",limits={0,100,0.125},value= shimPercent

			Button axisRange,pos={284,346},size={100,20},proc=GizmoAppendImage#AxisRangeButtonProc,title="Axis Range..."

			// RGB rotation
			PopupMenu rgbRotation pos={30,386}, size={159,20},proc=GizmoAppendImage#RGBRotatePopMenuProc,title="1. Rotate Image By"
			PopupMenu rgbRotation,mode=1,popvalue="0",value= #"\"0;90;180;270;\""
	
			// RGB Flip: rgbFlipH;rgbFlipV;
			CheckBox rgbFlipH pos={204,388}, size={126,16},proc=GizmoAppendImage#RGBImageFlipCheckProc,title="2. Flip Horizontally",value= 0
			CheckBox rgbFlipV pos={338,388}, size={111,16},proc=GizmoAppendImage#RGBImageFlipCheckProc,title="3. Flip Vertically",value= 0

			// Background controls
			CheckBox sizeGizmoToBackground,pos={115,201},size={238,16},proc=GizmoAppendImage#SizeToFitBackgroundCheckProc,title="Resize Gizmo to fit Background Image"
			CheckBox sizeGizmoToBackground,value= 0

		// tab 3: Appearance

			CheckBox useSurfaceColors,pos={132,150},size={156,16},title="Use colors from surface",proc=GizmoAppendImage#UseColorsRadioProc
			CheckBox useSurfaceColors,value= 1,mode=1

			CheckBox useConstantColor,pos={132,187},size={98,16},title="Use one Color",proc=GizmoAppendImage#UseColorsRadioProc
			CheckBox useConstantColor,value= 0,mode=1

			PopupMenu constantColorPop,pos={242,185},size={50,20},proc=GizmoAppendImage#ConstantColorPopMenuProc
			PopupMenu constantColorPop,mode=1,popColor= (32768,40777,65535),value= #"\"*COLORPOP*\""
			
			SetVariable alpha pos={135,224}, size={103,19},bodyWidth=60,proc=GizmoAppendImage#AlphaSetVarProc,title="Alpha*"
			SetVariable alpha,limits={0.05,1,0.05}

			TitleBox alphaTitle,pos={167,256}, size={175,13},title="\\JC* (0.0 = transparent, 1.0 = opaque)"
			TitleBox alphaTitle,fSize=10,frame=0

			// Clipped
			CheckBox clipped pos={136,286}, size={235,16},title="Clipped (unchecked is recommended)"
			CheckBox clipped,value= 0,proc=GizmoAppendImage#ClippedCheckProc
			
		// controls at bottom
		Button appendUpdateImage,pos={271,433},size={110,20},title="Update Image"
		Button appendUpdateImage,proc=GizmoAppendImage#AddOrUpdateButtonProc

		Button gizmoInfo,pos={13,460},size={84,20},title="Gizmo Info",proc=GizmoAppendImage#GizmoInfoButtonProc
		
		Variable updateOnChange= NumVarOrDefault(PanelDFVar("updateOnChange"),1)
		CheckBox updateOnChange,pos={117,435},size={133,16},title="Update Immediately",proc=GizmoAppendImage#UpdateOnChangeCheckProc
		CheckBox updateOnChange,value= updateOnChange
	
		Button help,pos={401,460},size={60,20},title="Help",proc=GizmoAppendImage#GizmoHelpButtonProc
		
		// Show/Hide controls for showing tab
		ControlInfo/W=$ksPanelName tab0
		Variable tabNum= V_Value
		TabProc("tab0",tabNum)
		
		// Set up hook
		SetWindow $ksPanelName hook(GizmoImage)=GizmoAppendImage#GIzmoAppendImagePanelWindowHook
		String dfName= UpdateGizmoImagePanel() // we're already activated, update controls from the top gizmo manually
		if( strlen(dfName) )
			String gizmoName= TopGizmo()
			if( ValidGizmoName(gizmoName) )
				AutoPositionWindow/M=0/R=$gizmoName $ksPanelName
			endif
		endif
	// else
	// the activate event from DoWindow/F will call UpdateGizmoImagePanel()

	endif
End

static Function/S UpdateGizmoImagePanel()

	DoWindow $ksPanelName
	if( V_Flag == 0 )
		return ""
	endif

	String allControls= ControlNameList(ksPanelName, ";", "*")
	allControls= RemoveFromList("dataFolderPath;gizmoName;help;showProcedure;debugShowAll", allControls)
	String gizmoName=TopGizmo()	// can be ""
	String/G $PanelDFVar("topGizmo")= gizmoName	// for GetPanelGizmoImage and CustomControl gizmoName
	
	// controls at top and bottom

	String wmImagesList= ListOfGizmoImages(gizmoName,0)
	Variable numImages= ItemsInList(wmImagesList)
	String imageName= StrVarOrDefault(GizmoDFVar(gizmoName,"wmImageName"), "_new_")
	if( numImages )	// see if imageName is in the list (it might have been removed)
		Variable index= WhichListItem(imageName, wmImagesList+"_new_;")	// -1 if not found
		if( index < 0 )
			imageName=StringFromList(numImages-1,wmImagesList)
		endif
	else
		imageName="_new_"
	endif
	String/G $GizmoDFVar(gizmoName,"wmImageName")= imageName

	wmImagesList= ListOfGizmoImages(gizmoName,1)
	Variable mode= 1+WhichListItem(imageName, wmImagesList)

	String cmd= GetIndependentModuleName()+"#GizmoAppendImage#ListOfGizmoImages(\"" + gizmoName + "\", 1)"
	PopupMenu imagesPopup, win=$ksPanelName,mode=mode, popvalue=imageName, value= #cmd

	Variable isNew= CmpStr(imageName,"_new_") == 0
	if( isNew )
		ModifyControl removeImage, win=$ksPanelName, disable=2	 // show disabled
		CheckBox updateOnChange, win=$ksPanelName, disable=1	// Hide the Update immediately checkbox
		Button appendUpdateImage,win=$ksPanelName,title="Append Image"
		imageName= "Nascent"	// place to put control values when the contour doesn't exist, yet.
	else
		ModifyControl removeImage, win=$ksPanelName, disable=0	 // show enabled
		CheckBox updateOnChange, win=$ksPanelName, disable=0	// Show the Update immediately checkbox
		Button appendUpdateImage,win=$ksPanelName,title="Update Image"
	endif
	
	// We now have the gizmo and image name.
	// Update the remaining controls from the global variables in GizmoImageDFVar(gizmoName,imageName,varName)

	String/G $PanelDFVar("dfPath")= GizmoImageDF(gizmoName, imageName)
#ifdef GIZMO_IMAGE_DEBUGGING
	ControlUpdate/W=$ksPanelName dataFolder
#endif

// Tab 0: Image Source
	
	// Source radio buttons
	String sourceRadio= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"sourceRadio"), "fromSurface")
	SetRadioGroup(sourceRadio, "fromSurface;fromRGBWave;")
	String/G $GizmoImageDFVar(gizmoName,imageName,"sourceRadio")= sourceRadio

	// Surface popup
	String list= GetGizmoMatrixSurfaceList(gizmoName)
	String surfaceName= StringFromList(0,list)
	String fromSurfaceName= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"fromSurfaceName"), surfaceName)
	mode= 1+WhichListItem(fromSurfaceName, list)
	if( mode <= 0 )
		fromSurfaceName= surfaceName
		mode= 1
	endif
	cmd= GetIndependentModuleName()+"#GizmoAppendImage#GetGizmoMatrixSurfaceList(\"" + gizmoName + "\")"
	PopupMenu matrixSurfaces,win=$ksPanelName,mode=mode, popvalue=fromSurfaceName,value= #cmd
	String/G $GizmoImageDFVar(gizmoName,imageName,"fromSurfaceName")= fromSurfaceName
	
	// RGB popup wave browser
	String pathToRGBWave=StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"rgbWavePath"),"")
	WAVE/Z w= $pathToRGBWave
	if( WaveExists(w) )
		PopupWS_SetSelectionFullPath(ksPanelName, "rgbWavePopupSelector", pathToRGBWave)
	else
		pathToRGBWave= PopupWS_GetSelectionFullPath(ksPanelName, "rgbWavePopupSelector")
	endif
	String/G $GizmoImageDFVar(gizmoName,imageName,"rgbWavePath")= pathToRGBWave

	// Surface/RGB wave preview
	UpdateSourcePreview(gizmoName, imageName)

	// Graph popup
	list= ListOfGraphs(1)
	String graphName= StringFromList(0,list)
	String fromGraphName= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"fromGraphName"), graphName)
	mode= 1+WhichListItem(fromGraphName, list)
	if( mode <= 0 )
		fromGraphName= graphName	// can be "_none_"
		mode= 1
	endif
	PopupMenu graphWindowPopup,win=$ksPanelName,mode=mode, popvalue=fromGraphName
	String/G $GizmoImageDFVar(gizmoName,imageName,"fromGraphName")= fromGraphName

	UpdateGraphTitle(fromGraphName)

// Tab 1: Image Type
//	String useRadio= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"useRadio"), "useSurface")
	String useRadio= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"useRadio"), "useTexture")	// uses less memory

	// ImageTypeUseCheckProc(useRadio,1)	this calls ImageNeedsUpdate
	SetRadioGroup(useRadio, "useSurface;useTexture;")
	String/G $GizmoImageDFVar(gizmoName,imageName,"useRadio")= useRadio
	
//	popup list is "auto;16;32;64;128;256;512;1024;2048;4096;"
	Variable texWidth= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"textureWidthPop"), NaN)	// NaN is "auto"
	String popMatch= SelectString(numtype(texWidth) == 0, "auto", num2istr(texWidth))
	PopupMenu textureWidthPop, win=$ksPanelName, popmatch=popmatch
	Variable/G $GizmoImageDFVar(gizmoName,imageName,"textureWidthPop")= texWidth
	
	Variable texHeight= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"textureHeightPop"), NaN)	// NaN is "auto"
	popMatch= SelectString(numtype(texHeight) == 0, "auto", num2istr(texHeight))
	PopupMenu textureHeightPop, win=$ksPanelName, popmatch=popmatch
	Variable/G $GizmoImageDFVar(gizmoName,imageName,"textureHeightPop")= texHeight
	
//	UpdateImageTypeControls()	Do this later because they depend on the placement.
	
// Tab 2: Placement
	String placement= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"imagePlacement"), "XY")
	mode= 1 + WhichItemIsPlacement(placement)
	PopupMenu positionAxis, win=$ksPanelName, mode=mode
	String/G $GizmoImageDFVar(gizmoName,imageName,"imagePlacement")=placement
	
	String coordinates= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"coordinates"), "Data")
	mode= 1 + WhichListItem(coordinates,ksCoordinatesList)
	PopupMenu coordinatesPopup, win=$ksPanelName, mode=mode
	String/G $GizmoImageDFVar(gizmoName,imageName,"coordinates")=coordinates
	
	String atPlacementRadio= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"atPlacementRadio"), "atMin")
	SetRadioGroup(atPlacementRadio, "atMax;atSurfaceDataMax;atUserValue;atSurfaceDataMin;atMin;")
	String/G $GizmoImageDFVar(gizmoName,imageName,"atPlacementRadio")= atPlacementRadio

	UpdatePlacementControls(placement,coordinates)	// may change atPlacementRadio and SetVariable atValue, too

	Variable shimChecked= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"shimChecked"),1)
	Variable/G $GizmoImageDFVar(gizmoName,imageName,"shimChecked")= shimChecked
	CheckBox shimCheck,variable=$GizmoImageDFVar(gizmoName,imageName,"shimChecked")

	Variable shimPct= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"shimPct"),1)
	Variable/G $GizmoImageDFVar(gizmoName,imageName,"shimPct")= shimPct
	SetVariable shimPercent, variable=$GizmoImageDFVar(gizmoName,imageName,"shimPct")

	Variable rotation= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"rgbRotateBy"), 0)
	mode= 1 + round(rotation/90)	// 0,90,180,270
	PopupMenu rgbRotation, win=$ksPanelName, mode=mode
	Variable/G $GizmoImageDFVar(gizmoName,imageName,"rgbRotateBy")= rotation
	
	Variable checked= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"rgbFlipH"), 0)
	Variable/G $GizmoImageDFVar(gizmoName,imageName,"rgbFlipH")= checked
	CheckBox rgbFlipH,win=$ksPanelName,variable=$GizmoImageDFVar(gizmoName,imageName,"rgbFlipH")
	
	checked= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"rgbFlipV"), 0)
	Variable/G $GizmoImageDFVar(gizmoName,imageName,"rgbFlipV")= checked
	CheckBox rgbFlipV,win=$ksPanelName,variable=$GizmoImageDFVar(gizmoName,imageName,"rgbFlipV")

	// Background placements
	checked= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"sizeGizmoToBackground"), 0)
	Variable/G $GizmoImageDFVar(gizmoName,imageName,"sizeGizmoToBackground")= checked
	CheckBox sizeGizmoToBackground,win=$ksPanelName,variable=$GizmoImageDFVar(gizmoName,imageName,"sizeGizmoToBackground")

	UpdateImageTypeControls()	// deferred until now because they depend on the placement.

// Tab 3: Colors

	String useColorsRadio= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"useColorsRadio"), "useSurfaceColors")
	SetRadioGroup(useColorsRadio, "useSurfaceColors;useConstantColor;")
	String/G $GizmoImageDFVar(gizmoName,imageName,"useColorsRadio")= useColorsRadio
	
	Variable constantRed= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"constantRed"),32768)	// these colors define a medium baby blue
	Variable constantGreen= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"constantGreen"),40777)
	Variable constantBlue= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"constantBlue"),65535)
	PopupMenu constantColorPop,mode=1,popColor= (constantRed,constantGreen,constantBlue)
	Variable/G $GizmoImageDFVar(gizmoName,imageName,"constantRed")= constantRed
	Variable/G $GizmoImageDFVar(gizmoName,imageName,"constantGreen")= constantGreen
	Variable/G $GizmoImageDFVar(gizmoName,imageName,"constantBlue")= constantBlue

	Variable imageAlpha= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"imageAlpha"),1)
	Variable/G $GizmoImageDFVar(gizmoName,imageName,"imageAlpha")= imageAlpha
	SetVariable alpha, win=$ksPanelName, variable= $GizmoImageDFVar(gizmoName,imageName,"imageAlpha")

	Variable clipped= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"clipped"), 0)
	CheckBox clipped,win=$ksPanelName, value=clipped
	Variable/G $GizmoImageDFVar(gizmoName,imageName,"clipped")= clipped

	UpdateColorsTabControls()

	String dfName= GetPackagePerGizmoDFName(gizmoName,ksPackageName)
	return dfName	// NOT the gizmoName, it's the data folder name in root:Packages:GizmoImages:PerGizmoData:
End

// Panel hook
Static Function GIzmoAppendImagePanelWindowHook(s)
	STRUCT WMWinHookStruct &s

	Variable rval= 0
	strswitch(s.eventName)
		case "activate":
// #if 0 is useful while developing the panel so that activation doesn't alter the control just changed by the just-deactivated dialog.
#if 1
			UpdateGizmoImagePanel()
#else
			Print "activate update not implemented. see GizmoAppendImagePanelWindowHook()."
#endif
			break
		case "kill":
			// remember RGB wave sorting
			Variable sortKind= -1, sortReverse = -1	// get values
			PopupWS_SetGetSortOrder(ksPanelName, "rgbWavePopupSelector", sortKind, sortReverse)
			Variable/G $PanelDFVar("rgbSortKind")= sortKind
			Variable/G $PanelDFVar("rgbSortReverse")= sortReverse
			// remember Update Immediately setting
			ControlInfo/W=$ksPanelName updateOnChange
			Variable/G $PanelDFVar("updateOnChange")= V_Value
			break
	endswitch

	return rval
End


// ====================== static utility routines =========================

//	Data Folder Hierarchy:
//	
//	PanelDF() =
//		root:Packages:GizmoImages:
//			<panel global (not image-specific) variables>
//	
//	GetGizmoDF("") =
//		root:Packages:GizmoImages:PerGizmoData:Defaults:
//	
//	GetGizmoDF(gizmoName) =
//		root:Packages:GizmoImages:PerGizmoData:GizmoData0:
//	
//	GizmoDFVar(gizmoName,varName) =
//		root:Packages:GizmoImages:PerGizmoData:GizmoData0:varName
//	
//	 GizmoImageDF(gizmoName, imageName) =
//		root:Packages:GizmoImages:PerGizmoData:GizmoData0:imageName
//			<all the per-image settings>
//			If the image doesn't exist yet, then:
//		root:Packages:GizmoImages:PerGizmoData:GizmoData0:Nascent
//	
//	GizmoImageDFVar(gizmoName,imageName,varName) =
//		root:Packages:GizmoImages:PerGizmoData:GizmoData0:imageName:varName
//
//			The controls directly manipulate theses variable or strings,
//			which are used to create a new or modify the selected image.

// ----------------------------------- Panel-specific variables -----------------------------------

static StrConstant ksPackagePath= "root:Packages:GizmoImages"
static StrConstant ksPackageName = "GizmoImages"

Static Function/S PanelDF()
	NewDataFolder/O root:Packages
	NewDataFolder/O $ksPackagePath
	return ksPackagePath
End

Static Function/S PanelDFVar(varName)
	String varName
	
	return PanelDF()+":"+PossiblyQuoteName(varName)
End

// Set the data folder to a place where Execute can dump all kinds of variables and waves.
// Returns the old data folder.
Static Function/S SetPanelDF()

	String oldDF= GetDataFolder(1)
	NewDataFolder/O/S $PanelDF()	// DF is left pointing here to an existing or created data folder.
	return oldDF
End

Static Function IsMacintosh()

	String platform= IgorInfo(2)
	return CmpStr(platform,"Macintosh") == 0
End

// ----------------------------------- Per-Gizmo data folders and variables -----------------------------------


// the data folder may not yet exist.
// returns full path to the gizmo-specific data folder.
Static Function/S GetGizmoDF(gizmoName)
	String gizmoName

	ValidGizmoName(gizmoName)	// if "", set gizmoName to top Gizmo's name
	String df= PackagePerGizmoDFVar(gizmoName,ksPackageName,"")	// "" if no gizmo by that name, else "root:Packages:GizmoImages:PerGizmoData:dfName"
	if( strlen(df) == 0 )
		df= PanelDF()+":Defaults"	// for controls before a gizmo window has been created (or after they've all gone away)
	endif
	NewDataFolder/O $df
	return df
End

// Changes data folder to the PerGizmo data folder and returns the old data folder.
static Function/S SetGizmoDF(gizmoName)
	String gizmoName
	
	String oldDF= GetDataFolder(1)
	String df= GetGizmoDF(gizmoName)
	NewDataFolder/O/S $df
	
	return oldDF
End

// Returns the path to gizmo-specific variable, string or wave, which may not exist.
static Function/S GizmoDFVar(gizmoName,varName)
	String gizmoName,varName
	
	return GetGizmoDF(gizmoName)+":"+PossiblyQuoteName(varName)
End

// returns number of parameters successfully retrieved: 1, or 2 or on error 0 is returned.
static Function GetPanelGizmoImage(gizmoName, imageName)
	String &gizmoName, &imageName	// outputs
	
	Variable numGot= 0
	gizmoName= ""
	imageName= ""
	SVAR/Z gn= $PanelDFVar("topGizmo")
	if( SVAR_Exists(gn) && strlen(gn) )
		gizmoName= gn
		numGot += 1
		SVAR/Z in= $GizmoDFVar(gizmoName, "wmImageName")
		if( SVAR_Exists(in) && strlen(in) )
			if( CmpStr(in,"_new_") == 0 )
				imageName= "Nascent"	// this is the corresponding data folder name.
			else
				imageName= in
			endif
			numGot += 1
		endif		
	endif
	return numGot
End
	
// ===================== WMImageGroup-related utilities ==============

//	To identify the image elements in Gizmo, each "image" object is placed in a group, with a name of "WMImageGroup<number>"
//	
//		AppendToGizmo group,name=WMImageGroup0
//		
//		// ************************* Group Object Start *******************
//		ModifyGizmo currentGroupObject="WMImageGroup0"
//
//		<stuff here>
//
//		ModifyGizmo currentGroupObject="::"
//	
//		// ************************* Group Object End *******************
//		
//		AppendToGizmo attribute color={0,0,0,1},name=black
//	
//
// The group contains the surface/quad objects.

// Each Gizmo may have multiple images.
// Returns the path to the image-specific data folder, creating it if necessary
static Function/S GizmoImageDF(gizmoName, imageName)
	String gizmoName, imageName
	
	String df= GetGizmoDF(gizmoName)	// root:Packages:GizmoImages:PerGizmoData:GizmoData0 or root:Packages:GizmoImages:Defaults
	if( strlen(imageName) )
		df += ":" + imageName	// root:Packages:GizmoImages:PerGizmoData:GizmoData0:image0, etc
	endif
	NewDataFolder/O $df
	return df
End

// Returns the path to imageName-specific variable, string or wave, which may not exist.
static Function/S GizmoImageDFVar(gizmoName,imageName,varName)
	String gizmoName,imageName,varName
	
	return GizmoImageDF(gizmoName,imageName)+":"+PossiblyQuoteName(varName)
End

static Function/S ListOfGizmoImages(gizmoName,includeNew)
	String gizmoName
	Variable includeNew
	
	String groups= SortList(GetGizmoGroupObjects(gizmoName, "", "WMImageGroup*"),";",16)
	if( includeNew )
		groups += "_new_;"
	endif
	return groups
End

// ====================== Images from RGB waves =========================

static Function/S CreateRGBWaveFromGraph(graphName, outputWaveName)
	String graphName, outputWaveName
	
	String pathToCreatedRGBWave=""
	if( strlen(graphName) )
		DoWindow $graphName
		if( V_Flag )
			Variable wantAlpha= 0
			Variable setWhiteTransparent= 0
			Wave/Z w= CreateRGBImageOfGraph(graphName,outputWaveName,wantAlpha=wantAlpha)
			if( WaveExists(w) )
				pathToCreatedRGBWave= GetWavesDataFolder(w,2)
			endif
		endif
	endif
	return pathToCreatedRGBWave
End

// Creates a parametric surface wave from a 2D image, colored by a created color wave
// and positioned perpendicular to the given plane with the given or default extent.
//
// Compare to MakeGizmoSurfaceProjectionImage() and MakeGizmoXY2DRGBImage()
//
// Returns truth of success.

Function MakeGizmoParametricRGBImage(gizmoName, wrgb, perpendicularPlane, parametricSurfaceWaveOutName, rgbaColorWaveOutName, planeConstant[,alpha,rotation,flipHoriz,flipVert,xmin,xmax,ymin,ymax,zmin,zmax])
	String gizmoName
	Wave wrgb				// create a parametric surface and a color wave from this wave.
	String perpendicularPlane		// "X", "Y", "Z" not likely: that's handled by MakeGizmoXY2DRGBImage(), and "Background" requires ortho coordinates, which a parametric surface can't do.
	String parametricSurfaceWaveOutName, rgbaColorWaveOutName	// names to use to create the surface and color waves
	Variable planeConstant			// where to place the image. If perpendicularPlane = "X", give an x value, if not x (if a y projection), give a y value. Pass +Inf for plane's max value, -Inf for min value
	Variable alpha					// optional, default is 1
	Variable rotation				// optional, in degrees, default is 0
	Variable flipHoriz,flipVert		// optional, default is false
	Variable xmin,xmax,ymin,ymax,zmin,zmax	// optional, default is to get the values from the X, Y and Z axis extents

	if( !ValidGizmoName(gizmoName) || !WaveExists(wrgb) )
		return 0
	endif
	
	Variable originalLayers= DimSize(wrgb,2)
	if( originalLayers < 3 )
		return 0
	endif
	
	// Create a parametric surface wave, one xyz point per color RGB wave point.
	// for a parametric surface, the source wave is 3D with each layer containing the X, Y, and Z values.
	Duplicate/O wrgb, $parametricSurfaceWaveOutName/WAVE=flatSurface

	if( !ParamIsDefault(rotation) && rotation != 0 )
		switch(rotation)
			case 90:
				ImageRotate/C/O flatSurface
				break
			case 180:
				ImageRotate/F/O flatSurface
				break
			case 270:
				ImageRotate/W/O flatSurface
				break
		endswitch
	endif
	if( !ParamIsDefault(flipHoriz) && flipHoriz )
		ImageRotate/H/O flatSurface
	endif
	
	if( !ParamIsDefault(flipVert) && flipVert )
		ImageRotate/V/O flatSurface
	endif

	Redimension/S flatSurface

	// create the color wave
	Duplicate/O flatSurface, $rgbaColorWaveOutName/WAVE=rgba	// 0-255
	rgba /= 255				// 0-1.0
	if( originalLayers == 3 )	// wave didn't have alpha channel, use a constant alpha
		if( ParamIsDefault(alpha) )
			alpha= 1
		endif
		Redimension/N=(-1,-1,4) rgba
		MultiThread rgba[][][3]= alpha
	endif

	// position the flat surface
	Variable gizmoXMin, gizmoXMax, gizmoYMin, gizmoYMax, gizmoZMin, gizmoZMax
	if( !GetGizmoAxisRanges(gizmoName, gizmoXMin, gizmoXMax, gizmoYMin, gizmoYMax, gizmoZMin, gizmoZMax) )
		return 0	// should never happen
	endif
	xmin= ParamIsDefault(xmin) ? gizmoXMin : xmin
	xmax= ParamIsDefault(xmax) ? gizmoXMax : xmax
	ymin= ParamIsDefault(ymin) ? gizmoYMin : ymin
	ymax= ParamIsDefault(ymax) ? gizmoYMax : ymax
	zmin= ParamIsDefault(zmin) ? gizmoZMin : zmin
	zmax= ParamIsDefault(zmax) ? gizmoZMax : zmax

	Redimension/N=(-1,-1,3) flatSurface
	Variable constantLayerDim, delta
	strswitch( perpendicularPlane )
		case "X":
			// flatSurface[][][0], the X values of the surface = planeConstant
			constantLayerDim= 0

			// flatSurface[][][1], the Y values of the surface are set to ymin...ymax
			delta= (ymax-ymin)/(DimSize(flatSurface,0)-1)
			MultiThread flatSurface[][][1]= ymin+p*delta

			// flatSurface[][][2], the Z values of the surface are set to zmin...zmax
			delta= (zmax-zmin)/(DimSize(flatSurface,1)-1)
			MultiThread flatSurface[][][2]= zmin+q*delta
			break
		case "Y":
			// flatSurface[][][0], the X values of the surface are set to xmin...xmax
			delta= (xmax-xmin)/(DimSize(flatSurface,0)-1)
			MultiThread flatSurface[][][0]= xmin+p*delta

			// flatSurface[][][1], the Y values of the surface = planeConstant
			constantLayerDim= 1

			// flatSurface[][][2], the Z values of the surface are set to zmin...zmax
			delta= (zmax-zmin)/(DimSize(flatSurface,1)-1)
			MultiThread flatSurface[][][2]= zmin+q*delta
			break
		case "Z":
			// flatSurface[][][0], the X values of the surface are set to xmin...xmax
			delta= (xmax-xmin)/(DimSize(flatSurface,0)-1)
			MultiThread flatSurface[][][0]= xmin+p*delta

			// flatSurface[][][1], the Y values of the surface are set to ymin...ymax
			delta= (ymax-ymin)/(DimSize(flatSurface,0)-1)
			MultiThread flatSurface[][][1]= ymin+p*delta

			// flatSurface[][][2], the Z values of the surface = planeConstant
			constantLayerDim= 2
			break
	endswitch
	
	MultiThread flatSurface[][][constantLayerDim]= planeConstant

	return 1
End

// This method creates a flat parametric surface colored by a color wave,
// and is necessarily positioned in data space.
//
// Returns truth of success.
//
// Waves are created in the current data folder, which normally is GizmoImageDF(gizmoName, imageGroupName)
//
// See Also: MakeGizmoXY2DSurfaceImage()
//
Function MakeGizmoXY2DRGBImage(gizmoName, wrgb, matrixSurfaceWaveOutName, rgbaColorWaveOutName, zValue [,alpha,rotation,flipHoriz,flipVert,xmin,xmax,ymin,ymax])
	String gizmoName
	Wave wrgb				// create a parametric surface and a color wave from this wave.
	String matrixSurfaceWaveOutName, rgbaColorWaveOutName	// names to use to create the surface and color waves
	Variable zValue				// z data value where the plane is positioned.
	Variable alpha					// optional, default is 1
	Variable rotation				// optional, in degrees, default is 0
	Variable flipHoriz,flipVert		// optional, default is false
	Variable xmin,xmax,ymin,ymax	// optional, default is to get the values from the X and Y axis extents

	if( !ValidGizmoName(gizmoName) || !WaveExists(wrgb) )
		return 0
	endif
	
	Variable originalLayers= DimSize(wrgb,2)
	if( originalLayers < 3 )
		return 0
	endif
	
	// Create a "flat" surface wave, one xy point per color RGB wave point.
	Duplicate/O wrgb, $matrixSurfaceWaveOutName/WAVE=flatWave

	if( !ParamIsDefault(rotation) && rotation != 0 )
		switch(rotation)
			case 90:
				ImageRotate/C/O flatWave
				break
			case 180:
				ImageRotate/F/O flatWave
				break
			case 270:
				ImageRotate/W/O flatWave
				break
		endswitch
	endif

	if( !ParamIsDefault(flipHoriz) && flipHoriz )
		ImageRotate/H/O flatWave
	endif
	
	if( !ParamIsDefault(flipVert) && flipVert )
		ImageRotate/V/O flatWave
	endif
	
	Redimension/S flatWave

	// create the color wave
	Duplicate/O flatWave, $rgbaColorWaveOutName/WAVE=rgba	// 0-255
	rgba /= 255				// 0-1.0
	if( originalLayers == 3 )	// wave didn't have alpha channel, use a constant alpha
		if( ParamIsDefault(alpha) )
			alpha= 1
		endif
		Redimension/N=(-1,-1,4) rgba
		MultiThread rgba[][][3]= alpha
	endif

	Redimension/N=(-1,-1,0) flatWave
	MultiThread flatWave= zValue

	// set the X and Y extent
	Variable gizmoXMin, gizmoXMax, gizmoYMin, gizmoYMax, gizmoZMin, gizmoZMax
	GetGizmoAxisRanges(gizmoName, gizmoXMin, gizmoXMax, gizmoYMin, gizmoYMax, gizmoZMin, gizmoZMax)
	xmin= ParamIsDefault(xmin) ? gizmoXMin : xmin
	xmax= ParamIsDefault(xmax) ? gizmoXMax : xmax
	ymin= ParamIsDefault(ymin) ? gizmoYMin : ymin
	ymax= ParamIsDefault(ymax) ? gizmoYMax : ymax
	SetScale/I x, xmin,xmax, "", flatWave
	SetScale/I y, ymin,ymax, "", flatWave

	
	return 1
End


// See also:
//	MakeGizmoParametricRGBImage()
//	MakeAppendXY2DSurfaceTexture()

// Returns  quadOutName+";"+textureObject+";"+opName+";"+quadWaveName+";"	// quadWaveName will be "" if isAtOrthoValue is true.
Function/S MakeAppendRGBImageTexture(gizmoName, wrgb, perpendicularPlane, quadOutName, textureWaveOutName, isAtOrthoValue, atValue[,alpha,rotation,flipHoriz,flipVert,xmin,xmax,ymin,ymax,zmin,zmax,textureWidthPixels, textureHeightPixels,clipped])
	String gizmoName
	Wave wrgb					// create a parametric quad surface or ortho quad and a texture wave from this wave, which has values from 0-255.
	String perpendicularPlane	// "X", "Y", "Z", or "Background" ("Background" requires ortho coordinates, which a parametric surface can't do.)
	String quadOutName, textureWaveOutName	// names to use to create the quad (whether object quad or parametric surface "quad") and texture wave
	Variable isAtOrthoValue		// if true, position the plane in the ortho coordinate space (create an object quad), else use data space and a data quad.
	Variable atValue				// if isAtOrthoValue, atValus is the orth z value where the plane is positioned, else z data value.
	Variable alpha					// optional, default is 1
	Variable rotation				// optional, in degrees, default is 0
	Variable flipHoriz,flipVert		// optional, default is false
	Variable xmin,xmax,ymin,ymax,zmin,zmax	// optional, default is to get the values from the X, Y and Z axis extents
	Variable textureWidthPixels, textureHeightPixels	// Omit or set to NaN to get auto (the size of the surface matrix).
	Variable clipped								// optional, default is 0 (not clipped)
	
	if( !ValidGizmoName(gizmoName) || !WaveExists(wrgb) )
		return ""
	endif
	
	Variable originalLayers= DimSize(wrgb,2)
	if( originalLayers < 3 )
		return ""
	endif

	// Create a texture wave from the RGB(A) wave
	String outName= CleanupName(NameOfWave(wrgb)[0,26]+"_tmp",0)
	Duplicate/O wrgb, $outName/WAVE=rgbaWave

	//Transparency
	if( originalLayers == 3 )	// wave didn't have alpha channel, use a constant alpha
		if( ParamIsDefault(alpha) )
			alpha= 1
		endif
		Variable bigAlpha = alpha * 255
		Redimension/U/B/N=(-1,-1,4) rgbaWave
		MultiThread rgbaWave[][][3]= bigAlpha
	else
		Redimension/U/B rgbaWave	// keep original alpha layer intact, could multiply with alpha.
	endif
	
	// Interpolate for a texture, THEN rotate/flip, etc.
	if( ParamIsDefault(textureWidthPixels) || numtype(textureWidthPixels) != 0 )
		textureWidthPixels= DimSize(rgbaWave,0)	// original dimensions
		if( textureWidthPixels < 16 )
			textureWidthPixels= 16
		endif
	endif
	if( ParamIsDefault(textureHeightPixels) || numtype(textureHeightPixels) != 0 )
		textureHeightPixels= DimSize(rgbaWave,1)
		if( textureHeightPixels < 16 )
			textureHeightPixels= 16
		endif
	endif
	InterpolateForTexture(rgbaWave,outName,newWidthRows=textureWidthPixels,newHeightCols=textureHeightPixels)	// NULL if no interpolation needed, or error
	Redimension/U/B rgbaWave			// ensure unsigned byte, suitable for ImageTransform imageToTexture

	// Rotate, Flip
	if( !ParamIsDefault(rotation) && rotation != 0 )
		switch(rotation)
			case 90:
				ImageRotate/C/O rgbaWave
				break
			case 180:
				ImageRotate/F/O rgbaWave
				break
			case 270:
				ImageRotate/W/O rgbaWave
				break
		endswitch
	endif
	if( !ParamIsDefault(flipHoriz) && flipHoriz )
		ImageRotate/H/O rgbaWave
	endif
	
	if( !ParamIsDefault(flipVert) && flipVert )
		ImageRotate/V/O rgbaWave
	endif

	// create the texture
	// ImageTransform imageToTexture needs a unsigned byte wave filled with 0-255, which presumably is what's in the original wave
	textureWidthPixels= DimSize(rgbaWave,0)	// interpolated and rotated dimensions
	textureHeightPixels= DimSize(rgbaWave,1)
	WAVE texture= CreateTextureFromRGB(rgbaWave, textureWaveOutName)

	// create an object quad (if ortho coordinates) or a parametric surface that defines a single quad (if data)
	if( ParamIsDefault(clipped) )
		clipped= 0
	endif
	String quadWaveName=""
	String planeStr= perpendicularPlane

	if( isAtOrthoValue )
		// adds the ortho quad, but not the texture. The quad, however, IS prepared to render using a texture.
		AddGizmoOrthoQuadPlane(gizmoName,planeStr,atValue,quadName=quadOutName,clipped=clipped)
	else
		// data quad
		// we need a wave as well as an object.
		quadWaveName= CleanupName(NameOfWave(wrgb)[0,25]+"_quad",0)
		AddGizmoDataQuadPlane(gizmoName,planeStr,quadWaveName=quadWaveName,constantDataVal=atValue,quadSurfaceName=quadOutName,clipped=clipped)
	endif
	
	// append the texture and set it's rendering (SCoordinates, TCoordinates, etc) appropriate for the plane.
	Variable minDim= min(textureWidthPixels,textureHeightPixels)
	Variable doNearestNeighbor= minDim <= 256
	String textureObject= AddGizmoTextureForPlane(gizmoName, texture, planeStr, hasAlpha=1,widthPixels=textureWidthPixels, heightPixels=textureHeightPixels,textureName=textureWaveOutName,doNearestNeighbor=doNearestNeighbor)
	
	// Display the texture and then the quad, then clear the texture:
	String cmd
	Variable isBackground= CmpStr(planeStr,"Background") == 0
	if( isBackground )
		sprintf cmd,"ModifyGizmo/N=%s insertDisplayList=0, opName=loadIdentity0, operation=loadIdentity",gizmoName
		Execute cmd
	else
		RemoveMatchingGizmoDisplay(gizmoName,"loadIdentity0")
	endif
	
	// enable GL_TEXTURE_2D
	sprintf cmd,"ModifyGizmo/N=%s setDisplayList=-1, opName=enableTexture, operation=enable, data=3553",gizmoName
	Execute cmd
	
	sprintf cmd,"ModifyGizmo/N=%s setDisplayList=-1, object=%s",gizmoName,textureWaveOutName
	Execute cmd

	sprintf cmd,"ModifyGizmo/N=%s setDisplayList=-1, object=%s",gizmoName,quadOutName
	Execute cmd

	// disable GL_TEXTURE_2D
	sprintf cmd,"ModifyGizmo/N=%s setDisplayList=-1, opName=disableTexture, operation=disable, data=3553",gizmoName
	Execute cmd

	String opName= UniqueGizmoObjectName(gizmoName,"ClearTexture0","displayItemExists")
	sprintf cmd,"ModifyGizmo/N=%s setDisplayList=-1, opName=%s, operation=ClearTexture",gizmoName,opName
	Execute cmd

	return quadOutName+";"+textureObject+";"+opName+";"+quadWaveName+";"
End



// ====================== Surface-related utilities =============================


Static Function/S GetGizmoMatrixSurfaceList(gizmoName)	// for Matrices in gizmo selected by Gizmo Contours panel
	String gizmoName	// or "" for top gizmo
	
	String surfaceNameList, surfaceDataPathList
	Variable numSurfaces= GetGizmoSurfaces(gizmoName, surfaceNameList, surfaceDataPathList,want2DMatrices=1,allow2DFlat=0,want3DParametrics=0,ignoreSubgroups=1)
	if( numSurfaces == 0 )
		surfaceNameList="_none_"
	endif
	return surfaceNameList
End


// ====================== Images from Matrix Surfaces =========================

Function/S MakeGizmoSurfaceImageColorWave(surfaceName, wantAlpha, outName [,alpha])
	String surfaceName
	Variable wantAlpha	// if 0, returns RGB 0-255 unsigned byte wave suitable for ImageTransform/TEXT=9 imageToTexture imageWave
						// if 1, returns RGBA 0-1 floating point wave suitable for Gizmo color wave. It must be redimension/U/B and *= 255 for ImageTransform/TEXT=17
	String outName		// name of color wave to create in the current data folder. If it exists, it is overwritten.
	Variable alpha		// optional, default is (usually) 1 (relevant only if wantAlpha is true)
	
	// convert the surface to equivalent RGB
	String gizmoName= TopGizmo()
	String surfaceDataPath= GetSurfaceDataPath(gizmoName,surfaceName)
	WAVE/Z surfaceWave=$surfaceDataPath
	if( !WaveExists(surfaceWave) )
		return ""
	endif

	Variable minRed, minGreen, minBlue, minAlpha	// useColorsFromSurface values
	Variable maxRed, maxGreen, maxBlue, maxAlpha
	Variable reverseColorTable, firstColorAtLevel,lastColorAtLevel
	String colorTableNameOrWavePath

	Variable surfaceColorType= GetGizmoSurfaceColors(gizmoName, surfaceName, colorTableNameOrWavePath, reverseColorTable, firstColorAtLevel, minRed, minGreen, minBlue, minAlpha, lastColorAtLevel, maxRed, maxGreen, maxBlue, maxAlpha)
	switch( surfaceColorType )
		default:
			return ""
			break
	
		case 1:	// constant color
			Duplicate/O surfaceWave, $outName	// 2D
			Wave imageWave= $outName
			if( wantAlpha )
				if( ParamIsDefault(alpha) )
					alpha= minAlpha
				endif
				Redimension/S/N=(-1,-1,4) imageWave		// rgba, 0-1
				MultiThread imageWave[][][3]= numtype(surfaceWave[p][q]) == 0 ? alpha : 0.0	// NaNs are transparent, otherwise transparency is set by alpha
			else	
				minRed *= 255
				minGreen *= 255
				minBlue *= 255
				Redimension/U/B/N=(-1,-1,3) imageWave	// rgb, 0-255
			endif
			MultiThread imageWave[][][0,2]= SelectNumber(r-1, minRed, minGreen, minBlue)
			break

		case 2:	// color table
			String colorTableName= colorTableNameOrWavePath
			if( strlen(colorTableName) == 0 )
				return ""
			endif
			ColorTab2Wave $colorTableName		// The 0-65535 wave M_colors is created in the current data folder.
			WAVE M_colors					 	// Red is in column 0, green is in column 1, and blue in column 2.
			if( reverseColorTable )
				Reverse/DIM=0/P M_colors
			endif
			//SetScale/I x, firstColorAtLevel, lastColorAtLevel,"", M_colors
			// keep unscaled. Use the Igor image plot mapping:
			//	index= floor((z-zmin)/(zmax-zmin)*numColors)
			Variable numColors= DimSize(M_colors,0)
			
			Duplicate/O surfaceWave, $outName	// 2D
			Wave imageWave= $outName
		
			Redimension/S M_colors	// 0-65535
			if( wantAlpha )
				if( ParamIsDefault(alpha) )
					alpha= 1	// perhaps get this from minAlpha or maxAlpha?
				endif
				M_colors /= 65535	// 0.0-1.00
				Redimension/S/N=(-1,-1,4) imageWave		// rgba, 0-1
				MultiThread imageWave[][][3]= numtype(surfaceWave[p][q]) == 0 ? alpha : 0.0	// NaNs are transparent, otherwise transparency is set by alpha
			else	
				M_colors /= 256	// 0- 255
				minRed *= 255
				minGreen *= 255
				minBlue *= 255
				maxRed *= 255
				maxGreen *= 255
				maxBlue *= 255
				Redimension/U/B/N=(-1,-1,3) imageWave	// rgb, 0-255
			endif
			// SelectNumber(whichOne, val1, val2 , val3 ) returns val1  if whichOne  is negative, val2  if whichOne  is zero, or val3  if whichOne  is positive.
			Variable zRange= (lastColorAtLevel-firstColorAtLevel)
			Variable multiplier= numColors/zRange
			MultiThread imageWave[][][0,2]= numtype(surfaceWave[p][q]) != 0 ? NaN : (surfaceWave[p][q] < firstColorAtLevel ? SelectNumber(r-1, minRed, minGreen, minBlue) : (surfaceWave[p][q] > lastColorAtLevel ? SelectNumber(r-1, maxRed, maxGreen, maxBlue) : M_colors[limit(floor((surfaceWave[p][q]-firstColorAtLevel)*multiplier),0,numColors-1)][r]))
			break

		case 3:	// 0-1 rgba color wave
			WAVE/Z colorWave= $colorTableNameOrWavePath
			if( !WaveExists(colorWave) )
				return ""
			endif
			Duplicate/O colorWave, $outName
			Wave imageWave= $outName
			CopyScales surfaceWave, imageWave
			// if we want alpha, colorWave's values are just fine (0-1)
			if( !wantAlpha )
				// otherwise, convert to 0-255 unsigned byte
				MultiThread imageWave= imageWave*255
				Redimension/U/B imageWave
			endif
			break
	endswitch

	String pathToImageColorWave=GetWavesDataFolder(imageWave,2)	// full path with possibly quoted name
	return pathToImageColorWave
End


// This method creates a flat parametric surface colored by a color wave,
// and is necessarily positioned in data space.
//
// Returns truth of success.
//
// Waves are created in the current data folder, which normally is GizmoImageDF(gizmoName, imageGroupName)
//
// based on the now-obsolete MakeAppendGizmoXY2DSurfaceImage()
//
Function MakeGizmoXY2DSurfaceImage(gizmoName, surfaceName, matrixSurfaceWaveOutName, rgbaColorWaveOutName, zValue [,alpha])
	String gizmoName
	String surfaceName		// create an image from this surface at the current level (usually at the root level).
	String matrixSurfaceWaveOutName, rgbaColorWaveOutName	// names to use to create the surface and color waves
	Variable zValue				// z data value where the plane is positioned.
	Variable alpha				// optional, default is 1

	if( !ValidGizmoName(gizmoName) )
		return 0
	endif
	
	String surfaceDataPath= GetSurfaceDataPath(gizmoName,surfaceName)
	WAVE/Z surfaceWave=$surfaceDataPath
	if( !WaveExists(surfaceWave) )
		return 0
	endif
	
	// create the color wave
	Variable wantAlpha= 1
	if( ParamIsDefault(alpha) )
		alpha= 1
	endif
	String pathToRGBAWave= MakeGizmoSurfaceImageColorWave(surfaceName,wantAlpha,rgbaColorWaveOutName,alpha=alpha)
	WAVE/Z rgb=$pathToRGBAWave
	if( !WaveExists(rgb) )
		return 0
	endif
	
	// Create a "flat" surface wave, one xy point per color wave point.
	Duplicate/O surfaceWave, $matrixSurfaceWaveOutName
	WAVE flatWave= $matrixSurfaceWaveOutName
	flatWave= zValue
	if( !WaveExists(flatWave) )
		return 0
	endif
	
	return 1
End

// returns name of created object or "" if error
Function/S AppendGizmoXY2DSurfaceImage(gizmoName, matrixSurfaceWave, colorWave [,clipped])
	String gizmoName
	WAVE/Z matrixSurfaceWave, colorWave
	Variable clipped	// optional, default is NOT clipped

	if( !ValidGizmoName(gizmoName) )
		return ""
	endif
	
	if( !WaveExists(matrixSurfaceWave) || !WaveExists(colorWave) )
		return ""
	endif

	if( ParamIsDefault(clipped) )
		clipped= 0
	endif
	String cmd
	
	// See if any surface has matrixSurfaceWave as the data path
	String objectName= FindSurfaceUsingDataWave(gizmoName, matrixSurfaceWave)
	if( strlen(objectName) == 0 )
		objectName= UniqueGizmoObjectName(gizmoName,"imageSurface0","objectItemExists")
		sprintf cmd, "ModifyGizmo/N=%s startRecMacro", gizmoName
		Execute cmd
		
		sprintf cmd, "AppendToGizmo/N=%s/D Surface=%s, name=%s", gizmoName, GetWavesDataFolder(matrixSurfaceWave,2),objectName
		Execute cmd
		
		sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={ surfaceColorType,3}", gizmoName, objectName
		Execute cmd
		
		sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={ surfaceColorWave,%s}", gizmoName, objectName,GetWavesDataFolder(colorWave,2)
		Execute cmd
		
		sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={ lineWidthType,0}", gizmoName, objectName
		Execute cmd
		
		sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={ fillMode,2}", gizmoName, objectName
		Execute cmd
		
		sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={ srcMode,0}", gizmoName, objectName
		Execute cmd
		
		sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={ Clipped,%d}", gizmoName, objectName, clipped
		Execute cmd
		
		sprintf cmd, "ModifyGizmo/N=%s compile", gizmoName
		Execute cmd

		sprintf cmd, "ModifyGizmo/N=%s endRecMacro", gizmoName
		Execute cmd
	endif

	return objectName
End

// Returns  quadOutName+";"+textureObject+";"+opName+";"+quadWaveName+";"	// quadWaveName will be "" if isAtOrthoValue is true.
Function/S MakeAppendXY2DSurfaceTexture(gizmoName, surfaceName, quadOutName, textureWaveOutName, isAtOrthoValue, atValue [,alpha,textureWidthPixels, textureHeightPixels,clipped])
	String gizmoName
	String surfaceName		// create an image from this surface at the current level (usually at the root level).
	String quadOutName, textureWaveOutName	// names to use to create the quad (whether object quad or parametric surface "quad") and texture wave
	Variable isAtOrthoValue		// if true, position the plane in the ortho coordinate space (create an object quad), else use data space and a data quad.
	Variable atValue				// if isAtOrthoValue, atValus is the orth z value where the plane is positioned, else z data value.
	Variable alpha				// optional, default is 1
	Variable textureWidthPixels, textureHeightPixels	// Omit or set to NaN to get auto (the size of the surface matrix).
	Variable clipped	// optional, default is 0

	if( !ValidGizmoName(gizmoName) )
		return ""
	endif

	String surfaceDataPath= GetSurfaceDataPath(gizmoName,surfaceName)
	WAVE/Z surfaceWave=$surfaceDataPath
	if( !WaveExists(surfaceWave) )
		return ""
	endif

	// create the texture wave
	Variable wantAlpha= 1	// this causes MakeGizmoSurfaceImageColorWave to create a floating point 0-1 wave.
	if( ParamIsDefault(alpha) )
		alpha= 1
	endif
	String outName= CleanupName(NameOfWave(surfaceWave)[0,26]+"_tmp",0)
	String pathToRGBAWave= MakeGizmoSurfaceImageColorWave(surfaceName,wantAlpha,outName,alpha=alpha)
	WAVE/Z rgbaWave=$pathToRGBAWave
	if( !WaveExists(rgbaWave) )
		return ""
	endif
	if( ParamIsDefault(textureWidthPixels) || numtype(textureWidthPixels) != 0 )
		textureWidthPixels= DimSize(rgbaWave,0)	// original dimensions
		if( textureWidthPixels < 16 )
			textureWidthPixels= 16
		endif
	endif
	if( ParamIsDefault(textureHeightPixels) || numtype(textureHeightPixels) != 0 )
		textureHeightPixels= DimSize(rgbaWave,1)
		if( textureHeightPixels < 16 )
			textureHeightPixels= 16
		endif
	endif
	InterpolateForTexture(rgbaWave,outName,newWidthRows=textureWidthPixels,newHeightCols=textureHeightPixels)	// NULL if no interpolation needed, or error
	MultiThread rgbaWave = rgbaWave*255	// 0-255
	// ImageTransform imageToTexture needs a unsigned byte wave filled with 0-255
	Redimension/U/B rgbaWave					// back to unsigned byte, suitable for ImageTransform imageToTexture
	textureWidthPixels= DimSize(rgbaWave,0)	// interpolated dimensions
	textureHeightPixels= DimSize(rgbaWave,1)

	WAVE texture= CreateTextureFromRGB(rgbaWave, textureWaveOutName)

	String quadWaveName=""
	String planeStr= "XY"
	if( ParamIsDefault(clipped) )
		clipped= 0
	endif

	if( isAtOrthoValue )
		// adds the ortho quad, but not the texture. The quad, however, IS prepared to render using a texture.
		AddGizmoOrthoQuadPlane(gizmoName, planeStr, atValue ,quadName=quadOutName,clipped=clipped)
	else
		// data quad
		// we need a wave as well as an object.
		quadWaveName= CleanupName(NameOfWave(surfaceWave)[0,25]+"_quad",0)
		AddGizmoDataQuadPlane(gizmoName,planeStr,quadWaveName=quadWaveName,constantDataVal=atValue,quadSurfaceName=quadOutName,clipped=clipped)
	endif
	
	// append the texture and set it's rendering (SCoordinates, TCoordinates, etc) appropriate for the plane.
	Variable minDim= min(textureWidthPixels,textureHeightPixels)
	Variable doNearestNeighbor= minDim <= 256
	String textureObject= AddGizmoTextureForPlane(gizmoName,texture,planeStr,hasAlpha=1,widthPixels=textureWidthPixels,heightPixels=textureHeightPixels,textureName=textureWaveOutName,doNearestNeighbor=doNearestNeighbor)

	// Display the texture and then the quad, then clear the texture:
	String cmd

	// enable GL_TEXTURE_2D
	sprintf cmd,"ModifyGizmo/N=%s setDisplayList=-1, opName=enableTexture, operation=enable, data=3553",gizmoName
	Execute cmd

	sprintf cmd,"ModifyGizmo/N=%s setDisplayList=-1, object=%s",gizmoName,textureWaveOutName
	Execute cmd

	sprintf cmd,"ModifyGizmo/N=%s setDisplayList=-1, object=%s",gizmoName,quadOutName
	Execute cmd

	// disable GL_TEXTURE_2D
	sprintf cmd,"ModifyGizmo/N=%s setDisplayList=-1, opName=disableTexture, operation=disable, data=3553",gizmoName
	Execute cmd

	String opName= UniqueGizmoObjectName(gizmoName,"ClearTexture0","displayItemExists")
	sprintf cmd,"ModifyGizmo/N=%s setDisplayList=-1, opName=%s, operation=ClearTexture",gizmoName,opName
	Execute cmd

	return quadOutName+";"+textureObject+";"+opName+";"+quadWaveName+";"
End

// ====================== Projected Images from Matrix Surfaces =========================

// Creates a parametric surface wave, colored by a created color wave,
// that represents the projection of a matrix surface on the X or Y axis.
//
// The projection can have the surface colors applied, or you can specify
// that the projection be all one color (like a shadow), with optional transparency (alpha).
//
//
// Returns truth of success.
Function MakeGizmoSurfaceProjectionImage(gizmoName, surfaceName, wantxProjection, parametricSurfaceWaveOutName, rgbaColorWaveOutName, planeConstant [,red,green,blue,alpha,shimPercent])
	String gizmoName, surfaceName
	Variable wantxProjection	// xProjection if 1, yProjection otherwise
	String parametricSurfaceWaveOutName, rgbaColorWaveOutName	// names to use to create the parametric and color waves
	Variable planeConstant		// where to place the projected image. If wantXprojection, give an x value, if not x (if a y projection), give a y value.
	Variable red, green, blue		// OPTIONAL, fixed color for the projected image, range is 0 to 1.
	Variable alpha				// OPTIONAL, range is 0 to 1.
	Variable shimPercent		// OPTIONAL, range is 0 to 100, a small value like 0.25 works well. If 0 no shim object is created. else the name of the created object is returned in the optional shimName parameter

	String surfaceDataPath= GetSurfaceDataPath(gizmoName,surfaceName)
	WAVE/Z surfaceWave=$surfaceDataPath
	if( !WaveExists(surfaceWave) )
		return 0
	endif
	Variable rows= DimSize(surfaceWave,0)		// x dimension
	Variable cols= DimSize(surfaceWave,1)		// y dimension
	Variable layers= DimSize(surfaceWave,2)	// z dimension, probably 0, but 1 is okay

	if( (rows < 2) || (cols < 2) || (layers > 1) )
		return 0
	endif

	Variable fixedColor= !ParamIsDefault(red) &&  !ParamIsDefault(green) &&  !ParamIsDefault(blue)
	if( ParamIsDefault(alpha) || (alpha < 0) || (alpha > 1) )
		alpha= 1.0
	endif

	Variable minRed, minGreen, minBlue, minAlpha
	Variable maxRed, maxGreen, maxBlue, maxAlpha
	Variable reverseColorTable, firstColorAtLevel,lastColorAtLevel
	String colorTableName=""
	
	if( !fixedColor )
		Variable surfaceColorType= GetGizmoSurfaceColors(gizmoName, surfaceName, colorTableName, reverseColorTable, firstColorAtLevel, minRed, minGreen, minBlue, minAlpha, lastColorAtLevel, maxRed, maxGreen, maxBlue, maxAlpha)
		Variable validColors = surfaceColorType == 1 || surfaceColorType == 2	// fixed or color table
		if( !validColors )
			DoAlert 0, "To use \"colors from surface\" for a projected image, the surface must use constant or color table-based colors (not a color wave). Try \"Use one Color\", instead."
			return 0
		endif
		if( strlen(colorTableName) == 0 )
			fixedColor= 1
			red= minRed
			green= minGreen
			blue= minBlue
			alpha= minAlpha
		endif
	endif
	// If fixed color, there are only two z's per x: the min and max at each x.
	Variable numColors,numColorStrips,	verticalPixels

	if( fixedColor )	// constant color
		numColors = 1
		numColorStrips= 2
		verticalPixels= 3
	else
		ColorTab2Wave $colorTableName		// The wave M_colors is created in the current data folder. Red is in column 0, green is in column 1, and blue in column 2.
		WAVE M_colors
		numColors = DimSize(M_colors,0)
		if( reverseColorTable )
			Reverse/DIM=0/P M_colors
		endif
		Redimension/S M_colors	// 0-65535
		M_colors /= 65535	// 0.0-1.00
		
		// set the color transition levels
		SetScale/I x, firstColorAtLevel, lastColorAtLevel,"", M_colors	// 0-65535
		 numColorStrips= 2+numColors	// before color, color table colors, and after color
		verticalPixels= max(3,numColorStrips)
	endif

	Redimension/N=(-1,-1,1) surfaceWave
	Variable varyingDim, constantDim
	if( wantxProjection )
		ImageTransform/METH=1 xProjection surfaceWave	// creates M_xProjection
		WAVE M_xProjection
		Duplicate/O M_xProjection, M_ProjectionMax
		ImageTransform/METH=3 xProjection surfaceWave
		Duplicate/O M_xProjection, M_ProjectionMin
		KillWaves/Z M_xProjection
		varyingDim= 1	// the projection gets the column scaling from the matrix surface
		constantDim= 0	// the row dimension of the projected image is constant
	else
		ImageTransform/METH=1 yProjection surfaceWave	// creates M_yProjection
		WAVE M_yProjection
		Duplicate/O M_yProjection, M_ProjectionMax
		ImageTransform/METH=3 yProjection surfaceWave
		Duplicate/O M_yProjection, M_ProjectionMin
		KillWaves/Z M_yProjection
		varyingDim= 0	// the projection gets the row scaling from the matrix surface
		constantDim= 1	// the column dimension of the projected image is constant
	endif

	Redimension/N=(-1,-1,layers) surfaceWave
	Redimension/N=(-1,0) M_ProjectionMin,M_ProjectionMax	// 1-D now instead of 2-D with 1 column.

	// copy the orthogonal dimension's scaling to the x scaling of the projections. 
	Variable dx= DimDelta(surfaceWave,varyingDim)
	Variable x0= DimOffset(surfaceWave,varyingDim)
	SetScale/P x, x0, dx, "", M_ProjectionMax,M_ProjectionMin

	Variable numXValues= DimSize(M_ProjectionMax,0)
	// Get the surface values (z) range
	WaveStats/M=1/Q M_ProjectionMax
	Variable zMax= V_max
	WaveStats/M=1/Q M_ProjectionMin
	Variable zMin= V_min
	
	// The parametric surface has a vertical resolution >= number of colors needed.
	// and the horizontal resolution is just that of the projection's number of points
	// Note: for fixed color, a strip would be easier, but this seems to work fine.

	// for a parametric surface, the source wave is 3D with each layer containing the X, Y, and Z values.
	Make/O/N=(numXValues,verticalPixels,3) $parametricSurfaceWaveOutName/WAVE=surface
	
	// The color wave for a parametric surface is a 3D RGBA wave that has the same number of points in the X and Y dimensions as the source wave.
	Make/O/N=(numXValues,verticalPixels,4) $rgbaColorWaveOutName/WAVE=colorWave	// r,g,b,a [0,1]

	//	if( wantxProjection )
	//		varyingDim= 1	// the projection gets the column scaling from the matrix surface
	//		constantDim= 0	// the row dimension of the projected image is constant
	
	if( ParamIsDefault(shimPercent) || numtype(shimPercent) != 0 )
		shimPercent= 0
	endif

	MultiThread surface[][][constantDim]= planeConstant
	MultiThread surface[][][varyingDim]= x0+p*dx
	
	if( 1 )
		// spread the z's out between M_ProjectionMin[p] and M_ProjectionMax[p] 
		MultiThread surface[][][2]= M_ProjectionMin[p] + q/(verticalPixels-1)*(M_ProjectionMax[p]-M_ProjectionMin[p])
	else
		// Use the color transitions, repeat the max or min if out of the projected range.
		// Repeating values didn't work very well with small vertical resolution: the edges got all jaggy.
		Variable zRange= zMax-zMin
		Variable dz= zRange/(verticalPixels-1)
		MultiThread surface[][][2]= ((zMin + q*dz) < M_ProjectionMin[p]) ? M_ProjectionMin[p] : (((zMin + q*dz) > M_ProjectionMax[p]) ? M_ProjectionMax[p] : zMin + q*dz)
	endif	
	// create colors appropriate to the z's
	if( fixedColor )	// constant color
		MultiThread colorWave[][][0]= red
		MultiThread colorWave[][][1]= green
		MultiThread colorWave[][][2]= blue
	else
		MultiThread colorWave[][][0,2]= surface[p][q][2] < firstColorAtLevel ? SelectNumber(r-1, minRed, minGreen, minBlue) : (surface[p][q][2] > lastColorAtLevel ? SelectNumber(r-1, maxRed, maxGreen, maxBlue) : M_colors(surface[p][q][2])[r])
	endif
	MultiThread colorWave[][][3]= alpha

	KillWaves/Z M_ProjectionMax,M_ProjectionMin,M_colors

	return 1
End


// Returns the name of the appended surface object.
// Waves are created in the current data folder, which normally is GizmoImageDF(gizmoName, imageGroupName)
// Objects are appended to the  group named imageGroupName.

static Function/S AppendGizmoParametricSurface(gizmoName, parametricSurfaceWave, colorWave [,clipped])
	String gizmoName
	Wave/Z parametricSurfaceWave, colorWave	// image is the combination of this parametric surface and color waves
	Variable clipped				// optional, default is NOT clipped

	if( !ValidGizmoName(gizmoName) )
		return ""
	endif
	
	if( ParamIsDefault(clipped) )
		clipped= 0
	endif
	
	// See if any surface has parametricSurfaceWave as the data path
	String surfaceObjectName= FindSurfaceUsingDataWave(gizmoName, parametricSurfaceWave)
	if( strlen(surfaceObjectName) == 0 )
		surfaceObjectName= UniqueGizmoObjectName(gizmoName,"imageSurface0","objectItemExists")
		String cmd
		sprintf cmd, "ModifyGizmo/N=%s startRecMacro", gizmoName
		Execute cmd
		
		sprintf cmd, "AppendToGizmo/N=%s/D Surface=%s, name=%s", gizmoName, GetWavesDataFolder(parametricSurfaceWave,2),surfaceObjectName
		Execute cmd
		
		sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={ surfaceColorType,3}", gizmoName, surfaceObjectName
		Execute cmd
		
		sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={ srcMode,4}", gizmoName, surfaceObjectName
		Execute cmd

		sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={ surfaceColorWave,%s}", gizmoName, surfaceObjectName,GetWavesDataFolder(colorWave,2)
		Execute cmd
		
		sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={ Clipped,%d}", gizmoName, surfaceObjectName, clipped
		Execute cmd
		
		sprintf cmd, "ModifyGizmo/N=%s compile", gizmoName
		Execute cmd

		sprintf cmd, "ModifyGizmo/N=%s endRecMacro", gizmoName
		Execute cmd
	endif
	
	return surfaceObjectName
End

// ====================== Images from RGB waves =========================



// ====================== Main image update and building routines =========================

// returns 0 if neither is valid
// returns 1 if surface name is valid
// returns 2 if pathToRGBWave is valid
Function GetGizmoImageSource(gizmoName, imageName, surfaceName, pathToRGBWave)
	String gizmoName, imageName // inputs
	String &surfaceName, &pathToRGBWave // outputs

	if( !ValidGizmoName(gizmoName) )
		return 0
	endif

	String sourceRadio= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"sourceRadio"), "fromSurface")
	strswitch( sourceRadio )
		case "fromSurface":
			surfaceName= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"fromSurfaceName"),"")
			if( strlen(surfaceName) )
				String pathToSurfaceData= GetSurfaceDataPath(gizmoName,surfaceName)
				WAVE/Z w= $pathToSurfaceData
				if( WaveExists(w) )
					return 1	// surface name is valid
				endif
			endif		
			break
		case "fromRGBWave":
			pathToRGBWave=StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"rgbWavePath"),"")
			if( strlen(pathToRGBWave) )
				WAVE/Z w= $pathToRGBWave
				if( WaveExists(w) )
					return 2	// pathToRGBWave is valid
				endif
			endif		
			break
	endswitch
	return 0
End

// update method is to remove the existing image and rebuild it.
static Function/S AddNewOrUpdateExistingImage(gizmoName,imageName)
	String gizmoName,imageName		// imageName name can be "Nascent" to mean "_new_"

	String df= GizmoImageDF(gizmoName,imageName)

	Variable displayIndex= -1	// append new images
	strswitch(imageName)
		case "_new_":
		case "Nascent":
			// create a new data folder by copying the Nascent data folder.
			String srcDF= df
			imageName= UniqueGizmoImageName(gizmoName)
			if( strlen(imageName) == 0 )
				DoAlert 0, "Could not create new image: too many already!"
				return ""
			endif
			df= GizmoImageDF(gizmoName,imageName)	// creates the data folder
			KillDataFolder/Z $df	// DuplicateDataFolder requires the folder to be absent
			DuplicateDataFolder $srcDF, $df
			break
		default:
			displayIndex=GetDisplayIndexOfNamedObject(gizmoName,imageName)
			RemoveMatchingGizmoObjects(gizmoName,imageName)
			KillWavesInImageFolder(gizmoName,imageName)
			RecompileGizmo(gizmoName)
			break
	endswitch
	
	// Rather than just appending to the end, insert before the first scale, translate or rotate operation
	if( displayIndex == -1 )
		String opName, operation
		FindFirstTranslateRotateScaleOp(gizmoName, displayIndex, opName, operation)	// leaves displayIndex -1 if none of these operations are found
	endif
	
	Variable groupDisplayIndex= NewGizmoImage(gizmoName,imageName,displayIndex)

	return imageName
End

static Function KillWavesInImageFolder(gizmoName,imageName)
	String gizmoName,imageName		// imageName name can be "Nascent" to mean "_new_"

	String df= GizmoImageDF(gizmoName,imageName)
	if( DataFolderExists(df) )
		String oldDF= GetDataFolder(1)
		SetDataFolder df
		KillWaves/A/Z			// kill waves not in use in the current data folder
		SetDataFolder oldDF
	endif
End


// DO NOT REFERENCE ANY CONTROLS
// so that a dependency on the source data can update the image in Gizmo.
// returns the display index of the group object, or -1 on error
static Function NewGizmoImage(gizmoName,imageName,displayIndex)
	String gizmoName
	String imageName	// "WMImageGroup0", etc. 
	Variable displayIndex	// for insertDisplayList

	// append an image
	// it could be a texture on a quad, a parametric surface.
	String sourceRadio= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"sourceRadio"), "fromSurface")
	Variable fromSurface= CmpStr(sourceRadio,"fromSurface") == 0

	String planeStr
	Variable orthoValue, dataValue
	// GetPlanePositionForImage returns 0 if invalid, kUseOrtho if the orthoValue is to be used, kUseData if the dataValue is to be used.
	Variable useThis= GetPlanePositionForImage(gizmoName, imageName, planeStr, orthoValue, dataValue)

	// The positioning is divided based on whether the image is positioned in "ortho" space (-1 to +1 in each dimension, normally)
	// or whether the image is positioned in data space.
	Variable isAtOrthoValue = useThis == kUseOrtho
	Variable atValue= isAtOrthoValue ?  orthoValue : dataValue

	String perpendicularPlane= PlaneSpecToPerpendicularPlane(planeStr)

	Variable clipped= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"clipped"),0)

	// Parametric surfaces are "data", a quad is positioned in ortho coordinates.
	// textures can be applied to both ortho quads and a single-quad parametric surface.
	
	String useRadio= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"useRadio"),"useSurface")
	Variable useSurface= CmpStr(useRadio,"useSurface") == 0
	
	String createdImageObjectName= ""

	displayIndex= FindOrInsertGizmoGroupObject(gizmoName,imageName, displayIndex)
	if( displayIndex == -1 )
		return -1	// error
	endif

	String oldDF= GetDataFolder(1)
	SetDataFolder GizmoImageDF(gizmoName, imageName)	// create waves in this data folder
	String dfName= GetPackagePerGizmoDFName("",ksPackageName)

	// set the group as the currentGroupObject
	String oldGroupPath= SetGizmoCurrentGroup(gizmoName, "root:"+imageName)

	Variable alpha= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"imageAlpha"),1)
	
	Variable texWidth= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"textureWidthPop"), NaN)	// NaN is "auto"
	Variable texHeight= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"textureHeightPop"), NaN)	// NaN is "auto"
	
	// use the same name for all image types to avoid proliferation of color waves (should do for the surface waves, too)
	String parametricSurfaceWaveOutName=""
	String matrixSurfaceWaveOutName=""

	String rgbaColorWaveOutName=CleanupName(imageName[0,25]+"_rgba",1)
	String textureWaveOutName="", quadOutName="", objects
	if( fromSurface )
		// Create an image from the data in surface0
		String surfaceName= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"fromSurfaceName"),"")
		if( strlen(surfaceName) == 0 )
//			Print "No Surface name!"
		else
			// try to use the same name for all image types to avoid proliferation of color waves (should do for the surface waves, too)
			Variable isProjection= CmpStr(perpendicularPlane,"Z") != 0	// projected perpendicular to Y or X plane
			if( isProjection )
				// necessarily a parametric surface, not a texture
				Variable wantxProjection= CmpStr(perpendicularPlane,"X") == 0
				parametricSurfaceWaveOutName= CleanupName(perpendicularPlane+"projSurf"+surfaceName,0)
				String useColorsRadio=StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"useColorsRadio"),"useSurfaceColors")
				Variable constantColor= CmpStr(useColorsRadio,	"useConstantColor") == 0
				if( constantColor )
					 // defaults define a medium baby blue, get 0-1 values
					Variable red= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"constantRed"),32768)	/ 65535
					Variable green= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"constantGreen"),40777)	/ 65535 
					Variable blue= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"constantBlue"),65535) / 65535
					MakeGizmoSurfaceProjectionImage(gizmoName, surfaceName, wantxProjection, parametricSurfaceWaveOutName, rgbaColorWaveOutName, dataValue,alpha=alpha,red=red,green=green,blue=blue)
				else
					MakeGizmoSurfaceProjectionImage(gizmoName, surfaceName, wantxProjection, parametricSurfaceWaveOutName, rgbaColorWaveOutName, dataValue,alpha=alpha)
				endif
			else		// necessarily the XY plane
				if( useSurface )	
					// create a 2D flat surface (this is not a parametric surface)
					String surfaceDataPath= GetSurfaceDataPath(gizmoName,surfaceName)
					WAVE surfaceWave=$surfaceDataPath
					matrixSurfaceWaveOutName= CleanupName(NameOfWave(surfaceWave)[0,28]+"_z",1)
					MakeGizmoXY2DSurfaceImage(gizmoName, surfaceName, matrixSurfaceWaveOutName, rgbaColorWaveOutName, dataValue, alpha=alpha)
				else
					// texture allows ortho and data coordinates
					// Variable isAtOrthoValue = useThis == kUseOrtho
					// Variable atValue= isAtOrthoValue ?  orthoValue : dataValue
					// String perpendicularPlane= PlaneSpecToPerpendicularPlane(planeStr)
					quadOutName= UniqueGizmoObjectName(gizmoName,"imageQuad0","objectItemExists")	// data or object quad
					textureWaveOutName= CleanupName(imageName[0,25]+"_txtr",1)
					// both creates and appends the image, either a data quad (with supporting wave)
					// or object quad (no supporting wave other than the texture, which the data quad has, too).
					objects= MakeAppendXY2DSurfaceTexture(gizmoName, surfaceName, quadOutName, textureWaveOutName, isAtOrthoValue, atValue,alpha=alpha,textureWidthPixels=texWidth, textureHeightPixels=texHeight,clipped=clipped)
					createdImageObjectName= StringFromList(0,objects)	// name of quad object is listed first.
				endif
			endif
		endif
	else		// from RGB wave
		String pathToRGBWave=StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"rgbWavePath"),"")
		WAVE/Z wrgb= $pathToRGBWave
		if( WaveExists(wrgb) )
			Variable rotation= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"rgbRotateBy"), 0)
			Variable flipHoriz= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"rgbFlipH"), 0)
			Variable flipVert= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"rgbFlipV"), 0)
			
			if( useSurface && !isAtOrthoValue )
				Variable makeMatrix= CmpStr(perpendicularPlane,"Z") == 0	// in the XY Plane, make a 2D matrix (they're faster)
				if( makeMatrix )
					matrixSurfaceWaveOutName= CleanupName(NameOfWave(wrgb)[0,28]+"_z",1)
					MakeGizmoXY2DRGBImage(gizmoName, wrgb, matrixSurfaceWaveOutName, rgbaColorWaveOutName, dataValue, alpha=alpha,rotation=rotation,flipHoriz=flipHoriz,flipVert=flipVert)
				else
					// parametric
					parametricSurfaceWaveOutName= CleanupName(perpendicularPlane+"rgbSurf",0)
					MakeGizmoParametricRGBImage(gizmoName, wrgb, perpendicularPlane, parametricSurfaceWaveOutName, rgbaColorWaveOutName, dataValue,alpha=alpha,rotation=rotation,flipHoriz=flipHoriz,flipVert=flipVert)
				endif
			else
				// texture allows ortho and data coordinates
				// Variable isAtOrthoValue = useThis == kUseOrtho
				// Variable atValue= isAtOrthoValue ?  orthoValue : dataValue
				// String perpendicularPlane= PlaneSpecToPerpendicularPlane(planeStr)
				quadOutName= UniqueGizmoObjectName(gizmoName,"imageQuad0","objectItemExists")	// data or object quad
				textureWaveOutName= CleanupName(imageName[0,25]+"_txtr",1)
				// both creates and appends the image, either a data quad (with supporting wave)
				// or object quad (no supporting wave other than the texture, which the data quad has, too).
				createdImageObjectName=MakeAppendRGBImageTexture(gizmoName, wrgb, perpendicularPlane, quadOutName, textureWaveOutName, isAtOrthoValue, atValue,alpha=alpha,rotation=rotation,flipHoriz=flipHoriz,flipVert=flipVert,textureWidthPixels=texWidth, textureHeightPixels=texHeight,clipped=clipped)

				Variable isBackground= CmpStr(perpendicularPlane,"Background") == 0
				if( isBackground && NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"sizeGizmoToBackground"), 0) )
					Variable rotationDegrees= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"rgbRotateBy"),0)
					ResizeGizmoToFitBackgroundRGB(gizmoName,wrgb,rotationDegrees)
				endif
			endif
		else
			Print "wave path doesn't exist: "+pathToRGBWave
		endif
	endif
	
	WAVE/Z colorWave=$rgbaColorWaveOutName
	if( strlen(matrixSurfaceWaveOutName) )
		WAVE/Z matrixSurfaceWave=$matrixSurfaceWaveOutName
		if( WaveExists(matrixSurfaceWave) )
			createdImageObjectName= AppendGizmoXY2DSurfaceImage(gizmoName, matrixSurfaceWave, colorWave ,clipped=clipped)
		endif
	endif
	if( strlen(parametricSurfaceWaveOutName) )
		WAVE/Z parametricSurfaceWave=$parametricSurfaceWaveOutName
		if( WaveExists(parametricSurfaceWave) )
			createdImageObjectName= AppendGizmoParametricSurface(gizmoName, parametricSurfaceWave, colorWave,clipped=clipped)
		endif
	endif
	
	// put blending in each group, delete when not needed:
	if( alpha < 1 )
		AddBlendingToGizmo(gizmoName=gizmoName) // blending is required to show alpha < 1
	else
		// remove unneeded alpha blending
		RemoveMatchingGizmoDisplay(gizmoName,"blendingFunction;enableBlend;")	// remove them only from the display list; that's all we need do
	endif

	// reset the currentGroupObject
	SetGizmoCurrentGroup(gizmoName, oldGroupPath)	// return to the previous group

	SetDatafolder oldDF

	String/G $GizmoImageDFVar(gizmoName,imageName,"imageObjectName")=createdImageObjectName	// could be a surface, quad, or other kind of object.
	if( strlen(createdImageObjectName) == 0 )
		DoAlert 0, "Gizmo image "+imageName+" could not be created/updated with those settings.";Beep
	endif

	SetupOrClearGizmoHook(gizmoName)

	return displayIndex
End

static Function SetupOrClearGizmoHook(gizmoName[,clearIt])
	String gizmoName
	Variable clearIt
	
	if( !ValidGizmoName(gizmoName) )
		return 0
	endif
	String func
	if( ParamIsDefault(clearIt) || !clearIt )
		func= GetIndependentModuleName()+"#GizmoAppendImage#GizmoWindowHook"
	else
		func= ""
	endif
	String cmd
	sprintf cmd,"ModifyGizmo/N=%s namedHookStr={AppendImageToGizmo, \"%s\"}", gizmoName, func

	String oldDF= SetGizmoDF(gizmoName)
	Execute/Q cmd
	SetDatafolder oldDF
End

// This hook is used primarily to detect changes in the gizmo's ortho or box axis ranges.

static Function GizmoWindowHook(s)
	STRUCT WMGizmoHookStruct &s

	String gizmoName= s.winName
	Variable updateOnChange

	strswitch( s.eventName )
		case "scale":
			// data range changed
			Variable scaleRecursionBlock= NumVarOrDefault(GizmoDFVar(gizmoName,"scaleRecursionBlock"), 0)
			if( !scaleRecursionBlock )
				Variable/G $GizmoDFVar(gizmoName,"scaleRecursionBlock")= 1
				updateOnChange= NumVarOrDefault(PanelDFVar("updateOnChange"),1)	
				if( updateOnChange )
					if( ChangedDataRange(gizmoName, s.xmin, s.xmax, s.ymin, s.ymax, s.zmin, s.zmax) )
						AdjustImagesForNewDataRange(gizmoName)
					endif						
				endif
				Variable/G $GizmoDFVar(gizmoName,"scaleRecursionBlock")= 0
			endif
			break
		case "transformation":	// ortho range MIGHT have changed (probably did)
			Variable orthoRecursionBlock= NumVarOrDefault(GizmoDFVar(gizmoName,"orthoRecursionBlock"), 0)
			if( !orthoRecursionBlock )
				Variable/G $GizmoDFVar(gizmoName,"orthoRecursionBlock")= 1
				updateOnChange= NumVarOrDefault(PanelDFVar("updateOnChange"),1)	
				if( updateOnChange )
					if( ChangedOrtho(gizmoName) )
						AdjustImagesForNewOrtho(gizmoName)
					endif
				endif
				Variable/G $GizmoDFVar(gizmoName,"orthoRecursionBlock")=0
			endif
			break
	endswitch
	
	return 0	 
End

static Function ChangedOrtho(gizmoName)						
	String gizmoName
	
	Variable left, right, bottom, top, zNear, zFar
	GetGizmoOrtho(gizmoName, left, right, bottom, top, zNear, zFar)

	Variable orthoLeft= NumVarOrDefault(GizmoDFVar(gizmoName,"orthoLeft"),NaN)
	Variable orthoRight= NumVarOrDefault(GizmoDFVar(gizmoName,"orthoRight"),NaN)
	Variable orthoTop= NumVarOrDefault(GizmoDFVar(gizmoName,"orthoTop"),NaN)
	Variable orthoBottom= NumVarOrDefault(GizmoDFVar(gizmoName,"orthoBottom"),NaN)
	Variable orthoZNear= NumVarOrDefault(GizmoDFVar(gizmoName,"orthoZNear"),NaN)
	Variable orthoZFar= NumVarOrDefault(GizmoDFVar(gizmoName,"orthoZFar"),NaN)
	
	Variable changed= orthoLeft != left || orthoRight != right || orthoTop != top || orthoBottom != bottom || orthoZNear != zNear || orthoZFar != zFar
	if( changed )
		Variable/G $GizmoDFVar(gizmoName,"orthoLeft")=left
		Variable/G $GizmoDFVar(gizmoName,"orthoRight")=right
		Variable/G $GizmoDFVar(gizmoName,"orthoTop")=top
		Variable/G $GizmoDFVar(gizmoName,"orthoBottom")=bottom
		Variable/G $GizmoDFVar(gizmoName,"orthoZNear")=zNear
		Variable/G $GizmoDFVar(gizmoName,"orthoZFar")=zFar
	endif
	return changed
End

static Function ChangedDataRange(gizmoName, xmin, xmax, ymin, ymax, zmin, zmax)
	String gizmoName
	Variable xmin, xmax, ymin, ymax, zmin, zmax

	Variable dataXMin= NumVarOrDefault(GizmoDFVar(gizmoName,"dataXMin"),NaN)
	Variable dataXMax= NumVarOrDefault(GizmoDFVar(gizmoName,"dataXMax"),NaN)
	Variable dataYMin= NumVarOrDefault(GizmoDFVar(gizmoName,"dataYMin"),NaN)
	Variable dataYMax= NumVarOrDefault(GizmoDFVar(gizmoName,"dataYMax"),NaN)
	Variable dataZMin= NumVarOrDefault(GizmoDFVar(gizmoName,"dataZMin"),NaN)
	Variable dataZMax= NumVarOrDefault(GizmoDFVar(gizmoName,"dataZMax"),NaN)

	Variable changed= dataXMin != xmin || dataXMax != xmax || dataYMin != ymin || dataYMax != ymax || dataZMin != zmin || dataZMax != zmax
	if( changed )
		Variable/G $GizmoDFVar(gizmoName,"dataXMin")=xmin
		Variable/G $GizmoDFVar(gizmoName,"dataXMax")=xmax
		Variable/G $GizmoDFVar(gizmoName,"dataYMin")=ymin
		Variable/G $GizmoDFVar(gizmoName,"dataYMax")=ymax
		Variable/G $GizmoDFVar(gizmoName,"dataZMin")=zmin
		Variable/G $GizmoDFVar(gizmoName,"dataZMax")=zmax
	endif
	return changed
End

static Function AdjustImagesForNewDataRange(gizmoName)						
	String gizmoName

	String imageNames= ListOfGizmoImages(gizmoName,0)
	Variable i, n= ItemsInList(imageNames), adjusted=0
	for(i=0; i<n; i+=1 )
		String imageName= StringFromList(i,imageNames)
		adjusted += AdjustImageForDataRange(gizmoName,imageName)
	endfor
	if( adjusted )
		RecompileGizmo(gizmoName)
	endif
End

static Function AdjustImageForDataRange(gizmoName,imageName)
	String gizmoName,imageName

	String planeStr
	Variable constantOrthoVal, dataValue
	// useThis is  0 if invalid, kUseOrtho if the orthoValue is to be used, kUseData if the dataValue is to be used.
	Variable useThis= GetPlanePositionForImage(gizmoName, imageName, planeStr, constantOrthoVal, dataValue)
	if( useThis != kUseData )
		return 0
	endif

	String atPlacementRadio= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"atPlacementRadio"), "atMin")
	strswitch( atPlacementRadio )
		case "atMax":
		case "atMin":
		case "atSurfaceDataMax":
		case "atSurfaceDataMin":
			break
		default:
			return 0
			break
	endswitch

	AddNewOrUpdateExistingImage(gizmoName,imageName)
	return 1
End

// this does *not* adjust any image for which "Update Immediately" is unchecked.
static Function AdjustImagesForNewOrtho(gizmoName)
	String gizmoName
	
	Variable left, right, bottom, top, zNear, zFar
	GetGizmoOrtho(gizmoName, left, right, bottom, top, zNear, zFar)

	// for now, just adjust any background images
	String imageNames= ListOfGizmoImages(gizmoName,0)
	Variable i, n= ItemsInList(imageNames), adjusted=0
	for(i=0; i<n; i+=1 )
		String imageName= StringFromList(i,imageNames)
		if( IsBackgroundImage(gizmoName,imageName) )
			adjusted += AdjustImageForOrtho(gizmoName,imageName,left, right, bottom, top, zNear, zFar)
		endif
	endfor
	if( adjusted )
		RecompileGizmo(gizmoName)
	endif
End

static Function IsBackgroundImage(gizmoName,imageName)
	String gizmoName,imageName
	
	String planeStr= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"imagePlacement"), "XY")

	return CmpStr(planeStr,"Background") == 0
End

// for now, only backgrounds are adjusted
// These are necessarily ortho quad objects
static Function AdjustImageForOrtho(gizmoName,imageName,left, right, bottom, top, zNear, zFar)
	String gizmoName,imageName
	Variable left, right, bottom, top, zNear, zFar

	// Get the plane offset
	String planeStr
	Variable constantOrthoVal, dataValue
	Variable useThis= GetPlanePositionForImage(gizmoName, imageName, planeStr, constantOrthoVal, dataValue)

	// find the quad
	// AppendToGizmo quad={-1.43705,-1.4825,-1.96,-1.43705,1.3916,-1.96,1.43705,1.3916,-1.96,1.43705,-1.4825,-1.96},name=imageQuad0
	String inGroupPath= imageName+":"

	String quadNameList, quadCoordinatesStringList	// outputs
	Variable quadsFound= GetGizmoQuads(gizmoName, quadNameList, quadCoordinatesStringList, inGroupPath=inGroupPath,ignoreSubgroups=1)

	if( quadsFound < 1 )
		return 0
	endif

	String quadName=StringFromList(0,quadNameList)
	String pathToQuad= imageName+":"+quadName
	
	// find the texture
	// AppendToGizmo texture=WMImageGroup1_txtr
	String textureNameList	// output
	Variable texturesFound= GetGizmoTextures(gizmoName, textureNameList, inGroupPath=inGroupPath,ignoreSubgroups=1)
	String textureName=StringFromList(0,textureNameList)
	String pathToTexture= imageName+":"+textureName
	
	return AdjustBackgroundQuadForOrtho(gizmoName, pathToQuad, pathToTexture, left, right, bottom, top, constantOrthoVal)
End

static Function ResizeGizmoToFitBackgroundRGB(gizmoName,wrgb,rotationDegrees)
	String gizmoName
	Wave/Z wrgb
	Variable rotationDegrees
	
	if( !ValidGizmoName(gizmoName) || !WaveExists(wrgb) || DimSize(wrgb,0) < kMinGizmoWidth || DimSize(wrgb,1) < kMinGizmoHeight )
		return 0
	endif
	
	Variable left, top, right, bottom	// points
	if( !GetGizmoCoordinates(gizmoName, left, top, right, bottom) )
		return 0
	endif
	
	Variable widthDim= 0, heightDim=1
	if( rotationDegrees == 90 || rotationDegrees == -90 || rotationDegrees == 270 )
		widthDim= 1
		heightDim=0
	endif 
	Variable widthPoints= DimSize(wrgb,widthDim) * 72 / ScreenResolution
	Variable heightPoints= DimSize(wrgb,heightDim) * 72 / ScreenResolution
	Variable newRight= left + widthPoints
	Variable newBottom= top+heightPoints
	if( (newRight != right) || (newBottom != bottom) )
		MoveWindow/W=$gizmoName left, top, newRight, newBottom
	endif
	SetGizmoAspectRatio(gizmoName, widthPoints/heightPoints)
	return 1
End

// ====================== DEBUGGING =========================

static Function ShowAllControlsButtonProc(ctrlName) : ButtonControl
	String ctrlName
	ShowHideControls(1, ControlNameList(ksPanelName))
End

static Function ShowProcedureFileButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	DisplayProcedure/W=$"AppendImageToGizmo.ipf" "WMGizmoImagePanel"
End

static Function DebuggingUpdatePanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	UpdateGizmoImagePanel()
End


// ====================== General Procedures =========================

static Function/S UniqueGizmoImageName(gizmoName)
	String gizmoName
	
	return UniqueGizmoObjectName(gizmoName,"WMImageGroup0","objectItemExists")
End


// round to 1, 2, or 5 * 10eN, non-rigorously
static Function NiceNumber(num)
	Variable num
	
	if( num == 0 )
		return 0
	endif
	Variable theSign= sign(num)
	num= abs(num)
	Variable lg= log(num)
	Variable decade= floor(lg)
	Variable frac = lg - decade
	Variable mant
	if( frac < log(1.5) )	// above 1.5, choose 2
		mant= 1
	else
		if( frac < log(4) )	// above 4, choose 5
			mant= 2
		else
			if( frac < log(8) )	// above 8, choose 10
				mant= 5
			else
				mant= 10
			endif
		endif
	endif
	num= theSign * mant * 10^decade
	return num
End

// preserves disable state
Static Function ShowHideControls(show, listOfControls)
	Variable show	// 1 if show, 0 if disable
	String listOfControls
	
	Variable i, n= ItemsInList(listOfControls)
	for(i=0; i<n; i+=1)
		String control= StringFromList(i, listOfControls)
		ControlInfo/W=$ksPanelName $control    // gets V_disable
		if( show )
			V_disable= V_disable & ~0x1   // clear the hide bit
		else
			V_disable= V_disable | 0x1    // set the hide bit
		endif
		ModifyControl $control win=$ksPanelName, disable=V_disable
	endfor
End

// preserves showing/hidden state
Static Function EnableDisableControls(enable, listOfControls)
	Variable enable	// 1 if enable, 0 if disable
	String listOfControls
	
	Variable i, n= ItemsInList(listOfControls)
	for(i=0; i<n; i+=1)
		String control= StringFromList(i, listOfControls)
		ControlInfo/W=$ksPanelName $control    // gets V_disable
		if( enable )
			V_disable= V_disable & ~0x2   // clear the disable bit
		else
			V_disable= V_disable | 0x2    // set the disable bit
		endif
		ModifyControl $control win=$ksPanelName, disable=V_disable
	endfor
End

static Function SetRadioGroup(ctrlName, allRadioNamesList)
	String ctrlName // the checked radio button control's name
	String allRadioNamesList

	Variable i, n= ItemsInList(allRadioNamesList)
	for(i=0; i<n; i+=1)
		String control= StringFromList(i, allRadioNamesList)
		Checkbox $control win=$ksPanelName, value= CmpStr(ctrlName,control)==0
	endfor
End

static Function/S GetRadioGroup(allRadioNamesList)
	String allRadioNamesList

	Variable i, n= ItemsInList(allRadioNamesList)
	for(i=0; i<n; i+=1)
		String control= StringFromList(i, allRadioNamesList)
		ControlInfo/W=$ksPanelName $control
		if( V_Value )
			return control
		endif
	endfor
	return ""	// none checked
End

// ====================== Control Procedures =========================

// Controls outside of the Tab control

Static Function GizmoInfoButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String oldDF= SetPanelDF()
	Execute/Q/Z "ModifyGizmo showInfo"
	SetDataFolder oldDF
End

Static Function GizmoHelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String oldDF= SetPanelDF()
	DisplayHelpTopic/K=1 "Append Image To Gizmo"
	SetDataFolder oldDF
End

// Brings The Data Browser to the front with the current data folder set to the image's data folder.
static Function SetDataBrowserDataFolder(pathToDataFolder)
	String pathToDataFolder
	
	SetDataFolder pathToDataFolder
	Print "SetDataFolder "+pathToDataFolder
	Variable browserIsShowing= strlen(GetBrowserSelection(-1)) > 0
	if( !browserIsShowing )
		Execute/P/Q/Z "CreateBrowser"
	endif
	Execute/P/Q/Z "ModifyBrowser setDataFolder=\""+pathToDataFolder+"\""
	if( !browserIsShowing )
		Execute/P/Q/Z "DoWindow/F "+ksPanelName
	endif
End

static Constant kCCE_mousedown = 1	// Mouse down in control.
static Constant kCCE_mouseup = 2		// Mouse up in control.
static Constant kCCE_mouseup_out = 3	// Mouse up outside control.
static Constant kCCE_draw = 10			// Time to draw custom content.

static Function GizmoLinkControlProc(s)
	struct WMCustomControlAction &s
	
	String gizmoName= s.sVal
	switch(s.eventCode)
		case kCCE_mouseup:
			if( WinType(gizmoName) == 13 )
				DoWindow/F $gizmoName
			endif
			// FALL THROUGH
		case kCCE_mouseup_out:
			CustomControl $s.ctrlName, win=$s.win, userData(mouseState)="Up"
			break
		case kCCE_mousedown:	// mouse down in control
			CustomControl $s.ctrlName, win=$s.win, userData(mouseState)="Down"
			break
		case kCCE_draw:
			Variable xc= 0
			Variable yc= (s.ctrlRect.bottom - s.ctrlRect.top)/2
			String str="\\JL\\K(30000,30000,30000)Gizmo Window Name:\\y-05 \\y+05"
			Variable mouseIsDown= s.eventMod & 0x1
			String mouseState= GetUserData(s.win,s.ctrlName,"mouseState")
			if( strlen(mouseState) )
				mouseIsDown = CmpStr(mouseState,"Down") == 0
			endif
			if( mouseIsDown )
				str += "\\x+05\\y-05"	// shift down and right
			endif
			str += "\\f04\\K(0,0,65535)"
			str += gizmoName
			SetDrawEnv textxjust=0, textyjust=1,fsize=9,fname="Geneva"
			DrawText xc, yc, str
			return 1
			break
	endswitch
	return 0
End

static Function DataFolderLinkControlProc(s)
	struct WMCustomControlAction &s
	
	String df,sVal
	switch(s.eventCode)
		case kCCE_mouseup:
			df= RemoveEnding(GetDataFolder(1),":")
			sVal= RemoveEnding(s.sVal,":")	// image data folder
			if( CmpStr(df,sVal)==0 )
				df= GetUserData(s.win,s.ctrlName,"previousDF")
				if( strlen(df) == 0 )
					df= "root:"
				endif
				SetDataBrowserDataFolder(df)
			else
				df=GetDataFolder(1)
				SetDataBrowserDataFolder(s.sVal)
				CustomControl $s.ctrlName, win=$s.win, userData(previousDF)=df
			endif
			// FALL THROUGH
		case kCCE_mouseup_out:
			CustomControl $s.ctrlName, win=$s.win, userData(mouseState)="Up"
			break
		case kCCE_mousedown:	// mouse down in control
			CustomControl $s.ctrlName, win=$s.win, userData(mouseState)="Down"
			break
		case kCCE_draw:
			Variable xc= 0
			Variable yc= (s.ctrlRect.bottom - s.ctrlRect.top)/2
			df= RemoveEnding(GetDataFolder(1),":")
			sVal= RemoveEnding(s.sVal,":")
			String str="\\JL\\K(30000,30000,30000)Data Folder:\\y-05 \\y+05"
			Variable mouseIsDown= s.eventMod & 0x1
			String mouseState= GetUserData(s.win,s.ctrlName,"mouseState")
			if( strlen(mouseState) )
				mouseIsDown = CmpStr(mouseState,"Down") == 0
			endif
			if( mouseIsDown )
				str += "\\x+05\\y-05"	// shift down and right
			endif
			if( CmpStr(df,sVal)==0 )
				str += "\\x-25\\K(65535,0,0)\\k(65535,0,0)\\W649"	// red triangle marker, moved left (it leaves too big a gap).
			endif
			str += "\\f04\\K(0,0,65535)"
			str += s.sVal
			SetDrawEnv textxjust=0, textyjust=1,fsize=9,fname="Geneva"
			DrawText xc, yc, str
			return 1
			break
	endswitch
	return 0
End
			

static Function GizmoImagesPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr	// image group name
	
	String gizmoName= TopGizmo()
	String/G $GizmoDFVar(gizmoName,"wmImageName") = popStr
	
	UpdateGizmoImagePanel()
End

// return truth that an auto-update was done
Static Function ImageNeedsUpdate(needsUpdate)
	Variable needsUpdate

	String gizmoName, imageName
	GetPanelGizmoImage(gizmoName, imageName)

	Variable/G $GizmoImageDFVar(gizmoName,imageName,"imageNeedsUpdate")= 1	// for Update routine

	Variable isNew= CmpStr(imageName, "Nascent") == 0

	// see if the user wants auto-updating
	// prefer the per-image updateOnChange value, fall back to panel's value (if present)
	Variable updateOnChange=1	// the ultimate default is to update on change
	DoWindow  $ksPanelName
	Variable havePanel= V_Flag != 0
	if( havePanel )
		ControlInfo/W=$ksPanelName updateOnChange
		if( V_Flag )
			updateOnChange= V_Value
		endif
	endif
	Variable updateDone= updateOnChange && needsUpdate && !isNew
	if( updateDone )
		// pretend the createOrUpdateImage button was pressed
		AddOrUpdateButtonProc("")	// this works even if the panel isn't present.
	else
		if( havePanel )
			ModifyControl appendUpdateImage, win= $ksPanelName, disable=needsUpdate ? 0 : 2	// enable this button whenever the user changes anything.
		endif
	endif
	return updateDone
End

static Function UpdateOnChangeCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	Variable/G $PanelDFVar("updateOnChange")= checked	
	
	if( checked )
		ImageNeedsUpdate(1)
	endif
End


static Function RemoveImageButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String gizmoName, imageName
	GetPanelGizmoImage(gizmoName, imageName)
	if( strlen(gizmoName) )
		RemoveMatchingGizmoObjects(gizmoName,imageName)

		String df= GizmoImageDF(gizmoName,imageName)
		if( DataFolderExists(df) )
			if( CmpStr(df,GetDataFolder(1)) == 0 )	// killing the data folder we're currently in!
				SetDataFolder root:		// let's reset to root:
			endif
			KillDataFolder/Z $df
		endif
		RecompileGizmo(gizmoName)
	endif
	UpdateGizmoImagePanel()
End

Static Function AddOrUpdateButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	String gizmoName, imageName
	GetPanelGizmoImage(gizmoName, imageName)
	
	imageName= AddNewOrUpdateExistingImage(gizmoName,imageName)		// imageName name can be "Nascent" to mean "_new_"
	if( strlen(imageName) )
		String/G $GizmoDFVar(gizmoName,"wmImageName") = imageName	// update the popup when a new image is created.
		Variable/G $GizmoImageDFVar(gizmoName,imageName,"imageNeedsUpdate")= 0
	endif
	UpdateGizmoImagePanel()
End

// Tab control

static StrConstant ksTab0Controls="fromRGBWave;fromSurface;graphTitle;graphWindowPopup;loadRGBFromFile;makeRGBGroup;makeRGBfromGraph;matrixSurfaces;previewGraphCheck;resizeGraph;rgbWaveName;rgbWavePopupSelector;showMakeRGBfromGraphControls;overwriteRGB;"
static StrConstant ksTab1Controls="textureHeightPop;textureWidthPop;useSurface;useTexture;textureGroup;"
static StrConstant ksTab2Controls="placementGroup;positionAxis;coordinatesPopup;atMin;atMax;atSurfaceDataMax;atSurfaceDataMin;atUserValue;atValue;shimCheck;shimGroup;shimPercent;axisRange;rgbRotation;rgbFlipH;rgbFlipV;sizeGizmoToBackground"
static StrConstant ksTab3Controls="alpha;alphaTitle;constantColorPop;useConstantColor;useSurfaceColors;clipped;"

static Function TabProc(ctrlName,tabNum) : TabControl
	String ctrlName
	Variable tabNum
	
	ShowHideControls(tabNum != 0, "source;")	// TitleBox source is shown on all tabs EXCEPT tab 0
	ShowHideControls(tabNum == 0, ksTab0Controls)
	ShowHideControls(tabNum == 1, ksTab1Controls)
	ShowHideControls(tabNum == 2, ksTab2Controls)
	ShowHideControls(tabNum == 3, ksTab3Controls)
	Variable hideRGBPreview= 1
	switch( tabNum )
		case 0:	// Image Source
			ControlInfo/W=$ksPanelName showMakeRGBfromGraphControls
			ShowHideControls(V_Value, ksGraphRGBControls)
			String imageNames=ImageNameList(ksPanelName+"#Preview",";")
			hideRGBPreview= strlen(imageNames) == 0
			break
		case 2:	// Placement
			UpdatePlacementControls("","")
			break
		case 3:	// Colors
			UpdateColorsTabControls()
			break
	endswitch
	SetWindow $(ksPanelName+"#Preview") hide=hideRGBPreview, needUpdate=1
	return 0
End


// Tab 0 - Image Source - control procedures

// these are also listed in ksTab0Controls
static StrConstant ksGraphRGBControls="graphTitle;graphWindowPopup;makeRGBGroup;makeRGBfromGraph;previewGraphCheck;resizeGraph;rgbWaveName;overwriteRGB;"
static Function ShowHideGraphRGBControlsCheck(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	ShowHideControls(checked, ksGraphRGBControls)
End

static Function SourceRadioProc(ctrlName,checked) : CheckBoxControl
	String ctrlName		// fromRGBWave;fromSurface;
	Variable checked

	SetRadioGroup(ctrlName, "fromRGBWave;fromSurface;")

	String gizmoName, imageName
	GetPanelGizmoImage(gizmoName, imageName)
	String/G $GizmoImageDFVar(gizmoName,imageName,"sourceRadio")= ctrlName

	UpdateSourcePreview(gizmoName, imageName)

	UpdateColorsTabControls()
		
	ImageNeedsUpdate(1)
End

Static Function MatrixSurfacesPopMenuProc(ctrlName,popNum,nameOfSurfaceObject) : PopupMenuControl
	String ctrlName
	Variable popNum
	String nameOfSurfaceObject	// name of surface object, should  be one of surfaceNameList
	
	String gizmoName, imageName
	GetPanelGizmoImage(gizmoName, imageName)
	
	String/G $GizmoImageDFVar(gizmoName,imageName,"fromSurfaceName")= nameOfSurfaceObject

	SourceRadioProc("fromSurface",1)	// calls UpdateSourcePreview() and ImageNeedsUpdate(1)
End

static Function RGBWavePopupSelectorNotify(event, wavepath, windowName, buttonName)
	Variable event		// WMWS_SelectionChanged
	String wavepath
	String windowName	// panel name
	String buttonName	// "rgbWavePopupSelector"
	
	String gizmoName, imageName
	GetPanelGizmoImage(gizmoName, imageName)
	String/G $GizmoImageDFVar(gizmoName,imageName,"rgbWavePath")= wavepath

	SourceRadioProc("fromRGBWave",1)	// calls UpdateSourcePreview() and ImageNeedsUpdate(1)
end

static Function PreviewImage(w)
	Wave/Z w

	String win=ksPanelName+"#Preview"	// preview subwindow
	String imageName=StringFromList(0,ImageNameList(win,";"))
	if( strlen(imageName) )
		RemoveImage/W=$win $imageName
	endif
	
	Variable hide= 1
	if( WaveExists(w) )
		ControlInfo/W=$ksPanelName tab0
		hide= V_Value != 0
		AppendImage/W=$win w
		ModifyGraph/W=$win nticks=0,standoff=0,axThick=0,noLabel=2
		ModifyImage/W=$win $NameOfWave(w) ctab={*, *, Rainbow }
		SetAxis/A/R/W=$win left
	endif
	SetWindow $win hide=hide, needUpdate=1
End

static Function UpdateSourcePreview(gizmoName, imageName)
	String gizmoName, imageName

	DoWindow $ksPanelName
	if( V_Flag )
		String sourceRadio= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"sourceRadio"), "fromSurface")
		String fromSurfaceName= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"fromSurfaceName"), "")
		String pathToRGBWave=StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"rgbWavePath"),"")
	
		String title=""
		strswitch( sourceRadio )
			case "fromSurface":
				pathToRGBWave= GetSurfaceDataPath(gizmoName,fromSurfaceName)
				title="Image from "+fromSurfaceName+": "+pathToRGBWave
				break
			case "fromRGBWave":
				// pathToRGBWave=StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"rgbWavePath"),""), already done above
				title="Image from RGB wave: "+pathToRGBWave
				break
		endswitch
		WAVE/Z w= $pathToRGBWave
		PreviewImage(w)
		TitleBox source,win=$ksPanelName, title=title
	endif
End

static Function RGBWaveIsAcceptable(w)
	Wave/Z w
	
	Variable acceptable= 0
	if( WaveExists(w) && WaveType(w) == 0x48 )	// rgb waves are numeric real unsigned byte waves
		//  must have more than 1 row, more than 1 column, and 3 or 4 layers, and no chunks
		acceptable= DimSize(w,0) > 1 && DimSize(w,1) > 1 && DimSize(w,2) >= 3 && DimSize(w,2) <= 4 && DimSize(w,3) == 0
	endif
	return acceptable
End

static Function RGBWavePopupSelectorFilter(fullPathToWave, contentsCode)
	String fullPathToWave
	Variable contentsCode	// WMWS_Waves or WMWS_DataFolders
	
	if( contentsCode != WMWS_Waves )
		return 0
	endif

	WAVE/Z w= $fullPathToWave
	return RGBWaveIsAcceptable(w)
End

static Function GraphWindowPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String gizmoName, imageName
	GetPanelGizmoImage(gizmoName, imageName)
	String/G $GizmoImageDFVar(gizmoName,imageName,"fromGraphName")= popStr

	Variable graphExists= strlen(popStr) && WinType(popStr) == 1

	ControlInfo/W=$ksPanelName previewGraphCheck
	if( V_Value && graphExists )
		if( IsMacintosh() )
			HideTools/A/W=$ksPanelName	// avoid group-level bug on Macintosh.
		endif
		DoWindow/B=$ksPanelName $popStr
	endif
	
	UpdateGraphTitle(popStr)
End

static Function UpdateGraphTitle(graphName)
	String graphName

	String title=""
	Variable graphExists= strlen(graphName) && WinType(graphName) == 1
	if( graphExists )
		GetWindow/Z $graphName wtitle	// wtitle requires Igor 6.20B03
		title= S_value
		GetWindow/Z $graphName wsizeDC	// pixels
		Variable widthPixels= abs(V_right-V_left)
		Variable heightPixels= abs(V_bottom-V_top)
		title += " (w x h = "+num2istr(widthPixels)+" x "+num2istr(heightPixels)+" pixels)"
	endif
	TitleBox graphTitle, win=$ksPanelName,title=title
End


static Function/S ListOfGraphs(includeNone)
	Variable includeNone
	
	String graphs= SortList(WinList("*",";","WIN:1"),";",16)
	if( includeNone && strlen(graphs) == 0 )
		graphs += "_none_;"
	endif
	return graphs
End

static Function OptimizeGraphForRGBButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String gizmoName, imageName
	GetPanelGizmoImage(gizmoName, imageName)

	ControlInfo/W=$ksPanelName graphWindowPopup
	String graphName= S_Value
	String/G $GizmoImageDFVar(gizmoName,imageName,"fromGraphName")= graphName

	ResizeGraphForTexture(graphName)
	
	UpdateGraphTitle(graphName) // the title shows the pixel sizes.
End

static Function MakeRGBFromGraphButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String gizmoName, imageName
	GetPanelGizmoImage(gizmoName, imageName)

	ControlInfo/W=$ksPanelName graphWindowPopup
	String graphName= S_Value
	String/G $GizmoImageDFVar(gizmoName,imageName,"fromGraphName")= graphName

	if( strlen(graphName) && CmpStr(graphName,"_none_") != 0 )
		String rgbWaveNamePrototype= StrVarOrDefault(PanelDFVar("rgbWaveNamePrototype"),"rgbImage0")
		String outputName= rgbWaveNamePrototype
		ControlInfo/W=$ksPanelName overwriteRGB
		Variable doOverWrite= V_Value
		if( !doOverWrite )
			outputName= UniqueName(CleanupBaseName(outputName),1,0)		// in current data folder (probably root:)
		endif
		String pathToCreatedRGBWave= CreateRGBWaveFromGraph(graphName,outputName)	// in current data folder (probably root:)
		if( strlen(pathToCreatedRGBWave) )
			String/G $GizmoImageDFVar(gizmoName,imageName,"rgbWavePath")= pathToCreatedRGBWave
			PopupWS_SetSelectionFullPath(ksPanelName, "rgbWavePopupSelector", pathToCreatedRGBWave)
			SourceRadioProc("fromRGBWave",1)	// calls UpdateSourcePreview() and ImageNeedsUpdate(1)
		endif
	endif
End

// returns a cleaned up name for baseName.
// Hopefully baseName on input is just a short name, like "wave" or "image",
// but possibly with a numeric suffix (which gets removed), or even "" or a bad name
static Function/S CleanupBaseName(baseName)
	String baseName
	
	if( strlen(baseName) == 0 )
		return "baseName"
	endif
	
	baseName= CleanupName(baseName,0)	// no liberal names here
	// remove trailing digits
	String expr="(?U)([[:alnum:]]+)[[:digit:]]+$", prefix
	SplitString/E=(expr) baseName, prefix
	if( (V_flag == 1) && strlen(prefix))
		baseName= prefix
	endif
	return baseName
End


static Function LoadRGBFileButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ImageLoad/Z/O
	if(V_flag==0)
		return 0
	endif
	String wavesName=StringFromList(0,S_waveNames)
	Wave/Z imageWave=$wavesName
	if( !WaveExists(imageWave) )
		return 0
	endif
	if( !RGBWaveIsAcceptable(imageWave) )
		DoAlert 0, wavesName+" is the wrong type to be made into a Gizmo Image"
		return 0
	endif

	String wavepath= GetWavesDataFolder(imageWave,2)
	PopupWS_SetSelectionFullPath(ksPanelName, "rgbWavePopupSelector", wavepath)

	// select the loaded wave
	String gizmoName, imageName
	GetPanelGizmoImage(gizmoName, imageName)
	String/G $GizmoImageDFVar(gizmoName,imageName,"rgbWavePath")= wavepath

	SourceRadioProc("fromRGBWave",1)	// calls UpdateSourcePreview() and ImageNeedsUpdate(1)
End

// Tab 1 - Image Type - control procedures

static Function ImageTypeUseCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName		// useSurface;useTexture;
	Variable checked

	SetRadioGroup(ctrlName, "useSurface;useTexture;")

	String gizmoName, imageName
	GetPanelGizmoImage(gizmoName, imageName)
	String/G $GizmoImageDFVar(gizmoName,imageName,"useRadio")= ctrlName
	
	ImageNeedsUpdate(1)
End


static Function TextureSizePopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName	// textureHeightPop;textureWidthPop;
	Variable popNum
	String popStr

	String gizmoName, imageName
	GetPanelGizmoImage(gizmoName, imageName)
	Variable/G $GizmoImageDFVar(gizmoName,imageName,ctrlName)= str2num(popStr)	// NaN if "auto"
	
	ControlInfo/W=$ksPanelName useTexture
	if( V_Value )
		ImageNeedsUpdate(1)
	endif
End


// Be careful calling this routine; it interacts with UpdatePlacementControls()

static Function UpdateImageTypeControls()	// deferred until now because they depend on the placement.


	ControlInfo/W=$ksPanelName useSurface	// NOTE: this is NOT the fromSurface control!
	Variable usingSurfaceToDisplayImage= V_Value
	Variable usingTextureToDisplayImage = !usingSurfaceToDisplayImage

	ControlInfo/W=$ksPanelName fromSurface
	Variable imageSourceIsFromSurface= V_Value

	// parametric surface image types work only with data coordinates.
	Variable canUseData= CanUseDataCoordinates()

	Variable enableUseSurface = canUseData
	EnableDisableControls(enableUseSurface, "useSurface;")

	if( !enableUseSurface )
		ControlInfo/W=$ksPanelName useSurface	// NOTE: this is NOT the fromSurface control!
		if( V_Value )
			ImageTypeUseCheckProc("useTexture",1)	// updates the surface but not the placement controls (whew) because Textures can be used everywhere.
		endif
	endif

	// can't project a gizmo surface using a texture
	Variable projectedSurface= 0

	if( imageSourceIsFromSurface )
		ControlInfo/W=$ksPanelName positionAxis		// popup
		String planeStr= StringFromList(0,S_Value," ")	// first word of text: "Background", "XY", "XZ", or "YZ"
		strswitch (planeStr)
			case "XZ":	// These image projections of a Gizmo 2D matrix surface
			case "YZ":	// always use a parametric surface.
				projectedSurface =1
				break
		endswitch
	endif
	
	Variable enableUseTexture = !projectedSurface
	EnableDisableControls(enableUseTexture, "textureHeightPop;textureWidthPop;useTexture;")
	if( !enableUseTexture )
		ControlInfo/W=$ksPanelName useTexture	// NOTE: this is NOT the fromSurface control!
		if( V_Value )
			ImageTypeUseCheckProc("useSurface",1)	// updates the surface but not the placement controls, which could be a problem.
		endif
	endif

End
	
// Tab 2 - Placement - control procedures

// Image Placement popup menu list
static StrConstant ksImagePlacementList="Background (before MainTransform);XY Plane at constant Z;XZ Plane at constant Y;YZ plane at constant X;"

static Function/S ImagePlacementPopupList()

	ControlInfo/W=$ksPanelName fromSurface
	Variable fromSurface= V_Value
	String disabledItem
	if( fromSurface )
		disabledItem="\\M0:(:"
	else
		disabledItem=""
	endif
	
	String list= disabledItem+ StringFromList(0,ksImagePlacementList)+";"	// Background (disabled for surface image)
	list += StringFromList(1,ksImagePlacementList)+";"		// XY
	list += StringFromList(2,ksImagePlacementList)+";"		// XZ (for a surface image, this results in a projected image)
	list += StringFromList(3,ksImagePlacementList)+";"		// YZ (for a surface image, this results in a projected image)
	
	return list
End


// returns 0-based item number of the item in ksImagePlacementList which begins with placement
Static Function WhichItemIsPlacement(placement)
	String placement
	
	String matchStr= placement+" *"
	String firstMatchingItem= StringFromList(0,ListMatch(ksImagePlacementList, matchStr))
	Variable whichOne= WhichListItem(firstMatchingItem, ksImagePlacementList)
	return whichOne
End


static Function CanUseDataCoordinates()

	// Data coordinates are not available if:
	//	1) the placement is "Background"
	ControlInfo/W=$ksPanelName positionAxis
	String planeStr= StringFromList(0,S_Value," ")	// first word of text: "Background", "XY", "XZ", or "YZ"
	if( CmpStr(planeStr,"Background") == 0 )
		return 0
	endif

	return 1
End

static Function CanUseOrthoCoordinates()
	// Ortho coordinates are not available if:
	//	1) a surface is being projected onto the XZ or YZ plane
	ControlInfo/W=$ksPanelName fromSurface
	Variable fromSurface= V_Value

	ControlInfo/W=$ksPanelName positionAxis		// popup
	String planeStr= StringFromList(0,S_Value," ")	// first word of text: "Background", "XY", "XZ", or "YZ"

	ControlInfo/W=$ksPanelName useSurface	// CheckBox useSurface,title="Use a surface to display the image"
	Variable useParametricSurface= V_Value

	if( fromSurface )
		strswitch (planeStr)
			case "XZ":	// These image projections of a Gizmo 2D matrix surface
			case "YZ":	// always use a parametric surface.
				return 0
				break
			case "XY":
				// 2) a Gizmo 2D matrix surface projected onto the XY surface image is using a parametric surface
				if( useParametricSurface )
					return 0
				endif
				break
		endswitch	
	else		// from RGB wave
		// 3) an RGB wave is projected using a parametric surface
		if( useParametricSurface )
			return 0
		endif
	endif

	return 1
End

// Image Coordinates popup menu list
static StrConstant ksCoordinatesList="Data;Ortho;"

static Function/S ImageCoordinatesPopupList()

	String disabledItem=""
	if( !CanUseDataCoordinates() )
		disabledItem="\\M0:(:"
	else
		disabledItem=""
	endif
	String list= disabledItem + StringFromList(0,ksCoordinatesList)+";"	// Data

	if( !CanUseOrthoCoordinates() )
		disabledItem="\\M0:(:"
	else
		disabledItem=""
	endif
	list += disabledItem + StringFromList(1,ksCoordinatesList)+";"		// Ortho
	
	return list
End

// The name of the variable the user changes to control the surface position can be one of 7 names:
// "atOrthoXValue", "atOrthoYValue", "atOrthoZValue", "atOrthoBValue" ("B" is for "Background"),
// "atDataXValue", "atDataYValue", "atDataZValue", "atDataBValue" (however, Background doesn't work with data coordinates, and this value shouldn't be used).

// the atOrthoBValue is the zFar value, nominally 2.0 - offset as a percentage of 2.0
// TO DO: We need a height and width parameter?

static Function/S AtValueVariableName(placement, coordinates)
	String placement	// ControlInfo/W=$ksPanelName positionAxis; placement= StringFromList(0,S_Value," ")	// first word of popup text
	String coordinates	// ControlInfo/W=$ksPanelName coordinatesPopup; coordinates= S_Value	// "Data" or "Ortho"

	String perpendicularPlane= PlaneSpecToPerpendicularPlane(placement)
	String name="at"+coordinates+perpendicularPlane[0]+"Value"
	return name
End


Static StrConstant ksAtWhereControls= "atMax;atSurfaceDataMax;atUserValue;atValue;atSurfaceDataMin;atMin;"

// Call UpdatePlacementControls() when:
//	1) a change to the "positionAxis" popup has occurred.
//	2) a change to the "coordinatesPopup" popup control has occurred.
//
// Calling this function MAY change the selected placement radio button,
// IF the current selection is inappropriate for the placement setting,  and it WILL change the title text.
// Calling this function WILL set the SetVariable atValue control's variable and the limits.
//
// Calling this function MAY change the Image Type from surface to texture (when Background is selected, usually).
//
// Returns placement (or if "", returns placement from the Image Placement popup)
static Function/S UpdatePlacementControls(placement,coordinates)
	String placement	// "", "Background", "XY", "XZ", or "YZ"
	String coordinates	// "", "Data" or "Ortho"
	
	String gizmoName, imageName
	GetPanelGizmoImage(gizmoName, imageName)

	if( strlen(placement) == 0 )	// If "", get placement from the control
		ControlInfo/W=$ksPanelName positionAxis
		placement= StringFromList(0,S_Value," ")	// first word
	endif
	String perpendicularPlane= PlaneSpecToPerpendicularPlane(placement)

	if( strlen(coordinates) == 0 )	// If "", get placement from the control
		ControlInfo/W=$ksPanelName coordinatesPopup
		coordinates= S_Value
	endif
	Variable isData= CmpStr(coordinates,"Data")==0	// else isOrtho

	// validate (and possibly change) the coordinate setting
	String newCoordinates=""
	Variable dataOkay= CanUseDataCoordinates()
	Variable orthoOkay= CanUseOrthoCoordinates()
	Variable mode
	if( isData )
		if(  !dataOkay )
			newCoordinates= "Ortho"
		endif
	else		// Ortho is selected
		if(  !orthoOkay )
			newCoordinates= "Data"
		endif
	endif
	if( strlen(newCoordinates) )
		coordinates= newCoordinates
		isData= CmpStr(coordinates,"Data")==0
		mode= 1+WhichListItem(coordinates,ksCoordinatesList)
		PopupMenu coordinatesPopup, win=$ksPanelName, mode=mode,popValue=coordinates
		String/G $GizmoImageDFVar(gizmoName,imageName,"coordinates")=coordinates
	endif

	// Determine the source of the image: either a Gizmo surface or an RGB wave
	// If we can't use data coordinates, switch away from the surface, which requires them.
	// also switch away from using a surface for the plane's coloring (which also required data coordinates)
	// Tab 0: Image Source
	ControlInfo/W=$ksPanelName fromSurface
	Variable fromSurface= V_Value
	if( !dataOkay )
		if( fromSurface )
			String sourceRadio= "fromRGBWave"
			SetRadioGroup(sourceRadio, "fromSurface;fromRGBWave;")
			String/G $GizmoImageDFVar(gizmoName,imageName,"sourceRadio")= sourceRadio
			fromSurface= 0
		endif
		// Tab 1: Image Type
		ControlInfo/W=$ksPanelName useSurface
		Variable useSurface= V_Value
		if( useSurface )
			String useRadio="useTexture"
			SetRadioGroup(useRadio, "useSurface;useTexture;")
			String/G $GizmoImageDFVar(gizmoName,imageName,"useRadio")= useRadio
		endif
	endif
	
	Variable fromRGB= !fromSurface
	String fromSurfaceName="surface"
	if( fromSurface )
		fromSurfaceName= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"fromSurfaceName"), "")
	endif

	// Decide which controls it is appropriate to enable and show
	Variable isBackgroundImage=  CmpStr(placement,"Background") == 0
	Variable enableAtSurfaceMinMaxControls= isData && fromSurface && CmpStr(perpendicularPlane,"Z") == 0

	// change control's visibility only if the Placement tab is showing.
	ControlInfo/W=$ksPanelName tab0
	Variable placementTabIsShowing= V_Value == 2 
	if( placementTabIsShowing )
		Variable show= !isBackgroundImage
		ShowHideControls(show, ksAtWhereControls)
		
		show= isBackgroundImage
		ShowHideControls(show, "sizeGizmoToBackground;")
		
		show= fromRGB 	// rgbRotation is appropriate only for rgb images
		ShowHideControls(show, "rgbRotation;rgbFlipH;rgbFlipV;")
		// Defer hiding or showing the shim controls,
		// because they depend on the atWhere radio settings,
		// which we may change below.
	endif

	EnableDisableControls(!isBackgroundImage, "coordinatesPopup;")

	if( isBackgroundImage )
		// setup zFar, width, height.

	else 	// !isBackgroundImage
		String planeStr= placement	// now that we know it's not "Background", placement must be a valid plane designation.

		EnableDisableControls(enableAtSurfaceMinMaxControls, "atSurfaceDataMax;atSurfaceDataMin;")
		
		// re-title controls appropriately. The titles implicitly start with "Display Image on <plane> at constant <perpendicular plane> "
		String title
		String prefix= "at "+perpendicularPlane
		if( isData )
			// "at <perpendicular plane> maximum (<axis max value>)".
			Variable axisMin, axisMax
			Variable valid= GetGizmoAxisRange(gizmoName, perpendicularPlane, axisMin, axisMax)	// use userBoxLimits if any, else the real data limits
			sprintf title, prefix +" axis maximum (%g)", axisMax
		else		// ortho
			// "at <perpendicular plane> Ortho maximum (1)".
			title = prefix +" Ortho maximum (1)"
		endif
		ModifyControl atMax, win=$ksPanelName, title=title
		
		// "at surface max (max)" is valid only if the placement is the XY Plane and the image is from a surface
		if( enableAtSurfaceMinMaxControls )
			// "at surface maximum (<surface max value>)".
			Variable zMin, zMax
			GetSurfaceMinMax(gizmoName, imageName, zMin, zMax)
			sprintf title, "at %s maximum (%g)", fromSurfaceName, zMax
		else		// disabled title
			title = "at surface maximum"
		endif
		ModifyControl atSurfaceDataMax, win=$ksPanelName, title=title
		
		// "at Z =" and the associated SetVariable atValue
		Variable atMin, atMax, atInc
		if( isData )
			// "at <perpendicular plane> =".
			title = prefix
			atMin= axisMin
			atMax= axisMax
			atInc= NiceNumber((axisMax - axisMin)/40)
		else		// ortho
			// "at <perpendicular plane> Ortho =".
			title = prefix +" Ortho"
			atMin= -1
			atMax= 1
			atInc= 0.05
			// if the image is before the main transform, then these values can push the image behind the axes.
			if( CmpStr(perpendicularPlane,"Z") == 0 )
				atMin= -2
				atMax= 2
				atInc= 0.1
			endif
		endif
		ModifyControl atUserValue, win=$ksPanelName, title=title
		
		String varName= AtValueVariableName(placement, coordinates)
		NVAR/Z v=$GizmoImageDFVar(gizmoName,imageName,varName)
		if( !NVAR_Exists(v) )
			//Print " atValue doesn't exist: "+GizmoImageDFVar(gizmoName,imageName,varName)
			// perhaps need to put defaults here?, limited to atMin, atMax?
			Variable middle=0
			if( isData )
				middle= NiceNumber((atMax+atMin)/2)
				if( middle < atMin || middle > atMax )
					middle= (atMax+atMin)/2
				endif
			endif
			Variable/G $GizmoImageDFVar(gizmoName,imageName,varName)= middle
		endif

		SetVariable atValue,win=$ksPanelName, variable=$GizmoImageDFVar(gizmoName,imageName,varName)
		SetVariable atValue,win=$ksPanelName, limits={atMin,atMax,atInc}
	
		// "at surface min (min)" is valid only if the placement is the XY Plane and the image is from a surface
		if( enableAtSurfaceMinMaxControls )
			// "at surface minimum (<surface min value>)".
			sprintf title, "at %s minimum (%g)", fromSurfaceName, zMin
		else		// disabled title
			title = "at surface minimum"
		endif
		ModifyControl atSurfaceDataMin, win=$ksPanelName, title=title
		
		// "at <perpendicular plane> minimum", etc.
		if( isData )
			// "at <perpendicular plane> minimum (<axis min value>)".
			sprintf title, prefix +" axis minimum (%g)", axisMin
		else		// ortho
			// "at <perpendicular plane> Ortho maximum (1)".
			title = prefix +" Ortho minimum (-1)"
		endif
		ModifyControl atMin, win=$ksPanelName, title=title

		// Fix up bad radio selections:
		String newAtPlacementRadio=""
		String atPlacementRadio= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"atPlacementRadio"), "atMin")

		if( !fromSurface )
			// If the image IS NOT from a surface and a fromSurface radio is selected, choose something appropriate.
			strswitch( atPlacementRadio )
				case "atSurfaceDataMax":
					newAtPlacementRadio= "atMax"
					break
				case "atSurfaceDataMin":
					newAtPlacementRadio= "atMin"
					break
			endswitch
		endif

		if( strlen(newAtPlacementRadio) )
			atPlacementRadio= newAtPlacementRadio
			SetRadioGroup(atPlacementRadio, "atMax;atSurfaceDataMax;atUserValue;atSurfaceDataMin;atMin;")
			String/G $GizmoImageDFVar(gizmoName,imageName,"atPlacementRadio")= atPlacementRadio
		endif
	endif

	// change control's visibility only if the Placement tab is showing.
	if( placementTabIsShowing )
		// shims are for:
		//	surfaces projected on the XZ or YZ planes (which are necessarily using data coordinates)
		//	surfaces in the XY plane using data coordinates
		//	RGB images using data OR Ortho coordinates, including the Background Ortho image.
		Variable showShims= isBackgroundImage || FindListItem(atPlacementRadio,"atMax;atMin;") >= 0
		ShowHideControls(showShims, "shimCheck;shimPercent;")
		if( showShims ) 
			title=SelectString(isBackgroundImage ,"Offset image away from min/max","Offset image away from background")	// (condition, false, true)
			CheckBox shimCheck, win=$ksPanelName, title=title
		endif
	endif

	return placement
End

static Constant kUseOrtho=1
static Constant kUseData=2

// returns 0 if invalid, kUseOrtho if the orthoValue is to be used, kUseData if the dataValue is to be used.
static Function GetPlanePositionForImage(gizmoName, imageName, planeStr,orthoValue, dataValue)
	String gizmoName, imageName	// inputs
	String &planeStr		// output: "Background" or plane spec.
	Variable &orthoValue	// output: valid only if kUseOrtho is returned
	Variable &dataValue		// output: valid only if kUseData is returned
	
	Variable usethis=0

	// instead of adding shims, inset the max, min values and let the user increase userBoxLimits to give some separation.
	Variable shimPct= 0			
	Variable shimChecked= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"shimChecked"),0)
	if( shimChecked )
		shimPct= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"shimPct"),0)
	endif
	Variable shimFrac= shimPct / 100
	
	planeStr= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"imagePlacement"), "XY")
	strswitch( planeStr )
		case "Background":
			usethis= kUseOrtho
			Variable left, right, bottom, top, zNear, zFar
			GetGizmoOrtho("", left, right, bottom, top, zNear, zFar)
			// zNear is the background, zFar is the foreground (!)
			// so to put an image in the "background", set orthoZ zNear
			orthoValue= zNear + shimFrac * (zFar - zNear)	// nominally zNear = -2, this is a bit closer to 0.
			break
		default:
			// Data vs Ortho
			String coordinates= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"coordinates"), "Data")
			Variable isData= CmpStr(coordinates,"Data")==0
			usethis= isData ? kUseData : kUseOrtho
			
			// Source: Surface or RGB wave?
			WAVE/Z w
			String sourceRadio= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"sourceRadio"), "fromSurface")
			Variable fromSurface= CmpStr(sourceRadio,"fromSurface") == 0
			if( fromSurface )
				String fromSurfaceName= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"fromSurfaceName"), "")
				WAVE/Z w= $GetSurfaceDataPath(gizmoName,fromSurfaceName)
			endif
			
			// Axis range
			String perpendicularPlane= PlaneSpecToPerpendicularPlane(planeStr)
			Variable axisMin, axisMax, axisRange, valid=0
			if( isData )
				valid= GetGizmoAxisRange(gizmoName, perpendicularPlane, axisMin, axisMax)	// use dataLimits = 1 if we offset from the data limits, but that's recursive.
				axisRange= axisMax - axisMin
			endif

			// Get Ortho or Data constant value
			String atPlacementRadio= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"atPlacementRadio"), "atMin")

			strswitch( atPlacementRadio )
				case "atMax":
					if( isData )
						dataValue= axisMax - axisRange * shimFrac
					else
						orthoValue= 1 - shimFrac
					endif
					break
				case "atSurfaceDataMax":
					dataValue= WaveExists(w) ? WaveMax(w) : NaN
					break
				case "atUserValue":
					String varName= AtValueVariableName(planeStr, coordinates)
					Variable v= NumVarOrDefault(GizmoImageDFVar(gizmoName,imageName,varName),0)
					if( isData )
						dataValue= v
					else
						orthoValue= v
					endif
					break
				case "atSurfaceDataMin":
					dataValue = WaveExists(w) ? WaveMin(w) : NaN
					break
				case "atMin":
					if( isData )
						dataValue= axisMin + axisRange * shimFrac
					else
						orthoValue= -1 + shimFrac
					endif
					break
			endswitch
			break
	endswitch
	
	return usethis	
End


// returns name of surface if the surface minima and maxima returned are valid,
// returns "" if they're not.
static Function/S GetSurfaceMinMax(gizmoName, imageName, zMin, zMax)
	String gizmoName, imageName
	Variable &zMin, &zMax
	
	String fromSurfaceName=""

	String sourceRadio= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"sourceRadio"), "fromSurface")
	if( CmpStr(sourceRadio, "fromSurface") == 0 )	// surface selected
		fromSurfaceName= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"fromSurfaceName"), "")
		WAVE/Z w= $GetSurfaceDataPath(gizmoName,fromSurfaceName)	// 2D Matrix wave
		if( WaveExists(w) )
			ImageStats/M=1 w
			zMin= V_Min
			zMax= V_Max
		else
			fromSurfaceName=""
		endif
	endif
	return fromSurfaceName
End

static Function ImagePlacementPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String gizmoName, imageName
	GetPanelGizmoImage(gizmoName, imageName)
	String placement= StringFromList(0,popStr," ")	// first word
	String/G $GizmoImageDFVar(gizmoName,imageName,"imagePlacement")= placement
	UpdatePlacementControls(placement,"")
	UpdateImageTypeControls()

	ImageNeedsUpdate(1)
End

static Function CoordinatesPopMenuProc(ctrlName,popNum,coordinates) : PopupMenuControl
	String ctrlName
	Variable popNum
	String coordinates

	String gizmoName, imageName
	GetPanelGizmoImage(gizmoName, imageName)
	String/G $GizmoImageDFVar(gizmoName,imageName,"coordinates")= coordinates
	UpdatePlacementControls("",coordinates)
	UpdateImageTypeControls()

	ImageNeedsUpdate(1)
End

static Function PlacementRadioCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName	// atMax;atSurfaceDataMax;atUserValue;atSurfaceDataMin;atMin;
	Variable checked

	SetRadioGroup(ctrlName, "atMax;atSurfaceDataMax;atUserValue;atSurfaceDataMin;atMin;")

	String gizmoName, imageName
	GetPanelGizmoImage(gizmoName, imageName)
	String/G $GizmoImageDFVar(gizmoName,imageName,"atPlacementRadio")= ctrlName

	UpdatePlacementControls("","")
	
	ImageNeedsUpdate(1)
End

static Function AtValueSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	String gizmoName, imageName
	GetPanelGizmoImage(gizmoName, imageName)
	Variable/G $GizmoImageDFVar(gizmoName,imageName,varName)= varNum
	
	ImageNeedsUpdate(1)
End

	// Shims
// the Checkbox alters the variable directly, so we don't need to update the global here.
static Function ShimCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

//	String gizmoName, imageName
//	GetPanelGizmoImage(gizmoName, imageName)
//	Variable/G $GizmoImageDFVar(gizmoName,imageName,"shimChecked")= checked

	ImageNeedsUpdate(1)
End

// the SetVariable alters the variable directly, so we don't need to update the global here.
static Function ShimPctSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

// the SetVariable alters the variable directly, so we don't need to update the global here.
//	String gizmoName, imageName
//	GetPanelGizmoImage(gizmoName, imageName)
//	Variable/G $GizmoImageDFVar(gizmoName,imageName,"shimPct")= varNum
	
	ControlInfo/W=$ksPanelName shimCheck
	if( V_Value )
		ImageNeedsUpdate(1)
	endif
End

static Function AxisRangeButtonProc(ctrlName) : ButtonControl
	String ctrlName

	if( exists("WM_initGizmoBoxLimitsPanel") == 6 )
		Execute/P/Q/Z GetIndependentModuleName()+"#WM_initGizmoBoxLimitsPanel()"
	elseif( exists("WMGP#WM_initGizmoBoxLimitsPanel") == 6 )
		Execute/P/Q/Z "WMGP#WM_initGizmoBoxLimitsPanel()"
	else
		Execute/P/Q/Z "INSERTINCLUDE <All Gizmo Procedures>"
		Execute/P/Q/Z "COMPILEPROCEDURES "
		Execute/P/Q/Z GetIndependentModuleName()+"#WM_initGizmoBoxLimitsPanel()"
	endif
End


static Function ClippedCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	String gizmoName, imageName
	GetPanelGizmoImage(gizmoName, imageName)
	Variable/G $GizmoImageDFVar(gizmoName,imageName,"clipped")= checked
	
	ImageNeedsUpdate(1)
End

static Function RGBRotatePopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	String gizmoName, imageName
	GetPanelGizmoImage(gizmoName, imageName)
	Variable/G $GizmoImageDFVar(gizmoName,imageName,"rgbRotateBy")= str2num(popStr)

	ImageNeedsUpdate(1)
End

// The rgbFlipH and rgbFlipV checkboxes control a variable, so we don't need to update their state here
static Function RGBImageFlipCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName	// "rgbFlipH;rgbFlipV"
	Variable checked

	ImageNeedsUpdate(1)
End

// Background Image-specific controls.

// sizeGizmoToBackground controls a variable, so we don't need to set the state that here
static Function SizeToFitBackgroundCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName	// CheckBox sizeGizmoToBackground
	Variable checked

	if( checked )
		ImageNeedsUpdate(1)
	endif
End


// Tab 3 - Colors - control procedures

static Function ProjectingASurface(gizmoName,imageName)
	String gizmoName,imageName

	Variable projectingASurface=0
	
	String planeStr= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"imagePlacement"), "XY")
	strswitch( planeStr )
		case "XZ":
		case "YZ":
			// Source: Surface or RGB wave?
			String sourceRadio= StrVarOrDefault(GizmoImageDFVar(gizmoName,imageName,"sourceRadio"), "fromSurface")
			projectingASurface= CmpStr(sourceRadio,"fromSurface") == 0
			break
	endswitch
	return projectingASurface
End

// Call UpdateColorsTabControls() when:
//	1) a change to the image source radio has occurred.
//	2) a change to the "positionAxis" popup has occurred.
//	0) a change to the "imagesPopup" popup has occurred.
//
static Function UpdateColorsTabControls()

	// change control's visibility only if the Placement tab is showing.
	ControlInfo/W=$ksPanelName tab0
	Variable tabIsShowing= V_Value == 3 
	if( tabIsShowing )
		String gizmoName, imageName
		GetPanelGizmoImage(gizmoName, imageName)
		Variable show= ProjectingASurface(gizmoName, imageName)
		ShowHideControls(show, "useSurfaceColors;useConstantColor;constantColorPop;")
	endif
End

static Function UseColorsRadioProc(ctrlName,checked) : CheckBoxControl
	String ctrlName	// "useSurfaceColors;useConstantColor;"
	Variable checked

	SetRadioGroup(ctrlName, "useSurfaceColors;useConstantColor;")

	String gizmoName, imageName
	GetPanelGizmoImage(gizmoName, imageName)
	String/G $GizmoImageDFVar(gizmoName,imageName,"useColorsRadio")= ctrlName

	ImageNeedsUpdate(1)
End

static Function ConstantColorPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	// used only for projected surfaces
	String gizmoName, imageName
	GetPanelGizmoImage(gizmoName, imageName)
	ControlInfo/W=$ksPanelName $ctrlName
	Variable/G $GizmoImageDFVar(gizmoName,imageName,"constantRed")= V_red	// 0-65535
	Variable/G $GizmoImageDFVar(gizmoName,imageName,"constantGreen")= V_green	// 0-65535
	Variable/G $GizmoImageDFVar(gizmoName,imageName,"constantBlue")= V_blue	// 0-65535

	if( ProjectingASurface(gizmoName,imageName) )
		ImageNeedsUpdate(1)
	endif
End

static Function AlphaSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	String gizmoName, imageName
	GetPanelGizmoImage(gizmoName, imageName)
	Variable/G $GizmoImageDFVar(gizmoName,imageName,"imageAlpha")= varNum

	ImageNeedsUpdate(1)
End


