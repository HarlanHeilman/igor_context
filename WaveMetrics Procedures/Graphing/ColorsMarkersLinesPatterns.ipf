#pragma rtGlobals=1		// Use modern global access method.
#pragma IgorVersion=9.0	// For "Turbo" color tables.
#pragma version=9.0		// shipped with Igor 9.0

// ColorsMarkersLinesPatterns.ipf
// 08/12/1999 - JP, WaveMetrics, Inc.
// 04/11/2003 - revised for Igor 5 (new and revised color tables have more colors, 6 new markers).
// 08/12/2006 - revised for Igor 6 (12 new color tables).
// 09/18/2006 - revised for Igor 6 (2 more new color tables).
// 07/07/2007 - 6.02: used different waves for WMColorKeyGraph (M_colorKey) and WMAllColorTables (M_colors).
// 11/19/2007 - 6.1: Revised for new markers 51-62
// 09/03/2010 - 6.2: Revised for new Mud and Classification color tables
// 08/22/2019 - 9.0: Revised for new Turbo color table
// 12/29/2020 - 9.0: WMMarkerKeyGraph made resizable; removed Igor version compatibility-indicating colors
//
// DemoColorsLinesMarkersPatterns() creates five graphs that 
// demonstrate color tables, graph markers, line styles, and patterns.
//
// Note that the pattern numbers differ between the drawing tools
// and the graph trace fill-to-zero usages.
//
Macro DemoColorsLinesMarkersPatterns()
	
	WMAllColorTables()		// Color Tables
	WMColorKeyGraph()		// Color Test Pattern Graph
	WMLineStyleKeyGraph()	// Line Styles
	WMMarkerKeyGraph()		// Markers
	WMPatternKeyGraph()	// Fill Patterns
End

Macro DemoClose()
	DoWindow/K PatternKeyGraph
	DoWindow/K MarkerKeyGraph
	DoWindow/K LineStyleKeyGraph
	DoWindow/K ColorKeyGraph
	DoWindow/K ColorTablesGraph
	KillDataFolder root:Packages:WMMarkersLinesPats
End

Function/S WMMarkersLinesPatsDF()
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:WMMarkersLinesPats
	return "root:Packages:WMMarkersLinesPats"
End

Function WMMakeLineStyleWaves()
	// two rows, 0 - 9 and 10-17
	
	Variable i=0
	String wn
	do
		sprintf wn, "root:Packages:WMMarkersLinesPats:'%d'", i
		Make/O/N=2 $wn
		Wave w= $wn
		w= i
		i += 1
	while( i <= 17)
	return 0
end

Macro WMLineStyleKeyGraph()

	PauseUpdate; Silent 1		// building line styles...
	WMMarkersLinesPatsDF()
	WMMakeLineStyleWaves()

	DoWindow/K LineStyleKeyGraph
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:WMMarkersLinesPats:
	String/G cmdLineStyle="ModifyGraph lstyle=0"
	Display/K=1/W=(355,64,566,478) '0','1','2','3','4','5','6','7','8' as "Line Style Numbers"
	AppendToGraph '9','10','11','12','13','14','15','16', '17'
	DoWindow/C LineStyleKeyGraph
	SetDataFolder fldrSav

	iterate( 18 )
		ModifyGraph/Z lStyle[i]=i
	loop
	ModifyGraph nticks(left)=30
	ModifyGraph rgb=(0,0,0)
	ModifyGraph sep(left)=1
	ModifyGraph noLabel(bottom)=2
	ModifyGraph axOffset(bottom)=-1.46667
	ModifyGraph axThick=0
	ModifyGraph manTick(left)={0,1,0,0},manMinor(left)={0,5}
	SetAxis/N=2 left 17,0
	ControlBar 30
	SetVariable cmd,pos={6,8},size={196,13},title="Command",fSize=10
	SetVariable cmd,value= root:Packages:WMMarkersLinesPats:cmdLineStyle
	SetWindow LineStyleKeyGraph hook=WMLineStyleHook, hookEvents=1
EndMacro

Function WMLineStyleHook(s)
	String s
	
	Variable returnVal= 0
	
	SVAR cmd= root:Packages:WMMarkersLinesPats:cmdLineStyle

	Variable xpix,ypix
	String msg
	String win=StringByKey("WINDOW",s)
	Variable isMouseUp= StrSearch(s,"EVENT:mouseup;",0) > 0
	Variable isMouseDown= StrSearch(s,"EVENT:mousedown;",0) > 0
	Variable isClick= isMouseUp + isMouseDown

	if( isClick )
		xpix= NumberByKey("MOUSEX",s)
		ypix= NumberByKey("MOUSEY",s)
		if( ypix > 0 )	// don't interfere with the control panel
			if( isMouseUp )
				// Locate the style from the coordinates
				Variable yaxval= AxisValFromPixel(win,"left",ypix)
				Variable style= round(yaxval)
				style= limit(style,0,17)
				cmd= "ModifyGraph lstyle="+num2istr(style)
			endif
			returnVal=1	// prevent double-click
		endif
	endif
	return returnVal
