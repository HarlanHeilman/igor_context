#pragma rtGlobals=1		// Use modern global access method.
#pragma ModuleName=WMRGBHSLColorPicker
#pragma version=9.02 // released with Igor 9.02
#pragma Igorversion=7 // requires Igor 7

// RGB (Red, Green, Blue) and HSL (Hue, Saturation, Lightness) color picker panel for multiple numeric ranges.
// At most one checked range can be automatically copied to the clipboard when a new color is chosen.
// Version 5.02: added 0...1 range for Gizmo colors.
// Version 5.03: Fixed gizmo blue values, added HTML Hex, and text->color parsing.
// Version 8.05: Igor 7 compatibility, including PanelResolution.
// Version 9.02: Slightly repositioned controls.

Menu "Misc"
	"RGB and HSL Color Picker", /Q, WMRGBHSLColorPicker#ColorPicker()
End

Static Function ColorPicker()
	DoWindow/F WMRGBHSLColorPickers
	if( V_Flag == 0 )
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:ColorPicker
		Variable/G root:Packages:ColorPicker:red
		Variable/G root:Packages:ColorPicker:green
		Variable/G root:Packages:ColorPicker:blue
		String/G root:Packages:ColorPicker:rgb65535
		String/G root:Packages:ColorPicker:rgb255
		String/G root:Packages:ColorPicker:rgb100
		String/G root:Packages:ColorPicker:rgb1
		String/G root:Packages:ColorPicker:hsl65535
		String/G root:Packages:ColorPicker:hsl255
		String/G root:Packages:ColorPicker:hsl100
		String/G root:Packages:ColorPicker:rgbHex	// 6 hex digits #FFFFFF = white
		String/G root:Packages:ColorPicker:rgbHex3	// 3 hex digits #FFF = white
		// display panel in the small size
		NewPanel /K=1 /W=(412,42,738,245) as "RGB and HSL Color Picker"
		DoWindow/C WMRGBHSLColorPickers
		ModifyPanel fixedSize=1, noEdit=1
		PopupMenu colorpop,pos={77,3},size={50,20},proc=WMRGBHSLColorPicker#ColorPopMenuProc
		PopupMenu colorpop,value= #"\"*COLORPOP*\""
		NVAR red= root:Packages:ColorPicker:red
		NVAR green= root:Packages:ColorPicker:green
		NVAR blue= root:Packages:ColorPicker:blue
		PopupMenu colorpop,mode=1,popColor= (red,green,blue)
		
		GroupBox rgbGroup,pos={6,19},size={276,167},title="RGB"
		SetVariable rgb65535,pos={38,38},size={231,19},title="0...65535"
		SetVariable rgb65535,value= root:Packages:ColorPicker:rgb65535,bodyWidth= 180
		SetVariable rgb65535,proc=WMRGBHSLColorPicker#WMColorPickerSetVarProc
		 
		SetVariable rgb255,pos={51,63},size={218.00,19.33},title="0...255"
		SetVariable rgb255,value= root:Packages:ColorPicker:rgb255,bodyWidth= 180
		SetVariable rgb255,proc=WMRGBHSLColorPicker#WMColorPickerSetVarProc

		SetVariable rgb100,pos={51,88},size={218,19},title="0...100"
		SetVariable rgb100,value= root:Packages:ColorPicker:rgb100,bodyWidth= 180
		SetVariable rgb100,proc=WMRGBHSLColorPicker#WMColorPickerSetVarProc

		SetVariable rgb1,pos={27,113},size={242.00,19.33},title="Gizmo 0...1"
		SetVariable rgb1,value= root:Packages:ColorPicker:rgb1,bodyWidth= 180
		SetVariable rgb1,proc=WMRGBHSLColorPicker#WMColorPickerSetVarProc

		// HTML Hex added for Igor 5.03
		// Add 25 to following vertical position and some heights.
		SetVariable rgbHex,pos={30,138},size={239,19},title="HTML Hex"
		SetVariable rgbHex,value= root:Packages:ColorPicker:rgbHex,bodyWidth= 180
		SetVariable rgbHex,proc=WMRGBHSLColorPicker#WMColorPickerSetVarProc
		
		// HTML Hex 3 added for Igor 5.03b3
		SetVariable rgbHex3,pos={20,163},size={249.00,19.33},title="HTML Hex 3"
		SetVariable rgbHex3,value= root:Packages:ColorPicker:rgbHex3,bodyWidth= 180
		SetVariable rgbHex3,proc=WMRGBHSLColorPicker#WMColorPickerSetVarProc
		// Add 25 more to following vertical position and some heights.

		CheckBox showHSL,pos={2,186},size={12.67,12.67},proc=WMRGBHSLColorPicker#DisclosureCheckProc,title=""
		CheckBox showHSL,value= 0, mode=2
		GroupBox hslGroup,pos={6,195},size={276,92},disable=1,title="HSL"
		SetVariable hsl65535,pos={38,213},size={231.00,19.33},disable=1,title="0...65535"
		SetVariable hsl65535,value= root:Packages:ColorPicker:hsl65535,bodyWidth= 180
		SetVariable hsl65535,proc=WMRGBHSLColorPicker#WMColorPickerSetVarProc

		SetVariable hsl255,pos={51,239},size={218.00,19.33},disable=1,title="0...255"
		SetVariable hsl255,value= root:Packages:ColorPicker:hsl255,bodyWidth= 180
		SetVariable hsl255,proc=WMRGBHSLColorPicker#WMColorPickerSetVarProc
		
		SetVariable hsl100,pos={51,264},size={218,19},disable=1,title="0...100"
		SetVariable hsl100,value= root:Packages:ColorPicker:hsl100,bodyWidth= 180
		SetVariable hsl100,proc=WMRGBHSLColorPicker#WMColorPickerSetVarProc

		TitleBox copyTitle,pos={244.00,2.00},size={79.00,28.00}
		TitleBox copyTitle,title="\\JRAutomatically\rcopy to Clipboard",fSize=10
		TitleBox copyTitle,frame=0,anchor=RT

		GroupBox copyGroup,pos={285,31},size={25,257}
		
		CheckBox check65535,pos={289,38},size={14,14},proc=WMRGBHSLColorPicker#ColorPickerCheckProc,title=""
		CheckBox check65535,value= 1
		CheckBox check255,pos={289,63},size={14,14},proc=WMRGBHSLColorPicker#ColorPickerCheckProc,title=""
		CheckBox check100,pos={289,88},size={14,14},proc=WMRGBHSLColorPicker#ColorPickerCheckProc,title=""
		CheckBox check1,pos={289,113},size={14,14},proc=WMRGBHSLColorPicker#ColorPickerCheckProc,title=""
		
		// HTML Hex added for Igor 5.03
		// Add 25 to following vertical position and some heights.
		Checkbox checkHex, pos={289,138},size={14,14},proc=WMRGBHSLColorPicker#ColorPickerCheckProc,title=""
		Checkbox checkHex3, pos={289,163},size={14,14},proc=WMRGBHSLColorPicker#ColorPickerCheckProc,title=""

		CheckBox checkHSL65535,pos={289,214},size={14,14},disable=1,proc=WMRGBHSLColorPicker#ColorPickerCheckProc,title=""
		CheckBox checkHSL255,pos={289,239},size={14,14},disable=1,proc=WMRGBHSLColorPicker#ColorPickerCheckProc,title=""
		CheckBox checkHSL100,pos={289,264},size={14,14},disable=1,proc=WMRGBHSLColorPicker#ColorPickerCheckProc,title=""

		ColorPopMenuProc("colorpop",1,"")

		SVAR/Z checkedCtrl=root:Packages:ColorPicker:checkedCtrl
		if( SVAR_Exists(checkedCtrl) )
			ColorPickerCheckProc(checkedCtrl,1)
		endif
		NVAR/Z showHSL=root:Packages:ColorPicker:showHSL
		if( NVAR_Exists(showHSL) && showHSL )
			DisclosureCheckProc("showHSL",1)
			CheckBox showHSL,value= 1, mode=2
		endif
	endif
