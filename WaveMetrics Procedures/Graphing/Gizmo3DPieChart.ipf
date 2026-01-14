#pragma rtGlobals=3		// Use modern global access method.
#pragma ModuleName=Gizmo3DPieChart
#pragma IgorVersion=7	// requires Igor 7's built-in Gizmo
#pragma version=8.03	// shipped with Igor 8.03

#include <colorSpaceConversions>
#include <WaveSelectorWidget>
#include <PopupWaveSelector>, version >= 1.04
#include <GizmoUtils>, version >= 7
#include <GizmoOrthoZoom>, version >= 7

// Gizmo3DPieChart.ipf
// Oct 22, 2004, Igor 5.03, JP - Initial version.
// Aug 14, 2007, Igor 6.02, JP - Revised for native GUI controls, fixed GetGizmoCoordinates for Mac Gizmo XOP.
// Restored font popup, used PopupWaveSelector for legend text wave.
// May 12, 2010, Igor 6.2, JP - Used public versions of generally useful routines in GizmoUtils.ipf,
// made use of ModifyGizmo/N, extensively revised window aspect settings (moved to GizmoOrthoZoom.ipf and GizmoUtils.ipf).
// Fixed bug where the panel checkboxes got reset every time the top Gizmo wasn't a 3D Pie chart.
// Stopped using a "datafolder" string object and associated color attribute in favor of Gizmo's new userString feature.
// May/Jun 2016, Igor 7, JP - Uses Igor 7's built-in Gizmo, more commands are compiled rather than interpreted, so Execute is rarely needed.
// The 3D Pie chart Legend is now a normal Igor annotation instead of a complicated bunch of strings in a Legend Group.

Static Constant kDegreesPerFace=5
Static Constant kDefaultWindowAspect= 1.333333333
Static StrConstant ks3DPieLegend="PieLegend"

Menu "New"
	"Gizmo 3D Pie Chart",/Q, NewGizmo3DPieChart()
End

Menu "Gizmo Pie", dynamic
	"New Gizmo 3D Pie Chart",/Q, NewGizmo3DPieChart()
	"Show 3D Pie Chart Panel",/Q,  ShowGizmo3DPieChartPanel()
	"-"
	"Gizmo 3D Pie Chart Help",/Q,DisplayHelpTopic/K=1 "Gizmo 3D Pie Charts"
End

// Now returns the gizmo window name
Function/S NewGizmo3DPieChart()

	Variable left= 10
	Variable top= 50
	Variable width= 440
	Variable height= width / kDefaultWindowAspect

	NewGizmo/W=(left, top, left+width, top+height)
	String gizmoName= TopGizmo()
	String dfName= CreateNewPackagePerGizmoDF(gizmoName,ksPackageName)
	SetGizmoUserString(gizmoName, ksIs3DPieChartString, "Yes")	// see GizmoIs3DPieChart()

	Variable vOrtho= 2
	Variable hOrtho= vOrtho * kDefaultWindowAspect
	ModifyGizmo/N=$gizmoName insertDisplayList=0, opName=ortho0, operation=ortho, data={ -hOrtho, hOrtho, -vOrtho, vOrtho,-2,2}

	// The following was the unnamed hook that pre-6.02 3D pie charts have installed:
	// Execute "ModifyGizmo hookFunction=WMGizmo3DPieChartHook"
	// Execute "ModifyGizmo hookEvents=8"	// kill and resize events only
	// The next was the Igor 6.02 hook: it won't work in an independent module:
	//Execute "ModifyGizmo namedHook={Gizmo3DPieChart,WMGizmo3DPieChartNamedHook}"
	
	UpdateHookFunction(gizmoName, "Gizmo3DPieChart", "WMGizmo3DPieChartNamedHook", "WMGizmo3DPieChartHook")

//	ModifyGizmo/N=$gizmoName euler = {0,0,-30}// Twisted angle 0 down 30 degrees, should be a user input
	ModifyGizmo/N=$gizmoName euler = {0,0,0}

	Variable/G $GizmoDFVar(gizmoName,"preserveAspectRatio") = kDefaultWindowAspect
	
	ResetGizmo3DPieChart(gizmoName)	// removes all objects and display list (but preserves the df name attribute)

	String win=ShowGizmo3DPieChartPanel()	// do this in the current data folder to get the wave popups to populate nicely.

	ModifyGizmo/N=$gizmoName infoWindow={300,504,720,705}

	DoWindow/F $win

	return gizmoName
End

// Cleans out the pie chart objects, ready for rebuilding.
// NOTE: Turns Gizmo compile off (compile=0)
Static Function ResetGizmo3DPieChart(gizmoName)
	String gizmoName
	
	if( !ValidGizmoName(gizmoName) )
		return 0
	endif

	String oldDF= SetTempDF()	// a place to leave Execute's globals.

	SetGizmoCurrentGroup(gizmoName, "")	// in case something went wrong previously while not the root group

	// Keep the ortho unchanged
	Variable left, right, bottom, top, zNear, zFar
	String opName="ortho0"
	if( !GetGizmoOrtho(gizmoName, left, right, bottom, top, zNear, zFar,opName=opName) )
		ComputeNewOrthoForWindow(gizmoName, left, right, bottom, top, zNear, zFar, opName)
	endif

	SetGizmoAspectRatio(gizmoName, NaN ,keepCentralBoxSquare=1)	// this installs the resize and transformation hook

	// Clean up the display list, removing only items we're controlling
	// TO DO: These need better (more pie-like) names
	String items="ortho0;clearColor0;enable0;translateLegend;scaleLegend;legend;MainTransform;light1;blendFunc0;"
	// and "gradientQuad;legend; and pieWedge*, but we'll remove the objects which also deletes them from the display list
	String displayList= RemoveMatchingGizmoDisplay(gizmoName, items)
	
	// clean up the object list, except light1 (don't delete the Packages group!)
	items= "gradientQuad;legend;"
	RemoveMatchingGizmoObjects(gizmoName,items)
	String objectsList= RemoveMatchingGizmoObjects(gizmoName,"pieWedge*")

	// clean up the attribute list (deleting an attribute apparently doesn't delete from the display list?)
	String attributesList= RemoveMatchingGizmoAttributes(gizmoName,"blendFunc0;")
		
	// Set up the default lighting, blending, and transforms
	// For a new 3D pie chart, this is where many of the things we were removing above are first created.
	
	ModifyGizmo/N=$gizmoName autoscaling=0
	ModifyGizmo/N=$gizmoName compile

	if( !NameIsInGizmoObjectList(gizmoName,"light1") )	// only if "light1" doesn't already exist
		AppendToGizmo/N=$gizmoName light=Directional,name=light1
		ModifyGizmo/N=$gizmoName modifyObject=light1,objectType=light,property={ position,0.328125,0.377273,0.866025,0.000000}
		ModifyGizmo/N=$gizmoName modifyObject=light1,objectType=light,property={ direction,0.328125,0.377273,0.866025}
		
		// provide ambient light for the legend
		ModifyGizmo/N=$gizmoName modifyObject=light1,objectType=light,property={ ambient,0.800000,0.800000,0.800000,1.000000}
		ModifyGizmo/N=$gizmoName modifyObject=light1,objectType=light,property={ specular,1.000000,1.000000,1.000000,1.000000}
		ModifyGizmo/N=$gizmoName modifyObject=light1,objectType=light,property={ diffuse,0.200000,0.200000,0.200000,1.000000}
	endif
	
	// restore ortho
	ModifyGizmo/N=$gizmoName insertDisplayList=0, opName=$opName, operation=ortho, data={left, right, bottom, top, zNear, zFar}

	AppendToGizmo/N=$gizmoName attribute blendFunc={770,771},name=blendFunc0
	ModifyGizmo/N=$gizmoName insertDisplayList=-1, opName=enable0, operation=enable, data=3042
	ModifyGizmo/N=$gizmoName insertDisplayList=-1, attribute=blendFunc0

	ModifyGizmo/N=$gizmoName insertDisplayList=-1, object=light1
		
	// Remove old Igor 6 legends
	RemoveMatchingGizmoDisplay(gizmoName,"*legend")

	// Pie Wedges
	ModifyGizmo/N=$gizmoName insertDisplayList=-1, opName=MainTransform, operation=mainTransform

	UpdateGizmo3DPieChartBackground(gizmoName)


	SetDataFolder oldDF
End


