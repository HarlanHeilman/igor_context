#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=1
#pragma version=9.02	// shipped with Igor 9.02
#pragma IndependentModule=XY2WFM
#pragma moduleName=XYPairToWfm

#include <PopupWaveSelector>
#include <Axis Utilities>
#include <Resize Controls>
#include <SaveRestoreWindowCoords>

// ++++++++++++++ XY Pair to Waveform Panel ++++++++++++++++
//
// Version 6.2, 6/14/2010  (JP)
//	Initial version. Call XY2WFM#ShowXYPairToWaveformPanel() to open the panel.
// Version 6.2, 6/24/2010  (JP)
//	Added remembering previous wave selections.
// Version 7, 5/13/2016  (JP)
//	PanelResolution changes.
// Version 9.01, 7/15/2022  (JP)
//	Error description for non-wave selection in X and Y Wave popup selectors.
// Version 9.02, 10/27/2022  (JP)
//	Added Interpolation method radio buttons for linear and cubic interpolation.
// Can now specify a liberal waveform output name, which is now remembered and restored.
//	Added an In New Graph button to the Display Waveform group.
//
// To Do: Series Detection button to the main panel which brings up another panel showing the analysis of the X wave's
// suitability as a series wave, and allows one to adjust the required maximum error.

static StrConstant ksPanelName="XYPairToWaveformPanel"

Function ShowXYPairToWaveformPanel()

	DoWindow/F $ksPanelName
	if( V_Flag == 0 )
		Variable vLeft=53, vTop=60, vRight=569, vBottom=479	// /W=(53,60,569,479) /W=(left, top, right, bottom )

