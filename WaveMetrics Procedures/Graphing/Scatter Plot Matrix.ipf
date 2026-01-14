#pragma rtGlobals=2
#pragma version=1.22
#pragma IgorVersion=4.00

#include <Axis Utilities>
#include <Keyword-Value>

// **********************************
// Version 1.1 adds minor enhancements:
// 1) rearranged controls on the control panel for better appearance and readability
// 2) using groupbox controls that are new in v. 4.00
// 3) changed to comply with gray appearance that's so popular right now
//
// Changes in version 1.2:
// 1) Marker selector panel selects a marker, doesn't just show you the marker numbers.
// 2) Options to plot with no ticks or tick labels.
// 3) Option to make colored boxes behind each little plot.
// 4) Fixed bug- the current data folder was not restored after making a scatter plot matrix.
//
// Changes in version 1.21
// Changed the way coordinates for plot frames and background color boxes are calculated in order to improve
//   the alignment of the boxes with  the axes
//
// Changes in version 1.22
// Remove dependencies on Strings As Lists procedure file (which is obsolete):
// 	Changed GetStrFromList calls to use StringFromList
// 	Changed RemoveItemFromList to use RemoveFromList
// **********************************

Menu "Macros"
	"Scatter Plot Matrix Control Panel", MakeScatterPlotMatrixPanel()
end

Function MakeScatterPlotMatrixPanel()

	if (wintype("ScatterPlotMatrixPanel") != 7)
		MatrixPlotGlobals()
		fScatterPlotMatrixPanel()
	else
		DoWindow/F ScatterPlotMatrixPanel
	endif
end

// Function to make necessary data folders and globals for Matrix Plot Panel
//   Should be called when initializing panel.
Function MatrixPlotGlobals()

	string sFolder=GetDataFolder(1)
	SetDataFolder root:
	
	NewDataFolder/S/O Packages
	NewDataFolder/S/O WMScatterPlotMatrixPackage
	
	// Here are the globals
	String/G gMPWaveList=""
	Variable/G gMPTraceMode=3, gMPMainMarker=8, gMPMainMarkerSize=3, gMPLineSize=1
	Variable/G gMPXMarker=17, gMPYMarker=19
	Variable/G gMPMarkerSize=5
	Variable/G gMPMarkerThick=1
	
	SetDataFolder $sFolder
end

