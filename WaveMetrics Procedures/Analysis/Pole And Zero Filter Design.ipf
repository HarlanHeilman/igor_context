#pragma rtGlobals=1		// Use modern global access method.
#pragma modulename=WMPoleAndZeroDesign
#pragma IndependentModule=WMFilter
#pragma IgorVersion=6			// requires Igor 6
#pragma version=7			// last revised for Igor 7

// Revisions:
// 10/02/2006 - added Gain log10 option.
// 12/18/2006 - Removed Preset Filters button, set phase to 45 degree increments.
// 12/29/2006 - Set phase to degree-friendly increments, added From target and Sort By controls
// 4/24/2007 - Changes to aid in localization.
// 5/2/2007 - Eliminated the FilterIIR error that sometimes occurred when the Clear All Poles and Zeros button was clicked.
//				The panel subwindows are now not editable.
// 10/11/2007 - version 6.03 Fixed localized menu item so it compiles.
// 3/24/2008 - Resized the right (mouse-click) panel.
// 12/22/2008 - Resized LimitWindowSize to work better on Windows if maximized.

#include <New Polar Graphs>, version>=6 // menus=0	//  version 6 is independent-module compatible.
#include <WaveSelectorWidget>  version >=1.07
#include <SaveRestoreWindowCoords>

// START OF LOCALIZABLE STRINGS [

// Menus
static StrConstant ksPZFilterDesignMenu = "Pole and Zero Filter Design"

// Dialog controls - see WMFilterIIRZerosPolesDesign()
static StrConstant ksPZDialogTitle= "Design Filter using Poles and Zeros"

// Mouse Click Group
static StrConstant ksPZMouseClickGroupTitle="Mouse Click"
static StrConstant ksPZMouseClickNormalTitle="Works Normally"
static StrConstant ksPZMouseClickAddPoleTitle="Adds Pole"
static StrConstant ksPZMouseClickAddZeroTitle="Adds Zero"
static StrConstant ksPZMouseClickRemoveTitle="Removes Pole or Zero"
static StrConstant ksPZMouseClickSelectTitle="Selects Pole or Zero"
static StrConstant ksPZMouseClickLimitRadiusTitle="Max Radius = 1"

// Edit Selected Pole or Zero Group
static StrConstant ksPZEditGroupTitle="Edit Selected Pole/Zero"
static StrConstant ksPZEditPolarTitle="polar"
static StrConstant ksPZEditRectTitle="rectangular"

static StrConstant ksPZEditRealTitle="Real:"
static StrConstant ksPZEditImagTitle="Imag:"

static StrConstant ksPZEditRadiusTitle="Radius:"
static StrConstant ksPZEditAngleDegTitle="Angle deg:"

static StrConstant ksPZEditClearTitle="Clear Poles and Zeros"

// #P0 subwindow ResponseFilter tab control
static StrConstant ksPZResponseFsTitle="fs (Hz)"

static StrConstant ksPZResponseFiltTab0Title="Response"
static StrConstant ksPZResponseFiltTab1Title="Filtered"

// #P0 subwindow Response Tab controls

static StrConstant ksPZResponseShowMagnitudeTitle="Show Magnitude"

// PopupMenu magnitudePop selections
static StrConstant ksMagnitudePopItems=  "dB;dB min -100;dB min -20;Gain;Gain log10;"

static StrConstant ksPZResponseShowPhaseTitle="Show Phase"
static StrConstant ksPZResponseRadiansTitle="radians"
static StrConstant ksPZResponseDegreesTitle="degrees"
static StrConstant ksPZResponsePhaseUnwrapTitle="Unwrap"

static StrConstant ksPZFilteredOutputNameTitle="Output Name"
static StrConstant ksPZFilteredUpdateNowTitle="Update Output Now"
static StrConstant ksPZFilteredAutoUpdateTitle="Auto-update Output"

// #PLEFT subwindow
static StrConstant ksPZDesignTitle="Edit Poles/Zeros Wave"
static StrConstant ksPZDesignFromTargetTitle="From target"
static StrConstant ksPZDesignSortByTitle="Sort By"
static StrConstant ksPZDesignNewEmptyFilterTitle="New Empty Filter..."

// #P1 subwindow
static StrConstant ksPZInputToFilterTitle="Input to Filter"

// Legend strings
static StrConstant ksPZLegendPoles="Poles"
static StrConstant ksPZLegendZeros="Zeros"

// Error messages

// See ZerosPolesNotificationProc()
static StrConstant ksPZErrNotValidZPWave="Not a valid Zeros & Poles wave; expected a two-column complex single or double precision wave with matching conjugate values."

// See UpdateFilteredOutput()
static StrConstant ksPZErrEnterOutputName="Enter Output Name to show filtered results"
static StrConstant ksPZErrSelectInputToFilter="Select Input to Filter"
static StrConstant ksPZErrUpdaeNowToFiltUpdate= "Click Update Output Now to show filtered results"
static StrConstant ksPZErrSelectInputToFiltUpdate="Select Input to Filter and click Update Output Now"

// See ClearButtonProc
static StrConstant ksPZErrClearAllPZ="Clear All Poles and Zeros?"

// See NewWaveButtonProc
static StrConstant ksPZPromptNewZPName="New zeros/poles wave"
static StrConstant ksPZErrOverwriteExistingWaveFmt="Overwrite existing %s?"	// %s is name of wave

// See UpdateFilterOutputNowButtonProc()
static StrConstant ksPZErrSelectInputFromList="Select an Input to Filter from the list on the left."

// END OF LOCALIZABLE STRINGS ]

Function/S PZFilterDesignMenu()
	return ksPZFilterDesignMenu
End

Menu "Analysis"
	//"Pole and Zero Filter Design", /Q, 	WMFilterIIRZerosPolesDesign(1, $"")
	WMFilter#PZFilterDesignMenu(), /Q, 	WMFilterIIRZerosPolesDesign(1, $"")
End

#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility with Igor 7
	String wName
	return 72
End
#endif

static StrConstant ksGraphName= "DesignFilterZerosPoles"
static StrConstant ksLeftPanelName= "DesignFilterZerosPoles#PLEFT"
static StrConstant ksRightPanelName= "DesignFilterZerosPoles#PRIGHT"
static StrConstant ksResponsePanelName= "DesignFilterZerosPoles#P0"
static StrConstant ksFilterInputPanelName= "DesignFilterZerosPoles#P1"
static StrConstant ksResponseGraphName= "DesignFilterZerosPoles#PBottom#G0"

StrConstant ksPRIGHTcontrols="mouseClickGroup;clickRadioNormal;clickRadioAddPole;clickRadioAddZero; clickRadioRemove;clickRadioSelect;limitRadius;editGroup;editPolar;editRectangular;zpx;zpy;zpr;zpa;clear;"

Function/S WMFilterIIRZerosPolesDesign( fs, zerosAndPoles)
	Variable fs					// samping frequency, use 1 for normalized filter design
	Wave/C/D/Z zerosAndPoles	// zeros in column 0, poles in column 1, can be NULL at startup
	
	String dfSave= GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O/S root:Packages:WM_ZerosPolesDesign
	
	if( !WaveExists(zerosAndPoles) )
		// default to a 2nd order lowpass filter at fc = 1/2 the Nyquist frequency
		Make/O/C/D/N=0 zerosAndPoles
		FilterIIR/LO=0.25/ORD=2/COEF/ZP zerosAndPoles
	endif
	
	String/G pathToZerosAndPoles= GetWavesDataFolder(zerosAndPoles,2)
	Variable/G iir_polar_fs= fs
	
	// create waves to display poles and zeros
	Variable nRows= DimSize(zerosAndPoles,0)	// must be at least one in order to keep the polar graph stuff happy.
	Make/O/N=(nRows) zerosRadii= real(r2polar(zerosAndPoles[p][0]))
	Make/O/N=(nRows) zerosAngles=imag(r2polar(zerosAndPoles[p][0]))
	Make/O/N=(nRows) polesRadii= real(r2polar(zerosAndPoles[p][1]))
	Make/O/N=(nRows) polesAngles=imag(r2polar(zerosAndPoles[p][1]))
	
	String polesTraceName,  zerosTraceName
	String polesAndZerosGraphName= ksGraphName	// proposed name
	DoWindow/F $polesAndZerosGraphName
	if( V_Flag == 0 )
		WMPolarGraphGlobalsInit()
		// initially position WMIIRPolesAndZeros using WC_WindowCoordinatesSetNums
		// as if AutopositionWindow/E/M=0/R=WMAnalogDesign
		Variable vLeft=10, vTop=45, vRight=460, vBottom=445 // points
