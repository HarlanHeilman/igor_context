#pragma rtGlobals=1		// Use modern global access method.
#pragma moduleName=FilterDialog
#pragma IndependentModule=WMFilter
#pragma IgorVersion=9	// requires Igor 9 FilterFIR/ENDV={startFill,endFill}, FilterIIR/ENDV=fillValue
#pragma version=9.0	// revised for Igor 9.0B05

// Revisions:
// Version 9.0, JP210527, added controls for FilterFIR/ENDV={startFill,endFill}, FilterIIR/ENDV=fillValue.
// Version 7.09, JP180215, Filtering a wave in a sub-datafolder no longer causes an erroneous Duplicate command.
//				- Fixed by using AbsoluteToRelativePath().
// Version 7, JP160411, Panel Resolution fixes, raised /HI and /LO num filter coefs to max (32767).
// Version 6.37, JP141111, Traces added to the response graph by the user are not removed on every update, which allows for response comparisons.
// Version 6.31, LH, PanelResolution
// 2/10/2012 - 6.30: fix for Show Phase checkbox state not being remembered when switching tabs, added db - 50dB option to response popup.
// 2/10/2012 - 6.23: fixes for coefs waves not showing up in the Select Filter Coefficients Wave tab's wave list.
// 5/26/2009 - 6.1: allows negative notchQ to get Igor 6.0 IIR notch design.
// 3/20/2009 - Revised WMFilterDialogHook to avoid recursion.
// 12/22/2008 - Revised WMFilterDialogHook to work better on Windows if maximized.
// 8/13/2008 - liberal name for filtered result and coefficients result are now properly quoted.
// 4/9/2008 - Fixed " FilterFIR gave error: Length of wave 'impulseResponse' is less than the coefficient wave" error that occured when filter length exceeded 1000.
//				- Increased impulse length from 1000 to 5000 to improve frequency resolution of the response graph.
// 3/24/2008 - Fixed highpass fir_high_n SetVariable, resized some too-big FIR controls.
// 3/16/2006 - deletes self when the dialog closes.
// 10/02/2006 - dialog size restored properly on Windows, added Gain log10 option.
// 11/08/2006 - doesn't DELETEINCLUDE itself, to avoid menu compilation problem.
// 12/18/2006 - Set phase to 45 degree increments.
// 12/29/2006 - Set phase to degree-friendly increments, added From target and Sort By controls.
// 3/12/2007 - uses ToCommandLine operation for the "To Cmd Line" button.
// 4/24/2007 - Changes to aid in localization.
// 5/2/2007 - The panel and panel subwindows are now not editable.

//#include <Pole and Zero Filter Design> menus=0	// defer this until ZeroPoleButton is pressed
#include <WaveSelectorWidget>  version >=1.20 // has fix for excessive datafolder filtering
#include <SaveRestoreWindowCoords>

static Constant kNoEdit=1	// panels not editable, set to 0 for development

// START OF LOCALIZABLE STRINGS [

// Menus
StrConstant ksFilterDotDotDotMenu = "Filter..."

// See DescribeWaveType()
static StrConstant ksDescribeTEXT="TEXT"
static StrConstant ksDescribeUnsigned="U"
static StrConstant ksDescribeSinglePrecision="SP"
static StrConstant ksDescribeDoublePrecsion="DP"
static StrConstant ksDescribeInteger8="INT8"
static StrConstant ksDescribeInteger16="INT16"
static StrConstant ksDescribeInteger32="INT32"
static StrConstant ksDescribeComplex=" CMPLX"	// NOTE THE LEADING SPACE CHARACTER

// See DescribeCoefs()
static StrConstant ksDescribeCoefsFIRFmt= "FIR (%d coefficients)"
static StrConstant ksDescribeCoefsIIRDF1Fmt= "IIR Direct Form I format %s"
static StrConstant ksDescribeCoefsIIRCascFmt= "IIR Cascade format (%d sections)"
static StrConstant ksDescribeCoefsIIRPZFmt= "IIR Zeros and Poles format (%d zeros and %d poles)"

// Dialog error messages - See GenerateCommand()
static StrConstant ksDlgErrSelectCoefsWave= "*** Select a coefficients wave in the Select Filter Coefficients Wave tab ***"
static StrConstant ksDlgErrSelectLowPassHiOrNotch= "*** Select Low Pass, High Pass, or Notch ***"
static StrConstant ksDlgErrSelectApplyWave=  "*** Select a wave in the Apply Filter tab ***"

// Dialog error messages - See AutoUpdateFilteredOutCheckProc() and UpdateFilterOutputNowButtonProc()
static StrConstant ksDlgErrSelectInputToFilter=  "Select an Input to Filter from the list above."

// Dialog error messages - See EditZerosPolesButtonProc()
static StrConstant ksDlgErrNotPoleZeroWaveFormat=  "%s is not a Zeros and Poles filter coefficients wave."	// %s is wave's path (name)

// UpdateResponse() and UpdateFilteredOutput() 
static StrConstant ksErrFilterCouldNotBeCreated= "Filter could not be created\rusing those values."
static StrConstant ksErrSelectCoefsWave= "Select a coefficients wave in the Select Filter Coefficients Wave tab."

// UpdateFilteredOutput()
static StrConstant ksErrEnterAnOutputName= "Enter an Output Name"
static StrConstant ksErrSelectInputToFilter= "Select Input to Filter"
static StrConstant ksErrAndClickUpdateOutputNow= " and click Update Output Now"	// NOTE THE LEADING SPACE CHARACTER

// ChangeFIRIIRTab()
static StrConstant ksTitleDesignUsingFrequency= "\\K(65535,0,0)Design using this Sampling Frequency (Hz)"
static StrConstant ksTitleResponseUsingFrequency= "\\K(65535,0,0)Show Response using this Sampling Frequency (Hz)"

// Dialog controls - see WMFilterDialog()
static StrConstant ksFilterDialogTitle= "Filter Design and Application"

// CheckBox createFilter
static StrConstant ksCreateFilterTitle= "Create Coefs"

// SetVariable fs
static StrConstant ksFsTitle= "\\K(65535,0,0)Design using this Sampling Frequency (Hz)"

// TabControl firIIRTab
static StrConstant ksFIR_IIRTab0Title="Design FIR Filter"
static StrConstant ksFIR_IIRTab1Title="Design IIR Filter"
static StrConstant ksFIR_IIRTab2Title="Select Filter Coefficients Wave"

// **** FIR Tab ****
static StrConstant ksFirLowpassGroupTitle="     Low Pass"
static StrConstant ksFirLowpassF1Title="End of Pass Band"
static StrConstant ksFirLowpassF2Title="Start of Reject Band"
static StrConstant ksFirLowpassNTitle="Number of Coefficients"

static StrConstant ksFirHighpassGroupTitle="     High Pass"
static StrConstant ksFirHighpassF1Title="End of Reject Band"
static StrConstant ksFirHighpassF2Title="Start of Pass Band"
static StrConstant ksFirHighpassNTitle="Number of Coefficients"

static StrConstant ksFirWindowKindTitle="Window"

static StrConstant ksFirNotchGroupTitle="     Notch"
static StrConstant ksFirNotchFcTitle="Notch Frequency"
static StrConstant ksFirNotchFwTitle="Notch Width"
static StrConstant ksFirNotchNMultTitle="Improve Notch Accuracy by"
static StrConstant ksFirNotchEPSTitle="Omit Coefs smaller than"

// **** IIR Tab ****
static StrConstant ksIIRFormatList = "Direct Form 1;Cascade (Direct Form II);Zeros and Poles;"

static StrConstant ksIIRCoefsFormatTitle="Filter Coefficients Format:"
static StrConstant ksIIRCreatePZButtonTitle="Create Filter using Poles and Zeros Editor..."

static StrConstant ksIIRLowpassGroupTitle="     Low Pass"
static StrConstant ksIIRLowpassFcTitle="Cutoff Frequency"

static StrConstant ksIIRHighpassGroupTitle="     High Pass"
static StrConstant ksIIRHighpassFcTitle="Cutoff Frequency"

static StrConstant ksIIROrderTitle="Order"

static StrConstant ksIIRNotchGroupTitle="     Notch"
static StrConstant ksIIRNotchFcTitle="Notch Frequency"
static StrConstant ksIIRNotchFwTitle="Notch Width"

// **** Select Coefs Tab ****
static StrConstant ksSelectFilterEditTitle="Edit Zeros and Poles"

// Filter Dialog P0 Response/Apply Filter controls

// TabControl responseTab
static StrConstant ksResponseTab0Title="Response"
static StrConstant ksResponseTab1Title="Apply Filter"

// **** Response Tab ****
static StrConstant ksResponseShowMagTitle="Show Magnitude"
static StrConstant ksResponseShowPhaseTitle="Show Phase"
static StrConstant ksResponsePhaseDegreesTitle="degrees"
static StrConstant ksResponsePhaseRadiansTitle="radians"
static StrConstant ksResponsePhaseUnwrapTitle="Unwrap"

// **** Apply Filter Tab ****
static StrConstant ksApplyFilterInputTitle="Input to Filter"
// PopupMenu sort
static StrConstant ksSortByTitle= "Sort By"
// CheckBox fromTarget
static StrConstant ksFromTargetTitle= "From target"
// PopupMenu endEffect
static StrConstant ksEndEffectsTitle= "End Effect(s)"
// SetVariable fillvalue
static StrConstant ksFillValueTitle= "Fill Value"
static StrConstant ksStartFillValueTitle= "Start Fill Value"
// Checkbox endFillCheck
static StrConstant ksEndFillValueTitleLong= "End Fill Value"
static StrConstant ksEndFillValueTitleShort= "End Fill"
// SetVariable endFill is untitled (title=" ")
// Checkbox iir_endFillCheck is untitled (title=" ")
// SetVariable iir_endFillValue
static StrConstant ksIIRFillValueTitle= "End Fill Value"

static StrConstant ksApplyFilterOutputTitle="Output Name"
static StrConstant ksApplyFilterAutoUpdateTitle="Auto-update Filtered Output"
static StrConstant ksApplyFilterUpdateNowTitle="Update Output Now"

// Filter Dialog P1 command controls
static StrConstant ksCmdDoItTitle="Do It"
static StrConstant ksCmdToCmdTitle="To Cmd Line"
static StrConstant ksCmdToClipTitle="To Clip"
static StrConstant ksCmdCancelTitle="Cancel"
static StrConstant ksCmdHelpTitle="Help"

// PopupMenu magnitudePop selections
static StrConstant ksMagnitudePopItems=  "dB;dB min -100;dB min -50;dB min -20;Gain;Gain log10;"

// Help Topic for Filter Dialog's Help button
static StrConstant ksFilterDialogHelpTopic="Filter Dialog"

// END OF LOCALIZABLE STRINGS ]

// Menus
Menu "Analysis"
	"Filter...", /Q, WMFilterDialog()
End


static StrConstant ksFIRWindowsList = "Bartlett;Blackman367;Blackman361;Blackman492;Blackman474;Cos1;Cos2;Cos3;Cos4;Hamming;Hanning;KaiserBessel20;KaiserBessel25;KaiserBessel30;Parzen;Poisson2;Poisson3;Poisson4;Riemann;"

// Definitions for Main FIR/IIR/Select Coefs tabs
static Constant firTabNum = 0
static Constant iirTabNum = 1
static Constant coefsTabNum = 2
static StrConstant ksFIRControls="fir_highPass;fir_high_f1;fir_high_f2;fir_high_n;fir_highpass_group;fir_low_f1;fir_low_f2;fir_low_n;fir_lowpass;fir_lowpass_group;fir_notch;fir_notch_eps;fir_notch_fc;fir_notch_fw;fir_notch_group;fir_notch_nmult;fir_windowKind;"
static StrConstant ksIIRControls="iir_coefsFormat;iir_fHigh;iir_fLow;iir_fNotch;iir_highPass;iir_highpass_group;iir_lowpass;iir_lowpass_group;iir_notch;iir_notchWidth;iir_notch_group;iir_order;createCustomZerosPolesCoefs;"
static StrConstant ksSelectCoefsControls="coefsDetails;coefsWavesList;editZerosPoles;"
static StrConstant ksCreateCoefsControls="coefsOutputName;createFilter;"

// Definitions for Response/Apply tabs
static StrConstant ksResponseControls="showMagnitude;magnitudePop;showPhase;phaseDegrees;phaseRadians;phaseUnwrap;"
static StrConstant ksApplyFilterControls="inputTitle;filterThisWave;filteredOutputName;autoUpdateFilteredOutput;updateNow;endEffect;fillValue;endFillCheck;endFillValue;iir_endFillCheck;iir_endFillValue;"
static Constant ResponseTabNum = 0
static Constant ApplyFilterTabNum = 1

// Panel and subwindow names
static StrConstant ksPanelName= "FilterDialog"
static StrConstant ksGraphName="FilterDialog#G0"
static StrConstant ksResponsePanelName="FilterDialog#P0"
static StrConstant ksCommandPanelName="FilterDialog#P1"

// Panel and Guides metrics
static Constant kGraphTopPos= 215 // panel units
//static Constant kMinResponseHeightPoints= 160
static Constant kMinResponseHeightPoints= 242
static Constant kGraphBottomOffset= -93 // panel units

static Constant kPanelHeight= 559 // kGraphTopPos + kMinResponseHeightPoints - kGraphBottomOffset ?
//		Variable vLeft=39, vTop=60, vRight=721, vBottom=559
//		vBottom += 60	// Igor 9: make room for Fill Value controls
//		Variable minHeight = vBottom - vTop	// this is the smallest permitted size.


// filter coefs types

static Constant kCoefsNone= 0
static Constant kCoefsFIR= 1
static Constant kCoefsIIRDF1= 2
static Constant kCoefsIIRCascade= 3
static Constant kCoefsIIRZerosPoles= 4

#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility with Igor 7
	String wName
	return 72
End
#endif


Static Function PanelCoordsToPoints(win, panelOrControlCoordinate)
	String win
	Variable panelOrControlCoordinate	// Igor 6 wsizeDC or Igor 7 points if screen resolution > 96 

	Variable points= panelOrControlCoordinate * PanelResolution(win) / ScreenResolution

	return points
End