Function PairPlot(WavesList, PlotOptions, LabelOptions, Frames)
	String WavesList
	Variable PlotOptions	// bit 0: Include lower triangle;bit 1: Include diagonal;
							// bit 2: include upper triangle; bit 3: No ticks or tick labels;
							// bit 4: Colored boxes
	Variable LabelOptions	//0: left and bottom
							//1: top and right
							//2: diagonal
	Variable Frames		//=1 for boxes around each graph
	
	Silent 1; 
	PauseUpdate
	
	String Wave1,Wave2, Axis1="", Axis2=""
	String LabelText
	
	Variable nWaves
	Variable i, j
	Variable MinPercent, MaxPercent, PercentBetween, PercentRange,PercentBase
	Variable LabelTextX, LabelTextY
	Variable AxMin
	
	i = -1
	do
		i += 1
		Wave1 = StringFromList(i, WavesList)
		if (strlen(Wave1) <= 0)
			break
		endif
		if (!exists(Wave1))
			abort "One of your waves, "+Wave1+", does not exist"
		endif
	while (1)
	
	if (i <= 1)
		abort "Need at least two waves in list"
	endif
	
	nWaves = i
	PercentBase = 1/nWaves
	PercentRange = .8*PercentBase
	
	if (LabelOptions == 2)
		PlotOptions = PlotOptions | 2
	endif
	
	Display
		
	i = 0
	do
		j = 0
		do
			if ((((PlotOptions & 2) != 0) && (i == j)) ||  (((PlotOptions & 1) != 0) && (i > j)) || (((PlotOptions & 4) != 0) && (i < j)))
				Wave1 = StringFromList(i, WavesList)
				Wave2 = StringFromList(j, WavesList)
				sprintf Axis1, "Y_%d%d", i, j
				sprintf Axis2, "X_%d%d", i, j
				
				
				MinPercent = (nWaves-i-1)*PercentBase
				MaxPercent = MinPercent+PercentRange
				LabelTextY = 1-(MinPercent+MaxPercent)/2
				if (((LabelOptions == 2) && (i != j)) || (LabelOptions != 2))
					AppendToGraph/B=$Axis2/L=$Axis1 $Wave1 vs $Wave2
					SetAxis/A/N=2 $Axis1
					SetAxis/A/N=2 $Axis2
					ModifyGraph axisEnab($Axis1)={MinPercent,MaxPercent}
				endif
				
										
				MinPercent = j*PercentBase
				MaxPercent = MinPercent+PercentRange
				LabelTextX = (MinPercent+MaxPercent)/2
				if (((LabelOptions == 2) && (i != j)) || (LabelOptions != 2))
					ModifyGraph axisEnab($Axis2)={MinPercent,MaxPercent}
				endif
				
				SetDrawLayer ProgBack
				SetDrawEnv xcoord=prel
			endif
			
			if ((LabelOptions == 2) && (i == j))
				SetDrawEnv textxjust=1, textyjust= 1
				DrawText LabelTextX, LabelTextY, NameOfWave($Wave1)
			endif

			j += 1
		while (j<nWaves)
		
	i += 1
	while (i<nWaves)
	
	DoUpdate
	
	i = 0
	do
		j = 0
		do
			Variable noLabelValue1 = 0
			Variable noLabelValue2 = 0
			sprintf Axis1, "Y_%d%d", i, j
			sprintf Axis2, "X_%d%d", i, j
			
			if ((((PlotOptions & 2) != 0) && (i == j)) ||  (((PlotOptions & 1) != 0) && (i > j)) || (((PlotOptions & 4) != 0) && (i < j)))
				if (frames && (((LabelOptions == 2 ) && (i != j)) || (LabelOptions != 2)))
					AddPlotSubFrame(Axis2, Axis1)
				endif
				
				if ( (PlotOptions & 16) && (((LabelOptions == 2 ) && (i != j)) || (LabelOptions != 2)) )
					AddPlotColoredBox(Axis2, Axis1)
				endif
			endif
			
			if ((((PlotOptions & 2) != 0) && (i == j)) ||  (((PlotOptions & 1) != 0) && (i > j)) || (((PlotOptions & 4) != 0) && (i < j)))
				Wave1 = StringFromList(i, WavesList)
				Wave2 = StringFromList(j, WavesList)
				LabelText = NameOfWave($Wave1)
				if (((j == 0) || ((i == 0)%&(j==1)%&((LabelOptions == 2) || ((PlotOptions %& 2) == 0)))) %& ((PlotOptions %& 1) != 0))
					if (LabelOptions != 2)
						Label $Axis1,LabelText
						ModifyGraph lblPos($Axis1)=40
					endif
				else
					if (((i == j) || ((LabelOptions == 2) %& (i == j-1))) %& ((PlotOptions %& 2) != 0) %& ((PlotOptions %& 1) == 0))
						if (LabelOptions != 2)
							Label $Axis1 LabelText
							ModifyGraph lblPos($Axis1)=40
						endif
					else
						if ((j-1 == i) %& ((PlotOptions %& 4) != 0) %& ((PlotOptions %& 1) == 0) %& ((PlotOptions %& 2) == 0))
							if (LabelOptions != 2)
								Label $Axis1 LabelText
								ModifyGraph lblPos($Axis1)=40
							endif
						else
							if ((LabelOptions != 2) || (i != j))
								ModifyGraph noLabel($Axis1)=2
								noLabelValue1 = 2
							endif
						endif
					endif
				endif
				LabelText = NameOfWave($Wave2)
				if (((i == (nWaves-1)) || ((i==(nWaves-2))%&((j==(nWaves-1)))%&((LabelOptions == 2) || ((PlotOptions %& 2) == 0)))) %& ((PlotOptions %& 1) != 0))
					if (LabelOptions != 2)
						Label $Axis2 LabelText
						ModifyGraph lblPos($Axis2)=30
					endif
				else
					if (((i == j) || ((LabelOptions == 2) %& (i == j-1))) %& ((PlotOptions %& 2) != 0) %& ((PlotOptions %& 1) == 0))
						if (LabelOptions != 2)
							Label $Axis2 LabelText
							ModifyGraph lblPos($Axis2)=30
						endif
					else
						if ((j-1 == i) %& ((PlotOptions %& 4) != 0) %& ((PlotOptions %& 1) == 0) %& ((PlotOptions %& 2) == 0))
							if (LabelOptions != 2)
								Label $Axis2 LabelText
								ModifyGraph lblPos($Axis2)=30
							endif
						else
							if ((LabelOptions != 2) || (i != j))
								ModifyGraph noLabel($Axis2)=2
								noLabelValue2 = 2
							endif
						endif
					endif
				endif
			endif				
				
			GetAxis/Q $Axis2
			if (!V_flag)
				ModifyGraph freePos($Axis1)={V_min, $Axis2}
			endif
			GetAxis/Q $Axis1
			if (!V_flag)
				ModifyGraph freePos($Axis2)={V_min, $Axis1}
			endif
			
			GetAxis/Q $Axis1
			if (!V_flag)
				if (PlotOptions & 8)	// no ticks or tick labels
					ModifyGraph tick($Axis1)=3
					ModifyGraph noLabel($Axis1)= noLabelValue1==0 ? 1 : noLabelValue1
				else
					ModifyGraph tick($Axis1)=2, lblPos($Axis1)=25
				endif
			endif
			GetAxis/Q $Axis2
			if (!V_flag)
				if (PlotOptions & 8)	// no ticks or tick labels
					ModifyGraph tick($Axis2)=3
					ModifyGraph noLabel($Axis2)= noLabelValue2==0 ? 1 : noLabelValue2
				else
					ModifyGraph tick($Axis2)=2, lblPos($Axis2)=25
				endif
			endif
			j += 1
		while (j<nWaves)
		i += 1
	while (i < nWaves)
	
	String SaveDF=GetDatafolder(1)
	SetDatafolder root:Packages:WMScatterPlotMatrixPackage
	NVAR gMPTraceMode
	NVAR gMPLineSize
	NVAR gMPMainMarkerSize
	NVAR gMPMainMarker
	ModifyGraph mode=gMPTraceMode
	ModifyGraph lsize=gMPLineSize
	ModifyGraph msize=gMPMainMarkerSize
	ModifyGraph marker=gMPMainMarker
	if ((((PlotOptions %& 1) != 0) || ((PlotOptions %& 2) != 0)) %& LabelOptions != 2)
		ModifyGraph margin(left)=72,margin(bottom)=72 
	endif
	ModifyGraph font="Monaco", fsize=9
	SetDatafolder $saveDF
