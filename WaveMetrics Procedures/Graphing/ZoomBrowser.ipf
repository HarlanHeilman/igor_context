#pragma rtGlobals=2		// force new syntax
#pragma ModuleName= WMZoomBrowser

// ZoomBrowser version 0.9, LH060816
// Provides easy visual access to sets of  axis range and cursor settings.
//
// Possible todo:
// allow name entry for snapshot and show in title area above snapshot (use dimension label?)
// better way to view and  possibly edit commands



Menu "Graph"
	"ZoomBrowser",/Q,WMZoomBrowser#AddZoomBrowserPanel()
End
Static Function  AddZoomBrowserPanel()
	String targ= WinName(0,1,1)
	if( strlen(targ)==0 )
		return -1
	endif
	
	DoWindow/W=$targ#ZoomBrowser dummy
	if( V_Flag )
		return -2		// already present
	endif
	
	String dfSave= GetDataFolder(1)
	NewDataFolder/S/O root:Packages
	NewDataFolder/O/S WMZoomBrowser

	// note: we store the name of the data folder containing info for this graph's browser as named user data in order to allow the
	// graph name to be changed without getting in trouble
	String dfName= GetUserData(targ,"","WMZoomBrowser")
	if( !DataFolderExists(dfName) )
		dfName= ""		// someone deleted our data
	endif
	
	if( strlen(dfName) != 0 )
		SetDataFolder $dfName
	else
		dfName= targ						// initial try
		if( DataFolderExists(dfName) )
			dfName= UniqueName(dfName, 11, 0)
		endif
		NewDataFolder/O/S $dfName
		SetWindow $targ,userdata(WMZoomBrowser )=dfName
	endif


	WAVE/Z/T wGrafZoomList,wGrafZoomCmds
	
	if( !WAVEExists(wGrafZoomList) )
		Make/O/T/N=0 wGrafZoomList,wGrafZoomCmds
		String/G gBaseGraphName= targ
	else
		SVAR gBaseGraphName
		if( cmpstr(gBaseGraphName,targ) != 0 )
			HandleGraphNameChange(gBaseGraphName,targ,wGrafZoomCmds)
		endif
		gBaseGraphName= targ
	endif
	
	NewPanel/HOST=$targ/EXT=0/W=(0,200,200,0)
	RenameWindow #,ZoomBrowser
	
	GetWindow kwTopWin,wsizeDC
	
	Variable width= V_right,height= V_bottom
	variable buttonsHeight= 60
	
	
	ListBox list0,pos={10,10},size={width-20,height-10-buttonsHeight},proc=WMZoomBrowser#list0Proc
	ListBox list0,listWave=wGrafZoomList,mode= 1,special= {3,0,0}

	Variable bx= width/2 - 130/2

	Button bSnap,pos={bx,height-buttonsHeight+5},size={130,23},proc=WMZoomBrowser#bAddSnapProc,title="Add snapshot"
	Button bRemoveSnap,pos={bx,height-buttonsHeight+5+23+5},size={130,23},proc=WMZoomBrowser#bRemoveSnapProc,title="Remove snapshot"

	PopupMenu pm,pos={5,height-25},size={20,20},proc=WMZoomBrowser#zbPopProc
	PopupMenu pm,mode=0,value= #"\"Instructions...;Remove\""


	
	SetDataFolder dfSave

	SetWindow kwTopWin,hook(default )=WMZoomBrowser#zbWinProc
	SetActiveSubwindow ##
EndMacro


Static Function list0Proc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba
	
	String targ= StringFromList(0, lba.win,"#")		// name of host graph
	String dfName= GetUserData(targ,"","WMZoomBrowser")

	switch( lba.eventCode )
		case 1: // mouse down
			if( lba.eventMod & 0x4 )		// option (alt) key down?
				WAVE/T w=root:Packages:WMZoomBrowser:$(dfName):wGrafZoomCmds
				Print w[lba.row]
			endif
			break
		case 3: // double click
			WAVE/T w=root:Packages:WMZoomBrowser:$(dfName):wGrafZoomCmds
			PossiblyHandleGraphNameChange(targ,dfName,w)
			Execute w[lba.row]
			break
	endswitch

	return 0
