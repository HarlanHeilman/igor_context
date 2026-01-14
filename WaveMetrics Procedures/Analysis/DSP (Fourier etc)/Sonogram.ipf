#pragma rtGlobals=1		// Use modern global access method.
#pragma version=7.09		// shipped with Igor 7.09

// Sonogram.ipf - computes image displaying short-time frequency spectra vs elapsed time.
// See the Sonogram Demo for documentation.

// 4/26/2018 (7.09) - JP
// All built-in color tables may be selected in the the graph created by SG_Display.
//
// 9/22/2010 (6.2) - JP
// Changed the way the first and last segments are calculated:
// they are no longer zero-filled unless the new optional zeroFill parameter is set to non-zero
// (that is, unless the Zero-fill ends checkbox is checked).
// The new default method is to make a shorter FFT and scale the result to match a "full" segment of real data.
//
// 6/4/2009 (6.1) - JP
// Added 0dB Maximum option.
//
// 7/10/2008 (6.04) - JP
// Removed code in SG_Display that used Plan mode to set the initial graph size.
//
// 1/18/2005 (5.04) - JP
// Fixed bug that occurred if no 1-D waves were in the current data folder.
//
// 10/01/2001 (4.05) - JP
// Massively revised to add the optional resolution enhancement, Gabor (Gaussian) smoothing, derivative display,
// sonogram-between-cursors, color table and play sound controls, better definition of window overlap,
// better handling of sonograms at each end of the time data, warnings about problematic values, and balloon help.
// The 4.04 sonogram is still available as SG_Sonogram404().
//
// 08/02/2001 (4.04) - JP
// Initial version.

#include <BringDestToFront>

Menu "New"
	"Sonogram", SG_SonogramPanel()
End

// This is the new sonogram, with optional resolution enhancement and Gabor (Gaussian) method
Function/S SG_sonogram(w,firstPoint, lastPoint, smoothingMethod,seglen,timeIncrementPoints,binsMultiplier,sonogramName,doLog, doDerivative [,maxDbIsZero,zeroFill])
	Wave/Z w
	Variable firstPoint		// first point in w to sonogram ( firstPoint-floor(seglen/2) to firstPoint+seglen/2 will be used in the calculation)
	Variable lastPoint		// last point in w to sonogram (lastPoint-floor(seglen/2) to lastPoint+seglen/2 will be used in the calculation)
	String smoothingMethod	// "Gabor" or "Hanning"
	Variable seglen			// length of signal to FFT in points (length before appending zeros to enhance resolution)
	Variable timeIncrementPoints	// time spacing between spectra
	Variable binsMultiplier	// enhance frequency resolution by appending zeros to make more freq bins.
	String sonogramName	// will be two-D wave in current data folder, will overwrite if existing
	Variable doLog			// 0 for linear amplitude, 20 for dB, other non-zero for log10
	Variable doDerivative	// non-zero for Spectrogram[][] = Spectrogram [p][q] - Spectrogram [p-1][q]
	Variable maxDbIsZero	// OPTIONAL parameter
	Variable zeroFill			// OPTIONAL parameter
	
	if( !WaveExists(w) )
		return ""
	endif
	
	if(  DimSize(w,1) != 0 )	// need one-D wave to do this.
		DoAlert 0, NameOfWave(w)+" is not a one-dimension wave!"
		return ""
	endif
	
	Variable wType= WaveType(w)
	if( wType %& 1 )	// complex
		DoAlert 0, NameOfWave(w)+" is not a real-valued wave!"
		return ""
	endif
	
	if( ParamIsDefault(maxDbIsZero) )
		maxDbIsZero= 0
	endif

	if( ParamIsDefault(zeroFill) )	
		zeroFill= 0
	endif

	Variable needRedimension= wType != 2 && wType != 4
	Variable n= numpnts(w)
	Variable dt= deltax(w)
	
	// some value MUST be integers
	firstPoint=floor(firstPoint)
	lastPoint=floor(lastPoint)
	seglen=floor(seglen)
	timeIncrementPoints= floor(timeIncrementPoints)
	binsMultiplier= floor(binsMultiplier)
	
	Variable seglenLeftHalf = floor(seglen/2)
	
	if( timeIncrementPoints < 0 )
		Variable oldLast=lastPoint
		lastPoint= firstPoint
		firstPoint=oldLast
		timeIncrementPoints *= -1
	endif
	firstPoint = max(-seglenLeftHalf,firstPoint)
	lastPoint= min(n-1-seglenLeftHalf+seglen-1,lastPoint)

	Variable numSpectra=  SG_NumSpectra(n,firstPoint,lastPoint,seglen,timeIncrementPoints) // updates lastPoint

	if( numSpectra < 1 )
		DoAlert 0, "too many bins (or not enough data) to compute even one spectrum with these settings!"
		return ""
	endif
	
	Variable len= lastPoint-firstPoint+1
	Variable bins = floor(seglen/2)		// frequency bins -1 (before appending zeroes)
	Variable fftBins= bins * binsMultiplier+1	// the actual FFT freq bins after appending zeroes
	Make/O/N=(numSpectra,fftBins) $sonogramName
	Wave sonogram= $sonogramName
	
	Wave smoothingWindowDoomed= $SG_WindowForMethod(smoothingMethod,seglen,dt)	// doomed because the first and last segment windowing code might overwrite this wave
	// show we duplicate the wave because the first and last segment redimension the smoothing window wave
	Wave smoothingWindowSeglen= $SG_DuplicateWaveInDataFolder(smoothingWindowDoomed)
	
	Variable spectra
	for( spectra=0; spectra < numSpectra; spectra += 1 )
		// the segment is CENTERED on firstPoint + spectra*timeIncrementPoints
		Variable firstSegmentPoint= firstPoint+spectra*timeIncrementPoints - seglenLeftHalf	// allowed to be negative
		Variable lastSegmentPoint= firstSegmentPoint + seglen -1		// allowed to exceed n
		if( firstSegmentPoint >= n )
			break
		endif
		Variable thisSeglen= lastSegmentPoint-firstSegmentPoint+1	// 6.21: each segment might have different length
		if( firstSegmentPoint >= 0 && lastSegmentPoint < n  )
			Duplicate/O/R=[firstSegmentPoint,lastSegmentPoint] w, segment
			Wave segmentSmoothingWindow= smoothingWindowSeglen
		else
			if( zeroFill )	// this is the method used prior to version 6.21
				// zero-fill points before w[0] and after w[n-1]
				// first, copy range of actual data
				Variable validStart= max(0,firstSegmentPoint)
				Variable validEnd= min(n-1,lastSegmentPoint)
				Duplicate/O/R=[validStart,validEnd] w, segment
				// prepend any missing zeros
				Variable missingZeros= max(0,0-firstSegmentPoint)
				if( missingZeros )
					InsertPoints 0, missingZeros, segment
				endif
				missingZeros= max(0,lastSegmentPoint - (n-1))
				if( missingZeros )
					InsertPoints numpnts(segment), missingZeros, segment	// append
				endif
	
				Wave segmentSmoothingWindow= smoothingWindowSeglen
			else	// default as of Igor 6.21.
				// rather than zero-fill, do a shorter FFT
				if( firstSegmentPoint < 0 )
					firstSegmentPoint= 0
				endif
				if( lastSegmentPoint >= n  )
					lastSegmentPoint= n-1
				endif
				thisSeglen= lastSegmentPoint-firstSegmentPoint+1
				Duplicate/O/R=[firstSegmentPoint,lastSegmentPoint] w, segment
	
				Wave smoothingWindowShort= $SG_WindowForMethod(smoothingMethod,thisSeglen,dt)
				Wave segmentSmoothingWindow= smoothingWindowShort
			endif
		endif

		if( needRedimension )	// can't smooth an integer wave (and we wouldn't want to introduce that much quantization to the smoothed result, anyway)
			Redimension/S segment
		endif
		segment *= segmentSmoothingWindow[p] * sqrt(seglen/thisSeglen)	// scale shorter segments to achieve about the same integral of mag sqr as a full segment.
		
		if( binsMultiplier > 1 )
			Redimension/N=(thisSeglen*binsMultiplier) segment	// append zeroes
		else
			thisSeglen= ceil(thisSeglen/2)*2			// even, rounded up
			Redimension/N=(thisSeglen) segment	// append a zero if thisSeglen was odd.
		endif