end

Function AddPlotSubFrame(Xaxis, Yaxis)
	String Xaxis, Yaxis

	Variable xstart, xend, ystart, yend
	
	AxisExtent(Xaxis, xstart, xend)
	AxisExtent(Yaxis, ystart, yend)

	SetDrawLayer UserAxes
	SetDrawEnv xcoord= $Xaxis,ycoord= $Yaxis,fillpat= 0
	DrawPoly xstart, ystart,1,1,{xstart,ystart,xstart,yend,xend,yend,xend,ystart,xstart,ystart}
End

Function AddPlotColoredBox(Xaxis, Yaxis)
	String Xaxis, Yaxis

	Variable xstart, xend, ystart, yend
	
	AxisExtent(Xaxis, xstart, xend)
	AxisExtent(Yaxis, ystart, yend)

	SetDrawLayer UserBack
	SetDrawEnv xcoord= $Xaxis,ycoord= $Yaxis,fillpat= 1, fillfgc=(50000,50000,50000), linethick=0
	DrawPoly xstart, ystart,1,1,{xstart,ystart,xstart,yend,xend,yend,xend,ystart,xstart,ystart}
End

Function AxisExtent(axis, axisStart, axisEnd)
	String axis
	Variable &AxisStart, &AxisEnd
	
	GetAxis/Q $axis
	AxisStart = V_min
	AxisEnd = V_max
	return 0
end

Function TraceModePopProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	NVAR gMPTraceMode=root:Packages:WMScatterPlotMatrixPackage:gMPTraceMode
	
	if (popNum == 1)
		gMPTraceMode = 2
	else
		if (popNum == 2)
			gMPTraceMode=3
		else
			if (popNum == 3)
				gMPTraceMode=0
			else	
				gMPTraceMode=4
			endif
		endif
	endif
End


