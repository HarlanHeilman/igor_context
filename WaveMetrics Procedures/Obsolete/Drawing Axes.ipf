#pragma TextEncoding = "UTF-8"
#pragma version=1.11
//
//	Version 1.11, JP971218: fixed prepDerivedAxis to use root: data folder,
//		fixed reciprocal axis labels disappearing bug in drawTickMarkWave().
//	Version 1.1,LH970912: used new ScreenResolution constant to get proper results under Windows
//
#pragma rtGlobals= 1

Menu "Macros"
	"Draw Derived Axis...", prepDerivedAxis()
end

////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////

Function prepDerivedAxis()
	Pauseupdate; Silent 1
	
	if (wintype("DerivedAxisControl") == 7)
		DoWindow/F DerivedAxisControl
		return 0
	endif
	
	String dfSav= GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S WM_DrawingAxis
	
	variable/g 	gDA_AxisLineWidth=1
	variable/g 	gDA_TicsLineWidth=1
	variable/g 	gDA_TicLength=0.03
	variable/g 	gDA_refAxis=1
	variable/g	gDA_FontSize=10
	variable/g	gDA_FontFace=0
	variable/g 	gDA_AxisToDraw=4
	variable/g	gDA_StartDerivedAxis=0
	variable/g 	gDA_EndDerivedAxis=100
	variable/g 	gDA_LabelGrout=0.02		// affects which ticks are labeled
	variable/g	gDA_LineRed
	variable/g	gDA_LineGreen
	variable/g	gDA_LineBlue
	variable/g	gDA_TextRed
	variable/g	gDA_TextGreen
	variable/g	gDA_TextBlue
	variable/g	gDA_SignificantDigits
	variable/g	gDA_LowerLimit=0
	variable/g	gDA_UpperLimit=100
	variable/g	gDA_Interval=20
	variable/g	gDA_requestedTicMarks=5
	String/g	gDA_ScalingFunc	

//	Variable/g	gWantsGrids		//  qqq not implemented yet

	Execute("DerivedAxisControl()")
	DoWindow /C  DerivedAxisControl
	DoWindow /T  DerivedAxisControl, "Draw Axis Control"

	SetDataFolder dfSav
end

////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////

Function ButtonProcEraseLayer(ctrlName) : ButtonControl
	String ctrlName

	String topGraphWindowName=WinName(0,1)		//   find the top graph window
	DoWindow /F  $topGraphWindowName				//   bring to the front
	SetDrawLayer/K	progAxes						//   erase the whole layer
	DoWindow /F  DerivedAxisControl					//   bring the panel back to front
End
////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////

Function myDrawDerivedAxis()
	NVAR 	gDA_AxisLineWidth=root:Packages:WM_DrawingAxis:gDA_AxisLineWidth
	NVAR 	gDA_refAxis=root:Packages:WM_DrawingAxis:gDA_refAxis
	NVAR	gDA_StartDerivedAxis=root:Packages:WM_DrawingAxis:gDA_StartDerivedAxis
	NVAR 	gDA_EndDerivedAxis=root:Packages:WM_DrawingAxis:gDA_EndDerivedAxis
	NVAR	gDA_LineRed=root:Packages:WM_DrawingAxis:gDA_LineRed
	NVAR	gDA_LineGreen=root:Packages:WM_DrawingAxis:gDA_LineGreen
	NVAR	gDA_LineBlue=root:Packages:WM_DrawingAxis:gDA_LineBlue
	NVAR	gDA_TextRed=root:Packages:WM_DrawingAxis:gDA_TextRed
	NVAR	gDA_TextGreen=root:Packages:WM_DrawingAxis:gDA_TextGreen
	NVAR	gDA_TextBlue=root:Packages:WM_DrawingAxis:gDA_TextBlue
	NVAR 	gDA_AxisToDraw=root:Packages:WM_DrawingAxis:gDA_AxisToDraw
	
	
	// get info from the controls now 
	ControlInfo popupNewPosition	
	gDA_AxisToDraw=V_value
	
	ControlInfo popupDerivedScaling	
	variable	scalingType=V_value
	
	variable	defFunc
	Variable	refAxis
	
	gDA_refAxis=refAxis
	
	String topGraphWindowName=WinName(0,1)		//   find the top graph window
	DoWindow /F  $topGraphWindowName
	
	SetDrawEnv xcoord=prel	
	SetDrawEnv ycoord=prel
	// SetDrawLayer/K	progAxes		// qqq 	just for testing: cleanup first
	SetDrawLayer	progAxes		
	SetDrawEnv	 gstart					//	start grouping here
	SetDrawEnv xcoord=prel			//	make sure they move correctly with the graph
	SetDrawEnv ycoord=prel
	SetDrawEnv linefgc=(gDA_LineRed,gDA_LineGreen,gDA_LineBlue)
		
	variable 	a,b,c,d;
	
	do
		if(gDA_AxisToDraw==1)				// 	bottom
			a=1;	b=gDA_StartDerivedAxis/100;	c=gDA_EndDerivedAxis/100;	d=a
			break
		endif
		
		if(gDA_AxisToDraw==4)				//	Top
			a=0;	b=gDA_StartDerivedAxis/100;	c=gDA_EndDerivedAxis/100;	d=a
			break;
		endif
		
		if(gDA_AxisToDraw==3)				//	Right
			d=(100-gDA_StartDerivedAxis)/100;	b=1;	c=1	;	a=(100-gDA_EndDerivedAxis)/100
		endif
		
		if(gDA_AxisToDraw==2)				//	Left
			d=(100-gDA_StartDerivedAxis)/100;	b=0;	c=0;	a=(100-gDA_EndDerivedAxis)/100
		endif
	while(0)
	
	//  Actually Drawing The Axis 	
	if(gDA_AxisLineWidth!=1)
		SetDrawEnv linethick=gDA_AxisLineWidth
	endif
	DrawLine 	b,a,c,d		
	
	// Now add the tic marks and labels based on user selected options
	
	// arbitrary scaling based on user specified interval
	if(scalingType==1)			// 	User specified interval
		myDrawEqualSpaceTicMarks(gDA_AxisToDraw,a,b,c,d,0)	
	endif	
	
	if(scalingType==2)
		DrawArbTicMarks(gDA_AxisToDraw,a,b,c,d)
	endif

	if(gDA_AxisLineWidth!=1)
		SetDrawEnv linethick=1
	endif
	SetDrawEnv gstop			// 	end grouping
	SetDrawLayer	UserFront	
end

////////////////////////////////////////////////////////////////////
//
// primitive that draws a centered label for top or bottom axis
// x and y offsets are in plot relative %
//
////////////////////////////////////////////////////////////////////


