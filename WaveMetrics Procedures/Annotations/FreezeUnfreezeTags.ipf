#pragma rtGlobals=1		// Use modern global access method.
#pragma IgorVersion=5.0	// Requires Igor 5
//
// FreezeOrUnfreezeTags -- makes the top graph's tags moveable or frozen in position.
// Useful for repositioning contour labels.
//
Menu "Graph", dynamic
	WM_FreezeOrUnFreezeTagsMenu(), /Q, WM_FreezeOrUnFreezeTags()
End

// if any tag is frozen, the menu is "Un-freeze Tag Positions"
// otherwise (all are moveable), the menu is "Freeze Tag Positions"
Function/S WM_FreezeOrUnFreezeTagsMenu()

	Variable isFrozen=WM_ATagIsFrozen("")
	String menuStr=  "(Freeze Tag Positions"
	switch( isFrozen )
		case 0:
			menuStr= "Freeze Tag Positions"
			break
		case 1:
			menuStr= "Un-freeze Tag Positions"
			break
	endswitch
	return menuStr
End

// returns -1 if no tags in the window
// returns 0 if all the tags are moveable
// returns 1 if ANY tag is frozen
Function WM_ATagIsFrozen(win)
	String win

	if( WinType(win) != 1 )
		return -1
	endif
	String list = AnnotationList(win)
	Variable numAnnotations = ItemsInList( list )
	Variable i, numTags=0, isFrozen=0
	for(i=0; i < numAnnotations; i+=1)
		String anno = StringFromList( i, list )
		String info = AnnotationInfo(win, anno )
		String type = StringByKey( "TYPE", info )
		if( CmpStr( type, "Tag" ) == 0 )
			numTags += 1
			String flags = StringByKey( "FLAGS", info )
			if( NumberByKey( "Z", flags, "=", "/" ) )
				isFrozen = 1	// at least one tag is frozen
				break			// and we don't need to look any further
			endif
		endif
	endfor
	return (numTags == 0 )? -1 :  isFrozen
End

Function WM_FreezeOrUnFreezeTags()

	String list = AnnotationList("")
	Variable isFrozen=WM_ATagIsFrozen("")
	if( isFrozen != -1 )
		Variable freeze= 1-isFrozen	// toggle /Z
		Variable i, numAnnotations = ItemsInList( list )
		for(i=0; i < numAnnotations; i+=1)
			String anno = StringFromList( i, list )
			String info = AnnotationInfo( "", anno )
			String type = StringByKey( "TYPE", info )
			if( CmpStr( type, "Tag" ) == 0 )
				Tag/C/N=$anno/Z=(freeze)
			endif
		endfor
	endif
End