Function fScatterPlotMatrixPanel() : Panel

	NewPanel /K=1/W=(25,48,395,499) as "Scatter Plot Matrix Controls"
	DoWindow/C ScatterPlotMatrixPanel
	
	GroupBox ScatterMatrixPlotLayoutGroup,pos={13,2},size={343,73},title="Plot Layout"
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

	GroupBox ScatterMatrixTrAppearanceGroup,pos={13,85},size={344,109},title="Trace Appearance"
		PopupMenu TraceModePopup,pos={20,103},size={143,20},proc=TraceModePopProc
		PopupMenu TraceModePopup,help={"Choose how you want the data to be shown on the plots."}
		PopupMenu TraceModePopup,mode=4,popvalue="Lines and Markers",value= #"\"Dots;Markers;Lines;Lines and Markers\""
		SetVariable SetMarkerSize,pos={49,148},size={101,15},title="Marker Size:"
		SetVariable SetMarkerSize,help={"Sets the size of the markers used to plot the data."}
		SetVariable SetMarkerSize,limits={0,10,0.5},value= root:Packages:WMScatterPlotMatrixPackage:gMPMainMarkerSize
		SetVariable Set_Marker,pos={49,129},size={101,15},title="Marker:"
		SetVariable Set_Marker,help={"Choose marker number for plotting data.  The numbers are the same as those used to assign markers in the Modify Trace Appearance dialog."}
		SetVariable Set_Marker,limits={0,44,1},value= root:Packages:WMScatterPlotMatrixPackage:gMPMainMarker
		SetVariable SetLineSize,pos={176,148},size={127,15},title="Line Thickness:"
		SetVariable SetLineSize,help={"Sets the line thickness for the data trace when you have chosen Lines or Lines and Markers mode in the Trace Mode popup."}
		SetVariable SetLineSize,limits={0,10,0.5},value= root:Packages:WMScatterPlotMatrixPackage:gMPLineSize
		SetVariable SetMarkerThick,pos={176,129},size={127,15},title="Marker Thickness:"
		SetVariable SetMarkerThick,help={"Sets the thickness of the line used to draw marker outlines."}
		SetVariable SetMarkerThick,limits={0,10,0.5},value= root:Packages:WMScatterPlotMatrixPackage:gMPMarkerThick
		Button ChangeTrace,pos={285,167},size={61,20},proc=ChangeTracesProc,title="Change"
		Button ChangeTrace,help={"The choices for Trace Mode, etc. are applied to the top graph window.  Otherwise, the settings in this area are applied when a new graph is made using the Make Plot button."}
		Button MarkerKeyButton,pos={19,167},size={119,20},proc=SPMSelectMarkerButtonProc,title="Select Marker..."
		Button MarkerKeyButton,help={"Creates a window showing graph markers and the marker numbers.  The window looks like you ought to be able to click the markers, but you can't."}

	GroupBox ScatterMatrixWavesGroup,pos={13,207},size={344,57},title="Waves to Plot"
		SetVariable MatrixPlotSetListOfWaves,pos={21,246},size={323,15},title=" "
		SetVariable MatrixPlotSetListOfWaves,help={"Editable list of wave names to include in the plot."}
		SetVariable MatrixPlotSetListOfWaves,fSize=9
		SetVariable MatrixPlotSetListOfWaves,limits={-Inf,Inf,1},value= root:Packages:WMScatterPlotMatrixPackage:gMPWaveList
		PopupMenu AddWaveMenu,pos={21,227},size={89,20},proc=AddWaveProc,title="Add Wave"
		PopupMenu AddWaveMenu,help={"Select waves to add to the list of waves.\r\r\"Add All\" adds all waves in the current data folder to the list.\r\r\"Top Table Selection\" adds any waves selected in the top table window."}
		PopupMenu AddWaveMenu,mode=0,value= #"WaveList(\"*\",\";\",\"\")+\"-;Add All;Top Table Selection\""
		PopupMenu RemoveWaveMenu,pos={242,227},size={99,20},proc=RmveWaveProc,title="Rmve Wave"
		PopupMenu RemoveWaveMenu,help={"Select waves to be removed from the list of waves.\r\r\"Remove All\" empties the list."}
		PopupMenu RemoveWaveMenu,mode=0,value= #"root:Packages:WMScatterPlotMatrixPackage:gMPWaveList+\"-;Remove All\""

	Button MakePlot,pos={242,275},size={72,20},proc=MakePlotButton,title="Make Plot"
	Button MakePlot,help={"Make the whole dang plot."}

	GroupBox ScatterMatrixFindPointGroup,pos={13,296},size={344,66},title="Find Data Point"
		Button MarkPoints,pos={243,312},size={103,20},proc=MarkCsrPntsBProc,title="Mark Csr Pnts"
		Button MarkPoints,help={"Mark any point on the plot with Cursor A (the round one).  When this button is clicked, every point on the plot that uses that Y value (as either X or Y data) will be marked.\r\rTo make the cursors available, select \"Show Info\" from the Graph menu."}
		Button RmvePoints,pos={243,336},size={103,20},proc=RmveMarksBProc,title="Remove Marks"
		Button RmvePoints,help={"Removes all the markers from the graph."}
		SetVariable XMarker,pos={21,314},size={49,17},title="X:"
		SetVariable XMarker,help={"Sets the number of the marker to use when marking points.  This box sets the marker for points that use the selected value as an X value.\r\rThe marker numbers are the same as the markers in the Modify Trace Appearance dialog."}
		SetVariable XMarker,fSize=9
		SetVariable XMarker,limits={0,44,1},value= root:Packages:WMScatterPlotMatrixPackage:gMPXMarker,bodyWidth= 35
		SetVariable YMarker,pos={81,314},size={49,17},title="Y:"
		SetVariable YMarker,help={"Sets the number of the marker to use when marking points.  This box sets the marker for points that use the selected value as an Y value.\r\rThe marker numbers are the same as the markers in the Modify Trace Appearance dialog."}
		SetVariable YMarker,fSize=9
		SetVariable YMarker,limits={0,44,1},value= root:Packages:WMScatterPlotMatrixPackage:gMPYMarker,bodyWidth= 35
		SetVariable MarkerSize,pos={143,314},size={62,17},title="Size:"
		SetVariable MarkerSize,help={"Sets the size of the marker to use when marking points.  This box sets the marker size for all marked points."}
		SetVariable MarkerSize,fSize=9
		SetVariable MarkerSize,limits={0,10,0.5},value= root:Packages:WMScatterPlotMatrixPackage:gMPMarkerSize,bodyWidth= 35

	GroupBox ScatterMatrixRegressionGroup,pos={13,371},size={344,70},title="Linear Regression"
		Button RegressButton,pos={120,403},size={104,20},proc=RegressButProc,title="Do Regression"
		Button RegressButton,help={"Do a linear fit to the data in each sub-plot.  Tags will be attached to each plot with information on the results."}
		CheckBox FitLinesCheck,pos={21,394},size={86,14},title="Add Fit Traces"
		CheckBox FitLinesCheck,help={"When doing the linear regression, add a trace to each plot showing the regression result.\r\rAlso makes a wave to contain the data resulting from the regression"}
		CheckBox FitLinesCheck,value= 0
		CheckBox RobustFit,pos={21,414},size={78,14},title="\"Robust\" Fit"
		CheckBox RobustFit,help={"When doing the linear regression, use least absolute error method instead of least squares.  The least absolute error method is less sensitive to outliers."}
		CheckBox RobustFit,value= 0

		GroupBox RegressionGroupKillGroup,pos={235,385},size={115,50},title="Kill:"
		Button RmvRegressionTags,pos={240,403},size={49,20},proc=RmveTagsButProc,title="Tags"
		Button RmvRegressionTags,help={"Remove from the top graph all tags produced by the Do Regression button."}
		Button RmvRegressionTraces,pos={295,403},size={49,20},proc=RemoveRegressTraces,title="Traces"
		Button RmvRegressionTraces,help={"Remove from the top graph all traces produced by the Do Regression button.  Also kills the waves associated with those traces."}
		CheckBox NoTicksCheckbox,pos={20,54},size={132,14},title="NO Ticks or Tick Labels"
		CheckBox NoTicksCheckbox,help={"Plot lower triangle of plot matrix"},value= 0
		CheckBox ColoredboxesCheck,pos={160,54},size={149,14},title="Colored Boxes Behind Plots"
		CheckBox ColoredboxesCheck,help={"Plot lower triangle of plot matrix"},value= 0
