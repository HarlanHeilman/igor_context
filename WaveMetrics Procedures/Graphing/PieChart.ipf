#pragma rtGlobals=1		// Use modern global access method.
#pragma ModuleName=WMPieChart
#pragma version=9.01 		// Released with Igor 9.01
#pragma IgorVersion=6.02	// for GetRTStackInfo(2), ColorWaveEditor client mode
#pragma TextEncoding = "UTF-8"

#include <colorSpaceConversions>
#include <WaveSelectorWidget>, version>=1.02
#include <ColorWaveEditor>, version>=1.01

// PieChart.ipf
//
// Makes a pie chart using Igor Pro drawing tools and annotations.
// The package makes an empty graph window and draws the pie chart in it.
// You supply a data wave, the routines will create FracWave,
// a temporary wave which contains a version of the data that has been normalized
// to the sum, and then it will draw the wedges as polygons.
//
// The pie is drawn in window-relative coordinates; a number between 0 and 1
// represents 0 to 100% of the window dimension.
// The graph window keeps the plot area square so that the pie will be round.
//
// The pie is drawn in the ProgFront drawing layer.
// If you can't select the pie wedges, make sure you are in drawing mode
// (type command-T (Mac) or Ctrl+T (Win) to bring up the tool palette, and
// click the lower button).
// If you are in drawing mode, but still can't select pie wedges, you may be in the wrong drawing layer.
// Click on the drawing toolbar's Layers icon and select ProgFront from the popup menu.
//
// You can modify the pie in various ways:
// To move the pie, use the panel's Center X0 and Y0 controls. 
// To change the size of the pie, use the Pie Radius control.
// To color a wedge choose Custom Colors and edit the associated color.
// You can add more labels using Add Annotation in the Graph menu.
// To make an exploded wedge, simply click and drag the wedge while in drawing mode.
//
// PROGRAMMERS: Version 6.32: May 17, 2013, Added PieChartForProgrammers()
// for programmatic creation of 2D pie charts. 6.35: Also see ModifyPieChart().
//
// REVISIONS
// Version 4: Dec. 12, 1996, J. Weeks
// Version 5.02: Jul. 2, 2004, JP - added PieChartWithLabels and auto-colorizing,
//		no longer uses permanent global waves.
// Version 5.03b7: Oct. 14, 2004, JP - revised color method, replace Missing Parameter
//		Dialog with a panel similar to the Gizmo 3D Pie Chart panel.
// Version 5.03: Oct. 20, 2004, JP - Rearranged the panel items, improved error messages,
//		rewrote PieChartWithLabels() as TwoDPieChart(), use resize hook to maintain aspect ratio
//		instead of width={Aspect,1}.
//		PieChartVersion is now 2.
//		Since the pie wedges are now drawn in ProgFront, not UserFront, older charts are
//		cleared and the panel is closed and recreated.
// Version 5.04: April 22, 2005, JP - Fixed "Please Choose another Numeric Wave" bug.
//		Updating pie charts works if the window is renamed, PieChartVersion is now 3.
// Version 5.05: December14, 2005, JP - Added Custom Colors, PieChartVersion is now 4.
//		Labels now are drawn using annotations.  Double-click in pie chart opens Pie Chart panel,
//		Contextual click has shortened menu that includes Modify Pie Chart. Increased Saturation range.
// Version 6.02: August 14, 2007, JP - Adjusted some control positions to make panel native GUI-friendly, panel not editable.
// Version 6.03: October 5, 2007, JP - Fixed removal of labels when the Labels checkbox is unchecked. Uses WaveCRC for update check.
// Version 6.04: October 10, 2007, JW - Modified to use new client color wave editor mode.
// Version 6.05: September 25, 2008, JP - Allows 1 point waves (single wedge or full circle),
//		 has Outline Wedges... option, variable stroke width.
// Version 6.1: June 12, 2009, JP - Added PossiblyQuoteName code to work with liberally-named waves and data folders.
//		Now limits the list of waves to those that have 200 or fewer rows (previously limited to 1000 which is just an unreasonable number of wedges in a Pie Chart).
// Version 6.32: May 17, 2013, JP - Added PieChartForProgrammers(), an extended version of Pie_Chart() for programmatic creation of 2D pie charts.
//		Added ModifyPieChart() for progammatic alteration of 2D pie charts.
//		The legacy Pie_Chart() and PieChart() routines now create panel-compatible pie charts, and use MaintainAspectUsingMargins()
//		instead of ModifyGraph width={Aspect,1}. 
// Version 6.33: July 22, 2013, JP - Minor control position adjustments.
// Version 6.35: February 27, 2014, JP - Added missing RestoreDependency() calls where needed, mostly to PieChartForProgrammers().
// Version 6.38: October 12, 2015, JP - Added fill patterns, contextual menu to set color and patterns, one color for all.
//		Added WMPieAutomaticColor() and WMPieAutomaticPattern() which can be conveniently overridden to alter automatic colors and patterns.
// Version 6.381: January 12, 2016, JP - Fixed "Structure field index out of bounds" errors when data wave is more than 100 points.
// Version 6.382: January 13, 2016, JP - Changes to support liberal names for numeric data wave and label wave.
// Version 6.383: May 24, 2016, JP - Labels group checkbox formatting
// Version 7.01: July 5, 2016, JP - Text Wave Labels no longer have leading and trailing space added to them, which makes multi-line labels line up better.
//		Fixed repeated DoAlerts about Old version Pie Chart when user changes the name of the pie chart window.
// Version 8: February 18, 2019, JP - Works with long wave and data folder names. If you use short names (31 or less),
//		earlier versions of the Pie Chart procedure will continue to work.
// Version 8.04: October 8, 2019, JP - Added innerRadius, labelRotation, and explodeWedgesDistance. PieChartVersion is now 8.
// Version 8.041: October 10, 2019, JP - labels follow the exploded wedges.
// Version 8.042: January 18, 2020, JP - ModifyPieChart() supports Version 8 additions:
//		"wedgesInnerRadius" = numValue			// 0 to 1 (relative coordinates), default is 0
//		"labelRotation" = stringValue			// "0;45;90;-45;-90;Radial;Tangent;" should support other values
//		"explodeWedgesDistance" = numValue		// 0 to 0.999, default is 0
//		Unsuitable pie data is rejected.
// Version 9.0: August 10 2021, JP - Eliminated duplicate case statements that caused the procedure to not compile. Fixed PopupMenu solidPattern not updating to correct value.
// Version 9.01: August 27 2021, JP - Panel's control positions improved for Windows.

Static Constant kUseDrawText= 0		// Set kUseDrawText= 1 to use drawing tools text (the way PieChartVersions 1-3 did).
											// If you do that, you may need to manually remove annotation labels from updated pie charts.

Menu "New"
	"Pie Chart", /Q, New2DPieChart()
End

Menu "2D Pie", dynamic
	"New 2D Pie Chart",/Q, New2DPieChart()
	"Show 2D Pie Chart Panel",/Q,  ShowPieChartPanel()
	"2D Pie Chart Help",/Q,DisplayHelpTopic/K=1 "2D Pie Chart Procedure"
	"-"
	WMPieChart#PossiblyShowPieChartMenu("Debug 2D Pie Chart..."),/Q, WMPieChart#fShowPieStructure()
End

Menu "Graph"
	WMPieChart#PossiblyShowPieChartMenu("Modify 2D Pie Chart..."),/Q, ShowPieChartPanel()
End

Static Function/S PossiblyShowPieChartMenu(menuItem)
	String menuItem
	String topPie= TopPieChart()
	String topWin= WinName(0,1)
	if( strlen(topWin) == 0 || CmpStr(topWin, topPie) != 0 )
		menuItem=""	// no menu item
	endif
	
	return menuItem
End

// Returns name of graph with the pie chart.
// Use ModifyPieChart to modify an existing pie chart.
Function/S PieChartForProgrammers(graphName, dataWave, labelsMethod, labelsTextWave, [pieRadius, labelRadius, centerX, centerY, startAngleDegrees, ccw, wedgeTotalPct, fontName, fontSize, quiet])
	String graphName	// "" for top graph, "_new_" to create a new graph (name returned), else must be name of existing graph
	Wave dataWave		// data for wedges
	String labelsMethod	// "_wave_", "_value_", "_percent_", "_percent_and_tenths_", "_none_"
	Wave/T/Z labelsTextWave	// can be $"" if labelsMethod is not "_wave_", else the text wave holding the labels.
	// optional parameters (which need to be specified with name=value, such as labelRadius= 0.8)
	Variable pieRadius	// 0 - 0.5
	Variable labelRadius	// 0 - 1, default is 0.7 * pieRadius
	Variable centerX	// X coordinate of pie center (0 - 1), defaults to 0.5
	Variable centerY	// Y coordinate of pie center (0 - 1), defaults to 0.5
	Variable startAngleDegrees	// 0, 90, 180, or 270 corresponds to Right, Bottom, Left, or Top. Default is 0 (Right)
	Variable ccw		// 0 for clockwise (the default), else counter-clockwise.
	Variable wedgeTotalPct	// 0-100. Default is 100 (%)
	String fontName		// font name for labels, "" means use the graph's default font (also the default).
	Variable fontSize		// font size for labels, defaults to 10 points (if you want no labels, set labelsMethod="_none_"
	Variable quiet			// 0 to allow DoAlert for errors, else quiet (no DoAlert dialogs)
	
	// set values for missing optional parameters
	if( ParamIsDefault(pieRadius) )
		pieRadius= 0.5
	endif
	if( ParamIsDefault(labelRadius) )
		labelRadius= pieRadius * 0.7
	endif
	if( ParamIsDefault(centerX) )
		centerX= 0.5
	endif
	if( ParamIsDefault(centerY) )
		centerY= 0.5
	endif
	if( ParamIsDefault(startAngleDegrees) )
		startAngleDegrees= 0
	endif
	if( ParamIsDefault(ccw) )
		ccw= 0	// clockwise
	endif
	if( ParamIsDefault(wedgeTotalPct) )
		wedgeTotalPct= 100
	endif
	if( ParamIsDefault(fontName) )
		fontName= "default"	// default
	endif
	if( ParamIsDefault(fontSize) )
		fontSize= 10	// points
	endif
	if( ParamIsDefault(quiet) )
		quiet= 0	// allow DoAlerts
	endif

	// Use the parameters
	if( !WaveExists(dataWave) )
		if( !quiet )
			DoAlert 0, "Cannot find data wave: "+ GetWavesDataFolder(dataWave,2)
		endif
		return ""
	endif

	// "" for top graph, "_new_" to create a new graph (name returned), else must be name of existing graph
	graphName= InitPieChartGraph(win=graphName)
	
	STRUCT PieChartInfo pieInfo
	DefaultPieStruct(pieInfo)
	
	pieInfo.dataWaveFolder= GetWavesDataFolder(dataWave,1)
	pieInfo.dataWaveName= NameOfWave(dataWave)

	strswitch(labelsMethod)
		case "_none_":
			pieInfo.labelType= kPieLabelNone
			break
		case "_value_":
			pieInfo.labelType= kPieLabelValue
			break
		case "_percent_":
			pieInfo.labelType= kPieLabelPercent
			break
		case "_percent_and_tenths_":
			pieInfo.labelType= kPieLabelPercentTenths
			break
		case "_wave_":
		default:
			if( WaveExists(labelsTextWave) )
				pieInfo.labelType= kPieLabelWave
				pieInfo.labelWaveFolder= GetWavesDataFolder(labelsTextWave,1)
				pieInfo.labelWaveName= NameOfWave(labelsTextWave)
			else
				if( !quiet )
					DoAlert 0, "Cannot find labels wave: "+ GetWavesDataFolder(labelsTextWave,2)
				endif
				return ""
			endif
			break
	endswitch
		
	pieInfo.wedgesRadius= pieRadius
	pieInfo.labelRadius= labelRadius
	pieInfo.wedgesX0= CenterX
	pieInfo.wedgesY0= CenterY
	pieInfo.angle0Degrees= startAngleDegrees
	pieInfo.nextClockwise= ccw != 0
	pieInfo.wedgesTotalPct= wedgeTotalPct
	
	pieInfo.fontName=fontName
	pieInfo.fontSize=fontSize

	TwoDPieChart(graphName, pieInfo)
	PutPieStruct(graphName,pieInfo)	// ensures that UpdatePieChartPanel sees the assigned values.
	return graphName	
End

// ModifyPieChart modifies an existing pie chart (added for Igor 6.32)
// Note: one of stringvalue=str or numValue=num must be specified.
// Returns truth that graphName and name were valid
Function ModifyPieChart(graphName, name [ ,stringValue, numValue, red, green, blue, wedge])
	String graphName	// name of the pie chart graph, pass "" for top pie chart. See also TopPieChart().
	String name			// programming name of pieStruct element to modify
	String stringValue	// optional: string value to assign to pieStruct element
	Variable numValue	// optional: numeric value to assign to pieStruct element
	Variable red, green, blue	// optional: color value to assign to pieStruct element
	Variable wedge				// optional: for changing the properties of one wedge.
	
	if( !IsPieChart(graphName) )
		graphName= TopPieChart()
	endif
	
	STRUCT PieChartInfo pieInfo
	if( !GetPieStruct(graphName, pieInfo) )	// window userData is gone.
		return 0
	endif

	if( ParamIsDefault(stringValue) )
		stringValue= ""
	endif

	if( ParamIsDefault(numValue) )
		numValue= 0
	endif

	if( ParamIsDefault(red) || ParamIsDefault(green) || ParamIsDefault(blue) )
		if( CmpStr(name,"allWedgesColor") == 0 )
			red= pieInfo.allWedgesRed
			green= pieInfo.allWedgesGreen
			blue=pieInfo.allWedgesBlue
		else
			red= 0; green=0; blue=0
		endif
	endif

	Variable valid= 1	// cleared by default: case
	strswitch(name)
		default:
			valid= 0
			break
		
	// Numeric Data
		case "dataWave":
			WAVE/Z dataWave= $stringValue
			if( WaveExists(dataWave) )	// note that we don't check the number of rows. 200 is a practical  upper limit
				pieInfo.dataWaveFolder= GetWavesDataFolder(dataWave,1)
				pieInfo.dataWaveName= NameOfWave(dataWave)
			endif
			break

	// Labels
		case "labelType":
			strswitch( stringValue )
				case "_none_":
					pieInfo.labelType= kPieLabelNone
					break
				case "_value_":
					pieInfo.labelType= kPieLabelValue
					break
				case "_percent_":
					pieInfo.labelType= kPieLabelPercent
					break
				case "_percent_and_tenths_":
					pieInfo.labelType= kPieLabelPercentTenths
					break
				case "_wave_":
					pieInfo.labelType= kPieLabelWave
					// pieInfo.labelWaveFolder= GetWavesDataFolder(labelsTextWave,1)	// set using "labelWave" and stringValue
					//	pieInfo.labelWaveName= NameOfWave(labelsTextWave)
					break
			endswitch
			break
			
		case "labelWave":
			WAVE/Z/T labelsTextWave= $stringValue
			if( WaveExists(labelsTextWave) )	// note that we don't check the number of rows. 200 is a practical  upper limit
				pieInfo.labelWaveFolder= GetWavesDataFolder(labelsTextWave,1)
				pieInfo.labelWaveName= NameOfWave(labelsTextWave)
				pieInfo.labelType= kPieLabelWave
			endif
			break

		case "labelRadius":
			pieInfo.labelRadius= limit(numValue,0,1)	// 0 to 1 (relative coordinates)
			break
			
		case "labelFontName":
			pieInfo.fontName= stringValue
			break
			
		case "labelFontSize":
			pieInfo.fontSize= numValue
			break
			
		case "labelColor":
			pieInfo.labelRed= red
			pieInfo.labelGreen= green
			pieInfo.labelBlue= blue
			break

		case "labelRotation":				// Version 8: "0;45;90;-45;-90;Radial;Tangent;"
			pieInfo.labelRotation= stringValue
			break
			
	// Background
		case "backgroundColor":	
			pieInfo.bkgRed= red
			pieInfo.bkgGreen= green
			pieInfo.bkgBlue= blue
			break
			
	// Wedges
		case "wedgesTotalPct":
			pieInfo.wedgesTotalPct= limit(numValue, 0, 100)
			break

		case "wedgesRadius":
			pieInfo.wedgesRadius= limit(numValue, 0, 1)	// 0 to 1 (relative coordinates)
			break
			
		case "wedgesInnerRadius": // Version 8
			pieInfo.wedgesInnerRadius= limit(numValue, 0, 1)	// 0 to 1 (relative coordinates)
			break

		case "explodeWedgesDistance": // Version 8
			pieInfo.explodeWedgesDistance= limit(numValue, 0, 0.999)	// 0 to 0.999, default is 0
			break

		case "angle0Degrees":
			strswitch( stringValue )
				case "Right":
					pieInfo.angle0Degrees= 0
					break
				case "Bottom":
					pieInfo.angle0Degrees= 90
					break
				case "Left":
					pieInfo.angle0Degrees= 180
					break
				case "Top":
					pieInfo.angle0Degrees= 270
					break
				default:
					pieInfo.angle0Degrees= limit(numValue, -360,360)
					break
			endswitch
			break

		case "nextWedgeClockwise":
			pieInfo.nextClockwise= limit(numValue,0,1)		// boolean.
			break

		case "wedgesX0":
			pieInfo.wedgesX0= limit(numValue, 0, 1)	// 0 to 1 (relative coordinates)
			break

		case "wedgesY0":
			pieInfo.wedgesY0= limit(numValue, 0, 1)	// 0 to 1 (relative coordinates)
			break

	// Wedge Colors
	
		case "wedgesStroke":
			pieInfo.stroke= numValue	// stroke width in points.
			break

		case "strokeColor":	
			pieInfo.strokeRed= red
			pieInfo.strokeGreen= green
			pieInfo.strokeBlue= blue
			break

		case "wedgesLightness":
			pieInfo.lightness= limit(numValue, 0, 100)	// 0 to 100
			break

		case "wedgesSaturation":
			pieInfo.saturation= limit(numValue, 0, 100)	// 0 to 100
			break
			
		case "autoWedgesColor":
			numValue= limit(numValue,0,1)		// boolean.
			if( numValue )
				pieInfo.useCustomColors= 0
				pieInfo.useAllWedgesColor= 0
				break
			endif
			// else FALL THROUGH to custom Colors
			numValue= 1	// custom

		case "customColors":
			numValue= limit(numValue,0,1)		// boolean.
			if( numValue )	// want custom colors: therefore either the customColorTable must already be filled in (numCustomColorsInitialized > 0 )
							// or stringValue must be a color table wave (a color index wave whose X scaling we ignore)
				WAVE/Z colorWave= $stringValue	// expected N x 3 wave, n  between 1 and 100
				String pathToDataWave= pieInfo.dataWaveFolder + PossiblyQuoteName(pieInfo.dataWaveName)
				WAVE/Z dw= $pathToDataWave
				if( WaveExists(colorWave) && DimSize(colorWave,0) >= 1 && DimSize(colorWave,1) >= 3 )
					Variable i, rows= limit(DimSize(colorWave,0),0,100)
					for( i=0; i<rows; i+=1 )
						pieInfo.customColorTable.customRed[i] = colorWave[i][0]
						pieInfo.customColorTable.customGreen[i] = colorWave[i][1]
						pieInfo.customColorTable.customBlue[i] = colorWave[i][2]
					endfor
					pieInfo.numCustomColorsInitialized= rows
					// Kill any existing custom colors wave to force rebuilding using the colors from the customColorTable
					// Because any existing color wave is connected to a dependency that updates the pie chart wedges
					// the wave is not killable while the dependency is in force.
					String chartDFName= pieInfo.dependencyDataFolderName
					if( strlen(chartDFName) == 0 )	// 6.35
						if( pieInfo.labelType == kPieLabelWave )
							String pathToLabelWave= pieInfo.labelWaveFolder + PossiblyQuoteName(pieInfo.labelWaveName)
							WAVE/Z/T tw= $pathToLabelWave
						endif
						pieInfo.dependencyDataFolderName= SetUpDependency(graphName, "", dw, tw , colorWaveOrNULL=colorWave)
					else
						ClearDependency(chartDFName)
						String pathToColorWave= ChartNameDFVar(chartDFName, "pieChartCustomColors")
						KillWaves/Z $pathToColorWave
					endif
				elseif (pieInfo.numCustomColorsInitialized < 1 )
					// there aren't any colors defined,
					// so use the auto colors
					if( WaveExists(dw) )
						Variable NumWedges= limit(DimSize(dw,0),0,100)
						for(i=0; i<NumWedges; i+=1)
							WMPieAutomaticColor(i, numWedges, red, green, blue)	// red, green, blue are 0-65535
							pieInfo.customColorTable.customRed[i]= red
							pieInfo.customColorTable.customGreen[i]= green
							pieInfo.customColorTable.customBlue[i]= blue
						endfor
					else
						numValue= 0
					endif
				endif
			endif
			if( pieInfo.useCustomColors != numValue )
				pieInfo.useCustomColors= numValue
				pieInfo.useAllWedgesColor= 0	// unchecking returns to auto.
			endif
			break
			
		case "allWedgesColor":
			numValue= limit(numValue,0,1)		// boolean.
			if( numValue )	// want all wedges colors: therefore either the customColorTable must already be filled in (numCustomColorsInitialized > 0 )
				pieInfo.allWedgesRed= red
				pieInfo.allWedgesGreen= green
				pieInfo.allWedgesBlue= blue
			endif
			if( pieInfo.useAllWedgesColor != numValue )
				pieInfo.useAllWedgesColor= numValue
				pieInfo.useCustomColors= 0	// unchecking returns to auto.
			endif
			break
			
		case "wedgeColor":
			if( ParamIsDefault(wedge) )
				Print "ModifyPieChart error: wedge=wedgeNumber is missing"
			else
				Variable useCustomColors= 1
				WMPieSetWedgeColor(graphName, pieInfo, wedge, red, green, blue, useCustomColors)
			endif
			break

	// Wedge Patterns
		case "autoWedgePatterns":
			for(i=0; i<PIE_MAX_PATTERNS; i+= 1)
				pieInfo.fillPatterns.fillPat[i] = WMPieAutomaticPattern(i)
			endfor
			pieInfo.numFillPatternsInitialized= PIE_MAX_PATTERNS
			break
		case "allWedgePatterns":
			numValue= limit(numValue, -1, 4+72)
			for(i=0; i<PIE_MAX_PATTERNS; i+= 1)
				pieInfo.fillPatterns.fillPat[i] = 5 + mod(i,72)
			endfor
			pieInfo.numFillPatternsInitialized= PIE_MAX_PATTERNS
			break
		case "wedgePattern":
			if( ParamIsDefault(wedge) )
				Print "ModifyPieChart error: wedge=wedgeNumber is missing"
			else
				numValue= limit(numValue, -1, 4+72)
				WMPieSetWedgePattern(graphName, wedge, pieInfo, numValue)
			endif
			break

		case "wedgePatternBkgColor":
			pieInfo.patBkRed= red
			pieInfo.patBkGreen= green
			pieInfo.patBkBlue= blue
			break

	// Wedges Outline

		case "outlineWedgesThickness":	
			pieInfo.outlineWedgesThickness= numValue	// 0 if no wedges are specially outlined, else line thickness (points) of the outline.
			break

		case "outlineWedgesFirst":	
			pieInfo.outlineWedgesFirst= limit(numValue,1,inf)	// 1-based indexes, 1..numWedges
			break

		case "outlineNumWedges":	
			pieInfo.outlineNumWedges= limit(numValue,1,inf)	// 1-based indexes, 1..numWedges
			break

		case "outlineWedgesColor":	
			pieInfo.outlineWedgesRed= red
			pieInfo.outlineWedgesGreen= green
			pieInfo.outlineWedgesBlue= blue
			break

		case "outlineHideSpokes":	
			pieInfo.outlineHideSpokes= limit(numValue, 0, 1)	// boolean
			break

	// Misc
		case "delayUpdates":
			pieInfo.delayUpdates= limit(numValue, 0, 1)	// boolean. applies only to dependency updates.
			break
		
	endswitch
	
	if( valid )
		TwoDPieChart(graphName, pieInfo)
		RestoreDependency(graphName, pieInfo)
		PutPieStruct(graphName,pieInfo)	// save any change to pieInfo.dependencyDataFolderName
	endif
	
	return valid
