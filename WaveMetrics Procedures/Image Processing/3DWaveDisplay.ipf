#pragma rtGlobals=1		// Use modern global access method.

// AG11FEB04 
// This procedure creates a panel that displays 3 views of a 3D wave.  The 3 views can be scrolled 
// independently and individual slices can be saved to the packages:WM_3Sliders folder.
// To invoke the procedure call WM_init3Sliders().
// 24MAY04
// Added user guides to make sure that images display properly after the window is minimized.
// 30SEP04
// Added Insert and Remove planes.
// Added histogram button
// 04OCT04
// Added line profiles and histograms.
// 09AUG05 reduced the upper limit.
// 17AUG05 changes to saving slices (wave scaling)
// 05JUN17 WM3SliderProc slider proc allows mousewheel to update slices.
// 07NOV18 changed code for new DB and truncated names of layers.
// TODO: add support for user selected colortables.
//*************************************************************************
constant kOriginalBottom=407									// 23MAY05

Function WM_init3Sliders()
	
	String curDF=GetDataFolder(1)							// to revert to the last data folder the user selected.
	CreateBrowser Prompt="Choose a 3D wave to display in the panel",showWaves=1
	if(V_Flag==0)
		return 0
	endif
	Wave/Z srcWave=$StringFromList(0, S_BrowserList, ";")
	if(WaveExists(srcWave))
		if(DimSize(srcWave,2)<=0 || DimSize(srcWave,3)>0)
			Abort "Bad wave dimensionality."
		endif
	else
		Abort "Bad wave specification."
	endif

	KillStrings/Z S_BrowserList
	KillVariables/Z V_Flag
	
	String dfName=NameOfWave(srcWave)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S WM_3Sliders
	KillWaves/A/Z													// We do not support more than one concurrent 3D display.
	
	Variable/G minValue
	Variable/G maxValue
	Variable/G dummy=0
	Variable/G editMode=0											// set to 1 for cropping volume.
	Variable/G xPos1,yPos1,zPos1,xPos2,yPos2,zPos2
	String/G zImageName,yImageName,xImageName
	Variable/G showHistograms=0
	Variable/G showLineProfiles=0
	Variable/G theZLayer
	Variable/G theYLayer
	Variable/G theXLayer
	
	String/G srcWaveName=GetWavesDataFolder(srcWave, 2 )
	threeViewPanelF()												// create the panel

	String dependStr="WM_updateXYWaves("+srcWaveName+")"
	SetFormula dummy,dependStr									// sets the main dependency; any change to the source file will be reflected on the panel.... a bit later though.
	
	// At this point the dependency must have created the waves for display in the y-axis and x-axis so
	// let's append them:
	AppendImage/T/W=threeViewPanel#G0 srcWave
	zImageName=PossiblyQuoteName(nameofwave(srcWave)) 
	ModifyImage/W=threeViewPanel#G0  $zImageName ctab= {*,*,Grays,0}
	ModifyGraph/W=threeViewPanel#G0  margin(left)=1,margin(bottom)=1,margin(top)=1,margin(right)=1,mirror=0,nticks=0,noLabel=2,standoff=0,axThick=0
	
	Wave YAxisWave=root:Packages:WM_3Sliders:YAxisWave
	AppendImage/T/W=threeViewPanel#G1 YAxisWave
	yImageName=PossiblyQuoteName(nameofwave(YAxisWave))
	ModifyImage/W=threeViewPanel#G1  $yImageName ctab= {*,*,Grays,0}
	ModifyGraph/W=threeViewPanel#G1  margin(left)=1,margin(bottom)=1,margin(top)=1,margin(right)=1,mirror=0,nticks=0,noLabel=2,standoff=0,axThick=0
	
	Wave XAxisWave=root:Packages:WM_3Sliders:XAxisWave
	xImageName=PossiblyQuoteName(nameofwave(XAxisWave))
	AppendImage/T/W=threeViewPanel#G2 XAxisWave
	ModifyImage/W=threeViewPanel#G2  $xImageName ctab= {*,*,Grays,0}
	ModifyGraph/W=threeViewPanel#G2  margin(left)=1,margin(bottom)=1,margin(top)=1,margin(right)=1,mirror=0,nticks=0,noLabel=2,standoff=0,axThick=0
	
	WM_updateXYWaves(srcWave)									// when called now it sets the min and max for ModifyImage.
	WM_initSliderPositions()
	SetDataFolder curDF
End

//*************************************************************************
// The following is a dependency function.  It will be called any time that srcWave is changed.  On initialization it is called twice.

