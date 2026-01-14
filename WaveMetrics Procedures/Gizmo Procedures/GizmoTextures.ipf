#pragma rtGlobals=3		// Use modern global access method.
#pragma IgorVersion=6.2	// requires Igor 6.2 for ImageInterpolate/RESL
#pragma version=6.2		// shipped with Igor 6.2
#pragma moduleName=GizmoTextures

#include <Math Utility Functions>
#include <GizmoUtils>

// If you've included GizmoTextures and the "Gizmo Textures" menu isn't showing, try setting menus=1:
// #include <GizmoTextures>,menus=1

// GizmoTextures.ipf
// JP100623: 6.20B03, Initial version
// JP100624: Revised ResizeGraphForTexture() to work if the graph isn't set to Auto size mode.
// JP100726: Added AddGizmoOrthoBackgroundQuad().
// JP100810: Used a less common path name than "temp".

Menu "Gizmo Textures"
	"Show Texture Maker Panel",/Q, ShowGraphTextureMakerPanel()
End

// ----------------------------------- START Graph Texture Maker Panel -----------------------------------

static StrConstant ksPanelName="GraphTextureMakerPanel"

Function ShowGraphTextureMakerPanel()
	DoWindow/F $ksPanelName
	if( V_Flag == 0 )
		NewPanel/N=$ksPanelName/K=1/W=(322,55,939,483) as "Create Gizmo Texture From Graph"
		ModifyPanel fixedSize=1, noedit=1
		DefaultGuiFont/W=#/Mac popup={"_IgorMedium",12,0},all={"_IgorMedium",12,0}
		DefaultGuiFont/W=#/Win popup={"_IgorMedium",0,0},all={"_IgorMedium",0,0}
	
		// 1. Graph
		GroupBox graphGroup,pos={17,8},size={587,121},title="1. Graph"
		PopupMenu graphWindowPopup,pos={36,36},size={71,20},proc=GizmoTextures#GraphWindowPopMenuProc
		String cmd= GetIndependentModuleName()+"#GizmoTextures#ListOfGraphs(1)"
		PopupMenu graphWindowPopup,mode=1,value= #cmd

		CheckBox previewGraphCheck,pos={253,38},size={208,16},title="Choosing Graph brings it forward"
		CheckBox previewGraphCheck,value= 1

		TitleBox graphTitle,pos={55,70},size={176,12},fSize=9,frame=0,title=""	// "Graph1:twod (w x h = 256 x 256 pixels)"

		Button resizeGraph,pos={34,97},size={210,20},proc=GizmoTextures#OptimizeGraphForRGBButtonProc,title="Optimize Graph Size for Texture"

		Button removeMargins,pos={320,97},size={260,20},proc=GizmoTextures#RemoveMarginsFromGraphProc,title="Remove Margins, Axes, Ticks from Graph"

		// 2. Create Texture
		GroupBox createTextureGroup,pos={17,138},size={587,121},title="2. Create Texture"

		String/G $PanelDFVar("textureWaveName")
		SetVariable textureWaveName,pos={55,166},size={271,19},bodyWidth=150,title="Texture Wave Name"
		SetVariable textureWaveName,value= root:Packages:GizmoTextures:textureWaveName
		SetVariable textureWaveName,proc=GizmoTextures#TextureWaveNameSetVarProc
	
		CheckBox overwrite,pos={400,166},size={74,16},proc=GizmoTextureMaker#OverwriteCheckProc,title="Overwrite"
		CheckBox overwrite,value= 1

		Button makeTexturefromGraph,pos={34,199},size={210,20},proc=GizmoTextures#MakeTextureFromGraphButtonProc,title="Make Texture from Graph"

		String/G $PanelDFVar("createdTextureInfo")
		SetVariable createdTexturePath,pos={55,232},size={404,15},bodyWidth=300,title="Created Texture Wave:"
		SetVariable createdTexturePath,fSize=9,frame=0,noedit= 1
		SetVariable createdTexturePath,value= root:Packages:GizmoTextures:createdTextureInfo

		// 3. Append To Gizmo
		GroupBox appendGroup,pos={17,266},size={587,121},title="3. Append to Gizmo"

		PopupMenu plane,pos={55,293},size={296,20},proc=GizmoTextures#TextureCoordinatesPopMenuProc,title="Append with Texture Coordinates for"
		PopupMenu plane,mode=5,popvalue="Wrapped around Object",value= #"\"XY Plane;XZ Plane;YZ Plane;Background;Wrapped around Object;\""

		Button appendTextureToGizmo,pos={35,324},size={210,20},proc=GizmoTextures#AddTextureButtonProc,title="Append Texture to Gizmo"

		String/G $PanelDFVar("createdTextureObjectName")
		SetVariable appendedTextureObject,pos={49,359},size={219,15},bodyWidth=100,title="Appended Texture Object:"
		SetVariable appendedTextureObject,fSize=9,frame=0,noedit= 1
		SetVariable appendedTextureObject,value= root:Packages:GizmoTextures:createdTextureObjectName

		Button appendSphere,pos={274,324},size={160,20},disable=1,proc=GizmoTextures#AppendSphereButtonProc,title="Append Sphere Object..."
		Button appendPlane,pos={274,324},size={160,20},proc=GizmoTextures#AppendPlaneButtonProc,title="Append Plane Object..."

		String/G $PanelDFVar("createdObjectName")
		SetVariable appendedObject pos={292,359}, size={192,15},bodyWidth=120,title="Created Object:"
		SetVariable appendedObject,fSize=9,frame=0,noedit= 1
		SetVariable appendedObject,value= root:Packages:GizmoTextures:createdObjectName

		// Bottom controls
		Button close,pos={525,397},size={50,20},proc=GizmoTextures#CloseButtonProc,title="Close"

		Button help,pos={433,397},size={50,20},proc=GizmoTextures#HelpButtonProc,title="Help"

		// Set up hook
		SetWindow $ksPanelName hook(GizmoTextures)=GizmoTextures#GraphTextureMakerWindowHook

		// Position panel
		String gizmoName= TopGizmo()
		if( ValidGizmoName(gizmoName) )
			AutoPositionWindow/M=0/R=$gizmoName $ksPanelName
		endif
		
		// Updates
		UpdateGizmoTexturePanel()
	endif
End

// suitable for when the panel is activated; the graphs might have disappeared or been resized.
static Function UpdateGizmoTexturePanel()

	ControlInfo/W=$ksPanelName graphWindowPopup
	String graphName= S_Value
	if( strlen(graphName) == 0 || WinType(graphName) != 1 )
		graphName= WinName(0,1,1)
		if( strlen(graphName) == 0 || WinType(graphName) != 1 )
			String graphs=ListOfGraphs(1)
			graphName= StringFromList(0,graphs)
		endif
		PopupMenu graphWindowPopup,mode=1
		ControlUpdate/W=$ksPanelName graphWindowPopup
	endif

	UpdateGraphTitle(graphName)
	String/G $PanelDFVar("textureWaveName")= ProposedTextureName(graphName)
	EnableDisableShowHide()
	ShowHideTextureObjects("")	// get object kind from popup menu
End

// Panel hook
Static Function GraphTextureMakerWindowHook(s)
	STRUCT WMWinHookStruct &s

	Variable rval= 0
	strswitch(s.eventName)
		case "activate":
// #if 0 is useful while developing the panel so that activation doesn't alter the control changed by the just-deactivated dialog.
#if 1
			UpdateGizmoTexturePanel()
#else
			Print "activate update not implemented. see GraphTextureMakerPanelWindowHook()."
#endif
			break
	endswitch
	return rval
End

static Function/S ListOfGraphs(includeNone)
	Variable includeNone
	
	String graphs= SortList(WinList("*",";","WIN:1"),";",16)
	if( includeNone && strlen(graphs) == 0 )
		graphs += "_none_;"
	endif
	return graphs
End

static Function GraphWindowPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Variable graphExists= strlen(popStr) && WinType(popStr) == 1

	if(  graphExists )
		ControlInfo/W=$ksPanelName previewGraphCheck
		if( V_Value )
			BringGraphToNearlyFront(popStr)
		endif
		String/G $PanelDFVar("textureWaveName")= ProposedTextureName(popStr)
	endif
	
	UpdateGraphTitle(popStr)
	EnableDisableShowHide()
End

static Function BringGraphToNearlyFront(graphName)
	String graphName
	
	Variable graphExists= strlen(graphName) && WinType(graphName) == 1
	if(  graphExists )
		if( IsMacintosh() )
			HideTools/A/W=$ksPanelName	// avoid group-level bug on Macintosh.
		endif
		DoWindow/B=$ksPanelName $graphName
	endif
End


static Function OptimizeGraphForRGBButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo/W=$ksPanelName graphWindowPopup
	String graphName= S_Value
	ResizeGraphForTexture(graphName)
	
	UpdateGraphTitle(graphName) // the title shows the pixel sizes.
End


static Function RemoveMarginsFromGraphProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo/W=$ksPanelName graphWindowPopup
	String graphName= S_Value
	RemoveMarginsFromGraph(graphName)
	BringGraphToNearlyFront(graphName)	// so that the top window is the graph
	UpdateGraphTitle(graphName) // the title shows the pixel sizes.
End

static Function UpdateGraphTitle(graphName)
	String graphName

	String title=""
	Variable graphExists= strlen(graphName) && WinType(graphName) == 1
	if( graphExists )
		Variable widthPixels, heightPixels
		GraphSizes(graphName, widthPixels, heightPixels)
		GetWindow/Z $graphName wtitle	// wtitle requires Igor 6.20B03
		title= S_value+" (w x h = "+num2istr(widthPixels)+" x "+num2istr(heightPixels)+" pixels)"
	endif
	TitleBox graphTitle, win=$ksPanelName,title=title
End

// returns controlbar height (NaN if no graph by that name)
Static Function GraphSizes(graphName, widthPixels, heightPixels)
	String graphName
	Variable &widthPixels, &heightPixels
	
	Variable graphExists= strlen(graphName) && WinType(graphName) == 1
	if( graphExists )
		GetWindow/Z $graphName wsizeDC	// pixels
		widthPixels= abs(V_right-V_left)
		heightPixels= abs(V_bottom-V_top)	// heightPixels does NOT include the control bar height: if there's a control bar the window is actually taller.
		ControlInfo /W=$graphName kwControlBar
		Variable controlBarHeightPixels=V_Height
		return controlBarHeightPixels		// so that the coordinates for MoveWindow (which DOES include the control bar) will be right.
	else
		widthPixels= NaN
		heightPixels= NaN
		return NaN
	endif
End

static Function OverwriteCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	EnableDisableShowHide()
End


