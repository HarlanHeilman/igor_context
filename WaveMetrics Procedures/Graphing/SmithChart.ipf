// Smith Chart and vector network analyzer support
// Gary W. Johnson, WB9JPS, 1-8-08
//
// https://en.wikipedia.org/wiki/Smith_chart
//
// Run Smith_Chart_GraphREF() first to set up Smith Chart.
//
// Then either append imaginary vs real component of reflection coefficient data,
// or choose Append Complex Wave from the Smith Chart menu
// to graph the real and imaginary components of a complex wave.

#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version=3				// 8-26-21, WM changes for graph resizing, Admittance and SWR Grids
#pragma IgorVersion=9			// Requires Igor 9
#pragma moduleName=SmithChart

Static Constant kDebugging = 0

Menu "New"
	"Smith Chart", /Q, Smith_Chart_GraphREF() 
End

Menu "Smith Chart"
	"New Smith Chart",/Q, Smith_Chart_GraphREF() 
	"Append Complex Wave...",/Q, SmithAppendComplexWave() 
	"Frequency Charts",/Q, SmithFreqCharts("") 
	"Smith Chart Help",/Q,DisplayHelpTopic/K=1 "Smith Chart Procedure"
End

// Given a complex wave containing reflection coefficient data, create two new waves
// containing real and imaginary components, and append them to the top graph.
Function SmithAppendComplexWave()
	String theWave = "gamma" // beware that Igor does have a built-in function named "gamma'.
	Prompt theWave,"Gamma wave",popup,WaveList("*",";","CMPLX:1")  // only complex waves listed
	DoPrompt/HELP="Smith Chart Procedure" "Append Complex Wave", theWave
	if( V_Flag )
		return -1 // cancelled
	endif
	WAVE w = $theWave
	if( WaveExists(w) )
		string theWave_re = theWave+"_re"
		string theWave_im = theWave+"_im"
		Duplicate/O w, $theWave_re, $theWave_im
		WAVE re = $theWave_re
		WAVE im = $theWave_im
		Redimension/R re,im 		// /R converts complex waves to real by discarding the imaginary part
		im = imag(w)
		AppendToGraph im vs re
	else
		Beep
	endif
end

Static Function/S TempDF()
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:SmithChart
	return "root:Packages:SmithChart"
End

// set the data folder to a place where Execute can dump all kinds of variables and waves
Static Function/S SetTempDF()

	String oldDF= GetDataFolder(1)
	NewDataFolder/O/S $TempDF()	// DF is left pointing here
	return oldDF
End

Static Function/S TempDFVar(String varName)
	
	return TempDF()+":"+PossiblyQuoteName(varName)
End

static Function/WAVE FreqWave(String graphName)

	String pathToWave = ""	// path to string containing path to frequency wave associated with data on Smith Chart
	if( WinType(graphName) == 1 )
		pathToWave = GetUserData(graphName, "", "SmithFreqWave")
	endif

	WAVE/Z wf = $pathToWave
	return wf
End

static Function SetFreqWave(String graphName, WAVE/Z freqWave)
	
	if( WinType(graphName) == 1 )
		String pathToWave = ""
		if( WaveExists(freqWave) )
			pathToWave = GetWavesDataFolder(freqWave,2) // full path to frequency wave associated with data on Smith Chart
		endif
		SetWindow $graphName userdata(SmithFreqWave) = pathToWave
	endif
End

Function SmithChartHook(s)
	STRUCT WMWinHookStruct &s 
	
	if ( s.eventCode == 7 )  // 7 is cursormoved		
		// Each time the A cursor moves, update user displays on graph. Uses cursor events.
		UpdateMarkerAReadout(s.winName)
	elseif( s.eventCode == 6 || s.eventCode == 0 )  // 6 is resize, 0 is activate
		FitControlsToGraph(s.winName)
		UpdateSmithLabels(s.winName, 0) // autosized
	endif
End

