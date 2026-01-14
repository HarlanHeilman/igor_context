#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3			// Use modern global access method and strict wave access
#pragma IgorVersion = 9.00	// The Draw Presentation Table procedures require Igor Pro 9.00 or later
#pragma version = 1.00		// Keep consistent with kDPTVersion

Constant kDPTVersion = 1.00

// Cell Data Organization
// Definition of layers of cellData wave
Constant kDPTCellDataVersion = 1.00				// A change in the units digit signifies an incompatible change to the cellData wave format
Constant kDPTCellTextLayer = 0						// Layer containing cell text
Constant kDPTCellTextFontLayer = 1					// Layer containing font name
Constant kDPTCellTextSizeLayer = 2					// Layer containing text size in points
Constant kDPTCellTextStyleLayer = 3				// Layer containing text style as for DrawText fstyle keyword
Constant kDPTCellTextJustificationLayer = 4		// Layer containing text justification in X and Y (e.g., "0,1" for left/middle justification)
Constant kDPTCellPaddingLayer = 5					// Layer containing cell for left, top, right, bottom (e.g., "8,5,8,5")
Constant kDPTCellBackgroundColorLayer = 6		// Layer containing background r,g,b where each component is in range 0..65535
Constant kDPTCellForegroundColorLayer = 7		// Layer containing foreground r,g,b where each component is in range 0..65535
Constant kDPTCellBorderLayer = 8					// Layer containing cell border information
Constant kDPTCellMergeLayer = 9						// Layer containing cell merger information
Constant kDPTCellDataNumLayers = 10

static StrConstant kDefaultNumericFormat = "%g"
static Constant kDefaultCellWidth = 100				// Cell width in points if not specified by cell data wave
static StrConstant kDefaultTextFont = "default"	// Uses window default font
static Constant kDefaultTextSize = 12					// Text size if not specified by cell data wave
static Constant kDefaultTextStyle = 0					// Text style if not specified by cell data wave
static Constant kDefaultTextXJustification = 0		// Left X text justification if not specified by cell data wave
static Constant kDefaultTextYJustification = 1		// Middle Y text justification if not specified by cell data wave
static Constant kDefaultXCellPadding = 8.0			// X cell width in points if not specified by cell data wave
static Constant kDefaultYCellPadding = 5.0			// Y cell width in points if not specified by cell data wave

// Caption Data Organization
// Definition of layers of captionData wave
Constant kDPTCaptionDataVersion = 1.00				// A change in the units digit signifies an incompatible change to the captionData wave format
Constant kDPTCaptionTextColumn = 0
Constant kDPTCaptionPositionColumn = 1				// 0=above, 1=below, 2=left, 3=right
Constant kDPTCaptionJustificationColumn = 2			// 0=left, 1=center, 2=right OR 0=bottom, 1=middle, 2=top
Constant kDPTCaptionPaddingColumn = 3					// Padding in points
Constant kDPTCaptionXOffsetColumn = 4					// X offset in points
Constant kDPTCaptionYOffsetColumn = 5					// Y offset in points
Constant kDPTCaptionDataNumColumns = 6

static Constant kDefaultCaptionPosition = 0
static Constant kDefaultCaptionJustification = 1
static Constant kDefaultCaptionPadding = 3.0
static Constant kDefaultCaptionXOffset = 0
static Constant kDefaultCaptionYOffset = 0

// Values for the action parameter to custom drawing function
Constant kDPTMeasureCustomCellAction = 0
Constant kDPTDrawCustomCellAction = 1

Function DPTCustomDrawCellFuncProto(dpt, action, row, column, xLeft, yTop, xRight, yBottom, width, height)
	STRUCT DrawPresentationTableParams &dpt
	int action					// 0=Measure cell, 1=Draw cell
	int row, column				// Cell row and column
	double xLeft, yTop, xRight, yBottom
	double& width				// Output
	double& height				// Output
	
	width = 50					// Arbitrary
	height = 30					// Arbitrary
	Printf "DPTCustomDrawCellFuncProto called for row %d, column %d\r", row, column
	return 0
End

Structure DrawPresentationTableParams
	// Fields initialized by InitDrawPresentationTableParams based on parameters
	String wName
	String drawingLayerName
	String drawingGroupName
	double tableX0
	double tableY0
	FUNCREF DPTCustomDrawCellFuncProto DrawCellFunc
	int32 haveCustomDrawCellFunc
	
	// Fields initialized by InitDrawPresentationTableParams to fixed values
	double xGridThickness					// Initialized to 1.0. Set to 0 to hide horizontal grid lines.
	double yGridThickness					// Initialized to 1.0. Set to 0 to hide vertical grid lines.
	int32 gridRed, gridGreen, gridBlue	// Grid color - initialized to black (0,0,0)
	int16 drawTableBGColor				// Initialized to 0
	int32 tableBGRed, tableBGGreen, tableBGBlue	// Table background color - initialized to white (65535,65535,65535)
	
	// Free waves created by InitDrawPresentationTableParams
	WAVE rowHeights
	WAVE columnWidths
	WAVE/T cellData
	WAVE/T captionData
EndStructure

static Function InstallVersionNote(w, constantName, version)
	WAVE w
	String constantName		// e.g., "kDPTCellDataVersion"
	double version
	
	String text
	sprintf text, "%s=%d", constantName, version
	Note/K w, text
End

Function InitDrawPresentationTableParams(dpt, wName, drawingLayerName, drawingGroupName, tableX0, tableY0, numRowsInTable, numColumnsInTable, numCaptions, DrawCellFunc)
	struct DrawPresentationTableParams& dpt
	String wName, drawingLayerName, drawingGroupName
	double tableX0, tableY0
	int numRowsInTable, numColumnsInTable
	int numCaptions
	FUNCREF DPTCustomDrawCellFuncProto DrawCellFunc		// Custom drawing function or $""
	
	dpt.wName = wName
	dpt.drawingLayerName = drawingLayerName
	dpt.drawingGroupName = drawingGroupName
	dpt.tableX0 = tableX0
	dpt.tableY0 = tableY0
	FUNCREF DPTCustomDrawCellFuncProto dpt.DrawCellFunc = DrawCellFunc
	dpt.haveCustomDrawCellFunc = 0
	String info = FuncRefInfo(DrawCellFunc)
	String funcName = StringByKey("NAME",info)
	if (strlen(funcName) > 0)
		dpt.haveCustomDrawCellFunc = 1
	endif	
	
	dpt.xGridThickness = 1.0
	dpt.yGridThickness = 1.0
	dpt.gridRed = 0
	dpt.gridGreen = 0
	dpt.gridBlue = 0
	
	dpt.drawTableBGColor = 0
	dpt.tableBGRed = 65535
	dpt.tableBGGreen = 65535
	dpt.tableBGBlue = 65535

	WAVE dpt.rowHeights = NewFreeWave(4, numRowsInTable)
	WAVE dpt.columnWidths = NewFreeWave(4, numColumnsInTable)
	Make/FREE/T/N=(numRowsInTable,numColumnsInTable,kDPTCellDataNumLayers) cellData
	WAVE/T dpt.cellData = cellData
	InstallVersionNote(cellData, "kDPTCellDataVersion", kDPTCellDataVersion)
	
	Make/FREE/T/N=(numCaptions,kDPTCaptionDataNumColumns) captionData
	WAVE/T dpt.captionData = captionData
	InstallVersionNote(captionData, "kDPTCaptionDataVersion", kDPTCaptionDataVersion)
End

static Function GetRowHeight(WAVE rowHeights, int row)
	double rowHeight = rowHeights[row]
	if (rowHeight <= 0)
		return 0				// Probably a user error
	endif
	return rowHeight
End

static Function SetRowHeight(WAVE rowHeights, int row, double rowHeight)
	if (rowHeight <= 0)
		rowHeight = 0				// Probably a user error
	endif
	rowHeights[row] = rowHeight
