// Path Profile version 1.11
//		REQUIRES Igor Pro version 3.01 or later
//		REQUIRES MDInterpolator XOP


#pragma rtglobals=1

#include <Strings as Lists>

// NOTE: This procedure file requires that the MDInterpolator XOP be installed
//		in the Igor Extensions folder.
//
//  For a demonstration experiment showing how this procedure file is used,
//  see the experiment file "Path Profile Demo" in the Graphs subfolder of the
//  Examples folder in your Igor Pro folder.
//
//  These procedures are written to be used with the control panels that are made by
//  the procedure file.  The functions that do the actual work could be used by themselves
//  if you did some work to modify them, or to set up the data folders and global variables
//  that the procedures need.
//
//  Possible Improvements:
//	Make it work with Images and Contour Plots that aren't displayed on Left and Bottom axes.

Menu "Macros"
	"Arbitrary Path Profile", MakeProfilePanel(1)
	"Perpendicular Path Profile", MakeProfilePanel(2)
end

function fObsoleteAlertPanel()
	NewPanel /K=2/W=(150,50,584,255)
	DoWindow/C PathProfileObsoleteAlert
	SetDrawLayer UserBack
	SetDrawEnv fstyle= 1,textxjust= 1, textRGB=(65535, 0, 10000)
	DrawText 215,26,"*** The Path Profile procedure file is obsolete. ***"
	SetDrawEnv fsize= 10,textxjust= 1
	DrawText 205,65,"It is better to use the built-in operation ImageLineProfile."
	SetDrawEnv fsize= 10,textxjust= 1
	DrawText 206,83,"A user interface is provided by the procedure file Image Line Profile."
	SetDrawEnv fsize= 10
	DrawText 54,117,"For more information about Igor's image processing capability,"
	SetDrawEnv fsize= 10
	DrawText 54,132,"see the Image Processing Tutorial in your Igor Pro folder."
	SetDrawEnv fsize= 10
	DrawText 54,148,"Look for Learning Aids:Tutorials:IP Tutorial:IP Tutorial.pxp"
	Button PathProfileAlertOKButton,pos={165,173},size={50,20},proc=PathProfileAlertOKButtonProc,title="OK"
EndMacro

Function PathProfileAlertOKButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/K PathProfileObsoleteAlert
End


Proc MakeProfilePanel(Type)
	Variable Type

	Silent 1

	String SaveFolder=GetDataFolder(1)
	SetDataFolder root:

	// Test for private data folder for these procedures, make it if it doesn't exist
	
	if (DataFolderExists("root:Packages")==0)
		NewDataFolder/S Packages
		NewDataFolder/S WMProfileProc
	else
		SetDataFolder Packages
		if (DataFolderExists("WMProfileProc")==0)
			NewDataFolder/S WMProfileProc
		else
			SetDataFolder WMProfileProc
		endif
	endif
	
	//  Some globals used by these procedures
	
	Variable/G PR_NumProfPoints=100
	String/G PR_PathXName="PathXWave"
	String/G PR_PathYName="PathYWave"
	String/G PR_OutWaveName="ProfileWave"
	SetDataFolder $SaveFolder

	if (Type == 1)
		if (wintype("ProfilePanel") == 7)
			DoWindow/F ProfilePanel
		else
			ProfilePanel()
		endif
	else
		if (wintype("PerpProfPanel") == 7)
			DoWindow/F PerpProfPanel
		else
			PerpProfPanel()
		endif
	endif
	
	fObsoleteAlertPanel()
end

// The function that actually calculates the profile data

Function InterpPath(Wave2D, PathY, PathX, NumOutPnts, OutName, AtPoints)
	Wave Wave2D, PathY
	WAVE/Z PathX
	Variable NumOutPnts
	String OutName
	Variable AtPoints
	
