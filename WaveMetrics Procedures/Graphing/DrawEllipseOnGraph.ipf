#pragma rtGlobals=2		// Use modern global access method.
#pragma IgorVersion = 4.0
#pragma version = 1.0
#include <Axis Utilities>

//*********************************************
//
// DrawEllipseOnGraph.ipf version 1.0
//
// Draw ellipses with oblique axes on a graph. The built-in draw tools ellipses
// have axes parallel to the window sides only.
//
// Features to add sometime:
//	1)	Do editing in absolute coordinates so that the handles are in the right places.
//	2)	Add support for fills (maybe).
//	3)	Likewise, add support for color.
//*********************************************


constant EDIT_ELLIPSE_ACTION = 1
constant ERASE_ELLIPSE_ACTION = 2
constant DRAW_ELLIPSE_ACTION = 3
constant MOVE_ELLIPSE_LAYER_ACTION = 4
static constant ELLIPSE_NUM_POINTS = 500

Menu "Graph"
	Submenu "Oblique Ellipses"
		EllipseMenuUndoItem(), UndoLastEllipseAction("")
		"Draw New Ellipse...", mDrawNewEllipse()
		"Edit an Ellipse", mSelectEllipseAndDoSomething(EDIT_ELLIPSE_ACTION)
		"Erase an Ellipse", mSelectEllipseAndDoSomething(ERASE_ELLIPSE_ACTION)
		"Change Ellipse Layer", mSelectEllipseAndDoSomething(MOVE_ELLIPSE_LAYER_ACTION)
	end
end

Function mDrawNewEllipse()
	if (WinType("DrawNewEllipsePanel") != 7)
		fDrawNewEllipsePanel()
	else
		DoWindow/F DrawNewEllipsePanel
	endif
end

Function mSelectEllipseAndDoSomething(theAction)
	variable theAction

	string graphName = WinName(0,1)
	if (strlen(graphName) == 0)
		DoAlert 0, "There are no graphs, so you can't edit an ellipse."
		return -1
	endif
	if (!DatafolderExists("root:Packages:WMDrawEllipse:"+graphName))
		DoAlert 0, "As far as I can tell, the top graph has no ellipses to edit."
		return -1
	endif

	Variable/G root:Packages:WMDrawEllipse:$(graphName):selectAction = theAction
	startIdentifyEllipses("")
end


static Function drawOvalInAxisCoordinates(semiMajor, semiMinor, centerX, centerY, axisAngle, ellipseName, graphName, drawIt, drawlayer, horizAxis, vertAxis, lineThickness)
	Variable semiMajor, semiMinor, centerX, centerY, axisAngle
	String ellipseName, graphName
	Variable drawIt
	String drawlayer, horizAxis, vertAxis
	Variable lineThickness
	
	String ellipseNameX = ellipseName+"_X"
	String ellipseNameY = ellipseName+"_Y"

	if ( (Exists(ellipseNameX) != 1) || (Exists(ellipseNameY) != 1) )
		Make/N=(ELLIPSE_NUM_POINTS)/O $ellipseNameX
		Make/N=(ELLIPSE_NUM_POINTS)/O $ellipseNameY
	endif
	Wave/Z ellipseX = $ellipseNameX
	Wave/Z ellipseY = $ellipseNameY

	Variable npnts = numpnts(ellipseX)
	Variable i
	Variable XFactor = 2*pi/(npnts-1)

	ellipseX = semiMajor*cos(p*XFactor)
	ellipseY = semiMinor*sin(p*XFactor)

	Variable saveX, saveY
	if (axisAngle != 0)
		Duplicate/O ellipseX, TWTempEllipseX
		Duplicate/O ellipseY, TWTempEllipseY
		ellipseX = TWTempEllipseX*cos(axisAngle) - TWTempEllipseY*sin(axisAngle)
		ellipseY = TWTempEllipseX*sin(axisAngle) + TWTempEllipseY*cos(axisAngle)
		KillWaves/Z TWTempEllipseX, TWTempEllipseY
	endif
	
	ellipseX += centerX
	ellipseY += centerY

	if (drawIt)
		SetDrawLayer/W=$graphName $drawlayer
		SetDrawEnv/W=$graphName xcoord = $horizAxis, ycoord = $vertAxis, fillpat = 0, linethick = lineThickNess
		DrawPoly/W=$graphName ellipseX[0], ellipseY[0], 1,1,ellipseX, ellipseY
	endif
end

static Function/S DrawEllipseOnGraph(graphName, ellipseName, semiMajor, semiMinor, centerX, centerY, axisAngle, horizAxis, vertAxis, layer)

	String graphName
	String ellipseName
	Variable semiMajor, semiMinor, centerX, centerY, axisAngle
	String horizAxis, vertAxis
	String layer

	if ( (strlen(graphName) == 0) || (WinType(graphName) != 1) )
		graphName = WinName(0, 1)
	endif
	
	String saveDF = GetDatafolder(1)
	
	NewDatafolder/O/S root:Packages
	NewDatafolder/O/S WMDrawEllipse
	NewDatafolder/O/S $graphName
	String/G EllipseList = StrVarOrDefault("EllipseList", "")
	if (FindListItem(ellipseName, EllipseList) < 0)
		EllipseList += ellipseName+";"
	endif
	NewDatafolder/O/S $ellipseName
	Variable tempNum
	semiMajor = abs(semiMajor)
	semiMinor = abs(semiMinor)
	if (semiMinor > semiMajor)
		tempNum = semiMajor
		semiMajor = semiMinor
		semiMinor = tempNum
		axisAngle += pi/2
	endif
	Variable/G GSemiMinor = semiMinor
	Variable/G GsemiMajor = semiMajor
	Variable/G GcenterX = centerX
	Variable/G GcenterY = centerY
	Variable/G GaxisAngle = axisAngle
	Variable focusDistance = sqrt(semiMajor^2 - semiMinor^2)
	Variable/G GFocus1X = centerX + focusDistance*cos(axisAngle)
	Variable/G GFocus1Y = centerY + focusDistance*sin(axisAngle)
	Variable/G GFocus2X = centerX - focusDistance*cos(axisAngle)
	Variable/G GFocus2Y = centerY - focusDistance*sin(axisAngle)
	String/G GHaxis = horizAxis
	String/G GVaxis = vertAxis
	String/G GDrawLayer = layer

	drawOvalInAxisCoordinates(GsemiMajor, GSemiMinor, GcenterX, GcenterY, GaxisAngle, ellipseName, graphName, 1, layer, GHaxis, GVaxis, 1)
	
	SetDatafolder $saveDF
	return ellipseName
end

Function redrawAllEllipses(graphName, exceptThisOne)
	String graphName
	String exceptThisOne	// name of an ellipse to NOT draw
	
	if ( (strlen(graphName) == 0) || (WinType(graphName) != 1) )
		graphName = WinName(0, 1)
	endif
	
	if (!DataFolderExists("root:Packages:WMDrawEllipse:"+graphName))
		return 0
	endif
	String saveDF = GetDatafolder(1)
	SetDatafolder root:Packages:WMDrawEllipse:$graphName
	
	SVAR/Z EllipseList
	if (!SVAR_Exists(EllipseList))
		DoAlert 0, "Someone's been tampering with my data!"
		return -1
	endif
	
