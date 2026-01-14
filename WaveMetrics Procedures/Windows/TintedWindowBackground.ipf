#pragma rtGlobals=1			// Use modern global access method.
#pragma IgorVersion=6.0		// for Menu ,hideable 
#pragma version=8			// Released with Igor 8.04
#pragma ModuleName=TintedBackground
#include <Graph Utility Procs>, version>=5.031

// Version 6.23, 8/9/2011:
//	The menu items disappear when HideIgorMenus "Graph", etc are executed.
//
// Version 6.03, 10/5/2007:
//	The panel now remembers the settings between invocations.
//	Added new "Plot Area only" option.
// "Add Tint Here" uses plot-relative coordinates in graphs (previous versions used window-relative coordinates).
//
// Version 7, 5/24/2016:
//	Panel uses sizeLimit on Igor 7.
//
// Version 8, 10/7/2019
// Added WM_RemoveTintsFromWindow()

Menu "Graph", hideable
	"Add Tinted Background", WM_TintedBkgPanel()
End

Menu "Layout", hideable
	"Add Tinted Background", WM_TintedBkgPanel()
End

Menu "GraphMarquee"
	"Add Tint Here", TintedBackground#WM_TintAtMarquee()
End

Menu "LayoutMarquee"
	"Add Tint Here", TintedBackground#WM_TintAtMarquee()
End

Static Function/S ShapeList()

	return "Square;Rounded Square;Circle;Spot;Vertical;Horizontal;Diagonal +45;Diagonal -45;"
End

static Constant kDefaultWidthPanelUnits= 447// 920 - 473
static Constant kDefaultHeightPanelUnits = 541 // 599 - 58

static Constant kMinWidthPanelUnits= 200
static Constant kMinHeightPanelUnits= 450