EndMacro

Function AddWaveProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	SVAR gMPWaveList=root:Packages:WMScatterPlotMatrixPackage:gMPWaveList
	if (cmpstr(popStr, "Add All") == 0)
		gMPWaveList = WaveList("*", ";", "")
	else
		if (cmpstr(popStr, "Top Table Selection")== 0)
			gMPWaveList += TableWaveList()
		else
			gMPWaveList += popStr+";"
		endif
	endif
End

Function RmveWaveProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	SVAR gMPWaveList=root:Packages:WMScatterPlotMatrixPackage:gMPWaveList
	if (cmpstr(popStr, "Remove All") == 0)
		gMPWaveList = ""
	else
		gMPWaveList = RemoveFromList(popStr, gMPWaveList)
	endif
End

Function/S TableWaveList()

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

Function MakePlotButton(ctrlName) : ButtonControl
	String ctrlName
	
	Variable PlotOptions, LabelOptions, Frames
	String ListVar="root:Packages:WMScatterPlotMatrixPackage:gMPWaveList"
	String PlotCommand=""
	
	ControlInfo UpperTriangle
	if (V_Value)
		PlotOptions = PlotOptions | 4
	else
		PlotOptions = PlotOptions %& (%~4)
	endif
	ControlInfo LowerTriangle
	if (V_Value)
		PlotOptions = PlotOptions | 1
	else
		PlotOptions = PlotOptions %& (%~1)
	endif
	ControlInfo Diagonal
	if (V_Value)
		PlotOptions = PlotOptions | 2
	else
		PlotOptions = PlotOptions %& (%~2)
	endif
	if (PlotOptions == 0)
		Abort "You must select at least one of Upper Triangle, Lower Triangle and Diagonal"
	endif
	ControlInfo NoTicksCheckbox
	if (V_Value)
		PlotOptions = PlotOptions | 8
	else
		PlotOptions = PlotOptions %& (%~8)
	endif
	ControlInfo ColoredboxesCheck
	if (V_Value)
		PlotOptions = PlotOptions | 16
	else
		PlotOptions = PlotOptions %& (%~16)
	endif
	
	ControlInfo DiagonalLabels
	if (V_Value)
		LabelOptions = 2
	else
		LabelOptions = 0
	endif
	ControlInfo FramePlots
	if (V_Value)
		Frames = 1
	else
		Frames = 0
	endif
	
	sprintf PlotCommand, "PairPlot(%s, %d, %d, %d)", ListVar, PlotOptions, LabelOptions, Frames
	Execute PlotCommand
End

