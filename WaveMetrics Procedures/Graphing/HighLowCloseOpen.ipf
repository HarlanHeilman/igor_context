#pragma rtGlobals=2		// Use modern global access method.
#pragma IgorVersion=6.2	// for markerHook

Menu "Graph", dynamic
	Submenu "High Low Close Open Trace"
		"Append High Low Close Open Trace", DoAppendHighLowCloseOpen()
		Submenu "Line Sizes"
			HighLowCloseOpenLineSizesMenu(), /Q, DoHighLowCloseOpenLineSize()
		End
		Submenu "Color"
			HighLowCloseOpenColorMenu(),/Q, DoHighLowCloseOpenColor()
		End
	End
End

Function OpenCloseMarkerProc(s)
	STRUCT WMMarkerHookStruct &s
	
	if( s.marker > 3 )
		return 0
	endif

	Variable overhang= s.penThick/2
	Variable size= s.size - overhang
	if( s.marker == 0 )			// open
		DrawLine s.x-size, s.y, s.x+overhang , s.y
	elseif( s.marker == 1 )		// close
		DrawLine s.x-overhang, s.y, s.x+size, s.y
	endif
	return 1
End

Constant kOpenMarker =100
Constant kCloseMarker =101
StrConstant ksHighLowCloseOpenUserDataName="WMHighLowCloseOpenData"

static Function HaveHighLowCloseOpen(graphName)
	String graphName
	
	if( strlen(graphName) == 0 )
		return 0
	endif
	DoWindow $graphName
	if( V_Flag == 0 )
		return 0
	endif
	String traces= TraceNameList(graphName, ";", 1)
	Variable i, n= ItemsInList(traces)
	for(i=0; i<n; i+=1 )
		String traceName= StringFromList(i,traces)
		String userData= GetUserData(graphName, traceName, ksHighLowCloseOpenUserDataName)
		strswitch(userData)
			case "open":
			case "close":
			case "high/low":
				return 1	// have at least one open/close/high/low trace
				break
		endswitch
	endfor
	return 0
End

Function/S HighLowCloseOpenColorMenu()
	String colorMenu= "*COLORPOP*"
	if( !HaveHighLowCloseOpen(WinName(0,1)) )
		colorMenu=  "\M1:(:"+colorMenu
	endif
	return colorMenu 
End

Function/S HighLowCloseOpenLineSizesMenu()

	String sizes="0.5;1;2;3;4;5;6;7;8;9;"
	if( !HaveHighLowCloseOpen(WinName(0,1)) )
		Variable i, n= ItemsInList(sizes)
		String disabledSizes=""
		for(i=0; i<n; i+=1 )
			String size= StringFromList(i,sizes)
			disabledSizes +=  "\M1:(:"+size+";"
		endfor
		sizes= disabledSizes
	endif
	return sizes 
End

Function DoHighLowCloseOpenLineSize()
	GetLastUserMenuInfo
	Variable lineSize= str2num(S_Value)
	SetHighLowCloseOpenLineSize(lineSize)
End

Function DoHighLowCloseOpenColor()
	GetLastUserMenuInfo
	SetHighLowCloseOpenColor(V_Red, V_Green, V_Blue)
End

Function SetHighLowCloseOpenColor(red, green, blue)
	Variable red, green, blue
	
	// find all the traces related to high-low-open-close and change the line size or marker stroke size.
	String graphName= WinName(0,1)
	if( strlen(graphName) == 0 )
		Beep
		return 0
	endif
	String traces= TraceNameList(graphName, ";", 1)
	Variable i, n= ItemsInList(traces)
	for(i=0; i<n; i+=1 )
		String traceName= StringFromList(i,traces)
		String userData= GetUserData(graphName, traceName, ksHighLowCloseOpenUserDataName)
		strswitch(userData)
			case "open":
			case "close":
			case "high/low":
				ModifyGraph/W=$graphName rgb($traceName)=(red, green, blue)
				break
		endswitch
	endfor
End


Function SetHighLowCloseOpenLineSize(lineSize)
	Variable lineSize
	
	// find all the traces related to high-low-open-close and change the line size or marker stroke size.
	String graphName= WinName(0,1)
	if( strlen(graphName) == 0 )
		Beep
		return 0
	endif
	String traces= TraceNameList(graphName, ";", 1)
	Variable i, n= ItemsInList(traces)
	for(i=0; i<n; i+=1 )
		String traceName= StringFromList(i,traces)
		String userData= GetUserData(graphName, traceName, ksHighLowCloseOpenUserDataName)
		strswitch(userData)
			case "open":
			case "close":
				ModifyGraph/W=$graphName mrkThick($traceName)=lineSize, msize($traceName)=lineSize*3
				break
			case "high/low":
				ModifyGraph/W=$graphName lsize($traceName)=lineSize
				break
		endswitch
	endfor
End

