#pragma rtGlobals=2		// Use modern logic ops

// Waterfall.ipf
// Provides user interface for NewWaterfall and ModifyWaterfall
// Version 1.0, LH000403



Static Function init()
	String dfSav= GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:WM_Waterfall
	
	Make/O/T wlist= {""}
	String/G title=""
	String/G modInfo="Target: none"
	Variable/G angle= 10
	Variable/G hidden=1
	Variable/G axlen=0.5
	Variable/G wfInited= 1
	
	String/G baseName="wave0"		// used for data tab
	
	SetDataFolder dfSav
end

// Call when target graph may have changed
Static Function UpdateWFProps()
	NVAR angle= root:Packages:WM_Waterfall:angle
	NVAR axlen= root:Packages:WM_Waterfall:axlen
	NVAR hidden= root:Packages:WM_Waterfall:hidden
	SVAR modInfo= root:Packages:WM_Waterfall:modInfo
	
	Variable tangle=angle,taxlen=axlen,thidden=hidden
	String grfName
	Variable didit= GetWaterfallStuff(tangle,taxlen,thidden,grfName)	// all pass-by-reference
	
	if( didit )
		angle= tangle
		axlen= taxlen
		hidden= thidden
		modInfo= "Target: "+grfName
		
		ControlInfo hidePop
		if( V_value != (hidden+1) )
			PopupMenu hidePop,mode= hidden+1
		endif
	else
		modInfo= "Target: \\K(65535,0,0)NONE"
	endif
	ControlInfo tc
	if( V_Value==1 )
		Button bDoIt,win=WM_NewWaterfallPanel ,disable=2
		Button bPrint,win=WM_NewWaterfallPanel ,disable=2
	endif
end

// Call when modify pane is active to update doit button
Static Function EnableModifyDoit()
	Variable ok=  StrLen( GenModifyWaterfall() ) != 0
	Button bDoIt ,disable=ok ? 0 : 2
	Button bPrint,disable=ok ? 0 : 2
end



Function WM_WF_TabProc(name,tab)
	String name
	Variable tab
	
	ListBox lb1,disable= (tab!=0)
	PopupMenu xwPop,disable= (tab!=0)
	PopupMenu ywPop,disable= (tab!=0)
	SetVariable setvar0,disable= (tab!=0)
	SetVariable angVar,disable= (tab!=1)
	SetVariable alenVar,disable= (tab!=1)
	PopupMenu hidePop,disable= (tab!=1)
	TitleBox tb,disable= (tab!=1)
	GroupBox dataGB1,disable= (tab!=2)
	SetVariable bnSetVar,disable= (tab!=2)
	Button merge,disable= (tab!=2)
	GroupBox dataGB2,disable= (tab!=2)
	PopupMenu testDataPop,disable= (tab!=2)
	Button CreateHlp,disable= (tab!=2)
	if( tab==0 )
		UpdateNewWF()
	elseif( tab==1 )
		EnableModifyDoit()
	elseif( tab==2 )
		Button bDoIt ,disable=1
		Button bPrint,disable=1
	endif
end

