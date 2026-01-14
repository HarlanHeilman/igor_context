#pragma rtGlobals=3		// Use modern global access method.
#pragma version=8.04		// Shipped with Igor 8.04
#pragma IgorVersion=7   // for COLORMODE=6
#pragma IndependentModule=WMColorTableControlPanel

#include <Resize Controls>
#include <Graph Utility Procs> // for WMGetRECREATIONFromInfo

// Version 6.30:	Nate Hyde, WaveMetrics, Inc.
// Version 8.03:	Jim Prouty, WaveMetrics, Inc.
//						Added support for color table waves, contour fill colors, and graph subwindows. Added a Modify... button and a Sliders update immediately checkbox.
// Version 8.04:	Jim Prouty, WaveMetrics, Inc.
//						Multiple images with the same wave name displayed in one graph no longer causes adjustments to be applied to only the first image.
//						Added display of data folder for target wave (trace, contour, or image data wave).


///////// some constants /////////
static constant kHeight = 523
static constant kWidth = 430

static constant cZInfoGraphObjectMissing = 0x1      //// set if the primary graph object is missing
static constant cZInfoCIndexWaveMissing = 0x2       //// set if the color index wave is missing   
static constant cZInfoCIndexHighEqLow = 0x4         //// the color index wave will get set to point scaling if you try to use SetScale with highValue == lowValue
static constant cZInfoIsCIndex = 0x8                //// set if an image uses a color index wave
static constant cZInfoIsColorTableWave = 0x10       //// set if an image uses a color table wave
static constant cZInfoColorTableWaveMissing = 0x20  //// set if the color table wave is missing   

Menu "Graph"
	"Color Table Control", /Q, createColorTableControlPanel()
End

//// execute WMColorTableControlPanel#createColorTableControlPanel()
//// createColorTableControlPanel will either create or move the current Color Table Control Panel,
//// then update it to the current traces.
//// If there is any information on the traces in the package the panel controls will be updated
Function createColorTableControlPanel()

	DFREF colorTablePackageDFR = GetColorTableControlPanelDFR()
	InitColorTableControlPanel(colorTablePackageDFR)
	
	// Get the top graph
	DFREF colorTablePackageDFR = GetColorTableControlPanelDFR()
	String /G colorTablePackageDFR:topGraphName
	SVAR graphName = colorTablePackageDFR:topGraphName
	graphName = ActiveGraph()
	
	DoWindow/F ColorTableControlPanel
	if (V_flag == 0)		// i.e. the panel doesn't already exist
		PauseUpdate; Silent 1		// building window...
		
		NVAR panelHeight = colorTablePackageDFR:PanelHeight 
		NVAR panelWidth = colorTablePackageDFR:PanelWidth 
		Variable initialSliderHeight = panelHeight-296 
		NVAR xLocation = colorTablePackageDFR:xLocation 
		NVAR yLocation = colorTablePackageDFR:yLocation 
		
		NewPanel /K=1 /W=(xLocation, yLocation, xLocation+panelWidth, yLocation+panelHeight) /N=ColorTableControlPanel as "Color Table Control"
	
		Button helpButton,  win=ColorTableControlPanel,  pos={9,7}, size={70,20}, fsize=12, fstyle=1, title="Help", proc=Help
		SetVariable currGraph, win=ColorTableControlPanel,pos={100,9},size={panelWidth-110,20},title="Current Graph:", fsize=12, fstyle=1, frame=0, noedit= 1, variable=colorTablePackageDFR:topGraphName
	
		PopupMenu selectTracePU, win=ColorTableControlPanel,pos={15,32},size={167,20},title="Target"
		PopupMenu selectTracePU, win=ColorTableControlPanel,fSize=12,mode=1,proc=SelectTraceProc			

		Button modify win=ColorTableControlPanel,pos={345,31}, size={70,20}, title="Modify...", proc=ModifyTarget

		PopupMenu selectColorTablePU, win=ColorTableControlPanel,pos={17,83},size={268,23},title="Color Table",value=#"\"*COLORTABLEPOP*\"" 
		PopupMenu selectColorTablePU, win=ColorTableControlPanel,fSize=12,mode=0,proc=SelectColorTableProc

