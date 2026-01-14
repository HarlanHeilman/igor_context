#pragma rtGlobals=1		// Use modern global access method.
#pragma version=6.13

#include <Readback ModifyStr>

// #include <Extract Contours As Waves>
//
// Contour traces are comprised of X and Y waves that have no data folder,
// and thus can't be accessed for analysis or inspection.
//
// This procedure file adds menu items to the Graph menu which allow you
// to extract a copy of the trace X and Y waves, either singly into the current
// data folder or all at once into a subdatafolder.
//
// The extracted traces can be displayed in a new or existing table or graph.
//
// Each X Y wave pair contains all of the contour traces for one level.
// Disjoint sections of the trace are separated by a NaN.
// To find the location of these NaNs use the included WMFindNaNValue() routine.
//
// 5.04:	Fixed WMDuplicateDisplayContourWaves() to work with liberally-named contour data, stored trace color into y wave's note.
// 6.13:	Menus now work when this file is included into an independent module.
//			This required rewriting the menu action as function calls.
//			The old Procs remain for compatibility.
//

Menu "Graph"
	"Extract One Contour Trace", /Q,	WMExtractOneContourTraceDialog()
	"Extract All Contour Traces", /Q,	WMExtractAllContourTracesDialog()
End

Function WMExtractOneContourTraceDialog()
	String traceName
	String displayWhere="in new graph"

	Prompt traceName,"Contour Trace",popup,TraceNameList("",";",2)	// only contour traces
	Prompt displayWhere, "Display Trace", popup, "nowhere;in new graph;in new table;"+WinList("*",";","WIN:3")	// graphs and tables

	DoPrompt "Extract One Contour Trace", traceName, displayWhere
	if( V_Flag == 0 )
		fWMExtractOneContourTrace(traceName, displayWhere)
	endif
End

Proc WMExtractOneContourTrace(traceName, displayWhere)
	String traceName
	Prompt traceName,"Contour Trace",popup,TraceNameList("",";",2)	// only contour traces
	String displayWhere="in new graph"
	Prompt displayWhere, "Display Trace", popup, "nowhere;in new graph;in new table;"+WinList("*",";","WIN:3")	// graphs and tables

	fWMExtractOneContourTrace(traceName, displayWhere)
End

Function fWMExtractOneContourTrace(traceName, displayWhere)
	String traceName, displayWhere
	
	String contourWin= WinName(0,1)
	String names= WMDuplicateTraceWave(contourWin,traceName)
	String xName= StringFromList(0,names,",")
	String yName= StringFromList(1,names,",")
	if( CmpStr(displayWhere,"nowhere") == 0 )
		Print traceName, " copied as waves " + xName + " and " + yName
	endif
	if( CmpStr(displayWhere,"in new graph") == 0 )
		Display $yName vs $xName
		AutoPositionWindow/E/M=1/R=$contourWin
	endif
	if( CmpStr(displayWhere,"in new table") == 0 )
		Edit $xName, $yName
		AutoPositionWindow/E/M=1/R=$contourWin
	endif
	if( FindListItem(displayWhere, "nowhere;in new graph;in new table;") < 0 )
		if( WinType(displayWhere) == 1 ) // graph
			AppendToGraph/W=$displayWhere $yName vs $xName
		endif
		if( WinType(displayWhere) == 2 ) // table
			AppendToTable/W=$displayWhere $xName, $yName
		endif
	endif
End

Function WMExtractAllContourTracesDialog()
	String contourNameStr
	String subDataFolderStr	= "extractedContours" // "" for current data folder, else new (or existing) sub data folder
	String displayWhere="in new graph"

	Prompt contourNameStr,"Contour Plot",popup,ContourNameList("",";")
	Prompt subDataFolderStr,"Create in Subfolder (\"\" for current folder)"
	Prompt displayWhere, "Display Trace", popup, "nowhere;in new graph;in new table;"+WinList("*",";","WIN:3")	// graphs and tables

	DoPrompt "Extract All Contour Traces", contourNameStr, subDataFolderStr, displayWhere
	if( V_Flag == 0 )
		fWMExtractAllContourTraces(contourNameStr, subDataFolderStr, displayWhere)
	endif
End


Proc WMExtractAllContourTraces( contourNameStr, subDataFolderStr, displayWhere)
	String contourNameStr
	String subDataFolderStr	= "extractedContours" // "" for current data folder, else new (or existing) sub data folder
	Prompt contourNameStr,"Contour Plot",popup,ContourNameList("",";")
	Prompt subDataFolderStr,"Create in Subfolder (\"\" for current folder)"
	String displayWhere="in new graph"
	Prompt displayWhere, "Display Trace", popup, "nowhere;in new graph;in new table;"+WinList("*",";","WIN:3")	// graphs and tables

	fWMExtractAllContourTraces(contourNameStr, subDataFolderStr, displayWhere)
End

