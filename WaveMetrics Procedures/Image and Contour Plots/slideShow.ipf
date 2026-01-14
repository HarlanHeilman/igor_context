#pragma rtGlobals=1		// Use modern global access method.

// 09OCT03 AG -- first version.
//=================================================================================================
#pragma ModuleName= slideShowProc

Menu "SlideShow"
	"Slide Show...", getSlideShowPrefs();
	"Start Slide Show", startSlideShow();
	"Stop Slide Show", stopSlideShow();
	"Resume Slide Show",resumeSlideShow();
End

//=================================================================================================

Function getFolder()
	NewPath /M="Choose the file containing the images." /O/Q slideShowFolderPath
End
//=================================================================================================
Function startSlideShow()

	String flist=IndexedFile(slideShowFolderPath, -1, "????")
	NVAR numPictures=root:Packages:slideShow:numPictures
	numPictures=ItemsInList(flist)
	NVAR nowShowing=root:Packages:slideShow:nowShowing
	nowShowing=0
	
	resumeSlideShow()
End

//=================================================================================================
Function stopSlideShow()
	CtrlBackground stop
	NVAR isPlay=root:Packages:slideShow:isPlay
	isPlay=0
End
//=================================================================================================
Function resumeSlideShow()
	
	NVAR delayTime=root:Packages:slideShow:delayTime
	NVAR isPlay=root:Packages:slideShow:isPlay
	NVAR lastTime=root:Packages:slideShow:lastTime
	isPlay=1
	lastTime=0
	SetBackground slideShowBackground()
	CtrlBackground  start , period=delayTime, dialogsOK=1, noBurst=1
End
//=================================================================================================
Function slideShowBackground()
		
	NVAR lastTime=root:Packages:slideShow:lastTime
	NVAR delayTime=root:Packages:slideShow:delayTime
	
	if((ticks-lastTime)<(delayTime*60))
		return 0
	endif
	
	lastTime=ticks
	
	NVAR nowShowing=root:Packages:slideShow:nowShowing
	NVAR isLoop=root:Packages:SlideShow:isLoop
	NVAR closeWindowAtEnd=root:Packages:SlideShow:closeWindowAtEnd
	
	String fileName=IndexedFile(slideShowFolderPath, nowShowing, "????")
	if(strlen(fileName)<=0)
		if(isLoop)
			nowShowing=0;
			doUpdate
			return 0
		endif
		if(closeWindowAtEnd)
			DoWindow/K slideShowWindow
		endif
		return 1
	endif
	nowShowing+=1
	slideShowDisplay(fileName)
	doUpdate
	return 0
End

//=================================================================================================
Function slideShowDisplay(fileName)
	String fileName
	
	
	ImageLoad /Q/O/P=slideShowFolderPath fileName
	String wName=StringFromList(0,S_waveNames)
	if(strlen(wName)<=0)
		return 1
	endif
	Wave ww=$wName
	NVAR rotation=root:Packages:slideShow:rotation
	if(rotation==2)
		Imagerotate/O /c ww
	elseif(rotation==3)
		Imagerotate/O /w ww
	endif
	Duplicate/O ww,slideShowDispWave
	CheckDisplayed /A slideShowDispWave
	if(V_flag==0)
		doGraph0()		
	endif
	adjustImageSize()
	KillWaves/Z ww
	return 0
End
//=================================================================================================
Function slideShowInit()

	String curDF=GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S SlideShow
	
	Variable/G 	numPictures=0
	Variable/G	delayTime
	Variable/G  isLoop
	Variable/G nowShowing=0
	Variable/G lastTime=0
	Variable/G	closeWindowAtEnd=1
	Variable/G  rotation
	Variable/G  isPlay=0
	
	string info=IgorInfo(0)
	String screenRectStr=StringByKey("SCREEN1", info, ":"),junkStr
	Variable left,top,junkVal
	Variable/G screenWidth,screenHeight
	sscanf screenRectStr, "DEPTH=%d,RECT=%d,%d,%d,%d",junkVal,left,top,screenWidth,screenHeight
	
	KillWaves/A/Z		
	SetDataFolder curDF
End

//=================================================================================================