static Function TextureWaveNameSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	// enable/disable Make Texture button
	EnableDisableShowHide()
End

static Function EnableDisableShowHide()

	String proposedWaveName= StrVarOrDefault(PanelDFVar("textureWaveName"),"")
	
	// enable or disable the Make button based on whether the wave name is valid and the graph exists.
	ControlInfo/W=$ksPanelName graphWindowPopup
	String graphName= S_Value
	Variable graphExists= strlen(graphName) && WinType(graphName) == 1
	Variable modifyGraphDisable= graphExists ? 0 : 2

	Variable waveNameIsOkay= strlen(proposedWaveName) && CmpStr(proposedWaveName, CleanupName(proposedWaveName,1)) == 0
	Variable makeDisable= waveNameIsOkay && graphExists ? 0 : 2
	
	// update the Texture Wave Name and Make Texture control titles
	ControlInfo/W=$ksPanelName overwrite
	Variable overwrite= V_Value

	String nameTitle, makeTitle= "New Texture from Graph"
	if( overwrite )
		nameTitle= "Texture Wave Name"
		if( exists(proposedWaveName) == 1 )
			makeTitle= "Overwrite Texture from Graph"
		endif
	else
		nameTitle= "Texture Wave Name Prototype"
	endif
	SetVariable textureWaveName win=$ksPanelName, title= nameTitle
	Button makeTexturefromGraph win=$ksPanelName, title= makeTitle, disable=makeDisable
	
	ModifyControlList "resizeGraph;removeMargins;", win=$ksPanelName, disable=modifyGraphDisable
End

static Function UpdateTextureWavePathTitle(textureWave)
	Wave/Z textureWave

	String path="", info=""
	if( WaveExists(textureWave) )
		Variable widthPixels, heightPixels, layers, textureMode
		String pathToRGBSourceWave
		GetTextureDimensions(textureWave, widthPixels, heightPixels, layers, textureMode, pathToRGBSourceWave)
		path=GetWavesDataFolder(textureWave,2)
		info= path+" (w x h = "+num2istr(widthPixels)+" x "+num2istr(heightPixels)+" pixels) "
	endif
	String/G $PanelDFVar("createdTexturePath")= path
	String/G $PanelDFVar("createdTextureInfo")= info
	SetVariable createdTexturePath, win=$ksPanelName,variable=$PanelDFVar("createdTextureInfo")
End

static Function MakeTextureFromGraphButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo/W=$ksPanelName graphWindowPopup
	String graphName= S_Value

	if( strlen(graphName) && WinType(graphName) == 1 )
		String textureOutputWaveName= StrVarOrDefault(PanelDFVar("textureWaveName"),"")

		ControlInfo/W=$ksPanelName overwrite
		Variable doOverWrite= V_Value
		if( !doOverWrite )
			textureOutputWaveName= UniqueName(CleanupBaseName(textureOutputWaveName),1,0)		// in current data folder (probably root:)
		endif
		String tmpRGBAwaveName= UniqueName("tmp_rgba",1,0)
		Wave/Z rgba= CreateRGBImageOfGraph(graphName,tmpRGBAwaveName, wantAlpha=1)
		if( WaveExists(rgba) )
			InterpolateForTexture(rgba,tmpRGBAwaveName)	// in-place interpolation to power-of-two size			
			Redimension/U/B rgba			// ensure unsigned byte, suitable for ImageTransform imageToTexture
			WAVE/Z textureWave= CreateTextureFromRGB(rgba, textureOutputWaveName)
			KillWaves/Z rgba
			UpdateTextureWavePathTitle(textureWave)
		endif
	endif
End

static Function/S ProposedTextureName(graphName)
	String graphName
	
	String textureOutputWaveName
	if( WinType(graphName) == 1 )
		textureOutputWaveName= graphName[0,25]+"_txtr"
	else
		textureOutputWaveName= "Graph_txtr"
	endif
	return textureOutputWaveName
End

static StrConstant ksObjectControls="appendSphere;appendPlane;"

static Function ShowHideTextureObjects(popStr)
	String popStr	// S_Value from PopupMenu plane
	
	if( strlen(popStr) == 0 )
		ControlInfo/W=$ksPanelname plane
		popStr= S_Value
	endif
	String showThese=""
	strswitch( popStr )
		case "Wrapped around Object":
			showThese += "appendSphere;"
			break
		default:
			showThese += "appendPlane;"
			break
	endswitch
	String hideThese= RemoveFromList(showThese,ksObjectControls)
	ModifyControlList hideThese, win=$ksPanelName, disable=1
	ModifyControlList showThese, win=$ksPanelName, disable=0
End

static Function TextureCoordinatesPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	ShowHideTextureObjects(popStr)
End

static Function AddTextureButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String textureWavePath= StrVarOrDefault(PanelDFVar("createdTexturePath"),"")
	WAVE/Z textureWave= $textureWavePath
	if( !WaveExists(textureWave) )
		DoAlert 0, "Create a texture, first!"
		return 0
	endif
	String oldDF= SetPanelDF()
	String gizmoName= EnsureTopGizmo()
	String planeStr
	ControlInfo/W=$ksPanelName plane
	String choice= S_Value
	strswitch(choice)
		case "Wrapped around Object":
			planeStr=""
			break
		default:	// 	// "XY Plane;XZ Plane;YZ Plane;Background"
			planeStr=StringFromList(0,S_Value," ")
			break
	endswitch
	String objectName= AddGizmoTextureForPlane(gizmoName, textureWave, planeStr)

	UpdateTextureObjectTitle(objectName)

	SetDataFolder oldDF
End

static Function UpdateTextureObjectTitle(objectName)
	String objectName

	String/G $PanelDFVar("createdTextureObjectName")= objectName
	SetVariable appendedTextureObject, win=$ksPanelName,variable=$PanelDFVar("createdTextureObjectName")
End

static Function UpdateObjectTitle(objectName)
	String objectName

	String/G $PanelDFVar("createdObjectName")= objectName
	SetVariable appendedObject, win=$ksPanelName,variable=$PanelDFVar("createdObjectName")
End


static Function AppendSphereButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String gizmoName= EnsureTopGizmo()
	String waveAndObjectNames= MakeGizmoSphereForTexture()	// "" if cancelled, elser just the wave's name, or both the wave's and objects name as a ;-separated list
	String objectName= StringFromList(1,waveAndObjectNames)
	if( strlen(objectName) )
		UpdateObjectTitle(objectName)
		ApplyRecentTextureToObject(objectName,0)
	endif
End

static Function AppendPlaneButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String gizmoName= EnsureTopGizmo()
	ControlInfo/W=$ksPanelName plane
	String planeStr= StringFromList(0,S_Value," ")
	Variable isBackground= CmpStr(planeStr,"Background") == 0
	Variable constantOrthoVal
	
	if( isBackground )
		constantOrthoVal= -1.999
	else
		constantOrthoVal= -1	// user can edit a quad pretty easily. Start here
	endif
	String objectName= AddGizmoOrthoQuadPlane(gizmoName, planeStr,constantOrthoVal)
	if( strlen(objectName) )
		UpdateObjectTitle(objectName)
		if( isBackground )
			Variable mainTransformIndex= GetDisplayIndexOfNamedObject(gizmoName,"MainTransform")
			if( mainTransformIndex < 0 )
				String oldDF= SetPanelDF()
				String cmd= "ModifyGizmo/N="+gizmoName+" insertDisplayList=0, opName=MainTransform, operation=mainTransform"
				Execute/Q/Z cmd
				SetDataFolder oldDF
			endif
		endif
		ApplyRecentTextureToObject(objectName, isBackground)
	endif
End

static Function/S EnsureTopGizmo()

	String gizmoName= TopGizmo()
	if( strlen(gizmoName) == 0 )
		String oldDF= SetPanelDF()
		Execute "NewGizmo/I"
		gizmoName= TopGizmo()
		SetDataFolder oldDF
	endif
	return gizmoName
End