Function WM_TintedBkgPanel()

	DoWindow TintPanel
	if( V_Flag )
		DoWindow/F TintPanel	// the activate hook will update the controls
		return 0
	endif

	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:WMBkgTint

	// left, top, right, bottom
	Variable left= 473, top= 58
	Variable widthPanelUnits= kDefaultWidthPanelUnits
	Variable heightPanelUnits= kDefaultHeightPanelUnits
	
	NewPanel /K=1/W=(left,top,left+widthPanelUnits,top+heightPanelUnits)/N=TintPanel as "Tint Background of Top Window"
	ModifyPanel noEdit=1
	String target=WinName(0,1+4)
	if( strlen(target) )
		AutoPositionWindow/M=0/R=$target $S_Name
	endif
	DefaultGUIFont/W=TintPanel /Mac popup={"_IgorSmall",0,0}, button={"_IgorSmall",0,0}
	
	String shape= StrVarOrDefault("root:Packages:WMBkgTint:shape", "Square")
	Variable mode= 1+ WhichListItem(shape,ShapeList())
	PopupMenu shape,pos={26,7},size={87,17},proc=TintedBackground#WM_TintShapePopMenuProc,title="Shape"
	PopupMenu shape,mode=mode,popvalue=shape,value= TintedBackground#ShapeList()// #"\"Square;Rounded Square;Circle;Spot;Vertical;Horizontal;Diagonal +45;Diagonal -45\""

	Variable theMargin= NumVarOrDefault("root:Packages:WMBkgTint:margin", 20)
	Variable/G root:Packages:WMBkgTint:margin = theMargin
	SetVariable margin,pos={28,48},size={79,15},proc=TintedBackground#WM_TintSetVarProc,title="Margin:"
	SetVariable margin,limits={0,100,5},value= root:Packages:WMBkgTint:margin,bodyWidth= 40

	Variable/G root:Packages:WMBkgTint:reverse
	CheckBox reverse,pos={26,29},size={81,14},proc=TintedBackground#WM_TintReverseCheckProc,title="Reverse Tints"
	CheckBox reverse,variable=root:Packages:WMBkgTint:reverse

	Variable/G root:Packages:WMBkgTint:returnToStartingTint
	CheckBox return,pos={26,49},size={121,14},disable=1,proc=TintedBackground#WM_TintReverseCheckProc,title="Return to Starting Tint"
	CheckBox return,variable=root:Packages:WMBkgTint:returnToStartingTint

	GroupBox tintGroup,pos={5,67},size={176,65},title="Center Tint"

	CheckBox tintRGB,pos={25,90},size={16,14},proc=TintedBackground#WM_TintRadioProc,title=""
	CheckBox tintRGB,value= 1,mode=1
	CheckBox tintPlotRGB,pos={25,111},size={125,14},proc=TintedBackground#WM_TintRadioProc,title="Graph Background Color"
	CheckBox tintPlotRGB,value= 0,mode=1

	Variable red, green, blue
	red= NumVarOrDefault("root:Packages:WMBkgTint:tintRed", 65535)
	green= NumVarOrDefault("root:Packages:WMBkgTint:tintGreen", 65534)
	blue= NumVarOrDefault("root:Packages:WMBkgTint:tintBlue", 49151)
	PopupMenu tint,pos={44,88},size={50,17},proc=TintedBackground#WM_TintPopMenuProc
	PopupMenu tint,mode=1,popColor= (red, green, blue),value= #"\"*COLORPOP*\""

	Button lighterTint,pos={110,88},size={50,20},proc=TintedBackground#WM_TintLighterButtonProc,title="Lighter"

	String str= StrVarOrDefault("root:Packages:WMBkgTint:whichTintRadio", "tintRGB")
	WM_SetTintRadioControls(str)	// updates the global root:Packages:WMBkgTint:whichTintRadio

	GroupBox fadeGroup,pos={5,139},size={176,90},title="Edge Tint"
	CheckBox fadeRGB,pos={25,163},size={16,14},proc=TintedBackground#WM_TintFadeRadioProc,title=""
	CheckBox fadeRGB,value= 1,mode=1
	CheckBox fadePlotRGB,pos={25,184},size={125,14},proc=TintedBackground#WM_TintFadeRadioProc,title="Graph Background Color"
	CheckBox fadePlotRGB,value= 0,mode=1
	CheckBox fadeWindowRGB,pos={25,205},size={133,14},proc=TintedBackground#WM_TintFadeRadioProc,title="Window Background Color"
	CheckBox fadeWindowRGB,value= 0,mode=1

	red= NumVarOrDefault("root:Packages:WMBkgTint:fadeRed", 65535)
	green= NumVarOrDefault("root:Packages:WMBkgTint:fadeGreen", 65535)
	blue= NumVarOrDefault("root:Packages:WMBkgTint:fadeBlue", 65535)
	PopupMenu fadeColor,pos={45,160},size={50,17},proc=TintedBackground#WM_TintPopMenuProc
	PopupMenu fadeColor,mode=1,popColor= (red, green, blue),value= #"\"*COLORPOP*\""

	Button lighterFade,pos={110,160},size={50,20},proc=TintedBackground#WM_TintLighterButtonProc,title="Lighter"

	str= StrVarOrDefault("root:Packages:WMBkgTint:whichFadeRadio", "fadeRGB")
	WM_SetFadeRadioControls(str)	// updates the global root:Packages:WMBkgTint:whichFadeRadio

	GroupBox frameGroup,pos={5,234},size={176,82},title="Frame"

	Variable theFrame= NumVarOrDefault("root:Packages:WMBkgTint:frame", 0)
	Variable/G root:Packages:WMBkgTint:frame = theFrame
	SetVariable frame,pos={25,253},size={126,15},proc=TintedBackground#WM_TintFrameSetVarProc,title="Thickness (points)"
	SetVariable frame,limits={0,100,1},value= root:Packages:WMBkgTint:frame,bodyWidth= 40
	Variable disable= theFrame > 0 ? 0 : 2

	red= NumVarOrDefault("root:Packages:WMBkgTint:frameRed", 0)
	green= NumVarOrDefault("root:Packages:WMBkgTint:frameGreen", 0)
	blue= NumVarOrDefault("root:Packages:WMBkgTint:frameBlue", 0)

	PopupMenu frameColor,pos={45,274},size={50,17},disable=disable,proc=TintedBackground#WM_TintPopMenuProc
	PopupMenu frameColor,mode=1,popColor= (red, green, blue),value= #"\"*COLORPOP*\""

	CheckBox frameRGB,pos={25,276},size={16,14},disable=disable,proc=TintedBackground#WM_TintFrameRadioProc,title=""
	CheckBox frameRGB,value= 0,mode=1

	CheckBox frameWindowRGB,pos={25,296},size={133,14},disable=disable,proc=TintedBackground#WM_TintFrameRadioProc,title="Window Background Color"
	CheckBox frameWindowRGB,value= 1,mode=1

	str= StrVarOrDefault("root:Packages:WMBkgTint:whichFrameRadio", "frameRGB")
	WM_SetFrameRadioControls(str)	// updates the global root:Packages:WMBkgTint:whichFrameRadio

	GroupBox tintLayerGroup,pos={5,326},size={176,160},title="Tint Layer                          "

	str= StrVarOrDefault("root:Packages:WMBkgTint:tintLayer", "ProgBack")
	mode= 1+ WhichListItem(str,"ProgBack;UserBack;")

	PopupMenu layer,pos={72,324},size={69,17},proc=TintedBackground#WM_TintLayerPopMenuProc
	PopupMenu layer,mode=mode,popvalue=str,value= #"\"ProgBack;UserBack;\""

	Button clearLayer,pos={13,352},size={160,20},proc=TintedBackground#WM_TintButtonProc,title="Clear ProgBack Layer"
	Button doit,pos={13,383},size={160,20},proc=TintedBackground#WM_TintButtonProc,title="Replace ProgBack with Tint"

	Variable/G root:Packages:WMBkgTint:tintPlotAreaOnly
	CheckBox plotAreaOnly,pos={14,413},size={117,14},title="Tint only the Plot Area"
	CheckBox plotAreaOnly,variable= root:Packages:WMBkgTint:tintPlotAreaOnly

	Variable checked= NumVarOrDefault("root:Packages:WMBkgTint:restoreLayerCheck", 1)
	Variable/G root:Packages:WMBkgTint:restoreLayerCheck= checked
	CheckBox retoreLayerCheck,pos={14,438},size={141,14},title="Set Drawing Layer back to:"
	CheckBox retoreLayerCheck,value= checked
	
	str= StrVarOrDefault("root:Packages:WMBkgTint:restoreLayer", "UserFront")
	mode= 1+ WhichListItem(str,WM_TintDrawLayers())
	PopupMenu restoreLayerPop,pos={87,457},size={72,17},proc=TintedBackground#WM_TintRestoreLayerPopMenuProc
	PopupMenu restoreLayerPop,mode=mode,popvalue=str,value= #"TintedBackground#WM_TintDrawLayers()"

	TitleBox hint,pos={6,498},size={120,32},title="\\K(65535,0,0) Use the Graph Marquee\rmenu to tint a small area"
	Button help,pos={138,503},size={40,19},proc=TintedBackground#WM_TintHelpButtonProc,title="Help"

	TitleBox previewTitle,pos={187,9},size={38,12},title="Preview",frame=0

	WM_SetTintShape(shape)

	Display/W=(187,30,250,516)/FG=(,,FR,FB)/HOST=# 

	RenameWindow #,G0

	WM_TintUpdatePreview(1)

	ModifyGraph margin=-1
	ModifyGraph mirror=2
	ModifyGraph noLabel=2
	ModifyGraph axThick=0
	SetActiveSubwindow ##
	
	SetWindow TintPanel hook(WM_Tint)=TintedBackground#WM_TintPanelWinHook
	WM_TintEnableControlsForTopWin()
	ControlInfo/W=TintPanel layer
	WM_TintLayerPopMenuProc("layer",V_Value,S_value)
End

