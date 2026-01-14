#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access.
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version=9.05			// Shipped with Igor 9.05
#pragma IgorVersion=9			// For multiple-return syntax functions

#include <New Polar Graphs> // so this procedure can compile on its own
#include <New Polar Keep On Screen>, version >= 9.03 // for NaN-aware WMPolarUnionRects()
#include <Virtual Drawing Layers>

// Part of the New Polar Graphs procedures
// 7/21/2000, JP: Version 4
// 7/9/2002, JP, Version 4.06:
//	Changes for making programatic use of these routines possible
//	without displaying the panel, namely WMPolarAxesRedrawGraphNow() .
//	Added angleTickLabelScale parameter.
//  Fixed Radius Axis drawn at Left when angle origin is at the top or bottom.
// 11/22/2002, JP, Version 4.07:
//	Protection against infinite loops in WMPolarGrid() when radiusInc == 0,
//	and against NaNs in WMPolarUpdateAxes().
// 10/29/2004, JP, Version 5.03:
//	Added Polar Cursors
//	12/22/2005, JP, Version 5.05:
//	Revised WMPolarSmartTicks() to include the 2.5 increment, better choice for 0-1 in 3 ticks.
//	9/17/2010, JP, Version 6.21:
//	WMPolarAxesRedrawGraphNow calls WMPolarUpdateLegend().
//	10/11/2011, JP, Version 6.23:
//	WMPolarFormatNumber calls WMPolarExecuteStrFunc() on the axis label formats.
// 10/9/2014, JP, Version 6.36:
//	WMPolarUpdateAxes checks that the polar graph actually exists.
// Version 7.05, JP170615, Added Alpha (transparency) support to colors. Used fast StringFromList.
// Version 7.06, JP170913, Fixed WMPolarRadiiForAngleAxes for Radius Start and End angle axes
// Version 8.04, JP191107, Prevented recurring DoAlert 0, "Too many major ticks in grid: increase the angle increment or the radius increment." from occurring.
// Fixed errors in WMPolarCurrentDrawLayer() and WMPolarDrawInfo() involving fast StringFromList, which fixed the background color of opaque labels.
// WMPolarSmartTicks() works with min > max. 
// Version 9.02, JP230307, Fixed WMPolarLabelTick()'s multi-line label opaque background,
//					and WMPolarAngleAxes() not drawing axis labels when the axis thickness is 0.
//					Added grid background color, grid circles are positioned more accurately and are used more often.
//					Fill to Origin polygons and the new grid background polygon are clipped to the polar graph plot area.
// Version 9.021, JP230314, Added ability for user to draw into any layer before the polar graphs package does.
//						This facility requires defining a function with a specific name based on the layer name, with only the graphname parameter:
//							PolarGraphInitProgBackLayer(String graphName)
//							PolarGraphInitUserBackLayer(String graphName)

//							PolarGraphInitProgAxesLayer(String graphName)
//							PolarGraphInitUserAxesLayer(String graphName)
// Version 9.023, JP230317, Simplified and fixed WMPolarDrawInfo() and WMPolarCurrentDrawLayer() to actually return the current (not default) drawing layer.
//                    Made layer and debugging constants public so that they can be overridden.
// Version 9.024, JP230322, Added font bold and font italic
// Version 9.03,  JP230328, Rewrote this routine to draw everything on one (selectable) layer using DrawAction group=gname, beginInsert ("virtual drawing layers")
// Version 9.031, JP231028, Fixed "Use Polar Settings from" when a non-virtual drawn polar graph was selected.
// Version 9.05,  JP231113, Fixed error message from WMPolarAxesRedraw() when Update Polar Graph is clicked but the graph lacks Horiz/VertCrossing axes.

Constant kPolarShowRects= 0	 // debugging: set to non-zero to show the autoscale rectangles. Use Override Constant kPolarShowRects=1 in the main Procedure window
Constant kPolarShowAutoScaleTrace=0	// debugging: set to line size to show the normally invisible autoscale trace (when it is first created)

// Prior to Igor 9.03, the grids, axes, fill-to-origin, and axis labels
// were drawn in this back-to-front order:
//
// (window background)
StrConstant ksPolarLayerFillToZeroBack="ProgBack"
StrConstant ksPolarLayerGrid="UserBack"
StrConstant ksPolarLayerAxes="UserBack"
// (axes and images)
StrConstant ksPolarLayerAxisLabels="ProgAxes"
StrConstant ksPolarLayerFillToZeroFront="UserAxes"
// (traces)
// ProgFront - reserved for user
// UserFront - reserved for user
// (annotations)

// Version 9.02:
// You can change the layers (all) polar graphs draw into by Overriding these constants.
// For example if you want to draw into ProgBack without interference, you can move the layers
// forward by one:
//
// // (window background)
// // ProgBack - reserved for user
//	Override StrConstant ksPolarLayerFillToZeroBack="UserBack"
//	// (axes)
//	Override StrConstant ksPolarLayerGrid="ProgAxes"
//	Override StrConstant ksPolarLayerAxes="ProgAxes"
//	Override StrConstant ksPolarLayerAxisLabels="UserAxes"
//	// (traces and images)
//	Override StrConstant ksPolarLayerFillToZeroFront="ProgFront"
// // UserFront - reserved for user
//	// (annotations)

// a more compatible solution to drawing into the background is to define
// a function named PolarGraphInitProgBackLayer():
// Function PolarGraphInitProgBackLayer(String polarGraphName)
// in which you draw the background content.
// DisplayHelpTopic "Drawing on a Polar Graph"

// Igor 9.03: Draw all of the polar graph axes, labels, fills to zero
// on one selectable drawing layer by always drawing in the same order
// but using group names to possibly delete and insert drawing groups
// as if they were virtual drawing layers, drawn in this order back to front:

// Virtual Drawing Layer Group Name
// ---------------------------------
// init<draw layer name> (eg "initProgAxis")
// 	gridBackground
// 	fillToZeroBack
// 	polarGrid
// 	polarAxes
// 	polarAxisLabels
// 	fillToZeroFront

// Any of these virtual layers may be empty of drawing objects,
// but the group names will still appear in recreation macros.

Function WMPolarCleanOutGraph(graphName)
	String graphName

	String oldLayer= WMPolarCurrentDrawLayer(graphName)
	RemoveFromGraph/Z/W=$graphName polarAutoscaleTrace

	Variable usesVirtualLayers = strlen(WMPolarGraphCurrentDrawLayer(graphName))
	if( usesVirtualLayers )
		WMPolarDeleteAllVirtualLayers(graphName)
	else
		SetDrawLayer/W=$graphName/K $ksPolarLayerFillToZeroBack // Don't call WMPolarClearDrawLayer() because that would draw the user's polar graph layer initialization FUNCREF.
		SetDrawLayer/W=$graphName/K $ksPolarLayerGrid
		SetDrawLayer/W=$graphName/K $ksPolarLayerAxes
		SetDrawLayer/W=$graphName/K $ksPolarLayerAxisLabels
		SetDrawLayer/W=$graphName/K $ksPolarLayerFillToZeroFront
	endif
	
	SetDrawLayer/W=$graphName $oldLayer
End

// Added for version 9.02
static Function RedrawPolarGridBackground(graphName)
	String graphName
	
	String df= WMPolarGraphDF(graphName)
	if( (strlen(df) == 0) || !DataFolderExists(df) )
		return -1
	endif

	String path= WMPolarGraphDFVar(graphName,"drawGridBackground")
	NVAR/Z drawGridBackground=$path
	if( !NVAR_Exists(drawGridBackground) || drawGridBackground == 0 )
		return 0
	endif

	String oldDF= GetDataFolder(1)
	SetDataFolder df
	
	// compare to WMPolarGrid
	// dataMinorAngleTicks= WMPolarGrid(graphName,dataInnerRadius,dataOuterRadius,dataMajorRadiusInc,dataMinorRadiusTicks,dataAngle0,dataAngleRange,dataMajorAngleInc,dataMinorAngleTicks,xMinDrawn, xMaxDrawn, yMinDrawn, yMaxDrawn,minSpacingDrawn)
	// Function WMPolarGrid(graphName,radiusStart,radiusEnd,radiusInc,radiusMinorTicks,angle0,angleRange,angleInc,angleMinorTicks,xmin,xmax,ymin,ymax,minspacing)
	// From this list of parameters, we need only
	// graphName, dataInnerRadius,dataOuterRadius, dataAngle0,dataAngleRange

	WAVE/Z/T tw= $WMPolarGraphTracesTW(graphName)

	// manual inputs
	NVAR angle0Degrees = angle0
	NVAR angleRangeDegrees = angleRange
	
	WMPolarTicks(tw)

	// dataInnerRadius, etc are outputs of WMPolarTicks():
	NVAR radiusStart=dataInnerRadius
	NVAR radiusEnd= dataOuterRadius
	NVAR radiusInc= dataMajorRadiusInc
	NVAR radiusMinorTicks= dataMinorRadiusTicks

	NVAR angle0= dataAngle0 				// radians
	NVAR angleRange= dataAngleRange	// radians
	NVAR angleInc = dataMajorAngleInc
	NVAR angleMinorTicks= dataMinorAngleTicks
	
	NVAR valueAtCenter
	if( radiusStart < valueAtCenter )
		radiusStart= valueAtCenter
	endif

	if( radiusEnd < valueAtCenter )
		radiusEnd= valueAtCenter
	endif
	
	// start code pulled from WMPolarGrid
	NVAR zeroAngleWhere				// 0 = right, 90 = top, 180 = left, -90 = bottom
	NVAR angleDirection				// 1 == clockwise, -1 == counter-clockwise"
	
	Variable angle0Draw= WMPolarAngleFunction(angle0,zeroAngleWhere,angleDirection,2*pi)	// drawn angle in radians

	Variable angleDir= -angleDirection			// -1 if clockwise (angles drawn in opposite direction), 1 if ccw
	Variable angleIncDraw= angleInc * angleDir
	Variable angleRangeDraw= angleRange * angleDir		// drawn angle
	
	NVAR valueAtCenter
	SVAR radiusFunction	// "Linear", "Log", or possibly "Ln"
	
	Variable radStartDraw=WMPolarRadiusFunction(radiusStart,radiusFunction,valueAtCenter)	// drawn radius
	Variable radEndDraw=WMPolarRadiusFunction(radiusEnd,radiusFunction,valueAtCenter)	// drawn radius

	Variable radius,deltaRadius,adjustedRadStart
	Variable visible,x1,y1,x2,y2,cosAngle,sinAngle,angle,angleDraw,lastAngle
	Variable i,numMinorTicks
	
	NVAR useCircles	// 0 for polygons, 1 for circles
	
	SetDrawEnv/W=$graphName push // limit the scope of clipping

	NVAR red= gridBkgColorRed
	NVAR green= gridBkgColorGreen
	NVAR blue= gridBkgColorBlue
	NVAR alpha= gridBkgColorAlpha

	SetDrawEnv/W=$graphName xcoord= HorizCrossing,ycoord= VertCrossing, fillpat= 1,fillfgc=(red,green,blue,alpha), linethick=0, save
	
	// Clip to drawn range
	Variable xMinDrawn, xMaxDrawn, yMinDrawn, yMaxDrawn	// outputs of WMPolarDrawnRange()
	WMPolarDrawnRange(graphName, xMinDrawn, xMaxDrawn, yMinDrawn, yMaxDrawn)	// current drawn range
	SetDrawEnv/W=$graphName clipRect=(xMinDrawn, yMaxDrawn, xMaxDrawn, yMinDrawn), save

	if( useCircles && (angleRangeDegrees >= 360) && (radStartDraw == 0) )
		DrawOval /W=$graphName -radEndDraw, radEndDraw, radEndDraw, -radEndDraw 
	else
		 // for best Appearance, set maxDeltaAngle to submultiple of gridDeltaAngle for the arc
		Variable maxDeltaAngle= WMPolarOptimumGridAngle(graphName,radiusEnd,angleInc,angleMinorTicks)
		Variable additionalPts=limit(round(abs(angleRange/maxDeltaAngle)),1,360) // this many endpoints, plus 1
		Variable dAngle= angleRangeDraw / additionalPts
	
		// draw outer arc at radEndDraw from start angle to end angle
		// unclipped drawn coordinates
		Variable xOrg= radEndDraw * cos(angle0Draw)
		Variable yOrg= radEndDraw * sin(angle0Draw)
		
		Variable xNext,yNext,drawnAngle
		
		Variable n=1
		do	// while there are points to draw
			// draw an arc step
			drawnAngle = angle0Draw+n*dAngle
			xNext = radEndDraw * cos(drawnAngle)
			yNext = radEndDraw * sin(drawnAngle)
			if( n == 1 )
				DrawPoly/W=$graphName xOrg, yOrg, 1, 1, {xOrg, yOrg, xNext, yNext}
			else
				DrawPoly/W=$graphName/A {xNext, yNext}
			endif
			n += 1
		while(n <= additionalPts)
		
		// draw line at end angle to radStartDraw, which may be 0
		xNext = radStartDraw * cos(drawnAngle)
		yNext = radStartDraw * sin(drawnAngle)
		DrawPoly/W=$graphName/A {xNext, yNext}
		
		if( radStartDraw > 0 )
			// draw arc at radStartDraw from end angle to start angle
			n=1
			Variable angleEnd = drawnAngle
			do	// while there are points to draw
				// draw an arc step
				drawnAngle = angleEnd-n*dAngle
				xNext = radStartDraw * cos(drawnAngle)
				yNext = radStartDraw * sin(drawnAngle)
				DrawPoly/W=$graphName/A {xNext, yNext}
				n += 1
			while(n <= additionalPts)
		endif
		
		// draw line at start angle from radStartDraw to radEndDraw (the first point in the polygon)
		DrawPoly/W=$graphName/A {xOrg, yOrg}
	endif

	SetDrawEnv/W=$graphName pop // undo clipping

	SetDataFolder oldDF
End


static Function RedrawFillToOrigins(graphName)
	String graphName
	
	String df= WMPolarGraphDF(graphName)
	if( (strlen(df) == 0) || !DataFolderExists(df) )
		return -1
	endif

	String oldDF= GetDataFolder(1)
	SetDataFolder df
	
	String oldLayer= WMPolarCurrentDrawLayer(graphName)
	
	Variable wantVirtualLayers = WMPolarGraphWantsVirtualLayers(graphName)
	Variable hadVirtualLayer
	if( wantVirtualLayers )
		String drawLayer = WMPolarGraphWantedDrawLayer(graphName)
		WMPolarSwitchDrawLayer(graphName, drawLayer)
		hadVirtualLayer= StartVirtualLayerRedraw(graphName, drawLayer, "gridBackground")
	else
		WMPolarClearDrawLayer(graphName, ksPolarLayerFillToZeroFront) // SetDrawLayer/W=$graphName/K $ksPolarLayerFillToZeroFront
		WMPolarClearDrawLayer(graphName, ksPolarLayerFillToZeroBack) // SetDrawLayer/W=$graphName/K $ksPolarLayerFillToZeroBack, where grid background is drawn.
		WMPolarGraphRecordCurrentDrawLayer(graphName,"")		// marks graph as not using virtual layers
	endif
	Variable usesVirtualLayers= wantVirtualLayers
	
	RedrawPolarGridBackground(graphName)	// 9.02 Possibly draw grid background in $ksPolarLayerFillToZeroBack. 9.03: or "gridBackground"
	if( usesVirtualLayers )
		EndVirtualLayerRedraw(graphName, drawLayer, "gridBackground", hadVirtualLayer)
	endif
	
	WAVE/Z/T tw= polarTracesTW
	if( WaveExists(tw) )

		// 9.02: Clip to drawn range
		Variable xMinDrawn, xMaxDrawn, yMinDrawn, yMaxDrawn	// outputs of WMPolarDrawnRange()
		WMPolarDrawnRange(graphName, xMinDrawn, xMaxDrawn, yMinDrawn, yMaxDrawn)	// current drawn range

		Variable row,n= DimSize(tw,0)
		
		// 9.03: draw all the back fills first, then the front fills for ease in 9.03 virtual layers drawing
		String virtualLayer= "fillToZeroBack"
		Variable isFront
		for( isFront=0; isFront < 2; isFront+=1 )
			if( usesVirtualLayers )
				hadVirtualLayer= StartVirtualLayerRedraw(graphName, drawLayer, virtualLayer)
			else
				if( isFront )
					SetDrawLayer/W=$graphName $ksPolarLayerFillToZeroFront
				else
					SetDrawLayer/W=$graphName $ksPolarLayerFillToZeroBack
				endif
				SetDrawEnv/W=$graphName push
			endif
			Variable needSetDrawEnv= 1
			//SetDrawEnv/W=$graphName xcoord= HorizCrossing,ycoord= VertCrossing, clipRect=(xMinDrawn, yMaxDrawn, xMaxDrawn, yMinDrawn),linethick=0, save
			for( row=0; row < n; row += 1 )
				String isFillToZero=tw[row][kIsFillToZero]
				if( strlen(isFillToZero) )
					String fillToZeroYWaveName= tw[row][kFillToZeroYWaveName]
					String fillToZeroXWaveName= tw[row][kFillToZeroXWaveName]
					WAVE/Z fillY= $fillToZeroYWaveName
					WAVE/Z fillX= $fillToZeroXWaveName
					if( !WaveExists(fillY) )
						continue
					endif
					String fillLayer= tw[row][kFillToZeroLayer] // "back" or "front"
					Variable fillIsFront = CmpStr(fillLayer,"front") == 0
					if( fillIsFront != isFront )
						continue
					endif
					if( needSetDrawEnv )
						SetDrawEnv/W=$graphName xcoord= HorizCrossing,ycoord= VertCrossing, clipRect=(xMinDrawn, yMaxDrawn, xMaxDrawn, yMinDrawn),linethick=0, save
						needSetDrawEnv= 0
					endif
//					SetDrawEnv/W=$graphName push
//					SetDrawEnv/W=$graphName clipRect=(xMinDrawn, yMaxDrawn, xMaxDrawn, yMinDrawn)
					Variable fillRed= str2num(tw[row][kFillToZeroRed])
					Variable fillGreen= str2num(tw[row][kFillToZeroGreen])
					Variable fillBlue= str2num(tw[row][kFillToZeroBlue])
					Variable fillAlpha= str2num(tw[row][kFillToZeroAlpha])
//					SetDrawEnv/W=$graphName xcoord= HorizCrossing,ycoord= VertCrossing, linethick=0, fillfgc=(fillRed,fillGreen,fillBlue,fillAlpha)
					SetDrawEnv/W=$graphName fillfgc=(fillRed,fillGreen,fillBlue,fillAlpha)
					DrawPoly/W=$graphName fillX[0], fillY[0] ,1, 1, fillX, fillY
//					SetDrawEnv/W=$graphName pop // undo clipping
				endif
			endfor
			if( usesVirtualLayers )
				EndVirtualLayerRedraw(graphName, drawLayer, virtualLayer,hadVirtualLayer)
				virtualLayer = "fillToZeroFront"
			else
				SetDrawEnv/W=$graphName pop // undo clipping
			endif
		endfor
	endif
	
	SetDataFolder oldDF

	SetDrawLayer/W=$graphName $oldLayer
	
	return 0
End

// sets up or destroys the fills-to-origin polygon for polarTraceName
Function WMPolarModifyFillToOrigin(graphName,polarTraceName)
	String graphName, polarTraceName // inputs: polarTraceName must not have any radius data wave name such as  "polarY0 [radiusData]" 
	
	Variable isFillToOrigin,isFillBehind	// this is the layer that the fill-to-origin polygon will be on when we're done
	Variable fillRed,fillGreen,fillBlue,fillAlpha
	String fillYWaveName,fillXWaveName
	
	String df= WMPolarGetPolarTraceSettings(graphName,polarTraceName,isFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue,fillYWaveName,fillXWaveName,fillAlpha=fillAlpha)

	if( strlen(df) == 0  )
		return -1
	endif
	String oldDF= GetDataFolder(1)

	String fillYWavePath="",fillXWavePath=""
	if( strlen(fillYWaveName) )
		fillYWavePath= df+fillYWaveName
		fillXWavePath= df+fillXWaveName
	endif
	
	if( isFillToOrigin )
		WAVE/Z wShadowY=TraceNameToWaveRef(graphName,polarTraceName)
		WAVE/Z wShadowX=XWaveRefFromTrace(graphName,polarTraceName)
		if( WaveExists(wShadowY) == 0  || WaveExists(wShadowX) == 0 )
			return -1
		endif

		if( strlen(fillYWaveName) == 0 )
			SetDataFolder df
			fillYWaveName= UniqueName("PolarFillY",1,0)
			fillXWaveName= UniqueName("PolarFillX",1,0)
			SetDataFolder oldDF
			fillYWavePath= df+fillYWaveName	// not yet existant
			fillXWavePath= df+fillXWaveName	// not yet existant
		endif
		WMPolarSetPolarTraceSettings(graphName,polarTraceName,isFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue,fillYWaveName,fillXWaveName)
	
		// generate the fill waves for this one polar trace's polygon
		WMPolarUpdateFillToOrigin(wShadowX,wShadowY)
		WAVE/Z fillY= $fillYWavePath
		WAVE/Z fillX= $fillXWavePath
		if( WaveExists(fillY) == 0  || WaveExists(fillX) == 0 )
			return -1
		endif

	else
		if( strlen(fillYWavePath) )
			KillWaves/Z $fillYWavePath, $fillXWavePath
		endif
		fillYWaveName=""
		fillXWaveName=""
		WMPolarSetPolarTraceSettings(graphName,polarTraceName,isFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue,fillYWaveName,fillXWaveName)
	endif
	
	// Redraw all fill-to-zero layers (because we may be moving the polygon from one layer to the other)
	RedrawFillToOrigins(graphName)

	return 0
