#pragma rtGlobals=2		// Use modern global access method.
#pragma version=1.02
#include <Strings As Lists>

// 1.02: removed minor use of | as comment

Menu "Macros"
	"Bivariate Histogram", MakeBiHistPanel()
end

Proc MakeBiHistPanel()

	if (wintype("BiHistPanel") != 7)
		String SavedFolder=GetDataFolder(1)
		SetDataFolder root:
	
		if (DataFolderExists("WinGlobals") == 0)
			NewDataFolder/S WinGlobals
		else
			SetDataFolder WinGlobals
		endif
		if (DataFolderExists("BiHistPanel") == 0)
			NewDataFolder/S BiHistPanel
		else
			SetDataFolder BiHistPanel
		endif
		String/G csrgraph=""
		BiHistPanel()
		
		SetDataFolder $SavedFolder
	else
		DoWindow/F BiHistPanel
	endif
end
	

Function BiHist(tinfo)
	String tinfo
	
	tinfo= ";"+tinfo
	
	String s= ";GRAPH:"
	Variable p0= StrSearch(tinfo,s,0),p1
	if( p0 < 0 )
		return 0
	endif
	p0 += strlen(s)
	p1= StrSearch(tinfo,";",p0)
	String gname= tinfo[p0,p1-1]
	String thedf= "root:WinGlobals:"+gname
	if( !DataFolderExists(thedf) )
		return 0
	endif
	
	s= ";TNAME:BiHistHairY"
	p0= StrSearch(tinfo,s,0)
	if( p0 < 0 )
		return 0
	endif
	p0 += strlen(s)
	p1= StrSearch(tinfo,";",p0)
	Variable n= str2num(tinfo[p0,p1-1])
	
	String dfSav= GetDataFolder(1)
	SetDataFolder thedf
	
	Variable/C offsetc=getoffset(tinfo, gname)

	DoHist(gname, real(offsetc), imag(offsetc))
	
	SetDataFolder dfSav
end

Function/C GetOffset(tinfo, gname)
	String tinfo, gname
	
	Variable XisLog=0
	String AInfoStr=AxisInfo(gname, "bottom")
	if (strsearch(AInfoStr, "log(x)=1", 0) >= 0)		//horizontal axis is log
		XisLog=1
	endif
	Variable YisLog=0
	AInfoStr=AxisInfo(gname, "left")
	if (strsearch(AInfoStr, "log(x)=1", 0) >= 0)		//vertical axis is log
		YisLog=1
	endif

	Variable Dum
	Variable HairX
	Variable HairY
	string s= "XOFFSET:"
	Variable p0=  StrSearch(tinfo,s,0)
	Variable p1
	if( p0 >= 0 )
		p0 += strlen(s)
		p1= StrSearch(tinfo,";",p0)
		Dum=str2num(tinfo[p0,p1-1])
		if (XisLog)
			GetAxis/Q bottom
			HairX=10^((Dum/(V_max-V_min))*(log(V_max/V_min)))
		else
			HairX=Dum
		endif
	endif
	
	s= "YOFFSET:"
	p0=  StrSearch(tinfo,s,0)
	if( p0 >= 0 )
		p0 += strlen(s)
		p1= StrSearch(tinfo,";",p0)
		Dum=str2num(tinfo[p0,p1-1])
		if (XisLog)
			GetAxis/Q left
			HairY=10^((Dum/(V_max-V_min))*(log(V_max/V_min)))
		else
			HairY=Dum
		endif
	endif
	
	return cmplx(HairX, HairY)
	//end JW mods
end	

Function DoHist(gname, HairX, HairY)
	String gname
	Variable HairX, HairY
	String tname=TraceNameList(gname, ";", 1)
	Variable p1= StrSearch(tname,";",0)
	if( p1 > 1 )
		tname= tname[0,p1-1]
		WAVE/Z XWave = XWaveRefFromTrace(gname, tname)
		Wave YWave = TraceNameToWaveRef(gname, tname)
		Variable hasXWave = WaveExists(XWave)
		Variable npnts=numpnts(YWave)
		Variable Xval
		Variable i=0
		Variable/G Q0=0, Q1=0,Q2=0,Q3=0
		do
			if (hasXWave)
				Xval=XWave[i]
			else
				Xval = pnt2x(YWave, i)
			endif
			if (Xval<HairX)
				if (YWave[i] < HairY)		//Quadrant 0
					Q0 += 1
				else							//Quadrant 2
					Q2 += 1
				endif
			else
				if (YWave[i] < HairY)		//Quadrant 1
					Q1 += 1
				else							//Quadrant 3
					Q3 += 1
				endif
			endif
			i += 1
		while(i<npnts)
	endif