// "Panel Coordinates" are used to store panel sizes to match the control coordinates.
// In this way, one control that fills the entire panel would have the same width and height values
// as the panel's "Panel Coordinates".
Static Function PointsToPanelCoords(win, points)
	String win
	Variable points 

	Variable panelOrControlCoordinate= points / PanelResolution(win) * ScreenResolution

	return panelOrControlCoordinate	// Igor 6 wsizeDC or Igor 7 points if screen resolution > 96
End


static Function ResponseTabProc(tca) : TabControl
	STRUCT WMTabControlAction &tca

	switch( tca.eventCode )
		case 2: // mouse up
			Variable tab = tca.tab	// new value
			String win= tca.win
			
			// Show/Hide the Response or Apply controls
			ShowOrHideControlList(win, ksResponseControls, tab==ResponseTabNum)
			ShowOrHideControlList(win, ksApplyFilterControls, tab==ApplyFilterTabNum)
			if( tab==ApplyFilterTabNum )
				ShowHideApplyFilterControls()
			endif

			 // switch the content of the Graph.
			UpdateResponse(0)
			break
	endswitch

	return 0
End

// NOTE: the wave DOES exist
// NOTE: this is NOT the CREATED coefs wave, NOR the temporary coefs wave
static Function/S SelectedCoefsWavePath()

	String wavePaths= WS_SelectedObjectsList(ksPanelName, "coefsWavesList")
	
	return StringFromList(0,wavePaths)	// can be ""
End

// RelativelyEqual() fails when both values are very close to (or equal) to zero)
static Function RelativelyEqual(v1,v2, releps)
	Variable v1, v2
	Variable releps	// relative difference allowed to be considered equal. Use 0.1 to specify equality to within 10%.
	
	Variable mag= max(abs(v1),abs(v2))
	Variable error= abs(v1-v2)
	Variable relError= error/mag
	return relError < releps
End

// FilterFIR creates both symmetrical filters when n is odd,
// and nearly-symmetrical filters when n is even.
static Function SymmetricWave(w)
	Wave w	// must be 1-D wave
	
	Variable n= numpnts(w)
	Variable i, diff, n2= floor(n/2)
	// When n is even the first element isn't symmetrical, and is skipped
	Variable isEven= (n & 0x1) == 0
	Variable offset= isEven ? 1 : 0
	WaveStats/Q/M=0 w
	Variable threshold= 1e-8 * max(abs(V_max),abs(V_Min))
	for(i=0; i<n2;i+=1)
		Variable v1= w[i+offset]
		Variable v2= w[n-1-i]
		Variable tooSmall= (abs(v1) < threshold) && (abs(v2) < threshold)	// 6.23
		if( !tooSmall && !RelativelyEqual(v1, v2, 0.001) )	// 0.1%
			return 0
		endif
	endfor
	return 1
End

static Function CoefsWaveKind(coefs)
	Wave/Z coefs

	if( !WaveExists(coefs))
		return kCoefsNone
	endif

	Variable columns= DimSize(coefs,1)
	Variable wt= WaveType(coefs)
	Variable isFloat = wt & 0x06
	if( !isFloat )
		return kCoefsNone
	endif
	Variable isComplex= wt & 0x1
		
	if( columns == 0 )	// could be FIR
		if( isComplex  || numpnts(coefs) ==0 )
			return kCoefsNone
		endif
		// check the symmetry
		if( !SymmetricWave(coefs) )
			return kCoefsNone
		endif
		return kCoefsFIR
	endif
	
	if( isComplex && columns == 2 )
		// use FilterIIR to check the format for conjugate pairs
		FilterIIR/ZP/Z/COEF=coefs	// no filtering is done, we're only checking V_Flag
		return V_Flag == 0 ? kCoefsIIRZerosPoles : kCoefsNone
	endif
	
	if( !isComplex )
		if( columns == 6 )
			FilterIIR/CASC/Z/COEF=coefs	// no filtering is done, we're only checking V_Flag
			return V_Flag == 0 ? kCoefsIIRCascade : kCoefsNone
		endif
		if( columns == 2 )
			FilterIIR/Z/COEF=coefs	// no filtering is done, we're only checking V_Flag
			return V_Flag == 0 ? kCoefsIIRDF1 : kCoefsNone
		endif
	endif

	return kCoefsNone
End

static Function IsZerosAndPolesWave(coefs)
	Wave/Z coefs

	return CoefsWaveKind(coefs) == kCoefsIIRZerosPoles
End

static Function/S DescribeWaveType(w)
	Wave/Z w
	
	String description=""
	if( WaveExists(w) )
		Variable wt= WaveType(w)
		if( wt == 0 )
			description= ksDescribeTEXT	// "TEXT"
		else
			Variable waveIsUnsigned = WaveType(w) & 0x40
			if( waveIsUnsigned )
				description= ksDescribeUnsigned	// "U"
			endif
			Variable waveIs32BitFloat = WaveType(w) & 0x02
			if( waveIs32BitFloat )
				description += ksDescribeSinglePrecision	// "SP"
			endif
			Variable waveIs64BitFloat = WaveType(w) & 0x04
			if( waveIs64BitFloat )
				description += ksDescribeDoublePrecsion	// "DP"
			endif
			Variable waveIs8BitInteger = WaveType(w) & 0x08
			if( waveIs8BitInteger )
				description += ksDescribeInteger8	// "INT8"
			endif
			Variable waveIs16BitInteger = WaveType(w) & 0x10
			if( waveIs16BitInteger )
				description += ksDescribeInteger16	// "INT16"
			endif
			Variable waveIs32BitInteger = WaveType(w) & 0x20
			if( waveIs32BitInteger )
				description += ksDescribeInteger32	// "INT32"
			endif
			Variable waveIsComplex = WaveType(w) & 0x01
			if( waveIsComplex )
				description += 	ksDescribeComplex	// " CMPLX"	// NOTE THE LEADING SPACE CHARACTER
			endif
		endif
	endif
	return description
End

static Function/S DescribeCoefs(coefs)
	Wave/Z coefs
	
	String description=""
	
	if( WaveExists(coefs) )
		Variable rows= DimSize(coefs,0)
		Variable cols= DimSize(coefs,1)
		String size
		if( cols == 0 )
			size= "("+num2istr(rows)+")"
		else
			size= "("+num2istr(rows)+","+num2istr(cols)+")"
		endif
		Variable kindOfCoefs= CoefsWaveKind(coefs)
		switch( kindOfCoefs )
			case kCoefsFIR:
				sprintf description, ksDescribeCoefsFIRFmt, rows	// "FIR (%d coefficients)"
				break
			case kCoefsIIRDF1:
				sprintf description, ksDescribeCoefsIIRDF1Fmt, size	//  "IIR Direct Form I format %s"
				break
			case kCoefsIIRCascade:
				sprintf description, ksDescribeCoefsIIRCascFmt, rows	//   "IIR Cascade format (%d sections)"
				break
			case kCoefsIIRZerosPoles:
				sprintf description, ksDescribeCoefsIIRPZFmt, rows, rows	//  "IIR Zeros and Poles format (%d zeros and %d poles)"
				break
			default:
				return ""
		endswitch

		description += " " +DescribeWaveType(coefs)

	endif	
	return description
End

static Function UpdateForIIRCoefsFormat()
	SVAR iir_coefsFormat= root:Packages:WM_FilterDialog:iir_coefsFormat
	
	Variable whichItem= WhichListItem(iir_coefsFormat, ksIIRFormatList)
	Variable disable= (whichItem == 2) ? 0 : 2	// enable (and show) if Zeros and Poles format
	// alter to accomodate the visibility of the tab.
	ControlInfo/W=$ksPanelName  firIIRTab
	if( V_Value != iirTabNum )
		disable += 1
	endif
	ModifyControl/Z createCustomZerosPolesCoefs, win=$ksPanelName, disable=disable
End

static Function UpdateForSelectedCoefsWave()

	SVAR pathToSelectedCoefs= root:Packages:WM_FilterDialog:pathToSelectedCoefs
	
	pathToSelectedCoefs= SelectedCoefsWavePath()
	Wave/Z coefs= $pathToSelectedCoefs
	
	// update the readout
	SVAR descriptionOfSelectedCoefs= root:Packages:WM_FilterDialog:descriptionOfSelectedCoefs
	descriptionOfSelectedCoefs= DescribeCoefs(coefs)

	ControlInfo/W=$ksPanelName coefsWavesList
	if( V_disable != 1 )
		Variable disable= IsZerosAndPolesWave(coefs) ? 0 : 2
		ModifyControl/Z editZerosPoles, win=$ksPanelName, disable=disable
	endif

End

static Function SelectCoefsNotificationProc(SelectedItem, EventCode)
	String SelectedItem		// string with full path to the item clicked on in the wave selector
	Variable EventCode		// the ListBox event code that triggered this notification

	switch( EventCode )
		case WMWS_DoubleClick:
			Wave/Z w = $SelectedItem
			if( WaveExists(w) )
// TO DO: Use ReplaceWave instead of always regenerating the graph
				DoWindow/K FilterDialogCoefsTable
				Edit/N=FilterDialogCoefsTable/K=1 w
				AutoPositionWindow/E/R=$ksPanelName FilterDialogCoefsTable
			endif
			break
		case WMWS_SelectionChanged:
			UpdateForSelectedCoefsWave()
			PossiblyShowHideApplyFilterControls()
			UpdateResponse(0)
			break
	endswitch
End

static Function ApproveCoefsWave(theNameWithPath, ListContents)
	String theNameWithPath
	Variable ListContents
	
	Wave/Z coefs= $theNameWithPath
	Variable kindOfCoefs= CoefsWaveKind(coefs)
	if( kindOfCoefs == kCoefsNone )
		return 0
	endif
	
	Variable isOK= WaveExists(coefs)
	if( isOK )
		ControlInfo/W=$ksPanelName fromTarget
		if( V_Value )
			isOK = WaveDisplayedInTarget(coefs)
		endif
	endif
	return isOK
end

static Function WaveDisplayedInTarget(w)
	Wave w
	
	String target= WinName(0,1+2,1)	// topmost visible graph or table
	if( CmpStr(target,"DesignFilterZerosPoles") == 0 )
		target= WinName(1,1+2,1)	// next most visible graph or table
	endif
	CheckDisplayed/W=$target  w
	return V_Flag 
End

static Function ApproveWaveToFilter(theNameWithPath, ListContents)
	String theNameWithPath
	Variable ListContents
	
	Wave/Z w= $theNameWithPath
	Variable isOK= WaveExists(w)
	if( isOK )
		ControlInfo/W=$ksPanelName fromTarget
		if( V_Value )
			isOK = WaveDisplayedInTarget(w)
		endif
	endif
	return isOK
end

static Function FilterDesignFromTargetCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			WS_UpdateWaveSelectorWidget(ksPanelName, "coefsWavesList")
			WS_UpdateWaveSelectorWidget(ksResponsePanelName, "filterThisWave")
			break
	endswitch

	return 0
End


static Function InputToFilterNotificationProc(SelectedItem, EventCode)
	String SelectedItem		// string with full path to the item clicked on in the wave selector
	Variable EventCode		// the ListBox event code that triggered this notification

	switch( EventCode )
		case WMWS_DoubleClick:
			Wave/Z w = $SelectedItem
			if( WaveExists(w) )
// TO DO: Use ReplaceWave instead of always regenerating the graph
				DoWindow/K FilterDialogInputGraph
// TO DO: Handle stereo data				
				Display/N=FilterDialogInputGraph/K=1 w
				AutoPositionWindow/E/R=$ksPanelName FilterDialogInputGraph
			endif
			break
		case WMWS_SelectionChanged:
			Wave/Z w = $SelectedItem
			if( WaveExists(w) )
				Variable fs= 1/deltax(w)
				Variable/G root:Packages:WM_FilterDialog:fs= fs
				UpdateFs(fs)	// calls UpdateResponse(0)
			else
				UpdateResponse(0)	// show blank response
			endif
			break
	endswitch
End

static Function UpdateFs(newFs)
	Variable newFs
	
	// Update all the frequencies from the old fs to the new fs
	
	String dfSave= GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O/S root:Packages:WM_FilterDialog
	NVAR fs
	
	fs= newFs
	
	// transform the normalized values....
	// FIR
	NVAR fir_low_f1, fir_low_f2
	NVAR  fir_high_f1, fir_high_f2
	NVAR  fir_notch_fc, fir_notch_fw
	// IIR
	NVAR iir_fLow
	NVAR iir_fHigh
	NVAR  iir_fNotch, iir_notchWidth

	// ...into the frequency-scaled values that are controlled by SetVariables
	
	// FIR
	NVAR fir_low_f1_fs, fir_low_f2_fs
	NVAR  fir_high_f1_fs, fir_high_f2_fs
	NVAR  fir_notch_fc_fs, fir_notch_fw_fs
	// IIR
	NVAR iir_fLow_fs
	NVAR iir_fHigh_fs
	NVAR  iir_fNotch_fs, iir_notchWidth_fs

	// FIR
	fir_low_f1_fs= fir_low_f1 * fs
	fir_low_f2_fs= fir_low_f2 * fs
	fir_high_f1_fs= fir_high_f1 * fs
	fir_high_f2_fs= fir_high_f2 * fs
	fir_notch_fc_fs= fir_notch_fc * fs
	fir_notch_fw_fs= fir_notch_fw * fs
	
	// IIR
	iir_fLow_fs= iir_fLow * fs
	iir_fHigh_fs= iir_fHigh * fs
	iir_fNotch_fs= iir_fNotch * fs
	iir_notchWidth_fs= iir_notchWidth * fs

	SetDataFolder dfSave

	
	UpdateResponse(0)	
	
End


// show the frequency response of the standard IIR filter in a subgraph
static Function UpdateResponse(updateNow)
	Variable updateNow	// if true, disregard unchecked autoUpdate

	String cmd=GenerateCommand()	// update the command in the TitleBox (and for the Do It, etc buttons)

	
	// update the Response trace(s) in ksGraphName,
	// OR the Apply Filter trace(s) in ksGraphName.
	if( !updateNow )
		updateNow= AutoUpdateFiltered()
	endif

	ControlInfo/W=$ksResponsePanelName responseTab	// TabControl
	Variable tab= V_value
	if( tab == 0 )
		UpdateFrequencyResponse()
	else
		UpdateFilteredOutput(updateNow)
	endif
End

static Function AutoUpdateFiltered()
	ControlInfo/W=$ksResponsePanelName autoUpdateFilteredOutput
	return V_Value