// If the panel doesn't have the dataFolder control, kill and recreate it.
		TitleBox targetDF, win=ColorTableControlPanel,pos={15,60},size={95,15},title="Target Wave DF:", fsize=12, frame=0, disable=1, fcolor=(2,39321,1) // dark green

		// cIndexInUse is also used to announce color table waves (non-indexed color waves)
		TitleBox cIndexInUse, win=ColorTableControlPanel,pos={15,86},size={panelWidth-30,20},title="Color Index Wave", fsize=12, frame=0, disable=1, fcolor=(0, 0, 65535) // blue
	
		GroupBox statusGroup, win=ColorTableControlPanel, pos={5,106},size={panelWidth-10,36}		
		TitleBox statusText, win=ColorTableControlPanel, pos={15,108},size={panelWidth-30,30}, fsize=11, title=" ", frame=0, anchor=MT, fcolor=(65535, 0, 0)	// red	

		TitleBox slidersTitle, win=ColorTableControlPanel, pos={127,144}, size={177, 17}, fsize=14, fstyle=1, title="Modify Color Table Range", frame=0, anchor=MC
			
		Slider highSliderSC, win=ColorTableControlPanel, pos={160,167},size={60,initialSliderHeight},fSize=10,limits={0,1,0.01},value=1, proc=SliderProc
		Slider lowSliderSC, win=ColorTableControlPanel, pos={20,167},size={60,initialSliderHeight},fSize=10,limits={0,1,0.01},value=0, proc=SliderProc
		SetVariable slidersHighSV, win=ColorTableControlPanel, pos={160, 175+initialSliderHeight}, size={120, 15}, fsize=12, title="Last", proc=setVarProc, bodyWidth=100, limits={-inf,inf,0}
		SetVariable slidersLowSV, win=ColorTableControlPanel, pos={20, 175+initialSliderHeight}, size={120, 15}, fsize=12, title="First", proc=setVarProc, bodyWidth=100, limits={-inf,inf,0}

		Variable center= 175+initialSliderHeight/2
		TitleBox slidersLimitsTitle, win=ColorTableControlPanel, pos={291,center-115}, size={100, 20}, fsize=12, fstyle=1, title="Set Slider Limits", frame=0, anchor=MC
		GroupBox sliderGroup, win=ColorTableControlPanel, pos={270,center-95}, size={143, 80}
		SetVariable maxSetSliderSV, win=ColorTableControlPanel, pos={280,center-85}, size={123, 20}, fsize=12, title="Max", proc=sliderLimitsSetVarProc, limits={-inf,inf,0}
		SetVariable minSetSliderSV, win=ColorTableControlPanel, pos={283,center-65}, size={120, 20}, fsize=12, title="Min", proc=sliderLimitsSetVarProc, limits={-inf,inf,0}
		Button autoCalcButton, win=ColorTableControlPanel, pos={309, center-45}, size={90, 20}, fsize=12, fstyle=1, title="Auto Calc", proc=sliderLimitsAutoCalc

		CheckBox live,win=ColorTableControlPanel,pos={246.00,center+45},size={182.00,16.00},proc=LiveCheckProc,title="Sliders update Immediately"
		CheckBox live,win=ColorTableControlPanel,fSize=12,fStyle=1, variable=colorTablePackageDFR:WMLiveSlider

		Checkbox holdAtEndsCheck, win=ColorTableControlPanel, pos={30, panelHeight-97}, size={70, 20}, fsize=12, fstyle=1;
		Checkbox holdAtEndsCheck, win=ColorTableControlPanel, title="Hold Last-First Difference", variable=colorTablePackageDFR:WMHoldAtEnds

		Checkbox reverseTableCheck, win=ColorTableControlPanel, pos={panelWidth/2+30, panelHeight-97}, size={70, 20}, fsize=12, fstyle=1; DelayUpdate
		Checkbox reverseTableCheck, win=ColorTableControlPanel, title="Reverse Color Table", proc=reverseColorTableProc//, variable=colorTablePackageDFR:WMReverseColorTable

		GroupBox presetsGroup,pos={5,panelHeight-75},size={panelWidth-10,70}			
		TitleBox presetsLabel, win=ColorTableControlPanel, pos={15, panelHeight-70}, size={80, 15}, fsize=12, fstyle=1, title="Set and Load color table preset:", frame=0
		Button savePreset, win=ColorTableControlPanel, pos={15, panelHeight-47}, size={90, 20}, fsize=12, fstyle=1, title="Save Current", proc=SavePreset
		Button applyPreset, win=ColorTableControlPanel, pos={panelWidth/2-45, panelHeight-47}, size={90, 20}, fsize=12, fstyle=1, title="Apply", proc=ApplyPreset
		Button applyAllPreset, win=ColorTableControlPanel, pos={panelWidth-105, panelHeight-47}, size={90, 20}, fsize=12, fstyle=1, title="Apply to All", proc=ApplyPreset

		NVAR /Z highSliderPreset = colorTablePackageDFR:WMHighSliderPreset 
		NVAR /Z lowSliderPreset = colorTablePackageDFR:WMLowSliderPreset
		SVAR /Z colorTablePreset = colorTablePackageDFR:WMColorTablePreset 	
		if (!NVAR_exists(highSliderPreset) || !NVAR_exists(lowSliderPreset) || !SVAR_exists(colorTablePreset))
			InitColorTableControlPanel(colorTablePackageDFR)
			NVAR highSliderPreset = colorTablePackageDFR:WMHighSliderPreset 
			NVAR lowSliderPreset = colorTablePackageDFR:WMLowSliderPreset
			SVAR colorTablePreset = colorTablePackageDFR:WMColorTablePreset 
		endif
		SetVariable currentPresetSettings, win=ColorTableControlPanel, pos={20, panelHeight-25}, size={panelWidth-40, 20}, fsize=11, title="\f01Current Preset: "; DelayUpdate
		SetVariable currentPresetSettings, win=ColorTableControlPanel, frame=0, noedit=1
		String presetSettings
		if (numtype(highSliderPreset) != 2 && numtype(lowSliderPreset)!=2 && strlen(colorTablePreset)!=0 && CmpStr(colorTablePreset, "_none_"))
			sprintf presetSettings, "{%.2e, %.2e, %s}", lowSliderPreset, highSliderPreset, colorTablePreset
			SetVariable currentPresetSettings, win=ColorTableControlPanel, value=_STR:presetSettings
		else
			SetVariable currentPresetSettings, win=ColorTableControlPanel, value=_STR:"No Saved Preset"
		endif

		Button helpButton,win=ColorTableControlPanel,userdata(ResizeControlsInfo)= A"!!,@s!!#:B!!#?E!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		Button helpButton,win=ColorTableControlPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		Button helpButton,win=ColorTableControlPanel,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

		SetVariable currGraph,userdata(ResizeControlsInfo)= A"!!,F-!!#:r!!#BZ!!#<Hz!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
		SetVariable currGraph,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		SetVariable currGraph,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

		PopupMenu selectTracePU,userdata(ResizeControlsInfo)= A"!!,B)!!#=c!!#A1!!#<pz!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
		PopupMenu selectTracePU,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		PopupMenu selectTracePU,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

		TitleBox targetDF,userdata(ResizeControlsInfo)= A"!!,B)!!#?)!!#@\"!!#<(z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		TitleBox targetDF,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Duafnzzzzzzzzzzz"
		TitleBox targetDF,userdata(ResizeControlsInfo) += A"zzz!!#u:Duafnzzzzzzzzzzzzzz!!!"

		Button modify,win=ColorTableControlPanel,userdata(ResizeControlsInfo)= A"!!,HgJ,hn1!!#?E!!#<Xz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
		Button modify,win=ColorTableControlPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Duafnzzzzzzzzzzz"
		Button modify,win=ColorTableControlPanel,userdata(ResizeControlsInfo) += A"zzz!!#u:Duafnzzzzzzzzzzzzzz!!!"

		PopupMenu selectColorTablePU,userdata(ResizeControlsInfo)= A"!!,BA!!#?_!!#B@!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
		PopupMenu selectColorTablePU,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		PopupMenu selectColorTablePU,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
		PopupMenu selectColorTablePU,win=ColorTableControlPanel,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

		TitleBox cIndexInUse,userdata(ResizeControlsInfo)= A"!!,B)!!#?e!!#B=!!#<(z!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
		TitleBox cIndexInUse,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		TitleBox cIndexInUse,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

		TitleBox slidersTitle,userdata(ResizeControlsInfo)= A"!!,Fc!!#@t!!#A@!!#<@z!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
		TitleBox slidersTitle,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		TitleBox slidersTitle,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

		GroupBox statusGroup,userdata(ResizeControlsInfo)= A"!!,?X!!#@8!!#C<J,hnIz!!#](Aon#azzzzzzzzzzzzzz!!#o2B4uAezz"
		GroupBox statusGroup,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		GroupBox statusGroup,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

		TitleBox statusText,userdata(ResizeControlsInfo)= A"!!,B)!!#@<!!#66!!#66z!!#](Aon#azzzzzzzzzzzzzz!!#o2B4uAezz"
		TitleBox statusText,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		TitleBox statusText,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

		Slider highSliderSC,userdata(ResizeControlsInfo)= A"!!,G0!!#A6!!#@B!!#Aoz!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
		Slider highSliderSC,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		Slider highSliderSC,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

		Slider lowSliderSC,userdata(ResizeControlsInfo)= A"!!,BY!!#A6!!#@B!!#Aoz!!#](Aon#azzzzzzzzzzzzzz!!#](Aon#azz"
		Slider lowSliderSC,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
		Slider lowSliderSC,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

		SetVariable slidersHighSV,userdata(ResizeControlsInfo)= A"!!,G(!!#C,J,hq:!!#<Hz!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
		SetVariable slidersHighSV,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
		SetVariable slidersHighSV,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

		SetVariable slidersLowSV,userdata(ResizeControlsInfo)= A"!!,A>!!#C,J,hq;!!#<Hz!!#](Aon#azzzzzzzzzzzzzz!!#](Aon#azz"
		SetVariable slidersLowSV,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
		SetVariable slidersLowSV,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

		TitleBox slidersLimitsTitle,userdata(ResizeControlsInfo)= A"!!,HM!!#AD!!#@*!!#<(z!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
		TitleBox slidersLimitsTitle,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#AtDKKH1zzzzzzzzzzz"
		TitleBox slidersLimitsTitle,userdata(ResizeControlsInfo) += A"zzz!!#AtDKKH1zzzzzzzzzzzzzz!!!"

		GroupBox sliderGroup,userdata(ResizeControlsInfo)= A"!!,HB!!#AU!!#@s!!#?Yz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
		GroupBox sliderGroup,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#AtDKKH1zzzzzzzzzzz"
		GroupBox sliderGroup,userdata(ResizeControlsInfo) += A"zzz!!#AtDKKH1zzzzzzzzzzzzzz!!!"

		SetVariable maxSetSliderSV,userdata(ResizeControlsInfo)= A"!!,HG!!#A_!!#@Z!!#<Hz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
		SetVariable maxSetSliderSV,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#AtDKKH1zzzzzzzzzzz"
		SetVariable maxSetSliderSV,userdata(ResizeControlsInfo) += A"zzz!!#AtDKKH1zzzzzzzzzzzzzz!!!"

		SetVariable minSetSliderSV,userdata(ResizeControlsInfo)= A"!!,HHJ,hrI!!#@T!!#<Hz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
		SetVariable minSetSliderSV,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#AtDKKH1zzzzzzzzzzz"
		SetVariable minSetSliderSV,userdata(ResizeControlsInfo) += A"zzz!!#AtDKKH1zzzzzzzzzzzzzz!!!"

		Button autoCalcButton,userdata(ResizeControlsInfo)= A"!!,HUJ,hr]!!#?m!!#<Xz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
		Button autoCalcButton,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#AtDKKH1zzzzzzzzzzz"
		Button autoCalcButton,userdata(ResizeControlsInfo) += A"zzz!!#AtDKKH1zzzzzzzzzzzzzz!!!"

		CheckBox live,userdata(ResizeControlsInfo)= A"!!,H1!!#B`!!#AE!!#<8z!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
		CheckBox live,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#AtDKKH1zzzzzzzzzzz"
		CheckBox live,userdata(ResizeControlsInfo) += A"zzz!!#AtDKKH1zzzzzzzzzzzzzz!!!"

		CheckBox holdAtEndsCheck,userdata(ResizeControlsInfo)= A"!!,CT!!#C8J,hqh!!#<8z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		CheckBox holdAtEndsCheck,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
		CheckBox holdAtEndsCheck,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

		CheckBox reverseTableCheck,userdata(ResizeControlsInfo)= A"!!,H5!!#C8J,hqD!!#<8z!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
		CheckBox reverseTableCheck,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
		CheckBox reverseTableCheck,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

		GroupBox presetsGroup,userdata(ResizeControlsInfo)= A"!!,?X!!#CCJ,hsgJ,hopz!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
		GroupBox presetsGroup,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
		GroupBox presetsGroup,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

		TitleBox presetsLabel,userdata(ResizeControlsInfo)= A"!!,B)!!#CF!!#AO!!#<(z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		TitleBox presetsLabel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
		TitleBox presetsLabel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

		Button savePreset,userdata(ResizeControlsInfo)= A"!!,B)!!#CQJ,hpC!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
		Button savePreset,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
		Button savePreset,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

		Button applyPreset,userdata(ResizeControlsInfo)= A"!!,G?!!#CQJ,hpC!!#<Xz!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
		Button applyPreset,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
		Button applyPreset,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

		Button applyAllPreset,userdata(ResizeControlsInfo)= A"!!,Hc!!#CQJ,hpC!!#<Xz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
		Button applyAllPreset,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
		Button applyAllPreset,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

		SetVariable currentPresetSettings,userdata(ResizeControlsInfo)= A"!!,BY!!#C\\J,hsXJ,hlkz!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
		SetVariable currentPresetSettings,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
		SetVariable currentPresetSettings,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

		SetWindow ColorTableControlPanel,userdata(ResizeControlsInfo)= A"!!*'\"z!!#CB!!#Cg^]4?7zzzzzzzzzzzzzzzzzzzz"
		SetWindow ColorTableControlPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzzzzzzzz"
		SetWindow ColorTableControlPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzz!!!"
		
		SetWindow ColorTableControlPanel, hook(ResizeControls)=ResizeControls#ResizeControlsHook
		SetWindow ColorTableControlPanel, hook(panelHook)=WinHook   //// The local hook function needs to be called before the ResizeControls#ResizeControlsHook.  Declaring it second ensures it is called first.

	endif
	
	String host=ActiveGraphHost()
	if( strlen(host) )
		AutoPositionWindow/E/R=$host ColorTableControlPanel
	endif

	UpdateControlPanel()
End

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////// Update Functions //////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