//	SetDrawLayer/K/W=$graphName progback
//	GetDrawingCommandsForGraph(graphName)
	EraseAllDrawLayers(graphName)
	String oneEllipse
	String layer
	Variable i=0
	do
		oneEllipse = StringFromList(i, EllipseList)
		if (strlen(oneEllipse) == 0)
			break
		endif
		if (CmpStr(oneEllipse, exceptThisOne) == 0)
			i += 1
			continue
		endif
		if (DatafolderExists(oneEllipse))
			SetDatafolder $oneEllipse
			Wave/Z ex = $(oneEllipse+"_X")
			Wave/Z ey = $(oneEllipse+"_Y")
			SVAR GHaxis, GVaxis
			SVAR/Z GDrawLayer
			if (SVAR_Exists(GDrawLayer))
				layer = GDrawlayer
			else
				layer = "progback"
			endif
			NVAR GsemiMajor, GSemiMinor, GcenterX, GcenterY, GaxisAngle
			DrawEllipseOnGraph(graphName, oneEllipse, GsemiMajor, GSemiMinor, GcenterX, GcenterY, GaxisAngle, GHaxis, GVaxis, layer)
			SetDatafolder ::
			i += 1
		else
			EllipseList = RemoveListItem(i, EllipseList)
		endif
	while (1)
	
	SetDatafolder $saveDF
end

Function SaveDrawingCommandsForGraph(graphName)
	String graphName

	if ( (strlen(graphName) == 0) || (WinType(graphName) != 1) )
		graphName = WinName(0, 1)
	endif
	
	if (!DataFolderExists("root:Packages:WMDrawEllipse:"+graphName))
		return 0
	endif
	String saveDF = GetDatafolder(1)
	GetDrawingCommandsForGraph(graphName)
	SetDatafolder $saveDF
end

Function executeDrawingCommandsForGraph(graphName)
	String graphName
	
	if ( (strlen(graphName) == 0) || (WinType(graphName) != 1) )
		graphName = WinName(0, 1)
	endif
	
	if (!DataFolderExists("root:Packages:WMDrawEllipse:"+graphName))
		return 0
	endif

	Wave/T/Z EllipseWinRec = root:Packages:WMDrawEllipse:$(graphName):EllipseWinRec
	if (WaveExists(EllipseWinRec))
		executeDrawingCommandsFromWave(EllipseWinRec, graphName)
	endif
end

static Function DrawOneEllipseInTopLayer(graphName, EllipseName, eraseFirst, doBold)
	String graphName
	String EllipseName
	Variable eraseFirst, doBold

	if ( (strlen(graphName) == 0) || (WinType(graphName) != 1) )
		graphName = WinName(0, 1)
	endif
	
	if (!DataFolderExists("root:Packages:WMDrawEllipse:"+graphName))
		return 0
	endif
	String saveDF = GetDatafolder(1)
	SetDatafolder root:Packages:WMDrawEllipse:$graphName
	
	SVAR/Z EllipseList
	if (!SVAR_Exists(EllipseList))
		DoAlert 0, "Someone's been tampering with my data!"
		return -1
	endif

	if (!DatafolderExists(ellipseName))
		return -1
	endif
	SetDatafolder $ellipseName
	SVAR GHaxis, GVaxis
	NVAR GsemiMajor, GSemiMinor, GcenterX, GcenterY, GaxisAngle
	Variable lineThickness = doBold ? 3:1
	if (eraseFirst)
		SetDrawLayer/K progFront
	endif
	drawOvalInAxisCoordinates(GsemiMajor, GSemiMinor, GcenterX, GcenterY, GaxisAngle, EllipseName, graphName, 1, "progFront", GHaxis, GVaxis, lineThickness)
	
	SetDatafolder $saveDF
end

static Function DrawEditHandles(graphName,EllipseName, eraseFirst)
	String graphName
	String EllipseName
	Variable eraseFirst
	
	if ( (strlen(graphName) == 0) || (WinType(graphName) != 1) )
		graphName = WinName(0, 1)
	endif
	
	if (!DataFolderExists("root:Packages:WMDrawEllipse:"+graphName))
		return 0
	endif
	String saveDF = GetDatafolder(1)
	SetDatafolder root:Packages:WMDrawEllipse:$graphName
	
	SVAR/Z EllipseList
	if (!SVAR_Exists(EllipseList))
		DoAlert 0, "Someone's been tampering with my data!"
		return -1
	endif

	if (!DatafolderExists(ellipseName))
		return -1
	endif
	SetDatafolder $ellipseName
	
	NVAR GsemiMajor, GSemiMinor, GcenterX, GcenterY, GaxisAngle
	SVAR GHaxis, GVaxis
	
	GetAxis/Q/W=$graphName $GHaxis
	Variable startX = V_min
	Variable endX = V_max
	GetAxis/Q/W=$graphName $GVaxis
	Variable startY = V_min
	Variable endY = V_max
	GetWindow $graphName gsize
	Variable horizPoints = V_right - V_left
	Variable vertPoints = V_bottom - V_top
	Variable factorX, factorY
	PointsToAxisUnits(graphName, GHaxis, GVaxis, factorX, factorY)
	
	Variable bwidth = 5*factorX
	Variable bheight = 5*factorY
	
	if (eraseFirst)
		SetDrawLayer/K/W=$graphName progfront
	endif

	Variable majorHandlePlusX = GcenterX + GsemiMajor*cos(GaxisAngle)
	Variable majorHandlePlusY = GcenterY + GsemiMajor*sin(GaxisAngle)
	Variable majorHandleMinusX = GcenterX - GsemiMajor*cos(GaxisAngle)
	Variable majorHandleMinusY = GcenterY - GsemiMajor*sin(GaxisAngle)

	Variable minorHandlePlusX = GcenterX + GSemiMinor*cos(GaxisAngle + pi/2)
	Variable minorHandlePlusY = GcenterY + GSemiMinor*sin(GaxisAngle + pi/2)
	Variable minorHandleMinusX = GcenterX - GSemiMinor*cos(GaxisAngle + pi/2)
	Variable minorHandleMinusY = GcenterY - GSemiMinor*sin(GaxisAngle + pi/2)

	SetDrawEnv/W=$graphName xcoord = $GHaxis, ycoord = $GVaxis, fillfgc  = (0,0,0)
	DrawOval/W=$graphName minorHandlePlusX-bwidth, minorHandlePlusY-bheight, minorHandlePlusX+bwidth, minorHandlePlusY+bheight	
	SetDrawEnv/W=$graphName xcoord = $GHaxis, ycoord = $GVaxis, fillfgc  = (0,0,0)
	DrawOval/W=$graphName minorHandleMinusX-bwidth, minorHandleMinusY-bheight, minorHandleMinusX+bwidth, minorHandleMinusY+bheight	

	SetDrawEnv/W=$graphName xcoord = $GHaxis, ycoord = $GVaxis, fillfgc  = (0,0,0)
	DrawRect/W=$graphName majorHandlePlusX-bwidth, majorHandlePlusY-bheight, majorHandlePlusX+bwidth, majorHandlePlusY+bheight	
	SetDrawEnv/W=$graphName xcoord = $GHaxis, ycoord = $GVaxis, fillfgc  = (0,0,0)
	DrawRect/W=$graphName majorHandleMinusX-bwidth, majorHandleMinusY-bheight, majorHandleMinusX+bwidth, majorHandleMinusY+bheight	

	Variable/G GminorHandlePlusY = minorHandlePlusY
	Variable/G GminorHandlePlusX = minorHandlePlusX
	Variable/G GminorHandleMinusY = minorHandleMinusY
	Variable/G GminorHandleMinusX = minorHandleMinusX

	Variable/G GmajorHandlePlusY = majorHandlePlusY
	Variable/G GmajorHandlePlusX = majorHandlePlusX
	Variable/G GmajorHandleMinusY = majorHandleMinusY
	Variable/G GmajorHandleMinusX = majorHandleMinusX
	
	SetDatafolder ::
	String/G GEditEllipse = ellipseName
		
	SetDatafolder $saveDF
end