#ifdef TEST_SHORT_FFT
	if( spectra==0 )
		DoWindow/K Segs
		Duplicate/O segment, segment0
		Display/N=Segs segment0
	elseif( spectra == 1 )
		Duplicate/O segment, segment1
		AppendToGraph/W=Segs segment1
		ModifyGraph/W=Segs/Z rgb[1]=(0,0,65535)
		Legend/W=Segs
	endif
#endif
		FFT segment
		Wave/C sg=segment			// segment is now complex
		if( thisSeglen == fftBins )
			Make/O/N=(fftBins) magsqrSpectrum = magsqr(sg[p])
		else
			Make/O/N=(thisSeglen) magsqrSpectrumShort = magsqr(sg[p])
			Make/O/N=(fftBins) magsqrSpectrum= magsqrSpectrumShort[p*thisSeglen/seglen]// map shorter segment into same number of columns.
		endif
		sonogram[spectra][]= sqrt(magsqrSpectrum[q])

#ifdef TEST_SHORT_FFT
	if( spectra==0 )
		DoWindow/K MagSqrs
		Make/O/N=(numpnts(sg)) magSqrSeg0= magsqr(sg)
		Display/N=MagSqrs magSqrSeg0
		Duplicate/O magsqrSpectrum, magsqrSpectrum0
		AppendToGraph/W=MagSqrs magsqrSpectrum0
		ModifyGraph/W=MagSqrs/Z rgb[1]=(0,65535,0)
	elseif( spectra == 1 )
		Duplicate/O magsqrSpectrum, magsqrSpectrum1
		AppendToGraph/W=MagSqrs magsqrSpectrum1
		ModifyGraph/W=MagSqrs/Z rgb[2]=(0,0,65535)
		Legend/W=MagSqrs
	endif
#endif

	endfor
	if( doDerivative )
		Variable lastSpectra= DimSize(sonogram,0)-1
		for( spectra= lastSpectra; spectra >= 0; spectra -= 1)
			if( spectra > 0 )
				sonogram[spectra][] -= sonogram[spectra-1][q]
			else
				sonogram[0][] = 0
			endif
		endfor
	endif
	switch( doLog )
		case 0:	// linear
			break
		case 20:	// dB
			sonogram= 20*log(sonogram)
			if( maxDbIsZero )
				ImageStats/M=1 sonogram
				sonogram -= V_Max
			endif
			break
		default:		// log
			sonogram= log(sonogram)
			break
	endswitch
	KillWaves/Z segment,smoothingWindowSeglen,smoothingWindowShort,magsqrSpectrum,magsqrSpectrumShort