// PopupMenu xxx value= TintedBackground#WM_TintDrawLayers()
Function/S WM_TintDrawLayers()
	
	String layers="_none_"
	String kind=WM_TintWindowKind(WinName(0,1+4))	// top graph or layout
	strswitch(kind )
		case "Graph":
			layers="ProgBack;UserBack;ProgAxes;UserAxes;ProgFront;UserFront;"
			break
		case "Layout":
			layers="ProgBack;UserBack;ProgFront;UserFront;"
			break
	endswitch
	return layers
End

// do this during panel activate or just after creation.
Static Function/S WM_TintEnableControlsForTopWin()

	String win= WinName(0,1+4)	// graphs and layouts
	if( strlen(win) == 0 )
		DoWindow/T TintPanel, "Tint Background of Graph or Layout"
		ModifyControlList "doit;clearLayer;" win=TintPanel, disable=2
		return win
	endif
	ModifyControlList "doit;clearLayer;" win=TintPanel, disable=0
	DoWindow/T TintPanel, "Tint Background of "+win

	String kind=WM_TintWindowKind(win)
	Variable isLayout= CmpStr(kind,"Layout") == 0 
	
	// if layout, any graph-specific controls are disabled
	Variable needUpdatePreview= 0
	Variable disable= isLayout ? 2 : 0
	CheckBox tintPlotRGB,win=TintPanel,disable=disable
	CheckBox fadePlotRGB,win=TintPanel,disable=disable
	CheckBox plotAreaOnly,win=TintPanel,disable=disable
	// if graph, hide the Marquee hint if a marquee isn't possible
	Variable hintDisable= 0
	if( CmpStr(kind,"Graph") == 0 )
		if( ItemsInList(TraceNameList(win,";",3)) < 1 )
			hintDisable= 1
		endif
	endif
	String hintText= "\\K(65535,0,0) Use the " + SelectString(isLayout, "Graph", "Layout")+" Marquee\rmenu to tint a small area"
	TitleBox hint,win=TintPanel,disable=hintDisable,title=hintText
	
	if( isLayout )
		// if the plot color radio buttons are checked, un check them and rebuild the color (not the shape)
		ControlInfo/W=TintPanel tintPlotRGB
		if( V_Value )
			CheckBox tintPlotRGB,win=TintPanel, value=0
			CheckBox tintRGB,win=TintPanel, value=1
			ModifyControl lighterTint, win=TintPanel, disable=0
			needUpdatePreview= 1 
		endif
		ControlInfo/W=TintPanel fadePlotRGB
		if( V_Value )
			CheckBox fadePlotRGB,win=TintPanel, value=0
			CheckBox fadeRGB,win=TintPanel, value=1
			ModifyControl lighterFade, win=TintPanel, disable=0
			needUpdatePreview= 1 
		endif
		// if the Set Drawing Layer back to is ProgAxes or UserAxes
		// use ProgFront or UserFront, instead
		ControlInfo/W=TintPanel restoreLayerPop
		strswitch(S_Value)
			case "ProgAxes":
				S_value= "ProgFront"
				break
			case "UserAxes":
				S_value= "UserFront"
				break
		endswitch
		String list= TintedBackground#WM_TintDrawLayers()
		Variable mode= max(1,1+WhichListItem(S_value,list))
		PopupMenu restoreLayerPop,win=TintPanel,popvalue=S_value,mode=mode
	else	// graph
		// see if the plot color is in use and different from what's showing in the Preview
		Variable red=65535, green=65535, blue=65535
		Variable winRed, winGreen, winBlue
		ControlInfo/W=TintPanel fadePlotRGB
		Variable inUse= V_Value
		if( inUse )
			red= NumVarOrDefault("root:Packages:WMBkgTint:fadeRed", 65535)
			green= NumVarOrDefault("root:Packages:WMBkgTint:fadeGreen", 65535)
			blue= NumVarOrDefault("root:Packages:WMBkgTint:fadeBlue", 65535)
		else
			ControlInfo/W=TintPanel tintPlotRGB
			inUse= V_Value
			if( inUse )
				red= NumVarOrDefault("root:Packages:WMBkgTint:tintRed", 65535)
				green= NumVarOrDefault("root:Packages:WMBkgTint:tintGreen", 65535)
				blue= NumVarOrDefault("root:Packages:WMBkgTint:tintBlue", 65535)
			endif
		endif
		if( inUse )
			// check the window's plot color against what was last used
			WMGetGraphPlotBkgColor(win, winRed, winGreen, winBlue)
			needUpdatePreview = (winRed != red) ||(winGreen != green) ||(winBlue != blue)
		endif
	endif
	
	// if the background or plot color has changed, update
	if( 0 == needUpdatePreview )
		red=65535; green=65535;blue=65535
		ControlInfo/W=TintPanel fadeWindowRGB 
		inUse= V_Value
		if( inUse )
			red= NumVarOrDefault("root:Packages:WMBkgTint:fadeRed", 65535)
			green= NumVarOrDefault("root:Packages:WMBkgTint:fadeGreen", 65535)
			blue= NumVarOrDefault("root:Packages:WMBkgTint:fadeBlue", 65535)
		else
			ControlInfo/W=TintPanel frameWindowRGB 
			inUse= V_Value
			if( inUse )
				red= NumVarOrDefault("root:Packages:WMBkgTint:frameRed", 65535)
				green= NumVarOrDefault("root:Packages:WMBkgTint:frameGreen", 65535)
				blue= NumVarOrDefault("root:Packages:WMBkgTint:frameBlue", 65535)
			endif
		endif
		if( inUse )
			// check the window's plot color against what was last used
			WM_TintGetWindowBkgColor(win, winRed, winGreen, winBlue)
			needUpdatePreview = (winRed != red) ||(winGreen != green) ||(winBlue != blue)
		endif
	endif
	
	if( needUpdatePreview )
		WM_TintUpdatePreview(0)
	endif
	return win
End

Static Function/S WM_TintWindowKind(win)
	String win
	
	String kind=""
	if( strlen(win) )
		switch( WinType(win) )
			case 1:
				kind="Graph"
				break
			case 2:
				kind="Table"
				break
			case 3:
				kind="Layout"
				break
			case 5:
				kind="Notebook"
				break
			case 7:
				kind="Panel"
				break
			default:
				kind="Window"
				break
		endswitch
	endif
	return kind
