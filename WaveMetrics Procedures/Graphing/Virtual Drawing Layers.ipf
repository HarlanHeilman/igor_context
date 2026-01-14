#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later

#pragma version=9.03		// Shipped with Igor 9.03
#pragma IgorVersion=9

// Virtual drawing layers use group names to possibly delete and insert drawing objects
// as if they were in virtual drawing layers.
//
// Can be used in any window that supports the drawing tools; graphs, panels, layouts
// at the time of this writing.

Function HaveVirtualLayer(win, drawLayer, virtualLayer)
	String win, drawLayer, virtualLayer
	
	DrawAction/W=$win/L=$drawLayer getgroup=$virtualLayer
	// Sets V_flag to truth group exists.
	Variable hadGroup = V_flag
	return hadGroup
End

Function StartVirtualLayerRedraw(win, drawLayer, virtualLayer)
	String win, drawLayer, virtualLayer
	
	SetDrawLayer/W=$win $drawLayer // IMPORTANT: THIS CHANGES THE CURRENT DRAWING LAYER
	Variable hadVirtualLayer = HaveVirtualLayer(win, drawLayer, virtualLayer)
	if( hadVirtualLayer )
		DrawAction/W=$win/L=$drawLayer getgroup=$virtualLayer, delete, begininsert // this deletes the gStart, push, pop, and gStop, too.
	else
		DrawAction/W=$win/L=$drawLayer getgroup=_all_ // Stores first and last index of layer's objects in V_startPos and V_endPos
		DrawAction/W=$win/L=$drawLayer begininsert= V_endPos+1 // create virtual layer at the end (last-drawn = above other objects)
	endif
	SetDrawEnv/W=$win gstart,gname=$virtualLayer
	SetDrawEnv/W=$win push
	// The ending pop, gstop, and endInsert  are added by EndVirtualLayerRedraw()
	// which means that call to EndVirtualLayerRedraw() is required.
	return hadVirtualLayer
End

// Programmer does drawing between
// StartVirtualLayerRedraw() and EndVirtualLayerRedraw() calls.

Function EndVirtualLayerRedraw(win, drawLayer, virtualLayer, hadVirtualLayer)
	String win, drawLayer, virtualLayer
	Variable hadVirtualLayer // return value from StartVirtualLayerRedraw(), currently not used

	SetDrawEnv/W=$win pop
	SetDrawEnv/W=$win gstop
	DrawAction/W=$win/L=$drawLayer endinsert
End


// Similar to StartVirtualLayerRedraw() but leaves the objects in the virtual layer alone
// and appends new objects after them, just before the (expected) SetDrawEnv pop and gstop commands.
Function StartAppendToVirtualLayer(win, drawLayer, virtualLayer)
	String win, drawLayer, virtualLayer
	
	SetDrawLayer/W=$win $drawLayer // IMPORTANT: THIS CHANGES THE CURRENT DRAWING LAYER
	Variable hadVirtualLayer = HaveVirtualLayer(win, drawLayer, virtualLayer)
	if( hadVirtualLayer )
		DrawAction/W=$win/L=$drawLayer getgroup=$virtualLayer // DrawAction getgroup stores first and last index of named group in V_startPos and V_endPos 
		DrawAction/W=$win/L=$drawLayer begininsert=V_endPos-1 // inserts before the SetDrawEnv pop command
	else
		DrawAction/W=$win/L=$drawLayer getgroup=_all_
		DrawAction/W=$win/L=$drawLayer begininsert= V_endPos+1 // insert after last command for drawLayer
		SetDrawEnv/W=$win gstart,gname=$virtualLayer
		SetDrawEnv/W=$win push
	endif
	return hadVirtualLayer // if true, we don't want to end with SetDrawEnv pop;SetDrawEnv gstop
End

// Programmer does drawing between
// StartAppendToVirtualLayer() and EndAppendToVirtualLayer() calls.

Function EndAppendToVirtualLayer(win, drawLayer, virtualLayer, hadVirtualLayer)
	String win, drawLayer, virtualLayer
	Variable hadVirtualLayer // return value from StartAppendToVirtualLayer()
	
	if( !hadVirtualLayer )
		SetDrawEnv/W=$win pop
		SetDrawEnv/W=$win gstop
	endif
	DrawAction/W=$win/L=$drawLayer endinsert