//		WC_WindowCoordinatesGetNums(ksPanelName, vLeft, vTop, vRight, vBottom, usePixels=1)
		String cmd="NewPanel/K=1/N="+ksPanelName+"/W=(%s) as \"XY Pair to Waveform\""	// /K=1 for no dialog if killed
		cmd= WC_WindowCoordinatesSprintf(ksPanelName,cmd,vLeft, vTop, vRight, vBottom,1)	// pixels
		Execute cmd

		ModifyPanel/W=$ksPanelName noEdit=1
		DefaultGuiFont/W=$ksPanelName/Mac popup={"_IgorMedium",12,0},all={"_IgorMedium",12,0}
		DefaultGuiFont/W=$ksPanelName/Win popup={"_IgorMedium",0,0},all={"_IgorMedium",0,0}
	
	// Input Group
		GroupBox inputGroup,pos={8,7},size={498,99},title="Input"
		GroupBox inputGroup,userdata(ResizeControlsInfo)= A"!!,@c!!#:B!!#C^!!#@*z!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
		GroupBox inputGroup,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		GroupBox inputGroup,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

		// X wave
		TitleBox xTitle,pos={27,36},size={42,16},title="X Wave:",frame=0
		TitleBox xTitle,userdata(ResizeControlsInfo)=A"!!,C<!!#=s!!#>6!!#<8z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		TitleBox xTitle,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		TitleBox xTitle,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		// +++++ X wave selector button
		Button xWaveSelector,pos={85,34},size={150,20},title="\\JRxwave \\W623"
		Button xWaveSelector,userdata(ResizeControlsInfo)= A"!!,Ed!!#=k!!#A%!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		Button xWaveSelector,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		Button xWaveSelector,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		cmd= "XYPairToWfm#WavePopupSelectorNotify"	// don't use GetIndependentModuleName()+"#": FUNCRefs aren't cross-IM
		MakeButtonIntoWSPopupButton(ksPanelName, "xWaveSelector", cmd)	// , options=PopupWS_OptionFloat float to avoid main panel activate hook events, but clicking outside doesn't close them.
		cmd= "XYPairToWfm#xWavePopupSelectorFilter"
		PopupWS_MatchOptions(ksPanelName, "xWaveSelector", nameFilterProc=cmd)
		// ------ X wave selector button
		TitleBox xDescription,pos={253,38},size={195,26},title="FP64 (25 points)\rnot regularly spaced (slope error avg = 0.557514)",fSize=9,frame=0
		TitleBox xDescription,userdata(ResizeControlsInfo)=A"!!,H8!!#>&!!#AR!!#=3z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		TitleBox xDescription,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		TitleBox xDescription,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

		// Y wave
		TitleBox yTitle,pos={27,69},size={41,16},title="Y Wave:",frame=0
		TitleBox yTitle,userdata(ResizeControlsInfo)=A"!!,C<!!#?C!!#>2!!#<8z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		TitleBox yTitle,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		TitleBox yTitle,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		// +++++ Y wave selector button
		Button yWaveSelector,pos={85,67},size={150,20},title="\\JRLVA \\W623"
		Button yWaveSelector,userdata(ResizeControlsInfo)= A"!!,Ed!!#??!!#A%!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		Button yWaveSelector,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		Button yWaveSelector,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		cmd= "XYPairToWfm#WavePopupSelectorNotify"	// don't use GetIndependentModuleName()+"#": FUNCRefs aren't cross-IM
		MakeButtonIntoWSPopupButton(ksPanelName, "yWaveSelector", cmd)
		cmd= "XYPairToWfm#yWavePopupSelectorFilter"
		PopupWS_MatchOptions(ksPanelName, "yWaveSelector", nameFilterProc=cmd)
		// ------ Y wave selector button
		TitleBox yDescription,pos={253,71},size={159,26},fSize=9,frame=0,title="FP64 (25 points)\rx scale: start=0, delta=1 (default scaling)"
		TitleBox yDescription,userdata(ResizeControlsInfo)=A"!!,H8!!#?G!!#A.!!#=3z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		TitleBox yDescription,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		TitleBox yDescription,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

	// Algorithm group
		GroupBox algorithmGroup,pos={8,117},size={498,110},title="Algorithm"
		GroupBox algorithmGroup,userdata(ResizeControlsInfo)=A"!!,@c!!#@N!!#C^!!#@@z!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
		GroupBox algorithmGroup,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		GroupBox algorithmGroup,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

		CheckBox useInterpolate,pos={38,173},size={142,16},title="Use Linear Interpolation"
		CheckBox useInterpolate,value= 1,mode=1,proc=XYPairToWfm#AlgorithmCheckProc
		CheckBox useInterpolate,userdata(ResizeControlsInfo)=A"!!,D'!!#A<!!#@r!!#<8z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		CheckBox useInterpolate,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		CheckBox useInterpolate,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		
		CheckBox useCubicInterpolate,pos={37.00,199.00},size={140.00,16.00},proc=XYPairToWfm#AlgorithmCheckProc
		CheckBox useCubicInterpolate,title="Use Cubic Interpolation"
		CheckBox useCubicInterpolate,userdata(ResizeControlsInfo)=A"!!,D#!!#AV!!#@p!!#<8z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		CheckBox useCubicInterpolate,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		CheckBox useCubicInterpolate,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		CheckBox useCubicInterpolate,value=0,mode=1

		CheckBox useSetScale,pos={38,148},size={83,16},disable=2,title="Use SetScale"
		CheckBox useSetScale,value= 0,mode=1,proc=XYPairToWfm#AlgorithmCheckProc
		CheckBox useSetScale,userdata(ResizeControlsInfo)=A"!!,D'!!#A#!!#?_!!#<8z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		CheckBox useSetScale,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		CheckBox useSetScale,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

		SetVariable numPoints,pos={253,172},size={220,19},title="Number of Points:"
		SetVariable numPoints,limits={2,inf,1},value= _NUM:128
		SetVariable numPoints,userdata(ResizeControlsInfo)=A"!!,H8!!#A;!!#Ak!!#<Pz!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
		SetVariable numPoints,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		SetVariable numPoints,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

		SetVariable outName,pos={254,147},size={216,19},proc=XYPairToWfm#WfmNameSetVarProc,title="Waveform Name:"
		SetVariable outName,value= _STR:StrVarOrDefault(PanelDFVar("wfmName"),"")

		SetVariable outName,userdata(ResizeControlsInfo)=A"!!,H9!!#A\"!!#Ag!!#<Pz!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
		SetVariable outName,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		SetVariable outName,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

	// Ungrouped

		Button makeWaveform,pos={59,248},size={120,20},proc=XYPairToWfm#MakeWaveformButtonProc,title="Make Waveform"
		Button makeWaveform,userdata(ResizeControlsInfo)=A"!!,E&!!#B2!!#@T!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		Button makeWaveform,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		Button makeWaveform,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		TitleBox warning,pos={193,251},size={234,13},title="\\K(65535,0,0)*** Warning: will overwrite existing wave LVA_Waveform ***",fSize=9,frame=0,fColor=(65535,0,0)
		TitleBox warning,userdata(ResizeControlsInfo)=A"!!,GQ!!#B5!!#B$!!#;]z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		TitleBox warning,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		TitleBox warning,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

		Button help,pos={415,323},size={50,20},proc=XYPairToWfm#HelpButtonProc,title="Help"
		Button help,userdata(ResizeControlsInfo)=A"!!,I5J,hs1J,ho,!!#<Xz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
		Button help,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		Button help,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		Button close,pos={415,356},size={50,20},proc=XYPairToWfm#CloseButtonProc,title="Close"
		Button close,userdata(ResizeControlsInfo)=A"!!,I5J,hsB!!#>V!!#<Xz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
		Button close,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		Button close,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
	
	// Display Group
		GroupBox displayGroup,pos={8,287},size={361,113},title="Display Waveform"
		GroupBox displayGroup,userdata(ResizeControlsInfo)=A"!!,@c!!#BIJ,hsDJ,hpqz!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
		GroupBox displayGroup,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		GroupBox displayGroup,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		
		Button appendWaveform,pos={42,323},size={150,20},proc=XYPairToWfm#AppendButtonProc,title="Append to Graph0"
		Button appendWaveform,userdata(ResizeControlsInfo)=A"!!,D7!!#B[J,hqP!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
		Button appendWaveform,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		Button appendWaveform,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

		Button newGraph,pos={233.00,323.00},size={95.00,20.00},proc=XYPairToWfm#NewGraphButtonProc
		Button newGraph,title="In New Graph"
		Button newGraph,userdata(ResizeControlsInfo)=A"!!,H$!!#B[J,hpM!!#<Xz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
		Button newGraph,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		Button newGraph,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		
		PopupMenu vAxis,pos={45,356},size={92,20},title="Use Axes:"	// hide
		String modulePrefix= GetIndependentModuleName()+"#"	// append a static function name to this; it'll work in a global context
		cmd= modulePrefix+"HVAxisList(\"\",0)"
		PopupMenu vAxis,mode=1,popvalue="left",value= #cmd
		PopupMenu vAxis,userdata(ResizeControlsInfo)=A"!!,DC!!#Bl!!#?q!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		PopupMenu vAxis,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		PopupMenu vAxis,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

		PopupMenu hAxis,pos={233,356},size={62,20}	// hide
		cmd= modulePrefix+"HVAxisList(\"\",0)"
		PopupMenu hAxis,mode=1,popvalue="bottom",value= #cmd
		PopupMenu hAxis,userdata(ResizeControlsInfo)=A"!!,H$!!#Bl!!#?1!!#<Xz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
		PopupMenu hAxis,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		PopupMenu hAxis,userdata(ResizeControlsInfo)+=A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

		SetWindow kwTopWin,userdata(ResizeControlsInfo)=A"!!*'\"z!!#Cf!!#C6J,fQL!!*'\"zzzzzzzzzzzzzzzzzzz"
		SetWindow kwTopWin,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzzzzzzzzzzzzzzz"
		SetWindow kwTopWin,userdata(ResizeControlsInfo)+=A"zzzzzzzzzzzzzzzzzzz!!!"

		SetWindow $ksPanelName,hook(ResizeControls)=ResizeControls#ResizeControlsHook

		SetWindow $ksPanelName hook(XYPairToWfm)=XYPairToWfm#PanelWindowHook
		
		// Restore the previous waves, if any
		RestoreSelectedWaves()
		
		// Update the panel
		UpdateWaveDescriptions(1,1)
		ShowHideEnableDisable()
		cmd=modulePrefix+"ResizeControls#FitControlsToPanel(\""+ksPanelName+"\")"
		Execute/P/Q/Z cmd
	endif
