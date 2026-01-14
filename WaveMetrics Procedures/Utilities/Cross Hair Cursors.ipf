#pragma TextEncoding = "UTF-8"
#pragma rtGlobals= 1
#pragma version=1.1 // z from contour plot if no image.
#include <Keyword-Value>

//	Cross hair Cursor package for IPro 3.13
//	Documentation is in the Cross Hair Cursor Demo example experiment
//	Version 1.1
//	Filename: Cross Hair Cursors
//	Changes since version 1.0: 
//		Try to guess the proper pair of axes for the crosshair waves rather than just defaulting
//		to left, bottom.




Macro HairlineCursor()
	DoWindow/F HairlineCursorPanel
	if( V_Flag )
		return
	endif
	
	NewDataFolder/O root:WinGlobals
	NewDataFolder/O root:WinGlobals:HairlineCursorPanel
	Variable/G root:WinGlobals:HairlineCursorPanel:curXtra=2
	String/G root:WinGlobals:HairlineCursorPanel:csrgraph0="<no value>"
	String/G root:WinGlobals:HairlineCursorPanel:csrgraph1="<no value>"
	String/G root:WinGlobals:HairlineCursorPanel:csrgraphn="<no value>"
	String/G root:WinGlobals:HairlineCursorPanel:expression="X1-X0"
	HairlineCursorPanel()
end


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


Function AddHairCursor(n)
	Variable n
	
	String dfSav= GetDataFolder(1)
	String wname= WinName(0, 1)
	
	if( strlen(wname) == 0 )
		Abort "no target graph"
	endif
	
	NewDataFolder/O/S root:WinGlobals:$wname
	
	String/G root:WinGlobals:HairlineCursorPanel:$"csrgraph"+num2istr(n)= wname
	
	Variable xm=0,ym=0
	
	String yw= "HairY"+num2istr(n),xw= "HairX"+num2istr(n)
	String xaxname="bottom",yaxname= "left",tinfo=""
	Make/O $yw={0,0,0,NaN,Inf,0,-Inf}
	Make/O $xw={-Inf,0,Inf,NaN,0,0,0}
	CheckDisplayed $yw
	Variable notup= V_Flag == 0
	if( notup )
		// Try to determine which axes to use by first checking for images, then contours
		String axinfo=" ",stmp= StringFromList(0,ImageNameList("",";"))
		if( StrLen(stmp) != 0 )
			tinfo= ImageInfo("", stmp, 0)
		else
			stmp= StringFromList(0,ContourNameList("",";"))
			if( StrLen(stmp) != 0 )
				tinfo= ContourInfo("", stmp, 0)
			else
				stmp= StringFromList(0,TraceNameList("",";",1))
				if( StrLen(stmp) != 0 )
					tinfo= TraceInfo("", stmp, 0)
				endif
			endif
		endif
		if( StrLen(tinfo) != 0 )
			axinfo= StrByKey("AXISFLAGS",tinfo)+" "
		endif

		Execute "AppendToGraph"+axinfo+yw+" vs "+xw
		ModifyGraph quickdrag($yw)=1,live($yw)=1
		if( n==0 )
			ModifyGraph rgb($yw)=(0,0,65534)	// blue
		endif
		if( n==1 )
			ModifyGraph rgb($yw)=(0,65534,0)	// green
		endif
		if( n>1 )
			ModifyGraph rgb($yw)=(0,0,0)		// black
		endif
	else
		Variable/C xy= GetWaveOffset($yw)
		xm= real(xy)
		ym= imag(xy)
		tinfo=  TraceInfo("", yw, 0)
	endif

	if( StrLen(tinfo) != 0 )
		xaxname=  StrByKey("XAXIS",tinfo)
		yaxname=  StrByKey("YAXIS",tinfo)
	endif

	Variable x0,x1,y0,y1
	GetAxis/Q $yaxname; y0= V_min; y1= V_max
	GetAxis/Q $xaxname; x0= V_min; x1= V_max
	if( notup %| (xm < min(x0,x1)) %| (xm > max(x0,x1)) )
		xm= x0+(x1-x0)*(1+min(n,4))/5
	endif
	if( notup %| (ym < min(y0,y1)) %| (ym > max(y0,y1)) )
		ym= y0+(y1-y0)*(1+min(n,4))/5
	endif
	

	ModifyGraph offset($yw)={xm,ym}
	
	Variable/G $"X"+num2istr(n)= xm
	Variable/G $"Y"+num2istr(n)= ym
	CreateUpdateZ("",n)

	String/G S_TraceOffsetInfo
	Variable/G hairTrigger
	SetFormula hairTrigger,"UpdateHairGlobals(S_TraceOffsetInfo)"
	
	SetDataFolder dfSav
