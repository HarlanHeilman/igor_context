#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma moduleName=WMRadarChart
#pragma version=9.02			// Shipped with Igor 9.02

#include <New Polar Graphs>
#include <colorSpaceConversions>
#include <Graph Utility Procs>
#include <Resize Controls>

// Radar and Spider Chart package
//
// 2/27/2023, JP: Initial Version shipped with Igor 9.02.
// 3/3/2023, JP: UpdateTableList no longer fails to set the helpWave when the NewRadarChartPanel is re-opened.
//				Fixed missing Resize Controls

Menu "New"
	"Radar Chart",/Q, ShowRadarChartPanel()
End

Menu "Graph", dynamic
	WMRadarSpiderTracesMenu(), /Q, RadarAppendRemoveSpiderTraces("")
	WMRadarSpiderTraceSizeStyleMenu(), /Q, ShowSpiderSettings()
End

Menu "Data", dynamic
	Submenu "Packages"
		RadarChartsCleanDFsMenuItem(), /Q, RadarChartCleanUnusedDFs()
	End
End

Function ShowRadarChartPanel()
	DoWindow/F NewRadarChartPanel
	if( V_flag == 0 )
		WMInitRadarCharts()
		CreateNewRadarChartPanel()
		UpdateTableList("NewRadarChartPanel")
	endif
End

Function CreateNewRadarChartPanel()
	DoWindow/K NewRadarChartPanel
	NewPanel /W=(119,141,647,508)/K=1/N=NewRadarChartPanel as "New Radar Chart"
	SetDrawLayer UserBack
	ListBox tableContent,pos={26.00,80.00},size={480.00,236.00}, proc=WMRadarChart#tableContentListProc
	ListBox tableContent,userdata(ResizeControlsInfo)=A"!!,C4!!#?Y!!#CU!!#B&z!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
	ListBox tableContent,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	ListBox tableContent,userdata(ResizeControlsInfo)+=A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"
	ListBox tableContent,listWave=root:Packages:WMRadarCharts:tableList
	ListBox tableContent,mode=6,special={1,0,1}
	Button doRadar,pos={159.00,335.00},size={215.00,20.00},proc=RadarChartFromTableButtonProc
	Button doRadar,title="Radar Chart with Selected Table Data"
	Button doRadar,userdata(ResizeControlsInfo)=A"!!,G/!!#BaJ,hr<!!#<Xz!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	Button doRadar,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	Button doRadar,userdata(ResizeControlsInfo)+=A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"
	GroupBox tablesGroup,pos={17.00,55.00},size={501.00,270.00}
	GroupBox tablesGroup,title="Select a table with Radar Data"
	GroupBox tablesGroup,userdata(ResizeControlsInfo)=A"!!,BA!!#>j!!#C_J,hrlz!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
	GroupBox tablesGroup,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	GroupBox tablesGroup,userdata(ResizeControlsInfo)+=A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"
	Slider columnsSlider,pos={295.00,7.00},size={183.00,56.00},proc=RadarTableColumnsSliderProc
	Slider columnsSlider,userdata(ResizeControlsInfo)=A"!!,HNJ,hjm!!#AF!!#>nz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	Slider columnsSlider,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	Slider columnsSlider,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
	Slider columnsSlider,fSize=12,limits={1,4,1},value=3,vert=0
	TitleBox numColumnsTitle,pos={233.00,38.00},size={48.00,15.00},title="Columns"
	TitleBox numColumnsTitle,userdata(ResizeControlsInfo)=A"!!,H$!!#>&!!#>N!!#<(z!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	TitleBox numColumnsTitle,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	TitleBox numColumnsTitle,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
	TitleBox numColumnsTitle,frame=0,anchor=LB
	Button help,pos={18.00,335.00},size={50.00,20.00},proc=RadarChartHelpButtonProc
	Button help,title="Help"
	Button help,userdata(ResizeControlsInfo)=A"!!,BI!!#BaJ,ho,!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	Button help,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	Button help,userdata(ResizeControlsInfo)+=A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"
	Button close,pos={464.00,335.00},size={50.00,20.00},proc=RadarChartPanelCloseButtonProc
	Button close,title="Close"
	Button close,userdata(ResizeControlsInfo)=A"!!,IN!!#BaJ,ho,!!#<Xz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	Button close,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	Button close,userdata(ResizeControlsInfo)+=A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"
	SetWindow kwTopWin,hook(ResizeControls)=ResizeControls#ResizeControlsHook
	SetWindow kwTopWin,hook(RadarChartPanelHook)=RadarChartPanelHook
	SetWindow kwTopWin,userdata(ResizeControlsInfo)=A"!!*'\"z!!#Ci!!#BqJ,fQLzzzzzzzzzzzzzzzzzzzz"
	SetWindow kwTopWin,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzzzzzzzzzzzzzzz"
	SetWindow kwTopWin,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzzzzzzzzz!!!"
	SetWindow kwTopWin sizeLimit={396,275.25,inf,inf}
End

static Function tableContentListProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	Variable row = lba.row
	Variable col = lba.col
	WAVE/T/Z wList = lba.listWave

	switch( lba.eventCode )
		case -1: // control being killed
			break
		case 3: // double click
			if( WaveExists(wList) )
				String tableName
				Variable nCols = DimSize(wList,1)
				if( nCols > 0 )
					tableName= wList[row][col]
				else
					tableName= wList[row]
				endif
				if( strlen(tableName) != 0 )
					DoWindow/F $tableName
				endif
			endif
			break
		case 4: // cell selection
		case 5: // cell selection plus shift key
			//UpdateSelectedTableInfo(lba.win,lba.listWave[row][col],0)
			break
		case 6: // begin edit
			break
		case 7: // finish edit
			break
	endswitch

	return 0
End

// hook on the panel
Function RadarChartPanelHook(s)
	STRUCT WMWinHookStruct &s

	Variable hookResult = 0

	strswitch(s.eventName)
		case "activate":
			UpdateTableList(s.winName)
			break
		case "kill":
			Execute/P/Q/Z "WMPossiblyKillRadarChartData(\"\", \"\")"	// once the panel has gone away 
			break
	endswitch

	return hookResult		// 0 if nothing done, else 1
