#pragma rtGlobals=3		// Require modern global access method.
#pragma modulename=GizmoBoxAxes
#pragma IgorVersion=6.2	// Requires Gizmo released with Igor 6.2.
#pragma version=6.2		// version shipped with Igor 6.2

#include <GizmoAxisLabels>
#include <GizmoLabels>
#include <CustomControl Definitions>
#include <GizmoUtils>

// Gizmo Box Axes.ipf
//
// An alternate GUI to show, hide, and modify Gizmo Box Axes objects.
//
// 03/14/05, JP: Initial version
// 08/08/06, JP: Version 6.0, fixed initial lack of axis toggle.
// 02/19/07, JP: Version 6.01, uses axis visible keyword instead of axisType=0, requires Gizmo that ships with Igor 6.01 or later.
// 09/12/08, JP: Version 6.05:	Adds X,Y,Z axis ranges, commands optionally echoed to the history.
//								Made WhichAxisAndNumForAxisIndex(), etc static. 
//								The Axis Labels... button calls the new GizmoAxisLabels.ipf routines.
//								Requires Gizmo that ships with Igor 6.04 or later.
// 02/19/07, JP: Version 6.2, GizmoUtils.ipf and CustomControl Definitions.ipf

static StrConstant ksDefaultRotation= "ModifyGizmo SETQUATERNION={0.570788,-0.062481,-0.089088,0.813855}"