Function WM_updateXYWaves(srcWave)
	wave srcWave	

	// do not go into this if the dependent variable does not exist.
	NVAR/Z dummy=root:Packages:WM_3Sliders:dummy
	if(NVAR_EXISTS(dummy)==0)
		return 0
	endif
		
	String oldDF=GetDataFolder(1)
	SetDataFolder root:Packages:WM_3Sliders
	
	ImageTransform/G=1 transposeVol srcWave
	Wave M_VolumeTranspose
	Duplicate/O M_VolumeTranspose YAxisWave
	ImageTransform/G=4 transposeVol srcWave
	Wave M_VolumeTranspose
	Duplicate/O M_VolumeTranspose XAxisWave
	KillWaves/Z M_VolumeTranspose
	
	// to make the scaling more efficient calculate this once
	WaveStats/Q srcWave
	NVAR minValue=root:Packages:WM_3Sliders:minValue
	minValue=V_min
	NVAR maxValue=root:Packages:WM_3Sliders:maxValue
	maxValue=V_max

	// this variable is set to zero on the first invokation.  It will be set to 1 after the dependency is called
	// at least once.  By that time we can count on the images being displayed.
	if(dummy)
		SVAR zImageName=root:Packages:WM_3Sliders:zImageName
		SVAR yImageName=root:Packages:WM_3Sliders:yImageName
		SVAR xImageName=root:Packages:WM_3Sliders:xImageName

		ModifyImage/W=threeViewPanel#G0  $zImageName ctab= {minValue,maxValue,Grays,0}
		ModifyImage/W=threeViewPanel#G1  $yImageName ctab= {minValue,maxValue,Grays,0}
		ModifyImage/W=threeViewPanel#G2  $xImageName ctab= {minValue,maxValue,Grays,0}
	endif
	
	// set the ranges of the sliders:
	Slider  zViewSlider win=threeViewPanel,limits={DimOffset(srcWave,2),(DimOffset(srcWave,2)+(DimSize(srcWave,2)-1)*DimDelta(srcWave,2)),0}		// 09AUG05 reduced the upper limit.
	Slider  yViewSlider win=threeViewPanel,limits={DimOffset(srcWave,1),(DimOffset(srcWave,1)+(DimSize(srcWave,1)-1)*DimDelta(srcWave,1)),0}
	Slider  xViewSlider win=threeViewPanel, limits={DimOffset(srcWave,0),(DimOffset(srcWave,0)+(DimSize(srcWave,0)-1)*DimDelta(srcWave,0)),0}
	
	// now make sure that the sliders' position is properly initialized:
	Variable newValue
	ControlInfo/W=threeViewPanel zViewSlider
	 if(dummy==0 || V_Value>=DimSize(srcWave,2))
		String cmd
		newValue=DimOffset(srcWave,2)+DimDelta(srcWave,2)*DimSize(srcWave,2)/2
		Slider  zViewSlider win=threeViewPanel,value=(newValue)
		sprintf cmd,"WM3SliderProc(\"zViewSlider\", %d, 0)",newValue
		Execute/P/Q cmd
	endif
	
	ControlInfo/W=threeViewPanel yViewSlider
	if(dummy==0 || V_Value>=DimSize(srcWave,1))
		newValue=DimOffset(srcWave,1)+DimDelta(srcWave,1)*DimSize(srcWave,1)/2
		Slider  yViewSlider win=threeViewPanel,value=(newValue)
		sprintf cmd,"WM3SliderProc(\"yViewSlider\", %d, 0)",newValue
		Execute/P/Q cmd
	endif
	
	ControlInfo/W=threeViewPanel xViewSlider
	if(dummy==0 || V_Value>=DimSize(srcWave,0))
		newValue=DimOffset(srcWave,0)+DimDelta(srcWave,0)*DimSize(srcWave,0)/2
		Slider  xViewSlider win=threeViewPanel,value=(newValue)
		sprintf cmd,"WM3SliderProc(\"xViewSlider\", %d, 0)",newValue
		Execute/P/Q cmd
	endif
	
	SetDataFolder oldDF
	return 1
End

//*************************************************************************
// The following function is an unfortunate requirement because the slider does not call its own 
// procedure when its value is changed in a function.
Function WM_initSliderPositions()

	Variable newValue
	SVAR srcWaveName=root:Packages:WM_3Sliders:srcWaveName
	Wave srcWave=$srcWaveName
	newValue=DimOffset(srcWave,2)+DimDelta(srcWave,2)*DimSize(srcWave,2)/2
	WM3SliderProc("zViewSlider", newValue, 0)			 
	newValue=DimOffset(srcWave,1)+DimDelta(srcWave,1)*DimSize(srcWave,1)/2
	WM3SliderProc("yViewSlider", newValue, 0)			 
	newValue=DimOffset(srcWave,0)+DimDelta(srcWave,0)*DimSize(srcWave,0)/2
	WM3SliderProc("xViewSlider", newValue, 0)				
End
//*************************************************************************
// The following function is invoked by the Reverse axis checkboxes.

Function WMFlipXAxisCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	strswitch(ctrlName)
		case "WMFlipXCheck":
			if(checked)
				SetAxis/A/R/W=threeViewPanel#G0 left
			else
				SetAxis/A/W=threeViewPanel#G0 left
			endif
		break
		
		case "WMFlipXCheck1":
			if(checked)
				SetAxis/A/R/W=threeViewPanel#G1 left
			else
				SetAxis/A/W=threeViewPanel#G1 left
			endif
		break
		
		case "WMFlipXCheck2":
			if(checked)
				SetAxis/A/R/W=threeViewPanel#G2 left
			else
				SetAxis/A/W=threeViewPanel#G2 left
			endif
		break
	endswitch
	
	NVAR showLineProfiles=root:Packages:WM_3Sliders:showLineProfiles
	if(showLineProfiles)
		WM_UpdateLineProfiles()
	endif
End
//*************************************************************************
// The following function is invoked by the Reverse Top checkboxes.

Function wmFlipYAxisCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	strswitch(ctrlName)
		case "WMFlipYCheck":
			if(checked)
				SetAxis/A/R/W=threeViewPanel#G0 top
			else
				SetAxis/A/W=threeViewPanel#G0 top
			endif
		break
		
		case "WMFlipYCheck1":
			if(checked)
				SetAxis/A/R/W=threeViewPanel#G1 top
			else
				SetAxis/A/W=threeViewPanel#G1 top
			endif
		break
		
		case "WMFlipYCheck2":
			if(checked)
				SetAxis/A/R/W=threeViewPanel#G2 top
			else
				SetAxis/A/W=threeViewPanel#G2 top
			endif
		break
	endswitch
	
	NVAR showLineProfiles=root:Packages:WM_3Sliders:showLineProfiles
	if(showLineProfiles)
		WM_UpdateLineProfiles()
	endif
End
//*************************************************************************
// The following function is called when the user clicks in one of the Save buttons.
// The 2D waves are saved in the "root:"+waveName+"Slices" folder using identifying names that include their
// axis and their layer number.