End

Function Pie_Chart()	// pre-5.03 pie chart remains for compatibility

	String DataWave, Labels
	Variable Radius=.4
	Variable CenterX=.5
	Variable CenterY=.5

	Prompt DataWave, "Data wave", popup, WaveList("*", ";", "TEXT:0,CMPLX:0,DIMS:1")
	Prompt Labels, "Label wave or method", popup, WaveList("*", ";", "TEXT:1,CMPLX:0,DIMS:1")+"\\M1-;_value_;_percent_;_percent_and_tenths_;_none_"
	Prompt Radius, "Pie radius (0 - 0.5)"
	Prompt CenterX, "X coordinate of pie center (0 - 1)"
	Prompt CenterY,  "Y coordinate of pie center (0 - 1)"
	
	Variable startAnglePos=1
	Prompt startAnglePos,  "First Wedge at", popup, "Right;Bottom;Left;Top;"
	
	Variable ccw=2
	Prompt ccw, "Angle", popup, "Clockwise;Counter-Clockwise;"

	String helpText="Pie Chart Procedure"	// help topic
	DoPrompt/HELP=(helpText) "Pie Chart", DataWave, Labels, startAnglePos, Radius, CenterX, CenterY, ccw
	
	if( V_Flag != 0 )
		return 0
	endif
	
	STRUCT PieChartInfo pieInfo
	DefaultPieStruct(pieInfo)
	
	Wave/Z dw= $DataWave
	if( WaveExists(dw) )
		pieInfo.dataWaveFolder= GetWavesDataFolder(dw,1)
		pieInfo.dataWaveName= NameOfWave(dw)
	else
		DoAlert 0, "Cannot find data wave: "+ DataWave
		return 0
	endif

//	Display as "2D Pie Chart"
//	ModifyGraph width={Aspect,1}
	String graphName= InitPieChartGraph()	// 6.32

	strswitch(Labels)
		case "_none_":
			pieInfo.labelType= kPieLabelNone
			break
		case "_value_":
			pieInfo.labelType= kPieLabelValue
			break
		case "_percent_":
			pieInfo.labelType= kPieLabelPercent
			break
		case "_percent_and_tenths_":
			pieInfo.labelType= kPieLabelPercentTenths
			break
		default:
			WAVE/T/Z tw= $Labels
			if( WaveExists(tw) )
				pieInfo.labelType= kPieLabelWave
				pieInfo.labelWaveFolder= GetWavesDataFolder(tw,1)
				pieInfo.labelWaveName= NameOfWave(tw)
			endif
			break
	endswitch
		
	pieInfo.wedgesRadius= Radius
	pieInfo.labelRadius= Radius * 0.7
	pieInfo.angle0Degrees= (startAnglePos-1) * 90	// 0, 90, 180, or 270 corresponds to Right, Bottom, Left, or Top
	pieInfo.wedgesX0= CenterX
	pieInfo.wedgesY0= CenterY
	pieInfo.nextClockwise= ccw != 2

	TwoDPieChart(graphName, pieInfo)
	RestoreDependency(graphName, pieInfo)	// 6.35
	PutPieStruct(graphName, pieInfo)	// ensures that UpdatePieChartPanel sees the assigned values.
End


// for legacy experiments (Pre 5.02)
Function PieChart(DataWave, Radius, CenterX, CenterY, NameBase)
	Wave/Z DataWave
	Variable Radius, CenterX, CenterY
	String NameBase	// not used
	
	STRUCT PieChartInfo pieInfo
	DefaultPieStruct(pieInfo)
	
	if( WaveExists(DataWave) )
		pieInfo.dataWaveFolder= GetWavesDataFolder(DataWave,1)
		pieInfo.dataWaveName= NameOfWave(DataWave)
	else
		DoAlert 0, "DataWave is NULL!"
		return 0
	endif

	String graphName= InitPieChartGraph(win= WinName(0,1))	// 6.32

	pieInfo.labelType= kPieLabelNone
	pieInfo.wedgesRadius= Radius
	pieInfo.labelRadius= Radius * 0.7
	pieInfo.wedgesX0= CenterX
	pieInfo.wedgesY0= CenterY

	TwoDPieChart(graphName, pieInfo)
	RestoreDependency(graphName, pieInfo)	// 6.35
	PutPieStruct(graphName,pieInfo)	// ensures that UpdatePieChartPanel sees the assigned values.
End

// +++++++++++++++++ Support routines +++++++++++++
Static Function/S TempDF()
	return "root:Packages:WMPieChart"
End

Static Function/S ChartDFVar(varName)
	String varName
	
	String df= TempDF()
	if( !DataFolderExists(df) )
		NewDataFolder/O root:Packages
		NewDataFolder/O $df
	endif
	return df+":"+PossiblyQuoteName(varName)
End

// set the data folder to a place where Execute can dump all kinds of variables and waves
Static Function/S SetTempDF()

	String oldDF= GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O/S $TempDF()	// DF is left pointing here
	return oldDF
End

Static Function/S ChartNameDFVar(dfName,varName)
	String dfName, varName
	
	String df= TempDF()+":Charts:"+dfName	// data folder name was same as window name prior to version 3.

	return df+":"+PossiblyQuoteName(varName)
End

// +++++++++++++++++ Panel-based Pie Chart +++++++++

Constant PieChartVersion = 8
// version 1 was shipped with Igor 5.02b7, 2 with Igor 5.03, 3 with 5.04b6, 4 with 5.05, 5 with 6.05 SPECIAL.
// Version 6 was shipped with Igor 6.38 and later.
// Version 8 was shipped with Igor 8.04 and later.

// Store pie chart parameters as a fixed-length structure in the graph's window user data.
// Igor 6.32 makes these definitions public rather than static.

Constant PIE_MAX_OBJ_NAME = 31	// as shipped with Igor 6.38 and 7.01, and as stored in fixed-length pieInfo
Constant PIE_MAX_PATH_LEN = 99	// as shipped with Igor 6.38 and 7.01

// variable-length paths to waves, wave names,
// and data folder names are stored in separate named window userDatas:
StrConstant PIE_USERDATA_PATH_TO_NUM_WAVE = "WMPieChartDataPath"
StrConstant PIE_USERDATA_PATH_TO_LBL_WAVE = "WMPieChartLabelPath"
StrConstant PIE_USERDATA_DATAFOLDER_NAME = "WMPieChartDataFolderName"

Constant kPieLabelNone= 0
Constant kPieLabelWave= 1
Constant kPieLabelValue= 2
Constant kPieLabelPercent= 3
Constant kPieLabelPercentTenths= 4

Constant PIE_MAX_COLORS = 100
Structure pieColorTable
	uint16 customRed[100]
	uint16 customGreen[100]
	uint16 customBlue[100]
EndStructure

Constant PIE_MAX_PATTERNS = 100
Structure piePatterns
	int16 fillpat[100]
EndStructure

// Fixed-length version for storage into window user data.
Structure PieChartInfoFixedLength
	// The order of structure members up to labelWaveName
	// MUST BE KEPT IN THE SAME ORDER AND HAVE THE SAME SIZES FOREVER.
	uint16	 version

	// Numeric Data
	char dataWaveFolder[PIE_MAX_PATH_LEN+1]	// full path to the numeric data wave's folder (only) WITH trailing colon
	char dataWaveName[PIE_MAX_OBJ_NAME+1]		// name of the wave
	
	// Labels
	uint16 labelType								// one of kPieLabelNone, kPieLabelWave, kPieLabelValue, kPieLabelPercent, or kPieLabelPercentTenths
	char labelWaveFolder[PIE_MAX_PATH_LEN+1]	// full path to the label text waves folder (only) WITH trailing colon, or ""
	char labelWaveName[PIE_MAX_OBJ_NAME+1]	// name of the label wave, or ""

	// Version 2 members start here

	double labelRadius
	char fontName[100]
	double fontSize
	uint16 labelRed, labelGreen, labelBlue

	// Background
	uint16 bkgRed, bkgGreen, bkgBlue

	// Wedges
	double wedgesTotalPct

	uint16 stroke									// stroke width in points
	uint16 strokeRed, strokeGreen, strokeBlue		// wedge stroke color
	
	double wedgesRadius							// 0 to 1 (relative coordinates)
	int16	angle0Degrees							// 0, 90, 180, or 270 corresponds to Right, Bottom, Left, or Top
	uint16 nextClockwise							// boolean. Default is counter-clockwise
	double wedgesX0, wedgesY0						// center of wedges (relative coordinates)
	
	double lightness, saturation						// in %, affects wedge colors

	// Delay (auto) updates
	uint16 delayUpdates							// boolean. applies only to dependency updates.

	// Version 3 members start here
	char dependencyDataFolderName[PIE_MAX_OBJ_NAME+1]	// so that the window can be renamed. Once set, this shouldn't be changed.

	// Version 4 members start here
	uint16 useCustomColors		// if false (the default) and useAllWedgesColor is false, use WMPieAutomaticColor(i,numWedges)
	uint16 numCustomColorsInitialized	// initially 0, set to number of colors in customColorTable[] that are actually initialized
	STRUCT pieColorTable customColorTable
	
	// Version 5 members start here
	double outlineWedgesThickness					// 0 if no wedges are specially outlined, else line thickness (points) of the outline.
	uint16 outlineWedgesFirst, outlineNumWedges	// 1-based indexes, 1..numWedges
	uint16 outlineWedgesRed, outlineWedgesGreen, outlineWedgesBlue		// wedge outline color
	// added Dec 2008
	int16 outlineHideSpokes		// 0 to show them, 1 to hide them
	
	// Version 6 members start here
	uint16 useAllWedgesColor
	uint16 allWedgesRed, allWedgesGreen, allWedgesBlue

	uint16 numFillPatternsInitialized	// initially 0, set to number of patterns in fillPatterns[] that are actually initialized
	STRUCT piePatterns fillPatterns		// SetDrawEnv fillpat numbers

	uint16 patBkRed, patBkGreen, patBkBlue		// pattern background color

	// Version 8 members start here
	double wedgesInnerRadius							// 0 to 1 (relative coordinates), default is 0
	char labelRotation[100]							// "0;45;90;-45;-90;Radial;Tangent;" // could add other numbers
	double explodeWedgesDistance						// 0 to 0.999, default is 0
	
EndStructure

// This Variable-length pieInfo structure supports long wave and datafolder names
Structure PieChartInfo
	uint16 version

	// Numeric Data
	// userdata PIE_USERDATA_PATH_TO_NUM_WAVE is split into the two following Strings
	String dataWaveFolder	// full path to the numeric data wave's folder (only) WITH trailing colon
	String dataWaveName	// name of the wave
	
	// Labels
	uint16 labelType								// one of kPieLabelNone, kPieLabelWave, kPieLabelValue, kPieLabelPercent, or kPieLabelPercentTenths
	// userdata PIE_USERDATA_PATH_TO_LBL_WAVE is split into the two following Strings
	String labelWaveFolder	// full path to the label text waves folder (only) WITH trailing colon, or ""
	String labelWaveName	// name of the label wave, or ""

	// Version 2 members start here

	double labelRadius
	char fontName[100]
	double fontSize
	uint16 labelRed, labelGreen, labelBlue

	// Background
	uint16 bkgRed, bkgGreen, bkgBlue

	// Wedges
	double wedgesTotalPct

	uint16 stroke									// stroke width in points
	uint16 strokeRed, strokeGreen, strokeBlue		// wedge stroke color
	
	double wedgesRadius							// 0 to 1 (relative coordinates)
	int16	angle0Degrees							// 0, 90, 180, or 270 corresponds to Right, Bottom, Left, or Top
	uint16 nextClockwise							// boolean. Default is counter-clockwise
	double wedgesX0, wedgesY0						// center of wedges (relative coordinates)
	
	double lightness, saturation						// in %, affects wedge colors

	// Delay (auto) updates
	uint16 delayUpdates							// boolean. applies only to dependency updates.

	// Version 3 members start here
	// userdata PIE_USERDATA_DATAFOLDER_NAME is stored in dependencyDataFolderName
	String dependencyDataFolderName	// so that the window can be renamed. Once set, this shouldn't be changed.

	// Version 4 members start here
	uint16 useCustomColors		// if false (the default) and useAllWedgesColor is false, use WMPieAutomaticColor(i,numWedges)
	uint16 numCustomColorsInitialized	// initially 0, set to number of colors in customColorTable[] that are actually initialized
	STRUCT pieColorTable customColorTable
	
	// Version 5 members start here
	double outlineWedgesThickness					// 0 if no wedges are specially outlined, else line thickness (points) of the outline.
	uint16 outlineWedgesFirst, outlineNumWedges	// 1-based indexes, 1..numWedges
	uint16 outlineWedgesRed, outlineWedgesGreen, outlineWedgesBlue		// wedge outline color
	// added Dec 2008
	int16 outlineHideSpokes		// 0 to show them, 1 to hide them
	
	// Version 6 members start here
	uint16 useAllWedgesColor
	uint16 allWedgesRed, allWedgesGreen, allWedgesBlue

	uint16 numFillPatternsInitialized	// initially 0, set to number of patterns in fillPatterns[] that are actually initialized
	STRUCT piePatterns fillPatterns		// SetDrawEnv fillpat numbers

	uint16 patBkRed, patBkGreen, patBkBlue		// pattern background color
	
	// Version 8 members start here
	double wedgesInnerRadius							// 0 to 1 (relative coordinates), default is 0
	String labelRotation;								// "0;45;90;-45;-90;Radial;Tangent;" // could add other numbers
	double explodeWedgesDistance						// 0 to 0.999, default is 0
EndStructure


Static Function DefaultFixedLengthPieStruct(pieVersion6)
	STRUCT PieChartInfoFixedLength &pieVersion6

	STRUCT PieChartInfo pieInfo
	DefaultPieStruct(pieInfo)
	MakePieStructFixedLength(pieInfo, pieVersion6)
End

Static Function DefaultPieStruct(pieInfo)
	STRUCT PieChartInfo &pieInfo

	pieInfo.version= PieChartVersion
	pieInfo.dataWaveFolder= ""
	pieInfo.dataWaveName=""
	
	// Labels
	pieInfo.labelType= kPieLabelPercent
	pieInfo.labelWaveFolder= ""
	pieInfo.labelWaveName= ""
	
	// Version 2 starts here
	pieInfo.labelRadius= 0.42
	pieInfo.fontName="default"
	pieInfo.fontSize=10
	pieInfo.labelRed= 0
	pieInfo.labelGreen= 0
	pieInfo.labelBlue= 0

	// Background
	pieInfo.bkgRed= 65535
	pieInfo.bkgGreen= 65535
	pieInfo.bkgBlue= 65535

	// Wedges
	pieInfo.wedgesTotalPct= 100
	
	pieInfo.stroke= 1
	pieInfo.strokeRed= 0
	pieInfo.strokeGreen= 0
	pieInfo.strokeBlue= 0
			
	pieInfo.wedgesRadius= 0.34
	pieInfo.angle0Degrees= 0	// 0, 90, 180, or 270 corresponds to Right, Bottom, Left, or Top
	pieInfo.nextClockwise= 0	// boolean
	pieInfo.wedgesX0= 0.5
	pieInfo.wedgesY0= 0.5		// center of wedges (relative coordinates)

	pieInfo.lightness= 100
	pieInfo.saturation=100
	
	// Updating
	pieInfo.delayUpdates	= 0		// boolean. applies only to dependency updates.
	
	// Version 3
	pieInfo.dependencyDataFolderName= ""
	
	// Version 4
	pieInfo.useCustomColors=0
	pieInfo.numCustomColorsInitialized= 0
	
	// Version 5 members start here
	pieInfo.outlineWedgesThickness= 0	// no wedges are specially outlined
	pieInfo.outlineWedgesFirst=1			// 1-based index, 1..numWedges
	pieInfo.outlineNumWedges=1
	pieInfo.outlineWedgesRed=0	// wedge outline color defaults to green
	pieInfo.outlineWedgesGreen=65535
	pieInfo.outlineWedgesBlue=0
	
	// Dec 2008
	pieInfo.outlineHideSpokes= 0

	// Version 6 members start here
	pieInfo.useAllWedgesColor= 0
	pieInfo.allWedgesRed= 65535/2
	pieInfo.allWedgesGreen= 65535/2
	pieInfo.allWedgesBlue= 65535/2
	
	pieInfo.numFillPatternsInitialized= PIE_MAX_PATTERNS
	Variable i
	for(i=0;i<PIE_MAX_PATTERNS;i+=1)
		pieInfo.fillPatterns.fillpat[i]= 1	// solid
	endfor
	
	// pattern background color
	pieInfo.patBkRed = 65535
	pieInfo.patBkGreen = 65535
	pieInfo.patBkBlue = 65535
	
	// Version 8 members start here
	pieInfo.wedgesInnerRadius = 0
	pieInfo.labelRotation="0"
	pieInfo.explodeWedgesDistance = 0
End	

Function GetPieStruct(win, pieInfo)
	String win
	STRUCT PieChartInfo &pieInfo
	
	if( !IsPieChart(win) )
		win= TopPieChart()
		if( strlen(win) == 0 )
			DefaultPieStruct(pieInfo)
			return 0
		endif
	endif	
	
	String userdata = GetUserData(win, "", "WMPieChart")
	Variable len= strlen(userdata)
	STRUCT PieChartInfoFixedLength pieFixed
	StructGet/S pieFixed, userdata // only the fixed-length version can be Get/Put into a string and userdata
	Variable oldVersion = pieFixed.version
	UpdateFixedPieStructToCurrent(win, pieFixed) // update out-dated pieInfo structures to current version
	CopyFixedPieStructToVarLength(win, pieFixed, pieInfo)	
	MakePieStructCompatible(win, pieInfo)	

	PutPieStruct(win, pieInfo) 			// save updated pie info
	
	if( oldVersion == 1 )
		SetDrawLayer/W=$win/K userFront		// Version 1 drew in UserFront, which obscures ProgFront
		ModifyGraph/W=$win width=0			// Version 1 used width={Aspect,1}, version 2 uses the resize hook.
		UpdatePieChart(win)
		DoWindow PieChartPanel
		if( V_Flag )
			DoWindow/K PieChartPanel	// it is missing the new controls or they're in the wrong place
			ShowPieChartPanel()
		endif
	endif
	
	return len > 0