#ifndef TEST_SHORT_FFT
	KillWaves/Z segment0, segment1, magSqrSeg0, magsqrSpectrum0, magsqrSpectrum1
#endif
	// Set the units and scaling of the sonogram result
	SetScale/P x, pnt2x(w,firstPoint), dt * timeIncrementPoints, WaveUnits(w,0), sonogram
	String yUnits=""
	if( CmpStr(WaveUnits(w,0), "s" ) == 0 )	// "s" or "S"
		yUnits= "Hz"
	endif
	SetScale/I y, 0, 1/(2*dt), yUnits, sonogram	// Hz if input is time
	String dUnits=""
	switch( doLog )
		case 0:		// linear
			if( strlen(WaveUnits(w,-1)) )
				dUnits=WaveUnits(w,-1)+"/Hz"
			endif
			break
		case 20:	// dB
			dUnits= "dB"
			break
		default:		// log
			dUnits= "log"
			break
	endswitch
	SetScale d, 0, 0, dUnits, sonogram
	
	return GetWavesDataFolder(sonogram,2)	// full path
End

// SG_Sonogram404 is the old sonogram that shipped with Igor 4.04.
// The new sonogram (with resolution enhancement, Gabor smoothing, and derivatives) is now SG_Sonogram.
//
// output is full path to sonogram
// This sonogram overlaps each segment with 50%
// of the prevous segment and uses Hanning smoothing on each segment
//
Function/S SG_Sonogram404(w,bins,sonogramName,doLog)
	Wave/Z w
	Variable bins	// the actual number of frequency bins is 1 more than this (0:512 is 513 bins)
	String sonogramName	// will be two-D wave in current data folder, will overwrite if existing
	Variable doLog			// 0 for linear amplitude, 20 for dB, other non-zero for log10
	
	if( !WaveExists(w) )
		return ""
	endif
	
	if(  DimSize(w,1) != 0 )	// need one-D wave to do this.
		DoAlert 0, NameOfWave(w)+" is not a one-dimension wave!"
		return ""
	endif
	
	Variable wType= WaveType(w)
	if( wType %& 1 )	// complex
		DoAlert 0, NameOfWave(w)+" is not a real-valued wave!"
		return ""
	endif
	Variable needRedimension= wType != 2 && wType != 4

	Variable seglen= bins*2				// how much time data goes into each FFT
	Variable numSpectra=floor(numpnts(w)/(seglen/2) -1)	// 50% overlap, and we'll throw extra points away.
	if( numSpectra < 1 )
		DoAlert 0, "too many bins (or not enough data) to compute even one spectrum!"
		return ""
	endif
	
	Make/O/N=(numSpectra,bins+1) $sonogramName
	Wave sonogram= $sonogramName
	Variable overlap= bins				// how much time we advance between each FFT
	Variable spectra
	for( spectra=0; spectra < numSpectra; spectra += 1 )
		Variable firstPoint= spectra*overlap
		Variable lastPoint= firstPoint + seglen -1
		Duplicate/O/R=[firstPoint,lastPoint] w, segment	// segment is real
		Wave segment
		if( needRedimension )	// can't smooth an integer wave (and we wouldn't want to introduce that much quantization to the smoothed result, anyway)
			Redimension/S segment
		endif
		Hanning segment		// needs 50% overlap
		FFT segment
		Wave/C sg=segment			// segment is now complex
		switch( doLog )
			case 0:		// linear
				sonogram[spectra][]= sqrt(magsqr(sg[q]))
				break
			case 20:	// dB
				sonogram[spectra][]= 20*log( sqrt(magsqr(sg[q])) )
				break
			default:		// log
				sonogram[spectra][]=log( sqrt(magsqr(sg[q])) )
				break
		endswitch
	endfor
	KillWaves/Z segment
	// Set the units and scaling of the sonogram result
	Variable dt= deltax(w)
	SetScale/P x, leftx(w), dt * overlap, WaveUnits(w,0), sonogram
	String yUnits=""
	if( CmpStr(WaveUnits(w,0), "s" ) == 0 )	// "s" or "S"
		yUnits= "Hz"
	endif
	SetScale y, 0, 1/(2*dt), yUnits, sonogram	// Hz if input is time
	String dUnits
	switch( doLog )
		case 0:		// linear
			dUnits=WaveUnits(w,-1)+"/Hz"
			break
		case 20:	// dB
			dUnits= "dB"
			break
		default:		// log
			dUnits= "log"
			break
	endswitch
	SetScale d, 0, 0, dUnits, sonogram
	
	return GetWavesDataFolder(sonogram,2)	// full path
End

Function SG_Display(timeData,image)
	Wave/Z timeData	// optional
	Wave image			// not
	
	Display/W=(5,44,586,435)
	AppendImage image
	
	if( WaveExists(timeData) )
		AppendToGraph/L=timeLeft timeData
		Variable sonoLeftPct=80
		ModifyGraph axisEnab(left)={1-sonoLeftPct/100,1}
		ModifyGraph axisEnab(timeLeft)={0,1-sonoLeftPct/100-.05},freePos(timeLeft)={0,bottom}
	endif
	ModifyGraph margin(right)=100, gfSize=10
	ModifyGraph mirror(left)=1, mirror(bottom)=1
	ModifyGraph standoff=0
	
	// this code was intended to make the sonogram image pixels square.
	// It got rather confused on some data sets.