function drawHorizCenterLabel(x1,y1,labelString,offsetx,offsety,fontName,fontSize,fontFace)
	String fontName
	variable fontSize
	variable fontFace
	variable x1,y1,offsetx,offsety
	string	labelString
	String	cmdStr
	
	NVAR	gDA_TextRed=root:Packages:WM_DrawingAxis:gDA_TextRed
	NVAR	gDA_TextGreen=root:Packages:WM_DrawingAxis:gDA_TextGreen
	NVAR	gDA_TextBlue=root:Packages:WM_DrawingAxis:gDA_TextBlue
	NVAR	gDA_FontFace=root:Packages:WM_DrawingAxis:gDA_FontFace

	// Note, the following needs to be converted into a string and then executed
	
	execute "SetDrawEnv fname= \""+fontName +"\""
	SetDrawEnv textrgb=(gDA_TextRed,gDA_TextGreen,gDA_TextBlue)

	SetDrawEnv 	fsize=fontSize
	SetDrawEnv 	fstyle=gDA_FontFace

	SetDrawEnv textxjust=1
	DrawText x1+offsetx,y1+offsety,labelString
end

////////////////////////////////////////////////////////////////////
//
// primitive that draws a centered label for left or right axis
// x and y offsets are in plot relative fractions
//
////////////////////////////////////////////////////////////////////


function drawVertCenterLabel(x1,y1,labelString,offsetx,offsety,fontName,fontSize,fontFace,which)
	String 		fontName
	variable 	fontSize
	variable 	fontFace
	Variable	which
	variable 	x1,y1,offsetx,offsety
	string		labelString
	String		cmdStr
	
	NVAR	gDA_TextRed=root:Packages:WM_DrawingAxis:gDA_TextRed
	NVAR	gDA_TextGreen=root:Packages:WM_DrawingAxis:gDA_TextGreen
	NVAR	gDA_TextBlue=root:Packages:WM_DrawingAxis:gDA_TextBlue
	NVAR	gDA_FontFace=root:Packages:WM_DrawingAxis:gDA_FontFace

	// Note, the following needs to be converted into a string and then executed
	
	execute("SetDrawEnv 	fname=\""+fontName+"\"");
	
	SetDrawEnv 	textrgb=(gDA_TextRed,gDA_TextGreen,gDA_TextBlue)
	SetDrawEnv 	fsize=fontSize
	SetDrawEnv 	fstyle=gDA_FontFace

	if(which==3)							// right axis we want left justified labels
		SetDrawEnv textxjust=0
	elseif(which==2)						// left axis has 
			SetDrawEnv textxjust=2
	endif
	
	SetDrawEnv textyjust=1
	DrawText x1+offsetx,y1+offsety,labelString
end



////////////////////////////////////////////////////////////////////
//
// primitive that draws a single ticmark
//
////////////////////////////////////////////////////////////////////


function drawSingleTic(x1,y1,x2,y2)
	variable x1,y1,x2,y2

	NVAR	gDA_LineRed=root:Packages:WM_DrawingAxis:gDA_LineRed
	NVAR	gDA_LineGreen=root:Packages:WM_DrawingAxis:gDA_LineGreen
	NVAR	gDA_LineBlue=root:Packages:WM_DrawingAxis:gDA_LineBlue
	NVAR 	gDA_TicsLineWidth=root:Packages:WM_DrawingAxis:gDA_TicsLineWidth
	
	SetDrawEnv linefgc=(gDA_LineRed,gDA_LineGreen,gDA_LineBlue)
	SetDrawEnv linethick=gDA_TicsLineWidth
	DrawLine	x1,y1,x2,y2	
end


////////////////////////////////////////////////////////////////////
//
//	make_f_Label:	makes a floating point label based on the number of digits provided
//					if digits<0 	then it uses the default representation (%g)
//
////////////////////////////////////////////////////////////////////

function/S  make_f_Label(value,digits)
	variable/d value,digits
	
	String		formatString="%."
	String		dig=num2str(digits)
	String		labelString
	
	if(digits>=0)
		formatString=formatString+dig+"f"
	else
		formatString="%g"
	endif
		
	if(numType(value)==1)
		labelString="∞"
	else
		sprintf  labelString, formatString ,  value
	endif
	
	return(labelString)
end


////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////

Function drawLineColor()
	DoWindow /F DerivedAxisControl
	SetDrawLayer /K userBack

	NVAR	gDA_LineRed=root:Packages:WM_DrawingAxis:gDA_LineRed
	NVAR	gDA_LineGreen=root:Packages:WM_DrawingAxis:gDA_LineGreen
	NVAR	gDA_LineBlue=root:Packages:WM_DrawingAxis:gDA_LineBlue
	NVAR	gDA_TextRed=root:Packages:WM_DrawingAxis:gDA_TextRed
	NVAR	gDA_TextGreen=root:Packages:WM_DrawingAxis:gDA_TextGreen
	NVAR	gDA_TextBlue=root:Packages:WM_DrawingAxis:gDA_TextBlue

	SetDrawEnv fillfgc= (gDA_LineRed,gDA_LineGreen,gDA_LineBlue);DelayUpdate
	DrawRect 10,321,60,371
	
	SetDrawEnv fillfgc= (gDA_TextRed,gDA_TextGreen,gDA_TextBlue);DelayUpdate
	DrawRect 240,321,290,371
end



////////////////////////////////////////////////////////////////////
//
//	draws a set of equally spaced tic marks based 
//	on info entered by the user
//
////////////////////////////////////////////////////////////////////