Function wmSaveSliceButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Variable thePlane
	SVAR srcWaveName=root:Packages:WM_3Sliders:srcWaveName
	String location=GetWavesDataFolder($srcWaveName,1)
	String outName
	
	String curDF=GetDataFolder(1)
	SetDataFolder location
	outName=NameOfWave($srcWaveName)+"Slices"
	outName=CleanupName(outName, 1)
	NewDataFolder/O/S $outName
	
	strswitch(ctrlName)
		case "WMSaveSliceButton":
			ControlInfo/W=threeViewPanel zViewSlider
			Wave srcWave=$srcWaveName
			thePlane=(V_Value-DimOffset(srcWave,2))/DimDelta(srcWave,2)		// 17AUG05
			thePlane=trunc(thePlane)														// 07NOV18
			ImageTransform /P=(thePlane) GetPlane srcWave
			Wave M_ImagePlane
			outName="M_ZAxis"+num2str(thePlane)
			Duplicate/O M_ImagePlane,$outName
			KillWaves/Z M_ImagePlane
		break
		
		case "WMSaveSliceButton1":
			Wave YAxisWave=root:Packages:WM_3Sliders:YAxisWave
			ControlInfo/W=threeViewPanel yViewSlider
			thePlane=(V_Value-DimOffset(YAxisWave,2))/DimDelta(YAxisWave,2)		// 17AUG05
			thePlane=trunc(thePlane)															// 07NOV18
			ImageTransform /P=(thePlane) GetPlane YAxisWave
			Wave M_ImagePlane
			outName="M_YAxis"+num2str(thePlane)
			Duplicate/O M_ImagePlane,$outName
			KillWaves/Z M_ImagePlane
		break
		
		case "WMSaveSliceButton2":
			Wave XAxisWave=root:Packages:WM_3Sliders:XAxisWave
			ControlInfo/W=threeViewPanel xViewSlider
			thePlane=(V_Value-DimOffset(XAxisWave,2))/DimDelta(XAxisWave,2)		// 17AUG05
			thePlane=trunc(thePlane)															// 07NOV18
			ImageTransform /P=(thePlane) GetPlane XAxisWave
			Wave M_ImagePlane
			outName="M_XAxis"+num2str(thePlane)
			Duplicate/O M_ImagePlane,$outName
			KillWaves/Z M_ImagePlane
		break
	endswitch
	
	SetDataFolder curDF
End

//*************************************************************************
// The following function creates the panel.

Function threeViewPanelF()  
	
	DoWindow/F threeViewPanel
	if(V_Flag)
		return 0
	endif
	NewPanel/K=1 /W=(105,59,920,466) as "3 views panel"
	DoWindow/C threeViewPanel
	SetDrawLayer UserBack
	DrawText 24,15,"Z-Axis"
	DrawText 281,15,"Y-Axis"
	DrawText 545,15,"X-Axis"
	CheckBox WMFlipXCheck,pos={19,300},size={102,14},proc=WMFlipXAxisCheckProc,title="Reverse Left-Axis"
	CheckBox WMFlipXCheck,value= 0
	CheckBox WMFlipXCheck1,pos={280,300},size={102,14},proc=WMFlipXAxisCheckProc,title="Reverse Left-Axis"
	CheckBox WMFlipXCheck1,value= 0
	CheckBox WMFlipXCheck2,pos={540,300},size={102,14},proc=WMFlipXAxisCheckProc,title="Reverse Left-Axis"
	CheckBox WMFlipXCheck2,value= 0
	CheckBox wmFlipYCheck,pos={19,315},size={100,14},proc=wmFlipYAxisCheckProc,title="Reverse Top-Axis"
	CheckBox wmFlipYCheck,value= 0
	CheckBox wmFlipYCheck1,pos={280,315},size={100,14},proc=wmFlipYAxisCheckProc,title="Reverse Top-Axis"
	CheckBox wmFlipYCheck1,value= 0
	CheckBox wmFlipYCheck2,pos={540,315},size={100,14},proc=wmFlipYAxisCheckProc,title="Reverse Top-Axis"
	CheckBox wmFlipYCheck2,value= 0
	CheckBox wmShowCropCheck,pos={22,377},size={101,14},proc=threeDCroppingCheckProc,title="Allow 3D Cropping"
	CheckBox wmShowCropCheck,value= 0
	Button WMSaveSliceButton,pos={157,298},size={100,20},proc=wmSaveSliceButtonProc,title="Save Slice"
	Button WMSaveSliceButton1,pos={417,298},size={100,20},proc=wmSaveSliceButtonProc,title="Save Slice"
	Button WMSaveSliceButton2,pos={679,298},size={100,20},proc=wmSaveSliceButtonProc,title="Save Slice"
	Button WMCropButton,pos={142,375},size={170,20},disable=2,proc=saveCroppedSelectionButtonProc,title="Save Cropped Selection"
	Button WMRemoveSliceButton,pos={157,321},size={100,20},proc=WMRemoveSliceButtonProc,title="Remove Slice"
	Button WMRemoveSliceButton1,pos={417,321},size={100,20},proc=WMRemoveSliceButtonProc,title="Remove Slice"
	Button WMRemoveSliceButton2,pos={679,321},size={100,20},proc=WMRemoveSliceButtonProc,title="Remove Slice"
	Button WMInsertSliceButton,pos={157,344},size={100,20},proc=WMInsertSliceButtonProc,title="Insert Slice"
	Button WMInsertSliceButton1,pos={417,344},size={100,20},proc=WMInsertSliceButtonProc,title="Insert Slice"
	Button WMInsertSliceButton2,pos={679,344},size={100,20},proc=WMInsertSliceButtonProc,title="Insert Slice"
	Slider zViewSlider,pos={21,23},size={200,45},proc=WM3SliderProc
	Slider zViewSlider,limits={0,2,1},value= 0,live= 1,vert= 0,ticks=5
	Slider yViewSlider,pos={282,23},size={200,45},proc=WM3SliderProc
	Slider yViewSlider,limits={0,2,1},value= 0,live= 1,vert= 0,ticks=5
	Slider xViewSlider,pos={551,23},size={200,45},proc=WM3SliderProc
	Slider xViewSlider,limits={0,2,1},value= 0,live= 1,vert= 0,ticks=5
	Slider WM_ZHProfileSlider,pos={3,63},size={16,235},proc=WMHProfileSliderProc,disable=1
	Slider WM_ZHProfileSlider,limits={0,99,0},value= 50,ticks= 0
	Slider WM_YHProfileSlider,pos={263,63},size={16,235},proc=WMHProfileSliderProc,disable=1
	Slider WM_YHProfileSlider,limits={0,99,0},value= 50,ticks= 0
	Slider WM_XHProfileSlider,pos={523,63},size={16,235},proc=WMHProfileSliderProc,disable=1
	Slider WM_XHProfileSlider,limits={0,99,0},value= 50,ticks= 0

	CheckBox WM_ShowHistogramCheck,pos={338,378},size={96,14},proc=WM_ShowHistogramCheckProc,title="Show Histograms"
	CheckBox WM_ShowHistogramCheck, variable=root:Packages:WM_3Sliders:showHistograms
	CheckBox WMShowLineProfiles,pos={444,378},size={102,14},proc=WM_ShowLineProfilesCheckProc,title="Show Line Profiles"
	CheckBox WMShowLineProfiles, variable=root:Packages:WM_3Sliders:showLineProfiles	
	DefineGuide UGH0={FT,293},UGH1={FT,71},UGV0={FL,19},UGV1={FL,258},UGV2={FL,280},UGV3={FL,518}
	DefineGuide UGV4={FL,540},UGV5={FL,779}
	Display/W=(20,59,260,300)/FG=(UGV0,UGH1,UGV1,UGH0)/HOST=# 
	ModifyGraph mirror=2
	RenameWindow #,G0
	SetActiveSubwindow ##
	Display/W=(280,60,520,294)/FG=(UGV2,UGH1,UGV3,UGH0)/HOST=# 
	RenameWindow #,G1
	SetActiveSubwindow ##
	Display/W=(546,54,780,302)/FG=(UGV4,UGH1,UGV5,UGH0)/HOST=# 
	RenameWindow #,G2
	SetActiveSubwindow ##
	SetWindow kwTopWin, hook(test)=threeViewWindowHook
	ModifyPanel fixedSize=1
