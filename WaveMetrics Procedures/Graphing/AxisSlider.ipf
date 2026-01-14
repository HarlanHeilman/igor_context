#pragma rtGlobals=2		// Need new syntax
#pragma version 8.01		// ships with Igor 8.01

#include <ControlBarManagerProcs>

// AxisSlider.ipf
//
// Designed for use via packages method.
// WMAppendAxisSlider() appends a Slider control to the top graph
// that controls the center point of a zoomed in axis. Used to scan through
// a large data set.

//************************************************
//	Revision History
//	1.0		(LH020103) first release.
//	1.01	(JW) revised code to avoid a pre-existing control bar; now reverts the control bar.
//			More intelligently independent of order in which various procs add controls to control bar.
//	1.02	(JP) Slider was too narrow under Windows OS.
//	1.03	(AL)  Added 1 and 4 as options to the zoom factor popup.
//	6.22	(JP110318)  Fixed WMAxisSliderInstructions, use modern version scheme.
//	7.09	(JP180206)  Added presetting of popup value to current zoom, added Other zoom value,
//			added GraphMarquee "Zoom to selection" item.
// 8.01	(JW180530) Made WMAxisSliderSetAxis() safe to be called from a window hook function "modified" event. This became
//			necessary after I fixed a bug in how the modified event was delivered. Previously, this function was OK with that
//			because the bug prevented updates due to the SetAxis here!
//************************************************

Menu "GraphMarquee", dynamic
	WMAxisSliderExpandMenuItem(), /Q, WMAxisSliderZoomToMarquee()
End

Function WMAxisSliderInGraph(grfName)
	String grfName	// or ""
	
	if( strlen(grfName) == 0 )
		grfName= WinName(0, 1)
		if( strlen(grfName) == 0 )
			return 0
		endif
	endif
	
	DFREF dfr= root:Packages:WMAxisSlider:$(grfName)
	if( DataFolderRefStatus(dfr) == 0 )
		return 0
	endif
	ControlInfo/W=$grfName WMAxSlSl
	return V_Flag == 7 // returns 1 if Slider is in the graph.
End

Function/S WMAxisSliderExpandMenuItem()
	
	String item= "" // disappears
	if( WMAxisSliderInGraph("") )
		item= "-;Zoom to selection;"
	endif
	return item
End

Function WMAxisSliderZoomToMarquee()

	String dfSav= GetDataFolder(1)
	String grfName= WinName(0, 1)
	SetDataFolder root:Packages:WMAxisSlider:$(grfName)

	NVAR gLeftLim,gRightLim
	SVAR gAxisName
	//GetAxis/Q $gAxisName
	GetMarquee/W=$grfName/K/Z $gAxisName
	SetAxis $gAxisName,V_left,V_right
	DoUpdate/W=$gAxisName

	// set zoom and resync slider
	WMAxisSliderSetAxis(gAxisName,0,gLeftLim,gRightLim)
	SetDataFolder dfSav
End


Function WMAxisSliderProc(name, value, event)
	String name	// name of this slider control
	Variable value	// value of slider
	Variable event	// bit field: bit 0: value set; 1: mouse down, //   2: mouse up, 3: mouse moved

	String dfSav= GetDataFolder(1)
	String grfName= WinName(0, 1)
	SetDataFolder root:Packages:WMAxisSlider:$(grfName)

	NVAR gLeftLim,gRightLim
	SVAR gAxisName
	GetAxis/Q $gAxisName
	Variable dx= (V_max-V_min)/2
	Variable x0= value*(gRightLim-gLeftLim)+gLeftLim
	SetAxis $gAxisName,x0-dx,x0+dx
	
	SetDataFolder dfSav
			
	return 0	// other return values reserved
End

static constant kSliderLMargin= 70
static constant ControlBarDelta = 46

#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility with Igor 7
	String wName
	return 72
End
#endif