Function/S ShowGizmo3DPieChartPanel()

	Variable createPanel= 1
	
	DoWindow Gizmo3DPieChartPanel
	if( V_Flag )	// exists, may be old
		ControlInfo/W=Gizmo3DPieChartPanel markerCheck	// the most recently designed control.
		if( V_Value != 0 )
			createPanel= 0	// has most recent control, just update
			DoWindow/F Gizmo3DPieChartPanel
		endif
	endif
	if(createPanel)
		DoWindow/K Gizmo3DPieChartPanel
		NewPanel/K=1/W=(497,49,785,622)/N=Gizmo3DPieChartPanel as "3D Pie Chart"
		ModifyPanel fixedSize=1, noEdit=1
		DefaultGuiFont/W=Gizmo3DPieChartPanel,popup={"_IgorSmall",0,0}
		// create the controls

		// Numeric Data
		TitleBox numericTitle,pos={6,10},size={60,12},title="Numeric Data",frame=0, fsize=10
		ListBox numericData,pos={74,4},size={194,90}
		String listOptions= "TEXT:0,CMPLX:0,DIMS:1,MAXROWS:1000"	// see WaveList
		MakeListIntoWaveSelector("Gizmo3DPieChartPanel", "numericData", content= WMWS_Waves, selectionMode= WMWS_SelectionSingle, listOptions=listOptions)
		WS_SetNotificationProc("Gizmo3DPieChartPanel", "numericData", "Gizmo3DPieChart#WS_DataNotificationProc")

		// Legend
		GroupBox legendGroup,pos={12,102},size={266,160},title="    Legend Text"

		CheckBox drawLegendCheck,pos={27,102},size={13,13},title=""
		CheckBox drawLegendCheck,proc= Gizmo3DPieChart#LegendCheckProc

		SetVariable textData,pos={75,125}, size={180,18}, noedit=1, title="Text Wave"
		Variable options=0 // not PopupWS_OptionFloat
		String/G $TempDFVar("textWaveName")

		MakeSetVarIntoWSPopupButton("Gizmo3DPieChartPanel", "textData", "Gizmo3DPieChart#PWS_TextNotificationProc", TempDFVar("textWaveName"), options=options, content= WMWS_Waves)

		listOptions= "TEXT:1,CMPLX:0,DIMS:1,MAXROWS:1000"	// see WaveList
		PopupWS_MatchOptions("Gizmo3DPieChartPanel", "textData" , listoptions=listOptions)

		// Legend Font
		PopupMenu fontName,pos={75,147},size={149,19},proc=Gizmo3DPieChart#FontNamePopMenuProc,title="Font"
		PopupMenu fontName,value= #"Gizmo3DPieChart#GizmoFontList()"

		// Legend Marker
		CheckBox markerCheck,pos={79,171},size={94,15},proc=Gizmo3DPieChart#WantLegendMarkerCheckProc,title="Legend Marker"
		CheckBox markerCheck,value= 1
	
		PopupMenu legendMarker,pos={184,169},size={50,19},proc=Gizmo3DPieChart#LegendMarkerPopMenuProc
		PopupMenu legendMarker,mode=18,value= #"\"*MARKERPOP*\""

		CheckBox legendColorCheck,pos={79,190},size={81,15},proc=Gizmo3DPieChart#ColoredLegendTextCheckProc,title="Colored Text"
		CheckBox legendColorCheck,value= 1

		// Legend position		
		TitleBox legendTopTitle,pos={17,168},size={20,15},title="Top",frame=0
		Slider LegendTop,pos={36,122},size={28,100},proc=Gizmo3DPieChart#LegendPosliderProc
		Slider LegendTop,limits={-2,2,0},side= 1,ticks= -10, value=1.9

		TitleBox legendLeftTitle,pos={75,214},size={20,15},title="Left",frame=0
		Slider legendLeft,pos={19,231},size={120,28},proc=Gizmo3DPieChart#LegendPosliderProc
		Slider legendLeft,limits={-2,2,0},vert= 0,ticks= -10, value=-1.9
		
		TitleBox legendSizeTitle,pos={200,214},size={20,15},title="Size",frame=0
		Slider legendSize,pos={151,231},size={120,28},proc=Gizmo3DPieChart#LegendSizeSliderProc
		Slider legendSize,limits={-0.5,0.5,0},vert=0,ticks= -10, value=0
		
		// Background
		GroupBox backgroundGroup,pos={12,265},size={266,103},title="Background"

		PopupMenu backgroundColorPop,pos={28,286},size={112,19},title="Fixed Color",value= #"\"*COLORPOP*\""
		PopupMenu backgroundColorPop,proc= Gizmo3DPieChart#BkgColorPopMenuProc

		CheckBox gradientColorCheck,pos={25,312},size={13,13},proc=Gizmo3DPieChart#GradientOnOffCheckProc,title=""

		PopupMenu gradientShape,pos={44,310},size={110,19}, proc=Gizmo3DPieChart#GradientShapePopMenuProc
		PopupMenu gradientShape,mode=1,bodyWidth= 110,popvalue="Vertical",value= #"Gizmo3dPieChart#GradientShapes()"

		PopupMenu gradientColor,pos={160,310},size={98,19},proc=Gizmo3DPieChart#GradientColorPopMenuProc, title="Gradient"
		PopupMenu gradientColor,value= #"\"*COLORPOP*\""

		CheckBox gradientReverse,pos={44,334},size={140,15},proc=Gizmo3DPieChart#GradientColorsCheckProc,title="Reverse Gradient Colors"
		
		CheckBox gradientReturn,pos={44,350},size={139,14},proc=Gizmo3DPieChart#GradientColorsCheckProc,title="Return to Background Color"

		// Wedges
		GroupBox wedgeGroup,pos={12,369},size={266,176},title="Wedges"

		CheckBox clockwise,pos={25,386},size={68,15},proc=Gizmo3DPieChart#ClockwiseCheckProc,title="Clockwise"
		
		SetVariable totalPct,pos={114,386},size={136,18},title="Wedges Total (%)"
		SetVariable totalPct,limits={0,100,0},bodyWidth= 40,proc= Gizmo3DPieChart#SetVarProc

		CheckBox sideColorCheck,pos={25,406},size={13,13},title="",proc= Gizmo3DPieChart#CheckProc

		PopupMenu sideColorPop,pos={45,405},size={142,19},title="Fixed Sides Color",value= #"\"*COLORPOP*\""
		PopupMenu sideColorPop,proc= Gizmo3DPieChart#SideColorPopMenuProc

		SetVariable thickness,pos={18,426},size={106,18},proc=Gizmo3DPieChart#SetVarProc,title="Thickness"
		SetVariable thickness,format="%.2f",limits={0,3,0.1},bodyWidth= 50

		SetVariable opacity,pos={146,426},size={112,15},size={119,18},title="Opacity (%):"
		SetVariable opacity,limits={5,100,5},bodyWidth= 50
		SetVariable opacity,proc= Gizmo3DPieChart#SetVarProc
		
		// Offset sub-group 
		GroupBox offsetGroup,pos={70,449},size={200,64}

		CheckBox offsetAllCheck,pos={78,453},size={109,15},title="Offset All Wedges",mode=1
		CheckBox offsetAllCheck,proc= Gizmo3DPieChart#OffsetRadioProc

		CheckBox offsetOneCheck,pos={78,473},size={13,13},title="",mode=1
		CheckBox offsetOneCheck,proc= Gizmo3DPieChart#OffsetRadioProc

		SetVariable explodingWedgeNum,pos={96,470},size={156,18},title="Offset Only Wedge #"
		SetVariable explodingWedgeNum,limits={0,inf,1}, proc=Gizmo3DPieChart#WedgeNumSetVarProc

		SetVariable wedgeOffset,pos={92,491},size={86,18},proc=Gizmo3DPieChart#WedgeOffsetSetVarProc,title="Offset"
		SetVariable wedgeOffset,limits={0,1,0.01},bodyWidth= 50,help={"Adjusts offset of all wedges or only the indicated wedge"}
		
		// Wedge Center Sliders
		
		TitleBox pieCenterY0Title,pos={17,484},size={13,15},title="Y0",frame=0
		Slider wedgesY0,pos={34,448},size={28,85},proc=Gizmo3DPieChart#WedgesCenterPosSliderProc
		Slider wedgesY0,limits={2,-2,0.01},value= 0,ticks= -3

		TitleBox pieCenterX0Title,pos={78,515},size={51,15},title="Center X0",frame=0
		Slider wedgesX0,pos={132,514},size={137,28},proc=Gizmo3DPieChart#WedgesCenterPosSliderProc
		Slider wedgesX0,limits={2,-2,0.01},value= 0,vert= 0,ticks= -3
		
		// Delay Updates and buttons

		CheckBox delayUpdates,pos={12,554},size={119,15},proc=Gizmo3DPieChart#DelayUpdatesCheckProc,title="Delay Auto Updates"

		Button gizmoInfo,pos={138,552},size={80,20},proc=Gizmo3DPieChart#GizmoInfoButtonProc,title="Gizmo Info"

		Button help,pos={228,552},size={50,20},proc=Gizmo3DPieChart#HelpButtonProc,title="Help"

		// Update if from the top Gizmo 3D Pie Chart (if any) when activated
		// If not a 3D pie chart, the controls will be disabled there
		SetWindow Gizmo3DPieChartPanel hook=Gizmo3DPieChart#Gizmo3DPieChartPanelHook
		Variable is3DPieChart= UpdateGizmo3DPieChartPanel() // we're already activated, update for the top chart manually
		if( is3DPieChart )
			String win= TopGizmo()
			AutoPositionWindow/M=0/R=$win Gizmo3DPieChartPanel
		endif
	endif
	
	return "Gizmo3DPieChartPanel"
End


Static Function/S TextWaveList()
	
	String str=WaveList("*",";","DIMS:1,TEXT:1")
	if(strlen(str)<=0)
		str="_none_"
	endif
	return str
End

Static Function ShowHint(msg)
	String msg
	
	if( strlen(msg) )
		TitleBox newHint,pos={1,42},size={68,24},win=Gizmo3DPieChartPanel,disable=2,title="\\JR\\K(65535,0,0)"+msg,frame=0,fsize=10
	else
		KillControl/W=Gizmo3DPieChartPanel newHint
	endif
End

// returns truth that the top gizmo is a 3D pie chart
// IMPORTANT: This routine CREATES many of the control global variables
//				 that are later consulted to update the 3D pie chart.
Static Function UpdateGizmo3DPieChartPanel()
	DoWindow Gizmo3DPieChartPanel
	if( V_Flag == 0 )
		return 0
	endif

	String allControls= ControlNameList("Gizmo3DPieChartPanel", ";", "*")
	String gizmoName= TopGizmo()
	Variable is3DPieChart= GizmoIs3DPieChart(gizmoName)
	if( !is3DPieChart )
		// not a 3d pie chart gizmo: disable all controls EXCEPT numeric data
		allControls= RemoveFromList("numericData;help;gizmoInfo", allControls)	// can't disable a list
		ModifyControlList/Z allControls, win=Gizmo3DPieChartPanel, disable=2	