End

//*************************************************************************
Function threeViewWindowHook(s)
	STRUCT WMWinHookStruct &s
	
	NVAR/Z editMode=root:Packages:WM_3Sliders:editMode
	Variable rval= 0

	switch(s.eventCode)
		case 2:				// "kill":
			if(cmpstr(s.winName,"threeViewPanel")==0)
				// we kill the dependency just in case we later can't kill the data folder (e.g., if the user has used the
				// enclosed waves in graphs or tables.
				NVAR/Z dummy=root:Packages:WM_3Sliders:dummy
				if(NVAR_EXISTS(dummy))
					SetFormula dummy,""
					KillVariables/Z dummy
				endif
				editMode=0
				if(DataFolderExists("root:Packages:WM_3Sliders"))
					// remove the images before we can kill the data folder.
					SVAR yImageName=root:Packages:WM_3Sliders:yImageName
					SVAR xImageName=root:Packages:WM_3Sliders:xImageName
		
					RemoveImage /W=threeViewPanel#G1  $yImageName
					RemoveImage /W=threeViewPanel#G2  $xImageName
					
					NVAR showHistograms=root:Packages:WM_3Sliders:showHistograms
					if(showHistograms)
						KillWindow threeviewpanel#G3
						KillWindow threeviewpanel#G4
						KillWindow threeviewpanel#G5
					endif
					
					NVAR showLineProfiles=root:Packages:WM_3Sliders:showLineProfiles
					if(showLineProfiles)
						KillWindow threeviewpanel#G6							// 23MAY05 changed to killing the windows.
						KillWindow threeviewpanel#G7
						KillWindow threeviewpanel#G8
					endif
					
						KillWindow threeviewpanel#G0							// 23MAY05 changed to killing the windows.
						KillWindow threeviewpanel#G1
						KillWindow threeviewpanel#G2
					
					KillDataFolder/Z  root:Packages:WM_3Sliders				// 23MAY05 added /Z
					// remove the Packages data folder only if it is empty.
					if(CountObjects("root:Packages", 1 )+CountObjects("root:Packages", 2 )+CountObjects("root:Packages", 3 )+CountObjects("root:Packages", 4 )==0)
						KillDataFolder root:Packages
					endif
				endif
			endif
		break
		
		case 7:				// "cursormoved":
			if(editMode==1)
				editMode=0			// lock out recursion
				String imageName=s.traceName		// StringByKey("TNAME",infoStr)
				Variable xPos=s.pointNumber		// NumberByKey("POINT", infoStr,":",";")
				Variable yPos=s.yPointNumber		// NumberByKey("YPOINT", infoStr,":",";")
				String whichCursor=s.cursorName	// StringByKey("CURSOR",infoStr)

				// Printf "Image=%s position=(%d,%d)\r",imageName,xPos,yPos
				SVAR zImageName=root:Packages:WM_3Sliders:zImageName
				SVAR yImageName=root:Packages:WM_3Sliders:yImageName
				SVAR xImageName=root:Packages:WM_3Sliders:xImageName
				NVAR xPos1=root:Packages:WM_3Sliders:xPos1
				NVAR yPos1=root:Packages:WM_3Sliders:yPos1
				NVAR zPos1=root:Packages:WM_3Sliders:zPos1
				NVAR xPos2=root:Packages:WM_3Sliders:xPos2
				NVAR yPos2=root:Packages:WM_3Sliders:yPos2
				NVAR zPos2=root:Packages:WM_3Sliders:zPos2
				SVAR srcWaveName=root:Packages:WM_3Sliders:srcWaveName
				Wave srcWave=$srcWaveName
				
				if(cmpstr(zImageName,imageName)==0)
					if(cmpstr(whichCursor,"A")==0)
						xPos1=DimOffset(srcWave,0)+xPos*DimDelta(srcWave,0)
						yPos1=DimOffset(srcWave,1)+yPos*DimDelta(srcWave,1)
					else
						xPos2=DimOffset(srcWave,0)+xPos*DimDelta(srcWave,0)
						yPos2=DimOffset(srcWave,1)+yPos*DimDelta(srcWave,1)
					endif
				elseif(cmpstr(yImageName,imageName)==0)
					if(cmpstr(whichCursor,"A")==0)
						xPos1=DimOffset(srcWave,0)+xPos*DimDelta(srcWave,0)
						zPos1=DimOffset(srcWave,2)+yPos*DimDelta(srcWave,2)
					else
						xPos2=DimOffset(srcWave,0)+xPos*DimDelta(srcWave,0)
						zPos2=DimOffset(srcWave,2)+yPos*DimDelta(srcWave,2)
					endif
				elseif(cmpstr(xImageName,imageName)==0)
					if(cmpstr(whichCursor,"A")==0)
						yPos1=DimOffset(srcWave,1)+xPos*DimDelta(srcWave,1)
						zPos1=DimOffset(srcWave,2)+yPos*DimDelta(srcWave,2)
					else
						yPos2=DimOffset(srcWave,1)+xPos*DimDelta(srcWave,1)
						zPos2=DimOffset(srcWave,2)+yPos*DimDelta(srcWave,2)
					endif
				endif
			
				WM_position3Cursors(xPos1,yPos1,zPos1,xPos2,yPos2,zPos2)
				editMode=1
				rval=1
			endif
		break
	endswitch
	
	return rval
End