static Function startEditing(graphName, EllipseName, storeUndo)
	String graphName
	String EllipseName
	Variable storeUndo

	if ( (strlen(graphName) == 0) || (WinType(graphName) != 1) )
		graphName = WinName(0, 1)
	endif
	
	if (!DataFolderExists("root:Packages:WMDrawEllipse:"+graphName))
		return 0
	endif
	String saveDF = GetDatafolder(1)
	SetDatafolder root:Packages:WMDrawEllipse:$graphName
	
	if (!DatafolderExists(ellipseName))
		return -1
	endif
	Variable/G editAction = 0		// 1=move center; 2=change size; 3 = change rotation

	GetWindow $graphName hook
	String/G GOldHook = S_value
	String graphrec = WinRecreation(graphName, 0)
	Variable hookEventPos = strsearch(graphrec, "hookevents", 0)
	Variable/G GOldHookEvents = 0
	if (hookEventPos >= 0)
		GOldHookEvents = str2num(graphrec[hookEventPos+11, hookEventPos+12])
	endif

	if (storeUndo)
		StoreUndoInfo(graphName, EllipseName, EDIT_ELLIPSE_ACTION, 0)
	endif
	SetWindow $graphName hook=EditEllipseMouseHook,hookEvents = 3
	DoWindow/F $graphName

	SetDatafolder $saveDF	
end

static Function DrawHandlesAndEdit(graphName, EllipseName, storeUndo)
	String graphName
	String EllipseName
	Variable storeUndo

	DrawEditHandles(graphName, EllipseName, 1)
	startEditing(graphName, EllipseName, storeUndo)
end

static Function PointsToAxisUnits(graphName, haxis, vaxis, factorX, factorY)
	String  graphName, haxis, vaxis
	Variable &factorX
	Variable &factorY

	GetAxis/Q/W=$graphName $haxis
	Variable startX = V_min
	Variable endX = V_max
	GetAxis/Q/W=$graphName $vaxis
	Variable startY = V_min
	Variable endY = V_max
	GetWindow $graphName gsize
	Variable horizPoints = V_right - V_left
	Variable vertPoints = V_bottom - V_top
	factorX = (endX-startX)/horizPoints
	factorY = (endY-startY)/vertPoints
end

Function EditEllipseMouseHook(infoStr)
	String infoStr
	
	String graphName = StringByKey("WINDOW", infoStr)
	String saveDF = GetDatafolder(1)
	if (!DatafolderExists("root:Packages:WMDrawEllipse:"+graphName))
		return 0
	endif
	SetDatafolder root:Packages:WMDrawEllipse:$graphName
	SVAR GEditEllipse
	NVAR editAction
	SetDatafolder $GEditEllipse

	String event= StringByKey("EVENT",infoStr)
	Variable statusCode = 0
	Variable tempNumber
	Variable d1,d2
	Variable dmouseX, dmouseY
	Variable focusDistance, sinangle, cosangle
		
	NVAR GSemiMinor
	NVAR GsemiMajor
	NVAR GaxisAngle
	NVAR GcenterX
	NVAR GcenterY
	SVAR GHaxis, GVaxis

	NVAR GminorHandlePlusY
	NVAR GminorHandlePlusX
	NVAR GminorHandleMinusY
	NVAR GminorHandleMinusX

	NVAR GmajorHandlePlusY
	NVAR GmajorHandlePlusX
	NVAR GmajorHandleMinusY
	NVAR GmajorHandleMinusX

	// These are globals created during the editing process.
	// There is no way that they won't exist when they are used.
	// It says here in fine print...
	NVAR/Z GStartMouseX
	NVAR/Z GStartMouseY
	NVAR/Z originalGCenterX
	NVAR/Z originalGCenterY
	NVAR/Z GFocus1X
	NVAR/Z GFocus1Y
	NVAR/Z GFocus2X
	NVAR/Z GFocus2Y
				
	Variable mousex, mousey, rectslopX, rectslopY
	Variable Done = 0
	Variable factorX, factorY, leftmostX, topmostY
	PointsToAxisUnits(graphName, GHaxis, GVaxis, factorX, factorY)
	switch (editAction)
		case 0:				// not editing yet
			if (CmpStr(event, "mousedown") == 0)
				mousex = AxisValFromPixel(graphName, GHaxis, NumberByKey("MOUSEX", infoStr))
				mousey = AxisValFromPixel(graphName, GVaxis, NumberByKey("MOUSEY", infoStr))
				d1 = sqrt((mousex-GFocus1X)^2 + (mousey-GFocus1Y)^2)
				d2 = sqrt((mousex-GFocus2X)^2 + (mousey-GFocus2Y)^2)
				rectslopX = 5*factorX
				rectslopY =  5*factorY
				statusCode = 1
				if(withinBox(mousex, mousey, GmajorHandlePlusX, GmajorHandlePlusY, rectslopX, rectslopY) || withinBox(mousex, mousey, GmajorHandleMinusX, GmajorHandleMinusY, rectslopX, rectslopY) )
					editAction = 2
				elseif(withinBox(mousex, mousey, GminorHandlePlusX, GminorHandlePlusY, rectslopX, rectslopY) || withinBox(mousex, mousey, GminorHandleMinusX, GminorHandleMinusY, rectslopX, rectslopY) )
					editAction = 3
				elseif (d1+d2 < 2*GsemiMajor)
					editAction = 1
					Variable/G originalGCenterX = GCenterX
					Variable/G originalGCenterY = GCenterY
				else
					Done = 1
					editAction = 0
				endif
				Variable/G GStartMouseX = mousex
				Variable/G GStartMouseY = mousey
				if (editAction)
					redrawAllEllipses(graphName, GEditEllipse)
					DrawOneEllipseInTopLayer(graphName, GEditEllipse, 1, 0)
					DrawEditHandles(graphName, GEditEllipse, 0)
				endif
			elseif(CmpStr(event, "mousemoved") == 0)
				mousex = AxisValFromPixel(graphName, GHaxis, NumberByKey("MOUSEX", infoStr))
				mousey = AxisValFromPixel(graphName, GVaxis, NumberByKey("MOUSEY", infoStr))
				d1 = sqrt((mousex-GFocus1X)^2 + (mousey-GFocus1Y)^2)
				d2 = sqrt((mousex-GFocus2X)^2 + (mousey-GFocus2Y)^2)
				rectslopX = 5*factorX
				rectslopY =  5*factorY
				if(withinBox(mousex, mousey, GmajorHandlePlusX, GmajorHandlePlusY, rectslopX, rectslopY) || withinBox(mousex, mousey, GmajorHandleMinusX, GmajorHandleMinusY, rectslopX, rectslopY) )
					SetWindow $graphName, hookcursor=28
				elseif(withinBox(mousex, mousey, GminorHandlePlusX, GminorHandlePlusY, rectslopX, rectslopY) || withinBox(mousex, mousey, GminorHandleMinusX, GminorHandleMinusY, rectslopX, rectslopY) )
					variable reverse = 0
					GetAxis/W=$graphName/Q $GVaxis
					if (V_min > V_max)
						reverse = !reverse
					endif
					GetAxis/W=$graphName/Q $GHaxis
					if (V_min > V_max)
						reverse = !reverse
					endif
					variable alpha = GaxisAngle
					if ( (alpha>-0.125*pi) && (alpha<0.125*pi) )
						SetWindow $graphName, hookcursor=30
					elseif( (alpha>0.125*pi) && (alpha<0.375*pi) )
						SetWindow $graphName, hookcursor= (reverse? 32:31)
					elseif( (alpha>0.375*pi) && (alpha<0.625*pi) )
						SetWindow $graphName, hookcursor=29
					elseif( (alpha>0.625*pi) && (alpha<0.875*pi) )
						SetWindow $graphName, hookcursor=(reverse? 31:32)
					elseif( alpha > 0.875*pi)
						SetWindow $graphName, hookcursor=30
					elseif( (alpha<-0.125*pi) && (alpha>-0.375*pi) )
						SetWindow $graphName, hookcursor=(reverse? 31:32)
					elseif( (alpha<-0.375*pi) && (alpha>-0.625*pi) )
						SetWindow $graphName, hookcursor=29
					elseif( (alpha<-0.625*pi) && (alpha>-0.875*pi) )
						SetWindow $graphName, hookcursor=(reverse? 32:31)
					elseif( alpha < -0.875*pi)
						SetWindow $graphName, hookcursor=30
					endif
				elseif (d1+d2 < 2*GsemiMajor)
					SetWindow $graphName, hookcursor=13
				else
					SetWindow $graphName, hookcursor=3
				endif				
			endif
			break
		case 1:				// move center
			strswitch(event)
				case "mouseup":
					editAction = 0
				case "mousemoved":
					mousex = AxisValFromPixel(graphName, GHaxis, NumberByKey("MOUSEX", infoStr))
					mousey = AxisValFromPixel(graphName, GVaxis, NumberByKey("MOUSEY", infoStr))
					dmouseX = mousex - GStartMouseX
					dmouseY = mousey - GStartMouseY
					GcenterX = originalGCenterX + dmouseX
					GcenterY = originalGCenterY + dmouseY
					if (editAction == 0)
						sinangle = sin(GaxisAngle)
						cosangle = cos(GaxisAngle)
						focusDistance = sqrt(GsemiMajor^2 - GsemiMinor^2)
						GFocus1X = GcenterX + focusDistance*cosangle
						GFocus1Y = GcenterY + focusDistance*sinangle
						GFocus2X = GcenterX - focusDistance*cosangle
						GFocus2Y = GcenterY - focusDistance*sinangle
					endif
					DrawOneEllipseInTopLayer(graphName, GEditEllipse, 1, 0)
					DrawEditHandles(graphName, GEditEllipse, 0)
					statusCode = 1
					break;
			endswitch
			break
		case 2:				// change semi-Major axis and angle
			strswitch(event)
				case "mouseup":
					editAction = 0
				case "mousemoved":
					mousex = AxisValFromPixel(graphName, GHaxis, NumberByKey("MOUSEX", infoStr))
					mousey = AxisValFromPixel(graphName, GVaxis, NumberByKey("MOUSEY", infoStr))
					GaxisAngle = atan2(mousey-GcenterY, mousex-GcenterX)
					GsemiMajor = sqrt((mousey-GcenterY)^2 + (mousex-GcenterX)^2) 
					statusCode = 1
					if (editAction == 0)
						if (GSemiMinor > GsemiMajor)
							tempNumber = GSemiMinor
							GSemiMinor = GsemiMajor
							GsemiMajor = tempNumber
							GaxisAngle += pi/2
						endif
						sinangle = sin(GaxisAngle)
						cosangle = cos(GaxisAngle)
						focusDistance = sqrt(GsemiMajor^2 - GsemiMinor^2)
						GFocus1X = GcenterX + focusDistance*cosangle
						GFocus1Y = GcenterY + focusDistance*sinangle
						GFocus2X = GcenterX - focusDistance*cosangle
						GFocus2Y = GcenterY - focusDistance*sinangle
					endif
					DrawOneEllipseInTopLayer(graphName, GEditEllipse, 1, 0)
					DrawEditHandles(graphName, GEditEllipse, 0)
					break;
			endswitch
			break
		case 3:				// change semi-minor axis
			strswitch(event)
				case "mouseup":
					editAction = 0
				case "mousemoved":
					mousex = AxisValFromPixel(graphName, GHaxis, NumberByKey("MOUSEX", infoStr))
					mousey = AxisValFromPixel(graphName, GVaxis, NumberByKey("MOUSEY", infoStr))
					Variable theAngle = GaxisAngle - atan2(mousey-GcenterY, mousex-GcenterX)
					Variable length = sqrt((mousey-GcenterY)^2 + (mousex-GcenterX)^2)
					GSemiMinor = length*sin(theAngle)
					DrawOneEllipseInTopLayer(graphName, GEditEllipse, 1, 0)
					DrawEditHandles(graphName, GEditEllipse, 0)
					statusCode = 1
					if (editAction == 0)
						if (GSemiMinor > GsemiMajor)
							tempNumber = GSemiMinor
							GSemiMinor = GsemiMajor
							GsemiMajor = tempNumber
							GaxisAngle += pi/2
						endif
						sinangle = sin(GaxisAngle)
						cosangle = cos(GaxisAngle)
						focusDistance = sqrt(GsemiMajor^2 - GsemiMinor^2)
						GFocus1X = GcenterX + focusDistance*cosangle
						GFocus1Y = GcenterY + focusDistance*sinangle
						GFocus2X = GcenterX - focusDistance*cosangle
						GFocus2Y = GcenterY - focusDistance*sinangle
					endif
					break;
			endswitch
			break
	endswitch
	
	if (Done || (CmpStr(event, "Deactivate") == 0) )
		HideOrShowAllAnnotations(graphName, 1)
		SetDrawLayer/K progback
		redrawAllEllipses(graphName, "")
		executeDrawingCommandsForGraph(graphName)
		KillVariables/Z GStartMouseX, GStartMouseY, editAction
		SetDatafolder ::
		SVAR GOldHook
		NVAR GOldHookEvents
		SetWindow $graphName, hook=$GOldHook, hookEvents=(GOldHookEvents)
		KillVariables/Z GOldHookEvents
		KillStrings/Z GOldHook, GEditEllipse
