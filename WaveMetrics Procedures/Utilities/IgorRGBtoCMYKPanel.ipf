#pragma rtGlobals=1		// Use modern global access method.
#pragma version=6.2		// shipped with Igor 6.2
#pragma IgorVersion=6.1
#pragma independentModule=RGB2CMYK
#pragma moduleName=IgorRGBtoCMYK

#include <SaveRestoreWindowCoords>
#include <colorSpaceConversions>, version >= 6.1	// for RGB16toCMYK
#include <Graph Utility Procs>, version >= 6.2		// for fixed WMGetColorsFromGraph()

//	The IgorRGBtoCMYKPanel procedure implements a table-like editor to override
//	the conversions Igor will perform when exporting RGB graphics in the CMYK format.
//	(See Exporting Colors (Macintosh) or Exporting Colors (Windows) for details.)
//
//	Revision History:
//		JP090325, version 6.1 (initial version)
//		JP100203, version 6.2 GetColorsFromTopGraph() calls WMGetColorsFromTopGraph() for more complete color list, strips boring colors.
//

// ++++++++ Public routines:
//
//	RGB2CMYK#ShowIgorRGBtoCMYKPanel() - displays the editor panel.
//	RGB2CMYK#LoadRGBCMYKOverrides() - for loading RGB2CMYK.txt files.
//	RGB2CMYK#CloseIgorRGBtoCMYKPanel() - displays the editor panel.
//


// ++++++++ Menus

Menu "Misc", hideable
	"Edit RGB to CMYK Conversions", ShowIgorRGBtoCMYKPanel()
End

// ++++++++ Constants

Static StrConstant ksPanelName="IgorRGBtoCMYKPanel"

// Listbox selWave constants
Static Constant kCellisCheckboxMask	= 0x20
Static Constant kCellisCheckedMask	= 0x10
Static Constant kCellisEditableMask	= 0x02
Static Constant kCellIsSelectedMask	= 0x01

// EditorColorWave constants
Static Constant kFirstRowContainingRGBCMYK= 3		// row 0 is "special" and row 1 is white (to display RGB text on a dark color), and row 2 is red for errors


// +++++++ Data Folder routines

Static Function/S PanelDF()
	return "root:Packages:IgorRGBtoCMYKPanel"
End

Static Function/S PanelDFVar(varName)
	String varName
	
	String df= PanelDF()
	if( !DataFolderExists(df) )
		NewDataFolder/O root:Packages
		NewDataFolder/O $df
	endif
	return df+":"+PossiblyQuoteName(varName)	// "root:Packages:IgorRGBtoCMYKPanel:'my variable'"
End

Static Function/S SetPanelDF()

	String oldDF= GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O/S $PanelDF()	// DF is left pointing here
	return oldDF
End


// +++++++ List Waves

// use column or layer dimension labels to access the list waves.

// M_IgorRGBtoCMYK columns:
//
//		%red, %green, %blue, %cyan, %magenta, %yellow, %black

// EditorColorWave columns
//		%red, %green, %blue %Enabled,%cyan, %magenta, %yellow, %black

// EditorTextWave and EditorSelWave
//		%Enabled, %rgb, %cyan, %magenta, %yellow, %black, %previewCMYK


// if M_IgorRGBtoCMYK doesn't exist, then the list is created initially with just red (the default trace color)
//
// Returns 1 if red was put into the list, 0 if the lists were created with zero text rows.

Static Function MakeListboxWaves()

	Variable initFrom_M_IgorRGBtoCMYK= Have_M_IgorRGBtoCMYK()

	WAVE/Z/T EditorTextWave= $PanelDFVar("EditorTextWave")
	if( initFrom_M_IgorRGBtoCMYK && WaveExists(EditorTextWave) && DimSize(EditorTextWave,1) >= 6 )
		// list waves already exist, so we just transfer from M_IgorRGBtoCMYK
		Load_M_IgorRGBtoCMYK()
		return DimSize(EditorTextWave,0)
	endif

	Variable initialTextRows= max(1,initFrom_M_IgorRGBtoCMYK)

	String oldDF=  SetPanelDF()
	
	// Listbox listWave
	// this text wave is what shows up in the listbox
	Make/O/N=(initialTextRows,7)/T EditorTextWave

	// selwave is multi-purpose and thus multi-dimensional
	// it has the same rows and columns as the text wave, but it has layers, onion boy!
	Make/O/N=(initialTextRows, 7, 3) EditorSelWave

	SetDimLabel 1, 0, Enabled,	EditorTextWave, EditorSelWave	// checkbox
	SetDimLabel 1, 1, rgb,		EditorTextWave, EditorSelWave	// text of rgb values, colored with that defined color. The user can edit this.
	SetDimLabel 1, 2, cyan,		EditorTextWave, EditorSelWave	// cyan value, 0-100 ala Photoshop or 0-1 as defined for M_IgorRGBtoCMYK, the user is expected to edit these
	SetDimLabel 1, 3, magenta,	EditorTextWave, EditorSelWave	// magenta
	SetDimLabel 1, 4, yellow,	EditorTextWave, EditorSelWave	// yellow
	SetDimLabel 1, 5, black,	EditorTextWave, EditorSelWave		// black
	SetDimLabel 1, 6, previewCMYK, EditorTextWave, EditorSelWave	// blank, just a place where the simulated CMYK is displayed.

	IndicateSortingOrder(-1,0,0)

	// selWave's layer 0 is actually where selection (and checkbox-in-cell and checked state) are stored for each row and column.
	EditorSelWave[][%Enabled][0]		= kCellisCheckboxMask | kCellisCheckedMask
	EditorSelWave[][%rgb][0]			= kCellisEditableMask
	EditorSelWave[][%cyan][0]			= kCellisEditableMask
	EditorSelWave[][%magenta][0]		= kCellisEditableMask
	EditorSelWave[][%yellow][0]			= kCellisEditableMask
	EditorSelWave[][%black][0]			= kCellisEditableMask
	EditorSelWave[][%previewCMYK][0]	= 0

	// selWave's layers 1 and 2 contain ROW INDEXES into EditorColorWave to select the background (layer 1) or text (layer 2) colors for each rolw and column
	SetDimLabel 2,1,backColors,EditorSelWave
	SetDimLabel 2,2,foreColors,EditorSelWave

	EditorSelWave[][][%backColors]= 0
	EditorSelWave[][%rgb][%backColors]= p+kFirstRowContainingRGBCMYK	// see how the first rows in EditorColorWave are used, below.
	EditorSelWave[][][%foreColors]= 0

	// Listbox colorwave

	// Listbox colorwave uses an at-least 3 column numeric wave containing red, green and blue values as at least short unsigned integers.
	// Used in conjunction with planes in selWave to define fore- and background colors for individual cells.
	// RGB values range from 65535 (full on) to 0.
	
	// We define two colors per row of the text wave: one for the red RGB and one for the CMYK simulation.
	
	// Note: the editor color wave has 3 initial colors:
	// row 0 = (0,0,0) = default colors (foreground and background)
	// row 1 = (65535,65535,65535) = white for white text on dark rgb backgrounds
	// row 2 = (65535,0,0) = red for error text
	//
	// row 3 is background color for the %rgb column of the list's first row
	// row 4 is the cmyk simulation color for the list's first row

	
	Make/O/N=(initialTextRows*2+kFirstRowContainingRGBCMYK, 8) EditorColorWave= 0
											
	// +2 is for the first two rows which are reserved for black and white and aren't transferred to M_IgorRGBtoCMYK
	//EditorColorWave[0][] = 0			// index 0 is special: it means use the default colors. Therefore the value of this row is superfluous.
	EditorColorWave[1][0] = 65535		// white for text on dark colors
	EditorColorWave[1][1] = 65535		// white for text on dark colors
	EditorColorWave[1][2] = 65535		// white for text on dark colors
	EditorColorWave[2][0] = 65535		// red for error text

	SetDimLabel 1, 0, red, EditorColorWave			// first 3 cols are used by ListBox colorWave
	SetDimLabel 1, 1, green, EditorColorWave
	SetDimLabel 1, 2, blue, EditorColorWave
	
	SetDimLabel 1, 3, Enabled, EditorColorWave		// These columns aren't used by ListBox selwave,
	SetDimLabel 1, 4, cyan, EditorColorWave			//  but I use them to store the default Igor rgb->cmyk conversions for comparison with the user's values.
	SetDimLabel 1, 5, magenta, EditorColorWave
	SetDimLabel 1, 6, yellow, EditorColorWave
	SetDimLabel 1, 7, black, EditorColorWave

	SetDataFolder oldDF

	if( initFrom_M_IgorRGBtoCMYK )
		Load_M_IgorRGBtoCMYK()
	else
		SetRowRGB(0,65535,0,0,1)	// pure red is the default trace color
		Update_M_IgorRGBtoCMYK()
	endif
	
	return initialTextRows
End	

// sets the listBox's
//	1) colorwave[textRow*2+kFirstRowContainingRGBCMYK][]
//	 and colorwave[textRow*2+1+kFirstRowContainingRGBCMYK][]
//	to the RGB and CMYK simulation colors, respectively.
//
//	2) text listWave[textRow][] text content
//
//	3) selWave[textRow][] columns for proper enabling, editing, checkbox state, index into color table, etc.
//
//	4) updates M_IgorRGBtoCMYK via Update_M_IgorRGBtoCMYK() so that only enabled entries are installed.
//
Static Function SetRowRGB(textRow, red, green, blue, enableChecked)
	Variable textRow
	Variable red, green, blue	// 0-65535
	Variable enableChecked		// 0 or 1 for clearing or checking the Enable checkbox, -1 for don't toggle.
	
// 1)
	WAVE EditorColorWave=  $PanelDFVar("EditorColorWave")
	
	// the rgbRow contains the red, green, blue and cyan,magenta,yellow,black
	// that eventually get to the M_IgorRGBtoCMYK wave
	Variable rgbRow= textRow*2 + kFirstRowContainingRGBCMYK	// zero-based

	Variable neededRows= rgbRow+2	// another one for CMYKSimulationRow (see below)
	Variable currentRows= DimSize(EditorColorWave,0)
	Variable initializeRow= currentRows < neededRows
	if( initializeRow )
		Variable additionalRows= neededRows - currentRows
		InsertPoints/M=0 currentRows, additionalRows, EditorColorWave
	endif
	
	EditorColorWave[rgbRow][%red]= red
	EditorColorWave[rgbRow][%green]= green
	EditorColorWave[rgbRow][%blue]= blue

	if( enableChecked >= 0 )
		EditorColorWave[rgbRow][%Enabled]= enableChecked
	endif

	// set the initial Igor-generated c,m,y,k values these shadow what the user enters in EditorTextWave as text 
	Variable cyan,magenta,yellow,black	// 0-1
	RGB16toCMYK(red,green,blue,cyan,magenta,yellow,black)	

