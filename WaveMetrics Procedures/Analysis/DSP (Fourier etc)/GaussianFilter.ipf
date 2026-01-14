#pragma rtGlobals=1		// Use modern global access method.
#pragma version=6.34		// This revision first shipped with Igor 6.34

// Filters 1-dimensional data with a variable width gaussian frequency response.
// This version implements only low-pass filtering.
// To start using this procedure, select "Gaussian Filtering" from the "Analysis Menu".
//
// Requires Igor 3.13 or later.
//
// 8/2000 - jsp, changes suggested Koichi Mori.
// 7/2004 - jsp, live update.
// 11/2013 - jsp, added "Hz" to Filter Response graph's waves and to the Wave's Sampling Frequency readout.

Menu "Analysis"
	"Gaussian Filtering"
End

// replaces data with the filtered result
Function GaussianFilterData(data,fCutoff,cutoffAmplitude)
	Wave data
	Variable fCutoff,cutoffAmplitude

	Variable npnts= numpnts(data)
	Redimension/N=(npnts*2) data	// eliminate end-effects
	FFT data
	WAVE/C cfiltered= data
	 ApplyGaussFilterResponseCmplx(cfiltered,fCutoff,cutoffAmplitude)
	 IFFT cfiltered
	Redimension/N=(npnts) data
End

Function ApplyGaussFilterResponse(w,fCutoff,cutoffAmplitude)
	Wave w
	Variable fCutoff
	Variable cutoffAmplitude // use 0.5 for half-voltage, 1/(sqrt(2)) for half-power
	
	Variable gaussWidth= fCutoff/sqrt(-ln(cutoffAmplitude))
	
	w*= exp(-(x*x/(gaussWidth*gaussWidth)))
End

Function ApplyGaussFilterResponseCmplx(w,fCutoff,cutoffAmplitude)
	Wave/C w
	Variable fCutoff
	Variable cutoffAmplitude // use 0.5 for half-voltage, 1/(sqrt(2)) for half-power
	
	Variable gaussWidth= fCutoff/sqrt(-ln(cutoffAmplitude))
	
	w *= cmplx(exp(-(x*x/(gaussWidth*gaussWidth))),0)
End

Function GaussianMakeSineSweep()
	Make/O/n=1200 sineSweep
	setscale/p x, 0, 0.0001,"s", sineSweep
	sineSweep=sin(2*pi*x*480/0.12*x)
end

Function GaussianCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	String matchstr
	if( checked )
		GaussianMakeSineSweep()
		matchStr="*"
	else
		KillWaves/Z SineSweep
		matchStr="!SineSweep*"
	endif
	String waves=WaveList(matchstr,";","")
	ControlInfo/W=GaussFilter inWave
	Variable mode= V_Value
	mode=max(1,min(mode,ItemsInList(waves)))
	String cmd= "PopupMenu  inWave,win=GaussFilter,mode=" + num2istr(mode)
	//  value= #"WaveList(\"<matchStr>\",\";\",\"\")"
	cmd += ",value=#\"WaveList(\\\""+matchStr+"\\\",\\\";\\\",\\\"\\\")\""
	
	Execute cmd	
	ControlUpdate/W=GaussFilter inWave
End

