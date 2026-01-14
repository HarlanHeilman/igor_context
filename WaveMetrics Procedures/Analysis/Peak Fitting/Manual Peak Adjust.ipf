#pragma rtGlobals=3		// Use modern global access method.
#pragma version=1.2

//******************** Revision Notes **********************
// Prior to version 1.1, there was no version number
//
//	version 1.10
//	JW 070828
//		Added optional parameter graphName to StartManualPeakMode.
//		Changed window hook function to named hook.
//		Provided alternate interface StartManualPeakModeEX to allow starting from an already-received mouse down.
//			This is used by Multipeak Fit 2.
//	version 1.20
//	ST 200527
//		Added support for asymmetric peak editing.
//	JW 200817
//		Removed commented code left over from a old-style to new-style hook function conversion. Also removed
//		debugging code that was potentially printing mysterious messages into the history.
//******************************************************

// Manual Peak Adjust
// Generic manual peak place and edit package

// Call with the target wave (used to determine graph and axes) and
// a callback function that will be called when a peak is placed or edited.
// If a list of wave names and equivalent Gaussian parameters is supplied
// via the wPkNames and wPkCoefs parameters then edit mode will be
// entered. In this mode, clicking on one of the peaks in the  wPkNames list
// will allow the user to drag and resize the existing peak. wPkNames must
// be a 1D text wave containing the names of editable peak waves. wPkCoefs
// is a 4 or 5 column matrix with a row for each peak. Columns are y0, a, x0, and w,
// or alternatively w1 and w2 instead of w for asymmetric peaks
// as described below. After calling StartManualPeakMode, you can kill the
//  wPkNames and wPkCoefs waves.
//
// If wPkNames and wPkCoefs are null ($"") then the user can insert new
// peaks.
//
// The callback will be called with the parameters of a Gaussian ( y0+a*exp(-((x-x0)/w)^2 )
// like so:
// 	 yourfunc(pk,y0,a,x0,w) or yourfunc(pk,y0,a,x0,w1,w2)
// where pk is the peak number. If insert mode, pk will be zero.
// The return value is ignored. In case of the asymmetric peak function type
// the Gaussian is split into left side (with width w1) and right side (w2).
// If w1 and w2 are not the same size then the peak will be asymmetric.


Function StartManualPeakMode(wtarg,ACallbackFunc,wPkNames,wPkCoefs [, graphName])
	Wave wtarg
	String ACallbackFunc
	WAVE/Z/T wPkNames
	WAVE/Z wPkCoefs
	String graphName
	
	if (ParamIsDefault(graphName))
		String win= FindGraphWithWave(wtarg)
		if( StrLen(win)==0 )
			return 0
		endif
	else
		win = graphName
	endif
	DoWindow/F $win
	
	String info= TraceInfo(win,NameOfWave(wtarg),0)
	String xaxis= StringByKey("XAXIS",info)
	GetAxis/Q $xaxis
	Variable x0= V_min,x1= V_max

	String dfSav= InitManualPeakPlacePackage()
	
	Variable/G gIsEditMode= WaveExists(wPkNames)
	if( gIsEditMode )
		Duplicate/O/T wPkNames, peakNameList
		Duplicate/O wPkCoefs, peakCoefArray
	endif
		
	
	String/G UserCallback= ACallbackFunc
	String/G TheGraph= win
	Make/O/N=300 tmpPeak= NaN
	SetScale x,x0,x1,tmpPeak
	Execute "AppendToGraph"+StringByKey("AXISFLAGS",info)+" tmpPeak"
	ModifyGraph live(tmpPeak)=1

	SetWindow $win,hook(ManualPeakAdjustHook)=ManPeakInsertHookProc,hookcursor=1
	Variable/G gMode= -1
	String/G gMessage
	if( gIsEditMode )
		gMessage= "Click on peak and drag."
	else
		gMessage= "Click and drag out Peak."
	endif
	Variable/G gThePeakNum= 0
	
	SetDataFolder dfSav
end

// if this function is called with an even structure having a mousedown event, it will immediately
// start the action by calling the hook function with s. If s contains an event code other than mousedown,
// it will be just like calling StartManualPeakMode(). Really, this function should only be called for a mousedown;
// other uses should call StartManualPeakMode().
Function StartManualPeakModeEX(wtarg,ACallbackFunc,wPkNames,wPkCoefs, s)
	Wave wtarg
	String ACallbackFunc
	WAVE/Z/T wPkNames
	WAVE/Z wPkCoefs
	STRUCT WMWinHookStruct &s

	StartManualPeakMode(wtarg,ACallbackFunc,wPkNames,wPkCoefs, graphName=s.winName)
	if (s.eventCode == 3)
		String dfSav= InitManualPeakPlacePackage()
		NVAR gmode
		SetDataFolder dfSav
		gmode = 0
		return ManPeakInsertHookProc(s)
	endif
	
	return 0
