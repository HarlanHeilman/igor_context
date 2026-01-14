#pragma TextEncoding = "UTF-8"
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma rtGlobals=3		// This mainly acts as notice that this proc is Igor 3.0 savvy

#pragma version=2.05
#pragma independentModule=WM_SplitAxisIModule

// Split Axis, Version 1.1, LH951107
// See the Split Axis Example experiment for documentation

// Version 1.1 created to be liberal name aware and data folder savvy

// Version 2.0, JW 090223
//		Made it image- and contour-aware.
// 		Added un-split and un-mark capabililty.
//		Added graph user data so that un-split and add split marks can find the most likely axes.
// 		Added /Q to menu item so that you don't get all that stuff in the history.
//		Function-ized everything.
//		Created control panel interface
//		Made it an independent module
// Version 2.01, JW 090708
//		Now properly handles swapXY graphs and /VERT traces
//		Now remembers if axis was reversed when unsplitting
// Version 2.02, JW 100827
//		If you clicked the Unsplit button when the menu read "None Available", it resulted
//			in an error that would put up an alert and break into the debugger.
//		Changed the updating of the menus so that if you clicked the Split It button multiple
//			times, the most recent split pair is offered as the default pair to be unsplit or marked.
// Version 2.03, JW 130826
//		Now it does the right thing with a category plot when splitting the category axis.
// Version 2.04, JW 200714
//		If the "other axis" (the axis perpendicular to the one being split) is a category axis, and
//			that axis uses dimension labels instead of a text wave, now the split doesn't create
//			a bad command for the new split traces.
// Version 2.05, JW 210624
//		Splitting a category axis gave very interesting results!
//		Changed rtGlobals to 3
//		Added Igor 9 pragma DefaultTab

#include <Readback ModifyStr>
#include <Graph Utility Procs>

Menu "Graph"
	"Split Axis Control", /Q, BuildSplitAxisPanel(WinName(0,1))
end

static Function/S WMSA_GetLastTraceName()		// funny name to avoid any possible future conflict
	Variable p0,p1	// for walking down the list
	Variable semicolon= char2num(";")

	String list=TraceNameList("", ";", 1)
	Variable numTraces = ItemsInList(list)
	return StringFromList(numTraces-1, list)
end

static Function/S WMSA_GetLastImageName()		// funny name to avoid any possible future conflict
	Variable p0,p1	// for walking down the list
	Variable semicolon= char2num(";")

	String list=ImageNameList("", ";")
	Variable numTraces = ItemsInList(list)
	return StringFromList(numTraces-1, list)
end

static Function/S WMSA_GetLastContourName()		// funny name to avoid any possible future conflict
	Variable p0,p1	// for walking down the list
	Variable semicolon= char2num(";")

	String list=ContourNameList("", ";")
	Variable numTraces = ItemsInList(list)
	return StringFromList(numTraces-1, list)
end

// returns 1 for all auto range
// if it returns 0, then at least one end has manual range; check minIsManual, maxIsManual for details
static Function CheckAxisRangeSettings(graphName, axisName, minIsManual, maxIsManual, hasSlashRFlag)
	String graphName, axisName
	Variable &minIsManual, &maxIsManual, &hasSlashRFlag
	
	String setaxisFlags = StringByKey("SETAXISFLAGS", AxisInfo(graphName, axisName))
	String setaxisCmd = StringByKey("SETAXISCMD", AxisInfo(graphName, axisName))
	
	Variable returnValue = 0
	hasSlashRFlag = strsearch(setaxisFlags, "/R", 0) >= 0 ? 1 : 0
	
	if (strsearch(setaxisFlags, "/A", 0) >= 0)
		Variable commaPos = strsearch(setaxisCmd, ",", 0)
		if (commaPos >= 0)
			// There's a comma, so there's at least one manual range
			returnValue = 0

			Variable starPos = strsearch(setaxisCmd, "*", 0)
			if (starPos >= 0)
				if (starPos < commaPos)
					minIsManual = 0
					maxIsManual = 1
				else
					minIsManual = 1
					maxIsManual = 0
				endif
			else
				// Hmmm.... this case should be the else part of if (strsearch(setaxisFlags, "/A", 0) > 0), because if both ends are manual, there's no /A flag
				// There's no star, so neither end is auto range
				minIsManual = 1
				maxIsManual = 1
			endif
		else
			minIsManual = 0
			maxIsManual = 0
			returnValue = 1
		endif
	else
		minIsManual = 1
		maxIsManual = 1
		returnValue = 0
	endif
	
	return returnValue
end

static StrConstant splitNameBase = "WMSplitAxis"
static StrConstant SplitListUDName = "WMSplitAxisList"

static Function/S GetFreeSplitName(graphName)
	String graphName
	
	if (strlen(graphName) == 0)
		graphName = WinName(0,1)
	endif
	
	Variable i = 0
	String splitAxisList = GetUserData(graphName, "", SplitListUDName)
	do
		String proposedName = splitNameBase+num2str(i)
		if (WhichListItem(proposedName, splitAxisList) < 0)
			break;
		endif
		i += 1
	while (1)
	
	return proposedName
end

static Function/S GetSplitAxisNameList(graphName [, splitMarkStatus])
	String graphName
	Variable splitMarkStatus			// 0 = don't check; 1= include only pairs with marks; 2 = include only pairs without marks
	
	string theList = GetUserData(graphName, "", SplitListUDName)
	
	if (splitMarkStatus)
		String fullList = theList
		theList = ""
		Variable nItems = ItemsInList(fullList)
		Variable i
		for (i = 0; i < nItems; i += 1)