//		WC_WindowCoordinatesGetNums(polesAndZerosGraphName, vLeft, vTop, vRight, vBottom)
		String cmd
		sprintf cmd, "Display/K=1/N=%s/W=(%%s) as \"%s\"", polesAndZerosGraphName, ksPZDialogTitle	// ksPZDialogTitle=  "Design Filter using Poles and Zeros"
		cmd= WC_WindowCoordinatesSprintf(polesAndZerosGraphName,cmd,vLeft, vTop, vRight, vBottom,0)	// points
		Execute cmd

		polesAndZerosGraphName=WMNewPolarGraph("_default_",polesAndZerosGraphName)

		ControlBar/R 164	// PRIGHT
		ControlBar/B 145
		ControlBar/L 170	// should make this a movable divider.

		// ksGraphName+"#PRIGHT"
		DefineGuide UGV0={GR,26}
		NewPanel/W=(0.823,0.2,0.98,0.576)/FG=(GR,GT,FR,GB)/HOST=# 
		ModifyPanel frameStyle=0, frameInset=0

		// Mouse Click group
		GroupBox mouseClickGroup,pos={7,20},size={151,138},title=ksPZMouseClickGroupTitle	// "Mouse Click"
		CheckBox clickRadioNormal,pos={17,40},size={90,14},proc=WMPoleAndZeroDesign#ClickRadioProc,title=ksPZMouseClickNormalTitle	// "Works Normally"
		CheckBox clickRadioNormal,value= 1,mode=1
		CheckBox clickRadioAddPole,pos={17,58},size={62,14},proc=WMPoleAndZeroDesign#ClickRadioProc,title=ksPZMouseClickAddPoleTitle	// "Adds Pole"
		CheckBox clickRadioAddPole,value= 0,mode=1
		CheckBox clickRadioAddZero,pos={17,76},size={63,14},proc=WMPoleAndZeroDesign#ClickRadioProc,title=ksPZMouseClickAddZeroTitle	// "Adds Zero"
		CheckBox clickRadioAddZero,value= 0,mode=1
		CheckBox clickRadioRemove,pos={17,113},size={116,14},proc=WMPoleAndZeroDesign#ClickRadioProc,title=ksPZMouseClickRemoveTitle	// "Removes Pole or Zero"
		CheckBox clickRadioRemove,value= 0,mode=1
		CheckBox clickRadioSelect,pos={17,94},size={109,14},proc=WMPoleAndZeroDesign#ClickRadioProc,title=ksPZMouseClickSelectTitle	// "Selects Pole or Zero"
		CheckBox clickRadioSelect,value= 0,mode=1
		CheckBox limitRadius,pos={38,135},size={87,14},disable=1,title=ksPZMouseClickLimitRadiusTitle	// "Max Radius = 1"
		CheckBox limitRadius,value= 1

		// Edit Selected Pole or Zero Group
		GroupBox editGroup,pos={7,168},size={151,84},title=ksPZEditGroupTitle	// "Edit Selected Pole/Zero"
		CheckBox editPolar,pos={19,190},size={41,14},disable=2,proc=WMPoleAndZeroDesign#EditCoordinatesRadioProc,title=ksPZEditPolarTitle	// "polar"
		CheckBox editPolar,value= 1,mode=1
		CheckBox editRectangular,pos={66,190},size={70,14},disable=2,proc=WMPoleAndZeroDesign#EditCoordinatesRadioProc,title=ksPZEditRectTitle	// "rectangular"
		CheckBox editRectangular,value= 0,mode=1
	
		// x and y are initially hidden
		Variable/G zpx, zpy
		SetVariable zpx,pos={37,211},size={103,15},disable=1,proc=WMPoleAndZeroDesign#EditZpxySetVarProc,title=ksPZEditRealTitle	// "Real:"
		SetVariable zpx,limits={-1.1,1.1,0.01},value= root:Packages:WM_ZerosPolesDesign:zpx,bodyWidth= 80
		SetVariable zpy,pos={35,230},size={105,15},disable=1,proc=WMPoleAndZeroDesign#EditZpxySetVarProc,title=ksPZEditImagTitle	// "Imag:"
		SetVariable zpy,limits={-1.1,1.1,0.01},value= root:Packages:WM_ZerosPolesDesign:zpy,bodyWidth= 80
		ModifyControlList "zpx;zpy;" disable= 1
	
		// r and z are initially shown but disabled.
		Variable/G zpr, zpa
		SetVariable zpr,pos={30,211},size={115,15},disable=2,proc=WMPoleAndZeroDesign#EditZpraSetVarProc,title=ksPZEditRadiusTitle	// "Radius:"
		SetVariable zpr,format="                               %g",frame=0
		SetVariable zpr,limits={0,1.1,0.01},value= root:Packages:WM_ZerosPolesDesign:zpr,bodyWidth= 80
		SetVariable zpa,pos={14,230},size={131,15},disable=2,proc=WMPoleAndZeroDesign#EditZpraSetVarProc,title=ksPZEditAngleDegTitle	// "Angle deg:"
		SetVariable zpa,format="                               %g",frame=0
		SetVariable zpa,limits={-180,180,1},value= root:Packages:WM_ZerosPolesDesign:zpa //bodyWidth= 80 (too wide on Windows)
		ModifyControlList "zpr;zpa;" disable= 2

		Button clear,pos={6,278},size={153,20},proc=WMPoleAndZeroDesign#ClearButtonProc,title=ksPZEditClearTitle	// "Clear Poles and Zeros"
		
		RenameWindow #,PRIGHT
		SetActiveSubwindow ##

		// The selected pole or zero is indicated by index into the zero/pole wave. -1 means no selection, 0 is first zero, 1 is first pole, etc.
		ClearSelectedZeroOrPole()	// Variable/G selectedZeroOrPole=-1, enables/disables controls in DesignFilterZerosPoles#PRIGHT

		// Add bottom panel and graph
		// ksGraphName+"#PBottom#G0" is updated by UpdateResponse()
		Make/O/N=2 magnitude, phase
		NewPanel/W=(0.2,0.2,0.8,0.8)/FG=(GL,GB,GR,FB)/HOST=# 
		ModifyPanel frameStyle=0, frameInset=1
		Display/W=(173,31,520,96)/FG=(FL,FT,FR,FB)/HOST=#  magnitude
		AppendToGraph/R phase
		ModifyGraph rgb(phase)=(0,0,65535), minor(bottom)=1
		ModifyGraph manTick(right)={0,45,0,0},manMinor(right)={2,0}
		Legend/C/N=ResponseLegend/X=0.00/Y=0.00
		ModifyGraph frameStyle=1

		RenameWindow #,G0
		SetActiveSubwindow ##
		RenameWindow #,PBottom
		SetActiveSubwindow ##
		
		// Add bottom right panel for fs and magnitude and phase controls. See UpdateResponse() and UpdateFs()
		// ksGraphName+"#P0"
		NewPanel/W=(0.2,0.2,0.8,0.956)/FG=(GR,GB,FR,FB)/HOST=# 
		ModifyPanel frameStyle=0
		DefaultGUIFont/Mac popup={"_IgorSmall",0,0}
		DrawLine 0,0,163,0

		SetVariable fs,pos={10,9},size={135,15},proc=WMPoleAndZeroDesign#FsSetVarProc,title=ksPZResponseFsTitle	// "fs (Hz)"
		SetVariable fs,limits={-inf,inf,0},value= root:Packages:WM_ZerosPolesDesign:iir_polar_fs
	
		TabControl ResponseFiltered,pos={4,32},size={155,109},fSize=10,tabLabel(0)=ksPZResponseFiltTab0Title	// "Response"
		TabControl ResponseFiltered,value= 0, proc=WMPoleAndZeroDesign#ResponseTabProc,tabLabel(1)=ksPZResponseFiltTab1Title	// "Filtered"
		
		// Response tab controls
		CheckBox showMagnitude,pos={9,55},size={90,14},proc=WMPoleAndZeroDesign#ShowMagnitudeCheckProc,title=ksPZResponseShowMagnitudeTitle	// "Show Magnitude"
		CheckBox showMagnitude,value= 1

		PopupMenu magnitudePop,pos={52,74},size={42,20},proc=WMPoleAndZeroDesign#MagnitudePopMenuProc
		String popvalue= StringFromList(0, ksMagnitudePopItems)	// first item
		String popFunc= GetIndependentModuleName()+"#WMPoleAndZeroDesign#MagnitudePopList()"
		PopupMenu magnitudePop,mode=1,popvalue=popvalue,value= #popFunc	// requires Igor 6 12/6/06 to work

		CheckBox showPhase,pos={9,99},size={71,14},proc=WMPoleAndZeroDesign#ShowPhaseCheckProc,title=ksPZResponseShowPhaseTitle	// "Show Phase"
		CheckBox showPhase,value= 1
		CheckBox phaseRadians,pos={90,118},size={51,14},proc=WMPoleAndZeroDesign#RadiansDegreesCheckProc,title=ksPZResponseRadiansTitle	// "radians"
		CheckBox phaseRadians,value= 0,mode=1
		CheckBox phaseDegrees,pos={30,118},size={53,14},proc=WMPoleAndZeroDesign#RadiansDegreesCheckProc,title=ksPZResponseDegreesTitle	// "degrees"
		CheckBox phaseDegrees,value= 1,mode=1
		CheckBox phaseUnwrap,pos={88,99},size={52,14},proc=WMPoleAndZeroDesign#UnwrapCheckProc,title=ksPZResponsePhaseUnwrapTitle	// "Unwrap"
		CheckBox phaseUnwrap,value= 1
		
		// Filtered tab controls (hidden)
		String/G filteredOutputName= StrVarOrDefault("root:Packages:WM_ZerosPolesDesign:filteredOutputName", "filtered")
		SetVariable filteredOutputName,pos={7,56},size={140,15},proc=WMPoleAndZeroDesign#FilteredOutputNameSetVarProc,title=ksPZFilteredOutputNameTitle	// "Output Name"
		SetVariable filteredOutputName,value= root:Packages:WM_ZerosPolesDesign:filteredOutputName, disable=1
		Button updateNow,pos={9,101},size={135,20},proc=WMPoleAndZeroDesign#UpdateFilterOutputNowButtonProc, disable=1,title=ksPZFilteredUpdateNowTitle	// "Update Output Now"
		CheckBox autoUpdateFilteredOutput,pos={12,78},size={105,14},proc=WMPoleAndZeroDesign#AutoUpdateFilteredOutCheckProc,title=ksPZFilteredAutoUpdateTitle	// "Auto-update Output"
		CheckBox autoUpdateFilteredOutput,value= 0, disable=1
	
		RenameWindow #,P0
		SetActiveSubwindow ##

		// ksGraphName+"#PLEFT
		NewPanel/W=(0.051,0.2,0.22,0.8)/FG=(FL,FT,GL,GB)/HOST=# 
		ModifyPanel frameStyle=0, frameInset=0
		TitleBox designTitle,pos={34,11},size={102,12},title=ksPZDesignTitle	// "Edit Poles/Zeros Wave"
		TitleBox designTitle,frame=0
		ListBox poleZeroWavesList,pos={4,28},size={160,168}
		
		Variable/G fromTarget
		CheckBox fromTarget,pos={4,204},size={72,14},proc=WMPoleAndZeroDesign#FromTargetCheckProc,title=ksPZDesignFromTargetTitle	// "From target"
		CheckBox fromTarget,variable=root:Packages:WM_ZerosPolesDesign:fromTarget

		PopupMenu sort,pos={87,202},size={62,17},title=ksPZDesignSortByTitle	// "Sort By"
		
		Button new,pos={15,227},size={140,20},proc=WMPoleAndZeroDesign#NewWaveButtonProc,title=ksPZDesignNewEmptyFilterTitle	// "New Empty Filter..."

		RenameWindow #,PLEFT
		SetActiveSubwindow ##

		// set up the pole/zero coefs wave selector
		String pwin=ksLeftPanelName
		String options= "DIMS:2,MINCOLS:2,TEXT:0,INTEGER:0,WORD:0,BYTE:0,CMPLX:1"	// regrettably, not limited to valid coefs waves.
		MakeListIntoWaveSelector(pwin, "poleZeroWavesList", selectionMode=WMWS_SelectionSingle, listoptions=options,nameFilterProc="WMPoleAndZeroDesign#ApproveCoefsWave")
		WS_SetNotificationProc(pwin, "poleZeroWavesList", "WMPoleAndZeroDesign#ZerosPolesNotificationProc")

		MakePopupIntoWaveSelectorSort(pwin, "poleZeroWavesList", "sort", popupcontrolwindow= ksLeftPanelName)

		// ksGraphName+"#P1"
		NewPanel/W=(0.2,0.2,0.8,0.965)/FG=(FL,GB,GL,FB)/HOST=# 
		ModifyPanel frameStyle=0, frameInset=0
		DrawLine 0,0,171,0

		TitleBox filterThisTitle,pos={52,6},size={62,12},frame=0,title=ksPZInputToFilterTitle	// "Input to Filter"
		ListBox filterThisWave,pos={5,22},size={160,121}

		RenameWindow #,P1
		SetActiveSubwindow ##

		pwin=ksFilterInputPanelName
		options= "DIMS:1,TEXT:0"	// See WaveList options documentation
		MakeListIntoWaveSelector(pwin, "filterThisWave", selectionMode=WMWS_SelectionSingle, listoptions=options,nameFilterProc="WMPoleAndZeroDesign#ApproveWaveToFilter")
		WS_SetNotificationProc(pwin, "filterThisWave", "WMPoleAndZeroDesign#InputToFilterNotificationProc")

		MakePopupIntoWaveSelectorSort(pwin, "filterThisWave", "sort", popupcontrolwindow= ksLeftPanelName)

		Variable sortKind= NumVarOrDefault("root:Packages:WM_ZerosPolesDesign:sortKind",0)
		Variable sortReverse= NumVarOrDefault("root:Packages:WM_ZerosPolesDesign:sortReverse",0)
		WS_SetGetSortOrder(ksLeftPanelName, "sort", sortKind, sortReverse)

		// change some polar axes settings
		WMPolarGraphSetStr(polesAndZerosGraphName,"radiusAxesWhere","  0")
		WMPolarGraphSetVar(polesAndZerosGraphName,"radiusTickLabelOmitOrigin",1)
		WMPolarGraphSetVar(polesAndZerosGraphName,"tickLabelOpaque", 0)
		WMPolarGraphSetVar(polesAndZerosGraphName,"radiusApproxTicks",2)
		WMPolarGraphSetVar(polesAndZerosGraphName,"doMinorRadiusTicks",1)
		WMPolarGraphSetVar(polesAndZerosGraphName,"doMinGridSpacing", 0)
		
		// Scale the angle into frequency
		WMPolarGraphSetStr(polesAndZerosGraphName,"angleTickLabelUnits", "degrees")
		WMPolarGraphSetStr(polesAndZerosGraphName,"angleTickLabelNotation", "%g Hz")
		WMPolarGraphSetStr(polesAndZerosGraphName,"angleTickLabelSigns", " no signs")
		WMPolarGraphSetVar(polesAndZerosGraphName,"angleTickLabelScale", fs/2/180)
		WMPolarGraphSetVar(polesAndZerosGraphName,"angle0", -135)
		
		// use light gray for the axes
		Variable grey=48000	// 25%
		WMPolarGraphSetVar(polesAndZerosGraphName,"radiusAxisColorRed",grey)
		WMPolarGraphSetVar(polesAndZerosGraphName,"radiusAxisColorGreen",grey)
		WMPolarGraphSetVar(polesAndZerosGraphName,"radiusAxisColorBlue",grey)

		WMPolarGraphSetVar(polesAndZerosGraphName,"angleAxisColorRed",grey)
		WMPolarGraphSetVar(polesAndZerosGraphName,"angleAxisColorGreen",grey)
		WMPolarGraphSetVar(polesAndZerosGraphName,"angleAxisColorBlue",grey)

		WMPolarGraphSetVar(polesAndZerosGraphName,"majorGridColorRed",grey)
		WMPolarGraphSetVar(polesAndZerosGraphName,"majorGridColorGreen",grey)
		WMPolarGraphSetVar(polesAndZerosGraphName,"majorGridColorBlue",grey)

		WMPolarGraphSetVar(polesAndZerosGraphName,"minorGridColorRed",grey)
		WMPolarGraphSetVar(polesAndZerosGraphName,"minorGridColorGreen",grey)
		WMPolarGraphSetVar(polesAndZerosGraphName,"minorGridColorBlue",grey)

		polesTraceName= WMPolarAppendTrace(polesAndZerosGraphName,polesRadii, polesAngles, 2*pi)	// angles are in radians
		zerosTraceName= WMPolarAppendTrace(polesAndZerosGraphName,zerosRadii, zerosAngles, 2*pi)
		ModifyGraph/W=$polesAndZerosGraphName mode($polesTraceName)=3,marker($polesTraceName)=1
		ModifyGraph/W=$polesAndZerosGraphName mode($zerosTraceName)=3,marker($zerosTraceName)=8, rgb($zerosTraceName)=(0,0,65280)
		
		// redraw
		WMPolarAxesRedrawGraphNow(polesAndZerosGraphName)
	elseif( strlen(polesAndZerosGraphName) )
		//DoWindow/F $polesAndZerosGraphName
		polesTraceName= WMPolarTraceNameForRadiusData(polesAndZerosGraphName,polesRadii)
		zerosTraceName= WMPolarTraceNameForRadiusData(polesAndZerosGraphName,zerosRadii)
		// optionally, rescale the angle into frequency
		Variable oldfs= NumVarOrDefault("root:Packages:WM_ZerosPolesDesign:iir_polar_fs", fs)
		if( fs != oldfs )
			WMPolarGraphSetVar(polesAndZerosGraphName,"angleTickLabelScale", fs/2/180)
			WMPolarAxesRedrawGraphNow(polesAndZerosGraphName)	// redraw
			Variable/G root:Packages:WM_ZerosPolesDesign:iir_polar_fs= fs
		endif
		WS_ClearSelection(ksLeftPanelName, "poleZeroWavesList")
	endif

	RepositionControlsInPLEFT()
	RepositionControlsInPRIGHT()
	
	WS_SelectAnObject(ksLeftPanelName, "poleZeroWavesList", pathToZerosAndPoles, OpenFoldersAsNeeded=1)

	// identify multiple zeros and/or poles using zmrkSize
	// X's don't really work for overlapping poles
	PZMarkerSizesForRadiiAngles(zerosRadii,zerosAngles,"zerosMrkSize")
	Wave zerosMrkSize
	ModifyGraph/W=$polesAndZerosGraphName zmrkSize($zerosTraceName)={zerosMrkSize,1,10,1,10}

	String str=  "\\s("+polesTraceName+") "+ksPZLegendPoles	// +"Poles"
	str += "\r\\s("+zerosTraceName+") "+ksPZLegendZeros	// +"Zeros"
	Legend/W=$polesAndZerosGraphName/C/N=polesLegend/J str

	SetDataFolder dfSave
	UpdateResponse(1)
	EnableDisablePZGraphHook(1)
	return polesAndZerosGraphName