End

static Function GetColumnWidth(WAVE columnWidths, int column)
	double columnWidth = columnWidths[column]
	if (columnWidth <= 0)
		return 0				// Probably a user error
	endif
	return columnWidth
End

static Function SetColumnWidth(WAVE columnWidths, int column, double columnWidth)
	if (columnWidth <= 0)
		columnWidth = 0			// Probably a user error
	endif
	columnWidths[column] = columnWidth
End

static Function GetCellMergerFromStr(cellMergerStr, mergeWithNextRow, mergeWithNextColumn)
	String cellMergerStr				// "", "0,1", "1,0", or "1,1"
	int &mergeWithNextRow				// Output
	int &mergeWithNextColumn			// Output
	
	if (strlen(cellMergerStr) == 0)			// Want default cell merger?
		mergeWithNextRow = 0
		mergeWithNextColumn = 0
		return 0
	endif
	
	double dMergeWithNextRow, dMergeWithNextColumn				// NumType works on doubles, not on ints
	sscanf cellMergerStr, "%d,%d", dMergeWithNextRow, dMergeWithNextColumn
	int numValuesReturned = V_Flag
	
	if (numValuesReturned<1 || NumType(dMergeWithNextRow)!=0)
		dMergeWithNextRow = 0					// No row merger specified
	endif
	mergeWithNextRow = dMergeWithNextRow
	
	if (numValuesReturned<2 || NumType(dMergeWithNextColumn)!=0)
		dMergeWithNextColumn = 0				// No column merger specified
	endif
	mergeWithNextColumn = dMergeWithNextColumn
		
	return 0
End

static Function GetCellMerger(cellData, row, column, mergeWithNextRow, mergeWithNextColumn)
	WAVE/T cellData						// Input
	int row, column						// Input
	int &mergeWithNextRow				// Output
	int &mergeWithNextColumn			// Output
	
	String cellMergerStr = cellData[row][column][kDPTCellMergeLayer]
	GetCellMergerFromStr(cellMergerStr, mergeWithNextRow, mergeWithNextColumn)
End

// GetCellHeightWithMerge(cellData, row, column)
// Returns row height taking cell merging into account.
static Function GetCellHeightWithMerge(dpt, row, column)
	struct DrawPresentationTableParams& dpt
	int row
	int column
	
	WAVE rowHeights = dpt.rowHeights				// Height of each row in points
	WAVE/T cellData = dpt.cellData
	double cellHeight = rowHeights[row]
	
	int lastRow = DimSize(rowHeights, 0) - 1
	do
		if (row >= lastRow)
			break					// Last row can't merge with next because there is no next row
		endif
		int mergeWithNextRow, mergeWithNextColumn
		GetCellMerger(cellData, row, column, mergeWithNextRow, mergeWithNextColumn)
		if (!mergeWithNextRow)
			break
		endif
		row += 1
		cellHeight += rowHeights[row]
	while(1) 
	
	if (cellHeight <= 0)
		return 0				// Probably a user error
	endif
	
	return cellHeight
End

// GetCellWidthWithMerge(cellData, row, column)
// Returns row height taking cell merging into account.
static Function GetCellWidthWithMerge(dpt, row, column)
	struct DrawPresentationTableParams& dpt
	int row
	int column
	
	WAVE columnWidths = dpt.columnWidths				// Width of each row in points
	WAVE/T cellData = dpt.cellData
	double columnWidth = columnWidths[column]
	
	int lastColumn = DimSize(columnWidths, 0) - 1
	do
		if (column >= lastColumn)
			break					// Last column can't merge with next because there is no next column
		endif
		int mergeWithNextRow, mergeWithNextColumn
		GetCellMerger(cellData, row, column, mergeWithNextRow, mergeWithNextColumn)
		if (!mergeWithNextColumn)
			break
		endif
		column += 1
		columnWidth += columnWidths[column]
	while(1) 
	
	if (columnWidth <= 0)
		return 0				// Probably a user error
	endif
	
	return columnWidth
End

// DPTMergeCells(dpt, startRow, startColumn, endRow, endColumn)
// Sets the appropriate elements of the kDPTCellMergeLayer of the cellData wave
// to merge the cells between startRow/startColumn and endRow/endColumn.
Function DPTMergeCells(dpt, startRow, startColumn, endRow, endColumn)
	struct DrawPresentationTableParams& dpt
	int startRow, startColumn
	int endRow, endColumn

	WAVE/T cellData = dpt.cellData
	
	int numRowsInTable = DimSize(cellData, 0)
	if (numRowsInTable <= 0)
		return -1					// Eliminate degenerate case
	endif
	int lastRowInTable = numRowsInTable - 1
	if (startRow<0 || startRow>lastRowInTable)
		return -1					// Invalid start row
	endif
	if (endRow<0 || endRow>lastRowInTable)
		return -1					// Invalid end row
	endif
	if (endRow < startRow)
		return -1					// Invalid start or end row
	endif
	
	int numColumnsInTable = DimSize(cellData, 1)
	if (numColumnsInTable <= 0)
		return -1					// Eliminate degenerate case
	endif
	int lastColumnInTable = numColumnsInTable - 1
	if (startColumn<0 || startColumn>lastColumnInTable)
		return -1					// Invalid start column
	endif
	if (endColumn<0 || endColumn>lastColumnInTable)
		return -1					// Invalid end column
	endif
	if (endColumn < startColumn)
		return -1					// Invalid start or end column
	endif
	
	int row
	for(row=startRow; row<=endRow; row+=1)
		int column
		for(column=startColumn; column<=endColumn; column+=1)
			int mergeWithNextRow = row < endRow
			int mergeWithNextColumn = column < endColumn
			if (mergeWithNextRow && mergeWithNextColumn)
				cellData[row][column][kDPTCellMergeLayer] = "1,1"			// Merge with next row and next column
			else
				if (mergeWithNextRow)
					cellData[row][column][kDPTCellMergeLayer] = "1,0"		// Merge with next row
				else
					if (mergeWithNextColumn)
						cellData[row][column][kDPTCellMergeLayer] = "0,1"	// Merge with next column
					endif
				endif
			endif
		endfor
	endfor

	return 0
End

static Function StartGroup(wName, groupName)
	String wName
	String groupName

	SetDrawEnv/W=$wName gStart, gName=$groupName	
End

static Function StopGroup(wName, groupName)
	String wName
	String groupName

	SetDrawEnv/W=$wName gStop, gName=$groupName	
End

static Function GetRGB(RGBStr, red, green, blue)
	String RGBStr								// e.g., "65535,0,0"
	int &red, &green, &blue					// Outputs
	
	if (strlen(RGBStr) == 0)					// Want default black?
		red = 0
		green = 0
		blue = 0
	endif
	
	double dRed, dGreen, dBlue		// NumType works on doubles, not on ints
	sscanf RGBStr, "%d,%d,%d", dRed, dGreen, dBlue
	int numValuesReturned = V_Flag
	red = dRed
	if (numValuesReturned<1 || NumType(dRed)!=0)
		red = 0							// Default red component if no red specified
	endif
	green = dGreen
	if (numValuesReturned<2 || NumType(dGreen)!=0)
		green = 0							// Default green component if no green specified
	endif
	blue = dBlue
	if (numValuesReturned<3 || NumType(dBlue)!=0)
		blue = 0							// Default blue component if no blue specified
	endif
End