//*************************************************************************
Function WM3SliderProc(name, value, event)
	String name			// name of this slider control
	Variable value		// value of slider
	Variable event		// bit field: bit 0: value set; 1: mouse down, //   2: mouse up, 3: mouse moved

	if(event&8)
		if( !(event&1) ) // 05JUN17: mouse wheel is "mouse moved + value set"
			return 0
		endif
	endif
	
	Variable theLayer=value
	String imageName=""
	// to use wave scaling uncomment the following line:
	SVAR srcWaveName=root:Packages:WM_3Sliders:srcWaveName
	Wave srcWave=$srcWaveName
	
	strswitch(name)
		case "zViewSlider":
			SVAR zImageName=root:Packages:WM_3Sliders:zImageName
			imageName=zImageName
			// to use wave scaling uncomment the following line.
			theLayer=(value-DimOffset(srcWave,2))/DimDelta(srcWave,2)
			ModifyImage/W=threeViewPanel#G0 $imageName plane=(theLayer)	
			NVAR theZLayer=root:Packages:WM_3Sliders:theZLayer
			theZLayer=theLayer
		break
		
		case "yViewSlider":
			SVAR yImageName=root:Packages:WM_3Sliders:yImageName
			imageName=yImageName
			// to use wave scaling uncomment the following line.
			theLayer=(value-DimOffset(srcWave,1))/DimDelta(srcWave,1)
			ModifyImage/W=threeViewPanel#G1 $imageName plane=(theLayer)	
			NVAR theYLayer=root:Packages:WM_3Sliders:theYLayer
			theYLayer=theLayer
		break
		
		case "xViewSlider":
			SVAR xImageName=root:Packages:WM_3Sliders:xImageName
			imageName=xImageName
			// to use wave scaling uncomment the following line.
			theLayer=(value-DimOffset(srcWave,0))/DimDelta(srcWave,0)
			ModifyImage/W=threeViewPanel#G2 $imageName plane=(theLayer)	
			NVAR theXLayer=root:Packages:WM_3Sliders:theXLayer
			theXLayer=theLayer
		break
		
		default:
			Abort "Bad Slider hooked up"
	endswitch
	
	NVAR showHistograms=root:Packages:WM_3Sliders:showHistograms
	if(showHistograms)
		WM_UpdateHistograms()
	endif
	
	NVAR showLineProfiles=root:Packages:WM_3Sliders:showLineProfiles
	if(showLineProfiles)
		WM_UpdateLineProfiles()
	endif
	
	
	return 0				// other return values reserved
End
//*************************************************************************
Function threeDCroppingCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	SVAR srcWaveName=root:Packages:WM_3Sliders:srcWaveName
	NVAR editMode=root:Packages:WM_3Sliders:editMode
	
	if(checked)
		Button WMCropButton,win=threeViewPanel,disable=0
		// compute the starting position for the cursors.  This is complicated because of silly wave scaling.
		// The two cursors will appear somewhere close to the center of the display with a slight difference
		// in position.
		Wave srcWave=$srcWaveName
		NVAR xPos1=root:Packages:WM_3Sliders:xPos1
		NVAR yPos1=root:Packages:WM_3Sliders:yPos1
		NVAR zPos1=root:Packages:WM_3Sliders:zPos1
		NVAR xPos2=root:Packages:WM_3Sliders:xPos2
		NVAR yPos2=root:Packages:WM_3Sliders:yPos2
		NVAR zPos2=root:Packages:WM_3Sliders:zPos2
		xPos1=DimOffset(srcWave,0)+DimDelta(srcWave,0)*(DimSize(srcWave,0)/4)
		xPos2=DimOffset(srcWave,0)+3*DimDelta(srcWave,0)*(DimSize(srcWave,0)/4)
		yPos1=DimOffset(srcWave,1)+DimDelta(srcWave,1)*(DimSize(srcWave,1)/4)
		yPos2=DimOffset(srcWave,1)+3*DimDelta(srcWave,1)*(DimSize(srcWave,1)/4)
		zPos1=DimOffset(srcWave,2)+DimDelta(srcWave,2)*(DimSize(srcWave,2)/4)
		zPos2=DimOffset(srcWave,2)+3*DimDelta(srcWave,2)*(DimSize(srcWave,2)/4)
		
		
		WM_position3Cursors(xPos1,yPos1,zPos1,xPos2,yPos2,zPos2)
		editMode=1					// only _after_ setting up the cursors.
		
	else
		editMode=0					// must precede any changes.
		Button WMCropButton,win=threeViewPanel,disable=2
		cursor/A=1/w=threeviewpanel#G0/k A 
		cursor/A=1/w=threeviewpanel#G0/k B 
		
		cursor/A=1/w=threeviewpanel#G1/k A
		cursor/A=1/w=threeviewpanel#G1/k B 
		
		cursor/A=1/w=threeviewpanel#G2/k A
		cursor/A=1/w=threeviewpanel#G2/k B 
	endif
End

//*************************************************************************
// The following function updates the position of the 3 pairs of cursors.

Function WM_position3Cursors(xPos1,yPos1,zPos1,xPos2,yPos2,zPos2)
	Variable xPos1,yPos1,zPos1,xPos2,yPos2,zPos2
		
	SVAR zImageName=root:Packages:WM_3Sliders:zImageName
	SVAR yImageName=root:Packages:WM_3Sliders:yImageName
	SVAR xImageName=root:Packages:WM_3Sliders:xImageName
	
	cursor/A=1/w=threeviewpanel#G0/C=(65535,0,0)/H=1/S=2/i A,$zImageName,xPos1,yPos1
	cursor/A=1/w=threeviewpanel#G0/C=(0,65535,0)/H=1/S=2/i B,$zImageName,xPos2,yPos2
	
	cursor/A=1/w=threeviewpanel#G1/C=(65535,0,0)/H=1/S=2/i A,$yImageName,xPos1,zPos1
	cursor/A=1/w=threeviewpanel#G1/C=(0,65535,0)/H=1/S=2/i B,$yImageName,xPos2,zPos2
	
	cursor/A=1/w=threeviewpanel#G2/C=(65535,0,0)/H=1/S=2/i A,$xImageName,yPos1,zPos1
	cursor/A=1/w=threeviewpanel#G2/C=(0,65535,0)/H=1/S=2/i B,$xImageName,yPos2,zPos2
End