end	


// ***** copied from Multi-peak fitting 1.3.ipf and made static so this file can stand alone
// ***** Realy, though, this should be in a common utility file.
// Find topmost graph containing given wave
//	returns zero length string if not found
//
Static Function/S FindGraphWithWave(w)
	wave w
	
	string win=""
	variable i=0
	
	do
		win=WinName(i, 1)				// name of ith graph window
		if( strlen(win) == 0 )
			break;							// no more graph wndows
		endif
		CheckDisplayed/W=$win  w
		if(V_Flag)
			break
		endif
		i += 1
	while(1)
	return win
end
	

// Ok to call even if not in insert or modify mode
Function EndManualPeakMode()
	String dfSav= InitManualPeakPlacePackage()
	String/G TheGraph
	String/G gMessage= ""
	SetDataFolder dfSav
	
	if( StrLen(TheGraph)==0 )
		return 0
	endif

	if( CmpStr(WinName(0, 1),TheGraph) != 0 )		// Graph is no longer front?
		DoWindow/F $TheGraph
		if( V_Flag==0 )
			return 0									// oops! Graph is gone
		endif
	endif
	RemoveFromGraph/Z tmpPeak
	SetWindow $TheGraph,hook(ManualPeakAdjustHook)=$"",hookcursor=0
	TheGraph= ""
end


// This is called automatically
Function/S InitManualPeakPlacePackage()
	
	String dfSav= GetDataFolder(1)
	
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:ManualPeaks

	if( NumVarOrDefault("root:Packages:ManualPeaks:inited",0) )
		return dfSav
	endif
	
	Variable/G gLastClickY= NaN
	Variable/G gLastClickX= NaN
	Variable/G gMode= -1	// i.e., not started
	String/G gMessage= "Watch this space."

	String/G UserCallback= "NoFuncSetYet"
	Variable/G gIsEditMode= 0
	Variable/G gThePeakNum= 0

	Variable/G inited= 1

	return dfSav
end