End

static Function EnableDisablePZGraphHook(enable)
	Variable enable
	
	GetWindow $ksGraphName hook
	Variable wasEnabled= strlen(S_Value) > 0
	if( enable )
		SetWindow $ksGraphName hook=WMPoleAndZeroDesign#WMDesignPolesAndZerosHook, hookEvents=3
	else
		SetWindow $ksGraphName hook=$""
	endif
	return wasEnabled
End

static Function FromTargetCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			WS_UpdateWaveSelectorWidget(ksLeftPanelName, "poleZeroWavesList")
			WS_UpdateWaveSelectorWidget(ksFilterInputPanelName, "filterThisWave")
			break
	endswitch

	return 0
End

static Function WaveDisplayedInTarget(w)
	Wave w
	
	String target= WinName(0,1+2,1)	// topmost visible graph or table
	if( CmpStr(target,"DesignFilterZerosPoles") == 0 )
		target= WinName(1,1+2,1)	// next most visible graph or table
	endif
	CheckDisplayed/W=$target  w
	return V_Flag 
End


static Function/S ZerosPolesWavePath()
	String path= StrVarOrDefault("root:Packages:WM_ZerosPolesDesign:pathToZerosAndPoles","")
	return path
End

static Function/C MouseXYtoRadiusAngle(mousex,mousey)
	Variable mousex,mousey

	Variable xx= AxisValFromPixel(ksGraphName, "HorizCrossing", mousex )
	Variable yy= AxisValFromPixel(ksGraphName, "VertCrossing", mousey )

	Variable drawnRadius= sqrt(xx*xx+yy*yy)
	Variable drawnAngle= atan2(yy,xx)	// radians
	
	// PolarRadiusFunctionInv transforms drawn radius to data radius
	Variable valueAtCenter= WMPolarGraphGetVar(ksGraphName,"valueAtCenter")
	String radiusFunction= WMPolarGraphGetStr(ksGraphName,"radiusFunction")
	Variable dataRadius= WMPolarRadiusFunctionInv(drawnRadius,radiusFunction,valueAtCenter)

	// PolarAngleFunctionInv transforms from drawn angle in radians to data angle
	Variable zeroAngleWhere= WMPolarGraphGetVar(ksGraphName,"zeroAngleWhere")
	Variable angleDirection= WMPolarGraphGetVar(ksGraphName,"angleDirection")
	Variable dataAngleRadians= WMPolarAngleFunctionInv(drawnAngle,zeroAngleWhere,angleDirection,2*PI)	// Radians

	Variable/C result= cmplx(dataRadius,dataAngleRadians)
	return result
End

static Function SnapToRightAngles(angle)// radians
	Variable angle
	
	Variable eps= 0.9*pi/180	// 0.9 degree
	
	if( abs(angle-pi) < eps )
		angle= pi
	elseif( abs(angle-(pi/2) ) < eps )
		angle= pi/2
	elseif( abs(angle) < eps )
		angle= 0
	elseif( abs(angle-(-pi/2)) < eps )
		angle= -pi/2
	elseif( abs(angle-(-pi)) < eps )
		angle= -pi
	endif
	
	return angle
End

Function MouseXYtoPoleZeroXY(mouseX, mouseY, maxRadius, pzX, pzY)
	Variable mouseX, mouseY, maxRadius	// inputs
	Variable &pzX, &pzY

	Variable/C radiusAngle= MouseXYtoRadiusAngle(mouseX, mouseY)
	Variable radius= real(radiusAngle)
	Variable angle=  imag(radiusAngle)
	if( radius > maxRadius )
		radius= maxRadius
	endif
	// clip to important angles
	angle= SnapToRightAngles(angle)	// radians
	// clip tiny values to 0
	Variable tiny= 0.01
	pzX= radius*cos(angle)
	if( abs(pzX) < tiny )
		pzX= 0
	endif
	pzY= radius*sin(angle)
	if( abs(pzY) < tiny )
		pzY= 0
	endif
End

static Function AddPoleAtXY(mousex,mousey,maxRadius)
	Variable mousex,mousey,maxRadius

	Wave/C/Z zerosPoles= $ZerosPolesWavePath()

	if( WaveExists(zerosPoles) )
		Variable xval, yval	// outputs of MouseXYtoPoleZeroXY()
		MouseXYtoPoleZeroXY(mouseX, mouseY, maxRadius, xval, yval)

		Variable needsConjugate= yval !=0
		Variable numRows= DimSize(zerosPoles,0)
		InsertPoints numRows, 1+needsConjugate, zerosPoles	// appends zeros to both columns
		zerosPoles[numRows][1] = cmplx(xval,yval)	// poles in column 1
		if( needsConjugate )
			zerosPoles[numRows+1][1] = cmplx(xval,-yval)
		endif

		UpdateZerosPolesDesign(1)	// sort because we've changed the number of poles and zeros.
		SetSelectedZeroOrPoleByValue(cmplx(xval,yval), 1)
		DoUpdate						// IndicateSelectedZeroOrPole reads drawnX and drawnY from polar graph...
		IndicateSelectedZeroOrPole()	// so we do this after the polar graph has updated.
	endif
End

