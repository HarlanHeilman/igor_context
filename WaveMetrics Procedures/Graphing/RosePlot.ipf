#pragma rtGlobals=1		// Use modern global access method.
#pragma moduleName=WMRosePlot
#pragma IgorVersion=5.03	// for eventName in window hook.
#pragma version=9		// shipped with Igor 9
// Initial version 5.03, 10/28/2004, JP
// Version 5.04, 1/3/2005, JP - bug fix for zero point speed waves (empty "petals").
// Version 6.23, 2/7/2012, JP - adjustible maximum petalAngle via Override function WMRosePlotPetalAngleWidth()
// Version 6.38, 8/24/2016, JP - Rose Plot data folder path mimics the Polar Graphs package, to avoid data overwriting
//							when same-named speed waves from different data folders are used to create Rose Plots.
//							Fixed legend when there is a calm bin, calm bin hides outlines because they overlay the bin and look wonky.
// Version 9, 7/13/2021, JP - Added binCenter parameter, which was previously always 0
#include <New Polar Graphs>
#include <colorSpaceConversions>

Menu "New"
	"Rose Plot",/Q, RosePlot()
End

// Wind Rose Plots
//
// In a wind rose graph each angle's maximum radius is the percentage or the probability (%/100)
// that the wind is blowing FROM that angle, no matter what the speed.
//
// The input data consists of two waves:
//		one wave of directions/angles in positive-only degrees (0-359.99),
//		one wave of speeds in, say, meters/second.
//
// All of the wind speeds whose angles fall within the angle bin are histogrammed,
// and the histogram multiplied by frequency/numberOfSpeedValues.
//
// Say we use 90 degree angle binning, then there are 4 angle bins.
// Usually these are +/-45 degree bins, with the first one centered on 0.
//
// For each of these angle bins, say we use 5 speed bins: 0-5, 5-10, 10-15, and 20-25, and values > 25 in
// We use the Extract operation to extract the speeds related to each of the 4 angle bins.
// Then each of these angle-specific wind speed waves is histogramed into "speed bins".
//
// Because of the way they're plotted, the speed bin waves are integrated to
// implement the stacked bar of a rose plot.
//
// The first speed bin from all the angles are collected into a "ring" of "petals".
// The second speed bins are all collected into a second ring, etc.
//
// These rings are appended to a polar graph, with the last speed bin ring appended first (and thus on the bottom)
// and the first speed bin ring appended last (and thus on the top).
// Each ring is given a distinctive color so you can see where each bin is located on each petal.
//
// A legend showing the speed bin ranges is created and appended to the polar graph.
//
// All of the constructed waves are created in a Packages:WMRosePlot:<PolarGraphName>: data folder.
//
// 11/01/2004 - Added optional "calm bin" (plotted last, on top, and in the center as a full circle).
//
// 7/1/2021 - Added binCenter parameter (was previously always 0).

// Demonstration data:
Proc MakeTestWindData(numValues)
	Variable numValues=100
	
	Make/O/N=(numValues) directionDegrees= round(abs(mod(gnoise(360), 360)))	// 0-359
	Make/O/N=(numValues) speedMS= round( abs(gnoise(20))) 	// rounding to make binning edge cases more likely
	
	WMNewRosePlot(directionDegrees, speedMS, 2, 30, 1, 10, 40)	// percent
End