End

// See RedrawFillToOrigins()
Function WMPolarAnyTraceHasFillToZero(graphName,fillToZeroDrawLayer)
	String graphName,fillToZeroDrawLayer

	WAVE/Z/T tw= $WMPolarGraphTracesTW(graphName)
	if( WaveExists(tw) )		// this describes the graph's traces
		Variable row,n= DimSize(tw,0)
		for( row=0; row < n; row += 1 )
			String isFillToZero=tw[row][kIsFillToZero]
			if( strlen(isFillToZero) )
				String fillToZeroYWaveName= tw[row][kFillToZeroYWaveName]
				String fillToZeroXWaveName= tw[row][kFillToZeroXWaveName]
				WAVE/Z fillY= $fillToZeroYWaveName
				WAVE/Z fillX= $fillToZeroXWaveName
				if( !WaveExists(fillY) )
					continue
				endif
				String fillLayer= tw[row][kFillToZeroLayer] // "back" or "front"
				if( CmpStr(fillLayer,"front") == 0 && CmpStr(fillToZeroDrawLayer, ksPolarLayerFillToZeroFront) == 0 )
					return 1 // found a fill in the queried fillToZeroDrawLayer
				endif
				
				if( CmpStr(fillLayer,"back") == 0 && CmpStr(fillToZeroDrawLayer, ksPolarLayerFillToZeroBack) == 0 )
					return 1 // found a fill in the queried fillToZeroDrawLayer
				endif
			endif
		endfor
	endif
	
	return 0
End

//
// Redraw all Polar Axes, grids, and labels for top polar graph, unless delayUpdate is on
//
Function WMPolarAxesRedrawTopGraph()

	Variable drawn=0
	if(  !WMPolarDelayUpdate() )
		drawn= WMPolarAxesRedrawTopGraphNow()
	endif
	return drawn
End

//
// Redraw all Polar Axes, grids, and labels for top polar graph
//
Function WMPolarAxesRedrawTopGraphNow()

	return WMPolarAxesRedrawGraphNow(WMPolarTopPolarGraph())
End

//
// Redraw all Polar Axes, grids, and labels for named polar graph
//
Function WMPolarAxesRedrawGraphNow(polarGraphName)
	String polarGraphName

	Variable drawn=0
	Variable graphExists= strlen(polarGraphName) && (WinType(polarGraphName) == 1)
	if( graphExists )
		WAVE/Z/T tw= $WMPolarGraphTracesTW(polarGraphName)
		if( WaveExists(tw) )
			Variable autoScaleTraceChanged= WMPolarAxesRedraw(polarGraphName,tw)
			drawn +=1
			if( autoScaleTraceChanged )
				DoUpdate
				WMPolarAxesRedraw(polarGraphName,tw)
				drawn +=1
			endif
			WMPolarUpdateCursors(polarGraphName)		// 5.03
			WMPolarUpdateLegend(polarGraphName,0)	// 6.21
		endif
	endif
	return drawn
End
 
// Redraws all Polar Axes, grids, and labels.
//
// Call WMPolarAxesRedraw() when a grid or axis setting changes.
//
// Draws on either two or three real drawing layers or on three virtual drawing layers in one real drawing layer:
//
//  WHAT			REAL DRAWING LAYER			VIRTUAL DRAWING LAYER
//  -----------		------------------			---------------------
//	Polar Grid		$ksPolarLayerGrid			"polarGrid"
//  Polar Axes		$ksPolarLayerAxes			"polarAxes"
//  Polar Labels	$ksPolarLayerAxisLabels		"polarAxisLabels"
//
// WMPolarAxesRedraw() makes extensive use of the conversion between
// data units (radiusData and angleData) and drawn units (wShadowX and wShadowY).
//
// These units are related through WMPolarRadiusFunction(), WMPolarRadiusFunctionInv()
// and WMPolarAngleFunction(), WMPolarAngleFunctionInv().
//
// Returns truth that the autoscale trace range changed.
//
Function WMPolarAxesRedraw(graphName,tw)
	String graphName
	Wave/T tw		// polarTracesTW

	// skip the redraw if the needed axes are missing (no polar trace or image)
	String axes=AxisList(graphName)
	Variable haveAxes= (FindListItem("VertCrossing",axes) >= 0) && (FindListItem("HorizCrossing",axes) >= 0)
	if( !haveAxes )
		return 0		// autoscale trace range unchanged.
	endif

	// all the drawing routines ASSUME they are in the polar graph's home data folder,
	// and it's faster to use NVAR rather than WMPolarGetVar()
	//
	String oldDF= GetDataFolder(1)
	String df= GetWavesDataFolder(tw,1)
	SetDataFolder df	
	
	String currentDrawLayer
	Variable plotRed,plotGreen,plotBlue // the opaque label background color
	WMPolarDrawInfo(graphName,currentDrawLayer,plotRed,plotGreen,plotBlue)

	NVAR plotAreaRed, plotAreaGreen, plotAreaBlue	
	plotAreaRed= plotRed
	plotAreaGreen= plotGreen
	plotAreaBlue= plotBlue
	
	WMPolarTicks(tw)

	// outputs of WMPolarTicks():
	NVAR dataInnerRadius
	NVAR dataOuterRadius
	NVAR dataMajorRadiusInc
	NVAR dataMinorRadiusTicks
	NVAR dataAngle0
	NVAR dataAngleRange
	NVAR dataMajorAngleInc
	NVAR dataMinorAngleTicks
	
	NVAR valueAtCenter
	if( dataInnerRadius < valueAtCenter )
		dataInnerRadius= valueAtCenter
	endif

	if( dataOuterRadius < valueAtCenter )
		dataOuterRadius= valueAtCenter
	endif

	// avoid infinite loops
	Variable canDraw = numtype(dataMajorRadiusInc) == 0 && dataMajorRadiusInc != 0 && numtype(dataMajorAngleInc) == 0 && dataMajorAngleInc != 0
	if( !canDraw )
		canDraw= 0 // put breakpoint here
	endif
	
	Variable xMinDrawn, xMaxDrawn, yMinDrawn, yMaxDrawn	// outputs of WMPolarDrawnRange()
	WMPolarDrawnRange(graphName, xMinDrawn, xMaxDrawn, yMinDrawn, yMaxDrawn)	// current drawn range

	// Accumulate the max range of the grids, axes and tick labels;
	// these are updated by the drawing routines (if anything gets drawn!)
	NVAR fullXMinDrawn, fullXMaxDrawn, fullYMinDrawn, fullYMaxDrawn
	fullXMinDrawn= NaN
	fullXMaxDrawn= NaN
	fullYMinDrawn= NaN
	fullYMaxDrawn= NaN

	NVAR doMinGridSpacing
	NVAR minGridSpacing
	Variable minSpacingDrawn= doMinGridSpacing ? WMPolarPointsToDrawn(graphName,minGridSpacing) : 0

	Variable wantVirtualLayers = WMPolarGraphWantsVirtualLayers(graphName)
	Variable hadVirtualLayer
	if( wantVirtualLayers )
		String drawLayer = WMPolarGraphWantedDrawLayer(graphName)
		WMPolarSwitchDrawLayer(graphName, drawLayer)
		hadVirtualLayer= StartVirtualLayerRedraw(graphName, drawLayer, "polarGrid")
	else
		// clear virtual layers from drawLayer
		String lastDrawnDrawLayer = WMPolarGraphCurrentDrawLayer(graphName)
		if( strlen(lastDrawnDrawLayer) )
			DeleteVirtualLayers(graphName,lastDrawnDrawLayer,ksPolarVirtualLayers)
			// delete the Init layer, too
			WMPolarDeleteInitVirtualLayer(graphName, lastDrawnDrawLayer)
			WMPolarGraphRecordCurrentDrawLayer(graphName,"") // not using virtual layers
			// could ensure legacy backgrounds here,
			// but it might overwrite the fills to zero
		endif
		// Ensure any FUNCREFs that clear drawing layers are called, even if we don't draw in them.
		if( !WMPolarAnyTraceHasFillToZero(graphName,ksPolarLayerFillToZeroBack) )
			WMPolarClearDrawLayer(graphName, ksPolarLayerFillToZeroBack) // SetDrawLayer/W=$graphName/K $ksPolarLayerFillToZeroBack
		endif
		if( !WMPolarAnyTraceHasFillToZero(graphName,ksPolarLayerFillToZeroFront) )
			WMPolarClearDrawLayer(graphName, ksPolarLayerFillToZeroFront) // SetDrawLayer/W=$graphName/K $ksPolarLayerFillToZeroFront
		endif
		// Grids go in back of everything except fill-to-origin (back)
		WMPolarClearDrawLayer(graphName, ksPolarLayerGrid) // SetDrawLayer/W=$graphName/K $ksPolarLayerGrid
	endif
	Variable usesVirtualLayers = wantVirtualLayers
	SetDrawEnv/W=$graphName xcoord= HorizCrossing,ycoord= VertCrossing, textxjust=1, textyjust=1, save
	Variable endedPolarGridRedraw = 0 // for virtual drawing layers
	NVAR doPolarGrids

	if( doPolarGrids && canDraw )	// Grid checkbox, 0 for off, 1 for on
		Variable numMajorCircles= abs((dataOuterRadius-dataInnerRadius)/dataMajorRadiusInc)
		Variable numMajorLines= abs(dataAngleRange/dataMajorAngleInc)

		if( numMajorCircles+numMajorLines > 1000 )		// Change this number, if you wish
			Variable warningCount= NumVarOrDefault(df+"tooManyTicksWarningCount",0)
			Variable/G $(df+"tooManyTicksWarningCount") = warningCount+1
			String msg= "Too many major ticks in grid: increase the angle increment or the radius increment."
			if( warningCount > 2 )
				if( warningCount < 10 )
					Print "• "+msg
				endif
			else
				DoAlert 0, msg
			endif
			if( usesVirtualLayers )
				EndVirtualLayerRedraw(graphName, drawLayer, "polarGrid",hadVirtualLayer)
			endif
			SetDrawLayer/W=$graphName $currentDrawLayer
			SetDataFolder oldDF
			return 0
		endif
		Variable/G $(df+"tooManyTicksWarningCount") = 0
		
		// draw the polar grid
		dataMinorAngleTicks= WMPolarGrid(graphName,dataInnerRadius,dataOuterRadius,dataMajorRadiusInc,dataMinorRadiusTicks,dataAngle0,dataAngleRange,dataMajorAngleInc,dataMinorAngleTicks,xMinDrawn, xMaxDrawn, yMinDrawn, yMaxDrawn,minSpacingDrawn)
	endif

	if( canDraw )
		if( !usesVirtualLayers )
			// 9.02: update the grid background in the backmost drawing layer.
			// Since the grid background and fills to zero are drawn on the same layer
			// we must update them both.
			String path= WMPolarGraphDFVar(graphName,"drawGridBackground")
			NVAR/Z drawGridBackground=$path
			if( NVAR_Exists(drawGridBackground) && drawGridBackground != 0 )
				RedrawFillToOrigins(graphName)
			endif
		else
			EndVirtualLayerRedraw(graphName, drawLayer, "polarGrid",hadVirtualLayer)
			endedPolarGridRedraw = 1 // don't call EndVirtualLayerRedraw() twice
			RedrawFillToOrigins(graphName)
		endif
	endif

	// if we have no radius or angle axes, skip unneeded commands

	// Draw Radius (Line) Axes
	WAVE wAxisAngles= WMPolarAnglesForRadiusAxes(dataAngle0,dataAngleRange,dataMajorAngleInc,dataMinorAngleTicks)
	Variable numRadiusAxes= numpnts(wAxisAngles)
	// Debugging:	wAxisAngles[0]	wAxisAngles[1]	wAxisAngles[2]	wAxisAngles[3]	wAxisAngles[4]	wAxisAngles[5]	wAxisAngles[6]	wAxisAngles[7]	wAxisAngles[8]	

	// Draw angle (Circle) Axes
	WAVE wAxisRadii= WMPolarRadiiForAngleAxes(dataInnerRadius,dataOuterRadius,dataMajorRadiusInc,dataMinorAngleTicks)
	Variable numAngleAxes= numpnts(wAxisRadii)
	// Debugging:	wAxisRadii[0]	wAxisRadii[1]	wAxisRadii[2]	wAxisRadii[3]	wAxisRadii[4]	wAxisRadii[5]	wAxisRadii[6]	wAxisRadii[7]	wAxisRadii[8]	

	Variable haveAnyAxes = (numRadiusAxes > 0) || (numAngleAxes > 0)

	if( usesVirtualLayers )
		if( !endedPolarGridRedraw )
			EndVirtualLayerRedraw(graphName, drawLayer, "polarGrid", hadVirtualLayer)
		endif
		// ensure these two virtual layers exist and are empty
		EmptyVirtualLayer(graphName, drawLayer, "polarAxisLabels")
		EmptyVirtualLayer(graphName, drawLayer, "polarAxes")
		if( haveAnyAxes )
			NVAR doRadiusTickLabels
			NVAR doAngleTickLabels
			if( doRadiusTickLabels || doAngleTickLabels )
				hadVirtualLayer= StartAppendToVirtualLayer(graphName, drawLayer, "polarAxisLabels")
				SetDrawEnv/W=$graphName xcoord= HorizCrossing,ycoord= VertCrossing, textxjust=1,textyjust=1, save // middle center
				EndAppendToVirtualLayer(graphName, drawLayer, "polarAxisLabels", hadVirtualLayer)
			endif
			
			hadVirtualLayer= StartAppendToVirtualLayer(graphName, drawLayer, "polarAxes")
			SetDrawEnv/W=$graphName xcoord= HorizCrossing,ycoord= VertCrossing, textxjust=1,textyjust=1, save // middle center
			EndAppendToVirtualLayer(graphName, drawLayer, "polarAxes", hadVirtualLayer)
		endif
	else
		// axis labels go here (normally on top)
		WMPolarClearDrawLayer(graphName, ksPolarLayerAxisLabels) // SetDrawLayer/W=$graphName/K $ksPolarLayerAxisLabels
		
		if( CmpStr(ksPolarLayerGrid,ksPolarLayerAxes) == 0 )	// drawn on the same layer?
			SetDrawLayer/W=$graphName $ksPolarLayerAxes			// axes and tickmarks go here, which we draw on top of the grid.
		else
			// axes and tickmarks go here, which we draw first.
			WMPolarClearDrawLayer(graphName, ksPolarLayerAxes) // SetDrawLayer/W=$graphName/K $ksPolarLayerAxes
		endif
	endif

	// Draw Radius (Line) Axes
//	WAVE wAxisAngles= $WMPolarAnglesForRadiusAxes(dataAngle0,dataAngleRange,dataMajorAngleInc,dataMinorAngleTicks)
//	Variable numRadiusAxes= numpnts(wAxisAngles)
//	// Debugging:	wAxisAngles[0]	wAxisAngles[1]	wAxisAngles[2]	wAxisAngles[3]	wAxisAngles[4]	wAxisAngles[5]	wAxisAngles[6]	wAxisAngles[7]	wAxisAngles[8]	

	if( numRadiusAxes > 0 && canDraw )	// radius axes, ticks, and labels
		Variable x0Drawn=0, y0Drawn=0		// origin for radius axes is shifted if " Left" or " Bottom"
		
		NVAR radiusAxesAtLeftBottomRadius //  this is where the offset radius axis intersects a radius axis drawn from the origin
		SVAR radiusFunction
		Variable drawnRadius= WMPolarRadiusFunction(radiusAxesAtLeftBottomRadius,radiusFunction,valueAtCenter)

//		SVAR radiusAxesWhere
		// the case values must match those returned by WMPolarRadiusAxisAtPopup()
		String radiusAxesWhere= WMPolarGetCleanedStr("radiusAxesWhere",WMPolarRadiusAxisAtPopup())	//	Version 6.33: cleans up user-entered values of radiusAxesWhere to match expected choices
		strswitch( radiusAxesWhere )
			case "  Left":
				x0Drawn= -drawnRadius
				y0Drawn= 0
				break
			case "  Bottom":
				x0Drawn=0
				y0Drawn=-drawnRadius
				break
			case "  Right":
				x0Drawn= drawnRadius
				y0Drawn= 0
				break
			case "  Top":
				x0Drawn=0
				y0Drawn=drawnRadius
				break
			default:
				x0Drawn=0
				y0Drawn=0
				break
		endswitch

		NVAR zeroAngleWhere, angleDirection
		Variable angle0Draw= WMPolarAngleFunction(dataAngle0,zeroAngleWhere,angleDirection,2*pi)	// drawn angle
		Variable angleDir= -angleDirection			// -1 if clockwise (angles drawn in opposite direction), 1 if ccw
		Variable angleRangeDraw= dataAngleRange * angleDir		// drawn angle
		WMPolarRadiusAxes(graphName,dataInnerRadius,dataOuterRadius,dataMajorRadiusInc,dataMinorRadiusTicks,wAxisAngles,angle0Draw, angleRangeDraw,x0Drawn,y0Drawn,xMinDrawn, xMaxDrawn, yMinDrawn, yMaxDrawn)
	endif

	// Draw angle (Circle) Axes
//	WAVE wAxisRadii= $WMPolarRadiiForAngleAxes(dataInnerRadius,dataOuterRadius,dataMajorRadiusInc,dataMinorAngleTicks)
//	Variable numAngleAxes= numpnts(wAxisRadii)
//	// Debugging:	wAxisRadii[0]	wAxisRadii[1]	wAxisRadii[2]	wAxisRadii[3]	wAxisRadii[4]	wAxisRadii[5]	wAxisRadii[6]	wAxisRadii[7]	wAxisRadii[8]	

	if( numAngleAxes > 0 && canDraw )	// angle  axes, ticks, and labels
		WMPolarAngleAxes(graphName,dataInnerRadius,dataOuterRadius,dataMajorRadiusInc,dataAngle0,dataAngleRange,dataMajorAngleInc,dataMinorAngleTicks,wAxisRadii,xMinDrawn, xMaxDrawn, yMinDrawn, yMaxDrawn,minSpacingDrawn)
	endif
	
//	Variable validFullRange = (numtype(fullXMinDrawn) + numtype(fullYMinDrawn) + numtype(fullXMaxDrawn) + numtype(fullYMaxDrawn) ) == 0 
//	if( kPolarShowRects && validFullRange )

	if( numtype(fullXMinDrawn) == 2 )
		fullXMinDrawn= xMinDrawn
	endif
	if( numtype(fullYMinDrawn) == 2 )
		fullYMinDrawn= yMinDrawn
	endif
	if( numtype(fullXMaxDrawn) == 2 )
		fullXMaxDrawn= xMaxDrawn
	endif
	if( numtype(fullYMaxDrawn) == 2 )
		fullYMaxDrawn= yMaxDrawn
	endif

	if( kPolarShowRects )
		if( usesVirtualLayers )
			hadVirtualLayer = StartAppendToVirtualLayer(graphName, drawLayer, "fillToZeroFront")
			SetDrawEnv/W=$graphName xcoord= HorizCrossing,ycoord= VertCrossing, fillpat=0, lineThick=2
			DrawRect/W=$graphName fullXMinDrawn, fullYMinDrawn, fullXMaxDrawn, fullYMaxDrawn
			EndAppendToVirtualLayer(graphName, drawLayer, "fillToZeroFront", hadVirtualLayer)
		else
			SetDrawEnv/W=$graphName fillpat=0, lineThick=2
			DrawRect/W=$graphName fullXMinDrawn, fullYMinDrawn, fullXMaxDrawn, fullYMaxDrawn
		endif
	endif

	Variable changed= WMPolarUpdateAutoRangeTrace(graphName,tw,fullXMinDrawn, fullYMinDrawn, fullXMaxDrawn, fullYMaxDrawn )

	SetDrawLayer/W=$graphName $currentDrawLayer
	SetDataFolder oldDF
	
	return changed
End