static Function GetTextJustification(textJustificationStr, xJustification, yJustification)
	String textJustificationStr				// e.g., "0,1" for left/middle justification
	int &xJustification, &yJustification	// Outputs
	
	if (strlen(textJustificationStr) == 0)		// Want default justification?
		xJustification = kDefaultTextXJustification
		yJustification = kDefaultTextYJustification
		return 0
	endif
	
	double dXJust, dYJust								// NumType works on doubles, not on ints
	sscanf textJustificationStr, "%d,%d", dXJust, dYJust
	int numValuesReturned = V_Flag
	
	if (numValuesReturned<1 || NumType(dXJust)!=0)
		dXJust = kDefaultTextXJustification		// Default X justification if no X justification specified
	endif
	xJustification = dXJust
	
	if (numValuesReturned<2 || NumType(dYJust)!=0)
		dYJust = kDefaultTextYJustification		// Default Y justification if no Y justification specified
	endif
	yJustification = dYJust
	
	return 0
End

static Function GetCustomCellFormats(cellData, row, column, fgRed, fgGreen, fgBlue, bgRed, bgGreen, bgBlue, textFontStr, textSize, textStyle, xJustification, yJustification)
	WAVE/T cellData						// Input
	int row, column						// Input
	int &fgRed, &fgGreen, &fgBlue	// Outputs - foreground color
	int &bgRed, &bgGreen, &bgBlue	// Outputs - background color
	String& textFontStr				// Output
	int& textSize						// Output
	int& textStyle						// Output
	int& xJustification				// Output: 0=left, 1=center, 2=right
	int& yJustification				// Output: 0=bottom, 1=middle, 2=top
	
	String foregroundRGBStr = cellData[row][column][kDPTCellForegroundColorLayer]
	GetRGB(foregroundRGBStr, fgRed, fgGreen, fgBlue)
	
	String backgroundRGBStr = cellData[row][column][kDPTCellBackgroundColorLayer]
	GetRGB(backgroundRGBStr, bgRed, bgGreen, bgBlue)
	
	textFontStr = cellData[row][column][kDPTCellTextFontLayer]
	if (strlen(textFontStr) == 0)
		textFontStr = kDefaultTextFont
	endif
	
	double dTextSize					// NumType works on doubles, not on ints
	String textSizeStr = cellData[row][column][kDPTCellTextSizeLayer]
	dTextSize = str2num(textSizeStr)
	if (NumType(dTextSize) != 0)
		dTextSize = kDefaultTextSize
	endif
	if (dTextSize<3 || dTextSize>200)
		dTextSize = kDefaultTextSize
	endif
	textSize = dTextSize

	double dTextStyle					// NumType works on doubles, not on ints
	String textStyleStr = cellData[row][column][kDPTCellTextStyleLayer]
	dTextStyle = str2num(textStyleStr)
	if (NumType(dTextStyle) != 0)
		dTextStyle = kDefaultTextStyle
	endif
	textStyle = dTextStyle
	
	String textJustificationStr = cellData[row][column][kDPTCellTextJustificationLayer]
	GetTextJustification(textJustificationStr, xJustification, yJustification)
End

static Function AdjustForXJustification(wName, textWidth, columnWidth, xJustification, leftPadding, rightPadding, xPos)
	String wName
	double textWidth		// In points
	double columnWidth
	int xJustification
	double leftPadding, rightPadding
	double& xPos				// Input: position of left edge of cell; Output: xPos suitable for DrawText taking xJustification into account
	
	double availableWidth = columnWidth - leftPadding - rightPadding
	double xExtra = availableWidth - textWidth
	double halfAvailableWidth = availableWidth/2
	double halfTextWidth = textWidth/2
	double xOffset = 0				// X offset needed for the desired X justification
	switch(xJustification)
		case 0:						// Left
			// Align left edge of text with left edge of available area
			xOffset = leftPadding
			break
		case 1:						// Center
			// Align center of text with center of available area
			xOffset = leftPadding + halfAvailableWidth - halfTextWidth
			break
		case 2:						// Right
			// Align right edge of text with right edge of available area
			xOffset = columnWidth - rightPadding - textWidth
			break
	endswitch
	xPos = xPos + xOffset
End

static Function AdjustForYJustification(wName, textHeight, rowHeight, yJustification, topPadding, bottomPadding, yPos)
	String wName
	double textHeight		// In points
	double rowHeight
	int yJustification
	double topPadding, bottomPadding
	double& yPos				// Input: position of top edge of cell; Output: yPos suitable for DrawText taking yJustification into account
	
	// DrawText's y0 parameter is taken as the Y coordinate of bottom of the text
	// where bottom includes the descent (height of descenders). y0 is not the
	// Y coordinate of the baseline of the text.
	// Starting off, yPos puts the bottom of the text at the top of the cell.
	double availableHeight = rowHeight - topPadding - bottomPadding
	double yExtra = availableHeight - 	textHeight
	double halfAvailableHeight = availableHeight/2
	double halfTextHeight = textHeight/2
	double yOffset = 0				// Y offset needed for the desired Y justification
	switch(yJustification)
		case 0:						// Bottom
			// Align bottom of text, including descenders, with bottom of available areaa
			yOffset = topPadding + availableHeight
			break
		case 1:						// Middle
			// Align middle of text, including descenders, with middle of available areaa
			yOffset = topPadding + halfAvailableHeight + halfTextHeight
			break
		case 2:						// Top
			// Align top of text, including descenders, with top of available areaa
			yOffset = topPadding + textHeight
			break
	endswitch
	yPos = yPos + yOffset
End

static Function GetCellPaddingFromStr(cellPaddingStr, leftPadding, topPadding, rightPadding, bottomPadding)
	String cellPaddingStr							// e.g., "8,5,8,5"
	double &leftPadding, &topPadding			// Outputs
	double &rightPadding, &bottomPadding		// Outputs
	
	if (strlen(cellPaddingStr) == 0)			// Want default cell padding?
		leftPadding = kDefaultXCellPadding
		topPadding = kDefaultYCellPadding
		rightPadding = kDefaultXCellPadding
		bottomPadding = kDefaultYCellPadding
		return 0
	endif
	
	double dLeftPadding, dTopPadding				// NumType works on doubles, not on ints
	double dRightPadding, dBottomPadding
	sscanf cellPaddingStr, "%d,%d,%d,%d", dLeftPadding, dTopPadding, dRightPadding, dBottomPadding
	int numValuesReturned = V_Flag
	
	if (numValuesReturned<1 || NumType(dLeftPadding)!=0)
		dLeftPadding = kDefaultXCellPadding		// Default left padding if no left justification specified
	endif
	leftPadding = dLeftPadding
	
	if (numValuesReturned<2 || NumType(dTopPadding)!=0)
		dTopPadding = kDefaultYCellPadding			// Default top padding if no top justification specified
	endif
	topPadding = dTopPadding
	
	if (numValuesReturned<3 || NumType(dRightPadding)!=0)
		dRightPadding = kDefaultXCellPadding		// Default right padding if no right justification specified
	endif
	rightPadding = dRightPadding
	
	if (numValuesReturned<4 || NumType(dBottomPadding)!=0)
		dBottomPadding = kDefaultYCellPadding		// Default bottom padding if no bottom justification specified
	endif
	bottomPadding = dBottomPadding
	
	return 0
End

static Function GetCellPadding(cellData, row, column, leftPadding, topPadding, rightPadding, bottomPadding)
	WAVE/T cellData									// Input
	int row, column									// Input
	double &leftPadding, &topPadding			// Outputs
	double &rightPadding, &bottomPadding		// Outputs
	
	String cellPaddingStr = cellData[row][column][kDPTCellPaddingLayer]
	GetCellPaddingFromStr(cellPaddingStr, leftPadding, topPadding, rightPadding, bottomPadding)
End