End

static Function DoingFIR()
	ControlInfo/W=$ksPanelName firIIRTab
	return V_Value == firTabNum
End

static Function DoingIIR()
	ControlInfo/W=$ksPanelName firIIRTab
	return V_Value == iirTabNum
End

static Function DoingUserCoefs()
	ControlInfo/W=$ksPanelName firIIRTab
	return V_Value == coefsTabNum
End

static Function/S AddEndEffects(Variable doFIR)
	String command=""
	if( doFIR )
		NVAR endEffect, fillValue, endFillCheck,endFillValue
		if( endEffect != 0 ) // default is bounce
			String str
			sprintf str,"/E=%d", endEffect
			command += str
			if( endEffect == 2 && (fillValue!=0 || (endFillCheck && endFillValue != 0)) ) // /E=2 is fill, default is 0
				if( endFillCheck && endFillValue != 0 )
					sprintf str,"/ENDV={%g,%g}", fillValue,endFillValue
				else
					sprintf str,"/ENDV={%g}", fillValue
				endif
				command += str
			endif
		endif
	else
		NVAR iir_endFillCheck,iir_endFillValue
		if( iir_endFillCheck && iir_endFillValue != 0 )
			sprintf command,"/ENDV=%g", iir_endFillValue
		endif
	endif
	return command
End

//	Generate an FilterFIR or FilterIIR command using the values entered into the controls
// WITHOUT any /COEF or output waves.
static Function/S GenerateRawCommand(isFIR)
	Variable &isFIR	// OUTPUT

	// TO DO: handle already-created and selected IIR or FIR coefficients waves
	String command="", str
	String dfSave= GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O/S root:Packages:WM_FilterDialog
	NVAR fs
	Variable f1,f2,n
	if( DoingFIR() )	// that is, if DESIGNING an FIR filter
		command= "FilterFIR"
		isFIR= 1
		
		NVAR fir_lowpass_check, fir_low_f1, fir_low_f2, fir_low_n
		if( fir_lowpass_check )
			sprintf str,"/LO={%g,%g,%d}", fir_low_f1, fir_low_f2, fir_low_n
			command += str
		endif

		NVAR fir_highpass_check, fir_high_f1, fir_high_f2, fir_high_n
		if( fir_highpass_check )
			sprintf str,"/HI={%g,%g,%d}", fir_high_f1, fir_high_f2, fir_high_n
			command += str
		endif
		
		SVAR fir_windowKind
		if( (fir_lowpass_check || fir_highpass_check) && CmpStr(fir_windowKind,"Hanning") != 0 )
			command += "/WINF="+fir_windowKind
		endif
		
		NVAR fir_notch_check, fir_notch_fc, fir_notch_fw, fir_notch_nmult,fir_notch_eps
		if( fir_notch_check )
			sprintf str,"/NMF={%g,%g,%g,%d}", fir_notch_fc, fir_notch_fw, fir_notch_eps,fir_notch_nmult
			command += str
		endif
		
		command += AddEndEffects(1) // 1 = doFIR
		
		if( !fir_lowpass_check && !fir_highpass_check && !fir_notch_check )
			command= ""	// nothing checked, don't generate a command
		endif
	endif
	if( DoingIIR() )	// that is, if DESIGNING an IIR filter
		command= "FilterIIR"
		isFIR= 0
		
		SVAR iir_coefsFormat
		switch( WhichListItem(iir_coefsFormat, ksIIRFormatList))
			case 0:	//Direct Form 1
				break
			case 1:	// Cascade (Direct Form II
				command += "/CASC"
				break
			case 2: // Zeros and Poles
				command += "/ZP"
				break
		endswitch
		
		NVAR iir_lowpass_check,iir_fLow
		if( iir_lowpass_check )
			sprintf str,"/LO=%g", iir_fLow
			command += str
		endif

		NVAR iir_highpass_check,iir_fHigh
		if( iir_highpass_check )
			sprintf str,"/HI=%g", iir_fHigh
			command += str
		endif

		NVAR iir_order
		if( (iir_lowpass_check || iir_highpass_check ) && iir_order != 2 )
			command += "/ORD="+num2istr(iir_order)
		endif

		NVAR iir_notch_check, iir_fNotch, iir_notchWidth
		if( iir_notch_check )
			Variable notchQ= round(iir_fNotch/iir_notchWidth)
			if( numtype(notchQ) != 0 )
				notchQ= 1000
			endif
			sprintf str,"/N={%g,%g}", iir_fNotch, notchQ
			command += str
		endif

		command += AddEndEffects(0) // 0 for IIR

		if( !iir_lowpass_check && !iir_highpass_check && !iir_notch_check )
			command= ""	// nothing checked, don't generate a command
		endif
	endif
	if( DoingUserCoefs() )	// could be IIR or FIR
		isFIR= 0
		String pathToSelectedCoefs= SelectedCoefsWavePath()
		WAVE/Z coefs=$pathToSelectedCoefs
		if( WaveExists(coefs) )
			Variable kindOfCoefs= CoefsWaveKind(coefs)
			switch( kindOfCoefs )
				case kCoefsFIR:
					command= "FilterFIR"	// GenerateCommand() will add "/COEF="+pathToSelectedCoefs
					isFIR= 1
					break
				case kCoefsIIRDF1:
					command= "FilterIIR"	// GenerateCommand() will add "/COEF="+pathToSelectedCoefs
					break
				case kCoefsIIRCascade:
					command= "FilterIIR/CASC"	// GenerateCommand() will add "/COEF="+pathToSelectedCoefs
					break
				case kCoefsIIRZerosPoles:
					command= "FilterIIR/ZP"	// GenerateCommand() will add "/COEF="+pathToSelectedCoefs
					break
			endswitch
			command += AddEndEffects(isFIR)
		endif
	endif
	
	SetDataFolder dfSave
	return command
End

static Function/S GenerateCommand()

	Variable generateFilter= 0	
	Variable haveOutput=0
	String df= GetDataFolder(1)	// has trailing ":"
	Variable disableDoIt= 0
	Variable isFIR
	String cmd= GenerateRawCommand(isFIR)	// has no /COEF, /COEF=userCoefs, and no output wave, will be "" if designing IIR or FIR and nothing is checked.
	String red="\\K(65535,0,0)"

	// the commands support EITHER generating a coefficients wave or accepting a user-supplied coefficients wave, but not both.
	Variable haveUserCoefs=DoingUserCoefs()
	if( haveUserCoefs )
		String pathToSelectedCoefs= SelectedCoefsWavePath()
		WAVE/Z coefs=$pathToSelectedCoefs
		if( WaveExists(coefs) )
			// use current data folder-relative paths instead of absolute paths
			pathToSelectedCoefs= AbsoluteToRelativePath(df, pathToSelectedCoefs)
			cmd += "/COEF="+pathToSelectedCoefs+" "
		else
			cmd=red+ksDlgErrSelectCoefsWave	// "*** Select a coefficients wave in the Select Filter Coefficients Wave tab ***"
			disableDoIt=2
		endif
	endif
	
	if( !haveUserCoefs )
		if(  strlen(cmd)== 0 )
			cmd=red+ksDlgErrSelectLowPassHiOrNotch		// "*** Select Low Pass, High Pass, or Notch ***"
			disableDoIt=2
		else
			// possibly add /COEF and output wave name if "Create Filter Coefficients Wave" is checked
			ControlInfo/W=$ksPanelName createFilter
			generateFilter= V_Value
			if( generateFilter )
				SVAR coefsOutputName= root:Packages:WM_FilterDialog:coefsOutputName
				String quotedCoefsName= PossiblyQuoteName(coefsOutputName)
				cmd = "Make/O/D/N=0 "+quotedCoefsName+"; DelayUpdate\r" + cmd
				cmd += "/COEF "+quotedCoefsName
			endif
		endif
	endif
	
	// possibly add command to filter the input wave.
	String inputPath= FilterInputWavePath()		// "" if no input, else path to existing wave
	String outputPath= FilteredOutputWavePath()	// path to output wave, may not exist even if not "".
	if( disableDoIt==0 && strlen(inputPath) && strlen(outputPath) )
		// Filter a duplicate of the input wave
		// use current data folder-relative paths instead of absolute paths
		inputPath= AbsoluteToRelativePath(df, inputPath)
		outputPath= AbsoluteToRelativePath(df, outputPath)
		cmd= ReplaceString("FilterFIR/", cmd, "FilterFIR/DIM=0/", 0, 1)
		cmd = "Duplicate/O "+inputPath+", "+outputPath+"; DelayUpdate\r" + cmd
		if( generateFilter )
			cmd += ", "
		endif
		cmd += outputPath
		haveOutput= 1
	endif
	
	if( disableDoIt == 0 && haveUserCoefs && !haveOutput )	// what's the point of that from the user's standpoint? (it's legal, but used only for checking the coefs format)
		cmd=red+ksDlgErrSelectApplyWave	// "*** Select a wave in the Apply Filter tab ***"
		disableDoIt=2
	endif

	String/G root:Packages:WM_FilterDialog:command=  cmd		// for the TitleBox control
	ModifyControlList/Z "doIt;toCmdLine;toClip;" win=$ksCommandPanelName, disable= disableDoIt
	return cmd
End

// 7.09: previously the : char was missing from relative paths to waves in subfolders
static Function/S AbsoluteToRelativePath(basePath, absPath)
	String basePath, absPath // (basePath is usually the current data folder)

	String relPath= absPath
	if( GrepString(absPath, "(?i)^"+basePath) )	// see if absPath starts with basePath (case insensitive)
		relPath= ReplaceString(basePath, absPath, ":", 0, 1)
	endif
	// check for :name, which is the same as just a plain name, but leave :folder:name alone.
	Variable pos0 = strsearch(relPath,":",0)
	if( pos0 == 0) // : at start
		Variable pos1 = strsearch(relPath,":",1)
		if( pos1 < 0 ) // the : at the start was the only :
			relPath[0,0]=""			// remove it.
		endif
	endif

	return relPath
End

// returns path to dialog-local coefs wave in the root:Packages:WM_FilterDialog: data folder
// OR to the user-selected coefs
static Function/S CreateCoefs(isFIR)
	Variable &isFIR	// OUTPUT

	if( DoingUserCoefs() )
		String pathToSelectedCoefs= SelectedCoefsWavePath()
		WAVE/D/Z coefs=$pathToSelectedCoefs
		Variable kindOfCoefs= CoefsWaveKind(coefs)
		isFIR= kindOfCoefs==kCoefsFIR
		return pathToSelectedCoefs
	endif
	
	//	Generate an FIR or IIR filter using the values entered into the controls
	// Do this in the WM_FilterDialog data folder to avoid a V_Flag variable being created in the current data folder.
	String df= GetDataFolder(1)
	SetDataFolder root:Packages:WM_FilterDialog
	String cmdNoCOEF= GenerateRawCommand(isFIR)
	// Add /COEF to create a coefficients wave in the WM_FilterDialog data folder
	Make/O/D/N=0 coefs
	// create the filter
	String command = cmdNoCOEF + "/DIM=0/COEF coefs"
	Execute/Q/Z command
	WAVE/Z coefs
	SetDataFolder df
	return GetWavesDataFolder(coefs,2)	// full path, the wave is a zero-point wave if the filter couldn't be created
End