// returns truth that the autoRangeTrace values changed
Function WMPolarUpdateAutoRangeTrace(graphName,tw,fullXMinDrawn, fullYMinDrawn, fullXMaxDrawn, fullYMaxDrawn )
	String graphName
	Wave/T tw // polarTracesTW
	Variable fullXMinDrawn, fullYMinDrawn, fullXMaxDrawn, fullYMaxDrawn
	
	String oldDF= GetDataFolder(1)
	String df= GetWavesDataFolder(tw,1)
	SetDataFolder df	
	
	WAVE/Z polarAutoscaleTrace
	WAVE/Z polarAutoscaleTraceX
	Variable changed= 0
	if( WaveExists(polarAutoscaleTrace) && WaveExists(polarAutoscaleTraceX) )
		changed= fullYMinDrawn != polarAutoscaleTrace[0] || fullYMaxDrawn != polarAutoscaleTrace[1]
		changed= changed || fullXMinDrawn != polarAutoscaleTraceX[0] || fullXMaxDrawn != polarAutoscaleTraceX[1]
	else
		changed= 1
	endif
	Make/O polarAutoscaleTrace= {fullYMinDrawn,fullYMaxDrawn}
	Make/O polarAutoscaleTraceX={fullXMinDrawn,fullXMaxDrawn}
	CheckDisplayed/W=$graphName polarAutoscaleTrace
	if( V_Flag == 0 )
		AppendToGraph/W=$graphName/B=HorizCrossing/L=VertCrossing polarAutoscaleTrace vs polarAutoscaleTraceX
		ModifyGraph/W=$graphName lsize(polarAutoscaleTrace)=1,mode(polarAutoscaleTrace)=4,marker(polarAutoscaleTrace)=19	// visible lines and marker
		ModifyGraph/W=$graphName rgb(polarAutoscaleTrace)=(50000,50000,50000) // light gray
		ModifyGraph/W=$graphName hideTrace(polarAutoscaleTrace)=kPolarShowAutoScaleTrace ? 0 : 2 // 
		changed= 1
	endif
	
	SetDataFolder oldDF
	
	return changed
End

Function WMPolarDrawInfo(graphName,layer,plotRed,plotGreen,plotBlue)
	String graphName
	String &layer
	Variable &plotRed,&plotGreen,&plotBlue

	layer= WMPolarCurrentDrawLayer(graphName) 
	
	GetWindow $graphName gbRGB // gbRGB	Sets V_Red, V_Green, V_Blue, and V_Alpha as RGBA Values to the plot area background color of the window in graph windows, as set by ModifyGraph gbRGB. Other windows set these values to 65535 (opaque white).
	plotRed= V_Red
	plotGreen= V_Green
	plotBlue= V_Blue
End

Function/S WMPolarCurrentDrawLayer(graphName)
	String graphName
	
	GetWindow $graphName drawLayer
	String layer= S_value
	return layer
End

// Draws angle axes (the "rings").
//
// All input angles in data coordinate radians,
// input radii are in data coordinates
// However, xmin,xmax,ymin,ymax,minspacing are in DRAWN coordinates.
//
Function WMPolarAngleAxes(graphName,radiusStart,radiusEnd,radiusInc,angle0,angleRange,angleInc,angleMinorTicks,wAxisRadii,xmin,xmax,ymin,ymax,minspacing)
	String graphName
	Variable radiusStart,radiusEnd,radiusInc
	Variable angle0,angleRange,angleInc,angleMinorTicks	// angleMinorTicks == 0 if none
	Wave wAxisRadii						// radii in data coordinates
	Variable xmin,xmax,ymin,ymax			// plot extent in drawn coordinates
	Variable minspacing					// min spacing between spokes, in drawn coordinates

	Variable numAngleAxes= numpnts(wAxisRadii)	// number of radii in wAxisRadii
	if( numAngleAxes < 1 )
		return 0
	endif
	
	Variable radius,deltaAngle,adjustedMinorTicks
	Variable angle,angleDraw
	Variable visible,inhibited,thick

	// axis
	NVAR angleAxisThick

	// ticks
	SVAR tickWhere= angleTicksLocation		// "Off;Crossing;Inside;Outside"
	Variable doMajorTicks= CmpStr(tickWhere,"Off") != 0	

	// tick range
	SVAR doMajorAngleTicks	// "auto" or "manual"
	Variable numMinorTicks=0		// provisional
	NVAR majorTickThick, minorTickThick

	// labels
	NVAR doAngleTickLabels		// boolean
	
	SVAR angleTickLabelRotation
	Variable lblOrient= str2num(angleTickLabelRotation)	// degrees

	SVAR font= tickLabelFontName
	NVAR fontSize= tickLabelFontSize
	Variable fontBold= NumVarOrDefault("tickLabelFontBold", 0)
	Variable fontItalic= NumVarOrDefault("tickLabelFontItalic", 0)
	Variable fontStyle = (fontItalic * 2) + fontBold

	Variable labelHeight = FontSizeHeight(font,fontSize,0)	// points

	NVAR tickLabelOpaque

	SVAR angleTickLabelNotation
	SVAR angleTickLabelUnits	// "degrees" or "radians"
	Variable radians= CmpStr(angleTickLabelUnits,"radians")==0	// label angle units, NOT data angle units

	Variable angleTickLabelScale= NumVarOrDefault("angleTickLabelScale",1)	// new 6/19/2002, angleTickLabelScale may not exist

	// label range (NOT the tick range)
	NVAR doAngleTickLabelSubRange		// 1 if manual subrange, 0 if auto range (entire axis range)
	
	// manual tick label angle subrange
	NVAR angleTickLabelRangeStart		// in degrees, data coordinates
	NVAR angleTickLabelRangeExtent	// in degrees, data coordinates

	Variable angleLabelStart,angleLabelRange
	if( doAngleTickLabelSubRange )
		angleLabelStart=WMPolarDegToRad(angleTickLabelRangeStart)
		angleLabelRange= WMPolarDegToRad(angleTickLabelRangeExtent)
	else
		angleLabelStart=angle0
		angleLabelRange=angleRange
	endif

	// calling routine is responsible for setting the drawLayer (if any) used for virtual layers
	String drawLayer = WMPolarGraphCurrentDrawLayer(graphName)
	Variable usingVirtualLayers = strlen(drawLayer)
	if( usingVirtualLayers )
		WMPolarSwitchDrawLayer(graphName, drawLayer)
		StartAppendToVirtualLayer(graphName, drawLayer, "polarAxes")	// next things drawn insert into the polarAxes virtual layer before pop command
		//SetDrawEnv/W=$graphName fname=(font), fsize=fontSize, fstyle=fontStyle, save
	else
		SetDrawLayer/W=$graphName $ksPolarLayerAxisLabels
		SetDrawEnv/W=$graphName xcoord= HorizCrossing,ycoord= VertCrossing,save
		SetDrawEnv/W=$graphName fname=(font), fsize=fontSize, fstyle=fontStyle, textxjust=1, textyjust=1, save

		SetDrawLayer/W=$graphName $ksPolarLayerAxes
		SetDrawEnv/W=$graphName xcoord= HorizCrossing,ycoord= VertCrossing,save
		SetDrawEnv/W=$graphName fname=(font), fsize=fontSize, fstyle=fontStyle, textxjust=1, textyjust=1, save
	endif
	
	NVAR angleAxisColorRed,angleAxisColorGreen,angleAxisColorBlue
	Variable angleAxisColorAlpha= NumVarOrDefault("angleAxisColorAlpha", 65535)
	SetDrawEnv/W=$graphName linefgc=(angleAxisColorRed,angleAxisColorGreen,angleAxisColorBlue,angleAxisColorAlpha)
	SetDrawEnv/W=$graphName linebgc=(angleAxisColorRed,angleAxisColorGreen,angleAxisColorBlue,angleAxisColorAlpha)
	SetDrawEnv/W=$graphName dash= 0,fillpat=0, save

	// coordinates
	NVAR zeroAngleWhere	// was popup code, now degrees (0 == right, 90=top, etc)
	NVAR angleDirection	// was popup code, "clockwise;counter-clockwise", now 1 for clockwise, -1 for counter-clockwise.
	NVAR valueAtCenter
	SVAR radiusFunction	// "Linear", "Log", or possibly "Ln"

	if( angleMinorTicks > 0 )		// same as FPolarGrid minor tick calculations
		Make/O/N=(angleMinorTicks+1) W_adjustedRadii	// indexed by mod(i,angleTicks+1) (revised angleMinorTicks guaranteed less than original angleMinorTicks)
		// lie about radiusEnd by radiusInc so that minor ticks can be drawn at end radius, even if no minor grid
		angleMinorTicks= WMPolarCalcAdjustedRadiuses(W_adjustedRadii,angleMinorTicks,angleInc,radiusStart,radiusEnd+radiusInc,radiusInc,minspacing,radiusFunction,valueAtCenter)
		deltaAngle= angleInc/(angleMinorTicks+1)
	endif

	// Prevent overlapping radius axes at 0 and 2*Pi
	Variable absDeltaAngle= abs(angleInc/(angleMinorTicks+1))
	Variable lastMajorAngle= angle0 + angleRange	// idealistic case; doesn't work well when angleRange is 2 * Pi
	if (2*Pi - abs(angleRange) < absDeltaAngle/2 )	// eek, could have two overlapping radius grids at angleRange near 2*Pi.
		lastMajorAngle -= sign(angleRange) * absDeltaAngle/2
	endif

	// these globals accumulate a rectangle that encompasses grids, axes, and axis labels
	NVAR fullXMinDrawn, fullXMaxDrawn, fullYMinDrawn, fullYMaxDrawn
	Variable fxMin=fullXMinDrawn
	Variable fxMax=fullXMaxDrawn
	Variable fyMin=fullYMinDrawn
	Variable fyMax=fullYMaxDrawn

	Variable angle0Draw= WMPolarAngleFunction(angle0,zeroAngleWhere,angleDirection,2*pi)	// drawn angle

	Variable angleDir= -angleDirection			// -1 if clockwise (angles drawn in opposite direction), 1 if ccw
	Variable angleIncDraw= angleInc * angleDir
	Variable angleRangeDraw= angleRange * angleDir		// drawn angle

	// compute optimum angle increment for arcs: a submultiple of major angle increment, and also possibly of the minor angle increment.
	Variable maxDeltaAngleDraw= WMPolarOptimumGridAngle(graphName,radiusEnd,angleInc,angleMinorTicks)

	NVAR majorTickLength
	Variable majTickLen= WMPolarPointsToDrawn(graphName,majorTickLength)

	NVAR minorTickLength
	Variable minTickLen= WMPolarPointsToDrawn(graphName,minorTickLength)

	NVAR lblOffsetPoints= angleTickLabelOffset	// user value in points
	Variable lblOffset= WMPolarPointsToDrawn(graphName,lblOffsetPoints)
	
	Variable addlOffset= WMPolarPointsToDrawn(graphName,labelHeight)

	// tick label sizes
	String str
	Variable labelLen
	SVAR fmt= angleTickLabelNotation		// "%g" or possibly "%g º" if radians.
	SVAR labelSigns= angleTickLabelSigns
	
	Variable value= WMPolarDegreesOrFractionOfPi(lastMajorAngle,radians)	// no-one prints radians, they print pi/2 or 0.5 º, and we expect the º to be in the format
	str= WMPolarFormatNumber(value*angleTickLabelScale, fmt, labelSigns)

	labelLen=FontSizeStringWidth(font,fontSize,0,str)	// points

	value= WMPolarDegreesOrFractionOfPi(angle0,radians)
	str= WMPolarFormatNumber(value*angleTickLabelScale, fmt, labelSigns)
	labelLen=max(labelLen,FontSizeStringWidth(font,fontSize,0,str))
	
	NVAR wantCircles= useCircles		// 0 for polygons, 1 for circles

	Variable tickOrient		// 0 or Pi, ticks parallel to radius angle (0 for labels on outside of axis, Pi for inside axis)
	Variable maj,tk
	Variable drawnRadius
	Variable a=0
	Variable tx,ty	// endpoint of tick mark opposite the tick label, in drawn coordinates.
	Variable lx,ly 	// label anchor position in drawn coordinates
	Variable x1, y1, x2, y2
	do
		radius= wAxisRadii[a]	// data radius at which to draw an arc.
		drawnRadius=WMPolarRadiusFunction(radius,radiusFunction,valueAtCenter)  // drawn radius
		
		WMPolarRectEnclosingArc(drawnRadius,angle0Draw,angleRangeDraw, x1, y1, x2, y2)
		WMPolarUnionRects(fxMin, fyMin, fxMax, fyMax, x1, y1, x2, y2)
		visible = 1 // 9.02
		if( angleAxisThick )
			SetDrawEnv/W=$graphName linethick=angleAxisThick,save	// angleAxisThick could be zero!
			visible= WMPolarDrawArc(graphName,drawnRadius,angle0Draw,angleRangeDraw,maxDeltaAngleDraw,xmin,xmax,ymin,ymax,wantCircles,angleAxisThick)	// 0 if invisible, 1 if not clipped, 2 if only x1,y1 clipped, 3 or 4 if x2,y2 clipped
		endif
		// Draw Tick marks, if turned on, and within the allowable range
		// Draw Tick labels, if turned on, and within the allowable range
		if( visible && (doMajorTicks || doAngleTickLabels) )
			tickOrient= WMPolarAngleTickOrientation(graphName,radius,drawnRadius,valueAtCenter,radiusStart,labelLen+lblOffsetPoints)
			if( doMajorTicks && (angleMinorTicks > 0) )
				adjustedMinorTicks= WMPolarTicksForRadius(radius,angleMinorTicks,W_adjustedRadii)		// Minor Ticks per major increment is a variable number depending on the radius
				deltaAngle= angleInc/(adjustedMinorTicks+1)	// data coordinates
				numMinorTicks=floor(1+ (adjustedMinorTicks+1) * abs(angleRange/angleInc))	// total minor ticks, was round(...)
				tk= 1
				SetDrawEnv/W=$graphName linethick=minorTickThick,save
				angle= angle0 + deltaAngle	// we skip the major angles, to avoid two spokes at the same location
				do
					angleDraw= WMPolarAngleFunction(angle,zeroAngleWhere,angleDirection,2*pi)	// drawn angle
					angleDraw= WMPolarStraightenAngle(angleDraw)					
					WMPolarDrawTick(graphName,drawnRadius,angleDraw,0,0,minorTickThick,minTickLen,0,tickOrient,tickWhere,tx,ty,lx,ly,xmin,xmax,ymin,ymax)
					tk += 1
					if( mod(tk,adjustedMinorTicks+1)==0 )	// we skip the major tick angles, to avoid two ticks at the same location
						tk += 1
					endif
					angle = angle0 + tk * deltaAngle
				while( tk <  numMinorTicks )
			endif
			// Major Ticks
			angle= angle0
			maj=0
			SetDrawEnv/W=$graphName linethick=majorTickThick,save
			do
				angleDraw= WMPolarAngleFunction(angle,zeroAngleWhere,angleDirection,2*pi)	// drawn angle
				angleDraw= WMPolarStraightenAngle(angleDraw)
				Variable lOffset= lblOffset + addlOffset + abs(addlOffset* cos(angleDraw)/4)
				// Major tick
				Variable tickThick = !doMajorTicks ? 0 : majorTickThick	// if no major ticks, just update lx,ly for label				
				visible= WMPolarDrawTick(graphName,drawnRadius,angleDraw,0,0,majorTickThick,majTickLen,lOffset,tickOrient,tickWhere,tx,ty,lx,ly,xmin,xmax,ymin,ymax)
				inhibited =  !WMPolarAngleInRange(angle,angleLabelStart,angleLabelRange)
				// Major tick label
				if( doAngleTickLabels && !inhibited )
					if( usingVirtualLayers )
						EndAppendToVirtualLayer(graphName, drawLayer, "polarAxes", 1)
						StartAppendToVirtualLayer(graphName, drawLayer, "polarAxisLabels")
						SetDrawEnv/W=$graphName fname=(font), fsize=fontSize, fstyle=fontStyle, save
					else
						SetDrawLayer/W=$graphName $ksPolarLayerAxisLabels
					endif

					value= WMPolarDegreesOrFractionOfPi(angle,radians)	// no-one prints radians, they print pi/2 or 0.5 º, and we expect the º to be in the format
					value *= angleTickLabelScale
					WMPolarLabelTick(graphName,visible,lx,ly,value,fmt,labelSigns,font,fontSize,labelHeight,tickLabelOpaque,lblOrient,angleDraw+tickOrient,fxMin, fxMax, fyMin, fyMax)

					if( usingVirtualLayers )
						EndAppendToVirtualLayer(graphName, drawLayer, "polarAxisLabels", 1)
						StartAppendToVirtualLayer(graphName, drawLayer, "polarAxes")
					else
						SetDrawLayer/W=$graphName $ksPolarLayerAxes
					endif
				endif
				maj += 1
				angle = angle0 + maj * angleInc
			while( angle <= lastMajorAngle )
		endif
		a+= 1
	while(a < numAngleAxes )

	if( usingVirtualLayers )
		EndAppendToVirtualLayer(graphName, drawLayer, "polarAxes", 1)
	endif

	KillWaves/Z W_adjustedRadii
	
	fullXMinDrawn= fxMin
	fullXMaxDrawn= fxMax
	fullYMinDrawn= fyMin
	fullYMaxDrawn= fyMax
End

// Igor 6.23:
Function/S WMPolarExecuteStrFunc(str)
	String str
	
	String funcName= StringFromList(0, str, "(")
	if( strlen(funcName)  )
		Variable isFunction= (exists(funcName) == 6) || (exists(funcName) == 3) 
		if( isFunction )
			String oldDF= WMPolarSetSubfolderDF("")
			KillVariables/Z $WMPolarDFVar("S_PrintLabel")
			KillWaves/Z $WMPolarDFVar("S_PrintLabel")
			String/G $WMPolarDFVar("S_PrintLabel")=str
			SVAR/Z S_PrintLabel= $WMPolarDFVar("S_PrintLabel")
			if( SVAR_Exists(S_PrintLabel) )
				Execute/Q/Z "String/G S_PrintLabel= "+str
				if( V_Flag == 0 )
					str= S_PrintLabel
				endif
			endif
			SetDataFolder oldDF
		endif
	endif
	return str
End

Function/S WMPolarFormatNumber(value, fmt, labelSigns)
	Variable value
	String fmt		// "%g" or "%g º", or whatever
	String labelSigns	// " - only; + and -; no signs"

	String str
	sprintf str,fmt,value
	
	str= WMPolarExecuteStrFunc(str)	// Igor 6.23: try executing str as a string function and use that result, instead
	
	Variable digitPos=WMPolarFirstDigitPos(str)
	if( digitPos < 0 )	// need a digit to add or subtract a sign from
		return str
	endif

	Variable plusPos= strsearch(str,"+",0)	// -1 if missing, 0 if first char, but the sign could be later, if fmt= "distance=%g", for example
	Variable negPos= strsearch(str,"-",0)
	
	strswitch( labelSigns )
		case " + and -":		// add + if missing
			if( value > 0 && plusPos < 0 )	// it's missing
				str[digitPos]= "+"			// insert + just before digit
			endif			
			if( value < 0 && negPos < 0 )	// it's missing, can't imagine why
				str[digitPos]= "-"			// insert - just before digit
			endif			
			break
		case " no signs":
			if( plusPos >= 0 )
				str[plusPos,plusPos]= ""	// deletes +
			endif
			if( negPos >= 0 )
				str[negPos,negPos]= ""		// deletes -
			endif
			break
		default:		// " - only" is the default for formats like %g
			if( value > 0 && plusPos >= 0  )
				str[plusPos,plusPos]= ""	// deletes +
			endif			
			if( value < 0 && negPos < 0 )	// it's missing, can't imagine why
				str[digitPos]= "-"			// insert - just before digit
			endif			
			break
	endswitch

	return str
End

Function WMPolarFirstDigitPos(str)
	String str
	
	Variable pos= -1	// no digits found
	Variable i=0
	Variable len= strlen(str)
	for( i=0; i < len; i+=1)
		Variable  charNum= char2Num(str[i,i])
		if( charNum >= char2num("0") && charNum <= char2num("9") ) // a digit
			pos= i
			break;
		endif
	endfor
	return pos
End

Function WMPolarDegreesOrFractionOfPi(angleInRadians,wantFractionOfPi)
	Variable angleInRadians,wantFractionOfPi
	
	angleInRadians= WMPolarStraightenAngle(angleInRadians)
	
	Variable value= WMPolarRadToDeg(angleInRadians)	// degrees
	
	if( wantFractionOfPi ) 	// no-one prints radians, they print pi/2 or 0.5 º, and we expect the º to be in the format
		value /= 180	
	endif
		
	return value
End
	
//returns 1 if angle is within the given range, else 0
Function WMPolarAngleInRange(angle,angle0,angleRange)
	Variable angle,angle0,angleRange
	
	// reduce angle and angle0 to 0...4*Pi range
	Variable twoPi=2*Pi
	Variable lastAngle
	Variable eps=Pi/3600	// half a second

	if( abs(angleRange) >= twoPi)
		return 1
	endif

	Variable inRange
	angle= mod(angle,twoPi)
	if( angle < 0 )
		angle += twoPi
	endif
	angle0= mod(angle0,twoPi)
	if( angle0 < 0 )
		angle0 += twoPi
	endif
	lastAngle= angle0+angleRange
	if( angleRange > 0 )
		inRange= abs(angle- limit(angle,angle0,lastAngle)) < eps
		if( (!inRange) && (lastAngle >= twoPi ) )
			inRange= abs(angle+twoPi -  limit(angle+twoPi,angle0,lastAngle)) < eps
		endif
	else
		inRange= abs(angle - limit(angle,lastAngle,angle0)) < eps
		if( (!inRange) && (lastAngle <= 0 ) )
			inRange= abs(angle-twoPi -  limit(angle-twoPi,lastAngle,angle0)) < eps
		endif
	endif

	return inRange
