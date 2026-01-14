#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma IndependentModule = ViewTableCell
#pragma IgorVersion=9 // ModifyTable viewSelection
#pragma version=9 // shipped with Igor 9

Menu "Table"
	"Go To Table Cell...",/Q, MakeViewTableCellPanel()
End

static StrConstant ksPanelName = "ViewTableCellPanel"
static StrConstant ksTableNameUserData = "TableName"
static StrConstant ksPointDimensionsList = "Row;Col;Layer;Chunk;"	// item 0 is rows, 1 is cols, etc.
static StrConstant ksScaledDimensionsList = "X;Y;Z;T;"			// item 0 is rows, 1 is cols, etc.

static StrConstant ksWaveIndexControlList = "wavesInTable;vDim;hDim;vLimits;hLimits;tableInfo;"
static StrConstant ksRowColControlList = "fromTarget;row;col;rowLimits;colLimits;"
static Constant    kIsDebug=0 // set = 1 for debugging popups

static Function IgorMenuHook(Variable isSelection, String menuStr, String itemStr, Variable itemNo, String activeWindowStr, Variable wType )
	
	String table= ActiveTable()
	if( strlen(table) )
		if( !isSelection )
			SetIgorMenuMode "Edit", "Go to Line", EnableItem
		elseif( CmpStr(menuStr,"Edit") == 0 && CmpStr(itemStr,"Go To Line") == 0 )
			Execute/P/Q GetIndependentModuleName()+"#MakeViewTableCellPanel()"
			return 1		
		endif
	endif
	return 0
End

Function MakeViewTableCellPanel()
	DoWindow/F $ksPanelName
	if( V_Flag  == 0 )
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:ShowTableCell
		Make/O/T/N=(1,2,2) root:Packages:ShowTableCell:wavesInTableTW
		String whichRadio= StrVarOrDefault("root:Packages:ShowTableCell:whichRadio", "TableRowColRadio")
		String/G root:Packages:ShowTableCell:whichRadio= whichRadio
		Variable viewImmediately= NumVarOrDefault("root:Packages:ShowTableCell:viewImmediately", 1)
		Variable/G root:Packages:ShowTableCell:viewImmediately= viewImmediately
		
		NewPanel /W=(163,201,930,603)/N=$ksPanelName/K=1 as "View Table Cell"
		DefaultGuiFont/W=#/Mac popup={"_IgorLarge",13,0},all={"_IgorLarge",13,0}
		DefaultGuiFont/W=#/Win popup={"_IgorLarge",0,0},all={"_IgorLarge",0,0}
		if( !kIsDebug )
			ModifyPanel/W=$ksPanelName noEdit=1
		endif
		
		TitleBox tableName,pos={52.00,20.00},size={88.00,24.00},title="Table:"
		TitleBox tableName,frame=2,fColor=(0,16000,65535)

		CheckBox TableRowColRadio,pos={49.00,62.00},size={141.00,16.00},proc=ViewTableCell#PointOrScaledRadioProc
		CheckBox TableRowColRadio,title="Table Row & Column",value=CmpStr(whichRadio,"TableRowColRadio")==0,mode=1
		CheckBox PointIndexesRadio,pos={49.00,95.00},size={131.00,16.00},proc=ViewTableCell#PointOrScaledRadioProc
		CheckBox PointIndexesRadio,title="Point (p/q) Indexes",value=CmpStr(whichRadio,"PointIndexesRadio")==0,mode=1
		CheckBox ScaledIndexRadio,pos={49.00,130.00},size={139.00,16.00},proc=ViewTableCell#PointOrScaledRadioProc
		CheckBox ScaledIndexRadio,title="Scaled (x/y) Indexes",value=CmpStr(whichRadio,"ScaledIndexRadio")==0,mode=1

		SetVariable row,pos={48.00,170.00},size={130.00,19.00},bodyWidth=100,disable=1,proc=ViewTableCell#RowColSetVarProc
		SetVariable row,title="Row",limits={0,127,1},value=_NUM:0
		SetVariable col,pos={54.00,200.00},size={124.00,19.00},bodyWidth=100,disable=1,proc=ViewTableCell#RowColSetVarProc
		SetVariable col,title="Col",limits={0,34,1},value=_NUM:0

		TitleBox rowLimits,pos={191.00,172.00},size={48.00,16.00},disable=1
		TitleBox rowLimits,title="0 ... 127",frame=0
		TitleBox colLimits,pos={191.00,202.00},size={43.00,16.00},disable=1
		TitleBox colLimits,title="0 ... 127",frame=0
		
		SetVariable vDim,pos={54.00,168.00},size={124.00,19.00},bodyWidth=100,proc=ViewTableCell#RowColSetVarProc
		SetVariable vDim,title="X",limits={0,19,1},value=_NUM:0,disable=1
		TitleBox vLimits,pos={191.00,170.00},size={41.00,16.00},title="0 ... 0",frame=0,disable=1

		SetVariable hDim,pos={66.00,198.00},size={112.00,19.00},bodyWidth=100,disable=1,proc=ViewTableCell#RowColSetVarProc
		SetVariable hDim,title="Y",limits={0,49,1},value=_NUM:0
		TitleBox hLimits,pos={191.00,200.00},size={55.00,16.00},title="0 ... 0",frame=0,disable=1

		CheckBox viewImmediately,pos={69.00,232.00},size={170.00,16.00},proc=ViewTableCell#ImmediateShowCheckProc
		CheckBox viewImmediately,title="Scroll to Cell Immediately",value=viewImmediately
	
		Button show,pos={80.00,332.00},size={120.00,20.00},proc=ViewTableCell#ShowRowColButtonProc
		Button show,title="Go To Table Cell"
	
		SetVariable real,pos={41.00,269.00},size={187.00,19.00},bodyWidth=150,proc=ViewTableCell#ValueSetVarProc
		SetVariable real,title="Value",limits={-inf,inf,0},value=_STR:""
		SetVariable imag,pos={41.00,292.00},size={187.00,19.00},bodyWidth=150,disable=1,proc=ViewTableCell#ValueSetVarProc
		SetVariable imag,title=".imag",limits={-inf,inf,0},value=_STR:""

		Variable top = 62, height = 321
		if( kIsDebug )
			top += 30
			height -= 30
		endif
		ListBox wavesInTable,pos={273.00,top},size={473.00,height},proc=ViewTableCell#ViewTableCellListBoxProc
		ListBox wavesInTable,listWave=root:Packages:ShowTableCell:wavesInTableTW,mode=1
		ListBox wavesInTable,selRow=0,userColumnResize=1

		Button fromTarget,pos={271.00,205.00},size={150.00,20.00},disable=1,proc=ViewTableCell#FromTargetButtonProc
		Button fromTarget,title="Set from Target Cell"

		if( kIsDebug )
			PopupMenu tableInfo,pos={274.00,53.00},size={228.00,21.00},title="Column Info"
			PopupMenu genTableInfo,pos={330.00,22.00},size={201.00,21.00},title="Table Info",disable=1
		endif
	
		SetWindow kwTopWin,hook(activate)=ViewTableCell#ShowTableCellPanelActivate
	endif
	String topTable= ActiveTable()
	String topWin = StringFromList(0,topTable,"#")
	AutoPositionWindow/E/R=$topWin $ksPanelName
	ViewTableCellPanelUpdate(topTable)
