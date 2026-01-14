#pragma rtGlobals=2
#include <Image Common>

// Image Grayscale Filters Package
// Version 1.0, LH971209
// This package creates a control panel that makes it easy to perform common
// image processing techniques such as gaussian blur and edge finding.
//
// Create user interface window by calling the following from a button or a menu:
// WMCreateImageFilterPanel()
 // 22JUN06 cleaned up panel and added Print commands.


Function WMBPNxNDoIt(ctrlName) : ButtonControl
	String ctrlName

	String ImGrfName= WMTopImageGraph()
	String pw= WMGetImageWave(ImGrfName)
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
	String cmd
	
	ImageGenerateROIMask/W=$ImGrfName $NameOfWave(w)
	if( V_FLag )
		MatrixFilter/R=M_ROIMask/N=(size)/P=(passesNxN) $keyword, w
		sprintf cmd,"MatrixFilter/R=M_ROIMask/N=(%g)/P=%d %s %s", size,passesNxN,keyword,NameOfWave(w)
		KillWaves M_ROIMask
	else
		MatrixFilter/N=(size)/P=(passesNxN) $keyword, w
		sprintf cmd,"MatrixFilter/N=(%g)/P=%d %s %s", size,passesNxN,keyword,NameOfWave(w)
	endif
	
	ControlInfo/W=WMImageFilterPanel IPFCheck0
	if(V_Value)
		print cmd
	endif
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

Function grayFilterHelp(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic "MatrixFilter"
End

		

Function WMBPConvDoIt(ctrlName) : ButtonControl
	String ctrlName

	String ImGrfName= WMTopImageGraph()
	String pw= WMGetImageWave(ImGrfName)
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
	
	ImageGenerateROIMask/W=$ImGrfName $NameOfWave(w)
	if( V_FLag )
		MatrixConvolve/R=M_ROIMask kw, w
		KillWaves M_ROIMask
	else
		MatrixConvolve kw, w
	endif
End

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


Function WMCreateImageFilterPanel()

	if(isColorImage())
		return 0;
	endif
	DoWindow/F WMImageFilterPanel
	if( V_Flag==1 )
		return 0
	endif

	String dfSav= GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S WMImProcess
	if( NumVarOrDefault("size",-1) == -1 )				// check if this is the very first time
		Variable/G size=3,passesNxN=1,passes3x3=1
	endif
	SetDataFolder dfSav

	NewPanel /K=1 /W=(202,381,528,661) as "Filters"
	DoWindow/C WMImageFilterPanel						// 10JAN02
	ModifyPanel fixedSize=1
	SetDrawLayer UserBack
	SetDrawEnv fillpat= 0,textxjust= 2
	SetDrawEnv save
	DrawText 96,33,"NxN Filter:"
	DrawText 95,114,"3x3 Filter:"
	DrawText 78,173,"Kernel:"
	DrawText 126,203,"DF:"
	PopupMenu popNxN,pos={100,17},size={70,20}
	PopupMenu popNxN,mode=1,popvalue="median",value= #"\"median;avg;gauss;min;max;NaNZapMedian;\""
	SetVariable size,pos={66,45},size={90,15},title="Size:",format="%d"
	SetVariable size,limits={3,100,2},value= root:Packages:WMImProcess:size
	SetVariable pasesNxN,pos={47,67},size={109,15},title="passes:"
	SetVariable pasesNxN,limits={0,100,1},value= root:Packages:WMImProcess:passesNxN
	Button NxNDoIt,pos={223,40},size={50,20},proc=WMBPNxNDoIt,title="Do It"
	PopupMenu Pop3x3,pos={101,98},size={86,20}
	PopupMenu Pop3x3,mode=1,popvalue="FindEdges",value= #"\"FindEdges;Point;Sharpen;SharpenMore;gradN;gradNW;gradW;gradSW;gradS;gradSE;gradE;gradNE\""
	SetVariable pases3x3,pos={95,127},size={90,15},title="passes:"
	SetVariable pases3x3,limits={0,100,1},value= root:Packages:WMImProcess:passes3x3
	Button DoIt3x3,pos={223,101},size={50,20},proc=WMBPNxNDoIt,title="Do It"
	PopupMenu popConvSrc,pos={90,156},size={43,20}
	PopupMenu popConvSrc,mode=1,popvalue="dd",value= #"WMGetKernelWaveList()"
	Button DoItConv,pos={223,172},size={50,20},proc=WMBPConvDoIt,title="Do It"
	Button buttonUndo,pos={110,247},size={81,20},proc=WMImageBPUndo,title="Undo"
	Button buttonUndo,help={"Reverts the image to its values prior to the last operation."}
	Button buttonRestore,pos={208,247},size={82,20},proc=WMImageBPUndo,title="Restore"
	Button buttonRestore,help={"Takes you back to the first image on which you performed an operation."}
	Button buttonLoadK,pos={36,186},size={60,20},proc=WMBPLoadKernel,title="Load..."
	Button buttonLoadK,help={"Load NIH Image style convolution kernels."}
	PopupMenu popKDF,pos={129,186},size={50,20},proc=WMPopProcSetDF
	PopupMenu popKDF,help={"Choose here the data folder where the convolution kernel is stored."}
	PopupMenu popKDF,mode=3,popvalue="root",value= #"WMGetKernelDataFolderPopList()"
	Button grayFilterHelpBut,pos={34,247},size={50,20},proc=grayFilterHelp,title="Help"
	GroupBox ipfGroup0,pos={21,8},size={275,81}
	GroupBox ipfGroup1,pos={21,93},size={275,126}
	CheckBox IPFCheck0,pos={34,224},size={91,14},title="Print Commands",value= 0
	String  ImGrfName= WMTopImageGraph()
	AutoPositionWindow/E/M=1/R=$ImGrfName
End


