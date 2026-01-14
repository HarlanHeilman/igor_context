#pragma rtGlobals=1		// Use modern global access method.
#pragma version=3.04
// <Polar Graphs>
//	Version 5.0: Renamed PolarDrawArc() to avoid conflict with Igor 5's DrawArc operation.
//	Version 3.04: PolarGraphGlobalsInit() no longer prints NaN
//	Version 3.03: Fixed bug where arcs were always drawn in cases where polar coordinates are defined as clockwise i.e. angleRange is negative, (Rowland Taylor).
//	Version 3.02. Modified by Rowland Taylor, 5 Nov 99.
//		 In Macro PolarRemoveWaves() the order for the first two arguments in calls to StrSubstitute() were incorrect.
// Version 3.01 modified for Windows and avoiding multi-dimensional data index functions
// Version 3.0 modified by Phil Parilla for rtGlobal=1 and data folder awareness
#pragma version=5.0
#include <WMDataBase Procs> version >= 3.0
#include <String Substitution>

Macro PolarGraphGlobalsInit()

	Silent 1
	WMDataBaseGlobalsInit()
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:PolarGraphs
	// All of the following vars and strings are in root:Packages:PolarGraphs
	String/G u_debugStr=""
	Variable/G u_debug
	String/G u_polRadAxesWherePop
	String/G u_polAngleAxesWherePop
	String/G u_polRotPop
	String/G u_polOffOn
	String/G u_polAngleUnitsPop
	String/G u_polLineStylePop
	Variable/D/G u_angle0,u_angleRange
	Variable/D/G u_polInnerRadius,u_polOuterRadius,u_polMajorRadiusInc,u_polMinorRadiusTicks
	Variable/D/G u_polAngle0,u_polAngleRange,u_polMajorAngleInc,u_polMinorAngleTicks
	Variable/D/G u_segsPerMinorArc
	Variable/D/G u_segsPerMinorArc
	Variable/D/G u_numPlaces, u_tickDelta, u_majorDelta
	String/G u_prompt,u_popup
	Variable/D/G u_var
	Variable/G u_UniqWinNdx
	Variable/G u_UniqWaveNdx
	Variable/D/G u_x1,u_x2,u_y1,u_y2
	String/G u_colorList
	DefaultWMPolarGraphGlobals()
	SetDataFolder root:
end

Function DefaultWMPolarGraphGlobals()

	NVAR V_min=root:Packages:PolarGraphs:V_min
	NVAR V_max=root:Packages:PolarGraphs:V_max
	NVAR V_left=root:Packages:PolarGraphs:V_left
	NVAR V_top=root:Packages:PolarGraphs:V_top
	NVAR V_bottom=root:Packages:PolarGraphs:V_bottom
	NVAR V_right=root:Packages:PolarGraphs:V_right

	// debugging
	SVAR u_debugStr=root:Packages:PolarGraphs:u_debugStr
	u_debugStr="Turn Debugging On"
	NVAR u_debug=root:Packages:PolarGraphs:u_debug
	u_debug=0

	DefaultWMDataBaseGlobals("\r(You can click \'No\' and still get new defaults.)")  

	String def=""									// contains default key=value pairs as a single string

	// PolarAppendWaves
	def += ",appendRadius=,appendAngleData="	// Strings - (wave names are empty)
	def += ",angleDataUnits=1"					// Variable popup,"degrees;radians;grads"
	def += ",appendShadowYWaves="				// String list of shadow waves (killable waves)
	def += ",appendShadowXWaves="				// String list of shadow waves (killable waves)

	// PolarCoordinates
	def += ",zeroAngleWhere=2"					// Variable popup code: "bottom;right;top;left" "-90;0;+90;+180"
	def += ",angleDirection=2"					// Variable popup code: "clockwise;counter-clockwise"
	def += ",radiusFunction=1"					// Variable popup code: "Linear;Log;Ln"
	def += ",valueAtCenter=0"					// Variable

	// PolarAxesRanges
	def += ",doRadiusRange=2"					// Variable popup code: auto;manual
	def += ",innerRadius=0"						// Variable (for manual)
	def += ",outerRadius=1"						// Variable (for manual)
	def += ",doAngleRange=2"					// Variable popup code: auto;manual
	def += ",angle0=0"							// Variable degrees
	def += ",angleRange=360"					// Variable degrees

	// PolarAxesTicks - radius
	def += ",doMajorRadiusTicks=3"				// Variable popup code: off;auto;manual
	def += ",majorRadiusInc=0.5"				// Variable: auto ticks or manual increment
	def += ",doMinorRadiusTicks=2"				// Variable popup code: off;on
	def += ",minorRadiusTicks=5"				// Variable: auto approx or manual exact minor ticks

	// PolarAxesTicks - angle
	def += ",doMajorAngleTicks=3"				// Variable popup code: off;auto;manual
	def += ",majorAngleInc=45"					// Variable: auto ticks or manual increment in degrees
	def += ",doMinorAngleTicks=2"				// Variable popup code: off;on
	def += ",minorAngleTicks=3"				// Variable: auto approx or manual exact minor ticks (not an angle)

	// PolarRadiusAxisTweaks
	def += ",radiusAxesWhere=10"				// Variable u_polRadAxesWherePop code = 0,90
	def += ",radiusAxesAngleList="				// String - (angle list is empty)
	def += ",radiusAxisThick=1"					// Variable
	def += ",radiusAxisColorNdx=1"				// Variable popup code: black,red,blue,...

	// PolarRadiusTickTweaks
	def += ",radiusTicksLocation=2"				// Variable popup code Inside;Crossing;Outside
	def += ",majorRadiusTickThick=1"			// Variable
	def += ",majorRadiusTickLength=5"			// Variable
	def += ",doMinorRadiusTicks=2"				// Variable popup code Off;On
	def += ",minorRadiusTickThick=1"			// Variable
	def += ",minorRadiusTickLength=3"			// Variable
	def += ",minorRadiusTickEmph=0"			// Variable: 0==none

	// PolarAngleAxisTweaks
	def += ",angleAxesWhere=3"				// Variable u_polAngleAxesWherePop code  "Off;Radius Start;RadiusEnd;Radius Start and End;All Major Radii;At Listed Angles" 
	def += ",angleAxesRadiusList="				// String - (radii list is empty)
	def += ",angleAxisThick=1"					// Variable
	def += ",angleAxisColorNdx=1"				// Variable popup code: black,red,blue,...


	// PolarAngleTickTweaks()
	def += ",angleTicksLocation=2"				// Variable popup code  Inside;Crossing;Outside
	def += ",majorAngleTickThick=1"			// Variable
	def += ",majorAngleTickLength=5"			// Variable
	def += ",doMinorAngleTicks=2"				// Variable popup code Off;On
	def += ",minorAngleTickThick=1"			// Variable
	def += ",minorAngleTickLength=3"			// Variable
	def += ",minorAngleTickEmph=0"			// Variable: 0==none

	// PolarRadiusTickLabels
	def += ",doRadiusTickLabels=2"				// Variable popup code  "Off;On"
	def += ",radiusTickLabelRange=" + DataBaseEncodeString("0,0")	// String: 0,0 for label all ticks
	def += ",radiusTickLabelOffset=0"			// Variable
	def += ",radiusTickLabelRotation=" + DataBaseEncodeString("  0")		// String u_polRotPop " -90;  0;+90;+180"
	def += ",radiusTickLabelSigns=1"			// Variable popup code  "-, no +;- and +;no signs"
	def += ",radiusTickLabelNotation=" + DataBaseEncodeString("%g")		// String "%g", ala Printf, they can put units here.
		// font and size moved in from PolarAngleAxisTweaks
	def += ",radiusAxisFontName=" + DataBaseEncodeString("default")	// String
	def += ",radiusAxisFontSize=12"			// Variable

	// PolarAngleTickLabels
	def += ",doAngleTickLabels=2"				// Variable popup code  "Off;On"
	def += ",angleTickLabelRange=" + DataBaseEncodeString("0,0")	// String: 0,0 for label all ticks
	def += ",angleTickLabelOffset=0"			// Variable
	def += ",angleTickLabelRotation=" + DataBaseEncodeString("  0")		// String u_polRotPop " -90;  0;+90;+180"
	def += ",angleTickLabelSigns=1"				// Variable popup code "-, no +;- and +;no signs"
	def += ",angleTickLabelNotation=" + DataBaseEncodeString("%g")		// String "%g", ala Printf
		// font and size moved in from PolarAngleAxisTweaks
	def += ",angleAxisFontName=" + DataBaseEncodeString("default")	// String
	def += ",angleAxisFontSize=12"				// Variable
	def += ",angleValues=1"						// Variable u_polAngleUnitsPop code "degrees;radians"

	// PolarGrid
	def += ",doPolarGrids=3"				// Variable popup code   "Off;Major Only; On"
	def += ",majorGridLineSize=1"			// Variable
	def += ",minorGridLineSize=1"			// Variable
	def += ",majorGridStyle=1"				// Variable popup code (style=code-1)
	def += ",minorGridStyle=2"				// Variable popup code (style=code-1)
	def += ",majorGridColorNdx=2"			// Variable popup code: black,red,blue,...
	def += ",minorGridColorNdx=2"			// Variable popup code: black,red,blue,...
	def += ",minGridSpacing=4"				// Variable spacing in points,  0 for finest grids.
	def += ",useCircles=2"					// Variable popup code "polygons;circles"	(use for complete circles)
	def += ",maxArcLine=6"					// Variable degrees (largest arc represented as a straight line)

	// PolarRadiusRulers
	// PolarRadiusRulersTweaks
	// PolarRadiusRulerLabels

	DataBaseCurrentBag("_default_")
	SetDataContents( def)						// install new default values into bag, regardless of whether other settings were cleared
	
	SVAR u_polRadAxesWherePop=root:Packages:PolarGraphs:u_polRadAxesWherePop
	u_polRadAxesWherePop="  Off;  Angle Start;  Angle Middle;  Angle End;  Angle Start and End;"		// 1-5
	u_polRadAxesWherePop+="  0;  90;  180; -90;"																// 6-9
	u_polRadAxesWherePop+="  0, 90;  90, 180; -180, -90; -90, 0;  0, 180;  90, -90;  0, 90, 180, -90;"	// 10-16
	u_polRadAxesWherePop+="  All Major Angles;  At Listed Angles"												// 17-18
	
	SVAR u_polAngleAxesWherePop=root:Packages:PolarGraphs:u_polAngleAxesWherePop
	SVAR u_polRotPop=root:Packages:PolarGraphs:u_polRotPop
	SVAR u_polOffOn=root:Packages:PolarGraphs:u_polOffOn
	SVAR u_polAngleUnitsPop=root:Packages:PolarGraphs:u_polAngleUnitsPop
	SVAR u_polLineStylePop=root:Packages:PolarGraphs:u_polLineStylePop
	u_polAngleAxesWherePop="Off;Radius Start;Radius End;Radius Start and End;All Major Radii;At Listed Radii"
	u_polRotPop=" -90;  0; +90; +180"
	u_polOffOn="Off;On"
	u_polAngleUnitsPop="deg;rad"
	u_polLineStylePop="solid;dash 1;dash 2;dash 3;dash 4;dash 5;dash 6;dash 7;dash 8;dash 9;dash 10;dash 11;dash 12;dash 13;dash 14;dash 15;dash 16;dash 17;"

	// Function QuadrantsToAngle0Range()
	NVAR u_angle0=root:Packages:PolarGraphs:u_angle0
	NVAR u_angleRange=root:Packages:PolarGraphs:u_angleRange

	// PolarTicks()
	NVAR u_polInnerRadius=root:Packages:PolarGraphs:u_polInnerRadius
	NVAR u_polOuterRadius=root:Packages:PolarGraphs:u_polOuterRadius
	NVAR u_polMajorRadiusInc=root:Packages:PolarGraphs:u_polMajorRadiusInc
	NVAR u_polMinorRadiusTicks=root:Packages:PolarGraphs:u_polMinorRadiusTicks
	NVAR u_polAngle0=root:Packages:PolarGraphs:u_polAngle0
	NVAR u_polAngleRange=root:Packages:PolarGraphs:u_polAngleRange
	NVAR u_polMajorAngleInc=root:Packages:PolarGraphs:u_polMajorAngleInc
	NVAR u_polMinorAngleTicks=root:Packages:PolarGraphs:u_polMinorAngleTicks
	NVAR u_segsPerMinorArc=root:Packages:PolarGraphs:u_segsPerMinorArc
	
	// FPolarGrid, FPolarAngleAxes
	if( u_debug )
			u_segsPerMinorArc=1
	else
			u_segsPerMinorArc=3
	endif

	// CalcAutoTicking (work in progress)
	NVAR u_numPlaces=root:Packages:PolarGraphs:u_numPlaces
	NVAR u_tickDelta=root:Packages:PolarGraphs:u_tickDelta
	NVAR u_majorDelta=root:Packages:PolarGraphs:u_majorDelta
	

	// general purpose macro, proc input,output
	SVAR u_str=root:Packages:WMDataBase:u_str
	SVAR u_prompt=root:Packages:PolarGraphs:u_prompt
	SVAR u_popup=root:Packages:PolarGraphs:u_popup
	NVAR u_var=root:Packages:PolarGraphs:u_var
	
	// UniqueWindowName
	NVAR u_UniqWinNdx=root:Packages:PolarGraphs:u_UniqWinNdx

	// DClip_u_X12Y12
	NVAR u_x1=root:Packages:PolarGraphs:u_x1
	NVAR u_x2=root:Packages:PolarGraphs:u_x2
	NVAR u_y1=root:Packages:PolarGraphs:u_y1
	NVAR u_y2=root:Packages:PolarGraphs:u_y2

	// GetRGBColorFromList
	SVAR u_colorList=root:Packages:PolarGraphs:u_colorList
	u_colorList="black;blue;green;cyan;red;magenta;yellow;white;special"
End

Menu "New"
	"Polar Graph...", NewPolarGraph()
		help={"Create a new Polar Graph Window, based on default settings or settings for an existing Polar Graph.\r\rUse the \'Macros\' menu to append waves, change axes, etc."}
End

Menu "Macros"
	"Polar Graph Globals Init"
		help={"Initializes the Polar Graph 'package'.\r\rYOU MUST RUN THIS MACRO FIRST!"}
	"New Polar Graph..."
		help={"Create a new Polar Graph Window, based on default settings or settings for an existing Polar Graph.\r\rUse the other macros to append waves, change axes, etc."}
	"Polar Append Waves..."
		help={"Append radius wave and optional angle wave to the top Polar Graph.\r\rIgor actually appends \"shadow waves\" which are recalculated XY versions of the radius and angle waves."}
	"Polar Remove Waves..."
		help={"Remove \"shadow waves\" from the top Polar Graph.\r\rThe original radius wave is shown in enclosing [ and ] characters."}
	"-"
	"Polar Coordinates..."
		help={"Set the Polar Graph\'s angle origin and clockwise-ness, and the radius value at the polar center (usually 0)."}
	"Polar Axes Ranges..."
		help={"Set the radius and angle axes extents.\r\rUse this and the marquee rather than the \'Set Axis Range...\' dialog.\r\rAxes are drawn in the ProgAxes layer."}
	"Polar Axes Ticks..."
		help={"Set the major and minor tick values for radius and angle axes.\r\rOnly manual ticks are implemented.\r\rAxis ticks are drawn in the ProgAxes layer."}
	"Polar Grid..."
		help={"Set the characteristics of the optional grid which spans the Polar Axes Ranges.\r\r Grids are drawn in the ProgBack layer."}
	Submenu "Radius Tweaks"
		"Polar Radius Axis Tweaks..."
			help={"Select the angles at which the radius axes (\"spokes\") will be drawn, axis thickness and color."}
		"Polar Radius Tick Tweaks..."
			help={"Set the radius axes tick lengths and thicknesses.\r\rOnly Crossing ticks are implemented. Emphasized ticks are not implemented."}
		"Polar Radius Tick Labels..."
			help={"Set the characteristics of tick labels for the radius axes.\r\rLabels are drawn in the UserAxes layer."}
	End
	Submenu "Angle Tweaks"
		"Polar Angle Axis Tweaks..."
			help={"Select the radii at which the angle axes (\"rings\" or \"arcs\") will be drawn, axis thickness and color."}
		"Polar Angle Tick Tweaks..."
			help={"Set the angle axes tick lengths and thicknesses.\r\rOnly Crossing ticks are implemented. Emphasized ticks are not implemented."}
		"Polar Angle Tick Labels..."
			help={"Set the characteristics of tick labels for the angle axes.\r\rHere is where you choose to label the angles in degrees or radians.\r\rLabels are drawn in the UserAxes layer."}
	End
	"Polar Redraw"
		help={"Redraw the polar graph with the settings you have changed with the above macros.\r\rThis takes a while, so it isn\'t done automatically after changing settings."}
	"-"
	"Kill Target Polar Graph"
		help={"Kill the top Polar Graph, kill the associated \"shadow waves\", and remove the settings from the data base."}
	"-"
	Submenu "Debugging"
		"Default WMPolarGraph Globals..."
			help={"Select this if you have changed the default values in the DefaultWMPolarGraphGlobals function."}
		"-"
		"Examine DataBase..."
			help={"Examine the settings for a polar graph, or select a new \"bag\" of settings to examine next time."}
		"-"
		DebugOnOff()
			help={"Enable or disable diagnostic messages used to debug this procedure window.\r\rBeware that the grids, axes, and labels are drawn in different drawing layers if debugging is on."}
	End
End

Function/s  DebugOnOff()
	String str=StrVarOrDefault("root:Packages:PolarGraphs:u_debugStr","(Turn Debugging On")
	return str
end

Proc TurnDebuggingOff()
	root:Packages:PolarGraphs:u_debugStr="Turn Debugging On"
	BuildMenu "Macros"
	root:Packages:PolarGraphs:u_debug=0
End

Proc TurnDebuggingOn()
	root:Packages:PolarGraphs:u_debugStr="Turn Debugging Off"
	BuildMenu "Macros"
	root:Packages:PolarGraphs:u_debug=1
End

Macro PolarRedraw()
	Silent 1;PauseUpdate	// computing new axes and grids
	PolarUpdateButton("polarButton")
EndMacro

Macro NewPolarGraph()
	Silent 1;PauseUpdate	// New Polar Graph...
	if(strlen(GetDataBag())==0)
		DefaultWMPolarGraphGlobals()
	endif
	PolarGraph()
EndMacro

Proc PolarHideAxes()
	SetAxis/A/E=2/N=2 left; SetAxis/A/E=2/N=2 bottom;
	ModifyGraph axThick=0,nolabel=2
	ModifyGraph margin=1
	ModifyGraph width={Plan,1,bottom,left},height=0	// Plan width zooms well for landscape monitors,
															// but when procedures aren't compiled, can create a huge window
EndMacro													// This is fixed by the PolarFixTargetAxisRanges routine

Proc PolarGraph(style)
	String style=GetDataBag()	// The last graph worked on, or _default_
	Prompt style,"use polar graph settings from:",popup,DataBaseListCategories()
	
	Silent 1; PauseUpdate
	String graphName		// Choose a new graph name
	graphName= UniqueWindowName("PolarGraph")	// creates or asks for name
	Display/W=(5,40,320,330)
	DoWindow/C $graphName	// Only after this statement will PolarRegisterGraph and PolarSet/Get work properly
	PolarRegisterGraph(graphName,style)	// also creates a new set of values for the graph, using current ones as defaults.
	PolarSS("appendShadowYWaves","")	// some things shouldn't be copied from a style bag
	PolarSS("appendShadowXWaves","")
	PolarAppendWaves()						// If user cancels here, bad things can happen
	PolarHideAxes()
	ControlBar 30
	Button polarButton pos={92,5}, size={150,20},title="Update Axes and Grid",proc=PolarUpdateButton
	PolarRedraw()
