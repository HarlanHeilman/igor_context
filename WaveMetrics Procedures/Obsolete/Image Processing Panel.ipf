// This package creates a control panel that makes it easy to perform common
// image processing techniques such as gaussian blur and edge finding.


#pragma rtGlobals=1


Macro CreateImageProcessingPanel()
	String dfSav= GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S WMImProcess
	Variable/G size=3,passesNxN=1,passes3x3=1
	SetDataFolder dfSav
	
	WMImageProcessingPanel()
end


// This routine is used to fetch a full path to the image wave in the top
// graph. A zero length string is returned if failure.
//
Function/S WMGetImageWave()
	String s= ImageNameList("", ";")
	Variable p1= StrSearch(s,";",0)
	if( p1<0 )
		return ""			// no image in top graph
	endif
	s= s[0,p1-1]
	Wave w= ImageNameToWaveRef("", s)
	return GetWavesDataFolder(w,2)		// full path to wave including name
end

// This routine makes backups of the data in the same data folder as
// the source wave. If a wave of the same name but with the suffex _Back
// does NOT exist then the source is duplicated as such a name. This wave
// is used for the restore button.
// The source wave is always duplicated as a wave with the suffex _UnDo
// which is used by the Undo button.
//
Function WMSaveWaveBackups(w)
	Wave w

	String s= GetWavesDataFolder(w,1)
	String dfSav= GetDataFolder(1)
	SetDataFolder s
	String bakName= NameOfWave(w)+"_Back"
	if( exists(bakName) != 1 )
		Duplicate/O w,$bakName
	endif
	Duplicate/O w,$(NameOfWave(w)+"_UnDo")
	SetDataFolder dfSav
end

// This routine restores wave w from backups that have been saved using WMSaveWaveBackups
// It can also delete the backups depending on kind:
// use -1 to kill backups, use 0 to restore from _UnDo, 1 to restore from _Back
// Returns 0 if success, 1 if backups did not exist and tried restore or undo
// When doing a restore the current data is stored in _UnDo so you can undo a restore
//
Function WMRestoreWaveBackups(w,kind)
	Wave w
	Variable kind

	variable fail= 1

	String s= GetWavesDataFolder(w,1)
	String dfSav= GetDataFolder(1)
	SetDataFolder s

	String bakName= NameOfWave(w)+"_Back"
	String undoName= NameOfWave(w)+"_UnDo"

	do
		if( kind == -1 )
			KillWaves/Z $bakName,$undoName		// don't care if they existed or not
			fail= 0
			break
		endif
		if( kind == 0 )
			if( exists(undoName) == 1 )
				NewDataFolder rwtmp	// tmp wave may or may not be created here
				Duplicate/O $undoName,:rwtmp:tmpw
				Duplicate/O w,$undoName
				Duplicate/O :rwtmp:tmpw,w
				KillDataFolder rwtmp
				fail= 0
			endif
		else // must be 1
			if( exists(bakName) == 1 )
				Duplicate/O w,$undoName
				Duplicate/O $bakName,w
				fail= 0
			endif
		endif
	while(0)
	SetDataFolder dfSav
	return fail
end


Function WMBPNxNDoIt(ctrlName) : ButtonControl
	String ctrlName

	String pw= WMGetImageWave()
	Wave/Z w= $pw
	if( !WaveExists(w) )
		beep
		return 0
	endif

	if( CmpStr("NxNDoIt",ctrlName) == 0 )
		ControlInfo popNxN
		NVAR passesNxN= root:Packages:WMImProcess:passesNxN
	else
		ControlInfo pop3x3
		NVAR passesNxN= root:Packages:WMImProcess:passes3x3
	endif

	String keyword= S_value
	if( CmpStr(keyword,"NaNZapMedian") == 0 )
		if( (WaveType(w) %& (2+4) ) == 0 )
			Abort "Integer image has no NANs to zap!"
			return 0
		endif
	endif
	WMSaveWaveBackups(w)
	NVAR size= root:Packages:WMImProcess:size
	MatrixFilter/N=(size)/P=(passesNxN) $keyword, w
End