//		for (i = nItems-1; i >= 0; i += 1)
			String splitName = StringFromList(i, fullList)
			String splitInfo = GetUserData(graphName, "", splitName)
			Variable hasMarks = strlen(StringByKey("SPLITMARKS", splitInfo, "=")) != 0
			Variable addToList = splitMarkStatus==1 ? hasMarks : !hasMarks
			if (addToList)
				theList += splitName+";"
			endif
		endfor
	endif
	
	return theList
end

Function isTraceSwapXY(graphName, traceName)
	String graphName, traceName
	
	String tinfo = TraceInfo(graphName, traceName, 0)
	String yAxis = StringByKey("YAXIS", tinfo , ":", ";")
	String ainfo = AxisInfo(graphName, yAxis)
	String aType = StringByKey("AXTYPE", ainfo, ":", ";")
	
	return (CmpStr(aType, "top") == 0) || (CmpStr(aType, "bottom") == 0)
end

Function isImageSwapXY(graphName, imageName)
	String graphName, imageName
	
	String iinfo = ImageInfo(graphName, imageName, 0)
	String yAxis = StringByKey("YAXIS", iinfo , ":", ";")
	String ainfo = AxisInfo(graphName, yAxis)
	String aType = StringByKey("AXTYPE", ainfo, ":", ";")
	
	return (CmpStr(aType, "top") == 0) || (CmpStr(aType, "bottom") == 0)
end

Function isContourSwapXY(graphName, contourName)
	String graphName, contourName
	
	String cinfo = ContourInfo(graphName, contourName, 0)
	String yAxis = StringByKey("YAXIS", cinfo , ":", ";")
	String ainfo = AxisInfo(graphName, yAxis)
	String aType = StringByKey("AXTYPE", ainfo, ":", ";")
	
	return (CmpStr(aType, "top") == 0) || (CmpStr(aType, "bottom") == 0)
end

Function isCategoryAxis(graphName, axisName)
	String graphName, axisName
	
	String ainfo = AxisInfo(graphName, axisName)
	return NumberByKey("ISCAT", ainfo)
end