//	2) text listWave[textRow][] text content

	// Listbox listWave
	// and Listbox selwave have the same rows and columns as the text wave
	// but selwave has layers:	[0] is for selection,
	//							[%backcolors] and [%forecolors] are for cell colors,
	//							and contain row indexes into editorColorWave
	
	WAVE/T EditorTextWave= $PanelDFVar("EditorTextWave")

	neededRows= textRow+1
	currentRows= DimSize(EditorTextWave,0)
	initializeRow= currentRows < neededRows
	if( initializeRow )
		additionalRows= neededRows - currentRows
		InsertPoints/M=0 currentRows, additionalRows, EditorTextWave
	endif

	EditorTextWave[textRow][%Enabled] = num2istr(textRow)	// row #for error messages

	// print the rgb
	EditorTextWave[textRow][%rgb] = num2istr(red)+","+num2istr(green)+","+num2istr(blue)
	

	//EditorTextWave[textRow][%previewCMYK] text is blank unless an error in the values was found; it's SetRowCMYK's responsibility.

//	3) selWave[textRow][] columns for proper enabling, editing, checkbox state, index into color table, etc.
	WAVE EditorSelWave= $PanelDFVar("EditorSelWave")
	currentRows= DimSize(EditorSelWave,0)
	initializeRow= currentRows < neededRows
	if( initializeRow )
		additionalRows= neededRows - currentRows
		InsertPoints/M=0 currentRows, additionalRows, EditorSelWave
	endif

	// selWave's layer 0 is actually where selection (and checkbox-in-cell and checked state) are stored for each row and column.
	Variable state= EditorSelWave[textRow][%Enabled] | kCellisCheckboxMask	// no change in state, but ensure it's a checkbox
	switch( enableChecked )
		case 0:
			state = state %& ~kCellisCheckedMask
			break
		case 1:
			state= state %| kCellisCheckedMask
			break
	endswitch
	EditorSelWave[textRow][%Enabled][0] = state | kCellisCheckboxMask

	if( initializeRow )	// so we don't lose selection states by updating the value
		EditorSelWave[textRow][%rgb][0]			= kCellisEditableMask
		EditorSelWave[textRow][%cyan][0]			= kCellisEditableMask
		EditorSelWave[textRow][%magenta][0]		= kCellisEditableMask
		EditorSelWave[textRow][%yellow][0]			= kCellisEditableMask
		EditorSelWave[textRow][%black][0]			= kCellisEditableMask
		EditorSelWave[textRow][%previewCMYK][0]	= 0
	endif
	
	// selWave's layers %backColors and %foreColors contain ROW INDEXES
	// into EditorColorWave to select the background or text colors for each row and column.
	// Previously we've set row 0 to default (black text, white background) colors
	// and row 1 to white (for text on a dark background).
	//EditorSelWave[textRow][][%backColors]= 0	// most of the rows cells's background is the default, 0 is also the initial value.
	//EditorSelWave[textRow][][%foreColors]= 0		// most of the rows cells's background is the default, 0 is also the initial value.
	EditorSelWave[textRow][%rgb][%backColors]= rgbRow
	EditorSelWave[textRow][%rgb][%foreColors]= ReadableTextColor2(red, green, blue) // ReadableTextColor2 returns 0 to use black text, 1 to use white text for a given input rgb color

	// set Igor's cmyk text values - the user can change these

	EditorTextWave[textRow][%cyan]=			FormatCMYKStr(cyan)
	EditorTextWave[textRow][%magenta]=		FormatCMYKStr(magenta)
	EditorTextWave[textRow][%yellow]=			FormatCMYKStr(yellow)
	EditorTextWave[textRow][%black]=			FormatCMYKStr(black)

	// set the CMYK colors
	SetRowCMYK(textRow,cyan,magenta,yellow,black)	// by this time the text wave must have the right number of rows.

End


Static Function DeleteRow(textRow)
	Variable textRow

	WAVE/T/Z EditorTextWave= $PanelDFVar("EditorTextWave")
	if( textRow < 0 || !WaveExists(EditorTextWave) )
		return 0
	endif
	
	Variable nrows= DimSize(EditorTextWave,0)
	if( textRow == 0 && nrows == 1 )
		return DeleteAllRows()	// let this routine handle the complexity of preventing dimensional collapse
	endif
	
	// the rgbRow contains the red, green, blue and cyan,magenta,yellow,black
	// that eventually get to the M_IgorRGBtoCMYK wave
	Variable rgbRow= textRow*2 + kFirstRowContainingRGBCMYK	// zero-based
	// the next row is used only to colorize the previewCMYK cell in the listbox
	// None of these values are expressed in M_IgorRGBtoCMYK,
	//  so we need populate only the red, green, blue columns
	Variable CMYKSimulationRow= rgbRow+1

	WAVE EditorColorWave=  $PanelDFVar("EditorColorWave")
	Variable currentRows= DimSize(EditorColorWave,0)
	if( rgbRow >= currentRows )
		return 0
	endif
	
	DeletePoints/M=0 rgbRow, 2, EditorColorWave

	// EditorSelWave is multi-purpose and thus multi-dimensional
	// it has the same rows and columns as the text wave, but it has layers
	WAVE EditorSelWave= $PanelDFVar("EditorSelWave")
	
	DeletePoints/M=0 textRow, 1, EditorTextWave, EditorSelWave
	
	// renumber the color indexed into ColorWave
	EditorSelWave[][%rgb][%backColors] = kFirstRowContainingRGBCMYK + 2 * p
	EditorSelWave[][%previewCMYK][%backColors] = kFirstRowContainingRGBCMYK+1 + 2 * p

	Update_M_IgorRGBtoCMYK()
	return 1
End

Static Function ClearListWaves()

	WAVE/Z EditorColorWave=  $PanelDFVar("EditorColorWave")
	if( !WaveExists(EditorColorWave) )
		return 0
	endif

	// deleting the first row collapses multi-dimensional waves to 1 d and loses all the dimension labels.
	// So we delete all rows but the first one, and mark it disabled.
	WAVE EditorSelWave= $PanelDFVar("EditorSelWave")
	WAVE/T EditorTextWave= $PanelDFVar("EditorTextWave")

	Variable currentRows= DimSize(EditorTextWave,0)
	if( currentRows > 1 )
		DeletePoints/M=0 1, currentRows-1, EditorSelWave, EditorTextWave	// keep 1 row to avoid dimensional collapse
		Variable colorRowsToKeep = kFirstRowContainingRGBCMYK+2	// +2 for the one text row we have to keep.
		Variable colorRowsToDelete = DimSize(EditorColorWave,0) - colorRowsToKeep
		DeletePoints/M=0 colorRowsToKeep, colorRowsToDelete, EditorColorWave
	endif
	SetRowRGB(0,65535,0,0,0)	// pure red is the default trace color
	return 1
End


Static Function DeleteAllRows()

	if( !ClearListWaves() )
		return 0
	endif

	// in case the KillWaves fails because the user is looking at it in a table...
	Make/O/N=(0,0) root:M_IgorRGBtoCMYK/WAVE=M_IgorRGBtoCMYK
	KillWaves/Z M_IgorRGBtoCMYK
	HighlightErrors()
	return 1
End


Static Function SetRowCMYK(textRow,cyan,magenta,yellow,black)
	Variable textRow	// MUST BE A VALID ROW
	Variable cyan,magenta,yellow,black	// 0-1, or NaN if blank (which we translate into the default from rGB

	WAVE EditorColorWave=  $PanelDFVar("EditorColorWave")	// MUST EXIST
	
	// the rgbRow contains the red, green, blue and cyan,magenta,yellow,black
	// that eventually get to the M_IgorRGBtoCMYK wave
	Variable rgbRow= textRow*2 + kFirstRowContainingRGBCMYK

	// These are always in 0-1 format, converted from what the user enters.
	// Choosing from the CMYK popup draws values from here and puts the scaled values into the text list. 
	// This is so that repeatedly changing the maximum doesn't cause the values to wander.
	EditorColorWave[rgbRow][%cyan]= cyan
	EditorColorWave[rgbRow][%magenta]= magenta
	EditorColorWave[rgbRow][%yellow]= yellow
	EditorColorWave[rgbRow][%black]= black

	// the next row is used only to colorize the previewCMYK cell in the listbox
	// None of these values are expressed in M_IgorRGBtoCMYK,
	//  so we need populate only the red, green, blue columns
	Variable CMYKSimulationRow= rgbRow+1

	Variable cmykSimRed, cmykSimGreen, cmykSimBlue	// 0-65535
	CMYKtoRGB16(cyan,magenta,yellow,black,cmykSimRed,cmykSimGreen,cmykSimBlue)

	EditorColorWave[CMYKSimulationRow][%red]= cmykSimRed
	EditorColorWave[CMYKSimulationRow][%green]= cmykSimGreen
	EditorColorWave[CMYKSimulationRow][%blue]= cmykSimBlue
	
	WAVE EditorSelWave=  $PanelDFVar("EditorSelWave")	// MUST EXIST
	EditorSelWave[textRow][%previewCMYK][%backColors]= CMYKSimulationRow
End