EndMacro

	
Macro PolarAppendWaves(appendRadius,appendAngleData,angleDataUnits)
	String appendRadius=PolarGS("appendRadius")
	String appendAngleData=PolarGS("appendAngleData")
	Variable angleDataUnits=PolarGV("angleDataUnits")
	Prompt appendRadius,"radius data:",popup,WaveList("!W_*",";","")
	Prompt appendAngleData,"angle data:",popup,"_from radius wave\'s x scaling_;"+WaveList("!W_*",";","")
	Prompt angleDataUnits,"angle units:",popup,root:Packages:PolarGraphs:u_polAngleUnitsPop	// can be different for each wave pair

	Silent 1; PauseUpdate // Polar Append Waves...
	PolarSS("appendRadius",appendRadius)
	PolarSS("appendAngleData",appendAngleData)
	PolarSV("angleDataUnits",angleDataUnits)

	String wshadowX,wshadowY
	wshadowX= UniqueWaveName("W_plrX")
	wshadowY= UniqueWaveName("W_plrY")
	Duplicate/O $appendRadius,$wshadowX,$wshadowY

	// Announce the presence of the new shadow waves
	PolarSS("appendShadowYWaves",PolarGS("appendShadowYWaves")+ wshadowY+",")
	PolarSS("appendShadowXWaves",PolarGS("appendShadowXWaves")+wshadowX+",")

	// Remember the wave(s) that the shadow waves are based on
	Note/K $wshadowY
	Note $wshadowY, "shadowX="+wshadowX+",appendRadius="+appendRadius+",appendAngleData="+appendAngleData+",angleDataUnits="+num2istr(angleDataUnits)
	UpdateTargetShadowWaves(wshadowY)
	String axes=AxisList("")
	Variable resetAxes= (strsearch(axes,"left;",0) < 0) %| (strsearch(axes,"bottom;",0) < 0)
	AppendToGraph/L/B $wshadowY vs $wshadowX
	if( resetAxes )
		PolarHideAxes()
	endif
EndMacro

Function UpdateTargetShadowWaves(shadowYList)
	String shadowYList	// if "", update them all, else shadowYList contains comma-separated list of Y shadow waves to update
	String zeroAngleWhereStr=PolarGS("zeroAngleWhere")
	String angleDirectionStr=PolarGS("angleDirection")
	String radiusFunctionStr=PolarGS("radiusFunction")
	String valueAtCenterStr=PolarGS("valueAtCenter")
	String shadowX,shadowY

	if( strlen(shadowYList)==0 )	// no wave(s) specified, do all in window
		shadowYList= PolarGS("appendShadowYWaves")
	endif

	Variable n=0
	do
		shadowY= StringFromList(n,shadowYList,",")
		if( strlen(shadowY) == 0 )
			break
		endif
		if( exists(shadowY)==1 )
			shadowX= PolarShadowXForY(shadowY)
			if( exists(shadowX)==1 )
				UpdateShadowWavePair(shadowX,shadowY,zeroAngleWhereStr,angleDirectionStr,radiusFunctionStr,valueAtCenterStr)
			endif
		endif
		n += 1
	while (1)
End

// Returns truth that the shadow waves were updated
// can use ObjEqn() if we want
Function UpdateShadowWavePair(shadowX,shadowY,zeroAngleWhereStr,angleDirectionStr,radiusFunctionStr,valueAtCenterStr)
	String shadowX,shadowY
	String zeroAngleWhereStr,angleDirectionStr,radiusFunctionStr,valueAtCenterStr	// normally variables, but we use string representations

	// shadowY note contains "shadowX="+wshadowX+",appendRadius="+appendRadius+",appendAngleData="+appendAngleData+",angleDataUnits="+angleDataUnits
	SVAR u_str=root:Packages:WMDataBase:u_str
	String appendRadius,appendAngle,shadowYNote,angleDataUnitsStr
	shadowYNote= note($shadowY)
	if( !GetKeyEqualValStr(shadowYNote,"appendRadius") )
		return 0
	endif
	appendRadius= u_str
	if( !GetKeyEqualValStr(shadowYNote,"appendAngleData") )
		return 0
	endif
	appendAngle= u_str
	if( !GetKeyEqualValStr(shadowYNote,"angleDataUnits") )
		return 0
	endif
	angleDataUnitsStr= u_str
	// Dependency equation must be valid in global scope, replace strings with actual names
	// wshadowx := PolarRadiusFunction(appendRadius,radiusFunction,valueAtCenter) * cos(PolarAngleFunction(appendAngle,zeroAngleWhere,angleDirection,angleDataUnits))
	// wshadowy := PolarRadiusFunction(appendRadius,radiusFunction,valueAtCenter) * sin(PolarAngleFunction(appendAngle,zeroAngleWhere,angleDirection,angleDataUnits))
	String cmdR,cmdA,cmdX,cmdY
	sprintf cmdR, " := PolarRadiusFunction(%s,%s,%s) * ", appendRadius,radiusFunctionStr,valueAtCenterStr
	if( exists(appendAngle) !=1 )	// get angle from radius wave's x scaling (not shadow wave's x scaling)
		appendAngle="pnt2x("+appendRadius+",p)"
	endif
	sprintf cmdA, "(PolarAngleFunction(%s,%s,%s,%s))", appendAngle,zeroAngleWhereStr,angleDirectionStr,angleDataUnitsStr
	cmdX=shadowX + cmdR + "cos"+cmdA
	cmdY=shadowY + cmdR + "sin"+cmdA
	Execute cmdX
	Execute cmdY
	return 1

End

Macro PolarRemoveWaves(shadowY)
	String shadowY
	Prompt shadowY,"shadow wave [radius=original wave] to remove:",popup,PolarShadowYWaves(1)

	Silent 1; PauseUpdate		// Polar Remove Waves...
	Variable offset= strsearch(shadowY," [",0)
	shadowY=shadowY[0,offset-1]
	CheckDisplayed/W=$WinName(0,1) $shadowY
	if( V_Flag )
		RemoveFromGraph $shadowY
	endif
	// Announce the absence of the shadow waves
	String shadowWaves,shadowX
	shadowX= PolarShadowXForY(shadowY)	// before we delete shadowY
	if( strlen(shadowY) )
		shadowWaves= PolarGS("appendShadowYWaves")
		shadowWaves= StrSubstitute(shadowY+",",shadowWaves,"")	// delete "<shadowY>,"
		PolarSS("appendShadowYWaves",shadowWaves)
		KillWaves/F/Z $shadowY
	endif
	if( strlen(shadowX) )
		shadowWaves= PolarGS("appendShadowXWaves")
		shadowWaves= StrSubstitute(shadowX+",",shadowWaves,"")	// delete "<shadowX>,"
		PolarSS("appendShadowXWaves",shadowWaves)
		KillWaves/F/Z $shadowX
	endif
End

Function/S PolarShadowYWaves(listDependentWave)
	Variable listDependentWave	//boolean

	SVAR u_str=root:Packages:WMDataBase:u_str
	String shadowList= PolarGS("appendShadowYWaves")
	String wshadow,theNote,shadowYList=""
	Variable n=0
	do
		wshadow= StringFromList(n, shadowList, ",")
		if( strlen(wshadow) == 0 )
			break
		endif
		if( exists(wshadow)==1 )
			theNote= note($wshadow)
			if( GetKeyEqualValStr(theNote,"appendRadius") )	// wshadow is a y shadow wave
				shadowYList+=wshadow
				if( listDependentWave )
					shadowYList+=" [radius="+u_str+"]"	// appendRadius
				endif
				shadowYList+=";"
			endif
		endif
		n += 1
	while (1)
	return shadowYList
End

Function/S PolarShadowXForY(shadowYWave)
	String shadowYWave
	
	SVAR u_str=root:Packages:WMDataBase:u_str
	String shadowX="",wshadow
	if( exists(shadowYWave) == 1 )	// wshadow is a y shadow wave
		wshadow= note($shadowYWave)
		if( GetKeyEqualValStr(wshadow,"shadowX") )
			shadowX= u_str
		endif
	endif	
	return shadowX
End

Function/S PolarDependentAngleWaves()

	SVAR u_str=root:Packages:WMDataBase:u_str
	String shadowList= PolarGS("appendShadowYWaves")
	String wshadow,theNote,angleList="",appendRadius
	Variable n=0
	do
		wshadow= StringFromList(n,shadowList, ",")
		if( strlen(wshadow) == 0 )
			break
		endif
		if( exists(wshadow)==1 )	// wshadow is a y shadow wave
			theNote= note($wshadow)
			if( GetKeyEqualValStr(theNote,"appendAngle") )
				if( exists(u_str)!=1 )	// no angle wave, assume x scaling of radius wave
					if( GetKeyEqualValStr(theNote,"appendRadius") )
						angleList+=u_str+".x;"
					endif
				else
					angleList+=u_str+";"
				endif
			endif
		endif
		n += 1
	while (1)
	return angleList
End

Function/S PolarDependentRadiusWaves()

	SVAR u_str=root:Packages:WMDataBase:u_str
	String shadowList= PolarGS("appendShadowYWaves")
	String wshadow,theNote,radiusList=""
	Variable n=0
	do
		wshadow= StringFromList(n,shadowList, ",")
		if( strlen(wshadow) == 0 )
			break
		endif
		if( exists(wshadow)==1 )	// wshadow is a y shadow wave
			theNote= note($wshadow)
			if( GetKeyEqualValStr(theNote,"appendRadius") )
				radiusList+=u_str+";"
			endif
		endif
		n += 1
	while (1)
	return radiusList
End

// labelling and gridding doesn't handle radius function - 2/94
// Macro PolarCoordinates(zeroAngleWhere,angleDirection,radiusFunction,valueAtCenter)
Proc PolarCoordinates(zeroAngleWhere,angleDirection,radiusFunction,valueAtCenter)
	Variable zeroAngleWhere=PolarGV("zeroAngleWhere")	// Variable popup code: "bottom;right;top;left"
	Variable angleDirection=PolarGV("angleDirection")		// Variable popup code:  "clockwise;counter-clockwise"
	Variable radiusFunction=PolarGV("radiusFunction")		// "Linear;Log;Ln"
	Variable/D valueAtCenter=PolarGV("valueAtCenter")
	Prompt zeroAngleWhere,"put zero angle at:",popup,"bottom;right;top;left" 				// -90;0;+90;+180
	Prompt angleDirection,"increasing angles are:",popup,"clockwise;counter-clockwise"	// angle * -1, angle * 1
	Prompt radiusFunction,"radius scaling",popup,"\\M1Linear;(Log;(Ln"
	Prompt valueAtCenter,"radius at polar center:"

	Silent 1; PauseUpdate	// Polar Coordinates...
	if( (radiusFunction > 1) %& ( valueAtCenter <= 0 ) )
		DoAlert 0,"Log radius scaling requires positive value at polar center; setting to 1 instead of "+num2str(valueAtCenter)
		valueAtCenter=1
	endif
	// any change of values invalidates the grid and labelling. The data changes immediately, so we delete the grid, axis, and labelling.
	Variable changed=1	// assume changed
	if( PolarGV("zeroAngleWhere") == zeroAngleWhere )
		if( PolarGV("angleDirection") == angleDirection )
			if( PolarGV("radiusFunction") == radiusFunction )
				if( PolarGV("valueAtCenter") == valueAtCenter )
					changed= 0	// oh, not changed at all
				endif
			endif
		endif
	endif
	if( changed )
		SetDrawLayer/K ProgBack	// Grid
		SetDrawLayer/K ProgAxes	// Axes
		SetDrawLayer/K UserAxes	// Labels
		if( root:Packages:PolarGraphs:u_debug )
			SetDrawLayer/K ProgFront	// Axes
			SetDrawLayer/K UserFront	// Labels
		else
			SetDrawLayer UserFront
		endif
	endif
	if( PolarGV("valueAtCenter") != valueAtCenter )
		SetAxis/A // we will need new scaling
	endif

	PolarSV("zeroAngleWhere",zeroAngleWhere)
	PolarSV("angleDirection",angleDirection)
	PolarSV("radiusFunction",radiusFunction)
	PolarSV("valueAtCenter",valueAtCenter)
	UpdateTargetShadowWaves("")
	if( root:Packages:PolarGraphs:u_debug )
		Print "zero at "+GetStrFromList("bottom;right;top;left" ,zeroAngleWhere-1,";")
		Print "increasing angles are "+GetStrFromList("clockwise;counter-clockwise" ,angleDirection-1,";")
		Print "radius function is "+GetStrFromList("Linear;Log;Ln" ,radiusFunction-1,";")
		Print "Value at Center= ",valueAtCenter
	endif

	PolarUpdated(0)
End

// Sets extent of drawn axes and grid
// Should it also determine how much data is displayed?
// and if so, should wave be clipped to the wedge defined by radii and angles?
Macro PolarAxesRanges(doRadiusRange,doAngleRange,innerRadius,angle0,outerRadius,angleRange)	// Used by Ticks and grids
	Variable doRadiusRange=PolarGV("doRadiusRange")	// Variable popup code: auto;manual
	Variable doAngleRange=PolarGV("doAngleRange")		// Variable popup code: auto;manual
	Variable/D innerRadius= PolarGV("innerRadius")
	Variable/D angle0= PolarGV("angle0")
	Variable/D outerRadius= PolarGV("outerRadius")
	Variable/D angleRange= PolarGV("angleRange")
	Prompt doRadiusRange,"radius range:",popup,"\\M1(auto;manual"	// auto doesn't work too well.
	Prompt doAngleRange,"angle range:",popup,"\\M1(auto;manual"	// auto not implemented
	Prompt innerRadius,"manual inner radius"
	Prompt angle0,"manual start angle (degrees)"
	Prompt outerRadius,"manual outer radius"
	Prompt angleRange,"manual angle extent (degrees)"

	Silent 1; PauseUpdate		// Polar Axes Ranges
	PolarSV("doRadiusRange",doRadiusRange)
	PolarSV("doAngleRange",doAngleRange)
	PolarSV("innerRadius",innerRadius)
	PolarSV("angle0",angle0)
	PolarSV("outerRadius",outerRadius)
	PolarSV("angleRange",angleRange)

	if( root:Packages:PolarGraphs:u_debug )
		if( doRadiusRange==1)
			Print "auto radius range"
		else
			Print "innerRadius= ",innerRadius, "outerRadius= ",outerRadius
		endif
		if( doAngleRange==1)
			Print "auto angle range"
		else
			Print "angle0= ",angle0, "angleRange= ",angleRange
		endif
	endif

	PolarUpdated(0)
	PolarAxesTicks()	 // because automatic ticking isn't implemented, yet
End

Macro PolarAxesTicks(doMajorRadiusTicks,doMajorAngleTicks,majorRadiusInc,majorAngleInc,doMinorRadiusTicks,doMinorAngleTicks,minorRadiusTicks,minorAngleTicks)	// Used by Ticks and grids
	Variable doMajorRadiusTicks=PolarGV("doMajorRadiusTicks")	// Variable popup code: Off;Auto;Manual
	Variable doMajorAngleTicks=PolarGV("doMajorAngleTicks")		// Variable popup code: Off;Auto;Manual
	Variable/D majorRadiusInc=PolarGV("majorRadiusInc")			// Auto: approx major radius ticks, Manual: exact major radius increment
	Variable/D majorAngleInc=PolarGV("majorAngleInc") 			// Auto: approx major angle ticks, Manual: exact major angle increment in degrees
	Variable doMinorRadiusTicks=PolarGV("doMinorRadiusTicks")	// Variable popup code: Off;On (if major ticks also on)
	Variable doMinorAngleTicks=PolarGV("doMinorAngleTicks")		// Variable popup code:  Off;On (if major ticks also on)
	Variable minorRadiusTicks=PolarGV("minorRadiusTicks")		// Auto: approx minor radius ticks, Manual: exact minor radius ticks
	Variable minorAngleTicks=PolarGV("minorAngleTicks")			// Auto: approx minor angle ticks, Manual: exact minor angle ticks
	Prompt doMajorRadiusTicks,"radius tick values:",popup,"Off;\\M1(Auto;Manual;"		// auto not implemented
	Prompt doMajorAngleTicks,"angle tick values:",popup,"Off;\\M1(Auto;Manual;"		// auto not implemented
	Prompt majorRadiusInc,"radius increment or auto major ticks:"
	Prompt majorAngleInc,"angle increment or auto major ticks:"
	Prompt doMinorRadiusTicks,"radius minor ticks (if major on):",popup, root:Packages:PolarGraphs:u_polOffOn
	Prompt doMinorAngleTicks,"angle minor ticks (if major on):",popup, root:Packages:PolarGraphs:u_polOffOn
	Prompt minorRadiusTicks,"radius minor ticks:"
	Prompt minorAngleTicks,"angle minor ticks:"

	Silent 1; PauseUpdate		// Polar Axes Ticks...
	PolarSV("doMajorRadiusTicks",doMajorRadiusTicks)
	PolarSV("doMajorAngleTicks",doMajorAngleTicks)
	if( (majorRadiusInc == 0) %& (doMajorRadiusTicks == 3))
		root:Packages:PolarGraphs:u_val= 0
		root:Packages:PolarGraphs:u_prompt="Zero value for manual radius increment is not allowed. Please enter a new value."
		AskValue()
		majorRadiusInc= root:Packages:PolarGraphs:u_val
	endif
	PolarSV("majorRadiusInc",majorRadiusInc)
	if( (majorAngleInc == 0) %& (doMajorAngleTicks == 3))
		root:Packages:PolarGraphs:u_val= 0
		root:Packages:PolarGraphs:u_prompt="Zero value for manual angle increment is not allowed. Please enter a new value."
		AskValue()
		majorAngleInc= root:Packages:PolarGraphs:u_val
	endif
	PolarSV("majorAngleInc",majorAngleInc)
	PolarSV("doMinorRadiusTicks",doMinorRadiusTicks)
	PolarSV("doMinorAngleTicks",doMinorAngleTicks)
	PolarSV("minorRadiusTicks",minorRadiusTicks)
	PolarSV("minorAngleTicks",minorAngleTicks)

	if(root:Packages:PolarGraphs:u_debug )
		Print "radius ticks: "+GetStrFromList("Off;Auto;Manual;" ,doMajorRadiusTicks-1,";")
		Print "majorRadiusInc= ",majorRadiusInc
		Print "doMinorRadiusTicks= ",doMinorRadiusTicks
		Print "minorRadiusTicks= ",minorRadiusTicks
		
		Print "angle ticks: "+GetStrFromList("Off;Auto;Manual;" ,doMajorAngleTicks-1,";")
		Print "majorAngleInc= ",majorAngleInc
		Print "doMinorAngleTicks= ",doMinorAngleTicks
		Print "minorAngleTicks= ",minorAngleTicks
	endif

	PolarUpdated(0)
End

Macro PolarRadiusAxisTweaks(radiusAxesWhere,radiusAxesAngleList,radiusAxisThick,radiusAxisColorNdx)
	Variable radiusAxesWhere=PolarGV("radiusAxesWhere")		// Variable popup code: "Off;Angle Start;Angle Middle;Angle End;Angle Start and End;, etc
	String radiusAxesAngleList=PolarGS("radiusAxesAngleList")	// list of angles, for example "-90,0,90,180"
	Variable radiusAxisThick=PolarGV("radiusAxisThick")
	Variable radiusAxisColorNdx=PolarGV("radiusAxisColorNdx")	// Variable popup code: "black;red...."
	Prompt radiusAxesWhere,"radius axes at:",popup,root:Packages:PolarGraphs:u_polRadAxesWherePop
	Prompt radiusAxesAngleList,"angles for \"At Listed Angles\":"
	Prompt radiusAxisThick,"radius axis thickness (points):"
	Prompt radiusAxisColorNdx,"radius axis color:",popup,root:Packages:PolarGraphs:u_colorList

	Silent 1; PauseUpdate	// Polar Radius Axis Tweaks...
	PolarSV("radiusAxesWhere",radiusAxesWhere)
	PolarSS("radiusAxesAngleList",radiusAxesAngleList)
	PolarSV("radiusAxisThick",radiusAxisThick)
	PolarSV("radiusAxisColorNdx",radiusAxisColorNdx) 