Function UpdateMarkerAReadout(graphName)
	string graphName
	
	WAVE/Z acw = CsrWaveRef(A,graphName)
	if( WaveExists(acw) )
		Variable pointNumber= pcsr(A,graphName)
		String imNameStr= NameOfWave(acw)// usually Im, but could be SmithY
		Tag/W=$graphName/C/N=markerAIsHere $imNameStr, pointNumber,"\\F'Times New Roman'\\Z12A"
		Variable z0 = Z0ForGraph(graphName)
		variable/c gammaRefl = cmplx( hcsr(A), vcsr(A) )  // complex reflection coefficient
		variable/c Zin = z0 * (gammaRefl+1)/(1-gammaRefl)
		variable ZReal =  real(Zin)
		variable ZImag = imag(Zin)
		variable gammaMag = sqrt( magsqr(gammaRefl) )
		variable gammaPhase = atan2( imag(gammaRefl), real(gammaRefl) ) * 180/pi
		variable theRL = -20 * log(gammaMag) // return loss?
		variable ZinMag =  gammamag * Z0
		variable SWR = (1+gammaMag) / (1-gammaMag)
		if( SWR > 1.0e+16 )	// a marker attached to the outer ring should always show inf for SWR, even if the ring is slightly less than radius = 1
			SWR = inf
		endif

		WAVE/Z phreq = FreqWave(graphName)		// frequency wave associated with data on Smith Chart
		String prt1 = "\\F'Times New Roman'\\f04Marker A\\f00\r"
		String prt2 = ""
		if( WaveExists(phreq) && CmpStr(imNameStr,"SmithY") != 0 && pointNumber < DimSize(phreq,0) )
			variable theFreq = phreq[pointNumber]  // use point number returned by cursor as index into Freq wave
			sprintf prt2, "  Freq = %.3W1PHz\r", theFreq
		endif
		String prt3
		sprintf prt3, "  Γ = %.3g Ω, <%.3g °\r", ZinMag,gammaPhase

		String prt4
		sprintf prt4, "  Z = %.3f  j %.3f Ω\r", Zreal,Zimag

		String chartType = SmithChartType(graphName)
		if( Cmpstr(chartType,"admittance") == 0 )
			// admittanceY = 1/impedance = Gconductance + j Bsusceptance
			// if impedance = ZinMag * e^j gammaPhase,
			// admittance = 1/ZinMag *e^-j gammaPhase
			Variable/C ZPolar = r2polar(Zin)
			Variable Ymag = 1/real(ZPolar)
			Variable YPhase = -imag(ZPolar)
			Variable/C YPolar = p2rect(cmplx(Ymag,YPhase))
			Variable Gconductance = real(YPolar)
			Variable Bsusceptance = imag(YPolar)

			String prtG
			sprintf prtG, "  Y = %.3f  j %.3f mho\r", Gconductance,Bsusceptance
			prt4 += prtG
		endif
		
		String prt5
		sprintf prt5, "  RL = %.3f dB\r", theRL
		
		String prt6
		sprintf prt6, "  SWR = %.3f",SWR

		String prt = prt1+prt2+prt3+prt4+prt5+prt6

		if( kDebugging )
			prt += "\r  Γ\Br\M = "+num2str(gammaMag,"%.3g")
		endif
		TextBox/W=$graphName/C/N=markerA/F=0/B=1/A=LB/X=2/Y=5.4/E=2 prt
	else
		Tag/W=$graphName/K/N=markerAIsHere
		TextBox/W=$graphName/K/N=markerA
	endif
End


// Creates frequency labels at start and end of the first XY plot found on the Smith chart.
// Values come from the global frequency wave selected by user

Function LabelButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			LabelFrequencyEnds(ba.win)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function LabelFrequencyEnds(String graphName)

	Variable removeTags= 1
	WAVE/Z phreq = FreqWave(graphName)
	Variable haveFrequency=WaveExists(phreq)
	if( haveFrequency )
		Variable StartFreq = phreq[0]
		Variable EndPoint = numpnts(phreq)-1
		Variable EndFreq = phreq[EndPoint]

		[WAVE ReWave, WAVE ImWave] = NonSmithWaves(graphName, 1)	 // first non-smith X and Y data wave in graph
		if( WaveExists(ImWave) )
			String traceName= NameOfWave(ImWave) // a bit presumptious
			String prt
			sprintf prt, "\\F'Times New Roman'\\Z10%.1W1PHz", StartFreq
			Tag/W=$graphName/C/N=freqStart $traceName, 0, prt
			sprintf prt, "\\F'Times New Roman'\\Z10%.1W1PHz", EndFreq	
			Tag/W=$graphName/C/N=freqEnd $traceName, EndPoint, prt
			removeTags= 0
		endif
	endif
	if( removeTags )
		Beep;
		if( haveFrequency )
			Print "Expected reflection coefficient trace in graph"
		else
			Print "Select a Frequency Wave"
		endif
		Tag/W=$graphName/K/N=freqStart
		Tag/W=$graphName/K/N=freqEnd
	endif
end	

Function FrequencyPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			WAVE/Z freqWave= $popStr
			if( WaveExists(freqWave) )
				SetFreqWave(pa.win,freqWave)
				SetScale d 0,0,"Hz", freqWave  // set data units to Hz
			else
				SetFreqWave(pa.win,$"")
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function ChartPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			ChangeChartType(pa.win, popStr)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function Z0SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			UpdateMarkerAReadout(sva.win)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function Z0ForGraph(graphName)
	String graphName
	
	ControlInfo/W=$graphName z0
	return V_Value
End