Function myDrawEqualSpaceTicMarks(which,a,b,c,d,attemptNiceLabels)
	variable		which,attemptNiceLabels
	variable/d  		a,b,c,d

	NVAR	gDA_SignificantDigits=root:Packages:WM_DrawingAxis:gDA_SignificantDigits
	NVAR	gDA_LowerLimit=root:Packages:WM_DrawingAxis:gDA_LowerLimit
	NVAR	gDA_UpperLimit=root:Packages:WM_DrawingAxis:gDA_UpperLimit
	NVAR	gDA_Interval=root:Packages:WM_DrawingAxis:gDA_Interval
	NVAR 	gDA_TicLength=root:Packages:WM_DrawingAxis:gDA_TicLength
	NVAR	gDA_FontSize=root:Packages:WM_DrawingAxis:gDA_FontSize
	NVAR 	gDA_LabelGrout=root:Packages:WM_DrawingAxis:gDA_LabelGrout
	NVAR	gDA_FontFace=root:Packages:WM_DrawingAxis:gDA_FontFace

	variable 		numDigits=gDA_SignificantDigits;
	
	
	GetWindow $WinName(0,1), psize
	variable plotWidth=V_right-V_left
	variable plotHeight=V_bottom-V_top
		
	if(gDA_Interval==0)
		Abort "Interval value should not be zero"
		// since abort does not work as one would expect,
		// the following will set default to 5 ticks
		gDA_Interval=(gDA_UpperLimit-gDA_LowerLimit)/5
	endif
	
	variable 	nTics=(gDA_UpperLimit-gDA_LowerLimit)/gDA_Interval
	
	if(nTics==0)
		Abort	"The number of tick-marks must be positive."
		return(0);
	else
		if(nTics>99)
			Abort	"The number of tick-marks should not exceed 99."
			return(0);
		endif
	endif
	
	// now lets see if it generates "nice" labels
	

	if(attemptNiceLabels)
		if((numType(gDA_LowerLimit)!=0) %| (numType(gDA_UpperLimit)!=0))
			beep
			print "Round labels are not enabled for infinite limits."
		else
			Make /o/N=5 tmpData		
			tmpData[0]=gDA_LowerLimit
			tmpData[1]=gDA_UpperLimit
			tmpData[2]=nTics
				
			makeSmartLabels(tmpData)
			
			gDA_LowerLimit=tmpData[0]
			gDA_UpperLimit=tmpData[1]
			nTics=tmpData[2]
			numDigits=tmpData[4]
			killWaves tmpData
		endif
	endif
	
	if(nTics<1)
		Abort	"The number of tick-marks must be greater than 1."
		return(0);
	else
		if(nTics>99)
			Abort	"The number of tick-marks should not exceed 99."
			return(0);
		endif
	endif
	
	gDA_Interval=(gDA_UpperLimit-gDA_LowerLimit)/nTics
		
	// case statement should start here
	// but we are just testing now
	
	variable	maxPosition,minPosition
	variable	y1,y2,x1,x2
	variable 	delta
	variable/d	valueAtTic
	string		labelString
	String		formatString="%."
	String		dig=num2str(numDigits)
	
	formatString=formatString+dig+"f"
	
	variable	value=gDA_LowerLimit
	
	ControlInfo/W=DerivedAxisControl popupFont
	String fontStringName=S_value
	
	variable fontFace=gDA_FontFace			
			
	// case statement for the different locations of the derived axis
	//
	do
		if(which==4)						// Top Axis
			maxPosition=c
			minPosition=b
			delta=((maxPosition-minPosition)/nTics)
			y1=0
			y2=- gDA_TicLength
			do
				x1=c-nTics*delta
				drawSingleTic(x1,y1,x1,y2)
				sprintf  labelString, formatString , value
				drawHorizCenterLabel(x1,y1,labelString,0,-gDA_LabelGrout-gDA_TicLength,fontStringName,gDA_FontSize,fontFace)
				nTics -=1
				value+=gDA_Interval
			while(nTics>=0)
			break;
		endif
		
		if(which==1)						// Bottom Axis
			maxPosition=c
			minPosition=b
			delta=((maxPosition-minPosition)/nTics)
			y1=1
			
			// the label needs to be dropped down by the ascent of the font as a ratio to the size of the plot 
			// since we are in plot relative coordinates
			
			y2=1+gDA_TicLength
			variable extraV=gDA_LabelGrout+FontSizeHeight(fontStringName, gDA_FontSize,fontFace)/plotHeight
			
			// Now draw the tic marks and labels
			do
				x1=maxPosition-nTics*delta
				drawSingleTic(x1,y1,x1,y2)
				sprintf  labelString, formatString , value
				drawHorizCenterLabel(x1,y2,labelString,0,extraV,fontStringName,gDA_FontSize,fontFace)
				nTics -=1
				value+=gDA_Interval
			while(nTics>=0)
			break;
		endif
		
		if(which==2)						// Left Axis
			maxPosition=a
			minPosition=d
			delta=((maxPosition-minPosition)/nTics)
			x1=0
			x2=-gDA_TicLength
			variable len
			do
				y1=maxPosition-nTics*delta		
				y2=y1
				drawSingleTic(x1,y1,x2,y2)
				sprintf  labelString, formatString , value
				drawVertCenterLabel(x1,y1,labelString,-gDA_LabelGrout-gDA_TicLength,0,fontStringName,gDA_FontSize,fontFace,which)
				nTics -=1
				value+=gDA_Interval
			while(nTics>=0)
			break;
		endif
		
		if(which==3)						// Right Axis
			maxPosition=a
			minPosition=d
			delta=((maxPosition-minPosition)/nTics)
			x1=1
			x2=1+gDA_TicLength
			do
				y1=maxPosition-nTics*delta		
				drawSingleTic(x1,y1,x2,y1)
				sprintf  labelString, formatString ,  value
				drawVertCenterLabel(x1,y1,labelString,gDA_LabelGrout+gDA_TicLength,0,fontStringName,gDA_FontSize,fontFace,which)
				nTics -=1
				value+=gDA_Interval
			while(nTics>=0)
			break;
		endif
		
	while(0)	
	
end

////////////////////////////////////////////////////////////////////
//
//	Draw tic marks and labels based on the scaling function and
//	the axis which is used as scaling origin.  The numerical labels
//	depends on a popup menu choice between "hard wired" i.e., the
//	labels just go at equal intervals without control over the value
//	the label displays.  The second choice is "nice labels" which
//	will be placed at nice values which may or may not span the
//	interval well in the case of highly non-linear functions.  The
//	third choice is to have the tick-marks and the labels placed 
//	based on a user-specified wave.
//
////////////////////////////////////////////////////////////////////

Function DrawArbTicMarks(which,a,b,c,d)	
	variable	which
	variable/d  	a,b,c,d
	
	variable	numTics=5
	variable	numDigits=4
	
	variable 	xmin,xmax
	String		getAxisString
	
	// first find which axis we are scaling
	// the following will support any axis, allowing the strange ability
	// to scale an axis based on a perpendicular axis.
	
	ControlInfo/W=DerivedAxisControl  popupLabelingType
	variable	options=V_value

	ControlInfo/W=DerivedAxisControl popupRefAxis
	String refAxisName=S_value
	
	if(strlen(refAxisName)<=0)
		Abort "You must specify a reference axis."
		return(0)
	endif
	
	GetAxis/Q  $refAxisName
	
	if((V_Max-V_Min)==0)
		beep
		print V_Max,V_Min
		Abort "Check your selection of scaled axis"
	endif
		
	if(numTics==0)
		Abort "The number of tic marks must be positive"
	endif
	
	do
		if(options==1)
			doHardWired(which,a,b,c,d,V_Min,V_Max)
			break
		endif
		
		if(options==2)
			doNiceLabels(which,a,b,c,d,V_Min,V_Max)
			break
		endif
		
		if(options==3)
			String	theName="tmp_qq_Params"
			Make /o/N=9	 tmp_qq_Params
				tmp_qq_Params[0]=which
				tmp_qq_Params[1]=a
				tmp_qq_Params[2]=b 
				tmp_qq_Params[3]=c
				tmp_qq_Params[4]=d
				tmp_qq_Params[5]=numTics
				tmp_qq_Params[6]=V_Min
				tmp_qq_Params[7]=V_Max
			useTicMarkWave(theName)
			killWaves tmp_qq_Params
			break
		endif
	while(0)
end


////////////////////////////////////////////////////////////////////
//
//	useTicMarkWave:	Asks the user which wave to use and then performs some
//						tests on the data.  If all is ok, the datapoints in the wave
//						are used to label the axis.  
//						We assume that the specified wave is in terms of target 
//						domain so in order to find where the tic marks go, we need
//						to calculate the inverse function for the true x-location and
//						then to scale it to plot relative coordinates.  To expedite the
//						search for the true x-location we store the last point found
//						to serve as a starting point for the next search.
//
////////////////////////////////////////////////////////////////////