//		ListBox textData win=Gizmo3DPieChartPanel, disable=1 // list boxes don't disable well (they show "E1"), so just hide it.
//		GroupBox disabledTextData,win=Gizmo3DPieChartPanel,pos={74,119},size={194,90},frame=0

		ShowHint("Select Numeric\rData to start.")
		//Checkbox clockwise,win=Gizmo3DPieChartPanel, value=0	// NOPE: this also resets the global variable the control was attached to!
		Variable/G $TempDFVar("zero")= 0
		Checkbox clockwise,win=Gizmo3DPieChartPanel, variable=$TempDFVar("zero")
		CheckBox delayUpdates,win=Gizmo3DPieChartPanel, variable=$TempDFVar("zero")
		Checkbox gradientColorCheck,win=Gizmo3DPieChartPanel, variable=$TempDFVar("zero")
		Checkbox gradientReverse,win=Gizmo3DPieChartPanel, variable=$TempDFVar("zero")
		Checkbox gradientReturn,win=Gizmo3DPieChartPanel, variable=$TempDFVar("zero")
		Checkbox sideColorCheck,win=Gizmo3DPieChartPanel, variable=$TempDFVar("zero")
		SetVariable opacity,win=Gizmo3DPieChartPanel, value=$TempDFVar("zero")
		SetVariable thickness,win=Gizmo3DPieChartPanel, value=$TempDFVar("zero")
		SetVariable explodingWedgeNum,win=Gizmo3DPieChartPanel, value=$TempDFVar("zero")
		SetVariable totalPct,win=Gizmo3DPieChartPanel, value=$TempDFVar("zero")
		SetVariable wedgeOffset,win=Gizmo3DPieChartPanel, value=$TempDFVar("zero")
		// LEGEND
		Checkbox drawLegendCheck,win=Gizmo3DPieChartPanel, variable=$TempDFVar("zero")
		CheckBox markerCheck,win=Gizmo3DPieChartPanel, variable=$TempDFVar("zero")
		CheckBox legendColorCheck,win=Gizmo3DPieChartPanel, variable=$TempDFVar("zero")
	else
		KillControl/W=Gizmo3DPieChartPanel disabledTextData

		ModifyControlList/Z allControls, win=Gizmo3DPieChartPanel, disable=0

  		// Save the gizmo name in the corresponding data folder
  		String/G $GizmoDFVar(gizmoName,"gizmoName") = gizmoName

		UpdateHookFunction(gizmoName, "Gizmo3DPieChart", "WMGizmo3DPieChartNamedHook", "WMGizmo3DPieChartHook")

		// transfer from globals (or defaults) to controls
		
		// NUMERIC DATA
		
		String waves= WaveList("*",";","DIMS:1,TEXT:0")+"_none_;"	// waves in current data folder
		String def= StringFromList(0,waves)
		WAVE/Z dw= $def
		if( WaveExists(dw) )
			def= GetWavesDataFolder(dw,2)	// full path
		else
			def=""
		endif
		String path= StrVarOrDefault(GizmoDFVar(gizmoName,"dataWave"),def)
		String/G $GizmoDFVar(gizmoName,"dataWave") = path
		WS_ClearSelection("Gizmo3DPieChartPanel", "numericData")
		WS_SelectObjectList("Gizmo3DPieChartPanel", "numericData", path)

		if( GizmoIsDisplayingNumericData() )
			ShowHint("")
		else
			ShowHint("Select Numeric\rData to start.")
		endif

		// LEGEND

		Variable/G $GizmoDFVar(gizmoName,"drawLegend")	// default unchecked
		CheckBox drawLegendCheck,win=Gizmo3DPieChartPanel, variable=$GizmoDFVar(gizmoName,"drawLegend")
		
		// Legend Text wave
		waves= TextWaveList()	// text waves in current data folder
		def= StringFromList(0,waves)
		WAVE/Z tw= $def
		if( WaveExists(tw) )
			def= GetWavesDataFolder(tw,2)	// full path
		else
			def= ""
		endif
		path= StrVarOrDefault(GizmoDFVar(gizmoName,"textWave"),def)
		String/G $GizmoDFVar(gizmoName,"textWave") = path// full path
		PopupWS_SetSelectionFullPath("Gizmo3DPieChartPanel", "textData", path)

		// want markers in legend?
		Variable checked= NumVarOrDefault(GizmoDFVar(gizmoName,"wantLegendMarker"),1)	// default checked
		Variable/G $GizmoDFVar(gizmoName,"wantLegendMarker")= checked
		CheckBox markerCheck,win=Gizmo3DPieChartPanel, variable=$GizmoDFVar(gizmoName,"wantLegendMarker")

		// Marker Pop
		Variable legendMarkerMode = NumVarOrDefault(GizmoDFVar(gizmoName,"legendMarker"),18)
		Variable/G $GizmoDFVar(gizmoName,"legendMarker")= legendMarkerMode
		PopupMenu legendMarker, mode=legendMarkerMode

		// want colored text in legend?
		Variable/G $GizmoDFVar(gizmoName,"coloredLegendText")	// default unchecked
		CheckBox legendColorCheck,win=Gizmo3DPieChartPanel, variable=$GizmoDFVar(gizmoName,"coloredLegendText")

		// Legend Font: Only scalable fonts
		String fonts=GizmoFontList()
		String str= StrVarOrDefault(GizmoDFVar(gizmoName,"fontName"),"Times New Roman")
		Variable md=max(1,1+WhichListItem(str, fonts))
		str= StringFromList(md-1,fonts)	// handles case where the font is now gone.
		PopupMenu fontName,mode=md, popvalue=str
		String/G $GizmoDFVar(gizmoName,"fontName") = str
		
		Variable legendScale= NumVarOrDefault(GizmoDFVar(gizmoName,"legendScale"), 0.25)
		Variable sliderValue= LegendSliderValueForLegendScale(legendScale)
		Slider legendSize,win=Gizmo3DPieChartPanel,value=sliderValue

		SetControlsForOrtho(gizmoName)

		// BACKGROUND
		
		// Fixed Color
		Variable red= NumVarOrDefault(GizmoDFVar(gizmoName,"bkgRed"), 65535)	// default white
		Variable green= NumVarOrDefault(GizmoDFVar(gizmoName,"bkgGreen"), 65535)
		Variable blue= NumVarOrDefault(GizmoDFVar(gizmoName,"bkgBlue"), 65535)
		PopupMenu backgroundColorPop,win=Gizmo3DPieChartPanel, popColor=(red,green,blue)
		Variable/G $GizmoDFVar(gizmoName,"bkgRed")= red
		Variable/G $GizmoDFVar(gizmoName,"bkgGreen")= green
		Variable/G $GizmoDFVar(gizmoName,"bkgBlue")= blue
		// The popup's proc sets GizmoDFVar(gizmoName,"bkgRed"), etc.

		Variable/G $GizmoDFVar(gizmoName,"gradientChecked")	// default unchecked
		CheckBox gradientColorCheck, win=Gizmo3DPieChartPanel, variable=$GizmoDFVar(gizmoName,"gradientChecked")

		String shape= StrVarOrDefault(GizmoDFVar(gizmoName,"gradientShape"), "Vertical")
		Variable mode= max(1,1+WhichListItem(shape, GradientShapes()))
		PopupMenu gradientShape,win=Gizmo3DPieChartPanel, popvalue=shape, mode=mode

		red= NumVarOrDefault(GizmoDFVar(gizmoName,"gradientColorRed"), 0)
		green= NumVarOrDefault(GizmoDFVar(gizmoName,"gradientColorGreen"), 0)
		blue= NumVarOrDefault(GizmoDFVar(gizmoName,"gradientColorBlue"), 0)
		PopupMenu gradientColor,win=Gizmo3DPieChartPanel, popColor=(red,green,blue)
		Variable/G $GizmoDFVar(gizmoName,"gradientColorRed")= red
		Variable/G $GizmoDFVar(gizmoName,"gradientColorGreen")= green
		Variable/G $GizmoDFVar(gizmoName,"gradientColorBlue")= blue

		// Reverse Gradient
		Variable/G $GizmoDFVar(gizmoName,"gradientReverse")	// default unchecked
		CheckBox gradientReverse,win=Gizmo3DPieChartPanel, variable=$GizmoDFVar(gizmoName,"gradientReverse")
	
		// Return  Gradient to Background Color
		Variable/G $GizmoDFVar(gizmoName,"gradientReturn")	// default unchecked
		CheckBox gradientReturn,win=Gizmo3DPieChartPanel, variable=$GizmoDFVar(gizmoName,"gradientReturn")
		
		EnableDisableGradientReturn()	// Return  Gradient to Background Color works only if the shape is diagonal
	
		// WEDGES
		Variable/G $GizmoDFVar(gizmoName,"clockwise")	// default unchecked
		CheckBox clockwise,win=Gizmo3DPieChartPanel, variable=$GizmoDFVar(gizmoName,"clockwise")
		
		Variable total=NumVarOrDefault(GizmoDFVar(gizmoName,"totalPct"), 100)// default 100
		Variable/G $GizmoDFVar(gizmoName,"totalPct")= total	
		SetVariable totalPct,win=Gizmo3DPieChartPanel, value=$GizmoDFVar(gizmoName,"totalPct")

		Variable/G $GizmoDFVar(gizmoName,"fixedSidesColor")	// default unchecked
		CheckBox sideColorCheck,win=Gizmo3DPieChartPanel, variable=$GizmoDFVar(gizmoName,"fixedSidesColor")

		red= NumVarOrDefault(GizmoDFVar(gizmoName,"sideRed"), 0)
		green= NumVarOrDefault(GizmoDFVar(gizmoName,"sideGreen"), 0)
		blue= NumVarOrDefault(GizmoDFVar(gizmoName,"sideBlue"), 0)
		PopupMenu sideColorPop,win=Gizmo3DPieChartPanel, popColor=(red,green,blue)
		Variable/G $GizmoDFVar(gizmoName,"sideRed")= red
		Variable/G $GizmoDFVar(gizmoName,"sideGreen")= green
		Variable/G $GizmoDFVar(gizmoName,"sideBlue")= blue
		// The popup's proc must set GizmoDFVar(gizmoName,"sideRed"), etc.

		Variable num=NumVarOrDefault(GizmoDFVar(gizmoName,"thickness"), 0.5)
		Variable/G $GizmoDFVar(gizmoName,"thickness")= num
		SetVariable thickness,win=Gizmo3DPieChartPanel, value=$GizmoDFVar(gizmoName,"thickness")

		num=NumVarOrDefault(GizmoDFVar(gizmoName,"opacity"), 100)
		Variable/G $GizmoDFVar(gizmoName,"opacity")= num
		SetVariable opacity,win=Gizmo3DPieChartPanel, value=$GizmoDFVar(gizmoName,"opacity")

		// WEDGE OFFSETS
		
		Variable offsetAll=NumVarOrDefault(GizmoDFVar(gizmoName,"offsetAllWedges"), 1)// default checked
		Variable/G $GizmoDFVar(gizmoName,"offsetAllWedges")= offsetAll
		CheckBox offsetAllCheck,win=Gizmo3DPieChartPanel,value=offsetAll
		CheckBox offsetOneCheck,win=Gizmo3DPieChartPanel,value= 1-offsetAll

		Variable/G $GizmoDFVar(gizmoName,"explodingWedgeNum")	// default wedgenum= 0
		NVAR explodingWedgeNum= $GizmoDFVar(gizmoName,"explodingWedgeNum")
		SetVariable explodingWedgeNum,win=Gizmo3DPieChartPanel, value=$GizmoDFVar(gizmoName,"explodingWedgeNum")

		WAVE/Z wOffsets= $GizmoDFVar(gizmoName,"offsets")
		Variable/G $GizmoDFVar(gizmoName,"gOffset")	// default global offset=0
		NVAR gOffset=$GizmoDFVar(gizmoName,"gOffset")

		Variable offset
		if( offsetAll )
			offset= gOffset
		elseif( WaveExists(wOffsets) )
			offset= wOffsets[explodingWedgeNum]
		else
			offset=0	// BUG
		endif
		
		Variable/G $GizmoDFVar(gizmoName,"wedgeoffset")= offset
		SetVariable wedgeOffset,win=Gizmo3DPieChartPanel,value=$GizmoDFVar(gizmoName,"wedgeoffset")
		
		// WEDGE CENTER
		Variable/G $GizmoDFVar(gizmoName,"wedgesY0")	// default wedgesY0= 0
		NVAR wedgesY0=$GizmoDFVar(gizmoName,"wedgesY0")
		Slider wedgesY0, win=Gizmo3DPieChartPanel,value=wedgesY0
		
		Variable/G $GizmoDFVar(gizmoName,"wedgesX0")	// default wedgesX0= 0
		NVAR wedgesX0=$GizmoDFVar(gizmoName,"wedgesX0")
		Slider wedgesX0, win=Gizmo3DPieChartPanel,value=wedgesX0
		
		// Delay Auto Updates
		Variable/G $GizmoDFVar(gizmoName,"delayUpdates")	// default unchecked
		CheckBox delayUpdates, win=Gizmo3DPieChartPanel, variable=$GizmoDFVar(gizmoName,"delayUpdates")

	endif
	return is3DPieChart
End

Static Function/S GradientShapes()
	return "Vertical;Horizontal;Diagonal -45;Diagonal +45;"
End

