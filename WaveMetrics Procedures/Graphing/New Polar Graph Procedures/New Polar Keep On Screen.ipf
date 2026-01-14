#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=9.03	// Revised for Igor 9.03

// Part of the New Polar Graphs procedures
// 7/21/2000, JP: Version 4
// 7/9/2002, JP, Version 4.06
// 7/9/2002, JP, Version 6.13
// 8/6/2014, JP, Version 6.35: WMPolarKeepWindowOnScreen works even if win no longer exists.
// 8/6/2014, JP, Version 9.03: WMPolarIntersectRects and WMPolarUnionRects allow any of left, top, right, or bottom to be NaN.

// WMPolarKeepWindowOnScreen is used for polar graphs with Plan mode on.
// WMPolarKeepWindowOnScreen works only with HorizCrossing,VertCrossing axes,
// and is called from the polar graph's window hook during the resize event.
Function WMPolarKeepWindowOnScreen(win)
	String win
	
	if( strlen(win) == 0 )
		return -1
	endif
	DoWindow $win
	if( V_Flag == 0 )	// 6.35
		return -1
	endif
	
	SetWindow $win userdata(WMPolarKeepWindowOnScreen)= ""	// allow another queued call to WMPolarKeepWindowOnScreen() by WMPolarGraphHook().

	Variable screenLeft, screenTop, screenRight, screenBottom	// points
	Variable screen= WMPolarBestScreenCornersForWin(win,screenLeft, screenTop, screenRight, screenBottom)
	
	// what we actually do is make sure the window will fit inside the given screen, with room to spare
	screenLeft += 5
	screenTop += 40
	screenRight -= 5
	screenBottom -= 5
	
	Variable screenWidth= screenRight-screenLeft
	Variable screenHeight= screenBottom-screenTop
	
	GetWindow $win wsize		// content area in points
	Variable winLeft= V_Left
	Variable winTop= V_Top
	Variable winRight= V_Right
	Variable winBottom= V_Bottom
	
	Variable winWidth= winRight-winLeft
	Variable winHeight= winBottom-winTop
	Variable tooBig=0
	Variable winAspect= winWidth/winHeight	// before limited by screen.
	
	if( winWidth > screenWidth )
		winWidth= screenWidth
		tooBig=1
	endif
	if( winHeight > screenHeight )
		winHeight= screenHeight
		tooBig=1
	endif
	
	if( !tooBig )
		return 0
	endif

	Variable screenAspect= screenWidth/screenHeight 

	//  A graph's Plan, Aspect mode will alter MoveWindow coords; prepare how it will respond.
	String widthHeightMode=WMPolarGraphSizeModes(win)	// "" if not a graph
	if( ItemsInList(widthHeightMode) == 1 )	// else, one of not a graph, auto mode (nothing to change), or both width and height are constrained (too complex)
		// this code works only with swapXY off and with Plan 1 VertCrossing,HorizCrossing mode.
		if( strsearch(widthHeightMode,"Plan",0) >= 0 ) 
			if( winAspect > screenAspect )		// graph wants to be more landscapish than the screen, limit by width
				ModifyGraph/W=$win width=0, height={Plan,1,VertCrossing,HorizCrossing}
			else	
				ModifyGraph/W=$win width={Plan,1,HorizCrossing,VertCrossing},height=0	// graph wants to be more portraitish than the screen, limit by height
			endif
		endif
	endif
	MoveWindow/W=$win winLeft, winTop, winLeft+winWidth, winTop+winHeight
	return 1
End