Function useTicMarkWave(params)
	String	params
	variable numDigits

	NVAR gDA_SignificantDigits=root:Packages:WM_DrawingAxis:gDA_SignificantDigits

	ControlInfo/W=DerivedAxisControl popupTicWave
	String wave_Name= S_Value
	if(strlen(wave_Name)<=0)
		abort "You must specify a tick-mark wave."
		return 0
	endif
	drawTickMarkWave(params,gDA_SignificantDigits,wave_Name)
end


////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////

Function SetWaveBasedOnString(w,  x0, x1, n)
	String w
	Variable/D 	x0, x1
	Variable n
		
	SVAR	gDA_ScalingFunc=root:Packages:WM_DrawingAxis:gDA_ScalingFunc
	
	if(strlen(gDA_ScalingFunc)<=0)
		abort "You must specify a function for this mode."
		return(-1)
	endif
	
	if(n<=1)
		beep
		print  "At least two tick-marks are required."
		return(-1)
	endif
	
	String cmd
	Make/O/D/N=(n) $w
	SetScale/I x x0, x1, $w
	sprintf cmd, "%s = %s", w,gDA_ScalingFunc
//print cmd
	Execute cmd
	
	return(0)
End

////////////////////////////////////////////////////////////////////
//
//	doNiceLabels:   	Attempts to look at the new interval and generate a set of nice 
//					rounded labels that will fall inside the boundaries set by the 
//					existing axis.
//
////////////////////////////////////////////////////////////////////

Function doNiceLabels(which,a,b,c,d,vmin,vmax)
	Variable 	which,a,b,c,d,vmin,vmax
	String		scalingFunc
	
	NVAR 	gDA_requestedTicMarks=root:Packages:WM_DrawingAxis:gDA_requestedTicMarks
	NVAR	gDA_SignificantDigits=root:Packages:WM_DrawingAxis:gDA_SignificantDigits

	// find the nice labels and load them on a wave which is passed to 
	

	variable	numTics=gDA_requestedTicMarks
	variable	numDigits=gDA_SignificantDigits
	variable	localTics=numTics+2,newXmin,newXmax
	variable	oldXmin,oldXmax
	variable	switchDir=1
	variable	interval
	variable 	numMinorTics
	
	
	//
	// calculate the limits and make sure that min<max after scaling
	//
	
	String tmpName="tmpDDD"
	if(SetWaveBasedOnString(tmpName,vmin, vmax,2))
		return(-1)
	endif
		
	Wave ww=$tmpName
	newXmin=ww[0]
	newXmax=ww[1]
	
	if((numType(newXmin)!=0) %| (numType(newXmax)!=0))
		beep
		print "Rounded labels can only apply to a finite range."
		return(-1)
	endif
	
	oldXmin=newXmin
	oldXmax=newXmax
	KillWaves ww
		
	//
	// set them in the right order and keep a flag around
	//
	
	if(newXmin>newXmax)
		switchDir=newXmin
		newXmin=newXmax
		newXmax=switchDir
		switchDir=-1
	endif
	
	
	Make /o/N=5 tmp_LabelsWave
	tmp_LabelsWave[0]=newXmin
	tmp_LabelsWave[1]=newXmax
	tmp_LabelsWave[2]=numTics+2
	
	// numMinorTics=w[3],numDigits=w[4]			// not implemented yet

	//
	// run a loop until it is happy with the number of tick marks;
	// require that there are at least 3(+2) tic-marks when we are done
	//
	
	do
		makeSmartLabels(tmp_LabelsWave)
		if(tmp_LabelsWave[2]>5)
			newXmin=tmp_LabelsWave[0]
			newXmax=tmp_LabelsWave[1]
			numTics=tmp_LabelsWave[2]
			numMinorTics=tmp_LabelsWave[3]
			numDigits=tmp_LabelsWave[4]
			if(numDigits>=1)
				numDigits-=1
			endif
			interval=(newXmax-newXmin)/numTics
			
			KillWaves tmp_LabelsWave
			break;
		endif
		
		localTics+=1
		tmp_LabelsWave[0]=newXmin
		tmp_LabelsWave[1]=newXmax
		tmp_LabelsWave[2]=localTics
	while(1)
	
	localTics=numTics
	
	//
	// while the direction of the limits are still from small to large
	//
	
	if(newXmin>=oldXmin)
		localTics+=1
		newXmin-=interval
	endif
	
	if(newXmax<=oldXmax)
		localTics+=1
	endif
	
	//
	// reset the directions if it was changed before
	//
	
	if(switchDir==-1)
		switchDir=newXmin
		newXmin=newXmax
		newXmax=switchDir
		switchDir=-1
	endif
	
	// now drop the outer two tick marks
	localTics-=1
	
	variable i=0
	String waveNameStr="tmp_qq_tics"
	Make /N=(localTics+1) tmp_qq_tics
	
	do
		tmp_qq_tics[i]=newXmin+switchDir*i*interval
		i+=1
	while(i<=localTics)
	
	
	String paramsStr="tmp_qq_params"
	Make /o/N=8 tmp_qq_params
	tmp_qq_params[0]=which
	tmp_qq_params[1]=a
	tmp_qq_params[2]=b
	tmp_qq_params[3]=c
	tmp_qq_params[4]=d
	tmp_qq_params[5]=localTics+1
	tmp_qq_params[6]=vmin
	tmp_qq_params[7]=vmax
	
	drawTickMarkWave(paramsStr,numDigits,waveNameStr)
	KillWaves tmp_qq_params,tmp_qq_tics
end

////////////////////////////////////////////////////////////////////
//
//		drawTickMarkWave:	is called from doNiceLabels() and from 
//								useTicmarkWave().  It takes the provided wave
//								and finds the x-location at which to place the tics
//								using Igor call FindLevel.
//
////////////////////////////////////////////////////////////////////