Proc GaussianFiltering()
	PauseUpdate; Silent 1		// building Gaussian Filtering Panel...
	
	String oldDF= GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O/S root:Packages:WMGaussianFiltering
	Variable/G root:Packages:WMGaussianFiltering:samplingFrequency
	Variable/G root:Packages:WMGaussianFiltering:cutoffFrequency
	DoWindow GaussFilter
	Variable vflag= V_Flag
	SetDataFolder oldDF
	if( V_Flag == 0 )
		Variable haveSineSweep= exists("sineSweep") == 1
		if( !haveSineSweep )
			GaussianMakeSineSweep()
		endif
		NewPanel /K=1/W=(469,44,709,285) as "Gaussian Filtering"
		DoWindow/C GaussFilter
		ModifyPanel fixedSize=1

		GroupBox inputWavesGroup,pos={10,9},size={228,98},title="Input (waves in current data folder)"
		CheckBox sampleData,pos={30,60},size={173,14},proc=GaussianCheckProc,title="List sineSweep Sample Data, too"
		CheckBox sampleData,value= 1

		PopupMenu inWave,pos={28,33},size={157,20},proc=InWavePopMenuProc,title="Input Wave"
		PopupMenu inWave,mode=1,value= #"WaveList(\"*\",\";\",\"\")"

		ValDisplay sampFreq,pos={26,83},size={200,14},title="Wave's Sampling Frequency"
		ValDisplay sampFreq,frame=0,limits={0,0,0},barmisc={0,1000}, format="%g Hz"	// JP131111
		ValDisplay sampFreq,value= #"root:Packages:WMGaussianFiltering:samplingFrequency"

		GroupBox filterSettingsGroup,pos={10,118},size={228,106},title="Filter Settings"
		SetVariable fCutoff,pos={27,142},size={201,15},proc=GaussianFilteringSetCutoffFreq,title="Cutoff Frequency"
		SetVariable fCutoff,limits={0,Inf,1},value= root:Packages:WMGaussianFiltering:cutoffFrequency,live=1

		PopupMenu cutoffAmp,pos={28,170},size={174,20},proc=GaussianFilteringPopMenuProc,title="Cutoff Amplitude"
		PopupMenu cutoffAmp,mode=1,popvalue="0.5 (-6dB)",value= #"\"0.5 (-6dB); 0.707 (-3dB)\""

		CheckBox apply,pos={39,200},size={78,14},proc=GaussianFilteringCheckProc,title="Apply Filter",value=0
	
		SetWindow GaussFilter hook=GaussFilterHook
	endif

	DoWindow/F GaussFilter
	ControlInfo inWave
	InWavePopMenuProc("inWave",V_Value,S_Value) 
EndMacro

Function GaussFilterHook(infoStr)
	String infoStr
	
	String event=StringByKey("EVENT",infoStr)
	if( CmpStr(event,"activate") == 0 )
		ControlUpdate/W=GaussFilter inWave
	endif
	return 0
End

Function GaussianFilterUpdate()

	// get the parameters
	ControlInfo/W=GaussFilter inWave
	WAVE/Z data= $S_Value
	if( WaveExists(data) == 0 )
		return 0
	endif
	Duplicate/O data root:Packages:WMGaussianFiltering:filteredData
	WAVE filtered= root:Packages:WMGaussianFiltering:filteredData
	
	ControlInfo/W=GaussFilter cutoffAmp
	Variable cutoffAmplitude= SelectNumber(V_Value-1,0.5, 1/sqrt(2))
	
	NVAR fCutoff= root:Packages:WMGaussianFiltering:cutoffFrequency
	
	ControlInfo/W=GaussFilter apply
	if( V_Flag == 0 )
		return 0
	endif
	if( V_Value == 0 )
		return 0
	endif

	// filter the wave
	GaussianFilterData(filtered,fCutoff,cutoffAmplitude)
	return 0
End

// Demonstrate the filter shape

Function GaussianDemo()
	NVAR fCutoff= root:Packages:WMGaussianFiltering:cutoffFrequency
	NVAR fs = root:Packages:WMGaussianFiltering:samplingFrequency
	ControlInfo/W=GaussFilter cutoffAmp
	Variable ampc= SelectNumber(V_Value-1, 0.5, 1/sqrt(2))
	Make/O/N=2 root:Packages:WMGaussianFiltering:cutoffAmplitude= ampc
	WAVE cutoffAmplitude= root:Packages:WMGaussianFiltering:cutoffAmplitude

	Make/O/N=129 root:Packages:WMGaussianFiltering:filterResponse=1
	WAVE filterResponse= root:Packages:WMGaussianFiltering:filterResponse
	SetScale/I x  0,fs/2,"Hz", filterResponse, cutoffAmplitude		// JP131111: added "Hz"
	ApplyGaussFilterResponseCmplx(filterResponse,fCutoff,ampc)
	CheckDisplayed/A filterResponse
	if( V_Flag == 0 )
		Preferences 1
		Display/K=1 filterResponse, cutoffAmplitude as "Filter Response"
		Legend
		Preferences 0
		DoWindow/C FilterResponse
		ModifyGraph rgb(cutoffAmplitude)=(0,0,65535)
		AutoPositionWindow/E/M=1/R=GaussFilter
	endif
