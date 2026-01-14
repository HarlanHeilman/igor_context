#pragma version=1.1
//
//	Version 1.1,LH970912: used new ScreenResolution constant to get proper results under Windows
//
#pragma rtGlobals= 0		// this procedure has NOT been updated to use the new globals method

// NOTE: This procedure has not yet been updated to be Igor Pro 3.0 savvy. You
// should not use waves with liberal names or those residing in data folders
// other than root:.

#include <Strings as Lists>

//****************************************************
Menu "Macros"
	"Draw Probability Graph...", Probability_Axis()
end

Function  Probability_Axis()
	Variable/D sq=sqrt(2)
	Make/D/o/N=5000 tmp_qq_erf
	SetScale/I x,0,10,tmp_qq_erf
	 tmp_qq_erf=0.5*erf(x/sq)
	
	Variable/D/G	gPAC_Red
	Variable/D/G	gPAC_Green
	Variable/D/G	gPAC_Blue
	Variable/D/G	gPAC_LineWidth
	Variable/D/G	gPAC_LabelGrout
	Variable/D/G	gPAC_TicLength
	Variable/D/G	gPAC_FontFace
	Variable/D/G	gPAC_FontSize
	Variable/D/G	gPAC_Min
	Variable/D/G	gPAC_Max
		
	gPAC_Red=0
	gPAC_Green=0
	gPAC_Blue=0
	gPAC_LineWidth=1
	gPAC_LabelGrout=0.03
	gPAC_TicLength=0.02
	gPAC_FontFace=0
	gPAC_FontSize=10
	gPAC_Min=0.01
	gPAC_Max=0.99
	
	// DoWindow /T  probAxisControl, "Probability Axis Control"
	Execute("probAxisControl()")
end

//****************************************************

Function/D scalePosition(inx)
	Variable/D	inx
	String/g  	wName="tmp_qq_erf"
	Variable	smaller=0
	
	if(numType(inx)!=0)
		return(inx)
	endif
	
	NVAR gPAC_Min, gPAC_Max
	if((inx<gPAC_Min) %| (inx>gPAC_Max))		// establish limits
		return(NaN)
	endif

	if(inx==0.5)									// simple case-no need to calculate
		return(0)
	endif
	
	if(inx<0.5)
		smaller=1
		inx=0.5-inx
	else
		smaller=0
		inx=inx-0.5
	endif
	
	variable/d outx=NaN
	findLevel/q   $wName,inx
	if(V_flag==0)					// will return a Nan otherwise
		outx=V_LevelX
	endif
	
	if(smaller==0)
		return(outx)
	else
		return(-outx)
	endif
end

//****************************************************

//****************************************************

function drawProbabilityAxis(whichAxis,waveName,fontName,fontSize,fontFace,ticLen,labelGrout)
	Variable whichAxis,fontSize,fontFace,ticLen,labelGrout
	String waveName,fontName
	
	String topGraphWindowName=WinName(0,1)		//   find the top graph window
	DoWindow /F  $topGraphWindowName				//   bring to the front
	SetDrawLayer 	progAxes

	NVAR gPAC_LineWidth, gPAC_Red,gPAC_Green,gPAC_Blue
	SetDrawEnv linethick=gPAC_LineWidth
	SetDrawEnv linefgc=(gPAC_Red,gPAC_Green,gPAC_Blue)
	SetDrawEnv textrgb=(gPAC_Red,gPAC_Green,gPAC_Blue)
	SetDrawEnv save

	do
		if(whichAxis==1)
			GetAxis/Q bottom
			if(V_Flag==0)
				ModifyGraph noLabel(bottom)=2,axThick(bottom)=0
			endif
			drawline 0,1,1,1
			drawTics(1,waveName,fontName,fontSize,fontFace,ticLen,labelGrout)
			break
		endif
		
		if(whichAxis==2)
			GetAxis/Q left
			if(V_Flag==0)
				ModifyGraph noLabel(left)=2,axThick(left)=0
			endif
			drawline 0,0,0,1
			drawTics(2,waveName,fontName,fontSize,fontFace,ticLen,labelGrout)
			break
		endif
		
		if(whichAxis==3)
			GetAxis/Q right
			if(V_Flag==0)
				ModifyGraph noLabel(right)=2,axThick(right)=0
			endif
			drawline 1,0,1,1
			drawTics(3,waveName,fontName,fontSize,fontFace,ticLen,labelGrout)
			break
		endif
		
		if(whichAxis==4)
			GetAxis/Q top
			if(V_Flag==0)
				ModifyGraph noLabel(top)=2,axThick(top)=0			
			endif
			drawline 0,0,1,0
			drawTics(4,waveName,fontName,fontSize,fontFace,ticLen,labelGrout)
			break
		endif
	while(0)