Function/S WMPolarGraphSizeModes(win)
	String win
	
	if( WinType(win) != 1 )
		return ""
	endif
	
	String modes=""
	
	String code= WinRecreation(win,1+4)	// style, don't revert to default mode in case the tools are active

	// search for height={ and width={, otherwise the height is automatic or fixed
	Variable hpos= strsearch(code,"height={",0) // height={perUnit,0,left}, height={Plan,1,left,bottom}, height={Aspect,1}
	Variable pos, theEnd,line=0, lines= ItemsInList(code,"\r")
	Variable width, height, bracket, posHeight, posWidth,done=0
	String searchFor= "ModifyGraph/Z"
	String text
	do
		text= StringFromList(line, code,"\r")
		pos= strsearch(text, searchFor,0)
		if( pos >= 0 )	// a ModifyGraph line (not a control or other thing that might have height={ in it.)
			// 	ModifyGraph/Z margin(left)=1,margin(bottom)=1,margin(top)=1,margin(right)=1,width={Plan,1,bottom,left}
			// search for height={
			pos += strlen(searchFor)
			posHeight= strsearch(text,"height={",pos)
			if( posHeight >= 0 )
				bracket= strsearch(text,"}",posHeight)
				if( strlen(modes) )
					modes += ";"
				endif
				modes += text[posHeight,bracket]
				done =  done %| 1
			else
				posHeight= strsearch(text,"height=",pos)
				if ( posHeight > 0)	// height= dd
					sscanf text[posHeight,inf], "height=%d", height
					if( V_Flag == 1 )
						if( strlen(modes) )
							modes += ";"
						endif
						modes += "height="+num2str(height)
						done =  done %| 1
					endif
				endif
			endif
			// search for width={
			posWidth= strsearch(text,"width={",pos)
			if( posWidth >= 0 )
				bracket= strsearch(text,"}",posWidth)
				if( strlen(modes) )
					modes += ";"
				endif
				modes += text[posWidth,bracket]
				done =  done %| 2
			else
				posWidth= strsearch(text,"width=",pos)
				if ( posWidth > 0)	// height= dd
					sscanf text[posWidth,inf], "width=%d", width
					if( V_Flag == 1 )
						if( strlen(modes) )
							modes += ";"
						endif
						modes += "width="+num2str(width)
						done =  done %| 2
					endif
				endif
			endif
		endif
		if( done  == 3)	// found both
			break
		endif
		line += 1
	while ( line < lines )

	return SortList(modes,";",1)	// width first, if present.
End

// locate the screen the window is (mostly) on, and get that screen's coordinates (in points)
Function WMPolarBestScreenCornersForWin(win,left, top, right, bottom)
	String win
	Variable &left, &top, &right	, &bottom	// points

	Variable nscreens= NumberByKey(" NSCREENS",IgorInfo(0),":",";")	// note leading space
	if( numtype(nscreens) != 0 )
		nscreens= NumberByKey("NSCREENS",IgorInfo(0),":",";")
	endif
	Variable bestScreen= 1	// assume only one screen
	if( nscreens > 1 )
		bestScreen= 0	// this will be the screen number that contains the largest area of the window.
		Variable bestArea= 0
		
		Variable screenNum= 1	// 1 is the first device (not necessarily the menu bar screen), 2 is the second....
		Variable theArea
		
		GetWindow $win wsize		// points
		// the window must be off-screen, or maybe minimized or maybe the content is offscreen but the title bar isn't.
		// so we inflate the window by a little bit
		Variable winLeft= V_Left - 5
		Variable winTop= V_Top - 25	// window title + a little more
		Variable winRight= V_Right + 5
		Variable winBottom= V_Bottom + 5
		do
			if( 0 == WMPolarScreenCorners(screenNum,left, top, right, bottom) )	// no such screen, we've seen them all now
				break
			endif
			
			theArea= WMPolarIntersectRects(left, top, right, bottom, winLeft, winTop, winRight, winBottom)
			if( theArea > bestArea )
				bestScreen= screenNum
				bestArea= theArea
			endif
			
			screenNum += 1	// not main screen, try next one
		while( 1 )
		
	endif
	
	WMPolarScreenCorners(bestScreen,left, top, right, bottom)
	return bestScreen		// returns number of screen as reported in IgorInfo(0), or 0 if the window isn't on any of them.
End