if( root:Packages:PolarGraphs:u_debug )
Print "radiusAxesWhere= "+GetStrFromList(u_polRadAxesWherePop,radiusAxesWhere-1,";")
Print "radiusAxesAngleList= ",radiusAxesAngleList
Print "radiusAxisThick= ",radiusAxisThick
Print "radiusAxisColorNdx= "+GetStrFromList(u_colorList,radiusAxisColorNdx-1,";")
endif

	PolarUpdated(0)
End

Macro PolarRadiusTickTweaks(doMinorRadiusTicks,radiusTicksLocation,minorRadiusTickThick,majorRadiusTickThick,minorRadiusTickLength,majorRadiusTickLength,minorRadiusTickEmph)
	Variable doMinorRadiusTicks=PolarGV("doMinorRadiusTicks")	// Variable popup code: Off;On (if major ticks also on)
	Variable radiusTicksLocation=PolarGV("radiusTicksLocation")	// Variable popup code: "Inside;Crossing;Outside"	
	Variable minorRadiusTickThick=PolarGV("minorRadiusTickThick")
	Variable majorRadiusTickThick=PolarGV("majorRadiusTickThick")
	Variable minorRadiusTickLength=PolarGV("minorRadiusTickLength")
	Variable majorRadiusTickLength=PolarGV("majorRadiusTickLength")
	Variable minorRadiusTickEmph=PolarGV("minorRadiusTickEmph")
	Prompt doMinorRadiusTicks,"minor radius ticks:",popup,root:Packages:PolarGraphs:u_polOffOn
	Prompt radiusTicksLocation,"radius tick location:",popup,"\\M1(Inside;Crossing;\\M1(Outside"
	Prompt minorRadiusTickThick,"minor radius tick thickness (points):"
	Prompt majorRadiusTickThick,"major radius tick thickness (points):"
	Prompt minorRadiusTickLength,"minor radius tick length (points):"
	Prompt majorRadiusTickLength,"major radius tick length (points):"
	Prompt minorRadiusTickEmph,"emphasize minor ticks every (0 = none):"

	Silent 1; PauseUpdate	// Polar Radius Tick Tweaks...
	PolarSV("radiusTicksLocation",radiusTicksLocation)
	PolarSV("majorRadiusTickThick",majorRadiusTickThick)
	PolarSV("majorRadiusTickLength",majorRadiusTickLength)
	PolarSV("doMinorRadiusTicks",doMinorRadiusTicks)
	PolarSV("minorRadiusTickThick",minorRadiusTickThick)
	PolarSV("minorRadiusTickLength",minorRadiusTickLength)
	PolarSV("minorRadiusTickEmph",minorRadiusTickEmph)

	if( root:Packages:PolarGraphs:u_debug )
		Print "radiusTicksLocation= "+GetStrFromList("Inside;Crossing;Outside;" ,radiusTicksLocation-1,";")
		Print "majorRadiusTickThick= ",majorRadiusTickThick
		Print "majorRadiusTickLength= ",majorRadiusTickLength
		Print "doMinorRadiusTicks= "+GetStrFromList(u_polOffOn ,doMinorRadiusTicks-1,";")
		Print "minorRadiusTickThick= ",minorRadiusTickThick
		Print "minorRadiusTickLength= ",minorRadiusTickLength
		Print "minorRadiusTickEmph= ",minorRadiusTickEmph
	endif

	PolarUpdated(0)
End

Macro PolarAngleAxisTweaks(angleAxesWhere,angleAxesRadiusList,angleAxisThick,angleAxisColorNdx)
	Variable angleAxesWhere=PolarGV("angleAxesWhere")	// Variable popup code: "Off;Radius Start;RadiusEnd;etc"	
	String angleAxesRadiusList=PolarGS("angleAxesRadiusList")
	Variable angleAxisThick=PolarGV("angleAxisThick")
	Variable angleAxisColorNdx=PolarGV("angleAxisColorNdx")	// Variable popup code: "black;red...."
	Prompt angleAxesWhere,"angle axes at:",popup,root:Packages:PolarGraphs:u_polAngleAxesWherePop
	Prompt angleAxesRadiusList,"radii for \"At Listed Radii\":"
	Prompt angleAxisThick,"angle axis thickness (points):"
	Prompt angleAxisColorNdx,"angle axis color:",popup,root:Packages:PolarGraphs:u_colorList

	Silent 1; PauseUpdate	// Polar Angle Axis Tweaks...
	PolarSV("angleAxesWhere",angleAxesWhere)
	PolarSS("angleAxesRadiusList",angleAxesRadiusList)
	PolarSV("angleAxisThick",angleAxisThick)
	PolarSV("angleAxisColorNdx",angleAxisColorNdx)

	if( root:Packages:PolarGraphs:u_debug )
		Print "angleAxesWhere= "+GetStrFromList(u_polAngleAxesWherePop ,angleAxesWhere-1,";")
		Print "angleAxesRadiusList= ",angleAxesRadiusList
		Print "angleAxisThick= ",angleAxisThick
		Print "angleAxisColorNdx= "+GetStrFromList(u_colorList,angleAxisColorNdx-1,";")
	endif

	PolarUpdated(0)
End

Macro PolarAngleTickTweaks(doMinorAngleTicks,angleTicksLocation,minorAngleTickThick,majorAngleTickThick,minorAngleTickLength,majorAngleTickLength,minorAngleTickEmph)
	Variable doMinorAngleTicks=PolarGV("doMinorAngleTicks")	// Variable popup code: Off;On (if major ticks also on)
	Variable angleTicksLocation=PolarGV("angleTicksLocation")	// Variable popup code: "Inside;Crossing;Outside"	
	Variable minorAngleTickThick=PolarGV("minorAngleTickThick")
	Variable majorAngleTickThick=PolarGV("majorAngleTickThick")
	Variable minorAngleTickLength=PolarGV("minorAngleTickLength")
	Variable majorAngleTickLength=PolarGV("majorAngleTickLength")
	Variable minorAngleTickEmph=PolarGV("minorAngleTickEmph")
	Prompt doMinorAngleTicks,"minor angle ticks:",popup,root:Packages:PolarGraphs:u_polOffOn
	Prompt angleTicksLocation,"angle tick location:",popup,"\\M1(Inside;Crossing;\\M1(Outside"
	Prompt minorAngleTickThick,"minor angle tick thickness (points):"
	Prompt majorAngleTickThick,"major angle tick thickness (points):"
	Prompt minorAngleTickLength,"minor angle tick length (points):"
	Prompt majorAngleTickLength,"major angle tick length (points):"
	Prompt minorAngleTickEmph,"emphasize minor ticks every:"

	Silent 1; PauseUpdate	// Polar Angle Tick Tweaks...
	PolarSV("angleTicksLocation",angleTicksLocation)
	PolarSV("majorAngleTickThick",majorAngleTickThick)
	PolarSV("majorAngleTickLength",majorAngleTickLength)
	PolarSV("doMinorAngleTicks",doMinorAngleTicks)
	PolarSV("minorAngleTickThick",minorAngleTickThick)
	PolarSV("minorAngleTickLength",minorAngleTickLength)
	PolarSV("minorAngleTickEmph",minorAngleTickEmph)

	if( root:Packages:PolarGraphs:u_debug )
		Print "angleTicksLocation= "+GetStrFromList("Inside;Crossing;Outside;" ,angleTicksLocation-1,";")
		Print "majorAngleTickThick= ",majorAngleTickThick
		Print "majorAngleTickLength= ",majorAngleTickLength
		Print "doMinorAngleTicks= "+GetStrFromList(u_polOffOn ,doMinorAngleTicks-1,";")
		Print "minorAngleTickThick= ",minorAngleTickThick
		Print "minorAngleTickLength= ",minorAngleTickLength
		Print "minorAngleTickEmph= ",minorAngleTickEmph
	endif

	PolarUpdated(0)
End



Macro PolarRadiusTickLabels(doRadiusTickLabels,radiusTickLabelRange,radiusTickLabelOffset,radiusTickLabelRotation,radiusTickLabelSigns,radiusTickLabelNotation,radiusAxisFontName,radiusAxisFontSize)
	Variable doRadiusTickLabels=PolarGV("doRadiusTickLabels")			// popup code  "Off;On"
	String radiusTickLabelRange=PolarGS("radiusTickLabelRange")
	Variable radiusTickLabelOffset=PolarGV("radiusTickLabelOffset")	// tick label offset, positive is "away" from axis // default 0
	String radiusTickLabelRotation=PolarGS("radiusTickLabelRotation")	// popup "-90;0;+90;+180"
	Variable radiusTickLabelSigns=PolarGV("radiusTickLabelSigns")		// popup "-, no +;- and +;no signs"	// default "no signs"
	String radiusTickLabelNotation=PolarGS("radiusTickLabelNotation")	// default is "%g", ala Printf
	String radiusAxisFontName=PolarGS("radiusAxisFontName")	
	Variable radiusAxisFontSize=PolarGV("radiusAxisFontSize")
	Prompt doRadiusTickLabels,"radius tick labels:",popup,root:Packages:PolarGraphs:u_polOffOn
	Prompt radiusTickLabelRange,"label radius ticks range, or \"0,0\" for all:"
	Prompt radiusTickLabelOffset,"label offset, positive is away from axis:"
	Prompt radiusTickLabelRotation,"label rotation:",popup,root:Packages:PolarGraphs:u_polRotPop
	Prompt radiusTickLabelSigns,"label signs:",popup," -, no +;\\M1( - and +;\\M1( no signs"
	Prompt radiusTickLabelNotation,"label format (often \"%g\", see Printf):"
	Prompt radiusAxisFontName,"radius axis font:",popup,FontList(";")+"default;"
	Prompt radiusAxisFontSize,"radius axis font size:"

	Silent 1; PauseUpdate	// Polar Radius Tick Labels...
	Variable/D radiusLabelStart = str2num(GetStrFromList(radiusTickLabelRange,0,","))	// first number
	Variable/D radiusLabelEnd = str2num(GetStrFromList(radiusTickLabelRange,1,","))	// second number
	if( (radiusLabelStart == 0) %& ( radiusLabelEnd == 0 ) )
		radiusLabelStart = -inf
		radiusLabelEnd = inf
	endif
	if( radiusLabelStart > radiusLabelEnd )
		DoAlert,1 "label radius ticks range ("+radiusTickLabelRange+") is reversed. \rFix it?"
		if (V_Flag == 1)
			sprintf radiusTickLabelRange,"%.15g,%.15g",radiusLabelEnd,radiusLabelStart
		endif
	endif

	PolarSV("doRadiusTickLabels",doRadiusTickLabels)
	PolarSS("radiusTickLabelRange",radiusTickLabelRange)
	PolarSV("radiusTickLabelOffset",radiusTickLabelOffset)
	PolarSS("radiusTickLabelRotation",radiusTickLabelRotation)
	PolarSV("radiusTickLabelSigns",radiusTickLabelSigns)
	PolarSS("radiusTickLabelNotation",radiusTickLabelNotation)
	PolarSS("radiusAxisFontName",radiusAxisFontName)
	PolarSV("radiusAxisFontSize",radiusAxisFontSize)

	if( root:Packages:PolarGraphs:u_debug )
		Print "doRadiusTickLabels= "+GetStrFromList(u_polOffOn,doRadiusTickLabels-1,";")
		Print "radiusTickLabelRange= ",radiusTickLabelRange
		Print "radiusTickLabelOffset= ",radiusTickLabelOffset
		Print "radiusTickLabelRotation= ",radiusTickLabelRotation
		Print "radiusTickLabelSigns= "+GetStrFromList("-, no +;- and +;no signs",radiusTickLabelSigns-1,";")
		Print "radiusTickLabelNotation= ",radiusTickLabelNotation
		Print "radiusAxisFontName= ",radiusAxisFontName
		Print "radiusAxisFontSize= ",radiusAxisFontSize
	endif

	PolarUpdated(0)
End

Macro PolarAngleTickLabels(doAngleTickLabels,angleTickLabelRange,angleTickLabelOffset,angleTickLabelRotation,angleTickLabelSigns,angleTickLabelNotation,angleAxisFontName,angleAxisFontSize,angleValues)
	Variable doAngleTickLabels=PolarGV("doAngleTickLabels")			// popup code  "Off;On"
	String angleTickLabelRange=PolarGS("angleTickLabelRange")
	Variable angleTickLabelOffset=PolarGV("angleTickLabelOffset")		// tick label offset, positive is "away" from axis
	String angleTickLabelRotation=PolarGS("angleTickLabelRotation")	// popup "-90;0;+90;+180"
	Variable angleTickLabelSigns=PolarGV("angleTickLabelSigns")		// popup "-, no +;- and +;no signs"
	String angleTickLabelNotation=PolarGS("angleTickLabelNotation")	// Printf format such as the default "%g"
	String angleAxisFontName=PolarGS("angleAxisFontName")
	Variable angleAxisFontSize=PolarGV("angleAxisFontSize")
	Variable angleValues=PolarGV("angleValues")							// popup code  "degrees;radians"
	Prompt doAngleTickLabels,"angle tick labels:",popup,root:Packages:PolarGraphs:u_polOffOn
	Prompt angleTickLabelRange,"label angle ticks start,range (0,0 = all):"
	Prompt angleTickLabelOffset,"label offset, positive is away from axis:"
	Prompt angleTickLabelRotation,"label rotation:",popup,root:Packages:PolarGraphs:u_polRotPop
	Prompt angleTickLabelSigns,"label signs:",popup," -, no +;\\M1( - and +;\\M1( no signs"
	Prompt angleTickLabelNotation,"label format (often \"%g\", see Printf):"
	Prompt angleAxisFontName,"angle axis font name:",popup,FontList(";")+"default;"
	Prompt angleAxisFontSize,"angle axis font size:"
	Prompt angleValues,"label angle values in:",popup,root:Packages:PolarGraphs:u_polAngleUnitsPop

	Silent 1; PauseUpdate	// Polar Angle Tick Labels
	PolarSV("doAngleTickLabels",doAngleTickLabels)
	PolarSS("angleTickLabelRange",angleTickLabelRange)
	PolarSV("angleTickLabelOffset",angleTickLabelOffset)
	PolarSS("angleTickLabelRotation",angleTickLabelRotation)
	PolarSV("angleTickLabelSigns",angleTickLabelSigns)
	PolarSS("angleTickLabelNotation",angleTickLabelNotation)
	PolarSS("angleAxisFontName",angleAxisFontName)
	PolarSV("angleAxisFontSize",angleAxisFontSize)
	PolarSV("angleValues",angleValues)

	if( root:Packages:PolarGraphs:u_debug )
		Print "doAngleTickLabels= "+GetStrFromList(u_polOffOn,doAngleTickLabels-1,";")
		Print "angleTickLabelRange= ",angleTickLabelRange
		Print "angleTickLabelOffset= ",angleTickLabelOffset
		Print "angleTickLabelRotation= ",angleTickLabelRotation
		Print "angleTickLabelSigns= "+GetStrFromList("-, no +;- and +;no signs",angleTickLabelSigns-1,";")
		Print "angleTickLabelNotation= ",angleTickLabelNotation
		Print "angleAxisFontName= ",angleAxisFontName
		Print "angleAxisFontSize= ",angleAxisFontSize
		Print "angleValues= "+GetStrFromList(u_polAngleUnitsPop,angleValues-1,";")
	endif

	PolarUpdated(0)
End

Macro PolarGrid(doPolarGrids,minGridSpacing,majorGridLineSize,minorGridLineSize,majorGridStyle,minorGridStyle,majorGridColorNdx,minorGridColorNdx,useCircles,maxArcLine)
	Variable doPolarGrids=PolarGV("doPolarGrids")			// Variable popup code:  "Off;Major Only; On"
	Variable/D minGridSpacing=PolarGV("minGridSpacing") 	// smallest grid spacing in points, 0 for finest grids.
	Variable majorGridLineSize=PolarGV("majorGridLineSize")
	Variable minorGridLineSize=PolarGV("minorGridLineSize")
	Variable majorGridStyle=PolarGV("majorGridStyle")		// Variable popup code (style=code-1)
	Variable minorGridStyle=PolarGV("minorGridStyle")		// Variable popup code (style=code-1)
	Variable majorGridColorNdx=PolarGV("majorGridColorNdx")
	Variable minorGridColorNdx=PolarGV("minorGridColorNdx")
	Variable useCircles=PolarGV("useCircles")					// variable popup code "polygons;circles"	(use for complete circles)
	Variable maxArcLine=PolarGV("maxArcLine")
	Prompt doPolarGrids,"polar grids:",popup,"Off;Major Only; On;"
	Prompt minGridSpacing,"min grid spacing (points), 0 is no min:"
	Prompt majorGridLineSize,"major grid line thickness (points):"
	Prompt minorGridLineSize,"minor grid line thickness (points):"
	Prompt majorGridStyle,"major grid style:",popup,root:Packages:PolarGraphs:u_polLineStylePop
	Prompt minorGridStyle,"minor grid style:",popup,root:Packages:PolarGraphs:u_polLineStylePop
	Prompt majorGridColorNdx,"major grid color:",popup,root:Packages:PolarGraphs:u_colorList
	Prompt minorGridColorNdx,"minor grid color:",popup,root:Packages:PolarGraphs:u_colorList
	Prompt useCircles,"for full circles, use:",popup,"polygons;circles;"
	Prompt maxArcLine,"longest arc line segment (points):"

	Silent 1; PauseUpdate // Polar Grid...
	PolarSV("doPolarGrids",doPolarGrids)
	PolarSV("minGridSpacing",minGridSpacing)
	PolarSV("majorGridLineSize",majorGridLineSize)
	PolarSV("minorGridLineSize",minorGridLineSize)
	PolarSV("majorGridStyle",majorGridStyle)
	PolarSV("minorGridStyle",minorGridStyle)
	PolarSV("majorGridColorNdx",majorGridColorNdx)
	PolarSV("minorGridColorNdx",minorGridColorNdx)
	PolarSV("useCircles",useCircles)
	PolarSV("maxArcLine",maxArcLine)

	if( root:Packages:PolarGraphs:u_debug )
		Print "doPolarGrids= "+StringFromList(doPolarGrids-1,"Off;Major Only; On")
		Print "minGridSpacing= ",minGridSpacing
		Print "majorGridLineSize= ",majorGridLineSize
		Print "minorGridLineSize= ",minorGridLineSize
		Print "majorGridStyle= "+StringFromList(majorGridStyle-1,u_polLineStylePop)
		Print "minorGridStyle= "+StringFromList(minorGridStyle-1,u_polLineStylePop)
		Print "majorGridColorNdx= "+StringFromList(majorGridColorNdx-1,u_colorList)
		Print "minorGridColorNdx= "+StringFromList(minorGridColorNdx-1,u_colorList)
		Print "useCircles= "+StringFromList(useCircles-1,"polygons;circles;")
		Print "maxArcLine= ",maxArcLine
	endif

	PolarUpdated(0)
End

Macro KillTargetPolarGraph()
	Silent 1; PauseUpdate	// Kill Target Polar Graph
	String graphName= WinName(0, 1)		// target graph
	if( strlen(graphName) )
		UnRegisterPolarGraph(graphName)
		DoWindow/K $graphName
	endif
