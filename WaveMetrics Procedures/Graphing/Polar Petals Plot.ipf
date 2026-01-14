#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=7.05		// Shipped with Igor 7.05
#include <RosePlot>

// Adds a menu: Windows->New->Polar Petals Plot
// See Polar Petals Plot Help.ihf for details.

Menu "New"
	"Polar Petals Plot", PolarPetalsPlot()
End

Function PolarPetalsPlot()
	String valueWaveName="" // value wave must have as many points as direction wave.
	String directionWaveName=""
	String labelsWaveName=""
	String anglesWaveName="_constant_"
	Variable rosePetalAngle=45
	Variable petalScalePct= 100 // 100 %, 0 is auto, slightly indended from 100%
	Variable petalsInFrontOfAxes= 1 // Yes
	Variable stroke=1
	Variable unique= 1 // Yes
	Variable legendFeatures= 1 // none

	Prompt valueWaveName,"Radius Value Wave",popup,WaveList("*",";","DIMS:1,TEXT:0,CMPLX:0")
	Prompt directionWaveName,"Direction Wave (0-360 degrees)",popup,"_Radius X Scaling_;"+WaveList("*",";","DIMS:1,TEXT:0,CMPLX:0")
	Prompt anglesWaveName,"Petal Widths Wave (degrees)",popup,"_Constant_;"+WaveList("*",";","DIMS:1,TEXT:0,CMPLX:0")
	Prompt labelsWaveName,"Labels Wave (text)",popup,"_none_;"+WaveList("*",";","DIMS:1,TEXT:1,CMPLX:0")

	Prompt rosePetalAngle, "Constant Petal Width, 0 = auto"
	Prompt petalScalePct, "Rose Petal Angle %, 0-100, 0 = auto"
	Prompt petalsInFrontOfAxes, "Petals In Front of Axes", popup,"Yes;No;" // 1,2
	Prompt stroke, "Line Stroke (points), 0 = none"
	Prompt unique, "Unique Petal Colors", popup,"Yes;No;" // 1,2
	Prompt legendFeatures, "Legend", popup,"None;Labels;Labels+Values;" // 1,2,3

	DoPrompt/HELP="Polar Petals Plot Procedure" "Polar Petals Plot", valueWaveName,directionWaveName,anglesWaveName,labelsWaveName,rosePetalAngle, petalScalePct, petalsInFrontOfAxes, stroke, unique,legendFeatures
	Variable cancelled= V_Flag != 0
	if( !cancelled  )
		Wave/Z vw= $valueWaveName
		if( !WaveExists(vw) )
			DoAlert 0, "Need a value wave!"
			return 1
		endif
		if( CmpStr(directionWaveName,"_Radius X Scaling_") != 0 )
			Wave/Z dw= $directionWaveName
			if( !WaveExists(dw) )
				DoAlert 0, "expected a direction wave!"
				return 1
			endif
			if( numpnts(vw) < numpnts(dw) )
				DoAlert 0, "value wave must have as many points as direction wave!"
				return 1
			endif
		else
			Wave/Z dw= $"" // use _Radius X Scaling_
		endif
		Wave/Z ww= $anglesWaveName
		Wave/T/Z wl= $labelsWaveName
		if( rosePetalAngle <= 0 )
			rosePetalAngle= abs(dw[1]-dw[0]) // degrees
		endif
		Variable isFillBehind = petalsInFrontOfAxes == 2 // true if "No"
		Variable uniqueColors= unique == 1 // true if "Yes"
		legendFeatures -= 1 // 0 is off, 1 is labels, 2 is labels+values 
		NewPolarPetalsPlot(vw, wDir=dw,wPetalAngleWidths=ww,wLabels=wl,petalAngleWidth=rosePetalAngle, petalScalePct=petalScalePct,isFillBehind=isFillBehind,stroke=stroke,wantUniqueColors=uniqueColors,wantLegend=legendFeatures)
	endif
	return cancelled
End