End

static Function SaveSelectedWaves()

	String/G $PanelDFVar("xWavePath")= PopupWS_GetSelectionFullPath(ksPanelName, "xWaveSelector")
	String/G $PanelDFVar("yWavePath")= PopupWS_GetSelectionFullPath(ksPanelName, "yWaveSelector")
End

static Function RestoreSelectedWaves()
	String fullPath=StrVarOrDefault(PanelDFVar("xWavePath"),"")
	Wave/Z wx= $fullPath
	if( WaveExists(wx) && WaveIsAcceptable(wx,0) )
		PopupWS_SetSelectionFullPath(ksPanelName, "xWaveSelector", fullPath)
	endif
	fullPath=StrVarOrDefault(PanelDFVar("yWavePath"),"")
	Wave/Z wy= $fullPath
	if( WaveExists(wy) && WaveIsAcceptable(wy,1) )
		PopupWS_SetSelectionFullPath(ksPanelName, "yWaveSelector", fullPath)
	endif
End

static Function WavePopupSelectorNotify(event, wavepath, windowName, buttonName)
	Variable event		// WMWS_SelectionChanged
	String wavepath
	String windowName	// panel name
	String buttonName	// "xWaveSelector" or "yWaveSelector"
	
	// update xDescription or yDescription
	Wave/Z w= $wavepath
	String descriptionControl=""
	Variable doX= 0, doY= 0
	strswitch( buttonName )
		case "xWaveSelector":
			doX= 1
			break
		case "yWaveSelector":
			doY= 1
			break
	endswitch
	UpdateWaveDescriptions(doX, doY)
	// set other controls appropriately
	ShowHideEnableDisable()
End


static Function UpdateWaveDescriptions(doX, doY)
	Variable doX, doY

	String title
	if( doX )
		WAVE/Z wx=$PopupWS_GetSelectionFullPath(ksPanelName, "xWaveSelector")
		title=WaveDescription(wx,1)
		TitleBox xDescription, win=$ksPanelName, title=title
	endif
	if( doY )
		WAVE/Z wy=$PopupWS_GetSelectionFullPath(ksPanelName, "yWaveSelector")
		title=WaveDescription(wy,0)
		TitleBox yDescription, win=$ksPanelName, title=title
	endif
End

// FP32 (rows points)
static Function/S WaveDescription(w,isX)
	Wave/Z w
	Variable isX	// for monotonicity text
	
	if( !WaveExists(w) )
		return "\\K(65535,0,0)*** expected wave ***"
	endif
	String description=""
	Variable wt=WaveType(w)
	Variable waveIs32BitFloat = wt & 0x02
	Variable waveIs64BitFloat = wt & 0x04
	Variable waveIs8BitInteger = wt & 0x08
	Variable waveIs16BitInteger = wt & 0x10
	Variable waveIs32BitInteger = wt & 0x20
	Variable waveIsUnsigned = wt & 0x40
	Variable waveIsComplex = wt & 0x01
	
	if( wt == 0 )
		description += "TEXT"
	else
		if( waveIsUnsigned )
			description += "U"
		endif
		
		if( waveIs32BitFloat )
			description += "FP32"
		elseif( waveIs64BitFloat )
			description += "FP64"
		elseif( waveIs8BitInteger )
			description += "INT8"
		elseif( waveIs16BitInteger )
			description += "INT16"
		elseif( waveIs32BitInteger )
			description += "INT32"
		endif
		if( waveIsComplex )
			description += " CMPLX"
		endif
	endif

	description += " ("+num2istr(numpnts(w))+" points)"
	if( isX )
		if( wt )	// for numeric waves only
			description += "\r"+DescribeXWave(w)
		endif
	else
		description += "\r"+DescribeWaveScaling(w)
	endif

	return description
End

static Function/S DescribeXWave(w [,beThorough])
	Wave w
	Variable beThorough	// optional input

	if( ParamIsDefault(beThorough) )
		beThorough= 0
	endif
	Variable hasNaNs, hasInfs, relError
	Variable isSeriesAndDirection=IsSeriesWave(w, beThorough=beThorough,hasNaNs=hasNaNs,hasInfs=hasInfs,relError=relError)
	String description=""
	if( numtype(isSeriesAndDirection) == 0 && isSeriesAndDirection != 0 )
		sprintf description, "\\K(0,32000,0)series wave: start=%g, delta=%g (SetScale-compatible)", w[0], isSeriesAndDirection
	elseif( hasNaNs || hasInfs )
		sprintf description, "has %d NaNs,  %d infinities", hasNaNs,hasInfs
	else
		sprintf description, "not regularly spaced (slope error avg = %g)", relError
	endif
	return description