Function FindMarkedPoint()

	Wave CWave=CsrWaveRef(A)
	if (strlen(NameOfWave(CWave)) == 0)
		Abort "Cursor A is not on the top graph"
	endif
	String CWaveName=GetWavesDataFolder(CWave, 2)
	String TraceNames=TraceNameList("", ";", 1)
	String ThisTrace
	
	Variable i=0, Instance=0
	do
		ThisTrace = StringFromList(i, TraceNames)
		if (strlen(ThisTrace) == 0)
			break
		endif
		// Find the cursorwave used as Y wave
		if (cmpstr(CWaveName, GetWavesDataFolder(TraceNametoWaveRef("", ThisTrace), 2)) == 0)
			MarkPoint(ThisTrace, CWave, Instance, 0)
			Instance += 1
		endif
		if (cmpstr(CWaveName, GetWavesDataFolder(XWaveRefFromTrace("", ThisTrace), 2)) == 0)
			MarkPoint(ThisTrace, CWave, Instance, 1)
			Instance += 1
		endif
		i += 1
	while (1)
end	

Function MarkPoint(TraceName, CWave, Instance, isX)
	String TraceName
	Wave CWave
	Variable Instance, isX
	
	NVAR gMPXMarker=root:Packages:WMScatterPlotMatrixPackage:gMPXMarker
	NVAR gMPYMarker=root:Packages:WMScatterPlotMatrixPackage:gMPYMarker
	NVAR gMPMarkerSize=root:Packages:WMScatterPlotMatrixPackage:gMPMarkerSize
	
	String GName=WinName(0,1)
	String MarkWaveNameX="Mark"+GName+num2istr(Instance)+"X"
	MarkWaveNameX = UniqueName(MarkWaveNameX, 1, 0)
	String MarkWaveNameY="Mark"+GName+num2istr(Instance)+"Y"
	MarkWaveNameY = UniqueName(MarkWaveNameY, 1, 0)
	Make/O/N=1 $MarkWaveNameX
	Make/O/N=1 $MarkWaveNameY
	Wave wx=$MarkWaveNameX
	Wave wy=$MarkWaveNameY
	
	if (isX)
		wx[0] = CsrWaveRef(A)[pcsr(A)]
		wy[0] = TraceNametoWaveRef("", TraceName)[pcsr(A)]
	else
		wy[0] = CWave[pcsr(A)]
		wx[0] = XWaveRefFromTrace("", TraceName)[pcsr(A)]
	endif
	
	String TInfo = TraceInfo("", TraceName, 0)
	String XAxis = StrByKey("XAXIS",TInfo)
	String YAxis = StrByKey("YAXIS",TInfo)
//print TraceName, MarkWaveNameY, wy[0], wx[0], YAxis, XAxis
	AppendToGraph/L=$YAxis/B=$XAxis wy vs wx
	ModifyGraph mode($MarkWaveNameY)=3, marker($MarkWaveNameY)=8, msize($MarkWaveNameY)=gMPMarkerSize
	if (isX)
		ModifyGraph marker($MarkWaveNameY)=gMPXMarker
	else
		ModifyGraph marker($MarkWaveNameY)=gMPYMarker
	endif
end

Function RemoveMarks()

	String TraceNames=TraceNameList("", ";", 1)
	String ThisTrace
	String GName=WinName(0,1)

	
	Variable i=0
	do
		ThisTrace = StringFromList(i, TraceNames)
		if (strlen(ThisTrace) == 0)
			break
		endif
		if (cmpstr(ThisTrace[0,3], "Mark") == 0)
			Wave wx=XWaveRefFromTrace("", ThisTrace)
			Wave wy=TraceNameToWaveRef("", ThisTrace)
			RemoveFromGraph $ThisTrace
			KillWaves/z wx, wy
		endif
		i += 1
	while (1)
end

Function MarkCsrPntsBProc(ctrlName) : ButtonControl
	String ctrlName
	
	FindMarkedPoint()
End

Function RmveMarksBProc(ctrlName) : ButtonControl
	String ctrlName
	
	RemoveMarks()
end