End

Function UpdateTableList(String pname)
	ControlInfo/W=$pname columnsSlider
	Variable ncols = V_Value
	FillTableList(pname,ncols)
End

Function/WAVE CreateTableList(ncols)
	Variable ncols

	Make/T/O/N=0/FREE tableListNew
	
	// make a list of table names
	// list only tables with exactly 1 text wave and one or more numeric waves
	String tableList= WinList("*",";","WIN:2;")
	Variable nTables = ItemsInList(tableList)
	Variable i, numRows=0
	for(i=0; i<nTables; i+=1)
		String tableName= StringFromList(i,tableList)
		
		String textWavePath
		String listOfNumericWaves
		[textWavePath, listOfNumericWaves] = AnalyzeTable(tableName)
		if( strlen(textWavePath) == 0)
			continue	// need one text wave
		endif
		if( strlen(listOfNumericWaves) == 0)
			continue	// need one numeric wave
		endif
		tableListNew[numRows]={tableName}
		numRows += 1
	endfor
	Sort/A tableListNew,tableListNew
	if( ncols>1 )
		numRows= ceil(numRows/ncols)
		Redimension/N=(numRows,ncols)/E=1 tableListNew
	endif
	return tableListNew
End

Function/S HelpForTable(String tableName)
	String help=""
	if( strlen(tableName) )
		// the table has been vetted, so less testing needed
		String textWavePath
		String listOfNumericWaves
		[textWavePath, listOfNumericWaves] = AnalyzeTable(tableName)
		WAVE/T categoryWave= $textWavePath
		help = "categories: "+NameOfWave(categoryWave)+"\rdata: "

		Variable i,numWaves= ItemsInList(listOfNumericWaves)
		for(i=0;i<numWaves;i+=1)
			String path = StringFromList(i,listOfNumericWaves)
			WAVE/Z w = $path
			help += NameOfWave(w)+", "
		endfor
		help = RemoveEnding(help,", ")
	endif
	return help
End

Function/WAVE CreateTableHelpList(WAVE/T tableList)

	Duplicate/O/T/FREE=1 tableList, wHelpList
	wHelpList = HelpForTable(tableList)
	
	return wHelpList
End
	

Function WMInitRadarCharts()
	String cdf= GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:WMRadarCharts
	WAVE/Z/T list = root:Packages:WMRadarCharts:tableList
	if( !WaveExists(list) )
		Make/O/T/N=0 root:Packages:WMRadarCharts:tableList // just to keep ListBox from complaining
	endif
End

Function FillTableList(pname, ncols)
	String pname		// panel name
	Variable ncols
	
	WMInitRadarCharts()

	WAVE/T tableListNew = CreateTableList(ncols)

	// see if the list is different than what the listbox is currently using
	ControlInfo/W=$pname tableContent
	String pathToListWave = S_DataFolder + S_Value
	WAVE/T/Z currentListWave = $pathToListWave
	if( !WaveExists(currentListWave)  || !EqualWaves(tableListNew,currentListWave,1) )
		Duplicate/O/T tableListNew, root:Packages:WMRadarCharts:tableList
		ListBox tableContent,win=$pname,listWave=root:Packages:WMRadarCharts:tableList
		ListBox tableContent,win=$pname,selWave=$""
		ListBox tableContent,win=$pname,mode=6,special={1,0,1}
		// Make a help list, too
		WAVE/T/Z wHelp = CreateTableHelpList(tableListNew)
		if( WaveExists(wHelp) )
			Duplicate/O/T wHelp, root:Packages:WMRadarCharts:tableListHelp
		endif
	endif
	WAVE/T/Z wHelp = root:Packages:WMRadarCharts:tableListHelp
	if( WaveExists(wHelp) )
		ListBox tableContent,win=$pname,helpWave=root:Packages:WMRadarCharts:tableListHelp
	endif
End

Function [String firstTextWavePath, String listOfNumericWaves] AnalyzeTable(String tableName)
	firstTextWavePath=""
	listOfNumericWaves=""
	Variable type = WinType(tableName)
	if( type == 2 ) // table window
		Variable index= 0
		Variable rows= NaN
		Variable sameNumberOfRows= NaN
		do
			WAVE/Z w = WaveRefIndexed(tableName, index, 1)
			if( !WaveExists(w) )
				break
			endif
			// For table windows, type  is 1 for data columns, 2 for index or dimension label columns, 3 for either data or index or dimension label columns.
			type = WaveType(w,1)
			String path = GetWavesDataFolder(w,2)
			if( type == 1 ) // numeric
				listOfNumericWaves += path+";"
			elseif( type == 2 ) // text
				if( strlen(firstTextWavePath) == 0 )
					firstTextWavePath = path
				endif
			endif
			if( type == 1 || type == 2 )
				if( numtype(rows) == 2 )
					rows = DimSize(w,0)
				else
					// enforce same number of rows
					if( DimSize(w,0) != rows )
						return ["",""]
					endif
				endif
				// enforce 1-D (0 or 1 columns)
				if( DimSize(w,1) > 1 )
					return ["",""]
				endif
			endif
			index += 1
		while(1) // exit via break
	endif
End

Function RadarTableColumnsSliderProc(sa) : SliderControl
	STRUCT WMSliderAction &sa

	switch( sa.eventCode )
		case -3: // Control received keyboard focus
		case -2: // Control lost keyboard focus
		case -1: // Control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				Variable curval = sa.curval
				FillTableList("NewRadarChartPanel",curval)
			endif
			break
	endswitch

	return 0
End

Function RadarChartHelpButtonProc(ctrlName) : ButtonControl
	String ctrlName
	DisplayHelpTopic "The Radar Chart Panel"
End


