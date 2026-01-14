#pragma rtGlobals=2
#pragma version=2.06
#pragma IgorVersion=6

#include <WaveSelectorWidget>
#include <SaveRestoreWindowCoords>
#include <Readback ModifyStr>

// **********************************
// Version 2
//		Major revision of Scatter Plot Matrix file. Includes option to make the scatter plot matrix as a grid
// 		of embedded graphs.
//
//		Adds Modify Scatter Plot Matrix control panel.
//
//		Adds additional plot appearance options to the Modify Scatter Plot Matrix control panel.
//
//		Uses updated controls for markers, line styles and colors.
//
//		Added help file.
//
// 2.01
//		Added checkbox to Modify Scatter Plot Matrix panel, Axes tab: "Ignore NaN  for Axis Range". This checkbox
//			causes each individual plot to have axis ranges that include just the visible data. That is, the range does
//			not depend on data that have a NaN in either the X or Y wave (Igor's default in this case is to include the data
//			in the range even though the data point is invisible). This  also enables tick  labels on all plots.
//			*** This change is broken in that if you turn *off* the checkbox, the extra tick labels remain.***
// 2.02
// 		Fixed bug: if you had more than 10 data sets, some would be missing.
//		Fixed bug: Modify panel lacked a Show Ticks checkbox
// 		Fixed bug: Modify panel would turn on ticks if you selected an item from the Tick Position menu, and there was no way to turn them off again.
//		Added feature: Scatter Plot Matrix panel includes list to change order of waves.
//
// 2.03
//		Added ability to copy trace settings from one sub-graph to all sub-graphs.
//
// 2.04
//		Now you can plot a scatter plot matrix from the columns of a 2D matrix wave.
//
// 2.05 (LH, JP)
//		Supports variable panel resolution on Windows (IP7 only)
//
// 2.06 (JW)
//		Marker popup menu was initialized off-by-one so it looked like diamonds, but gave circles.
//		Fixed bug: if more than one wave is selected in the list of selected waves, and you clicked the Up or Down buttons when the selected
//			waves were already at the top (Up) or bottom (Down) a wave would disappear with each click.
// **********************************

// **********************************
// 	Possible things to add, bugs to fix, etc.
//
//	1) Needs an Unload Scatter Plot Matrix Package menu item.
//
//	2) Need to make free axis plot frame polygon draw with the correct color and line thickness to match the axis color and line thickness
//
//	3) Could use a Make All Subplots Look Like Active Subplot function.
//
//	4) For axis mod tab:
//		font, font size
//		minor ticks, tick sep, approximately ticks
//		high, low trip?
//		autoscale modes
//
// **********************************

Menu "New"
	"Scatter Plot Matrix...", /Q, fScatterPlotMatrixPanel2()
end

Menu "Graph", dynamic
	Submenu "Scatter Plot Matrix"
		"Modify Scatter Plot Matrix...", /Q, fScatterPlotMatrixModifyPanel()
		"Find Data Points...", /Q, fScatterPlotMatrixFindDataPanel()
		"Regression...", /Q, fScatterPlotMatrixRegressPanel()
	end
end

// Function to make necessary data folders and globals for Matrix Plot Panel
//   Should be called when initializing panel.
Function SPM2_MatrixPlotGlobals()

	string sFolder=GetDataFolder(1)
	SetDataFolder root:
	
	NewDataFolder/S/O Packages
	NewDataFolder/S/O WMScatterPlotMatrixPackage
	
	// Here are the globals
	String sdummy = StrVarOrDefault("gMPWaveList", "")
	String/G gMPWaveList =sdummy
	Variable dummy = NumVarOrDefault("gMPTraceMode", 3)
	Variable/G gMPTraceMode = dummy
	dummy = NumVarOrDefault("gMPMainMarker", 8)
	Variable/G gMPMainMarker = dummy
	dummy = NumVarOrDefault("gMPMainMarkerSize", 3)
	Variable/G gMPMainMarkerSize = dummy
	dummy = NumVarOrDefault("gMPModMarkerSize", 3)
	Variable/G gMPModMarkerSize = dummy
	dummy = NumVarOrDefault("gMPLineSize", 1)
	Variable/G gMPLineSize = dummy
	dummy = NumVarOrDefault("gMPModLineSize", 1)
	Variable/G gMPModLineSize = dummy
	dummy = NumVarOrDefault("gMPXMarker", 17)
	Variable/G gMPXMarker = dummy
	dummy = NumVarOrDefault("gMPYMarker", 19)
	Variable/G gMPYMarker = dummy
	dummy = NumVarOrDefault("gMPMarkerSize", 5)
	Variable/G gMPMarkerSize = dummy
	dummy = NumVarOrDefault("gMPMarkerThick", 1)
	Variable/G gMPMarkerThick = dummy
	
	dummy = NumVarOrDefault("gMPLeftMargin", 30)
	Variable/G gMPLeftMargin = dummy
	dummy = NumVarOrDefault("gMPBottomMargin", 30)
	Variable/G gMPBottomMargin = dummy
	dummy = NumVarOrDefault("gMPTopMargin", 10)
	Variable/G gMPTopMargin = dummy
	dummy = NumVarOrDefault("gMPRightMargin", 10)
	Variable/G gMPRightMargin = dummy
	
	// these are use only for embedded plots
	dummy = NumVarOrDefault("gMPRightInsetFraction", 0.1)
	Variable/G gMPRightInsetFraction = dummy
	dummy = NumVarOrDefault("gMPLeftInsetFraction", 0.15)
	Variable/G gMPLeftInsetFraction = dummy
	dummy = NumVarOrDefault("gMPTopInsetFraction", 0.1)
	Variable/G gMPTopInsetFraction = dummy
	dummy = NumVarOrDefault("gMPBottomInsetFraction", 0.15)
	Variable/G gMPBottomInsetFraction = dummy
	
	// this is used only for free-axis plots
	dummy =  NumVarOrDefault("gMPVerticalGroutFraction", 0.20)
	Variable/G gMPVerticalGroutFraction = dummy
	dummy = NumVarOrDefault("gMPHorizontalGroutFraction", 0.20)
	Variable/G gMPHorizontalGroutFraction = dummy
	dummy = NumVarOrDefault("gMPTagAxisFraction", 1)
	Variable/G gMPTagAxisFraction = dummy
	
	// Axis characteristics
	Variable/G gMPAxisThickness
	Variable/G gMPYLabelPosition
	Variable/G gMPXLabelPosition
	
	// Waves for the selection list
	Make/O/N=0 SelectedWavesSelWave
	Make/O/N=0/T SelectedWavesListWave
	
	SetDataFolder $sFolder
end

constant PO_LowerTriangle = 1
constant PO_Diagonal = 2
constant PO_UpperTriangle = 4
constant PO_NoTicksOrLabels = 8
constant PO_ColoredBoxes = 16

constant LO_LeftBottom = 0
constant LO_RightTop = 1		// not actually used...
constant LO_Diagonal = 2

static constant DoFrames = 1
static constant DontDoFrames = 0

constant PlotMatrixErr_NoErr = 0
constant PlotMatrixErr_NotEnoughWaves = 1
constant PlotMatrixErr_BadWave = 2
constant PlotMatrixErr_BadOptions = 3
constant PlotMatrixErr_NoTextWaves = 4
constant PlotMatrixErr_OneWaveMustBe2D = 5

static Constant MAX_OBJ_NAME = 31

Structure ScatterPlotMatrixInfo
	Variable ScatterPlotMatrixVersion
	Variable nWaves
	Variable UseEmbeddedGraphs
	Variable PlotOptions
	Variable LabelOptions
	Variable Frames
	Variable TraceMode
	Variable LineSize
	Variable LineStyle
	Variable Markersize
	Variable MarkerNumber
	Variable MarkerThickness
	Variable OpaqueMarkers
	Variable UseMarkerStroke
	Variable MarkerStrokeRed
	Variable MarkerStrokeGreen
	Variable MarkerStrokeBlue
	Variable TraceColorRed
	Variable TraceColorGreen
	Variable TraceColorBlue
	
	Variable LeftMargin
	Variable BottomMargin
	Variable RightMargin
	Variable TopMargin
	
	// used only for embedded plots
	Variable RightInsetFraction
	Variable LeftInsetFraction
	Variable TopInsetFraction
	Variable BottomInsetFraction
	
	// used only for free-axis plots
	Variable VerticalGroutFraction
	Variable HorizontalGroutFraction
	
	Variable PlotBackColorRed
	Variable PlotBackColorGreen
	Variable PlotBackColorBlue
	
	// Axis characteristics
	Variable AxisThickness
	Variable AxisColorRed
	Variable AxisColorGreen
	Variable AxisColorBlue
	Variable AxisStandoff
	
	Variable YAxisLabelPos
	Variable XAxisLabelPos
	Variable YTickLabelRot
	Variable XTickLabelRot
	Variable TickPosition 	// you know- outside, inside, crossing
	Variable GridOnOff

	char datafoldername[MAX_OBJ_NAME+1]
	
	// axis range
	Variable AxisRangeMode		// 0: normal (all plots auto-range); 1: range without NaN's (each plot gets manual range including only real data)
EndStructure

constant ScatterPlotMatrixInfoVersion = 2

Function SPM2_ScatterPlotMatrix(WavesList, PlotOptions, LabelOptions, Frames[, TraceMode, LineSize, MarkerSize, MarkerNumber])
	String WavesList
	Variable PlotOptions		// bit 0: Include lower triangle;bit 1: Include diagonal;
								// bit 2: include upper triangle; bit 3: No ticks or tick labels;
								// bit 4: Colored boxes
	Variable LabelOptions		//0: left and bottom
								// 1: right and top (not implemented, but the code is included for compatibility with free-axis version)
								//2: diagonal
	Variable Frames			//=1 for boxes around each graph
	Variable TraceMode			// ModifyGraph mode=<TraceMode>
	Variable LineSize			//  ModifyGraph lsize=<LineSize>
	Variable MarkerSize		//  ModifyGraph msize=<MarkerSize>
	Variable MarkerNumber	//  ModifyGraph marker=<MarkerNumber>
	
	if (PlotOptions == 0)
		return PlotMatrixErr_BadOptions
	endif
	
	if (ParamIsDefault(TraceMode))
		TraceMode = 3
	endif	
	if (ParamIsDefault(LineSize))
		LineSize = 1
	endif	
	if (ParamIsDefault(MarkerSize))
		MarkerSize = 0
	endif	
	if (ParamIsDefault(MarkerNumber))
		MarkerNumber = 8
	endif	

	STRUCT ScatterPlotMatrixInfo info
	info.ScatterPlotMatrixVersion = ScatterPlotMatrixInfoVersion
	info.UseEmbeddedGraphs = 1
	info.PlotOptions = PlotOptions
	info.LabelOptions = LabelOptions
	info.Frames = Frames
	info.TraceMode = TraceMode
	info.LineSize = LineSize
	info.LineStyle = 0			// default
	info.Markersize = MarkerSize
	info.MarkerNumber = MarkerNumber
	info.MarkerThickness = 1
	info.TraceColorRed = 65535
	info.TraceColorGreen = 0
	info.TraceColorBlue = 0
	info.OpaqueMarkers = 0
	info.UseMarkerStroke = 0
	info.MarkerStrokeRed = 65535
	info.MarkerStrokeGreen = 0
	info.MarkerStrokeBlue = 0
	
	info.LeftMargin = 30
	info.BottomMargin = 30
	info.RightMargin = 10
	info.TopMargin = 10
	info.RightInsetFraction = 0.1
	info.LeftInsetFraction = 0.15
	info.TopInsetFraction = 0.1
	info.BottomInsetFraction = 0.15

	info.PlotBackColorRed = 50000
	info.PlotBackColorGreen = 50000
	info.PlotBackColorBlue = 50000
	
	info.AxisThickness = 1
	info.AxisColorRed = 0
	info.AxisColorGreen = 0
	info.AxisColorBlue = 0
	info.AxisStandoff = 1
	info.YTickLabelRot = 0
	info.XTickLabelRot = 0
	info.TickPosition = 2
	info.GridOnOff = 0

	String Wave1,Wave2, Axis1="", Axis2=""
	String LabelText
	
	Variable nWaves
	Variable i, j
	Variable MinPercent, MaxPercent, PercentBetween, PercentRange,PercentBase
	Variable LabelTextX, LabelTextY
	Variable AxMin
	
	nWaves = ItemsInList(WavesList)
	
	if (nWaves < 1)
		return PlotMatrixErr_NotEnoughWaves
	endif

	if (nWaves == 1)
		Wave w = $StringFromList(0, WavesList)
		if (WaveDims(w) != 2)
			return PlotMatrixErr_OneWaveMustBe2D
		endif
	endif
	
	info.nWaves = nWaves

	for (i = 0; i < nWaves; i += 1)
		Wave1 = StringFromList(i, WavesList)
		if (strlen(Wave1) <= 0)
			return PlotMatrixErr_BadWave
		endif
		Wave/Z w = $Wave1
		if (!WaveExists(w))
			return PlotMatrixErr_BadWave
		endif
		if (WaveType(w ) == 0)
			return PlotMatrixErr_NoTextWaves
		endif
		if (WaveDims(w) > 1 && nWaves > 1)
			return PlotMatrixErr_OneWaveMustBe2D
		endif
	endfor
	
	Display
	String graphname = WinName(0, 1)
	
	String GuideName, GuideNamePG
	
	DefineGuide/W=$graphname RightGuide = {FR, -info.RightMargin}
	DefineGuide/W=$graphname TopGuide = {FT, info.TopMargin}
	DefineGuide/W=$graphname LeftGuide = {FL, info.LeftMargin}
	DefineGuide/W=$graphname BottomGuide = {FB, -info.BottomMargin}
	
	Variable nCols = nWaves
	if (nWaves == 1)
		Wave matrixWave = $StringFromList(0, WavesList)
		nCols = DimSize(matrixWave, 1)
		if (nCols <= 2)
			return PlotMatrixErr_OneWaveMustBe2D
		endif
	endif

	for (i = 0; i <= nCols; i += 1)
		GuideName = "VerticalFG_"+num2istr(i)
		DefineGuide/W=$graphname $GuideName = {LeftGuide, i/nCols,RightGuide}
		if (i < nCols)
			GuideNamePG = "VerticalPGL_"+num2istr(i)
			DefineGuide/W=$graphname $GuideNamePG = {LeftGuide, (i+info.LeftInsetFraction)/nCols,RightGuide}
		endif
		if (i > 0)
			GuideNamePG = "VerticalPGR_"+num2istr(i)
			DefineGuide/W=$graphname $GuideNamePG = {LeftGuide, (i-info.RightInsetFraction)/nCols,RightGuide}
		endif
		GuideName = "HorizontalFG_"+num2istr(i)
		DefineGuide/W=$graphname $GuideName = {TopGuide, i/nCols,BottomGuide}
		if (i > 0)
			GuideNamePG = "HorizontalPGB_"+num2istr(i)
			DefineGuide/W=$graphname $GuideNamePG = {TopGuide, (i-info.BottomInsetFraction)/nCols,BottomGuide}
		endif
		if (i < nCols)
			GuideNamePG = "HorizontalPGT_"+num2istr(i)
			DefineGuide/W=$graphname $GuideNamePG = {TopGuide, (i+info.TopInsetFraction)/nCols,BottomGuide}
		endif
	endfor

	String VGuideNameR, VGuideNameL, HGuideNameT, HGuideNameB, VGuideNamePGL, VGuideNamePGR, HGuideNamePGT, HGuideNamePGB, SubGraphName
	Variable IncludeDiagonals = (PlotOptions&PO_Diagonal) && !(LabelOptions==LO_Diagonal)

	for (j = 0; j < nCols; j += 1)
		if (!WaveExists(matrixWave))
			Wave1 = StringFromList(j, WavesList)
		endif
		HGuideNameT = "HorizontalFG_"+num2istr(j)
		HGuideNamePGB = "HorizontalPGB_"+num2istr(j+1)
		HGuideNamePGT = "HorizontalPGT_"+num2istr(j)
		for (i = nCols-1; i >= 0; i -= 1)
			if (IncludeHorizLabels(j, i, PlotOptions, LabelOptions, nCols))
				HGuideNameB = ""		// the axis label is included only if there is no plot below this one
			else
				HGuideNameB = "HorizontalFG_"+num2istr(j+1)
			endif
			if (IncludeVertLabels(j, i, PlotOptions, LabelOptions))
				VGuideNameL = ""		// the axis label is included only if there is no plot to the left of this one. 
			else
				VGuideNameL = "VerticalFG_"+num2istr(i)
			endif
			VGuideNamePGL = "VerticalPGL_"+num2istr(i)
			VGuideNameR = "VerticalFG_"+num2istr(i+1)
			VGuideNamePGR = "VerticalPGR_"+num2istr(i+1)
			if (!WaveExists(matrixWave))
				Wave2 = StringFromList(i, WavesList)
			endif
			SubGraphName = "Graph_"+num2istr(i)+"_"+num2istr(j)
			if ( ((PlotOptions&PO_LowerTriangle) == 0) && (i < j) )
				continue
			endif
			if ( ((PlotOptions&PO_UpperTriangle) == 0) && (i > j) )
				continue
			endif
			String traceName
			if (WaveExists(matrixWave))
				traceName = "Matrix_"+num2str(j)+"_"+num2str(i)
				Display/HOST=$graphname/N=$SubGraphName/FG=($VGuideNameL, , , $HGuideNameB)/PG=($VGuideNamePGL, $HGuideNamePGT, $VGuideNamePGR, $HGuideNamePGB) matrixWave[][j]/TN=$traceName vs matrixWave[][i]
			else
				Display/HOST=$graphname/N=$SubGraphName/FG=($VGuideNameL, , , $HGuideNameB)/PG=($VGuideNamePGL, $HGuideNamePGT, $VGuideNamePGR, $HGuideNamePGB) $Wave1 vs $Wave2
				traceName = Wave1
			endif
			if (PlotOptions & PO_NoTicksOrLabels)
				ModifyGraph/W=$graphname#$SubGraphName noLabel=1, tick=3
			else
				ModifyGraph/W=$graphname#$SubGraphName tick=2
			endif

			String labelStr
			if (IncludeHorizAxisLabel(j, i, PlotOptions, LabelOptions, nCols))
				if (WaveExists(matrixWave))
					labelStr = GetDimLabel(matrixWave, 1, i)
					if (strlen(labelStr) == 0)
						labelStr = NameOfWave(matrixWave)+"[]["+num2str(i)+"]"
					endif
					Label/W=$graphname#$SubGraphName bottom, labelStr
				else
					Label/W=$graphname#$SubGraphName bottom, NameOfWave($Wave2)
				endif
			endif
			if (IncludeVertAxisLabel(j, i, PlotOptions, LabelOptions))
				if (WaveExists(matrixWave))
					labelStr = GetDimLabel(matrixWave, 1, j)
					if (strlen(labelStr) == 0)
						labelStr = NameOfWave(matrixWave)+"[]["+num2str(j)+"]"
					endif
					Label/W=$graphname#$SubGraphName left, labelStr
				else
					Label/W=$graphname#$SubGraphName left, NameOfWave($Wave1)
				endif
			endif
			info.XAxisLabelPos = (PlotOptions & PO_NoTicksOrLabels) ? 20 : 30
			ModifyGraph/W=$graphname#$SubGraphName lblPosMode(bottom)=4,lblPos(bottom)=info.XAxisLabelPos
			info.YAxisLabelPos = (PlotOptions & PO_NoTicksOrLabels) ? 20 : 40
			ModifyGraph/W=$graphname#$SubGraphName lblPosMode(left)=4,lblPos(left)=info.YAxisLabelPos

			if (!IncludeHorizTickLabels(j, i, PlotOptions, LabelOptions, nCols))
				if (!IncludeHorizAxisLabel(j, i, PlotOptions, LabelOptions, nCols))
					ModifyGraph/W=$graphname#$SubGraphName nolabel(bottom)=2
				else
					ModifyGraph/W=$graphname#$SubGraphName nolabel(bottom)=1
				endif
			endif
			if (!IncludeVertTickLabels(j, i, PlotOptions, LabelOptions))
				if (!IncludeVertAxisLabel(j, i, PlotOptions, LabelOptions))
					ModifyGraph/W=$graphname#$SubGraphName nolabel(left)=2
				else
					ModifyGraph/W=$graphname#$SubGraphName nolabel(left)=1
				endif
			endif
			if (LabelOptions == LO_Diagonal)
				if (i == j)
					if (WaveExists(matrixWave))
						labelStr = GetDimLabel(matrixWave, 1, j)
						if (strlen(labelStr) == 0)
							labelStr = NameOfWave(matrixWave)+"[]["+num2str(j)+"]"
						endif
						TextBox/C/N=$("Label"+num2istr(i))/F=0/A=MC/X=0/Y=0 labelStr
					else
						TextBox/C/N=$("Label"+num2istr(i))/F=0/A=MC/X=0/Y=0 NameOfWave($Wave1)
					endif
				endif
			endif

			if (!IncludeDiagonals && (i == j))
				ModifyGraph nolabel=2, axThick=0, lSize=0		// hide the graph. Having a graph causes the label, if it exists, to be positioned in the middle of the plot area, so it matches the other graphs
				continue
			endif
			
			if (frames)
				ModifyGraph/W=$graphname#$SubGraphName mirror=2
			endif

			if (PlotOptions & PO_ColoredBoxes)
				ModifyGraph/W=$graphname#$SubGraphName gbRGB=(info.PlotBackColorRed,info.PlotBackColorGreen,info.PlotBackColorBlue)
			endif
			ModifyGraph/W=$graphname#$SubGraphName mode=TraceMode
			ModifyGraph/W=$graphname#$SubGraphName lsize=LineSize
			ModifyGraph/W=$graphname#$SubGraphName msize=MarkerSize
			ModifyGraph/W=$graphname#$SubGraphName marker=MarkerNumber
		endfor
	endfor
	
	SetActiveSubwindow $graphname

	info.datafoldername = MakeGraphDataFolder(graphname, 0)
	
	SPM_StoreInfoInGraph(info, graphname)
	
	SetWindow $graphname,hook(ScatterPlotMatrixHook)=ScatterPlotMatrixHook

	return PlotMatrixErr_NoErr
end