EndMacro

Function RepositionListbox()

	ControlInfo/W=$ksPanelName wavesInTable
	Variable left= V_left
	Variable top = V_top
	
	GetWindow $ksPanelName wsizeForControls
	Variable panelWidth = V_right
	Variable panelHeight = V_bottom

	Variable margin = 8
	Variable listWidth = panelWidth - left - margin;
	Variable listHeight = panelHeight - top - margin;
	listWidth = max(50,listWidth)
	listHeight = max(50,listHeight)
	ListBox wavesInTable,win=$ksPanelName, size={listWidth,listHeight}
End

Function ShowTableCellPanelActivate(s)
	STRUCT WMWinHookStruct &s

	Variable hookResult = 0

	strswitch(s.eventName)
		case "activate":
			String topTable= ActiveTable()
			ViewTableCellPanelUpdate(topTable)
			break
		case "deactivate":
			ShowTableActivateDeactivate(0x2)
			break
		case "resize":
			RepositionListbox()
	endswitch

	return hookResult		// 0 if nothing done, else 1
End

Function ShowTableActivateDeactivate(Variable disable)
	String controls = ControlNameList(ksPanelName)
	SafeDisableControlList(ksPanelName, controls, disable)
End

Function ViewTableCellPanelUpdate(String topTable)

	Variable wt= WinType(topTable)
	Variable isTable = wt == 2
	Variable disable= isTable ? 0 : 1
	ShowTableActivateDeactivate(disable)

	String title= "Table: "
	if( isTable )
		title += topTable
	endif
	TitleBox tableName win=$ksPanelName, title=title

	String previousTableName= GetUserData(ksPanelName,"",ksTableNameUserData)
	SetWindow $ksPanelName, userdata($ksTableNameUserData) = topTable

	if( kIsDebug )
		String items = "TableInfo(ViewTableCell#ActiveTable(),-2)"
		PopupMenu genTableInfo, win=$ksPanelName, value=#items, mode=8, disable=disable
	endif
	
	WAVE/T tw = FillViewCellWavesList(topTable,previousTableName)
	if( isTable )
		ControlInfo/W=$ksPanelName wavesInTable
		Variable selRow = V_Value
		UpdateViewTableCellControls(topTable, tw, selRow)
	endif
End

Function/WAVE ColumnsWaveAndIndex(Variable selRow, Variable &tableIndex)
	ControlInfo/W=$ksPanelName wavesInTable
	WAVE/Z/T tw = $(S_DataFolder+S_Value) // 	Full path to listWave (if any).
	if( WaveExists(tw) && selRow >= 0 && selRow < DimSize(tw,0) )
		String pathToWave = tw[selRow][1][0]		// less susceptible to column rearrangement after the list was created.
		WAVE/Z w = $pathToWave	// could be text or complex wave, we don't care, we care only about dimensions and scaling
		tableIndex= str2num(tw[selRow][0][1])
	else
		tableIndex= NaN
	endif
	return w
End

Function/WAVE SelectedColumnsWave(Variable &tableIndex)
	ControlInfo/W=$ksPanelName wavesInTable
	Variable selRow = V_Value
	WAVE/Z w = ColumnsWaveAndIndex(selRow,tableIndex)
	return w
End

Function ShowValueOfSelectedCell()
	String tableName= GetUserData(ksPanelName,"",ksTableNameUserData)

	[WAVE w, Variable isValid, String realPart,String imagPart] = TableTargetValues(tableName)
	Variable isComplex = isValid && (WaveType(w) & 0x1)
	String title= SelectString(isComplex, "Value", ".real")
	Variable disable = isValid ? 0 : 2
	SetVariable real win=$ksPanelName, title=title, disable=disable, value=_STR:realPart
	disable = isComplex ? (isValid ? 0 : 2) : 1
	SetVariable imag win=$ksPanelName, disable=disable,value=_STR:imagPart
End

Function ShowValueOfCell(Variable tableRow, Variable tableCol)

	String tableName= GetUserData(ksPanelName,"",ksTableNameUserData)
	
	[WAVE w, Variable isValid, String realPart,String imagPart] = TableCellValues(tableName, tableRow, tableCol)
	Variable isComplex = isValid && (WaveType(w) & 0x1)
	String title= SelectString(isComplex, "Value", ".real")
	Variable disable = isValid ? 0 : 2
	SetVariable real win=$ksPanelName, title=title, disable=disable, value=_STR:realPart
	disable = isComplex ? (isValid ? 0 : 2) : 1
	SetVariable imag win=$ksPanelName, disable=disable,value=_STR:imagPart
End

Function UpdateViewTableCellControls(String table, WAVE/T tw, Variable selRow)

	Variable updateTargetCell= 0
	ControlInfo/W=$ksPanelName TableRowColRadio
	if( V_Value )
		SafeHideControlList(ksPanelName, ksWaveIndexControlList, 1) // hide
		SafeHideControlList(ksPanelName, ksRowColControlList, 0) // show
		UpdateViewTableRowCol(table,1)
	else
		SafeHideControlList(ksPanelName, ksWaveIndexControlList, 0) // show
		SafeHideControlList(ksPanelName, ksRowColControlList, 1) // hide
		Variable ret = UpdateWavePointScaledControls(table, tw, selRow)
		updateTargetCell = ret == 1
	endif
	Variable tableRow, tableCol
	GetTableRowAndCol(tableRow, tableCol)
	ShowValueOfCell(tableRow, tableCol)
	ControlInfo/W=$ksPanelName viewImmediately
	if( V_Value || updateTargetCell )
		ViewTableRowAndCol(tableRow, tableCol)
	endif