Function RosePlot()
	String directionWaveName, speedWaveName
	Variable radiusUnits = 1 // probability aka "frequency", use 100 for %
	Variable angleBinWidth = 45	// 8 bins
	Variable binCenter = 0		// first bin's center defaults to 0
	Variable speedBinWidth = 10
	Variable calmSpeedBin = 0			// no calm bin
	Variable maxSpeed = 100		// the last bin is maxSpeed+
	Prompt directionWaveName,"Direction Wave (0-360 degrees)",popup,WaveList("*",";","DIMS:1,TEXT:0,CMPLX:0")
	Prompt speedWaveName,"Speed Wave",popup,WaveList("*",";","DIMS:1,TEXT:0,CMPLX:0")
	Prompt binCenter, "Center of First Bin (degrees)"	// added for version 9
	Prompt radiusUnits,"Radius units", popup, "Probability (0-1);Percent (0-100);"
	Prompt angleBinWidth,"Angle Bin Width (degrees)"
	Prompt speedBinWidth,"Speed Bin Width"
	Prompt calmSpeedBin,"Calm Bin Max (0 for none)"
	Prompt maxSpeed,"Last Speed+ Bin"
	
	DoPrompt/HELP="Rose Plot Procedure" "Rose Plot", directionWaveName, angleBinWidth, speedWaveName, binCenter, radiusUnits, calmSpeedBin, speedBinWidth, maxSpeed

	if( V_Flag == 0  )
		Wave/Z dw= $directionWaveName
		Wave/Z sw= $speedWaveName
		if( !WaveExists(dw) || !WaveExists(sw) )
			DoAlert 0, "Need both a direction wave and a speed wave!"
			return 1
		endif
		Variable radiusMax= (radiusUnits == 1) ? 1 : 100
		WMNewRosePlot(dw, sw, radiusMax, angleBinWidth, calmSpeedBin, speedBinWidth, maxSpeed, binCenter=binCenter)
	endif
	return V_Flag
End

// Igor 6.23:
// To override WMRosePlotPetalAngleWidth() in your own code, define WMRosePlotPetalAngleWidth()
// like this in your main Procedure window:
//
//Override Function WMRosePlotPetalAngleWidth(angleBinWidth)
//	Variable angleBinWidth
//	// Keep the drawn petal the same angle width as the actual bin width
//	return angleBinWidth
//End

Function WMRosePlotPetalAngleWidth(angleBinWidth)
	Variable angleBinWidth

	Variable petalAngleWidth= angleBinWidth
	if( angleBinWidth > 30 )
		petalAngleWidth = 30 + (angleBinWidth-30) / 4	// angle bins wider than 30 degrees are rendered a bit narrower to avoid crowding
	endif
	return petalAngleWidth
End

Function/S WMNewRosePlotDF()
	
	String dfName=WMPolarNewGraphName()	// name of not-yet-created polar graph: "PolarGraph0", etc.
	String workDF= "root:Packages:RosePlot:"+dfName // parallel to, but not the same df as Polar Graphs package uses.

	return workDF // the data folder isn't created by this routine.
End

// creates datafolder hierarchy, changes the current data folder to it, and returns old data folder.
Function/S WMSetNewRosePlotDF(wSpeed)
	Wave wSpeed // not used

	String oldDF= GetDataFolder(1)
	String workDF= WMNewRosePlotDF()	// full path
	
	// Ensure each level of the data folders exists
	Variable i, n= itemsInList(workDF,":")
	SetDataFolder root:	// start here
	for( i=1; i<n; i+=1 )	// continue with second level, should be "Packages"
		String dfName= StringFromList(i, workDF, ":")
		NewDataFolder/O/S $dfName
	endfor
	
	return oldDF
End