Function/S WMLoadKernel()
	String rval= ""
	
	String dfSav=GetDataFolder(1)
	SetDataFolder WMGetSetKernelDFVariable("")
	NewDataFolder/S lktmp
	LoadWave/G/M/A=kernel
	Wave/Z w= kernel0
	if( WaveExists(w) )
		rval= CleanupName(S_fileName, 1)
		Duplicate/O w,::$rval
	endif
	KillDataFolder :
	SetDataFolder dfSav
	return rval
end

Function WMBPLoadKernel(ctrlName) : ButtonControl
	String ctrlName
	
	String s= WMLoadKernel()
end

		

Function WMBPConvDoIt(ctrlName) : ButtonControl
	String ctrlName

	String pw= WMGetImageWave()
	Wave/Z w= $pw
	if( !WaveExists(w) )
		beep
		return 0
	endif
	ControlInfo popConvSrc
	String kwName= S_value

	String dfSav=GetDataFolder(1)
	SetDataFolder WMGetSetKernelDFVariable("")
	Wave/Z kw= $kwName
	SetDataFolder dfSav
	if( !WaveExists(kw) )
		Abort "No kernel wave selected"
		return 0
	endif
	WMSaveWaveBackups(w)
	MatrixConvolve kw, w
End


Function WMBPUndo(ctrlName) : ButtonControl
	String ctrlName

	String pw= WMGetImageWave()
	Wave/Z w= $pw
	Variable haveImage= WaveExists(w)

	variable fail= 1
	do
		if( CmpStr(ctrlName,"buttonUndo") == 0 )
			if( !haveImage )
				beep;	return 0
			endif
			fail= WMRestoreWaveBackups(w,0)
			break
		endif
		if( CmpStr(ctrlName,"buttonRestore") == 0 )
			if( !haveImage )
				beep;	return 0
			endif
			fail=WMRestoreWaveBackups(w,1)
			break
		endif
		if( CmpStr(ctrlName,"buttonDone") == 0 )
			fail= 0
			if( haveImage )
				DoAlert 2,"Delete backups?"
				if( V_Flag == 3 )								// cancel button
					break;
				endif
				if( V_Flag == 1 )
					WMRestoreWaveBackups(w,-1)
				endif
			endif
			Execute/P/Q "DoWindow/K "+WinName(0, 64)				// this be us
			KillDataFolder/Z root:Packages:WMImProcess:
			break
		endif
	while(0)
	if( fail )
		Print "no backup waves found"
		beep
	endif
End

Function WMWithin(a,b,c)
	variable a,b,c
	
	if( a < b )
		return 0
	endif
	if( a > c )
		return 0
	endif
	return 1
end

// WMGetSetKernelDFVariable is a bottleneck proc that
// manages a global string variable in this package that contains the data folder
// in which convolution kernels looked for and loaded. If newDF is not zero length then
// it is taken to be the new path. The value of the variable is returned.
//
Function/S WMGetSetKernelDFVariable(newDF)
	String newDF
	
	String kdfpath= "root:Packages:WMImProcess:kerneldf"	// this should be the only place this literal path is needed
	if( exists(kdfpath) == 0 )
		String/G $kdfpath= GetDataFolder(1)	// first time, set to current DF
	endif
	SVAR kerneldf= $kdfpath
	
	if( strlen(newDF) != 0 )
		kerneldf= newDF
	endif
	
	if( !DataFolderExists(kerneldf) )
		kerneldf= GetDataFolder(1)
		Print "Saved kernel data folder path no longer valid; reset to current data folder"
	endif

	return kerneldf
end




Function/S WMGetKernelWaveList()
	String dfSav=GetDataFolder(1)
	SetDataFolder WMGetSetKernelDFVariable("")

	String s=""
	Variable i=0
	do
		Wave/Z w= WaveRefIndexed("", i, 4)
		if( !WaveExists(w) )
			break
		endif
		if( WaveType(w)!=0 )
			if( WMWithin(DimSize(w,0),3,51) %& WMWithin(DimSize(w,1),3,51) %& (DimSize(w,2) == 0 ) )
				s += NameOfWave(w)+";"
			endif
		endif
		i+=1
	while(1)
	SetDataFolder dfSav
	return s
end