static Function GetCellBorderParams(cellBorderStr, borderSpec, thickness, dashStyle, red, green, blue, xOffset, yOffset)
	String cellBorderStr
	String& borderSpec		// Output - some combination of L, T, R, B for left, top, right, bottom
	double& thickness		// Output
	int& dashStyle			// Output
	int& red					// Output
	int& green				// Output
	int& blue					// Output
	double& xOffset
	double& yOffset
	
	// Set defaults
	thickness = 1.0
	dashStyle = 0
	red = 0; green = 0; blue = 0;
	xOffset = 0; yOffset = 0;
	
	String whichBordersStr, colonStr
	sscanf cellBorderStr, "%[LTRB]%[:]", borderSpec, colonStr
	if (V_Flag != 2)
		return -1				// Must start with some combination of L, T, R, B and include a colon
	endif
	
	int paramsStartPos = strsearch(cellBorderStr, ":", 0)
	if (paramsStartPos < 0)
		return -1				// No colon
	endif
	paramsStartPos += 1	// Byte after colon
	int totalLen = strlen(cellBorderStr)
	String paramsStr = cellBorderStr[paramsStartPos,totalLen]
	
	int paramIndex = 0
	do
		String paramStr = StringFromList(paramIndex, paramsStr)
		if (strlen(paramStr) == 0)
			break
		endif
		
		// Print paramIndex, paramStr
		String keyword = StringFromList(0, paramStr, "=")
		String param = StringFromList(1, paramStr, "=")
		strswitch(keyword)
			case "thickness":
				thickness = str2num(param)
				break
			case "dash":
				dashStyle = str2num(param)
				break
			case "rgb":
				sscanf param, "(%d,%d,%d)", red, green, blue
				if (V_Flag != 3)
					return -1
				endif
				break
			case "xoffset":
				xOffset = str2num(param)
				break
			case "yoffset":
				yOffset = str2num(param)
				break
			default:
				return -1
				break
		endswitch
		
		paramIndex += 1
	while(1)
	
	// sscanf cellBorderStr, "%[LTRB]:thickness=%g,dash=%d,rgb=(%d,%d,%d)%[;]", borderSpec, thickness, dashStyle, red, green, blue, semicolon
	
	return 0
End

Function TestCellBorderParams(cellBorderStrs)	// For testing only
	String cellBorderStrs
	
	int index = 0
	
	do
		String cellBorderStr = StringFromList(index, cellBorderStrs, "\r")
		if (strlen(cellBorderStr) == 0)
			break
		endif
		cellBorderStr += ";"
	
		String borderSpec
		double thickness
		int dashStyle
		int red
		int green
		int blue
		double xOffset, yOffset
		int result = GetCellBorderParams(cellBorderStr, borderSpec, thickness, dashStyle, red, green, blue, xOffset, yOffset)
		if (result != 0)
			Print result
			return result
		endif
		
		Printf "%s:thickness=%g;dash=%d;rgb=(%d,%d,%d);xoffset=%g;yoffset=%g;\r", borderSpec, thickness, dashStyle, red, green, blue, xOffset, yOffset
		
		index += 1
	while(1)
	
	return 0
End

static Function DrawBorderLine(wName, x0, y0, x1, y1)
	String wName					// Name of window to draw in
	double x0, y0, x1, y1
	
	DrawLine/W=$wName x0, y0, x1, y1
End

//	DrawPresentationCellBorder(wName, xLeft, yTop, xRight, yBottom, cellBorderStr)
//	cellBorderStr describes which border or borders to draw. It has the following
//	format which you must follow precisely:
//		X:thickness=<thickNum>;dash=<dashNum>;rgb=(<rNum>,<gNum>,<bNum>);;xoffset=<xoffsetNum>;yoffset=<yoffsetNum>;
//	where:
//		X is some combination of L, T, R, or B, in that order
//		thickNum is a line thickness in points
//		dashNum is a line dash style as for the SetDrawEnv dash keyword (0=solid)
//		rNum,gNum,bNum are in the range 0...65535 and specify the line color
//		xoffsetNum is an X offset in points
//		yoffsetNum is an Y offset in points
//	
//	You can omit any keyword=value pair to get the default for that keyword. The defaults are:
//		thickness:	1.0 (points)
//		dash:			0 (solid)
//		rgb:			(0,0,0) (black)
//		xoffset:		0.0 (points)
//		yoffset:		0.0 (points)
//
//	Examples:
//		"B:thickness=3;dash=1;rgb=(65535,0,0);"			// Bottom cell border
//		"LRTB:thickness=3;dash=1;rgb=(65535,0,0);"		// Left, right, top and bottom cell borders
//	
//	The DrawPresentationCellBorders below allows you to provide concatenated cell border strings
// by inserting a carriage return between sections.
//	For example, this gives a red left cell border and a blue right cell border:
//		"L:thickness=3;dash=0;rgb=(65535,0,0);" + "\r" + "R:thickness=5;dash=0;rgb=(0,0,65535);"
static Function DrawPresentationCellBorder(wName, xLeft, yTop, xRight, yBottom, cellBorderStr)
	String wName					// Name of window to draw in
	double xLeft, yTop			// Absolute coordinates in points of top/left corner of the row of text
	double xRight, yBottom
	String cellBorderStr
	
	if (strlen(cellBorderStr) == 0)
		return 0
	endif
	
	String borderSpec			// Some combination of L, T, R, B for left, top, right, bottom, in that order
	double thickness
	int dashStyle
	int red, green, blue
	double xOffset, yOffset
	if (GetCellBorderParams(cellBorderStr, borderSpec, thickness, dashStyle, red, green, blue, xOffset, yOffset))
		return -1		// Improperly formatted cellBorderStr
	endif
	
	// Like grids, border lines are drawn centered on the specified coordinates.
	// In this case, the specified coordinates are relative to the cell bounds.
	// This means that, for example, a 3 point border is half inside the cell's
	// bounds and half inside the bounds of an adjacent cell. I considered doing
	// an adjustment so that, by default (i.e., with no xoffset or yoffset),
	// a border would be entirely within a cell's bounds, but decided that it
	// was better to be mathematically consistent with the grid. Also, I'm not
	// sure what adjustment would work for all line thicknesses.
	// double lineAdjustment = thickness/2
	double lineAdjustment = 0
	
	xLeft += xoffset
	xRight += xoffset
	yTop += yoffset
	yBottom += yoffset
	
	SetDrawEnv/W=$wName fillpat=0, linethick=(thickness), dash=(dashStyle), linefgc=(red,green,blue), save
	
	int drawLeft = strsearch(borderSpec, "L", 0) >= 0
	if (drawLeft)
		DrawBorderLine(wName, xLeft+lineAdjustment, yTop, xLeft+lineAdjustment, yBottom)
	endif
	int drawTop = strsearch(borderSpec, "T", 0) >= 0
	if (drawTop)
		DrawBorderLine(wName, xLeft, yTop+lineAdjustment, xRight, yTop+lineAdjustment)
	endif
	int drawRight = strsearch(borderSpec, "R", 0) >= 0
	if (drawRight)
		DrawBorderLine(wName, xRight-lineAdjustment, yTop, xRight-lineAdjustment, yBottom)
	endif
	int drawBottom = strsearch(borderSpec, "B", 0) >= 0
	if (drawBottom)
		DrawBorderLine(wName, xLeft, yBottom-lineAdjustment, xRight, yBottom-lineAdjustment)
	endif
	
	return 0
End

static Function DrawPresentationCellBorders(wName, xLeft, yTop, xRight, yBottom, cellBorderStrs)
	String wName					// Name of window to draw in
	double xLeft, yTop			// Absolute coordinates in points of top/left corner of the row of text
	double xRight, yBottom
	String cellBorderStrs		// One or more cell border strings as described above DrawPresentationCellBorder
	
	if (strlen(cellBorderStrs) == 0)
		return 0
	endif
	
	SetDrawEnv/W=$wName push
	
	int index = 0
	do
		String cellBorderStr = StringFromList(index, cellBorderStrs, "\r")
		if (strlen(cellBorderStr) == 0)
			break
		endif
		DrawPresentationCellBorder(wName, xLeft, yTop, xRight, yBottom, cellBorderStr)
		index += 1
	while(1)
	
	SetDrawEnv/W=$wName pop