Function WMNewRosePlot(wDir, wSpeed, radiusMax, angleBinWidth, calmSpeedBin, speedBinWidth, maxSpeed [,binCenter])
	Wave wDir			// wind direction in degrees
	Wave wSpeed		// wind speed
	Variable radiusMax	// 1 for probability/frequency, 100 for percent
	Variable angleBinWidth	// in degrees, use 90 to get 4 bins
	Variable calmSpeedBin	// speeds less than this are considered direction-less and are combined into a circle at the origin, normally 0
	Variable speedBinWidth	// each bin contains this much speed range (except the last)
	Variable maxSpeed		// last speed bin contains this value + all that exceed this value.
	Variable binCenter		// optional
	if( ParamIsDefault(binCenter) )
		binCenter= 0
	endif

	Variable totalSpeeds= numpnts(wSpeed)
	if( totalSpeeds != numpnts(wDir) )
		DoAlert 0, "direction and speed waves must have the same number of points"
		return 0
	endif

	String prefix= NameOfWave(wSpeed)[0,30-strlen("spiHistAtAngle359")]
	
	String oldDF= WMSetNewRosePlotDF(wSpeed)
	
	String workDF=  GetDataFolder(1)

	Variable numAngleBins = round(360 / angleBinWidth)
	Variable halfAngleBin= angleBinWidth/2
	
	Variable numSpeedBins= 1+round(maxSpeed / speedBinWidth)	// ex: 60/10 = 6 bins
	Variable numCalmBins= 0, calmSpeeds=0, calmRadius= 0
	if( calmSpeedBin > 0 )
		numCalmBins= 1
		// extract all the calm speed values regardless of direction
	
		String calmSpeedsWaveName= prefix+"calmSpeeds"
		Extract/O wSpeed, $calmSpeedsWaveName, (wSpeed < calmSpeedBin)
		WAVE cs= $calmSpeedsWaveName
		calmSpeeds= numpnts(cs)	// count speed values < calmSpeedBin
		
		calmRadius= calmSpeeds * radiusMax / totalSpeeds	// calm circle's radius
		
		// optional calculation for debugging	
		String calmAnglesWaveName= prefix+"calmAngles"
		Extract/O wDir, $calmAnglesWaveName,  (wSpeed < calmSpeedBin)
	endif

	Variable i
	for(i=0; i < numAngleBins; i+=1 )
		String suffix= num2istr(i*angleBinWidth)
	
		// The first angle bin is centered on 0
		Variable angleStart= i*angleBinWidth - halfAngleBin + binCenter
		Variable angleEnd= i*angleBinWidth + halfAngleBin + binCenter

		// optional calculation for debugging	
		String angleWaveName= prefix+"anglesAtAngle"+suffix
		Extract/O wDir, $angleWaveName,  (wSpeed >= calmSpeedBin) && ((wDir >= angleStart && wDir < angleEnd) || ((wDir-360) >= angleStart && (wDir-360) < angleEnd))

		// extract the speeds (those that exceed calmSpeedBin) for only this angle range
		String speedsWaveName= prefix+"speedsAtAngle"+suffix
		Extract/O wSpeed, $speedsWaveName, (wSpeed >= calmSpeedBin) && ((wDir >= angleStart && wDir < angleEnd) || ((wDir-360) >= angleStart && (wDir-360) < angleEnd))
		WAVE sw= $speedsWaveName
		Variable numSpeedsAtAngle= numpnts(sw)	// can be 0

		// histogram the speeds for this angle
		String speedsHistName= prefix+"spHistAtAngle"+suffix

		Make/O/N=(numSpeedBins) $speedsHistName=0
		WAVE hw= $speedsHistName
		if( numSpeedsAtAngle )
			Histogram/B={0, speedBinWidth, numSpeedBins} sw, $speedsHistName
			
			// add missing values to the last bin to make the last bin include all values bigger than the bin range
			Variable missingSpeedsInHistogram=  numpnts(sw) - sum(hw)
			if( missingSpeedsInHistogram )
				hw[numSpeedBins-1] += missingSpeedsInHistogram
			endif
		endif		

		// integrate the histogram so that each bin's value is augmented by the sum of previous bins
		String integratedHistName= prefix+"spiHistAtAngle"+suffix
		Integrate/P hw /D=$integratedHistName
		WAVE ihw= $integratedHistName

		ihw += calmSpeeds	// don't get hidden by the calm bin circle

		// Scale the histogram count by the total number of speeds, as a fraction or as %
		ihw *= radiusMax / totalSpeeds
	endfor
	
	// we create a ring of rose petals from the first speed bin, another ring from the second speed bin.
	Variable petalAngleWidth= WMRosePlotPetalAngleWidth(angleBinWidth)	// make drawn petals a bit narrower if they're big (to avoid crowding)

	Variable numPetalAngles= max(2,round(petalAngleWidth / 5))
	Variable petalAngleInc= petalAngleWidth/(numPetalAngles-1)
	Variable ringWavePoints= (2+numPetalAngles)*numAngleBins
	
	Variable speedBin
	for( speedBin= 0; speedBin < numSpeedBins; speedBin+=1 )
		String ringRadiusName= prefix+"RingRadius"+num2istr(speedBin)
		String ringAngleName= prefix+"RingAngle"+num2istr(speedBin)

		// Create an angle wave for the rose plot.
		// each rose "petal" consists of at least 4 radius, angle pairs
		// index	radius					angle
		// [0]		0						0
		// [1]		speedBin[angleBin]		CenterAngle - angleBinWidth/2 (or /more, perhaps /4)
		// (more pairs are inserted here if the petal angle is more than 5 degrees)
		// [2]		speedBin[angleBin]		CenterAngle + angleBinWidth/2
		// [3]		0						0
		
		Make/O/N=(ringWavePoints) $ringRadiusName= 0
		Wave ringRadius= $ringRadiusName
		
		Make/O/N=(ringWavePoints) $ringAngleName= 0
		Wave ringAngle= $ringAngleName
		
		// For each speed bin,
		// create a wave for all angles using just that one speed bin
		Variable petalRow= 0
		for(i=0; i < numAngleBins; i+=1, petalRow += 2+numPetalAngles )
			suffix= num2istr(i*angleBinWidth)

			integratedHistName= prefix+"spiHistAtAngle"+suffix
			WAVE ihw= $integratedHistName
			Variable radius= ihw[speedBin]
			
			Variable index
			for( index=0; index < numPetalAngles; index+=1 )
				Variable angle= i*angleBinWidth - petalAngleWidth / 2 + index * petalAngleInc + binCenter
				ringRadius[petalRow+1+index]= radius
				ringAngle[petalRow+1+index]= angle
			endfor
		endfor
		
	endfor
	
	// Start a Polar Graph, and set up it's origin and rotation
	WMPolarGraphGlobalsInit()
	String graphName= WMNewPolarGraph("_default_", "")
	WMPolarGraphSetVar(graphName,"zeroAngleWhere",90)// 0 = right, 90 = top, 180 = left, -90 = bottom
	WMPolarGraphSetVar(graphName,"angleDirection", 1)	// 1 == clockwise, -1 == counter-clockwise"

	// now add the rose rings in REVERSE order to a polar graph, while building a legend
	String legendText="", str

	for( speedBin= numSpeedBins-1; speedBin >= 0; speedBin-=1 )
		ringRadiusName= prefix+"RingRadius"+num2istr(speedBin)
		ringAngleName= prefix+"RingAngle"+num2istr(speedBin)
		
		SetDataFolder workDF	// just in case the the polar graph stuff isn't preserving the current data folder.
		
		Wave ringRadius= $ringRadiusName
		Wave ringAngle= $ringAngleName

		String polarTraceName= WMPolarAppendTrace(graphName,ringRadius, ringAngle, 360)
		Variable red, green, blue
		WM_GetDistinctColor(speedBin+numCalmBins,numSpeedBins+numCalmBins,red, green, blue,1)
		SetPolarFillToOrigin(graphName,polarTraceName,red, green, blue)
		Variable binStart= speedBin * speedBinWidth
		Variable binEnd= binStart + speedBinWidth
		if( binStart < calmSpeedBin )
			binStart = calmSpeedBin
		endif
		if( speedBin == numSpeedBins-1 )
			sprintf str, "\\K(%d,%d,%d)\\W516\\K(0,0,0)%g+ ", red, green, blue, binStart
			legendText = str + legendText
		elseif( (numCalmBins == 0) || (binEnd > calmSpeedBin) ) // 6.38
			sprintf str, "\\K(%d,%d,%d)\\W516\\K(0,0,0)%g - %g \r", red, green, blue, binStart, binEnd
			legendText = str + legendText
		endif
	endfor
	
	// add the calm speed bin circle last
	if( calmSpeedBin )
		WM_GetDistinctColor(0,numSpeedBins+numCalmBins,red, green, blue,1)
		if( calmRadius > 0 )
			SetDataFolder workDF	// just in case the the polar graph stuff isn't preserving the current data folder.
			// make a circle out of 5-degree arcs
			numPetalAngles= 1+ 360 / 5
			String calmRadiusName= prefix+"calmRadius"
			Make/O/N=(numPetalAngles) $calmRadiusName= calmRadius
			Wave ringRadius= $calmRadiusName
			
			String calmAngleName= prefix+"calmAngle"
			Make/O/N=(numPetalAngles) $calmAngleName= p * 5
			Wave ringAngle= $calmAngleName
	
			polarTraceName= WMPolarAppendTrace(graphName,ringRadius, ringAngle, 360)
			SetPolarFillToOrigin(graphName,polarTraceName,red, green, blue)
			// 6.38: set line width to 0 to avoid wedge lines overlaying the "calm bin"
			ModifyGraph/W=$graphName lsize=0
		endif
		sprintf str, "\\K(%d,%d,%d)\\W516\\K(0,0,0)0 - %g \r", red, green, blue, calmSpeedBin
		legendText = str + legendText
	endif

	TextBox/C/N=text0/A=RB/X=-5/Y=0 legendText

	SetDataFolder workDF	// just in case the the polar graph stuff isn't preserving the current data folder.
	String/G rosePlotGraphName= graphName	// for future use.
	SetDataFolder oldDF
	
	// Add a hook function to the polar graph to delete the Rose Plot data folder when the graph dies.
	SetWindow $graphName hook(WMRosePlot)= WMRosePlotHook
	SetWindow $graphName userData(WMRosePlot)= workDF
	
	// Cue the user that changes can be made with the Polar Graphs panel.
	WMPolarGraphs(-1)
	
	return 1	// success