Function WM_fNewWaterfallPanel(pane)
	Variable pane							// desired pane number (0=New, 1=Modify)
	DoWindow/F WM_NewWaterfallPanel
	if( V_Flag )
		return 0
	endif
	
	if( NumVarOrDefault("root:Packages:WM_Waterfall:wfInited",0) == 0 )
		init()
	endif
	
	NewPanel /K=1 /W=(304,140,572,393) as "New Waterfall"
	DoWindow/C WM_NewWaterfallPanel
	ModifyPanel fixedSize=1

	ListBox lb1,pos={28,40},size={200,80},proc=WM_WF_NewListboxProc
	ListBox lb1,listWave=root:Packages:WM_Waterfall:wlist,mode= 1,selRow= 0
	Button bDoIt,pos={32,220},size={50,20},proc=WM_WF_ButtonProc,title="Do It"
	Button bPrint,pos={120,220},size={71,20},proc=WM_WF_ButtonProc,title="Print Cmd"
	PopupMenu xwPop,pos={46,124},size={120,20},proc=WM_WF_NewPopMenuProc,title="x:"
	PopupMenu xwPop,mode=1,popvalue="_calculated_",value= #"WM_WF_XYList(1)"
	PopupMenu ywPop,pos={46,147},size={120,20},proc=WM_WF_NewPopMenuProc,title="y:"
	PopupMenu ywPop,mode=1,popvalue="_calculated_",value= #"WM_WF_XYList(0)"
	SetVariable setvar0,pos={35,175},size={178,15},title="title:"
	SetVariable setvar0,limits={-Inf,Inf,1},value= root:Packages:WM_Waterfall:title
	TabControl tc,pos={11,7},size={235,192},proc=WM_WF_TabProc,tabLabel(0)="New"
	TabControl tc,tabLabel(1)="Modify",tabLabel(2)="Data",value= 0
	SetVariable angVar,pos={79,79},size={83,15},disable=1,proc=WM_WF_ModifySetVarProc,title="Angle"
	SetVariable angVar,format="%.1f"
	SetVariable angVar,limits={10,90,1},value= root:Packages:WM_Waterfall:angle,bodyWidth= 50
	SetVariable alenVar,pos={50,106},size={112,15},disable=1,proc=WM_WF_ModifySetVarProc,title="Axis Length"
	SetVariable alenVar,format="%.2f"
	SetVariable alenVar,limits={0.1,0.9,0.05},value= root:Packages:WM_Waterfall:axlen,bodyWidth= 50
	PopupMenu hidePop,pos={47,132},size={122,20},disable=1,proc=WM_WF_ModifyPopMenuProc,title="Hidden lines:"
	PopupMenu hidePop,mode=3,popvalue="True",value= #"\"Off;Painter;True;No bottom;Color bottom\""
	TitleBox tb,pos={26,36},size={79,20},disable=1,frame=4
	TitleBox tb,variable= root:Packages:WM_Waterfall:modInfo
	SetVariable bnSetVar,pos={29,60},size={155,15},disable=1,title="Start Name:"
	SetVariable bnSetVar,limits={-Inf,Inf,1},value= root:Packages:WM_Waterfall:baseName
	GroupBox dataGB1,pos={21,41},size={215,82},disable=1,title="Merge 1D waves"
	Button merge,pos={34,88},size={50,20},disable=1,title="Merge",proc=WM_WF_DataProc
	GroupBox dataGB2,pos={23,148},size={211,41},title="Create Test Data"
	PopupMenu testDataPop,pos={73,163},size={69,20},proc=WM_WF_CreatePopMenuProc,title="Create"
	PopupMenu testDataPop,mode=0,value= #"\"Vector set wave0;Vector set wave00;Matrix Single Peak;Matrix Peak Group\""
	Button CreateHlp,pos={194,164},size={23,18},proc=WM_WF_TestDataHelpButtonProc,title="?"

	fillWFList()
	DoUpdate
	SetWindow WM_NewWaterfallPanel, hook= WM_WF_NewHook
	TabControl tc,value= pane
	WM_WF_TabProc("doesn't matter",pane)
	UpdateWFProps()
end

Function WM_WF_ModifyPopMenuProc(ctrlName,popNum,popStr)
	String ctrlName
	Variable popNum
	String popStr

	NVAR hidden= root:Packages:WM_Waterfall:hidden
	hidden= popNum-1
	EnableModifyDoit()
end
	
Function WM_WF_ModifySetVarProc (ctrlName,varNum,varStr,varName)
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable

	EnableModifyDoit()
End


Function WM_WF_NewPopMenuProc(ctrlName,popNum,popStr)
	String ctrlName
	Variable popNum
	String popStr

	// nothing to do unless we want to have a command line display
End

Function/T WM_WF_XYList(isX)
	Variable isX

	String s= "_calculated_"
	ControlInfo/W=WM_NewWaterfallPanel lb1
	WAVE/T lw= root:Packages:WM_Waterfall:wlist
	
	Variable dis= (V_Value >= DimSize(lw,0)) || StrLen(lw[V_Value])<=0
	if( !dis )
		WAVE ww= $lw[V_Value]
		Variable i=0
		do
			WAVE/Z w= WaveRefIndexed("",i,4)					// get i'th wave in current data folder
			if( WaveExists(w)==0 )
				break
			endif
			if( WaveType(w)!=0 && (WaveType(w)&1)==0 && DimSize(w,1)==0 )		// Only real numeric 1D waves, please.
				if( (isX && DimSize(w,0)==DimSize(ww,0)) || (isX==0 && DimSize(w,0)==DimSize(ww,1)) )
					s += ";"+ NameOfWave(w)
				endif
			endif
			i += 1
		while(1)
	endif
	return s
End


Function WM_WF_NewListboxProc(ctrlName,row,col,event)
	String ctrlName		// name of this control
	Variable row		// row if click in interior, -1 if click in title
	Variable col			// column number
	Variable event		// event code
	
	if( event==4 )
		PopupMenu xwPop,value=#"WM_WF_XYList(1)"
		PopupMenu ywPop,value=#"WM_WF_XYList(0)"
		UpdateNewWF()
	endif
	return 0            // other return values reserved