//*************************************************************************
// We will try to place the cropped image in the same data folder as the slices.
Function saveCroppedSelectionButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	NVAR xPos1=root:Packages:WM_3Sliders:xPos1
	NVAR yPos1=root:Packages:WM_3Sliders:yPos1
	NVAR zPos1=root:Packages:WM_3Sliders:zPos1
	NVAR xPos2=root:Packages:WM_3Sliders:xPos2
	NVAR yPos2=root:Packages:WM_3Sliders:yPos2
	NVAR zPos2=root:Packages:WM_3Sliders:zPos2
	SVAR srcWaveName=root:Packages:WM_3Sliders:srcWaveName
	Wave srcWave=$srcWaveName

	String location=GetWavesDataFolder($srcWaveName,1)
	String outName
	
	String curDF=GetDataFolder(1)
	SetDataFolder location
	outName=NameOfWave(srcWave)+"Slices"
	outName=CleanupName(outName,1)
	NewDataFolder/O/S $outName
	
	outName=NameOfWave(srcWave)+"_cr"
	outName=UniqueName(outName, 1,0)
	Duplicate/O/R=(xpos1,xpos2)(ypos1,ypos2)(zpos1,zpos2) srcWave,$outName
	
	SetDataFolder curDF
End
//*************************************************************************
// The current plane is given in the RECREATION field of ImageInfo
// e.g., ImageInfo("threeViewPanel#G0","median",0)
// Remove and Inset below apply to the source wave.  The dependency takes care
// of updating the associated waves.
Function WMRemoveSliceButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Variable curPlane
	SVAR srcWaveName=root:Packages:WM_3Sliders:srcWaveName
	Wave/Z srcWave=$srcWaveName
	if(WaveExists(srcWave)==0)
		Abort  "Source Wave is missing"
		return 0
	endif
	
	strswitch(ctrlName)
		case "WMRemoveSliceButton":
			curPlane=WM_GetCurrentShowingPlane("threeViewPanel#G0",NameOfWave(srcWave))		// 13JAN12
			ImageTransform /O/P=(curPlane) removeZPlane srcWave
		break
		
		case "WMRemoveSliceButton1":
			curPlane=WM_GetCurrentShowingPlane("threeViewPanel#G1","YAxisWave")
			ImageTransform/O /P=(curPlane) removeYPlane srcWave
		break
		
		case "WMRemoveSliceButton2":
			curPlane=WM_GetCurrentShowingPlane("threeViewPanel#G2","XAxisWave")
			ImageTransform/O /P=(curPlane) removeXPlane srcWave
		break
		
	endswitch
End
//*************************************************************************

Function WMInsertSliceButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Variable curPlane
	SVAR srcWaveName=root:Packages:WM_3Sliders:srcWaveName
	Wave/Z srcWave=$srcWaveName
	if(WaveExists(srcWave)==0)
		Abort  "Source Wave is missing"
		return 0
	endif
	
	String curDF=GetDataFolder(1)							// to revert to the last data folder the user selected.
	CreateBrowser Prompt="Choose a Slice wave insert in the current position",showWaves=1
	if(V_Flag==0)
		return 0
	endif
	Wave insertedWave=$StringFromList(0,S_BrowserList,";")
	SetDataFolder curDF
	if(WaveExists(insertedWave)==0)
		return 0
	endif
	
	strswitch(ctrlName)
		case "WMInsertSliceButton":
			curPlane=WM_GetCurrentShowingPlane("threeViewPanel#G0",NameOfWave(srcWave))	// 13JAN12
			ImageTransform/O/INSW=insertedWave /P=(curPlane)  insertZPlane srcWave
		break
		
		case "WMInsertSliceButton1":
			curPlane=WM_GetCurrentShowingPlane("threeViewPanel#G1","YAxisWave")
			ImageTransform/O/INSW=insertedWave /P=(curPlane)insertYPlane srcWave
		break
		
		case "WMInsertSliceButton2":
			curPlane=WM_GetCurrentShowingPlane("threeViewPanel#G2","XAxisWave")
			ImageTransform/O/INSW=insertedWave /P=(curPlane) insertXPlane srcWave
		break
		
	endswitch
End

//*************************************************************************
// Looks at the zeroth instance image only!
Function WM_GetCurrentShowingPlane(winNameStr,imageNameStr)
	String winNameStr,imageNameStr
	
	return NumberByKey("plane",ImageInfo(winNameStr,imageNameStr,0),"=")
End
//*************************************************************************
Function WM_ShowHistogramCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	if(checked)
			WM_SetWindowSize(1,0)
	else
			WM_SetWindowSize(-1,0)
	endif
End
//*************************************************************************
// Adjust the height of the window for the options the user clicked on. +1 ==> add, -1 ==> remove, 0 ==> unchanged.
constant kHistogramHeight=200