End

// Similar to StartVirtualLayerRedraw() but leaves the objects in the virtual layer alone
// and inserts new objects before (below) them,
// just after the (expected) SetDrawEnv gstart and push commands.
Function StartInsertIntoVirtualLayer(win, drawLayer, virtualLayer)
	String win, drawLayer, virtualLayer
	
	SetDrawLayer/W=$win $drawLayer // IMPORTANT: THIS CHANGES THE CURRENT DRAWING LAYER
	Variable hadVirtualLayer = HaveVirtualLayer(win, drawLayer, virtualLayer)
	if( hadVirtualLayer )
		DrawAction/W=$win/L=$drawLayer getgroup=$virtualLayer // DrawAction getgroup stores first and last index of named group in V_startPos and V_endPos 
		DrawAction/W=$win/L=$drawLayer begininsert=V_startPos+2 // inserts before command after SetDrawEnv push
	else
		DrawAction/W=$win/L=$drawLayer begininsert= 0 // insert before first command for drawLayer
		SetDrawEnv/W=$win gstart,gname=$virtualLayer
		SetDrawEnv/W=$win push
	endif
	return hadVirtualLayer // if true, we don't want to end with SetDrawEnv pop;SetDrawEnv gstop
End

// Programmer does drawing between
// StartInsertIntoVirtualLayer() and EndInsertIntoVirtualLayer() calls.

Function EndInsertIntoVirtualLayer(win, drawLayer, virtualLayer, hadVirtualLayer)
	String win, drawLayer, virtualLayer
	Variable hadVirtualLayer // return value from StartInsertIntoVirtualLayer()
	
	if( !hadVirtualLayer )
		SetDrawEnv/W=$win pop
		SetDrawEnv/W=$win gstop
	endif
	DrawAction/W=$win/L=$drawLayer endinsert
End


Function InsertEmptyVirtualLayer(win, drawLayer, virtualLayer, beforeVirtualLayer)
	String win, drawLayer, virtualLayer, beforeVirtualLayer

	SetDrawLayer/W=$win $drawLayer // IMPORTANT: THIS CHANGES THE CURRENT DRAWING LAYER
	Variable hadBeforeVirtualLayer = HaveVirtualLayer(win, drawLayer, beforeVirtualLayer)
	if( hadBeforeVirtualLayer )
		DrawAction/W=$win/L=$drawLayer getgroup=$beforeVirtualLayer
		DrawAction/W=$win/L=$drawLayer begininsert=V_startPos // inserts before this virtual layer starts
	else
		// before virtual layer doesn't exist, insert at very start (bottom) of drawing layer
		DrawAction/W=$win/L=$drawLayer begininsert=0
	endif
	SetDrawEnv/W=$win gstart,gname=$virtualLayer
//	SetDrawEnv/W=$win push, pop, gstop // result was pop, push, gstop, because the order isn't preserved, just whether push or pop were specified.
	SetDrawEnv/W=$win push
	SetDrawEnv/W=$win pop
	SetDrawEnv/W=$win gstop
	DrawAction/W=$win/L=$drawLayer endinsert
	return hadBeforeVirtualLayer
End


// Removes all objects from the virtual layer,
// but keeps the virtual layer (group) itself
// along with the push and pop commands.

Function EmptyVirtualLayer(win, drawLayer, virtualLayer)
	String win, drawLayer, virtualLayer
	Variable hadVirtualLayer = StartVirtualLayerRedraw(win, drawLayer, virtualLayer)
	EndVirtualLayerRedraw(win, drawLayer, virtualLayer, hadVirtualLayer)
End

// If the named virtual layer does not yet exist,
// appends an empty virtual layer at the end (top) of the drawing layer's drawing list.
//
// If the virtual layer does exist, it is emptied without changine its position.
Function AppendEmptyVirtualLayer(win, drawLayer, virtualLayer)
	String win, drawLayer, virtualLayer

	EmptyVirtualLayer(win, drawLayer, virtualLayer)
End