static Function/S DoSplitAxis(graphName, axName,splitPoint,splitGap)
	String graphName, axName
	Variable splitPoint,splitGap
	
	PauseUpdate; Silent 1

	String newAxis
	Variable i=2
	do
		newAxis= axName+"_P"	+num2istr(i)	// name of new axis; left_P2
		if( strlen(AxisInfo(graphName, newAxis)) == 0 )
			break;
		endif
		i+=1
	while(1)

	String axInfo= AxisInfo(graphName, axName),axType
	axType= StringByKey("AXTYPE",axInfo)
	if( strlen(axType) == 0 )
		Abort "FOOBAR"						// sanity check, from now on we ASSUME things work
	endif
	Variable isX= (CmpStr("bottom", axType)==0 ) ||  (CmpStr("top", axType)==0 )
	Variable isSwapXY
	Variable isCategory = isCategoryAxis(graphName, axName)

	String tracesOnGraph= TraceNameList(graphName, ";", 1)
	String thetrace,tInfo,otheraxis,oaInfo,oaType
	String theCmd							// command string is built up here
	String key1,key2
	Variable/D av0,av1,sp
	Variable origStart,origEnd,split			// original axis start and end fractions, split point on axis
	
	GetAxis/Q/W=$graphName $axName
	av0= V_Min; av1= V_max
	
	Variable numTraces = ItemsInList(tracesOnGraph)
	for (i = 0; i < numTraces; i += 1)
		thetrace= StringFromList(i, tracesOnGraph)		
		tInfo= TraceInfo(graphName, thetrace, 0)
		isSwapXY = isTraceSwapXY(graphName, thetrace)
		if( isX )
			key1= "XAXIS"
			key2= "YAXIS"
		else
			key1= "YAXIS"
			key2= "XAXIS"
		endif
		if ( isSwapXY )
			String tempstr = key1
			key1 = key2
			key2 = tempstr
		endif
		if( CmpStr(axName,StringByKey(key1,tInfo))== 0 )
			otheraxis= StringByKey(key2,tInfo)
			oaInfo=  AxisInfo(graphName, otheraxis)
			oaType= StringByKey("AXTYPE",oaInfo)
			Variable oa_isCategory = isCategoryAxis(graphName, otheraxis)
			theCmd= "AppendToGraph/W="+graphName+"/"+oaType[0]+"="+otheraxis+"/"+axType[0]+"="+newAxis+" "
			if (isSwapXY)
				theCmd += "/VERT "
			endif
			theCmd += GetWavesDataFolder(TraceNameToWaveRef(graphName, thetrace), 4)
			if( strlen(StringByKey("XWAVE",tInfo)) != 0 || oa_isCategory || isCategory )
				Wave/Z xw = XWaveRefFromTrace(graphName, thetrace)
				if (WaveExists(xw))
					theCmd += " vs "+GetWavesDataFolder(xw, 4)
				elseif (oa_isCategory || isCategory)
					theCmd += " vs _labels_"
				else
					DoAlert 0, "You have found a bug. Please contact support@WaveMetrics.com. If you can, please include a copy of your Igor experiment file."
				endif
			endif
			Execute theCmd
			CopyTraceSettings(thetrace,-1,WMSA_GetLastTraceName(),-1, graphName=graphName)
		endif
	endfor
	
	String imagesOnGraph = ImageNameList(graphName, ";")
	Variable numImages = ItemsInList(imagesOnGraph)
	for (i = 0; i < numImages; i += 1)
		String theImage = StringFromList(i, imagesOnGraph)		
		String iInfo= ImageInfo(graphName, theImage, 0)
		isSwapXY = isImageSwapXY(graphName, theImage)
		if( isX )
			key1= "XAXIS"
			key2= "YAXIS"
		else
			key1= "YAXIS"
			key2= "XAXIS"
		endif
		if ( isSwapXY )
			tempstr = key1
			key1 = key2
			key2 = tempstr
		endif
		if( CmpStr(axName,StringByKey(key1,iInfo))== 0 )
			otheraxis= StringByKey(key2,iInfo)
			oaInfo=  AxisInfo(graphName, otheraxis)
			oaType= StringByKey("AXTYPE",oaInfo)
			theCmd= "AppendImage/W="+graphName+"/"+oaType[0]+"="+otheraxis+"/"+axType[0]+"="+newAxis+" "
			theCmd += GetWavesDataFolder(ImageNameToWaveRef(graphName, theImage), 4)
			String xwname = StringByKey("XWAVE",iInfo)
			String ywname = StringByKey("YWAVE",iInfo)
			if( (strlen(xwname) != 0) || (strlen(ywname) != 0) )
				theCmd += " vs {"
				if (strlen(xwname) != 0)
					xwname = StringByKey("XWAVEDF", iInfo)+xwname
				else
					xwname = "*"
				endif
				theCmd += xwname+","
				if (strlen(ywname) != 0)
					ywname = StringByKey("YWAVEDF", iInfo)+ywname
				else
					ywname = "*"
				endif
				theCmd += ywname+"}"
			endif
			Execute theCmd
			CopyImageSettings(theImage,-1,WMSA_GetLastImageName(),-1, graphName=graphName)
		endif
	endfor

	String contoursOnGraph = ContourNameList(graphName, ";")
	Variable numContours = ItemsInList(contoursOnGraph)
	for (i = 0; i < numContours; i += 1)
		String theContour = StringFromList(i, contoursOnGraph)		
		String cInfo= ContourInfo(graphName, theContour, 0)
		isSwapXY = isContourSwapXY(graphName, theContour)
		if( isX )
			key1= "XAXIS"
			key2= "YAXIS"
		else
			key1= "YAXIS"
			key2= "XAXIS"
		endif
		if ( isSwapXY )
			tempstr = key1
			key1 = key2
			key2 = tempstr
		endif
		if( CmpStr(axName,StringByKey(key1,cInfo))== 0 )
			otheraxis= StringByKey(key2,cInfo)
			oaInfo=  AxisInfo(graphName, otheraxis)
			oaType= StringByKey("AXTYPE",oaInfo)
			
			if (CmpStr(StringByKey("DATAFORMAT", cInfo), "Matrix") == 0)
				theCmd = "AppendMatrixContour"
			else
				theCmd = "AppendXYZContour"
			endif
			theCmd += "/W="+graphName+"/"+oaType[0]+"="+otheraxis+"/"+axType[0]+"="+newAxis+" "
			theCmd += GetWavesDataFolder(ContourNameToWaveRef(graphName, theContour), 4)
			xwname = StringByKey("XWAVE",cInfo)
			ywname = StringByKey("YWAVE",cInfo)
			if( (strlen(xwname) != 0) || (strlen(ywname) != 0) )
				theCmd += " vs {"
				if (strlen(xwname) != 0)
					xwname = StringByKey("XWAVEDF", cInfo)+xwname
				else
					xwname = "*"
				endif
				theCmd += xwname+","
				if (strlen(ywname) != 0)
					ywname = StringByKey("YWAVEDF", cInfo)+ywname
				else
					ywname = "*"
				endif
				theCmd += ywname+"}"
			endif
			Execute theCmd
			CopyContourSettings(theContour,-1,WMSA_GetLastContourName(),-1, graphName=graphName)
		endif
	endfor

	
	CopyAxisSettingsForGraph(graphName, axName, newAxis)
	origStart= GetNumFromModifyStr(axInfo,"axisEnab","{",0)
	origEnd= GetNumFromModifyStr(axInfo,"axisEnab","{",1)
	sp= splitPoint*(av1-av0)+av0
	if (isCategory)
		if (sp > 1)
			sp = floor(sp)
		else
			sp = ceil(sp)
		endif
	endif

	GetWindow $graphName,psize
	if( isX )
		splitGap= splitGap/(2*(V_right-V_left))
	else
		splitGap= splitGap/(2*(V_bottom-V_top))
	endif