// This attempts to get the texture-object-clearTexture sequences in the display list all set up correctly.
static Function ApplyRecentTextureToObject(objectName,isBackground)
	String objectName	// sphere or plane may already be in the display list, maybe not
	Variable isBackground	// special handling: ensure a background image is before the MainTransform, WHICH MUST BE PRESENT ALREADY
	
	String recentTextureObject= StrVarOrDefault(PanelDFVar("createdTextureObjectName"),"")
	if( (strlen(objectName) == 0) || (strlen(recentTextureObject) == 0) )
		return 0
	endif
	String gizmoName= EnsureTopGizmo()
	// Find most recently appended texture object and use it 
		// Either move the sphere object to before the appended texture,
		// or insert the texture object before the sphere object in the display list.
	Variable mainTransformIndex= GetDisplayIndexOfNamedObject(gizmoName,"MainTransform")
	Variable textureDisplayIndex= GetDisplayIndexOfNamedObject(gizmoName,recentTextureObject)	// -1 if not in display list
	Variable objectDisplayIndex= GetDisplayIndexOfNamedObject(gizmoName,objectName)	// -1 if not in display list
	Variable insertHere
	
	String newClearTextureName= UniqueGizmoObjectName(gizmoName,"ClearTexture0","displayItemExists")
	
	Variable result= 1	// assume success
	if( objectDisplayIndex > textureDisplayIndex && textureDisplayIndex >= 0 )
		// texture is before the object
	else
		String cmd
		String oldDF= SetPanelDF()
		if( textureDisplayIndex < 0 && objectDisplayIndex < 0 )
			// neither is in the display list
			// append a clearTexture
			insertHere= isBackground ? mainTransformIndex : -1
			sprintf cmd, "ModifyGizmo/N=%s insertDisplayList=%d, opName=%s, operation=ClearTexture",gizmoName,insertHere,newClearTextureName
			Execute/Q/Z cmd
			objectDisplayIndex= GetDisplayIndexOfNamedObject(gizmoName,newClearTextureName)
			// insert the object in front of the clearTexture
			sprintf cmd, "ModifyGizmo/N=%s insertDisplayList=%d,object=%s",gizmoName,objectDisplayIndex,objectName
			Execute/Q/Z cmd
			objectDisplayIndex= GetDisplayIndexOfNamedObject(gizmoName,objectName)
			// insert the texture in front of the object
			sprintf cmd, "ModifyGizmo/N=%s insertDisplayList=%d,object=%s",gizmoName,objectDisplayIndex,recentTextureObject
			Execute/Q/Z cmd
		elseif( textureDisplayIndex < 0 )
			// the texture isn't in the display list, but now we know the object is
			// append a clearTexture after the object
			insertHere= objectDisplayIndex + 1
			sprintf cmd, "ModifyGizmo/N=%s insertDisplayList=%d, opName=%s, operation=ClearTexture",gizmoName,insertHere,newClearTextureName
			Execute/Q/Z cmd
			// Insert the texture before the object
			sprintf cmd, "ModifyGizmo/N=%s insertDisplayList=%d,object=%s",gizmoName,objectDisplayIndex,recentTextureObject
			Execute/Q/Z cmd
		elseif( objectDisplayIndex < 0 )
			// the object isn't in the display list, put it after the texture
			sprintf cmd, "ModifyGizmo/N=%s insertDisplayList=%d,object=%s",gizmoName,textureDisplayIndex+1,objectName
			Execute/Q/Z cmd
			objectDisplayIndex= GetDisplayIndexOfNamedObject(gizmoName,objectName)
			// append a clearTexture after the object
			insertHere= objectDisplayIndex + 1
			sprintf cmd, "ModifyGizmo/N=%s insertDisplayList=%d, opName=%s, operation=ClearTexture",gizmoName,insertHere,newClearTextureName
			Execute/Q/Z cmd
		else
			 // They're both in the list, but the object is before the texture.
			// delete the texture and put it before the first object
			RemoveMatchingGizmoDisplay(gizmoName,recentTextureObject)
			objectDisplayIndex= GetDisplayIndexOfNamedObject(gizmoName,objectName)	// -1 if not in display list
			sprintf cmd, "ModifyGizmo/N=%s insertDisplayList=%d,object=%s",gizmoName,objectDisplayIndex,recentTextureObject
			Execute/Q/Z cmd
		endif
		SetDataFolder oldDF
	endif
	// ensure there's a clearTexture right after the object.
	// This may leave extra clearTextures around, but that should be harmless
	objectDisplayIndex= GetDisplayIndexOfNamedObject(gizmoName,objectName)	// -1 if not in display list
	if( objectDisplayIndex >= 0 )
		EnsureClearTextureAtIndex(gizmoName, objectDisplayIndex+1)
	endif
	if( isBackground )	// ensure background objects are before the MainTransform, as needed
		mainTransformIndex= GetDisplayIndexOfNamedObject(gizmoName,"MainTransform")
		textureDisplayIndex= GetDisplayIndexOfNamedObject(gizmoName,recentTextureObject)	// -1 if not in display list
		objectDisplayIndex= GetDisplayIndexOfNamedObject(gizmoName,objectName)	// -1 if not in display list
		if( textureDisplayIndex > mainTransformIndex || objectDisplayIndex > mainTransformIndex )
			String clearTextureObjectName
			Variable nextItemIsClearObject= IsClearTextureAtIndex(gizmoName, objectDisplayIndex+1,opName=clearTextureObjectName)
			MoveObjectBeforeMainTransform(gizmoName,recentTextureObject)
			MoveObjectBeforeMainTransform(gizmoName,objectName)
			if(nextItemIsClearObject )
				MoveObjectBeforeMainTransform(gizmoName,clearTextureObjectName)
			endif
		endif
	endif
	return result
End

static Function IsClearTextureAtIndex(gizmoName, displayIndex [,opName])
	String gizmoName
	Variable displayIndex
	String &opName	// optional output

	String displayCommandList= GizmoList(gizmoName, "displayList")	// "ModifyGizmo setDisplayList=0, object=BackgroundTexture0;ModifyGizmo setDisplayList=1, opName=ClearTexture0, operation=ClearTexture;..."
	String commandAtDisplayList= StringFromList(displayIndex, displayCommandList)
	Variable start= strsearch(commandAtDisplayList, ", operation=ClearTexture", 0, 2)
	Variable isClearTexture= start > 0
	if( !ParamIsDefault(opName) )
		opName=""
		if( isClearTexture )
			Variable theEnd= start-1
			String key=", opName="
			start= strsearch(commandAtDisplayList, key, 0, 2)
			if( start > 0 )
				start += strlen(key)	// skip key
				opName=commandAtDisplayList[start,theEnd]
			endif
		endif
	endif
	return isClearTexture
End

static Function EnsureClearTextureAtIndex(gizmoName, displayIndex)
	String gizmoName
	Variable displayIndex
	
	if( !IsClearTextureAtIndex(gizmoName, displayIndex) )
		// append a clearTexture after the object
		String newClearTextureName= UniqueGizmoObjectName(gizmoName,"ClearTexture0","displayItemExists")
		String oldDF= SetPanelDF()
		Variable insertHere= displayIndex + 1
		String cmd
		sprintf cmd, "ModifyGizmo/N=%s insertDisplayList=%d, opName=%s, operation=ClearTexture",gizmoName,insertHere,newClearTextureName
		Execute/Q/Z cmd
		SetDataFolder oldDF
	endif
End

static Function CloseButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Execute/P/Q/Z "DoWindow/K "+ksPanelName
End

static Function HelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/F GizmoTextureHelp
	if( V_Flag == 0 )
		ShowGizmoTextureHelp()
	endif
End

static Function ShowGizmoTextureHelp()
	DoWindow/K GizmoTextureHelp
	NewPanel /N=GizmoTextureHelp/W=(965,46,1333,476)/K=1 as "Gizmo Texture Help"
	ModifyPanel/W=GizmoTextureHelp noEdit=1
	NewNotebook /F=1 /N=NB0 /W=(151,162,454,651)/FG=(FL,FT,FR,FB) /HOST=# 
	Notebook kwTopWin, defaultTab=36, statusWidth=0, autoSave=1, showRuler=0, rulerUnits=1
	Notebook kwTopWin newRuler=Normal, justification=0, margins={0,0,340}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,0,(0,0,0)}
	Notebook kwTopWin, zdata= "Gatm>9lM(B'qR9+K`P*qAU]M5UbN(LA?8>m:LjW]f@!i#8q3-c(*QMWhO36V5r6uZmMW,bWDj?I3,jO#%\\+sX*2\"^YU>X7T.P@7%E2JLsNon%,h(uCL,M=TQp0+NamanZ\"chG0*j%picGjnml2uBK82*?9TGaEUQGi1aFX&8KE\"8gC%rJ)nppT8@Y?4%?qEOD;mq>\"Z(#I!^i[+>]B<UVs:f,*3$,g2H\\].t&rP34uR;SM[D!C#JCr8q);MstYs0=5+9Y$tY`-PiPH84*up9JUTCLj>5jX=mZudm+<s`m^%2"
	Notebook kwTopWin, zdata= "YY'),h,_E3[Pnc^`\\tGP%4@3-RS;b(=f,)Y2iP%+8W&Zs//\"(W4H!`2.;0rP09HW]Lael6UiYA5=$/>!RM$_tm5]0&YOc69A9sLldMT=3Q`\"Bla'\"(L&LaPC23#3#K4Rfs,hEq\"#W@c3TkMG$lf8qS/E@\\('Ba@k1HHbbX3YgJeO'Gcmn>4^N?umd(u+>]Oj(pJ3oc*>mja`UNS2.f4e)jDRU@i+'0aYM?mrg3$HAW3CrhY@p]QqY(0`c3Xa$kX;C,!HKHa(,NqYi838s'$T?V!.AK$turE?i+rUueYf8YZ)"
	Notebook kwTopWin, zdata= "kq&Hc5]N6>BpLo2Ges.tdL\\!MlqWFn)RH.un_mueh67t)rPC`P*K8L7&u*kZ']Tb`7:8Xn%&RU=!WcodiCDf-*6J%>,=,MO3!HeRK7T0f'qm+4\\1q)?JSAKm)UHF\"@Y,;'+NfD+KehTH0opC3!a9BjI2`\\96>k_u^5.)`M@IWp<4OAfaJ)LMbf=T(;ksf0YqX.8Ul'Iqb%\"p&/P@tJ/<J>+@#V([pOl`R0qH?!H<-XA(RJPE&gD!T)hKpP>k(3m)#&S\\$;LsHDX:$q&s2*l`\\>hk)ZTr@_aBfBTn7gSm%daJ"
	Notebook kwTopWin, zdata= "R0@!K'J.7G?`K&26>HiEAe>9b+HpOC1Xf/1_'TG+k\"Ib)6tqnH8KjB0\"ZEu8K+4Og&JLT=%Y53]W%)Dp9[S+<+G(?C-D_'c\\di/hn`3u2*\\`dV*%:n<b&H.f@(&DE.\\#JiN9?U^@#>\",K;El<`FK-^c#r.ljs/#(%#h`)*ar,)4V0p/NC4$VR4X%Uf>&!R[!Bfk2-N?!!!#@83J`H-hmO,NAH4mP9GBrYQ9>XURsbEOHhZB5XgK6hDsb!%#<lq:h6N[;>S$Qf>6h:N43`2Z'D]g@Ai>mMlZ@uM<k(h/$u9Wm"
	Notebook kwTopWin, zdata= "^X-YDl.Z,rC:L!51<l&B:$b,?6cdRh%mQm&FGr#+e\\q9_C,S2uK:I^ie3/(dNgd\"$%ie>0el/s*/]J&G]jfFk5SnJ$SOJ%m7gh,!r_H\")#be`I6E&Jo9\"^W`<@A\"23X,`(1^0Af#\\C4]Ob_1Y.@W8H6OV8`5T-rj%&I'QMCP\"1+DBeCFFY)[aCDBSKtu_)T!M3;BQdVW=4tQ9\"eeN48OIPfQGq\"`NeN(q:044JaeD\"'oM:eNd?9!bm#RJ2PO&53qJ<FC9-Y8[:9b_^Lg!m_Z5Y;r4B)GecBTJY@CI'XOe/1^"
	Notebook kwTopWin, zdata= "s#,l'&Nm]#\"44GL\"k'9bcVB*<bChA=1D'3F>5X:J&B7d!CMmE'Ni.GoM4g+/H@Z3$R32rUiIr7!KFA%6a]!d1=-8o7M='ig>0A$,\"%\"LUWX9J,8bLH0<4B\\[?MPP\"XS##$AFh,3TH$U_/(b1STsacR@#hIEa+HR23:.=n1$!5qX=33CJ(WD&HuHX)]C)\"UmpiG=7n?$o*%@:\"+,Bf)WSV$R(_@c,!N=D&3@G-,Eh-,kTER;%b,FAJZf9@gem(p>h*sk5=*'G&F2K3'.Asd`phXt3VY-f*)'Ur>Eji!Q/:.DU"
	Notebook kwTopWin, zdata= "mHgsi[G>Z.(ig@(_&7T_Y>(Vl2dWuKBH,#ec'ePt27bd_J>l\"K.VaNE=E-aR#^TIf01Y5-E['N]!!`'AQ;'Z$\"6VFO!G-e-l+Ebll-\\mli^7a1G?hAYBV&g5%$FODS5]o@@V`7,Wo2I2h&o4D'\\X_k^r0;(%?G@-S9Z)Gj^EDF5k5uA*:f?\"&bt>#arpYB^?%hE%VVL9V<04th]7_r`#tc!OHZ98JqXP@7,9:nba/42OKXd>KEbOV@GC476OK.!_#dbggFkh>_*e_@0h,F_r!ec9@>uSN9u_Z#?^]%Gd5$/4"
	Notebook kwTopWin, zdata= "&OE!gX2<LL)1*2H&X;R*jO<<Ak/+2$2??O50HQ.Zc<[%LWB_iJ3hm'$E6M<-F'XmM0!p.BL\"U;>q(_<O%jG#<NQfW:N4[sab>Sg9pkaA'&uX&U3(/*=,/I:_Q%TZUT5HRp,!8i4]sb%TQAK.6&a::&SZt%$gtCXgDImS;6DI^U<i:`i3RdL_ME3G,3?<Pl;J9=C`9*`lEG4V!!>q?+qga5!1>;+rVMG[EWX/u-8#;YWd=rmM!-jqmfQBK<.0rQ8'HfiLTi=P^O,):s!kX6!c9o>cRi0kHk/tU^)LU*U@%5T1"
	Notebook kwTopWin, zdata= "`W^OK]bl9`6_HlZ0+9F,3OY\\`TFXeW@lZBb@Rl/MG;LX7Q]4QddqdOG[X=5e2j)-j[8#K=b3EfNiX1ZM*']'u`19;>U0OJ%2>7!/=]nbZHo<gfZFEa+cMMGX?u,4=X8TKAoKeJ\\n\"*27:3-N[B$7sfqXR7Le2PZ!ol+][^$.3-]_+R]h9L6@c.:IcB%mW_PhA0cbk5S[H%59jVqLc^h,mp]eTU7`OrkaH*B#\"IHmN@4>#)'QiQ^u]:q><L(DgucMtgrDAt=(i[mPLY#Id5%%]<s]Mdn`N/in9]#67iCU/hQK"
	Notebook kwTopWin, zdata= "GB/%si3\"H_$I%&7L^,9g%8*)C.KTF?!UC>(doA9oM5fgKihC7Jd%jYR]bEmXSmknc-,JI%Al)Bu+c]&&Vk'h1V<G>u^od\\9e/2,\"CT(1V]`BOgQNj0\\#sfH,)N4fE#YddCXntE3H5I3HfrHq)Ued:_Jt3ti\"^t4A0?\"EZ9?g2Be9':PJY<:p[KI)%k7j\"GI-)!_@>]gfPQjTC2%)(kl(3=[?0p+1ZZ(\\g\\kaVfJ6t0Q(Tc;T7hOrlH=E!:[kS\"^M#hEDk[Li:#Vg!Dl&pTBH3L-CXJbgnb)@so6KNqQ_ZN^Y"
	Notebook kwTopWin, zdata= "`C<6fEl[7S0p/c%ZmsVk%OS`/A%)71G8aVe^YS=I-O'X?DY6W6c:2orcakj/#%?Kl^mmQG\\OsmKA.s<sH.]gPL<s9#n?+<o)0G%qVWiml;()qU/0]V-!9cn0%9&pqetn^F42&IfApDNC+[UA0P/nQCpjKuq;(I\"FD(c3hKfUsU+ZKJu5_hLD4#F<s,:2$NN3:mnc+C^9?C%>A@[c[?-1(dgS>(Q;'*pS@El5jnVBoc5dq>G,]pc2bFkGiSH.\"EM!prX6CEY8:e[-Vhk+RY8(r.[:``EhlILk-9*Wr[cH\\g]S"
	Notebook kwTopWin, zdata= "bg;%k`^a]5-XNd<cY$K:drUfrjR]%SQ9bPu#P*EM%*NJ04.;d9p'eNu:uTMQi]2je%AW&njAXnPZceVc(uIS][W#Lq_2DB0,em%=lcGRn\\QH?0mAYNS8u5a<3\\d+e\\2(\\70`q#&BK/bYC:WA`&o4GpUt#:J90Inc9hO;&L\\*ANe&NX3/Aa4iIt('STU8.k\"JIo8^)ZK+cZ:H_?jj`T$!6rRV^L,@DQ_c$XKg7*e+Qr8RGB9W4PU8e`LtgfoS]9??e:k0_:*R0/p9LqKN\",F@D8uoGb6O!hR,7GGhPpEI>_I_"
	Notebook kwTopWin, zdata= "'VCV1n2)RQ$@PPl03+:?Z2Mg;bt_?4$,]eFlgX4^AGh\"XP18__V%H<k#OP??HKN?hn&#^AX3Rd&Lir5#,3T+t`<'(@`eF8%\")SA+b<,$DF\"_h=Ccq_[0%`:-DY<[*muqA^L\\9]>=B=Igp,-$^li&E\\RBKCJ$+2j%YWKVbiVs)fQX6fMq^(\\Wn#I8gQclRXCYkb/jF-7jh#!**=776f^V,]@cSSsG>]4F8hJ('N:E$uar\"eq;#h)\"XlHY`(m#0^:]]VP8(VIrJPOEqA]DL\"3s0=k9G;ho>Nk)V''He%2gD'1_"
	Notebook kwTopWin, zdata= "^h5hBA18%b[k!1uA(?^Nc]PK.dVD@0d,#Zp$/Um&_bnjEZ!5O^\\s\\)@fRZ_@l8;QEp>49rLjMqs#=W-^>Q"
	Notebook kwTopWin, zdataEnd= 1
	Notebook kwTopWin, writeProtect=1
	RenameWindow #,NB0
	SetActiveSubwindow ##
	AutoPositionWindow/E GizmoTextureHelp