// Note: the text usually comes from the user editing the list wave
Static Function SetRowCMYKFromText(textRow,cyanText,magentaText,yellowText,blackText)
	Variable textRow	// MUST BE A VALID ROW
	String cyanText,magentaText,yellowText,blackText	// 0-1, 0-100, or 0-255 as text

	// allow the user entering "" as a way to revert to the default value (if the rgb is valid)
	Variable red, green, blue, defaultCyan, defaultMagenta, defaultYellow, defaultBlack
	if( GetUsersRGBCMYK(textRow, red, green, blue, defaultCyan, defaultMagenta, defaultYellow, defaultBlack) & 0x1 )
		RGB16toCMYK(red, green, blue, defaultCyan, defaultMagenta, defaultYellow, defaultBlack)
		WAVE/T/Z EditorTextWave= $PanelDFVar("EditorTextWave")
		if( numtype(str2num(cyanText)) != 0 )
			cyanText= FormatCMYKStr(defaultCyan)
			EditorTextWave[textRow][%cyan]= cyanText
		endif
		if( numtype(str2num(magentaText)) != 0 )
			magentaText= FormatCMYKStr(defaultMagenta)
			EditorTextWave[textRow][%magenta]= magentaText
		endif
		if( numtype(str2num(yellowText)) != 0 )
			yellowText= FormatCMYKStr(defaultYellow)
			EditorTextWave[textRow][%yellow]= yellowText
		endif
		if( numtype(str2num(blackText)) != 0 )
			blackText= FormatCMYKStr(defaultBlack)
			EditorTextWave[textRow][%black]= blackText
		endif
	endif

	Variable cyan= ScaleUsersCMYK(str2num(cyanText))			// 0-1
	Variable magenta= ScaleUsersCMYK(str2num(magentaText))	// 0-1
	Variable yellow= ScaleUsersCMYK(str2num(yellowText))		// 0-1
	Variable black= ScaleUsersCMYK(str2num(blackText))		// 0-1

	SetRowCMYK(textRow,cyan,magenta,yellow,black)
End

// returns bitflag about whether rgb and/or cmyk are valid:
// 0x1 - red, green, and blue are all valid
// 0x2 - cmyk are all valid numbers
Static Function GetUsersRGBCMYK(textRow, red, green, blue, cyan,magenta,yellow,black)
	Variable textRow
	Variable &red, &green, &blue					// 0-65535 outputs
	Variable &cyan, &magenta, &yellow, &black	// 0-1 outputs

	Variable rgbsAreValid= 0
	Variable cmyksAreValid= 0
	
	WAVE/T/Z EditorTextWave= $PanelDFVar("EditorTextWave")
	if( WaveExists(EditorTextWave) && (textRow < DimSize(EditorTextWave,0)) )
		String rgbText= EditorTextWave[textRow][%rgb]
		if( ParseRGB(rgbText,red, green, blue) )
			if( (red == limit(red, 0, 65535)) &&(green == limit(green, 0, 65535)) &&(blue == limit(blue, 0, 65535)) )
				rgbsAreValid= 0x1
			endif
		endif

		cyan= ScaleUsersCMYK(str2num(EditorTextWave[textRow][%cyan]))
		magenta= ScaleUsersCMYK(str2num(EditorTextWave[textRow][%magenta]))
		yellow= ScaleUsersCMYK(str2num(EditorTextWave[textRow][%yellow]))
		black= ScaleUsersCMYK(str2num(EditorTextWave[textRow][%black]))

		if( (cyan == limit(cyan, 0, 1)) &&(magenta == limit(magenta, 0,1)) &&(yellow == limit(yellow, 0, 1))  && (black == limit(black, 0, 1)) )
			cmyksAreValid= 0x2
		endif
	endif
	
	return rgbsAreValid %| cmyksAreValid	// if you want to know if both are value use if (returnedValue == 3 )
End

Static Function IsInterestingRGBCMYK(textRow, red, green, blue, cyan,magenta,yellow,black)
	Variable textRow
	Variable &red, &green, &blue					// 0-65535 outputs
	Variable &cyan, &magenta, &yellow, &black	// 0-1 outputs

	if( GetUsersRGBCMYK(textRow, red, green, blue, cyan,magenta,yellow,black) == 3 )
		return 1	// If the user added a valid entry, it's confusing to not find it in M_IgorRGBtoCMYK.
	endif

	return 0
End

Static Function IsDefaultCMYKForRGB(textRow)
	Variable textRow

	Variable isDefault= 1
	Variable red, green, blue,cyan,magenta,yellow,black
	if( GetUsersRGBCMYK(textRow, red, green, blue, cyan,magenta,yellow,black) == 3 )
		// Compare cyan,magenta,yellow,black to igor-generated cmyk using text
		// to avoid the problems with reconciling user-input with RGB16toCMYK's
		// high resolution calculations.
		// Since elsewhere we use FormatCMYKStr, we use it here.
		Variable IgorCyan, IgorMagenta,IgorYellow,IgorBlack	// 0-1
		RGB16toCMYK(red,green,blue,IgorCyan, IgorMagenta,IgorYellow,IgorBlack)
		String cmyk, igorcmky
		sprintf cmyk, "%s,%s,%s,%s", FormatCMYKStr(cyan),FormatCMYKStr(magenta),FormatCMYKStr(yellow),FormatCMYKStr(black)
		sprintf igorcmky, "%s,%s,%s,%s", FormatCMYKStr(IgorCyan),FormatCMYKStr(IgorMagenta),FormatCMYKStr(IgorYellow),FormatCMYKStr(IgorBlack)
		isDefault= CmpStr(cmyk, igorcmky) == 0
	endif

	return isDefault
End

// M_IgorRGBtoCMYK needs only enabled rows from the editor whose cmyk values differ from the Igor-generated ones
// Let's see how many enabled rows differ to preflight the sizing of M_IgorRGBtoCMYK.
Static Function Needed_M_IgorRGBtoCMYK_Rows()

	Variable validRows= 0
	
	// EditorSelWave knows which rows are enabled
	WAVE/Z EditorSelWave= $PanelDFVar("EditorSelWave")

	// EditorTextWave knows the RGB values and the user's desired cmyk values in CMYK Maximum format, all as text
	WAVE/T/Z EditorTextWave= $PanelDFVar("EditorTextWave")

	// Both waves are expected to have the same number of rows
	Variable row,nrows= DimSize(EditorTextWave,0)
	for( row= 0; row < nrows; row+=1 )
		if( EditorSelWave[row][%Enabled] & kCellisCheckedMask )
			// Enabled, now compare the user's cmyk to Igor's
			Variable red, green, blue	// 0-65535
			Variable cyan,magenta,yellow,black	// 0-1
			if( IsInterestingRGBCMYK(row, red, green, blue, cyan,magenta,yellow,black) )
				validRows += 1
			endif
		endif	
	endfor
	return validRows
End

// the editor wave can have disabled rows that shouldn't be in the M_IgorRGBtoCMYK wave
Static Function Update_M_IgorRGBtoCMYK()

	Variable neededRows= Needed_M_IgorRGBtoCMYK_Rows()
	if( neededRows > 0 )

		// EditorSelWave knows which rows are enabled
		WAVE/Z EditorSelWave= $PanelDFVar("EditorSelWave")
	
		// EditorTextWave knows the RGB values and the user's desired cmyk values in CMYK Maximum format, all as text
		WAVE/T/Z EditorTextWave= $PanelDFVar("EditorTextWave")

		Make/O/N=(neededRows,7) root:M_IgorRGBtoCMYK/WAVE=M_IgorRGBtoCMYK
		SetDimLabel 1, 0, red,		M_IgorRGBtoCMYK	
		SetDimLabel 1, 1, green,		M_IgorRGBtoCMYK
		SetDimLabel 1, 2, blue,		M_IgorRGBtoCMYK
		SetDimLabel 1, 3, cyan,		M_IgorRGBtoCMYK
		SetDimLabel 1, 4, magenta,	M_IgorRGBtoCMYK
		SetDimLabel 1, 5, yellow,	M_IgorRGBtoCMYK
		SetDimLabel 1, 6, black,		M_IgorRGBtoCMYK
		
		Variable textRows= DimSize(EditorSelWave,0)
		Variable textRow
		Variable row=0
		for( textRow= 0; textRow < textRows; textRow+=1 )
			// if enabled, copy the row's colors to M_IgorRGBtoCMYK
			if( EditorSelWave[textRow][%Enabled][0] & kCellisCheckedMask )
				// Enabled, now compare the user's cmyk to Igor's
				Variable red, green, blue	// 0-65535
				Variable cyan,magenta,yellow,black	// 0-1
				if( IsInterestingRGBCMYK(textRow, red, green, blue, cyan,magenta,yellow,black) )
					M_IgorRGBtoCMYK[row][%red]= red
					M_IgorRGBtoCMYK[row][%green]= green
					M_IgorRGBtoCMYK[row][%blue]= blue
					M_IgorRGBtoCMYK[row][%cyan]= cyan
					M_IgorRGBtoCMYK[row][%magenta]= magenta
					M_IgorRGBtoCMYK[row][%yellow]= yellow
					M_IgorRGBtoCMYK[row][%black]= black
					row += 1
				endif
			endif	
		endfor
	else
		// in case the KillWaves fails because the user is looking at in a table...
		Make/O/N=(0,0) root:M_IgorRGBtoCMYK/WAVE=M_IgorRGBtoCMYK
		KillWaves/Z M_IgorRGBtoCMYK
	endif
	return neededRows
End


// +++++++ Panel support routines

Menu "IgorRGBtoCMYKMenuChange",contextualmenu,dynamic
	Submenu "Change RGB"
		IgorRGBtoCMYK#ColorPopMenuString(), /Q, ; // nothing is done with the menu selection because the thing that calls PopupContextualMenu calls GetLastUserMenuinfo to get the menu selection info.
	End
	IgorRGBtoCMYK#DeleteRowMenuString(), /Q, ;
End


Menu "IgorRGBtoCMYKMenuNew",contextualmenu,dynamic
	Submenu "Add RGB->CMYK Override for"
		IgorRGBtoCMYK#ColorPopMenuString(), /Q, ; // nothing is done with the menu selection because the thing that calls PopupContextualMenu calls GetLastUserMenuinfo to get the menu selection info.
	End
End

Static Function/S DeleteRowMenuString()

	// set editTextWaveRow before calling PopupContextualMenu
	Variable theRow= NumVarOrDefault(PanelDFVar("editTextWaveRow"),0)
	WAVE/T/Z EditorTextWave = $PanelDFVar("EditorTextWave")
	String menustr
	if( (!WaveExists(EditorTextWave)) || (theRow >= DimSize(EditorTextWave,0)) )
		menustr = ""	// disappears
	else
		sprintf menustr, "Delete Row %d",theRow
	endif
	
	return menustr
end