static Function UpdateFrequencyResponse()
	String dfSave= GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O/S root:Packages:WM_FilterDialog

	Variable isFIR
	String coefsPath= CreateCoefs(isFIR)
	WAVE/Z/D coefs= $coefsPath

	WAVE/D/Z magnitude, phase	// Fake out the FFT command to generate real (not complex) wave references.
	Variable phaseIsInDegrees=0
	if( WaveExists(coefs) && DimSize(coefs,0) > 0 )	// a zero-points wave means the filter couldn't be realized.
		// filter an impulse
		Variable coefsSizeEven= (DimSize(coefs,0)+1) %& ~0x1
		Variable npnts=max(50000, coefsSizeEven)
		if( !WaveExists(impulseResponse) || numpnts(impulseResponse) != npnts )
			Make/O/D/N=(npnts) impulseResponse
		endif
		Variable fs= NumVarOrDefault("root:Packages:WM_FilterDialog:fs", 1)
		SetScale/P x, 0, 1/fs, "s" impulseResponse
		if( isFIR )
			impulseResponse= p==npnts/2
		else
			impulseResponse= p==0
		endif
		ApplyFilterToWave(coefs, impulseResponse)
		
		// measure the response 
		FFT/MAG/DEST=magnitude impulseResponse

		SetScale d, 0, 0, "dB", magnitude
		Variable ignorePhaseIfMagLE= -inf	// that is, don't ignore any phase values
		Variable logType= 0
		ControlInfo/W=$ksResponsePanelName magnitudePop
		strswitch(S_value)	// static StrConstant ksMagnitudePopItems=  "dB;dB min -100;dB min -50;dB min -20;Gain;Gain log10;"
			case "dB":
				magnitude= 20*log(magnitude)
				break
			case "dB min -100":
				magnitude= max(-100,20*log(magnitude))
				ignorePhaseIfMagLE= -100
				break
			case "dB min -50":
				magnitude= max(-50,50*log(magnitude))
				ignorePhaseIfMagLE= -50
				break
			case "dB min -20":
				magnitude= max(-20,20*log(magnitude))
				ignorePhaseIfMagLE= -20
				break
			case "Gain log10":
				logType= 1
				// fall through
			case "Gain":
			default:
				SetScale d, 0, 0, "", magnitude
				break
		endswitch
		FFT/OUT=5/DEST=phase impulseResponse
		
		if( isFIR )
			phase= 0
		else
			// omit phase where magnitude < minDB
			if( numtype(ignorePhaseIfMagLE) == 0 )
				phase= (magnitude[p] <= ignorePhaseIfMagLE) ? NaN : phase[p]
			endif
			Variable modulus= 2*pi
			ControlInfo/W=$ksResponsePanelName phaseDegrees
			phaseIsInDegrees= V_Value
			if( phaseIsInDegrees )
				modulus= 360
				phase *= 180/pi		// convert to degrees
				SetScale d, 0, 0, "deg", phase
			else
				SetScale d, 0, 0, "rad", phase
			endif
			ControlInfo/W=$ksResponsePanelName phaseUnwrap
			if(V_Value )
				phase[0] = phase[1]
				Unwrap modulus, phase	// continuous phase
			endif
		endif
	
	else
		Make/O/D/N=0 magnitude, phase
		SetScale d, 0, 0, "", magnitude, phase
	endif	
	SetDataFolder dfSave				

	// remove any traces that aren't magnitude or phase
	
	Variable needToAppendMagnitude= 1
	Variable needToAppendPhase= !isFIR
	String pathToMagnitude= "root:Packages:WM_FilterDialog:magnitude"
	String pathToPhase= "root:Packages:WM_FilterDialog:phase"
	String traces= TraceNameList(ksGraphName, ";", 1)
	Variable i, n= ItemsInList(traces)
	for(i=0; i<n; i+=1 )
		String traceName= StringFromList(i,traces)
		String path= GetWavesDataFolder(TraceNameToWaveRef(ksGraphName, traceName), 2)
		if( CmpStr(path,pathToMagnitude) == 0 )
			needToAppendMagnitude= 0
		elseif( CmpStr(path,pathToPhase) == 0 && needToAppendPhase )
			needToAppendPhase= 0
		else
			// JP141111: permit user-appended waves to persist
			String dfOnly= GetWavesDataFolder(TraceNameToWaveRef(ksGraphName, traceName), 1)
			if( CmpStr(dfOnly,"root:Packages:WM_FilterDialog:") == 0 )
				RemoveFromGraph/W=$ksGraphName $tracename
			endif
		endif
	endfor
	// append the filtered output
	Wave/Z magnitude=$pathToMagnitude
	if( WaveExists(magnitude) && needToAppendMagnitude )
		AppendToGraph/W=$ksGraphName magnitude
	endif	
	Wave/Z phase=$pathToPhase
	if( WaveExists(phase) && needToAppendPhase )
		AppendToGraph/R/W=$ksGraphName phase
		ModifyGraph/W=$ksGraphName rgb(phase)=(0,0,65535)
	endif	

	Variable rightAxisExists= WhichListItem("right",AxisList(ksGraphName)) >= 0
	if( WaveExists(phase) && rightAxisExists )
		Variable inc= 0, minorTicks
		if( phaseIsInDegrees )
			inc= ChooseDegreesIncrement(phase, ksGraphName, "right", minorTicks)
		endif
		if( inc == 0 )
			ModifyGraph/W=$ksGraphName minor(right)=1,manTick(right)=0
		else
			ModifyGraph/W=$ksGraphName manTick(right)={0,inc,0,0},manMinor(right)={minorTicks,0}
		endif
	endif
	
	ControlInfo/W=$ksResponsePanelName showMagnitude
	ModifyGraph/W=$ksGraphName hideTrace(magnitude)=!V_value, log(left)=logType

	if( isFIR )
		Variable/G root:Packages:WM_FilterDialog:zero = 0
		Checkbox showPhase win=$ksResponsePanelName, variable= root:Packages:WM_FilterDialog:zero
		ModifyControlList/Z "showPhase;phaseDegrees;phaseRadians;phaseUnwrap;" win=$ksResponsePanelName, disable= 2
	else
		Checkbox showPhase win=$ksResponsePanelName, disable= 0 ,variable= root:Packages:WM_FilterDialog:phase_check
		ControlInfo/W=$ksResponsePanelName showPhase
		ModifyControlList/Z "phaseDegrees;phaseRadians;phaseUnwrap;" win=$ksResponsePanelName, disable= V_value ? 0 : 2
		ModifyGraph/W=$ksGraphName hideTrace(phase)=!V_value
	endif
	
	if( DimSize(coefs,0) > 0 )
		Legend/W=$ksGraphName/C/N=ResponseLegend ""
	else
		String text=ksErrFilterCouldNotBeCreated	// "Filter could not be created\rusing those values."
		if( DoingUserCoefs() )
			text=ksErrSelectCoefsWave	// "Select a coefficients wave in the Select Filter Coefficients Wave tab."
		endif
		Legend/W=$ksGraphName/C/N=ResponseLegend "\\JC\\K(65535,0,0)"+text
	endif
End

static Function ChooseDegreesIncrement(wDegrees, graphName, axisName, minorTicks)
	Wave wDegrees
	String graphName, axisName
	Variable &minorTicks
	
	GetWindow $graphName psize
	Variable approxGraphHeightInPoints= V_bottom- V_top
	String fontName
	Variable fontStyle
	Variable fontSize= AxisLabelFontSizeStyle(graphName, axisName, fontName, fontStyle)	// in points

	// figure out how many labels will fit on the axis.
	// here we're assuming that the axis is vertical (left/right)
	// and the labels are horizontal, so they stack their heights
	Variable labelHeightPixels= FontSizeHeight(fontName, fontSize, fontStyle)
	Variable labelHeightPoints= PanelCoordsToPoints(graphName,labelHeightPixels)
	Variable maxLabels= floor(approxGraphHeightInPoints/labelHeightPoints)

	WaveStats/Q/M=1 wDegrees
	Variable range= V_max-V_min
	Variable delta= range/(maxLabels / 1.1)
	Variable inc
	// round to multiple of 360, 90, 45, 15, or 5
	inc= 360 * round(delta/360)
	minorTicks= 3	// 90 degrees
	if( inc == 0 )
		inc= 90 * round(delta/90)
		minorTicks= 2	// 30 degrees
		if( inc == 0 )
			inc= 45 * round(delta/45)
			minorTicks= 2	// 15 degrees
			if( inc == 0 )
				inc= 15 * round(delta/15)
				minorTicks= 2	// 5 degrees
				if( inc == 0 )
					inc= 5 * round(delta/5)
					minorTicks= 4	// 1 degrees
				endif
			endif
		endif
	endif
	return inc
End

// this belongs in <Axis Utilities>
// Requires Igor 6.0
static Function AxisLabelFontSizeStyle(graphName, axisName, fontName, fontStyle)
	String graphName, axisName
	String &fontName
	Variable &fontStyle
	
	String info= AxisInfo(graphName,axisName)
	fontName= StringByKey("FONT", info)
	fontStyle= NumberByKey("FONTSTYLE", info)
	return NumberByKey("FONTSIZE",info)
End

static Function ApplyFilterToWave(filter, filterThis [,endEffect, fillValue, endFillValue])
	Wave filter	// IIR or FIR coefs, will be 0 points if no filter was designed.
	Wave filterThis	// replaced with filtered result
	// Optional params
	Variable endEffect, fillValue, endFillValue
	if( ParamIsDefault(endEffect) )
		endEffect=1
	endif
	if( ParamIsDefault(fillValue) )
		fillValue=0
	endif
	if( ParamIsDefault(endFillValue) )
		endFillValue=fillValue
	endif
	
	Variable filterLen= DimSize(filter,0)
	Variable V_Flag= filterLen == 0
	if( V_Flag  )
		filterThis= NaN	// without this, it looks like there actually is an all-pass filter.
	else
		Variable isFIR= DimSize(filter,1) == 0
		if( isFIR )
			// avoid "filtered wave is shorter than filter" error
			if( filterLen > DimSize(filterThis,0) )
				if( filterLen & 0x1 )	// if odd,
					filterLen += 1		// make even
				endif
				Redimension/N=(filterLen,-1,-1,-1) filterThis
			endif
			if( endEffect == 2 ) 	// fill
				FilterFIR/ENDV={fillValue, endFillValue}/COEF=filter filterThis	// /ENDV implies /E=2	
			else
				FilterFIR/E=(endEffect)/COEF=filter filterThis	
			endif	
		else
			Variable wt= WaveType(filter)
			Variable isComplex= wt & 0x1
			if( isComplex )
				FilterIIR/Z/COEF=filter/ZP/ENDV=(endFillValue) filterThis	// zero-poles format
			else
				if( DimSize(filter,1) >= 6 )
					FilterIIR/Z/COEF=filter/CASC/ENDV=(endFillValue) filterThis	// DF2 format
				else
					FilterIIR/Z/COEF=filter/ENDV=(endFillValue) filterThis	// DF1 format
				endif			
			endif
		endif
	endif
	return V_Flag
End

// creates a filtered wave named "filtered" in the WM_FilterDialog data folder.
// This wave could potentially be large and should be cleaned up when the dialog is closed.
Static Function UpdateFilteredOutput(updateNow)
	Variable updateNow	// if true, filter the input data, otherwise just ensure the traces are shown/hidden

	Variable isFIR
	String coefsPath= CreateCoefs(isFIR)
	WAVE/Z/D filter= $coefsPath	// the filter coefficients in IIR or FIR format, will be 0 points if no filter was designed.

	Wave/Z filterInputWave= $FilterInputWavePath()	// that is, the input TO the filter
	String outputName= StrVarOrDefault("root:Packages:WM_FilterDialog:filteredOutputName", "filtered")

	// allow "" outputName to mean "don't filter the input"
	if( strlen(outputName) == 0 )
		Textbox/W=$ksGraphName/C/N=ResponseLegend ksErrEnterAnOutputName	// "Enter an Output Name"
		return 0
	endif
	
	// protect against inputName==outputName
	if( WaveExists(filterInputWave) && CmpStr(NameOfWave(filterInputWave),outputName) == 0 )
		String df= GetDataFolder(1)
		SetDataFolder GetWavesDataFolder(filterInputWave,1)
		outputName= UniqueName(outputName, 1, 0)
		String/G root:Packages:WM_FilterDialog:filteredOutputName= outputName
		SetDataFolder df				
	endif
	
	// NOTE: the outputName is used ONLY to create the final filtered result when the user presses "Do It".
	// the filtered output is always stored in a wave named "filtered" in the WM_FilterDialog data folder,
	// and it is this wave that is displayed in the Filtered Output graph ksGraphName
	outputName="filtered"
	Wave/Z output= TraceNameToWaveRef(ksGraphName, outputName)
	
	Variable filterFailed= 0
	if( updateNow && WaveExists(filter) && WaveExists(filterInputWave) )
		String dfSave= GetDataFolder(1)
		NewDataFolder/O root:Packages
		NewDataFolder/O/S root:Packages:WM_FilterDialog
		// filter the input wave using the given output name
		Duplicate/O filterInputWave, $outputName
		Wave output=$outputName
		
		if( isFIR )
			NVAR endEffect= root:Packages:WM_FilterDialog:endEffect
			NVAR fillValue= root:Packages:WM_FilterDialog:fillValue
			NVAR endFillCheck= root:Packages:WM_FilterDialog:endFillCheck
			NVAR endFillValue= root:Packages:WM_FilterDialog:endFillValue
			if( endFillCheck )
				filterFailed= ApplyFilterToWave(filter, output, endEffect=endEffect, fillValue=fillValue, endFillValue=endFillValue)
			else
				filterFailed= ApplyFilterToWave(filter, output, endEffect=endEffect, fillValue=fillValue)
			endif
		else
			NVAR iir_endFillCheck= root:Packages:WM_FilterDialog:iir_endFillCheck
			if( iir_endFillCheck )
				NVAR iir_endFillValue= root:Packages:WM_FilterDialog:iir_endFillValue
				filterFailed= ApplyFilterToWave(filter, output, endFillValue=iir_endFillValue)
			else
				filterFailed= ApplyFilterToWave(filter, output)
			endif
		endif
		
		SetDataFolder dfSave
		String cmd= GetIndependentModulename()+"#WS_UpdateWaveSelectorWidget(\"" + ksResponsePanelName +"\", \"filterThisWave\")"
		Execute/P/Q/Z cmd
	endif

	// update the graph 

	// remove any other traces that aren't output
	String outputPath= ""
	if( WaveExists(output) )
		outputPath= GetWavesDataFolder(output,2)
	endif
	Variable needToAppendOutput= 1
	String traces= TraceNameList(ksGraphName, ";", 1)
	Variable i, n= ItemsInList(traces)
	for(i=0; i<n; i+=1 )
		String traceName= StringFromList(i,traces)
		String path= GetWavesDataFolder(TraceNameToWaveRef(ksGraphName, traceName), 2)
		if( CmpStr(path,outputPath) == 0 )
			needToAppendOutput= 0
		else
			RemoveFromGraph/W=$ksGraphName $tracename
		endif
	endfor
	// append the filtered output
	if( WaveExists(output) && needToAppendOutput )
		AppendToGraph/W=$ksGraphName output
	endif
	
	traces= TraceNameList(ksGraphName, ";", 1)
	n= ItemsInList(traces)
	if( n < 1 )
		String text=ksErrSelectInputToFilter	// "Select Input to Filter"
		if( !AutoUpdateFiltered() )
			text += ksErrAndClickUpdateOutputNow	// " and click Update Output Now"
		endif
		Textbox/W=$ksGraphName/C/N=ResponseLegend text
	else
		if( filterFailed )
			Textbox/W=$ksGraphName/C/N=ResponseLegend ksErrFilterCouldNotBeCreated	// "Filter could not be created\rusing those values."
		else
			Legend/W=$ksGraphName/C/N=ResponseLegend ""
		endif
	endif
End

// NOTE: the wave DOES exist
static Function/S FilterInputWavePath()

	String wavePaths= WS_SelectedObjectsList(ksResponsePanelName, "filterThisWave")
	
	return StringFromList(0,wavePaths)	// can be ""
End

// return the path to where to create the filtered output wave, which is to be created in the CURRENT data folder (often the root data folder)
// NOTE: the output wave is NOT created here.
static Function/S FilteredOutputWavePath()

	String outputName= StrVarOrDefault("root:Packages:WM_FilterDialog:filteredOutputName", "filtered")

	if( strlen(outputName) == 0 )
		return ""	// blank text in the Output Name SetVariable
	endif

	if( CmpStr(CleanupName(outputName, 1), outputName) != 0 )
		return ""	// illegal name
	endif

	String outputWavePath= GetDataFolder(1) + PossiblyQuoteName(outputName)

	// protect against overwriting important waves in the WM_FilterDialog data folder
	if( CmpStr(outputWavePath,"root:Packages:WM_FilterDialog:magnitude") == 0 )
		return ""	// cannot overwrite this wave
	endif
	
	if( CmpStr(outputWavePath,"root:Packages:WM_FilterDialog:phase") == 0 )
		return ""	// cannot overwrite this wave
	endif
	
	if( CmpStr(outputWavePath,"root:Packages:WM_FilterDialog:coefs") == 0 )
		return ""	// cannot overwrite this wave
	endif
	
	// protect against nothing for the output to be duplicated from.
	String inputWavePath= FilterInputWavePath()
	Wave/Z filterInputWave= $inputWavePath
	if( !WaveExists(filterInputWave) )
		return ""	// no input selected
	endif

	// protect against input == output
	if( CmpStr(inputWavePath,outputWavePath) == 0 )
		return ""	// cannot overwrite self
	endif
	
	return outputWavePath	// the wave may very well NOT exist, even if the result is a path to a wave that COULD exist.
