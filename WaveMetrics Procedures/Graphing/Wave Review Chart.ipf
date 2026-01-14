
// ********* Wave Review Chart ***********
//
//	This package creates a control panel containing a strip-chart that can
//	be connected to a binary wave file (or to a normal FIFO file).
//	To use, run Create File Review Chart from Macros menu to create the chart panel,
//	select an appropriate path from the popup menu,  click the
//	open button and find a .bwav or FIFO file. 
//
//	You can also view a wave resident in memory by choosing _In Memory_ from the
//	Path popup menu. This will require double the memory as for the wave by itself.
//
//	If the wave is very large, you can use the utility SaveWaveFile()
//	to create a disk file from one of your waves in an experiment.
//
//	See the Wave Review Chart Demo experiment file for more info.
//	LH000421: updated to use Igor 4 features.

#pragma rtGlobals=2		// Use modern global access method and new syntax.

Menu "Macros"
	"Create File Review Chart",CreateFileReviewChart()
	"Save Wave File",SaveWaveFile()
end


Function CreateFileReviewChart()
	Make/O DataSamp=x			// a wave to put chanel 0 into when the => wave button is pressed

	DoWindow/F WM_DataSampGraph
	if( V_FLag==0 )
		Display/K=1/W=(5,42,400,250) DataSamp
		DoWindow/C WM_DataSampGraph
		ModifyGraph grid(left)=1
		ModifyGraph minor(left)=1
		Label bottom "\\U"
	endif

	DoWindow/F WM_WaveReviewChart
	if( V_FLag==0 )
		NewPanel/K=1/W=(184,59,550,364)
		DoWindow/C WM_WaveReviewChart
		SetDrawLayer UserBack
		Chart davechart,pos={9,8},size={348,209},title="no data",fSize=9,fifo= dave
		Chart davechart,chans={0},umode= 2
		Button bStart,pos={10,223},size={50,20},proc=StartStopButton,title="Open..."
		Button ToWaveButton,pos={168,277},size={130,20},proc=WM_WFFifoToWave,title="chart => graph"
		Button upButton,pos={272,223},size={80,20},proc=WM_WFExpandProc,title="H Contract"
		Button downButton,pos={272,247},size={80,20},disable=2,proc=WM_WFExpandProc,title="H Expand"
		PopupMenu stylePop,pos={163,249},size={88,20},proc=WM_WFStyleProc,title="Style:"
		PopupMenu stylePop,mode=1,value= #"\"Dots;Lines;Fill\""
		Button AutoButton,pos={168,220},size={74,20},proc=WM_WFAutoscaleBProc,title="Autoscale"
		PopupMenu pathPop,pos={5,249},size={134,20},title="path"
		PopupMenu pathPop,mode=1,value= #"\"_In Memory_;_current_;\"+PathList(\"*\", \";\", \"\")"
		GroupBox gb1,pos={269,220},size={87,51}
	endif
End

Function  SaveWaveFile()
	String path
	Prompt path,"place to write file", popup PathList("*",";","")
	String wname
	Prompt wname,"wave to write",popup WaveList("*",";","")
	String fname="temp file.bwav"
	Prompt fname,"file name"
	DoPrompt "Save Wave File",path,wname,fname
	if( V_Flag )
		return 0
	endif
	
	Save/O/C/P=$path $wname as fname
End
	