end

static Constant kNumMarkers=63	// was 46 for Igor 4, was 51 up to Igor 6.0x, changed to 63 with Igor 6.1
static Constant kMarkerSize=5
static Constant kMarkerColumnWidthPoints=15
static Constant kMarkerMargin=20

Function WMMakeMarkerKeyWaves(numColumns)
	Variable numColumns
	
	Make/O/N=(kNumMarkers) root:Packages:WMMarkersLinesPats:MarkerKeyY
	Wave MKY=root:Packages:WMMarkersLinesPats:MarkerKeyY
	Make/O/N=(kNumMarkers) root:Packages:WMMarkersLinesPats:MarkerKeyX
	Wave MKX=root:Packages:WMMarkersLinesPats:MarkerKeyX
	Make/O/N=(kNumMarkers) root:Packages:WMMarkersLinesPats:MarkerKey= x
	MKY = -Floor(p/numColumns)
	MKX = Mod(p, numColumns)
end

Function WMMarkerColumns(graphName)
	String graphName
	
	Variable numColumns= 8
	GetWindow/Z $graphName wsize // points
	if( V_flag == 0 )
		Variable widthPoints = V_right-V_left
		Variable availableWidth = widthPoints - 2*kMarkerMargin
		numColumns= floor(availableWidth/kMarkerColumnWidthPoints)
		numColumns= max(2,min(kNumMarkers,numColumns))	
	endif
	SetWindow $graphName userdata(numColumns)=num2istr(numColumns)
	return numColumns
End

Function 	WMResizeMarkerWavesForGraph(graphName)
	String graphName

	Variable numColumns= WMMarkerColumns(graphName)
	WMMakeMarkerKeyWaves(numColumns)
End

Function WMMarkerFromXY(graphName,xx,yy)
	String graphName
	Variable xx,yy

	Variable marker
	Variable row= round(-yy)
	Variable numColumns = str2num(GetUserData(graphName,"","numColumns"))
	if( numtype(numColumns) != 0 )
		numColumns = WMMarkerColumns(graphName)
	endif
	Variable numRows= ceil(kNumMarkers/numColumns)
	row= limit(row,0,numRows-1)
	Variable col= round(xx)
	col= limit(col,0,numColumns-1)
	marker= row*numColumns+col
	marker= limit(marker,0,kNumMarkers-1)
	return marker
End

Macro WMMarkerKeyGraph()

	PauseUpdate; Silent 1		// building markers
	WMMakeMarkerKeyGraph()
End