//	splitGap *= origEnd-origStart

	split= splitPoint*(origEnd-origStart)+origStart
	Variable minIsManual, maxIsManual, hasSlashRFlag
	CheckAxisRangeSettings(graphName, axName, minIsManual, maxIsManual, hasSlashRFlag)
	String origAxisStartStr = ""
	String origAxisEndStr = ""
	
	if( splitPoint < 0.5 )				// leave original axis with biggest piece
		if (maxIsManual)
			SetAxis/W=$graphName $axName,sp,av1
			origAxisEndStr = num2str(av1)
		else
			if (hasSlashRFlag)
				SetAxis/R/W=$graphName $axName,sp,*
			else
				SetAxis/W=$graphName $axName,sp,*
			endif
			origAxisEndStr = "*"
		endif
		if (minIsManual)
			SetAxis/W=$graphName $newAxis,av0,sp
			origAxisStartStr = num2str(av0)
		else
			if (hasSlashRFlag)
				SetAxis/R/W=$graphName $newAxis,*,sp
			else
				SetAxis/W=$graphName $newAxis,*,sp
			endif
			origAxisStartStr = "*"
		endif
		ModifyGraph/W=$graphName axisEnab($axName)={split+splitGap,origEnd}
		ModifyGraph/W=$graphName axisEnab($newAxis)={origStart,split-splitGap}
	else
		if (minIsManual)
			SetAxis/W=$graphName $axName,av0,sp
			origAxisStartStr = num2str(av0)
		else
			if (hasSlashRFlag)
				SetAxis/R/W=$graphName $axName,*,sp
			else
				SetAxis/W=$graphName $axName,*,sp
			endif
			origAxisStartStr = "*"
		endif
		if (maxIsManual)
			SetAxis/W=$graphName $newAxis,sp,av1
			origAxisEndStr = num2str(av1)
		else
			if (hasSlashRFlag)
				SetAxis/R/W=$graphName $newAxis,sp,*
			else
				SetAxis/W=$graphName $newAxis,sp,*
			endif
			origAxisEndStr = "*"
		endif
		ModifyGraph/W=$graphName axisEnab($axName)={origStart,split-splitGap}
		ModifyGraph/W=$graphName axisEnab($newAxis)={split+splitGap,origEnd}
	endif
	ModifyGraph/W=$graphName standoff($axName)=0
	ModifyGraph/W=$graphName standoff($newAxis)=0
	
	if (!isFreeAxis(axName))
		ModifyGraph/W=$graphName freePos($axName)={0,kwFraction}
		ModifyGraph/W=$graphName freePos($newAxis)={0,kwFraction}
	endif
	
	String splitName = GetFreeSplitName(graphName)
	String splitAxisList = GetSplitAxisNameList(graphName)
	splitAxisList += splitName+";"
	SetWindow $graphName, UserData($SplitListUDName)= splitAxisList
	
	String splitInfo = "AXIS="+axName+";NEWAXIS="+newAxis+";"
	splitInfo += "AXISSTART="+origAxisStartStr+";AXISEND="+origAxisEndStr+";"
	splitInfo += "AXISENABSTART="+num2str(origStart)+";AXISENABEND="+num2str(origEnd)+";"
	splitInfo += "AXISHASSLASHR="+num2str(hasSlashRFlag)+";"
	SetWindow $graphName, UserData($splitName)=splitInfo
	
	return splitName
end

static Function isFreeAxis(axisName)
	String axisName
	
	strswitch(axisName)
		case "top":
		case "bottom":
		case "left":
		case "right":
			return 0
			break;
		default:
			return 1
			break;
	endswitch
end

static Function isHorizAxis(graphName, axisName)
	String graphName, axisName
	
	String axInfo= AxisInfo(graphName,axisName)
	String axType
	axType= StringByKey("AXTYPE",axInfo)
	return (CmpStr("bottom", axType)==0 ) ||  (CmpStr("top", axType)==0 )
end

Function/S ExtractFreePosCommand(infoStr)
	String infoStr
	
	Variable freePosPos = strsearch(infoStr, "freePos(x)=",0)
	String cmdStr = ""
	
	if (freePosPos >= 0)
		Variable semiPos = strsearch(infoStr, ";", freePosPos)
		if (semiPos >= 0)
			cmdStr = infoStr[freePosPos, semiPos-1]
		else
			cmdStr = infoStr[freePosPos, strlen(infoStr)-1]
		endif
	endif
	
	return cmdStr
end

 Function AxisPerpendicularPosition(graphName, axisName)
	String graphName, axisName
	
	Variable isX = isHorizAxis(graphName, axisName)
	String axInfo = AxisInfo(graphName,axisName)
	String axType = StringByKey("AXTYPE",axInfo)

	if (!isFreeAxis(axisName))
		if ( (isX && (CmpStr("bottom", axType)==0)) || (!isX && (CmpStr("left", axType)==0)) )
			return 0
		else
			return 1
		endif
	else
		String freePosCmd = ExtractFreePosCommand(axInfo)
		Variable freePos = 0
		if (strsearch(freePosCmd, "kwFraction", 0) >= 0)
			// Fraction of plot area positioning
			sscanf freePosCmd, "freePos(x)={%g", freePos
			if ((CmpStr("top", axType)==0 ) ||  (CmpStr("right", axType)==0 ))
				freePos = 1-freePos
			endif
			return freePos
		elseif (strsearch(freePosCmd, "{", 0) >= 0)
			// Crossing at positioning
			String otherAxis=""
			Variable lastBracePos = strsearch(freePosCmd, "}", inf, 1)
			if (lastBracePos >= 0)
				freePosCmd = freePosCmd[0,lastBracePos-1]
			endif
			sscanf freePosCmd, "freePos(x)={%g,%s}", freePos, otherAxis
			GetAxis/Q/W=$graphName $otherAxis
			Variable freePosFraction = (freePos-V_min)/(V_max - V_min)
			Variable a1start= GetNumFromModifyStr(AxisInfo(graphName, otherAxis),"axisEnab","{",0)
			Variable a1end= GetNumFromModifyStr(AxisInfo(graphName, otherAxis),"axisEnab","{",1)
			freePosFraction = freePosFraction*(a1end - a1start) + a1start
			return freePosFraction
		else
			// offset from plot area edge positioning
			sscanf freePosCmd, "freePos(x)=%g", freePos
			GetWindow $graphname psize
			Variable width
			width = isX ? V_bottom - V_top : V_right - V_left
			freePos = -freePos/width

			if ((CmpStr("top", axType)==0 ) ||  (CmpStr("right", axType)==0 ))
				freePos = 1-freePos
			endif
			
			return freePos
		endif
	endif