Function RadarChartPanelCloseButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			Execute/P/Q/Z "DoWindow/K "+ba.win
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function RadarChartFromTableButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			ControlInfo/W=$ba.win tableContent
			Variable row = V_Value // Currently selected row (valid for mode 1 or 2 or modes 5 and 6 when no selWave is used). If no list row is selected, then it is set to -1.
			Variable col = V_selCol //Currently selected column (valid for modes 5 and 6 when no selWave is used).
			String tableName=""
			String pathToListWave = S_DataFolder + S_Value
			WAVE/T/Z wList = $pathToListWave
			if( WaveExists(wList) )
				Variable nCols = DimSize(wList,1)
				if( nCols > 0 )
					tableName= wList[row][col]
				else
					tableName= wList[row]
				endif
			endif
			if( strlen(tableName) )
				RadarChartFromTableData(tableName)
			else
				Beep
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Static Function/S RadarChartsDF()
	return "root:Packages:WMRadarCharts:" // note the trailing ":"
End

Static Function/S RadarChartsDFVar(String varName)
	return RadarChartsDF()+PossiblyQuoteName(varName)
End


// creates datafolder hierarchy, changes the current data folder to it, and returns the data folder path.
static Function/S SetNewRadarChartDF(String polarGraphName, String table)

	String workDF= RadarChartsDFVar(polarGraphName)+":" // parallel to, but not the same df as Polar Graphs package uses.
	
	// Ensure each level of the data folders exists, and set current DF to the leaf.
	Variable i, n= itemsInList(workDF,":")
	SetDataFolder root:	// start here
	for( i=1; i<n; i+=1 )	// continue with second level, should be "Packages"
		String dfName= StringFromList(i, workDF, ":")
		NewDataFolder/O/S $dfName
	endfor
	// Radar Chart will put its own data into its own data folder parallel to the polar graph package:
	// root:Packages:WMRadarCharts:PolarGraph0
	// root:Packages:WMPolarGraphs:PolarGraph0
	String/G tableName = table	// root:Packages:WMRadarCharts:PolarGraph0:tableName
	
	return workDF // now the current DF, with terminating ":"
End


// Additional polar graph hook (hook on the graph)
Function WMRadarChartHook(hs)
	STRUCT WMWinHookStruct &hs
	
	Variable ret=0
	strswitch(hs.eventName)
		case "kill":
			String workDF = GetUserData(hs.winName, "", "WMRadarChart")
			Execute/P/Q/Z "WMPossiblyKillRadarChartData(\"" + hs.winName + "\", \"" + workDF + "\")"	// once the window has gone away 
			break
	endswitch
	return ret
End

Function WMPossiblyKillRadarChartData(win, dfpath)
	String win, dfpath

	if( strlen(win) )
		if( exists(win) != 5 )
			// no recreation macro exists, it's okay to kill the data folder.
			if( strlen(dfpath) )
				KillDataFolder/Z dfpath	// also kills any dependency
			endif
		endif
	endif
	DoWindow NewRadarChartPanel
	if( V_Flag == 0 ) // if the New Radar Chart panel is closed...
		// ...and if no radar charts exist, kill the entire Packages:WMRadarChart data folder.
		String dfName = GetIndexedObjName("root:Packages:WMRadarChart", 4, 0)
		if (strlen(dfName) == 0)
			// no more radar charts!
			KillDataFolder/Z root:Packages:WMRadarChart
		endif
	endif
End