End

Function DPTMeasureText(wName, text, textFontStr, textSize, textStyle, textWidthOut, textHeightOut)
	String wName					// Name of window to draw in
	String text					// Input
	String textFontStr			// Input
	int textSize					// Input
	int textStyle				// Input
	double& textWidthOut		// Output
	double& textHeightOut		// Output
	
	// If textFontStr=="", MeasureStyledText gives the default font, but that requires Igor Pro 9.00 or later
	MeasureStyledText/W=$wName/F=textFontStr/SIZE=(textSize)/STYL=(textStyle) text
	
	textWidthOut = V_Width
	textHeightOut = V_Height
End

static Function DrawPresentationCell(dpt, xPos, yPos, row, column, rowHeight, columnWidth)
	struct DrawPresentationTableParams& dpt
	double xPos, yPos					// Absolute coordinates in points of top/left corner of the row of text
	int row								// Table row to draw
	int column							// Table column to draw
	double rowHeight, columnWidth

	String wName = dpt.wName
	WAVE/T cellData = dpt.cellData

	String text = cellData[row][column][kDPTCellTextLayer]
	String cellBorderStr = cellData[row][column][kDPTCellBorderLayer]
	String foregroundRGBStr = cellData[row][column][kDPTCellForegroundColorLayer]
	int fgRed, fgGreen, fgBlue
	int bgRed, bgGreen, bgBlue
	String textFontStr
	int textSize, textStyle
	int xJustification, yJustification
	GetCustomCellFormats(cellData, row, column, fgRed, fgGreen, fgBlue, bgRed, bgGreen, bgBlue, textFontStr, textSize, textStyle, xJustification, yJustification)

	double xRight = xPos + columnWidth
	double yBottom = yPos + rowHeight
	
	if (bgRed>0 || bgGreen>0 || bgBlue>0)
		SetDrawEnv/W=$wName fillfgc=(bgRed,bgGreen,bgBlue), fillpat=1, linethick=0
		DrawRect/W=$wName xPos, yPos, xRight, yBottom
	endif
	
	if (strlen(cellBorderStr) != 0)
		DrawPresentationCellBorders(wName, xPos, yPos, xRight, yBottom, cellBorderStr)
	endif
	
	double textWidth
	double textHeight
	DPTMeasureText(wName, text, textFontStr, textSize, textStyle, textWidth, textHeight)	// Sets textWidth and textHeight
	
	// Justification is handled by AdjustForXJustification and AdjustForYJustification so we omit the textXJust and textYJust keywords
	SetDrawEnv/W=$wName textrgb=(fgRed, fgGreen, fgBlue), fname=textFontStr, fsize=textSize, fstyle=textStyle
	
	double leftPadding, topPadding, rightPadding, bottomPadding
	GetCellPadding(cellData, row, column, leftPadding, topPadding, rightPadding, bottomPadding)
	
	double textXPos=xPos
	AdjustForXJustification(wName, textWidth, columnWidth, xJustification, leftPadding, rightPadding, textXPos)
	
	double textYPos=yPos
	AdjustForYJustification(wName, textHeight, rowHeight, yJustification, topPadding, bottomPadding, textYPos)
	
	int drewCustomCell = 0
	if (dpt.haveCustomDrawCellFunc)
		FUNCREF DPTCustomDrawCellFuncProto DrawCellFunc = dpt.DrawCellFunc
		drewCustomCell = DrawCellFunc(dpt, kDPTDrawCustomCellAction, row, column, xPos, yPos, xRight, yBottom, textWidth, textHeight)
		if (drewCustomCell)
			return 0
		endif
	endif
	
	DrawText/W=$wName textXPos, textYPos, text
	return 0
End

static Function DrawPresentationTableRow(dpt, x0, y0, row)
	struct DrawPresentationTableParams& dpt
	double x0, y0				// Absolute coordinates in points of top/left corner of the row of text
	int row						// row in wave to draw

	WAVE rowHeights = dpt.rowHeights				// Height of each row in points
	WAVE columnWidths = dpt.columnWidths			// Width of each column in points
	WAVE/T cellData = dpt.cellData
	
	double rowHeight = GetRowHeight(rowHeights, row)	// Row height in points
	if (rowHeight <= 0)
		return -1					// Invalid row height
	endif
	
	double xPos = x0, yPos = y0
	
	int numColumnsInTable = DimSize(cellData, 1)
	int column
	for(column=0; column<numColumnsInTable; column+=1)
		double columnWidth = GetColumnWidth(columnWidths, column)	// Column width in points
		if (columnWidth <= 0)
			continue				// Invalid column width
		endif
		double rowHeightWithMerge = GetCellHeightWithMerge(dpt, row, column)
		double columnWidthWithMerge = GetCellWidthWithMerge(dpt, row, column)
		DrawPresentationCell(dpt, xPos, yPos, row, column, rowHeightWithMerge, columnWidthWithMerge)
		if (columnWidth <= 0)
			columnWidth = kDefaultCellWidth
		endif
		xPos += columnWidth
	endfor
	
	return 0
End

static Function DrawPresentationTableCells(dpt)
	struct DrawPresentationTableParams& dpt
	
	String wName = dpt.wName
	String drawingGroupName = dpt.drawingGroupName
	double tableX0 = dpt.tableX0
	double tableY0 = dpt.tableY0
	WAVE rowHeights = dpt.rowHeights				// Height of each row in points
	WAVE columnWidths = dpt.columnWidths			// Width of each column in points
	WAVE/T cellData = dpt.cellData
	
	int numRowsInTable = DimSize(cellData, 0)
	if (numRowsInTable <= 0)
		return 0
	endif
	
	String cellsGroupName = drawingGroupName + "_Cells"
	DrawAction/W=$wName getgroup=$cellsGroupName, delete		// Delete old cells group if any
	StartGroup(wName, cellsGroupName)

	SetDrawEnv/W=$wName push
	
	double yPos = tableY0
	
	int row
	for(row=0; row<numRowsInTable; row+=1)
		DrawPresentationTableRow(dpt, tableX0, yPos, row)
		double dY = GetRowHeight(rowHeights, row)
		yPos += dY
	endfor

	SetDrawEnv/W=$wName pop
	StopGroup(wName, cellsGroupName)
End

static Function GetTableHeight(WAVE rowHeights)
	double tableHeight = 0
	int numRows = DimSize(rowHeights, 0)
	int row
	for(row=0; row<numRows; row+=1)
		double rowHeight = GetRowHeight(rowHeights, row)
		tableHeight += rowHeight
	endfor
	return tableHeight
End

static Function GetTableWidth(WAVE columnWidths)
	double tableWidth = 0
	int numColumns = DimSize(columnWidths, 0)
	int column
	for(column=0; column<numColumns; column+=1)
		double columnWidth = GetColumnWidth(columnWidths, column)
		tableWidth += columnWidth
	endfor
	return tableWidth
End

static Function DrawPresentationTableBackgroundColor(dpt)
	struct DrawPresentationTableParams& dpt
	
	if (dpt.drawTableBGColor == 0)
		return 0
	endif
	
	String wName = dpt.wName
	
	int tableBGRed = dpt.tableBGRed
	int tableBGGreen = dpt.tableBGGreen
	int tableBGBlue = dpt.tableBGBlue
	
	double tableX0 = dpt.tableX0						// Absolute coordinates in points of the top/left corner
	double tableY0 = dpt.tableY0						// of the presentation table
	
	double tableWidth = GetTableWidth(dpt.columnWidths)
	double tableHeight = GetTableHeight(dpt.rowHeights)
	
	double tableX1 = tableX0 + tableWidth
	double tableY1 = tableY0 + tableHeight
	
	String backgroundColorGroupName = dpt.drawingGroupName + "_BackgroundColor"
	DrawAction/W=$wName getgroup=$backgroundColorGroupName, delete		// Delete old background color group if any
	StartGroup(wName, backgroundColorGroupName)

	SetDrawEnv/W=$wName push
	
	SetDrawEnv/W=$wName fillfgc=(tableBGRed,tableBGGreen,tableBGBlue)
	DrawRect/W=$wName tableX0, tableY0, tableX1, tableY1

	SetDrawEnv/W=$wName pop
	StopGroup(wName, backgroundColorGroupName)
	
	return 0	