End

// sets the color popup and the texts, copies the checked text to the clipboard
Static Function SetPickerRGB(red, green, blue)
	Variable red, green, blue

	NVAR r= root:Packages:ColorPicker:red
	NVAR g= root:Packages:ColorPicker:green
	NVAR b= root:Packages:ColorPicker:blue

	r= red
	g= green
	b= blue

	SVAR rgb65535= root:Packages:ColorPicker:rgb65535
	sprintf rgb65535, "(%d,%d,%d)", red, green, blue

	SVAR rgb255= root:Packages:ColorPicker:rgb255
	sprintf rgb255, "(%d,%d,%d)", round(red * 255 / 65535), round(green* 255 / 65535), round(blue* 255 / 65535)

	SVAR rgb100= root:Packages:ColorPicker:rgb100
	sprintf rgb100, "(%d,%d,%d)", round(red * 100 / 65535), round(green* 100 / 65535), round(blue* 100 / 65535)
	
	SVAR rgb1= root:Packages:ColorPicker:rgb1
	sprintf rgb1, "(%g,%g,%g)", red / 65535, green / 65535, blue / 65535
	
	SVAR rgbHex= root:Packages:ColorPicker:rgbHex
	sprintf rgbHex, "#%02X%02X%02X", round(red * 255 / 65535), round(green* 255 / 65535), round(blue* 255 / 65535)
	
	SVAR rgbHex3= root:Packages:ColorPicker:rgbHex3
	sprintf rgbHex3, "#%01X%01X%01X", round(red * 15 / 65535), round(green* 15 / 65535), round(blue* 15 / 65535)
	
	Make/O/N=(1,1,3)/U/W root:Packages:ColorPicker:rgbhsl
	WAVE rgbhsl= root:Packages:ColorPicker:rgbhsl
	rgbhsl[0][0][0]= round(red)
	rgbhsl[0][0][1]= round(green)
	rgbhsl[0][0][2]= round(blue)
	
	ImageTransform/O rgb2hsl rgbhsl
	
	Variable hue=rgbhsl[0][0][0]
	Variable sat=rgbhsl[0][0][1]
	Variable light= rgbhsl[0][0][2]

	SVAR hsl255= root:Packages:ColorPicker:hsl255
	sprintf hsl255, "(%d,%d,%d)",  hue, sat, light  

	SVAR hsl65535= root:Packages:ColorPicker:hsl65535
	sprintf hsl65535, "(%d,%d,%d)", round(hue * 65535 / 255), round(sat* 65535 / 255), round(light* 65535 / 255)
	
	SVAR hsl100= root:Packages:ColorPicker:hsl100
	sprintf hsl100, "(%d,%d,%d)", round(hue * 100 / 255), round(sat* 100 / 255), round(light* 100 / 255)

	ControlInfo check65535
	if( V_Value )
		PutScrapText rgb65535
	endif
	ControlInfo check255
	if( V_Value )
		PutScrapText rgb255
	endif
	ControlInfo check100
	if( V_Value )
		PutScrapText rgb100
	endif
	ControlInfo check1
	if( V_Value )
		PutScrapText rgb1
	endif
	ControlInfo checkHex
	if( V_Value )
		PutScrapText rgbHex
	endif
	ControlInfo checkHex3
	if( V_Value )
		PutScrapText rgbHex3
	endif
	ControlInfo checkHSL65535
	if( V_Value )
		PutScrapText hsl65535
	endif
	ControlInfo checkHSL255
	if( V_Value )
		PutScrapText hsl255
	endif
	ControlInfo checkHSL100
	if( V_Value )
		PutScrapText hsl100
	endif
	
