#pragma rtGlobals=2		// Use modern global access method.
#pragma version=6.23		// shipped with Igor 6.23

#include <Image Common>

// Image Range Adjust package
// Version 1.0, LH971209
//
// Create user interface window by calling the following from a button or a menu:
// WMCreateImageRangeGraph()

// LH971127: Idea
// It would be best if the contrast histogram updated whenever the top image
// changed or a new top image was activated.  The former could be done using
// a dependency but the latter would require either:
// 	1. A magic global variable that is updated with the name of the top window
//		whenever that changes. A dependency could then be set up.
//	2. A new parameter to the Window Hook info string could be added that indicates
//		that a change in window order has taken place.
//	3. A mechanism could be developed where user functions can be registered to
//		be called whenever a specific class of actions as taken place. Actions might be
//		a wave has been changed, the window order has changed or a time has passed.

// AG17JUN99 Modified the update by calling the hook directly after panel creation.

// Version 6.23, JP110712: WMImageRangeWindowProc() kills the dependency when the image range graph dies.
// This fixes a bug reported by Thomas Braun where the image range was being reset after experiment load
// when the image range had been changed using the Modify Image dialog (or ModifyImage command) after
// the Image Range graph was used.

Function WMCreateImageRangeGraph()

	if(isColorImage())
		return 0;
	endif
	DoWindow/F WMImageRangeGraph
	if( V_Flag==1 )
		return 0
	endif

	NewDataFolder/O root:WinGlobals
	NewDataFolder/O root:WinGlobals:WMImageRangeGraph
	String/G root:WinGlobals:WMImageRangeGraph:S_TraceOffsetInfo= ""

	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:WMImProcess
	NewDataFolder/O root:Packages:WMImProcess:ImageRange
	
	String dfSav= GetDataFolder(1)
	SetDataFolder root:Packages:WMImProcess:ImageRange
	
	Variable/G zmin,zmax,zminmaxDummy
	SetFormula zminmaxDummy,"WMSetImRngMinMaxFromCursors(root:WinGlobals:WMImageRangeGraph:S_TraceOffsetInfo)"
	
	Make/O zminDrag={-Inf,Inf},zmaxDrag={-Inf,Inf},xDrag={0,0}

	String/G ImGrfName= WMTopImageGraph()
	
	SetDataFolder dfSav
	
	Wave w= $WMGetImageWave(ImGrfName)
	
	WAVE/Z histw= $WMImageRangeDoHist(ImGrfName)
	if( !WaveExists(histw) )
		Abort "No Image graph found"
	endif
	WMImageRangeAdjustGraph(histw)

	 WMUpdateImageRangeAdjustGraph(histw,w,ImGrfName)

	AutoPositionWindow/E/M=1/R=$ImGrfName
	
	return 0;
end

Function WMImageRangeUpdateProc()
	String newImGrfName= WMTopImageGraph()
	SVAR ImGrfName= root:Packages:WMImProcess:ImageRange:ImGrfName
	
	Wave/Z w= $WMGetImageWave(newImGrfName)
	
	WAVE/Z histw= $WMImageRangeDoHist(newImGrfName)
	if( !WaveExists(histw) )
		WAVE/Z hw= TraceNameToWaveRef("", "hist")
		if( WaveExists(hw) )
			hw= NaN
		endif
		return 0
	endif
	if( CmpStr(newImGrfName,ImGrfName)!= 0 )
		ReplaceWave trace=hist,histw
	endif
	ImGrfName= newImGrfName
	 WMUpdateImageRangeAdjustGraph(histw,w,newImGrfName)
end
	
Function WMImageRangeWindowProc(infoStr)
	String infoStr
	
	Variable status= 0
	String eventName= StringByKey("EVENT",infoStr)

	strswitch(eventName)
		case "activate":
			WMImageRangeUpdateProc()
			status= 1
			break
		case "kill":
			SetFormula root:Packages:WMImProcess:ImageRange:zminmaxDummy, ""	// JP110712: otherwise the dependency fires when the experiment is re-opened, which can reset the image color range.
			break
	endswitch
	
	return status
