#pragma rtGlobals=3			// Use modern global access method and strict wave access.
#pragma version=9.05			// Revised for Igor 9.05
#pragma IgorVersion=9

// Main include of the New Polar Graphs procedures
//
//	Made programatic creation and alteration of polar graphs possible without displaying the panel
//	by adding the following routines:
//
//		WMNewPolarGraph(templateGraphName, newOrExistingGraphName)
//		WMPolarAppendTrace(graphName,appendRadius, appendAngleData, anglePerCircle)
//		WMPolarRemoveTrace(graphName,traceName)
//		WMPolarGraphDisplayed(radiusData)
//		WMPolarTraceNameForRadiusData(polarGraphName,radiusData)
//		WMPolarGraphSetVar(graphNameOrDefault,varName,variableValue)
//		WMPolarGraphGetVar(graphNameOrDefault,varName)
//		WMPolarGraphSetStr(graphNameOrDefault,varName,stringValue)
//		WMPolarGraphGetStr(graphNameOrDefault,varName)
//		WMPolarTagRadius(tagWaveRefHere,tagPointNumber)
//		WMPolarTagAngle(tagWaveRefHere,tagPointNumber)
//		WMPolarAxesRedrawGraphNow(polarGraphName)
//
//		WMPolarSetManualRadiusRange(polarGraphName, radiusMin, radiusMax)
//		WMPolarGetRadiusRange(polarGraphName, radiusMin, radiusMax)
//
//		WMPolarSetAutoRadiusRange(polarGraphName [,alwaysIncludeOrigin])
//		WMPolarGetAutoRadiusRange(polarGraphName, alwaysIncludeOrigin)
//
//		WMPolarSetAngleRange(polarGraphName, startAngleDegrees, angleExtentDegrees)
//		WMPolarGetAngleRange(polarGraphName, startAngleDegrees, angleExtentDegrees)
//
//		WMPolarSetZeroAngleWhere(polarGraphName, where [,radiusOrigin])
//		WMPolarGetZeroAngleWhere(polarGraphName, whereDegrees,radiusOrigin)
//
//		WMPolarSetAngleDirection(polarGraphName, angleDirectionStr)
//		WMPolarGetAngleDirection(polarGraphName)
//
//		WMPolarGetTraceErrorBars(graphName,polarTraceName,errorBarsCapThickness,errorBarsBarThickness,colorFromTraceRadio,errorBarsColorsString)
//		WMPolarSetTraceErrorBars(graphName,polarTraceName,errorBarsCapThickness,errorBarsBarThickness,colorFromTraceRadio,errorBarsColorsString)
//
//		WMPolarGetTraceRadiusErrorBars(graphName,polarTraceName,radiusErrorBarsX,radiusErrorBarsY,radiusErrorBarsMrkZ,radiusErrorBarsMode,radiusErrorBarsPercent,radiusErrorBarsConstant,radiusErrorBarsPlusWavePath,radiusErrorBarsMinusWavePath,radiusErrorBarsCapWidthStr)
//		WMPolarSetTraceRadiusErrorBars(graphName,polarTraceName,radiusErrorBarsX,radiusErrorBarsY,radiusErrorBarsMrkZ,radiusErrorBarsMode,radiusErrorBarsPercent,radiusErrorBarsConstant,radiusErrorBarsPlusWavePath,radiusErrorBarsMinusWavePath,radiusErrorBarsCapWidthStr)
//
//		WMPolarGetTraceAngleErrorBars(graphName,polarTraceName,angleErrorBarsX,angleErrorBarsY,angleErrorBarsMrkZ,angleErrorBarsMode,angleErrorBarsPercent,angleErrorBarsConstant,angleErrorBarsPlusWavePath,angleErrorBarsMinusWavePath,angleErrorBarsCapWidthStr)
//		WMPolarSetTraceAngleErrorBars(graphName,polarTraceName,angleErrorBarsX,angleErrorBarsY,angleErrorBarsMrkZ,angleErrorBarsMode,angleErrorBarsPercent,angleErrorBarsConstant,angleErrorBarsPlusWavePath,angleErrorBarsMinusWavePath,angleErrorBarsCapWidthStr)
//
// Version 7.05, JP170615, Added Alpha (transparency) support to fillToZero by adding fillAlpha parameter.
//
//		WMPolarGetPolarTraceSettings(graphName,polarTraceName,isFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue,fillYWaveName,fillXWaveName,fillAlpha=fillAlpha)
//		[make changes to any of isFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue,fillAlpha,fillYWaveName,fillXWaveName]
//		WMPolarSetPolarTraceSettings(graphName,polarTraceName,isFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue,fillYWaveName,fillXWaveName,fillAlpha=fillAlpha)
//
// Version 7.05, JP170809, Added graph userData(polarGraphSettings) to record the data folder name
//		to protect the polar graph from accidental deletion of the textbox/N=polarGraphSettings annotation
//		via DeleteAnnotations/A or DeleteAnnotations invisible.
//		Added WMPolarSaveSettingsName().
//
// Version 7.09, JP180819, Fixed problem of fill-to-zero tw[kFillToZeroAlpha] being transparent by default (it should have been set to opaque in WMPolarAppendTrace).
//
// Version 8.04, JP190425, fixed bug in WMPolarParseColorStr() where it set alpha to 0 for input that had no alpha component.
//		Added:
//		WMClosePolarGraph(graphName)
//		WMKillPolarGraphDataFolder(subfolderName)
//		CloseAllPolarGraphs(saveRecreationMacros, preserveClosedPolarGraphs)
//		JP190905: WMPolarSaveSettingsName() rewritten to update the textbox only if it exists and differs
//
// Version 8.041, JP191108, fixed data problems caused by running a recreation macro when the original polar graph is still open.
//		Now the recreated polar graph uses a clone of the original polar data folder. See PossiblyRelocateToNewDataFolder().
//		Added WMPolarCleanUnusedDFs(), which can be accessed from Igor's Data->Packages submenu when there are unused PolarGraph data folders.
//		Added graphName string to each polar graph data folder, in case the user renames the window, or recreates PolarGraph0 as PolarGraph0_1.

// Version 8.042, JP191111, automatically updates opaque label background if user changes the window plot area color.
// Version 9.0, JP210427: Renamed DataFolderList to WMDataFolderList because Igor 9 has a DataFolderList function.
// Version 9.01, JP210701: Added WMPolarEnsureSettingsDF() to fix problem in WMPolarSaveSettingsName() when a polar graph is first created.
// Version 9.02, JP230307: Added WMPolarMoveTraceToBottom(), fixed multi-line label opaque backgrounds, tweaked control positions.
//		Added grid background color, clipped background grid and fill-to-origin polygons to the polar graph's plot area.
//		Fixed Polar Grid Resolution panel's radio buttons
// Version 9.021, JP230314: Fixed Variable/G ill-formed name bug on initial display of first polar graph panel.
// Version 9.022, JP230316: added WMPolarDisconnectGraph() and WMPolarReconnectGraph().
// Version 9.024, JP230322: added font bold and font italic controls
// Version 9.03,  JP230412: rewritten to draw in virtual draw layers.
// Version 9.04,  JP231030: Fixed "Use Polar Settings from" when a non-virtual-drawn polar graph was selected.
//		Fixes to virtual draw layers code and to new controls.
// Version 9.05,  JP231102: Fixes to WMPolar_MainTab and to WMPolarPanelHook to fix missing controls or extra controls.
//		Fixed panel continuously upgrading if screen resolution is non-standard.
//		Using a non-zero valueAtCenter value now draws as expected for negative radii;
//		ValueAtCenter effectively "captures" radii whose absolute value is less than valueAtCenter.
//		An image-only polar graph calls WMPolarKeepWindowOnScreen().

#include <New Polar Graphs Init>, version >= 9.03
#include <New Polar Graphs Draw>, version >= 9.03
#include <New Polar Keep On Screen>, version >= 6.13
#include <New Polar Graphs Cursors>, version >= 9
#include <Virtual Drawing Layers>, version >= 9.03
#include <Graph Utility Procs>, version >=6.2

#include <SaveRestoreWindowCoords>, version >=7
#include <PopupWaveSelector>

Constant kPanelHeightPixels = 490 // previously 459	// panel units, actually

Constant kPolarCapMarkerNumber = 998			// radius error bars: SetWindow polarGraphName markerHook= {WMPolarErrorBarCapMarker, kPolarCapMarkerNumber,kPolarCapMarkerNumber}
Constant kPolarAngleCapMarkerNumber = 999		// 	angle error bars: SetWindow $graphName markerHook= {WMPolarErrorBarCapMarker, kPolarCapMarkerNumber, kPolarAngleCapMarkerNumber}

// Tab Pane Values
Static Constant kTabPrevious= -1, kTabMain=0, kTabRange=1, kTabAxes=2, kTabTicks=3, kTabLabels=4

// Column indexes into polarTracesTW text wave, also used in New Polar Graphs Draw
Constant kShadowTargetVariable=0
Constant kShadowTraceName=1, kShadowXWaveName=2
Constant kAutoRadiusTargetVariable= 3
Constant kRadiusWavePath=4, kAngleWavePath=5, kAngleUnits=6
Constant kRadiusMin=7, kRadiusMax=8
Constant kIsFillToZero=9, kFillToZeroLayer=10, kFillToZeroYWaveName=11, kFillToZeroXWaveName=12
Constant kFillToZeroRed=13, kFillToZeroGreen=14, kFillToZeroBlue=15
Constant kVersion404Columns=16				// version 4.04 kTWColumns, 0-15
// End of Version 4.04 Columns
// Start of Version 6.33 columns
Constant kFirstVersion633Column= 16			// Version 6.33 adds columns 16-24

// Error Bars (generally)
Constant kErrorBarsCapThickness= 16			// "1.0" (points) (this is mrkThick, the marker stroke width)
Constant kErrorBarsBarThickness= 17			// "1.0" (points)
Constant kErrorBarsColorFromTraceRadio = 18	//	"0" = from Trace not checked,  and Color checked, "1" = from Trace checked and Color unchecked
Constant kErrorBarsColorRedGreenBlue = 19	// Red, green, blue values, with optional opaque value separated by commas, normally 0,0,0,65535 (black[, opaque])
// Error Bars (radius)
Constant kRadiusErrorBarMinMaxStr= 20		// record the x,y range of the radius bars
Constant kRadiusErrorsBarsX = 21			// name of radius error bars X wave, polarRadiusErrorBarX0, etc
Constant kRadiusErrorsBarsY = 22			// name of radius error bars Y wave, polarRadiusErrorBarY0, etc
Constant kRadiusErrorsBarsMrkZ = 23		// name of radius error bars markers f(Z) wave, polarRadiusErrorBarZ0, etc
Constant kRadiusErrorBarsMode= 24		// None;% of radius;sqrt of radius;+constant;+/-constant;+/- wave;
StrConstant ksRadiusErrorBarsModes= "None;% of radius;sqrt of radius;+ constant;+/- constant;+/- wave;"
Constant kRadiusErrorBarsPercent=25			// 0-1000
Constant kRadiusErrorBarsConstant=26			// -inf - +inf if +constant, 0 - +inf if +/- constant (or just take abs if +/- constant)
Constant kRadiusErrorBarsPlusWavePath=27	// full data folder path to +wave or "_none_"
Constant kRadiusErrorBarsMinusWavePath=28	// full data folder path to -wave or "_none_" (there is no "same as Y+" feature)
Constant kRadiusErrorBarsCapWidth= 29		// ("Auto" else points, this is just the cap marker size, and must be kept up-to-date with msize)

Constant kVersion633Columns= 30		// as of Version 6.33 (Radius Error Bars only)
// Error Bars (angle)
// not implemented in 6.33, added in Version 7.02
Constant kFirstVersion702Column= 30		// Version 7.02 adds columns 30-38
Constant kAngleErrorsBarsX = 30			// name of angle error bars X wave, polarAngleErrorBarX0, etc
Constant kAngleErrorsBarsY = 31		// name of angle error bars Y wave, polarAngleErrorBarY0, etc
Constant kAngleErrorsBarsMrkZ = 32		// name of angle error bars markers f(Z) wave, polarAngleErrorBarZ0, etc
Constant kAngleErrorBarsMode= 33		// None;% of Angle;sqrt of Angle;+constant;+/-constant;+/- wave;
StrConstant ksAngleErrorBarsModes= "None;% of angle;sqrt of angle;+ constant;+/- constant;+/- wave;"
Constant kAngleErrorBarsPercent=34		// 0-1000
Constant kAngleErrorBarsConstant=35		// -inf - +inf if +constant, 0 - +inf if +/- constant (or just take abs if +/- constant)
Constant kAngleErrorBarsPlusWavePath=36	// full data folder path to +wave or "_none_"
Constant kAngleErrorBarsMinusWavePath=37// full data folder path to -wave or "_none_" (there is no "same as Y+" feature)
Constant kAngleErrorBarsCapWidth= 38		// ("Auto" else points, this is just the cap marker size, and must be kept up-to-date with msize)
Constant kVersion702Columns= 39			// 0..38 as of Version 7.02, which added radius error bars

// Fill to zero transparency
Constant kFillToZeroAlpha=39			// default is 65535 (opaque)

Constant kTWColumns=40		// 0..39 (Version 7.05 added kFillToZeroAlpha, optional ,alpha for kErrorBarsColorRedGreenBlue )

Menu "New", hideable
	"Polar Graph",/Q, WMPolarGraphs(0)
End

Menu "Graph", dynamic, hideable
	WMPolarEnableModifyPolarGraph(),/Q, WMPolarGraphs(-1)
	WMPolarCursorsMenu(),/Q, WMTogglePolarCursors()
	WMPolarLegendMenu(),/Q, AddOrUpdatePolarGraphLegend()
End

Menu "Data", dynamic, hideable
	Submenu "Packages"
		WMPolarEnableCleanDFs(), /Q, WMPolarCleanUnusedDFs()
	End
End

// You can #define POLAR_DEBUGGING in your procedure window(s) to enable these menu items.
// Or use
// 		SetIgorOption poundDefine=POLAR_DEBUGGING
// in a Macro or Proc (or inside Execute)

#ifdef POLAR_DEBUGGING
Menu "Graph", dynamic, hideable
	EnablePolarMenuItem("Toggle Polar Axes Visibility"),/Q, WMPolarShowHideAxes("",-1)
	EnablePolarMenuItem("Clean Drawing Layers"),/Q, WMPolarClearAllLayers("")
	EnablePolarMenuItem("Toggle Autoscale Trace Visibility"),/Q, WMPolarToggleAutoscaleTraceVis("")
End

Function/S EnablePolarMenuItem(String menuItem)

	if( WMPolarGraphDFExists("") == 0 )
		menuItem= ""	// disappears
	endif
	return menuItem
End

#endif

Function/S WMPolarEnableCleanDFs()

	String menuItem= "Delete Unused Polar Graph Data Folders"
	if( ItemsInList(UnusedPolarDFs()) == 0 )
		menuItem= ""	// disappears
	endif
	return menuItem
End

static Function/S UnusedPolarDFs()
	String unusedDFs=""

	String allDFs = WMPolarListPolarSubfolders()
	Variable i, n= ItemsInList(allDFs)
	for( i=0; i<n; i+=1 )
		String dfName= StringFromList(i,allDFs)
		if( CmpStr(dfName, "_default_") == 0 )
			continue
		endif
		String df= WMPolarSettingsDF(dfName)+":"
		WAVE/T/Z tw= $(df+"polarTracesTW")
		String graphName= WMPolarGraphForTW(tw) // can be "", consults open graphs and df+"graphName"
		Variable inUse = strlen(graphName) && (WinType(graphName) == 1 || GraphMacroExists(graphName))
		if( !inUse )
			unusedDFs += dfName+";"
		endif
	endfor

	return unusedDFs
End

// Call CleanUnusedPolarDFs() if there are data folders in root:Packages:WMPolarGraphs:* that you can't delete.
Function WMPolarCleanUnusedDFs()

	String dfList= UnusedPolarDFs()
	Variable i, n= ItemsInList(dfList)
	for( i=0; i<n; i+=1 )
		String dfName= StringFromList(i,dfList)
		String df= WMPolarSettingsDF(dfName)+":"
		WAVE/T/Z tw= $(df+"polarTracesTW")
		String graphName= WMPolarGraphForTW(tw) // can be ""
		WMPolarRemovePolarGraphData(graphName,dfName)
		// printing added for version 9.02
		if( DatafolderExists(df) )
			Print "Not removed (in use) "+df // something other than polar graphs is using the data folder.
		else
			Print "Removed "+df
		endif
	endfor
End


Function WMPolarGraphs(tabNum)
	Variable tabNum
	
	if( DataFolderExists(WMPolarDF()) == 0 )
		 WMPolarGraphGlobalsInit()
	endif
	DoWindow/F WMPolarGraphPanel	// if window position changes, runs the activate hook, which calls WMPolarPanelUpdate()
	if( !V_Flag )
		// create the panel
		WMPolar_NewPanel(kTabMain)
		WMPolarPanelUpdate(0)
	else
		WMPolarSwitchTab(tabNum)
	endif
End

Function WMPolarTabProc(name,tab)
	String name
	Variable tab
	
	WMPolarSwitchTab(tab)
End

Function WMPolarPanelNeedsRebuilding()

	Variable wrongHeight= 0
	DoWindow WMPolarGraphPanel
	if( V_Flag == 0 )
		return 0
	endif
	//	Always test for the latest-added control name
	// but test for a control that should always be present (main tab, probably)
	// test for a control that has always existed in the main tab
	ControlInfo/W=WMPolarGraphPanel mainAppendGroup
	Variable missingControls = V_Flag==0
	if( !missingControls ) // mainAppendGroup exists, tab has been initialized, perhaps new, perhaps old panel
		ControlInfo/W=WMPolarGraphPanel mainLayersButton	// newest control in main tab
		missingControls = V_Flag==0
	endif
	return missingControls
End

// WMPolarRebuildPanel should be called with:
//
// if( WMPolarPanelNeedsRebuilding() )
// 		Execute/P/Q/Z "WMPolarRebuildPanel()"
// endif
//
// because it kills and rebuilds WMPolarGraphPanel
Function WMPolarRebuildPanel()
	Print "\rUpgrading old Polar Graphs panel for new features..."
	// recreate the panel
	String path= WMPolarDFVar("prevTab")
	Variable tabNum= NumVarOrDefault(path, kTabMain)
	DoWindow/K WMPolarGraphPanel
	WMPolar_NewPanel(tabNum)
	Variable/G $path = tabNum	// for WMPolarPanelUpdate
	WMPolarPanelUpdate(0) // 0 avoids runaway recursion
End

// switch tabs - faster than WMPolarPanelUpdate(), but doesn't update all the controls to the current data folder.
// (use WMPolarPanelUpdate() to point the controls to the top graph's settings data folder.
// Don't call this without ensuring that the globals exist; call WMPolarGraphs(), instead.
// Should work if the panel isn't the top window.
Function WMPolarSwitchTab(tabNum)
	Variable tabNum

	NVAR prevTab= $WMPolarDFVar("prevTab")
	if( tabNum != kTabPrevious && tabNum != prevTab )
		// Enforce the proper panel height and controls
		Variable fixNeeded = WMPolarPanelNeedsRebuilding()
		if( fixNeeded )
 			Execute/P/Q/Z "WMPolarRebuildPanel()" // so that this will restore to the desired tab
		else
			TabControl commonPolarTab win= WMPolarGraphPanel, value=tabNum 
			WAVE/T tabNames= $WMPolarDFVar("tabNames")
			WMPolarShowHideMatchingControls("WMPolarGraphPanel",tabNames[prevTab]+"*", 0)	// hide previous
			SetDrawLayer/K/W=WMPolarGraphPanel UserBack		// erase any drawn stuff.
			switch( tabNum )
				case kTabMain:
					WMPolar_MainTab(1)
					break
				case kTabRange:
					WMPolar_RangeTab(1)
					break
				case kTabAxes:
					WMPolar_AxesTab(1)
					break
				case kTabTicks:
					WMPolar_TicksTab(1)
					break
				case kTabLabels:
					WMPolar_LabelsTab(1)
					break
			endswitch
		endif
		prevTab= tabNum
	endif
End

Function WMPolarPanelHook(infoStr)
	String infoStr

	Variable statusCode= 0
	String event= StringByKey("EVENT",infoStr)
	strswitch(event)
		case "activate":
			if( WMPolarPanelNeedsRebuilding() )
				Execute/P/Q/Z "WMPolarRebuildPanel()"
				return 0
			endif
			SVAR previousTopGraph= $WMPolarDFVAR("previousTopGraph")
			String topGraphNow= WMPolarTopPolarGraph()
			Variable removedTraces= WMPolarUpdateForRemovedWaves(topGraphNow)
			Variable needUpdate= !removedTraces
			if( needUpdate )
				Execute/P/Q/Z "WMPolarPanelUpdate(0)"
				return 0
			endif
			// handle partial updates here
			ControlInfo/W= WMPolarGraphPanel commonPolarTab
			WMPolarSwitchTab(V_Value)
			break
	endswitch
	
	Variable coordinateStatus= WC_WindowCoordinatesHook(infoStr)
	if( statusCode == 0 )
		statusCode= coordinateStatus
	endif

	return statusCode				// 0 if nothing done, else 1 or 2
End
 
// Call this to update the panel if you have any reason to think it may need updating.
// If you set possiblyFixPanel to non-zero, call with Execute/P 
Function WMPolarPanelUpdate(possiblyFixPanel)
	Variable possiblyFixPanel

	DoWindow WMPolarGraphPanel
	if( V_Flag == 0 )
		return 0
	endif
	if( possiblyFixPanel && WMPolarPanelNeedsRebuilding() )
		Execute/P/Q/Z "WMPolarRebuildPanel()"
		return 0
	endif

	String graphName= WMPolarTopPolarGraph()
	NVAR prevTab= $WMPolarDFVar("prevTab")
	Variable disable= 0	// that is, enabled.
	if( strlen(graphName) == 0 )
		SetDrawLayer/W=WMPolarGraphPanel/K UserBack		// erase any drawn stuff.
		prevTab= kTabMain
		disable= 2	// lock out the other tabs because there is no appropriate graph.
		Button commonUpdate, win=WMPolarGraphPanel, title="Update", disable=1	// hidden
	else
		Button commonUpdate, win=WMPolarGraphPanel, title="Update "+graphName, disable=0 // visible
	endif
	WMPolar_MainTab(prevTab == kTabMain)
	WMPolar_RangeTab(prevTab == kTabRange)
	WMPolar_AxesTab(prevTab == kTabAxes)
	WMPolar_TicksTab(prevTab == kTabTicks)
	WMPolar_LabelsTab(prevTab == kTabLabels)
	TabControl commonPolarTab win=WMPolarGraphPanel, disable=disable
	// record these values to prevent the activate hook from needlessly updating the panel
	String/G $WMPolarDFVAR("previousTopGraph")= graphName
	String/G $WMPolarDFVAR("previousDataFolder")=  GetDataFolder(1)

End


Function WMPolar_NewPanel(tabNum)
	Variable tabNum
	
	// restore from previous position
	Variable defLeft=477	// pixels
	Variable defTop= 45
	Variable defRight= 792
	Variable defBottom= defTop + kPanelHeightPixels
	// enforce larger 9.03 height
	Variable defWidth= defRight- defLeft
	Variable defHeight= defBottom- defTop
	Variable vLeft, vTop, vRight, vBottom
	if( WC_WindowCoordinatesGetNums("WMPolarGraphPanel", defLeft, defTop, vRight, vBottom) )	// points
		defLeft *= ScreenResolution/PanelResolution("")
		defTop *= ScreenResolution/PanelResolution("")
		defRight= defLeft + defWidth
		defBottom= defTop + defHeight
	endif
	DoWindow/K WMPolarGraphPanel
	NewPanel/K=1/W=(defLeft,defTop,defRight,defBottom)/N=WMPolarGraphPanel as "Polar Graphs"

	ModifyPanel/W=WMPolarGraphPanel fixedSize=1, noEdit=1
	SetWindow WMPolarGraphPanel hook=WMPolarPanelHook
	DefaultGUIFont/W=WMPolarGraphPanel popup={"_IgorSmall",0,0}, button={"_IgorMedium",0,0}

	// Common
	TabControl commonPolarTab win=WMPolarGraphPanel, pos={2,4},size={309,460}, tabLabel(0)="Main", tabLabel(1)="Range",tabLabel(2)="Axes",tabLabel(3)="Ticks",tabLabel(4)="Labels"
	TabControl commonPolarTab win=WMPolarGraphPanel, value= tabNum, proc= WMPolarTabProc

	Button commonHelpButton win=WMPolarGraphPanel, pos={5,466},size={50,20},title="Help", proc=WMPolarCloseHelpButtons
	Button commonUpdate win=WMPolarGraphPanel, pos={64,466},size={148,20},proc=WMPolarUpdateButtonProc,title="Update PolarGraph0", disable=1	// initially hidden
	CheckBox commonDelayUpdate win=WMPolarGraphPanel, pos={219,469},size={80,14},title="Delay Update"
	CheckBox commonDelayUpdate win=WMPolarGraphPanel, variable=$WMPolarDFVar("delayPolarUpdate")
End

Function WMPolarUpdateButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String graphName= WMPolarTopPolarGraph()
	WMPolarBlockModifiedWindowHook(graphName,0)	// just in case the modified hook blocking gets out of sync
	WMPolarUpdateShadowWave(graphName,$"")	// all of them; this allows updating traces that can't auto-update because the wave names are too long.

	WMPolarAxesRedrawTopGraphNow()	// regardless of DelayUpdate setting
End

Function WMPolarDelayUpdate()
	
	NVAR delayPolarUpdate= $WMPolarDFVar("delayPolarUpdate")
	return delayPolarUpdate
End

Function WMPolarCloseHelpButtons(ctrlName) : ButtonControl
	String ctrlName

	strswitch(ctrlName)
		case "commonCloseButton":
			DoWindow/K WMPolarGraphPanel
			break
		case "commonHelpButton":
			NVAR prevTab= $WMPolarDFVar("prevTab")
			WAVE/T tabNames= $WMPolarDFVar("tabNames")
			String topic="Polar Graphs["+tabNames[prevTab]+" Tab]"
			DisplayHelpTopic/K=1 topic
			break
	endswitch
End

// control names must start with "main"
Function WMPolar_MainTab(show)
	Variable show
	
	Variable disable= show ? 0 : 1	// 0 is show, 1 is hide, 2 is show disabled.
	String graphName= WMPolarTopPolarGraph()
	Variable appendDisable= disable
	if( show )
		ControlInfo/W=WMPolarGraphPanel commonPolarTab
		if( V_Value != kTabMain )		// avoid flashing
			TabControl commonPolarTab win= WMPolarGraphPanel, value= kTabMain
		endif
		if( strlen(graphName) == 0 )	// nothing to append to  (or remove from)
			appendDisable= 1
		endif
	endif

	// New
	GroupBox mainNewGroup win= WMPolarGraphPanel, pos={10,30},size={290,80},title="New",  disable=disable
	PopupMenu mainNewStylePop win= WMPolarGraphPanel, pos={28,52},size={209,20},title="Use Polar Settings from:",  disable=disable
	Variable whichOne = 1 // "_default_"
	ControlInfo/W=WMPolarGraphPanel mainNewStylePop
	if( V_Flag == 3 )
		String polarGraphsList= "_default_;"+ WMPolarListPolarGraphs(1)
		whichOne = 1+max(0,WhichListItem(S_Value, polarGraphsList)) // added max in case mainNewStylePop was set to a now-deleted polar graph.
	endif
	//	PopupMenu mainNewStylePop win= WMPolarGraphPanel, value= #"\"_default_;\"+WMPolarListPolarGraphs(1)"
	String moduleName= GetIndependentModuleName()+"#"
	String command= "\"_default_;\"+" + moduleName+"WMPolarListPolarGraphs(1)"
	PopupMenu mainNewStylePop win= WMPolarGraphPanel, mode=whichOne, value= #command	// this value=#str format requires Igor 6
	Button mainNewPolarGraphButton win= WMPolarGraphPanel, pos={138,82},size={122,20},title="New Polar Graph",  disable=disable, proc=WMPolarNewButton

	// Append
	GroupBox mainAppendGroup win= WMPolarGraphPanel, pos={10,117},size={289,140},title="Append to "+graphName,  disable=appendDisable

	// +++++ radius wave selector button
	TitleBox mainAppendRadiusTitle, win= WMPolarGraphPanel, pos={33,143},size={66,16}, title="Radius Data:"
	TitleBox mainAppendRadiusTitle, win= WMPolarGraphPanel, frame=0,anchor=RT, disable=appendDisable
	
	Button mainAppendRadiusDataPop, win= WMPolarGraphPanel, pos={105,141},size={180,20},disable=appendDisable
	
	Variable popInitialized = WMPolarWavePopupIsInitialized("WMPolarGraphPanel", "mainAppendRadiusDataPop")
	if( !popInitialized )
		Button mainAppendRadiusDataPop, win= WMPolarGraphPanel, title="\\JRradius \\W623"
		command= "WMPolarWavePopupSelectorNotify"	// don't use GetIndependentModuleName()+"#": FUNCRefs aren't cross-IM
		MakeButtonIntoWSPopupButton("WMPolarGraphPanel", "mainAppendRadiusDataPop", command)
		command= "WMPolarWavePopupSelectorFilter"
		PopupWS_MatchOptions("WMPolarGraphPanel", "mainAppendRadiusDataPop", nameFilterProc=command)
	endif

	// +++++ angle wave (or _X Scaling_) selector button
	TitleBox mainAppendAngleTitle, win= WMPolarGraphPanel,pos={38,174},size={61,16}, title="Angle Data:"
	TitleBox mainAppendAngleTitle, win= WMPolarGraphPanel,frame=0,anchor=RT, disable=appendDisable
	
	Button mainAppendAngleDataPop, win= WMPolarGraphPanel, pos={105,172},size={180,20},disable=appendDisable
	
	popInitialized = WMPolarWavePopupIsInitialized("WMPolarGraphPanel",  "mainAppendAngleDataPop")
	if( !popInitialized )
		Button mainAppendAngleDataPop, win= WMPolarGraphPanel,title="\\JR_X Scaling_ \\W623"
		command= "WMPolarWavePopupSelectorNotify"	// don't use GetIndependentModuleName()+"#": FUNCRefs aren't cross-IM
		MakeButtonIntoWSPopupButton("WMPolarGraphPanel", "mainAppendAngleDataPop", command)
		command= "WMPolarWavePopupSelectorFilter"
		PopupWS_MatchOptions("WMPolarGraphPanel", "mainAppendAngleDataPop", nameFilterProc=command)
		PopupWS_AddSelectableString("WMPolarGraphPanel", "mainAppendAngleDataPop", "_X Scaling_")
		PopupWS_SetSelectionFullPath("WMPolarGraphPanel", "mainAppendAngleDataPop", "_X Scaling_")
	endif
	
	Variable anglePerCircle= WMPolarGetVar("anglePerCircle")
	CheckBox mainAppendAngleDataRadiansRadio win= WMPolarGraphPanel, pos={102,202},size={55,14},title="Radians",value=(anglePerCircle != 360),mode=1,  proc=WMPolarMainRadDegRadioProc, disable=appendDisable
	CheckBox mainAppendAngleDataDegreesRadio win= WMPolarGraphPanel, pos={177,202},size={56,14},title="Degrees",value= (anglePerCircle == 360),mode=1, proc=WMPolarMainRadDegRadioProc, disable=appendDisable

	// Append Trace button
	Variable appendButtonDisable= appendDisable == 0 ? 2 : 1 // initially disabled (no selection)
	
	if( show && popInitialized && appendDisable != 1 )
		String pathToRadiusWave= PopupWS_GetSelectionFullPath("WMPolarGraphPanel", "mainAppendRadiusDataPop")
		WAVE/Z appendRadius=$pathToRadiusWave
		if( WaveExists(appendRadius) )
			String pathToAngleWaveOrXScaling= PopupWS_GetSelectionFullPath("WMPolarGraphPanel", "mainAppendAngleDataPop")
			if( CmpStr(pathToAngleWaveOrXScaling, "_X Scaling_") == 0 )
				appendButtonDisable = 0 // enabled
			else 
				WAVE/Z appendAngleData=$pathToAngleWaveOrXScaling	// NULL if = "_calculated_" or "_X Scaling_"
				if( WaveExists(appendRadius) )
					appendButtonDisable = 0 // enabled
				endif
			endif
		endif
	endif
	Button mainAppendButton win= WMPolarGraphPanel, pos={191,228},size={94,20},title="Append Trace",  proc=WMPolarMainAppendButton, disable=appendButtonDisable

	// Append Image...  or Remove Image button
	Button mainPrepareOrRemoveImage win= WMPolarGraphPanel, pos={31,228},size={100,20}, disable=appendDisable

	Variable appendImageDisable = appendDisable
	// allow only one image per polar graph, so we have either Append Image... or Remove Image
	WAVE/Z polarGraphImage= WMPolarGraphGetImage(graphName, 0)
	if( WaveExists(polarGraphImage) ) // showing enabled, but already have an image in the graph
		Button mainPrepareOrRemoveImage win= WMPolarGraphPanel,title="Remove Image",proc=WMPolarRemoveImageProc
	else
		Button mainPrepareOrRemoveImage win= WMPolarGraphPanel,title="Append Image...",proc=WMPolarPrepareImageForAppendProc
	endif

	// Modify Polar Traces
	Variable modifyDisable= appendDisable
	String traces= WMPolarTraceNameList(0)
	Variable mode=1	// first trace by default
	String polarTraceName=""
	
	if( strlen(traces) == 0 )
		modifyDisable= 1
	else
		ControlInfo/W=WMPolarGraphPanel mainModifyTracePop
		if( V_Flag == 3 )	// get current item number
			mode= max(1,V_Value)
			polarTraceName=StringFromList(mode-1,traces)
		endif
	endif
	GroupBox mainModifyTraceGroup win= WMPolarGraphPanel, pos={10,276},size={288,131},title="                                                               ",  disable=modifyDisable

	PopupMenu mainModifyTracePop win= WMPolarGraphPanel, pos={33,275},size={253,20},bodyWidth= 190
	PopupMenu mainModifyTracePop win= WMPolarGraphPanel, title="Polar Trace:",  disable=modifyDisable
	command= moduleName+"WMPolarTraceNameList(1)"
	PopupMenu mainModifyTracePop win= WMPolarGraphPanel, mode=mode, value=#command,proc=WMPolarMainTracePopup

	// Get popup help text to show source data for the selected polar trace
	String help = PolarTraceSources(WMPolarTopPolarGraph(),polarTraceName)
	PopupMenu mainModifyTracePop win= WMPolarGraphPanel, help={help}
	// Position Fill to Zero controls, and set up procs
	GroupBox mainFillToOriginGroup win= WMPolarGraphPanel, pos={19,302},size={269,74},title="                             ",  disable=modifyDisable
	
 	CheckBox mainTraceFillToOrigin win= WMPolarGraphPanel,pos={37,303},size={82,14},proc=WMPolarMainFillToOriginRadio,title="Fill to Origin",  disable=modifyDisable

	CheckBox mainFillBehind win= WMPolarGraphPanel,pos={37,328},size={119,14},proc=WMPolarMainFillToOriginRadio,title="Behind Grid and Axes",mode=1,  disable=modifyDisable

	CheckBox mainFillInFront win= WMPolarGraphPanel,pos={37,351},size={138,14},proc=WMPolarMainFillToOriginRadio,title="In Front of Grid and Axes",mode=1,  disable=modifyDisable

	PopupMenu mainFillToOriginColor win= WMPolarGraphPanel,pos={177,326},size={106,20},title="Fill Color:",  disable=modifyDisable
	PopupMenu mainFillToOriginColor win= WMPolarGraphPanel,mode=1,popColor= (0,0,0),value= #"\"*COLORPOP*\"",proc=WMPolarMainFillToOriginColorPop

	// Igor 6.33: (Radius) Error Bars... button
	Button mainErrorBars,win= WMPolarGraphPanel,pos={37,382}, size={80,20},proc=WMPolarErrorBarsPanelButtonProc,title="Error Bars...", disable=modifyDisable
	
	Button mainRemoveButton win= WMPolarGraphPanel, pos={192,382},size={94,20},title="Remove Trace",  proc= WMPolarMainRemoveButton, disable=modifyDisable
	
	// Update Fill to Zero controls
	if( modifyDisable == 0 )
		WMPolarUpdatePolarTraceControls(graphName,polarTraceName)
	endif
	
	// 9.03: Layers... button, disable
	Button mainLayersButton,win= WMPolarGraphPanel, pos={115,426},size={80,20},proc=WMPolarLayersPanelButtonProc,disable=appendDisable
	Button mainLayersButton,win= WMPolarGraphPanel, title="Layers..."
	Button mainLayersButton,win= WMPolarGraphPanel, help={"Sets drawing layer(s) used for the axes, grid, and labels"}
	
End

Function WMPolarWavePopupIsInitialized(hostWindow, ctrlName)
	String hostWindow, ctrlName
	String userData = GetUserData(hostWindow, ctrlName, "popupWSInfo")
	return strlen(userData)
End


Function WMPolarWavePopupSelectorNotify(event, wavepath, windowName, buttonName)
	Variable event		// WMWS_SelectionChanged
	String wavepath
	String windowName	// panel name
	String buttonName	// "mainAppendRadiusDataPop" or "mainAppendAngleDataPop"
	
	Wave/Z w= $wavepath

	strswitch( buttonName )
		case "mainAppendRadiusDataPop":
			Variable appendButtonDisable = WaveExists(w) ? 0 : 2
			Button mainAppendButton win= $windowName, disable=appendButtonDisable
			break
		case "mainAppendAngleDataPop":
			break
	endswitch
End

Function WMPolarWavePopupSelectorFilter(fullPathToWave, contentsCode)
	String fullPathToWave
	Variable contentsCode	// WMWS_Waves or WMWS_DataFolders
	
	if( contentsCode != WMWS_Waves )
		return 0
	endif

	WAVE/Z w= $fullPathToWave
	return WMPolarWaveIsAcceptable(w)
End

// must be numeric, can't be complex or two-dimensional. 
static Function WMPolarWaveIsAcceptable(w)
	Wave/Z w
	
	Variable wt= WaveType(w,1)	// a new kind of waveType
	Variable acceptable= (wt == 1) // numeric
	if( acceptable ) 
		//  must have more than 1 row, less than 2 columns, 0 or 1 layers, and 0 or 1 chunks
		acceptable= DimSize(w,0) > 1 && DimSize(w,1) <= 1 && DimSize(w,2) <= 1 && DimSize(w,3) <= 1
		if( acceptable )
			wt= WaveType(w)	// standard kind of waveType
			Variable waveIsComplex = wt & 0x01
			acceptable= !waveIsComplex
		endif
	endif
	return acceptable
End

Function WMPolarPrepareImageForAppendProc(ctrlName) : ButtonControl
	String ctrlName

	WMPolarShowImageScalingPanel($"")
End


Function WMPolarRemoveImageProc(ctrlName) : ButtonControl
	String ctrlName

	String graphName= WMPolarTopPolarGraph()
	if( strlen(graphName) )
		// Don't append image to top polar graph if it already has an image
		WAVE/Z polarGraphImage= WMPolarGraphGetImage(graphName, 0)
		if( WaveExists(polarGraphImage) )
			RemoveImage/W=$graphName $NameOfWave(polarGraphImage)
			Modifygraph/W=$graphName margin=0 // auto
			WMPolarPanelUpdate(0)		// update Add/Remove Image button.
		endif
	endif
End

Function WMPolarErrorBarsPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/F WMPolarErrorBarsPanel
	if( V_Flag == 0 )
		WMPolarShowErrorBarsPanel()
	endif
End


Function WMPolarMainFillToOriginColorPop(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String graphName= WMPolarTopPolarGraph()
	ControlInfo/W=WMPolarGraphPanel mainModifyTracePop
	String polarTraceName= S_Value

	Variable isFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue,fillAlpha
	String fillYWaveName,fillXWaveName
	String df= WMPolarGetPolarTraceSettings(graphName,polarTraceName,isFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue,fillYWaveName,fillXWaveName,fillAlpha=fillAlpha)
	if( strlen(df) )
		ControlInfo/W=WMPolarGraphPanel $ctrlName
		fillRed= V_Red
		fillGreen= V_Green
		fillBlue= V_Blue
		fillAlpha= V_Alpha
		WMPolarSetPolarTraceSettings(graphName,polarTraceName,isFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue,fillYWaveName,fillXWaveName,fillAlpha=fillAlpha)
		WMPolarModifyFillToOrigin(graphName,polarTraceName)
		WMPolarAxesRedrawTopGraph()
	endif
End

 // this works for radio buttons, too
Function WMPolarMainFillToOriginRadio(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	String graphName= WMPolarTopPolarGraph()
	ControlInfo/W=WMPolarGraphPanel mainModifyTracePop
	String polarTraceName= S_Value

	Variable isFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue
	String fillYWaveName,fillXWaveName
	String df= WMPolarGetPolarTraceSettings(graphName,polarTraceName,isFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue,fillYWaveName,fillXWaveName)
	if( strlen(df) )
		Variable changed= 0
		ControlInfo/W=WMPolarGraphPanel $ctrlName
		strswitch(ctrlName)
			case "mainTraceFillToOrigin":
				if( checked != isFillToOrigin )
					isFillToOrigin= checked
					changed= 1
				endif
				break
			case "mainFillInFront":
				checked = !checked
				// FALL THROUGH
			case "mainFillBehind":
				if( checked != isFillBehind )
					changed= 1
					isFillBehind= checked
				endif
				break
		endswitch
		if( !changed )
			return -1
		endif
		
		WMPolarSetPolarTraceSettings(graphName,polarTraceName,isFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue,fillYWaveName,fillXWaveName)
		WMPolarUpdatePolarTraceControls(graphName,polarTraceName)
		WMPolarModifyFillToOrigin(graphName,polarTraceName)
	endif

	WMPolarAxesRedrawTopGraph()
End


Function WMPolarMainTracePopup(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String graphName= WMPolarTopPolarGraph()
	WMPolarUpdatePolarTraceControls(graphName,popStr)
End

// NOTE: DOES NOT UPDATE THE Polar Trace POPUP ITSELF! (this routine is CALLED from the trace popup proc)
Function WMPolarUpdatePolarTraceControls(graphName,polarTraceName)
	String graphName,polarTraceName
 
	// Save for polarTraceName for WMPolarShowErrorBarsPanel()
	String/G $WMPolarDFVAR("polarTrace")= polarTraceName
	
	// Polar Trace
	// Get popup help text to show source data for the selected polar trace
	String help = PolarTraceSources(graphName,polarTraceName)
	PopupMenu mainModifyTracePop win= WMPolarGraphPanel, help={help}
 	// Fill to Zero
	Variable isFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue,fillAlpha
	String fillYWaveName,fillXWaveName
	String df= WMPolarGetPolarTraceSettings(graphName,polarTraceName,isFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue,fillYWaveName,fillXWaveName,fillAlpha=fillAlpha)
	Variable modifyDisable= strlen(df) ? 0 : 2
	
	GroupBox mainFillToOriginGroup win= WMPolarGraphPanel, disable=modifyDisable
	CheckBox mainTraceFillToOrigin win= WMPolarGraphPanel, value= isFillToOrigin, disable=modifyDisable
	
	Variable fillToOriginDisable= modifyDisable
	if( fillToOriginDisable == 0 )
		fillToOriginDisable= isFillToOrigin ?  0 : 2	// visible disabled if fillToOrgin isn't checked.
	endif
	
	CheckBox mainFillBehind win= WMPolarGraphPanel, value= isFillBehind, disable=fillToOriginDisable
	CheckBox mainFillInFront win= WMPolarGraphPanel, value= !isFillBehind, disable=fillToOriginDisable
	PopupMenu mainFillToOriginColor win= WMPolarGraphPanel, popColor= (fillRed,fillGreen,fillBlue,fillAlpha), disable=fillToOriginDisable
	
	// Error Bars
	Button mainErrorBars win= WMPolarGraphPanel, disable=modifyDisable
	
 	return modifyDisable
End

// Remove any radius data wave name from polarTraceName.
// For example, change "polarY0 [radiusData]" into "polarY0".
Function/S WMPolarOnlyTraceName(polarTraceName)
	String polarTraceName
	
	Variable extraStuffPos= strsearch(polarTraceName," [",0)
	if( extraStuffPos >= 0 )
		polarTraceName[extraStuffPos,999]=""
	endif
	
	return polarTraceName	// just "polarY0", also called "the shadow wave", because it shadows (depends on) the user's radius and angle waves/scaling.
End
 
// returns "" if the named polar trace doesn't exist in the graph
// returns path to tw wave's data folder if it does.
Function/S WMPolarGetPolarTraceSettings(graphName,polarTraceName,isFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue,fillYWaveName,fillXWaveName[,fillAlpha])
	String graphName			// input
	String &polarTraceName		// input/output: polarTraceName is the name of the shadow wave displayed in graphName; any " [radiusWaveName]" is removed.
	Variable &isFillToOrigin, &isFillBehind, &fillRed, &fillGreen, &fillBlue	// outputs
	String &fillYWaveName,&fillXWaveName	// outputs
	Variable &fillAlpha // 7.05: optional output

	isFillToOrigin=0
	isFillBehind=0
	fillRed=0
	fillGreen=0
	fillBlue=0
	fillYWaveName=""
	fillXWaveName=""
	if( !ParamIsDefault(fillAlpha) )
		fillAlpha= 65535
	endif
	
	String path= ""
	WAVE/Z/T tw= $WMPolarGraphTracesTW(graphName)
	
	if( WaveExists(tw) )		// this describes the graph's traces
	 	polarTraceName= WMPolarOnlyTraceName(polarTraceName)	// changes the input parameter!!!!
		WAVE/Z wShadowY= TraceNameToWaveRef(graphName,polarTraceName)
		if( WaveExists(wShadowY) )
			Variable row= WMPolarShadowWaveRow(wShadowY)
			if( row != -1 )		// this wave was found in polarTracesTW
				isFillToOrigin= strlen(tw[row][kIsFillToZero]) > 0
				String layer=tw[row][kFillToZeroLayer]
				strswitch(layer)
					case "front":
						isFillBehind=0
						break
					case "back":
						isFillBehind=1
						break
					default:
						isFillToOrigin= 0
						break
				endswitch
				fillRed= str2num(tw[row][kFillToZeroRed])
				fillGreen= str2num(tw[row][kFillToZeroGreen])
				fillBlue= str2num(tw[row][kFillToZeroBlue])
				if( !ParamIsDefault(fillAlpha) )
					fillAlpha= str2num(tw[row][kFillToZeroAlpha])
				endif
				fillYWaveName=tw[row][kFillToZeroYWaveName]
				fillXWaveName= tw[row][kFillToZeroXWaveName]

				path= GetWavesDataFolder(tw,1)
			endif
		endif
	endif

	return path
End

// Usage:
//	modifyDisable= WMPolarGetPolarTraceSettings(graphName,polarTraceName,isFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue,fillYWaveName,fillXWaveName,fillAlpha=fillAlpha)
//		[make changes to any of isFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue,fillAlpha,fillYWaveName,fillXWaveName]
//	WMPolarSetPolarTraceSettings(graphName,polarTraceName,isFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue,fillYWaveName,fillXWaveName,fillAlpha=fillAlpha)
//
// returns "" if the named polar trace doesn't exist in the graph
// returns path to tw wave's data folder if it does.
//
Function/S WMPolarSetPolarTraceSettings(graphName,polarTraceName,isFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue,fillYWaveName,fillXWaveName[,fillAlpha])
	String graphName			// input
	String &polarTraceName		// input/output polarTraceName is the name of the shadow wave displayed in graphName; any " [radiusWaveName]" is removed.
	Variable isFillToOrigin, isFillBehind, fillRed, fillGreen, fillBlue	// inputs
	String fillYWaveName,fillXWaveName	// inputs
	Variable fillAlpha // optional input

	String path= ""

	WAVE/Z/T tw= $WMPolarGraphTracesTW(graphName)
	if( WaveExists(tw) )		// this describes the graph's traces
		polarTraceName= WMPolarOnlyTraceName(polarTraceName)	// changes the input parameter!!!!
		WAVE/Z wShadowY= TraceNameToWaveRef(graphName,polarTraceName)
		if( WaveExists(wShadowY) )
			Variable row= WMPolarShadowWaveRow(wShadowY)
			if( row != -1 )		// this wave was found in polarTracesTW
				if( isFillToOrigin )
					tw[row][kIsFillToZero]= "Yes"
				else
					tw[row][kIsFillToZero]= ""		// don't use "No" here, we test with strlen(tw[row][kIsFillToZero]) > 0
				endif

				String layer= ""
				if(isFillBehind )
					layer= "back"
				else
					layer= "front"
				endif					
				tw[row][kFillToZeroLayer]= layer

				tw[row][kFillToZeroRed]= num2istr(fillRed)
				tw[row][kFillToZeroGreen]= num2istr(fillGreen)
				tw[row][kFillToZeroBlue]= num2istr(fillBlue)
				if( !ParamIsDefault(fillAlpha) )
					tw[row][kFillToZeroAlpha]= num2istr(fillAlpha) // it is useful (easier) to not set fillAlpha=fillAlpha if we're updating non-fill polar settings
				endif
				tw[row][kFillToZeroYWaveName]= fillYWaveName
				tw[row][kFillToZeroXWaveName]= fillXWaveName
				
				path= GetWavesDataFolder(tw,1)
			endif
		endif
	endif

	return path
End

// see also WMPolarModifyFillToOrigin() which sets up the polygon and it's appearance
Function WMPolarUpdateFillToOrigin(wShadowX,wShadowY)	
	Wave wShadowX,wShadowY

	Variable row= WMPolarShadowWaveRow(wShadowY) // Returns the row in the polarTracesTW text wave, or -1 if not found
	if( row != -1 )		// this wave was found in polarTracesTW
		String df= GetWavesDataFolder(wShadowY,1)	// we rely on the fact that the shadow wave and the polarTracesTW wave are in the same data folder
		WAVE/T/Z tw= $(df+"polarTracesTW")
	
		if( WaveExists(tw) )
			String isFill= tw[row][kIsFillToZero]
			String fillYWaveName= tw[row][kFillToZeroYWaveName]
			if( strlen(isFill) > 0 && strlen(fillYWaveName) > 0 )	// the polygon is assumed to exist; See WMPolarModifyFillToOrigin.
				String fillToZeroYWavePath=  df+fillYWaveName
				String fillToZeroXWavePath=  df+tw[row][kFillToZeroXWaveName]
				
				Duplicate/O wShadowX, $fillToZeroXWavePath
				WAVE fillX= $fillToZeroXWavePath
				Duplicate/O wShadowY, $fillToZeroYWavePath
				WAVE fillY= $fillToZeroYWavePath
				
				Variable n= numpnts(wShadowY)
				InsertPoints n, 1, fillX ,fillY
			
				Variable originX=0	// drawn coordinates
				Variable originY=0
				fillX[n]=originX
				fillY[n]=originY
				InsertPoints 0, 1, fillX ,fillY
				fillX[0]=originX
				fillY[0]=originY
			endif
		endif
	endif
	return row
end

// used in the polar trace popup menu; don't change this interface
Function/S WMPolarTraceNameList(showSourceWave)	// only polar traces, no others
	Variable showSourceWave
	
	String graphName= WMPolarTopPolarGraph()
	String list= WMPolarTraceNameListForGraph(graphName,showSourceWave)
	return list
End

Function/S WMPolarTraceNameListForGraph(graphName,showSourceWave)	// only polar traces, no others
	String graphName
	Variable showSourceWave
	
	String list=""
	
	WAVE/Z/T tw= $WMPolarGraphTracesTW(graphName)
	
	if( WaveExists(tw) )		// there is a top polar graph, and this describes its traces
		Variable row,i=0
		do
			WAVE/Z w= WaveRefIndexed(graphName,i,1) 	// Waves in top polar graph
			if( !WaveExists(w) )
				break
			endif
	
			row= WMPolarShadowWaveRow(w)
			if( row != -1 )		// this wave was found in polarTracesTW
				String item= NameOfWave(w)
				if( showSourceWave )
					String radiusPath= tw[row][kRadiusWavePath]
					String fileName= ParseFilePath(0,radiusPath,":",1,0)
					item += " ["+fileName+"]"
				endif
				list += item+";"
			endif
			i += 1
		while( 1 )
	endif
	return list
End

Function/S WMPolarWaveList()	// excludes text waves

	String list=""
	Variable i=0
	do
		WAVE/Z w= WaveRefIndexed("",i,4) 	// Waves in current data folder only
		if( !WaveExists(w) )
			break
		endif
		// we want only 1D numeric waves (and not complex, either: 4.05 12/7/01)
		if( DimSize(w,1) == 0 && WaveType(w) != 0  && !(WaveType(w) %& 1) )
			list += NameOfWave(w)+";"
		endif
		i += 1
	while( 1 )
	return list
End


Function/S WMPolarWaveListOrNone()	// excludes text waves

	String list=WMPolarWaveList()
	if( strlen(list) == 0 )
		list= "_none_"
	endif
	return list
End

Function/S WMPolarWaveListAndNone()	// excludes text waves

	String list= "_none_;"+WMPolarWaveList()
	return list
End


Function WMPolarMainRadDegRadioProc(name,value)
	String name
	Variable value
	
	Variable radioVal
	
	strswitch (name)
		case "mainAppendAngleDataRadiansRadio":
			radioVal= 1
			break
		case "mainAppendAngleDataDegreesRadio":
			radioVal= 2
			break
	endswitch
	CheckBox mainAppendAngleDataRadiansRadio win= WMPolarGraphPanel, value= radioVal == 1
	CheckBox mainAppendAngleDataDegreesRadio win= WMPolarGraphPanel, value= radioVal == 2
	
	WMPolarSetVar("anglePerCircle", (radioVal==1) ?  2*pi  :  360)
End

// Based on PolarAppendWaves
Function WMPolarMainAppendButton(ctrlName) : ButtonControl
	String ctrlName

	String pathToRadiusWave= PopupWS_GetSelectionFullPath("WMPolarGraphPanel", "mainAppendRadiusDataPop")
	WAVE/Z appendRadius=$pathToRadiusWave

	String pathToAngleWaveOrXScaling= PopupWS_GetSelectionFullPath("WMPolarGraphPanel", "mainAppendAngleDataPop")
	WAVE/Z appendAngleData=$pathToAngleWaveOrXScaling	// NULL if = "_calculated_" or "_X Scaling_"
	
	Variable anglePerCircle= WMPolarGetVar("anglePerCircle")
	
	String graphName= WMPolarTopPolarGraph()
	WMPolarAppendTrace(graphName, appendRadius, appendAngleData, anglePerCircle)
End

Function/WAVE WMPolarEnsurePolarGraphTracesWave(graphName)
	String graphName
	
	String df= WMPolarSetPolarGraphDF(graphName)	// OLD data folder
	if( strlen(df) == 0 )	// couldn't find NEW polar data folder for graphName, data folder wasn't changed.
		return $""
	endif

	WAVE/Z/T tw= WMPolarEnsurePolarTracesWave()
	SetDataFolder df

	return tw
End

//
// Maintains a multi-column text wave, each row pertains to a polar graph trace whose traceName is in the first column.
//
//		WARNING:	Make sure WMPolarEnsurePolarTracesWave() is called ONLY when the current data folder
//					is properly set by, for example:
//
//					String df= WMPolarSetPolarGraphDF(graphName)	// returns OLD data folder, sets to polar data folder.
//
//		OR just call:
//
//					WAVE/Z/T tw= WMPolarEnsurePolarGraphTracesWave(graphName)
//
Function/WAVE WMPolarEnsurePolarTracesWave()

	WAVE/Z/T tw= polarTracesTW
	if( WaveExists(tw) == 0 || DimSize(tw,0) == 0 )	// deleting the last row from polarTracesTW collapses the dimensionality to 1D, 0 rows.
		// create version 4.04 columns
		Make/O/T/N=(0,kVersion404Columns) polarTracesTW
		WAVE/T tw=polarTracesTW
		// label the columns for debugging purposes
		SetDimLabel 1, 0, shadowTargetVariable, tw
		SetDimLabel 1, 1, shadowTraceName, tw	// also shadowYWaveName
		SetDimLabel 1, 2, shadowXWaveName, tw
		
		SetDimLabel 1, 3, radiusTargetVariable, tw
		SetDimLabel 1, 4, radiusWavePath, tw
		
		SetDimLabel 1, 5, angleWavePath, tw
		SetDimLabel 1, 6, angleUnits, tw
		
		SetDimLabel 1,7, radiusMin, tw
		SetDimLabel 1,8, radiusMax, tw

		SetDimLabel 1,9, isFill2Origin, tw
		SetDimLabel 1,10, fillLayer, tw
		SetDimLabel 1,11, fillY, tw
		SetDimLabel 1,12, fillX, tw
		SetDimLabel 1,13, fillRed, tw
		SetDimLabel 1,14, fillGreen, tw
		SetDimLabel 1,15, fillBlue, tw
	endif
	
	if( WaveExists(tw) && (DimSize(tw,1) < kTWColumns) )
		Variable originalColumns= DimSize(tw,1)
		// add in defaults for newer version columns
		Redimension/N=(-1, kTWColumns) tw
		
		// 6.33: Error bars common settings
		SetDimLabel 1,kErrorBarsCapThickness, errorBarsCapThickness, tw
		SetDimLabel 1,kErrorBarsBarThickness, errorBarsBarThickness, tw

		SetDimLabel 1,kErrorBarsColorFromTraceRadio, errorBarsFromTraceRadio, tw
		SetDimLabel 1,kErrorBarsColorRedGreenBlue, errorBarsColorRGBA, tw // 7.05: label changed to RGB

		// Error bars radius settings
		SetDimLabel 1,kRadiusErrorBarMinMaxStr, radiusErrorBarMinMaxStr, tw
		SetDimLabel 1,kRadiusErrorsBarsX, radiusErrorsBarsX, tw
		SetDimLabel 1,kRadiusErrorsBarsY, radiusErrorsBarsY, tw
		SetDimLabel 1,kRadiusErrorsBarsMrkZ, radiusErrorsBarsMrkZ, tw
		SetDimLabel 1,kRadiusErrorBarsMode, radiusErrorBarsMode, tw
		SetDimLabel 1,kRadiusErrorBarsPercent, radiusErrorBarsPercent, tw
		SetDimLabel 1,kRadiusErrorBarsConstant, radiusErrorBarsConstant, tw
		SetDimLabel 1,kRadiusErrorBarsPlusWavePath, radiusErrorBarsPlusWavePath, tw
		SetDimLabel 1,kRadiusErrorBarsMinusWavePath, radiusErrorBarsMinusWavePath, tw
		SetDimLabel 1,kRadiusErrorBarsCapWidth, radiusErrorBarsCapWidth, tw
		
		// 7.02: Error bars angle settings
		SetDimLabel 1,kAngleErrorsBarsX, angleErrorsBarsX, tw
		SetDimLabel 1,kAngleErrorsBarsY, angleErrorsBarsY, tw
		SetDimLabel 1,kAngleErrorsBarsMrkZ, angleErrorsBarsMrkZ, tw
		SetDimLabel 1,kAngleErrorBarsMode, angleErrorBarsMode, tw
		SetDimLabel 1,kAngleErrorBarsPercent, angleErrorBarsPercent, tw
		SetDimLabel 1,kAngleErrorBarsConstant, angleErrorBarsConstant, tw
		SetDimLabel 1,kAngleErrorBarsPlusWavePath, angleErrorBarsPlusWavePath, tw
		SetDimLabel 1,kAngleErrorBarsMinusWavePath, angleErrorBarsMinusWavePath, tw
		SetDimLabel 1,kAngleErrorBarsCapWidth, angleErrorBarsCapWidth, tw
		
		// 7.05: Fill to zero transparency
		SetDimLabel 1,kFillToZeroAlpha, fillAlpha, tw

		// set default values to update old experiments
		Variable nrows= DimSize(tw,0)
		if( nrows )
			// 6.33 defaults
			if( originalColumns < kVersion633Columns )
				// Error Bars general defaults
				tw[][kErrorBarsCapThickness]= "1.0"
				tw[][kErrorBarsBarThickness]= "1.0"
				tw[][kErrorBarsColorFromTraceRadio]= "1"	// 1 (from Trace checked and Color unchecked)
				tw[][kErrorBarsColorRedGreenBlue]= "0,0,0,65535"	// black, opaque
				// Error Bars Radius Defaults (error bar names can stay blank)
				tw[][kRadiusErrorBarMinMaxStr]= "0,0"
				tw[][kRadiusErrorBarsMode]= "None"
				tw[][kRadiusErrorBarsPercent]= "5"
				tw[][kRadiusErrorBarsConstant]= "0"
				// wave paths can stay blank, too
				tw[][kRadiusErrorBarsCapWidth]= "Auto"
			endif
			// 7.02 defaults
			if( originalColumns < kVersion702Columns )
				// Error Bars Angle Defaults (error bar names can stay blank)
				tw[][kAngleErrorBarsMode]= "None"
				tw[][kAngleErrorBarsPercent]= "5"
				tw[][kAngleErrorBarsConstant]= "0"
				// wave paths can stay blank, too
				tw[][kAngleErrorBarsCapWidth]= "Auto"
			endif
			// 7.05 defaults
			if( originalColumns < kTWColumns )
				tw[][kFillToZeroAlpha]= "65535" // opaque
			endif

		endif // nrows
	endif
	return tw
End

// version 6.38: no longer requires polar graph to exist.
Function/WAVE WMPolarModernizePolarTracesWave(tw)
	WAVE/Z/T tw

	String twDF= GetWavesDataFolder(tw,1)	// just the data folder, has trailing ":"
	if( strlen(twDF)  )
		String df= GetDataFolder(1)
		SetDataFolder twDF
		WAVE/Z/T tw=WMPolarEnsurePolarTracesWave()
		SetDataFolder df
	endif
	
	return tw	// should be the very same
End

// version 7.02 - returns name of appended trace, or "" if error
Function/S WMPolarAppendTrace(graphName,appendRadius, appendAngleData, anglePerCircle)
	String graphName
	Wave appendRadius
	Wave/Z appendAngleData	// $"" if X Scaling is used.
	Variable anglePerCircle	// kDegrees or kRadians

	String df= WMPolarSetPolarGraphDF(graphName)	// OLD data folder
	if( strlen(df) == 0 )	// couldn't find NEW polar data folder for graphName, data folder wasn't changed.
		return ""
	endif

	WAVE/Z/T tw=WMPolarEnsurePolarTracesWave()
	
	Variable newRow= DimSize(tw,0)
	InsertPoints/M=0 newRow, 1, tw	// append

	String shadowTargetVarName= UniqueName("shadowTarget",3,0)
	Variable/G $shadowTargetVarName
	tw[newRow][kShadowTargetVariable]= shadowTargetVarName

	String shadowYName= UniqueName("polarY",1,0)	// wave name, and also trace name (presumably also unique)
	String shadowXName= UniqueName("polarX",1,0)
	tw[newRow][kShadowTraceName]= shadowYName
	tw[newRow][kShadowXWaveName]= shadowXName
	
	String radiusTargetVarName= UniqueName("radiusTarget",3,0)
	Variable/G $radiusTargetVarName
	tw[newRow][kAutoRadiusTargetVariable]= radiusTargetVarName

	tw[newRow][kRadiusWavePath]= GetWavesDataFolder(appendRadius,2)
	if( WaveExists(appendAngleData) )
		tw[newRow][kAngleWavePath]= GetWavesDataFolder(appendAngleData,2)
	else
		tw[newRow][kAngleWavePath]= "_calculated_"
	endif
	tw[newRow][kAngleUnits]= SelectString(anglePerCircle==360, "radians", "degrees")	// false value, true value
	
	// 4.07: initialized kRadiusMin and kRadiusMax
	WaveStats/Q appendRadius
	String theMin, theMax
	sprintf theMin, "%.14g", V_min
	sprintf theMax, "%.14g", V_Max
	tw[newRow][kRadiusMin]= theMin
	tw[newRow][kRadiusMax]= theMax
	
	// fill-to-origin (other values are initialized to "" meaning "off")
	tw[newRow][kFillToZeroLayer]= "back"		// default is behind grid	
	tw[newRow][kFillToZeroRed]= "65535"		// light red in igor color palette
	tw[newRow][kFillToZeroGreen]= "49151"
	tw[newRow][kFillToZeroBlue]= "49151"
	
	// Version 6.33: error bars (initially off, and the wave paths can stay blank)
	// Error Bars common settings
	tw[newRow][kErrorBarsCapThickness]= "1.0"
	tw[newRow][kErrorBarsBarThickness]= "1.0"
	tw[newRow][kErrorBarsColorFromTraceRadio]= "1"	// 1 (from Trace checked and Color unchecked)
	tw[newRow][kErrorBarsColorRedGreenBlue]= "0,0,0,65535"	// black, opaque

	// Radius Error Bars settings
	tw[newRow][kRadiusErrorBarMinMaxStr]= "0,0"
	tw[newRow][kRadiusErrorsBarsX]= ""		// will be polarRadiusErrorBarX0, etc
	tw[newRow][kRadiusErrorsBarsY]= ""		// will be polarRadiusErrorBarY0, etc
	tw[newRow][kRadiusErrorsBarsMrkZ]= ""	// will be polarRadiusErrorBarZ0, etc
	tw[newRow][kRadiusErrorBarsMode]= "None"
	tw[newRow][kRadiusErrorBarsPercent]= "5"
	tw[newRow][kRadiusErrorBarsConstant]= "0"
	tw[newRow][kRadiusErrorBarsCapWidth]= "Auto"

	// Version 7.02: Angle Error Bars settings
	tw[newRow][kAngleErrorsBarsX]= ""		// will be polarAngleErrorBarX0, etc
	tw[newRow][kAngleErrorsBarsY]= ""		// will be polarAngleErrorBarY0, etc
	tw[newRow][kAngleErrorsBarsMrkZ]= ""	// will be polarAngleErrorBarZ0, etc
	tw[newRow][kAngleErrorBarsMode]= "None"
	tw[newRow][kAngleErrorBarsPercent]= "5"
	tw[newRow][kAngleErrorBarsConstant]= "0"
	tw[newRow][kAngleErrorBarsCapWidth]= "Auto"
	
	// Version 7.02: Transparency
	tw[newRow][kFillToZeroAlpha]= "65535" // opaque

	// transform the data before appending it to the graph to avoid resizing the graph unnecessarily
	Duplicate/O appendRadius,$shadowXName, $shadowYName	// just to get the right length and type.
	WAVE wShadowX= $shadowXName
	WAVE wShadowY= $shadowYName

	String traces= WMPolarTraceNameList(0)
	String axes=AxisList(graphName)
	Variable initializeAxes= ItemsInList(traces) == 0 || (FindListItem("VertCrossing",axes) < 0) || (FindListItem("HorizCrossing",axes) < 0)	// True if we're about to add the VertCrossing or the HorizCrossing axis

	AppendToGraph/W=$graphName/L=VertCrossing/B=HorizCrossing wShadowY vs wShadowX

	SetDataFolder df

	if( initializeAxes )
		WMPolarInitializeAxes(graphName)
	endif
	WMPolarUpdateShadowWave(graphName,wShadowY)
	DoUpdate	// otherwise the autoscale doesn't work too well.	
//	WMPolarAxesRedraw(graphName,tw)
	WMPolarAxesRedrawGraphNow(graphName)	// 6.13 - this avoids noticeable margin changes (they're still there, just smaller).

	//  auto-sets to the last trace
	DoWindow WMPolarGraphPanel
	if( V_Flag )
		String polarTraces=WMPolarTraceNameList(0)
		Variable lastTrace= max(1,ItemsInList(polarTraces))
		PopupMenu mainModifyTracePop win= WMPolarGraphPanel, mode=lastTrace
		WMPolarPanelUpdate(1)		// add to removable traces.
	endif
	
	return shadowYName
End

Function WMPolarInitializeAxes(graphName)
	String graphName

	String axes=AxisList(graphName)
	Variable haveAxes=(FindListItem("VertCrossing",axes) >= 0) && (FindListItem("HorizCrossing",axes) >= 0)
	if( haveAxes)
		// It is possible that the user could accidently drag these to the wrong location; but perhaps it doesn't matter
		ModifyGraph/W=$graphName freePos(VertCrossing)={inf,HorizCrossing}	// this puts them out of the way.
		ModifyGraph/W=$graphName freePos(HorizCrossing)={inf,VertCrossing}
		// Plan width zooms well for landscape monitors,
		// but it can create a window larger than the monitor.
		// The window hook calls WMPolarKeepWindowOnScreen() to fix this up as best it can (by switching the mode around)
		ModifyGraph/W=$graphName width={Plan,1,HorizCrossing,VertCrossing},height=0
		WMPolarShowHideAxes(graphName,0)	// hide, use 1 to show for debugging

		// 9.03: Initialize virtual drawing layers for the default axesDrawLayer:
		String drawLayer = WMPolarGraphWantedDrawLayer(graphName)
		WMPolarEnsureVirtualLayers(graphName, drawLayer)
	endif
End

Function WMPolarSetManualRadiusRange(polarGraphName, radiusMin, radiusMax)	
	String polarGraphName
	Variable radiusMin, radiusMax

	WMPolarGraphSetStr(polarGraphName,"doRadiusRange","manual")

	WMPolarGraphSetVar(polarGraphName,"innerRadius",radiusMin)
	WMPolarGraphSetVar(polarGraphName,"outerRadius",radiusMax)

	WAVE/T tw=$WMPolarGraphTracesTW(polarGraphName)
	WMPolarUpdateAxes(tw,1)	//  WMPolarUpdateAxes will compute the max and min radii for all traces and expand or contract the grid accordingly
End

Function WMPolarGetRadiusRange(polarGraphName, radiusMin, radiusMax)
	String polarGraphName
	Variable &radiusMin, &radiusMax	// outputs

	// outputs of WMPolarTicks():
	radiusMin= WMPolarGraphGetVar(polarGraphName,"dataInnerRadius")
	radiusMax= WMPolarGraphGetVar(polarGraphName,"dataOuterRadius")
End

Function WMPolarSetAutoRadiusRange(polarGraphName [,alwaysIncludeOrigin])
	String polarGraphName
	Variable alwaysIncludeOrigin	// optional: 0 to autoscale radius min, too. Default is 1 (autoscale to radius origin)

	WMPolarGraphSetStr(polarGraphName,"doRadiusRange","auto")
	
	if( !ParamIsDefault(alwaysIncludeOrigin) )
		WMPolarGraphSetVar(polarGraphName,"doRadiusRangeMaxOnly",alwaysIncludeOrigin)
	endif

	WAVE/T tw=$WMPolarGraphTracesTW(polarGraphName)
	WMPolarUpdateAxes(tw,1)	//  WMPolarUpdateAxes will compute the max and min radii for all traces and expand or contract the grid accordingly
End

// returns truth that the radius range is auto-scaled
Function WMPolarGetAutoRadiusRange(polarGraphName, alwaysIncludeOrigin)
	String polarGraphName
	Variable &alwaysIncludeOrigin	// output: 0 to autoscale radius min, too. Default is 1 (autoscale to radius origin)

	alwaysIncludeOrigin= WMPolarGraphGetVar(polarGraphName,"doRadiusRangeMaxOnly")

	String doRadiusRange= WMPolarGraphGetStr(polarGraphName,"doRadiusRange")
	Variable isAuto= CmpStr(doRadiusRange ,"auto") == 0
	return isAuto
End


Function WMPolarSetAngleRange(polarGraphName, startAngleDegrees, angleExtentDegrees)
	String polarGraphName
	Variable startAngleDegrees, angleExtentDegrees

	WMPolarGraphSetVar(polarGraphName,"angle0",startAngleDegrees)
	WMPolarGraphSetVar(polarGraphName,"angleRange",angleExtentDegrees)

	WAVE/T tw=$WMPolarGraphTracesTW(polarGraphName)
	WMPolarUpdateAxes(tw,1)
End

Function WMPolarGetAngleRange(polarGraphName, startAngleDegrees, angleExtentDegrees)
	String polarGraphName
	Variable &startAngleDegrees, &angleExtentDegrees	// outputs

	// outputs of WMPolarTicks() are in radians
	startAngleDegrees= WMPolarGraphGetVar(polarGraphName,"dataAngle0") * 180 / pi
	angleExtentDegrees= WMPolarGraphGetVar(polarGraphName,"dataAngleRange") * 180 / pi
End

Function WMPolarSetZeroAngleWhere(polarGraphName, where [,radiusOrigin])
	String polarGraphName
	String where	// "top", "bottom", "left", or "right"
	Variable radiusOrigin	// optional, default is 0

	Variable zeroAngleWhere
	strswitch(where)
		case "bottom":
			zeroAngleWhere= -90
			break
		case "right":
			zeroAngleWhere= 0
			break
		case "top":
			zeroAngleWhere= 90
			break
		case "left":
			zeroAngleWhere= 180
			break
		default:	
			zeroAngleWhere= str2num(where)	// degrees
			break
	endswitch
	
	WMPolarGraphSetVar(polarGraphName,"zeroAngleWhere",zeroAngleWhere)
	
	if( !ParamIsDefault(radiusOrigin) )
		WMPolarGraphSetVar(polarGraphName,"valueAtCenter",radiusOrigin)
	endif

	WAVE/T tw=$WMPolarGraphTracesTW(polarGraphName)
	WMPolarUpdateAxes(tw,1)
End

Function WMPolarGetZeroAngleWhere(polarGraphName, whereDegrees,radiusOrigin)
	String polarGraphName
	Variable &whereDegrees	// output: angle in degrees, 0 is "right", 90 is "top", -90 is "bottom", and 180 is "left"
	Variable &radiusOrigin	// output

	whereDegrees= WMPolarGraphGetVar(polarGraphName,"zeroAngleWhere")
	radiusOrigin= WMPolarGraphGetVar(polarGraphName,"valueAtCenter")
End

Function WMPolarSetAngleDirection(polarGraphName, angleDirectionStr)
	String polarGraphName
	String angleDirectionStr	// "1", "clockwise" or "CW" or "counter clockwise" or "CCW" or "-1"
	
	Variable angleDirection
	strswitch( angleDirectionStr )
		case "clockwise":
		case "CW":
			angleDirection= 1
			break
		case "counter clockwise":
		case "CCW":
			angleDirection= -1
			break
		default:	
			angleDirection= str2num(angleDirectionStr)
			if( numtype(angleDirection) != 0 )
				return 0
			endif
			angleDirection= sign(angleDirection)
			break
	endswitch

	WMPolarGraphSetVar(polarGraphName,"angleDirection",angleDirection)

	WAVE/T tw=$WMPolarGraphTracesTW(polarGraphName)
	WMPolarUpdateAxes(tw,1)
End

// returns -1 for CCW, or 1 for CW
Function WMPolarGetAngleDirection(polarGraphName)
	String polarGraphName

	Variable angleDirection= WMPolarGraphGetVar(polarGraphName,"angleDirection")
	return angleDirection
End


// NOTE: Igor users should not call WMPolarShowHideAxes(); it does not do what you think it does.
Function WMPolarShowHideAxes(graphName,show)
	String graphName
	Variable show // 0 for hide, -1 for toggle
	
	if( strlen(graphName) == 0 )
		graphName= WMPolarTopPolarGraph()
		if( strlen(graphName) == 0 )
			return 0
		endif
	endif
	String axes=AxisList(graphName)
	Variable haveAxes= (FindListItem("VertCrossing",axes) >= 0) && (FindListItem("HorizCrossing",axes) >= 0)
	if( haveAxes )
		if( show == -1 )	// toggle
			Variable nolabel= WMPolarAxisInfoNumByKey("noLabel",graphName,"VertCrossing")	// case sensitive
			if( numtype(nolabel) != 0 )	// NaN if nolabel is missing
				nolabel=0				//  (which means it was 0)
			endif
			show= nolabel != 0
		endif
		if( show )
			ModifyGraph/W=$graphName axThick(HorizCrossing)=1,nolabel(HorizCrossing)=0
			Label/W=$graphName HorizCrossing ""	// default axis label
			ModifyGraph/W=$graphName axThick(VertCrossing)=1,nolabel(VertCrossing)=0
			Label/W=$graphName VertCrossing ""	// default axis label
		else
			ModifyGraph/W=$graphName axThick(HorizCrossing)=0,nolabel(HorizCrossing)=2
			Label/W=$graphName HorizCrossing "\\u#2"	// no axis label
			ModifyGraph/W=$graphName axThick(VertCrossing)=0,nolabel(VertCrossing)=2
			Label/W=$graphName VertCrossing "\\u#2"	// no axis label
		endif
	endif
End


Function WMPolarToggleAutoscaleTraceVis(graphName)
	String graphName
	
	if( strlen(graphName) == 0 )
		graphName= WMPolarTopPolarGraph()
		if( strlen(graphName) == 0 )
			return 0
		endif
	endif
	Variable hideTrace= WMPolarTraceInfoNumByKey("hideTrace",graphName,"polarAutoscaleTrace") // normally hideTrace=2
	if( hideTrace == 0 )
		hideTrace=2 // include in autoscale
	else
		hideTrace=0
	endif
	ModifyGraph/W=$graphName hideTrace(polarAutoscaleTrace) = hideTrace
End


Function WMPolarTraceInfoNumByKey(key,graphName,traceName)
	String key,graphName,traceName
	
	String info= TraceInfo(graphName,traceName,0)

	String recKey=";RECREATION:"
	Variable recPos= strsearch(info,recKey,0)
	if( recPos < 0 )
		return NaN
	endif
	info[0,recPos+strlen(recKey)-1]=""
	return NumberByKey(key+"(x)",info,"=")
End

Function WMPolarAxisInfoNumByKey(key,graphName,axisName)
	String key,graphName,axisName
	
	String info= AxisInfo(graphName,axisName)

	String recKey=";RECREATION:"
	Variable recPos= strsearch(info,recKey,0)
	if( recPos < 0 )
		return NaN
	endif
	info[0,recPos+strlen(recKey)-1]=""
	return NumberByKey(key+"(x)",info,"=")
End


Function WMPolarMainRemoveButton(ctrlName) : ButtonControl
	String ctrlName
	
	ControlInfo/W=WMPolarGraphPanel mainModifyTracePop
	if( V_Flag <= 0 )
		Beep
		return 0
	endif

	String graphName= WMPolarTopPolarGraph()
	WAVE/Z/T tw= $WMPolarGraphTracesTW(graphName)
	if( !WaveExists(tw) )
		Beep
		return 0
	endif
	
	String shadowOnly, radiusOnly
	shadowOnly= StringFromList(0,S_Value,"[")
	shadowOnly= StringFromList(0,shadowOnly," ")
	radiusOnly= StringFromList(1,S_Value,"[")
	radiusOnly= StringFromList(0,radiusOnly,"]")
//	WAVE/Z wShadowY= TraceNameToWaveRef(graphName,shadowOnly)		// it is possible that the user removed the trace from the graph using the Remove From Graph dialog...
//	if( !WaveExists(wShadowY) )
//		Beep
//		return 0
//	endif
	Variable remainingTraces= WMPolarRemoveTrace(graphName,shadowOnly)
	WMPolarPanelUpdate(0)		// update removable traces.
	if( remainingTraces )
		WMPolarUpdateAxes(tw,1)	//  WMPolarUpdateAxes will compute the max and min radii for all traces and expand or contract the grid accordingly
		DoUpdate
		WMPolarAxesRedraw(graphName,tw)
	endif
	WMPolarUpdateLegend(graphName,0)	// 6.21
End

static Function WMPolarUnSetFillToOrigin(graphName,polarTraceName)
	String graphName,polarTraceName

	Variable wasFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue
	String fillYWaveName,fillXWaveName
	String df= WMPolarGetPolarTraceSettings(graphName,polarTraceName,wasFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue,fillYWaveName,fillXWaveName)
	if( strlen(df) && wasFillToOrigin )
		WMPolarSetPolarTraceSettings(graphName,polarTraceName,0,isFillBehind,fillRed,fillGreen,fillBlue,fillYWaveName,fillXWaveName)
		WMPolarModifyFillToOrigin(graphName,polarTraceName)
	endif
	return wasFillToOrigin
End

// returns number of remaining polar traces
Function WMPolarRemoveTrace(graphName,traceName)
	String graphName,traceName

	WMPolarUnSetFillToOrigin(graphName,traceName) // 9.02: erase this trace's fill-to-origin drawing.
	WAVE/Z wShadowY=TraceNameToWaveRef(graphName,traceName)	// may fail if the trace was already removed from the graph
	WAVE/Z wShadowX=XWaveRefFromTrace(graphName,traceName)
	RemoveFromGraph/Z/W=$graphName $traceName

	WAVE/Z/T tw= $WMPolarGraphTracesTW(graphName)
	if( WaveExists(tw) )
		WAVE/Z wShadowY= $GetWavesDataFolder(tw,1)+traceName
		Variable row= WMPolarShadowWaveRow(wShadowY)
		if( row != -1 )		// this wave was found in polarTracesTW
			// deallocate anything allocated for the trace
			String df=GetWavesDataFolder(tw,1)
			String wShadowXPath= df+tw[row][kShadowXWaveName]
			String shadowVariablePath= df+tw[row][kShadowTargetVariable]
			String radiusVariablePath= df+tw[row][kAutoRadiusTargetVariable]
			String fillYPath= df+tw[row][kFillToZeroYWaveName]
			String fillXPath= df+tw[row][kFillToZeroXWaveName]
			KillVariables/Z $shadowVariablePath, $radiusVariablePath
			KillWaves/Z $fillYPath, $fillXPath
			DeletePoints/M=0 row,1,tw		// remove from list of polar traces
			// WARNING: Deleting the last row causes Igor to redimension tw to 1-D!
			// This is fixed in the WMPolarAppendTrace() code.
			WAVE/Z wShadowX= $wShadowXPath
		endif
	endif
	KillWaves/Z wShadowX
	KillWaves/Z wShadowY

	//  Set to the last trace
	String polarTraces=WMPolarTraceNameList(0)
	Variable numPolarTraces= ItemsInList(polarTraces)
	if( numPolarTraces == 0 )	// removed the last trace; clean up
		WMPolarCleanOutGraph(graphName)
	endif	

	DoWindow WMPolarGraphPanel
	if( V_Flag )
		Variable lastTrace= max(1,numPolarTraces)
		PopupMenu mainModifyTracePop win= WMPolarGraphPanel, mode=lastTrace
	endif

	return numPolarTraces
End

Function WMPolarUpdateForRemovedWaves(graphName)
	String graphName

	Variable removedTraces=0
	WAVE/Z/T tw= $WMPolarGraphTracesTW(graphName)
	if( WaveExists(tw) )
		String df=GetWavesDataFolder(tw,1)
		Variable row,n= DimSize(tw,0)
		String traceList=""
		for( row=0; row < n; row += 1 )
			String traceName=tw[row][kShadowTraceName]
			WAVE/Z w=$(df+traceName)
			CheckDisplayed/W=$graphName w
			if( V_Flag == 0 )	// no longer displayed; remove it!
				traceList += traceName+";"	// later, else the row numbers get confused
			endif
		endfor
		removedTraces= ItemsInList(traceList)
		for( row= 0; row < removedTraces; row += 1)
			traceName= StringFromList(row,traceList)
			WMPolarRemoveTrace(graphName,traceName)
		endfor
		if( removedTraces )
			WMPolarPanelUpdate(1)		// update removable traces.
		endif
	endif
	return removedTraces
End

Function WMPolarCleanOutDF(df)
	String df
	
	if( DataFolderExists(df) && strsearch(df,"_default_",0) == -1 )
		String oldDF= GetDataFolder(1)
		SetDataFolder df
		WAVE/Z/T tw= polarTracesTW
		if( WaveExists(tw) )
			Variable row,n= DimSize(tw,0)
			for( row=0; row < n; row += 1 )
				String shadowVariableName= tw[row][kShadowTargetVariable]
				String radiusVariableName= tw[row][kAutoRadiusTargetVariable]
				KillVariables/Z $shadowVariableName, $radiusVariableName

				String shadowYName= tw[row][kShadowTraceName]
				String shadowXName= tw[row][kShadowXWaveName]
				
				String fillToZeroYWaveName= tw[row][kFillToZeroYWaveName]
				String fillToZeroXWaveName= tw[row][kFillToZeroXWaveName]
				
				KillWaves/Z $shadowYName, $shadowXName
				if( strlen(fillToZeroYWaveName) )
					KillWaves/Z $fillToZeroYWaveName, $fillToZeroXWaveName
				endif
				
				String radiusErrorsBarsX= tw[row][kRadiusErrorsBarsX]
				String radiusErrorsBarsY= tw[row][kRadiusErrorsBarsY]
				String radiusErrorsBarsMrkZ= tw[row][kRadiusErrorsBarsMrkZ]
				if( strlen(radiusErrorsBarsX) )
					KillWaves/Z $radiusErrorsBarsX, $radiusErrorsBarsY, $radiusErrorsBarsMrkZ
				endif

				String angleErrorBarX= tw[row][kAngleErrorsBarsX]
				String angleErrorBarY= tw[row][kAngleErrorsBarsY]
				String angleErrorBarMrkZ= tw[row][kAngleErrorsBarsMrkZ]
				if( strlen(angleErrorBarX) )
					KillWaves/Z $angleErrorBarX, $angleErrorBarY, $angleErrorBarMrkZ
				endif
				
			endfor
			KillWaves/Z tw
		endif
		SetDataFolder oldDF
	endif
End

Function WMPolarUpdateShadowWave(graphName,wShadowY)
	String graphName
	WAVE/Z wShadowY		// pass $"" to update all shadow waves in the graph

	String df= WMPolarSetPolarGraphDF(graphName)
	if( strlen(df) == 0 )
		return 0
	endif

	WAVE/Z/T tw= polarTracesTW
	if( WaveExists(tw) == 0 )
		SetDataFolder df
		return 0
	endif
	
	Variable row
	if( WaveExists(wShadowY) )	// update one polar trace
		row= WMPolarShadowWaveRow(wShadowY)
		if( row >= 0 )
			WMPolarUpdateShadowWaveByRow(graphName,row)
		endif
	else			// update all polar traces in the graph
		Variable rows = DimSize(tw,0)
		for( row=0; row < rows; row += 1 )
			WAVE/Z wShadowY = $tw[row][kShadowTraceName]
			if( WaveExists(wShadowY) )	// update this polar trace
				WMPolarUpdateShadowWaveByRow(graphName,row)
			endif
		endfor
	endif
	SetDataFolder df
End

// WMPolarUpdateShadowWaveByRow() is the single most important routine for Polar Graphs.
// Here is where the radius and angle waves are transformed into X and Y "shadow" waves
// which are displayed in the graph.
//
// Here we also set up a dependency through WMPolarSetRadiusMinsMaxes() to
// create or update the invisible Range traces PolarRange0, PolarRangeX0
// which keep the minima and maxima X and Y data ranges so that Autoscale on the graph
// encompasses all traces AND GRIDS in the graph, including the radius error bars.
//
// (Note: the angle error bars do not participate in autoscaling since the angle erro bars
// are always at the radii defined by the polar traces,
// and the polar traces are already included in radius auto-scaling.)
//
// Before calling WMPolarUpdateShadowWaveByRow, the following must be true:
// 	a)	polarTracesTW for the given graph must exist,
//	b)	0 <= polarTracesTWRow < rows in PolarTracesTW,
//	c)	the columns of polarTracesTW for that row must be valid.
//
// WMPolarUpdateShadowWaveByRow() creates dependency assignments which are valid in global scope to implement
// automatic updating of the polar graph when underlying data changes.
//
// shadowTarget0 := ProcGlobal#WMPolarShadowFunction(wShadowX,wShadowY,radiusData, angleDataOrNull, radiusFunctionStr,valueAtCenter,zeroAngleWhereDegrees,angleDirection,anglePerCircle)
// radiusTarget0 := 	ProcGlobal#WMPolarSetRadiusMinsMaxes(pathToTWStr,pathToRadiusDataWave)
//
// The radiusTarget0 dependency responds to changes in the radiusErrorBars YWave to provoke an autoscale.
// through an optional WAVE radiusYWave parameter to WMPolarSetRadiusMinsMaxes:
//
// radiusTarget0 := 	ProcGlobal#WMPolarSetRadiusMinsMaxes(pathToTWStr,pathToRadiusDataWave,radiusYWave=pathToRadiusErrorBarYWave)
//
// 2/19/2001, JP: Version 4.01 - when the ProcGlobal#WMPolarShadowFunction equation is too long, the dependency is split into two equations,
//	 WMPolarShadowFunctionData() for the input and output data and WMPolarShadowFunctionSettings() for the graph global settings:
//
//		shadowTarget0 := ProcGlobal#WMPolarShadowFunctionData(shadowXPath, shadowYPath,radiusDataPath, angleDataPath,anglePerCircleStr,settingsVariableNamePath)
//		coordsChanged := ProcGlobal#WMPolarShadowFunctionSettings(radiusFunctionPath,valueAtCenterPath, zeroAngleWherePath,angleDirectionPath)
//
// 3/12/2001, JP: Version 4.02 - Larry pointed out that formulas are evaluated in the context of the variable or wave's data folder.
//	Places where a path was used need only the name of the wave, variable, or string.
//
// 6/11/2013, JP, Version 6.33 -  Added radius error bars.
//
// 1/13/2017, JP: Version 7 - Added angle error bars

Function WMPolarUpdateShadowWaveByRow(graphName,row)
	String graphName
	Variable row		// in polarTracesTW

	// wShadowX and wShadowY are the displayed waves 

	String df= WMPolarSetPolarGraphDF(graphName)	// df NOT CHECKED, but this is the data folder used to evaluate the dependency formulae
	WAVE/T tw= polarTracesTW
	WAVE/Z wShadowY = $tw[row][kShadowTraceName]
	if( !WaveExists(wShadowY) )
		SetDataFolder df
		return 0
	endif
	String shadowYPath= NameOfWave(wShadowY)

	WAVE wShadowX = $tw[row][kShadowXWaveName]
	String shadowXPath= NameOfWave(wShadowX)
	
	// Source radiusDataPath
	String radiusDataPath=tw[row][kRadiusWavePath]	// NOT in current data folder
	
	// Polar Coordinates apply to all traces, and we want them to update when the coordinate values change
	String radiusFunctionPath= "radiusFunction"	// "Linear;Log;Ln"
	String valueAtCenterPath= "valueAtCenter"
	
	// Source  angleDataPath (or X scaling)
	String angleDataPath=tw[row][kAngleWavePath]	// NOT in current data folder
	WAVE/Z angleData = $angleDataPath					// angle wave is optional
	if( !WaveExists(angleData) )
		angleDataPath= "$\"\""		// NULL wave means use the radius X Scaling
	endif
	// units are specific to the trace and currently can't be changed except by removing and re-appending the trace.
	String anglePerCircleStr= SelectString(CmpStr(tw[row][kAngleUnits],"degrees") == 0,  "2 * pi", "360")	// false value, true value

	// Polar Coordinates apply to all traces
	String angleDirectionPath=  "angleDirection"	// 1 == clockwise, -1 == counter-clockwise"
	String zeroAngleWherePath= "zeroAngleWhere"	// 0 = right, 90 = top, 180 = left, -90 = bottom

	// Shadow Target
	String targetVariableName= tw[row][kShadowTargetVariable]

	String modName=GetIndependentModuleName()+"#"

	// Destinations wShadowX and wShadowY are set as a side-effect of the following formula
	// targetVariable := WMPolarShadowFunction(wShadowX,wShadowY,radiusData, angleDataOrNull, radiusFunctionStr,valueAtCenter,zeroAngleWhereDegrees,angleDirection,anglePerCircle)
	
	// We use anglePerCircleStr, the last parameter, to append any optional parameters needed.
	String wPath
	String radiusErrorBarsMode= tw[row][kRadiusErrorBarsMode]	//  "None;% of radius;sqrt of radius;+ constant;+/- constant;+/- wave;"
	Variable haveRadiusErrorBarsWaves= CmpStr(radiusErrorBarsMode, "+/- wave") == 0
	if( haveRadiusErrorBarsWaves )
		wPath= tw[row][kRadiusErrorBarsPlusWavePath]
		WAVE/Z w= $wPath
		if( WaveExists(w) )
			anglePerCircleStr += ",radiusPlus="+wPath		// append optional parameter
		endif
		wPath= tw[row][kRadiusErrorBarsMinusWavePath]
		WAVE/Z w= $wPath
		if( WaveExists(w) )
			anglePerCircleStr += ",radiusMinus="+wPath		// append optional parameter
		endif
	endif

	String angleErrorBarsMode= tw[row][kAngleErrorBarsMode]	//  "None;% of radius;sqrt of radius;+ constant;+/- constant;+/- wave;"
	Variable haveAngleErrorBarsWaves= CmpStr(angleErrorBarsMode, "+/- wave") == 0
	if( haveAngleErrorBarsWaves )
		wPath= tw[row][kAngleErrorBarsPlusWavePath]
		WAVE/Z w= $wPath
		if( WaveExists(w) )
			anglePerCircleStr += ",anglePlus="+wPath		// append optional parameter
		endif
		wPath= tw[row][kAngleErrorBarsMinusWavePath]
		WAVE/Z w= $wPath
		if( WaveExists(w) )
			anglePerCircleStr += ",angleMinus="+wPath		// append optional parameter
		endif
	endif

	String formula
	sprintf formula, "%sWMPolarShadowFunction(%s,%s,%s,%s,%s,%s,%s,%s,%s)", modName, shadowXPath, shadowYPath,radiusDataPath, angleDataPath,radiusFunctionPath,valueAtCenterPath, zeroAngleWherePath,angleDirectionPath,anglePerCircleStr

	if( strlen(formula) > 400 )
		// Print "formula too long: ",strlen(formula)
		// divide the dependency into two pieces, one for the input and output data:
		String settingsVariableName= "coordsChanged"	// shared among all traces, changing this provokes a call to WMPolarShadowFunctionData
		String settingsVariableNamePath= WMPolarGraphDFVar(graphName,settingsVariableName)
		Variable/G $settingsVariableNamePath	// possibly already existing.

		// We use settingsVariableNamePath, the last parameter, to append any optional parameters needed.
		if( haveRadiusErrorBarsWaves )
			wPath= tw[row][kRadiusErrorBarsPlusWavePath]
			WAVE/Z w= $wPath
			if( WaveExists(w) )
				settingsVariableNamePath += ",radiusPlus="+wPath		// append optional parameter
			endif
			wPath= tw[row][kRadiusErrorBarsMinusWavePath]
			WAVE/Z w= $wPath
			if( WaveExists(w) )
				settingsVariableNamePath += ",radiusMinus="+wPath		// append optional parameter
			endif
		endif

		if( haveAngleErrorBarsWaves )
			wPath= tw[row][kAngleErrorBarsPlusWavePath]
			WAVE/Z w= $wPath
			if( WaveExists(w) )
				settingsVariableNamePath += ",anglePlus="+wPath		// append optional parameter
			endif
			wPath= tw[row][kAngleErrorBarsMinusWavePath]
			WAVE/Z w= $wPath
			if( WaveExists(w) )
				settingsVariableNamePath += ",angleMinus="+wPath		// append optional parameter
			endif
		endif

		sprintf formula, "%sWMPolarShadowFunctionData(%s,%s,%s,%s,%s,%s)", modName, shadowXPath, shadowYPath,radiusDataPath, angleDataPath,anglePerCircleStr,settingsVariableNamePath
		//	SetFormula $targetVariableName, formula	// do this below to prevent double update

		// and one for the polar graph settings:
		String settingsFormula
		sprintf settingsFormula, "%sWMPolarShadowFunctionSettings(%s,%s,%s,%s)", modName, radiusFunctionPath,valueAtCenterPath, zeroAngleWherePath,angleDirectionPath

		if( (strlen(formula) > 400) || (strlen(settingsFormula) > 400) )
			DoAlert 0, "The wave names or data folder names are too long for auto-updating to work.\r\rPlease shorten them and try again."
			WAVE radiusData= $radiusDataPath
			SVAR radiusFunctionStr= $radiusFunctionPath
			NVAR valueAtCenter= $valueAtCenterPath
			NVAR zeroAngleWhereDegrees= $zeroAngleWherePath
			NVAR angleDirection= $angleDirectionPath
			Variable anglePerCircle= str2num(anglePerCircleStr)
	
			WMPolarShadowFunction(wShadowX,wShadowY,radiusData,angleData,radiusFunctionStr,valueAtCenter,zeroAngleWhereDegrees,angleDirection,anglePerCircle)
		else
			SetFormula $settingsVariableName, settingsFormula
			SetFormula $targetVariableName, formula
		endif
	else
		// Print targetVariableName+" := " + formula
		SetFormula $targetVariableName, formula	// evaluated in the data folder of $targetVariableName; the current df
	endif

	// Auto-Radius Target 
	 // (we pass the tw path, because we don't want the formula executed if tw changes, only if the radius data changes.)
	targetVariableName= tw[row][kAutoRadiusTargetVariable]
	String twPath= GetWavesDataFolder(tw,2)
	// The radiusTarget0 dependency responds to changes in the radiusErrorBars YWave to provoke an autoscale.
	// through an optional WAVE radiusYWave parameter to WMPolarSetRadiusMinsMaxes:
	//
	// radiusTarget0 := 	ProcGlobal#WMPolarSetRadiusMinsMaxes(pathToTWStr,pathToRadiusDataWave,radiusYWave=pathToRadiusErrorBarYWave)
	Variable haveRadiusErrorBars= CmpStr(radiusErrorBarsMode, "None") != 0
	if( haveRadiusErrorBars )
		String pathToRadiusErrorBarYWave= tw[row][kRadiusErrorsBarsY]	// polarRadiusErrorBarY0, etc in the current data folder, so it is just the wave name
		radiusDataPath += ",radiusYWave="+pathToRadiusErrorBarYWave		// append optional parameter
	endif

	sprintf formula, "%sWMPolarSetRadiusMinsMaxes(\"%s\",%s)", modName, twPath, radiusDataPath
	SetFormula $targetVariableName, formula

	SetDataFolder df
End


// Usage: someArbitraryVariable := WMPolarShadowFunction(wShadowX,wShadowY,radiusData, angleDataOrNull,shadowTargetVarPath)
Function WMPolarShadowFunction(wShadowX,wShadowY,radiusData, angleDataOrNull,radiusFunctionStr,valueAtCenter,zeroAngleWhereDegrees,angleDirection,anglePerCircle[,radiusPlus,radiusMinus,anglePlus,angleMinus])
	Wave wShadowX,wShadowY,radiusData
	Wave/Z angleDataOrNull		// pass $"" for _calculated_ angles from radiusData's X scaling.
	String radiusFunctionStr	// "Linear", "Log", or "Ln"
	Variable valueAtCenter
	Variable zeroAngleWhereDegrees	// 0 = right, 90 = top, 180 = left, -90 = bottom
	Variable angleDirection		// 1 == clockwise, -1 == counter-clockwise"
	Variable anglePerCircle		// 2 * pi for radians, 360 for degrees
	WAVE/Z radiusPlus	// radiusErrorBarsPlusWavePath, optionally used, and only to provoke the dependency. Short name to keep the SetFormula text short.
	WAVE/Z radiusMinus	// radiusErrorBarsMinusWavePath, optionally used, and only to provoke the dependency. Short name to keep the SetFormula text short.
	WAVE/Z anglePlus	// angleErrorBarsPlusWavePath, optionally used, and only to provoke the dependency. Short name to keep the SetFormula text short.
	WAVE/Z angleMinus	// angleErrorBarsMinusWavePath, optionally used, and only to provoke the dependency. Short name to keep the SetFormula text short.

	if( ParamIsDefault(radiusPlus) )
		WAVE/Z radiusPlus=$""	// we don't use this wave, we use tw[row][kRadiusErrorBarMinMaxStr], instead. See below
	endif
	if( ParamIsDefault(radiusMinus) )
		WAVE/Z radiusMinus=$""	// we don't use this wave, we use tw[row][kRadiusErrorBarMinMaxStr], instead. See below
	endif

	if( ParamIsDefault(anglePlus) )
		WAVE/Z anglePlus=$""	// we don't use this wave for anything other than a dependency to to provoke and update to the error bars
	endif
	if( ParamIsDefault(angleMinus) )
		WAVE/Z angleMinus=$""	// we don't use this wave for anything other than a dependency to to provoke and update to the error bars
	endif

	//	x = funcR(radius) * cos(funcA(angle))	
	//	y = funcR(radius) * sin(funcA(angle))
	Variable npnts= numpnts(radiusData)
	if( numpnts(wShadowY) != npnts )
		Redimension/N=(npnts) wShadowY, wShadowX
	endif

	if( WaveExists(angleDataOrNull) )
		wShadowX= WMPolarRadiusFunction(radiusData,radiusFunctionStr,valueAtCenter) * cos(WMPolarAngleFunction(angleDataOrNull,zeroAngleWhereDegrees,angleDirection,anglePerCircle))
		wShadowY= WMPolarRadiusFunction(radiusData,radiusFunctionStr,valueAtCenter) * sin(WMPolarAngleFunction(angleDataOrNull,zeroAngleWhereDegrees,angleDirection,anglePerCircle))
	else
		wShadowX= WMPolarRadiusFunction(radiusData,radiusFunctionStr,valueAtCenter) * cos(WMPolarAngleFunction(pnt2x(radiusData,p),zeroAngleWhereDegrees,angleDirection,anglePerCircle))
		wShadowY= WMPolarRadiusFunction(radiusData,radiusFunctionStr,valueAtCenter) * sin(WMPolarAngleFunction(pnt2x(radiusData,p),zeroAngleWhereDegrees,angleDirection,anglePerCircle))
	endif

	WMPolarUpdateFillToOrigin(wShadowX,wShadowY)	
	WMPolarUpdateErrorBars(wShadowX,wShadowY)	
	return 0				// the return value isn't important; it is what happens in the routine that's important.
End

Function WMPolarShadowFunctionData(wShadowX,wShadowY,radiusData, angleDataOrNull,anglePerCircle,settingsHaveChanged[,radiusPlus,radiusMinus,anglePlus,angleMinus])
	Wave wShadowX,wShadowY,radiusData
	Wave/Z angleDataOrNull		// pass $"" for _calculated_ angles from radiusData's X scaling.
	Variable anglePerCircle			// 2 * pi for radians, 360 for degrees, units are specific to the trace and currently can't be changed except by removing and re-appending the trace.
	Variable settingsHaveChanged	// used for propagating the dependency changes from WMPolarShadowFunctionSettings to WMPolarShadowFunctionData
	WAVE/Z radiusPlus	// radiusErrorBarsPlusWavePath, optionally used, and only to provoke the dependency. Short name to keep the SetFormula text short.
	WAVE/Z radiusMinus	// radiusErrorBarsMinusWavePath, optionally used, and only to provoke the dependency. Short name to keep the SetFormula text short.
	WAVE/Z anglePlus	// angleErrorBarsPlusWavePath, optionally used, and only to provoke the dependency. Short name to keep the SetFormula text short.
	WAVE/Z angleMinus	// angleErrorBarsMinusWavePath, optionally used, and only to provoke the dependency. Short name to keep the SetFormula text short.

	if( ParamIsDefault(radiusPlus) )
		WAVE/Z radiusPlus=$""	// we don't use this wave, we use tw[row][kRadiusErrorBarMinMaxStr], instead. See below
	endif
	if( ParamIsDefault(radiusMinus) )
		WAVE/Z radiusMinus=$""	// we don't use this wave, we use tw[row][kRadiusErrorBarMinMaxStr], instead. See below
	endif

	if( ParamIsDefault(anglePlus) )
		WAVE/Z anglePlus=$""	// we don't use this wave for anything other than a dependency to to provoke and update to the error bars
	endif
	if( ParamIsDefault(angleMinus) )
		WAVE/Z angleMinus=$""	// we don't use this wave for anything other than a dependency to to provoke and update to the error bars
	endif

	String df= GetWavesDataFolder(wShadowX,1)
	// the following settings are common to all traces in the polar graph

	String radiusFunctionPath= df+"radiusFunction"		// "Linear;Log;Ln"
	String valueAtCenterPath= df+"valueAtCenter"
	String angleDirectionPath=  df+"angleDirection"		// 1 == clockwise, -1 == counter-clockwise"
	String zeroAngleWherePath= df+"zeroAngleWhere"	// 0 = right, 90 = top, 180 = left, -90 = bottom

	SVAR radiusFunctionStr	= $radiusFunctionPath
	NVAR valueAtCenter	= $valueAtCenterPath
	NVAR angleDirection	= $angleDirectionPath
	NVAR zeroAngleWhereDegrees = $zeroAngleWherePath

	//	x = funcR(radius) * cos(funcA(angle))	
	//	y = funcR(radius) * sin(funcA(angle))
	Variable npnts= numpnts(radiusData)
	if( numpnts(wShadowY) != npnts )
		Redimension/N=(npnts) wShadowY, wShadowX
	endif
	if( WaveExists(angleDataOrNull) )
		wShadowX= WMPolarRadiusFunction(radiusData,radiusFunctionStr,valueAtCenter) * cos(WMPolarAngleFunction(angleDataOrNull,zeroAngleWhereDegrees,angleDirection,anglePerCircle))
		wShadowY= WMPolarRadiusFunction(radiusData,radiusFunctionStr,valueAtCenter) * sin(WMPolarAngleFunction(angleDataOrNull,zeroAngleWhereDegrees,angleDirection,anglePerCircle))
	else
		wShadowX= WMPolarRadiusFunction(radiusData,radiusFunctionStr,valueAtCenter) * cos(WMPolarAngleFunction(pnt2x(radiusData,p),zeroAngleWhereDegrees,angleDirection,anglePerCircle))
		wShadowY= WMPolarRadiusFunction(radiusData,radiusFunctionStr,valueAtCenter) * sin(WMPolarAngleFunction(pnt2x(radiusData,p),zeroAngleWhereDegrees,angleDirection,anglePerCircle))
	endif

	WMPolarUpdateFillToOrigin(wShadowX,wShadowY)	
	WMPolarUpdateErrorBars(wShadowX,wShadowY)
	return 0				// the return value isn't important; it's what happens in the routine
End

Function WMPolarRadiusAngleToDrawnXY(tw, row, radius, angle, drawnX, drawnY)
	Wave/T tw				// input (required)
	Variable row
	Variable radius, angle	// inputs; angle is in the units specified by tw[row][kAngleUnits]
	Variable &drawnX, &drawnY	// outputs
	
	// per-trace values are in tw
	Variable anglePerCircle= (CmpStr(tw[row][kAngleUnits],"degrees") == 0) ? 360 : 2 * pi	

	// per-graph values are in the polar graph's data folder, along with tw
	DFREF saveDFR = GetDataFolderDFR()
	SetDataFolder GetWavesDataFolder(tw,1)
	NVAR valueAtCenter
	NVAR zeroAngleWhere	// degrees
	NVAR angleDirection
	SVAR radiusFunction
	SetDataFolder saveDFR
	
	Variable drawnRadius= WMPolarRadiusFunction(radius,radiusFunction,valueAtCenter)
	Variable drawnAngle= WMPolarAngleFunction(angle,zeroAngleWhere,angleDirection,anglePerCircle)
	
	drawnX= drawnRadius * cos(drawnAngle)
	drawnY= drawnRadius * sin(drawnAngle)
End

// returns angle in drawn coordinates radians
Function WMPolarAngleToDrawnAngle(tw, row, dataAngle)
	Wave/T tw				// input (required)
	Variable row
	Variable dataAngle	// inputs; angle is in the units specified by tw[row][kAngleUnits]

	// per-trace values are in tw
	Variable anglePerCircle= (CmpStr(tw[row][kAngleUnits],"degrees") == 0) ? 360 : 2 * pi	

	// per-graph values are in the polar graph's data folder, along with tw
	DFREF saveDFR = GetDataFolderDFR()
	SetDataFolder GetWavesDataFolder(tw,1)
	NVAR zeroAngleWhere	// degrees
	NVAR angleDirection
	SetDataFolder saveDFR
	
	Variable drawnAngle= WMPolarAngleFunction(dataAngle,zeroAngleWhere,angleDirection,anglePerCircle)
	
	return drawnAngle
End


// the only purpose of this routine is to cause any change of the input parameters to trigger an update
// of anything that depends on the output variable.
//	Usage:
//	Variable/G dependentVariable
//	dependentVariable := WMPolarShadowFunctionSettings(radiusFunctionStr,valueAtCenter,zeroAngleWhereDegrees,angleDirection)
//	Variable/G anotherVariable
//	anotherVariable := AnotherFunction(dependentVariable)
//
// AnotherFunction is executed whenever any of radiusFunctionStr,valueAtCenter,zeroAngleWhereDegrees,angleDirection change.
//
Function WMPolarShadowFunctionSettings(radiusFunctionStr,valueAtCenter,zeroAngleWhereDegrees,angleDirection)
	String radiusFunctionStr	// "Linear", "Log", or "Ln"
	Variable valueAtCenter
	Variable zeroAngleWhereDegrees	// 0 = right, 90 = top, 180 = left, -90 = bottom
	Variable angleDirection		// 1 == clockwise, -1 == counter-clockwise"

	return ticks				// the return value isn't important, it's the fact that the output is assigned to something which matters.
								// the input parameters are actually deduced in WMPolarShadowFunctionData
End

// A note about transformations:
// labels values are in data coordinates, and are placed at the drawn location.
// when labeling r,a (data), the label reads r,a, but is drawn at PolarRadiusFunction(r,...),PolarAngleFunction(a,...)

// WMPolarRadiusFunction transforms from data radius to drawn radius
Function WMPolarRadiusFunction(dataRadius,radiusFunctionStr,valueAtCenter)
	Variable dataRadius			// wave[p]
	String radiusFunctionStr	// "Linear", "Log", or "Ln"
	Variable valueAtCenter

	Variable drawnRadius=dataRadius
	strswitch(radiusFunctionStr)
		case "Linear":
			if( valueAtCenter > 0)
				// In this case, radii < -valueAtCenter are shortened by abs(valueAtCenter)
				if( dataRadius > valueAtCenter )
					drawnRadius= dataRadius-valueAtCenter
				elseif( dataRadius < -valueAtCenter )
				 	drawnRadius= dataRadius+valueAtCenter
				else
					drawnRadius = 0
				endif
			elseif( valueAtCenter < 0 )
				 // in this case, radii < value at center are set to 0
				drawnRadius= max(dataRadius-valueAtCenter,0)
			endif
			break
		case "Log":
			drawnRadius=  max(log(dataRadius/valueAtCenter),0)
			break
		case "Ln":
			drawnRadius=  max(ln(dataRadius/valueAtCenter),0)
			break
	endswitch
	return drawnRadius
End

// PolarRadiusFunctionInv transforms drawn radius to data radius
Function OldWMPolarRadiusFunctionInv(drawnRadius,radiusFunctionStr,valueAtCenter)
	Variable drawnRadius
	String radiusFunctionStr	// "Linear", "Log", or "Ln"
	Variable valueAtCenter

	Variable dataRadius

	strswitch(radiusFunctionStr)
		case "Linear":
			dataRadius= drawnRadius + valueAtCenter
			break
		case "Log":
			dataRadius= 10^(drawnRadius) * valueAtCenter
			break
		case "Ln":
			dataRadius= e^(drawnRadius) * valueAtCenter
			break
	endswitch

	return dataRadius
End

// PolarRadiusFunctionInv transforms drawn radius to data radius
Function WMPolarRadiusFunctionInv(drawnRadius,radiusFunctionStr,valueAtCenter)
	Variable drawnRadius
	String radiusFunctionStr	// "Linear", "Log", or "Ln"
	Variable valueAtCenter

	Variable dataRadius

	strswitch(radiusFunctionStr)
		case "Linear":
			if( drawnRadius >= 0)
				dataRadius= drawnRadius + valueAtCenter
			else
				dataRadius= drawnRadius - valueAtCenter
			endif
			break
		case "Log":
			dataRadius= 10^(drawnRadius) * valueAtCenter
			break
		case "Ln":
			dataRadius= e^(drawnRadius) * valueAtCenter
			break
	endswitch

	return dataRadius
End

// WMPolarAngleFunction transforms from data angle in angleUnits to drawn angle in radians
Function WMPolarAngleFunction(dataAngle,zeroAngleWhereDegrees,angleDirection,anglePerCircle)
	Variable dataAngle					// in degrees or radians, depending on anglePerCircle
	Variable zeroAngleWhereDegrees	// 0 = right, 90 = top, 180 = left, -90 = bottom
	Variable angleDirection		// 1 == clockwise, -1 == counter-clockwise"
	Variable anglePerCircle		// 2 * pi for radians, 360 for degrees

	Variable zeroAngleRadians= WMPolarDegToRad(zeroAngleWhereDegrees)
	
	if( anglePerCircle == 360 ) // dataAngle is in degrees
		dataAngle= WMPolarDegToRad(dataAngle)// we need radians
	endif

	Variable drawnAngleRadians
	if( angleDirection == 1 ) // clock-wise
		drawnAngleRadians = zeroAngleRadians - dataAngle
	else
		drawnAngleRadians = zeroAngleRadians + dataAngle	// counter-clockwise
	endif
	return drawnAngleRadians
End

// PolarAngleFunctionInv transforms from drawn angle in radians to data angle in angleUnits
Function WMPolarAngleFunctionInv(drawnAngle,zeroAngleWhereDegrees,angleDirection,anglePerCircle)
	Variable/D drawnAngle	// drawn angles are ALWAYS in radians
	Variable zeroAngleWhereDegrees	// 0 = right, 90 = top, 180 = left, -90 = bottom
	Variable angleDirection		// 1 == clockwise, -1 == counter-clockwise"
	Variable anglePerCircle		// 2 * pi for data radians, 360 for data degrees

	Variable zeroAngleRadians= WMPolarDegToRad(zeroAngleWhereDegrees)

	Variable dataAngle
	if( angleDirection == 1 ) // clock-wise
		dataAngle = zeroAngleRadians - drawnAngle
	else
		dataAngle= drawnAngle - zeroAngleRadians	// counter-clockwise
	endif

	if( anglePerCircle == 360 ) // data Angles are in degrees
		dataAngle= WMPolarRadToDeg(dataAngle)
	endif
	return dataAngle		// degrees or radians
End


//
// WMPolarSetRadiusMinsMaxes records the minima and maxima of the radius for grid auto-scale radius.
//
//	These values are stored in the polarTracesTW wave in the kRadiusMin and kRadiusMax columns.
//	Note that these are the data values, not the drawn values.
//
Function WMPolarSetRadiusMinsMaxes(pathToPolarTracesTW,radiusData[,radiusYWave])
	String pathToPolarTracesTW
	Wave radiusData
	WAVE/Z radiusYWave	// radiusErrorBarsYWave, optionally used, and only to provoke the dependency. Short name to keep the SetFormula text short.
	
	if( ParamIsDefault(radiusYWave) )
		WAVE/Z radiusYWave=$""	// we don't use this wave, we use tw[row][kRadiusErrorBarMinMaxStr], instead. See below
	endif

	// Measure the radius extent
	
	Wave/T tw=$pathToPolarTracesTW
	Variable row= WMPolarRadiusWaveRow(tw,radiusData)
	if( row == -1 )	
		return -1
	endif
	
	WaveStats/Q radiusData
	Variable radiusMin= V_Min, radiusMax= V_max
	// if error bars, consider the error bars radii, too
	// the radii extents (including error waves) are computed in WMPolarUpdateErrorBars(),
	// and stored in tw[row][kRadiusErrorBarMinMaxStr]
	Variable haveErrorBars= CmpStr(tw[row][kRadiusErrorBarsMode],"None") != 0
	if( haveErrorBars )
		Variable radiusErrorMin, radiusErrorMax
		String minMaxStr= tw[row][kRadiusErrorBarMinMaxStr]
		sscanf minMaxStr, "%g,%g", radiusErrorMin, radiusErrorMax
		if( V_Flag == 2 )
			radiusMin= min(radiusMin,radiusErrorMin)
			radiusMax= max(radiusMin,radiusErrorMax)
		endif
	endif
	
	String theMin, theMax
	sprintf theMin, "%.14g", radiusMin
	sprintf theMax, "%.14g", radiusMax
	tw[row][kRadiusMin]= theMin		// could be negative!
	tw[row][kRadiusMax]= theMax		// could be negative!
	
	if( WMPolarWantAutoRadiusRange(tw) )
		WMPolarUpdateAxes(tw,0)	//  WMPolarUpdateAxes will compute the max and min radii for all traces and expand or contract the grid accordingly
	endif
	
	return row
End

// true if the named string in the wave's data folder is "auto"
Function WMPolarStrIsAuto(tw,strNameInDF)
	Wave/T tw	// could be just about any wave, but this is the most useful one.
	String strNameInDF
	
	String df= GetWavesDataFolder(tw,1)

	SVAR autoOrManualStr= $(df+strNameInDF)
	return CmpStr(autoOrManualStr,"auto") == 0
End


// Returns truth that the polar graph has auto radius axis range selected
Function WMPolarWantAutoRadiusRange(tw)
	Wave/T tw	// could be just about any wave, but this is the most useful one.

	return WMPolarStrIsAuto(tw,"doRadiusRange")
End

// true if "Auto Radius Ticks, Approximately:" is checked in the Ticks tab.
Function WMPolarWantAutoRadiusTicks(tw)
	Wave/T tw	// could be just about any wave, but this is the most useful one.
	
	return WMPolarStrIsAuto(tw,"doMajorRadiusTicks")
End

// true if "Auto Angle Ticks, Approximately:" is checked in the Ticks tab.
Function WMPolarWantAutoAngleTicks(tw)
	Wave/T tw	// could be just about any wave, but this is the most useful one.
	
	return WMPolarStrIsAuto(tw,"doMajorAngleTicks")
End

// Returns the matching row in the polarTracesTW text wave, or -1 if not found
Function  WMPolarRadiusWaveRow(tw,radiusData)
	Wave/T tw
	Wave radiusData

	Variable row, rows = DimSize(tw,0)
	String radiusDataPath= GetWavesDataFolder(radiusData,2)
	for( row=0; row < rows; row += 1 )
		if( CmpStr(radiusDataPath,tw[row][kRadiusWavePath]) == 0 )
			return row
		endif
	endfor
	return -1
End

// Returns the matching row in the polarTracesTW text wave, or -1 if not found
Function WMPolarShadowWaveRow(wShadowY)
	WAVE wShadowY

	String shadowYName=NameOfWave(wShadowY)
	String df= GetWavesDataFolder(wShadowY,1)	// we rely on the fact that the shadow wave and the polarTracesTW wave are in the same data folder
	WAVE/T/Z tw= $(df+"polarTracesTW")

	if( WaveExists(tw) )
		Variable row, rows = DimSize(tw,0)
		for( row=0; row < rows; row += 1 )
			if( CmpStr(shadowYName,tw[row][kShadowTraceName]) == 0 )
				return row
			endif
		endfor
	endif
	return -1	// not found
end

// Returns the matching row in the polarTracesTW text wave, or -1 if not found
Function WMPolarRadiusErrorBarsWaveRow(wRadiusErrorBarsY)
	WAVE wRadiusErrorBarsY

	String radiusErrorWaveName=NameOfWave(wRadiusErrorBarsY)	// polarRadiusErrorBarY0
	String df= GetWavesDataFolder(wRadiusErrorBarsY,1)	// we rely on the fact that the shadow wave and the polarTracesTW wave are in the same data folder
	WAVE/T/Z tw= $(df+"polarTracesTW")

	if( WaveExists(tw) )
		Variable row, rows = DimSize(tw,0)
		for( row=0; row < rows; row += 1 )
			if( CmpStr(radiusErrorWaveName,tw[row][kRadiusErrorsBarsY]) == 0 )
				return row
			endif
		endfor
	endif
	return -1	// not found
End

// Returns the matching row in the polarTracesTW text wave, or -1 if not found
Function WMPolarAngleErrorBarsWaveRow(wAngleErrorBarsY)
	WAVE wAngleErrorBarsY

	String angleErrorWaveName=NameOfWave(wAngleErrorBarsY)	// polarRadiusErrorBarY0
	String df= GetWavesDataFolder(wAngleErrorBarsY,1)	// we rely on the fact that the shadow wave and the polarTracesTW wave are in the same data folder
	WAVE/T/Z tw= $(df+"polarTracesTW")

	if( WaveExists(tw) )
		Variable row, rows = DimSize(tw,0)
		for( row=0; row < rows; row += 1 )
			if( CmpStr(angleErrorWaveName,tw[row][kAngleErrorsBarsY]) == 0 )
				return row
			endif
		endfor
	endif
	return -1	// not found
End

// See also WMNewPolarGraph()
Function WMPolarNewButton(ctrlName) : ButtonControl
	String ctrlName

	// source of settings is either the _default_ data folder, or an existing graph's data folder.
	ControlInfo/W=WMPolarGraphPanel mainNewStylePop
	String srcGraphName= S_Value		// graph name or "_default_"

	String srcDF= WMPolarGraphDF(srcGraphName)
	if( strlen(srcDF) == 0 || DataFolderExists(srcDF) == 0 )
		DoAlert 0, "Polar settings for graph \"" + srcGraphName +"\" are missing. Expected datafolder is "+srcDF
		return 0
	endif

	WMPolarGraphDefaults("_default_")

	String newGraphName= WMPolarNewGraphName()
	String destDF= WMPolarGraphDF(newGraphName) // returns full path from dfName

	Display/W=(10,45,360,345)
	DoWindow/C $newGraphName
	WMPolarSaveSettingsName(newGraphName,newGraphName)	// initially the graph name and data folder name are the same.
	
	SetWindow $newGraphName hook=WMPolarGraphHook, hookEvents=1	// mouse button events

	// copy the settings
	if( DataFolderExists(destDF) )
		WMPolarCleanOutDF(destDF)	// should remove any dependencies that prevent folder deletion.
		KillDataFolder/Z $destDF
	endif
	DuplicateDataFolder $srcDF, $destDF
	WMPolarCleanOutDF(destDF)
	
	// 9.03: initialize the virtual drawing layers for newly-created polar graphs
	String drawLayer = WMPolarGraphWantedDrawLayer(newGraphName)
	WMPolarEnsureVirtualLayers(newGraphName, drawLayer)
	
	// 9.03: allow drawing polar axes, grid, etc without polar traces or an image
	WAVE/T/Z tw= WMPolarEnsurePolarGraphTracesWave(newGraphName)	// Make polar drawing code happy
	WMPolarUpdateAutoRangeTrace(newGraphName,tw,-1, -1, 1, 1)	// append default autoscale trace
	WMPolarInitializeAxes(newGraphName)	// hide axes
	
	DoWindow/F WMPolarGraphPanel	// nothing interesting can be done with an empty polar graph, 
//	WMPolarPanelUpdate()				// panel activation will cause WMPolarPanelUpdate to run, anyway
End


// The user could have renamed a polar graph,
// leaving PolarGraph0 an available graph name
// but not an available data folder name
Function/S WMPolarNewGraphName()

	Variable startIndex= 0
	do
		String newGraphName= UniqueName("PolarGraph",5,startIndex)
		String destDF= WMPolarGraphDF(newGraphName)
		startIndex= str2num(newGraphName[10,31])+1
	while(DataFolderExists(destDF) )
	return newGraphName
End

// Igor 4.05A on the PC caused an error when killing the data folder (because the first x disp
// wasn't properly removed by RemoveFromGraph). This function is called if that error is detected
// by the GetRTError(1) call in WMPolarGraphHook().
Function WMPolarRemovePolarGraphData(graphName,settings)
	String graphName
	String settings
	
	String polarDF= WMPolarSettingsDF(settings)
	if( DatafolderExists(polarDF) )
		if( strlen(graphName) )
			DoWindow/K $graphName
		endif
		WMPolarCleanOutDF(polarDF)
		KillDataFolder/Z $polarDF
	endif
End

static Function GraphMacroExists(graphName)
	String graphName
	
	Variable recreationMacroExists= exists("ProcGlobal#"+graphName)
	return recreationMacroExists
End

// Counts only open polar graph uses of the data folder, not saved recreation macros.
// Lies about WMPolarGraphDF("_default_") so it always looks heavily used.
Function WMPolarDFUseCount(polarDF)
	String polarDF // full path, as in String polarDF= WMPolarGraphDF(graphName)

	Variable count = 0
	if( DataFolderExists(polarDF) )
		String defaultDF= WMPolarGraphDF("_default_")
		if( CmpStr(polarDF,defaultDF) == 0 ) // don't EVER delete the default DF 
			count = 999
		else
			Variable i=0
			do
				String graphName= WinName(i, 1)
				if( strlen(graphName) == 0 )
					break
				endif
				if( WMPolarIsPolarGraph(graphName) )
					String df= WMPolarGraphDF(graphName)
					if( CmpStr(df, polarDF) == 0 )
						count += 1
					endif
				endif
				i += 1
			while(1)
		endif
	endif
	return count
End

static Function PossiblyRelocateToNewDataFolder(polarGraphName)
	String polarGraphName

	String polarDF= WMPolarGraphDF(polarGraphName) // full path
	Variable dfUseCount = WMPolarDFUseCount(polarDF)
	Variable relocated= 0
	if( dfUseCount > 1 )
		// Relocate only if the polarGraphName doesn't match the settings name.
		// This protects the "real" or "original" polar graph from
		// being renamed when an "imposter" like PolarGraph0_1 is created
		// by the user choosing the recreation macro while the original
		// polar graph is still open.
		String settings = WMPolarSettingsNameForGraph(polarGraphName)
		if( CmpStr(settings, polarGraphName) != 0 )
			String newDFName = RelocateToNewDataFolder(polarGraphName)
			Execute/P/Q/Z "WMPolarPanelUpdate(1)"
			relocated= 1
		endif
	endif
	return relocated
End

// handle case where user changes background color when labels are already opaque.
static Function PossiblyUpdateLabelBackgrounds(graphName)
	String graphName

	Variable updated=0
	
	NVAR/Z tickLabelOpaque = $WMPolarGraphDFVar(graphName,"tickLabelOpaque")
	if( NVAR_Exists(tickLabelOpaque) && tickLabelOpaque )
		// see if the plot color changed
		NVAR/Z plotAreaRed = $WMPolarGraphDFVar(graphName,"plotAreaRed")
		NVAR/Z plotAreaGreen = $WMPolarGraphDFVar(graphName,"plotAreaGreen")
		NVAR/Z plotAreaBlue = $WMPolarGraphDFVar(graphName,"plotAreaBlue")
		if( NVAR_Exists(plotAreaRed) && NVAR_Exists(plotAreaGreen) && NVAR_Exists(plotAreaBlue) )
			String layer
			Variable plotRed,plotGreen,plotBlue
			WMPolarDrawInfo(graphName,layer,plotRed,plotGreen,plotBlue)
			Variable different = plotAreaRed != plotRed || plotAreaGreen != plotGreen || plotAreaBlue != plotBlue 
			if( different )
				Variable alreadyBlocked = WMPolarBlockModifiedWindowHook(graphName,1)	// block
				WMPolarAxesRedrawGraphNow(graphName)
				WMPolarBlockModifiedWindowHook(graphName,alreadyBlocked)
				updated=1
			endif
		endif
	endif
	
	return updated
End


// Without changing the existing polar graph's name,
// find an available graphName without a matching datafolder.
// Then create that data folder, copy the existing graph's data into it
// and add the necessary dependencies so that if the conflicting polar graph's
// data folder is deleted the dependencies such as:
//
// radiusTarget := ProcGlobal#WMPolarSetRadiusMinsMaxes("root:Packages:WMPolarGraphs:PolarGraph1:polarTracesTW",root:WR)
// shadowTarget := ProcGlobal#WMPolarShadowFunction(polarX0,polarY0,root:WR,root:WA,radiusFunction,valueAtCenter,zeroAngleWhere,angleDirection,360)
//
// and globals in the relocated data folder that fully support the polar graph are unaffected.
//
// This is needed when the user keeps a polar graph open
// but runs the saved recreation macro, getting a graph name like "PolarGraph0_1"
//
// Returns settings (data folder) name for the relocated data folder.
static Function/S RelocateToNewDataFolder(polarGraphName)
	String polarGraphName // must be an existing polar graph

	String sourceDF= WMPolarGraphDF(polarGraphName) // full path without trailing ':'

	// Choose a nonexistent data folder name for the named graph.
	//
	// All of the waves live in the PolarGraph0 data folder, but we need them to
	// be separated from the PolarGraph0 data folder
	// so that the two polar graph's settings don't overwrite each other.

	// First, see if the PolarGraphs:polarGraphName is available, as that is the most reasonable choice
	String newSettingsDFName = polarGraphName
	String polarDF= WMPolarSettingsDF(newSettingsDFName)
	if( DatafolderExists(polarDF) || GraphMacroExists(newSettingsDFName) )
		// Using the existing graph name won't work, choose an unused name
		newSettingsDFName = WMPolarNewGraphName()	// a PolarGraphnnn name with no matching data folder (yet)
		polarDF= WMPolarSettingsDF(newSettingsDFName)
	endif

	// Record the selected new data folder
	WMPolarSaveSettingsName(polarGraphName, newSettingsDFName) 	// essentially, SetWindow $polarGraphName userdata(polarGraphSettings)=newSettingsDFName

	// Destination path to the settings Strings, Variables, , dependency variables, shadow waves, and tw
	String destDF= WMPolarSettingsDF(newSettingsDFName)

	// copy the settings, and waves, including dependency targets, polarTracesTW, autoscale waves.
	DuplicateDataFolder/O=3/Z $sourceDF, $destDF	// /O requires Igor 8

	// Replace traces pointing to old datafolder
	String df = WMPolarSetPolarGraphDF(polarGraphName)
	ReplaceWave/W=$polarGraphName allinCDF
	SetDataFolder df

	// establish new dependencies in the new data folder for each polar graph trace in polarTracesTW
	WMPolarUpdateShadowWave(polarGraphName,$"")

	return newSettingsDFName
End

Function WMPolarGraphHook(infoStr)
	String infoStr

	Variable statusCode= 0
	String event= StringByKey("EVENT",infoStr)
	String graphName= StringByKey("WINDOW",infoStr)
	Variable modifiers= NumberByKey("MODIFIERS", infoStr)
	String settings, cmd
	strswitch(event)
		case "renamed":
			String/G $WMPolarGraphDFVar(graphName,"graphName") = graphName
			break
		case "kill":
			// On Mac OS X, there is no guarantee that the graphName is the top-most window or top-most polar graph!
			SetWindow $graphName userdata(WMPolarKeepWindowOnScreen)= ""	// allow another queued call to WMPolarKeepWindowOnScreen() by WMPolarGraphHook().
			String polarDF= WMPolarGraphDF(graphName)
			if( strlen(polarDF) )
				Variable recreationMacroExists = GraphMacroExists(graphName)
				if( recreationMacroExists != 5 )	// no saved window recreation macro
					String defaultDF= WMPolarGraphDF("_default_")
					if( DataFolderExists(polarDF) && CmpStr(polarDF,defaultDF) != 0 ) // don't EVER delete the default DF 
						Variable dfUseCount = WMPolarDFUseCount(polarDF) // number of open polar graphs using the data folder, should always be 1. We presume graphName names one of the using polar graphs.
						if( dfUseCount < 2 ) // don't do this if another polar graph is using the DF.
							WMPolarRemoveAllTraces(graphName)
							settings= WMPolarSettingsNameForGraph(graphName)
							WMPolarSaveSettingsName(graphName, "") // fixes the problem of polar graphs losing their settings; graph no longer marked as a Polar Graph.
							WMPolarCleanOutDF(polarDF)
							KillDataFolder/Z $polarDF	// can get an error if the panel references globals in the DF.
							if (V_Flag || GetRTError(1))
								sprintf cmd, "%s#WMPolarRemovePolarGraphData(\"%s\",\"%s\")", GetIndependentModuleName(), graphName, settings
								Execute/P/Q cmd // executes after WMPolarPanelUpdate(). WMPolarPanelUpdate() disconnects from the about-to-be-killed data folder.
							endif
						endif
					endif
				endif
				WMPolarPanelUpdate(1)
				String topGraphName= WMPolarTopPolarGraph()
				if( strlen(topGraphName) <= 0 )
					DoWindow/K WMPolarResolutionPanel	// releases the SetVariable 
				endif
			endif
			break
		case "resize":
			// keep window on screen (only if VertCrossing and HorizCrossing axes are on the graph)
			String axes=AxisList(graphName)
			Variable haveAxes= (FindListItem("VertCrossing",axes) >= 0) && (FindListItem("HorizCrossing",axes) >= 0)
			if( haveAxes )
				WAVE/Z/T tw= $WMPolarGraphTracesTW(graphName)
				if( WaveExists(tw) )
					WMPolarAxesRedraw(graphName,tw)
				endif
				String userdata=GetUserData(graphName,"","WMPolarKeepWindowOnScreen")
				// Queue up only one command to restore the window position (this deals with dynamic resizing)
				if( strlen(userdata) == 0 )
					SetWindow $graphName userdata(WMPolarKeepWindowOnScreen)= "Pending"
					sprintf cmd, "%s#WMPolarKeepWindowOnScreen(\"%s\")", GetIndependentModuleName(), graphName
					Execute/P/Q cmd
				endif
			endif
			break
		case "modified": // called when annotations are deleted
			// for Error Bars colors "Use Trace Color" radio button.
			if( strlen(WMPolarGraphDF(graphName)) )
				Variable blocked= WMPolarBlockModifiedWindowHook(graphName,2) 	// 2 == query only
				if( !blocked )
					PossiblyRelocateToNewDataFolder(graphName)
					settings= WMPolarSettingsNameForGraph(graphName)
					WMPolarSaveSettingsName(graphName, settings) // in case of DeleteAnnotations, but this will provoke another modified event if the settings value changed
					WMPolarCheckErrorBarTraceColors(graphName)	// this can cause another "modified" event.
					PossiblyUpdateLabelBackgrounds(graphName) // handle case where user changes background color when labels are already opaque.
				endif
			endif
			break
		case "activate":
			String/G $WMPolarGraphDFVar(graphName,"graphName") = graphName
			PossiblyRelocateToNewDataFolder(graphName)
			settings= WMPolarSettingsNameForGraph(graphName)
			WMPolarSaveSettingsName(graphName, settings) 	// in case of DeleteAnnotations
			SVAR/Z previousTopGraph= $WMPolarDFVar("previousTopGraph")
			if( SVAR_Exists(previousTopGraph) )
				String topGraphNow= graphName
				if( CmpStr(topGraphNow,previousTopGraph) != 0 )
					WMPolarPanelUpdate(1)
					WMPolarUpdateLayerPanel()
				endif
			endif
			SetWindow $graphName userdata(WMPolarKeepWindowOnScreen)= ""	// allow another queued call to WMPolarKeepWindowOnScreen() by WMPolarGraphHook().
			BuildMenu "Graph"	// update "Modify Polar Graph" menu item
			break
		case "deactivate":
			SetWindow $graphName userdata(WMPolarKeepWindowOnScreen)= ""	// allow another queued call to WMPolarKeepWindowOnScreen() by WMPolarGraphHook().
			BuildMenu "Graph"	// update "Modify Polar Graph" menu item
			break
		case "mousedown":		// first half of the detection for shifting the graph with the hand tool.
			NVAR/Z mouseDownModifiers= $WMPolarGraphDFVar(graphName,"mouseDownModifiers")
			if( NVAR_Exists(mouseDownModifiers) )
				mouseDownModifiers= modifiers
				Variable mouseX= NumberByKey("MOUSEX", infoStr)
				Variable mouseY= NumberByKey("MOUSEY", infoStr)
				String options= "ONLY:polarAutoscaleTrace;WINDOW:"+graphName
				String tInfo=TraceFromPixel(mouseX,mouseY,options)
				String clickedTrace= StringByKey("TRACE",tInfo)
				if( CmpStr(clickedTrace,"polarAutoscaleTrace") == 0 )
					statusCode=1	// don't offset this trace
				endif
			endif
			break
		case "mouseup":		// second half of the detection for shifting the graph with the hand tool.
			NVAR/Z mouseDownModifiers= $WMPolarGraphDFVar(graphName,"mouseDownModifiers")
			if( NVAR_Exists(mouseDownModifiers) )
				if( mouseDownModifiers %& 4 )	// option or alt, this was the hand tool
					WAVE/Z/T tw= $WMPolarGraphTracesTW(graphName)
					if( WaveExists(tw) )
						WMPolarAxesRedraw(graphName,tw)
					endif
				endif
				mouseDownModifiers= 0	// mousedown doesn't work if in tools mode, so we reset the modifiers to avoid redrawing again.
			endif
			break
	endswitch

	return statusCode				// 0 if nothing done, else 1 or 2
End

// returns the value of whether the modified hook was blocked before WMPolarBlockModifiedWindowHook() was called
Function WMPolarBlockModifiedWindowHook(graphName,allow_block_query)
	String graphName
	Variable allow_block_query	// pass 0 to allow the modified event, 1 to block, 2 to query if it is blocked without changing its state
	
	String userData= GetUserData(graphName, "", "WMPolarModifiedHook")
	switch( allow_block_query )
		case 0:	// allow
			SetWindow $graphName userData(WMPolarModifiedHook)=""
			break
		case 1:	// block
			SetWindow $graphName userData(WMPolarModifiedHook)="Blocked"
			break
		default:	// query
			break
	endswitch
	Variable modifiedHookBlocked= strlen(userData) != 0
	return modifiedHookBlocked
End

Function WMPolarRemoveAllTraces(graphName)
	String graphName

	String list= TraceNameList(graphName,";",1)
	String name
	Variable n
	for( n= ItemsInList(list)-1; n >= 0 ; n -= 1)	// work backwards so that trace#1 is removed before trace#0
		name= StringFromList(n,list)
		RemoveFromGraph/Z/W=$graphName $name
	endfor
End

// control names must start with "range"
Function WMPolar_RangeTab(show)
	Variable show
	
	if( show )
		ControlInfo/W=WMPolarGraphPanel commonPolarTab
		if( V_Value != kTabRange )		// avoid flashing
			TabControl commonPolarTab win= WMPolarGraphPanel, value= kTabRange
		endif
	endif
	Variable disable= show ? 0 : 1

	if( show )
		SetDrawLayer/W=WMPolarGraphPanel UserBack
		SetDrawEnv/W=WMPolarGraphPanel fillpat= 0
		DrawOval/W=WMPolarGraphPanel 123,133,60,70
		SetDrawEnv/W=WMPolarGraphPanel fstyle= 1
		DrawText/W=WMPolarGraphPanel 38,109,"0"
		SetDrawEnv/W=WMPolarGraphPanel fstyle= 1
		DrawText/W=WMPolarGraphPanel 88,157,"0"
		SetDrawEnv/W=WMPolarGraphPanel fstyle= 1
		DrawText/W=WMPolarGraphPanel 133,109,"0"
		SetDrawEnv/W=WMPolarGraphPanel fstyle= 1
		DrawText/W=WMPolarGraphPanel 87,63,"0"
		DrawLine/W=WMPolarGraphPanel 195,84,241,84
		SetDrawEnv/W=WMPolarGraphPanel arrow= 2
		DrawLine/W=WMPolarGraphPanel 87,107,37,157
		SetDrawEnv/W=WMPolarGraphPanel gstart
		DrawLine/W=WMPolarGraphPanel 87,102,97,102
		DrawLine/W=WMPolarGraphPanel 92,97,92,107
		SetDrawEnv/W=WMPolarGraphPanel gstop
		SetDrawEnv/W=WMPolarGraphPanel arrow= 2
		DrawLine/W=WMPolarGraphPanel 186,279,195,279
		SetDrawEnv/W=WMPolarGraphPanel arrow= 2
		DrawLine/W=WMPolarGraphPanel 186,357,195,357
		SetDrawEnv/W=WMPolarGraphPanel arrow= 2
		DrawLine/W=WMPolarGraphPanel 186,385,195,385
		SetDrawEnv/W=WMPolarGraphPanel arrow= 2
		DrawLine/W=WMPolarGraphPanel 186,302,195,302
		SetDrawEnv/W=WMPolarGraphPanel arrow= 1,fillpat= 0
		DrawArc/W=WMPolarGraphPanel 195.333333333333,84,38,0,45
		SetDrawEnv/W=WMPolarGraphPanel fillpat= 0
		DrawPoly/W=WMPolarGraphPanel 241,84,1,1,{241,84,194.665467641414,84,226.499839920694,52.1656277207196}
		SetDrawEnv/W=WMPolarGraphPanel fsize= 16,textxjust= 1,textyjust= 1
		DrawText/W=WMPolarGraphPanel 218.666666666667,74.9999999999998,"θ"
		SetDrawEnv/W=WMPolarGraphPanel fillpat= 0
		DrawPoly/W=WMPolarGraphPanel 240.666666666667,94,1,1,{240.666666666667,94,194.666666666667,94,225.837343770495,125.170677103828}
		SetDrawEnv/W=WMPolarGraphPanel arrow= 2,fillpat= 0
		DrawArc/W=WMPolarGraphPanel 194.666666666667,94,37.8491156509047,-45,0
		SetDrawEnv/W=WMPolarGraphPanel fsize= 16,textxjust= 1,textyjust= 1
		DrawText/W=WMPolarGraphPanel 218.666666666667,104.333333333333,"θ"
	endif
	
	// Origins
	GroupBox rangeOriginsGroup  win= WMPolarGraphPanel,pos={10,32},size={161,174},title="Origins",  disable=disable

	// Polar Coordinates apply to all traces, and we want them to update when the coordinate values change
	NVAR zeroAngleWhere= $WMPolarTopOrDefaultDFVar("zeroAngleWhere")	// 0 = right, 90 = top, 180 = left, -90 = bottom
	CheckBox rangeZeroLeftRadio  win= WMPolarGraphPanel,pos={54,95},size={16,14},title="",value= (zeroAngleWhere ==180),mode=1,  proc=WMPolarRangeOriginRadioProc, disable=disable
	CheckBox rangeZeroTopRadio  win= WMPolarGraphPanel,pos={86,65},size={16,14},title="",value= (zeroAngleWhere ==90),mode=1,  proc=WMPolarRangeOriginRadioProc, disable=disable
	CheckBox rangeZeroRightRadio  win= WMPolarGraphPanel,pos={116,95},size={16,14},title="",value= (zeroAngleWhere ==0),mode=1,  proc=WMPolarRangeOriginRadioProc, disable=disable
	CheckBox rangeZeroBottomRadio  win= WMPolarGraphPanel,pos={86,128},size={16,14},title="",value= (zeroAngleWhere ==-90),mode=1, proc=WMPolarRangeOriginRadioProc, disable=disable
	
	SetVariable rangeRadiusAtCenter  win= WMPolarGraphPanel,pos={21,161},size={140,15},title="Radius Origin",  proc=WMPolarSetVarProc, disable=disable
	SetVariable rangeRadiusAtCenter  win= WMPolarGraphPanel,limits={-Inf,Inf,0},value=$WMPolarTopOrDefaultDFVar("valueAtCenter")

	Button rangeOriginCenter win= WMPolarGraphPanel,pos={32,180},size={119,20},proc=WMPolarRangeCenterButtonProc,title="Center In Graph", disable=disable
	
	// Rotation
	GroupBox rangeRotationGroup  win= WMPolarGraphPanel,pos={180,32},size={122,109},title="Rotation",  disable=disable

	// Polar Coordinates apply to all traces, and we want them to update when the coordinate values change
	NVAR angleDirection= $WMPolarTopOrDefaultDFVar("angleDirection")	// 1 == clockwise, -1 == counter-clockwise"

	CheckBox rangeClockwiseRadio  win= WMPolarGraphPanel,pos={245,107},size={34,14},title="CW",value= (angleDirection==1),mode=1, proc=WMPolarRangeRotationRadioProc, disable=disable
	CheckBox rangeCounterclockwiseRadio  win= WMPolarGraphPanel,pos={245,63},size={40,14},title="CCW",value= (angleDirection!=1),mode=1, proc=WMPolarRangeRotationRadioProc, disable=disable
	
	// Radius Lin/Log
	GroupBox rangeRadiusLinLogGroup  win= WMPolarGraphPanel,pos={180,142},size={122,64},title="Radius",  disable=disable

	// Polar Coordinates apply to all traces, and we want them to update when the coordinate values change
	SVAR radiusFunction= $WMPolarTopOrDefaultDFVar("radiusFunction")	// "Linear;Log;Ln"
	CheckBox rangeRadiusLinearRadio  win= WMPolarGraphPanel,pos={194,160},size={50,14},title="Linear",value= (CmpStr(radiusFunction,"Linear") == 0),mode=1, proc=WMPolarRangeRadFuncRadioProc,  disable=disable
	CheckBox rangeRadiusLogRadio  win= WMPolarGraphPanel,pos={254,160},size={34,14},title="Log",value= (CmpStr(radiusFunction,"Log") == 0),mode=1, proc=WMPolarRangeRadFuncRadioProc, disable=disable
	Button rangeZoomIn,win= WMPolarGraphPanel,pos={189,180},size={62,20},proc=WMPolarRangeZoomButtonProc,title="Zoom In", disable=disable
	Button rangeZoomOut,win= WMPolarGraphPanel,pos={259,180},size={35,20},proc=WMPolarRangeZoomButtonProc,title="Out", disable=disable

	// Axes Ranges
	GroupBox rangeRangesGroup  win= WMPolarGraphPanel,pos={8,211},size={297,206},title="Axes Ranges",  disable=disable
		// Radius Auto Range
	SVAR doRadiusRange= $WMPolarTopOrDefaultDFVar("doRadiusRange")	// "manual" or "auto"
	Variable doAuto= CmpStr(doRadiusRange,"auto") == 0
	
	CheckBox rangeAutoMinIsOrigin win= WMPolarGraphPanel,pos={202,231},size={124,14},proc=WMPolarCheckboxProc,title="Include Origin",  disable=disable
	CheckBox rangeAutoMinIsOrigin win= WMPolarGraphPanel,variable= $WMPolarTopOrDefaultDFVar("doRadiusRangeMaxOnly")

	CheckBox rangeRadiusAutoRadio  win= WMPolarGraphPanel,pos={38,231},size={123,14},title="Autoscale Radius Axes",  disable=disable
	CheckBox rangeRadiusAutoRadio  win= WMPolarGraphPanel,value=doAuto,mode=1, proc=WMPolarRangeRadRangeRadioProc
		// Radius Manual Range
	GroupBox rangeRadiusManualGroup  win= WMPolarGraphPanel,pos={14,250},size={284,68},title="                                       ",  disable=disable
	CheckBox rangeRadiusManualRadio  win= WMPolarGraphPanel,pos={38,253},size={108,14},title="Manual Radius Range",  disable=disable
	CheckBox rangeRadiusManualRadio  win= WMPolarGraphPanel,value=!doAuto,mode=1, proc=WMPolarRangeRadRangeRadioProc
	
	Variable rangeDisable= disable
	Variable frame=1
	if( rangeDisable == 0 && doAuto )
		rangeDisable= 2	// show disabled
		frame=0
	endif
	SetVariable rangeRadiusManualInner  win= WMPolarGraphPanel,pos={35,272},size={150,15},title="Inner Radius:", proc=WMPolarSetVarProc, disable=rangeDisable
	SetVariable rangeRadiusManualInner  win= WMPolarGraphPanel,limits={-Inf,Inf,0},value=$WMPolarTopOrDefaultDFVar("innerRadius"), frame=frame
	
	SetVariable rangeRadiusManualOuter  win= WMPolarGraphPanel,pos={35,295},size={150,15},title="Outer Radius:", proc=WMPolarSetVarProc,  disable=rangeDisable
	SetVariable rangeRadiusManualOuter  win= WMPolarGraphPanel,limits={-Inf,Inf,0},value=$WMPolarTopOrDefaultDFVar("outerRadius"), frame=frame

	Button rangeRadiusManualOriginButton  win= WMPolarGraphPanel,pos={200,269},size={90,20},title="Set To Origin",  proc=WMPolarRangeSetOriginButtonProc, disable=rangeDisable
	
	// disable if no polar trace and no polar image
	Variable disableAuto = rangeDisable
	if( disableAuto == 0 )
		String graphName= WMPolarTopPolarGraph()
		if( strlen(graphName) == 0 )
			disableAuto= 2
		else
			String traces= WMPolarTraceNameList(0)
			WAVE/Z image= WMPolarGraphGetImage(graphName, 0)
			if( strlen(traces)==0 && !WaveExists(image) )
				disableAuto=2
			endif
		endif
	endif
	Button rangeRadiusManualAutoButton  win= WMPolarGraphPanel,pos={200,291},size={90,20},title="Set To Auto",proc=WMPolarRangeSetAutoButtonProc, disable=disableAuto

		// Angle Manual Range
	GroupBox rangeAngleManualGroup  win= WMPolarGraphPanel,pos={14,322},size={284,82},title="Angle Axes Range",  disable=disable

	SetVariable rangeAngleManualStart  win= WMPolarGraphPanel,pos={35,351},size={120,15},title="Start Angle:", proc=WMPolarSetVarProc,  disable=disable
	SetVariable rangeAngleManualStart  win= WMPolarGraphPanel,limits={-360,360,15},value=$WMPolarTopOrDefaultDFVar("angle0")
	
	SetVariable rangeAngleManualExtent  win= WMPolarGraphPanel,pos={35,377},size={120,15},title="Angle Extent:", proc=WMPolarSetVarProc,  disable=disable
	SetVariable rangeAngleManualExtent  win= WMPolarGraphPanel,limits={0,360,15},value=$WMPolarTopOrDefaultDFVar("angleRange")
	
	PopupMenu rangeAngleManualSetStartPop  win= WMPolarGraphPanel,pos={202,349},size={70,20}, title="Set to:",  proc= WMPolarRangeSetAngle, disable=disable
	PopupMenu rangeAngleManualSetStartPop  win= WMPolarGraphPanel,mode=0,value= #"\" 0; 45; 90;135;180; -45; -90; -135; -180;\""

	PopupMenu rangeAngleManualSetExtentPop  win= WMPolarGraphPanel,pos={202,375},size={84,20}, title="Set to:",  proc= WMPolarRangeSetAngle, disable=disable
	PopupMenu rangeAngleManualSetExtentPop  win= WMPolarGraphPanel,mode=0,value= #"\"0;45;90;135;180;225;270;315;360;\""

	TitleBox rangeAngleManualDegreeTitle  win= WMPolarGraphPanel,pos={163,352},size={15,12},title="deg",frame=0,  disable=disable
	TitleBox rangeExtentManualDegreeTitle  win= WMPolarGraphPanel,pos={163,378},size={15,12},title="deg",frame=0,  disable=disable
End

Function WMPolarRangeZoomButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Variable mult= sqrt(2)	// two clicks to double
	strswitch( ctrlName )
		case "rangeZoomIn":
			mult= 1/mult
			break
	endswitch

	// Expand or Shrink the DRAWN range by 10%
	Variable xMin, xMax, yMin, yMax	// drawn (axis) ranges
	String graphName= WMPolarTopPolarGraph()
	WMPolarDrawnRange(graphName,xMin, xMax, yMin, yMax)
	
	Variable centerX= (xMin + xMax)/ 2
	Variable rangeX= (xMax-xMin)*mult/2
	xMin= centerX-rangeX
	xMax= centerX+rangeX

	Variable centerY= (yMin + yMax)/ 2
	Variable rangeY= (yMax-yMin)*mult/2
	yMin= centerY-rangeY
	yMax= centerY+rangeY
	
	SetAxis/W=$graphName HorizCrossing  xMin, xMax
	SetAxis/W=$graphName VertCrossing  yMin, yMax

	WMPolarAxesRedrawTopGraphNow()
End

Function WMPolarRangeSetAngle(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Variable angle= str2num(popStr)

	strswitch( ctrlName )
		case "rangeAngleManualSetStartPop":
			NVAR angle0= $WMPolarTopOrDefaultDFVar("angle0")
			angle0= angle
			ControlUpdate/W=WMPolarGraphPanel rangeAngleManualStart
			break
		case "rangeAngleManualSetExtentPop":
			NVAR angleRange= $WMPolarTopOrDefaultDFVar("angleRange")
			angleRange= angle
			ControlUpdate/W=WMPolarGraphPanel rangeAngleManualExtent
			break
	endswitch
	WMPolarAxesRedrawTopGraph()
End

Function WMPolarRangeSetAutoButtonProc(ctrlName) : ButtonControl
	String ctrlName

	NVAR autoRadiusMax= $WMPolarTopOrDefaultDFVar("autoRadiusMax")
	NVAR outerRadius= $WMPolarTopOrDefaultDFVar("outerRadius")

	WAVE/T/Z tw=$WMPolarGraphTracesTW("")
	if( WaveExists(tw) )
		WMPolarUpdateAxes(tw,0)	//  WMPolarUpdateAxes will compute the max and min radii for all traces and expand or contract the grid accordingly
	endif
	
	outerRadius= autoRadiusMax

	WMPolarAxesRedrawTopGraph()
End

Function WMPolarRangeSetOriginButtonProc(ctrlName) : ButtonControl
	String ctrlName

	NVAR valueAtCenter= $WMPolarTopOrDefaultDFVar("valueAtCenter")
	NVAR innerRadius= $WMPolarTopOrDefaultDFVar("innerRadius")
	innerRadius= valueAtCenter

	WMPolarAxesRedrawTopGraph()
End

Function WMPolarRangeCenterButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Variable xMin, xMax, yMin, yMax	// drawn (axis) ranges
	String graphName= WMPolarTopPolarGraph()
	WMPolarDrawnRange(graphName,xMin, xMax, yMin, yMax)
	
	Variable rangeX= (xMax-xMin)/2
	xMin= -rangeX
	xMax= rangeX

	Variable rangeY= (yMax-yMin)/2
	yMin= -rangeY
	yMax= rangeY
	
	SetAxis/W=$graphName HorizCrossing  xMin, xMax
	SetAxis/W=$graphName VertCrossing  yMin, yMax

	WMPolarAxesRedrawTopGraphNow()
End

Function WMPolarRangeRadRangeRadioProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	SVAR doRadiusRange= $WMPolarTopOrDefaultDFVar("doRadiusRange")	// "manual" or "auto"
	Variable doAuto
	strswitch( ctrlName )
		case "rangeRadiusAutoRadio":
			doRadiusRange= "auto"
			doAuto= 1
			break
		case "rangeRadiusManualRadio":
			doRadiusRange= "manual"
			doAuto=0
			break
	endswitch
	
	CheckBox rangeRadiusAutoRadio  win= WMPolarGraphPanel,value=doAuto
	CheckBox rangeRadiusManualRadio  win= WMPolarGraphPanel,value=!doAuto

	// if this procedure is called, the radio buttons must be showing, and so are the manual radius controls
	Variable rangeDisable= doAuto ? 2 : 0
	Variable frame= doAuto ? 0 : 1			// enhance disabled appearance
	SetVariable rangeRadiusManualInner  win= WMPolarGraphPanel, disable=rangeDisable, frame=frame
	SetVariable rangeRadiusManualOuter  win= WMPolarGraphPanel, disable=rangeDisable, frame=frame
	Button rangeRadiusManualOriginButton  win= WMPolarGraphPanel, disable=rangeDisable
	Button rangeRadiusManualAutoButton  win= WMPolarGraphPanel, disable=rangeDisable
	if( doAuto )
		WAVE/T tw=$WMPolarGraphTracesTW("")
		WMPolarUpdateAxes(tw,1)	//  WMPolarUpdateAxes will compute the max and min radii for all traces and expand or contract the grid accordingly
	else
		WMPolarAxesRedrawTopGraph()
	endif
End


Function WMPolarRangeRadFuncRadioProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	SVAR radiusFunction= $WMPolarTopOrDefaultDFVar("radiusFunction")	// "Linear;Log"
	strswitch( ctrlName )
		case "rangeRadiusLinearRadio":
			radiusFunction= "Linear"
			break
		case "rangeRadiusLogRadio":
			radiusFunction= "Log"
			break
	endswitch
	
	CheckBox rangeRadiusLinearRadio win= WMPolarGraphPanel, value= (CmpStr(radiusFunction,"Linear") == 0)
	CheckBox rangeRadiusLogRadio win= WMPolarGraphPanel, value= (CmpStr(radiusFunction,"Log") == 0)
	
	if( CmpStr(radiusFunction,"Log") == 0)
		NVAR valueAtCenter= $WMPolarTopOrDefaultDFVar("valueAtCenter")	// radius origin
		if( valueAtCenter <= 0 )
			DoAlert 0, "Log radius requires Radius Origin > 0. Setting Radius Origin = radius minimum."
			NVAR autoRadiusMin=$WMPolarTopOrDefaultDFVar("autoRadiusMin")
			valueAtCenter= autoRadiusMin	// hopefully the data is log-compatible (> 0)
		endif
	endif
	WMPolarAxesRedrawTopGraphNow()
End

Function WMPolarRangeRotationRadioProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	NVAR angleDirection= $WMPolarTopOrDefaultDFVar("angleDirection")	// 1 == clockwise, -1 == counter-clockwise"
	strswitch( ctrlName )
		case "rangeClockwiseRadio":
			angleDirection= 1
			break
		case "rangeCounterclockwiseRadio":
			angleDirection= -1
			break
	endswitch
	
	CheckBox rangeClockwiseRadio			win= WMPolarGraphPanel, value= (angleDirection ==1)
	CheckBox rangeCounterclockwiseRadio	win= WMPolarGraphPanel, value= (angleDirection ==-1)

	DoUpdate
	WMPolarAxesRedrawTopGraph()
End

Function WMPolarRangeOriginRadioProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	NVAR zeroAngleWhere= $WMPolarTopOrDefaultDFVar("zeroAngleWhere")	// 0 = right, 90 = top, 180 = left, -90 = bottom
	
	strswitch( ctrlName )
		case "rangeZeroLeftRadio":
			zeroAngleWhere= 180
			break
		case "rangeZeroTopRadio":
			zeroAngleWhere= 90
			break
		case "rangeZeroRightRadio":
			zeroAngleWhere= 0
			break
		case "rangeZeroBottomRadio":
			zeroAngleWhere= -90
			break
	endswitch
	
	CheckBox rangeZeroLeftRadio  win= WMPolarGraphPanel, value= (zeroAngleWhere ==180)
	CheckBox rangeZeroTopRadio  win= WMPolarGraphPanel, value= (zeroAngleWhere ==90)
	CheckBox rangeZeroRightRadio  win= WMPolarGraphPanel,value= (zeroAngleWhere ==0)
	CheckBox rangeZeroBottomRadio  win= WMPolarGraphPanel,value= (zeroAngleWhere ==-90)

	DoUpdate
	WMPolarAxesRedrawTopGraph()
End

Function/S WMPolarGraphDrawLayers()
	String items= "\M0:1(:  (window background);ProgBack;UserBack;"
	items += "\M0:1(:  (axes && images);ProgAxes;UserAxes;"
	items += "\M0:1(:  (traces);ProgFront;UserFront;"
	items += "\M0:1(:  (annotations);"	
	return items
End


// control names must start with "axes"
Function WMPolar_AxesTab(show)
	Variable show
	
	if( show )
		ControlInfo/W=WMPolarGraphPanel commonPolarTab
		if( V_Value != kTabAxes )		// avoid flashing
			TabControl commonPolarTab win= WMPolarGraphPanel, value= kTabAxes,size={309,460},pos={2,4}
		endif
	endif
	Variable disable= show ? 0 : 1
	
	// Radius Axes
	GroupBox axesRadiusGroup win= WMPolarGraphPanel,pos={13,30},size={283,98},title="Radius Axes",  disable=disable
	
	//popVal= WMPolarGetStr("radiusAxesWhere")
	String popVal=WMPolarGetCleanedStr("radiusAxesWhere",WMPolarRadiusAxisAtPopup())
	Variable whichOne= max(1,1+WhichListItem(popVal , WMPolarRadiusAxisAtPopup()))
	PopupMenu axesRadiusAxesAtPop  win= WMPolarGraphPanel,pos={29,51},size={196,20},title="Radius Axes at:", proc=WMPolarAxesWherePopupProc,  disable=disable
	// PopupMenu axesRadiusAxesAtPop  win= WMPolarGraphPanel,mode=whichOne,popvalue=popVal,value= #"WMPolarRadiusAxisAtPopup()"
	String moduleName= GetIndependentModuleName()+"#"
	String command= moduleName+"WMPolarRadiusAxisAtPopup()"
	PopupMenu axesRadiusAxesAtPop  win= WMPolarGraphPanel,mode=whichOne,popvalue=popVal,value= #command
	
	// don't show "At Radius=", "At Max Radius", or "Upper Half..." unless Left or Bottom
	Variable atRadiusDisable= disable
	Variable axisAtSide= strlen(WMPolarRadiusAxesAtSide(popVal)) > 0	// Left, Right, Top, or Bottom
	if( atRadiusDisable == 0 && !axisAtSide )
		atRadiusDisable= 1
	endif
	SetVariable axesRadiusAxesOffsetToRadius  win= WMPolarGraphPanel,pos={190,50},size={100,15},title="At Radius=", proc=WMPolarSetVarProc,  disable=atRadiusDisable
	SetVariable axesRadiusAxesOffsetToRadius  win= WMPolarGraphPanel,limits={-Inf,Inf,0},value= $WMPolarTopOrDefaultDFVar("radiusAxesAtLeftBottomRadius")
	// don't show Angles List unless "At Listed Angles"
	Variable atListed= strsearch(popVal,"At Listed",0) >= 0

	popVal= WMPolarGetStr("radiusAxesHalves")	// "Upper Half;Lower Half;Left Half;Right Half;Both Halves"
	whichOne= max(1,1+WhichListItem(popVal , WMPolarRadiusAxisHalvesPopup()))
	PopupMenu axesRadiusAtLeftBottomPop win= WMPolarGraphPanel,pos={73,77},size={94,20},proc=WMPolarAxesAtHalvesPopupProc,  disable=atRadiusDisable
//	PopupMenu axesRadiusAtLeftBottomPop win= WMPolarGraphPanel,mode=whichOne,popvalue=popVal,value= #"WMPolarRadiusAxisHalvesPopup()"
	command= moduleName+"WMPolarRadiusAxisHalvesPopup()"
	PopupMenu axesRadiusAtLeftBottomPop win= WMPolarGraphPanel,mode=whichOne,popvalue=popVal,value= #command

	Button axesMaxRadius win= WMPolarGraphPanel,pos={187,77},size={100,20},proc=WMPolarAxesMaxRadiusButtonProc,title="At Max Radius",  disable=atRadiusDisable

	// don't show Angles List unless "At Listed Angles"
//	Variable atListed= strsearch(popVal,"At Listed",0) >= 0
	Variable atListedDisable= disable
	if( atListedDisable == 0  )
		atListedDisable= atListed ? 0 : 1
	endif
	SetVariable axesListOfAngles4RadiusAxes  win= WMPolarGraphPanel,pos={32,78},size={255,19},title="Angles List:", proc=WMPolarSetVarProc,  disable=atListedDisable
	SetVariable axesListOfAngles4RadiusAxes  win= WMPolarGraphPanel,limits={-Inf,Inf,0},value= $WMPolarTopOrDefaultDFVar("radiusAxesAngleList")

	Variable red= WMPolarGetVar("radiusAxisColorRed")
	Variable green=WMPolarGetVar("radiusAxisColorGreen")
	Variable blue=WMPolarGetVar("radiusAxisColorBlue")
	Variable alpha=WMPolarGetVarOrDefault("radiusAxisColorAlpha",65535)
	PopupMenu axesRadiusAxisColorPop  win= WMPolarGraphPanel,pos={28,103},size={84,20},title="Color:", proc=WMPolarAxesColorPopupProc,  disable=disable
	PopupMenu axesRadiusAxisColorPop  win= WMPolarGraphPanel,mode=1,popColor= (red,green,blue,alpha),value= #"\"*COLORPOP*\""

	SetVariable axesRadiusAxisThick  win= WMPolarGraphPanel,pos={139,104},size={110,19},title="Thickness:", proc=WMPolarSetVarProc,  disable=disable
	SetVariable axesRadiusAxisThick  win= WMPolarGraphPanel,limits={0,10,0.25},value= $WMPolarTopOrDefaultDFVar("radiusAxisThick")

	TitleBox axesRadiusAxisThickPoints  win= WMPolarGraphPanel,pos={253,106},size={33,16},title="points",frame=0,  disable=disable

	// Angle Axes
	GroupBox axesAngleGroup  win= WMPolarGraphPanel,pos={13,132},size={283,98},title="Angle Axes",  disable=disable
	
	popVal= WMPolarGetCleanedStr("angleAxesWhere",WMPolarAngleAxisAtPopup())		// WMPolarGetStr("angleAxesWhere")
	whichOne= max(1,1+WhichListItem(popVal , WMPolarAngleAxisAtPopup()))
	PopupMenu axesAngleAxesAtPop  win= WMPolarGraphPanel,pos={29,154},size={176,20},title="Angle Axes at:", proc=WMPolarAxesWherePopupProc,  disable=disable
//	PopupMenu axesAngleAxesAtPop  win= WMPolarGraphPanel,mode=whichOne,popvalue=popVal,value= #"WMPolarAngleAxisAtPopup()"
	command= moduleName+"WMPolarAngleAxisAtPopup()"
	PopupMenu axesAngleAxesAtPop  win= WMPolarGraphPanel,mode=whichOne,popvalue=popVal,value= #command
	
	// don't show Radii List unless "At Listed Radii"
	atListed= strsearch(popVal,"At Listed",0) >= 0
	atListedDisable= disable
	if( atListedDisable == 0 )
		atListedDisable= atListed ? 0 : 1
	endif
	SetVariable axesListOfRadii4AngleAxes  win= WMPolarGraphPanel,pos={31,179},size={256,19},title="Radii List:", proc=WMPolarSetVarProc, disable=atListedDisable
	SetVariable axesListOfRadii4AngleAxes  win= WMPolarGraphPanel,limits={-Inf,Inf,0},value= $WMPolarTopOrDefaultDFVar("angleAxesRadiusList")

	red= WMPolarGetVar("angleAxisColorRed")
	green=WMPolarGetVar("angleAxisColorGreen")
	blue=WMPolarGetVar("angleAxisColorBlue")
	alpha=WMPolarGetVarOrDefault("angleAxisColorAlpha",65535)

	PopupMenu axesAngleAxisColorPop  win= WMPolarGraphPanel,pos={28,203},size={84,20},title="Color:", proc=WMPolarAxesColorPopupProc,  disable=disable
	PopupMenu axesAngleAxisColorPop  win= WMPolarGraphPanel,mode=1,popColor= (red,green,blue,alpha),value= #"\"*COLORPOP*\""

	SetVariable axesAngleAxisThick  win= WMPolarGraphPanel,pos={139,206},size={110,19},title="Thickness:", proc=WMPolarSetVarProc, disable=disable
	SetVariable axesAngleAxisThick  win= WMPolarGraphPanel,limits={0,10,0.25},value= $WMPolarTopOrDefaultDFVar("angleAxisThick")

	TitleBox axesAngleAxisThickPoints  win= WMPolarGraphPanel,pos={253,207},size={33,16},title="points",frame=0,  disable=disable

	// Grid
	GroupBox axesGridGroup  win= WMPolarGraphPanel,pos={13,235},size={283,220},title="                                                   ",  disable=disable
	
	CheckBox axesGridCheck,win= WMPolarGraphPanel, pos={28,237},size={42,16},proc=WMPolarCheckboxProc,title="Grid "
	CheckBox axesGridCheck,win= WMPolarGraphPanel, variable= $WMPolarTopOrDefaultDFVar("doPolarGrids"), disable=disable
	
	// Igor 9.02: Grid Background
	// 9.02: new controls can't presume global variables exist yet for possibly old data folders.
	String path=WMPolarTopOrDefaultDFVar("drawGridBackground")
	Variable checked = NumVarOrDefault(path,0)
	Variable/G $path= checked

	CheckBox axesDrawGridBackground,win=WMPolarGraphPanel,pos={76,238},size={14,14},title="",proc=WMPolarCheckboxProc
	CheckBox axesDrawGridBackground,win=WMPolarGraphPanel,variable=$path, disable=disable

	red= WMPolarGetVarOrDefault("gridBkgColorRed",65535)
	green=WMPolarGetVarOrDefault("gridBkgColorGreen",65535)
	blue=WMPolarGetVarOrDefault("gridBkgColorBlue",65535)
	alpha=WMPolarGetVarOrDefault("gridBkgColorAlpha",65535)
	
	Variable/G $WMPolarTopOrDefaultDFVar("gridBkgColorRed")= red
	Variable/G $WMPolarTopOrDefaultDFVar("gridBkgColorGreen")= green
	Variable/G $WMPolarTopOrDefaultDFVar("gridBkgColorBlue")= blue
	Variable/G $WMPolarTopOrDefaultDFVar("gridBkgColorAlpha")= alpha

	PopupMenu axesGridBkgColor,win=WMPolarGraphPanel,pos={91,235},size={119,20},proc=WMPolarAxesColorPopupProc
	PopupMenu axesGridBkgColor,win=WMPolarGraphPanel,title="Background:", disable=disable
	PopupMenu axesGridBkgColor,win=WMPolarGraphPanel,mode=1,popColor=(red,green,blue,alpha),value=#"\"*COLORPOP*\""

		// Major Grid
	GroupBox axesGridMajorGroup  win= WMPolarGraphPanel,pos={21,255},size={265,70},title="Major Grid Lines",  disable=disable

	red= WMPolarGetVar("majorGridColorRed")
	green= WMPolarGetVar("majorGridColorGreen")
	blue= WMPolarGetVar("majorGridColorBlue")
	alpha= WMPolarGetVarOrDefault("majorGridColorAlpha",65535)

	PopupMenu axesGridMajorColorPop  win= WMPolarGraphPanel,pos={28,275},size={84,20},title="Color:",proc=WMPolarAxesColorPopupProc, disable=disable
	PopupMenu axesGridMajorColorPop  win= WMPolarGraphPanel,mode=1,popColor= (red,green,blue,alpha),value= #"\"*COLORPOP*\""

	SetVariable axesMajorGridThick  win= WMPolarGraphPanel,pos={135,278},size={110,19},title="Thickness:", proc=WMPolarSetVarProc, disable=disable
	SetVariable axesMajorGridThick  win= WMPolarGraphPanel,limits={0,10,0.25},value=$WMPolarTopOrDefaultDFVar("majorGridLineSize")

	TitleBox axesGridMajorThickPoints  win= WMPolarGraphPanel,pos={248,279},size={33,16},title="points",frame=0,  disable=disable

	whichOne= WMPolarGetVar("majorGridStyle") + 1	// style 0 is solid, the first popup menu item
	PopupMenu axesGridMajorStylePop  win= WMPolarGraphPanel,pos={28,301},size={181,20},title="Style:",proc=WMPolarAxesStylePopupProc, disable=disable
	PopupMenu axesGridMajorStylePop  win= WMPolarGraphPanel,mode=whichOne,value= #"\"*LINESTYLEPOP*\""

		// Minor Grid
	GroupBox axesGridMinorGroup  win= WMPolarGraphPanel,pos={21,325},size={265,71},title="Minor Grid Lines (if Minor Ticks)",  disable=disable

	red= WMPolarGetVar("minorGridColorRed")
	green= WMPolarGetVar("minorGridColorGreen")
	blue= WMPolarGetVar("minorGridColorBlue")
	alpha= WMPolarGetVarOrDefault("minorGridColorAlpha",65535)

	PopupMenu axesGridMinorColorPop  win= WMPolarGraphPanel,pos={28,346},size={84,20},title="Color:",proc=WMPolarAxesColorPopupProc, disable=disable
	PopupMenu axesGridMinorColorPop  win= WMPolarGraphPanel,mode=1,popColor= (red,green,blue,alpha),value= #"\"*COLORPOP*\""

	SetVariable axesMinorGridThick  win= WMPolarGraphPanel,pos={135,348},size={110,19},title="Thickness:", proc=WMPolarSetVarProc, disable=disable
	SetVariable axesMinorGridThick  win= WMPolarGraphPanel,limits={0,10,0.25},value=$WMPolarTopOrDefaultDFVar("minorGridLineSize")

	TitleBox axesGridMinorThickPoints  win= WMPolarGraphPanel,pos={248,349},size={33,16},title="points",frame=0,  disable=disable

	whichOne= WMPolarGetVar("minorGridStyle") + 1	// style 0 is solid, the first popup menu item
	PopupMenu axesGridMinorStylePop  win= WMPolarGraphPanel,pos={28,371},size={181,20},title="Style:",proc=WMPolarAxesStylePopupProc, disable=disable
	PopupMenu axesGridMinorStylePop  win= WMPolarGraphPanel,mode=whichOne,value= #"\"*LINESTYLEPOP*\""

	// More Grid Stuff
	Variable doMinGridSpacing=  WMPolarGetVar("doMinGridSpacing")
	CheckBox axesGridMinSpacingCheck  win= WMPolarGraphPanel,pos={23,404},size={107,16},title="Min Grid Spacing",proc=WMPolarAxesMinSpacingCheckbox, disable=disable
	CheckBox axesGridMinSpacingCheck  win= WMPolarGraphPanel,variable=$WMPolarTopOrDefaultDFVar("doMinGridSpacing")
	
	Variable spacingDisable= disable
	if( spacingDisable == 0 && !doMinGridSpacing )
		spacingDisable= 1	// hide
	endif

	SetVariable axesGridMinSpacing  win= WMPolarGraphPanel,pos={136,401},size={42,19},title=" ",proc=WMPolarSetVarProc, disable=spacingDisable
	SetVariable axesGridMinSpacing  win= WMPolarGraphPanel,limits={0,72,0.5},value= $WMPolarTopOrDefaultDFVar("minGridSpacing")

	TitleBox axesGridSpacingPoints,win= WMPolarGraphPanel,pos={185,401},size={33,16}, disable=spacingDisable
	TitleBox axesGridSpacingPoints,win= WMPolarGraphPanel,title="points",frame=0

// replaced Resolution... panel with SetVariable axesArcPolyLength
//	Button axesGridResolutionTweaks  win= WMPolarGraphPanel,pos={189,430},size={96,20},proc=WMPolarAxesResolutionButton,title="Resolution...",  disable=disable

	// Always set useCircles
	Variable/G $WMPolarTopOrDefaultDFVar("useCircles")= 1 // use DrawOval for full circles

	SetVariable axesArcPolyLength,win= WMPolarGraphPanel,pos={23,426},size={215,19},proc=WMPolarSetVarProc, disable=disable
	SetVariable axesArcPolyLength,win= WMPolarGraphPanel,title="Longest Polygon Line Segment:"
	SetVariable axesArcPolyLength,win= WMPolarGraphPanel,help={"Polygons are used to draw arcs that aren't a full circle"}
	SetVariable axesArcPolyLength,win= WMPolarGraphPanel,limits={0.5,10,0.5},value=$WMPolarTopOrDefaultDFVar("maxArcLine")
	
	TitleBox axesLongestPolygonPoints,win= WMPolarGraphPanel,pos={244,427},size={33,16},title="points",frame=0, disable=disable
End


Function WMPolarAxesMaxRadiusButtonProc(ctrlName) : ButtonControl
	String ctrlName

	NVAR radiusAxesAtLeftBottomRadius= $WMPolarTopOrDefaultDFVar("radiusAxesAtLeftBottomRadius")
	NVAR autoRadiusMax= $WMPolarTopOrDefaultDFVar("autoRadiusMax")
	NVAR dataOuterRadius= $WMPolarTopOrDefaultDFVar("dataOuterRadius")
	
	radiusAxesAtLeftBottomRadius= max(autoRadiusMax,dataOuterRadius)

	WMPolarAxesRedrawTopGraph()
End

Function WMPolarAxesAtHalvesPopupProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	SVAR radiusAxesHalves= $WMPolarTopOrDefaultDFVar("radiusAxesHalves")
	radiusAxesHalves= popStr
	
	WMPolarAxesRedrawTopGraph()
End


Function WMPolarAxesWherePopupProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String listName
	strswitch( ctrlName ) 
		case "axesRadiusAxesAtPop":
			SVAR where= $WMPolarTopOrDefaultDFVar("radiusAxesWhere")
			where= popStr
			
			listName="axesListOfAngles4RadiusAxes"
			
			// don't show "At Radius=", "At Max Radius", or "Upper Half..." unless Left, Right, Top, or Bottom
			Variable axisAtSide= strlen(WMPolarRadiusAxesAtSide(where)) > 0	// true if Left, Right, Top, or Bottom
			Variable atRadiusDisable= !axisAtSide
			SetVariable axesRadiusAxesOffsetToRadius  win= WMPolarGraphPanel, disable=atRadiusDisable
			PopupMenu axesRadiusAtLeftBottomPop win= WMPolarGraphPanel, disable=atRadiusDisable
			Button axesMaxRadius win= WMPolarGraphPanel, disable=atRadiusDisable
			if( atRadiusDisable == 0 )
				ControlUpdate/W=WMPolarGraphPanel axesRadiusAtLeftBottomPop	// update the shown popup value
				ControlInfo/W=WMPolarGraphPanel axesRadiusAtLeftBottomPop
				SVAR radiusAxesHalves= $WMPolarTopOrDefaultDFVar("radiusAxesHalves")
				radiusAxesHalves= S_Value
				// if the At Radius= value is zero (the default)
				NVAR radiusAxesAtLeftBottomRadius= $WMPolarTopOrDefaultDFVar("radiusAxesAtLeftBottomRadius")
				if( radiusAxesAtLeftBottomRadius == 0 )
					WMPolarAxesMaxRadiusButtonProc("")	// bump it out to to a reasonable-looking value
				endif
			endif
			break
		case "axesAngleAxesAtPop":
			SVAR where= $WMPolarTopOrDefaultDFVar("angleAxesWhere")
			where= popStr
			listName="axesListOfRadii4AngleAxes"
			break
	endswitch

	// don't show List unless "At Listed xxxx"
	Variable atListed= strsearch(popStr,"At Listed",0) >= 0
	Variable disable= atListed ? 0 : 1
	SetVariable $listName win= WMPolarGraphPanel, disable=disable
	
	WMPolarAxesRedrawTopGraph()
End

Function WMPolarAxesMinSpacingCheckbox(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	if( checked )
		SetVariable axesGridMinSpacing  win= WMPolarGraphPanel, disable=0
	else
		SetVariable axesGridMinSpacing  win= WMPolarGraphPanel, disable=1
	endif
	WMPolarAxesRedrawTopGraph()
End

Function WMPolarAxesStylePopupProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	strswitch( ctrlName ) 
		case "axesGridMajorStylePop":
			NVAR style= $WMPolarTopOrDefaultDFVar("majorGridStyle")
			break
		case "axesGridMinorStylePop":
			NVAR style= $WMPolarTopOrDefaultDFVar("minorGridStyle")
			break
	endswitch
	style= popNum-1
	WMPolarAxesRedrawTopGraph()
End


Function WMPolarAxesColorPopupProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	ControlInfo/W=WMPolarGraphPanel $ctrlName
	
	String prefix
	strswitch( ctrlName ) 
		case "axesRadiusAxisColorPop":
			prefix= "radiusAxisColor"
			break
		case "axesAngleAxisColorPop":
			prefix= "angleAxisColor"
			break
		case "axesGridMajorColorPop":
			prefix= "majorGridColor"
			break
		case "axesGridMinorColorPop":
			prefix= "minorGridColor"
			break
		case "axesGridBkgColor":
			prefix= "gridBkgColor" // perhaps this should also set Variable/G $WMPolarTopOrDefaultDFVar("drawGridBackground") = 1
			break
	endswitch
	Variable/G $WMPolarTopOrDefaultDFVar(prefix+"Red") = V_Red
	Variable/G $WMPolarTopOrDefaultDFVar(prefix+"Green") = V_Green
	Variable/G $WMPolarTopOrDefaultDFVar(prefix+"Blue") = V_Blue
	Variable/G $WMPolarTopOrDefaultDFVar(prefix+"Alpha") = V_Alpha
	WMPolarAxesRedrawTopGraph()
End

// control names must start with "Ticks"
Function WMPolar_TicksTab(show)
	Variable show
	
	if( show )
		ControlInfo/W=WMPolarGraphPanel commonPolarTab
		if( V_Value != kTabTicks )		// avoid flashing
			TabControl commonPolarTab win= WMPolarGraphPanel, value= kTabTicks
		endif
	endif
	Variable disable= show ? 0 : 1

	// Radius Ticks
	GroupBox ticksRadiusTicksGroup  win= WMPolarGraphPanel,pos={11,34},size={288,107},title="                                         ",  disable=disable

	String popVal= WMPolarGetStr("radiusTicksLocation")
	Variable whichOne= max(1,1+WhichListItem(popVal , "Off;Crossing;Inside;Outside;"))
	PopupMenu ticksRadiusTicksWhere  win= WMPolarGraphPanel,pos={26,33},size={123,17},title="Radius Ticks:",  proc=WMPolarTicksWherePopupProc, disable=disable
	PopupMenu ticksRadiusTicksWhere  win= WMPolarGraphPanel,mode=whichOne,popvalue=popVal,value= #"\"Off;Crossing;Inside;Outside;\""

	String doMajorRadiusTicks= WMPolarGetStr("doMajorRadiusTicks")	// "manual" or "auto"
	Variable doAuto= CmpStr(doMajorRadiusTicks,"auto") == 0	

	CheckBox ticksAutoRadiusTickRadio  win= WMPolarGraphPanel,pos={27,67},size={16,14},title="",value= doAuto,mode=1, proc=WMPolarTicksRadiusRadioButtons, disable=disable

	SetVariable ticksAutoRadiusApproxTicks  win= WMPolarGraphPanel,pos={46,65},size={225,15},title="Auto Radius Ticks, Approximately:",  proc=WMPolarSetVarProc, disable=disable
	SetVariable ticksAutoRadiusApproxTicks  win= WMPolarGraphPanel,limits={1,Inf,1},value=$WMPolarTopOrDefaultDFVar("radiusApproxTicks")

	CheckBox ticksManualRadiusTicksRadio  win= WMPolarGraphPanel,pos={27,88},size={16,14},title="",  proc=WMPolarTicksRadiusRadioButtons, disable=disable
	CheckBox ticksManualRadiusTicksRadio  win= WMPolarGraphPanel,value= !doAuto,mode=1

	SetVariable ticksManualRadiusMajorInc  win= WMPolarGraphPanel,pos={46,87},size={228,15},title="Manual Radius Increment:", proc=WMPolarSetVarProc,disable=disable
	SetVariable ticksManualRadiusMajorInc  win= WMPolarGraphPanel,limits={-Inf,Inf,0},value=$WMPolarTopOrDefaultDFVar("majorRadiusInc")

		// Minor Radius Ticks
	CheckBox ticksMinorRadiusTicksCheck  win= WMPolarGraphPanel,pos={27,110},size={16,14},title="Minor Ticks", proc=WMPolarCheckboxProc, disable=disable
	CheckBox ticksMinorRadiusTicksCheck  win= WMPolarGraphPanel,variable= $WMPolarTopOrDefaultDFVar("doMinorRadiusTicks")

	Variable minorDisable= disable
	if( minorDisable == 0 && doAuto )
		minorDisable= 1	// hide minor ticks value if auto
	endif

	SetVariable ticksMinorRadiusTicks  win= WMPolarGraphPanel,pos={107,110},size={60,15},title=" ", proc=WMPolarSetVarProc, disable=minorDisable
	SetVariable ticksMinorRadiusTicks  win= WMPolarGraphPanel,limits={1,Inf,1},value=$WMPolarTopOrDefaultDFVar("minorRadiusTicks")

	String doRadiusRange= WMPolarGetStr("doRadiusRange")	// "manual" or "auto"
	Variable rangeAuto= CmpStr(doRadiusRange,"auto") == 0	
	Variable noteDisable= disable
	if( noteDisable == 0 && (doAuto || !rangeAuto) )
		noteDisable= 1	// hide note if auto radius ticks or if radius range is manual
	endif
	TitleBox ticksRadRangeIsAuto win= WMPolarGraphPanel,pos={185,109},size={92,24},frame=0,title="NOTE: radius range\r       is autoscaled.", disable=noteDisable

	// Angle Ticks
	GroupBox ticksAngleTicksGroup  win= WMPolarGraphPanel,pos={11,159},size={288,108},title="                                          ",  disable=disable

	popVal= WMPolarGetStr("angleTicksLocation")
	whichOne= max(1,1+WhichListItem(popVal , "Off;Crossing;Inside;Outside;"))
	PopupMenu ticksAngleTicksWhere  win= WMPolarGraphPanel,pos={26,159},size={125,17},title="Angle Ticks:", proc=WMPolarTicksWherePopupProc, disable=disable
	PopupMenu ticksAngleTicksWhere  win= WMPolarGraphPanel,mode=whichOne,popvalue=popVal,value= #"\"Off;Crossing;Inside;Outside;\""

	String doMajorAngleTicks= WMPolarGetStr("doMajorAngleTicks")	// "manual" or "auto"
	doAuto= CmpStr(doMajorAngleTicks,"auto") == 0	
	CheckBox ticksAutoAngleTickRadio  win= WMPolarGraphPanel,pos={27,191},size={16,14},title="",value= doAuto,mode=1, proc=WMPolarTicksAngleRadioButtons, disable=disable

	SetVariable ticksAutoAngleApproxTicks  win= WMPolarGraphPanel,pos={46,189},size={215,15},title="Auto Angle Ticks, Approximately:", proc= WMPolarSetVarProc, disable=disable
	SetVariable ticksAutoAngleApproxTicks  win= WMPolarGraphPanel,limits={1,Inf,1},value= $WMPolarTopOrDefaultDFVar("angleApproxTicks")

	CheckBox ticksManualAngleTicksRadio  win= WMPolarGraphPanel,pos={27,212},size={16,14},title="",  proc=WMPolarTicksAngleRadioButtons, disable=disable
	CheckBox ticksManualAngleTicksRadio  win= WMPolarGraphPanel,value=!doAuto,mode=1

	SetVariable ticksManualAngleMajorInc  win= WMPolarGraphPanel,pos={46,211},size={197,15},title="Manual Angle Increment:", proc= WMPolarSetVarProc, disable=disable
	SetVariable ticksManualAngleMajorInc  win= WMPolarGraphPanel,limits={0,360,5},value= $WMPolarTopOrDefaultDFVar("majorAngleInc")

	TitleBox ticksManualIncrementDegree  win= WMPolarGraphPanel,pos={248,212},size={36,12},title="degrees",frame=0,  disable=disable

		// Minor Angle Ticks
	CheckBox ticksMinorAngleTicksCheck  win= WMPolarGraphPanel,pos={28,235},size={77,14},title="Minor Ticks", proc=WMPolarCheckboxProc,  disable=disable
	CheckBox ticksMinorAngleTicksCheck  win= WMPolarGraphPanel,variable=$WMPolarTopOrDefaultDFVar("doMinorAngleTicks")
	
	SetVariable ticksMinorAngleTicks  win= WMPolarGraphPanel,pos={112,235},size={55,15},title=" ", proc= WMPolarSetVarProc, disable=disable
	SetVariable ticksMinorAngleTicks  win= WMPolarGraphPanel,limits={1,Inf,1},value= $WMPolarTopOrDefaultDFVar("minorAngleTicks")

	Variable approxDisable= disable
	if( approxDisable == 0 && !doAuto )
		approxDisable= 1	// hide "(approximately)" if manual
	endif
	
	TitleBox ticksMinorApproximately win= WMPolarGraphPanel,pos={177,237},size={83,12},title="(approximately)",frame=0, disable=approxDisable
	
	// Tick Sizes
		GroupBox ticksSizesGroup win=WMPolarGraphPanel, pos={11,281}, size={288,129},title="Tick Sizes",  disable=disable
		// Major
	GroupBox ticksMajorSizes  win= WMPolarGraphPanel,pos={20,302},size={271,45},title="Major",  disable=disable
	
	SetVariable ticksMajorThick  win= WMPolarGraphPanel,pos={38,322},size={100,15},title="Thickness:", proc=WMPolarSetVarProc, disable=disable
	SetVariable ticksMajorThick  win= WMPolarGraphPanel,limits={0,10,0.25},value= $WMPolarTopOrDefaultDFVar("majorTickThick")

	SetVariable ticksMajorLength  win= WMPolarGraphPanel,pos={151,322},size={85,15},title="Length:", proc=WMPolarSetVarProc, disable=disable
	SetVariable ticksMajorLength  win= WMPolarGraphPanel,limits={0,10,0.25},value= $WMPolarTopOrDefaultDFVar("majorTickLength")

	TitleBox ticksMajorPoints  win= WMPolarGraphPanel,pos={241,322},size={30,12},title="points",frame=0,  disable=disable
		// Minor
	GroupBox ticksMinorSizes  win= WMPolarGraphPanel,pos={20,353},size={271,45},title="Minor",  disable=disable

 	SetVariable ticksMinorThick win=WMPolarGraphPanel, pos={36,373}, size={100,15},title="Thickness:", proc=WMPolarSetVarProc, disable=disable
	SetVariable ticksMinorThick  win= WMPolarGraphPanel,limits={0,10,0.25},value= $WMPolarTopOrDefaultDFVar("minorTickThick")

	SetVariable ticksMinorLength win=WMPolarGraphPanel, pos={151,373}, size={85,15},title="Length:", proc=WMPolarSetVarProc, disable=disable
	SetVariable ticksMinorLength  win= WMPolarGraphPanel,limits={0,10,0.25},value= $WMPolarTopOrDefaultDFVar("minorTickLength")

	TitleBox ticksMinorPoints win=WMPolarGraphPanel, pos={241,374}, size={27,12},title="points",frame=0,  disable=disable
End

Function WMPolarTicksRadiusRadioButtons(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	SVAR doMajorRadiusTicks= $WMPolarTopOrDefaultDFVar("doMajorRadiusTicks")	// "manual" or "auto"
	Variable doAuto, disable
	strswitch(ctrlName)
		case "ticksAutoRadiusTickRadio":
			doMajorRadiusTicks= "auto"
			doAuto= 1
			disable= 1	// hide the number of minor ticks; it's determined automatically
			break
		case "ticksManualRadiusTicksRadio":
			doMajorRadiusTicks= "manual"
			doAuto= 0
			disable= 0
			break
	endswitch

	CheckBox ticksAutoRadiusTickRadio  win= WMPolarGraphPanel,value= doAuto
	CheckBox ticksManualRadiusTicksRadio  win= WMPolarGraphPanel,value= !doAuto
	SetVariable ticksMinorRadiusTicks  win= WMPolarGraphPanel, disable=disable
	
	String doRadiusRange= WMPolarGetStr("doRadiusRange")	// "manual" or "auto"
	Variable rangeAuto= CmpStr(doRadiusRange,"auto") == 0	
	Variable noteDisable= 0
	if( !doAuto || !rangeAuto )
		noteDisable= 1	// hide note if manual radius ticks or if radius range is manual
	endif
	TitleBox ticksRadRangeIsAuto win= WMPolarGraphPanel, disable=noteDisable

	WMPolarAxesRedrawTopGraph()
End

Function WMPolarTicksAngleRadioButtons(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	SVAR doMajorAngleTicks= $WMPolarTopOrDefaultDFVar("doMajorAngleTicks")	// "manual" or "auto"
	Variable doAuto,disable
	strswitch(ctrlName)
		case "ticksAutoAngleTickRadio":
			doMajorAngleTicks= "auto"
			doAuto= 1
			disable=0	// show "(approximately)" for minor ticks value
			break
		case "ticksManualAngleTicksRadio":
			doMajorAngleTicks= "manual"
			doAuto= 0
			disable=1	// hide "(approximately)" for minor ticks value
			break
	endswitch

	CheckBox ticksAutoAngleTickRadio  win= WMPolarGraphPanel,value= doAuto
	CheckBox ticksManualAngleTicksRadio  win= WMPolarGraphPanel,value= !doAuto

	TitleBox ticksMinorApproximately  win= WMPolarGraphPanel, disable=disable

	WMPolarAxesRedrawTopGraph()
End


Function WMPolarTicksWherePopupProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	strswitch(ctrlName)
		case "ticksRadiusTicksWhere":
			SVAR where= $WMPolarTopOrDefaultDFVar("radiusTicksLocation")
			break
		case "ticksAngleTicksWhere":
			SVAR where= $WMPolarTopOrDefaultDFVar("angleTicksLocation")
			break
	endswitch
	where= popStr

	WMPolarAxesRedrawTopGraph()
End

// control names must start with "Labels"
Function WMPolar_LabelsTab(show)
	Variable show
	
	if( show )
		ControlInfo/W=WMPolarGraphPanel commonPolarTab
		if( V_Value != kTabLabels )		// avoid flashing
			TabControl commonPolarTab win= WMPolarGraphPanel, value= kTabLabels
		endif
	endif
	Variable disable= show ? 0 : 1
	
	// Radius Tick Labels
	GroupBox labelsRadiusGroup  win= WMPolarGraphPanel,pos={11,31},size={293,170},title="                                 ",  disable=disable
	
	CheckBox labelsRadiusCheck  win= WMPolarGraphPanel,pos={27,33},size={101,14},title="Radius Tick Labels", proc=WMPolarLabelsRadiusCheckboxProc, disable=disable
	CheckBox labelsRadiusCheck  win= WMPolarGraphPanel,variable=$WMPolarTopOrDefaultDFVar("doRadiusTickLabels")

	Variable radiusDisable= disable
	if( radiusDisable == 0 )		// visible, enabled
		Variable doRadiusTickLabels= WMPolarGetVar("doRadiusTickLabels")
		if( !doRadiusTickLabels )
			radiusDisable= 2	// visible, disabled
		endif
	endif
	Variable radiusFrame= (radiusDisable == 2) ? 0 : 1	// setvariables look more disabled with frame=0

	Variable doRadiusTickLabelSubRange= WMPolarGetVar("doRadiusTickLabelSubRange")	// 0 for all (except, possibly, the origin), 1 for subrange
	
	CheckBox labelsRadiusRangeAllRadio  win= WMPolarGraphPanel,pos={34,54},size={130,14},title="Label Entire Radius Range",  disable=radiusDisable
	CheckBox labelsRadiusRangeAllRadio  win= WMPolarGraphPanel,value=!doRadiusTickLabelSubRange,mode=1, proc=WMPolarLabelsRadiusRadioProc
	
	CheckBox labelsRadiusNotOriginCheck  win= WMPolarGraphPanel,pos={200,54},size={76,14},title="Except Origin", proc=WMPolarCheckboxProc, disable=radiusDisable
	CheckBox labelsRadiusNotOriginCheck  win= WMPolarGraphPanel,variable=$WMPolarTopOrDefaultDFVar("radiusTickLabelOmitOrigin")

		// >>>>>> Start of Radius Subrange
	GroupBox labelsRadiusManualRangeGrp  win= WMPolarGraphPanel,pos={18,73},size={282,72},title="                                ",  disable=disable
	
	CheckBox labelsRadiusManualRangeRadio  win= WMPolarGraphPanel,pos={34,74},size={92,14},title="Manual Subrange",  disable=radiusDisable
	CheckBox labelsRadiusManualRangeRadio  win= WMPolarGraphPanel,value= doRadiusTickLabelSubRange,mode=1, proc=WMPolarLabelsRadiusRadioProc

	Variable subrangeRadiusDisable= radiusDisable
	if( subrangeRadiusDisable == 0 )	// visible, enabled
		if( !doRadiusTickLabelSubRange )
			subrangeRadiusDisable= 2	// visible, disabled
		endif
	endif
	Variable subrangeFrame= (subrangeRadiusDisable == 2) ? 0 : 1	// setvariables look more disabled with frame=0

	SetVariable labelsRadiusManualStart  win= WMPolarGraphPanel,pos={51,96},size={110,15},title="Start:",  proc=WMPolarSetVarProc, disable=subrangeRadiusDisable, frame=subrangeFrame
	SetVariable labelsRadiusManualStart  win= WMPolarGraphPanel,limits={-Inf,Inf,0},value=$WMPolarTopOrDefaultDFVar("radiusTickLabelRangeStart")

	SetVariable labelsRadiusManualEnd  win= WMPolarGraphPanel,pos={180,96},size={110,15},title="End:", proc=WMPolarSetVarProc,  disable=subrangeRadiusDisable, frame=subrangeFrame
	SetVariable labelsRadiusManualEnd  win= WMPolarGraphPanel,limits={-Inf,Inf,0},value=$WMPolarTopOrDefaultDFVar("radiusTickLabelRangeEnd")

	Button labelsRadiusSetEntireRange  win= WMPolarGraphPanel,pos={107,118},size={141,20},title="Set to Entire Range",  proc=WMPolarLabelEntireRadiusButton, disable=subrangeRadiusDisable
		// <<<<<< End of Radius Manual Subrange

	String popVal= WMPolarGetStr("radiusTickLabelSigns")
	Variable whichOne= max(1,1+WhichListItem(popVal , " - only; + and -; no signs"))
	PopupMenu labelsRadiusSignsPop  win= WMPolarGraphPanel,pos={19,151},size={120,20},title="Label Signs:",  proc=WMPolarLabelStringPopup, disable=radiusDisable
	PopupMenu labelsRadiusSignsPop  win= WMPolarGraphPanel,mode=whichOne,popvalue=popVal,value= #"\" - only; + and -; no signs\""

	popVal= WMPolarGetStr("radiusTickLabelRotation")
	whichOne= max(1,1+WhichListItem(popVal , " -90;   0;  90; 180"))
	PopupMenu labelsRadiusRotPop  win= WMPolarGraphPanel,pos={187,151},size={82,20},title="Rotation:",  proc=WMPolarLabelStringPopup, disable=radiusDisable
	PopupMenu labelsRadiusRotPop  win= WMPolarGraphPanel,mode=whichOne,popvalue=popVal,value= #"\" -90;   0;  90; 180\""

	SetVariable labelsRadiusFormat  win= WMPolarGraphPanel,pos={19,178},size={131,15},title="Label Format:",  disable=radiusDisable, frame=radiusFrame
	SetVariable labelsRadiusFormat  win= WMPolarGraphPanel,value= $WMPolarTopOrDefaultDFVar("radiusTickLabelNotation"),  proc=WMPolarSetVarProc

	SetVariable labelsRadiusOffset  win= WMPolarGraphPanel,pos={159,178},size={134,15},title="Offset from Axis:",  disable=radiusDisable, frame=radiusFrame
	SetVariable labelsRadiusOffset  win= WMPolarGraphPanel,limits={-Inf,Inf,1},value= $WMPolarTopOrDefaultDFVar("radiusTIckLabelOffset"),  proc=WMPolarSetVarProc

	// Angle Tick Labels
	GroupBox labelsAngleGroup  win= WMPolarGraphPanel,pos={11,204},size={293,174},title="                                ",  disable=disable
	
	CheckBox labelsAngleCheck  win= WMPolarGraphPanel,pos={27,206},size={97,14},title="Angle Tick Labels",  proc=WMPolarLabelsAngleCheckboxProc, disable=disable
	CheckBox labelsAngleCheck  win= WMPolarGraphPanel,variable=$WMPolarTopOrDefaultDFVar("doAngleTickLabels")

	Variable angleDisable= disable
	if( angleDisable == 0 )		// visible, enabled
		Variable doAngleTickLabels= WMPolarGetVar("doAngleTickLabels")
		if( !doAngleTickLabels )
			angleDisable= 2		// visible, disabled
		endif
	endif
	Variable angleFrame= (angleDisable == 2) ? 0 : 1	// setvariables look more disabled with frame=0

	Variable doAngleTickLabelSubRange= WMPolarGetVar("doAngleTickLabelSubRange")	// 0 for all, 1 for subrange

	CheckBox labelsAngleRangeAllRadio  win= WMPolarGraphPanel,pos={34,224},size={127,14},title="Label Entire Angle Range",  disable=angleDisable
	CheckBox labelsAngleRangeAllRadio  win= WMPolarGraphPanel,value= !doAngleTickLabelSubRange,mode=1,  proc=WMPolarLabelsAngleRadioProc

		// >>>>>> Start of Angle Manual Subrange
	GroupBox labelsAngleManualRangeGrp  win= WMPolarGraphPanel,pos={18,242},size={282,63},title="                                 ",  disable=disable
	
	CheckBox labelsAngleManualRangeRadio  win= WMPolarGraphPanel,pos={34,244},size={95,14},title="Manual Subrange",  disable=angleDisable
	CheckBox labelsAngleManualRangeRadio  win= WMPolarGraphPanel,value= doAngleTickLabelSubRange,mode=1,  proc=WMPolarLabelsAngleRadioProc

	Variable subrangeAngleDisable= angleDisable
	if( subrangeAngleDisable == 0 )		// visible, enabled
		if( !doAngleTickLabelSubRange )
			subrangeAngleDisable= 2	// visible, disabled
		endif
	endif
	subrangeFrame= (subrangeAngleDisable == 2) ? 0 : 1	// setvariables look more disabled with frame=0

	SetVariable labelsAngleManualStart  win= WMPolarGraphPanel,pos={52,260},size={109,15},title="Start:",  proc=WMPolarSetVarProc, disable=subrangeAngleDisable, frame=subrangeFrame
	SetVariable labelsAngleManualStart  win= WMPolarGraphPanel,limits={-360,360,5},value=$WMPolarTopOrDefaultDFVar("angleTickLabelRangeStart")

	SetVariable labelsAngleManualExtent  win= WMPolarGraphPanel,pos={175,260},size={114,15},title="Extent:",  proc=WMPolarSetVarProc, disable=subrangeAngleDisable, frame=subrangeFrame
	SetVariable labelsAngleManualExtent  win= WMPolarGraphPanel,limits={-360,360,5},value= $WMPolarTopOrDefaultDFVar("angleTickLabelRangeExtent")

	Button labelsAngleSetEntireRange  win= WMPolarGraphPanel,pos={107,281},size={141,20},title="Set to Entire Range",  proc=WMPolarLabelEntireAngleButton, disable=subrangeAngleDisable
		// <<<<<< End of Angle Manual Subrange

	popVal= WMPolarGetStr("angleTickLabelSigns")
	whichOne= max(1,1+WhichListItem(popVal , " - only; + and -; no signs"))
	PopupMenu labelsAngleSignsPop  win= WMPolarGraphPanel,pos={19,309},size={120,20},title="Label Signs:",  proc=WMPolarLabelStringPopup, disable=angleDisable
	PopupMenu labelsAngleSignsPop  win= WMPolarGraphPanel,mode=whichOne,popvalue=popVal,value= #"\" - only; + and -; no signs\""

	popVal= WMPolarGetStr("angleTickLabelRotation")
	whichOne= max(1,1+WhichListItem(popVal , " -90;   0;  90; 180"))
	PopupMenu labelsAngleRotPop  win= WMPolarGraphPanel,pos={182,309},size={82,20},title="Rotation:",    proc=WMPolarLabelStringPopup, disable=angleDisable
	PopupMenu labelsAngleRotPop  win= WMPolarGraphPanel,mode=whichOne,popvalue=popVal,value= #"\" -90;   0;  90; 180\""

	SetVariable labelsAngleFormat  win= WMPolarGraphPanel,pos={19,332},size={131,15},title="Label Format:",  disable=angleDisable, frame=angleFrame
	SetVariable labelsAngleFormat  win= WMPolarGraphPanel,value= $WMPolarTopOrDefaultDFVar("angleTickLabelNotation"),  proc=WMPolarSetVarProc

	SetVariable labelsAngleOffset  win= WMPolarGraphPanel,pos={159,332},size={134,15},title="Offset from Axis:",  disable=angleDisable, frame=angleFrame
	SetVariable labelsAngleOffset  win= WMPolarGraphPanel,limits={-Inf,Inf,1},value=$WMPolarTopOrDefaultDFVar("angleTIckLabelOffset"),  proc=WMPolarSetVarProc

	String angleTickLabelUnits= WMPolarGetStr("angleTickLabelUnits")
	Variable isDegrees= CmpStr(angleTickLabelUnits,"degrees") == 0
	
	CheckBox labelsAngleDegreesRadio  win= WMPolarGraphPanel,pos={23,356},size={54,14}, proc=WMPolarLabelsAngleUnitsRadio,disable=angleDisable
	CheckBox labelsAngleDegreesRadio  win= WMPolarGraphPanel,value= isDegrees,mode=1,title="Degrees"

	CheckBox labelsAngleRadiansRadio  win= WMPolarGraphPanel,pos={85,356},size={76,14}, proc=WMPolarLabelsAngleUnitsRadio, disable=angleDisable
	CheckBox labelsAngleRadiansRadio  win= WMPolarGraphPanel,value= !isDegrees,mode=1,title="Fraction of Pi"

	// on existing open panels, the new global variable angleTickLabelScale may not exist: initialize it to 1 if that is so.
	Variable angleScale=NumVarOrDefault(WMPolarTopOrDefaultDFVar("angleTickLabelScale"),1)
	Variable/G $WMPolarTopOrDefaultDFVar("angleTickLabelScale") = angleScale
	SetVariable labelsAngleScale win= WMPolarGraphPanel, pos={174,353},size={125,15},proc=WMPolarSetVarProc,disable=angleDisable, frame=angleFrame
	SetVariable labelsAngleScale win= WMPolarGraphPanel,title="* constant", value= $WMPolarTopOrDefaultDFVar("angleTickLabelScale")

	// Labels Font
	popVal= WMPolarGetStr("tickLabelFontName")
	PopupMenu labelsFontPop win= WMPolarGraphPanel,pos={12,383},size={156,20},bodyWidth= 130,title="Font:",proc=WMPolarLabelStringPopup, disable=disable
	PopupMenu labelsFontPop win= WMPolarGraphPanel,popvalue=popVal,value= #"\"default;\\\\M1-;\"+FontList(\";\")"
	
	// Labels Color
	Variable tickLabelRed= WMPolarGetVar("tickLabelRed")
	Variable tickLabelGreen= WMPolarGetVar("tickLabelGreen")
	Variable tickLabelBlue= WMPolarGetVar("tickLabelBlue")
	Variable tickLabelAlpha = WMPolarGetVarOrDefault("tickLabelAlpha",65535)
	PopupMenu labelsTextColorPop win= WMPolarGraphPanel,pos={187,383},size={105,20},proc=WMPolarLabelsTextColorPopup,title="Label Color:", disable=disable
	PopupMenu labelsTextColorPop win= WMPolarGraphPanel,mode=1,popColor= (tickLabelRed,tickLabelGreen,tickLabelBlue,tickLabelAlpha),value= #"\"*COLORPOP*\""
	
	// Labels Font Size
	SetVariable labelsFontSize win= WMPolarGraphPanel,pos={12,409},size={78,15},title="Size:",  proc= WMPolarSetVarProc, disable=disable
	SetVariable labelsFontSize win= WMPolarGraphPanel,limits={1,1000,1},value= $WMPolarTopOrDefaultDFVar("tickLabelFontSize")

	// Labels Font Style
	// tickLabelFontBold global may not exist when opening old experiments with polar graphs in them.
	Variable bold=NumVarOrDefault(WMPolarTopOrDefaultDFVar("tickLabelFontBold"),0)
	Variable/G $WMPolarTopOrDefaultDFVar("tickLabelFontBold") = bold // creates the global
	CheckBox labelsFontBold win= WMPolarGraphPanel,pos={102,411},size={40,16},proc=WMPolarCheckboxProc, disable=disable
	CheckBox labelsFontBold win= WMPolarGraphPanel,title="Bold"
	CheckBox labelsFontBold win= WMPolarGraphPanel,variable=$WMPolarTopOrDefaultDFVar("tickLabelFontBold")

	// tickLabelFontItalic global may not exist when opening old experiments with polar graphs in them.
	Variable italic=NumVarOrDefault(WMPolarTopOrDefaultDFVar("tickLabelFontItalic"),0)
	Variable/G $WMPolarTopOrDefaultDFVar("tickLabelFontItalic") = italic // creates the global
	CheckBox labelsFontItalic win= WMPolarGraphPanel,pos={156,411},size={41,16},proc=WMPolarCheckboxProc, disable=disable
	CheckBox labelsFontItalic win= WMPolarGraphPanel,title="Italic"
	CheckBox labelsFontItalic win= WMPolarGraphPanel,variable=$WMPolarTopOrDefaultDFVar("tickLabelFontItalic")
	
	CheckBox labelsOpaque win= WMPolarGraphPanel,pos={220,410},size={51,14},proc=WMPolarCheckboxProc,title="Opaque", disable=disable
	CheckBox labelsOpaque win= WMPolarGraphPanel,variable=$WMPolarTopOrDefaultDFVar("tickLabelOpaque")

	// 9.03: Shadowed text labels
	// on existing open panels, the new global variable shadowedTickLabel may not exist: initialize it to 0 if that is so.
	Variable shadowedTickLabel=WMPolarGetVarOrDefault("shadowedTickLabel",0)
	Variable/G $WMPolarTopOrDefaultDFVar("shadowedTickLabel") = shadowedTickLabel

	String help= "Adds a drop shadow below labels"
	CheckBox labelsShadow,win= WMPolarGraphPanel,pos={15,441},size={14,14},proc=WMPolarCheckboxProc,title="", disable=disable
	CheckBox labelsShadow,win= WMPolarGraphPanel,help={help},variable=$WMPolarTopOrDefaultDFVar("shadowedTickLabel")
	
	Variable shadowRed= WMPolarGetVarOrDefault("shadowRed",0)		// 0..65535
	Variable shadowGreen= WMPolarGetVarOrDefault("shadowGreen",0)
	Variable shadowBlue= WMPolarGetVarOrDefault("shadowBlue",0)
	Variable shadowAlpha= WMPolarGetVarOrDefault("shadowAlpha",22000)	// full opaque is 65535

	Variable/G $WMPolarTopOrDefaultDFVar("shadowRed") = shadowRed
	Variable/G $WMPolarTopOrDefaultDFVar("shadowGreen") = shadowGreen
	Variable/G $WMPolarTopOrDefaultDFVar("shadowBlue") = shadowBlue
	Variable/G $WMPolarTopOrDefaultDFVar("shadowAlpha") = shadowAlpha

	help= "Shadow Color. A non-opaque shade of black is recommended for non-zero blur."
	PopupMenu labelsShadowColor,win= WMPolarGraphPanel,pos={37,438},size={98,20},proc=WMPolarLabelsShadowColorPopup
	PopupMenu labelsShadowColor,win= WMPolarGraphPanel,title="Shadow:", help={help}, disable=disable
	PopupMenu labelsShadowColor,win= WMPolarGraphPanel,mode=1,popColor=(shadowRed,shadowGreen,shadowBlue,shadowAlpha),value=#"\"*COLORPOP*\""

	Variable shadowXOffset= WMPolarGetVarOrDefault("shadowXOffset",2) 	// points
	Variable shadowYOffset= WMPolarGetVarOrDefault("shadowYOffset",2)	// points
	Variable shadowBlur= WMPolarGetVarOrDefault("shadowBlur",4)			// points
	
	Variable/G $WMPolarTopOrDefaultDFVar("shadowXOffset") = shadowXOffset
	Variable/G $WMPolarTopOrDefaultDFVar("shadowYOffset") = shadowYOffset
	Variable/G $WMPolarTopOrDefaultDFVar("shadowBlur") = shadowBlur

	help= "Shadow X offset in points"
	SetVariable labelsShadowXOffset,win= WMPolarGraphPanel,pos={144,438},size={73,19},bodyWidth=30,proc=WMPolarSetVarProc
	SetVariable labelsShadowXOffset,win= WMPolarGraphPanel,title="X,Y,Blur", help={help}, disable=disable
	SetVariable labelsShadowXOffset,win= WMPolarGraphPanel,limits={-40,40,0},value=$WMPolarTopOrDefaultDFVar("shadowXOffset")
	
	help= "Shadow Y offset in points"
	SetVariable labelsShadowYOffset,win= WMPolarGraphPanel,pos={219,438},size={40,19},bodyWidth=30,proc=WMPolarSetVarProc
	SetVariable labelsShadowYOffset,win= WMPolarGraphPanel,title=" ,", help={help}, disable=disable
	SetVariable labelsShadowYOffset,win= WMPolarGraphPanel,limits={-40,40,0},value=$WMPolarTopOrDefaultDFVar("shadowYOffset")
	
	help= "Shadow blur size in points. 0 just draws the label again offset with the chosen color. More than 10 draws slowly."
	SetVariable labelsShadowBlur,win= WMPolarGraphPanel,pos={260,438},size={40,19},bodyWidth=30,proc=WMPolarSetVarProc
	SetVariable labelsShadowBlur,win= WMPolarGraphPanel,title=" ,", help={help}, disable=disable
	SetVariable labelsShadowBlur,win= WMPolarGraphPanel,limits={0,40,0},value=$WMPolarTopOrDefaultDFVar("shadowBlur")

End

Function WMPolarLabelsTextColorPopup(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	ControlInfo/W=WMPolarGraphPanel $ctrlName

	Variable/G $WMPolarTopOrDefaultDFVar("tickLabelRed") = V_Red
	Variable/G $WMPolarTopOrDefaultDFVar("tickLabelGreen") = V_Green
	Variable/G $WMPolarTopOrDefaultDFVar("tickLabelBlue") = V_Blue
	Variable/G $WMPolarTopOrDefaultDFVar("tickLabelAlpha") = V_Alpha

	WMPolarAxesRedrawTopGraph()
End

Function WMPolarLabelsAngleUnitsRadio(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	Variable isDegrees
	SVAR angleTickLabelUnits= $WMPolarTopOrDefaultDFVar("angleTickLabelUnits")

	strswitch( ctrlName )
		case "labelsAngleRadiansRadio":
			isDegrees= 0
			angleTickLabelUnits="radians"
			break
		case "labelsAngleDegreesRadio":
			isDegrees= 1
			angleTickLabelUnits="degrees"
			break
	endswitch

	CheckBox labelsAngleRadiansRadio  win= WMPolarGraphPanel,value= !isDegrees
	CheckBox labelsAngleDegreesRadio  win= WMPolarGraphPanel,value= isDegrees

	WMPolarAxesRedrawTopGraph()
End

// sets a string value from the popup content
Function WMPolarLabelStringPopup(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String varName
	
	strswitch( ctrlName )
		case "labelsRadiusSignsPop":
			varName= "radiusTickLabelSigns"
			break
		case "labelsRadiusRotPop":
			varName= "radiusTickLabelRotation"
			break
		case "labelsAngleSignsPop":
			varName= "angleTickLabelSigns"
			break
		case "labelsAngleRotPop":
			varName= "angleTickLabelRotation"
			break
		case "labelsFontPop":
			varName= "tickLabelFontName"
			break
	endswitch
	
	WMPolarSetStr(varName,popStr)

	WMPolarAxesRedrawTopGraph()
End


Function WMPolarLabelEntireAngleButton(ctrlName) : ButtonControl
	String ctrlName

	NVAR angleTickLabelRangeStart=$WMPolarTopOrDefaultDFVar("angleTickLabelRangeStart")
	NVAR angleTickLabelRangeExtent= $WMPolarTopOrDefaultDFVar("angleTickLabelRangeExtent")

	// use outputs of WMPolarTicks() to set the tick label range
	NVAR dataAngle0=$WMPolarTopOrDefaultDFVar("dataAngle0")		// radians
	NVAR dataAngleRange= $WMPolarTopOrDefaultDFVar("dataAngleRange")		// radians

	angleTickLabelRangeStart= WMPolarRadToDeg(dataAngle0)
	angleTickLabelRangeExtent= WMPolarRadToDeg(dataAngleRange)

	WMPolarAxesRedrawTopGraph()
End


Function WMPolarLabelEntireRadiusButton(ctrlName) : ButtonControl
	String ctrlName

	NVAR radiusTickLabelRangeStart=$WMPolarTopOrDefaultDFVar("radiusTickLabelRangeStart")
	NVAR radiusTickLabelRangeEnd= $WMPolarTopOrDefaultDFVar("radiusTickLabelRangeEnd")

	// use outputs of WMPolarTicks() to set the tick label range
	NVAR dataInnerRadius=$WMPolarTopOrDefaultDFVar("dataInnerRadius")
	NVAR dataOuterRadius= $WMPolarTopOrDefaultDFVar("dataOuterRadius")

	radiusTickLabelRangeStart= dataInnerRadius
	radiusTickLabelRangeEnd= dataOuterRadius

	WMPolarAxesRedrawTopGraph()
End


Function WMPolarLabelsAngleRadioProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked 

	Variable subrangeAngleDisable= 0
	Variable subrangeFrame=1
	NVAR doAngleTickLabelSubRange= $WMPolarTopOrDefaultDFVar("doAngleTickLabelSubRange")
	strswitch(ctrlName)
		case "labelsAngleRangeAllRadio":
			doAngleTickLabelSubRange= 0
			subrangeAngleDisable= 2
			subrangeFrame= 0			// setvariables look more disabled this way
			break
		case "labelsAngleManualRangeRadio":
			doAngleTickLabelSubRange= 1
			subrangeAngleDisable= 0
			subrangeFrame= 1
			break
	endswitch	

	CheckBox labelsAngleRangeAllRadio  win= WMPolarGraphPanel,value=!doAngleTickLabelSubRange
	
		// >>>>>> Start of Angle Subrange
	CheckBox labelsAngleManualRangeRadio  win= WMPolarGraphPanel,value=doAngleTickLabelSubRange
	SetVariable labelsAngleManualStart  win= WMPolarGraphPanel, disable=subrangeAngleDisable, frame=subrangeFrame
	SetVariable labelsAngleManualExtent  win= WMPolarGraphPanel, disable=subrangeAngleDisable, frame=subrangeFrame
	Button labelsAngleSetEntireRange  win= WMPolarGraphPanel, disable=subrangeAngleDisable
		// <<<<<< End of Angle Manual Subrange

	WMPolarAxesRedrawTopGraph()
End

Function WMPolarLabelsRadiusRadioProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked 

	Variable subrangeRadiusDisable= 0
	Variable subrangeFrame=1
	NVAR doRadiusTickLabelSubRange= $WMPolarTopOrDefaultDFVar("doRadiusTickLabelSubRange")
	strswitch(ctrlName)
		case "labelsRadiusRangeAllRadio":
			doRadiusTickLabelSubRange= 0
			subrangeRadiusDisable= 2
			subrangeFrame= 0			// setvariables look more disabled this way
			break
		case "labelsRadiusManualRangeRadio":
			doRadiusTickLabelSubRange= 1
			subrangeRadiusDisable= 0
			subrangeFrame= 1
			break
	endswitch	

	CheckBox labelsRadiusRangeAllRadio  win= WMPolarGraphPanel,value=!doRadiusTickLabelSubRange
	
		// >>>>>> Start of Radius Subrange
	CheckBox labelsRadiusManualRangeRadio  win= WMPolarGraphPanel,value=doRadiusTickLabelSubRange
	SetVariable labelsRadiusManualStart  win= WMPolarGraphPanel, disable=subrangeRadiusDisable, frame=subrangeFrame
	SetVariable labelsRadiusManualEnd  win= WMPolarGraphPanel, disable=subrangeRadiusDisable, frame=subrangeFrame
	Button labelsRadiusSetEntireRange  win= WMPolarGraphPanel, disable=subrangeRadiusDisable
		// <<<<<< End of Radius Manual Subrange

	WMPolarAxesRedrawTopGraph()
End


// This gets called only if the pane is visible
// Enables or disables all controls in the radius tick labels group,
// with the caveat that the manual subrange controls aren't enabled unless Manual Subrange is checked
Function WMPolarLabelsAngleCheckboxProc(ctrlName,doAngleTickLabels) : CheckBoxControl
	String ctrlName
	Variable doAngleTickLabels 

	Variable angleDisable= doAngleTickLabels ? 0 : 2
	Variable angleFrame= angleDisable ? 0 : 1		// setvariables look more disabled without a frame

	CheckBox labelsAngleRangeAllRadio  win= WMPolarGraphPanel, disable=angleDisable

		// >>>>>> Start of Angle Subrange
	CheckBox labelsAngleManualRangeRadio  win= WMPolarGraphPanel, disable=angleDisable

	Variable subrangeAngleDisable= angleDisable
	if( subrangeAngleDisable == 0 )		// visible, enabled
		Variable doAngleTickLabelSubRange= WMPolarGetVar("doAngleTickLabelSubRange")	// 0 for entire angle range, 1 for subrange
		if( !doAngleTickLabelSubRange )
			subrangeAngleDisable= 2	// visible, disabled
		endif
	endif
	Variable subrangeFrame= (subrangeAngleDisable == 2) ? 0 : 1	// setvariables look more disabled with no frame.

	SetVariable labelsAngleManualStart  win= WMPolarGraphPanel, disable=subrangeAngleDisable, frame=subrangeFrame
	SetVariable labelsAngleManualExtent  win= WMPolarGraphPanel, disable=subrangeAngleDisable, frame=subrangeFrame
	Button labelsAngleSetEntireRange  win= WMPolarGraphPanel, disable=subrangeAngleDisable
		// <<<<<< End of Angle Manual Subrange

	PopupMenu labelsAngleSignsPop  win= WMPolarGraphPanel,disable=angleDisable
	PopupMenu labelsAngleRotPop  win= WMPolarGraphPanel,disable=angleDisable
	SetVariable labelsAngleFormat  win= WMPolarGraphPanel,disable=angleDisable, frame=angleFrame
	SetVariable labelsAngleOffset  win= WMPolarGraphPanel, disable=angleDisable, frame=angleFrame
	CheckBox labelsAngleRadiansRadio  win= WMPolarGraphPanel,disable=angleDisable
	CheckBox labelsAngleDegreesRadio  win= WMPolarGraphPanel,disable=angleDisable
	
	SetVariable labelsAngleScale  win= WMPolarGraphPanel,disable=angleDisable, frame=angleFrame

	WMPolarAxesRedrawTopGraph()
End

// This gets called only if the pane is visible
// Enables or disables all controls in the radius tick labels group,
// with the caveat that the manual subrange controls aren't enabled unless Manual Subrange is checked
Function WMPolarLabelsRadiusCheckboxProc(ctrlName,doRadiusTickLabels) : CheckBoxControl
	String ctrlName
	Variable doRadiusTickLabels 

	Variable radiusDisable= doRadiusTickLabels ? 0 : 2
	Variable radiusFrame= radiusDisable ? 0 : 1		// setvariables look more disabled without a frame

	Variable doRadiusTickLabelSubRange= WMPolarGetVar("doRadiusTickLabelSubRange")	// 0 for all (except, possibly, the origin), 1 for subrange
	
	CheckBox labelsRadiusRangeAllRadio  win= WMPolarGraphPanel, disable=radiusDisable
	CheckBox labelsRadiusNotOriginCheck  win= WMPolarGraphPanel, disable=radiusDisable

		// >>>>>> Start of Radius Subrange
	CheckBox labelsRadiusManualRangeRadio  win= WMPolarGraphPanel, disable=radiusDisable

	Variable subrangeRadiusDisable= radiusDisable
	if( subrangeRadiusDisable == 0 )		// visible, enabled
		if( !doRadiusTickLabelSubRange )
			subrangeRadiusDisable= 2	// visible, disabled
		endif
	endif
	Variable subrangeFrame= (subrangeRadiusDisable == 2) ? 0 : 1

	SetVariable labelsRadiusManualStart  win= WMPolarGraphPanel, disable=subrangeRadiusDisable, frame=subrangeFrame
	SetVariable labelsRadiusManualEnd  win= WMPolarGraphPanel, disable=subrangeRadiusDisable, frame=subrangeFrame
	Button labelsRadiusSetEntireRange  win= WMPolarGraphPanel, disable=subrangeRadiusDisable
		// <<<<<< End of Radius Manual Subrange

	PopupMenu labelsRadiusSignsPop  win= WMPolarGraphPanel,disable=radiusDisable
	PopupMenu labelsRadiusRotPop  win= WMPolarGraphPanel,disable=radiusDisable
	SetVariable labelsRadiusFormat  win= WMPolarGraphPanel,disable=radiusDisable, frame=radiusFrame
	SetVariable labelsRadiusOffset  win= WMPolarGraphPanel, disable=radiusDisable, frame=radiusFrame

	WMPolarAxesRedrawTopGraph()
End


// Rather than store settings in the graph's note
// and rather than insist the graph name not change for the settings to not be lost,
// an essentially random but unique name is stored as the "settings name"
// as the text of an invisible annotation named "polarGraphSettings"
// and additionally (as of 7.05) as a userData(polarGraphSettings) value in the graph.
// This "settings" name is the data folder leaf name of a subfolder in the WMPolarDF() data folder.
//
// If the graph doesn't exist, then the subfolder name is just the non-existent graph's name.
// This is appropriate for an about-to-be-created graph.
//
// If the graph does exist but doesn't know the polar graph settings name, then "" is returned.
//
// Warning: the settings data folder may not exist!
//
// NOTE:	DO NOT USE THIS TO TEST WHETHER THE NAMED GRAPH IS A POLAR GRAPH.
// 			USE WMPolarIsPolarGraph(), instead.
//
Function/S WMPolarSettingsNameForGraph(graphName)
	String graphName
	
	if( strlen(graphName) == 0 )
		graphName=WinName(0,1)
		if( strlen(graphName) == 0 )
			return ""
		endif
	endif
	DoWindow $graphName
	if( V_Flag == 0 )
		return graphName		// default settings name is the graph's name as it is now
	endif

	// new (7.05) way
	String settings= GetUserData(graphName, "", "polarGraphSettings")
	if( strlen(settings) )
		return settings
	endif
	
	// old way
	String list=AnnotationList(graphName)
	if( strlen(list) == 0 || WhichListItem("polarGraphSettings",list) == -1 )
		return ""
	endif
	String info= AnnotationInfo(graphName,"polarGraphSettings")
	Variable start= strsearch(info,"TEXT:",0)
	if( start < 0 )
		return ""
	endif
	start += strlen("TEXT:")
	info= info[start,inf]
	return info
End

// returns truth the textbox exists
Function WMPolarSettingsTextBoxText(graphName, text)
	String graphName // input
	String &text // output
	
	String annotations= AnnotationList(graphName)
	Variable whichOne= WhichListItem("polarGraphSettings", annotations)
	Variable haveTextBox = whichOne >= 0
	if( haveTextBox )
		String info= AnnotationInfo(graphName,"polarGraphSettings",1)
		text=StringByKey("TEXT",info)
	else
		text=""
	endif
	return haveTextBox
End

// Added for Igor 9.02
// Returns the datafolder name that the polar graph was using.
Function/S WMPolarDisconnectGraph(graphName)
	String graphName	// can be "" for top polar graph
	
	String dfName=""
	if( strlen(graphName) == 0 )
		graphName = WMPolarTopPolarGraph()
	endif
	
	if( strlen(graphName) )
		dfName = WMPolarSettingsNameForGraph(graphName)
		WMPolarSaveSettingsName(graphName, "") // graph no longer marked as a Polar Graph.
		SetWindow $graphName hook=$""
	endif
	return dfName
End

// Added for Igor 9.02
// It is imporant to supply the dfName if it is not the same as the polar graph's name
Function WMPolarReconnectGraph(graphName, dfName)
	String graphName	// can be "" for top polar graph
	String dfName		// can be "" to use the graph's name as the data folder
	
	if( strlen(graphName) == 0 )
		graphName = WinName(0,1,1) // top visible graph
	endif
	
	if( strlen(graphName) )
		if( strlen(dfName) == 0 )
			dfName = graphName
		endif
		WMPolarSaveSettingsName(graphName, dfName)
		SetWindow $graphName hook=WMPolarGraphHook, hookEvents=1	// mouse button events
	endif
End


// Rewritten to update the textbox only if it exists and differs
Function WMPolarSaveSettingsName(graphName, dfName)
	String graphName
	String dfName // dfName is not the full path, it is only the leaf name of the data folder path
					 // the data folder containing the polar graph settings for the named graph.
					 // pass "" to remove the data folder name from the graph

	// Update the TextBox only if it exists and text differs
	String text
	Variable haveTextbox = WMPolarSettingsTextBoxText(graphName, text)
	Variable updateTextBox = haveTextbox && CmpStr(text,dfName) != 0
	Variable wasBlocked = WMPolarBlockModifiedWindowHook(graphName,2)	// query
	WMPolarBlockModifiedWindowHook(graphName,1)	// block
	if( strlen(dfName) )
		if( updateTextBox )
			// the "old way" of storing the data folder name is in the text of an invisible annotation.
			// this caused recursion (really "ping-ponging") before the text comparison test was added.
			TextBox/W=$graphName/C/N=polarGraphSettings/V=0 dfName // will provoke a modified event.
		endif
		
		// the "new way" is storing the dfName in a named userdata, which does not provoke a modified event.
		SetWindow $graphName userdata(polarGraphSettings)=dfName

		// 9.01: Ensure the settings data folder exists so that saving the graph name does not fail.
		WMPolarEnsureSettingsDF(dfName)
	else // making the graph no longer a polar graph.
		if( updateTextBox )
			TextBox/W=$graphName/K/N=polarGraphSettings // once killed, only the "new way" will be used.
		endif
		SetWindow $graphName userdata(polarGraphSettings)=""
	endif
	String pathToVar=WMPolarGraphDFVar(graphName,"graphName")
	if( strlen(pathToVar) )
		String/G $pathToVar = graphName
	endif
	WMPolarBlockModifiedWindowHook(graphName,wasBlocked)	// restore old block setting
End


// WMPolarIsPolarGraph() returns truth that the graph exists and is a polar graph.
// To be considered a polar graph, the graph must know it's settings data folder and the data folder must exist.
Function WMPolarIsPolarGraph(graphName)
	String graphName	// can NOT be ""

	// Does window exist?
	if( strlen(graphName) == 0 )
		return 0 // nope
	endif
	DoWindow $graphName
	if( V_Flag == 0 )
		return 0 // nope
	endif
	// Does the polar graph know the data folder name where settings are stored?
	String settings= WMPolarSettingsNameForGraph(graphName)
	if( strlen(settings) == 0 )
		return 0 // nope
	endif
	// Does that data folder exist?
	if( !WMPolarGraphDFExists(settings) )
		return 0 // nope
	endif
	
	// else, it must be a polar graph!
	return 1
End

Function/S WMPolarDF()
	return "root:Packages:WMPolarGraphs"
End

// this also works for waves in the main polar graphs data folder
Function/S WMPolarDFVar(varName)
	String varName
	return WMPolarDF()+":"+varName
End


// Pass "" to set to main Polar data folder.
// Ensures the data folder exists.
Function/S WMPolarSetSubfolderDF(subfolder)
	String subfolder
	
	String oldDF= GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S WMPolarGraphs
	if( strlen(subfolder) )
		NewDataFolder/O/S $subfolder
	endif
	return oldDF
End

// Returns the full path to the data folder for the settings whose datafolder leaf name is subfolderName.
// Ensures the data folder exists.
Function/S WMPolarEnsureSettingsDF(subfolderName)
	String subfolderName
	String oldDF = WMPolarSetSubfolderDF(subfolderName)
	SetDataFolder oldDF
	String df = WMPolarSettingsDF(subfolderName)
	return df
End

// Returns the full path to the data folder for the settings whose datafolder leaf name is subfolderName,
// properly quoting liberal subfolderNames.
// The data folder might not exist.
Function/S WMPolarSettingsDF(subfolderName)
	String subfolderName // aka "settings" or "dfName"
	
	subfolderName= PossiblyQuoteName(subfolderName)		// '_default_'
	return WMPolarDFVar(subfolderName)
End

Function WMPolarGraphDFExists(graphName)
	String graphname
	
	String df= WMPolarGraphDF(graphname)
	return (strlen(df) > 0) && DataFolderExists(df)
End

// Warning: the returned data folder might not exist.
// "" is returned if the graph exists but doesn't have the invisible annotation or settings userdata
Function/S WMPolarGraphDF(graphNameOrDefault)
	String graphNameOrDefault
	
	String settings
	if( CmpStr(graphNameOrDefault,"_default_") == 0 )
		settings= "_default_"
	else
		settings= WMPolarSettingsNameForGraph(graphNameOrDefault)
		if( strlen(settings) == 0 )
			return ""	// existing graph is not a polar graph.
		endif
	endif
	String df= WMPolarSettingsDF(settings)
	return df
End


// returns path to variable (or wave) in existing data folder, or "" if the data folder doesn't exist.
// In either case, the variable or wave may not exist; test with NVAR_Exists or WaveExists
// Use "" for graphName for top polar graph.
Function/S WMPolarGraphDFVar(graphNameOrDefault,varName)
	String graphNameOrDefault,varName
	
	String path= WMPolarGraphDF(graphNameOrDefault)
	if( strlen(path) )
		path += ":"+varName
	endif
	return path
end

// "" means top polar graph
Function/S WMPolarGraphTracesTW(graphName)
	String graphName
	
	String path= WMPolarGraphDFVar(graphName,"polarTracesTW")
	return path
End

// Sets current DF to top polar graphs Data Folder and returns OLD datafolder
// If the top polar graph doesn't exist, the data folder is not changed and "" is returned
Function/S WMPolarSetTopPolarGraphDF()

	String oldDF= ""
	String df= WMPolarTopPolarGraphDF()
	if( (strlen(df) > 0) && DataFolderExists(df) )
		oldDF= GetDataFolder(1)
		SetDataFolder df
	endif
	return oldDF
End

Function/S WMPolarTopPolarGraphDF()

	String topPolarGraph=WMPolarTopPolarGraph()
	if( strlen(topPolarGraph) == 0 )
		return ""	// no polar graph.
	endif
	String df= WMPolarGraphDF(topPolarGraph)
	return df
End

// This will never return a path to the _default_ data folder.
Function/S WMPolarTopDFVar(varName)
	String varName
	
	String topPolarGraph=WMPolarTopPolarGraph()
	String path= WMPolarGraphDFVar(topPolarGraph,varName)
	return path
end

// Use this in the panel, so that if there is no polar graph
// the controls will be tied to the defaults (but the tabs will
// be disabled so nothing will get changed).
// This allows the update to work even if there is no polar graph.
Function/S WMPolarTopOrDefaultDFVar(varName)
	String varName
	
	String graphName= WMPolarTopPolarGraph()
	if( strlen(graphName) == 0 )
		graphName="_default_"
	endif
	String path= WMPolarGraphDFVar(graphName,varName)
	return path
End

Function/S WMPolarTopGraphOrDefault()
	String graphName= WMPolarTopPolarGraph()
	if( strlen(graphName) == 0 )
		graphName="_default_"
	endif
	return graphName
End

// was PolarGV, will get value from _default_
Function WMPolarGetVar(varName)
	String varName

	String path=WMPolarTopDFVar(varName)
	NVAR/Z nv=$path	// we expect nv to exist: use  NVAR_SVAR_WAVE checking to detect an error
	if( NVAR_Exists(nv) )
		return nv
	else
		return NaN
	endif
End

Function WMPolarGetVarOrDefault(varName, defaultValue)
	String varName
	Variable defaultValue

	String path=WMPolarTopDFVar(varName)
	NVAR/Z nv=$path	// we expect nv to exist: use  NVAR_SVAR_WAVE checking to detect an error
	if( NVAR_Exists(nv) )
		return nv
	else
		return defaultValue
	endif
End

// returns truth that variableValue was set
// was PolarSV
// will not set _default_ values.
Function WMPolarSetVar(varName,variableValue)
	String varName
	Variable variableValue

	Variable set=0
	String path=WMPolarTopDFVar(varName)
	NVAR/Z nv=$path	// we expect nv to exist: use  NVAR_SVAR_WAVE checking to detect an error
	if( NVAR_Exists(nv) )
		 nv= variableValue
		 set=1
	endif
	return set
End

// was PolarGS, will get value from _default_
Function/S WMPolarGetStr(varName)
	String varName

	String path=WMPolarTopDFVar(varName)
	SVAR/Z sv=$path
	if( SVAR_Exists(sv) )
		return sv
	else
		return ""
	endif
End

// was PolarSS
// returns truth that stringValue was set
// will not set _default_ values.
Function WMPolarSetStr(varName,stringValue)
	String varName,stringValue

	Variable set=0
	String path=WMPolarTopDFVar(varName)
	SVAR/Z sv=$path	// we expect sv to exist: use NVAR_SVAR_WAVE checking to detect an error
	if( SVAR_Exists(sv) )
		 sv= stringValue
		 set=1
	endif
	return set
End


// Returns one of the cleaned choices if SVAR $varName matches it according to slightly looser standards than exact equality.
Function/S WMPolarGetCleanedStr(varName,listOfCleanedChoices)
	String varName				// name of global string for current polar graph
	String listOfCleanedChoices	// acceptable choices
	
	String str= WMPolarGetStr(varName)	// may be user-entered approximation of acceptable choices.
	Variable whichItem= WhichListItem(str, listOfCleanedChoices)
	if( whichItem < 0 ) 	// str doesn't exactly match any of the ideal "clean" choices, perhaps the user added spaces or got the case wrong.
		// we compare by removing all spaces from str and listOfCleanedChoices, then using case-insensitive WhichListItem
		String strippedStr= ReplaceString(" ", str, "")
		String strippedChoices=ReplaceString(" ", listOfCleanedChoices, "")
		Variable matchCase= 0
		whichItem= WhichListItem(strippedStr, strippedChoices , ";", 0, matchCase)
		if( whichItem >= 0 )
			str= StringFromList(whichItem, listOfCleanedChoices)
			WMPolarSetStr(varName,str)
		endif
	endif

	return str
End

Function WMPolarWhichCleanedListItem(str, listOfIdealChoices)
	String str		// an item which, after "cleaning", might match one of the items in listOfIdealChoices
	String listOfIdealChoices
	
	Variable whichItem= WhichListItem(str, listOfIdealChoices)
	if( whichItem < 0 ) 	// str doesn't exactly match any of the ideal "clean" choices, perhaps the user added spaces or got the case wrong.
		// we compare by removing all spaces from str and listOfCleanedChoices, then using case-insensitive WhichListItem
		String strippedStr= ReplaceString(" ", str, "")
		String strippedChoices=ReplaceString(" ", listOfIdealChoices, "")
		Variable matchCase= 0
		whichItem= WhichListItem(strippedStr, strippedChoices , ";", 0, matchCase)
	endif
	return whichItem
End

// Sets current DF to the polar graphs Data Folder and returns OLD datafolder
// If the named polar graph doesn't exist, the data folder is not changed and "" is returned
Function/S WMPolarSetPolarGraphDF(graphName)
	String graphName
	
	String oldDF= ""
	String df= WMPolarGraphDF(graphName)
	if( (strlen(df) > 0) && DataFolderExists(df) )
		oldDF= GetDataFolder(1)
		SetDataFolder df
	endif
	return oldDF
End

Function/S WMPolarTopPolarGraph()

	String graphName
	Variable i=0
	do
		graphName= WinName(i, 1)
		if( strlen(graphName) == 0 )
			break
		endif
		if( WMPolarIsPolarGraph( graphName) )
			return graphName
		endif
		i += 1
	while(1)
	return ""
End

// presumes there is only one graph per TW,
// examines only graphs that are open
// does not know about recreation macros.
Function/S WMPolarGraphForTW(tw)
	WAVE/T/Z tw
	
	if( !WaveExists(tw) )
		return ""
	endif
	
	String graphName, settings
	String twDF= GetWavesDataFolder(tw,1)	// just the data folder, has trailing ":"
	Variable i=0
	do
		graphName= WinName(i, 1)
		if( strlen(graphName) == 0 )
			break
		endif
		settings= WMPolarSettingsNameForGraph(graphName)
		if( strlen( settings) )
			String df= WMPolarSettingsDF(settings)+":"
			if( CmpStr(df, twDF) == 0 )
				return graphName
			endif
		endif
		i += 1
	while(1)
	graphName = StrVarOrDefault(twDF+"graphName", "")
	return graphName
End


// List of visible polar graphs (doesn't include _default_)
// See Also: WMPolarListPolarSubfolders
Function/S 	WMPolarListPolarGraphs(disableIfNoDataFolder)
	Variable disableIfNoDataFolder
	
	String graphName, list=""
	Variable i
	for( i=0; ; i += 1)
		graphName= WinName(i, 1)
		if( strlen(graphName) == 0 )
			break
		endif
		if( !WMPolarIsPolarGraph(graphName))
			continue
		endif
		String settings= WMPolarSettingsNameForGraph(graphName)
		if( strlen(settings) == 0 )
			continue
		endif
		
		if( disableIfNoDataFolder )
			String df= WMPolarSettingsDF(settings)
			if( strlen(df) == 0 || DataFolderExists(df ) == 0 )
				graphName= "\\M1("+graphName
			endif
		endif
		list += graphName + ";"
	endfor
	return SortList(list)
End

// List of  polar graph subfolders, including _default_
// See Also: WMPolarListPolarGraphs
Function/S WMPolarListPolarSubfolders()

	String df, list=""
	Variable i=0
	do
		df= GetIndexedObjName(WMPolarDF(),4,i )
		if( strlen(df) == 0 )
			break
		endif
		list += df + ";"
		i += 1
	while(1)
	return list
End

Function/S WMPolarEnableModifyPolarGraph()

	String menuItem= "Modify Polar Graph"
	if( WMPolarGraphDFExists("") == 0 )
		menuItem= ""	// disappears
	endif
	return menuItem
End

Function WMPolarShowHideMatchingControls(win,matchStr,doShow)
	String win, matchStr
	Variable doShow
	
	String matchingControls=ListMatch(ControlNameList(win), matchStr)
	ModifyControlList/Z matchingControls, win=$win, disable=(doShow ? 0 : 1)
End

Function/S WMPolarRadiusAxisHalvesPopup()

	String pop
	String where= WMPolarGetCleanedStr("radiusAxesWhere",WMPolarRadiusAxisAtPopup())
	if( CmpStr(where,"  Left") == 0 || CmpStr(where,"  Right") == 0 )
		pop= "Upper Half;Lower Half;Both Halves;"
	else
		pop= "Left Half;Right Half;Both Halves;"
	endif
	
	return pop
End

// Returns "" if not one of "  Left; Bottom;  Right; Top;"
// else returns the item
Function/S WMPolarRadiusAxesAtSide(radiusAxesWhere)
	String radiusAxesWhere
	
	String list="  Left;  Right;  Top;  Bottom;"
	Variable whichOne= WMPolarWhichCleanedListItem(radiusAxesWhere,list)
	if( whichOne >= 0 )
		return StringFromList(whichOne,list)
	endif
	return ""
End	

Function/S WMPolarRadiusAxisAtPopup()

	String pop= "  Off;  Angle Start;  Angle Middle;  Angle End;  Angle Start and End;"			// 1-5
	pop +="  0;  90;  180; -90;"															// 6-9
	pop +="  0, 90;  90, 180; -180, -90; -90, 0;  0, 180;  90, -90;  0, 90, 180, -90;"	// 10-16
	pop +="  Left;  Right;  Top;  Bottom;"													// 17-20 (these need an "at radius=" value)
	pop +="  All Major Angles;  At Listed Angles"												// 21-22
	return pop
End

Function/S WMPolarAngleAxisAtPopup()

	String pop= "Off;Radius Start;Radius End;Radius Start and End;All Major Radii;At Listed Radii;"
	return pop
End

// ++++ START obsolete Resolution Dialog (code retained to accomodate saved old experiments)

Function WMPolarAxesResolutionButton(ctrlName) : ButtonControl
	String ctrlName

	 
								  
				  
							 
	  
	 
	// resolution button is obsolete
	  

End

// obsolete
Function WMPolarResolutionCloseHelp(ctrlName) : ButtonControl
	String ctrlName

End

Function WMPolarResolutionCirclesRadio(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

End

Function WMPolarUpdateResolutionPanel()

	DoWindow/K WMPolarResolutionPanel
	Execute/P/Q/Z "WMPolarPanelUpdate(1)" // resolution panel is obsolete
End

Function WMPolarResolutionPanelHook(infoStr)
	String infoStr

	Variable statusCode= 0
	String event= StringByKey("EVENT",infoStr)
	String win= StringByKey("WINDOW",infoStr)
	strswitch(event)
		case "activate":
			Print "The Resolution Panel is obsolete and will be closed."
			Execute/P/Q/Z "DoWindow/K WMPolarResolutionPanel" // run this before DoAlert to avoid double-activate
			Execute/P/Q/Z "DoAlert 0, \"The Resolution Panel is obsolete.\""
			return 0
			break
	endswitch

	return statusCode				// 0 if nothing done, else 1 or 2
End

// ---- End Resolution Dialog - obsolete


// Generic control procedures that force the target polar graph to redraw the axes and/or grids

// Normal (push) buttons
Function WMPolarButtonProc(ctrlName) : ButtonControl
	String ctrlName

	WMPolarAxesRedrawTopGraph()
End

// this works for radio buttons, too
Function WMPolarCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	WMPolarAxesRedrawTopGraph()
End

Function WMPolarPopupProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	WMPolarAxesRedrawTopGraph()
End

Function WMPolarSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	WMPolarAxesRedrawTopGraph()
End

// ------------------ routines you can call to create or modify polar graphs without using the panel (added for version 4.06)

// Returns name of first polar graph found that is displaying the given radius data, or ""
Function/S WMPolarGraphDisplayed(radiusData)
	Wave radiusData			// a radius data wave
	
	// look in each polar data folder...
	String polarGraphsLists= WMPolarListPolarGraphs(1)
	Variable i=0
	do
		String polarGraphName=StringFromList(i,polarGraphsLists)
		if( strlen(polarGraphName) == 0 )	// none left
			return ""
		endif
		WAVE/T/Z tw= $WMPolarGraphTracesTW(polarGraphName)	
		if( WaveExists(tw) )
			// ... inside each row of  the PolarTracesTW wave for a match with the [%radiusWavePath] columns
			Variable row= WMPolarRadiusWaveRow(tw,radiusData) // Returns the row in the polarTracesTW text wave, or -1 if not found
			if( row >= 0 )
				return polarGraphName
			endif
		endif
		i += 1
	while(1)
	return ""
End

// Returns name of the trace in the named graph that is displaying the radius (Y) data
Function/S WMPolarTraceNameForRadiusData(polarGraphName,radiusData)
	String polarGraphName
	Wave radiusData			// a radius data wave
	
	if( strlen(polarGraphName) == 0 )
		return ""
	endif
	WAVE/T/Z tw= $WMPolarGraphTracesTW(polarGraphName)	
	if( WaveExists(tw) )
		// ... inside each row of  the PolarTracesTW wave for a match with the [%radiusWavePath] columns
		Variable row= WMPolarRadiusWaveRow(tw,radiusData) // Returns the row in the polarTracesTW text wave, or -1 if not found
		if( row >= 0 )
			return tw[row][kShadowTraceName]
		endif
	endif
	return ""
End

// Given a polar trace name, return help text describing the source(s) for the trace
Function/S PolarTraceSources(polarGraphName,traceName)
	String polarGraphName,traceName

	String helpText=""
	WAVE/Z/T tw= $WMPolarGraphTracesTW(polarGraphName)
	if( WaveExists(tw) )
		String onlyTraceName = WMPolarCleanTraceName(traceName)
		WAVE/Z wShadowY= $GetWavesDataFolder(tw,1)+onlyTraceName
		if( WaveExists(wShadowY) )
			Variable row= WMPolarShadowWaveRow(wShadowY)
			if( row != -1 )		// this wave was found in polarTracesTW
				// Source radiusDataPath
				String radiusDataPath=tw[row][kRadiusWavePath]	// NOT in current data folder
				
				// Source  angleDataPath (or X scaling)
				String angleDataPath=tw[row][kAngleWavePath]	// NOT in current data folder
				if( strlen(angleDataPath) == 0 )
					angleDataPath= "_calculated_"
				endif
				// units are specific to the trace and currently can't be changed except by removing and re-appending the trace.
				String unitsStr= tw[row][kAngleUnits] // "degrees" or "radians"
				helpText= radiusDataPath+" vs "+angleDataPath+" ("+unitsStr+")"
			endif
		endif
	endif
	return helpText
End

Function/S WMPolarCleanTraceName(traceName)
	String traceName // can have appended " [stuff here..." which we clean up (remove)
	
	Variable pos = strsearch(traceName, " [", 0)
	if( pos >= 0 )
		traceName[pos,inf] = "" // truncate
	endif
	return traceName
End

// Returns radius value at the attachment point, or NaN if error
// Usage: Tag polarTraceName, x, "\\{WMPolarTagRadius(TagWaveRef(),TagVal(0))}"
Function WMPolarTagRadius(tagWaveRefHere,tagPointNumber)
	Wave/Z tagWaveRefHere	// TagWaveRef, this is the polar shadow Y wave.
	Variable tagPointNumber	// TagVal(0) = point number

	Wave wShadowY= tagWaveRefHere
	Variable row= WMPolarShadowWaveRow(wShadowY)// Returns the row in the polarTracesTW text wave, or -1 if not found
	if( row < 0 )		// this wave was NOT found in polarTracesTW
		return NaN
	endif
	// this wave WAS found in polarTracesTW
	String df= GetWavesDataFolder(wShadowY,1)	// we rely on the fact that the shadow wave and the polarTracesTW wave are in the same data folder
	WAVE/T/Z tw= $(df+"polarTracesTW")
	if( !WaveExists(tw) )
		return NaN
	endif
	WAVE/Z radiusData= $tw[row][kRadiusWavePath]
	if( !WaveExists(radiusData) )
		return NaN
	endif
	return radiusData[tagPointNumber]
End

// Returns angle values at the attachment point, or NaN if error.
// The value returned is in the same units as the angle axes, NOT the angle Data units
// Usage: Tag polarTraceName, x, "\\{WMPolarTagAngle(TagWaveRef(),TagVal(0))}"
Function WMPolarTagAngle(tagWaveRefHere,tagPointNumber)
	Wave/Z tagWaveRefHere	// TagWaveRef, this is the polar shadow Y wave.
	Variable tagPointNumber	// TagVal(0) = point number

	Wave wShadowY= tagWaveRefHere
	Variable row= WMPolarShadowWaveRow(wShadowY)// Returns the row in the polarTracesTW text wave, or -1 if not found
	if( row < 0 )		// this wave was NOT found in polarTracesTW
		return NaN
	endif
	// this wave WAS found in polarTracesTW
	String df= GetWavesDataFolder(wShadowY,1)	// we rely on the fact that the shadow wave and the polarTracesTW wave are in the same data folder
	WAVE/T/Z tw= $(df+"polarTracesTW")
	if( !WaveExists(tw) )
		return NaN
	endif
	String graphName=WMPolarGraphForTW(tw)
	Variable angle
	if( CmpStr("_calculated_", tw[row][kAngleWavePath]) == 0 )
		WAVE radiusData= $tw[row][kRadiusWavePath]	// NOT in current data folder
		angle= pnt2x(radiusData,tagPointNumber)
	else
		WAVE/Z angleData= $tw[row][kAngleWavePath]
		if( !WaveExists(angleData) )
			return NaN
		endif
		angle= angleData[tagPointNumber]
	endif
	Variable dataIsRadians= CmpStr(tw[row][kAngleUnits],"radians")==0
	String angleLabelUnits= WMPolarGraphGetStr(graphName,"angleTickLabelUnits")
	if( CmpStr(angleLabelUnits,tw[row][kAngleUnits]) != 0 )	// need to convert
		if( CmpStr(angleLabelUnits," radians") == 0 )			// convert data from degrees to displayed radians
			angle *= pi/180
		else
			angle *= 180/pi		
		endif
	endif
	
	Variable scale= WMPolarGraphGetVar(graphName,"angleTickLabelScale")
	if( numtype(scale) == 0 )
		angle *= scale
	endif
	String angleTickLabelSigns= WMPolarGraphGetStr(graphName,"angleTickLabelSigns")
	if( CmpStr(angleTickLabelSigns," no signs") == 0 )
		angle= abs(angle)
	endif
	
	return angle	// in angle axes units, NOT the data units.
End

// Performs like WMPolarNewButton() that runs when pressing the New Polar Graph button,
// but no Modify Polar Graph panel is needed
// Returns name of created (or used) polar graph.
// You can call this routine with the name of an existing empty graph so you can set up things
// like the title, the userKill (/K), or the initial window position.
Function/S WMNewPolarGraph(templateGraphName, newOrExistingGraphName)
	String templateGraphName	// existing polar graph name to copy setting from, or "_default_" or ""
	String newOrExistingGraphName // name to give new graph, or name of graph to use, or "" for automatically created graph name

	if( DataFolderExists(WMPolarDF()) == 0 )
		WMPolarGraphGlobalsInit()
	endif
	// source of settings is either the _default_ data folder, or an existing graph's data folder.
	if( strlen(templateGraphName) == 0 )
		templateGraphName="_default_"
	endif
	String srcDF= WMPolarGraphDF(templateGraphName)
	if( strlen(srcDF) == 0 || DataFolderExists(srcDF) == 0 )
		srcDF= WMPolarGraphDF("_default_")
	endif

	WMPolarGraphDefaults("_default_")

	if( strlen(newOrExistingGraphName) == 0 || (WinType(newOrExistingGraphName) != 0 && WinType(newOrExistingGraphName) != 1) )
		newOrExistingGraphName= WMPolarNewGraphName()
	endif

	if( WinType(newOrExistingGraphName) != 1 )	// need to create the graph
		DoWindow/K $newOrExistingGraphName
		Display/W=(10,45,360,345)
		DoWindow/C $newOrExistingGraphName
	endif
	WMPolarSaveSettingsName(newOrExistingGraphName, newOrExistingGraphName) // dfName and graph name initially the same.
	SetWindow $newOrExistingGraphName hook=WMPolarGraphHook, hookEvents=1	// mouse button events

	// copy the settings
	String destDF= WMPolarGraphDF(newOrExistingGraphName)	// invisible annotation or userdata(polarGraphSettings) must exist for this to succeed.
	if( DataFolderExists(destDF) )
		WMPolarCleanOutDF(destDF)	// should remove any dependencies that prevent folder deletion.
		KillDataFolder/Z $destDF
	endif
	DuplicateDataFolder $srcDF+":", $destDF
	WMPolarCleanOutDF(destDF)

	// 9.03: initialize the virtual drawing layers for newly-created polar graphs
	String drawLayer = WMPolarGraphWantedDrawLayer(newOrExistingGraphName)
	WMPolarEnsureVirtualLayers(newOrExistingGraphName, drawLayer)

	// 9.03: allow drawing polar axes, grid, etc without polar traces or an image
	WAVE/T/Z tw= WMPolarEnsurePolarGraphTracesWave(newOrExistingGraphName)	// Make polar drawing code happy
	WMPolarUpdateAutoRangeTrace(newOrExistingGraphName,tw,-1, -1, 1, 1)	// append default autoscale trace
	WMPolarInitializeAxes(newOrExistingGraphName)	// hide axes

	return newOrExistingGraphName
End

Function WMClosePolarGraph(graphName, saveRecreationMacro)
	String graphName	// "" for top polar graph
	Variable saveRecreationMacro // if set, the recreation macro is saved, and the graph is closed afterwards using Execute/P

	if( strlen(graphName) == 0 )
		graphName= WMPolarTopPolarGraph()
	endif
	if( strlen(graphName) == 0 || !WMPolarIsPolarGraph(graphName) )
		return 0 // nothing done
	endif

	Variable saveMethod
	if( saveRecreationMacro )
		// functions can't update recreation macros, so we must use an Execute/P hack
		Execute/P/Q/Z "DoWindow/R "+graphName
		Execute/P/Q/Z "KillWindow/Z "+graphName
		saveMethod = 2 // deferred
	else
		KillWindow/Z $graphName	// allows the window hook to run, without any option to save a recreation macro
		saveMethod = 1 // immediate
	endif

	return saveMethod
End

Function WMKillPolarGraphDataFolder(subfolderName)
	String subfolderName	// "PolarGraph0", for example, corresponding to root:Packages:WMPolarGraphs:PolarGraph0

	if( CmpStr(subfolderName, "_default_") != 0 )
		String polarDF= WMPolarSettingsDF(subfolderName)
		WMPolarCleanOutDF(polarDF)
		KillDataFolder/Z $polarDF
	endif
End

// CloseAllPolarGraphs() solves the problem of releasing dependencies in root:Packages:WMPolarGraphs:*
// However it can be ruthless (though your radius and angle waves are not ever removed):
// CloseAllPolarGraphs(0, 0) = nuclear option; all open and closed polar graphs, settings, and derived data are removed.
// CloseAllPolarGraphs(1, 0) = nuclear option: open polar graphs are closed after saving or updating a recreation macro.
//										All Polar data (including dependencies) are deleted.
// CloseAllPolarGraphs(0, 1) = "mixed" option: open polar graphs are closed without saving or updating a recreation macro.
//										Polar data (including dependencies) are saved if a recreation macro was saved,
//										otherwise it is deleted.
// CloseAllPolarGraphs(1, 1) = "safe" option; open polar graphs are closed after their recreation macros are saved.
//										No Polar data is deleted Dependencies are maintained.
Function CloseAllPolarGraphs(saveRecreationMacros, preserveClosedPolarGraphs)
	Variable saveRecreationMacros 		// preserve OPEN polar graphs as recreation macros before closing the graph
	Variable preserveClosedPolarGraphs // note that preserveClosedPolarGraphs does NOT preserve OPEN polar graphs.

	String allGraphs = WinList("*",";","WIN:1")
	Variable index, n = ItemsInList(allGraphs)
	Variable mustDeferClosedPolarGraphs = 0
	for( index=0; index<n; index+=1 )
		String graphName= StringFromList(index, allGraphs)
		if( WMPolarIsPolarGraph(graphName) )
			Variable saveMethod = WMClosePolarGraph(graphName,saveRecreationMacros)
			if( saveMethod==2 )
				mustDeferClosedPolarGraphs= 1// because WMClosePolarGraph had to use Execute/P
			endif
		endif
	endfor
	// No more open polar graphs, now.
	// The above code did not release dependencies for closed polar graphs
	// that have saved recreation macros (and thus saved dependencies).
	Variable closeDFMethod = 0 // no data folders cleaned
	if( !preserveClosedPolarGraphs )
		if( mustDeferClosedPolarGraphs )
			Execute/P/Q/Z "CloseAllPolarGraphs(0, "+num2istr(preserveClosedPolarGraphs)+")"
			closeDFMethod = 2 // deferred
		else
			// We take care of that now.
			// get a list of all data folders that stays put when one is deleted.
			String parentFolder = WMPolarDF()
			String allDFs=WMDataFolderList(parentFolder)
			n = ItemsInList(allDFs)
			for( index=0; index<n; index+=1 )
				String subfolderName = StringFromList(index, allDFs)
				WMKillPolarGraphDataFolder(subfolderName)
			endfor
			closeDFMethod = 1 // immediate
		endif
	endif
	if( closeDFMethod != 2 )
		//Execute/P/Q/Z "WMPolarPanelUpdate()"
		WMPolarPanelUpdate(1)
	endif
	return closeDFMethod
End

// renamed because Igor 9 does have a DataFolderList function.
static Function/S WMDataFolderList(parentFolder)
	String parentFolder	// for example, "root:Packages", no trailing ":"
	
	Variable index= 0
	String list=""
	do
		String subfolderName = GetIndexedObjName(parentFolder, 4, index)
		if( strlen(subfolderName) == 0 )
			break // no more data folders
		endif
		list += subfolderName + ";"
		index += 1
	while(1)
	return list
End

// returns path to variable if it exists, or "" if it doesn't exist.
Function/S WMPolarGraphSetVar(graphNameOrDefault,varName,variableValue)
	String graphNameOrDefault, varName
	Variable variableValue

	String path=WMPolarGraphDFVar(graphNameOrDefault,varName)
	NVAR/Z nv=$path
	if( NVAR_Exists(nv) )
		 nv= variableValue
	else
		path=""
	endif
	return path
End

// returns the polar graph numeric value for the named graph (or the default value if "_default_")
// or NaN if the variable doesn't exist
Function WMPolarGraphGetVar(graphNameOrDefault,varName)
	String graphNameOrDefault, varName

	NVAR/Z nv=$WMPolarGraphDFVar(graphNameOrDefault,varName)
	if( NVAR_Exists(nv) )
		return nv
	else
		return NaN
	endif
End

Function WMPolarGraphGetVarOrDefault(graphNameOrDefault,varName,defaultValue)
	String graphNameOrDefault, varName
	Variable defaultValue

	NVAR/Z nv=$WMPolarGraphDFVar(graphNameOrDefault,varName)
	if( NVAR_Exists(nv) )
		return nv
	else
		return defaultValue
	endif
End


// returns path to variable if it exists, or "" if it doesn't exist.
Function/S WMPolarGraphSetStr(graphNameOrDefault,varName,stringValue)
	String graphNameOrDefault, varName, stringValue

	String path=WMPolarGraphDFVar(graphNameOrDefault,varName)
	SVAR/Z sv=$path
	if( SVAR_Exists(sv) )
		 sv= stringValue
	else
		path=""
	endif
	return path
End

// returns the polar graph string value for the named graph (or the default value if "_default_")
// or "" if the string doesn't exist.
// compare to WMPolarGetStr().
Function/S WMPolarGraphGetStr(graphNameOrDefault,varName)
	String graphNameOrDefault, varName

	SVAR/Z sv=$WMPolarGraphDFVar(graphNameOrDefault,varName)
	if( SVAR_Exists(sv) )
		return sv
	else
		return ""
	endif
End

Function/S WMPolarGraphGetStrOrDefault(graphNameOrDefault,varName, defaultStr)
	String graphNameOrDefault, varName, defaultStr

	SVAR/Z sv=$WMPolarGraphDFVar(graphNameOrDefault,varName)
	if( SVAR_Exists(sv) )
		return sv
	else
		return defaultStr
	endif
End


// Polar Legend added for Igor 6.21

Function/S WMPolarLegendMenu()

	String menuText=""	// disappearing "Polar Graph Legend..."
	if( WMPolarGraphDFExists("") )
		menuText= "Polar Graph Legend..."
	endif
	return menuText
End

Function AddOrUpdatePolarGraphLegend()

	String polarGraphName = WMPolarTopPolarGraph()
	if( strlen(polarGraphName) )
		Variable showAngle, showPaths		// 0 = no, 1 = yes
		GetLegendParams(polarGraphName, showAngle, showPaths)

		showAngle = 2 - showAngle	// 2 = no, 1 = yes,
		showPaths = 2 - showPaths
		Prompt showAngle, "Include Angle Wave (if any):",popup, "Yes;No;"
		Prompt showPaths, "Full Path to Wave:",popup, "Yes;No;"
		DoPrompt "Polar Graph Legend", showAngle, showPaths
		if( V_Flag == 0 )	// Continue clicked
			WMPolarUpdateLegend(polarGraphName, 1, showAngle=(showAngle==1), showPaths=(showPaths==1))
		endif
	endif
End

static Function GetLegendParams(polarGraphName, showAngle, showPaths)
	String polarGraphName
	Variable &showAngle	// output
	Variable &showPaths	// output
	
	if( strlen(polarGraphName) == 0 )
		return 0
	endif
	String path= WMPolarGraphDFVar(polarGraphName,"legendShowAngle")
	Variable haveParams= strlen(path)	// 0 if not a polar graph
	if( haveParams )
		showAngle=  WMPolarGraphGetVar(polarGraphName,"legendShowAngle")
		if( numtype(showAngle) != 0 )
			showAngle= 1	// default is to show the angle, if there is one.
		endif
		showPaths=  WMPolarGraphGetVar(polarGraphName,"legendShowPaths")
		if( numtype(showPaths) != 0 )
			showPaths= 0	// default is to only the wave's name, not the full path.
		endif
	endif
	return haveParams	
End

static Function SetLegendParams(polarGraphName, showAngle, showPaths)
	String polarGraphName
	Variable showAngle
	Variable showPaths
	
	if( strlen(polarGraphName) == 0 )
		return 0
	endif
	String path= WMPolarGraphDFVar(polarGraphName,"legendShowAngle")
	Variable isPolarGraph= strlen(path)	// 0 if not a polar graph
	if( isPolarGraph )
		Variable/G $path = showAngle
		path= WMPolarGraphDFVar(polarGraphName,"legendShowPaths")
		Variable/G $path = showPaths
	endif
	return isPolarGraph	
End

// Added for Igor 6.21
// Returns name of the legend in the named graph that is displaying the polar graph legend
Function/S WMPolarUpdateLegend(polarGraphName, createIfAbsent [, showAngle, showPaths])
	String polarGraphName
	Variable createIfAbsent	// if 0, the legend is update only if it already exists.
	Variable showAngle	// optional, set to 1 to list the angle wave as "vs <angle wave>" rather than just the radius wave.
	Variable showPaths	// optional, set to 1 to show the full path to the waves rather than just the names.
	
	if( strlen(polarGraphName) == 0 )
		return ""
	endif
	WAVE/T/Z tw= $WMPolarGraphTracesTW(polarGraphName)	
	String legendName= ""
	if( WaveExists(tw) )	// it truly is a polar graph
		Variable defaultShowAngle, defaultShowPaths
		GetLegendParams(polarGraphName, defaultShowAngle, defaultShowPaths)
		if( ParamIsDefault(showAngle) )
			showAngle=  defaultShowAngle
		endif
		String path=WMPolarGraphDFVar(polarGraphName,"legendShowAngle")
		Variable/G $path = showAngle

		if( ParamIsDefault(showPaths) )
			showPaths=  defaultShowPaths
		endif
		SetLegendParams(polarGraphName, showAngle, showPaths)
		
		legendName= "PolarGraphLegend"	// fixed name for now.
		String annotations= AnnotationList(polarGraphName)
		Variable legendExists= WhichListItem(legendName,annotations) >= 0
		if( createIfAbsent || legendExists )
			String text=""
			String traces= TraceNameList(polarGraphName,";",1+4) // traces showing in the polar graph (omit hidden traces)
			Variable i,n= ItemsInList(traces)
			for( i=0; i<n; i+=1 )
				String trace= StringFromList(i,traces)
				if( CmpStr(trace,"polarAutoscaleTrace") == 0 )
					continue
				endif
				WAVE w= TraceNameToWaveRef(polarGraphName,trace) 
				Variable row= WMPolarShadowWaveRow(w)
				if( row != -1 )		// this polar graph wave was found in polarTracesTW
					String radius= tw[row][kRadiusWavePath]
					String angle= tw[row][kAngleWavePath]
					if( !showPaths ) // names only
						radius= ParseFilePath(0,radius,":",1,0)
						angle= ParseFilePath(0,angle,":",1,0)	// can be "_calculated_"
					endif
					// 	Textbox/C/N=PolarGraphLegend "\\s(polarY0) polarY0\r\\s(polarAutoscaleTrace) polarAutoscaleTrace\r\\s(polarY1) polarY1\r\\s(polarY2) polarY2\r\\s(polarY3) polarY3"
					String item= "\\s("+trace+") "+radius
					if( CmpStr(angle,"_calculated_") != 0 && showAngle )
						item += " vs "+angle
					endif
					if( strlen(text) )
						text += "\r"
					endif
					text += item
				endif
			endfor
			
			if( strlen(text) )
				Textbox/W=$polarGraphName/N=$legendName/C/V=1 text	// show
			else
				Textbox/W=$polarGraphName/N=$legendName/C/V=0	// hide
			endif
		endif
	endif
	return legendName
End

// Error Bars Trace general settings

// returns path to tw wave's data folder if it does.
// returns "" if the named polar trace doesn't exist in the graph
//
// General Error Bars Settings:
//	Constant kErrorBarsCapThickness= 16			// "1.0" (points)
//	Constant kErrorBarsBarThickness= 17			// "1.0" (points)
//	Constant kErrorBarsColorFromTraceRadio = 18	//	"0" = from Trace not checked,  and Color checked, "1" = from Trace checked and Color unchecked
//	Constant kErrorBarsColorRedGreenBlue = 19	// Red, green, blue values, separated by commas, normally 0,0,0 (black)
Function/S WMPolarGetTraceErrorBars(graphName,polarTraceName,errorBarsCapThickness,errorBarsBarThickness,colorFromTraceRadio,errorBarsColorsString)
	String graphName			// input
	String &polarTraceName		//input/output: polarTraceName is the name of the shadow wave displayed in graphName; any " [radiusWaveName]" is removed.
	Variable &errorBarsCapThickness	// output
	Variable &errorBarsBarThickness	// output
	Variable &colorFromTraceRadio		// output, 0 = from Trace not checked,  and Color checked, "1" = from Trace checked and Color unchecked
	String &errorBarsColorsString		// output, "0,0,0" is black
	
	errorBarsBarThickness= 1.0
	errorBarsCapThickness= 1.0

	String path= ""
	WAVE/Z/T tw= $WMPolarGraphTracesTW(graphName)
	
	if( WaveExists(tw) )		// this describes the graph's traces
	 	polarTraceName= WMPolarOnlyTraceName(polarTraceName)	// changes the input parameter!!!!
		WAVE/Z wShadowY= TraceNameToWaveRef(graphName,polarTraceName)	// the trace actually exists
		if( WaveExists(wShadowY) )
			Variable row= WMPolarShadowWaveRow(wShadowY)
			if( row != -1 )		// this wave was found in polarTracesTW
				WMPolarModernizePolarTracesWave(tw)
				errorBarsCapThickness= str2num(tw[row][kErrorBarsCapThickness])
				errorBarsBarThickness= str2num(tw[row][kErrorBarsBarThickness])
				colorFromTraceRadio= str2num(tw[row][kErrorBarsColorFromTraceRadio])
				errorBarsColorsString= tw[row][kErrorBarsColorRedGreenBlue]

				path= GetWavesDataFolder(tw,1)
			endif
		endif
	endif

	return path
End

// returns "" if the named polar trace doesn't exist in the graph
// returns path to tw wave's data folder if it does.
//
// General Error Bars Settings:
//	Constant kErrorBarsCapThickness= 16			// "1.0" (points)
//	Constant kErrorBarsBarThickness= 17			// "1.0" (points)
//	Constant kErrorBarsColorFromTraceRadio = 18	//	"0" = from Trace not checked,  and Color checked, "1" = from Trace checked and Color unchecked
// Constant kErrorBarsColorRedGreenBlue = 19	// Red, green, blue values, with optional opaque value separated by commas, normally 0,0,0,65535 (black[, opaque])
Function/S WMPolarSetTraceErrorBars(graphName,polarTraceName,errorBarsCapThickness,errorBarsBarThickness,colorFromTraceRadio,errorBarsColorsString)
	String graphName			// input
	String &polarTraceName		// input/output: polarTraceName is the name of the shadow wave displayed in graphName; any " [radiusWaveName]" is removed.
	Variable errorBarsCapThickness	// input
	Variable errorBarsBarThickness	// input
	Variable colorFromTraceRadio	// input
	String errorBarsColorsString	// input, r,g,b with optional ,alpha

	String path= ""

	WAVE/Z/T tw= $WMPolarGraphTracesTW(graphName)
	if( WaveExists(tw) )		// this describes the graph's traces
		polarTraceName= WMPolarOnlyTraceName(polarTraceName)	// changes the input parameter!!!!
		WAVE/Z wShadowY= TraceNameToWaveRef(graphName,polarTraceName)
		if( WaveExists(wShadowY) )
			Variable row= WMPolarShadowWaveRow(wShadowY)
			if( row != -1 )		// this wave was found in polarTracesTW
				WMPolarModernizePolarTracesWave(tw)

				tw[row][kErrorBarsCapThickness]= num2str(errorBarsCapThickness)
				tw[row][kErrorBarsBarThickness]= num2str(errorBarsBarThickness)
				
				tw[row][kErrorBarsColorFromTraceRadio]= num2str(colorFromTraceRadio)
				tw[row][kErrorBarsColorRedGreenBlue]= errorBarsColorsString

				path= GetWavesDataFolder(tw,1)
			endif
		endif
	endif

	return path
End

// returns "" if the named polar trace doesn't exist in the graph
// returns path to tw wave's data folder if it does.
//
// Radius Error Bars Settings:
//	Constant kRadiusErrorsBarsX = 21			// name of radius error bars X wave, polarRadiusErrorBarX0, etc
//	Constant kRadiusErrorsBarsY = 22			// name of radius error bars Y wave, polarRadiusErrorBarY0, etc
//	Constant kRadiusErrorsBarsMrkZ = 23		// name of radius error bars markers f(Z) wave, polarRadiusErrorBarZ0, etc
//	Constant kRadiusErrorBarsMode= 24		// None;% of radius;sqrt of radius;+constant;+/-constant;+/- wave;
//	StrConstant ksRadiusErrorBarsModes= "None;% of radius;sqrt of radius;+ constant;+/- constant;+/- wave;"
//	Constant kRadiusErrorBarsPercent=25			// 0-1000
//	Constant kRadiusErrorBarsConstant=26			// -inf - +inf if +constant, 0 - +inf if +/- constant (or just take abs if +/- constant)
//	Constant kRadiusErrorBarsPlusWavePath=27	// full data folder path to +wave or "_none_"
//	Constant kRadiusErrorBarsMinusWavePath=28	// full data folder path to -wave or "_none_" (there is no "same as Y+" feature)
//	Constant kRadiusErrorBarsCapWidth= 29		// ("Auto" else points, this is just the cap marker size, and must be kept up-to-date with msize)
Function/S WMPolarGetTraceRadiusErrorBars(graphName,polarTraceName,radiusErrorBarsX,radiusErrorBarsY,radiusErrorBarsMrkZ,radiusErrorBarsMode,radiusErrorBarsPercent,radiusErrorBarsConstant,radiusErrorBarsPlusWavePath,radiusErrorBarsMinusWavePath,radiusErrorBarsCapWidthStr)
	String graphName			// input
	String &polarTraceName		// input/output: polarTraceName is the name of the shadow wave displayed in graphName; any " [radiusWaveName]" is removed.
	String &radiusErrorBarsX,&radiusErrorBarsY,&radiusErrorBarsMrkZ	// outputs
	String &radiusErrorBarsMode	// output
	Variable &radiusErrorBarsPercent	// output
	Variable &radiusErrorBarsConstant	// output
	String &radiusErrorBarsPlusWavePath	// output
	String &radiusErrorBarsMinusWavePath	// output
	String &radiusErrorBarsCapWidthStr	// output ("Auto" else degrees)

	// defaults
	radiusErrorBarsX= ""
	radiusErrorBarsY= ""
	radiusErrorBarsMrkZ= ""
	radiusErrorBarsMode= "None"
	radiusErrorBarsPercent= 5.0
	radiusErrorBarsConstant= 0	
	radiusErrorBarsPlusWavePath=""
	radiusErrorBarsMinusWavePath=""
	radiusErrorBarsCapWidthStr= "Auto"

	String path= ""
	WAVE/Z/T tw= $WMPolarGraphTracesTW(graphName)
	
	if( WaveExists(tw) )		// this describes the graph's traces
	 	polarTraceName= WMPolarOnlyTraceName(polarTraceName)	// changes the input parameter!!!!
		WAVE/Z wShadowY= TraceNameToWaveRef(graphName,polarTraceName)	// the trace actually exists
		if( WaveExists(wShadowY) )
			Variable row= WMPolarShadowWaveRow(wShadowY)
			if( row != -1 )		// this wave was found in polarTracesTW
				WMPolarModernizePolarTracesWave(tw)
				radiusErrorBarsX= tw[row][kRadiusErrorsBarsX]
				radiusErrorBarsY= tw[row][kRadiusErrorsBarsY]
				radiusErrorBarsMrkZ= tw[row][kRadiusErrorsBarsMrkZ]
				
				radiusErrorBarsMode= tw[row][kRadiusErrorBarsMode]
				radiusErrorBarsPercent= str2num(tw[row][kRadiusErrorBarsPercent])
				radiusErrorBarsConstant= str2num(tw[row][kRadiusErrorBarsConstant])
				radiusErrorBarsPlusWavePath= tw[row][kRadiusErrorBarsPlusWavePath]
				radiusErrorBarsMinusWavePath= tw[row][kRadiusErrorBarsMinusWavePath]
				radiusErrorBarsCapWidthStr= tw[row][kRadiusErrorBarsCapWidth]	// // ("Auto" else points)

				path= GetWavesDataFolder(tw,1)
			endif
		endif
	endif

	return path
End

// returns "" if the named polar trace doesn't exist in the graph
// returns path to tw wave's data folder if it does.
//
// Radius Error Bars Settings:
//	Constant kRadiusErrorsBarsX = 21			// name of radius error bars X wave, polarRadiusErrorBarX0, etc
//	Constant kRadiusErrorsBarsY = 22			// name of radius error bars Y wave, polarRadiusErrorBarY0, etc
//	Constant kRadiusErrorsBarsMrkZ = 23		// name of radius error bars markers f(Z) wave, polarRadiusErrorBarZ0, etc
//	Constant kRadiusErrorBarsMode= 24		// None;% of radius;sqrt of radius;+constant;+/-constant;+/- wave;
//	StrConstant ksRadiusErrorBarsModes= "None;% of radius;sqrt of radius;+ constant;+/- constant;+/- wave;"
//	Constant kRadiusErrorBarsPercent=25			// 0-1000
//	Constant kRadiusErrorBarsConstant=26			// -inf - +inf if +constant, 0 - +inf if +/- constant (or just take abs if +/- constant)
//	Constant kRadiusErrorBarsPlusWavePath=27	// full data folder path to +wave or "_none_"
//	Constant kRadiusErrorBarsMinusWavePath=28	// full data folder path to -wave or "_none_" (there is no "same as Y+" feature)
//	Constant kRadiusErrorBarsCapWidth= 29		// ("Auto" else points, this is just the cap marker size, and must be kept up-to-date with msize)
Function/S WMPolarSetTraceRadiusErrorBars(graphName,polarTraceName,radiusErrorBarsX,radiusErrorBarsY,radiusErrorBarsMrkZ,radiusErrorBarsMode,radiusErrorBarsPercent,radiusErrorBarsConstant,radiusErrorBarsPlusWavePath,radiusErrorBarsMinusWavePath,radiusErrorBarsCapWidthStr)
	String graphName			// input
	String &polarTraceName		//input/output: polarTraceName is the name of the shadow wave displayed in graphName; any " [radiusWaveName]" is removed.
	String radiusErrorBarsX,radiusErrorBarsY,radiusErrorBarsMrkZ	// inputs
	String radiusErrorBarsMode	// input
	Variable radiusErrorBarsPercent	// input
	Variable radiusErrorBarsConstant	// input
	String radiusErrorBarsPlusWavePath	// input
	String radiusErrorBarsMinusWavePath	// input
	String radiusErrorBarsCapWidthStr	// input

	String path= ""

	WAVE/Z/T tw= $WMPolarGraphTracesTW(graphName)
	if( WaveExists(tw) )		// this describes the graph's traces
		polarTraceName= WMPolarOnlyTraceName(polarTraceName)	// changes the input parameter!!!!
		WAVE/Z wShadowY= TraceNameToWaveRef(graphName,polarTraceName)
		if( WaveExists(wShadowY) )
			Variable row= WMPolarShadowWaveRow(wShadowY)
			if( row != -1 )		// this wave was found in polarTracesTW
				WMPolarModernizePolarTracesWave(tw)

				tw[row][kRadiusErrorsBarsX]= radiusErrorBarsX
				tw[row][kRadiusErrorsBarsY]= radiusErrorBarsY
				tw[row][kRadiusErrorsBarsMrkZ]= radiusErrorBarsMrkZ

				tw[row][kRadiusErrorBarsMode]= radiusErrorBarsMode
				tw[row][kRadiusErrorBarsPercent]= num2str(radiusErrorBarsPercent)
				tw[row][kRadiusErrorBarsConstant]= num2str(radiusErrorBarsConstant)
				tw[row][kRadiusErrorBarsPlusWavePath]= radiusErrorBarsPlusWavePath
				tw[row][kRadiusErrorBarsMinusWavePath]= radiusErrorBarsMinusWavePath
				tw[row][kRadiusErrorBarsCapWidth]= radiusErrorBarsCapWidthStr	// ("Auto" else points)

				path= GetWavesDataFolder(tw,1)
			endif
		endif
	endif

	return path
End

// Compare to WMPolarUpdateFillToOrigin() and WMPolarModifyFillToOrigin()

//	// Error Bars (generally)
//	Constant kErrorBarsCapThickness= 16			// "1.0" (points)
//	Constant kErrorBarsBarThickness= 17			// "1.0" (points)
//	Constant kErrorBarsColorFromTraceRadio = 18	//	"0" = from Trace not checked,  and Color checked, "1" = from Trace checked and Color unchecked
// Constant kErrorBarsColorRedGreenBlue = 19	// Red, green, blue values, with optional opaque value separated by commas, normally 0,0,0,65535 (black[, opaque])

// Error Bars (radius)
//	Constant kRadiusErrorBarMinMaxStr= 20		// record the x,y range of the radius error bars
//	Constant kRadiusErrorsBarsX = 21			// name of radius error bars X wave, polarRadiusErrorBarX0, etc
//	Constant kRadiusErrorsBarsY = 22			// name of radius error bars Y wave, polarRadiusErrorBarY0, etc
//	Constant kRadiusErrorsBarsMrkZ = 23		// name of radius error bars markers f(Z) wave, polarRadiusErrorBarZ0, etc
//	Constant kRadiusErrorBarsMode= 24		// None;% of radius;sqrt of radius;+constant;+/-constant;+/- wave;
//	StrConstant ksRadiusErrorBarsModes= "None;% of radius;sqrt of radius;+ constant;+/- constant;+/- wave;"
//	Constant kRadiusErrorBarsPercent=25			// 0-1000
//	Constant kRadiusErrorBarsConstant=26			// -inf - +inf if +constant, 0 - +inf if +/- constant (or just take abs if +/- constant)
//	Constant kRadiusErrorBarsPlusWavePath=27	// full data folder path to +wave or "_none_"
//	Constant kRadiusErrorBarsMinusWavePath=28	// full data folder path to -wave or "_none_" (there is no "same as Y+" feature)
//	Constant kRadiusErrorBarsCapWidth= 29		// ("Auto" else points, this is just the cap marker size, and must be kept up-to-date with msize)

Function WMPolarUpdateRadiusErrorBars(graphName, wShadowX, wShadowY, df, tw, row)
	String graphName
	Wave wShadowX, wShadowY
	String df
	Wave/T tw
	Variable row
	
	String radiusPath=tw[row][kRadiusWavePath]
	String anglePath=tw[row][kAngleWavePath]
	Variable angleIsRadians= CmpStr(tw[row][kAngleUnits],"radians")==0
	String plusErrorsPath= tw[row][kRadiusErrorBarsPlusWavePath]
	String minusErrorsPath= tw[row][kRadiusErrorBarsMinusWavePath]

	Variable radiusErrorBarsPercent= str2num(tw[row][kRadiusErrorBarsPercent])
	Variable radiusErrorBarsConstant= str2num(tw[row][kRadiusErrorBarsConstant])
	Variable deltaRadiusPlus=0, deltaRadiusMinus=0
	
	Variable drawNegativeErrorBars= 0
	String radiusErrorBarsMode= tw[row][kRadiusErrorBarsMode]

	strswitch(radiusErrorBarsMode)
		case "sqrt of radius":	// perhaps we need + sqrt of radius, and +/- sqrt of radius
		case "% of radius":		// perhaps we need + % of radius, and +/- % of radius
			drawNegativeErrorBars= 1	// for now we do just what regular traces do.
			break
		case "+/- constant":
			drawNegativeErrorBars= 1
			deltaRadiusMinus= radiusErrorBarsConstant	// subtract this from radius
			// FALL THROUGH
		case "+ constant":
			deltaRadiusPlus= radiusErrorBarsConstant	// add this to radius
			break
		case "+/- wave":
			WAVE/Z wPlusErrors= $plusErrorsPath
			WAVE/Z wMinusErrors= $minusErrorsPath
			if( WaveExists(wMinusErrors) )
				drawNegativeErrorBars= 1
			elseif( !WaveExists(WPlusErrors) )
				// the user might not have selected any waves yet
				return 0
			endif
			break
		default:
			Print "Bug in WMPolarUpdateRadiusErrorBars()!"; Beep
			// FALL THROUGH
		case "None":
			return 0
			break
	endswitch
	
	WAVE/Z radiusData= $radiusPath
	if( !WaveExists(radiusData) )
		Print "Missing radiusData!"
		return 0
	endif
	WAVE/Z angleData= $anglePath	// optional

	String radiusErrorBarsCapWidthStr = tw[row][kRadiusErrorBarsCapWidth]
	Variable capWidthPoints= WMPolarCapWidthPoints(radiusErrorBarsCapWidthStr)

	Variable pointsPerErrorBar= 3	// both ends of the error bar, followed by (NaN,NaN)
	Variable n= numpnts(wShadowY)	// will be same as angle data or radius data
	Variable pointsForErrorBarWaves= n * pointsPerErrorBar
	
	String radiusErrorBarXWavePath= df+tw[row][kRadiusErrorsBarsX]	// polarRadiusErrorBarX0, etc
	String radiusErrorBarYWavePath= df+tw[row][kRadiusErrorsBarsY]	// polarRadiusErrorBarY0, etc
	String radiusErrorBarZWavePath= df+tw[row][kRadiusErrorsBarsMrkZ]	// polarRadiusErrorBarZ0, etc
	
	Make/O/D/N=(pointsForErrorBarWaves) $radiusErrorBarXWavePath/WAVE=wRadiusBarsX
	Make/O/D/N=(pointsForErrorBarWaves) $radiusErrorBarYWavePath/WAVE=wRadiusBarsY
	Make/O/D/N=(pointsForErrorBarWaves) $radiusErrorBarZWavePath/WAVE=wRadiusBarsZ

	if( drawNegativeErrorBars )
		wRadiusBarsZ= mod(p,3) == 2 ? NaN	: kPolarCapMarkerNumber// all visible points have caps
	else	
		// Only positive error bars, don't put a marker at the radius value, only on the +error bar.
		// first of 3 x,y points is the radius value, which has no cap (NaN).
		//  The other end of the bar has a cap, and the (NaN,NaN) point doesn't care what the marker # is.
		wRadiusBarsZ= mod(p,3) == 1 ? kPolarCapMarkerNumber : NaN
	endif
	
	Variable seg, pt, bp= 0
	Variable radiusErrorMin= inf, radiusErrorMax= -inf
	for(pt=0; pt<n; pt+=1 )
		Variable dataRadius= radiusData[pt]
		Variable dataAngle
		if( WaveExists(angleData) )
			dataAngle= angleData[pt]
		else
			dataAngle= pnt2x(radiusData,pt)
		endif

		// per-point radius errors
		strswitch(radiusErrorBarsMode)
			case "sqrt of radius":	// perhaps we need + sqrt of radius, and +/- sqrt of radius
				deltaRadiusMinus= sqrt(abs(dataRadius))	// (yes, radius can be negative) subtracted from radius
				deltaRadiusPlus= deltaRadiusMinus			// added to radius
				break
			case "% of radius":		// perhaps we need + % of radius, and +/- % of radius
				deltaRadiusMinus= dataRadius * radiusErrorBarsPercent / 100	// subtracted from radius
				deltaRadiusPlus= deltaRadiusMinus			// added to radius
				break
			case "+/- wave":
				if( WaveExists(wMinusErrors) )
					deltaRadiusMinus= wMinusErrors[pt]	// subtracted from radius
				endif
				if( WaveExists(wPlusErrors) )
					deltaRadiusPlus= wPlusErrors[pt]	// added to radius
				endif
				break
		endswitch
		
		Variable errorRadiusPlus= dataRadius + deltaRadiusPlus
		if( errorRadiusPlus < radiusErrorMin )
			radiusErrorMin = errorRadiusPlus
		endif
		if( errorRadiusPlus > radiusErrorMax )
			radiusErrorMax = errorRadiusPlus
		endif
		
		Variable drawnX, drawnY	// convert data +/- error bars to same coordinate space as shadowX and shadowY using WMPolarRadiusAngleToDrawnXY
		
		Variable errorRadiusMinus= dataRadius - deltaRadiusMinus

		if( errorRadiusMinus < radiusErrorMin )
			radiusErrorMin = errorRadiusMinus
		endif
		if( errorRadiusMinus > radiusErrorMax )
			radiusErrorMax = errorRadiusMinus
		endif

		// BAR is from radius-errorMinus to radius+errorPlus (errorMinus is zero if we're not drawing negative error bars)

		// (wRadiusBarsX[0], wRadiusBarsY[0])  = (shadowX - deltaRadius * cos(drawnAngle[i]) , shadowY - deltaRadius * sin(drawnAngle[i]) )
		WMPolarRadiusAngleToDrawnXY(tw, row, errorRadiusMinus, dataAngle, drawnX, drawnY)
		wRadiusBarsX[bp+0]= drawnX
		wRadiusBarsY[bp+0]= drawnY

		// [1] = (shadowX + deltaRadius * cos(drawnAngle[i]) , shadowY + deltaRadius * sin(drawnAngle[i]) )
		WMPolarRadiusAngleToDrawnXY(tw, row, errorRadiusPlus, dataAngle, drawnX, drawnY)
		wRadiusBarsX[bp+1]= drawnX
		wRadiusBarsY[bp+1]= drawnY

		// [2] = (NaN , NaN) to provide a gap
		wRadiusBarsX[bp+2]= NaN
		wRadiusBarsY[bp+2]= NaN
		
		bp += pointsPerErrorBar
	endfor
	
	// record radii extent for WMPolarSetRadiusMinsMaxes()
	String minMaxStr
	sprintf minMaxStr, "%.14g,%.14g", radiusErrorMin, radiusErrorMax
	tw[row][kRadiusErrorBarMinMaxStr]= minMaxStr
	String pathToTW = GetWavesDataFolder(tw,2)
	WMPolarSetRadiusMinsMaxes(pathToTW,radiusData,radiusYWave=wRadiusBarsY)
	return 1
End

// Error Bars (angle)
//	Constant kAngleErrorBarMinMaxStr= 30	// record the x,y range of the angle error bars
//	Constant kAngleErrorsBarsX = 31			// name of angle error bars X wave, polarAngleErrorBarX0, etc
//	Constant kAngleErrorsBarsY = 32			// name of angle error bars Y wave, polarAngleErrorBarY0, etc
//	Constant kAngleErrorsBarsMrkZ = 33		// name of angle error bars markers f(Z) wave, polarAngleErrorBarZ0, etc
//	Constant kAngleErrorBarsMode= 34			// None;% of Angle;sqrt of Angle;+constant;+/-constant;+/- wave;
//	StrConstant ksAngleErrorBarsModes= "None;% of angle;sqrt of angle;+ constant;+/- constant;+/- wave;"
//	Constant kAngleErrorBarsPercent=35			// 0-1000
//	Constant kAngleErrorBarsConstant=36			// -inf - +inf if +constant, 0 - +inf if +/- constant (or just take abs if +/- constant)
//	Constant kAngleErrorBarsPlusWavePath=37	// full data folder path to +wave or "_none_"
//	Constant kAngleErrorBarsMinusWavePath=38	// full data folder path to -wave or "_none_" (there is no "same as Y+" feature)
//	Constant kAngleErrorBarsCapWidth= 39		// ("Auto" else points, this is just the cap marker size, and must be kept up-to-date with msize)
//	
//	Constant kTWColumns=40				// 0..39 (Igor 7 added Angle Error Bars)


Function WMPolarUpdateAngleErrorBars(graphName, wShadowX, wShadowY, df, tw, row)
	String graphName
	Wave wShadowX, wShadowY
	String df
	Wave/T tw
	Variable row

	String radiusPath=tw[row][kRadiusWavePath]
	String anglePath=tw[row][kAngleWavePath]
	Variable angleIsRadians= CmpStr(tw[row][kAngleUnits],"radians")==0

	String plusErrorsPath= tw[row][kAngleErrorBarsPlusWavePath]
	String minusErrorsPath= tw[row][kAngleErrorBarsMinusWavePath]

	Variable angleErrorBarsPercent= str2num(tw[row][kAngleErrorBarsPercent])
	Variable angleErrorBarsConstant= str2num(tw[row][kAngleErrorBarsConstant]) // degrees!
	Variable deltaAnglePlus=0, deltaAngleMinus=0
	
	Variable drawNegativeErrorBars= 0
	String angleErrorBarsMode= tw[row][kAngleErrorBarsMode]

	strswitch(angleErrorBarsMode)
		case "sqrt of angle":	
		case "% of angle":
			drawNegativeErrorBars= 1
			break
		case "+/- constant":
			drawNegativeErrorBars= 1
			deltaAngleMinus= angleErrorBarsConstant	// subtract this from angle
			// FALL THROUGH
		case "+ constant":
			deltaAnglePlus= angleErrorBarsConstant	// add this to angle
			break
		case "+/- wave":
			WAVE/Z wPlusErrors= $plusErrorsPath
			WAVE/Z wMinusErrors= $minusErrorsPath
			if( WaveExists(wMinusErrors) )
				drawNegativeErrorBars= 1
			elseif( !WaveExists(WPlusErrors) )
				// the user might not have selected any waves yet
				return 0
			endif
			break
		default:
			Print "Bug in WMPolarUpdateAngleErrorBars()!"; Beep
			// FALL THROUGH
		case "None":
			return 0
			break
	endswitch
	
	WAVE/Z radiusData= $radiusPath
	if( !WaveExists(radiusData) )
		Print "Missing radiusData!"
		return 0
	endif
	WAVE/Z angleData= $anglePath	// optional

	String angleErrorBarsCapWidthStr = tw[row][kAngleErrorBarsCapWidth]
	Variable capWidthPoints= WMPolarCapWidthPoints(angleErrorBarsCapWidthStr)

	// compute the number of points needed for the angle error bars.
	// Since the bars are curved, a polygon approximation must necessarily use many points for one bar.
	// maxDeltaAngle is already defined for polygon accuracy, let's use some function of that.
	Variable n= numpnts(wShadowY)	// will be same as angle data or radius data
	
	// for each angle error bar, we need at least 3 points, all at constant radiusData[i].
	// in (Radius, Angle) nomenclature, where R = radiusData[i] and A = dataAngle[i],
	// point 0:		(R,A - errorAngle) // if double-sided error bars
	// point 0/1:	(R,A)
	// point 1/2:	(R,A + errorAngle)
	// point 2/3:	(NaN, NaN)	// gap to skip to next angle error bar
	Variable minPointsPerErrorBar = drawNegativeErrorBars ? 4 : 3

	Variable anglePerCircle= angleIsRadians ? 2 * pi	: 360
	Variable angleToDegrees= angleIsRadians ? 180 / pi : 1	
	Variable maxDeltaAngle = 1	// degrees

	Variable pt, dataAngle, dataDegrees
	Variable pointsForErrorBarWaves= 0, pointsForThisErrorBar, additionalPointsForAngle, minusPts

	// compute total number of needed points.
	// Store the length of each error bar in this free wave
	Make/O/N=(n,4)/FREE barInfo=0
//	Make/O/N=(n,4) barInfo=0
	// barInfo[pt][0] = total number of x,y points for the bar, including the trailing NaN,NaN xy pair.
	// barInfo[pt][1] = additional number of x,y points for deltaAngleMinus bar.
	// barInfo[pt][2] = deltaAngleMinus (degrees)
	// barInfo[pt][3] = deltaAnglePlus (degrees)
	SetDimLabel 1, 0, points, barInfo
	SetDimLabel 1, 1, minusPoints, barInfo
	SetDimLabel 1, 2, deltaAngleMinus, barInfo
	SetDimLabel 1, 3, deltaAnglePlus, barInfo
	
	for(pt=0; pt<n; pt+=1)
		if( WaveExists(angleData) )
			dataAngle= angleData[pt]
		else
			dataAngle= pnt2x(radiusData,pt)
		endif
		dataDegrees= dataAngle * angleToDegrees

		// compute the number of points needed for this angle error bar
		strswitch(angleErrorBarsMode)
			case "sqrt of angle":	
				deltaAngleMinus= sqrt(abs(dataDegrees))	// degrees subtracted from angle
				deltaAnglePlus= deltaAngleMinus			// added to angle
				break
			case "% of angle":
				deltaAngleMinus= dataDegrees * angleErrorBarsPercent / 100	// degrees subtracted from angle
				deltaAnglePlus= deltaAngleMinus			// added to angle
				break
			case "+/- wave": // degrees
				if( WaveExists(wMinusErrors) )
					deltaAngleMinus= wMinusErrors[pt]	// degrees subtracted from angle
				endif
				if( WaveExists(wPlusErrors) )
					deltaAnglePlus= wPlusErrors[pt]	// added to angle
				endif
		endswitch
		barInfo[pt][%deltaAngleMinus]= deltaAngleMinus
		barInfo[pt][%deltaAnglePlus]= deltaAnglePlus

		// Additional points between (R,A) and (R,A +/- errorAngle) can be added to make the curved bar "curvy".
		// Suppose we decide that we need a certain number of points to describe an arc of angle = errorAngle
		// based on maxDeltaAngle.
		// If maxDeltaAngle is, say, 3 (degrees), and the error is 6 degrees,
		// we'd have one additional point on each side so that each segment spans 3 degrees.
		additionalPointsForAngle = limit(round(abs(deltaAnglePlus/maxDeltaAngle)),1,360) - 1
		// if errors are double-sided, then we have two additional points for that angle error bar
		if( drawNegativeErrorBars )
			minusPts= limit(round(abs(deltaAngleMinus/maxDeltaAngle)),1,360) - 1
			barInfo[pt][%minusPoints] = minusPts
			additionalPointsForAngle += minusPts
		endif
		pointsForThisErrorBar = minPointsPerErrorBar + additionalPointsForAngle
		barInfo[pt][%points] = pointsForThisErrorBar
		pointsForErrorBarWaves += pointsForThisErrorBar
	endfor

	String angleErrorBarXWavePath= df+tw[row][kAngleErrorsBarsX]	// polarAngleErrorBarX0, etc
	String angleErrorBarYWavePath= df+tw[row][kAngleErrorsBarsY]	// polarAngleErrorBarY0, etc
	String angleErrorBarZWavePath= df+tw[row][kAngleErrorsBarsMrkZ]	// polarAngleErrorBarZ0, etc
	
	Make/O/D/N=(pointsForErrorBarWaves) $angleErrorBarXWavePath/WAVE=wAngleBarsX
	Make/O/D/N=(pointsForErrorBarWaves) $angleErrorBarYWavePath/WAVE=wAngleBarsY
	Make/O/D/N=(pointsForErrorBarWaves) $angleErrorBarZWavePath/WAVE=wAngleBarsZ

	Variable lastPt, bp= 0 // indexes into X,Y,Z waves
	for(pt=0; pt<n; pt+=1) // index into radius,angle,shadowX,shadowY waves
		Variable dataRadius= radiusData[pt]
		if( WaveExists(angleData) )
			dataAngle= angleData[pt]
		else
			dataAngle= pnt2x(radiusData,pt)
		endif
		dataDegrees= dataAngle * angleToDegrees

		pointsForThisErrorBar= barInfo[pt][%points]
		minusPts= barInfo[pt][%minusPoints]
		
		lastPt= bp+pointsForThisErrorBar-1
		// add NaN, NaN	separator
		wAngleBarsX[lastPt] = NaN
		wAngleBarsY[lastPt] = NaN
		wAngleBarsZ[lastPt] = NaN

		deltaAngleMinus= barInfo[pt][%deltaAngleMinus] 
		deltaAnglePlus= barInfo[pt][%deltaAnglePlus]

		Variable drawnX, drawnY	// convert data +/- error bars to same coordinate space as shadowX and shadowY using WMPolarRadiusAngleToDrawnXY

		// for each angle error bar, we need at least 3 points, all at constant radiusData[i].
		// in (Radius, Angle) nomenclature, where R = radiusData[i] and A = dataAngle[i],
		// point 0:		(R,A - deltaAngleMinus) // if double-sided error bars
		// point 0/1:	(R,A)
		// point 1/2:	(R,A + deltaAnglePlus)
		// point 2/3:	(NaN, NaN)	// gap to skip to next angle error bar
		Variable j, angle, da // angles in data units
		Variable bpi= bp
		if( drawNegativeErrorBars )
			// add initial negative bar coordinate as first point
			angle = (dataDegrees - deltaAngleMinus) / angleToDegrees
			WMPolarRadiusAngleToDrawnXY(tw, row, dataRadius, angle, drawnX, drawnY)
			wAngleBarsX[bpi] = drawnX
			wAngleBarsY[bpi] = drawnY
			wAngleBarsZ[bpi] = kPolarAngleCapMarkerNumber
			bpi += 1
			if( minusPts )
				da = (deltaAngleMinus/angleToDegrees) / (minusPts+1) // increment in data angle units
				for( j=0; j< minusPts; j+=1 )
					// additional minus points between (R,A-deltaAngleMinus) and (R,A) but not including ends
					angle += da
					WMPolarRadiusAngleToDrawnXY(tw, row, dataRadius, angle, drawnX, drawnY)
					wAngleBarsX[bpi] = drawnX
					wAngleBarsY[bpi] = drawnY
					wAngleBarsZ[bpi] = NaN // no marker
					bpi += 1
				endfor
			endif
			bp += 1 + minusPts
		endif
		
		// (R,A)
		angle= dataAngle
		WMPolarRadiusAngleToDrawnXY(tw, row, dataRadius, angle, drawnX, drawnY)
		wAngleBarsX[bpi]= drawnX
		wAngleBarsY[bpi]= drawnY
		wAngleBarsZ[bpi] = NaN // no marker
		bpi += 1
		
		// positive errors (all error bars have positive errors, but optional negative errors)
		
		// if first bar is 10 pts, lastPt is 9, (R,A+error) is wAngleBarsX[8]
		// if no negative bar, bpi = 1.
		Variable finalPt= lastPt - 1
		Variable plusPts = finalPt - bpi
		if( plusPts )
			da = (deltaAnglePlus/angleToDegrees) / (plusPts+1) // increment in data angle units
			for( j=0; j< plusPts; j+=1 )
				// additional plus points between (R,A) and (R,A+deltaAnglePlus) but not including ends
				angle += da
				WMPolarRadiusAngleToDrawnXY(tw, row, dataRadius, angle, drawnX, drawnY)
				wAngleBarsX[bpi] = drawnX
				wAngleBarsY[bpi] = drawnY
				wAngleBarsZ[bpi] = NaN // no marker
				bpi += 1
			endfor
		endif
		
		// angle + deltaAnglePlus
		angle = (dataDegrees + deltaAnglePlus) / angleToDegrees
		WMPolarRadiusAngleToDrawnXY(tw, row, dataRadius, angle, drawnX, drawnY)
		wAngleBarsX[bpi] = drawnX
		wAngleBarsY[bpi] = drawnY
		wAngleBarsZ[bpi] = kPolarAngleCapMarkerNumber
		
		bp= lastPt + 1
	endfor
	
	return 1
End

Function WMPolarUpdateErrorBars(wShadowX,wShadowY)	
	Wave wShadowX,wShadowY

	Variable row= WMPolarShadowWaveRow(wShadowY)// Returns the row in the polarTracesTW text wave, or -1 if not found
	if( row != -1 )		// this wave was found in polarTracesTW
		String df= GetWavesDataFolder(wShadowY,1)	// we rely on the fact that the shadow wave and the polarTracesTW wave are in the same data folder
		String pathToTW= df+"polarTracesTW"
		WAVE/T/Z tw= $pathToTW
	
		if( WaveExists(tw) )
			WMPolarModernizePolarTracesWave(tw)

			// compare to WMPolarUpdateFillToOrigin(), but be aware that we need to follow the shadow trace's color
			String graphName= WMPolarGraphForTW(tw)

			Variable haveRadiusErrorBars= WMPolarUpdateRadiusErrorBars(graphName, wShadowX, wShadowY, df, tw, row)
			Variable haveAngleErrorBars= WMPolarUpdateAngleErrorBars(graphName, wShadowX, wShadowY, df, tw, row)
		endif	// WaveExists(tw)
	endif	// row != -1

	return row
End


Function WMPolarErrorBarCapMarker(s)
	STRUCT WMMarkerHookStruct &s

	// 2 markers supported: marker 998 for radius error bar marker, 999 for angle error bar marker
	if( s.marker < 0 || s.marker > 1 )
		return 0
	endif
	
	Variable isAngle= s.marker == 1

	Variable capCosAngle= 0, capSinAngle= 1// default is vertical marker
	
	if( s.ywIndex >= 0 )		// -1 means "no specific point", which usually means the marker is being drawn in a Legend, Textbox, or control.
		WAVE/Z errorBarY= s.ywave
		if( WaveExists(errorBarY) )
			String df= GetWavesDataFolder(errorBarY,1)	// we rely on the fact that the shadow wave and the polarTracesTW wave are in the same data folder
			WAVE/T/Z tw= $(df+"polarTracesTW")
			if( WaveExists(tw) )
				//String graphName= WMPolarGraphForTW(tw)	// debugging
				Variable row
				if( isAngle )
					row= WMPolarAngleErrorBarsWaveRow(errorBarY)	// match against tw[row][kAngleErrorsBarsY]	// polarRadiusErrorBarY0, etc
				else
					row= WMPolarRadiusErrorBarsWaveRow(errorBarY)	// match against tw[row][kRadiusErrorsBarsY]	// polarRadiusErrorBarY0, etc
				endif

				if( row != -1 )
					if( isAngle )
						WAVE/Z errorBarX= $(df+tw[row][kAngleErrorsBarsX])
					else
						WAVE/Z errorBarX= $(df+tw[row][kRadiusErrorsBarsX])
					endif
					if( WaveExists(errorBarX) )
						Variable drawnX= errorBarX[s.ywIndex]
						Variable drawnY= errorBarY[s.ywIndex]
						Variable drawnRadius= sqrt( drawnX * drawnX + drawnY * drawnY)
						Variable drawnCosAngle= drawnX/drawnRadius
						Variable drawnSinAngle= drawnY/drawnRadius
						// The drawn coordinate system's angles are atan(drawny, drawnx), 0,0 at the center, x increases to the right and y increases UP.
						// The marker coordinate system has x increasing to the right, but y increasing DOWN.
						// This reverses the sign of the angles.
						Variable markerCosAngle= drawnCosAngle
						Variable markerSinAngle= - drawnSinAngle
						
						if( isAngle )
							capCosAngle= markerCosAngle
							capSinAngle= markerSinAngle
						else
							// rotate 90 degrees
							capCosAngle= -markerSinAngle	// cos(theta+90) = -sin(theta)
							capSinAngle= markerCosAngle	// sin(theta+90) = cos(theta)
						endif
					endif
				endif
			endif
		endif
	endif
	
	Variable x0= s.x - s.size*capCosAngle
	Variable y0= s.y - s.size*capSinAngle

	Variable x1= s.x + s.size*capCosAngle
	Variable y1= s.y + s.size*capSinAngle
	
	SetDrawEnv linethick=s.penThick,linefgc=(s.penRGB.red, s.penRGB.green, s.penRGB.blue, s.penRGB.alpha)	// use stroke color, which defaults to line color
	DrawLine x0, y0, x1, y1

	return 1
End

Function WMPolarTraceHasErrorBars(graphName,polarTraceName)
	String graphName, polarTraceName // inputs

	Variable haveErrorBars= 0
 	polarTraceName= WMPolarOnlyTraceName(polarTraceName)
	WAVE/Z wShadowY= TraceNameToWaveRef(graphName,polarTraceName)	// the trace actually exists
	if( WaveExists(wShadowY) )
		String df= GetWavesDataFolder(wShadowY,1)	// we rely on the fact that the shadow wave and the polarTracesTW wave are in the same data folder
		WAVE/T/Z tw= $(df+"polarTracesTW")
		Variable row= WMPolarShadowWaveRow(wShadowY)
		if( row != -1 )		// this wave was found in polarTracesTW
			WMPolarModernizePolarTracesWave(tw)
			String radiusErrorBarsMode= tw[row][kRadiusErrorBarsMode]
			Variable haveRadiusErrorBars= CmpStr(radiusErrorBarsMode, "None") != 0
			Variable haveAngleErrorBars= 0	// TO DO
			haveErrorBars= haveRadiusErrorBars || haveAngleErrorBars
		endif
	endif
	return haveErrorBars
End

// copies the polar trace colors to the error bars if colorFromTraceRadio is set
Function WMPolarCheckErrorBarTraceColors(graphName)
	String graphName
	
	String df=WMPolarGraphDF(graphName)	// no trailing ":"
	if( strlen(df) )
		WAVE/T/Z tw= $WMPolarGraphDFVar(graphName,"polarTracesTW")
		if( WaveExists(tw) )
			WMPolarModernizePolarTracesWave(tw)
			// check all the polar traces for error bars
			Variable row, rows=DimSize(tw,0)

			WMPolarBlockModifiedWindowHook(graphName,1)	// block
			for( row=0; row<rows; row+=1)
				String radiusErrorBarsMode= tw[row][kRadiusErrorBarsMode]
				Variable haveRadiusErrorBars= CmpStr(radiusErrorBarsMode, "None") != 0
				Variable haveAngleErrorBars= 0	// TO DO
				Variable haveErrorBars= haveRadiusErrorBars || haveAngleErrorBars
				if( haveErrorBars )
					String shadowYName= tw[row][kShadowTraceName]
					WAVE/Z wShadowY= $WMPolarGraphDFVar(graphName,shadowYName)
					if( WaveExists(wShadowY) )
						String polarTraceName= WMPolarTraceNameFromWaveRef(graphName, wShadowY)
						if( strlen(polarTraceName) )
							// We have a polar trace, compare its color to error bar trace(s) colors.
							String polarTraceColorsString = WMPolarGetTraceRGBStr(graphName, polarTraceName)

							// Since we can have any combination of radius and/or angle error bar traces,
							// this is a little tricky.
							// The user can change the color of either the radius or angle error bar traces, or the polar trace.
							//
							// WHEN tw[row][kErrorBarsColorFromTraceRadio]=1 "Color from Trace"
							// 		set tw[row][kErrorBarsColorRedGreenBlue] to the color of the polar trace.
							//		that color will be propogated to the error bar(s).
							
							// WHEN tw[row][kErrorBarsColorFromTraceRadio]=0 (custom color)
							// 		update tw[row][kErrorBarsColorRedGreenBlue] when the user changes the color of the polar trace,
							//		and then propogate that to the error bar(s).
							
							// 
							// We use ONE custom color for both error bars in the error bars panel when the radio button is not set to "Color From Trace"
							// We *could* use the radius error bars as the definitive color (since it is oldest),
							// But it is less problematic to propogate a color change of either error bar trace to the color of both traces
							// as a "custom color".
							// We detect the most recently changed color by comparing the radius and angle trace colors against the
							// polar trace and the not-from-polar-trace custom color.
							// The color that does not match either one is the one that must have most recently changed.
							
							String customErrorBarsColorsString= tw[row][kErrorBarsColorRedGreenBlue]	// if colors are NOT from the polar trace.
							Variable colorFromTraceRadio= str2num(tw[row][kErrorBarsColorFromTraceRadio])

							String angleErrorBarYWavePath= WMPolarGraphDFVar(graphName,tw[row][kAngleErrorsBarsY])	// polarAngleErrorBarY0, etc
							WAVE/Z wAngleBarsY= $angleErrorBarYWavePath
							String angleBarsTraceName=""
							String angleErrorBarsColorsString =""

							if( WaveExists(wAngleBarsY) )
								angleBarsTraceName= WMPolarTraceNameFromWaveRef(graphName, wAngleBarsY)
								if( strlen(angleBarsTraceName) )
									angleErrorBarsColorsString = WMPolarGetTraceRGBStr(graphName, angleBarsTraceName)
								endif
							endif
							
							String radiusErrorBarYWavePath= WMPolarGraphDFVar(graphName,tw[row][kRadiusErrorsBarsY])	// polarRadiusErrorBarY0, etc
							WAVE/Z wRadiusBarsY= $radiusErrorBarYWavePath
							String radiusBarsTraceName=""
							String radiusErrorBarsColorsString =""

							if( WaveExists(wRadiusBarsY) )
								radiusBarsTraceName= WMPolarTraceNameFromWaveRef(graphName, wRadiusBarsY)
								if( strlen(radiusBarsTraceName) )
									radiusErrorBarsColorsString = WMPolarGetTraceRGBStr(graphName, radiusBarsTraceName)
								endif
							endif
							
							if( strlen(radiusBarsTraceName) || strlen(angleBarsTraceName) )
								// have error bars trace(s), so we can know the color(s) and line thicknesses, marker sizes, etc.
								// need polar trace's color to (re)-apply to radius and angle error bars
								String colorStr
								if( colorFromTraceRadio )
									colorStr= polarTraceColorsString
								else // !colorFromTraceRadio )
									// since the color is set manually, save the MOST RECENTLY SET error bar trace color in tw
									colorStr= customErrorBarsColorsString
									if( strlen(radiusBarsTraceName) && (CmpStr(customErrorBarsColorsString,radiusErrorBarsColorsString) != 0) )
										colorStr= radiusErrorBarsColorsString
									elseif( strlen(angleBarsTraceName) && (CmpStr(customErrorBarsColorsString,angleErrorBarsColorsString) != 0) )
										colorStr= angleErrorBarsColorsString
									endif
									tw[row][kErrorBarsColorRedGreenBlue] = colorStr	// will be picked up by WMPolarUpdateErrorBarsPanel()
								endif	// colorFromTraceRadio
								
								Variable red, green, blue, alpha
								WMPolarParseColorStr(colorStr, red, green, blue, alpha)
								// compare to radius error bars colors, and change radius error bars colors if different
								if( strlen(radiusBarsTraceName) && (CmpStr(colorStr,radiusErrorBarsColorsString) != 0) )
									ModifyGraph/W=$graphName rgb($radiusBarsTraceName)=(red, green, blue, alpha)
								endif
								// compare trace color to angle error bars colors, and change angle error bars colors if different
								if( strlen(angleBarsTraceName) && (CmpStr(colorStr,angleErrorBarsColorsString) != 0) )
									ModifyGraph/W=$graphName rgb($angleBarsTraceName)=(red, green, blue, alpha)
								endif

								// Record changes to the bar trace thickness, etc. Perhaps these just shouldn't be separate settings.
								// Before Version 7.02 we didn't synchronize the radius and error bar line size, mrk thick or msize.
								String radiusInfo= ""
								String angleInfo= ""
								if( strlen(radiusBarsTraceName) )
									radiusInfo= TraceInfo(graphName,radiusBarsTraceName,0)
								endif
								if( strlen(angleBarsTraceName) )
									angleInfo= TraceInfo(graphName,angleBarsTraceName,0)
								endif
								if( strlen(radiusInfo) || strlen(angleInfo) )
									// detect a change in lsize on either angle or radius error bars
									String oldLSize= tw[row][kErrorBarsBarThickness]
									String newLSize= oldLSize
									String radiusLSize="", angleLSize=""
									if( strlen(radiusInfo) )
										radiusLSize = WMGetRECREATIONInfoByKey("lsize(x)", radiusInfo)
										if( CmpStr(radiusLSize, oldLSize) != 0 )
											newLSize= radiusLSize // user changed radius bar line size
										endif
									endif
									if( strlen(angleInfo) )
										angleLSize = WMGetRECREATIONInfoByKey("lsize(x)", angleInfo)
										if( CmpStr(angleLSize, oldLSize) != 0 )
											newLSize= angleLSize // user changed angle bar line size
										endif
									endif
									if( CmpStr(oldLSize, newLSize) != 0 )
										tw[row][kErrorBarsBarThickness] = newLSize	// will be picked up by WMPolarUpdateErrorBarsPanel()
										Variable lsize= str2num(newLSize)
										// compare to radius error bars value, and change radius error bars value if different
										if( strlen(radiusLSize) && (CmpStr(radiusLSize,newLSize) != 0) )
											ModifyGraph/W=$graphName lsize($radiusBarsTraceName)=lsize
										endif
										// compare trace color to angle error bars value, and change angle error bars value if different
										if( strlen(angleLSize) && (CmpStr(angleLSize,newLSize) != 0) )
											ModifyGraph/W=$graphName lsize($angleBarsTraceName)=lsize
										endif
									endif
									
									// detect a change in mrkThick
									String oldMrkThick= tw[row][kErrorBarsCapThickness]
									String newMrkThick= oldMrkThick
									String radiusMrkThick="", angleMrkThick=""
									if( strlen(radiusInfo) )
										radiusMrkThick = WMGetRECREATIONInfoByKey("mrkThick(x)", radiusInfo)
										if( CmpStr(radiusMrkThick, oldMrkThick) != 0 )
											newMrkThick= radiusMrkThick // user changed radius bar marker thickness
										endif
									endif
									if( strlen(angleInfo) )
										angleMrkThick = WMGetRECREATIONInfoByKey("mrkThick(x)", angleInfo)
										if( CmpStr(angleMrkThick, oldMrkThick) != 0 )
											newMrkThick= angleMrkThick // user changed angle bar marker thickness
										endif
									endif
									if( CmpStr(oldMrkThick, newMrkThick) != 0 )
										// Copy marker stroke to Constant kErrorBarsCapThickness= 16		// "1.0" (points) (this is mrkThick, the marker stroke width)
										tw[row][kErrorBarsCapThickness] = newMrkThick	// will be picked up by WMPolarUpdateErrorBarsPanel()
										Variable mrkThick = str2num(newMrkThick)
										// compare to radius error bars value, and change radius error bars value if different
										if( strlen(radiusMrkThick) && (CmpStr(radiusMrkThick,newMrkThick) != 0) )
											ModifyGraph/W=$graphName mrkThick($radiusBarsTraceName)=mrkThick
										endif
										// compare trace color to angle error bars value, and change angle error bars value if different
										if( strlen(angleMrkThick) && (CmpStr(angleMrkThick,newMrkThick) != 0) )
											ModifyGraph/W=$graphName mrkThick($angleBarsTraceName)=mrkThick
										endif
									endif
									
									// detect a change in radius cap width msize (not a shared property) 
									if( strlen(radiusInfo) )
										String radiusMSize = WMGetRECREATIONInfoByKey("msize(x)", radiusInfo)
										if( str2num(radiusMSize) == 0 )
										 	radiusMSize= "Auto"
										endif
										tw[row][kRadiusErrorBarsCapWidth] = radiusMSize	// will be picked up by WMPolarUpdateErrorBarsPanel()
									endif
									// detect a change in angle cap width msize (not a shared property) 
									if( strlen(angleInfo) )
										String angleMSize = WMGetRECREATIONInfoByKey("msize(x)", angleInfo)
										if( str2num(angleMSize) == 0 )
										 	angleMSize= "Auto"
										endif
										tw[row][kAngleErrorBarsCapWidth] = angleMSize	// will be picked up by WMPolarUpdateErrorBarsPanel()
									endif // strlen(angleInfo)
								endif // strlen(radiusInfo) || strlen(angleInfo)
							endif // strlen(radiusBarsTraceName) || strlen(angleBarsTraceName)
						endif	// strlen(polarTraceName)
					endif	// WaveExists(wShadowY)
				endif	// haveErrorBars
			endfor // for( row...
			WMPolarBlockModifiedWindowHook(graphName,0)	// permit
		endif	// WaveExists(tw)
	endif	// strlen(df)
End


// compare to WMPolarModifyFillToOrigin
// sets up or destroys the radius and/or angle error bar waves for polarTraceName
Function WMPolarModifyErrorBars(graphName,polarTraceName)
	String graphName, polarTraceName // inputs: polarTraceName must not have any radius data wave name such as  "polarY0 [radiusData]" 

	// General Settings
	Variable errorBarsCapThickness, errorBarsBarThickness, colorFromTraceRadio
	String errorBarsColorsString
	Variable red, green, blue, alpha
	String polarTraceColorsString = WMPolarGetTraceRGBStr(graphName, polarTraceName)

	// Radius Error Bars
	Variable wantRadiusErrorBars= 0	
	String radiusErrorBarsX="", radiusErrorBarsY="", radiusErrorBarsMrkZ=""
	String radiusErrorBarsMode, radiusErrorBarsPlusWavePath, radiusErrorBarsMinusWavePath, radiusErrorBarsCapWidthStr
	Variable radiusErrorBarsPercent, radiusErrorBarsConstant

	// Angle Error Bars
	Variable wantAngleErrorBars= 0
	String angleErrorBarsX="", angleErrorBarsY="", angleErrorBarsMrkZ=""
	String angleErrorBarsMode, angleErrorBarsPlusWavePath, angleErrorBarsMinusWavePath, angleErrorBarsCapWidthStr
	Variable angleErrorBarsPercent, angleErrorBarsConstant

	String df= WMPolarGetTraceErrorBars(graphName,polarTraceName,errorBarsCapThickness,errorBarsBarThickness,colorFromTraceRadio,errorBarsColorsString)
	if( strlen(df) )
		if( colorFromTraceRadio )
			WMPolarParseColorStr(polarTraceColorsString, red, green, blue, alpha)
		else
			WMPolarParseColorStr(errorBarsColorsString, red, green, blue, alpha)
		endif
		// Radius Error Bars
		df= WMPolarGetTraceRadiusErrorBars(graphName,polarTraceName,radiusErrorBarsX,radiusErrorBarsY,radiusErrorBarsMrkZ,radiusErrorBarsMode,radiusErrorBarsPercent,radiusErrorBarsConstant,radiusErrorBarsPlusWavePath,radiusErrorBarsMinusWavePath,radiusErrorBarsCapWidthStr)
		if( strlen(df) )
			strswitch(radiusErrorBarsMode)
				case "% of radius":
				case "+ constant":
				case "+/- constant":
				case "+/- wave":
				case "sqrt of radius":
					wantRadiusErrorBars= 1
					break
				default:
					Print "Radius Bug in WMPolarModifyErrorBars()!"; Beep
					// FALL THROUGH
				case "None":
					wantRadiusErrorBars= 0
					break
			endswitch
		endif
		// Angle Error Bars
		df= WMPolarGetTraceAngleErrorBars(graphName,polarTraceName,angleErrorBarsX,angleErrorBarsY,angleErrorBarsMrkZ,angleErrorBarsMode,angleErrorBarsPercent,angleErrorBarsConstant,angleErrorBarsPlusWavePath,angleErrorBarsMinusWavePath,angleErrorBarsCapWidthStr)
		if( strlen(df) )
			strswitch(angleErrorBarsMode)
				case "% of angle":
				case "+ constant":
				case "+/- constant":
				case "+/- wave":
				case "sqrt of angle":
					wantAngleErrorBars= 1
					break
				default:
					Print "Angle Bug in WMPolarModifyErrorBars()!"; Beep
					// FALL THROUGH
				case "None":
					wantAngleErrorBars= 0
					break
			endswitch
		endif
	endif
	if( strlen(df) == 0 )
		return -1
	endif
	String oldDF= GetDataFolder(1)
	SetDataFolder df
	
// can't append error bars without polar trace "shadow" waves
	WAVE/Z wShadowY=TraceNameToWaveRef(graphName,polarTraceName)
	WAVE/Z wShadowX=XWaveRefFromTrace(graphName,polarTraceName)
	if( WaveExists(wShadowY) == 0  || WaveExists(wShadowX) == 0 )
		SetDataFolder oldDF
		return -1
	endif

	String barsTraceName, anchorTraceName
	Variable capWidthPoints

	// create and append
	// or remove and destroy
	// the radius error bar waves
	String radiusErrorBarXWavePath=""
	String radiusErrorBarYWavePath=""
	String radiusErrorBarZWavePath=""

	if( strlen(radiusErrorBarsY) )
		radiusErrorBarXWavePath= df+radiusErrorBarsX
		radiusErrorBarYWavePath= df+radiusErrorBarsY
		radiusErrorBarZWavePath= df+radiusErrorBarsMrkZ
	endif

	if( wantRadiusErrorBars )
		// if they don't exist, create the radius error bar waves
		// and append them below the polar "shadow" traces
		// (so that markers are drawn in front of the error bar)

		if( strlen(radiusErrorBarsY) == 0 )
			radiusErrorBarsX= UniqueName("polarRadiusErrorBarX",1,0)	// polarRadiusErrorBarX0, etc
			radiusErrorBarXWavePath= df+radiusErrorBarsX

			radiusErrorBarsY= UniqueName("polarRadiusErrorBarY",1,0)	// polarRadiusErrorBarY0, etc
			radiusErrorBarYWavePath= df+radiusErrorBarsY

			radiusErrorBarsMrkZ= UniqueName("polarRadiusErrorBarZ",1,0)	// polarRadiusErrorBarZ0, etc
			radiusErrorBarZWavePath= df+radiusErrorBarsMrkZ
		endif
		WMPolarSetTraceRadiusErrorBars(graphName,polarTraceName,radiusErrorBarsX,radiusErrorBarsY,radiusErrorBarsMrkZ,radiusErrorBarsMode,radiusErrorBarsPercent,radiusErrorBarsConstant,radiusErrorBarsPlusWavePath,radiusErrorBarsMinusWavePath,radiusErrorBarsCapWidthStr)
		
		// create the radius error bar waves
		Make/O/D/N=1 $radiusErrorBarXWavePath/WAVE=wx
		wx=NaN

		Make/O/D/N=1 $radiusErrorBarYWavePath/WAVE=wy
		wy=NaN
		
		Make/O/D/N=1 $radiusErrorBarZWavePath/WAVE=wz
		wz=NaN
		
		CheckDisplayed/W=$graphName wy
		if( V_Flag == 0 )
			// append radius error bar wave below the shadowY trace (so that any markers are drawn in front of the error bar)
			AppendToGraph/W=$graphName/L=VertCrossing/B=HorizCrossing wy vs wx
			anchorTraceName= polarTraceName
			ReorderTraces/W=$graphName $anchorTraceName, {$radiusErrorBarsY}
			SetWindow $graphName markerHook= {WMPolarErrorBarCapMarker, kPolarCapMarkerNumber, kPolarAngleCapMarkerNumber}
		endif
		// set the color unless it is set by the polar trace
		barsTraceName= WMPolarTraceNameFromWaveRef(graphName, wy)

		if( strlen(barsTraceName) )
			ModifyGraph/W=$graphName rgb($barsTraceName)=(red, green, blue, alpha)
			capWidthPoints= WMPolarCapWidthPoints(radiusErrorBarsCapWidthStr)
			ModifyGraph/W=$graphName lsize($barsTraceName)=errorBarsBarThickness, mode($barsTraceName)= 4 // lines and markers, bar thickness
			ModifyGraph/W=$graphName msize($barsTraceName)=capWidthPoints, mrkThick($barsTraceName)=errorBarsCapThickness	// cap width and thickness
			ModifyGraph/W=$graphName marker($barsTraceName)=kPolarCapMarkerNumber, zmrkNum($barsTraceName)={wz}	// caps or no caps
		endif
		
		// then update the existing radius error bar waves
		//WMPolarUpdateErrorBars(wShadowX,wShadowY)
	else
		// if the radius error bar waves exist, remove them from the graph, then delete them.
		WAVE/Z radiusY= $radiusErrorBarYWavePath
		if( WaveExists(radiusY) )
			WMPolarRemoveWaveFromGraph(graphName, radiusY)
			KillWaves/Z radiusY
		endif
		WAVE/Z radiusX= $radiusErrorBarXWavePath
		if( WaveExists(radiusX) )
			KillWaves/Z radiusX
		endif
		// KillWaves/Z radiusZ was missing before Igor 7.02:
		WAVE/Z radiusZ= $radiusErrorBarZWavePath
		if( WaveExists(radiusZ) )
			KillWaves/Z radiusZ
		endif
	endif

	// create and append
	// or remove and destroy
	// the angle error bar waves
	String angleErrorBarXWavePath=""
	String angleErrorBarYWavePath=""
	String angleErrorBarZWavePath=""

	if( strlen(angleErrorBarsY) )
		angleErrorBarXWavePath= df+angleErrorBarsX
		angleErrorBarYWavePath= df+angleErrorBarsY
		angleErrorBarZWavePath= df+angleErrorBarsMrkZ
	endif

	if( wantAngleErrorBars )
		// if they don't exist, create the angle error bar waves
		// and append them below the polar "shadow" traces
		// (so that markers are drawn in front of the error bar)
	
		// unlike the straight radius error bars which need only a few points to define the error bar,
		// the curved angle error bars require many more points, typically 1 point per degree

		if( strlen(angleErrorBarsY) == 0 )
			angleErrorBarsX= UniqueName("polarAngleErrorBarX",1,0)	// polarAngleErrorBarX0, etc
			angleErrorBarXWavePath= df+angleErrorBarsX

			angleErrorBarsY= UniqueName("polarAngleErrorBarY",1,0)	// polarAngleErrorBarY0, etc
			angleErrorBarYWavePath= df+angleErrorBarsY

			angleErrorBarsMrkZ= UniqueName("polarAngleErrorBarZ",1,0)	// polarAngleErrorBarZ0, etc
			angleErrorBarZWavePath= df+angleErrorBarsMrkZ
		endif

		WMPolarSetTraceAngleErrorBars(graphName,polarTraceName,angleErrorBarsX,angleErrorBarsY,angleErrorBarsMrkZ,angleErrorBarsMode,angleErrorBarsPercent,angleErrorBarsConstant,angleErrorBarsPlusWavePath,angleErrorBarsMinusWavePath,angleErrorBarsCapWidthStr)
		
		// create the angle error bar waves
		Make/O/D/N=1 $angleErrorBarXWavePath/WAVE=wx
		wx=NaN

		Make/O/D/N=1 $angleErrorBarYWavePath/WAVE=wy
		wy=NaN
		
		Make/O/D/N=1 $angleErrorBarZWavePath/WAVE=wz
		wz=NaN
		
		CheckDisplayed/W=$graphName wy
		if( V_Flag == 0 )
			// angle error bar wave below the shadowY trace (so that any markers are drawn in front of the error bar)
			AppendToGraph/W=$graphName/L=VertCrossing/B=HorizCrossing wy vs wx
			anchorTraceName= polarTraceName
			ReorderTraces/W=$graphName $anchorTraceName, {$angleErrorBarsY}
			SetWindow $graphName markerHook= {WMPolarErrorBarCapMarker, kPolarCapMarkerNumber, kPolarAngleCapMarkerNumber}
		endif

		// set the color unless it is set by the polar trace
		barsTraceName= WMPolarTraceNameFromWaveRef(graphName, wy)
		if( strlen(barsTraceName) )
			ModifyGraph/W=$graphName rgb($barsTraceName)=(red, green, blue, alpha)
			capWidthPoints= WMPolarCapWidthPoints(angleErrorBarsCapWidthStr)
			ModifyGraph/W=$graphName lsize($barsTraceName)=errorBarsBarThickness, mode($barsTraceName)= 4 // lines and markers, bar thickness
			ModifyGraph/W=$graphName msize($barsTraceName)=capWidthPoints, mrkThick($barsTraceName)=errorBarsCapThickness	// cap width and thickness
			ModifyGraph/W=$graphName marker($barsTraceName)=kPolarAngleCapMarkerNumber, zmrkNum($barsTraceName)={wz}	// caps or no caps
		endif
	else
		// if the angle error bar waves exist, remove them from the graph, then delete them.
		WAVE/Z angleY= $angleErrorBarYWavePath
		if( WaveExists(angleY) )
			WMPolarRemoveWaveFromGraph(graphName, angleY)
			KillWaves/Z angleY
		endif
		WAVE/Z angleX= $angleErrorBarXWavePath
		if( WaveExists(angleX) )
			KillWaves/Z angleX
		endif
		WAVE/Z angleZ= $angleErrorBarZWavePath
		if( WaveExists(angleZ) )
			KillWaves/Z angleZ
		endif
	endif

	if( wantRadiusErrorBars || wantAngleErrorBars )
		// then update the radius &/or angle error bar waves
		WMPolarUpdateErrorBars(wShadowX,wShadowY) // creates radius error bar values, TO DO: create angle error bars.
	endif

	SetDataFolder oldDF

	// set up the proper dependencies for radius autoscaling (angle range does not autoscale)
	WAVE/Z wShadowY=TraceNameToWaveRef(graphName,polarTraceName)
	Variable row= WMPolarShadowWaveRow(wShadowY)
	if( row >= 0 )
		WMPolarUpdateShadowWaveByRow(graphName,row)	// includes radius error bar ranges
	endif

	return 0
End

// removes all Y instances of wy from the graph
Function WMPolarRemoveWaveFromGraph(graphName, wy)
	String graphName
	Wave/z wy

	DoWindow $graphName
	if( V_Flag && WaveExists(wy) )
		String wypath= GetWavesDataFolder(wy,2)
		String traces= TraceNameList(graphName,";",1)
		Variable i, n= ItemsInList(traces)
		for(i=n-1; i>=0; i-=1)	// work backwards so that the duplicates of a trace are removed in the right order (remove wn#3 before wn#2)
			String tn= StringFromList(i, traces)
			String wpath= GetWavesDataFolder(TraceNameToWaveRef(graphName, tn), 2)
			if( CmpStr(wpath, wypath) == 0 )
				RemoveFromGraph/W=$graphName/Z $tn
			endif
		endFor
	endif
End

// returns the first trace name that has wy as its Y wave, or "" if none
Function/S WMPolarTraceNameFromWaveRef(graphName, wy)
	String graphName
	Wave wy
	
	String wypath= GetWavesDataFolder(wy,2)
	String traces= TraceNameList(graphName,";",1)
	Variable i, n=ItemsInList(traces)
	for(i=0; i<n; i+=1)
		String traceName= StringFromList(i,traces)
		String wpath= GetWavesDataFolder(TraceNameToWaveRef(graphName, traceName),2)
		if( CmpStr(wpath, wypath) == 0 )
			return traceName
		endif
	endfor
	return ""
End

Function/S WMPolarGetTraceRGBStr(graphName, traceName)
	String graphName, traceName

	String info= TraceInfo(graphName,traceName,0)
	String rgbtext= WMGetRECREATIONInfoByKey("rgb(x)", info)	//  "(r,g,b)" or "(r,g,b,a)"
	return rgbtext
End

// START Error Bars subpanel
Function WMPolarShowErrorBarsPanel()

	DoWindow/K WMPolarErrorBarsPanel
	//NewPanel /K=1 /W=(199,268,493,563) as "Polar Error Bars"
	//NewPanel /K=1 /W=(83,85,373,438) as "Polar Error Bars" // /W=(left, top, right, bottom )

	Variable defLeft=83	// NewPanel units
	Variable defTop= 85
	Variable defRight= 373
	Variable defBottom= 438
	
	// clear old coordinates if panel not high enough
	// 	TitleBox error,win=WMPolarErrorBarsPanel, pos={116,325},size={52,12},frame=0
	Variable neededHeight = 325 + 12	// bottom-most control + control height
	Variable vLeft, vTop, vRight, vBottom
	if( WC_WindowCoordinatesGetNums("WMPolarErrorBarsPanel", vLeft, vTop, vRight, vBottom, usePixels=1) ) // have coordinates
		Variable panelHeight= vBottom-vTop
		if( panelHeight < neededHeight )
			WC_WindowCoordinatesForget("WMPolarErrorBarsPanel")
		endif
	endif
	String fmt="NewPanel/K=1/W=(%s)/N=WMPolarErrorBarsPanel as \"Polar Error Bars\""	// /W=(defLeft,defTop,defRight,defBottom)
	// restore from previous position
	String command= WC_WindowCoordinatesSprintf("WMPolarErrorBarsPanel",fmt,defLeft,defTop,defRight,defBottom,1)
	Execute command
	ModifyPanel/W=WMPolarErrorBarsPanel fixedSize=1, noEdit=1

	DefaultGuiFont/W=WMPolarErrorBarsPanel/Mac popup={"_IgorSmall",9,0}
	DefaultGuiFont/W=WMPolarErrorBarsPanel/Win popup={"_IgorSmall",12,0}

	String moduleName= GetIndependentModuleName()+"#"

	String/G $WMPolarDFVAR("polarTrace")
	SVAR polarTraceName= $WMPolarDFVAR("polarTrace")
	String polarTraceList= WMPolarTraceNameList(1)
	Variable mode= max(1,1+WhichListItem(polarTraceName, polarTraceList))
	String match= StringFromList(mode-1, polarTraceList)

	PopupMenu mainModifyTracePop,win=WMPolarErrorBarsPanel,pos={13,13},size={256,19},bodyWidth=200,title="Polar Trace:"
	PopupMenu mainModifyTracePop,win=WMPolarErrorBarsPanel,mode=mode,popvalue=match
//	PopupMenu mainModifyTracePop,win=WMPolarErrorBarsPanel,value= #"ProcGlobal#WMPolarTraceNameList(1)", proc=WMPolarErrorBarsTracePopup
	command= moduleName+"WMPolarTraceNameList(1)"
	PopupMenu mainModifyTracePop,win=WMPolarErrorBarsPanel,value= #command, proc=WMPolarErrorBarsTracePopup

//	GroupBox radiusErrorBarsGroup,win=WMPolarErrorBarsPanel,pos={15,56},size={263,124}

	Variable/G $WMPolarDFVAR("errorBarsTabNum")	// defaults to 0
	NVAR errorBarsTabNum= $WMPolarDFVAR("errorBarsTabNum")
	TabControl ErrorBarsTab,win=WMPolarErrorBarsPanel, pos={16,53}, size={259,173}, proc=WMPolarErrorBarsTabProc
	TabControl ErrorBarsTab,win=WMPolarErrorBarsPanel,tabLabel(0)="Radius Error Bars",tabLabel(1)="Angle Error Bars"
	TabControl ErrorBarsTab,win=WMPolarErrorBarsPanel,value= errorBarsTabNum

	// Radius Error Bars Tab Controls
	PopupMenu radiusErrorBarsMode,win=WMPolarErrorBarsPanel,pos={30,87}, size={212,19},proc=WMPolarErrorBarsRadiusModeProc,title="Radius Error Bar Mode:"
	PopupMenu radiusErrorBarsMode,win=WMPolarErrorBarsPanel,mode=1,popvalue="None",value= #"\"None;% of radius;sqrt of radius;+ constant;+/- constant;+/- wave;\""

	SetVariable radiusErrorsPercent,win=WMPolarErrorBarsPanel,pos={30,116}, size={140,18},bodyWidth=80,proc=WMPolarErrorBarsPercentProc,title="Radius +/-"
	SetVariable radiusErrorsPercent,win=WMPolarErrorBarsPanel,limits={-inf,inf,0},value= _NUM:5

	TitleBox radiusErrorsPercentUnits,win=WMPolarErrorBarsPanel,pos={183,118},size={10,15},title="%",frame=0

	PopupMenu radiusErrorsPlusWave,win=WMPolarErrorBarsPanel,pos={30,141},size={138,19},proc=WMPolarErrorBarsPlusWaveProc,title="Radius +wave:"
	command= moduleName+"WMPolarWaveListAndNone()"
	PopupMenu radiusErrorsPlusWave,win=WMPolarErrorBarsPanel,value= #command

	PopupMenu radiusErrorsMinusWave,win=WMPolarErrorBarsPanel,pos={30,168}, size={135,19},proc=WMPolarErrorBarsMinusWaveProc,title="Radius -wave:"
	PopupMenu radiusErrorsMinusWave,win=WMPolarErrorBarsPanel,value= #command

	// Renamed radiusErrorsCapWidthDegrees to radiusErrorsCapWidth
	SetVariable radiusErrorsCapWidth,win=WMPolarErrorBarsPanel,pos={30,197},size={147,14},proc=WMPolarRadiusErrorBarsCapWidth
	SetVariable radiusErrorsCapWidth,win=WMPolarErrorBarsPanel,bodyWidth=60,title="Radius Cap Width:",limits={0,99,1},value= _STR:"Auto"

	TitleBox radiusErrorsCapWidthUnits,win=WMPolarErrorBarsPanel,pos={189,199},size={27,11},title="points",frame=0

	// Angle Error Bars Tab Controls
	
	PopupMenu angleErrorBarsMode,win=WMPolarErrorBarsPanel,pos={31,87},size={189,19},proc=WMPolarErrorBarsAngleModeProc,title="Angle Error Bar Mode:",disable=1
	PopupMenu angleErrorBarsMode,win=WMPolarErrorBarsPanel,mode=1,popvalue="+/- wave",value= #"\"None;% of angle;sqrt of angle;+ constant;+/- constant;+/- wave;\""

	SetVariable angleErrorsPercent,win=WMPolarErrorBarsPanel,pos={31,116},size={136,18},bodyWidth=80,proc=WMPolarAngErrorBarsPercentProc,title="Angle +/-",disable=1
	SetVariable angleErrorsPercent,win=WMPolarErrorBarsPanel,limits={-inf,inf,0},value= _NUM:NaN

	TitleBox angleErrorsPercentUnits,win=WMPolarErrorBarsPanel,pos={183,118},size={10,15},frame=0,title="%",disable=1

	PopupMenu angleErrorsPlusWave,win=WMPolarErrorBarsPanel,pos={31,141},size={178,19},proc=WMPolarAngErrorBarsPlusWaveProc,title="Angle +wave:",disable=1
	PopupMenu angleErrorsPlusWave,win=WMPolarErrorBarsPanel,mode=1,popvalue="None",value= #command

	PopupMenu angleErrorsMinusWave,win=WMPolarErrorBarsPanel,pos={31,168},size={186,19},proc=WMPolarAngErrorBarsMinusWavePrc,title="Angle -wave:",disable=1
	PopupMenu angleErrorsMinusWave,win=WMPolarErrorBarsPanel,mode=1,popvalue="None",value= #command

	SetVariable angleErrorsCapWidth,win=WMPolarErrorBarsPanel,pos={31,197},size={157,18},bodyWidth=60,proc=WMPolarAngleErrorBarsCapWidth,title="Angle Cap Width:",disable=1
	SetVariable angleErrorsCapWidth,win=WMPolarErrorBarsPanel,limits={0,99,1},value= _STR:"Auto"

	TitleBox angleErrorsCapWidthUnits,win=WMPolarErrorBarsPanel,pos={199,199},size={33,15},frame=0,title="points",disable=1

	// Shared Error Bar Controls

	GroupBox colorGroup,win=WMPolarErrorBarsPanel,pos={14,242},size={118,66},title="Bar & Cap Color"
	CheckBox colorFromTrace,win=WMPolarErrorBarsPanel,pos={28,263},size={88,15},proc=WMPolarErrorBarsRadioProc,title="Use Trace Color"
	CheckBox colorFromTrace,win=WMPolarErrorBarsPanel,value= 1,mode=1
	CheckBox colorFromPopup,win=WMPolarErrorBarsPanel,pos={28,284},size={15,15},proc=WMPolarErrorBarsRadioProc,title=""
	CheckBox colorFromPopup,win=WMPolarErrorBarsPanel,value= 0,mode=1
	PopupMenu color,win=WMPolarErrorBarsPanel,pos={48,283},size={50,19},proc=WMPolarErrorBarsColorPopup
	PopupMenu color,win=WMPolarErrorBarsPanel,mode=1,popColor= (0,0,0),value= #"\"*COLORPOP*\""

	GroupBox thicknessGroup,win=WMPolarErrorBarsPanel,pos={140,244},size={138,65},title="Bar & Cap Thickness"
	SetVariable barThickness,win=WMPolarErrorBarsPanel,pos={157,263}, size={72,14},bodyWidth=50,proc=WMPolarErrorBarsBarThickProc,title="Bar:"
	SetVariable barThickness,win=WMPolarErrorBarsPanel,limits={0,10,0.5},value= _NUM:1
	TitleBox barThicknessUnits,win=WMPolarErrorBarsPanel,pos={233,264}, size={27,11},title="points",frame=0

	SetVariable capThickness,win=WMPolarErrorBarsPanel,pos={154,284},size={75,14},bodyWidth=50,proc=WMPolarErrorBarsCapThickProc,title="Cap:"
	SetVariable capThickness,win=WMPolarErrorBarsPanel,limits={0,10,0.5},value= _NUM:1
	TitleBox capThicknessUnits,win=WMPolarErrorBarsPanel,pos={233,285},size={27,11},title="points",frame=0

	Button errorBarsHelpButton,win=WMPolarErrorBarsPanel,pos={16,320},size={50,20},proc=WMPolarErrorBarsCloseHelp,title="Help"
	Button errorBarsCloseButton,win=WMPolarErrorBarsPanel,pos={225,320},size={50,20},proc=WMPolarErrorBarsCloseHelp,title="Close"

	TitleBox error,win=WMPolarErrorBarsPanel, pos={116,325},size={52,12},frame=0
	TitleBox error,win=WMPolarErrorBarsPanel, fColor=(65535,0,0),anchor= MT

	SetWindow WMPolarErrorBarsPanel hook=WMPolarErrorBarsPanelHook
	WMPolarUpdateErrorBarsPanel(1)
End


Function WMPolarErrorBarsCloseHelp(ctrlName) : ButtonControl
	String ctrlName

	strswitch(ctrlName)
		case "errorBarsCloseButton":
			Execute/P/Q/Z "DoWindow/K WMPolarErrorBarsPanel"
			break
		case "errorBarsHelpButton":
			DisplayHelpTopic/K=1 "Polar Graphs[Error Bars Dialog]"
			break
	endswitch
End

Function WMPolarErrorBarsTabProc(ctrlName,tabNum) : TabControl
	String ctrlName
	Variable tabNum

	Variable/G $WMPolarDFVAR("errorBarsTabNum")=tabNum
	WMPolarUpdateErrorBarsPanel(0)
	return 0
End

StrConstant ksErrorBarTab0Controls = "radiusErrorBarsMode;radiusErrorsCapWidth;radiusErrorsCapWidthUnits;radiusErrorsMinusWave;radiusErrorsPercent;radiusErrorsPercentUnits;radiusErrorsPlusWave;"
StrConstant ksErrorBarTab1Controls = "angleErrorBarsMode;angleErrorsCapWidth;angleErrorsPercentUnits;angleErrorsCapWidthUnits;angleErrorsMinusWave;angleErrorsPercent;angleErrorsPlusWave;"

Function WMPolarUpdateErrorBarsPanel(updateErrorBarsToo)
	Variable updateErrorBarsToo

	DoWindow WMPolarErrorBarsPanel
	if( V_Flag == 0 )
		return -1
	endif
	
	String graphName= WMPolarTopPolarGraph()
	if( strlen(graphName) == 0 )
		DoAlert 0, "No active polar graph; closing down..."
		Execute/P/Q/Z "DoWindow/K WMPolarErrorBarsPanel"
		return -1
	endif
	
	// Renamed radiusErrorsCapWidthDegrees to radiusErrorsCapWidth when angle error bar controls were introduced.
	ControlInfo/W=WMPolarErrorBarsPanel radiusErrorsCapWidthDegrees
	Variable haveOldPanel = V_Flag != 0
	if( haveOldPanel )
		DoAlert 0, "Rebuilding old Error Bars Panel..."
		WC_WindowCoordinatesForget("WMPolarErrorBarsPanel")
		Execute/P/Q/Z "WMPolarShowErrorBarsPanel()"
		return -1
	endif

	String error=""

	// refill the popup in case the target graph changed.
	ControlInfo/W=WMPolarErrorBarsPanel mainModifyTracePop
	if( V_Flag < 0 )
		return -1		// programming error
	endif
	
	String polarTraceName= S_value // traceName [<radius data wave name>]
	String polarTraceList= WMPolarTraceNameList(1)
	Variable mode= max(1,1+WhichListItem(polarTraceName, polarTraceList))
	String match= StringFromList(mode-1, polarTraceList)
	PopupMenu mainModifyTracePop,win=WMPolarErrorBarsPanel,mode=mode,popvalue=match
	String help=PolarTraceSources(WMPolarTopPolarGraph(),match)
	PopupMenu mainModifyTracePop,win=WMPolarErrorBarsPanel,help={help}

	// Hide/show the controls depending on the tab setting
	ControlInfo/W=WMPolarErrorBarsPanel ErrorBarsTab
	Variable 	errorBarsTabNum= V_Value
	Variable tab0Disable= errorBarsTabNum == 0 ? 0 : 1
	ModifyControlList ksErrorBarTab0Controls win=WMPolarErrorBarsPanel, disable=tab0Disable
	Variable tab1Disable= errorBarsTabNum == 1 ? 0 : 1
	ModifyControlList ksErrorBarTab1Controls win=WMPolarErrorBarsPanel, disable=tab1Disable

	// set the error bar controls to match the error bar settings for the selected polar trace
	Variable errorBarsCapThickness, errorBarsBarThickness, colorFromTraceRadio
	String errorBarsColorsString
	String df= WMPolarGetTraceErrorBars(graphName,polarTraceName,errorBarsCapThickness,errorBarsBarThickness,colorFromTraceRadio,errorBarsColorsString)
	if( strlen(df) )
		// General Settings
		//	Bar & Cap Color
		CheckBox colorFromTrace,win=WMPolarErrorBarsPanel,value= colorFromTraceRadio != 0
		CheckBox colorFromPopup,win=WMPolarErrorBarsPanel,value= colorFromTraceRadio == 0
		Variable red, green, blue, alpha
		WMPolarParseColorStr(errorBarsColorsString, red, green, blue, alpha)
		PopupMenu color,win=WMPolarErrorBarsPanel,popColor= (red,green,blue,alpha)
		//	Bar & Cap Thickness
		SetVariable barThickness,win=WMPolarErrorBarsPanel,value= _NUM:errorBarsBarThickness
		SetVariable capThickness,win=WMPolarErrorBarsPanel,value= _NUM:errorBarsCapThickness

		Variable disableSetVar
		Variable disableSetVarUnits
		Variable disableWavePops
		Variable disableCapWidth
		String title, leafName
		Variable value
		Variable minimum,maximum
		
		// Radius Error Bars
		if( errorBarsTabNum == 0 )
			String radiusErrorBarsX, radiusErrorBarsY, radiusErrorBarsMrkZ
			String radiusErrorBarsMode, radiusErrorBarsPlusWavePath, radiusErrorBarsMinusWavePath, radiusErrorBarsCapWidthStr
			Variable radiusErrorBarsPercent, radiusErrorBarsConstant
	
			df= WMPolarGetTraceRadiusErrorBars(graphName,polarTraceName,radiusErrorBarsX,radiusErrorBarsY,radiusErrorBarsMrkZ,radiusErrorBarsMode,radiusErrorBarsPercent,radiusErrorBarsConstant,radiusErrorBarsPlusWavePath,radiusErrorBarsMinusWavePath,radiusErrorBarsCapWidthStr)
			if( strlen(df) )
				//StrConstant ksRadiusErrorBarsModes= "None;% of radius;sqrt of radius;+ constant;+/- constant;+/- wave;"
				mode= max(1,1+WhichListItem(radiusErrorBarsMode, ksRadiusErrorBarsModes))
				match= StringFromList(mode-1, ksRadiusErrorBarsModes)
				PopupMenu radiusErrorBarsMode,win=WMPolarErrorBarsPanel,mode=mode,popvalue=match
		
				// radiusErrorsPercent is used for % of radius, for +constant, and +/- constant.
				// it is hidden for all other modes.
				disableSetVar= 1	// hide
				disableSetVarUnits= 1	// hide
				disableWavePops= 1	// hide
				disableCapWidth= 0	// show
				title= "Radius +/-"
				value=NaN
				minimum=0
				maximum=inf
				strswitch(radiusErrorBarsMode)
					case "% of radius":
						disableSetVar = 0	// show
						disableSetVarUnits = 0	// show
						value= radiusErrorBarsPercent
						minimum= -100	// %
						maximum= 100	// %
						break
					case "+ constant":
						title= "Radius +"
						minimum= -inf
						// FALL THROUGH
					case "+/- constant":
						disableSetVar = 0	// show only the constant value, not %
						value= radiusErrorBarsConstant
						break
					case "+/- wave":
						disableWavePops= 0	// show
						break
					default:
						Print "Bug in WMPolarUpdateErrorBarsPanel()!"; Beep
						// FALL THROUGH
					case "None":
						disableCapWidth= 1	// hide
						break
					case "sqrt of radius":
						break
				endswitch
				//Radius  +/- Constant or %
				SetVariable radiusErrorsPercent,win=WMPolarErrorBarsPanel,title=title,limits={minimum,maximum,0},value= _NUM:value, disable= disableSetVar
				TitleBox radiusErrorsPercentUnits,win=WMPolarErrorBarsPanel, disable= disableSetVarUnits
	
				// Radius +/- Waves
				leafName= WMPolarGetUnquotedLeafName(radiusErrorBarsPlusWavePath)
				PopupMenu radiusErrorsPlusWave,win=WMPolarErrorBarsPanel, popvalue=leafName, popmatch=leafname, disable= disableWavePops
				leafName= WMPolarGetUnquotedLeafName(radiusErrorBarsMinusWavePath)
				PopupMenu radiusErrorsMinusWave,win=WMPolarErrorBarsPanel, popvalue=leafName, popmatch=leafname, disable= disableWavePops
	
				// Radius Cap width
				SetVariable radiusErrorsCapWidth,win=WMPolarErrorBarsPanel,value= _STR:radiusErrorBarsCapWidthStr, disable= disableCapWidth
				if( WMPolarIsValidCapWidth(radiusErrorBarsCapWidthStr) )
					SetVariable radiusErrorsCapWidth,win=WMPolarErrorBarsPanel,valueColor=(0,0,0),fColor=(0,0,0)
					TitleBox radiusErrorsCapWidthUnits,win=WMPolarErrorBarsPanel,fColor=(0,0,0)
				else
					error= "Expected \"Auto\" or degrees > 0"
					SetVariable radiusErrorsCapWidth,win=WMPolarErrorBarsPanel,valueColor=(65535,0,0),fColor=(65535,0,0)
					TitleBox radiusErrorsCapWidthUnits,win=WMPolarErrorBarsPanel,fColor=(65535,0,0)
				endif
				TitleBox radiusErrorsCapWidthUnits,win=WMPolarErrorBarsPanel, disable= disableCapWidth
			endif
		else // angle error bars
			String angleErrorBarsX, angleErrorBarsY, angleErrorBarsMrkZ
			String angleErrorBarsMode, angleErrorBarsPlusWavePath, angleErrorBarsMinusWavePath, angleErrorBarsCapWidthStr
			Variable angleErrorBarsPercent, angleErrorBarsConstant
	
			df= WMPolarGetTraceAngleErrorBars(graphName,polarTraceName,angleErrorBarsX,angleErrorBarsY,angleErrorBarsMrkZ,angleErrorBarsMode,angleErrorBarsPercent,angleErrorBarsConstant,angleErrorBarsPlusWavePath,angleErrorBarsMinusWavePath,angleErrorBarsCapWidthStr)
			if( strlen(df) )
				//StrConstant ksAngleErrorBarsModes= "None;% of angle;sqrt of angle;+ constant;+/- constant;+/- wave;"
				mode= max(1,1+WhichListItem(angleErrorBarsMode, ksAngleErrorBarsModes))
				match= StringFromList(mode-1, ksRadiusErrorBarsModes)
				PopupMenu angleErrorBarsMode,win=WMPolarErrorBarsPanel,mode=mode,popvalue=match
		
				// angleErrorsPercent is used for % of angle, for +constant, and +/- constant.
				// it is hidden for all other modes.
				disableSetVar= 1	// hide
				disableSetVarUnits= 1	// hide
				String titleSetVarUnits="%" // or "degrees"
				disableWavePops= 1	// hide
				disableCapWidth= 0	// show
				title= "Angle +/-"
				value=NaN
				minimum=0
				maximum=inf
				strswitch(angleErrorBarsMode)
					case "% of angle":
						disableSetVar = 0	// show
						disableSetVarUnits = 0	// show
						value= angleErrorBarsPercent
						minimum= -100	// %
						maximum= 100	// %
						break
					case "+ constant":
						title= "Angle +"
						minimum= -inf
						// FALL THROUGH
					case "+/- constant":
						disableSetVar = 0	// show the constant value, and "degrees" instead of "%"
						value= angleErrorBarsConstant
						disableSetVarUnits= 0	// show
						titleSetVarUnits="deg"
						break
					case "+/- wave":
						disableWavePops= 0	// show
						break
					default:
						Print "Bug in WMPolarUpdateErrorBarsPanel()!"; Beep
						// FALL THROUGH
					case "None":
						disableCapWidth= 1	// hide
						break
					case "sqrt of angle":
						break
				endswitch
				// Angle  +/- Constant (degrees) or %
				SetVariable angleErrorsPercent,win=WMPolarErrorBarsPanel,title=title,limits={minimum,maximum,0},value= _NUM:value, disable= disableSetVar
				TitleBox angleErrorsPercentUnits,win=WMPolarErrorBarsPanel, title=titleSetVarUnits, disable= disableSetVarUnits
	
				// Angle +/- Waves (degrees)
				leafName= WMPolarGetUnquotedLeafName(angleErrorBarsPlusWavePath)
				PopupMenu angleErrorsPlusWave,win=WMPolarErrorBarsPanel, popvalue=leafName, popmatch=leafname, disable= disableWavePops
				leafName= WMPolarGetUnquotedLeafName(angleErrorBarsMinusWavePath)
				PopupMenu angleErrorsMinusWave,win=WMPolarErrorBarsPanel, popvalue=leafName, popmatch=leafname, disable= disableWavePops
	
				// Angle Cap width
				SetVariable angleErrorsCapWidth,win=WMPolarErrorBarsPanel,value= _STR:angleErrorBarsCapWidthStr, disable= disableCapWidth
				if( WMPolarIsValidCapWidth(angleErrorBarsCapWidthStr) )
					SetVariable angleErrorsCapWidth,win=WMPolarErrorBarsPanel,valueColor=(0,0,0),fColor=(0,0,0)
					TitleBox angleErrorsCapWidthUnits,win=WMPolarErrorBarsPanel,fColor=(0,0,0)
				else
					error= "Expected \"Auto\" or points > 0"
					SetVariable angleErrorsCapWidth,win=WMPolarErrorBarsPanel,valueColor=(65535,0,0),fColor=(65535,0,0)
					TitleBox angleErrorsCapWidthUnits,win=WMPolarErrorBarsPanel,fColor=(65535,0,0)
				endif
				TitleBox angleErrorsCapWidthUnits,win=WMPolarErrorBarsPanel, disable= disableCapWidth
			endif
		endif
	endif
	
	TitleBox error,win=WMPolarErrorBarsPanel,title=error
// TitleBox error,win=WMPolarErrorBarsPanel,title="error here", disable=0
	if( updateErrorBarsToo )
		WMPolarModifyErrorBars(graphName,polarTraceName)
	endif
End


Function WMPolarErrorBarsPanelHook(infoStr)
	String infoStr

	Variable statusCode= 0
	String event= StringByKey("EVENT",infoStr)
	String win= StringByKey("WINDOW",infoStr)
	strswitch(event)
		case "activate":
			WMPolarUpdateErrorBarsPanel(0)
			break
	endswitch
	Variable coordinateStatus= WC_WindowCoordinatesHook(infoStr)
	if( statusCode == 0 )
		statusCode= coordinateStatus
	endif

	return statusCode				// 0 if nothing done, else 1 or 2
End

Function WMPolarErrorBarsTracePopup(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String graphName= WMPolarTopPolarGraph()
	if( strlen(graphName) == 0 )
		WMPolarUpdateErrorBarsPanel(0)	// will close down the panel
		return 0
	endif
	
	ControlInfo/W=WMPolarErrorBarsPanel mainModifyTracePop
	if( V_Flag < 0 )
		return 0		// programming error
	endif
	String polarTraceName= S_value
	WMPolarUpdateErrorBarsPanel(1)
End

// General Error Bars Controls

Function WMPolarErrorBarsRadioProc(ctrlName,checked) : CheckBoxControl
	String ctrlName	// colorFromPopup;colorFromTrace;
	Variable checked

	CheckBox colorFromTrace,win=WMPolarErrorBarsPanel,value=CmpStr(ctrlName,"colorFromTrace") == 0
	CheckBox colorFromPopup,win=WMPolarErrorBarsPanel,value=CmpStr(ctrlName,"colorFromPopup") == 0

	String graphName= WMPolarTopPolarGraph()
	if( strlen(graphName) == 0 )
		WMPolarUpdateErrorBarsPanel(0)	// will close down the panel
		return 0
	endif
	
	ControlInfo/W=WMPolarErrorBarsPanel mainModifyTracePop
	if( V_Flag < 0 )
		return 0		// programming error
	endif
	String polarTraceName= S_value

	Variable errorBarsCapThickness, errorBarsBarThickness, colorFromTraceRadio
	String errorBarsColorsString
	String df= WMPolarGetTraceErrorBars(graphName,polarTraceName,errorBarsCapThickness,errorBarsBarThickness,colorFromTraceRadio,errorBarsColorsString)
	if( strlen(df) )
		colorFromTraceRadio= CmpStr(ctrlName,"colorFromTrace") == 0
		WMPolarSetTraceErrorBars(graphName,polarTraceName,errorBarsCapThickness,errorBarsBarThickness,colorFromTraceRadio,errorBarsColorsString)
		WMPolarUpdateErrorBarsPanel(1)
	endif
End

Function WMPolarErrorBarsColorPopup(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String graphName= WMPolarTopPolarGraph()
	if( strlen(graphName) == 0 )
		WMPolarUpdateErrorBarsPanel(0)	// will close down the panel
		return 0
	endif
	
	ControlInfo/W=WMPolarErrorBarsPanel mainModifyTracePop
	if( V_Flag < 0 )
		return 0		// programming error
	endif
	String polarTraceName= S_value

	Variable errorBarsCapThickness, errorBarsBarThickness, colorFromTraceRadio
	String errorBarsColorsString
	String df= WMPolarGetTraceErrorBars(graphName,polarTraceName,errorBarsCapThickness,errorBarsBarThickness,colorFromTraceRadio,errorBarsColorsString)
	if( strlen(df) )
		ControlInfo/W=WMPolarErrorBarsPanel $ctrlName
		errorBarsColorsString= S_Value	// S_Value has parentheses around the colors, ex: "(0,0,0)"
		CheckBox colorFromTrace,win=WMPolarErrorBarsPanel,value=0
		CheckBox colorFromPopup,win=WMPolarErrorBarsPanel,value=1
		colorFromTraceRadio= 0
		WMPolarSetTraceErrorBars(graphName,polarTraceName,errorBarsCapThickness,errorBarsBarThickness,colorFromTraceRadio,errorBarsColorsString)
		WMPolarUpdateErrorBarsPanel(1)
	endif
End

Function WMPolarErrorBarsCapThickProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	String graphName= WMPolarTopPolarGraph()
	if( strlen(graphName) == 0 )
		WMPolarUpdateErrorBarsPanel(0)	// will close down the panel
		return 0
	endif
	
	ControlInfo/W=WMPolarErrorBarsPanel mainModifyTracePop
	if( V_Flag < 0 )
		return 0		// programming error
	endif
	String polarTraceName= S_value

	Variable errorBarsCapThickness, errorBarsBarThickness, colorFromTraceRadio
	String errorBarsColorsString
	String df= WMPolarGetTraceErrorBars(graphName,polarTraceName,errorBarsCapThickness,errorBarsBarThickness,colorFromTraceRadio,errorBarsColorsString)
	if( strlen(df) )
		errorBarsCapThickness= varNum	// even if invalid, so that WMPolarUpdateErrorBarsPanel() can indicate the error
		WMPolarSetTraceErrorBars(graphName,polarTraceName,errorBarsCapThickness,errorBarsBarThickness,colorFromTraceRadio,errorBarsColorsString)
		WMPolarUpdateErrorBarsPanel(1)
	endif
End

Function WMPolarErrorBarsBarThickProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	String graphName= WMPolarTopPolarGraph()
	if( strlen(graphName) == 0 )
		WMPolarUpdateErrorBarsPanel(0)	// will close down the panel
		return 0
	endif
	
	ControlInfo/W=WMPolarErrorBarsPanel mainModifyTracePop
	if( V_Flag < 0 )
		return 0		// programming error
	endif
	String polarTraceName= S_value

	Variable errorBarsCapThickness, errorBarsBarThickness, colorFromTraceRadio
	String errorBarsColorsString
	String df= WMPolarGetTraceErrorBars(graphName,polarTraceName,errorBarsCapThickness,errorBarsBarThickness,colorFromTraceRadio,errorBarsColorsString)
	if( strlen(df) )
		errorBarsBarThickness= varNum	// even if invalid, so that WMPolarUpdateErrorBarsPanel() can indicate the error
		WMPolarSetTraceErrorBars(graphName,polarTraceName,errorBarsCapThickness,errorBarsBarThickness,colorFromTraceRadio,errorBarsColorsString)
		WMPolarUpdateErrorBarsPanel(1)
	endif
End

// Radius Error Bars Controls

Function WMPolarErrorBarsRadiusModeProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String graphName= WMPolarTopPolarGraph()
	if( strlen(graphName) == 0 )
		WMPolarUpdateErrorBarsPanel(0)	// will close down the panel
		return 0
	endif
	
	ControlInfo/W=WMPolarErrorBarsPanel mainModifyTracePop
	if( V_Flag < 0 )
		return 0		// programming error
	endif
	String polarTraceName= S_value

	// Radius Error Bars
	String radiusErrorBarsX,radiusErrorBarsY,radiusErrorBarsMrkZ
	String radiusErrorBarsMode, radiusErrorBarsPlusWavePath, radiusErrorBarsMinusWavePath, radiusErrorBarsCapWidthStr
	Variable radiusErrorBarsPercent, radiusErrorBarsConstant

	String df= WMPolarGetTraceRadiusErrorBars(graphName,polarTraceName,radiusErrorBarsX,radiusErrorBarsY,radiusErrorBarsMrkZ,radiusErrorBarsMode,radiusErrorBarsPercent,radiusErrorBarsConstant,radiusErrorBarsPlusWavePath,radiusErrorBarsMinusWavePath,radiusErrorBarsCapWidthStr)
	if( strlen(df) )
		radiusErrorBarsMode= popStr
		WMPolarSetTraceRadiusErrorBars(graphName,polarTraceName,radiusErrorBarsX,radiusErrorBarsY,radiusErrorBarsMrkZ,radiusErrorBarsMode,radiusErrorBarsPercent,radiusErrorBarsConstant,radiusErrorBarsPlusWavePath,radiusErrorBarsMinusWavePath,radiusErrorBarsCapWidthStr)

		WMPolarUpdateErrorBarsPanel(1)
	endif
	return 0
End

// this proc actually handles +/- constant, +constant, and +/- %
Function WMPolarErrorBarsPercentProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	String graphName= WMPolarTopPolarGraph()
	if( strlen(graphName) == 0 )
		WMPolarUpdateErrorBarsPanel(0)	// will close down the panel
		return 0
	endif
	
	ControlInfo/W=WMPolarErrorBarsPanel mainModifyTracePop
	if( V_Flag < 0 )
		return 0		// programming error
	endif
	String polarTraceName= S_value

	// Radius Error Bars
	String radiusErrorBarsX,radiusErrorBarsY,radiusErrorBarsMrkZ
	String radiusErrorBarsMode, radiusErrorBarsPlusWavePath, radiusErrorBarsMinusWavePath, radiusErrorBarsCapWidthStr
	Variable radiusErrorBarsPercent, radiusErrorBarsConstant

	String df= WMPolarGetTraceRadiusErrorBars(graphName,polarTraceName,radiusErrorBarsX,radiusErrorBarsY,radiusErrorBarsMrkZ,radiusErrorBarsMode,radiusErrorBarsPercent,radiusErrorBarsConstant,radiusErrorBarsPlusWavePath,radiusErrorBarsMinusWavePath,radiusErrorBarsCapWidthStr)
	if( strlen(df) )
		strswitch(radiusErrorBarsMode)
			case "% of radius":
				radiusErrorBarsPercent= varNum	// even if not valid! This allows WMPolarUpdateErrorBarsPanel() to indicate an error
				break
			case "+ constant":
			case "+/- constant":
				radiusErrorBarsConstant= varNum	// even if not valid! This allows WMPolarUpdateErrorBarsPanel() to indicate an error
				break
			default:
				Print "Bug in WMPolarErrorBarsPercentProc()!"; Beep
				break
		endswitch
		
		WMPolarSetTraceRadiusErrorBars(graphName,polarTraceName,radiusErrorBarsX,radiusErrorBarsY,radiusErrorBarsMrkZ,radiusErrorBarsMode,radiusErrorBarsPercent,radiusErrorBarsConstant,radiusErrorBarsPlusWavePath,radiusErrorBarsMinusWavePath,radiusErrorBarsCapWidthStr)

		WMPolarUpdateErrorBarsPanel(1)
	endif
	return 0
End

Function/S WMPolarSelectedWavesPath(wavesNameOrNone)	// returns "_none_" or full path to wave
	String wavesNameOrNone
	
	WAVE/Z w=$wavesNameOrNone
	if( WaveExists(w) )
		wavesNameOrNone= GetWavesDataFolder(w,2)
	endif
	return wavesNameOrNone
End

Function WMPolarErrorBarsPlusWaveProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String graphName= WMPolarTopPolarGraph()
	if( strlen(graphName) == 0 )
		WMPolarUpdateErrorBarsPanel(0)	// will close down the panel
		return 0
	endif
	
	ControlInfo/W=WMPolarErrorBarsPanel mainModifyTracePop
	if( V_Flag < 0 )
		return 0		// programming error
	endif
	String polarTraceName= S_value

	// Radius Error Bars
	String radiusErrorBarsX,radiusErrorBarsY,radiusErrorBarsMrkZ
	String radiusErrorBarsMode, radiusErrorBarsPlusWavePath, radiusErrorBarsMinusWavePath, radiusErrorBarsCapWidthStr
	Variable radiusErrorBarsPercent, radiusErrorBarsConstant

	String df= WMPolarGetTraceRadiusErrorBars(graphName,polarTraceName,radiusErrorBarsX,radiusErrorBarsY,radiusErrorBarsMrkZ,radiusErrorBarsMode,radiusErrorBarsPercent,radiusErrorBarsConstant,radiusErrorBarsPlusWavePath,radiusErrorBarsMinusWavePath,radiusErrorBarsCapWidthStr)
	if( strlen(df) )
		radiusErrorBarsPlusWavePath= WMPolarSelectedWavesPath(popStr)	// returns "_none_" or full path to wave
		WMPolarSetTraceRadiusErrorBars(graphName,polarTraceName,radiusErrorBarsX,radiusErrorBarsY,radiusErrorBarsMrkZ,radiusErrorBarsMode,radiusErrorBarsPercent,radiusErrorBarsConstant,radiusErrorBarsPlusWavePath,radiusErrorBarsMinusWavePath,radiusErrorBarsCapWidthStr)

		WMPolarUpdateErrorBarsPanel(1)
	endif
	return 0
End

Function WMPolarErrorBarsMinusWaveProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String graphName= WMPolarTopPolarGraph()
	if( strlen(graphName) == 0 )
		WMPolarUpdateErrorBarsPanel(0)	// will close down the panel
		return 0
	endif
	
	ControlInfo/W=WMPolarErrorBarsPanel mainModifyTracePop
	if( V_Flag < 0 )
		return 0		// programming error
	endif
	String polarTraceName= S_value

	// Radius Error Bars
	String radiusErrorBarsX,radiusErrorBarsY,radiusErrorBarsMrkZ
	String radiusErrorBarsMode, radiusErrorBarsPlusWavePath, radiusErrorBarsMinusWavePath, radiusErrorBarsCapWidthStr
	Variable radiusErrorBarsPercent, radiusErrorBarsConstant

	String df= WMPolarGetTraceRadiusErrorBars(graphName,polarTraceName,radiusErrorBarsX,radiusErrorBarsY,radiusErrorBarsMrkZ,radiusErrorBarsMode,radiusErrorBarsPercent,radiusErrorBarsConstant,radiusErrorBarsPlusWavePath,radiusErrorBarsMinusWavePath,radiusErrorBarsCapWidthStr)
	if( strlen(df) )
		radiusErrorBarsMinusWavePath= WMPolarSelectedWavesPath(popStr)	// returns "_none_" or full path to wave
		WMPolarSetTraceRadiusErrorBars(graphName,polarTraceName,radiusErrorBarsX,radiusErrorBarsY,radiusErrorBarsMrkZ,radiusErrorBarsMode,radiusErrorBarsPercent,radiusErrorBarsConstant,radiusErrorBarsPlusWavePath,radiusErrorBarsMinusWavePath,radiusErrorBarsCapWidthStr)

		WMPolarUpdateErrorBarsPanel(1)
	endif
	return 0
End

// return 1 if "Auto", else 0
Function WMPolarIsAutoStr(str)
	String str
	
	str= ReplaceString(" ", str, "")
	return CmpStr(str[0,3],"Auto") == 0 
End

Function WMPolarIsValidCapWidth(str)
	String str
	
	if( WMPolarIsAutoStr(str) )
		return 1
	endif
	Variable num= str2num(str)
	Variable isNum = numtype(num) == 0	// that is, it isn't NaN or +/- inf
	return isNum && num >= 0
End

Function WMPolarCapWidthPoints(errorBarsCapWidthStr)
	String errorBarsCapWidthStr

	Variable capWidthPoints 
	if( WMPolarIsAutoStr(errorBarsCapWidthStr) )
		capWidthPoints= 0	// auto marker size
	else
		capWidthPoints= str2num(errorBarsCapWidthStr)	// user entered value, can be blank, naN, inf, etc
		if(  capWidthPoints > 10 )	// true if user enters "Inf"
			capWidthPoints= 10	// maximum marker size
		endif
		if( (numtype(capWidthPoints) != 0) || (capWidthPoints < 0) )
			capWidthPoints= 0	// auto marker size
		endif
	endif
	return capWidthPoints
End

Function WMPolarRadiusErrorBarsCapWidth(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	String graphName= WMPolarTopPolarGraph()
	if( strlen(graphName) == 0 )
		WMPolarUpdateErrorBarsPanel(0)	// will close down the panel
		return 0
	endif
	
	ControlInfo/W=WMPolarErrorBarsPanel mainModifyTracePop
	if( V_Flag < 0 )
		return 0		// programming error
	endif
	String polarTraceName= S_value

	// Radius Error Bars
	String radiusErrorBarsX,radiusErrorBarsY,radiusErrorBarsMrkZ
	String radiusErrorBarsMode, radiusErrorBarsPlusWavePath, radiusErrorBarsMinusWavePath, radiusErrorBarsCapWidthStr
	Variable radiusErrorBarsPercent, radiusErrorBarsConstant

	String df= WMPolarGetTraceRadiusErrorBars(graphName,polarTraceName,radiusErrorBarsX,radiusErrorBarsY,radiusErrorBarsMrkZ,radiusErrorBarsMode,radiusErrorBarsPercent,radiusErrorBarsConstant,radiusErrorBarsPlusWavePath,radiusErrorBarsMinusWavePath,radiusErrorBarsCapWidthStr)
	if( strlen(df) )
		radiusErrorBarsCapWidthStr= varStr	// even if not valid! This allows WMPolarUpdateErrorBarsPanel() to indicate an error
		WMPolarSetTraceRadiusErrorBars(graphName,polarTraceName,radiusErrorBarsX,radiusErrorBarsY,radiusErrorBarsMrkZ,radiusErrorBarsMode,radiusErrorBarsPercent,radiusErrorBarsConstant,radiusErrorBarsPlusWavePath,radiusErrorBarsMinusWavePath,radiusErrorBarsCapWidthStr)

		WMPolarUpdateErrorBarsPanel(1)
	endif
	return 0
End

// End Radius Error Bars


// Start Angle Error Bars

Function WMPolarErrorBarsAngleModeProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String graphName= WMPolarTopPolarGraph()
	if( strlen(graphName) == 0 )
		WMPolarUpdateErrorBarsPanel(0)	// will close down the panel
		return 0
	endif
	
	ControlInfo/W=WMPolarErrorBarsPanel mainModifyTracePop
	if( V_Flag < 0 )
		return 0		// programming error
	endif
	String polarTraceName= S_value

	// Angle Error Bars
	String angleErrorBarsX, angleErrorBarsY, angleErrorBarsMrkZ
	String angleErrorBarsMode, angleErrorBarsPlusWavePath, angleErrorBarsMinusWavePath, angleErrorBarsCapWidthStr
	Variable angleErrorBarsPercent, angleErrorBarsConstant

	String df= WMPolarGetTraceAngleErrorBars(graphName,polarTraceName,angleErrorBarsX,angleErrorBarsY,angleErrorBarsMrkZ,angleErrorBarsMode,angleErrorBarsPercent,angleErrorBarsConstant,angleErrorBarsPlusWavePath,angleErrorBarsMinusWavePath,angleErrorBarsCapWidthStr)
	if( strlen(df) )
		angleErrorBarsMode= popStr
		WMPolarSetTraceAngleErrorBars(graphName,polarTraceName,angleErrorBarsX,angleErrorBarsY,angleErrorBarsMrkZ,angleErrorBarsMode,angleErrorBarsPercent,angleErrorBarsConstant,angleErrorBarsPlusWavePath,angleErrorBarsMinusWavePath,angleErrorBarsCapWidthStr)

		WMPolarUpdateErrorBarsPanel(1)
	endif
	return 0
End

Function WMPolarAngErrorBarsPercentProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	String graphName= WMPolarTopPolarGraph()
	if( strlen(graphName) == 0 )
		WMPolarUpdateErrorBarsPanel(0)	// will close down the panel
		return 0
	endif
	
	ControlInfo/W=WMPolarErrorBarsPanel mainModifyTracePop
	if( V_Flag < 0 )
		return 0		// programming error
	endif
	String polarTraceName= S_value

	// Angle Error Bars
	String angleErrorBarsX, angleErrorBarsY, angleErrorBarsMrkZ
	String angleErrorBarsMode, angleErrorBarsPlusWavePath, angleErrorBarsMinusWavePath, angleErrorBarsCapWidthStr
	Variable angleErrorBarsPercent, angleErrorBarsConstant

	String df= WMPolarGetTraceAngleErrorBars(graphName,polarTraceName,angleErrorBarsX,angleErrorBarsY,angleErrorBarsMrkZ,angleErrorBarsMode,angleErrorBarsPercent,angleErrorBarsConstant,angleErrorBarsPlusWavePath,angleErrorBarsMinusWavePath,angleErrorBarsCapWidthStr)
	if( strlen(df) )
		strswitch(angleErrorBarsMode)
			case "% of radius":
				angleErrorBarsPercent= varNum	// even if not valid! This allows WMPolarUpdateErrorBarsPanel() to indicate an error
				break
			case "+ constant":
			case "+/- constant":
				angleErrorBarsConstant= varNum	// even if not valid! This allows WMPolarUpdateErrorBarsPanel() to indicate an error
				break
			default:
				Print "Bug in WMPolarAngErrorBarsPercentProc()!"; Beep
				break
		endswitch
		
		WMPolarSetTraceAngleErrorBars(graphName,polarTraceName,angleErrorBarsX,angleErrorBarsY,angleErrorBarsMrkZ,angleErrorBarsMode,angleErrorBarsPercent,angleErrorBarsConstant,angleErrorBarsPlusWavePath,angleErrorBarsMinusWavePath,angleErrorBarsCapWidthStr)

		WMPolarUpdateErrorBarsPanel(1)
	endif
	return 0
End

Function WMPolarAngErrorBarsPlusWaveProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String graphName= WMPolarTopPolarGraph()
	if( strlen(graphName) == 0 )
		WMPolarUpdateErrorBarsPanel(0)	// will close down the panel
		return 0
	endif
	
	ControlInfo/W=WMPolarErrorBarsPanel mainModifyTracePop
	if( V_Flag < 0 )
		return 0		// programming error
	endif
	String polarTraceName= S_value

	// Angle Error Bars
	String angleErrorBarsX, angleErrorBarsY, angleErrorBarsMrkZ
	String angleErrorBarsMode, angleErrorBarsPlusWavePath, angleErrorBarsMinusWavePath, angleErrorBarsCapWidthStr
	Variable angleErrorBarsPercent, angleErrorBarsConstant

	String df= WMPolarGetTraceAngleErrorBars(graphName,polarTraceName,angleErrorBarsX,angleErrorBarsY,angleErrorBarsMrkZ,angleErrorBarsMode,angleErrorBarsPercent,angleErrorBarsConstant,angleErrorBarsPlusWavePath,angleErrorBarsMinusWavePath,angleErrorBarsCapWidthStr)
	if( strlen(df) )
		angleErrorBarsPlusWavePath= WMPolarSelectedWavesPath(popStr)	// returns "_none_" or full path to wave
		WMPolarSetTraceAngleErrorBars(graphName,polarTraceName,angleErrorBarsX,angleErrorBarsY,angleErrorBarsMrkZ,angleErrorBarsMode,angleErrorBarsPercent,angleErrorBarsConstant,angleErrorBarsPlusWavePath,angleErrorBarsMinusWavePath,angleErrorBarsCapWidthStr)

		WMPolarUpdateErrorBarsPanel(1)
	endif
	return 0
End

Function WMPolarAngErrorBarsMinusWavePrc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String graphName= WMPolarTopPolarGraph()
	if( strlen(graphName) == 0 )
		WMPolarUpdateErrorBarsPanel(0)	// will close down the panel
		return 0
	endif
	
	ControlInfo/W=WMPolarErrorBarsPanel mainModifyTracePop
	if( V_Flag < 0 )
		return 0		// programming error
	endif
	String polarTraceName= S_value

	// Angle Error Bars
	String angleErrorBarsX, angleErrorBarsY, angleErrorBarsMrkZ
	String angleErrorBarsMode, angleErrorBarsPlusWavePath, angleErrorBarsMinusWavePath, angleErrorBarsCapWidthStr
	Variable angleErrorBarsPercent, angleErrorBarsConstant

	String df= WMPolarGetTraceAngleErrorBars(graphName,polarTraceName,angleErrorBarsX,angleErrorBarsY,angleErrorBarsMrkZ,angleErrorBarsMode,angleErrorBarsPercent,angleErrorBarsConstant,angleErrorBarsPlusWavePath,angleErrorBarsMinusWavePath,angleErrorBarsCapWidthStr)
	if( strlen(df) )
		angleErrorBarsMinusWavePath= WMPolarSelectedWavesPath(popStr)	// returns "_none_" or full path to wave
		WMPolarSetTraceAngleErrorBars(graphName,polarTraceName,angleErrorBarsX,angleErrorBarsY,angleErrorBarsMrkZ,angleErrorBarsMode,angleErrorBarsPercent,angleErrorBarsConstant,angleErrorBarsPlusWavePath,angleErrorBarsMinusWavePath,angleErrorBarsCapWidthStr)

		WMPolarUpdateErrorBarsPanel(1)
	endif
	return 0
End

Function WMPolarAngleErrorBarsCapWidth(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	String graphName= WMPolarTopPolarGraph()
	if( strlen(graphName) == 0 )
		WMPolarUpdateErrorBarsPanel(0)	// will close down the panel
		return 0
	endif
	
	ControlInfo/W=WMPolarErrorBarsPanel mainModifyTracePop
	if( V_Flag < 0 )
		return 0		// programming error
	endif
	String polarTraceName= S_value

	// Angle Error Bars
	String angleErrorBarsX, angleErrorBarsY, angleErrorBarsMrkZ
	String angleErrorBarsMode, angleErrorBarsPlusWavePath, angleErrorBarsMinusWavePath, angleErrorBarsCapWidthStr
	Variable angleErrorBarsPercent, angleErrorBarsConstant

	String df= WMPolarGetTraceAngleErrorBars(graphName,polarTraceName,angleErrorBarsX,angleErrorBarsY,angleErrorBarsMrkZ,angleErrorBarsMode,angleErrorBarsPercent,angleErrorBarsConstant,angleErrorBarsPlusWavePath,angleErrorBarsMinusWavePath,angleErrorBarsCapWidthStr)
	if( strlen(df) )
		angleErrorBarsCapWidthStr= varStr	// even if not valid! This allows WMPolarUpdateErrorBarsPanel() to indicate an error
		WMPolarSetTraceAngleErrorBars(graphName,polarTraceName,angleErrorBarsX,angleErrorBarsY,angleErrorBarsMrkZ,angleErrorBarsMode,angleErrorBarsPercent,angleErrorBarsConstant,angleErrorBarsPlusWavePath,angleErrorBarsMinusWavePath,angleErrorBarsCapWidthStr)

		WMPolarUpdateErrorBarsPanel(1)
	endif
	return 0
End

// returns "" if the named polar trace doesn't exist in the graph
// returns path to tw wave's data folder if it does.
//
//	Constant kAngleErrorsBarsX = 30			// name of angle error bars X wave, polarAngleErrorBarX0, etc
//	Constant kAngleErrorsBarsY = 31		// name of angle error bars Y wave, polarAngleErrorBarY0, etc
//	Constant kAngleErrorsBarsMrkZ = 32		// name of angle error bars markers f(Z) wave, polarAngleErrorBarZ0, etc
//	Constant kAngleErrorBarsMode= 33		// None;% of Angle;sqrt of Angle;+constant;+/-constant;+/- wave;
//	StrConstant ksAngleErrorBarsModes= "None;% of angle;sqrt of angle;+ constant;+/- constant;+/- wave;"
//	Constant kAngleErrorBarsPercent=34		// 0-1000
//	Constant kAngleErrorBarsConstant=35		// -inf - +inf if +constant, 0 - +inf if +/- constant (or just take abs if +/- constant)
//	Constant kAngleErrorBarsPlusWavePath=36	// full data folder path to +wave or "_none_"
//	Constant kAngleErrorBarsMinusWavePath=37// full data folder path to -wave or "_none_" (there is no "same as Y+" feature)
//	Constant kAngleErrorBarsCapWidth= 38		// ("Auto" else points, this is just the cap marker size, and must be kept up-to-date with msize)

Function/S WMPolarGetTraceAngleErrorBars(graphName,polarTraceName,angleErrorBarsX,angleErrorBarsY,angleErrorBarsMrkZ,angleErrorBarsMode,angleErrorBarsPercent,angleErrorBarsConstant,angleErrorBarsPlusWavePath,angleErrorBarsMinusWavePath,angleErrorBarsCapWidthStr)
	String graphName			// input
	String &polarTraceName		// input/output: polarTraceName is the name of the shadow wave displayed in graphName; any " [angleWaveName]" is removed.
	String &angleErrorBarsX,&angleErrorBarsY,&angleErrorBarsMrkZ	// outputs
	String &angleErrorBarsMode	// output
	Variable &angleErrorBarsPercent	// output
	Variable &angleErrorBarsConstant	// output
	String &angleErrorBarsPlusWavePath	// output
	String &angleErrorBarsMinusWavePath	// output
	String &angleErrorBarsCapWidthStr	// output ("Auto" else degrees)

	// defaults
	angleErrorBarsX= ""
	angleErrorBarsY= ""
	angleErrorBarsMrkZ= ""
	angleErrorBarsMode= "None"
	angleErrorBarsPercent= 5.0
	angleErrorBarsConstant= 0	
	angleErrorBarsPlusWavePath=""
	angleErrorBarsMinusWavePath=""
	angleErrorBarsCapWidthStr= "Auto"

	String path= ""
	WAVE/Z/T tw= $WMPolarGraphTracesTW(graphName)
	
	if( WaveExists(tw) )		// this describes the graph's traces
	 	polarTraceName= WMPolarOnlyTraceName(polarTraceName)	// changes the input parameter!!!!
		WAVE/Z wShadowY= TraceNameToWaveRef(graphName,polarTraceName)	// the trace actually exists
		if( WaveExists(wShadowY) )
			Variable row= WMPolarShadowWaveRow(wShadowY)
			if( row != -1 )		// this wave was found in polarTracesTW
				WMPolarModernizePolarTracesWave(tw)
				angleErrorBarsX= tw[row][kAngleErrorsBarsX]
				angleErrorBarsY= tw[row][kAngleErrorsBarsY]
				angleErrorBarsMrkZ= tw[row][kAngleErrorsBarsMrkZ]
				
				angleErrorBarsMode= tw[row][kAngleErrorBarsMode]
				angleErrorBarsPercent= str2num(tw[row][kAngleErrorBarsPercent])
				angleErrorBarsConstant= str2num(tw[row][kAngleErrorBarsConstant])
				angleErrorBarsPlusWavePath= tw[row][kAngleErrorBarsPlusWavePath]
				angleErrorBarsMinusWavePath= tw[row][kAngleErrorBarsMinusWavePath]
				angleErrorBarsCapWidthStr= tw[row][kAngleErrorBarsCapWidth]	// // ("Auto" else points)

				path= GetWavesDataFolder(tw,1)
			endif
		endif
	endif

	return path
End

// returns "" if the named polar trace doesn't exist in the graph
// returns path to tw wave's data folder if it does.
//
// Angle Error Bars Settings:
//	Constant kAngleErrorsBarsX = 30			// name of angle error bars X wave, polarAngleErrorBarX0, etc
//	Constant kAngleErrorsBarsY = 31		// name of angle error bars Y wave, polarAngleErrorBarY0, etc
//	Constant kAngleErrorsBarsMrkZ = 32		// name of angle error bars markers f(Z) wave, polarAngleErrorBarZ0, etc
//	Constant kAngleErrorBarsMode= 33		// None;% of Angle;sqrt of Angle;+constant;+/-constant;+/- wave;
//	StrConstant ksAngleErrorBarsModes= "None;% of angle;sqrt of angle;+ constant;+/- constant;+/- wave;"
//	Constant kAngleErrorBarsPercent=34		// 0-1000
//	Constant kAngleErrorBarsConstant=35		// -inf - +inf if +constant, 0 - +inf if +/- constant (or just take abs if +/- constant)
//	Constant kAngleErrorBarsPlusWavePath=36	// full data folder path to +wave or "_none_"
//	Constant kAngleErrorBarsMinusWavePath=37// full data folder path to -wave or "_none_" (there is no "same as Y+" feature)
//	Constant kAngleErrorBarsCapWidth= 38		// ("Auto" else points, this is just the cap marker size, and must be kept up-to-date with msize)
Function/S WMPolarSetTraceAngleErrorBars(graphName,polarTraceName,angleErrorBarsX,angleErrorBarsY,angleErrorBarsMrkZ,angleErrorBarsMode,angleErrorBarsPercent,angleErrorBarsConstant,angleErrorBarsPlusWavePath,angleErrorBarsMinusWavePath,angleErrorBarsCapWidthStr)
	String graphName			// input
	String &polarTraceName		//input/output: polarTraceName is the name of the shadow wave displayed in graphName; any " [angleWaveName]" is removed.
	String angleErrorBarsX,angleErrorBarsY,angleErrorBarsMrkZ	// inputs
	String angleErrorBarsMode	// input
	Variable angleErrorBarsPercent	// input
	Variable angleErrorBarsConstant	// input
	String angleErrorBarsPlusWavePath	// input
	String angleErrorBarsMinusWavePath	// input
	String angleErrorBarsCapWidthStr	// input

	String path= ""

	WAVE/Z/T tw= $WMPolarGraphTracesTW(graphName)
	if( WaveExists(tw) )		// this describes the graph's traces
		polarTraceName= WMPolarOnlyTraceName(polarTraceName)	// changes the input parameter!!!!
		WAVE/Z wShadowY= TraceNameToWaveRef(graphName,polarTraceName)
		if( WaveExists(wShadowY) )
			Variable row= WMPolarShadowWaveRow(wShadowY)
			if( row != -1 )		// this wave was found in polarTracesTW
				WMPolarModernizePolarTracesWave(tw)

				tw[row][kAngleErrorsBarsX]= angleErrorBarsX
				tw[row][kAngleErrorsBarsY]= angleErrorBarsY
				tw[row][kAngleErrorsBarsMrkZ]= angleErrorBarsMrkZ

				tw[row][kAngleErrorBarsMode]= angleErrorBarsMode
				tw[row][kAngleErrorBarsPercent]= num2str(angleErrorBarsPercent)
				tw[row][kAngleErrorBarsConstant]= num2str(angleErrorBarsConstant)
				tw[row][kAngleErrorBarsPlusWavePath]= angleErrorBarsPlusWavePath
				tw[row][kAngleErrorBarsMinusWavePath]= angleErrorBarsMinusWavePath
				tw[row][kAngleErrorBarsCapWidth]= angleErrorBarsCapWidthStr	// ("Auto" else points)

				path= GetWavesDataFolder(tw,1)
			endif
		endif
	endif

	return path
End

// END Angle Error Bars

// END Error Bars subpanel

// GENERAL ROUTINES

// returns truth the string is valid
Function WMPolarParseColorStr(str, red, green, blue, alpha)
	String str	// "(0,0,0)" "0,0,0", (0,0,0,65535) or "0,0,0,65535
	Variable &red, &green, &blue, &alpha		// outputs
	
	alpha= 65535
	sscanf str, "(%d,%d,%d,%d)", red, green, blue, alpha
	if( V_Flag != 4 )
		alpha= 65535
		sscanf str, "(%d,%d,%d)", red, green, blue
		if( V_Flag != 3 )
			red= str2num(StringFromList(0,str,","))
			green= str2num(StringFromList(1,str,","))
			blue= str2num(StringFromList(2,str,","))
			String salpha= StringFromList(3,str,",")
			if( strlen(salpha) )
				alpha= str2num(salpha)
			endif
		endif
	endif
	Variable valid= (red >= 0) && (red <= 65535) && (green >= 0) && (green <= 65535) && (blue >= 0) && (blue <= 65535) && (alpha >= 0) && (alpha <= 65535)
	return valid
End

static Function/S WMPolarGetUnquotedLeafName(path)
	String path			// Path to data folder or wave
	
	String name
	name = ParseFilePath(0, path, ":", 1, 0)		// Just the name without path.
	
	// Remove single quotes if present
	if (CmpStr(name[0],"'") == 0)
		Variable len = strlen(name)
		name = name[1,len-2]	
	endif
	
	return name
End

/// Start of code implementing version 9.03's Layers panel and associated controls


// called by mainLayersButton
Function WMPolarLayersPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/F WMPolarGraphLayersPanel
	if( V_Flag == 0 )
		WMPolarShowPolarLayersPanel()
	endif

End

// Layers Panel

Function WMPolarShowPolarLayersPanel()
	
	DoWindow/K WMPolarGraphLayersPanel
	// NewPanel /K=1 /W=(199,107,662,290) as "Polar Graph Layers"  // /W=(left, top, right, bottom )

	Variable defLeft=199	// NewPanel units
	Variable defTop= 107
	Variable defRight= 662
	Variable defBottom= 290

	//WC_WindowCoordinatesForget("WMPolarGraphLayersPanel")
	
	String fmt="NewPanel/K=1/W=(%s)/N=WMPolarGraphLayersPanel as \"Polar Graph Layers\""	// /W=(defLeft,defTop,defRight,defBottom)
	// restore from previous position
	String command= WC_WindowCoordinatesSprintf("WMPolarGraphLayersPanel",fmt,defLeft,defTop,defRight,defBottom,1)
	Execute command
	ModifyPanel/W=WMPolarGraphLayersPanel fixedSize=1, noEdit=1
	
	// 9.03: new controls can't presume global variables exist yet for possibly old data folders.
	CheckBox oneLayerCheck win= WMPolarGraphLayersPanel,pos={22,22},size={14,14},proc=WMPolarLayersRadioProc
	CheckBox oneLayerCheck win= WMPolarGraphLayersPanel,title="",value=0,mode=1

	String path=WMPolarTopOrDefaultDFVar("axesDrawLayer")
	String popVal = StrVarOrDefault(path,"ProgAxes")
	String/G $path= popVal
	Variable whichOne= max(1,1+WhichListItem(popVal, WMPolarGraphDrawLayers()))
	String moduleName= GetIndependentModuleName()+"#"
	command= moduleName+"WMPolarGraphDrawLayers()"
	PopupMenu axesLayer win= WMPolarGraphLayersPanel,pos={38,20},size={384,20},proc=WMPolarAxesLayerPopMenuProc
	PopupMenu axesLayer win= WMPolarGraphLayersPanel,title="Axes, Grid, Labels, and Fills to Zero on One Drawing Layer:"
	PopupMenu axesLayer win= WMPolarGraphLayersPanel,mode=whichOne,popvalue=popVal,value= #command

	CheckBox multiLayersCheck win= WMPolarGraphLayersPanel,pos={22,49},size={244,16},proc=WMPolarLayersRadioProc
	CheckBox multiLayersCheck win= WMPolarGraphLayersPanel,title="Use Multiple Drawing Layers (old method*)"
	CheckBox multiLayersCheck win= WMPolarGraphLayersPanel,value=1,mode=1

	TitleBox oldMethodTitle,win= WMPolarGraphLayersPanel,pos={40,75},size={350,14}
	TitleBox oldMethodTitle,win= WMPolarGraphLayersPanel,title="* Old method uses ProgBack, UserBack, ProgAxes, and UserAxes drawing layers."
	TitleBox oldMethodTitle,win= WMPolarGraphLayersPanel,fSize=10,frame=0,fColor=(1,16019,65535)

	Button commonUpdate,win= WMPolarGraphLayersPanel,pos={42,113},size={148,20},proc=WMPolarUpdateButtonProc
	Button commonUpdate,win= WMPolarGraphLayersPanel,title="Update PolarGraph5"

	CheckBox commonDelayUpdate,win= WMPolarGraphLayersPanel,pos={199,115},size={88,16}
	CheckBox commonDelayUpdate,win= WMPolarGraphLayersPanel,title="Delay Update"
	CheckBox commonDelayUpdate,win= WMPolarGraphLayersPanel,variable=root:Packages:WMPolarGraphs:delayPolarUpdate

	Button help,win= WMPolarGraphLayersPanel,pos={40,154},size={50,20},proc=WMPolarLayerPanelCloseHelp,title="Help"
	Button close,win= WMPolarGraphLayersPanel,pos={373,154},size={50,20},proc=WMPolarLayerPanelCloseHelp,title="Close"

	Button closeGoToModifyPolarGraph,win= WMPolarGraphLayersPanel,pos={151,154},size={130.00,20.00},proc=WMPolarLayerPanelCloseHelp
	Button closeGoToModifyPolarGraph,win= WMPolarGraphLayersPanel,title="Modify Polar Graph"

	SetWindow WMPolarGraphLayersPanel hook(polarLayersPanel)=WMPolarLayerPanelHook
	SetWindow WMPolarGraphLayersPanel hook(windowCoordinates)=WC_WindowCoordinatesNamedHook

	WMPolarUpdateLayerPanel()
End


Function WMPolarLayerPanelHook(s)
	STRUCT WMWinHookStruct &s

	Variable hookResult = 0

	strswitch(s.eventName)
		case "Activate":
			WMPolarUpdateLayerPanel()
			break
	endswitch

	return 0
End

Function WMPolarUpdateLayerPanel()

	DoWindow WMPolarGraphLayersPanel
	if( V_Flag == 0 )
		return 0
	endif
	
	// 9.03: new controls can't presume global variables exist yet for possibly old data folders.
	Variable disable= 2

	String path=WMPolarTopOrDefaultDFVar("axesDrawInOneVirtualLayer")
	Variable axesDrawInOneVirtualLayer = NumVarOrDefault(path,0)	// default to pre-9.03
	Variable/G $path= axesDrawInOneVirtualLayer

	String topPolarGraph=WMPolarTopPolarGraph()
	String winTitle="Polar Graph Layers"
	if( strlen(topPolarGraph) )
		winTitle += " for "+topPolarGraph
		disable = 0
		Button commonUpdate,win= WMPolarGraphLayersPanel,title="Update "+topPolarGraph, disable=0
	else
		Button commonUpdate,win= WMPolarGraphLayersPanel,title="Update Polar Graph", disable=2
	endif
	DoWindow/T WMPolarGraphLayersPanel, winTitle

	CheckBox oneLayerCheck win= WMPolarGraphLayersPanel,variable= $WMPolarTopOrDefaultDFVar("axesDrawInOneVirtualLayer"), disable=disable
	CheckBox multiLayersCheck win= WMPolarGraphLayersPanel,value=!axesDrawInOneVirtualLayer,disable=disable
	
	path=WMPolarTopOrDefaultDFVar("axesDrawLayer")
	String popVal = StrVarOrDefault(path,"ProgAxes")
	String/G $path= popVal
	Variable whichOne= max(2,2+WhichListItem(popVal, WMPolarGraphDrawLayers())) // 1 is (window background), don't select that, nor 0 (title in popup)
	PopupMenu axesLayer win= WMPolarGraphLayersPanel,proc=WMPolarAxesLayerPopMenuProc, disable=disable
	PopupMenu axesLayer win= WMPolarGraphLayersPanel,mode=whichOne,popvalue=popVal
End

Function WMPolarAxesLayerPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String/G $WMPolarTopOrDefaultDFVar("axesDrawLayer") = popStr
	WMPolarAxesRedrawTopGraph()
End

Function WMPolarLayerPanelCloseHelp(ctrlName) : ButtonControl
	String ctrlName

	strswitch(ctrlName)
		case "closeGoToModifyPolarGraph":
			WMPolarGraphs(-1)
			// fall through
		case "close":
			Execute/P/Q/Z "DoWindow/K WMPolarGraphLayersPanel"
			break
		case "help":
			DisplayHelpTopic/K=1/Z "Polar Graphs[Layers Dialog]"
			break
	endswitch
End

Function WMPolarLayersRadioProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	// Switch drawing layer method by setting axesDrawInOneVirtualLayer
	String path = WMPolarTopOrDefaultDFVar("axesDrawInOneVirtualLayer")
	strswitch(ctrlName)
		case "oneLayerCheck":
			CheckBox multiLayersCheck win= WMPolarGraphLayersPanel,value=0
			Variable/G $path = 1
			break
		case "multiLayersCheck":
			CheckBox oneLayerCheck win= WMPolarGraphLayersPanel,value=0
			Variable/G $path = 0
			break
	endswitch
	
	String topPolarGraph=WMPolarTopPolarGraph()
	if( strlen(topPolarGraph) )
		WMPolarAxesRedrawTopGraph()
	endif
End


/// Start of code implementing version 9.03's Image Scaling panel and associated controls

Menu "Graph", dynamic, hideable
	"Show Polar Image Scaling Panel", /Q, WMPolarShowImageScalingPanel($"")
End

// really a graph with controls
Function WMPolarShowImageScalingPanel(WAVE/Z image)

//	DoWindow/K WMPolarImageScalingPanel
	DoWindow/F WMPolarImageScalingPanel
	if( V_Flag )
		return 1
	endif
	
	//Display /W=(24,47,437.25,507.5) as "Image Scaling for Polar Graph" // /W=(left,top,right,bottom)

	Variable defLeft=24	// points
	Variable defTop= 47
	Variable defRight= 437
	Variable defBottom= 508

	//WC_WindowCoordinatesForget("WMPolarImageScalingPanel")
	
	String fmt="Display/K=1/W=(%s)/N=WMPolarImageScalingPanel as \"Image Scaling for Polar Graph\""	// /W=(defLeft,defTop,defRight,defBottom)
	// restore from previous position
	String command= WC_WindowCoordinatesSprintf("WMPolarImageScalingPanel",fmt,defLeft,defTop,defRight,defBottom,0)
	Execute command

	if( WaveExists(image) && DimSize(image,0) > 1  && DimSize(image,1) > 1 ) // that is, it is image-like enough to display as an image
		AppendImage/T image
		WMPolarImageScalingStyle("WMPolarImageScalingPanel") // really a graph
	endif
	
	// PTop
	ControlBar 139
	NewPanel/W=(0.2,0.2,0.8,0.8)/FG=(FL,FT,FR,GT)/HOST=# 
	ModifyPanel frameStyle=1, frameInset=0
	TitleBox imageTitle,pos={19,14},size={36,16},title="Image:",frame=0,anchor=RC
	Button imagePop,pos={63,12},size={400,20},title="Image..."
	
	Button centerByPixels,pos={290,45},size={130,20},proc=WMPolarCenterImageButtonProc
	Button centerByPixels,title="Center Image Scaling"

	Button centerAtCursorA,pos={268,77},size={206,20},proc=WMPolarCenterImageButtonProc
	Button centerAtCursorA,title="Center Image Scaling at Cursor A"

	SetVariable xScaleMin,pos={94,110},size={163,19},bodyWidth=80,proc=WMPolarImageScalingSetVarProc
	SetVariable xScaleMin,title="- X Max Radius"
	SetVariable xScaleMin,limits={-inf,inf,0},value=_NUM:-1

	SetVariable xScaleMax,pos={367,110},size={167,19},bodyWidth=80,proc=WMPolarImageScalingSetVarProc
	SetVariable xScaleMax,title="+ X Max Radius"
	SetVariable xScaleMax,limits={-inf,inf,0},value=_NUM:1

	SetVariable pixelDx,pos={21,41},size={184,19},bodyWidth=80,proc=WMPolarImageXYPixelSetVarProc
	SetVariable pixelDx,title="Pixel X Scaling Size",limits={1e-308,inf,0},value=_NUM:1

	CheckBox unequalPixelScalingDisclosure,pos={17,62},size={128,16},proc=WMUnequalPixelScalingDisclosureProc
	CheckBox unequalPixelScalingDisclosure,title="Unequal Pixel Scaling"
	CheckBox unequalPixelScalingDisclosure,value=0,mode=2

	SetVariable pixelDy,pos={31,79},size={184,19},bodyWidth=80,proc=WMPolarImageXYPixelSetVarProc, disable=0 // hidden
	SetVariable pixelDy,title="Pixel Y Scaling Size",limits={1e-308,inf,0},value=_NUM:1

	RenameWindow #,PTop
	SetActiveSubwindow ##

	// PLeft
	ControlBar/L 200
	NewPanel/W=(0.2,0.2,0.8,0.8)/FG=(FL,GT,GL,FB)/HOST=# 
	ModifyPanel frameStyle=1, frameInset=0
	SetDrawLayer UserBack
	Button flipY,pos={49,209},size={90,20},proc=WMPolarGraphImageYFlipButtonProc
	Button flipY,title="Flip Y Scaling"
	SetVariable yScaleMax,pos={13,38},size={163,19},bodyWidth=80,proc=WMPolarImageScalingSetVarProc
	SetVariable yScaleMax,title="+Y Max Radius"
	SetVariable yScaleMax,limits={-inf,inf,0},value=_NUM:1
	SetVariable yScaleMin,pos={17,434},size={159,19},bodyWidth=80,proc=WMPolarImageScalingSetVarProc
	SetVariable yScaleMin,title="-Y Max Radius"
	SetVariable yScaleMin,limits={-inf,inf,0},value=_NUM:-1
	Button appendImageToPolarGraph,pos={37,316},size={130,20},proc=WMPolarGraphAppendImageButtonProc
	Button appendImageToPolarGraph,title="Add to Polar Graph",fStyle=1
	Button appendImageToPolarGraph,fColor=(3,52428,1)
	RenameWindow #,PLeft
	SetActiveSubwindow ##
	
	// Make image wave browser
	command= "WMPolarImagePopupSelectorNotify"	// don't use GetIndependentModuleName()+"#": FUNCRefs aren't cross-IM
	MakeButtonIntoWSPopupButton("WMPolarImageScalingPanel#PTop", "imagePop", command)
	command= "WMPolarImagePopupSelectorFilter"
	PopupWS_MatchOptions("WMPolarImageScalingPanel#PTop", "imagePop", nameFilterProc=command)

	String message = "\\JC\\K(65535,0,0)"
	message += "Make a selection\rfrom the Image popup menu."
	message += "\r\rAdjust the image's X and Y Scaling\rto prepare it for display\rin a polar graph."
	message += "\r\rThen click the Add to Polar Graph button."
	TextBox/W=WMPolarImageScalingPanel/C/N=makeAselection/F=0/A=MC/X=0/Y=0 message

	SetWindow WMPolarImageScalingPanel,hook(WMPolarImageScalingPanel)=WMPolarImageScalingPanelHook
	SetWindow WMPolarImageScalingPanel hook(windowCoordinates)=WC_WindowCoordinatesNamedHook
	WMPolarGraphImageScalingPanelUpdate()

	return 0
End

Function WMPolarImageScalingStyle(String graphName)
	Variable wt= WinType(graphName)
	if( wt == 1 )
		ModifyGraph/W=$graphName margin(left)=28,margin(bottom)=14,margin(top)=28,margin(right)=14,fSize=8

		WAVE/Z image = WMPolarGraphGetImage(graphName, 0)
		if( WaveExists(image) )
			// ModifyGraph/W=$graphName width={Plan,1,top,left}
			ModifyGraph/W=$graphName zero=1,mirror=2,nticks(left)=14,nticks(top)=11
			ModifyGraph/W=$graphName minor=1,standoff=0,tkLblRot(left)=90,btLen=3,tlOffset=-2
			ModifyGraph/W=$graphName height={Plan,1,left,top}
			String imageName= NameOfWave(image)
			ModifyImage/W=$graphName $imageName ctab= {*,*,Turbo,0} // TO DO: save and restore last used color table
			Cursor/I/F/H=1/W=$graphName A $imageName 0,0
			ShowInfo/W=$graphName/CP=0
		endif
	endif
End

Function WMPolarImageReplaceImage(WAVE/Z image) // $"" to remove the image from the "panel"

	WAVE/Z oldImage = WMPolarGetImageScalingPanelImage()
	if( WaveExists(oldImage) && WaveExists(image) )
		ReplaceWave/W=WMPolarImageScalingPanel image=$NameOfWave(oldImage), image
	else
		if( WaveExists(oldImage) )
			RemoveImage/W=WMPolarImageScalingPanel $NameOfWave(oldImage)
		elseif( WaveExists(image) )
			AppendImage/T/W=WMPolarImageScalingPanel image
			DoUpdate/W=WMPolarImageScalingPanel
			WMPolarImageScalingStyle("WMPolarImageScalingPanel")
		endif
	endif
	WMPolarGraphImageScalingPanelUpdate()
End

Function WMPolarImageScalingPanelHook(s)
	STRUCT WMWinHookStruct &s

	Variable hookResult = 0

	strswitch(s.eventName)
		case "activate":
			WMPolarGraphImageScalingPanelUpdate()
			break

		case "resize":
			WMPolarImageScalingPanelResize()
			break

	endswitch

	return hookResult		// 0 if nothing done, else 1
End

Function/WAVE WMPolarGetImageScalingPanelImage()

	Variable wt = Wintype("WMPolarImageScalingPanel")
	WAVE/Z image
	if( wt == 1 )
		WAVE/Z image= WMPolarGraphGetImage("WMPolarImageScalingPanel", 0)
	endif
	return image
End

Function/WAVE WMPolarGraphGetImage(String graphName, Variable zbIndex)

	String images= ImageNameList(graphName, ";")
	Variable numImages= ItemsInList(images)
	if( zbIndex < 0 || zbIndex >= numImages )
		return $""
	endif
	String imageInstanceName= StringFromList(zbIndex,images)
	WAVE/Z image= ImageNameToWaveRef(graphName, imageInstanceName )
	return image
End


Function WMPolarImageScalingSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	WAVE/Z image=WMPolarGetImageScalingPanelImage()
	if( !WaveExists(image) )
		return 0
	endif

	Variable xFirst= DimOffset(image,0)
	Variable xLast= DimDelta(image,0)*(DimSize(image,0)-1)
	String xUnits= WaveUnits(image,0)
			
	Variable yFirst= DimOffset(image,1)
	Variable yLast= DimDelta(image,1)*(DimSize(image,1)-1)
	String yUnits= WaveUnits(image,1)

	// apply the new X or Y extrema value to the image scaling
	// without adjusting the center or the other end.
	// this changes the DimDelta
	strswitch(ctrlName)
		case "xScaleMin":
			SetScale/I x,varNum,xLast,xUnits, image
			break
		case "xScaleMax":
			SetScale/I x,xFirst,varNum,xUnits, image
			break
		case "yScaleMin": // reverse
			SetScale/I y,yFirst,varNum,yUnits, image
			break
		case "yScaleMax":
			SetScale/I y,varNum,yLast,yUnits, image
			break
	endswitch
 	WMPolarGraphImageScalingPanelUpdate() // update pixel dx, dy
	return 1
End


Function WMPolarCenterImageButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	WAVE/Z image=WMPolarGetImageScalingPanelImage()
	if( !WaveExists(image) )
		return 0
	endif
	
	Variable xRows= DimSize(image,0)
	Variable yCols= DimSize(image,1)
	
	String xUnits= WaveUnits(image,0)
	String yUnits= WaveUnits(image,1)
	
	strswitch(ctrlName)
		case "centerByPixels":
			
			// apply Pixel X and Y Scaling from the panel, keeping the image's existing polarity

			ControlInfo/W=WMPolarImageScalingPanel#PTop pixelDx
			Variable dx = abs(V_Value) // absolute value of (possibly new) xDelta
			Variable dy = dx			// absolute value of (possibly new) yDelta
	
			ControlInfo/W=WMPolarImageScalingPanel#PTop unequalPixelScalingDisclosure
			if( V_Value )
				ControlInfo/W=WMPolarImageScalingPanel#PTop pixelDy
				dy = abs(V_Value)
			endif
			dx *= sign(DimDelta(image,0))
			dy *= sign(DimDelta(image,1))
						
			Variable xd2 = (xRows-1)/2 * dx
			Variable yd2 = (yCols-1)/2 * dy
			SetScale/I x, -xd2, xd2, xUnits, image
			SetScale/I y, -yd2, yd2, yUnits, image // reversed
			break
		case "centerAtCursorA":
			if( WaveExists(CsrWaveRef(A,"WMPolarImageScalingPanel")) )
				Variable xA = hcsr(A,"WMPolarImageScalingPanel")
				Variable rowA = pcsr(A,"WMPolarImageScalingPanel")
				Variable x0 = DimOffset(image,0) - xA
				SetScale/P x, x0, DimDelta(image,0), xUnits, image
				
				Variable yA = vcsr(A,"WMPolarImageScalingPanel")
				Variable colA = qcsr(A,"WMPolarImageScalingPanel")
				Variable y0 = DimOffset(image,1) - yA
				SetScale/P y, y0, DimDelta(image,1), yUnits, image
			endif
			break
	endswitch
	WMPolarGraphImageScalingPanelUpdate()
	return 1
End

Function WMPolarGraphImageScalingPanelUpdate()
	Variable wt = Wintype("WMPolarImageScalingPanel")
	if( wt != 1 )
		return -1
	endif
	
	Variable yCols,yScaleMin,yScaleMax
	Variable xRows,xScaleMin,xScaleMax
	Variable xDelta, yDelta
	Variable disable = 2 // shown, disabled

	// Initially no image wave is displayed
	WAVE/Z image=WMPolarGetImageScalingPanelImage()
	Variable haveImage = WaveExists(image)
	if( haveImage )
		disable = 0 // shown, enabled
		xRows= DimSize(image,0)
		xScaleMin= DimOffset(image,0)
		xDelta= DimDelta(image,0)
		xScaleMax= DimOffset(image,0) + xDelta*(xRows-1)

		yCols= DimSize(image,1)
		yDelta= DimDelta(image,1)
		yScaleMin= DimOffset(image,1) + yDelta*(yCols-1) // should be less than yScaleMax
		yScaleMax= DimOffset(image,1)

		TextBox/K/W=WMPolarImageScalingPanel/N=makeAselection
	else
		xScaleMin= NaN; xScaleMax= NaN
		yScaleMin= NaN; yScaleMax= NaN
		xDelta= NaN; yDelta= NaN
	endif

	String win= "WMPolarImageScalingPanel#PLeft"

	Button flipY,win=$win, disable=disable

	String title="Add to Polar Graph"
	String graph= WMPolarTopPolarGraph()
	if( strlen(graph) && haveImage )
		// Don't append image to top polar graph if it already has an image
		WAVE/Z polarGraphImage= WMPolarGraphGetImage(graph, 0)
		if( !WaveExists(polarGraphImage) )
			title= "Add to "+graph
		endif
	endif	
	Button appendImageToPolarGraph,win=$win,title=title, disable=disable

	SetVariable yScaleMin,win=$win,value=_NUM:yScaleMin, disable=disable
	SetVariable yScaleMax,win=$win,value=_NUM:yScaleMax, disable=disable

	win= "WMPolarImageScalingPanel#PTop"
	SetVariable xScaleMin,win=$win,value=_NUM:xScaleMin, disable=disable
	SetVariable xScaleMax,win=$win,value=_NUM:xScaleMax, disable=disable

	SetVariable pixelDx,win=$win,value=_NUM:abs(xDelta), disable=disable
	CheckBox unequalPixelScalingDisclosure,win=$win,disable=disable
	ControlInfo/W=$win unequalPixelScalingDisclosure
	Variable dYdisable = V_Value ? disable : 1 // hide ydx if unequal scaling unchecked (not "revealed")
	SetVariable pixelDy,win=$win,value=_NUM:abs(yDelta), disable=dYdisable

	Button centerByPixels,win=$win,disable=disable
	Button centerAtCursorA,win=$win,disable=disable

	return disable
End


Function WMPolarGraphImageYFlipButtonProc(ctrlName) : ButtonControl
	String ctrlName

	WAVE/Z image=WMPolarGetImageScalingPanelImage()
	if( !WaveExists(image) )
		return 0
	endif
	// get current Setscale/I y scaling
	// and reverse extrema
	Variable yCols= DimSize(image,1)
	Variable yScaleMin= DimOffset(image,1) + DimDelta(image,1)*(yCols-1) // should be less than yScaleMax
	Variable yScaleMax= DimOffset(image,1)
	SetScale/I y, yScaleMin, yScaleMax, WaveUnits(image,1), image
 	WMPolarGraphImageScalingPanelUpdate()
 End

Function WMPolarImagePopupSelectorNotify(event, wavepath, windowName, buttonName)
	Variable event		// WMWS_SelectionChanged
	String wavepath
	String windowName	// panel name
	String buttonName	// "mainAppendRadiusDataPop" or "mainAppendAngleDataPop"
	
	Wave/Z image= $wavepath

	WMPolarImageReplaceImage(image)
End

Function WMPolarImagePopupSelectorFilter(fullPathToWave, contentsCode)
	String fullPathToWave
	Variable contentsCode	// WMWS_Waves or WMWS_DataFolders
	
	if( contentsCode != WMWS_Waves )
		return 0
	endif

	WAVE/Z w= $fullPathToWave
	return WMPolarImageIsAcceptable(w)
End

// must be numeric, can't be complex or one-dimensional. 
static Function WMPolarImageIsAcceptable(w)
	Wave/Z w
	
	Variable wt= WaveType(w,1)	// a new kind of waveType
	Variable acceptable= (wt == 1) // numeric
	if( acceptable ) 
		//  must have more than 1 row, more than 1 columns
		acceptable= DimSize(w,0) > 1 && DimSize(w,1) > 1
		if( acceptable )
			wt= WaveType(w)	// standard kind of waveType
			Variable waveIsComplex = wt & 0x01
			acceptable= !waveIsComplex
		endif
	endif
	return acceptable
End

// compare to WMPolarShowImageScalingPanel
Function WMPolarImageScalingPanelResize()

	if( WinType("WMPolarImageScalingPanel") != 1 )
		return -1
	endif
	
	Variable margin= 8
	
	// PTop
	String win= "WMPolarImageScalingPanel#PTop"
	GetWindow $win wsizeForControls // Reads window width into V_right in panel units.
	Variable width = V_right
	ControlInfo/W=$win imagePop // sets V_Height, V_Width, V_top, V_left, V_right
	// use full width for the image popup
	Variable right = width-margin
	Variable w = right-V_left
	ModifyControl imagePop, win=$win, size={w,V_Height}
	
	// right-justify the center buttons and +X Max Radius
	// centerByPixels;centerAtCursorA;xScaleMax
	
	ControlInfo/W=$win centerByPixels
	Variable left = right - V_Width
	ModifyControl centerByPixels, win=$win, pos={left,V_top}
	
	ControlInfo/W=$win centerAtCursorA
	left = right - V_Width
	ModifyControl centerAtCursorA, win=$win, pos={left,V_top}
	
	ControlInfo/W=$win xScaleMax
	left = right - V_Width
	ModifyControl xScaleMax, win=$win, pos={left,V_top}

	// PLeft
	win= "WMPolarImageScalingPanel#PLeft"
	GetWindow $win wsizeForControls // Reads window height into V_bottom in panel units.
	Variable height = V_bottom
	
	// center controls in width
	Variable wd2 = V_right/2
	
	// put yScaleMax at the top
	ControlInfo/W=$win yScaleMax	// sets V_Height, V_Width, V_top, V_left, V_right
	Variable top = margin
	left = wd2 - V_Width/2
	ModifyControl yScaleMax, win=$win, pos={left,top}
	Variable y1 = top+V_height // bottom of yScaleMax
	
	// put yScaleMin at the bottom
	ControlInfo/W=$win yScaleMin	// sets V_Height, V_Width, V_top, V_left, V_right
	top = height - margin - V_Height
	left = wd2 - V_Width/2
	ModifyControl yScaleMin, win=$win, pos={left,top}
	Variable y2 = top // top of yScaleMax

	// put flip Y vertical center at 1/3 of the distance
	// from the bottom of yScaleMax (y1)
	// and the top of yScaleMin (y2)
	ControlInfo/W=$win appendImageToPolarGraph	// sets V_Height, V_Width, V_top, V_left, V_right
	Variable h2 = V_Height

	ControlInfo/W=$win flipY
	Variable h1 = V_Height
	
	Variable buttonsHeight = h1+h2
	Variable dy = (y2 - y1 - buttonsHeight)/3	// distance from bottom of one control to top of the next
	
	top = y1 + dy
	left = wd2 - V_Width/2
	ModifyControl flipY, win=$win, pos={left,top}

	ControlInfo/W=$win appendImageToPolarGraph
	top = y2 - dy - V_Height
	left = wd2 - V_Width/2
	ModifyControl appendImageToPolarGraph, win=$win, pos={left,top}
End


Function WMUnequalPixelScalingDisclosureProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	if( !checked ) // switching to equal pixel scaling
		ControlInfo/W=WMPolarImageScalingPanel#PTop pixelDx
		WMPolarImageXYPixelSetVarProc("pixelDx",V_Value,num2str(V_Value),"")
	endif
	WMPolarGraphImageScalingPanelUpdate()
End

Function WMPolarImageXYPixelSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	WAVE/Z image=WMPolarGetImageScalingPanelImage()
	if( !WaveExists(image) )
		return 0
	endif
	
	Variable xRows= DimSize(image,0)
	Variable xScaleMin= DimOffset(image,0)
	Variable xDelta= DimDelta(image,0)
	Variable xScaleMax= DimOffset(image,0) + xDelta*(xRows-1)

	Variable yCols= DimSize(image,1)
	Variable yDelta= DimDelta(image,1)
	Variable yScaleMin= DimOffset(image,1) + yDelta*(yCols-1) // should be less than yScaleMax
	Variable yScaleMax= DimOffset(image,1)

	ControlInfo/W=WMPolarImageScalingPanel#PTop pixelDx
	Variable dx = abs(V_Value) // absolute value of (possibly new) xDelta
	Variable dy = dx			// absolute value of (possibly new) yDelta
	
	ControlInfo/W=WMPolarImageScalingPanel#PTop unequalPixelScalingDisclosure
	if( V_Value )
		ControlInfo/W=WMPolarImageScalingPanel#PTop pixelDy
		dy = abs(V_Value)
	endif

	// alter the extrema keeping the center the same.
	Variable xMult = dx/xDelta	// xDelta preserves sign of scaling (horizontal orientation)
	xScaleMin *= xMult
	xScaleMax *= xMult
	
	Variable yMult = dy/yDelta	// yDelta preserves sign of scaling (vertical orientation)
	yScaleMin *= yMult
	yScaleMax *= yMult
	
	SetScale/I x, xScaleMin, xScaleMax, WaveUnits(image,0), image
	SetScale/I y, yScaleMin, yScaleMax, WaveUnits(image,1), image

 	WMPolarGraphImageScalingPanelUpdate()
End

 
Function WMPolarGraphAppendImageButtonProc(ctrlName) : ButtonControl
	String ctrlName

	WAVE/Z image=WMPolarGetImageScalingPanelImage()
	Variable haveImage = WaveExists(image)
	if( !haveImage )
		Beep // shouldn't happen
		return -1
	endif
	
	String graphName= WMPolarTopPolarGraph()
	if( strlen(graphName) )
		// Don't append image to top polar graph if it already has an image
		WAVE/Z polarGraphImage= WMPolarGraphGetImage(graphName, 0)
		if( WaveExists(polarGraphImage) )
			graphName="" // create a new polar graph, instead
		else
			DoWindow/F $graphName
		endif
	endif
	if( strlen(graphName) == 0 )
		graphName= WMNewPolarGraph("_default_", "")
	endif
	if( strlen(graphName) )
		AppendImage/W=$graphName/B=HorizCrossing/R=VertCrossing image
		WMPolarInitializeAxes(graphName)
		Modifygraph/W=$graphName margin=-1 // eliminate white border around image; the presumption is that the image is a background for the graph.
		// WARNING: Make sure WMPolarEnsurePolarTracesWave() is called when the current data folder is properly set
		// by, for example: String df= WMPolarSetPolarGraphDF(graphName)	// returns OLD data folder, sets to polar data folder.
		String df= WMPolarSetPolarGraphDF(graphName)	// OLD data folder
		WAVE/Z/T tw=WMPolarEnsurePolarTracesWave()
		SetDataFolder df

		// Copy Image Settings from Image Scaling Graph to polar graph
		String info= ImageInfo("WMPolarImageScalingPanel", "", 0 )
		String recreation = StringByKey("RECREATION", info)
		String command= "ModifyImage/W="+graphName+" "+NameOfWave(image)+", "+recreation
		Execute/Q/Z command
	endif
End


/// End of code implementing version 9.03's Image Scaling panel and associated controls

Function WMPolarLabelsShadowColorPopup(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	ControlInfo/W=WMPolarGraphPanel $ctrlName

	Variable/G $WMPolarTopOrDefaultDFVar("shadowRed") = V_Red
	Variable/G $WMPolarTopOrDefaultDFVar("shadowGreen") = V_Green
	Variable/G $WMPolarTopOrDefaultDFVar("shadowBlue") = V_Blue
	Variable/G $WMPolarTopOrDefaultDFVar("shadowAlpha") = V_Alpha

	WMPolarAxesRedrawTopGraph()
End