//	String OutName=UniqueName(NameofWave(Wave2D)+"_path", 1, 0)
//	print "Wave containing path is ", OutName
	
	Variable TotalLength,LengthInc, LengthP, PointX, PointY,Distance
	Variable/C Point
	Variable ind, endloop
	Variable XVal, YVal
	Variable hasX=waveExists(PathX)
	
//	print "InterpPath: hasX = ", hasX
	
	if (AtPoints)
		NumOutPnts = numpnts(PathY)
	endif
	Make/O/N=(NumOutPnts) $OutName
	Wave w=$OutName
	Duplicate/O PathY, root:Packages:WMProfileProc:PR_LineLength
	Wave PR_LineLength=root:Packages:WMProfileProc:PR_LineLength
	
	if (AtPoints)
		ind = 0
		endloop=NumOutPnts
		do
			if (hasX)
				XVal = PathX[ind]
			else
				XVal = pnt2x(pathY, ind)
			endif
			// interp2d is in the MDInterpolator XOP.
			// If you get an error here, put an alias to MDInterpolator in Igor Extensions and relaunch Igor.
			w[ind] = interp2d(wave2D, XVal, pathY[ind])
			ind += 1
		while(ind<endloop)
	else
		TotalLength=WaveLineLengthXY(PathX, PathY, PR_LineLength)
//		print "TotalLength",TotalLength
		LengthInc = TotalLength/(NumOutPnts-1)
		SetScale/I x 0,TotalLength,$OutName

		ind=0
		endloop=NumOutPnts
		do
			Distance=ind*LengthInc
//			print "ProfileProc: distance = ", distance
			Point=XYatDistance(PR_LineLength, PathX, PathY, Distance)
//			print "ProfileProc: point, ind:",point, ind
			w[ind] = interp2d(Wave2D, real(Point), imag(Point))
//			print point, ind, w[ind]
		
			ind += 1
		while(ind< endloop)
	endif
	
	KillWaves PR_LineLength
end

// XYatDistance calculates the X, Y points corresponding to a distance along the wave, or pair of waves.
//  If XWave doesn't exist, does a waveform calculation, if it does exist, does XY calculation.
//
//  Requires that WaveLineLengthXY be run first to calculate the line length wave.

Function/C XYatDistance(LengthWave, XWave, YWave, Distance)
	Wave/Z LengthWave, XWave, YWave
	Variable/D Distance
	
	Variable hasX = waveExists(XWave)
	
//	print "XYatDistance: hasX = ", hasX
	
	Variable i=0, PNum, TP=numpnts(LengthWave), Px, Py
	Variable XVal0, XVal1
	
	do
//		print "XYatDistance, d, LW[i]:",Distance, LengthWave[i]
		if (Distance < LengthWave[i])
			PNum=i-1
			break
		endif
			
		i += 1
	while (i < TP)
	
	if (i > TP)
//		print "XYatDistance: i > TP"
		return(cmplx(NaN, NaN))
	endif
	
	Distance -= LengthWave[PNum]
	Distance = Distance/(LengthWave[PNum+1]-LengthWave[PNum])
	
	if (hasX)
		Xval0 = XWave[PNum]
		Xval1 = XWave[PNum+1]
	else
		Xval0 = pnt2x(YWave, PNum)
		Xval1 = pnt2x(YWave, PNum+1)
	endif

	Px = Xval0 + Distance*(Xval1-Xval0)
	Py = YWave[PNum] + Distance*(YWave[PNum+1]-YWave[PNum])
	
	return cmplx(Px, Py)
end

// WaveLineLengthXY calculates a new wave with line length along the wave or wave pair.
// Each element in the calculated wave is the total length of the given wave(s) up to the
// corresponding element.

Function/D WaveLineLengthXY(InWaveX, InWaveY, LengthWave)
	Wave/Z InWaveX, InWaveY, LengthWave
	
	Variable hasX=waveExists(InWaveX)
	Variable Xval0, Xval1
	
