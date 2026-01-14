#pragma rtGlobals=1		// Use modern global access method.

// 06MAR06
// Execute WM_initGizmoSlicer() to initialize a Gizmo Slicer panel.  The panel can handle multiple Gizmo windows
// by handling the top Gizmo.
// 20MAY09
// JP, Added noEdit=1
// 08SEP10
// JP, WM_initGizmoSlicer no longer resets values already defined.

// ===========================================================================
Function WM_initGizmoSlicer()
	String oldDF=GetDataFolder(1)
		SetDataFolder root:
		NewDataFolder/O/S Packages
		NewDataFolder/O/S WaveSlicer
		Variable num= NumVarOrDefault("root:Packages:WaveSlicer:planeNumber",0)
		Variable/G planeNumber=num
		String str= StrVarOrDefault("root:Packages:WaveSlicer:sliceType","Z")
		String/G sliceType=str
		str= StrVarOrDefault("root:Packages:WaveSlicer:sliceName","Surface")
		String/G sliceName=str
		str= StrVarOrDefault("root:Packages:WaveSlicer:lastGizmoName","")
		String/G lastGizmoName=str
		WM_initGizmoSlicerPanel()
	SetDataFolder oldDF
End
// ===========================================================================
// 

Function WM_GSPanelHook(s)
	STRUCT WMWinHookStruct &s

	Variable rval= 0
	switch(s.eventCode)
		case 0:					// window activated; check and update menus
			WM_GSCheckUpdateMenus()
		break
	EndSwitch

	return rval
End