End

// returns 0 or Pi to produce parallel ticks.
// 0 causes labels to be drawn outside of axis;
// Pi causes labels to be drawn inside of axis.
//
// based on AngleTickOrientation
//
Function WMPolarAngleTickOrientation(graphName, radius,drawnRadius,valueAtCenter,radiusStart,labelLenAndOffset)	// someday add another param for user setting
	String graphName
	Variable radius				// the data radius for this axis
	Variable drawnRadius		// the radius at which the axis is drawn
	Variable valueAtCenter		// the radius data value at the drawn center, usually zero
	Variable radiusStart		// starting radius as entered by the user, not fudged by RadiiForAngleAxes
	Variable labelLenAndOffset	// label length plus label offset in points

	// we will assume that the most often labelled angle axes are the start and/or end radiuses
	// In the absence of a user setting for selection of where the labels will be drawn,
	// we choose to label axes usually on the outside of the axis.
	// However, when
	//	the radiusStart > valueAtCenter,
	//	AND radius == radiusStart,
	//	AND we believe there is room for the labels inside the radius,
	//	THEN the labels are on the inside of the axis.
	// The check for room inside the radius is rather crude.

	Variable tickOrient=0		// defaults to outside of axis	
	if( radiusStart > valueAtCenter)	// horizontal axis
		Variable approxRadius=radius,approxRadiusStart=radiusStart // single precision for equality testing
		if (approxRadius == approxRadiusStart )
			Variable roomToLabel= (WMPolarPointsToDrawn(graphName,labelLenAndOffset) < drawnRadius)
			if( roomToLabel )
				tickOrient= Pi			// inside axis
			endif
		endif
	endif
	return tickOrient
End

// numMinorTicks=
Function WMPolarTicksForRadius(radius,angleMinorTicks,wAdjustedRadii)
	Variable radius
	Variable angleMinorTicks
	Wave wAdjustedRadii	// indexed by mod(i,angleTicks+1), where i is the minor tick number, from 1 to angleMinorTicks
	
	// return the number of adjusted (starting) radii that are less than radius
	Variable numMinorTicks=0,i=1
	if( angleMinorTicks > 0 )
		do
			if(  wAdjustedRadii[i] < radius )
				numMinorTicks+= 1
			endif
			i += 1
		while(i <=  angleMinorTicks)
	endif
	return numMinorTicks
End
	
// Returns FREE wave containing the list of radii at which to draw angle (circle/arc) axes.
// All calculations are in data coordinates, NOT drawn coordinates.
// Assumes we are in the current polar graph's data folder.
Function/WAVE WMPolarRadiiForAngleAxes(radiusStart,radiusEnd,radiusInc,minorRadiusTicks)
	Variable radiusStart,radiusEnd,radiusInc,minorRadiusTicks

	String radiiList=""
	Variable radius

	//SVAR angleAxesWhere		// one of: "Off;Radius Start;Radius End;Radius Start and End;All Major Radii;At Listed Radii;"
	String angleAxesWhere= WMPolarGetCleanedStr("angleAxesWhere",WMPolarAngleAxisAtPopup())

	NVAR firstMajorRadiusTick
	NVAR lastMajorRadiusTick
	NVAR valueAtCenter
	Variable numAngleAxes
	Variable firstRadius=radiusStart					// in case radiusStart is valueAtCenter

	// disallow an angle axis at the center (r=0)
	if( abs(valueAtCenter-radiusStart) < radiusInc/2 )
		firstRadius= firstMajorRadiusTick
		if( abs(valueAtCenter-firstRadius) < radiusInc/2 )
			firstRadius= firstMajorRadiusTick+radiusInc
		endif
		radiusStart=NaN
	endif

	// Remove legacy waves in the current polar graph's data folder.
	KillWaves/Z wAxisRadii
	Make/O/N=0/D/FREE wAxisRadii

	strswitch( angleAxesWhere )
		default:
		case "Off":
			break	
		case "Radius Start":
			if( numtype(radiusStart) == 0 ) // not NaN nor +/-Inf
				wAxisRadii= {radiusStart}
			endif
			break	
		case "Radius End":
			wAxisRadii= {radiusEnd}
			break	
		case "Radius Start and End":	// (excepting valueAtCenter)
			if( numtype(radiusStart) != 0 ) // radiusStart is NaN or +/-Inf, skip it
				wAxisRadii= {radiusEnd}
			else
				wAxisRadii= {radiusStart,radiusEnd}
			endif
			break
		case "All Major Radii":	//  (excepting valueAtCenter)
			numAngleAxes = trunc((min(radiusEnd,lastMajorRadiusTick)-firstMajorRadiusTick) / radiusInc + 1)
			Redimension/N=(numAngleAxes) wAxisRadii
			wAxisRadii= firstMajorRadiusTick + p * radiusInc
			break
		case "At Listed Radii":	// list of radii, for example "1,2,3"
			SVAR radList= angleAxesRadiusList
			numAngleAxes= ItemsInList(radList,",")
			Redimension/N=(numAngleAxes) wAxisRadii
			Variable i
			String str
			for( i=0; i < numAngleAxes; i+=1 )
				str = StringFromList(i,radList,",")
				wAxisRadii[i]=str2num(str)
			endfor
			break
	endswitch
	WaveTransform zapNaNs wAxisRadii	// 6.33

	return wAxisRadii
End

// Draws radius axes (the "spokes").
//
// All angles are in data coordinates and radians
// radii are in data coordinates,
// and x and y are in drawn coordinates.
//
// Assumes we are in the current polar graph's data folder.
//
Function WMPolarRadiusAxes(graphName,radiusStart,radiusEnd,radiusInc,radiusMinorTicks,wAxisAngles,angle0Draw, angleRangeDraw,x0Drawn,y0Drawn,xMinDrawn, xMaxDrawn, yMinDrawn, yMaxDrawn)
	String graphName
	Variable radiusStart,radiusEnd			// axis range (data coordinates) NOT the tick range and NOT the tick label range.
	Variable radiusInc,radiusMinorTicks	// radiusMinorTicks == 0 if none
	Wave wAxisAngles						// angles, in radians (data coordinates).
	Variable angle0Draw, angleRangeDraw	// angle range in drawn coordinates
	Variable x0Drawn,y0Drawn				// axis origin, usually 0,0
	Variable xMinDrawn, xMaxDrawn, yMinDrawn, yMaxDrawn	// plot extent in drawn coordinates
	
	Variable numRadiusAxes= numpnts(wAxisAngles)
	if( numRadiusAxes <= 0  )
		return 0
	endif

	// label range (NOT the tick range)
	Variable radiusLabelStart= -inf	// assume "Label Entire Radius Range"
	Variable radiusLabelEnd= inf
	Variable omitOrigin= 0			// assume we'll label the origin, too
	Variable centerLabeled=0		// though we haven't done it, yet.
	NVAR doRadiusTickLabelSubRange
	if( doRadiusTickLabelSubRange )
		NVAR radiusTickLabelRangeStart, radiusTickLabelRangeEnd
		radiusLabelStart= radiusTickLabelRangeStart
		radiusLabelEnd= radiusTickLabelRangeEnd
	else	// perhaps we omit the origin
		NVAR radiusTickLabelOmitOrigin
		omitOrigin= radiusTickLabelOmitOrigin
	endif
	
	// same minor tick calculations as WMPolarGrid()
	// tick range
	NVAR firstMajorRadiusTick
	NVAR lastMajorRadiusTick

	radiusInc= abs(radiusInc)
	radiusMinorTicks=round(abs(radiusMinorTicks))

	Variable deltaRadius=radiusInc
	Variable numMinorTicks=0
	if( radiusMinorTicks > 0 )
		deltaRadius= radiusInc/(radiusMinorTicks+1)
		numMinorTicks=floor(1+ (radiusMinorTicks+1) * abs((radiusEnd-radiusStart)/radiusInc)) // total ticks for entire axis
	endif

	// find radius of first minor tick= firstMajorRadiusTick - n * deltaRadius, n <= numMinorTicks
	Variable firstMinorTick= firstMajorRadiusTick + deltaRadius	// for radius
	Variable firstMinorTickIndex = 1		// for ti
	
	if( numMinorTicks > 0 && deltaRadius != 0 )
		Variable minorIncsBeforeMajorTick= floor((firstMajorRadiusTick - radiusStart) / deltaRadius)	// positive number
		if( minorIncsBeforeMajorTick != 0 )
			firstMinorTickIndex= -minorIncsBeforeMajorTick 		// initial negative number for ti
			firstMinorTick = firstMajorRadiusTick + firstMinorTickIndex * deltaRadius
			numMinorTicks=floor(1+ (radiusMinorTicks+1) * abs((radiusEnd-firstMinorTick)/radiusInc)) // total ticks for ticked axis
		endif
	endif

	// these globals accumulate a rectangle that encompasses grids, axes, and axis labels
	NVAR fullXMinDrawn, fullXMaxDrawn, fullYMinDrawn, fullYMaxDrawn
	Variable fxMin=fullXMinDrawn
	Variable fxMax=fullXMaxDrawn
	Variable fyMin=fullYMinDrawn
	Variable fyMax=fullYMaxDrawn

	SVAR radiusFunction
	NVAR valueAtCenter
	
	// spokes run from radStartDraw to radEndDraw
	Variable radStartDraw=WMPolarRadiusFunction(radiusStart,radiusFunction,valueAtCenter)
	Variable radEndDraw=WMPolarRadiusFunction(radiusEnd,radiusFunction,valueAtCenter)

	NVAR majorTickLength
	Variable majTickLen= WMPolarPointsToDrawn(graphName,majorTickLength)

	NVAR minorTickLength
	Variable minTickLen= WMPolarPointsToDrawn(graphName,minorTickLength)

	NVAR radiusTickLabelOffset
	Variable lblOffset= WMPolarPointsToDrawn(graphName,radiusTickLabelOffset)

	// major ticks
	SVAR tickWhere= radiusTicksLocation		// "Off;Crossing;Inside;Outside"
	Variable doMajorTicks= CmpStr(tickWhere,"Off") != 0	

	NVAR doRadiusTickLabels	// master on/off flag for radius tick labels BUT NOT the tick marks themselves.
	NVAR majorTickThick, minorTickThick
	NVAR zeroAngleWhere	// was popup code, now degrees (0 == right, 90=top, etc)
	NVAR angleDirection	// was popup code, "clockwise;counter-clockwise", now 1 for clockwise, -1 for counter-clockwise.

	SVAR radiusTickLabelRotation
	Variable lblOrientDegrees= str2num(radiusTickLabelRotation)
	Variable radiusTickLabelRotRadians= WMPolarDegToRad(lblOrientDegrees)
	
	SVAR fmt=radiusTickLabelNotation
	SVAR labelSigns= radiusTickLabelSigns

	SVAR tickLabelFontName
	NVAR tickLabelFontSize
	Variable fontBold= NumVarOrDefault("tickLabelFontBold", 0)
	Variable fontItalic= NumVarOrDefault("tickLabelFontItalic", 0)
	Variable fontStyle = (fontItalic * 2) + fontBold

	String drawLayer = WMPolarGraphCurrentDrawLayer(graphName)
	Variable usingVirtualLayers = strlen(drawLayer)
	if( usingVirtualLayers )
		WMPolarSwitchDrawLayer(graphName, drawLayer)
		// next things drawn insert into the polarAxes virtual layer before gstop command
		StartAppendToVirtualLayer(graphName, drawLayer, "polarAxes")
	else
		SetDrawLayer/W=$graphName $ksPolarLayerAxisLabels
		SetDrawEnv/W=$graphName xcoord= HorizCrossing,ycoord= VertCrossing,textxjust=1,textyjust=1,save
		SetDrawEnv/W=$graphName fname=(tickLabelFontName), fsize=tickLabelFontSize, fstyle=fontStyle, save

		SetDrawLayer/W=$graphName $ksPolarLayerAxes
	endif

	SetDrawEnv/W=$graphName xcoord= HorizCrossing,ycoord= VertCrossing,textxjust=1,textyjust=1,save
	SetDrawEnv/W=$graphName fname=(tickLabelFontName), fsize=tickLabelFontSize, fstyle=fontStyle, save

	Variable labelHeight = FontSizeHeight(tickLabelFontName,tickLabelFontSize,0)	// points
	NVAR tickLabelOpaque

	NVAR radiusAxisColorRed,radiusAxisColorGreen,radiusAxisColorBlue,radiusAxisThick
	Variable radiusAxisColorAlpha= NumVarOrDefault("radiusAxisColorAlpha", 65535)

	SetDrawEnv/W=$graphName linefgc=(radiusAxisColorRed,radiusAxisColorGreen,radiusAxisColorBlue,radiusAxisColorAlpha)
	SetDrawEnv/W=$graphName linebgc=(radiusAxisColorRed,radiusAxisColorGreen,radiusAxisColorBlue,radiusAxisColorAlpha)
	SetDrawEnv/W=$graphName dash= 0,fillpat=0, save

	Variable maxThick= max(max(radiusAxisThick,majorTickThick),minorTickThick) // points
	maxThick= WMPolarPointsToDrawn(graphName,maxThick)

	Variable boxMargin= max(majTickLen,minTickLen)	// drawn coordinates
	boxMargin += maxThick

	// draw each spoke
	Variable visible,radius,radiusDraw,x1,y1,x2,y2,cosAngle,sinAngle,angleData,angleDraw,lastAngle,thick,inhibited,tickOrient
	Variable maj,ti
	Variable tx,ty	// endpoint of tick mark opposite the tick label, in drawn coordinates.
	Variable lx,ly 	// label anchor position in drawn coordinates
	
	Variable angleIndex=0	// was a
	do
		SetDrawEnv/W=$graphName linethick=radiusAxisThick, save	// reset line thickness for axis thick (the tick thick is different)

		angleData= wAxisAngles[angleIndex]
		angleDraw= WMPolarAngleFunction(angleData,zeroAngleWhere,angleDirection,2*pi) // convert data angle (radians) in wAxisAngles to drawn angle
		angleDraw= WMPolarStraightenAngle(angleDraw)
		
		cosAngle= cos(angleDraw)
		sinAngle= sin(angleDraw)

		// tick label orientation
		// WMPolarRadiusTickOrientation returns +/- Pi/2 to produce perpendicular ticks.
		tickOrient= WMPolarRadiusTickOrientation(angleDraw,angle0Draw, angleRangeDraw)	// unrotated tick label angle in radians
		// modify according to user selection
		tickOrient += radiusTickLabelRotRadians	// -90 degrees (-Pi/2), for example, causes labels to be drawn more clockwise

		// draw a "spoke" from radStartDraw to radEndDraw
		x1= x0Drawn + radStartDraw * cosAngle
		y1= y0Drawn + radStartDraw * sinAngle
		x2= x0Drawn + radEndDraw * cosAngle
		y2= y0Drawn + radEndDraw * sinAngle
		
		// Make sure autoscale encloses the radius axis and its tick marks as well.
		Variable boxMinX= min(x1,x2)-boxMargin
		Variable boxMaxX=max(x1,x2)+boxMargin
		Variable boxMinY= min(y1,y2)-boxMargin
		Variable boxMaxY=max(y1,y2)+boxMargin
		WMPolarUnionRects(fxMin, fyMin, fxMax, fyMax, boxMinX, boxMinY, boxMaxX, boxMaxY)

if( kPolarShowRects )
	SetDrawEnv/W=$graphName fillpat=0, linethick=1
	DrawRect/W=$graphName boxMinX, boxMinY, boxMaxX, boxMaxY		// left, top, right, bottom
endif
		
		visible= WMPolarDrawClippedLineSize(graphName,x1,y1,x2,y2,xMinDrawn, xMaxDrawn, yMinDrawn, yMaxDrawn,radiusAxisThick)	// 0 if invisible, 1 if not clipped, 2 if only x1,y1 clipped, 3 or 4 if x2,y2 clipped

		// Draw Tick marks, if turned on, and within the allowable range
		// Draw major tick labels if within the allowable range and if doRadiusTickLabels is true
		if( visible && (doMajorTicks || doRadiusTickLabels) )
			// Minor Ticks
			// numMinorTicks == 0 if  doMinorRadiusTicks is false
			// don't draw minor ticks if major ticks aren't drawn (don't draw minor ticks if we're only drawing tick labels)
			if( numMinorTicks > 0 && doMajorTicks )
				SetDrawEnv/W=$graphName linethick=minorTickThick,save
				ti= firstMinorTickIndex		// 1 if radiusStart == firstMajorRadiusTick
				radius= firstMinorTick		// radiusStart+deltaRadius if radiusStart == firstMajorRadiusTick
				do
					radiusDraw= WMPolarRadiusFunction(radius,radiusFunction,valueAtCenter)  // drawn radius
					visible= WMPolarDrawTick(graphName,radiusDraw,angleDraw,x0Drawn,y0Drawn,minorTickThick,minTickLen,0,tickOrient,tickWhere,tx,ty,lx,ly,xMinDrawn, xMaxDrawn, yMinDrawn, yMaxDrawn)
					ti += 1
					if( mod(ti,radiusMinorTicks+1)==0 )	// we skip the major radii, to avoid two ticks at the same location
						ti += 1
					endif
					radius = firstMajorRadiusTick + ti * deltaRadius	// data radius
				while( ti <  numMinorTicks && radius < radiusEnd )
			endif
			// Major Ticks (and/or tick labels)
			radius= firstMajorRadiusTick
			maj=0
			SetDrawEnv/W=$graphName linethick=majorTickThick,save
			do	// Major Ticks
				// no major tick at center if there is more than one axis
				inhibited=radius < valueAtCenter		// don't use sloppy compare for this; any value < center shouldn't be labelled.
				if( !inhibited ) // labelling okay if the radius exceeds valueAtCenter
					Variable sloppyDiff=WMPolarSloppyCompare(radius,valueAtCenter,radiusInc/4)
					if( sloppyDiff == 0 )	// at or near origin, sometimes we don't label
						if( 	omitOrigin )
							inhibited= 1
						else
							inhibited = centerLabeled == 1	// only first center value is labelled.
							centerLabeled= 1				// after LabelTick, the center is labelled (or never will be)
						endif
					endif
				endif
				inhibited = inhibited || (radius< radiusLabelStart) || (radius> radiusLabelEnd)
				thick= (inhibited || !doMajorTicks) ? 0 : majorTickThick	// 0 thickness just computes the tick label anchor into lx, ly
				radiusDraw= WMPolarRadiusFunction(radius,radiusFunction,valueAtCenter)  // drawn radius
				visible= WMPolarDrawTick(graphName,radiusDraw,angleDraw,x0Drawn,y0Drawn,thick,majTickLen,lblOffset,tickOrient,tickWhere,tx,ty,lx,ly,xMinDrawn, xMaxDrawn, yMinDrawn, yMaxDrawn)

				if( doRadiusTickLabels && (!inhibited) )
					if( usingVirtualLayers )
						EndAppendToVirtualLayer(graphName, drawLayer, "polarAxes", 1)
						StartAppendToVirtualLayer(graphName, drawLayer, "polarAxisLabels")
						SetDrawEnv/W=$graphName fname=(tickLabelFontName), fsize=tickLabelFontSize, fstyle=fontStyle, save
					else
						SetDrawLayer/W=$graphName $ksPolarLayerAxisLabels
					endif

					WMPolarLabelTick(graphName,visible,lx,ly,radius,fmt,labelSigns,tickLabelFontName,tickLabelFontSize,labelHeight,tickLabelOpaque,lblOrientDegrees,angleDraw+tickOrient,fxMin, fxMax, fyMin, fyMax)

					if( usingVirtualLayers )
						EndAppendToVirtualLayer(graphName, drawLayer, "polarAxisLabels", 1)
						StartAppendToVirtualLayer(graphName, drawLayer, "polarAxes")
					else
						SetDrawLayer/W=$graphName $ksPolarLayerAxes
					endif
				endif
				maj += 1
				radius = firstMajorRadiusTick + maj * radiusInc
				Variable keepGoing= WMPolarSloppyCompare(radius,lastMajorRadiusTick,radiusInc/4) <= 0		// positive if radius bigger than lastMajorRadiusTick
				keepGoing= keepGoing && WMPolarSloppyCompare(radius,radiusEnd,radiusInc/4) <= 0
			while( keepGoing )
		endif
		angleIndex+= 1
	while(angleIndex< numRadiusAxes )

	if( usingVirtualLayers )
		EndAppendToVirtualLayer(graphName, drawLayer, "polarAxes", 1)
	endif
	
	fullXMinDrawn= fxMin
	fullXMaxDrawn= fxMax
	fullYMinDrawn= fyMin
	fullYMaxDrawn= fyMax
End