static Function AddZeroAtXY(mousex,mousey,maxRadius)
	Variable mousex,mousey,maxRadius

	Wave/C/Z zerosPoles= $ZerosPolesWavePath()

	if( WaveExists(zerosPoles) )
		Variable xval, yval	// outputs of MouseXYtoPoleZeroXY()
		MouseXYtoPoleZeroXY(mouseX, mouseY, maxRadius, xval, yval)

		Variable needsConjugate= yval !=0
		Variable numRows= DimSize(zerosPoles,0)
		InsertPoints numRows, 1+needsConjugate, zerosPoles	// appends zeros to both columns
		zerosPoles[numRows][0] = cmplx(xval,yval)	// zeros in column 0
		if( needsConjugate )
			zerosPoles[numRows+1][0] = cmplx(xval,-yval)
		endif

		UpdateZerosPolesDesign(1)	// sort because we've changed the number of poles and zeros.
		SetSelectedZeroOrPoleByValue(cmplx(xval,yval), 0)
		DoUpdate						// IndicateSelectedZeroOrPole reads drawnX and drawnY from polar graph...
		IndicateSelectedZeroOrPole()	// so we do this after the polar graph has updated.
	endif
End

static Function AreConjugatePair(c1,c2)
	Variable/C c1,c2

	Variable eps= max(1e-6,max(cabs(c1),cabs(c2)) * 1e-6)

	Variable closeReal= abs(real(c1) - real(c2)) < eps
	Variable closeImag= abs(imag(c1) + imag(c2)) < eps
	Variable isConjugatePair= closeReal && closeImag
	return isConjugatePair
End

static Function CmplxAreSame(c1,c2)
	Variable/C c1,c2

	Variable eps= max(1e-6,max(cabs(c1),cabs(c2)) * 1e-6)

	Variable closeReal= abs(real(c1) - real(c2)) < eps
	Variable closeImag= abs(imag(c1) - imag(c2)) < eps
	Variable areSame= closeReal && closeImag
	return areSame
End


static Function RemoveZeroOrPole(zp, isZero)
	Variable/C zp
	Variable isZero

	Wave/C/Z zerosPoles= $ZerosPolesWavePath()

	if( !WaveExists(zerosPoles) )
		return 0
	endif
	
	Variable zpCol = isZero ? 0 : 1
	// find the zero or pole
	Variable rows= DimSize(zerosPoles,0)
	Variable/C zp2
	Variable i, matchingRow= -1
	for( i=0; i<rows;i+=1 )
		zp2= zerosPoles[i][zpCol]
		if( CmplxAreSame(zp, zp2) )
			matchingRow = i
			break
		endif
	endfor
	if( matchingRow == -1 )
		return 0	// not found
	endif	

	Variable selectedRow, selectedIsPole
	String pathToZeroPole= GetSelectedZeroOrPole(selectedRow, selectedIsPole)
	Variable wasSelected= strlen(pathToZeroPole) && selectedRow >= 0 && (selectedRow == matchingRow) && (selectedIsPole != isZero ) 
		
	zerosPoles[matchingRow][zpCol]= cmplx(0,0)	// erase by setting zero or pole to (0,0)
	if( imag(zp) != 0 )
		// remove the conjugate, too
		for( i=0; i<rows;i+=1 )
			if( i == matchingRow )
				continue
			endif
			zp2= zerosPoles[i][zpCol]
			if ( AreConjugatePair(zp,zp2) )
				zerosPoles[i][zpCol]= cmplx(0,0)	// erase by setting zero or pole to (0,0)
				break
			endif
		endfor
	endif

	if( wasSelected )
		ClearSelectedZeroOrPole()
	endif

	UpdateZerosPolesDesign(1)	
	return 1	// found and removed.
End	

static Function SetSelectedZeroOrPoleByValue(poleOrZero, isPole)
	Variable/C poleOrZero
	Variable isPole
	
	Variable rowIndex= -1	// not found in zerosPoles wave
	Wave/C/Z zerosPoles= $ZerosPolesWavePath()
	if( WaveExists(zerosPoles) )
		Variable i, nRows= DimSize(zerosPoles,0)	// must be at least one in order to keep the polar graph stuff happy.
		for(i=0; i<nRows;i+=1)
			if(  cequal(zerosPoles[i][isPole],poleOrZero) )
				SetSelectedZeroOrPole(i, isPole)
				rowIndex= i
				break
			endif
		endfor
	endif
	if( rowIndex < 0 )
		ClearSelectedZeroOrPole()	// must have deleted the  selected zero or pole.
	endif
	
	return rowIndex
End

static Function SetSelectedZeroOrPole(rowIndex, isPole)
	Variable rowIndex, isPole
	
	//	selectedZeroOrPole is an index as if the zero/pole wave were a 1-d real-valued wave:
	//	
	//	-1 = no selection
	//	0 = first zero
	//	1 = first pole
	//	2= second zero
	//	etc
	//	
	Variable/G root:Packages:WM_ZerosPolesDesign:selectedZeroOrPole= rowIndex * 2 + ((isPole) ? 1 : 0)
	EnableZeroOrPoleEditControls()
	IndicateSelectedZeroOrPole()
End

static Function ClearSelectedZeroOrPole()
	
	Variable/G root:Packages:WM_ZerosPolesDesign:selectedZeroOrPole= -1
	EnableZeroOrPoleEditControls()
	IndicateSelectedZeroOrPole()
End

// Returns path to zero/pole wave, or "" if no selection
static Function/S GetSelectedZeroOrPole(rowIndex, isPole)
	Variable &rowIndex 	// output
	Variable &isPole	// output
	
	String pathToWave= ZerosPolesWavePath()
	Wave/C/Z poleZero= $pathToWave
	if( !WaveExists(poleZero) )
		rowIndex= -1
		isPole= 0
		return ""
	endif
	Variable selectedZeroOrPole= NumVarOrDefault("root:Packages:WM_ZerosPolesDesign:selectedZeroOrPole",-1)
	if( selectedZeroOrPole < 0 )	// no selection
		rowIndex= -1
		isPole= 0
		pathToWave= ""
	else
		rowIndex= floor(selectedZeroOrPole/2)
		isPole= mod(selectedZeroOrPole,2)
	endif
	return pathToWave
End

// returns truth that w was accepted as the new zeros and poles wave
static Function ChangeZerosPolesWave(w, selectInBrowser)
	Wave/C w
	Variable selectInBrowser
	
	if( !ValidIIRCoefsWave(w) )
		return 0
	endif

	String dfSave= GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O/S root:Packages:WM_ZerosPolesDesign
	String pathToWave= GetWavesDataFolder(w,2)
	String/G pathToZerosAndPoles= pathToWave
	ClearSelectedZeroOrPole()
	SetDataFolder dfSave
	
	if( selectInBrowser )
		WS_ClearSelection(ksLeftPanelName, "poleZeroWavesList")
		WS_SelectAnObject(ksLeftPanelName, "poleZeroWavesList", pathToWave, OpenFoldersAsNeeded=1)
	endif

	UpdateZerosPolesDesign(1)				
	return 1
End

static Function ValidIIRCoefsWave(zpw)
	Wave/C/Z zpw
	
	if( WaveExists(zpw) )
		FilterIIR/COEF=zpw/ZP/Z	// errs if zpw isn't valid wave: need /Z option and set V_Flag to error code.
		if( V_Flag )
			return 0	// not valid
		endif
		return 1	// valid
	endif
	return 0	// not valid
End

// we already know that the wave is float or double, complex, with at least two columns
static Function ApproveCoefsWave(theNameWithPath, ListContents)
	String theNameWithPath
	Variable ListContents
	
	Wave/Z coefs= $theNameWithPath
	if( !WaveExists(coefs))
		return 0
	endif

	ControlInfo/W=$ksLeftPanelName fromTarget
	if( V_Value )
		if( ! WaveDisplayedInTarget(coefs) )
			return 0
		endif
	endif

	Variable columns= DimSize(coefs,1)
	if( columns == 2 )
		// use FilterIIR to check the format for conjugate pairs
		FilterIIR/ZP/Z/COEF=coefs	// no filtering is done, we're only checking V_Flag
		return V_Flag == 0 ? 1 : 0
	endif
	return 0
end

static Function ApproveWaveToFilter(theNameWithPath, ListContents)
	String theNameWithPath
	Variable ListContents
	
	Wave/Z w= $theNameWithPath
	Variable isOK= WaveExists(w)
	if( isOK )
		ControlInfo/W=$ksLeftPanelName fromTarget
		if( V_Value )
			isOK = WaveDisplayedInTarget(w)
		endif
	endif
	return isOK
end


static Function ZerosPolesNotificationProc(SelectedItem, EventCode)
	String SelectedItem		// string with full path to the item clicked on in the wave selector
	Variable EventCode		// the ListBox event code that triggered this notification

	switch( EventCode )
		case WMWS_DoubleClick:
			Wave/Z/C w = $SelectedItem
			if( WaveExists(w) )
// TO DO: Use ReplaceWave instead of always regenerating the table
				DoWindow/K ZerosPolesTable
				Edit/N=ZerosPolesTable/K=1 w
				AutoPositionWindow/E/R=$ksGraphName ZerosPolesTable
			endif
			break
		case WMWS_SelectionChanged:
			Wave/Z/C w = $SelectedItem
			if( WaveExists(w) && ValidIIRCoefsWave(w))
				ChangeZerosPolesWave(w, 0)
			else
				Variable oldEnable= EnableDisablePZGraphHook(0)	// disable the activate hook, because when DoPrompt closes the dialog, the activate hook attempts to use the zerosPoles wave while it is being modified!
				DoAlert 0, ksPZErrNotValidZPWave	// "Not a valid Zeros & Poles wave; expected a two-column complex single or double precision wave with matching conjugate values."
				String pathToWave= ZerosPolesWavePath()
				Wave/C/Z poleZero= $pathToWave
				if(WaveExists(poleZero)  && ValidIIRCoefsWave(poleZero))
					ChangeZerosPolesWave(poleZero, 1)
				endif
				EnableDisablePZGraphHook(oldEnable)
			endif
			break
	endswitch
End