// Can be used to initially CREATE one or more virtual layers,
// listed in back-to-front drawing order.
Function EmptyVirtualLayers(win, drawLayer, virtualLayersList)
	String win, drawLayer, virtualLayersList

	Variable i, n=ItemsInList(virtualLayersList)
	for(i=0; i<n; i+=1)
		String virtualLayer= StringFromList(i,virtualLayersList)
		EmptyVirtualLayer(win, drawLayer, virtualLayer)
	endfor
End


// Unlike EmptyVirtualLayer, this completely deletes the named virtual layer (group).
Function DeleteVirtualLayer(win, drawLayer, virtualLayer)
	String win, drawLayer, virtualLayer

	DrawAction/W=$win/L=$drawLayer getgroup=$virtualLayer, delete
	// Sets V_flag to truth group exists.
	Variable hadGroup = V_flag
	return hadGroup
End

Function DeleteVirtualLayers(win, drawLayer, virtualLayersList)
	String win, drawLayer, virtualLayersList

	Variable i, n=ItemsInList(virtualLayersList)
	for(i=0; i<n; i+=1)
		String virtualLayer= StringFromList(i,virtualLayersList)
		DeleteVirtualLayer(win, drawLayer, virtualLayer)
	endfor
End


// Debugging
// #define VIRTUAL_LAYER_DEBUGGING to enable these menus:
// SetIgorOption poundDefine=VIRTUAL_LAYER_DEBUGGING

#ifdef VIRTUAL_LAYER_DEBUGGING

// For now, these debugging items work only in a graph without controls.

Menu "Graph"
	"-"
	"Toggle Virtual Drawing Layer Debugging",/Q, ToggleVirtualLayerDebugControls(WinName(0,1,1))
	"-"
End

Function ToggleVirtualLayerDebugControls(String graphName)

	if( WinType(graphName) != 1 )
		graphName= WinName(0,1,1)
	endif
	if( strlen(graphName) == 0 )
		DoAlert 0, "Expected a graph window"
		return NaN
	endif
	ControlInfo/W=$graphName progLayer // PopupMenu
	if( V_Flag )
		// have the progLayer control, remove it and the rest
		KillControl/W=$graphName progLayer
		KillControl/W=$graphName commands
		ControlBar/W=$graphName 0
	else
		// don't have the progLayer control, add it and the rest
		ControlBar/W=$graphName 38
	
		PopupMenu progLayer,win=$graphName,pos={262.00,9.00},size={106.00,20.00},title="Layer"
		// Guess that ProgAxes is the most populated drawing layer (Polar Graph package)
#if IgorVersion() >= 10
		PopupMenu progLayer,win=$graphName,mode=3,popvalue="ProgAxes",value=#"\"ProgBack;UserBack;ProgAxes;UserAxes;ProgFront;UserFront;ProgTop;UserTop;Overlay;\""
#else
		PopupMenu progLayer,win=$graphName,mode=3,popvalue="ProgAxes",value=#"\"ProgBack;UserBack;ProgAxes;UserAxes;ProgFront;UserFront;Overlay;\""
#endif
		// TO DO: Get most-populated drawing layer with virtual drawing layers
		PopupMenu commands,win=$graphName,pos={392.00,9.00},size={130.00,20.00}
		PopupMenu commands,win=$graphName,title="Drawing Commands"
		PopupMenu commands,win=$graphName,mode=0,value=#"VirtualLayerCommands(WinName(0,1,1),ChosenDrawingLayer(WinName(0,1,1)))"
	endif
	
	return 0
End

Function/S ChosenDrawingLayer(String win)

	String layer=""
	ControlInfo/W=$win progLayer
	if( V_Flag )
		layer = S_Value
	endif
	return layer
End

Function/S VirtualLayerCommands(String win, String drawLayer)

	String cleaned= ""
	if( strlen(drawLayer) )
		DrawAction/W=$win/L=$drawLayer commands // stored in S_recreation
		// eliminate lines like "// ;ITEMNO:1;"
		cleaned= GrepList(S_recreation, "^// ;", 1, "\r")
		cleaned = ReplaceString("\r",cleaned,";")
	endif
	return cleaned
End
#endif