End

static Function/S DescribeWaveScaling(w)
	Wave w

	String description,comment=""
	Variable x0= DimOffset(w,0)
	Variable dx= DimDelta(w,0)
	if( x0 == 0 && dx == 1 )
		comment="(default scaling)"
	endif
	sprintf description, "x scale: start=%g, delta=%g %s", x0, dx, comment
	return description
End

static Function IsSeriesWave(w [,beThorough,maxRelativeError,hasNaNs,hasInfs,relError])
	Wave w	// must be extant numeric wave, not complex
	Variable beThorough				// optional input, default is fast
	Variable maxRelativeError				// optional input, default depends on data type
	Variable &hasNaNs,&hasInfs,&relError	// optional outputs
	
	if( ParamIsDefault(beThorough) )
		beThorough=0
	endif
	if( !ParamIsDefault(hasNans) )
		hasNaNs= NaN	// irony
	endif
	if( !ParamIsDefault(hasInfs) )
		hasInfs= NaN
	endif
	if( !ParamIsDefault(relError) )
		relError= NaN
	endif
	Variable diff=0
	Variable relativeError= NaN
	Variable n= numpnts(w)
	if( n < 2 )
		diff= 0
		WaveStats/Z/Q/M=0 w	// is either inf or NaN?
	elseif( n == 2 )
		diff=w[1]-w[0]
		WaveStats/Z/Q/M=0 w	// is either inf or NaN?
		relativeError= 0			// no chance to deviate from a slope defined by two values
	else // 3 or more points
		String oldDF= SetPanelDF()
		if((n <= 1024) || beThorough)
			Duplicate/O w, diffWave
			Differentiate/METH=1/P diffWave
		else
			// the "fast" part is limited checking (just the start, middle, and end)
			Variable checkLen= min(256,floor(n/3))
			Variable totalLen= 3*checkLen
			Duplicate/O/R=[0,checkLen-1] w, diffWave
			Differentiate/METH=1/P diffWave
			Variable middleStart=(n-checkLen)/2
			Duplicate/O/R=[middleStart,middleStart+checkLen-1] w, diffWave2
			Differentiate/METH=1/P diffWave2
			Variable endStart= n-checkLen
			Duplicate/O/R=[endStart,endStart+checkLen-1] w, diffWave3
			Differentiate/METH=1/P diffWave3
			Concatenate/NP/KILL {diffWave2, diffWave3}, diffWave
		endif
		
		WaveStats/Q diffWave
		KillWaves/Z diffWave
		relativeError = abs(V_adev/V_Avg)	// infinity if V_Avg == 0, NaN if 0/0
		if( V_numNaNs || V_numInfs )
			diff= 0	// not strictly true, but it means we can't use setscale.
		elseif( V_Avg == 0 )
			diff= 0	// this is not going to work well with either method
		else
			diff= V_Avg
			if( ParamIsDefault(maxRelativeError) )
				Variable wt=WaveType(w)
				Variable waveIs32BitFloat = wt & 0x02
				Variable waveIs64BitFloat = wt & 0x04
				if( waveIs32BitFloat )
					maxRelativeError= 0.01/100	// .01 %
				elseif( waveIs64BitFloat )
					maxRelativeError= 0.01/100	// .01 %
				else
					maxRelativeError= 0	// for integer wave types
				endif
			endif
			if( relativeError > maxRelativeError )
				diff= 0	// not regularly increasing or decreasing
			endif
		endif
		SetDataFolder oldDF
	endif

	if( !ParamIsDefault(hasNans) )
		hasNaNs= V_numNaNs
	endif
	if( !ParamIsDefault(hasInfs) )
		hasInfs= V_numInfs
	endif
	if( !ParamIsDefault(relError) )
		relError= relativeError
	endif
	Variable/G $PanelDFVar("xWaveIsOkayForSetScale")= diff	
	Variable/G $PanelDFVar("xWaveIsOkayThorough")= beThorough	
	String/G  $PanelDFVar("xWaveIsOkayIdentifier")= GetWavesDataFolder(w,2)+";"+WaveInfo( w, 0)		// WaveInfo includes MODTIME
	return diff
End

// this version doesn't accept text waves
static Function xWavePopupSelectorFilter(fullPathToWave, contentsCode)
	String fullPathToWave
	Variable contentsCode	// WMWS_Waves or WMWS_DataFolders
	
	if( contentsCode != WMWS_Waves )
		return 0
	endif

	WAVE/Z w= $fullPathToWave
	return WaveIsAcceptable(w,0)
End

// this version does accept text waves, because they can be used with a regularly spaced X wave 
static Function yWavePopupSelectorFilter(fullPathToWave, contentsCode)
	String fullPathToWave
	Variable contentsCode	// WMWS_Waves or WMWS_DataFolders
	
	if( contentsCode != WMWS_Waves )
		return 0
	endif

	WAVE/Z w= $fullPathToWave
	return WaveIsAcceptable(w,1)
End