Function drawTickMarkWave(params,numDigits,waveNameStr)
	String 		params,waveNameStr
	variable 	numDigits

	NVAR	gDA_FontSize=root:Packages:WM_DrawingAxis:gDA_FontSize
	NVAR 	gDA_TicLength=root:Packages:WM_DrawingAxis:gDA_TicLength
	NVAR 	gDA_LabelGrout=root:Packages:WM_DrawingAxis:gDA_LabelGrout
	NVAR	gDA_FontFace=root:Packages:WM_DrawingAxis:gDA_FontFace
		
	variable 		whichAxis,a,b,c,d,numTics,axmin,axmax
	Wave			theParams=$params
	
	Duplicate/o 	$waveNameStr,pointsWave
	
	whichAxis=		theParams[0]
	a=				theParams[1]
	b=				theParams[2]
	c=				theParams[3]
	d=				theParams[4]
	numTics=		theParams[5]
	axmin=			theParams[6]
	axmax=			theParams[7]
		
	GetWindow kwTopWin,psize
	variable plotWidth=V_right-V_left
	variable plotHeight=V_bottom-V_top
	variable maxPosition,minPosition
	maxPosition=c
	minPosition=b
	variable delta,y1,y2,x1,x2
	delta=axmax-axmin
	variable scaleFactor							// used for partial axis drawing
	
	//  Now we test that the requested tic marks are within range
	//  of the new scaled axis
	
	variable numberOfPoints=numpnts(pointsWave)

	variable ymin,ymax
	String  tmpWaveStr="tmpddd"
	
	if(SetWaveBasedOnString(tmpWaveStr,axmin,axmax,2))
		return(-1)
	endif
	
	Wave ddd=$tmpWaveStr
	ymin=ddd[0]
	ymax=ddd[1]
	KillWaves ddd
		
	variable flipLimitsFlag=0			
			
	if(ymax<ymin)						//  make sure we have it in the correct order
		flipLimitsFlag=ymin
		ymin=ymax
		ymax=flipLimitsFlag
		flipLimitsFlag=1
	endif
	
	ControlInfo/W=DerivedAxisControl popupFont
	String fontStringName=S_value

	//  test to see that all points in the wave are within limits
	
	variable i=0	
	do
		if((pointsWave[i]>ymax) %| (pointsWave[i]<ymin))
			String  mess
			mess="Data point "+num2str(pointsWave[i]) + " is out of range."
			pointsWave[i]=NaN
		endif
		i+=1
	while(i<numberOfPoints)
	
										//  if we flipped the limits before, restore them
	if(flipLimitsFlag==1)
		flipLimitsFlag=ymin
		ymin=ymax
		ymax=flipLimitsFlag
		flipLimitsFlag=1
	endif
	
										//  Now go through all tic marks specified in the wave

	String	labelString
	variable horizontalPosition=-1
	variable newPosition
	variable lastx=axmin
	
	// load a wave of 1000 points with the data 
	
	String tmpString="tmpXPoints"
	if(SetWaveBasedOnString("tmpXPoints",axmin,axmax,1000))
		return(-1)
	endif
	
	Wave tmpXPoints=$tmpString
	
	i=0
	do
		if((whichAxis==4) %| (whichAxis==1))
			variable yOffset
			scaleFactor=(c-b)/delta
			if(whichAxis==4)
				y1=0
				y2=-gDA_TicLength
				yOffset=-gDA_LabelGrout-gDA_TicLength
			else
				y1=1
				y2=1+gDA_TicLength
				yOffset=gDA_LabelGrout+gDA_TicLength+gDA_FontSize/plotHeight					// 10=fontsize
			endif

			do
				if(numtype(pointsWave[i])==0)							// skip NaN's and the like
					//  gave only one tick FindLevel /Q/R=(lastx,axmax) tmpXPoints, pointsWave[i]
					FindLevel /Q/R=(axmin,axmax) tmpXPoints, pointsWave[i]
					if(V_flag==0)											// only if a solution was found
						x1=V_levelX
						lastx=x1											// know where to start the search
						x1=b+scaleFactor*(x1-axmin)					// prel value
						
						drawSingleTic(x1,y1,x1,y2)
						labelString=make_f_Label(pointsWave[i],numDigits)
						newPosition=x1-(FontSizeStringWidth(fontStringName,gDA_FontSize , 0, labelString)/plotWidth)/2
						if((horizontalPosition<newPosition) %| (horizontalPosition>0 ) %| (flipLimitsFlag==0))
							drawHorizCenterLabel(x1,y1,labelString,0,yOffset,fontStringName,gDA_FontSize,gDA_FontFace)
							horizontalPosition=x1+(FontSizeStringWidth(fontStringName,gDA_FontSize , gDA_FontFace, labelString)/plotWidth)/2
						endif
					endif
				endif
				i +=1
			while(i<numberOfPoints)
			break;
		endif
		
		//
		//	Handle the case of the two vertical axes
		//
		
		if((whichAxis==2) %| (whichAxis==3))
			maxPosition=a
			minPosition=d
			Variable xOffset
			scaleFactor=(d-a)/delta
			
			if(whichAxis==3)
				x1=1
				x2=1+gDA_TicLength
				xOffset=0.03+gDA_TicLength
			else
				x1=0
				x2=-gDA_TicLength
				xOffset=-gDA_TicLength
			endif
			
			do
				if(numtype(pointsWave[i])==0)							// skip NaN's and the like
					FindLevel /Q/R=(lastx,axmax) tmpXPoints, pointsWave[i]
					if(V_flag==0)											// only if a solution was found
						y1=V_levelX
						lastx=y1											// know where to start the search
						y1=minPosition-(y1-axmin)*scaleFactor				// prel value
						drawSingleTic(x1,y1,x2,y1)
						labelString=make_f_Label(pointsWave[i],numDigits)
						drawVertCenterLabel(x1,y1,labelString,xOffset,0,fontStringName,gDA_FontSize,gDA_FontFace,whichAxis)
					endif
				endif
				i +=1
			while(i<numberOfPoints)
			break;
		endif
	while(0)
	
	KillWaves tmpXPoints,pointsWave
end


////////////////////////////////////////////////////////////////////
//
//	doHardWired:  draws hard wired tic marks with labels
//	according to the distances provided by the min and max
//	and by the number of intervals.  If the labels are too long
//	the label may be skipped although the tic mark is drawn.
//
//	Note that there are no tests to find if the labels fall inside
//	the margins of the graph and there are no changes to the current
//	setting of the margins.
//
////////////////////////////////////////////////////////////////////