Function RadarChartFromTableData(String tableName)

	// Start a Polar Graph, which creates a WMPolarGraphs data folder and an empty polar graph
	String oldDF = GetDataFolder(1) // in case polar graphs package doesn't restore DF
	WMPolarGraphGlobalsInit()
	String graphName= WMNewPolarGraph("_default_", "")
	
	// Derived data for the radar chart is created in a data folder within root:Packages:WMRadarCharts
	String workDF = SetNewRadarChartDF(graphName,tableName) // current path
	
	String textWavePath
	String listOfNumericWaves // radii waves
	[textWavePath, listOfNumericWaves] = AnalyzeTable(tableName)

	WAVE/T categories = $textWavePath
	
	// Set a useful initial graph title
	DoWindow/T $graphName, NameOfWave(categories)+" Radar/Spider Chart"
	
	String/G categoriesWavePath = textWavePath
	
	// we need a set of angles corresponding to the categories that COMPLETE a full circle.
	Variable numCategories = DimSize(categories,0) // we expect this to the same # of rows as the input radii waves

	Variable majorAngleInc = 360 / numCategories
	
	Variable numAngles = numCategories+1 // to close the path
	
	Make/O/N=(numAngles)/FREE categoryAngles = p * majorAngleInc
	// for 4 categories we get 5 angles: 0, 90, 180, 270, 360
	
	// make augmented radii waves from the numeric waves to close each trace
	Variable numRadii= ItemsInList(listOfNumericWaves)
	Variable i
	String listOfClosedWaves=""
	for(i=0; i<numRadii; i+=1 )
		WAVE wRadii = $StringFromList(i,listOfNumericWaves)
		String closedWaveName= NameOfWave(wRadii)+"_closed"
		Duplicate/O wRadii, $closedWaveName // in workDF
		WAVE closed = $closedWaveName
		Variable numRows = DimSize(wRadii,0) // we expect this to the same # of rows as all the other input waves
		closed[numRows] = {wRadii[0]} // wrap the end around to the start
		SetScale/P x, 0, majorAngleInc, "deg", closed
		listOfClosedWaves += GetWavesDataFolder(closed,2)+";"
	endfor
	
	String/G listOfAugmentedWaves = listOfClosedWaves
	
	// TO DO: Make dependencies on the input waves to update these augmented "closed" waves.

	// Now we have the data needed to make a radar chart

	// we make some default choices here that the user can change with the normal Polar Graph panel
	WMPolarGraphSetVar(graphName,"zeroAngleWhere",90)// 0 = right, 90 = top, 180 = left, -90 = bottom
	WMPolarGraphSetVar(graphName,"angleDirection", 1)	// 1 == clockwise, -1 == counter-clockwise"
	
	// Append polar traces and make a legend
	String legendText="" // 	Legend/C/N=text0/J/X=1.01/Y=1.91 "\\s(polarY0) Product_A\r\\s(polarY1) Product_A"

	for(i=0; i<numRadii; i+=1 )
		WAVE wRadii = $StringFromList(i,listOfClosedWaves)
		SetDataFolder workDF	// just in case the the polar graph stuff isn't preserving the current data folder.
		String polarTraceName= WMPolarAppendTrace(graphName, wRadii, $"", 360)
		Variable red, green, blue
		WM_GetDistinctColor(i,numRadii,red,green,blue,1)
		//if(fill)
		//	SetPolarFillToOrigin(graphName,polarTraceName,red,green,blue)
		//endif
		ModifyGraph/W=$graphName rgb($polarTraceName)=(red,green,blue)
		WAVE wRadii = $StringFromList(i,listOfNumericWaves)
		legendText += "\\s("+polarTraceName+") " + NameOfWave(wRadii)
		if( i != numRadii-1 )
			legendText += "\r"
		endif		
	endfor
	
	Textbox/C/N=radarLegend/X=1.01/Y=1.91/W=$graphName legendText
	
	// set the radii angles to the values in categoryAngles
	WMPolarGraphSetStr(graphName,"doMajorAngleTicks","manual")
	WMPolarGraphSetVar(graphName,"majorAngleInc", majorAngleInc)

	// 0 angle at the right:
	WMPolarGraphSetVar(graphName,"zeroAngleWhere",0)

	// CCW
	WMPolarGraphSetVar(graphName,"angleDirection",-1)	// 1 == clockwise, -1 == counter-clockwise

	// Set the angle labels function
	
	//root:Packages:WMPolarGraphs:PolarGraph0:angleTickLabelNotation
	WMPolarGraphSetStr(graphName,"angleTickLabelNotation","RadarCategory(\""+graphName+"\",%g)")
	
	// turn off minor angle ticks
	WMPolarGraphSetVar(graphName,"doMinorAngleTicks",0)
	
	// pre-populate radius axes at listed angles...
	WMPolarGraphSetStr(graphName,"radiusAxesWhere","At Listed Angles")
	String radiusAxesAngleList
	wfprintf radiusAxesAngleList, "%g, "/R=(0, numCategories-1) categoryAngles
	WMPolarGraphSetStr(graphName,"radiusAxesAngleList",radiusAxesAngleList)

	// ... but start with radius axes at 0
	WMPolarGraphSetStr(graphName,"radiusAxesWhere","  0")
	
	// don't label radius=0
	WMPolarGraphSetVar(graphName,"radiusTickLabelOmitOrigin",1)
	
	// major grid lines
	// color
	String prefix= "majorGridColor"
	WMPolarGraphSetVar(graphName,prefix+"Red",32768)
	WMPolarGraphSetVar(graphName,prefix+"Green",40777)
	WMPolarGraphSetVar(graphName,prefix+"Blue",65535)
	WMPolarGraphSetVar(graphName,prefix+"Alpha",65535)
	// style
	WMPolarGraphSetVar(graphName,"majorGridStyle",1) // dashed

	//Angle Axes thickness
	WMPolarGraphSetVar(graphName,"angleAxisThick",0.25)
	// color 
	prefix= "angleAxisColor"
	WMPolarGraphSetVar(graphName,prefix+"Red",32768)
	WMPolarGraphSetVar(graphName,prefix+"Green",40777)
	WMPolarGraphSetVar(graphName,prefix+"Blue",65535)
	WMPolarGraphSetVar(graphName,prefix+"Alpha",65535)	
	
	SetDataFolder workDF	// just in case the the polar graph stuff isn't preserving the current data folder.
	String/G radarChartGraphName= graphName	// for future use.

	// Add a hook function to the polar graph to delete the Radar Chart data folder when the graph dies.
	SetWindow $graphName hook(WMRadarChart)= WMRadarChartHook
	SetWindow $graphName userData(WMRadarChart)= workDF
	
	WMPolarAxesRedrawTopGraphNow()
	// this updates the graph and autoscales the radius axes.
	
	Variable wantSpider = 0
	if( wantSpider )
		RadarAppendRemoveSpiderTraces(graphName)
	else
		SetDataFolder workDF	// just in case the the polar graph stuff isn't preserving the current data folder.
		Variable/G haveSpiderWeb = 0
	endif

	// Cue the user that changes can be made with the Polar Graphs panel.
	WMPolarGraphs(-1)
	
	SetDataFolder oldDF
	return 1	// success
End

// returns "" if not radar chart, else path to working data folder for the radar chart
static Function/S IsRadarChart(String graphName)

	if( strlen(graphName) )
		String workDF = GetUserData(graphName, "", "WMRadarChart")
		if( DataFolderExists(workDF) )
			return workDF
		endif
	endif
	return ""
End


/////////// Print category as angle axis label


// root:Packages:WMPolarGraphs:PolarGraph0:angleTickLabelNotation = RadarCategory(graphName,%g)
Function/S RadarCategory(String graphName, Variable angle) // presumed to be degrees, we *could* ask the polar graph.

	String workDF = GetUserData(graphName, "", "WMRadarChart")
	String strPath = workDF+"categoriesWavePath"
	String textWavePath= StrVarOrDefault(strPath,"")
	WAVE/T/Z categories = $textWavePath
	if( !WaveExists(categories) )
		return "_no_category_wave_"
	endif
	
	if( angle > 360 )
		Debugger
	endif
	
	Variable numCategories = DimSize(categories,0) // we expect this to the same # of rows as the input radii waves
	if( numCategories < 1 )
		return "_no_categories_"
	endif
	Variable majorAngleInc = 360 / numCategories

	Variable catNum = round(angle / majorAngleInc)
	catNum = mod(catNum, numCategories)

	String category= categories[catNum]
	return category
End

/////////// Clean Radar Chart Data Folders