end

Function UnsplitAxis(graphName, splitAxisName)
	String graphName, splitAxisName
	
	if (strlen(graphName) == 0)
		graphName = WinName(0,1)
	endif
	
	if (strlen(splitAxisName) <= 0)
		return -1
	endif
	
	String splitList = GetSplitAxisNameList(graphName)
	if (strlen(splitList) <= 0)
		return -1
	endif
	
	if (WhichListItem(splitAxisName, splitList) < 0)
		return -1
	endif
	
	String splitInfo = GetUserData(graphName, "", splitAxisName)
	String axisStartStr = StringByKey("AXISSTART", splitInfo, "=")
	String axisEndStr = StringByKey("AXISEND", splitInfo, "=")
	String axisEnabStartStr = StringByKey("AXISENABSTART", splitInfo, "=")
	String axisEnabEndStr = StringByKey("AXISENABEND", splitInfo, "=")
	String axisHasSlashRStr = StringByKey("AXISHASSLASHR", splitInfo, "=")
	Variable hasSlashR = str2num(axisHasSlashRStr)
	String splitMarks = StringByKey("SPLITMARKS", splitInfo, "=")
	String newAxis = StringByKey("NEWAXIS", splitInfo, "=")
	String oldAxis = StringByKey("AXIS", splitInfo, "=")
	Variable items
	Variable i
	
	String traces = ListTracesUsingAxis(graphname, newAxis)
	items = ItemsInList(traces)
	for (i = items-1; i >= 0; i -= 1)
		String tname = StringFromList(i, traces)
		RemoveFromGraph/W=$graphName $tname
	endfor
	
	String contours = ListContoursUsingAxis(graphname, newAxis)
	items = ItemsInList(contours)
	for (i = items-1; i >= 0; i -= 1)
		String cname = StringFromList(i, contours)
		RemoveContour /W=$graphName $cname
	endfor
	
	String images = ListImagesUsingAxis(graphname, newAxis)
	items = ItemsInList(images)
	for (i = items-1; i >= 0; i -= 1)
		String iname = StringFromList(i, images)
		RemoveImage/W=$graphName $iname
	endfor
	
	DoUpdate
	
	Variable axisStartIsAuto = CmpStr(axisStartStr, "*") == 0
	Variable axisEndIsAuto = CmpStr(axisEndStr, "*") == 0
	if (axisStartIsAuto && axisEndIsAuto)
		if (hasSlashR)
			SetAxis/A/R $oldAxis
		else
			SetAxis/A $oldAxis
		endif
	elseif (axisStartIsAuto)
		if (hasSlashR)
			SetAxis/A/R $oldAxis, *, str2num(axisEndStr)
		else
			SetAxis/A $oldAxis, *, str2num(axisEndStr)
		endif
	elseif (axisEndIsAuto)
		if (hasSlashR)
			SetAxis/A/R $oldAxis, str2num(axisStartStr), *
		else
			SetAxis/A $oldAxis, str2num(axisStartStr), *
		endif
	else
		SetAxis $oldAxis, str2num(axisStartStr), str2num(axisEndStr)
	endif
	ModifyGraph/W=$graphName axisEnab($oldAxis)={str2num(axisEnabStartStr), str2num(axisEnabEndStr)}
	
	RemoveSplitMarkGroup(graphName, splitMarks)
	
	splitList = RemoveFromList(splitAxisName, splitList)
	SetWindow $graphName, UserData($SplitListUDName)= splitList
	SetWindow $graphName, UserData($splitAxisName)=""
end

// these params determine size and angle of slash
Static constant SLASH_LEN= 5
Static constant SLASH_HEIGHT=2

static Function/S UniqueDrawGroupName(graphName)
	String graphName
	
	Variable i=0
	do
		String proposedName = "WM_SplitMarkGroup"+num2str(i)
		DrawAction/W=$graphName/L=UserFront getgroup=$proposedName
		if (V_flag == 0)
			break;
		endif
		i += 1
	while (1)
	
	return proposedName
end

Function AddSplitMarksToSplitPair(graphName, splitAxisName)
	String graphName, splitAxisName
	
	
	if (strlen(graphName) == 0)
		graphName = WinName(0,1)
	endif
	
	String splitList = GetSplitAxisNameList(graphName)
	if (WhichListItem(splitAxisName, splitList) < 0)
		return -1
	endif
	
	String splitInfo = GetUserData(graphName, "", splitAxisName)
	String newAxis = StringByKey("NEWAXIS", splitInfo, "=")
	String oldAxis = StringByKey("AXIS", splitInfo, "=")
	String drawGroupName = DoAddSplitAxisMarks(graphName, oldAxis,newAxis)
	splitInfo += "SPLITMARKS="+drawGroupName+";"
	SetWindow $graphName, UserData($splitAxisName)=splitInfo
end