Function ManPeakInsertHookProc(s)
	STRUCT WMWinHookStruct &s
	
	String dfSav= InitManualPeakPlacePackage()
	
	Variable xpix,ypix,xaxval,yaxval
	
	Variable isMouseDown= s.eventCode == 3
	Variable isMouseMoved=  s.eventCode == 4
	Variable isMouseUp=  s.eventCode == 5
	Variable returnVal= 0

	Variable/G gMode,gLastClickY,gLastClickX
	String/G gMessage
	Variable/G gIsEditMode
	Variable/G gThePeakNum
		
	if( isMouseDown || isMouseUp )
		xpix= s.mouseLoc.h
		ypix= s.mouseLoc.v
		xaxval= AxisValFromPixel("","bottom",xpix)
		yaxval= AxisValFromPixel("","left",ypix)
		
		gLastClickY= yaxval
		gLastClickX= xaxval
	endif
		
	if( isMouseDown )
		// state variable gMode:
		// 0 means mousedown = start or edit
		// 1 means dragging out peak, 2 means we are dragging an exising peak
		// 3 means we are adjusting baseline and width of an existing peak
		if( gMode==0 )
			if( gIsEditMode )
				Wave/T pnl= peakNameList
				WAVE/Z pcoefa= peakCoefArray

				Make/O/N=5 wcoef							// ST: holding : y0, a, x0, w1, w2
				gThePeakNum= 0
				Variable i=0,imax= numpnts(pnl)
				Do
					String theTrace = TraceFromPixel(xpix,ypix,"ONLY:"+PossiblyQuoteName(pnl[i])+";")
					if( strlen(theTrace)!=0 )
						gThePeakNum= i+1
						if (DimSize(pcoefa,1) == 4)			// ST: compatibility with symmetric peak function calls (symmetric peaks have only 4 parameters)
							wcoef[,3]= pcoefa[i][p]
							wcoef[4]= pcoefa[i][3]			// ST: duplicate the width
						else
							wcoef= pcoefa[i][p]				// ST: rewritten for left/right width
						endif
						break
					endif
					i+=1
				while(i<imax)
				if( gThePeakNum==0 )
					gMessage= "Didn't find individual peak at click."
				else
					gMessage= "Drag peak to desired location."
					Duplicate/O wcoef,wcoefsav
					UpdatePeakFromXY(yaxval,xaxval,1,1)
					gMode= 2								// drag peak around until mouse is released
				endif
				
			else
				gMode= 1 
				SetWindow $s.winName,hookcursor=8		// 4 arrows
				gMessage= "Drag and release. Hold shift to skew peak."
				UpdatePeakFromXY(yaxval,xaxval,1,0)
				Duplicate/O $"wcoef",wcoefsav
			endif
		else
			isMouseUp= 1		// fake mouse up if had been expecting a mouseup but got a mousedown (drag out of window and release syndrome)
								// Also used for the finish edit click in mode 3
		endif
		
		returnVal= 1
	endif
	if( isMouseMoved )
		xpix= s.mouseLoc.h
		ypix= s.mouseLoc.v
		xaxval= AxisValFromPixel("","bottom",xpix)
		yaxval= AxisValFromPixel("","left",ypix)

		if( gMode==-1 )
			// if we had a message when user first moves cursor onto graph, we could set it here.
			gMode= 0
		endif
		if( gMode==1 )
			UpdatePeakFromXY(yaxval,xaxval,0,0)
		endif
		if( gMode==2 )
			UpdatePeakFromXY(yaxval,xaxval,1,1)
		endif
		if( gMode==3 )
			UpdatePeakFromXY(yaxval,xaxval,0,1)
		endif
	endif
	if( isMouseUp )
		do
			if( ( gMode==1) %| (gMode==3) )
				WAVE wdest= tmpPeak
				WAVE/Z pcoefa= peakCoefArray
				wdest= NaN
				Wave wcoef=wcoef
				SVAR UserCallback= UserCallback
				FUNCREF UserCallBackTemplateAsym userFuncAsym=$UserCallBack		
				SetDataFolder dfSav
				
				Variable userReturn = 0
				Variable FuncInfo = str2num(StringByKey("N_PARAMS",FunctionInfo(UserCallBack),":"))
				if (Funcinfo == 5)							// ST: compatibility with symmetric peak function calls
					FUNCREF UserCallBackTemplate userFunc=$UserCallBack
					userReturn = userFunc(gThePeakNum, wcoef[0], wcoef[1], wcoef[2], wcoef[3])
				else
					userReturn = userFuncAsym(gThePeakNum, wcoef[0], wcoef[1], wcoef[2], wcoef[3], wcoef[4])
				endif

				if ( (NumType(userReturn) == 2) || (userReturn == 0) )
					SetWindow $s.winName,hookcursor=1		// selection arrow
					if( gMode==1 )
						gMessage= "Start new or click Finish."
					else
						pcoefa[gThePeakNum-1][]= wcoef[q]
						gMessage= "Edit old or click Finish."
					endif
					gMode= 0
				else
				endif
				break
			endif
			if( gMode==2 )
				Duplicate/O $"wcoef",wcoefsav
				gMessage= "Click to end edit. Hold shift to skew peak."
				gMode= 3
				break
			endif
		while(0)
	endif
	SetDataFolder dfSav
	return returnVal
end

Function UserCallBackTemplateAsym(pk,y0,a,x0,w1,w2)
	Variable pk,y0,a,x0,w1,w2
end

Function UserCallBackTemplate(pk,y0,a,x0,w)
	Variable pk,y0,a,x0,w
end