EndMacro

// ----------------------------------- END Graph Texture Maker Panel -----------------------------------


Function/S MakeGizmoSphereForTexture()

	Variable dataRadius=100
	Variable numberOfSegmentsPerCircle=100
	String outName="paramSphereWave"
	Prompt dataRadius, "Radius (in Data coordinates):"
	Prompt numberOfSegmentsPerCircle, "Number of Segments Per Circle:"
	Prompt outName, "Name of Wave (overwritten):"
	DoPrompt "Make paramSphereWave for Texture", dataRadius,numberOfSegmentsPerCircle,outName
	if (V_Flag)
		return ""								// User canceled
	endif
	WAVE sphere = MakeParamSphereForTexture(dataRadius,numberOfSegmentsPerCircle,outName)
	String gizmoName=TopGizmo()
	if( ValidGizmoName(gizmoName) )
		RemoveMatchingGizmoObjects(gizmoName,outName)
		String cmd
		sprintf cmd, "AppendToGizmo/N=%s/D Surface=%s, name=%s", gizmoName, GetWavesDataFolder(sphere,2),outName
		GizmoEchoExecute(cmd, slashZ=1)
		sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s property={ srcMode,4}", gizmoName,outName
		GizmoEchoExecute(cmd, slashZ=1)
		sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s property={ textureType,1}", gizmoName,outName
		GizmoEchoExecute(cmd, slashZ=1)

		outName += ";"+outName+";"
	endif
	return outName	// either just the wave's name, or both the wave's and objects name as a ;-separated list
End

// The order of the angles is designed so that 
// a texture created from a graph
// wraps from Gizmo's X axis cue towards the Y axis cue,
// with the Gizmo Z axis cue as "up" = increasing Y/left graph values.
//
Function/WAVE MakeParamSphereForTexture(radius,num,name)
	Variable radius,num
	String name
	
	Make/O/N=(num+1,num+1,3) $name/WAVE=paramSphereWave
	Variable i,j,theta,phi,xx,yy,zz,nm1=num-1,ss,tt
	Variable	angX, angY;

	for(i=0; i<=num; i+=1)
		angX = Pi/2 -(i * 360/ num) * PI / 180
		for (j=0; j<=num; j+=1)
			angY = (-90 + (j * 180 / num)) * PI / 180

			paramSphereWave[i][j][0] = radius * abs(cos(angY)) * sin(angX)	// x
			paramSphereWave[i][j][1] = radius * abs(cos(angY)) * cos(angX)	// y
			paramSphereWave[i][j][2] = radius * -sin(angY);					// z
		endfor
	endfor
	return paramSphereWave
End

// ----------------------------------- Panel Utilities -----------------------------------

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

Static Function IsMacintosh()

	String platform= IgorInfo(2)
	return CmpStr(platform,"Macintosh") == 0
End


// ----------------------------------- Panel-specific variables -----------------------------------

static StrConstant ksPackagePath= "root:Packages:GizmoTextures"
static StrConstant ksPackageName = "GizmoTextures"

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

// ----------------------------------- Gizmo Texture processing routines -----------------------------------

// returns RGB (or RGBA) image wave representing the graph with red, green, blue, alpha values in the range of 0-255
Function/WAVE CreateRGBImageOfGraph(graphName, outputWaveName [,wantAlpha,transparentRed, transparentGreen, transparentBlue, transparentError])
	String graphName
	String outputWaveName			// name of created wave. Overwrites any existing wave of that name.
	Variable wantAlpha				// optional input, defaults to false.	If true, wantTexture should be at least 16. If false, wantTexture should be less than 16.
	Variable transparentRed, transparentGreen, transparentBlue	// optional input, defaults to nothing being transparent. Set all three, to values between 0 and 255 (white is 255,255,255)
	Variable transparentError		// optional input, defaults to 0, a simple equality check. Else it is the walking distance of the color errors. Reasonable values are 0-10, 3 allows error of 1 in each color component.
	
	if( strlen(graphName) == 0 )
		return $""
	endif
	DoWindow $graphName
	if( V_Flag == 0 )
		return $""
	endif

	if( ParamIsDefault(wantAlpha) )
		wantAlpha= 0
	endif

	// convert to rgb by saving the windows as PNG and reading it back
	String fileName= RemoveEnding(outputWaveName,".png")+".png"
	NewPath/O/Q WMGizmoTexturesTemp, SpecialDirPath("Temporary", 0, 0, 1)
	SavePICT/O/E=-5/B=72/WIN=$graphName/P=WMGizmoTexturesTemp as fileName
	ImageLoad/Q/T=rpng/P=WMGizmoTexturesTemp fileName
	KillPath/Z WMGizmoTexturesTemp
	String loadedAsWaveNamed= StringFromList(0,S_waveNames)
	WAVE/Z rgb= $loadedAsWaveNamed
	if( CmpStr(loadedAsWaveNamed, outputWaveName) != 0 )
		Wave/Z waveToOverwrite= $outputWaveName
		if( WaveExists(waveToOverwrite) )
			// this method works if waveToOverwrite can't be killed because it's in use
			Duplicate/O rgb, waveToOverwrite
			KillWaves/Z rgb
			WAVE/Z rgb= waveToOverwrite
		else
			Rename rgb, $outputWaveName
		endif
	endif
	if( WaveExists(rgb) && wantAlpha )
		Redimension/N=(-1,-1,4) rgb
		if( !ParamIsDefault(transparentRed) &&  !ParamIsDefault(transparentGreen) &&  !ParamIsDefault(transparentBlue) )
			// matching color everywhere is set to transparent
			if( ParamIsDefault(transparentError) )
				transparentError= 0
			endif
			if( transparentError > 0 )
				// this is a bit slower than the equality test
				MultiThread rgb[][][3]= ((abs(rgb[p][q][0]-transparentRed) + abs(rgb[p][q][1]-transparentGreen) + abs(rgb[p][q][2]-transparentBlue)) <= transparentError) ? 0 : 255
			else
				MultiThread rgb[][][3]= (rgb[p][q][0] == transparentRed && rgb[p][q][1] == transparentGreen && rgb[p][q][2] == transparentBlue ) ? 0 : 255
			endif
		else
			MultiThread rgb[][][3]= 255	// now rgba format, but still completely opaque
		endif
	endif

	return rgb