Function doGraph0()
	
	NVAR screenWidth=root:Packages:SlideShow:screenWidth
	NVAR screenHeight=root:Packages:SlideShow:screenHeight
	
	Display/K=1 /W=(0,0,screenWidth,screenHeight)
	DoWindow/C slideShowWindow
	AppendImage/T slideShowDispWave
	ModifyGraph wbRGB=(0,0,0),gbRGB=(0,0,0)
	ModifyGraph mirror=0
	ModifyGraph nticks=0
	ModifyGraph noLabel=2
	ModifyGraph standoff=0
	ModifyGraph axThick=0
	SetAxis/A/R left
	addSlideControls()
End 

//=================================================================================================
Function adjustImageSize()
	NVAR screenWidth=root:Packages:SlideShow:screenWidth
	NVAR screenHeight=root:Packages:SlideShow:screenHeight
	Wave slideShowDispWave
	Variable imageWidth=DimSize(slideShowDispWave,0)
	variable imageHeight=DimSize(slideShowDispWave,1)
	
	Variable widthFactor=(0.9*screenWidth/imageWidth)
	Variable heightFactor=(0.9*screenHeight/imageHeight)
	
	Variable theFactor=widthFactor
	if(heightFactor<widthFactor)
		theFactor=heightFactor
	endif
	imageWidth*=theFactor
	imageHeight*=theFactor
	
	Variable wMargin,hMargin
	wMargin=(screenWidth-imageWidth)/2
	hMargin=(screenHeight-imageHeight)/2
	
	DoWindow/F slideShowWindow
	ModifyGraph margin(left)=wMargin,margin(bottom)=hMargin,margin(top)=hMargin,margin(right)=wMargin
	ModifyGraph width=imageWidth
	ModifyGraph height=imageHeight
End
//=================================================================================================

Function getSlideShowPrefs()
	
	slideShowInit()
	NVAR rotation=root:Packages:slideShow:rotation
	DoWindow/F slideShowPrefsPanel
	if(V_Flag)
		return 0
	endif
	NewPanel /K=1/W=(360,52,656,234) as "Slide Show"
	DoWindow/C slideShowPrefsPanel
	CheckBox checkLoop,pos={20,14},size={40,14},title="Loop"
	CheckBox checkLoop,variable= root:Packages:SlideShow:isLoop
	SetVariable delaySetVar,pos={21,38},size={120,15},title="Delay (sec):"
	SetVariable delaySetVar,value= root:Packages:SlideShow:delayTime
	CheckBox checkCloseWindow,pos={21,62},size={201,14},title="Close picture window after slide show"
	CheckBox checkCloseWindow,variable= root:Packages:SlideShow:closeWindowAtEnd
	Button ChooseFolderButton,pos={22,122},size={150,20},proc=chooseFolderButtonProc,title="Choose Folder"
	Button startShowButton,pos={22,151},size={151,19},proc=startSlideShowButtonProc,title="Start"
	PopupMenu popupRotation,pos={22,87},size={181,20},title="Rotation before display: "
	PopupMenu popupRotation,mode=rotation,value= #"\"None;90 degrees CW; 90 degrees CCW \"",proc=rotationPopMenuProc
	ModifyPanel fixedsize=1
End
//=================================================================================================

Function chooseFolderButtonProc(ctrlName) : ButtonControl
	String ctrlName
	getFolder()
End
//=================================================================================================

Function startSlideShowButtonProc(ctrlName) : ButtonControl
	String ctrlName
	startSlideShow()
End

//=================================================================================================
Function rotationPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	NVAR rotation=root:Packages:slideShow:rotation
	rotation=popNum