End

Static Function WM_TintAtMarquee()
	
	GetMarquee	// no axes specified means V_left, etc are in points relative to the graph (not plot) area.
	if (V_flag == 0)
		Print "There is no marquee"
	else
		Variable left= V_left, top=V_top, right=V_right, bottom=V_bottom
		DoWindow TintPanel
		if( V_Flag == 0 )
			WM_TintedBkgPanel()
		endif
		ControlInfo/W=TintPanel layer
		String layer= S_Value
		
		String win=WinName(0,1+4)
		Variable plotRelative= WinType(win) == 1	// plotRelative if graph
//		ControlInfo/W=TintPanel plotAreaOnly	
//		plotRelative= plotRelative= && V_Value	// and Tint only the Plot Area is checked.
		WM_TintedBkgArea(win, layer, left, top, right, bottom, 0, plotRelative)	// don't erase, possibly plotRelative
	endif
End


// To do: Set up a kill proc to call KillPICTs on all pictures named "Tint*" and delete the data folder

Static Function/S WM_TintMakeBackFade(shape, reversed, returnToStart, margin)
	String shape
	Variable reversed, returnToStart	// booleans
	Variable margin
	
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:WMBkgTint

	Make/O/N=(256,256) root:Packages:WMBkgTint:backfade=WM_TintValue(shape, reversed, returnToStart, margin, p, q, 256)
	WAVE backfade= root:Packages:WMBkgTint:backfade
	if( margin > 10 )
		strswitch(shape)
			case "rounded square":
			case "square":
				MatrixFilter/N=9 gauss backfade
				break
		endswitch
	endif
	return GetWavesDataFolder(backfade,2)
End

Static Function WM_TintValue(shape, reversed, returnToStart, margin, row, col, n)
	String shape	// "circle", "square"
	Variable reversed, returnToStart	// booleans
	Variable margin, row, col
	Variable n	// number of rows and number of columns
	
	Variable n1= n-1
	Variable c= n1/2
	Variable value=1
	Variable nm= n-margin	// the first pixel in the right-most regions.
	Variable nm1 = nm-1	// the last pixel in the center regions
	strswitch(shape)
		default:
		case "rounded square":	// constant radius corners
			if( margin == 0 )
				break
			endif
			// there are 9 regions for the square fade
			// 0 is the first pixel in the left-most regions
			// margin is the last pixel in the left-most regions
			// margin +1 is the first pixel in the center regions
			Variable radius
			if( row <= margin )
				// left-most regions
				if( col <= margin )
					radius= min(margin,sqrt((margin-row)*(margin-row)+(margin-col)*(margin-col)))// bottom-left
					value= 1-radius/margin
				elseif( col < nm )
					value= row/margin	// middle-left ("middle" is between top and bottom)
				else	// col >= nm
					radius= min(margin,sqrt((margin-row)*(margin-row)+(col-nm1)*(col-nm1)))	// top-left
					value= 1-radius/margin
				endif
			elseif( row < nm )
				// center regions ("center" is between left and right)
				if( col <= margin )
					value= col/margin	// bottom-center
				elseif( col < nm )
					value= 1	// middle-center
				else	// col >= nm
					value= (n1-col)/margin	// top-center
				endif
			else	// row >= nm
				// right-most regions
				if( col <= margin )
					radius= min(margin,sqrt((row-nm1)*(row-nm1)+(margin-col)*(margin-col)))// bottom-right
					value= 1-radius/margin
				elseif( col < nm )
					value= (n1-row)/margin// middle-right ("middle" is between top and bottom)
				else	// col >= nm
					radius= min(margin,sqrt((row-nm1)*(row-nm1)+(col-nm1)*(col-nm1)))	// top-right
					value= 1-radius/margin
				endif
			endif
			break
			
		case "square":	// asymptotic corners
			if( margin == 0 )
				break
			endif
			// there are 9 regions for the square fade
			// 0 is the first pixel in the left-most regions
			// margin is the last pixel in the left-most regions
			// margin +1 is the first pixel in the center regions
			if( row <= margin )
				// left-most regions
				if( col <= margin )
					value= (row*col)/(margin*margin)	// bottom-left
				elseif( col < nm )
					value= row/margin	// middle-left ("middle" is between top and bottom)
				else	// col >= nm
					value= (row*(n1-col))/(margin*margin)	// top-left
				endif
			elseif( row < nm )
				// center regions ("center" is between left and right)
				if( col <= margin )
					value= col/margin	// bottom-center
				elseif( col < nm )
					value= 1	// middle-center
				else	// col >= nm
					value= (n1-col)/margin	// top-center
				endif
			else
				// right-most regions
				if( col <= margin )
					value= ((n1-row)*(col))/(margin*margin) // bottom-right
				elseif( col < nm )
					value= (n1-row)/margin// middle-right ("middle" is between top and bottom)
				else	// col >= nm
					value= ((n1-row)*(n1-col))/(margin*margin) // top-right
				endif
			endif
			break
			
		case "circle":
			// 1+sin() with flat center
			Variable r= sqrt((row-c)*(row-c)+(col-c)*(col-c))	// distance from center towards edge
			Variable edgeR= c-r	// distance from edge towards center
			margin=max(1,margin)
			if( r >= c )
				value= 0
			elseif( edgeR >= (2*margin) )
				value=1
			else
				Variable arg= pi*edgeR/(2*margin)
				value= (1+sin(arg-pi/2))/2
			endif
			break
			
		case "spot":
			// gaussian center
			r= sqrt((row-c)*(row-c)+(col-c)*(col-c))	// distance from center towards edge
			if( r >= c )
				value= 0
			else
				Variable gw= (c-margin)
				value=gauss(row, c, gw, col, c, gw)
				value/=gauss(c, c, gw, c, c, gw)
				edgeR= c-r	// distance from edge towards center
				margin=max(5,min(margin, 20))	// don't overly smooth spots with big margins, and don't leave a hard edge for small margins
				if( edgeR < (2*margin) )
					// smooth the edges down to zero
					arg= pi*edgeR/(2*margin)
					value *= (1+sin(arg-pi/2))/2
				endif
			endif
			break
			
		case "horizontal":
			value= row/(n1)
			break
			
		case "vertical":
			value= col/(n1)
			break
			
		case "Diagonal +45":
			value= ((n1-row)+(n1-col))/(2*n1)
			break

		case "Diagonal -45":
			value= 1-(row+n1-col)/(2*n1)
			break

	endswitch
	if( returnToStart )
		strswitch(shape)
			case "horizontal":
			case "vertical":
			case "Diagonal +45":
			case "Diagonal -45":
				value *= 2
				if( value > 1 )
					value= 2-value
				endif
				value= 1-value
				break
		endswitch
	endif

	if( reversed )
		value= 1-value
	endif
	return max(0,min(1,value))	