End

Function UpdateViewTableRowCol(String table, Variable initFromTargetCell)

	String info= TableInfo(table,-2)	// general info, or "" if not a table
	Variable cols = NumberByKey("COLUMNS",info,":")
	Variable rows = NumberByKey("ROWS",info,":")
	Variable vLimitMin = 0, vLimitMax = rows-1, vLimitInc= 1
	Variable hLimitMin = 0, hLimitMax = cols-1, hLimitInc= 1
	String vRange, hRange
	sprintf vRange, "%d ... %d", vLimitMin,vLimitMax
	sprintf hRange, "%d ... %d", hLimitMin,hLimitMax

	// TO DO: Test with empty table
	// test with table containing only an index column
	Variable vValue, hValue
	if (initFromTargetCell)
		String selectionInfo = StringByKey("SELECTION", info,":")	//28,6,28,6,28,6
		Variable fRow, fCol, lRow, lCol, tRow, tCol	// these are most like row and column point indices into the wave, never scaling values.
		sscanf selectionInfo, "%d,%d,%d,%d,%d,%d", fRow, fCol, lRow, lCol, tRow, tCol
		vValue = tRow; hValue = tCol
	else
		// validate the previously entered value (use separate controls from wave-driven values)
		ControlInfo/W=$ksPanelName row
		vValue = limit(V_Value,0,rows-1)
		ControlInfo/W=$ksPanelName col
		hValue = limit(V_Value,0,cols-1)
	endif
	SetVariable row,win=$ksPanelName,title="Row",limits={vLimitMin,vLimitMax,vLimitInc},value=_NUM:vValue	
	SetVariable col,win=$ksPanelName,title="Col",limits={hLimitMin,hLimitMax,hLimitInc},value=_NUM:hValue	
	TitleBox rowLimits,win=$ksPanelName,title=vRange
	TitleBox colLimits,win=$ksPanelName,title=hRange
	
	// hide controls not relevant to the dimensions of the wave.
	Variable hide = (vLimitMax < 0 ) ? 1 : 0
	SafeHideControlList(ksPanelName, "row;rowLimits;", hide)
	hide = (hLimitMax < 0 ) ? 1 : 0
	SafeHideControlList(ksPanelName, "col;colLimits;", hide)
End