End

// Copy fields from a version 6 pie info struct, with its fixed-length char arrays,
// into a current-version pie info struct, with its String representations
// for wave paths, wave name, and data folder names.
//
// The limitations on Structure char[] arrays means that paths to wave with long names or data folders
// can be properly represented by only String members, not char[400] members.
// So we need a variable-length PieChartInfo to support long names.
Static Function CopyFixedPieStructToVarLength(win, pieIn, pieOut)
	String win	// when a pie chart is first constructed, win cannot be ""
	STRUCT PieChartInfoFixedLength &pieIn		// must be fully updated to version 6
	STRUCT PieChartInfo &pieOut		// current version, Igor 8.03 or later, filled with default values

	// Version
	pieOut.version = pieIn.version
	
	// Numeric Data
	pieOut.dataWaveFolder = pieIn.dataWaveFolder // copies from char[] to String
	pieOut.dataWaveName = pieIn.dataWaveName
	
	// Labels
	pieOut.labelType = pieIn.labelType

	pieOut.labelWaveFolder = pieIn.labelWaveFolder
	pieOut.labelWaveName = pieIn.labelWaveName
	
	pieOut.labelRadius = pieIn.labelRadius

	pieOut.fontName = pieIn.fontName
	pieOut.fontSize = pieIn.fontSize

	pieOut.labelRed = pieIn.labelRed
	pieOut.labelGreen = pieIn.labelGreen
	pieOut.labelBlue = pieIn.labelBlue

	// Background
	pieOut.bkgRed = pieIn.bkgRed
	pieOut.bkgGreen = pieIn.bkgGreen
	pieOut.bkgBlue = pieIn.bkgBlue

	// Wedges
	pieOut.wedgesTotalPct = pieIn.wedgesTotalPct

	pieOut.stroke = pieIn.stroke
	pieOut.strokeRed = pieIn.strokeRed
	pieOut.strokeGreen = pieIn.strokeGreen
	pieOut.strokeBlue = pieIn.strokeBlue

	pieOut.wedgesRadius = pieIn.wedgesRadius

	pieOut.angle0Degrees = pieIn.angle0Degrees
	pieOut.nextClockwise = pieIn.nextClockwise

	pieOut.wedgesX0 = pieIn.wedgesX0
	pieOut.wedgesY0 = pieIn.wedgesY0

	pieOut.lightness = pieIn.lightness
	pieOut.saturation = pieIn.saturation

	// Delay (auto) updates
	pieOut.delayUpdates = pieIn.delayUpdates

	// Version 3 members start here
	pieOut.dependencyDataFolderName = pieIn.dependencyDataFolderName

	// Version 4 members start here
	pieOut.useCustomColors = pieIn.useCustomColors
	pieOut.numCustomColorsInitialized = pieIn.numCustomColorsInitialized
	pieOut.customColorTable = pieIn.customColorTable

	// Version 5 members start here
	pieOut.outlineWedgesThickness = pieIn.outlineWedgesThickness
	pieOut.outlineWedgesFirst = pieIn.outlineWedgesFirst
	pieOut.outlineNumWedges = pieIn.outlineNumWedges
	pieOut.outlineWedgesRed = pieIn.outlineWedgesRed
	pieOut.outlineWedgesGreen = pieIn.outlineWedgesGreen
	pieOut.outlineWedgesBlue = pieIn.outlineWedgesBlue
	pieOut.outlineHideSpokes = pieIn.outlineHideSpokes
	
	// Version 6 members start here
	pieOut.useAllWedgesColor = pieIn.useAllWedgesColor
	pieOut.allWedgesRed = pieIn.allWedgesRed
	pieOut.allWedgesGreen = pieIn.allWedgesGreen
	pieOut.allWedgesBlue = pieIn.allWedgesBlue

	pieOut.numFillPatternsInitialized = pieIn.numFillPatternsInitialized
	pieOut.fillPatterns = pieIn.fillPatterns
	pieOut.patBkRed = pieIn.patBkRed
	pieOut.patBkGreen = pieIn.patBkGreen
	pieOut.patBkBlue = pieIn.patBkBlue
	
	// Version 8 members start here
	pieOut.wedgesInnerRadius = pieIn.wedgesInnerRadius
	pieOut.labelRotation = pieIn.labelRotation
	pieOut.explodeWedgesDistance = pieIn.explodeWedgesDistance
End

// Copy fields from a the current version pie info struct
// with its String representations for wave paths, wave name, and data folder names
// into a pie info struct with its fixed-length char arrays.
//
// The limitations on Structure char[] arrays means that paths to wave with long names or data folders
// can be properly represented by only String members, not char[400] members.
// but only fixed-length structures can be stored in strings and window userdata,
// so we need a fixed-length version of the current PieChartInfo.
Static Function MakePieStructFixedLength(pieIn, pieOut)
	STRUCT PieChartInfo &pieIn		// must be fully updated to version PieChartVersion
	STRUCT PieChartInfoFixedLength &pieOut		// current version, Igor 8.03 or later, filled with default values

	// Version
	pieOut.version = pieIn.version

	// Numeric Data
	pieOut.dataWaveFolder = pieIn.dataWaveFolder // copies from char[] to String
	pieOut.dataWaveName = pieIn.dataWaveName
	
	// Labels
	pieOut.labelType = pieIn.labelType

	pieOut.labelWaveFolder = pieIn.labelWaveFolder
	pieOut.labelWaveName = pieIn.labelWaveName
	
	pieOut.labelRadius = pieIn.labelRadius

	pieOut.fontName = pieIn.fontName
	pieOut.fontSize = pieIn.fontSize

	pieOut.labelRed = pieIn.labelRed
	pieOut.labelGreen = pieIn.labelGreen
	pieOut.labelBlue = pieIn.labelBlue

	// Background
	pieOut.bkgRed = pieIn.bkgRed
	pieOut.bkgGreen = pieIn.bkgGreen
	pieOut.bkgBlue = pieIn.bkgBlue

	// Wedges
	pieOut.wedgesTotalPct = pieIn.wedgesTotalPct

	pieOut.stroke = pieIn.stroke
	pieOut.strokeRed = pieIn.strokeRed
	pieOut.strokeGreen = pieIn.strokeGreen
	pieOut.strokeBlue = pieIn.strokeBlue

	pieOut.wedgesRadius = pieIn.wedgesRadius

	pieOut.angle0Degrees = pieIn.angle0Degrees
	pieOut.nextClockwise = pieIn.nextClockwise

	pieOut.wedgesX0 = pieIn.wedgesX0
	pieOut.wedgesY0 = pieIn.wedgesY0

	pieOut.lightness = pieIn.lightness
	pieOut.saturation = pieIn.saturation

	// Delay (auto) updates
	pieOut.delayUpdates = pieIn.delayUpdates

	// Version 3 members start here
	pieOut.dependencyDataFolderName = pieIn.dependencyDataFolderName

	// Version 4 members start here
	pieOut.useCustomColors = pieIn.useCustomColors
	pieOut.numCustomColorsInitialized = pieIn.numCustomColorsInitialized
	pieOut.customColorTable = pieIn.customColorTable

	// Version 5 members start here
	pieOut.outlineWedgesThickness = pieIn.outlineWedgesThickness
	pieOut.outlineWedgesFirst = pieIn.outlineWedgesFirst
	pieOut.outlineNumWedges = pieIn.outlineNumWedges
	pieOut.outlineWedgesRed = pieIn.outlineWedgesRed
	pieOut.outlineWedgesGreen = pieIn.outlineWedgesGreen
	pieOut.outlineWedgesBlue = pieIn.outlineWedgesBlue
	pieOut.outlineHideSpokes = pieIn.outlineHideSpokes
	
	// Version 6 members start here
	pieOut.useAllWedgesColor = pieIn.useAllWedgesColor
	pieOut.allWedgesRed = pieIn.allWedgesRed
	pieOut.allWedgesGreen = pieIn.allWedgesGreen
	pieOut.allWedgesBlue = pieIn.allWedgesBlue

	pieOut.numFillPatternsInitialized = pieIn.numFillPatternsInitialized
	pieOut.fillPatterns = pieIn.fillPatterns
	pieOut.patBkRed = pieIn.patBkRed
	pieOut.patBkGreen = pieIn.patBkGreen
	pieOut.patBkBlue = pieIn.patBkBlue
	
	// Version 8 members start here
	pieOut.wedgesInnerRadius = pieIn.wedgesInnerRadius
	pieOut.labelRotation = pieIn.labelRotation
	pieOut.explodeWedgesDistance = pieIn.explodeWedgesDistance
End


Static Function UpdateFixedPieStructToCurrent(win, pieInfo)
	String win	// when a pie chart is first constructed, win cannot be ""
	STRUCT PieChartInfoFixedLength &pieInfo

	if( pieInfo.version != PieChartVersion )
		// The data and label waves are designed to always be valid.
		// That means that the order of structure members up to labelWaveName
		// MUST BE KEPT IN THE SAME ORDER AND HAVE THE SAME SIZES FOREVER.
		
		// remember whatever old settings exist, then transfer them to the new default Pie Struct.
		Variable oldVersion=pieInfo.version

		Printf "Old version Pie Chart (%g) detected: updating to newer version (%g), some settings may need to be reset to defaults.\r", oldVersion, PieChartVersion

		String dwf= pieInfo.dataWaveFolder
		String dwn= pieInfo.dataWaveName
		Variable labelType= pieInfo.labelType
		String twf= pieInfo.labelWaveFolder
		String twn= pieInfo.labelWaveName

		STRUCT piePatterns fillPatterns
		Variable numFillPatternsInitialized= 0
		
		switch( oldVersion )
			// put case for newer versions here
					// fall through
			
			case 8: // PieChartVersion
				// Version 8 members start here
				Variable wedgesInnerRadius = pieInfo.wedgesInnerRadius
				String labelRotation = pieInfo.labelRotation
				Variable 	explodeWedgesDistance= pieInfo.explodeWedgesDistance
					// fall through
					
			case 6:
				// Version 6 members start here
				Variable useAllWedgesColor = pieInfo.useAllWedgesColor
				Variable allWedgesRed = pieInfo.allWedgesRed
				Variable allWedgesGreen = pieInfo.allWedgesGreen
				Variable allWedgesBlue = pieInfo.allWedgesBlue

				numFillPatternsInitialized= pieInfo.numFillPatternsInitialized
				fillPatterns= pieInfo.fillPatterns
				
				Variable patBkRed= pieInfo.patBkRed
				Variable patBkGreen =pieInfo.patBkGreen
				Variable patBkBlue =pieInfo.patBkBlue

					// fall through
			case 5:
				Variable outlineHideSpokes= pieInfo.outlineHideSpokes
				Variable outlineWedgesThickness= pieInfo.outlineWedgesThickness
				Variable outlineWedgesFirst= pieInfo.outlineWedgesFirst
				Variable outlineNumWedges= pieInfo.outlineNumWedges
				Variable outlineWedgesRed= pieInfo.outlineWedgesRed
				Variable outlineWedgesGreen= pieInfo.outlineWedgesGreen
				Variable outlineWedgesBlue= pieInfo.outlineWedgesBlue
					// fall through
			case 4:
				Variable useCustomColors= pieInfo.useCustomColors
				Variable numCustomColorsInitialized= pieInfo.numCustomColorsInitialized
				STRUCT pieColorTable customColorTable
				customColorTable= pieInfo.customColorTable				
					// fall through
			case 3:
				String dependencyDataFolderName= pieInfo.dependencyDataFolderName
					// fall through
			case 2:
				// preserve version 2 stuff, which is the same place as the current version
				Variable labelRadius= pieInfo.labelRadius
				String fontName= pieInfo.fontName
				Variable fontSize= pieInfo.fontSize
				Variable labelRed= pieInfo.labelRed
				Variable labelGreen= pieInfo.labelGreen
				Variable labelBlue= pieInfo.labelBlue

				Variable bkgRed= pieInfo.bkgRed
				Variable bkgGreen= pieInfo.bkgGreen
				Variable bkgBlue= pieInfo.bkgBlue

				Variable wedgesTotalPct= pieInfo.wedgesTotalPct
	
				Variable stroke= pieInfo.stroke
				Variable strokeRed= pieInfo.strokeRed
				Variable strokeGreen= pieInfo.strokeGreen
				Variable strokeBlue= pieInfo.strokeBlue
			
				Variable wedgesRadius= pieInfo.wedgesRadius
				Variable angle0Degrees= pieInfo.angle0Degrees
				Variable nextClockwise= pieInfo.nextClockwise
				Variable wedgesX0= pieInfo.wedgesX0
				Variable wedgesY0= pieInfo.wedgesY0

				Variable lightness= pieInfo.lightness
				Variable saturation= pieInfo.saturation
	
				Variable delayUpdates= pieInfo.delayUpdates
				break
		endswitch
		
		// initialize the fixed-length pieInfo.
		DefaultFixedLengthPieStruct(pieInfo)
		
		// Always put Version 1 stuff back
		pieInfo.dataWaveFolder= dwf
		pieInfo.dataWaveName= dwn
		pieInfo.labelType= labelType
		pieInfo.labelWaveFolder= twf
		pieInfo.labelWaveName= twn
		
		// Put more recent version stuff back if it was there
		switch( oldVersion )
			// put case for newer versions here
					// fall through
			
			case 8: // PieChartVersion
				// Version 8 members start here
				pieInfo.wedgesInnerRadius= wedgesInnerRadius
				pieInfo.labelRotation= labelRotation
				pieInfo.explodeWedgesDistance= explodeWedgesDistance
					// fall through
			case 6:
				// Version 6 members start here
				pieInfo.useAllWedgesColor= useAllWedgesColor
				pieInfo.allWedgesRed= allWedgesRed
				pieInfo.allWedgesGreen= allWedgesGreen
				pieInfo.allWedgesBlue= allWedgesBlue

				pieInfo.numFillPatternsInitialized= pieInfo.numFillPatternsInitialized
				pieInfo.fillPatterns= fillPatterns
				
				pieInfo.patBkRed= patBkRed
				pieInfo.patBkGreen= patBkGreen
				pieInfo.patBkBlue= patBkBlue
					// fall through
			case 5:
				pieInfo.outlineHideSpokes= outlineHideSpokes
				pieInfo.outlineWedgesThickness= outlineWedgesThickness
				pieInfo.outlineWedgesFirst= outlineWedgesFirst
				pieInfo.outlineNumWedges= outlineNumWedges
				pieInfo.outlineWedgesRed= outlineWedgesRed
				pieInfo.outlineWedgesGreen= outlineWedgesGreen
				pieInfo.outlineWedgesBlue= outlineWedgesBlue
					// fall through
			case 4:
				pieInfo.useCustomColors=useCustomColors
				pieInfo.numCustomColorsInitialized= numCustomColorsInitialized
				pieInfo.customColorTable= customColorTable
					// fall through
			case 3:
				pieInfo.dependencyDataFolderName= dependencyDataFolderName
					// fall through
			case 2:
				// restore version 2 stuff
				pieInfo.labelRadius= labelRadius
				pieInfo.fontName= fontName
				pieInfo.fontSize= fontSize
				pieInfo.labelRed= labelRed
				pieInfo.labelGreen= labelGreen
				pieInfo.labelBlue= labelBlue
			
				pieInfo.bkgRed= bkgRed
				pieInfo.bkgGreen= bkgGreen
				pieInfo.bkgBlue= bkgBlue
			
				pieInfo.wedgesTotalPct= wedgesTotalPct
				
				pieInfo.stroke= stroke
				pieInfo.strokeRed= strokeRed
				pieInfo.strokeGreen= strokeGreen
				pieInfo.strokeBlue= strokeBlue
						
				pieInfo.wedgesRadius= wedgesRadius
				pieInfo.angle0Degrees= angle0Degrees
				pieInfo.nextClockwise= nextClockwise
				pieInfo.wedgesX0= wedgesX0
				pieInfo.wedgesY0= wedgesY0
			
				pieInfo.lightness= lightness
				pieInfo.saturation=saturation
				
				pieInfo.delayUpdates	= delayUpdates
				break
		endswitch

		if( oldVersion < 3 )
			// New for Version 3
			pieInfo.dependencyDataFolderName= win
		endif
	endif
End

// The limitations on Structure char[] arrays means that paths to wave with long names or data folders
// can be properly represented by only String members, not char[400] members.
// MakePieStructCompatible() fills out the long-name members of STRUCT PieChartInfo
// from other userdata strings.
Static Function MakePieStructCompatible(win, pieInfo)
	String win	// when a pie chart is first constructed, win cannot be ""
	STRUCT PieChartInfo &pieInfo

	// Numeric Data
	String dataWavePath = GetUserData(win, "", PIE_USERDATA_PATH_TO_NUM_WAVE)
	if( strlen(dataWavePath) )
		pieInfo.dataWaveFolder = ParseFilePath(1, dataWavePath, ":", 1, 0)	// doesn't include the ending element, has trailing ":"
		pieInfo.dataWaveName = ParseFilePath(0, dataWavePath, ":", 1, 0)		// keep only the ending element, no leading ":"
	endif
	
	// Labels
	String labelWavePath = GetUserData(win, "", PIE_USERDATA_PATH_TO_LBL_WAVE)
	if( strlen(labelWavePath) )
		pieInfo.labelWaveFolder = ParseFilePath(1, labelWavePath, ":", 1, 0)	// doesn't include the ending element, has trailing ":"
		pieInfo.labelWaveName = ParseFilePath(0, labelWavePath, ":", 1, 0)	// keep only the ending element, no leading ":"
	endif

	// DependencyDataFolderName is remembered so that the window can be renamed.
	// Once set, dependencyDataFolderName shouldn't be changed.
	String dependencyDataFolderName= GetUserData(win, "", PIE_USERDATA_DATAFOLDER_NAME)
	if( strlen(dependencyDataFolderName) )
		pieInfo.dependencyDataFolderName= dependencyDataFolderName
	endif
End

// If the user keeps to 31-char object names,
// the saved pieStruct can be read by an earlier version of the Pie Chart code.
Static Function PutPieStruct(win, pieInfo)
	String win	// must currently BE a pie chart window (graph)
	STRUCT PieChartInfo &pieInfo
	
	if( !IsPieChart(win) )
		win= TopPieChart()
		if( strlen(win) == 0 )
			return 0
		endif
	endif	

	SetPieStruct(win, pieInfo)

	return 1
End

Static Function SetPieStruct(win, pieInfo)
	String win	// when a pie chart is first constructed, win cannot be ""
	STRUCT PieChartInfo &pieInfo
	
	if( strlen(win) == 0 )
		return 0
	endif
	Variable wt = WinType(win)
	if( wt != 1 ) // must be graph
		return 0
	endif	

	String dataWavePath = pieInfo.dataWaveFolder + pieInfo.dataWaveName // Note: not PossiblyQuote()-d
	SetWindow $win userData($PIE_USERDATA_PATH_TO_NUM_WAVE)= dataWavePath

 	String labelWavePath = pieInfo.labelWaveFolder + pieInfo.labelWaveName // Note: not PossiblyQuote()-d
	SetWindow $win userData($PIE_USERDATA_PATH_TO_LBL_WAVE)= labelWavePath

	String dependencyDataFolderName= pieInfo.dependencyDataFolderName
	SetWindow $win userData($PIE_USERDATA_DATAFOLDER_NAME)= dependencyDataFolderName

	STRUCT PieChartInfoFixedLength pie6
	MakePieStructFixedLength(pieInfo, pie6)

	String infoStr
	StructPut/S pie6, infoStr
	SetWindow $win userData(WMPieChart)= infoStr

	return 1
End

// Prior to 6.32, TopPieChart was a static function.
Function/S TopPieChart()

	String list= WinList("*", ";", "WIN:1")
	Variable i=0
	do
		String win= StringFromList(i,list)
		if( strlen(win) == 0 )
			return ""
		endif
		String userdata = GetUserData(win, "", "WMPieChart")
		if( strlen(userData) )
			return win
		endif
		i += 1
	while(1)

	return ""
End

// Debugging