// called whenever either the data or any setting changes
// Make this work without ANY ControlInfo/W=Gizmo3DPieChartPanel,
// and check for panel exists before any <control> <name> win=Gizmo3DPieChartPanel
Static Function UpdateGizmo3DPieChart(gizmoName)
	String gizmoName
	
	Variable is3DPieChart= GizmoIs3DPieChart(gizmoName)
	if( !is3DPieChart )
		// top gizmo is not a 3D pie chart, we so create one.
		gizmoName= NewGizmo3DPieChart()
		UpdateGizmo3DPieChart(gizmoName)	// NOTE: CALLING SELF!
		ShowHint("")
		return 1
	endif
	
	if( !ValidGizmoName(gizmoName) )
		return 0
	endif

	SetGizmoCurrentGroup(gizmoName, "")	// in case something went wrong previously while not the root group
	
	// check for GizmoDF(gizmoName) data folder existence, else the rest of this routine dies
	String df= GizmoDF(gizmoName)
	if( strlen(df) == 0 )
		return 0
	endif

	DoWindow Gizmo3DPieChartPanel
	Variable havePanel= V_Flag

	// create wedges from data
	String dwPath= StrVarOrDefault(GizmoDFVar(gizmoName,"dataWave"),"")	// path to wave
	Wave/Z dw=$dwPath
	if(WaveExists(dw))
	
		String oldDF= SetTempDF()

		Variable numWedges=numpnts(dw)
		
		// limit the wedge number to a valid number
		NVAR/Z wedgeID= $GizmoDFVar(gizmoName,"explodingWedgeNum")
		if( NVAR_Exists(wedgeID) )
			if( wedgeID >= numWedges )
				wedgeID=numWedges-1
			endif
		endif
		
		if( havePanel )
			// Make the SetVariable's max value= numWedges-1
			SetVariable explodingWedgeNum,win=Gizmo3DPieChartPanel,limits={0,numWedges-1,1}
		endif
		
		// Maintain a wave of offsets parallel to the data wave
		
		Make/O/N=(numWedges) $GizmoDFVar(gizmoName,"offsets")	// initially 0, this redimensions an existing wave without resetting the values.
		
		// check if we want to waste time on legend:
		Variable isLegendRequested= NumVarOrDefault(GizmoDFVar(gizmoName,"drawLegend"),0)
		if(isLegendRequested)
			String twPath=StrVarOrDefault(GizmoDFVar(gizmoName,"textWave"),"")	// path to wave
			WAVE/T/Z tw=$twPath
		endif
		
		// Start the Gizmo over, resets the background color, too
		ResetGizmo3DPieChart(gizmoName)
		
		// Add the wedges
		Variable total=sum(dw,-inf,inf)
		
		// adjust the total so that the sum of all the angles is GizmoDFVar(gizmoName,"totalPct")
		Variable totalPct= NumVarOrDefault(GizmoDFVar(gizmoName,"totalPct"), 100)
		total /= (totalPct/100)		
		
		Variable alpha= NumVarOrDefault(GizmoDFVar(gizmoName,"opacity"), 100) / 100
		alpha=max(alpha,0.05)	// not invisible
		alpha=min(alpha,1)	// don't confuse gizmo

		WAVE wOffsets=$GizmoDFVar(gizmoName,"offsets")
		Variable clockwise= NumVarOrDefault(GizmoDFVar(gizmoName,"clockwise"),0)
		Variable thickness= NumVarOrDefault(GizmoDFVar(gizmoName,"thickness"),0)
		Variable calcNormals= 1

		Variable i,startAngle,endAngle
		for( i=0,startAngle=0,endAngle=360; i<numWedges; i+=1 )
			if( clockwise )
				startAngle=endAngle-360*dw[i]/total
			else
				endAngle=startAngle+360*dw[i]/total
			endif

			Variable rt,gt,bt	// top color
			WM_GetDistinctColor(i,numWedges,rt,gt,bt,0)	// gizmo colors (0-1)

			Variable rs,gs,bs	// side color
			Variable fixedSidesColor= NumVarOrDefault(GizmoDFVar(gizmoName,"fixedSidesColor"),0)
			if(fixedSidesColor)
				rs= NumVarOrDefault(GizmoDFVar(gizmoName,"sideRed"), 0)/ 65535 // convert from Mac colors to OpenGL colors.
				gs= NumVarOrDefault(GizmoDFVar(gizmoName,"sideGreen"), 0)/ 65535	
				bs= NumVarOrDefault(GizmoDFVar(gizmoName,"sideBlue"), 0)/ 65535	
			else
				rs=0.8*rt// side color default
				gs=0.8*gt
				bs=0.8*bt
			endif

			Variable offset= wOffsets[i]
			Append3DPieWedge(gizmoName,WedgeName(gizmoName,i),i,numWedges,startAngle,endAngle,thickness,offset,calcNormals,alpha,rt,gt,bt,rs,gs,bs)
			if( clockwise )
				endAngle = startAngle
			else
				startAngle=endAngle
			endif
		endfor
		if( isLegendRequested )
			UpdateGizmo3DPieChartLegend(gizmoName)
		endif
		ModifyGizmo/N=$gizmoName compile
		
		SetUpDependency(gizmoName, dw, tw)
		SetDataFolder oldDF
	endif
End

// TO DO: Add "shadow" wedge.
Static Function Append3DPieWedge(gizmoName,theName,index,numWedges,startAngle,endAngle,thick,offset, calcNormals, alpha, rt,gt,bt,rs,gs,bs)
	String gizmoName
	String theName
	Variable index,numWedges,startAngle,endAngle
	Variable thick	// total thickness
	Variable offset
	Variable calcNormals
	Variable alpha		// wedge transparency (1= opaque)
	Variable rt,gt,bt	// top color
	Variable rs,gs,bs	// side color
	
	if( !ValidGizmoName(gizmoName) )
		return 0
	endif
	
	AppendToGizmo/N=$gizmoName/D pieWedge=$theName
	
	ModifyGizmo/N=$gizmoName ModifyObject=$theName,objectType=pieWedge, property={ rMin, 0}
	ModifyGizmo/N=$gizmoName ModifyObject=$theName,objectType=pieWedge, property={ rMax, 1}
	ModifyGizmo/N=$gizmoName ModifyObject=$theName,objectType=pieWedge, property={ zMin, -thick/2} // this apparently doesn't work: it comes out 0
	ModifyGizmo/N=$gizmoName ModifyObject=$theName,objectType=pieWedge, property={ zMax, thick/2}
	ModifyGizmo/N=$gizmoName ModifyObject=$theName,objectType=pieWedge, property={ startAngle, startAngle}
	ModifyGizmo/N=$gizmoName ModifyObject=$theName,objectType=pieWedge, property={ endAngle, endAngle}
	ModifyGizmo/N=$gizmoName ModifyObject=$theName,objectType=pieWedge, property={ radialOffset, offset}
	ModifyGizmo/N=$gizmoName ModifyObject=$theName,objectType=pieWedge, property={ calcNormals, calcNormals}
	ModifyGizmo/N=$gizmoName ModifyObject=$theName,objectType=pieWedge, property={ colorMode, 2}
	
	Variable slices= round((endAngle-startAngle) / kDegreesPerFace)
	slices= max(slices,4)

	ModifyGizmo/N=$gizmoName ModifyObject=$theName,objectType=pieWedge, property={ slices, slices}
	ModifyGizmo/N=$gizmoName ModifyObject=$theName,objectType=pieWedge, property={ topRGBA, rt,gt,bt,alpha}
	ModifyGizmo/N=$gizmoName ModifyObject=$theName,objectType=pieWedge, property={ sidesRGBA, rs,gs,bs,alpha}
End

static Function UpdateGizmo3DPieChartLegend(gizmoName)
	String gizmoName

	if( !ValidGizmoName(gizmoName))
		return 0
	endif

	Variable isLegendRequested= NumVarOrDefault(GizmoDFVar(gizmoName,"drawLegend"),0)

	String dwPath= StrVarOrDefault(GizmoDFVar(gizmoName,"dataWave"),"")	// path to wave
	Wave/Z dw=$dwPath

	String twPath=StrVarOrDefault(GizmoDFVar(gizmoName,"textWave"),"")	// path to wave
	WAVE/T/Z textWave=$twPath

	if(!isLegendRequested || !WaveExists(textWave) || numpnts(textWave) == 0 )
		Textbox/W=$gizmoName/K/N=$ks3DPieLegend
		return 0
	endif	

	Variable numWedges=numpnts(dw)
	Variable numLabels=numpnts(textWave)
		
	String fontName= StrVarOrDefault(GizmoDFVar(gizmoName,"fontName"),"Times New Roman")
	Variable legendScale= NumVarOrDefault(GizmoDFVar(gizmoName,"legendScale"),0.25)
	Variable fontSize=48*legendScale

	String font
	sprintf font, "\\F'%s'\\Z%02d", fontName, fontSize

	// convert Igor 6 legend (ortho) values to textbox offsets (%)
	Variable legendLeft= NumVarOrDefault(GizmoDFVar(gizmoName,"legendLeft"), -1.9) // -2 to 2
	Variable legendTop= NumVarOrDefault(GizmoDFVar(gizmoName,"legendTop"), 1.9)

	Variable xPct= 25*legendLeft + 50	// -2 to +2 -> 0 -> 100
	Variable yPct= 25*(-legendTop) + 50

	TextBox/W=$gizmoName/C/N=$ks3DPieLegend/A=LT/X=(xPct)/Y=(yPct) font

	Variable wantLegendMarker = NumVarOrDefault(GizmoDFVar(gizmoName,"wantLegendMarker"),0)
	Variable legendMarker = NumVarOrDefault(GizmoDFVar(gizmoName,"legendMarker"),18)
	String marker= ""
	
	if( wantLegendMarker )
		sprintf marker, "\\W5%02d", legendMarker-1 	// mode=18 = marker 17, filled triangle
	endif

	Variable coloredLegendText= NumVarOrDefault(GizmoDFVar(gizmoName,"coloredLegendText"),1)

	Variable index,rr,gg,bb
	for( index=0; index<numWedges; index+=1 )
		String color=""
		if( wantLegendMarker || coloredLegendText )
			WM_GetDistinctColor(index,numWedges,rr,gg,bb,1) // 0...65535
			String rgb
			sprintf rgb, "(%d,%d,%d)", rr,gg,bb
			color="\\K"+rgb
			if( wantLegendMarker )
				color += "\\k"+rgb
			endif 
		endif
		String textColor=""
		if( !coloredLegendText && strlen(color) )
			textColor="\\K(0,0,0)"	// black
		endif
		
		String text = color
		if( wantLegendMarker )
			text += marker
		endif
		String labelText
		if( index < numLabels )
			labelText= textWave[index]
		else
			labelText=" "
		endif
		text += textColor+labelText
		AppendText/W=$gizmoName/N=$ks3DPieLegend/NOCR=(index==0) text
	endfor
	
	return 1
End