end

Function UpdateHairGlobals(tinfo)
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
	
	s= ";TNAME:HairY"
	p0= StrSearch(tinfo,s,0)
	if( p0 < 0 )
		return 0
	endif
	p0 += strlen(s)
	p1= StrSearch(tinfo,";",p0)
	Variable n= str2num(tinfo[p0,p1-1])
	
	String dfSav= GetDataFolder(1)
	SetDataFolder thedf
	
	s= "XOFFSET:"
	p0=  StrSearch(tinfo,s,0)
	if( p0 >= 0 )
		p0 += strlen(s)
		p1= StrSearch(tinfo,";",p0)
		Variable/G $"X"+num2str(n)=str2num(tinfo[p0,p1-1])
	endif
	
	s= "YOFFSET:"
	p0=  StrSearch(tinfo,s,0)
	if( p0 >= 0 )
		p0 += strlen(s)
		p1= StrSearch(tinfo,";",p0)
		Variable/G $"Y"+num2str(n)=str2num(tinfo[p0,p1-1])
	endif
	
	CreateUpdateZ(gname,n)
	
	SetDataFolder dfSav
end

// this is intended to be called with DF set to loc of globals
Function CreateUpdateZ(gname,n)
	String gname					// the graph name (empty or cur graph)
	Variable n
	
	NVAR gXn= $"X"+num2str(n)
	NVAR gYn= $"Y"+num2str(n)
	
	
	Variable Xn=gXn,Yn=gYn,Xp,Yp
	
	String iname= ImageNameList(gname, ";")
	Variable p1= StrSearch(iname,";",0)
	if( p1 > 1 )
		iname= iname[0,p1-1]
		WAVE/Z w= ImageNameToWaveRef(gname, iname)
		if( WaveExists(w) )
			String info= ";"+ImageInfo(gname, iname, 0)
			WAVE/Z xw= $GetWavePathFromImageInfo("X",info)
			WAVE/Z yw= $GetWavePathFromImageInfo("Y",info)
			if( WaveExists(xw) )
				Xp= BinarySearchInterp(xw,Xn)
				Xn= pnt2x(w, Xp)
			endif
			if( WaveExists(yw) )
				Yp= BinarySearchInterp(yw,Yn)
				Yn= DimOffset(w, 1) + Yp *DimDelta(w,1)
			endif
			Variable/G $"Z"+num2str(n)= w(Xn)(Yn)
		endif
	else // version 1.1
		iname= ContourNameList(gname, ";")
		p1= StrSearch(iname,";",0)
		if( p1 > 1 )
			iname= iname[0,p1-1]
			Variable/G $"Z"+num2str(n)= ContourZ(gname,iname,0,Xn,Yn)
		endif
	endif
end	

Function/S GetWavePathFromImageInfo(pre,info)
	String pre,info
	
	String wname= StrByKey(";"+pre+"WAVE",info)
	String wpath= StrByKey(";"+pre+"WAVEDF",info)
	
	return wpath+PossiblyQuoteName(wname)
end