//	Variable n= DimDelta(image,0) * 72/ ScreenResolution	// points/units?
//	if( DimSize(image,0) < 200 )
//		n /= max(1,ceil(200 / DimSize(image,0)))
//	endif
//	ModifyGraph width={perUnit,1/n,bottom}
//	n= DimDelta(image,1) * 72/ ScreenResolution
//	if( DimSize(image,1) < 200 )
//		n /= max(1,ceil(200 / DimSize(image,1)))
//	endif
//	ModifyGraph height={perUnit,1/n,left}

	String name=NameOfWave(image)
	String ctabName= StrVarOrDefault("root:Packages:sonogram:ctabName","Grays")
	Variable reversed= NumVarOrDefault("root:Packages:sonogram:ctabChecked",1)
	ModifyImage $name ctab= {*,*,$ctabName,reversed}	// ensure the controls initially match this setting
	ColorScale/C/N=text0/E/A=RC/X=1.00/Y=12.00 image=$name
	
	// Controls
	String colorTableList=CTabList()
	Variable whichOne= 1+max(0,WhichListItem(ctabName, colorTableList))
	ControlBar 32
	PopupMenu ctab,pos={7,7},size={117,20},proc=SG_CTabPopMenuProc
	colorTableList= "\""+colorTableList+"\""
	PopupMenu ctab,mode=whichOne,popvalue=ctabName,value= #colorTableList
	CheckBox reversed,pos={161.00,11},size={62,14},proc=SG_ReversedCTabCheckProc,title="Reversed",value=reversed
	Button play,pos={233,7},size={80,20},proc=SG_PlaySoundButtonProc,title="Play Sound"

	// cursors
	if( WaveExists(timeData) )
		Cursor A, $NameOfWave(timeData), leftx(timeData)
		Cursor B, $NameOfWave(timeData), rightx(timeData)
		ShowInfo
	else
		Variable yAvg= DimOffset(image,1) + DimSize(image,1)/2 * DimDelta(image,1)
		Variable xmin= DimOffset(image,0)
		Variable xmax= DimOffset(image,0) + (DimSize(image,0) -1) * DimDelta(Image,0)
		Cursor/I A, $name, xmin, yAvg
		Cursor/I B, $name, xmax , yAvg
		ShowInfo
	endif
	// establish initial window size.
//	DoUpdate
//	ModifyGraph width=0, height=0	// Release perUnit
EndMacro