Function Smith_Chart_GraphREF()

	String graphName= UniqueName("SmithChart",6,0)
	String type = "impedance"
	[WAVE SmithX, WAVE SmithY] = SmithWaves(type)

	Display/W=(31,47,582,573)/N=$graphName SmithY vs SmithX as "Smith Chart" // impedance
	ModifyGraph width={Plan,1,bottom,left} // allows resizing even if Expanded/Shrunk.
	ModifyGraph rgb(SmithY)=(34952,34952,34952)
	ModifyGraph noLabel=2
	ModifyGraph standoff=0
	ModifyGraph axRGB=(65535,65535,65535), axThick=0
	ShowInfo

	UpdateSmithLabels(graphName, 9)
		
	// Call the hook routine any time the 'A' cursor is moved in the topmost graph.
	SetWindow $graphName,hook(smith)=SmithChartHook 

	// Chart Type popup control
	PopupMenu chartType,pos={10,10},size={130.00,20.00},proc=ChartPopMenuProc
	PopupMenu chartType,title="Chart",fSize=11
	PopupMenu chartType,mode=1,popvalue="Impedance",value=#"\"Impedance;Admittance;SWR;\""

	// Z0 SetVariable
	SetVariable z0 pos={10,32}, title="Z\\B0",size={76.00,19.00},bodyWidth=60
	SetVariable z0 value= _NUM:50,limits={0,inf,1},fSize=11,proc=Z0SetVarProc
	
	// Frequency wave popup control
	PopupMenu FreqWave_popup pos={7,502},size={132,20},proc=FrequencyPopMenuProc,title="Select Freq Wave"
	PopupMenu FreqWave_popup value= "_none_;" + WaveList( "*", ";", "")

	// Buttons
	Button FreqChartButton,pos={381,479},size={150,20},proc=FreqChartButtonProc,title="Display Freq Charts"
	Button button0,pos={381,502},size={150,20},proc=LabelButtonProc,title="Label End Freqs"
End

Function AutoFontSizeForLabels(graphName)
	String graphName
	
	Variable fontSize= 9
	GetWindow $graphName, wsize
	Variable winLength = max(V_right-V_left,V_bottom-V_top)
	
	if( winLength > 650 )
		fontSize= 10
		if( winLength > 800 )
			fontSize= 11
			if( winLength > 1000 )
				fontSize= 12 + ceil((winLength-1000)/200)
			endif
		endif
	endif
	if( kDebugging )
		String cmd
		sprintf cmd, "TextBox/W=%s/C/N=fsizeDemo \"\\F'Helvetica'\\Z%.2dfsize %d +j2.0 winLength=%d\"", graphName, fontSize, fontSize, winLength
		Execute/Z cmd
	endif

	return fontSize
end

Function/S SmithChartType(String graphName)
	// only one of SmithY, SWRy, or AdmittanceY is allowed in the graph.
	WAVE/Z wy = TraceNameToWaveRef(graphName,"SmithY")
	if( WaveExists(wy) )
		return "impedance"
	endif
	WAVE/Z wy = TraceNameToWaveRef(graphName,"AdmittanceY")
	if( WaveExists(wy) )
		return "admittance"
	endif
	WAVE/Z wy = TraceNameToWaveRef(graphName,"SWRy")
	if( WaveExists(wy) )
		return "SWR"
	endif
	return "" // none!
End

// The result is used with ReplaceWave trace=result newWave
Function/S SmithChartYTraceName(String graphName)
	// only one of SmithY, SWRy, or AdmittanceY is allowed in the graph.
	WAVE/Z wy = TraceNameToWaveRef(graphName,"SmithY")
	if( WaveExists(wy) )
		return "SmithY"
	endif
	WAVE/Z wy = TraceNameToWaveRef(graphName,"AdmittanceY")
	if( WaveExists(wy) )
		return "AdmittanceY"
	endif
	WAVE/Z wy = TraceNameToWaveRef(graphName,"SWRy")
	if( WaveExists(wy) )
		return "SWRy"
	endif
	return "" // none!
End

Function IsSmithChartYTraceName(String name)

	Variable isSmith = CmpStr(name,"SmithY") == 0 || CmpStr(name,"AdmittanceY") == 0 || CmpStr(name,"SWRy") == 0
	return isSmith
End

Function IsSmithChart(String graphName)
	
	String smithTraceName= SmithChartYTraceName(graphName)
	return strlen(smithTraceName) > 0
End

Function/S TopSmithChart()
	
	String graphs = WinList("*",";","WIN:1,VISIBLE:1")
	Variable i=0, n= ItemsInList(graphs)
	for(i=0; i<n; i+=1)
		String graphName= StringFromList(i,graphs)
		if( IsSmithChart(graphName) )
			return graphName
		endif
	endfor
	return ""
End


// Return the X and Y waves of the nth non-Smith trace (a trace that isn't one of the "Smith Waves"),
// returns null waves if only Smith Waves (or no waves at all) are in the graph.
//
// nths is 1-based; pass 1 to get the wave(s) for first non-Smith trace.
Function [WAVE/Z wx, WAVE/Z wy] NonSmithWaves(String graphName, Variable nth)

	Variable n = 0
	Variable numNonSmiths = 0
	do
		WAVE/Z traceY = WaveRefIndexed(graphName,n,1)  // trace's Y data wave
		if( !WaveExists(traceY) )
			return [$"", $""]
		endif
		String name = NameOfWave(traceY)
		if( !IsSmithChartYTraceName(name) )
			numNonSmiths += 1
			if( numNonSmiths == nth )
				return [WaveRefIndexed(graphName,n,2), traceY]
			endif
		endif
		n += 1
	while(1)
	
	return [$"", $""]	// not found
End