End

Static Function zbWinProc(s)
	STRUCT WMWinHookStruct &s
	
	if( s.eventCode == 6 )			// resize

		Variable width= s.winRect.right,height= s.winRect.bottom
		variable buttonsHeight= 60
		
		ListBox list0,size={width-20,height-10-buttonsHeight},win= $s.winName
	
		Variable bx= width/2 - 130/2
	
		Button bSnap,pos={bx,height-buttonsHeight+5},win= $s.winName
		Button bRemoveSnap,pos={bx,height-buttonsHeight+5+23+5},win= $s.winName
		PopupMenu pm,pos={5,height-25},win= $s.winName
	endif

	return 0		// 0 if nothing done, else 1
End




Static Function zbPopProc(s) : PopupMenuControl
	STRUCT WMPopupAction &s

	String dfSav,grfName
	
	StrSwitch(s.popStr)
		case "Instructions...":
			ShowZoomBrowserInstructions()
			break
		case "Remove":
			dfSav= GetDataFolder(1)

			String targ= StringFromList(0, s.win,"#")
			String dfName= GetUserData(targ,"","WMZoomBrowser")
			
			KillWindow $s.win

			SetDataFolder root:Packages:WMZoomBrowser:$(dfName)

			KillDataFolder :
			if( CountObjects(":",4) == 0 )
				KillDataFolder :
				Execute/P "DELETEINCLUDE  <ZoomBrowser>"
				Execute/P "COMPILEPROCEDURES "
			endif
			SetDataFolder dfSav
			break
	endswitch
End


Static Function bAddSnapProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			String targ= StringFromList(0, ba.win,"#")
			String dfName= GetUserData(targ,"","WMZoomBrowser")


			WAVE/T wp=root:Packages:WMZoomBrowser:$(dfName):wGrafZoomList
			WAVE/T wc=root:Packages:WMZoomBrowser:$(dfName):wGrafZoomCmds
			
			PossiblyHandleGraphNameChange(targ,dfName,wc)

			Variable np= numpnts(wp)
			SavePICT/E=-5/B=72/W=(0,0,200,200)/SNAP/WIN=$targ as "_string_"
			wp[np]= {S_Value}		// Why curly braces? To automatically create new points.
			wc[np]= {CreateZoomSetMacro(targ)}
			ListBox list0,win=$ba.win,selRow=np
			break
	endswitch

	return 0
End


Static Function bRemoveSnapProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			String targ= StringFromList(0, ba.win,"#")
			String dfName= GetUserData(targ,"","WMZoomBrowser")

			WAVE/T wp=root:Packages:WMZoomBrowser:$(dfName):wGrafZoomList
			WAVE/T wc=root:Packages:WMZoomBrowser:$(dfName):wGrafZoomCmds
			
			PossiblyHandleGraphNameChange(targ,dfName,wc)

			Variable np= numpnts(wp)
			ControlInfo/W=$ba.win list0
			DeletePoints V_Value,1,wp,wc
			if( V_Value == (np-1) )
				ListBox list0,win=$ba.win,selRow=np-2
			endif
			break
	endswitch

	return 0
End