Function WMPolarMoveTraceToBottom(graphName,traceName)
	String graphName,traceName

	WAVE/Z wShadowY=TraceNameToWaveRef(graphName,traceName)	// may fail if the trace was already removed from the graph
	if( WaveExists(wShadowY) )
		ReorderTraces/W=$graphName _back_, {$traceName}

		WAVE/Z/T tw= $WMPolarGraphTracesTW(graphName)
		if( WaveExists(tw) )
			WAVE/Z wShadowY= $GetWavesDataFolder(tw,1)+traceName // should be the same
			Variable row= WMPolarShadowWaveRow(wShadowY)
			if( row != -1 && row != 0 )		// this wave was found in polarTracesTW and isn't already at tw[0]
				// move the row to tw[0][]
				InsertPoints/M=0 0,1,tw		// create a new row to that we'll copy to
				Variable sourceRow = row+1	// account for inserted row
				tw[0][] = tw[sourceRow][q]	// copy data
				DeletePoints/M=0 sourceRow,1,tw	// avoid two identical rows
			endif
		endif
	endif

	//  update the popup menu 
	DoWindow WMPolarGraphPanel
	if( V_Flag )
		String polarTraces=WMPolarTraceNameList(1)
		ControlInfo/W=WMPolarGraphPanel mainModifyTracePop
		String currentPopStr = S_Value
		PopupMenu mainModifyTracePop win= WMPolarGraphPanel, popMatch=currentPopStr
	endif
End


Function/S RadarChartsCleanDFsMenuItem()

	String menuItem= "Delete Unused Radar Chart Data Folders"
	if( ItemsInList(UnusedRadarChartDFs()) == 0 )
		menuItem= ""	// disappears
	endif
	return menuItem
End

static Function/S RadarChartSubfolders()

	String df, list=""
	Variable i=0
	do
		df= GetIndexedObjName(RadarChartsDF(),4,i )
		if( strlen(df) == 0 )
			break
		endif
		list += df + ";"
		i += 1
	while(1)
	return list
End

static Function/S UnusedRadarChartDFs()
	String unusedDFs=""

	String allDFs = RadarChartSubfolders()
	Variable i, n= ItemsInList(allDFs)
	for( i=0; i<n; i+=1 )
		String dfName= StringFromList(i,allDFs)
		String df= RadarChartsDFVar(dfName)+":"
		String graphName= StrVarOrDefault(df+"radarChartGraphName","")
		Variable inUse = strlen(graphName) && (WinType(graphName) == 1 || exists("ProcGlobal#"+graphName))
		if( !inUse )
			unusedDFs += dfName+";"
		endif
	endfor

	return unusedDFs
End

// Call RadarChartCleanUnusedDFs() if there are data folders in root:Packages:WMRadarCharts:* that you think are unnecessary
Function RadarChartCleanUnusedDFs()

	String dfList= UnusedRadarChartDFs()
	Variable i, n= ItemsInList(dfList)
	for( i=0; i<n; i+=1 )
		String dfName= StringFromList(i,dfList)
		String df= RadarChartsDFVar(dfName)+":"
		KillDataFolder/Z $df
		// printing added for version 9.02
		if( DatafolderExists(df) )
			Print "Not removed (in use) "+df // something other than radar charts is using the data folder.
		else
			Print "Removed "+df
		endif
	endfor
End

/////////// Spider Plot code

// Note: A Radar Chart graph can optionally present as a spider plot (has web traces).


Static Function IsSpiderPlot(String graphName)
	Variable isSpiderPlot = 0
	
	if( strlen(graphName) )
		String workDF = IsRadarChart(graphName)
		if( strlen(workDF) )
			isSpiderPlot = NumVarOrDefault(workDF+"haveSpiderWeb",0)
		endif
	endif
	return isSpiderPlot
End

Function/S TopSpiderPlot()
	String graphName= WinName(0,1,1) // top visible graph
	if( strlen(graphName) )
		if( IsSpiderPlot(graphName) )
			return graphName
		endif
	endif
	return ""
End

Function/S WMRadarSpiderTracesMenu()
	String item="" // disappearing menu
	String graphName= WinName(0,1,1) // top visible graph
	if( strlen(graphName) )
		String workDF = IsRadarChart(graphName)
		if( strlen(workDF) )
			Variable haveSpiderWeb = IsSpiderPlot(graphName)
			if( haveSpiderWeb )
				item= "Remove Spider Web"
			else
				item= "Add Spider Web"
			endif
		endif
	endif
	return item
End