end



// Note: prior to version 68, this attempted to use a dependency mechanism to
// allow the histogram to be performed only when necessary. However that made it
// a pain to delte the data associated with an image so we now do the histogram whenever
// the range adjust graph is activated.
Function/S WMImageRangeDoHist(ImGrfName)
	String ImGrfName
	
	WAVE/Z w= $WMGetImageWave(ImGrfName)
	if( !WaveExists(w) )
		return ""
	endif
	
	String pu= WMGetWaveAuxDF(w)
	String dfSav= GetDataFolder(1)
	SetDataFolder pu
	Make/O/N=100 hist
	Histogram/B=1 w,hist
	SetScale d,0,0,"Counts" hist

	SetDataFolder dfSav

	return GetWavesDataFolder(hist,2)		// full path to wave including name
end

#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility with Igor 7
	String wName
	return 72
End
#endif

Function WMImageRangeAdjustGraph(histw)
	Wave histw

	// specify size in pixels to match user controls
	Variable x0=324*PanelResolution("")/ScreenResolution, y0= 156*PanelResolution("")/ScreenResolution
	Variable x1=732*PanelResolution("")/ScreenResolution, y1= 313*PanelResolution("")/ScreenResolution

	Display/K=1/L=lnew /W=(x0,y0,x1,y1) histw as "Image Range Adjust"

	String dfSav= GetDataFolder(1)
	SetDataFolder root:Packages:WMImProcess:ImageRange:
	AppendToGraph/L=lnew zminDrag,:zmaxDrag vs xDrag
	SetDataFolder dfSav
	ModifyGraph margin(left)=56
	ModifyGraph mode(hist)=1
	ModifyGraph quickdrag(zminDrag)=1,live(zminDrag)=1
	ModifyGraph quickdrag(zmaxDrag)=1,live(zmaxDrag)=1
	ModifyGraph lSize(zminDrag)=2,lSize(zmaxDrag)=2
	ModifyGraph rgb(hist)=(0,0,0),rgb(zmaxDrag)=(1,4,52428)
	ModifyGraph lblPos(lnew)=47
	ModifyGraph freePos(lnew)=7

	DoWindow/C WMImageRangeGraph

	ControlBar 28
	SetVariable MinVar,pos={17,6},size={92,15},proc=WMContMinMaxVarSetVarProc,title="min:"
	SetVariable MinVar,help={"Set minimum z here or drag left vertical cursor"}
	SetVariable MinVar,limits={0,255,2.55},value= root:Packages:WMImProcess:ImageRange:zmin
	SetVariable MaxVar,pos={119,6},size={91,15},proc=WMContMinMaxVarSetVarProc,title="max:"
	SetVariable MaxVar,help={"Set maximum z here or drag right vertical cursor"}
	SetVariable MaxVar,limits={0,255,2.55},value= root:Packages:WMImProcess:ImageRange:zmax
	Button WMContInvButton,pos={219,4},size={50,20},proc=WMContInvButtonProc,title="Invert"
	Button WMContInvButton,help={"Swaps zmin and zmax to invert the image."}
	Button WMContAuto,pos={276,4},size={50,20},proc=WMContAutoButtonProc,title="Auto"
	Button WMContAuto,help={"Click to autoscale zmin and zmax to the full rage of z values."}
	Button WMCont94,pos={331,4},size={50,20},proc=WMCont94ButtonProc,title="94%"
	Button WMCont94,help={"Click here to set zmin and zmax to bracket 94% of the histogram."}

	DoUpdate	// get update over with so we don't call WMImageRangeDoHist twice
	SetWindow kwTopWin,hook=WMImageRangeWindowProc
	WMImageRangeWindowProc("EVENT:activate")
EndMacro