Function SG_SonogramPanel()
	PauseUpdate; Silent 1		// building Sonogram panel...
	
	DoWindow/K SonogramPanel
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:Sonogram
	Variable resolution= NumVarOrDefault("root:Packages:Sonogram:frequencyResolutionHz",1000)
	Variable/G root:Packages:Sonogram:frequencyResolutionHz=resolution
	Variable inc= NumVarOrDefault("root:Packages:Sonogram:timeIncrementPoints",1)
	Variable/G root:Packages:Sonogram:timeIncrementPoints=inc
	
	NewPanel /K=1/W=(590,43,820,436) as "Sonogram"	// NewPanel positions are in pixels
	DoWindow/C SonogramPanel
	ModifyPanel fixedSize=1, noEdit=1

	PopupMenu timeDataPop,pos={6,9},size={152,20},proc=SG_DataPopMenuProc,title="Time data:",help={"Select a time wave from the current data folder."}
	PopupMenu timeDataPop,mode=1,value= #"WaveList(\"*\",\";\",\"DIMS:1\")+\"_none_\""
	TitleBox fs,pos={10,34},size={166,12},title="Sampling frequency (Hz):", frame=0,help={"The time data wave is presumed to have X scaling in seconds."}
	TitleBox totalDataPoints,pos={10,53},size={88,12},title="Total data points:",frame=0,help={"The number of values in the time data wave."}

	CheckBox betweenCursors,pos={10,73},size={181,14},proc=SG_BetweenCursorsCheckProc,title="Sonogram points between cursors."
	CheckBox betweenCursors,value= 0, disable=2
	CheckBox betweenCursors,help={"Use the X range of the cursors to define the sonogram time range. Disabled if no cursors are on the time data wave."}
	TitleBox cursorPoints,pos={31,93},size={122,12},title="Points between cursors: ",frame=0, disable=2
	TitleBox cursorPoints,help={"The number of time data points that are selected by the cursors."}
	GroupBox data,pos={0,112},size={252,4}, frame=0

	PopupMenu method,pos={7,122},size={166,20},proc=SG_PopMenuProc,title="Sonogram method:"
	PopupMenu method,mode=1,value= #"\"Gabor;Hanning\""
	PopupMenu method,help={"Each spectrum in the sonogram is smoothed by a Gabor (Gaussian) or a Hanning window."}
	SetVariable resolutionHz,pos={10,152},size={212,15},proc=SG_SetVarProc,title="Frequency resolution (Hz):"
	SetVariable resolutionHz,limits={0,1000,10},value= root:Packages:Sonogram:frequencyResolutionHz
	SetVariable resolutionHz,help={"Better (smaller) frequency resolution requires more time points per spectrum."}
	TitleBox seglen,pos={10,175},size={129,12},title="Time points per spectrum:",frame=0
	TitleBox seglen,help={"Each spectrum (sonogram column) has half this many rows if no Extra frequency bins are used. Red when the value may be too large or small."}

	GroupBox overlap,pos={4,193},size={224,73}
	SetVariable timeIncrement,pos={10,199},size={182,15},proc=SG_TimeIncSetVarProc,title="Generate spectrum every"
	SetVariable timeIncrement,limits={1,inf,10},value= root:Packages:Sonogram:timeIncrementPoints
	SetVariable timeIncrement,help={"Use 1 to generate a spectrum at each time sample, or use the checkboxes for faster computation."}
	TitleBox everypoints,pos={194,200},size={30,12},title="points",frame=0
	CheckBox auto50overlap,pos={30,221},size={118,14},proc=SG_OverlapCheckProc,title="always 50% overlap",value= 0
	CheckBox auto50overlap,help={"Generate a spectrum every 50% of the Time points per spectrum value."}
	CheckBox auto75overlap,pos={154,221},size={42,14},proc=SG_OverlapCheckProc,title="75%",value= 0
	CheckBox auto75overlap,help={"Generate a spectrum every 25% of the Time points per spectrum value."}
	CheckBox auto875overlap,pos={154,235},size={52,14},proc=SG_OverlapCheckProc,title="87.5%",value= 0
	CheckBox auto875overlap,help={"Generate a spectrum every 12.5% of the Time points per spectrum value."}
	CheckBox auto0overlap,pos={154,249},size={69,14},proc=SG_OverlapCheckProc,title="no overlap",value= 0
	CheckBox auto0overlap,help={"Generate a spectrum every 100% of the Time points per spectrum value. "}
	TitleBox nSpectra,pos={10,246},size={115,12},title="Number of spectra:",frame=0
	TitleBox nSpectra,help={"The number of spectra (sonogram rows). Red when the value may be too large or small."}

	PopupMenu binsMultiplier,pos={7,273},size={174,20},proc=SG_PopMenuProc,title="Extra frequency bins:"
	PopupMenu binsMultiplier,mode=1,value= #"\"none;x 2;x 4;x 8;x 16\""
	PopupMenu binsMultiplier,help={"Increase the number of FFT bins (sonogram rows). This doesn't generate extra frequency detail, just a smoother appearance."}
	TitleBox totalBins,pos={10,299},size={126,12},title="Total frequency bins:",frame=0
	TitleBox totalBins,help={"The number of rows in each sonogram column, this equals Time points per spectrum/2 * Extra frequency bins + 1.  Red when the value may be too large or small."}
	GroupBox binsGroup,pos={0,320},size={259,4}, frame=0

	CheckBox zeroFill,pos={146,298},size={74,14},proc=SG_ZeroFillCheckProc,title="Zero-fill ends"
	CheckBox zeroFill,help={"When checked, instead of computing a short FFT, zero-fill the first and last segments to make a \"complete\" segment."}
	CheckBox zeroFill,value= 0

	CheckBox derivative,pos={11,330},size={62,14},title="Derivative",value= 0,proc=SG_DerivativeCheckProc
	CheckBox derivative,help={"The difference of adjacent spectra are displayed. Since derivatives can be 0 or negative, log and dB are not appropriate."}

	CheckBox zeroDbMaxCheck,pos={11,345},size={55,14},proc=SG_Normalize0dBCheckProc,title="0dB Max"
	CheckBox zeroDbMaxCheck,value= 0
	CheckBox zeroDbMaxCheck,help={"When using dB Amplitudes, normalize the dB range so that the maximum value is 0 dB."}

	PopupMenu log,pos={100,335},size={110,20},title="Amplitude:"
	PopupMenu log,mode=1,popvalue="linear",value= #"\"linear;log;dB\""
	PopupMenu log,help={"Display the magnitude, log or 20*log10 (dB) of the spectra. log and dB are not appropriate for derivatives, because they can be 0 or negative."}

	Button newsonogram,pos={41,364},size={150,21},proc=SG_DoSonogramButtonProc,title="Compute Sonogram"
	Button newsonogram,help={"Computes the sonogram, and displays it in a (possibly new) graph."}

	SetWindow SonogramPanel hook=SG_SonogramPanelHook
	SG_UpdateParameters()
EndMacro

Function SG_SonogramPanelHook(infoStr)
	String infoStr

	String event= StringByKey("EVENT",infoStr)
	strswitch(event)
		case "activate":
			SG_UpdateParameters()
			break
	endswitch

	return 0
End