function doHardWired(which,a,b,c,d,xmin,xmax)
	variable which,a,b,c,d,xmin,xmax
	String 		scalingF
	
	NVAR 	gDA_requestedTicMarks=root:Packages:WM_DrawingAxis:gDA_requestedTicMarks
	NVAR	gDA_FontSize=root:Packages:WM_DrawingAxis:gDA_FontSize
	NVAR 	gDA_TicLength=root:Packages:WM_DrawingAxis:gDA_TicLength
	NVAR 	gDA_LabelGrout=root:Packages:WM_DrawingAxis:gDA_LabelGrout
	NVAR	gDA_SignificantDigits=root:Packages:WM_DrawingAxis:gDA_SignificantDigits
	NVAR	gDA_FontFace=root:Packages:WM_DrawingAxis:gDA_FontFace

	
	variable	numTics=gDA_requestedTicMarks

	ControlInfo/W=DerivedAxisControl funcString	
	if(strlen(S_value)<=0)
		abort "You must specify a function for this mode."
		return(-1)
	endif
	
	
	GetWindow kwTopWin,psize
	variable plotWidth=V_right-V_left
	variable plotHeight=V_bottom-V_top
	variable maxPosition,minPosition
	variable delta
	variable interval=(xmax-xmin)/numTics
	variable value=xmin
	variable x1,x2,y1,y2
	String	labelString
	variable horizontalPosition=-1
	variable newPosition

	String tmpFileName="tmp_yy"
	if(SetWaveBasedOnString(tmpFileName,xmin,xmax,numTics+1))
		return(-1)
	endif
	
	wave w=$tmpFileName
		
	variable i=0
	variable yOffset
	ControlInfo/W=DerivedAxisControl setvarFontSize
	gDA_FontSize=V_value

	ControlInfo/W=DerivedAxisControl popupFont
	String fontStringName=S_value
	
	do
		if((which==4) %| (which==1))
			maxPosition=c
			minPosition=b
			delta=((maxPosition-minPosition)/numTics)
			if(which==4)
				y1=0
				y2=-gDA_TicLength
				yOffset=-gDA_LabelGrout-gDA_TicLength
			endif
			
			if(which==1)
				y1=1
				y2=1+gDA_TicLength
				yOffset=gDA_LabelGrout+gDA_TicLength+gDA_FontSize/plotHeight  
			endif

			do
				x1=c-numTics*delta
				drawSingleTic(x1,y1,x1,y2)
				labelString=make_f_Label(w[i],gDA_SignificantDigits)
				newPosition=x1-(FontSizeStringWidth(fontStringName,gDA_FontSize , gDA_FontFace, labelString)/plotWidth)/2
				if((horizontalPosition<newPosition) %| (horizontalPosition<0 ))
					drawHorizCenterLabel(x1,y1,labelString,0,yOffset,fontStringName,gDA_FontSize,gDA_FontFace)
					horizontalPosition=x1+gDA_LabelGrout+(FontSizeStringWidth(fontStringName,gDA_FontSize , gDA_FontFace, labelString)/plotWidth)/2
				endif
				numTics -=1
				i +=1
			while(numTics>=0)
			break;
		endif
		
		//
		//	Left and right axes are handled here.   
		//
		
		
		if((which==2) %| (which==3))
			maxPosition=a
			minPosition=d
			delta=((maxPosition-minPosition)/numTics)
			variable xOffset=gDA_LabelGrout+gDA_TicLength
			if(which==3)
				x1=1
				x2=1+gDA_TicLength
			else
				x1=0
				x2=-gDA_TicLength
				xOffset=-xOffset
			endif
			do
				y1=maxPosition-numTics*delta		
				drawSingleTic(x1,y1,x2,y1)
				labelString=make_f_Label(w[i],gDA_SignificantDigits)
				drawVertCenterLabel(x1,y1,labelString,xOffset,0,fontStringName,gDA_FontSize,gDA_FontFace,which)
				numTics -=1
				i +=1
			while(numTics>=0)
			break
		endif
		
		if(which!=0)
			Abort "Feature Not Implemented;  Look for next ver. "
		endif
	while(0)
	
	KillWaves w
end

//	The following function takes a wave as an input.  The wave consists of 5 parameters
//	which the function will modify.  On input the first two parameters are the min and max
//	range.  On output the first two parameters are the min and max values that will give
//	"nice" values when used with the determined number of tic marks.
//	
//	The third parameter on input is the requested number of tic marks.  This function will
//	set the output third parameter to the number of tic marks that together with the specified
//	min and max values provide "nice" intervals and labels.
//
//	The forth parameter is set upon return to a good value for the number of minor tic marks
//	inside each major tic-mark interval.
//
//	The fifth parameter is the number of significat figures required to represent the "nice"
//	labels.
//
//	Original algorithm by R. M. Emmons (c. 1987).


function makeSmartLabels(w)
	Wave w
	
	Variable xmin=w[0],xmax=w[1],numTics=w[2],numMinorTics=w[3],numDigits=w[4]
	
	if(numTics<=0)
		Abort "The number of tic marks must be positive"
	endif
	
	Make /o/n=4 	tmpGood={10,2,3,5}
	
	variable LDX=(xmax-xmin)/numTics
	numTics+=1
	
	variable 	tmp,ord,order
	variable 	i=0,j;
	variable	outXmax,outXmin,imin,imax,basis,tntics,varOrder,ntic,minor
	
	do
	
		tmp=LDX/10
		tmp=log(tmp)
		ord=trunc(tmp)
		j=0
		
		do
			varOrder=ord+j
			basis=tmpGood[i]*10^varOrder
			imin=trunc(floor(xmin/basis))
			imax=ceil(xmax/basis)
			tntics=imax-imin+1
			
			if(abs(tntics-numTics) < abs(ntic-numTics))
				outXmax=imax*basis
				outXmin=imin*basis
				ntic=tntics
				// numDigits=abs(varOrder)
				numDigits=abs(floor(log(basis)))+1		// 09NOV98 suggested by JEG
				minor=i
			endif
			j +=1
		while(j<=1)
		
		i +=1
	while(i<4)
	
	// 	load for return
	w[0]=outXmin
	w[1]=outXmax
	w[2]=ntic-1
	w[3]=minor
	w[4]=numDigits

	// cleanup
	KillWaves tmpGood
end

////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////

Function/S AxisListForMenu(graphName)
	String graphName
	
	String s = "(None"
	
	if (strlen(graphName) == 0)		// convert "" into active graph
		graphName = WinName(0,1)
	endif
	if (wintype(graphName) == 1)
		s = AxisList(graphName)
		if (strlen(s) == 0)
			s = "(No Axes in Graph"
		endif
	endif
	return s
End

////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////


Function DAButtonProc(ctrlName) : ButtonControl
	String ctrlName
		
	GetWindow DerivedAxisControl wsize
	
	if(cmpstr(ctrlName,"bFew")==0)
		Button $ctrlName, title="More Choices",rename=bMore
		MoveWindow  V_left,V_top,V_right,V_bottom-105*72/ScreenResolution
		Button bMore_2 pos={1000,1000}
	else
		Button $ctrlName, title="Fewer Choices",rename=bFew
		MoveWindow  V_left,V_top,V_right,V_bottom+105*72/ScreenResolution
		Button bMore_2 pos={316,170}
	endif
End

////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////


Function popupFontSizeProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	NVAR	gDA_FontSize=root:Packages:WM_DrawingAxis:gDA_FontSize

	if(strlen(popStr)>0)
		gDA_FontSize=str2num(popStr)
	endif
	
End

////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////


Function setvarFontSizeProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	NVAR	gDA_FontSize=root:Packages:WM_DrawingAxis:gDA_FontSize
	
	gDA_FontSize=varNum
End

////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////