Function RegressButProc(ctrlName) : ButtonControl
	String ctrlName

	String TraceNames=TraceNameList("", ";", 1)
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
	
	Variable/G V_FitOptions=4	// Suppress progress window
	//Variable/G K0, K1, V_Pr
	Variable/G V_FitError
	
	ControlInfo FitLinesCheck
	AutotraceOn = V_value
	print "AutotraceOn = ",AutotraceOn
	
	ControlInfo RobustFit
	if (V_value)
		DoRobust = 1
		Make/N=2/O Fcoef = {0,1}
		Wave coef=Fcoef
	endif
		
	Variable i=0, Instance=0
	do
		ThisTrace = StringFromList(i, TraceNames)
		if (strlen(ThisTrace) == 0)
			break
		endif
		if (cmpstr(ThisTrace[0,3], "Fit_") != 0)
			Wave w=TraceNameToWaveRef("", ThisTrace)
			Wave/Z wavex = XWaveRefFromTrace("", ThisTrace)
			if (WaveExists(wavex))
				XWave=GetWavesDataFolder(wavex, 4)
				YWave=GetWavesDataFolder(w, 4)
				if (AutotraceOn)
					NewWaveName = "Fit_"+num2istr(i)
					NewWaveName = UniqueName(NewWaveName, 1, 0)
					Duplicate/O w,$NewWaveName
					Wave fitWave = $NewWaveName
				endif
				V_FitOptions = 4
				CurveFit/Q line, w /X=$Xwave
				Wave coef=W_coef
				if (DoRobust)
					V_FitOptions += 2
					Wave rcoef=Fcoef
					rcoef=coef
					Duplicate/O coef, Eps
					Wave e=Eps
					e=1
					V_FitError=0
					Execute "FuncFit/Q LineFit,Fcoef, "+YWave+" /X="+Xwave +" /E=Eps"
					if (V_FitError %& 2)
						sprintf AMessage, "Singular Matrix while fitting %s vs %s; Continue?",YWave, XWave
						DoAlert 1, AMessage
						if (V_flag == 2)
							Abort "Aborting regression"
						else
							tagtext = "Singular Matrix"
						endif
					else
						sprintf tagtext,"\Z09a=%g\rb=%g", coef[0], coef[1]
					endif
					Wave coef=Fcoef
				else
					sprintf tagtext,"\Z09a=%g\rb=%g\rr=%g", coef[0], coef[1], V_Pr
				endif
				if (AutotraceOn)
					fitWave = coef[0]+coef[1]*wavex[p]
					TInfo = TraceInfo("", ThisTrace, 0)
					XAxis = StrByKey("XAXIS",TInfo)
					YAxis = StrByKey("YAXIS",TInfo)
					AppendToGraph/B=$XAxis/L=$YAxis fitWave vs $Xwave
				endif
				TagName = UniqueTagName("MPR_"+num2istr(i))
				Tag/N=$TagName/L=1/X=0/Y=0/B=1 $ThisTrace, 0, tagtext
			endif
		endif
		i += 1
	while (1)

End

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

Function RmveTagsButProc(ctrlName) : ButtonControl
	String ctrlName
	
	String TagList=AnnotationList("")
	String ThisOne
	Variable i=0
	do
		ThisOne=StringFromList(i, TagList)
		if (strlen(ThisOne) == 0)
			break
		endif
		if (cmpstr("MPR_", ThisOne[0,3]) == 0)
			Tag/K /N=$ThisOne
		endif
		i += 1
	while(1)
End

Function ChangeTracesProc(ctrlName) : ButtonControl
	String ctrlName
	
	NVAR gMPTraceMode=root:Packages:WMScatterPlotMatrixPackage:gMPTraceMode
	NVAR gMPLineSize=root:Packages:WMScatterPlotMatrixPackage:gMPLineSize
	NVAR gMPMainMarkerSize=root:Packages:WMScatterPlotMatrixPackage:gMPMainMarkerSize
	NVAR gMPMainMarker=root:Packages:WMScatterPlotMatrixPackage:gMPMainMarker
	NVAR gMPMarkerThick=root:Packages:WMScatterPlotMatrixPackage:gMPMarkerThick
	
	ModifyGraph mode=gMPTraceMode
	ModifyGraph marker=gMPMainMarker
	ModifyGraph msize=gMPMainMarkerSize
	ModifyGraph mrkThick=gMPMarkerThick
	ModifyGraph lsize=gMPLineSize
End

Function RemoveRegressTraces(ctrlName) : ButtonControl
	String ctrlName

	String TraceNames=TraceNameList("", ";", 1)
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
			RemoveFromGraph $ThisTrace
			KillWaves/Z w, wavex
		endif
		i += 1
	while (1)
End

Function/D LineFit(w, xx)
	Wave w
	Variable xx
	
	return w[0]+w[1]*xx
end


//*******************************
// Marker selection stuff
//*******************************

Static Constant DOUBLECLICKTIME = 30
Static Constant DOUBLECLICKSLOP = 5