// can't be complex or two-dimensional
static Function WaveIsAcceptable(w,textWaveIsOkay)
	Wave/Z w
	Variable textWaveIsOkay
	
	Variable wt= WaveType(w,1)	// a new kind of waveType
	Variable acceptable= (wt == 1) || (textWaveIsOkay && wt == 2)	// numeric or (optionally) text
	if( acceptable ) 
		//  must have more than 1 row, less than 2 columns, 0 or 1 layers, and 0 or 1 chunks
		acceptable= DimSize(w,0) > 1 && DimSize(w,1) <= 1 && DimSize(w,2) <= 1 && DimSize(w,3) <= 0
		if( acceptable )
			wt= WaveType(w)	// standard kind of waveType
			Variable waveIsComplex = wt & 0x01
			acceptable= !waveIsComplex
		endif
	endif
	return acceptable
End

// Any wave accepted by Interpolate2 must be:
//	existant
//	1D
//	Must have more than 1 row, less than 2 columns, 0 or 1 layers, and 0 or 1 chunks
// 	be FP32 or FP64
// If we need to interpolate any other data format, we'll need to redimension a copy.
static Function WaveIsAcceptableToInterpolate(w)
	Wave/Z w
	
	Variable wt= WaveType(w,1)	// a new kind of waveType
	Variable acceptable= wt == 1	// numeric
	if( acceptable ) 
		// any 1-D wave accepted by Interpolate2 : 1D FP32 or FP64
		//  must have more than 1 row, less than 2 columns, 0 or 1 layers, and 0 or 1 chunks
		acceptable= DimSize(w,0) > 1 && DimSize(w,1) <= 1 && DimSize(w,2) <= 1 && DimSize(w,3) <= 0
		if( acceptable )
			wt= WaveType(w)	// standard kind of waveType
			acceptable= wt == 0x02 || wt == 0x04	// only 32 or 64-bit float
		endif
	endif
	return acceptable
End

static Function/S GetSetVariableStr(ctrlName)
	String ctrlName

	ControlInfo/W=$ksPanelName $ctrlName
	String str= StrVarOrDefault(S_DataFolder,S_Value)
	return str
End

static Function/S PathToWaveform()

	String wn=GetSetVariableStr("outName")
	WAVE/Z w= $wn
	String path=""
	if( WaveExists(w) )
		path= GetWavesDataFolder(w,2)
	endif
	return path
End


static Function MakeWaveformButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String pathToXWave= PopupWS_GetSelectionFullPath(ksPanelName, "xWaveSelector")
	WAVE/Z wx=$pathToXWave
	String pathToYWave= PopupWS_GetSelectionFullPath(ksPanelName, "yWaveSelector")
	WAVE/Z wy=$pathToYWave
	
	String waveformName= GetSetVariableStr("outName")

	ControlInfo/W=$ksPanelName numPoints
	Variable numPoints= V_Value
	if( WaveExists(wx) && WaveExists(wy) )
		String algorithm = GetAlgorithm()
		Variable useSetScale= CmpStr(algorithm,"useSetScale") == 0
		Variable interpSlashT = 0 // set scale
		if( CmpStr(algorithm,"useCubicInterpolate") == 0 )
			interpSlashT = 2 // cubic
		elseif( CmpStr(algorithm,"useInterpolate") == 0 )
			interpSlashT = 1 // linear
		endif
		if( !useSetScale )
			String outWavePath= PathToWaveform()
			if( strlen(outWavePath) )
				DoAlert/T="Wave Exists" 1, "Overwrite existing "+waveformName+" wave?"
				if( V_Flag != 1 )
					ModifyControl outName, win=$ksPanelName, activate 
					return -1
				endif
			endif
		endif
		XYPairToWaveform(wx,wy,useSetScale,interpSlashT,numPoints,waveformName)	// uses Execute
		UpdateWaveDescriptions(0,1)	// to show the new scaling in the Y wave description if SetScale was selected.
		ShowHideEnableDisable()	// for Append to <window>
	endif
End

static Function ProceedAnyway(wxName,relativeErrorPct)
	String wxName
	Variable relativeErrorPct

	DoAlert/T="Upon further analysis..." 1,"SetScale may not be appropriate with "+wxName+" as an X Wave: actual relative series error is "+num2str(relativeErrorPct)+ " %.\r\rProceed anyway?\r\r(Click No to use Interpolate instead.)"
	return V_Flag == 1
End