// obsolete
Static Function xAppend3DWedgeTextGroup(gizmoName,index,numWedges,textWave,fontName)
	String gizmoName
	Variable index,numWedges
	Wave/T/Z textWave
	String fontName

	Variable spacing= 1.0

	if( !ValidGizmoName(gizmoName) )
		return 0
	endif

	if(WaveExists(textWave) && index < DimSize(textWave,0) )
		String cmd

		// display the legend group object if it is not displayed
		Variable legendDisplayIndex= GetDisplayIndexOfNamedObject(gizmoName,"legend")
		if( legendDisplayIndex < 0 )
			// create the legend group object (only) if it is missing	
			if( !NameIsInGizmoObjectList(gizmoName,"legend") )
				Execute "AppendToGizmo/N="+gizmoName+" group,name=legend"
			endif
			legendDisplayIndex=1+ GetDisplayIndexOfNamedObject(gizmoName,"scaleLegend")	// scaleLegend is appended to Gizmo in Reset3DPieChart, which the legend object IS NOT
			sprintf cmd, "ModifyGizmo/N=%s insertDisplayList=%d, object=legend",gizmoName,legendDisplayIndex
	 		Execute cmd
		endif
		String oldGroupPath= SetGizmoCurrentGroup(gizmoName, "legend")

		String translateName="translate"+num2str(index)
		Variable displayIndex= 1+2*index
		if( index == 0 )
			// on the first index, initialize the main scaling
			Execute "ModifyGizmo/N="+gizmoName+" setDisplayList=0, opName=rotate0, operation=rotate, data={180,1,0,0}"	// otherwise the strings are all flipped!
		 	sprintf cmd "ModifyGizmo/N=%s setDisplayList=%d, opName=%s, operation=translate, data={0,%g,0}",gizmoName,displayIndex,translateName,spacing*0.79
			Execute cmd
		else
		 	sprintf cmd "ModifyGizmo/N=%s setDisplayList=%d, opName=%s, operation=translate, data={0,%g,0}",gizmoName,displayIndex,translateName,spacing
			Execute cmd
		endif
		
		String stringName="string"+num2str(index)
		String colorName="color"+num2str(index)
		
		sprintf cmd,"AppendToGizmo/N=%s string=\"%s\",strFont=\"%s\",name=%s",gizmoName,textWave[index],fontName, stringName
		Execute cmd
		sprintf cmd, "ModifyGizmo/N=%s setObjectAttribute={%s,%s}",gizmoName, stringName, colorName
		Execute cmd

		Variable rr,gg,bb
		WM_GetDistinctColor(index,numWedges,rr,gg,bb,0)
		sprintf cmd,"AppendToGizmo/N=%s attribute color={%g,%g,%g,1},name=%s",gizmoName,rr,gg,bb, colorName
		Execute cmd

	 	sprintf cmd, "ModifyGizmo/N=%s setDisplayList=%d, object=%s",gizmoName,1+displayIndex,stringName
	 	Execute cmd
		SetGizmoCurrentGroup(gizmoName, oldGroupPath)	// back to previous group
	endif
End

static Function GizmoIsDisplayingNumericData()
	
	String gizmoName= TopGizmo()
	String dataWedgeName= WedgeName(gizmoName,0)
	return NameIsInGizmoObjectList(gizmoName,dataWedgeName)
End
	
// ++++++++++++++++ Background routines +++++++++++++++++++++

Static Function UpdateGizmo3DPieChartBackground(gizmoName)
	String gizmoName

	if( !ValidGizmoName(gizmoName) )
		return 0
	endif

	if( !GizmoIs3DPieChart(gizmoName) )
		return 0
	endif
	
	// test for presence of clearColor0 in the display list
	String ctrlName	// either "gradientStart" or "gradientEnd"
	Variable popNum
	String popStr
	
	String oldDF= SetTempDF()

	Variable red, green, blue
	String cmd

//	Execute "ModifyGizmo/N="+gizmoName+" startRecMacro"	// too much flashing

	// either a background gradient or a fixed color
	red= NumVarOrDefault(GizmoDFVar(gizmoName,"bkgRed"), 65535) / 65535
	green= NumVarOrDefault(GizmoDFVar(gizmoName,"bkgGreen"), 65535) / 65535
	blue= NumVarOrDefault(GizmoDFVar(gizmoName,"bkgBlue"), 65535) / 65535
	if( NameIsInGizmoDisplayList(gizmoName,"clearColor0") )
		sprintf cmd,"ModifyGizmo/N=%s opName=clearColor0, operation=clearColor, data={%g,%g,%g,1}",gizmoName,red,green,blue
	else
		sprintf cmd,"ModifyGizmo/N=%s insertDisplayList=0, opName=clearColor0, operation=clearColor, data={%g,%g,%g,1}",gizmoName,red,green,blue
	endif
	Execute cmd
	
	Variable gradientChecked= NumVarOrDefault(GizmoDFVar(gizmoName,"gradientChecked"),0)
	if( gradientChecked )
		// Insert gradient background via quad with colored vertices
		String pop1, pop2
		Variable gradientReverse= NumVarOrDefault(GizmoDFVar(gizmoName,"gradientReverse"),0)
		if( gradientReverse )
			pop1= "gradientColor"
			pop2= "bkg"
		else
			pop1= "bkg"
			pop2= "gradientColor"
		endif

		red= NumVarOrDefault(GizmoDFVar(gizmoName, pop1+"Red"), 65535)	/ 65535	// default white
		green= NumVarOrDefault(GizmoDFVar(gizmoName, pop1+"Green"), 65535)	/ 65535
		blue= NumVarOrDefault(GizmoDFVar(gizmoName, pop1+"Blue"), 65535)	/ 65535

		Variable redEnd= NumVarOrDefault(GizmoDFVar(gizmoName, pop2+"Red"), 0)	/ 65535	// default black
		Variable greenEnd= NumVarOrDefault(GizmoDFVar(gizmoName, pop2+"Green"), 0)	/ 65535
		Variable blueEnd= NumVarOrDefault(GizmoDFVar(gizmoName, pop2+"Blue"), 0)	/ 65535

		Variable gradientIndex= 1 + GetDisplayIndexOfNamedObject(gizmoName,"light1")

		Variable gradientIsDisplayed= NameIsInGizmoDisplayList(gizmoName,"gradientQuad")
		Variable gradientExists= NameIsInGizmoObjectList(gizmoName,"gradientQuad")
		// create or update the a background quad

		Variable left, right, bottom, top, zNear, zFar
		GetGizmoOrtho(gizmoName, left, right, bottom, top, zNear, zFar)
		Variable zQuad= zNear + 0.1	// was -1, zNear is nominally -2, zQuad is nominally -1.9

		if( !gradientExists )
			Execute "AppendToGizmo/N="+gizmoName+" quad={-2,2,-1,2,2,-1,2,-2,-1,-2,-2,-1},name=gradientQuad"	// just to get it appended; we'll move it later.
			Execute "ModifyGizmo/N="+gizmoName+" ModifyObject=gradientQuad property={calcNormals,1}"
			Execute "ModifyGizmo/N="+gizmoName+" ModifyObject=gradientQuad property={ COLORTYPE,2}"
		endif

		// NOTE: only the diagonal gradients support "return to Background Color"	
		Variable returnToBkg= NumVarOrDefault(GizmoDFVar(gizmoName,"gradientReturn"),0)
		
		Variable redTL, redTR, redBR, redBL	// TopLeft, TopRight, BottomRight, BottomLeft = 0,1,2,3 indices
		Variable greenTL, greenTR, greenBR, greenBL
		Variable blueTL, blueTR, blueBR, blueBL
		
		Variable redHalf= 0.5 * (red + redEnd)
		Variable greenHalf= 0.5 * (green + greenEnd)
		Variable blueHalf= 0.5 * (blue + blueEnd)
		
		Variable quadCoordsSet=0

		String gradientShape= StrVarOrDefault(GizmoDFVar(gizmoName,"gradientShape"),"Vertical")
		strswitch( gradientShape )
			case "Vertical":
			default:
				redTL= red; redTR= red
				greenTL= green; greenTR= green
				blueTL=blue; blueTR=blue
				
				redBR= redEnd; redBL=redEnd
				greenBR= greenEnd; greenBL=greenEnd
				blueBR= blueEnd; blueBL= blueEnd
				break
			
			case "Horizontal":
				redTL= red; redBL= red
				greenTL= green; greenBL= green
				blueTL=blue; blueBL=blue
				
				redBR= redEnd; redTR=redEnd
				greenBR= greenEnd; greenTR=greenEnd
				blueBR= blueEnd; blueTR= blueEnd
				break
			case "Diagonal -45":
				if( returnToBkg )
					redTL= red; redBR= red
					greenTL= green; greenBR= green
					blueTL=blue; blueBR=blue
					
					redTR= redEnd; redBL=redEnd
					greenTR= greenEnd; greenBL=greenEnd
					blueTR= blueEnd; blueBL= blueEnd
				else
					redTL= red
					greenTL= green
					blueTL=blue

					redTR= redHalf
					greenTR= greenHalf
					blueTR=blueHalf
					
					redBR= redEnd
					greenBR= greenEnd
					blueBR= blueEnd

					redBL=redHalf
					greenBL=greenHalf
					blueBL= blueHalf
				endif
				break
				
			case "Diagonal +45":
				if( returnToBkg )
					// rotate the quad 90 degrees clockwise, so that the return works properly.
					// This changes the locations of the colors, too:
					// standard: Execute "ModifyGizmo ModifyObject=gradientQuad property={vertex,-2,2,-1,2,2,-1,2,-2,-1,-2,-2,-1}"
					// (starting at top/left going clockwise)
					// rotated is starting at the top/right and going clockwise
					// Execute "ModifyGizmo ModifyObject=gradientQuad property={vertex,2,2,-1,2,-2,-1,-2,-2,-1,-2,2,-1}"
					sprintf cmd, "ModifyGizmo/N=%s ModifyObject=gradientQuad property={vertex,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g}", gizmoName, right, top, zQuad, right, bottom, zQuad, left, bottom, zQuad, left, top, zQuad
					Execute cmd
					quadCoordsSet=1
					// 0 = TL is now top-right corner
					// set top-right corner to bkg color
					redTL= red
					greenTL= green
					blueTL=blue
					
					// 1 = TR is now bottom-right corner
					// set bottom-right corner to gradient color
					redTR= redEnd
					greenTR= greenEnd
					blueTR=blueEnd
					
					// 2 = BR is now bottom-left corner
					// set bottom-left corner to bkg color
					redBR= red
					greenBR= green
					blueBR= blue
					
					// 3 = BL is now top-left corner
					// set top-left corner to gradient color
					redBL=redEnd
					greenBL=greenEnd
					blueBL= blueEnd
				else
					redTL= redHalf
					greenTL= greenHalf
					blueTL=blueHalf

					redTR= redEnd
					greenTR= greenEnd
					blueTR=blueEnd
					
					redBR= redHalf
					greenBR= greenHalf
					blueBR= blueHalf

					redBL=red
					greenBL=green
					blueBL= blue
				endif
				break
		endswitch
		
		if( !quadCoordsSet )	// (not Diagonal +45 returnToBkg)
			// standard rotation is starting at top/left going clockwise:
			// Execute "ModifyGizmo ModifyObject=gradientQuad property={vertex,-2,2,-1,2,2,-1,2,-2,-1,-2,-2,-1}"
			sprintf cmd, "ModifyGizmo/N=%s ModifyObject=gradientQuad property={vertex,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g}", gizmoName, left, top, zQuad, right, top, zQuad, right, bottom, zQuad, left, bottom, zQuad
			Execute cmd
		endif
			
		sprintf cmd, "ModifyGizmo/N=%s ModifyObject=gradientQuad property={ COLORVALUE,0,%g,%g,%g,1}", gizmoName, redTL, greenTL, blueTL	// top left
	 	Execute cmd
	
		sprintf cmd, "ModifyGizmo/N=%s ModifyObject=gradientQuad property={ COLORVALUE,1,%g,%g,%g,1}", gizmoName, redTR, greenTR, blueTR	// top right
	 	Execute cmd
	
		sprintf cmd, "ModifyGizmo/N=%s ModifyObject=gradientQuad property={ COLORVALUE,2,%g,%g,%g,1}", gizmoName, redBR, greenBR, blueBR	// bottom right
	 	Execute cmd
	
		sprintf cmd, "ModifyGizmo/N=%s ModifyObject=gradientQuad property={ COLORVALUE,3,%g,%g,%g,1}", gizmoName, redBL, greenBL, blueBL	// bottom left
	 	Execute cmd

		if( !gradientIsDisplayed )
			sprintf cmd,"ModifyGizmo/N=%s insertDisplayList=%d, object=gradientQuad", gizmoName, gradientIndex
	 		Execute cmd
		endif

	else	// just a background color
		
		// remove any "gradient" display item from the list. Keep any gradient OBJECT, though
		Execute "RemoveFromGizmo/Z/N="+gizmoName+" displayItem=gradientQuad"
	endif	