End

Static Function/S WM_TintImage(red, green, blue, fadeRed, fadeGreen, fadeBlue)
	Variable red, green, blue	// 0-65535
	Variable fadeRed, fadeGreen, fadeBlue
	
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:WMBkgTint

	if( !exists("root:Packages:WMBkgTint:whiteRGB") )
		Make/O/N=(256,256,3)/B/U root:Packages:WMBkgTint:whiteRGB
		Make/O/N=(256,256,3)/B/U root:Packages:WMBkgTint:tintRGB
	endif
	
	// fill the output with tint
	WAVE tintRGB= root:Packages:WMBkgTint:tintRGB	// the output
	tintRGB[][][0] = min(255,red/256)
	tintRGB[][][1] = min(255,green/256)
	tintRGB[][][2] = min(255,blue/256)

	// blend with white, usually
	WAVE whiteRGB= root:Packages:WMBkgTint:whiteRGB
	whiteRGB[][][0] = min(255,fadeRed/256)
	whiteRGB[][][1] = min(255,fadeGreen/256)
	whiteRGB[][][2] = min(255,fadeBlue/256)
	
	WAVE backfade= root:Packages:WMBkgTint:backfade
	ImageBlend /W= backfade whiteRGB, tintRGB, tintRGB
	
	RemoveImage/Z/W=TintPanel#G0 tintRGB
	AppendImage/W=TintPanel#G0 tintRGB
	ModifyGraph/W=TintPanel#G0 axthick=0, nolabel=2, margin=1
	return GetWavesDataFolder(tintRGB,2)
End


Static Function WM_TintSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	WM_TintUpdatePreview(1)
End

Static Function WM_SetTintShape(popStr)
	String popStr
	
	Variable disable
	String tintGroupTitle, fadeGroupTitle
	Strswitch(popStr)
		case "Square":
		case "Rounded Square":
		case "Circle":
		case "Spot":
			 disable=0	// show margin
			 tintGroupTitle= "Center Tint"
			 fadeGroupTitle= "Edge Tint"
			 break
		default:
			disable=1	// hide margin
			 tintGroupTitle= "Starting Tint"
			 fadeGroupTitle= "Ending Tint"
			break
	endswitch
	ModifyControl margin, win=TintPanel, disable=disable
	ModifyControl return win=TintPanel, disable=(1-disable)
	ModifyControl tintGroup, win=TintPanel, title=tintGroupTitle
	ModifyControl fadeGroup, win=TintPanel, title=fadeGroupTitle

	String/G root:Packages:WMBkgTint:shape= popStr
	
End

Static Function WM_TintShapePopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	WM_SetTintShape(popStr)
	WM_TintUpdatePreview(1)
End


Static Function WM_TintPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	WM_TintUpdatePreview(0)
	ControlInfo/W=TintPanel $ctrlName	// V_Red, V_Green, V_Blue
	Strswitch(ctrlName)
		case "tint":
			Variable/G root:Packages:WMBkgTint:tintRed= V_Red
			Variable/G root:Packages:WMBkgTint:tintGreen= V_Green
			Variable/G root:Packages:WMBkgTint:tintBlue= V_Blue
			WM_TintRadioProc("tintRGB",1)
			break
		case "fadeColor":
			Variable/G root:Packages:WMBkgTint:fadeRed= V_Red
			Variable/G root:Packages:WMBkgTint:fadeGreen= V_Green
			Variable/G root:Packages:WMBkgTint:fadeBlue= V_Blue
			WM_TintFadeRadioProc("fadeRGB",1)
			break
		case "frameColor":
			Variable/G root:Packages:WMBkgTint:frameRed= V_Red
			Variable/G root:Packages:WMBkgTint:frameGreen= V_Green
			Variable/G root:Packages:WMBkgTint:frameBlue= V_Blue
			WM_TintFrameRadioProc("frameRGB", 1)
			break
	endswitch
End

Static Function WM_SetTintRadioControls(ctrlName)
	String ctrlName

	// Radio button behavior
	Checkbox tintRGB, win=TintPanel, value= CmpStr(ctrlName,"tintRGB")==0
	Checkbox tintPlotRGB, win=TintPanel, value= CmpStr(ctrlName,"tintPlotRGB")==0
	Variable disable= CmpStr(ctrlName,"tintRGB")==0 ? 0 : 2
	ModifyControl lighterTint win=TintPanel, disable=disable

	String/G root:Packages:WMBkgTint:whichTintRadio= ctrlName
End

Static Function WM_TintRadioProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	WM_SetTintRadioControls(ctrlName)
	WM_TintUpdatePreview(0)
End


Static Function WM_SetFadeRadioControls(ctrlName)
	String ctrlName

	// Radio button behavior
	Checkbox fadeRGB, win=TintPanel, value= CmpStr(ctrlName,"fadeRGB")==0
	Checkbox fadePlotRGB, win=TintPanel, value= CmpStr(ctrlName,"fadePlotRGB")==0
	Checkbox fadeWindowRGB, win=TintPanel, value= CmpStr(ctrlName,"fadeWindowRGB")==0
	Variable disable= CmpStr(ctrlName,"fadeRGB")==0 ? 0 : 2
	ModifyControl lighterFade win=TintPanel, disable=disable

	String/G root:Packages:WMBkgTint:whichFadeRadio= ctrlName