EndMacro

// Removes Shadow waves, makes graph not a polar graph
Function UnRegisterPolarGraph(graphName)
	String graphName
	String listOfYWaves="",listOfXWaves=""
	Variable ylen
	if( strlen(graphName) )
		if( DataBaseBagAndKeyExist(graphName,"appendShadowYWaves")  )	// side effect makes graphName current bag
			listOfYWaves+= PolarGS("appendShadowYWaves")
		endif
		if( DataBaseBagAndKeyExist(graphName,"appendShadowXWaves")  )	// side effect makes graphName current bag
			listOfXWaves+= PolarGS("appendShadowXWaves")
		endif
		String currBag= GetDataBag()
		if( (CmpStr(currBag,"_default_")!=0) %& (CmpStr(currBag,graphName)==0) )
			DataBaseKillCurrentBag()	// now graph doesn't look like a polar graph
			DataBaseCurrentBag("_default_")	// ideally the top polar graph, but this prevents bug in NewPolarGraph().
		endif
		ylen=strlen(listOfYWaves)
		if( ylen > 0 )
			if( CmpStr(listOfYWaves[ylen-1],",") == 0 )
				listOfYWaves= listOfYWaves[0,ylen-2]
			endif
			Execute "RemoveFromGraph "+listOfYWaves	// trailing comma does hurt
		endif
		Execute "KillWaves/Z " +listOfXWaves + listOfYWaves	// listOfXWaves trailing comma doesn't hurt
		// Window can now be killed.
	endif
	return 0
End

// Redraw all Polar Axes, grids, and labels
// Currently only works for manual tick marks.
// much work to be done here.
Function FPolarAxesRedraw()
	// should test; if top graph not PolarGraph, abort
	String win=WinName(0,1)
	if( ! IsPolarGraph(win) )
		Abort win+" isn\'t a polar graph!"
	endif
	Variable/D xmin,xmax,ymin,ymax
	GetAxis /Q bottom; xmin=V_min;xmax=V_max	// Drawn coordinates
	GetAxis /Q left; ymin=V_min;ymax=V_max		// Drawn coordinates

	PolarTicks(xmin,xmax,ymin,ymax)	// outputs are globals u_polInnerRadius, etc that establish tick and grid locations in data coordinates.

	Variable/D minorRadTicks,minorAngleTicks,minspacing
	minspacing= PointsToDrawn(PolarGV("minGridSpacing"))
	NVAR u_polMinorRadiusTicks=root:Packages:PolarGraphs:u_polMinorRadiusTicks
	NVAR u_polMinorAngleTicks=root:Packages:PolarGraphs:u_polMinorAngleTicks
	NVAR u_polOuterRadius=root:Packages:PolarGraphs:u_polOuterRadius
	NVAR u_polInnerRadius=root:Packages:PolarGraphs:u_polInnerRadius
	NVAR u_polMajorRadiusInc=root:Packages:PolarGraphs:u_polMajorRadiusInc
	NVAR u_polAngleRange=root:Packages:PolarGraphs:u_polAngleRange
	NVAR u_polMajorAngleInc=root:Packages:PolarGraphs:u_polMajorAngleInc
	NVAR u_debug=root:Packages:PolarGraphs:u_debug
	NVAR u_polAngle0=root:Packages:PolarGraphs:u_polAngle0
	minorRadTicks= u_polMinorRadiusTicks
	minorAngleTicks= u_polMinorAngleTicks
	if( PolarGV("doMinorRadiusTicks") == 1 )	// off
		minorRadTicks= 0
	endif
	if( PolarGV("doMinorAngleTicks") == 1 )	// off
		minorAngleTicks= 0	// no ticks
	endif
	SetDrawLayer /K ProgBack
	if( PolarGV("doPolarGrids")!= 1)
		Variable numMajorCircles= abs((u_polOuterRadius-u_polInnerRadius)/u_polMajorRadiusInc)
		Variable numMajorLines= abs(u_polAngleRange/u_polMajorAngleInc)
	if( u_debug )
		Print numMajorCircles," major circles, ",numMajorLines," major lines"
	endif
		if( numMajorCircles+numMajorLines > 100 )		// Change this number, if you wish
			Abort "Too many major ticks in grid, use the Polar Axes Ticks macro"
		endif
		minorAngleTicks= FPolarGrid(u_polInnerRadius,u_polOuterRadius,u_polMajorRadiusInc,minorRadTicks,u_polAngle0,u_polAngleRange,u_polMajorAngleInc,minorAngleTicks,xmin,xmax,ymin,ymax,minspacing)
	endif
	DoUpdate	// show progress (the polar grid)
	Make/D/O/N=2 W_tmp= NaN
	Variable numRadiusAxes= AnglesForRadiusAxes(W_tmp,u_polAngle0,u_polAngleRange,u_polMajorAngleInc,minorAngleTicks)

	if( u_debug )
		Print numRadiusAxes," radius axes: ", W_tmp[0],"...", W_tmp[numRadiusAxes-1], "minorRadTicks= ",minorRadTicks,"radiusInc= ",u_polMajorRadiusInc
	endif

	if( u_debug )
		SetDrawLayer /K UserAxes;SetDrawLayer /K ProgAxes
		SetDrawLayer /K UserFront	// labels
		SetDrawLayer /K ProgFront	// axes, so that data doesn't hide the axes we are debugging
	else
		SetDrawLayer /K UserFront;SetDrawLayer /K ProgFront
		// When debugging is removed, only the next two lines need remain
		SetDrawLayer /K UserAxes	// labels go here
		SetDrawLayer /K ProgAxes	// axes and tickmarks go here
	endif
	if( numRadiusAxes > 0 )	// radius axes, ticks, and labels
		FPolarRadiusAxes(u_polInnerRadius,u_polOuterRadius,u_polMajorRadiusInc,minorRadTicks,numRadiusAxes,W_tmp,xmin,xmax,ymin,ymax)
	endif
	DoUpdate	// show progress

	// Note: RadiiForAngleAxes() expects W_tmp to contain the data coordinate angles where the radius axes were drawn.
	// on output W_tmp contains the (data) radii for the angle axes.
	// This might not work if the angles are needed by FPolarAngleAxes (in which case we'll just add another wave)
	Variable numAngleAxes= RadiiForAngleAxes(numRadiusAxes,W_tmp,u_polInnerRadius,u_polOuterRadius,u_polMajorRadiusInc,minorRadTicks)
	if( u_debug )
		Print numAngleAxes," angle axes: ", W_tmp[0],"...", W_tmp[numAngleAxes-1]
	endif

	if( numAngleAxes > 0 )	// angle  axes, ticks, and labels
		FPolarAngleAxes(u_polInnerRadius,u_polOuterRadius,u_polMajorRadiusInc,u_polAngle0,u_polAngleRange,u_polMajorAngleInc,minorAngleTicks,numAngleAxes,W_tmp,xmin,xmax,ymin,ymax,minspacing)
	endif
	KillWaves/Z W_tmp
	SetDrawLayer UserFront
	DoUpdate	// show progress
	PolarFixTargetAxisRanges()	// prevent autoscale, because shadow waves are infinite until procedures are compiled
	return 0
End

// Inputs are user selections, as returned by PolarGV and PolarGS
// Outputs are	u_polInnerRadius,u_polOuterRadius,u_polMajorRadiusInc (in data coordinates) (only linear radius supported currently)
// and			u_polMinorRadiusTicks
// and			u_polAngle0,u_polAngleRange,u_polMajorAngleInc, all in radians (data coordinates)
// and			u_polMinorAngleTicks
Function PolarTicks(xmin,xmax,ymin,ymax)
	Variable/D xmin,xmax,ymin,ymax
	
	NVAR u_polInnerRadius=root:Packages:PolarGraphs:u_polInnerRadius
	NVAR u_polOuterRadius=root:Packages:PolarGraphs:u_polOuterRadius
	NVAR V_max=root:Packages:PolarGraphs:V_max
	// Radius Range
	Variable doMajorRadiusTicks
	if( PolarGV("doRadiusRange")==2 )		// manual radius range
		u_polInnerRadius=PolarGV("innerRadius")
		u_polOuterRadius=PolarGV("outerRadius")
	else										// auto radius is 0,NiceNumber(max radius) when implemented
		PolarRadiusDrawnRange()
		u_polOuterRadius= PolarRadiusFunctionInv(V_max,PolarGV("radiusFunction"),PolarGV("valueAtCenter"))
//		u_polOuterRadius= NiceNumber(u_polOuterRadius,u_polInnerRadius)
		u_polInnerRadius=PolarGV("valueAtCenter")
	endif
	
	if( u_polInnerRadius > u_polOuterRadius )
		Variable/D tmp=u_polOuterRadius
		u_polOuterRadius= u_polInnerRadius
		u_polInnerRadius= tmp
	endif
	
	// Radius Ticks
	NVAR u_polMajorRadiusInc=root:Packages:PolarGraphs:u_polMajorRadiusInc
	NVAR u_polMinorRadiusTicks=root:Packages:PolarGraphs:u_polMinorRadiusTicks
	if(  PolarGV("doMajorRadiusTicks")==2 )	// auto radius ticks
		// PolarRadiusAutoTicks()
		u_polMajorRadiusInc=PolarGV("majorRadiusInc")			// temporary, until PolarRadiusAutoTicks() is working
		u_polMinorRadiusTicks=PolarGV("minorRadiusTicks")
	else											// manual or off radius ticks
		u_polMajorRadiusInc=PolarGV("majorRadiusInc")
		u_polMinorRadiusTicks=PolarGV("minorRadiusTicks")
	endif
	
	// Angle Range
	NVAR u_polAngle0=root:Packages:PolarGraphs:u_polAngle0
	NVAR u_polAngleRange=root:Packages:PolarGraphs:u_polAngleRange
	NVAR V_min=root:Packages:PolarGraphs:V_min
	if( PolarGV("doAngleRange")==2 )			// manual angle range
		u_polAngle0=DegToRad(PolarGV("angle0"))
		u_polAngleRange=DegToRad(PolarGV("angleRange"))
	else											// auto angle
		PolarAutoScaleAngle()
		u_polAngle0=V_min
		u_polAngleRange=V_max-V_min
	endif
	 u_polAngleRange= limit(u_polAngleRange,-2*Pi,2*Pi)
	 
	// Angle Ticks
	NVAR u_polMajorAngleInc=root:Packages:PolarGraphs:u_polMajorAngleInc
	NVAR u_polMinorAngleTicks=root:Packages:PolarGraphs:u_polMinorAngleTicks
	if(  PolarGV("doMajorAngleTicks")==2 )	// auto radius ticks
		// PolarAngleAutoTicks()
		u_polMajorAngleInc=DegToRad(PolarGV("majorAngleInc"))			// temporary, until PolarAngleAutoTicks() is working
		u_polMinorAngleTicks=PolarGV("minorAngleTicks")
	else											// manual or off angle ticks
		u_polMajorAngleInc=DegToRad(PolarGV("majorAngleInc"))
		u_polMinorAngleTicks=PolarGV("minorAngleTicks")
	endif
	return 0
End

// numRadiusAxes= 
Function AnglesForRadiusAxes(wAxisAngles,angle0,angleRange,angleInc,angleMinorTicks)
	Wave/D wAxisAngles		// these angle are all in data coordinates, NOT drawn coordinates.
	Variable/D angle0,angleRange,angleInc,angleMinorTicks
	Variable numRadiusAxes=0
	
	Variable where=PolarGV("radiusAxesWhere")		// Variable popup code: "Off;Angle Start;Angle Middle;Angle End;Angle Start and End;, etc, 6-16 are lists of angles in degrees
	
	if( where > 1 )	// 1 is "off"
		Variable/D angle,lastAngle= angle0 + angleRange
		String str,angleList=""
		if( where == limit(where,2,5) )
			numRadiusAxes= 1
			if( where == 2 )	// Angle Start
				wAxisAngles= {angle0,NaN}
			endif
			if( where == 3 )	// Angle Middle
				wAxisAngles= { angle0+angleRange/2,NaN}
			endif
			if( where == 4 )	// Angle End
				wAxisAngles= { lastAngle,NaN}
			endif
			if( where == 5 )	// Angle Start and End
				wAxisAngles= {angle0,lastAngle}
				numRadiusAxes= 2
			endif
		endif
		SVAR u_polRadAxesWherePop=root:Packages:PolarGraphs:u_polRadAxesWherePop
		if( where == limit(where,6,16) )	// angles listed in popup in degrees
			angleList = StringFromList(where-1,u_polRadAxesWherePop)
		endif
		if( where == 17 )	// all major angles, skip string list; output to wave directly
			numRadiusAxes = trunc(angleRange / angleInc + 1)
			Redimension/N=(max(2,numRadiusAxes)) wAxisAngles
			wAxisAngles= angle0 + p * angleInc					// radians
		endif
		if( where == 18 )	// 18 is list of angles, for example "-90,0,90,180"
			angleList=PolarGS("radiusAxesAngleList")
		endif
	
		if( strlen(angleList) > 0 )
			// angleList has angles in degrees, convert to wave values in radians
			do
				str = StringFromList(numRadiusAxes,angleList,",")
				if( strlen(str) == 0 )
					break
				endif
				InsertPoints numRadiusAxes,1,wAxisAngles // append
				wAxisAngles[numRadiusAxes]=DegToRad(str2num(str))
				numRadiusAxes += 1
			while (1)
		endif
	endif
	return numRadiusAxes
End


// Draws radius axes (the "spokes")
// All angles in data coordinates and radians, radii in data coordinates.
Function FPolarRadiusAxes(radiusStart,radiusEnd,radiusInc,radiusMinorTicks,numRadiusAxes,wAxisAngles,xmin,xmax,ymin,ymax)
	Variable/D radiusStart,radiusEnd		//  (data coordinates).
	Variable/D radiusInc,radiusMinorTicks	// radiusMinorTicks == 0 if none
	Variable numRadiusAxes
	Wave/D wAxisAngles	// angles, in radians (data coordinates).
	Variable/D xmin,xmax,ymin,ymax	// plot extent in drawn coordinates
	
	radiusInc= abs(radiusInc)
	radiusMinorTicks=round(abs(radiusMinorTicks))

	Variable/D clipped,radius,radiusDraw,deltaRadius=radiusInc
	Variable/D x1,y1,x2,y2,cosAngle,sinAngle,angleDraw,lastAngle
	Variable i=0,numMinorTicks=0,centerLabeled=0,thick,inhibited
	NVAR u_x1=root:Packages:PolarGraphs:u_x1
	NVAR u_y1=root:Packages:PolarGraphs:u_y1
	NVAR u_x2=root:Packages:PolarGraphs:u_x2
	NVAR u_y2=root:Packages:PolarGraphs:u_y2
	
	String colorSpec= GetRGBColorFromList(PolarGV("radiusAxisColorNdx"))
	Variable doMajorRadiusTicks= PolarGV("doMajorRadiusTicks")
	Variable doRadiusTickLabels= PolarGV("doRadiusTickLabels")
	Variable radiusAxisThick= PolarGV("radiusAxisThick")
	Variable majorRadiusTickThick= PolarGV("majorRadiusTickThick")
	Variable minorRadiusTickThick= PolarGV("minorRadiusTickThick")
	Variable/D lblOrient= PolarGV("radiusTickLabelRotation")
	Variable radiusFunction=PolarGV("radiusFunction")
	Variable/D valueAtCenter= PolarGV("valueAtCenter")
	Variable zeroAngleWhere= PolarGV("zeroAngleWhere")	// popup code, "bottom;right;top;left", -90;0;+90;+180
	Variable angleDirection= PolarGV("angleDirection")		// popup code, "clockwise;counter-clockwise"


	String str = PolarGS("radiusTickLabelRange")	// label range, NOT the tick range
	Variable/D radiusLabelStart = str2num(StringFromList(0,str,","))	// first number
	Variable/D radiusLabelEnd = str2num(StringFromList(1,str,","))	// second number
	if( (radiusLabelStart == 0) %& ( radiusLabelEnd == 0 ) )
		radiusLabelStart = -inf
		radiusLabelEnd = inf
	endif

	String fmt= PolarGS("radiusTickLabelNotation")

	if( radiusMinorTicks > 0 )		// same as FPolarGrid minor tick calculations
		deltaRadius= radiusInc/(radiusMinorTicks+1)
		numMinorTicks=floor(1+ (radiusMinorTicks+1) * abs((radiusEnd-radiusStart)/radiusInc)) // total ticks, was round(...)
	endif
	
	if( (numRadiusAxes > 0) )
		Variable/D radStartDraw=PolarRadiusFunction(radiusStart,radiusFunction,valueAtCenter)	// drawn radius
		Variable/D radEndDraw=PolarRadiusFunction(radiusEnd,radiusFunction,valueAtCenter)	// drawn radius
		Variable maj,ti,a= 0
		Variable/D majTickLen= PointsToDrawn(PolarGV("majorRadiusTickLength"))
		Variable/D minTickLen= PointsToDrawn(PolarGV("minorRadiusTickLength"))
		Variable/D lblOffset= PointsToDrawn(PolarGV("radiusTickLabelOffset"))
		Variable/D tickOrient
		NVAR u_debug=root:Packages:PolarGraphs:u_debug
if( u_debug )
		SetDrawLayer UserFront	// labels
else
		SetDrawLayer UserAxes	// labels
endif
		SetDrawEnv xcoord= bottom,ycoord= left,save
		Execute "SetDrawEnv fname=\""+PolarGS("radiusAxisFontName")+"\",save"
		Execute "SetDrawEnv fsize="+PolarGS("radiusAxisFontSize")+",save"
if( u_debug )
		SetDrawLayer ProgFront	// axes
else
		SetDrawLayer ProgAxes	// axes
endif
		SetDrawEnv xcoord= bottom,ycoord= left,save
		Execute "SetDrawEnv linefgc="+colorSpec+",linebgc="+colorSpec+",save"
		SetDrawEnv fillpat= 0,dash=0,save
		
		do

			SetDrawEnv linethick=radiusAxisThick,save	// radiusAxisThick could be zero!
			angleDraw= PolarAngleFunction(wAxisAngles[a],zeroAngleWhere,angleDirection,2)		// convert data angle in wAxisAngles to drawn angle
			cosAngle= cos(angleDraw)
			sinAngle= sin(angleDraw)
			x1= radStartDraw * cosAngle
			y1=  radStartDraw *sinAngle
			x2=  radEndDraw * cosAngle
			y2=  radEndDraw *sinAngle
			 tickOrient= RadiusTickOrientation(angleDraw,numRadiusAxes,wAxisAngles) //-Pi/2	// perpendicular ticks: -Pi/2 causes labels to be drawn clockwise of the axis; use +Pi/2 for ccw label position
			clipped= DrawClippedLineSize(x1,y1,x2,y2,xmin,xmax,ymin,ymax,radiusAxisThick)	// 0 if invisible, 1 if not clipped, 2 if only x1,y1 clipped, 3 or 4 if x2,y2 clipped
			// Draw Tick marks, if turned on, and within the allowable range
			if( (clipped != 0) %& (doMajorRadiusTicks != 1)  )
				// Minor Ticks
				if( numMinorTicks > 0 )
					ti= 1
					SetDrawEnv linethick=minorRadiusTickThick,save
					radius= radiusStart+deltaRadius	// we skip the major radii, to avoid two arcs at the same location
					do
						radiusDraw= PolarRadiusFunction(radius,radiusFunction,valueAtCenter)  // drawn radius
						DrawTick(radiusDraw,angleDraw,minorRadiusTickThick,minTickLen,0,tickOrient,xmin,xmax,ymin,ymax)
						ti += 1
						if( mod(ti,radiusMinorTicks+1)==0 )	// we skip the major radii, to avoid two arcs at the same location
							ti += 1
						endif
						radius = radiusStart + ti * deltaRadius	// data radius
					while( ti <  numMinorTicks )
				endif
				// Major Ticks
				radius= radiusStart
				maj=0
				SetDrawEnv linethick=majorRadiusTickThick,save
				do	// Major Ticks
					// no major tick at center if there is more than one axis
					if( (radius != valueAtCenter) %| (numRadiusAxes == 1) )
						thick= majorRadiusTickThick	// majorRadiusTickThick could be zero
						inhibited= 0						// labelling okay
					else
						thick= 0							// don't draw tick, just locate it
						inhibited = centerLabeled	 == 1	// only first center value is labelled.
						centerLabeled= 1					// after LabelTick, the center is labelled (or never will be)
					endif
					inhibited = inhibited %|  (radius< radiusLabelStart) %| (radius> radiusLabelEnd)
					radiusDraw= PolarRadiusFunction(radius,radiusFunction,valueAtCenter)  // drawn radius
					clipped= DrawTick(radiusDraw,angleDraw,thick,majTickLen,lblOffset,tickOrient,xmin,xmax,ymin,ymax)
					if( (clipped > 0) %& (doRadiusTickLabels != 1) %& (!inhibited) )