Function  WM_SetWindowSize(histogramHeight,lineProfileHeight)
	Variable histogramHeight,lineProfileHeight
	
	NVAR showHistograms=root:Packages:WM_3Sliders:showHistograms
	NVAR showLineProfiles=root:Packages:WM_3Sliders:showLineProfiles
	GetWindow threeviewpanel wSize
	Variable resFactor=72/screenResolution
	Variable gLeft,gRight,gTop,gBottom
	
	gLeft=V_left/resFactor
	gRight=V_right/resFactor
	gTop=V_top/resFactor
	gBottom=V_bottom/resFactor
	
	if(histogramHeight>0)
		// Define a new guide at the current bottom:
		DefineGuide /W=threeviewpanel UGHistTop={FT,(gBottom-gTop)}
		DefineGuide /W=threeviewpanel UGHistBottom={FT,(gBottom-gTop+kHistogramHeight-10)}
		
		MoveWindow /W=threeviewpanel V_left,V_top,V_right,(V_bottom+kHistogramHeight*resFactor)
		WM_UpdateHistograms()
		WM_DisplayHistograms()
	elseif(histogramHeight<0)
		// 23MAY05 MoveWindow /W=threeviewpanel V_left,V_top,V_right,(V_bottom-kHistogramHeight)
		MoveWindow /W=threeviewpanel V_left,V_top,V_right,V_top+(kOriginalBottom+kHistogramHeight*showLineProfiles)*resFactor
		KillWindow threeviewpanel#G3
		KillWindow threeviewpanel#G4
		KillWindow threeviewpanel#G5
		if(showLineProfiles)				// move the guides up
			GetWindow threeviewpanel wSize
			gLeft=V_left/resFactor
			gRight=V_right/resFactor
			gTop=V_top/resFactor
			gBottom=V_bottom/resFactor
			DefineGuide /W=threeviewpanel UGProfileTop={FT,(gBottom-gTop-kHistogramHeight)}
			DefineGuide /W=threeviewpanel UGProfileBottom={FT,(gBottom-gTop-10)}
		endif
	endif
	
	GetWindow threeviewpanel wSize
	gLeft=V_left/resFactor
	gRight=V_right/resFactor
	gTop=V_top/resFactor
	gBottom=V_bottom/resFactor

	if(lineProfileHeight>0)
		// Define a new guide at the current bottom:
		DefineGuide /W=threeviewpanel UGProfileTop={FT,(gBottom-gTop)}
		DefineGuide /W=threeviewpanel UGProfileBottom={FT,(gBottom-gTop+kHistogramHeight-10)}
		MoveWindow /W=threeviewpanel V_left,V_top,V_right,V_bottom+kHistogramHeight*resFactor
		WM_UpdateLineProfiles()
		WM_DisplayLineProfiles()
	elseif(lineProfileHeight<0)
		// 23MAY05 MoveWindow /W=threeviewpanel V_left,V_top,V_right,(V_bottom-kHistogramHeight)
		MoveWindow /W=threeviewpanel V_left,V_top,V_right,V_top+(kOriginalBottom+kHistogramHeight*showHistograms)*resFactor
		KillWindow threeviewpanel#G6
		KillWindow threeviewpanel#G7
		KillWindow threeviewpanel#G8
		RemoveFromGraph /W=threeviewpanel#G0 yyy0
		RemoveFromGraph /W=threeviewpanel#G1 yyy1
		RemoveFromGraph /W=threeviewpanel#G2 yyy2
		if(showHistograms)				// move the guides up
			GetWindow threeviewpanel wSize
			gLeft=V_left/resFactor
			gRight=V_right/resFactor
			gTop=V_top/resFactor
			gBottom=V_bottom/resFactor
			DefineGuide /W=threeviewpanel UGHistTop={FT,(gBottom-gTop-kHistogramHeight)}
			DefineGuide /W=threeviewpanel UGHistBottom={FT,(gBottom-gTop-10)}
		endif
	endif
End
//*************************************************************************
// Get the plane numbers for each of the images and use them to generate an ImageHistogram into
// 3 specially named waves.  
Function WM_UpdateHistograms()

	Variable 	curPlane
	SVAR srcWaveName=root:Packages:WM_3Sliders:srcWaveName
	Wave/Z srcWave=$srcWaveName
	if(WaveExists(srcWave)==0)
		Abort  "Source Wave is missing"
		return 0
	endif
	
	String oldDF=GetDataFolder(1)
	SetDataFolder root:Packages:WM_3Sliders
	curPlane=WM_GetCurrentShowingPlane("threeViewPanel#G0",NameOfWave(srcWave))

	ImageHistogram /P=(curPlane) srcWave
	Wave W_ImageHist
	Duplicate/O W_ImageHist,W_ZPlaneHist
	
	Wave/z YAxisWave
	if(WaveExists(YAxisWave))
		curPlane=WM_GetCurrentShowingPlane("threeViewPanel#G1","YAxisWave")
		ImageHistogram /P=(curPlane) YAxisWave
		Wave W_ImageHist
		Duplicate/O W_ImageHist,W_YPlaneHist
	endif
	
	Wave/z XAxisWave
	if(WaveExists(XAxisWave))
		curPlane=WM_GetCurrentShowingPlane("threeViewPanel#G2","XAxisWave")
		ImageHistogram /P=(curPlane) XAxisWave
		Wave W_ImageHist
		Duplicate/O W_ImageHist,W_XPlaneHist
	endif

	SetDataFolder oldDF
End
//*************************************************************************
// the three histogram windows are hard wired as G3, G4, G5
Function WM_DisplayHistograms()

	String oldDF=GetDataFolder(1)
	SetDataFolder root:Packages:WM_3Sliders
	
	Wave/Z W_ZPlaneHist,W_YPlaneHist,W_XPlaneHist
	
	Display/FG=(UGV0,UGHistTop,UGV1,UGHistBottom)/HOST=threeviewpanel
	if(WaveExists(W_ZPlaneHist))
		AppendToGraph W_ZPlaneHist
	endif
	RenameWindow #,G3
	
	Display/FG=(UGV2,UGHistTop,UGV3,UGHistBottom)/HOST=threeviewpanel
	if(WaveExists(W_YPlaneHist))
		AppendToGraph W_YPlaneHist
	endif
	RenameWindow #,G4
	
	Display/FG=(UGV4,UGHistTop,UGV5,UGHistBottom)/HOST=threeviewpanel
	if(WaveExists(W_XPlaneHist))
		AppendToGraph W_XPlaneHist
	endif
	RenameWindow #,G5
	
	SetDataFolder oldDF
End
//*************************************************************************
Function WM_ShowLineProfilesCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	if(checked)
			WM_SetWindowSize(0,1)
			Slider  WM_ZHProfileSlider,disable=0
			Slider  WM_YHProfileSlider,disable=0
			Slider  WM_XHProfileSlider,disable=0
	else
			WM_SetWindowSize(0,-1)
			Slider  WM_ZHProfileSlider,disable=1
			Slider  WM_YHProfileSlider,disable=1
			Slider  WM_XHProfileSlider,disable=1
	endif
End
//*************************************************************************
Function WM_DisplayLineProfiles()

	String oldDF=GetDataFolder(1)
	SetDataFolder root:Packages:WM_3Sliders
	
	Wave/Z W_ZPlaneProfile,W_YPlaneProfile,W_XPlaneProfile
		
	Display/FG=(UGV0,UGProfileTop,UGV1,UGProfileBottom)/HOST=threeviewpanel
	if(WaveExists(W_ZPlaneProfile))
		AppendToGraph W_ZPlaneProfile
	endif
	RenameWindow #,G6
	
	Display/FG=(UGV2,UGProfileTop,UGV3,UGProfileBottom)/HOST=threeviewpanel
	if(WaveExists(W_YPlaneProfile))
		AppendToGraph W_YPlaneProfile
	endif
	RenameWindow #,G7
	
	Display/FG=(UGV4,UGProfileTop,UGV5,UGProfileBottom)/HOST=threeviewpanel
	if(WaveExists(W_XPlaneProfile))
		AppendToGraph W_XPlaneProfile
	endif
	RenameWindow #,G8
	
	Wave/Z xxx, yyy0,yyy1,yyy2
	if(WaveExists(xxx))
		SetActiveSubwindow ##
		SetActiveSubwindow #G0
		AppendToGraph/T yyy0 vs xxx
		
		SetActiveSubwindow ##
		SetActiveSubwindow #G1
		AppendToGraph/T yyy1 vs xxx
		
		SetActiveSubwindow ##
		SetActiveSubwindow #G2
		AppendToGraph/T yyy2 vs xxx
	endif
	SetActiveSubwindow ##
	SetDataFolder oldDF