Static Function fShowPieStructure()

	String win= TopPieChart()
	if( strlen(win) == 0 )
		Print "(no pie charts)"
		return 0
	endif	

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	Printf "Window: %s,  version= %d\r", win, pieInfo.version
	
	String dwf= pieInfo.dataWaveFolder
	String dwn= pieInfo.dataWaveName

	String pathToDataWave= dwf + PossiblyQuoteName(dwn)
	WAVE/Z dw= $pathToDataWave
	if( !WaveExists(dw) )
		Print "Could not locate data wave: \""+pathToDataWave+"\"!"
	else
		Print "Data Wave: "+pathToDataWave
	endif

	String lwf= pieInfo.labelWaveFolder
	String lwn= pieInfo.labelWaveName

	if( strlen(lwn) )
		String pathToLabelWave= lwf + PossiblyQuoteName(lwn)
		WAVE/Z/T tw= $pathToLabelWave
		if( !WaveExists(tw)  )
			Print "Could not locate "+pathToLabelWave+"."
		else
			Print "Label Wave: "+pathToLabelWave
		endif
	endif
	
	if( pieInfo.version >= 3 )
		Print "Chart data folder: \""+ pieInfo.dependencyDataFolderName + "\""
	endif

	if( pieInfo.version >= 4 )
		Printf "useCustomColors= %d, numCustomColorsInitialized=%d\r", pieInfo.useCustomColors, pieInfo.numCustomColorsInitialized
		Variable i
		for(i=0; i< pieInfo.numCustomColorsInitialized;i+=1 )
			Printf "r,g,b[%d]= %d, %d, %d\r", i, pieInfo.customColorTable.customRed[i], pieInfo.customColorTable.customGreen[i], pieInfo.customColorTable.customBlue[i]
		endfor
	endif

	if( pieInfo.version >= 5 )
		Printf "outlineHideSpokes= %d, outlineWedgesThickness=%d\r", pieInfo.outlineHideSpokes, pieInfo.outlineWedgesThickness

		Printf "outlineWedgesFirst= %d, outlineNumWedges=%d\r", pieInfo.outlineWedgesFirst, pieInfo.outlineNumWedges
		Printf "outlineWedges (r, g, b)= (%d, %d, %d)\r", pieInfo.outlineWedgesRed, pieInfo.outlineWedgesGreen, pieInfo.outlineWedgesBlue
	endif

	if( pieInfo.version >= 6 )
		Printf "useAllWedgesColor= %d, color=(%d,%d,%d)\r", pieInfo.useAllWedgesColor, pieInfo.allWedgesRed, pieInfo.allWedgesGreen, pieInfo.allWedgesBlue
	
		Printf "numFillPatternsInitialized=%d\r", pieInfo.numFillPatternsInitialized
		for(i=0; i< pieInfo.numFillPatternsInitialized;i+=1 )
			Printf "fillpat[%d]= %d\r", i, pieInfo.fillPatterns.fillpat[i]
		endfor

		Printf "pattern bkg(r, g, b)= (%d, %d, %d)\r", pieInfo.patBkRed, pieInfo.patBkGreen, pieInfo.patBkBlue

	endif

	if( pieInfo.version >= 8 )
		Printf "wedgesInnerRadius= %g\r", pieInfo.wedgesInnerRadius
		Printf "explodeWedgesDistance= %g\r", pieInfo.explodeWedgesDistance
		Printf "labelRotation= \"%s\"\r", pieInfo.labelRotation
	endif

End


Static Function UpdatePieChart(win)
	String win
	// get settings from the pie chart structure (not the panel)
	// and update the pie chart
	if( !IsPieChart(win) )
		win= TopPieChart()
		if( strlen(win) == 0 )
			return 0
		endif
	endif
	
	STRUCT PieChartInfo pieInfo
	GetPieStruct(win, pieInfo)
	TwoDPieChart(win, pieInfo)

	RestoreDependency(win, pieInfo)
	PutPieStruct(win,pieInfo)	// save any change to pieInfo.dependencyDataFolderName
End

Static Function RestoreDependency(win, pieInfo)
	String win
	STRUCT PieChartInfo &pieInfo

	String pathToDataWave= pieInfo.dataWaveFolder + PossiblyQuoteName(pieInfo.dataWaveName)
	WAVE/Z dw= $pathToDataWave
	if( !WaveExists(dw) )
		return 0
	endif

	Variable labelType= pieInfo.labelType
	if( labelType == kPieLabelWave )
		String pathToLabelWave= pieInfo.labelWaveFolder + PossiblyQuoteName(pieInfo.labelWaveName)
		WAVE/Z/T tw= $pathToLabelWave
	endif
	if( pieInfo.useCustomColors )
		WAVE/Z/U/W cw= $WedgeColorWavePath(pieInfo)	// might not exist, yet.
	else
		WAVE/Z/U/W cw= $""
	endif
	pieInfo.dependencyDataFolderName= SetUpDependency(win, pieInfo.dependencyDataFolderName, dw, tw, colorWaveOrNULL=cw)
	PutPieStruct(win,pieInfo)	// save any change to pieInfo.dependencyDataFolderName
End

// Debugging
static Function fResetCustomColors([win])
	String win
	
	if( ParamIsDefault(win) )
		win= TopPieChart()
	endif
	if( !IsPieChart(win) )
		Print "(no pie charts)"
		return 0
	endif	

	STRUCT PieChartInfo pieInfo
	GetPieStruct(win, pieInfo)

	String chartDFName= pieInfo.dependencyDataFolderName
	String pathToColorWave= ChartNameDFVar(chartDFName, "pieChartCustomColors")
	KillWaves/Z $pathToColorWave
	
	pieInfo.useCustomColors= 0
	pieInfo.numCustomColorsInitialized= 0
	pieInfo.useAllWedgesColor= 0

	PutPieStruct(win,pieInfo)	// save any change to pieInfo.dependencyDataFolderName
	UpdatePieChartPanel()
	UpdatePieChart("")
End

// You can use an override function to change this algorithm
// DisplayHelpTopic "Function Overrides"
Function WMPieAutomaticColor(wedge, numWedges, red, green, blue)
	Variable wedge	// input, 0 is the first wedge.
	Variable numWedges	// input, number of wedges in total
	Variable &red, &green, &blue		// outputs each in the range of 0-65535

	WM_GetDistinctColor(wedge, numWedges, red, green, blue,1)	// red, green, blue are 0-65535
End

// returns wedge color unmodified by saturation or lightness
Function WMPieColorForWedge(pieWin, wedgeNo, numWedges, pieInfo, red, green, blue)
	String pieWin
	Variable wedgeNo, numWedges
	STRUCT PieChartInfo &pieInfo	// see DefaultPieStruct and GetPieStruct
	Variable &red, &green, &blue	// OUTPUTS

	Variable haveCustomColor= pieInfo.useCustomColors
	Variable oneColorForAll= pieInfo.useAllWedgesColor
	if( oneColorForAll )
		red= pieInfo.allWedgesRed
		green= pieInfo.allWedgesGreen
		blue= pieInfo.allWedgesBlue
	elseif( haveCustomColor )
		String pathToColorWave= CreateWedgeColorWave(pieWin, pieInfo)
		Wave/U/W/Z cw=$pathToColorWave
		if( !WaveExists(cw) || wedgeNo >= DimSize(cw,0) )
			WMPieAutomaticColor(wedgeNo,numWedges,red, green, blue)	// red, green, blue are 0-65535
		else
			red= cw[wedgeNo][0]
			green= cw[wedgeNo][1]
			blue= cw[wedgeNo][2]
		endif
	else
		WMPieAutomaticColor(wedgeNo,numWedges,red, green, blue)	// red, green, blue are 0-65535
	endif
End

// returns truth that wedge is valid
// returns wedge color unmodified by saturation or lightness
Function WMPieGetWedgeColor(win, wedge, red, green, blue)
	String win
	Variable wedge
	Variable &red, &green, &blue

	Variable valid= 0

	STRUCT PieChartInfo pieInfo
	if( GetPieStruct(win, pieInfo) )
		String pathToDataWave= pieInfo.dataWaveFolder + PossiblyQuoteName(pieInfo.dataWaveName)
		WAVE/Z DataWave= $pathToDataWave
		if( WaveExists(DataWave) )
			Variable NumWedges= numpnts(DataWave)
			if( wedge >= 0 && wedge < NumWedges )
				WMPieColorForWedge(win, wedge, NumWedges, pieInfo, red, green, blue)	// red, green, blue are 0-65535
				valid= 1
			endif
		endif
	endif
	
	return valid
End

// Note that calling this routine will never leave the pie chart in Automatic Colors mode.
// don't forget to call 
//	PutPieStruct(win,pieInfo)	// save any change to pieInfo.dependencyDataFolderName
//	UpdatePieChartPanel()
//	UpdatePieChart(win)

Function WMPieSetWedgeColor(win, pieInfo, wedge, red, green, blue, useCustomColors)
	String win
	STRUCT PieChartInfo &pieInfo
	Variable wedge
	Variable red, green, blue
	Variable useCustomColors		// if 1 switch to custom colors without asking (appropriate for programmer's i/f)
										// if 0, switch to useAllWedgesColor mode

	Variable valid= 0

	if( useCustomColors )
		String pathToDataWave= pieInfo.dataWaveFolder + PossiblyQuoteName(pieInfo.dataWaveName)
		WAVE/Z DataWave= $pathToDataWave
		if( WaveExists(DataWave) )
			Variable NumWedges= numpnts(DataWave)
			if( wedge >= 0 && wedge < NumWedges )
				Variable wasAutoColors= pieInfo.useCustomColors == 0 && pieInfo.useAllWedgesColor == 0
				Variable wasAllOneColor= pieInfo.useAllWedgesColor
				Variable wasCustomColors= pieInfo.useCustomColors
				
				String pathToColorWave= CreateWedgeColorWave(win, pieInfo)
				Wave/U/W/Z cw=$pathToColorWave
				
				// there are three important cases:
				// 1) the colors are all the same, in which case we copy the same color into each custom color
				// 2)	the colors are automatic, in which case we copy the WM_distinct colors
				// 3)	the color are already custom
				if( !wasCustomColors )
					Variable i
					Variable oldRed= pieInfo.allWedgesRed
					Variable oldGreen= pieInfo.allWedgesGreen
					Variable oldBlue= pieInfo.allWedgesBlue

					for(i=0; i<NumWedges; i+=1)
						if( wasAutoColors )
							WMPieAutomaticColor(i, numWedges, oldRed, oldGreen, oldBlue)	// red, green, blue are 0-65535
						endif
						if( WaveExists(cw) && i < DimSize(cw,0) )
							cw[i][0]= oldRed
							cw[i][1]= oldGreen
							cw[i][2]= oldBlue
						endif
						if( i<PIE_MAX_COLORS )
							pieInfo.customColorTable.customRed[i]= oldRed
							pieInfo.customColorTable.customGreen[i]= oldGreen
							pieInfo.customColorTable.customBlue[i]= oldBlue
						endif
					endfor
					pieInfo.useCustomColors= 1
					pieInfo.useAllWedgesColor= 0
				endif

				cw[wedge][0]= red
				cw[wedge][1]= green
				cw[wedge][2]= blue
				if( wedge < PIE_MAX_COLORS )
					pieInfo.customColorTable.customRed[wedge]= red
					pieInfo.customColorTable.customGreen[wedge]= green
					pieInfo.customColorTable.customBlue[wedge]= blue
				endif
				valid= 1
			endif
		endif
	else
		pieInfo.useCustomColors= 0
		pieInfo.useAllWedgesColor= 1
		pieInfo.allWedgesRed= red
		pieInfo.allWedgesGreen= green
		pieInfo.allWedgesBlue= blue
	endif
	
	return valid
End


Function TwoDPieChart(win, pieInfo)
	String win
	STRUCT PieChartInfo &pieInfo	// see DefaultPieStruct and GetPieStruct

	// Check data wave
	String pathToDataWave= pieInfo.dataWaveFolder + PossiblyQuoteName(pieInfo.dataWaveName)
	WAVE/Z DataWave= $pathToDataWave
	if( !WaveExists(DataWave) )
		ShowHint("Select Numeric Data to start.")
		// DoAlert 0, "Could not locate "+pathToDataWave+"! Please Choose another Numeric Data Wave."
		return 0
	endif
	if( numpnts(DataWave) < 1 )
		DoAlert 0, "At least one value is needed to create a Pie Chart!"
		return 0
	endif

	// Check text wave
	if( pieInfo.labelType == kPieLabelWave )
		String pathToLabelWave= pieInfo.labelWaveFolder + PossiblyQuoteName(pieInfo.labelWaveName)
		WAVE/Z/T labelWave= $pathToLabelWave
		if( !WaveExists(labelWave) )
//			pieInfo.labelType= kPieLabelNone	// this made the labels wave list get hidden if you failed to select a text wave
		endif
	endif

	// check font name
	String fonts= FontList(";" )
	Variable whichOne= WhichListItem(pieInfo.fontName, fonts)
	if( whichOne < 0 )
		pieInfo.fontName="default"
	endif	

	Variable total, EndFrac
	Variable StartAngle, EndAngle, NumWedges
	Variable i,j,n
	Variable x0, y0, xi, yi
	Variable xOrigin, yOrigin // these are a possibly-exploded origin.
	Variable explodeAngle
	Variable angle, angle0= pi * pieInfo.angle0Degrees/180
	Variable red, green, blue
	Variable radius= pieInfo.wedgesRadius
	Variable innerRadius= pieInfo.wedgesInnerRadius // had always been 0 until Version 8
	Variable explodeWedgesDistance= pieInfo.explodeWedgesDistance // new for Version 8, add to inner and outer radii
	
	SetDrawLayer/W=$win/K ProgFront
	String df= SetTempDF() // create the temporary waves in a Packages data folder

	Duplicate/O DataWave, FracWave
	NumWedges=numpnts(FracWave)
	FracWave[1,NumWedges-1] = FracWave[p-1] + FracWave[p]	// integrate
	total = FracWave[NumWedges-1]
	Variable maxFrac= pieInfo.wedgesTotalPct / 100
	FracWave = FracWave/total*maxFrac	// now it really is a "fraction wave"
	InsertPoints 0,1,FracWave	// inserts a 0
	i = 0
	do
		WMPieColorForWedge(win, i, NumWedges, pieInfo, red, green, blue)	// red, green, blue are 0-65535
		if( pieInfo.saturation != 100 || pieInfo.lightness != 100)
			Make/O/N=(1,1,3)/U/W rgbhsl
			WAVE/U/W  rgbhsl
			rgbhsl[0][0][0] = red	// 0-65535
			rgbhsl[0][0][1] = green
			rgbhsl[0][0][2] = blue
			ImageTransform/O rgb2hsl rgbhsl
			rgbhsl[0][0][1] = min(255,round(pieInfo.saturation / 100 * rgbhsl[0][0][1]))
			rgbhsl[0][0][2] = min(255,round(pieInfo.lightness/ 100 * rgbhsl[0][0][2]))
			ImageTransform/O hsl2rgb rgbhsl
			red= rgbhsl[0][0][0]
			green= rgbhsl[0][0][1]
			blue= rgbhsl[0][0][2]
		endif
		
		SetDrawEnv/W=$win xcoord= prel,ycoord= prel
		SetDrawEnv/W=$win linefgc= (pieInfo.strokeRed, pieInfo.strokeGreen, pieInfo.strokeBlue),linethick= pieInfo.stroke

		Variable fillPat= WMPiePatternForWedge(win, i, pieInfo)//pieInfo.fillPatterns.fillpat[i]
		SetDrawEnv/W=$win fillfgc= (red, green, blue), fillPat=fillPat, fillbgc=(pieInfo.patBkRed, pieInfo.patBkGreen,pieInfo.patBkBlue)

		// Draw the polygon
		StartAngle = 2*pi*FracWave[i]
		EndAngle = 2*pi*FracWave[i+1]
		if( !pieInfo.nextClockwise )	// if (ccw)
			StartAngle = -StartAngle
			EndAngle= -EndAngle
		endif
		
		StartAngle += angle0
		EndAngle += angle0
		n= ceil(max(1,abs(EndAngle-StartAngle)*(500/pi)))
		
		// first point on the outer arc
		x0= radius*cos(StartAngle)
		y0= radius*sin(StartAngle)
		
		// first point on any inner arc, usually 0,0
		xi = innerRadius*cos(StartAngle)
		yi = innerRadius*sin(StartAngle)
	
		xOrigin= pieInfo.wedgesX0
		yOrigin= pieInfo.wedgesY0
		if( explodeWedgesDistance )
			explodeAngle = (EndAngle+StartAngle)/2
			xOrigin += explodeWedgesDistance*cos(explodeAngle)
			yOrigin += explodeWedgesDistance*sin(explodeAngle)
		endif
	
		Variable epsilon = pi/720	// within 0.25 degrees
		Variable isFullCircle = (numWedges == 1) && (abs(EndAngle-StartAngle) >= (2*pi-epsilon))
		if( isFullCircle )
			Variable left= pieInfo.wedgesX0 - radius
			Variable right= pieInfo.wedgesX0 + radius
			Variable top= pieInfo.wedgesY0 - radius
			Variable bottom= pieInfo.wedgesY0 + radius
			DrawOval/W=$win left, top, right, bottom
			if( innerRadius != 0 )
				// Fake a ring by overlaying a smaller circle drawn with the background color.
				// This technique doesn't support Tinted background; that will require Igor 9.
				left= pieInfo.wedgesX0 - innerRadius
				right= pieInfo.wedgesX0 + innerRadius
				top= pieInfo.wedgesY0 - innerRadius
				bottom= pieInfo.wedgesY0 + innerRadius
				SetDrawEnv/W=$win push
				SetDrawEnv/W=$win fillpat=-1, fillfgc= (pieInfo.bkgRed, pieInfo.bkgGreen, pieInfo.bkgBlue)
				SetDrawEnv/W=$win linefgc= (pieInfo.strokeRed, pieInfo.strokeGreen, pieInfo.strokeBlue),linethick= pieInfo.stroke
				DrawOval/W=$win left, top, right, bottom
				SetDrawEnv/W=$win pop
			endif
		elseif( innerRadius == 0 )
			DrawPoly/W=$win/ABS xOrigin, yOrigin,1,1,{0,0,x0,y0}		// first and second points
			for(j=1; j<=n; j+=1)
				angle = startAngle + j * (EndAngle-StartAngle) / n
				x0= radius*cos(angle)
				y0= radius*sin(angle)
				DrawPoly/W=$win /A {x0,y0}
			endfor
			DrawPoly/W=$win/A {0,0}
		else // ring segment, possibly exploded.
			DrawPoly/W=$win/ABS xOrigin, yOrigin,1,1,{xi,yi,x0,y0}		// first and second points
			for(j=1; j<=n; j+=1)
				angle = startAngle + j * (EndAngle-StartAngle) / n
				x0= radius*cos(angle)
				y0= radius*sin(angle)
				DrawPoly/W=$win /A {x0,y0}
			endfor
			x0 = innerRadius*cos(angle)
			y0 = innerRadius*sin(angle)
			DrawPoly/W=$win/A {x0,y0}
			// draw the remainder of the inner radius
			for(j=1; j<=n; j+=1)
				angle = EndAngle - j * (EndAngle-StartAngle) / n
				x0= innerRadius*cos(angle)
				y0= innerRadius*sin(angle)
				DrawPoly/W=$win /A {x0,y0}
			endfor
		endif
		i += 1
	while (i < NumWedges)
	
	// SPECIAL VERSION 5: optional outlining of one group of sequential wedges.
	if( pieInfo.outlineWedgesThickness && pieInfo.outlineNumWedges >= 1 )
		isFullCircle = (pieInfo.outlineNumWedges >= numWedges) && (abs(FracWave[pieInfo.outlineNumWedges]-FracWave[0]) >= 0.99)
		if( isFullCircle )
			left= pieInfo.wedgesX0 - radius
			right= pieInfo.wedgesX0 + radius
			top= pieInfo.wedgesY0 - radius
			bottom= pieInfo.wedgesY0 + radius
			SetDrawEnv/W=$win xcoord= prel,ycoord= prel
			SetDrawEnv/W=$win fillpat=0, linefgc= (pieInfo.outlineWedgesRed, pieInfo.outlineWedgesGreen, pieInfo.outlineWedgesBlue),linethick= pieInfo.outlineWedgesThickness
			DrawOval/W=$win left, top, right, bottom
			if( innerRadius && (pieInfo.outlineHideSpokes==0) )
				left= pieInfo.wedgesX0 - innerRadius
				right= pieInfo.wedgesX0 + innerRadius
				top= pieInfo.wedgesY0 - innerRadius
				bottom= pieInfo.wedgesY0 + innerRadius
				SetDrawEnv/W=$win fillpat=0, linefgc= (pieInfo.outlineWedgesRed, pieInfo.outlineWedgesGreen, pieInfo.outlineWedgesBlue),linethick= pieInfo.outlineWedgesThickness
				DrawOval/W=$win left, top, right, bottom
			endif
		else
			Variable outlineNumWedges= limit(pieInfo.outlineNumWedges,1,NumWedges)
			Variable isFirst = 1, isLast= 0
			i = pieInfo.outlineWedgesFirst-1		// user enters 1-based index
			do
				SetDrawEnv/W=$win xcoord= prel,ycoord= prel
				SetDrawEnv/W=$win fillpat=0, linefgc= (pieInfo.outlineWedgesRed, pieInfo.outlineWedgesGreen, pieInfo.outlineWedgesBlue),linethick= pieInfo.outlineWedgesThickness, save
		
				StartAngle = 2*pi*FracWave[i]
				EndAngle = 2*pi*FracWave[i+1]
				if( !pieInfo.nextClockwise )	// if (ccw)
					StartAngle = -StartAngle
					EndAngle= -EndAngle
				endif
				
				StartAngle += angle0
				EndAngle += angle0
				
				// first point on the outer arc
				x0= radius*cos(StartAngle)
				y0= radius*sin(StartAngle)

				// first point on any inner arc, usually 0,0
				xi = innerRadius*cos(StartAngle)
				yi = innerRadius*sin(StartAngle)
				
				// compute the (possibly exploded) origin
				xOrigin= pieInfo.wedgesX0
				yOrigin= pieInfo.wedgesY0
				if( explodeWedgesDistance )
					explodeAngle = (EndAngle+StartAngle)/2
					xOrigin += explodeWedgesDistance*cos(explodeAngle)
					yOrigin += explodeWedgesDistance*sin(explodeAngle)
				endif
				
				// Draw the polygon
				if( isFirst==1 && (pieInfo.outlineHideSpokes==0) )
					if( innerRadius == 0 )
						DrawPoly/W=$win xOrigin, yOrigin,1,1,{0,0,x0,y0}		// first and second points
					else
						DrawPoly/W=$win/ABS xOrigin, yOrigin,1,1,{xi,yi,x0,y0}		// first and second points
					endif
				else
					DrawPoly/W=$win/ABS xOrigin, yOrigin,1,1,{x0,y0}		// first point
				endif
				n= ceil(max(1,abs(EndAngle-StartAngle)*(500/pi)))
				for(j=1; j<=n; j+=1)
					angle = startAngle + j * (EndAngle-StartAngle) / n
					x0= radius*cos(angle)
					y0= radius*sin(angle)
					DrawPoly/W=$win /A {x0,y0}
				endfor
				isLast = outlineNumWedges == 1
				if( isLast && (pieInfo.outlineHideSpokes == 0) )
					xi = innerRadius*cos(angle)
					yi = innerRadius*sin(angle)
					DrawPoly/W=$win/A {xi,yi}
				endif
				if(explodeWedgesDistance)
					isFirst = 2
				else
					isFirst = 0
				endif
				i += 1
				if( i>=NumWedges )	// wrap the angles around.
					i= 0
				endif
				outlineNumWedges -= 1
			while(outlineNumWedges > 0)
			
			// Version 8 innerRadius and explodeWedgesDistance
			if( innerRadius != 0 && (pieInfo.outlineHideSpokes==0) )
				// draw the wedge inside outlines in reverse wedge order
				outlineNumWedges= limit(pieInfo.outlineNumWedges,1,NumWedges)
				i = pieInfo.outlineWedgesFirst+outlineNumWedges-1
				if( i>=NumWedges )
					i-= NumWedges
				endif
				isFirst = 1
				do
					Variable prev= i-1
					if( prev < 0 )
						prev= NumWedges
					endif
					StartAngle = 2*pi*FracWave[i]
					EndAngle = 2*pi*FracWave[prev]
					if( !pieInfo.nextClockwise )	// if (ccw)
						StartAngle = -StartAngle
						EndAngle= -EndAngle
					endif
					
					// compute the (possibly exploded) origin
					xOrigin= pieInfo.wedgesX0
					yOrigin= pieInfo.wedgesY0
					if( explodeWedgesDistance )
						explodeAngle = (EndAngle+StartAngle)/2
						xOrigin += explodeWedgesDistance*cos(explodeAngle)
						yOrigin += explodeWedgesDistance*sin(explodeAngle)
					endif

					// Draw  polygon, drawing from EndAngle to StartAngle, returning to the spoke's inner point
					// first point on any inner arc, usually 0,0
					if( isFirst )
						xi = innerRadius*cos(StartAngle)
						yi = innerRadius*sin(StartAngle)
						DrawPoly/W=$win/ABS xOrigin, yOrigin,1,1,{xi,yi}		// first point
					endif
					for(j=1; j<=n; j+=1)
						angle = StartAngle + j * (EndAngle-StartAngle) / n
						xi = innerRadius*cos(angle)
						yi = innerRadius*sin(angle)
						DrawPoly/W=$win/A {xi,yi}
					endfor
					if(explodeWedgesDistance)
						isFirst = 1
					else
						isFirst = 0
					endif
					i -= 1
					if( i<=0 )	// wrap the angles around.
						i= NumWedges
						if( pieInfo.wedgesTotalPct != 100 && !isFirst )
							DrawPoly/W=$win/A {NaN,NaN}
						endif
					endif
					outlineNumWedges -= 1
				while(outlineNumWedges > 0)
			endif
		endif
	endif
	
	// Draw the labels afterwards to prevent them from being obscured by nearby wedges
	// Version 8: labelAngle
	Variable labelAngle = str2num(pieInfo.labelRotation) // had always been 0 until Version 8, one of "0;90;180;270;Radial;Tangent;"
	Variable labelAngleRadial = CmpStr(pieInfo.labelRotation,"Radial") == 0
	Variable labelAngleTangent = CmpStr(pieInfo.labelRotation,"Tangent") == 0
	String text=""
	String command
	for(i=0; i<NumWedges;i+=1)
		StartAngle = 2*pi*FracWave[i]
		EndAngle = 2*pi*FracWave[i+1]
		if( !pieInfo.nextClockwise )	// if (ccw)
			StartAngle = -StartAngle
			EndAngle= -EndAngle
		endif
		StartAngle += angle0
		EndAngle += angle0
		
		// compute or get the label (if any)
		switch( pieInfo.labelType )
			default:
			case kPieLabelNone:
				break
			case kPieLabelWave:
				if( WaveExists(LabelWave) )
					if( i < DimSize(LabelWave,0) )
						text= LabelWave[i]
					else
						text=""
					endif
				endif
				break
			case kPieLabelValue:
				text= num2str(DataWave[i])
				break
			case kPieLabelPercent:
				sprintf text, "%d%%", round((FracWave[i+1] - FracWave[i]) * 100)
				break
			case kPieLabelPercentTenths:
				sprintf text, "%.1f%%", (FracWave[i+1] - FracWave[i]) * 100
				break
		endswitch

		String anno="pie"+num2istr(i)
		
		if( strlen(text) )
			// draw the label
			Variable centerAngle= (StartAngle + EndAngle)/2 	// already in radians
			Variable labelRadius = pieInfo.labelRadius+ explodeWedgesDistance
			x0= pieInfo.wedgesX0+labelRadius*cos(centerAngle)
			y0= pieInfo.wedgesY0+labelRadius*sin(centerAngle)
			
			// labelAngle = str2num(pieInfo.labelRotation) // had always been 0 until Version 8, now one of "0;45;90-45;-90;Radial;Tangent;"
			if( labelAngleRadial || labelAngleTangent)
				labelAngle= centerAngle;
				if( labelAngleTangent )
					labelAngle += pi/2;
				endif
				labelAngle *= -180/pi // commands use degrees, y is inverted
				if( labelAngle > 180 )
					labelAngle -= 360
				elseif( labelAngle < -180 )
					labelAngle += 360
				endif
				if( labelAngle > 90 )
					labelAngle -= 180
				elseif( labelAngle < -90 )
					labelAngle += 180
				endif
			endif

			if( kUseDrawText )
				SetDrawEnv/W=$win xcoord= prel,ycoord= prel
				SetDrawEnv/W=$win textxjust=1,textyjust=1, textrgb=(pieInfo.labelRed, pieInfo.labelGreen, pieInfo.labelBlue)
				if( CmpStr(pieInfo.fontName,"default") != 0 )
					sprintf command, "SetDrawEnv/W=%s fname=\"%s\"", win, pieInfo.fontName
					Execute command
				endif
				if( pieInfo.fontSize > 0 )
					SetDrawEnv/W=$win fsize= pieInfo.fontSize
				endif
				SetDrawEnv/W=$win textrot=labelAngle
				DrawText/W=$win x0, y0, text
			else
				if( CmpStr(pieInfo.fontName,"default") != 0 )
					text= "\\F'" + pieInfo.fontName + "'"+text
				endif
				if( pieInfo.fontSize > 0 )
					String fSize
					sprintf fSize, "\\Z%02d", pieInfo.fontSize
					text= fSize+text
				endif
				x0 = (x0-0.5) * 100
				y0 = -(y0-0.5) * 100
				TextBox/W=$win/O=(labelAngle)/C/N=$anno/A=MC/X=(x0)/Y=(y0)/F=0/B=1/G=(pieInfo.labelRed, pieInfo.labelGreen, pieInfo.labelBlue) text
			endif
		else	// 6.03: remove annotation
			if( !kUseDrawText )
				TextBox/W=$win/K/N=$anno
			endif
		endif
	endfor

	// Clean up
	if( kUseDrawText )
		ShowTools/W=$win/A arrow			// make it easy for the user to edit the result
	else
		GraphNormal/W=$win
		i= NumWedges
		String annotations= AnnotationList(win)
		do
			String name="pie"+num2istr(i)
			if( FindListItem(name, annotations) < 0 )
				break
			endif
			TextBox/W=$win/K/N=$name
			i+= 1
		while(1)
	endif
	KillWaves/Z FracWave, rgbhsl
	SetDataFolder df