Function ScatterPlotMatrixHook(s)
	STRUCT WMWinHookStruct &s
	
	Variable returnValue = 0
	STRUCT ScatterPlotMatrixInfo info
	if (SPM_GetInfoFromGraph(info, ParseFilePath(0, s.winName, "#", 0, 0) ) == 0)
		return 0
	endif
	
	strswitch(s.eventName)
		case "kill":
			String fullDFName = "root:Packages:WMScatterPlotMatrixPackage:"+info.datafoldername
			if ( (strlen(info.datafoldername) > 0) && DataFolderExists(fullDFName ) )
				if (exists(s.winName) != 5)	// if user saved a recreation macro, keep the waves
					Execute/P/Q/Z "KillDataFolder "+fullDFName
					return 0
				endif
				if ((CountObjects(fullDFName, 1)+CountObjects(fullDFName, 2)+CountObjects(fullDFName, 3)+CountObjects(fullDFName, 4)) == 0)
					KillDataFolder fullDFName
					return 0
				endif
			endif
			break;
		case "mousedown":
			if (s.eventMod == 16+2+1)		// ctrl plus shift plus button down
				if (strlen(TraceFromPixel(s.mouseLoc.h, s.mouseLoc.v, "WINDOW:"+s.winName)) == 0)
					return 0
				endif
				Variable IncludeDiagonals = (info.PlotOptions&PO_Diagonal) && !(info.LabelOptions==LO_Diagonal)
				returnValue = 1
				String menuString = ""
				if ((info.UseEmbeddedGraphs && IsDiagonalGraph(s.winName) && !IncludeDiagonals))
					menuString += "\\M1(Copy Trace Styles;"
				else
					menuString += 	"Copy Trace Styles;"		// if !IncludeDiagonals, the graph windows on the diagonal don't have traces with styles that should be copied
				endif
				if (CopyTraceUndoAvailable(s.winName))
					menuString += 	"Undo Copy Trace Styles;"
				else
					menuString += 	"\\M1(Undo Copy Trace Styles;"
				endif
				if (strlen(menuString) == 0)
					return 0
				endif
				PopupContextualMenu menuString
				switch (V_flag)
					case 1:
						string pixelTraceInfo = TraceFromPixel(s.mouseLoc.h, s.mouseLoc.v, "WINDOW:"+s.winName )
						SPM2_CopyTraceInfoToSubGraphs(StringByKey("TRACE", pixelTraceInfo), s.winName)
						break;
					case 2:
						SPM2_UndoCopyTraceInfo(ParseFilePath(0, s.winName, "#", 0, 0))
						break;
				endswitch
			endif
			break;
	endswitch
	
	return returnValue		// 0 if nothing done, else 1
End

Function IncludeVertLabels(row, column, PlotOptions, LabelOptions)
	Variable row, column, PlotOptions, LabelOptions
	
	Variable IncludeDiag = (PlotOptions & PO_Diagonal) && (LabelOptions != LO_Diagonal)
	
	if (PlotOptions & PO_LowerTriangle)
		if (IncludeDiag)
			return column == 0
		else
			return (column == 0) || ((column == 1) && (row == 0))
		endif
	else
		if (IncludeDiag)
			return column == row
		else
			return column == row+1
		endif
	endif
end

Function IncludeHorizLabels(row, column, PlotOptions, LabelOptions, nCols)
	Variable row, column, PlotOptions, LabelOptions, nCols
	
	Variable IncludeDiag = (PlotOptions & PO_Diagonal) && (LabelOptions != LO_Diagonal)
	
	if (PlotOptions & PO_LowerTriangle)
		if (IncludeDiag)
			return row == nCols-1
		else
			return (row == nCols-1) || ((row == nCols-2) && (column == nCols-1))
		endif
	else
		if (IncludeDiag)
			return column == row
		else
			return row == column-1
		endif
	endif
end

Function IncludeVertTickLabels(row, column, PlotOptions, LabelOptions)
	Variable row, column, PlotOptions, LabelOptions
	
	return IncludeVertLabels(row, column, PlotOptions, LabelOptions) && ((PlotOptions & PO_NoTicksOrLabels) == 0)
end

Function IncludeHorizTickLabels(row, column, PlotOptions, LabelOptions, nCols)
	Variable row, column, PlotOptions, LabelOptions, nCols
	
	return IncludeHorizLabels(row, column, PlotOptions, LabelOptions, nCols) && ((PlotOptions & PO_NoTicksOrLabels) == 0)
end

Function IncludeVertAxisLabel(row, column, PlotOptions, LabelOptions)
	Variable row, column, PlotOptions, LabelOptions
	
	return IncludeVertLabels(row, column, PlotOptions, LabelOptions) && (LabelOptions != LO_Diagonal)
end

Function IncludeHorizAxisLabel(row, column, PlotOptions, LabelOptions, nCols)
	Variable row, column, PlotOptions, LabelOptions, nCols
	
	return IncludeHorizLabels(row, column, PlotOptions, LabelOptions, nCols) && (LabelOptions != LO_Diagonal)
end

Function/S MakeGraphDataFolder(GraphName, returnFullPath)
	String GraphName
	Variable returnFullPath
	
	String SaveDF = GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S WMScatterPlotMatrixPackage
	String dfname = UniqueName(GraphName, 11, 0)
	NewDataFolder/O/S $dfname
	SetDataFolder SaveDF
	
	if (returnFullPath)
		return "root:Packages:WMScatterPlotMatrixPackage:"+dfname
	else
		return dfname
	endif
end

Function/S GraphDataFolderFullPath(GraphName)
	String GraphName
	
	STRUCT ScatterPlotMatrixInfo info
	if (SPM_GetInfoFromGraph(info, GraphName) == 0)
		return ""		// not a Scatter Plot Matrix graph window
	endif
	if (strlen(info.datafoldername) == 0)
		info.datafoldername = MakeGraphDataFolder(GraphName, 0)
		SPM_StoreInfoInGraph(info, GraphName)
	endif
	return "root:Packages:WMScatterPlotMatrixPackage:"+info.datafoldername
end

Function TraceModePopNumToModeNumber(popNum)
	Variable popNum
	
	switch (popNum)
		case 1:
		case 2:
			return popNum+1
			break;
		case 3:
			return 0
			break;
		case 4:
			return 4
			break;
	endswitch
end

Function TraceModeNumberToModePopNum(mode)
	Variable mode
	
	switch (mode)
		case 2:
		case 3:
			return mode-1
			break;
		case 0:
			return 3
			break;
		case 4:
			return 4
			break;
	endswitch
end

Function SPM2_TraceModePopProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	NVAR gMPTraceMode=root:Packages:WMScatterPlotMatrixPackage:gMPTraceMode
	gMPTraceMode = TraceModePopNumToModeNumber(popNum)
End

Function TraceMarkerPopProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	NVAR gMPMainMarker=root:Packages:WMScatterPlotMatrixPackage:gMPMainMarker
	gMPMainMarker = popNum-1
End

#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility between Igor 6 and 7
	String wName
	return 72
End
#endif

Function fScatterPlotMatrixPanel2() : Panel

	if (WinType("ScatterPlotMatrixPanel2") == 7)
		DoWindow/F ScatterPlotMatrixPanel2
	else
		SPM2_MatrixPlotGlobals()
	
		string cmd = "NewPanel /K=1/W=(%s) as \"Scatter Plot Matrix Controls\""
		execute WC_WindowCoordinatesSprintf("ScatterPlotMatrixPanel2", cmd, 438,300,943,751, PanelResolution("ScatterPlotMatrixPanel2") == 72)
//		NewPanel /K=1/W=(25,48,395,499) as "Scatter Plot Matrix Controls"
		DoWindow/C ScatterPlotMatrixPanel2
		
		String SaveDF=GetDatafolder(1)
		SetDatafolder root:Packages:WMScatterPlotMatrixPackage
			NVAR gMPTraceMode
			NVAR gMPLineSize
			NVAR gMPMainMarkerSize
			NVAR gMPMainMarker
			Wave SelectedWavesSelWave
			Wave/T SelectedWavesListWave
		SetDatafolder $saveDF

		GroupBox ScatterMatrixPlotLayoutGroup,pos={7,2},size={350,114},title="Plot Layout"
			CheckBox UpperTriangle,pos={20,20},size={130,14},title="Include Upper Triangle"
			CheckBox UpperTriangle,help={"Plot upper triangle of plot matrix"},value= 1
			CheckBox LowerTriangle,pos={20,37},size={130,14},title="Include Lower Triangle"
			CheckBox LowerTriangle,help={"Plot lower triangle of plot matrix"},value= 1
			CheckBox Diagonal,pos={160,20},size={97,14},title="Include Diagonal"
			CheckBox Diagonal,help={"Plot diagonal elements of plot matrix.  These plots are degenerate, having the same data set for both X and Y values."}
			CheckBox Diagonal,value= 1
			CheckBox DiagonalLabels,pos={160,37},size={102,14},title="Label on Diagonal"
			CheckBox DiagonalLabels,help={"The plots on the diagonal will be replaced with axis labels.  \r\rOtherwise, axis labels will be placed on the left-most plot for vertical axes, and on the bottom-most plot for horizontal axes."}
			CheckBox DiagonalLabels,value= 1
			CheckBox FramePlots,pos={270,20},size={77,14},title="Frame Plots"
			CheckBox FramePlots,help={"A frame will be drawn around each plot.\r\rWhen unchecked, just a left and bottom axis are drawn."}
			CheckBox FramePlots,value= 1
			CheckBox NoTicksCheckbox,pos={20,54},size={132,14},title="NO Ticks or Tick Labels"
			CheckBox NoTicksCheckbox,help={"Plot lower triangle of plot matrix"},value= 0
			CheckBox ColoredboxesCheck,pos={160,54},size={149,14},title="Colored Boxes Behind Plots"
			CheckBox ColoredboxesCheck,help={"Plot lower triangle of plot matrix"},value= 0
			PopupMenu SPM2_PlotMethodMenu,pos={23,81},size={206,20},title="Plot Method"
			PopupMenu SPM2_PlotMethodMenu,mode=1,bodyWidth= 150,value= #"\"Embedded Graphs;Lots of Free Axes\""
			Button SPM2_PlotMethodHelpButton,pos={239,81},size={20,20},proc=SPM2_PlotMethodHelpButtonProc,title="?"

		GroupBox ScatterMatrixTrAppearanceGroup,pos={7,125},size={350,109},title="Trace Appearance"
			PopupMenu TraceModePopup,pos={20,143},size={133,20},proc=SPM2_TraceModePopProc
			PopupMenu TraceModePopup,help={"Choose how you want the data to be shown on the plots."}
			PopupMenu TraceModePopup,value= #"\"Dots;Markers;Lines;Lines and Markers\"",mode=TraceModeNumberToModePopNum(gMPTraceMode)
			SetVariable SetMarkerSize,pos={49,205},size={101,15},title="Marker Size:"
			SetVariable SetMarkerSize,help={"Sets the size of the markers used to plot the data."}
			SetVariable SetMarkerSize,limits={0,10,0.5},value= root:Packages:WMScatterPlotMatrixPackage:gMPMainMarkerSize
			SetVariable SetLineSize,pos={176,205},size={127,15},title="Line Thickness:"
			SetVariable SetLineSize,help={"Sets the line thickness for the data trace when you have chosen Lines or Lines and Markers mode in the Trace Mode popup."}
			SetVariable SetLineSize,limits={0,10,0.5},value= root:Packages:WMScatterPlotMatrixPackage:gMPLineSize
			SetVariable SetMarkerThick,pos={176,182},size={127,15},title="Marker Thickness:"
			SetVariable SetMarkerThick,help={"Sets the thickness of the line used to draw marker outlines."}
			SetVariable SetMarkerThick,limits={0,10,0.5},value= root:Packages:WMScatterPlotMatrixPackage:gMPMarkerThick
			PopupMenu SCM_MarkerMenu,pos={61,180},size={90,20},proc=TraceMarkerPopProc,title="Marker:"
			PopupMenu SCM_MarkerMenu,mode=gMPMainMarker+1,value= #"\"*MARKERPOP*\""
			
		GroupBox SPM_SelectWavesGroup,pos={7,240},size={489,211}
			ListBox SPM_WaveSelectorList,pos={14,249},size={190,134},frame=2
			ListBox SPM_SelectedWavesList,pos={299,249},size={190,134}, selwave=SelectedWavesSelWave, listWave=SelectedWavesListWave
			ListBox SPM_SelectedWavesList,mode=3,proc=SPM_SelectedWavesListProc,frame=2	// mode=3: multiple contiguous selection
			Button SPM_SelectAllInTargetButton,pos={24,391},size={170,20},proc=SPM_SelectAllInTargetButtonProc,title="Select All in Top Window",fSize=10
			Button SPM_AppendWaves,pos={218,303},size={65,20},title="Append->",fSize=10,proc=SPM_AppendSelectedWavesBtnProc
			Button SPM_WaveSelectionUp,pos={388,391},size={40,20},title="Up",fSize=10,proc=SPM_MoveSelectedWavesUpOrDown
			Button SPM_WaveSelectionDown,pos={439,391},size={40,20},title="Down",fSize=10,proc=SPM_MoveSelectedWavesUpOrDown
			TitleBox SPM_MoveSelectionTitle,pos={307,394},size={75,12},title="Move Selection:"
			TitleBox SPM_MoveSelectionTitle,fSize=10,frame=0
			Button SPM_DeleteFromWaveList,pos={307,420},size={120,20},title="Delete Selection",fSize=10,proc=SPM_DeleteFromSelectedWaves
	
		Button SPM_MakePlotButton,pos={6,457},size={80,20},proc=SPM2_MakePlotButtonProc,title="Make Plot"
		Button SPM_MakePlotButton,help={"Make the whole dang plot."},fStyle=1
		Button SPM_MakePlotButton,fColor=(0,43690,65535)
	
		Button SPM_HelpButton,pos={433,15},size={50,20},proc=SPM_HelpButtonProc,title="Help"
		
		MakeListIntoWaveSelector("ScatterPlotMatrixPanel2", "SPM_WaveSelectorList", listoptions="CMPLX:0,TEXT:0")
		
		SetWindow ScatterPlotMatrixPanel2, hook(SCMPanelHook)=SCM_PanelHook
		Variable pixelsToPoints = ScreenResolution/PanelResolution("ScatterPlotMatrixPanel2")
		SPM2_PanelMinWindowSize("ScatterPlotMatrixPanel2", 505/pixelsToPoints, 484/pixelsToPoints)	// make sure the window isn't too small
		SPM2_PanelResize("ScatterPlotMatrixPanel2")
	endif
EndMacro

Function SCM_PanelHook(s)
	STRUCT WMWinHookStruct &s
	
	Variable statusCode = 0
	
	switch (s.eventCode)
		case 2:		// window being killed
			WC_WindowCoordinatesSave(s.winName)
			break;
		case 6:		// resized
			Variable pixelsToPoints = ScreenResolution/PanelResolution(s.winName)
			SPM2_PanelMinWindowSize(s.winName, 505/pixelsToPoints, 484/pixelsToPoints)	// make sure the window isn't too small
			SPM2_PanelResize(s.winName)
			statusCode=1
			break
		case 11:		// keyboard
			if ( (s.keycode == 13) || (s.keycode == 3) )			// Return and Enter keys on a Macintosh
				SPM2_MakePlotButtonProc("")
			endif
			break;
	endswitch
	
	return statusCode		// 0 if nothing done, else 1
End

static Function SPM2_PanelMinWindowSize(winName, minwidth,minheight)
	String winName
	Variable minwidth,minheight

	GetWindow $winName wsize
	Variable width= max(V_right - V_left, minwidth)
	Variable height= max(V_bottom-V_top,minheight)
	MoveWindow/W=$winName V_left, V_top, V_left+width, V_top+height
End

static Function SPM2_PanelResize(winName)
	String winName
	
	if( PanelResolution(winName) == 72 )
		GetWindow $winName wsizeDC
	else
		GetWindow $winName wsize
	endif
	Variable width= V_right - V_left
	Variable height= V_bottom-V_top
	
	GroupBox SPM_SelectWavesGroup,win=$winName,size={width-16,height-273}

	Variable winMiddle = round(width/2)
	Variable LBHeight = height-350
	Variable LBWidth = winMiddle-63
	ListBox SPM_WaveSelectorList,win=$winName,size={LBWidth, LBHeight}
	ListBox SPM_SelectedWavesList,win=$winName,pos={winMiddle+46, 249},size={LBWidth, LBHeight}
	Button SPM_AppendWaves,win=$winName,pos={winMiddle-35, 249+LBHeight/2-10}
	Button SPM_MakePlotButton,win=$winName,pos={6, height-27}
	Variable BTop = height-93
	Button SPM_SelectAllInTargetButton,win=$winName,pos={24, BTop}
	Button SPM_WaveSelectionUp,win=$winName,pos={winMiddle+135,BTop}
	Button SPM_WaveSelectionDown,win=$winName,pos={winMiddle+186,BTop}
	Variable tLeft = winMiddle+54
	TitleBox SPM_MoveSelectionTitle,win=$winName,pos={tLeft,BTop-3}
	Button SPM_DeleteFromWaveList,win=$winName,pos={tLeft,height-64}
end

static Function/S TableWaveList()

	Variable StartColNum, EndColNum, NumCols
	
	String TableName=WinName(0,2)
	GetSelection table, $TableName, 1
	
	StartColNum = V_startCol
	EndColNum = V_endCol
	NumCols = EndColNum-StartColNum+1
	
	String ListofWaves=""
	
	Variable i = StartColNum
	do
		Wave/Z w=WaveRefIndexed(TableName,i,1)
		if (waveExists(w))
			ListofWaves += GetWavesDataFolder(w, 2)+";"
		endif
	
		i += 1
	while (i<= EndColNum)

	return ListofWaves
end

static Function/S GraphWaveList()

	String GraphName = WinName(0,1)
	if (strlen(GraphName) == 0)
		return ""
	endif
	
	String Tracelist = TraceNameList(GraphName, ";", 1)
	String theList = ""
	
	Variable i = 0
	do
		String aTrace = StringFromList(i, TraceList)
		if (strlen(aTrace) == 0)
			break;
		endif
		
		Wave w = TraceNameToWaveRef(GraphName, aTrace )
		theList += GetWavesDataFolder(w, 2)+";"
		Wave/Z w = XWaveRefFromTrace(GraphName, aTrace)
		if (WaveExists(w))
			theList += GetWavesDataFolder(w, 2)+";"
		endif
		i += 1
	while (1)
	
	return theList
end

Function SPM_SelectedWavesListProc(s) : ListboxControl
	STRUCT WMListboxAction &s

	switch (s.eventCode)
		case 4:
		case 5:
			if ( (s.row >= numpnts(s.selWave))|| (s.row < 0) )
				Button SPM_AppendWaves,win=ScatterPlotMatrixPanel2,title="Append->"
			else
				Button SPM_AppendWaves,win=ScatterPlotMatrixPanel2,title="Insert->"
			endif
			break;
	endswitch
end

Function SPM_SelectAllInTargetButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String TopWindow = WinName(0, 3)
	Variable TopWinType = WinType(TopWindow)
	String ListOfWaves
	
	if (TopWinType == 1)		// a graph
		ListOfWaves = GraphWaveList()
	elseif (TopWinType == 2)	// a table
		ListOfWaves = TableWaveList()
	endif
	
	if (strlen(ListOfWaves) > 0)
		WS_ClearSelection("ScatterPlotMatrixPanel2", "SPM_WaveSelectorList")
		WS_SelectObjectList("ScatterPlotMatrixPanel2", "SPM_WaveSelectorList", ListOfWaves, OpenFoldersAsNeeded=1)
	endif
End

Function SPM_AppendSelectedWavesBtnProc(ctrlName) : ButtonControl
	String ctrlName

	String SaveDF = GetDataFolder(1)
	SetDatafolder root:Packages:WMScatterPlotMatrixPackage
		Wave SelectedWavesSelWave
		Wave/T SelectedWavesListWave
	SetDatafolder saveDF
	
	String ListOfWaves = WS_SelectedObjectsList("ScatterPlotMatrixPanel2", "SPM_WaveSelectorList")
	WS_ClearSelection("ScatterPlotMatrixPanel2", "SPM_WaveSelectorList")
	Variable numNewWaves = ItemsInList(ListOfWaves)
	if (numNewWaves  <= 0)
		return 0
	endif
		
	Variable rowsInSelectedList=DimSize(SelectedWavesSelWave, 0)
	Variable firstSelectedRow = rowsInSelectedList
	Variable i
	for (i = 0; i < rowsInSelectedList; i += 1)
		if (SelectedWavesSelWave[i] & 0x01)
			firstSelectedRow = i
			break
		endif
	endfor
	
	SPM_AppendListToSelectedWaves(ListOfWaves, firstSelectedRow)
end

static Function SPM_AppendListToSelectedWaves(theList, aboveRow)
	String theList
	Variable aboveRow

	String SaveDF = GetDataFolder(1)
	SetDatafolder root:Packages:WMScatterPlotMatrixPackage
		Wave SelectedWavesSelWave
		Wave/T SelectedWavesListWave
	SetDatafolder saveDF
	
	Variable numNewWaves = ItemsInList(theList)
	if (numNewWaves <= 0)
		return 0
	endif
	
	Variable i
	
	InsertPoints aboveRow, numNewWaves, SelectedWavesSelWave, SelectedWavesListWave
	SelectedWavesSelWave = 0
	for (i = 0; i < numNewWaves; i += 1)
		SelectedWavesListWave[i+aboveRow] = StringFromList(i, theList)
		SelectedWavesSelWave[i+aboveRow] = 1
	endfor
	
	ControlInfo/W=ScatterPlotMatrixPanel2 SPM_SelectedWavesList
	Variable topRow = V_startRow
	Variable bottomRow = topRow + V_Height/V_rowHeight - 1									// -1 for fence-post problem

	if ( (aboveRow - numNewWaves < topRow) || (aboveRow > bottomRow) )
		Variable newRow = max(0, aboveRow - numNewWaves-1)
		ListBox SPM_SelectedWavesList,win=ScatterPlotMatrixPanel2,row = newRow
	endif
	Button SPM_AppendWaves,win=ScatterPlotMatrixPanel2,title="Insert->"
end

Function SPM_MoveSelectedWavesUpOrDown(ctrlName) : ButtonControl
	String ctrlName

	String SaveDF = GetDataFolder(1)
	SetDatafolder root:Packages:WMScatterPlotMatrixPackage
		Wave SelectedWavesSelWave
		Wave/T SelectedWavesListWave
	SetDatafolder saveDF
	
	Variable rowsInSelectedList = DimSize(SelectedWavesSelWave, 0)
	Variable firstSelectedRow = rowsInSelectedList
	Variable lastSelectedRow = rowsInSelectedList
	Variable i
	
	String SelectedWaves = ""
	for (i = 0; i < rowsInSelectedList; i += 1)
		if (SelectedWavesSelWave[i] & 0x01)
			firstSelectedRow = i
			break
		endif
	endfor

	Variable numSelected = 0
	for (; i < rowsInSelectedList; i += 1)
		if  (SelectedWavesSelWave[i] & 0x01)
			SelectedWaves += SelectedWavesListWave[i]
			SelectedWaves += ";"
			numSelected += 1
		else
			break;
		endif
	endfor
	
	DeletePoints firstSelectedRow, numSelected, SelectedWavesSelWave, SelectedWavesListWave
	Variable appendRow = (CmpStr(ctrlName, "SPM_WaveSelectionUp") == 0) ? max(firstSelectedRow-1, 0) : min(firstSelectedRow+1, DimSize(SelectedWavesSelWave, 0))
	SPM_AppendListToSelectedWaves(SelectedWaves, appendRow)