End

Static Function WM_TintFadeRadioProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	WM_SetFadeRadioControls(ctrlName)
	WM_TintUpdatePreview(0)
End

static Function WM_TintLighten(red, green, blue)
	Variable &red, &green, &blue	// inputs and outputs, 0-65535
	
	Make/O/N=(1,1,3)/U/W root:Packages:WMBkgTint:rgbhsl
	WAVE rgbhsl= root:Packages:WMBkgTint:rgbhsl
	rgbhsl[0][0][0]= round(red)
	rgbhsl[0][0][1]= round(green)
	rgbhsl[0][0][2]= round(blue)
	
	ImageTransform/O rgb2hsl rgbhsl

	rgbhsl[0][0][2]= min(255, (255 + 3*rgbhsl[0][0][2]) / 4)	// lighten
	ImageTransform/O hsl2rgb rgbhsl

	red=rgbhsl[0][0][0]
	green=rgbhsl[0][0][1]
	blue= rgbhsl[0][0][2]
End

Static Function WM_TintLighterButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	String popName=""
	String radioName=""
	strswitch( ctrlName )
		case "lighterTint":
			popName= "tint"
			radioName="tintRGB"
			break
		case "lighterFade":
			popName= "fadeColor"
			radioName="fadeRGB"
			break
	endswitch
	
	ControlInfo/W=TintPanel $popName	// sets V_Red, V_Green, V_Blue
	
	WM_TintLighten(V_Red, V_Green, V_Blue)
	
	PopupMenu $popName, win=TintPanel, popColor=(V_Red, V_Green, V_Blue )

	strswitch(popName)
		case "tint":
			Variable/G root:Packages:WMBkgTint:tintRed= V_Red
			Variable/G root:Packages:WMBkgTint:tintGreen= V_Green
			Variable/G root:Packages:WMBkgTint:tintBlue= V_Blue
			break
		case "fadeColor":
			Variable/G root:Packages:WMBkgTint:fadeRed= V_Red
			Variable/G root:Packages:WMBkgTint:fadeGreen= V_Green
			Variable/G root:Packages:WMBkgTint:fadeBlue= V_Blue
			break
	endswitch

	ControlInfo/W=TintPanel $radioName
	if( V_Value )
		WM_TintUpdatePreview(0)
	endif
End

Static Function WM_SetFrameRadioControls(ctrlName)
	String ctrlName

	// Radio button behavior
	Checkbox frameRGB, win=TintPanel, value= CmpStr(ctrlName,"frameRGB")==0
	Checkbox frameWindowRGB, win=TintPanel, value= CmpStr(ctrlName,"frameWindowRGB")==0

	String/G root:Packages:WMBkgTint:whichFrameRadio= ctrlName
End

Static Function WM_TintFrameRadioProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	WM_SetFrameRadioControls(ctrlName)
	WM_TintUpdatePreview(0)
End

Static Function WM_TintFrameSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	Variable disable= 0
	if( varNum <= 0 )
		disable=2	// disabled, not hidden
	endif
	
	ModifyControlList "frameColor;frameRGB;frameWindowRGB" disable=disable

	WM_TintUpdatePreview(0)
End


static Function WM_TintReverseCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	WM_TintUpdatePreview(1)
End


Function WM_TintGetWindowBkgColor(win, red, green, blue)
	String win					// input
	Variable &red, &green, &blue	// outputs: 0-65535

	if( WinType(win) == 1 )	// graph
		return WMGetGraphWindowBkgColor(win, red, green, blue)
	else	// presumably layout
		return WMGetLayoutWindowBkgColor(win, red, green, blue)
	endif
End


Static Function WM_TintUpdatePreview(rebuildShape)
	Variable rebuildShape
	
	if( rebuildShape )
		ControlInfo/W=TintPanel shape
		String shape=S_Value
		
		ControlInfo/W=TintPanel reverse
		Variable reversed= V_Value
	
		ControlInfo/W=TintPanel return
		Variable returnToStart= V_Value
	
		ControlInfo/W=TintPanel margin
		WM_TintMakeBackFade(shape,reversed,returnToStart,V_Value)
	endif
	
	// fade color radio buttons: only one is relevant:
	ControlInfo/W=TintPanel fadeRGB
	if( V_Value )
		// color popup
		ControlInfo/W=TintPanel fadeColor	// sets V_red, V_green, V_blue
	else
		// graph's plot or window background color
		ControlInfo/W=TintPanel fadePlotRGB
		if( V_Value )
			// plot area RGB: ModifyGraph gbRGB
			WMGetGraphPlotBkgColor(WinName(0,1), V_red, V_green, V_blue)
		else
			// window RGB: ModifyGraph wbRGB
			WM_TintGetWindowBkgColor(WinName(0,1+4), V_red, V_green, V_blue)
		endif
	endif
	
	// saved for comparison with an activated graph or layout
	Variable/G root:Packages:WMBkgTint:fadeRed = V_red
	Variable/G root:Packages:WMBkgTint:fadeGreen = V_green
	Variable/G root:Packages:WMBkgTint:fadeBlue = V_blue

	NVAR fadeRed= root:Packages:WMBkgTint:fadeRed
	NVAR fadeGreen= root:Packages:WMBkgTint:fadeGreen
	NVAR fadeBlue= root:Packages:WMBkgTint:fadeBlue
	
	// tint color radio buttons: only one is relevant
	ControlInfo/W=TintPanel tintRGB
	if( V_Value )
		ControlInfo/W=TintPanel tint
	else
		// plot area RGB: ModifyGraph gbRGB
		WMGetGraphPlotBkgColor(WinName(0,1), V_red, V_green, V_blue)
	endif

	WM_TintImage(V_red, V_green, V_blue, fadeRed, fadeGreen, fadeBlue)

	// saved for comparison with an activated graph or layout
	Variable/G root:Packages:WMBkgTint:tintRed = V_red
	Variable/G root:Packages:WMBkgTint:tintGreen = V_green
	Variable/G root:Packages:WMBkgTint:tintBlue = V_blue

	// Frame (margin) size
	ControlInfo/W=TintPanel frame	// size in points
	if( V_Value<=0 )
		V_Value=-1	// none
	endif
	ModifyGraph/W=TintPanel#G0 margin=V_Value

	// Frame (margin) color  radio buttons: only one is relevant
	ControlInfo/W=TintPanel frameRGB
	if( V_Value )
		ControlInfo/W=TintPanel frameColor
	else		// window RGB: ModifyGraph wbRGB
		WM_TintGetWindowBkgColor(WinName(0,1+4), V_red, V_green, V_blue)
	endif
	ModifyGraph/W=TintPanel#G0 wbRGB=(V_red, V_green, V_blue)
	ModifyGraph/W=TintPanel#G0 gbRGB=(V_red, V_green, V_blue)

	// saved for comparison with an activated graph or layout
	Variable/G root:Packages:WMBkgTint:frameRed = V_red
	Variable/G root:Packages:WMBkgTint:frameGreen = V_green
	Variable/G root:Packages:WMBkgTint:frameBlue = V_blue