End

Function WM_WF_NewHook(infoStr)
	String infoStr

	String event= StringByKey("EVENT",infoStr)
	if( CmpStr(event,"activate") == 0 )
		fillWFList()
		ControlInfo tc
		if( V_Value == 0 )
			UpdateNewWF()
		endif
		UpdateWFProps()
	endif
	if( CmpStr(event,"kill") == 0 )
// NOTE: originally, I asked the user if the package should be deleted. But then decided there was little reason to not delete.
//		DoAlert 1,"Delete entire waterfall package?"
//		if( V_Flag==1 )
			Execute/P "KillDataFolder  root:Packages:WM_Waterfall"
			Execute/P "DELETEINCLUDE <Waterfall>"
			Execute/P "COMPILEPROCEDURES "
//		endif
	endif
	return 0
end

Static Function UpdateNewWF()
	ControlInfo/W=WM_NewWaterfallPanel lb1
	WAVE/T lw= root:Packages:WM_Waterfall:wlist
	
	Variable dis= (V_Value >= DimSize(lw,0)) || StrLen(lw[V_Value])<=0
	Button bDoIt,win=WM_NewWaterfallPanel ,disable=dis ? 2 : 0
	Button bPrint,win=WM_NewWaterfallPanel ,disable=dis ? 2 : 0
end
		


// NOTE: this will not be called unless conditions are valid
Function WM_WF_ButtonProc(ctrlName)
	String ctrlName
	
	String cmd

	ControlInfo tc
	if( V_Value==0 )
		WAVE/T lw= root:Packages:WM_Waterfall:wlist
		ControlInfo lb1
		cmd= "NewWaterfall "+PossiblyQuoteName(lw[V_Value])
		
		ControlInfo xwPop
		String sx= S_value
		if( strlen(sx)==0 || CmpStr(sx,"_calculated_")==0 )
			sx= "*"
		else
			sx= PossiblyQuoteName(sx)
		endif
		ControlInfo ywPop
		String sy= S_value
		if( strlen(sy)==0 || CmpStr(sy,"_calculated_")==0 )
			sy= "*"
		else
			sy= PossiblyQuoteName(sy)
		endif
		if( CmpStr(sx,"*")!=0 || CmpStr(sy,"*")!=0 )
			cmd += " vs {"+sx+","+sy+"}"
		endif
		
		SVAR title=  root:Packages:WM_Waterfall:title
		if( strlen(title) != 0 )
			cmd += " as \""+title+"\""
		endif
	elseif( V_Value==1 )
		cmd= GenModifyWaterfall()
	endif
	
	if( CmpStr(ctrlName,"bDoIt") == 0 )
		Execute/P cmd
	else
		Print cmd
	endif
	
	// After a ModifyWaterfall, disable buttons until change is made
	ControlInfo tc
	if( V_Value==1 )
		Button bDoIt,win=WM_NewWaterfallPanel ,disable=2
		Button bPrint,win=WM_NewWaterfallPanel ,disable=2
	endif
End

Static Function/T GenModifyWaterfall()
	String cmd= "ModifyWaterfall "
	String s1=""
	Variable haveChanges= 0

	NVAR angle= root:Packages:WM_Waterfall:angle
	NVAR axlen= root:Packages:WM_Waterfall:axlen
	NVAR hidden= root:Packages:WM_Waterfall:hidden
	
	Variable tangle=angle,taxlen=axlen,thidden=hidden
	String grfName
	Variable didit= GetWaterfallStuff(tangle,taxlen,thidden,grfName)	// all pass-by-reference
	
	if( !didit )
		return ""
	endif
	
	if( tangle != angle )
		sprintf s1,"angle= %.2g",angle
		cmd += s1
		haveChanges= 1
	endif
	if( taxlen != axlen )
		sprintf s1,"axlen= %.3g",axlen
		if( haveChanges )
			cmd += ","
		endif
		cmd += s1
		haveChanges= 1
	endif
	if( thidden != hidden )
		sprintf s1,"hidden= %d",hidden
		if( haveChanges )
			cmd += ","
		endif
		cmd += s1
		haveChanges= 1
	endif
	if( haveChanges )
		return cmd
	else
		return ""
	endif
end
			