if( u_debug )
						SetDrawLayer UserFront	// labels
else
						SetDrawLayer UserAxes	// labels
endif
						NVAR u_x2=root:Packages:PolarGraphs:u_x2
						NVAR u_y2=root:Packages:PolarGraphs:u_y2
						LabelTick(u_x2,u_y2,fmt,radius,lblOrient,angleDraw+tickOrient,xmin,xmax,ymin,ymax)
if( u_debug )
						SetDrawLayer ProgFront	// axes
else
						SetDrawLayer ProgAxes	// axes
endif
					endif
					maj += 1
					radius = radiusStart + maj * radiusInc
if( u_debug)
//print "last tick clipped,thick=",clipped,thick," next tick at radius=",radius,"radiusEnd=",radiusEnd
endif
				while( radius <= radiusEnd )
			endif
			a+= 1
		while(a < numRadiusAxes )
	endif
End

// returns +/- Pi/2 to produce perpendicular ticks.
// -Pi/2 causes labels to be drawn clockwise of the axis;
// +Pi/2 causes labels to be drawn counter-clockwise of the axis.
Function/D RadiusTickOrientation(axisAngle,numRadiusAxes,wAxisAngles)	// someday add another param for user setting
	Variable/D axisAngle		// the angle at which this particular axis will be drawn (in drawn coordinates)
	Variable numRadiusAxes	// number of angles in wAxisAngles, currently not used.
	Wave/D wAxisAngles		// angles, in data coordinates and radians, where radius axes will be drawn, currently not used.

	// we will assume that the most often labelled radius axes are the four standard axes at 0,90,180,-90
	// In the absence of a user setting for selection of where the labels will be drawn,
	// we choose to label axes to the left of vertical axes, and below horizontal axes
	// horizontal axes to the left of x==0 are labelled ccw (+Pi/2), right of x==0 are labelled cw (-Pi/2) 
	// vertical axes above the y==0 line are labelled ccw (+Pi/2), below the line are labelled cw (-Pi/2)
	Variable/D tickOrient,sinAngle=sin(axisAngle),sincos45=sin(Pi/4),ccw=Pi/2
	if( sinAngle <= sincos45 )	// horizontal axis
		if( cos(axisAngle) > 0 )	// right of x==0, label clockwise
			tickOrient= -ccw
		else						// left of x==0, label counter-clockwise
			tickOrient= ccw
		endif
	else	// vertical axis
		if( sinAngle > 0 )			// above y==0, label counter-clockwise
			tickOrient= ccw
		else						// below y==0, label clockwise
			tickOrient= -ccw
		endif
	endif
	return tickOrient
End



// for now this draws a crossing tick; later we can add more parameters
// On output, u_x1,u_y1 is location of the far (unlabeled) end of the tickmark.
// u_x2,u_y2 is the (possibly offset) location of the near (labeled) end of the tickmark; the label anchor goes here.
// returns clipped
Function/D DrawTick(radius,angle,lineThick,ticklen,lblOffset,tickOrient,xmin,xmax,ymin,ymax)
	Variable/D radius,angle		// position of tick mark in drawn polar coordinates
	Variable lineThick			// points; if zero, don't actually draw it.
	Variable/D ticklen,lblOffset	//  in drawn coordinates
	Variable/D tickOrient			// add this to angle to set the tickmark orientation, 0/180 for parallel, +/-Pi/2 for perpendicular
	Variable/D xmin,xmax,ymin,ymax	// plot extent in drawn coordinates

	Variable/D x1,y1,x2,y2,cosAngle,sinAngle,clipped,halfTick=ticklen/2
	NVAR u_x1=root:Packages:PolarGraphs:u_x1
	NVAR u_y1=root:Packages:PolarGraphs:u_y1
	NVAR u_x2=root:Packages:PolarGraphs:u_x2
	NVAR u_y2=root:Packages:PolarGraphs:u_y2
	
	cosAngle= cos(angle); sinAngle= sin(angle)
	x1= radius * cosAngle; y1= radius *sinAngle 		// position of tick anchor on axis
	angle += tickOrient
	cosAngle= cos(angle); sinAngle= sin(angle)
	// far end crossing tick mark calculations
	x1-= cosAngle * halfTick; y1 -= sinAngle*halfTick
	// Given far end, calculate near end
	x2= x1+cosAngle*ticklen;y2=y1+sinAngle*ticklen
	// Draw the tick mark (or not if lineThick==0)
	clipped= DrawClippedLineSize(x1,y1,x2,y2,xmin,xmax,ymin,ymax,lineThick)
	// Apply label standoff and store in u_x2,u_y2
	u_x2 = x2+cosAngle * lblOffset; u_y2 = y2 + sinAngle *lblOffset
	return clipped
End


// no minor radius grid (arcs) if  radiusMinorTicks==0, no minor angle grid (spokes) if angleMinorTicks==0
// minspacing is used to prevent grids from colliding at smaller radii.  Set to 0 if you want same number of spokes/angle regardless of radius.
// All angles in radians.
// Returns revised angleMinorTicks, because the minspacing limitation may prevent that many minor ticks from being used.
Function FPolarGrid(radiusStart,radiusEnd,radiusInc,radiusMinorTicks,angle0,angleRange,angleInc,angleMinorTicks,xmin,xmax,ymin,ymax,minspacing)
	Variable/D radiusStart,radiusEnd,radiusInc,radiusMinorTicks	// radii in data coordinates, NOT drawn coordinates
	Variable/D angle0,angleRange,angleInc,angleMinorTicks	// angles in data coordinates, NOT drawn coordinates.
	Variable/D xmin,xmax,ymin,ymax
	Variable/D minspacing					// affects only the spokes

	SetDrawEnv xcoord= bottom,ycoord= left
	SetDrawEnv fname= "default",fillpat= 0,textxjust= 1,textyjust= 1,save

	radiusInc= abs(radiusInc)
	radiusMinorTicks=round(abs(radiusMinorTicks))
	// don't abs(angleInc), negative angleIncs are legal!
	angleMinorTicks=round(abs(angleMinorTicks))

	NVAR u_segsPerMinorArc=root:Packages:PolarGraphs:u_segsPerMinorArc
	Variable zeroAngleWhere= PolarGV("zeroAngleWhere")	// popup code, "bottom;right;top;left", -90;0;+90;+180
	Variable angleDirection= PolarGV("angleDirection")		// popup code, "clockwise;counter-clockwise"
	Variable/D angle0Draw= PolarAngleFunction(angle0,zeroAngleWhere,angleDirection,2)	// drawn angle
	Variable/D angleDir= -sign(1- angleDirection )			// -1 if clockwise (angles drawn in opposite direction), 1 if ccw
	Variable/D angleIncDraw= angleInc * angleDir
	Variable/D angleRangeDraw= angleRange * angleDir		// drawn angle
	Variable/D maxDeltaAngleDraw= min( DegToRad(PolarGV("maxArcLine")),angleIncDraw/(angleMinorTicks+1)/u_segsPerMinorArc)

	Variable/D valueAtCenter=PolarGV("valueAtCenter")
	Variable radiusFunction=PolarGV("radiusFunction")
	Variable/D radStartDraw=PolarRadiusFunction(radiusStart,radiusFunction,valueAtCenter)	// drawn radius
	Variable/D radEndDraw=PolarRadiusFunction(radiusEnd,radiusFunction,valueAtCenter)	// drawn radius
	Variable/D radius,deltaRadius,adjustedRadStart
	Variable/D clipped,x1,y1,x2,y2,cosAngle,sinAngle,angle,angleDraw,lastAngle
	Variable i,numMinorTicks,linesize
	Variable wantCircles=PolarGV("useCircles")==2	// DrawArc must also make sure each circle fits in xmin,xmax,ymin,ymax
	String colorSpec

	SetDrawEnv gstart	// begin grids group

	// draw minor grid first, so that the major grids are drawn on top
	linesize= PolarGV("minorGridLineSize")
	if( (PolarGV("doPolarGrids") != 2) %& (linesize > 0) )
		colorSpec= GetRGBColorFromList(PolarGV("minorGridColorNdx"))
		Execute "SetDrawEnv linefgc="+colorSpec+",linebgc="+colorSpec
		SetDrawEnv dash= PolarGV("minorGridStyle")-1,linethick=(linesize),save

		if( (radiusMinorTicks > 0) %& ( linesize > 0) )
			deltaRadius= radiusInc/(radiusMinorTicks+1)
			numMinorTicks=floor(1+ (radiusMinorTicks+1) * abs((radiusEnd-radiusStart)/radiusInc))	// total minor ticks.

			radius= radiusStart+deltaRadius	// we skip the major radii, to avoid two arcs at the same location
			i=1
			do	//draw minor radius grid (arcs)
				radius= PolarRadiusFunction(radius,radiusFunction,valueAtCenter)  // drawn radius
				PolarDrawArc(radius,angle0Draw,angleRangeDraw,maxDeltaAngleDraw,xmin,xmax,ymin,ymax,wantCircles,lineSize)
				i += 1
				if( mod(i,radiusMinorTicks+1)==0 )	// we skip the major radii, to avoid two arcs at the same location
					i += 1
				endif
				radius = radiusStart + i * deltaRadius	// data radius
			while(i <  numMinorTicks)
		endif
		if( (angleMinorTicks>0) %& (angleInc!=0) )
			Make/D/O/N=(angleMinorTicks+1) W_adjustedRadii	// indexed by mod(i,angleTicks+1) (revised angleMinorTicks guaranteed less than original angleMinorTicks)
			Variable ndx
			angleMinorTicks= CalcAdjustedRadiuses(W_adjustedRadii,angleMinorTicks,angleInc,radiusStart,radiusEnd,radiusInc,minspacing,radiusFunction,valueAtCenter)
			if( angleMinorTicks>0 )
				Variable/D deltaAngle= angleInc/(angleMinorTicks+1)	// data angle units
				numMinorTicks=floor(1+ (angleMinorTicks+1) * abs(angleRange/angleInc))	// total minor ticks, was round(...)
				angle= angle0 + deltaAngle	// we skip the major angles, to avoid two spokes at the same location
				i=1
				do	//draw minor angle grid (spokes)
					angleDraw= PolarAngleFunction(angle,zeroAngleWhere,angleDirection,2)	// drawn angle
					cosAngle= cos(angleDraw)
					sinAngle= sin(angleDraw)
					adjustedRadStart= W_adjustedRadii[mod(i,angleMinorTicks+1)]	// data radius
					adjustedRadStart=PolarRadiusFunction(adjustedRadStart,radiusFunction,valueAtCenter)  // drawn radius
					x1= adjustedRadStart * cosAngle
					y1=  adjustedRadStart * sinAngle
					x2=  radEndDraw * cosAngle
					y2=  radEndDraw * sinAngle
					if( adjustedRadStart < radEndDraw )	// Drawn radii compared
						clipped= DrawClippedLine(x1,y1,x2,y2,xmin,xmax,ymin,ymax)	// 0 if invisible, 1 if not clipped, 2 if only x1,y1 clipped, 3 or 4 if x2,y2 clipped
					endif
					i += 1
					if( mod(i,angleMinorTicks+1)==0 )	// we skip the major angles, to avoid two spokes at the same location
						i += 1
					endif
					angle= angle0 + i* deltaAngle
				while(i <  numMinorTicks)
			else
				Print "*** Min grid spacing of "+PolarGS("minGridSpacing")+" points prevented minor grids from being drawn."
				Print "*** You can decrease min grid spacing with the \"Polar Grid\" macro."
			endif
			KillWaves/Z W_adjustedRadii
		endif
	endif

	// draw major grids
	linesize= PolarGV("majorGridLineSize")
	colorSpec= GetRGBColorFromList(PolarGV("majorGridColorNdx"))
	Execute "SetDrawEnv linefgc="+colorSpec+",linebgc="+colorSpec
	SetDrawEnv dash= PolarGV("majorGridStyle")-1,linethick=linesize,save		// begin major grids group

	if( PolarGV("doMajorRadiusTicks") != 1  %& ( linesize > 0) )
		radius= radiusStart
		i=0
		do	// Major Rings
			radius= PolarRadiusFunction(radius,radiusFunction,valueAtCenter)  // drawn radius
			PolarDrawArc(radius,angle0Draw,angleRangeDraw,maxDeltaAngleDraw,xmin,xmax,ymin,ymax,wantCircles,linesize)
			i += 1
			radius = radiusStart + i * radiusInc	// data radius
		while(radius <= radiusEnd )
	endif
	
	if( PolarGV("doMajorAngleTicks") != 1  %& ( linesize > 0) )
		angle= angle0
		lastAngle= angle0 + limit(angleRange,-2*Pi+angleInc/2,2*Pi-angleInc/2)	// to avoid two radius grids overlapping
		i= 0
		do	// Spokes
			angleDraw= PolarAngleFunction(angle,zeroAngleWhere,angleDirection,2)	// drawn angle
			cosAngle= cos(angleDraw)
			sinAngle= sin(angleDraw)
			x1= radStartDraw * cosAngle
			y1=  radStartDraw *sinAngle
			x2=  radEndDraw * cosAngle
			y2=  radEndDraw *sinAngle
			clipped= DrawClippedLine(x1,y1,x2,y2,xmin,xmax,ymin,ymax)	// 0 if invisible, 1 if not clipped, 2 if only x1,y1 clipped, 3 or 4 if x2,y2 clipped
			i += 1
			angle= angle0 + i * angleInc
		while(angle <= lastAngle )
	endif
	SetDrawEnv gstop	// end grids group

	return angleMinorTicks	// possibly revised to be fewer.
End

// Computes new radius starts in DATA COORDINATES into wAdjustedRadii to prevent spokes from coming too close together.
// angleInc CANNOT BE ZERO!
// Returns angle ticks, possibly smaller than angleMinorTicks if minspacing is violated at radiusEnd
Function/D CalcAdjustedRadiuses(wAdjustedRadii,angleMinorTicks,angleInc,radiusStart,radiusEnd,radiusInc,minspacing,radiusFunction,valueAtCenter)
	Wave/D  wAdjustedRadii
	Variable/D angleMinorTicks,angleInc,radiusStart,radiusEnd,radiusInc,minspacing,radiusFunction,valueAtCenter

	Variable/D deltaAngle,spacing, angle,angleTicks,radStart,radEnd,limitedRad
	Variable n

	// Verify that the angleMinorTicks don't violate minspacing at radiusEnd:
	// spoke spacing at r,deltaAngle is 2 * r * sin(deltaAngle/2)
	radEnd=PolarRadiusFunction(radiusEnd,radiusFunction,valueAtCenter)  // drawn Ending Radius

	angleMinorTicks= round(abs(angleMinorTicks))
	angleInc= abs(angleInc)
	deltaAngle= angleInc/(angleMinorTicks+1)
	spacing= 2 * (radEnd-radiusInc) * sin(deltaAngle/2)	// notice that the constraint is applied to the next-to-last major radius tickmark
	wAdjustedRadii= radiusStart	// default
	if( spacing < minspacing )	// minspacing prevents even the outer-most radius increment from using angleMinorTicks
		// recompute angleMinorTicks
		// minspacing <= 2 * (radiusEnd-radiusInc) * sin(angleInc/(angleMinorTicks+1)/2)	// solve for angleMinorTicks
		// minspacing/2/(radiusEnd-radiusInc) <= sin(angleInc/(angleMinorTicks+1)/2)
		// next step assumes that angleInc is between 180 and -180, not zero, and angleMinorTicks is at least 1 )
		// asin(minspacing/2/(radiusEnd-radiusInc)) <= angleInc/(angleMinorTicks+1)/2
		// -1 + 2/angleInc * asin(minspacing/2/(radiusEnd-radiusInc)) <=  angleMinorTicks
		angleTicks= max(0,floor(-1 + 2/angleInc * asin(minspacing/2/(radEnd-radiusInc))))
		// angleTicks must be a submultiple of angleMinorTicks
		angleMinorTicks= max(0,DBiggestSubmultiple(angleTicks+1,angleMinorTicks+1)-1)
	endif
	deltaAngle= angleInc/(angleMinorTicks+1)
	SetScale/P x ,0,deltaAngle,wAdjustedRadii	// so we can get radius as a function of angle offset, too!
	if( angleMinorTicks > 0)
		// Then compute the radius that all spokes may be drawn from,
		// minspacing <= 2 * radStart * sin(deltaAngle/2))	// solve for radStart
		radStart= minspacing /2 /sin(deltaAngle/2)	// solved for DRAWN radius
		radStart=PolarRadiusFunctionInv(radStart,radiusFunction,valueAtCenter)	// data radius, but not multiple of radiusStart + n * radiusInc
		n=  ceil((radStart-radiusStart)/radiusInc)
		radStart= radiusStart + radiusInc * n
		wAdjustedRadii= limit(radiusStart,radStart,radiusEnd) // if we stopped here, all spokes would start here
		if( (radStart > radiusStart) %& (angleMinorTicks > 2) %& angleMinorTicks )	// angleMinorTicks must be odd!
			angleTicks=angleMinorTicks
			do
				angleTicks= SubDivideTicks(angleTicks)	// find submultiple (preferably odd), and find smallest ring that doesn't violate minspacing
				deltaAngle= angleInc/(angleTicks+1)
				radStart= minspacing /2 /sin(deltaAngle/2)	// solved for DRAWN radius
				radStart=PolarRadiusFunctionInv(radStart,radiusFunction,valueAtCenter)	// data radius, but not multiple of radiusStart + n * radiusInc
				n=  ceil((radStart-radiusStart)/radiusInc)
				radStart= radiusStart + radiusInc * n
				limitedRad=  limit(radiusStart,radStart,radiusEnd)
				angle= deltaAngle
				do
					wAdjustedRadii[x2pnt(wAdjustedRadii,angle)]= limitedRad // adjust only those spokes for the angles of interest
					angle += deltaAngle
				while( angle < angleInc )
			while( (radStart > radiusStart) %& (angleTicks > 2) )	 // then try every other one of those, etc.
		endif
	else
		angleMinorTicks= 0
	endif
	return angleMinorTicks	// possibly modified, 0 means no ticks possible with minspacing honored
End