End


Static Function WM_TintedBkgArea(win, layerName, left, top, right, bottom, doErase, plotRelative)
	String win
	String layerName
	Variable left, top, right, bottom	// in points
	Variable doErase, plotRelative

	// copy the Tint panel subwindow's image to the clipboard and paste it into the windows ProgBack or UserBack layer
	SavePICT/Z/WIN=TintPanel#G0/E=-5/RES=(screenresolution)/W=(left, top, right, bottom) as "Clipboard"

	// prepare to draw
	if( doErase )
		SetDrawLayer/W=$win/K $layerName	//removes old PICT from graph
		WM_TintDisposeLayersPICTs(GetUserData(win,"","WM_Tint"),layerName)	// removes all of the layer's PICTs from memory
	else
		SetDrawLayer/W=$win $layerName	
	endif

	// load new PICT
	String name= UniqueName("Tint", 13, 0)
	LoadPICT/Q "Clipboard", $name
	name= StringByKey("NAME",S_info)

	SetDrawEnv/W=$win xcoord=rel, ycoord=rel
	if( WinType(win) == 1 )	// graph
		if( plotRelative )
			SetDrawEnv/W=$win xcoord=prel, ycoord=prel
			GetWindow $win psize	// sets V_left, V_right, V_top, and V_bottom in points
		else
			GetWindow $win gsize	// sets V_left, V_right, V_top, and V_bottom in points
		endif
	else	// layout, presumably
		GetWindow $win logicalpapersize	// sets V_left, V_right, V_top, and V_bottom in points
	endif

	// convert absolute coordinates into relative coordinates
	Variable winWidth= V_right-V_left
	Variable winHeight= V_bottom-V_top
	Variable rLeft= (left - V_left) / winWidth
	Variable rTop= (top-V_top)/winHeight
	Variable rRight=  (right - V_left) / winWidth
	Variable rBottom=  (bottom-V_top)/winHeight
	DrawPICT/W=$win/RABS rLeft, rTop,rRight,rBottom,$name	// RABS requires plot- or window-relative coordinates: 0,0, 1,1 to tints the entire window or entire plot area

	WM_TintRecordPICT(win,layerName,name)
	WM_TintPutLayerBack(win)
	if( WinType(win) == 3 )	// layouts are usually in DelayUpdate mode.
		DoUpdate
	endif
End

// Window hook for the window the tint has been added to.
Static Function WM_TintWindowHook(s)
	STRUCT WMWinHookStruct &s
	Variable statusCode=0

	switch(s.eventCode)
		case 2:	// kill
			// once the window is gone, kill the Tint PICTs if there is no recreation macro
			String cmd
			sprintf cmd, "TintedBackground#WM_TintDisposeUnusedPICTs(\"%s\",\"%s\")", s.winName, GetUserData(s.winName,"","WM_Tint")
			Execute/P/Q/Z cmd
			break
	EndSwitch
	
	return statusCode		// 0 if nothing done, else 1
End

// Window hook for the tint panel itself. See SetWindow
Static Function WM_TintPanelWinHook(s)
	STRUCT WMWinHookStruct &s
	Variable statusCode=0

	String win= StringFromList(0, s.winName, "#")
	switch(s.eventCode)
		case 0: // activate
			if( CmpStr(s.winName,"TintPanel") == 0 )
				WM_TintEnableControlsForTopWin()	// requires "TintPanel"
			endif
			break
		case 6:	// resize
			GetWindow $win wsize	// keep V_left, V_top the same, sets values in points (which is what MoveWindow uses)
			Variable left=V_left
			Variable top=V_top
			Variable width=V_right-V_left
			Variable height=V_bottom-V_top
			// no narrower than the controls on the left, excepting it is okay to hide the Help button
			ControlInfo	tintLayerGroup // sets V_Height, V_Width, V_top, V_left in Panel Units
			// convert to points
			Variable PanelUnitsToPoints = PanelResolution(s.winName) / ScreenResolution
			V_top *= PanelUnitsToPoints
			V_left *= PanelUnitsToPoints
			V_Height *= PanelUnitsToPoints
			V_Width *= PanelUnitsToPoints
			Variable minWidthPoints= V_left+V_Width+36 // +36 to leave a little room for the preview to show up.
			variable minHeightPoints= v_top+V_Height+4
#if IgorVersion() >= 7
			SetWindow $win sizeLimit={minWidthPoints, minHeightPoints, Inf, Inf}
#else
			// allow only width to change
			// compare sizes in points, choose the larger if minimums are violated
			Variable changed=0
			if( width < minWidthPoints )
				width= minWidthPoints
				changed=1
			endif
			if( height < minHeightPoints )
				height= minHeightPoints
				changed=1
			endif
			if( changed )
				MoveWindow/W=$win left, top, left+width, top+height
				statusCode=1
			endif