Function WMPolarSloppyCompare(v1,v2,slop)
	Variable v1,v2	// the numbers to compare
	Variable slop		// if the difference is < slop, they're equal
	
	Variable diff= v1-v2		// positive if v1 bigger, negative if v2 bigger
	if( abs(diff) < abs(slop) )
		return 0 				// approximately equal
	endif
	return diff
End

Function [Variable length, Variable height] WMPolarStringSizesinPoints(String font, Variable fontSize, Variable style, String str)

	
	length = FontSizeStringWidth(font,fontSize,style,str)	// points
	height = FontSizeHeight(font,fontSize,style)			// points

	// break str into lines on \r
	Variable numLines = ItemsInList(str,"\r")
	if( numLines > 1 ) // we have multiple lines. Not sure what happens if string ENDs with a bare \r, though.
		length = 0	// find the max length
		Variable i, lineHeight = height;
		height = 0;
		for(i=0; i<numLines; i+=1 )
			String line= StringFromList(i,str,"\r")
			Variable lineLength = FontSizeStringWidth(font,fontSize,style,line)	// points
			if( lineLength > length )
				length = lineLength
			endif
			height += lineHeight
		endfor
	endif
End

#define SHADOW

// multi-line labels fixed in version 9.02
// optional shadow added in version 9.03
Function/S WMPolarLabelTick(graphName,visible,x0,y0,labelVal,fmt,labelSigns,font,fontSize,labelHeight,opaque,lblOrient,tickAngle,xmin,xmax,ymin,ymax)
	String graphName
	Variable visible	// 0 if we're only computing the rectangle and accumulating it into xmin, xmax, ymin, ymax
	Variable x0,y0	// position of label anchor in drawn polar coordinates
	Variable labelVal
	String fmt				// "%g" for labelVal
	String labelSigns		// see WMPolarFormatNumber
	String font
	Variable fontSize
	Variable labelHeight		// = FontSizeHeight(font,fontSize,0) (points)
	Variable opaque			// if true, draw a filled rect behind the label using the graph's plot area color, which is in plotAreaRed, plotAreaGreen, plotAreaBlue
	Variable lblOrient		// label orientation in degrees, ala DrawText
	Variable tickAngle		// angle tickmark is drawn at, angle measured from far end toward tick label end
	Variable &xmin,&xmax,&ymin,&ymax	// grows this rectangle (in drawn coordinates) to include the drawn tick label

	String str= WMPolarFormatNumber(labelVal, fmt, labelSigns)

	Variable cosAngle=cos(tickAngle)
	Variable sinAngle=sin(tickAngle)
	// adjust x0, y0 based on  label size

	// compute label rect whether it was drawn or not, assuming textxjust=1 and textyjust=1 (middle center)
	Variable labelLen
	[labelLen, labelHeight] = WMPolarStringSizesinPoints(font, fontSize, 0, str) // fontSize in points, thus len and height are in points (they might not scale exactly)
	if( mod(lblOrient,90)  > 45 )		// vertical label
		Variable tmp=  labelLen
		labelLen= labelHeight
		labelHeight= labelLen
	endif
	labelLen= WMPolarPointsToDrawn(graphName,labelLen+2)			// 1 point halo
	labelHeight= WMPolarPointsToDrawn(graphName,labelHeight+2)

	Variable xMinLabel= x0 - labelLen/2
	Variable xMaxLabel= xMinLabel + labelLen

	Variable yMinLabel= y0 - labelHeight/2
	Variable yMaxLabel= yMinLabel + labelHeight

	// accumulate label rectangle into the autoscale rectangle.
	WMPolarUnionRects(xMin, yMin, xMax, yMax, xMinLabel, yMinLabel, xMaxLabel, yMaxLabel)

	if( visible )
		if( opaque )	// backing rectangle to make the label opaque
			NVAR plotAreaRed, plotAreaGreen, plotAreaBlue	// the opaque color, set by calling routine
			SetDrawEnv/W=$graphName fillpat=1, linethick=0, fillfgc=(plotAreaRed, plotAreaGreen, plotAreaBlue)
			DrawRect/W=$graphName xMinLabel, yMinLabel, xMaxLabel, yMaxLabel		// left, top, right, bottom
		endif
		NVAR tickLabelRed,tickLabelGreen,tickLabelBlue
		Variable tickLabelAlpha= NumVarOrDefault("tickLabelAlpha",65535)
		Variable shadowedTickLabel = WMPolarGraphGetVarOrDefault(graphName,"shadowedTickLabel",0)
		if( shadowedTickLabel )
			// default is shadow down and to the right by 2 points, blurred over 4 points
			Variable shadowXOffset= WMPolarGraphGetVarOrDefault(graphName,"shadowXOffset",2) 	// points
			Variable shadowYOffset= WMPolarGraphGetVarOrDefault(graphName,"shadowYOffset",2)	// points
			Variable shadowBlur= WMPolarGraphGetVarOrDefault(graphName,"shadowBlur",4)			// points
			if( shadowBlur == 0 )
				shadowedTickLabel = 0 // draw an offset copy of the label instead of a shadow
			endif
			// default is black shadow
			Variable shadowRed= WMPolarGraphGetVarOrDefault(graphName,"shadowRed",0)		// 0..65535
			Variable shadowGreen= WMPolarGraphGetVarOrDefault(graphName,"shadowGreen",0)
			Variable shadowBlue= WMPolarGraphGetVarOrDefault(graphName,"shadowBlue",0)
			Variable shadowAlpha= WMPolarGraphGetVarOrDefault(graphName,"shadowAlpha",22000)	// full opaque is 65535
			if( shadowedTickLabel )
				SetDrawEnv/W=$graphName beginShadow= {shadowXOffset,shadowYOffset,shadowBlur,(shadowRed,shadowGreen,shadowBlue,shadowAlpha)}
			else
				shadowXOffset= WMPolarPointsToDrawn(graphName,shadowXOffset) // drawn coordinates
				shadowYOffset= WMPolarPointsToDrawn(graphName,shadowYOffset) // drawn coordinates
				SetDrawEnv/W=$graphName textxjust=1,textyjust=1,textrgb=(shadowRed,shadowGreen,shadowBlue,shadowAlpha),textrot=lblOrient	// middle center
				DrawText/W=$graphName x0+shadowXOffset,y0-shadowYOffset,str
			endif
		endif
		SetDrawEnv/W=$graphName textxjust=1,textyjust=1,textrgb=(tickLabelRed,tickLabelGreen,tickLabelBlue,tickLabelAlpha),textrot=lblOrient	// middle center
		DrawText/W=$graphName x0,y0,str
		if( shadowedTickLabel )
			SetDrawEnv/W=$graphName endShadow
		endif
	endif

	if( kPolarShowRects )
		SetDrawEnv/W=$graphName fillpat=0, linethick=1
		DrawRect/W=$graphName xMinLabel, yMinLabel, xMaxLabel, yMaxLabel		// left, top, right, bottom
	endif

	return str
End


Function WMPolarSignRange(val,slop)	// three-valued sign function with +/- slop around zero
	Variable val,slop
	
	if( abs(val) > abs(slop))
		val= sign(val)
	else
		val=0
	endif
	return val
End


// On output, tx, ty is location of the far (unlabeled) end of the tickmark.
// and lx, ly is the (possibly offset) location of the near (labeled) end of the tickmark; the label anchor goes here.
// returns visible
Function WMPolarDrawTick(graphName,radius,angle,x0Drawn,y0Drawn,lineThick,ticklen,lblOffset,tickOrient,tickWhere,tx,ty,lx,ly,xmin,xmax,ymin,ymax)
	String graphName
	Variable radius,angle		// position of tick mark in drawn polar coordinates
	Variable x0Drawn,y0Drawn	// origin of radius,angle. Usually 0,0, but will be different if a Left or Bottom Radius axis
	Variable lineThick			// points; if zero, don't actually draw it, just compute the tick label position
	Variable ticklen				// in drawn coordinates
	String tickWhere			// "Crossing", "Inside", or "Outside", CURRENTLY UNUSED
	Variable lblOffset			//  in drawn coordinates, included in lx, ly output.
	Variable tickOrient			// add this to angle to set the tickmark orientation, 0 or Pi for parallel, +/-Pi/2 for perpendicular
	Variable &tx, &ty			// OUTPUT: location of the unlabelled end of the tickmark.
	Variable &lx, &ly			// OUTPUT: the (possibly offset) location of the labelled end of the tickmark; the label anchor goes here.
	Variable xmin,xmax,ymin,ymax	// plot extent in drawn coordinates

	Variable halfTick=ticklen/2
	
	Variable cosAngle= cos(angle)
	Variable sinAngle= sin(angle)
	tx= x0Drawn + radius * cosAngle
	ty= y0Drawn + radius * sinAngle 		// position of tick on axis

	angle += tickOrient			// tick mark angle
	cosAngle= cos(angle)
	sinAngle= sin(angle)
	
	// far end (unlabelled) crossing tick mark calculations
	strswitch(tickWhere)
		case "Outside":
			break
		default:		// "Crossing" or error
			tx -= cosAngle * halfTick
			ty -= sinAngle * halfTick
			break;
		case "Inside":
			tx -= cosAngle * ticklen
			ty -= sinAngle * ticklen
			break
	endswitch
	// Given far end, calculate near (labelled) end
	lx= tx+cosAngle * ticklen
	ly= ty+sinAngle * ticklen
	// Draw the tick mark (if lineThick != 0)
	Variable visible= WMPolarDrawClippedLineSize(graphName,tx,ty,lx,ly,xmin,xmax,ymin,ymax,lineThick)
	// Apply label standoff
	lx += cosAngle * lblOffset
	ly += sinAngle * lblOffset
	return visible
End



// Returns +/- Pi/2 to produce perpendicular ticks.
// -Pi/2 causes labels to be drawn clockwise of the axis;
// +Pi/2 causes labels to be drawn counter-clockwise of the axis.
Function WMPolarRadiusTickOrientation(axisAngle,angle0Draw, angleRangeDraw)
	Variable axisAngle		// the angle at which this particular axis will be drawn (in drawn coordinates)
	Variable angle0Draw, angleRangeDraw
	
	// we will assume that the most often labelled radius axes are the four standard axes at 0,90,180,-90
	// In the absence of a user setting for selection of where the labels will be drawn,
	// we choose to label axes to the left of vertical axes, and below horizontal axes
	// horizontal axes to the left of x==0 are labelled ccw (+Pi/2), right of x==0 are labelled cw (-Pi/2) 
	// vertical axes above the y==0 line are labelled ccw (+Pi/2), below the line are labelled cw (-Pi/2)
	Variable tickOrient
	Variable sinAngle=sin(axisAngle)
	Variable cosAngle=cos(axisAngle)
	Variable sincos45=sin(Pi/4)
	Variable ccw=Pi/2

		//SVAR radiusAxesWhere	// the case values must match those returned by WMPolarRadiusAxisAtPopup()
		String radiusAxesWhere= WMPolarGetCleanedStr("radiusAxesWhere",WMPolarRadiusAxisAtPopup())	//	Version 6.33: cleans up user-entered values of radiusAxesWhere to match expected choices
		strswitch( radiusAxesWhere )
			case "  Left":	// vertical axes, labels on left
				tickOrient= (sinAngle > 0) ? ccw : -ccw
				break
			case "  Right":	// vertical axes, labels on right
				tickOrient= (sinAngle < 0) ? ccw : -ccw
				break
			case "  Top":		// horizontal axes, labels on top
				tickOrient= (cosAngle > 0) ? ccw : -ccw
				break
			case "  Bottom":	// horizontal axes, labels on bottom
				tickOrient= (cosAngle < 0) ? ccw : -ccw
				break
			default:
				if( abs(sinAngle) <= sincos45 )	// horizontal axis
					tickOrient= (cosAngle > 0) ? -ccw : ccw
				else	// vertical axis
					tickOrient= (sinAngle > 0) ? ccw : -ccw	// above y==0, label counter-clockwise
				endif
				// if the chosen orientation puts the tick label inside the grid, use the other orientation (unless it also puts the tick labels in the grid)
				Variable angleInc= tickOrient/3		// 30 degrees in direction of where the labels will be drawn
				Variable tickLabelsWouldBeInsideGrid=  WMPolarAngleInRange(axisAngle+angleInc,angle0Draw, angleRangeDraw)
				if( tickLabelsWouldBeInsideGrid )	// if the chosen orientation puts the tick label inside the grid
					tickLabelsWouldBeInsideGrid=  WMPolarAngleInRange(axisAngle-angleInc,angle0Draw, angleRangeDraw)
					if( !tickLabelsWouldBeInsideGrid )	// and the other orientation wouldn't put the tick labels inside the grid
						tickOrient = - tickOrient		// use the other orientation
					endif				
				endif

				break
		endswitch

	return tickOrient
End



// Returns FREE wave containing the list of angles at which to draw radius (line) axes.
// All calculations are in data coordinates, NOT drawn coordinates.
// Assumes we are in the current polar graph's data folder.
Function/WAVE WMPolarAnglesForRadiusAxes(angle0,angleRange,angleInc,angleMinorTicks)
	Variable angle0,angleRange,angleInc,angleMinorTicks

	String angleList=""
	Variable lastAngle= angle0 + angleRange
	Variable numRadiusAxes	

	// Remove legacy waves in the current polar graph's data folder.
	KillWaves/Z wAxisAngles
	Make/O/N=0/D/FREE wAxisAngles
	
//	SVAR radiusAxesWhere	// the case values must match those returned by WMPolarRadiusAxisAtPopup()
	String radiusAxesWhere= WMPolarGetCleanedStr("radiusAxesWhere",WMPolarRadiusAxisAtPopup()) //	Version 6.33: cleans up user-entered values of radiusAxesWhere to match expected choices
//	String pop= "  Off;  Angle Start;  Angle Middle;  Angle End;  Angle Start and End;"		// 1-5
//	pop +="  0;  90;  180; -90;"																// 6-9
//	pop +="  0, 90;  90, 180; -180, -90; -90, 0;  0, 180;  90, -90;  0, 90, 180, -90;"	// 10-16
//	pop +="  Left; Bottom;"												// 17-18 (these need an "at radius=" value)
//	pop +="  All Major Angles;  At Listed Angles"												// 19-20

	SVAR radiusAxesHalves					// "Upper Half;Lower Half;Both Halves" or ";Left Half;Right Half;Both Halves"

	// Because the output is in data angles, yet the designations "Upper Half", "Left", etc are really in DRAWN coordinates.
	// we need to create data angles (in radians) from drawn coordinates.
	NVAR zeroAngleWhere				// 0 = right, 90 = top, 180 = left, -90 = bottom
	NVAR angleDirection				// 1 == clockwise, -1 == counter-clockwise"
	Variable dataAngleUp= WMPolarAngleFunctionInv(pi/2,zeroAngleWhere,angleDirection,2*pi)	// radians
	Variable dataAngleDown=WMPolarAngleFunctionInv(-pi/2,zeroAngleWhere,angleDirection,2*pi)
	Variable dataAngleLeft= WMPolarAngleFunctionInv(pi,zeroAngleWhere,angleDirection,2*pi)
	Variable dataAngleRight=WMPolarAngleFunctionInv(0,zeroAngleWhere,angleDirection,2*pi)
	
	strswitch( radiusAxesWhere )
		case "  Off":
			break
		// 17-18 (these need an "at radius=" value, and aren't drawn from the origin)
		case "  Left":
		case "  Right":
			strswitch( radiusAxesHalves )
				case "Upper Half":
					wAxisAngles= {dataAngleUp}
					break
				case "Lower Half":
					wAxisAngles= {dataAngleDown}
					break
				default:
					wAxisAngles= {dataAngleUp,dataAngleDown}
					break
			endswitch
			break
		case "  Top":
		case "  Bottom":
			strswitch( radiusAxesHalves )
				case "Left Half":
					wAxisAngles= {dataAngleLeft}
					break
				case "Right Half":
					wAxisAngles= {dataAngleRight}
					break
				default:
					wAxisAngles= {dataAngleLeft,dataAngleRight}
					break
			endswitch
			break
		case "  Angle Start":
			wAxisAngles= {angle0}
			break
		case "  Angle Middle":
			wAxisAngles= {angle0+angleRange/2}
			break
		case "  Angle End":
			wAxisAngles= {lastAngle}
			break
		case "  Angle Start and End":
			wAxisAngles= {angle0,lastAngle}
			break

		case "  At Listed Angles":
//			SVAR radiusAxesWhere=radiusAxesAngleList
			SVAR radiusAxesAngleList
			radiusAxesWhere= radiusAxesAngleList
			// FALL THROUGH
		default:		// radiusAxesWhere is an explicit angle value or comma-separated range, such as "180" or "  0, 90, 180, -90" 
			numRadiusAxes= ItemsInList(radiusAxesWhere,",")
			Redimension/N=(numRadiusAxes) wAxisAngles
			// angleList has angles in degrees, convert to wave values in radians
			Variable i
			String str
			for( i=0; i < numRadiusAxes; i+=1 )
				str = StringFromList(i,radiusAxesWhere,",")
				wAxisAngles[i]=WMPolarDegToRad(str2num(str))
			endfor
			break
		
		case "  All Major Angles":
			numRadiusAxes = trunc(angleRange / angleInc + 1)
			Redimension/N=(numRadiusAxes) wAxisAngles
			wAxisAngles= WMPolarStraightenAngle(angle0 + p * angleInc)	// radians
			break
	
	endswitch

	WaveTransform zapNaNs, wAxisAngles	// 6.33
	return wAxisAngles
End

// Make angles that are "real close" to +/- pi or +/- pi/2 even closer
Function WMPolarStraightenAngle(angleInRadians)
	Variable angleInRadians

	Variable epsilon= (2*pi/360)/8	// 1/8 degree

	if( abs(angleInRadians - pi/2) < epsilon )
		angleInRadians= pi/2
	elseif( abs(angleInRadians - (-pi/2)) < epsilon )
		angleInRadians= -pi/2
	elseif( abs(angleInRadians - pi) < epsilon )
		angleInRadians= pi
	elseif( abs(angleInRadians - (-pi)) < epsilon )
		angleInRadians= -pi
	endif
	return angleInRadians
End
	
//	Call WMPolarUpdateAxes() when the data changes (not when a grid or axis setting changes)
//
//	if auto-radius axes, this will compute the max and min radii for all traces
//	and expand or contract the axes accordingly.
//	It may possibly check for other reasons to redraw the grid
Function WMPolarUpdateAxes(tw, forceRedraw)
	Wave/T tw		// polarTracesTW
	Variable forceRedraw
	
	String df= GetWavesDataFolder(tw,1)
	
	Variable row, rows = DimSize(tw,0)
	Variable drawGrid= 0
	Variable radiusChanged= 0
	
	// always compute the min and max
	// in case the user switches from manual range to auto range.
	Variable/G $(df+"autoRadiusMin")
	NVAR previousMin= $(df+"autoRadiusMin")
	Variable/G $(df+"autoRadiusMax")
	NVAR previousMax= $(df+"autoRadiusMax")
	Variable radMin=inf, radMax = -inf
	NVAR valueAtCenter= $(df+"valueAtCenter")
	for( row=0; row < rows; row += 1 )
		Variable theMin= str2num(tw[row][kRadiusMin])
		if( numtype(theMin) != 0 )
			continue
		endif
		if( theMin < radMin )
			radMin= theMin
			if( radMin < valueAtCenter )
				radMin = valueAtCenter
			endif
		endif
		Variable theMax=str2num(tw[row][kRadiusMax])
		if( numtype(theMax) != 0 )
			continue
		endif
		if( theMin < valueAtCenter && valueAtCenter == 0 )		// handle the big negative radius case.
			theMax= max(-theMin,theMax)
		endif
		if( theMax > radMax )
			radMax= theMax
		endif
	endfor

	// in some weird cases, the min and max values aren't in tw[]
	// one of these weird cases is when there are no polar traces
	
	// 9.03: also consider the first image in the polar graph
	// but ONLY if there are no polar traces
	String graphName= WMPolarGraphForTW(tw) 
	Variable imageRadiusMin=NaN,imageRadiusMax=NaN
	WMPolarImageAutoRadius(graphName,imageRadiusMin,imageRadiusMax)
	if( radMin == inf && numtype(imageRadiusMin) == 0 )
		radMin= imageRadiusMin
	endif
	if( radMax == -inf && numtype(imageRadiusMax) == 0 )
		radMax= imageRadiusMax
	endif

	// fall back to previousMin and Max if no traces and no image
	if( radMin == inf )
		radMin= previousMin
	endif
	if( radMax == -inf )
		radMax= previousMax
	endif

	if( (radMin != previousMin) || (radMax != previousMax) )
		previousMin= radMin
		previousMax= radMax
		radiusChanged= 1
		if( WMPolarWantAutoRadiusRange(tw) )
			drawGrid= 1
		endif
	endif
	
	if( forceRedraw )
		drawGrid= 1
	endif
	
	if (drawGrid )
		//if( strlen(graphName) )	// 6.36
		if( WMPolarIsPolarGraph(graphName) ) // 9.02
			Variable autoScaleTraceChanged= WMPolarAxesRedraw(graphName,tw)
			if( autoScaleTraceChanged && forceRedraw )
				DoUpdate
				WMPolarAxesRedraw(graphName,tw)
			endif
		endif
	endif