End

static Function ChangeFIRIIRTab(tab)
	Variable tab

	// Show/Hide the FIR or IIR controls
	ShowOrHideControlList(ksPanelName, ksFIRControls, tab==firTabNum)
	ShowOrHideControlList(ksPanelName, ksIIRControls, tab==iirTabNum)
	ShowOrHideControlList(ksPanelName, ksCreateCoefsControls, tab==firTabNum || tab==iirTabNum)
	ShowOrHideControlList(ksPanelName, ksSelectCoefsControls, tab==coefsTabNum)

	String title=ksTitleDesignUsingFrequency	// "Design using this Sampling Frequency (Hz)"
	if( tab==coefsTabNum )
		title= ksTitleResponseUsingFrequency	// "Show Response using this Sampling Frequency (Hz)"
	endif
	ModifyControl/Z fs, win=$ksPanelName, title=title

	Variable/G root:Packages:WM_FilterDialog:firIIRTab= tab

	UpdateForIIRCoefsFormat()

	PossiblyShowHideApplyFilterControls()
	UpdateResponse(0)
End	

static Function FIRIIRTabProc(tca) : TabControl
	STRUCT WMTabControlAction &tca

	switch( tca.eventCode )
		case 2: // mouse up
			ChangeFIRIIRTab(tca.tab)
			break
	endswitch

	return 0
End

Static Function ShowOrHideControlList(win, controls, show)
	String win
	String controls	// semicolon-separated controls
	Variable show
		
	// Use the Asylum Research trick:
	// disable= 0 = showing and active
	// disable= 2 = showing and disabled

	// disable= 1 = hidden and (latent) active
	// disable= 3 = hidden and (latent) disabled
	Variable i, n= ItemsInList(controls)
	for(i=0; i<n; i+=1 )
		String control= StringFromList(i,controls)
		ControlInfo/W=$win $control
		
		if( show )
			switch( V_disable )
				case 0:
				case 2:
					break
				case 1:
					V_disable = 0
					break
				case 3:
					V_disable = 2	// showing and disabled
					break
			endswitch
		else
			switch( V_disable )
				case 0:
					V_disable = 1
					break
				case 2:
					V_disable = 3	// hidden and latent disabled
					break
				case 1:
				case 3:
					break
			endswitch
		endif
		ModifyControl/Z $control win=$win, disable= V_disable
	endfor
End

// a panel-coordinate replacement for GetWindow wsizeDC.
Static Function PanelCoordEdges(win, vleft, vtop, vright, vbottom)
	String win	// can be "Panel0#P1", for example
	Variable &vleft, &vtop, &vright, &vbottom	// outputs, host window's left,top is 0,0

	vleft= NumberByKey("POSITION",GuideInfo(win,"FL"))
	vtop= NumberByKey("POSITION",GuideInfo(win,"FT"))
	vright= NumberByKey("POSITION",GuideInfo(win,"FR"))
	vbottom= NumberByKey("POSITION",GuideInfo(win,"FB"))
End

// Figures out if we need the FIR or IIR end effect controls.
Function WantFIREndEffects()

	Variable wantFIR = DoingFIR()
	if( DoingUserCoefs() )
		String pathToSelectedCoefs= SelectedCoefsWavePath()
		WAVE/Z coefs=$pathToSelectedCoefs
		Variable kindOfCoefs= CoefsWaveKind(coefs)
		wantFIR = kindOfCoefs == kCoefsFIR
	endif
	return wantFIR
End

Function PossiblyShowHideApplyFilterControls()
	ControlInfo/W=$ksResponsePanelName responseTab	// TabControl
	Variable tab= V_value
	if( tab == 1 )
		ShowHideApplyFilterControls()
	endif
End

// call ONLY when the Apply Filter tab is active.
Function ShowHideApplyFilterControls()

	String pwin= ksResponsePanelName
	String fir_endEffectControls= "endEffect;fillValue;endFillCheck;endFillValue;"
	String iir_endEffectControls= "iir_endFillCheck;iir_endFillValue;"
	Variable wantFIR = WantFIREndEffects()
	ModifyControlList/Z fir_endEffectControls win=$pwin, disable= wantFIR ? 0 : 1
	ModifyControlList/Z iir_endEffectControls win=$pwin, disable= wantFIR ? 1 : 0

	if( wantFIR ) 
		// If the End Effect is NOT Fill Value,
		// the fillValue, endFillCheck, and endFillValue controls are hidden
		ControlInfo/W=$pwin endEffect // value=#"\"Bounce;Wrap;Fill Value;Repeat;\""
		Variable wantFillValueControls= V_Value == 3 // "Fill Value"
		ModifyControlList/Z "fillValue;endFillCheck;endFillValue;" win=$pwin, disable= wantFillValueControls ? 0 : 1
		
		// If we want the fill value controls, perhaps the endFill value need not be shown
		if( wantFillValueControls )
			ControlInfo/W=$pwin endFillCheck
			ModifyControl/Z endFillValue win=$pwin, disable= V_Value ? 0 : 1
	
			String title= SelectString(V_Value, ksEndFillValueTitleLong, ksEndFillValueTitleShort)
			ModifyControl/Z endFillCheck win=$pwin, title=title
			
			title= SelectString(V_Value, ksFillValueTitle, ksStartFillValueTitle)
			ModifyControl/Z fillValue win=$pwin, title=title
		endif
	endif
	
	RepositionResponseControls()
End

// mostly this repositions ApplyFilter controls, since the Response controls don't need to move.
Function RepositionResponseControls()

	String pwin= ksResponsePanelName
	Variable vleft, vtop, vright, vbottom
	PanelCoordEdges(pwin, vleft, vtop, vright, vbottom)

	Variable panelHeight= vbottom-vtop // in panel units
	// Resize tab
	ControlInfo/W=$pwin responseTab	// Sets V_left, V_top, V_Width, V_Height in panel units
	Variable roomBelow= 1
	Variable controlHeight= max(3,(panelHeight - V_top) - roomBelow)
	ModifyControl/Z responseTab, win=$pwin, pos={V_left, V_top}, size={V_Width, controlHeight}

	Variable margin= 5	// space between controls
	roomBelow +=  V_top + margin
	
	// Offset Buttons, working from bottom to top
	ControlInfo/W=$pwin updateNow
	Variable controlTop= (panelHeight - V_Height) - roomBelow
	ModifyControl/Z updateNow, win=$pwin, pos={V_left, controlTop}, size={V_Width, V_Height}
	roomBelow += V_Height+margin

	ControlInfo/W=$pwin autoUpdateFilteredOutput
	controlTop= (panelHeight - V_Height) - roomBelow
	ModifyControl/Z autoUpdateFilteredOutput, win=$pwin, pos={V_left, controlTop}, size={V_Width, V_Height}
	roomBelow += V_Height+margin

	ControlInfo/W=$pwin filteredOutputName
	controlTop= (panelHeight - V_Height) - roomBelow
	ModifyControl/Z filteredOutputName, win=$pwin, pos={V_left, controlTop}, size={V_Width, V_Height}
	roomBelow += V_Height+margin
	
	// End Effects
	Variable wantFIR = WantFIREndEffects()
	if( wantFIR )
		// Here's a little wrinkle: if the End Effect is NOT Fill Value,
		// the fillValue, endFillCheck, and endFillValue controls are hidden
		// and thus they do not need any screen real estate.
		ControlInfo/W=$pwin endEffect // value=#"\"Bounce;Wrap;Fill Value;Repeat;\""
		Variable endEffect= V_Value
		if( endEffect == 3 )
			ControlInfo/W=$pwin endFillCheck
			controlTop= (panelHeight - V_Height) - roomBelow
			ModifyControl/Z endFillCheck, win=$pwin, pos={V_left, controlTop}, size={V_Width, V_Height}
			roomBelow += V_Height+margin
	
			// endFillValue is at the same vertical position as endFillCheck
			ControlInfo/W=$pwin endFillValue
			ModifyControl/Z endFillValue, win=$pwin, pos={V_left, controlTop}, size={V_Width, V_Height}
	
			ControlInfo/W=$pwin fillValue
			controlTop= (panelHeight - V_Height) - roomBelow
			ModifyControl/Z fillValue, win=$pwin, pos={V_left, controlTop}, size={V_Width, V_Height}
			roomBelow += V_Height+margin
		endif
	
		ControlInfo/W=$pwin endEffect
		controlTop= (panelHeight - V_Height) - roomBelow
		ModifyControl/Z endEffect, win=$pwin, pos={V_left, controlTop}, size={V_Width, V_Height}
		roomBelow += V_Height+margin
	else
		// IIR
		ControlInfo/W=$pwin iir_endFillCheck
		controlTop= (panelHeight - V_Height) - roomBelow
		ModifyControl/Z iir_endFillCheck, win=$pwin, pos={V_left, controlTop}, size={V_Width, V_Height}
		Variable v= V_Height

		// iir_endFillValue is at the same vertical position as iir_endFillCheck, offset down by 2
		ControlInfo/W=$pwin iir_endFillValue
		ModifyControl/Z iir_endFillValue, win=$pwin, pos={V_left, controlTop+2}, size={V_Width, V_Height}
		roomBelow += v+margin
	endif

	// Use the height remaining at the top for the listbox of waves
	ControlInfo/W=$pwin filterThisWave
	controlHeight= max(3,(panelHeight - V_top) - roomBelow)
	ModifyControl/Z filterThisWave, win=$pwin, pos={V_left, V_top}, size={V_Width, controlHeight}
End

Function RepositionCommandControls()

	String pwin= ksCommandPanelName
	Variable vleft, vtop, vright, vbottom
	PanelCoordEdges(pwin, vleft, vtop, vright, vbottom)
	Variable panelWidth= vright-vleft

	ControlInfo/W=$pwin cancel	// Sets V_left, V_top, V_Width, V_Height in panel coordinates
	Variable left= (panelWidth - 20) - V_Width
	ModifyControl/Z cancel, win=$pwin, pos={left, V_top}, size={V_Width, V_Height}

	ControlInfo/W=$pwin help
	left -= V_Width + 100
	ModifyControl/Z help, win=$pwin, pos={left, V_top}, size={V_Width, V_Height}

	Variable right= panelWidth - 6

	ControlInfo/W=$pwin commandGroup
	Variable width = right - V_left
	ModifyControl/Z commandGroup, win=$pwin, pos={V_left, V_top}, size={width, V_Height}
	
	ControlInfo/W=$pwin command
	width = (right - V_left) - 4
	ModifyControl/Z command, win=$pwin, pos={V_left, V_top}, size={width, V_Height}
End


static Function IIRLowPassCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			UpdateResponse(0)
			break
	endswitch

	return 0
End

static Function IIRHighPassCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			UpdateResponse(0)
			break
	endswitch

	return 0
End

static Function IIRNotchPassCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			UpdateResponse(0)
			break
	endswitch

	return 0
End

static Function IIRCoefsFormatPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			String/G root:Packages:WM_FilterDialog:iir_coefsFormat= pa.popStr
			UpdateForIIRCoefsFormat()
			PossiblyShowHideApplyFilterControls()
			UpdateResponse(0)
			break
	endswitch

	return 0
End

static Function FilterNameSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			String str=GenerateCommand()
			break
	endswitch

	return 0
End

static Function FsSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			UpdateFs(dval)
			break
	endswitch

	return 0
End

static Function IIRfLowSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			NVAR fs= root:Packages:WM_FilterDialog:fs
			NVAR iir_fLow= root:Packages:WM_FilterDialog:iir_fLow
			iir_fLow= dval / fs
			UpdateResponse(0)
			break
	endswitch

	return 0
End

static Function IIRfHighSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			NVAR fs= root:Packages:WM_FilterDialog:fs
			NVAR iir_fHigh= root:Packages:WM_FilterDialog:iir_fHigh
			iir_fHigh= dval / fs
			UpdateResponse(0)
			break
	endswitch

	return 0
End

static Function IIRorderSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			UpdateResponse(0)
			break
	endswitch

	return 0
End

static Function IIRNotchSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			NVAR fs= root:Packages:WM_FilterDialog:fs
			NVAR iir_fNotch_fs= root:Packages:WM_FilterDialog:iir_fNotch_fs
			NVAR iir_fNotch= root:Packages:WM_FilterDialog:iir_fNotch
			iir_fNotch= iir_fNotch_fs / fs
			
			NVAR iir_notchWidth_fs= root:Packages:WM_FilterDialog:iir_notchWidth_fs
			NVAR iir_notchWidth= root:Packages:WM_FilterDialog:iir_notchWidth
			iir_notchWidth= iir_notchWidth_fs / fs
			UpdateResponse(0)
			break
	endswitch

	return 0
End


static Function FIRLowSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			NVAR fs= root:Packages:WM_FilterDialog:fs
			NVAR fir_low_f1_fs= root:Packages:WM_FilterDialog:fir_low_f1_fs
			NVAR fir_low_f1= root:Packages:WM_FilterDialog:fir_low_f1
			fir_low_f1= fir_low_f1_fs / fs
			
			NVAR fir_low_f2_fs= root:Packages:WM_FilterDialog:fir_low_f2_fs
			NVAR fir_low_f2= root:Packages:WM_FilterDialog:fir_low_f2
			fir_low_f2= fir_low_f2_fs / fs
			UpdateResponse(0)
			break
	endswitch

	return 0
End

static Function FIRHighSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			NVAR fs= root:Packages:WM_FilterDialog:fs
			NVAR fir_high_f1_fs= root:Packages:WM_FilterDialog:fir_high_f1_fs
			NVAR fir_high_f1= root:Packages:WM_FilterDialog:fir_high_f1
			fir_high_f1= fir_high_f1_fs / fs
			
			NVAR fir_high_f2_fs= root:Packages:WM_FilterDialog:fir_high_f2_fs
			NVAR fir_high_f2= root:Packages:WM_FilterDialog:fir_high_f2
			fir_high_f2= fir_high_f2_fs / fs
			UpdateResponse(0)
			break
	endswitch

	return 0