// returns truth the graph is now displaying as a spider plot
Function RadarAppendSpiderTraces(String graphName)

	if( strlen(graphName) == 0 )
		graphName= WMPolarTopPolarGraph()
	endif
	String workDF = IsRadarChart(graphName)
	if( strlen(workDF) == 0 )
		Beep
		return 0
	endif

	Variable haveWeb = NumVarOrDefault(workDF+"haveSpiderWeb",0) // alternatively, we could look for any spider trace
	if( haveWeb )
		return 1
	endif
	
	// Create and append spider web-like "strand" traces that traverse the full circle at each major radius.
	// and "spokes" from the dataInnerRadius to the data outerRadius.
	
	String oldDF = GetDataFolder(1)
	SetDataFolder workDF
	
	SVAR categoriesWavePath // textWavePath 
	WAVE categories = $categoriesWavePath
	Variable numCategories = DimSize(categories,0)

	Variable dataInnerRadius = WMPolarGraphGetVar(graphName,"dataInnerRadius") // if this isn't zero, we may have trouble
	Variable dataMajorRadiusInc = WMPolarGraphGetVar(graphName,"dataMajorRadiusInc")
	Variable dataOuterRadius = WMPolarGraphGetVar(graphName,"dataOuterRadius")

	Variable majorAngleInc = 360 / numCategories
	Variable numAngles = numCategories+1 // to close the path
	
	// for 4 categories we get 5 angles: 0, 90, 180, 270, 360
	// create one web "strand" for each major radius tick, but not at radius = 0
	// We want to append the strings from large radius to small so that
	// if we want to fill-to-zero each strand can have its own color.
	// This will reverse the polar trace names, though.
	
	String polarTraceName
	String/G listOfSpiderWebTraces=""

	// apply the default or the last values used for this particular radar chart's spider traces
	Variable lSize = NumVarOrDefault(workDF+"lastSpider_lSize",1) 
	Variable lStyle = NumVarOrDefault(workDF+"lastSpider_style",1) // dashed
	Variable red= NumVarOrDefault(workDF+"lastSpider_red",10000)
	Variable green= NumVarOrDefault(workDF+"lastSpider_green",10000)
	Variable blue= NumVarOrDefault(workDF+"lastSpider_blue",10000)
	Variable alpha= NumVarOrDefault(workDF+"lastSpider_alpha",65535)

	// Add "spokes", as one radius/angle pair
	Make/O/N=(numCategories*3) spokesRadii = mod(p,3) == 0 ? dataInnerRadius : (mod(p,3) == 1 ? dataOuterRadius : NaN)
	Make/O/N=(numCategories*3) spokesAngles = trunc(p/3) * majorAngleInc

	polarTraceName= WMPolarAppendTrace(graphName, spokesRadii, spokesAngles, 360)
	ModifyGraph/W=$graphName rgb($polarTraceName)=(red,green,blue,alpha), lStyle($polarTraceName)=lStyle, lSize($polarTraceName)=lSize
	ModifyGraph/W=$graphName userData($polarTraceName)={WMRadarChart,0,"isSpiderTrace"}
	WMPolarMoveTraceToBottom(graphName,polarTraceName) // Spokes will be drawn above strands
	listOfSpiderWebTraces += polarTraceName+";"

	// Add "strands", one for each major radius increment
	String strandName
	Variable range = dataOuterRadius - dataInnerRadius
	Variable numStrands = floor(range/dataMajorRadiusInc)
	Variable radius = dataInnerRadius ? dataInnerRadius : dataMajorRadiusInc
	Variable index= 0
	
	for( ; radius <= dataOuterRadius; radius += dataMajorRadiusInc, index += 1 )
		strandName = "strand"+num2str(index)
		Make/O/N=(numAngles) $strandName/WAVE=strand
		strand = radius
		SetScale/P x, 0, majorAngleInc, "deg", strand
		String path = GetWavesDataFolder(strand,2)
		
		polarTraceName= WMPolarAppendTrace(graphName, strand, $"", 360)
		ModifyGraph/W=$graphName rgb($polarTraceName)=(red,green,blue,alpha), lStyle($polarTraceName)=lStyle, lSize($polarTraceName)=lSize
		ModifyGraph/W=$graphName userData($polarTraceName)={WMRadarChart,0,"isSpiderTrace"}
		listOfSpiderWebTraces += polarTraceName+";"
		WMPolarMoveTraceToBottom(graphName,polarTraceName)// keep strands below "normal" polar traces because they a like a grid
	endfor
	
	// Turn off radar (circular) grid
	WMPolarGraphSetVar(graphName,"doPolarGrids",0)
	// and other stuff, too
	WMPolarGraphSetVar(graphName,"angleAxisThick",0)
	WMPolarGraphSetVar(graphName,"majorTickThick",0)
	WMPolarGraphSetVar(graphName,"radiusAxisThick",0)

	SetDataFolder workDF
	Variable/G haveSpiderWeb = 1
	
	WMPolarAxesRedrawTopGraphNow()
	SetDataFolder oldDF

End

// returns truth the graph is now displaying as a radar plot
Function RadarRemoveSpiderTraces(String graphName)

	if( strlen(graphName) == 0 )
		graphName= WMPolarTopPolarGraph()
	endif
	String workDF = IsRadarChart(graphName)
	if( strlen(workDF) == 0 )
		Beep
		return 0
	endif

	Variable haveWeb = NumVarOrDefault(workDF+"haveSpiderWeb",0) // alternatively, we could look for any spider trace
	if( !haveWeb )
		return 1 // radar chart already
	endif
	
	// Remove spider web traces
	String oldDF = GetDataFolder(1)
	SetDataFolder workDF

	// but first, save a few trace settings we care to preserve in case
	// the user clicks remove/add web
	Variable/G lastSpider_lSize= GetSpiderTracesSize(graphName)

	Variable/G lastSpider_style= GetSpiderTracesStyle(graphName)
	
	Variable red, green, blue, alpha
	[red, green, blue, alpha] = GetSpiderTracesRGB(graphName)

	Variable/G lastSpider_red = red
	Variable/G lastSpider_green = green
	Variable/G lastSpider_blue = blue
	Variable/G lastSpider_alpha = alpha

	String tracesList = StrVarOrDefault(workDF+"listOfSpiderWebTraces","")
	Variable i, n=ItemsInList(tracesList)
	for(i=0;i<n;i+=1)
		String traceName= StringFromList(i,tracesList)
		Variable removeTrace = IsSpiderTrace(graphname, traceName)
		if( removeTrace )
			Wave strand = TraceNameToWaveRef(graphName,traceName) // Note: could be the "spoke" trace
			WMPolarRemoveTrace(graphName,traceName)
			KillWaves/Z strand
		endif
	endfor
	SetDataFolder workDF
	String/G listOfSpiderWebTraces=""
	Variable/G haveSpiderWeb = 0
	
	// Turn on radar (circular) grid
	WMPolarGraphSetVar(graphName,"doPolarGrids",1)
	// and other stuff, too
	WMPolarGraphSetVar(graphName,"angleAxisThick",0.25)
	WMPolarGraphSetVar(graphName,"majorTickThick",1)
	WMPolarGraphSetVar(graphName,"radiusAxisThick",1)

	WMPolarAxesRedrawTopGraphNow()
	SetDataFolder oldDF
End


Function RadarAppendRemoveSpiderTraces(String graphName)

	if( strlen(graphName) == 0 )
		graphName= WMPolarTopPolarGraph()
	endif
	String workDF = IsRadarChart(graphName)
	if( strlen(workDF) == 0 )
		Beep
		return 0
	endif

	Variable haveWeb = NumVarOrDefault(workDF+"haveSpiderWeb",0)
	if( haveWeb )
		RadarRemoveSpiderTraces(graphName)
	else
		RadarAppendSpiderTraces(graphName)
	endif
End

/////////// Spider Settings Panel


Function/S WMRadarSpiderTraceSizeStyleMenu()
	String item="" // disappearing menu
	String graphName= WinName(0,1,1) // top visible graph
	Variable haveSpiderWeb = IsSpiderPlot(graphName)
	if( haveSpiderWeb )
		item= "Modify Spider Web Lines"
	endif
	return item