Static Function/S ColorPopMenuString()

	// set editTextWaveRow before calling PopupContextualMenu
	Variable theRow= NumVarOrDefault(PanelDFVar("editTextWaveRow"),0)*2 + kFirstRowContainingRGBCMYK
	
	Wave/Z EditorColorWave = $PanelDFVar("EditorColorWave")
	String menustr
	if( (!WaveExists(EditorColorWave)) || (theRow >= DimSize(EditorColorWave,0)) )
		menustr = "*COLORPOP*"
	else
		sprintf menustr, "*COLORPOP*(%d,%d,%d)",EditorColorWave[theRow][%red], EditorColorWave[theRow][%green], EditorColorWave[theRow][%blue]
	endif
	
	return menustr
end

// applies the CMYK Maximum popup setting
Static Function/S FormatCMYKStr(cmyk)
	Variable cmyk	// one of cyan,magenta,yellow,black in range of 0-1.0
	
	ControlInfo/W=$ksPanelName cmykRange
	if( CmpStr(S_Value,"1.0") != 0 )
		Variable maximum= str2num(S_Value)	// 100, 255, etc
		cmyk = round(cmyk*maximum)
	endif
	return num2str(cmyk)
End

// un-applies the CMYK Maximum popup setting
Static Function ScaleUsersCMYK(cmyk)
	Variable cmyk	// one of cyan,magenta,yellow,black in range depending on cmykRange popup

	ControlInfo/W=$ksPanelName cmykRange
	if( CmpStr(S_Value,"1.0") != 0 )
		Variable maximum= str2num(S_Value)	// 100, 255, etc
		cmyk /= maximum
	endif
	return cmyk	// one of cyan,magenta,yellow,black in range of 0-1.0
End
	

// returns 0 to use black text, 1 to use white text for a given input rgb color
Static Function ReadableTextColor2(red, green, blue)
	Variable red, green, blue	// 0-65535
	
	Variable LL, aa, bb
	Variable factor = 255/65535
	RGB2Lab(Red*factor, Green*factor, Blue*factor, L=LL, a=aa, b=bb)
	return LL < 75 ? 1 : 0
end

Static Function CMYKMaxPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	Variable/G $PanelDFVar("cmykRangeItem") = popNum
	ReformatCMYKs()	// pulls them from EditorColorWave where they're always 0..1.0 range.
	HighlightErrors()
	Update_M_IgorRGBtoCMYK()
End

Static Function NumberOfListRows()

	Variable numRows= 0
	WAVE/Z EditorTextWave= $PanelDFVar("EditorTextWave")
	if( WaveExists(EditorTextWave) )
		numRows= DimSize(EditorTextWave,0)
	endif

	return numRows
End

Static Function NewButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ChooseColor
	if( V_Flag )
		Variable row=AddUniqueRGB(V_red, V_green, V_blue)
		SelectCyanForRow(row)
	endif
End

Static Function AddUniqueRGB(red, green, blue)
	Variable red, green, blue

	Variable matchingRow=FindRowMatchingRGB(red, green, blue)
	if(  matchingRow < 0 )
		matchingRow= NumberOfListRows()
		SetRowRGB(matchingRow, red, green, blue, 1)
		HighlightErrors()
		Update_M_IgorRGBtoCMYK()
	else
		DoAlert 0, "Duplicate entry"
		DeselectAll()
		WAVE EditorSelWave= $PanelDFVar("EditorSelWave")
		EditorSelWave[matchingRow][%Enabled][0] = EditorSelWave[matchingRow][%Enabled] | kCellIsSelectedMask
	endif
	EnableDisableButtons()
	return matchingRow
End

Static Function SelectCyanForRow(row)
	Variable row

	DeselectAll()
	WAVE EditorSelWave= $PanelDFVar("EditorSelWave")
	EditorSelWave[row][%cyan][0] = EditorSelWave[row][%cyan] | kCellIsSelectedMask
	DoWindow $ksPanelName
	if( V_Flag )
		Variable col= FindDimLabel(EditorSelWave,1,"cyan")
		ListBox rgb2cmykList, win=$ksPanelName, setEditCell={row, col , -1, 0}
	endif
End

Static Function AddGraphColorsButtonProc(ctrlName) : ButtonControl
	String ctrlName

	AddColorsFromTopGraph()
End

Static Function RemoveSelectedButtonProc(ctrlName) : ButtonControl
	String ctrlName

	WAVE/Z EditorSelWave= $PanelDFVar("EditorSelWave")
	if( !WaveExists(EditorSelWave) )
		return 0
	endif
	
	Variable textRow= SelectedListRow(EditorSelWave, 0)
	if( textRow < 0 )
		Beep
		return 0
	endif

	Variable nrows
	do
		textRow= SelectedListRow(EditorSelWave, textRow)
		if( textRow < 0 )
			break
		endif
		DeleteRow(textRow)
		nrows= DimSize(EditorSelWave,0)
		// don't increment textRow the following row is now selWave[textRow].
	while( nrows > 1 )	// exit via break
	RenumberList()
	HighlightErrors()
	return 1
End

Static Function RenumberList()

	WAVE/T/Z EditorTextWave= $PanelDFVar("EditorTextWave")
	if( WaveExists(EditorTextWave) )
		EditorTextWave[][%Enabled]= num2istr(p)
	endif
End

Static Function RemoveAllButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DeleteAllRows()
End

Static Function LoadButtonProc(ctrlName) : ButtonControl
	String ctrlName

	LoadRGBCMYKOverrides("")
End

Static Function SaveButtonProc(ctrlName) : ButtonControl
	String ctrlName

	SaveRGBCMYKOverrides()
End

Static Function CloseButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	CloseIgorRGBtoCMYKPanel()
End

// Public
Function CloseIgorRGBtoCMYKPanel()

	Execute/P "DoWindow/K "+ksPanelName
End

Static Function HelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic "RGB to CMYK Panel"
End

// Listbox proc
Static Function RGBCMYKListBoxProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	Variable status= 0
	Variable row = lba.row
	Variable col = lba.col
	WAVE/T/Z listWave = lba.listWave
	WAVE/Z selWave = lba.selWave
	
	String colDimLabel= GetDimLabel(listWave, 1, col)		// for both text and sel waves
	Variable inList= row < DimSize(listWave,0) && row >=0
	Variable inTitle= row < 0
	Variable isContextual= lba.eventMod & 0x10	// bit 4

	switch( lba.eventCode )
		case -1: // control being killed
			break
		case 2:	// mouse up
			if( inList && (col == 0) && !isContextual )
				Update_M_IgorRGBtoCMYK()
			endif
			break
		case 1:								// mouse down				
			// put up contextual menu and use ChooseColor menu
			if( inTitle )
				SortByColumn(colDimLabel)
				status= 1
			elseif ( inList && (col == 1) && isContextual)
				Variable/G $PanelDFVar("editTextWaveRow") = row
				PopupContextualMenu/N "IgorRGBtoCMYKMenuChange"	// color-picker menu
				if (V_flag >= 0)
					if( V_kind == 10 )	// color pop
						SetRowRGB(row, V_red, V_green, V_blue, -1)
						Update_M_IgorRGBtoCMYK()
						SelectCyanForRow(row)
					else
						// only 1 text item, "remove row"
						DeleteRow(row)					
					endif
					HighlightErrors()
					EnableDisableButtons()
				endif
				status= 1
			elseif( isContextual )	// add row
				Variable newRow=NumberOfListRows()
				Variable/G $PanelDFVar("editTextWaveRow") = newRow
				PopupContextualMenu/N "IgorRGBtoCMYKMenuNew"	// color-picker menu in submenu announcing that a new row will be added
				if (V_flag >= 0)
					newRow=AddUniqueRGB(V_red, V_green, V_blue)	// newRow can be different if we chose a duplicate
					SelectCyanForRow(newRow)
				endif
				status= 1
			else
				Variable shift= lba.eventMod & 0x02
				if( !shift )
					DeselectAll()
					status= 1
				endif			
			endif
			break
		case 3: // double click
			break
		case 4: // cell selection
		case 5: // cell selection plus shift key
			if( inList )	// add selection to Enabled column for clarity
				selWave[row][%Enabled][0] = selWave[row][%Enabled] | kCellIsSelectedMask
			endif
			EnableDisableButtons()
			break
		case 6: // begin edit
			break
		case 7: // finish edit
			strswitch( colDimLabel )
				case "rgb":
					Variable red, green, blue
					String rgbText=listWave[row][%rgb]
					if( strlen(rgbText) )
						ParseRGB(rgbText,red, green, blue)
					else
						if( RecoverLastRGB(row, red, green, blue) )
							sprintf rgbText, "%d,%d,%d", red, green, blue
							listWave[row][%rgb]= rgbText
						endif
					endif
					SetRowRGB(row, red, green, blue, -1)
					Update_M_IgorRGBtoCMYK()
					HighlightErrors()
					break
				case "cyan":
				case "magenta":
				case "yellow":
				case "black":
					SetRowCMYKFromText(row,listWave[row][%cyan],listWave[row][%magenta],listWave[row][%yellow],listWave[row][%black])
					Update_M_IgorRGBtoCMYK()
					HighlightErrors()
					break
			endswitch 
			EnableDisableButtons()
			break
	endswitch

	return status
End

Static Function RecoverLastRGB(textRow,red, green, blue)
	Variable textRow
	Variable &red, &green, &blue	// outputs

	Variable rgbRow= textRow*2 + kFirstRowContainingRGBCMYK	// zero-based
	WAVE/Z EditorColorWave= $PanelDFVar("EditorColorWave")
	if( !WaveExists(EditorColorWave) )
		return 0
	endif
	
	Variable currentRows= DimSize(EditorColorWave,0)
	Variable haveRGBs= rgbRow < currentRows
	if( haveRGBs )
		red= EditorColorWave[rgbRow][%red]
		green= EditorColorWave[rgbRow][%green]
		blue= EditorColorWave[rgbRow][%blue]
	endif
	return haveRGBs
End

Static Function ParseRGB(str,red, green, blue)
	String str				// input "red,green,blue"
	Variable &red, &green, &blue	// outputs

	Variable numValues= ItemsInList(str,",")
	red= str2num(StringFromList(0,str,","))
	green= str2num(StringFromList(1,str,","))
	blue= str2num(StringFromList(2,str,","))
	return numValues == 3
End