End

static Function FIRLowPassCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			UpdateResponse(0)
			break
	endswitch

	return 0
End

static Function FIRHighPassCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			UpdateResponse(0)
			break
	endswitch

	return 0
End

static Function FIRNotchCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			UpdateResponse(0)
			break
	endswitch

	return 0
End

static Function FIRNotchSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			NVAR fs= root:Packages:WM_FilterDialog:fs
			NVAR fir_notch_fc_fs= root:Packages:WM_FilterDialog:fir_notch_fc_fs
			NVAR fir_notch_fc= root:Packages:WM_FilterDialog:fir_notch_fc
			fir_notch_fc= fir_notch_fc_fs / fs
			
			NVAR fir_notch_fw_fs= root:Packages:WM_FilterDialog:fir_notch_fw_fs
			NVAR fir_notch_fw= root:Packages:WM_FilterDialog:fir_notch_fw
			fir_notch_fw= fir_notch_fw_fs / fs
			UpdateResponse(0)
			break
	endswitch

	return 0
End

// Note: both frequency-scaled and normalized values are required
// in order for changing the sampling frequency to work.
static Function InitGlobals()

	String dfSave= GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O/S root:Packages:WM_FilterDialog
	
	Variable fSamp= NumVarOrDefault("fs", 1)
	Variable/G fs= fSamp
	
	String str= StrVarOrDefault("coefsOutputName", "coefs")
	String/G coefsOutputName= str
	
	Variable val= NumVarOrDefault("createFilter",1)
	Variable/G createFilter=val
	
	// Apply Filter globals
	String/G pathToFilteredInput	// default is ""

	Variable/G dimension	// default 0 - NOT IMPLEMENTED

	val= NumVarOrDefault("endEffect",0)	// default is 0 (Bounce)
	Variable/G endEffect=val

	val= NumVarOrDefault("fillValue",0)	// default is 0
	Variable/G fillValue=val

	val= NumVarOrDefault("endFillCheck",0)	// default is 0 (unchecked)
	Variable/G endFillCheck=val

	val= NumVarOrDefault("endFillValue",0)	// default is 0
	Variable/G endFillValue=val

	val= NumVarOrDefault("iir_endFillCheck",0)	// default is 0 (unchecked)
	Variable/G iir_endFillCheck=val

	val= NumVarOrDefault("iir_endFillValue",0)	// default is 0
	Variable/G iir_endFillValue=val

	str= StrVarOrDefault("filteredOutputName", "filtered")
	String/G filteredOutputName= str
	
	Variable/G autoUpdateFilteredOutput	// default is 0
	
	// Command globals
	String/G command	// "" always regenerated
	
	// FIR/IIR Tab globals
	Variable/G firIIRTab	// default is 0 (FIR)
	
	// FIR globals
	str=StrVarOrDefault("fir_windowKind", "Hanning")
	String/G fir_windowKind= str

	val= NumVarOrDefault("fir_lowpass_check",1)
	Variable/G fir_lowpass_check= val
	
	val= NumVarOrDefault("fir_low_f1", 0.2)
	Variable/G fir_low_f1= val
	Variable/G fir_low_f1_fs= val*fs

	val= NumVarOrDefault("fir_low_f2", 0.3)
	Variable/G fir_low_f2= val
	Variable/G fir_low_f2_fs= val*fs
	
	val= NumVarOrDefault("fir_low_n", 101)
	Variable/G fir_low_n= val

	Variable/G fir_highpass_check	// default is 0
	val= NumVarOrDefault("fir_high_f1", 0.2)
	Variable/G fir_high_f1= val
	Variable/G fir_high_f1_fs= val*fs
	
	val= NumVarOrDefault("fir_high_f2", 0.3)
	Variable/G fir_high_f2= val
	Variable/G fir_high_f2_fs= val*fs
	
	val= NumVarOrDefault("fir_high_n", 101)
	Variable/G fir_high_n= val

	Variable/G fir_notch_check	// default is 0
	
	val= NumVarOrDefault("fir_notch_fc", 0.4)
	Variable/G fir_notch_fc= val
	Variable/G fir_notch_fc_fs= val*fs
	
	val= NumVarOrDefault("fir_notch_fw", 0.05)
	Variable/G fir_notch_fw= val
	Variable/G fir_notch_fw_fs= val*fs

	val= NumVarOrDefault("fir_notch_nmult", 2)
	Variable/G fir_notch_nmult= val
	
	val= NumVarOrDefault("fir_notch_eps", 2^-40)
	Variable/G fir_notch_eps= val
	
	// IIR Globals
	
	str=StrVarOrDefault("iir_coefsFormat", "Cascade (Direct Form II)")
	String/G iir_coefsFormat= str
	
	val= NumVarOrDefault("iir_lowpass_check", 1)
	Variable/G iir_lowpass_check= val
	
	val= NumVarOrDefault("iir_fLow", 0.25)
	Variable/G iir_fLow= val
	Variable/G iir_fLow_fs= val*fs

	Variable/G iir_highpass_check	// default is 0
	val= NumVarOrDefault("iir_fHigh", 0.25)
	Variable/G iir_fHigh= val
	Variable/G iir_fHigh_fs= val*fs

	val= NumVarOrDefault("iir_order", 2)
	Variable/G iir_order= val

	Variable/G iir_notch_check	// default is 0
	
	val= NumVarOrDefault("iir_fNotch", 0.4)
	Variable/G iir_fNotch= val
	Variable/G iir_fNotch_fs= val*fs
	
	val= NumVarOrDefault("iir_notchWidth", 0.05)
	Variable/G iir_notchWidth= val
	Variable/G iir_notchWidth_fs= val*fs
	
	// Select Filter coefs globals
	String/G pathToSelectedCoefs	// default is ""
	String/G descriptionOfSelectedCoefs
	
	// Response globals
	
	val= NumVarOrDefault("magnitude_check", 1)
	Variable/G magnitude_check= val
	val= NumVarOrDefault("magnitude_popNum", 1) // default is dB
	Variable/G magnitude_popNum= val

	val= NumVarOrDefault("phase_check", 1)
	Variable/G phase_check= val
	val= NumVarOrDefault("phase_unwrap", 1)
	Variable/G phase_unwrap= val
	val= NumVarOrDefault("phase_degrees", 1)
	Variable/G phase_degrees= val

	SetDataFolder dfSave

End

static Function/S FIRWindowsList()
	return ksFIRWindowsList
End

static Function/S IIRFormatList()
	return ksIIRFormatList
End

Function WMFilterDialog()

	InitGlobals()

	String dfSave= GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O/S root:Packages:WM_FilterDialog
	
	NVAR fs, dimension, createFilter
	SVAR coefsOutputName, filteredOutputName, pathToFilteredInput, command
	NVAR endEffect, fillValue, endFillCheck, endFillValue

	NVAR firIIRTab
	
	NVAR fir_lowpass_check,fir_low_f1_fs, fir_low_f2_fs, fir_low_n
	NVAR fir_highpass_check, fir_high_f1_fs, fir_high_f2_fs, fir_high_n
	NVAR fir_notch_check, fir_notch_fc_fs, fir_notch_fw_fs, fir_notch_nmult, fir_notch_eps
	
	NVAR iir_lowpass_check, iir_fLow_fs, iir_order
	NVAR iir_highpass_check, iir_fHigh_fs
	NVAR iir_notch_check, iir_fNotch_fs, iir_notchWidth_fs
	
	SVAR descriptionOfSelectedCoefs
	
	NVAR magnitude_check, phase_check, phase_unwrap, phase_degrees, magnitude_popNum

	DoWindow/F $ksPanelName
	if( V_Flag == 0 )
		Variable vLeft=39, vTop=60, vRight=721, vBottom= vTop + kPanelHeight
		WC_WindowCoordinatesGetNums(ksPanelName, vLeft, vTop, vRight, vBottom)
		Variable height = vBottom - vTop
		if( height < kPanelHeight )	// old panel size might not be tall enough for new controls
			vBottom = vTop + kPanelHeight
		endif
		
		// /K=1 for no dialog if killed
		String cmd
		sprintf cmd, "NewPanel/K=1/N=%s/W=(%%s) as \"%s\"", ksPanelName, ksFilterDialogTitle	// ksFilterDialogTitle=  "Filter Design and Application"
		cmd= WC_WindowCoordinatesSprintf(ksPanelName,cmd,vLeft, vTop, vRight, vBottom,1)	// pixels
		Execute cmd
		
		DefaultGuiFont/W=$ksPanelName popup={"_IgorSmall",0,0}, button={"_IgorMedium",0,0}
		ModifyPanel/W=$ksPanelName noEdit=kNoEdit

		CheckBox createFilter,pos={205,153},proc=FilterDialog#CreateCoefsCheckProc,title=ksCreateFilterTitle	// "Create Coefficients:"
		CheckBox createFilter,variable= root:Packages:WM_FilterDialog:createFilter

		SetVariable coefsOutputName,pos={303,153},size={118,15},proc=FilterDialog#CoefsOutputNameSetVarProc,title=" "
		SetVariable coefsOutputName,value= root:Packages:WM_FilterDialog:coefsOutputName,bodyWidth= 118

		SetVariable fs,pos={273,189},size={342,15},proc=FilterDialog#FsSetVarProc,title=ksFsTitle	// "Design using this Sampling Frequency (Hz)"
		SetVariable fs,limits={0,inf,0},value= root:Packages:WM_FilterDialog:fs,bodyWidth= 110
		
		PopupMenu sort,pos={102,188},size={62,17},title=ksSortByTitle	// "Sort By"

		Variable/G fromTarget
		CheckBox fromTarget,pos={14,188},size={72,14},proc=FilterDialog#FilterDesignFromTargetCheckProc,title=ksFromTargetTitle	// "From target"
		CheckBox fromTarget,variable=root:Packages:WM_FilterDialog:fromTarget
		
		TabControl firIIRTab,pos={6,11},size={662,169},proc=FilterDialog#FIRIIRTabProc
		TabControl firIIRTab,tabLabel(0)=ksFIR_IIRTab0Title	// "Design FIR Filter"
		TabControl firIIRTab,tabLabel(1)=ksFIR_IIRTab1Title	// "Design IIR Filter"
		TabControl firIIRTab,tabLabel(2)=ksFIR_IIRTab2Title	// "Select Filter Coefficients Wave"
		TabControl firIIRTab,value= firIIRTab

		// FIR Tab
		Variable checky= 40
		GroupBox fir_lowpass_group,pos={17,37},size={200,104},title=ksFirLowpassGroupTitle	// "     Low Pass"
		CheckBox fir_lowpass,pos={30,checky},size={16,14},proc=FilterDialog#FIRLowPassCheckProc,title=""
		CheckBox fir_lowpass,variable= root:Packages:WM_FilterDialog:fir_lowpass_check
		SetVariable fir_low_f1,pos={51,60},size={159,15},proc=FilterDialog#FIRLowSetVarProc,title=ksFirLowpassF1Title	// "End of Pass Band"
		SetVariable fir_low_f1,limits={0,inf,0},value= root:Packages:WM_FilterDialog:fir_low_f1_fs,bodyWidth= 80
		SetVariable fir_low_f2,pos={34,88},size={176,15},proc=FilterDialog#FIRLowSetVarProc,title=ksFirLowpassF2Title	// "Start of Reject Band"
		SetVariable fir_low_f2,limits={0,inf,0},value= root:Packages:WM_FilterDialog:fir_low_f2_fs,bodyWidth= 80
		SetVariable fir_low_n,pos={23,116},size={187,15},proc=FilterDialog#FIRLowSetVarProc,title=ksFirLowpassNTitle	// "Number of Coefficients"
		SetVariable fir_low_n,limits={3,32767,2},value= root:Packages:WM_FilterDialog:fir_low_n,bodyWidth= 50
	
		GroupBox fir_highpass_group,pos={221,37},size={201,104},title=ksFirHighpassGroupTitle	// "     High Pass"
		CheckBox fir_highPass,pos={235,checky},size={16,14},proc=FilterDialog#FIRHighPassCheckProc,title=""
		CheckBox fir_highPass,variable= root:Packages:WM_FilterDialog:fir_highpass_check
		SetVariable fir_high_f1,pos={250,60},size={167,15},proc=FilterDialog#FIRHighSetVarProc,title=ksFirHighpassF1Title	// "End of Reject Band"
		SetVariable fir_high_f1,limits={0,inf,0},value= root:Packages:WM_FilterDialog:fir_high_f1_fs,bodyWidth= 80
		SetVariable fir_high_f2,pos={249,88},size={168,15},proc=FilterDialog#FIRHighSetVarProc,title=ksFirHighpassF2Title	// "Start of Pass Band"
		SetVariable fir_high_f2,limits={0,inf,0},value= root:Packages:WM_FilterDialog:fir_high_f2_fs,bodyWidth= 80
		SetVariable fir_high_n,pos={230,116},size={187,15},proc=FilterDialog#FIRLowSetVarProc,title=ksFirHighpassNTitle	// "Number of Coefficients"
		SetVariable fir_high_n,limits={3,32767,2},value= root:Packages:WM_FilterDialog:fir_high_n,bodyWidth= 50

		PopupMenu fir_windowKind,pos={17,150},size={118,20},title=ksFirWindowKindTitle	// "Window"
		SVAR fir_windowKind
		Variable mode= max(1,1 + WhichListItem(fir_windowKind, ksFIRWindowsList))