Function XYPairToWaveform(wx,wy,useSetScale,interpSlashT,numPoints,waveformName)
	Wave wx, wy
	Variable useSetScale,interpSlashT,numPoints
	String waveformName // can be a liberal name
	
	String pathToXWave= GetWavesDataFolder(wx,4)	// 4 Returns partial path including possibly quoted wave name.
	String pathToYWave= GetWavesDataFolder(wy,4)

	// Make it obvious what we're doing by printing the commands to the history window
	String cmd,commands=""
	if( useSetScale )
		String wxName= NameOfWave(wx)
		Variable hasNaNs, hasInfs, relError
		Variable isSeriesAndDirection=IsSeriesWave(wx, beThorough=1,hasNaNs=hasNaNs,hasInfs=hasInfs,relError=relError)
		if( hasNaNs || hasInfs )
			useSetScale= 0
			DoAlert/T="Upon further analysis..." 0, "Found NaNs (blanks) or Infinities in "+wxName+"."
		elseif( !isSeriesAndDirection && !ProceedAnyway(wxName,relError/100) )
			useSetScale= 0
		endif
		if( useSetScale )
			Variable first= wx[0]
			Variable last= wx[numpnts(wx)-1]
			// SetScale/I x, first, last, wy
			sprintf commands, "SetScale/I x, %.14g, %.14g, \"%s\", %s", first, last, WaveUnits(wy,0), pathToYWave
		else
			Print "Switching Algorithm to \"Use Interpolate\"."
			SetAlgorithm("useInterpolate")
			return 0	// not setscale
		endif
	endif
	
	if( !useSetScale )	// interpolate
		// if not FP32 or 64, convert to FP32 or 64
		String flag
		String pathToTempX=""
		if( !WaveIsAcceptableToInterpolate(wx) )	// because it is not floating-point, if we've gotten this far
			// create a temp wave and interpolate that, then delete the temp
			// if 32-bit int, use double-precision float (to preserve accuracty), else float is good enough
			pathToTempX= PanelDFVar("tempX")
			sprintf cmd, "Duplicate/O %s, %s", pathToXWave, pathToTempX
			commands += cmd+";"
			flag = SelectString((WaveType(wx)&0x20) == 0, "/S", "/D")	// if ! waveIs32BitInteger, use /S, else use /D
			sprintf cmd, "Redimension%s %s", flag, pathToTempX
			commands += cmd+";"
			pathToXWave=pathToTempX
		endif
	
		String pathToTempY=""
		if( !WaveIsAcceptableToInterpolate(wy) )
			pathToTempY= PanelDFVar("tempY")
			sprintf cmd, "Duplicate/O %s, %s", pathToYWave, pathToTempY
			commands += cmd+";"
			flag = SelectString((WaveType(wy)&0x20) == 0, "/S", "/D")	// if ! waveIs32BitInteger, use /S, else use /D
			sprintf cmd, "Redimension%s %s", flag, pathToTempY
			commands += cmd+";"
			pathToYWave=pathToTempY
		endif
	
		// then interpolate
		sprintf cmd, "Interpolate2/T=%d/N=%d/E=2/Y=%s %s, %s", interpSlashT, numPoints, PossiblyQuoteName(waveformName), pathToXWave, pathToYWave
		commands += cmd+";"
		
		// then kill any temp wave(s)
		if( strlen(pathToTempX) )
			sprintf cmd, "KillWaves/Z %s", pathToTempX
			commands += cmd+";"
		endif
		if( strlen(pathToTempY) )
			sprintf cmd, "KillWaves/Z %s", pathToTempY
			commands += cmd+";"
		endif
	endif
	
	String dot= "•"
	Variable i, n= ItemsInList(commands)	// ; separates commands
	for(i=0;i<n;i+=1)
		cmd= StringFromList(i,commands)
		Execute cmd
		Print dot+cmd
	endfor
	return useSetScale
End

static Function IsMacintosh()

	String platform= IgorInfo(2)
	return CmpStr(platform,"Macintosh") == 0
End

// ----------------------------------- Panel-specific variables -----------------------------------

static StrConstant ksPackagePath= "root:Packages:XYPairToWaveform"
static StrConstant ksPackageName = "XYPairToWaveform"

Static Function/S PanelDF()
	NewDataFolder/O root:Packages
	NewDataFolder/O $ksPackagePath
	return ksPackagePath
End

Static Function/S PanelDFVar(varName)
	String varName
	
	return PanelDF()+":"+PossiblyQuoteName(varName)
End

// Set the data folder to a place where we can dump all kinds of variables and waves.
// Returns the old data folder.
Static Function/S SetPanelDF()

	String oldDF= GetDataFolder(1)
	NewDataFolder/O/S $PanelDF()	// DF is left pointing here to an existing or created data folder.
	return oldDF
End


// Panel Window hook:
Static Function PanelWindowHook(s)
	STRUCT WMWinHookStruct &s

	Variable rval= 0
	strswitch(s.eventName)
		case "activate":
			UpdateWaveDescriptions(1, 1)	// the waves may have changed
			ShowHideEnableDisable()
			break
		case "kill":
			SaveSelectedWaves()
			WC_WindowCoordinatesSave(s.winName)
			break
	endswitch

	return rval
End

static Function CanDoSetScale(forceThorough)
	Variable forceThorough
	
	String pathToXWave= PopupWS_GetSelectionFullPath(ksPanelName, "xWaveSelector")
	WAVE/Z wx=$pathToXWave 
	if( !WaveExists(wx) )
		return 0
	endif
	
	String pathToYWave= PopupWS_GetSelectionFullPath(ksPanelName, "yWaveSelector")
	WAVE/Z wy=$pathToYWave
	if( !WaveExists(wy) )
		return 0
	endif

	if( numpnts(wx) != numpnts(wy) )
		return 0
	endif

	Variable xWaveIsOkayForSetScale= GetPossiblyCachedCanDoSetScale(wx,forceThorough)
	if( !xWaveIsOkayForSetScale )
		return 0
	endif
	
	return 1
End


static Function GetPossiblyCachedCanDoSetScale(wx,forceThorough)
	Wave/Z wx
	Variable forceThorough
	
	// Use the last X wave check result instead of computing it all the time.
	// See IsSeriesWave()
	Variable canUseCachedValue= 0
	Variable xWaveIsOkayForSetScale

	String waveIdentifier= GetWavesDataFolder(wx,2)+";"+WaveInfo(wx, 0)
	String xWaveIsOkayIdentifier= StrVarOrDefault(PanelDFVar("xWaveIsOkayIdentifier"),"") // from IsSeriesWave()
	if( CmpStr(waveIdentifier,xWaveIsOkayIdentifier) == 0 )	// same wave with same modification time
		canUseCachedValue= 1
		if( forceThorough )
			Variable xWaveIsOkayThorough= NumVarOrDefault(PanelDFVar("xWaveIsOkayThorough"),0)
			if( !xWaveIsOkayThorough )
				canUseCachedValue= 0
			endif
		endif
		if( canUseCachedValue )
			xWaveIsOkayForSetScale= NumVarOrDefault(PanelDFVar("xWaveIsOkayForSetScale"),NaN)
			if( numtype(xWaveIsOkayForSetScale) != 0 )
				canUseCachedValue= 0
			endif
		endif
	endif

	if( !canUseCachedValue )
		Variable isSeriesAndDirection= IsSeriesWave(wx,beThorough=forceThorough)
		xWaveIsOkayForSetScale= isSeriesAndDirection != 0
		Variable/G $PanelDFVar("xWaveIsOkayForSetScale")=xWaveIsOkayForSetScale
	endif
	return xWaveIsOkayForSetScale