end

Function SPM_DeleteFromSelectedWaves(ctrlName) : ButtonControl
	String ctrlName

	String SaveDF = GetDataFolder(1)
	SetDatafolder root:Packages:WMScatterPlotMatrixPackage
		Wave SelectedWavesSelWave
		Wave/T SelectedWavesListWave
	SetDatafolder saveDF
	
	Variable rowsInSelectedList = DimSize(SelectedWavesSelWave, 0)
	Variable firstSelectedRow = rowsInSelectedList

	Variable numSelected = 0
	Variable i
	for (i = 0; i < rowsInSelectedList; i += 1)
		if (SelectedWavesSelWave[i] & 0x01)
			firstSelectedRow = i
			break
		endif
	endfor
	for (; i < rowsInSelectedList; i += 1)
		if  (SelectedWavesSelWave[i] & 0x01)
			numSelected += 1
		else
			break;
		endif
	endfor
	
	if (numSelected == 0)
		return 0
	endif
	
	DeletePoints firstSelectedRow, numSelected, SelectedWavesSelWave, SelectedWavesListWave
	Button SPM_AppendWaves,win=ScatterPlotMatrixPanel2,title="Append->"
end

Function SPM2_PlotMethodHelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic/K=1 "Scatter Plot Matrix Package[Embedded Graphs or Free Axes?]"
End

Function SPM_HelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic "Scatter Plot Matrix Package"
End

Function SPM_ModifyHelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic "Scatter Plot Matrix Package[Modifying a Scatter Plot Matrix]"
End

Function SPM_FindDataHelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic "Scatter Plot Matrix Package[Finding Data Points]"
End

Function SPM_RegressionHelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic "Scatter Plot Matrix Package[Regression]"
End

Function SPM2_MakePlotButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	Variable PlotOptions = 0
	Variable LabelOptions = LO_LeftBottom
	Variable Frames = DontDoFrames
	String PlotCommand=""
	
	String SaveDF = GetDataFolder(1)
	SetDatafolder root:Packages:WMScatterPlotMatrixPackage
		Wave SelectedWavesSelWave
		Wave/T SelectedWavesListWave
		NVAR gMPTraceMode
		NVAR gMPLineSize
		NVAR gMPMainMarkerSize
		NVAR gMPMainMarker
	SetDatafolder saveDF

	String ListOfWaves = ""
	Variable i
	Variable nWaves = DimSize(SelectedWavesSelWave, 0)
	for (i = 0; i < nWaves; i += 1)
		ListOfWaves += SelectedWavesListWave[i]
		ListOfWaves += ";"
	endfor
	
	ControlInfo UpperTriangle
	if (V_Value)
		PlotOptions = PlotOptions | PO_UpperTriangle
	endif
	ControlInfo LowerTriangle
	if (V_Value)
		PlotOptions = PlotOptions | PO_LowerTriangle
	endif
	ControlInfo Diagonal
	if (V_Value)
		PlotOptions = PlotOptions | PO_Diagonal
	endif
	if (PlotOptions == 0)
		Abort "You must select at least one of Upper Triangle, Lower Triangle and Diagonal"
	endif
	ControlInfo NoTicksCheckbox
	if (V_Value)
		PlotOptions = PlotOptions | PO_NoTicksOrLabels
	endif
	ControlInfo ColoredboxesCheck
	if (V_Value)
		PlotOptions = PlotOptions | PO_ColoredBoxes
	endif
	
	ControlInfo DiagonalLabels
	if (V_Value)
		LabelOptions = LO_Diagonal
	else
		LabelOptions = LO_LeftBottom
	endif
	ControlInfo FramePlots
	if (V_Value)
		Frames = DoFrames
	else
		Frames = DontDoFrames
	endif
	
	Variable err
	ControlInfo SPM2_PlotMethodMenu
	if (CmpStr(S_value, "Embedded Graphs") == 0)
		err = SPM2_ScatterPlotMatrix(ListOfWaves, PlotOptions, LabelOptions, Frames, TraceMode=gMPTraceMode, LineSize=gMPLineSize, MarkerSize=gMPMainMarkerSize, MarkerNumber=gMPMainMarker)
	else
		err = SPM_FreeAxisPlotMatrix(ListOfWaves, PlotOptions, LabelOptions, Frames, TraceMode=gMPTraceMode, LineSize=gMPLineSize, MarkerSize=gMPMainMarkerSize, MarkerNumber=gMPMainMarker)
	endif
	switch (err)
		case PlotMatrixErr_NoErr:
			break;
		case PlotMatrixErr_NotEnoughWaves:
			DoAlert 0, "A scatter plot matrix requires at least two waves."
			break;
		case PlotMatrixErr_BadWave:
		case PlotMatrixErr_NoTextWaves:
			for (i = 0; i < ItemsInList(ListOfWaves); i += 1)
				String wname = StringFromList(i, ListOfWaves)
				Wave/Z w = $wname
				if (!WaveExists(w))
					DoAlert 0, "The wave "+wname+" does not exist."
					break;
				endif
				if (WaveType(w) == 0)
					DoAlert 0, "The wave "+wname+" is a text wave. Scatter Plot Matrix can't handle text waves."
					break;
				endif
			endfor
			if (i == ItemsInList(ListOfWaves))
				DoAlert 0, "That's odd- SPM2_ScatterPlotMatrix() says Bad Wave, but I can't find a bad wave in the list"
			endif
			break;
		case PlotMatrixErr_BadOptions:
			DoAlert 0, "You must select at least one of Upper Triangle, Lower Triangle and Diagonal"
			break;
		case PlotMatrixErr_OneWaveMustBe2D:
			DoAlert 0, "If you use a matrix wave, it must be the only wave, and it must have at least two columns."
			break;
		default:
			DoAlert 0, "Unknown error reported by SPM2_ScatterPlotMatrix()"
			break;
	endswitch
End

Function/S NameOfFirstCursorOnGraph(SubWin)
	String SubWin
	
	Wave/Z CWave=CsrWaveRef(A, SubWin)
	if (WaveExists(CWave))
		return "A"
	endif
	Wave/Z CWave=CsrWaveRef(B, SubWin)
	if (WaveExists(CWave))
		return "B"
	endif
	Wave/Z CWave=CsrWaveRef(C, SubWin)
	if (WaveExists(CWave))
		return "C"
	endif
	Wave/Z CWave=CsrWaveRef(D, SubWin)
	if (WaveExists(CWave))
		return "D"
	endif
	Wave/Z CWave=CsrWaveRef(E, SubWin)
	if (WaveExists(CWave))
		return "E"
	endif
	Wave/Z CWave=CsrWaveRef(F, SubWin)
	if (WaveExists(CWave))
		return "F"
	endif
	Wave/Z CWave=CsrWaveRef(G, SubWin)
	if (WaveExists(CWave))
		return "G"
	endif
	Wave/Z CWave=CsrWaveRef(H, SubWin)
	if (WaveExists(CWave))
		return "H"
	endif
	Wave/Z CWave=CsrWaveRef(I, SubWin)
	if (WaveExists(CWave))
		return "I"
	endif
	Wave/Z CWave=CsrWaveRef(J, SubWin)
	if (WaveExists(CWave))
		return "J"
	endif
	
	// failed
	return ""
end

Function SPM2_FindMarkedPoint(GraphWindow, xMarker, yMarker, markerSize)
	String GraphWindow
	Variable xMarker, yMarker, markerSize

	GetWindow $GraphWindow activeSW
	String SubWin = S_value
//	Wave/Z CWave=CsrWaveRef(A, SubWin)
//	String cName = "A"
//	if (!WaveExists(CWave))
//		Wave/Z CWave=CsrWaveRef(B, SubWin)
//		cName = "B"
//		if (!WaveExists(CWave))
//			DoAlert 0, "Cursor is not on active sub-graph.\r\rClick in sub-graph containing the cursor, or place a cursor on the active sub-graph."
//			return -1
//		endif
//	endif
	String cName = NameOfFirstCursorOnGraph(SubWin)
	Wave CWave = CsrWaveRef($cName, SubWin)
	String CWaveName = GetWavesDataFolder(CWave, 2)
	String CTraceName = CsrWave($cName, SubWin, 1)
	
	Variable hasMatrix = 0
	Variable matrixYCol, matrixXCol 
	if (WaveDims(CWave) == 2)
		hasMatrix = 1
		matrixYCol = str2num(StringFromList(1, CTraceName, "_"))
		matrixXCol = str2num(StringFromList(2, CTraceName, "_"))
	endif
	
	Variable cursorPoint = pcsr($cName, SubWin)
	
	String plotList = ChildWindowList(GraphWindow)
	Variable nPlots = ItemsInList(plotList)
	Variable i

	STRUCT ScatterPlotMatrixInfo info
	SPM_GetInfoFromGraph(info, GraphWindow)
	
	Variable IncludeDiagonals = (info.PlotOptions&PO_Diagonal) && !(info.LabelOptions==LO_Diagonal)
	
	for (i = 0; i < nPlots; i += 1)
		String subWinName = StringFromList(i, plotList)

		Variable ii,jj
		ii = str2num(StringFromList(1, subWinName, "_"))
		jj = str2num(StringFromList(2, subWinName, "_"))
		
		if (!IncludeDiagonals && (ii == jj))
			continue
		endif
		
		String gnamestr = GraphWindow+"#"+subWinName
		String tname = StringFromList(0, TraceNameList(gnamestr, ";", 1))
		if (hasMatrix)
			Variable yCol = str2num(StringFromList(1, tname, "_"))
			Variable xCol = str2num(StringFromList(2, tname, "_"))
			if (yCol == matrixYCol)
				SPM2_MarkPoint(GraphWindow, subWinName, cursorPoint, 0, xMarker, yMarker, markerSize)
			endif
			if (xCol == matrixYCol)
				SPM2_MarkPoint(GraphWindow, subWinName, cursorPoint, 1, xMarker, yMarker, markerSize)
			endif
		else
			if (cmpstr(CWaveName, GetWavesDataFolder(TraceNametoWaveRef(gnamestr, tname), 2)) == 0)
				SPM2_MarkPoint(GraphWindow, subWinName, cursorPoint, 0, xMarker, yMarker, markerSize)
			endif
			if (cmpstr(CWaveName, GetWavesDataFolder(XWaveRefFromTrace(gnamestr, tname), 2)) == 0)
				SPM2_MarkPoint(GraphWindow, subWinName, cursorPoint, 1, xMarker, yMarker, markerSize)
			endif
		endif
	endfor	
	
	return 0
end	

Function/S SPM_SetGraphDataFolder(GraphName)
	String GraphName
	
	String DFName = GraphDataFolderFullPath(GraphName)
	if (strlen(DFName) == 0)
		return ""
	endif
	
	String saveDF = GetDataFolder(1)

	if (!DataFolderExists(DFName ))
		STRUCT ScatterPlotMatrixInfo info
		SPM_GetInfoFromGraph(info, GraphName)		// This has to succede. If the graph isn't a scatter plot matrix graph, the call to GraphDataFolderFullPath() has already failed
		info.datafoldername = MakeGraphDataFolder(GraphName, 0)
		DFName = info.datafoldername
		SPM_StoreInfoInGraph(info, GraphName)
	endif
	
	SetDataFolder $GraphDataFolderFullPath(GraphName)

	return saveDF
end

Function SPM2_MarkPoint(MainWindow, subWindow, pointNumber, isX, xMarker, yMarker, markerSize)
	String MainWindow, subWindow
	Variable pointNumber
	Variable isX
	Variable xMarker, yMarker, markerSize
	
	String MarkWaveNameX="Mark"+MainWindow+"X"
	String MarkWaveNameY="Mark"+MainWindow+"Y"
	
	String SaveDF = SPM_SetGraphDataFolder(MainWindow)
		if (strlen(SaveDF) == 0)		// not a Scatter Plot Matrix graph
			return -1
		endif
		MarkWaveNameX = UniqueName(MarkWaveNameX, 1, 0)
		MarkWaveNameY = UniqueName(MarkWaveNameY, 1, 0)	
		Make/O/N=1 $MarkWaveNameX
		Make/O/N=1 $MarkWaveNameY
		Wave wx=$MarkWaveNameX
		Wave wy=$MarkWaveNameY
	SetDataFolder SaveDF
	
	String tname = StringFromList(0, TraceNameList(MainWindow+"#"+subWindow, ";", 1))
	Wave twy = TraceNametoWaveRef(MainWindow+"#"+subWindow, tname)
	Wave twx = XWaveRefFromTrace(MainWindow+"#"+subWindow, tname)
	if (WaveDims(twy) == 2)
		Variable i = str2num(StringFromList(1, tname, "_"))
		Variable j = str2num(StringFromList(2, tname, "_"))
		wy[0] = twy[pointNumber][i]
		wx[0] = twx[pointNumber][j]
	else
		wy[0] = twy[pointNumber]
		wx[0] = twx[pointNumber]
	endif
	AppendToGraph/W=$MainWindow#$subWindow wy vs wx
	
	ModifyGraph/W=$MainWindow#$subWindow  mode($MarkWaveNameY)=3, marker($MarkWaveNameY)=8, msize($MarkWaveNameY)=markerSize
	if (isX)
		ModifyGraph/W=$MainWindow#$subWindow  marker($MarkWaveNameY)=xMarker
	else
		ModifyGraph/W=$MainWindow#$subWindow  marker($MarkWaveNameY)=yMarker
	endif
end

Function SPM2_EmbeddedRemoveMarks(GName)
	String GName

	String plotList = ChildWindowList(GName)
	Variable nPlots = ItemsInList(plotList)
	Variable j

	for (j = 0; j < nPlots; j += 1)
		String SubGName = GName+"#"+StringFromList(j, plotList)
		
		String TraceNames=TraceNameList(SubGName, ";", 1)
		String ThisTrace
		
		Variable i=0
		do
			ThisTrace = StringFromList(i, TraceNames)
			if (strlen(ThisTrace) == 0)
				break
			endif
			if (cmpstr(ThisTrace[0,3], "Mark") == 0)
				Wave wx=XWaveRefFromTrace(SubGName, ThisTrace)
				Wave wy=TraceNameToWaveRef(SubGName, ThisTrace)
				RemoveFromGraph/W=$SubGName $ThisTrace
				KillWaves/z wx, wy
			endif
			i += 1
		while (1)
	endfor
end

Function SPM2_MarkCsrPntsBProc(ctrlName) : ButtonControl
	String ctrlName
	
	
	String MainWindow = WinName(0,1)	// work on the top graph

	STRUCT ScatterPlotMatrixInfo info
	Variable infoVersion = SPM_GetInfoFromGraph(info, MainWindow)
	if (infoVersion == 0)
		return -1		// not a Scatter Plot Matrix graph window
	endif
	STRUCT ScatterPlotMatrixInfo newInfo
	newInfo = info

	ControlInfo/W=ScatterPlotMatrixFindDataPanel ModSPM_MarkXMarker
	Variable MarkDataxMarkerNum = V_value-1
	
	ControlInfo/W=ScatterPlotMatrixFindDataPanel ModSPM_MarkYMarker
	Variable MarkDatayMarkerNum = V_value-1
	
	ControlInfo/W=ScatterPlotMatrixFindDataPanel ModSPM_FindDataMarkerSize
	Variable MarkDataMarkerSize = V_value
	
	if (info.UseEmbeddedGraphs)
		SPM2_FindMarkedPoint(MainWindow, MarkDataxMarkerNum, MarkDatayMarkerNum, MarkDataMarkerSize)
	else
		SPMFree_FindMarkedPoint(MainWindow, MarkDataxMarkerNum, MarkDatayMarkerNum, MarkDataMarkerSize)
	endif
End

Function SPM2_RmveMarksBProc(ctrlName) : ButtonControl
	String ctrlName
	
	String GName=WinName(0,1)
	STRUCT ScatterPlotMatrixInfo info
	if (SPM_GetInfoFromGraph(info, GName))
		if (info.UseEmbeddedGraphs)
			SPM2_EmbeddedRemoveMarks(GName)
		else
			SPM_FreeAxisRemoveMarks(GName)
		endif
	endif
end