End

// returns wave reference to created texture wave, or NULL if error.
Function/WAVE CreateRGBATextureFromImagePlot(imagePlotWindowName, imageInstanceName, textureWaveName[,transparentRed, transparentGreen, transparentBlue, transparentError])
	String imagePlotWindowName, imageInstanceName, textureWaveName
	Variable transparentRed, transparentGreen, transparentBlue	// optional input, defaults to nothing being transparent. Set all three, to values between 0 and 255 (white is 255,255,255)
	Variable transparentError		// optional input, defaults to 0, a simple equality check. Else it is the walking distance of the color errors. Reasonable values are 0-10, 3 allows error of 1 in each color component.

	if( strlen(imagePlotWindowName) == 0 )
		return $""
	endif
	DoWindow $imagePlotWindowName
	if( V_Flag == 0 )
		return $""
	endif

	WAVE/Z image= ImageNameToWaveRef(imagePlotWindowName, imageInstanceName)
	if( !WaveExists(image) )
		return $""
	endif

	Variable rows= DimSize(image,0)	// x dimension, top or bottom axis
	Variable cols= DimSize(image,1)	// y dimension, left or right axis

	String str
	if( (rows < 2) || (cols < 2) )
		str= NameOfWave(image)+" is not a 2-D wave!"
		Print str
		DoAlert 0, str
		return $""
	endif
	
	Variable neededRows= CeilPwr2(rows)		
	Variable neededColumns= CeilPwr2(cols)	
	if( (rows != neededRows) || (cols != neededColumns ) )
		str= NameOfWave(image)+" needs to be interpolated to power of two rows and columns."	// Click \"Interpolate Image..\" button."
		Print str
		DoAlert 0, str
		return $""
	endif
	
	// update graph size to per-pixel with no margins
	Variable widthPoints= 72/ScreenResolution * rows
	Variable heightPoints= 72/ScreenResolution * cols
	ModifyGraph/W=$imagePlotWindowName margin=-1,width=widthPoints,height=heightPoints
	DoUpdate
	
	// convert to rgba by saving as PNG and reading it back
	if( ParamIsDefault(transparentRed) || ParamIsDefault(transparentGreen) || ParamIsDefault(transparentBlue) )
		WAVE/Z rgba= CreateRGBImageOfGraph(imagePlotWindowName, textureWaveName, wantAlpha=1)
	else
		if( ParamIsDefault(transparentError) )
			transparentError= 0
		endif
		WAVE/Z rgba= CreateRGBImageOfGraph(imagePlotWindowName, textureWaveName, wantAlpha=1,transparentRed=transparentRed,transparentGreen=transparentGreen,transparentBlue=transparentBlue,transparentError=transparentError)
	endif
	
	if( !WaveExists(rgba) )
		Print "Failed to create RGB image from "+imagePlotWindowName
		return $""
	endif
	
	// convert to texture
	WAVE/Z output= CreateTextureFromRGB(rgba, textureWaveName)
	KillWaves/Z rgba

	return output
End

// returns truth that the graph was resized.
Function ResizeGraphForTexture(graphName)
	String graphName

	Variable widthPixels, heightPixels	// pixels of entire window content, excluding control bar
	Variable controlBarHeightPixels= GraphSizes(graphName, widthPixels, heightPixels)
	if( numtype(controlBarHeightPixels) == 0 )
		Variable neededWidth= CeilPwr2(widthPixels)
		Variable neededHeight= CeilPwr2(heightPixels)

		if( (widthPixels != neededWidth ) ||  (heightPixels != neededHeight) )
			// convert to points, because that's what MoveWindow needs.
			GetWindow/Z $graphName wsize	// points
			Variable top= V_Top
			Variable left= V_Left
			neededWidth *= 72 / ScreenResolution	// pixels-to-points
			neededHeight += controlBarHeightPixels
			neededHeight *= 72 / ScreenResolution
			Variable right= left+neededWidth
			Variable bottom= top+neededHeight
			ModifyGraph/W=$graphName width=0,height=0		// in case the graph has absolute or plan modes set.
			MoveWindow/W=$graphName left, top, right, bottom	// if the window has a resize hook, it's going to override this...
			return 1
		endif
	endif
	return 0
End

static Function RemoveMarginsFromGraph(graphName)
	String graphName

	Variable graphExists= WinType(graphName) == 1
	if( graphExists )
		ModifyGraph/W=$graphName margin=-1, nolabel=2, standoff=0
	endif
End

// returns NULL if no interpolation needed, or error
// Textures need to be a sized to a power of 2.
// NOTE: This routine does not check or alter the data type or scale the rgb values.
// The interpolated wave is created in the current data folder.
Function/WAVE InterpolateForTexture(imageWave,interpolatedImageWaveName [,newWidthRows,newHeightCols])
	Wave/Z imageWave					// expected to be an RGB wave containing values with layer [][][0]=red, [][][1]=green, [][][2]=blue. The values may be 0-1 or 0-255, or 0-65535
	String interpolatedImageWaveName	// can be same as imageWave
	Variable  newWidthRows,newHeightCols	// optional, if default, DimSize(imageWave,0), etc. 

	if( !WaveExists(imageWave) )
		return imageWave	// NULL
	endif
											
	Variable rows= DimSize(imageWave,0)	// x dimension, top or bottom axis
	Variable cols= DimSize(imageWave,1)	// y dimension, left or right axis
	if( (rows < 2) || (cols < 2) )
		return $""	// NULL: need a 2-D wave!
	endif

	if( ParamIsDefault(newWidthRows) )
		newWidthRows= rows	// x dimension, top or bottom axis
	endif								
	if( ParamIsDefault(newHeightCols) )
		newHeightCols= cols		// y dimension, left or right axis
	endif								
	if( (newWidthRows < 2) || (newHeightCols < 2) )
		return $""	// NULL: need a 2-D wave!
	endif

	Variable neededRows= CeilPwr2(newWidthRows)
	Variable neededColumns= CeilPwr2(newHeightCols)

	if( (rows == neededRows ) &&  (cols ==neededColumns ) )
		return $""	// NULL: already interpolated!
	endif

	ImageInterpolate/RESL={neededRows,neededColumns} bilinear imageWave
	WAVE interpolated= M_InterpolatedImage	// creates or overwrites M_InterpolatedImage, a single-precision wave.
	CopyScales/I imageWave,interpolated

	WAVE/Z output=$interpolatedImageWaveName
	if( CmpStr(interpolatedImageWaveName,"M_InterpolatedImage") != 0 )
		// see we we're overwriting the output (which is allowed)
		if( WaveExists(output) )
			Duplicate/O interpolated, output
			KillWaves/Z interpolated
		else
			Rename interpolated, $interpolatedImageWaveName
			WAVE output=$interpolatedImageWaveName
		endif
	endif
	
	return output
End

Function/S SaveTextureDimensions(sourceWave, textureWave, textureMode)
	Wave sourceWave							// input wave passed to ImageTransform/TEXT=8,9,16, or 17 imageToTexture
	Wave textureWave						// texture wave made by ImageTransform/TEXT=8,9,16, or 17 imageToTexture
	Variable textureMode					// ImageTransform/TEXT=(textureMode)
	
	Variable widthPixels= DimSize(sourceWave,0)
	Variable heightPixels= DimSize(sourceWave,1)
	Variable layers= DimSize(sourceWave,2)
	
	String wavenote= note(textureWave)
	wavenote= ReplaceNumberByKey("WIDTHPIXELS", wavenote, widthPixels)
	wavenote= ReplaceNumberByKey("HEIGHTPIXELS", wavenote, heightPixels)
	wavenote= ReplaceNumberByKey("LAYERS", wavenote, layers)
	wavenote= ReplaceNumberByKey("TEXTUREMODE", wavenote, textureMode)
	wavenote= ReplaceStringByKey("SOURCEWAVE", wavenote, GetWavesDataFolder(sourceWave,2))
	Note/K textureWave, waveNote
	
	return waveNote
End

// retrieves values added by either ImageTransform or CreateTexture routines,
// returns truth that the numeric values were found
Function GetTextureDimensions(textureWave, widthPixels, heightPixels, layers, textureMode, pathToSourceWave)
	Wave textureWave					// texture wave made by ImageTransform/TEXT=8,9,16, or 17 imageToTexture
	Variable &widthPixels, &heightPixels	// Outputs: texture dimensions
	Variable &layers					// Output: texture layers
	Variable &textureMode			// Output: ImageTransform/TEXT=(textureMode)
	String &pathToSourceWave	// output: path to wave passed to ImageTransform and SaveTextureDimensions()

	String wavenote= note(textureWave)
	widthPixels= NumberByKey("WIDTHPIXELS",wavenote)
	heightPixels= NumberByKey("HEIGHTPIXELS",wavenote)
	layers= NumberByKey("LAYERS",wavenote)
	textureMode= NumberByKey("TEXTUREMODE",wavenote)
	pathToSourceWave= StringByKey("SOURCEWAVE",wavenote)
	
	return numtype(widthPixels) == 0 && numtype(heightPixels) == 0 && numtype(layers) == 0 && numtype(textureMode) == 0	// omits testing pathToSourceWave
End