// Assumes imagew is a gray scale (or false color) image and that
// histw is an autoscaled histogram displayed in a special purpose top graph
Function WMUpdateImageRangeAdjustGraph(histw,imagew,imGrfName)
	Wave histw,imagew
	String imGrfName
	
	Variable zmin= leftx(histw),zmax= rightx(histw),nmin,nmax
	Variable ntype= WaveType(imagew)
	
	// Try to find natural limits to z-range
	do
		if( ntype %& 0x8 )				// 8 bit?
			if( ntype %& 0x40 )		// unsigned?
				nmin= 0; nmax= 255
			else
				nmin= -128; nmax= 127
			endif
			break
		endif
		if( ntype %& 0x10 )			// 16 bit?
			if( ntype %& 0x40 )		// unsigned?
				nmin= 0; nmax= 65535
			else
				nmin= -32768; nmax= 32767
			endif
			break
		endif
		if( ntype %& 0x20 )			// 32 bit?
			if( ntype %& 0x40 )		// unsigned?
				nmin= 0; nmax= 2^32-1
			else
				nmin= -2^31; nmax= 2^31-1
			endif
			break
		endif
		// Still here? Must be float with no natural limits. To give some range outside
		// the data min/max we expand the range by half or so
		nmin= zmin - (zmax-zmin)/2
		nmax= zmax + (zmax-zmin)/2
	while(0)

	SetAxis bottom,nmin,nmax
	SetVariable MaxVar,limits={nmin,nmax,(nmax-nmin)/100}
	SetVariable MinVar,limits={nmin,nmax,(nmax-nmin)/100}

	NVAR nzmax= root:Packages:WMImProcess:ImageRange:zmax
	NVAR nzmin= root:Packages:WMImProcess:ImageRange:zmin
	
	Variable/C cur= WMReadImageRange(imGrfName,imagew)
	if( NumType(real(cur)) == 0 )
		nzmin= real(cur)
	else
		nzmin= zmin
	endif
	if( NumType(imag(cur)) == 0 )
		nzmax= imag(cur)
	else
		nzmax= zmax
	endif
	ModifyGraph offset(zmaxDrag)={nzmax,0}
	ModifyGraph offset(zminDrag)={nzmin,0}
	// Now prevent the offset dependency from firing due to double update.
	String/G root:WinGlobals:WMImageRangeGraph:S_TraceOffsetInfo= ""
end

Function WMContMinMaxVarSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	// NOTE: setting the offsets here causes a dependency to fire that ends up updating the image
	if( CmpStr("MaxVar",ctrlName) == 0 )
		ModifyGraph offset(zmaxDrag)={varNum,0}	
	else
		ModifyGraph offset(zminDrag)={varNum,0}
	endif
End

// Fires on a dependency. s is S_TraceOffsetInfo from the quickdrag stuff
Function WMSetImRngMinMaxFromCursors(s)
	String s

	Variable isZmin= StrSearch(s,"TNAME:zminDrag;",0)>0
	Variable isZmax= StrSearch(s,"TNAME:zmaxDrag;",0)>0
	if( (isZmin==0) %& (isZmax==0) )
		return 0								// not valid yet
	endif
	String targ= ";XOFFSET:"
	Variable v1= StrSearch(s,targ,0)
	if( v1<0 )
		return 0
	endif
	v1 += strlen(targ)
	Variable v2= StrSearch(s,";",v1)
	Variable xoff= str2num(s[v1,v2-1])
	if( NumType(xoff) != 0 )
		return 0;
	endif
	NVAR nzmax= root:Packages:WMImProcess:ImageRange:zmax
	NVAR nzmin= root:Packages:WMImProcess:ImageRange:zmin
	if( isZmax )
		nzmax= xoff
	else
		nzmin= xoff
	endif
	WMSetZminZmaxForImage(isZmax)
	return 0
end