End

static Function DrawPresentationTableXGrid(dpt)	// Handles cell mergers
	struct DrawPresentationTableParams& dpt
	
	String wName = dpt.wName
	double x0 = dpt.tableX0
	double y0 = dpt.tableY0
	WAVE/T cellData = dpt.cellData
	WAVE rowHeights = dpt.rowHeights
	WAVE columnWidths = dpt.columnWidths
	
	int numRowsInTable = DimSize(rowHeights, 0)
	int numColumnsInTable = DimSize(columnWidths, 0)
	
	// Because lines are drawn centered on their coordinates, this adjustment
	// is needed to make the top and bottom X grid lines extend to the edges
	// of the leftmost and rightmost Y grid lines.
	double xAdjust = dpt.yGridThickness / 2
	
	double xPos = x0
	double yPos = y0
	int row
	for(row=0; row<=numRowsInTable; row+=1)
		xPos = x0
		int width = 0
		int column
		for(column=0; column<numColumnsInTable; column+=1)
			int columnWidth = columnWidths[column]
			int mergeWithNextRow=0, mergeWithNextColumn=0
			int testForMerge = row>0 && row<numRowsInTable
			if (testForMerge)
				GetCellMerger(cellData, row-1, column, mergeWithNextRow, mergeWithNextColumn)
			endif
			if (mergeWithNextRow)
				if (width > 0)
					DrawLine/W=$wName xPos-xAdjust, yPos, xPos+width+xAdjust, yPos	// Draw X grid before this column
					xPos = xPos + width
					width = 0
				endif
				xPos += columnWidth
			else
				width += columnWidth
			endif
		endfor
		if (width > 0)
			DrawLine/W=$wName xPos-xAdjust, yPos, xPos+width+xAdjust, yPos			// Draw remaining X grid
		endif
		
		if (row == numRowsInTable)
			break
		endif
		double dY = GetRowHeight(rowHeights, row)
		yPos += dY
	endfor
	
	return 0	
End

static Function DrawPresentationTableYGrid(dpt)	// Handles cell mergers
	struct DrawPresentationTableParams& dpt
	
	String wName = dpt.wName
	double x0 = dpt.tableX0
	double y0 = dpt.tableY0
	WAVE/T cellData = dpt.cellData
	WAVE rowHeights = dpt.rowHeights
	WAVE columnWidths = dpt.columnWidths
	
	int numRowsInTable = DimSize(rowHeights, 0)
	int numColumnsInTable = DimSize(columnWidths, 0)	
	
	double xPos = x0
	double yPos = y0
	int column
	for(column=0; column<=numColumnsInTable; column+=1)
		yPos = y0
		int height = 0
		int row
		for(row=0; row<numRowsInTable; row+=1)
			int rowHeight = rowHeights[row]
			int mergeWithNextRow=0, mergeWithNextColumn=0
			int testForMerge = column>0 && column<numColumnsInTable
			if (testForMerge)
				GetCellMerger(cellData, row, column-1, mergeWithNextRow, mergeWithNextColumn)
			endif
			if (mergeWithNextColumn)
				if (height > 0)
					DrawLine/W=$wName xPos, yPos, xPos, yPos+height	// Draw Y grid before this column
					yPos = yPos + height
					height = 0
				endif
				yPos += rowHeight
			else
				height += rowHeight
			endif
		endfor
		if (height > 0)
			DrawLine/W=$wName xPos, yPos, xPos, yPos+height			// Draw remaining Y grid
		endif
		
		if (column == numColumnsInTable)
			break
		endif
		double dX = GetColumnWidth(columnWidths, column)
		xPos += dX
	endfor
	
	return 0	
End

static Function DrawPresentationTableGrid(dpt)
	struct DrawPresentationTableParams& dpt
	
	double xGridThickness = dpt.xGridThickness
	double yGridThickness = dpt.yGridThickness
	if (xGridThickness<=0 && yGridThickness<=0)
		return 0
	endif

	String wName = dpt.wName
	int gridRed = dpt.gridRed
	int gridGreen = dpt.gridGreen
	int gridBlue = dpt.gridBlue
	
	String gridGroupName = dpt.drawingGroupName + "_Grid"
	DrawAction/W=$wName getgroup=$gridGroupName, delete		// Delete old grid group if any
	StartGroup(wName, gridGroupName)

	SetDrawEnv/W=$wName push
	
	if (xGridThickness > 0)
		SetDrawEnv lineThick=xGridThickness, linefgc=(gridRed,gridGreen,gridBlue), save
		DrawPresentationTableXGrid(dpt)
	endif
	
	if (yGridThickness > 0)
		SetDrawEnv lineThick=yGridThickness, linefgc=(gridRed,gridGreen,gridBlue), save
		DrawPresentationTableYGrid(dpt)
	endif

	SetDrawEnv/W=$wName pop
	StopGroup(wName, gridGroupName)
	
	return 0	
End