// call this after altering the number or placement of poles and zeros
// Set doSort if the number of poles and zeros has changed.
static Function UpdateZerosPolesDesign(doSort)
	Variable doSort
	
	Wave/C/Z zerosPoles= $ZerosPolesWavePath()

	if( WaveExists(zerosPoles) )
		String dfSave= GetDataFolder(1)
		NewDataFolder/O root:Packages
		NewDataFolder/O/S root:Packages:WM_ZerosPolesDesign
		Variable nRows= DimSize(zerosPoles,0)	// must be at least one in order to keep the polar graph stuff happy.
		
		if( nRows > 1 && doSort )
			// Preserve the selection over the sort
			Variable rowIndex, isPole	// outputs
			String pathToZeroPole= GetSelectedZeroOrPole(rowIndex, isPole)
			Variable isSelected= strlen(pathToZeroPole) && rowIndex >= 0
			if( isSelected )
				Variable/C poleOrZero = zerosPoles[rowIndex][isPole]	// will be (0,0) if the zero or pole was just deleted (overwritten with (0,0)).
			endif
			// Sort to eliminate extra zeros or poles at (0,0)
			// The trick is that we can only eliminate a zero if we also eliminate a pole.
			// Split the poles and zeros into separate waves

			Make/O/D/C/N=(nRows) poles = zerosPoles[p][1]
			// Sort by radius^2
			Make/O/N=(nRows) poleIndex = magsqr(poles)
			Sort poleIndex, poleIndex, poles
			Variable i, numPolesAtZero=0
			for(i=0; i<nRows;i+=1)
				if( poleIndex[i] != 0 )
					break
				endif
				numPolesAtZero +=1
			endfor
		
			Make/O/D/C/N=(nRows) zeros = zerosPoles[p][0]
			Make/O/N=(nRows) zeroIndex = magsqr(zeros)
			Sort zeroIndex, zeroIndex, zeros
			Variable numZerosAtZero=0
			for(i=0; i<nRows;i+=1)
				if( zeroIndex[i] != 0 )
					break
				endif
				numZerosAtZero +=1
			endfor
			
			Variable numZerosToRemove= min(numPolesAtZero, numZerosAtZero)
			if( numZerosToRemove > 0 && nRows > numZerosToRemove )
				DeletePoints 0, numZerosToRemove, poles, zeros, zerosPoles
				zerosPoles[][0] = zeros[p]
				zerosPoles[][1] = poles[p]
				nRows= DimSize(zerosPoles,0)
				// Preserve the selection over the sort
				if( isSelected )
					Variable updatedSelection= 0
					for(i=0; i<nRows;i+=1)
						if(  cequal(zerosPoles[i][isPole],poleOrZero) )
							SetSelectedZeroOrPole(i, isPole)
							updatedSelection= 1
							break
						endif
					endfor
					if( !updatedSelection )
						ClearSelectedZeroOrPole()	// must have deleted the  selected zero or pole.
					endif
				endif
			endif

			KillWaves/Z poles, zeros, poleIndex, zeroIndex
		endif
		
		// these assignments trigger the dependency formulas, which also detect the possibly changed lengths of the input waves.
		Make/O/N=(nRows) zerosRadii= real(r2polar(zerosPoles[p][0]))
		Make/O/N=(nRows) zerosAngles=imag(r2polar(zerosPoles[p][0]))
		Make/O/N=(nRows) polesRadii= real(r2polar(zerosPoles[p][1]))
		Make/O/N=(nRows) polesAngles=imag(r2polar(zerosPoles[p][1]))
		
		PZMarkerSizesForRadiiAngles(zerosRadii,zerosAngles,"zerosMrkSize")
		UpdateResponse(0)
		DoUpdate						// IndicateSelectedZeroOrPole reads drawnX and drawnY from polar graph...
		IndicateSelectedZeroOrPole()	// so we do this after the polar graph has updated.
		SetDataFolder dfSave				
	endif
End

static Function/S GetDrawLayer(win)
	String win
	
	return "UserFront"
End

// use the UserFront layer to indicatet the current pole or zero
static Function IndicateSelectedZeroOrPole()
	Variable rowIndex, isPole	// outputs
	String pathToZeroPole= GetSelectedZeroOrPole(rowIndex, isPole)
	Variable isSelected= strlen(pathToZeroPole) && rowIndex >= 0
	String oldLayer= GetDrawLayer(ksGraphName)
	SetDrawLayer/W=$ksGraphName/K UserFront
	if( isSelected )
		String traces= RemoveFromList("polarAutoscaleTrace", TraceNameList(ksGraphName, ";", 1) )
		String ytrace
		if( isPole )
			ytrace= StringFromList(0,traces)	// usually "PolarY0"
		else
			ytrace= StringFromList(1,traces)	// usually "PolarY1"
		endif
		Wave/Z wy= TraceNameToWaveRef(ksGraphName, ytrace)
		Wave/Z wx = XWaveRefFromTrace(ksGraphName, ytrace )
		if( WaveExists(wy) && WaveExists(wx) )
		 	Variable drawnY= wy[rowIndex]
			Variable drawnX= wx[rowIndex]
			SetDrawEnv/W=$ksGraphName xcoord=HorizCrossing, ycoord=VertCrossing, fillpat=0, linethick=2, linefgc=(0,32767,0)
Variable size= 0.05	// should scale with graph size and be about 150% of marker size.
			DrawRect/W=$ksGraphName drawnX-size, drawnY-size, drawnX+size, drawnY+size
		 endif
	endif
	SetDrawLayer/W=$ksGraphName $oldLayer
End

// returns truth that a the zerosPoles wave needs resorting
static Function ChangeZeroOrPole(zerosPoles, rowIndex, isPole, newValue)
	Wave/C zerosPoles
	Variable rowIndex, isPole	// which pole or zero to assign newValue to.
	Variable/C newValue

	// a change in Y can cause a pole or zero to split (if it was previously real), or to merge (if it was complex but y is now 0)
	Variable/C oldValue= zerosPoles[rowIndex][isPole]
	Variable oldIsReal= imag(oldValue) == 0
	Variable newIsReal= imag(newValue) == 0
	Variable splitOrMerge= oldIsReal != newIsReal
	Variable i, rows= DimSize(zerosPoles,0)
	Variable/C zp
	if( splitOrMerge )
		Variable merge= newIsReal
		if( merge )
			// find the OLD conjugate and delete it by overwriting with (0,0)
			for( i=0; i<rows;i+=1 )
				if( i == rowIndex )
					continue
				endif
				zp= zerosPoles[i][isPole]
				if ( AreConjugatePair(zp,oldValue) )
					zerosPoles[i][isPole]= cmplx(0,0)	// erase by setting zero or pole to (0,0)
					break
				endif
			endfor
		else	// split
			// Add a conjugate pole and a (0,0) zero
			// or a conjugate zero and a (0,0) pole
			InsertPoints rows, 1, zerosPoles	// appends (0,0) to both columns
			zerosPoles[rows][isPole]= conj(newValue)
		endif
	elseif( !oldIsReal )	// that is, the old value was complex, one a conjugate pair
			// find the OLD conjugate and change it, too
			for( i=0; i<rows;i+=1 )
				if( i == rowIndex )
					continue
				endif
				zp= zerosPoles[i][isPole]
				if ( AreConjugatePair(zp,oldValue) )
					zerosPoles[i][isPole]= conj(newValue)
					break
				endif
			endfor
	endif
	// put the new value into the wave
	zerosPoles[rowIndex][isPole]= newValue

	return splitOrMerge	// pass as parameter to UpdateZerosPolesDesign()
End

static Function UpdateFs(fs)
	Variable fs	// usually root:Packages:WM_ZerosPolesDesign:iir_polar_fs= fs
	
	// update the polar graph's settings.
	WMPolarGraphSetVar(ksGraphName,"angleTickLabelScale", fs/2/180)
	// redraw
	WMPolarAxesRedrawGraphNow(ksGraphName)

	UpdateResponse(0)	
End

static Function UpdateResponse(updateNow)
	Variable updateNow	// if true, disregard unchecked autoUpdate

	if( !updateNow )
		updateNow= AutoUpdateFiltered()
	endif
	
	ControlInfo/W=$ksResponsePanelName ResponseFiltered	// TabControl
	Variable tab= V_value
	if( tab == 0 )
		UpdateFrequencyResponse()
	else
		UpdateFilteredOutput(updateNow)
	endif
End

Static Function UpdateFilteredOutput(updateNow)
	Variable updateNow	// if true, filter the input data, otherwise just ensure the traces are shown/hidden

	Wave/Z filterInputWave= $FilterInputWavePath()
	String outputName= StrVarOrDefault("root:Packages:WM_ZerosPolesDesign:filteredOutputName", "filtered")
	
	// protect against inputName==outputName
	if( WaveExists(filterInputWave) && CmpStr(NameOfWave(filterInputWave),outputName) == 0 )
		String df= GetDataFolder(1)
		SetDataFolder GetWavesDataFolder(filterInputWave,1)
		outputName= UniqueName(outputName, 1, 0)
		String/G root:Packages:WM_ZerosPolesDesign:filteredOutputName= outputName
		SetDataFolder df				
	endif
	
	// protect against multiple magnitude and phase traces by fixing outputName
	if( CmpStr(outputName,"magnitude") == 0 || CmpStr(outputName,"phase") == 0 )
		outputName= "filtered"
		String/G root:Packages:WM_ZerosPolesDesign:filteredOutputName= outputName
	endif

	String graphName= ksResponseGraphName
	Wave/Z output=$""	
	if( strlen(outputName) )
		Wave/Z output= TraceNameToWaveRef(graphName, outputName)
	endif
	
	Wave/C/Z zerosPoles= $ZerosPolesWavePath()

	// allow "" outputName to mean "don't filter the input"
	if( strlen(outputName) && updateNow && WaveExists(zerosPoles) && WaveExists(filterInputWave) )
		String dfSave= GetDataFolder(1)
		SetDataFolder GetWavesDataFolder(filterInputWave,1)
		// filter the input wave using the given output name
		Duplicate/O filterInputWave, $outputName
		Wave output=$outputName
		FilterIIR/DIM=0/COEF=zerosPoles/ZP output
		SetDataFolder dfSave
		String cmd= GetIndependentModulename()+"#WS_UpdateWaveSelectorWidget(\"" + ksFilterInputPanelName +"\", \"filterThisWave\")"
		Execute/P/Q/Z cmd
	endif
	
	// update the graph 

	// remove any other traces that aren't output
	String outputPath= ""
	if( WaveExists(output) )
		outputPath= GetWavesDataFolder(output,2)
	endif
	Variable needToAppendOutput= 1
	String traces= TraceNameList(graphname, ";", 1)
	Variable i, n= ItemsInList(traces)
	for(i=0; i<n; i+=1 )
		String traceName= StringFromList(i,traces)
		String path= GetWavesDataFolder(TraceNameToWaveRef(graphName, traceName), 2)
		if( CmpStr(path,outputPath) == 0 )
			needToAppendOutput= 0
		else
			RemoveFromGraph/W=$graphName $tracename
		endif
	endfor
	// append the filtered output
	if( WaveExists(output) && needToAppendOutput )
		AppendToGraph/W=$graphName output
	endif
	
	traces= TraceNameList(graphname, ";", 1)
	n= ItemsInList(traces)
	if( n < 1 )
		String text
		if( strlen(outputName) ==  0 )
			text=ksPZErrEnterOutputName	// "Enter Output Name to show filtered results"
		elseif( AutoUpdateFiltered() )
			text=ksPZErrSelectInputToFilter	// "Select Input to Filter"
		else
			if( WaveExists(filterInputWave) )
				text=ksPZErrUpdaeNowToFiltUpdate	// "Click Update Output Now to show filtered results"
			else
				text=ksPZErrSelectInputToFiltUpdate	// "Select Input to Filter and click Update Output Now"
			endif
		endif
		Textbox/W=$graphName/C/N=ResponseLegend text
	else
		Legend/W=$graphName/C/N=ResponseLegend ""
	endif
End