//	print "WaveLineLengthXY: hasX = ", hasX
	
	if (hasX)
		if (numpnts(InWaveX) != numpnts(InWaveY))
//			print "WaveLineLengthXY: wrong X points"
			return NaN
		endif
	endif
	
	if (numpnts(InWaveY) != numpnts(LengthWave))
//		print "WaveLineLengthXY: wrong LengthWave"
		return NaN
	endif
	
	Variable/D Sum=0
	Variable i=0, numiters=numpnts(InWaveY)-1
	
	LengthWave[0] = 0
	do
		if (hasX)
			Xval0 = InWaveX[i]
			Xval1 = InWaveX[i+1]
		else
			Xval0 = pnt2x(InWaveY, i)
			Xval1 = pnt2x(InWaveY, i+1)
		endif

		sum += sqrt((Xval1-Xval0)^2 + (InWaveY[i+1]-InWaveY[i])^2)
		LengthWave[i+1] = sum
	
		i += 1
	while (i<numiters)
	
	return sum
end


// ListContoursImages() returns a string containing the names of both images and
// contour plots.  Eliminates duplicate names.

Function/S ListContoursImages()

	String ContourList=ContourNameList("",";")
	String ImageList=ImageNameList("",";")
	String Name1, Name2
	Variable i1=0, i2, Match
	
	i1 = 0
	do
		Name1=GetStrFromList(ImageList, i1, ";")
		if (strlen(Name1) == 0)
			break
		endif
		i2 = 0
		do
			Name2 = GetStrFromList(ContourList, i2, ";")
			if (strlen(Name2) == 0)
				break
			endif
			if (cmpstr(Name1, Name2) == 0)
				Match = 1
				break
			else
				Match = 0
			endif
			i2 += 1
		while(1)
		if (Match == 0)
			ContourList += Name1+";"
		endif
		i1 += 1
	while (1)
	
	return ContourList
end

//***************************
// Action procedures for controls follow
//***************************