static Function DrawPresentationTableCaption(dpt, captionIndex)
	struct DrawPresentationTableParams& dpt
	int captionIndex		// 0-based index
	
	WAVE/T captionData = dpt.captionData
	int numCaptions = DimSize(captionData, 0)
	if (captionIndex<0 || captionIndex>=numCaptions)
		return -1				// Bad caption index
	endif
	
	String captionText = captionData[captionIndex][kDPTCaptionTextColumn]
  	if (strlen(captionText) == 0)
		return 0
	endif
	
	double dval
	
	// captionPosition: 0=above, 1=below, 2=left, 3=right
	int captionPosition = kDefaultCaptionPosition
	String captionPositionStr = captionData[captionIndex][kDPTCaptionPositionColumn]
	if (strlen(captionPositionStr) > 0)
		dval = str2num(captionPositionStr)
		if (numtype(dval) != 0)
			return -1					// Bad value for caption position
		endif
		captionPosition = dval
		if (captionPosition<0 || captionPosition>3)
			return -1					// Caption position out of range
		endif
	endif
	
	// If captionPosition is above or below, captionJustification is: 0=left, 1=center, 2=right
	// If captionPosition is left or right, captionJustification is: 0=bottom, 1=middle, 2=top
	int captionJustification = kDefaultCaptionJustification
	String captionJustificationStr = captionData[captionIndex][kDPTCaptionJustificationColumn]
	if (strlen(captionJustificationStr) > 0)
		dval = str2num(captionJustificationStr)
		if (numtype(dval) != 0)
			return -1					// Bad value for caption justification
		endif
		captionJustification = dval
		if (captionJustification<0 || captionJustification>2)
			return -1					// Caption justification out of range
		endif
	endif
	
	// If captionPosition is above or below, captionPadding is vertical padding in points
	// If captionPosition is left or right, captionPadding is horizontal padding in points
	double captionPadding = kDefaultCaptionPadding
	String captionPaddingStr = captionData[captionIndex][kDPTCaptionPaddingColumn]
	if (strlen(captionPaddingStr) > 0)
		dval = str2num(captionPaddingStr)	
		if (numtype(dval) != 0)
			return -1					// Bad value for caption padding
		endif
		captionPadding = dval
		if (captionPadding < 0)
			return -1					// Caption padding out of range
		endif
	endif
	
	double captionXOffset = kDefaultCaptionXOffset
	String captionXOffsetStr = captionData[captionIndex][kDPTCaptionXOffsetColumn]
	if (strlen(captionXOffsetStr) > 0)
		dval = str2num(captionXOffsetStr)	
		if (numtype(dval) != 0)
			return -1					// Bad value for caption X offset
		endif
		captionXOffset = dval
	endif
	
	double captionYOffset = kDefaultCaptionYOffset
	String captionYOffsetStr = captionData[captionIndex][kDPTCaptionYOffsetColumn]
	if (strlen(captionYOffsetStr) > 0)
		dval = str2num(captionYOffsetStr)	
		if (numtype(dval) != 0)
			return -1					// Bad value for caption Y offset
		endif
		captionYOffset = dval
	endif
	
	String wName = dpt.wName
	double x0 = dpt.tableX0							// Absolute coordinates in points of the top/left corner
	double y0 = dpt.tableY0							// of the presentation table
	
	double tableHeight = GetTableHeight(dpt.rowHeights)
	double tableWidth = GetTableWidth(dpt.columnWidths)
	
	String captionGroupName = dpt.drawingGroupName + "_Caption_" + num2istr(captionIndex)
	DrawAction/W=$wName getgroup=$captionGroupName, delete		// Delete old caption group if any
	StartGroup(wName, captionGroupName)
	
	SetDrawEnv/W=$wName push
	
	// The user can override these defaults using annotation escape codes
	String textFontStr = kDefaultTextFont
	int textSize = kDefaultTextSize
	int textStyle = kDefaultTextStyle
	
	// 	This is needed to get the right defaults for MeasureStyledText and DrawText
	// but the caption text can override any of these settings using
	// annotation escape codes
	SetDrawEnv/W=$wName fname=textFontStr, fsize=textSize, fstyle=textStyle
	
	double textWidth
	double textHeight
	DPTMeasureText(wName, captionText, textFontStr, textSize, textStyle, textWidth, textHeight)	// Sets textWidth and textHeight
	
	double textXPos = x0
	double textYPos = y0
	
	if (captionPosition==0 || captionPosition==1)		// Above or below
		switch(captionPosition)
			case 0:						// Above table
				textYPos -= captionPadding
				break;
			case 1:						// Below table
				textYPos 	+= tableHeight + textHeight
				textYPos += captionPadding
				break;
		endswitch
		switch(captionJustification)
			case 0:						// Left
				break;
			case 1:						// Center
				textXPos -= (textWidth - tableWidth) / 2
				break;
			case 2:						// Right
				textXPos -= textWidth
				textXPos += tableWidth
				break;
		endswitch
	endif
	
	if (captionPosition==2 || captionPosition==3)		// Left or right
		switch(captionPosition)
			case 2:						// Left of table
				textXPos -= textWidth + captionPadding
				break;
			case 3:						// Right of table
				textXPos 	+= tableWidth + captionPadding
				break;
		endswitch
		switch(captionJustification)
			case 0:						// Bottom
				textYPos += tableHeight
				break;
			case 1:						// Middle
				textYPos += (tableHeight + textHeight) / 2
				break;
			case 2:						// Top
				textYPos += textHeight
				break;
		endswitch
	endif
	
	textXPos += captionXOffset
	textYPos += captionYOffset
	
	DrawText/W=$wName textXPos, textYPos, captionText
	
	#if 0		// For testing only
		SetDrawEnv/W=$wName fillpat=0, linethick=1, linefgc=(65535,0,0)
		DrawRect/W=$wName textXPos, textYPos-textHeight, textXPos+textWidth, textYPos
	#endif

	SetDrawEnv/W=$wName pop
	StopGroup(wName, captionGroupName)
	
	return 0	
End

static Function DrawPresentationTableCaptions(dpt)
	struct DrawPresentationTableParams& dpt
	
	WAVE/T captionData = dpt.captionData
	int numCaptions = DimSize(captionData, 0)
	if (numCaptions == 0)
		return 0
	endif
	
	int captionIndex
	for(captionIndex=0; captionIndex<numCaptions; captionIndex+=1)
		DrawPresentationTableCaption(dpt, captionIndex)
	endfor
	
	return 0
End

// DrawPresentationTableSetTextFrom1DWaves(cellNumericFormats, columnHeaders, waves, cellData)
// Sets the cell text layer (kDPTCellTextLayer) of the cellData wave based on
// the 1D waves referenced by the waves parameter, using numeric formats specified
// by the cellNumericFormats wave.
// The cellNumericFormats must have one element for each cell of the table,
// including for header cells if columnHeaders is non-NULL.
// Supports 1D, real, numeric and text waves only.
// Does not support complex waves.
// Does not support date/time waves.
// 	Returns 0 if OK, non-zero if error
Function DrawPresentationTableSetTextFrom1DWaves(cellNumericFormats, columnHeaders, waves, cellData)
	WAVE/T cellNumericFormats		// 2D wave containing a numeric format for each table cell
	WAVE/T/Z columnHeaders		// Pass $"" for no column headers
	WAVE/WAVE waves					// List of waves
	WAVE/T cellData
	
	int numRowsInTable = DimSize(cellData, 0)
	int numColumnsInTable = DimSize(cellData, 1)
	if (DimSize(cellNumericFormats,0) != numRowsInTable)
		return -1			// cellNumericFormats has wrong number of rows 
	endif
	if (DimSize(cellNumericFormats,1) != numColumnsInTable)
		return -1			// cellNumericFormats has wrong number of columns 
	endif
	
	WAVE/Z firstWave = waves[0]
	if (!WaveExists(firstWave))
		return -1			// At least one wave is required
	endif
	
	int row, column
	
	int waveStartRow = 0					// Assume no column headers
	int numWaveRows = numRowsInTable	// Assume no column headers
	
	if (WaveExists(columnHeaders))
		waveStartRow += 1			// Fix assumption
		numWaveRows -= 1
		for(column=0; column<numColumnsInTable; column+=1)
			String headerText = columnHeaders[column]
			cellData[0][column][kDPTCellTextLayer] = headerText
		endfor
	endif
	
	for(column=0; column<numColumnsInTable; column+=1)
		int waveRow
		for(waveRow=0; waveRow<numWaveRows; waveRow+=1)
			int tableRow = waveStartRow+waveRow
			String numericFormat = cellNumericFormats[tableRow][column]
			if (strlen(numericFormat) == 0)
				numericFormat = kDefaultNumericFormat
			endif
			String text
			WAVE/Z w = waves[column]
			if (WaveExists(w))
				if (WaveType(w) == 0)			// Text wave?
					WAVE/T tw = w
					text = tw[waveRow]
				else
					double val = w[waveRow]
					sprintf text, numericFormat, val
				endif
				cellData[tableRow][column][kDPTCellTextLayer] = text
			endif
		endfor
	endfor
	
	return 0		// Success
End