end

//****************************************************
Function drawTics(which,waveName,fontName,fontSize,fontFace,ticLen,labelGrout)
	Variable 	which,fontSize,fontFace,ticLen,labelGrout
	String 		waveName,fontName
	
	Variable 	numTics=numpnts($waveName)
	variable 	i=0
	String		labelString
	Variable/D 	xPos
	Wave/D		w=$waveName
	
	// we are sorting the wave here
	sort w,w										
	
	NVAR gPAC_Min, gPAC_Max
	Variable/D	lowVal=scalePosition(gPAC_Min)
	Variable/D	highVal=scalePosition(gPAC_Max)

	if((lowVal<-50) %| (highVal<-50))
		Print "Processed wave contains bad values."
		Print lowVal,highVal
		return(0)
	endif
		
	Variable/D	scaleFactor=1.0/(highVal-lowVal)	
	
	Variable/D	offsetx,offsety		
	
	GetWindow $WinName(0,1), psize
	variable plotHeight=V_bottom-V_top
		
	ControlInfo /W=probAxisControl checkPercentLabel
	Variable convert2Percent=V_value
		
	if(which==1)		// bottom Axis
		offsety=ticLen+labelGrout+(fontSize/plotHeight)
		Variable offsetPts=offsety*plotHeight
		if((offsetPts/fontSize)<(1.7*fontSize))
			offsety=(1.7*fontSize)/plotHeight
		endif
		offsety+=0.02							// for 0.5 extension
		do
			if(numType(w[i])==0)
				if(convert2Percent==0)
					labelString=num2str(w[i])
				else
					labelString=num2str(100*w[i])
				endif
				
				xPos=(scalePosition(w[i])-lowVal)*scaleFactor
				if(w[i]==0.5)
					drawline  xPos,1,xPos,1+ticLen+0.02
				else
					drawline  xPos,1,xPos,1+ticLen
				endif
				drawHCenterLabel(xPos,1,labelString,0,offsety,fontName,fontSize,fontFace)
			endif
			i+=1
		while(i<numTics)
	endif
	
	if(which==4)		// top Axis
		offsety=-ticLen-labelGrout-0.02
		do
			if(numType(w[i])==0)
				if(convert2Percent==0)
					labelString=num2str(w[i])
				else
					labelString=num2str(100*w[i])
				endif
				xPos=(scalePosition(w[i])-lowVal)*scaleFactor
				if(w[i]==0.5)
					drawline  xPos,0,xPos,-ticLen-0.02
				else
					drawline  xPos,0,xPos,-ticLen
				endif
				drawHCenterLabel(xPos,0,labelString,0,offsety,fontName,fontSize,fontFace)
			endif
			i+=1
		while(i<numTics)
	endif

	if(which==2)		// left axis
		offsetx=-labelGrout-ticLen-0.02
		offsety=0
		do
			if(numType(w[i])==0)
				if(convert2Percent==0)
					labelString=num2str(w[i])
				else
					labelString=num2str(100*w[i])
				endif
				xPos=1-(scalePosition(w[i])-lowVal)*scaleFactor
				if(w[i]==0.5)
					drawline  0,xPos,-ticLen-0.02,XPos
				else
					drawline  0,xPos,-ticLen,XPos
				endif
				drawVCenterLabel(0,xPos,labelString,offsetx,offsety,fontName,fontSize,fontFace,which)
			endif
			i+=1
		while(i<numTics)
	endif
	
	if(which==3)		// right axis
		offsetx=labelGrout+ticLen+0.02
		offsety=0
		do
			if(numType(w[i])==0)
				if(convert2Percent==0)
					labelString=num2str(w[i])
				else
					labelString=num2str(100*w[i])
				endif
				xPos=1-(scalePosition(w[i])-lowVal)*scaleFactor
				if(w[i]==0.5)
					drawline  1,xPos,1+ticLen+0.02,XPos
				else
					drawline  1,xPos,1+ticLen,XPos
				endif
				drawVCenterLabel(1,xPos,labelString,offsetx,offsety,fontName,fontSize,fontFace,which)
			endif
			i+=1
		while(i<numTics)
	endif