End

// Public interface
Function New2DPieChart()
	InitPieChartGraph()
	ShowPieChartPanel()
End

Static Function/S InitPieChartGraph([win])
	String win	// optional. If missing a new window is created
	
	if( ParamIsDefault(win) || (Wintype(win) != 1) )
		Display/W=(5,44,295,298)
		win= S_Name
		DoWindow/T $win  win+" (Pie Chart)"
	endif
	if( kUseDrawText )
		ShowTools/W=$win/A
	endif
	DoUpdate	// for aspect to take affect
	MaintainAspectUsingMargins(win)

	STRUCT PieChartInfo pieInfo
	DefaultPieStruct(pieInfo)
	SetPieStruct(win,pieInfo)	// makes this a 2D pie chart graph

	return win
End

// Existing panels might need to be updated
static Function PanelIsOutdated()

	// WARNING: A programmer might forget to update this routine, which can
	// cause endless recursion if the control referenced below is not created by ShowPieChartPanel()

	// check for existence of latest control
	ControlInfo/W=PieChartPanel patternHint
	Variable isOutdated= V_Flag == 0	// true if control doesn't exist

	return isOutdated
End

Function/S ShowPieChartPanel()
	DoWindow/F PieChartPanel
	if(V_Flag==0 || PanelIsOutdated() )
		DoWindow/K PieChartPanel	// in case it is outdated.
		
		NewPanel /K=1 /W=(138,73,569,644) /N=PieChartPanel as "2D Pie Chart"
		ModifyPanel fixedSize=1, noEdit=1
		DefaultGuiFont/W=PieChartPanel,popup={"_IgorSmall",0,0}

		// create the controls

		// Numeric Data
		TitleBox numericTitle,pos={54,9},size={65,13},title="Numeric Data",frame=0

		ListBox numericData,pos={3,35},size={194,213}
		String listOptions= "TEXT:0,CMPLX:0,DIMS:1,MAXROWS:200"	// see WaveList
		MakeListIntoWaveSelector("PieChartPanel", "numericData", content= WMWS_Waves, selectionMode= WMWS_SelectionSingle, listOptions=listOptions)
		WS_SetNotificationProc("PieChartPanel", "numericData", "WMPieChart#WS_DataNotificationProc")
		
		// Labels
		GroupBox labelGroup,pos={205,17},size={219,233}
		
#if IgorVersion()>=7
		// Background rectangle to hide the groupbox line under the Labels checkbox
		// because Igor 7 does not erase behind the checkbox
		ControlInfo/W=PieChartPanel kwBackgroundColor // sets V_Red, V_Green, V_Blue
		String blanks="                 " // perhaps different lengths depending on OS
		TitleBox blank,pos={219,10},size={45.00,15.00},title=blanks
		TitleBox blank,frame=0,labelBack=(V_Red, V_Green, V_Blue),fColor=(V_Red, V_Green, V_Blue)
#endif
		CheckBox labelsCheck,pos={219,10},size={52,14},proc=WMPieChart#LabelsRadioProc,title="Labels "

		CheckBox labelsTextRadio,pos={213,51},size={73,14},proc=WMPieChart#LabelsRadioProc,title="Text Labels"
		CheckBox labelsTextRadio,value= 0,mode=1

		ListBox textData,pos={222,70},size={194,107}
		listOptions= "TEXT:1,CMPLX:0,DIMS:1,MAXROWS:200"	// see WaveList
		MakeListIntoWaveSelector("PieChartPanel", "textData", content= WMWS_Waves, selectionMode= WMWS_SelectionSingle, listOptions=listOptions)
		WS_SetNotificationProc("PieChartPanel", "textData", "WMPieChart#WS_TextNotificationProc")

		CheckBox labelsValueRadio,pos={213,31},size={87,14},proc=WMPieChart#LabelsRadioProc,title="Numeric Value"
		CheckBox labelsValueRadio,value= 0,mode=1
	
		CheckBox labelsPercentRadio,pos={316,31},size={26,14},proc=WMPieChart#LabelsRadioProc,title="%"
		CheckBox labelsPercentRadio,value= 1,mode=1
	
		CheckBox labelsTenthsRadio,pos={316,51},size={84,14},proc=WMPieChart#LabelsRadioProc,title="% with Tenths"
		CheckBox labelsTenthsRadio,value= 0,mode=1

		Variable/G $ChartDFVar("labelRadius")	// set in UpdatePieChartPanel()
		SetVariable labelRadius,pos={301,184},size={116,16},proc=WMPieChart#PieLabelRadiusSetVarProc,title="Label Radius"
		SetVariable labelRadius,limits={0.01,1,0.01},value= $ChartDFVar("labelRadius"),bodyWidth= 50

		PopupMenu labelFont,pos={218,205},size={85,21},title="Font",proc=WMPieChart#PieLabelFontPopMenuProc
		PopupMenu labelFont,mode=1,popvalue="default",value= #"\"default;\"+FontList(\";\")"

	// Version 8 interface
		PopupMenu labelRotation,pos={330,226},title="Rotation",proc=WMPieChart#PieLabelRotationProc
		PopupMenu labelRotation,mode=1,popvalue="0",value= #"\"0;45;90;-45;-90;Radial;Tangent;\""

		SetVariable labelFontSize,pos={218,226},size={98,16},title="Font Size",proc=WMPieChart#PieLabelFontSizeSetVarProc
		SetVariable labelFontSize,limits={3,400,1},value= $ChartDFVar("fontSize"),bodyWidth= 50
		
		PopupMenu labelColor,pos={214,184},size={77,21},proc=WMPieChart#PieLabelColorPopMenuProc,title="Color"
		PopupMenu labelColor,mode=1,popColor= (0,0,0),value= #"\"*COLORPOP*\""

		// Background
		GroupBox backgroundGroup,pos={4,255},size={420,46},title="Background"

		PopupMenu backgroundColorPop,pos={23,276},size={105,21},proc=WMPieChart#BkgColorPopMenuProc,title="Fixed Color"
		PopupMenu backgroundColorPop,mode=1,popColor= (65535,65535,65535),value= #"\"*COLORPOP*\""

		Button tintedBackground,pos={178,274},size={220,20},proc=WMPieChart#TintedBackgroundButtonProc,title="Tinted/Gradient Background..."
		
		// Wedges
		GroupBox wedgeGroup,pos={4,307},size={419,223},title="Wedges"

		Variable/G $ChartDFVar("wedgesTotalPct")	// set in UpdatePieChartPanel()
		SetVariable totalPct,pos={18,329},size={128,16},proc=WMPieChart#PieTotalPctSetVarProc,title="Wedges Total (%)"
		SetVariable totalPct,limits={1,100,0},value= $ChartDFVar("wedgesTotalPct"),bodyWidth= 40

// Version 4 interface	
//		CheckBox stroke,pos={174,324},size={16,14},proc=WMPieChart#PieStrokeCheckProc,title=""
//		CheckBox stroke,value= 0

// Version 5 interface
		SetVariable stroke,pos={153,329},size={80,16},bodyWidth=45,proc=WMPieChart#PieStrokeSetVarProc,title="Stroke"
		SetVariable stroke,limits={0,10,1},value= $ChartDFVar("stroke")

		PopupMenu strokeColorPop,pos={242,328},size={50,21},proc=WMPieChart#StrokeColorPopMenuProc
		PopupMenu strokeColorPop,mode=1,popColor= (0,0,0),value= #"\"*COLORPOP*\""

		Variable/G $ChartDFVar("wedgesRadius")	// set in UpdatePieChartPanel()
		SetVariable pieRadius,pos={313,324},size={102,14},proc=WMPieChart#PieWedgesRadiusSetVarProc,title=" Pie Radius"
		SetVariable pieRadius,limits={0.01,1,0.01},value= $ChartDFVar("wedgesRadius"),bodyWidth= 50

// Version 8 interface
		Variable/G $ChartDFVar("wedgesInnerRadius")	// set in UpdatePieChartPanel()
		SetVariable pieInnerRadius,pos={306,342},size={109,14},proc=WMPieChart#PieWedgesInnerRadiusSetVarProc,title="Inner Radius"
		SetVariable pieInnerRadius,limits={0.00,0.99,0.01},value= $ChartDFVar("wedgesInnerRadius"),bodyWidth= 50

		Variable/G $ChartDFVar("explodeWedgesDistance")	// set in UpdatePieChartPanel()
		SetVariable pieExplode,pos={312.00,358.00},size={103.00,14.00},proc=WMPieChart#PieWedgesExplodeSetVarProc,title="Explode by"
		SetVariable pieExplode,limits={0,0.99,0.01},value= $ChartDFVar("explodeWedgesDistance"),bodyWidth= 50

		PopupMenu angle0,pos={23,355},size={126,21},proc=WMPieChart#PieAngle0PopMenuProc,title="First Wedge at"
		PopupMenu angle0,mode=1,popvalue="Right",value= #"\"Right;Bottom;Left;Top;\""

		CheckBox clockwise,pos={174,357},size={129,14},proc=WMPieChart#PieClockwiseCheckProc,title="Next Wedge CW"
		CheckBox clockwise,value=0

		Variable/G $ChartDFVar("wedgesX0")	// set in UpdatePieChartPanel()
		SetVariable centerX0,pos={21,385},size={101,16},proc=WMPieChart#PieCenterSetVarProc,title="Center X0"
		SetVariable centerX0,limits={0.01,1,0.01},value= $ChartDFVar("wedgesX0"),bodyWidth= 50
	
		Variable/G $ChartDFVar("wedgesY0")	// set in UpdatePieChartPanel()
		SetVariable centerY0,pos={174,385},size={101,16},proc=WMPieChart#PieCenterSetVarProc,title="Center Y0"
		SetVariable centerY0,limits={0.01,1,0.01},value=$ChartDFVar("wedgesY0"),bodyWidth= 50

		SetVariable lightness,pos={316,379},size={99,16},proc=WMPieChart#LightnessSetVarProc,title="Lightness"
		SetVariable lightness,limits={5,200,5},value=$ChartDFVar("lightness"),bodyWidth= 50
	
		SetVariable saturation,pos={313,396},size={102,16},proc=WMPieChart#SaturationSetVarProc,title="Saturation"
		SetVariable saturation,limits={0,200,5},value=$ChartDFVar("saturation"),bodyWidth= 50

		// Version 4 controls:
		CheckBox autoColors,pos={25,419},size={97,14},proc=WMPieChart#WedgeColorsCheckProc,title="Automatic Colors"
		CheckBox autoColors,value= 1,mode=1

		CheckBox customColors,pos={158,419},size={85,14},proc=WMPieChart#WedgeColorsCheckProc,title="Custom Colors"
		CheckBox customColors,value= 0,mode=1

		Button editCustomColors,pos={260,418},size={154,20},proc=WMPieChart#EditCustomColorsButtonProc,title="Edit Custom Colors..."

		Button outline,pos={260,442},size={154,20},proc=WMPieChart#OutlineButtonProc,title="Outline..."

// Version 6 interface
		// monochrome color
		CheckBox allWedgesOneColor,pos={25,445},size={94,14},proc=WMPieChart#WedgeColorsCheckProc,title="One Color for All"
		CheckBox allWedgesOneColor,value= 0,mode=1
	
		PopupMenu oneColor,pos={158,442},size={50,21}, proc=WMPieChart#AllWedgesPopMenuProc
		PopupMenu oneColor,mode=1,popColor= (0,0,0),value= #"\"*COLORPOP*\""
	
		// patterns
		Button autoPatterns,pos={25,473},size={130,20},proc=WMPieChart#AutomaticPatterns,title="Automatic Patterns"

		PopupMenu pattern,pos={171,473},size={139,21},proc=WMPieChart#PatternPopMenuProc,title="One Pattern for All "
		PopupMenu pattern,mode=1,value= #"\"*PATTERNPOP*\""
	
		PopupMenu solidPattern,pos={320,473},size={52,21},proc=WMPieChart#PatternPopMenuProc
		PopupMenu solidPattern,mode=1,popvalue="Solid",value= #"\"Solid;Dark Gray;Gray;Light Gray;\""

		PopupMenu patBkColor,pos={25,500},size={148,21},proc=WMPieChart#PatBkgPopMenuProc,title="Pattern Background"
		PopupMenu patBkColor,mode=1,popColor= (65535,65535,65535),value= #"\"*COLORPOP*\""

		// !!!!!!!!!!!!!! WARNING !!!!!!!!!!!!!! 
		// DO NOT OMIT patternHint CONTROL UNLESS YOU ALSO CHANGE THE PanelIsOutdated() routine!
		// !!!!!!!!!!!!!! WARNING !!!!!!!!!!!!!! 
		TitleBox patternHint,pos={192,505},size={224,13},title="\\K(0,12800,52224)Hint: right-click wedge to modify pattern or color"
		TitleBox patternHint,fSize=9,frame=0