End


Function/S PathToWaveOnLeftAxis(graphName,leftAxisName)
	String graphName,leftAxisName
	
	String traces= TraceNameList(graphName,";",1)
	Variable index= 0
	do
		String trace= StringFromList(index,traces)
		if( strlen(trace) == 0 )
			break
		endif
		String info= TraceInfo(graphName,trace,0)	// YAXIS:left;  etc
		String yaxisName= StringByKey("YAXIS", info , ":")
		if( cmpStr(yaxisName,leftAxisName) == 0 )
			WAVE w= TraceNameToWaveRef(graphName,trace)
			return GetWavesDataFolder(w,2)
		endif
		index += 1
	while(1)
	return ""
End

Function GaussianDataGraph(data)
	Wave/Z data
	
	if( !WaveExists(data) )
		return 0
	endif
	Preferences 1
	DoWindow GaussianGraph
	if( V_Flag == 0 )
		Display/K=1/L=dataLeft data
		DoWindow/C  GaussianGraph
		Duplicate/O data root:Packages:WMGaussianFiltering:filteredData
		WAVE filtered= root:Packages:WMGaussianFiltering:filteredData
		AppendToGraph/L=filteredLeft filtered
		ModifyGraph margin(left)=57
		ModifyGraph lblPos(dataLeft)=50, freePos(dataLeft)=0, axisEnab(dataLeft)={0.55,1}
		ModifyGraph lblPos(filteredLeft)=50, freePos(filteredLeft)=0, axisEnab(filteredLeft)={0, 0.45 }
		ModifyGraph rgb($NameOfWave(filtered))=(0,0,65535)
		Legend
	else
		// replace the data wave
		WAVE/Z oldData= $PathToWaveOnLeftAxis("GaussianGraph", "dataLeft")
		if( WaveExists(oldData) )
			ReplaceWave/W=GaussianGraph trace=$NameOfWave(oldData),  data
		else
			AppendToGraph/L=dataLeft data
			ModifyGraph lblPos(dataLeft)=50, freePos(dataLeft)=0, axisEnab(dataLeft)={0.55,1}
		endif
		// replace the filtered wave
		Duplicate/O data root:Packages:WMGaussianFiltering:filteredData
		WAVE filtered= root:Packages:WMGaussianFiltering:filteredData
	endif
	Preferences 0
End

Function InWavePopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	NVAR fs = root:Packages:WMGaussianFiltering:samplingFrequency
	WAVE/Z w= $popStr
	if( WaveExists(w) )
		fs= 1/deltax(w)
		Variable increment= round(fs/200)	// 1%
		if( increment <= 10 )
			increment= fs/200
		endif
		NVAR fc= root:Packages:WMGaussianFiltering:cutoffFrequency
		if( fc >= fs/2 )		// the maximum value
			fc= fs/4		// a more practical number
		endif
		if( fc <= 0 )
			fc= fs/4
		endif
		SetVariable fCutoff,limits={0,fs/2,increment},value= root:Packages:WMGaussianFiltering:cutoffFrequency
		GaussianDataGraph(w)
		GaussianDemo()
		GaussianFilterUpdate()
	else
		fs= NaN
	endif
	return 0
End

Function GaussianFilteringSetCutoffFreq(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	GaussianDemo()
	GaussianFilterUpdate()

End

Function GaussianFilteringPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	GaussianDemo()
	GaussianFilterUpdate()

End

Function GaussianFilteringCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	if( checked )
		GaussianFilterUpdate()
	else
		// replace the filtered wave
		ControlInfo/W=GaussFilter inWave
		WAVE/Z data= $S_Value
		if( WaveExists(data) ==  1 )
			Duplicate/O data root:Packages:WMGaussianFiltering:filteredData
		endif
	endif
End