//		SetDrawLayer/K progfront
	endif

	SetDatafolder $saveDF
	return statusCode				// 0 if nothing done, else 1 or 2
End

static Function withinRect(pntX, pntY, rectLeft, rectTop, rectRight, rectBottom)
	Variable pntX, pntY, rectLeft, rectTop, rectRight, rectBottom
	
	Variable temp
	if (rectLeft > rectRight)
		temp = rectLeft
		rectLeft = rectRight
		rectRight = temp
	endif
	if (rectBottom > rectTop)
		temp = rectBottom
		rectBottom = rectTop
		rectTop = temp
	endif
	Variable returnValue = 0
	if ( (pntX > rectLeft) && (pntX < rectRight) )
		if ( (pntY > rectBottom) && (pntY < rectTop) )
			returnValue = 1
		endif
	endif
	
	return returnValue
end

static Function withinBox(pntX, pntY, boxCenterX, boxCenterY, boxHalfWidthX, boxHalfWidthY)
	Variable pntX, pntY, boxCenterX, boxCenterY, boxHalfWidthX, boxHalfWidthY
	
	Variable left = boxCenterX-boxHalfWidthX
	Variable right = boxCenterX+boxHalfWidthX
	Variable top = boxCenterY-boxHalfWidthY
	Variable bottom = boxCenterY+boxHalfWidthY
	
	return withinRect(pntX, pntY, left, top, right, bottom)
end

static Function/S nameForEllipse(ellipseIndex)
	Variable ellipseIndex
	
	return "Ellipse"+num2istr(ellipseIndex)
end

static Function StartDrawingNewEllipse(GraphName, haxis, vaxis, layer)
	String GraphName, haxis, vaxis, layer
	
	if ( (strlen(graphName) == 0) || (WinType(graphName) != 1) )
		graphName = WinName(0, 1)
	endif
	
	String saveDF = GetDatafolder(1)
	
	NewDatafolder/O/S root:Packages
	NewDatafolder/O/S WMDrawEllipse
	NewDatafolder/O/S $graphName
	
	SVAR/Z EllipseList
	Variable/G newEllipseIndex = 0
	String eName
	if (SVAR_Exists(EllipseList))
		eName = "Ellipse"+num2istr(newEllipseIndex)
		if (WhichListItem(eName , EllipseList) >= 0)
			do
				newEllipseIndex += 1
				eName = "Ellipse"+num2istr(newEllipseIndex)
			while (WhichListItem(eName , EllipseList) >= 0)
		endif
	endif
	Variable/G firstClickX = 0, firstClickY = 0
	Variable/G secondClickX = 0, secondClickY = 0
	Variable/G thirdClickX = 0, thirdClickY = 0
	Variable/G whichClick = 0
	String/G newEllipseHAxis = haxis
	String/G newEllipseVAxis = vaxis
	String/G GDrawLayer = layer
	
	GetWindow $graphName hook
	String/G GOldHook = S_value
	String graphrec = WinRecreation(graphName, 0)
	Variable hookEventPos = strsearch(graphrec, "hookevents", 0)
	Variable/G GOldHookEvents = 0
	if (hookEventPos >= 0)
		GOldHookEvents = str2num(graphrec[hookEventPos+11, hookEventPos+12])
	endif

	SetWindow $graphName hook=NewEllipseHook,hookEvents = 1
	DoWindow/F $graphName
	HideOrShowAllAnnotations(graphName, 0)
	SaveDrawingCommandsForGraph(graphName)

	SetDatafolder $saveDF
