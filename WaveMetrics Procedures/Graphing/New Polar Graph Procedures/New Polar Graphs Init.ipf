#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=9.03		// Revised for Igor 9.03

#include <New Polar Graphs>  // so this procedure can compile on its own

// Part of the New Polar Graphs procedures
//
// 7/21/2000, JP: Version 4
// 7/9/2002, JP, Version 4.06
//	Added angleTickLabelScale parameter.
// 6/14/2017, JP, Version 7.05
//	Added Alpha parameters for colors.
// Version 8.041, JP191111, Added graphName string to each polar graph data folder, in case the user renames the window, or recreates PolarGraph0 as PolarGraph0_1.
// Version 9.02, JP230307, Added optional grid background color
// Version 9.024, JP230322, Added label Font Style

Function WMPolarGraphGlobalsInit()

	String oldDF= WMPolarSetSubfolderDF("")
	
	// All of the following vars and strings are in root:Packages:PolarGraphs

	// Tabs
	Make/O/T tabNames={"Main","Range","Axes","Ticks","Labels"}	// also the prefixes of controls in those tabs
	// Use WAVE/T tabNames= $WMPolarDFVar("tabNames") to get this wave.
	
	// Update limiters
	Variable/G prevTab		// 0 (kTabMain) initially, though we want to be able to call WMPolarGraphGlobalsInit() at any time.
	String/G previousTopGraph
	String/G previousDataFolder
	Variable/G delayPolarUpdate=0
	
	// Drawing globals
	Make/O angleIncrements={360, 180, 90, 45, 15, 5, 1}
	
// Defaults	
	WMPolarGraphDefaults("_default_")

	SetDataFolder oldDF
end