static Function UpdateFrequencyResponse()

	String graphName= ksResponseGraphName
	String panelName= ksResponsePanelName

	Wave/C/Z zerosPoles= $ZerosPolesWavePath()
	Wave/Z magnitude, phase	// Fake out the FFT command to generate real (not complex) wave references.
	Variable phaseIsInDegrees=0
	if( WaveExists(zerosPoles) )
		String dfSave= GetDataFolder(1)
		NewDataFolder/O root:Packages
		NewDataFolder/O/S root:Packages:WM_ZerosPolesDesign
		// filter an impulse
		Variable npnts=1000
		if( !WaveExists(impulseResponse) || numpnts(impulseResponse) != npnts )
			Make/O/N=(npnts) impulseResponse
		endif
		Variable fs= NumVarOrDefault("root:Packages:WM_ZerosPolesDesign:iir_polar_fs", 1)
		impulseResponse= p==0
		SetScale/P x, 0, 1/fs, "s" impulseResponse
		FilterIIR/COEF=zerosPoles/ZP impulseResponse
		// measure the response 
		FFT/MAG/DEST=magnitude impulseResponse

		ControlInfo/W=$panelName magnitudePop
		SetScale d, 0, 0, "dB", magnitude
		Variable logType= 0
		switch(V_value)
			case 1:	// "dB":
				magnitude= 20*log(magnitude)
				break
			case 2:	// "dB min -100":
				magnitude= max(-100,20*log(magnitude))
				break
			case 3:	// "dB min -20":
				magnitude= max(-20,20*log(magnitude))
				break
			case 5:	// "Gain log10":
				logType= 1
			case 4:	// "Gain":
			default:
				SetScale d, 0, 0, "", magnitude
				break
		endswitch
		FFT/OUT=5/DEST=phase impulseResponse
		Variable modulus= 2*pi
		ControlInfo/W=$panelName phaseDegrees
		phaseIsInDegrees= V_Value
		if( phaseIsInDegrees )
			modulus= 360
			phase *= 180/pi		// convert to degrees
			SetScale d, 0, 0, "deg", phase
		else
			SetScale d, 0, 0, "rad", phase
		endif
		ControlInfo/W=$panelName phaseUnwrap
		if(V_Value )
			Unwrap modulus, phase	// continuous phase
		endif
		SetDataFolder dfSave				
	endif	

	// remove any traces that aren't magnitude or phase
	
	Variable needToAppendMagnitude= 1
	Variable needToAppendPhase= 1
	String pathToMagnitude= "root:Packages:WM_ZerosPolesDesign:magnitude"
	String pathToPhase= "root:Packages:WM_ZerosPolesDesign:phase"
	String traces= TraceNameList(graphname, ";", 1)
	Variable i, n= ItemsInList(traces)
	for(i=0; i<n; i+=1 )
		String traceName= StringFromList(i,traces)
		String path= GetWavesDataFolder(TraceNameToWaveRef(graphName, traceName), 2)
		if( CmpStr(path,pathToMagnitude) == 0 )
			needToAppendMagnitude= 0
		elseif( CmpStr(path,pathToPhase) == 0 )
			needToAppendPhase= 0
		else
			RemoveFromGraph/W=$graphName $tracename
		endif
	endfor
	// append the filtered output
	// Magnitude (possibly hidden)
	Wave/Z magnitude=$pathToMagnitude
	if( WaveExists(magnitude) && needToAppendMagnitude )
		AppendToGraph/W=$graphName magnitude
	endif	
	Variable haveMagnitudeTrace=0
	if( WaveExists(magnitude) )
		CheckDisplayed/W=$graphName magnitude
		haveMagnitudeTrace= V_Flag
	endif
	if( haveMagnitudeTrace ) 
		ControlInfo/W=$panelName showMagnitude
		ModifyGraph/W=$graphName hideTrace(magnitude)=!V_value, log(left)=logType
	endif

	// Phase (possibly hidden)
	Wave/Z phase=$pathToPhase
	if( WaveExists(phase) && needToAppendPhase )
		AppendToGraph/R/W=$graphName phase
		ModifyGraph/W=$graphName rgb(phase)=(0,0,65535)
	endif
	Variable havePhaseTrace=0
	if( WaveExists(phase) )
		CheckDisplayed/W=$ksGraphName phase
		havePhaseTrace= V_Flag
	endif

	if( havePhaseTrace ) 
		Variable inc= 0, minorTicks
		if( phaseIsInDegrees )
			inc= PZChooseDegreesIncrement(phase, graphName, "right", minorTicks)
		endif
		if( inc == 0 )
			ModifyGraph/W=$graphName minor(right)=1,manTick(right)=0
		else
			ModifyGraph/W=$graphName manTick(right)={0,inc,0,0},manMinor(right)={minorTicks,0}
		endif
		ControlInfo/W=$panelName showPhase
		ModifyGraph/W=$graphName hideTrace(phase)=!V_value
	endif
	
	Legend/W=$graphName/C/N=ResponseLegend ""
End

static Function PZChooseDegreesIncrement(wDegrees, graphName, axisName, minorTicks)
	Wave wDegrees
	String graphName, axisName
	Variable &minorTicks
	
	GetWindow $graphName psize
	Variable approxGraphHeightInPoints= V_bottom- V_top
	String fontName
	Variable fontStyle
	Variable fontSize= PZAxisLabelFontSizeStyle(graphName, axisName, fontName, fontStyle)	// in points

	// figure out how many labels will fit on the axis.
	// here we're assuming that the axis is vertical (left/right)
	// and the labels are horizontal, so they stack their heights
	Variable labelHeightPixels= FontSizeHeight(fontName, fontSize, fontStyle)
	Variable labelHeightPoints= labelHeightPixels/ScreenResolution*PanelResolution(graphName)
	Variable maxLabels= floor(approxGraphHeightInPoints/labelHeightPoints)

	WaveStats/Q/M=1 wDegrees
	Variable range= V_max-V_min
	Variable delta= range/(maxLabels / 1.1)
	Variable inc
	// round to multiple of 360, 90, 45, 15, or 5
	inc= 360 * round(delta/360)
	minorTicks= 3	// 90 degrees
	if( inc == 0 )
		inc= 90 * round(delta/90)
		minorTicks= 2	// 30 degrees
		if( inc == 0 )
			inc= 45 * round(delta/45)
			minorTicks= 2	// 15 degrees
			if( inc == 0 )
				inc= 15 * round(delta/15)
				minorTicks= 2	// 5 degrees
				if( inc == 0 )
					inc= 5 * round(delta/5)
					minorTicks= 4	// 1 degrees
				endif
			endif
		endif
	endif
	return inc
End

// this belongs in <Axis Utilities>
// Requires Igor 6.0
static Function PZAxisLabelFontSizeStyle(graphName, axisName, fontName, fontStyle)
	String graphName, axisName
	String &fontName
	Variable &fontStyle
	
	String info= AxisInfo(graphName,axisName)
	fontName= StringByKey("FONT", info)
	fontStyle= NumberByKey("FONTSTYLE", info)
	return NumberByKey("FONTSIZE",info)
End

// creates waves in the current data folder.
static Function PZMarkerSizesForRadiiAngles(radii,anglesInRadians, markerOutputName)
	Wave radii,anglesInRadians
	String markerOutputName

	Variable maxMrkSize= 5
	Variable nCoords= DimSize(radii,0)
	Make/O/N=(nCoords) $markerOutputName=maxMrkSize
	Wave markerWave= $markerOutputName
	WaveStats/Q radii
	Variable closeRadii= abs(V_Max * 5/100)	// "close" radius
	Variable closeAngle= 0.1/2 * pi/180			// "close" angle in radians
	Variable i
	for( i=1; i < nCoords; i+=1 )
		// count how many previous coordinates are "close" to this one
		Variable j, mrksize=markerWave[0]
		Variable thisRadius= radii[i]
		Variable thisAngle= anglesInRadians[i]
		for( j=0; j < i; j+=1)
			Variable radiusDiff= abs(thisRadius-radii[j])
			Variable angleDiff= abs(thisAngle-anglesInRadians[j])
			Variable closeCoord= (radiusDiff < closeRadii) && (angleDiff < closeAngle)
			if( closeCoord )
				if( mrksize < 19*3+5 )	// after 20 zeros, I doubt they care to see how many there really are.
					mrksize += 3
				else
					mrksize += 1
				endif
				if( mrkSize > maxMrkSize )
					maxMrkSize=mrkSize
				endif
			endif
		endfor
		markerWave[i]= mrksize
	endfor
	return maxMrkSize
end


static Function WMDesignPolesAndZerosHook(infoStr)
	String infoStr

	Variable status=0
	String event= StringByKey("EVENT",infoStr)
	String win
	strswitch(event)
		case "mousedown":
		case "mouseup":
		case "mousemoved":
			Variable mousex= NumberByKey("MOUSEX", infoStr)
			Variable mousey= NumberByKey("MOUSEY", infoStr)
			win= StringByKey("WINDOW", infoStr)
			if( CmpStr(event,"mousedown") == 0 )
				GetWindow $win gsizeDC	// pixels
				if( mousey < V_bottom && mousey > V_top && mousex > V_left && mousex < V_right )
					Variable maxRadius = limitMaxRadius() ? 1 : Inf
					status= 1// assume we're handling the mouse event.
					strswitch(GetCheckedRadio())
						case "clickRadioNormal":
							status= 0	// mouse down not handled
							break
						case "clickRadioAddPole":
							AddPoleAtXY(mousex,mousey,maxRadius)
							break
						case "clickRadioAddZero":
							AddZeroAtXY(mousex,mousey,maxRadius)
							break
						case "clickRadioSelect":
						case "clickRadioRemove":
							String info= TraceFromPixel(mousex, mousey, "WINDOW:"+ksGraphName)
							String trace= StringByKey("TRACE",info)
							if( strlen(trace) == 0 )
								Beep
							else
								Variable pnt= NumberByKey("HITPOINT",info)
								Wave/C/Z zerosPoles= $ZerosPolesWavePath()
								if( WaveExists(zerosPoles) )
									Variable hitZero = CmpStr(trace,"polarY1") == 0
									Variable isPole = hitZero ? 0 : 1
									if( CmpStr(GetCheckedRadio(), "clickRadioSelect") == 0 )
										//	Select or deselect the hit zero or pole
										Variable selectedRow, selectedIsPole
										GetSelectedZeroOrPole(selectedRow, selectedIsPole)
										if( selectedRow == pnt && selectedIsPole == isPole )
											 ClearSelectedZeroOrPole()
										else
											SetSelectedZeroOrPole(pnt, isPole)
										endif
									else							
										// Delete the zero or pole and possibly its conjugate
										Variable/C zp= zerosPoles[pnt][isPole]
										RemoveZeroOrPole(zp, hitZero)
									endif
								else
									Beep
								endif
							endif
							break
					endswitch
				endif
			endif
			if( CmpStr(event,"mousemoved") == 0 )
				Variable cursorNum= 0
				GetWindow $win gsizeDC	// pixels
				if( mousey < V_bottom && mousey > V_top && mousex > V_left && mousex < V_right )
					strswitch(GetCheckedRadio())
						case "clickRadioAddPole":
							cursorNum= 14	// "X" cursor (X in a box)
							break
						case "clickRadioAddZero":
							cursorNum= 15	// "O" cursor (0 with a cross in it)
							break
						case "clickRadioSelect":
							cursorNum= 18// select cursor (maybe should be 1)
							// to do: add dragging code.
							// if( dragging )
							
							// endif
							break
						case "clickRadioRemove":
							cursorNum= 19	// Zap cursor
							break
					endswitch
				endif
				SetWindow $win hookcursor=cursorNum
				if( cursorNum > 0 )
					status= 2			// we have taken over this event
				endif
			endif
			break
		case "activate":
			UpdateResponse(0)	// the input wave may have been edited.
			// FALL THROUGH
		case "deactivate":
			SetWindow $ksGraphName, userdata(setPanelSizeScheduled)= ""	// avoid locking out calls to SetPanelSize().
			break
		case "resize":
			Variable resizePending= LimitWindowSize()
			if( !resizePending )
				RepositionControlsInPLEFT()
				RepositionControlsInPRIGHT()
			endif
			break
		case "kill":
			// save sort order
			Variable sk= -1 //get
			Variable sr= -1
			WS_SetGetSortOrder(ksLeftPanelName, "sort", sk, sr)
			Variable/G root:Packages:WM_ZerosPolesDesign:sortKind= sk
			Variable/G root:Packages:WM_ZerosPolesDesign:sortReverse= sr 

			if(0 )	// the WMPolarGraphHook already deletes the targets if no window macro exists.
				// Delete the radiusTarget and angleTargets
				String cmd= "KillVariables "+WMPolarGraphDFVar(ksGraphName,"shadowTarget0")+","+WMPolarGraphDFVar(ksGraphName,"radiusTarget0")
				Execute/P/Q/Z cmd
				cmd= "KillVariables "+WMPolarGraphDFVar(ksGraphName,"shadowTarget1")+","+WMPolarGraphDFVar(ksGraphName,"radiusTarget1")
				Execute/P/Q/Z cmd
				cmd= "KillDataFolder "+WMPolarGraphDF(ksGraphName)
				Execute/P/Q/Z cmd
			endif
			// remove this procedure and anything it includes (some day when it doesn't cause user-defined menu problems)