Function/S DoAddSplitAxisMarks(graphName, axName1,axName2)
	String graphName, axName1,axName2
	
	String axInfo1= AxisInfo(graphName,axName1),axInfo2= AxisInfo("",axName2)
	String axType1,axType2
	axType1= StringByKey("AXTYPE",axInfo1)
	axType2= StringByKey("AXTYPE",axInfo2)
	if( CmpStr(axType1,axType2)!= 0 )
		Abort "Different kinds of axes - unlikely"		// sanity check
	endif
	// ***** need free axes as well *****
	Variable isX= isHorizAxis(graphName, axName1)

	Variable a1start,a2start,a1end,a2end
	
	a1start= GetNumFromModifyStr(axInfo1,"axisEnab","{",0)
	a1end= GetNumFromModifyStr(axInfo1,"axisEnab","{",1)
	a2start= GetNumFromModifyStr(axInfo2,"axisEnab","{",0)
	a2end= GetNumFromModifyStr(axInfo2,"axisEnab","{",1)
	if( a1end > a2start )		// user chose axes in reverse order
		a1end= a2end
		a2start= a1start
	endif
	GetWindow $graphName,psize
	Variable x0= V_left, y0= V_top,dx= V_right-V_left,dy= V_bottom-V_top,x,y
	Variable sh,sl

	String drawGroupName = UniqueDrawGroupName(graphName)
	SetDrawLayer/W=$graphName UserFront
	SetDrawEnv/W=$graphName gstart, gname=$drawGroupName
	if( isX )
		x= a1end
		y = 1-AxisPerpendicularPosition(graphName, axName1)		// prel coordinates have 0 at the *top* of the plot rectangle
		sh= SLASH_HEIGHT/dx
		sl= SLASH_LEN/dy
		SetDrawEnv/W=$graphName xcoord= prel,ycoord= prel
		DrawLine/W=$graphName x-sh,y-sl,x+sh,y+sl
		x= a2start
		SetDrawEnv/W=$graphName xcoord= prel,ycoord= prel
		DrawLine/W=$graphName x-sh,y-sl,x+sh,y+sl
	else
		y= 1-a1end
		x = AxisPerpendicularPosition(graphName, axName1)
		sh= SLASH_HEIGHT/dy
		sl= SLASH_LEN/dx
		SetDrawEnv/W=$graphName xcoord= prel,ycoord= prel
		DrawLine/W=$graphName x-sl,y-sh,x+sl,y+sh
		y= 1-a2start
		SetDrawEnv/W=$graphName xcoord= prel,ycoord= prel
		DrawLine/W=$graphName x-sl,y-sh,x+sl,y+sh
	endif
	SetDrawEnv/W=$graphName gstop
	SetWindow $graphName, UserData($drawGroupName)="AXIS1="+axName1+";AXIS2="+axName2+";"
	String SplitMarkList = GetUserData(graphName, "", "WM_SplitMarkGroupList" )
	SplitMarkList += drawGroupName+";"
	SetWindow $graphName, UserData(WM_SplitMarkGroupList)= SplitMarkList
	return drawGroupName
end

Function/S listSplitMarks(graphName)
	String graphName
	
	if (strlen(graphName) == 0)
		graphName = WinName(0,1)
	endif
	
	return GetUserData(graphName, "", "WM_SplitMarkGroupList" )
end

Function RemoveSplitMarkFromSplitAxis(graphName, splitAxisName)
	String graphName, splitAxisName
	
	String splitInfo = GetUserData(graphName, "", splitAxisName)
	String splitMarkName = StringByKey("SPLITMARKS", splitInfo, "=")
	if (strlen(splitMarkName) > 0)
		RemoveSplitMarkGroup(graphName, splitMarkName)
		splitInfo = RemoveByKey("SPLITMARKS", splitInfo, "=")
		SetWindow $graphName, UserData($splitAxisName)=splitInfo
	endif
end

Function RemoveSplitMarkGroup(graphName, groupName)
	String graphName, groupName
	
	if (strlen(groupName) == 0)
		return 0
	endif
	
	if (strlen(graphName) == 0)
		graphName = WinName(0,1)
	endif
	
	DrawAction/W=$graphName/L=UserFront getgroup=$groupName, delete
	String SplitMarkList = GetUserData(graphName, "", "WM_SplitMarkGroupList" )
	if (WhichListItem(groupName, SplitMarkList) >= 0)
		SplitMarkList = RemoveFromList(groupName, SplitMarkList)
		SetWindow $graphName, UserData(WM_SplitMarkGroupList)= SplitMarkList
		SetWindow $graphName, UserData($groupName)=""
	endif
end

static Function/S ListTracesUsingAxis(graphname, axisName)
	String graphname, axisName
	
	String tnames = TraceNameList(graphName, ";", 1)
	Variable items = ItemsInList(tnames)
	Variable i
	
	String tlist = ""
	for (i = 0; i < items; i += 1)
		String tname = StringFromList(i, tnames)
		if ( (CmpStr(StringByKey("XAXIS", TraceInfo(graphName, tname, 0)), axisName) == 0) || (CmpStr(StringByKey("YAXIS", TraceInfo(graphName, tname, 0)), axisName) == 0) )
			tlist += tname+";"
		endif
	endfor
	
	return tlist
end

static Function/S ListContoursUsingAxis(graphname, axisName)
	String graphname, axisName
	
	String tnames = ContourNameList(graphName, ";")
	Variable items = ItemsInList(tnames)
	Variable i
	
	String tlist = ""
	for (i = 0; i < items; i += 1)
		String tname = StringFromList(i, tnames)
		if ( (CmpStr(StringByKey("XAXIS", ContourInfo(graphName, tname, 0)), axisName) == 0) || (CmpStr(StringByKey("YAXIS", ContourInfo(graphName, tname, 0)), axisName) == 0) )
			tlist += tname+";"
		endif
	endfor
	
	return tlist