// Outputs V_min,V_max
Function PolarRadiusDrawnRange()

	NVAR V_min=root:Packages:PolarGraphs:V_min
	NVAR V_max=root:Packages:PolarGraphs:V_max

	Variable/D bigMax=NaN,smallMin=NaN,valueAtCenter=PolarGV("valueAtCenter")
	Variable haveMinMax=0,n=0
	Variable radiusFunction=PolarGV("radiusFunction")
	String radiusWaveList=PolarDependentRadiusWaves()
	String radiusWave
	do
		radiusWave= StringFromList(n,radiusWaveList)
		if( strlen(radiusWave) == 0 )
			break
		endif
		if( exists(radiusWave)==1 )
			PolarRadiusMinMax($radiusWave,radiusFunction,valueAtCenter)
			if( n==0)
				bigMax= V_max
				smallMin= V_min
			else
				bigMax= max(bigMax,V_max)
				smallMin= min(V_min,smallMin)
			endif
		endif
		n += 1
	while (1)
	V_min=smallMin
	V_max=bigMax
	return 0
End

// outputs in V_min and V_max
Function PolarRadiusMinMax(wr,radiusFunction,valueAtCenter)
	Wave/D wr
	Variable radiusFunction,valueAtCenter
	
	NVAR V_min=root:Packages:PolarGraphs:V_min
	NVAR V_max=root:Packages:PolarGraphs:V_max
	V_min=-inf
	V_max=inf
	Variable pt=0,n=numpnts(wr)
	Variable/D val
	do
		val= PolarRadiusFunction(wr[pt],radiusFunction,valueAtCenter)
		V_max= max(V_max,val)
		V_min= min(val,V_min)
		pt+=1
	while (pt < n)
	return 0
End


// Outputs V_min (angle0), V_max (angle0+angleRange) in radians
// must handle negative radius, angle units, and cut point at -180 degrees
// for simplicity, PolarAngleDataRange just picks quadrants.
Function PolarAutoScaleAngle()

	NVAR V_min=root:Packages:PolarGraphs:V_min
	NVAR V_max=root:Packages:PolarGraphs:V_max
	NVAR u_angle0=root:Packages:PolarGraphs:u_angle0
	NVAR u_angleRange=root:Packages:PolarGraphs:u_angleRange

	String shadowYList
	String shadowX,shadowY
	Variable n=0,quadrants=0
	shadowYList= PolarGS("appendShadowYWaves")
	do
		shadowY= StringFromList(n, shadowYList, ",")
		if( strlen(shadowY) == 0 )
			break
		endif
		if( exists(shadowY)==1 )
			shadowX= PolarShadowXForY(shadowY)
			if( exists(shadowX)==1 )
				quadrants+=WaveXYToQuadrants($shadowX,$shadowY)
			endif
		endif
		n += 1
	while (1)
	QuadrantsToAngle0Range(quadrants)	// Drawn quadrants
	V_min= DataAngle(u_angle0)	// convert from drawn angle to data angle in radians
	V_max= DataAngle(u_angle0+u_angleRange)
	return 0
End


// Given the number of ticks, choose a submultiple of current ticks to divide the region evenly
// Because only an odd number of ticks can be further subdivided, this routine prefers to return
// the largest odd submultiple over even submultiples.  It even prefers 1 over small even submultiple 2
// Returns 0 if it can't find a number of ticks.
Function/D SubDivideTicks(currentTicks)
	Variable/D currentTicks
	
	Variable/D newTicks= 0		// zero means can't subdivide interval
	if( (currentTicks > 1) %& (currentTicks %& 1) )	// only odd ticks (even subintervals) can be subdivided
		newTicks= DBiggestEvenSubmultiple((currentTicks+3)/2,currentTicks+1)
		if( newTicks > 0 )		// zero means cant subdivide
			newTicks-= 1
			if( newTicks == 1 )	// try even ticks
				newTicks= DBiggestOddSubmultiple(currentTicks,currentTicks+1)
				if( newTicks < 4 )	// prefer 1 tick over small even ticks
					newTicks= 1
				endif
			endif
		endif
	endif	
	return newTicks
End


// returns biggest odd result less than submultipleCandidate, such that that result * multiple = product, where multiple is an integer, possibly 0
// requires inputs to be greater than 0
Function/D DBiggestOddSubmultiple(submultipleCandidate,product)
	Variable/D submultipleCandidate,product
	Variable/D remainder,result
	result=floor(min(submultipleCandidate-1,product)) // (result usually == submultipleCandidate-1)
	if( ((result %& 1) == 0) %& ( result > 0) )
		result -= 1	// guaranteed odd
	endif
	if( result > 0 )
		do
			remainder=mod(product,result)
			result -= 2
		while( (remainder != 0) %& (result > 0) )
		if( remainder == 0 )
			result +=2
		else
			result = 0
		endif
	endif
	return result
End

// returns biggest even result less than submultipleCandidate, such that that result * multiple = product, where multiple is an integer, possibly 0
// requires inputs to be greater than 0
Function/D DBiggestEvenSubmultiple(submultipleCandidate,product)
	Variable/D submultipleCandidate,product
	Variable/D remainder,result
	result=floor(min(submultipleCandidate-1,product)) // (result usually == submultipleCandidate-1)
	if( result %& 1 )
		result -= 1	// guaranteed even
	endif
	if( result > 0 )
		do
			remainder=mod(product,result)
			result -= 2
		while( (remainder != 0) %& (result > 0) )
		if( remainder == 0 )
			result +=2
		else
			result = 0
		endif
	endif
	return result
End

// returns biggest result less than submultipleCandidate, such that that result * multiple = product, where multiple is an integer, possibly 1
Function/D DBiggestSubmultiple(submultipleCandidate,product)
	Variable/D submultipleCandidate,product
	Variable/D remainder,result=floor(min(submultipleCandidate-1,product)) // (result usually == submultipleCandidate-1)
	do
		remainder=mod(product,result)
		result-= 1
	while( (remainder != 0) %& (result > 0) )
	return result+1
End



// Inputs: span,desiredTicks
// Outputs:
//	Variable/D/G u_numPlaces, u_tickDelta, u_majorDelta 
// Returns:
//	singular= 1		// if user desires only one tick mark
Function CalcAutoTicking(span,desiredTicks)
	Variable/D span
	Variable desiredTicks

	Variable/D dtmp,tickDelta,majorDelta
	Variable singular,itmp,numPlaces
	
	NVAR u_numPlaces=root:Packages:PolarGraphs:u_numPlaces
	NVAR u_tickDelta=root:Packages:PolarGraphs:u_tickDelta
	NVAR u_majorDelta=root:Packages:PolarGraphs:u_majorDelta

	//	roughly desiredTicks tick marks
	dtmp= log(abs(span)/desiredTicks)
	// check for valid range
	singular= abs(dtmp) > 1.00000e+30
	if(desiredTicks==1)
		singular= 1		//user desires only one tick mark
	endif
	itmp= trunc(dtmp)
	if( dtmp<0 )
		itmp -= 1
	endif
	numPlaces= itmp		// will become num digits past dp
	tickDelta= dtmp-itmp

	// find "nice" increment for tick marks
	if( tickDelta > 0.875 )			// delta>log10(7.5)?
		majorDelta= 1
		tickDelta= 10
		numPlaces += 1
	else
		if( tickDelta > 0.544 )		// delta>log10(3.5)?
			majorDelta= 5
			tickDelta=  5
		else
			if( tickDelta > 0.176 )	//  delta>log10(1.5)?
				majorDelta= 2
				tickDelta=  2
			else
				majorDelta= 1
				tickDelta=  1
			endif
		endif
	endif

	tickDelta *= 10^itmp
	if(span<0)
		tickDelta= -tickDelta
	endif

	// digits past dp only if log(delta)<0.  Also max of 15 digits
	numPlaces =  min(15,-min(0,numPlaces))


	u_numPlaces= numPlaces
	u_tickDelta= tickDelta
	u_majorDelta= majorDelta
	Return singular					// non-zero if only one tick mark
End

// A note about transformations:
// labels values are in data coordinates, and are placed at the drawn location.
// when labelling r,a (data), the label reads r,a, but is drawn at PolarRadiusFunction(r,...),PolarAngleFunction(a,...)


// PolarRadiusFunction transforms from data radius to drawn radius
Function/D PolarRadiusFunction(dataRadius,radiusFunction,valueAtCenter)
	Variable/D dataRadius
	Variable radiusFunction	// "Linear;Log;Ln"
	Variable/D valueAtCenter

	Variable/D drawnRadius=dataRadius
	if( radiusFunction == 1 )
		if( valueAtCenter != 0 )
			drawnRadius= max(dataRadius-valueAtCenter,0)
		endif
	else	// log or ln
		if( radiusFunction==2 )	// log
			drawnRadius=  max(log(dataRadius/valueAtCenter),0)
		else	// ln
			drawnRadius=  max(ln(dataRadius/valueAtCenter),0)
		endif
	endif
	return drawnRadius
End

// PolarRadiusFunctionInv transforms drawn radius to data radius
Function/D PolarRadiusFunctionInv(drawnRadius,radiusFunction,valueAtCenter)
	Variable/D drawnRadius
	Variable radiusFunction	// "Linear;Log;Ln"
	Variable/D valueAtCenter

	Variable/D dataRadius=drawnRadius
	if( radiusFunction == 1 )
		dataRadius+=valueAtCenter
	else	// log or ln
		if( radiusFunction==2 )	// log
			dataRadius= 10^(drawnRadius) * valueAtCenter
		else	// ln
			dataRadius= e^(drawnRadius) * valueAtCenter
		endif
	endif
	return dataRadius
End

// PolarAngleFunction transforms from data angle in angleUnits to drawn angle in radians
Function/D PolarAngleFunction(dataAngle,zeroAngleWhere,angleDirection,angleUnits)
	Variable/D dataAngle		// in angleUnits
	Variable zeroAngleWhere	// Variable popup code: "bottom;right;top;left" "-90;0;+90;+180"
	Variable angleDirection	// Variable popup code:  "clockwise;counter-clockwise"
	Variable angleUnits		// Variable popup code:  "degrees;radians"
	Variable/D drawnAngle,zeroAngle= (zeroAngleWhere-2)*Pi/2
	if( angleUnits == 1 )		// degrees (360 per circle)
		dataAngle *= Pi/180
	endif
	if( angleDirection == 1 ) // clock-wise
		drawnAngle = zeroAngle - dataAngle
	else
		drawnAngle = zeroAngle + dataAngle	// counter-clockwise
	endif
	return drawnAngle
End

// PolarAngleFunctionInv transforms from drawn angle in radians to data angle in angleUnits
Function/D PolarAngleFunctionInv(drawnAngle,zeroAngleWhere,angleDirection,angleUnits)
	Variable/D drawnAngle	// radians
	Variable zeroAngleWhere	// Variable popup code: "bottom;right;top;left" "-90;0;+90;+180"
	Variable angleDirection	// Variable popup code:  "clockwise;counter-clockwise"
	Variable angleUnits		// Variable popup code:  "degrees;radians"
	Variable/D dataAngle,zeroAngle= (zeroAngleWhere-2)*Pi/2
	if( angleDirection == 1 ) // clock-wise
		dataAngle = zeroAngle - drawnAngle
	else
		dataAngle= drawnAngle - zeroAngle	// counter-clockwise
	endif
	if( angleUnits == 1 )		// degrees (360 per circle)
		dataAngle *= 180/Pi
	endif
	return dataAngle	// in angleUnits
End

// These next two functions aren't very fast. Don't use them in a loop; use PolarAngleFunction and PolarAngleFunctionInv.
Function/D DrawnAngle(dataAngle)	// convert from data angle (radians) to angle drawn on graph (radians)
	Variable/D dataAngle
	return PolarAngleFunction(dataAngle,PolarGV("zeroAngleWhere"),PolarGV("angleDirection"),2)
End

Function/D DataAngle(drawnAngle)	// convert from data angle (radians) to angle drawn on graph (radians)
	Variable/D drawnAngle
	return PolarAngleFunctionInv(drawnAngle,PolarGV("zeroAngleWhere"),PolarGV("angleDirection"),2)
End

// This function assumes the top window is a graph in 1:1 Plan mode,
// that left and bottom axes exist and that they define the entire plot area.
Function/D PointsToDrawn(points)
	Variable/D points			// some parameter, like tick length, in points (1/72 inch)
	String grfwin				// or "kWinTop" for top window
	
	Variable/D drawnLength,physicalLength
	
	GetAxis /Q bottom
	drawnLength= abs(V_max-V_min)		// Drawn coordinates

	GetWindow kwTopWin psize
	physicalLength= V_right-V_left			// points
	
	drawnLength= points * drawnLength/physicalLength
	return drawnLength		// Call DrawLine with this to draw a radial line that is physically points long.
End

// Real Soon Now, we will store a window's settings in the window note

Function/D PolarGV(variableKey)
	String variableKey
	return DataBaseGetBagVariable(BagForTargetAndKey(variableKey),variableKey)
End

// returns truth that variableValue was set
Function PolarSV(variableKey,variableValue)
	String variableKey
	Variable/D variableValue
	Variable set=0
	String bagName=WinName(0, 1)
	if( DataBaseBagAndKeyExist(bagName,"") )
		set= DataBaseSetBagVariable(bagName,variableKey,variableValue)
	endif
	return set
End

Function/S PolarGS(stringKey)
	String stringKey
	return DataBaseGetBagString(BagForTargetAndKey(stringKey),stringKey)
End

// returns truth that stringValue was set
Function PolarSS(stringKey,stringValue)
	String stringKey,stringValue
	Variable set=0
	String bagName=WinName(0, 1)
	if( DataBaseBagAndKeyExist(bagName,"") )
		set= DataBaseSetBagString(bagName,stringKey,stringValue)
	endif
	return set
End

// returns window name if a bag in the database can be found to match it, else "_default_"
// Also aborts if the target window name is not a bag found in the database
Function/S BagForTargetAndKey(key)	// Prevent creating categories for non-PolarGraphs
	String key							// use "" for don't care
	String bagName= WinName(0, 1)	// target graph
	if( DataBaseBagAndKeyExist(bagName,"") == 0 )
		Abort bagName+" either isn't a Polar Graph, or the graph's name has been changed.  Polar Graph settings cannot be located."
	else
		if( DataBaseBagAndKeyExist(bagName,key) == 0 )
			bagName= "_default_"
		endif
	endif
	return bagName
End

Function PolarFixTargetAxisRanges()
	GetAxis/Q bottom
	SetAxis /Z bottom, V_min,V_max
	GetAxis/Q left
	SetAxis /Z left, V_min,V_max
End

Function PolarWindowHook (info)
	String info
	
	String win,event
	Variable st,en,didit=0
	st=strsearch(info,"WINDOW:",0)+7;en=strsearch(info,";",st);win=info[st,en-1]
	st=strsearch(info,"EVENT:",0)+6;en=strsearch(info,";",st);event=info[st,en-1]

	if( IsPolarGraph(win)>0 ) 
		if (strsearch(event,"activate",0)>=0 )
			PolarFixTargetAxisRanges()
			didit= 1
		endif
		if (cmpstr(event,"kill")==0 )
			UnRegisterPolarGraph(win)// Remove settings from database
			didit= 1
		endif
	endif
	return didit				// 0 if nothing done, else 1
End

// Returns 1 if graph is a Polar Graph
Function IsPolarGraph(graphName)
	String graphName
	return DataBaseBagAndKeyExist(graphName,"")
End

// set up new graphName; if it doesn't exist as a bag, copy polar graph settings from style
Proc PolarRegisterGraph(graphName,style)
	String graphName,style
	Variable isNew=0
	if( DataBaseBagAndKeyExist(graphName,"") == 0 )
		DataBaseCurrentBag(style)
		String contents= GetDataContents()	
		DataBaseCurrentBag(graphName)
		SetDataContents(contents)
		isNew=1
	endif
	SetWindow $graphName,hook=PolarWindowHook
	return isNew
End


Function WvsXYToRadiusAngle(wx,wy,wr,wa)	// must be distinct waves
	wave wx,wy,wr,wa
	wr= sqrt(wx*wx+wy*wy)
	wa= atan2(wy,wx)		// radians
End

Function WvsRadiusAngleToXY(wr,wa,wx,wy)	// must be distinct waves
	wave wr,wa,wx,wy
	wx= wr * cos(wa)		// wa in radians
	wy=wr * sin(wa)			// wa in radians
End

Function/D DegToRad(deg)
	Variable/D deg
	Return deg / 180 * Pi
End

Function/D RadToDeg(rad)
	Variable/D rad
	Return rad / Pi * 180
End

// returns quadrant bits set according to content of  x,y waves
// bit 1 is quadrant 1 (0-90),
// bit 2 is quadrant 2 (90-180)
// bit 3 is quadrant 3 (-180 to -90)
// bit 4 is quadrant 4 (-90 to 0)
// (bit 0 is not used, and is zero)
Function WaveXYToQuadrants(wx,wy)	// wx,wy are usually shadow waves
	Wave/D wx,wy
	Variable quad,quadrants= 0
	Variable q1=2,q2=4,q3=8,q4=16
	Variable qAll=q1+q2+q3+q4
	Variable negX_Y0=0,posX_Y0=0,negY_X0=0,posY_X0=0
	Variable pt=0,n=numpnts(wx)

	Variable/D xx,yy
	do
		xx= wx[pt]; yy=wy[pt];quad=0
		if( yy < 0 )		// q3 & q4
			if( xx < 0 )
				quad =  q3
			else
				if (xx > 0)
					quad=  q4
				else	// x = 0, y < 0
					negY_X0= 1
				endif
			endif
		else
			if (yy > 0 )	// q1 & q2
				if( xx < 0 )
					quad = q1
				else
					if (xx > 0)
						quad=q2
					else	// x = 0, y > 0
						posY_X0= 1
					endif
				endif
			else			// y=0, x axes
				if( xx > 0 )
					posX_Y0= 1
				endif
				if( xx < 0 )
					negX_Y0= 1
				endif
			endif
		endif
		quadrants+=quad
		pt+= 1
	while( (pt < n) %& (quadrants < qAll ))		// while not using all quadrants
	if( (quadrants < qAll) %& (negX_Y0+posX_Y0+negY_X0+posY_X0) > 0)	// process any points on quadrant borders
		if( negX_Y0 %& ! (quadrants %& (q2+q3)) )	// need q2 or q3
			if( quadrants %& q1 )	// have q1, extend to q2
				quadrants+=q2
			else
				quadrants+=q3
			endif
		endif
		if( posX_Y0 %& !(quadrants %& (q1+q4)) )	// need q1 or q4
			if( quadrants %& q2 )	// have q2, extend to q1
				quadrants+=q2
			else
				quadrants+=q4
			endif
		endif
		if( negY_X0 %& !(quadrants %& (q3 + q4)) )	// need q3 or q4
			if( quadrants %& q1 ) // have q1, extend to q4
				quadrants+=q4
			else
				quadrants+=q3
			endif
		endif
		if( posY_X0 %& !(quadrants %& (q1+q2)) )	// need q1 or q2
			if( quadrants %& q4 )	// have q4, extend to q1
				quadrants+=q1
			else
				quadrants+=q2
			endif
		endif
	endif
	return quadrants
End