// ===========================================================================
Function WM_GSCheckUpdateMenus()

	Execute "GetGizmo GizmoName"
	SVAR S_GizmoName
	SVAR lastGizmoName=root:Packages:WaveSlicer:lastGizmoName
	
	Controlupdate/W=WM_GSPanel WM_GSSrcPop
	
	if(strlen(S_GizmoName)<=0)
		PopupMenu WM_GSCurSlice,mode=1,value= "_none_",win=WM_GSPanel,disable=2
		Slider WM_GSSlider,limits={0,1,1},value=(0),win=WM_GSPanel,disable=2
		Button WM_GS_DeleteSliceButton,win=WM_GSPanel,disable=2
		PopupMenu WM_GSCtabPop,win=WM_GSPanel,disable=2
		CheckBox WM_GSShowAxes,value=0,win=WM_GSPanel,disable=2
		CheckBox WM_GSAspect,value=0,win=WM_GSPanel,disable=2
		CheckBox WM_GSAxesCue,value=0,win=WM_GSPanel,disable=2
		CheckBox WM_GLightCheck,value=0,win=WM_GSPanel,disable=2
		PopupMenu WM_GSLightAmbient,win=WM_GSPanel,disable=2,popColor=(65535,65535,65535 )
		PopupMenu WM_GSLightDiffuse,win=WM_GSPanel,disable=2,popColor=(65535,65535,65535 )
		PopupMenu WM_GSLightSpecular,win=WM_GSPanel,disable=2,popColor=(65535,65535,65535 )
		Slider WM_GSLightAzimuth,win=WM_GSPanel,disable=2
		Slider WM_GSLightElevation,win=WM_GSPanel,disable=2
		lastGizmoName=S_GizmoName
		return 0
	endif

	if(cmpstr(S_GizmoName,lastGizmoName)==0)
		return 0
	endif

	String oldDF=GetDataFolder(1)
	Variable pos2
	String strValue
	
	SetDataFolder root:Packages:WaveSlicer
	lastGizmoName=S_GizmoName
	PopupMenu WM_GSCtabPop,win=WM_GSPanel,disable=0
	Button WM_GS_DeleteSliceButton,win=WM_GSPanel,disable=0
	String str=GetIndependentModuleName()+"#WM_GetCurrentSlicesList()"
	PopupMenu WM_GSCurSlice,mode=1,value= #str,disable=0
	Slider WM_GSSlider,limits={0,1,1},value=(0),win=WM_GSPanel,disable=0
	Execute "GetGizmo displayList"
	SVAR S_DisplayList
	Variable pos=strsearch(S_DisplayList, "Axes", 0,2)
	CheckBox WM_GSShowAxes,value=(pos>-1),win=WM_GSPanel,disable=0
	String recMacro=WinRecreation(S_GizmoName, 0)
	pos=strsearch(recMacro, "aspectRatio=1", 0)
	CheckBox WM_GSAspect,value=pos>=0,win=WM_GSPanel,disable=0
	pos=strsearch(recMacro, "showAxisCue=1", 0)
	CheckBox WM_GSAxesCue,value=pos>=0,win=WM_GSPanel,disable=0
	pos=strsearch(S_DisplayList,"object=light0",0)							// hard-wired to light0 and no other light!!!
	if(pos<0)
		CheckBox WM_GLightCheck,value=0,win=WM_GSPanel,disable=0
		PopupMenu WM_GSLightAmbient,win=WM_GSPanel,disable=2,popColor=(65535,65535,65535 )
		PopupMenu WM_GSLightDiffuse,win=WM_GSPanel,disable=2,popColor=(65535,65535,65535 )
		PopupMenu WM_GSLightSpecular,win=WM_GSPanel,disable=2,popColor=(65535,65535,65535 )
		Slider WM_GSLightAzimuth,win=WM_GSPanel,disable=2
		Slider WM_GSLightElevation,win=WM_GSPanel,disable=2
	else
		CheckBox WM_GLightCheck,value=1,win=WM_GSPanel,disable=0
		// Get the recreation info for light0:		
		pos=strsearch(recMacro, "light=light0 property={ direction", 0)
		pos2=strsearch(recMacro, "}", pos)
		strValue=recMacro[pos+34,pos2-1]
		Variable direction1,direction2,direction3
		sscanf strValue,"%g,%g,%g",direction1,direction2,direction3

		Variable azimuth,elevation,R2
		azimuth=atan2(direction2,direction1)
		azimuth+=pi;
		if(azimuth>2*pi)
			azimuth-=2*pi
		endif
		azimuth*=180/pi
	
		R2=direction1^2+direction2^2+direction3^2	
		elevation=-asin(direction3/sqrt(R2))*180/pi

		Slider WM_GSLightAzimuth,win=WM_GSPanel,disable=0,value=azimuth
		Slider WM_GSLightElevation,win=WM_GSPanel,disable=0,value=elevation
	
		Variable red,green,blue,alpha
		pos=strsearch(recMacro, "light=light0 property={ ambient", 0)
		if(pos>-1)
			pos2=strsearch(recMacro, "}", pos)
			strValue=recMacro[pos+32,pos2-1]
			sscanf strValue,"%g,%g,%g,%g",red,green,blue,alpha
		else
			red=1
			blue=1
			green=1
		endif
		PopupMenu WM_GSLightAmbient,win=WM_GSPanel,disable=0,popColor=(red*65535,green*65535,blue*65535 )

		pos=strsearch(recMacro, "light=light0 property={ diffuse", 0)
		if(pos>-1)
			pos2=strsearch(recMacro, "}", pos)
			strValue=recMacro[pos+32,pos2-1]
			sscanf strValue,"%g,%g,%g,%g",red,green,blue,alpha
		else
			red=1
			blue=1
			green=1
		endif
		PopupMenu WM_GSLightDiffuse,win=WM_GSPanel,disable=0,popColor=(red*65535,green*65535,blue*65535 )
		
		pos=strsearch(recMacro, "light=light0 property={ specular", 0)
		if(pos>-1)
			pos2=strsearch(recMacro, "}", pos)
			strValue=recMacro[pos+33,pos2-1]
			sscanf strValue,"%g,%g,%g,%g",red,green,blue,alpha
		else
			red=1
			blue=1
			green=1
		endif

		PopupMenu WM_GSLightSpecular,win=WM_GSPanel,disable=0,popColor=(red*65535,green*65535,blue*65535 )
		
	endif
	SetDataFolder oldDF
End

// ===========================================================================