Function/S NewPolarPetalsPlot(wValue [, wPetalAngleWidths, petalAngleWidth, wDir, wLabels, petalScalePct, isFillBehind, wantUniqueColors, fillRed,fillGreen,fillBlue,fillAlpha, stroke, wantLegend])
	// Required
	Wave wValue 				// wValue[p] is radius at wDir[p] or pnt2x(wValue,p)
	// At most one of the following must be specified:
	Wave/Z wPetalAngleWidths	// width of each petal p in degrees
	Variable petalAngleWidth	// width of all petals in degrees. If missing, it is set to 360 / numpnts(wValue)
	// Optional
	Wave/Z wDir 				// direction angle in degrees, if not specified, comes from wValue's X scaling
	Wave/T/Z wLabels 			// names of the elements, if not specified the values are printed into the legend
	Variable petalScalePct			// default is 0 (auto). Use 100 for drawn petals = true petal width (auto is a bit narrower)
	Variable isFillBehind			// default is false: petals are in front of axes
	Variable wantUniqueColors	// default is true. if false, they're all set to red (or fillRed,fillGreen,filllBlue, fillAlpha) If true, only fillAlpha is used for the unique colors
	Variable fillRed,fillGreen,fillBlue	// if wantUniqueColors=0, petals are this color
	Variable fillAlpha			// Igor 7: Regardless of wantUniqueColors, the petals have this opacity. Use alpha=1 for opaque, 0 for no fill (stroke only)
	Variable stroke				// default is 1 (points).
	Variable wantLegend			// 0 is no legend, 1 is legend with only labels, 2 is legend with labels and values. default is 0 (no legend).
	
	if( !WaveExists(wValue) || numpnts(wValue)==0 )
		Print "wValue is empty"
		return ""
	endif
	
	// At most one of the following must be specified:
	if( ParamIsDefault(petalAngleWidth) )
		if( !WaveExists(wPetalAngleWidths) )
			petalAngleWidth = 360 / max(1, numpnts(wValue))
		endif
	endif
	// Optional
	Variable angleFromXScaling = 1 // angle= pnt2x(wValue,p)
	if( ParamIsDefault(wDir) || !WaveExists(wDir) )
		angleFromXScaling = 0	// angle= wDir[p]
	endif
	if( ParamIsDefault(wantUniqueColors) )
		wantUniqueColors= 1 // petals are in front of axes
	endif
	if( ParamIsDefault(isFillBehind) )
		isFillBehind= 0 // petals are in front of axes
	endif
	if( ParamIsDefault(fillRed) )
		fillRed= 65535
	endif
	if( ParamIsDefault(fillGreen) )
		fillGreen= 0
	endif
	if( ParamIsDefault(fillRed) )
		fillRed= 65535
	endif
	if( ParamIsDefault(fillBlue) )
		fillBlue= 0
	endif
	if( ParamIsDefault(fillAlpha) )
		fillAlpha= 65535 // opaque
	else
		fillAlpha= limit(fillAlpha*65535,0,65535) // convert 0-1 to 0-65535
	endif
	if( ParamIsDefault(stroke) )
		stroke= fillAlpha > 0 ? 1 : 0
	endif
	if( ParamIsDefault(wantLegend) )
		wantLegend= 0
	endif
	Variable wantNumbers = wantLegend >=2
	
	// Start a Polar Graph, and set up it's origin and rotation
	WMPolarGraphGlobalsInit()
	String graphName= WMNewPolarGraph("_default_", "")
	WMPolarGraphSetVar(graphName,"zeroAngleWhere",90)// 0 = right, 90 = top, 180 = left, -90 = bottom
	WMPolarGraphSetVar(graphName,"angleDirection", 1)	// 1 == clockwise, -1 == counter-clockwise"

	String oldDF= SetNewPolarPetalDF()
	String workDF=  GetDataFolder(1)

	String prefix= NameOfWave(wValue)[0,30-strlen("_at360")]

	// num petals is min of points in wValue, wPetalAngleWidths, and wDir
	Variable numPetals= numpnts(wValue)
	if( WaveExists(wPetalAngleWidths) )
		numPetals = min(numpnts(wPetalAngleWidths), numPetals)
	endif
	if( WaveExists(wDir) )
		numPetals = min(numpnts(wDir), numPetals)
	endif

	String legendText="", str
	Variable petalNum
	for( petalNum=0; petalNum < numPetals; petalNum+=1 )
		Variable radius= wValue[petalNum]
		Variable angle0
		if( WaveExists(wDir) )
			angle0 = wDir[petalNum]
		else
			angle0 = pnt2x(wValue,petalNum)
		endif
		String petalRadiusName= prefix+"_at"+num2istr(angle0) // this is the name that shows in the Polar Traces popup
		String petalAngleName= prefix+"_a"+num2istr(angle0)

		// Create a rose "petal" which consists of at least 4 radius, angle pairs
		// index		radius					angle
		// [0]		0						0
		// [1]		wValue[petalNum]		angle0 - petalAngleWidth/2
		// (more pairs are inserted here if the petal angle is more than 5 degrees)
		// [2]		wValue[petalNum]		angle0 + petalAngleWidth/2
		// [3]		0						0
		if( WaveExists(wPetalAngleWidths) )
			petalAngleWidth= wPetalAngleWidths[petalNum]
		endif

		Variable petalAngle
		if( petalScalePct )
			petalAngle= petalScalePct/100*petalAngleWidth
		else
			petalAngle= WMRosePlotPetalAngleWidth(petalAngleWidth)	// make drawn petals a bit narrower if they're big (to avoid crowding)
		endif
		
		// max 5 degrees per line segment of the petal's arc
		Variable numPetalAngles= max(2,round(petalAngle / 5))
		Variable petalAngleInc= petalAngle/(numPetalAngles-1)
		Variable petalPoints = (2+numPetalAngles)
	
		Make/O/N=(petalPoints) $petalRadiusName= 0
		Wave petalRadiusWave= $petalRadiusName
		
		Make/O/N=(petalPoints) $petalAngleName= 0
		Wave petalAngleWave= $petalAngleName
		
		Variable segment
		for( segment=0; segment < numPetalAngles; segment+=1 )
			Variable angle= angle0 - petalAngle / 2 + segment * petalAngleInc
			petalRadiusWave[1+segment]= radius
			petalAngleWave[1+segment]= angle
		endfor

		String polarTraceName= WMPolarAppendTrace(graphName,petalRadiusWave, petalAngleWave, 360)
		Variable red= fillRed
		Variable green = fillGreen
		Variable blue= fillBlue
		if( wantUniqueColors )
			WM_GetDistinctColor(petalNum,numPetals,red, green, blue,1)
		endif
		SetPolarFillToOriginPetalPlot(graphName,polarTraceName,red, green, blue, isFillBehind)

		ModifyGraph/W=$graphName lsize($polarTraceName)=stroke

		SetDataFolder workDF	// just in case the the polar graph stuff isn't preserving the current data folder.

		if( wantLegend )
			String name=""
			if( WaveExists(wLabels) )
				name=wLabels[petalNum]
				if( strlen(name) && wantNumbers )
					name +=", "
				endif
			elseif( !wantNumbers )
				sprintf name, "[%d]", petalNum
			endif
	
			sprintf str, "\\K(%d,%d,%d)\\W516\\K(0,0,0)%s", red, green, blue, name
			if( wantNumbers )
				String nums
				if( WaveExists(wPetalAngleWidths) )
					sprintf nums, "r= %g, a= %g, \\F'Symbol'D\\]0 = %g", radius, angle0, petalAngleWidth
				else
					sprintf nums, "r= %g, a= %g", radius, angle0
				endif
				str += nums
			endif
			if( petalNum != numPetals-1 )
				str += "\r"
			endif
			legendText += str
		endif
	endfor
	
	if( wantLegend )
		TextBox/C/N=petalLegend/A=RB/X=-5/Y=0 legendText
	endif

	SetDataFolder oldDF