Function WMSetZminZmaxForImage(isMax)
	variable isMax
	
	SVAR ImGrfName= root:Packages:WMImProcess:ImageRange:ImGrfName
	NVAR nzmax= root:Packages:WMImProcess:ImageRange:zmax
	NVAR nzmin= root:Packages:WMImProcess:ImageRange:zmin

	WAVE/Z w= $WMGetImageWave(ImGrfName)
	if( !WaveExists(w) )
		return 0
	endif
	if( isMax )
		ModifyImage/W=$ImGrfName $NameOfWave(w) ctab= {,nzmax,}
	else
		ModifyImage/W=$ImGrfName $NameOfWave(w) ctab= {nzmin,,}
	endif
	return 0
end


Function WMContInvButtonProc(ctrlName) : ButtonControl
	String ctrlName

	SVAR ImGrfName= root:Packages:WMImProcess:ImageRange:ImGrfName
	WAVE/Z w= $WMGetImageWave(ImGrfName)
	if( !WaveExists(w) )
		return 0
	endif

	NVAR nzmax= root:Packages:WMImProcess:ImageRange:zmax
	NVAR nzmin= root:Packages:WMImProcess:ImageRange:zmin
	variable tmp
	
	tmp= nzmax; nzmax= nzmin; nzmin= tmp
	
	ModifyGraph offset(zmaxDrag)={nzmax,0}
	ModifyGraph offset(zminDrag)={nzmin,0}
	// Now prevent the offset dependency from firing due to double update.
	String/G root:WinGlobals:WMImageRangeGraph:S_TraceOffsetInfo= ""
	ModifyImage/W=$ImGrfName $NameOfWave(w) ctab= {nzmin,nzmax,}
	
	return 0
End

Function WMContAutoButtonProc(ctrlName) : ButtonControl
	String ctrlName


	SVAR ImGrfName= root:Packages:WMImProcess:ImageRange:ImGrfName
	WAVE/Z w= $WMGetImageWave(ImGrfName)
	if( !WaveExists(w) )
		return 0
	endif

	NVAR nzmax= root:Packages:WMImProcess:ImageRange:zmax
	NVAR nzmin= root:Packages:WMImProcess:ImageRange:zmin
	
	Wave histw= TraceNameToWaveRef("", "hist")
	nzmin= LeftX(histw)
	nzmax= RightX(histw)-deltax(histw)
	
	ModifyGraph offset(zmaxDrag)={nzmax,0}
	ModifyGraph offset(zminDrag)={nzmin,0}
	// Now prevent the offset dependency from firing due to double update.
	String/G root:WinGlobals:WMImageRangeGraph:S_TraceOffsetInfo= ""
	ModifyImage/W=$ImGrfName $NameOfWave(w) ctab= {*,*,}
	
	return 0
End

Function WMCont94ButtonProc(ctrlName) : ButtonControl
	String ctrlName


	SVAR ImGrfName= root:Packages:WMImProcess:ImageRange:ImGrfName
	WAVE/Z w= $WMGetImageWave(ImGrfName)
	if( !WaveExists(w) )
		return 0
	endif

	NVAR nzmax= root:Packages:WMImProcess:ImageRange:zmax
	NVAR nzmin= root:Packages:WMImProcess:ImageRange:zmin
	
	Wave histw= TraceNameToWaveRef("", "hist")
	Variable npts= numpnts(histw)
	Variable tot= sum(histw, pnt2x(histw,0 ), pnt2x(histw,npts-1 ))

	variable s=0,i=0
	do
		s += histw[i]
		i+=1
	while( (s/tot) < 0.03 )
	nzmin= LeftX(histw)+deltax(histw)*i
	
	s=0;i=npts-1
	do
		s += histw[i]
		i-=1
	while( (s/tot) < 0.03 )
	nzmax= LeftX(histw)+deltax(histw)*i
	
	ModifyGraph offset(zmaxDrag)={nzmax,0}
	ModifyGraph offset(zminDrag)={nzmin,0}
	// Now prevent the offset dependency from firing due to double update.
	String/G root:WinGlobals:WMImageRangeGraph:S_TraceOffsetInfo= ""
	ModifyImage/W=$ImGrfName $NameOfWave(w) ctab= {nzmin,nzmax,}
	
	return 0
End