// Take the target table's row/col selection
// and the View Table Cell panel's listbox row selection into account
// to update the Point/Scaled controls accordingly.
// If the table selection isn't in the selected wave's row/column, use row/col = 0
// It is possible (likely) that if the column is invalid that the row *is* valid.
// The return value is -1 if the table is empty,
// 0 if the controls were updated properly
// 1 if the controls were updated properly, BUT the target cell needs an update.
Function UpdateWavePointScaledControls(String table, WAVE/T tw, Variable selRow)
	
	Variable nRows = DimSize(tw,0)
	if( nRows < 1 )
		ModifyControlList "vDim;vLimits;hDim;hLimits;" ,win=$ksPanelName, disable = 1
		return -1
	endif
	if( selRow < 0 )
		selRow = 0
	elseif (selRow >= nRows)
		selRow = nRows-1
	endif

	Variable tableIndex = str2num(tw[selRow][0][1])
	//String info = TableInfo(table, tableIndex)
	String info = tw[selRow][1][1]	// First data column (not index) UNLESS ONLY an Index/Label column is present
	// TABLENAME:Table0;HOST:;COLUMNNAME:jack.i;TYPE:Index;INDEX:0;DATATYPE:2;WAVE:root:jack;COLUMNS:2;HDIM:1;VDIM:0;
  	// TITLE:;WIDTH:82;FORMAT:0;DIGITS:3;SIGDIGITS:6;TRAILINGZEROS:0;SHOWFRACSECONDS:0;
  	// FONT:Helvetica;SIZE:12;STYLE:0;ALIGNMENT:2;RGB:0,0,0;RGBA:0,0,0,65535;ELEMENTS:-2,-3,0,0;
	if( kIsDebug )
		String items = "\""+info+"\""
		PopupMenu TableInfo win=$ksPanelName,value=#items, mode=3
	endif
	
	//String pathToWave = StringByKey("WAVE",info,":")	
	String pathToWave = tw[selRow][1][0]		// less susceptible to column rearrangement after the list was created.
	WAVE/Z w = $pathToWave	// could be text or complex wave, we don't care, we care only about dimensions and scaling

	// figure out the vertical dimension
	Variable vDim =	NumberByKey("VDIM",info,":")	// 0 is rows, 1 is cols, etc.
	Variable hDim =	NumberByKey("HDIM",info,":")

	// Get the target cell in table row/col format.
	String tInfo = TableInfo(table,-2)
	// TABLENAME:Table0;HOST:;ROWS:128;COLUMNS:26;SELECTION:28,6,28,6,28,6;FIRSTCELL:0,0;LASTCELL:38,18;TARGETCELL:28,6;SHOWPARTS:0xff;ENTERING:1;ENTRYTEXT:0
	String selectionInfo = StringByKey("SELECTION", tInfo,":")	//28,6,28,6,28,6
	Variable fRow, fCol, lRow, lCol, tRow, tCol	// these are most like row and column point indices into the wave, never scaling values.
	sscanf selectionInfo, "%d,%d,%d,%d,%d,%d", fRow, fCol, lRow, lCol, tRow, tCol
	
	// Figure out the point or scaling range of the wave for the column selected in the View Table Cell's list
	// Choose the vDimPoint and hDimPoint closest to the target cell.
	Variable firstColInTable = NumberByKey("INDEX",info,":")
	Variable vDimPoint = tRow
	Variable hDimPoint = tCol - firstColInTable 
	
	// Either point or scaled value (and limits and increment)
	// is installed in SetVariable vDim and SetVariable hDim.
	// To start, let's take the target row and col and find the corresponding vertical and horizontal point indices
	Variable vDimMax = DimSize(w, vdim)-1	// 0 is the min DimSize, vDimMax can be -1 if wave has no rows (points)
	Variable hDimMax = DimSize(w, hdim)-1	// hDimMax is -1 if hDim=1 (columns) but w has no columns, for example.
	
	// If vDimPointClipped != vDimPoint or hDimPointClipped != hDimPoint
	// the table target cell doesn't match the cell we're representing in the panel.
	Variable vDimPointClipped = limit(vDimPoint,0,vDimMax)
	Variable hDimPointClipped = limit(hDimPoint,0,hDimMax)
	Variable needTargetCellUpdate = vDimPointClipped != vDimPoint || hDimPointClipped != hDimPoint
	vDimPoint= vDimPointClipped
	hDimPoint= hDimPointClipped
	
	// Corresponding scaled values
	Variable vDimScaled = DimOffset(w, vDim) + vDimPoint * DimDelta(w, vDim)
	Variable hDimScaled = DimOffset(w, hDim) + hDimPoint * DimDelta(w, hDim)
	
	Variable vDimScaledStart = DimOffset(w, vDim)
	Variable hDimScaledStart = DimOffset(w, hDim)
	
	Variable vDimScaledEnd = vDimScaledStart + vDimMax * DimDelta(w, vDim)
	Variable hDimScaledEnd = hDimScaledStart + hDimMax * DimDelta(w, hDim)

	// set up controls for scaled or point values
	String verticalLabel, horizontalLabel
	Variable vLimitMin, vLimitMax, vLimitInc
	Variable hLimitMin, hLimitMax, hLimitInc
	String vRange, hRange
	Variable vValue, hValue

	ControlInfo/W=$ksPanelName PointIndexesRadio
	if( V_Value )
		// point indexing
		verticalLabel = StringFromList(vDim,ksPointDimensionsList)
		horizontalLabel = StringFromList(hDim,ksPointDimensionsList)
		vLimitMin = 0; vLimitMax = vDimMax; vLimitInc= 1
		hLimitMin = 0; hLimitMax = hDimMax; hLimitInc= 1
		sprintf vRange, "%d ... %d", vLimitMin,vLimitMax
		sprintf hRange, "%d ... %d", hLimitMin,hLimitMax
		vValue= vDimPoint
		hValue = hDimPoint
	else
		// scaled indexing
		verticalLabel = StringFromList(vDim,ksScaledDimensionsList)
		horizontalLabel = StringFromList(hDim,ksScaledDimensionsList)
		// beware: DimDelta can be negative
		// I choose to always present the range as increasing
		// even if the start scaling (leftx) is greater than the end scaling (rightx)
		vLimitMin = min(vDimScaledStart,vDimScaledEnd)
		vLimitMax = max(vDimScaledStart,vDimScaledEnd)
		vLimitInc= abs(DimDelta(w, vDim))
		hLimitMin = min(hDimScaledStart,hDimScaledEnd)
		hLimitMax = max(hDimScaledStart,hDimScaledEnd)
		hLimitInc= abs(DimDelta(w, hDim))
		sprintf vRange, "%g ... %g", vLimitMin,vLimitMax
		sprintf hRange, "%g ... %g", hLimitMin,hLimitMax
		vValue= vDimScaled
		hValue = hDimScaled
	endif
	SetVariable vDim,win=$ksPanelName,title=verticalLabel,limits={vLimitMin,vLimitMax,vLimitInc},value=_NUM:vValue
	SetVariable hDim,win=$ksPanelName,title=horizontalLabel,limits={hLimitMin,hLimitMax,hLimitInc},value=_NUM:hValue
	TitleBox vLimits,win=$ksPanelName,title=vRange
	TitleBox hLimits,win=$ksPanelName,title=hRange
	
	// hide controls not relevant to the dimensions of the wave.
	Variable disable = (vDimMax < 0 ) ? 1 : 0
	ModifyControlList "vDim;vLimits" ,win=$ksPanelName, disable = disable

	disable = (hDimMax < 0 ) ? 1 : 0
	// if the type is Index or Label, that means only the .i column is in the table, not the .d column.
	// In that case only the vDim control is functional
	String type = StringByKey("TYPE",info,":")	// we care if type is Index or Label
	if( CmpStr(type,"Index") == 0 || CmpStr(type,"Label") == 0 )
		disable= 1
	endif
	
	ModifyControlList "hDim;hLimits" ,win=$ksPanelName, disable = disable
	return needTargetCellUpdate ? 1 : 0
End

// returns the table column for first Data or RealData col with the given table index,
// or if no data, then the first Index or Label,
// or -1 if not found.
//
// The purpose of this routine is to choose the table column that matches the wave's horizontal index or scaling value.
// 
Function FirstTableColumnForWave(String tableWin, WAVE/Z w)
	String info= TableInfo(tableWin,-2)	// general info, or "" if not a table
	if( strlen(info) == 0 || !WaveExists(w) )
		return -1
	endif
	Variable i, cols = NumberByKey("COLUMNS",info,":")
	String soughtWavePath = GetWavesDataFolder(w,2)	// root:'complex Chunky'
	for(i=0; i<cols; )
		info = TableInfo(tableWin,i)		// first column (jack.x or jack.d)
		Variable index = NumberByKey("INDEX",info,":")	// should be i
		Variable groupColumns = NumberByKey("COLUMNS",info,":")	// skips to next group from index, includes index, DOES multiply by 2 for complex waves.
		String wavePath = StringByKey("WAVE",info,":")
		String type = StringByKey("TYPE",info,":")	// Unused, Point, Index, Label, Data, RealData, ImagData
		if( CmpStr(wavePath, soughtWavePath) == 0 )
			// i is the table selection column of the first index or data column; we prefer the data column
			strswitch(type)
				case "Index":	// one of these two types of columns can be present
				case "Label":	// but not both
					String nextInfo = TableInfo(tableWin,i+1)			// next column
					String nextWavePath = StringByKey("WAVE",nextInfo,":")
					if( CmpStr(nextWavePath, soughtWavePath) == 0 )
						i += 1
					endif
					break
			endswitch
			return i // <<<<< NORMAL EXIT
		endif
		i += groupColumns
	endfor
	return -1
End