static Function FindRowHeight(dpt, row)
	struct DrawPresentationTableParams& dpt
	int row
	
	String wName = dpt.wName
	WAVE/T cellData = dpt.cellData
	
	int numColumnsInTable = DimSize(cellData, 1)
	
	int rowHeight = 0
	
	int column
	for(column=0; column<numColumnsInTable; column+=1)
		double textWidth
		double textHeight
		
		// Because of complexity and ambiguity issues, cells that merge with rows below
		// are treated as zero height for the purpose of autosizing rows. See the "Cell Merging"
		// help topic for details.
		int mergeWithNextRow, mergeWithNextColumn
		GetCellMerger(cellData, row, column, mergeWithNextRow, mergeWithNextColumn)
		if (mergeWithNextRow)
			continue
		endif
		
		int measuredCustomCell = 0
		if (dpt.haveCustomDrawCellFunc)
			FUNCREF DPTCustomDrawCellFuncProto DrawCellFunc = dpt.DrawCellFunc
			measuredCustomCell = DrawCellFunc(dpt, kDPTMeasureCustomCellAction, row, column, 0, 0, 0, 0, textWidth, textHeight)
		endif
		
		if (!measuredCustomCell)
			String text = cellData[row][column][kDPTCellTextLayer]
			String foregroundRGBStr = cellData[row][column][kDPTCellForegroundColorLayer]
			int fgRed, fgGreen, fgBlue
			int bgRed, bgGreen, bgBlue
			String textFontStr
			int textSize, textStyle
			int xJustification, yJustification
			GetCustomCellFormats(cellData, row, column, fgRed, fgGreen, fgBlue, bgRed, bgGreen, bgBlue, textFontStr, textSize, textStyle, xJustification, yJustification)
			DPTMeasureText(wName, text, textFontStr, textSize, textStyle, textWidth, textHeight)	// Sets textWidth and textHeight
		endif
		
		double leftPadding, topPadding, rightPadding, bottomPadding
		GetCellPadding(cellData, row, column, leftPadding, topPadding, rightPadding, bottomPadding)
		double yCellPadding = topPadding + bottomPadding
		
		double thisRowHeight = textHeight + yCellPadding
		if (thisRowHeight > rowHeight)
			rowHeight = thisRowHeight
		endif
	endfor
	
	return rowHeight
End

// DrawPresentationTableAutosizeRows(dpt, minRowHeight)
// Sets the elements of the rowHeights wave based on the text and formatting in cellData.
// All layers of cellData must contain values suitable for DrawPresentationTable.
// minRowHeight is the minimum allowed row height. Pass 0 if you don't want any minimum.
// 	Returns 0 if OK, non-zero if error
Function DrawPresentationTableAutosizeRows(dpt, minRowHeight)
	struct DrawPresentationTableParams& dpt
	double minRowHeight		// Minimum allowed row height
	
	String wName = dpt.wName
	WAVE/T cellData = dpt.cellData
	WAVE rowHeights = dpt.rowHeights
	
	int numRowsInTable = DimSize(cellData, 0)
	if (DimSize(rowHeights,0) != numRowsInTable)
		return -1					// rowHeights has wrong number of rows 
	endif
	
	int row
	for(row=0; row<numRowsInTable; row+=1)
		double thisRowHeight = FindRowHeight(dpt, row)
		if (thisRowHeight < minRowHeight)
			thisRowHeight = minRowHeight			
		endif
		SetRowHeight(rowHeights, row, thisRowHeight)
	endfor
	
	return 0		// Success
End

static Function FindColumnWidth(dpt, column)
	struct DrawPresentationTableParams& dpt
	int column
	
	String wName = dpt.wName
	WAVE/T cellData = dpt.cellData
	
	int numRowsInTable = DimSize(cellData, 0)
	
	int columnWidth = 0
	
	int row
	for(row=0; row<numRowsInTable; row+=1)
		double textWidth
		double textHeight
		
		// Because of complexity and ambiguity issues, cells that merge with columns
		// to the right are treated as zero width for the purpose of autosizing columns.
		// See the "Cell Merging" help topic for details.
		int mergeWithNextRow, mergeWithNextColumn
		GetCellMerger(cellData, row, column, mergeWithNextRow, mergeWithNextColumn)
		if (mergeWithNextColumn)
			continue
		endif
		
		int measuredCustomCell = 0
		if (dpt.haveCustomDrawCellFunc)
			FUNCREF DPTCustomDrawCellFuncProto DrawCellFunc = dpt.DrawCellFunc
			measuredCustomCell = DrawCellFunc(dpt, kDPTMeasureCustomCellAction, row, column, 0, 0, 0, 0, textWidth, textHeight)
		endif
		
		if (!measuredCustomCell)
			String text = cellData[row][column][kDPTCellTextLayer]
			String foregroundRGBStr = cellData[row][column][kDPTCellForegroundColorLayer]
			int fgRed, fgGreen, fgBlue
			int bgRed, bgGreen, bgBlue
			String textFontStr
			int textSize, textStyle
			int xJustification, yJustification
			GetCustomCellFormats(cellData, row, column, fgRed, fgGreen, fgBlue, bgRed, bgGreen, bgBlue, textFontStr, textSize, textStyle, xJustification, yJustification)
			DPTMeasureText(wName, text, textFontStr, textSize, textStyle, textWidth, textHeight)	// Sets textWidth and textHeight
		endif
		
		double leftPadding, topPadding, rightPadding, bottomPadding
		GetCellPadding(cellData, row, column, leftPadding, topPadding, rightPadding, bottomPadding)
		double xCellPadding = leftPadding + rightPadding
		
		double thisColumnWidth = textWidth + xCellPadding
		if (thisColumnWidth > columnWidth)
			columnWidth = thisColumnWidth
		endif
	endfor
	
	return columnWidth
End

// DrawPresentationTableAutosizeColumns(dpt, minColumnWidth)
// Sets the elements of the columnWidths wave based on the text and formatting in cellData.
// All layers of cellData must contain values suitable for DrawPresentationTable.
// minColumnWidth is the minimum allowed column width. Pass 0 if you don't want any minimum.
// 	Returns 0 if OK, non-zero if error
Function DrawPresentationTableAutosizeColumns(dpt, minColumnWidth)
	struct DrawPresentationTableParams& dpt
	double minColumnWidth		// Minimum allowed column width
	
	String wName = dpt.wName
	WAVE/T cellData = dpt.cellData
	WAVE columnWidths = dpt.columnWidths
	
	int numColumnsInTable = DimSize(cellData, 1)
	if (DimSize(columnWidths,0) != numColumnsInTable)
		return -1					// rowHeights has wrong number of solumns 
	endif
	
	int column
	for(column=0; column<numColumnsInTable; column+=1)
		double thisColumnWidth = FindColumnWidth(dpt, column)
		if (thisColumnWidth < minColumnWidth)
			thisColumnWidth = minColumnWidth			
		endif
		SetColumnWidth(columnWidths, column, thisColumnWidth)
	endfor
	
	return 0		// Success
End

Function DrawPresentationTable(dpt)			// Returns 0 if OK, non-zero if error
	struct DrawPresentationTableParams& dpt
	
	String wName = dpt.wName
	String drawingLayerName = dpt.drawingLayerName
	String drawingGroupName = dpt.drawingGroupName
	double tableX0 = dpt.tableX0, tableY0 = dpt.tableY0
	WAVE rowHeights = dpt.rowHeights
	WAVE columnWidths = dpt.columnWidths
	WAVE/T cellData = dpt.cellData
	
	int numRowsInTable = DimSize(cellData, 0)
	if (numRowsInTable <= 0)
		return -1			// Invalid number of row 
	endif
	if (DimSize(rowHeights,0) != numRowsInTable)
		return -1			// rowHeights has wrong number of rows 
	endif
	
	int numColumnsInTable = DimSize(cellData, 1)
	if (numColumnsInTable <= 0)
		return -1			// Invalid number of columns 
	endif
	if (DimSize(columnWidths,0) != numColumnsInTable)
		return -1			// columnWidths has wrong number of rows 
	endif
	
	SetDrawLayer/W=$wName $drawingLayerName
	String prevDrawLayer = S_Name
	DrawAction/W=$wName getgroup=$drawingGroupName, delete	// Delete old table group if any
	StartGroup(wName, drawingGroupName)
	
	DrawPresentationTableBackgroundColor(dpt)
	DrawPresentationTableCells(dpt)
	DrawPresentationTableGrid(dpt)
	DrawPresentationTableCaptions(dpt)
	
	StopGroup(wName, drawingGroupName)
	SetDrawLayer/W=$wName $prevDrawLayer
	
	return 0		// Success
End