#endif
			break
	EndSwitch
	
	return statusCode		// 0 if nothing done, else 1
End

#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility between Igor 6 and 7
	String wName
	return 72
End
#endif

Static Function/S WM_TintDisposeLayersPICTs(userData, layerName)
	String userData		// GetUserData(win,"","WM_Tint"), though the window may be gone now
	String layerName	// "ProgBack" or "UserBack", probably
	
	String pictsInLayerList=StringByKey(layerName,userData)	// "Tint0,Tint1,"
	Variable i=0
	do
		String pict= StringFromList(i,pictsInLayerList,",")
		if( strlen(pict) == 0 )
			break
		endif
		KillPICTs/Z $pict
		i+=1
	while(1)
	return pictsInLayerList
End

Static Function WM_TintDisposeUnusedPICTs(win, userData)
	String win
	String userData	// GetUserData(win,"","WM_Tint"), though the window is probably gone now

	if( exists(win) != 5 )
		// window recreation macro doesn't exist
		// kill any Tint picts
		WM_TintDisposeLayersPICTs(userData, "ProgBack")
		WM_TintDisposeLayersPICTs(userData, "UserBack")
	endif
End

// userdata("WM_Tint") format is "<layerName>:pict0,pict1,pict2;<layerName>:pict0,pict1,pict2;"
Static Function WM_TintRecordPICT(win,layerName,pictName)
	String win,layerName,pictName

	String userData=GetUserData(win,"","WM_Tint")
	String layerList= StringByKey(layerName,userData)	// "pict0,pict1,pict2" or "" if no key
	// Add pict to list
	layerList= AddListItem(pictName,RemoveFromList(pictName,layerList,","),",",inf)	// append pictname, ensure it's listed only once
	// update userData with new pict list for the given layer
	userData= ReplaceStringByKey(layerName, userData, layerList)
	// update userData in window
	SetWindow $win, userData(WM_Tint)=userData, hook(WM_Tint)=TintedBackground#WM_TintWindowHook
End

Static Function WM_TintButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String win=WinName(0,1+4)
	if( strlen(win) == 0 )
		DoAlert 0, "No window to tint!"
		return -1
	endif

	ControlInfo/W=TintPanel layer
	String layer= S_Value
	

	strswitch(ctrlName)
		case "doit":
			Variable plotRelative= 0
			if( Wintype(win) == 1 )	// graph
				ControlInfo/W=TintPanel plotAreaOnly
				plotRelative= V_Value
				if( plotRelative )
					GetWindow $win psize	// sets V_left, V_right, V_top, and V_bottom in points
				else
					GetWindow $win gsize	// sets V_left, V_right, V_top, and V_bottom in points
				endif
			else		// layout, presumably
				GetWindow $win logicalpapersize	// sets V_left, V_right, V_top, and V_bottom in points
				// this puts the rectangle beyond the page's margins (to the paper's edge, not the printable area's edge)
				GetWindow $win logicalprintablesize
			endif
			WM_TintedBkgArea(win, layer, V_Left, V_Top, V_Right, V_Bottom, 1, plotRelative)	// , 1=clear layer first
			break
		case "clearLayer":
			SetDrawLayer/W=$win /K $layer
			if( WinType(win) != 1 )	// !graph
				DoUpdate
			endif
			WM_TintDisposeLayersPICTs(GetUserData(win,"","WM_Tint"),layer)
			break
	endswitch

	return 0
End

// new for version
Function/S WM_RemoveTintsFromWindow(win)
	String win
	
	String layersCleared=""
	if( strlen(win) )
		Variable wType = WinType(win) // 0 if no named window
		String userData = GetUserData(win,"","WM_Tint") // "ProgBack:Tint0,;UserBack:Tint1,;"
		if( strlen(userData) )
			String tint = StringByKey("ProgBack",userData)
			if( strlen(tint) )
				SetDrawLayer/W=$win /K ProgBack
				WM_TintDisposeLayersPICTs(userData, "ProgBack")
				layersCleared += "ProgBack;"
			endif
			tint = StringByKey("UserBack",userData)
			if( strlen(tint) )
				SetDrawLayer/W=$win /K UserBack
				WM_TintDisposeLayersPICTs(userData, "UserBack")
				layersCleared += "UserBack;"
			endif
			if( WinType(win) != 1 && strlen(layersCleared) )	// !graph
				DoUpdate
			endif
		endif
	endif
	return layersCleared
End

static Function WM_TintRestoreLayerPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	// sets the draw layer if the checkbox is checked
	WM_TintPutLayerBack(WinName(0,1+4))
	String/G root:Packages:WMBkgTint:restoreLayer= popStr
End

static Function WM_TintIsMacintosh()

	String info= IgorInfo(2)	// If selector  is 2, IgorInfo returns the name of the current platform: "Macintosh" or "Windows".
	return CmpStr(info,"Macintosh") == 0
End

static Function WM_TintLayerPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Button clearLayer, win=TintPanel, title="Clear "+popStr+" Layer"
	String style= ""
	if( WM_TintIsMacintosh() )
		style="\\f01"
	endif
	Button doit, win=TintPanel, title=style+"Replace "+popStr+" with Tint"
	String/G root:Packages:WMBkgTint:tintLayer= popStr
End


Static Function WM_TintPutLayerBack(win)
	String win
	
	if( strlen(win) )
		Controlinfo/W=TintPanel retoreLayerCheck
		if( V_Value )
			Controlinfo/W=TintPanel restoreLayerPop
			if( WinType(win) != 1 )	// layout doesn't have ProgAxes or UserAxes layers
				if( CmpStr(S_value,"ProgAxes") == 0 )
					S_value="ProgFront"
				elseif( CmpStr(S_value,"UserAxes") == 0 )
					S_Value= "UserFront"
				endif
			endif
			SetDrawLayer/W=$win $S_value
			return 1
		endif
	endif
	return 0
End

Static Function WM_TintHelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic "Tinted Window Background"  // in TintedWindowBackground.ihf
End