Function UpdateCursorReadout(n)
	Variable n

	String df= "root:WinGlobals:"+WinName(0, 1)+":"
	String suf= num2str(n)
	if( n>1 )
		suf= "n"
	endif
	String xval= df+"X"+num2str(n)
	if( Exists(xval) != 2 )
		xval= "#\"no value\""
	endif
	String yval= df+"Y"+num2str(n)
	if( Exists(yval) != 2 )
		yval= "#\"no value\""
	endif
	String zval= df+"Z"+num2str(n)
	if( Exists(zval) != 2 )
		zval= "#\"no value\""
	endif
	
	Execute "ValDisplay valdispX"+suf+",value="+xval
	Execute "ValDisplay valdispY"+suf+",value="+yval
	Execute "ValDisplay valdispZ"+suf+",value="+zval
	
	if( n>=2 )
		String/G root:WinGlobals:HairlineCursorPanel:csrgraphn="<no value>"
		SetFormula root:WinGlobals:HairlineCursorPanel:csrgraphn,"csrgraph"+num2str(n)
	endif
end

Function UpdateCursorDeltas()
	String dimletter= "XYZ"
	Variable i=0
	do
		String basename= "valdisp"+dimletter[i]
		ControlInfo $basename+"0"
		Variable x0valid= V_Flag==4
		String x0expr= "not valid"
		if( x0valid )
			x0expr= S_value
		endif
	
		ControlInfo $basename+"1"
		Variable x1valid= V_Flag==4
		String x1expr= "not valid"
		if( x1valid )
			x1expr= S_value
		endif
		
		String dxexpr= "#\"no value\""
		if( x0valid %& x1valid )
			dxexpr= x1expr+"-"+x0expr
		endif
		Execute "ValDisplay "+basename+"D ,value="+ dxexpr
		
		i+=1
	while(i<=2 )
	
end



Function ButtonProcSetn(ctrlName) : ButtonControl
	String ctrlName
	
	if( CmpStr(ctrlName,"Set0") == 0 )
		AddHairCursor(0)
		UpdateCursorReadout(0)
		UpdateCursorDeltas()
	endif
	if( CmpStr(ctrlName,"Set1") == 0 )
		AddHairCursor(1)
		UpdateCursorReadout(1)
		UpdateCursorDeltas()
	endif
	if( CmpStr(ctrlName,"Set2") == 0 )
		NVAR curXtra= root:WinGlobals:HairlineCursorPanel:curXtra
		AddHairCursor(curXtra)
		UpdateCursorReadout(curXtra)
	endif
End

Function ButtonProcRemoven(ctrlName) : ButtonControl
	String ctrlName
	
	Variable n= -1
	if( CmpStr(ctrlName,"Remove0") == 0 )
		n=0
	endif
	if( CmpStr(ctrlName,"Remove1") == 0 )
		n=1
	endif
	if( CmpStr(ctrlName,"Remove2") == 0 )
		n=NumVarOrDefault("root:WinGlobals:HairlineCursorPanel:curXtra",2)
	endif

	CheckDisplayed TraceNameToWaveRef("", "HairY"+num2istr(n))
	if( V_Flag != 0 )
		RemoveFromGraph $"HairY"+num2istr(n)
	endif
End