// Version 1 interface

		// DelayUpdates & Help
		CheckBox delayUpdates,pos={51,541},size={138,14},proc=WMPieChart#DelayUpdatesCheckProc,title="Delay Automatic Updates"
		
		Button help,pos={288,540},size={50,20},proc=WMPieChart#HelpButtonProc,title="Help"

		SetWindow PieChartPanel hook=WMPieChart#PieChartPanelHook	// now activate events will call UpdatePieChartPanel

		UpdatePieChartPanel()	// we're already activated, update for the top chart manually. If no 2D pie chart, the controls will be disabled there

		String win= TopPieChart()
		if( strlen(win) )
			AutoPositionWindow/M=0/R=$win PieChartPanel
		endif
	endif
End

Static Function EnableDisableTextWaveList(disable)
	Variable disable	// boolean
	
	if( disable )
		ControlInfo/W=PieChartPanel textData	// get V_Height, V_Width, V_top, V_left
		ListBox textData win=PieChartPanel, disable=1 // list boxes don't disable well (they show "E1"), so just hide it.
		GroupBox disabledTextData,win=PieChartPanel,pos={V_left,V_top},size={V_Width,V_Height},frame=0
	else
		KillControl/W=PieChartPanel disabledTextData
		ListBox textData win=PieChartPanel, disable=0
	endif
End

Static Function UpdatePieChartPanel()

	DoWindow PieChartPanel
	if( V_Flag == 0 )
		return 0
	endif
	
	String win= TopPieChart()
	String allControls= ControlNameList("PieChartPanel", ";", "*")

	if( strlen(win) == 0 || !GraphIsDisplayingNumericData(win) )
		// no 2d pie chart graph: disable all controls EXCEPT numeric data
		allControls= RemoveFromList("numericData;help;textData;", allControls)
		ModifyControlList/Z allControls, win=PieChartPanel, disable=2
		
		// Numeric Data
		ShowHint("Select Numeric Data to start.")
		
		// Labels
		EnableDisableTextWaveList(1)

		Checkbox labelsCheck,win=PieChartPanel, value=0
		CheckBox labelsTextRadio,win=PieChartPanel, value=0
		CheckBox labelsValueRadio,win=PieChartPanel, value=0
		CheckBox labelsPercentRadio,win=PieChartPanel, value=0
		CheckBox labelsTenthsRadio,win=PieChartPanel, value=0
		
		Variable/G $ChartDFVar("zero")= 0
		SetVariable labelRadius,win=PieChartPanel, value= $ChartDFVar("zero")

		SetVariable labelFontSize,win=PieChartPanel, value= $ChartDFVar("zero")
		
		// Background
		PopupMenu backgroundColorPop,win=PieChartPanel,popColor= (65535,65535,65535)
		
		// Wedges
		SetVariable totalPct,win=PieChartPanel, value= $ChartDFVar("zero")
		
		SetVariable stroke,win=PieChartPanel, value= $ChartDFVar("zero")

		SetVariable pieRadius,win=PieChartPanel, value= $ChartDFVar("zero")
		SetVariable pieInnerRadius,win=PieChartPanel, value= $ChartDFVar("zero")
		SetVariable pieExplode,win=PieChartPanel, value= $ChartDFVar("zero")

		CheckBox clockwise,win=PieChartPanel, value=0
		SetVariable centerX0,win=PieChartPanel, value= $ChartDFVar("zero")
		SetVariable centerY0,win=PieChartPanel, value= $ChartDFVar("zero")
		SetVariable lightness,win=PieChartPanel, value= $ChartDFVar("zero")
		SetVariable saturation,win=PieChartPanel, value= $ChartDFVar("zero")
	else

		String labelTypeControls="labelsTextRadio;labelsValueRadio;labelsPercentRadio;labelsTenthsRadio;labelRadius;"	// see SetLabelsRadios
		allControls= RemoveFromList(labelTypeControls, allControls)	// avoid flashing that would occur if enabled and then disabled again.
		ModifyControlList/Z allControls, win=PieChartPanel, disable=0

		ShowHint("")

		// Transfer pieInfo to the controls and the globals they control
		// Assign defaults to any unset/invalid pieInfo members.
		STRUCT PieChartInfo pieInfo
		GetPieStruct(win, pieInfo)
	
		// Numeric Data
		//String path= pieInfo.dataWaveFolder + pieInfo.dataWaveName
		String path= pieInfo.dataWaveFolder + PossiblyQuoteName(pieInfo.dataWaveName)		// 6.382
		WAVE/Z dw= $path
		if( !WaveExists(dw) )
			String waves= WaveList("*",";","DIMS:1,TEXT:0")+"_none_;"	// waves in current data folder
			WAVE/Z dw= $StringFromList(0,waves)	// first in list
			if( WaveExists(dw) )
				path= GetWavesDataFolder(dw,2)	// full path
				pieInfo.dataWaveFolder= GetWavesDataFolder(dw,1)
				pieInfo.dataWaveName= NameOfWave(dw)
			else
				path=""
				pieInfo.dataWaveFolder=""
				pieInfo.dataWaveName=""
			endif
		endif
		WS_ClearSelection("PieChartPanel", "numericData")
		WS_SelectObjectList("PieChartPanel", "numericData", path, OpenFoldersAsNeeded=1)

		// Labels
		SetLabelsRadios(pieInfo.labelType)	// could disable controls that were enabled by allControls

		//path= pieInfo.labelWaveFolder + pieInfo.labelWaveName
		path= pieInfo.labelWaveFolder + PossiblyQuoteName(pieInfo.labelWaveName)	// 6.382
		WAVE/Z tw= $path
		if( !WaveExists(tw) )
			waves= TextWaveList()	// text waves in current data folder
			WAVE/Z tw= $StringFromList(0,waves)
			if( WaveExists(tw) )
				path= GetWavesDataFolder(tw,2)	// full path
				pieInfo.labelWaveFolder= GetWavesDataFolder(tw,1)
				pieInfo.labelWaveName= NameOfWave(tw)
			else
				path=""
				pieInfo.labelWaveFolder=""
				pieInfo.labelWaveName=""
			endif
		endif
		WS_ClearSelection("PieChartPanel", "textData")
		WS_SelectObjectList("PieChartPanel", "textData", path, OpenFoldersAsNeeded=1)
		
		Variable/G $ChartDFVar("labelRadius")	= pieInfo.labelRadius
		SetVariable labelRadius,win=PieChartPanel, value= $ChartDFVar("labelRadius")
		
		Variable/G $ChartDFVar("wedgesInnerRadius")	= pieInfo.wedgesInnerRadius
		SetVariable pieInnerRadius,win=PieChartPanel, value= $ChartDFVar("wedgesInnerRadius")
		
		Variable/G $ChartDFVar("explodeWedgesDistance")	= pieInfo.explodeWedgesDistance
		SetVariable pieExplode,win=PieChartPanel, value= $ChartDFVar("explodeWedgesDistance")
		
		String fonts= "default;"+FontList(";")
		Variable mode= 1 + max(0,WhichListItem(pieInfo.fontName, fonts))
		String str= StringFromList(mode-1, fonts)
		PopupMenu labelFont,win=PieChartPanel,mode=mode,popvalue=str

		String rotations="0;45;90;-45;-90;Radial;Tangent;"
		mode= 1 + max(0,WhichListItem(pieInfo.labelRotation, rotations))
		str= StringFromList(mode-1, rotations)
		PopupMenu labelRotation,win=PieChartPanel,mode=mode,popvalue=str

		Variable/G $ChartDFVar("fontSize") = pieInfo.fontSize
		SetVariable labelFontSize,win=PieChartPanel,value= $ChartDFVar("fontSize")
		
		PopupMenu labelColor,win=PieChartPanel,popColor= (pieInfo.labelRed,pieInfo.labelGreen,pieInfo.labelBlue)
	
		// Background
		PopupMenu backgroundColorPop,win=PieChartPanel,popColor= (pieInfo.bkgRed,pieInfo.bkgGreen,pieInfo.bkgBlue)
		
		// Wedges
		Variable/G $ChartDFVar("wedgesTotalPct") = pieInfo.wedgesTotalPct
		SetVariable totalPct,win=PieChartPanel, value= $ChartDFVar("wedgesTotalPct")
		
		ControlInfo/W=PieChartPanel stroke
		if( abs(V_Flag) == 2 )
			// Version 4 interface
			CheckBox stroke,win=PieChartPanel, value=pieInfo.stroke
		else
			// Version 5 interface
			Variable/G $ChartDFVar("stroke") = pieInfo.stroke
			SetVariable stroke,win=PieChartPanel, value= $ChartDFVar("stroke")
		endif

		PopupMenu strokeColorPop,win=PieChartPanel,popColor= (pieInfo.strokeRed,pieInfo.strokeGreen,pieInfo.strokeBlue)

		Variable/G $ChartDFVar("wedgesRadius") = pieInfo.wedgesRadius
		SetVariable pieRadius,win=PieChartPanel, value= $ChartDFVar("wedgesRadius")
		
		mode= 1 + round(pieInfo.angle0Degrees/90)
		str= StringFromList(mode-1, "Right;Bottom;Left;Top;")
		PopupMenu angle0,win=PieChartPanel,mode=mode,popvalue=str
	
		CheckBox clockwise,win=PieChartPanel, value= pieInfo.nextClockwise

		Variable/G $ChartDFVar("wedgesX0")= pieInfo.wedgesX0
		SetVariable centerX0,win=PieChartPanel, value= $ChartDFVar("wedgesX0")

		Variable/G $ChartDFVar("wedgesY0")= pieInfo.wedgesY0
		SetVariable centerY0,win=PieChartPanel, value= $ChartDFVar("wedgesY0")

		Variable/G $ChartDFVar("lightness")= pieInfo.lightness
		SetVariable lightness,win=PieChartPanel, value= $ChartDFVar("lightness")

		Variable/G $ChartDFVar("saturation")= pieInfo.saturation
		SetVariable saturation,win=PieChartPanel, value= $ChartDFVar("saturation")
	
		// Version 4 Auto vs Custom Colors
		Variable checked= !pieInfo.useCustomColors && !pieInfo.useAllWedgesColor
		CheckBox autoColors,win=PieChartPanel, value= checked
		CheckBox customColors,win=PieChartPanel, value= pieInfo.useCustomColors

		// Version 6
		// Monochrome wedge colors
		CheckBox allWedgesOneColor,win=PieChartPanel,value=pieInfo.useAllWedgesColor
		PopupMenu oneColor,win=PieChartPanel,popColor= (pieInfo.allWedgesRed,pieInfo.allWedgesGreen,pieInfo.allWedgesBlue)
	
		// patterns
		Variable fillPat= pieInfo.fillPatterns.fillpat[0]
		// set pattern popup to first pattern if it is in the range of 5..., else to first item.
		// For a pattern pop-up, the mode value is the SetDrawEnv fillPat number minus 4,
		// so mode=1 corresponds to fillpat=5, the SW-NE lines fill pattern.
		mode= 1
		if( fillPat >= 5 )
			mode= fillPat-4	// first item is fillPat 5
		endif
		PopupMenu pattern,win=PieChartPanel,mode=mode
		
		PopupMenu patBkColor,win=PieChartPanel,popColor= (pieInfo.patBkRed, pieInfo.patBkGreen, pieInfo.patBkBlue)

		// set solidPattern popup to first pattern if it is in the range of -1 to 4, else to Solid (mode=3)
		// #"\"Solid;Dark Gray;Gray;Light Gray;\""
		// fpatt =-1	Erase to background color. (NOT USED, NOT IN POPUP MENU)
		// fpatt =0:	No fill. (NOT USED, NOT IN POPUP MENU)
		// fpatt =1:	100% = "Solid" pattern, the default).
		// fpatt =2:	75% gray = "Dark Gray"
		// fpatt =3:	50% gray = "Gray"
		// fpatt =4:	25% gray = "Light Gray"
		mode= 1
		if( fillPat < 5 )
			mode= limit(fillPat, 1, 4)
		endif
		PopupMenu solidPattern,win=PieChartPanel,mode=mode
	
		// DelayUpdates and Help
		CheckBox delayUpdates,win=PieChartPanel, value= pieInfo.delayUpdates

		PutPieStruct(win, pieInfo)	// save any changes made
	endif
End

Static Function PieDataIsValid(w)	// Version 8.042: Unsuitable data is rejected
	Wave/Z w
	
	Variable valid= 0
	if( WaveExists(w) )
		WaveStats/M=0 w
		if( V_min >= 0 && V_numNaNs == 0 && V_numInfs == 0 )
			valid= 1
		endif
	endif
	return valid
End

Static Function WS_DataNotificationProc(SelectedItem, EventCode)	// for WS_SetNotificationProc
	String SelectedItem		// string with full path to the item clicked on in the wave selector
	Variable EventCode		// the ListBox event code that triggered this notification, currently either 4 or 5

	STRUCT PieChartInfo pieInfo

	String  win= TopPieChart()
	if( strlen(win) == 0 )
		win= InitPieChartGraph()
	endif
	
	GetPieStruct(win, pieInfo)

	WAVE/Z w= $SelectedItem
	Variable valid = PieDataIsValid(w)	// Version 8.042: Unsuitable data is rejected
	if( valid )
		pieInfo.dataWaveFolder= GetWavesDataFolder(w,1)	// full path to the numeric data wave's folder (only) WITH trailing colon
		pieInfo.dataWaveName= NameOfWave(w)
		ShowHint("")
	else
		pieInfo.dataWaveFolder= ""
		pieInfo.dataWaveName= ""
		if( !WaveExists(w) )
			ShowHint("Click Numeric Data to start.")
		else
			ShowHint(NameOfWave(w)+" data is not suitable for a pie chart.")
		endif
	endif
	PutPieStruct(win, pieInfo)
	UpdatePieChart(win)
	UpdatePieChartPanel()
End

Static Function WS_TextNotificationProc(SelectedItem, EventCode)	// for WS_SetNotificationProc
	String SelectedItem		// string with full path to the item clicked on in the wave selector
	Variable EventCode		// the ListBox event code that triggered this notification, currently either 4 or 5

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)
//	// Labels
//	int16	labelType								// one of kPieLabelNone, kPieLabelWave, kPieLabelValue, kPieLabelPercent, or kPieLabelPercentTenths
//	char	labelWaveFolder[PIE_MAX_PATH_LEN+1]	// full path to the label text waves folder (only) WITH trailing colon, or ""
//	char	labelWaveName[PIE_MAX_OBJ_NAME+1]	// name of the label wave, or ""
	WAVE/Z tw= $SelectedItem
	if( WaveExists(tw) )
		pieInfo.labelWaveFolder= GetWavesDataFolder(tw,1)	// full path to the numeric data wave's folder (only) WITH trailing colon
		pieInfo.labelWaveName= NameOfWave(tw)
		pieInfo.labelType= kPieLabelWave
	else
		pieInfo.labelWaveFolder= ""
		pieInfo.labelWaveName= ""
	endif
	Variable update= 0
	if( pieInfo.labelType == kPieLabelWave )
		if( !WaveExists(tw) )
//			pieInfo.labelType= kPieLabelNone	// this caused the text list to get hidden if you failed to select a text wave
		endif
		 update=1
	endif
	PutPieStruct("", pieInfo)
	if( update )
		UpdatePieChart("")
	endif
End

Static Function BkgColorPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	ControlInfo/W=PieChartPanel $ctrlName

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	if( (pieInfo.bkgRed != V_red) || (pieInfo.bkgGreen != V_green) || (pieInfo.bkgBlue != V_blue) )
		pieInfo.bkgRed= V_red
		pieInfo.bkgGreen= V_green
		pieInfo.bkgBlue= V_blue
		PutPieStruct("", pieInfo)
		// UpdatePieChart("") - no need to change the wedges...
		String win= TopPieChart()
		if( strlen(win) )
			ModifyGraph/W=$win gbRGB=(V_red, V_green, V_blue), wbRGB=(V_red, V_green, V_blue)
			// remove any tinted background
			DeleteTintsFromWindow(win)
		endif
	endif
End

Static Function LabelsRadioProc(ctrlName,checked) : CheckBoxControl
	String ctrlName	// one of "labelsCheck", "labelsTextRadio", "labelsValueRadio", "labelsPercentRadio", or "labelsTenthsRadio"
	Variable checked	// radio buttons are called only when checked is true. LabelsCheck is NOT a radio button.

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)
	// uncheck/enable or disable other radio buttons
	Variable labelType	//	one of kPieLabelNone, kPieLabelWave, kPieLabelValue, kPieLabelPercent, or kPieLabelPercentTenths

	String typeControls="labelsTextRadio;labelsValueRadio;labelsPercentRadio;labelsTenthsRadio;labelRadius;"
	strswitch(ctrlName)
		case "labelsCheck":
			if( checked == 0 )
				labelType= kPieLabelNone
				ModifyControlList/Z typeControls, disable=2	// disabled, not hidden
			else
				ModifyControlList/Z typeControls, disable=0	// shown, not disabled
				ControlInfo/W=PieChartPanel labelsTextRadio
				if( V_Value )
					labelType= kPieLabelWave
				endif
				ControlInfo/W=PieChartPanel labelsValueRadio
				if( V_Value )
					labelType= kPieLabelValue
				endif
				ControlInfo/W=PieChartPanel labelsPercentRadio
				if( V_Value )
					labelType= kPieLabelPercent
				endif
				ControlInfo/W=PieChartPanel labelsTenthsRadio
				if( V_Value )
					labelType= kPieLabelPercentTenths
				endif
			endif
			break
		case "labelsTextRadio":
			labelType= kPieLabelWave
			break
		case "labelsValueRadio":
			labelType= kPieLabelValue
			break
		case "labelsPercentRadio":
			labelType= kPieLabelPercent
			break
		case "labelsTenthsRadio":
			labelType= kPieLabelPercentTenths
			break
	endswitch
	
	if( CmpStr(ctrlName, "labelsCheck") != 0 )
		Checkbox labelsTextRadio, win=PieChartPanel, value= CmpStr(ctrlName,"labelsTextRadio") == 0
		Checkbox labelsValueRadio, win=PieChartPanel, value= CmpStr(ctrlName,"labelsValueRadio") == 0
		Checkbox labelsPercentRadio, win=PieChartPanel, value= CmpStr(ctrlName,"labelsPercentRadio") == 0
		Checkbox labelsTenthsRadio, win=PieChartPanel, value= CmpStr(ctrlName,"labelsTenthsRadio") == 0
	endif

	pieInfo.labelType= labelType
	PutPieStruct("", pieInfo)

	EnableDisableTextWaveList(labelType != kPieLabelWave)

	UpdatePieChart("")
End

Static Function SetLabelsRadios(labelType)
	Variable labelType	//	one of kPieLabelNone, kPieLabelWave, kPieLabelValue, kPieLabelPercent, or kPieLabelPercentTenths

	Checkbox labelsCheck, win=PieChartPanel, value= labelType != kPieLabelNone

	String labelTypeControls="labelsTextRadio;labelsValueRadio;labelsPercentRadio;labelsTenthsRadio;labelRadius;"
	if( labelType == kPieLabelNone )
		ModifyControlList/Z labelTypeControls, disable=2	// disabled, not hidden
	else
		ModifyControlList/Z labelTypeControls, disable=0	// shown, not disabled
	endif
	
	Checkbox labelsTextRadio, win=PieChartPanel, value= labelType==kPieLabelWave
	Checkbox labelsValueRadio, win=PieChartPanel, value= labelType==kPieLabelValue
	Checkbox labelsPercentRadio, win=PieChartPanel, value= labelType==kPieLabelPercent
	Checkbox labelsTenthsRadio, win=PieChartPanel, value= labelType==kPieLabelPercentTenths
	EnableDisableTextWaveList(labelType != kPieLabelWave)
End


Static Function TintedBackgroundButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Execute/P/Q/Z "INSERTINCLUDE  <TintedWindowBackground>, version>=8";Execute/P/Q/Z "COMPILEPROCEDURES ";Execute/P/Q/Z "WM_TintedBkgPanel()"
	Execute/P/Q/Z "PopupMenu restoreLayerPop,win=TintPanel,popvalue=\"ProgFront\",mode=5"
End

static Function DeleteTintsFromWindow(win)
	String win
	
	String userData = GetUserData(win,"","WM_Tint") // "ProgBack:Tint0,;UserBack:Tint1,;"
	if( strlen(userData) )
		Execute/P/Q/Z "INSERTINCLUDE  <TintedWindowBackground>, version>=8";Execute/P/Q/Z "COMPILEPROCEDURES ";Execute/P/Q/Z "WM_RemoveTintsFromWindow(\""+win+"\")"
	endif
End

static Function PieTotalPctSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	pieInfo.wedgesTotalPct = varNum
	PutPieStruct("", pieInfo)

	UpdatePieChart("")
End

static Function PieWedgesRadiusSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	pieInfo.wedgesRadius= varNum
	PutPieStruct("", pieInfo)

	UpdatePieChart("")
End

static Function PieWedgesInnerRadiusSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	pieInfo.wedgesInnerRadius= varNum
	PutPieStruct("", pieInfo)

	UpdatePieChart("")
End

static Function PieWedgesExplodeSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	pieInfo.explodeWedgesDistance= varNum
	PutPieStruct("", pieInfo)

	UpdatePieChart("")
End