Static Function fillWFList()
	String dfSav= GetDataFolder(1)
	SetDataFolder root:Packages:WM_Waterfall
	WAVE/T wlist
	
	Make/O/T newWlist= {""}
	SetDataFolder dfSav
	
	Variable i=0,j=0
	do
		WAVE/Z w= WaveRefIndexed("",i,4)					// get i'th wave in current data folder
		if( WaveExists(w)==0 )
			break
		endif
		if( WaveType(w)!=0 && (WaveType(w)&1)==0 && DimSize(w,1) != 0 && DimSize(w,2)==0 )		// Only real numeric 2D waves, please.
			ReDimension/N=(j+1) newWlist
			newWlist[j]= NameOfWave(w)
			j += 1
		endif
		i += 1
	while(1)
	
	Variable different= 0
	if( DimSize(wlist,0) != j )
		different= 1
	else
		for(i=0;i<j;i+=1)
			if( CmpStr(wlist[i],newWlist[i]) != 0 )
				different= 1
				break
			endif
		endfor
	endif
	
	if( different )
		Duplicate/T/O newWlist,wlist
	endif
	return different
end


Static Function GetWaterfallStuff(angle,axlen,hidden,grfName)
	Variable &angle,&axlen,&hidden
	String &grfName
	
	String wname= WinName(0, 1)					// top graph
	String s= WinRecreation(wname,0)
	
	Variable p0= StrSearch(s,"ModifyWaterfall",0)		// ex. ModifyWaterfall angle=30, axlen= 0.3, hidden= 0
	
	if( p0 <=0 )
		return 0			// Top graph is not a waterfall plot
	endif
	
	grfName= wname
	
	Variable p1= StrSearch(s,"\r",p0)
	
	s= s[p0,p1]			// isolate the single line ModifyWaterfall command
	
	String key
	
	key= "angle="
	p0=  StrSearch(s,key,0)
	if( p0 >0 )
		angle= str2num(s[p0+strlen(key),inf])
	endif

	key= "axlen="
	p0=  StrSearch(s,key,0)
	if( p0 >0 )
		axlen= str2num(s[p0+strlen(key),inf])
	endif

	key= "hidden="
	p0=  StrSearch(s,key,0)
	if( p0 >0 )
		hidden= str2num(s[p0+strlen(key),inf])
	endif
	
	return 1
end


Function WM_WF_DataProc(ctrlName)
	String ctrlName

	SVAR baseName= root:Packages:WM_Waterfall:baseName
	
	String errStr=""

	Variable err= CreateMatrixFromVects(baseName,errStr)
	if( err )
		ShowErrorDialog("\\K(65535,0,0)Merge Error: \\K(0,0,0)\r"+errStr)
	endif
end

// Given the name of the first wave in a naming sequence with incrementing digit suffexes
// creates a matrix  named with _M replacing the digits of the first name.
// Merged waves are moved into a new data folder named with _DF suffex.
Static Function CreateMatrixFromVects(firstName,errStr)
	String firstName,&errStr
	
	if( !WaveExists($firstName) )
		errStr= "First Name must be name of existing wave."
		return -1						// ERROR EXIT
	endif
	
	Variable bnLen= strlen(firstName)
	Variable digit
	Variable ndigits					// number of digits on the firstName

	for(ndigits= 0;;ndigits += 1)
		digit=  char2num(firstName[bnLen-1-ndigits])
		if( digit<0x30 || digit>0x39 )
			break
		endif
	endfor
	if( ndigits==0 )
		errStr= "First Name must have digits as suffex."
		return -2						// ERROR EXIT
	endif

	bnLen -= ndigits
	String wName, baseName= firstName[0,bnLen-1]
	
	Variable i,startNum= str2num(firstName[bnLen,bnLen+ndigits-1])
	
	Duplicate/O $firstName,$(baseName+"_M")
	WAVE mOut= $(baseName+"_M")
	
	NewDataFolder/O $(baseName+"_DF")
	String df= ":"+PossiblyQuoteName(baseName+"_DF")+":"

	MoveWave $firstName,$df
	
	for(i=startNum+1;;i+=1)
		sprintf wName,"%s%0*d",baseName,ndigits,i
		WAVE/Z w= $wName
		if( !WaveExists(w) )
			break
		endif
		Variable col=i- startNum
		Redimension/N=(-1,col+1) mOut
		mOut[][col]= w[p]
		MoveWave w,$df
	endfor

	fillWFList()		// make New tab show our new wave
	
	return 0
end

// 	PopupMenu testDataPop,mode=0,value= #"\"Vector set wave0;Vector set wave00;Matrix Single Peak;Matrix Peak Group\""