end

Function NewEllipseHook (infoStr)
	String infoStr
	
	String graphName = StringByKey("WINDOW", infoStr)
	String saveDF = GetDatafolder(1)
	if (!DatafolderExists("root:Packages:WMDrawEllipse:"+graphName))
		return 0
	endif
	SetDatafolder root:Packages:WMDrawEllipse:$graphName
	NVAR/Z whichClick
	SVAR newEllipseHAxis
	SVAR newEllipseVAxis
	
	String event= StringByKey("EVENT",infoStr)
	if (CmpStr(event, "mousedown") == 0)
		switch (whichClick)
			case 0:
				whichClick += 1
				NVAR firstClickX, firstClickY
				Variable rawClickX = NumberByKey("MOUSEX", infoStr)
				Variable rawClickY = NumberByKey("MOUSEY", infoStr)
				firstClickX = AxisValFromPixel(graphName, newEllipseHAxis, rawClickX)
				firstClickY = AxisValFromPixel(graphName, newEllipseVAxis, rawClickY)
				SetDrawLayer/K/W=$graphName progfront
				SetDrawEnv/W=$graphName xcoord = $newEllipseHAxis, ycoord = $newEllipseVAxis, fillfgc  = (0,0,0)
				Variable left = AxisValFromPixel(graphName, newEllipseHAxis, rawClickX-3)
				Variable right = AxisValFromPixel(graphName, newEllipseHAxis, rawClickX+3)
				Variable top = AxisValFromPixel(graphName, newEllipseVAxis, rawClickY-3)
				Variable bottom = AxisValFromPixel(graphName, newEllipseVAxis, rawClickY+3)
				DrawRect /W=$graphName left, top, right, bottom
				break
			case 1:
				whichClick += 1
				NVAR firstClickX, firstClickY
				NVAR secondClickX, secondClickY
				secondClickX = AxisValFromPixel(graphName, newEllipseHAxis, NumberByKey("MOUSEX", infoStr))
				secondClickY = AxisValFromPixel(graphName, newEllipseVAxis, NumberByKey("MOUSEY", infoStr))
				SetDrawLayer/K/W=$graphName progfront
				SetDrawEnv/W=$graphName xcoord = $newEllipseHAxis, ycoord = $newEllipseVAxis, fillfgc  = (0,0,0)
				DrawLine /W=$graphName firstClickX, firstClickY, secondClickX, secondClickY
				break
			case 2:
				whichClick += 1
				NVAR firstClickX, firstClickY
				NVAR secondClickX, secondClickY
				NVAR thirdClickX, thirdClickY, newEllipseIndex
				thirdClickX = AxisValFromPixel(graphName, newEllipseHAxis, NumberByKey("MOUSEX", infoStr))
				thirdClickY = AxisValFromPixel(graphName, newEllipseVAxis, NumberByKey("MOUSEY", infoStr))
				Variable semiMajor = sqrt( (secondClicky - firstClicky)^2 + (secondClickX - firstClickX)^2)/2
				Variable axisAngle = atan2(secondClicky - firstClicky, secondClickX - firstClickX)
				Variable alpha2 = atan2(thirdClicky - firstClicky, thirdClickX - firstClickX)
				Variable semiMinor = sqrt((thirdClicky - firstClicky)^2+(thirdClickX - firstClickX)^2)*sin(axisAngle-alpha2)
//				SetDrawLayer/K/W=$graphName progfront
				Variable centerX = (firstClickX+secondClickX)/2
				Variable centerY = (firstClickY+secondClickY)/2
				SVAR GDrawLayer
				String  eName = DrawEllipseOnGraph(graphName, nameForEllipse(newEllipseIndex), semiMajor, semiMinor, centerX, centerY, axisAngle, newEllipseHAxis, newEllipseVAxis, GDrawLayer)
				SVAR GOldHook
				NVAR GOldHookEvents
				SetWindow $graphName, hook=$GOldHook, hookEvents=(GOldHookEvents)
				KillVariables/Z firstClickX, firstClickY,secondClickX, secondClickY, thirdClickX, thirdClickY, newEllipseIndex,whichClick, GOldHookEvents
				KillStrings/Z GOldHook, newEllipseHAxis, newEllipseVAxis

				StoreUndoInfo(graphName, eName, DRAW_ELLIPSE_ACTION, 0)
				DrawHandlesAndEdit(graphName, eName, 0)
				break
		endswitch
	elseif(CmpStr(event, "deactivate") == 0)
//		SetDrawLayer/W=$graphName/K progFront
		redrawAllEllipses(graphName, "")
		executeDrawingCommandsForGraph(graphName)
		SVAR GOldHook
		NVAR GOldHookEvents
		SetWindow $graphName, hook=$GOldHook, hookEvents=(GOldHookEvents)
		KillVariables/Z firstClickX, firstClickY,secondClickX, secondClickY, thirdClickX, thirdClickY, newEllipseIndex,whichClick, GOldHookEvents
		KillStrings/Z GOldHook, newEllipseHAxis, newEllipseVAxis
		HideOrShowAllAnnotations(graphName, 1)
	endif

	SetDatafolder $saveDF
	return 1
end

static Function eraseElipse(graphName, ellipseName)
	String graphName
	String ellipseName

	if ( (strlen(graphName) == 0) || (WinType(graphName) != 1) )
		graphName = WinName(0, 1)
	endif
	
	if (!DataFolderExists("root:Packages:WMDrawEllipse:"+graphName))
		return 0
	endif
	String saveDF = GetDatafolder(1)
	SetDatafolder root:Packages:WMDrawEllipse:$graphName
	
	if (!DatafolderExists(ellipseName))
		return -1
	endif

	SaveDrawingCommandsForGraph(graphName)
	SVAR ellipseList
	ellipseList = RemoveFromList(ellipseName, ellipseList)
	KillDatafolder $ellipseName
	redrawAllEllipses(graphName, "")
	executeDrawingCommandsForGraph(graphName)
	
	if (DatafolderExists(saveDF))
		SetDatafolder $saveDF
	endif
end

static Function startIdentifyEllipses(graphName)
	String graphName
	
	if ( (strlen(graphName) == 0) || (WinType(graphName) != 1) )
		graphName = WinName(0, 1)
	endif
	
	if (!DataFolderExists("root:Packages:WMDrawEllipse:"+graphName))
		return 0
	endif
	String saveDF = GetDatafolder(1)
	SetDatafolder root:Packages:WMDrawEllipse:$graphName

	GetWindow $graphName hook
	String/G GOldHook = S_value
	String graphrec = WinRecreation(graphName, 0)
	Variable hookEventPos = strsearch(graphrec, "hookevents", 0)
	Variable/G GOldHookEvents = 0
	if (hookEventPos >= 0)
		GOldHookEvents = str2num(graphrec[hookEventPos+11, hookEventPos+12])
	endif

	SaveDrawingCommandsForGraph(graphName)
	SetWindow $graphName hook=IdentifyEllipseHook,hookEvents = 3
	DoWindow/F $graphName
	HideOrShowAllAnnotations(graphName, 0)
	
	SetDatafolder $saveDF