Function popupDerivedScalingProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	if(popNum==1)
		popupmenu popupRefAxis 		pos={1000,1000}
		popupmenu popupScalingFunc 	pos={1000,1000}
		SetVariable funcString 			pos={1000,1000}
		popupmenu popupLabelingType 	pos={1000,1000}
		popupmenu popupTicWave 		pos={1000,1000}
		SetVariable setvarLowerLimit	pos={14,71}
		SetVariable setvarUpperLimit	pos={215,71}
		SetVariable setvarInterval		pos={14,94}
		SetVariable setvarSigDigits		pos={279,139}
		SetVariable setvarNumTics		pos={1000,1000}	
	else
		popupmenu popupRefAxis	 	pos={11,65}
		popupmenu popupScalingFunc 	pos={207,65}
		popupmenu popupLabelingType 	pos={11,115}
		SetVariable funcString 			pos={14,90}
		SetVariable setvarLowerLimit	pos={1000,1000}
		SetVariable setvarUpperLimit	pos={1000,1000}
		SetVariable setvarInterval		pos={1000,1000}
		// checkbox	checkNiceLabels		pos={1000,1000}

		ControlInfo popupLabelingType
		variable externalSelection=V_value
		do
			if(externalSelection==3)
				PopupMenu popupTicWave		pos={11,139}
				SetVariable setvarNumTics		pos={1000,1000}	
				SetVariable setvarSigDigits		pos={279,139}	
				break
			endif
			
			if(externalSelection==2)
				SetVariable setvarSigDigits		pos={1000,1000}	
				SetVariable setvarNumTics		pos={1000,1000}	
				break
			endif
			
			if(externalSelection==1)
				SetVariable setvarNumTics		pos={11,139}
				SetVariable setvarSigDigits		pos={279,139}	
				break
			endif
		while(0)
		
	endif	
End

////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////

Function popupLabelingTypeProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	
	SetVariable setvarNumTics		pos={1000,1000}	
	SetVariable setvarSigDigits		pos={1000,1000}	
	PopupMenu popupTicWave		pos={1000,1000}
	
	do
		if(popNum==3)
			PopupMenu popupTicWave		pos={11,139}
			SetVariable setvarNumTics		pos={1000,1000}	
			SetVariable setvarSigDigits		pos={279,139}	
			break
		endif
		
		if(popNum==2)
			SetVariable setvarSigDigits		pos={1000,1000}	
			SetVariable setvarNumTics		pos={1000,1000}	
			break
		endif
		
		if(popNum==1)
			SetVariable setvarNumTics		pos={11,139}
			SetVariable setvarSigDigits		pos={279,139}	
			break
		endif
	while(0)
End

////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////

Function bMore_2Proc(ctrlName) : ButtonControl
	String ctrlName

	GetWindow DerivedAxisControl wsize
	
	if(cmpstr(ctrlName,"bFew_2")==0)
		Button $ctrlName, title="Even More",rename=bMore_2
		MoveWindow  V_left,V_top,V_right,V_bottom-80*72/ScreenResolution
		Button bFew  pos={225,169}
	else
		Button $ctrlName, title="Fewer Choices",rename=bFew_2
		MoveWindow  V_left,V_top,V_right,V_bottom+80*72/ScreenResolution
		Button bFew  pos={1000,1000}
	endif
End

////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////

Function popupScalingFuncProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	SVAR	gDA_ScalingFunc=root:Packages:WM_DrawingAxis:gDA_ScalingFunc

	do
		if(popNum==2)
			gDA_ScalingFunc="32+9*x/5"
			break;
		endif
		if(popNum==3)
			gDA_ScalingFunc="(x-32)*5/9"
			break;
		endif
		if(popNum==1)
			gDA_ScalingFunc=""
			break;
		endif
	while(0)
End

////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////

Function CheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	if(checked)
		SetVariable setvarSigDigits		pos={1000,1000}
	else
		SetVariable setvarSigDigits		pos={279,139}
	endif
End

////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////

Function bMoreProc(ctrlName) : ButtonControl
	String ctrlName
		
	GetWindow DerivedAxisControl wsize
	
	if(cmpstr(ctrlName,"bFew")==0)
		Button $ctrlName, title="More Choices",rename=bMore
		MoveWindow  V_left,V_top,V_right,V_bottom-105*72/ScreenResolution
		Button bMore_2 pos={1000,1000}
	else
		Button $ctrlName, title="Fewer Choices",rename=bFew
		MoveWindow  V_left,V_top,V_right,V_bottom+105*72/ScreenResolution
		Button bMore_2 pos={342,169}
	endif
End
////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////

Function ApplyButtonProc(ctrlName) : ButtonControl
	String ctrlName
	myDrawDerivedAxis()
End

////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////