end

//****************************************************
Function/D getLowValue(waveName)
	String waveName
	
	Wave/D 	w=$waveName;
	Variable 	i=0,num=numpnts(w)
	Variable/D	theVal
	
	do
		theVal=scalePosition(w[i])
		if(numType(theVal)==0)
			return(theVal)
		endif
		i+=1
	while(i<num)
	
	return(-200)				// an impossible value 
end

//****************************************************

Function/d getHighValue(waveName)
	String 		waveName
	Variable/D 	theVal
	
	Wave/D w=$waveName;
	Variable num=numpnts(w)
	num-=1
	do
		theVal=scalePosition(w[num])
		if(numType(theVal)==0)
			return(theVal)
		endif
		num-=1
	while(num>=0)
	return(-20)				// an impossible value  
end

//****************************************************

Function PopMenuProc_5(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	if(cmpstr(ctrlName,"popupSourceType")==0)
		if((popNum==1) %| (popNum==3))
			popupmenu popupPairedWave pos={1000,1000}
		else
			popupmenu popupPairedWave pos={249,24}
		endif
		if((popNum==4) %| (popNum==3))
			Checkbox checkProbPercent pos={11,22}
		else
			Checkbox checkProbPercent pos={1000,1000}
		endif
	endif

End

Function ButtonProc_5(ctrlName) : ButtonControl
	String ctrlName
		
	GetWindow $WinName(0,64) wsize							// works on top Panel

	if(cmpstr(ctrlName,"bFew")==0)
		Button $ctrlName, title="More Choices",rename=bMore
		MoveWindow  V_left,V_top,V_right,V_bottom-120*72/ScreenResolution
	else
		Button $ctrlName, title="Fewer Choices",rename=bFew
		MoveWindow  V_left,V_top,V_right,V_bottom+120*72/ScreenResolution
	endif
End

Window probAxisControl() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(14,238,495,393) as "Probability Axis Control"
	SetDrawLayer UserBack
	DrawLine 8,44,387,44
	DrawLine 8,120,387,120
	DrawLine 5,156,384,156
	Button button0,pos={9,129},size={90,20},proc=ButtonProc_7,title="New Graph"
	CheckBox checkMirror,pos={259,49},size={100,20},title="Mirror Axis",value=0
	PopupMenu popupSourceWave,pos={249,1},size={113,19},title="Source Wave:"
	PopupMenu popupSourceWave,mode=2,value= #"\"(_none_;\"+WaveList(\"!tmp_qq*\",\";\",\"\")"
	PopupMenu popupPairedWave,pos={1000,1000},size={111,19},title="Paired Wave:"
	PopupMenu popupPairedWave,mode=5,value= #"\"(_Calculated_;\"+WaveList(\"!tmp_qq*\",\";\",\"\")"
	Button button1,pos={541,133},size={150,20},proc=ButtonProc_6,title="Erase Probability Axis"
	PopupMenu popupHorV,pos={9,50},size={236,19},title="Plot Probability:"
	PopupMenu popupHorV,mode=1,value= #"\"Horizontal Axis;Vertical Axis\""
	PopupMenu popupSourceType,pos={10,2},size={179,19},proc=PopMenuProc_5,title="Data Type:"
	PopupMenu popupSourceType,mode=1,value= #"\"Raw 1 Wave;Raw 2 Waves;Processed 1 Wave;Processed 2 Waves\""
	SetVariable setvarMinRange,pos={11,98},size={180,17},title="Minimum Value:"
	SetVariable setvarMinRange,font="Chicago",limits={1e-10,0.9999,0.0001},value=gPAC_Min
	SetVariable setvarMaxRange,pos={205,98},size={180,17},title="Maximum Value:"
	SetVariable setvarMaxRange,font="Chicago",limits={0.0001,0.9999,0.001},value=gPAC_Max
	Button bMore,pos={246,128},size={120,20},proc=ButtonProc_5,title="More Choices"
	PopupMenu popupFont,pos={274,163},size={112,19},title="Font:"
	PopupMenu popupFont,mode=4,popvalue=GetDefaultFont(""),value= #"FontList(\";\")"
	PopupMenu popup1,pos={390,192},size={19,19},proc=PopMenuProc_6
	PopupMenu popup1,mode=0,value= #"\"5;7;9;10;12;14;18;24;36;48;72\""
	SetVariable setvarLabelGrout,pos={276,217},size={133,17},title="Label Grout:"
	SetVariable setvarLabelGrout,font="Chicago"
	SetVariable setvarLabelGrout,limits={0,1,0.01},value=gPAC_LabelGrout
	SetVariable setvarTicLen,pos={96,182},size={130,17},title="Tick-Length"
	SetVariable setvarTicLen,font="Chicago",limits={0,1,0.01},value=gPAC_TicLength
	CheckBox checkFontPlain,pos={3,159},size={50,20},proc=CheckProc_1,title="Plain",value=1
	CheckBox checkFontBold,pos={3,175},size={50,20},proc=CheckProc_1,title="Bold",value=0
	CheckBox checkFontItalic,pos={3,191},size={60,20},proc=CheckProc_1,title="Italic",value=0
	CheckBox checkFontUnderline,pos={3,207},size={90,20},proc=CheckProc_1,title="Underline",value=0
	CheckBox checkFontOutline,pos={3,223},size={90,20},proc=CheckProc_1,title="Outline",value=0
	CheckBox checkFontShadow,pos={3,239},size={80,20},proc=CheckProc_1,title="Shadow",value=0
	SetVariable setvarFontSize,pos={276,192},size={110,17},title="Font Size:"
	SetVariable setvarFontSize,font="Chicago",limits={0,INF,2},value=gPAC_FontSize
	SetVariable setvarLineWidth,pos={96,161},size={160,17},title="Line Width:"
	SetVariable setvarLineWidth,font="Chicago",limits={0,INF,1},value=gPAC_LineWidth
	SetVariable setvarRed,pos={96,208},size={128,17},title="Red:",font="Chicago"
	SetVariable setvarRed,limits={0,65535,256},value=gPAC_Red
	SetVariable setvarGreen,pos={96,228},size={129,17},title="Green:",font="Chicago"
	SetVariable setvarGreen,limits={0,65535,256},value=gPAC_Green
	SetVariable setvarBlue,pos={97,249},size={128,17},title="Blue",font="Chicago"
	SetVariable setvarBlue,limits={0,65535,256},value=gPAC_Blue
	CheckBox checkProbPercent,pos={1000,1000},size={160,20},title="Probability data in %",value=0
	PopupMenu popupTicSource,pos={11,73},size={186,19},proc=PopMenuProc_7,title="Tick Marks"
	PopupMenu popupTicSource,mode=1,value= #"\"_Calculated_;\"+WaveList(\"!tmp_qq*\",\";\",\"\")"
	CheckBox checkGrid,pos={260,71},size={50,20},title="Grid",value=1
	CheckBox checkPercentLabel,pos={275,241},size={100,20},title="Label in %",value=0
EndMacro

Function PopMenuProc_6(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	if(strlen(popstr)>0)
		NVAR gPAC_FontSize
		gPAC_FontSize=str2num(popStr)
	endif
End


//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

Function PA_setFontFace()
	ControlInfo /W=probAxisControl checkFontPlain
	NVAR gPAC_FontFace
	gPAC_FontFace=0
	if(V_value==1)	
		CheckBox checkFontPlain value=1
		CheckBox checkFontBold value=0
		CheckBox checkFontItalic value=0
		CheckBox checkFontUnderline value=0
		CheckBox checkFontOutline value=0
		CheckBox checkFontShadow value=0
	else
		ControlInfo /W=probAxisControl checkFontBold
		if(V_value)
			gPAC_FontFace+=1
		endif
		ControlInfo /W=probAxisControl checkFontItalic
		if(V_value)
			gPAC_FontFace+=2
		endif
		ControlInfo /W=probAxisControl checkFontUnderline
		if(V_value)
			gPAC_FontFace+=4
		endif
		ControlInfo /W=probAxisControl checkFontOutline
		if(V_value)
			gPAC_FontFace+=8
		endif
		ControlInfo /W=probAxisControl checkFontShadow
		if(V_value)
			gPAC_FontFace+=16
		endif
	endif
end
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

Function CheckProc_1(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	if(cmpstr(ctrlName,"checkFontPlain")!=0)
		CheckBox checkFontPlain value=0
	endif
	PA_setFontFace()
End

//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


Function ButtonProc_6(ctrlName) : ButtonControl		// erase button
	String ctrlName
	
	String topGraphWindowName=WinName(0,1)		//   find the top graph window
	DoWindow /F  $topGraphWindowName				//   bring to the front
	SetDrawLayer/k progAxes
	DoWindow/F probAxisControl						//  bring to front the control window
	
End

//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

Function ButtonProc_7(ctrlName) : ButtonControl
	String ctrlName

	probAxisMain()
End

//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

Function probAxisMain()
	
	// first order of business is to find out what is the input
	
	ControlInfo /W=probAxisControl popupSourceType
	Variable 		sourceType=V_value
	String			SourceFileA,SourceFileB=""

	// 	SourceFileA is needed in each case 
	
	ControlInfo /W=probAxisControl popupSourceWave
	SourceFileA=itemNumber2waveName(V_value-1)

	if((V_value==1) %| (strlen(SourceFileA)<=0))
		beep
		print V_value,SourceFileA
		print "You must specify a source wave."
		return(-1)
	endif

	ControlInfo/W=probAxisControl setvarMinRange
	NVAR gPAC_Min, gPAC_Max
	gPAC_Min=V_value
	ControlInfo/W=probAxisControl setvarMaxRange
	gPAC_Max=V_value
	
	ControlINfo /W=probAxisControl popupHorV
	Variable plotDirection=V_value
	
	Variable needsProcessing=0
	
	do
		if(sourceType==1)
			needsProcessing=1
			break
		endif
		
		if(sourceType==2)
			ControlInfo /W=probAxisControl popupPairedWave
			// we do not need to load the name "calculated" on the string
			if(V_value>1)
				SourceFileB=itemNumber2waveName(V_value-1)
			endif
			needsProcessing=2
			break
		endif
		
		if(sourceType==3)
			break
		endif
		
		if(sourceType==4)
			ControlInfo /W=probAxisControl popupPairedWave
			SourceFileB=itemNumber2waveName(V_value-1)
			break
		endif
	while(0)
	
	
	// pre-process the data if necessary
		
	if(needsProcessing>0)
		String processedName="processed_"
		probAxisProcess(needsProcessing,SourceFileA,SourceFileB,processedName)
	endif
		
	// at this point we have 2 or 3 waves, from which we plot two depending
	// on the Horizontal or vertical choice
	// plotDirection=1 for horizontal, 2 for vertical
	
	do
		if(needsProcessing==0)
			ControlInfo /W=probAxisControl checkProbPercent
			if(V_value==1)	// if data is in % divide by 100
				String	 	 	newSourceFile="Source_100"
				Duplicate/O 	$SourceFileA,$newSourceFile
				Wave 			w=$newSourceFile
				w=w/100
				plotProbabilityWaves(newSourceFile,SourceFileB,plotDirection)			
			else
				plotProbabilityWaves(SourceFileA,SourceFileB,plotDirection)
			endif
			break
		endif
	
		if(needsProcessing==1)
			plotProbabilityWaves(processedName,SourceFileA,plotDirection)
			break
		endif
		
		if(needsProcessing==2)
			plotProbabilityWaves(processedName,SourceFileB,plotDirection)
			break
		endif
	while(0)
	
	cleanup()
end

//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

function cleanup()
	KillWaves/z $"tmp_qq_ticWave"
end

//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
//	
//	plotProbabilityWaves:	we assume that waveA contains the range [0,1)
//							and that waveB contains some arb values.
//							We scale waveA using the probability scale and
//							plot the resultant against waveB depending on the 
//							specified direction
//
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

Function plotProbabilityWaves(waveA,waveB,plotDirection)
	String 		waveA,waveB
	Variable 	plotDirection

	Wave/D 		tmp_qq_a=$waveA
	Wave/D			tmp_qq_b=$waveB
	String			dupWaveName=waveA+"_d"
	
	SetDrawEnv	 gstart					//	start grouping here

	Variable 		index=0
	do
		sprintf  dupWaveName "%s_d%d",waveA,index
		index+=1
	while(exists(dupWaveName)!=0)
	
	Duplicate/O  	tmp_qq_a,$dupWaveName
	Wave/D			tmp_qq_aDup=$dupWaveName
		
	tmp_qq_aDup=scalePosition(tmp_qq_aDup)
	
	Variable/D  z,n,normalization
		
	ControlInfo/W=probAxisControl setvarTicLen
	NVAR gPAC_TicLength, gPAC_FontSize, gPAC_LabelGrout
	gPAC_TicLength=V_value
	ControlInfo/W=probAxisControl setvarFontSize
	gPAC_FontSize=V_value
	ControlInfo/W=probAxisControl setvarLabelGrout
	gPAC_LabelGrout=V_value

	ControlInfo /W=probAxisControl popupFont
	String fontName= S_value
	
	
	ControlInfo/W=probAxisControl checkMirror
	Variable mirror=V_value
	ControlInfo/W=probAxisControl checkGrid
	Variable isGrid=V_value
	
	String TicWaveName=""
	ControlInfo/W=probAxisControl popupTicSource
	
	if(V_value>1)
		TicWaveName=tickWave2MinMax(V_value)
	endif
	
	NVAR gPAC_Min, gPAC_MAX
	if(gPAC_Min>=gPAC_Max)
		Abort "limits must be Low->High"
		SetDrawEnv gstop			// 	end grouping
		return(-1)
	endif
	
	z=scalePosition(gPAC_Min)
	n=scalePosition(gPAC_Max)
	
	normalization=1/(n-z)
	tmp_qq_aDup=(tmp_qq_aDup-z)*normalization

	// Duplicate/o tmp_qq_aDup,$"NewDup"
	// Edit $"NewDup"
	
	if(strlen(TicWaveName)<=0)
		TicWaveName=setDefProbTics()
	endif
	
	if(plotDirection==1)
		if(strlen(waveB)<=0)							// there is no wave name to plot against
			String  		localName="tmp_qq_run"
			Variable 	num=numpnts(tmp_qq_aDup)
			make/D/O/N=(num) $localName=x
			Wave/D 	tmp_qq_c=$localName
			SetScale/I 	x,0,num,tmp_qq_c
			Display 	tmp_qq_c vs tmp_qq_aDup	
		else
			Display tmp_qq_b vs tmp_qq_aDup	
		endif
		
		SetAxis bottom 0,1
		
		NVAR gPAC_FontFace
		drawProbabilityAxis(1,TicWaveName,fontName,gPAC_FontSize,gPAC_FontFace,gPAC_TicLength,gPAC_LabelGrout)
		if(mirror)
			ModifyGraph margin(top)=70
			drawProbabilityAxis(4,TicWaveName,fontName,gPAC_FontSize,gPAC_FontFace,gPAC_TicLength,gPAC_LabelGrout)
		endif
		if(isGrid)
			drawProbGrid(1,TicWaveName)
			ModifyGraph grid(left)=1
		endif
	else
		if(strlen(waveB)>0)							// there exists a wave name to plot against
			Display  tmp_qq_aDup vs tmp_qq_b		
		else
			Display tmp_qq_aDup
		endif
		
		SetAxis left 0,1
		drawProbabilityAxis(2,TicWaveName,fontName,gPAC_FontSize,gPAC_FontFace,gPAC_TicLength,gPAC_LabelGrout)
		if(mirror)
			ModifyGraph margin(right)=70
			drawProbabilityAxis(3,TicWaveName,fontName,gPAC_FontSize,gPAC_FontFace,gPAC_TicLength,gPAC_LabelGrout)
		endif
		if(isGrid)
			drawProbGrid(2,TicWaveName)
			ModifyGraph grid(bottom)=1
		endif
	endif	
	ModifyGraph mode=3,marker=41
	SetDrawEnv gstop			// 	end grouping
end

//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

Function/S  itemNumber2waveName(item)
	Variable item
	
	String local=GetStrFromList(WaveList("!tmp_qq*",";" , ""), item-1, ";")
	
	return (GetStrFromList(WaveList("!tmp_qq*",";" , ""), item-1, ";"))
end

//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
//
//	probAxisProcess:	Requires input for the needsProcessing flag and 3 names.
//						
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

Function probAxisProcess(needsProcessing,SourceFileA,SourceFileB,processedName)
	Variable 	needsProcessing
	String		SourceFileA,SourceFileB,processedName
	
	Wave/D		w1=$SourceFileA
	Wave/D		tmp_qq_b=$SourceFileB
		
		
	Sort w1,w1									
	Variable numPoints=numpnts(w1)
	Make/D/O/N=(numPoints)    $processedName
	Wave/D			w3=$processedName			// must follow the duplicate
	SetScale /I x,1,numPoints,w3
	w3=x											// set to the initial population number
		
	Duplicate/O 	w1,$"tmp_qqDup"
	Wave/D			tmp_qq_a2=$"tmp_qqDup"
	
	if(needsProcessing==1)
		Sort tmp_qq_a2,tmp_qq_a2					// sorting the duplicated not original		
	else
		Sort tmp_qq_a2,tmp_qq_a2	,tmp_qq_b		// reorder the second wave if necessary;	
	endif
	
	Variable i=1
	Variable j
	// Handle the case of equal values
		
	do
		if(tmp_qq_a2[i]==tmp_qq_a2[i-1])
			j=i
			do
				w3[j]-=1
				j+=1
			while((j<numPoints) %& (tmp_qq_a2[j]==tmp_qq_a2[j-1]))
			i=j
		endif
		i+=1
	while(i<numPoints)	
	
	// Find the Fraction of the population below each value
	// qqq  Comment the following line for dividing by the total number of points
	numPoints+=1
	w3=w3/numPoints

	KillWaves/z	tmp_qq_a2							// cleanup
end

//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

Function drawProbGrid(which,TicWaveName)
	Variable 	which
	String 		TicWaveName
	
	Variable/D 		i=0,xp,first=0
	Wave/D			w=$TicWaveName
	Variable		num=numpnts(w)
	
	Variable/D	lowVal=getLowValue(TicWaveName)
	Variable/D	highVal=getHighValue(TicWaveName)
	
	if((lowVal<-50) %| (highVal<-50))
		Print "Processed wave contains bad values."
		Print lowVal,highVal
		return(0)
	endif
		
	Variable/D	scaleFactor=1.0/(highVal-lowVal)	

	Variable 	last=num
	Variable	sub
		
	do
		if(numType(w[num-1])==0)
			last=num-2
			break
		endif
		num-=1
	while(num>2)
	
	// the following loop does not draw a grid line at the first and
	// the last points
	
	do
		if(numType(w[first])==0)
			i=first+1
			break
		endif
		first+=1
	while(first<last)
			
	if(which==1)							// vertical grid
		do
			xp=(scalePosition(w[i])-lowVal)*scaleFactor
			if(numType(xp)==0)
				SetDrawEnv linefgc=(0x6000,0x6000,0xffff)
				SetDrawEnv dash= 1
				drawline xp,0,xp,1
			endif
			i+=1
		while(i<=last)
	else										// Horizontal grid
		do
			xp=(scalePosition(w[i])-lowVal)*scaleFactor
			if(numType(xp)==0)
				SetDrawEnv linefgc=(0x6000,0x6000,0xffff)
				SetDrawEnv dash= 1
				drawline 0,xp,1,xp
			endif
			i+=1
		while(i<=last)
	endif
end

//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

function drawHCenterLabel(x1,y1,labelString,offsetx,offsety,fontName,fontSize,fontFace)
	String 		fontName
	Variable 	fontSize
	Variable	 fontFace
	Variable 	x1,y1,offsetx,offsety
	String		labelString
	
	// Note, the following needs to be converted into a string and then executed
	
	execute "SetDrawEnv fname= \""+fontName +"\""
	SetDrawEnv 	fsize=fontSize
	SetDrawEnv 	fstyle=fontFace

	SetDrawEnv textxjust=1
	DrawText x1+offsetx,y1+offsety,labelString
end

//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
//
// primitive that draws a centered label for left or right axis
// x and y offsets are in plot relative fractions
//
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


function drawVCenterLabel(x1,y1,labelString,offsetx,offsety,fontName,fontSize,fontFace,which)
	String 		fontName
	Variable 	fontSize
	Variable 	fontFace
	Variable	which
	Variable 	x1,y1,offsetx,offsety
	String		labelString
	
	// Note, the following needs to be converted into a string and then executed
	
	execute("SetDrawEnv     fname=\""+fontName+"\"");
	SetDrawEnv 	fsize=fontSize
	SetDrawEnv 	fstyle=fontFace

	if(which==3)						// right axis we want left justified labels
		SetDrawEnv textxjust=0
	elseif(which==2)						// left axis has 
			SetDrawEnv textxjust=2
	endif
	
	SetDrawEnv textyjust=1
	DrawText x1+offsetx,y1+offsety,labelString
end

//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

Function PopMenuProc_7(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	if(popNum>1)
		SetVariable setVarMinRange pos={1000,1000}
		SetVariable setVarMaxRange pos={1000,1000}
		tickWave2MinMax(popNum)
	else
		SetVariable setVarMinRange pos={11,98}
		SetVariable setVarMaxRange pos={205,98}
		ControlInfo/W=probAxisControl setvarMinRange
		NVAR gPAC_Min, gPAC_Max
		gPAC_Min=V_value
		ControlInfo/W=probAxisControl setvarMaxRange
		gPAC_Max=V_value
	endif
End


//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	// in the following we set up a local tick mark wave for the case that the user
	// specifies only external limits.  We use a fixed wave for standard interval and
	// verify that all points  in the wave fall between the min and max limits
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

Function/S setDefProbTics()
	
	String waveName

		waveName="tmp_qq_ticWave"
		Make/D/O  	$waveName={NaN,Nan,0.01,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,0.99,NaN,Nan}
		Wave/D		ww=$waveName
		
		NVAR gPAC_Min, gPAC_Max
		ControlInfo/W=probAxisControl setvarMinRange
		gPAC_Min=V_value
		ControlInfo/W=probAxisControl setvarMaxRange
		gPAC_Max=V_value
	
		if(gPAC_Min<0.01)
			if(gPAC_Min<0.001)
				ww[0]=gPAC_Min
				ww[1]=0.001
			else
				ww[1]=gPAC_Min
			endif
			
		endif
		
		variable num=numpnts(ww)
		if(gPAC_Max>0.99)
			if(gPAC_Max>0.999)
				ww[num-2]=0.999
				ww[num-1]=gPAC_Max
			else
				ww[num-2]=gPAC_Max
			endif
		endif
		
		variable i=0
		variable/D  zz
		do
			zz=ww[i]
			if((ww[i]<gPAC_Min) %| (ww[i]>gPAC_Max))
				ww[i]=NaN
			endif
			i+=1
		while(i<num)
		
	return(waveName)
end



Function/S tickWave2MinMax(pop_value)
	Variable pop_value
	
	String 	TicWaveName=""
	TicWaveName=itemNumber2waveName(pop_value-1)
	// set the min and max if the user specifies a wave of tickmarks
	if(strlen(TicWaveName)>0)	
		Wave/D  whatever=$TicWaveName
		Sort whatever,whatever						// qq sort 1
		NVAR gPAC_Min, gPAC_Max
		gPAC_Min=whatever[0]
		gPAC_Max=whatever[numpnts(whatever)-1]
	endif
	
	return(TicWaveName)
End