// This routine extracts info from a binary wave file (.bwav).
// It uses magic numbers (offsets into the file) that you (the user) are not
// expected to understand. You should use this routine only as a black box and you probably
// should not attempt to change it.
// On the other hand, you can use it as an example of a function using a temporary data
// folder filled with variables as a way of returning more than one value.
// 
Function/S ExamineBinaryWaveFile(refnum)
	Variable refnum
	
	FSetPos refnum,0
	Variable binvers
	FBinRead/F=2 refnum,binvers	// binary file version is short at offset 0
	Variable v1,wfmType,wfmOffset,wfmPnts
	Variable fsValid,topFullScale,botFullScale,wdeltaT
	Variable headersize
	String wName
	do
		if( binvers == 5 )
			headersize= (2*2+4*4+2*4*4+3*4)		// from BinHeader
			FSetPos refnum,headersize+26
			FBinRead/F=2 refnum,v1						// whVersion
			if( v1 != 1 )
				return "unsupported wave header version"
			endif
			wName= PadString("",32,0)
			FBinRead refnum,wName						// bname
			wfmOffset= 3*4								// next thru modDate
			FSetPos refnum,headersize+wfmOffset
			FBinRead/F=3 refnum,wfmPnts					// npnts
			FBinRead/F=2 refnum,wfmType					// type
			wfmOffset += 2*4+8+32+8+4*4				// npnts thru nDim[MAXDIMS]
			FSetPos refnum,headersize+wfmOffset
			FBinRead/F=5 refnum,wdeltaT					// sfA[0]
			wfmOffset += 2*8*4+4+4*4					// sfA thru dimUnits
			FSetPos refnum,headersize+wfmOffset
			FBinRead/F=2 refnum,fsValid					// fsValid
			wfmOffset +=4
			FSetPos refnum,headersize+wfmOffset
			FBinRead/F=5 refnum,topFullScale				// topFullScale
			FBinRead/F=5 refnum,botFullScale				// botFullScale
			wfmOffset += 2*8
			wfmOffset += 4+4*4+4*4+4+16*4			// dataEUnits thru whUnused
			wfmOffset += 4*2+5*4						//  aModified thru sIndicies
			break
		endif
		if( binvers == 2 )
			headersize= (2+3*4+2)					// from BinHeader2
			FSetPos refnum,headersize+26
			FBinRead/F=2 refnum,v1						// whVersion
			if( v1 != 0 )
				return "unsupported wave header version"
			endif
			wfmOffset= 0
			FSetPos refnum,headersize+wfmOffset
			FBinRead/F=2 refnum,wfmType					// type
			wfmOffset += 2+4								// type thru next
			wName= PadString("",20,0)
			FBinRead refnum,wName						// bname
			wfmOffset += 20+2*2+4+2*4					// bname thru xUnits
			FSetPos refnum,headersize+wfmOffset
			FBinRead/F=3 refnum,wfmPnts					// npnts
			wfmOffset += 4+2								// npnts thru aModified
			FSetPos refnum,headersize+wfmOffset
			FBinRead/F=5 refnum,wdeltaT					// hsA
			wfmOffset += 2*8+2*2						// hsA thru swModified
			FSetPos refnum,headersize+wfmOffset
			FBinRead/F=2 refnum,fsValid					// fsValid
			FBinRead/F=5 refnum,topFullScale				// topFullScale
			FBinRead/F=5 refnum,botFullScale				// botFullScale
			wfmOffset += 2+2*8+2+3*4+2+2*4			// useBits thru userComment
			break
		endif
		return "not a supported binary file"
	while(0)
	NewDataFolder/S/O ebwresults
	Variable/G offset= headersize+wfmOffset
	Variable/G type= wfmType
	Variable/G npnts= wfmPnts
	String/G name= wName
	if( !fsValid )
		Make/N=(min(10000,wfmPnts)) ebwTmp
		FSetPos refnum,headersize+wfmOffset
		FBinRead/Y=(wfmType) refnum,ebwTmp
		WaveStats/Q ebwTmp
		topFullScale= V_Max
		botFullScale= V_Min
		KillWaves ebwTmp
	endif
	Variable/G topFS= topFullScale
	Variable/G botFS= botFullScale
	Variable/G deltaT= wdeltaT
	SetDataFolder ::
	return ""
end

// This could be a built-in function some day so we try to avoid name conflits.
Function WM_NumSize(ntype)
	Variable ntype
	
	Variable isCmplx= (ntype&1) != 0,nbytes= 0
	ntype= ntype&(2+4+8+16+32)
	
	switch(ntype)
		case 1:
			return 1				// text, 1 byte, can't be complex
		case 2:
			nbytes= 4				// float
			break
		case 4:
			nbytes= 8				// double
			break
		case 8:
			nbytes= 1				// byte
			break
		case 16:
			nbytes= 2				// short
			break
		case 32:
			nbytes= 4				// long
			break
	endswitch
	
	return isCmplx ? nbytes*2 : nbytes
end


Function WM_WFLoadFifoFromWave()
	String wname
	Prompt wname,"wave to review",popup WaveList("*",";","")
	DoPrompt "Load from wave",wname
	if( V_Flag )
		return 0
	endif


	Wave/Z w= $wname
	if( WaveExists(w) == 0 )
		return 0
	endif

	Variable npts= numpnts(w),i

	WaveStats/Q/R=[0,10000] w

	NewFIFOChan/Y=(WaveType(w)) dave, $NameOfWave(w), 0, 1, V_Min, V_Max, ""
	CtrlFIFO dave,size=npts,deltaT= deltax(w),start
	
	for(i=0;i<npts;i+=1)
		AddFIFOData dave,w[i]
	endfor
	CtrlFIFO dave,stop
	
	DoUpdate		// let the chart recognize the new fifo and autoconfigure
	Chart davechart,oMode= 1,ppStrip= 1		// need to set ppStrip because autoconfigure may set it assuming we will be acually taking live data (depends of deltaT)
	Chart davechart,jumpTo=300
	Chart davechart,title="data from wave"+NameOfWave(w)
	return 1