Static Function/S CreateZoomSetCmds(gname)
	String gname		// base graph name
	
	String mstr= ""	
	
	String axList= AxisList(gname)
	Variable i
	
	for(i=0;;i+=1)
		String aname= StringFromList(i,axList)
		if( strlen(aname) == 0 )
			break
		endif
		String ainfo= AxisInfo(gname,aname)
		String cmd= StringByKey("SETAXISCMD",ainfo)
		cmd[7]="/W="+gname+" "		// 7 is strlen of SetAxis, space is to allow search for "/W=name " when base graph name is changed
		mstr= mstr+"\t"+cmd+"\r"
	endfor
	
	String csr= CsrInfo(A,gname)
	if( strlen(csr) != 0 )
		mstr +=  "\t"+StringByKey("RECREATION",csr)+"\r"
	else
		mstr += "\tCursor/W="+gname+"/K A\r"
	endif
	csr= CsrInfo(B,gname)
	if( strlen(csr) != 0 )
		mstr +=  "\t"+StringByKey("RECREATION",csr)+"\r"
	else
		mstr += "\tCursor/W="+gname+" /K B\r"		// space after gname is to allow search for "/W=name " when base graph name is changed
	endif
	
	String clist= ChildWindowList(gname)
	for(i=0;;i+=1)
		String cname= StringFromList(i,clist)
		if( strlen(cname) == 0 )
			break
		endif
		if( WinType(gname+"#"+cname) == 1 )		// graphs only (or should panels be examined for subgraphs?)
			mstr += CreateZoomSetCmds(gname+"#"+cname)
		endif
	endfor
	return mstr
End





Static Function/S CreateZoomSetMacro(gname)
	String gname		// base graph name
	
	String mstr= "Macro junk()\r"		// a start
	
	mstr += CreateZoomSetCmds(gname)
	
	mstr += "EndMacro\r"
	
	return mstr
End


Static Function HandleGraphNameChange(prevName,newName,cw)
	String prevName,newName
	WAVE/T cw
	
	Variable i,np= numpnts(cw)
	String pw= "/W="+prevName
	String nw= "/W="+newName
	
	for(i=0;i<np;i+=1)
		String c= cw[i]
		c= ReplaceString(pw+" ",c,nw+" ")		// note space char to make search more reliable
		c= ReplaceString(pw+"#",c,nw+"#")
		cw[i]= c
	endfor
End

Static Function PossiblyHandleGraphNameChange(targ,dfName,wc)
	String targ, dfName
	WAVE/T wc

	SVAR prevName= root:Packages:WMZoomBrowser:$(dfName):gBaseGraphName
	if( cmpstr(prevName,targ) != 0 )
		HandleGraphNameChange(prevName,targ,wc)
		prevName= targ
	endif
End

Static Function ShowZoomBrowserInstructions()
	String nb = "ZoomBrowserInstructions"
	DoWindow/F $nb
	if( V_Flag )
		return 0
	endif
	NewNotebook/N=$nb/F=1/V=1/K=1/W=(62,103,583,484)
	Notebook $nb defaultTab=36, statusWidth=238, pageMargins={72,72,72,72}
	Notebook $nb showRuler=0, rulerUnits=1, updating={1, 216000}
	Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,0,(0,0,0)}
	Notebook $nb ruler=Normal; Notebook $nb  justification=1, fStyle=1, text="ZoomBrowser Tips\r"
	Notebook $nb ruler=Normal, fStyle=-1, text="\r"
	Notebook $nb text="The ZoomBrowser can assisit in examining a large data set by allowing you to easilly save and restore axis range and cursor settings.\r"
	Notebook $nb text="\r"
	Notebook $nb text="Click add snapshot to store the current axis range and cursor data. \r"
	Notebook $nb text="\r"
	Notebook $nb text="To return to a previous zoom/cursor state, double click on a snapshot.\r"
	Notebook $nb text="\r"
	Notebook $nb text="To print the commands that would be executed on a double click, alt (option) click on a snapshot.\r"
	Notebook $nb text="\r"
	Notebook $nb text="If you close the browser via its close icon, you can bring it back unchanged by choosing ZoomBrowser from the Graph menu. But if "
	Notebook $nb text="you choose remove from the popup menu, the data will be discarded and, if no other graphs are using the browser, the package will be unloaded."
End