// Public
Function ShowIgorRGBtoCMYKPanel()

	DoWindow/F $ksPanelName
	if( V_Flag == 0 )
		// create the data folders
		String oldDF= SetPanelDF()
		SetDataFolder oldDF
		
		// create the panel
		NewPanel/W=(36,153,617,579)/K=1 as "RGB to CMYK Overrides"
		DoWindow/C $ksPanelName
		DefaultGuiFont/Mac/W=$ksPanelName popup={"_IgorSmall",9,0},all={"_IgorMedium",12,0}
		DefaultGuiFont/Win/W=$ksPanelName popup={"_IgorSmall",0,0},all={"_IgorMedium",0,0}

		// cmykRange
		Variable mode= NumVarOrDefault(PanelDFVar("cmykRangeItem"), 2)
		String popValue= StringFromList(mode-1,"1.0;100;255;")
		PopupMenu cmykRange,pos={353,4},size={131,17},bodyWidth=60,title="CMYK Maximum"
		PopupMenu cmykRange,fSize=9,mode=mode,popValue=popValue, value="1.0;100;255;"
		PopupMenu cmykRange proc=IgorRGBtoCMYK#CMYKMaxPopMenuProc

		// rgb2cmykList

		MakeListboxWaves()
		WAVE EditorColorWave=  $PanelDFVar("EditorColorWave")
		WAVE/T EditorTextWave=  $PanelDFVar("EditorTextWave")
		WAVE EditorSelWave=  $PanelDFVar("EditorSelWave")
		WAVE/T EditorTitleWave=  $PanelDFVar("EditorTitleWave")

		ListBox rgb2cmykList,pos={22,28},size={538,253}, fsize=10,proc=IgorRGBtoCMYK#RGBCMYKListBoxProc,mode= 7	// multiple contiguous selections
		ListBox rgb2cmykList selWave= EditorSelWave, colorWave= EditorColorWave, listWave=EditorTextWave, titleWave= EditorTitleWave
		ListBox rgb2cmykList widths={45,119,69,70,70,74,74},userColumnResize= 1
		ListBox rgb2cmykList editStyle=1, clickEventModifiers=4

		// Error text
		TitleBox error,pos={22,282},size={538,13}
		TitleBox error,fSize=10,frame=0,fStyle=1,anchor= MT,title=""

		// Buttons
		Button new,pos={48,304},size={190,20},proc=IgorRGBtoCMYK#NewButtonProc,title="Add RGB->CMYK Override"

		Button addGraphColors,pos={48,335},size={190,20},proc=IgorRGBtoCMYK#AddGraphColorsButtonProc,title="Add Colors used in Top Graph"

		// removeSelected gets enabled and disabled
		Button removeSelected,pos={48,366},size={190,20},proc=IgorRGBtoCMYK#RemoveSelectedButtonProc,title="Remove Selected Rows"

		// removeAll gets enabled and disabled
		Button removeAll,pos={88,397},size={110,20},proc=IgorRGBtoCMYK#RemoveAllButtonProc,title="Remove All"

		Button load,pos={334,304},size={200,20},proc=IgorRGBtoCMYK#LoadButtonProc,title="Load from RGB2CMYK.txt File..."

		Button save,pos={334,335},size={200,20},proc=IgorRGBtoCMYK#SaveButtonProc,title="Save to RGB2CMYK.txt File..."

		Button help,pos={334,397},size={70,20},proc=IgorRGBtoCMYK#HelpButtonProc,title="Help"

		Button close,pos={463,397},size={70,20},proc=IgorRGBtoCMYK#CloseButtonProc,title="Close"

		SetWindow $ksPanelName hook(resize) = IgorRGBtoCMYK#RGBtoCMYKPanelHook

		SaveControlPositions()

		WC_WindowCoordinatesRestore(ksPanelName)
	endif
	EnableDisableButtons()
	HighlightErrors()
End


Static Function SaveControlPositions()
	
	String controls= ControlNameList(ksPanelName)
	Variable n= ItemsInList(controls)

	Make/O/T/N=(n+1,5+4) $PanelDFVar("controlPositions")/WAVE=tw
	SetDimLabel 0, 0, Panel, tw
	
	SetDimLabel 1, 0, Name, tw
	SetDimLabel 1, 1, Left, tw
	SetDimLabel 1, 2, Top, tw
	SetDimLabel 1, 3, Width, tw
	SetDimLabel 1, 4, Height, tw
	
	SetDimLabel 1, 5, LeftAdjust, tw	// one of ksMoveNo, ksMoveFixedOffsetFromLeft, ksMoveFixedOffsetFromMiddle,ksMoveFixedOffsetFromRight
	SetDimLabel 1, 6, TopAdjust, tw
	SetDimLabel 1, 7, RightAdjust, tw
	SetDimLabel 1, 8, BottomAdjust, tw	// one of ksMoveNo, ksMoveFixedOffsetFromTop, ksMoveFixedOffsetFromCenter,ksMoveFixedOffsetFromBottom
	
	GetWindow $ksPanelName wsizeDC	// the new window size in pixels
	Variable winHeight= V_bottom-V_top	// pixels
	Variable winWidth= V_right-V_left		// pixels
	tw[%Panel][%Name]=controls			// saves list of controls: its faster than enumerating the list.
	tw[%Panel][%Top]=num2str(V_top)
	tw[%Panel][%Left]=num2str(V_left)
	tw[%Panel][%Width]=num2str(winWidth)
	tw[%Panel][%Height]=num2str(winHeight)
	
	Variable row
	for( row=1; row <= n; row+=1 )
		String ctrlName= StringFromList(row-1,controls)
		ControlInfo/W=$ksPanelName $ctrlName
		SetDimLabel 0, row, $ctrlName, tw
		tw[row][%Name]=ctrlName
		tw[row][%Left]=num2str(V_left)
		tw[row][%Top]=num2str(V_top)
		tw[row][%Width]=num2str(V_width)
		tw[row][%Height]=num2str(V_height)
		// default adjustment rules
		tw[row][%LeftAdjust]= ksMoveFixedOffsetFromLeft
		tw[row][%RightAdjust]= ksMoveFixedOffsetFromLeft
		tw[row][%TopAdjust]= ksMoveFixedOffsetFromTop
		tw[row][%BottomAdjust]= ksMoveFixedOffsetFromTop
		// define adjustment rules
		strswitch(ctrlName)
			// top-right controls
			case "cmykRange":
				tw[row][%LeftAdjust]= ksMoveFixedOffsetFromRight
				tw[row][%RightAdjust]= ksMoveFixedOffsetFromRight
				break
			// list is the only one whose top is stationary and bottom moves
			case "rgb2cmykList":
				tw[row][%RightAdjust]= ksMoveFixedOffsetFromRight
				tw[row][%BottomAdjust]= ksMoveFixedOffsetFromBottom
				break
			// bottom-left controls
			case "new":
			case "addGraphColors":
			case "removeSelected":
			case "removeAll":
				tw[row][%TopAdjust]= ksMoveFixedOffsetFromBottom
				tw[row][%BottomAdjust]= ksMoveFixedOffsetFromBottom
				break
			// bottom-right controls
			case "load":
			case "save":
			case "help":
			case "close":
				tw[row][%LeftAdjust]= ksMoveFixedOffsetFromRight
				tw[row][%RightAdjust]= ksMoveFixedOffsetFromRight
				tw[row][%TopAdjust]= ksMoveFixedOffsetFromBottom
				tw[row][%BottomAdjust]= ksMoveFixedOffsetFromBottom
				break
			// bottom-middle controls
			case "error":
				tw[row][%LeftAdjust]= ksMoveFixedOffsetFromLeft
				tw[row][%RightAdjust]= ksMoveFixedOffsetFromRight
				tw[row][%TopAdjust]= ksMoveFixedOffsetFromBottom
				tw[row][%BottomAdjust]= ksMoveFixedOffsetFromBottom
				break
			
		endswitch
	endfor
End

Static StrConstant ksMoveNo = ""

// window edge-relative adjustments
Static StrConstant ksMoveFixedOffsetFromLeft = "Left"
//Static StrConstant ksMoveFixedOffsetFromMiddle= "Middle"
Static StrConstant ksMoveFixedOffsetFromRight= "Right"

Static StrConstant ksMoveFixedOffsetFromTop = "Top"
//Static StrConstant ksMoveFixedOffsetFromCenter= "Center"
Static StrConstant ksMoveFixedOffsetFromBottom= "Bottom"

Static Function FitControlsToPanel(win)
	String win

	// a generalized routine could get the path to the wave from userData
	// or even use a struct that was PutStruct/S'd into one of the window's named userDatas.
	WAVE/T/Z tw= $PanelDFVar("controlPositions")	// original positions
	if( !WaveExists(tw) )
		return 0
	endif
	
	GetWindow $win wsizeDC	// the new window size in pixels
	Variable winWidth= V_right-V_left	
	Variable winHeight= V_bottom-V_top
	
	Variable originalWinWidth= str2num(tw[%Panel][%Width])
	Variable originalWinHeight= str2num(tw[%Panel][%Height])
	
	// adjustment amounts in pixels
	Variable deltaWidth= winWidth - originalWinWidth
	Variable deltaHeight= winHeight - originalWinHeight
	
	Variable row
	Variable n= DimSize(tw,0)
	for( row=1; row<n; row+=1 )
		String ctrlName= tw[row][%Name]
		
		Variable origLeft=str2num(tw[row][%Left])
		Variable origTop=str2num(tw[row][%Top])
		Variable origWidth=str2num(tw[row][%Width])
		Variable origHeight=str2num(tw[row][%Height])
		
		Variable left= origLeft, top= origTop, width=origWidth, height= origHeight

		String leftAdjust= 		tw[row][%LeftAdjust]
		String rightAdjust=		tw[row][%RightAdjust]

		String topAdjust= 		tw[row][%TopAdjust]
		String bottomAdjust=	tw[row][%BottomAdjust]
		
		Variable diff

		strswitch(leftAdjust)
			case ksMoveFixedOffsetFromRight:
				left += deltaWidth
				break
		endswitch
		
		strswitch(rightAdjust)
			case ksMoveFixedOffsetFromRight:
				Variable right= origLeft + origWidth
				right += deltaWidth
				width = right-left
				break
		endswitch
		
		strswitch(topAdjust)
			case ksMoveFixedOffsetFromBottom:
				top += deltaHeight
				break
		endswitch
		
		strswitch(bottomAdjust)
			case ksMoveFixedOffsetFromBottom:
				Variable bottom= origTop+origHeight
				bottom += deltaHeight
				height= bottom-top
				break
		endswitch
		
		Variable sizeChange= CmpStr(leftAdjust,rightAdjust) != 0 || CmpStr(bottomAdjust,bottomAdjust) != 0
		if( sizeChange )
			ModifyControl $ctrlName, win=$win, pos={left,top},size={width,height}
		else
			ModifyControl $ctrlName, win=$win, pos={left,top}
		endif
	endfor
	
	return 1