End

Function WMPolarImageAutoRadius(graphName,imageRadiusMin,imageRadiusMax)
	String graphName
	Variable &imageRadiusMin,&imageRadiusMax // outputs

	WAVE/Z image= WMPolarGraphGetImage(graphName, 0)
	if( !WaveExists(image) )
		return 0 // imageRadiusMin,imageRadiusMax unchanged
	endif
	// an image is displayed in "drawn coordinates"
	// but we need "data coordinates" for the radiuses
	Variable xFirst = DimOffset(image,0)
	Variable xLast = xFirst + (DimSize(image,0)-1)*DimDelta(image,0)

	Variable yFirst = DimOffset(image,1)
	Variable yLast = yFirst + (DimSize(image,1)-1)*DimDelta(image,1)
	
	// to convert from drawn to data coordinates,
	// we need the radiusFunctionStr and valueAtCenter to use WMPolarRadiusFunctionInv
	String radiusFunctionStr=WMPolarGraphGetStrOrDefault(graphName, "radiusFunction", "Linear")	// "Linear;Log;Ln"
	Variable valueAtCenter=WMPolarGraphGetVarOrDefault(graphName,"valueAtCenter",0)

	// the max radius is one of the corners
	Variable drawnRadius = sqrt(magsqr(cmplx(xFirst,yFirst)))
	imageRadiusMax = WMPolarRadiusFunctionInv(drawnRadius,radiusFunctionStr,valueAtCenter)

	drawnRadius = sqrt(magsqr(cmplx(xLast,yFirst)))
	imageRadiusMax = max(imageRadiusMax,WMPolarRadiusFunctionInv(drawnRadius,radiusFunctionStr,valueAtCenter))

	drawnRadius = sqrt(magsqr(cmplx(xLast,yLast)))
	imageRadiusMax = max(imageRadiusMax,WMPolarRadiusFunctionInv(drawnRadius,radiusFunctionStr,valueAtCenter))

	drawnRadius = sqrt(magsqr(cmplx(xFirst,yLast)))
	imageRadiusMax = max(imageRadiusMax,WMPolarRadiusFunctionInv(drawnRadius,radiusFunctionStr,valueAtCenter))
	
	// the min radius is located on one the sides (use a min-distance-to-line algorithm)
	imageRadiusMin= 0 // TEMPORARY
	return 1 // imageRadiusMin,imageRadiusMax changed
End

// WMPolarTicks() outputs are globals in tw's data folder:
//
// dataInnerRadius			(data coordinates)
// dataOuterRadius			(data coordinates)
// dataMajorRadiusInc		(data coordinates)
// dataMinorRadiusTicks	(0 if no minor ticks)
// firstMajorRadiusTick
// lastMajorRadiusTick
//
// dataAngle0 				(radians)
// dataAngleRange			(radians)
// dataMajorAngleInc		(radians)
// dataMinorAngleTicks		(0 if no minor ticks)
//
// Based on PolarTicks
Function WMPolarTicks(tw)
	Wave/T tw		// polarTracesTW, assumed to be in current data folder

	// Radius Range - outputs are dataInnerRadius and dataOuterRadius
	NVAR dataInnerRadius	// but we update these later because WMPolarRadiusTicks may modify minRadius and maxRadius
	NVAR dataOuterRadius

	Variable minRadius, maxRadius
	Variable isAutoRadiusRange= WMPolarRadiusRange(tw, minRadius, maxRadius)	// outputs are minRadius, maxRadius

	// Radius Ticks - outputs are dataMajorRadiusInc and dataMinorRadiusTicks
	NVAR dataMajorRadiusInc
	NVAR dataMinorRadiusTicks
	NVAR firstMajorRadiusTick
	NVAR lastMajorRadiusTick
	
	Variable majorInc, minorTicks, firstMajorTick, lastMajorTick
	Variable isAutoRadiusTicks= WMPolarRadiusTicks(tw, minRadius, maxRadius, majorInc, minorTicks ,firstMajorTick, lastMajorTick)	// outputs are majorInc, minorTicks and possibly minRadius, maxRadius

	dataInnerRadius= minRadius
	dataOuterRadius= maxRadius

	dataMajorRadiusInc= majorInc
	NVAR doMinorRadiusTicks	// updated by checkbox directly, it applies to both auto or manual ticks.
	dataMinorRadiusTicks= doMinorRadiusTicks ? max(1,minorTicks) : 0 

	firstMajorRadiusTick= firstMajorTick
	lastMajorRadiusTick= lastMajorTick

	// Angle Range - Manual Only - outputs are dataAngle0 and dataAngleRange in radians
	NVAR angle0			// degrees
	NVAR angleRange		// degrees

	NVAR dataAngle0		// radians
	NVAR dataAngleRange	// radians
	dataAngle0= 			WMPolarDegToRad(angle0)
	dataAngleRange=		WMPolarDegToRad(angleRange)

	// Angle Ticks - outputs are dataMajorAngleInc (in radians) and dataMinorAngleTicks
	Variable isAutoAngleTicks= WMPolarAngleTicks(tw, angle0, angleRange, majorInc, minorTicks )	// outputs are majorInc (in degrees), minorTicks

	NVAR dataMajorAngleInc		// radians
	dataMajorAngleInc= WMPolarDegToRad(majorInc)

	NVAR dataMinorAngleTicks
	NVAR doMinorAngleTicks	// updated by checkbox directly, it applies to both auto or manual ticks.
	dataMinorAngleTicks= doMinorAngleTicks ? max(1,minorTicks) : 0 
End

// WMPolarAngleTicks
// outputs are majorInc and minorTicks
// either auto-determined or manually set.
//
// Returns truth that the ticks were automatically determined.
Function WMPolarAngleTicks(tw, angle0, angleRange, majorInc, minorTicks)
	Wave/T tw		// polarTracesTW, assumed to be in current data folder
	Variable angle0, angleRange			// inputs in DEGREES (for better ticking calculations)
	Variable &majorInc, &minorTicks	// outputs (majorInc in DEGREES)

	Variable isAutoAngleTicks= WMPolarWantAutoAngleTicks(tw)	// true if "Auto Radius Ticks, Approximately:" is checked in the Ticks tab.

	if( isAutoAngleTicks )
		NVAR angleApproxTicks
		Variable numTics= angleApproxTicks

		Variable numMinorTics=1
		Variable theMin= angle0
		Variable theMax= angle0+angleRange

		// Choose ever-smaller angles that are a submultiple of a circle until the angleApproxTicks * angleInc spans the range.
		
		majorInc= angleRange / max(1,numTics)
		WAVE angleIncrements= $WMPolarDFVar("angleIncrements")	// {360, 180, 90, 45, 15, 5, 1}
		Variable index= BinarySearchInterp(angleIncrements,majorInc)
		if( index == -2)
			Variable numDigits			// currently not used, could be used to modify the label format?
			if( 0 != WMPolarSmartTicks(theMin, theMax,numTics,numMinorTics,numDigits) )
				// handle error
				numMinorTics= 0
			endif
			majorInc= (theMax-theMin) / numTics
			minorTicks= numMinorTics
		else
			majorInc= angleIncrements[round(index)]
			NVAR minorAngleTicks	// manual radius minor ticks
			minorTicks= WMPolarBiggestSubmultiple(minorAngleTicks+1,majorInc) -1
		endif
	else
		NVAR majorAngleInc	// manual angle increment
		majorInc= majorAngleInc
	
		NVAR minorAngleTicks	// manual radius minor ticks
		minorTicks= minorAngleTicks
	endif

	return isAutoAngleTicks
End

// WMPolarRadiusTicks
// outputs are majorInc and minorTicks
// either auto-determined or manually set.
//
// the inputs minRadius and maxRadius are the range values from WMPolarRadiusRange()
//	 if manual
//	 	innerRadius and outerRadius
//	 else auto:
//		autoRadiusMin and  autoRadiusMax
//
// Returns truth that the ticks were automatically determined.
Function WMPolarRadiusTicks(tw, minRadius, maxRadius, majorInc, minorTicks,firstMajorTick, lastMajorTick)
	Wave/T tw		// polarTracesTW, assumed to be in current data folder
	Variable &minRadius, &maxRadius		// axis range inputs and possibly outputs (if auto range)
	Variable &majorInc, &minorTicks	// outputs
	Variable &firstMajorTick, &lastMajorTick	// outputs; the major tick marks don't necessarily start at the minRadius

	NVAR valueAtCenter

	Variable isAutoRadiusRange=  WMPolarWantAutoRadiusRange(tw)	// true if "Autoscale Radius Axes" radio button is chosen in the Range tab
	Variable numMinorTics
	Variable numDigits			// currently not used, could be used to modify the label format?

	Variable isAutoRadiusTicks= WMPolarWantAutoRadiusTicks(tw)		// true if "Auto Radius Ticks, Approximately:" is checked in the Ticks tab.

	Variable minR= minRadius,maxR= maxradius	// avoid updating minRadius and maxRadius unnecessarily

	if( isAutoRadiusTicks )
		NVAR radiusApproxTicks
		Variable numTics= radiusApproxTicks


		if( 0 != WMPolarSmartTicks(minR, maxR,numTics,numMinorTics,numDigits) )
			// handle error
			numMinorTics= 0
		endif
		majorInc= (maxR - minR) / numTics
		minorTicks= numMinorTics
	
		if( isAutoRadiusRange )
			minRadius= minR
			maxRadius= maxR
		endif
		
		// prevent the first major tick from being outside the grid
		// this is tricky: the range can extend into valueAtCenter:
		// for example: valueAtCenter=7
		// auto (or manual) range= 0-100
		Variable minLim= max(valueAtCenter,minRadius)
		Variable delta= minLim - minR		// positive if minR is too small
		if( delta > 0 )
			minR +=majorInc* ceil(delta/majorInc)
		endif
		delta= maxR - maxRadius	// positive if maxR is too big
		if( delta > 0 )
			maxR -=majorInc* ceil(delta/majorInc)
		endif
		firstMajorTick=minR
		lastMajorTick= maxR
		
	else		// manual radius ticks - we need a canonical tick other than minRadius
	
		NVAR majorRadiusInc	// manual radius increment
		majorInc= majorRadiusInc
	
		NVAR minorRadiusTicks	// manual radius minor ticks
		minorTicks= minorRadiusTicks
		
		if( isAutoRadiusRange )	// true if auto radius range but manual radius increment
			Variable nt
			if( majorInc > 0 )
				Variable aDelta= abs((maxRadius-minRadius)/ majorInc)
				nt= max(1,ceil(aDelta))
			else
				nt=1
			endif
			WMPolarSmartTicks(minRadius, maxRadius,nt,numMinorTics,numDigits)
		endif

		// set the first major tick to be a multiple of the increment
		firstMajorTick= ceil(minRadius / majorInc) * majorInc
		lastMajorTick= round(maxRadius / majorInc) * majorInc
	endif

	return isAutoRadiusTicks
End

// WMPolarRadiusRange
// outputs are minRadius and maxRadius
// either auto-determined or manually set.
//
// Returns truth that the range was automatically determined.
Function WMPolarRadiusRange(tw, minRadius, maxRadius)
	Wave/T tw		// polarTracesTW, assumed to be in current data folder
	Variable &minRadius, &maxRadius

	Variable isAutoRadiusRange=  WMPolarWantAutoRadiusRange(tw)	// true if "Autoscale Radius Axes" radio button is chosen in the Range tab
	if( isAutoRadiusRange )
		// the autoRadiusMin and autoRadiusMax values are the result of the WMPolarUpdateAxes() stuff
		NVAR autoRadiusMin
		NVAR autoRadiusMax
		NVAR doRadiusRangeMaxOnly
		if( doRadiusRangeMaxOnly )
			NVAR valueAtCenter
			minRadius= valueAtCenter
		else
			minRadius= autoRadiusMin
		endif
		if( autoRadiusMax == minRadius )
			maxRadius= minRadius + max(1,minRadius/100)
		else
			maxRadius= autoRadiusMax
		endif
	else
		NVAR innerRadius	// manual radius values
		NVAR outerRadius
		minRadius= innerRadius
		maxRadius= outerRadius
	endif
	
	return isAutoRadiusRange
End

Function WMPolarDegToRad(deg)
	Variable deg
	Return deg / 180 * Pi
End

Function WMPolarRadToDeg(rad)
	Variable rad
	Return rad / Pi * 180
End


// Returns drawn coordinates
Function WMPolarDrawnRange(graphName,xMin, xMax, yMin, yMax)
	String graphName
	Variable &xMin, &xMax, &yMin, &yMax

	GetAxis/Q/W=$graphName HorizCrossing
	xMin=V_min
	xMax=V_max
	GetAxis/Q/W=$graphName VertCrossing
	yMin=V_min
	yMax=V_max
End

// This function assumes the top window is a graph in 1:1 Plan mode,
// the HorizCrossing axes exists and it spans the entire plot area.
Function WMPolarPointsToDrawn(graphName, points)
	String graphName
	Variable points
	
	GetAxis/Q/W=$graphName HorizCrossing
	Variable drawnLength= abs(V_max-V_min)		// Drawn coordinates

	GetWindow $graphName psize
	Variable physicalLength= V_right-V_left		// plot area width in points
	
	drawnLength= points * drawnLength/physicalLength	// if HorizCrossing axis is x% of plot area, multiply here by x%
	
	return drawnLength		// Call WMPolarDrawLine with this value to draw a radial line that is physically points long.
End


	
// returns biggest result less than submultipleCandidate, such that that result * multiple = product, where multiple is an integer, possibly 1
Function WMPolarBiggestSubmultiple(submultipleCandidate,product)
	Variable submultipleCandidate,product

	Variable remainder
	Variable result=floor(min(submultipleCandidate-1,product)) // (result usually == submultipleCandidate-1)
	do
		remainder=mod(product,result)
		result-= 1
	while( (remainder != 0) %& (result > 0) )

	return result+1
End

// returns biggest odd result less than submultipleCandidate, such that that result * multiple = product, where multiple is an integer, possibly 0
// requires inputs to be greater than 0
Function WMPolarBiggestOddSubmultiple(submultipleCandidate,product)
	Variable submultipleCandidate,product
	
	Variable remainder
	Variable result=floor(min(submultipleCandidate-1,product)) // (result usually == submultipleCandidate-1)
	if( ((result %& 1) == 0) && ( result > 0) )
		result -= 1	// guaranteed odd
	endif
	if( result > 0 )
		do
			remainder=mod(product,result)
			result -= 2
		while( (remainder != 0) && (result > 0) )
		if( remainder == 0 )
			result +=2
		else
			result = 0
		endif
	endif
	return result
End

// returns biggest even result less than submultipleCandidate, such that that result * multiple = product, where multiple is an integer, possibly 0
// requires inputs to be greater than 0
Function WMPolarBiggestEvenSubmultiple(submultipleCandidate,product)
	Variable submultipleCandidate,product
	
	Variable remainder
	Variable result=floor(min(submultipleCandidate-1,product)) // (result usually == submultipleCandidate-1)
	if( result %& 1 )
		result -= 1	// guaranteed even
	endif
	if( result > 0 )
		do
			remainder=mod(product,result)
			result -= 2
		while( (remainder != 0) && (result > 0) )
		if( remainder == 0 )
			result +=2
		else
			result = 0
		endif
	endif
	return result
End

// Given the number of ticks, choose a submultiple of current ticks to divide the region evenly
// Because only an odd number of ticks can be further subdivided, this routine prefers to return
// the largest odd submultiple over even submultiples.  It even prefers 1 over small even submultiple 2
// Returns 0 if it can't find a number of ticks.
Function WMPolarSubDivideTicks(currentTicks)
	Variable currentTicks
	
	Variable newTicks= 0		// zero means can't subdivide interval
	if( (currentTicks > 1) && (currentTicks %& 1) )	// only odd ticks (even subintervals) can be subdivided
		newTicks= WMPolarBiggestEvenSubmultiple((currentTicks+3)/2,currentTicks+1)
		if( newTicks > 0 )		// zero means cant subdivide
			newTicks-= 1
			if( newTicks == 1 )	// try even ticks
				newTicks= WMPolarBiggestOddSubmultiple(currentTicks,currentTicks+1)
				if( newTicks < 4 )	// prefer 1 tick over small even ticks
					newTicks= 1
				endif
			endif
		endif
	endif	
	return newTicks
End


// rounds to 1, 2, or 5 * 10eN, non-rigorously
Function WMPolarNiceNumber10(num)
	Variable num
	
	if( num == 0 )
		return 0
	endif
	Variable theSign= sign(num)
	num= abs(num)
	Variable lg= log(num)
	Variable decade= floor(lg)
	Variable frac = lg - decade
	Variable mant
	if( frac < log(1.5) )
		mant= 1
	else	
		if( frac < log(4) )
			mant= 2
		else
			if( frac < log(8) )
				mant= 5
			else
				mant= 10
			endif
		endif
	endif
	num= theSign * mant * 10^decade
	return num
End


//	WMPolarSmartTicks takes 5 parameters which it modifies:
//
//	 On input the first two parameters are the min and max range.
//	 On output the first two parameters are the min and max values that will give
//	"nice" values when used with the determined number of tic marks.
//	
//	The third parameter on input is the requested number of tic marks.  This function will
//	set the output third parameter to the number of tic marks that together with the specified
//	min and max values provide "nice" intervals and labels.
//
//	The fourth parameter is set upon return to a good value for the number of minor tic marks
//	inside each major tic-mark interval.
//
//	The fifth parameter is set upon return to the number of significant figures required to
//	represent the "nice" ticks.
//
//	NOTE: No provision is made for the size of the tick labels and the size of the region to label.
//
//	The return value is 0 if all went well, or 1 if some error was encountered.
//
//	Based on makeSmartLabels from Drawing Axes.ipf
//
//	Original algorithm by R. M. Emmons (c. 1987).
//
//	Revised Dec 22, 2005 by JP to include the 2.5 good increment
//	Revised Nov 7, 2019 by JP to allow xmin > xmax
//
Function WMPolarSmartTicks(xmin,xmax,numTics,numMinorTics,numDigits)
	Variable &xmin,&xmax,&numTics,&numMinorTics,&numDigits
	
	numTics= max(0,(round(numTics)))
	if(numTics<=0)
		DoAlert 0, "The number of tic marks must be positive"
		return 1
	endif
	
	Make /O/FREE tmpGood={10,2,2.5,3,5}
	Variable nPnts= numpnts(tmpGood)

	Variable reversed= xmin > xmax
	Variable xrange= abs(xmax-xmin)
	if( reversed )
		Variable xminCopy= xmin
		xmin = xmax
		xmax = xminCopy
	endif
	
	// the following algorithm relies on xmin < xmax
	
	numTics+=1
	variable LDX=xrange/numTics
	
	variable 	tmp,ord,order
	variable 	i=0,j;
	variable	outXmax,outXmin,imin,imax,basis,tntics,varOrder,ntic,minor
	
	do
	
		tmp=LDX/10
		tmp=log(tmp)
		ord=trunc(tmp)
		j=0
		
		do
			varOrder=ord+j
			basis=tmpGood[i]*10^varOrder
			imin=trunc(floor(xmin/basis))
			imax=ceil(xmax/basis)
			tntics=imax-imin+1	// this includes the start, middle, and end ticks
			
			if(abs(tntics-numTics) < abs(ntic-numTics))
				outXmax=imax*basis
				outXmin=imin*basis
				ntic=tntics
				// numDigits=abs(varOrder)
				numDigits=abs(floor(log(basis)))+1		// 09NOV98 suggested by JEG
				minor=i
			endif
			j +=1
		while(j<=1)
		
		i +=1
	while(i<nPnts)
	
	// 	load return values

	if( reversed )
		xmin= outXmax
		xmax= outXmin
	else
		xmin= outXmin
		xmax= outXmax
	endif

	numTics= ntic-1
	numMinorTics= minor

	return 0
end

// assumes the current data folder contains the settings for the named polar graph
Function WMPolarOptimumGridAngle(graphName,radiusEnd,angleInc,angleMinorTicks)
	String graphName
	Variable radiusEnd,angleInc,angleMinorTicks

	NVAR valueAtCenter
	SVAR radiusFunction	// "Linear", "Log", or possibly "Ln"
	
	Variable maxDrawnRadius= WMPolarRadiusFunction(radiusEnd,radiusFunction,valueAtCenter)  // drawn radius
	Variable zeroRadius= WMPolarRadiusFunction(valueAtCenter,radiusFunction,valueAtCenter)  // drawn radius
	maxDrawnRadius -= zeroRadius

	NVAR maxArcLine		// longest straight line used to draw an arc, in points
	Variable maxArcLineDrawn= WMPolarPointsToDrawn(graphName,maxArcLine)
	
	Variable maxArcAngleDrawn= abs(atan2(maxArcLineDrawn,	maxDrawnRadius))	// minorArcAngle could exceed angleIncDraw in magnitude...
	// maxArcAngleDrawn is now the upper bound on the angle (degrees is maxArcAngleDrawn * 180 / pi )
	// now compute submultiple of the major and minor angle increments that is smaller than that.
	Variable gridAngleInc= abs(angleInc/(angleMinorTicks+1))	// angle between adjacent grid "spokes"
	Variable multiple= ceil(gridAngleInc / maxArcAngleDrawn)
	maxArcAngleDrawn= gridAngleInc / multiple						// maxArcAngleDrawn is now an even multiple of gridAngleInc
	
	NVAR segsPerMinorArc	// a number designed for minor ticks, about 3, usually
	Variable deltaAngleDraw= min(maxArcAngleDrawn,gridAngleInc/segsPerMinorArc)
	return deltaAngleDraw	//  deltaAngleDraw * 180 / pi 