End

Static Function ColorPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	ControlInfo $ctrlName	// sets V_Red, V_Green, V_Blue
	
	SetPickerRGB(V_Red, V_Green, V_Blue)
End

Static Function ColorPickerCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	if( checked )
		Checkbox check65535 value=CmpStr(ctrlName,"check65535")==0
		Checkbox check255 value=CmpStr(ctrlName,"check255")==0
		Checkbox check100 value=CmpStr(ctrlName,"check100")==0
		Checkbox check1 value=CmpStr(ctrlName,"check1")==0
		Checkbox checkHex value=CmpStr(ctrlName,"checkHex")==0

		Checkbox checkHSL65535 value=CmpStr(ctrlName,"checkHSL65535")==0
		Checkbox checkHSL255 value=CmpStr(ctrlName,"checkHSL255")==0
		Checkbox checkHSL100 value=CmpStr(ctrlName,"checkHSL100")==0
		String/G root:Packages:ColorPicker:checkedCtrl=ctrlName
	else
		Checkbox $ctrlName value=0
		String/G root:Packages:ColorPicker:checkedCtrl=""
	endif
End

#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)	// For compatibility with Igor7
	String wName
	return 72
End
#endif

Static Function DisclosureCheckProc(ctrlName,showHSL) : CheckBoxControl
	String ctrlName
	Variable showHSL

	String hslControls="hslGroup;hsl65535;hsl255;hsl100;checkHSL65535;checkHSL255;checkHSL100;"

	String win="WMRGBHSLColorPickers"

	ControlInfo/W=$win showHSL
	Variable revealBottom = V_Top + V_Height + 2 // panel units 

	GetWindow $win wsize	// V_left, V_right, V_top, and V_bottom in points from the top left of the screen in points
	Variable heightInPanelUnits
	if( showHSL )
		heightInPanelUnits= 245+25+25
		ModifyControlList/Z hslControls, disable=0	// show
		GroupBox copyGroup,pos={285,29},size={25,208+25+25}
	else
		heightInPanelUnits= 153+25+25
		ModifyControlList/Z hslControls, disable=1	// hide
		GroupBox copyGroup,pos={285,29},size={25,107+25+25}

		// uncheck hidden controls
		Checkbox checkHSL65535, value=0	// uncheck
		Checkbox checkHSL255, value=0	// uncheck
		Checkbox checkHSL100, value=0	// uncheck
		String/G root:Packages:ColorPicker:checkedCtrl
		SVAR checkedCtrl= root:Packages:ColorPicker:checkedCtrl
		if( strsearch(checkedCtrl, "checkHSL",0) >= 0 )
			checkedCtrl= ""
		endif
	endif

	Variable/G root:Packages:ColorPicker:showHSL= showHSL

	V_bottom = V_top + heightInPanelUnits * PanelResolution(win) / ScreenResolution
	MoveWindow V_left, V_top, V_right, V_bottom