// ensure that rgbaWave is of type /U/B before calling this routine:
//	Redimension/U/B rgbaWave
// The texture wave is created in the current data folder,
// but care is taken to not generate the standard W_Texture in the current data folder
// to avoid overwriting a user's W_Texture.
Function/WAVE CreateTextureFromRGB(rgbaWave, textureWaveOutName)
	Wave rgbaWave		// unsigned byte, 3 or 4 layers, values must be 0-255 (actually this can be a 2-D wave; a luminance texture is created)
	String textureWaveOutName	// if it exists, the wave is overwritten
	
	// ImageTransform imageToTexture needs a unsigned byte wave filled with 0-255
	Variable textureWidthPixels= DimSize(rgbaWave,0)	// interpolated and rotated dimensions
	Variable textureHeightPixels= DimSize(rgbaWave,1)
	Variable layers= DimSize(rgbaWave,2)
	Variable textureMode= layers > 3 ? 17 : (layers == 3 ? 9 : 5)
	
	String oldDF= SetPanelDF()
	ImageTransform/TEXT=(textureMode) imageToTexture rgbaWave	// creates W_Texture (ImageTransform ignores /O)
	WAVE texture= W_Texture
	SetDataFolder oldDF
	
	String pathToW_Texture= GetWavesDataFolder(texture,2)
	String pathToTextureOutName= GetDataFolder(1)+PossiblyQuoteName(textureWaveOutName)

	if( CmpStr(pathToW_Texture, pathToTextureOutName) != 0 )
		Wave/Z waveToOverwrite= $textureWaveOutName
		if( WaveExists(waveToOverwrite) )
			// this method works if waveToOverwrite can't be killed because it's in use
			Duplicate/O texture, waveToOverwrite
			KillWaves/Z texture
			WAVE/Z texture= waveToOverwrite
		else
			Duplicate/O texture, $textureWaveOutName
		endif
	endif
	WAVE texture=$textureWaveOutName

	SaveTextureDimensions(rgbaWave,texture,textureMode)
	return texture
End

// returns the names of the added texture object or "" if error.
// Presumably this is applied to a quad, and the quad's color is ignored by using GL_REPLACE instead of GL_DECAL
Function/S AddGizmoTextureForPlane(gizmoName, textureWave, planeStr [, hasAlpha, widthPixels, heightPixels,textureName,doNearestNeighbor])
	String gizmoName
	Wave textureWave					// texture wave made by ImageTransform/TEXT=8,9,16, or 17 imageToTexture
	String planeStr						// "XY", "XZ", or "YZ": the plane for which the texture is designed. This affects the SCoordinate and TCoordinates.
										// "Z", "Y", or "X" are corresponding single-letter synonyms naming the perpendicular plane.
										// Set to "" to set SGenMode and TGenMode=0
	Variable hasAlpha					// optional: set to true if the texture is rgba, to false if only rgb. default is to ask the texture or default to rgb.
	Variable widthPixels, heightPixels	// optional: texture dimensions (if not supplied, they must be the textureWave's wave note)
	Variable doNearestNeighbor			// optional: if true, use nearest neighbor for the texture instead of linear. By default nearest neighbor is used if either width or height is less than 256 pixels.
	String textureName					// optional: If given, any object of that name is first deleted. Otherwise, a uniquely named object created.

	if( !ValidGizmoName(gizmoName) )
		return ""
	endif
	
	if( !WaveExists(textureWave) )
		return ""
	endif
	
	if( ParamIsDefault(widthPixels) || ParamIsDefault(heightPixels) || ParamIsDefault(hasAlpha) )
		Variable textureMode, layers= 3
		String pathToRGBSourceWave
		if( !GetTextureDimensions(textureWave, widthPixels, heightPixels, layers, textureMode, pathToRGBSourceWave) )
			return ""
		endif
		hasAlpha= layers > 3
	endif
	if( ParamIsDefault(doNearestNeighbor) )
		doNearestNeighbor = (widthPixels <= 256) || (heightPixels <= 256)
	endif

	
	Variable sP1, sP2, sP3, sP4	// s corresponds to the x dimension (rows) of the texture
	Variable tP1, tP2, tP3, tP4	// t corresponds to the y dimension (cols) of the texture
	// For example, the s (x) dimension of the texture is mapped to x,y,z surface's ortho-transformed dimensions
	// through the transform:
	//	texture x [0-1] range = sP1 * x + sP2 * y + sP3 * z + sp4
	// So in if the surface is in the XY plane, then to map the x of the texture to x of the surface, use:
	//	sP1= 0.5, sP4 = 0.5, and the others to 0 so that they don't affect which x coordinate of the texture is chosen.
	// The constant 0.5 appears to be related to wrapping the surface given that the ortho range of a full plane is -1 to +1.
	// using surface ortho x = -1 to 1, that'd give texture x = 0 to 1
	// Now for y, set tP2 = 0.5, and for the same reason set tP4 to 0.5
	sP4= 0.5
	tP4 = 0.5
	strswitch( PlaneSpecToPerpendicularPlane(planeStr) )
		case "":
			sP4= 0
			tP4 = 0
			break;
		case "Background":
			Variable left, right, bottom, top, zNear, zFar
			GetGizmoOrtho(gizmoName, left, right, bottom, top, zNear, zFar)
			// the following calculations are explained in AdjustBackgroundQuadForOrtho()
			sP1 = 1 / (right-left)
			sP4 = - left * sP1
			tP2= 1 / (bottom - top)	// check: if bottom = -2 and top = 2 , this should be -0.25
			tP4 = - top * tP2		// check: if bottom = -2 and top = 2 , this should be 0.5
			break
		case "Z":	// XY
			sP1= 0.5	// texture x depends on data x
			tP2= 0.5	// texture y depends on data y
			break
		case "Y":	// XZ
			sP1= 0.5	// texture x depends on data x
			tP3= 0.5	// texture y depends on data z
			break
		case "X":	// YZ
			sP2= 0.5	// texture x depends on data y
			tP3= 0.5	// texture y depends on data z
			break
	endswitch

	if( ParamIsDefault(textureName) )
		String prototypeName
		if( strlen(planeStr) == 0 )
			prototypeName= "wrappingTexture0"
		else
			prototypeName= planeStr+"Texture0"
		endif
		textureName = UniqueGizmoObjectName(gizmoName,prototypeName,"objectItemExists")
	else
		RemoveMatchingGizmoObjects(gizmoName,textureName)
	endif

	String cmd
	sprintf cmd, "AppendToGizmo/N=%s texture=%s",gizmoName,textureName
	Execute cmd
	sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s property={ PRIORITY,1}",gizmoName,textureName
	Execute cmd

	if( doNearestNeighbor )
		sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s  property={ MAGMODE,9728}",gizmoName,textureName
		Execute cmd
		sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s  property={ MINMODE,9728}",gizmoName,textureName
		Execute cmd
	endif

	sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s  property={ ENVMODE,GL_REPLACE}",gizmoName,textureName	// not GL_DECAL, because that requires the object to be colored.
	Execute cmd
	sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s  property={ WIDTH,%d}",gizmoName,textureName,widthPixels
	Execute cmd
	sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s  property={ HEIGHT,%d}",gizmoName,textureName,heightPixels
	Execute cmd
	
	if( hasAlpha )
		sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s  property={ DATAFORMAT,GL_RGBA}",gizmoName,textureName
	else
		sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s  property={ DATAFORMAT,GL_RGB}",gizmoName,textureName
	endif
	Execute cmd

	String textureWavePath=GetWavesDataFolder(textureWave,2)
	sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s property={ SRCWAVE,%s}",gizmoName,textureName,textureWavePath
	Execute cmd
	if( strlen(planeStr) )
		sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s  property={ SCoordinates,%g,%g,%g,%g}",gizmoName,textureName, sP1, sP2, sP3, sP4
		Execute cmd
		sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s  property={ TCoordinates,%g,%g,%g,%g}",gizmoName,textureName, tP1, tP2, tP3, tP4
		Execute cmd
	else
		// suitable for wrapping around a sphere
		sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s  property={ SGENMODE,0}",gizmoName,textureName
		Execute cmd
		sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s  property={ TGENMODE,0}",gizmoName,textureName
		Execute cmd
	endif
	
	return textureName
End


// Returns the name of the created quad object, which is prepared for a texture.
// Does not append anything to the display list.
//
// AddGizmoOrthoQuadPlane uses an ortho coordinate system.
//
// Also see AddGizmoDataQuadPlane(), which uses a data coordinate system.
//
// NOTE: To modify a quad (one named "quad0" in this example), use:
// 	ModifyGizmo modifyobject=quad0, property={vertex,x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4}
//
Function/S AddGizmoOrthoQuadPlane(gizmoName, planeStr, constantOrthoVal [,orthoMaxValue,quadName,clipped,calcNormals])
	String gizmoName
	String planeStr						// "XY", "XZ", "YZ" or "Background": the plane in which the quad lies.
										// "Z", "Y", or "X" are corresponding single-letter synonyms naming the perpendicular plane.
	Variable constantOrthoVal			// plane= constant value. If planeStr is "XY", then this is the constant z value, in ortho coordinates
	Variable orthoMaxValue				// optional: overrides the default ortho -1 to 1 range for the quad. Pass 2 to get -2 to 2.
	String quadName					// optional: If given, any object of that name is first deleted. Otherwise, a uniquely named object created.
	Variable clipped						// optional: default is 0 (not clipped)
	Variable calcNormals				// optional: default is 1
	
	if( !ValidGizmoName(gizmoName) )
		return ""
	endif
	
	if( ParamIsDefault(orthoMaxValue) )
		if( CmpStr(planeStr,"Background") == 0 )
			Variable left, right, bottom, top, zNear, zFar
			GetGizmoOrtho(gizmoName, left, right, bottom, top, zNear, zFar)
		else
			orthoMaxValue =  1
		endif
	endif
	
	if( ParamIsDefault(quadName) )
		quadName= UniqueGizmoObjectName(gizmoName,"planeOrthoQuad0","objectItemExists")
	else
		RemoveMatchingGizmoObjects(gizmoName,quadName)
	endif
	
	Variable x1,y1,z1
	Variable x2,y2,z2
	Variable x3,y3,z3
	Variable x4,y4,z4
	
	strswitch( PlaneSpecToPerpendicularPlane(planeStr) )
		case "Background":
			x1= left
			x2= left
			x3= right
			x4= right
			
			y1= bottom
			y2= top
			y3= top
			y4= bottom
			
			z1= constantOrthoVal
			z2= constantOrthoVal
			z3= constantOrthoVal
			z4= constantOrthoVal
			break
			
		case "Z":	// XY
			x1= -orthoMaxValue
			x2= -orthoMaxValue
			x3= orthoMaxValue
			x4= orthoMaxValue
			
			y1= -orthoMaxValue
			y2= orthoMaxValue
			y3= orthoMaxValue
			y4= -orthoMaxValue
			
			z1= constantOrthoVal
			z2= constantOrthoVal
			z3= constantOrthoVal
			z4= constantOrthoVal
			break
			
		case "Y":	// XZ
			x1= -orthoMaxValue
			x2= -orthoMaxValue
			x3= orthoMaxValue
			x4= orthoMaxValue

			y1= constantOrthoVal
			y2= constantOrthoVal
			y3= constantOrthoVal
			y4= constantOrthoVal

			z1= -orthoMaxValue
			z2= orthoMaxValue
			z3= orthoMaxValue
			z4= -orthoMaxValue
			break
			
		case "X":	// YZ
			x1= constantOrthoVal
			x2= constantOrthoVal
			x3= constantOrthoVal
			x4= constantOrthoVal

			y1= -orthoMaxValue
			y2= -orthoMaxValue
			y3= orthoMaxValue
			y4= orthoMaxValue
			
			z1= -orthoMaxValue
			z2= orthoMaxValue
			z3= orthoMaxValue
			z4= -orthoMaxValue
			break
	endswitch
	
	if( ParamIsDefault(clipped) )
		clipped= 0
	endif
	if( ParamIsDefault(clipped) )
		calcNormals= 1
	endif
	
	
	// AppendToGizmo quad = {v1x,v1y,v1z,v2x,v2y,v2z,v3x,v3y,v3z,v4x,v4y,v4z }
	String cmd
	sprintf cmd, "AppendToGizmo/N=%s quad={%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g},name=%s",gizmoName,x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4,quadName
	Execute/Q/Z cmd
	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s property={ textureType,1}",gizmoName,quadName
	Execute/Q/Z cmd
	sprintf cmd,"ModifyGizmo/N=%s ModifyObject=%s property={ calcNormals,%d}",gizmoName,quadName,calcNormals
	Execute/Q/Z cmd
	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={ Clipped,%d}", gizmoName, quadName, clipped
	Execute/Q/Z cmd

	return quadName