End
	

// no minor radius grid (arcs) if  radiusMinorTicks==0, no minor angle grid (spokes) if angleMinorTicks==0
// minspacing is used to prevent grids from colliding at smaller radii.  Set to 0 if you want same number of spokes/angle regardless of radius.
// All angles in radians.
// Returns revised angleMinorTicks, because the minspacing limitation may prevent that many minor ticks from being used.
//
// TO DO: don't draw a major grid if an axis will be drawn over it.
//
// Based on FPolarGrid
//
Function WMPolarGrid(graphName,radiusStart,radiusEnd,radiusInc,radiusMinorTicks,angle0,angleRange,angleInc,angleMinorTicks,xmin,xmax,ymin,ymax,minspacing)
	String graphName
	Variable radiusStart,radiusEnd	// radii in data coordinates, NOT drawn coordinates
	Variable radiusInc				// major increment
	Variable radiusMinorTicks		// minor increment is radiusInc/(radiusMinorTicks+1)
	Variable angle0,angleRange		// angles in data coordinates (radians), NOT drawn coordinates.
	Variable angleInc				// major angle increment in radians
	Variable angleMinorTicks		// minor increment is angleInc/(angleMinorTicks+1)
	Variable xmin,xmax,ymin,ymax							// current graph ranges in DRAWN coordinates
	Variable minspacing										// min required distance between spokes, in DRAWN coordinates

	NVAR majorGridLineSize
	NVAR minorGridLineSize

	NVAR firstMajorRadiusTick
	NVAR lastMajorRadiusTick
	radiusInc= abs(radiusInc)
	radiusMinorTicks=round(abs(radiusMinorTicks))
	// don't abs(angleInc), negative angleIncs should be legal! (though they don't work quite right)
	angleMinorTicks=round(abs(angleMinorTicks))

	NVAR zeroAngleWhere				// 0 = right, 90 = top, 180 = left, -90 = bottom
	NVAR angleDirection				// 1 == clockwise, -1 == counter-clockwise"
	
	Variable angle0Draw= WMPolarAngleFunction(angle0,zeroAngleWhere,angleDirection,2*pi)	// drawn angle in radians

	Variable angleDir= -angleDirection			// -1 if clockwise (angles drawn in opposite direction), 1 if ccw
	Variable angleIncDraw= angleInc * angleDir
	Variable angleRangeDraw= angleRange * angleDir		// drawn angle
	
	// compute optimum angle increment for arcs: a submultiple of major angle increment, and also possibly of the minor angle increment.
	Variable maxDeltaAngleDraw= WMPolarOptimumGridAngle(graphName,radiusEnd,angleInc,angleMinorTicks)

	NVAR valueAtCenter
	SVAR radiusFunction	// "Linear", "Log", or possibly "Ln"
	
	Variable radStartDraw=WMPolarRadiusFunction(radiusStart,radiusFunction,valueAtCenter)	// drawn radius
	Variable radEndDraw=WMPolarRadiusFunction(radiusEnd,radiusFunction,valueAtCenter)	// drawn radius
	
	Variable radius,deltaRadius,adjustedRadStart
	Variable visible,x1,y1,x2,y2,cosAngle,sinAngle,angle,angleDraw,lastAngle
	Variable i,numMinorTicks
	
	NVAR useCircles	// 0 for polygons, 1 for circles
	Variable wantCircles

	SetDrawEnv/W=$graphName xcoord= HorizCrossing,ycoord= VertCrossing,fillpat= 0,save

	Variable usesVirtualLayers = strlen(WMPolarGraphCurrentDrawLayer(graphName))
	if( !usesVirtualLayers )
		SetDrawEnv/W=$graphName gstart	// begin grids group
	endif
	
	// draw minor grid first, so that the major grids are drawn on top
	NVAR doPolarGrids
	Variable linesize= minorGridLineSize
	
	if( doPolarGrids )
		NVAR minorGridColorRed,minorGridColorGreen,minorGridColorBlue,minorGridStyle
		Variable minorGridColorAlpha= NumVarOrDefault("minorGridColorAlpha", 65535)
		SetDrawEnv/W=$graphName linefgc=(minorGridColorRed,minorGridColorGreen,minorGridColorBlue,minorGridColorAlpha)
		SetDrawEnv/W=$graphName linebgc=(minorGridColorRed,minorGridColorGreen,minorGridColorBlue,minorGridColorAlpha)
		SetDrawEnv/W=$graphName dash= minorGridStyle,linethick=linesize, save

		//wantCircles= useCircles && minorGridStyle == 0	// circles can draw only the solid line.
		wantCircles= useCircles								// not true anymore (Igor 7+)

		if( (radiusMinorTicks > 0) && (linesize > 0) )
			deltaRadius= radiusInc/(radiusMinorTicks+1)
			numMinorTicks=floor(1+ (radiusMinorTicks+1) * abs((radiusEnd-radiusStart)/radiusInc))	// total minor ticks.

			// find radius of first minor tick= firstMajorRadiusTick - n * deltaRadius, n <= numMinorTicks
			Variable firstMinorTick= firstMajorRadiusTick + deltaRadius	// for radius
			Variable firstMinorTickIndex = 1		// for ti
			
			if( numMinorTicks > 0 && deltaRadius != 0 )
				Variable minorIncsBeforeMajorTick= floor((firstMajorRadiusTick - radiusStart) / deltaRadius)	// positive number
				if( minorIncsBeforeMajorTick != 0 )
					firstMinorTickIndex= -minorIncsBeforeMajorTick 		// initial negative number for ti
					firstMinorTick = firstMajorRadiusTick + firstMinorTickIndex * deltaRadius
					numMinorTicks=floor(1+ (radiusMinorTicks+1) * abs((radiusEnd-firstMinorTick)/radiusInc)) // total ticks for ticked axis
				endif
			endif
			
			radius= firstMinorTick
			i=firstMinorTickIndex
			do	//draw minor radius grid (arcs)
				radius= WMPolarRadiusFunction(radius,radiusFunction,valueAtCenter)  // drawn radius
				WMPolarDrawArc(graphName,radius,angle0Draw,angleRangeDraw,maxDeltaAngleDraw,xmin,xmax,ymin,ymax,wantCircles,lineSize)
				i += 1
				if( mod(i,radiusMinorTicks+1)==0 )	// we skip the major radii, to avoid two arcs at the same location
					i += 1
				endif
				radius = firstMajorRadiusTick + i * deltaRadius	// data radius
			while(i <  numMinorTicks && radius < radiusEnd && deltaRadius != 0 )
		endif
		if( (angleMinorTicks>0) %& (angleInc!=0) )
			Make/D/O/N=(angleMinorTicks+1) W_adjustedRadii	// indexed by mod(i,angleTicks+1) (revised angleMinorTicks guaranteed less than original angleMinorTicks)
			Variable ndx
			angleMinorTicks= WMPolarCalcAdjustedRadiuses(W_adjustedRadii,angleMinorTicks,angleInc,radiusStart,radiusEnd,radiusInc,minspacing,radiusFunction,valueAtCenter)
			if( angleMinorTicks>0 )
				Variable deltaAngle= angleInc/(angleMinorTicks+1)	// data angle units
				numMinorTicks=floor(1+ (angleMinorTicks+1) * abs(angleRange/angleInc))	// total minor ticks, was round(...)
				angle= angle0 + deltaAngle	// we skip the major angles, to avoid two spokes at the same location
				i=1
				do	//draw minor angle grid (spokes)
					angleDraw= WMPolarAngleFunction(angle,zeroAngleWhere,angleDirection,2*pi)	// drawn angle
					angleDraw= WMPolarStraightenAngle(angleDraw)					
					cosAngle= cos(angleDraw)
					sinAngle= sin(angleDraw)
					adjustedRadStart= W_adjustedRadii[mod(i,angleMinorTicks+1)]	// data radius
					adjustedRadStart=WMPolarRadiusFunction(adjustedRadStart,radiusFunction,valueAtCenter)  // drawn radius
					x1= adjustedRadStart * cosAngle
					y1=  adjustedRadStart * sinAngle
					x2=  radEndDraw * cosAngle
					y2=  radEndDraw * sinAngle
					if( adjustedRadStart < radEndDraw )	// Drawn radii compared
						visible= WMPolarDrawClippedLine(graphName,x1,y1,x2,y2,xmin,xmax,ymin,ymax)	// 0 if invisible, 1 if not clipped, 2 if only x1,y1 clipped, 3 or 4 if x2,y2 clipped
					endif
					i += 1
					if( mod(i,angleMinorTicks+1)==0 )	// we skip the major angles, to avoid two spokes at the same location
						i += 1
					endif
					angle= angle0 + i* deltaAngle
				while(i <  numMinorTicks  && deltaAngle != 0)
			else
//				NVAR minGridSpacing
//				Print "*** Min grid spacing of "+num2str(minGridSpacing)+" points prevented minor grids from being drawn."
//				Print "*** You can decrease min grid spacing in the Axes tab."
			endif
			KillWaves/Z W_adjustedRadii
		endif
	endif

	// draw major grids

	// these globals accumulate a rectangle that encompasses grids, axes, and axis labels
	NVAR fullXMinDrawn, fullXMaxDrawn, fullYMinDrawn, fullYMaxDrawn
	Variable fxMin=fullXMinDrawn
	Variable fxMax=fullXMaxDrawn
	Variable fyMin=fullYMinDrawn
	Variable fyMax=fullYMaxDrawn


	if( doPolarGrids  )
		linesize= majorGridLineSize
		NVAR majorGridColorRed,majorGridColorGreen,majorGridColorBlue,majorGridStyle
		Variable majorGridColorAlpha= NumVarOrDefault("majorGridColorAlpha", 65535)
		SetDrawEnv/W=$graphName linefgc=(majorGridColorRed,majorGridColorGreen,majorGridColorBlue,majorGridColorAlpha)
		SetDrawEnv/W=$graphName linebgc=(majorGridColorRed,majorGridColorGreen,majorGridColorBlue,majorGridColorAlpha)
		SetDrawEnv/W=$graphName dash= majorGridStyle,linethick=linesize, save

		wantCircles= useCircles

		// Major Rings
		if( linesize > 0 )
			radius= firstMajorRadiusTick
			i=0
			do
				radius= WMPolarRadiusFunction(radius,radiusFunction,valueAtCenter)  // drawn radius
				WMPolarDrawArc(graphName,radius,angle0Draw,angleRangeDraw,maxDeltaAngleDraw,xmin,xmax,ymin,ymax,wantCircles,linesize)
				i += 1
				radius = firstMajorRadiusTick + i * radiusInc	// data radius
				
				Variable keepGoing= WMPolarSloppyCompare(radius,lastMajorRadiusTick,radiusInc/4) <= 0		// positive if radius bigger than lastMajorRadiusTick
				keepGoing= keepGoing && WMPolarSloppyCompare(radius,radiusEnd,radiusInc/4) <= 0
			while( keepGoing && radiusInc != 0 )
		endif
		// Major Spokes
		angle= angle0
		lastAngle= angle0 + limit(angleRange,-2*Pi+angleInc/2,2*Pi-angleInc/2)	// to avoid two radius grids overlapping
		i= 0
		do
			angleDraw= WMPolarAngleFunction(angle,zeroAngleWhere,angleDirection,2*pi)	// drawn angle in radians
			angleDraw= WMPolarStraightenAngle(angleDraw)					
			cosAngle= cos(angleDraw)
			sinAngle= sin(angleDraw)
			x1= radStartDraw * cosAngle
			y1=  radStartDraw *sinAngle
			x2=  radEndDraw * cosAngle
			y2=  radEndDraw *sinAngle
			WMPolarUnionRects(fxMin, fyMin, fxMax, fyMax, x1, y1, x2, y2)
			if( linesize > 0 )
				visible= WMPolarDrawClippedLine(graphName,x1,y1,x2,y2,xmin,xmax,ymin,ymax)	// 0 if invisible, 1 if not clipped, 2 if only x1,y1 clipped, 3 or 4 if x2,y2 clipped
			endif
			i += 1
			angle= angle0 + i * angleInc
		while(angle <= lastAngle && angleInc != 0 )
	endif
	if( !usesVirtualLayers )
		SetDrawEnv/W=$graphName gstop	// end grids group
	endif

	fullXMinDrawn= fxMin
	fullXMaxDrawn= fxMax
	fullYMinDrawn= fyMin
	fullYMaxDrawn= fyMax

	return angleMinorTicks	// possibly revised to be fewer.
End

// returns true if a circle of given radius will fit within xmin,xmax,ymin,ymax without clipping, else returns 0 
Function WMPolarCircleFitsInRect(radius,xmin,xmax,ymin,ymax)
	Variable/D radius,xmin,xmax,ymin,ymax
	
	Variable fits=0
	// First, zero has to be within the xmin,xmax,ymin,ymax box
	if( (xmin < 0) %& (xmax > 0) %& (ymin < 0) %& (ymax > 0) )
		Variable smallest= min(min(min(-xmin,xmax),-ymin),ymax)
		fits= (radius <= smallest)
	endif
	return fits
End

 // for best Appearance, set maxDeltaAngle to submultiple of gridDeltaAngle for the arc
 // based on DrawArc
Function WMPolarDrawArc(graphName,radius,angle0,angleRange,maxDeltaAngle,xmin,xmax,ymin,ymax,wantCircles,lineSize)	// radians
	String graphName
	Variable radius,angle0,angleRange,maxDeltaAngle,xmin,xmax,ymin,ymax
	Variable wantCircles	// user wants circles, we  also make sure each circle fits in xmin,xmax,ymin,ymax
	Variable lineSize		// size of line in points, used only if wantCircles is true.
	
	Variable useCircles=0
	if(wantCircles && (abs(angleRange) >= 2*pi))
		useCircles= WMPolarCircleFitsInRect(radius,xmin,xmax,ymin,ymax)
		if( useCircles )
			//radius += WMPolarPointsToDrawn(graphName,lineSize)/2	// DrawOval used to draw tangent to the boundaries, but no longer.
			DrawOval/W=$graphName -radius,radius,radius,-radius
			return 1
		endif
	endif
	
//	if( maxDeltaAngle <= 0 )
//		maxDeltaAngle =angleRange/360 	// one degree or less
//	endif
//	
	Variable visible				// really "visible + how clipped, if clipped at all"!
	Variable partVisible= 0		// true if any portion of the arc is visible

	Variable additionalPts=limit(round(abs(angleRange/maxDeltaAngle)),1,360) // this many endpoints, plus 1
	Variable dAngle= angleRange / additionalPts

	// unclipped coordinates
	Variable x1= radius * cos(angle0)
	Variable y1=  radius * sin(angle0)
	Variable x2, y2
	
	Variable cx1,cy1,cx2,cy2	// clipped coordinates
	
	Variable n=1
	do	// while there are points to draw
		do	// start a segment
			x2= radius * cos(angle0+n*dAngle)
			y2=  radius * sin(angle0+n*dAngle)
			cx1= x1
			cy1= y1
			cx2= x2
			cy2=y2
			visible= WMPolarClipLineToRect(cx1,cy1,cx2,cy2,xmin,xmax,ymin,ymax)	// 0 if invisible, 1 if not clipped, 2 if only x1,y1 clipped, 3 or 4 if x2,y2 clipped
			x1=x2
			y1=y2	// ready for next try
			additionalPts -= 1
			n+=1
		while( (visible ==0) %& (additionalPts > 0) )	//  do while invisible
		if( visible )
			DrawPoly/W=$graphName cx1,cy1,1,1,{cx1,cy1,cx2,cy2}		// first and second points, possibly clipped
			partVisible= 1
		endif
		if (radius == 0 )
			return partVisible
		endif
		// Additional points, if any, and only if x2,y2 (the new x1,y1) weren't clipped
		if( (additionalPts > 0) && (visible <= 3) )	// no clipping, or old x1,y1 clipped
			do					// draw additional points
				x2= radius * cos(angle0+n*dAngle)
				y2=  radius * sin(angle0+n*dAngle)
				cx1= x1
				cy1= y1
				cx2= x2
				cy2=y2
				visible= WMPolarClipLineToRect(cx1,cy1,cx2,cy2,xmin,xmax,ymin,ymax)	// 0 if invisible, 1 if not clipped, 2 if only x1,y1 clipped, 3 or 4 if x2,y2 clipped
				if( visible )
					DrawPoly/W=$graphName /A {cx2,cy2}
				endif 
				x1=x2
				y1=y2	// ready for next try
				additionalPts -= 1
				n+=1
			while( (additionalPts>0) && (visible == 1) )	// until the segment ends with x2,y2 clipped (we already know x1, y1 aren't clipped)
		endif
	while( additionalPts > 0 )
	return partVisible
End

// The arc's origin is 0,0
Function WMPolarRectEnclosingArc(radius,angle0,angleRange, xmin, ymin, xmax, ymax)
	Variable radius
	Variable angle0, angleRange // radians
	Variable &xmin, &ymin, &xmax, &ymax	// rectangle corners
	
	if( angleRange < 0 )
		angle0 += angleRange
		angleRange= -angleRange
	endif
	if( angle0 < 0 )
		angle0 += 2*pi
	endif
	
	Variable quadrant, lastAngle= angle0+angleRange
	
	xmin= 0
	ymin= 0
	xmax= 0
	ymax= 0
	
	Variable angleX, angleY, angle=angle0, done=0
	do
		angleX= radius*cos(angle)
		angleY= radius*sin(angle)
		
		if( angleX < xmin )
			xmin= angleX
		elseif( angleX > xmax )
			xmax= angleX
		endif
		
		if( angleY < ymin )
			ymin= angleY
		elseif( angleY > ymax )
			ymax= angleY
		endif
		
		if( done )
			break
		endif
		
		quadrant= 1 + floor(angle/(pi/2))	// next quadrant
		angle= quadrant * pi/2
		
		if( angle >= lastAngle )
			// do last angle
			angle= lastAngle
			done= 1
		endif
	while(1)

End