// Returns u_angle0,u_angleRange
// bit 1 is quadrant 1 (0-90),
// bit 2 is quadrant 2 (90-180)
// bit 3 is quadrant 3 (-180 to -90)
// bit 4 is quadrant 4 (-90 to 0)
// (bit 0 is not used, and is zero)
// only handles quarter, half, or full circles (doesn't return 3/4 circle)
Function QuadrantsToAngle0Range(quadrants)
	Variable quadrants
	
	NVAR u_angleRange=root:Packages:PolarGraphs:u_angleRange
	NVAR u_angle0=root:Packages:PolarGraphs:V_min
	Variable q1= (quadrants %& 2) > 0
	Variable q2= (quadrants %& 4) > 0
	Variable q3= (quadrants %& 8) > 0
	Variable q4= (quadrants %& 16) > 0
	Variable numQuadrants= q1+q2+q3+q4
	// quarter circle works if only one quadrant needed.
	if (numQuadrants== 1 )
		u_angleRange=90
		u_angle0= q2 * 90 + q3 * (-180) + q4 * (-90)
	else
		u_angle0= 0
		if ( (q1 %& q3) %| (q2 %& q4) )	// need opposite quadrants, use full circle
			u_angleRange=360
		else // must be adacent quadrants 1,2 or 2,3 or 3,4 or 4,1
			u_angleRange=180
			//u_angle0= (q1 %& q2) * 0			// 0 to 180
			u_angle0 += (q2 %& q3) * 90		// 90 to 270
			u_angle0 += (q3 %& q4) * (-180)	// -180 to 0	
			u_angle0 += (q4 %& q1) * (-90)	// -90 to 90	
		endif
	endif
	u_angle0 *= pi/180		// degrees to radians
	u_angleRange *= pi/180	// degrees to radians
	return quadrants
End

//UniqueWindowName makes numerical suffix so that Window named prfx+sfxStr does not exist
Function/S UniqueWindowName(prfx)
	String prfx	// Window name starts with this 
	
	SVAR u_str=root:Packages:WMDataBase:u_str
	SVAR u_prompt=root:Packages:PolarGraphs:u_prompt
	NVAR u_UniqWinNdx=root:Packages:PolarGraphs:u_UniqWinNdx	// static memory of last index tried
	String 	sfxStr="Last"			// if 1000 prfx windows exist!
	Variable ii=0,sfxNum=u_UniqWinNdx,chances=3,isBad
	do
		if (wintype(prfx+num2istr(sfxNum)) == 0)
			u_UniqWinNdx=sfxNum
			sfxStr=num2istr(sfxNum)
			break
		endif
		sfxNum = mod(u_UniqWinNdx+1,1000)
		ii+=1
	while (ii < 1000)
	u_str= prfx+sfxStr
	if( (Cmpstr(sfxStr,"Last") == 0) %| (strlen(u_str)>31) )
		u_prompt= "Help Igor create a new window name (this one wasn't valid or already existed):"
		do
			Execute "Ask()"	// ask the user, who might goof...
			isBad=  (strlen(u_str)>31) %| (strsearch(u_str," ",0) != -1) %| (wintype(u_str)!=0) // so we check for length and spaces and existing windows
			chances -= 1	// avoid infinite loop because user can not cancel!
		while ( chances > 0 %& isBad )
		if( isBad )
			u_str= "_bad_window_name_"
		endif
	endif
	return u_str		// non-existing window, or prfx+"Last"
End

//UniqueWaveName makes numerical suffix so that wave named prfx+sfxStr does not exist
Function/S UniqueWaveName(prfx)
	String prfx	// Window name starts with this 
	
	NVAR u_UniqWinNdx=root:Packages:PolarGraphs:u_UniqWinNdx	// static memory of last index tried
	NVAR u_UniqWaveNdx=root:Packages:PolarGraphs:u_UniqWaveNdx
	String 	sfxStr="Last"			// if 1000 prfx windows exist!
	Variable ii=0,sfxNum=u_UniqWaveNdx,chances=3,isBad
	do
		if (exists(prfx+num2istr(sfxNum)) == 0)
			u_UniqWaveNdx=sfxNum
			sfxStr=num2istr(sfxNum)
			break
		endif
		sfxNum = mod(u_UniqWaveNdx+1,1000)
		ii+=1
	while( (strlen(prfx) > 0) %& (ii < 1000) )
	SVAR u_str=root:Packages:WMDataBase:u_str
	SVAR u_prompt=root:Packages:PolarGraphs:u_prompt
	u_str= prfx+sfxStr
	if( (Cmpstr(sfxStr,"Last") == 0) %| (strlen(u_str)>18) )
		u_prompt= "Help Igor create a new wave name (this one wasn't valid or already existed):"
		do
			Execute "Ask()"	// ask the user, who might goof...
			isBad=  (strlen(u_str)>31) %| (strsearch(u_str," ",0) != -1) %| (wintype(u_str)!=0) // so we check for length and spaces and existing windows
			chances -= 1	// avoid infinite loop because user can not cancel!
		while ( chances > 0 %& isBad )
		if( isBad )
			u_str= "_bad_window_name_"
		endif
	endif
	return u_str		// non-existing window, or prfx+"Last"
End


Proc Ask(str)					// str parameter must be missing for this to be useful
	String str= root:Packages:WMDataBase:u_str			// set u_str before calling this Proc; user will update, and we'll try again
	Prompt str,root:Packages:PolarGraphs:u_prompt		// set this, too
	
	root:Packages:WMDataBase:u_str= str					// output
End

Proc AskChoice(str)			// str parameter must be missing for this to be useful
	String str= root:Packages:WMDataBase:u_str			// set u_str before calling this Proc; user will update, and we'll try again
	Prompt str,root:Packages:PolarGraphs:u_prompt,popup,root:Packages:PolarGraphs:u_popup		// set these, too
	
	root:Packages:WMDataBase:u_str= str					// output
End

Proc AskValue(val)				// val parameter must be missing for this to be useful
	Variable/D val= root:Packages:PolarGraphs:u_val		// set u_val before calling this Proc; user will update, and we'll try again
	Prompt val,root:Packages:PolarGraphs:u_prompt			// set this, too
	
	root:Packages:PolarGraphs:u_val= val					// output
End

Proc AskValueChoice(val)			// val parameter must be missing for this to be useful
	Variable/D val= root:Packages:PolarGraphs:u_val			// set u_val before calling this Proc; user will update, and we'll try again
	Prompt val,root:Packages:PolarGraphs:u_prompt,popup,root:Packages:PolarGraphs:u_popup		// set these, too
	
	root:Packages:PolarGraphs:u_val= val					// output
End


// global inputs and outputs Variable/D/G u_x1,u_y1,u_x2,u_y2
// returns 0 if that segment is not visible in xmin,xmax,ymin,ymax (u_x1,u_y1,u_x2,u_y2 weren't changed)
// returns 1 if that segment is visible WITHOUT clipping (u_x1,u_y1,u_x2,u_y2 weren't changed)
// returns 2 if that segment is visible WITH clipping (u_x1 or u_y1 were changed), pt1changed==2)
// returns 3 if that segment is visible WITH clipping (u_x1 or u_y1 and u_x2 or u_y2 were changed)
// returns 4 if that segment is visible WITH clipping (u_x2 or u_y2 were changed, pt2changed= 4)
Function DClip_u_X12Y12(xmin,xmax,ymin,ymax)
	Variable/D xmin,xmax,ymin,ymax

	NVAR u_x1=root:Packages:PolarGraphs:u_x1
	NVAR u_y1=root:Packages:PolarGraphs:u_y1
	NVAR u_x2=root:Packages:PolarGraphs:u_x2
	NVAR u_y2=root:Packages:PolarGraphs:u_y2
	
	Variable j,reversed= 0, pt1changed= 0, pt2changed= 0
	Variable/D xt,yt,dy,dx,dxy,qx,qXX,qy,qYY,U1,U2,U3,U4

	// 1. see if segment is outside of "rectangle" xmin,xmax,ymin,ymax
	if( (u_x1 < xmin) %& (u_x2 < xmin) )
		return 0
	endif
	if( (u_x1 > xmax) %& (u_x2 > xmax) )
		return 0
	endif
	if( (u_y1 < ymin) %& (u_y2 < ymin) )
		return 0
	endif
	if( (u_y1 > ymax) %& (u_y2 > ymax) )
		return 0
	endif
	// 2. maintain u_x2,u_y2 to the "right" of u_x1,u_y1
	if( u_y1 > u_y2 )
		xt=u_x1; yt=u_y1
		u_x1=u_x2; u_y1=u_y2
		u_x2=xt; u_y2=yt
		reversed = 1
	else
		// 3. horizontal line
		if( u_y1 == u_y2 )
			if( u_x1 > u_x2 )
				xt=u_x1; yt=u_y1
				u_x1=u_x2; u_y1=u_y2
				u_x2=xt; u_y2=yt
				reversed = 1
			endif
			if( u_x1 < xmin )	// try u_x1= min(u_x1,xmin), etc
				u_x1= xmin
				pt1changed= 2 + reversed*2
			endif
			if( u_x2 > xmax )
				u_x2= xmax
				pt2changed= 4 - reversed*2
			endif
			if( reversed )	// put them back in same order
				xt=u_x1; yt=u_y1
				u_x1=u_x2; u_y1=u_y2
				u_x2=xt; u_y2=yt
			endif
			return  (pt1changed+pt2changed)%|1
		endif
	endif
	// 4. vertical line
	if( u_x1 == u_x2 )
		if( u_y1 < ymin )
			u_y1= ymin
			pt1changed= 2 + reversed*2
		endif
		if( u_y2 > ymax )
			u_y2= ymax
			pt2changed= 4 - reversed*2
		endif
		if( reversed )	// put them back in same order
			xt=u_x1; yt=u_y1
			u_x1=u_x2; u_y1=u_y2
			u_x2=xt; u_y2=yt
		endif
		return  (pt1changed+pt2changed)%|1
	endif
	// 5. do corners
	dy= u_y1-u_y2
	dx= u_x1-u_x2
	dxy= u_x1*u_y2-u_y1*u_x2
	qx= xmin*dy
	qXX=xmax*dy
	qy= ymin*dx
	qYY= ymax*dx
	U1= qx-qy+dxy
	U2= qx-qYY+dxy
	U3= qXX-qYY+dxy
	U4= qXX-qy+dxy
	// 6.
	j= 0
	// 7. Line intersects xmin?
	if( sign(U1) != sign(U2) )
		j+=1
		if( u_x1 < xmin )
			u_y1= (xmin*dy+dxy)/dx
			u_x1= xmin
			dy= u_y1-u_y2;dx= u_x1-u_x2;dxy= u_x1*u_y2-u_y1*u_x2  // update dy, dx, dxy
			pt1changed= 2 + reversed*2
		endif
		if( u_x2 < xmin )
			u_y2= (xmin*dy+dxy)/dx
			u_x2= xmin
			dy= u_y1-u_y2;dx= u_x1-u_x2;dxy= u_x1*u_y2-u_y1*u_x2  // update dy, dx, dxy
			pt2changed= 4 - reversed*2
		endif
	endif
	// 8. Line intersects ymax ?
	if( sign(U2) != sign(U3) )
		j+=1
		if( u_y2 > ymax )
			u_x2= (ymax*dx-dxy)/dy
			u_y2= ymax
			dy= u_y1-u_y2;dx= u_x1-u_x2;dxy= u_x1*u_y2-u_y1*u_x2  // update dy, dx, dxy
			pt2changed= 4 - reversed*2
		endif
	endif
	// 9. Line intersects xmax ?
	if( sign(U3) != sign(U4) )
		j+=1
		if( u_x1 > xmax )
			u_y1= (xmax*dy+dxy)/dx
			u_x1= xmax
			dy= u_y1-u_y2;dx= u_x1-u_x2;dxy= u_x1*u_y2-u_y1*u_x2  // update dy, dx, dxy
			pt1changed= 2 + reversed*2
		endif
		if( u_x2 > xmax )
			u_y2= (xmax*dy+dxy)/dx
			u_x2= xmax
			dy= u_y1-u_y2;dx= u_x1-u_x2;dxy= u_x1*u_y2-u_y1*u_x2  // update dy, dx, dxy
			pt2changed= 4 - reversed*2
		endif
	endif
	// 10. Line intersects ymin ?
	if( sign(U4) != sign(U1) )
		j+=1
		if( u_y1 < ymin )
			u_x1= (ymin*dx-dxy)/dy
			u_y1= ymin
			pt1changed= 2 + reversed*2
		endif
	endif
	
	if( reversed )	// put them back in same order
		xt=u_x1; yt=u_y1
		u_x1=u_x2; u_y1=u_y2
		u_x2=xt; u_y2=yt
	endif
	return  (pt1changed+pt2changed)%| (j>0)
End



Function/D DrawClippedLine(x1,y1,x2,y2,xmin,xmax,ymin,ymax)	// returns 0 if invisible, 1 if not clipped, 2 if only x1,y1 clipped, 3 or 4 if x2,y2 clipped
	Variable/D x1,y1,x2,y2,xmin,xmax,ymin,ymax

	NVAR u_x1=root:Packages:PolarGraphs:u_x1
	NVAR u_y1=root:Packages:PolarGraphs:u_y1
	NVAR u_x2=root:Packages:PolarGraphs:u_x2
	NVAR u_y2=root:Packages:PolarGraphs:u_y2
	u_x1=x1;u_y1=y1;u_x2=x2;u_y2=y2
	Variable/D clipped= DClip_u_X12Y12(xmin,xmax,ymin,ymax)	// 0 if invisible, 1 if not clipped, 2 if only x1,y1 clipped, 3 or 4 if x2,y2 clipped
	if( clipped )	// if visible
		DrawLine u_x1, u_y1, u_x2, u_y2
	endif
	return clipped
End

Function/D DrawClippedLineSize(x1,y1,x2,y2,xmin,xmax,ymin,ymax,lineSize)	// returns 0 if invisible, 1 if not clipped, 2 if only x1,y1 clipped, 3 or 4 if x2,y2 clipped
	Variable/D x1,y1,x2,y2,xmin,xmax,ymin,ymax,lineSize

	NVAR u_x1=root:Packages:PolarGraphs:u_x1
	NVAR u_y1=root:Packages:PolarGraphs:u_y1
	NVAR u_x2=root:Packages:PolarGraphs:u_x2
	NVAR u_y2=root:Packages:PolarGraphs:u_y2
	u_x1=x1;u_y1=y1;u_x2=x2;u_y2=y2
	Variable/D clipped= DClip_u_X12Y12(xmin,xmax,ymin,ymax)	// 0 if invisible, 1 if not clipped, 2 if only x1,y1 clipped, 3 or 4 if x2,y2 clipped
	if( (clipped>0) %& (lineSize>0) )	// if visible
		DrawLine u_x1, u_y1, u_x2, u_y2
	endif
	return clipped
End

// returns true if a circle of given radius will fit within xmin,xmax,ymin,ymax without clipping, else returns 0 
Function CircleFitsInRect(radius,xmin,xmax,ymin,ymax)
	Variable/D radius,xmin,xmax,ymin,ymax
	
	Variable fits=0
	// First, zero has to be within the xmin,xmax,ymin,ymax box
	if( (xmin < 0) %& (xmax > 0) %& (ymin < 0) %& (ymax > 0) )
		Variable smallest= min(min(min(-xmin,xmax),-ymin),ymax)
		fits= (radius <= smallest)
	endif
	return fits
End

 // for best Appearance, set maxDeltaAngle to submultiple of gridDeltaAngle for the arc
Function PolarDrawArc(radius,angle0,angleRange,maxDeltaAngle,xmin,xmax,ymin,ymax,wantCircles,lineSize)	// radians
	Variable/D radius,angle0,angleRange,maxDeltaAngle,xmin,xmax,ymin,ymax
	Variable wantCircles	// user wants circles, we  also make sure each circle fits in xmin,xmax,ymin,ymax
	Variable lineSize		// size of line in points, used only if wantCircles is true.
	
	Variable useCircles=0
	if(wantCircles %& (abs(angleRange) >= 2*pi))
		useCircles= CircleFitsInRect(radius,xmin,xmax,ymin,ymax)
	NVAR u_debug=root:Packages:PolarGraphs:u_debug
if( u_debug )
	Print "for radius=",radius,"useCircles=", useCircles
endif
		if( useCircles )
			radius += PointsToDrawn(lineSize)/2	// DrawOval draws tangent to the boundaries, not through them.
			DrawOval -radius,radius,radius,-radius
			return 1
		endif
	endif
	
//	if( maxDeltaAngle <= 0 )
//		maxDeltaAngle =angleRange/360 	// one degree or less
//	endif
//	
	Variable additionalPts=limit(round(abs(angleRange/maxDeltaAngle)),1,360) // this many endpoints, plus 1

	Variable/D angle,dAngle= angleRange / (additionalPts),cosDAngle,sinDAngle
	NVAR u_x1=root:Packages:PolarGraphs:u_x1
	NVAR u_y1=root:Packages:PolarGraphs:u_y1
	NVAR u_x2=root:Packages:PolarGraphs:u_x2
	NVAR u_y2=root:Packages:PolarGraphs:u_y2
	Variable/D x1,y1,x2,y2
	Variable clipped				// really "visible + how clipped, if clipped at all"!
	Variable partVisible= 0		// true if any portion of the arc is visible
Variable n=1
	x1= radius * cos(angle0)
	y1=  radius * sin(angle0)
	cosDAngle= cos(dAngle);sinDAngle=sin(dAngle)
	do	// while there are points to draw
		do	// start a segment
x2= radius * cos(angle0+n*dAngle)
y2=  radius * sin(angle0+n*dAngle)
//			x2= x1 * cosDAngle - y1 * sinDAngle
//			y2= x1 * sinDAngle + y1 * cosDAngle
			u_x1=x1;u_y1=y1;u_x2=x2;u_y2=y2
			clipped= DClip_u_X12Y12(xmin,xmax,ymin,ymax)	// 0 if invisible, 1 if not clipped, 2 if only x1,y1 clipped, 3 or 4 if x2,y2 clipped
//			x1=u_x2;y1=u_y2	// ready for next try
			x1=x2;y1=y2	// ready for next try
			additionalPts -= 1
			n+=1
		while( (clipped ==0) %& (additionalPts > 0) )	//  do while invisible
		if( clipped )
			DrawPoly u_x1,u_y1,1,1,{u_x1,u_y1,u_x2,u_y2}		// first and second points, possibly clipped
			partVisible= 1
		endif
		if (radius == 0 )
			return partVisible
		endif
		// Additional points, if any, and only if x2,y2 (the new x1,y1) weren't clipped
		if( (additionalPts > 0) %& (clipped <= 3) )	// no clipping, or old x1,y1 clipped
			do					// draw additional points
x2= radius * cos(angle0+n*dAngle)
y2=  radius * sin(angle0+n*dAngle)
//				x2= x1 * cosDAngle - y1 * sinDAngle
//				y2= x1 * sinDAngle + y1 * cosDAngle
				u_x1=x1;u_y1=y1;u_x2=x2;u_y2=y2
				clipped= DClip_u_X12Y12(xmin,xmax,ymin,ymax)	// 0 if invisible, 1 if not clipped, 2 if only x1,y1 clipped, 3 or 4 if x2,y2 clipped
				if( clipped )	// that is, "if visible"
					DrawPoly /A {u_x2,u_y2}
				endif 
				x1=x2;y1=y2	// ready for next try
				additionalPts -= 1
				n+=1
			while( (additionalPts>0) %& (clipped == 1) )	// until the segment ends with x2,y2 clipped (we already know x1, y1 aren't clipped)
		endif
	while( additionalPts > 0 )
	return partVisible
End