End

	
Static Constant kMinWidth= 550
Static Constant kMinHeight=270

Static Function MinWindowSize(win,minwidth,minheight)
	String win
	Variable minwidth,minheight	// points

	GetWindow $win wsize
	Variable width= V_right-V_left
	Variable height= V_bottom-V_top
	Variable neededWidth= max(width,minwidth)
	Variable neededHeight= max(height,minheight)
	Variable resizePending= (neededWidth > width) || (neededHeight > height)
	if( resizePending )
		//MoveWindow/W=$win V_left, V_top, V_left+newwidth, V_top+newheight
		String cmd
		sprintf cmd, "MoveWindow/W=%s %g,%g,%g,%g", win, V_left, V_top, V_left+neededWidth, V_top+neededHeight
		Execute/P/Q/Z cmd	// after the functions stop executing, the MoveWindow will provoke another resize event.
	endif
	return resizePending	
End

#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility with Igor 7
	String wName
	return 72
End
#endif


Static Function RGBtoCMYKPanelHook(hs)
	STRUCT WMWinHookStruct &hs

	Variable statusCode= 0
	
	strswitch(hs.eventName)
		case "resize":
			String win= hs.winName
			Variable tooSmall= MinWindowSize(win,kMinWidth*PanelResolution(win)/ScreenResolution,kMinHeight*PanelResolution(win)/ScreenResolution)	// make sure the window isn't too small (at least 200 pixels)
			if( !tooSmall )	// don't bother resizing if another resize event is pending
				FitControlsToPanel(win)
			endif
			statusCode=1
			break
		case "activate":
			EnableDisableButtons()
			break
		case "kill":
			WC_WindowCoordinatesSave(ksPanelName)
			break
	endswitch
	return statusCode
End

// truth the M_IgorRGBtoCMYK wave exists, and if so how many rows it has
Static Function Have_M_IgorRGBtoCMYK()

	Variable nrows= 0
	WAVE/Z M_IgorRGBtoCMYK= root:M_IgorRGBtoCMYK	// before MakeListboxWaves() creates the single red row
	if( WaveExists(M_IgorRGBtoCMYK) )
		nrows= DimSize(M_IgorRGBtoCMYK,0)
	endif

	return nrows
End

// transfer M_IgorRGBtoCMYK to the list waves
Static Function Load_M_IgorRGBtoCMYK()

	DoWindow $ksPanelName
	if( V_Flag == 0 )
		return 0
	endif

	WAVE/T/Z EditorTextWave= $PanelDFVar("EditorTextWave")
	if( !WaveExists(EditorTextWave) )
		return 0
	endif

	Variable nrows= Have_M_IgorRGBtoCMYK()
	if( nrows == 0 )
		return 0
	endif

	WAVE M_IgorRGBtoCMYK= root:M_IgorRGBtoCMYK
	SetDimLabel 1, 0, red,		M_IgorRGBtoCMYK	
	SetDimLabel 1, 1, green,		M_IgorRGBtoCMYK
	SetDimLabel 1, 2, blue,		M_IgorRGBtoCMYK
	SetDimLabel 1, 3, cyan,		M_IgorRGBtoCMYK
	SetDimLabel 1, 4, magenta,	M_IgorRGBtoCMYK
	SetDimLabel 1, 5, yellow,	M_IgorRGBtoCMYK
	SetDimLabel 1, 6, black,		M_IgorRGBtoCMYK

	ClearListWaves()

	Variable row
	for(row= 0; row < nrows; row += 1 )
		Variable red=	M_IgorRGBtoCMYK[row][%red]
		Variable green=	M_IgorRGBtoCMYK[row][%green]
		Variable blue= 	M_IgorRGBtoCMYK[row][%blue]
		SetRowRGB(row, red, green, blue, 1)
		
		Variable cyan=		M_IgorRGBtoCMYK[row][%cyan]
		Variable magenta=	M_IgorRGBtoCMYK[row][%magenta]
		Variable yellow= 	M_IgorRGBtoCMYK[row][%yellow]
		Variable black= 		M_IgorRGBtoCMYK[row][%black]

		// SetRowCMYK() sets up the simulation color and saves the cmyk values,
		// but doesn't set the text in the list wave
		EditorTextWave[row][%cyan]= 		FormatCMYKStr(cyan)
		EditorTextWave[row][%magenta]=	FormatCMYKStr(magenta)
		EditorTextWave[row][%yellow]=		FormatCMYKStr(yellow)
		EditorTextWave[row][%black]=		FormatCMYKStr(black)

		SetRowCMYK(row,cyan,magenta,yellow,black)
	endfor

	return 1
End

// we save:
//  EditorColorWave[rgbRow][%red]
//  EditorColorWave[rgbRow][%green]
//  EditorColorWave[rgbRow][%blue]
//  EditorColorWave[rgbRow][%Enabled]
//  EditorColorWave[rgbRow][%cyan]
//  EditorColorWave[rgbRow][%magenta]
//  EditorColorWave[rgbRow][%yellow]
//  EditorColorWave[rgbRow][%black]
//
// by simply saving a copy of EditorColorWave after
// deleting the cmykSim rows and the first kFirstRowContainingRGBCMYK rows.
Static Function SaveRGBCMYKOverrides()

	WAVE/Z EditorColorWave= $PanelDFVar("EditorColorWave")
	if( !WaveExists(EditorColorWave) )
		return 0
	endif

	Variable nrows= DimSize(EditorColorWave,0)
	Duplicate/O EditorColorWave, $PanelDFVar("RGB2CMYK")/WAVE=IRCC
	
	Variable finalRows= (nrows-kFirstRowContainingRGBCMYK)/2
	Redimension/N=(finalRows,-1) IRCC
	
	IRCC= EditorColorWave[p*2+kFirstRowContainingRGBCMYK][q]

	// tab-delimited with column dimension labels-based first row providing titles, no wave name.
	Save/J/I/U={0,0,1,0} IRCC
	
	KillWaves/Z IRCC
End

// Public
Function LoadRGBCMYKOverrides(pathToFile)
	String pathToFile		// "" to ask the user to locate the file, else the full Mac-format file path

	String oldDF= SetPanelDF()
	if( strlen(pathToFile) )
		LoadWave/J/M/U={0,0,1,0}/O/K=1/N=RGB2CMYK/K=0/V={"\t,"," $",0,1}/L={0,1,0,0,8} pathToFile
	else
		LoadWave/J/M/U={0,0,1,0}/O/K=1/N=RGB2CMYK/K=0/V={"\t,"," $",0,1}/L={0,1,0,0,8}
	endif
	WAVE/Z IRCC= $StringFromList(0,S_waveNames)
	SetDataFolder oldDF

	if( !WaveExists(IRCC) )
		return 0		// user cancelled
	endif

	Variable ncols= DimSize(IRCC,1)
	if( ncols < 8 )
		DoAlert 0, "Expected wave with at least 8 columns; it has only "+num2str(ncols)+"! Can't load this."
		return 0
	endif

	Variable nrows= DimSize(IRCC,0)
	if( nrows == 0 )
		return 0
	endif

	// allow user-supplied waves that might not have the column labels
	SetDimLabel 1, 0, red,		IRCC	
	SetDimLabel 1, 1, green,		IRCC
	SetDimLabel 1, 2, blue,		IRCC
	SetDimLabel 1, 3, Enabled,	IRCC
	SetDimLabel 1, 4, cyan,		IRCC
	SetDimLabel 1, 5, magenta,	IRCC
	SetDimLabel 1, 6, yellow,	IRCC
	SetDimLabel 1, 7, black,		IRCC

	WAVE/T/Z EditorTextWave= $PanelDFVar("EditorTextWave")
	if( !WaveExists(EditorTextWave) )
		MakeListboxWaves()
	endif

	ClearListWaves()
	WAVE/T/Z EditorTextWave= $PanelDFVar("EditorTextWave")

	Variable row
	for(row= 0; row < nrows; row += 1 )
		Variable red=	IRCC[row][%red]
		Variable green=	IRCC[row][%green]
		Variable blue= 	IRCC[row][%blue]
		Variable enabled= IRCC[row][%Enabled]

		SetRowRGB(row, red, green, blue, enabled)
		
		Variable cyan=		IRCC[row][%cyan]
		Variable magenta=	IRCC[row][%magenta]
		Variable yellow= 	IRCC[row][%yellow]
		Variable black= 		IRCC[row][%black]

		// SetRowCMYK() sets up the simulation color and saves the cmyk values,
		// but doesn't set the text in the list wave
		EditorTextWave[row][%cyan]= 		FormatCMYKStr(cyan)
		EditorTextWave[row][%magenta]=	FormatCMYKStr(magenta)
		EditorTextWave[row][%yellow]=		FormatCMYKStr(yellow)
		EditorTextWave[row][%black]=		FormatCMYKStr(black)

		SetRowCMYK(row,cyan,magenta,yellow,black)
	endfor
	
	HighlightErrors()
	Update_M_IgorRGBtoCMYK()

	KillWaves/Z IRCC

	return 1
End