End

Static Function WMPossiblyKillRosePlotData(win, dfpath)
	String win, dfpath
	
	if( exists(win) != 5 )
		// no recreation macro exists, it's okay to kill the data folder.
		KillDataFolder/Z dfpath	// also kills any dependency
		// if this is the last one, kill the Packages:RosePlot data folder.
		String dfName = GetIndexedObjName("root:Packages:RosePlot", 4, 0)
		if (strlen(dfName) == 0)
			// no more rose plots!
			KillDataFolder/Z root:Packages:RosePlot
		endif
	endif
End

// Additional polar graph hook
Function WMRosePlotHook(hs)
	STRUCT WMWinHookStruct &hs
	
	Variable ret=0
	strswitch(hs.eventName)
		case "kill":
			String workDF = GetUserData(hs.winName, "", "WMRosePlot")
			Execute/P/Q/Z "WMRosePlot#WMPossiblyKillRosePlotData(\"" + hs.winName + "\", \"" + workDF + "\")"	// once the window has gone away 
			break
	endswitch
	return ret
End

Function SetPolarFillToOrigin(graphName,polarTraceName, red, green, blue)
	String graphName,polarTraceName
	Variable red, green, blue
	
	Variable isFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue
	String fillYWaveName,fillXWaveName
	String df= WMPolarGetPolarTraceSettings(graphName,polarTraceName,isFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue,fillYWaveName,fillXWaveName)
	if( strlen(df) )
		isFillToOrigin= 1
		fillRed= red
		fillGreen= green
		fillBlue= blue
		WMPolarSetPolarTraceSettings(graphName,polarTraceName,isFillToOrigin,isFillBehind,fillRed,fillGreen,fillBlue,fillYWaveName,fillXWaveName)
		WMPolarModifyFillToOrigin(graphName,polarTraceName)
	endif
End