end

static Function/S ListImagesUsingAxis(graphname, axisName)
	String graphname, axisName
	
	String tnames = ImageNameList(graphName, ";")
	Variable items = ItemsInList(tnames)
	Variable i
	
	String tlist = ""
	for (i = 0; i < items; i += 1)
		String tname = StringFromList(i, tnames)
		if ( (CmpStr(StringByKey("XAXIS", ImageInfo(graphName, tname, 0)), axisName) == 0) || (CmpStr(StringByKey("YAXIS", ImageInfo(graphName, tname, 0)), axisName) == 0) )
			tlist += tname+";"
		endif
	endfor
	
	return tlist
end

Function/S WMSA_ListSplitAxisPairs(graphName, splitMarkStatus)
	String graphName
	Variable splitMarkStatus			// 0 = don't check; 1= include only pairs with marks; 2 = include only pairs without marks
	
	String splitlist = GetSplitAxisNameList(graphName)
	Variable items = ItemsInList(splitlist)
	Variable i
	
	String theList = ""
	for (i = 0; i < items; i += 1)
		String splitAxisName = StringFromList(i, splitlist)
		String splitInfo = GetUserData(graphName, "", splitAxisName)
		Variable hasMarks = strlen(StringByKey("SPLITMARKS", splitInfo, "=")) != 0
		Variable addToList = 1
		if (splitMarkStatus)
			addToList = splitMarkStatus==1 ? hasMarks : !hasMarks
		endif
		if (addToList)
			String newAxis = StringByKey("NEWAXIS", splitInfo, "=")
			String oldAxis = StringByKey("AXIS", splitInfo, "=")
			theList += oldAxis+" and "+newAxis+";"
		endif
	endfor
	
	if (strlen(theList) == 0)
		theList = "\\M1(None Available"
	endif
	
	return theList
end

Function BuildSplitAxisPanel(graphName)
	String graphName
	
	String pName = graphName+"#SplitAxisControl"
	if (wintype(pName) == 7)
		DoWindow/F $graphName
		return 0
	endif

	NewPanel/HOST=$graphName/EXT=0/W=(0,623,315,623)/K=1 as "Split Axes"
	RenameWindow #, SplitAxisControl
	pName = graphName+"#SplitAxisControl"
	String s
	
	GroupBox WMSA_AddSplitGroupBox,win=$pName, pos={16,19},size={279,174},title="Split Axis"
	GroupBox WMSA_AddSplitGroupBox,win=$pName, fSize=12
	PopupMenu WMSA_AxisList,win=$pName, pos={27,46},size={254,20},bodyWidth=150,title="Add Split to Axis:"
	PopupMenu WMSA_AxisList,win=$pName, fSize=12
	PopupMenu WMSA_AxisList,win=$pName, mode=1
	s="AxisList(\""+graphName+"\")"
	PopupMenu WMSA_AxisList,win=$pName, value=#s
	SetVariable WMSA_SplitPosition,win=$pName, pos={61,78},size={210,19},bodyWidth=60,title="Split Position (% of axis):"
	SetVariable WMSA_SplitPosition,win=$pName, fSize=12,limits={0,100,1},value= _NUM:80
	SetVariable WMSA_SplitGap,win=$pName, pos={101,101},size={170,19},bodyWidth=60,title="Split Gap (points):"
	SetVariable WMSA_SplitGap,win=$pName, fSize=12,limits={0,inf,1},value= _NUM:8
	CheckBox WMSA_AddSplitMarksCheck,win=$pName, pos={129,129},size={135,16},title="Add Split Marks, too"
	CheckBox WMSA_AddSplitMarksCheck,win=$pName, fSize=12,value= 0
	Button WMSA_AddSplitButton,win=$pName, pos={95,163},size={120,20},proc=WMSA_AddSplitButtonProc,title="Split It"

	GroupBox WMSA_AddSplitMarksGroup,win=$pName, pos={16,211},size={279,124},title="Add Split Marks"
	GroupBox WMSA_AddSplitMarksGroup,win=$pName, fSize=12
	PopupMenu WMSA_SplitPairMenu,win=$pName, pos={55,259},size={200,20},bodyWidth=200
	PopupMenu WMSA_SplitPairMenu,win=$pName, mode=1
	s = GetIndependentModuleName()+"#WMSA_ListSplitAxisPairs(\""+graphName+"\", 2)"
	PopupMenu WMSA_SplitPairMenu,win=$pName, value= #s
	TitleBox WMSA_AddSplitMarksToTitle,win=$pName, pos={33,236},size={113,16},title="Add Marks to Axes:"
	TitleBox WMSA_AddSplitMarksToTitle,win=$pName, fSize=12,frame=0
	Button WMSA_AddMarksButton,win=$pName, pos={95,297},size={120,20},proc=WMSA_AddMarksButtonProc,title="Add Marks"

	GroupBox WMSA_RemoveSplitMarksGroup,win=$pName, pos={16,347},size={279,124},title="Remove Split Marks"
	GroupBox WMSA_RemoveSplitMarksGroup,win=$pName, fSize=12
	PopupMenu WMSA_SplitPairMenu1,win=$pName, pos={55,395},size={200,20},bodyWidth=200
	PopupMenu WMSA_SplitPairMenu1,win=$pName, mode=1
	s = GetIndependentModuleName()+"#WMSA_ListSplitAxisPairs(\""+graphName+"\", 1)"
	PopupMenu WMSA_SplitPairMenu1,win=$pName, value= #s
	TitleBox WMSA_AddSplitMarksToTitle1,win=$pName, pos={33,372},size={152,16},title="Remove Marks From Axes:"
	TitleBox WMSA_AddSplitMarksToTitle1,win=$pName, fSize=12,frame=0
	Button WMSA_AddMarksButton1,win=$pName, pos={95,433},size={120,20},proc=WMSA_RemoveMarksButtonProc,title="Remove Marks"

	GroupBox WMSA_RemoveAxisSplitGroup,win=$pName, pos={16,491},size={279,124},title="Remove Axis Split"
	GroupBox WMSA_RemoveAxisSplitGroup,win=$pName, fSize=12
	PopupMenu WMSA_SplitPairMenu2,win=$pName, pos={55,539},size={200,20},bodyWidth=200
	PopupMenu WMSA_SplitPairMenu2,win=$pName, mode=1
	s = GetIndependentModuleName()+"#WMSA_ListSplitAxisPairs(\""+graphName+"\", 0)"
	PopupMenu WMSA_SplitPairMenu2,win=$pName, value= #s
	TitleBox WMSA_RemoveAxisSplitTitle,win=$pName, pos={33,516},size={129,16},title="Choose Split Axis Pair:"
	TitleBox WMSA_RemoveAxisSplitTitle,win=$pName, fSize=12,frame=0
	Button WMSA_RemoveAxisSplitButton,win=$pName, pos={95,577},size={120,20},proc=WMSA_RemoveSplitButtonProc,title="Unsplit"
	
	SetWindow $pName, UserData(WMSA_HostGraph)=graphName