//			Execute/P/Q/Z "DELETEINCLUDE <Pole And Zero Filter Design>"
//			Execute/P/Q/Z "COMPILEPROCEDURES "
			break
	endswitch

		
	if( status == 0 )
		WC_WindowCoordinatesHook(infoStr)
		status= WMPolarGraphHook(infoStr)
	endif
	return status
End

// returns truth the window will (eventually) be resized.
static Function LimitWindowSize()

	Variable resizePending= 0
	
	Variable minWidthPoints= 400
	Variable minHeightPoints =300
			
#if IgorVersion() >= 7
	SetWindow $ksGraphName sizeLimit={minWidthPoints, minHeightPoints, Inf, Inf}
#else
	GetWindow $ksGraphName wsize	// V_left, V_top, V_right, V_bottom in points
	Variable width= V_right-V_left
	Variable height= V_bottom-V_top
	Variable resizeNeeded= (width < minWidthPoints-1) || (height < minHeightPoints-1)
	if( resizeNeeded )
		String setPanelSizeScheduledStr= GetUserData(ksGraphName,"","setPanelSizeScheduled")	// "" if never set (means "no")
		if( strlen(setPanelSizeScheduledStr) == 0 )
			SetWindow $ksGraphName, userdata(setPanelSizeScheduled)= "yes"
			V_right = max(V_right, V_left + minWidthPoints)
			V_bottom= max(V_bottom, V_top +minHeightPoints )
			String cmd
			String functionName=GetIndependentModulename()+"#ResetPoleZeroSize"
			sprintf cmd "%s(%g, %g, %g, %g)", functionName, V_left, V_top, V_right, V_bottom
			Execute/P/Q/Z cmd
			resizePending = 1
		endif
	endif
#endif
	return resizePending
End

Function ResetPoleZeroSize(left, top, right, bottom) // points
	Variable left, top, right, bottom
	
	MoveWindow/W=$ksGraphName left, top, right, bottom
	SetWindow $ksGraphName userdata(setPanelSizeScheduled)= ""
	RepositionControlsInPLEFT()
	RepositionControlsInPRIGHT()
End

static Function RepositionControlsInPRIGHT()

	String pwin= ksRightPanelName
	
	// Any controls that are off the bottom are moved off to the right so they can't be invoked by clicking in the Response tab 

	GetWindow $pwin wsizeDC	// in pixels
	// Sets V_left, V_top, V_right, V_bottom
	Variable pLeft= 0
	Variable pTop= 0
	Variable pRight= (V_right-V_left) * 72 / ScreenResolution 	// in panel units
	Variable pBottom= (V_bottom-V_top) * 72 / ScreenResolution - 2 // in panel units
	
	Variable shiftOffscreenPanelUnits= (pRight - pLeft ) * 2
	Variable i=0
	String controls= RemoveFromList("mouseClickGroup;editGroup;", ksPRIGHTcontrols)
	do
		String controlName= StringFromList(i,controls)
		if( strlen(controlName) == 0 )
			break
		endif
		ControlInfo/W=$pwin $controlName	// Sets V_left, V_top, V_Width, V_Height in panel units
		Variable cLeft= V_left
		Variable cTop= V_top
		Variable cRight= V_left+V_Width
		Variable cBottom= V_top+V_Height

		// if the bottom is below pBottom,
		if( cBottom > pBottom )
			// move it off to the right
			// unless it is already there
			if( cLeft < pRight )
				cLeft += shiftOffscreenPanelUnits
			endif
		else
			if( cLeft > pRight )
				cLeft -=  shiftOffscreenPanelUnits
			endif
		endif		
		if( cLeft != V_left )
			ModifyControl/Z $controlName, win=$pwin, pos={cLeft, cTop}, size={V_Width, V_Height}
		endif
		i += 1
	while(1)
	// could resize the group boxes so they don't appear to go off the bottom.
End

static Function RepositionControlsInPLEFT()

	String pwin= ksLeftPanelName
	
	GetWindow $pwin wsizeDC	// in pixels
	// Sets V_left, V_top, V_right, V_bottom
	
	ControlInfo/W=$pwin new
	Variable top= (V_bottom) * 72 / ScreenResolution - 28	// in panel units
	ModifyControl new, win=$pwin, pos={V_left, top}, size={V_Width, V_Height}

	ControlInfo/W=$pwin fromTarget	// Sets V_left, V_top, V_Width, V_Height in panel units
	top -= V_Height+10
	ModifyControl fromTarget, win=$pwin, pos={V_left, top}, size={V_Width, V_Height}

	ControlInfo/W=$pwin sort	// Sets V_left, V_top, V_Width, V_Height
	top -= 2
	ModifyControl sort, win=$pwin, pos={V_left, top}, size={V_Width, V_Height}

	ControlInfo/W=$pwin poleZeroWavesList
	Variable bottom= top-6
	Variable height= bottom - V_top
	ModifyControl poleZeroWavesList, win=$pwin, pos={V_left, V_top}, size={V_Width, height}
End

 // ==== START ====  Control and utility procs for editing poles and zeros. These controls are all in the ksGraphName+"#PRIGHT" subwindow

static Function/S GetCheckedRadio()
	String checkedName= "clickRadioNormal"
	ControlInfo/W=$ksRightPanelName clickRadioAddPole
	if( V_Value )
		checkedName= "clickRadioAddPole"
	endif
	ControlInfo/W=$ksRightPanelName clickRadioAddZero
	if( V_Value )
		checkedName= "clickRadioAddZero"
	endif
	ControlInfo/W=$ksRightPanelName clickRadioSelect
	if( V_Value )
		checkedName= "clickRadioSelect"
	endif
	ControlInfo/W=$ksRightPanelName clickRadioRemove
	if( V_Value )
		checkedName= "clickRadioRemove"
	endif
	return checkedName	
End

static Function limitMaxRadius()

	ControlInfo/W=$ksRightPanelName limitRadius
	return  V_Value
End


Static Function ClickRadioProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			String ctrlName= cba.ctrlName
			String win= cba.win	
			Checkbox clickRadioNormal, win=$win, value=CmpStr(ctrlName,"clickRadioNormal")==0
			
			Checkbox clickRadioAddPole, win=$win, value=CmpStr(ctrlName,"clickRadioAddPole")==0
			Checkbox clickRadioAddZero, win=$win, value=CmpStr(ctrlName,"clickRadioAddZero")==0
			
			Checkbox clickRadioSelect, win=$win, value=CmpStr(ctrlName,"clickRadioSelect")==0
			
			Checkbox clickRadioRemove, win=$win, value=CmpStr(ctrlName,"clickRadioRemove")==0

			Variable disable= CmpStr(ctrlName,"clickRadioAddPole") == 0  || CmpStr(ctrlName,"clickRadioAddZero") == 0 ? 0 : 1
			ModifyControl limitRadius win=$win, disable=disable
			break
	endswitch

	return 0
End


static Function ClearButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			
			Variable oldEnable= EnableDisablePZGraphHook(0)	// disable the activate hook, because when DoAlert closes the dialog, the activate hook attempts to use the zerosPoles wave while it is being modified!
			String win= ba.win
			DoAlert 1, ksPZErrClearAllPZ	// "Clear All Poles and Zeros?"
			if( V_Flag == 1 )	// yes
				Wave/C/Z zerosPoles= $ZerosPolesWavePath()
				if( WaveExists(zerosPoles) )
					Redimension/N=(1,2) zerosPoles
					zerosPoles= cmplx(0,0)
					UpdateZerosPolesDesign(0)				
				endif
			endif
			EnableDisablePZGraphHook(oldEnable)
			break
	endswitch

	return 0
End

static Function NewWaveButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			String name= "zpCoefs"
			if( exists("zpCoefs") == 1 )
				name= UniqueName("zpCoefs", 1, 0)
			endif
			Prompt name, "Name"
			Variable oldEnable= EnableDisablePZGraphHook(0)	// disable the activate hook, because when DoPrompt closes the dialog, the activate hook attempts to use the zerosPoles wave while it is being modified!
			DoPrompt ksPZPromptNewZPName, name	// "New zeros/poles wave"
			if( V_flag == 0 )	// Continue was clicked
				if( exists(name) == 1 )
					String msg
					sprintf msg, ksPZErrOverwriteExistingWaveFmt, name	// "Overwrite existing %s?"
					DoAlert 1, msg
					if( V_Flag != 1 )	// not "Yes"
						return 0
					endif
				endif
				Make/O/C/N=(1,2) $name= cmplx(0,0)
				Wave/C cw=$name
				WS_UpdateWaveSelectorWidget(ksLeftPanelName, "poleZeroWavesList")
				ChangeZerosPolesWave(cw, 1)
			endif
			EnableDisablePZGraphHook(oldEnable)
			break
	endswitch

	return 0