End

Static Function IsSpiderTrace(String graphName, String traceName)
	String userData = GetUserData(graphname, traceName, "WMRadarChart")
	Variable isSpiderTrace = CmpStr(userData,"isSpiderTrace") == 0
	return isSpiderTrace
End

Function GetSpiderTracesSize(String graphName)
	Variable haveSpiderWeb = IsSpiderPlot(graphName)
	if( haveSpiderWeb )
		Variable options = 0x1 // normal visible and hidden traces
		String list = TraceNameList(graphName,";",options)
		Variable i, n= ItemsInList(list)
		for(i=0; i<n; i+=1)
			String traceName= StringFromList(i,list)
			if( IsSpiderTrace(graphName, traceName) )
				String info = TraceInfo(graphName, traceName,0)
				Variable lSize = str2num(WMGetRECREATIONInfoByKey("lSize(x)", info))
				return lSize
			endif
		endfor
	endif
	return 1 // default
End

Function SetSpiderTracesSize(String graphName,Variable size)

	if( strlen(graphName) == 0 )
		graphName= WinName(0,1,1) // top visible graph
	endif
	Variable haveSpiderWeb = IsSpiderPlot(graphName)
	if( haveSpiderWeb )
		Variable options = 0x1 // normal visible and hidden traces
		String list = TraceNameList(graphName,";",options)
		Variable i, n= ItemsInList(list)
		for(i=0; i<n; i+=1)
			String traceName= StringFromList(i,list)
			if( IsSpiderTrace(graphName, traceName) )
				ModifyGraph/W=$graphName lSize($traceName)=size
			endif
		endfor
	endif
End

Function GetSpiderTracesStyle(String graphName)
	Variable haveSpiderWeb = IsSpiderPlot(graphName)
	if( haveSpiderWeb )
		Variable options = 0x1 // normal visible and hidden traces
		String list = TraceNameList(graphName,";",options)
		Variable i, n= ItemsInList(list)
		for(i=0; i<n; i+=1)
			String traceName= StringFromList(i,list)
			if( IsSpiderTrace(graphName, traceName) )
				String info = TraceInfo(graphName, traceName,0)
				// Variable lStyle= GetNumFromModifyStr(info,"lStyle","",0) // case SENSITIVE(!)
				Variable lStyle = str2num(WMGetRECREATIONInfoByKey("lStyle(x)", info))
				return lStyle
			endif
		endfor
	endif
	return 0 // default
End

Function SetSpiderTracesStyle(String graphName,Variable style)

	if( strlen(graphName) == 0 )
		graphName= WinName(0,1,1) // top visible graph
	endif
	Variable haveSpiderWeb = IsSpiderPlot(graphName)
	if( haveSpiderWeb )
		Variable options = 0x1 // normal visible and hidden traces
		String list = TraceNameList(graphName,";",options)
		Variable i, n= ItemsInList(list)
		for(i=0; i<n; i+=1)
			String traceName= StringFromList(i,list)
			if( IsSpiderTrace(graphName, traceName) )
				ModifyGraph/W=$graphName lStyle($traceName)=style
			endif
		endfor
	endif
End

Function [Variable red, Variable green, Variable blue, Variable alpha] GetSpiderTracesRGB(String graphName)
	
	red= 65535;green=65535;blue=65535;alpha=65535
	Variable haveSpiderWeb = IsSpiderPlot(graphName)
	if( haveSpiderWeb )
		Variable options = 0x1 // normal visible and hidden traces
		String list = TraceNameList(graphName,";",options)
		Variable i, n= ItemsInList(list)
		for(i=0; i<n; i+=1)
			String traceName= StringFromList(i,list)
			if( IsSpiderTrace(graphName, traceName) )
				String info = TraceInfo(graphName, traceName,0)
				String rgbtext= WMGetRECREATIONInfoByKey("rgb(x)", info)	//  "(r,g,b)" or "(r,b,g,a)"
				sscanf rgbtext, "(%d,%d,%d,%d)", red, green, blue, alpha
				if( V_Flag != 4 )
					alpha = 65535
					sscanf rgbtext, "(%d,%d,%d)", red, green, blue
				endif
			endif
		endfor
	endif
End

Function SetSpiderTracesRGB(String graphName,Variable red, Variable green, Variable blue, Variable alpha)

	if( strlen(graphName) == 0 )
		graphName= WinName(0,1,1) // top visible graph
	endif
	Variable haveSpiderWeb = IsSpiderPlot(graphName)
	if( haveSpiderWeb )
		Variable options = 0x1 // normal visible and hidden traces
		String list = TraceNameList(graphName,";",options)
		Variable i, n= ItemsInList(list)
		for(i=0; i<n; i+=1)
			String traceName= StringFromList(i,list)
			if( IsSpiderTrace(graphName, traceName) )
				ModifyGraph/W=$graphName rgb($traceName)=(red,green,blue,alpha)
			endif
		endfor
	endif
End

Function UpdateSpiderControls(String graphName)

	Variable disable = 0 // show and enabled
	
	if( strlen(graphName) == 0 )
		graphName= WMPolarTopPolarGraph()
	endif
	
	String title=""
	if( WinType(graphName) )
		GetWindow $graphName wtitle
		title= S_value
	endif
	
	TitleBox chart, win=SpiderSettings, title=title
	
	String workDF = IsRadarChart(graphName)
	if( strlen(workDF) == 0 )
		disable = 2 // visible disabled
	endif
	
	Variable haveWeb = NumVarOrDefault(workDF+"haveSpiderWeb",0) // alternatively, we could look for any spider trace
	CheckBox showSpiderWeb, win=SpiderSettings, disable=disable, value=haveWeb
	if( !haveWeb )
		disable = 2
	endif
	ModifyControlList "lineSize;lineStyle;color;", disable=disable
	if( disable == 0 )
		Variable size= GetSpiderTracesSize(graphName)
		SetVariable lineSize, win=SpiderSettings, value=_NUM:size

		Variable style= GetSpiderTracesStyle(graphName)
		PopupMenu lineStyle,win=SpiderSettings, mode=1+style
		
		Variable red, green, blue, alpha
		[red, green, blue, alpha] = GetSpiderTracesRGB(graphName)
		PopupMenu color,win=SpiderSettings,popColor=(red, green, blue, alpha)
	endif