Proc DoAppendHighLowCloseOpen(wHigh, wLow, wClose, wOpen, wDays)
	String wHigh, wLow, wClose, wOpen, wDays
	Prompt wHigh, "High Prices", popup, WaveList("*",";","DIMS:1")	
	Prompt wLow, "Low Prices", popup, WaveList("*",";","DIMS:1")
	Prompt wClose, "Close Prices", popup, WaveList("*",";","DIMS:1")
	Prompt wOpen, "Open Prices", popup, WaveList("*",";","DIMS:1")	
	Prompt wDays, "Days", popup, WaveList("*",";","DIMS:1")+";_none_;"	// can be string or numeric wave or _none_

	AppendHighLowCloseOpen($wHigh, $wLow, $wClose, $wOpen, $wDays)
End

Function AppendHighLowCloseOpen(wHigh, wLow, wClose, wOpen, wDays)
	Wave wHigh, wLow, wOpen, wClose
	Wave/Z wDays

	String graphName= WinName(0,1)
	if( strlen(graphName) == 0 )
		DoAlert 0, "Make a graph, first!"
		return 0
	endif
	
	String outName= CleanupName(NameOfWave(wHigh)[0,14]+"_"+NameOfWave(wLow)[0,14],1)

	if( !WaveExists(wDays) )
		Variable n= numpnts(wOpen)
		String daysName= CleanupName(outName[0,25]+"_days",1)
		Make/O/N=(n) $daysName= p+1	// 1-n
		WAVE wDays= $daysName
	endif

	SetWindow $graphName markerHook={OpenCloseMarkerProc,kOpenMarker,kCloseMarker}
	AppendToGraph/W=$graphName wOpen,wClose vs wDays
	String openTraceName= NameOfWave(wOpen)
	String closeTraceName= NameOfWave(wClose)
	ModifyGraph/W=$graphName mode($openTraceName)=3, mode($closeTraceName)=3
	ModifyGraph/W=$graphName marker($openTraceName)=kOpenMarker,marker($closeTraceName)=kCloseMarker
	ModifyGraph/W=$graphName mrkThick($openTraceName)=1,mrkThick($closeTraceName)=1

	//	Make this work: String userData= GetUserData(graphName, $openTraceName, ksHighLowCloseOpenUserDataName)
	ModifyGraph/W=$graphName userData($openTraceName)={$ksHighLowCloseOpenUserDataName, 0, "open"}
	ModifyGraph/W=$graphName userData($closeTraceName)={$ksHighLowCloseOpenUserDataName, 0, "close"}

	WAVE  wHighLow= fMakeHighLowWave(wHigh, wLow, outName)
	String dayOutName= CleanupName(NameOfWave(wDays)[0,14]+"_4HiLo",1)
	WAVE wHiLoDays= fMakeHighLowDays(wDays, dayOutName)
	
	AppendToGraph/W=$graphName wHighLow vs wHiLoDays
	ModifyGraph/W=$graphName mode($outName)=0
	ModifyGraph/W=$graphName userData($outName)={$ksHighLowCloseOpenUserDataName, 0, "high/low"}
End

Function/WAVE fMakeHighLowWave(wHigh, wLow, outName)
	Wave wHigh, wLow
	String outName
	
	Duplicate/O wHigh, $outName/WAVE=wout
	Variable n=numpnts(wHigh)
	Redimension/N=(3*numpnts(wHigh)) wout
	wout[0;3] = wHigh[p/3]		// interleave high first
	wout[1;3] = wLow[(p-1)/3]	// then low
	wout[2;3] = NaN				// then gap

	return wout
End

Function/WAVE fMakeHighLowDays(wDay, dayOutName)
	Wave wDay	// can be text or numeric wave
	String dayOutName

	Duplicate/O wDay, $dayOutName/WAVE=wout
	Variable n=numpnts(wDay)
	Redimension/N=(3*n) wout
	wout= wDay[trunc(p/3)]
	
	return wout
End

Window OpenCloseHighLowStyle() : GraphStyle
	PauseUpdate; Silent 1		// modifying window...
	ModifyGraph/Z mode[0]=3,mode[1]=3
	ModifyGraph/Z marker[0]=100,marker[1]=101
	ModifyGraph/Z lSize[2]=3
	ModifyGraph/Z rgb[0]=(1,16019,65535),rgb[1]=(1,16019,65535),rgb[2]=(1,16019,65535)
	ModifyGraph/Z msize[0]=9,msize[1]=9
	ModifyGraph/Z mrkThick[0]=3,mrkThick[1]=3
	ModifyGraph/Z grid(bottom)=1
	ModifyGraph/Z nticks(bottom)=10
	ModifyGraph/Z axOffset(bottom)=-1.66667
	ModifyGraph/Z tkLblRot(bottom)=90
	ModifyGraph/Z manTick(bottom)={3450384000,1,0,0,day},manMinor(bottom)={0,50}
	ModifyGraph/Z dateInfo(bottom)={0,0,0}
	Label/Z bottom " "
	SetWindow kwTopWin,markerHook={OpenCloseMarkerProc,100,101}
EndMacro
	