// Given a table and the target tableRow and tableColumn as returned by TableInfo(table,-2)
// returns Wave reference, point dimensions
Function [WAVE w, Variable pPoint, Variable qPoint, Variable rPoint, Variable sPoint] TableRowAndColumnToWavePoints(String table, Variable tableRow, Variable tableCol)

	Variable index = tableCol	// same as INDEX from TableInfo
	String info = TableInfo(table,index)
	// TABLENAME:Table0;HOST:;COLUMNNAME:'complex Chunky'.d.real;TYPE:RealData;INDEX:3;
	// DATATYPE:3;WAVE:root:'complex Chunky';COLUMNS:9;HDIM:1;VDIM:0;TITLE:;
	// WIDTH:194;FORMAT:0;DIGITS:3;SIGDIGITS:6;TRAILINGZEROS:0;SHOWFRACSECONDS:0;
	// FONT:Helvetica;SIZE:12;STYLE:0;ALIGNMENT:2;RGB:0,0,0;RGBA:0,0,0,65535;ELEMENTS:-2,-3,2,0;
	String type = StringByKey("TYPE",info,":")	// Unused, Point, Index, Label, Data, RealData, ImagData
	String elements = StringByKey("ELEMENTS",info,":") // "-2,-3,2,0" -2: Display this dimension vertically, -3: horizontally
	String pathToWave = StringByKey("WAVE",info,":")
	WAVE/Z w = $pathToWave	// could be numeric, text or complex wave
	Variable isComplex = WaveType(w) & 0x1
	// figure out the displayed dimensions
	Variable vDim =	NumberByKey("VDIM",info,":")	// 0 is rows, 1 is cols, etc.
	Variable hDim =	NumberByKey("HDIM",info,":")
	Variable hPoint, vPoint = tableRow
	Variable isIndexColumn = CmpStr(type,"Index") == 0 || CmpStr(type,"Label") == 0
	if( isIndexColumn )
		hPoint = 0
	else
		Variable firstColIndex = FirstTableColumnForWave(table, w)
		hPoint = tableCol - firstColIndex
		if( isComplex )
			hPoint = floor(hPoint/2)
		endif
	endif

	// substitute hPoint for -3, and vPoint for -2
	String points= ReplaceString("-2",ReplaceString("-3", elements, num2istr(hPoint)), num2istr(vPoint))
	sscanf points, "%d,%d,%d,%d", pPoint, qPoint, rPoint, sPoint
	return [w, pPoint, qPoint, rPoint, sPoint]
End

Function [Variable tableRow, Variable tableCol] TableTargetCell(String table)

	String tInfo = TableInfo(table,-2)
	// TABLENAME:Table0;HOST:;ROWS:128;COLUMNS:26;SELECTION:28,6,28,6,28,6;FIRSTCELL:0,0;LASTCELL:38,18;TARGETCELL:28,6;SHOWPARTS:0xff;ENTERING:1;ENTRYTEXT:0
	String selectionInfo = StringByKey("SELECTION", tInfo,":")	//28,6,28,6,28,6
	Variable fRow, fCol, lRow, lCol
	sscanf selectionInfo, "%d,%d,%d,%d,%d,%d", fRow, fCol, lRow, lCol, tableRow, tableCol
	return [tableRow, tableCol]
End

// [p,0,0,0] is always valid
Function ValidIndexesForWave(Wave/Z w, Variable pPoint, Variable qPoint, Variable rPoint, Variable sPoint)
	if( !WaveExists(w) || numpnts(w) == 0 )
		return 0
	endif
	if( pPoint && (pPoint >= DimSize(w,0)) )
		return 0
	endif
	if( pPoint < 0 )
		return 0
	endif
	if( qPoint && (qPoint >= DimSize(w,1)) )
		return 0
	endif
	if( qPoint < 0 )
		return 0
	endif
	if( rPoint && (rPoint >= DimSize(w,2)) )
		return 0
	endif
	if( rPoint < 0 )
		return 0
	endif
	if( sPoint && (sPoint >= DimSize(w,3)) )
		return 0
	endif
	if( sPoint < 0 )
		return 0
	endif
	return 1
End

Function [WAVE w, Variable isValid, String realPart,String imagPart] TableCellValues(String table, Variable tableRow, Variable tableCol)

	[WAVE w, Variable pPoint, Variable qPoint, Variable rPoint, Variable sPoint] = TableRowAndColumnToWavePoints(table, tableRow, tableCol)
	isValid = ValidIndexesForWave(w, pPoint, qPoint, rPoint, sPoint)
	if( isValid )
		Variable wt1 = WaveType(w,1)
		Variable isNumeric = wt1 == 1
		Variable isText = wt1 == 2
		Variable isReference = !isNumeric && !isText
		imagPart=""
		if( isNumeric )
			Variable isComplex = WaveType(w) & 0x1
			if( isComplex )
				WAVE/C cw = w
				Variable/C cmplxVal = cw[pPoint][qPoint][rPoint][sPoint]
				sprintf realPart, "%.14g", real(cmplxVal)
				sprintf imagPart, "%.14g", imag(cmplxVal)
			else
				sprintf realPart, "%.14g", w[pPoint][qPoint][rPoint][sPoint]
			endif
		elseif( isText )
			WAVE/T tw=w
			realPart = tw[pPoint][qPoint][rPoint][sPoint]
		else
			sprintf realPart, "0x%8.8x", w[pPoint][qPoint][rPoint][sPoint]
		endif
	else
		realPart=""
		imagPart=""
	endif
	return [w,isValid,realPart,imagPart]
End

Function [WAVE w, Variable isValid, String realPart,String imagPart] TableTargetValues(String table)

	[Variable tableRow, Variable tableCol] = TableTargetCell(table)
	[WAVE w, isValid, realPart, imagPart] = TableCellValues(table, tableRow, tableCol)
	return [w,isValid,realPart,imagPart]
End

Function/WAVE FillViewCellWavesList(String tableWin,String previousTableName)

	String info= TableInfo(tableWin,-2)	// general info, or "" if not a table
	if( strlen(info) == 0 )
		Make/O/T/N=(1,2,2) root:Packages:ShowTableCell:wavesInTableTW/WAVE=tw
		SetDimLabel 1, 0, column, tw
		SetDimLabel 1, 1, wave, tw
		tw[0][][] = "<n/a>"	
		return tw
	endif
	
	Variable previousSelectedRow = 0
	if( CmpStr(previousTableName,tableWin) == 0 )
		ControlInfo/W=$ksPanelName wavesInTable
		previousSelectedRow = V_Value
	endif
	
	Variable cols = NumberByKey("COLUMNS",info,":")