Function WMMakeMarkerKeyGraph()

	WMMarkersLinesPatsDF()
	WMMakeMarkerKeyWaves(8)
	DoWindow/K MarkerKeyGraph
	
	String MKY = "root:Packages:WMMarkersLinesPats:MarkerKeyY"
	String MKX = "root:Packages:WMMarkersLinesPats:MarkerKeyX"
	String MK = "root:Packages:WMMarkersLinesPats:MarkerKey"
	String/G root:Packages:WMMarkersLinesPats:cmdMarker="ModifyGraph marker(traceName)=0"
	
	Display/K=1/W=(502,178,837,446)/N=MarkerKeyGraph $MKY vs $MKX as "Marker Numbers"
	AppendToGraph $MKY vs $MKX
	ModifyGraph margin(left)=kMarkerMargin,margin(bottom)=(kMarkerMargin*2),margin(top)=kMarkerMargin,margin(right)=kMarkerMargin
	ModifyGraph mode=3
	ModifyGraph rgb=(0,0,0)
	ModifyGraph msize(MarkerKeyY)=kMarkerSize, mrkThick(MarkerKeyY)=1
	ModifyGraph zmrkNum(MarkerKeyY)={$MK}
	ModifyGraph textMarker(MarkerKeyY#1)={$MK,"default",0,0,kMarkerSize,0.00,-15.00}
	ModifyGraph noLabel=2, axThick=0, gmSize=4

	ControlBar 25
	SetVariable cmd,pos={2,6},size={200,17},fSize=10, title=" "
	SetVariable cmd,value= root:Packages:WMMarkersLinesPats:cmdMarker

	SetWindow MarkerKeyGraph hook(named)=WMNamedMarkerHook
	WMResizeMarkerWavesForGraph("MarkerKeyGraph")
End

Function WMNamedMarkerHook(s)
	STRUCT WMWinHookStruct &s
	Variable hookResult = 0
	String win=s.winName

	strswitch(s.eventName)
		case "mouseup":
			Variable ypix = s.mouseLoc.v
			if( ypix > 0 )	// don't interfere with the control panel
				// Locate the marker from the coordinates
				Variable xpix = s.mouseLoc.h
				Variable xaxval= AxisValFromPixel(win,"bottom",xpix)
				Variable yaxval= AxisValFromPixel(win,"left",ypix)
				Variable marker= WMMarkerFromXY(win,xaxval,yaxval)
				SVAR cmd= root:Packages:WMMarkersLinesPats:cmdMarker
				cmd= "ModifyGraph marker="+num2istr(marker)
				PutScrapText cmd
				Variable numColumns= WMMarkerColumns(win)
				if( numColumns < 6 )
					cmd= num2istr(marker)
				endif
			endif
			break
		case "resize":
			WMResizeMarkerWavesForGraph(win)
			break
	endswitch
	return hookResult		// 0 if nothing done, else 1
End


Macro WMPatternKeyGraph()
	PauseUpdate; Silent 1		// building patterns...

	WMMarkersLinesPatsDF()
	String/G root:Packages:WMMarkersLinesPats:cmdPattern

	DoWindow/K PatternKeyGraph
	Display/K=1/W=(7,43,342,478) as "Pattern Numbers"
	DoWindow/C PatternKeyGraph
	ControlBar 55
	PopupMenu code,pos={4,10},size={329,19},proc=WMFillPatternPop,title="Numbers for"
	PopupMenu code,mode=1,value= "Drawing Patterns (fillPat values);Graph Patterns (hbFill values)"
	SetVariable cmd,pos={13,34},size={297,17},title="Command",fSize=10
	SetVariable cmd,value= root:Packages:WMMarkersLinesPats:cmdPattern
	WMDrawFillPatternNumbers(-1)	// hbFill numbers for drawing tools
	SetWindow PatternKeyGraph hook=WMPatHook, hookEvents=1
EndMacro


Function WMFillPatternPop(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	WMDrawFillPatternNumbers(popNum-2)	// -1 (drawing) or 0 (graphs)

End

Function WMPatternCmd(patNum)
	Variable patNum
	
	SVAR cmd= 	root:Packages:WMMarkersLinesPats:cmdPattern
	ControlInfo/W= PatternKeyGraph code
	if( V_value == 1 ) 	// drawing tools
		cmd= "SetDrawEnv fillPat="
	else		// graph
		cmd= "ModifyGraph hbFill(traceName)="
	endif
	cmd+= num2istr(patNum)
End

Function WMDrawFillPatternNumbers(startingNumber)
	Variable startingNumber	// -1 (drawing) or 0 (graphs)
	
	Variable isGraph= startingNumber == 0
	SetDrawLayer/K UserFront
	SetDrawEnv xcoord= abs,ycoord= abs
	SetDrawEnv textxjust= 1,textyjust= 2
	SetDrawEnv fillfgc= (0,0,0)
	SetDrawEnv save

	WMPatternCmd(startingNumber+6)	// first pattern
	
	Variable yy,xx, tx,ty
	Variable box=18
	Variable skip= 38
	Variable x0=25
	Variable y0=6
	Variable drawPat= -3 // always use drawing tool code, first valid is -1
	startingNumber-= 2
	String fillText
	Variable row=0, col
	do
		col= 0
		yy= y0 + row * skip
		ty= yy + box
		do
			xx= x0 + col *skip
			tx= xx + box/2
			if( drawPat >= 1 )
				SetDrawEnv fillpat= drawPat
				DrawRect xx,yy,xx+box,yy+box
				DrawText tx,ty, num2istr(startingNumber)
			else
				if( drawPat >= -1 )	// -1 is erase for draw, none for graph
					if( isGraph )	  // 0 is  none for draw, erase for graph
						fillText=SelectString(drawPat == -1,"erase","none")
					else
						fillText=SelectString(drawPat == -1,"none","erase")
					endif
					DrawText tx,yy, fillText
					DrawText tx,ty, num2istr(startingNumber)
				endif
			endif
			
			drawPat += 1
			startingNumber += 1	
			col += 1
		while( col <= 7)
		row += 1
	while(row <= 9)
End


Function WMPatHook(s)
	String s
	
	Variable returnVal= 0
	
	SVAR cmd= root:Packages:WMMarkersLinesPats:cmdPattern

	Variable xpix,ypix
	String msg
	String win=StringByKey("WINDOW",s)

	Variable isMouseUp= StrSearch(s,"EVENT:mouseup;",0) > 0
	Variable isMouseDown= StrSearch(s,"EVENT:mousedown;",0) > 0
	Variable isClick= isMouseUp + isMouseDown

	if( isClick )
		xpix= NumberByKey("MOUSEX",s)
		ypix= NumberByKey("MOUSEY",s)
		if( ypix > 0 )	// don't interfere with the control panel
			if( isMouseUp )
				// Locate the pattern from the coordinates
				xpix= NumberByKey("MOUSEX",s)
				ypix= NumberByKey("MOUSEY",s)
				Variable patNum= WMPatternFromXY(xpix,ypix)	// drawing pattern
				ControlInfo/W= PatternKeyGraph code
				if( V_value == 2 ) 	// graph
					patNum += 1
				endif
				WMPatternCmd(patNum)
			endif
		endif
	endif
	return returnVal
end

Function WMPatternFromXY(xpix,ypix)
	Variable xpix,ypix	// points, actually
	
	Variable xabsolute= xpix*72/ScreenResolution // convert to points (xcoord=abs is points in a graph)
	Variable yabsolute= ypix*72/ScreenResolution // convert to points (ycoord=abs is points in a graph)
	Variable xx= xabsolute
	Variable yy= yabsolute 
	Variable box=18	// must be the same as the routine which draws these, should use globals.
	Variable skip= 38
	Variable x0=25
	Variable y0=6
	Variable hMargin= (skip-box)/2
	// the hit zones are the boxes extended vertically to the next row, horizontally +/- hMargin.
	Variable col= floor((xx-(x0-hMargin)) / skip)
	col= limit(col,0,7)
	Variable row= floor((yy-y0) / skip)
	row= limit(row,0,9)	
	Variable patNum= -3 + row * 8 + col	// drawing pattern
	return limit(patNum,-1,76)
End

Function WMColorKeyWave(colorTableName)
	String colorTableName
	
	String oldDF= GetDataFolder(1)
	SetDataFolder root:Packages:WMMarkersLinesPats:
	
	if( FindListItem(colorTableName, Ctablist()) < 0 )
		// builtin
		Make/O/U/W/N=(3,128) M_colorKey=0
		M_colorKey[0][0]={65535,65535,65535}	// white
		M_colorKey[0][1]={0,0,0}					// black
		M_colorKey[0][2]={65535,49151,49151}
		M_colorKey[0][3]={65535,54611,49151}
		M_colorKey[0][4]={65535,60076,49151}
		M_colorKey[0][5]={65535,65534,49151}
		M_colorKey[0][6]={57346,65535,49151}
		M_colorKey[0][7]={49151,65535,49151}
		M_colorKey[0][8]={49151,65535,57456}
		M_colorKey[0][9]={49151,65535,65535}
		M_colorKey[0][10]={49151,60031,65535}
		
		M_colorKey[0][11]={49151,53155,65535}
		M_colorKey[0][12]={49151,49152,65535}
		M_colorKey[0][13]={51664,44236,58982}
		M_colorKey[0][14]={65535,49151,62258}
		M_colorKey[0][15]={65535,49151,55704}
		M_colorKey[0][16]={61166,61166,61166}
		M_colorKey[0][17]={4369,4369,4369}
		M_colorKey[0][18]={65535,32768,32768}
		M_colorKey[0][19]={65535,43688,32768}
	
		M_colorKey[0][20]={65535,54607,32768}
		M_colorKey[0][21]={65535,65533,32768}
		M_colorKey[0][22]={49163,65535,32768}
		M_colorKey[0][23]={32769,65535,32768}
		M_colorKey[0][24]={32768,65535,49386}
		M_colorKey[0][25]={32768,65535,65535}
		M_colorKey[0][26]={32768,54615,65535}
		M_colorKey[0][27]={32768,40777,65535}
		M_colorKey[0][28]={32768,32770,65535}
		M_colorKey[0][29]={44253,29492,58982}
	
		M_colorKey[0][30]={65535,32768,58981}
		M_colorKey[0][31]={65535,32768,45875}
		M_colorKey[0][32]={56797,56797,56797}
		M_colorKey[0][33]={8738,8738,8738}
		M_colorKey[0][34]={65535,16385,16385}
		M_colorKey[0][35]={65535,32764,16385}
		M_colorKey[0][36]={65535,49157,16385}
		M_colorKey[0][37]={65535,65532,16385}
		M_colorKey[0][38]={40969,65535,16385}
		M_colorKey[0][39]={16386,65535,16385}
	
		M_colorKey[0][40]={16385,65535,41303}
		M_colorKey[0][41]={16385,65535,65535}
		M_colorKey[0][42]={16385,49025,65535}
		M_colorKey[0][43]={16385,28398,65535}
		M_colorKey[0][44]={16385,16388,65535}
		M_colorKey[0][45]={36873,14755,58982}
		M_colorKey[0][46]={65535,16385,55749}
		M_colorKey[0][47]={65535,16385,36045}
		M_colorKey[0][48]={52428,52428,52428}
		M_colorKey[0][49]={13107,13107,13107}
	
		M_colorKey[0][50]={65535,0,0}
		M_colorKey[0][51]={65535,21845,0}
		M_colorKey[0][52]={65535,43690,0}
		M_colorKey[0][53]={65535,65535,0}
		M_colorKey[0][54]={32792,65535,1}
		M_colorKey[0][55]={0,65535,0}
		M_colorKey[0][56]={1,65535,33232}
		M_colorKey[0][57]={0,65535,65535}
		M_colorKey[0][58]={0,43690,65535}
		M_colorKey[0][59]={1,16019,65535}
	
		M_colorKey[0][60]={0,0,65535}
		M_colorKey[0][61]={29524,1,58982}
		M_colorKey[0][62]={65535,0,52428}
		M_colorKey[0][63]={65535,0,26214}
		M_colorKey[0][64]={48059,48059,48059}
		M_colorKey[0][65]={17476,17476,17476}
		M_colorKey[0][66]={52428,1,1}
		M_colorKey[0][67]={52428,17472,1}
		M_colorKey[0][68]={52428,34958,1}
		M_colorKey[0][69]={52428,52425,1}
	
		M_colorKey[0][70]={26205,52428,1}
		M_colorKey[0][71]={3,52428,1}
		M_colorKey[0][72]={1,52428,26586}
		M_colorKey[0][73]={1,52428,52428}
		M_colorKey[0][74]={1,34817,52428}
		M_colorKey[0][75]={1,12815,52428}
		M_colorKey[0][76]={1,4,52428}
		M_colorKey[0][77]={26411,1,52428}
		M_colorKey[0][78]={52428,1,41942}
		M_colorKey[0][79]={52428,1,20971}
	
		M_colorKey[0][80]={43690,43690,43690}
		M_colorKey[0][81]={21845,21845,21845}
		M_colorKey[0][82]={39321,1,1}
		M_colorKey[0][83]={39321,13101,1}
		M_colorKey[0][84]={39321,26208,1}
		M_colorKey[0][85]={39321,39319,1}
		M_colorKey[0][86]={19675,39321,1}
		M_colorKey[0][87]={2,39321,1}
		M_colorKey[0][88]={1,39321,19939}
		M_colorKey[0][89]={1,39321,39321}
	
		M_colorKey[0][90]={1,26221,39321}
		M_colorKey[0][91]={1,9611,39321}
		M_colorKey[0][92]={1,3,39321}
		M_colorKey[0][93]={19729,1,39321}
		M_colorKey[0][94]={39321,1,31457}
		M_colorKey[0][95]={39321,1,15729}
		M_colorKey[0][96]={39321,39321,39321}
		M_colorKey[0][97]={26214,26214,26214}
		M_colorKey[0][98]={26214,0,0}
		M_colorKey[0][99]={26214,8736,0}
	
		M_colorKey[0][100]={26214,17479,0}
		M_colorKey[0][101]={26214,26212,0}
		M_colorKey[0][102]={13102,26214,0}
		M_colorKey[0][103]={1,26214,0}
		M_colorKey[0][104]={0,26214,13293}
		M_colorKey[0][105]={0,26214,26214}
		M_colorKey[0][106]={0,17409,26214}
		M_colorKey[0][107]={0,6405,26214}
		M_colorKey[0][108]={0,2,26214}
		M_colorKey[0][109]={13112,0,26214}
	
		M_colorKey[0][110]={26214,0,20971}
		M_colorKey[0][111]={26214,0,10485}
		M_colorKey[0][112]={34952,34952,34952}
		M_colorKey[0][113]={30583,30583,30583}
		M_colorKey[0][114]={13107,0,0}
		M_colorKey[0][115]={13107,4367,0}
		M_colorKey[0][116]={13107,8736,0}
		M_colorKey[0][117]={13107,13106,0}
		M_colorKey[0][118]={6558,13107,0}
		M_colorKey[0][119]={0,13107,0}
		M_colorKey[0][120]={0,13107,6646}
		
		M_colorKey[0][121]={0,13107,13107}
		M_colorKey[0][122]={0,8740,13107}
		M_colorKey[0][123]={0,3204,13107}
		M_colorKey[0][124]={0,1,13107}
		M_colorKey[0][125]={6509,0,13107}
		M_colorKey[0][126]={13107,0,10485}
		M_colorKey[0][127]={13107,0,5243}
		MatrixTranspose M_colorKey
	else
		ColorTab2Wave $colorTableName	// creates M_colors
		Duplicate/O M_colors, M_ColorKey
		KillWaves/Z M_colors
	endif
	SetDataFolder oldDF
End

Macro WMColorKeyGraph()

	DoWindow/K ColorKeyGraph
	PauseUpdate; Silent 1		// building color key

	WMMarkersLinesPatsDF()
	WMColorKeyWave("")

	String wny="root:Packages:WMMarkersLinesPats:colorAxisY"
	String wnx="root:Packages:WMMarkersLinesPats:colorAxisX"
	Make/O/N=2 $wny={ 90, 325 }
	Make/O/N=2 $wnx={ 40,  530 }

	Display/K=1/W=(348,42,825,320) $wny vs $wnx as "Color Test Pattern"
	DoWindow/C ColorKeyGraph
	 // hide the axis-determining wave and the associated axis labelling
	ModifyGraph lsize(colorAxisY)=0, margin=1, axThick=0, standoff=0,nolabel=2
	ModifyGraph height=248, width=485
	SetAxis/A/R left

	// command
	String/G  root:Packages:WMMarkersLinesPats:cmdColor="rgb(traceName)=(0,0,0)"
	ControlBar 28
	SetVariable cmd,pos={2,7},size={342,13},title="Command",fSize=10
	SetVariable cmd,limits={-Inf,Inf,1},value= root:Packages:WMMarkersLinesPats:cmdColor
	
	// color popup
	PopupMenu colorPop,pos={347,4},size={111,19},proc=WMColorTestPop
	PopupMenu colorPop,mode=1,popvalue="Color Palette",value= #"\"Color Palette;\"+CTabList()"

	WMColorKeyDraw()
	SetWindow ColorKeyGraph hook=WMColorHook, hookEvents=1
End


Function WMColorTestPop(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	WMColorKeyWave(popStr)
	WMColorKeyDraw()
End

static Constant kX0=55
static Constant kY0=100
static Constant kCols=16
static Constant kColWidth= 29


Function WMColorKeyDraw()
	SetDrawLayer/K UserFront
	SetDrawEnv xcoord=bottom,ycoord=left,save
	Wave M_colorKey= root:Packages:WMMarkersLinesPats:M_colorKey
	Variable row, col, xx, yy
	Variable red,green,blue
	Variable cols= 16
	Variable n= DimSize(M_colorKey,0)
	Variable rows= ceil(n/cols)
	Variable rowHeight= (rows <= 8) ? 27 : (315-kY0)/rows
	Variable index=0
	row=0	
	do
		yy= kY0 + row * rowHeight
		col= 0
		do
			xx= kX0 + col * kColWidth
			red= M_colorKey[index][0]
			green= M_colorKey[index][1]
			blue= M_colorKey[index][2]
			SetDrawEnv fillfgc=(red,green,blue)
			DrawRect xx, yy, xx+kColWidth+1, yy+rowHeight+1
			index += 1
			if( index >= n )
				break;
			endif
			col += 1
		while( col < cols )
		row += 1
	while( row < rows )
End

Function/S WMColorFromXY(xx,yy)
	Variable xx,yy

	String rgbs= "0,0,0"

	Wave M_colorKey= root:Packages:WMMarkersLinesPats:M_colorKey
	Variable row, col
	Variable cols= 16
	Variable n= DimSize(M_colorKey,0)
	Variable rows= ceil(n/cols)
	Variable rowHeight= (rows <= 8) ? 27 : (315-kY0)/rows

	col= floor((xx-kX0) / kColWidth)
	col= limit(col,0,cols-1)
	row= floor((yy-kY0) / rowHeight)
	row= limit(row,0,rows-1)	
	Variable index= row * cols + col	// drawing pattern
	index= limit(index,0,n-1)
	// Printf "row= %g, col= %g, index= %g\r",row,col,index
	sprintf rgbs "%d,%d,%d", M_colorKey[index][0],M_colorKey[index][1],M_colorKey[index][2]

	return rgbs
End



Function WMColorHook(s)
	String s

	Variable returnVal= 0
	
	SVAR cmd= root:Packages:WMMarkersLinesPats:cmdColor

	Variable xpix,ypix
	String msg
	String win=StringByKey("WINDOW",s)

	Variable isMouseUp= StrSearch(s,"EVENT:mouseup;",0) > 0
	Variable isMouseDown= StrSearch(s,"EVENT:mousedown;",0) > 0
	Variable isClick= isMouseUp + isMouseDown

	if( isClick )
		xpix= NumberByKey("MOUSEX",s)
		ypix= NumberByKey("MOUSEY",s)
		if( ypix > 0 )	// don't interfere with the control panel
			if( isMouseUp )
				// Locate the marker from the coordinates
				Variable xaxval= AxisValFromPixel(win,"bottom",xpix)
				Variable yaxval= AxisValFromPixel(win,"left",ypix)
				String rgbs= WMColorFromXY(xaxval,yaxval)
				sprintf cmd, "ModifyGraph rgb(traceName)=(%s)",rgbs
			endif
		endif
	endif
	return returnVal
end

Macro WMAllColorTables()
	fWMAllColorTables(1)	// building color tables graph
End

Function fWMAllColorTables(makeSameLength)
	Variable makeSameLength
	
	DoWindow/K ColorTablesGraph
	String savedDataFolder = GetDataFolder(1)

	String tdf= WMMarkersLinesPatsDF()	// without ":"
	SetDataFolder tdf
	
	Variable/G lastColorIndex=0
	String/G clickedCtab="Grays"
	
	String list= CTabList()
	Variable i, n= ItemsInList(list)
	Variable axisInc= 1/(n+1)
	Display/N=ColorTablesGraph /W=(5,42,834,800)/K=1
	String win= S_Name
	DoWindow/T $win, "Color Tables"
	ModifyGraph/W=$win margin(left)=110,margin(bottom)=10,margin(top)=28,margin(right)=180
	ModifyGraph/W=$win wbRGB=(56797,56797,56797),gbRGB=(56797,56797,56797), gfSize=10

	SetDrawLayer/W=$win UserFront
	SetDrawEnv/W=$win textxjust= 2,textyjust= 1,fsize= 10, save

	for(i= 0; i < n; i += 1 )
		String tab= StringFromList(i,list)

		ColorTab2Wave $tab	// create M_Colors
		Wave M_Colors
		Variable rows=DimSize(M_Colors,0)
		
		lastColorIndex= max(lastColorIndex,rows)

		String wavePath
		sprintf wavePath, "root:Packages:WMMarkersLinesPats:%s", tab
		
		Make/O/N=(rows, 2, 3) $wavePath
		WAVE w=$wavePath
		w= M_colors[p][r]

		String axisName
		Variable highFrac= 1- i* axisInc
		Variable lowFrac= highFrac - axisInc*0.45	// leave some gap

		axisName="Left"
		SetScale/I y, lowFrac, highFrac, "", w
		if( makeSameLength )
			Variable overhang= (100 / rows)/2
			SetScale/I x, 0+overhang, 100-overhang, "", w
		endif
		AppendImage/W=$win/L=$axisName w

		SetDrawEnv/W=$win ycoord= $axisName,xcoord=bottom, save
		strswitch( tab )
			case "Grays":
			case "Rainbow":
			case "YellowHot":
			case "BlueHot":
			case "BlueRedGreen":
			case "RedWhiteBlue":
			case "PlanetEarth":
			case "Terrain":
			case "Grays16":
			case "Rainbow16":
				SetDrawEnv/W=$win textrgb=(0,0,65535)
				break
			
			case "Grays256":
			case "Rainbow256":
			case "YellowHot256":
			case "BlueHot256":
			case "BlueRedGreen256":
			case "RedWhiteBlue256":
			case "PlanetEarth256":
			case "Terrain256":
			case "Red":
			case "Green":
			case "Blue":
			case "Cyan":
			case "Magenta":
			case "Yellow":
			case "Copper":
			case "Gold":
			case "CyanMagenta":
			case "RedWhiteGreen":
			case "BlueBlackRed":
			case "Geo":
			case "Geo32":
			case "LandAndSea":
			case "LandAndSea8":
			case "Refief":
			case "Relief19":
			case "PastelsMap":
			case "PastelsMap20":
			case "Bathymetry9":
			case "BlackBody":
			case "Spectrum":
			case "SpectrumBlack":
			case "Cycles":
			case "Fiddle":
			case "Pastels":
				SetDrawEnv/W=$win textrgb=(0,40000,0)	// green indicates Igor 5-compatible tables
				break
		
			case "Mud":
			case "Classification":
				SetDrawEnv/W=$win textrgb=(65535,0,0)	// red indicates Igor 6.2 tables
				break
		
			case "Turbo":
				SetDrawEnv/W=$win textrgb=(1,39321,39321)	// cyan indicates Igor 9.0 tables
				break
		
			default:
				SetDrawEnv/W=$win textrgb=(0,0,0)
				break
		endswitch
		DrawText/W=$win -1,(lowFrac+highFrac)/2,tab+" "

	endfor
	
	ModifyGraph/W=$win mirror(bottom)=0, nticks(bottom)=0, axthick(bottom)=0
	ModifyGraph/W=$win  axthick(left)=0, nticks(left)=0

	// P1 panel
	NewPanel/W=(0.2,0.2,0.8,0.8)/FG=(PL,GT,PR,PT)/HOST=# 
	ModifyPanel frameStyle=0
	TitleBox title4,pos={1,4},size={87,20},title="Igor 4 color tables"
	TitleBox title4,fColor=(0,0,52428)
	TitleBox title5,pos={97,4},size={87,20},title="Igor 5 color tables"
	TitleBox title5,fColor=(0,40000,0)
	TitleBox title6,pos={193,4},size={117,20},title="Igor 6.0, 6.1 color tables"
	TitleBox title62,pos={319,4},size={96,20},title="Igor 6.2 color tables"
	TitleBox title62,fColor=(65535,0,0)
	TitleBox title9,pos={420,4},size={96,20},title="Igor 9 color tables"
	TitleBox title9,fColor=(1,39321,39321)
	RenameWindow #,P1
	SetActiveSubwindow ##
	
	// G0 for colorscale
	Display/W=(0.2,0.2,0.8,0.8)/FG=(PR,PT,FR,PB)/HOST=# 
	ColorScale/C/N=big/A=MT/X=0/Y=1  ctab={0,100,$clickedCtab,0}, heightPct=97, widthPct=60
	ColorScale/C/N=big/Z=1 nticks=10,minor=1	// frozen position
	RenameWindow #,G0
	SetActiveSubwindow ##
	
	// P0 for selected color table name
	NewPanel/W=(0.2,0.2,0.8,0.8)/FG=(PR,GT,FR,PT)/HOST=# 
	ModifyPanel frameStyle=0, frameInset=0
	SetVariable selectedTable,pos={7,6},size={142,15},title=" ",frame=1
	SetVariable selectedTable,value= root:Packages:WMMarkersLinesPats:clickedCtab, noedit=0
	RenameWindow #,P0
	SetActiveSubwindow ##
	
	KillWaves/Z M_colors
	SetDataFolder savedDataFolder
	SetWindow $win hook=WMColorTablesHook, hookEvents=1
End

Function WMColorTablesHook(s)
	String s

	Variable returnVal= 0
	
	String savedDataFolder = GetDataFolder(1)

	SetDataFolder WMMarkersLinesPatsDF()	// without ":"
	
	String/G clickedCtab
	SVAR clickedCtab

	Variable xpix,ypix
	String msg
	String win=StringByKey("WINDOW",s)

	Variable isMouseUp= StrSearch(s,"EVENT:mouseup;",0) > 0
	Variable isMouseDown= StrSearch(s,"EVENT:mousedown;",0) > 0
	Variable isClick= isMouseUp || isMouseDown

	if( isClick )
		xpix= NumberByKey("MOUSEX",s)
		ypix= NumberByKey("MOUSEY",s)
		if( ypix > 0 )	// don't interfere with the control panel
			if( isMouseUp )
				// Locate the marker from the coordinates
				Variable xaxval= AxisValFromPixel(win,"bottom",xpix)
				Variable yaxval= AxisValFromPixel(win,"left",ypix)
				// ignore clicks outside of the thumbnail graph area
				GetAxis/W=$win/Q bottom
				if( xaxval >= V_min && xaxval <= V_max )
					String units
					clickedCtab= WMColorTabFromXY(xaxval,yaxval,units)
					// modify the colorscale in the subwindow, xaxval and yaxval become colormin and color max
					if( strlen(clickedCtab) )
						String subwin= win+"#G0"
						ColorScale/W=$subwin/C/N=big ctab={xaxval,yaxval,$clickedCTab,0}, units
					endif
				endif
			endif
		endif
	endif
	SetDataFolder savedDataFolder
	return returnVal
end

Function/S WMColorTabFromXY(xaxval,yaxval,units)
	Variable &xaxval,&yaxval	// these become colormin and colormax
	String &units
	
	Variable index=0

	String list= CTabList()
	Variable i, n= ItemsInList(list)
	Variable axisInc= 1/(n+1)
	Variable deltaY= axisInc*0.45
	Variable overhang=  0.7 * deltaY	// should be 0.5, but this works to handle the gaps better.
	// top of ctab i is actually drawn at:
	// topY= 1 - i * axisInc + overhang
	// i * axisInc = 1 - topY + overhang
	i = floor((1-yaxval+overhang)/axisInc)

	String ctab= StringFromList(i,list)
	// some color tables are designed to work over a specific or typical numeric range
	units=""
	strswitch( ctab )
		case "LandAndSea8":
			xaxval= -1000
			yaxval= 3700
			units="ft"
			break
		case "Relief19":
			xaxval= -1000
			yaxval= 1100
			units="ft"
			break
		// SeaLevel at 50%
		case "LandAndSea":
		case "Relief":
			xaxval= -1000
			yaxval= 1000
			units="ft"
			break
		// SeaLevel at 66.67%
		case "PastelsMap":
		case "PastelsMap20":
			xaxval= -2000
			yaxval= 1000
			units="ft"
			break
		// SeaLevel at 100%
		case "Bathymetry9":
			xaxval= -10000
			yaxval= 0
			units="ft"
			break
		case "BlackBody":
			xaxval= 1000
			yaxval= 10000
			units="deg K"
			break
		case "Spectrum":	// 380 to 780 nm
			xaxval= 380
			yaxval= 780
			units="nm"
			break
		case "SpectrumBlack":	// 355 to 830 nm
			xaxval= 355
			yaxval= 830
			units="nm"
			break
		// Start Igor 6 special-purpose color tables
		case "Web216":
			xaxval= 0
			yaxval= 215
			break
		// Geological
		// Sea level at 25%
		case "SeaLandAndFire":
			xaxval= -2500
			yaxval= 7500
			units="ft"
			break
		// Meteorological
		// GreenMagenta16	16 colors, similar to the 14-color NW National Weather Service Motion (base velocity or storm relative values), but friendly to red-green colorblind people.
		case "GreenMagenta16":
			xaxval= -30
			yaxval= 30
			units="m/s"
			break
		// dBZ14			14 colors, National Weather Service Reflectivity (radar) colors for Clear Air (-28 to +24 dBZ) or Precipitation (5 to 70 dBZ) mode.
		case "dBZ14":
			xaxval= 5
			yaxval= 70
			units="dBZ"
			break
		// dBZ21			21 colors, National Weather Service Reflectivity (radar) colors for combined Clear Air and Precipitation mode (-30 to 70) dBZ.
		case "dBZ21":
			xaxval= -30
			yaxval= 70
			units="dBZ"
			break
		default:
			xaxval= 0
			yaxval= 100
			break
	endswitch
	return ctab
End

Function WMColorTablesLastIndexSV(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	SetAxis bottom, 0, varNum
End

Function WMColorTablesAllButtonProc(ctrlName) : ButtonControl
	String ctrlName

	SetAxis/A bottom
	GetAxis/Q bottom
	Variable/G lastColorIndex= ceil(V_max)
End