Function/S ChangeChartType(String graphName, String chartType)
	String oldChartType = SmithChartType(graphName)
	if( CmpStr(oldChartType, chartType) != 0 )
		String smithTraceName = SmithChartYTraceName(graphName)
		// TO DO: Save and restore marker A position using axis values if not attached to reflection coefficient trace
		if( strlen(chartType) == 0 ) // remove chart grid
			RemoveFromGraph/W=$graphName $smithTraceName
		else
			// change the chart grid wave
			[WAVE SmithX, WAVE SmithY] = SmithWaves(chartType)
			ReplaceWave/W=$graphName/X trace=$smithTraceName SmithX
			ReplaceWave/W=$graphName trace=$smithTraceName SmithY
		endif
		ChangeSmithLabels(graphName, 0, chartType)
		UpdateMarkerAReadout(graphName)
	endif
	return oldChartType
End

Function [WAVE SmithX, WAVE SmithY] SmithWaves(String chartType [,Variable quality])
	// chartType is one of "impedance", "admittance", "SWR"
	String xname,yname // output wave names.
	if (CmpStr(chartType, "SWR") == 0 )
		xname= "SWRx"
		yname= "SWRy"
	elseif (CmpStr(chartType, "admittance") == 0 )
		xname= "AdmittanceX"
		yname= "AdmittanceY"
	else
		xname= "SmithX"
		yname= "SmithY"
	endif

	if( ParamIsDefault(quality) || quality < 0.5 )
		quality = 0.5	// higher values use more points to approximate arcs, 1 is recommended
	endif
	
	String df = SetTempDF()

	Make/O/D/N=0 $xname/WAVE=wx
	Make/O/D/N=0 $yname/WAVE=wy

	SetDataFolder df

	if (CmpStr(chartType, "SWR") == 0 )
		// constant SWR are circles on the origin.
		// a SWR of 1 is a zero-radius circle at the origin,
		// and the unit circle is a SWR of infinity
		Make/FREE/D vals={1.2, 1.5, 2, 3, 5, 10, 20, inf} // SWR
		for( Variable SWR:vals )
			// solve for gammaMag (the radius)
			// 	variable SWR = (1+gammaMag) / (1-gammaMag)
			// 	SWR * (1-gammaMag) = 1+gammaMag
			// SWR - SWR*gammaMag - 1 = gammaMag
			// SWR - 1 = gammaMag + SWR*gammaMag
			// SWR - 1 = gammaMag * (1+SWR)
			// (SWR-1)/(SWR+1) = gammaMag
			Variable radius = numtype(SWR) == 0 ? (SWR-1)/(SWR+1) : 1
			Variable segments = max(32,round(720*quality*radius)) // smaller circles have fewer segments
			if( kDebugging )
				print "radius = ", radius, "segments=", segments, "angle increment=", 360/segments, "degrees"
			endif
			Variable startPoint = DimSize(wx,0)
			Variable endPoint = startPoint+segments
			InsertPoints/M=0/V=(NaN) startPoint+1,segments+2,wx,wy // NaN separator between circles
			wx[startPoint,endPoint] = radius * cos(2*pi*(p-startPoint)/segments)
			wy[startPoint,endPoint] = radius * sin(2*pi*(p-startPoint)/segments)
		endfor
		// origin crossings
		wx[endPoint+1] = {-1, 0, 1, NaN, 0, 0, 0}
		wy[endPoint+1] = {0, 0, 0, NaN, -1, 0, 1}
		return [wx, wy]
	endif
	
	// Constant resistance/admittance
	Variable mx = 1 // assume resistance (impedance)
	if (CmpStr(chartType, "admittance") == 0 )
		mx= -1
	endif
	
	Make/FREE/D vals={0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.2, 1.4, 1.6, 1.8, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 16, 18, 20, 50, 100}
	for( Variable R:vals )
		radius = 1 / (1+R)
		Variable x0 = mx * (1 - radius)
		segments = max(32,round(720*quality*radius)) // smaller circles have fewer segments
		if( kDebugging )
			print "radius = ", radius, "x0=", x0, "segments=", segments, "angle increment=", 360/segments, "degrees"
		endif
		// start and end at mx*1,0 (R=infinity, X=0), so that we don't need NaN separators
		startPoint = DimSize(wx,0)
		endPoint = startPoint+segments
		InsertPoints/M=0/V=(NaN) startPoint+1,segments+1,wx,wy
		wx[startPoint,endPoint] = x0 + mx*radius * cos(2*pi*(p-startPoint)/segments)
		wy[startPoint,endPoint] = radius * sin(2*pi*(p-startPoint)/segments)
	endfor

	// Horizontal line
	wx[endPoint+1] = {-mx, NaN}
	wy[endPoint+1] = {0, NaN}

	Variable reactanceStartPoint = DimSize(wx,0)

	// +Constant reactance/susceptance
	Make/FREE/D vals={0.2, 0.4, 0.6, 0.8, 1.0, 1.2, 1.4, 1.6, 1.8, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 16, 18, 20}
	x0 = mx
	for( Variable Xl:vals )	// inductance is +j, capacitance is -j for impedance.
		radius = 1 / Xl
		Variable y0 = radius
		// solving for angle for gammaMag = 1, aka R = 0
		//	variable gammaMag = sqrt(x*x+y*y) == 1 also x*x+y*y == 1
		//	x = x0 + radius*cos(angle)
		//	y = y0 + radius*sin(angle)
		//	(x0 + radius*cos(angle)) * (x0 + radius*cos(angle)) + (y0 + radius*sin(angle))*(y0 + radius*sin(angle)) == 1
		// simpler: substitute x0=1, y0 = radius
		//	(1 + radius*cos(angle)) * (1 + radius*cos(angle)) + (radius + radius*sin(angle))*(radius + radius*sin(angle)) == 1
		//https://www.wolframalpha.com/input/?i=solve+%281%2Br*cos%28a%29%29*%281%2Br*cos%28a%29%29%2B%28r%2Br*sin%28a%29%29*%28r%2Br*sin%28a%29%29+%3D%3D1+for+a
		Variable angle0 = -pi/2
		Variable angleMax
		if( radius == 1 )
			angleMax = -pi
		else
			angleMax = 2*atan((radius+1)/(1-radius))
			if( angleMax > angle0 )
				angleMax -= 2*pi
			endif
		endif
		segments = round(180*quality*sqrt(radius)) // smaller circles have fewer segments
		startPoint = DimSize(wx,0)
		endPoint = startPoint+segments
		InsertPoints/M=0/V=(NaN) startPoint+1,segments+2,wx,wy	// end with NaN,NaN
		Variable deltaAngle = (angleMax-angle0)/segments
		wx[startPoint,endPoint] = x0 + mx * radius * cos(angle0+deltaAngle*(p-startPoint))
		wy[startPoint,endPoint] = y0 + radius * sin(angle0+deltaAngle*(p-startPoint))
	endfor

	// - constant reactance/susceptance just negates the y coordinates.
	Variable reactanceEndPoint = DimSize(wx,0)-1
	Variable numToInsert = reactanceEndPoint - reactanceStartPoint+1

	InsertPoints/M=0/V=(NaN) reactanceEndPoint+1,numToInsert,wx,wy
	startPoint = reactanceEndPoint+1
	endPoint = DimSize(wx,0)-1
	wx[startPoint,endPoint] = wx[p-numToInsert]
	wy[startPoint,endPoint] = -wy[p-numToInsert]

	return [wx, wy]