End

static Function CanDoInterpolate()	// can't interpolate a text wave (while SetScale is fine with it)

	String pathToXWave= PopupWS_GetSelectionFullPath(ksPanelName, "xWaveSelector")
	WAVE/Z wx=$pathToXWave 
	Variable wt= WaveType(wx,1)
	if( wt != 1 )
		return 0
	endif
	String pathToYWave= PopupWS_GetSelectionFullPath(ksPanelName, "yWaveSelector")
	WAVE/Z wy=$pathToYWave
	wt= WaveType(wy,1)
	return wt == 1	// interpolate requires numeric Y
End


static StrConstant ksAlgorithmControls= "useInterpolate;useSetScale;useCubicInterpolate;"

static Function/S GetAlgorithm()
	return GetRadioGroup(ksAlgorithmControls)
End

static Function/S SetAlgorithm(algorithm)
	String algorithm		// presumably appropriate for the given x and y waves

	SetRadioGroup(algorithm, ksAlgorithmControls)
	Variable wfmDisable= 0
	String wfmName= GetSetVariableStr("outName")
	if( CmpStr(algorithm,"useSetScale") == 0 )
		String pathToYWave= PopupWS_GetSelectionFullPath(ksPanelName, "yWaveSelector")
		Wave wy=$pathToYWave
		SetVariable numPoints,win=$ksPanelName,value= _NUM:numpnts(wy)
		wfmDisable= 2
		wfmName= NameOfWave(wy)
	else
		wfmName= StrVarOrDefault(PanelDFVar("wfmName"),wfmName)
	endif
	ModifyControlList "numPoints;outName;" ,win=$ksPanelName, disable=wfmDisable
	SetVariable outName,win=$ksPanelName,value= _STR:wfmName

	return algorithm
End

static Function AlgorithmCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	SetAlgorithm(ctrlName)
	ShowHideEnableDisable()
End

static Function ShowHideEnableDisable()

	String title=""
	Variable disable=0 // Enable/disable the Make Waveform Button

	// Check the X and Y waves
	String pathToXWave= PopupWS_GetSelectionFullPath(ksPanelName, "xWaveSelector")
	String pathToYWave= PopupWS_GetSelectionFullPath(ksPanelName, "yWaveSelector")
	if( exists(pathToXWave) != 1 || exists(pathToYWave) != 1 )
		title="*** select X and Y waves ***"
		disable=2
	elseif( CmpStr(pathToXWave,pathToYWave) ==0 )
		title="*** select DIFFERENT X and Y waves ***"
		disable=2
	else
		// must be the same length
		Wave wx=$pathToXWave
		Wave wy=$pathToYWave
		if( numpnts(wx) != numpnts(wy) )
			title="*** select waves with the same number of points ***"
			disable=2
		endif	
	endif
	Variable setScaleDisable=disable // Disable the SetScale algorithm when the X wave is inappropriate
									// but SetScale enabling isn't affected by the output name
	if( setScaleDisable == 0 )
		// two different waves of the same length exist
		setScaleDisable = CanDoSetScale(0) ? 0 : 2
	endif
	ModifyControl useSetScale, win=$ksPanelName, disable=setScaleDisable
	
	Variable interpolateDisable= CanDoInterpolate() ? 0 : 2
	ModifyControlList "useInterpolate;useCubicInterpolate;", win=$ksPanelName, disable=interpolateDisable
	
	
	String algorithm = GetAlgorithm()
	Variable alreadyUsingInterpolation = CmpStr(algorithm,"useSetScale") != 0
	if( setScaleDisable != 0 && interpolateDisable == 0 )
		// switch to Interpolate
		if( !alreadyUsingInterpolation )
			algorithm= SetAlgorithm("useInterpolate") // linear
		endif
	elseif( interpolateDisable != 0 && setScaleDisable == 0)
		// switch to SetScale
		algorithm= SetAlgorithm("useSetScale")
	endif
	Variable usingSetScale= CmpStr(algorithm,"useSetScale") == 0

	// check the waveform name
	String waveformName= GetSetVariableStr("outName")		// can be liberal name
	String cleanedName= CleanupName(waveformName,1)		// can still a liberal name
	if( strlen(cleanedName) == 0 || CmpStr(waveformName,cleanedName) != 0 )
		disable= 2
		if( strlen(title) == 0 )
			title="*** Waveform Name is not a legal wave name ***"
		endif
	endif
	
	Variable wouldOverwrite
	String pathToWfm= PathToWaveform()	// "" if the waveform doesn't yet exist
	if( disable == 0 && !usingSetScale )
		// prevent Interpolate from overwriting the input waves
		// because disable is 0, we know that waveformName is a valid wave name (even if the wave doesn't yet exist)
		// and we know wx and wy are valid wave references
		// compare the path that *would* be generated with the x and y waves
		pathToXWave= GetWavesDataFolder(wx,4)	// it's easiest to compare waveformName to a relative path 
		pathToYWave= GetWavesDataFolder(wy,4)
		wouldOverwrite= CmpStr(waveformName,pathToXWave) == 0 || CmpStr(waveformName,pathToYWave) == 0
		if( wouldOverwrite )
			disable=2
			if( strlen(title) == 0 )
				title= "*** Cannot overwrite input wave ***"
			endif
		else
			// warn about incipient overwrite of non-input wave
			wouldOverwrite= strlen(pathToWfm) > 0 
			if( (strlen(title) == 0) && wouldOverwrite )
				title="\\K(65535,0,0)*** Warning: will overwrite existing wave "+waveformName+" ***"	// red
			endif
		endif
	endif
	TitleBox warning, win=$ksPanelName, title=title
	Button makeWaveform, win=$ksPanelName, disable=disable

	// Append to <window> button
	String topWin= WinName(0,3)
	disable= strlen(pathToWfm) > 0 ? 0 : 2
	if( strlen(topWin) == 0 )
		topWin= "window"
		disable=2
	else
		if( strlen(pathToWfm) == 0 )
			disable=2
		endif
	endif
	Button appendWaveform,win=$ksPanelName,title="Append to "+topWin, disable=disable
	Button newGraph,win=$ksPanelName,disable=disable

	// hide the axes popups unless topWin is a graph with axes
	disable= (strlen(topWin) && WinType(topWin) == 1 && strlen(AxisList(topWin)) > 0 ) ? 0 : 1
	ModifyControlList "hAxis;vAxis;", win=$ksPanelName, disable=disable
	if( disable == 0 )
		// check that the selected axes actually exist
		String axes= HVAxisList(topWin,1)
		ControlInfo/W=$ksPanelName hAxis
		if( WhichListItem(S_Value,axes) < 0 )
			PopupMenu hAxis, win=$ksPanelName, mode=1
		endif
		axes= HVAxisList(topWin,0)
		ControlInfo/W=$ksPanelName vAxis
		if( WhichListItem(S_Value,axes) < 0 )
			PopupMenu vAxis, win=$ksPanelName, mode=1
		endif
	endif