Function WMGizmoBoxAxesPanel()

	Variable winHeightPixels= 550	// bottom-top
	Variable winWidthPixels= 1431-818	// right-left
	DoWindow/F GizmoBoxAxes
	Variable rebuild= V_Flag == 0
	if( !rebuild )
		// this window was redesigned for 6.05
		GetWindow GizmoBoxAxes wsizeDC
		if( (V_right-V_Left) != winWidthPixels )
			rebuild= 1
		elseif( (V_Bottom-V_Top) != winHeightPixels )
			rebuild= 1
		endif
	endif
	// rebuild=1	// debugging	
	if( rebuild )
		
		MakeSliderLabelWaves()// Inits data folders, too
		
		DoWindow/K GizmoBoxAxes

		Variable left= 818, top=53
		Variable right= left+winWidthPixels
		Variable bottom= top+winHeightPixels
		
		NewPanel/N=GizmoBoxAxes/W=(left,top,right,bottom)/K=1 as "Gizmo Box Axes"	// /W=(l,t,r,b)
		DoWindow/C GizmoBoxAxes	// in case a window macro somehow got saved
		ModifyPanel/W=GizmoBoxAxes fixedSize=1, noEdit=1

		String gizmoName= TopGizmo()
		if( strlen(gizmoName) )
			AutoPositionWindow/E/R=$gizmoName GizmoBoxAxes
		endif

		SetVariable topGizmoSV,pos={85,17},size={174,15},disable=2,title="Gizmo Window Name:"
		SetVariable topGizmoSV,frame=0,value= $PanelDFVAR("topGizmo")
		
		PopupMenu axesPop,pos={85,44},size={144,20},proc=GizmoBoxAxes#BoxAxesPopMenuProc,title="Box Axes Object:"
		PopupMenu axesPop,mode=1,popvalue="axes0",value= #"GizmoBoxAxes#GizmoBoxAxesList(\"\")"

		Button appendAxes,pos={261,15},size={130,20},proc=GizmoBoxAxes#AppendBoxAxesButtonProc,title="Append Box Axes"
		
		Button removeAxes,pos={262,43},size={129,20},proc=GizmoBoxAxes#RemoveAxesButtonProc,title="Remove Box Axes"
		
		Button gizmoAxesInfo,pos={409,42},size={124,20},proc=GizmoBoxAxes#BoxAxesInfoButtonProc,title="Box Axes Info..."

		Variable/G $PanelDFVAR("showAxisNames")
		CheckBox showAxisNames,pos={76,323},size={98,14},proc=GizmoBoxAxes#ShowAxisNamesCheckProc,title="Show Axis Names"
		CheckBox showAxisNames,variable=$PanelDFVAR("showAxisNames")
		
		Variable verbose= NumVarOrDefault(PanelDFVAR("verbose"),1)	// default to verbosity
		Variable/G $PanelDFVAR("verbose")=verbose	// user can set this to zero to suppress the printing of Gizmo commands to the history.
		CheckBox verbose,pos={76,340},size={163,14},title="Echo Commands to History"
		CheckBox verbose,variable=$PanelDFVAR("verbose")
	
		CheckBox toggleAxes,pos={289,84},size={136,14},proc=GizmoBoxAxes#ShowHideCheckProc,title="Click Shows or Hides Axis"
		CheckBox toggleAxes,value= 1,mode=1

		CheckBox toggleTicks,pos={289,109},size={130,14},proc=GizmoBoxAxes#ShowHideCheckProc,title="Click Toggles Tick Marks"
		CheckBox toggleTicks,value= 0,mode=1

		CheckBox toggleLabels,pos={289,134},size={156,14},proc=GizmoBoxAxes#ShowHideCheckProc,title="Click Toggles Numerical Labels"
		CheckBox toggleLabels,value= 0,mode=1
	
		GroupBox selectedAxisGroup,pos={273,161},size={317,290},title="      Click Selects an Axis"

		CheckBox selectAxes,pos={289,159},size={16,14},proc=GizmoBoxAxes#ShowHideCheckProc,title=""
		CheckBox selectAxes,value= 0,mode=1

		Variable/G $PanelDFVAR("numTicks")
		SetVariable numTicks,pos={283,186},size={139,18},bodyWidth=40,proc=GizmoBoxAxes#NumTicksSetVarProc,title="Requested Ticks"
		SetVariable numTicks,fStyle=1
		SetVariable numTicks,limits={1,100,1},value= $PanelDFVAR("numTicks")
	
		Variable/G $PanelDFVAR("tickLen")
		SetVariable tickLen,pos={432,186},size={93,18},bodyWidth=50,proc=GizmoBoxAxes#TickLenSetVarProc,title="Length"
		SetVariable tickLen,fStyle=1
		SetVariable tickLen,limits={0.5,100,0.5},value= $PanelDFVAR("tickLen")

		// Limits for selected axis
		Variable/G  $PanelDFVAR("axisMin")
		SetVariable axisMin,pos={290,213},size={107,15},bodyWidth=80,proc=GizmoBoxAxes#AxisRangeSetVarProc,title="X Min"
		SetVariable axisMin,limits={-inf,inf,0},value= $PanelDFVAR("axisMin"),fStyle=1

		Variable/G  $PanelDFVAR("axisMax")
		SetVariable axisMax,pos={409,213},size={110,15},bodyWidth=80,proc=GizmoBoxAxes#AxisRangeSetVarProc,title="X Max"
		SetVariable axisMax,limits={-inf,inf,0},value= $PanelDFVAR("axisMax"),fStyle=1
		
		Button autoscaleAxis,pos={529,204},size={50,16},proc=GizmoBoxAxes#AutoscaleButtonProc,title="Auto"
		Button autoscaleAxis,fSize=10
		
		Button fivePercentAxis,pos={529,225},size={50,16},proc=GizmoBoxAxes#AutoscaleButtonProc,title="+ 5%"
		Button fivePercentAxis,fSize=10

		// Numeric labels rotation
		TitleBox rotationTitle,pos={302,243},size={169,12},title="Rotate Numerical Labels about:",frame=0,fStyle=1

		CheckBox rotateAroundY,pos={331,260},size={93,14},proc=GizmoBoxAxes#RotateAboutRadioProc,title="World Z Axis (y)"
		CheckBox rotateAroundY,value= 1,mode=1

		CheckBox rotateAroundZ,pos={331,277},size={79,14},proc=GizmoBoxAxes#RotateAboutRadioProc,title="Clockwise (z)"
		CheckBox rotateAroundZ,value= 0,mode=1
	
		CheckBox rotateAroundX,pos={447,260},size={98,14},proc=GizmoBoxAxes#RotateAboutRadioProc,title="Label Baseline (x)"
		CheckBox rotateAroundX,value= 0,mode=1
	
		CheckBox rotateAroundOther,pos={447,277},size={67,14},disable=2,title="Other Axis"
		CheckBox rotateAroundOther,value= 0,mode=1

		Slider labelRotationAngle,pos={283,294},size={296,47},proc=GizmoBoxAxes#TickLabelSliderProc
		Slider labelRotationAngle,limits={-180,180,5},value= 0,vert= 0,ticks= 30
		Slider labelRotationAngle,userTicks={$PanelDFVar("tickValues"),$PanelDFVar("tickLabels")}

		// numeric labels offsets

		TitleBox offsetTitle,pos={304,353},size={135,12},title="Offset Numerical Labels:"
		TitleBox offsetTitle,frame=0,fStyle=1
	
		CheckBox offsetLeftRight,pos={331,370},size={65,14},proc=GizmoBoxAxes#OffsetRadioProc,title="Left/Right"
		CheckBox offsetLeftRight,value= 1,mode=1
	
		CheckBox offsetUpDown,pos={413,370},size={59,14},proc=GizmoBoxAxes#OffsetRadioProc,title="Up/Down"
		CheckBox offsetUpDown,value= 0,mode=1
	
		CheckBox offsetForwardBack,pos={491,370},size={83,14},proc=GizmoBoxAxes#OffsetRadioProc,title="Forward/Back"
		CheckBox offsetForwardBack,value= 0,mode=1
	
		Slider labelOffset,pos={283,395},size={296,45},proc=GizmoBoxAxes#TickLabelOffsetSliderProc
		Slider labelOffset,limits={-1,1,0},value= 0,vert= 0,ticks= 20

		Button resetLabelRotations,pos={274,476},size={320,20},proc=GizmoBoxAxes#DefaultLabelRotationButtonProc,title="Reset All Numerical Labels Rotations and Offsets"

		// do this last so it is drawn correctly
		CustomControl cube,pos={21,80},size={233,233},proc=MyCC_CubeFunc
		CustomControl cube,mode= 1,picture= {ProcGlobal#GrayCube,1}

		Button sameRotation,pos={13,364},size={250,20},proc=GizmoBoxAxes#OrientationButtonProc,title="Set Gizmo Rotation to Match Diagram"

		Button rotateBack,pos={42,396},size={200,20},proc=GizmoBoxAxes#OrientationButtonProc,title="Put Gizmo Rotation Back"

		Button autoScaleXYZ,pos={41,445},size={200,20},proc=GizmoBoxAxes#AutoscaleButtonProc, title="Autoscale X, Y, and Z Ranges"
	
		Button gizmoInfo,pos={13,520},size={90,20},proc=GizmoBoxAxes#GizmoInfoButtonProc,title="Gizmo Info"

		Button axisLabels,pos={246,520},size={100,20},proc=GizmoBoxAxes#AxisLabelsButtonProc,title="Axis Labels..."
	
		Button help,pos={492,520},size={87,20},proc=GizmoBoxAxes#HelpButtonProc,title="Help"

		SetWindow kwTopWin,hook(GizmoBoxAxes)=GizmoBoxAxes#PanelWindowHook
		// should put a hook on the Gizmo, too, except that is already done by other Gizmo Procedures

		UpdateGizmoBoxAxesPanel()
	else
		// activate event will call UpdateGizmoBoxAxesPanel()
	endif
End


Static Function MakeSliderLabelWaves()

	String oldDF= SetPanelDF()

	Variable n= round(360/15+1)
	Make/O/N=(n) tickValues = -180 + 15 * p
	Make/O/T/N=(n) tickLabels=""
	tickLabels[0,n-1;3] = num2istr(tickValues[p])
	

	SetDataFolder oldDF
End

// Smaller Box PNG: width= 235, height= 234
Picture GrayCube
	ASCII85Begin
	M,6r;%14!\!!!!.8Ou6I!!!#b!!!#a#Qau+!6d8G-NF,H&TgHDFAm*iFE_/6AH5;7DfQssEc39jTBQ
	=U$!Tth5u`*!m@E'Ui^ac:EM#h<'*?HeU_$?.-j60a!/Fr[:^D_.-3VL03/&LXYn)8;D9FiEV#Ip6]
	"YK]Gh3=O<RjO3&Xp=?(fl<g`T1>*+cE"GM/MNbU)Q.\k_9Qo\tOb5DWkK&)`jAML(5QATnA2>k[:,
	(0*`G+N%o^=oGE<ET.>8I0t[Jl!(\-DG3!4N]H(5kO?.]!0HjoqmD2kQ,[,`JER"uOD%&+?SCW<Wr1
	=N^\0rJBA.L#uRF?dOrtCM!UlJ+"bm;?TYE&4$n:tXR]7Z"C;FgFgU77uBGfHqL>X7QkEik:A%!:_N
	V?_Tq7TDO[-m3YC%jnlE<K+<Oi1bbO1"Q1<m23pr0mjN2nEf.YE)Amca<"#sPMu_=j;hJ>O?07@'4W
	'cR6%3\&Wg?U*:[T4JP@^j`uiE08^uCT(sTSJn,'iF[?sKUe'Z@T!OnW,*?:-Cl]0$GbKEQHL&;IWN
	p/=O,%U&moR5V>SLFAi7?3CRcDJ_:_(dp?:(IjGn*f`>p\25M&f1j8juGYhII)3K:8at'?=$srmCSO
	TA'PHOAY*768DCSbh6*cXg^EoZ80)cc[Y,Y@QF:Y>g[00rc+T47jOH!bT.3Lt;P>MtI.2@@dP8Lh$!
	DkE02=fV@VJ*m.)e,m/&3:@NcD65SdLZ@.Zc]s#=lUt]4!\^?:>Gsl+n6EXrJR,PirkLD[XS?j^*NE
	dc`*[#J4YF@Y$^te5<AAZmRT5`7@dp%i4`ao+2bP(EdjbmLLX!#4Zf"gOie]-*^,dFl`AVOF42B4=_
	BjkrmZfa>3B3j8ap?L5:sSiS+M?@<L)O,#hfCbWf+A8LPT:A["V;I>JKN^A%*h9/?@-MngX\8)Q[;^
	*I\CH,:iH@(D:Yc3JiS^eg.%UlN#,+BB+1M'Y2tmD1ElQR<$s#AW,d7$$C8P8Jpt3pQ.L0#@][!g#J
	&W3/H.Eg*I`,4o7Z78$@9U4_L@<&GnG1(8dijt_Fha"'X^$0tI_f]p!;5i6\r2_b@dSD\N%bOO'o/V
	@+U`$flqLt74#'d.We*!oK?!qFbPkBnto$)ET3E<W=?JZoBC0p"F?NeF?0JZoBC0p"Et`YG:E"i;<S
	`^&gF3"hr\"i;<S`^&ep(fue['aT.?)$?i_i^ekd'aT.?)$?i_?sH"_<$:PDA.58oLa+).<$:PDA.5
	8oJ8kal;h;.XImIAl?.WA2m(0@&l\t.$%#g3!?Ji2XnGRKZY,q>A4LT,(p[;Jdj3O>^%u8&7Z\bmjM
	;PasdIG,Xq)k"<Z*1LeCt@p[NT%&+f'@GeqhbPH7i/tMQ0UIo5<iKpr;?J_C/JLsT)/u$7GQt_iF0@
	S*fn@nf@NPH_%r/l+1W1!Ssqe.G.ZYHJ,f?9-eX[($p=8gU%_9>SOP@j=;SVg)UT#?#>`@PJWC,:,N
	'r[-*+F#*e#^?9?or6#Y5uZ3Zm\pC)B>'#l$u/+g-6+LU#&3L4h_b)Wo9ejY<Qkm(m$l_cO"3PfGO8
	(fElti%OkAf&`Ok,QOegi7gkCSM9E2%\=2;`5T.%Y5tL-6gBIe;E15KO-*,;#l]6mTqD&'pt#h?TB(
	+1lQSY[/X&.Gm(qZ.DIQ-W&P%_XPBITiK(k1ZKjGE[lDRU;lQjhKYDF"1*ZPuU-AL"^EMQPpBf*(=f
	Rm+qbJ]K'W]BqT,h>PRM&!iJS.7+tL=?fTU`;F00l^<eSt8.'3jGjRrI2NZaa%/[NgK`hm6itd75R_
	;<Rp41?2OT7n,(#]Yl'p4^#M[jXGM'[q!MMCSYqt9F?7rpI5i4HWp9JqD;3[ofDGIBctiOp^i(*%a1
	Rg?I2;&)mrZ5>k5F#_ckk_#9li96f'E"'<DK@.qkh>EpbeH-D39tPC:0M9.aMq6WbT0%2GI\"DS'G5
	/tP+M3LBh0Q!lYE=)&6!Q-JG)_gUFs)hHR_h=l=t<C']1"86-nKnK=3nYc[O:%SA`T!AUmHuMC,eF>
	X0p)j=tCtn[Rn^6K:<E6ZeY&2o^X.0IR-TPJ59hFh!oCV\Iq*s@d?#MWjjnHeKpM:`gN'Xua-:P`l>
	S)uX,*%>T;h=H7?nqpa8+p>b)tr3AJCG0N,Xe11KKY]]J^ffFR-98f\0)o:6lZM1VZL9;-=\0@A.L#
	u@1Osr80&:46I_u"fRq9_80-B9M/Lsu$Na3r`/tUR.M2;]1'UWHp0aU6p>COQe.H[G7%F[<4d_1Ze<
	)n]k_;71+<Yep*!oK?!auTd@j#o)%jnkr%k\,Y*>(e.e>Y^cK?4s$*SH(%DLC>\NA6c!k@:?L0E24_
	h[DDhDXFW@WT4DX3r3_dH3+;T,bES>)/hn]e$^Lg$Nj'8cP]+FnA:M>"SlKeWT+u'jUY-L!SHf2cNg
	ci'+)n?K![0>Wfq\ldKL+6E(Rp/)+G3bY`$`aaUFF%r%Q_kYS34*K\:OU0+@-/395+6$nl-/8s'cVM
	0cCaSDhRV'W"(il\!lI8P6j<2;/iN'hKB\M&D(MESOQU2iKNa?l(.E%)NZ$me>epM+MOCDD0][#-ga
	i@TePC(ON5`P<Op\pL"da0an-4+l3)@fSN0.dVUGe(C!`.S9cUjL)4u[+\<>:JpOX/P8FKI8Wi2MC$
	`b`'R@,!m0c;T,gQ5VObV229T(*$(^]TG/kf^k18[P?qZjG@P9o:>_khciaHFL;*Gc$A4F;$"_M42)
	*pg`hL*:PgjR9o;m)3Ea;DQlkqneFGM.J^"Z>b'^?jS@p,@s$jKh2\?Ji&V?K3d,dM%:4TfL#JP&2f
	=+3nQ2tGkPNZbR5Z74kPH[$q$h$OkYLofSR^o8C(ZOm0c;N,hCp^Mf1=Z%i1+R(kM<e(FCjF!E2HX%
	sDA/-8(`BfL#JP&1!,*3S8@`GkPMs>Rr'p*pg`hL1+NMkj-&;m)2;-#$YbJ(hP/#D?jB8_m9S`jDu/
	hpL"da0aokd7s>Je@4*Z@KFG<9^+`5Q@N5VWm-r#^b>I2-FcTU&^hFCV9[GP^PQi.%F@-9Hh9`u+2f
	pb$%38,a6O+:\d(r+/F>2)O*DCQB#8>qk#=/uTZu)^;L&_2R!(fUS7'8jaJc
	ASCII85End
End


Structure CC_AxisInfo
//	int32 axisType	// funky axisType value if showing, 0 if hidden, obsolete as of version 6.01
	int32 visible	// 1 if showing, 0 if hidden
	int32 lineSize	// we don't set it, but we want to know what its value is.
	char ticks		// show/hide tick marks and labels:
					//	0:	disable tick marks.
					//	1:	enable tick marks.
					//	2:	enable labels.
					//	3:	enable both tick marks and labels.
	int32 numTicks
	// Numeric Labels Rotation
	double rotateAroundX
	double rotateAroundY
	double rotateAroundZ
	double labelRotationAngle
	// Numeric Labels Offset
	double labelOffsetX
	double labelOffsetY
	double labelOffsetZ
	// end version 6.01
	// start version 6.05
	double tickLen
EndStructure

Structure CC_CubeInfo
	STRUCT CC_AxisInfo xAxes[4]
	STRUCT CC_AxisInfo yAxes[4]
	STRUCT CC_AxisInfo zAxes[4]
EndStructure

Static Function InitCubeInfo(cubeInfo)
	STRUCT CC_CubeInfo &cubeInfo
	
	STRUCT CC_AxisInfo axDefaults
	axDefaults.visible=1
	axDefaults.lineSize=1
	axDefaults.ticks=0
	axDefaults.numTicks= 5
	axDefaults.rotateAroundX= 0
	axDefaults.rotateAroundY= 0
	axDefaults.rotateAroundZ= 0
	axDefaults.labelRotationAngle= 0

	axDefaults.labelOffsetX= 0
	axDefaults.labelOffsetY= 0
	axDefaults.labelOffsetZ= 0
	
	axDefaults.tickLen= 1
	
	Variable i, axisIndex
	for(i=0;i<4;i+=1)
		cubeInfo.xAxes[i]= axDefaults
		cubeInfo.yAxes[i]= axDefaults
		cubeInfo.zAxes[i]= axDefaults
	endfor
End

Static Function GetCubeInfo(cubeInfo)
	STRUCT CC_CubeInfo &cubeInfo	// output

	String userData=GetUserData("GizmoBoxAxes", "cube", "")
	Variable haveUserData= strlen(userData)
	if( haveUserData )
		StructGet/S cubeInfo,userData
	endif
	return haveUserData
End

Static Function SetCubeInfo(cubeInfo)
	STRUCT CC_CubeInfo &cubeInfo	// output

	String userData
	StructPut/S cubeInfo,userData
	
	CustomControl cube win=GizmoBoxAxes, userData=userData
End

// note that this does not return the axis range 
Static Function GetAxisInfo(cubeInfo, whichAxis, whichNum, ai)
	STRUCT CC_CubeInfo &cubeInfo	// input
	String whichAxis
	Variable whichNum
	STRUCT CC_AxisInfo &ai	// output

	if( whichNum < 0 || whichNum > 3 )
		return 0
	endif

	strswitch( whichAxis )
		case "x":
			ai= cubeInfo.xAxes[whichNum]
			break
			
		case "y":
			ai= cubeInfo.yAxes[whichNum]
			break
			
		case "z":
			ai= cubeInfo.zAxes[whichNum]
			break
			
		default:
			return 0
	endswitch
	return 1
End

Static Function SetAxisInfo(cubeInfo, whichAxis, whichNum, ai)
	STRUCT CC_CubeInfo &cubeInfo	// input
	String whichAxis
	Variable whichNum
	STRUCT CC_AxisInfo &ai	// input
	
	if( whichNum < 0 || whichNum > 3 )
		return 0
	endif

	strswitch( whichAxis )
		case "x":
			cubeInfo.xAxes[whichNum]= ai
			break
			
		case "y":
			cubeInfo.yAxes[whichNum]= ai
			break
			
		case "z":
			cubeInfo.zAxes[whichNum]= ai
			break
			
		default:
			return 0
	endswitch
	return 1
End

// note that this does not (yet) update the axis range 
Static Function UpdateAxisInfo(whichAxis, whichNum, ai)
	String whichAxis
	Variable whichNum
	STRUCT CC_AxisInfo &ai

	STRUCT CC_CubeInfo cubeInfo
	if( GetCubeInfo(cubeInfo) )
		SetAxisInfo(cubeInfo, whichAxis, whichNum, ai)
		SetCubeInfo(cubeInfo)
	endif
End

Function MyCC_CubeFunc(s)
	STRUCT WMCustomControlAction &s

	STRUCT CC_CubeInfo cubeInfo
	
	String whichAxis	// "x", "y", "z"
	Variable whichNum	// 0-3

	switch(s.eventCode)
		case kCCE_draw:
			if( strlen(s.userdata) )
				StructGet/S cubeInfo,s.userdata
			else
				InitCubeInfo(cubeInfo)
				StructPut/S cubeInfo,s.userdata	// will be written out to control
			endif
			DrawAxes(s.win, s.ctrlName, cubeInfo)
			break
		case kCCE_frame:	// frame, as in which frame of the 0...n-1 frames in the control's picture
			s.curFrame= 1
			break
		case kCCE_mousedown:	// in control
			Variable clickX = s.mouseLoc.h - s.ctrlRect.left
			Variable clickY = s.mouseLoc.v - s.ctrlRect.top
			
			Variable hit= AxisHitTest(clickX, clickY,whichAxis, whichNum)
			if( !hit )
				break
			endif

			StructGet/S cubeInfo,s.userdata

			String gizmoName= StrVarOrDefault(PanelDFVar("topGizmo"),"")
			String boxAxesName= StrVarOrDefault(PanelDFVar("boxAxesName"),"")
			
			STRUCT CC_AxisInfo ax
			strswitch(whichAxis)
				case "x":
					ax= cubeInfo.xAxes[whichNum]
					break
				case "y":
					ax= cubeInfo.yAxes[whichNum]
					break
				case "z":
					ax= cubeInfo.zAxes[whichNum]
					break
			endswitch

			Variable axisIndex=AxisIndexForWhichAxisAndNum(whichAxis, whichNum)
			String cmd
			
			// select or toggle axis
			String selectionAction= StrVarOrDefault(PanelDFVar("selectionAction"),"")
			strswitch(selectionAction)
				case "selectAxes":	// selection is a property of the panel, not the axes
					SVAR/Z whichSelectedAxis = $PanelDFVar("whichSelectedAxis")
					NVAR/Z whichSelectedNum = $PanelDFVar("whichSelectedNum")
					if( SVAR_Exists(whichSelectedAxis) && NVAR_Exists(whichSelectedNum) )
						// toggle selection off if the selected axis is the one we've just clicked
						if( CmpStr(whichSelectedAxis,whichAxis) == 0 && whichSelectedNum == whichNum )
							whichAxis= ""
							whichNum = NaN
						endif
					endif
					String/G $PanelDFVar("whichSelectedAxis") = whichAxis
					Variable/G $PanelDFVar("whichSelectedNum") = whichNum
					Execute/P/Q/Z GetIndependentModuleName()+"#GizmoBoxAxes#UpdateGizmoBoxAxesPanel()"
					break
				case "toggleAxes":
					ax.visible = !ax.visible
					// Change the gizmo
					if( strlen(gizmoName) && strlen(boxAxesName) )
						sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={%d,visible,%d}", gizmoName, boxAxesName, axisIndex, ax.visible
						EchoExecute(cmd, slashP=1, slashZ=1)	// defer so the control can update quickly
						Variable axisType=AxisConstantForAxisIndex(axisIndex)	// in case old versions set axType=0
						sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={%d,axisType,%d}", gizmoName, boxAxesName, axisIndex, axisType
						EchoExecute(cmd, slashP=1, slashZ=1)	// defer so the control can update quickly
					endif
					break
				case "toggleTicks":
					//Axes	ticks	0:	disable tick marks.
					//				1:	enable tick marks.
					//				2:	enable labels.
					//				3:	enable both tick marks and labels.
					if( ax.ticks %& 0x1 )	// ticks enabled
						ax.ticks= ax.ticks %& ~0x1	// disable ticks
					else
						ax.ticks= ax.ticks %| 0x1		// enable ticks
					endif
					// Change the gizmo
					if( strlen(gizmoName) && strlen(boxAxesName) )
						sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={%d,ticks,%d}", gizmoName, boxAxesName, axisIndex, ax.ticks
						EchoExecute(cmd, slashP=1, slashZ=1)	// defer so the control can update quickly
					endif
					break
				case "toggleLabels":
					//Axes	ticks	0:	disable tick marks.
					//				1:	enable tick marks.
					//				2:	enable labels.
					//				3:	enable both tick marks and labels.
					if( ax.ticks %& 0x2 )	// labels enabled
						ax.ticks= ax.ticks %& ~0x2	// disable labels
					else
						ax.ticks= ax.ticks %| 0x2		// enable labels
					endif
					// Change the gizmo
					if( strlen(gizmoName) && strlen(boxAxesName) )
						sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s, property={%d,ticks,%d}", gizmoName, boxAxesName, axisIndex, ax.ticks
						EchoExecute(cmd, slashP=1, slashZ=1)	// defer so the control can update quickly
					endif
					break
			endswitch

			strswitch(whichAxis)
				case "x":
					cubeInfo.xAxes[whichNum]= ax
					break
				case "y":
					cubeInfo.yAxes[whichNum]= ax
					break
				case "z":
					cubeInfo.zAxes[whichNum]= ax
					break
			endswitch
			StructPut/S cubeInfo,s.userdata	// will be written out to control
			break
	endswitch
	return 0
End

Static Function DrawAxes(win, ctrlName, cubeInfo)
	String win, ctrlName
	STRUCT CC_CubeInfo &cubeInfo

	// Draw Back to Front

	DrawAxis(cubeInfo.zAxes[1], "z", 1, 0)
	DrawAxis(cubeInfo.zAxes[2], "z", 2, 0)
	DrawAxis(cubeInfo.xAxes[1], "x", 1, 0)
	DrawAxis(cubeInfo.xAxes[2], "x", 2, 0)

	DrawAxis(cubeInfo.yAxes[0], "y", 0, 0)
	DrawAxis(cubeInfo.yAxes[1], "y", 1, 0)
	DrawAxis(cubeInfo.yAxes[2], "y", 2, 0)
	DrawAxis(cubeInfo.yAxes[3], "y", 3, 0)

	DrawAxis(cubeInfo.xAxes[0], "x", 0, 0)
	DrawAxis(cubeInfo.xAxes[3], "x", 3, 0)
	DrawAxis(cubeInfo.zAxes[0], "z", 0, 0)
	DrawAxis(cubeInfo.zAxes[3], "z", 3, 0)


	Variable i, maxLineSize=1
	for(i=0;i<4;i+=1)
		if( cubeInfo.xAxes[i].lineSize > maxLineSize )
			maxLineSize= cubeInfo.xAxes[i].lineSize
		endif
		if( cubeInfo.yAxes[i].lineSize > maxLineSize )
			maxLineSize= cubeInfo.xAxes[i].lineSize
		endif
		if( cubeInfo.zAxes[i].lineSize > maxLineSize )
			maxLineSize= cubeInfo.xAxes[i].lineSize
		endif
	endfor
	

	// draw again so the selection rectangle is on top
	Variable drawSelection=maxLineSize
	for(i=0;i<4;i+=1)
		DrawAxis(cubeInfo.xAxes[i], "x", i, drawSelection)
		DrawAxis(cubeInfo.yAxes[i], "y", i, drawSelection)
		DrawAxis(cubeInfo.zAxes[i], "z", i, drawSelection)
	endfor
	
	// put the labels on the very top
	ControlInfo/W=$win showAxisNames
	if( V_Flag && V_Value )
		DrawLabels(win)
	endif
End

Static Function GetAxisLine(x0, y0, x1, y1, whichAxis, whichNum)
 	Variable &x0, &y0, &x1, &y1
	String whichAxis	// "x", "y", "z"
	Variable whichNum

// indented the box 2 pixels to make room for "numeric" labels
	Variable dx0=10+2
	Variable dx1=68+2
	Variable dx2=166-2
	Variable dx3=224-2

	Variable dy0=10+2
	Variable dy1=68+2
	Variable dy2=166-2
	Variable dy3=223-2

	strswitch( whichAxis )
		case "x":
			switch( whichNum )
				case 0:
					x0=dx1
					y0=dy3
					x1=dx3
					y1=dy3
					break
				case 1:
					x0=dx0
					y0=dy2
					x1=dx2
					y1=dy2
					break
				case 2:
					x0=dx0
					y0=dy0
					x1=dx2
					y1=dy0
					break
				case 3:
					x0=dx1
					y0=dy1
					x1=dx3
					y1=dy1
					break
			endswitch
			break
		case "y":
			switch( whichNum )
				case 0:
					x0=dx0
					y0=dy2
					x1=dx1
					y1=dy3
					break
				case 1:
					x0=dx0
					y0=dy0
					x1=dx1
					y1=dy1
					break
				case 2:
					x0=dx2
					y0=dy0
					x1=dx3
					y1=dy1
					break
				case 3:
					x0=dx2
					y0=dy2
					x1=dx3
					y1=dy3
					break
			endswitch
			break
		case "z":
			switch( whichNum )
				case 0:
					x0=dx1
					y0=dy1
					x1=dx1
					y1=dy3
					break
				case 1:
					x0=dx0
					y0=dy0
					x1=dx0
					y1=dy2
					break
				case 2:
					x0=dx2
					y0=dy0
					x1=dx2
					y1=dy2
					break
				case 3:
					x0=dx3
					y0=dy1
					x1=dx3
					y1=dy3
					break
			endswitch
			break
	endswitch
End

// if this returns 0, the whichAxis and whichNum are probably "x" and 4, but should be ignored
static Function AxisHitTest(clickX, clickY,whichAxis, whichNum)
	Variable clickX, clickY	// relative to the top-left of the control
	String &whichAxis		// OUTPUT: "x", "y", "z"
	Variable &whichNum	// OUTPUT: 0-3

	Variable hit= 0
	
	whichAxis= "x"
	for(whichNum=0; whichNum<4; whichNum+=1 )
		if( InAxisClick(clickX, clickY,whichAxis,whichNum) )
			return 1
		endif
	endfor

	whichAxis= "z"
	for(whichNum=0; whichNum<4; whichNum+=1 )
		if( InAxisClick(clickX, clickY,whichAxis,whichNum) )
			return 1
		endif
	endfor
		
	// diagonal hits last
	whichAxis= "y"
	for(whichNum=0; whichNum<4; whichNum+=1 )
		if( InAxisClick(clickX, clickY,whichAxis,whichNum) )
			return 1
		endif
	endfor
		
	return 0
End

// to make the hit testing easy, test for Y and Z axes first, then if no hit test for x (diagonal) axes.

Static Function InAxisClick(clickX, clickY,whichAxis, whichNum)
	Variable clickX, clickY
	String whichAxis	// "x", "y", "z"
	Variable whichNum

	Variable hit=0
	Variable epsilon = 5		// +/- pixels
	
	Variable x0, y0, x1, y1
	GetAxisLine(x0, y0, x1, y1, whichAxis, whichNum)

	// hit testing method varies with the direction of the line
	strswitch( whichAxis )
		case "y":	// diagonal lines (drawn from top-left to bottom right)
			hit= (clickX >= x0) && (clickX <= x1) && (clickY >= y0) && (clickY <= y1)
			if( hit )
				// compute distance to line. if the line is defined by (x1, y1) and (x2, y2)
				// the distance from a point (x0,y0) to the line is:
				// d= | (x2-x1)(y1-y0) - (x1-x0)*(y2-y1) |
				//    ________________________________
				//	sqrt((x2-x1)^2 + (y2-y1)^2)
				// COV:	(x0,y0) => (clickX,clickY)
				//		(x1,y1) => (x0, y0)
				//		(x2,y2) => (x1, y1)
				Variable denom = sqrt((x1-x0)*(x1-x0) + (y1-y0)*(y1-y0))
				Variable num= (x1-x0)*(y0-clickY) - (x0-clickX)*(y1-y0)
				Variable distance=abs(num)/denom
				if( distance > epsilon )
					hit= 0
				endif
			endif
			break
		case "x":	// horizontal lines (drawn left-to-right)
			hit= (clickX >= x0) && (clickX <= x1) && abs(clickY-y0) <= epsilon
			break
		case "z":	// vertical lines (drawn top to bottom)
			hit= (clickY >= y0) && (clickY <= y1) && abs(clickX-x0) <= epsilon
			break
	endswitch
	return hit
End


Static Function DrawAxis(ai, whichAxis, whichNum, drawSelection)
	STRUCT CC_AxisInfo &ai
	String whichAxis	// "x", "y", "z"
	Variable whichNum
	Variable drawSelection	// 0 if we're not drawing the selection now (we're drawing the axis itself)
							// else it is max(1,the size of the widest axis line)
	
	Variable x0, y0, x1, y1
	GetAxisLine(x0, y0, x1, y1, whichAxis, whichNum)

	if( drawSelection )
		String whichSelectedAxis	// "x", "y", "z"
		Variable whichSelectedNum
		if( GetSelectedAxis(whichSelectedAxis, whichSelectedNum) && (CmpStr(whichSelectedAxis,whichAxis) == 0) && (whichSelectedNum==whichNum) )
			Variable size= max(4, drawSelection+1)	// half size
			Variable left, top, right, bottom
			left= x0-size
			right=x0+size
			top=y0-size
			bottom=y0+size
			SetDrawEnv fillpat=1, fillfgc=(0,0,0)
			DrawRect left, top, right, bottom
			left= x1-size
			right=x1+size
			top=y1-size
			bottom=y1+size
			SetDrawEnv fillpat=1, fillfgc=(0,0,0)
			DrawRect left, top, right, bottom
		endif
	else
		if( ai.visible )
			Variable tickAngle,  tickLen= 2
			strswitch(whichAxis)
				case "x":
					SetDrawEnv linefgc= (50000,10000,10000), save
					tickAngle= 90
					break
				case "y":
					SetDrawEnv linefgc= (10000,50000,10000), save
					tickLen= 4	// extra length for diagonal axes
					tickAngle= 90
					break
				case "z":
					SetDrawEnv linefgc= (10000,10000,50000), save
					tickAngle= 0
					break
			endswitch
			Variable ls= min(10,ai.lineSize + 1)
			SetDrawEnv lineThick=ls
			DrawLine x0,y0,x1,y1

			if( ai.ticks )
					//	ai.ticks=	0:	disable tick marks.
					//				1:	enable tick marks.
					//				2:	enable labels.
					//				3:	enable both tick marks and labels.
				Variable i, n=5	// pretend there are only 4 ticks per axis
				Variable dy= y1-y0
				Variable dx= x1-x0
				
				tickAngle *= pi/180
				tickLen += ls/2

				for(i = 1; i < n; i += 1 )
					Variable tx= x0 + i * dx/n
					Variable ty= y0 + i * dy/n
			
					Variable tx0 = tx - cos(tickAngle)*ticklen
					Variable tx1 = tx + cos(tickAngle)*ticklen

					Variable ty0 = ty - sin(tickAngle)*ticklen
					Variable ty1 = ty + sin(tickAngle)*ticklen
			
					if( ai.ticks & 0x1 )	// tick marks
						DrawLine tx0,ty0,tx1,ty1
					endif
					
					if( ai.ticks & 0x2 )	// tick labels
						Variable tx2 = tx - cos(tickAngle)*ticklen*3
						Variable ty2 = ty + sin(tickAngle)*ticklen*3
						SetDrawEnv textxjust=1, textyjust=1, fsize=10
						DrawText tx2,ty2,"#"
					endif
				endfor
			endif

			SetDrawEnv linefgc= (0,0,0), lineThick=1, save
		endif
	
	endif

End


Static Function DrawLabels(win)
	String win
	
	SetDrawEnv fsize= 13,fstyle= 1
	DrawText 89,174,"X"
	SetDrawEnv fsize= 11,fstyle= 1
	DrawText 99,177,"1"
	
	SetDrawEnv fsize= 13,fstyle= 1
	DrawText 139,229,"X"
	SetDrawEnv fsize= 11,fstyle= 1
	DrawText 149,232,"0"
	
	SetDrawEnv fsize= 13,fstyle= 1
	DrawText 89,19,"X"
	SetDrawEnv fsize= 11,fstyle= 1
	DrawText 99,22,"2"
	
	SetDrawEnv fsize= 13,fstyle= 1
	DrawText 139,77,"X"
	SetDrawEnv fsize= 11,fstyle= 1
	DrawText 149,80,"3"

	SetDrawEnv fsize= 13,fstyle= 1
	DrawText 34,199,"Y"
	SetDrawEnv fsize= 11,fstyle= 1
	DrawText 42,202,"0"
	
	SetDrawEnv fsize= 13,fstyle= 1
	DrawText 32,47,"Y"
	SetDrawEnv fsize= 11,fstyle= 1
	DrawText 40,50,"1"
	
	SetDrawEnv fsize= 13,fstyle= 1
	DrawText 190,49,"Y"
	SetDrawEnv fsize= 11,fstyle= 1
	DrawText 198,52,"2"
	
	SetDrawEnv fsize= 13,fstyle= 1
	DrawText 187,201,"Y"
	SetDrawEnv fsize= 11,fstyle= 1
	DrawText 195,204,"3"
	
	SetDrawEnv fsize= 13,fstyle= 1
	DrawText 63,148,"Z"
	SetDrawEnv fsize= 11,fstyle= 1
	DrawText 71,151,"0"
	
	SetDrawEnv fsize= 13,fstyle= 1
	DrawText 4,99,"Z"
	SetDrawEnv fsize= 11,fstyle= 1
	DrawText 12,102,"1"
	
	SetDrawEnv fsize= 13,fstyle= 1
	DrawText 158,99,"Z"
	SetDrawEnv fsize= 11,fstyle= 1
	DrawText 166,102,"2"
	
	SetDrawEnv fsize= 13,fstyle= 1
	DrawText 216,148,"Z"
	SetDrawEnv fsize= 11,fstyle= 1
	DrawText 224,151,"3"
End

Static Function ShowAxisNamesCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	// set control mode to 1

	CustomControl cube mode=1	// anything to force a redraw
End

// Users have noticed that the Gizmo command are never echoed to the history, so we do that now.
// Users can set root:Packages:GizmoBoxAxes:verbose to zero to suppress this printing.
// if you're calling this, you're not wanting /Q functionality

static Function EchoExecute(command, [slashP, slashZ])
	String command
	Variable slashP, slashZ
	
	if( ParamIsDefault(slashP) )
		slashP= 0
	endif
	if( ParamIsDefault(slashZ) )
		slashZ= 0
	endif
	Variable slashQ= NumVarOrDefault(PanelDFVAR("verbose"),1) ? 0 : 1
	
	GizmoEchoExecute(command, slashQ=slashQ, slashP=slashP, slashZ=slashZ)
End


// user limits

// returns the autoscale value for only one axis
static Function AutoscaleGizmoAxisRange(gizmoName,whichAxis,axisMin,axisMax)
	String gizmoName,whichAxis
	Variable &axisMin, &axisMax

	return GetGizmoAxisRange(gizmoName, whichAxis, axisMin, axisMax, getDataLimits=1)
End

Static Function/S PanelDF()
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:GizmoBoxAxes
	return "root:Packages:GizmoBoxAxes"
End

Static Function/S PanelDFVar(varName)
	String varName
	
	return PanelDF()+":"+PossiblyQuoteName(varName)
End

// Set the data folder to a place where Execute can dump all kinds of variables and waves.
// Returns the old data folder.
Static Function/S SetPanelDF()

	String oldDF= GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S $PanelDF()	// DF is left pointing here to an existing or created data folder.
	return oldDF
End

// returns the path to the Gizmo-specific GizmoBoxAxes package data folder, creating it if needed.
static Function/S GizmoDF(gizmoName)
	String gizmoName
	
	if( strlen(gizmoName) == 0 )
		gizmoName= TopGizmo()
	endif
	String dfName= gizmoName
	if( strlen(dfName) == 0 )
		dfName= "Defaults"		// no gizmos, use defaults.
	endif
	String df= PanelDF()+":"+dfName
	NewDataFolder/O $df
	return df
End

// Returns the path to gizmo-specific variable, string or wave, which may not exist.
static Function/S GizmoDFVar(gizmoName,varName)
	String gizmoName,varName
	
	return GizmoDF(gizmoName)+":"+PossiblyQuoteName(varName)
End

// Each Gizmo may have multiple BoxAxes.
// Returns the path to the suface-specific data folder, creating it if necessary
static Function/S GizmoBoxAxesDF(gizmoName, BoxAxesName)
	String gizmoName, BoxAxesName
	
	String df= GizmoDF(gizmoName) + ":" + BoxAxesName
	NewDataFolder/O $df
	return df
End

// Returns the path to BoxAxes-specific variable, string or wave, which may not exist.
static Function/S GizmoBoxAxesDFVar(gizmoName,BoxAxesName,varName)
	String gizmoName,BoxAxesName,varName
	
	return GizmoBoxAxesDF(gizmoName,BoxAxesName)+":"+PossiblyQuoteName(varName)
End

Static Function/S GizmoBoxAxesList(gizmoName)
	String gizmoName

	if( strlen(gizmoName) == 0 )
		gizmoName=TopGizmo()
		if( strlen(gizmoName) == 0 )
			return "_none_"
		endif
	endif

	String boxAxesNameList=""
	String code= WinRecreation(gizmoName, 0)
	
	// parse:
	// AppendToGizmo Axes=boxAxes,name=axes0
	Variable start=0
	do
		String key="AppendToGizmo Axes=boxAxes,name="
		start= Strsearch(code, key, start)
		if( start < 0 )
			break
		endif
		start += strlen(key)	// point past key to name
		Variable theEnd= strsearch(code, num2char(13), start)
		if( theEnd < 0 )
			break
		endif
		boxAxesNameList += code[start, theEnd-1]+";"
		start= theEnd+1
	while(1)
	if( strlen(boxAxesNameList) == 0 )
		boxAxesNameList= "_none_"
	endif
	return boxAxesNameList
End


Static Function PanelWindowHook(hs)
	STRUCT WMWinHookStruct &hs
	
	Variable statusCode= 0
	strswitch( hs.eventName )
		case "activate":
			UpdateGizmoBoxAxesPanel()
			break
	endswitch
	return statusCode		// 0 if nothing done, else 1
End


 // compare to GizmoContours#UpdateGizmoContourPanel()
Static Function UpdateGizmoBoxAxesPanel()

	DoWindow GizmoBoxAxes
	if( V_Flag == 0 )
		return 0
	endif

	String allControls= ControlNameList("GizmoBoxAxes", ";", "*")
	allControls= RemoveFromList("topGizmoSV;help;", allControls)

	String gizmoName= TopGizmo()
	String/G $PanelDFVar("topGizmo")= gizmoName	// for the topGizmoSV SetVariable

	if( strlen(gizmoName) == 0 )
		ModifyControlList allControls, win=GizmoBoxAxes, disable=1
		return 0	// NO GIZMO!
	endif

	// enable each control directly

	ModifyControlList "cube;showAxisNames;sameRotation;autoScaleXYZ;gizmoInfo;axisLabels;", win=GizmoBoxAxes, disable=0

	Variable isDefaultRot= IsDefaultRotation(gizmoName)
	if( ! isDefaultRot )
		SaveGizmoRotationCommand(gizmoName)
	endif

	Variable disable
	String rotateBackCommand= OldGizmoRotation(gizmoName)
	if( isDefaultRot && (strlen(rotateBackCommand) > 0)  )
		disable= 0
	else
		disable= 2
	endif

	ModifyControl rotateBack win= GizmoBoxAxes, disable=disable

	String boxAxesList= GizmoBoxAxesList(gizmoName)
	Variable numBoxAxes= 0
	Variable whichOne, mode
	String boxAxesName
	if( CmpStr(boxAxesList, "_none_") == 0 )
		boxAxesName= "_none_"
		mode=1
	else
		boxAxesName=  StrVarOrDefault(PanelDFVar("boxAxesName"), StringFromList(0,boxAxesList))
		whichOne= max(0,WhichListItem(boxAxesName, boxAxesList))
		boxAxesName= StringFromList(whichOne, boxAxesList)
		mode= 1+whichOne
	endif
	String/G $PanelDFVar("boxAxesName")= boxAxesName
	Variable haveAxes= CmpStr(boxAxesName, "_none_") != 0 && NameIsInGizmoObjectList(gizmoName,boxAxesName)
	
	PopupMenu axesPop, win=GizmoBoxAxes, mode=mode, popvalue=boxAxesName
	ModifyControlList "axesPop;appendAxes;", win= GizmoBoxAxes, disable=0
	
	disable= haveAxes ? 0 : 2
	ModifyControlList "removeAxes;resetLabelRotations;gizmoAxesInfo;", win=GizmoBoxAxes, disable=disable
	
	if( haveAxes )
		ModifyControl gizmoAxesInfo, win=GizmoBoxAxes, title=boxAxesName+" Info..."
	else
		ModifyControl gizmoAxesInfo, win=GizmoBoxAxes, title="Box Axes Info..."
	endif

	String selectionAction =StrVarOrDefault(PanelDFVar("selectionAction"),"toggleAxes")
	Checkbox toggleAxes win=GizmoBoxAxes, value=CmpStr(selectionAction,"toggleAxes") == 0
	Checkbox toggleTicks win=GizmoBoxAxes, value=CmpStr(selectionAction,"toggleTicks") == 0
	Checkbox toggleLabels win=GizmoBoxAxes, value=CmpStr(selectionAction,"toggleLabels") == 0
	Checkbox selectAxes win=GizmoBoxAxes, value=CmpStr(selectionAction,"selectAxes") == 0
	String/G $PanelDFVar("selectionAction")= selectionAction	// version 6.0
	
	ModifyControlList "selectAxes;selectedAxisGroup;toggleAxes;toggleLabels;toggleTicks;", win=GizmoBoxAxes, disable=disable

	STRUCT CC_CubeInfo cubeInfo
	GetCubeInfoFromGizmoBoxAxes(gizmoName, boxAxesName, cubeInfo)
	SetCubeInfo(cubeInfo)	// for GetSelectedAxisInfo() and control

	// Set up selection controls (if any selection), regardless of the current click mode/radio button
	
	String whichAxis
	Variable whichNum
	STRUCT CC_AxisInfo ai
	String axisObjectName	// same as boxAxesName if an axis is selected
	Variable selected= GetSelectedAxisInfo(whichAxis, whichNum, ai, axisObjectName, gizmoName)

	String checkboxLabel= "      Click Selects an Axis"
	if( selected )
		checkboxLabel += " ("+UpperStr(whichAxis)+num2str(whichNum)+" selected)"
	endif
	ModifyControl selectedAxisGroup, win=GizmoBoxAxes, title=checkboxLabel

	// establish default axis of rotation
	// here's what's weird: rotation of the labels is relative to the label, NOT the world.
	// So the axes and their meanings are:
	// rotateAroundX = rotate the label back and forward (like a pig on a spit!)
	// rotateAroundY = rotate while keeping the label upright = rotate around world Z
	// rotateAroundZ = rotate the label like the hands of a clock.
	if( ai.rotateAroundX == 0 &&  ai.rotateAroundY == 0 && ai.rotateAroundZ == 0 )
		ai.rotateAroundY= 1	// world Z axis
		SetAxisInfo(cubeInfo, whichAxis, whichNum, ai)

		if( selected )
			Variable axisIndex=AxisIndexForWhichAxisAndNum(whichAxis, whichNum)
			String cmd
			String df= SetPanelDF()
			sprintf cmd "ModifyGizmo/N=%s ModifyObject=%s,property={%d,labelRotationAxis,%g, %g, %g}", gizmoName, axisObjectName, axisIndex, ai.rotateAroundX, ai.rotateAroundY, ai.rotateAroundZ
			Execute/Q/Z cmd
			SetDataFolder df
		endif
	endif
	
	SetCubeInfo(cubeInfo)

	// If axis is selected, transfer from axis info to controls
	disable= (haveAxes && selected) ? 0 : 1
	
	ModifyControlList/Z "labelRotationAngle;numTicks;tickLen;rotateAroundX;rotateAroundY;rotateAroundZ;rotateAroundOther;rotationTItle;" win= GizmoBoxAxes, disable=disable
	ModifyControlList/Z "labelOffset;offsetForwardBack;offsetLeftRight;offsetTitle;offsetUpDown;" win= GizmoBoxAxes, disable=disable
	ModifyControlList/Z "axisMin;axisMax;autoscaleAxis;fivePercentAxis" win= GizmoBoxAxes, disable=disable

	if( !disable )
	
		// ai.numTicks
		Variable/G $PanelDFVar("numTicks")= ai.numTicks

		// 6.05: ai.tickLen
		Variable/G $PanelDFVar("tickLen")= ai.tickLen

		// Get the axis range directly from the gizmo
		Variable axisMin, axisMax
		GetGizmoAxisRange(gizmoName,whichAxis,axisMin,axisMax)
		Variable/G $PanelDFVar("axisMin")=axisMin
		Variable/G $PanelDFVar("axisMax")=axisMax
		SetVariable axisMin win=GizmoBoxAxes, title=UpperStr(whichAxis) +" Min"
		SetVariable axisMax win=GizmoBoxAxes, title=UpperStr(whichAxis) +" Max"
		
		Button autoscaleAxis win=GizmoBoxAxes, title="Auto "+UpperStr(whichAxis)
	
		//	ai.rotateAroundX
		//	ai.rotateAroundY
		//	ai.rotateAroundZ
		String rotateAround = "rotateAroundOther"	// don't mess with non-orthogonal axes
		// if only one of ai.rotateAroundX, Y, Z is non-zero, it's an orthogonal rotation)
		Variable isX= ai.rotateAroundX != 0
		Variable isY= ai.rotateAroundY != 0
		Variable isZ= ai.rotateAroundZ != 0
		Variable isOrthogonal = (isX + isY + isZ) == 1
		if( isOrthogonal )
			if( isX )
				rotateAround = "rotateAroundX"	
			elseif( isY )
				rotateAround = "rotateAroundY"	
			else
				rotateAround = "rotateAroundZ"	
			endif
		endif
		String/G $PanelDFVar("rotateAround")= rotateAround

		Checkbox rotateAroundX win=GizmoBoxAxes, value=CmpStr(rotateAround,"rotateAroundX") == 0, disable= isOrthogonal ? 0 : 2
		Checkbox rotateAroundY win=GizmoBoxAxes, value=CmpStr(rotateAround,"rotateAroundY") == 0, disable= isOrthogonal ? 0 : 2
		Checkbox rotateAroundZ win=GizmoBoxAxes, value=CmpStr(rotateAround,"rotateAroundZ") == 0, disable= isOrthogonal ? 0 : 2
		Checkbox rotateAroundOther win=GizmoBoxAxes, value=CmpStr(rotateAround,"rotateAroundOther") == 0, disable= isOrthogonal ? 2 : 0
	
		//	ai.labelRotationAngle (degrees)
		Slider labelRotationAngle  win=GizmoBoxAxes, value=ai.labelRotationAngle
		
		// label offset
		String offsetDirection= StrVarOrDefault(PanelDFVar("offsetDirection"), "offsetLeftRight")
		String/G $PanelDFVar("offsetDirection")= offsetDirection
		
		Variable offsetForwardBack=CmpStr(offsetDirection,"offsetForwardBack") == 0
		Variable offsetLeftRight=CmpStr(offsetDirection,"offsetLeftRight") == 0
		Variable offsetUpDown=CmpStr(offsetDirection,"offsetUpDown") == 0
	
		Checkbox offsetForwardBack win=GizmoBoxAxes, value=offsetForwardBack
		Checkbox offsetLeftRight win=GizmoBoxAxes, value=offsetLeftRight
		Checkbox offsetUpDown win=GizmoBoxAxes, value=offsetUpDown

		Variable sliderValue
		if( offsetForwardBack )
			sliderValue= ai.labelOffsetZ
		elseif(offsetLeftRight )
			sliderValue= ai.labelOffsetX
		else	// offsetUpDown
			sliderValue= ai.labelOffsetY
		endif
		Slider labelOffset, win=GizmoBoxAxes, value=sliderValue
	endif
End

// returns 1 if an axis is selected
// returns 0 if no axis is selected
static Function GetSelectedAxis(whichAxis, whichNum)
	String &whichAxis			// output
	Variable &whichNum		// output

	whichAxis= StrVarOrDefault(PanelDFVar("whichSelectedAxis"), "")	// default is none selected
	whichNum= NumVarOrDefault(PanelDFVar("whichSelectedNum"), NaN)
	Variable selected= strlen(whichAxis) > 0
	return selected
End

// returns 1 if an axis is selected
// returns 0 if no axis is selected
Static Function GetSelectedAxisInfo(whichAxis, whichNum, ai, axisObjectName, gizmoName)
	String &whichAxis			// output
	Variable &whichNum		// output
	STRUCT CC_AxisInfo &ai	// output
	String &axisObjectName		// output
	String &gizmoName			// output

	ControlInfo/W=GizmoBoxAxes axesPop
	axisObjectName= S_Value	// can be "_none_"

	Variable selected= GetSelectedAxis(whichAxis, whichNum)

	gizmoName= TopGizmo()
	if( !selected || (strlen(gizmoName) == 0) )
		return 0
	endif

	if( CmpStr(axisObjectName,"_none_") == 0 || !NameIsInGizmoObjectList(gizmoName,axisObjectName) )
		return 0
	endif

	STRUCT CC_CubeInfo cubeInfo
	if( !GetCubeInfo(cubeInfo) )
		return 0
	endif

	GetAxisInfo(cubeInfo, whichAxis, whichNum, ai)
	return 1
End


// returns true if the values were gotten
Static Function GetCubeInfoFromGizmoBoxAxes(gizmoName, boxAxesName, cubeInfo)
	String gizmoName, boxAxesName	// boxAxesName can be "_none_"
	STRUCT CC_CubeInfo &cubeInfo	// output

	InitCubeInfo(cubeInfo)
	
	String code= WinRecreation(gizmoName, 0)
	// find 	AppendToGizmo Axes=boxAxes,name=axes0
	
	String key="AppendToGizmo Axes=boxAxes,name="+boxAxesName
	Variable start= Strsearch(code, key, 0)
	if( start < 0 )
		return 0
	endif
	start += strlen(key)	// point past key to name

	// now parse the axis info:
	// 	ModifyGizmo ModifyObject=axes0,property={0,axisRange,-1,-1,-1,1,-1,-1}
	//	ModifyGizmo ModifyObject=axes0,property={0,axisType,4194305}
	//	ModifyGizmo ModifyObject=axes0,property={0,visible,1}
	//	ModifyGizmo ModifyObject=axes0,property={0,ticks,3}
	//	ModifyGizmo ModifyObject=axes0,property={3,ticks,1}

	key="ModifyGizmo ModifyObject="+boxAxesName+",property={"

	do
		start= Strsearch(code, key, start)
		if( start < 0 )
			break
		endif
		start += strlen(key)	// point past key to index,
		Variable theEnd= strsearch(code, "}", start)
		if( theEnd < 0 )
			break
		endif
		String parameters= code[start, theEnd-1]	// parameters without the { or }
		start= theEnd+1
		
		// interpret the properties:
		// the first param is the axis index
		Variable axisIndex= str2num(StringFromList(0,parameters,","))	// THIS CAN BE -1
		parameters= RemoveListItem(0,parameters,",")
		String whichAxis
		Variable whichNum
		WhichAxisAndNumForAxisIndex(axisIndex, whichAxis, whichNum)

		// remainder of parameters
		String command= StringFromList(0,parameters,",")
		parameters= RemoveListItem(0,parameters,",")

		Variable i
		String str
		STRUCT CC_AxisInfo ai
		
		strswitch( command )
//			case "axisType":
//				GetAxisInfo(cubeInfo, whichAxis, whichNum, ai)
//				str= StringFromList(0,parameters,",")
//				ai.axisType= str2num(str)
//				SetAxisInfo(cubeInfo, whichAxis, whichNum, ai)
//				break

			case "visible":
				GetAxisInfo(cubeInfo, whichAxis, whichNum, ai)
				str= StringFromList(0,parameters,",")
				ai.visible= str2num(str)
				SetAxisInfo(cubeInfo, whichAxis, whichNum, ai)
				break

			case "lineWidth":
				str= StringFromList(0,parameters,",")
				Variable lineSize= str2num(str)
				if( axisIndex == -1 )
					for(i=0;i<4;i+=1)
						cubeInfo.xAxes[i].lineSize= lineSize
						cubeInfo.yAxes[i].lineSize= lineSize
						cubeInfo.zAxes[i].lineSize= lineSize
					endfor
				else
					GetAxisInfo(cubeInfo, whichAxis, whichNum, ai)
					ai.lineSize= lineSize
					SetAxisInfo(cubeInfo, whichAxis, whichNum, ai)
				endif
				break

			case "numTicks":
				str= StringFromList(0,parameters,",")
				Variable numTicks= str2num(str)

				if( axisIndex == -1 )
					for(i=0;i<4;i+=1)
						cubeInfo.xAxes[i].numTicks= numTicks
						cubeInfo.yAxes[i].numTicks= numTicks
						cubeInfo.zAxes[i].numTicks= numTicks
					endfor
				else
					GetAxisInfo(cubeInfo, whichAxis, whichNum, ai)
					ai.numTicks= numTicks
					SetAxisInfo(cubeInfo, whichAxis, whichNum, ai)
				endif
				break

			case "ticks":
				str= StringFromList(0,parameters,",")
				Variable axisTicks= str2num(str)

				if( axisIndex == -1 )
					for(i=0;i<4;i+=1)
						cubeInfo.xAxes[i].ticks= axisTicks
						cubeInfo.yAxes[i].ticks= axisTicks
						cubeInfo.zAxes[i].ticks= axisTicks
					endfor
				else
					GetAxisInfo(cubeInfo, whichAxis, whichNum, ai)
					ai.ticks= axisTicks
					SetAxisInfo(cubeInfo, whichAxis, whichNum, ai)
				endif
				break
				
			case "tickScaling":
				str= StringFromList(0,parameters,",")
				Variable tickLen= str2num(str)

				if( axisIndex == -1 )
					for(i=0;i<4;i+=1)
						cubeInfo.xAxes[i].tickLen= tickLen
						cubeInfo.yAxes[i].tickLen= tickLen
						cubeInfo.zAxes[i].tickLen= tickLen
					endfor
				else
					GetAxisInfo(cubeInfo, whichAxis, whichNum, ai)
					ai.tickLen= tickLen
					SetAxisInfo(cubeInfo, whichAxis, whichNum, ai)
				endif
				break
				
			case "labelRotationAngle":
				str= StringFromList(0,parameters,",")
				Variable labelRotationAngle= str2num(str)

				if( axisIndex == -1 )
					for(i=0;i<4;i+=1)
						cubeInfo.xAxes[i].labelRotationAngle= labelRotationAngle
						cubeInfo.yAxes[i].labelRotationAngle= labelRotationAngle
						cubeInfo.zAxes[i].labelRotationAngle= labelRotationAngle
					endfor
				else
					GetAxisInfo(cubeInfo, whichAxis, whichNum, ai)
					ai.labelRotationAngle= labelRotationAngle
					SetAxisInfo(cubeInfo, whichAxis, whichNum, ai)
				endif
				break
			
			case "labelRotationAxis":
				Variable rotateAroundX= str2num(StringFromList(0,parameters,","))
				Variable rotateAroundY= str2num(StringFromList(1,parameters,","))
				Variable rotateAroundZ= str2num(StringFromList(2,parameters,","))

				if( axisIndex == -1 )
					for(i=0;i<4;i+=1)
						cubeInfo.xAxes[i].rotateAroundX= rotateAroundX
						cubeInfo.xAxes[i].rotateAroundY= rotateAroundY
						cubeInfo.xAxes[i].rotateAroundZ= rotateAroundZ
						
						cubeInfo.yAxes[i].rotateAroundX= rotateAroundX
						cubeInfo.yAxes[i].rotateAroundY= rotateAroundY
						cubeInfo.yAxes[i].rotateAroundZ= rotateAroundZ
						
						cubeInfo.zAxes[i].rotateAroundX= rotateAroundX
						cubeInfo.zAxes[i].rotateAroundY= rotateAroundY
						cubeInfo.zAxes[i].rotateAroundZ= rotateAroundZ
					endfor
				else
					GetAxisInfo(cubeInfo, whichAxis, whichNum, ai)
					ai.rotateAroundX= rotateAroundX
					ai.rotateAroundY= rotateAroundY
					ai.rotateAroundZ= rotateAroundZ
					SetAxisInfo(cubeInfo, whichAxis, whichNum, ai)
				endif
				break
				
			case "labelOffset":			
				Variable labelOffsetX= str2num(StringFromList(0,parameters,","))
				Variable labelOffsetY= str2num(StringFromList(1,parameters,","))
				Variable labelOffsetZ= str2num(StringFromList(2,parameters,","))

				if( axisIndex == -1 )
					for(i=0;i<4;i+=1)
						cubeInfo.xAxes[i].labelOffsetX= labelOffsetX
						cubeInfo.xAxes[i].labelOffsetY= labelOffsetY
						cubeInfo.xAxes[i].labelOffsetZ= labelOffsetZ
						
						cubeInfo.yAxes[i].labelOffsetX= labelOffsetX
						cubeInfo.yAxes[i].labelOffsetY= labelOffsetY
						cubeInfo.yAxes[i].labelOffsetZ= labelOffsetZ
						
						cubeInfo.zAxes[i].labelOffsetX= labelOffsetX
						cubeInfo.zAxes[i].labelOffsetY= labelOffsetY
						cubeInfo.zAxes[i].labelOffsetZ= labelOffsetZ
					endfor
				else
					GetAxisInfo(cubeInfo, whichAxis, whichNum, ai)
					ai.labelOffsetX= labelOffsetX
					ai.labelOffsetY= labelOffsetY
					ai.labelOffsetZ= labelOffsetZ
					SetAxisInfo(cubeInfo, whichAxis, whichNum, ai)
				endif
				break
		endswitch
	
	while(1)
	return 1
End

// convert from this procedure's notion of axis name and number
// to Gizmo axis index.
static Function AxisIndexForWhichAxisAndNum(whichAxis, whichNum)
	String whichAxis
	Variable whichNum

	Variable axisIndex=0
	strswitch( whichAxis )
		case "x":
			switch( whichNum )
				case 0:
					axisIndex=0
					break
				case 1:
					axisIndex=9
					break
				case 2:
					axisIndex=10
					break
				case 3:
					axisIndex=11
					break
			endswitch
			break

		case "y":
			switch( whichNum )
				case 0:
					axisIndex=1
					break
				case 1:
					axisIndex=6
					break
				case 2:
					axisIndex=7
					break
				case 3:
					axisIndex=8
					break
			endswitch
			break

		case "z":
			axisIndex= whichNum+2
			break

		case "All":
			axisIndex= -1
			break
	endswitch
	return axisIndex
End

// convert from Gizmo axis index
// to this procedure's notion of axis name and number
static Function WhichAxisAndNumForAxisIndex(axisIndex, whichAxis, whichNum)
	Variable axisIndex
	String &whichAxis
	Variable &whichNum

	switch( axisIndex )
		case 9:
		case 10:
		case 11:
			axisIndex -= 8
		case 0:
			whichAxis= "x"
			whichNum= axisIndex
			break
			
		case 6:
		case 7:
		case 8:
			axisIndex -= 4
		case 1:
			whichAxis= "y"
			whichNum= axisIndex-1
			break
			
		case 2:
		case 3:
		case 4:
		case 5:
			whichAxis= "z"
			whichNum= axisIndex-2
			break
			
		case -1:
			whichAxis= "All"
			whichNum= -1
			break
	endswitch
	
End

Static Function AxisConstantForAxisIndex(axisIndex)
	Variable axisIndex
	
	Variable axisConstant
	switch( axisIndex )
		case 0:
			axisConstant= 4194305
			break
		case 1:
			axisConstant= 4194306
			break
		case 2:
			axisConstant= 4194308
			break
		case 3:
			axisConstant= 4194312
			break
		case 4:
			axisConstant= 4194320
			break
		case 5:
			axisConstant= 4194336
			break
		case 6:
			axisConstant= 4194368
			break
		case 7:
			axisConstant= 4194432
			break
		case 8:
			axisConstant= 4194560
			break
		case 9:
			axisConstant= 4194816
			break
		case 10:
			axisConstant= 4195328
			break
		case 11:
			axisConstant= 4196352
			break
		default:
			axisConstant= 0
			break
	endswitch
	return axisConstant
End

Static Function ShowHideCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName		// one of "selectAxes", "toggleAxes", "toggleTicks" or "toggleLabels"
	Variable checked
	
	Checkbox selectAxes value=CmpStr(ctrlName,"selectAxes") == 0
	Checkbox toggleAxes value=CmpStr(ctrlName,"toggleAxes") == 0
	Checkbox toggleTicks value=CmpStr(ctrlName,"toggleTicks") == 0
	Checkbox toggleLabels value=CmpStr(ctrlName,"toggleLabels") == 0
	
	String/G $PanelDFVar("selectionAction")= ctrlName
	UpdateGizmoBoxAxesPanel()
End

Static Function BoxAxesPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	String/G $PanelDFVar("boxAxesName")= popStr
	UpdateGizmoBoxAxesPanel()
End


Static Function OrientationButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String gizmoName= TopGizmo()

	strswitch(ctrlName)
		case "sameRotation":
			// Save old coordinates and enable "Put Gizmo Rotation Back"
			if( !IsDefaultRotation(gizmoName) && strlen(SaveGizmoRotationCommand(gizmoName)) )
				ModifyControl rotateBack win= GizmoBoxAxes, disable=0
			endif
			EchoExecute(ksDefaultRotation, slashZ=1)
			break
			
		case "rotateBack":
			String oldRotationCommand= OldGizmoRotation(gizmoName)
			if( strlen(oldRotationCommand) )
				EchoExecute(oldRotationCommand, slashZ=1)
			endif
			ModifyControl rotateBack win= GizmoBoxAxes, disable=2
			break
	endswitch
	
	// flip auto-rotated Z axis labels to show up correctly
	String oldDF= SetPanelDF()
	Execute/Q/Z "ModifyGizmo compile"	// not interesting enough to print to history
	SetDataFolder oldDF
End

static Function IsDefaultRotation(gizmoName)
	String gizmoName

	Variable isDefault=0
	String code= GetGizmoRotationCommand(gizmoName)
	if( strlen(code) )
		isDefault = CmpStr(code, ksDefaultRotation) == 0
	endif

	return isDefault
End

static Function/S SaveGizmoRotationCommand(gizmoName)
	String gizmoName

	String code= GetGizmoRotationCommand(gizmoName)
	if( strlen(code) )
		String/G $GizmoDFVar(gizmoName, "oldRotationCode") = code
	endif

	return code
End


static Function/S OldGizmoRotation(gizmoName)
	String gizmoName

	String path= GizmoDFVar(gizmoName, "oldRotationCode")
	string code= StrVarOrDefault(path, "")
	return code
End

static Function/S GetGizmoRotationCommand(gizmoName)
	String gizmoName

	String code= WinRecreation(gizmoName, 0)
	// find 	ModifyGizmo SETQUATERNION={0.570788,-0.062481,-0.089088,0.813855}"

	String key="ModifyGizmo SETQUATERNION={"
	Variable start= strsearch(code, key, 0)
	if( start < 0 )
		return ""
	endif
	Variable theEnd= strsearch(code, "\r", start)

	return code[start,theEnd-1]
End

Static Function NumTicksSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	String whichAxis
	Variable whichNum
	STRUCT CC_AxisInfo ai
	String axisObjectName, gizmoName
	if( GetSelectedAxisInfo(whichAxis, whichNum, ai, axisObjectName, gizmoName) )
		ai.numTicks= varNum
		Variable axisIndex=AxisIndexForWhichAxisAndNum(whichAxis, whichNum)
		String cmd
		sprintf cmd "ModifyGizmo/N=%s ModifyObject=%s,property={%d,numTicks,%d}", gizmoName, axisObjectName, axisIndex, ai.numTicks
		EchoExecute(cmd, slashZ=1)
		UpdateAxisInfo(whichAxis, whichNum, ai)
	endif
End

Static Function GizmoInfoButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String oldDF= SetPanelDF()
	Execute/Z "ModifyGizmo showInfo"
	SetDataFolder oldDF
End

Static Function HelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String oldDF= SetPanelDF()
	DisplayHelpTopic/K=1 "Gizmo Box Axes"
	SetDataFolder oldDF
End

// works on the selected axis
Static Function TickLabelSliderProc(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved

	Variable mouseUp= event & 0x4	 // mouse up (for command echo)
	Variable mouseMoved= event & 0x8	 // mouse up (for command echo)

	if( mouseUp || mouseMoved )
		String whichAxis
		Variable whichNum
		STRUCT CC_AxisInfo ai
		String axisObjectName, gizmoName
		if( GetSelectedAxisInfo(whichAxis, whichNum, ai, axisObjectName, gizmoName) )
			ai.labelRotationAngle= round(sliderValue)	// degrees
			Variable axisIndex=AxisIndexForWhichAxisAndNum(whichAxis, whichNum)
			String cmd
			sprintf cmd "ModifyGizmo/N=%s ModifyObject=%s,property={%d,labelRotationAxis,%g, %g, %g}", gizmoName, axisObjectName, axisIndex, ai.rotateAroundX, ai.rotateAroundY, ai.rotateAroundZ
			String oldDF= SetPanelDF()
			if( mouseUp )
				EchoExecute(cmd, slashZ=1)
			else
				Execute/Q/Z cmd
			endif
			sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={%d,labelRotationAngle,%d}", gizmoName, axisObjectName, axisIndex, ai.labelRotationAngle
			if( mouseUp )
				EchoExecute(cmd, slashZ=1)
			else
				Execute/Q/Z cmd
			endif
			SetDataFolder oldDF
			UpdateAxisInfo(whichAxis, whichNum, ai)
		endif
	endif

	return 0
End

Static Function DefaultLabelRotationButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo/W=GizmoBoxAxes axesPop
	String axisObjectName= S_Value
	if( NameIsInGizmoObjectList("",axisObjectName) )
		String cmd
		
		sprintf cmd "ModifyGizmo ModifyObject=%s,property={-1,labelRotationAxis,0,0,0}", axisObjectName
		EchoExecute(cmd, slashZ=1)
		
		sprintf cmd "ModifyGizmo ModifyObject=%s,property={-1,labelRotationAngle,0}", axisObjectName
		EchoExecute(cmd, slashZ=1)
		
		sprintf cmd "ModifyGizmo ModifyObject=%s,property={-1,labelOffset,0,0,0}", axisObjectName
		EchoExecute(cmd, slashZ=1)
		
		String oldDF= SetPanelDF()
		Execute/Q/Z "ModifyGizmo compile"	// not interesting enough to print to history
		SetDataFolder oldDF
		
		// put default rotation axis into selected axis
		
		String whichAxis
		Variable whichNum
		STRUCT CC_AxisInfo ai
		String gizmoName
		if( GetSelectedAxisInfo(whichAxis, whichNum, ai, axisObjectName, gizmoName) )
			Variable axisIndex=AxisIndexForWhichAxisAndNum(whichAxis, whichNum)
			sprintf cmd "ModifyGizmo/N=%s ModifyObject=%s,property={%d,labelRotationAxis,0, 1, 0}", gizmoName, axisObjectName, axisIndex	// rotate around y (z world axis)
			EchoExecute(cmd, slashZ=1)
		endif

		UpdateGizmoBoxAxesPanel()
	endif
End

Static Function RotateAboutRadioProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	String/G $PanelDFVar("rotateAround")= ctrlName
	
	Variable isX=CmpStr(ctrlName,"rotateAroundX") == 0
	Variable isY=CmpStr(ctrlName,"rotateAroundY") == 0
	Variable isZ=CmpStr(ctrlName,"rotateAroundZ") == 0

	Checkbox rotateAroundX win=GizmoBoxAxes, value=isX
	Checkbox rotateAroundY win=GizmoBoxAxes, value=isY
	Checkbox rotateAroundZ win=GizmoBoxAxes, value=isZ
	
	String whichAxis
	Variable whichNum
	STRUCT CC_AxisInfo ai
	String axisObjectName, gizmoName
	if( GetSelectedAxisInfo(whichAxis, whichNum, ai, axisObjectName, gizmoName) )
		ai.rotateAroundX= isX
		ai.rotateAroundY= isY
		ai.rotateAroundZ= isZ		
		Variable axisIndex=AxisIndexForWhichAxisAndNum(whichAxis, whichNum)
		String cmd
		sprintf cmd "ModifyGizmo/N=%s ModifyObject=%s,property={%d,labelRotationAxis,%g, %g, %g}", gizmoName, axisObjectName, axisIndex, ai.rotateAroundX, ai.rotateAroundY, ai.rotateAroundZ
		EchoExecute(cmd, slashZ=1)
		UpdateAxisInfo(whichAxis, whichNum, ai)
	endif
End

#if 0
	// INSERTINCLUDE doesn't work when Gizmo Box Axes is included into an Independent module
	// Must use #include, instead.
Static Function AxisLabelsButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String gizmoName= TopGizmo()
	ControlInfo/W=GizmoBoxAxes axesPop
	String boxAxesName= S_Value

	Execute/P/Q/Z "INSERTINCLUDE <GizmoAxisLabels>"
	Execute/P/Q/Z "COMPILEPROCEDURES "

	// check for old axis labels
	String im=GetIndependentModuleName()
	String cmd
	sprintf cmd, "Variable/G %s=%s#CheckForOldGizmoAxisLabels(\"%s\",\"%s\")", im,PanelDFVar("oldAxisLabelApproval"), gizmoName,boxAxesName
	Execute/P/Q/Z cmd
	
	// Then call the correct axis panel code
	sprintf cmd, "%s#GizmoBoxAxes#CallCorrectAxisLabelPanel(%s,\"%s\",\"%s\")", im,PanelDFVar("oldAxisLabelApproval"), gizmoName,boxAxesName
	Execute/P/Q/Z cmd
End

// call this after GizmoAxisLabels has been loaded and compiled (via Execute/P)
static Function CallCorrectAxisLabelPanel(code, gizmoName,boxAxesName)
	Variable code	// return code from CheckForOldGizmoAxisLabels(gizmoName,boxAxesName)
	String gizmoName,boxAxesName

	String im=GetIndependentModuleName()+"#"
	// CheckForOldGizmoAxisLabels() returns:
	// 0 - no old axis labels existed
	// 1 - old axis labels have been converted
	// 2 - old axis labels remain: use the old panel code instead.
	if( code == 2 )	// 2 - old axis labels remain: use the old panel code instead.
		Execute/P/Q/Z "INSERTINCLUDE <GizmoLabels>"
		Execute/P/Q/Z "COMPILEPROCEDURES "
		Execute/P/Q/Z im+"WMMakeLabelsPanel()"
	else
		Execute/P/Q/Z im+"WMMakeAxisLabelsPanel(\""+ boxAxesName+"\")"
	endif
End

#else

Static Function AxisLabelsButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String gizmoName= TopGizmo()
	ControlInfo/W=GizmoBoxAxes axesPop
	String boxAxesName= S_Value

	// check for old axis labels
	Variable code=CheckForOldGizmoAxisLabels(gizmoName,boxAxesName)

	if( code == 2 )	// 2 - old axis labels remain: use the old panel code instead.
		WMMakeLabelsPanel()
	else
		WMMakeAxisLabelsPanel(boxAxesName)
	endif
End
#endif


Static Function AppendBoxAxesButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String gizmoName= TopGizmo()
	String objectName= UniqueBoxAxesName(gizmoName)

	String cmd
	sprintf cmd, "ModifyGizmo/N=%s startRecMacro", gizmoName
	EchoExecute(cmd)

	// AppendToGizmo Axes=boxAxes,name=axes1
	sprintf cmd, "AppendToGizmo/N=%s Axes=boxAxes,name=%s", gizmoName, objectName
	EchoExecute(cmd)
	
	// ModifyGizmo ModifyObject=axes1,property={0,axisRange,-1,-1,-1,1,-1,-1}
	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={0,axisRange,-1,-1,-1,1,-1,-1}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={1,axisRange,-1,-1,-1,-1,1,-1}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={2,axisRange,-1,-1,-1,-1,-1,1}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={3,axisRange,-1,1,-1,-1,1,1}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={4,axisRange,1,1,-1,1,1,1}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={5,axisRange,1,-1,-1,1,-1,1}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={6,axisRange,-1,-1,1,-1,1,1}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={7,axisRange,1,-1,1,1,1,1}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={8,axisRange,1,-1,-1,1,1,-1}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={9,axisRange,-1,1,-1,1,1,-1}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={10,axisRange,-1,1,1,1,1,1}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={11,axisRange,-1,-1,1,1,-1,1}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={0,axisType,4194305}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={1,axisType,4194306}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={2,axisType,4194308}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={3,axisType,4194312}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={4,axisType,4194320}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={5,axisType,4194336}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={6,axisType,4194368}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={7,axisType,4194432}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={8,axisType,4194560}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={9,axisType,4194816}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={10,axisType,4195328}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={11,axisType,4196352}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={-1,axisScalingMode,1}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s ModifyObject=%s,property={-1,axisColor,0,0,0,1}", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s setDisplayList=-1, object=%s", gizmoName, objectName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s compile", gizmoName
	EchoExecute(cmd)

	sprintf cmd, "ModifyGizmo/N=%s endRecMacro", gizmoName
	EchoExecute(cmd)
	
	String/G $PanelDFVar("boxAxesName")=objectName
	
	UpdateGizmoBoxAxesPanel()
End


Static Function/S UniqueBoxAxesName(gizmoName)
	String gizmoName

	String axes= GizmoBoxAxesList(gizmoName)
	Variable suffix= 0
	do
		String axesName
		sprintf axesName, "axes%d",suffix
		Variable offset= FindListItem(axesName, axes)
		if( offset < 0 )	// unique?
			return axesName	// yep
		endif
		suffix += 1
	while(suffix <= 99)

	return ""	// error
End

Static Function RemoveAxesButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	ControlInfo/W=GizmoBoxAxes axesPop
	String name= S_Value
	String gizmoName= TopGizmo() 

	String cmd
	sprintf cmd, "RemoveFromGizmo/Z/N=%s object=%s", gizmoName,name
	EchoExecute(cmd, slashZ=1)
	
	sprintf cmd, "ModifyGizmo/N=%s compile", gizmoName
	EchoExecute(cmd, slashZ=1)

	STRUCT CC_CubeInfo cubeInfo
	InitCubeInfo(cubeInfo)
	SetCubeInfo(cubeInfo)

	String/G $PanelDFVar("whichSelectedAxis")= ""
	Variable/G $PanelDFVar("whichSelectedNum")= NaN

	UpdateGizmoBoxAxesPanel()
End

Static Function BoxAxesInfoButtonProc(ctrlName) : ButtonControl
	String ctrlName

	ControlInfo/W=GizmoBoxAxes axesPop
	String boxAxesName= S_Value
	if( CmpStr(boxAxesName,"_none_") == 0 )
		return 0
	endif

	String oldDF= SetPanelDF()
	String cmd
	// ModifyGizmo edit={objTypeName,objName}
	sprintf cmd, "ModifyGizmo edit={Object,%s}", boxAxesName
	Execute/Z/Q cmd
	SetDataFolder oldDF
End

Static Function OffsetRadioProc(ctrlName,checked) : CheckBoxControl
	String ctrlName	
	Variable checked

	String/G $PanelDFVar("offsetDirection")= ctrlName	// one of "offsetForwardBack", "offsetLeftRight", "offsetUpDown", this is panel-specific, not axis specific
	
	Variable offsetForwardBack=CmpStr(ctrlName,"offsetForwardBack") == 0
	Variable offsetLeftRight=CmpStr(ctrlName,"offsetLeftRight") == 0
	Variable offsetUpDown=CmpStr(ctrlName,"offsetUpDown") == 0

	Checkbox offsetForwardBack win=GizmoBoxAxes, value=offsetForwardBack
	Checkbox offsetLeftRight win=GizmoBoxAxes, value=offsetLeftRight
	Checkbox offsetUpDown win=GizmoBoxAxes, value=offsetUpDown
	
	String whichAxis
	Variable whichNum
	STRUCT CC_AxisInfo ai
	String axisObjectName, gizmoName
	if( GetSelectedAxisInfo(whichAxis, whichNum, ai, axisObjectName, gizmoName) )
		Variable sliderValue
		if( offsetForwardBack )
			sliderValue= ai.labelOffsetZ
		elseif(offsetLeftRight )
			sliderValue= ai.labelOffsetX
		else	// offsetUpDown
			sliderValue= ai.labelOffsetY
		endif
	endif
	Slider labelOffset, win=GizmoBoxAxes, value=sliderValue
End

Static Function TickLabelOffsetSliderProc(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved

	Variable mouseUp= event & 0x4	 // mouse up (for command echo)
	Variable mouseMoved= event & 0x8	 // mouse up (for command echo)

	if( mouseUp || mouseMoved )
		String whichAxis
		Variable whichNum
		STRUCT CC_AxisInfo ai
		String axisObjectName, gizmoName
		if( GetSelectedAxisInfo(whichAxis, whichNum, ai, axisObjectName, gizmoName) )
			String offsetDirection= StrVarOrDefault(PanelDFVar("offsetDirection"), "offsetLeftRight")
			strswitch(offsetDirection)
				case "offsetForwardBack":
					ai.labelOffsetZ= sliderValue
				break
				default:
				case "offsetLeftRight":
					ai.labelOffsetX= sliderValue
					break
				case "offsetUpDown":
					ai.labelOffsetY= sliderValue
					break
			endswitch
			Variable axisIndex=AxisIndexForWhichAxisAndNum(whichAxis, whichNum)
			String oldDF= SetPanelDF()
			String cmd
			sprintf cmd "ModifyGizmo/N=%s ModifyObject=%s,property={%d,labelOffset,%g, %g, %g}", gizmoName, axisObjectName, axisIndex, ai.labelOffsetX, ai.labelOffsetY, ai.labelOffsetZ
			if( mouseUp )
				EchoExecute(cmd, slashZ=1)
			else
				Execute/Q/Z cmd
			endif
			SetDataFolder oldDF
			UpdateAxisInfo(whichAxis, whichNum, ai)
		endif
	endif

	return 0
End

Static Function AutoscaleButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String whichAxis
	Variable whichNum
	STRUCT CC_AxisInfo ai
	String axisObjectName, gizmoName
	Variable axisMin, axisMax
	String cmd

	strswitch(ctrlName)
		case "autoScaleXYZ":
			EchoExecute("ModifyGizmo autoscale", slashZ=1)
			break
		case "autoscaleAxis":
			// autoscale only one axis.
			if( GetSelectedAxisInfo(whichAxis, whichNum, ai, axisObjectName, gizmoName) )
				AutoscaleGizmoAxisRange(gizmoName,whichAxis,axisMin,axisMax)
				SetGizmoAxisRange(gizmoName,whichAxis,axisMin,axisMax)
			endif
			break
		case "fivePercentAxis":
			// autoscale only one axis.
			if( GetSelectedAxisInfo(whichAxis, whichNum, ai, axisObjectName, gizmoName) )
				GetGizmoAxisRange(gizmoName,whichAxis,axisMin,axisMax)
				Variable fivePercentRange= 0.05*(axisMax-axisMin)
				SetGizmoAxisRange(gizmoName,whichAxis,axisMin-fivePercentRange,axisMax+fivePercentRange)
			endif
			break
	endswitch
	UpdateGizmoBoxAxesPanel()
End

static Function AxisRangeSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	String whichAxis
	Variable whichNum
	STRUCT CC_AxisInfo ai
	String axisObjectName, gizmoName
	if( GetSelectedAxisInfo(whichAxis, whichNum, ai, axisObjectName, gizmoName) )
		ControlInfo/W=GizmoBoxAxes axisMin
		Variable axisMin=V_Value
		ControlInfo/W=GizmoBoxAxes axisMax
		Variable axisMax=V_Value
		SetGizmoAxisRange(gizmoName,whichAxis,axisMin,axisMax)
		//UpdateGizmoBoxAxesPanel()
	endif
End

Static Function TickLenSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	String whichAxis
	Variable whichNum
	STRUCT CC_AxisInfo ai
	String axisObjectName, gizmoName
	if( GetSelectedAxisInfo(whichAxis, whichNum, ai, axisObjectName, gizmoName) )
		ai.tickLen= varNum
		Variable axisIndex=AxisIndexForWhichAxisAndNum(whichAxis, whichNum)
		String cmd
		sprintf cmd "ModifyGizmo/N=%s ModifyObject=%s,property={%d,tickScaling,%g}", gizmoName, axisObjectName, axisIndex, ai.tickLen
		EchoExecute(cmd, slashZ=1)
		UpdateAxisInfo(whichAxis, whichNum, ai)
	endif
End