End


Function ChangeSmithLabels(graphName, fSize, chartType)
	String graphName
	Variable fSize	// 0 for auto, else points
	String chartType

	strswitch(chartType)
		case "impedance":
			UpdateImpedanceLabels(graphName, fSize)
			break
		case "admittance":
			UpdateAdmittanceLabels(graphName, fSize)
			break
		case "SWR":
			UpdateSWRLabels(graphName, fSize)
			break
		default:
			SetDrawLayer/W=$graphName/K ProgFront // SetDrawLayer sets S_Name to the name of the previously-selected drawing layer
			SetDrawLayer/W=$graphName $S_Name
			break
	endswitch
End

Function UpdateSmithLabels(graphName, fSize)
	String graphName
	Variable fSize	// 0 for auto, else points
	String chartType = SmithChartType(graphName)
	ChangeSmithLabels(graphName, fSize, chartType)
End

Function UpdateImpedanceLabels(graphName, fSize)
	String graphName
	Variable fSize	// 0 for auto, else points
	
	if( fSize <= 0 )
		fSize = AutoFontSizeForLabels(graphName)
	endif
	
	SetDrawLayer/W=$graphName/K ProgFront
	String oldLayer= S_Name
	SetDrawEnv/W=$graphName xcoord= bottom,ycoord= left,textrgb= (34952,34952,34952),fname= "Helvetica",fsize= fSize, save
	// upper
	SetDrawEnv/W=$graphName textxjust= 2,textyjust= 2,textrot= 90
	DrawText/W=$graphName 0.767022149302708,0.657095980311731,"+j3.0"

	SetDrawEnv/W=$graphName textxjust= 2,textyjust= 2,textrot= 90
	DrawText/W=$graphName 0.575061525840854,0.821164889253487,"+j2.0"

	SetDrawEnv/W=$graphName textxjust= 1,textyjust= 2,textrot= 90
	DrawText/W=$graphName 0.383100902379,0.913043478260871,"+j1.6"
	
	SetDrawEnv/W=$graphName textxjust= 1,textyjust= 2,textrot= 90
	DrawText/W=$graphName 0.273174733388023,0.952420016406892,"+j1.4"
	
	SetDrawEnv/W=$graphName textxjust= 1,textyjust= 2,textrot= 90
	DrawText/W=$graphName 0.133716160787531,0.978671041837573,"+j1.2"
	
	SetDrawEnv/W=$graphName textxjust= 1,textyjust= 2,textrot= 90
	DrawText/W=$graphName -0.0237899917965544,0.991796554552914,"+j1.0"

	SetDrawEnv/W=$graphName textyjust= 2
	DrawText/W=$graphName -0.204265791632485,0.968826907301066,"+j0.8"
	
	SetDrawEnv/W=$graphName textyjust= 2
	DrawText/W=$graphName -0.440525020508613,0.881870385561936,"+j0.6"
	DrawText/W=$graphName -0.678424938474159,0.657095980311731,"+j0.4"
	DrawText/W=$graphName -0.891714520098441,0.374897456931911,"+j0.2"
	
	// middle
	SetDrawEnv/W=$graphName textxjust= 2,textrot= 90, save
	DrawText/W=$graphName 0.504511894995899,0.00410172272354358,"3.0"
	DrawText/W=$graphName 0.342083675143561,0.00410172272354358,"2.0"
	DrawText/W=$graphName 0.173092698933553,0.00410172272354358,"1.4"
	DrawText/W=$graphName 0.0959803117309277,0.00410172272354358,"1.2"
	DrawText/W=$graphName 0.00246103363412708,0.00410172272354358,"1.0"
	DrawText/W=$graphName -0.107465135356849,0.00738310090237869,"0.8"
	DrawText/W=$graphName -0.245283018867923,0.00738310090237869,"0.6"
	DrawText/W=$graphName -0.425758818703855,0.00738310090237869,"0.4"
	DrawText/W=$graphName -0.666940114848234,0.00738310090237869,"0.2"
	DrawText/W=$graphName -0.936013125512713,0.00738310090237869,"0.0"
	
	// lower

	SetDrawEnv/W=$graphName textxjust= 2,textrot= 90
	DrawText/W=$graphName 0.767022149302708,-0.643970467596391,"-j3.0"
	SetDrawEnv/W=$graphName textxjust= 2,textrot= 90
	DrawText/W=$graphName 0.581624282198524,-0.822805578342904,"-j2.0"
	SetDrawEnv/W=$graphName textxjust= 1,textrot= 90
	DrawText/W=$graphName 0.384741591468417,-0.914684167350287,"-j1.6"
	SetDrawEnv/W=$graphName textxjust= 1,textrot= 90
	DrawText/W=$graphName 0.269893355209189,-0.954060705496309,"-j1.4"
	SetDrawEnv/W=$graphName textxjust= 1,textrot= 90
	DrawText/W=$graphName 0.135356849876949,-0.978671041837572,"-j1.2"
	SetDrawEnv/W=$graphName textxjust= 1,textrot= 90
	DrawText/W=$graphName -0.0287120590648065,-0.98687448728466,"-j1.0"

	SetDrawEnv/W=$graphName textxjust= 2,textrot= 0,save
	DrawText/W=$graphName -0.21410992616899,-0.945857260049221,"-j0.8"
	DrawText/W=$graphName -0.6636587366694,-0.640689089417555,"-j0.4"
	DrawText/W=$graphName -0.440525020508613,-0.840853158326497,"-j0.6"
	DrawText/W=$graphName -0.827727645611156,-0.353568498769483,"-j0.2"
	
	SetDrawLayer/W=$graphName $S_Name