End
//*************************************************************************
// updates the 3 waves displayed as profiles based on the positions of the sliders and the states of checkboxes.
//
Function WM_UpdateLineProfiles()

	Variable sliderXPosition				// expressed in % from 0 to 99
	Variable sliderYPosition				// expressed in % from 0 to 99
	Variable sliderZPosition				// expressed in % from 0 to 99
	Variable leftFlip
	Variable bottomFlip
	Variable row
	
	String oldDF=GetDataFolder(1)
	SetDataFolder root:Packages:WM_3Sliders
	Wave/Z xxx
	Wave/Z yyy0,yyy1,yyy2
	Wave/z XAxisWave
	if(WaveExists(xxx)==0)
		Make/O/N=2 xxx={-inf,inf}										// same x-wave will be used by all.
		Make/O/N=2 yyy0={nan,nan},yyy1={nan,nan},yyy2={nan,nan}		// one wave for each slider.
	endif
	// The first profile----------------------------------------------
	// Get slider positions
	ControlInfo  WM_ZHProfileSlider
	sliderZPosition=V_Value
	NVAR theZLayer=root:Packages:WM_3Sliders:theZLayer
	ControlInfo WMFlipXCheck			// Get directions of display
	leftFlip=V_Value
	ControlInfo wmFlipYCheck
	bottomFlip=V_Value
	SVAR srcWaveName=root:Packages:WM_3Sliders:srcWaveName
	Wave/Z srcWave=$srcWaveName
	if(WaveExists(srcWave)==0)
		Abort  "Source Wave is missing"
		return 0
	endif
	if(leftFlip==0)
		row=round(sliderZPosition*DimSize(srcWave,1)/99)
	else
		row=round((99-sliderZPosition)*DimSize(srcWave,1)/99)
	endif
		
	Wave yyy0=root:Packages:WM_3Sliders:yyy0
	yyy0=DimOffset(srcWave,1)+DimDelta(srcWave,1)*row 
	
	if(row>=DimSize(srcWave,1))		// 08JAN10
		row=DimSize(srcWave,1)-1
	endif
	
	ImageTransform/P=(theZLayer)/G=(row) GetCol srcWave
	Wave/Z W_ExtractedCol
	if(WaveExists(W_ExtractedCol))	// 08JAN10
		if(bottomFlip)
			WaveTransform/O flip W_ExtractedCol
		endif
		Duplicate/O W_ExtractedCol,W_ZPlaneProfile
	endif

	// The Second profile----------------------------------------------
	ControlInfo  WM_YHProfileSlider
	sliderYPosition=V_Value
	NVAR theYLayer=root:Packages:WM_3Sliders:theYLayer
	Wave YAxisWave=root:Packages:WM_3Sliders:YAxisWave
	if(WaveExists(YAxisWave)==0)
		doAlert 0,"Missing main Y-Axis wave."
		return 0
	endif
	ControlInfo WMFlipXCheck1			// Get directions of display
	leftFlip=V_Value
	ControlInfo wmFlipYCheck1
	bottomFlip=V_Value

	if(leftFlip==0)
		row=round(sliderYPosition*DimSize(YAxisWave,1)/99)				// this is the #1 dim of the volume wave 	 
	else	
		row=round((99-sliderYPosition)*DimSize(YAxisWave,1)/99)				 
	endif
	Wave yyy1=root:Packages:WM_3Sliders:yyy1
	yyy1=DimOffset(YAxisWave,1)+DimDelta(YAxisWave,1)*row 
	
	if(row>=DimSize(YAxisWave,1))		// 08JAN10
		row=DimSize(YAxisWave,1)-1
	endif
	ImageTransform/P=(theYLayer)/G=(row) GetCol YAxisWave
	Wave/Z W_ExtractedCol				// 08JAN10
	if(WaveExists(W_ExtractedCol))	// 08JAN10
		if(bottomFlip)
			WaveTransform/O flip W_ExtractedCol
		endif
		Duplicate/O W_ExtractedCol,W_YPlaneProfile
	endif
	// The Third profile----------------------------------------------
	ControlInfo  WM_XHProfileSlider
	sliderXPosition=V_Value
	NVAR theXLayer=root:Packages:WM_3Sliders:theXLayer
	Wave XAxisWave=root:Packages:WM_3Sliders:XAxisWave
	if(WaveExists(XAxisWave)==0)
		doAlert 0,"Missing main X-Axis wave."
		return 0
	endif
	ControlInfo WMFlipXCheck2			// Get directions of display
	leftFlip=V_Value
	ControlInfo wmFlipYCheck2
	bottomFlip=V_Value
	
	if(leftFlip==0)
		row=round(sliderXPosition*DimSize(XAxisWave,1)/99)				// this is the #1 dim of the volume wave 		 
	else
		row=round((99-sliderXPosition)*DimSize(XAxisWave,1)/99)				 
	endif
	Wave yyy2=root:Packages:WM_3Sliders:yyy2
	yyy2=DimOffset(XAxisWave,1)+DimDelta(XAxisWave,1)*row 
	
	if(row>=DimSize(XAxisWave,1))		// 08JAN10
		row=DimSize(XAxisWave,1)-1
	endif

	ImageTransform/P=(theXLayer)/G=(row) GetCol XAxisWave
	Wave/Z W_ExtractedCol
	if(WaveExists(W_ExtractedCol))
		if(bottomFlip)
			WaveTransform/O flip W_ExtractedCol
		endif
		Duplicate/O W_ExtractedCol,W_XPlaneProfile
	endif
	SetDataFolder oldDF
End
//*************************************************************************
Function WMHProfileSliderProc(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved

	if(event %& 0x1)	// bit 0, value set
		WM_UpdateLineProfiles()
	endif

	return 0
End
//*************************************************************************