End

// Returns the name of the created quad object, which is prepared for a texture.
// Does not append anything to the display list.
//
// AddGizmoOrthoBackgroundQuad uses an ortho coordinate system.
//
// Use AdjustBackgroundQuadForOrtho() to generate the necessary SCoordinates and TCoordinates
// to align the texture with the quad.
//
// Also see AddGizmoOrthoQuadPlane()
//
// NOTE: To modify a quad (one named "quad0" in this example), use:
// 	ModifyGizmo modifyobject=quad0, property={vertex,x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4}
//
Function/S AddGizmoOrthoBackgroundQuad(gizmoName,xleft,xright,ybottom,ytop,zVal[,quadName,clipped,calcNormals])
	String gizmoName
	Variable xleft,xright,ybottom,ytop,zVal	// quad ortho coordinates.
	String quadName						// optional: If given, any object of that name is first deleted. Otherwise, a uniquely named object created.
	Variable clipped							// optional: default is 0 (not clipped)
	Variable calcNormals					// optional: default is 1
	
	if( !ValidGizmoName(gizmoName) )
		return ""
	endif
	
	if( ParamIsDefault(quadName) )
		quadName= UniqueGizmoObjectName(gizmoName,"backOrthoQuad0","objectItemExists")
	else
		RemoveMatchingGizmoObjects(gizmoName,quadName)
	endif
	
	Variable x1= xleft
	Variable x2= xleft
	Variable x3= xright
	Variable x4= xright
			
	Variable y1= ybottom
	Variable y2= ytop
	Variable y3= ytop
	Variable y4= ybottom
			
	Variable z1= zVal
	Variable z2= zVal
	Variable z3= zVal
	Variable z4= zVal

	if( ParamIsDefault(clipped) )
		clipped= 0
	endif
	if( ParamIsDefault(clipped) )
		calcNormals= 1
	endif
	
	// AppendToGizmo quad = {v1x,v1y,v1z,v2x,v2y,v2z,v3x,v3y,v3z,v4x,v4y,v4z }
	String cmd
	sprintf cmd, "AppendToGizmo/N=%s quad={%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g},name=%s",gizmoName,x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4,quadName
	Execute/Q/Z cmd
	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s property={ textureType,1}",gizmoName,quadName
	Execute/Q/Z cmd
	sprintf cmd,"ModifyGizmo/N=%s ModifyObject=%s property={ calcNormals,%d}",gizmoName,quadName,calcNormals
	Execute/Q/Z cmd
	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={ Clipped,%d}", gizmoName, quadName, clipped
	Execute/Q/Z cmd

	return quadName
End

Function AdjustBackgroundQuadForOrtho(gizmoName,pathToQuad,pathToTexture,left, right, bottom, top, backgroundZ)
	String gizmoName
	String pathToQuad	// either the quad's name or something like "group0:quad0"
	String pathToTexture	// "" if no texture or no texture adjustment, else the path to the texture, "texture0" or "group0:texture0"
	Variable left, right, bottom, top, backgroundZ

	// GizmoGroupPathToNameAndPrefix() returns leaf name from groupPath, changes groupPath to be the path component before the leaf name.
	// For example: GizmoGroupPathToNameAndPrefix("group0:subgroup:surface0") returns "surface0" and sets groupPath to "group0:subgroup"
	String pathToGroup= pathToQuad
	String quadName= GizmoGroupPathToNameAndPrefix(pathToGroup)

// NOTE: To modify a quad (one named "quad0" in this example), use:
// 	ModifyGizmo modifyobject=quad0, property={vertex,x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4}

	Variable x1= left
	Variable x2= left
	Variable x3= right
	Variable x4= right
			
	Variable y1= bottom
	Variable y2= top
	Variable y3= top
	Variable y4= bottom
			
	Variable z1= backgroundZ
	Variable z2= backgroundZ
	Variable z3= backgroundZ
	Variable z4= backgroundZ
	
	SetGizmoCurrentGroup(gizmoName, pathToGroup)

	String cmd
	sprintf cmd, "ModifyGizmo/N=%s modifyobject=%s, property={vertex,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g}",gizmoName,quadName,x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4
	Execute cmd
	
	if( strlen(pathToTexture) )
		pathToGroup= pathToTexture
		String textureName= GizmoGroupPathToNameAndPrefix(pathToGroup)

		SetGizmoCurrentGroup(gizmoName, "")
		SetGizmoCurrentGroup(gizmoName, pathToGroup)

		// Compute the SCoordinates and TCoordinates for the new ortho range
		Variable sP1, sP2, sP3, sP4	// s corresponds to the x dimension (rows) of the texture
		Variable tP1, tP2, tP3, tP4	// t corresponds to the y dimension (cols) of the texture
		// For example, the s (x) dimension of the texture is mapped to x,y,z surface's ortho-transformed dimensions
		// through the transform:
		//	texture x [0-1] range = sP1 * x + sP2 * y + sP3 * z + sp4
		// So in if the surface is in the XY plane, then to map the x of the texture to x of the surface, use:
		//	sP1= 0.5, sP4 = 0.5, and the others to 0 so that they don't affect which x coordinate of the texture is chosen.
		// The constant 0.5 appears to be related to wrapping the surface given that the ortho range of a full plane is -1 to +1.
		// using surface ortho x = -1 to 1, that'd give texture x = 0 to 1
		// Now for y, set tP2 = 0.5, and for the same reason set tP4 to 0.5
		
		// map only the left, right x domain to 0-1:
		// right * sP1 + sP4 = 1
		// left * sP1 + sP4 = 0
		// subtracting:
		// (right-left) * sP1 = 1, therefore:
		sP1 = 1 / (right-left)
		// solving for sP4:
		// sP4 = 0 - left * sP1
		sP4 = - left * sP1
		
		// map only the top/bottom range to 0-1.
		// Unlike window coordinate, bottom is less than top, typically bottom = -2 and top = 2 
		// bottom * tP2 + tP4 = 1
		// top * tP2 + tP4 = 0
		// subtracting:
		// (bottom - top) * tP2 = 1, therefore:
		tP2= 1 / (bottom - top)	// check: if bottom = -2 and top = 2 , this should be -0.25
		// solving for tP4:
		// tP4 = 0 - top * tP2
		tP4 = - top * tP2	// check: if bottom = -2 and top = 2 , this should be 0.5

		sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s  property={ SCoordinates,%g,%g,%g,%g}",gizmoName,textureName, sP1, sP2, sP3, sP4
		Execute cmd
		sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s  property={ TCoordinates,%g,%g,%g,%g}",gizmoName,textureName, tP1, tP2, tP3, tP4
		Execute cmd
	endif

	// reset the currentGroupObject
	SetGizmoCurrentGroup(gizmoName, "")
	return 1
End