Function WMAppendAxisSlider()
	String grfName= WinName(0, 1)
	DoWindow/F $grfName
	if( V_Flag==0 )
		return 0			// no top graph, exit
	endif
	ControlInfo WMAxSlSl
	if( V_Flag != 0 )
		return 0			// already installed, do nothing
	endif
	String dfSav= GetDataFolder(1)
	NewDataFolder/S/O root:Packages
	NewDataFolder/S/O WMAxisSlider
	NewDataFolder/S/O $grfName
	
	Variable/G gLeftLim,gRightLim
	String/G gAxisName=""

	String CBIdent=""
	Variable/G gOriginalHeight = ExtendControlBar(grfName, ControlBarDelta, CBIdent) // we append below original controls (if any)
	String/G CBIdentifier = CBIdent
	
	// Find first axis of type bottom or top
	String axList= AxisList("" )
	Variable i,nax= ItemsInList(axList )
	for(i=0;i<nax;i+=1)
		gAxisName= StringFromList(i,axList)
		String axtype= StringByKey("AXTYPE",AxisInfo("", gAxisName))
		if( CmpStr(axtype,"bottom")==0 || CmpStr(axtype,"top")==0 )
			break
		endif
	endfor

	GetWindow kwTopWin,gsize	// returns points, and controls are positioned in pixels
	V_left *= ScreenResolution/PanelResolution(grfName)	// v1.02 - convert points to pixels
	V_right *= ScreenResolution/PanelResolution(grfName)
	
	Slider WMAxSlSl,pos={V_left+50,gOriginalHeight+9},size={V_right-V_left-kSliderLMargin,16},proc=WMAxisSliderProc
	Slider WMAxSlSl,limits={0,1,0},value= .5,vert= 0,ticks= 0,side=0
	PopupMenu WMAxSlPop,pos={V_left+10,gOriginalHeight+5},size={20,20},proc=WMAxSlPopProc
	PopupMenu WMAxSlPop,mode=0,value= #"\"Instructions...;Set Axis...;Zoom Factor...;Resync position;Resize;Remove\""

	Variable/G gLastAuto=1
	WMAxisSliderSetAxis(gAxisName,gLastAuto,0,0)
	
	SetDataFolder dfSav
End

Function WMAxisSliderSetAxis(axName,doAutoscale,vmin,vmax)
	String axName
	Variable doAutoscale,vmin,vmax

	NVAR gLeftLim,gRightLim
	SVAR gAxisName

	gAxisName= axName
	GetAxis/Q $axName
	Variable origV_min= V_min,origV_max=V_max
	if( doAutoscale )
		SetAxis/A $axName
		DoUpdate
		GetAxis/Q $axName
	else
		V_min= vmin
		V_max= vmax
	endif
	gLeftLim= V_min
	gRightLim= V_max
	// JW 180530 Added doAutoscale check so that this function doesn't cause infinite updates if called from
	// a window hook modified event. The gLeftLim and gRightLim globals keep the limits of the axis if it were
	// autoscaled so that the slider has the right limit values. Needed if the data changes its X range.
	if (doAutoscale)
		SetAxis $axName,origV_min,origV_max
	endif

	Variable value= (((origV_max+origV_min)/2)-gLeftLim)/(gRightLim-gLeftLim)
	Slider WMAxSlSl,value=value
End

Function WMAxSlPopProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String dfSav,grfName
	
	StrSwitch(popStr)
		case "Set Axis...":
			dfSav= GetDataFolder(1)
			grfName= WinName(0, 1)
			SetDataFolder root:Packages:WMAxisSlider:$(grfName)
			
			String axList= AxisList("" )
			NVAR gLeftLim,gRightLim,gLastAuto
			SVAR gAxisName
			
			String newAx= gAxisName
			Prompt newAx,"axis",popup,axList
			Variable doAuto= gLastAuto ? 1 : 2
			Prompt doAuto,"autoscale",popup,"Yes;No"
			Variable axMin= gLeftLim
			Prompt axMin,"axis minimum"
			Variable axMax= gRightLim
			Prompt axMax,"axis maximum"
			
			DoPrompt "Set Axis for Slider",newAx,doAuto,axMin,axMax
			if( V_Flag==0 )
				gLastAuto= doAuto==1
				WMAxisSliderSetAxis(newAx,gLastAuto,axMin,axMax)
			endif

			SetDataFolder dfSav
			break
		case "Zoom Factor...":
			dfSav= GetDataFolder(1)
			grfName= WinName(0, 1)
			SetDataFolder root:Packages:WMAxisSlider:$(grfName)
			
			NVAR gLeftLim,gRightLim
			SVAR gAxisName
			GetAxis/Q $gAxisName
			// JP 7.09: added presetting of popup value to current zoom.
			Variable displayedRange= V_Max-V_Min
			Variable maxRange= gRightLim-gLeftLim
			Variable oldZoom= round(maxRange/displayedRange)
			String zoomFactor= num2istr(oldZoom) 				// JP 7.09: was = "10"
			String choices= "1;4;10;40;100;400;1000;"		// AL 1.03: Added 1 and 4 as options.
			Variable inList = WhichListItem(zoomFactor, choices) >= 0
			if( !inList )
				zoomFactor= "Other"
			endif
			Prompt zoomFactor,"Zoom Factor",popup,choices+"Other;"
			Variable other = oldZoom
			Prompt other, "Other Zoom Factor"
			DoPrompt "Set Axis Zoom",zoomFactor, other
			if( V_Flag==0 )
				Variable x0= (V_Max+V_Min)/2
				Variable zoom= str2num(zoomFactor)
				if( numtype(zoom) != 0 )
					zoom = other
				endif
				Variable dx= (gRightLim-gLeftLim)/(2*zoom)
				SetAxis $gAxisName,x0-dx,x0+dx
			endif

			SetDataFolder dfSav
			break
		case "Resync position":
			dfSav= GetDataFolder(1)
			grfName= WinName(0, 1)
			SetDataFolder root:Packages:WMAxisSlider:$(grfName)
			
			NVAR gLeftLim,gRightLim
			SVAR gAxisName
			WMAxisSliderSetAxis(gAxisName,0,gLeftLim,gRightLim)

			SetDataFolder dfSav
			break
		case "Resize":
			GetWindow kwTopWin,gsize	// returns points, and controls are positioned in pixels
			grfName= WinName(0, 1)
			V_left *= ScreenResolution/PanelResolution(grfName)	// v1.02 - convert points to pixels
			V_right *= ScreenResolution/PanelResolution(grfName)
			Slider WMAxSlSl,size={V_right-V_left-kSliderLMargin,16}
			break
		case "Instructions...":
			Execute/Q/Z "WMAxisSliderInstructions()"
			break
		case "Remove":
			dfSav= GetDataFolder(1)
			grfName= WinName(0, 1)
			SetDataFolder root:Packages:WMAxisSlider:$(grfName)