Function WMPolarGraphDefaults(subfolder)
	String subfolder

	String oldDF= WMPolarSetSubfolderDF(subfolder)		// the globals are created in this data folder.

	// Track current polar graph
	String/G graphName

	// PolarAppendWaves
	Variable/G anglePerCircle=360			// 2*pi if radians

	// Range Tab - Origin
	Variable/G zeroAngleWhere=0				// 0 = right, 90 = top, 180 = left, -90 = bottom
	Variable/G valueAtCenter=0

	// Range Tab - Rotation
	Variable/G angleDirection=-1				// 1 == clockwise, -1 == counter-clockwise"

	// Range Tab - Radius Function
	String/G radiusFunction="Linear"			// popup: "Linear;Log;Ln"

	// Range Tab - Radius Axes Range
	String/G doRadiusRange="auto"			// popup: auto;manual
	Variable/G doRadiusRangeMaxOnly=1	// in other words, the minimum is always valueAtCenter
	
	// corresponding outputs of WMPolarUpdateAxes (for auto radius axes)
	Variable/G autoRadiusMin=inf
	Variable/G autoRadiusMax=-inf

	Variable/G innerRadius=0					// (for manual)
	Variable/G outerRadius=1					// (for manual)

	// Range Tab - Angle Axes Range
	Variable/G angle0=0						// degrees
	Variable/G angleRange=360					// degrees

	// Axes Tab - Radius Axes
	String/G radiusAxesWhere="  0, 90"		// polRadAxesWherePop popup, BEWARE THE LEADING SPACES

		// NEW: for when radiusAxesWhere="Left" or "Bottom",
	Variable/G radiusAxesAtLeftBottomRadius	//  this is where the offset radius axis intersects a radius axis drawn from the origin
	String/G radiusAxesHalves					// "Upper Half;Lower Half;Both Halves" or ";Left Half;Right Half;Both Halves"

		// For when radiusAxesWhere == "At Listed Angles"
	String/G radiusAxesAngleList=""			// String - (user-specified angle list is initially empty)

	Variable/G radiusAxisColorRed, radiusAxisColorGreen, radiusAxisColorBlue
	Variable/G radiusAxisThick=1

	// Axes Tab - Angle Axes
	String/G angleAxesWhere="Radius End"		// "Off;Radius Start;Radius End;Radius Start and End;All Major Radii;At Listed Radii" 

		// For when angleAxesWhere == "At Listed Radii"
	String/G angleAxesRadiusList=""				// String - (user-specified radii list is initially empty)

	Variable/G angleAxisThick=1
	Variable/G angleAxisColorRed, angleAxisColorGreen, angleAxisColorBlue

	// Axes Tab - Grid
	Variable/G doPolarGrids=1				// checkbox, 0 for off, 1 for on
	
	// Igor 9.02: Grid background color
	Variable/G drawGridBackground=0			// Checkbox axesDrawGridBackground
	
	Variable/G gridBkgColorRed=	65535		// white - PopupMenu axesGridBkgColor
	Variable/G gridBkgColorGreen=	65535
	Variable/G gridBkgColorBlue=	65535
	Variable/G gridBkgColorAlpha=	65535
	
	// 		Major
	Variable/G majorGridColorRed=	0	// black
	Variable/G majorGridColorGreen=	0
	Variable/G majorGridColorBlue=	0
	Variable/G majorGridColorAlpha=	65535
	Variable/G majorGridStyle=0				// line style (=item number-1)
	Variable/G majorGridLineSize=1
	// 		Minor
	Variable/G minorGridColorRed=	32767	// light blue
	Variable/G minorGridColorGreen=	32767
	Variable/G minorGridColorBlue=	65535
	Variable/G minorGridColorAlpha=	65535
	Variable/G minorGridStyle=1				// line style (=item number-1)
	Variable/G minorGridLineSize=1

	// THESE PERHAPS SHOULD BE GLOBAL TO ALL POLAR GRAPHS
	// 		Min Grid Spacing
	Variable/G doMinGridSpacing=1				// 0 for finest grids, 1 to enable minGridSpacing
	Variable/G minGridSpacing=4				// minimum grid spacing in points,  0 for finest grids.
	// 		Resolution...
	Variable/G useCircles=1					//  0 for polygons, 1 for complete circles
	Variable/G maxArcLine=6					// longest straight line used to draw an arc, in points

	// Tick Tab - Radius Ticks
	String/G radiusTicksLocation="Crossing"	// popup: Off;Crossing;Inside;Outside
	String/G doMajorRadiusTicks="auto"		// "auto" or "manual"
	Variable/G radiusApproxTicks=5			// for auto
	Variable/G majorRadiusInc=0.5				// manual increment

	Variable/G doMinorRadiusTicks=0			// 0 for off, 1 for on
	Variable/G minorRadiusTicks=5				// manual exact minor ticks

	// Tick Tab - Angle Ticks
	String/G angleTicksLocation="Crossing"		// popup:  Off;Inside;Crossing;Outside
	String/G doMajorAngleTicks="auto"			// "auto" or "manual"
	Variable/G angleApproxTicks=8				// for auto
	Variable/G majorAngleInc=45				// manual increment in degrees

	Variable/G doMinorAngleTicks=1			// 0 for off, 1 for on
	Variable/G minorAngleTicks=3				// manual exact minor ticks (not an angle)

	// Tick Tab - Tick Sizes
	Variable/G majorTickThick=1				// was majorRadiusTickThick and majorAngleTickThick
	Variable/G majorTickLength=5				// was majorRadiusTickLength and majorAngleTickLength

	Variable/G minorTickThick=1				// was minorRadiusTickThick and minorAngleTickThick
	Variable/G minorTickLength=3				// was minorRadiusTickLength and minorAngleTickLength

	// Labels Tab - Radius Tick Labels
	Variable/G doRadiusTickLabels=1			// 0 for off, 1 for on
	Variable/G doRadiusTickLabelSubRange= 0	// 0 for all (except, possibly, the origin), 1 for subrange
	Variable/G radiusTickLabelOmitOrigin= 0	// 0 for off, 1 for on

	//			- Radius tick label subrange
	Variable/G radiusTickLabelRangeStart= 0	// use 0, 0 for label all ticks
	Variable/G radiusTickLabelRangeEnd= 0		// was radiusTickLabelRange

	//			- Radius Label Formats
	String/G radiusTickLabelRotation=" 0"		// popup: " -90;  0;+90;+180" BEWARE THE LEADING SPACES
	String/G radiusTickLabelSigns=" - only"	// popup:  " - only; + and -; no signs"
	String/G radiusTickLabelNotation="%g"		// ala Printf, they can put units here.
	Variable/G radiusTickLabelOffset=10		// offset from Axis (points, positive is farther from axis, -ve is closer)

	// Labels Tab - Angle Tick Labels
	Variable/G doAngleTickLabels=1				// 0 for off, 1 for on
	Variable/G doAngleTickLabelSubRange= 0	// 0 for all (except, possibly, the origin), 1 for subrange

	//			- Manual Angle tick label range
	Variable/G angleTickLabelRangeStart=0		//
	Variable/G angleTickLabelRangeExtent=0	// was angleTickLabelRange

	//			- Angle Label Formats
	String/G angleTickLabelRotation=" 0"		// popup: " -90;  0;+90;+180" BEWARE THE LEADING SPACES
	String/G angleTickLabelSigns=" - only"		// popup:  " - only; + and -; no signs"
	String/G angleTickLabelNotation="%g"		// String "%g", ala Printf
	Variable/G angleTickLabelOffset=0			// offset from Axis (points, positive is farther from axis, -ve is closer)
	String/G angleTickLabelUnits="degrees"		// "degrees" or "radians" (really fraction of Pi)
	Variable/G angleTickLabelScale=1			// new 6/19/2002, multiply angle tick value by constant.

	// Labels Tab - Font
	String/G tickLabelFontName="default"
	Variable/G tickLabelFontSize=10
	Variable/G tickLabelFontBold=0 // 9.03
	Variable/G tickLabelFontItalic=0 // 9.03
	
	Variable/G tickLabelOpaque= 1				// by default, opaque labels
	Variable/G tickLabelRed=0,tickLabelGreen=0,tickLabelBlue=0,tickLabelAlpha=65535

	// 9.03: Label Shadow
	Variable/G shadowedTickLabel= 0
	Variable/G shadowXOffset= 2, shadowYOffset= 2,shadowBlur= 2 // points
	Variable/G shadowRed=0, shadowGreen=0, shadowBlue=0, shadowAlpha=22000 // full opaque is 65535

	// Layers... Dialog (invoked on the Main tab, is its own dialog)
	Variable/G axesDrawInOneVirtualLayer=1	// default for 9.03
	String/G axesDrawLayer = "ProgAxes"		// below traces and above images, default for 9.03
	
	// Globals used by drawing routines: These are computed from user parameters in the subfolders.

	// outputs of WMPolarAxesRedraw()
	
	Variable/G plotAreaRed, plotAreaGreen, plotAreaBlue	
	
	// outputs of WMPolarTicks()
	Variable/G dataInnerRadius
	Variable/G dataOuterRadius
	Variable/G dataMajorRadiusInc
	Variable/G dataMinorRadiusTicks
	Variable/G firstMajorRadiusTick,lastMajorRadiusTick	// the major ticks don't necessarily start at the inner radius value
	
	Variable/G dataAngle0				// radians
	Variable/G dataAngleRange			// radians
	Variable/G dataMajorAngleInc		// radians
	Variable/G dataMinorAngleTicks

	//  outputs of FPolarGrid, FPolarAngleAxes
	Variable/G segsPerMinorArc=3
	
	Variable/G fullXMinDrawn, fullXMaxDrawn, fullYMinDrawn, fullYMaxDrawn // rectangle enclosing grids, axes and axis labels in drawn coordinates
	
	// for graph shifting detection
	Variable/G mouseDownModifiers
	
	// for currently selected polar trace
	String/G fillToZeroLayer	//  "" (off), "front" (UserBack), or"back" (ProgBack)
	Variable/G fillToZeroRed, fillToZeroGreen, fillToZeroBlue, fillToZeroAlpha


	SetDataFolder oldDF

End