//	Execute "ModifyGizmo/N="+gizmoName+" endRecMacro"	// too much flashing
	
	SetDataFolder oldDF
End


Static Function SetUpDependency(gizmoName,dataWave, textWaveOrNull)
	String gizmoName
	WAVE dataWave
	WAVE/Z textWaveOrNull

	// create a dependency for a dummy target based on the data and possibly text waves
	// create the dependency relative to the chart data folder
	if( !ValidGizmoName(gizmoName) )
		return 0
	endif
	
	String oldDF= SetGizmoDF(gizmoName)
	
	String dataPath= GetWavesDataFolder(dataWave,4)	// relative path
	String labelPath= "$\"\""		// NULL  text wave means
	if( WaveExists(textWaveOrNull) )
		labelPath= GetWavesDataFolder(textWaveOrNull,4)	// relative path
	endif
	String dfName= GetDataFolder(0)	// just the name
	String formula
	sprintf formula "Gizmo3DPieChart#UpdateThroughDependency(\"%s\",%s,%s)", dfName, dataPath, labelPath

	Variable/G dependencyTarget
	String currentFormula= GetFormula(dependencyTarget)
	if( CmpStr(currentFormula, formula) != 0 )
		SetFormula dependencyTarget, formula
	endif
	SetDataFolder oldDF
End

// Call this when the window is closed, regardless of whether a recreation macro exists.
Static Function KillDependency(dfName)
	String dfName
	
	String path= ChartNameDFVar(dfName, "dependencyTarget")
	NVAR/Z dependencyTarget= $path
	if( NVAR_Exists(dependencyTarget) )
		dependencyTarget= 0	// breaks any dependency
		SetFormula dependencyTarget, ""
	endif
End

// make a trivial change to the data wave to provoke a dependency update
static Function TickleDependency(dfName)
	String dfName
	
	String dwPath=StrVarOrDefault(ChartNameDFVar(dfName, "dataWave"),"")
	WAVE/Z dw= $dwPath
	if( WaveExists(dw) )
		Variable isLegendRequested= NumVarOrDefault(ChartNameDFVar(dfName, "drawLegend"),0)
		if(isLegendRequested)
			String twPath=StrVarOrDefault(ChartNameDFVar(dfName, "textWave"),"")	// path to wave
			WAVE/T/Z tw=$twPath
		endif
		NVAR/Z dependencyTarget= $ChartNameDFVar(dfName, "dependencyTarget")
		if( NVAR_Exists(dependencyTarget) )
			dependencyTarget= UpdateThroughDependency(dfName, dw, tw)
		endif
	endif
End

Static Function UpdateThroughDependency(dfName, dataWave, textWaveOrNull)
	String dfName
	WAVE dataWave
	WAVE/Z textWaveOrNull
	
	String df= ChartNameDF(dfName)
	Variable lastUpdate= NumVarOrDefault(ChartNameDFVar(dfName, "dependencyTarget"),0)
	if( numtype(lastUpdate) != 0 )	// it can be set to NaN if a programming error occurs.
		lastUpdate= 0
	endif
	
	Variable delayUpdates= NumVarOrDefault(ChartNameDFVar(dfName, "delayUpdates"),0) // default 0 = no delay
	if( delayUpdates )
		return lastUpdate
	endif

	String caller= GetRTStackInfo(1)	// name of calling function or macro
	strswitch(caller)
		default:
		case "":		// No calling routine: must have been called through dependency mechanism.
			// check whether the waves are actually changed (modified) from when we last updated
			Variable changed= 0
			Variable seconds
			if( WaveExists(dataWave) )
				seconds= modDate(dataWave)
				changed =  seconds> lastUpdate
			endif
			if( !changed && WaveExists(textWaveOrNull) )
				seconds= modDate(textWaveOrNull)
				changed =  seconds> lastUpdate
			endif
			if( changed )
				break
			endif
			// else fall through for no update
		case "SetUpDependency":	// SetFormula was just called
			return lastUpdate	// no change
	endswitch
	
	// See if the gizmo exists and if it is the top-most gizmo
	// If so, update
	
	if( DataFolderExists(df) )
		String gizmoName= StrVarOrDefault(ChartNameDFVar(dfName, "gizmoName"),"")
		if( strlen(gizmoName) )
			if( WinType(gizmoName) == 17 )
				UpdateGizmo3DPieChart(gizmoName)		// this should be made to work without the panel
			else
				Variable/G $ChartNameDFVar(dfName, "delayupdates")= 1	// Gizmo window not showing, turn off updates
			endif
		endif
	endif
	
	// If not, just set a "dirty" flag for when the panel comes up next
	// then there will be an "Update" button where the hint title box often is
	
	return DateTime	// indicate time of last update.
End

// +++++++++++++++++ Support routines +++++++++++++

static StrConstant ksPackagePath= "root:Packages:Gizmo3DPieChart"
static StrConstant ksPackageName = "Gizmo3DPieChart"
static StrConstant ksIs3DPieChartString = "thisIsA3DPieChart"

Static Function/S TempDF()
	return ksPackagePath
End

Static Function/S TempDFVar(varName)
	String varName
	
	return ksPackagePath+":"+PossiblyQuoteName(varName)
End

// set the data folder to a place where Execute can dump all kinds of variables and waves
Static Function/S SetTempDF()

	String oldDF= GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S $ksPackageName	// DF is left pointing here
	return oldDF
End

Static Function IsMacintosh()

	String platform= IgorInfo(2)
	return CmpStr(platform,"Macintosh") == 0
End

// the un-named hook function
Static Function/S GetGizmoHookFunction(gizmoName)
	String gizmoName
	
	String code= WinRecreation(gizmoName, 0) // 	ModifyGizmo hookFunction=GizmoRotationHook
	String hookFunction=""
	String key="ModifyGizmo hookFunction="
	Variable start= Strsearch(code, key, 0)
	if( start >= 0 )
		start += strlen(key)	// point past what we just found.
		key= num2char(13)
		Variable theEnd= strsearch(code,key, start)
		if( theEnd >= 0 )
			hookFunction= code[start,theEnd-1]
		endif
	endif
	return hookFunction
End

Static Function UpdateHookFunction(gizmoName, hookName, namedHookFunction, unnamedHookFunction)
	String gizmoName, hookName, namedHookFunction, unnamedHookFunction
	
	String oldDF= SetTempDF()
	String currentHookFunction= GetGizmoHookFunction(gizmoName)
	// Is this my old hook un-named function?
	if( CmpStr(currentHookFunction, unnamedHookFunction) == 0 )
		// yep, disable it, because we're going to use the named hook function
		Execute "ModifyGizmo/N="+gizmoName+" hookFunction=$\"\""
		Execute "ModifyGizmo/N="+gizmoName+" hookEvents=0"
	endif
	// install the named hook function

	String func=GetIndependentModuleName()+"#Gizmo3DPieChart#"+namedHookFunction
	Execute "ModifyGizmo/N="+gizmoName+" namedHookStr={"+hookName+",\""+func+"\"}"
	SetDataFolder oldDF
End	

// Old Hook function needs to be public to accomodate ancient experiments
Function WMGizmo3DPieChartHook(infoStr)
	String infoStr
	
	String gizmoName= StringByKey("WINDOW",infoStr)

	UpdateHookFunction(gizmoName, "Gizmo3DPieChart", "WMGizmo3DPieChartNamedHook", "WMGizmo3DPieChartHook")
	
	String event= StringByKey("EVENT",infoStr)

	return Hook(gizmoName, event)
End

// Name Hook function needs to be public to accomodate old experiments
Function WMGizmo3DPieChartNamedHook(s)
	STRUCT WMGizmoHookStruct &s

	return Hook(s.winName, s.eventName)
End

Static Function Hook(gizmoName, eventName)
	String gizmoName, eventName
	
	Variable resizeBlock,transformation
	strswitch(eventName)
		case "kill":
			String dfName= GetPackagePerGizmoDFName(gizmoName,ksPackageName)
			Execute/P/Q GetIndependentModuleName()+"#Gizmo3DPieChart#PossiblyKillGizmoDF(\"" + gizmoName + "\", \""+dfName+"\")"	// once the window has gone away
			break
		case "transformation":
			transformation= NumVarOrDefault(GizmoDFVar(gizmoName,"transformationBlock"), 0)
			if( !transformation )
				Variable/G $GizmoDFVar(gizmoName,"transformationBlock")=1	// reset by HandleOrthoChanged
				Execute/P/Q/Z GetIndependentModuleName()+"#Gizmo3DPieChart#HandleOrthoChanged(\"" + gizmoName + "\")"	// do this after the hook has returned
			endif
			break
	endswitch
	return 0
End

// +++++++++++++++++ Routines to put/get globals in a data folder named after the "chart name" (often the same as the window name, but not necessarily) +++++++++++++

// the data folder may not yet exist.
Static Function/S GizmoDF(gizmoName)
	String gizmoName

	String df= PackagePerGizmoDFVar(gizmoName,ksPackageName,"")	// "" if no gizmo by that name, else "root:Packages:Gizmo3DPieChart:PerGizmoData:dfName"
	if( strlen(df) == 0 )
		df= TempDF()+":Defaults"
	endif
	NewDataFolder/O $df
	return df
End