Function SetVarLineColor(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	drawLineColor()
End

////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////

Function SetVarTextColor(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	drawLineColor()
End

////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////

Function CheckFontFace(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	if(cmpstr(ctrlName,"checkFontPlain")!=0)
		CheckBox checkFontPlain value=0
	endif

	NVAR	gDA_FontFace=root:Packages:WM_DrawingAxis:gDA_FontFace

	ControlInfo checkFontPlain
	gDA_FontFace=0
	if(V_value==1)	
		CheckBox checkFontPlain value=1
		CheckBox checkFontBold value=0
		CheckBox checkFontItalic value=0
		CheckBox checkFontUnderline value=0
		CheckBox checkFontOutline value=0
		CheckBox checkFontShadow value=0
	else
		ControlInfo checkFontBold
		if(V_value)
			gDA_FontFace+=1
		endif
		ControlInfo checkFontItalic
		if(V_value)
			gDA_FontFace+=2
		endif
		ControlInfo checkFontUnderline
		if(V_value)
			gDA_FontFace+=4
		endif
		ControlInfo checkFontOutline
		if(V_value)
			gDA_FontFace+=8
		endif
		ControlInfo checkFontShadow
		if(V_value)
			gDA_FontFace+=16
		endif
	endif
End

////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////

Function SetVarScaleFunc1(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	SVAR	gDA_ScalingFunc=root:Packages:WM_DrawingAxis:gDA_ScalingFunc

	gDA_ScalingFunc=varStr

End

////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////


Window Table0() : Table
	PauseUpdate; Silent 1		// building window...
	Edit/W=(5,42,510,249) tick
EndMacro

////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////

Proc DerivedAxisControl()
	PauseUpdate; Silent 1		// building window...
	NewPanel/K=1 /W=(182,128,643,325)			// 09NOV98
	SetDrawLayer ProgBack
	DrawLine -13,196,460,196
	DrawLine -15,301,458,301
	SetDrawEnv fname= "Chicago"
	DrawText 11,320,"Line Color:"
	SetDrawEnv fname= "Chicago"
	DrawText 235,320,"Text Color:"
	SetDrawEnv fname= "Chicago"
	DrawText 19,218,"Draw axis between"
	SetDrawEnv fname= "Chicago"
	DrawText 77,241,"and"
	SetDrawEnv fname= "Chicago"
	DrawText 171,242,"%"
	DrawLine -14,161,459,161
	SetDrawLayer UserBack
	SetDrawEnv fillfgc= (0,0,0)
	DrawRect 10,321,60,371
	SetDrawEnv fillfgc= (0,0,0)
	DrawRect 240,321,290,371
	Button bApply,pos={10,169},size={50,20},proc=ApplyButtonProc,title="Apply"
	PopupMenu popupNewPosition,pos={11,8},size={174,19},title="Position New Axis:"
	PopupMenu popupNewPosition,mode=4,value= #"\"Bottom;Left;Right;Top\""
	PopupMenu popupDerivedScaling,pos={10,38},size={362,19},proc=popupDerivedScalingProc,title="Label New Axis With:"
	PopupMenu popupDerivedScaling,mode=2,value= #"\"User defined range;Direct scaling of another axis\""
	PopupMenu popupScalingFunc,pos={207,65},size={234,19},proc=popupScalingFuncProc,title="Scaling Function:"
	PopupMenu popupScalingFunc,mode=1,value= #"\"User Specified;C to F;F to C\""
	Button bMore,pos={225,169},size={110,20},proc=bMoreProc,title="More Choices"
	PopupMenu popupFontSize,pos={421,226},size={19,19},proc=popupFontSizeProc
	PopupMenu popupFontSize,mode=0,value= #"\"5;7;9;10;12;14;18;24;36;48;72\""
	PopupMenu popupRefAxis,pos={11,65},size={166,19},title="Reference Axis:"
	PopupMenu popupRefAxis,mode=1,value= #"AxisListForMenu(\"\")"
	SetVariable setvarLowerLimit,pos={1000,1000},size={175,17},title="Lower Limit:"
	SetVariable setvarLowerLimit,font="Chicago"
	SetVariable setvarLowerLimit,limits={-INF,INF,0.005},value=gDA_LowerLimit
	SetVariable setvarInterval,pos={1000,1000},size={230,17},title="Interval between Ticks:"
	SetVariable setvarInterval,font="Chicago"
	SetVariable setvarInterval,limits={-INF,INF,0.005},value=gDA_Interval
	SetVariable setvarUpperLimit,pos={1000,1000},size={175,17},title="Upper Limit:"
	SetVariable setvarUpperLimit,font="Chicago",format="%g"
	SetVariable setvarUpperLimit,limits={-INF,INF,0.005},value=gDA_UpperLimit
	SetVariable setvarSigDigits,pos={1000,1000},size={160,17},title="Significant Digits"
	SetVariable setvarSigDigits,font="Chicago"
	SetVariable setvarSigDigits,limits={0,INF,1},value=gDA_SignificantDigits
	SetVariable funcString,pos={14,90},size={425,17},title="Function:"
	SetVariable funcString,font="Chicago",limits={-INF,INF,1},value=gDA_ScalingFunc
	PopupMenu popupLabelingType,pos={11,115},size={319,19},proc=popupLabelingTypeProc,title="Labeling Type:"
	PopupMenu popupLabelingType,mode=1,value= #"\"Hard-Wired to Reference Axis;Rounded Labels;User Specified Tick-Mark Position Wave\""
	PopupMenu popupTicWave,pos={1000,1000},size={135,19},title="Tick-Mark Wave:"
	PopupMenu popupTicWave,mode=11,value= #"WaveList(\"!tmp_qq*\",\";\",\"\")"
	PopupMenu popupFont,pos={299,201},size={112,19},title="Font:"
	PopupMenu popupFont,mode=4,popvalue=GetDefaultFont(WinName(0, 1)),value= #"FontList(\";\")"
	Button bMore_2,pos={1000,1000},size={110,20},proc=bMore_2Proc,title="Even More"
	SetVariable setvar2,pos={18,225},size={50,17},title=" ",font="Chicago"
	SetVariable setvar2,format="%g",limits={0,100,5},value=gDA_StartDerivedAxis
	SetVariable setvar2_1,pos={115,225},size={50,17},title=" ",font="Chicago"
	SetVariable setvar2_1,format="%d",limits={0,100,5},value=gDA_EndDerivedAxis
	SetVariable setvarAxisWidth,pos={7,253},size={165,17},title="Axis Line Width:"
	SetVariable setvarAxisWidth,font="Chicago",format="%2.2f"
	SetVariable setvarAxisWidth,limits={0,INF,0.25},value=gDA_AxisLineWidth
	SetVariable setvarTickLength,pos={13,278},size={165,17},title="Tick Mark Size:"
	SetVariable setvarTickLength,font="Chicago",format="%1.2f"
	SetVariable setvarTickLength,limits={0,1,0.01},value=gDA_TicLength
	SetVariable setvarFontSize,pos={302,226},size={115,17},proc=setvarFontSizeProc,title="Font Size:"
	SetVariable setvarFontSize,font="Chicago",format="%d"
	SetVariable setvarFontSize,limits={0,72,2},value=gDA_FontSize
	SetVariable setvarLabelGrout,pos={303,249},size={135,17},title="Label Grout:"
	SetVariable setvarLabelGrout,font="Chicago",format="%1.2f"
	SetVariable setvarLabelGrout,limits={0,0.5,0.01},value=gDA_LabelGrout
	SetVariable setvarLineRed,pos={82,318},size={120,17},proc=SetVarLineColor,title="Red:"
	SetVariable setvarLineRed,font="Chicago",limits={0,65535,256},value=gDA_LineRed
	SetVariable setvarLineGreen,pos={67,338},size={135,17},proc=SetVarLineColor,title="Green:"
	SetVariable setvarLineGreen,font="Chicago"
	SetVariable setvarLineGreen,limits={0,65535,256},value=gDA_LineGreen
	SetVariable setvarLineBlue,pos={77,359},size={125,17},proc=SetVarLineColor,title="Blue:"
	SetVariable setvarLineBlue,font="Chicago"
	SetVariable setvarLineBlue,limits={0,65535,256},value=gDA_LineBlue
	SetVariable setvarTextRed,pos={313,318},size={120,17},proc=SetVarTextColor,title="Red:"
	SetVariable setvarTextRed,font="Chicago",limits={0,65535,256},value=gDA_TextRed
	SetVariable setvarTextGreen,pos={299,338},size={135,17},proc=SetVarTextColor,title="Green:"
	SetVariable setvarTextGreen,font="Chicago"
	SetVariable setvarTextGreen,limits={0,65535,256},value=gDA_TextGreen
	SetVariable setvarTextBlue,pos={309,358},size={125,17},proc=SetVarTextColor,title="Blue:"
	SetVariable setvarTextBlue,font="Chicago"
	SetVariable setvarTextBlue,limits={0,65535,256},value=gDA_TextBlue
	CheckBox checkFontPlain,pos={206,197},size={75,20},proc=CheckFontFace,title="Plain",value=1
	CheckBox checkFontBold,pos={206,213},size={75,20},proc=CheckFontFace,title="Bold",value=0
	CheckBox checkFontItalic,pos={206,229},size={75,20},proc=CheckFontFace,title="Italic",value=0
	CheckBox checkFontUnderline,pos={206,245},size={90,20},proc=CheckFontFace,title="Underline",value=0
	CheckBox checkFontOutline,pos={206,261},size={85,20},proc=CheckFontFace,title="Outline",value=0
	CheckBox checkFontShadow,pos={206,277},size={85,20},proc=CheckFontFace,title="Shadow",value=0
	SetVariable setvarNumTics,pos={11,139},size={185,17},title="Number of Intervals:"
	SetVariable setvarNumTics,font="Chicago",format="%d"
	SetVariable setvarNumTics,limits={0,50,1},value=gDA_requestedTicMarks
	Button bErase,pos={100,169},size={90,20},proc=ButtonProcEraseLayer,title="Erase Layer"
EndMacro