end	


Window BiHistPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel/K=1 /W=(219,54,467,266) as "Bivariate Histogram"
	SetDrawLayer UserBack
	SetDrawEnv fname= "Geneva"
	DrawText 13,48,"Cursor:"
	SetDrawEnv fname= "Geneva"
	DrawText 13,28,"Graph"
	DrawText 13,73,"Counts:"
	DrawText 14,122,"Graph Annotations:"
	DrawText 13,165,"Extract Subset:"
	Button Set0,pos={61,32},size={29,17},proc=BiHistSetButton,title="Set"
	Button Remove0,pos={93,32},size={29,17},proc=BiHistRemoveButton,title="Rm"
	SetVariable setvarGrf0,pos={58,15},size={76,12},title=" ",fSize=9
	SetVariable setvarGrf0,limits={0,0,0},value= root:WinGlobals:BiHistPanel:csrgraph
	ValDisplay valdispQ0,pos={57,86},size={77,12},fSize=9
	ValDisplay valdispQ0,limits={0,0,0},barmisc={0,1000}
	ValDisplay valdispQ0,value= #"No Value"
	ValDisplay valdispQ1,pos={138,86},size={77,12},fSize=9
	ValDisplay valdispQ1,limits={0,0,0},barmisc={0,1000}
	ValDisplay valdispQ1,value= #"No Value"
	ValDisplay valdispQ2,pos={57,71},size={77,12},fSize=9
	ValDisplay valdispQ2,limits={0,0,0},barmisc={0,1000}
	ValDisplay valdispQ2,value= #"No Value"
	ValDisplay valdispQ3,pos={138,71},size={77,12},fSize=9
	ValDisplay valdispQ3,limits={0,0,0},barmisc={0,1000}
	ValDisplay valdispQ3,value= #"No Value"
	Button BiHistAnnoSet,pos={61,126},size={58,17},proc=BiHistAddAnno,title="Create"
	Button BiHistAnnoRemove,pos={126,126},size={57,17},proc=BiHistRemAnno,title="Remove"
	Button DupUL,pos={62,165},size={29,17},proc=ExtractSubsetButton,title="UL"
	Button DupUR,pos={93,165},size={29,17},proc=ExtractSubsetButton,title="UR"
	Button DupLL,pos={62,184},size={29,17},proc=ExtractSubsetButton,title="LL"
	Button DupLR,pos={93,184},size={29,17},proc=ExtractSubsetButton,title="LR"
	SetWindow BiHistPanel, hook=BiHistPanelWindowHook
	BiHistPanelWindowHook("EVENT:Activate")
EndMacro