Static Function SortByColumn(colDimLabel)
	String colDimLabel
	
	WAVE/T/Z EditorTextWave= $PanelDFVar("EditorTextWave")
	if( !WaveExists(EditorTextWave) )
		return 0
	endif
	
	Variable col= FindDimLabel(EditorTextWave,1,colDimLabel)
	if( col < 0 || col > 6 )
		return 0
	endif
	
	Variable nrows= DimSize(EditorTextWave,0)
	if( nrows < 2 )
		return 0
	endif

	WAVE/Z EditorColorWave= $PanelDFVar("EditorColorWave")
	if( !WaveExists(EditorColorWave) )
		return 0
	endif

	WAVE EditorSelWave= $PanelDFVar("EditorSelWave")
	if( !WaveExists(EditorSelWave) )
		return 0
	endif

	DeSelectAll()

	Make/O/N=(nrows) $PanelDFVar("index")/WAVE=index
	
	// primary sort key
	Make/O/N=(nrows) $PanelDFVar("sortKey0")/WAVE=sortKey0
	String sortedBy= colDimLabel
	Variable rgbIndex=0
	strswitch(colDimLabel)
		case "Enabled":
			sortedBy= "Enabled status"
			sortKey0= EditorSelWave[p][%Enabled][0] & kCellisCheckedMask
			break
		case "previewCMYK":
			sortedBy= "user CMYK override status"
			sortKey0= IsDefaultCMYKForRGB(p)
			break
		case "rgb":
			// if col == 1 (rgb), we rotate among sorting by red, green, or blue.
			rgbIndex= mod(1+NumVarOrDefault(PanelDFVar("rgbIndex"),2),3)		// 0, 1, or 2
			Variable/G $PanelDFVar("rgbIndex")= rgbIndex
			rgbIndex -= 1	// -1,0,1
			sortedBy= SelectString(rgbIndex, "red", "green", "blue")
			Variable row
			for(row=0; row<nrows; row+=1 )
				String rgbText= EditorTextWave[row][%rgb]
				Variable red, green, blue
				ParseRGB(rgbText,red, green, blue)
				sortKey0[row]= SelectNumber(rgbIndex, red, green, blue)
			endfor
			break
		case "cyan":
		case "magenta":
		case "yellow":
		case "black":
			sortKey0= str2num(EditorTextWave[p][col])
			break
	endswitch
	
	// secondary sort keys
	Make/O/N=(nrows) $PanelDFVar("sortKeyC")/WAVE=sortKeyC
	Make/O/N=(nrows) $PanelDFVar("sortKeyM")/WAVE=sortKeyM
	Make/O/N=(nrows) $PanelDFVar("sortKeyY")/WAVE=sortKeyY
	Make/O/N=(nrows) $PanelDFVar("sortKeyK")/WAVE=sortKeyK
	sortKeyC= str2num(EditorTextWave[p][%cyan])
	sortKeyM= str2num(EditorTextWave[p][%magenta])
	sortKeyY= str2num(EditorTextWave[p][%yellow])
	sortKeyK= str2num(EditorTextWave[p][%black])

	MakeIndex {sortKey0,sortKeyC,sortKeyM,sortKeyY,sortKeyK}, index

	// if sort by is the same as last time, toggle the sort order
	Variable reversed= 0
	String lastSortedBy= StrVarOrDefault(PanelDFVar("lastSortedBy"),"")
	String/G $PanelDFVar("lastSortedBy")= sortedBy
	if( CmpStr(sortedBy, lastSortedBy) == 0 )
		reversed= !NumVarOrDefault(PanelDFVar("reversed"),0)
	endif
	Variable/G $PanelDFVar("reversed")= reversed
	if( reversed )
		Reverse/P index
	endif
	IndicateSortingOrder(col,rgbIndex,reversed)
	
	// The index is directly applicable to EditorTextWave and EditorSelWave rows
	Duplicate/O/T EditorTextWave, $PanelDFVar("copyT")/WAVE=copyT
	EditorTextWave= copyT[index[p]][q]
	RenumberList()

	Duplicate/O EditorSelWave, $PanelDFVar("copy")/WAVE=copy
	EditorSelWave= copy[index[p]][q][r]
	
	// The index is indirectly applicable to EditorTextWave and EditorSelWave rows
	index = index[p]*2 + kFirstRowContainingRGBCMYK	// rgbRows
	Duplicate/O EditorColorWave, $PanelDFVar("copy")/WAVE=copy
	EditorColorWave[kFirstRowContainingRGBCMYK,;2][] = copy[index[(p-kFirstRowContainingRGBCMYK)/2]][q] // rgbRows
	index += 1	// cmykSimRows
	EditorColorWave[kFirstRowContainingRGBCMYK+1,;2][] = copy[index[(p-(kFirstRowContainingRGBCMYK+1))/2]][q] // cmykSimRows

	// now fix up the background color indexes
	EditorSelWave[][%rgb][%backColors] = kFirstRowContainingRGBCMYK + 2 * p
	EditorSelWave[][%previewCMYK][%backColors] = kFirstRowContainingRGBCMYK+1 + 2 * p
	DeSelectAll()

	Variable haveError= HighlightErrors()	// fixes preview texts.
	Update_M_IgorRGBtoCMYK()
	if( !haveError )
		String text
		sprintf text, "(%ssorted by %s)", SelectString(reversed,"","reverse "), sortedBy
		TitleBox error, win=$ksPanelName, title=text,fColor=(0,0,65535)
	endif
	KillWaves/Z copyT, copy, index, sortKey0,sortKeyC,sortKeyM,sortKeyY,sortKeyK
End

Static Function 	IndicateSortingOrder(col,whichRGB,reversed)
	Variable col
	Variable whichRGB	// -1,0,1
	Variable reversed

	Make/O/T $PanelDFVar("EditorTitleWave")/WAVE=EditorTitleWave= {"Enabled","Right-click for Color", "C", "M", "Y", "K", "CMYK Preview"}
	if( col >= 0 )
		String marker= SelectString(reversed,  "\\W523", "\\W517")	// points in direction of increasing value
		String color="\\K(65535,0,0)"
		if( col == 1 )	// r,g,b
			color=SelectString(whichRGB,"\\K(65535,0,0)","\\K(1,26214,0)","\\K(0,0,65535)")
		endif
		EditorTitleWave[col] = "\\f01"+color+EditorTitleWave[col]+marker
	endif
End

Static Function DeSelectAll()

	WAVE EditorSelWave= $PanelDFVar("EditorSelWave")
	if( !WaveExists(EditorSelWave) )
		return 0
	endif
	Variable nrows= DimSize(EditorSelWave,0)
	Variable ncols= DimSize(EditorSelWave,1)
	Variable row, col
	for(row= 0; row < nrows; row += 1 )
		for(col= 0; col < ncols; col += 1 )
			Variable sel= EditorSelWave[row][col][0] & ~kCellIsSelectedMask
			EditorSelWave[row][col][0] = sel
		endfor
	endfor
	EnableDisableButtons()
End

// CMYK Maximum popup action procedure.
// Pulls CMYK values from EditorColorWave where they're always 0..1.0 range
// and reformats them based on the new/now-current format showing in the popup.
Static Function ReformatCMYKs()
	
	WAVE/T/Z EditorTextWave= $PanelDFVar("EditorTextWave")
	if( !WaveExists(EditorTextWave) )
		return 0
	endif
	Variable nrows= DimSize(EditorTextWave,0)
	
	WAVE/Z EditorColorWave= $PanelDFVar("EditorColorWave")
	if( !WaveExists(EditorColorWave) )
		return 0
	endif
	
	Variable textRow, rgbRow
	for(textRow= 0,rgbRow= kFirstRowContainingRGBCMYK; textRow < nrows; textRow += 1,rgbRow+=2 )
		Variable cyan=		EditorColorWave[rgbRow][%cyan]
		Variable magenta=	EditorColorWave[rgbRow][%magenta]
		Variable yellow= 	EditorColorWave[rgbRow][%yellow]
		Variable black= 		EditorColorWave[rgbRow][%black]

		EditorTextWave[textRow][%cyan]= 		FormatCMYKStr(cyan)
		EditorTextWave[textRow][%magenta]=	FormatCMYKStr(magenta)
		EditorTextWave[textRow][%yellow]=		FormatCMYKStr(yellow)
		EditorTextWave[textRow][%black]=		FormatCMYKStr(black)
	endfor
End

Static Function AddColorsFromTopGraph()

	WAVE/T/Z EditorTextWave= $PanelDFVar("EditorTextWave")
	if( !WaveExists(EditorTextWave) )
		return 0
	endif
	
	WAVE EditorSelWave= $PanelDFVar("EditorSelWave")
	if( !WaveExists(EditorSelWave) )
		return 0
	endif

	WAVE/Z rgbs= GetColorsFromTopGraph()
	if( WaveExists(rgbs) )
		Variable nrows= DimSize(rgbs,0)
		Variable row
		for(row= 0; row < nrows; row += 1 )
			Variable red=	rgbs[row][%red]
			Variable green=	rgbs[row][%green]
			Variable blue= 	rgbs[row][%blue]
			Variable textRow= FindRowMatchingRGB(red,green,blue)
			if( textRow < 0 )
				// matching color not found, add a row
				SetRowRGB(DimSize(EditorTextWave,0), red, green, blue, 1)
			else
				EditorSelWave[textRow][%Enabled][0] = kCellisCheckboxMask | kCellisCheckedMask
			endif
		endfor
		HighlightErrors()
		Update_M_IgorRGBtoCMYK()
	endif
End


// black and white aren't interesting colors, and technically any shade of gray isn't, either
Static Function IsInterestingColor(red, green, blue)
	Variable red, green, blue
	
	if( red == green && green == blue )
		return 0
	endif
	
	return 1
End

Static Function StripBoringRGBs(w)
	Wave/Z w
	Variable red, green, blue

	Variable rows= -1
	if( WaveExists(w) )
		rows= DimSize(w,0)
		Variable row
		for( row= rows-1; row >= 0; row -= 1)
			red= w[row][%red]
			green= w[rows][%green]
			blue= w[rows][%blue]
			if( !IsInterestingColor(red, green, blue) )
				DeletePoints/M=0 row, 1, w
			endif
		endfor
		rows= DimSize(w,0)
	endif
	return rows
End

Static Function AddRGBToWave(w, red, green, blue)
	Wave/Z w
	Variable red, green, blue

	Variable rows= -1
	if( WaveExists(w) )
		rows= DimSize(w,0)
		InsertPoints/M=0 rows, 1, w
		w[rows][%red]= red
		w[rows][%green]= green
		w[rows][%blue]= blue
	endif
	return rows
End

Static Function MatchingRGB(w, red, green, blue)
	Wave/Z w
	Variable red, green, blue

	if( WaveExists(w) )
		Variable nrows= DimSize(w,0)
		Variable row
		for(row= 0; row < nrows; row += 1 )
			if( w[row][%red] == red &&w[row][%green] == green &&w[row][%blue] == blue )
				return row
			endif	
		endfor
	endif
	return -1