End
//=================================================================================================
// PNG: width= 93, height= 29
static Picture rightArrowPict
	ASCII85Begin
	M,6r;%14!\!!!!.8Ou6I!!!")!!!!>#Qau+!(T]Vp](9o&TgHDFAm*iFE_/6AH5;7DfQssEc39jTBQ
	=U!B*M;5u`*!m?td"_]T@V9pO8A9!UcQ@"i-V%-JZ_Tdh2g*#f4J4&nHA9!A4ZJg2K7F2cX%UZ"Ttn
	YbD,eC,!ar/>s3F3Z2(P:,254-jGT9\[!M0eLQ2qGm<_7jd4!!"cD@4/$,%LjNR!<qFbb_tq5b/66=
	\]_;EaS.i*KWHedeeS<ucoupdUpYs"<fT-S@I;i<54O:UDJM9&[\>,DXdmgaFAg^q[<f^"7:b2@PY4
	#Q-3q%5s.nPdsf[\-O=m9,S4<GF]E9p&K8_!%-QUZr;eoc]!=sNdiWt@h\`U:"(Ng-m_VV"NHA!1oE
	/+Cu<&]fD>aRV*N&a$o&F)Mmj#`LIH?A:>S7(fmE"L8iq"I8BWC8,`i;TVRcRgipI]b3.2-R/AUiP,
	*hRF&^<QS6"dz8OZBBY!QNJ
	ASCII85End
End

// PNG: width= 93, height= 29
static Picture leftArrowPict
	ASCII85Begin
	M,6r;%14!\!!!!.8Ou6I!!!")!!!!>#Qau+!(T]Vp](9o&TgHDFAm*iFE_/6AH5;7DfQssEc39jTBQ
	=U!D?!P5u`*!m?u]8__;KfY=_mf.aAA=+Y+h=GW>B6?pYmCI`Q8(HG0`?)`UCZMjPB3Ei+.;)U?S$p
	a_"?T'i+AT+MS]U.O;uq(<Ui@TaJ_[!gg8dk80;Au,S)!G(K7Zk4M)Ro-tZ>q'JYjU?F>CBOVLD;,8
	&?.]#3cM?Ii;il#>a,F+E8lA:Re;J#c!+$V$[!Aol"K08=U"5.I./A+U,c\N0/X$YhOZ-V5)F7ln4A
	k`[h$CU7,Z.gEB:L6>nD9(9VDWTd$=<1.63spbGjf52`#\g<<iq5QF#U+eg/_(1<*MdKK<8+b:@$OE
	S2c.Eg<K^7gPVC\g8arg@'6U30QV$gFIoD\lq#OX<^ZTi$?fsZ[j,iFoojR;m_'A/J[1g5j=%\HHnD
	1-(*tU@0,qbFI1i%gcHI)#"FgD6!$.]:;96#uqu?]s!(fUS7'8jaJc
	ASCII85End
End

// PNG: width= 180, height= 29
static Picture playButtonPict
	ASCII85Begin
	M,6r;%14!\!!!!.8Ou6I!!!#+!!!!>#Qau+!0"S<6N@)d&TgHDFAm*iFE_/6AH5;7DfQssEc39jTBQ
	=U!@gZ/5u`*!mFtp(_E\Y8i#]uH4B(ClP;@K<p-FXFdZVh8h%f4mLNOB$VC:5&Jk8srBG\iX]2WoVJ
	*K3\V'I7]PjX`Vc6FYH)S8`K$Mh+![(]n5V;q2nSi]]Z%'5P/6`1SSQ@hj^#FS[(1/6=Q?MDuM.HSW
	BhrQIDGf[W`3?IY@WKVsTrk<)b:I5r+nBd79H2^rT5D!sjF25a([r;`T$Ro?9E!ob=08BPI%C^;I&E
	OJ=\D\4+&>^ACHp;`*SqI0SE.nkbJ.!95iB$u"J.!95iG-["J.!95i>/$HJ.!95iC7_HJ.!95iHF@9
	2\ET%S^8gJ6T3,mIJS0KKMDgpZN#D)'GekX-C09XT0!:m9^i9p+nHXkZqFC4b<_FA#&p@Q"SJ5uz8O
	ZBBY!QNJ
	ASCII85End
End

// PNG: width= 93, height= 29
static Picture clockwisePict
	ASCII85Begin
	M,6r;%14!\!!!!.8Ou6I!!!")!!!!>#Qau+!(T]Vp](9o&TgHDFAm*iFE_/6AH5;7DfQssEc39jTBQ
	=U!@^T.5u`*!m?td"_]T@V9pO6a!`N\6L3!l+/R"[A%H!6ihT<n@M'qm(8ml8"Pdl%Ml/Kq"8<m))Y
	J.0?'JW)PinLn5!Oi_/+JK*ad:&DKCmOXUp:gSl@X8.[O&K)?iT10ljH2`mBtBNO_b7`D]Q^0S\!-8
	FmiAA\@csCke:J#ofb)_c$G)%a?ZS0&[+@eZ@Z5Y^e:mqb;/QWAL>M=i<HDbI];d%?E4+lirFL42kO
	3Og@pA1:]iFf4;<-.]oMX/7AMEQQ5;bcS276a[4\bP(BER`ZABN,FYrR8/J#@Zr&i=^QLF"ea*IR9a
	PIOT=-Ac1,;V!7:&^A</-=9/rholiV/S?smG6bb$b^!_T^$K^e?\5G=1NSr`VbNc:hjr5@5I(4g!!!
	!j78?7R6=>B
	ASCII85End
End

// PNG: width= 93, height= 29
static Picture cclockwisePict
	ASCII85Begin
	M,6r;%14!\!!!!.8Ou6I!!!")!!!!>#Qau+!(T]Vp](9o&TgHDFAm*iFE_/6AH5;7DfQssEc39jTBQ
	=U!>.mk5u`*!m?pTW__;?"EL!Td#WZIVOMfJbP:Xa$^D7_+1FmC\@`6/P:<ZBtMlE%-/^DQB:<TrA=
	!,HpLM<4,MpM!RK=[V<&eVg!M`umb+u=WBI1?Y3c!q4kYfPi?+*so.kYgZTL!*e+,DnY4)Yms*P[*_
	KeB!H9ohnCZ^XPn*[i5@G]OWH,CJL2T`!A?:V`U,0LL0hA67;Lg$RlsK;J=qqR`.f)R`20=g@=b/c#
	')**-IVk&H@_FZBq.1$]'7o=m`iOXOZ^,C=YH7RT7,0$5B8b.W?nlg)QA%eE9IR_Qsphk6lAK%:/1:
	/qparDRXCS-LN+Hn?Tm&4pdYnBBBosdir_"%u<a-op+Y>!!!!j78?7R6=>B
	ASCII85End
End

//=================================================================================================
Function addSlideControls()

	Button nextPictButton,pos={69,2},size={31,29},proc=rightButtonProc,title=""
	Button nextPictButton,picture= slideShowProc#rightArrowPict
	Button prevPictButton,pos={7,2},size={31,29},proc=leftButtonProc,title=""
	Button prevPictButton,picture= slideShowProc#leftArrowPict
	CheckBox playCheck,pos={39,2},size={30,29},proc=playCheckProc,title=""
	CheckBox playCheck,variable= root:Packages:SlideShow:isPlay,picture= slideShowProc#playButtonPict
	Button rotateLeftButton,pos={100,2},size={31,29},proc=cclockwiseButtonProc,title=""
	Button rotateLeftButton,picture= slideShowProc#cclockwisePict
	Button rotateRightButton,pos={131,2},size={31,29},proc=clockwiseButtonProc,title=""
	Button rotateRightButton,picture= slideShowProc#clockwisePict
End
//=================================================================================================
Function cclockwiseButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	Wave/Z slideShowDispWave
	if(WaveExists(slideShowDispWave))
		Imagerotate/O /w slideShowDispWave
	endif
	adjustImageSize()
End
//=================================================================================================
Function clockwiseButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	Wave/Z slideShowDispWave
	if(WaveExists(slideShowDispWave))
		Imagerotate/O /c slideShowDispWave
	endif
	adjustImageSize()
End
//=================================================================================================
Function rightButtonProc(ctrlName) : ButtonControl
	String ctrlName
	displayImage(1)
End
//=================================================================================================
Function playCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	NVAR isPlay=root:Packages:slideShow:isPlay
	if(!isPlay)
		stopSlideShow()
	else
		resumeSlideShow()
	endif
End
//=================================================================================================
Function leftButtonProc(ctrlName) : ButtonControl
	String ctrlName
	displayImage(-1)
End
//=================================================================================================
Function displayImage(direction)
	Variable direction
	
	NVAR nowShowing=root:Packages:slideShow:nowShowing
	NVAR numPictures=root:Packages:SlideShow:numPictures
	nowShowing+=direction
	
	if(nowShowing<0)
		nowShowing=0
		beep
		return 0
	elseif(nowShowing>=numPictures)
		if(direction==-1)
			nowShowing-=1
		else
			beep
			return 0
		endif
	endif
		
	String fileName=IndexedFile(slideShowFolderPath, nowShowing, "????")
	if(strlen(fileName)<=0)
		return 1
	endif
	nowShowing+=1
	slideShowDisplay(fileName)
	doUpdate
End
//=================================================================================================