// x1,y1,x2,y2 are inputs and outputs, the endpoints of a line to be clipped to xmin,xmax,ymin,ymax.
//
// returns 0 if that segment is not visible in xmin,xmax,ymin,ymax (x1,y1,x2,y2 weren't changed)
// returns 1 if that segment is visible WITHOUT clipping (x1,y1,x2,y2 weren't changed)
// returns 2 if that segment is visible WITH clipping (x1 or y1 were changed), pt1changed==2)
// returns 3 if that segment is visible WITH clipping (x1 or y1 and x2 or y2 were changed)
// returns 4 if that segment is visible WITH clipping (x2 or y2 were changed, pt2changed= 4)
Function WMPolarClipLineToRect(x1,y1,x2,y2,xmin,xmax,ymin,ymax)
	Variable &x1, &y1, &x2, &y2		// line endpoints, possibly clipped on output
	Variable xmin,xmax,ymin,ymax		// clipping box

	Variable reversed= 0
	Variable pt1changed= 0
	Variable pt2changed= 0
	Variable j, xt,yt,dy,dx,dxy,qx,qXX,qy,qYY,U1,U2,U3,U4

	// 1. see if segment is outside of "rectangle" xmin,xmax,ymin,ymax
	if( (x1 < xmin) %& (x2 < xmin) )
		return 0
	endif
	if( (x1 > xmax) %& (x2 > xmax) )
		return 0
	endif
	if( (y1 < ymin) %& (y2 < ymin) )
		return 0
	endif
	if( (y1 > ymax) %& (y2 > ymax) )
		return 0
	endif
	// 2. maintain x2,y2 to the "right" of x1,y1
	if( y1 > y2 )
		xt=x1; yt=y1
		x1=x2; y1=y2
		x2=xt; y2=yt
		reversed = 1
	else
		// 3. horizontal line
		if( y1 == y2 )
			if( x1 > x2 )
				xt=x1; yt=y1
				x1=x2; y1=y2
				x2=xt; y2=yt
				reversed = 1
			endif
			if( x1 < xmin )	// try x1= min(x1,xmin), etc
				x1= xmin
				pt1changed= 2 + reversed*2
			endif
			if( x2 > xmax )
				x2= xmax
				pt2changed= 4 - reversed*2
			endif
			if( reversed )	// put them back in same order
				xt=x1; yt=y1
				x1=x2; y1=y2
				x2=xt; y2=yt
			endif
			return  (pt1changed+pt2changed)%|1
		endif
	endif
	// 4. vertical line
	if( x1 == x2 )
		if( y1 < ymin )
			y1= ymin
			pt1changed= 2 + reversed*2
		endif
		if( y2 > ymax )
			y2= ymax
			pt2changed= 4 - reversed*2
		endif
		if( reversed )	// put them back in same order
			xt=x1; yt=y1
			x1=x2; y1=y2
			x2=xt; y2=yt
		endif
		return  (pt1changed+pt2changed)%|1
	endif
	// 5. do corners
	dy= y1-y2
	dx= x1-x2
	dxy= x1*y2-y1*x2
	qx= xmin*dy
	qXX=xmax*dy
	qy= ymin*dx
	qYY= ymax*dx
	U1= qx-qy+dxy
	U2= qx-qYY+dxy
	U3= qXX-qYY+dxy
	U4= qXX-qy+dxy
	// 6.
	j= 0
	// 7. Line intersects xmin?
	if( sign(U1) != sign(U2) )
		j+=1
		if( x1 < xmin )
			y1= (xmin*dy+dxy)/dx
			x1= xmin
			dy= y1-y2;dx= x1-x2;dxy= x1*y2-y1*x2  // update dy, dx, dxy
			pt1changed= 2 + reversed*2
		endif
		if( x2 < xmin )
			y2= (xmin*dy+dxy)/dx
			x2= xmin
			dy= y1-y2;dx= x1-x2;dxy= x1*y2-y1*x2  // update dy, dx, dxy
			pt2changed= 4 - reversed*2
		endif
	endif
	// 8. Line intersects ymax ?
	if( sign(U2) != sign(U3) )
		j+=1
		if( y2 > ymax )
			x2= (ymax*dx-dxy)/dy
			y2= ymax
			dy= y1-y2;dx= x1-x2;dxy= x1*y2-y1*x2  // update dy, dx, dxy
			pt2changed= 4 - reversed*2
		endif
	endif
	// 9. Line intersects xmax ?
	if( sign(U3) != sign(U4) )
		j+=1
		if( x1 > xmax )
			y1= (xmax*dy+dxy)/dx
			x1= xmax
			dy= y1-y2;dx= x1-x2;dxy= x1*y2-y1*x2  // update dy, dx, dxy
			pt1changed= 2 + reversed*2
		endif
		if( x2 > xmax )
			y2= (xmax*dy+dxy)/dx
			x2= xmax
			dy= y1-y2;dx= x1-x2;dxy= x1*y2-y1*x2  // update dy, dx, dxy
			pt2changed= 4 - reversed*2
		endif
	endif
	// 10. Line intersects ymin ?
	if( sign(U4) != sign(U1) )
		j+=1
		if( y1 < ymin )
			x1= (ymin*dx-dxy)/dy
			y1= ymin
			pt1changed= 2 + reversed*2
		endif
	endif
	
	if( reversed )	// put them back in same order
		xt=x1; yt=y1
		x1=x2; y1=y2
		x2=xt; y2=yt
	endif
	return  (pt1changed+pt2changed)%| (j>0)	// bitwise or
End

Function WMPolarDrawClippedLine(graphName, x1,y1,x2,y2,xmin,xmax,ymin,ymax)	// returns 0 if invisible, 1 if not clipped, 2 if only x1,y1 clipped, 3 or 4 if x2,y2 clipped
	String graphName
	Variable x1,y1,x2,y2,xmin,xmax,ymin,ymax

	Variable visible= WMPolarClipLineToRect(x1,y1,x2,y2,xmin,xmax,ymin,ymax)	// 0 if invisible, 1 if not clipped, 2 if only x1,y1 clipped, 3 or 4 if x2,y2 clipped
	if( visible )
		DrawLine/W=$graphName x1, y1, x2, y2
	endif
	return visible
End

Function/D WMPolarDrawClippedLineSize(graphName,x1,y1,x2,y2,xmin,xmax,ymin,ymax,lineSize)	// returns 0 if invisible, 1 if not clipped, 2 if only x1,y1 clipped, 3 or 4 if x2,y2 clipped
	String graphName
	Variable x1,y1,x2,y2,xmin,xmax,ymin,ymax,lineSize

	Variable visible= WMPolarClipLineToRect(x1,y1,x2,y2,xmin,xmax,ymin,ymax)	// 0 if invisible, 1 if not clipped, 2 if only x1,y1 clipped, 3 or 4 if x2,y2 clipped
	if( (visible>0) && (lineSize>0) )	// if visible
		DrawLine/W=$graphName x1, y1, x2, y2
	endif
	return visible
End


// Computes new radius starts in DATA COORDINATES into wAdjustedRadii to prevent spokes from coming too close together.
// angleInc CANNOT BE ZERO!
// Returns angle ticks, possibly smaller than angleMinorTicks if minspacing is violated at radiusEnd
Function WMPolarCalcAdjustedRadiuses(wAdjustedRadii,angleMinorTicks,angleInc,radiusStart,radiusEnd,radiusInc,minspacing,radiusFunction,valueAtCenter)
	Wave  wAdjustedRadii
	Variable angleMinorTicks,angleInc,radiusStart,radiusEnd,radiusInc	// data coordinates
	Variable minspacing	// DRAWN coordinates
	String radiusFunction
	Variable valueAtCenter

	Variable deltaAngle,spacing, angle,angleTicks,radStart,radEnd,limitedRad
	Variable n

	NVAR firstMajorRadiusTick
	NVAR lastMajorRadiusTick

	// Verify that the angleMinorTicks don't violate minspacing at radiusEnd:
	// spoke spacing at r,deltaAngle is 2 * r * sin(deltaAngle/2)
	radEnd=WMPolarRadiusFunction(lastMajorRadiusTick,radiusFunction,valueAtCenter)  // last major radius tick in DRAWN units
	Variable radNextToLast= WMPolarRadiusFunction(lastMajorRadiusTick-radiusInc,radiusFunction,valueAtCenter)  // next-to-last major radius tickmark in DRAWN units

	angleMinorTicks= round(abs(angleMinorTicks))
	angleInc= abs(angleInc)
	deltaAngle= angleInc/(angleMinorTicks+1)
	spacing= 2 * radNextToLast * sin(deltaAngle/2)	// Drawn units: notice that the constraint is applied to the next-to-last major radius tickmark
	wAdjustedRadii= radiusStart	// by default, the radius grids all start at the beginning of the radius range.
	if( spacing < minspacing )	// minspacing prevents even the outer-most radius increment from using angleMinorTicks
		// recompute angleMinorTicks
		// minspacing <= 2 * (radiusEnd-radiusInc) * sin(angleInc/(angleMinorTicks+1)/2)	// solve for angleMinorTicks
		// minspacing/2/(radiusEnd-radiusInc) <= sin(angleInc/(angleMinorTicks+1)/2)
		// next step assumes that angleInc is between 180 and -180, not zero, and angleMinorTicks is at least 1 )
		// asin(minspacing/2/(radiusEnd-radiusInc)) <= angleInc/(angleMinorTicks+1)/2
		// -1 + 2/angleInc * asin(minspacing/2/(radiusEnd-radiusInc)) <=  angleMinorTicks
		angleTicks= max(0,floor(-1 + 2/angleInc * asin(minspacing/2/(radEnd-radiusInc))))
		// angleTicks must be a submultiple of angleMinorTicks
		angleMinorTicks= max(0,WMPolarBiggestSubmultiple(angleTicks+1,angleMinorTicks+1)-1)
	endif
	deltaAngle= angleInc/(angleMinorTicks+1)
	SetScale/P x ,0,deltaAngle,wAdjustedRadii	// so we can get radius as a function of angle offset, too!
	if( angleMinorTicks > 0)
		// Then compute the radius that all spokes may be drawn from,
		// minspacing <= 2 * radStart * sin(deltaAngle/2))	// solve for radStart
		radStart= minspacing /2 /sin(deltaAngle/2)	// solved for DRAWN radius
		Variable dataRadStart=WMPolarRadiusFunctionInv(radStart,radiusFunction,valueAtCenter)	// data radius, but not multiple of radiusStart + n * radiusInc
		if( minSpacing > 0 )
			n=  ceil((dataRadStart-firstMajorRadiusTick)/radiusInc)
			dataRadStart= firstMajorRadiusTick + radiusInc * n
		endif
		wAdjustedRadii= limit(dataRadStart,radiusStart,radiusEnd) // if we stopped here, all spokes would start here
		if( (dataRadStart > radiusStart) && (angleMinorTicks %& 0x1) )	// angleMinorTicks must be odd!
			angleTicks=angleMinorTicks
			do
				angleTicks= WMPolarSubDivideTicks(angleTicks)	// find submultiple (preferably odd), and find smallest ring that doesn't violate minspacing
				deltaAngle= angleInc/(angleTicks+1)
				radStart= minspacing /2 /sin(deltaAngle/2)	// solved for DRAWN radius
				dataRadStart=WMPolarRadiusFunctionInv(radStart,radiusFunction,valueAtCenter)	// data radius, but not multiple of radiusStart + n * radiusInc
				n=  ceil((dataRadStart-firstMajorRadiusTick)/radiusInc)
				dataRadStart= firstMajorRadiusTick + radiusInc * n
				limitedRad=  limit(dataRadStart,radiusStart,radiusEnd)
				angle= deltaAngle
				do
					Variable row= x2pnt(wAdjustedRadii,angle)
					if( row >= numpnts(wAdjustedRadii) )
						break	// avoid "Index out of range" messages.
					endif
					wAdjustedRadii[row]= limitedRad // adjust only those spokes for the angles of interest
					angle += deltaAngle
				while( angle < angleInc )
			while( (dataRadStart > radiusStart) %& (angleTicks > 2) )	 // then try every other one of those, etc.
		endif
	else
		angleMinorTicks= 0
	endif
	return angleMinorTicks	// possibly modified, 0 means no ticks possible with minspacing honored
End

// 9.02: Added a feature to polar graphs where a cleared drawing layer
// can be optionally drawn into before the polar graph code draws.

Function WMPolarInitLayerFuncProto(String polarGraphName)
	//Print "WMPolarInitLayerFuncProto(\""+ polarGraphName + "\")"
	return 0 // user didn't write a function
End

Function WMPolarClearDrawLayer(String graphName, String layerName)

	SetDrawLayer/W=$graphName/K $layerName // IMPORTANT: THIS CHANGES THE CURRENT DRAWING LAYER

	Variable result= -1
	String functionName= "PolarGraphInit"+layerName+"Layer"
	FUNCREF WMPolarInitLayerFuncProto fref = $functionName
	String info= FuncRefInfo(fref)
	Variable isProto = NumberByKey("ISPROTO",info)
	if( !isProto )
		result = fref(graphName)
	endif
	return result	
End

// clears the layer only if the FUNCREF exists.
// Saves and restores the current drawing layer,
// but don't try to use this routine if drawing is in insert mode.
Function WMPolarPossiblyClearDrawLayer(String graphName, String layerName)

	Variable result= -1
	String functionName= "PolarGraphInit"+layerName+"Layer"
	FUNCREF WMPolarInitLayerFuncProto fref = $functionName
	String info= FuncRefInfo(fref)
	Variable isProto = NumberByKey("ISPROTO",info)
	if( !isProto )
		String oldLayer= WMPolarCurrentDrawLayer(graphName)
		SetDrawLayer/W=$graphName/K $layerName
		result = fref(graphName)
		SetDrawLayer/W=$graphName/K $oldLayer
	endif

	return result
End

// Version 9.03 can draw all of the polar graph axes, labels, fills to zero
// on one selectable drawing layer by always drawing in the same order
// but using group names to possibly delete and insert drawing objects
// as if they were in virtual drawing layers, drawn in this order back to front
// on only one actual drawing layer:
//
// Virtual Drawing Layer Group Name
// ---------------------------------
// init<draw layer name> (eg "initProgAxes")
// 	gridBackground
// 	fillToZeroBack
// 	polarGrid
// 	polarAxes
// 	polarAxisLabels
// 	fillToZeroFront
//
// Any of these virtual layers may be empty of drawing objects,
// but the group names will still appear in recreation macros.

StrConstant ksPolarVirtualLayers ="gridBackground;fillToZeroBack;polarGrid;polarAxes;polarAxisLabels;fillToZeroFront;"

// Version 9.02: Added a feature to polar graphs where a cleared drawing layer
// can be optionally drawn into before the polar graph code draws.
//
// Version 9.03: that drawing is done in (the first) virtual layer
// before gridBackground.
Function/S WMPolarVirtualInitLayerName(drawLayer)
	String drawLayer // "ProgAxes", etc.
	
	return "init"+drawLayer
End

// if the virtual layers are present, nothing is one and 0 is returned.
// otherwise (the virtual layers are missing) empty ones are added to the drawLayer and 1 is returned.
Function WMPolarEnsureVirtualLayers(graphName, drawLayer)
	String graphName, drawLayer

	Variable hadVirtualLayer = HaveVirtualLayer(graphName, drawLayer, "gridBackground")
	if( hadVirtualLayer )
		return 0
	endif

	WMPolarInitVirtualLayers(graphName, drawLayer)
	return 1
End

Function WMPolarInitVirtualLayers(graphName, drawLayer)
	String graphName, drawLayer

	WMPolarInitDrawLayer(graphName, drawLayer)	// init<draw layer name> (eg "initProgAxes")

	String virtualLayersList= ksPolarVirtualLayers
	Variable i, n=ItemsInList(virtualLayersList)
	for(i=0; i<n; i+=1)
		String virtualLayer= StringFromList(i,virtualLayersList)
		EmptyVirtualLayer(graphName, drawLayer, virtualLayer)
	endfor
	
	WMPolarGraphRecordCurrentDrawLayer(graphName,drawLayer) // if missing or "no", polar graph was drawn on multiple layers, and they need clearing out.
End

Function WMPolarGraphWantsVirtualLayers(graphName)
	String graphName
	
	Variable wantVirtualLayers= WMPolarGraphGetVarOrDefault(graphName,"axesDrawInOneVirtualLayer",0)
	return wantVirtualLayers
End

// returns the drawing layer CONTAINING the virtual layers (if any layer does)
// or returns the drawing layer the user would WANT the virtual layers to be in.
Function/S WMPolarGraphWantedDrawLayer(graphName)
	String graphName
	
	String drawLayer= WMPolarGraphGetStr(graphName,"axesDrawLayer")
	if( strlen(drawLayer) == 0 ) 	// 9.031: making a graph from an existing old polar graph won't have a wanted drawing layer
		drawLayer = "ProgAxes"		// below traces and above images, default for 9.03
	endif
	return drawLayer
End


// returns truth that we WANT to draw into virtual layers
Function/S WMPolarGraphCurrentDrawLayer(graphName)
	String graphName
	
	String drawLayer = GetUserData(graphName,"","polarGraphUsesVirtualLayers")
	return drawLayer
End

// record the drawing layer that CONTAINS virtual layers
Function/S WMPolarGraphRecordCurrentDrawLayer(graphName,drawLayer)
	String graphName, drawLayer

	String oldDrawLayer = GetUserData(graphName,"","polarGraphUsesVirtualLayers")
	SetWindow $graphName userdata(polarGraphUsesVirtualLayers)=drawLayer

	WMPolarGraphSetStr(graphName,"axesDrawLayer",drawLayer) // 9.031

	return oldDrawLayer
End

// Call WMPolarSwitchDrawLayer ONLY if drawing into virtual layers (9.03+),
// and NOT drawing into multiple layers (pre-9.03)
Function WMPolarSwitchDrawLayer(graphName, drawLayer)
	String graphName, drawLayer
	
	String lastDrawnDrawLayer = WMPolarGraphCurrentDrawLayer(graphName) // "" if previously drawing into multiple layers (pre-9.03)
	Variable switched = CmpStr(drawLayer,lastDrawnDrawLayer) != 0

	if( switched )
		if( strlen(lastDrawnDrawLayer) )
			DeleteVirtualLayers(graphName, lastDrawnDrawLayer,ksPolarVirtualLayers)
			// delete the Init layer if no FUNCREF to draw in it exists.
			WMPolarPossiblyDeleteInitVirtualLayer(graphName,lastDrawnDrawLayer)
		else
			// converting from multi-layer (legacy) drawing to virtual layers
			// clear out the multi-layer drawings.
			WMPolarClearAllLayers(graphName)
		endif
		if( strlen(drawLayer) ) // technically, empty drawLayer here is an error.
			WMPolarEnsureVirtualLayers(graphName, drawLayer)
		endif
		WMPolarGraphRecordCurrentDrawLayer(graphName,drawLayer)
	endif
	return switched
End

Function WMPolarDeleteInitVirtualLayer(graphName, drawLayer)
	String graphName, drawLayer

	String virtualLayer= WMPolarVirtualInitLayerName(drawLayer)
	Variable deleted = strlen(virtualLayer)
	if( deleted )
		DeleteVirtualLayer(graphName, drawLayer, virtualLayer)
	endif
	return deleted
End

Function WMPolarPossiblyDeleteInitVirtualLayer(graphName, drawLayer)
	String graphName, drawLayer

	Variable deleted = !WMPolarInitDrawLayerHasFUNCREF(graphName, drawLayer)
	if( deleted )
		String virtualLayer= WMPolarVirtualInitLayerName(drawLayer)
		DeleteVirtualLayer(graphName, drawLayer, virtualLayer)
	endif
	return deleted
End


// Version 9.02 added a feature to polar graphs where a cleared drawing layer
// can be optionally drawn into before the polar graph code draws.
//
// Version 9.03: that drawing is done in the first virtual layer.
Function WMPolarInitDrawLayer(graphName, drawLayer)
	String graphName, drawLayer

	SetDrawLayer/W=$graphName/K $drawLayer // IMPORTANT: THIS CHANGES THE CURRENT DRAWING LAYER
	String virtualLayer= WMPolarVirtualInitLayerName(drawLayer)

	Variable hadVirtualLayer= StartVirtualLayerRedraw(graphName, drawLayer, virtualLayer)
	// User does drawing between StartVirtualLayerRedraw() and EndVirtualLayerRedraw() calls.

	Variable result= -1
	String functionName= WMPolarInitDrawLayerInitFuncName(drawLayer)
	FUNCREF WMPolarInitLayerFuncProto fref = $functionName
	String info= FuncRefInfo(fref)
	Variable isProto = NumberByKey("ISPROTO",info)
	if( !isProto )
		result = fref(graphName)
	endif

	EndVirtualLayerRedraw(graphName, drawLayer, virtualLayer, hadVirtualLayer)
	return result	
End

Function/S WMPolarInitDrawLayerInitFuncName(drawLayer)
	String drawLayer
	
	String functionName= "PolarGraphInit"+drawLayer+"Layer"
	return functionName
ENd

Function WMPolarInitDrawLayerHasFUNCREF(graphName, drawLayer)
	String graphName, drawLayer

	String functionName= WMPolarInitDrawLayerInitFuncName(drawLayer)
	FUNCREF WMPolarInitLayerFuncProto fref = $functionName
	String info= FuncRefInfo(fref)
	Variable isProto = NumberByKey("ISPROTO",info)
	return !isProto
End

static Function/S GraphDrawLayers()
	String items= "ProgBack;UserBack;ProgAxes;UserAxes;ProgFront;UserFront;"
	if( IgorVersion() >= 10 )
		items += "ProgTop;UserTop;"	
	endif
	return items
End

Function WMPolarDeleteAllVirtualLayers(graphName)
	String graphName
	
	String drawingLayers= GraphDrawLayers()
	Variable i, n=ItemsInList(drawingLayers)
	for(i=0; i<n; i+=1 )
		String drawLayer = StringFromList(i,drawingLayers)
		String virtualLayersList =  WMPolarVirtualInitLayerName(drawLayer)+";"
		virtualLayersList += ksPolarVirtualLayers
		DeleteVirtualLayers(graphName, drawLayer, virtualLayersList)
	endfor
	String traces= WMPolarTraceNameList(0)
	if( ItemsInList(traces) == 0 )
		WMPolarGraphRecordCurrentDrawLayer(graphName,"")
		// the drawing layer used for virtual drawing layers
		// will be set when the first polar trace is appended.
	endif
End

// mostly for recovering from bugs in the Polar Graphs package
Function WMPolarClearAllLayers(graphName)
	String graphName

	if( strlen(graphName) == 0 )
		graphName= WMPolarTopPolarGraph()
	endif
	if( strlen(graphName) == 0 || !WMPolarIsPolarGraph(graphName) )
		return 0 // nothing done
	endif
	
	String oldLayer= WMPolarCurrentDrawLayer(graphName)
	String drawingLayers= GraphDrawLayers()
	Variable i, n=ItemsInList(drawingLayers)
	for(i=0; i<n; i+=1 )
		String drawLayer = StringFromList(i,drawingLayers)
		SetDrawLayer/W=$graphName/K $drawLayer
	endfor
	String traces= WMPolarTraceNameList(0)
	if( ItemsInList(traces) == 0 )
		WMPolarGraphRecordCurrentDrawLayer(graphName,"")
		// the drawing layer used for virtual drawing layers
		// will be set when the first polar trace is appended.
	endif
	SetDrawLayer/W=$graphName $oldLayer
End