// Returns a list comprised of:
//	the name of the created quad surface object (which is prepared for a texture),
//	and the full path to the created surface wave.
//
// Does not append anything to the display list.
//
// AddGizmoDataQuadPlane() uses a data coordinate system.
//
// Also see AddGizmoOrthoQuadPlane, which uses an ortho coordinate system.
Function/S AddGizmoDataQuadPlane(gizmoName,planeStr [,quadWaveName,constantDataVal,quadSurfaceName,xmin,xmax,ymin,ymax,zmin,zmax,clipped])
	String gizmoName
	String planeStr						// "XY", "XZ", or "YZ": the plane in which the quad lies.
										// "Z", "Y", or "X" are corresponding single-letter synonyms naming the perpendicular plane.
	String quadWaveName				// optional: name of wave to be created in the current data folder. If not specified, a uniquely named wave is created.
	Variable constantDataVal			// optional: if planeStr is "Z", this is the z axis value at which the plane is placed. The default is the minimum value for the axis (zMin, for example).
	String quadSurfaceName			// optional: If given, any object of that name is first deleted. Otherwise, a uniquely named object created.
	Variable xmin,xmax,ymin,ymax,zmin,zmax	// optional: default is to get the values from the X, Y and Z axis extents
	Variable clipped								// optional: default is 0 (not clipped)

	if( !ValidGizmoName(gizmoName) )
		return ""
	endif
	
	if( ParamIsDefault(quadSurfaceName) )
		quadSurfaceName= UniqueGizmoObjectName(gizmoName,"planeDataQuad0","objectItemExists")
	else
		RemoveMatchingGizmoObjects(gizmoName,quadSurfaceName)
	endif

	// position the flat surface
	Variable gizmoXMin, gizmoXMax, gizmoYMin, gizmoYMax, gizmoZMin, gizmoZMax
	if( !GetGizmoAxisRanges(gizmoName, gizmoXMin, gizmoXMax, gizmoYMin, gizmoYMax, gizmoZMin, gizmoZMax) )
		return ""	// should never happen
	endif
	
	xmin= ParamIsDefault(xmin) ? gizmoXMin : xmin
	xmax= ParamIsDefault(xmax) ? gizmoXMax : xmax
	ymin= ParamIsDefault(ymin) ? gizmoYMin : ymin
	ymax= ParamIsDefault(ymax) ? gizmoYMax : ymax
	zmin= ParamIsDefault(zmin) ? gizmoZMin : zmin
	zmax= ParamIsDefault(zmax) ? gizmoZMax : zmax

	if( ParamIsDefault(quadWaveName) )
		quadWaveName= UniqueName("planeQuad",1,0)
	endif
	// DisplayHelpTopic "Parametric Surface Data Formats"
	Make/O/N=(2,2,3) $quadWaveName/WAVE=quadParametric
	
	strswitch( PlaneSpecToPerpendicularPlane(planeStr) )
		case "Z":	// XY
			quadParametric[][][2]= ParamIsDefault(constantDataVal) ? zmin : constantDataVal	// the z axis value at which the plane is placed
			// increment x fastest in the xy plane, then y
			// point 0
			quadParametric[0][0][0]= xmin
			quadParametric[0][0][1]= ymin
			// point 1
			quadParametric[0][1][0]= xmax
			quadParametric[0][1][1]= ymin
			// point 2
			quadParametric[1][0][0]= xmin
			quadParametric[1][0][1]= ymax
			// point 3
			quadParametric[1][1][0]= xmax
			quadParametric[1][1][1]= ymax
			break
		case "Y":	// XZ
			quadParametric[][][1]= ParamIsDefault(constantDataVal) ? ymin : constantDataVal	// the y axis value at which the plane is placed
			// increment x fastest in the xz plane, then z
			// point 0
			quadParametric[0][0][0]= xmin
			quadParametric[0][0][2]= zmin
			// point 1
			quadParametric[0][1][0]= xmax
			quadParametric[0][1][2]= zmin
			// point 2
			quadParametric[1][0][0]= xmin
			quadParametric[1][0][2]= zmax
			// point 3
			quadParametric[1][1][0]= xmax
			quadParametric[1][1][2]= zmax
			break
		case "X":	// YZ
			quadParametric[][][0]= ParamIsDefault(constantDataVal) ? xmin : constantDataVal	// the x axis value at which the plane is placed
			// increment y fastest in the yz plane, then z
			// point 0
			quadParametric[0][0][1]= ymin
			quadParametric[0][0][2]= zmin
			// point 1
			quadParametric[0][1][1]= ymax
			quadParametric[0][1][2]= zmin
			// point 2
			quadParametric[1][0][1]= ymin
			quadParametric[1][0][2]= zmax
			// point 3
			quadParametric[1][1][1]= ymax
			quadParametric[1][1][2]= zmax
			break
	endswitch
	
	//	AppendToGizmo Surface=root:quadParametric,name=quadSurface
	// ModifyGizmo ModifyObject=quadSurface property={ surfaceColorType,1}
	// ModifyGizmo ModifyObject=quadSurface property={ srcMode,4}
	// ModifyGizmo ModifyObject=quadSurface property={ frontColor,1,0,0,1}
	// ModifyGizmo ModifyObject=quadSurface property={ backColor,0,0,1,1}
	// ModifyGizmo modifyObject=quadSurface property={ Clipped,0}
	if( ParamIsDefault(clipped) )
		clipped= 0
	endif
	
	String cmd
	String pathToWave= GetWavesDataFolder(quadParametric,2)
	sprintf cmd, "AppendToGizmo/N=%s Surface=%s,name=%s",gizmoName,pathToWave,quadSurfaceName
	Execute/Q/Z cmd

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s property={ surfaceColorType,1}",gizmoName,quadSurfaceName
	Execute/Q/Z cmd

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s property={ srcMode,4}",gizmoName,quadSurfaceName
	Execute/Q/Z cmd

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s property={ frontColor,1,0,0,1}",gizmoName,quadSurfaceName
	Execute/Q/Z cmd

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s property={ backColor,0,0,1,1}",gizmoName,quadSurfaceName
	Execute/Q/Z cmd
	
	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={ Clipped,%d}", gizmoName, quadSurfaceName, clipped
	Execute/Q/Z cmd

	return quadSurfaceName+";"+pathToWave+";"
End

Function GetGizmoTextures(gizmoName, textureNameList [,inGroupPath,ignoreSubgroups])
	String gizmoName
	String &textureNameList	// output, names are either simple names (if ignoreSubgroups is true) or paths (if ignoreSubgroups is false) to avoid confusing identically named surfaces at the top level and in a group.
	String inGroupPath			// optional input: Default is "", the top-level objects. Use "group0:" to list quads in that top-level group.
	Variable ignoreSubgroups	// optional input: Default is false, which lists all surfaces starting at inGroupPath and in groups and subgroups. If false, the output names are full paths to the object.

	textureNameList=""

	if( !ValidGizmoName(gizmoName) )
		return 0
	endif

	if( ParamIsDefault(inGroupPath) )
		inGroupPath= ""
	else
		inGroupPath=RemoveEnding(inGroupPath,":")	// strip any erroneously trailing ":" char.
	endif
	if( ParamIsDefault(ignoreSubgroups) )
		ignoreSubgroups= 0
	endif

	String code= GetGizmoGroupObjectCommands(gizmoName, inGroupPath ,removeSubgroups=ignoreSubgroups,removeCurrentGroupObject=1)
	String key="(?i)AppendToGizmo texture="
	String appendTextureCommands= GrepList(code,key,0,"\r")
	Variable numTextures= ItemsInList(appendTextureCommands,"\r")
	if( numTextures == 0 )
		return 0
	endif

	// keep only the interesting lines: appended textures and currentGroupObject commands

	key="(?i)(AppendToGizmo texture=)|(ModifyGizmo currentGroupObject=)"
	code= GrepList(code,key,0,"\r")

	// keep the groupPathPrefix in sync with code
	String groupPathPrefix=""
	if( strlen(inGroupPath) )
		groupPathPrefix = inGroupPath+":"
	endif
	String name
	Variable line, numLines= ItemsInList(code,"\r")
	for(line=0; line <numLines; line+=1 )
		String lineStr= StringFromList(line,code,"\r")
		// parse:
		// AppendToGizmo texture=WMImageGroup1_txtr
		key="AppendToGizmo texture="
		Variable start= strsearch(lineStr, key, 0, 2)
		if( start >= 0 )	// found a texture command
			start += strlen(key)	// point past key
			// the rest of the line is the name
			Variable theEnd= strlen(lineStr)-1
			name= lineStr[start, theEnd]
			if( !ignoreSubgroups )	// we'll need full object path name if we're parsing subgroups, too
				name= groupPathPrefix+name
			endif
			textureNameList += name+";"
		else
			// must be ModifyGizmo currentGroupObject command
			if( !ignoreSubgroups )
				// keep track of the groupPathPrefix
				key="ModifyGizmo currentGroupObject=\"(.*)\""
				SplitString/E=(key) lineStr, name
				strswitch(name)
					default:
						if( strlen(name) )
							groupPathPrefix += name+":"
							break
						endif
					case "":
					case "::":
						groupPathPrefix= ParseFilePath(1, groupPathPrefix,":",1,0)	//  entire input up to but not including last element, has trailing ":" unless ""
						break
				endswitch
			endif		
		endif
	endfor

	return ItemsInList(textureNameList)
End


// search for ModifyGizmo setDisplayList=1, opName=ClearTexture0, operation=ClearTexture

Function GetGizmoClearTextures(gizmoName, clearTextureNameList [,inGroupPath,ignoreSubgroups])
	String gizmoName
	String &clearTextureNameList	// output, names are either simple names (if ignoreSubgroups is true) or paths (if ignoreSubgroups is false) to avoid confusing identically named surfaces at the top level and in a group.
	String inGroupPath			// optional input: Default is "", the top-level objects. Use "group0:" to list quads in that top-level group.
	Variable ignoreSubgroups	// optional input: Default is false, which lists all surfaces starting at inGroupPath and in groups and subgroups. If false, the output names are full paths to the object.

	clearTextureNameList=""

	if( !ValidGizmoName(gizmoName) )
		return 0
	endif

	if( ParamIsDefault(inGroupPath) )
		inGroupPath= ""
	else
		inGroupPath=RemoveEnding(inGroupPath,":")	// strip any erroneously trailing ":" char.
	endif
	if( ParamIsDefault(ignoreSubgroups) )
		ignoreSubgroups= 0
	endif

	String code= GetGizmoGroupObjectCommands(gizmoName, inGroupPath ,removeSubgroups=ignoreSubgroups,removeCurrentGroupObject=1)
	String key="(?i), operation=ClearTexture"
	String appendTextureCommands= GrepList(code,key,0,"\r")
	Variable numTextures= ItemsInList(appendTextureCommands,"\r")
	if( numTextures == 0 )
		return 0
	endif

	// keep only the interesting lines: appended clearTextures and currentGroupObject commands

	key="(?i)(, operation=ClearTexture)|(ModifyGizmo currentGroupObject=)"
	code= GrepList(code,key,0,"\r")

	// keep the groupPathPrefix in sync with code
	String groupPathPrefix=""
	if( strlen(inGroupPath) )
		groupPathPrefix = inGroupPath+":"
	endif
	String name
	Variable line, numLines= ItemsInList(code,"\r")
	for(line=0; line <numLines; line+=1 )
		String lineStr= StringFromList(line,code,"\r")
		// parse:
		// AppendToGizmo texture=WMImageGroup1_txtr
		// ModifyGizmo setDisplayList=1, opName=ClearTexture0, operation=ClearTexture
		key=", operation=ClearTexture"
		Variable start= strsearch(lineStr, key, 0, 2)
		if( start >= 0 )	// found a ClearTexture command
			Variable theEnd= start-1
			// the name preceeds the key and follows ", opName="
			key=", opName="
			start=strsearch(lineStr, key, theEnd, 3)	// search backwards from theEnd and ignore case
			start += strlen(key)	// point past key
			name= lineStr[start, theEnd]
			if( !ignoreSubgroups )	// we'll need full object path name if we're parsing subgroups, too
				name= groupPathPrefix+name
			endif
			clearTextureNameList += name+";"
		else
			// must be ModifyGizmo currentGroupObject command
			if( !ignoreSubgroups )
				// keep track of the groupPathPrefix
				key="ModifyGizmo currentGroupObject=\"(.*)\""
				SplitString/E=(key) lineStr, name
				strswitch(name)
					default:
						if( strlen(name) )
							groupPathPrefix += name+":"
							break
						endif
					case "":
					case "::":
						groupPathPrefix= ParseFilePath(1, groupPathPrefix,":",1,0)	//  entire input up to but not including last element, has trailing ":" unless ""
						break
				endswitch
			endif		
		endif
	endfor

	return ItemsInList(clearTextureNameList)
End