//		PopupMenu fir_windowKind,mode=mode,popvalue=fir_windowKind,value=#"FilterDialog#FIRWindowsList()"
		String popFunc= GetIndependentModuleName()+"#FilterDialog#FIRWindowsList()"
		PopupMenu fir_windowKind,mode=mode,popvalue=fir_windowKind,value=#popFunc	// requires Igor 6 12/6/06 to work
		PopupMenu fir_windowKind proc=FilterDialog#WindowPopMenuProc

		GroupBox fir_notch_group,pos={426,37},size={235,132},title=ksFirNotchGroupTitle	// "     Notch"
		CheckBox fir_notch,pos={441,checky},size={16,14},proc=FilterDialog#FIRNotchCheckProc,title=""
		CheckBox fir_notch,variable= root:Packages:WM_FilterDialog:fir_notch_check
		SetVariable fir_notch_fc,pos={496,60},size={158,15},proc=FilterDialog#FIRNotchSetVarProc,title=ksFirNotchFcTitle	// "Notch Frequency"
		SetVariable fir_notch_fc,limits={0,inf,0},value= root:Packages:WM_FilterDialog:fir_notch_fc_fs,bodyWidth= 80
		SetVariable fir_notch_fw,pos={517,88},size={137,15},proc=FilterDialog#FIRNotchSetVarProc,title=ksFirNotchFwTitle	// "Notch Width"
		SetVariable fir_notch_fw,limits={0,inf,0},value= root:Packages:WM_FilterDialog:fir_notch_fw_fs,bodyWidth= 80
		SetVariable fir_notch_nmult,pos={441,116},size={213,15},proc=FilterDialog#FIRNotchSetVarProc,title=ksFirNotchNMultTitle	// "Improve Notch Accuracy by:"
		SetVariable fir_notch_nmult,limits={0,16,1},value= root:Packages:WM_FilterDialog:fir_notch_nmult,bodyWidth= 50
		SetVariable fir_notch_eps,pos={433,144},size={221,15},proc=FilterDialog#FIRNotchSetVarProc,title=ksFirNotchEPSTitle	// "Omit Coefs smaller than"
		SetVariable fir_notch_eps,limits={0,inf,0},value= root:Packages:WM_FilterDialog:fir_notch_eps,bodyWidth= 80

		// IIR Tab
		PopupMenu iir_coefsFormat,pos={93,46},size={261,17},disable=1,proc=FilterDialog#IIRCoefsFormatPopMenuProc,title=ksIIRCoefsFormatTitle	// "Filter Coefficients Format:"
		SVAR iir_coefsFormat
		mode= max(1,1 + WhichListItem(iir_coefsFormat, ksIIRFormatList))
//		PopupMenu iir_coefsFormat,mode=mode,popvalue=iir_coefsFormat,value=#"FilterDialog#IIRFormatList()"
		popFunc= GetIndependentModuleName()+"#FilterDialog#IIRFormatList()"
		PopupMenu iir_coefsFormat,mode=mode,popvalue=iir_coefsFormat,value=#popFunc	// requires Igor 6 12/6/06 to work

		Button createCustomZerosPolesCoefs,pos={426,45},size={235,18},proc=FilterDialog#DesignZeroPolesButtonProc,title=ksIIRCreatePZButtonTitle	// "Create Filter using Poles and Zeros Editor..."
		Button createCustomZerosPolesCoefs,fSize=10, disable=3

		GroupBox iir_lowpass_group,pos={17,82},size={200,56},disable=1,title=ksIIRLowpassGroupTitle	// "     Low Pass"
		CheckBox iir_lowpass,pos={31,81},size={16,14},disable=1,proc=FilterDialog#IIRLowPassCheckProc,title=""
		CheckBox iir_lowpass,variable= root:Packages:WM_FilterDialog:iir_lowpass_check
		SetVariable iir_fLow,pos={43,106},size={161,15},disable=1,proc=FilterDialog#IIRfLowSetVarProc,title=ksIIRLowpassFcTitle	// "Cutoff Frequency"
		SetVariable iir_fLow,limits={0,inf,0},value= root:Packages:WM_FilterDialog:iir_fLow_fs,bodyWidth= 80
	
		GroupBox iir_highpass_group,pos={221,82},size={201,56},disable=1,title=ksIIRHighpassGroupTitle	// "     High Pass"
		CheckBox iir_highPass,pos={235,81},size={16,14},disable=1,proc=FilterDialog#IIRHighPassCheckProc,title=""
		CheckBox iir_highPass,variable= root:Packages:WM_FilterDialog:iir_highpass_check
		SetVariable iir_fHigh,pos={239,106},size={161,15},disable=1,proc=FilterDialog#IIRfHighSetVarProc,title=ksIIRHighpassFcTitle	// "Cutoff Frequency"
		SetVariable iir_fHigh,limits={0,inf,0},value= root:Packages:WM_FilterDialog:iir_fHigh_fs,bodyWidth= 80
	
		SetVariable iir_order,pos={20,153},size={110,15},disable=1,proc=FilterDialog#IIRorderSetVarProc,title=ksIIROrderTitle	// "Order"
		SetVariable iir_order,limits={1,100,1},value= root:Packages:WM_FilterDialog:iir_order,bodyWidth= 80
	
		GroupBox iir_notch_group,pos={427,82},size={235,84},disable=1,title=ksIIRNotchGroupTitle	// "     Notch"
		CheckBox iir_notch,pos={441,81},size={16,14},disable=1,proc=FilterDialog#IIRNotchPassCheckProc,title=""
		CheckBox iir_notch,variable= root:Packages:WM_FilterDialog:iir_notch_check
		SetVariable iir_fNotch,pos={468,106},size={158,15},disable=1,proc=FilterDialog#IIRNotchSetVarProc,title=ksIIRNotchFcTitle	// "Notch Frequency"
		SetVariable iir_fNotch,limits={0,inf,0},value= root:Packages:WM_FilterDialog:iir_fNotch_fs,bodyWidth= 80
		SetVariable iir_notchWidth,pos={489,136},size={137,15},disable=1,proc=FilterDialog#IIRNotchSetVarProc,title=ksIIRNotchFwTitle	// "Notch Width"
		SetVariable iir_notchWidth,limits={-inf,inf,0},value= root:Packages:WM_FilterDialog:iir_notchWidth_fs,bodyWidth= 80	// allows negative notchQ to get old design.

		// Select Filter Coefs Tab
		Button editZerosPoles,pos={257,113},size={140,20},proc=FilterDialog#EditZerosPolesButtonProc,title=ksSelectFilterEditTitle, disable=2	// "Edit Zeros and Poles", usually hidden
		ListBox coefsWavesList,pos={16,34},size={211,138}
		TitleBox coefsDetails,pos={258,67},size={1,1},disable=1,frame=0
		TitleBox coefsDetails,variable= root:Packages:WM_FilterDialog:descriptionOfSelectedCoefs
		
		// Set up the Select Coefs wave listbox
		String options= "TEXT:0"	// See WaveList options documentation
		MakeListIntoWaveSelector(ksPanelName, "coefsWavesList", selectionMode=WMWS_SelectionSingle, listoptions=options, nameFilterProc="FilterDialog#ApproveCoefsWave")
		WS_SetNotificationProc(ksPanelName, "coefsWavesList", "FilterDialog#SelectCoefsNotificationProc")

		MakePopupIntoWaveSelectorSort(ksPanelName, "coefsWavesList", "sort", popupcontrolwindow= ksPanelName)

		// Response/Filtered Graph
		Make/O/D/N=2 magnitude, phase
		DefineGuide GraphLeft={FL,200},GraphTop={FT,kGraphTopPos},GraphBottom={FB,kGraphBottomOffset},GraphRight={FR,-6}
		Display/W=(369,260,817,546)/FG=(GraphLeft,GraphTop,GraphRight,GraphBottom)/HOST=# magnitude
		AppendToGraph/R phase
		ModifyGraph rgb(phase)=(0,0,65535), minor(bottom)=1
		ModifyGraph manTick(right)={0,45,0,0},manMinor(right)={2,0}
		Legend/C/N=ResponseLegend/X=0.00/Y=0.00
		ModifyGraph frameStyle=1
		RenameWindow #,G0
		SetActiveSubwindow ##

		// P0 contains the response and apply filter controls
		NewPanel/W=(168,140,506,422)/FG=(FL,GraphTop,GraphLeft,GraphBottom)/HOST=# 
		ModifyPanel frameStyle=0, frameInset=0, noEdit=kNoEdit
//		TabControl responseTab,pos={2,2},size={195,585},proc=FilterDialog#ResponseTabProc
		height = 585
		height += 60 // Igor 9
		TabControl responseTab,pos={2,2},size={195,height},proc=FilterDialog#ResponseTabProc
		TabControl responseTab,tabLabel(0)=ksResponseTab0Title	// "Response"
		TabControl responseTab,tabLabel(1)=ksResponseTab1Title	// "Apply Filter"
		TabControl responseTab,value= 0	// Response
		
		// Response tab
		
		CheckBox showMagnitude,pos={21,31},size={90,14},proc=FilterDialog#ShowMagnitudeCheckProc,title=ksResponseShowMagTitle	// "Show Magnitude"
		CheckBox showMagnitude,variable= root:Packages:WM_FilterDialog:magnitude_check
		
		PopupMenu magnitudePop,pos={62,50},size={42,20},proc=FilterDialog#MagnitudePopMenuProc
		String popvalue= StringFromList(magnitude_popNum-1, ksMagnitudePopItems)	// "dB;dB min -100;dB min -50;dB min -20;Gain;Gain log10;")
		popFunc= GetIndependentModuleName()+"#FilterDialog#MagnitudePopList()"
		PopupMenu magnitudePop,mode=magnitude_popNum,popvalue=popvalue,value=#popFunc	// requires Igor 6 12/6/06 to work

		CheckBox showPhase,pos={21,75},size={71,14},proc=FilterDialog#ShowPhaseCheckProc,title=ksResponseShowPhaseTitle	// "Show Phase"
		CheckBox showPhase,variable= root:Packages:WM_FilterDialog:phase_check
	
		CheckBox phaseDegrees,pos={48,94},size={53,14},disable=2,proc=FilterDialog#RadiansDegreesCheckProc,title=ksResponsePhaseDegreesTitle	// "degrees"
		CheckBox phaseDegrees,variable= root:Packages:WM_FilterDialog:phase_degrees,mode=1
	
		CheckBox phaseRadians,pos={112,94},size={51,14},disable=2,proc=FilterDialog#RadiansDegreesCheckProc,title=ksResponsePhaseRadiansTitle	// "radians"
		CheckBox phaseRadians,value= !phase_degrees,mode=1
		
		CheckBox phaseUnwrap,pos={110,75},size={52,14},disable=2,proc=FilterDialog#UnwrapCheckProc,title=ksResponsePhaseUnwrapTitle	// "Unwrap"
		CheckBox phaseUnwrap,variable= root:Packages:WM_FilterDialog:phase_unwrap

		// Apply Filter tab	(contents initially hidden)
		TitleBox inputTitle,pos={65,25},size={62,12},frame=0,title=ksApplyFilterInputTitle	// "Input to Filter"
		ListBox filterThisWave,pos={8,41},size={183,80}

	// Igor 9: added fill Value controls
		Variable padding= 5
		Variable top = 41+80+padding
		PopupMenu endEffect,pos={14.00,top},size={123.00,16.00},title=ksEndEffectsTitle
		String list= "Bounce;Wrap;Fill Value;Repeat;"
		popvalue= StringFromList(endEffect,list)
		mode= endEffect+1	// endEffect is zero-based, the list item is one-based
		PopupMenu endEffect,mode=mode,popvalue=popvalue,value=#"\"Bounce;Wrap;Fill Value;Repeat;\""
		PopupMenu endEffect proc=FilterDialog#EndEffectPopMenuProc		

		// IIR fill value controls at same vertical position as End Effects popup
			CheckBox iir_endFillCheck,pos={11,top},size={16,16},title=" "
			CheckBox iir_endFillCheck,variable= root:Packages:WM_FilterDialog:iir_endFillCheck
			CheckBox iir_endFillCheck proc=FilterDialog#EndFillCheckProc

			SetVariable iir_endFillValue,pos={30,top},size={157,14.00}
			SetVariable iir_endFillValue,title=ksIIRFillValueTitle,limits={-inf,inf,0}
			SetVariable iir_endFillValue,variable= root:Packages:WM_FilterDialog:iir_endFillValue
			SetVariable iir_endfillValue proc=FilterDialog#FillValueSetVarProc

		top += 16+padding
		SetVariable fillValue,pos={45,top},size={143.00,14.00},bodyWidth=100
		SetVariable fillValue,title=ksFillValueTitle,limits={-inf,inf,0}
		SetVariable fillValue,variable= root:Packages:WM_FilterDialog:fillValue
		SetVariable fillValue proc=FilterDialog#FillValueSetVarProc
		
		top += 14+padding
		CheckBox endFillCheck,pos={34,top},size={49.00,16.00},title=ksEndFillValueTitleShort
		CheckBox endFillCheck,variable= root:Packages:WM_FilterDialog:endFillCheck
		CheckBox endFillCheck proc=FilterDialog#EndFillCheckProc
		
		SetVariable endFillValue,pos={88,top},size={100.00,14.00},bodyWidth=100
		SetVariable endFillValue,title=" ",limits={-inf,inf,0}
		SetVariable endFillValue,variable= root:Packages:WM_FilterDialog:endFillValue
		SetVariable endfillValue proc=FilterDialog#FillValueSetVarProc

	// output
		top += 16+padding
		SetVariable filteredOutputName,pos={11,top},size={176,15},proc=FilterDialog#FilteredOutputNameSetVarProc,title=ksApplyFilterOutputTitle	// "Output Name"
		SetVariable filteredOutputName,value= root:Packages:WM_FilterDialog:filteredOutputName

		top += 15+padding
		CheckBox autoUpdateFilteredOutput,pos={11,top},size={105,14},proc=FilterDialog#AutoUpdateFilteredOutCheckProc,title=ksApplyFilterAutoUpdateTitle	// "Auto-update Filtered Output"
		CheckBox autoUpdateFilteredOutput,variable= root:Packages:WM_FilterDialog:autoUpdateFilteredOutput

		top += 14+padding
		Button updateNow,pos={32,top},size={120,18},proc=FilterDialog#UpdateFilterOutputNowButtonProc,title=ksApplyFilterUpdateNowTitle	// "Update Output Now"
		Button updateNow,fSize=11

		RenameWindow #,P0
		SetActiveSubwindow ##
		ShowOrHideControlList(ksResponsePanelName, ksApplyFilterControls, 0)	// hide
		
		// Set up the input wave listbox
		options= "DIMS:1,TEXT:0"	// See WaveList options documentation
		MakeListIntoWaveSelector(ksResponsePanelName, "filterThisWave", selectionMode=WMWS_SelectionSingle, listoptions=options,nameFilterProc="FilterDialog#ApproveWaveToFilter")
		WS_SetNotificationProc(ksResponsePanelName, "filterThisWave", "FilterDialog#InputToFilterNotificationProc")

		MakePopupIntoWaveSelectorSort(ksResponsePanelName, "filterThisWave", "sort", popupcontrolwindow= ksPanelName)

		Variable sortKind= NumVarOrDefault("root:Packages:WM_FilterDialog:sortKind",0)
		Variable sortReverse= NumVarOrDefault("root:Packages:WM_FilterDialog:sortReverse",0)
		WS_SetGetSortOrder(ksPanelName, "sort", sortKind, sortReverse)

		// P1 contains the command controls
		NewPanel/W=(168,96,506,289)/FG=(FL,GraphBottom,FR,FB)/HOST=# 
		ModifyPanel frameStyle=0, noEdit=kNoEdit
		Button doit,pos={16,60},size={50,20},proc=FilterDialog#DoItButtonProc,title=ksCmdDoItTitle	// "Do It"
		GroupBox commandGroup,pos={7,9},size={660,41},labelBack=(65535,65535,65535)
		GroupBox commandGroup,frame=0
		TitleBox command,pos={12,11},size={180,36},variable=root:Packages:WM_FilterDialog:command
		TitleBox command,frame=0,fsize=9
		Button toCmdLine,pos={99,60},size={99,20},proc=FilterDialog#DoItButtonProc,title=ksCmdToCmdTitle	// "To Cmd Line"
		Button toClip,pos={232,60},size={60,20},proc=FilterDialog#DoItButtonProc,title=ksCmdToClipTitle		// "To Clip"
		Button cancel,pos={584,60},size={70,20},proc=FilterDialog#DoItButtonProc,title=ksCmdCancelTitle	// "Cancel"
		Button help,pos={443,60},size={50,20},proc=FilterDialog#HelpButtonProc,title=ksCmdHelpTitle		// "Help"
		RenameWindow #,P1
		SetActiveSubwindow ##
		
		RepositionResponseControls()
		RepositionCommandControls()