Function BiHistAddHairCursor()
	
	String dfSav= GetDataFolder(1)
	String wname= WinName(0, 1)
	
	if( strlen(wname) == 0 )
		Abort "no target graph"
	endif
	
	NewDataFolder/O/S root:WinGlobals:$wname
	
	String/G root:WinGlobals:BiHistPanel:csrgraph= wname
	
	Variable xm=0,ym=0
	
	String yw= "BiHistHairY",xw= "BiHistHairX"
	String AInfoStr=AxisInfo(wname, "left")
	Variable YisLog = strsearch(AInfoStr, "log(x)=1", 0) >= 0
	if (YisLog)		//vertical axis is log
		Make/O $yw={1,1,1,NaN,inf,1,0}
		ym = 1
	else	
		Make/O $yw={0,0,0,NaN,Inf,0,-Inf}
		ym = 0
	endif
	AInfoStr=AxisInfo(wname, "bottom")
	Variable XisLog = strsearch(AInfoStr, "log(x)=1", 0) >= 0
	if (XisLog)		//horixontal axis is log
		Make/O $xw={inf,1,0,NaN,1,1,1}
		xm = 1
	else	
		Make/O $xw={Inf,0,-Inf,NaN,0,0,0}
		xm = 0
	endif
	//end JW mods
	
	Variable x0,x1,y0,y1
	GetAxis/Q left; y0= V_min; y1= V_max
	GetAxis/Q bottom; x0= V_min; x1= V_max
	if (YisLog)
		SetAxis left, y0,y1
	endif
	if (XisLog)
		SetAxis bottom,x0,x1
	endif
	
	CheckDisplayed $yw
	Variable notup= V_Flag == 0
	if( notup )
		AppendToGraph $yw vs $xw
		ModifyGraph quickdrag($yw)=1,live($yw)=1
		ModifyGraph rgb($yw)=(0,0,65534)	// blue
	else
		Variable/C xy= GetWaveOffset($yw)
		xm= real(xy)
		ym= imag(xy)
	endif
	
	if (XisLog)
		xm=10^((xm/(x1-x0))*(log(x1/x0)))
	endif
	if (YisLog)
		ym=10^((ym/(y1-y0))*(log(y1/y0)))
	endif

	if( notup || (xm < min(x0,x1)) || (xm > max(x0,x1)) )
		if (XisLog)
			xm = x0*sqrt(x1/x0)
		else
			xm= x0+(x1-x0)*0.5
		endif
	endif
	if( notup || (ym < min(y0,y1)) || (ym > max(y0,y1)) )
		if (YisLog)
			ym = y0*sqrt(y1/y0)
		else
			ym= y0+(y1-y0)*0.5
		endif
	endif
	
	DoHist(wname, xm, ym)
	Variable/G $"X0"= xm
	Variable/G $"Y0"= ym

	if (XisLog)
		xm = (log(xm)/log(x1/x0))*(x1-x0)
	endif
	if (YisLog)
		ym = (log(ym)/log(y1/y0))*(y1-y0)
	endif
	
	String GlobName="root:WinGlobals:"+wname+":"
	String VarName=GlobName+"Q0"
	Variable/G $VarName
	Execute "ValDisplay valdispQ0,value= "+VarName
	VarName=GlobName+"Q1"
	Variable/G $VarName
	Execute "ValDisplay valdispQ1,value= "+VarName
	VarName=GlobName+"Q2"
	Variable/G $VarName
	Execute "ValDisplay valdispQ2,value= "+VarName
	VarName=GlobName+"Q3"
	Variable/G $VarName
	Execute "ValDisplay valdispQ3,value= "+VarName

	ModifyGraph offset($yw)={xm,ym}
	if (notup)
		ModifyGraph quickdrag($yw)=1,live($yw)=1
		ModifyGraph rgb($yw)=(0,0,65534)	// blue
	endif

	String/G S_TraceOffsetInfo
	Variable/G hairTrigger
	SetFormula hairTrigger,"BiHist(S_TraceOffsetInfo)"
	
	NVAR Q0=Q0
	NVAR Q1=Q1
	NVAR Q2=Q2
	NVAR Q3=Q3
	
	ControlUpdate/W=BiHistPanel/A
	
	SetDataFolder dfSav
end

Function BiHistPanelWindowHook(infoStr)
	String infoStr
	
	String event= StringByKey("EVENT",infoStr)
	if (CmpStr(event, "Activate") == 0)
		String topGraph = WinName(0, 1)
		SVAR csrgraph = root:WinGlobals:BiHistPanel:csrgraph
		if (CmpStr(csrgraph, topGraph) != 0)
			if (DatafolderExists("root:WinGlobals:"+topGraph))
				BiHistAddHairCursor()		// If cursor already exists, simply adjusts the control panel
			endif
		endif
	endif
end

Function BiHistSetButton(ctrlName) : ButtonControl
	String ctrlName
	
		BiHistAddHairCursor()
End

Function BiHistRemoveButton(ctrlName) : ButtonControl
	String ctrlName
	
	CheckDisplayed TraceNameToWaveRef("", "BiHistHairY")
	if( V_Flag != 0 )
		RemoveFromGraph $"BiHistHairY"
		String Folder = "root:WinGlobals:"+PossiblyQuoteName(WinName(0,1))
		KillDatafolder $Folder
	endif
End