Function MakeSPMMarkerKeyGraph()

	SPMMakeMarkerKeyWaves()
	DoWindow/K MarkerKeyGraph
	
	String MKY = "root:Packages:WMScatterPlotMatrixPackage:MarkerKeyY"
	String MKX = "root:Packages:WMScatterPlotMatrixPackage:MarkerKeyX"
	String MK = "root:Packages:WMScatterPlotMatrixPackage:MarkerKey"
	Variable/G root:Packages:WMScatterPlotMatrixPackage:OutlierMarker
	
	Display/K=1/W=(502,178,825,478) $MKY vs $MKX as "Marker Numbers"
	AppendToGraph $MKY vs $MKX
	DoWindow/C MarkerKeyGraph
	AutoPositionWindow/E/M=0 MarkerKeyGraph
	ModifyGraph margin(left)=20,margin(bottom)=40,margin(top)=20,margin(right)=20
	ModifyGraph mode=3
	ModifyGraph rgb=(0,0,0)
	ModifyGraph msize(MarkerKeyY)=5
	ModifyGraph zmrkNum(MarkerKeyY)={$MK}
	ModifyGraph textMarker(MarkerKeyY#1)={$MK,"default",0,0,5,0.00,-15.00}
	ModifyGraph noLabel=2
	ModifyGraph axThick=0
	SetWindow MarkerKeyGraph hook=SPMMarkerHook, hookEvents=1
EndMacro

Function SPMMakeMarkerKeyWaves()

	Make/O/N=45 root:Packages:WMScatterPlotMatrixPackage:MarkerKeyY
	Wave MKY=root:Packages:WMScatterPlotMatrixPackage:MarkerKeyY
	Make/O/N=45 root:Packages:WMScatterPlotMatrixPackage:MarkerKeyX
	Wave MKX=root:Packages:WMScatterPlotMatrixPackage:MarkerKeyX
	Make/O/N=45 root:Packages:WMScatterPlotMatrixPackage:MarkerKey= x
	MKY = -Floor(p/8)
	MKX = Mod(p, 8)
end

Function SPMMarkerHook(s)
	String s

	Variable returnVal= 0
	
	NVAR/Z mouseDownTime = root:Packages:WMScatterPlotMatrixPackage:mouseDownTime
	NVAR/Z sawDoubleClick = root:Packages:WMScatterPlotMatrixPackage:sawDoubleClick
	NVAR/Z mouseDownX = root:Packages:WMScatterPlotMatrixPackage:mouseDownX
	NVAR/Z mouseDownY = root:Packages:WMScatterPlotMatrixPackage:mouseDownY
	if (!NVAR_Exists(mouseDownTime) || !NVAR_Exists(mouseDownTime) || !NVAR_Exists(mouseDownX) || !NVAR_Exists(mouseDownY))
		Variable/G root:Packages:WMScatterPlotMatrixPackage:mouseDownTime = 0
		Variable/G root:Packages:WMScatterPlotMatrixPackage:sawDoubleClick = 0
		Variable/G root:Packages:WMScatterPlotMatrixPackage:mouseDownX = -10000
		Variable/G root:Packages:WMScatterPlotMatrixPackage:mouseDownY = -10000
		NVAR/Z mouseDownTime = root:Packages:WMScatterPlotMatrixPackage:mouseDownTime
		NVAR/Z sawDoubleClick = root:Packages:WMScatterPlotMatrixPackage:sawDoubleClick
		NVAR/Z mouseDownTime = root:Packages:WMScatterPlotMatrixPackage:mouseDownX
		NVAR/Z sawDoubleClick = root:Packages:WMScatterPlotMatrixPackage:mouseDownY
	endif
	
	Variable xpix,ypix
	Variable clickTime
	String msg
	String win=StringByKey("WINDOW",s)

	Variable isMouseUp= StrSearch(s,"EVENT:mouseup;",0) > 0
	Variable isMouseDown= StrSearch(s,"EVENT:mousedown;",0) > 0
	Variable isClick= isMouseUp + isMouseDown

	if( isClick )
		clickTime = NumberByKey("TICKS", s)
		xpix= NumberByKey("MOUSEX",s)
		ypix= NumberByKey("MOUSEY",s)
		if (isMouseDown)
			if ( ((clickTime - mouseDownTime) < DOUBLECLICKTIME) && (abs(xpix - mouseDownX) < DOUBLECLICKSLOP) && (abs(ypix - mouseDownY) < DOUBLECLICKSLOP)  )
				sawDoubleClick = 1
			else
				sawDoubleClick = 0
				mouseDownTime = clickTime
				mouseDownX = xpix
				mouseDownY = ypix
			endif
		else		// it's a mouseUp
			if (sawDoubleClick)
				if ( (abs(xpix - mouseDownX) < DOUBLECLICKSLOP) && (abs(ypix - mouseDownY) < DOUBLECLICKSLOP)  )
					// saw a double click, it's a mouse up and it's within the click slop- select the marker and done
					Variable xaxval= AxisValFromPixel(win,"bottom",xpix)
					Variable yaxval= AxisValFromPixel(win,"left",ypix)
					Variable marker= SPMMarkerFromXY(xaxval,yaxval)
					Variable/G root:Packages:WMScatterPlotMatrixPackage:gMPMainMarker = marker
					Execute/P "DoWindow/K MarkerKeyGraph"
				else
					// not within slop, start over
					mouseDownTime = 0
					mouseDownX = -10000
					mouseDownY = -10000
					sawDoubleClick = 0
				endif
			endif
		endif
		returnVal= 1
	endif
	return returnVal
end

Function SPMMarkerFromXY(xx,yy)
	Variable xx,yy

	Variable marker
	Variable row= round(-yy)
	row= limit(row,0,5)
	Variable col= round(xx)
	col= limit(col,0,7)
	marker= row*8+col
	marker= limit(marker,0,44)
	return marker
End


Function SPMSelectMarkerButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	MakeSPMMarkerKeyGraph()
End