Static Function PieAngle0PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr	// Right= 0 degrees, Bottom = 90 degrees, Left= 180, Top= 270 degrees

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	Variable degrees
	strswitch(popStr)
		default:
		case "Right":
			degrees=0
			break
		case "Bottom":
			degrees=90
			break
		case "Left":
			degrees=180
			break
		case "Top":
			degrees=270
			break
	endswitch
	pieInfo.angle0Degrees = degrees
	PutPieStruct("", pieInfo)

	UpdatePieChart("")
End

Static Function PieLabelFontPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	pieInfo.fontName= popStr
	PutPieStruct("", pieInfo)

	if( pieInfo.labelType != kPieLabelNone )
		UpdatePieChart("")
	endif
End

static Function PieLabelRotationProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	pieInfo.labelRotation= popStr
	PutPieStruct("", pieInfo)

	UpdatePieChart("")
End

static Function PieCenterSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName		// "centerX0" or "centerY0"
	Variable varNum
	String varStr
	String varName

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	strswitch(ctrlName)
		case "centerX0":
			pieInfo.wedgesX0= varNum
			break
		case "centerY0":
			pieInfo.wedgesY0= varNum
			break
	endswitch

	PutPieStruct("", pieInfo)

	UpdatePieChart("")
End

static Function PieClockwiseCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	pieInfo.nextClockwise = checked
	PutPieStruct("", pieInfo)

	UpdatePieChart("")
End


Static Function DelayUpdatesCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	String win= TopPieChart()

	STRUCT PieChartInfo pieInfo
	if( GetPieStruct(win, pieInfo) )

		pieInfo.delayUpdates = checked
		PutPieStruct(win, pieInfo)
	
		if( !checked )
			TickleDependency(win)
		endif
	endif
End

Static Function HelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic/K=1 "2D Pie Chart Procedure"
End

static Function PieChartPanelHook(infoStr)
	String infoStr

	String win= StringByKey("WINDOW",infoStr)
	if( CmpStr(win,"PieChartPanel") == 0 )
		String event= StringByKey("EVENT",infoStr)
		strswitch(event)
			case "activate":
					String pieWin=TopPieChart()
					STRUCT PieChartInfo pieInfo
					if( GetPieStruct(pieWin, pieInfo) )
						RestoreDependency(pieWin, pieInfo)// necessary after re-creating a saved pie chart graph
						PutPieStruct(pieWin,pieInfo)	// save any change to pieInfo.dependencyDataFolderName
					endif
					if( PanelIsOutdated() )
						Print "Closing old Pie Chart Panel to create new version..."
						Execute/P "ShowPieChartPanel()"	// will kill and recreate the panel
						Execute/P "DoAlert 0, \"Updated 2D Pie Chart panel to latest version\""
						return 0
					endif
	
					UpdatePieChartPanel()
					break
			case "kill":
					DoWindow/K OutlineWedges
					// if no chart data folders, then kill the TempDF data folder, too
					String dfpath= TempDF()+":Charts"
					if( 0 == CountObjects(dfPath, 4) )
						KillDataFolder/Z TempDF()
					endif
					break
		endswitch
	endif
	return 0
End

static Function GraphIsDisplayingNumericData(graphName)
	String graphName// already presumed to be a pie chart graph: see TopPieChart()
	
	String info= WinRecreation(graphName,4)
	Variable haveWedges= strsearch(info,"DrawPoly",0) >= 0	// optimistic, but usually the case
	Variable haveCircle = strsearch(info,"DrawOval",0) >= 0
	return haveWedges || haveCircle
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
	
	DoWindow PieChartPanel
	if( V_Flag )
		if( strlen(msg) )
			TitleBox hint,pos={36,20},size={132,12},win=PieChartPanel,disable=2,title="\\K(65535,0,0)"+msg,frame=0,anchor= MC, disable=2
		else
			KillControl/W=PieChartPanel hint
		endif
	elseif( strlen(msg) )
		 DoAlert 0, msg
	endif
End

static Function PieLabelRadiusSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	pieInfo.labelRadius = varNum
	PutPieStruct("", pieInfo)

	if( pieInfo.labelType != kPieLabelNone )
		UpdatePieChart("")
	endif
End

static Function PieLabelFontSizeSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	pieInfo.fontSize = varNum
	PutPieStruct("", pieInfo)
	
	if( pieInfo.labelType != kPieLabelNone )
		UpdatePieChart("")
	endif
End

// OBSOLETE
static Function PieStrokeCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	pieInfo.stroke= checked
	PutPieStruct("", pieInfo)

	UpdatePieChart("")
End

static Function PieStrokeSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	pieInfo.stroke= varNum
	PutPieStruct("", pieInfo)

	UpdatePieChart("")
End


Static Function StrokeColorPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	ControlInfo/W=PieChartPanel $ctrlName

	if( (pieInfo.strokeRed != V_red) || (pieInfo.strokeGreen != V_green) || (pieInfo.strokeBlue != V_blue) )
		pieInfo.strokeRed= V_red
		pieInfo.strokeGreen= V_green
		pieInfo.strokeBlue= V_blue
		PutPieStruct("", pieInfo)
		if( pieInfo.stroke )
			UpdatePieChart("")
		endif
	endif
End

Static Function PieLabelColorPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	ControlInfo/W=PieChartPanel $ctrlName

	if( (pieInfo.labelRed != V_red) || (pieInfo.labelGreen != V_green) || (pieInfo.labelBlue != V_blue) )
		pieInfo.labelRed= V_red
		pieInfo.labelGreen= V_green
		pieInfo.labelBlue= V_blue
		PutPieStruct("", pieInfo)
		if( pieInfo.labelType != kPieLabelNone )
			UpdatePieChart("")
		endif
	endif
End

Static Function LightnessSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	pieInfo.lightness = varNum
	PutPieStruct("", pieInfo)

	UpdatePieChart("")

End

Static Function SaturationSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	pieInfo.saturation = varNum
	PutPieStruct("", pieInfo)

	UpdatePieChart("")

End


static Function OutlineButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	ShowOutlineWedgesPanel()
End

// +++++++ Dependency routines

// Version 3 returns the created data folder name (only the name)
// Version 4 adds optional colorWaveOrNULL parameter
Static Function/S SetUpDependency(win, proposedDfName, dataWave, textWaveOrNull [, colorWaveOrNULL])
	String win
	String proposedDfName	// can be "", in which case we generate a unique data folder name (which is returned)
	WAVE dataWave
	WAVE/Z textWaveOrNull
	WAVE/U/W/Z colorWaveOrNULL

	if (ParamIsDefault(colorWaveOrNULL))
		WAVE/U/W/Z colorWaveOrNULL=$""
	endif

	// create a dependency for a dummy target based on the data and possibly text waves
	// create the dependency in a special folder for the window
	String oldDF= SetTempDF()
	
	NewDataFolder/O/S Charts

	String actualDfName= proposedDfName
	if( strlen(actualDfName) == 0 )
		actualDfName= UniqueName("PieChart", 11, 0)	// unique data folder name 
	endif

	NewDataFolder/O/S $actualDfName

	String dataPath= GetWavesDataFolder(dataWave,4)	// relative path
	String labelPath= "$\"\""		// NULL  text wave means
	if( WaveExists(textWaveOrNull) )
		labelPath= GetWavesDataFolder(textWaveOrNull,4)	// relative path
	endif
	String optionalColorWavePath= ""
	if( WaveExists(colorWaveOrNULL) )
		optionalColorWavePath= ",colorWaveOrNULL="+GetWavesDataFolder(colorWaveOrNULL,4)
	endif

	String formula
	sprintf formula "WMPieChart#UpdateThroughDependency(\"%s\",%s,%s%s)", actualDfName, dataPath, labelPath, optionalColorWavePath

	Variable/G dependencyTarget
	String currentFormula= GetFormula(dependencyTarget)
	if( CmpStr(currentFormula, formula) != 0 )
		SetFormula dependencyTarget, formula
	endif
	SetDataFolder oldDF
	SetWindow $win hook(WMPieChart)= WMPieChartHook, hookEvents=1	// to kill the dependency when the window closes
	return actualDfName	// IT IS IMPORTANT TO SAVE THIS NAME IN THE WINDOW'S pieInfo USERDATA
End

// Call this when the window is closed, regardless of whether a recreation macro exists.
// Note that at that time it is TOO LATE to be getting anything out of any window userData.
Static Function KillDependency(dfName)
	String dfName

	if( strlen(dfName) == 0 )	// version 2?
		return 0
	endif	
	
	String dfpath= TempDF()+":Charts:"+dfName
	if( DataFolderExists(dfpath) )
		String dependencyPath=dfPath+":dependencyTarget"
		KillVariables/Z $dependencyPath
		KillDataFolder/Z $dfpath
		DoWindow PieChartPanel
		if( V_Flag == 0 )	// no pie chart panel showing, try to completely clean up.
			// if that was the last data folder, then kill the TempDF data folder, too
			dfpath= TempDF()+":Charts"
			if( 0 == CountObjects(dfPath, 4) )
				KillDataFolder/Z TempDF()
			endif
		endif
	endif
	return 0
End

// used to reset the custom colors
static Function ClearDependency(dfName)
	String dfName

	if( strlen(dfName) == 0 )	// version 2?
		return 0
	endif	
	
	String dfpath= TempDF()+":Charts:"+dfName
	if( DataFolderExists(dfpath) )
		String dependencyPath=dfPath+":dependencyTarget"
		KillVariables/Z $dependencyPath
	endif
End

// window name of pie chart whose dependecies are stored in TempDF()+":Charts:"+dfName, or "" if none. 
Static Function/S GetPieChartWindowForDFName(dfName)
	String dfName
	
	if( strlen(dfName) == 0 )
		return ""
	endif
	
	// First Loop through all graphs looking for pie structs with dfName==pieInfo.dependencyDataFolderName
	Variable haveEarlyVersions= 0
	String list= WinList("*", ";", "WIN:1")
	Variable i=0
	do
		String win= StringFromList(i,list)
		if( strlen(win) == 0 )
			return ""
		endif
		String userdata = GetUserData(win, "", "WMPieChart")
		if( strlen(userData) )
			STRUCT PieChartInfoFixedLength pieInfo
			StructGet/S pieInfo, userdata
			if( pieInfo.version < 3 )
				haveEarlyVersions= 1
			else
				if( CmpStr(dfName, pieInfo.dependencyDataFolderName) == 0 )
					return win
				endif
			endif
		endif
		i += 1
	while(1)
	
	// then loop looking for Version 1 or 2 pie chart graphs whose window name matches dfName 
	if( haveEarlyVersions )
		i=0
		do
			win= StringFromList(i,list)
			if( strlen(win) == 0 )
				return ""
			endif
			userdata = GetUserData(win, "", "WMPieChart")
			if( strlen(userData) )
				StructGet/S pieInfo, userdata
				if( pieInfo.version < 3 )
					if( CmpStr(dfName, win) == 0 )
						return win
					endif
				endif
			endif
			i += 1
		while(1)
	endif
	return ""
End

// Version 3 routine didn't have optional colorWaveOrNULL parameter
Static Function UpdateThroughDependency(chartDFName, dataWave, textWaveOrNull [, colorWaveOrNULL])
	String chartDFName	// Version 2 expected the current window name, but that prevented window renaming, so we pass the data folder name in versions 3 and later.
	WAVE dataWave
	WAVE/T/Z textWaveOrNull
	WAVE/U/W/Z colorWaveOrNULL

	if (ParamIsDefault(colorWaveOrNULL))
		WAVE/U/W/Z colorWaveOrNULL = $""
	endif
	
	Variable lastCRCsum= NumVarOrDefault(ChartNameDFVar(chartDFName, "dependencyTarget"),0)
		
	String win= GetPieChartWindowForDFName(chartDFName)
	if( strlen(win) == 0 )
		return lastCRCsum
	endif
	
	STRUCT PieChartInfo pieInfo
	if( !GetPieStruct(win, pieInfo) )	// window userData is gone.
		return lastCRCsum
	endif

	if( pieInfo.delayUpdates )
		return lastCRCsum
	endif

	Variable crcSum=0

	String caller= GetRTStackInfo(2)	// NameOfCallingRoutine()
	strswitch(caller)
		default:
		case "":		// No calling routine: must have been called through dependency mechanism.
			// see whether the the waves are actually changed (modified) from when we last updated
			Variable changed= 0
			if( WaveExists(dataWave) )
				crcSum = WaveCRC(crcSum, dataWave, 1)	// CRC only the header (it's faster, and sufficient)
			endif
			if( WaveExists(textWaveOrNull) )
				crcSum = WaveCRC(crcSum, textWaveOrNull, 1)
			endif
			if( WaveExists(colorWaveOrNULL) )
				crcSum = WaveCRC(crcSum, colorWaveOrNULL, 1)
			endif
			changed = crcSum != lastCRCsum
			if( changed )
				break
			endif
			// else fall through for no update
		case "SetUpDependency":	// SetFormula was just called
			return lastCRCsum	// no change
	endswitch
	
	UpdatePieChart(win)
	
	return crcSum		//  This is stored in ChartNameDFVar(chartDFName, "dependencyTarget")!
End

// call through the dependency
static Function TickleDependency(win)
	String win

	STRUCT PieChartInfo pieInfo
	if( !GetPieStruct(win, pieInfo) )	// window is gone.
		return 0
	endif

	//String dwPath= pieInfo.dataWaveFolder + pieInfo.dataWaveName
	String dwPath= pieInfo.dataWaveFolder + PossiblyQuoteName(pieInfo.dataWaveName)	// 6.382
	WAVE/Z dw= $dwPath
	if( WaveExists(dw) )
		if(pieInfo.labelType == kPieLabelWave )
			//String twPath=pieInfo.labelWaveFolder + pieInfo.labelWaveName
			String twPath=pieInfo.labelWaveFolder + PossiblyQuoteName(pieInfo.labelWaveName)	// 6.382
			WAVE/T/Z tw=$twPath
		endif
		NVAR/Z dependencyTarget= $ChartNameDFVar(win, "dependencyTarget")
		if( NVAR_Exists(dependencyTarget) )
			String dfName= pieInfo.dependencyDataFolderName
			if( strlen(dfName) == 0 )
				dfName= win	// version 1 or 2 method
			endif
			WAVE/U/W/Z pieChartCustomColors=$WedgeColorWavePath(pieInfo)
			dependencyTarget= UpdateThroughDependency(dfName, dw, tw,colorWaveOrNULL=pieChartCustomColors)
		endif
	endif
End

// graph hook

Function WMPieChartHook(hs)
	STRUCT WMWinHookStruct &hs
	
	Variable ret=0
	STRUCT PieChartInfo pieInfo
	Variable wedge
	strswitch(hs.eventName)
		case "kill":
			GetPieStruct(hs.winName, pieInfo)
			String dfName= pieInfo.dependencyDataFolderName
			if( strlen(dfName) == 0 )
				dfName= hs.winName	// a version 1 or 2 pie chart is about to die...
			endif
			Execute/P/Q "WMPieChart#KillDependency(\"" + dfName + "\")"	// once the window has gone away
			break
		case "resize":
			// if the aspect ratio isn't square, adjust the margins to maintain the desired aspect ratio.
			ret= MaintainAspectUsingMargins(hs.winName)
			break
		case "mousedown":
			// double-click logic
			Variable lastClickTicks= NumVarOrDefault(ChartDFVar("lastClickTicks"), 0)
			Variable isDoubleClick= (hs.ticks - lastClickTicks) < (0.5*60)	// 1/2 second (there are 60 ticks per second)
			Variable/G $ChartDFVar("lastClickTicks")= hs.ticks
			if( isDoubleClick )
				ShowPieChartPanel()
				ret= 1
			elseif( (hs.eventMod %& 16 ) && !(hs.eventMod %& 2)) // contextual click, don't show if Shift key held down
				wedge= WMPieFindWedge(hs.winName,hs.mouseLoc.h, hs.mouseLoc.v)
				String menuName="PieContextualMenuPlain"
				if( numtype(wedge) == 0 )
					GetPieStruct(hs.winName, pieInfo)	// see PieWedgeColorMenuItem() and PieWedgePatternMenuItem()
					Variable/G $ChartDFVar("wedgeNo") = wedge
					Variable/G $ChartDFVar("mouseH") = hs.mouseLoc.h
					Variable/G $ChartDFVar("mouseV")	= hs.mouseLoc.v
					String/G $ChartDFVar("pieWin")	= hs.winName
					menuName="PieContextMenuColorAndPatt"	// if pieInfo.useAllWedgesColor, can change ALL colors
				endif
				PopupContextualMenu/C=( hs.mouseLoc.h, hs.mouseLoc.v)/N menuName
				Variable fillPat= NaN
				strswitch(S_selection)
					case "Modify Pie Chart...":
						ShowPieChartPanel()
						break
					case "Modify Graph...":
						DoIgorMenu "Graph", "Modify Graph"
						break
					case "Add Annotation...":
						DoIgorMenu "Graph", "Add Annotation"
						break
					case "Erase":
						fillpat = -1
						break
					case "None":
						fillpat = 0
						break
					case "Solid":
						fillpat = 1
						break
					case "Dark Gray":
						fillpat = 2
						break
					case "Gray":
						fillpat = 3
						break
					case "Light Gray":
						fillpat = 4
						break
					default:
						if( V_kind == 10 )	// *COLORPOP*
							Variable useCustomColors= 1
							if( pieInfo.useAllWedgesColor )
								DoAlert 1, "Set all wedges to this color?"
								if( V_Flag == 1 ) 	//yes
									useCustomColors= 0	// all same color
								endif
							endif
							WMPieSetWedgeColor(hs.winName, pieInfo, wedge, V_red, V_green, V_Blue, useCustomColors)
							PutPieStruct(hs.winName, pieInfo)
							UpdatePieChart(hs.winName)
						elseif( V_kind == 7 )	// *PATTERNPOP*
							fillpat= V_Flag+4	// item 1 is pattern 5, etc
						endif
						break
				endswitch
				if( numtype(fillpat) == 0 )
					WMPieSetWedgePattern(hs.winName, wedge, pieInfo, fillpat)
					PutPieStruct(hs.winName, pieInfo)
					UpdatePieChart(hs.winName)
				endif
				ret= 1
			endif
			break
#if 0	// debugging
		case "mousemoved":
			wedge= WMPieFindWedge(hs.winName,hs.mouseLoc.h, hs.mouseLoc.v)
			Variable/G root:pieWedge= wedge
			break
#endif
	endswitch
	return ret
End

Menu "PieContextualMenuPlain", contextualmenu
	"\\M0:(:(Use shift key for normal contextual menu)", ;
	"Modify Pie Chart...", ;
	"Modify Graph...", ;
	"Add Annotation...", ;
End

Menu "PieContextMenuColorAndPatt", contextualmenu, dynamic
	"\\M0:(:(Use shift key for normal contextual menu)", ;
	"Modify Pie Chart...", ;
	"Modify Graph...", ;
	"Add Annotation...", ;
	Submenu "Wedge Color"
		PieWedgeColorMenuItem(), ;
	End
	Submenu "Wedge Pattern"
		PieWedgePatternMenuItem("Solid"), ;	// 1
		PieWedgePatternMenuItem("Dark Gray"), ;	// 2
		PieWedgePatternMenuItem("Gray"), ;			// 3
		PieWedgePatternMenuItem("Light Gray"), ;	// 4
		Submenu "Pattern"
			PieWedgePatternMenuItem("*PATTERNPOP*"), ;	// fillpat 5...76
		End
	End
End

Function WMPieFindWedge(win, mouseH, mouseV)
	String win
	Variable mouseH, mouseV

	Variable angle, radius
	Variable isInsideWedge= WMPieAngleFromMouse(win, mouseH, mouseV, angle, radius)
	Variable wedge=NaN
	if( isInsideWedge )
		STRUCT PieChartInfo pieInfo
		GetPieStruct(win, pieInfo)
		wedge= WMPieWedgeFromAngle(pieInfo,angle)
	endif
	return wedge
end

Function IsPieChart(win)
	String win
	
	if( strlen(win) && WinType(win) == 1 )
		String userdata = GetUserData(win, "", "WMPieChart")
		if( strlen(userData) )
			return 1
		endif
	endif
	return 0
End

Static Function/S PieWinOrTop()

	String pieWin= StrVarOrDefault(ChartDFVar("pieWin"),"")	// see WMPieChartHook
	if( strlen(pieWin) == 0 || !IsPieChart(pieWin) )
		pieWin= TopPieChart()
	endif
	
	return pieWin
End

Function/S PieWedgeColorMenuItem()

	String menuItem="*COLORPOP*"
	String win= PieWinOrTop()
	if( strlen(win) )
		Variable wedge= NumVarOrDefault(ChartDFVar("wedgeNo"),NaN)	// see WMPieChartHook
		if( numtype(wedge) == 0 )
			Variable red, green, blue
			if( WMPieGetWedgeColor(win, wedge, red, green, blue) )
				sprintf menuItem, "*COLORPOP*(%d,%d,%d)",red, green, blue
			endif
		endif
	endif
	
	return menuItem
End