End

Function UpdateAdmittanceLabels(graphName, fSize)
	String graphName
	Variable fSize	// 0 for auto, else points
	
	if( fSize <= 0 )
		fSize = AutoFontSizeForLabels(graphName)
	endif

	SetDrawLayer/W=$graphName/K ProgFront
	String oldLayer= S_Name
	SetDrawEnv/W=$graphName xcoord= bottom,ycoord= left,textrgb= (34952,34952,34952),fname= "Helvetica",fsize= fSize, save
	// upper
	SetDrawEnv/W=$graphName textxjust= 0,textyjust= 2,textrot= 90
	DrawText/W=$graphName -0.767022149302708,0.657095980311731,"+j3.0"

	SetDrawEnv/W=$graphName textxjust= 0,textyjust= 2,textrot= 90
	DrawText/W=$graphName -0.575061525840854,0.821164889253487,"+j2.0"

	SetDrawEnv/W=$graphName textxjust= 1,textyjust= 2,textrot= 90
	DrawText/W=$graphName -0.383100902379,0.913043478260871,"+j1.6"
	
	SetDrawEnv/W=$graphName textxjust= 1,textyjust= 2,textrot= 90
	DrawText/W=$graphName -0.273174733388023,0.952420016406892,"+j1.4"
	
	SetDrawEnv/W=$graphName textxjust= 1,textyjust= 2,textrot= 90
	DrawText/W=$graphName -0.133716160787531,0.978671041837573,"+j1.2"
	
	SetDrawEnv/W=$graphName textxjust= 1,textyjust= 2,textrot= 90
	DrawText/W=$graphName 0.0237899917965544,0.991796554552914,"+j1.0"

	SetDrawEnv/W=$graphName textxjust= 2,textyjust= 2
	DrawText/W=$graphName 0.204265791632485,0.968826907301066,"+j0.8"
	
	SetDrawEnv/W=$graphName textxjust= 2,textyjust= 2
	DrawText/W=$graphName 0.440525020508613,0.881870385561936,"+j0.6"
	SetDrawEnv/W=$graphName textxjust= 2
	DrawText/W=$graphName 0.678424938474159,0.657095980311731,"+j0.4"
	SetDrawEnv/W=$graphName textxjust= 2
	DrawText/W=$graphName 0.891714520098441,0.374897456931911,"+j0.2"
	
	// middle
	SetDrawEnv/W=$graphName textxjust= 0,textrot= 90, save
	DrawText/W=$graphName -0.504511894995899,0.00410172272354358,"3.0"
	DrawText/W=$graphName -0.342083675143561,0.00410172272354358,"2.0"
	DrawText/W=$graphName -0.173092698933553,0.00410172272354358,"1.4"
	DrawText/W=$graphName -0.0959803117309277,0.00410172272354358,"1.2"
	DrawText/W=$graphName -0.00246103363412708,0.00410172272354358,"1.0"
	DrawText/W=$graphName 0.107465135356849,0.00738310090237869,"0.8"
	DrawText/W=$graphName 0.245283018867923,0.00738310090237869,"0.6"
	DrawText/W=$graphName 0.425758818703855,0.00738310090237869,"0.4"
	DrawText/W=$graphName 0.666940114848234,0.00738310090237869,"0.2"
	DrawText/W=$graphName 0.936013125512713,0.00738310090237869,"0.0"
	
	// lower

	SetDrawEnv/W=$graphName textxjust= 0,textrot= 90
	DrawText/W=$graphName -0.767022149302708,-0.643970467596391,"-j3.0"
	SetDrawEnv/W=$graphName textxjust= 0,textrot= 90
	DrawText/W=$graphName -0.581624282198524,-0.822805578342904,"-j2.0"
	SetDrawEnv/W=$graphName textxjust= 1,textrot= 90
	DrawText/W=$graphName -0.384741591468417,-0.914684167350287,"-j1.6"
	SetDrawEnv/W=$graphName textxjust= 1,textrot= 90
	DrawText/W=$graphName -0.269893355209189,-0.954060705496309,"-j1.4"
	SetDrawEnv/W=$graphName textxjust= 1,textrot= 90
	DrawText/W=$graphName -0.135356849876949,-0.978671041837572,"-j1.2"
	SetDrawEnv/W=$graphName textxjust= 1,textrot= 90
	DrawText/W=$graphName 0.0287120590648065,-0.98687448728466,"-j1.0"

	SetDrawEnv/W=$graphName textxjust= 0,textrot= 0,save
	DrawText/W=$graphName 0.21410992616899,-0.945857260049221,"-j0.8"
	DrawText/W=$graphName 0.6636587366694,-0.640689089417555,"-j0.4"
	DrawText/W=$graphName 0.440525020508613,-0.840853158326497,"-j0.6"
	DrawText/W=$graphName 0.827727645611156,-0.353568498769483,"-j0.2"
	
	SetDrawLayer/W=$graphName $S_Name