end

 Function WM_WFDoStartButton()
	FIFOStatus/Q dave
	if( V_FLag!=0 )
		KillFIFO dave
		DoUpdate				// let chart know we killed its fifo
	endif
	NewFIFO dave

	variable refnum
	
	ControlInfo pathPop
	if( CmpStr(S_value,"_current_") == 0 )
		Open/R/T="????"/D/M="select a FIFO file or wave" refnum
	else
		if( CmpStr(S_value,"_In Memory_") == 0 )
			return WM_WFLoadFifoFromWave()			// ********** exit if use resident wave
		else
			Open/P=$S_value/R/T="????"/D/M="select a FIFO file or wave" refnum
		endif
	endif
	if( strlen(S_FileName) == 0 )
		return 0
	endif
	String fName= S_FileName

	String s= PadString("",8,0)
	Open/R refnum as fName

	FStatus refnum
	Chart davechart,title="data from "+S_FileName
	
	FBinRead refnum,s
	FSetPos refnum,0
	if( CmpStr(s,"IGORfifo") == 0 )
		CtrlFIFO dave,rfile=refnum
	else
		String err= ExamineBinaryWaveFile(refnum)
		if( strlen(err) == 0 )
			Variable offset= NumVarOrDefault(":ebwresults:offset",-1)
			Variable type= NumVarOrDefault(":ebwresults:type",-1)
			String wname= StrVarOrDefault(":ebwresults:name","dummy")
			Variable topFS= NumVarOrDefault(":ebwresults:topFS",1)
			Variable botFS= NumVarOrDefault(":ebwresults:botFS",-1)
			Variable npnts= NumVarOrDefault(":ebwresults:npnts",0)
			Variable deltaT= NumVarOrDefault(":ebwresults:deltaT",1)
			KillDataFolder ebwresults
			NewFIFOChan/Y=(type) dave, $wname, 0, 1, botFS, topFS, ""
			CtrlFIFO dave,deltaT= deltaT
			CtrlFIFO dave,rdfile=refnum,doffset=offset,dsize=npnts*WM_NumSize(type)
			DoUpdate		// let the chart recognize the new fifo and autoconfigure
			Chart davechart,oMode= 1
			Chart davechart,jumpTo=300
			ControlInfo stylePop
			Chart davechart,lineMode(0)= V_Value-1
			if( deltaT < 0.05 )
				DoUpdate		
				Chart davechart,ppStrip= 1		// need to set ppStrip because autoconfigure may set it assuming we will be acually taking live data (depends of deltaT)
			endif
		else
			DoAlert 0,err
			Close refnum
			return 0
		endif
	endif
	return 1
end

	
	
Function StartStopButton(theTag) : ButtonControl
	String theTag
	
	if( cmpstr(theTag,"bStart") == 0 )
		if( WM_WFDoStartButton() )
			Button $theTag,title="Close",rename=bStop
		endif
	else
		Button $theTag,title="Open...",rename=bStart
		KillFIFO dave
		Chart davechart,title="no data"
	endif
End



Function WM_WFExpandProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo davechart
	Variable newPPS= NumberByKey("PPSTRIP",S_Value)
	if( StrSearch(ctrlName,"up",0) >= 0 )
		newPPS *= 2
	else
		newPPS /= 2
	endif
	newPPS= limit(newPPS,1,32)
	Chart davechart,ppStrip= newPPS
	Button downButton,disable= (newPPS==1) ? 2 : 0
	Button upButton,disable= (newPPS==32) ? 2 : 0
End


Function WM_WFFifoToWave(ctrlName) : ButtonControl
	String ctrlName
	
	if( WM_WFCheckInvalid() )
		return 0
	endif

	ControlInfo davechart
	String chan= StringByKey("CHNAME0",S_Value)
	FIFO2Wave/S=3/R=[NumberByKey("LHSAMP",S_Value),NumberByKey("RHSAMP",S_Value)] dave,$chan,DataSamp
End

Function WM_WFStyleProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Chart davechart,lineMode(0)= popNum-1
End

Function WM_WFCheckInvalid()
	FIFOStatus/Q dave
	if( V_Flag==0 )
		return 1
	endif
	return NumberByKey("VALID",S_Info)==0
end

Function WM_WFAutoscaleBProc(ctrlName) : ButtonControl
	String ctrlName
	
	if( WM_WFCheckInvalid() )
		return 0
	endif

	ControlInfo davechart
	String chan= StringByKey("CHNAME0",S_Value)
	Make/O astemp
	FIFO2Wave/S=3/R=[NumberByKey("LHSAMP",S_Value),NumberByKey("RHSAMP",S_Value)] dave,$chan,astemp
	WaveStats/Q astemp
	KillWaves astemp

	FIFOStatus/Q dave
	Variable plusFS= NumberByKey("FSPLUS0",S_Info)
	Variable minusFS= NumberByKey("FSMINUS0",S_Info)
	chart davechart,offset(0)= (V_min+V_max)/2 - (plusFS+minusFS)/2
	chart davechart,gain(0)=(plusFS-minusFS)/(V_max-V_min)
End