End


Function/S NewPolarPetalPlotDF()
	
	String dfName=WMPolarNewGraphName()	// name of not-yet-created polar graph: "PolarGraph0", etc.
	String workDF= "root:Packages:PolarPetalPlot:"+dfName // parallel to, but not the same df as Polar Graphs package uses.

	return workDF // the data folder isn't created by this routine.
End

// creates datafolder hierarchy, changes the current data folder to it, and returns old data folder.
Function/S SetNewPolarPetalDF()

	String oldDF= GetDataFolder(1)
	String workDF= NewPolarPetalPlotDF()	// full path
	
	// Ensure each level of the data folders exists
	Variable i, n= itemsInList(workDF,":")
	SetDataFolder root:	// start here
	for( i=1; i<n; i+=1 )	// continue with second level, should be "Packages"
		String dfName= StringFromList(i, workDF, ":")
		NewDataFolder/O/S $dfName
	endfor
	
	return oldDF
End

Function SetPolarFillToOriginPetalPlot(graphName,polarTraceName, red, green, blue, isFillBehind)
	String graphName,polarTraceName
	Variable red, green, blue, isFillBehind
	
	Variable isFillToOrigin,wasFillBehind,fillRed,fillGreen,fillBlue
	String fillYWaveName,fillXWaveName
	String df= WMPolarGetPolarTraceSettings(graphName,polarTraceName,isFillToOrigin,wasFillBehind,fillRed,fillGreen,fillBlue,fillYWaveName,fillXWaveName)
	if( strlen(df) )
		isFillToOrigin= 1
		fillRed= red
		fillGreen= green
		fillBlue= blue
		WMPolarSetPolarTraceSettings(graphName,polarTraceName,isFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue,fillYWaveName,fillXWaveName)
		WMPolarModifyFillToOrigin(graphName,polarTraceName)
	endif
End