EndMacro

static function WMSA_UpdateMenus(graphName)
	String graphName
	
	String pName = graphName+"#SplitAxisControl"
	
	ControlInfo/W=$pName WMSA_AxisList
	String selectedText = S_value
	String menuList = AxisList(graphName)
	Variable index = WhichListItem(selectedText, menuList)
	index = index < 0 ? 1 : index+1
	PopupMenu WMSA_AxisList,win=$pName,mode=index
	ControlUpdate/W=$pName WMSA_AxisList
	
	menuList = WMSA_ListSplitAxisPairs(graphName, 2)
	index = ItemsInList(menuList)
	PopupMenu WMSA_SplitPairMenu,win=$pName,mode=index
	ControlUpdate/W=$pName WMSA_SplitPairMenu
	
	menuList = WMSA_ListSplitAxisPairs(graphName, 1)
	index = ItemsInList(menuList)
	PopupMenu WMSA_SplitPairMenu1,win=$pName,mode=index
	ControlUpdate/W=$pName WMSA_SplitPairMenu1
	
	menuList = WMSA_ListSplitAxisPairs(graphName, 0)
	index = ItemsInList(menuList)
	PopupMenu WMSA_SplitPairMenu2,win=$pName,mode=index
	ControlUpdate/W=$pName WMSA_SplitPairMenu2
end

Function WMSA_AddSplitButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s

	if (s.eventCode == 2)			// mouse up
		String hostGraph = GetUserData(s.win, "", "WMSA_HostGraph")
		ControlInfo/W=$(s.win) WMSA_AxisList
		String axisName = S_value
		ControlInfo/W=$(s.win) WMSA_SplitPosition
		Variable splitPoint = V_value
		ControlInfo/W=$(s.win) WMSA_SplitGap
		Variable splitGap = V_value
		string splitName = DoSplitAxis(hostGraph, axisName,splitPoint/100,splitGap)
	
		ControlInfo/W=$(s.win) WMSA_AddSplitMarksCheck
		if (V_value)
			AddSplitMarksToSplitPair(hostGraph, splitName)
		endif
		
		WMSA_UpdateMenus(hostGraph)
	endif
End

Function WMSA_AddMarksButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s

	if (s.eventCode == 2)			// mouse up
		String hostGraph = GetUserData(s.win, "", "WMSA_HostGraph")
		String splitlist = GetSplitAxisNameList(hostGraph, splitMarkStatus=2)
		ControlInfo/W=$(s.win) WMSA_SplitPairMenu
		Variable splitIndex = V_value-1
		String splitName = StringFromList(splitIndex, splitList)
		AddSplitMarksToSplitPair(hostGraph, splitName)
		
		WMSA_UpdateMenus(hostGraph)
	endif
End

Function WMSA_RemoveMarksButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s

	if (s.eventCode == 2)			// mouse up
		String hostGraph = GetUserData(s.win, "", "WMSA_HostGraph")
		String splitlist = GetSplitAxisNameList(hostGraph, splitMarkStatus=1)
		ControlInfo/W=$(s.win) WMSA_SplitPairMenu1
		Variable splitIndex = V_value-1
		String splitName = StringFromList(splitIndex, splitList)
		RemoveSplitMarkFromSplitAxis(hostGraph, splitName)
		
		WMSA_UpdateMenus(hostGraph)
	endif
End

Function WMSA_RemoveSplitButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s

	if (s.eventCode == 2)			// mouse up
		String hostGraph = GetUserData(s.win, "", "WMSA_HostGraph")

		ControlInfo/W=$(s.win) WMSA_SplitPairMenu2
		Variable splitIndex = V_value-1
		String splitlist = GetSplitAxisNameList(hostGraph)
		String splitName = StringFromList(splitIndex, splitList)
		
		UnsplitAxis(hostGraph, splitName)
		
		WMSA_UpdateMenus(hostGraph)
	endif
End