Function fWMExtractAllContourTraces(contourNameStr, subDataFolderStr, displayWhere)
	String contourNameStr, subDataFolderStr, displayWhere
	
	String contourWin= WinName(0,1)
	if( CmpStr(displayWhere,"nowhere") == 0 )
		displayWhere= ""
	endif
	if( CmpStr(displayWhere,"in new graph") == 0 )
		Display
		displayWhere= WinName(0,1)
		AutoPositionWindow/E/M=1/R=$contourWin $displayWhere
	endif
	if( CmpStr(displayWhere,"in new table") == 0 )
		Edit
		displayWhere= WinName(0,2)
		AutoPositionWindow/E/M=1/R=$contourWin $displayWhere
	endif
	Variable n= WMDuplicateDisplayContourWaves(contourWin, contourNameStr, subDataFolderStr,displayWhere)

	if( strlen(displayWhere) == 0 )
		Variable len= strlen(subDataFolderStr)
		if( len )
			Printf "copied %d traces into %d waves in %s\r", n, n*2, subDataFolderStr
		else
			Printf "copied %d traces into %d waves\r", n, n*2
		endif
	endif
End

Function WMDuplicateDisplayContourWaves(graphNameStr, contourNameStr, subDataFolderStr, appendToThisWindow)
	String graphNameStr, contourNameStr, subDataFolderStr, appendToThisWindow
	
	String df= GetDataFolder(1)
	if( strlen(subDataFolderStr) )
		NewDataFolder/O/S $subDataFolderStr
	endif
	
	// the traces that belong to a contour are named programmatically based on level and contour instance name	
	String info= ContourInfo(graphNameStr, contourNameStr, 0)
	String tracesFormat= StringByKey("TRACESFORMAT", info)
	String contourLevels= StringByKey("LEVELS", info)	// comma-separated list
	
	// possibly display the traces
	Variable wType= 0	// nowhere
	if( strlen(appendToThisWindow) )
		wType= WinType(appendToThisWindow)
	endif

	String cleanedContourName=ReplaceString("'", contourNameStr, "") // removed of any enclosing single quotes
	Variable i, numTraces= ItemsInList(contourLevels, ",")
	for( i=0; i <  numTraces; i+= 1 )
		Variable level= str2num(StringFromList(i,contourLevels,","))
		String traceNameStr
		sprintf traceNameStr, tracesFormat, cleanedContourName, level
		String names= WMDuplicateTraceWave(graphNameStr,traceNameStr)
		Wave wx= $StringFromList(0,names,",")
		Wave wy= $StringFromList(1,names,",")
		
		// 5.04 - put the trace color into the wy wave's note:
		Variable red, green, blue
		Variable gotColors= WMGetTraceRGB(graphNameStr,traceNameStr, red, green, blue)
		if( gotColors )
			String rgbstr
			sprintf rgbstr, ";RED:%d;GREEN:%d;BLUE:%d;", red, green, blue
			Note wy, rgbstr	// Append the note
		endif
		if( wType == 1 ) // graph
			AppendToGraph/W=$appendToThisWindow wy vs wx
			if( gotColors )
				// copy the color, too.
				String newTraceName= StringFromList(1,names,",")
				ModifyGraph/W=$appendToThisWindow rgb($newTraceName)=(red,green,blue)
			endif
		endif
		if( wType == 2 ) // table
			AppendToTable/W=$appendToThisWindow wx, wy
		endif
	endfor
	SetDataFolder df
	return numTraces
End

Function/S WMDuplicateTraceWave(graphNameStr,traceNameStr)
	String graphNameStr,traceNameStr
	
	Wave w=  TraceNameToWaveRef(graphNameStr,traceNameStr)
	String outYName= CleanupName(NameOfWave(w)[0,28]+".y",1)	// data=level.y
	Duplicate/O w, $outYName

	Wave w=  XWaveRefFromTrace(graphNameStr,traceNameStr)
	String outXName= NameOfWave(w)	// data=level.x
	Duplicate/O w, $outXName
	
	return outXName + "," + outYName
End

Function WMGetTraceRGB(graphNameStr,traceNameStr, red, green, blue)
	String graphNameStr,traceNameStr
	Variable &red, &green, &blue

	Wave/Z w=  TraceNameToWaveRef(graphNameStr,traceNameStr)
	if( WaveExists(w) )
		String info= TraceInfo(graphNameStr,traceNameStr,0)
		red= GetNumFromModifyStr(info,"rgb","(", 0)
		green= GetNumFromModifyStr(info,"rgb","(", 1)
		blue= GetNumFromModifyStr(info,"rgb","(", 2)
		return 1
	endif
	return 0
End


Function WMFindNaNValue(w, startingIndex)
	Wave w		// real (not complex) one-dimensional wave
	Variable startingIndex	// usually 0 or one more than the index of the previously found NaN
	
	Variable i, n= numpnts(w)
	for( i=startingIndex; i < n; i += 1 )
		if (numtype(w[i]) == 2 )	// found NaN
			return i				// here
		endif
	endfor
	return -1	// not found indicator
End