Function SG_UpdateParameters()
	ControlInfo/W=SonogramPanel timeDataPop
	if( V_Flag == 3 )
		Wave/Z w= $S_Value
	endif
	if( WaveExists(w) )
		// time data
		TitleBox fs win=SonogramPanel, title="Sampling frequency (Hz): "+num2str(1/deltax(w))
		TitleBox totalDataPoints win=SonogramPanel, title="Total data points: "+num2str(numpnts(w))

		// cursors
		Variable firstPoint=0, lastPoint=numpnts(w)-1
		Variable cursorFirstPoint,cursorLastPoint
		String graphName= SG_FindGraphWithWaveAndCursors(w,cursorFirstPoint,cursorLastPoint)
		Variable canCursor= strlen(graphName) > 0
		String title="Points between cursors: "
		Variable cursorDisable
		if( canCursor )
			title += num2istr(cursorLastPoint - cursorFirstPoint + 1)
			cursorDisable= 0
		else
			cursorDisable= 2
			CheckBox betweenCursors, win=SonogramPanel, value=0	// don't allow checked if it can't be done.
		endif
		CheckBox betweenCursors, win=SonogramPanel, disable=cursorDisable
		TitleBox cursorPoints, win=SonogramPanel,title=title, disable=cursorDisable
		// if we *can* use cursors and we *want* to use cursors, sonogram a subset of the data.
		ControlInfo/W=SonogramPanel betweenCursors
		if( V_Value )
			firstPoint=cursorFirstPoint
			lastPoint= cursorLastPoint
		endif

		// method popup
		ControlInfo/W=SonogramPanel method
		String method= S_Value
		
		ControlInfo/W=SonogramPanel resolutionHz
		Variable deltaF= V_Value
		Variable seglen= SG_SeglenForMethodDeltaF(w,method,deltaF) // length before zero-padding.
		// warnings
		if( seglen < 16 || seglen > 5000 )
			TitleBox seglen win=SonogramPanel, labelBack=(65535	,40000,40000), title=" Time points per spectrum: "+num2istr(seglen)+" "
		else
			TitleBox seglen win=SonogramPanel, labelBack=0, title="Time points per spectrum: "+num2istr(seglen)
		endif

		// handle auto-overlap settings.
		NVAR timeInc=root:Packages:Sonogram:timeIncrementPoints
		ControlInfo/W=SonogramPanel auto0overlap
		if( V_Value)
			timeInc= max(1,floor(seglen))	// inc % = 100-overlap%
		endif
		ControlInfo/W=SonogramPanel auto50overlap
		if( V_Value)
			timeInc= max(1,floor(seglen * 0.50))
		endif
		ControlInfo/W=SonogramPanel auto75overlap
		if( V_Value)
			timeInc= max(1,floor(seglen * 0.25))	// inc % = 100-overlap%
		endif
		ControlInfo/W=SonogramPanel auto875overlap
		if( V_Value)
			timeInc= max(1,floor(seglen * 0.125))	// inc % = 100-overlap%
		endif
		
		ControlInfo/W=SonogramPanel timeIncrement
		Variable pointsIncrement= max(1,floor(V_Value))
		Variable numSpectra= SG_NumSpectra(numpnts(w),firstPoint,lastPoint,seglen,pointsIncrement)
		
		if( numSpectra < 8 || numSpectra > 5000 )
			TitleBox nSpectra win=SonogramPanel, labelBack=(65535 ,40000,40000), title=" Number of spectra: "+num2istr(numSpectra)+" "
		else
			TitleBox nSpectra win=SonogramPanel, labelBack=0, title="Number of spectra: "+num2istr(numSpectra)
		endif

		ControlInfo/W=SonogramPanel binsMultiplier
		Variable binsMultiplier= 2^(V_Value-1)		// 1, 2, 4, 8, 16
		Variable frequencyBins= seglen/2				// actually one more than this.
		Variable totalBins= frequencyBins * binsMultiplier + 1	// true number of bins generated by FFT
		
		if( totalBins < 16 || totalBins > 5000 )
			TitleBox totalBins win=SonogramPanel, labelBack=(65535,40000,40000), title=" Total frequency bins: "+num2istr(totalBins)+" "
		else
			TitleBox totalBins win=SonogramPanel, labelBack=0, title="Total frequency bins: "+num2istr(totalBins)
		endif
		
	else
		TitleBox fs win=SonogramPanel, title="Sampling frequency (Hz): "
		TitleBox totalDataPoints win=SonogramPanel, title="Total data points: "
		CheckBox betweenCursors,win=SonogramPanel,value= 0
		TitleBox cursorPoints,win=SonogramPanel,disable=2, title="Points between cursors: "
		TitleBox seglen win=SonogramPanel, title="Time points per spectrum: "
		TitleBox nSpectra win=SonogramPanel, title="Number of spectra: "
		TitleBox totalBins win=SonogramPanel, title="Total frequency bins: "
	endif
	return WaveExists(w)
End


Function SG_ReversedCTabCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	ControlInfo ctab
	ModifyImage $"#0" ctab= {*,*,$S_Value,checked}
	Variable/G root:Packages:sonogram:ctabChecked= checked
End

Function SG_CTabPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	ControlInfo reversed
	ModifyImage $"#0" ctab= {*,*,$popStr,V_Value}
	String/G root:Packages:sonogram:ctabName= popStr
End

Function SG_GetCursorXs(graphName,xa, xb)
	String graphName
	Variable &xa, &xb	// not updated if no cursors.
	
	// Handle cursors, if any
	Variable haveCursors = 0
	if( strlen(graphName) == 0 )
		graphName= WinName(0,1)
	endif
	Wave/Z cwa=CsrWaveRef(A,graphName)
	Wave/Z cwb=CsrWaveRef(B,graphName)
	if( WaveExists(cwa) && WaveExists(cwb) )
		haveCursors= 1
		xa=hcsr(A,graphName)
		xb= hcsr(B,graphName)
	endif
	return haveCursors
End

Function SG_CursorsOnTimeWave(w)
	Wave/Z w
	
	Variable haveCursors=0
	if( WaveExists(w) )
		Variable firstPoint,lastPoint
		String graphName= SG_FindGraphWithWaveAndCursors(w,firstPoint,lastPoint)
		haveCursors= strlen(graphName)> 0
	endif
	return haveCursors
End
	
Function/S SG_FindGraphWithWaveAndCursors(w,firstPoint,lastPoint)
	wave w
	Variable &firstPoint,&lastPoint
	
	string win=""
	variable i=0
	Variable xa,xb
	do
		win=WinName(i, 1)				// name of ith graph window
		if( strlen(win) == 0 )
			break;							// no more graph wndows
		endif
		CheckDisplayed/W=$win  w
		if(V_Flag)	// found graph with wave
			if( SG_GetCursorXs(win,xa, xb) )	// have both cursors, too.
				Variable pa= x2pnt(w,xa)
				Variable pb= x2pnt(w,xb)
				firstPoint= min(pa,pb)
				lastPoint= max(pa,pb)
				break
			endif
		endif
		i += 1
	while(1)
	return win