End

static Function SetRadioGroup(ctrlName, allRadioNamesList)
	String ctrlName // the checked radio button control's name
	String allRadioNamesList

	Variable i, n= ItemsInList(allRadioNamesList)
	for(i=0; i<n; i+=1)
		String control= StringFromList(i, allRadioNamesList)
		Checkbox $control win=$ksPanelName, value= CmpStr(ctrlName,control)==0
	endfor
End

static Function/S GetRadioGroup(allRadioNamesList)
	String allRadioNamesList

	Variable i, n= ItemsInList(allRadioNamesList)
	for(i=0; i<n; i+=1)
		String control= StringFromList(i, allRadioNamesList)
		ControlInfo/W=$ksPanelName $control
		if( V_Value )
			return control
		endif
	endfor
	return ""	// none checked
End

static Function WfmNameSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	// disable the Make Waveform button if the name isn't valid, etc
	ControlInfo/W=$ksPanelName $ctrlName
	if( V_disable == 0 )
		String/G $PanelDFVar("wfmName")=varStr
	endif
	ShowHideEnableDisable()
End

static Function AppendButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	String waveformName= GetSetVariableStr("outName")
	WAVE/Z w= $waveformName
	if( !WaveExists(w) )
		DoAlert 0, waveformName+" no longer exists in the current data folder!"
		return 0
	endif
	String win= WinName(0,1+2)
	if( WinType(win) == 1 )	// graph
		AppendWaveToFirstAxisPair(win, w)
	elseif( WinType(win) == 2 )	// table
		AppendToTable w.id
	endif
	ShowHideEnableDisable()	// when appending to an empty graph, now show the newly added axes.
End

static Function NewGraphButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	String waveformName= GetSetVariableStr("outName")
	WAVE/Z w= $waveformName
	if( !WaveExists(w) )
		DoAlert 0, waveformName+" no longer exists in the current data folder!"
		return 0
	endif
	Display w
	ShowHideEnableDisable()	// show the newly added axes.
End


static Function AppendWaveToFirstAxisPair(graphName, w)
	String graphName
	Wave w
	
	String info
	String hFlag=""
	String axes= HVAxisList(graphName,1)
	ControlInfo/W=$ksPanelName hAxis
	String hAxis= S_Value
	if( WhichListItem(hAxis,axes) >= 0 )
		info=AxisInfo(graphName,hAxis)
		hFlag=StringByKey("AXFLAG", info)	// /B=HorizCrossing, etc
	endif

	String vFlag=""
	axes= HVAxisList(graphName,0)
	ControlInfo/W=$ksPanelName vAxis
	String vAxis= S_Value
	if( WhichListItem(vAxis,axes) >= 0 )
		info=AxisInfo(graphName,vAxis)
		vFlag=StringByKey("AXFLAG", info)	// /B=HorizCrossing, etc
	endif

	// AppendToGraph/W=$win/L=$vAxis/B=$hAxis NameOfWave(w)
	String pathToWave= GetWavesDataFolder(w,2)
	String cmd
	sprintf cmd, "AppendToGraph/W=%s%s%s %s", graphName, hFlag, vFlag, pathToWave
	Execute/Q/Z cmd
End

static Function CloseButtonProc(ctrlName) : ButtonControl
	String ctrlName

	Execute/P/Q/Z "DoWindow/K "+ksPanelName
End

static Function HelpButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	DisplayHelpTopic "Converting XY Data to a Waveform"
End