Function BiHistAddAnno(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR win=root:WinGlobals:BiHistPanel:csrgraph
	String topWin = WinName(0,1)
	
	if (Exists("root:WinGlobals:"+topWin+":Q0") != 2)
		abort "You must create a cross-hair cursor on the graph before making the annotations"
	else
		Textbox/N=BiHistQ0Text/A=LB "\\{root:WinGlobals:"+topWin+":Q0}"
		Textbox/N=BiHistQ1Text/A=RB "\\{root:WinGlobals:"+topWin+":Q1}"
		Textbox/N=BiHistQ2Text/A=LT "\\{root:WinGlobals:"+topWin+":Q2}"
		Textbox/N=BiHistQ3Text/A=RT "\\{root:WinGlobals:"+topWin+":Q3}"
	endif
End

Function BiHistRemAnno(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR/Z win=root:WinGlobals:BiHistPanel:csrgraph
	if (!SVAR_Exists(win))
		return 0
	endif
	
	Textbox/W=$win/N=BiHistQ0Text/K
	Textbox/W=$win/N=BiHistQ1Text/K
	Textbox/W=$win/N=BiHistQ2Text/K
	Textbox/W=$win/N=BiHistQ3Text/K
End

// returns offset of given wave (assumed to be in top graph)
// xoffset is real part, yoffset is imaginary part
Function/C GetWaveOffset(w)
	Wave w
	
	String s= TraceInfo("",NameOfWave (w),0)
	if( strlen(s) == 0 )
		return NaN
	endif
	String subs= "offset(x)={"
	Variable v1= StrSearch(s,subs,0)
	if( v1 == -1 )
		return NaN
	endif
	v1 += strlen(subs)
	Variable xoff= str2num(s[v1,1e6])
	v1= StrSearch(s,",",v1)
	Variable yoff= str2num(s[v1+1,1e6])
	return cmplx(xoff,yoff)
end

Function ExtractSubsetButton(ctrlName) : ButtonControl
	String ctrlName
	
	Variable SubNumPnts
	Variable DoQuad
	Variable i, subP
	
	SVAR gname=root:WinGlobals:BiHistPanel:csrgraph
	String dfSav= GetDataFolder(1)
//	SetDataFolder 	root:WinGlobals:$gname

	SVAR tinfo=root:WinGlobals:$(gname):S_TraceOffsetInfo
	if (strlen(tinfo) == 0)
		abort "There is no cross hair information for this graph"
	endif
	
	NVAR Q0=root:WinGlobals:$(gname):Q0	
	NVAR Q1=root:WinGlobals:$(gname):Q1
	NVAR Q2=root:WinGlobals:$(gname):Q2
	NVAR Q3=root:WinGlobals:$(gname):Q3
	
	String suffix
	if (cmpstr(ctrlName, "DupUL") == 0)
		SubNumPnts= Q2
		DoQuad=3
		suffix = "_UL"
	endif
	if (cmpstr(ctrlName, "DupUR") == 0)
		SubNumPnts= Q3
		DoQuad=4
		suffix = "_UR"
	endif
	if (cmpstr(ctrlName, "DupLL") == 0)
		SubNumPnts= Q0
		DoQuad=1
		suffix = "_LL"
	endif
	if (cmpstr(ctrlName, "DupLR") == 0)
		SubNumPnts= Q1
		DoQuad=2
		suffix = "_LR"
	endif
	
	Variable/C offsetC=GetOffset(tinfo, gname)
	String tname=GetTraceName(gname)
	WAVE/Z XWave = XWaveRefFromTrace(gname, tname)
	Wave YWave = TraceNameToWaveRef(gname, tname)
	Variable hasXWave = WaveExists(XWave)
	
	Make/O/D/N=(SubNumPnts)/O $(gname+suffix)
	WAVE SubSet = $(gname+suffix)
	if (HasXWave)
		Make/O/D/N=(SubNumPnts)/O $(gname+suffix+"X")
		WAVE SubSetX = $(gname+suffix+"X")
	endif
	
	Duplicate/O YWave,TempWave
	Wave TW=TempWave
		
	if (hasXWave)
		if (DoQuad == 1)
			TW=(YWave[p]  < imag(offsetc))&& (XWave[p] < real(offsetc))
		endif
		if (DoQuad == 2)
			TW=(YWave[p]  < imag(offsetc)) && (XWave[p] > real(offsetc))
		endif
		if (DoQuad == 3)
			TW=(YWave[p]  > imag(offsetc)) && (XWave[p] < real(offsetc))
		endif
		if (DoQuad == 4)
			TW=(YWave[p]  > imag(offsetc)) && (XWave[p] > real(offsetc))
		endif
		i = 0
		subP=0
		do
			if (TW[i] == 1)
				SubSet[subP] = YWave[i]
				SubSetX[subP] = XWave[i]
				subP += 1
			endif
			i += 1
		while (i < numpnts(TW))
	else
		if (DoQuad == 1)
			TW=(YWave[p]  < imag(offsetc)) && (pnt2x(YWave, p) < real(offsetc))
		endif
		if (DoQuad == 2)
			TW=(YWave[p]  < imag(offsetc)) && (pnt2x(YWave, p) > real(offsetc))
		endif
		if (DoQuad == 3)
			TW=(YWave[p]  > imag(offsetc)) && (pnt2x(YWave, p) < real(offsetc))
		endif
		if (DoQuad == 4)
			TW=(YWave[p]  > imag(offsetc)) && (pnt2x(YWave, p) > real(offsetc))
		endif
		i = 0
		subP=0
		do
			if (TW[i] == 1)
				SubSet[subP] = YWave[i]
				subP += 1
			endif
			i += 1
		while (i < SubNumPnts)
	endif
	
	KillWaves/Z TW
	SetDataFolder $dfSav
End

Function/S GetTraceName(gname)
	String gname
	
	String tname=TraceNameList(gname, ";", 1)
	Variable p1= StrSearch(tname,";",0)
	if( p1 > 1 )
		tname= tname[0,p1-1]
	else
		tname = ""
	endif
	
	return tname
end