Function WMPolarIntersectRects(left, top, right, bottom, winLeft, winTop, winRight, winBottom)
	Variable &left, &top, &right, &bottom, winLeft, winTop, winRight, winBottom
	
	// 9.03: Added NaN protection
	if( numtype(left) == 2 )
		left= winLeft
	endif
	if( numtype(top) == 2 )
		top= winTop
	endif
	if( numtype(right) == 2 )
		right= winRight
	endif
	if( numtype(bottom) == 2 )
		bottom= winBottom
	endif

	// Compute horizontal overlap
	Variable temp
	if( left > right )
		temp=left
		left= right
		right=temp
	endif
	if( winLeft > winRight )
		temp=winLeft
		winLeft= winRight
		winRight=temp
	endif
	
	// make left, right the left-most rectangle
	if( left > winLeft )
		temp=winLeft
		winLeft= left
		left=temp
		temp=winRight
		winRight= right
		right=temp
	endif
	
	// check for horizontal overlap; if none, there is no intersection
	if( right <= winLeft )
		return 0
	endif
	
	// Compute vertical overlap
	if( top > bottom )
		temp=bottom
		bottom= top
		top=temp
	endif
	if( winTop > winBottom )
		temp=winBottom
		winBottom= winTop
		winTop=temp
	endif
	// make top, bottom the top-most rectangle
	if( top > winTop )
		temp=winTop
		winTop= top
		top=temp
		temp=winBottom
		winBottom= bottom
		bottom=temp
	endif
	
	// check for vertical overlap; if none, there is no intersection
	if( bottom <= winTop )
		return 0
	endif
	
	left= max(left,winLeft)
	top= max(top,winTop)
	right= min(right,winRight)
	bottom= min(bottom,winBottom)
	
	Variable theArea= abs((right-left) * (bottom-top))
	
	return theArea
End

// the resulting rectangle includes both rectangles
// if used for data units, the args are
//	WMPolarUnionRects(xMin, yMin, xMax, yMax, xMin2, yMin2, xMax2, yMax2)
Function WMPolarUnionRects(left, top, right, bottom, winLeft, winTop, winRight, winBottom)
	Variable &left, &top, &right, &bottom, winLeft, winTop, winRight, winBottom
	
	// 9.03: Added NaN protection
	if( numtype(left) == 2 )
		left= winLeft
	endif
	if( numtype(top) == 2 )
		top= winTop
	endif
	if( numtype(right) == 2 )
		right= winRight
	endif
	if( numtype(bottom) == 2 )
		bottom= winBottom
	endif

	// Compute horizontal union
	Variable temp
	if( left > right )
		temp=left
		left= right
		right=temp
	endif
	if( winLeft > winRight )
		temp=winLeft
		winLeft= winRight
		winRight=temp
	endif
	
	left= min(left,winLeft)
	right= max(right,winRight)
	
	// Compute vertical union
	if( top > bottom )
		temp=bottom
		bottom= top
		top=temp
	endif
	if( winTop > winBottom )
		temp=winBottom
		winBottom= winTop
		winTop=temp
	endif

	top= min(top,winTop)
	bottom= max(bottom,winBottom)
	
	Variable theArea= abs((right-left) * (bottom-top))
	
	return theArea
End

Function WMPolarMainScreenCorners(left, top, right, bottom)
	Variable &left, &top, &right, &bottom
	
	Variable screenNum= 1	// 1 is the first device (not necessarily the menu bar screen), 2 is the second....
	Variable val
	do
		val = WMPolarScreenCorners(screenNum,left, top, right, bottom)
		if( val == 0 )	// no such screen, should never happen
			break
		endif
		if( val == 2 )	// this is the main screen, left, top, bottom, right are updated already
			return 1	// success
		endif
		screenNum += 1	// not main screen, try next one
	while( 1 )
	return 0			// main screen not found (!)
End	

Function WMPolarScreenCorners(screenNum,left, top, right, bottom)
	Variable screenNum	// 1 is the first device (not necessarily the menu bar screen), 2 is the second....
	Variable &left, &top, &right, &bottom
	
	String info = IgorInfo(0)
	String screenSize= StringByKey("SCREEN"+num2istr(screenNum),info)
	if( strlen(screenSize) == 0 )
		return 0	// no such screen
	endif
	String rectKey="RECT="
	Variable pos = strsearch(screenSize, rectKey, 0)	
	screenSize = screenSize[pos+strlen(rectKey),100]		// hack out everything after RECT=
	left = str2num(StringFromList(0,screenSize,","))		// Get edges of screen
	top = str2num(StringFromList(1,screenSize,","))
	right = str2num(StringFromList(2,screenSize,","))
	bottom = str2num(StringFromList(3,screenSize,","))		// pixels
	
	// The screen coordinates are in pixels, but MoveWindow and GetWindow use points
	left  *= 72/ScreenResolution
	top  *= 72/ScreenResolution
	right   *= 72/ScreenResolution
	bottom  *= 72/ScreenResolution			// points
	
	// determine if the screen is the main one
	Variable isMainScreen= left == 0 && top == 0
	return isMainScreen ? 2 : 1
End	