Window HairlineCursorPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel/K=1 /W=(329,44,777,184)
	SetDrawLayer UserBack
	SetDrawEnv fname= "Geneva"
	DrawText 13,18,"Cursor:"
	SetDrawEnv fstyle= 1,textrgb= (0,0,65535)
	DrawText 29,42,"0"
	SetDrawEnv fname= "Geneva",fstyle= 1,textrgb= (3,52428,1)
	DrawText 29,63,"1"
	SetDrawEnv fname= "Geneva"
	DrawText 146,18,"X"
	DrawLine 17,17,436,17
	SetDrawEnv fname= "Geneva"
	DrawText 229,18,"Y"
	SetDrawEnv fname= "Geneva"
	DrawText 320,18,"Z"
	SetDrawEnv fname= "Geneva",fsize= 9,textxjust= 2,textyjust= 1
	DrawText 107,97,"delta (1-0):"
	SetDrawEnv fname= "Geneva"
	DrawText 379,17,"Graph"
	Button Set0,pos={45,25},size={29,17},proc=ButtonProcSetn,title="Set"
	Button Set1,pos={45,45},size={29,17},proc=ButtonProcSetn,title="Set"
	Button Set2,pos={45,65},size={29,17},proc=ButtonProcSetn,title="Set"
	Button Remove0,pos={78,25},size={29,17},proc=ButtonProcRemoven,title="Rm"
	Button Remove1,pos={78,45},size={29,17},proc=ButtonProcRemoven,title="Rm"
	Button Remove2,pos={78,65},size={29,17},proc=ButtonProcRemoven,title="Rm"
	ValDisplay valdispX0,pos={115,27},size={77,12},fSize=9
	ValDisplay valdispX0,limits={0,0,0},barmisc={0,1000},value= #"no value"
	ValDisplay valdispY0,pos={198,27},size={77,12},fSize=9
	ValDisplay valdispY0,limits={0,0,0},barmisc={0,1000},value= #"no value"
	ValDisplay valdispZ0,pos={281,27},size={76,12},fSize=9
	ValDisplay valdispZ0,limits={0,0,0},barmisc={0,1000},value= #"no value"
	ValDisplay valdispX1,pos={115,48},size={77,12},fSize=9
	ValDisplay valdispX1,limits={0,0,0},barmisc={0,1000},value= #"no value"
	ValDisplay valdispY1,pos={198,48},size={77,12},fSize=9
	ValDisplay valdispY1,limits={0,0,0},barmisc={0,1000},value= #"no value"
	ValDisplay valdispZ1,pos={281,48},size={77,12},fSize=9
	ValDisplay valdispZ1,limits={0,0,0},barmisc={0,1000},value= #"no value"
	ValDisplay valdispXn,pos={115,68},size={77,12},fSize=9
	ValDisplay valdispXn,limits={0,0,0},barmisc={0,1000},value= #"no value"
	ValDisplay valdispYn,pos={198,68},size={77,12},fSize=9
	ValDisplay valdispYn,limits={0,0,0},barmisc={0,1000},value= #"no value"
	ValDisplay valdispZn,pos={281,68},size={77,12},fSize=9
	ValDisplay valdispZn,limits={0,0,0},barmisc={0,1000},value= #"no value"
	SetVariable setvar0,pos={8,66},size={34,15},proc=SetVarProcChangeCurXtra,title=" "
	SetVariable setvar0,limits={2,5,1},value= root:WinGlobals:HairlineCursorPanel:curXtra
	ValDisplay valdispXD,pos={115,91},size={77,12},fSize=9
	ValDisplay valdispXD,limits={0,0,0},barmisc={0,1000},value= #"no value"
	ValDisplay valdispYD,pos={198,90},size={77,12},fSize=9
	ValDisplay valdispYD,limits={0,0,0},barmisc={0,1000},value= #"no value"
	ValDisplay valdispZD,pos={281,90},size={77,12},fSize=9
	ValDisplay valdispZD,limits={0,0,0},barmisc={0,1000},value= #"no value"
	SetVariable setvarGrf0,pos={362,27},size={76,12},title=" ",fSize=9
	SetVariable setvarGrf0,limits={-INF,INF,1},value= root:WinGlobals:HairlineCursorPanel:csrgraph0
	SetVariable setvarGrf1,pos={362,48},size={76,12},title=" ",fSize=9
	SetVariable setvarGrf1,limits={-INF,INF,1},value= root:WinGlobals:HairlineCursorPanel:csrgraph1
	SetVariable setvarGrf2,pos={362,67},size={76,12},title=" ",fSize=9
	SetVariable setvarGrf2,limits={-INF,INF,1},value= root:WinGlobals:HairlineCursorPanel:csrgraphn
	SetVariable setvarExpression,pos={115,118},size={190,15},title=" "
	SetVariable setvarExpression,limits={-INF,INF,1},value= root:WinGlobals:HairlineCursorPanel:expression
	Button buttonPrint,pos={58,115},size={50,20},proc=ButtonProcPrintExpr,title="Print:"