// Assumes we are already in the proper data folder
Function UpdatePeakFromXY(yaxval,xaxval,isPeak,isOld)
	Variable yaxval,xaxval,isPeak,isOld
	
	Wave wdest = tmpPeak
	Make/O/N=5 wcoef,wcoefsav	// ST: holding : y0, a, x0, w1, w2

	Variable/G gLastClickY
	Variable/G gLastClickX

	if( isPeak )		// either peak pos/top or baseline/width
		if( isOld )
			wcoef[0]= wcoefsav[0]+yaxval-gLastClickY
			wcoef[1]= wcoefsav[1]
			wcoef[2]= wcoefsav[2]+xaxval-gLastClickX
		else
			wcoef[0]= yaxval
			wcoef[1]= 0
			wcoef[2]= xaxval
			wcoef[3]= 0
			wcoef[4]= 0			// ST: left and right width
		endif
	else
		if( isOld )
			wcoef[0]= wcoefsav[0]+yaxval-gLastClickY
			wcoef[1]= wcoefsav[1] + wcoefsav[0] - wcoef[0]		// maintain old peak top
		else
			wcoef[0]= yaxval
			wcoef[1]= wcoefsav[1] + wcoefsav[0] - yaxval		// maintain old peak top
		endif
		
		Variable ShiftPressed = GetKeyState(0) & 2^2			// ST: shift key as skew modifier
		
		Variable RightSide = gLastClickX > wcoefsav[2]			// ST: left or right of peak center?
		Variable AverageWidthSav = (wcoefsav[3]+wcoefsav[4])/2
		Variable CurDisplacement = (xaxval - gLastClickX)

		if (ShiftPressed)										// ST: prevent skewing new peaks
			if (AverageWidthSav == 0)							// ST: for new peaks => save the current cursor displacement as 'width'
				RightSide = (xaxval - gLastClickX) > 0			// right side = cursor is at higher x than last click
				if (RightSide)
					wcoefsav[3] = abs(CurDisplacement)
					wcoefsav[4] = abs(CurDisplacement)/2
				else
					wcoefsav[3] = abs(CurDisplacement)/2
					wcoefsav[4] = abs(CurDisplacement)
				endif
				AverageWidthSav = (wcoefsav[3]+wcoefsav[4])/2
			endif
			
			CurDisplacement *= RightSide ? 1 : -1				// ST: switch edit direction depending on peak side
			Variable multiplicator = CurDisplacement > 0 ? (AverageWidthSav - CurDisplacement)/AverageWidthSav : (AverageWidthSav + CurDisplacement)/AverageWidthSav
			multiplicator = exp((multiplicator-1)/10)			// ST: a multiplicator which slows down when approaching the center line; the denominator decides how slowly the width approaches zero

			if (RightSide)
				if (CurDisplacement > 0)
					wcoef[3] = wcoefsav[3] * multiplicator
					wcoef[4] = wcoefsav[4] + CurDisplacement/2
				else
					wcoef[3] = wcoefsav[3] - CurDisplacement/2	
					wcoef[4] = wcoefsav[4] * multiplicator
				endif
			else
				if (CurDisplacement > 0)
					wcoef[3] = wcoefsav[3] + CurDisplacement/2	
					wcoef[4] = wcoefsav[4] * multiplicator
				else
					wcoef[3] = wcoefsav[3] * multiplicator
					wcoef[4] = wcoefsav[4] - CurDisplacement/2
				endif
			endif
			
			Variable minwidth = DimDelta(wdest,0)
			wcoef[3] = max(wcoef[3],minwidth)
			wcoef[4] = max(wcoef[4],minwidth) 
		else
			CurDisplacement *= RightSide ? 1 : -1				// ST: switch edit direction depending on peak side
			wcoef[3] = AverageWidthSav + CurDisplacement		// ST: snap back to symmetric peak for pure width edit
			wcoef[4] = AverageWidthSav + CurDisplacement
		endif
	endif

	Variable y0 = wcoef[0]
	Variable a  = wcoef[1]
	Variable x0 = wcoef[2]
	Variable w1 = wcoef[3]
	Variable w2 = wcoef[4]
	
	wdest = x < x0? y0+a*exp(-((x-x0)/w1)^2) : y0+a*exp(-((x-x0)/w2)^2)	// ST: modify left and right peaks separately
end	

Function PeekHookStartButtonProc(ctrlName) : ButtonControl
	String ctrlName

	if( CmpStr(ctrlName,"start")==0 )
		Button start,rename=finish,title="Finish"
		SetWindow Graph0,hook(ManualPeakAdjustHook)=PeakHookProc,hookcursor=1
		Variable/G root:Packages:PeakHookDemo:gWhichCoef= -1
		DoWindow/F Graph0
		String/G root:Packages:PeakHookDemo:gMessage= "Move cursor onto graph."
	endif
	if( CmpStr(ctrlName,"finish")==0 )
		SetWindow Graph0,hook(ManualPeakAdjustHook)=$"",hookcursor=0
		DoWindow/K HookPanel
	endif
End

Window HookPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel/K=2 /W=(429,242,730,325)
	Button start,pos={10,9},size={50,20},proc=PeekHookStartButtonProc,title="Start"
	SetVariable message,pos={10,37},size={274,17},title=" "
	SetVariable message,limits={-Inf,Inf,1},value= root:Packages:PeakHookDemo:gMessage
EndMacro