//// UpdateControlPanel ////
//// - populate the graph objects list
//// - set the current object to the first object in the list (could save selected object for each graph in the package data - possible TODO)
//// - set the color table to be the color table of the current object
//// - set all other controls to reflect the condition of the current object
//// - if there's no z colored objects on the top graph disable the controls.
Function UpdateControlPanel()
	DFREF colorTablePackageDFR = GetColorTableControlPanelDFR()
	String /G colorTablePackageDFR:topGraphName
	SVAR topGraphName = colorTablePackageDFR:topGraphName
	topGraphName = ActiveGraph() // can be active graph subwindow

	String traceNames = getZColoredObjectsFromTopWin(topGraphName)
	
	String cmd = GetIndependentModuleName()+"#getZColoredObjectsFromTopWin(\"" + topGraphName + "\")"
	PopupMenu selectTracePU win=ColorTableControlPanel, value=#cmd
	
	String ctrls= "modify;selectTracePU;selectColorTablePU;highSliderSC;lowSliderSC;live;holdAtEndsCheck;reverseTableCheck;"
	ctrls += "slidersHighSV;slidersLowSV;slidersTitle;presetsLabel;savePreset;applyPreset;applyAllPreset;currentPresetSettings;"
	ctrls += "autoCalcButton;maxSetSliderSV;minSetSliderSV;"
	ctrls += "targetDF;" // 8.04
	
	if (CmpStr(traceNames, "_none_"))   /// CmpStr returns 0 if it matches, so this checks that the trace name is not "_none_"
		ControlInfo /W=ColorTableControlPanel selectTracePU
		
		String currObject=S_Value
		if (FindListItem(S_Value, traceNames) < 0) //StringFromList(0, traceNames)
			currObject = StringFromList(0, traceNames)
			PopupMenu selectTracePU, win=ColorTableControlPanel, mode=1
		endif
		
		if (strlen(currObject))		/// there's at least one graph object 
			ModifyControlList/Z ctrls, win=ColorTableControlPanel, disable=0
		
			Struct zInfoStruct zInfo
			getZInfoFromObject(topGraphName, currObject, zInfo)
			
			if (zInfo.flags & cZInfoIsCIndex)
				PopupMenu selectColorTablePU, win=ColorTableControlPanel, disable=1
				TitleBox cIndexInUse, win=ColorTableControlPanel, title="Color Index Wave: "+zInfo.colorTable, disable=0
				TitleBox slidersTitle, win=ColorTableControlPanel, title="Modify Color Index Wave Scaling"
			elseif( zInfo.flags & cZInfoIsColorTableWave )
				PopupMenu selectColorTablePU, win=ColorTableControlPanel, disable=1
				TitleBox cIndexInUse, win=ColorTableControlPanel, title="Color Table Wave: "+zInfo.colorTable, disable=0
				TitleBox slidersTitle, win=ColorTableControlPanel, title="Modify Color Table Range"
			else
				PopupMenu selectColorTablePU, win=ColorTableControlPanel, disable=0		
				TitleBox cIndexInUse, win=ColorTableControlPanel, disable=1	 // hide
				TitleBox slidersTitle, win=ColorTableControlPanel, title="Modify Color Table Range"
			endif
			
			Wave /Z zWave = $(zInfo.zWaveDataFolder + zInfo.zWaveName)
			if (!waveExists(zWave))
				zInfo.flags = zInfo.flags | cZInfoGraphObjectMissing
				TitleBox targetDF, win=ColorTableControlPanel, title="(target wave missing)"
			else
				TitleBox targetDF, win=ColorTableControlPanel, title="Target Wave DF: "+zInfo.zWaveDataFolder
			endif
			
			Variable zMax=waveMax(zWave), zMin=waveMin(zWave)
	
			if (!(zInfo.flags & (cZInfoIsCIndex|cZInfoIsColorTableWave)))
				PopupMenu selectColorTablePU, win=ColorTableControlPanel, mode=WhichListItem(zInfo.colorTable, CTabList(), ";", 0, 0)+1
			endif
			
			/////// update the panel values ///////
			controlInfo /W=ColorTableControlPanel highSliderSC
			Variable sliderIncrement = V_Height*2
		
			DFREF CTCPRef = GetColorTableControlPanelDFR()
			Wave /Z sliderTicks = CTCPRef:WMSliderTicks
			Wave /T/Z sliderTickLabels = CTCPRef:WMSliderTickLabels
			if (!WaveExists(sliderTicks) || !WaveExists(sliderTickLabels))
				InitColorTableControlPanel(CTCPRef)
				Wave /Z sliderTicks = CTCPRef:WMSliderTicks
				Wave /T/Z sliderTickLabels = CTCPRef:WMSliderTickLabels
			endif
			
			Variable sliderMin=zMin, sliderMax=zMax	
			String objectUserData = GetUserData(topGraphName, "", zInfo.objName)	
			String sliderMinMaxStr = StringByKey(zInfo.objType+"_sliderLimits", objectUserData,"=")  			
			if (strlen(sliderMinMaxStr))
				String sliderMinStr = StringFromList(0, sliderMinMaxStr[1,strlen(sliderMinMaxStr)-2], ",")
				String sliderMaxStr = StringFromList(1, sliderMinMaxStr[1,strlen(sliderMinMaxStr)-2], ",")
				if (CmpStr("*", sliderMinStr))
					sliderMin = str2num(sliderMinStr)			
				endif
				if (CmpStr("*", sliderMaxStr))
					sliderMax = str2num(sliderMaxStr)	
				endif
			endif

			sliderTicks = {sliderMin, (sliderMin+sliderMax)/2, sliderMax}
			String labelStr
			String format= "%g" // was "%.2e"
			sprintf labelStr, format, sliderMin
			sliderTickLabels[0] = labelStr
			sprintf labelStr, format, (sliderMin+sliderMax)/2
			sliderTickLabels[1] = labelStr
			sprintf labelStr, format, sliderMax
			sliderTickLabels[2] = labelStr
			
			Variable live = NumVarOrDefault("root:Packages:ColorTableControlPanel:WMLiveSlider", 1)
			Slider highSliderSC, win=ColorTableControlPanel, live=live, limits={sliderMin, sliderMax, (sliderMax-sliderMin)/sliderIncrement}, value=zInfo.zMax, userTicks={sliderTicks, sliderTickLabels}
			Slider lowSliderSC, win=ColorTableControlPanel, live=live, limits={sliderMin, sliderMax, (sliderMax-sliderMin)/sliderIncrement}, value=zInfo.zMin, userTicks={sliderTicks, sliderTickLabels}
		
			//// Sliders min/max set variables
			SetVariable maxSetSliderSV, win=ColorTableControlPanel, value=_NUM:sliderMax 
			SetVariable minSetSliderSV, win=ColorTableControlPanel, value=_NUM:sliderMin

			//// sliders positions set variables
			SetVariable slidersHighSV, win=ColorTableControlPanel, value=_NUM:zInfo.zMax, limits={sliderMin, sliderMax, 0}
			SetVariable slidersLowSV, win=ColorTableControlPanel, value=_NUM:zInfo.zMin, limits={sliderMin, sliderMax, 0}
			
			ControlUpdate /W=ColorTableControlPanel highSliderSC
			ControlUpdate /W=ColorTableControlPanel lowSliderSC
			Checkbox reverseTableCheck, win=ColorTableControlPanel, value=zInfo.revColorTable, disable=2*(zInfo.flags & cZInfoIsCIndex)/cZInfoIsCIndex //revColorTable
					
			//// Update the status box
			handleError(zInfo)
		endif
	else       //// no z colored graph objects.  disable the controls
		PopupMenu selectTracePU win=ColorTableControlPanel, mode=1 // select _none_
		ModifyControlList/Z ctrls, win=ColorTableControlPanel, disable=2
		String msg= "No z colored objects in the active graph."
		Variable isTopLevelWindow = ItemsInList(topGraphName,"#") == 1
		if( isTopLevelWindow )
			String children = ChildWindowList(topGraphName)
			if( strlen(children) )
				msg += "\r(Click in a graph subwindow to make it active.)"
			endif
		endif
		TitleBox statusText, win=ColorTableControlPanel, title=msg
		TitleBox cIndexInUse, win=ColorTableControlPanel, disable=1	 // hide
	endif
End

//// Prints an error in the status box.  
//// The status box only shows 2 lines, so order the messages in order of importance.
Function handleError(zInfo)
	Struct zInfoStruct & zInfo
	
	DFREF colorTablePackageDFR = GetColorTableControlPanelDFR()
	
	String /G colorTablePackageDFR:errStr = ""
	SVAR errStr = colorTablePackageDFR:errStr
	SVAR topGraphName = colorTablePackageDFR:topGraphName // 

	String host= StringFromList(0, topGraphName, "#")
	DoWindow $host
	if (!V_flag || WinType(topGraphName) != 1 )
		UpdateControlPanel()
	endif
	
	if (zInfo.flags & cZInfoGraphObjectMissing)
		if (strlen(errStr))
			errStr += "\r"
		endif
		strswitch (zInfo.objType)
			case "image":
				errStr += "Error: image "+zInfo.objName+" does not exist in "+topGraphName+"."
				break
			case "trace":
				errStr += "Error: wave "+zInfo.objName+" does not exist in "+topGraphName+"."			
				break
			case "contour":
			case "contour lines":
			case "contour fill":
				errStr += "Error: contour "+zInfo.objName+" does not exist in "+topGraphName+"."
				break
			default:
				break
		endswitch
	endif

	if (zInfo.flags & cZInfoColorTableWaveMissing)
		if (strlen(errStr))
			errStr += "\r"
		endif
		errStr += "Error: color table wave "+zInfo.colorTable+" does not exist."
	endif

	if (zInfo.flags & cZInfoCIndexWaveMissing)
		if (strlen(errStr))
			errStr += "\r"
		endif
		errStr += "Error: color index wave "+zInfo.colorTable+" does not exist."
	endif
	
	if (zInfo.flags & cZInfoCIndexHighEqLow)
		if (strlen(errStr))
			errStr += "\r"
		endif
		errStr += "Error: a color index wave cannot have a first value equal the last value."
	endif
	
	if (zInfo.flags & cZInfoIsCIndex)
		if (strlen(errStr))
			errStr += "\r"
		endif
		errStr += "Warning: changes will affect the x scaling of the color index wave.\r"
		errStr += "Note: Use the sliders to reverse the color table."
	endif
	
	TitleBox statusText, win=ColorTableControlPanel, variable=errStr