End

Function UpdateSWRLabels(graphName, fSize)
	String graphName
	Variable fSize	// 0 for auto, else points
	
	if( fSize <= 0 )
		fSize = AutoFontSizeForLabels(graphName)
	endif

	SetDrawLayer/W=$graphName/K ProgFront
	String oldLayer= S_Name
	SetDrawEnv/W=$graphName xcoord= bottom,ycoord= left,textrgb= (34952,34952,34952),fname= "Helvetica",fsize= fSize, save

	// top
	DrawText/W=$graphName 0.0117800729153626,0.0921757069632116,"1.2"
	DrawText/W=$graphName 0.0117800729153626,0.202233149768005,"1.5"	
	DrawText/W=$graphName 0.0117800729153626,0.33818937438918," 2"
	DrawText/W=$graphName 0.0117800729153626,0.506754294662529," 3"
	DrawText/W=$graphName 0.0117800729153626,0.675319214935877," 5"
	DrawText/W=$graphName 0.0117800729153626,0.823382996257061,"10"
	DrawText/W=$graphName 0.0117800729153626,0.91449916937779,"20"
	DrawText/W=$graphName 0.0117800729153626,1.00145569111692,"Inf"

	// bottom
	SetDrawEnv/W=$graphName textyjust= 2, save
	DrawText/W=$graphName 0.0117800729153626,-0.0946856069054014,"1.2"
	DrawText/W=$graphName 0.0117800729153626,-0.215285098407177,"1.5"
	DrawText/W=$graphName 0.0117800729153626,-0.34210259641374," 2"
	DrawText/W=$graphName 0.0117800729153626,-0.52390263964404," 3"
	DrawText/W=$graphName 0.0117800729153626,-0.679425310611568," 5"
	DrawText/W=$graphName 0.0117800729153626,-0.829171748268486,"10"
	DrawText/W=$graphName 0.0117800729153626,-0.919077472957976,"20"
	DrawText/W=$graphName 0.0117800729153626,-1.01606255705826,"Inf"

	SetDrawLayer/W=$graphName $S_Name
End