//		SetWindow $ksPanelName hook=FilterDialog#WMFilterDialogHook
	endif
	SetDataFolder dfSave
	ChangeFIRIIRTab(firIIRTab)	// calls UpdateResponse(0), which provokes an activate (?)
	UpdateForSelectedCoefsWave()
	SetWindow $ksPanelName hook=FilterDialog#WMFilterDialogHook
EndMacro

static Function WindowToolBarWidth(win)
	String win
	
	String code= WinRecreation(win, 0)
	Variable pos= strsearch(code, "\tShowTools\r", 0)
	return (pos >= 0) ? 28 : 0	// panel units?
End

static Function LimitWindowSize(win, minWidthPoints, minHeightPoints)
	String win
	Variable minWidthPoints, minHeightPoints

	Variable resizePending = 0

#if IgorVersion() >= 7
	SetWindow $win sizeLimit={minWidthPoints, minHeightPoints, Inf, Inf}
#else
	
	GetWindow $win wsize	// V_left, V_top, V_right, V_bottom in points
	Variable width= V_right-V_left
	Variable height= V_bottom-V_top
	Variable resizeNeeded= (width < minWidthPoints-1) || (height < minHeightPoints-1)
	if( resizeNeeded )
		String setPanelSizeScheduledStr= GetUserData(ksPanelName,"","setPanelSizeScheduled")	// "" if never set (means "no")
		if( strlen(setPanelSizeScheduledStr) == 0 )
			SetWindow $ksPanelName, userdata(setPanelSizeScheduled)= "yes"
			V_right = max(V_right, V_left + minWidthPoints)
			V_bottom= max(V_bottom, V_top +minHeightPoints )
			//MoveWindow/W=$ksPanelName V_left, V_top, V_right, V_bottom	// Igor's recursion block omits the needed resize event unless we defer
			String cmd
			String functionName=GetIndependentModulename()+"#ResetPanelSize"
			sprintf cmd "%s(%g, %g, %g, %g)", functionName, V_left, V_top, V_right, V_bottom
			Execute/P/Q/Z cmd
			resizePending = 1
		endif
	endif
#endif
	
	return resizePending
End

static Function WMFilterDialogHook(infoStr)
	String infoStr

	Variable status=0
	String event= StringByKey("EVENT",infoStr)
	strswitch(event)
		case "activate":
			UpdateResponse(0)	// the coefficients wave or the input to the filter may have changed
			UpdateForSelectedCoefsWave()// also need to update the description of the selected coefs wave
			// FALL THROUGH
		case "deactivate":
			SetWindow $ksPanelName, userdata(setPanelSizeScheduled)= ""	// avoid locking out calls to SetPanelSize().
			break
		case "resize":	// resized, actually
			if( !WindowIsMinimized(ksPanelName) )
				// limit the width to + 4 beyond the firIIRTab control's right side
				ControlInfo/W=$ksPanelName firIIRTab	// V_top, V_left, V_Width, V_Height in panel units
				Variable minWidth= V_left + V_Width + 4 + WindowToolBarWidth(ksPanelName)
				Variable minWidthPoints= PanelCoordsToPoints(ksPanelName, minWidth)
				// limit the panel height so that the Input To Filter list doesn't have a red X in it
				Variable minHeight= kGraphTopPos - kGraphBottomOffset
				Variable minHeightPoints= PanelCoordsToPoints(ksPanelName, minHeight) + kMinResponseHeightPoints 
				
				Variable resizePending= LimitWindowSize(ksPanelName, minWidthPoints, minHeightPoints)
				if( !resizePending )
					RepositionResponseControls()
					RepositionCommandControls()
				endif
			endif
			break
		case "kill":
			// save sort order
			Variable sk= -1 //get
			Variable sr= -1
			WS_SetGetSortOrder(ksPanelName, "sort", sk, sr)
			Variable/G root:Packages:WM_FilterDialog:sortKind= sk
			Variable/G root:Packages:WM_FilterDialog:sortReverse= sr 

			KillWaves/Z root:Packages:WM_FilterDialog:filtered		// likely to be a big wave worth killing
//			Execute/P/Q/Z "DELETEINCLUDE <FilterDialog>"	// delete self: Nope: delete confuses independent module menu compilation
//			Execute/P/Q/Z "COMPILEPROCEDURES "
			break
	endswitch

	if( status == 0 )
		WC_WindowCoordinatesHook(infoStr)
	endif
	return status
End

static Function WindowIsMinimized(win)
	String win
	
	GetWindow $win wsize
	Variable isMinimized = V_Left == 0 && V_Right == 0	// if true, the others are going to be zero, too.
	
	return isMinimized
End

Function ResetPanelSize(left, top, right, bottom) // points
	Variable left, top, right, bottom
	
	MoveWindow/W=$ksPanelName left, top, right, bottom
	SetWindow $ksPanelName userdata(setPanelSizeScheduled)= ""
	RepositionResponseControls()
	RepositionCommandControls()
End

static Function DoItButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			String cmd=GenerateCommand()	
			strswitch(ba.ctrlName)
				case "doit":
					Execute/P/Z cmd
					break
				case "toCmdLine":
					ToCommandLine cmd
					break
				case "toClip":
					PutScrapText cmd
					break
				case "cancel":
					break
			endswitch		
			Execute/P/Q/Z "DoWindow/K "+ksPanelName
			strswitch(ba.ctrlName)
				case "toCmdLine":
					Execute/P/Q/Z "DoWindow/F/H"
					break
			endswitch		
			break
	endswitch

	return 0
End

static Function HelpButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			DisplayHelpTopic/Z ksFilterDialogHelpTopic	// "Filter Dialog"
			break
	endswitch

	return 0
End

static Function ShowMagnitudeCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			ModifyGraph/Z/W=$ksGraphName hideTrace(magnitude)=!checked
			ModifyControlList/Z "magnitudePop;" win=$(cba.win), disable= checked ? 0 : 2
			break
	endswitch

	return 0
End

static Function/S MagnitudePopList()		
	return  ksMagnitudePopItems	// "dB;dB min -100;dB min -50;dB min -20;Gain;Gain log10;")
End		

static Function MagnitudePopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			UpdateResponse(0)
			break
	endswitch

	return 0
End

static Function UnwrapCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			UpdateResponse(0)
			break
	endswitch

	return 0
End

static Function RadiansDegreesCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Checkbox phaseDegrees win=$(cba.win), value=CmpStr(cba.ctrlName, "phaseDegrees") == 0
			Checkbox phaseRadians win=$(cba.win), value=CmpStr(cba.ctrlName, "phaseRadians") == 0
			UpdateResponse(0)
			break
	endswitch

	return 0
End

static Function ShowPhaseCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			String graphName= ksGraphName
			ModifyGraph/Z/W=$graphName hideTrace(phase)=!checked
			// disable or enable phase controls
			ModifyControlList/Z "phaseDegrees;phaseRadians;phaseUnwrap;" win=$(cba.win), disable= checked ? 0 : 2
			break
	endswitch

	return 0
End

Static Function FilteredOutputNameSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 2: // Enter key
			UpdateResponse(0)
			break
	endswitch

	return 0
End

static Function AutoUpdateFilteredOutCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			Wave/Z filterInputWave= $FilterInputWavePath()
			if( checked && !WaveExists(filterInputWave) )
				DoAlert 0, ksDlgErrSelectInputToFilter	// "Select an Input to Filter from the list above."
			endif
			break
	endswitch

	return 0
End

// PopupMenu endEffect proc=WMFilter#EndEffectPopMenuProc
static Function EndEffectPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			Variable/G root:Packages:WM_FilterDialog:endEffect= popNum-1 // endEffect is 0-based, pop nums are 1-based
			ShowHideApplyFilterControls()
			UpdateResponse(0)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

// SetVariable fillValue proc=WMFilter#FilterDialog#FillValueSetVarProc
// SetVariable endfillValue proc=WMFilter#FilterDialog#FillValueSetVarProc
static Function FillValueSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName // fillValue or endFillValue
	Variable varNum
	String varStr
	String varName

	UpdateResponse(0)
End

// CheckBox endFillCheck proc=FilterDialog#EndFillCheckProc
Function EndFillCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	ShowHideApplyFilterControls()
	UpdateResponse(0)
End


static Function UpdateFilterOutputNowButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			Wave/Z filterInputWave= $FilterInputWavePath()
			if( WaveExists(filterInputWave) )
				UpdateResponse(1)
			else
				DoAlert 0, ksDlgErrSelectInputToFilter	// "Select an Input to Filter from the list above."
			endif
			break
	endswitch

	return 0
End

static Function EditZerosPolesButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if( DoingUserCoefs() )
				String pathToSelectedCoefs= SelectedCoefsWavePath()
				WAVE/Z coefs=$pathToSelectedCoefs
				Variable kindOfCoefs= CoefsWaveKind(coefs)
				if( kindOfCoefs == kCoefsIIRZerosPoles )
					Variable fs= NumVarOrDefault("root:Packages:WM_FilterDialog:fs", 1)
					InvokeIIRZerosPolesDesign(fs, coefs)
				else
					String err
					sprintf err, 	ksDlgErrNotPoleZeroWaveFormat, pathToSelectedCoefs		// "%s is not a Zeros and Poles filter coefficients wave."
					DoAlert 0, err
				endif
			endif
			break
	endswitch

	return 0
End

static Function CoefsOutputNameSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			String cmd=GenerateCommand()	
			break
	endswitch

	return 0
End

static Function CreateCoefsCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			String cmd=GenerateCommand()
			break
	endswitch

	return 0
End

static Function WindowPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			String/G root:Packages:WM_FilterDialog:fir_windowKind= pa.popStr
			UpdateResponse(0)
			break
	endswitch

	return 0
End

static Function DesignZeroPolesButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			NVAR createFilter= root:Packages:WM_FilterDialog:createFilter
			SVAR coefsOutputName= root:Packages:WM_FilterDialog:coefsOutputName
			if( DoingIIR() && createFilter && strlen(coefsOutputName) )
				Variable isFIR=0	// it isn't, we know
				SVAR pathToSelectedCoefs= root:Packages:WM_FilterDialog:pathToSelectedCoefs
				String quotedCoefsName= PossiblyQuoteName(coefsOutputName)
				pathToSelectedCoefs= CreateCoefs(isFIR)// returns path to dialog-local coefs wave in the root:Packages:WM_FilterDialog: data folder
				String/G root:Packages:WM_FilterDialog:pathToSelectedCoefs= CreateCoefs(isFIR)// returns path to dialog-local coefs wave in the root:Packages:WM_FilterDialog: data folder
				WAVE/Z coefs=$pathToSelectedCoefs
				Variable kindOfCoefs= CoefsWaveKind(coefs)
				if( kindOfCoefs == kCoefsIIRZerosPoles )
					// create the coefs wave in the current data folder
					Duplicate/O coefs, $quotedCoefsName
				else
					Make/O/C/D/N=(1,2) $quotedCoefsName= cmplx(0,0)
				endif
				WAVE/C newCoefs= $quotedCoefsName
				pathToSelectedCoefs= GetWavesDataFolder(newCoefs,2)
				// select the created wave
				ModifyControl/Z coefsWavesList, win=$ksPanelName, disable=0	// without this the wave sometimes isn't selected.
				WS_SelectAnObject(ksPanelName, "coefsWavesList", pathToSelectedCoefs, OpenFoldersAsNeeded=1)
				// Enter SelectFilterCoefficients Wave tab before launching 	WMFilterIIRZerosPolesDesign
				TabControl firIIRTab win=$ksPanelName, value=coefsTabNum
				// switch modes
				ChangeFIRIIRTab(coefsTabNum)	// calls UpdateResponse(0)
				Variable fs= NumVarOrDefault("root:Packages:WM_FilterDialog:fs", 1)
				InvokeIIRZerosPolesDesign(fs, newCoefs)
			endif
			break
	endswitch

	return 0
End

static Function InvokeIIRZerosPolesDesign(fs, coefs)
	Variable fs
	WAVE/C/Z coefs
	
	if( !WaveExists(coefs) )
		Beep
		return 1
	endif
	String functionName=GetIndependentModulename()+"#WMFilterIIRZerosPolesDesign"
	if( exists(functionName) != 3 )
		Execute/P/Q/Z "INSERTINCLUDE <Pole and Zero Filter Design> menus=0"
		Execute/P/Q/Z "COMPILEPROCEDURES "
	endif
	String cmd
	sprintf cmd, "%s(%.14g, %s)", functionName,fs, GetWavesDataFolder(coefs,2)
	Execute/P/Q/Z cmd
	return 0
End