Function WM_AppendSliceButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Execute "GetGizmo GizmoName"
	SVAR S_GizmoName
	if(strlen(S_GizmoName)<=0)
		Execute "NewGizmo"
		Execute "ModifyGizmo euler={20,30,5}"
		WM_GSCheckUpdateMenus()
	endif

	String srcWaveName
	ControlInfo/W=WM_GSPanel WM_GSSrcPop
	srcWaveName=s_value
	Wave/Z ww=$srcWaveName
	if(WaveExists(ww)==0)
		doAlert 0,"Bad source wave specification."
		return 0
	endif
	
	SVAR baseName=root:Packages:WaveSlicer:sliceName
	NVAR planeNumber=root:Packages:WaveSlicer:planeNumber
	
	if(strlen(baseName)<=0)
		baseName="Surface"
	endif
	String surfaceName
	Variable i=0
	// find a valid unique name 
	do
		surfaceName=baseName+num2str(i)
		if(GizmoInfo(surfaceName,1)==1)
			break
		endif
		i+=1
	while(1)
	
	String cmd
	
	Variable srcMode
	ControlInfo/W=WM_GSPanel  WM_GSSlicePop
	srcMode=V_Value==1 ? 128:(V_Value==2? 64:(V_Value==3? 32:0))
	
	sprintf cmd,"AppendToGizmo Surface=%s,name=%s",srcWaveName,surfaceName
	Execute cmd
	
	sprintf cmd,"ModifyGizmo ModifyObject=%s property={ srcMode,%d}",surfaceName,srcMode
	Execute cmd
	
	sprintf cmd,"ModifyGizmo ModifyObject=%s property={surfaceCTab,Rainbow}",surfaceName
	Execute cmd
	
	sprintf cmd,"ModifyGizmo ModifyObject=%s property={ plane,%d}",surfaceName,planeNumber
	Execute cmd
	
	sprintf cmd,"ModifyGizmo modifyObject=%s property={calcNormals,1}",surfaceName
	Execute cmd
	
	sprintf cmd,"ModifyGizmo setDisplayList=-1,object=%s",surfaceName
	Execute cmd
End
// ===========================================================================
//	The following function returns a string containing a list of all the slices in the top Gizmo

Function/S WM_GetCurrentSlicesList()
	String out="_none_;" 
	
	Execute "GetGizmo GizmoName"
	SVAR S_GizmoName
	String recMacro=WinRecreation(S_GizmoName, 0)
	String theName
	Variable pos=0,pos2
	do
		pos=strsearch(recMacro, "AppendToGizmo Surface", pos)
		if(pos<0)
			break
		endif
		pos=strsearch(recMacro, "name=", pos) 
		pos2=strsearch(recMacro, "\r", pos) 
		theName=recMacro[pos+5,pos2]
		out+=theName+";"
	while(1)
	return out
End
// ===========================================================================