end

Function IdentifyEllipseHook(infoStr)
	String infoStr
		
	String graphName = StringByKey("WINDOW", infoStr)
	String event= StringByKey("EVENT",infoStr)
	String mouseEName
	SVAR/Z lastEName = root:Packages:WMDrawEllipse:lastEName
	String saveDF
	
	Variable drawName = 0
	Variable rawMouseX, rawMouseY
	
	if (CmpStr(event, "mousemoved") == 0)
		rawMouseX = NumberByKey("MOUSEX", infoStr)
		rawMouseY = NumberByKey("MOUSEY", infoStr)
		mouseEName = mouseEllipseName(graphName, rawMouseX, rawMouseY)
		if (SVAR_Exists(lastEName))
			drawName = (strlen(mouseEName) > 0)
			if ( (strlen(mouseEName) == 0) && (strlen(lastEName)>0) )
				SetDrawLayer/W=$graphName/K  progFront					
			endif
		else
			drawName = 0
			String/G root:Packages:WMDrawEllipse:lastEName = ""
		endif
		if (drawName)
			saveDF = GetDatafolder(1)
			SetDatafolder root:Packages:WMDrawEllipse:$(graphName):$(mouseEName)
			String/G root:Packages:WMDrawEllipse:lastEName = mouseEName

			SVAR GHaxis, GVaxis
			NVAR GCenterX, GCenterY
			SetDrawLayer/W=$graphName/K  progFront
			Variable screenFactor = 72/screenResolution
			SetDrawEnv/W=$graphName xcoord=abs, ycoord=abs, textxjust=1, textyjust=1
			DrawText/W=$graphName rawMouseX*screenFactor, rawMouseY*screenFactor, mouseEName
			
			DrawOneEllipseInTopLayer(graphName, mouseEName, 0, 1)
			
			SetDatafolder $saveDF
		endif
		return 1
	elseif (CmpStr(event, "mousedown") == 0)
		saveDF = GetDatafolder(1)
		SetDatafolder root:Packages:WMDrawEllipse:$graphName

		SVAR/Z GOldHook
		NVAR/Z GOldHookEvents
		if (SVAR_Exists(GOldHook) && NVAR_Exists(GOldHookEvents))
			SetWindow $graphName, hook=$GOldHook, hookEvents=(GOldHookEvents)
		endif

		SetDrawLayer/W=$graphName/K  progFront
		
		rawMouseX = NumberByKey("MOUSEX", infoStr)
		rawMouseY = NumberByKey("MOUSEY", infoStr)
		mouseEName = mouseEllipseName(graphName, rawMouseX, rawMouseY)
		if (strlen(mouseEName) > 0)
			NVAR selectAction = root:Packages:WMDrawEllipse:$(graphName):selectAction
			switch (selectAction)
				case EDIT_ELLIPSE_ACTION:
					DrawHandlesAndEdit(graphName, mouseEName, 1)
					break
				case ERASE_ELLIPSE_ACTION:
					StoreUndoInfo(graphName, mouseEName, ERASE_ELLIPSE_ACTION, 0)
					eraseElipse(graphName, mouseEName)
					HideOrShowAllAnnotations(graphName, 1)
					break
				case MOVE_ELLIPSE_LAYER_ACTION:
					ChangeEllipseLayer(graphName, mouseEName)
					break
			endswitch
		else		// no selection made
			HideOrShowAllAnnotations(graphName, 1)
		endif
		
		if (DatafolderExists(saveDF))
			SetDatafolder $saveDF
		endif
	elseif (CmpStr(event, "Deactivate") == 0)
		saveDF = GetDatafolder(1)
		SetDatafolder root:Packages:WMDrawEllipse:$graphName

		SVAR/Z GOldHook
		NVAR/Z GOldHookEvents
		if (SVAR_Exists(GOldHook) && NVAR_Exists(GOldHookEvents))
			SetWindow $graphName, hook=$GOldHook, hookEvents=(GOldHookEvents)
		endif

		SetDrawLayer/W=$graphName/K  progFront
		HideOrShowAllAnnotations(graphName, 1)
		redrawAllEllipses(graphName, "")
		executeDrawingCommandsForGraph(graphName)
	endif
end

static Function/S mouseEllipseName(graphName, rawMouseX, rawMouseY)
	String graphName
	Variable rawMouseX, rawMouseY
	
	string returnValue = ""
	
	if ( (strlen(graphName) == 0) || (WinType(graphName) != 1) )
		graphName = WinName(0, 1)
	endif
	
	if (!DataFolderExists("root:Packages:WMDrawEllipse:"+graphName))
		return ""
	endif
	String saveDF = GetDatafolder(1)
	SetDatafolder root:Packages:WMDrawEllipse:$graphName

	SVAR EllipseList	
	String oneEllipse
	Variable numEllipses = ItemsInList(EllipseList)
	Variable i=numEllipses-1
	do
		oneEllipse = StringFromList(i, EllipseList)
		if (strlen(oneEllipse) == 0)
			break
		endif
		SetDatafolder $oneEllipse

		SVAR GHaxis, GVaxis
		NVAR GsemiMajor, GSemiMinor, GcenterX, GcenterY, GaxisAngle
		Variable mousex = AxisValFromPixel(graphName, GHaxis, rawMouseX)
		Variable mousey = AxisValFromPixel(graphName, GVaxis, rawMouseY)
		if (PointIsInEllipse(mousex, mousey, GcenterX, GcenterY, GsemiMinor, GsemiMajor, GaxisAngle))
			returnValue = oneEllipse
			break
		endif
		SetDatafolder ::
		i -= 1
	while (i >= 0)
	
	SetDatafolder $saveDF
	return returnValue
end

static Function PointIsInEllipse(pntX, pntY, centerX, centerY, semiMinor, semiMajor, axisAngle)
	Variable pntX, pntY, centerX, centerY, semiMinor, semiMajor, axisAngle
	
	Variable sinangle = sin(axisAngle)
	Variable cosangle = cos(axisAngle)
	Variable focusDistance = sqrt(semiMajor^2 - semiMinor^2)
	Variable Focus1X = centerX + focusDistance*cosangle
	Variable Focus1Y = centerY + focusDistance*sinangle
	Variable Focus2X = centerX - focusDistance*cosangle
	Variable Focus2Y = centerY - focusDistance*sinangle
	Variable d1 = sqrt((pntX-Focus1X)^2 + (pntY-Focus1Y)^2)
	Variable d2 = sqrt((pntX-Focus2X)^2 + (pntY-Focus2Y)^2)
	if (d1+d2 < 2*semiMajor)
		return 1
	else
		return 0
	endif
end

Function HideOrShowAllAnnotations(graphName, showThem)
	String graphName
	Variable showThem
	
	if ( (strlen(graphName) == 0))
		graphName = WinName(0, 1)
	endif

	String AnnoList = AnnotationList(graphName)
	String annoName,theType,cmd
	Variable i, numAnnos = ItemsInList(AnnoList)
	for (i = 0; i < numAnnos; i += 1)
		annoName = StringFromList(i, AnnoList)
		theType=StringByKey("TYPE",AnnotationInfo(graphName,annoName))
		cmd=theType+"/W="+graphName+"/C/N="+annoName+"/V="+num2istr(showThem)
		Execute cmd
//		TextBox/C/N=$annoName/V=(showThem)
	endfor
end	