Function WM_WF_CreatePopMenuProc(ctrlName,popNum,popStr)
	String ctrlName
	Variable popNum
	String popStr
	
	Variable i,imax=50
	String sname

	NewDataFolder/O/S root:WF_TestData
	if( popNum==1 || popNum==2 )
		if( DataFolderExists("wave_DF") )
			KillDataFolder wave_DF
		endif
		for(i=0;i<imax;i+=1)
			if( popNum==1 )
				sprintf sname,"wave%d",i
			else
				sprintf sname,"wave%02d",i
			endif
			Make/O $sname=exp(-((imax/2 -i)/20)^2)* exp(-((x-20-i)/10)^2)
		endfor
	elseif( popNum==3 )
		Make/O/N=(200,30) jack;SetScale x,-3,4,jack;SetScale y,-2,3,jack
		jack=exp(-((x-y)^2+(x+3+y)^2))
	elseif( popNum==4 )
		Make/O/N=(200,30) fred;SetScale x,-3,4,fred;SetScale y,-2,3,fred
		fred=exp(-60*(x-1*y)^2)+exp(-60*(x-0.5*y)^2)+exp(-60*(x-2*y)^2)+exp(-60*(x+1*y)^2)+exp(-60*(x+2*y)^2)
	endif
	fillWFList()		// make New tab show our new wave
End


Function ShowErrorDialog(errStr)
	String errStr

	NewPanel /K=1 /W=(304,140,572,393) as "Merge Error"
	DoWindow/C WM_MergeError
	
	String/G root:Packages:meTmp= errStr
	TitleBox tb,pos={10,10},variable=  root:Packages:meTmp,frame=4
	Button bhelp,pos={32,220},size={50,20},proc=WM_WF_MergeErrHelpProc,title="Help"
	
	PauseForUser WM_MergeError
	KillStrings root:Packages:meTmp
end

Function WM_WF_MergeErrHelpProc(ctrlName)
	String ctrlName

	String nb = "MergeErrorHelp"
	NewNotebook/N=$nb/F=1/V=1/K=1/W=(100,100,500,300) as "Merge Error Help"
	Notebook $nb defaultTab=36, statusWidth=238, pageMargins={72,72,72,72}
	Notebook $nb showRuler=0, rulerUnits=1, updating={1, 60}
	Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,0,(0,0,0)}
	Notebook $nb ruler=Normal; Notebook $nb  margins={0,0,360}
	Notebook $nb text="Merge 1D waves assumes you have a set of waves with incrementing numeric suffexes. For example, wave0 wa"
	Notebook $nb text="ve1 wave2 or wave00 wave01 wave02 etc.\r"
	Notebook $nb text="\r"
	Notebook $nb text="Waves in a set are merged into a single matrix where each column in the matrix is a wave from the set. T"
	Notebook $nb text="he matrix is named by appending a suffex of _M to the base (or common) portion of the name of the set. T"
	Notebook $nb text="he original waves are moved into a data folder named by appending _DF to the base name.\r"
	Notebook $nb text="\r"
	Notebook $nb text="After the merge, you may not need the original waves. If so, you can use the Data Browser (Data Menu) to"
	Notebook $nb text=" delete the _DF data folder.\r"
	
	DoWindow/K WM_MergeError
end


Function WM_WF_TestDataHelpButtonProc(ctrlName)
	String ctrlName
	
	DoWindow/F CreateTestDataHelp
	if( V_Flag )
		return 0
	endif

	String nb = "CreateTestDataHelp"
	NewNotebook/N=$nb/F=1/V=1/K=1/W=(116,425,516,625) as "Create Test Data Help"
	Notebook $nb defaultTab=36, statusWidth=238, pageMargins={72,72,72,72}
	Notebook $nb showRuler=0, rulerUnits=1, updating={1, 3600}
	Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,0,(0,0,0)}
	Notebook $nb ruler=Normal; Notebook $nb  margins={0,0,360}
	Notebook $nb text="The first two methods in the Create popup menu create a sequence of waves that can be used as input to M"
	Notebook $nb text="erge 1D waves. Both sequences are the same except for the wave suffex technique. After creating the sequ"
	Notebook $nb text="ence, enter either wave0 or wave00 into the Start Name field and then click the Merge button. Switch to "
	Notebook $nb text="the 'New\" Tab and choose wave_M in the list.\r"
	Notebook $nb text="\r"
	Notebook $nb text="The other methods generate matrices directly. You can go straight to the 'New' Tab to create a waterfall"
	Notebook $nb text=". "

End