End	

//// UpdateTopGraph() ////
//// - find the current selected trace
//// - get values of all the controls and set the graph objects values accordingly
Function/S UpdateTopGraph()

	ControlInfo /W=ColorTableControlPanel selectTracePU
	String selectedTrace = S_Value
	
	ControlInfo /W=ColorTableControlPanel selectColorTablePU
	String selectedColorTable = S_Value
	
	ControlInfo /W=ColorTableControlPanel highSliderSC
	Variable vh= V_Value
	ControlInfo /W=ColorTableControlPanel lowSliderSC
	Variable vl= V_Value
	
	ControlInfo /W=ColorTableControlPanel reverseTableCheck
	Variable revCT = V_Value
		
	DFREF colorTablePackageDFR = GetColorTableControlPanelDFR()
	SVAR topGraph = colorTablePackageDFR:topGraphName // can be subwindow path

	Struct zInfoStruct zInfo
	getZInfoFromObject(topGraph, selectedTrace, zInfo)
	
	if (strlen(zInfo.zWaveName))
		updateGraphObject(zInfo, vl, vh, selectedColorTable, revCT)
	endif
	
	return topGraph
End

///// Set minVal or maxVal to NaN to auto calculate
///// This function simply changes the userdata for the named graph object in the top graph.  It uses the name as it appears in the popup with "_" prepended,
///// which includes the type information (trace, image or countour), so it should not interfere with user data.
Function setSliderLimits(minVal, maxVal, [doUp, currObject])
	Variable minVal, maxVal
	Variable doUp
	String currObject

	String minValStr, maxValStr
	
	if (ParamIsDefault(doUp))
		doUp = 1
	endif
	if (ParamIsDefault(currObject))
		ControlInfo /W=ColorTableControlPanel selectTracePU
		currObject=S_Value
	endif
	
	DFREF colorTablePackageDFR = GetColorTableControlPanelDFR()
	SVAR topGraph = colorTablePackageDFR:topGraphName // can be subwindow path
	Struct zInfoStruct zInfo
	getZInfoFromObject(topGraph,currObject, zInfo)
	Wave /Z zWave = $(zInfo.zWaveDataFolder + zInfo.zWaveName)
	if (!waveExists(zWave))
		zInfo.flags = zInfo.flags | cZInfoGraphObjectMissing
		handleError(zInfo)
	endif
	
	if (numType(minVal)==2)
		minValStr = "*"
		minVal = waveMin(zWave)
	else
		minValStr = num2str(minVal)
	endif
	if (numType(maxVal)==2)
		maxValStr = "*"
		maxVal = waveMax(zWave)
	else	
		maxValStr = num2str(maxVal)
	endif
	
	String objectUserData = GetUserData(topGraph, "", zInfo.objName)	
	objectUserData = ReplaceStringByKey(zInfo.objType+"_sliderLimits", objectUserData, "{"+minValStr+","+maxValStr+"}", "=")
	SetWindow $topGraph userdata($(zInfo.objName))=objectUserData
	
	Variable sliderMin=zInfo.zMin, sliderMax=zInfo.zMax
	if (sliderMin < minVal)
		sliderMin = minVal
	elseif (sliderMin > maxVal)
		sliderMin = maxVal
	endif
	if (sliderMax < minVal)
		sliderMax = minVal
	elseif (sliderMax > maxVal)
		sliderMax = maxVal
	endif	
	
	updateGraphObject(zInfo, sliderMin, sliderMax, "", zInfo.revColorTable)
	
	if (doUp)
		UpdateControlPanel()   ////update the control panel
	endif
End

//// Getting the slider min/max should be part of ControlInfo, but it is not.  This function tries to get it from the graph's user data.
//// if its not set (generally it will not be), then get it from the current graph object's underlying data
Function getCurrentSliderMinMax(minVar, maxVar)
	Variable & minVar
	Variable & maxVar
	
	ControlInfo /W=ColorTableControlPanel selectTracePU	
	String currObject=S_Value

	if (strlen(currObject))		/// there's at least one graph object	
		DFREF colorTablePackageDFR = GetColorTableControlPanelDFR()
		SVAR topGraph = colorTablePackageDFR:topGraphName // can be subwindow path
		Struct zInfoStruct zInfo
		getZInfoFromObject(topGraph, currObject, zInfo)
		
		Wave /Z zWave = $(zInfo.zWaveDataFolder + zInfo.zWaveName)
		if (!waveExists(zWave))
			zInfo.flags = zInfo.flags | cZInfoGraphObjectMissing
			handleError(zInfo)
			
			UpdateControlPanel()
		endif
		
		Variable zMax=waveMax(zWave), zMin=waveMin(zWave)

		/////// update the panel values ///////
		minVar=zMin
		maxVar=zMax
		
		String objectUserData = GetUserData(topGraph, "", zInfo.objName)	
		String sliderMinMaxStr = StringByKey(zInfo.objType+"_sliderLimits", objectUserData,"=")  
		if (strlen(sliderMinMaxStr))
			String sliderMinStr = StringFromList(0, sliderMinMaxStr[1,strlen(sliderMinMaxStr)-2], ",")
			String sliderMaxStr = StringFromList(1, sliderMinMaxStr[1,strlen(sliderMinMaxStr)-2], ",")
			if (CmpStr("*", sliderMinStr))
				minVar = str2num(sliderMinStr)			
			endif
			if (CmpStr("*", sliderMaxStr))
				maxVar = str2num(sliderMaxStr)	
			endif
		endif
	else
		minVar = NaN
		maxVar = NaN
	endif
End

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////// Event Functions ///////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

//// remember the panel position and size
//// when the panel is activated update the controls
Function WinHook(s)
	STRUCT WMWinHookStruct &s

	Variable rval= 0
	strswitch(s.eventName)
		case "xkill":
			Execute/P/Q/Z "DELETEINCLUDE <Color Table Control Panel>"
			Execute/P/Q/Z "COMPILEPROCEDURES "		
			break
		case "activate":
			UpdateControlPanel()		
			break
		case "resize":
			UpdateControlPanel()
		case "moved":		
			DFREF CTCPRef = GetColorTableControlPanelDFR()
			NVAR /Z panelHeight = CTCPRef:PanelHeight 
			NVAR /Z panelWidth = CTCPRef:PanelWidth
			NVAR /Z xLocation = CTCPRef:xLocation
			NVAR /Z yLocation = CTCPRef:yLocation
			
			if (!NVAR_exists(panelHeight) || !NVAR_exists(panelWidth) || !NVAR_exists(xLocation) || !NVAR_exists(yLocation))
				InitColorTableControlPanel(CTCPRef)
				NVAR panelHeight = CTCPRef:PanelHeight 
				NVAR panelWidth = CTCPRef:PanelWidth
				NVAR xLocation = CTCPRef:xLocation
				NVAR yLocation = CTCPRef:yLocation
			endif
			
			GetWindow ColorTableControlPanel wsize	
			panelHeight = V_bottom-V_top
			panelWidth = V_right-V_left
			yLocation = V_top
			xLocation = V_left
			break
		default:
			break
	endswitch
End

Function LiveCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	Slider highSliderSC, win=ColorTableControlPanel, live=checked
	Slider lowSliderSC, win=ColorTableControlPanel, live=checked
End

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////// Control Functions //////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

Function sliderLimitsSetVarProc(SV_Struct) : SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct
	
	switch (SV_Struct.eventCode)
		case 2:
			Variable minVar, maxVar
			getCurrentSliderMinMax(minVar, maxVar)   //// minVar and maxVar are the "first" and "last" sliders, respectively.
			
			if (!CmpStr(SV_Struct.ctrlName, "maxSetSliderSV"))	
				maxVar = SV_Struct.dval
			else
				minVar = SV_Struct.dval
			endif

			Variable trueMin = min(minVar, maxVar)    //// they may not be the true min or max
			Variable trueMax = max(minVar, maxVar)

			setSliderLimits(minVar, maxVar)
			
			Variable highSliderVal, lowSliderVal
			ControlInfo /W=ColorTableControlPanel highSliderSC
			highSliderVal = V_Value
			ControlInfo /W=ColorTableControlPanel lowSliderSC
			lowSliderVal = V_Value

			STRUCT WMSliderAction sa
			sa.win=SV_Struct.win
			sa.eventCode=9

			Variable updateCalled = 0
			if (highSliderVal < trueMin)
				Slider highSliderSC, win=ColorTableControlPanel, value=trueMin
				sa.ctrlName = "highSliderSC" 
				sa.curval=trueMin
				SliderProc(sa)
				updateCalled = 1  //// SliderProc will update the top graph.  No need to do it again
			elseif (highSliderVal > trueMax)
				Slider highSliderSC, win=ColorTableControlPanel, value=trueMax
				sa.ctrlName = "highSliderSC" 
				sa.curval=trueMax
				SliderProc(sa)	
				updateCalled = 1 //// SliderProc will update the top graph.  No need to do it again
			endif
			
			if (lowSliderVal < trueMin)
				Slider lowSliderSC, win=ColorTableControlPanel, value=trueMin
				sa.ctrlName = "lowSliderSC" 
				sa.curval=trueMin
				SliderProc(sa) 
				updateCalled = 1 //// SliderProc will update the top graph.  No need to do it again
			elseif (lowSliderVal > trueMax)
				Slider lowSliderSC, win=ColorTableControlPanel, value=trueMax
				sa.ctrlName = "lowSliderSC" 
				sa.curval=trueMax
				SliderProc(sa) 
				updateCalled = 1 //// SliderProc will update the top graph.  No need to do it again
			endif
	
			if (!updateCalled)
				updateTopGraph()
			endif
	
			break
		default:
			break
	endswitch