#if 0
	Variable rows = NumberByKey("ROWS",info,":")
	Variable parts = NumberByKey("SHOWPARTS",info,":")	// does this scan 0xFF properly? YES!
	Printf "showParts = 0x%x\r",parts
	Variable havePointsColumn = parts & 0x8
	Print "-------"	
	Print info
	// TABLENAME:Table0;HOST:;ROWS:128;COLUMNS:26;SELECTION:28,6,28,6,28,6;FIRSTCELL:0,0;LASTCELL:38,18;TARGETCELL:28,6;SHOWPARTS:0xff;ENTERING:1;ENTRYTEXT:0
	
	// if the point column is not showing...	ModifyTable showParts=0xf7, you'd expect some readback in TableInfo(table,-2)
	// #define SS_SHOW_POINT_COLUMN_MASK 8
	// now with Igor 9 it does:
	// TABLENAME:Table0;HOST:;ROWS:128;COLUMNS:26;SELECTION:28,6,28,6,28,6;FIRSTCELL:0,0;LASTCELL:38,19;TARGETCELL:28,6;SHOWPARTS:0xf7;ENTERING:0;ENTRYTEXT:0

	Print TableInfo(tableWin,-1)	// point column
  	// TABLENAME:Table0;HOST:;COLUMNNAME:Point;TYPE:Point;INDEX:-1;DATATYPE:96;WAVE:;COLUMNS:0;HDIM:1;VDIM:0;
  	// TITLE:;WIDTH:64;FORMAT:1;DIGITS:3;SIGDIGITS:6;TRAILINGZEROS:0;SHOWFRACSECONDS:0;
  	// FONT:Helvetica;SIZE:12;STYLE:0;ALIGNMENT:2;RGB:0,0,0;RGBA:0,0,0,65535;ELEMENTS:-2,-3,0,0;
  	

	Print TableInfo(tableWin,0)		// first column (jack.i) (jack.x)
  	// TABLENAME:Table0;HOST:;COLUMNNAME:jack.i;TYPE:Index;INDEX:0;DATATYPE:2;WAVE:root:jack;COLUMNS:2;HDIM:1;VDIM:0;
  	// TITLE:;WIDTH:82;FORMAT:0;DIGITS:3;SIGDIGITS:6;TRAILINGZEROS:0;SHOWFRACSECONDS:0;
  	// FONT:Helvetica;SIZE:12;STYLE:0;ALIGNMENT:2;RGB:0,0,0;RGBA:0,0,0,65535;ELEMENTS:-2,-3,0,0;

	Print TableInfo(tableWin,1)		// second column (jack.d)
	// TABLENAME:Table0;HOST:;COLUMNNAME:jack.d;TYPE:Data;INDEX:1;DATATYPE:2;WAVE:root:jack;COLUMNS:2;HDIM:1;VDIM:0;
	// TITLE:;WIDTH:82;FORMAT:0;DIGITS:3;SIGDIGITS:6;TRAILINGZEROS:0;SHOWFRACSECONDS:0;
	// FONT:Helvetica;SIZE:12;STYLE:0;ALIGNMENT:2;RGB:0,0,0;RGBA:0,0,0,65535;ELEMENTS:-2,-3,0,0;

	Print TableInfo(tableWin,2)	// third column (twod.i)
	// TABLENAME:Table0;HOST:;COLUMNNAME:twod.i;TYPE:Index;INDEX:2;DATATYPE:2;WAVE:root:twod;COLUMNS:21;HDIM:1;VDIM:0;
	// TITLE:;WIDTH:82;FORMAT:0;DIGITS:3;SIGDIGITS:6;TRAILINGZEROS:0;SHOWFRACSECONDS:0;
	// FONT:Helvetica;SIZE:12;STYLE:0;ALIGNMENT:2;RGB:0,0,0;RGBA:0,0,0,65535;ELEMENTS:-2,-3,0,0;

	Print TableInfo(tableWin,3)	// fourth column (twod.d[][0])
	Print TableInfo(tableWin,4) // fifth column (twod.d[][1])
	//...
	WAVE twod
	Variable twodCols = DimSize(twoD,1)
	Print TableInfo(tableWin,3+twodCols-1) // fifth column (twod[][19].d)
	// TABLENAME:Table0;HOST:;COLUMNNAME:twod.d;TYPE:Data;INDEX:22;DATATYPE:2;WAVE:root:twod;COLUMNS:21;HDIM:1;VDIM:0;
	// TITLE:;WIDTH:82;FORMAT:0;DIGITS:3;SIGDIGITS:6;TRAILINGZEROS:0;SHOWFRACSECONDS:0;
	// FONT:Helvetica;SIZE:12;STYLE:0;ALIGNMENT:2;RGB:0,0,0;RGBA:0,0,0,65535;ELEMENTS:-2,-3,0,0;

	Print TableInfo(tableWin,3+twodCols) // first column of complex 1D wave, with a title (for the group)
	// TABLENAME:Table0;HOST:;COLUMNNAME:cmpx.d.real;TYPE:RealData;INDEX:23;DATATYPE:3;WAVE:root:cmpx;COLUMNS:2;HDIM:1;VDIM:0;
	// TITLE:This is a Title;WIDTH:82;FORMAT:0;DIGITS:3;SIGDIGITS:6;TRAILINGZEROS:0;SHOWFRACSECONDS:0;
	// FONT:Helvetica;SIZE:12;STYLE:0;ALIGNMENT:2;RGB:0,0,0;RGBA:0,0,0,65535;ELEMENTS:-2,-3,0,0;