Function GetDrawingCommandsForGraph(graphName)
	String graphName
	
	if ( (strlen(graphName) == 0))
		graphName = WinName(0, 1)
	endif

	String recMacro = WinRecreation(graphName, 0)
	Variable charPos1, charPos2, lastCharPos
	charPos1 = strsearch(recMacro, "SetDrawLayer", 0)
	if (charPos1 < 0)
		return 0
	endif
	Make/N=0/T/O EllipseWinRec
	Variable wavepoint = 0
	String dum1, dum2
	Variable drawEllipsePos, spacePos
	do
		charPos2 = strsearch(recMacro, "\r", charPos1)
		drawEllipsePos = strsearch(recMacro, "WMDrawEllipse", charPos1)
		if ( (drawEllipsePos < 0) || (drawEllipsePos > charPos2) )	// the current line does not contain an ellipse-drawing command; put it into the text wave
			spacePos = strsearch(recMacro, " ", charPos1)-1
			if (isDrawingCommand(recMacro[charPos1, spacePos]) )
				InsertPoints wavepoint, 1, EllipseWinRec
				EllipseWinRec[wavepoint] = recMacro[charPos1, charPos2]
				wavepoint += 1
			endif
		else		// the current line contains an ellipse drawing command; that means we have just inserted a SetDrawEnv command related to drawing an ellipse
				// which was the command immediately preceding the current line. We must now delete that command
			wavePoint -= 1
			DeletePoints wavePoint, 1, EllipseWinRec
		endif
		charPos1 = strsearch(recMacro, "\t", charPos2)+1
		if (charPos1 <= 0)
			break
		endif
	while(1)
end

static Function isDrawingCommand(cmd)
	String cmd
	
	strswitch(cmd)
		case "SetDrawLayer":
		case "SetDrawEnv":
		case "DrawLine":
		case "DrawOval":
		case "DrawRect":
		case "DrawRRect":
		case "DrawText":
		case "DrawPoly":
			return 1
		default:
			return 0
	endswitch
end

Function executeDrawingCommandsFromWave(theWave, graphName)
	Wave/T theWave
	String graphName
	
	Variable npnts = numpnts(theWave)
	Variable i
	String rawCmd
	String theCommand
	Variable spacePos, rawLength
	for (i = 0; i < npnts; i += 1)
		rawCmd = theWave[i]
		rawLength = strlen(rawCmd)-1
		spacePos = strsearch(rawCmd, " ", 0)
		theCommand = rawCmd[0,spacePos-1]
		if (!IsDrawingCommand(theCommand))
			continue
		endif
		theCommand += "/W="+graphName
		theCommand += rawCmd[spacePos, rawLength]
		Execute theCommand
	endfor
end

Function EraseAllDrawLayers(graphName)
	String graphName
	
	if ( (strlen(graphName) == 0))
		graphName = WinName(0, 1)
	endif

	SetDrawLayer/W=$graphName /K progback
	SetDrawLayer/W=$graphName /K userback
	SetDrawLayer/W=$graphName /K progaxes
	SetDrawLayer/W=$graphName /K useraxes
	SetDrawLayer/W=$graphName /K progfront
	SetDrawLayer/W=$graphName /K userfront		
end

Function ChangeEllipseLayer(graphName, ellipseName)
	String graphName, ellipseName

	if ( (strlen(graphName) == 0) || (WinType(graphName) != 1) )
		graphName = WinName(0, 1)
	endif
	
	if (!DataFolderExists("root:Packages:WMDrawEllipse:"+graphName+":"+ellipseName))
		return -1
	endif
	
	String  SaveDF = GetDatafolder(1)
	SetDatafolder root:Packages:WMDrawEllipse:$(graphName):$(ellipseName)
	
	fChangeEllipseLayerPanel(graphName, ellipseName)
	DoUpdate
	PauseForUser ChangeEllipseLayerPanel
	
	SaveDrawingCommandsForGraph(graphName)
	redrawAllEllipses(graphName, "")
	executeDrawingCommandsForGraph(graphName)
	
	SetDatafolder $saveDF
end

// This panel and associate functions expect the current datafolder to be the one for the ellipse to be changed.
Function fChangeEllipseLayerPanel(graphName, ellipseName)
	String graphName, ellipseName

	SVAR/Z GDrawLayer
	if (!SVAR_Exists(GDrawLayer))
		return -1
	endif
	
	NewPanel /W=(24,54,259,167) as "Change Ellipse Draw Layer"
	DoWindow/C ChangeEllipseLayerPanel
	PopupMenu DrawEllipseLayerMenu,pos={24,21},size={176,20},title="New Draw layer:"
	PopupMenu DrawEllipseLayerMenu,mode=2,popvalue="UserFront",value= #"\"\\M1(annotations;UserFront;ProgFront;\\M1(traces;UserAxes;ProgAxes;\\M1(axes;\\M1(Images;UserBack;ProgBack;\\M1(Window Background;\""
	Button DoItButton,pos={18,62},size={72,20},proc=ChangeEllipseLayerButtonProc,title="Do It"
	Button CancelButton,pos={135,62},size={72,20},proc=CancelEllipseLayerButtonProc,title="Cancel"
end

Function ChangeEllipseLayerButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	ControlInfo DrawEllipseLayerMenu
	String newDrawLayer = S_value
	SVAR/Z GDrawLayer
	if (SVAR_Exists(GDrawLayer))
		GDrawLayer = newDrawLayer
	endif

	DoWindow/K ChangeEllipseLayerPanel
end

Function CancelEllipseLayerButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/K ChangeEllipseLayerPanel
end

//************************
// Stuff for an UNDO function
//************************

static Function StoreUndoInfo(graphName, ellipse_Name, action, doTempFolder)
	String  graphName, ellipse_Name
	Variable action, doTempFolder
	
	if ( (strlen(graphName) == 0))
		graphName = WinName(0, 1)
	endif
	
	if (!DataFolderExists("root:Packages:WMDrawEllipse:"+graphName+":"+ellipse_Name))
		return 0
	endif
	String saveDF = GetDatafolder(1)
	SetDatafolder root:Packages:WMDrawEllipse:$(graphName):$(ellipse_Name)
	
	NVAR/Z GSemiMinor
	NVAR/Z GsemiMajor
	NVAR/Z GaxisAngle
	NVAR/Z GcenterX
	NVAR/Z GcenterY
	SVAR/Z GHaxis, GVaxis
	SVAR/Z GDrawLayer

	if (doTempFolder)
		NewDatafolder/O/S root:Packages:WMDrawEllipse:$(graphName):TempUndoInfo
	else
		NewDatafolder/O/S root:Packages:WMDrawEllipse:$(graphName):UndoInfo
	endif
	String/G GUndoEllipseName = ellipse_Name
	Variable/G GUndoAction = action
	String/G GUndoGHaxis = GHaxis
	String/G GUndoGVaxis = GVaxis
	Variable/G GUndoSemiMinor = GSemiMinor
	Variable/G GUndoSemiMajor = GSemiMajor
	Variable/G GUndoAxisAngle = GaxisAngle
	Variable/G GUndocenterX = GcenterX
	Variable/G GUndocenterY = GcenterY
	String/G GUndoDrawLayer = GDrawLayer
	
	BuildMenu "Graph"
	SetDatafolder $saveDF
end