Function/S PieWedgePatternMenuItem(menuItem)
	String menuItem
	
	String win= PieWinOrTop()
	if( strlen(win) )
		Variable wedge= NumVarOrDefault(ChartDFVar("wedgeNo"),NaN)	// see WMPieChartHook
		if( numtype(wedge) == 0 )
			STRUCT PieChartInfo pieInfo
			GetPieStruct(win, pieInfo)
			Variable fillPat= WMPiePatternForWedge(win, wedge, pieInfo)
			
			if( CmpStr(menuItem,"*PATTERNPOP*") == 0 )
				Variable item= fillPat - 4	// item 1 corresponds to fillPat =5
				if( item >= 1 )
					sprintf menuItem, "*PATTERNPOP*(%d)",item
				endif
			else
				String patternName= StringFromList(fillPat+1,"Erase;None;Solid;Dark Gray;Gray;Light Gray;")
				if( CmpStr(patternName, menuItem) == 0 )
					// check the menu item
					menuItem= "!"+num2char(18)+menuItem
				endif
			endif
		endif
	endif
	
	return menuItem
End

static Function MaintainAspectUsingMargins(graphName)
	String graphName

	GetWindow $graphName gsize	// V_left, V_right, V_top, and V_bottom in points
	Variable gWidth= (V_right-V_Left)
	Variable gHeight= (V_bottom-V_top)
	
	Variable margin
	if( gWidth > gHeight )
		// pad left and right margins, set top and bottom to 0
		margin= (gWidth - gHeight)/2
		if( margin < 1 )
			margin= -1
		endif
		ModifyGraph/W=$graphName margin(left)=margin, margin(right)=margin, margin(top)=-1, margin(bottom)=-1
	else
		// pad top and bottom margins, set left and right to 0
		margin= (gHeight - gWidth)/2
		if( margin < 1 )
			margin= -1
		endif
		ModifyGraph/W=$graphName margin(left)=-1, margin(right)=-1, margin(top)=margin, margin(bottom)=margin
	endif
	return 1
End
	
static Function WedgeColorsCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName	// "autoColors" or "customColors" or "allWedgesOneColor"
	Variable checked

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	pieInfo.useCustomColors= CmpStr(ctrlName,"customColors") == 0
	pieInfo.useAllWedgesColor= CmpStr(ctrlName,"allWedgesOneColor") == 0
	PutPieStruct("", pieInfo)

	CheckBox customColors,win=PieChartPanel, value= pieInfo.useCustomColors
	CheckBox allWedgesOneColor,win=PieChartPanel, value= pieInfo.useAllWedgesColor

	checked= !pieInfo.useCustomColors && !pieInfo.useAllWedgesColor
	CheckBox autoColors,win=PieChartPanel, value= checked

	UpdatePieChart("")
End

// Use this to check if there is a custom color wave:
// WAVE/U/W/Z cw= $WedgeColorWavePath(pieInfo)
// if( WaveExists(cw) )
// ...
static Function/S WedgeColorWavePath(pieInfo)
	STRUCT PieChartInfo &pieInfo

	String chartDFName= pieInfo.dependencyDataFolderName
	String pathToColorWave= ChartNameDFVar(chartDFName, "pieChartCustomColors")
	return pathToColorWave
end


static Function StoreWedgeColors(win, pieInfo)
	String win
	STRUCT PieChartInfo &pieInfo

	String pathToColorWave=WedgeColorWavePath(pieInfo)
	WAVE/U/W/Z pieChartCustomColors=$pathToColorWave

	if( WaveExists(pieChartCustomColors) )
		Variable i, numColors= min(DimSize(pieChartCustomColors,0), PIE_MAX_COLORS) // 6.381
		for( i=0; i< numColors;i+=1 )
			pieInfo.customColorTable.customRed[i]= pieChartCustomColors[i][0]
			pieInfo.customColorTable.customGreen[i]=pieChartCustomColors[i][1]
			pieInfo.customColorTable.customBlue[i]= pieChartCustomColors[i][2]
		endfor
		pieInfo.numCustomColorsInitialized= numColors
		for( ; i<PIE_MAX_COLORS;i+=1 )
			pieInfo.customColorTable.customRed[i] = 65535/2
			pieInfo.customColorTable.customGreen[i] = 65535/2
			pieInfo.customColorTable.customBlue[i] = 65535/2
		endfor
	else
		pieInfo.numCustomColorsInitialized= 0
	endif
	PutPieStruct(win, pieInfo)
End

//  call this when you KNOW you want custom colors,
// NOT just to check if the user defined custom colors.
static Function/S CreateWedgeColorWave(win, pieInfo)
	String win
	STRUCT PieChartInfo &pieInfo

	Variable numWedges= 100
	String pathToDataWave= pieInfo.dataWaveFolder + PossiblyQuoteName(pieInfo.dataWaveName)
	WAVE/Z DataWave= $pathToDataWave
	if( WaveExists(DataWave) )
		numWedges= DimSize(DataWave,0)
	endif

	String df= TempDF()+":Charts"
	NewDataFolder/O $df
	String dfName= pieInfo.dependencyDataFolderName
	df= TempDF()+":Charts:"+dfName	// data folder name was same as window name prior to version 3.
	NewDataFolder/O $df

	String pathToColorWave=WedgeColorWavePath(pieInfo)
	WAVE/U/W/Z pieChartCustomColors=$pathToColorWave

	Variable i, red, green, blue
	if( WaveExists(pieChartCustomColors) )
		Variable numColors= DimSize(pieChartCustomColors,0)
		if( numWedges > numColors )
			// data longer than color wave, fill the new points with automatic colors
			Redimension/N=(numWedges,3) pieChartCustomColors
			for( i=numColors; i< numWedges; i+=1 )
				WMPieAutomaticColor(i,numWedges,red, green, blue)	// red, green, blue are 0-65535
				pieChartCustomColors[i][0]= red
				pieChartCustomColors[i][1]= green
				pieChartCustomColors[i][2]= blue
			endfor
		endif
	else
		Make/U/W/O/N=(numWedges,3) $pathToColorWave
		WAVE/U/W pieChartCustomColors=$pathToColorWave
		
		for( i=0; i< pieInfo.numCustomColorsInitialized && i < numWedges; i+=1 )
			pieChartCustomColors[i][0]= pieInfo.customColorTable.customRed[i]
			pieChartCustomColors[i][1]= pieInfo.customColorTable.customGreen[i]
			pieChartCustomColors[i][2]= pieInfo.customColorTable.customBlue[i]
		endfor

		for( ; i< numWedges; i+=1 )
			WMPieAutomaticColor(i,numWedges,red, green, blue)	// red, green, blue are 0-65535
			pieChartCustomColors[i][0]= red
			pieChartCustomColors[i][1]= green
			pieChartCustomColors[i][2]= blue
		endfor
		pieInfo.numCustomColorsInitialized= min(numWedges,PIE_MAX_COLORS) // 6.381
		RestoreDependency(win, pieInfo)	// now the dependency involves the color wave, too.
	endif
	StoreWedgeColors(win, pieInfo)
	return pathToColorWave
End

static Function EditCustomColorsButtonProc(ctrlName) : ButtonControl
	String ctrlName

	STRUCT PieChartInfo pieInfo
	String pieWin= TopPieChart()
	GetPieStruct(pieWin, pieInfo)
	String pathToColorWave= CreateWedgeColorWave(pieWin,pieInfo)
	PutPieStruct(pieWin, pieInfo)
	
	CWE_MakeClientColorEditor($pathToColorWave, 0, CWE_range65535, "2D Pie Chart Custom Colors", "Click on a row", "")
	
End

// ------- Start of Wedge Outline SubPanel Code -----------

Function ShowOutlineWedgesPanel()
	
	Variable/G $ChartDFVar("outlineWedgesThickness")
	Variable/G $ChartDFVar("outlineWedgesFirst")
	Variable/G $ChartDFVar("outlineNumWedges")
	
	DoWindow/K OutlineWedges
	NewPanel/K=1/N=OutlineWedges/W=(329,72,820,261) as "Outline Wedges"
	DoWindow/C OutlineWedges
	ModifyPanel fixedSize=1, noEdit=1

	SetVariable outlineWedgesThickness,pos={49,25},size={163,15},bodyWidth=50,proc=WMPieChart#WedgeOutlineSetVarProc,title="Wedge Outline Thickness"
	SetVariable outlineWedgesThickness,limits={0,10,0.5},value= root:Packages:WMPieChart:outlineWedgesThickness

	SetVariable outlineWedgesFirst,pos={60,59},size={152,15},bodyWidth=50,proc=WMPieChart#WedgeOutlineSetVarProc,title="First Wedge to Outline"
	SetVariable outlineWedgesFirst,limits={1,inf,1},value= root:Packages:WMPieChart:outlineWedgesFirst

	SetVariable outlineNumWedges,pos={28,93},size={184,15},bodyWidth=50,proc=WMPieChart#WedgeOutlineSetVarProc,title="Number of Wedges to Outline"
	SetVariable outlineNumWedges,limits={1,inf,1},value= root:Packages:WMPieChart:outlineNumWedges

	PopupMenu outlineColor,pos={100,127},size={109,20},proc=WMPieChart#OutlineColorPopMenuProc,title="Outline Color"
	PopupMenu outlineColor,mode=1,popColor= (0,0,0),value= #"\"*COLORPOP*\""

	CheckBox hideSpokes,pos={18,160},size={196,14},proc=WMPieChart#OutlineHideSpokesCheckProc,title="Hide Spokes (Outline only the perimeter)"

	String/G $ChartDFVar("outlineHelp") ="\\K(65535,0,0)Outlining draws a line around a group of wedges.\r\rStroke draws a line around each wedge.\r\rSet Outline Thickness to 0 to turn off outlining."
	TitleBox help,pos={232,24},size={225,56}, variable= $ChartDFVar("outlineHelp"), fsize=10

	Button close,pos={309,126},size={70,20},proc=WMPieChart#OutlineCloseButtonProc,title="Done"

	AutoPositionWindow/R=PieChartPanel OutlineWedges

	UpdateOutlineWedgesPanel()
	SetWindow OutlineWedges hook(outlineWedges)=WMPieChart#OutlineWedgesHook
End


static Function OutlineWedgesHook(hs)
	STRUCT WMWinHookStruct &hs

	if( CmpStr(hs.winName,"OutlineWedges") == 0 )
		strswitch(hs.eventName)
			case "activate":
					UpdateOutlineWedgesPanel()
					break
		endswitch
	endif
	return 0
End

Static Function UpdateOutlineWedgesPanel()

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	Variable/G $ChartDFVar("outlineWedgesThickness") = pieInfo.outlineWedgesThickness
	Variable/G $ChartDFVar("outlineWedgesFirst") = max(1,pieInfo.outlineWedgesFirst)
	
	Variable numWedges= max(1,pieInfo.outlineNumWedges)
	// Check numWedges against data wave
	String pathToDataWave= pieInfo.dataWaveFolder + PossiblyQuoteName(pieInfo.dataWaveName)
	WAVE/Z DataWave= $pathToDataWave
	if( WaveExists(DataWave) )
		numWedges= min(numWedges,numpnts(DataWave))
		SetVariable outlineWedgesFirst,win=OutlineWedges,limits={1,numpnts(DataWave),1}
		SetVariable outlineNumWedges,win=OutlineWedges,limits={1,numpnts(DataWave),1}
	endif
	pieInfo.outlineNumWedges= numWedges
	Variable/G $ChartDFVar("outlineNumWedges") = pieInfo.outlineNumWedges

	PopupMenu outlineColor,win=OutlineWedges,popColor= (pieInfo.outlineWedgesRed,pieInfo.outlineWedgesGreen,pieInfo.outlineWedgesBlue)

	CheckBox hideSpokes,value= pieInfo.outlineHideSpokes

End


static Function WedgeOutlineSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	strswitch(ctrlName)
		case "outlineWedgesThickness":
			pieInfo.outlineWedgesThickness= varNum
			break
		case "outlineWedgesFirst":
			pieInfo.outlineWedgesFirst= varNum
			break
		case "outlineNumWedges":
			pieInfo.outlineNumWedges= varNum
			break
	endswitch

	PutPieStruct("", pieInfo)

	UpdatePieChart("")
End


Static Function OutlineColorPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	ControlInfo/W=OutlineWedges $ctrlName

	if( (pieInfo.outlineWedgesRed != V_red) || (pieInfo.outlineWedgesGreen != V_green) || (pieInfo.outlineWedgesBlue != V_blue) )
		pieInfo.outlineWedgesRed= V_red
		pieInfo.outlineWedgesGreen= V_green
		pieInfo.outlineWedgesBlue= V_blue
		PutPieStruct("", pieInfo)
		if( pieInfo.outlineWedgesThickness && pieInfo.outlineNumWedges )
			UpdatePieChart("")
		endif
	endif
End

static Function OutlineCloseButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	Execute/P/Q "DoWindow/K OutlineWedges"
End

static Function OutlineHideSpokesCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	pieInfo.outlineHideSpokes= checked

	PutPieStruct("", pieInfo)

	UpdatePieChart("")
End

Function WMPieMouseToPlotRel(win, mouseH, mouseV, xPrel, yPrel)
	String win
	Variable mouseH, mouseV
	Variable &xPrel, &yPrel	// outputs
	
	GetWindow $win psizeDC
	xPrel = (mouseH - V_Left) / (V_Right-V_Left)
	yPrel = (mouseV - V_Top) / (V_Bottom-V_Top)
End

// return truth the radius is < wedgesRadius
Function WMPieAngleFromMouse(win, mouseH, mouseV, angle, radius)
	String win
	Variable mouseH, mouseV
	Variable &angle	// radians
	Variable &radius	// plot relative
	
	STRUCT PieChartInfo pieInfo
	GetPieStruct(win, pieInfo)
	
	// convert pixels to plot relative coordinates
	Variable xPrel, yPrel
	WMPieMouseToPlotRel(win, mouseH, mouseV, xPrel, yPrel)
	
	// adjust for center
	Variable pieX = xPrel-pieInfo.wedgesX0 
	Variable pieY = yPrel-pieInfo.wedgesY0 
	
	// compute the angle
	angle= atan2(pieY, pieX)	// drawn angle in radians
	
	// compute the radius
	radius= sqrt(pieX*pieX+pieY*pieY)

#if 0	// debugging
	Variable/G root:pieX= pieX
	Variable/G root:pieY= pieY
	Variable/G root:pieAngle= angle * 180 / pi	// degrees
	Variable/G root:pieRadius= radius
#endif	
	
	// Is the mouse inside the wedge?
	Variable isInsideWedge= radius <= pieInfo.wedgesRadius

	return isInsideWedge
End


// returns free wave
Function/WAVE WMPieFracWave(pieInfo)
	STRUCT PieChartInfo &pieInfo
	
	String pathToDataWave= pieInfo.dataWaveFolder + PossiblyQuoteName(pieInfo.dataWaveName)
	WAVE/Z DataWave= $pathToDataWave
	if( !WaveExists(DataWave) )
		return $""
	endif
	
	Duplicate/FREE DataWave, FracWave
	Variable NumWedges=numpnts(FracWave)
	FracWave[1,NumWedges-1] = FracWave[p-1] + FracWave[p]	// integrate
	Variable total = FracWave[NumWedges-1]
	Variable maxFrac= pieInfo.wedgesTotalPct / 100
	FracWave = FracWave/total*maxFrac	// now it really is a "fraction wave"
	InsertPoints 0,1,FracWave	// inserts a 0

	return FracWave
End

Function WMPieAngleIsBetweenAngles(angle, startAngle, endAngle)
	Variable angle	// between -pi and +pi
	Variable startAngle, endAngle	// between -4pi and +4pi, but the pie wedge is betwen start and end
										// and these angles are NOT wrapped modulo 2pi.
	
	Variable ccw = endAngle < startAngle
	Variable originalAngle= angle
	if( ccw )
		for(; angle<endAngle; angle+=2*pi)
		endfor
		for(; angle>startAngle; angle-=2*pi)
		endfor
		if( angle >= endAngle )
			return 1
		endif
	else
		for(; angle<startAngle; angle+=2*pi)
		endfor
		for(; angle>endAngle; angle-=2*pi)
		endfor
		if( angle >= startAngle )
			return 1
		endif
	endif
	
	return 0
End

Function WMPieWedgeFromAngle(pieInfo, angle)
	STRUCT PieChartInfo &pieInfo
	Variable angle	// radians, for normal prel drawing, has no adjustments for angle0 or direction.
						// accordingly, the value is 0 to +/- pi.
						
	
	Variable angle0= pi * pieInfo.angle0Degrees/180
	
	// To compute the wedge, we need the fraction wave
	WAVE/Z FracWave= WMPieFracWave(pieInfo)
	if( WaveExists(FracWave) )
		Variable i, n= numpnts(FracWave)
		for(i=0; i<n; i+=1 )
			Variable StartAngle = 2*pi*FracWave[i]
			Variable EndAngle = 2*pi*FracWave[i+1]
			// convert to drawn angle.
			if( !pieInfo.nextClockwise )	// if (ccw)
				StartAngle = -StartAngle
				EndAngle= -EndAngle
			endif
			StartAngle += angle0
			EndAngle += angle0
			// compare this wedge's drawn angles to the input angle.
			if( WMPieAngleIsBetweenAngles(angle, startAngle, endAngle) )
				return i
			endif
		endfor
		
	endif
	
	return NaN
End


// ------- Start of Fill Patterns Code -----------

Function WMPiePatternForWedge(win, wedge, pieInfo)
	String win
	Variable wedge // 0 is the first wedge
	STRUCT PieChartInfo &pieInfo
	
	Variable fillPat= 1		// solid aka 100%
	wedge= mod(wedge,PIE_MAX_PATTERNS)	// pieInfo.fillPatterns array has PIE_MAX_PATTERNS elements
	String pathToDataWave= pieInfo.dataWaveFolder + PossiblyQuoteName(pieInfo.dataWaveName)
	WAVE/Z DataWave= $pathToDataWave
	if( WaveExists(DataWave) )
		Variable NumWedges= numpnts(DataWave), pattern
		if( wedge >= pieInfo.numFillPatternsInitialized )
			// initialize to non-% patterns ()
			Variable i
			Variable numUsefulPatterns= 72 // # of items in a *PATTERNPOP* menu
			for( i=pieInfo.numFillPatternsInitialized; i<=wedge ; i+=1 )
				pattern= mod(i,numUsefulPatterns) + 5
				pieInfo.fillPatterns.fillpat[i] = pattern
			endfor
			pieInfo.numFillPatternsInitialized= wedge+1
			PutPieStruct(win, pieInfo)
		endif
		fillPat= pieInfo.fillPatterns.fillpat[wedge]
	endif
	return fillPat
End

Function WMPieSetWedgePattern(win, wedge, pieInfo, pattern)
	String win
	Variable wedge // 0 is the first wedge
	STRUCT PieChartInfo &pieInfo
	Variable pattern

	wedge= mod(wedge,PIE_MAX_PATTERNS)	// pieInfo.fillPatterns array has PIE_MAX_PATTERNS elements
	// an important side affect of calling WMPiePatternForWedge
	// is ensuring pieInfo.numFillPatternsInitialized includes wedge
	Variable oldPattern= WMPiePatternForWedge(win, wedge, pieInfo)
	pieInfo.fillPatterns.fillpat[wedge] = pattern

	return oldPattern
End

static Function AllWedgesPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	pieInfo.useCustomColors=0
	pieInfo.useAllWedgesColor=1
	
	ControlInfo/W=PieChartPanel $ctrlName
	pieInfo.allWedgesRed= V_red
	pieInfo.allWedgesGreen= V_green
	pieInfo.allWedgesBlue= V_blue

	PutPieStruct("", pieInfo)
	
	CheckBox allWedgesOneColor, win=PieChartPanel, value=1
	CheckBox autoColors, win=PieChartPanel, value=0
	CheckBox customColors, win=PieChartPanel, value=0

	UpdatePieChart("")
End

static Function PatternPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Variable fillPat= 1
	if( CmpStr(ctrlName,"pattern") == 0 )
		fillPat = popNum+4	// first item is fillPat 5
	else
		// solidPattern
		fillPat = popNum			// first item is Solid, fillPat= 1
	endif

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)
	Variable i
	for(i=0; i<100; i+= 1)
		pieInfo.fillPatterns.fillPat[i] = fillPat
	endfor

	PutPieStruct("", pieInfo)

	UpdatePieChart("")
End

// You can use an override function to change this algorithm
// DisplayHelpTopic "Function Overrides"
Function WMPieAutomaticPattern(wedge)
	Variable wedge	// input, 0 is the first wedge.
	
	Variable fillPat= 5 + mod(wedge,72)
	return fillPat	// SetDrawEnv fillPat value
End

static Function AutomaticPatterns(ctrlName) : ButtonControl
	String ctrlName

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)
	Variable i
	for(i=0; i<100; i+= 1)
		pieInfo.fillPatterns.fillPat[i] = WMPieAutomaticPattern(i)
	endfor

	PutPieStruct("", pieInfo)

	UpdatePieChart("")
End

static Function PatBkgPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	STRUCT PieChartInfo pieInfo
	GetPieStruct("", pieInfo)

	ControlInfo/W=PieChartPanel $ctrlName
	pieInfo.patBkRed= V_red
	pieInfo.patBkGreen= V_green
	pieInfo.patBkBlue= V_blue

	PutPieStruct("", pieInfo)
	UpdatePieChart("")
End