end

// "The wave's time per point, as determined by its X scaling,
// must be between 2e-4 and 1.5625e-5 which corresponds
// to sampling rates of 5000 to 64000 Hertz."
Function SG_CanPlaySound(w)
	Wave/Z w
	
	if( WaveExists(w) )
		Variable fs= 1/deltax(w)
		if( fs >= 5000 && fs < 64000 )
			return 1
		endif
	endif
	return 0
End

Function SG_PlaySoundButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/Z w= WaveRefIndexed("",0,1) 	// Returns first Y wave in the top graph.
	if( WaveExists(w) )
		// Handle cursors, if any
		Variable firstPoint, lastPoint
		String graphName= SG_FindGraphWithWaveAndCursors(w,firstPoint,lastPoint)
		if( CmpStr(graphName,WinName(0,1)) != 0 )	// but cursors are not in this graph
			firstPoint=0
			lastPoint= numpnts(w)-1
		endif
		Variable n= lastPoint-firstPoint+1
		
		WaveStats/Q/R=[firstPoint,lastPoint] w
		Variable amplitude= 32767 / max(V_Max-V_Avg,V_Avg-V_Min)
		Make/w/o/n=(n) root:Packages:Sonogram:soundWave = amplitude*(w[p+firstPoint]-V_Avg)
		Wave soundWave= root:Packages:Sonogram:soundWave
		CopyScales/P w, soundWave
		if(! SG_CanPlaySound(soundWave) )
			Variable fs= 22050
			if( n /  fs < 2 )	// if less than two seconds at 22.05Khz
				fs= 5000	// use the lowest frequency allowed.
			endif
			SetScale/P x, 0, 1/fs, "", soundWave
		endif
		PlaySound soundWave
		KillWaves/Z soundWave
	endif
End

//
// The number of spectra is based on the assumption
// that each segment is *centered* at firstPoint + spectraNum * seglen.
// This means that not only is wave[firstPoint] used in the calculations,
// but so are wave[firstPoint-floor(seglen/2),firstPoint-floor(seglen/2)+seglen].
// This behavior includes the idea of zero-extending before the start of wave[0]
// and after wave[npnts-1].
Function SG_NumSpectra(npnts,firstPoint,lastPoint,seglen,pointsIncrement)
	Variable npnts
	Variable firstPoint, lastPoint
	Variable seglen, pointsIncrement

	if( pointsIncrement < 0 )
		Variable oldLast=lastPoint
		lastPoint= firstPoint
		firstPoint=oldLast
		pointsIncrement *= -1
	endif
	Variable seglenLeftHalf = floor(seglen/2)
	
	if( (lastPoint < firstPoint) || (lastPoint-seglenLeftHalf +seglen < 0) || (firstPoint - seglenLeftHalf  > npnts-1) )
		return 0
	endif

	Variable len=lastPoint-firstPoint+1
	Variable numSpectra = max(0, ceil(len/pointsIncrement))
	return numSpectra
End

Function SG_DerivativeCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	if( checked )
		PopupMenu log,mode=1,popvalue="linear", disable=2	// log of a derivative makes lots of -Infs
	else
		PopupMenu log, disable=0	
	endif
	ControlUpdate log
	CheckBox zeroDbMaxCheck, value=0
End

Function SG_Normalize0dBCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	if( checked )
		PopupMenu log,mode=3,popvalue="dB", disable=2
	else
		PopupMenu log, disable=0	
	endif
	ControlUpdate log
	CheckBox derivative, value=0
End

Function SG_ZeroFillCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	//SG_UpdateParameters()
End

Function SG_OverlapCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	if( checked )	// we need to uncheck the others
		CheckBox auto0overlap,win=SonogramPanel,value= CmpStr(ctrlName,"auto0overlap") == 0
		CheckBox auto50overlap,win=SonogramPanel,value= CmpStr(ctrlName,"auto50overlap") == 0
		CheckBox auto75overlap,win=SonogramPanel,value= CmpStr(ctrlName,"auto75overlap") == 0
		CheckBox auto875overlap,win=SonogramPanel,value= CmpStr(ctrlName,"auto875overlap") == 0
	endif

	SG_UpdateParameters()
End

Function/S SG_DuplicateWaveInDataFolder(w)
	Wave w
	
	String dfSav = GetDataFolder(1)
	SetDataFolder GetWavesDataFolder(w,1)
	String dupName=NameOfWave(w)[0,28] + "_2"
	Duplicate/O w, $dupName/WAVE=dup
	String path= GetWavesDataFolder(dup,2)	// full path
	SetDataFolder dfSav
	return path
End

Function/S SG_WindowForMethod(smoothingMethod,len,dt)
	String smoothingMethod
	Variable len,dt
	
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:Sonogram
	Make/O/N=(len) root:Packages:Sonogram:smoothingWindow
	Wave smoothingWindow= root:Packages:Sonogram:smoothingWindow
	
	strswitch( smoothingMethod	)
		case "Gabor":
			Variable twidthPoints=len/4	// see SG_SeglenForMethodDeltaF
			Variable twidth= twidthPoints * dt
			Variable centerPoint= len/2
			smoothingWindow= 1/twidth * exp(-(2*pi*(p-centerPoint) / twidthPoints * (p-centerPoint) / twidthPoints))
			smoothingWindow[0]=0
			smoothingWindow[len-1]=0
			break
		case "Hanning":
		default:
			smoothingWindow= 1
			Hanning smoothingWindow
			break
	endswitch
	WaveStats/Q smoothingWindow
	smoothingWindow /= V_Avg	// normalize average to 1.0.
	return GetWavesDataFolder(smoothingWindow,2)	// full path