// returns string containing color specification; use with Execute
// these are the old QuickDraw colors
// assumes String/G u_colorList="black;blue;green;cyan;red;magenta;yellow;white;special"
Function/S GetRGBColorFromList(colorNdx)
	Variable colorNdx	// 1 is black, 2 is blue,...8 is white, 9 is (user's) special.  See u_colorList global

	Variable inRange= limit(colorNdx,1,9) == colorNdx	// out of range is considered to be black.
	Variable red=0,green=0,blue=0	// colorNdx==1
	String colorStr
	if( inRange )
		if( colorNdx == 2)	//blue
			blue = 0xd400
		else
		if( colorNdx == 3)	//green
			green = 0x8000
			blue = 0x11b0
		else
		if( colorNdx == 4)	//cyan
			red = 0x0241
			green = 0xab54
			blue = 0xeaff
		else
		if( colorNdx == 5)	//red
			red = 0xdd6b
			green = 0x08c2
			blue = 0x06a2
		else
		if( colorNdx == 6)	//magenta
			red = 0xf2d7
			green = 0x0856
			blue = 0x84ec
		else
		if( colorNdx == 7)	//yellow
			red = 0xfc00
			green = 0xf37d
			blue = 0x052f
		else
		if( colorNdx == 8)	//white
			red = 0xffff
			green = 0xffff
			blue = 0xffff
		else
		if( colorNdx == 9)	// special: Set this to what you want, add additional values here and to u_polColorList
			red = 49151		// light blue, change to your liking
			green =49152
			blue = 65535
		endif
		endif
		endif
		endif
		endif
		endif
		endif
		endif
	endif
	sPrintf colorStr, "(%d,%d,%d)" red,green,blue
	return colorStr
End

Proc Expand_Square() : GraphMarquee
	Variable/D halfRange,hCenter,vCenter
	
	Silent 1;PauseUpdate
	GetMarquee/K bottom,left
	if( V_Flag==0 ) // means no marquee, use axes entire range 
		GetAxis /Q bottom
		hCenter= (V_min + V_max)/2
		halfRange= abs(V_max-V_min)/2
		GetAxis /Q left
		vCenter= (V_min + V_max)/2
		halfRange= max(halfRange, abs(V_max-V_min)/2)
	else // from marquee
		halfRange= max(abs(V_right-V_left),abs(V_top-V_bottom))/2
		hCenter= (V_left + V_right)/2
		vCenter= (V_top + V_bottom)/2
	endif
	SetAxis bottom, hCenter-halfRange,hCenter+halfRange
	SetAxis left, vCenter-halfRange,vCenter+halfRange

	PolarUpdated(0)
End

// This sets the state of the update button in the graph.
Function PolarUpdated(isUpdated)
	Variable isUpdated	// zero if polar graph needs updating, 1 if it has been updated

	if( isUpdated == 0 )
		Button polarButton title="Update Axes and Grid"
	else
		Button polarButton title="(graph updated)"
	endif
End
	

Function PolarUpdateButton(ctrlName) : ButtonControl
	String ctrlName
	Button $ctrlName title="(computing)"
//	Button polarButton title="(computing)"
	DoUpdate
	FPolarAxesRedraw()
	PolarUpdated(1)
End

Function/D signRange(val,slop)	// three-valued sign function with +/- slop around zero
	Variable/D val,slop
	if( abs(val) > abs(slop))
		val= sign(val)
	else
		val=0
	endif
	return val
End

Function/S LabelTick(x0,y0,fmt,labelVal,lblOrient,tickAngle,xmin,xmax,ymin,ymax)
	Variable/D x0,y0	// position of label anchor in drawn polar coordinates
	String fmt
	Variable/D labelVal
	Variable lblOrient		// label orientation in degrees, ala DrawText
	Variable/D tickAngle		// angle tickmark is drawn at, angle measured from far end toward tick label end
	Variable/D xmin,xmax,ymin,ymax	// plot extent in drawn coordinates

	String str
	sprintf str,fmt,labelVal
//	if( (strlen(str)==1) %& CmpStr(str,"0")!=0) )	// so that wimpy labels like "1" don't get lost with %g
//		str+=".0"
//	endif

	Variable xj,yj,slop= 0.0980171	//  sin(pi/32) is 1/64th of a circle
	xj=1+ signRange(-cos(tickAngle),slop)
	yj= 1+ signRange(-sin(tickAngle),slop)
	SetDrawEnv textxjust=xj,textyjust=yj,textrot=lblOrient
	DrawText x0,y0,str

	return str
End

//returns 1 if angle is within the given range, else 0
Function AngleInRange(angle,angle0,angleRange)
	Variable/D angle,angle0,angleRange
	
	// reduce angle and angle0 to 0...4*Pi range
	Variable/D twoPi=2*Pi,lastAngle,eps=Pi/3600	// half a second
	if( abs(angleRange) >= twoPi)
		return 1
	endif

	Variable inRange
	angle= mod(angle,twoPi)
	if( angle < 0 )
		angle += twoPi
	endif
	angle0= mod(angle0,twoPi)
	if( angle0 < 0 )
		angle0 += twoPi
	endif
	lastAngle= angle0+angleRange
	if( angleRange > 0 )
		inRange= abs(angle- limit(angle,angle0,lastAngle)) < eps
		if( (!inRange) %& (lastAngle >= twoPi ) )
			inRange= abs(angle+twoPi -  limit(angle+twoPi,angle0,lastAngle)) < eps
		endif
	else
		inRange= abs(angle - limit(angle,lastAngle,angle0)) < eps
		if( (!inRange) %& (lastAngle <= 0 ) )
			inRange= abs(angle-twoPi -  limit(angle-twoPi,lastAngle,angle0)) < eps
		endif
	endif

	return inRange
End

// Returns number of angle axes, and on ouput wAxisRadii contains the (data) radii at which the axes are drawn.
Function RadiiForAngleAxes(numRadiusAxes,wAxisRadii,radiusStart,radiusEnd,radiusInc,minorRadiusTicks)
	Variable numRadiusAxes	// virtual length of wAxisRadii
	Wave/D wAxisRadii	// initially, this contains the data angles at which radius axes were drawn, on output it contains the radii at which angle axes are to be drawn.
	Variable/D radiusStart,radiusEnd,radiusInc,minorRadiusTicks

	Variable numAngleAxes=0
	Variable/D radius,firstRadius=radiusStart					// in case radiusStart is valueAtCenter
	Variable where=PolarGV("angleAxesWhere")		// Variable popup code: "Off;Radius Start;Radius End;Radius Start and End;All Major Radii;At Listed Radii"

	Variable/D valueAtCenter= PolarGV("valueAtCenter")
	
	if( where > 1 )	// 1 is "off"
		if( abs(valueAtCenter-radiusStart) < radiusInc/2 )	// disallow an angle axis at the center (r=0)
			firstRadius= radiusStart+radiusInc
			radiusStart=NaN
		else
			numAngleAxes= 1
		endif
		if( where == 2 )	// Radius Start
			wAxisRadii= {radiusStart,NaN}
		endif
		if( where == 3 )	// Radius End
			wAxisRadii= {radiusEnd,NaN}
			numAngleAxes= 1
		endif
		if( where == 4 )	// Radius Start and End (but start may be valueAtCenter)
			if( numAngleAxes == 0 )	// radiusStart is NaN, skip it
				wAxisRadii= {radiusEnd,NaN}
			else
				wAxisRadii= {radiusStart,radiusEnd}
			endif
			numAngleAxes+= 1
		endif
		if( where == 5 )	// All Major Radii (excepting valueAtCenter)
			numAngleAxes = trunc((radiusEnd-firstRadius) / radiusInc + 1)
			Redimension/N=(max(2,numAngleAxes)) wAxisRadii
			wAxisRadii= firstRadius + p * radiusInc
		endif
		if( where == 6)	// list of radii, for example "1,2,3"
			numAngleAxes= 0
			String str,radList=PolarGS("angleAxesRadiusList")
			if( strlen(radList) > 0 )
				// radList has radii, save in wave
				do
					str = StringFromList(numAngleAxes,radList,",")
					if( strlen(str) == 0 )
						break
					endif
					radius= str2num(str)
					if( radius != valueAtCenter )
						InsertPoints numAngleAxes,1,wAxisRadii
						wAxisRadii[numAngleAxes]=radius
						numAngleAxes+=1
					endif
				while (1)
			endif
		endif
	endif
	return numAngleAxes
End

// Draws angle axes (the "rings")
// All input angles in data coordinate radians.
Function FPolarAngleAxes(radiusStart,radiusEnd,radiusInc,angle0,angleRange,angleInc,angleMinorTicks,numAngleAxes,wAxisRadii,xmin,xmax,ymin,ymax,minspacing)
	Variable/D radiusStart,radiusEnd,radiusInc
	Variable/D angle0,angleRange,angleInc,angleMinorTicks	// angleMinorTicks == 0 if none
	Variable numAngleAxes
	Wave/D wAxisRadii	// radii, in drawn coordinates
	Variable/D xmin,xmax,ymin,ymax	// plot extent in drawn coordinates
	Variable/D minspacing					// affects only the spokes

	if( numAngleAxes < 1 )
		return 0
	endif
	
	Variable/D clipped,radius,deltaAngle,adjustedMinorTicks
	Variable/D angle,angleDraw,value
	Variable numMinorTicks=0,thick,inhibited
	NVAR u_x1=root:Packages:PolarGraphs:u_x1
	NVAR u_y1=root:Packages:PolarGraphs:u_y1
	NVAR u_x2=root:Packages:PolarGraphs:u_x2
	NVAR u_y2=root:Packages:PolarGraphs:u_y2
	
	String colorSpec= GetRGBColorFromList(PolarGV("angleAxisColorNdx"))
	Variable doMajorAngleTicks= PolarGV("doMajorAngleTicks")
	Variable doAngleTickLabels= PolarGV("doAngleTickLabels")
	Variable angleAxisThick= PolarGV("angleAxisThick")
	Variable majorAngleTickThick= PolarGV("majorAngleTickThick")
	Variable minorAngleTickThick= PolarGV("minorAngleTickThick")
	Variable/D lblOrient= PolarGV("angleTickLabelRotation")

	String str= PolarGS("angleTickLabelRange")	// label range, NOT the tick range
	Variable/D angleLabelStart = str2num(StringFromList(0,str,","))		// first number, in data coordinates
	Variable/D angleLabelRange = str2num(StringFromList(1,str,","))	// second number, in data coordinates
	if( (angleLabelStart == 0) %& ( angleLabelRange == 0 ) )
		angleLabelStart = 0
		angleLabelRange = 2*pi+0.001
	endif
	
	String fmt= PolarGS("angleTickLabelNotation")
	String font=PolarGS("angleAxisFontName")
	Variable fontSize= PolarGV("angleAxisFontSize")
	Variable radians= PolarGV("angleValues")== 2	// "degrees;radians"
	NVAR u_debug=root:Packages:PolarGraphs:u_debug
if( u_debug )
	SetDrawLayer UserFront	// labels
else
	SetDrawLayer UserAxes	// labels
endif
	SetDrawEnv xcoord= bottom,ycoord= left,save
	Execute "SetDrawEnv fname=\""+font+"\",save"
	SetDrawEnv fsize=fontSize,save

if( u_debug )
	SetDrawLayer ProgFront	// axes
else
	SetDrawLayer ProgAxes	// axes
endif
	Execute "SetDrawEnv linefgc="+colorSpec+",linebgc="+colorSpec+",save"
	SetDrawEnv xcoord= bottom,ycoord= left,save
	SetDrawEnv fillpat= 0,dash=0,save

	Variable/D drawnRadius,valueAtCenter=PolarGV("valueAtCenter")
	Variable radiusFunction=PolarGV("radiusFunction")

	if( angleMinorTicks > 0 )		// same as FPolarGrid minor tick calculations
		Make/D/O/N=(angleMinorTicks+1) W_adjustedRadii	// indexed by mod(i,angleTicks+1) (revised angleMinorTicks guaranteed less than original angleMinorTicks)
		// lie about radiusEnd by  radiusInc so that minor ticks can be drawn at end radius, even if no minor grid
		angleMinorTicks= CalcAdjustedRadiuses(W_adjustedRadii,angleMinorTicks,angleInc,radiusStart,radiusEnd+radiusInc,radiusInc,minspacing,radiusFunction,valueAtCenter)
		deltaAngle= angleInc/(angleMinorTicks+1)
	endif
	Variable zeroAngleWhere= PolarGV("zeroAngleWhere")	// popup code, "bottom;right;top;left", -90;0;+90;+180
	Variable angleDirection= PolarGV("angleDirection")		// popup code, "clockwise;counter-clockwise"
	Variable/D angle0Draw= PolarAngleFunction(angle0,zeroAngleWhere,angleDirection,2)	// drawn angle
	Variable/D angleDir= -sign(1- angleDirection )			// -1 if clockwise (angles drawn in opposite direction), 1 if ccw
	Variable/D angleIncDraw= angleInc * angleDir
	Variable/D angleRangeDraw= angleRange * angleDir		// drawn angle
	NVAR u_segsPerMinorArc=root:Packages:PolarGraphs:u_segsPerMinorArc
	Variable/D maxDeltaAngleDraw= min( DegToRad(PolarGV("maxArcLine")),angleIncDraw/(angleMinorTicks+1)/u_segsPerMinorArc)

	Variable/D majTickLen= PointsToDrawn(PolarGV("majorAngleTickLength"))
	Variable/D minTickLen= PointsToDrawn(PolarGV("minorAngleTickLength"))
	Variable/D lblOffsetPoints= PolarGV("angleTickLabelOffset")
	Variable/D lblOffset= PointsToDrawn(lblOffsetPoints)


	// Prevent overlapping radius axes at 0 and 2*Pi
	Variable/D absDeltaAngle= abs(angleInc/(angleMinorTicks+1))
	Variable/D lastMajorAngle= angle0 + angleRange	// idealistic case; doesn't work well when angleRange is 2 * Pi
	if (2*Pi - abs(angleRange) < absDeltaAngle/2 )	// eek, could have two overlapping radius grids at angleRange near 2*Pi.
		lastMajorAngle -= sign(angleRange) * absDeltaAngle/2
	endif
	
	Variable wantCircles=PolarGV("useCircles")==2	// DrawArc must also make sure each circle fits in xmin,xmax,ymin,ymax

	Variable/D tickOrient		// 0 or Pi, ticks parallel to radius angle (0 for labels on outside of axis, Pi for inside axis)
	Variable maj,tk,a= 0,labelLen
	sprintf str,fmt,lastMajorAngle	
	labelLen=FontSizeStringWidth(font,fontSize,0,str)
	sprintf str,fmt,angle0	
	labelLen=max(labelLen,FontSizeStringWidth(font,fontSize,0,str))

	do
		SetDrawEnv linethick=angleAxisThick,save	// angleAxisThick could be zero!
		radius= wAxisRadii[a]	// data radius
		drawnRadius=PolarRadiusFunction(radius,radiusFunction,valueAtCenter)  // drawn radius
		
		clipped= PolarDrawArc(drawnRadius,angle0Draw,angleRangeDraw,maxDeltaAngleDraw,xmin,xmax,ymin,ymax,wantCircles,angleAxisThick)	// 0 if invisible, 1 if not clipped, 2 if only x1,y1 clipped, 3 or 4 if x2,y2 clipped
		// Draw Tick marks, if turned on, and within the allowable range
		if( (clipped != 0) %& (doMajorAngleTicks != 1) )
			tickOrient= AngleTickOrientation(radius,drawnRadius,valueAtCenter,radiusStart,labelLen+lblOffsetPoints)	// someday add another param for user setting
			if( angleMinorTicks > 0  )
				adjustedMinorTicks= TicksForRadius(radius,angleMinorTicks,W_adjustedRadii)		// Minor Ticks per major increment is a variable number depending on the radius
				deltaAngle= angleInc/(adjustedMinorTicks+1)	// data coordinates
				numMinorTicks=floor(1+ (adjustedMinorTicks+1) * abs(angleRange/angleInc))	// total minor ticks, was round(...)
				tk= 1
				SetDrawEnv linethick=minorAngleTickThick,save
				angle= angle0 + deltaAngle	// we skip the major angles, to avoid two spokes at the same location
				do
					angleDraw= PolarAngleFunction(angle,zeroAngleWhere,angleDirection,2)	// drawn angle
					DrawTick(drawnRadius,angleDraw,minorAngleTickThick,minTickLen,0,tickOrient,xmin,xmax,ymin,ymax)
					tk += 1
					if( mod(tk,adjustedMinorTicks+1)==0 )	// we skip the major tick angles, to avoid two ticks at the same location
						tk += 1
					endif
					angle = angle0 + tk * deltaAngle
				while( tk <  numMinorTicks )
			endif
			// Major Ticks
			angle= angle0
			maj=0
			SetDrawEnv linethick=majorAngleTickThick,save
			do	// Major Ticks
				angleDraw= PolarAngleFunction(angle,zeroAngleWhere,angleDirection,2)	// drawn angle
				clipped= DrawTick(drawnRadius,angleDraw,majorAngleTickThick,majTickLen,lblOffset,tickOrient,xmin,xmax,ymin,ymax)
				inhibited =  !AngleInRange(angle,angleLabelStart,angleLabelRange)
				if( (clipped > 0) %& (doAngleTickLabels != 1) %& !inhibited )
if( u_debug )
		SetDrawLayer UserFront	// labels
else
		SetDrawLayer UserAxes	// labels
endif
					if( radians )
						value = angle
					else
						value= RadToDeg(angle)
					endif
					LabelTick(u_x2,u_y2,fmt,value,lblOrient,angleDraw+tickOrient,xmin,xmax,ymin,ymax)
if( u_debug )
		SetDrawLayer ProgFront	// axes
else
		SetDrawLayer ProgAxes	// axes
endif
				endif
				maj += 1
				angle = angle0 + maj * angleInc
if( u_debug)
//	print "radius= ",radius,"last tick clipped,majorAngleTickThick=",clipped,majorAngleTickThick," next tick at angle=",angle,"lastMajorAngle=",lastMajorAngle
endif
			while( angle <= lastMajorAngle )
		endif
		a+= 1
	while(a < numAngleAxes )
	KillWaves/Z W_adjustedRadii
End



// returns 0 or Pi to produce parallel ticks.
// 0 causes labels to be drawn outside of axis;
// Pi causes labels to be drawn inside of axis.
Function/D AngleTickOrientation(radius,drawnRadius,valueAtCenter,radiusStart,labelLenAndOffset)	// someday add another param for user setting
	Variable/D radius				// the data radius for this axis
	Variable/D drawnRadius		// the radius at which the axis is drawn
	Variable/D valueAtCenter		// the radius data value at the drawn center, usually zero
	Variable/D radiusStart		// starting radius as entered by the user, not fudged by RadiiForAngleAxes
	Variable labelLenAndOffset	// label font size plus label offset

	// we will assume that the most often labelled angle axes are the start and/or end radiuses
	// In the absence of a user setting for selection of where the labels will be drawn,
	// we choose to label axes usually on the outside of the axis.
	// However, when
	//	the radiusStart > valueAtCenter,
	//	AND radius == radiusStart,
	//	AND we believe there is room for the labels inside the radius,
	//	THEN the labels are on the inside of the axis.
	// The check for room inside the radius is rather crude since we can't measure a string's length.
	// we use the font height, but we need a stringwidth function, and the tick label format.

	Variable/D tickOrient=0		// defaults to outside of axis	
	if( radiusStart > valueAtCenter)	// horizontal axis
		Variable approxRadius=radius,approxRadiusStart=radiusStart // single precision for equality testing
		if (approxRadius == approxRadiusStart )
			Variable roomToLabel= (PointsToDrawn(labelLenAndOffset) < drawnRadius)
			if( roomToLabel )
				tickOrient= Pi			// inside axis
			endif
		endif
	endif
	return tickOrient
End


// numMinorTicks=
Function TicksForRadius(radius,angleMinorTicks,wAdjustedRadii)
	Variable/D radius
	Variable angleMinorTicks
	Wave/D wAdjustedRadii	// indexed by mod(i,angleTicks+1), where i is the minor tick number, from 1 to angleMinorTicks
	
	// return the number of adjusted (starting) radii that are less than radius
	Variable numMinorTicks=0,i=1
	if( angleMinorTicks > 0 )
		do
			if(  wAdjustedRadii[i] < radius )
				numMinorTicks+= 1
			endif
			i += 1
		while(i <=  angleMinorTicks)
	endif
	return numMinorTicks
End