Function UndoLastEllipseAction(graphName)
	String  graphName
	
	if ( (strlen(graphName) == 0))
		graphName = WinName(0, 1)
	endif
	
	if (!DataFolderExists("root:Packages:WMDrawEllipse:"+graphName))
		return 0
	endif
	String saveDF = GetDatafolder(1)
	SetDatafolder root:Packages:WMDrawEllipse:$(graphName):UndoInfo

	SVAR/Z GUndoEllipseName
	SVAR/Z GUndoDrawLayer
	NVAR/Z GUndoAction
	SVAR/Z GUndoGHaxis
	SVAR/Z GUndoGVaxis
	NVAR/Z GUndoSemiMinor
	NVAR/Z GUndoSemiMajor
	NVAR/Z GUndoAxisAngle
	NVAR/Z GUndocenterX
	NVAR/Z GUndocenterY
	
	Variable killUndoFolder = 0
	string eName
	
	switch (GUndoAction)
		case EDIT_ELLIPSE_ACTION:			// last action was editing; simply restore the saved parameters
			if (!DataFolderExists("root:Packages:WMDrawEllipse:"+graphName+":"+GUndoEllipseName))
				DoAlert 0, "Can't undo last ellipse edit: it appears that the ellipse no longer exists."
				break
			endif
			SetDatafolder root:Packages:WMDrawEllipse:$(graphName):$(GUndoEllipseName)
			StoreUndoInfo(graphName, GUndoEllipseName, EDIT_ELLIPSE_ACTION, 1)
			String/G GHaxis = GUndoGHaxis
			String/G GVaxis = GUndoGVaxis
			Variable/G GSemiMinor = GUndoSemiMinor
			Variable/G GaxisAngle = GUndoAxisAngle
			Variable/G GcenterX = GUndocenterX
			Variable/G GcenterY = GUndocenterY
			KillDatafolder root:Packages:WMDrawEllipse:$(graphName):UndoInfo
			RenameDatafolder root:Packages:WMDrawEllipse:$(graphName):TempUndoInfo, UndoInfo
			SaveDrawingCommandsForGraph(graphName)
			redrawAllEllipses(graphName, "")
			executeDrawingCommandsForGraph(graphName)
			break
		case ERASE_ELLIPSE_ACTION:		// last action was erase; look up the saved info and draw a new ellipse to replace the old one
			if (DataFolderExists("root:Packages:WMDrawEllipse:"+graphName+":"+GUndoEllipseName))
				DoAlert 0, "Undo information says the ellipse was erased, but its datafolder still exists. I will try re-drawing it."
				SetDatafolder root:Packages:WMDrawEllipse:$(graphName):$(GUndoEllipseName)
				killUndoFolder = 1
			else
				NewDatafolder/O/S root:Packages:WMDrawEllipse:$(graphName):$(GUndoEllipseName)
				killUndoFolder = 0
			endif
			DrawEllipseOnGraph(graphName, GUndoEllipseName, GUndoSemiMajor, GUndoSemiMinor, GUndocenterX, GUndocenterY, GUndoAxisAngle, GUndoGHaxis, GUndoGVaxis, GUndoDrawLayer)
			eName = GUndoEllipseName
			if (killUndoFolder)
				KillDatafolder root:Packages:WMDrawEllipse:$(graphName):UndoInfo
				// we don't recreate the undo info here because the folder was suspect. The lack of undo info will prevent further undo.
			else
				KillDatafolder root:Packages:WMDrawEllipse:$(graphName):UndoInfo
				StoreUndoInfo(graphName, eName, DRAW_ELLIPSE_ACTION, 0)		// the inverse of erasing...
			endif
			break
		case DRAW_ELLIPSE_ACTION:		// last action was to draw a new ellipse; we just need to erase it, first storing the undo info so that we can re-do it.
			if (!DataFolderExists("root:Packages:WMDrawEllipse:"+graphName+":"+GUndoEllipseName))
				DoAlert 0, "Can't undo last ellipse draw: it appears that the ellipse no longer exists."
				break
			endif
			StoreUndoInfo(graphName, GUndoEllipseName, ERASE_ELLIPSE_ACTION, 0)			// the inverse of drawing...
			eraseElipse(graphName, GUndoEllipseName)
			break
	endswitch
	
	SetDatafolder $saveDF
end

Function/S EllipseMenuUndoItem()

	if (!DatafolderExists("root:Packages:WMDrawEllipse:"+WinName(0,1)+":UndoInfo"))
		return "(Can't Undo"
	else
		NVAR undoAction = root:Packages:WMDrawEllipse:$(WinName(0,1)):UndoInfo:GUndoAction
		switch (undoAction)
			case EDIT_ELLIPSE_ACTION:
				return "Undo Edit Ellipse"
			case ERASE_ELLIPSE_ACTION:
				return "Undo Erase Ellipse"
			case DRAW_ELLIPSE_ACTION:
				return "Undo Ellipse Draw"
			default:
				return "(Can't Undo- Unknown Action"
		endswitch
	endif
end

//************************
// control panels for drawing a new ellipse, editing an existing ellipse, and erasing an ellipse
// Ah, Ha! I can do selection and editing/erasing without a panel!
//************************
static Function fDrawNewEllipsePanel()
	NewPanel /K=1 /W=(24,56,272,257) as "Draw New Ellipse"
	DoWindow/C DrawNewEllipsePanel

	PopupMenu EllipseGraphMenu,pos={16,12},size={110,20},title="Graph:"
	PopupMenu EllipseGraphMenu,mode=1,value= #"WinList(\"*\", \";\", \"WIN:1\")"
	PopupMenu EllipseHAxisMenu,pos={33,55},size={157,20},title="Horizontal Axis:"
	PopupMenu EllipseHAxisMenu,mode=1,value= #"AxisListForEllipsePanels(\"DrawNewEllipsePanel\", 1)"
	PopupMenu EllipseVAxisMenu,pos={45,87},size={120,20},title="Vertical Axis:"
	PopupMenu EllipseVAxisMenu,mode=1,value= #"AxisListForEllipsePanels(\"DrawNewEllipsePanel\", 0)"
	PopupMenu DrawEllipseLayerMenu,pos={53,119},size={153,20},title="Draw layer:"
	PopupMenu DrawEllipseLayerMenu,mode=2,value= #"\"\\M1(annotations;UserFront;ProgFront;\\M1(traces;UserAxes;ProgAxes;\\M1(axes;\\M1(Images;UserBack;ProgBack;\\M1(Window Background;\""
	Button DrawNewEllipseButton,pos={51,156},size={150,20},proc=DrawNewEllipseButtonProc,title="Start Drawing"
	SetWindow DrawNewEllipsePanel, hook=DrawNewEllipseAxisModeHook
EndMacro

Function DrawNewEllipseAxisModeHook(infoStr)
	String infoStr
	
	String event= StringByKey("EVENT",infoStr)
	if (CmpStr(event, "activate") == 0)
		String graphList = WinList("*", ";", "WIN:1")
		String topGraph = WinName(0,1)
		Variable listPos = WhichListItem(topGraph, graphList)
		PopupMenu EllipseGraphMenu,mode=(listPos+1)
		return 1
	else
		return 0
	endif
end

Function/S AxisListForEllipsePanels(panelName, wantHorizontal)
	string panelName
	Variable wantHorizontal
	
	ControlInfo/W=$panelName EllipseGraphMenu
	if (WinType(S_value) == 1)
		return HVAxisList(S_value,wantHorizontal)
	else
		return ""
	endif
end

Function DrawNewEllipseButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo EllipseGraphMenu
	String GraphName = S_value
	ControlInfo EllipseHAxisMenu
	String haxis = S_value
	ControlInfo EllipseVAxisMenu
	String vaxis = S_value
	GetAxis/Q/W=$graphName $haxis
	if (V_flag)
		DoAlert 0, "The axis \""+haxis+"\" does not exist on the graph \""+graphName+"\""
		return -1
	endif
	GetAxis/Q/W=$graphName $vaxis
	if (V_flag)
		DoAlert 0, "The axis \""+vaxis+"\" does not exist on the graph \""+graphName+"\""
		return -1
	endif
	ControlInfo DrawEllipseLayerMenu
	String layer = S_value

	StartDrawingNewEllipse(GraphName, haxis, vaxis, layer)
	return 0
End

Function/S ListEllipsesInTopGraph()
 
 	String graphName = WinName(0,1)
 	if (strlen(graphName) == 0)
 		return ""
 	endif
 	if (!DatafolderExists("root:Packages:WMDrawEllipse:"+graphName))
 		return ""
 	endif
	SVAR EllipseList = root:Packages:WMDrawEllipse:$(graphName):EllipseList
	return EllipseList
end