static Function/S SetGizmoDF(gizmoName)
	String gizmoName
	
	String oldDF= GetDataFolder(1)
	String chDF=GizmoDF(gizmoName)
	NewDataFolder/O/S $chDF
	return oldDF
End

Static Function/S GizmoDFVar(gizmoName,varName)
	String gizmoName,varName
	
	return GizmoDF(gizmoName)+":"+PossiblyQuoteName(varName)
End

// NOTE: the parameter is NOT gizmoName
// Using dfName allows use of this routine without a Gizmo window.
//
Static Function/S ChartNameDF(dfName)	
	String dfName
	
	return PackagePerGizmoDFVar("",ksPackageName,"",dfName=dfName)
End	

// the dfName data folder may not yet exist.
Static Function/S ChartNameDFVar(dfName,varName)	// NOTE: NOT gizmoName
	String dfName,varName

 	String chDF= ChartNameDF(dfName)
 	return chDF +":"+PossiblyQuoteName(varName)
End

// intentionally made public (not static)
Function GizmoIs3DPieChart(gizmoName)
	String gizmoName	// input
	
	if( !ValidGizmoName(gizmoName) )
		return 0
	endif
	String stringValue= GetGizmoUserString(gizmoName, ksIs3DPieChartString)	// See NewGizmo3DPieChart()
	return strlen(stringValue) > 0
End

Function TopGizmoIs3DPieChart()
	return GizmoIs3DPieChart(TopGizmo())
End


Static Function PossiblyKillGizmoDF(gizmoName,dfName)
	String gizmoName,dfName
	
	// supplying dfName works even if the gizmo is gone, which it mostly likely is
	String df= ChartNameDF(dfName) // "root:Packages:Gizmo3DPieChart:PerGizmoData:dfName"
	
	if( strlen(df) )
		if( exists(gizmoName) != 5 )
			// no recreation macro exists, it's okay to kill the data folder.
			KillDataFolder/Z $df	// also kills any dependency
			// if this is the last PerGizmo data folder, kill all the Packages:Gizmo3DPieChart data folder too
			String chartsDF= ParseFilePath(1, df, ":", 1, 0)	// root:Packages:Gizmo3DPieChart:PerGizmoData:
			chartsDF= RemoveEnding(chartsDF,":")
			String otherDfName = GetIndexedObjName(chartsDF, 4, 0)
			if (strlen(otherDfName) == 0)
				// no more charts!
				DoWindow/K Gizmo3DPieChartPanel
				KillDataFolder/Z $TempDF()
			endif
			return 1
		else
			KillDependency(dfName)
		endif
	endif
	DoWindow Gizmo3DPieChartPanel
	if( V_Flag )
		UpdateGizmo3DPieChartPanel()
	endif
	return 0
End


// ++++++++++++++++++++ panel code +++++++++++++++++++++


Static Function WS_DataNotificationProc(SelectedItem, EventCode)	// for WS_SetNotificationProc
	String SelectedItem		// string with full path to the item clicked on in the wave selector
	Variable EventCode		// the ListBox event code that triggered this notification, currently either 4 or 5

	String gizmoName= TopGizmo()
	String path=GizmoDFVar(gizmoName,"dataWave")
	WAVE/Z w= $SelectedItem
	if( WaveExists(w) )
		String/G $path = SelectedItem	// full path from root:
		ShowHint("")
	else
		String/G $path = ""
		ShowHint("Click Numeric\rData to start.")
	endif
	UpdateGizmo3DPieChart(gizmoName) // "" if no gizmo extant.
End

Static Function PWS_TextNotificationProc(event, wavepath, windowName, ctrlName)
		Variable event
		String wavepath
		String windowName
		String ctrlName

//		Your function will be called with the parameters filled as follows:
//
//		event:			The event that caused the function to be called. WMWS_SelectionChanged is so far the only event. This
//						constant is defined in the WaveSelectorWidget.ipf procedure file.
//		wavepath:		String containing the full path of the selected wave. It is possible for this to have zero length if a click
//						didn't select a wave.
//		windowName:	String containing the name of the control panel or graph window containing the button or SetVariable
//						control. This is the window name passed by you into MakeButtonIntoWSPopupButton or 
//						MakeSetVarIntoWSPopupButton
//		ctrlName:		String containing the name of the button or SetVariable control.

	String gizmoName= TopGizmo()
	String path=GizmoDFVar(gizmoName,"textWave")
	WAVE/Z tw= $wavepath
	if( WaveExists(tw) )
		String/G $path = wavepath
	else
		String/G $path = ""
	endif
	ControlInfo/W=$windowName drawLegendCheck
	if( V_Value )
		UpdateGizmo3DPieChart(gizmoName)
	endif
End

Static Function WS_TextNotificationProc(SelectedItem, EventCode)	// for WS_SetNotificationProc
	String SelectedItem		// string with full path to the item clicked on in the wave selector
	Variable EventCode		// the ListBox event code that triggered this notification, currently either 4 or 5

	String gizmoName= TopGizmo()
	String path=GizmoDFVar(gizmoName,"textWave")
	WAVE/Z tw= $SelectedItem
	if( WaveExists(tw) )
		String/G $path = SelectedItem
	else
		String/G $path = ""
	endif
	ControlInfo/W=Gizmo3DPieChartPanel drawLegendCheck
	if( V_Value )
		UpdateGizmo3DPieChart(gizmoName)
	endif

End

// given a legendScale value, compute the corresponding slider value
Static Function LegendSliderValueForLegendScale(legendScale)
	Variable legendScale
	
	Variable sliderValue= log(legendScale * 4)	
	return sliderValue
End

Static Function LegendSizeSliderProc(sa) : SliderControl
	STRUCT WMSliderAction &sa

	switch( sa.eventCode )
		case -3: // Control received keyboard focus
		case -2: // Control lost keyboard focus
		case -1: // Control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				sa.blockReentry = 1	// this will take a while...
				Variable sliderValue = sa.curval
				String gizmoName= TopGizmo()
				String oldDF= SetTempDF()
				Variable legendScale=0.25 * 10^sliderValue // nominal value is 0.25
				Variable/G $GizmoDFVar(gizmoName,"legendScale")= legendScale
#if 0
				String cmd
				sprintf cmd, "ModifyGizmo/N=%s opName=scaleLegend, operation=scale, data={%g, %g, %g}", gizmoName,legendScale, legendScale, legendScale
				Execute cmd
#else
				UpdateGizmo3DPieChartLegend(gizmoName)
#endif
				SetDataFolder oldDF
			endif
			break
	endswitch

	return 0
End

static Function LegendPosliderProc(sa) : SliderControl
	STRUCT WMSliderAction &sa

	switch( sa.eventCode )
		case -3: // Control received keyboard focus
		case -2: // Control lost keyboard focus
		case -1: // Control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				sa.blockReentry = 1	// this will take a while...
				Variable sliderValue = sa.curval
				String gizmoName= TopGizmo()
				ControlInfo/W=Gizmo3DPieChartPanel legendLeft
				Variable left= V_Value
				ControlInfo/W=Gizmo3DPieChartPanel legendTop
				Variable top=V_value
				Variable/G $GizmoDFVar(gizmoName,"legendTop")= top	// -2 to +2
				Variable/G $GizmoDFVar(gizmoName,"legendLeft")= left
				UpdateGizmo3DPieChartLegend(gizmoName)
			endif
			break
	endswitch

	return 0
End


Static Function SideColorPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String gizmoName= TopGizmo()
	ControlInfo/W=Gizmo3DPieChartPanel $ctrlName
	Variable/G $GizmoDFVar(gizmoName,"sideRed")= V_red
	Variable/G $GizmoDFVar(gizmoName,"sideGreen")= V_green
	Variable/G $GizmoDFVar(gizmoName,"sideBlue")= V_blue
	ControlInfo/W=Gizmo3DPieChartPanel sideColorCheck
	if( V_Value )
		UpdateGizmo3DPieChart(gizmoName)
	endif
End

Static Function CheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	UpdateGizmo3DPieChart(TopGizmo())
End


Static Function LegendCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	UpdateGizmo3DPieChartLegend(TopGizmo())
End

Static Function OffsetRadioProc(ctrlName,checked) : CheckBoxControl
	String ctrlName	// either "offsetAllCheck" or "offsetOneCheck"
	Variable checked

	// radio button behavior
	String gizmoName= TopGizmo()
	Variable allChecked= CmpStr(ctrlName,"offsetAllCheck")==0
	Variable/G $GizmoDFVar(gizmoName,"offsetAllWedges")= allChecked
	CheckBox offsetAllCheck, win=Gizmo3DPieChartPanel, value=allChecked
	CheckBox offsetOneCheck, win=Gizmo3DPieChartPanel, value=!allChecked
	
	// update the slider
	WAVE/Z wOffsets= $GizmoDFVar(gizmoName,"offsets")
	Variable explodingWedgeNum= NumVarOrDefault(GizmoDFVar(gizmoName,"explodingWedgeNum"),0)
	Variable offset
	if( allChecked )
		offset= NumVarOrDefault(GizmoDFVar(gizmoName,"gOffset"),0)
	elseif( WaveExists(wOffsets) && (explodingWedgeNum <= DimSize(wOffsets,0)-1) )
		offset= wOffsets[explodingWedgeNum]
	else
		offset= 0
	endif
	Variable/G $GizmoDFVar(gizmoName,"wedgeoffset")= offset
	SetVariable wedgeOffset,win=Gizmo3DPieChartPanel,value=$GizmoDFVar(gizmoName,"wedgeoffset")

	// NO CALL TO UpdateGizmo3DPieChart() IS NEEDED HERE.
End


Static Function WedgeNumSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	// update slider value IF Offset Only Wedge is selected
	
	ControlInfo/W=Gizmo3DPieChartPanel offsetOneCheck
	if( V_Value )
		String gizmoName= TopGizmo()
		WAVE/Z wOffsets= $GizmoDFVar(gizmoName,"offsets")
		Variable offset=0
		if( WaveExists(wOffsets) && (varNum <= DimSize(wOffsets,0)-1) )
			offset= wOffsets[varNum]
		endif
		Variable/G $GizmoDFVar(gizmoName,"wedgeoffset")= offset
		SetVariable wedgeOffset,win=Gizmo3DPieChartPanel,value=$GizmoDFVar(gizmoName,"wedgeoffset")
	endif

	// NO CALL TO UpdateGizmo3DPieChart() IS NEEDED HERE.
End

// Previous to Igor 6.2, the name of a particular wedge object was built
// from the name of the source wave and the  number of the wedge.
// As of Igor 6.2, it's just "pieWedge0", pieWedge1", etc. That makes it easy to delete with "pieWedge*"
Static Function/S WedgeName(gizmoName,index)
	String gizmoName
	Variable index
	
	return "pieWedge"+num2istr(index)
End

Static Function offsetAllWedges(gizmoName,sliderValue)
	String gizmoName
	Variable sliderValue

	SVAR dataWavePath= $GizmoDFVar(gizmoName,"dataWave")
	Wave/Z dw=$dataWavePath
	if(WaveExists(dw))
