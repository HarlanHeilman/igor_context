#pragma rtGlobals=1		// Use modern global access method.
#pragma version=6.2		// shipped with Igor 6.2
#pragma Igorversion=6		// for WinName(0,1,1)

// 6.2, JP: Handles case where margin is 0 properly, and uses a function for use in an independent module, explicit graph name

// This macro can freeze the top graph at its current size. This means that when
// you use the graph in a page layout or when you print it will always be the current
// size. This is useful in some cases to help get WYSIWYG results.  
// 
Macro FreezeGraphSize(doFreeze)
	Variable doFreeze= 1
	Prompt doFreeze,"action",popup "freeze;unfreeze"	// 1 == freeze, 2 == unfreeze
	
	FreezeUnfreezeGraphSize("", doFreeze==1)
End

Function FreezeUnfreezeGraphSize(graphName, doFreeze)
	String graphName	// "" for top visible graph (if any)
	Variable doFreeze	// 0 for unfreeze, else freeze
	
	if( strlen(graphName) == 0 )
		graphName= WinName(0,1,1)	// top visible graph
	endif
	if( strlen(graphName) && WinType(graphName) == 1 )
		// compute margins. The new unfreeze logic needs them, too.
		GetWindow $graphName,gsize
		Variable gleft= V_left, gtop= V_top,gright= V_right,gbottom= V_bottom

		GetWindow $graphName,psize
		Variable pleft= V_left, ptop= V_top,pright= V_right,pbottom= V_bottom

		Variable leftMarginPoints= pleft-gleft
		if( leftMarginPoints == 0 )
			leftMarginPoints= -1	// None
		endif
		Variable topMarginPoints= ptop-gtop
		if( topMarginPoints == 0 )
			topMarginPoints= -1	// None
		endif
		Variable rightMarginPoints  = gright-pright
		if( rightMarginPoints == 0 )
			rightMarginPoints= -1	// None
		endif
		Variable bottomMarginPoints= gbottom-pbottom
		if( bottomMarginPoints == 0 )
			bottomMarginPoints= -1	// None
		endif
		
		Variable widthPoints, heightPoints
		if( doFreeze )
			widthPoints= pright-pleft
			heightPoints= pbottom-ptop
		else
			// 6.2: new unfreeze logic: if any margin is -1, keep it -1, else release the margin to Auto (0)
			// (the old logic was to always set the margins to 0 (Auto).
			if( leftMarginPoints != -1 )
				leftMarginPoints= 0	// auto
			endif
			if( topMarginPoints != -1 )
				topMarginPoints= 0
			endif
			if( rightMarginPoints != -1 )
				rightMarginPoints= 0
			endif
			if( bottomMarginPoints != -1 )
				bottomMarginPoints= 0
			endif
			
			widthPoints= 0	// auto plot (and thus graph) width
			heightPoints= 0	// auto plot (and thus graph) height
		endif
		ModifyGraph/W=$graphName margin(left)=leftMarginPoints,margin(top)=topMarginPoints
		ModifyGraph/W=$graphName margin(right)=rightMarginPoints,margin(bottom)=bottomMarginPoints
		ModifyGraph/W=$graphName width=widthPoints,height=heightPoints
	endif
End