End

Function  SG_SeglenForMethodDeltaF(w,method,deltaF)
	Wave w
	String method
	Variable deltaF	// frequency resolution in Hz
	
	Variable fs= 1/deltax(w)
	Variable seglen
	strswitch(method)
		case "Gabor":
			Variable twidth= 1/deltaF	// not to be confused with the sampling interval, this is the gaussian width param
			Variable twidthPoints=	twidth/deltax(w)
			seglen= 4 * twidthPoints	// not clipped to integer (yet)
			break
		case "Hanning":
		default:
			seglen= fs/deltaf
			break
	endswitch
	// limit segment length to wave's total length
	seglen=min(numpnts(w),seglen)
	seglen= max(2,2*floor(seglen/2))	// limit to even values
	return seglen	
End


Function SG_TimeIncSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	CheckBox auto0overlap,win=SonogramPanel,value= 0
	CheckBox auto50overlap,win=SonogramPanel,value= 0
	CheckBox auto75overlap,win=SonogramPanel,value= 0
	CheckBox auto875overlap,win=SonogramPanel,value= 0
	NVAR timeInc= root:Packages:Sonogram:timeIncrementPoints
	timeInc= max(1,floor(timeInc))
	SG_UpdateParameters()
End


Function SG_SetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	SG_UpdateParameters()
End

Function SG_BetweenCursorsCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	SG_UpdateParameters()

End

Function SG_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	SG_UpdateParameters()
End

Function SG_DataPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Wave/Z w= $popStr
	if( WaveExists(w) )
		Variable fs= 1/ deltax(w)
		Variable increment= SG_NiceNumber(fs/2 * 0.005)	// 0.5%
		Variable lowerLimit= SG_NiceNumber(fs/numpnts(w))
		SetVariable resolutionHz win=SonogramPanel, limits={lowerLimit,fs/2,increment}
	endif
	SG_UpdateParameters()
End

// round to 1, 2, or 5 * 10eN, non-rigorously
Function SG_NiceNumber(num)
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
	if( frac < log(1.5) )	// above 1.5, choose 2
		mant= 1
	else
		if( frac < log(4) )	// above 4, choose 5
			mant= 2
		else
			if( frac < log(8) )	// above 8, choose 10
				mant= 5
			else
				mant= 10
			endif
		endif
	endif
	num= theSign * mant * 10^decade
	return num
End


// this code avoids naming a wave the same as a macro name
Function/S SG_SonogramOutputName(baseName)
	String baseName
	
	baseName=baseName[0,25]
	String name= CleanupName(baseName+"_sonogram",1)
	if( exists(name) == 0 || exists(name) == 1)
		return name
	endif
	Variable count=0
	baseName=baseName[0,23]	// two more chars for 0 to 99
	do
		name= CleanupName(baseName+"_sonogram"+num2istr(count),1)
		count += 1
	while(exists(name) != 0 && exists(name) != 1 && count <= 99 )
	return name
End


Function SG_DoSonogramButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo/W=SonogramPanel timeDataPop
	Wave/Z w= $S_Value
	if( WaveExists(w) == 0 )
		Beep
		DoAlert 0, "No Time data wave selected."
		return -1
	endif
	String sonogramName=SG_SonogramOutputName(NameOfWave(w))

	// cursors	
	Variable firstPoint=0
	Variable lastPoint=numpnts(w)-1

	Variable cursorFirstPoint,cursorLastPoint
	String graphName= SG_FindGraphWithWaveAndCursors(w,cursorFirstPoint,cursorLastPoint)
	Variable canCursor= strlen(graphName) > 0
	if( canCursor )
		ControlInfo/W=SonogramPanel betweenCursors
		if( V_Value )
			firstPoint=cursorFirstPoint
			lastPoint= cursorLastPoint
		endif
	endif

	ControlInfo/W=SonogramPanel method
	String smoothingMethod= S_Value
	NVAR deltaF= root:Packages:Sonogram:frequencyResolutionHz
	Variable seglen= SG_SeglenForMethodDeltaF(w,smoothingMethod,deltaF) // length before zero-padding.

	NVAR timeInc= root:Packages:Sonogram:timeIncrementPoints

	ControlInfo/W=SonogramPanel binsMultiplier
	Variable binsMultiplier= 2^(V_Value-1)		// 1, 2, 4, 8, 16

	// Zero-fill
	Variable zeroFill= 0
	ControlInfo/W=SonogramPanel zeroFill
	if( V_Flag )
		zeroFill= V_Value
	endif
	
	ControlInfo/W=SonogramPanel log
	Variable doLog= 0
	strswitch( S_Value )
		case "Log":
			doLog= 1
			break
		case "dB":
			doLog= 20
			break
	endswitch
	
	ControlInfo/W=SonogramPanel derivative
	Variable doDerivative= V_Value
	
	ControlInfo/W=SonogramPanel zeroDbMaxCheck
	Variable maxDbIsZero= V_Value
	
	Wave/Z sonogram= $SG_sonogram(w,firstPoint,lastPoint,smoothingMethod,seglen,timeInc,binsMultiplier,sonogramName,doLog,doDerivative,maxDbIsZero=maxDbIsZero,zeroFill=zeroFill)
	if( WaveExists(sonogram) )
		graphName= FindGraphWithWave(sonogram)
		if( !strlen(graphName) )
			SG_Display(w,sonogram)
		endif
	endif
End