End
 

static Function PresetStdFiltersButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			break
	endswitch

	return 0
End


static Function EnableZeroOrPoleEditControls()

	Variable rowIndex, isPole	// outputs
	String pathToZeroPole= GetSelectedZeroOrPole(rowIndex, isPole)
	Variable enable= strlen(pathToZeroPole) && rowIndex >= 0
	
	if( enable )
		Wave/C zeroPole= $pathToZeroPole
		Variable/C cpx= zeroPole[rowIndex][isPole]
		Variable/G root:Packages:WM_ZerosPolesDesign:zpx= real(cpx)
		Variable/G root:Packages:WM_ZerosPolesDesign:zpy= imag(cpx)
		cpx= r2polar(cpx)
		Variable/G root:Packages:WM_ZerosPolesDesign:zpr= real(cpx)
		Variable/G root:Packages:WM_ZerosPolesDesign:zpa= imag(cpx) * 180/pi	// degrees
	else
		Variable/G root:Packages:WM_ZerosPolesDesign:zpx= 0
		Variable/G root:Packages:WM_ZerosPolesDesign:zpy= 0
		Variable/G root:Packages:WM_ZerosPolesDesign:zpr= 0
		Variable/G root:Packages:WM_ZerosPolesDesign:zpa= 0
	endif
	
	ControlInfo/W=$ksRightPanelName editPolar
	Variable isPolar= V_Value
	String controls
	if( isPolar )
		controls= "zpr;zpa;"
	else
		controls= "zpx;zpy;"
	endif
	String format= "%g"
	if( !enable )
		format= "                               %g"	// push the 0 off to the right
	endif
	ModifyControlList controls win=$ksRightPanelName, frame= enable ? 1 : 0, format=format	// SetVariables don't look disabled with the frame on.

	controls += "editPolar;editRectangular;"
	ModifyControlList controls win=$ksRightPanelName, disable= enable ? 0 : 2	// show enabled or disabled
End

static Function EditCoordinatesRadioProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable isPolar= CmpStr(cba.ctrlName, "editPolar") == 0
			Checkbox editPolar win=$(cba.win), value=isPolar
			Checkbox editRectangular win=$(cba.win), value=!isPolar
			Variable show= IsPoleOrZeroSelected() ? 0 : 2	// show enabled or disabled
			ModifyControlList "zpx;zpy;" win=$(cba.win), disable= !isPolar ? show : 1	// show or hide
			ModifyControlList "zpr;zpa;" win=$(cba.win), disable= isPolar ? show : 1	// show or hide
			break
	endswitch

	return 0
End

static Function IsPoleOrZeroSelected()

	Variable rowIndex, isPole	// outputs
	String pathToZeroPole= GetSelectedZeroOrPole(rowIndex, isPole)
	Variable selected= strlen(pathToZeroPole) && rowIndex >= 0
	return selected
End

static Function EditZpxySetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable rowIndex, isPole	// outputs
			String pathToZeroPole= GetSelectedZeroOrPole(rowIndex, isPole)
			Variable selected= strlen(pathToZeroPole) && rowIndex >= 0
			
			if( selected )
				NVAR zpx= root:Packages:WM_ZerosPolesDesign:zpx
				NVAR zpy= root:Packages:WM_ZerosPolesDesign:zpy
				Variable/C new= cmplx(zpx, zpy)

				// update radius and angle from x and y
				Variable/C polar= r2polar(new)
				Variable/G root:Packages:WM_ZerosPolesDesign:zpr= real(polar)
				Variable/G root:Packages:WM_ZerosPolesDesign:zpa= imag(polar) * 180/pi	// degrees
				
				// a change in Y can cause a pole or zero to split (if it was previously real), or to merge (if it was complex but y is now 0)
				Wave/C zerosPoles= $pathToZeroPole
				Variable doSort= ChangeZeroOrPole(zerosPoles, rowIndex, isPole, new)
				UpdateZerosPolesDesign(doSort)
			endif
			break
	endswitch

	return 0
End

static Function EditZpraSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			// update x and y from radius and angle
			Variable rowIndex, isPole	// outputs
			String pathToZeroPole= GetSelectedZeroOrPole(rowIndex, isPole)
			Variable selected= strlen(pathToZeroPole) && rowIndex >= 0
			
			if( selected )
				NVAR zpr= root:Packages:WM_ZerosPolesDesign:zpr
				NVAR zpa= root:Packages:WM_ZerosPolesDesign:zpa
				Variable/C polar= cmplx(zpr, zpa/180*pi)

				// update radius and angle from x and y
				Variable/C new= p2rect(polar)
				Variable/G root:Packages:WM_ZerosPolesDesign:zpx= real(new)
				Variable/G root:Packages:WM_ZerosPolesDesign:zpy= imag(new)
				
				// a change in Y can cause a pole or zero to split (if it was previously real), or to merge (if it was complex but y is now 0)
				Wave/C zerosPoles= $pathToZeroPole
				Variable doSort= ChangeZeroOrPole(zerosPoles, rowIndex, isPole, new)
				UpdateZerosPolesDesign(doSort)
			endif
			break
	endswitch

	return 0
End

 // ==== END ====  Control procs for editing poles and zeros. These controls are all in the ksGraphName+"#PRIGHT" subwindow

 
// ==== START ====  Control procs for Magnitude & Phase display. These controls are all in the ksGraphName+"#P0" subwindow

Static Function FsSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			UpdateFs(dval)
			break
	endswitch

	return 0
End

// Tab control


// these are in the Response tab
static Function ShowMagnitudeCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			String graphName= ksResponseGraphName
			ModifyGraph/W=$graphName hideTrace(magnitude)=!checked
			ModifyControlList "magnitudePop;" win=$(cba.win), disable= checked ? 0 : 2
			break
	endswitch

	return 0
End

static Function ShowPhaseCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			String graphName= ksResponseGraphName
			ModifyGraph/W=$graphName hideTrace(phase)=!checked
			// disable or enable phase controls
			ModifyControlList "phaseDegrees;phaseRadians;phaseUnwrap;" win=$(cba.win), disable= checked ? 0 : 2
			break
	endswitch

	return 0
End

static Function/S MagnitudePopList()		
	return  ksMagnitudePopItems	// "dB;dB min -100;dB min -20;Gain;Gain log10;")
End		

static Function MagnitudePopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			UpdateResponse(0)
			break
	endswitch

	return 0
End


static Function RadiansDegreesCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Checkbox phaseDegrees win=$(cba.win), value=CmpStr(cba.ctrlName, "phaseDegrees") == 0
			Checkbox phaseRadians win=$(cba.win), value=CmpStr(cba.ctrlName, "phaseRadians") == 0
			UpdateResponse(1)
			break
	endswitch

	return 0
End

static Function UnwrapCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			UpdateResponse(1)
			break
	endswitch

	return 0
End


// These are in the Filtered tab

Static StrConstant ksResponseTabControls="showMagnitude;magnitudePop;showPhase;phaseRadians;phaseDegrees;phaseUnwrap;"
Static StrConstant ksFilteredTabControls="filteredOutputName;autoUpdateFilteredOutput;updateNow;"

static Function ResponseTabProc(tca) : TabControl
	STRUCT WMTabControlAction &tca

	switch( tca.eventCode )
		case 2: // mouse up, switch tabs
			Variable tab = tca.tab
			String win= tca.win
			
			Variable show= tab==0
			ShowOrHideControlList(win, ksResponseTabControls, show)
			
			show= tab==1
			ShowOrHideControlList(win, ksFilteredTabControls, show)
			
			UpdateResponse(0)
			break
	endswitch

	return 0
End

Static Function ShowOrHideControlList(win, controls, show)
	String win
	String controls	// semicolon-separated controls
	Variable show
		
	// Use the Asylum Research trick:
	// disable= 0 = showing and active
	// disable= 2 = showing and disabled

	// disable= 1 = hidden and (latent) active
	// disable= 3 = hidden and (latent) disabled
	Variable i, n= ItemsInList(controls)
	for(i=0; i<n; i+=1 )
		String control= StringFromList(i,controls)
		ControlInfo/W=$win $control
		
		if( show )
			switch( V_disable )
				case 0:
				case 2:
					break
				case 1:
					V_disable = 0
					break
				case 3:
					V_disable = 2	// showing and disabled
					break
			endswitch
		else
			switch( V_disable )
				case 0:
					V_disable = 1
					break
				case 2:
					V_disable = 3	// hidden and latent disabled
					break
				case 1:
				case 3:
					break
			endswitch
		endif
		ModifyControl $control win=$win, disable= V_disable
	endfor
End

Static Function FilteredOutputNameSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 2: // Enter key
			String sval = sva.sval
			UpdateResponse(0)
			break
	endswitch

	return 0
End

static Function UpdateFilterOutputNowButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			Wave/Z filterInputWave= $FilterInputWavePath()
			if( WaveExists(filterInputWave) )
				UpdateResponse(1)
			else
				DoAlert 0, ksPZErrSelectInputFromList	// "Select an Input to Filter from the list on the left."
			endif
			break
	endswitch

	return 0
End

static Function AutoUpdateFilteredOutCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			Wave/Z filterInputWave= $FilterInputWavePath()
			if( checked && !WaveExists(filterInputWave) )
				DoAlert 0, ksPZErrSelectInputFromList	// "Select an Input to Filter from the list on the left."
			endif
			break
	endswitch

	return 0
End

static Function AutoUpdateFiltered()
	ControlInfo/W=$ksResponsePanelName autoUpdateFilteredOutput
	return V_Value
End


// ==== END ====  Control procs for Magnitude & Phase display. These controls are all in the ksGraphName+"#P0" subwindow


// ==== START ====  Control procs for  the ksGraphName+"#P1" subwindow

static Function InputToFilterNotificationProc(SelectedItem, EventCode)
	String SelectedItem		// string with full path to the item clicked on in the wave selector
	Variable EventCode		// the ListBox event code that triggered this notification

	switch( EventCode )
		case WMWS_DoubleClick:
			Wave/Z w = $SelectedItem
			if( WaveExists(w) )
// TO DO: Use ReplaceWave instead of always regenerating the graph
				DoWindow/K FilteredInputGraph
// TO DO: Handle stereo data				
				Display/N=FilteredInputGraph/K=1 w
				AutoPositionWindow/E/R=$ksGraphName FilteredInputGraph
			endif
			break
		case WMWS_SelectionChanged:
			Wave/Z w = $SelectedItem
			if( WaveExists(w) )
				Variable fs= 1/deltax(w)
				Variable/G root:Packages:WM_ZerosPolesDesign:iir_polar_fs= fs
				UpdateFs(fs)	// calls UpdateResponse()
			else
				UpdateResponse(0)	// show blank response
			endif
			break
	endswitch
End

static Function/S FilterInputWavePath()

	String wavePaths= WS_SelectedObjectsList(ksFilterInputPanelName, "filterThisWave")
	
	return StringFromList(0,wavePaths)	// can be ""
End

// ==== END ====  Control procs for  the ksGraphName+"#P1" subwindow