//		Execute "ModifyGizmo/N="+gizmoName+" startRecMacro"	// faster, though it flashes more
		Variable i, num=numpnts(dw)
		for(i=0;i<num;i+=1)
			offsetSingleWedge(gizmoName,i,sliderValue)
		endfor
//		Execute "ModifyGizmo/N="+gizmoName+" endRecMacro"
	endif	
End

static Function offsetSingleWedge(gizmoName,index,sliderValue)
	String gizmoName
	Variable index,sliderValue
	
	String theName= WedgeName(gizmoName,index)
	String cmd
	sprintf cmd,"ModifyGizmo/N=%s ModifyObject=%s property={radialOffset,%g}",gizmoName,theName,sliderValue
	Execute cmd
End

Static Function HelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic/K=1 "Gizmo 3D Pie Charts"
End

Static Function SetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	UpdateGizmo3DPieChart("")
End

static Function Gizmo3DPieChartPanelHook(infoStr)
	String infoStr

	String win= StringByKey("WINDOW",infoStr)
	if( CmpStr(win,"Gizmo3DPieChartPanel") == 0 )
		String event= StringByKey("EVENT",infoStr)
		strswitch(event)
			case "activate":
					UpdateGizmo3DPieChartPanel()
					break
		endswitch
	endif
	return 0
End

// -- Background & Gradient control procedures

Static Function BkgColorPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String gizmoName= TopGizmo()
	ControlInfo/W=Gizmo3DPieChartPanel $ctrlName
	Variable/G $GizmoDFVar(gizmoName,"bkgRed")= V_red
	Variable/G $GizmoDFVar(gizmoName,"bkgGreen")= V_green
	Variable/G $GizmoDFVar(gizmoName,"bkgBlue")= V_blue
	
	ControlInfo/W=Gizmo3DPieChartPanel bkgColorCheck
	if( V_Value )
		UpdateGizmo3DPieChartBackground(gizmoName)
	endif
End

static Function EnableDisableGradientReturn()

	ControlInfo/W=Gizmo3DPieChartPanel gradientShape
	Variable disable= 0
	strswitch(S_value)
		default:
			disable= 1	// hide
			break
		case "Diagonal -45":
		case "Diagonal +45":
			disable= 0	// show
			break
	endswitch
	Checkbox gradientReturn win=Gizmo3DPieChartPanel, disable=disable
End

Static Function GradientShapePopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName	// "gradientShape"
	Variable popNum
	String popStr
	
	String gizmoName= TopGizmo()
	String/G $GizmoDFVar(gizmoName,"gradientShape")= popStr
	EnableDisableGradientReturn()
	
	ControlInfo/W=Gizmo3DPieChartPanel gradientColorCheck
	if( V_Value )
		UpdateGizmo3DPieChartBackground(gizmoName)
	endif
End


Static Function GradientColorPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName	// "gradientColor"
	Variable popNum
	String popStr
	
	String gizmoName= TopGizmo()
	ControlInfo/W=Gizmo3DPieChartPanel $ctrlName
	Variable/G $GizmoDFVar(gizmoName,"gradientColorRed")= V_red
	Variable/G $GizmoDFVar(gizmoName,"gradientColorGreen")= V_green
	Variable/G $GizmoDFVar(gizmoName,"gradientColorBlue")= V_blue
	
	ControlInfo/W=Gizmo3DPieChartPanel gradientColorCheck
	if( V_Value )
		UpdateGizmo3DPieChartBackground(gizmoName)
	endif
End

Static Function GradientOnOffCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	UpdateGizmo3DPieChartBackground("")
End

Static Function GradientColorsCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	ControlInfo/W=Gizmo3DPieChartPanel gradientColorCheck
	if( V_Value )
		UpdateGizmo3DPieChartBackground("")
	endif
End


Static Function GizmoInfoButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String oldDF= SetTempDF()
	Execute "ModifyGizmo showInfo"
	SetDataFolder oldDF
End

Static Function DelayUpdatesCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	if( !checked )
		String dfName= GetPackagePerGizmoDFName("",ksPackageName)
		TickleDependency(dfName) // force an update through the dependency (if any)
	endif
End

Static Function ClockwiseCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	UpdateGizmo3DPieChart("")
End

static Function  WedgesCenterPosSliderProc(sa) : SliderControl
	STRUCT WMSliderAction &sa

	switch( sa.eventCode )
		case -3: // Control received keyboard focus
		case -2: // Control lost keyboard focus
		case -1: // Control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				sa.blockReentry = 1	// this will take a while...
				Variable sliderValue = sa.curval
				String gizmoName= TopGizmo()
				String oldDF= SetTempDF()
				ControlInfo/W=Gizmo3DPieChartPanel wedgesX0
				Variable wedgesX0= V_Value
				ControlInfo/W=Gizmo3DPieChartPanel wedgesY0
				Variable wedgesY0=V_value
				Variable/G $GizmoDFVar(gizmoName,"wedgesX0")= wedgesX0
				Variable/G $GizmoDFVar(gizmoName,"wedgesY0")= wedgesY0
				SetDataFolder oldDF
				UpdateOrtho(gizmoName)
			endif
			break
	endswitch

	return 0
End

Static Function WedgeOffsetSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			String gizmoName= TopGizmo()
			Variable is3DPieChart= GizmoIs3DPieChart(gizmoName)
			if( !is3DPieChart )
				return 0
			endif
			sva.blockReentry = 1	// this will take a while...
			Variable varNum = sva.dval
		
			String oldDF= SetTempDF()
			WAVE/Z wOffsets= $GizmoDFVar(gizmoName,"offsets")
			ControlInfo/W=Gizmo3DPieChartPanel offsetAllCheck
			if( V_value )
				Variable/G $GizmoDFVar(gizmoName,"gOffset")= varNum
				if( WaveExists(wOffsets) )
					wOffsets= varNum
				endif
				offsetAllWedges(gizmoName,varNum)
			else
				Variable explodingWedgeNum= NumVarOrDefault(GizmoDFVar(gizmoName,"explodingWedgeNum"),0)
				if( WaveExists(wOffsets) && (explodingWedgeNum <= DimSize(wOffsets,0)-1) )
					wOffsets[explodingWedgeNum]= varNum
				endif
				offsetSingleWedge(gizmoName,explodingWedgeNum,varNum)
			endif
			SetDataFolder oldDF
			// NO CALL TO UpdateGizmo3DPieChart() IS NEEDED HERE, we're modifying existing wedges.

			break
	endswitch

	return 0
End


Static Function FontNamePopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String gizmoName= TopGizmo()
	String/G $GizmoDFVar(gizmoName,"fontName")= popStr
	ControlInfo/W=Gizmo3DPieChartPanel drawLegendCheck
	if( V_Value )
		UpdateGizmo3DPieChartLegend(gizmoName)
	endif
End


// ++++ Gizmo Utilities +++++

Static Function/S GizmoFontList()
	return FontList(";",1)	// Igor 6.02: Only scalable fonts
End


// ++++ Window Aspect Ratio Routines +++++

Static Function HandleOrthoChanged(gizmoName)
	String gizmoName
	
	if( strlen(gizmoName) )
		MakeChangesForNewOrtho(gizmoName)
		Variable/G $GizmoDFVar(gizmoName,"transformationBlock")= 0
	endif
End

Static Function ComputeNewOrthoForWindow(gizmoName, left, right, bottom, top, zNear, zFar, opName)
	String gizmoName
	Variable &left, &top, &right, &bottom, &zNear, &zFar		// ortho outputs
	String &opName	// output
	
	String name
	GetGizmoOrtho(gizmoName, left, right, bottom, top, zNear, zFar, opName=name)
	opName=name
	
	Variable wleft, wtop, wright, wbottom	// points, but all we care about is the aspect ratio.
	if( GetGizmoCoordinates(gizmoName, wleft, wtop, wright, wbottom) )
		Variable wWidth= wright-wleft
		Variable wHeight= wbottom-wtop
		Variable windowAspect= wWidth/wHeight

		Variable horizontal = abs(right-left)/2	// half the ortho horizontal range, nominally 2
		Variable vertical = abs(top-bottom)/2	// half the ortho vertical range, nominally 2
		vertical = horizontal	/ windowAspect
		Variable wedgesX0= NumVarOrDefault(GizmoDFVar(gizmoName,"wedgesX0"), 0)
		Variable wedgesY0= NumVarOrDefault(GizmoDFVar(gizmoName,"wedgesY0"), 0)

		left= wedgesX0 - horizontal
		right= wedgesX0 + horizontal
		bottom= wedgesY0 - vertical
		top= wedgesY0 + vertical
		// zNear, zFar aren't changed
		return 1 // success
	endif
	return 0 // failure or defaults
End

Static Function UpdateOrtho(gizmoName)
	String gizmoName

	if( ValidGizmoName(gizmoName) )
		Variable left, right, bottom, top, zNear, zFar
		String opName
		if( ComputeNewOrthoForWindow(gizmoName, left, right, bottom, top, zNear, zFar, opName) )
			String oldDF= SetTempDF()
			String cmd
			sprintf cmd, "ModifyGizmo/N=%s opName=%s, operation=ortho, data={%g,%g,%g,%g,%g,%g}", gizmoName, opName, left, right, bottom, top, zNear, zFar
			Execute cmd
			SetDataFolder oldDF
			
			MakeChangesForNewOrtho(gizmoName)	// set the slider ranges and the background quad's coordinates
		endif
	endif
End

Static Function MakeChangesForNewOrtho(gizmoName)
	String gizmoName
	
	Variable needChartUpdate= SetControlsForOrtho(gizmoName)
	if( needChartUpdate )
		UpdateGizmo3DPieChart(gizmoName)
	else
		UpdateGizmo3DPieChartBackground(gizmoName)
	endif
End

Static Function SetControlsForOrtho(gizmoName)
	String gizmoName

	Variable needChartUpdate=0

	return needChartUpdate
End



static Function LegendMarkerPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String gizmoName= TopGizmo()
	if( strlen(gizmoName) )
		Variable/G $GizmoDFVar(gizmoName,"legendMarker")= popNum
		ControlInfo/W=Gizmo3DPieChartPanel drawLegendCheck
		if( V_Value )
			UpdateGizmo3DPieChartLegend(gizmoName)
		endif
	endif
End

static Function WantLegendMarkerCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	String gizmoName= TopGizmo()
	if( strlen(gizmoName) )
		Variable/G $GizmoDFVar(gizmoName,"wantLegendMarker")= checked
		ControlInfo/W=Gizmo3DPieChartPanel drawLegendCheck
		if( V_Value )
			UpdateGizmo3DPieChartLegend(gizmoName)
		endif
	endif
End

static Function ColoredLegendTextCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	String gizmoName= TopGizmo()
	if( strlen(gizmoName) )
		Variable/G $GizmoDFVar(gizmoName,"coloredLegendText")= checked
		ControlInfo/W=Gizmo3DPieChartPanel drawLegendCheck
		if( V_Value )
			UpdateGizmo3DPieChartLegend(gizmoName)
		endif
	endif
End