Function MatrixPlot_SetXMarkMarker(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	NVAR gMPXMarker=root:Packages:WMScatterPlotMatrixPackage:gMPXMarker
	gMPXMarker = popNum-1
End

Function MatrixPlot_SetYMarkMarker(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	NVAR gMPYMarker=root:Packages:WMScatterPlotMatrixPackage:gMPYMarker
	gMPYMarker = popNum-1
End

Function SPM2_Regression(MainGraph, AddTraces, RobustFit)
	String MainGraph
	Variable AddTraces, RobustFit
	
 
	STRUCT ScatterPlotMatrixInfo info
	if (SPM_GetInfoFromGraph(info, MainGraph) == 0)
		return -1
	endif
	
	String plotList = ChildWindowList(MainGraph)
	Variable nPlots = ItemsInList(plotList)
	Variable i

	String XWave,YWave
	String NewWaveName=""
	Variable AutotraceOn
	Variable DoRobust = 0
	String TagName=""
	String AMessage
	Variable V_FitOptions=4	// Suppress progress window
	Variable V_FitError
	String tagtext = ""
	
	AutotraceOn = AddTraces
	
	DoWindow/F $MainGraph
	
	String SaveDF = SPM_SetGraphDataFolder(MainGraph)
	if (strlen(SaveDF) == 0)		// not a Scatter Plot Matrix graph
		return -1
	endif
	
	if (RobustFit)
		DoRobust = 1
		Make/N=2/O Fcoef = {0,1}
		Wave coef=Fcoef
	endif

	for (i = 0; i < nPlots; i += 1)
		String subWinName = MainGraph+"#"+StringFromList(i, plotList)
		Variable ii,jj
		ii = str2num(StringFromList(1, subWinName, "_"))
		jj = str2num(StringFromList(2, subWinName, "_"))
		if (ii == jj)
			continue
		endif

		SetActiveSubwindow $subWinName
		String ThisTrace = StringFromList(0, TraceNameList(subWinName, ";", 1))
		
		Wave w=TraceNameToWaveRef(subWinName, ThisTrace)
		Wave wavex = XWaveRefFromTrace(subWinName, ThisTrace)
		Variable xCol = 0
		Variable yCol = 0
		if (WaveDims(w) == 2)
			xCol = str2num(StringFromList(2, ThisTrace, "_"))
			yCol = str2num(StringFromList(1, ThisTrace, "_"))
		endif
		
		V_FitOptions = 4

		if (DoRobust)
			V_FitOptions += 2
			Duplicate/O Fcoef, Eps
			Wave e=Eps
			e=1
			V_FitError=0
			CurveFit/Q line, w[][yCol] /X=wavex[][xCol]
			Wave W_coef
			Fcoef = W_coef
			if (AutoTraceOn)
				FuncFit/N/Q SPM_LineFit,Fcoef w[][yCol] /X=wavex[][xCol]/D
//				DoUpdate
		
				Wave fitwave = $("Fit_"+NameOfWave(w))
				Wave/Z killfitwave = $("Fit_"+NameOfWave(w)+num2istr(i))
				if (WaveExists(killfitwave))
					Duplicate/O fitwave, $("Fit_"+NameOfWave(w)+num2istr(i))
					RemoveFromGraph/W=$subWinName $("Fit_"+NameOfWave(w))
					KillWaves/Z fitwave
				else
					Rename fitwave, $("Fit_"+NameOfWave(w)+num2istr(i))
				endif
			else
				FuncFit/N/Q SPM_LineFit,Fcoef, w[][yCol] /X=wavex[][xCol] /E=e
			endif
			if (V_FitError %& 2)
				sprintf AMessage, "Singular Matrix while fitting %s vs %s; Continue?",NameOfWave(w), NameOfWave(wavex)
				DoAlert 1, AMessage
				if (V_flag == 2)
					break;
				else
					tagtext = "Singular Matrix"
				endif
			else
				sprintf tagtext,"\Z09a=%g\rb=%g", Fcoef[0], Fcoef[1]
			endif
		else
			if (AutoTraceOn)
				CurveFit/Q line, w[][yCol] /X=wavex[][xCol]/D
		
				Wave fitwave = $("Fit_"+NameOfWave(w))
				Wave/Z killfitwave = $("Fit_"+NameOfWave(w)+num2istr(i))
				if (WaveExists(killfitwave))
					Duplicate/O fitwave, $("Fit_"+NameOfWave(w)+num2istr(i))
					RemoveFromGraph/W=$subWinName $("Fit_"+NameOfWave(w))
					KillWaves/Z fitwave
				else
					Rename fitwave, $("Fit_"+NameOfWave(w)+num2istr(i))
				endif
			else
				CurveFit/N/Q line, w[][yCol] /X=wavex[][xCol]
			endif
			Wave W_coef
			sprintf tagtext,"\Z09a=%g\rb=%g\rr=%g", W_coef[0], W_coef[1], V_Pr
		endif
		TagName = "MPR_"+num2istr(i)
		GetAxis/Q Left
		Tag/C/W=$subWinName/N=$TagName/L=0/X=0/Y=0/B=1/A=MC left, V_max, tagtext
	endfor
	
	SetDataFolder SaveDF
end

Function SPM2_RegressButProc(ctrlName) : ButtonControl
	String ctrlName
	
	String MainGraph = WinName(0,1)
	ControlInfo ModSPM_FitLinesCheck
	Variable  AddTraces = V_value
	ControlInfo ModSPM_RobustFit
	Variable RobustFit = V_value
	
	STRUCT ScatterPlotMatrixInfo info
	if (SPM_GetInfoFromGraph(info, MainGraph))
		if (info.UseEmbeddedGraphs)
			SPM2_Regression(MainGraph, AddTraces, RobustFit)
		else
			SPM_FreeAxisRegression(MainGraph, AddTraces, RobustFit)
		endif
	endif
End

Function SPM2_EmbeddedRmveTags(GName)
	String GName
	
	String plotList = ChildWindowList(GName)
	Variable nPlots = ItemsInList(plotList)
	Variable j

	for (j = 0; j < nPlots; j += 1)
		String SubGName = GName+"#"+StringFromList(j, plotList)
		
		String TagList=AnnotationList(SubGName)
		String ThisOne
		Variable i=0
		do
			ThisOne=StringFromList(i, TagList)
			if (strlen(ThisOne) == 0)
				break
			endif
			if (cmpstr("MPR_", ThisOne[0,3]) == 0)
				Tag/W=$SubGName/K /N=$ThisOne
			endif
			i += 1
		while (1)
	endfor
end

Function SPM2_RmveTagsButProc(ctrlName) : ButtonControl
	String ctrlName

	String GName=WinName(0,1)
	STRUCT ScatterPlotMatrixInfo info
	if (SPM_GetInfoFromGraph(info, GName))
		if (info.UseEmbeddedGraphs)
			SPM2_EmbeddedRmveTags(GName)
		else
			SPM_FreeAxisRmveTags(GName)
		endif
	endif
End

Function SPM_EmbeddedRemoveRegressTraces(GraphName)
	String GraphName

	String plotList = ChildWindowList(GraphName)
	Variable nPlots = ItemsInList(plotList)
	Variable j

	for (j = 0; j < nPlots; j += 1)
		String SubGName = GraphName+"#"+StringFromList(j, plotList)
		
		String TraceNames=TraceNameList(SubGName, ";", 1)
		String ThisTrace=""
		
		Variable i=0
		do
			ThisTrace = StringFromList(i, TraceNames)
			if (strlen(ThisTrace) == 0)
				break
			endif
			if (cmpstr(ThisTrace[0,3], "Fit_") == 0)
				Wave w=TraceNameToWaveRef(SubGName, ThisTrace)
				Wave/Z wavex = XWaveRefFromTrace(SubGName, ThisTrace)
				RemoveFromGraph/W=$SubGName $ThisTrace
				KillWaves/Z w, wavex
			endif
			i += 1
		while (1)
	endfor
end

Function SPM2_RemoveRegressTraces(ctrlName) : ButtonControl
	String ctrlName
	
	String GName=WinName(0,1)
	STRUCT ScatterPlotMatrixInfo info
	if (SPM_GetInfoFromGraph(info, GName))
		if (info.UseEmbeddedGraphs)
			SPM_EmbeddedRemoveRegressTraces(GName)
		else
			SPM_FreeAxisRemoveRegressTraces(GName)
		endif
	endif
End

xFunction/D LineFit(w, xx)
	Wave w
	Variable xx
	
	return w[0]+w[1]*xx
end

Function RemoveRegressTracesTagsTraces(ctrlName) : ButtonControl
	String ctrlName
	
	String GName=WinName(0,1)
	STRUCT ScatterPlotMatrixInfo info
	if (SPM_GetInfoFromGraph(info, GName))
		if (info.UseEmbeddedGraphs)
			SPM_EmbeddedRemoveRegressTraces(GName)
			SPM2_EmbeddedRmveTags(GName)
		else
			SPM_FreeAxisRemoveRegressTraces(GName)
			SPM_FreeAxisRmveTags(GName)
		endif
	endif
end

Function SPM2_RegressTagPositionFree(GName, Anchor, Axis, Position)
	String GName, Anchor, Axis
	Variable Position

	String TagList=AnnotationList(GName)
	String ThisOne
	Variable i
	Variable nItems = ItemsInList(TagList)
	for (i = 0; i < nItems; i += 1)
		ThisOne=StringFromList(i, TagList)
		if (cmpstr("MPR_", ThisOne[0,3]) == 0)
			String aInfo = AnnotationInfo(GName, ThisOne)
			String axisName = StringByKey("YWAVE", aInfo)
			if (CmpStr(Axis, "Bottom") == 0)
				axisName[0,0] = "X"
			else
				axisName[0,0] = "Y"
			endif
			GetAxis/Q $axisName
			Variable AttachX = V_min + Position*(V_max-V_min)
			Tag/W=$GName/N=$ThisOne/C/A=$Anchor $axisName AttachX
		endif
	endfor
end

Function SPM2_RegressTagPositionEmbed(GName, Anchor, Axis, Position)
	String GName, Anchor, Axis
	Variable Position
	
	String plotList = ChildWindowList(GName)
	Variable nPlots = ItemsInList(plotList)
	Variable j

	for (j = 0; j < nPlots; j += 1)
		String SubGName = GName+"#"+StringFromList(j, plotList)
		
		String TagList=AnnotationList(SubGName)
		String ThisOne
		Variable i=0
		Variable nItems = ItemsInList(TagList)
		for (i = 0; i < nItems; i += 1)
			ThisOne=StringFromList(i, TagList)
			if (cmpstr("MPR_", ThisOne[0,3]) == 0)
				String aInfo = AnnotationInfo(SubGName, ThisOne)
				GetAxis/Q/W=$SubGName $Axis
				Variable AttachX = V_min + Position*(V_max-V_min)
				Tag/W=$SubGName/N=$ThisOne/C/A=$Anchor $Axis AttachX
			endif
		endfor
	endfor
end

Function SPM2_RegressTagPosition(GName, Anchor, Axis, Position)
	String GName, Anchor, Axis
	Variable Position

	STRUCT ScatterPlotMatrixInfo info
	if (SPM_GetInfoFromGraph(info, GName) == 0)
		return 0
	endif
	
	if (info.UseEmbeddedGraphs)
		SPM2_RegressTagPositionEmbed(GName, Anchor, Axis, Position)
	else
		SPM2_RegressTagPositionFree(GName, Anchor, Axis, Position)
	endif
end

StrConstant anchorCodes="LT;LC;LB;MT;MC;MB;RT;RC;RB;"
Function/S SPM2_TagAnchorMenuToCode(menuItem)
	Variable menuItem
	
	return StringFromList(menuItem-1, anchorCodes)
end

Function ModSPM_TagAnchorMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	String GName=WinName(0,1)
	STRUCT ScatterPlotMatrixInfo info
	if (SPM_GetInfoFromGraph(info, GName))
//		if (!info.UseEmbeddedGraphs)
			ControlInfo ModSPM_TagAxis
			String AxisCode = S_value
			NVAR gMPTagAxisFraction = root:Packages:WMScatterPlotMatrixPackage:gMPTagAxisFraction
			SPM2_RegressTagPosition(GName, SPM2_TagAnchorMenuToCode(popNum), AxisCode, gMPTagAxisFraction)
//		endif
	endif
End

Function ModSPM_TagAxisMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	String GName=WinName(0,1)
	STRUCT ScatterPlotMatrixInfo info
	if (SPM_GetInfoFromGraph(info, GName))
//		if (!info.UseEmbeddedGraphs)
			ControlInfo ModSPM_TagAnchorMenu
			Variable AnchorItem = V_value
			NVAR gMPTagAxisFraction = root:Packages:WMScatterPlotMatrixPackage:gMPTagAxisFraction
			SPM2_RegressTagPosition(GName, SPM2_TagAnchorMenuToCode(AnchorItem), popStr, gMPTagAxisFraction)
//		endif
	endif
End

Function ModSPM_SetTagAxisPositionProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	String GName=WinName(0,1)
	STRUCT ScatterPlotMatrixInfo info
	if (SPM_GetInfoFromGraph(info, GName))
//		if (!info.UseEmbeddedGraphs)
			ControlInfo ModSPM_TagAnchorMenu
			Variable AnchorItem = V_value
			ControlInfo ModSPM_TagAxis
			String AxisCode = S_value
			NVAR gMPTagAxisFraction = root:Packages:WMScatterPlotMatrixPackage:gMPTagAxisFraction
			SPM2_RegressTagPosition(GName, SPM2_TagAnchorMenuToCode(AnchorItem), AxisCode, gMPTagAxisFraction)
//		endif
	endif
End

static constant modSPM_TraceTab = 0
static constant modSPM_AxesTab = 1
static constant modSPM_PlotsTab = 2

Function fScatterPlotMatrixModifyPanel() : Panel

	if (WinType("ScatterPlotMatrixModifyPanel") == 7)
		DoWindow/F ScatterPlotMatrixModifyPanel
	else
		SPM2_MatrixPlotGlobals()		

		string cmd = "NewPanel /K=1/W=(%s) as \"Modify Scatter Plot Matrix\""
		execute WC_WindowCoordinatesSprintf("ScatterPlotMatrixModifyPanel", cmd, 25,40,392,306, PanelResolution("ScatterPlotMatrixModifyPanel") == 72)
//		NewPanel/K=1 /W=(518,283,885,549) as "Modify Scatter Plot Matrix"
		DoWindow/C ScatterPlotMatrixModifyPanel
		ModifyPanel fixedSize=1
			
		TabControl ModScatterPlotMatrixTabControl,pos={6,8},size={355,239},proc=ModSPM_TabProc
		TabControl ModScatterPlotMatrixTabControl,tabLabel(modSPM_TraceTab)="Traces"
		TabControl ModScatterPlotMatrixTabControl,tabLabel(modSPM_AxesTab)="Axes"
		TabControl ModScatterPlotMatrixTabControl,tabLabel(modSPM_PlotsTab)="Plots"

		Button SPM2_PlotMethodHelpButton,pos={340,3},size={20,20},proc=SPM_ModifyHelpButtonProc,title="?"
	
		// tab 0- trace appearance
		PopupMenu ModSPM_TraceModePop,pos={38,47},size={170,20},title="Mode:", proc=ModSPM_PopProc
		PopupMenu ModSPM_TraceModePop,help={"Choose how you want the data to be shown on the plots."}
		PopupMenu ModSPM_TraceModePop,mode=4,bodyWidth= 140,value= #"\"Dots;Markers;Lines;Lines and Markers\""
	
		PopupMenu ModSPM_MarkerMenu,pos={43,95},size={90,20},title="Marker:", proc=ModSPM_PopProc
		PopupMenu ModSPM_MarkerMenu,mode=17,bodyWidth= 50,popvalue="",value= #"\"*MARKERPOP*\""

		PopupMenu ModSPM_TraceRGBPop,pos={23,121},size={120,20},title="Trace Color:",proc=ModSPM_PopProc
		PopupMenu ModSPM_TraceRGBPop,mode=1,bodyWidth= 60,popColor= (1,16019,65535),value= #"\"*COLORPOP*\""

		PopupMenu ModSPM_LineTypePop,pos={31,147},size={152,20},title="Line Style:", proc=ModSPM_PopProc
		PopupMenu ModSPM_LineTypePop,mode=1,bodyWidth= 100,popvalue="",value= #"\"*LINESTYLEPOP*\""
	
		SetVariable ModSPM_SetMarkerSize,pos={227,100},size={113,15},title="Marker Size:",proc=ModSPM_SetValueProc,live=1
		SetVariable ModSPM_SetMarkerSize,help={"Sets the size of the markers used to plot the data."}
		SetVariable ModSPM_SetMarkerSize,limits={0,10,1},value= root:Packages:WMScatterPlotMatrixPackage:gMPModMarkerSize,bodyWidth= 50

		SetVariable ModSPM_SetLineSize,pos={217,144},size={123,15},title="Line Thickness:",proc=ModSPM_SetValueProc,live=1
		SetVariable ModSPM_SetLineSize,help={"Sets the line thickness for the data trace when you have chosen Lines or Lines and Markers mode in the Trace Mode popup."}
		SetVariable ModSPM_SetLineSize,limits={0,10,1},value= root:Packages:WMScatterPlotMatrixPackage:gMPModLineSize,bodyWidth= 50

		SetVariable ModSPM_SetMarkerThick,pos={202,122},size={138,15},title="Marker Thickness:",proc=ModSPM_SetValueProc,live=1
		SetVariable ModSPM_SetMarkerThick,help={"Sets the thickness of the line used to draw marker outlines."}
		SetVariable ModSPM_SetMarkerThick,limits={0,10,1},value= root:Packages:WMScatterPlotMatrixPackage:gMPMarkerThick,bodyWidth= 50
		
		CheckBox ModSPM_OpaqueMarkerCheck,pos={83,176},size={90,14},proc=ModSPM_CheckProc,title="Opaque Markers"
		CheckBox ModSPM_OpaqueMarkerCheck,value= 0

		CheckBox ModSPM_UseStrokeColorCheck,pos={34,202},size={130,14},proc=ModSPM_CheckProc,title="Use Marker Stroke Color"
		CheckBox ModSPM_UseStrokeColorCheck,value= 0
	
		PopupMenu ModSPM_MarkerStrokeColorMenu,pos={36,218},size={146,20},proc=ModSPM_PopProc,title="Marker Stroke Color"
		PopupMenu ModSPM_MarkerStrokeColorMenu,mode=1,popColor= (3,52428,1),value= #"\"*COLORPOP*\""

		// axis appearance tab
		
		CheckBox SPM_AxisStandoffCheckBox,pos={28,39},size={80,14},proc=ModSPM_CheckProc,title="Axis Standoff"
		CheckBox SPM_AxisStandoffCheckBox,value= 1

		PopupMenu SPM_AxisColor,pos={28,58},size={101,20},proc=ModSPM_PopProc,title="Axis Color"
		PopupMenu SPM_AxisColor,mode=1,popColor= (0,0,0),value= #"\"*COLORPOP*\""

		SetVariable SPM_SetAxisThickness,pos={28,84},size={132,15},proc=ModSPM_SetValueProc,title="Axis Thickness"
		SetVariable SPM_SetAxisThickness,limits={0,5,0.1},value= root:Packages:WMScatterPlotMatrixPackage:gMPAxisThickness,bodyWidth= 60,live= 1
	
		PopupMenu ModSMP_VertTLabelRot,pos={18,165},size={172,20},proc=ModSPM_PopProc,title="Y Axis Tick Label Rotation"
		PopupMenu ModSMP_VertTLabelRot,mode=1,popvalue="180",value= #"\"180;90;0; -90\""

		PopupMenu ModSMP_HorizTLabelRot,pos={18,189},size={172,20},proc=ModSPM_PopProc,title="X Axis Tick Label Rotation"
		PopupMenu ModSMP_HorizTLabelRot,mode=1,popvalue="180",value= #"\"180;90;0; -90\""

		SetVariable ModSPM_YAxisLabelPos,pos={18,115},size={141,15},proc=ModSPM_SetValueProc,title="Y Axis Label Offset",live=1
		SetVariable ModSPM_YAxisLabelPos,value= root:Packages:WMScatterPlotMatrixPackage:gMPYLabelPosition,bodyWidth= 50

		SetVariable ModSPM_XAxisLabelPos,pos={18,134},size={141,15},proc=ModSPM_SetValueProc,title="X Axis Label Offset",live=1
		SetVariable ModSPM_XAxisLabelPos,value= root:Packages:WMScatterPlotMatrixPackage:gMPXLabelPosition,bodyWidth= 50

		CheckBox ModSPM_TicksOnOff,pos={202,38},size={69,14},title="Show Ticks",value= 0,proc=ModSPM_CheckProc

		PopupMenu ModSPM_TickPosition,pos={211,61},size={141,20},proc=ModSPM_PopProc,title="Tick Position"
		PopupMenu ModSPM_TickPosition,mode=2,bodyWidth= 80,popvalue="Crossing",value= #"\"Outside;Crossing;Inside;\""

		PopupMenu ModSPM_GridsMenu,pos={236,89},size={116,20},proc=ModSPM_PopProc,title="Grids"
		PopupMenu ModSPM_GridsMenu,mode=3,popvalue="Major Only",value= #"\"Off;On;Major Only\""
		
		CheckBox SPM_RangeIgnoreNaNCheckBox,pos={16,225},size={136,14},title="Ignore NaN for Axis Range",proc=ModSPM_CheckProc
		CheckBox SPM_RangeIgnoreNaNCheckBox,value= 0

		// Plot appearance tab
		CheckBox ModSPM_ColoredBackgroundCheck,pos={19,31},size={106,14},disable=1,title="Colored Background",proc=ModSPM_CheckProc
		CheckBox ModSPM_ColoredBackgroundCheck,value= 1

		PopupMenu ModSPM_BackgroundColor,pos={42,50},size={131,20},disable=1,title="Background Color",proc=ModSPM_PopProc
		PopupMenu ModSPM_BackgroundColor,mode=1,bodyWidth= 50,popColor= (65535,65534,49151),value= #"\"*COLORPOP*\""

		CheckBox ModSPM_PlotFramesCheckBox,pos={219,31},size={133,14},disable=1,title="Frames Around Sub-Plots",proc=ModSPM_CheckProc
		CheckBox ModSPM_PlotFramesCheckBox,value= 1

		GroupBox PlotsTab_OverallMarginsGroup,pos={17,74},size={333,58},title="Main Window Margins (Points; zero = auto)"
	
			SetVariable ModSPM_SetLeftMargin,pos={51,90},size={116,15},disable=1,title="Left Margin",proc=ModSPM_SetValueProc,live=1
			SetVariable ModSPM_SetLeftMargin,value= root:Packages:WMScatterPlotMatrixPackage:gMPLeftMargin,bodyWidth= 60
	
			SetVariable ModSPM_SetBottomMargin,pos={37,110},size={130,15},disable=1,title="Bottom Margin",proc=ModSPM_SetValueProc,live=1
			SetVariable ModSPM_SetBottomMargin,value= root:Packages:WMScatterPlotMatrixPackage:gMPBottomMargin,bodyWidth= 60
	
			SetVariable ModSPM_SetRightMargin,pos={215,90},size={121,15},disable=1,title="Right Margin",proc=ModSPM_SetValueProc,live=1
			SetVariable ModSPM_SetRightMargin,value= root:Packages:WMScatterPlotMatrixPackage:gMPRightMargin,bodyWidth= 60
	
			SetVariable ModSPM_SetTopMargin,pos={222,110},size={114,15},disable=1,title="Top Margin",proc=ModSPM_SetValueProc,live=1
			SetVariable ModSPM_SetTopMargin,value= root:Packages:WMScatterPlotMatrixPackage:gMPTopMargin,bodyWidth= 60

		GroupBox PlotsTab_SubPlotMarginsGroup1,pos={17,147},size={333,58},title="Sub-Plot Margins"
			SetVariable ModSPM_LeftInset,pos={30,164},size={147,15},title="Left Inset Fraction",proc=ModSPM_SetValueProc,live=1
			SetVariable ModSPM_LeftInset,value= root:Packages:WMScatterPlotMatrixPackage:gMPLeftInsetFraction,bodyWidth= 60
			SetVariable ModSPM_LeftInset limits={0,1,0.01}

			SetVariable ModSPM_RightInset,pos={25,184},size={152,15},title="Right Inset Fraction",proc=ModSPM_SetValueProc,live=1
			SetVariable ModSPM_RightInset,value= root:Packages:WMScatterPlotMatrixPackage:gMPRightInsetFraction,bodyWidth= 60
			SetVariable ModSPM_RightInset limits={0,1,0.01}

			SetVariable ModSPM_BottomInset,pos={184,184},size={161,15},title="Bottom Inset Fraction",proc=ModSPM_SetValueProc,live=1
			SetVariable ModSPM_BottomInset,value= root:Packages:WMScatterPlotMatrixPackage:gMPBottomInsetFraction,bodyWidth= 60
			SetVariable ModSPM_BottomInset limits={0,1,0.01}

			SetVariable ModSPM_TopInset,pos={200,164},size={145,15},title="Top Inset Fraction",proc=ModSPM_SetValueProc,live=1
			SetVariable ModSPM_TopInset,value= root:Packages:WMScatterPlotMatrixPackage:gMPTopInsetFraction,bodyWidth= 60
			SetVariable ModSPM_TopInset limits={0,1,0.01}

			SetVariable ModSPM_SetVGroutFraction,pos={60,164},size={147,15},title="Vertical Grout Fraction",proc=ModSPM_SetValueProc,live=1
			SetVariable ModSPM_SetVGroutFraction,value= root:Packages:WMScatterPlotMatrixPackage:gMPVerticalGroutFraction,bodyWidth= 60
			SetVariable ModSPM_SetVGroutFraction limits={0,1,0.01}

			SetVariable ModSPM_SetHGroutFraction,pos={60,184},size={147,15},title="Horizontal Grout Fraction",proc=ModSPM_SetValueProc,live=1
			SetVariable ModSPM_SetHGroutFraction,value= root:Packages:WMScatterPlotMatrixPackage:gMPHorizontalGroutFraction,bodyWidth= 60
			SetVariable ModSPM_SetHGroutFraction limits={0,1,0.01}
	
		STRUCT WMTabControlAction initTabStruct
		initTabStruct.tab = modSPM_TraceTab
		initTabStruct.eventCode = 2		// mouse up
		ModSPM_TabProc(initTabStruct)
		
		STRUCT ScatterPlotMatrixInfo info
		if (SPM_GetInfoFromGraph(info, WinName(0,1)))
			ModSPM_SyncPanelToInfo(info)
		endif
		
		SetWindow ScatterPlotMatrixModifyPanel, hook(ModSPM_PanelHook) = ModSPM_PanelActivateHook
	endif
End

Function fScatterPlotMatrixFindDataPanel() : Panel

	if (WinType("ScatterPlotMatrixFindDataPanel") == 7)
		DoWindow/F ScatterPlotMatrixFindDataPanel
	else
		SPM2_MatrixPlotGlobals()		

		string cmd = "NewPanel /K=1/W=(%s) as \"Scatter Plot Matrix: Find Data\""
		execute WC_WindowCoordinatesSprintf("ScatterPlotMatrixFindDataPanel", cmd, 25,40,392,256, PanelResolution("ScatterPlotMatrixFindDataPanel") == 72)
//		NewPanel/K=1 /W=(518,283,885,549) as "Modify Scatter Plot Matrix"
		DoWindow/C ScatterPlotMatrixFindDataPanel
		ModifyPanel fixedSize=1
			
		Button SPM2_PlotMethodHelpButton,pos={340,3},size={20,20},proc=SPM_FindDataHelpButtonProc,title="?"
	
		Button ModSPM_MarkPoints,pos={25,165},size={103,20},proc=SPM2_MarkCsrPntsBProc,title="Mark Csr Pnts"
		Button ModSPM_MarkPoints,help={"Mark any point on the plot with a graph cursor.  When this button is clicked, every point on the plot that uses that Y value (as either X or Y data) will be marked.\r\rTo make the cursors available, select \"Show Info\" from the Graph menu."}
	
		Button ModSPM_UnMarkPoints,pos={226,166},size={103,20},proc=SPM2_RmveMarksBProc,title="Remove Marks"
		Button ModSPM_UnMarkPoints,help={"Removes all the markers from the graph."}
	
		PopupMenu ModSPM_MarkXMarker,pos={31,57},size={99,20},title="X Marker:"
		PopupMenu ModSPM_MarkXMarker,mode=17,bodyWidth= 50,popvalue="",value= #"\"*MARKERPOP*\""
	
		PopupMenu ModSPM_MarkYMarker,pos={151,57},size={99,20},title="Y Marker:"
		PopupMenu ModSPM_MarkYMarker,mode=19,bodyWidth= 50,popvalue="",value= #"\"*MARKERPOP*\""
	
		SetVariable ModSPM_FindDataMarkerSize,pos={96,99},size={98,15},title="Marker Size:"
		SetVariable ModSPM_FindDataMarkerSize,help={"Sets the size of the marker to use when marking points.  This box sets the marker size for all marked points."}
		SetVariable ModSPM_FindDataMarkerSize,fSize=9
		SetVariable ModSPM_FindDataMarkerSize,limits={0,10,1},value= root:Packages:WMScatterPlotMatrixPackage:gMPMarkerSize,bodyWidth= 35
		
		SetWindow ScatterPlotMatrixFindDataPanel, hook = WC_WindowCoordinatesHook
	endif
End

Function fScatterPlotMatrixRegressPanel() : Panel

	if (WinType("ScatterPlotMatrixRegressPanel") == 7)
		DoWindow/F ScatterPlotMatrixRegressPanel
	else
		SPM2_MatrixPlotGlobals()		

		string cmd = "NewPanel /K=1/W=(%s) as \"Scatter Plot Matrix: Regression\""
		execute WC_WindowCoordinatesSprintf("ScatterPlotMatrixRegressPanel", cmd, 25,40,392,306, PanelResolution("ScatterPlotMatrixRegressPanel") == 72)
//		NewPanel/K=1 /W=(518,283,885,549) as "Modify Scatter Plot Matrix"
		DoWindow/C ScatterPlotMatrixRegressPanel
		ModifyPanel fixedSize=1
			
		Button SPM2_PlotMethodHelpButton,pos={340,3},size={20,20},proc=SPM_RegressionHelpButtonProc,title="?"
	
		Button ModSPM_RegressButton,pos={79,55},size={104,20},proc=SPM2_RegressButProc,title="Do Regression"
		Button ModSPM_RegressButton,help={"Do a linear fit to the data in each sub-plot.  Tags will be attached to each plot with information on the results."}
	
		CheckBox ModSPM_FitLinesCheck,pos={38,19},size={84,14},title="Add Fit Traces"
		CheckBox ModSPM_FitLinesCheck,help={"When doing the linear regression, add a trace to each plot showing the regression result.\r\rAlso makes a wave to contain the data resulting from the regression"}
		CheckBox ModSPM_FitLinesCheck,value= 1
	
		CheckBox ModSPM_RobustFit,pos={147,19},size={73,14},title="\"Robust\" Fit"
		CheckBox ModSPM_RobustFit,help={"When doing the linear regression, use least absolute error method instead of least squares.  The least absolute error method is less sensitive to outliers."}
		CheckBox ModSPM_RobustFit,value=0
	
		GroupBox ModSPM_RegressRemoveGroup,pos={39,197},size={298,57},title="Remove"
	
			Button ModSPM_RmvRegressTags,pos={67,221},size={49,20},proc=SPM2_RmveTagsButProc,title="Tags"
			Button ModSPM_RmvRegressTags,help={"Remove from the top graph all tags produced by the Do Regression button."}
		
			Button ModSPM_RmvRegressTraces,pos={130,221},size={49,20},proc=SPM2_RemoveRegressTraces,title="Traces"
			Button ModSPM_RmvRegressTraces,help={"Remove from the top graph all traces produced by the Do Regression button.  Also kills the waves associated with those traces."}
		
			Button ModSPM_RmvRegressTagsTraces,pos={194,221},size={120,20},proc=RemoveRegressTracesTagsTraces,title="Tags and Traces"
			Button ModSPM_RmvRegressTagsTraces,help={"Remove from the top graph all traces produced by the Do Regression button.  Also kills the waves associated with those traces."}

		GroupBox ModSPM_RegressTagGroup,pos={39,91},size={298,95},title="Tags"
		
			PopupMenu ModSPM_TagAnchorMenu,pos={49,115},size={135,20},proc=ModSPM_TagAnchorMenuProc,title="Anchor"
			PopupMenu ModSPM_TagAnchorMenu,mode=9,popvalue="Right Bottom",value= #"\"Left Top;Left Center;Left Bottom;Mid Top;Mid Center;Mid Bottom;Right Top;Right Center;Right Bottom;\""
			
			PopupMenu ModSPM_TagAxis,pos={209,115},size={91,20},proc=ModSPM_TagAxisMenuProc,title="Axis"
			PopupMenu ModSPM_TagAxis,mode=2,value= #"\"Left;Bottom\""
			
			SetVariable ModSPM_SetTagAxisPosition,pos={95,155},size={200,15},proc=ModSPM_SetTagAxisPositionProc,title="Fractional Position Along Axis"
			SetVariable ModSPM_SetTagAxisPosition,limits={0,1,0.1},value= root:Packages:WMScatterPlotMatrixPackage:gMPTagAxisFraction,bodyWidth= 60,live= 1
			
		SetWindow ScatterPlotMatrixRegressPanel, hook(SPM2_CoordinateHook) = WC_WindowCoordinatesHook
		SetWindow ScatterPlotMatrixRegressPanel, hook(SPM2_Activation)=SPM2_RegressActivateHook
	endif
End

Function SPM2_RegressActivateHook(s)
	STRUCT WMWinHookStruct &s
	
	STRUCT ScatterPlotMatrixInfo info
	if (SPM_GetInfoFromGraph(info, WinName(0,1)) == 0)
		return 0
	endif
	
	if (s.eventCode == 0)		// activate
//		Variable show = info.UseEmbeddedGraphs == 0
//		GroupBox ModSPM_RegressTagGroup,disable=!show
//		PopupMenu ModSPM_TagAnchorMenu,disable=!show
//		PopupMenu ModSPM_TagAxis,disable=!show
//		SetVariable ModSPM_SetTagAxisPosition,disable=!show
		
		String tagName, windowName
		if (info.UseEmbeddedGraphs)
			windowName = WinName(0,1)+"#"+StringFromList(1, ChildWindowList(WinName(0,1)))		// graph0 may be a diagonal label only
			tagName = StringFromList(0, AnnotationList(windowName))
			if (strlen(tagName) == 0)
				return 0
			endif
		else
			windowName = WinName(0,1)
			tagName = "MPR_0"
			if (strlen(AnnotationList(windowName)) == 0)
				return 0
			endif
		endif
		
//		if (!info.UseEmbeddedGraphs)
			if (WhichListItem(tagName, AnnotationList(windowName)) >= 0)
				String aInfo = AnnotationInfo(windowName, tagName)
				if (strlen(aInfo) <= 0)
					return 0
				endif
				
				Variable anchorPos = StrSearch(aInfo, "/A=", 0)
				String AnchorCode = aInfo[anchorPos+3, anchorPos+4]
				PopupMenu ModSPM_TagAnchorMenu,mode=WhichListItem(AnchorCode, anchorCodes)+1
				
				String AxisName = StringByKey("YWAVE", aInfo)
				if (info.UseEmbeddedGraphs)
					if (CmpStr(AxisName, "bottom") == 0)
						PopupMenu ModSPM_TagAxis,mode=2
					else
						PopupMenu ModSPM_TagAxis,mode=1
					endif
				else
					if (CmpStr(AxisName[0], "X") == 0)
						PopupMenu ModSPM_TagAxis,mode=2
					else
						PopupMenu ModSPM_TagAxis,mode=1
					endif
				endif
				
				NVAR gMPTagAxisFraction = root:Packages:WMScatterPlotMatrixPackage:gMPTagAxisFraction
				GetAxis/Q/W=$windowName $AxisName
				gMPTagAxisFraction = (NumberByKey("ATTACHX", aInfo)-V_min)/(V_max - V_min)
			endif
//		endif
	endif
end

Function ModSPM_PopProc(s) : PopupMenuControl
	STRUCT WMPopupAction &s
	
	switch (s.eventCode)
		case 2:				// mouse up
			String MainWindow = WinName(0,1)	// work on the top graph
		
			STRUCT ScatterPlotMatrixInfo info
			if (SPM_GetInfoFromGraph(info, MainWindow) == 0)
				return -1		// not a Scatter Plot Matrix graph window
			endif
			
			String colorString
			
			strswitch(s.ctrlName)
				case "ModSPM_TraceModePop":
					info.TraceMode = TraceModePopNumToModeNumber(s.popNum)
					break;
				case "ModSPM_MarkerMenu":
					info.MarkerNumber = s.popNum-1					
					break;
				case "ModSPM_TraceRGBPop":
					colorString = s.popstr
					colorString = colorString[1,strlen(colorString)-2]
					info.TraceColorRed = str2num(StringFromList(0, colorString, ","))
					info.TraceColorGreen = str2num(StringFromList(1, colorString, ","))
					info.TraceColorBlue = str2num(StringFromList(2, colorString, ","))
					break;
				case "ModSPM_LineTypePop":
					info.LineStyle = s.popNum-1					
					break;
				case "SPM_AxisColor":
					colorString = s.popstr
					colorString = colorString[1,strlen(colorString)-2]
					info.AxisColorRed = str2num(StringFromList(0, colorString, ","))
					info.AxisColorGreen = str2num(StringFromList(1, colorString, ","))
					info.AxisColorBlue = str2num(StringFromList(2, colorString, ","))
					break;
				case "ModSPM_BackgroundColor":
					colorString = s.popstr
					colorString = colorString[1,strlen(colorString)-2]
					info.PlotBackColorRed = str2num(StringFromList(0, colorString, ","))
					info.PlotBackColorGreen = str2num(StringFromList(1, colorString, ","))
					info.PlotBackColorBlue = str2num(StringFromList(2, colorString, ","))
					
					// as a service to the user, set the colored background checkbox also
					checkbox ModSPM_ColoredBackgroundCheck,win=ScatterPlotMatrixModifyPanel, value=1
					info.PlotOptions = info.PlotOptions | PO_ColoredBoxes
					break;
				case "ModSPM_MarkerStrokeColorMenu":
					colorString = s.popstr
					colorString = colorString[1,strlen(colorString)-2]
					info.MarkerStrokeRed = str2num(StringFromList(0, colorString, ","))
					info.MarkerStrokeGreen = str2num(StringFromList(1, colorString, ","))
					info.MarkerStrokeBlue = str2num(StringFromList(2, colorString, ","))
					
					CheckBox ModSPM_UseStrokeColorCheck,win=ScatterPlotMatrixModifyPanel, value=1
					info.UseMarkerStroke = 1
					break;
				case "ModSMP_VertTLabelRot":
					info.YTickLabelRot = str2num(s.popStr)
					break;
				case "ModSMP_HorizTLabelRot":
					info.XTickLabelRot = str2num(s.popStr)
					break;
				case "ModSPM_TickPosition":
					info.TickPosition = s.popNum-1
					break;
				case "ModSPM_GridsMenu":
					info.GridOnOff = s.popNum-1
					break;
				default:
					String errormsg
					sprintf errormsg,"BUG: unknown control name: %s",s.ctrlName
					DoAlert 0,errormsg
			endswitch
					
			SPM_ApplyMods(MainWindow, info)
			break;
	endswitch
End

Function ModSPM_CheckProc(s) : CheckBoxControl
	STRUCT WMCheckboxAction &s

	switch (s.eventCode)
		case 2:			// mouse up
			String MainWindow = WinName(0,1)	// work on the top graph
		
			STRUCT ScatterPlotMatrixInfo info
			if (SPM_GetInfoFromGraph(info, MainWindow) == 0)
				return -1		// not a Scatter Plot Matrix graph window
			endif
			
			strswitch(s.ctrlName)
				case "SPM_AxisStandoffCheckBox":
					info.AxisStandoff = s.checked					
					break;
				case "ModSPM_ColoredBackgroundCheck":
					if (s.checked)
						info.PlotOptions = info.PlotOptions | PO_ColoredBoxes
					else
						info.PlotOptions = info.PlotOptions & ~PO_ColoredBoxes
					endif
					break;
				case "ModSPM_PlotFramesCheckBox":
					info.Frames = s.checked
					break;
				case "ModSPM_OpaqueMarkerCheck":
					info.OpaqueMarkers = s.checked
					break;
				case "ModSPM_UseStrokeColorCheck":
					info.UseMarkerStroke = s.checked
					break;
				case "ModSPM_TicksOnOff":
					if (s.checked)		// show ticks
						info.PlotOptions = info.PlotOptions & ~PO_NoTicksOrLabels
					else
						info.PlotOptions = info.PlotOptions | PO_NoTicksOrLabels
					endif
					break;
				case "SPM_RangeIgnoreNaNCheckBox":
					info.AxisRangeMode = s.checked
					break;
				default:
					String errormsg
					sprintf errormsg,"BUG: unknown control name: %s",s.ctrlName
					DoAlert 0,errormsg
			endswitch

			SPM_ApplyMods(MainWindow, info)
			break;
	endswitch
End

Function ModSPM_SetValueProc(s) : SetVariableControl
	STRUCT WMSetVariableAction &s

	switch (s.eventCode)
		case 1:			// mouse up
		case 2:			// Enter key
		case 3:			// live update
			String MainWindow = WinName(0,1)	// work on the top graph
		
			STRUCT ScatterPlotMatrixInfo info
			if (SPM_GetInfoFromGraph(info, MainWindow) == 0)
				return -1		// not a Scatter Plot Matrix graph window
			endif
			
			strswitch(s.ctrlName)
				case "ModSPM_SetMarkerSize":
					info.MarkerSize = s.dval					
					break;
				case "ModSPM_SetLineSize":
					info.LineSize = s.dval					
					break;
				case "ModSPM_SetMarkerThick":
					info.MarkerThickness = s.dval					
					break;
				case "SPM_SetAxisThickness":
					info.AxisThickness = s.dval					
					break;
				case "ModSPM_SetLeftMargin":
					info.LeftMargin = s.dval					
					break;
				case "ModSPM_SetBottomMargin":
					info.BottomMargin = s.dval					
					break;
				case "ModSPM_SetRightMargin":
					info.RightMargin = s.dval					
					break;
				case "ModSPM_SetTopMargin":
					info.TopMargin = s.dval					
					break;
				case "ModSPM_LeftInset":
					info.LeftInsetFraction = s.dval					
					break;
				case "ModSPM_RightInset":
					info.RightInsetFraction = s.dval					
					break;
				case "ModSPM_BottomInset":
					info.BottomInsetFraction = s.dval					
					break;
				case "ModSPM_TopInset":
					info.TopInsetFraction = s.dval					
					break;
				case "ModSPM_SetVGroutFraction":
					info.VerticalGroutFraction = s.dval					
					break;
				case "ModSPM_SetHGroutFraction":
					info.HorizontalGroutFraction = s.dval					
					break;
				case "ModSPM_YAxisLabelPos":
					info.YAxisLabelPos = s.dval
					break;
				case "ModSPM_XAxisLabelPos":
					info.XAxisLabelPos = s.dval
					break;
				default:
					String errormsg
					sprintf errormsg,"BUG: unknown control name: %s",s.ctrlName
					DoAlert 0,errormsg
			endswitch
			SPM_ApplyMods(MainWindow, info)
			break;
	endswitch
End

// This function sets a global variable that flags the fact that a Scatter Plot Matrix graph is being modified. The modification process goes like this:
//
//	Read info from graph
//	Compare info from graph with new info
//	Make changes to the graph as needed by the changed info
//	Write the new info back to the graph if changes were made
//
//	This process has the potential to be interrupted by the ScatterPlotMatrixModifyPanel's activate event. When you select "other" in a popup color menu
//	the color picker dialog causes an activate event to be sent to the control panel's window hook, which causes the ModSPM_PanelActivateHook function to run, which
//	calls ModSPM_SyncPanelToInfo(). ModSPM_SyncPanelToInfo() reads the info out of the graph and sets the panel's controls to match. But since the activate event
//	interrupted SPM_ApplyMods(), it read stale data from the graph.
//
//	This function sets a flag which the hook function will use to avoid syncing the panel to stale data.
Function ApplyingMods()

	Variable/G root:Packages:WMScatterPlotMatrixPackage:gMPModifyingGraph = 1
end

Function ApplyingModsFinished()

	Variable/G root:Packages:WMScatterPlotMatrixPackage:gMPModifyingGraph = 0
end

Function WeAreApplyingMods()

	NVAR/Z gMPModifyingGraph = root:Packages:WMScatterPlotMatrixPackage:gMPModifyingGraph
	if (NVAR_Exists(gMPModifyingGraph) && (gMPModifyingGraph == 1))
		return 1
	endif
	
	return 0
end

Function SPM_ApplyMods(GraphName, newinfo)
	String GraphName
	STRUCT ScatterPlotMatrixInfo &newinfo
	
	if (newinfo.UseEmbeddedGraphs)
		SPM2_ApplyMods(GraphName, newinfo)
	else
		SPMFree_ApplyMods(GraphName, newinfo)
	endif
end

Function SPM2_ApplyMods(GraphName, newinfo)
	String GraphName
	STRUCT ScatterPlotMatrixInfo &newinfo
	
	STRUCT ScatterPlotMatrixInfo info
	if (SPM_GetInfoFromGraph(info, GraphName) == 0)
		return -1		// not a Scatter Plot Matrix graph window
	endif

	ApplyingMods()

	Variable IncludeDiagonals = (info.PlotOptions&PO_Diagonal) && !(info.LabelOptions==LO_Diagonal)
	
	String plotList = ChildWindowList(GraphName)
	Variable nPlots = ItemsInList(plotList)
	Variable i
	Variable changed = 0
	for (i = 0; i < nPlots; i += 1)
		String subWinName = StringFromList(i, plotList)

		Variable ii,jj
		ii = str2num(StringFromList(1, subWinName, "_"))
		jj = str2num(StringFromList(2, subWinName, "_"))
		
		if (!IncludeDiagonals && (ii == jj))
			continue
		endif
		
		// trace mods
		if (newInfo.TraceMode != Info.TraceMode)
			ModifyGraph/W=$GraphName#$subWinName mode = newInfo.TraceMode
			changed = 1
		endif
		if (newInfo.MarkerNumber != info.MarkerNumber)
			ModifyGraph/W=$GraphName#$subWinName marker = newInfo.MarkerNumber
			changed = 1
		endif
		if (newInfo.Markersize != info.Markersize)
			ModifyGraph/W=$GraphName#$subWinName msize = newInfo.Markersize
			changed = 1
		endif
		if (info.MarkerThickness != newInfo.MarkerThickness)
			ModifyGraph/W=$GraphName#$subWinName mrkThick = newInfo.MarkerThickness
			changed = 1
		endif
		if (info.LineSize != newInfo.LineSize)
			ModifyGraph/W=$GraphName#$subWinName lsize = newInfo.LineSize
			changed = 1
		endif
		if ( (info.TraceColorRed != newInfo.TraceColorRed) || (info.TraceColorGreen != newInfo.TraceColorGreen) || (info.TraceColorBlue != newInfo.TraceColorBlue) )
			ModifyGraph/W=$GraphName#$subWinName rgb = (newInfo.TraceColorRed, newInfo.TraceColorGreen, newInfo.TraceColorBlue)
			changed = 1
		endif
		if (info.LineStyle != newInfo.LineStyle)
			ModifyGraph/W=$GraphName#$subWinName lStyle = newInfo.LineStyle
			changed = 1
		endif
		if (info.UseMarkerStroke != newInfo.UseMarkerStroke)
			ModifyGraph/W=$GraphName#$subWinName useMrkStrokeRGB = newInfo.UseMarkerStroke
			changed = 1
		endif
		if ( (info.MarkerStrokeRed != newInfo.MarkerStrokeRed) || (info.MarkerStrokeGreen != newInfo.MarkerStrokeGreen) || (info.MarkerStrokeBlue != newInfo.MarkerStrokeBlue) )
			ModifyGraph/W=$GraphName#$subWinName mrkStrokeRGB = (newInfo.MarkerStrokeRed, newInfo.MarkerStrokeGreen, newInfo.MarkerStrokeBlue)
			changed = 1
		endif

		// axis mods
		if (newInfo.AxisThickness != Info.AxisThickness)
			ModifyGraph/W=$GraphName#$subWinName axThick = newInfo.AxisThickness
			changed = 1
		endif
		if ( (info.AxisColorRed != newInfo.AxisColorRed) || (info.AxisColorGreen != newInfo.AxisColorGreen) || (info.AxisColorBlue != newInfo.AxisColorBlue) )
			ModifyGraph/W=$GraphName#$subWinName axRGB = (newInfo.AxisColorRed, newInfo.AxisColorGreen, newInfo.AxisColorBlue)
			ModifyGraph/W=$GraphName#$subWinName alblRGB = (newInfo.AxisColorRed, newInfo.AxisColorGreen, newInfo.AxisColorBlue)
			ModifyGraph/W=$GraphName#$subWinName tickRGB = (newInfo.AxisColorRed, newInfo.AxisColorGreen, newInfo.AxisColorBlue)
			ModifyGraph/W=$GraphName#$subWinName tlblRGB = (newInfo.AxisColorRed, newInfo.AxisColorGreen, newInfo.AxisColorBlue)
			changed = 1
		endif
		if (	info.AxisStandoff != newInfo.AxisStandoff)
			ModifyGraph/W=$GraphName#$subWinName standoff = newInfo.AxisStandoff
			changed = 1
		endif
		if (	info.YAxisLabelPos != newInfo.YAxisLabelPos)
			ModifyGraph/W=$GraphName#$subWinName lblPos(left) = newInfo.YAxisLabelPos
			changed = 1
		endif		
		if (	info.XAxisLabelPos != newInfo.XAxisLabelPos)
			ModifyGraph/W=$GraphName#$subWinName lblPos(bottom) = newInfo.XAxisLabelPos
			changed = 1
		endif		
		if (	info.GridOnOff != newInfo.GridOnOff)
			ModifyGraph/W=$GraphName#$subWinName grid = newInfo.GridOnOff
			changed = 1
		endif
		If ( (newInfo.PlotOptions & PO_NoTicksOrLabels) == 0 )	// if bit clear, tick labels
			Variable applyAll = (newInfo.PlotOptions & PO_NoTicksOrLabels) != (info.PlotOptions & PO_NoTicksOrLabels)
			if ( applyAll || (info.YTickLabelRot != newInfo.YTickLabelRot) )
				ModifyGraph/W=$GraphName#$subWinName lblRot(left) = newInfo.YTickLabelRot
				changed = 1
			endif		
			if ( applyAll || (info.XTickLabelRot != newInfo.XTickLabelRot) )
				ModifyGraph/W=$GraphName#$subWinName lblRot(bottom) = newInfo.XTickLabelRot
				changed = 1
			endif		
			if ( applyAll || (info.TickPosition != newInfo.TickPosition) )
				ModifyGraph/W=$GraphName#$subWinName tick = newInfo.TickPosition
				changed = 1
			endif		
		else
			if ((newInfo.PlotOptions & PO_NoTicksOrLabels) != (info.PlotOptions & PO_NoTicksOrLabels))
				ModifyGraph/W=$GraphName#$subWinName noLabel=1, tick=3
				changed = 1
			endif
		endif

		
		if (info.AxisRangeMode != newInfo.AxisRangeMode)
			if (newInfo.AxisRangeMode)
				Wave yw = WaveRefIndexed(GraphName+"#"+subWinName, 0, 1)
				Wave xw = WaveRefIndexed(GraphName+"#"+subWinName, 0, 2)
				Variable npnts = numpnts(yw)
				Variable  xMin=inf, yMin=inf
				Variable xMax=-inf, yMax=-inf
				Variable pntIndex
				for (pntIndex = 0; pntIndex < npnts; pntIndex += 1)
					if ( (numtype(yw[pntIndex]) == 0) && (numtype(xw[pntIndex]) == 0) )
						xMin = min(xMin, xw[pntIndex])
						yMin = min(yMin, yw[pntIndex])
						xMax = max(xMax, xw[pntIndex])
						yMax = max(yMax, yw[pntIndex])
						SetAxis/W=$GraphName#$subWinName bottom xMin, xMax
						SetAxis/W=$GraphName#$subWinName left yMin, yMax
					endif
					ModifyGraph/W=$GraphName#$subWinName noLabel=0
				endfor
			else
				// this needs to be altered to calculate which labels to re-enable
				SetAxis/W=$GraphName#$subWinName/A
			endif
			changed = 1
		endif	

		// plot mods
		if ( (newInfo.PlotOptions & PO_ColoredBoxes) != (Info.PlotOptions & PO_ColoredBoxes) || (newInfo.PlotBackColorRed != info.PlotBackColorRed) || (newInfo.PlotBackColorGreen != info.PlotBackColorGreen) || (newInfo.PlotBackColorBlue != info.PlotBackColorBlue) )
			if (newInfo.PlotOptions & PO_ColoredBoxes)
				ModifyGraph/W=$GraphName#$subWinName gbRGB = (newInfo.PlotBackColorRed, newInfo.PlotBackColorGreen, newInfo.PlotBackColorBlue)
			else
				ModifyGraph/W=$GraphName#$subWinName gbRGB = (65535, 65535, 65535)
			endif
			changed = 1
		endif

		if (newInfo.Frames != info.Frames)
			ModifyGraph/W=$GraphName#$subWinName mirror = newInfo.Frames ? 2 : 0
			changed = 1
		endif

		if (newInfo.OpaqueMarkers != info.OpaqueMarkers)
			ModifyGraph/W=$GraphName#$subWinName opaque = newInfo.OpaqueMarkers
			changed = 1
		endif
	endfor
	
	// plot layout mods
	if (newInfo.LeftMargin != info.LeftMargin)
		DefineGuide/W=$GraphName LeftGuide = {FL, newInfo.LeftMargin}
		changed = 1
	endif
	if (newInfo.BottomMargin != info.BottomMargin)
		DefineGuide/W=$GraphName BottomGuide = {FB, -newInfo.BottomMargin}
		changed = 1
	endif
	if (newInfo.RightMargin != info.RightMargin)
		DefineGuide/W=$GraphName RightGuide = {FR, -newInfo.RightMargin}
		changed = 1
	endif
	if (newInfo.TopMargin != info.TopMargin)
		DefineGuide/W=$GraphName TopGuide = {FT, newInfo.TopMargin}
		changed = 1
	endif
	
	String GuideNamePG
	for (i = 0; i <= info.nWaves; i += 1)
		if ( (i < info.nWaves) && (newInfo.LeftInsetFraction != Info.LeftInsetFraction) )
			GuideNamePG = "VerticalPGL_"+num2istr(i)
			DefineGuide/W=$GraphName $GuideNamePG = {LeftGuide, (i+newInfo.LeftInsetFraction)/info.nWaves,RightGuide}
			Changed = 1
		endif
		if ( (i > 0) && (Info.RightInsetFraction != newInfo.RightInsetFraction) )
			GuideNamePG = "VerticalPGR_"+num2istr(i)
			DefineGuide/W=$GraphName $GuideNamePG = {LeftGuide, (i-newInfo.RightInsetFraction)/info.nWaves,RightGuide}
			Changed = 1
		endif
		if ( (i > 0) && (newInfo.BottomInsetFraction != Info.BottomInsetFraction) )
			GuideNamePG = "HorizontalPGB_"+num2istr(i)
			DefineGuide/W=$GraphName $GuideNamePG = {TopGuide, (i-newInfo.BottomInsetFraction)/info.nWaves,BottomGuide}
			Changed = 1
		endif
		if ( (i < info.nWaves) && (Info.TopInsetFraction != newInfo.TopInsetFraction) )
			GuideNamePG = "HorizontalPGT_"+num2istr(i)
			DefineGuide/W=$GraphName $GuideNamePG = {TopGuide, (i+newInfo.TopInsetFraction)/info.nWaves,BottomGuide}
			Changed = 1
		endif
	endfor
	
	if (changed)
		SPM_StoreInfoInGraph(newinfo, GraphName)
	endif

	ApplyingModsFinished()
end

Function SPMFree_ApplyMods(GraphName, newinfo)
	String GraphName
	STRUCT ScatterPlotMatrixInfo &newinfo
	
	STRUCT ScatterPlotMatrixInfo info
	if (SPM_GetInfoFromGraph(info, GraphName) == 0)
		return -1		// not a Scatter Plot Matrix graph window
	endif
	
	Variable changed = 0

	ApplyingMods()

	Variable IncludeDiagonals = (info.PlotOptions&PO_Diagonal) && !(info.LabelOptions==LO_Diagonal)
	
	// trace mods
	if (newInfo.TraceMode != Info.TraceMode)
		ModifyGraph/W=$GraphName mode = newInfo.TraceMode
		changed = 1
	endif
	if (newInfo.MarkerNumber != info.MarkerNumber)
		ModifyGraph/W=$GraphName marker = newInfo.MarkerNumber
		changed = 1
	endif
	if (newInfo.Markersize != info.Markersize)
		ModifyGraph/W=$GraphName msize = newInfo.Markersize
		changed = 1
	endif
	if (info.MarkerThickness != newInfo.MarkerThickness)
		ModifyGraph/W=$GraphName mrkThick = newInfo.MarkerThickness
		changed = 1
	endif
	if (info.LineSize != newInfo.LineSize)
		ModifyGraph/W=$GraphName lsize = newInfo.LineSize
		changed = 1
	endif
	if ( (info.TraceColorRed != newInfo.TraceColorRed) || (info.TraceColorGreen != newInfo.TraceColorGreen) || (info.TraceColorBlue != newInfo.TraceColorBlue) )
		ModifyGraph/W=$GraphName rgb = (newInfo.TraceColorRed, newInfo.TraceColorGreen, newInfo.TraceColorBlue)
		changed = 1
	endif
	if (info.LineStyle != newInfo.LineStyle)
		ModifyGraph/W=$GraphName lStyle = newInfo.LineStyle
		changed = 1
	endif
	if (info.UseMarkerStroke != newInfo.UseMarkerStroke)
		ModifyGraph/W=$GraphName useMrkStrokeRGB = newInfo.UseMarkerStroke
		changed = 1
	endif
	if ( (info.MarkerStrokeRed != newInfo.MarkerStrokeRed) || (info.MarkerStrokeGreen != newInfo.MarkerStrokeGreen) || (info.MarkerStrokeBlue != newInfo.MarkerStrokeBlue) )
		ModifyGraph/W=$GraphName mrkStrokeRGB = (newInfo.MarkerStrokeRed, newInfo.MarkerStrokeGreen, newInfo.MarkerStrokeBlue)
		changed = 1
	endif
	
	// plot mods
	Variable i, j
	Variable nPlots = 0
	String Axis1,Axis2
	
	if (newInfo.LeftMargin != info.LeftMargin)
		ModifyGraph/W=$GraphName margin(left) = newInfo.LeftMargin
		changed = 1
	endif
	if (newInfo.BottomMargin != info.BottomMargin)
		ModifyGraph/W=$GraphName margin(bottom) = newInfo.BottomMargin
		changed = 1
	endif
	if (newInfo.RightMargin != info.RightMargin)
		ModifyGraph/W=$GraphName margin(right) = newInfo.RightMargin
		changed = 1
	endif
	if (newInfo.TopMargin != info.TopMargin)
		ModifyGraph/W=$GraphName margin(top) = newInfo.TopMargin
		changed = 1
	endif
	if (newInfo.OpaqueMarkers != info.OpaqueMarkers)
		ModifyGraph/W=$GraphName opaque = newInfo.OpaqueMarkers
		changed = 1
	endif
	
	String AxisNameFormat = ""
	// test for old or  new axis naming convention
	GetAxis/Q/W=$GraphName/Q Y_0_1
	if (V_flag)
		GetAxis/Q/W=$GraphName/Q Y_1_0
		if (V_flag)
			AxisNameFormat = "%s_%d%d"
		else
			AxisNameFormat = "%s_%d_%d" 
		endif
	else
		AxisNameFormat = "%s_%d_%d"
	endif
	
	if  ( (newinfo.VerticalGroutFraction != info.VerticalGroutFraction) || (newinfo.HorizontalGroutFraction != info.HorizontalGroutFraction) )
		Variable VerticalPercentRange = (1-newinfo.VerticalGroutFraction)/info.nWaves
		Variable HorizontalPercentRange = (1-newinfo.HorizontalGroutFraction)/info.nWaves
		Variable VerticalPercentGrout = newinfo.VerticalGroutFraction/(info.nWaves-1)
		Variable HorizontalPercentGrout = newinfo.HorizontalGroutFraction/(info.nWaves-1)

		for (i = 0; i < info.nWaves; i += 1)
			for (j = 0; j < info.nWaves; j += 1)
				sprintf Axis1, AxisNameFormat, "Y", i, j
				sprintf Axis2, AxisNameFormat, "X", i, j
				
				GetAxis/W=$GraphName/Q $Axis1
				if (V_flag)
					continue
				endif
				
				Variable MinPercent = (info.nWaves-i-1)*(VerticalPercentRange + VerticalPercentGrout)
				MinPercent = MinPercent < 0 ? 0 : MinPercent
				Variable MaxPercent = MinPercent+VerticalPercentRange
				MaxPercent = MaxPercent > 1 ? 1 : MaxPercent
				ModifyGraph/W=$GraphName axisEnab($Axis1)={MinPercent,MaxPercent}				
										
				MinPercent = j*(HorizontalPercentRange + HorizontalPercentGrout)
				MinPercent = MinPercent < 0 ? 0 : MinPercent
				MaxPercent = MinPercent+HorizontalPercentRange
				MaxPercent = MaxPercent > 1 ? 1 : MaxPercent
				ModifyGraph/W=$GraphName axisEnab($Axis2)={MinPercent,MaxPercent}
			endfor
		endfor
		changed = 1
	endif
	
	Variable DrawFramesandBackground =  (newInfo.Frames != info.Frames) || (newInfo.PlotOptions & PO_ColoredBoxes) != (Info.PlotOptions & PO_ColoredBoxes) || (newInfo.PlotBackColorRed != info.PlotBackColorRed) || (newInfo.PlotBackColorGreen != info.PlotBackColorGreen) || (newInfo.PlotBackColorBlue != info.PlotBackColorBlue) 
	if (DrawFramesandBackground)
		SetDrawLayer/W=$GraphName/K UserBack
		SetDrawLayer/W=$GraphName/K UserAxes
		changed = 1
	endif
	for (i = 0; i < info.nWaves; i += 1)
		for (j = 0; j < info.nWaves; j += 1)
			sprintf Axis1, AxisNameFormat, "Y", i, j
			sprintf Axis2, AxisNameFormat, "X", i, j
			
			GetAxis/W=$GraphName/Q $Axis1
			if (V_flag)
				continue
			endif

			if (DrawFramesandBackground)
				if (newInfo.PlotOptions & PO_ColoredBoxes)
					AddPlotColoredBox(GraphName, Axis2, Axis1, red=newInfo.PlotBackColorRed, green=newInfo.PlotBackColorGreen, blue=newInfo.PlotBackColorBlue)
				endif
				
				if (newInfo.Frames)
					AddPlotSubFrame(GraphName, Axis2, Axis1)
				endif
			endif
				
			if (	info.YAxisLabelPos != newInfo.YAxisLabelPos)
				ModifyGraph/W=$GraphName lblPos($Axis1) = newInfo.YAxisLabelPos
				changed = 1
			endif		
			if (	info.XAxisLabelPos != newInfo.XAxisLabelPos)
				ModifyGraph/W=$GraphName lblPos($Axis2) = newInfo.XAxisLabelPos
				changed = 1
			endif		
			if ( info.GridOnOff != newInfo.GridOnOff )
				ModifyGraph/W=$GraphName grid = newInfo.GridOnOff
				if (newInfo.GridOnOff)
					Variable aStart, aEnd
					AxisExtent(GraphName, Axis1, aStart, aEnd)
					ModifyGraph/W=$GraphName gridEnab($Axis2) = {aStart, aEnd}
					AxisExtent(GraphName, Axis2, aStart, aEnd)
					ModifyGraph/W=$GraphName gridEnab($Axis1) = {aStart, aEnd}
				endif
				changed = 1
			endif
			If ( (newInfo.PlotOptions & PO_NoTicksOrLabels) == 0 )	// if bit clear, tick labels
				Variable applyAll = (newInfo.PlotOptions & PO_NoTicksOrLabels) != (info.PlotOptions & PO_NoTicksOrLabels)
				if ( applyAll || (info.TickPosition != newInfo.TickPosition) )
					ModifyGraph/W=$GraphName tick = newInfo.TickPosition
					changed = 1
				endif		
				if ( applyAll || (info.YTickLabelRot != newInfo.YTickLabelRot) )
					ModifyGraph/W=$GraphName lblRot($Axis1) = newInfo.YTickLabelRot
					changed = 1
				endif		
				if ( applyAll || (info.XTickLabelRot != newInfo.XTickLabelRot) )
					ModifyGraph/W=$GraphName lblRot($Axis2) = newInfo.XTickLabelRot
					changed = 1
				endif		
			else
				if ((newInfo.PlotOptions & PO_NoTicksOrLabels) != (info.PlotOptions & PO_NoTicksOrLabels))
					ModifyGraph/W=$GraphName noLabel=1, tick=3
					changed = 1
				endif
			endif	
		endfor
	endfor	
	
				
	if (info.AxisRangeMode != newInfo.AxisRangeMode)
		if (newInfo.AxisRangeMode)
			String tlist = TraceNameList(GraphName, ";", 1)
			Variable ntraces = ItemsInList(tlist)
			Variable tindex
			for (tindex = 0; tindex < ntraces; tindex += 1)
				String tname = StringFromList(tindex, tlist)
				String tinfo = TraceInfo(GraphName, tname, 0)
				String yAxis = StringByKey("YAXIS", tinfo)
				String xAxis = StringByKey("XAXIS", tinfo)
		
				Wave yw = TraceNameToWaveRef(GraphName, tname)
				Wave xw = XWaveRefFromTrace(GraphName, tname)
				
				Variable npnts = numpnts(yw)
				Variable  xMin=inf, yMin=inf
				Variable xMax=-inf, yMax=-inf
				Variable pntIndex
				for (pntIndex = 0; pntIndex < npnts; pntIndex += 1)
					if ( (numtype(yw[pntIndex]) == 0) && (numtype(xw[pntIndex]) == 0) )
						xMin = min(xMin, xw[pntIndex])
						yMin = min(yMin, yw[pntIndex])
						xMax = max(xMax, xw[pntIndex])
						yMax = max(yMax, yw[pntIndex])
						SetAxis/W=$GraphName $xAxis xMin, xMax
						SetAxis/W=$GraphName $yAxis yMin, yMax
					endif
					ModifyGraph/W=$GraphName noLabel=0
				endfor
			endfor
		else
			// this needs to be altered to calculate which labels to re-enable
			SetAxis/W=$GraphName/A
		endif
		changed = 1
	endif	
	
	// axis mods
	if (newInfo.AxisThickness != Info.AxisThickness)
		ModifyGraph/W=$GraphName axThick = newInfo.AxisThickness
		changed = 1
	endif
	if ( (info.AxisColorRed != newInfo.AxisColorRed) || (info.AxisColorGreen != newInfo.AxisColorGreen) || (info.AxisColorBlue != newInfo.AxisColorBlue) )
		ModifyGraph/W=$GraphName axRGB = (newInfo.AxisColorRed, newInfo.AxisColorGreen, newInfo.AxisColorBlue)
		ModifyGraph/W=$GraphName alblRGB = (newInfo.AxisColorRed, newInfo.AxisColorGreen, newInfo.AxisColorBlue)
		ModifyGraph/W=$GraphName tickRGB = (newInfo.AxisColorRed, newInfo.AxisColorGreen, newInfo.AxisColorBlue)
		ModifyGraph/W=$GraphName tlblRGB = (newInfo.AxisColorRed, newInfo.AxisColorGreen, newInfo.AxisColorBlue)
		changed = 1
	endif
	if (	info.AxisStandoff != newInfo.AxisStandoff)
		ModifyGraph/W=$GraphName standoff = newInfo.AxisStandoff
		changed = 1
	endif
	
	if (changed)
		SPM_StoreInfoInGraph(newinfo, GraphName)
	endif

	ApplyingModsFinished()
end

// parses subwindow graph names: Graph_4_5 is the fifth graph in the sixth row. Extracts the 4 and the 5 and test to see if they are the same.
Function IsDiagonalGraph(subGraphName)
	String subGraphName
	
	return CmpStr(StringFromList(1, subGraphName, "_"), StringFromList(2, subGraphName, "_")) == 0
end

Function SPM2_CopyTraceInfoToSubGraphs(tracename, fromSubGraph)
	String tracename, fromSubGraph			// hcspec for the subwindow graph from which to copy trace info; main window name for a free-axis type graph
	
	if (!WaveExists(TraceNameToWaveRef(fromSubGraph, tracename)))
		DoAlert 0, "No trace under mouse?"
		return -1
	endif
	
	String rootGraph = ParseFilePath(0, fromSubGraph, "#", 0, 0)
	
	STRUCT ScatterPlotMatrixInfo info
	if (SPM_GetInfoFromGraph(info, rootGraph) == 0)
		return -1		// not a Scatter Plot Matrix graph window
	endif
	
	Variable IncludeDiagonals = (info.PlotOptions&PO_Diagonal) && !(info.LabelOptions==LO_Diagonal)
//	if (IsDiagonalGraph(fromSubGraph) && !IncludeDiagonals)
//		return -1			// if !IncludeDiagonals, the graph windows on the diagonal don't have traces with styles that should be copied
//	endif

	String undoFolderName = MakeUndoFolderForGraph(rootGraph)

	Variable i
	String masterInfo = RootRelativeTraceInfo(fromSubGraph, tracename)
	String tname = ""
	if (info.UseEmbeddedGraphs)
		GetWindow $rootGraph activeSW
		String activeSubWindow = S_Value
		
		String plotList = ChildWindowList(rootGraph)
		Variable nPlots = ItemsInList(plotList)
		
		for (i = 0; i < nPlots; i += 1)
			String subWinName = rootGraph+"#"+StringFromList(i, plotList)
			SetActiveSubwindow $subWinName
			tname = StringFromList(0, TraceNameList(subWinName, ";", 1))
			
			if (IsDiagonalGraph(subWinName) && !IncludeDiagonals)
				continue
			endif
			
			SPM2_CopyTraceSettingsSaveUndo(subWinName, tname, RootRelativeTraceInfo(subWinName, tname), undoFolderName)
			SPM2_CopyTraceSettings(masterInfo, tname)
		endfor
		
		SetActiveSubwindow $activeSubWindow
	else
		String tlist = TraceNameList(fromSubGraph, ";", 1 )
		Variable nItems = ItemsInList(tlist)
		for (i = 0; i < nItems; i += 1)
			tname = StringFromList(i, tlist)
			if (strlen(tname) == 0)
				continue
			endif
			if (stringmatch(tname, "fit_*" ))
				continue
			endif
			if (CmpStr(tname, tracename) == 0)
				continue
			endif
			SPM2_CopyTraceSettingsSaveUndo(fromSubGraph, tname, RootRelativeTraceInfo(fromSubGraph, tname), undoFolderName)
			SPM2_CopyTraceSettings(masterInfo, tname)
		endfor
	endif
end

static Function/S RootRelativeTraceInfo(graphName, traceName)
	String graphName, traceName
	
	String saveDF = GetDataFolder(1)
	SetDataFolder root:
	String tinfo = TraceInfo(graphName, traceName, 0)
	SetDataFolder saveDF
	return tinfo
end

Function/S HashThreeStrings(s1, s2, s3)
	String s1, s2, s3
	
	Variable i
	Variable nChars
	Variable hashNum = 0
	
	nChars = strlen(s1)
	for (i = 0; i < nChars; i += 1)
		hashNum += char2num(s1[i])
	endfor
	
	nChars = strlen(s2)
	for (i = 0; i < nChars; i += 1)
		hashNum += char2num(s2[i])*256
	endfor
	
	nChars = strlen(s3)
	for (i = 0; i < nChars; i += 1)
		hashNum += char2num(s3[i])*65536
	endfor
	
	String returnString
	sprintf returnString, "%X", hashNum
	
	return returnString
end

static Function/S MakeUndoFolderForGraph(rootGraph)
	string rootGraph
	
	
	STRUCT ScatterPlotMatrixInfo info
	if (SPM_GetInfoFromGraph(info, rootGraph) == 0)
		return ""		// not a Scatter Plot Matrix graph window
	endif
	
	String SaveDF = GetDataFolder(1)
	String undoFolderName=""
	
	String fullDFName = "root:Packages:WMScatterPlotMatrixPackage:"+info.datafoldername
	if ( (strlen(info.datafoldername) > 0) && DataFolderExists(fullDFName ) )
		SetDataFolder fullDFName
		
		NewDataFolder/O/S TraceUndoInfo
		undoFolderName = UniqueName(rootGraph, 11, 0)
		NewDataFolder/O/S $undoFolderName
		undoFolderName = GetDataFolder(1)
	endif
	
	SetDataFolder saveDF
	return undoFolderName
end

Function SPM2_CopyTraceSettingsSaveUndo(forSubWin, tname, tinfo, undoFolder)
	String forSubWin, tname, tinfo, undoFolder
	
	String rootGraph = ParseFilePath(0, forSubWin, "#", 0, 0)
	String subWindowName = ParseFilePath(0, forSubWin, "#", 0, 1)
	STRUCT ScatterPlotMatrixInfo info
	if (SPM_GetInfoFromGraph(info, rootGraph) == 0)
		return -1		// not a Scatter Plot Matrix graph window
	endif
	
	String SaveDF = GetDataFolder(1)
	SetDataFolder $undoFolder
	
	String hashName = UniqueName("UndoSubPlot", 11, 0)
	NewDataFolder/O/S $hashName
	String/G WindowName = forSubWin
	String/G TraceName = tname
	String/G InfoForTrace = tinfo

	SetDataFolder saveDF
end

static Function/S GetLatestUndoFolder(rootGraph)
	String rootGraph
	
	STRUCT ScatterPlotMatrixInfo info
	if (SPM_GetInfoFromGraph(info, rootGraph) == 0)
		return ""		// not a Scatter Plot Matrix graph window
	endif
	
	String saveDF = GetDataFolder(1)
	String fullDFName = "root:Packages:WMScatterPlotMatrixPackage:"+info.datafoldername
	SetDataFolder fullDFName
	SetDataFolder TraceUndoInfo
	Variable nItems = CountObjects(":", 4)
	if (nItems == 0)
		SetDataFolder saveDF
		return ""
	endif
	
	Variable i=0
	do
		String DFName = rootGraph+num2str(i)
		if (!DataFolderExists(DFName))
			i -= 1
			break;
		endif
		i += 1
	while(1)
	SetDataFolder saveDF
	
	if (i < 0)
		return ""
	endif
	
	return rootGraph+num2str(i)
end

Function SPM2_UndoCopyTraceInfo(rootGraph)
	String rootGraph
	
	STRUCT ScatterPlotMatrixInfo info
	if (SPM_GetInfoFromGraph(info, rootGraph) == 0)
		return -1		// not a Scatter Plot Matrix graph window
	endif
	
	String saveDF = GetDataFolder(1)
	String fullDFName = "root:Packages:WMScatterPlotMatrixPackage:"+info.datafoldername
	SetDataFolder fullDFName
	SetDataFolder TraceUndoInfo
	String undoFolder = GetLatestUndoFolder(rootGraph)
	SetDataFolder $undoFolder
	Variable i
	Variable nItems = CountObjects(":", 4 )
	for (i = nItems-1; i >= 0; i -= 1)
		String dfName = GetIndexedObjName(":", 4, i )
		SetDataFolder dfName
		SVAR WindowName
		SVAR TraceName
		SVAR InfoForTrace
		SetActiveSubWindow $WindowName
		SPM2_CopyTraceSettings(InfoForTrace, TraceName)
		SetDataFolder ::
		KillDataFolder $dfName
	endfor
	SetDataFolder ::
	KillDataFolder $undoFolder
	
	SetDataFolder saveDF
end

static Function CopyTraceUndoAvailable(WinOrSubwin)
	String WinOrSubwin
	
	String rootGraph = ParseFilePath(0, WinOrSubwin, "#", 0, 0)
	
	STRUCT ScatterPlotMatrixInfo info
	if (SPM_GetInfoFromGraph(info, rootGraph) == 0)
		return 0		// not a Scatter Plot Matrix graph window
	endif
	
	String fullDFName = "root:Packages:WMScatterPlotMatrixPackage:"+info.datafoldername+":TraceUndoInfo:"+rootGraph+"0"
	if (DataFolderExists(fullDFName))
		return CountObjects(fullDFName, 4 ) > 0
	endif
end


// Expects the active window to be the graph window containing the matrix plot. Further expects
// the active subwindow to be the one to which the trace info should be copied.
Function SPM2_CopyTraceSettings(masterInfo, desttrace)
	String masterInfo, desttrace
	
	Variable sstop= strsearch(masterInfo, "RECREATION:", 0)
	masterInfo= masterInfo[sstop+strlen("RECREATION:"),1e6]		// want just recreation stuff
	String dstr = "("+desttrace+")"			// i.e., (jack#1)

	String sitem,xstr
	Variable nItems = ItemsInList(masterInfo)
	Variable i
	for (i = 0; i < nItems; i += 1)
		sitem= StringFromList(i,masterInfo)
		if( strlen(sitem) == 0 )
			continue;
		endif
		String saveDF = GetDataFolder(1)
		SetDataFolder root:
		xstr= "ModifyGraph "+ReplaceString("(x)",sitem,dstr,1)	// replace "(x)" in sitem with, for example, "(left)"
		Execute xstr
		SetDataFolder saveDF
	endfor
End

Function ModSPM_PanelActivateHook(H_Struct)
	STRUCT WMWinHookStruct &H_Struct
	
	Variable statusCode = 0
	
	switch (H_Struct.eventCode)
		case 0:					// activate event
			STRUCT ScatterPlotMatrixInfo info
			if (SPM_GetInfoFromGraph(info, WinName(0,1)))
				ModSPM_SyncPanelToInfo(info)
				statusCode = 1
			endif
			break;
		case 2:		// window being killed
			WC_WindowCoordinatesSave(H_Struct.winName)
			break;
	endswitch
	
	return statusCode		// 0 if nothing done, else 1
End

Function TickLabelRotCharsToMenuItem(itemText)
	String itemText
	
	strswitch(itemText)
		case "180":
			return 1
		case "90":
			return 2
		case "0":
			return 3
		case "-90":
			return 4
	endswitch
	
	return -1			// bad input
end

Function TickLabelRotDegreesToMenuItem(degrees)
	Variable degrees
	
	if (degrees >= 180)
		return 1
	elseif (degrees >= 90)
		return 2
	elseif (degrees >= 0)
		return 3
	else
		return 4
	endif
end

Function ModSPM_SyncPanelToInfo(info)
	STRUCT ScatterPlotMatrixInfo &info
	
	// don't sync the controls while a graph is being modified- it will result in syncing the stale data.
	if (WeAreApplyingMods())
		return -1
	endif
	
	PopupMenu ModSPM_TraceModePop, mode=TraceModeNumberToModePopNum(info.TraceMode)
	NVAR gMPModMarkerSize = root:Packages:WMScatterPlotMatrixPackage:gMPModMarkerSize
	gMPModMarkerSize = info.Markersize
	NVAR gMPModLineSize = root:Packages:WMScatterPlotMatrixPackage:gMPModLineSize
	gMPModLineSize = info.LineSize
	NVAR gMPMarkerThick = root:Packages:WMScatterPlotMatrixPackage:gMPMarkerThick
	gMPMarkerThick = info.MarkerThickness
	PopupMenu ModSPM_MarkerMenu,win=ScatterPlotMatrixModifyPanel,mode = info.MarkerNumber+1
	PopupMenu ModSPM_TraceRGBPop,win=ScatterPlotMatrixModifyPanel,popColor=(info.TraceColorRed, info.TraceColorGreen, info.TraceColorBlue)
	PopupMenu ModSPM_LineTypePop,win=ScatterPlotMatrixModifyPanel, mode=info.LineStyle+1
	PopupMenu ModSPM_MarkerStrokeColorMenu,win=ScatterPlotMatrixModifyPanel,popColor=(info.MarkerStrokeRed, info.MarkerStrokeGreen, info.MarkerStrokeBlue)
	CheckBox ModSPM_OpaqueMarkerCheck,win=ScatterPlotMatrixModifyPanel,value = info.OpaqueMarkers
	CheckBox ModSPM_UseStrokeColorCheck,win=ScatterPlotMatrixModifyPanel,value = info.UseMarkerStroke
	
	CheckBox ModSPM_ColoredBackgroundCheck,win=ScatterPlotMatrixModifyPanel,value = ((info.PlotOptions & PO_ColoredBoxes) != 0)
	PopupMenu ModSPM_BackgroundColor,win=ScatterPlotMatrixModifyPanel,popColor= (info.PlotBackColorRed,info.PlotBackColorGreen,info.PlotBackColorBlue)
	
	if (info.useEmbeddedGraphs)
		GroupBox PlotsTab_OverallMarginsGroup,win=ScatterPlotMatrixModifyPanel,title="Main Window Margins (Points)"
	else
		GroupBox PlotsTab_OverallMarginsGroup,win=ScatterPlotMatrixModifyPanel,title="Main Window Margins (Points; Zero = Auto)"
	endif

	NVAR gMPLeftMargin = root:Packages:WMScatterPlotMatrixPackage:gMPLeftMargin
	gMPLeftMargin = info.LeftMargin

	NVAR gMPBottomMargin = root:Packages:WMScatterPlotMatrixPackage:gMPBottomMargin
	gMPBottomMargin = info.BottomMargin

	NVAR gMPRightMargin = root:Packages:WMScatterPlotMatrixPackage:gMPRightMargin
	gMPRightMargin = info.RightMargin

	NVAR gMPTopMargin = root:Packages:WMScatterPlotMatrixPackage:gMPTopMargin
	gMPTopMargin = info.TopMargin

	NVAR gMPLeftInsetFraction = root:Packages:WMScatterPlotMatrixPackage:gMPLeftInsetFraction
	gMPLeftInsetFraction = info.LeftInsetFraction

	NVAR gMPRightInsetFraction = root:Packages:WMScatterPlotMatrixPackage:gMPRightInsetFraction
	gMPRightInsetFraction = info.RightInsetFraction

	NVAR gMPBottomInsetFraction = root:Packages:WMScatterPlotMatrixPackage:gMPBottomInsetFraction
	gMPBottomInsetFraction = info.BottomInsetFraction

	NVAR gMPTopInsetFraction = root:Packages:WMScatterPlotMatrixPackage:gMPTopInsetFraction
	gMPTopInsetFraction = info.TopInsetFraction

	NVAR gMPVerticalGroutFraction = root:Packages:WMScatterPlotMatrixPackage:gMPVerticalGroutFraction
	gMPVerticalGroutFraction = info.VerticalGroutFraction
	
	NVAR gMPHorizontalGroutFraction = root:Packages:WMScatterPlotMatrixPackage:gMPHorizontalGroutFraction
	gMPHorizontalGroutFraction = info.HorizontalGroutFraction
	
	NVAR gMPAxisThickness = root:Packages:WMScatterPlotMatrixPackage:gMPAxisThickness
	gMPAxisThickness = info.AxisThickness
	CheckBox SPM_AxisStandoffCheckBox,win=ScatterPlotMatrixModifyPanel,value = info.AxisStandoff
	PopupMenu SPM_AxisColor,win=ScatterPlotMatrixModifyPanel,popColor=(info.AxisColorRed, info.AxisColorGreen, info.AxisColorBlue)
	
	PopupMenu ModSMP_VertTLabelRot,win=ScatterPlotMatrixModifyPanel,mode=TickLabelRotDegreesToMenuItem(info.YTickLabelRot)
	PopupMenu ModSMP_HorizTLabelRot,win=ScatterPlotMatrixModifyPanel,mode=TickLabelRotDegreesToMenuItem(info.XTickLabelRot)
	
	CheckBox ModSPM_TicksOnOff,value=!(info.PlotOptions & PO_NoTicksOrLabels)
	
	NVAR gMPYLabelPosition = root:Packages:WMScatterPlotMatrixPackage:gMPYLabelPosition
	gMPYLabelPosition = info.YAxisLabelPos
	NVAR gMPXLabelPosition = root:Packages:WMScatterPlotMatrixPackage:gMPXLabelPosition
	gMPXLabelPosition = info.XAxisLabelPos
	PopupMenu ModSPM_TickPosition,win=ScatterPlotMatrixModifyPanel,mode=info.TickPosition+1
	PopupMenu ModSPM_GridsMenu,win=ScatterPlotMatrixModifyPanel,mode=info.GridOnOff+1
	
	Checkbox SPM_RangeIgnoreNaNCheckBox, win=ScatterPlotMatrixModifyPanel,value = info.AxisRangeMode
	
	ControlInfo/W=ScatterPlotMatrixModifyPanel ModScatterPlotMatrixTabControl
	Variable PlotTab = V_value==modSPM_PlotsTab
	
	Variable dontshowit = !PlotTab || !info.useEmbeddedGraphs
	SetVariable ModSPM_LeftInset,win=ScatterPlotMatrixModifyPanel,disable=dontshowit
	SetVariable ModSPM_RightInset,win=ScatterPlotMatrixModifyPanel,disable=dontshowit
	SetVariable ModSPM_BottomInset,win=ScatterPlotMatrixModifyPanel,disable=dontshowit
	SetVariable ModSPM_TopInset,win=ScatterPlotMatrixModifyPanel,disable=dontshowit
	
	dontshowit = !PlotTab || info.useEmbeddedGraphs
	SetVariable ModSPM_SetVGroutFraction,win=ScatterPlotMatrixModifyPanel,disable=dontshowit
	SetVariable ModSPM_SetHGroutFraction,win=ScatterPlotMatrixModifyPanel,disable=dontshowit

	CheckBox ModSPM_PlotFramesCheckBox,win=ScatterPlotMatrixModifyPanel,value = info.Frames
end

Function SPM_GetInfoFromGraph(info, MainWindow)
	STRUCT ScatterPlotMatrixInfo &info
	String MainWindow

	String infostr = GetUserData(MainWindow, "",  "ScatterPlotMatrixInfo")
	info.ScatterPlotMatrixVersion = 0
	StructGet /S info, infostr
	return info.	ScatterPlotMatrixVersion
end

Function SPM_StoreInfoInGraph(info, GraphName)
	STRUCT ScatterPlotMatrixInfo &info
	String GraphName
	
	String infostr
	StructPut /S Info, infostr
	SetWindow	$GraphName userdata(ScatterPlotMatrixInfo) = infostr
end

Function ModSPM_TabProc(TC_Struct) : TabControl
	STRUCT WMTabControlAction &TC_Struct

	STRUCT ScatterPlotMatrixInfo info
	Variable infoVersion = SPM_GetInfoFromGraph(info, WinName(0,1))
	Variable embeddedGraphs = 1
	if (infoVersion != 0)
		embeddedGraphs = info.useEmbeddedGraphs
	endif
	
	if (TC_Struct.eventCode == 2)		// mouse-up
		// tab 0- Trace appearance
		PopupMenu ModSPM_TraceModePop, disable = TC_Struct.tab!=modSPM_TraceTab
		SetVariable ModSPM_SetMarkerSize, disable = TC_Struct.tab!=modSPM_TraceTab
		SetVariable ModSPM_SetLineSize, disable = TC_Struct.tab!=modSPM_TraceTab
		SetVariable ModSPM_SetMarkerThick, disable = TC_Struct.tab!=modSPM_TraceTab
		CheckBox ModSPM_OpaqueMarkerCheck, disable = TC_Struct.tab!=modSPM_TraceTab
		CheckBox ModSPM_UseStrokeColorCheck, disable = TC_Struct.tab!=modSPM_TraceTab
		PopupMenu ModSPM_MarkerStrokeColorMenu, disable = TC_Struct.tab!=modSPM_TraceTab
		PopupMenu ModSPM_MarkerMenu, disable = TC_Struct.tab!=modSPM_TraceTab
		PopupMenu ModSPM_TraceRGBPop, disable = TC_Struct.tab!=modSPM_TraceTab
		PopupMenu ModSPM_LineTypePop, disable = TC_Struct.tab!=modSPM_TraceTab

		// axis appearance tab
		CheckBox SPM_AxisStandoffCheckBox,disable = TC_Struct.tab!=modSPM_AxesTab
		PopupMenu SPM_AxisColor,disable = TC_Struct.tab!=modSPM_AxesTab
		SetVariable SPM_SetAxisThickness,disable = TC_Struct.tab!=modSPM_AxesTab
		PopupMenu ModSMP_VertTLabelRot,disable = TC_Struct.tab!=modSPM_AxesTab
		PopupMenu ModSMP_HorizTLabelRot,disable = TC_Struct.tab!=modSPM_AxesTab
		SetVariable ModSPM_YAxisLabelPos,disable = TC_Struct.tab!=modSPM_AxesTab
		SetVariable ModSPM_XAxisLabelPos,disable = TC_Struct.tab!=modSPM_AxesTab
		CheckBox ModSPM_TicksOnOff,disable = TC_Struct.tab!=modSPM_AxesTab
		PopupMenu ModSPM_TickPosition,disable = TC_Struct.tab!=modSPM_AxesTab
		PopupMenu ModSPM_GridsMenu,disable = TC_Struct.tab!=modSPM_AxesTab
		Checkbox SPM_RangeIgnoreNaNCheckBox,disable = TC_Struct.tab!=modSPM_AxesTab
		
		// Plots tab
		CheckBox ModSPM_ColoredBackgroundCheck, disable = TC_Struct.tab!=modSPM_PlotsTab
		PopupMenu ModSPM_BackgroundColor, disable = TC_Struct.tab!=modSPM_PlotsTab
		GroupBox PlotsTab_OverallMarginsGroup, disable = TC_Struct.tab!=modSPM_PlotsTab
		SetVariable ModSPM_SetLeftMargin, disable = TC_Struct.tab!=modSPM_PlotsTab
		SetVariable ModSPM_SetBottomMargin, disable = TC_Struct.tab!=modSPM_PlotsTab
		SetVariable ModSPM_SetRightMargin, disable = TC_Struct.tab!=modSPM_PlotsTab
		SetVariable ModSPM_SetTopMargin, disable = TC_Struct.tab!=modSPM_PlotsTab
		GroupBox PlotsTab_SubPlotMarginsGroup1, disable = TC_Struct.tab!=modSPM_PlotsTab

		Variable PlotTab = TC_Struct.tab==modSPM_PlotsTab
		Variable dontshowit = !PlotTab || !embeddedGraphs
		SetVariable ModSPM_LeftInset,win=ScatterPlotMatrixModifyPanel,disable=dontshowit
		SetVariable ModSPM_RightInset,win=ScatterPlotMatrixModifyPanel,disable=dontshowit
		SetVariable ModSPM_BottomInset,win=ScatterPlotMatrixModifyPanel,disable=dontshowit
		SetVariable ModSPM_TopInset,win=ScatterPlotMatrixModifyPanel,disable=dontshowit
		
		dontshowit = !PlotTab || embeddedGraphs
		SetVariable ModSPM_SetVGroutFraction,win=ScatterPlotMatrixModifyPanel,disable=dontshowit
		SetVariable ModSPM_SetHGroutFraction,win=ScatterPlotMatrixModifyPanel,disable=dontshowit

		CheckBox ModSPM_PlotFramesCheckBox, disable = TC_Struct.tab!=modSPM_PlotsTab
	endif
	
	return 0
End

//****************************************************************

Function SPM_FreeAxisPlotMatrix(WavesList, PlotOptions, LabelOptions, Frames[, TraceMode, LineSize, MarkerSize, MarkerNumber])
	String WavesList
	Variable PlotOptions	// bit 0: Include lower triangle;
							// bit 1: Include diagonal;
							// bit 2: include upper triangle;
							// bit 3: No ticks or tick labels;
							// bit 4: Colored boxes
	Variable LabelOptions	//0: left and bottom
							//1: top and right
							//2: diagonal
	Variable Frames		//=1 for boxes around each graph
	Variable TraceMode			// ModifyGraph mode=<TraceMode>
	Variable LineSize			//  ModifyGraph lsize=<LineSize>
	Variable MarkerSize		//  ModifyGraph msize=<MarkerSize>
	Variable MarkerNumber	//  ModifyGraph marker=<MarkerNumber>

	if (ParamIsDefault(TraceMode))
		TraceMode = 3
	endif	
	if (ParamIsDefault(LineSize))
		LineSize = 1
	endif	
	if (ParamIsDefault(MarkerSize))
		MarkerSize = 0
	endif	
	if (ParamIsDefault(MarkerNumber))
		MarkerNumber = 8
	endif	

	STRUCT ScatterPlotMatrixInfo info
	info.ScatterPlotMatrixVersion = ScatterPlotMatrixInfoVersion
	info.UseEmbeddedGraphs = 0
	info.PlotOptions = PlotOptions
	info.LabelOptions = LabelOptions
	info.Frames = Frames
	info.TraceMode = TraceMode
	info.LineSize = LineSize
	info.LineStyle = 0			// default
	info.Markersize = MarkerSize
	info.MarkerNumber = MarkerNumber
	info.MarkerThickness = 1
	info.TraceColorRed = 65535
	info.TraceColorGreen = 0
	info.TraceColorBlue = 0
	info.OpaqueMarkers = 0
	info.UseMarkerStroke = 0
	info.MarkerStrokeRed = 65535
	info.MarkerStrokeGreen = 0
	info.MarkerStrokeBlue = 0
	
	info.LeftMargin = 0
	info.BottomMargin = 0
	info.RightMargin = 0
	info.TopMargin = 0
	info.VerticalGroutFraction = 0.2
	info.HorizontalGroutFraction = 0.2

	info.PlotBackColorRed = 50000
	info.PlotBackColorGreen = 50000
	info.PlotBackColorBlue = 50000

	info.AxisThickness = 1
	info.AxisColorRed = 0
	info.AxisColorGreen = 0
	info.AxisColorBlue = 0
	info.AxisStandoff = 1

	String Wave1,Wave2, Axis1="", Axis2=""
	String LabelText
	
	Variable i, j
	Variable XMinPercent, YMinPercent, XMaxPercent, YMaxPercent, PercentBetween, VerticalPercentRange, HorizontalPercentRange, VerticalPercentGrout, HorizontalPercentGrout
	Variable LabelTextX, LabelTextY
	Variable AxMin
	
	Variable nWaves = ItemsInList(WavesList)

	if (nWaves < 1)
		return PlotMatrixErr_NotEnoughWaves
	endif

	if (nWaves == 1)
		Wave w = $StringFromList(0, WavesList)
		if (WaveDims(w) != 2)
			return PlotMatrixErr_OneWaveMustBe2D
		endif
	endif
	
	info.nWaves = nWaves

	for (i = 0; i < nWaves; i += 1)
		Wave1 = StringFromList(i, WavesList)
		if (strlen(Wave1) <= 0)
			return PlotMatrixErr_BadWave
		endif
		Wave/Z w = $Wave1
		if (!WaveExists(w))
			return PlotMatrixErr_BadWave
		endif
		if (WaveType(w ) == 0)
			return PlotMatrixErr_NoTextWaves
		endif
		if (WaveDims(w) > 1 && nWaves > 1)
			return PlotMatrixErr_OneWaveMustBe2D
		endif
	endfor
	
	Variable nCols = nWaves
	if (nWaves == 1)
		Wave matrixWave = $StringFromList(0, WavesList)
		nCols = DimSize(matrixWave, 1)
		if (nCols <= 2)
			return PlotMatrixErr_OneWaveMustBe2D
		endif
	endif

	VerticalPercentRange = (1-info.VerticalGroutFraction)/nCols
	HorizontalPercentRange = (1-info.HorizontalGroutFraction)/nCols
	VerticalPercentGrout = info.VerticalGroutFraction/(nCols-1)
	HorizontalPercentGrout = info.HorizontalGroutFraction/(nCols-1)
	
	if (LabelOptions == LO_Diagonal)
		PlotOptions = PlotOptions | PO_Diagonal
	endif
	
	Display
	String graphname = WinName(0, 1)
	
	string tracename
	string labelStr
		
	for (i = 0; i < nCols; i += 1)
		for (j = 0; j < nCols; j += 1)
			if ((((PlotOptions & PO_Diagonal) != 0) && (i == j)) ||  (((PlotOptions & PO_LowerTriangle) != 0) && (i > j)) || (((PlotOptions & PO_UpperTriangle) != 0) && (i < j)))
				Wave1 = StringFromList(i, WavesList)
				Wave2 = StringFromList(j, WavesList)
				sprintf Axis1, "Y_%d_%d", i, j
				sprintf Axis2, "X_%d_%d", i, j
				
				
				YMinPercent = (nCols-i-1)*(VerticalPercentRange + VerticalPercentGrout)
				YMaxPercent = YMinPercent+VerticalPercentRange
				if (YMaxPercent > 1)
					YMaxPercent = 1
				endif
				if (YMinPercent < 0)
					YMinPercent = 0
				endif
				LabelTextY = 1-(YMinPercent+YMaxPercent)/2
				if (((LabelOptions == LO_Diagonal) && (i != j)) || (LabelOptions != LO_Diagonal))
					if (WaveExists(matrixWave))
						traceName = "Matrix_"+num2str(i)+"_"+num2str(j)
						AppendToGraph/B=$Axis2/L=$Axis1 matrixWave[][i]/TN=$traceName vs matrixWave[][j]
					else
						AppendToGraph/B=$Axis2/L=$Axis1 $Wave1 vs $Wave2
						traceName = Wave1
					endif
//					DoUpdate
					SetAxis/A/N=2 $Axis1
					SetAxis/A/N=2 $Axis2
					ModifyGraph axisEnab($Axis1)={YMinPercent,YMaxPercent}
				endif
				
										
				XMinPercent = j*(HorizontalPercentRange + HorizontalPercentGrout)
				XMaxPercent = XMinPercent+HorizontalPercentRange
				if (XMaxPercent > 1)
					XMaxPercent = 1
				endif
				if (XMinPercent < 0)
					XMinPercent = 0
				endif
				LabelTextX = (XMinPercent+XMaxPercent)/2
				if (((LabelOptions == LO_Diagonal) && (i != j)) || (LabelOptions != LO_Diagonal))
					ModifyGraph axisEnab($Axis2)={XMinPercent,XMaxPercent}
					ModifyGraph freePos($Axis2)={YMinPercent, kwFraction}
					ModifyGraph freePos($Axis1)={XMinPercent, kwFraction}
				endif
				
				
				SetDrawLayer ProgBack
				SetDrawEnv xcoord=prel
			endif
			
			if ((LabelOptions == LO_Diagonal) && (i == j))
				if (WaveExists(matrixWave))
					labelStr = GetDimLabel(matrixWave, 1, j)
					if (strlen(labelStr) == 0)
						labelStr = NameOfWave(matrixWave)+"[]["+num2str(j)+"]"
					endif
				else
					labelStr = NameOfWave($Wave1)
				endif

				SetDrawEnv textxjust=1, textyjust= 1
				DrawText LabelTextX, LabelTextY, labelStr
			endif
		endfor
	endfor
	
	DoUpdate
	
	for (i = 0; i < nCols; i += 1)
		for (j = 0; j < nCols; j += 1)
			Variable noLabelValue1 = 0
			Variable noLabelValue2 = 0
			sprintf Axis1, "Y_%d_%d", i, j
			sprintf Axis2, "X_%d_%d", i, j
			
			if ((((PlotOptions & PO_Diagonal) != 0) && (i == j)) ||  (((PlotOptions & PO_LowerTriangle) != 0) && (i > j)) || (((PlotOptions & PO_UpperTriangle) != 0) && (i < j)))
				if (frames && (((LabelOptions == LO_Diagonal ) && (i != j)) || (LabelOptions != LO_Diagonal)))
					AddPlotSubFrame(graphname, Axis2, Axis1)
				endif
				
				if ( (PlotOptions & PO_ColoredBoxes) && (((LabelOptions == LO_Diagonal ) && (i != j)) || (LabelOptions != LO_Diagonal)) )
					AddPlotColoredBox(graphname, Axis2, Axis1)
				endif
			endif
			
			if ((((PlotOptions & PO_Diagonal) != 0) && (i == j)) ||  (((PlotOptions & PO_LowerTriangle) != 0) && (i > j)) || (((PlotOptions & PO_UpperTriangle) != 0) && (i < j)))
				Wave1 = StringFromList(i, WavesList)
				Wave2 = StringFromList(j, WavesList)
				if (WaveExists(matrixWave))
					LabelText = GetDimLabel(matrixWave, 1, i)
					if (strlen(labelStr) == 0)
						LabelText = NameOfWave(matrixWave)+"[]["+num2str(i)+"]"
					endif
				else
					LabelText = NameOfWave($Wave1)
				endif
				if (((j == 0) || ((i == 0)%&(j==1)%&((LabelOptions == LO_Diagonal) || ((PlotOptions %& PO_Diagonal) == 0)))) %& ((PlotOptions %& PO_LowerTriangle) != 0))
					if (LabelOptions != LO_Diagonal)
						Label $Axis1,LabelText
					endif
				else
					if (((i == j) || ((LabelOptions == LO_Diagonal) %& (i == j-1))) %& ((PlotOptions %& PO_Diagonal) != 0) %& ((PlotOptions %& PO_LowerTriangle) == 0))
						if (LabelOptions != LO_Diagonal)
							Label $Axis1 LabelText
						endif
					else
						if ((j-1 == i) %& ((PlotOptions %& PO_UpperTriangle) != 0) %& ((PlotOptions %& PO_LowerTriangle) == 0) %& ((PlotOptions %& PO_Diagonal) == 0))
							if (LabelOptions != LO_Diagonal)
								Label $Axis1 LabelText
							endif
						else
							if ((LabelOptions != LO_Diagonal) || (i != j))
								ModifyGraph noLabel($Axis1)=2
								noLabelValue1 = 2
							endif
						endif
					endif
				endif
				if (WaveExists(matrixWave))
					LabelText = GetDimLabel(matrixWave, 1, j)
					if (strlen(labelStr) == 0)
						LabelText = NameOfWave(matrixWave)+"[]["+num2str(j)+"]"
					endif
				else
					LabelText = NameOfWave($Wave2)
				endif
				if (((i == (nCols-1)) || ((i==(nCols-2))%&((j==(nCols-1)))%&((LabelOptions == LO_Diagonal) || ((PlotOptions %& PO_Diagonal) == 0)))) %& ((PlotOptions %& PO_LowerTriangle) != 0))
					if (LabelOptions != LO_Diagonal)
						Label $Axis2 LabelText
					endif
				else
					if (((i == j) || ((LabelOptions == LO_Diagonal) %& (i == j-1))) %& ((PlotOptions %& PO_Diagonal) != 0) %& ((PlotOptions %& PO_LowerTriangle) == 0))
						if (LabelOptions != LO_Diagonal)
							Label $Axis2 LabelText
						endif
					else
						if ((j-1 == i) %& ((PlotOptions %& PO_UpperTriangle) != 0) %& ((PlotOptions %& PO_LowerTriangle) == 0) %& ((PlotOptions %& PO_Diagonal) == 0))
							if (LabelOptions != LO_Diagonal)
								Label $Axis2 LabelText
							endif
						else
							if ((LabelOptions != LO_Diagonal) || (i != j))
								ModifyGraph noLabel($Axis2)=2
								noLabelValue2 = 2
							endif
						endif
					endif
				endif
			endif				
				
			GetAxis/Q $Axis1
			if (!V_flag)
				if (PlotOptions & PO_NoTicksOrLabels)	// no ticks or tick labels
					ModifyGraph tick($Axis1)=3
					ModifyGraph noLabel($Axis1)= noLabelValue1==0 ? 1 : noLabelValue1
				else
					ModifyGraph tick($Axis1)=2, lblPosMode($Axis1)=4,lblPos($Axis1)=55
					info.YAxisLabelPos = 55
				endif
			endif
			GetAxis/Q $Axis2
			if (!V_flag)
				if (PlotOptions & PO_NoTicksOrLabels)	// no ticks or tick labels
					ModifyGraph tick($Axis2)=3
					ModifyGraph noLabel($Axis2)= noLabelValue2==0 ? 1 : noLabelValue2
				else
					ModifyGraph tick($Axis2)=2, lblPosMode($Axis1)=4,lblPos($Axis2)=35
					info.XAxisLabelPos = 35
				endif
			endif
		endfor
	endfor
	
	String SaveDF=GetDatafolder(1)
	SetDatafolder root:Packages:WMScatterPlotMatrixPackage
	ModifyGraph mode=info.TraceMode
	ModifyGraph lsize=info.LineSize
	ModifyGraph msize=info.Markersize
	ModifyGraph marker=info.MarkerNumber
	ModifyGraph margin(left)=65,margin(bottom)=45 
	info.LeftMargin = 65
	info.BottomMargin = 45
	ModifyGraph fsize=9
	SetDatafolder $saveDF
	
	info.datafoldername = MakeGraphDataFolder(graphname, 0)
	
	SPM_StoreInfoInGraph(info, graphname)
	
	SetWindow $graphname,hook(ScatterPlotMatrixHook)=ScatterPlotMatrixHook

	return PlotMatrixErr_NoErr
end

Function AddPlotSubFrame(GraphName, Xaxis, Yaxis)
	String GraphName
	String Xaxis, Yaxis

	Variable xstart, xend, ystart, yend
	
	AxisExtent(GraphName, Xaxis, xstart, xend)
	AxisExtent(GraphName, Yaxis, ystart, yend)
	ystart = 1-ystart
	yend = 1-yend

	SetDrawLayer/W=$GraphName UserAxes
	SetDrawEnv/W=$GraphName xcoord= prel,ycoord= prel,fillpat= 0
	DrawPoly/W=$GraphName xstart, yend,1,1,{xstart,yend,xend,yend,xend,ystart}
End

Function AddPlotColoredBox(GraphName, Xaxis, Yaxis[, red, green, blue])
	String GraphName
	String Xaxis, Yaxis
	Variable red, green, blue

	Variable xstart, xend, ystart, yend
	
	if (ParamIsDefault(red))
		red = 50000
		green = 50000
		blue = 50000
	endif
	
	AxisExtent(GraphName, Xaxis, xstart, xend)
	AxisExtent(GraphName, Yaxis, ystart, yend)
	ystart = 1-ystart
	yend = 1-yend

	SetDrawLayer/W=$GraphName UserBack
	SetDrawEnv/W=$GraphName xcoord= prel,ycoord= prel,fillpat= 1, fillfgc=(red, green, blue), linethick=0
	DrawPoly/W=$GraphName xstart, ystart,1,1,{xstart,ystart,xstart,yend,xend,yend,xend,ystart,xstart,ystart}
End

Function AxisRange(GraphName, axis, axisStart, axisEnd)
	String GraphName
	String axis
	Variable &AxisStart, &AxisEnd
	
	GetAxis/W=$GraphName/Q $axis
	AxisStart = V_min
	AxisEnd = V_max
	return 0
end

Function AxisExtent(GraphName, axis, axisStart, axisEnd)
	String GraphName
	String axis
	Variable &AxisStart, &AxisEnd

	AxisStart = GetNumFromModifyStr(AxisInfo(GraphName, axis), "axisEnab", "{", 0)
	axisEnd = GetNumFromModifyStr(AxisInfo(GraphName, axis), "axisEnab", "{", 1)
	return 0
end

Function SPMFree_FindMarkedPoint(GraphName, xMarker, yMarker, markerSize)
	String GraphName
	Variable xMarker, yMarker, markerSize

	String cName = NameOfFirstCursorOnGraph(GraphName)
	Wave CWave = CsrWaveRef($cName, GraphName)
	String CWaveName=GetWavesDataFolder(CWave, 2)
	String TraceNames=TraceNameList(GraphName, ";", 1)
	String CTraceName = CsrWave($cName, GraphName, 1)
	String ThisTrace

	Variable cursorPoint = pcsr($cName, GraphName)
	
	Variable hasMatrix = 0
	Variable matrixYCol, matrixXCol 
	if (WaveDims(CWave) == 2)
		hasMatrix = 1
		matrixYCol = str2num(StringFromList(1, CTraceName, "_"))
		matrixXCol = str2num(StringFromList(2, CTraceName, "_"))
	endif

	Variable i=0, Instance=0
	Variable nTraces = ItemsInList(TraceNames)
	for (i = 0; i < nTraces; i += 1)
		ThisTrace = StringFromList(i, TraceNames)
		// Find the cursorwave used as Y wave
		if (hasMatrix)
			Variable yCol = str2num(StringFromList(1, ThisTrace, "_"))
			Variable xCol = str2num(StringFromList(2, ThisTrace, "_"))
			if (matrixYCol == yCol)
				MarkPoint(GraphName, ThisTrace, CWave, 0, 0, cursorPoint, xMarker, yMarker, markerSize)
			endif
			if (matrixYCol == xCol)
				MarkPoint(GraphName, ThisTrace, CWave, 0, 1, cursorPoint, xMarker, yMarker, markerSize)
			endif
		else
			if (cmpstr(CWaveName, GetWavesDataFolder(TraceNametoWaveRef("", ThisTrace), 2)) == 0)
				MarkPoint(GraphName, ThisTrace, CWave, Instance, 0, cursorPoint, xMarker, yMarker, markerSize)
				Instance += 1
			endif
			if (cmpstr(CWaveName, GetWavesDataFolder(XWaveRefFromTrace("", ThisTrace), 2)) == 0)
				MarkPoint(GraphName, ThisTrace, CWave, Instance, 1, cursorPoint, xMarker, yMarker, markerSize)
				Instance += 1
			endif
		endif
	endfor
end	

Function MarkPoint(GraphName, TraceName, CWave, Instance, isX, cursorPoint, xMarker, yMarker, markerSize)
	String GraphName
	String TraceName
	Wave CWave
	Variable Instance, isX
	Variable cursorPoint
	Variable xMarker, yMarker, markerSize
	
//	String GName=WinName(0,1)
	String MarkWaveNameX="Mark"+GraphName+num2istr(Instance)+"X"
	MarkWaveNameX = UniqueName(MarkWaveNameX, 1, 0)
	String MarkWaveNameY="Mark"+GraphName+num2istr(Instance)+"Y"
	MarkWaveNameY = UniqueName(MarkWaveNameY, 1, 0)
	
	String SaveDF = SPM_SetGraphDataFolder(GraphName)
	if (strlen(SaveDF) == 0)		// not a Scatter Plot Matrix graph
		return -1
	endif
		MarkWaveNameX = UniqueName(MarkWaveNameX, 1, 0)
		MarkWaveNameY = UniqueName(MarkWaveNameY, 1, 0)	
		Make/O/N=1 $MarkWaveNameX
		Make/O/N=1 $MarkWaveNameY
		Wave wx=$MarkWaveNameX
		Wave wy=$MarkWaveNameY
	SetDataFolder SaveDF

	if (WaveDims(CWave) == 2)
		Variable yCol = str2num(StringFromList(1, TraceName, "_"))
		Variable xCol = str2num(StringFromList(2, TraceName, "_"))
		wy[0] = CWave[cursorPoint][yCol]
		wx[0] = CWave[cursorPoint][xCol]
	else
		if (isX)
			wx[0] = CWave[cursorPoint]
			wy[0] = TraceNametoWaveRef(GraphName, TraceName)[cursorPoint]
		else
			wy[0] = CWave[cursorPoint]
			wx[0] = XWaveRefFromTrace(GraphName, TraceName)[cursorPoint]
		endif
	endif
	
	String TInfo = TraceInfo(GraphName, TraceName, 0)
	String XAxis = StringByKey("XAXIS",TInfo)
	String YAxis = StringByKey("YAXIS",TInfo)
//print TraceName, MarkWaveNameY, wy[0], wx[0], YAxis, XAxis
	AppendToGraph/W=$GraphName/L=$YAxis/B=$XAxis wy vs wx
	ModifyGraph/W=$GraphName mode($MarkWaveNameY)=3, marker($MarkWaveNameY)=8, msize($MarkWaveNameY)=markerSize
	if (isX)
		ModifyGraph/W=$GraphName marker($MarkWaveNameY)=xMarker
	else
		ModifyGraph/W=$GraphName marker($MarkWaveNameY)=yMarker
	endif
end

Function SPM_FreeAxisRemoveMarks(GName)
	String GName

	String TraceNames=TraceNameList(GName, ";", 1)
	String ThisTrace

	
	Variable i=0
	do
		ThisTrace = StringFromList(i, TraceNames)
		if (strlen(ThisTrace) == 0)
			break
		endif
		if (cmpstr(ThisTrace[0,3], "Mark") == 0)
			Wave wx=XWaveRefFromTrace(GName, ThisTrace)
			Wave wy=TraceNameToWaveRef(GName, ThisTrace)
			RemoveFromGraph/W=$GName $ThisTrace
			KillWaves/z wx, wy
		endif
		i += 1
	while (1)
end

Function SPM_FreeAxisRegression(GraphName, AddTraces, RobustFit)
	String GraphName
	Variable AddTraces, RobustFit
	
	
	String TraceNames=TraceNameList(GraphName, ";", 1)
	String ThisTrace
	String tagtext
	String TInfo
	String XAxis
	String YAxis
	String XWave,YWave
	String NewWaveName=""
	Variable AutotraceOn
	Variable DoRobust = 0
	String TagName=""
	String AMessage
	
	String SaveDF = SPM_SetGraphDataFolder(GraphName)
	if (strlen(SaveDF) == 0)		// not a Scatter Plot Matrix graph
		return -1
	endif

	Variable/G V_FitOptions=4	// Suppress progress window
	//Variable/G K0, K1, V_Pr
	Variable/G V_FitError
	
	AutotraceOn = AddTraces
	DoRobust = RobustFit
	
	if (DoRobust)
		Make/N=2/O Fcoef = {0,1}
		Wave coef=Fcoef
	endif
		
	Variable i=0, Instance=0
	Variable nTraces = ItemsInList(TraceNames)
	for (i = 0; i < nTraces; i += 1)
		ThisTrace = StringFromList(i, TraceNames)
		if ( (cmpstr(ThisTrace[0,3], "Fit_") != 0) && (cmpstr(ThisTrace[0,8], "MarkGraph") != 0) )
			Wave w=TraceNameToWaveRef(GraphName, ThisTrace)
			Wave wavex = XWaveRefFromTrace(GraphName, ThisTrace)

			XWave=GetWavesDataFolder(wavex, 4)
			YWave=GetWavesDataFolder(w, 4)
			
			Variable yCol = 0
			Variable xCol = 0
			if (WaveDims(w) == 2)
				yCol = str2num(StringFromList(1, ThisTrace, "_"))
				xCol = str2num(StringFromList(2, ThisTrace, "_"))
			endif
			if (AutotraceOn)
				NewWaveName = "Fit_"+num2istr(i)
				NewWaveName = UniqueName(NewWaveName, 1, 0)
				Make/O/D/N=(DimSize(w, 0)) $NewWaveName/WAVE=fitWave
			endif
			V_FitOptions = 4
			CurveFit/Q line, w[][yCol] /X=wavex[][xCol]
			Wave coef=W_coef
			if (DoRobust)
				V_FitOptions += 2
				Wave rcoef=Fcoef
				rcoef=coef
				Duplicate/O coef, Eps
				Wave e=Eps
				e=1
				V_FitError=0
				FuncFit/Q/N SPM_LineFit, Fcoef, w[][yCol] /X=wavex[][xCol]/E=Eps
				if (V_FitError %& 2)
					sprintf AMessage, "Singular Matrix while fitting %s vs %s; Continue?",YWave, XWave
					DoAlert 1, AMessage
					if (V_flag == 2)
						SetDataFolder saveDF
						return -1
					else
						tagtext = "Singular Matrix"
					endif
				else
					sprintf tagtext,"\Z09a=%g\rb=%g", Fcoef[0], Fcoef[1]
				endif
				Wave coef=Fcoef
			else
				sprintf tagtext,"\Z09\[0a=%g\rb=%g\rr\y+102\M=%g", coef[0], coef[1], V_r2
			endif
			if (AutotraceOn)
				fitWave = coef[0]+coef[1]*wavex[p][xCol]
				TInfo = TraceInfo(GraphName, ThisTrace, 0)
				XAxis = StringByKey("XAXIS",TInfo)
				YAxis = StringByKey("YAXIS",TInfo)
				AppendToGraph/W=$GraphName/B=$XAxis/L=$YAxis fitWave vs wavex[][xCol]
			endif
			TagName = UniqueTagName("MPR_"+num2istr(i))
			String axisName = StringByKey("XAXIS", TraceInfo(GraphName, ThisTrace, 0))
			GetAxis/Q $axisName
			Tag/W=$GraphName/N=$TagName/L=0/X=0/Y=0/B=1/A=MC $axisName, V_max, tagtext
		endif
	endfor
	
	SetDataFolder saveDF
	return 0
end

Function/S UniqueTagName(TrialName)
	String TrialName
	
	Variable i=0
	String TagList=AnnotationList("")
	String aName
	String Suffix=""
	Variable SuffixNum=0
	
	do
		aName = StringFromList(i, TagList)
		if (strlen(aName) == 0)
			break
		endif
		if (cmpstr(aName, TrialName+Suffix) == 0)
			Suffix = num2istr(SuffixNum)
			SuffixNum += 1
			i = -1
		endif
		i += 1
	while(1)
	
	return TrialName+Suffix
end

Function SPM_FreeAxisRmveTags(GraphName)
	String GraphName
	
	String TagList=AnnotationList(GraphName)
	String ThisOne
	Variable i=0
	do
		ThisOne=StringFromList(i, TagList)
		if (strlen(ThisOne) == 0)
			break
		endif
		if (cmpstr("MPR_", ThisOne[0,3]) == 0)
			Tag/W=$GraphName/K /N=$ThisOne
		endif
		i += 1
	while(1)
End

Function SPM_FreeAxisRemoveRegressTraces(GraphName)
	String GraphName

	String TraceNames=TraceNameList(GraphName, ";", 1)
	String ThisTrace=""
	
	Variable i=0
	do
		ThisTrace = StringFromList(i, TraceNames)
		if (strlen(ThisTrace) == 0)
			break
		endif
		if (cmpstr(ThisTrace[0,3], "Fit_") == 0)
			Wave w=TraceNameToWaveRef("", ThisTrace)
			Wave wavex = XWaveRefFromTrace("", ThisTrace)
			RemoveFromGraph/W=$GraphName $ThisTrace
			KillWaves/Z w, wavex
		endif
		i += 1
	while (1)
End

Function/D SPM_LineFit(w, xx)
	Wave w
	Variable xx
	
	return w[0]+w[1]*xx
end
