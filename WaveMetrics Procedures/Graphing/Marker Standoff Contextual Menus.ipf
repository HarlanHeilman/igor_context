#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version = 9.03			// will ship with Igor 9.03
#pragma IgorVersion = 8		// mstandoff added in Igor 8 LH170219

#include <Graph Utility Procs>

// Marker Standoff Contextual Menus

// 0.01 is useful to draw lines up to but not behind unfilled "hollow" markers
StrConstant ksStandoffs = "0;0.01;0.25;0.5;0.75;1.0;1.5;2.0;3.0;4.0;5.0;6.0;7.0;8.0;9.0;"

Menu "TracePopup", dynamic
	Submenu "Marker Standoff"
		ItemsIfLinesAndMarkersTrace(), /Q, SetMStandoff()
	End
End

Menu "AllTracesPopup", dynamic
	Submenu "All Marker Standoffs"
		ItemsIfAnyAppropriateTrace(), /Q, SetAllMStandoffs()
	End
End

Function/S ItemsIfLinesAndMarkersTrace()

	String items="" // disappearing items
	GetLastUserMenuInfo
	if( strlen(S_traceName) > 0 ) // a trace was selected when the menu was updated
		// see if the trace is mode 4 (line+markers)
		String info = traceInfo(S_graphName, S_traceName,0)
		String modeStr = WMGetRECREATIONInfoByKey("mode(x)", info)
		Variable mode = str2num(modeStr)
		if( mode == 4 )
			String mstandoffStr = WMGetRECREATIONInfoByKey("mstandoff(x)", info)
			Variable mstandoff = str2num(mstandoffStr)
			Variable i, n= ItemsInList(ksStandoffs)
			Variable foundMStandoff = 0
			for(i=0; i<n; i+=1 )
				String item= StringFromList(i,ksStandoffs)
				Variable num = str2num(item)
				if( num == mstandoff )
					item += "!" + num2char(18) // checked
					foundMStandoff= 1
				endif
				items += item + ";"
			endfor
			if( !foundMStandoff )
				items += "-;"+mstandoffStr+"!" + num2char(18) // checked
			endif
		else
			items="(_not lines and markers mode_"
		endif	
	else
			items="(_no trace selected_"
	endif
	
	return items
End

Function SetMStandoff()
	GetLastUserMenuInfo // parse S_value	The menu item text
	Variable mstandoff= str2num(S_Value) // tolerates ending !... text
	ModifyGraph/W=$S_graphName mstandoff($S_traceName) = mstandoff
End


Function/S ItemsIfAnyAppropriateTrace()
	String items="" // disappearing items
	Variable foundLinesAndMarkersMode= 0
	GetLastUserMenuInfo
	if( strlen(S_graphName) )
		String traces = TraceNameList(S_graphName,";",1+2+4) // visible normal or contour traces
		Variable i, n=ItemsInList(traces)
		for(i=0; i<n; i+=1 )
			String traceName = StringFromList(i,traces)
			// see if the trace is mode 4 (line+markers)
			String info = traceInfo(S_graphName, traceName,0)
			String modeStr = WMGetRECREATIONInfoByKey("mode(x)", info)
			Variable mode = str2num(modeStr)
			if( mode == 4 )
				foundLinesAndMarkersMode = 1
				break
			endif
		endfor
		if( foundLinesAndMarkersMode )
			items= ksStandoffs
		elseif( n == 0 )
			items="(_no traces_"
		else
			items="(_no traces using lines and markers mode_"
		endif
	endif
	return items
End

Function SetAllMStandoffs()
	GetLastUserMenuInfo // parse S_value	The menu item text
	Variable mstandoff= str2num(S_Value) // tolerates ending !... text

	if( strlen(S_graphName) )
		String traces = TraceNameList(S_graphName,";",1+2+4) // visible normal or contour traces
		Variable i, n=ItemsInList(traces)
		for(i=0; i<n; i+=1 )
			String traceName = StringFromList(i,traces)
			// see if the trace is mode 4 (line+markers)
			String info = traceInfo(S_graphName, traceName,0)
			String modeStr = WMGetRECREATIONInfoByKey("mode(x)", info)
			Variable mode = str2num(modeStr)
			if( mode == 4 )
				ModifyGraph/W=$S_graphName mstandoff($traceName) = mstandoff
			endif
		endfor
	endif
End
