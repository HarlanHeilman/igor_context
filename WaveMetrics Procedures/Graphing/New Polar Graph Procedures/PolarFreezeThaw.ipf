#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=9.021		// shipped with Igor 9.02
#pragma IgorVersion=9

#include <New Polar Graphs>, version >= 9.02 // for WMPolarDisconnectGraph

// Use Override Constant kPolarFreezeSizeToo=0 in the main procedure window
// to allow "frozen" polar graphs to resize
Constant kPolarFreezeSizeToo = 1

Menu "Graph",dynamic
	"-"
	WMPolarFreezeMenu("Freeze top Polar Graph"), /Q, FreezePolarGraph(WinName(0,1))
	WMPolarThawMenu("Thaw top Polar Graph"), /Q, ThawPolarGraph(WinName(0,1))
	"Freeze all Polar Graphs", /Q, FreezeAllPolarGraphs()
	"Thaw all Polar Graphs", /Q, ThawAllPolarGraphs()
	"-"
End

Function/S WMPolarFreezeMenu(menuText)
	String menuText

	if( !WMPolarIsPolarGraph(WinName(0,1)) )
		menuText= ""	// disappearing item if not a polar graph
	endif
	return menuText
End

Function/S WMPolarThawMenu(menuText)
	String menuText

	if( !WMPolarIsFrozenPolarGraph(WinName(0,1)) )
		menuText= ""	// disappearing item if it is a polar graph (already "thawed")
	endif
	return menuText
End

Function WMPolarIsFrozenPolarGraph(graphName)
	String graphName
	
	if( strlen(graphName) == 0 )
		return 0 // nope
	endif
	String dfName= GetUserData(graphName, "", "frozenPolarSettings")
	return strlen(dfName) > 0
End


Function FreezePolarGraph(polarGraphName)
	String polarGraphName

	if( !WMPolarIsPolarGraph(polarGraphName) )
		return -1 // error
	endif
	
	String dfName = WMPolarDisconnectGraph(polarGraphName)

	// store the dfName in a differently named userdata where it can be restored from.
	SetWindow $polarGraphName userdata(frozenPolarSettings)=dfName
	
	// alter the window title to show it is frozen.
	GetWindow $polarGraphName wtitle
	String title= "[Frozen] " + ReplaceString("[Frozen] ", S_Value, "")
	DoWindow/T $polarGraphName, title
	
	if( kPolarFreezeSizeToo )
		// The size is also frozen because things won't resize nicely if the polar graph code can't fix things up.
		GetWindow $polarGraphName psize	// points sizes of plot area
		Variable pWidth = abs(V_right-V_left)
		Variable pHeight = abs(V_bottom-V_top)
		ModifyGraph/W=$polarGraphName width=pWidth,height=pHeight
	endif
End

Function ThawPolarGraph(graphName)
	String graphName

	if( !WMPolarIsFrozenPolarGraph(graphName) )
		return -1 // error
	endif
	
	String dfName= GetUserData(graphName, "", "frozenPolarSettings")

	WMPolarReconnectGraph(graphName, dfName)	// it is a polar graph once more.
	// remove the frozen setting.
	SetWindow $graphName userdata(frozenPolarSettings)=""

	// alter the window title to show it is thawed.
	GetWindow $graphName wtitle
	String title= ReplaceString("[Frozen] ", S_Value, "")
	DoWindow/T $graphName, title
	
	if( kPolarFreezeSizeToo )
		// thaw the graph size, too.
		ModifyGraph/W=$graphName width={Plan,1,HorizCrossing,VertCrossing}, height=0
	endif
End

Function FreezeAllPolarGraphs()

	String graphName
	Variable i=0, frozen= 0
	do
		graphName= WinName(i, 1)
		if( strlen(graphName) == 0 )
			break
		endif
		if( WMPolarIsPolarGraph(graphName) )
			FreezePolarGraph(graphName)
			frozen += 1
		endif
		i += 1
	while(1)
	Print "Froze "+num2istr(frozen)+" polar graphs"
End


Function ThawAllPolarGraphs()
	String graphName
	Variable i=0, thawed= 0
	do
		graphName= WinName(i, 1)
		if( strlen(graphName) == 0 )
			break
		endif
		if( WMPolarIsFrozenPolarGraph(graphName) )
			ThawPolarGraph(graphName)
			thawed += 1
		endif
		i += 1
	while(1)
	Print "Thawed "+num2istr(thawed)+" polar graphs"
End