End

Static Function AddColorTableRGBsToWave(w, ctab)
	Wave/Z w
	String ctab

	if( WaveExists(w) )
		String oldDF= SetPanelDF()
		ColorTab2Wave $ctab
		WAVE M_colors
		SetDataFolder oldDF
	
		Variable row, nrows= DimSize(M_colors,0)
		for( row=0; row<nrows; row+=1)
			Variable red= M_colors[row][0]
			Variable green= M_colors[row][1]
			Variable blue= M_colors[row][2]
			if(  -1 == MatchingRGB(w, red, green, blue) && IsInterestingColor(red, green, blue) )
				AddRGBToWave(w, red, green, blue)
			endif
		endfor
	endif
End

// returns offset PAST then found rgb stuff (where to start the NEXT search.
Static Function GetNextRGB(code, offset, keyPrefix, keyEnd, rgbStart, rgbEnd, red, green, blue)
	String code
	Variable offset	// start looking here
	String keyPrefix		// "rgb[" or "rgb("
	String keyEnd		// "]=(" or")="
	String rgbStart		// "(" or whatever
	String rgbEnd		// ")"
	Variable &red, &green, &blue		// outputs
	
	do
		// keyPrefix is not optional
		offset= strsearch(code, keyPrefix, offset)
		if( offset < 0 )
			return -1
		endif
		offset += strlen(keyPrefix)
		// skip to keyEnd, we've now skipped over something like rgb[0]=(
		if( strlen(keyEnd) )
			offset= strsearch(code, keyEnd, offset)
			if( offset < 0 )
				continue
			endif
			offset += strlen(keyEnd)
		endif
		if( strlen(rgbStart) )
			offset= strsearch(code, rgbStart, offset)
			if( offset < 0 )
				continue
			endif
			offset += strlen(rgbStart)
		endif
		// rgbEnd is not optional
		Variable rgbEndPos= strsearch(code, rgbEnd, offset)
		if( rgbEndPos < 0 )
			continue
		endif
		// found an rgb
		String rgbtext=code[offset,rgbEndPos-1]
		sscanf rgbtext, "%d,%d,%d", red, green, blue
		if( V_Flag == 3 )
			offset= rgbEndPos + strlen(rgbEnd)
			return offset
		endif
		// didn't scan, keep looking, discarding the (apparently unreliable) rgbEndPos
		
	while( 1 )	// return from inside loop
	// WE NEVER GET HERE
End


Static Function/WAVE GetColorsFromTopGraph()

	String oldDF= SetPanelDF()
	 // Get all the colors from the graph, and the kinds.
	String whichColors="all;"
	WAVE/Z rgbs= WMGetColorsFromTopGraph("graphRGBs",whichColors)	// sets whichColors

	 // Then ask the user which ones are desired:
	String userApprovedColors=	AskUserWhichColors(whichColors)
	Variable userCancelled= CmpStr(userApprovedColors,"cancel;") == 0 
	if( userCancelled )
		KillWaves/Z rgbs
	else
		// Get only the approved colors (if there were any)
		if( CmpStr(userApprovedColors,whichColors) != 0  && ItemsInList(userApprovedColors) > 0 )
			WAVE/Z rgbs= WMGetColorsFromTopGraph("graphRGBs",userApprovedColors)
		endif
	endif
	
	StripBoringRGBs(rgbs)
	SetDataFolder oldDF

	return rgbs
End


Static Function FindRowMatchingRGB(red,green,blue)
	Variable red, green, blue
	
	WAVE/T/Z EditorTextWave= $PanelDFVar("EditorTextWave")
	if( !WaveExists(EditorTextWave) )
		return -1
	endif

	Variable row, nrows= DimSize(EditorTextWave,0)
	for(row= 0; row < nrows; row += 1 )
		String rgbText
		sprintf rgbText, "%d,%d,%d", red, green, blue
		if( CmpStr(rgbText,	EditorTextWave[row][%rgb]) == 0 )
			return row
		endif	
	endfor
	
	return -1
End

// returns the first row with a selection. 0 is the first row. returns -1 if no row selected.
Static Function SelectedListRow(selWave, startRow)
	Wave selWave	// must exist
	Variable startRow	// 0 to search the entire wave for selections, larger to search later rows

	Variable nrows= DimSize(selWave,0)
	Variable ncols= DimSize(selWave,1)
	for( ; startRow < nrows; startRow += 1 )
		Variable col
		for( col= 0; col < ncols; col += 1 )
			if( selWave[startRow][col] & kCellIsSelectedMask )
				return startRow		// row in text and selection waves
			endif
		endfor	
	endfor
 
 	return -1
 End

Static Function EnableDisableButtons()

	// enable/disable removeSelected based on whether there is a selection

	WAVE EditorSelWave=  $PanelDFVar("EditorSelWave")
	Variable firstSelected= SelectedListRow(EditorSelWave, 0)
	Variable disable = (firstSelected >= 0 ) ? 0 : 2
	Button removeSelected,win=$ksPanelName, disable=disable

	// enable/disable removeAll and save buttons
	// based on whether there are rows to remove or save
	disable= (DimSize(EditorSelWave,0) > 0) ? 0 : 2
	ModifyControlList "removeAll;save;" ,win=$ksPanelName, disable=disable
	
	String topGraphName= WinName(0,1,1)
	disable= strlen(topGraphName) > 0 ? 0 : 2	
	Button addGraphColors,win=$ksPanelName, disable=disable
End

Static Function HighlightCMYK(textRow, cyanInError, magentaInError, yellowInError, blackInError)
	Variable textRow	// must be valid row
	Variable cyanInError, magentaInError, yellowInError, blackInError	// 0 if okay, 1 if wrong value
	
	WAVE EditorSelWave= $PanelDFVar("EditorSelWave")	// must exist
	// Note: the editor color wave has 3 initial colors:
	// row 0 = (0,0,0) = default colors (foreground and background)
	// row 1 = (65535,65535,65535) = white for white text on dark rgb backgrounds
	// row 2 = (65535,0,0) = red for error text
	// here we're installing the desired color wave row number into the cell's %foreColors layer
	EditorSelWave[textRow][%cyan][%foreColors]= cyanInError ? 2 : 0
	EditorSelWave[textRow][%magenta][%foreColors]= magentaInError ? 2 : 0
	EditorSelWave[textRow][%yellow][%foreColors]= yellowInError ? 2 : 0
	EditorSelWave[textRow][%black][%foreColors]= blackInError ? 2 : 0
	
	// if error, clear out the CMYK preview.
	// if no error, we set the CMYK Preview background color to the right value.
	// and put readable text in it to indicate whether the CMYK is default or changed
	String previewText= ""	// However, since only this routine alters the CMYK Preview text, we also clear it here.
	if( cyanInError || magentaInError || yellowInError || blackInError )
		previewText= "Invalid"	
		EditorSelWave[textRow][%previewCMYK][%backColors]=0
		EditorSelWave[textRow][%previewCMYK][%foreColors]= 2
	else
		Variable CMYKSimulationRow= kFirstRowContainingRGBCMYK + 2*textRow
		EditorSelWave[textRow][%previewCMYK][%backColors]=CMYKSimulationRow
		WAVE EditorColorWave=  $PanelDFVar("EditorColorWave")// must exist

		Variable cmykSimRed= EditorColorWave[CMYKSimulationRow][%red]
		Variable cmykSimGreen= EditorColorWave[CMYKSimulationRow][%green]
		Variable cmykSimBlue= EditorColorWave[CMYKSimulationRow][%blue]
		EditorSelWave[textRow][%previewCMYK][%foreColors]= ReadableTextColor2(cmykSimRed, cmykSimGreen, cmykSimBlue) // ReadableTextColor2 returns 0 to use black text, 1 to use white text for a given input rgb color

		previewText=SelectString(IsDefaultCMYKForRGB(textRow), "user", "default")
	endif
	WAVE/T EditorTextWave= $PanelDFVar("EditorTextWave")
	EditorTextWave[textRow][%previewCMYK]= previewText
End

// returns truth that there was an error
Static Function HighlightErrors()

	WAVE EditorTextWave= $PanelDFVar("EditorTextWave")
	WAVE EditorSelWave= $PanelDFVar("EditorSelWave")
	Variable nrows= DimSize(EditorTextWave,0)	// both waves have the same number of rows and columns
	Variable row
	String errorText= ""
	for( row=0; row < nrows; row += 1 )
		Variable red, green, blue, cyan,magenta,yellow,black
		Variable validBits=GetUsersRGBCMYK(row, red, green, blue, cyan,magenta,yellow,black)
		if( validBits == 3 )
			HighlightCMYK(row,0,0,0,0)	// clear CMYK error indications
			continue
		endif
		// there's an error, deal with it
		if( (validBits & 0x1) == 0 )	// error in rgb text
			// remove indicated color (because its invalid)
			// Once the user corrects the values the color will be set properly.
			EditorSelWave[row][%rgb][%backColors]= 0
			EditorSelWave[row][%rgb][%foreColors]= 2

			if( strlen(errorText) == 0 )
				errorText= "Expected three numbers between 0 and 65535 in the second column of row "+num2istr(row)
			endif
		endif
		
		if( (validBits & 0x2) == 0 )	// error in one of C, M, Y, K
			// Set the text of cmyk values to red if error
			Variable cyanInError= cyan != limit(cyan,0,1)
			Variable magentaInError= magenta != limit(magenta,0,1)
			Variable yellowInError= yellow != limit(yellow,0,1)
			Variable blackInError= black != limit(black,0,1)
			HighlightCMYK(row,cyanInError, magentaInError, yellowInError, blackInError)
			
			if( strlen(errorText) == 0 )
				String columnName
				if( cyanInError )
					columnName= "C"
				elseif( cyanInError )
					columnName= "M"
				elseif( cyanInError )
					columnName= "Y"
				else
					columnName= "K"
				endif
				errorText= "Expected number between 0 and "+FormatCMYKStr(1.0)+" in "+columnName+" column of row "+num2istr(row)
			endif
		endif
	endfor
	
	DoWindow $ksPanelName
	if( V_Flag )
		TitleBox error win=$ksPanelName, title=errorText,fColor=(52428,1,1)
	endif
	return strlen(errorText)
End