End

Function ShowSpiderSettings()

	String graphName= TopSpiderPlot()
	DoWindow/F SpiderSettings
	if( V_Flag == 0 )
		CreateSpiderSettings()
		UpdateSpiderControls(graphName)
	endif
	if( strlen(graphName) )
		AutoPositionWindow/M=1/R=$graphName SpiderSettings
	endif
End

Function CreateSpiderSettings()
	DoWindow/K SpiderSettings
	NewPanel /W=(610,143,925,388)/K=1/N=SpiderSettings as "Modify Spider Web Lines"
	ModifyPanel/W=SpiderSettings noEdit=1

	TitleBox chart,pos={40.00,15.00},size={144.00,14.00}
	TitleBox chart,title="Organization Radar/Spider Chart",fSize=10,frame=0
	TitleBox chart,fColor=(1,16019,65535)
	TitleBox chart,userdata(ResizeControlsInfo)=A"!!,D/!!#<(!!#@t!!#;mz!!,c)Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
	TitleBox chart,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	TitleBox chart,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
	GroupBox spiderGroup,pos={23.00,49.00},size={266.00,144.00}
	GroupBox spiderGroup,userdata(ResizeControlsInfo)=A"!!,Bq!!#>R!!#B?!!#@tz!!,c)Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
	GroupBox spiderGroup,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	GroupBox spiderGroup,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
	CheckBox showSpiderWeb,pos={34.00,42.00},size={115.00,16.00},proc=WMRadarChart#ShowSpiderWebCheckProc
	CheckBox showSpiderWeb,title="Show Spider Web ",labelBack=(61166,61166,61166)
	CheckBox showSpiderWeb,value=1
	CheckBox showSpiderWeb,userdata(ResizeControlsInfo)=A"!!,Cl!!#>6!!#@J!!#<8z!!,c)Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	CheckBox showSpiderWeb,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	CheckBox showSpiderWeb,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
	SetVariable lineSize,pos={40.00,81.00},size={110.00,19.00},bodyWidth=60,proc=WMRadarChart#SpiderLineSizeSetVarProc
	SetVariable lineSize,title="Line Size",limits={0,10,0.25},value=_NUM:0.25
	SetVariable lineSize,userdata(ResizeControlsInfo)=A"!!,D/!!#?[!!#@@!!#<Pz!!,f.A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	SetVariable lineSize,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	SetVariable lineSize,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
	PopupMenu color,pos={40.00,154.00},size={106.00,20.00},proc=WMRadarChart#SpiderLineColorPopMenuProc
	PopupMenu color,title="Line Color"
	PopupMenu color,mode=1,popColor=(34952,34952,34952),value=#"\"*COLORPOP*\""
	PopupMenu color,userdata(ResizeControlsInfo)=A"!!,D/!!#A)!!#@8!!#<Xz!!,f.A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	PopupMenu color,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	PopupMenu color,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
	PopupMenu lineStyle,pos={40.00,114.00},size={203.00,20.00},proc=WMRadarChart#SpiderLineStylePopMenuProc
	PopupMenu lineStyle,title="Line Style",mode=2,value=#"\"*LINESTYLEPOP*\""
	PopupMenu lineStyle,userdata(ResizeControlsInfo)=A"!!,D/!!#@H!!#AZ!!#<Xz!!,f.A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	PopupMenu lineStyle,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	PopupMenu lineStyle,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
	Button close,pos={129.00,213.00},size={50.00,20.00},proc=SpiderCloseButtonProc
	Button close,title="Close"
	Button close,userdata(ResizeControlsInfo)=A"!!,Ff!!#Ad!!#>V!!#<Xz!!,f.A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	Button close,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	Button close,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

	SetWindow kwTopWin,hook(SpiderSettings)=SpiderSettingsHook
	SetWindow kwTopWin,hook(ResizeControls)=ResizeControls#ResizeControlsHook
	SetWindow kwTopWin,userdata(ResizeControlsInfo)=A"!!*'\"z!!#BRJ,hrZz!!*'\"zzzzzzzzzzzzzzzzzzz"
	SetWindow kwTopWin,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzzzzzzzzzzzzzzz"
	SetWindow kwTopWin,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzzzzzzzzz!!!"

	SetWindow kwTopWin sizeLimit={228,183,inf,183}

	SetWindow kwTopWin,hook(SpiderSettings)=SpiderSettingsHook
End

Function SpiderSettingsHook(s)
	STRUCT WMWinHookStruct &s

	Variable hookResult = 0

	strswitch(s.eventName)
		case "activate":				// Activate
			UpdateSpiderControls(WinName(0,1,1))
			break

		case "kill":
			break

	endswitch

	return hookResult		// 0 if nothing done, else 1
End

static Function SpiderLineSizeSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	String graphName= TopSpiderPlot()
	SetSpiderTracesSize(graphName,varNum)
End

static Function SpiderLineStylePopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String graphName= TopSpiderPlot()
	SetSpiderTracesStyle(graphName,popNum-1)
End

Static Function SpiderLineColorPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String graphName= TopSpiderPlot()
	ControlInfo/W=SpiderSettings $ctrlName

	SetSpiderTracesRGB(graphName,V_red, V_green, V_blue, V_alpha)
End

Function SpiderCloseButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Execute/P/Q/Z "KillWindow SpiderSettings"
End

static Function ShowSpiderWebCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	String graphName= WMPolarTopPolarGraph()
	String workDF = IsRadarChart(graphName)
	if( strlen(workDF) == 0 )
		Beep
		return 0
	endif
	if( checked )
		RadarAppendSpiderTraces(graphName)
	else
		// TO DO: Save line size, style and color
		// so that toggling the checkbox doesn't reset the values to the defaults.
		RadarRemoveSpiderTraces(graphName)
	endif
	UpdateSpiderControls(graphName)
End