Function MakePathProc(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR PathXName=root:Packages:WMProfileProc:PR_PathXName
	SVAR PathYName=root:Packages:WMProfileProc:PR_PathYName
//	NVAR HasPathXWave=root:Packages:WMProfileProc:HasPathXWave

	Variable hasX
	
//	print "X,Y:", PathXName, PathYName
	
	if (strlen(PathYName) == 0)
		Abort "No name for Y path wave"
	endif
	if (strlen(PathXName) == 0)
		Abort "No name for X path wave"
	endif
	
	Make/O/N=2 $PathXName
	wave PR_XWave=$PathXName
	Make/O/N=2 $PathYName
	wave PR_YWave=$PathYName
	
	
	GetAxis bottom
	
//	print V_min, V_max
	PR_XWave[0] = V_min
	PR_XWave[1] = V_max
	
	GetAxis left
//	print V_min, V_max
	PR_YWave[0] = V_min
	PR_YWave[1] = V_max
	
	CheckDisplayed/W=$(WinName(0, 1)) $PathYName
	if (!V_flag)
		AppendToGraph $PathYName vs $PathXName
		ModifyGraph rgb($PathYName)=(0,0,0 )
	endif
	ControlUpdate PathWavePopup
	String traceList=traceNameList("", ";",1)
//	print traceList

	String currentName
	Variable i=0
	do
		currentName=GetStrFromList(traceList, i,";")
//		print currentName
		if (strlen(currentName)== 0)
			break
		endif
		if (cmpstr(currentName, PathYName) == 0)
			PopupMenu PathWavePopup,mode=i+1
			break
		endif
	
		i += 1
	while (1)
	
End

Function EditPathProc(ctrlName) : ButtonControl
	String ctrlName
	
	String TraceName
		
		ControlInfo PathWavePopup
		TraceName=S_value
	
	Wave/Z PathY = TraceNameToWaveRef("", TraceName)
//	print "PathY = ", NameofWave(PathY)
	Wave/Z PathX = XWaveRefFromTrace("", TraceName)
//	print "PathX = ", NameofWave(PathX)

	if (WaveExists(PathY) == 0)
		Abort "Path Y wave doesn't exist"
	endif
	if (WaveExists(PathX) == 0)
		Abort "Please do not edit Waveform traces, only XY traces"
	endif

	
	String Window=WinName(0,1)
	
	DoWindow/F $Window
	ShowTools
	
//	print "Print from pathWaves:", PathY[0], PathX[0]
	GraphWaveEdit $TraceName
	
End

Function ProfileProc(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR PR_OutWaveName=root:Packages:WMProfileProc:PR_OutWaveName
	
	NVAR PR_NumProfPoints=root:Packages:WMProfileProc:PR_NumProfPoints
	
	String ContourName=WaveNameForProfile()
	Wave Wave2d=$(ContourName)
	String PathName
	Variable AtPoints
		
	ControlInfo PathWavePopup
	PathName = S_value
	
	Wave PathY = TraceNameToWaveRef("",PathName)
	Wave PathX = XWaveRefFromTrace("",PathName)
	
	ControlInfo AtPointsCheck
	AtPoints=V_value

	InterpPath(Wave2D, PathY, PathX, PR_NumProfPoints, PR_OutWaveName, AtPoints)
	
End

Function/S WaveNameForProfile()

	Variable UseImage=0
	String ContourList=ContourNameList("",";")
	String ContourName
	
	ContourName=GetStrFromList(ContourList, 0, ";")
	if (strlen(ContourName) == 0)
		UseImage = 1
	else
	//	print "ContourName = ", ContourName
		string cInfo = ContourInfo("",ContourName,0)
		Variable formatPos = strsearch(cInfo, "DATAFORMAT", 0)
		if ((formatPos < 0) %| (cmpstr(cInfo[formatPos+11, formatPos+13], "XYZ") == 0))
			UseImage = 1
		else
			Wave Wave2d=ContourNameToWaveRef("", ContourName)
		endif
	endif
	if (UseImage)
		ContourList = ImageNameList("",";")
		ContourName = GetStrFromList(ContourList, 0, ";")
		if (strlen(ContourName) == 0)
			abort "No contour plot or image found in the top graph window"
		else
			Wave Wave2d=ImageNameToWaveRef("", ContourName)
		endif
	endif
	
	return GetWavesDatafolder(Wave2d, 4)
end

	




Function ProfileGraphProc(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR PR_OutWaveName=root:Packages:WMProfileProc:PR_OutWaveName
	
	Display $PR_OutWaveName

End


Function InterpCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	if (checked)
		Checkbox AtPointsCheck, value=0
	else
		Checkbox AtPointsCheck, value=1
	endif

End

Function ProfileCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	Variable CtrlProfChk, CtrlInterpChk
	
	if (checked)
		Checkbox InterpPathCheck, value=0
	else
		Checkbox InterpPathCheck, value=1
	endif


End

//*******************************
// Recreation macro for profile control panel
//*******************************

Window ProfilePanel()
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(254.25,70.25,522,362.75) as "Path Profile"
	SetDrawLayer UserBack
	SetDrawEnv fillpat= 0
	DrawRect 36,33,228,114
	SetDrawEnv fillpat= 0
	DrawRect 36,149,228,205
	SetVariable SetXPathWave,pos={45,39},size={174,18},title="X Path Name:"
	SetVariable SetXPathWave,limits={-Inf,Inf,1},value= root:Packages:WMProfileProc:PR_PathXName
	SetVariable SetYPathWave,pos={44,60},size={175,18},title="Y Path Name:"
	SetVariable SetYPathWave,limits={-Inf,Inf,1},value= root:Packages:WMProfileProc:PR_PathYName
	Button MakePathButton,pos={90,85},size={83,20},proc=MakePathProc,title="Make Path"
	Button EditPathButton,pos={90,116},size={83,20},proc=EditPathProc,title="Edit Path"
	Button ProfileButton,pos={44,265},size={83,20},proc=ProfileProc,title="Do Profile"
	Button ProfileGraphButton,pos={137,265},size={83,20},proc=ProfileGraphProc,title="Graph"
	SetVariable setvar0,pos={28,220},size={216,18},title="Number of Points"
	SetVariable setvar0,limits={0,Inf,1},value= root:Packages:WMProfileProc:PR_NumProfPoints
	SetVariable SetOutWaveName,pos={28,242},size={217,18},title="Output Wave Name"
	SetVariable SetOutWaveName,limits={-Inf,Inf,1},value= root:Packages:WMProfileProc:PR_OutWaveName
	PopupMenu PathWavePopup,pos={51,6},size={87,21},title="Path trace:"
	PopupMenu PathWavePopup,mode=6,popvalue="",value= #"TraceNameList(\"\",\";\",1)"
	CheckBox InterpPathCheck,pos={50,157},size={160,20},proc=InterpCheckProc,title="Interpolate along path",value=1
	CheckBox AtPointsCheck,pos={50,177},size={160,20},proc=ProfileCheckProc,title="Profile at path wave points",value=0
EndMacro

//*******************************
// Recreation macro for perpendicular profile control panel
//*******************************

Window PerpProfPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(215,49,538,382) as "Perpendicular Profile"
	SetDrawLayer UserBack
	SetDrawEnv fillpat= 0,fillfgc= (48896,55552,65280)
	DrawRRect 34,83,292,270
	DrawRRect 55,194,271,221
	SetDrawEnv fstyle= 1
	DrawText 61,215,"Do It:"
	SetDrawEnv linebgc= (48896,59904,65280),fillpat= 0,fillfgc= (56576,56576,56576)
	DrawRect 46,91,278,150
	DrawRect 45,162,279,183
	Button AddXHair,pos={43,38},size={110,20},proc=AddXHair,title="Add Cross Hair"
	Button AddXHair,help={"Adds a cross-hair cursor to the top graph.\r\rYou will use the cross-hair to select a vertical or horizontal line along which a profile will be generated."}
	Button RmvXHair,pos={43,294},size={110,20},proc=RmvXHair,title="Rmv Cross Hair"
	Button RmvXHair,help={"Removes the cross-hair cursor from the top graph."}
	Button ProfVertical,pos={108,197},size={75,20},proc=MakePerpProfile,title="Vertical"
	Button ProfVertical,help={"Make a profile along the vertical cross-hair line."}
	Button ProfHorizontal,pos={189,197},size={75,20},proc=MakePerpProfile,title="Horizontal"
	Button ProfHorizontal,help={"Make a profile along the horizontal cross-hair line."}
	CheckBox InterpolateCheck,pos={58,99},size={98,17},proc=RadioCheck,title="Interpolate"
	CheckBox InterpolateCheck,help={"Check this if you want the profile to have values interpolated between the data points of the contour or image.\r\rThis check box works like a radio button with the At Grid Points checkbox."},value=0
	SetVariable setvar0,pos={156,99},size={111,14},title="# of Points:"
	SetVariable setvar0,help={"Sets the total number of points to be made for an interpolated profile.\r\rThis setting only has effect if the Interpolate checkbox is checked."}
	SetVariable setvar0,fSize=10
	SetVariable setvar0,limits={-Inf,Inf,1},value= root:Packages:WMProfileProc:PR_NumProfPoints
	CheckBox AtGridPointsCheck,pos={58,124},size={209,17},proc=RadioCheck,title="At Grid Points",value=1
	SetVariable OutWaveName,pos={47,164},size={231,14},title="Wave Name for Result:"
	SetVariable OutWaveName,help={"Edit this text box to set the name for the wave to receive the profile results.  Any pre-existing wave with the same name will be overwritten when one of the Do It buttons is clicked."}
	SetVariable OutWaveName,fSize=10
	SetVariable OutWaveName,limits={-Inf,Inf,1},value= root:Packages:WMProfileProc:PR_OutWaveName
	Button PerpGraph,pos={133,232},size={65,20},proc=ProfileGraphProc,title="Graph"
	Button PerpGraph,help={"Make a graph of the profile."}
EndMacro

Function AddXHair(ctrlName) : ButtonControl
	String ctrlName
	
	String dfSav= GetDataFolder(1)
	String wname= WinName(0, 1)
	
	if( strlen(wname) == 0 )
		Abort "no target graph"
	endif
	
	if (DataFolderExists("root:WinGlobals"))
		SetDataFolder root:WinGlobals
	else
		NewDataFolder/O/S root:WinGlobals
	endif
	NewDataFolder/O/S root:WinGlobals:$wname
	
//	String/G root:WinGlobals:HairlineCursorPanel:$"csrgraph"+num2istr(n)= wname
	
	Variable xm=0,ym=0
	
	String yw= "HairY",xw= "HairX"
	Make/O $yw={0,0,0,NaN,Inf,0,-Inf}
	Make/O $xw={-Inf,0,Inf,NaN,0,0,0}
	CheckDisplayed $yw
	Variable notup= V_Flag == 0
	if( notup )
		AppendToGraph $yw vs $xw
		ModifyGraph quickdrag($yw)=1,live($yw)=1
		ModifyGraph rgb($yw)=(0,0,0)		// black
	else
		Variable/C xy= PRGetWaveOffset($yw)
		xm= real(xy)
		ym= imag(xy)
	endif

	Variable x0,x1,y0,y1
	GetAxis/Q left; y0= V_min; y1= V_max
	GetAxis/Q bottom; x0= V_min; x1= V_max
	if( notup %| (xm < min(x0,x1)) %| (xm > max(x0,x1)) )
		xm= x0+(x1-x0)*.5
	endif
	if( notup %| (ym < min(y0,y1)) %| (ym > max(y0,y1)) )
		ym= y0+(y1-y0)*.5
	endif
	

	ModifyGraph offset($yw)={xm,ym}
	
//	Variable/G $"X"+num2istr(n)= xm
//	Variable/G $"Y"+num2istr(n)= ym
//	CreateUpdateZ("",n)

	String/G S_TraceOffsetInfo
	Variable/G hairTrigger
	SetFormula hairTrigger,"PRUpdateHairGlobals(S_TraceOffsetInfo)"
	
	SetDataFolder dfSav


End

// returns offset of given wave (assumed to be in top graph)
// xoffset is real part, yoffset is imaginary part
Function/C PRGetWaveOffset(w)
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

Function RmvXHair(ctrlName) : ButtonControl
	String ctrlName

	CheckDisplayed TraceNameToWaveRef("", "HairY")
	if( V_Flag != 0 )
		RemoveFromGraph $"HairY"
	endif
End

Function RadioCheck(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	if (cmpstr(ctrlName, "InterpolateCheck") == 0)
		if (checked)
			CheckBox AtGridPointsCheck value=0
		else
			CheckBox AtGridPointsCheck value=1
		endif
	else
		if (checked)
			CheckBox InterpolateCheck value=0
		else
			CheckBox InterpolateCheck value=1
		endif
	endif
End

Function MakePerpProfile(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR PR_OutWaveName=root:Packages:WMProfileProc:PR_OutWaveName
	
	NVAR nInterp=root:Packages:WMProfileProc:PR_NumProfPoints
	
	String wname= WinName(0, 1)
	String theDF = "root:WinGlobals:"+wname
	if (!DataFolderExists(theDF))
		abort "No crosshair information for this graph"
	endif
	NVAR xhairpos = $(theDF+":XPOS")
	NVAR yhairpos = $(theDF+":YPOS")

	String ContourList=ContourNameList("",";")
	String ContourName=WaveNameForProfile()
	Wave Wave2d=$(ContourName)
	String PathName
	Variable npnts
	Variable p1,p2,q1,q2,x1,x2,y1,y2, XVal, YVal, xinc, yinc
	Variable x0,deltax,y0,deltay, nrows, ncols
	Variable doHorizontal
	Variable/C chairpos
	Variable i, temp
	
	if (cmpstr(ctrlName, "ProfVertical") == 0)
		doHorizontal = 0
	else
		doHorizontal = 1
	endif
		
	GetAxis/Q bottom
	x1=V_min
	x2=V_max
	GetAxis/Q left
	y1=V_min
	y2=V_max
	
	chairpos = PRGetWaveOffset(w)
	
	x0 = DimOffset(Wave2d, 0)
	y0 = DimOffset(Wave2d, 1)
	deltax = DimDelta(Wave2d, 0)
	deltay = DimDelta(Wave2d, 1)
	nrows = DimSize(Wave2d, 0)
	ncols = DimSize(Wave2d, 1)
	p1 = (x1-x0)/deltax
	p2 = (x2-x0)/deltax
	if (p1 > p2)
		temp=p1
		p1 = p2
		p2 = temp
	endif
	if(p1 < 0)
		p1 = 0
	endif
	if (p2 > nrows-1)
		p2 = nrows-1
	endif

	q1 = (y1-y0)/deltay
	q2 = (y2-y0)/deltay
	if (q1 > q2)
		temp=q1
		q1 = q2
		q2 = temp
	endif
	if(q1 < 0)
		q1 = 0
	endif
	if (q2 > ncols-1)
		q2 = ncols-1
	endif
	
	ControlInfo/W=PerpProfPanel InterpolateCheck
	Variable DoInterp=V_value

	if (DoInterp)
		Make/D/O/N=(nInterp) $PR_OutWaveName
		Wave OutW=$PR_OutWaveName
		xinc = (x2-x1)/(nInterp-1)
		yinc = (y2-y1)/(nInterp-1)
		i = 0
		do
			if (doHorizontal)
				XVal = x1+xinc*i
				OutW[i] = interp2d(wave2D, XVal, yhairpos)
			else
				YVal = y1+yinc*i
				OutW[i] = interp2d(wave2D, xhairpos, YVal)
			endif
			i += 1
		while (i < nInterp)
	else
		if (doHorizontal)
			npnts = p2-p1+1
			YVal = round((yhairpos-y0)/deltay)
		else
			npnts = q2-q1+1
			XVal = round((xhairpos-x0)/deltax)
		endif
		Make/D/O/N=(npnts) $PR_OutWaveName
		Wave OutW=$PR_OutWaveName
		i = 0
		do
			if (doHorizontal)
				OutW[i] = wave2D[i+p1][YVal]
			else
				OutW[i] = wave2D[XVal][i+q1]
			endif
			i += 1
		while (i < npnts)
	endif
	if (doHorizontal)
		SetScale/I x x1,x2,OutW
	else
		SetScale/I x y1,y2,OutW
	endif
End

Function PRUpdateHairGlobals(tinfo)
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
		
	String dfSav= GetDataFolder(1)
	SetDataFolder thedf
	
	s= "XOFFSET:"
	p0=  StrSearch(tinfo,s,0)
	if( p0 >= 0 )
		p0 += strlen(s)
		p1= StrSearch(tinfo,";",p0)
		Variable/G $"XPOS"=str2num(tinfo[p0,p1-1])
	endif
	
	s= "YOFFSET:"
	p0=  StrSearch(tinfo,s,0)
	if( p0 >= 0 )
		p0 += strlen(s)
		p1= StrSearch(tinfo,";",p0)
		Variable/G $"YPOS"=str2num(tinfo[p0,p1-1])
	endif
	
	SetDataFolder dfSav
end