//			NVAR gOriginalHeight
//			Variable searchTop = gOriginalHeight+ControlBarDelta
//			String moveCList = ListControlsInControlBar(grfName, searchTop)
			KillControl WMAxSlSl
			KillControl WMAxSlPop
//			ControlBar gOriginalHeight
//			MoveControls(moveCList, 0, -ControlBarDelta)	
			SVAR CBIdentifier
			ContractControlBar(grfName, CBIdentifier, ControlBarDelta)
			KillDataFolder :
			if( CountObjects(":",4) == 0 )
				KillDataFolder :
				Execute/P "DELETEINCLUDE  <AxisSlider>"
				Execute/P "COMPILEPROCEDURES "
			endif
			SetDataFolder dfSav
			break
	endswitch
End

Proc WMAxisSliderInstructions()
	String nb = "AxisSliderInstructions"
	DoWindow/F $nb
	if( V_Flag )
		return
	endif
	NewNotebook/N=$nb/F=1/V=1/K=1/W=(62,103,583,484) 
	Notebook $nb defaultTab=36, statusWidth=238, pageMargins={72,72,72,72}
	Notebook $nb showRuler=0, rulerUnits=1, updating={1, 3600}
	Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,0,(0,0,0)}
	Notebook $nb ruler=Normal; Notebook $nb  justification=1, fStyle=1, text="Axis Slider Tips\r"
	Notebook $nb ruler=Normal, fStyle=-1, text="\r"
	Notebook $nb text="The axis slider is used to scroll a zoomed-in axis in order to examine a large data set. \r"
	Notebook $nb text="\r"
	Notebook $nb text="When first installed in a graph, the package chooses the first horizontal axis it finds and does an auto"
	Notebook $nb text="scale to determine the axis limits. You can choose other axes using the popup menu to the left of the sli"
	Notebook $nb text="der.\r"
	Notebook $nb text="\r"
	Notebook $nb text="You can use the Zoom Factor command in the popup menu or you can manually set the axis range using the u"
	Notebook $nb text="sual marquee method. If you do set the axis range manually, you should choose the popup's Resync positio"
	Notebook $nb text="n command to synchronize the slider to the new axis center position.\r"
	Notebook $nb text="\r"
	Notebook $nb text="When working with large zoom factors, you should use a large window size so that the slider bar is large"
	Notebook $nb text=" enough to provide acceptable positioning resolution. Alternatively, you can use the usual hand tool (option ("
	Notebook $nb text="Alt) key) to pan when you get in the right region (remember to hold the shift key to constrain to one di"
	Notebook $nb text="rection.) Another method of getting more resolution using the slider is to use the Set Axis... command a"
	Notebook $nb text="nd manually set a subrange (choose No from the autoscale popup menu and type in new values for the axis "
	Notebook $nb text="limits).\r"
	Notebook $nb text="\r"
	Notebook $nb text="If you resize the graph window, you should choose \"Resize\" from the popup to readjust the slider width. "
	Notebook $nb text=" \r"
	Notebook $nb text="\r"
	Notebook $nb text="Do not rename the graph while the slider is present. To minimize clutter, you should choose \"Remove\" bef"
	Notebook $nb text="ore killing a graph if you are not going to save its recreation macro. \r"
End