#endif

	// the key values here are:
	//  COLUMNNAME	Use this in the list?
	//  COLUMNS	The total number of columns in the table from the wave for the column for which you are getting information. This can be used to skip over all of the columns of a multidimensional wave., excepting the Points column, which claims it is zero.
	//  INDEX	Column's position. -1 refers to the Point column, 0 to the first data column and so on.
	//  HDIM	The wave dimension displayed horizontally as you move from one column to the next. 0 means rows, 1 means columns, 2 means layers, 3 means chunks.
	//  VDIM	The wave dimension displayed vertically in the column. 0 means rows, 1 means columns, 2 means layers, 3 means chunks.
	//  TYPE	Column's type which will be one of the following: Unused, Point, Index, Label, Data, RealData, ImagData.
	
	String names=""
	String wavePaths=""
	String indexList=""
	Variable i
	String previousColumnInfo=""
	String previousWavePath=""
	for(i=0; i<cols; )
		info = TableInfo(tableWin,i)		// first column (jack.i) (jack.x)
		String type = StringByKey("TYPE",info,":")
		Variable increment = 1
		Variable index = NumberByKey("INDEX",info,":")
		String name = StringByKey("TITLE",info,":")
		if( strlen(name) == 0 )
			name = StringByKey("COLUMNNAME",info,":")
			// remove .real and .imag
			name= RemoveEnding(RemoveEnding(name,".real"),".imag")
		endif
		String wavePath = StringByKey("WAVE",info,":")
		// The complications here arise from the way the COLUMNS is reported for indexes columns.
		// For example, Edit jack.id results in a TableInfo for jack.i that reports COLUMNS=2; one for the .i (.x) and one for the .d.
		// But the next column for jack.d also reports COLUMNS=2 if the .i is present.
		// The complication is that one can have just the index column without the data column.
		strswitch(type)
			case "Data":
			case "RealData":
				increment = NumberByKey("COLUMNS",info,":") // skip to the next group
				if( CmpStr(wavePath,previousWavePath) == 0 )
					increment -= 1
					// replace the previous column's name and index from names and indexList
					// with this column's name and index (we already know the wave is the same) 
					Variable n= ItemsInList(names)
					names = RemoveListItem(n-1, names)+name+";"
					indexList = RemoveListItem(n-1, indexList) + num2str(index,"%d;")
				else
					names += name+";"
					wavePaths += wavePath+";"
					indexList += num2str(index,"%d;")
				endif
				break
			case "Index":
			case "Label":
				names += name+";"
				wavePaths += wavePath+";"
				indexList += num2str(index,"%d;")
				increment = 1
				break
		endswitch
		previousColumnInfo=info
		previousWavePath= wavePath
		i += increment
	endfor
	n = ItemsInList(names)
	Make/O/T/N=(n,2,2) root:Packages:ShowTableCell:wavesInTableTW/WAVE=tw
	SetDimLabel 1, 0, column, tw
	SetDimLabel 1, 1, wave, tw
	tw[][0][0] = StringFromList(p,names)
	tw[][1][0] = StringFromList(p,wavePaths)
	tw[][0][1] = StringFromList(p,indexList)
	for( i = 0; i<n; i+= 1 )
		index = str2num(tw[i][0][1])
		tw[i][1][1] = TableInfo(tableWin,index)	
	endfor
	
	ListBox wavesInTable, win=$ksPanelName, selRow=previousSelectedRow
	return tw
End

Function ViewTableRowAndCol(Variable tableRow, Variable tableCol)

	String tableName= GetUserData(ksPanelName,"",ksTableNameUserData)
	ModifyTable/W=$tableName viewSelection, selection=(tableRow, tableCol, tableRow, tableCol, tableRow, tableCol)
End

// Reads the controls in the panel,
// and figures out which row and column to set as target with ViewTableRowAndCol().
Function GetTableRowAndCol(Variable &tableRow, Variable &tableCol)

	// Table Rows & Column
	ControlInfo/W=$ksPanelName TableRowColRadio
	if( V_Value )
		ControlInfo/W=$ksPanelName row
		tableRow= V_Value
		ControlInfo/W=$ksPanelName col
		tableCol= V_Value
		return 0
	endif

	// Point or Scaled wave indexes
	// Convert the control point or scaled values into table rows and cols
	Variable tableIndex
	WAVE/Z w= SelectedColumnsWave(tableIndex)
	Variable isComplex = WaveType(w) & 0x1
	String choices
	ControlInfo/W=$ksPanelName PointIndexesRadio
	Variable isPoints = V_Value
	if( isPoints )
		choices = ksPointDimensionsList
	else
		choices = ksScaledDimensionsList
	endif
	// convert a vertical dimension index/scale to a spreadsheet row
	ControlInfo/W=$ksPanelName vDim
	Variable vValue = V_Value
	Variable vDim = WhichListItem(S_title, choices, ";", 0, 0) // case insensitive
	tableRow= 0
	if( vDim >= 0 )
		if( isPoints )
			tableRow= vValue	// table row same as vertical dimension point index if points
		else
			// convert from dimension scaling to dimension point index.
			tableRow= round( (vValue - DimOffset(w,vDim)) / DimDelta(w,vDim))
		endif
	endif
	
	String tableName= GetUserData(ksPanelName,"",ksTableNameUserData)
	Variable firstTableCol = FirstTableColumnForWave(tableName, w)
	tableCol = firstTableCol
	// if wave has a horizontal dimension, convert a horizontal dimension index/scale to a spreadsheet column
	ControlInfo/W=$ksPanelName hDim
	if( V_disable == 0 )
		Variable hValue = V_Value
		Variable hDim = WhichListItem(S_title, choices, ";", 0, 0) // case insensitive
		
		// figure out which column the wave[...,hValue] is displayed in
		if( hDim >= 0 )
			Variable waveCol
			if( isPoints )
				waveCol = hValue	// table col same as horizontal dimension point index if points
			else
				// convert from dimension scaling to dimension point index.
				waveCol = round( (hValue - DimOffset(w,hDim)) / DimDelta(w,hDim))
			endif
			if( isComplex )
				waveCol *= 2
			endif
			if( firstTableCol >= 0 )
				tableCol = firstTableCol+waveCol
			endif
		endif
	endif
	
	return isPoints ? 1 : 2
End

Function ViewTableCellListBoxProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	Variable row = lba.row
	Variable col = lba.col
	WAVE/T/Z listWave = lba.listWave
	WAVE/Z selWave = lba.selWave
	String tableName= GetUserData(lba.win,"",ksTableNameUserData)

	switch( lba.eventCode )
		case -1: // control being killed
			break
		case 1: // mouse down
			break
		case 3: // double click
			break
		case 4: // cell selection
		case 5: // cell selection plus shift key
			UpdateViewTableCellControls(tableName,listWave, row)
			break
		case 6: // begin edit
			break
		case 7: // finish edit
			break
		case 13: // checkbox clicked (Igor 6.2 or later)
			break
	endswitch

	return 0
End