Function/S WMGetKernelDataFolderPopList()
	String dfSav=GetDataFolder(1)
	String kdfpath=  WMGetSetKernelDFVariable("")
	SetDataFolder kdfpath

	String s= ""
	if( CmpStr(kdfpath,"root:") == 0 )
		s= "\\M1(No parent;-;"
	else
		SetDataFolder ::
		s= GetDataFolder(0)+";-;"		// looks like we need a GetDataFolderParent function
		SetDataFolder kdfpath
	endif
	s += GetDataFolder(0)+";-;"
	Variable i=0
	do
		String df= GetIndexedObjName(":", 4, i)
		if( strlen(df)==0 )
			break
		endif
		s += df+";"
		i+=1
	while(1)
	SetDataFolder dfSav
	return s+"-;Set to Current Data Folder"
end

Function WMPopProcSetDF(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String dfSav=GetDataFolder(1)
	SetDataFolder  WMGetSetKernelDFVariable("")
	
	do
		if( popNum==1 )
			SetDataFolder ::		// set to parent
			WMGetSetKernelDFVariable( GetDataFolder(1) )
			break
		endif
		if( popNum== 3 )
			break // do nothing
		endif
		if( CmpStr(popStr,"Set to Current Data Folder")==0 )
			WMGetSetKernelDFVariable( dfSav )
			break
		endif
		SetDataFolder $popStr
		WMGetSetKernelDFVariable(  GetDataFolder(1) )
	while(0)
	SetDataFolder dfSav
	PopupMenu popKDF,mode=3
End

 
// commenting is removed during development
Proc WMImageProcessingPanel()
//Panel0()
//end
//
//Window Panel0() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(347,56,657,298)
	SetDrawLayer UserBack
	SetDrawEnv fillpat= 0
	DrawRRect 284,196,12,144
	SetDrawEnv fillpat= 0
	DrawRRect 284,83,12,15
	SetDrawEnv textxjust= 2
	DrawText 96,34,"NxN Filter:"
	SetDrawEnv fillpat= 0
	DrawRRect 284,138,12,89
	SetDrawEnv textxjust= 2
	DrawText 95,109,"3x3 Filter:"
	SetDrawEnv textxjust= 2
	DrawText 83,165,"Kernel:"
	SetDrawEnv textxjust= 2
	DrawText 140,188,"DF:"
	PopupMenu popNxN,pos={100,18},size={73,19}
	PopupMenu popNxN,mode=1,popvalue="median",value= #"\"median;avg;gauss;min;max;NaNZapMedian;\""
	SetVariable size,pos={74,42},size={70,17},format="%d"
	SetVariable size,limits={3,101,2},value= root:Packages:WMImProcess:size
	SetVariable pasesNxN,pos={58,64},size={115,17},title="passes"
	SetVariable pasesNxN,limits={0,100,1},value= root:Packages:WMImProcess:passesNxN
	Button NxNDoIt,pos={223,40},size={50,20},proc=WMBPNxNDoIt,title="Do It"
	PopupMenu Pop3x3,pos={101,93},size={89,19}
	PopupMenu Pop3x3,mode=1,popvalue="FindEdges",value= #"\"FindEdges;Point;Sharpen;SharpenMore;gradN;gradNW;gradW;gradSW;gradS;gradSE;gradE;gradNE\""
	SetVariable pases3x3,pos={56,119},size={115,17},title="passes"
	SetVariable pases3x3,limits={0,100,1},value= root:Packages:WMImProcess:passes3x3
	Button DoIt3x3,pos={223,101},size={50,20},proc=WMBPNxNDoIt,title="Do It"
	PopupMenu popConvSrc,pos={85,149},size={19,19}
	PopupMenu popConvSrc,mode=1,popvalue="",value= #"WMGetKernelWaveList()"
	Button DoItConv,pos={223,147},size={50,20},proc=WMBPConvDoIt,title="Do It"
	Button buttonUndo,pos={35,208},size={50,20},proc=WMBPUndo,title="Undo"
	Button buttonRestore,pos={89,208},size={66,20},proc=WMBPUndo,title="Restore"
	Button buttonDone,pos={229,208},size={50,20},proc=WMBPUndo,title="Done"
	Button buttonLoadK,pos={42,172},size={60,20},proc=WMBPLoadKernel,title="Load..."
	PopupMenu popKDF,pos={142,172},size={52,19},proc=WMPopProcSetDF
	PopupMenu popKDF,mode=3,popvalue="root",value= #"WMGetKernelDataFolderPopList()"
EndMacro