Function FitControlsToGraph(graphName)
	String graphName

	GetWindow $graphName wsizeForControls // window width into V_right and the window height into V_bottom in panel units

	Variable height = V_bottom
	Variable width = V_right
	Variable left=10
	Variable top = height - 23
	// left control
	PopupMenu FreqWave_popup,win=$graphName,pos={left,top}

	// right controls
	left = width - 160
	Button button0,win=$graphName,pos={left,top}
	top -= 22
	Button FreqChartButton,win=$graphName,pos={left,top}
End

Function FreqChartButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			SmithFreqCharts(ba.win)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function SmithFreqCharts(String graphName)
	if( !IsSmithChart(graphName) )
		graphName= TopSmithChart()
	endif
	if( !IsSmithChart(graphName) )
		Beep;Print "Expected Smith Chart"
		return -1
	endif
	
	[ WAVE re, WAVE im] = NonSmithWaves(graphName, 1) // first non-Smith trace X and Y Waves, presumed to be reflection coefficient r,i components.
	if( WaveExists(re) && WaveExists(im) )
		String imWave = NameOfWave(im)
		String GammaWave = imWave+"_Gamma"
		String RLWave = imWave+"_RL"
		String ZMagWave = imWave+"_ZMag"
		String ZPhaseWave = imWave+"_ZPh"
		String ZRealWave = imWave+"_ZRe"
		String ZImageWave = imWave+"_ZIm"
		variable z0 = Z0ForGraph(graphName)
		
		String df = SetTempDF()
		variable npoints = numpnts(im)
		Make/O/D/N=(npoints)/C $GammaWave/WAVE=wg
		Make/O/D/N=(npoints) $RLWave/WAVE=wrl
		Make/O/D/N=(npoints) $ZMagWave/WAVE=wzmag
		Make/O/D/N=(npoints) $ZPhaseWave/WAVE=wzph
		Make/O/D/N=(npoints) $ZRealWave/WAVE=wzr
		Make/O/D/N=(npoints) $ZImageWave/WAVE=wzi

		SetDataFolder df
		
		wg = cmplx(re,im)	
		wzr = real(z0 * (wg[p]+1)/(1-wg[p]))
		wzi = imag(z0 * (wg[p]+1)/(1-wg[p]))
		wzph = atan2( imag(wg[p]), real(wg[p]) ) * 180/pi
		wrl = -20 * log( sqrt( magsqr(wg[p]) ))
		wzmag =  sqrt( magsqr(wg[p]) ) * z0
		WAVE/Z freqWave= FreqWave(graphName)
		MagPhaseGraph(freqWave, wzmag, wzph)
		RealImagGraph(freqWave, wzr, wzi)
		RLGraph(freqWave, wrl)
	else
		Beep; Print "Expected reflection coefficient trace in graph"
	endif
end

Function MagPhaseGraph(WAVE freqWave, WAVE Zmag, WAVE Zph)
	
	Display /W=(586,46,924,215) Zmag vs freqWave as "Impedance (Mag, Phase)"
	AppendToGraph/R Zph vs freqWave
	String zphName= NameOfWave(Zph)
	ModifyGraph lStyle($zphName)=2
	ModifyGraph rgb($zphName)=(0,0,65535)
	ModifyGraph grid=2
	ModifyGraph mirror(bottom)=1
	ModifyGraph standoff(left)=0,standoff(bottom)=0
	Label left "| Z |  Ohms"
	Label right "Phase, Degrees"
	TextBox/C/N=text0/F=0/A=MT/E "\\f01Impedance vs Frequency (Mag, Phase)"
	string prt
	sprintf prt, "\\s(%s) | Z |\r\\s(%s) Phase", NameOfWave(ZMag), zphName
	Legend/C/N=text1/J/A=LB/X=43.14/Y=69.44  prt
End

Function RealImagGraph(WAVE freqWave, WAVE Zre, WAVE Zim)
	
	Display /W=(586,238,924,407) Zre vs freqWave as "Impedance (Real, Imag)"
	AppendToGraph/R Zim vs freqWave

	String zimName= NameOfWave(Zim)
	ModifyGraph lStyle($zimName)=2
	ModifyGraph rgb($zimName)=(0,0,65535)
	ModifyGraph grid(left)=2,grid(bottom)=2
	ModifyGraph mirror(bottom)=1
	ModifyGraph standoff(left)=0,standoff(bottom)=0
	Label left "Resistance, Ohms"
	Label right "Reactance, Ohms"
	TextBox/C/N=text0/F=0/A=MT/E "\\f01Impedance vs Frequency (Real, Imag)"
	string prt
	sprintf prt, "\\s(%s) Resistance\r\\s(%s) Reactance", NameOfWave(Zre), zimName
	Legend/C/N=text2/J/X=31.43/Y=2.78  prt
End

Function RLGraph(WAVE freqWave, WAVE RL)

	Display /W=(584,431,921,601) RL vs freqWave as "Return Loss"
	ModifyGraph grid=2
	ModifyGraph mirror=1
	ModifyGraph standoff=0
	Label left "dB"
	TextBox/C/N=text0/F=0/A=MT/E "\\f01Return Loss vs Frequency"
End