EndMacro

// used during development
xMacro NoValueize()
	ValDisplay valdispX0,value= #"no value"
	ValDisplay valdispY0,value= #"no value"
	ValDisplay valdispZ0,value= #"no value"
	ValDisplay valdispX1,value= #"no value"
	ValDisplay valdispY1,value= #"no value"
	ValDisplay valdispZ1,value= #"no value"
	ValDisplay valdispXn,value= #"no value"
	ValDisplay valdispYn,value= #"no value"
	ValDisplay valdispZn,value= #"no value"
	ValDisplay valdispXD,value= #"no value"
	ValDisplay valdispYD,value= #"no value"
	ValDisplay valdispZD,value= #"no value"
end

Function SetVarProcChangeCurXtra(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	UpdateCursorReadout(varNum)
End

Function ButtonProcPrintExpr(ctrlName) : ButtonControl
	String ctrlName

	SVAR expr= root:WinGlobals:HairlineCursorPanel:expression
	String s= TranslateXYZExpr(expr)
	Print  "•print "+s
	Execute "print "+s
End

Function/S TranslateXYZExpr(expr)
	String expr
	
	variable p0,p1,p2
	
	//
	//	First we search for patterns like X<digit>, Y<digit> and Z<digit>
	//	If found, we insert a single quite in front to identify the location of the
	//	pattern. This whole thing would be much easier if we had a grep style
	//	pattern search. Even if we just had a case insensitive search, all the p1 vs p2
	//	stuff would dissapear.
	//
	String s1="XYZ"
	Variable i=0
	do
		String ch= s1[i]		// the char to search for
		p0=0
		do
			p1= StrSearch(expr,ch,p0)					// upper case search
			p2= StrSearch(expr,LowerStr(ch),p0)		// lower case search
			if( (p1 < 0) %& (p2 < 0) )					// didn't find either
				break
			endif
			if( (p1>=0) %& (p2>=0) )					// found both
				p1= min(p1,p2)						// take the first one
			else
				p1= max(p1,p2)						// just one, the other is -1
			endif
			if( (char2num(expr[p1+1]) >= 0x30) %& (char2num(expr[p1+1]) <= 0x39) ) // digit?
				expr[p1]= "'"
				p0= p1+3
			else
				p0= p1+2
			endif
		while(1)
		i+=1
	while(i<3)
	
	//
	//	Now, for each singe quote, we extract the digit, use that to look up the
	//	name of the graph (if any) and then replace the single quote with the path
	//	to the variable. We verify the variable exists and return an error string
	//	if not
	//
	p0= 0
	do
		p1= StrSearch(expr,"'",p0)
		if( p1<0 )
			break
		endif
		Variable n= char2num(expr[p1+2])-0x30
		String gnstr= "root:WinGlobals:HairlineCursorPanel:csrgraph"+num2str(n)
		SVAR gname= $gnstr
		if( Exists(gnstr) != 2 )
			expr= "\"ERROR: specified cursor set does not exist ("+gnstr+")\""
			break
		endif
		String vpath=  "root:WinGlobals:"+gname+":"+expr[p1+1,p1+2]
		if( Exists(vpath) != 2 )
			expr= "\"ERROR: specified cursor does not exist ("+vpath+")\""
			break
		endif
		expr[p1,p1+2]= vpath
		p0= p1+strlen(vpath)
	while(1)
	
	return expr
end