Function/S ActiveTable()
	
	String windows = WinList("!"+ksPanelName,";","WIN:67,VISIBLE:1")	// tables, graphs, and panels not named ksPanelName, in top-to-bottom order
	
	Variable i, n= ItemsInList(windows)
	for(i=0;i<n;i+=1)
		String win= StringFromList(i,windows)
		GetWindow $win activeSW		// Stores the window "path" of currently active window or subwindow in S_Value. See Subwindow Syntax for details on the window hierarchy.
		Variable type= WinType(S_Value)
		if( type == 2 ) // sub-table?
			return S_Value
		endif
	endfor
	return ""
End

Function SafeDisable(String win, String control, Variable disable)

	ControlInfo/W=$win $control
	//	V_disable		Control's disable state:
	//		0:	Normal (enabled, visible).
	//		1:	Hidden.
	//		2:	Disabled, visible.
	//		3:	Disabled, hidden (not documented).
	if( disable )
		V_disable = V_disable | 0x2	// set only the disabled
	else
		V_disable = V_disable & ~0x2 // clear only the disabled bit
	endif
	ModifyControl/Z $control, win=$win, disable=V_disable
End

Function SafeDisableControlList(String win, String controlList, Variable disable)

	Variable i, n= ItemsInList(controlList)
	for(i=0; i<n; i+=1)
		String control = StringFromList(i,controlList)
		SafeDisable(win, control, disable)
	endfor
End

Function SafeHideControl(String win, String control, Variable hide)

	ControlInfo/W=$win $control
	//	V_disable		Control's disable state:
	//		0:	Normal (enabled, visible).
	//		1:	Hidden.
	//		2:	Disabled, visible.
	//		3:	Disabled, hidden (not documented).
	if( hide )
		V_disable = V_disable | 0x1	// set only the invisible bit
	else
		V_disable = V_disable & ~0x1 // clear only the invisible bit
	endif
	ModifyControl/Z $control, win=$win, disable=V_disable
End

Function SafeHideControlList(String win, String controlList, Variable hide)

	Variable i, n= ItemsInList(controlList)
	for(i=0; i<n; i+=1)
		String control = StringFromList(i,controlList)
		SafeHideControl(win, control, hide)
	endfor
End

Function PointOrScaledRadioProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
		
			String/G root:Packages:ShowTableCell:whichRadio = cba.ctrlName
			CheckBox PointIndexesRadio, value= CmpStr(cba.ctrlName, "PointIndexesRadio") == 0
			CheckBox ScaledIndexRadio, value= CmpStr(cba.ctrlName, "ScaledIndexRadio") == 0
			CheckBox TableRowColRadio, value= CmpStr(cba.ctrlName, "TableRowColRadio") == 0
			
			ControlInfo/W=$ksPanelName wavesInTable
			Variable selRow = V_Value
			WAVE/Z/T tw = $(S_DataFolder+S_Value) // 	Full path to listWave (if any).
			String tableName= GetUserData(ksPanelName,"",ksTableNameUserData)
			UpdateViewTableCellControls(tableName, tw, selRow)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function RowColSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	Variable tableRow, tableCol
	GetTableRowAndCol(tableRow, tableCol)
	ControlInfo/W=$ksPanelName viewImmediately
	if( V_Value )
		ViewTableRowAndCol(tableRow, tableCol)
	endif
	ShowValueOfCell(tableRow, tableCol)
End

Function ShowRowColButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Variable tableRow, tableCol
	GetTableRowAndCol(tableRow, tableCol)
	ViewTableRowAndCol(tableRow, tableCol)
	ShowValueOfCell(tableRow, tableCol)
	String tableName= GetUserData(ksPanelName,"",ksTableNameUserData)
	String win = StringFromList(0,tableName,"#")
	DoWindow/F $win
End

Function ImmediateShowCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	Variable/G root:Packages:ShowTableCell:viewImmediately = checked
	if( checked )
		Variable tableRow, tableCol
		GetTableRowAndCol(tableRow, tableCol)
		ViewTableRowAndCol(tableRow, tableCol)
		ShowValueOfCell(tableRow, tableCol)
	endif
End

Function FromTargetButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String table= GetUserData(ksPanelName,"",ksTableNameUserData)
	String tInfo = TableInfo(table,-2)
	// TABLENAME:Table0;HOST:;ROWS:128;COLUMNS:26;SELECTION:28,6,28,6,28,6;FIRSTCELL:0,0;LASTCELL:38,18;TARGETCELL:28,6;SHOWPARTS:0xff;ENTERING:1;ENTRYTEXT:0
	String selectionInfo = StringByKey("SELECTION", tInfo,":")	//28,6,28,6,28,6
	Variable fRow, fCol, lRow, lCol, tRow, tCol	// these are most like row and column point indices into the wave, never scaling values.
	sscanf selectionInfo, "%d,%d,%d,%d,%d,%d", fRow, fCol, lRow, lCol, tRow, tCol

	SetVariable row,win=$ksPanelName,value=_NUM:tRow	
	SetVariable col,win=$ksPanelName,value=_NUM:tCol	
End

Function ValueSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	ControlInfo/W=$ksPanelName real
	String realPart = S_value
	ControlInfo/W=$ksPanelName imag
	String imagPart = S_value
	SetValueOfSelectedCell(realPart,imagPart)
End

Function/WAVE SetValueOfSelectedCell(String realPart, String imagPart)
	String table= GetUserData(ksPanelName,"",ksTableNameUserData)
	[Variable tableRow, Variable tableCol] = TableTargetCell(table)
	[WAVE w, Variable pPoint, Variable qPoint, Variable rPoint, Variable sPoint] = TableRowAndColumnToWavePoints(table, tableRow, tableCol)
	Variable wt1 = WaveType(w,1)
	Variable isNumeric = wt1 == 1
	Variable isText = wt1 == 2
	Variable isReference = !isNumeric && !isText
	if( isNumeric )
		Variable isComplex = WaveType(w) & 0x1
		if( isComplex )
			WAVE/C cw = w
			Variable/C cmplxVal = cmplx(str2num(realPart),str2num(imagPart))
			cw[pPoint][qPoint][rPoint][sPoint]= cmplxVal
		else
			w[pPoint][qPoint][rPoint][sPoint] = str2num(realPart)
		endif
	elseif( isText )
		WAVE/T tw=w
		tw[pPoint][qPoint][rPoint][sPoint] = realPart
	else
		Beep // setting the value of a DFR or WAVEWAVE is a bad idea
	endif
	
	return w
End