End

Static Function WMColorPickerSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	// parse the text to get the color, then set all the others and the color popup
	ControlInfo/W=WMRGBHSLColorPickers colorpop	// sets V_Red, V_Green, V_Blue, which we change ONLY IF we can parse the text
	Variable parsed= 0	// set to one if V_Red, V_Green, V_Blue are set from parsing varStr
	Variable convertHSL=0
	
	strswitch(ctrlName)
		case "rgb65535":
			sscanf varStr, "(%d, %d, %d)", V_Red, V_Green, V_Blue 	// sscanf operation sets the variable V_flag to the number of values read
			parsed= V_flag == 3
			break
		case "rgb255":
			sscanf varStr, "(%d, %d, %d)", V_Red, V_Green, V_Blue 	// sscanf operation sets the variable V_flag to the number of values read
			parsed= V_flag == 3
			V_Red = round(V_Red * 65535 / 255)
			V_Green = round(V_Green * 65535 / 255)
			V_Blue = round(V_Blue * 65535 / 255)
			break
		case "rgb100":
			sscanf varStr, "(%d, %d, %d)", V_Red, V_Green, V_Blue 	// sscanf operation sets the variable V_flag to the number of values read
			parsed= V_flag == 3
			V_Red = round(V_Red * 65535 / 100)
			V_Green = round(V_Green * 65535 / 100)
			V_Blue = round(V_Blue * 65535 / 100)
			break
		case "rgb1":
			sscanf varStr, "(%g, %g, %g)", V_Red, V_Green, V_Blue 	// sscanf operation sets the variable V_flag to the number of values read
			parsed= V_flag == 3
			V_Red = round(V_Red * 65535)
			V_Green = round(V_Green * 65535)
			V_Blue = round(V_Blue * 65535)
			break
		case "rgbHex":
			sscanf varStr, "#%2x%2x%2x", V_Red, V_Green, V_Blue 	// sscanf operation sets the variable V_flag to the number of values read
			parsed= V_flag == 3
			V_Red = round(V_Red * 65535 / 255)
			V_Green = round(V_Green * 65535 / 255)
			V_Blue = round(V_Blue * 65535 / 255)
			break
		case "rgbHex3":
			sscanf varStr, "#%1x%1x%1x", V_Red, V_Green, V_Blue 	// sscanf operation sets the variable V_flag to the number of values read
			parsed= V_flag == 3
			V_Red = round(V_Red * 65535 / 15)
			V_Green = round(V_Green * 65535 / 15)
			V_Blue = round(V_Blue * 65535 / 15)
			break
		case "hsl65535":
			sscanf varStr, "(%d, %d, %d)", V_Red, V_Green, V_Blue 	// sscanf operation sets the variable V_flag to the number of values read
			parsed= V_flag == 3
			convertHSL=1	// V_Red, V_Green, V_Blue are actually HSL values
			break
		case "hsl255":
			sscanf varStr, "(%d, %d, %d)", V_Red, V_Green, V_Blue 	// sscanf operation sets the variable V_flag to the number of values read
			parsed= V_flag == 3
			V_Red = round(V_Red * 65535 / 255)
			V_Green = round(V_Green * 65535 / 255)
			V_Blue = round(V_Blue * 65535 / 255)
			convertHSL=1	// V_Red, V_Green, V_Blue are actually HSL values
			break
		case "hsl100":
			sscanf varStr, "(%d, %d, %d)", V_Red, V_Green, V_Blue 	// sscanf operation sets the variable V_flag to the number of values read
			parsed= V_flag == 3
			V_Red = round(V_Red * 65535 / 100)
			V_Green = round(V_Green * 65535 / 100)
			V_Blue = round(V_Blue * 65535 / 100)
			convertHSL=1	// V_Red, V_Green, V_Blue are actually HSL values
			break
	endswitch

	if( parsed )
		if( convertHSL )
			// convert HSL to RGB:
			Make/O/N=(1,1,3)/U/W root:Packages:ColorPicker:rgbhsl
			WAVE rgbhsl= root:Packages:ColorPicker:rgbhsl
			rgbhsl[0][0][0]= round(V_Red)	// hue
			rgbhsl[0][0][1]= round(V_Green)	// saturation
			rgbhsl[0][0][2]= round(V_Blue)	// lightness
			ImageTransform/O hsl2rgb rgbhsl
			V_Red=rgbhsl[0][0][0]
			V_Green=rgbhsl[0][0][1]
			V_Blue= rgbhsl[0][0][2]
		endif

		PopupMenu colorpop, win= WMRGBHSLColorPickers, popColor=(V_Red, V_Green, V_Blue)
		SetPickerRGB(V_Red, V_Green, V_Blue)
		ControlInfo/W=WMRGBHSLColorPickers $ctrlName
		SVAR sv= $(S_DataFolder+varName)
		sv= varStr	// overwrite changes made by SetPickerRGB
	endif
End