Function WM_GSSliderProc(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved

	String cmd,objectName
	
	ControlInfo/W=WM_GSPanel WM_GSCurSlice
	objectName=S_Value
	
	if(cmpstr(objectName,"_none_")==0)
		return 0
	endif
	
	if(event %& 0x1)	// bit 0, value set
		sprintf cmd,"ModifyGizmo ModifyObject=%s property={ plane,%d}",objectName,sliderValue
		Execute cmd
	endif

	return 0
End
// ===========================================================================
// updates the range of ticks for the slider based on the number of planes in the particular slice.

Function WM_GSCurSlicePopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	if(cmpstr(popstr,"_none_")==0)
		Slider WM_GSSlider,limits={0,1,1},value=(0),win=WM_GSPanel
		PopupMenu WM_GSCtabPop mode=1,win=WM_GSPanel
	endif

	Execute "GetGizmo GizmoName"
	SVAR S_GizmoName
	Variable pos,pos2
	String recMacro=WinRecreation(S_GizmoName, 0)
	String findThis="name="+popStr
	String srcWaveName
	// step 1: find the wave associated with the slice
	pos=strsearch(recMacro,findThis, 0)
	if(pos<0)
		return 0
	endif
	pos=strsearch(recMacro,"Surface=", pos,3)
	if(pos<0)
		return 0
	endif
	pos2=strsearch(recMacro,",", pos)
	srcWaveName=recMacro[pos+8,pos2-1]
	Wave/Z ww=$srcWaveName
	if(WaveExists(ww)==0)
		return 0
	endif
	// step 2: find srcMode which tells us if this is in the z;y;x direction 32,64,128
	pos=strsearch(recMacro,"property={ srcMode",pos)
	if(pos<0)
		return 0
	endif
	pos2=strsearch(recMacro,"}",pos)
	String modestr=recMacro[pos+19,pos2-1]
	Variable srcMode,maxDim
	sscanf modestr,"%d", srcMode
	switch(srcMode)
		case 32:
			maxDim=DimSize(ww,2)-1
		break
		case 64:
			maxDim=DimSize(ww,1)-1
		break
		case 128:
			maxDim=DimSize(ww,0)-1
		break
		
		default:
			doAlert 0, "Bas srcMode in Rec Macro."
		break
	endswitch
	
	// step 3: find the color table
	string ctabName
	pos=strsearch(recMacro,"property={ surfaceCTab",pos)
	if(pos<0)
		return 0
	endif
	pos2=strsearch(recMacro,"}",pos)
	ctabName=recMacro[pos+23,pos2-1]
	

	// step 4: find the current setting:
	pos=strsearch(recMacro,"property={ plane",pos)
	if(pos>-1)
		pos2=strsearch(recMacro,"}",pos)
		Variable planeNum
		String planeStr=recMacro[pos+17,pos2-1]
		sscanf planeStr,"%d",planeNum
	else
		planeNum=0
	endif
		
	// step 5: adjust the slider
	Slider WM_GSSlider,limits={0,maxDim,1},value=(planeNum),win=WM_GSPanel
	
	// step 6: adjust the color table
	String list=CTabList()
	Variable item=2+WhichListItem(ctabName, list)	// 1 for 1 base and 1 for _none_.
	PopupMenu WM_GSCtabPop mode=item,win=WM_GSPanel
	ControlUpdate/W=WM_GSPanel WM_GSCtabPop
End
// ===========================================================================
// deletes the surface item selected in the current slice popup menu.

Function WM_GSDeleteSliceButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo/W=WM_GSPanel WM_GSCurSlice
	if(cmpstr(s_value,"_none_")==0)
		beep
		return 0
	endif
	
	String cmd
	sprintf cmd,"RemoveFromGizmo object=%s",s_value
	Execute cmd
	Execute "ModifyGizmo update=2"
	PopupMenu WM_GSCurSlice,mode=1,win=WM_GSPanel
	ControlUpdate /W=WM_GSPanel WM_GSCurSlice
End

// ===========================================================================
Function WM_GSShowAxesCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	String axesName
	Variable i=0
	String cmd

	if(checked)
		do
			axesName="axes"+num2str(i)
			if(GizmoInfo(axesName,1)==1)
				break
			endif
			i+=1
		while(1)
		sprintf cmd "AppendToGizmo Axes=boxAxes,name=%s",axesName
		Execute cmd
		sprintf cmd, "ModifyGizmo setDisplayList=-1,object=%s",axesName
		Execute cmd
	else
		Execute "GetGizmo displayList"
		SVAR S_DisplayList
		Variable pos=strsearch(S_DisplayList, "Axes", 0,2)
		if(pos<0)
			return 0
		endif
		Variable pos2=strsearch(S_DisplayList, ";", pos)
		axesName=S_DisplayList[pos,pos2-1]
		sprintf cmd,"RemoveFromGizmo object=%s",axesName
		Execute cmd
	endif
	Execute "ModifyGizmo update=2"
End
// ===========================================================================

Function WM_GSCtabPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	if(cmpstr(popStr,"_none_")==0)
		Beep
		return 0
	endif
	
	ControlInfo/W=WM_GSPanel WM_GSCurSlice
	if(cmpstr(s_value,"_none_")==0)
		beep
		return 0
	endif
	String cmd
	sprintf cmd,"ModifyGizmo ModifyObject=%s property={surfaceCTab,%s}",s_value,popStr
	Execute cmd
End
// ===========================================================================
Function WM_initGizmoSlicerPanel()

	DoWindow/F WM_GSPanel
	if(V_Flag)
		return 0
	endif 
	
	NewPanel /K=1 /W=(891,44,1201,647) as "Gizmo Slicer"
	DoWindow/C WM_GSPanel
	PopupMenu WM_GSSrcPop,pos={19,6},size={150,20},title="Source Wave:"
	String str=GetIndependentModuleName()+"#WM_GSSrcWaveList()"
	PopupMenu WM_GSSrcPop,mode=1,bodyWidth= 100,value= #str
	PopupMenu WM_GSSlicePop,pos={21,54},size={110,20},title="Slice Type"
	PopupMenu WM_GSSlicePop,mode=1,bodyWidth= 60,popvalue="X",value= #"\"X;Y;Z\""
	SetVariable WM_GSPlaneSetVar,pos={23,80},size={102,15},title="Plane #:"
	SetVariable WM_GSPlaneSetVar,limits={0,inf,1},value= root:Packages:WaveSlicer:planeNumber,bodyWidth= 60
	SetVariable WM_GSNameSetVar,pos={14,106},size={246,18},bodyWidth=173,title="Base Name:"
	SetVariable WM_GSNameSetVar,format="%g"
	SetVariable WM_GSNameSetVar,value= root:Packages:WaveSlicer:sliceName,bodyWidth= 173
	Button WM_GS_AppendSliceButton,pos={25,131},size={120,20},proc=WM_AppendSliceButtonProc,title="Append Slice"
	PopupMenu WM_GSCurSlice,pos={24,186},size={134,20},proc=WM_GSCurSlicePopMenuProc,title="Current Slice:"
	str=GetIndependentModuleName()+"#WM_GetCurrentSlicesList()"
	PopupMenu WM_GSCurSlice,mode=1,popvalue="_none_",value= #str
	Slider WM_GSSlider,pos={16,257},size={256,45},proc=WM_GSSliderProc
	Slider WM_GSSlider,limits={0,1,1},value= 0,vert= 0
	Button WM_GS_DeleteSliceButton,pos={26,307},size={120,20},proc=WM_GSDeleteSliceButtonProc,title="Delete Slice"
	PopupMenu WM_GSCtabPop,pos={26,219},size={191,20},proc=WM_GSCtabPopMenuProc,title="Color Table:"
	
	str=GetIndependentModuleName()+"#WM_GSCtabList()"
	PopupMenu WM_GSCtabPop,mode=1,value= #str
	CheckBox WM_GSShowAxes,pos={23,356},size={68,14},proc=WM_GSShowAxesCheckProc,title="Show Axes Cube"
	CheckBox WM_GSShowAxes,value= 1
	CheckBox WM_GSAspect,pos={23,376},size={99,14},proc=WM_GSAspectCheckProc,title="Keep Aspect Ratio"
	CheckBox WM_GSAspect,value= 0
	CheckBox WM_GSAxesCue,pos={175,355},size={87,14},proc=WM_GSShowAxesCueCheckProc,title="Show Axis Cue"
	CheckBox WM_GSAxesCue,value= 1
	GroupBox WM_GSgroup0,pos={8,168},size={276,170},title="Slice Control"
	GroupBox WM_GSgroup1,pos={8,34},size={278,129},title="New Slice"
	CheckBox WM_GLightCheck,pos={23,396},size={60,14},proc=WM_GSAddLightCheckProc,title="Add Light"
	CheckBox WM_GLightCheck,value= 1
	Slider WM_GSLightElevation,pos={23,421},size={256,45},proc=WM_GSLIghtSliderProc
	Slider WM_GSLightElevation,limits={-90,90,1},value= 18,vert= 0,ticks= 11
	Slider WM_GSLightAzimuth,pos={25,468},size={256,45},proc=WM_GSLIghtSliderProc
	Slider WM_GSLightAzimuth,limits={0,360,1},value= 338,vert= 0,ticks= 11
	PopupMenu WM_GSLightSpecular,pos={24,570},size={96,20},proc=WM_GSLightPopMenuProc,title="Specular:"
	PopupMenu WM_GSLightSpecular,mode=1,popColor= (0,0,0),value= #"\"*COLORPOP*\""
	PopupMenu WM_GSLightAmbient,pos={26,520},size={94,20},proc=WM_GSLightPopMenuProc,title="Ambient:"
	PopupMenu WM_GSLightAmbient,mode=1,popColor= (43690,43690,43690),value= #"\"*COLORPOP*\""
	PopupMenu WM_GSLightDiffuse,pos={35,545},size={85,20},proc=WM_GSLightPopMenuProc,title="Diffuse"
	PopupMenu WM_GSLightDiffuse,mode=1,popColor= (0,0,0),value= #"\"*COLORPOP*\""
	SetWindow kwTopWin,hook(activate)=WM_GSPanelHook
	ModifyPanel fixedSize=1, noEdit=1
End

// ===========================================================================
Function/S WM_GSSrcWaveList()
	String out= "_none_;"+WaveList("*",";","DIMS:3")
	return out
End
// ===========================================================================
Function WM_GSAspectCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	if(checked)
		Execute "ModifyGizmo AspectRatio=1"
	else
		Execute "ModifyGizmo AspectRatio=0"
	endif
	Execute "ModifyGizmo update=2"
End
// ===========================================================================

Function WM_GSShowAxesCueCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	if(checked)
		Execute "ModifyGizmo showAxisCue=1"
	else
		Execute "ModifyGizmo showAxisCue=0"
	endif
End
// ===========================================================================

Function WM_GSAddLightCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	String oldDF=GetDataFolder(1)
	SetDataFolder root:Packages:WaveSlicer
	Variable displayItemExists=0,pos,objectItemExists=0
	// find if there is such item on the display list
	Execute "GetGizmo displayList"
	SVAR/Z S_DisplayList
	if(SVAR_Exists(S_DisplayList ))
		pos=strsearch(S_DisplayList, "light0", 0,2)
		displayItemExists=pos>-1
	endif
	
	Execute "GetGizmo objectList"
	SVAR/Z S_gizmoObjectList
	if(SVAR_Exists(S_gizmoObjectList ))
		pos=strsearch(S_gizmoObjectList, "light0", 0,2)
		objectItemExists=pos>-1
	endif
	
	if(checked)
		if(objectItemExists==0)
			Execute "AppendToGizmo light=Directional,name=light0"
		endif
		Execute "ModifyGizmo insertDisplayList=0, object=light0"
		WM_GSSlidersToLight()
		WM_GSColorPopsToLight()
	else
		if(displayItemExists)
			Execute "RemoveFromGizmo displayItem=light0"
		endif
	endif

	SVAR lastGizmoName=root:Packages:WaveSlicer:lastGizmoName
	lastGizmoName=""
	WM_GSCheckUpdateMenus()
		
	SetDataFolder oldDF
End
// ===========================================================================
// the following handles both light direction sliders.  Same commands are issued regardless which one changes.

Function WM_GSLIghtSliderProc(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved

	if(event %& 0x1)	// bit 0, value set
		WM_GSSlidersToLight()
	endif

	return 0
End
// ===========================================================================

Function WM_GSLightPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	WM_GSColorPopsToLight()
End

// ===========================================================================
Function WM_GSSlidersToLight()

	Variable position0,position1,position2
	Variable direction0,direction1,direction2
	Variable azimuth,elevation
	String cmd
	ControlInfo/W=WM_GSPanel WM_GSLightAzimuth
	azimuth=V_Value*pi/180
	ControlInfo/W=WM_GSPanel WM_GSLightElevation
	elevation=V_Value*pi/180
	direction0=-cos(elevation)*cos(azimuth)
	direction1=-cos(elevation)*sin(azimuth)
	direction2=-sin(elevation)
	position0=direction0
	position1=direction1
	position2=direction2
	sprintf cmd,"ModifyGizmo light=light0 property={ position,%g,%g,%g,0.000000}",position0,position1,position2
	Execute cmd
	sprintf cmd,"ModifyGizmo light=light0 property={ direction,%g,%g,%g}",direction0,direction1,direction2
	Execute cmd
	Execute "ModifyGizmo update=2"
End
// ===========================================================================
Function WM_GSColorPopsToLight()

	String cmd
	Variable red,green,blue
	
	ControlInfo/W=WM_GSPanel WM_GSLightAmbient
	sscanf S_value,"(%g,%g,%g)",red,green,blue
	sprintf cmd,"ModifyGizmo light=light0 property={ ambient,%g,%g,%g,1.000000}",red/65535,green/65535,blue/65535
	Execute cmd

	ControlInfo/W=WM_GSPanel WM_GSLightSpecular
	sscanf S_value,"(%g,%g,%g)",red,green,blue
	sprintf cmd,"ModifyGizmo light=light0 property={ specular,%g,%g,%g,1.000000}",red/65535,green/65535,blue/65535
	Execute cmd

	ControlInfo/W=WM_GSPanel WM_GSLightDiffuse
	sscanf S_value,"(%g,%g,%g)",red,green,blue
	sprintf cmd,"ModifyGizmo light=light0 property={ diffuse,%g,%g,%g,1.000000}",red/65535,green/65535,blue/65535
	Execute cmd
	
	Execute "ModifyGizmo update=2"
End
// ===========================================================================
Function/S WM_GSCtabList()

	return "_none_;" +CTabList()
End
// ===========================================================================