End

//// Auto calc button.  Simply call set Slider limits with NaN arguments to set slider limits according to the current graph object
Function sliderLimitsAutoCalc(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	switch (B_Struct.eventCode)
		case 2: //// Mouse up
			setSliderLimits(NaN, NaN)			
			break
		default:
			break
	endswitch
End

//// Save the current control settings
Function SavePreset(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	if (B_Struct.eventCode==2)
		DFREF CTCPRef = GetColorTableControlPanelDFR()
	
		NVAR /Z highSliderPreset = CTCPRef:WMHighSliderPreset 
		NVAR /Z lowSliderPreset = CTCPRef:WMLowSliderPreset
		SVAR /Z colorTablePreset = CTCPRef:WMColorTablePreset // can be path to color table wave 	
		NVAR /Z highSliderPresetLimit = CTCPRef:WMHighSliderLimitPreset
		NVAR /Z lowSliderPresetLimit = CTCPRef:WMLowSliderLimitPreset	
		NVAR /Z revColorTable = CTCPRef:WMReverseColorTablePreset
		
		if (!NVAR_exists(highSliderPreset) || !NVAR_exists(lowSliderPreset) || !SVAR_exists(colorTablePreset) ||!NVAR_exists(revColorTable))
			InitColorTableControlPanel(CTCPRef)
			NVAR highSliderPreset = CTCPRef:WMHighSliderPreset 
			NVAR lowSliderPreset = CTCPRef:WMLowSliderPreset
			SVAR colorTablePreset = CTCPRef:WMColorTablePreset 
			NVAR highSliderPresetLimit = CTCPRef:WMHighSliderLimitPreset
			NVAR lowSliderPresetLimit = CTCPRef:WMLowSliderLimitPreset
			NVAR revColorTable = CTCPRef:WMReverseColorTablePreset
		endif
		
		ControlInfo /W=ColorTableControlPanel selectColorTablePU
		if (strlen(S_Value))
			colorTablePreset = S_Value
		endif
		ControlInfo /W=ColorTableControlPanel highSliderSC
		if (numtype(V_Value)!=2)
			highSliderPreset = V_Value
		endif
		ControlInfo /W=ColorTableControlPanel lowSliderSC
		if (numtype(V_Value)!=2)
			lowSliderPreset = V_Value
		endif	
		ControlInfo /W=ColorTableControlPanel maxSetSliderSV
		if (numtype(V_Value)!=2)
			highSliderPresetLimit = V_Value
		endif
		ControlInfo /W=ColorTableControlPanel minSetSliderSV
		if (numtype(V_Value)!=2)
			lowSliderPresetLimit = V_Value
		endif
		ControlInfo /W=ColorTableControlPanel reverseTableCheck
		revColorTable = V_Value
				
		String presetSettings
		sprintf presetSettings, "{%g, %g, %s, %d}", lowSliderPreset, highSliderPreset, colorTablePreset, revColorTable
		SetVariable currentPresetSettings, win=ColorTableControlPanel, value=_STR:presetSettings
	endif
End

//// apply the saved control settings to the current graph object, or to all graph objects
Function ApplyPreset(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	if (B_Struct.eventCode==2)
		DFREF CTCPRef = GetColorTableControlPanelDFR()
	
		NVAR /Z highSliderPreset = CTCPRef:WMHighSliderPreset 
		NVAR /Z lowSliderPreset = CTCPRef:WMLowSliderPreset
		SVAR /Z colorTablePreset = CTCPRef:WMColorTablePreset 
		NVAR /Z highSliderPresetLimit = CTCPRef:WMHighSliderLimitPreset
		NVAR /Z lowSliderPresetLimit = CTCPRef:WMLowSliderLimitPreset			
		NVAR /Z revColorTable = CTCPRef:WMReverseColorTablePreset
		
		if (!NVAR_exists(highSliderPreset) || !NVAR_exists(lowSliderPreset) || !SVAR_exists(colorTablePreset) || !NVAR_exists(revColorTable))
			InitColorTableControlPanel(CTCPRef)
			NVAR highSliderPreset = CTCPRef:WMHighSliderPreset 
			NVAR lowSliderPreset = CTCPRef:WMLowSliderPreset
			SVAR colorTablePreset = CTCPRef:WMColorTablePreset 
			NVAR highSliderPresetLimit = CTCPRef:WMHighSliderLimitPreset
			NVAR lowSliderPresetLimit = CTCPRef:WMLowSliderLimitPreset
			NVAR revColorTable = CTCPRef:WMReverseColorTablePreset			
		endif
			
		if (numtype(highSliderPreset) != 2 && numtype(lowSliderPreset)!=2 && strlen(colorTablePreset)!=0 && CmpStr(colorTablePreset, "_none_"))
			DFREF colorTablePackageDFR = GetColorTableControlPanelDFR()
			SVAR topGraph = colorTablePackageDFR:topGraphName // can be subwindow path
			String objectsList = ""
			ControlInfo /W=ColorTableControlPanel selectTracePU
			String selectedTrace = S_Value
			if (!CmpStr(B_Struct.ctrlName, "applyAllPreset"))
				objectsList = getZColoredObjectsFromTopWin(topGraph)
			else
				if (CmpStr(selectedTrace, "_none_"))
					objectsList = selectedTrace + ";"
				endif
			endif
	
			Variable i
			Struct zInfoStruct zInfo
			for (i=0; i<ItemsInList(objectsList); i+=1)
				String currObject = StringFromList(i, objectsList)
				getZInfoFromObject(topGraph, currObject, zInfo)
		
				setSliderLimits(lowSliderPresetLimit, highSliderPresetLimit, doUp=0, currObject=currObject)
				
				if (strlen(zInfo.zWaveName))
					updateGraphObject(zInfo, lowSliderPreset, highSliderPreset, colorTablePreset, revColorTable)				
				endif
			endfor
		endif
		UpdateControlPanel()
	endif
End

Function Help(ctrlName) : ButtonControl
	String ctrlName
	
	DisplayHelpTopic "Color Table Control Panel"	
End

Function/S ActiveGraph()

	// Perhaps the topmost panel has an active graph.
	// Since the Color Table Control panel exists, we need to look
	// at the next top-most window.
	String wins = WinList("!ColorTableControlPanel",";","WIN:65,VISIBLE:1") // all visible panels and graphs, top-most first
	String win= StringFromList(0,wins)
	GetWindow/Z $win activeSW
	if( WinType(S_Value) == 1 )
		win= S_Value // active graph subwindow
	else
		if( WinType(win) != 1 ) // top is not a graph host, and doesn't have an active graph subwindow
			win= WinName(0,1,1) // top visible graph
			GetWindow/Z $win activeSW
			if( WinType(S_Value) == 1 )
				win= S_Value // active graph subwindow
			endif
		endif
	endif
	return win
End

Function/S ActiveGraphHost()

	String graph= ActiveGraph()
	String host= StringFromList(0,graph,"#")
	return host
End

Function ModifyTarget(ctrlName) : ButtonControl
	String ctrlName
	
	ControlInfo /W=ColorTableControlPanel selectTracePU
	String selectedTrace = S_Value
	
	DFREF colorTablePackageDFR = GetColorTableControlPanelDFR()
	SVAR win = colorTablePackageDFR:topGraphName // can be subwindow path
	Struct zInfoStruct zInfo
	getZInfoFromObject(win, selectedTrace, zInfo)
	
	String cmd=""
	strswitch (zInfo.objType)
		case "image":
			cmd="DoIgorMenu \"Image\", \"Modify Image Appearance\""
			break
		case "trace":
			cmd="DoIgorMenu \"Graph\", \"Modify Trace Appearance\""
			break
		case "contour":
		case "contour lines":
		case "contour fill":
			cmd="DoIgorMenu \"Graph\", \"Modify Contour Appearance\""
			break
	endswitch
	if( strlen(cmd) )
		String host= StringFromList(0, win, "#")
		DoWindow/F $host
		SetActiveSubwindow $win
		Execute/P/Q/Z cmd
	endif
End


Function SelectTraceProc(PU_Struct) : PopupMenuControl
	STRUCT WMPopupAction &PU_Struct
	
	switch( PU_Struct.eventCode )
		case -1: // control being killed
			break
		case 2:
			UpdateControlPanel()
			break
		default:
			break
	endswitch
End

Function SelectColorTableProc(PU_Struct) : PopupMenuControl
	STRUCT WMPopupAction &PU_Struct
	
	switch( PU_Struct.eventCode )
		case -1: // control being killed
			break
		case 2:			
			UpdateTopGraph()
			break
		default:
			break
	endswitch
End

Function reverseColorTableProc(CB_Struct) : CheckBoxControl
	STRUCT WMCheckBoxAction &CB_Struct
	
	switch( CB_Struct.eventCode )
		case -1: // control being killed
			break
		case 2:			
			UpdateTopGraph()
			break
		default:
			break
	endswitch
End

Function setVarProc(SV_Struct) : SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct
	
	switch( SV_Struct.eventCode )
		case -1:
			break
		case 2:
			SV_Struct.blockReentry=1			
			///// the tricky bits regarding holding the high-low difference are all in the slider control function.  Probably should remove it, but
			///// its currently a bit of a tangle.  Set the appropriate slider, create a slider action struct and call the slider proc.  
			STRUCT WMSliderAction sa
			sa.win=SV_Struct.win
			sa.eventCode=9
			sa.curval = SV_Struct.dval
			
			if (!CmpStr(SV_Struct.ctrlName, "slidersHighSV"))		
				Slider highSliderSC, win=ColorTableControlPanel, value=SV_Struct.dval
				sa.ctrlName = "highSliderSC"
			else
				Slider lowSliderSC, win=ColorTableControlPanel, value=SV_Struct.dval
				sa.ctrlName = "lowSliderSC"
			endif
			SliderProc(sa)			
			
			break
		default:
			break
	endswitch
End

Function SliderProc(sa) : SliderControl
	STRUCT WMSliderAction &sa

	switch( sa.eventCode )
		case -3: // Control received keyboard focus
		case -2: // Control lost keyboard focus
		case -1: // Control being killed
			break
		default:
			if( (sa.eventCode & 1) == 0 )
				break // value not set
			endif
				
			sa.blockReentry=1
		
			//// get general slider conditions - assumes limits are the same for all sliders
			ControlInfo /W=ColorTableControlPanel highSliderSC
			String recreation = S_recreation
			Variable index, i		
			
			Variable iLimitsStart = strsearch(recreation, "limits={",0)   // find the location of the recreation string containing slider limits data
			if (iLimitsStart >= 0)
				Variable iLimitsEnd = strsearch(recreation, "}",iLimitsStart)   // the location of the end of the limits data
				String limitsStr = recreation[iLimitsStart+8, iLimitsEnd-1]      // get the string
				Variable minVal = str2num(StringFromList(0, limitsStr, ","))   // get the pieces of info needed
				Variable maxVal = str2num(StringFromList(1, limitsStr, ","))
							
				ControlInfo /W=ColorTableControlPanel selectTracePU
				String selectedTrace = S_Value
				DFREF colorTablePackageDFR = GetColorTableControlPanelDFR()
				SVAR topGraph = colorTablePackageDFR:topGraphName // can be subwindow path
				Struct zInfoStruct zInfo
				getZInfoFromObject(topGraph,selectedTrace, zInfo)
								
				DFREF colorTablePackageDFR = GetColorTableControlPanelDFR()
				NVAR holdEnds = colorTablePackageDFR:WMHoldAtEnds
			
				Variable lowVal, highVal
				if (!CmpStr(sa.ctrlName, "highSliderSC"))
					highVal = sa.curval
					lowVal = zInfo.zMin
				else
					highVal = zInfo.zMax
					lowVal = sa.curval
				endif
			
				if (holdEnds)
					Variable difference = zInfo.zMax - zInfo.zMin
					
					if (!CmpStr(sa.ctrlName, "highSliderSC"))
						if (sa.curval - difference < minVal)
							highVal = minVal+difference
							lowVal = minVal
						elseif (sa.curval - difference > maxVal)
							highVal = maxVal+difference
							lowVal = maxVal
						else
							lowVal = sa.curval-difference
						endif
					else
						if (sa.curval + difference < minVal)
							highVal = minVal
							lowVal = minVal-difference
						elseif (sa.curval + difference > maxVal)
							highVal = maxVal
							lowVal = maxVal-difference							
						else
							highVal = sa.curval+difference
						endif
					endif
				endif
				
				Slider highSliderSC, win=ColorTableControlPanel, value=highVal
				Slider lowSliderSC, win=ColorTableControlPanel, value=lowVal
				SetVariable slidersHighSV, win=ColorTableControlPanel, value=_NUM:highVal
				SetVariable slidersLowSV, win=ColorTableControlPanel, value=_NUM:lowVal
			endif		
			UpdateTopGraph()
			break
	endswitch

	return 0
End


////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// Utility Structures and  Functions /////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
Structure zInfoStruct
	String graphName // top graph name or path to graph subwindow, such as Panel0#G0
	String objName
	String colorTable // or path to color table wave if COLORMODE=6 image, or trace ctableRGB. path to color index wave if COLORMODE=2 or 3 or trace cindexRGB
	String zWaveName	// contour or image z data (matrix or Z of XYZ), possibly-quoted
	String zWaveDataFolder
	String objType
	Variable flags   //// Bit-wise variable.  Constants defined with cZInfo prefix.  
	Variable zMin
	Variable zMax
	Variable revColorTable
EndStructure

///// Fill out the zInfoStruct given the name as it appears in the selectTracePU popup and as returned by getZColoredObjectsFromTopWin()
Function getZInfoFromObject(graphName, objectNameInPopUp, zInfo)
	String graphName
	String objectNameInPopUp
	Struct zInfoStruct & zInfo
	
	zInfo.graphName = graphName
	
	Variable iStart = strsearch(objectNameInPopUp, "(", strlen(objectNameInPopUp)-1, 1)+1
	zInfo.objType = objectNameInPopUp[iStart, strlen(objectNameInPopUp)-2]
	zInfo.objName = objectNameInPopUp[0, iStart-3]
	zInfo.zWaveDataFolder = ""
	zInfo.flags = 0
	
	//// utility variables ////
	String info, recreation, zColorStr, zWaveName, colorArgs
	String highValStr, lowValStr, revColorTableStr
	Variable numArgs
	
	strswitch (zInfo.objType)
		case "trace":
			info = TraceInfo(graphName, zInfo.objName, 0)		
			recreation = StringByKey("RECREATION", info)
			zColorStr = StringByKey("zColor(x)", recreation, "=")
			colorArgs = zColorStr[1,strlen(zColorStr)-2]
			numArgs = ItemsInList(colorArgs, ",")
			// if just a color table, colorArgs has 4 or 5 args
			// jack,*,*,Grays[,reverse]
			
			// if user-defined color index wave, colorArgs has 6 args, the 4th is 'cindexRGB'
			// jack,*,*,cindexRGB,reverse,::M_colors
			
			// if user-defined color table wave, colorArgs has 6 args, the 4th is 'ctableRGB'
			// jack,*,*,ctableRGB,reverse,::Packages:ColorTables:Misc:cividis

			// Notes:
			//		Wave paths are relative to the current data folder.
			//		Wave names are possibly-quoted.
			//		The 5th parameter is always the sometimes-optional reverse parameter.
				
			zInfo.colorTable = StringFromList(3, colorArgs, ",") // built-in color table name or "cindexRGB" or "ctableRGB"

			String relativeZWavePath = StringFromList(0, colorArgs, ",")
			zInfo.zWaveName = ParseFilePath(0, relativeZWavePath, ":", 1, 0) // if liberal wave name, it is already possibly-quoted
			zInfo.zWaveDataFolder = GetDataFolder(1)+ParseFilePath(1, relativeZWavePath, ":", 1, 0)
			Wave /Z zWave = $(zInfo.zWaveDataFolder + zInfo.zWaveName)
			if (!waveExists(zWave))
				zInfo.flags = zInfo.flags | cZInfoGraphObjectMissing
				handleError(zInfo)
				break
			endif

			highValStr = StringFromList(2, colorArgs, ",")
			if (CmpStr(highValStr, "*")==0)
				zInfo.zMax = waveMax(zWave)
			else 	
				zInfo.zMax = str2num(highValStr)
			endif

			lowValStr = StringFromList(1, colorArgs, ",")
			if (CmpStr(lowValStr, "*")==0)
				zInfo.zMin = waveMin(zWave)
			else 	
				zInfo.zMin = str2num(lowValStr)
			endif
			
			// distinguish between cindexRGB, ctableRGB, and normal built-in color table
			strswitch( zInfo.colorTable )
				case "cindexRGB":
					zInfo.flags = zInfo.flags | cZInfoIsCIndex   // set the color index bit
					zInfo.colorTable = StringFromList(5, colorArgs, ",")
					break
					
				case "ctableRGB":
					zInfo.flags = zInfo.flags | cZInfoIsColorTableWave   // color table wave
					zInfo.colorTable = StringFromList(5, colorArgs, ",")
					break
				
				default: // built-in color table
					break
			endswitch
		
			if (numArgs > 4)
				revColorTableStr = StringFromList(4, colorArgs, ",")
				zInfo.revColorTable = str2num(revColorTableStr)
			else	
				zInfo.revColorTable = 0
			endif
			break

		case "image":
			info = ImageInfo(graphName, zInfo.objName, 0)
			recreation = StringByKey("RECREATION", info)
			zInfo.zWaveName = PossiblyQuoteName(StringByKey("ZWave", info))
			zInfo.zWaveDataFolder = StringByKey("ZWaveDF", info)
			Wave /Z zWave = $(zInfo.zWaveDataFolder + zInfo.zWaveName)
			
			if (!waveExists(zWave))
				zInfo.flags = zInfo.flags | cZInfoGraphObjectMissing
				handleError(zInfo)
				break
			endif
			Variable colorMode = NumberByKey("COLORMODE",info)
			if (colorMode==2 || colorMode==3)
				zInfo.flags = zInfo.flags | cZInfoIsCIndex   //// set the color index bit

				zColorStr = StringByKey("cindex", recreation, "=")   //// in color index context this is the path to the color index wave. 
				if (!CmpStr(zColorStr[0], " "))                      //// also address strange space (" ") after cindex=
					zColorStr = zColorStr[1, strlen(zColorStr)-1]                        
				endif
				Wave /Z cIndexWave = $zColorStr
				if (!waveExists(cIndexWave))
					zInfo.flags = zInfo.flags | cZInfoCIndexWaveMissing
					zInfo.zMax = NaN 
					zInfo.zMin = NaN
					handleError(zInfo)
					break
				endif
				
				zInfo.colorTable = GetWavesDataFolder(cIndexWave,2) // full path with possibly-quoted wave name
				Variable zMin = DimOffset(cIndexWave, 0)
				Variable zMax = zMin + DimDelta(cIndexWave, 0) * (DimSize(cIndexWave, 0)-1)
				
				zInfo.revColorTable = 0		// Reverse Color Table disabled for Color Index Waves
				
				zInfo.zMin = zMin
				zInfo.zMax = zMax
			
			else
				zInfo.flags = zInfo.flags & ~cZInfoIsCIndex   //// clear out the color index bit
				zColorStr = StringByKey("ctab", recreation, "=")
				iStart = strsearch(zColorStr, "{", strlen(zColorStr)-2, 1)+1  /// there seems to be a space after ctab=, which seems strange so I'm not relying on the position of "{" by offset
				colorArgs = zColorStr[iStart,strlen(zColorStr)-2]
				numArgs = ItemsInList(colorArgs, ",")
				
				highValStr = StringFromList(1, colorArgs, ",")
				if (!CmpStr(highValStr, "*"))
					zInfo.zMax = waveMax(zWave)
				else 	
					zInfo.zMax = str2num(highValStr)
				endif

				lowValStr = StringFromList(0, colorArgs, ",")
				if (!CmpStr(lowValStr, "*"))
					zInfo.zMin = waveMin(zWave)
				else 	
					zInfo.zMin = str2num(lowValStr)
				endif
				
				zInfo.colorTable = StringFromList(2, colorArgs, ",") // or path to color table wave if COLORMODE=6

				if (numArgs > 3)
					revColorTableStr = StringFromList(3, colorArgs, ",")
					zInfo.revColorTable = str2num(revColorTableStr)
				else	
					zInfo.revColorTable = 0
				endif				
				if (colorMode == 6 )
					// "RECREATION:ctab= {*,*,:Packages:ColorTables:EPFL:ametrine,0};..."
					zInfo.flags = zInfo.flags | cZInfoIsColorTableWave   //// set the color table wave bit
					WAVE /Z cTableWave = $zInfo.colorTable
					if (!WaveExists(cTableWave))
						zInfo.flags = zInfo.flags | cZInfoColorTableWaveMissing
						handleError(zInfo)
					endif
					zInfo.colorTable = GetWavesDataFolder(cTableWave,2) // full path with possibly-quoted wave name
					break
				endif
			endif
			break

		case "contour": // (lines)
		case "contour lines":
		case "contour fill":
			info = contourInfo(graphName, zInfo.objName, 0) 		
			zInfo.zWaveDataFolder = StringByKey("ZWAVEDF", info)			
			zInfo.zWaveName = PossiblyQuoteName(StringByKey("ZWave", info))
			Wave /Z zWave = $(zInfo.zWaveDataFolder + zInfo.zWaveName)
	
			if (!WaveExists(zWave))
				zInfo.flags = zInfo.flags | cZInfoGraphObjectMissing
				handleError(zInfo)
				return -1
			endif		
			
			// LINES
			// ModifyContour twod ctabLines={*,*,Relief,0} // color table
			// ModifyContour twod ctabLines={*,*,:Packages:ColorTables:EPFL:ametrine,0} // color table wave
			// 	ModifyContour twod cindexLines='M colors' // color index wave

			// FILLS
			// ModifyContour twod ctabFill={*,*,LandAndSea8,0} // color table
			// ModifyContour twod ctabFill={*,*,:Packages:ColorTables:EPFL:ametrine,0} // color table wave
			// ModifyContour twod cindexFill='M colors' // color index wave

			if( CmpStr(zInfo.objType,"contour fill") == 0 )
				zColorStr = StringByKey("ctabfill", info, "=")
			else
				zColorStr = StringByKey("ctabLines", info, "=")
			endif
			if( strlen(zColorStr) )
				// normal color table or user-defined color table wave
				iStart = strsearch(zColorStr, "{", strlen(zColorStr)-1, 1)+1  /// there is no space after ctabLines=, but we're not relying on the position of "{" by offset
				colorArgs = zColorStr[iStart,strlen(zColorStr)-2]
				numArgs = ItemsInList(colorArgs, ",")
	
				highValStr = StringFromList(1, colorArgs, ",")
				if (!CmpStr(highValStr, "*"))
					zInfo.zMax = waveMax(zWave)
				else 	
					zInfo.zMax = str2num(highValStr)
				endif
				
				lowValStr = StringFromList(0, colorArgs, ",")
				if (!CmpStr(lowValStr, "*"))
					zInfo.zMin = waveMin(zWave)
				else 	
					zInfo.zMin = str2num(lowValStr)
				endif
	
				zInfo.colorTable = StringFromList(2, colorArgs, ",")  // or path to color table wave
				if (numArgs > 3)
					revColorTableStr = StringFromList(3, colorArgs, ",")
					zInfo.revColorTable = str2num(revColorTableStr)
				else	
					zInfo.revColorTable = 0
				endif				

				Variable whichBuiltin = WhichListItem(zinfo.colorTable,CTabList())
				if( whichBuiltin < 0 )
					// Not a standard built-in color table name, must be path to user-provided color table wave.
					// Note: if an older Igor opens a newer Igor's experiment using a new built-in color table,
					// the older Igor will interpret that "future" built-in color table as a (missing) color table wave.
					zInfo.flags = zInfo.flags | cZInfoIsColorTableWave   //// set the color table wave bit.
					WAVE /Z cTableWave = $zInfo.colorTable
					if (!waveExists(cTableWave))
						zInfo.flags = zInfo.flags | cZInfoColorTableWaveMissing
						handleError(zInfo)
						break
					endif
					zInfo.colorTable = GetWavesDataFolder(cTableWave,2) // full path with possibly-quoted wave name
				endif
			else
				// perhaps color index wave?
				if( CmpStr(zInfo.objType,"contour fill") == 0 )
					zColorStr = StringByKey("cindexFill", info, "=")
				else
					zColorStr = StringByKey("cindexLines", info, "=")
				endif
				if( strlen(zColorStr) )
					// yep, color index wave
					zInfo.flags = zInfo.flags | cZInfoIsCIndex   //// set the color index bit
					zInfo.colorTable = zColorStr  // relative path to color index wave
					Wave /Z cIndexWave = $zColorStr
					if (!waveExists(cIndexWave))
						zInfo.flags = zInfo.flags | cZInfoCIndexWaveMissing
						zInfo.zMax = NaN 
						zInfo.zMin = NaN
						handleError(zInfo)
						break
					endif
					zInfo.colorTable = GetWavesDataFolder(cIndexWave,2) // full path with possibly-quoted wave name
					zInfo.zMin = DimOffset(cIndexWave, 0)
					zInfo.zMax = zInfo.zMin + DimDelta(cIndexWave, 0) * (DimSize(cIndexWave, 0)-1)
				endif
			endif
			break
			
		default:
			break
	endswitch
End

Function updateColorIndexWave(zInfo, lowVal, highVal, cIndexWave)
	Struct zInfoStruct & zInfo
	Variable lowVal, highVal
	Wave /Z cIndexWave

	Variable haveCIndex= WaveExists(cIndexWave)
	if (!haveCIndex)
		zInfo.flags = zInfo.flags | cZInfoCIndexWaveMissing
		zInfo.zMax = NaN
		zInfo.zMin = NaN
	else
		if (lowVal!=highVal)   
			SetScale /I x, lowVal, highVal, cIndexWave			
		else
			zInfo.flags = zInfo.flags | cZInfoCIndexHighEqLow 
			if (abs(zInfo.zMin-lowVal) > abs(zInfo.zMax-highVal))
				Slider lowSliderSC, win=ColorTableControlPanel, value=zInfo.zMin
				SetVariable slidersLowSV, win=ColorTableControlPanel, value=_NUM:zInfo.zMin
			else
				Slider highSliderSC, win=ColorTableControlPanel, value=zInfo.zMax
				SetVariable slidersHighSV, win=ColorTableControlPanel, value=_NUM:zInfo.zMax
			endif
		endif
	endif
	return haveCIndex
End

// zInfo must be filled, presumably from a call to getZInfoFromObject()
// set low val and/or highval to NaN to use values from zInfo
// set colorTableName to "" to use the color table from zInfo
Function updateGraphObject(zInfo, lowVal, highVal, colorTableName, reverseColorTable)
	Struct zInfoStruct & zInfo
	Variable lowVal, highVal // from slider
	String colorTableName		// from popup menu control. this is NEVER copied from zInfo.colorTable, which may hold the path to a cindex or color table wave
	Variable reverseColorTable // from checkbox

	if (NumType(lowVal)==2)
		lowVal = zInfo.zMin
	endif
	if (NumType(highVal)==2)
		highVal = zInfo.zMax
	endif

	// bear in mind that often we use zInfo.colorTable to hold the path to a cindex or color table wave
	if (strlen(colorTableName)==0)
		colorTableName = zInfo.colorTable
	endif
	
	Wave/Z zWave= $(zInfo.zWaveDataFolder+zInfo.zWaveName)
	Wave /Z colorWave = $zInfo.colorTable // color index or color table wave
	
	String win= zInfo.graphName
	Variable isFill= 0
	strswitch (zInfo.objType)
		case "trace":
			if (zInfo.flags & cZInfoIsCIndex)	// f(z) with color index wave
				// zwave,low,high,cindexRGB,reverse,pathToCIndexWave
				Variable haveCIndexWave = updateColorIndexWave(zInfo, lowVal, highVal, colorWave)
				if (haveCIndexWave)
					ModifyGraph/W=$win zColor($(zInfo.objName))={zWave,*,*,cindexRGB,reverseColorTable,colorWave}
				endif
			elseif(zInfo.flags & cZInfoIsColorTableWave)	// f(z) with color table wave
				// zwave,low,high,ctableRGB,reverse,pathToColorTableWave
				if (!WaveExists(colorWave))
					zInfo.flags = zInfo.flags | cZInfoColorTableWaveMissing
					zInfo.zMax = NaN
					zInfo.zMin = NaN
				else
					ModifyGraph/W=$win zColor($(zInfo.objName))={zWave, lowVal, highVal,ctableRGB,reverseColorTable,colorWave}
				endif
			else // f(z) with built-in color table
				// {zwave,low,high,ctabName[,reverse]}
				ModifyGraph/W=$win zColor($(zInfo.objName))={zWave, lowVal, highVal,$colorTableName,reverseColorTable}
			endif
			break
		case "image":
			if (zInfo.flags & cZInfoIsCIndex)
				updateColorIndexWave(zInfo, lowVal, highVal, colorWave)
			elseif (zInfo.flags & cZInfoIsColorTableWave)
				if (!WaveExists(colorWave))
					zInfo.flags = zInfo.flags | cZInfoColorTableWaveMissing
					zInfo.zMax = NaN
					zInfo.zMin = NaN
				else
					ModifyImage/W=$win $(zInfo.objName), ctab={lowVal, highVal, colorWave, reverseColorTable}
				endif
			else // just a normal color table
				ModifyImage/W=$win $(zInfo.objName), ctab={lowVal, highVal, $colorTableName, reverseColorTable}
			endif
			break
		case "contour fill":
			isFill= 1
			// FALL THROUGH
		case "contour lines":
		case "contour":
			if (zInfo.flags & cZInfoIsCIndex)	// fill or line with color index wave
				updateColorIndexWave(zInfo, lowVal, highVal, colorWave)
			elseif (zInfo.flags & cZInfoIsColorTableWave)
				if( isFill )
					ModifyContour/W=$win $(zInfo.objName), ctabFill={lowVal, highVal, colorWave, reverseColorTable}
				else
					ModifyContour/W=$win $(zInfo.objName), ctabLines={lowVal, highVal, colorWave, reverseColorTable}
				endif
			else // just a normal color table
				if(isFill)
					ModifyContour/W=$win $(zInfo.objName), ctabFill={lowVal, highVal, $colorTableName, reverseColorTable}
				else
					ModifyContour/W=$win $(zInfo.objName), ctabLines={lowVal, highVal, $colorTableName, reverseColorTable}
				endif
			endif
			break
		default: 
			break
	endswitch
	handleError(zInfo)
End


//// Get a string list of all graph objects using a mapping from data values to a color table.  ID the type in the string.
Function /S getZColoredObjectsFromTopWin(String topWin)

	if( (strlen(topWin) == 0) || (WinType(topWin) != 1) )
		topWin= ActiveGraph()
	endif
	
	String traceList = TraceNameList(topWin, ";", 5)
	
	String currObject, currImage, info, ret=""
	Variable i
	for (i=0; i<ItemsInList(traceList); i+=1)
		currObject = StringFromList(i, traceList)
		info = TraceInfo(topWin, currObject, 0)
		String recreation = WMGetRECREATIONFromInfo(info) // RECREATION:zColor(x)={...}
		String zColorStr = StringByKey("zColor(x)", recreation, "=")
		if (strlen(zColorStr) && CmpStr(zColorStr, "0"))
			ret += currObject+" (trace);"
		endif
	endfor

	String imageList = ImageNameList(topWin, ";")
	for(i=0; i<ItemsInList(imageList); i+=1)
		currImage = StringFromList(i, imageList)
		info = ImageInfo(topWin, currImage, 0)
		Variable isCT, colorMode= NumberByKey("COLORMODE",info)
		switch( colorMode )
			case 1: // color table
			case 2: // color index wave
			case 3: // point-scaled color index wave
			case 6: // (non-indexed) color table wave
				isCT= colorMode
				break
			default:
				isCT = 0
				break
		endswitch
		if( isCT )
			ret += currImage+" (image);"
		endif
	endfor

	///// add all contours; they can have z values, too
	String contourList = ContourNameList(topWin, ";")
	for (i=0; i<ItemsInList(contourList); i+=1)
		String currContour= StringFromList(i, contourList)
		info = ContourInfo(topWin, currContour, 0)
		recreation = WMGetRECREATIONFromInfo(info) // RECREATION:update=2;autoLevels={*,*,11};lines=1;ctabLines={*,*,::Packages:ColorTables:Misc:cividis,1};fill=1;ctabFill={*,*,::Packages:ColorTables:EPFL:ametrine,0};boundary=0;xymarkers=0;labels=3;labelFormat=0;labelSigDigits=6;labelDigits=3;labelFont="default";labelFSize=0;labelFStyle=0;labelBkg=2;labelRGB=(0,0,0);labelHV=4;
		// LINES
			// ModifyContour twod rgbLines=(65535,0,0) // same colors: nothing to modify
			// 	ModifyContour twod cindexLines='M colors' // color index wave
			// ModifyContour twod ctabLines={*,*,Relief,0} // color table
			// ModifyContour twod ctabLines={*,*,:Packages:ColorTables:EPFL:ametrine,0} // color table wave
		String ctabLines = StringByKey("ctabLines",recreation, "=")
		String cindexLines = StringByKey("cindexLines",recreation, "=")
		if (strlen(ctabLines) ||strlen(cindexLines))
			ret += currContour+" (contour lines);"
		endif
		// FILLS
			// ModifyContour twod fill=1,rgbFill=(56797,56797,56797) // same colors: nothing to modify
			// ModifyContour twod fill=1,cindexFill='M colors' // color index wave
			// ModifyContour twod fill=1,ctabFill={*,*,LandAndSea8,0} // color table
			// ModifyContour twod fill=1,ctabFill={*,*,:Packages:ColorTables:EPFL:ametrine,0} // color table wave
		Variable fill = NumberByKey("fill",recreation, "=")	// 	ModifyContour twod fill=1,cindexFill='M colors'
		if( fill )
			String ctabFill = StringByKey("ctabFill",recreation, "=")
			String cindexFill = StringByKey("cindexFill",recreation, "=")
			if (strlen(ctabFill) ||strlen(cindexFill))
				ret += currContour+" (contour fill);"
			endif
		endif
	endfor
	
	if (!strlen(ret))
		ret="_none_"
	endif
	
	return ret
End

////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////// Get Set Package Data Folder ///////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

Function InitColorTableControlPanel(dfr)
	DFREF dfr

	Variable localVar
	String localStr

	localVar = NumVarOrDefault("root:Packages:ColorTableControlPanel:WMHoldAtEnds", 0)
	Variable /G dfr:WMHoldAtEnds = localVar
	localVar = NumVarOrDefault("root:Packages:ColorTableControlPanel:WMLiveSlider", 1)
	Variable /G dfr:WMLiveSlider = localVar
	localVar = NumVarOrDefault("root:Packages:ColorTableControlPanel:WMHighSliderPreset", NaN)
	Variable /G dfr:WMHighSliderPreset =  localVar
	localVar = NumVarOrDefault("root:Packages:ColorTableControlPanel:WMLowSliderPreset", NaN)
	Variable /G dfr:WMLowSliderPreset =  localVar
	localVar = NumVarOrDefault("root:Packages:ColorTableControlPanel:WMHighSliderLimitPreset", NaN)
	Variable /G dfr:WMHighSliderLimitPreset =  localVar
	localVar = NumVarOrDefault("root:Packages:ColorTableControlPanel:WMLowSliderLimitPreset", NaN)
	Variable /G dfr:WMLowSliderLimitPreset =  localVar
	localStr = StrVarOrDefault("root:Packages:ColorTableControlPanel:WMColorTablePreset", "")
	String /G dfr:WMColorTablePreset =  localStr		
	localVar = NumVarOrDefault("root:Packages:ColorTableControlPanel:PanelHeight", kHeight)
	Variable /G dfr:PanelHeight = max(localVar, kHeight)
	localVar = NumVarOrDefault("root:Packages:ColorTableControlPanel:PanelWidth", kWidth)
	Variable /G dfr:PanelWidth = max(localVar, kWidth)
	localVar = NumVarOrDefault("root:Packages:ColorTableControlPanel:xLocation", 20)
	Variable /G dfr:xLocation = localVar
	localVar = NumVarOrDefault("root:Packages:ColorTableControlPanel:yLocation", 20)
	Variable /G dfr:yLocation = localVar
//	localVar = NumVarOrDefault("root:Packages:ColorTableControlPanel:WMReverseColorTable", 0)
//	Variable /G dfr:WMReverseColorTable = localVar
	localVar = NumVarOrDefault("root:Packages:ColorTableControlPanel:WMReverseColorTablePreset", 0)
	Variable /G dfr:WMReverseColorTablePreset = localVar
	
	Wave /Z testWaveRef = dfr:WMSliderTicks
	if (!WaveExists(testWaveRef))
		Make /D/N=3 dfr:WMSliderTicks
	endif
	Wave /Z testWaveRef = dfr:WMSliderTickLabels
	if (!WaveExists(testWaveRef))
		Make /T/N=3 dfr:WMSliderTickLabels
	endif
End

// Creates the data folder if it does not already exist.
Function /DF GetColorTableControlPanelDFR()
	DFREF dfr = root:Packages:ColorTableControlPanel
	if (DataFolderRefStatus(dfr) != 1)
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:ColorTableControlPanel
		DFREF dfr = root:Packages:ColorTableControlPanel
		
		InitColorTableControlPanel(dfr)
	endif
	return dfr
End

