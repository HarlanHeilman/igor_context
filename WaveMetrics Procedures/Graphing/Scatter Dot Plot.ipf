#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.11
#include <WaveSelectorWidget>
#include <PopupWaveSelector>, version>=1.11
#include <Resize Controls>

#pragma IndependentModule = ScatterDotPlot 

// Version 1.1: 	Handled case where all bins calculate to the same value - meaning all waves have the same value
//				Also changed getSDPPackageWaveName(wName) to trim the length of SDPPackage wave names to 29 to 
//				accomodate names for error bars
// Version 1.11, JW 190708
//		Fixed bug: if the lowest bin boundary was at the start of a wave being counted, and that value was
// 		repeated in the wave being counted, then it didn't count all instances of that value.
//		Updated: Changed to rtGlobals=3. When I did that, it found a bad wave reference in WMScatterDotPlotGraph().
//		Updated: added TextEncoding pragma.
//		Setting rtGlobals=3 found a bug in updateGraph(); see comments marked "JW 190708". It was another
//			manifestation of the bug above.
//		The function doItButtonProc() calls updateGraph() to set up the a new graph or modify a pre-existing graph.
//			But updateGraph() changes some data waves that can trigger a dependency that also calls updateGraph() resulting
//			in recursion. I don't know why this wasn't causing bugs. It sure made it hard to debug!

static strconstant newGraphTag = "_New Graph_"
static constant DPConstantNBins = 1
static constant DPConstantMarkerSize = 2

static constant DPConstantMaxAutoIterations = 40
static constant DPSmallConstant = 2.2250738585072014e-308

static constant DPAdjustNBinsPlots = 1
static constant DPAdjustMarkerSizePlots = 2

static constant DPSpreadMarkers = 1
static constant DPTightMarkers = 2
static constant DPOverlapMarkers = 3

static constant DPStdDev = 1
static constant DPStdErr = 2
static constant DPWaveDef = 3

static strconstant DPNoWave = "_none_"
static strconstant DPSameWave = "Same as + Err Bar Wave"

//////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////// Panel Set-up Function ////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
Function ScatterDotPlotPanel()
	// if it already exists, exit
	DoWindow /F DotPanel
	if (V_Flag != 0)
		return 0
	endif

	/// package data folder references	
	DFREF pkgDFR = WMGetScatterDotPlotDFR()	
	DFREF graphDFR = WMGetScatterDotPlotGraphDFR()

	/// variable references
	SVAR currGraph = pkgDFR:currentGraphName	
	NVAR panelWth = pkgDFR:ScatterDotPlotWidth
	NVAR panelHt = pkgDFR:ScatterDotPlotHeight
	
	panelWth=max(panelWth,400)
	panelHt = max(panelHt, 610)	
	
	/// control locations variables
	Variable listboxHt = floor(panelHt *0.196721)
	Variable optionsY = listboxHt*2 + floor(panelHt*0.21)-55
	Variable optionsHt = floor(panelHt*0.344262)+55	
	Variable optionsLeftCol = floor(panelWth*0.425)
	
	// panel control variables	
	// position
	NVAR xLoc = pkgDFR:ScatterDotPlotXLoc
	NVAR yLoc = pkgDFR:ScatterDotPlotYLoc
	// listbox waves
	Wave selectedWaves = graphDFR:selectedWaveNames
	Wave selectedWavesSelected = graphDFR:selectedWaveSelected
	
	// The panel and the controls
	NewPanel /N=DotPanel /W=(xLoc,yLoc, xLoc+panelWth, yLoc+panelHt) /K=1 as "Scatter Dot Plot"
	SetWindow DotPanel,hook(activateHook)=DotPanelHook

	PopupMenu selectGraph win=DotPanel, pos={10,10}, size={180,20}, title="Select Graph", value="New Graph;Top Graph"; DelayUpdate
	PopupMenu selectGraph win=DotPanel, fsize=13, proc=SelectGraphProc
	
	SetVariable currentGraph win=DotPanel, pos={200, 10}, size={panelWth-200, 20}, title="Current Graph:", value=currGraph, noEdit=1, fsize=11, frame=0, valueColor=(65535, 0, 0)
	Button makeCurrGraphNotSDP win=DotPanel, pos={280, 30}, size={105, 17}, title="Make Not Scatter Dot", fsize=9, proc=removeSDPProc, disable=2
	
	TitleBox selectWavesTitle win=DotPanel, fsize=13, pos={10,40}, size={panelWth-20,20}, title="Select Waves", frame=0
	ListBox selectWaves win=DotPanel, pos={10, 60}, size={panelWth-20, listboxHt}, fsize=11
	MakeListIntoWaveSelector("DotPanel", "selectWaves", listoptions="DIMS:1")
	
	Button addButton win=DotPanel, pos={panelWth/2-120 , listboxHt+69}, size={100, 20}, title="Add", proc=addButtonProc
	Button removeButton win=DotPanel, pos={panelWth/2+20, listboxHt+69}, size={100, 20}, title="Remove", proc=removeButtonProc
	
	TitleBox selectedWavesTitle win=DotPanel, fsize=13, pos={10, listBoxHt+90}, size={246,20}, title="Selected Waves", frame=0
	ListBox selectedWaves win=DotPanel, pos={10, listBoxHt+110}, size={panelWth-20, listboxHt-40}, fsize=11, listWave=selectedWaves
//	ListBox selectedWaves win=DotPanel, pos={10, listBoxHt+110}, size={panelWth-20, listboxHt}, fsize=11, listWave=selectedWaves
	ListBox selectedWaves win=DotPanel, selWave=selectedWavesSelected, mode=3
	
	Button doItButton win=DotPanel, pos={30, panelHt-30}, size={100, 20}, fsize=14, title="Do It", proc=doItButtonProc
	Button helpButton win=DotPanel, pos={panelWth/2-35, panelHt-30}, size={70, 20}, title="Help", proc=HelpProc
	Button cancelButton win=DotPanel, pos={panelWth-130, panelHt-30}, size={100, 20}, fsize=14, title="Cancel", proc=cancelButtonProc
	
	GroupBox optionsBox win=DotPanel, pos={10, optionsY-5}, size={panelWth-20, optionsHt}, fsize=13, title="Options"

	SetVariable markerSizeSetVar win=DotPanel, pos={15, optionsY+23}, size={optionsLeftCol, 20}, fsize=11, title="Marker Size", limits={1, 200, 1}
	SetVariable nBinsSetVar win=DotPanel, pos={15, optionsY+41}, size={optionsLeftCol, 20}, fsize=11, title="Number of Bins:", limits={2, 200, 1}, proc=nBinsSetVarProc
	
	Checkbox usePredefinedBins win=DotPanel, pos={15, optionsY+122}, size={panelWth-optionsLeftCol-60, 20}, fsize=11; DelayUpdate
	Checkbox usePredefinedBins win=DotPanel, title="Use Wave for Bin Boundaries", proc=predefinedBinsProc
	TitleBox binWavePathTitle win=DotPanel, pos={20, optionsY+139}, size={150, 20}, fsize=11, frame=0, title="Bin Boundaries Wave:"
	SetVariable binWavePathSetVar win=DotPanel, pos={15, optionsY+154}, size={panelWth/2-20, 20}, fsize=11, title=" "
	MakeSetVarIntoWSPopupButton("DotPanel", "binWavePathSetVar", "coordinateGlobalAndLocalBinWave", GetDataFolder(1, pkgDFR)+"globalBinWavePath", content=WMWS_Waves)
	Button saveBinWaveAs win=DotPanel, pos={25, optionsY+177}, size={140, 20}, fsize=12, title="Save Bin Wave As...", proc=saveBinWaveAsProc 

	Checkbox useTrueYCheck win=DotPanel, pos={15, optionsY+59}, size={panelWth-optionsLeftCol-60, 20}, fsize=11, title="Use True Y Location"
	Checkbox useLogScaleCheck win=DotPanel, pos={15, optionsY+77}, size={optionsLeftCol, 20}, fsize=11, title="Use Log Y Axis"
	Checkbox showBinsCheck win=DotPanel, pos={15, optionsY+95}, size={optionsLeftCol, 20}, fsize=11, title="Show Bins"
	
	Checkbox showMeanYCheck win=DotPanel, pos={panelWth-160, optionsY+23}, size={panelWth-optionsLeftCol-60, 20}, fsize=11, title="Show Mean Values", proc=showMeansProc
	TitleBox meanYBarWidthTitle win=DotPanel, pos={panelWth-143, optionsY+39}, size={80,20}, fsize=11, frame=0, title="Mean Value Bar Width:"
	Checkbox meanValsWidthAutoCheck win=DotPanel, mode=1, pos={panelWth-143, optionsY+56}, size={40, 20}, fsize=11, title="Auto", proc=meanValsTypeProc
	Checkbox meanValsWidthTypeCheck win=DotPanel, mode=1, pos={panelWth-143, optionsY+74}, size={60, 20}, fsize=11, title="Manual:", proc=meanValsTypeProc
	SetVariable meanValsWidthPercent win=DotPanel, pos={panelWth-85, optionsY+72}, size={65, 20}, fsize=11, title="%", limits={0,100,1}
	
	Checkbox showErrBars win=DotPanel, pos={panelWth-160, optionsY+96}, size={panelWth-optionsLeftCol-60, 20}, fsize=11, title="Show Error Bars", proc=showErrBarsProc
	Checkbox useStdDev win=DotPanel, mode=1, pos={panelWth-143, optionsY+114}, size={panelWth-optionsLeftCol-60, 20}, fsize=10, title="Use Std Dev", proc=errBarsTypeProc
	SetVariable nFactorsSetVar win=DotPanel, pos={panelWth-125, optionsY+132}, size={panelWth-optionsLeftCol-120, 18}, fsize=10, title="Factor:", limits={0, inf, 1}
	Checkbox useStdErr win=DotPanel, mode=1, pos={panelWth-143, optionsY+150}, size={panelWth-optionsLeftCol-60, 20}, fsize=10, title="Use Std Err", proc=errBarsTypeProc
	Checkbox useOwnWave win=DotPanel, mode=1, pos={panelWth-143, optionsY+168}, size={panelWth-optionsLeftCol-60, 20}, fsize=10, title="User Wave(s)", proc=errBarsTypeProc
	
	TitleBox ErrBarWidthTitle win=DotPanel, pos={panelWth-143, optionsY+186}, size={70,20}, fsize=11, frame=0, title="Bar Width:"
	Checkbox ErrBarWidthAutoCheck win=DotPanel, mode=1, pos={panelWth-143, optionsY+202}, size={40, 20}, fsize=11, title="Auto", proc=ErrBarWidthProc
	Checkbox ErrBarWidthTypeCheck win=DotPanel, mode=1, pos={panelWth-143, optionsY+220}, size={60, 20}, fsize=11, title="Manual:", proc=ErrBarWidthProc
	SetVariable ErrBarWidthPercent win=DotPanel, pos={panelWth-85, optionsY+218}, size={65, 20}, fsize=11, title="%", limits={0,100,1}	
	
	/// auto-calc values
	PopupMenu markerOverlapPopUp win=DotPanel, pos={15, optionsY+210}, size={optionsLeftCol, 20}, fsize=11, title="Marker Spacing"; DelayUpdate
	PopupMenu markerOverlapPopUp win=DotPanel, value="Spread;Tight;Overlap;", proc=setMarkerOverlap	
	Checkbox staticParamsCheck win=DotPanel, pos={15, optionsY+230}, size={panelWth-optionsLeftCol-60, 20}, fsize=11, title="Auto-Calc", proc=autoChecksProc
	PopupMenu binNMarkerPopUp win=DotPanel, pos={30, optionsY+245}, size={200, 20}, fsize=11, title="Auto-Calc Type", proc=binNMarkerProc; DelayUpdate
	PopupMenu binNMarkerPopUp win=DotPanel, value="Num Bins;Marker Size;Num Bins then Marker Size"
	
	/// sets up the control variables & links for the above 
	updateControlLinks()
 
	////////// Set up resizing userdata //////////
	PopupMenu selectGraph,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,A.!!#;-!!#A<!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#`-A7TLfzz"
	PopupMenu selectGraph,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	PopupMenu selectGraph,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

	SetVariable currentGraph,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,GX!!#;-!!#AW!!#<Hz!!#`-A7TLfzzzzzzzzzzzzzz!!#o2B4uAezz"
	SetVariable currentGraph,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	SetVariable currentGraph,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

	Button makeCurrGraphNotSDP,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,HG!!#=S!!#@6!!#<8z!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	Button makeCurrGraphNotSDP,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	Button makeCurrGraphNotSDP,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#u:Duafnzzzzzzzzzzzzzz!!!"

	TitleBox selectWavesTitle,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,A.!!#>.!!#?a!!#<@z!!#](Aon#azzzzzzzzzzzzzz!!#](Aon\"Qzz"
	TitleBox selectWavesTitle,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	TitleBox selectWavesTitle,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"

	ListBox selectWaves,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,A.!!#?)!!#C#!!#@^z!!#](Aon#azzzzzzzzzzzzzz!!#o2B4uAezz"
	ListBox selectWaves,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	ListBox selectWaves,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#AtDKKH1zzzzzzzzzzzzzz!!!"

	Button addButton,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,EZ!!#AQ!!#@,!!#<Xz!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	Button addButton,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#AtDKKH1zzzzzzzzzzz"
	Button addButton,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#AtDKKH1zzzzzzzzzzzzzz!!!"

	Button removeButton,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,Gl!!#AQ!!#@,!!#<Xz!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	Button removeButton,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#AtDKKH1zzzzzzzzzzz"
	Button removeButton,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#AtDKKH1zzzzzzzzzzzzzz!!!"

	TitleBox selectedWavesTitle,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,A.!!#Af!!#@*!!#<@z!!#](Aon#azzzzzzzzzzzzzz!!#](Aon#azz"
	TitleBox selectedWavesTitle,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#AtDKKH1zzzzzzzzzzz"
	TitleBox selectedWavesTitle,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#AtDKKH1zzzzzzzzzzzzzz!!!"

	ListBox selectedWaves,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,A.!!#B%!!#C#!!#?cz!!#](Aon#azzzzzzzzzzzzzz!!#o2B4uAezz"
	ListBox selectedWaves,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#AtDKKH1zzzzzzzzzzz"
	ListBox selectedWaves,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	Button doItButton,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,CT!!#D(J,hpW!!#<Xz!!#](Aon#azzzzzzzzzzzzzz!!#](Aon\"Qzz"
	Button doItButton,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	Button doItButton,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	Button helpButton,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,G5!!#D(J,hop!!#<Xz!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	Button helpButton,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	Button helpButton,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	Button cancelButton,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,HB!!#D(J,hpW!!#<Xz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	Button cancelButton,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	Button cancelButton,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	GroupBox optionsBox,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,A.!!#B\\!!#C#!!#BCJ,fQL!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
	GroupBox optionsBox,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	GroupBox optionsBox,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	SetVariable markerSizeSetVar,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,B)!!#Bj!!#A9!!#<Hz!!#](Aon\"Qzzzzzzzzzzzzzz!!#`-A7TLfzz"
	SetVariable markerSizeSetVar,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	SetVariable markerSizeSetVar,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	SetVariable nBinsSetVar,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,B)!!#Bs!!#A9!!#<Hz!!#](Aon\"Qzzzzzzzzzzzzzz!!#`-A7TLfzz"
	SetVariable nBinsSetVar,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	SetVariable nBinsSetVar,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	CheckBox usePredefinedBins,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,B)!!#CFJ,hqd!!#<(z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon#azz"
	CheckBox usePredefinedBins,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	CheckBox usePredefinedBins,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	TitleBox binWavePathTitle,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,BY!!#CO!!#@H!!#<(z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon#azz"
	TitleBox binWavePathTitle,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	TitleBox binWavePathTitle,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	SetVariable binWavePathSetVar,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,B)!!#CVJ,hqn!!#<Hz!!#](Aon\"Qzzzzzzzzzzzzzz!!#`-A7TLfzz"
	SetVariable binWavePathSetVar,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	SetVariable binWavePathSetVar,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	Button PopupWS_Button0,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,GR!!#CVJ,hm.!!#<8z!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	Button PopupWS_Button0,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	Button PopupWS_Button0,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	Button saveBinWaveAs,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,C,!!#Cb!!#@p!!#<Xz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	Button saveBinWaveAs,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	Button saveBinWaveAs,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	CheckBox useTrueYCheck,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,B)!!#C'!!#@^!!#<(z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	CheckBox useTrueYCheck,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	CheckBox useTrueYCheck,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	CheckBox useLogScaleCheck,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,B)!!#C0!!#@&!!#<(z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	CheckBox useLogScaleCheck,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	CheckBox useLogScaleCheck,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	CheckBox showBinsCheck,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,B)!!#C9!!#?I!!#<(z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	CheckBox showBinsCheck,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	CheckBox showBinsCheck,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	CheckBox showMeanYCheck,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,H+!!#Bj!!#@L!!#<(z!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	CheckBox showMeanYCheck,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	CheckBox showMeanYCheck,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	TitleBox meanYBarWidthTitle,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,H;J,hsH!!#@T!!#<(z!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	TitleBox meanYBarWidthTitle,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	TitleBox meanYBarWidthTitle,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	CheckBox meanValsWidthAutoCheck,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,H;J,hsPJ,hni!!#<(z!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	CheckBox meanValsWidthAutoCheck,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	CheckBox meanValsWidthAutoCheck,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	CheckBox meanValsWidthTypeCheck,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,H;J,hsYJ,hoL!!#<(z!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	CheckBox meanValsWidthTypeCheck,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	CheckBox meanValsWidthTypeCheck,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	SetVariable meanValsWidthPercent,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,HXJ,hsXJ,hof!!#<Hz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	SetVariable meanValsWidthPercent,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	SetVariable meanValsWidthPercent,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	CheckBox showErrBars,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,H+!!#C9J,hp[!!#<(z!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	CheckBox showErrBars,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	CheckBox showErrBars,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	CheckBox useStdDev,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,H;J,hsmJ,hp)!!#<(z!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	CheckBox useStdDev,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	CheckBox useStdDev,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	SetVariable nFactorsSetVar,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,HDJ,ht!J,hpk!!#<8z!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	SetVariable nFactorsSetVar,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	SetVariable nFactorsSetVar,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	CheckBox useStdErr,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,H;J,ht*J,hot!!#<(z!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	CheckBox useStdErr,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	CheckBox useStdErr,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	CheckBox useOwnWave,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,H;J,ht3J,hp5!!#<(z!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	CheckBox useOwnWave,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	CheckBox useOwnWave,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	TitleBox ErrBarWidthTitle,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,H;J,ht;^]6]+!!#<(z!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	TitleBox ErrBarWidthTitle,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	TitleBox ErrBarWidthTitle,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	CheckBox ErrBarWidthAutoCheck,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,H;J,ht?^]6\\T!!#<(z!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	CheckBox ErrBarWidthAutoCheck,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	CheckBox ErrBarWidthAutoCheck,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	CheckBox ErrBarWidthTypeCheck,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,H;J,htD5QF,a!!#<(z!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	CheckBox ErrBarWidthTypeCheck,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	CheckBox ErrBarWidthTypeCheck,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	SetVariable ErrBarWidthPercent,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,HXJ,htC^]6]Q!!#<Hz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	SetVariable ErrBarWidthPercent,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	SetVariable ErrBarWidthPercent,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	PopupMenu markerOverlapPopUp,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,B)!!#Ck^]6_3!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	PopupMenu markerOverlapPopUp,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	PopupMenu markerOverlapPopUp,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	CheckBox staticParamsCheck,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,B)!!#Cp^]6][!!#<(z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	CheckBox staticParamsCheck,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	CheckBox staticParamsCheck,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	PopupMenu binNMarkerPopUp,win=DotPanel,userdata(ResizeControlsInfo)= A"!!,CT!!#CtJ,hrlJ,hm.z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	PopupMenu binNMarkerPopUp,win=DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#?(FEDG<zzzzzzzzzzz"
	PopupMenu binNMarkerPopUp,win=DotPanel,userdata(ResizeControlsInfo) += A"zzz!!#?(FEDG<zzzzzzzzzzzzzz!!!"

	SetWindow DotPanel,hook(ResizeControls)=ScatterDotPlot#ResizeControls#ResizeControlsHook
	SetWindow DotPanel,userdata(ResizeControlsInfo)= A"!!*'\"z!!#C-!!#D0zzzzzzzzzzzzzzzzzzzzz"
	SetWindow DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzzzzzzzz"
	SetWindow DotPanel,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzz!!!"
End

//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// Controls /////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////

//// Add waves from top listbox to bottom listbox action procedure
Function addButtonProc(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	if (B_Struct.eventCode == 2) // mouse up
		DFREF pkgDFR = WMGetScatterDotPlotDFR()
		DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
		
		SVAR graphName = pkgDFR:currentGraphName
		
		String waveNames = WS_SelectedObjectsList("DotPanel", "selectWaves")
		Wave /T selectedNames = graphPkgDFR:selectedWaveNames
		Wave /B/U selectedNamesSelected = graphPkgDFR:selectedWaveSelected
		
		Variable i, j, nWavesIn = ItemsInList(waveNames)
		Variable nSelectedWaves = numpnts(selectedNames)
		
		String addList=""
		for (i=0; i<nWavesIn; i+=1)
			String currentName = StringFromList(i, waveNames)
			
			// be sure the wave isn't already selected
			Variable notFound = 1
			for (j=0; j<nSelectedWaves && notFound; j+=1)
				if (!cmpStr(currentName, selectedNames[j]))
					notFound = 0
				endif
			endfor
			
			if (notFound)
				addList += currentName+";"
			endif
		endfor
		
		Variable nAddWaveNames = ItemsInList(addList)
		Redimension /N=(nSelectedWaves+nAddWaveNames) selectedNames, selectedNamesSelected
				
		for (i=0; i<nAddWaveNames; i+=1)
			selectedNames[i+nSelectedWaves] = StringFromList(i, addList)
		endfor
	endif
End

//// remove waves from bottom listbox
Function removeButtonProc(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	if (B_Struct.eventCode==2) //mouse up
		DFREF pkgDFR = WMGetScatterDotPlotDFR()
		DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
		
		SVAR graphName = pkgDFR:currentGraphName
		
		Wave /T selectedNames = graphPkgDFR:selectedWaveNames
		Wave /B/U selectedNamesSelected = graphPkgDFR:selectedWaveSelected
		
		Variable i, nSelectedWaves = numpnts(selectedNames)	
		Variable startRemove, nRemoved
		
		// this code assumes ListBox mode=3, which means only consecutive rows can be selected
		for (i=0; i<nSelectedWaves; i+=1)
			if (selectedNamesSelected[i])
				if (nRemoved)
					nRemoved += 1
				else
					nRemoved = 1
					startRemove = i
				endif
			endif
		endfor
		
		if (nRemoved)
			DeletePoints startRemove, nRemoved, selectedNames, selectedNamesSelected
		endif
	endif
End

Function helpProc(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	if (B_Struct.eventCode==2) //mouse up
		DisplayHelpTopic "Scatter Dot Plot Panel"
	endif
End

Function removeSDPProc(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	if (B_Struct.eventCode==2) //mouse up
		DFREF pkgDFR = WMGetScatterDotPlotDFR()
		DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
		
		SVAR graphName = pkgDFR:currentGraphName
		ControlInfo /W=DotPanel selectGraph 
		if (!CmpStr(S_Value, "New Graph") || !CmpStr(graphName, newGraphTag))
			return 0
		endif
		
		Variable i
		
		///// Remove all the "counts_" named traces whose waves are in the graphPkgDFR from the current graph./////	
		String countTracesOnGraph = ListMatch(TraceNameList(graphName, ";", 1), "counts_*")+ListMatch(TraceNameList(graphName, ";", 1), "'counts_*")
		Variable nCTOGtoRemove = ItemsInList(countTracesOnGraph)
		for (i=0; i<nCTOGtoRemove; i+=1) 
			// - get the wave reference
			String currTrace = StringFromList(i, countTracesOnGraph)
			Wave /Z currWave = TraceNameToWaveRef(graphName, currTrace)
			// - if it is not in the graphPkgDFR don't remove it 	
			if (WaveExists(currWave))
				DFREF waveDFR = GetWavesDataFolderDFR(currWave)
				if (DataFolderRefsEqual(waveDFR, graphPkgDFR)) 
					RemoveFromGraph /Z/W=$graphName $currTrace
				endif
			endif
		endfor
		
		// Remove the bin bounds waves, if they exist
		Wave /Z binBounds = TraceNameToWaveRef(graphName, "binBounds")
		if (waveExists(binBounds))
			DFREF waveDFR = GetWavesDataFolderDFR(currWave)
			if (DataFolderRefsEqual(waveDFR, graphPkgDFR)) 
				RemoveFromGraph /Z/W=$graphName binBounds
			endif
		endif

		// remove the category axis label if there are any traces left
		if (ItemsInList(TraceNameList(graphName, ";", 1)))
			ModifyGraph /W=$graphName userticks(bottom)=0
		endif
			
		// set the variable to ensure there will be no update
		Variable /G $("root:Packages:WMScatterDotPlot:"+graphName+":WMisScatterDot")=0
		
	endif
End

Function doItButtonProc(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	if (B_Struct.eventCode==2) //mouse up
		DFREF pkgDFR = WMGetScatterDotPlotDFR()
		DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
		
		SVAR graphName = pkgDFR:currentGraphName
		
		Wave /T selectedNames = graphPkgDFR:selectedWaveNames
		Variable i, nSelectedWaves = numpnts(selectedNames)
		
		ControlInfo /W=DotPanel selectGraph 
		String selGraphText = S_Value
		
		if (!CmpStr(S_Value, "New Graph") || !CmpStr(graphName, newGraphTag))
			graphName = UniqueName("Graph", 6, 0)
			copyControls("root:Packages:WMScatterDotPlot:"+PossiblyQuoteName(newGraphTag), "root:Packages:WMScatterDotPlot:"+PossiblyQuoteName(graphName))
		endif
		
		DoWindow /F $graphName
		if (!V_Flag)
			Display /N=$graphName	

			DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()			
			NVAR doAutoAdjust = graphPkgDFR:doAutoAdjust
			
			SetWindow $graphName, hook(WMScatterDotPlotGraph)=WMScatterDotPlotGraph
		endif
		
		Variable /G $("root:Packages:WMScatterDotPlot:"+graphName+":WMisScatterDot")=1
		
		NVAR /Z dependenciesVar = graphPkgDFR:$"dependenciesVar"
		if (!NVAR_exists(dependenciesVar))
			Variable /G graphPkgDFR:$"dependenciesVar"
			NVAR dependenciesVar = graphPkgDFR:$"dependenciesVar"
		endif
 
 		// JW 190708 the function updateTopGraph() can change the plotted waves and that can trigger the dependency
 		// if it already exists. So clear the dependency, call updateTopGraph(), then call setFormula to set up
 		// the needed dependency.
		SetFormula dependenciesVar, ""
		updateTopGraph()

		String formulaStr = "ScatterDotPlot#sourceDataChangedUpdate(\""+graphName+"\""

		for (i=0; i<nSelectedWaves; i+=1)		
			formulaStr += ", a"+num2str(i)+"="+selectedNames[i]
		endfor
		formulaStr += ")"
		SetFormula dependenciesVar, formulaStr
		
//		PopupMenu selectGraph win=DotPanel, popmatch="Top Graph"
		updateControlLinks()
	endif
End

Function cancelButtonProc(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	if (B_Struct.eventCode==2) //mouse up
		DoWindow /K DotPanel
	endif
End

Function applyOptionsProc(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	if (B_Struct.eventCode==2) //mouse up
		updateTopGraph()	
	endif	
End

Function SelectGraphProc(PU_Struct) : PopupMenuControl
	STRUCT WMPopupAction &PU_Struct
	
	if (PU_Struct.eventCode==2) //mouse up
		DFREF pkgDFR = WMGetScatterDotPlotDFR()
		DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
		
		SVAR graphName = pkgDFR:currentGraphName

		if (!CmpStr(PU_Struct.popStr, "New Graph"))
			graphName = newGraphTag
		else
			graphName = WinName(0, 1)
			if (!strlen(graphName))
				graphName = newGraphTag
				PopupMenu selectGraph win=DotPanel, popmatch="New Graph"
			endif
		endif
		
		updateControlLinks()
	endif
End

Function predefinedBinsProc(CB_Struct) : CheckBoxControl
	Struct WMCheckboxAction &CB_Struct
	
	if (CB_Struct.eventCode == 2) //Mouse up
		DFREF dfr = WMGetScatterDotPlotDFR()
		SVAR graphName = dfr:currentGraphName
	
		DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
		
		NVAR usePredefinedBinsWave = graphPkgDFR:usePredefinedBinsWave
		
		TitleBox binWavePathTitle win=DotPanel, disable=!usePredefinedBinsWave*2
		SetVariable binWavePathSetVar win=DotPanel, disable=!usePredefinedBinsWave*2
		SetVariable nBinsSetVar win=DotPanel, disable=usePredefinedBinsWave*2
		
		if (usePredefinedBinsWave)
			ControlInfo /W=DotPanel markerParams
			if (V_Value)
				Checkbox staticParamsCheck, win=DotPanel, value=1
				Checkbox markerParamsCheck win=DotPanel, value=0, disable=2
			endif
		endif
	endif
End

Function showMeansProc(CB_Struct) : CheckBoxControl
	Struct WMCheckboxAction &CB_Struct
	
	if (CB_Struct.eventCode == 2) //Mouse up
		DFREF dfr = WMGetScatterDotPlotDFR()
		SVAR graphName = dfr:currentGraphName
	
		DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
		
		NVAR showMeanY = graphPkgDFR:showMeanY
		
		Checkbox meanValsWidthAutoCheck win=DotPanel, disable=!showMeanY*2
		Checkbox meanValsWidthTypeCheck win=DotPanel, disable=!showMeanY*2
		SetVariable meanValsWidthPercent win=DotPanel, disable=!showMeanY*2
		TitleBox meanYBarWidthTitle win=DotPanel, disable=!showMeanY*2
	endif
End

Function meanValsTypeProc(CB_Struct) : CheckBoxControl
	STRUCT WMCheckboxAction &CB_Struct
	
	if (CB_Struct.eventCode == 2)
		DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
	
		NVAR setMeanYWidth = graphPkgDFR:setMeanYWidth	
		
		if (!CmpStr(CB_Struct.ctrlName, "meanValsWidthAutoCheck"))
			setMeanYWidth=0
		else
			setMeanYWidth=1
		endif
	
		Checkbox meanValsWidthAutoCheck win=DotPanel, value=setMeanYWidth==0
		Checkbox meanValsWidthTypeCheck win=DotPanel, value=setMeanYWidth==1
	endif
End

Function errBarWidthProc(CB_Struct) : CheckBoxControl
	STRUCT WMCheckboxAction &CB_Struct
	
	if (CB_Struct.eventCode == 2)
		DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
	
		NVAR setErrBarWidth = graphPkgDFR:setErrBarWidth	
		
		if (!CmpStr(CB_Struct.ctrlName, "ErrBarWidthAutoCheck"))
			setErrBarWidth=0
		else
			setErrBarWidth=1
		endif
	
		Checkbox ErrBarWidthAutoCheck win=DotPanel, value=setErrBarWidth==0
		Checkbox ErrBarWidthTypeCheck win=DotPanel, value=setErrBarWidth==1	
	endif
End


Function showErrBarsProc(CB_Struct) : CheckBoxControl
	Struct WMCheckboxAction &CB_Struct
	
	if (CB_Struct.eventCode == 2) //Mouse up
		DFREF dfr = WMGetScatterDotPlotDFR()
		SVAR graphName = dfr:currentGraphName
	
		DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
		
		NVAR showErrorBars = graphPkgDFR:showErrorBars
		
		Checkbox useStdDev win=DotPanel, disable=!showErrorBars*2
		Checkbox useStdErr win=DotPanel, disable=!showErrorBars*2
		SetVariable nFactorsSetVar win=DotPanel, disable=!showErrorBars*2
		Checkbox useOwnWave win=DotPanel, disable=!showErrorBars*2
		TitleBox ErrBarWidthTitle win=DotPanel, disable=!showErrorBars*2
		Checkbox ErrBarWidthAutoCheck win=DotPanel, disable=!showErrorBars*2
		Checkbox ErrBarWidthTypeCheck win=DotPanel, disable=!showErrorBars*2
		SetVariable ErrBarWidthPercent win=DotPanel, disable=!showErrorBars*2
	endif
End

Function autoChecksProc(CB_Struct) : CheckBoxControl
	STRUCT WMCheckboxAction &CB_Struct
	
	if (CB_Struct.eventCode==2) 								//mouse up
		DFREF pkgDFR = WMGetScatterDotPlotDFR()
		DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
		
		SVAR graphName = pkgDFR:currentGraphName			// update the top graph
	
		NVAR doAutoAdjust = graphPkgDFR:doAutoAdjust
		NVAR autoAdjustType= graphPkgDFR:autoAdjustType
		doAutoAdjust = CB_Struct.checked
		NVAR usePredefinedBinsWave = graphPkgDFR:usePredefinedBinsWave

		if (usePredefinedBinsWave && doAutoAdjust && autoAdjustType!=DPAdjustMarkerSizePlots) 
			autoAdjustType = DPAdjustMarkerSizePlots
		endif
		Checkbox usePredefinedBins win=DotPanel, disable=2*doAutoAdjust*(autoAdjustType!=DPAdjustMarkerSizePlots), value=usePredefinedBinsWave
		
		Checkbox staticParamsCheck win=DotPanel, value=doAutoAdjust	
	
		PopupMenu binNMarkerPopUp win=DotPanel, disable=2*!doAutoAdjust, mode=autoAdjustType
	endif
End

Function binNMarkerProc(PU_Struct) : PopupMenuControl
	STRUCT WMPopupAction &PU_Struct

	if (PU_Struct.eventCode == 2)	
		DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
		DFREF pkgDFR = WMGetScatterDotPlotDFR()
		
		SVAR graphName = pkgDFR:currentGraphName
		
		NVAR autoAdjustType= graphPkgDFR:autoAdjustType
		NVAR usePredefinedBinsWave = graphPkgDFR:usePredefinedBinsWave		
			
		strswitch (PU_Struct.popStr)
			case "Num Bins":
				autoAdjustType = DPAdjustNBinsPlots
				TitleBox binWavePathTitle win=DotPanel, disable=2
				usePredefinedBinsWave=0
				Checkbox usePredefinedBins win=DotPanel, disable=2
				break
			case "Marker Size":
				autoAdjustType = DPAdjustMarkerSizePlots 	
				TitleBox binWavePathTitle win=DotPanel, disable=0
				Checkbox usePredefinedBins win=DotPanel, disable=0
				break
			case "Num Bins then Marker Size":	
				autoAdjustType = DPAdjustNBinsPlots + DPAdjustMarkerSizePlots
				TitleBox binWavePathTitle win=DotPanel, disable=2
				usePredefinedBinsWave=0				
				Checkbox usePredefinedBins win=DotPanel, disable=2
				break
		endswitch	
	endif
End

Function setMarkerOverlap(PU_Struct) : PopupMenuControl
	STRUCT WMPopupAction &PU_Struct

	if (PU_Struct.eventCode == 2)					//mouse up
		DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
		NVAR markerSpread = graphPkgDFR:markerSpread		

		strswitch (PU_Struct.popStr)
			case "Spread":
				markerSpread = DPSpreadMarkers
				break
			case "Tight":
				markerSpread = DPTightMarkers
				break
			case "Overlap":
				markerSpread = DPOverlapMarkers
				break				
		endswitch
	endif
End

Function nBinsSetVarProc(SV_Struct) : SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct
	
	if (SV_Struct.eventCode >= 2) // anything but being killed or mouse up
		DFREF dfr = WMGetScatterDotPlotDFR()
//		SVAR graphName = dfr:currentGraphName
	
		DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
	
		NVAR nBins = graphPkgDFR:nBins
		nBins = floor(nBins)
		
		ControlUpdate /W=DotPlot nBinsSetVar
	endif
End

Function errBarsTypeProc(CB_Struct) : CheckBoxControl
	STRUCT WMCheckboxAction &CB_Struct
	
	if (CB_Struct.eventCode == 2)
	
		DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
	
		NVAR errBarType = graphPkgDFR:errBarType	
	
		strswitch (CB_Struct.ctrlName)
			case "useStdDev":
				errBarType = DPStdDev
				break
			case "useStdErr":
				errBarType = DPStdErr
				break
			case "useOwnWave":
				errBarType = DPWaveDef

				launchCustomErrBarDialog()

				break
		endswitch

		Checkbox useStdDev win=DotPanel, value=errBarType==DPStdDev
		Checkbox useStdErr win=DotPanel, value=errBarType==DPStdErr
		Checkbox useOwnWave win=DotPanel, value=errBarType==DPWaveDef
	endif
End

Function launchCustomErrBarDialog()
	DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
	
	SVAR errBarPosWaveName = graphPkgDFR:errBarPosWaveName
	if (!strlen(errBarPosWaveName))
		errBarPosWaveName = "(no selection)"
	endif
	SVAR errBarNegWaveName = graphPkgDFR:errBarNegWaveName
	if (!strlen(errBarNegWaveName))
		errBarNegWaveName = "(no selection)"
	endif

	// MakeSetVarIntoWSPopupButton initialSelection argument won't work with added selectable strings
	// Have to store the initial values and add them after PopupWS_AddSelectableString has been called
	String tmpPosName = errBarPosWaveName
	String tmpNegName = errBarNegWaveName

	String PosWaveNameStrPath = GetDataFolder(1, graphPkgDFR)+"errBarPosWaveName"
	String NegWaveNameStrPath = GetDataFolder(1, graphPkgDFR)+"errBarNegWaveName"
			
	DoWindow /F SDPSelectWavesPanel
	if (V_Flag!=0)
		return 0
 	endif

	GetWindow DotPanel, wsize
			
	NewPanel /N=SDPSelectWavesPanel /W=(V_Left, V_Top, V_Left+295, V_Top+150) /K=1 as "Select Waves..."

	SetVariable setErrBarPosSource win=SDPSelectWavesPanel, pos={10, 20}, size={255, 24}, fixedSize=1, value=errBarPosWaveName, title="+ Err Bar Wave"; DelayUpdate
	MakeSetVarIntoWSPopupButton("SDPSelectWavesPanel", "setErrBarPosSource", "", PosWaveNameStrPath, initialSelection=errBarPosWaveName, content=WMWS_Waves)
	PopupWS_AddSelectableString("SDPSelectWavesPanel", "setErrBarPosSource", DPNoWave)
	PopupWS_SetPopupFont("SDPSelectWavesPanel", "setErrBarPosSource", fontSize=12)
	PopupWS_SetSelectionFullPath("SDPSelectWavesPanel", "setErrBarPosSource", tmpPosName)

	SetVariable setErrBarNegSource win=SDPSelectWavesPanel, pos={10, 50}, size={255, 24}, fixedSize=1, value=errBarNegWaveName, title="- Err Bar Wave"; DelayUpdate
	MakeSetVarIntoWSPopupButton("SDPSelectWavesPanel", "setErrBarNegSource", "", NegWaveNameStrPath, initialSelection=errBarNegWaveName, content=WMWS_Waves)
	PopupWS_AddSelectableString("SDPSelectWavesPanel", "setErrBarNegSource", DPNoWave)
	PopupWS_AddSelectableString("SDPSelectWavesPanel", "setErrBarNegSource", DPSameWave)
	PopupWS_SetPopupFont("SDPSelectWavesPanel", "setErrBarNegSource", fontSize=12)
	PopupWS_SetSelectionFullPath("SDPSelectWavesPanel", "setErrBarNegSource", tmpNegName)

	Button saveBinDoItButton win=SDPSelectWavesPanel, pos={30, 100}, size={100, 20}, title="Do It", proc=selectWavesDoItButtonProc
	Button saveBinCancelButton win=SDPSelectWavesPanel, pos={160, 100}, size={100, 20}, title="Cancel", proc=selectWavesCancelButtonProc
End

Function selectWavesDoItButtonProc(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct 

	if (B_Struct.eventCode==2)		//mouse up
		DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
		
		SVAR errBarPosWaveName = graphPkgDFR:errBarPosWaveName
		SVAR errBarNegWaveName = graphPkgDFR:errBarNegWaveName
		SVAR errBarWaveNamesDisplay = graphPkgDFR:errBarWaveNamesDisplay
		
		errBarWaveNamesDisplay = ParseFilePath(0, errBarPosWaveName, ":", 1, 0)
		if (CmpStr(errBarNegWaveName, DPNoWave) && CmpStr(errBarNegWaveName, DPSameWave))
			errBarWaveNamesDisplay += ":"+ParseFilePath(0, errBarNegWaveName, ":", 1, 0)
		endif
		
//		TitleBox currSelectedWaves win=DotPanel, variable=errBarWaveNamesDisplay
		
		DoWindow /K /W=SDPSelectWavesPanel SDPSelectWavesPanel		
	endif
End

Function selectWavesCancelButtonProc(B_Struct) : ButtonControl
	STRUCT WMButtonAction & B_Struct
	
	if (B_Struct.eventCode==2) 		//mouse up
		DoWindow /K /W=SDPSelectWavesPanel SDPSelectWavesPanel
	endif
End

Function updateControlLinks()
	DFREF dfr = WMGetScatterDotPlotDFR()
	SVAR graphName = dfr:currentGraphName

	ControlInfo /W=DotPanel selectGraph
	if (!CmpStr(S_Value, "New Graph"))
		graphName=newGraphTag
	else
		graphName=WinName(0, 1)
		if (!strlen(graphName))  // there is no top graph
			graphName = newGraphTag
			PopupMenu selectGraph win=DotPanel, popmatch="New Graph"
		endif
	endif

	DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
		
	NVAR markerSize = graphPkgDFR:markerSize
	NVAR usePredefinedBinsWave = graphPkgDFR:usePredefinedBinsWave
	SVAR binWavePath = graphPkgDFR:binWavePath
	NVAR useLogScale = graphPkgDFR:useLogScale
	NVAR nBins = graphPkgDFR:nBins
	NVAR useTrueY = graphPkgDFR:useTrueY
	NVAR showMeanY = graphPkgDFR:showMeanY	
	NVAR setMeanYWidth = graphPkgDFR:setMeanYWidth
	NVAR meanYWidthPercent = graphPkgDFR:meanYWidthPercent
	NVAR showBins = graphPkgDFR:showBins
	NVAR setErrBarWidth = graphPkgDFR:setErrBarWidth	
	NVAR errBarWidthPercent = graphPkgDFR:errBarWidthPercent	
	NVAR doAutoAdjust = graphPkgDFR:doAutoAdjust	
	NVAR markerSpread = graphPkgDFR:markerSpread
	NVAR autoAdjustType= graphPkgDFR:autoAdjustType
	NVAR showErrorBars = graphPkgDFR:showErrorBars		
	NVAR nStdFactor = graphPkgDFR:nStdFactor
	NVAR errBarType = graphPkgDFR:errBarType
	SVAR errBarPosWaveName = graphPkgDFR:errBarPosWaveName
	SVAR errBarNegWaveName = graphPkgDFR:errBarNegWaveName
	SVAR errBarWaveNamesDisplay = graphPkgDFR:errBarWaveNamesDisplay

	Wave /T/Z selectedWaveNames = graphPkgDFR:selectedWaveNames
	Wave /B/U selectedWaveSelected = graphPkgDFR:selectedWaveSelected

	/// update the global bin boundaries wave that is the variable for the panel SetVariable binWavePathSetVar
	SVAR globalBinWavePath = dfr:globalBinWavePath
	globalBinWavePath = binWavePath
	
	SetVariable markerSizeSetVar win=DotPanel, value=markerSize
		
	Checkbox usePredefinedBins win=DotPanel, variable=usePredefinedBinsWave	
	Checkbox useLogScaleCheck win=DotPanel, variable=useLogScale
	
	TitleBox binWavePathTitle win=DotPanel, disable=!usePredefinedBinsWave*2
	SetVariable binWavePathSetVar win=DotPanel, disable=!usePredefinedBinsWave*2
	SetVariable nBinsSetVar win=DotPanel, variable=nBins, disable=usePredefinedBinsWave*2
	
	Checkbox showErrBars win=DotPanel, variable=showErrorBars
	Checkbox useStdDev win=DotPanel, value=errBarType==DPStdDev, disable=!showErrorBars*2
	Checkbox useStdErr win=DotPanel, value=errBarType==DPStdErr, disable=!showErrorBars*2	
	SetVariable nFactorsSetVar win=DotPanel, variable=nStdFactor, disable=!showErrorBars*2
	TitleBox ErrBarWidthTitle win=DotPanel, disable=!showErrorBars*2
	Checkbox ErrBarWidthAutoCheck win=DotPanel, disable=!showErrorBars*2, value=setErrBarWidth==0
	Checkbox ErrBarWidthTypeCheck win=DotPanel, disable=!showErrorBars*2, value=setErrBarWidth==1
	SetVariable ErrBarWidthPercent win=DotPanel, disable=!showErrorBars*2	, variable=ErrBarWidthPercent
	
	Checkbox useOwnWave win=DotPanel, value=errBarType==DPWaveDef, disable=!showErrorBars*2
//	Button setCustomErrBars win=DotPanel, disable=!showErrorBars*2
//	TitleBox currSelectedWaves win=DotPanel, variable=errBarWaveNamesDisplay, disable=!(showErrorBars && errBarType==DPWaveDef)*2

	Checkbox useTrueYCheck win=DotPanel, variable=useTrueY
	Checkbox showMeanYCheck win=DotPanel, variable=showMeanY
	
	Checkbox meanValsWidthAutoCheck win=DotPanel, disable=!showMeanY*2, value=setMeanYWidth==0	
	Checkbox meanValsWidthTypeCheck win=DotPanel, disable=!showMeanY*2, value=setMeanYWidth==1
	SetVariable meanValsWidthPercent win=DotPanel, variable=meanYWidthPercent, disable=!showMeanY*2
	
	ListBox selectedWaves win=DotPanel, listWave=selectedWaveNames, selWave=selectedWaveSelected
	Checkbox showBinsCheck win=DotPanel, variable=showBins

	PopupMenu binNMarkerPopUp win=DotPanel, disable=2*!doAutoAdjust
	
	Checkbox usePredefinedBins win=DotPanel, disable=2*doAutoAdjust*(autoAdjustType!=DPAdjustMarkerSizePlots)
	if (usePredefinedBinsWave && doAutoAdjust && autoAdjustType!=DPAdjustMarkerSizePlots) 
		doAutoAdjust = 0
	endif
	Checkbox staticParamsCheck win=DotPanel, value=doAutoAdjust	

	PopupMenu binNMarkerPopUp win=DotPanel, mode=autoAdjustType, disable=2*!doAutoAdjust
		
	PopupMenu markerOverlapPopUp win=DotPanel, mode=markerSpread
	
	Button makeCurrGraphNotSDP win=DotPanel, disable=2*!CmpStr(graphName, newGraphTag)
End

Function DotPanelHook(s)
	STRUCT WMWinHookStruct &s

	Variable hookResult = 0

	switch(s.eventCode)
		case 0:				// Activate
			ControlInfo /W=DotPanel selectGraph
			if (!CmpStr(S_Value, "Top Graph"))
				DFREF dfr = WMGetScatterDotPlotDFR()
				SVAR graphName = dfr:currentGraphName

				graphName=WinName(0, 1)
				if (!strlen(graphName))  // there is no top graph
					graphName = newGraphTag
					PopupMenu selectGraph win=DotPanel, popmatch="New Graph"
				endif
			endif
		
			updateControlLinks()
			break
		case 2:				// Kill	
			Variable i, nFolders, doUnload=0
			
			DFREF sdpDFR = WMGetScatterDotPlotDFR()	
			nFolders = CountObjectsDFR(sdpDFR, 4)	
			
			if (nFolders==0 || (nFolders == 1 && !CmpStr(GetIndexedObjNameDFR(sdpDFR, 4, 0), newGraphTag)))
				doUnload=1
			endif
			
			//// Nothing in the package, so delete it and the package folder.  This will delete the dependencies too.
			if (doUnload)
				Execute/P/Q/Z "DELETEINCLUDE <Scatter Dot Plot>"
				Execute/P/Q/Z "COMPILEPROCEDURES "						

				KillDataFolder /Z sdpDFR	
			endif
				
			break	
		case 6: 			// Resize			
			DFREF pkgDFR = WMGetScatterDotPlotDFR()	
			//record panel size
			
			NVAR plotWidth = pkgDFR:ScatterDotPlotWidth
			NVAR plotHeight = pkgDFR:ScatterDotPlotHeight
			
			GetWindow DotPanel wsize
			plotWidth = V_right-V_left
			plotHeight = V_bottom-V_top			
			break			
		case 12: 			// Moved
			DFREF pkgDFR = WMGetScatterDotPlotDFR()	
			//record panel location	
			NVAR xLoc = pkgDFR:ScatterDotPlotXLoc
			NVAR yLoc = pkgDFR:ScatterDotPlotYLoc
			GetWindow DotPanel wsize
			xLoc = V_left
			yLoc = V_top			
			break
	endswitch

	return hookResult		// 0 if nothing done, else 1
End

/// There may be graphs still using the package data, 
Function unloadScatterDotPlot()
	Variable i, nFolders, doUnload=1
			
	DFREF sdpDFR = root:Packages:WMScatterDotPlot 	// can't do it with WMGetScatterDotPlotDFR() because it will create the folder if it doesn't exist!  Have to hard-code it	
	if (DataFolderRefStatus(sdpDFR))
		nFolders = CountObjectsDFR(sdpDFR, 4)	
			
		for (i=0; i<nFolders; i+=1)
			String currFolder = GetIndexedObjNameDFR(sdpDFR, 4, i)
		
			DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR(graphName=currFolder)
		
			NVAR /Z dependenciesVar = graphPkgDFR:$"dependenciesVar"
			if (NVAR_exists(dependenciesVar))
				setFormula dependenciesVar, ""
			endif
		
			// this may not be necessary unless you have the Scatter Dot Plot.ipf file open for editing :)
			if (WinType(currFolder)==1)
				SetWindow $currFolder, hook(WMScatterDotPlotGraph)=$""
			endif
		endfor					

		String newGraphFolder = GetDataFolder(1, sdpDFR)+PossiblyQuoteName(newGraphTag)	
		KillDataFolder /Z $newGraphFolder  
	
		SVAR /Z currentGraphName = sdpDFR:currentGraphName
		if (SVAR_exists(currentGraphName))
			currentGraphName = newGraphTag
		endif	
	endif

	DoWindow /K DotPanel						
	
	Execute/P/Q/Z "DELETEINCLUDE <ScatterDotPlot>"
	Execute/P/Q/Z "COMPILEPROCEDURES "	
End

//// Function to make the global binWave path string coordinate update the local string
Function coordinateGlobalAndLocalBinWave(event, wavePath, windowName, ctrlName)
	Variable event
	String wavePath, windowName, ctrlName
	
	DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
	
	String /G graphPkgDFR:binWavePath = wavePath	
End

//////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////// graph resize hook function ///////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////

Function WMScatterDotPlotGraph(s)
	STRUCT WMWinHookStruct &s

	String graphNameStr
	switch(s.eventCode)
		case 2: 	// kill
			DFREF dfr = WMGetScatterDotPlotDFR()
			graphNameStr = s.winName
			DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR(graphName=graphNameStr)
			 
			NVAR /Z dependenciesVar = graphPkgDFR:$"dependenciesVar"
			if (NVAR_exists(dependenciesVar))
				setFormula dependenciesVar, ""
			endif
	
			Variable /G graphPkgDFR:WMisScatterDot = 0
		
			break
		case 6:		// resize
			DFREF dfr = WMGetScatterDotPlotDFR()

			graphNameStr = s.winName
			DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR(graphName=graphNameStr)
		
			NVAR doAutoAdjust = graphPkgDFR:doAutoAdjust
			if (doAutoAdjust)			
				ScatterDotPlot#updateGraph(graphNameStr)
			endif
			break
		case 13:	// rename
			DFREF dfr = WMGetScatterDotPlotDFR()
			graphNameStr = s.oldWinName
			DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR(graphName=graphNameStr)
			
			if (DataFolderRefStatus(graphPkgDFR)==1) 
				NVAR /Z dependenciesVar = graphPkgDFR:$"dependenciesVar"
				if (NVAR_exists(dependenciesVar))
					setFormula dependenciesVar, ""
				endif
				
				String oldDataFolderString = GetDataFolder(0, graphPkgDFR)
				String newDataFolderString = s.winName
			
				RenameDataFolder dfr:$oldDataFolderString $newDataFolderString
				DFREF newGraphPkgDFR = WMGetScatterDotPlotGraphDFR(graphName=s.winName)	

				Wave /Z/T selectedNames = newGraphPkgDFR:selectedWaveNames
				if (WaveExists(selectedNames))
					String formulaStr = "ScatterDotPlot#sourceDataChangedUpdate(\""+newDataFolderString+"\""
					Variable	 /G 	newGraphPkgDFR:dependenciesVar
					NVAR dependenciesVar = newGraphPkgDFR:dependenciesVar
					
					Variable nSelectedWaves = dimSize(selectedNames, 0) 
					Variable i
					for (i=0; i<nSelectedWaves; i+=1)		
						formulaStr += ", a"+num2str(i)+"="+selectedNames[i]
					endfor
					formulaStr += ")"
					SetFormula dependenciesVar, formulaStr				
				endif
			endif	
			
			break
	endswitch
	
	return 0
End

//////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////// save bin panel and controls //////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////

Function saveBinWaveAsProc(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	if (B_Struct.eventCode==2) //mouse up

		// panel control variables	
		DFREF pkgDFR = WMGetScatterDotPlotDFR()	
		NVAR xLoc = pkgDFR:ScatterDotPlotXLoc
		NVAR yLoc = pkgDFR:ScatterDotPlotYLoc

		DoWindow /F SaveBinWaveAsPanel
		if (V_Flag)
			// center the panel over the DotPanel, then return
			GetWindow SaveBinWaveAsPanel wsize
			MoveWindow /W=SaveBinWaveAsPanel xLoc+20, yLoc+20, xLoc+20+V_right-V_left, yLoc+20+V_bottom-V_top		

			updateSaveBinPanel()	
			return 1
		endif
		
		NewPanel /N=SaveBinWaveAsPanel /W=(xLoc+20,yLoc+20, xLoc+410, yLoc+150) /K=1 as "Save Bin Wave As..."	
	
		SetWindow SaveBinWaveAsPanel,hook(closePopUpHook)=closePopUpHook
	
		String sbwDir = StrVarOrDefault(GetDataFolder(1, pkgDFR)+"saveBinWaveDir", GetDataFolder(0))
		String /G pkgDFR:saveBinWaveDir = sbwDir
		SVAR saveBinWaveDir = pkgDFR:saveBinWaveDir

		String wN = StrVarOrDefault(GetDataFolder(1, pkgDFR), "aBinWave")
		String /G pkgDFR:wName = wN
		SVAR wName = pkgDFR:wName
	
		SetVariable sourceWaveSetVar, win=SaveBinWaveAsPanel, pos={10, 10}, size={650, 20}, fsize=11, title="Source Wave:"; DelayUpdate
		SetVariable sourceWaveSetVar, win=SaveBinWaveAsPanel, noEdit=1, fsize=11, frame=0, valueColor=(65535, 0, 0)
	
		SetVariable setBinDir, win=SaveBinWaveAsPanel, pos={10, 35}, size={350, 20}, fsize=11, title="Target Directory:", variable=saveBinWaveDir
		MakeSetVarIntoWSPopupButton("SaveBinWaveAsPanel", "setBinDir", "", GetDataFolder(1, pkgDFR)+"saveBinWaveDir", initialSelection=GetDataFolder(0), content=WMWS_DataFolders)
		SetVariable binWaveName win=SaveBinWaveAsPanel, pos={10, 60}, size={350, 20}, fsize=11, title="Target Wave Name:", variable=wName
	
		Button saveBinDoItButton win=SaveBinWaveAsPanel, pos={30, 100}, size={100, 20}, fsize=14, title="Do It", proc=saveBinDoItButtonProc
		Button saveBinCancelButton win=SaveBinWaveAsPanel, pos={270, 100}, size={100, 20}, fsize=14, title="Cancel", proc=saveBinCancelButtonProc

		updateSaveBinPanel()
	endif
End

Function updateSaveBinPanel()
	DFREF pkgDFR = WMGetScatterDotPlotDFR()	
	DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
	
	//// source wave name for display ////
	NVAR usePredefinedBinsWave = graphPkgDFR:usePredefinedBinsWave
	
	String sourceWaveName 
	if (!usePredefinedBinsWave)
		sourceWaveName = GetDataFolder(1, graphPkgDFR)+"ScatterDotPlotBinBounds (default)" 
	else
		sourceWaveName = PopupWS_GetSelectionFullPath("DotPanel", "binWavePathSetVar") //binWavePath
	endif
	
	//// get target wave name ////
	String sbwDir = StrVarOrDefault(GetDataFolder(1, pkgDFR)+"saveBinWaveDir", GetDataFolder(0))
	String /G pkgDFR:saveBinWaveDir = sbwDir
	SVAR saveBinWaveDir = pkgDFR:saveBinWaveDir

	String wN = StrVarOrDefault(GetDataFolder(1, pkgDFR), "aBinWave")
	String /G pkgDFR:wName = wN
	SVAR wName = pkgDFR:wName
	
	SetVariable sourceWaveSetVar, win=SaveBinWaveAsPanel, value=_STR:sourceWaveName
End

Function closePopUpHook(s)
	STRUCT WMWinHookStruct &s

	switch(s.eventCode)
		case 0:				// Activate			
			DotPanelHook(s)	// update the Dot Panel in case user clicked from graph to this panel - Note that this might be dangerous if the DotPanelHook activate portion changes
			updateSaveBinPanel()
			break
	endswitch
End

Function saveBinDoItButtonProc(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	if (B_Struct.eventCode==2) 								//mouse up
		DFREF pkgDFR = WMGetScatterDotPlotDFR()
		DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
		
		SVAR saveBinWaveDir = pkgDFR:saveBinWaveDir
		SVAR wName = pkgDFR:wName
		
		if (strlen(wName))
			if (!DataFolderExists(saveBinWaveDir))
				saveBinWaveDir = "root:"
			endif		
			
			SVAR graphName = pkgDFR:currentGraphName

			NVAR usePredefinedBinsWave = graphPkgDFR:usePredefinedBinsWave

			String sourceWaveName, targetWaveName=ReplaceString("::", saveBinWaveDir+":"+PossiblyQuoteName(wName), ":")
			if (!usePredefinedBinsWave)
				sourceWaveName = GetDataFolder(1, graphPkgDFR)+"ScatterDotPlotBinBounds"
			else
				sourceWaveName = PopupWS_GetSelectionFullPath("DotPanel", "binWavePathSetVar")//binWavePath
			endif
		
			Wave /Z sourceWave = $sourceWaveName
			if (!waveExists(sourceWave))
				DoAlert /T="Bin Wave Error" 0, "Error: bin wave "+sourceWaveName+" does not exist.  Select a valid bin wave and try again."
			else
				Wave /Z targetWave = $targetWaveName
				if (waveExists(targetWave))
					DoAlert /T="Target Wave Exists Warning", 1, "Warning: target wave "+targetWaveName+" already exists.  Overwrite it?"
					if (V_flag==2)
						return -1
					endif
				endif
				
				Duplicate /O sourceWave $targetWaveName
			endif
		endif
		
		DoWindow /K /W=SaveBinWaveAsPanel SaveBinWaveAsPanel
	endif
End

Function saveBinCancelButtonProc(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	if (B_Struct.eventCode==2) //mouse up
		DoWindow /K /W=SaveBinWaveAsPanel SaveBinWaveAsPanel
	endif
End


Function selectCustomWaveButton(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	if (B_Struct.eventCode==2) //mouse up
		launchCustomErrBarDialog()
	endif
End
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// Main Functions ////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////

Function updateTopGraph()
	DFREF pkgDFR = WMGetScatterDotPlotDFR()
	SVAR graphName = pkgDFR:currentGraphName
	
	// Make sure currentGraphName has been properly updated
	String listOfGraphName = WinList(graphName, ";", "")
	if (strlen(listOfGraphName))
		updateGraph(graphName)
	endif
End

// assumes the currentGraph is correctly set

Function updateGraph(graphName)
	String graphName  
	
	//// get package folders and the top graph ////
	DFREF pkgDFR = WMGetScatterDotPlotDFR()
	DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR(graphName=graphName)

	// Make sure the following didn't happen:
	//		a Scatter Dot Plot that was created
	//		That SDP was killed
	//		a new Graph was created and given the same name as the deleted SDP
	//		an update occurred.
	// If all that happens a non SDP can be wrongly converted to a SDP - causing gnashing of teeth and pulling of hair by the user 
	NVAR /Z isScatterDot = graphPkgDFR:WMisScatterDot
	if (!NVAR_exists(isScatterDot))
		Variable /G graphPkgDFR:WMisScatterDot = 1
		NVAR isScatterDot = graphPkgDFR:WMisScatterDot
	endif
	if (!isScatterDot) 
		return 0
	endif
	
	//// get selected waves ref and other function variables ////
	Wave /T/Z waveNames = graphPkgDFR:selectedWaveNames
	Variable nWaves= waveExists(waveNames) ? numPnts(waveNames) : 0
	Variable i, j, k, minVal, maxVal, nPnts, iBin, currPt, maxCount, dx, currCount
	String countWaveName
	
	//// get control variables ////
	NVAR markerSize = graphPkgDFR:markerSize
	NVAR usePredefinedBinsWave = graphPkgDFR:usePredefinedBinsWave
	SVAR binWavePath = graphPkgDFR:binWavePath
	NVAR useLogScale = graphPkgDFR:useLogScale
	NVAR nBins = graphPkgDFR:nBins
	if (numtype(nBins)!=0 || nBins < 2)
		nBins=2
	endif
	NVAR useTrueY = graphPkgDFR:useTrueY
	NVAR showMeanY = graphPkgDFR:showMeanY
	NVAR setMeanYWidth = graphPkgDFR:setMeanYWidth
	NVAR meanYWidthPercent = graphPkgDFR:meanYWidthPercent
	NVAR showBins = graphPkgDFR:showBins
	NVAR doAutoAdjust = graphPkgDFR:doAutoAdjust
	NVAR autoAdjustType = graphPkgDFR:autoAdjustType
	NVAR showErrorBars = graphPkgDFR:showErrorBars	
	NVAR errBarType = graphPkgDFR:errBarType
	NVAR setErrBarWidth = graphPkgDFR:setErrBarWidth	
	NVAR errBarWidthPercent = graphPkgDFR:errBarWidthPercent	
	NVAR nStdFactor = graphPkgDFR:nStdFactor
	
	//// no waves, nothing to do ////
	if (!nWaves)
		return -1
	endif
	 
	Wave /Z ScatterDotPlotBinBounds
	 
	Struct binInfoStruct binInfo
	binInfo.logScale = useLogScale
	binInfo.autoAdjustType = autoAdjustType	
	binInfo.nBins = nBins
	if (numType(binInfo.nBins))
		binInfo.nBins = 4
	endif	

	if (usePredefinedBinsWave)
		Wave /Z binInfo.binWave = $binWavePath//Wave /Z ScatterDotPlotBinBounds = $binWavePath  
		if (!waveExists(binInfo.binWave))
			DoAlert /T="Bin Wave Warning" 0, PopupWS_GetSelectionFullPath("DotPanel", "binWavePathSetVar")+" does not exist.  Dot plot will use evenly spaced bins."
			binInfo.usePredefinedBinsWave = 0
		else
			binInfo.usePredefinedBinsWave = 1
			binInfo.nBins = DimSize(binInfo.binWave,0)-1
		endif
	endif
	
	if (doAutoAdjust)
		getAutoBinWave(graphName, waveNames, binInfo)
	else
		getConstantBinWave(graphName, waveNames, binInfo)
	endif
	
	Duplicate /O binInfo.binWave, graphPkgDFR:ScatterDotPlotBinBounds
	Wave ScatterDotPlotBinBounds = graphPkgDFR:ScatterDotPlotBinBounds
	nBins = binInfo.nBins
	
	///// Remove all the removed "counts_" named waves from the current graph./////	
	String countTracesOnGraph = ListMatch(TraceNameList(graphName, ";", 1), "counts_*")+ListMatch(TraceNameList(graphName, ";", 1), "'counts_*")
	for (i=0; i<nWaves; i+=1)
		String currentWaveCountName = getSDPPackageWaveName(waveNames[i])
		countTracesOnGraph = RemoveFromList(ListMatch(countTracesOnGraph, currentWaveCountName+"*"), countTracesOnGraph)  		// remove non-liberal names
		countTracesOnGraph = RemoveFromList(ListMatch(countTracesOnGraph, "'"+currentWaveCountName+"*"), countTracesOnGraph)  	// remove liberal names
	endfor
	Variable nCTOGtoRemove = ItemsInList(countTracesOnGraph)
	for (i=0; i<nCTOGtoRemove; i+=1) 
		// - get the wave reference
		String currTrace = StringFromList(i, countTracesOnGraph)
		Wave /Z currWave = TraceNameToWaveRef(graphName, currTrace)
		// - if it is not in the graphPkgDFR don't remove it 	
		if (WaveExists(currWave))
			DFREF waveDFR = GetWavesDataFolderDFR(currWave)
			if (!DataFolderRefsEqual(waveDFR, graphPkgDFR)) 
				continue
			endif
		endif
	
		RemoveFromGraph /Z/W=$graphName $currTrace
	endfor	

	///// Remove all "counts_*" and "'counts_*" waves from the folder that are not on the graph.  
	String killList = ""
	Variable nWavesInGraphDFR = CountObjectsDFR(graphPkgDFR, 1)
	for (i=0; i<nWavesInGraphDFR; i+=1) 
		String currWaveName = GetIndexedObjNameDFR(graphPkgDFR, 1, i)
		if (StringMatch(currWaveName, "counts_*") || StringMatch(currWaveName, "'counts_*"))
			killList += currWaveName+";"
		endif 
	endfor
	for (i=0; i<ItemsInList(killList); i+=1)
			// try to kill it.  Assume that if it is on the graph it won't get deleted
		KillWaves /Z graphPkgDFR:$StringFromList(i, killList)
	endfor

	/// re-set the countTracesOnGraph list.  Will append waves that are not in this list
	countTracesOnGraph = ListMatch(TraceNameList(graphName, ";", 1), "counts_*")+ListMatch(TraceNameList(graphName, ";", 1), "'counts_*")

	Wave counts = binInfo.counts
	
	Wave /WAVE sortedSourceWaves = binInfo.sortedSourceWaves   // free wave of free waves
	Wave /WAVE sortedToSourceIndices = binInfo.sortedToSourceIndices	
	dx = binInfo.dX 
	
	//// make the tick label wave.  If the user has already assigned a custom tick wave make sure we don't push it aside.
	Variable usingCustomTickLabels = 1	
	Wave /T/Z tickWaveNames = getCustomWaveLabelsWave(graphName)	
	if (!WaveExists(tickWaveNames))
		Make /O/T/N=(nWaves) graphPkgDFR:tickWaveNames
		Wave /T tickWaveNames = graphPkgDFR:tickWaveNames
		usingCustomTickLabels=0
	endif
	
	// Set up error bar waves and report associated errors outside the loop
	
	if (showErrorBars && errBarType==DPWaveDef)
		SVAR errBarPosWaveName = graphPkgDFR:errBarPosWaveName
		SVAR errBarNegWaveName = graphPkgDFR:errBarNegWaveName
				
		Wave /Z errBarPosWave = $errBarPosWaveName
		if (!CmpStr(errBarNegWaveName, DPSameWave))
			Wave /Z errBarNegWave = $errBarPosWaveName
		else
			Wave /Z errBarNegWave = $errBarNegWaveName
		endif
		
		if (!WaveExists(errBarPosWave) || !WaveExists(errBarNegWave))
			Print "Scatter Dot Plot Warning: Error Bars set to use custom waves but valid wave(s) are not set."
		endif
		String customErrBarErrorMsg = ""
		if (WaveExists(errBarPosWave) && DimSize(errBarPosWave, 0) < nWaves)
			Print "Scatter Dot Plot Error: Custom error wave(s) do not have as many points as there are scatter dot categories."
		endif
	endif
	
	//// update the plot waves ////	
	for (i=0; i<nWaves; i+=1)
		Wave /Z currSortedWave = sortedSourceWaves[i]
		
		if (!usingCustomTickLabels)
			tickWaveNames[i] = ParseFilePath(0, waveNames[i], ":", 1, 0)
		endif

		nPnts = sum(counts, i*dimsize(counts, 0), (i+1)*dimSize(counts,0)-1)
		
		countWaveName = getSDPPackageWaveName(waveNames[i])
			
		Wave /Z countWave = graphPkgDFR:$countWaveName	
		if (!waveExists(countWave))
			Make /D/O/N=(nPnts) graphPkgDFR:$countWaveName		
			Wave countWave = graphPkgDFR:$countWaveName
		elseif (numpnts(countWave) != nPnts)
			Redimension /N=(nPnts) countWave
		endif

		Wave /Z countWaveX = graphPkgDFR:$(countWaveName+"X") 	
		if (!waveExists(countWaveX))
			Make /O/N=(nPnts) graphPkgDFR:$(countWaveName+"X")		
			Wave countWaveX = graphPkgDFR:$(countWaveName+"X")	
		elseif (numpnts(countWaveX) != nPnts)
			Redimension /N=(nPnts) countWaveX
		endif
		
		// JW 190708 Initialize the indices for getting data from the sorted data waves
		// Find the place in the current wave where the bottom bin boundary is in the current wave.
		Variable minBoundary = ScatterDotPlotBinBounds[0]
		currPt = BinarySearch(currSortedWave, minBoundary)
		if (currPt == -2)		// bottom bin boundary is larger than any data point in the current wave.
			currPt = dimSize(currSortedWave, 0)-1
		endif
		if (currPt == -1)		// bottom bin boundary is smaller than any data point in the current wave.
			currPt = 0
		endif
		// JW 190708 If the minimum boundary value is in the current wave, and it is repeated, we need
		// to find the first instance of the boundary value.
		do
			if (currSortedWave[currPt] == minBoundary && currPt > 0)
				currPt -= 1
			else
				break
			endif
		while(1)
		
		if (currSortedWave[currPt] < ScatterDotPlotBinBounds[0])
			currPt+=1		// currSortedWave[currPt] will either be on or before the smallest bin boundary.  If before, increase the point.
		endif
		Variable initPt = currPt

		for (j=0; j<nBins; j+=1)
			Variable nInBin = counts[j][i]
			if (useTrueY)
				Wave currIndices = sortedToSourceIndices[i]
				Duplicate /FREE /R=(currPt, currPt+nInBin-1) currIndices, binIndices, sortedBinIndices
				sortedBinIndices = p
				sort binIndices, sortedBinIndices
			else
				Variable binMiddle = useLogScale ? 10^((log(ScatterDotPlotBinBounds[j])+log(ScatterDotPlotBinBounds[j+1]))/2) : (ScatterDotPlotBinBounds[j]+ScatterDotPlotBinBounds[j+1])/2
			endif
			for (k=0; k<nInBin; k+=1)
				countWave[currPt-initPt] = useTrueY ? currSortedWave[currPt] : binMiddle		
				countWaveX[currPt-initPt] = useTrueY ? i+1+(sortedBinIndices[k]+.5)*dx-nInBin*dx/2 : i+1+(k+.5)*dx-nInBin*dx/2
				currPt += 1
			endfor
		endfor		
			
		if (WhichListItem(countWaveName, countTracesOnGraph)<0 && WhichListItem("'"+countWaveName+"'", countTracesOnGraph)<0)
			AppendToGraph /W=$graphName countWave vs countWaveX
			ModifyGraph /W=$graphName mode($(NameOfWave(countWave)))=3, marker($(NameOfWave(countWave)))=19
			ModifyGraph /W=$graphName useMrkStrokeRGB($(NameOfWave(countWave)))=1
		endif
		
		// Using full width for mean or static width for error bars can look funny.  Make width based on max data width
		Variable barWidth
		if (showErrorBars || showMeanY) 
			if (setMeanYWidth)
				barWidth = 0.5*meanYWidthPercent/100
			else
				Duplicate /O/FREE countWaveX, absOffsetX
				absOffsetX = abs(absOffsetX - (i+1))
				barWidth = min(max(wavemax(absOffsetX)*1.1,0.1), 0.5)
			endif
		endif
		
		if (showMeanY)
			Wave /Z countWaveAvg = graphPkgDFR:$(countWaveName+"A")
			if (!waveExists(countWaveAvg))
				Make /O/N=2 graphPkgDFR:$(countWaveName+"A")
				Wave countWaveAvg = graphPkgDFR:$(countWaveName+"A")
			endif
			Redimension /N=2 countWaveAvg
			SetScale /I x, i+1-barWidth, i+1+barWidth, countWaveAvg
			countWaveAvg = Mean(currSortedWave) // the sorted wave has all non-normal (meaning Nan and +-inf) numbers removed

			if (WhichListItem(countWaveName+"A", countTracesOnGraph)<0 && WhichListItem("'"+countWaveName+"A'", countTracesOnGraph)<0)
				AppendToGraph /W=$graphName countWaveAvg
				ModifyGraph lSize($NameOfWave(countWaveAvg))=3, rgb($NameOfWave(countWaveAvg))=(0,0,0)					
			endif
		else	
			RemoveFromGraph /Z/W=$graphName $(countWaveName+"A")
			RemoveFromGraph /Z/W=$graphName $("'"+countWaveName+"A'")
		endif
		
		if (showErrorBars)
			Wave /Z countWaveStdDevX = graphPkgDFR:$(countWaveName+"Sx")
			if (!waveExists(countWaveStdDevX))
				Make /O/N=6 graphPkgDFR:$(countWaveName+"Sx")
				Wave countWaveStdDevX = graphPkgDFR:$(countWaveName+"Sx")
			endif
			
			Wave /Z countWaveStdDevY = graphPkgDFR:$(countWaveName+"Sy")
			if (!waveExists(countWaveStdDevY))
				Make /O/N=7 graphPkgDFR:$(countWaveName+"Sy")
				Wave countWaveStdDevY = graphPkgDFR:$(countWaveName+"Sy")
			endif
			
			Variable meanVal = Mean(currSortedWave)
			Variable stdDev = sqrt(Variance(currSortedWave))*nStdFactor
			Variable posErrBarVal = stdDev, negErrBarVal = stdDev
			if (errBarType == DPStdErr)
				if (nPnts<=1)
					posErrBarVal = 0
					negErrBarVal = 0
				else
					posErrBarVal = stdDev/sqrt(nPnts)
					negErrBarVal = stdDev/sqrt(nPnts)
				endif
			endif
			
			if (errBarType == DPWaveDef)
				if (WaveExists(errBarPosWave) && DimSize(errBarPosWave, 0) > i)
					posErrBarVal = errBarPosWave[i]
				else	
					posErrBarVal = 0
				endif
				if (WaveExists(errBarNegWave) && DimSize(errBarNegWave, 0) > i)
					negErrBarVal = errBarNegWave[i]
				else
					negErrBarVal = 0
				endif
			endif
			
			Redimension /N=7 countWaveStdDevX, countWaveStdDevY
			Variable errBarWidth
			if (setErrBarWidth)
				errBarWidth=errBarWidthPercent/200
			else
				errBarWidth=max(barWidth/3, 0.05)
			endif
			countWaveStdDevX = {i+1-errBarWidth, i+1+errBarWidth, i+1, i+1, i+1, i+1-errBarWidth, i+1+errBarWidth}
			countWaveStdDevY[0,2] = meanVal+posErrBarVal 
			countWaveStdDevY[3] = meanVal
			countWaveStdDevY[4,6] = meanVal-negErrBarVal 

			if (WhichListItem(countWaveName+"Sy", countTracesOnGraph)<0 && WhichListItem("'"+countWaveName+"Sy'", countTracesOnGraph)<0)
				AppendToGraph /W=$graphName countWaveStdDevY vs countWaveStdDevX
				ModifyGraph lSize($NameOfWave(countWaveStdDevY))=2, rgb($NameOfWave(countWaveStdDevY))=(0,0,0)					
			endif		

		else
			RemoveFromGraph /Z/W=$graphName $(countWaveName+"Sy")
			RemoveFromGraph /Z/W=$graphName $("'"+countWaveName+"Sy'")
		endif
		
		// clean up possible errors here //
		markerSize = min(markerSize, 200)			// max marker size - probably only reachable by zealous testers
		if (markerSize <= 0 || numtype(markerSize))
			markerSize =4
		endif
				
		ModifyGraph /W=$graphName msize($countWaveName)=markerSize
	endfor

	Make /O/N=(nWaves) graphPkgDFR:tickLocations = p+1
	Wave tickLocations = graphPkgDFR:tickLocations

	ModifyGraph /W=$graphName userticks(bottom)={tickLocations,tickWaveNames}
	
	if (useLogScale)
		ModifyGraph /W=$graphName log(left)=1
	else
		ModifyGraph /W=$graphName log(left)=0
	endif
	
	if (showBins)		
		//// wave for drawing the bin boundaries ////
		Make /O/N=((nBins+1)*3) graphPkgDFR:binBounds, graphPkgDFR:binBoundsX
	 	Wave binBounds = graphPkgDFR:binBounds
	 	Wave binBoundsX = graphPkgDFR:binBoundsX
	
		for (i=0; i<=nBins; i+=1)				
			binBounds[i*3, i*3+1] = ScatterDotPlotBinBounds[i]    
			binBounds[i*3+2] = NaN
			binBoundsX[i*3] = 0.5
			binBoundsX[i*3+1] = nWaves+.5		
			binBoundsX[i*3+2] = NaN
		endfor
	
		if (!waveExists(TraceNametoWaveRef(graphName, NameOfWave(binBounds))))
			AppendToGraph /W=$graphName /C=(0, 0, 0) binBounds vs binBoundsX
		endif
	else 	
		RemoveFromGraph /Z/W=$graphName binBounds
	endif
	
	return 1
End 

//////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////// Utility Functions ////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////

Structure binInfoStruct
	// Input arguments
	Variable logScale
	Variable autoAdjustType		
	Variable usePredefinedBinsWave		//if 1 then dependentVar != DPConstnatNBins - meaning nBins cannot change!

	// the fundamental variables
	Variable nBins
	Wave binWave  	// a 1D wave sized nBins+1 giving bin boundaries
	Variable dx		
	
	// other useful information
	Wave sortedSourceWaves   // free wave of free waves, with non normal numbers removed (i.e. -inf, inf and NaN removed)
	Wave counts
	Wave sortedToSourceIndices
	Wave iFirstNormal			// indices of first normal value (not -inf) for each sorted source wave
	Wave iLastNormal			// indices of last normal value (not inf or nan) for each sorted source wave
EndStructure

Function getAutoBinWave(graphName, waveNames, binInfo)
	String graphName
	Wave /T/Z waveNames
	Struct binInfoStruct & binInfo
	
	//// get package folders and the top graph ////
	DFREF pkgDFR = WMGetScatterDotPlotDFR()
	DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
	
	//// define function variables ////
	Variable nWaves= waveExists(waveNames) ? numPnts(waveNames) : 0
	Variable i, j, k, minVal, maxVal, nPnts, iBin, currPt, maxCount, currCount
	String countWaveName
	
	//// get control variables ////
	NVAR markerSize = graphPkgDFR:markerSize
	NVAR markerSpread = graphPkgDFR:markerSpread
	Variable markerSpreadDX
	switch (markerSpread)	
		case DPSpreadMarkers:
			markerSpreadDX = 1.5
			break
		case DPTightMarkers:
			markerSpreadDX=1
			break
		case DPOverlapMarkers:
			markerSpreadDX = 0.5
			break			
	endswitch

	GetWindow $graphName psizeDC
	Variable graphHtPixels = V_Bottom - V_Top
	Variable graphWtPixels = V_Right - V_Left
	
	Variable dX = (2*markerSize+1)*nWaves/graphWtPixels*markerSpreadDX
	
	/// waves for auto-determining bin size given marker size	
	Make /FREE/WAVE/N=(nWaves) sortedWaves
	Wave binInfo.sortedSourceWaves = sortedWaves
	Make /FREE/N=(nWaves) iFirstNormal
	Wave binInfo.iFirstNormal = iFirstNormal
	Make /FREE/N=(nWaves) iLastNormal
	Wave binInfo.iLastNormal = iLastNormal	
		
	Make /FREE/WAVE/N=(nWaves) sortedToSourceIndices
	Wave binInfo.sortedToSourceIndices = sortedToSourceIndices
	
	if (numType(binInfo.nBins))
		binInfo.nBins = 4
	endif	
		
	//// sort the input waves
	for (i=0; i<nWaves; i+=1)
		Wave currWave = $(waveNames[i])
		Duplicate /Free currWave, sortedCurrWave
		Make /O/FREE/N=(numpnts(currWave)) sortedIndices = p
		sort sortedCurrWave, sortedCurrWave, sortedIndices
							
		sortedWaves[i] = sortedCurrWave
		sortedToSourceIndices[i] = sortedIndices
		
		// find the first normal number - basically numbers greater than -Inf
		for (j=0; j<numpnts(sortedCurrWave)-1; j+=1)
			if (numtype(sortedCurrWave[j])==0)
				iFirstNormal[i]=j
				break
			endif
		endfor
		
		// sort compares NaN as greater than any other value, including infinity.  So all the Infs and NaNs will end up at the end.  
		// Iterate backwards through the sorted wave to find the first non-Nan
		for (j=numpnts(sortedCurrWave)-1; j>=0; j-=1)
			if (numtype(sortedCurrWave[j])==0)
				iLastNormal[i]=j
				break
			endif
		endfor
		
		if (iFirstNormal[i]>0)
			DeletePoints 0, iFirstNormal[i], sortedCurrWave, sortedIndices
		endif
		
		if (iLastNormal[i] < numpnts(currWave)-1)
			DeletePoints iLastNormal[i]-iFirstNormal[i]+1, numpnts(currWave)-iLastNormal[i]-1, sortedCurrWave, sortedIndices
		endif
	endfor	
	
	Make /FREE/N=5/D collectedWaveStats 
	
	/// set up dimension labels to keep code readable
	SetDimLabel 0, 0, maxnpts, collectedWaveStats
	SetDimLabel 0, 1, FDestimate, collectedWaveStats		//Freedman-Diaconis choice for bin size
	SetDimLabel 0, 2, stddev, collectedWaveStats
	SetDimLabel 0, 3, minval, collectedWaveStats
	SetDimLabel 0, 4, maxval, collectedWaveStats
	
	Variable maxNBins = floor(graphHtPixels/(markerSize*2+1))
	Variable maxBinCount = floor(graphWtPixels/(nWaves*(markerSize*2+1)*markerSpreadDX))
	
	Variable minMaxCountWidth = dX*maxBinCount*.85		// minimum width of the widest bin
	
	//// find the minimum and maximum values for all the data sets ////
	if (binInfo.logScale)
		/// get wave stats in log space
		Wave currSortedWave = sortedWaves[0]
	
		Duplicate /FREE currSortedWave, currSortedWaveLog
		currSortedWaveLog = log(currSortedWave[p])
		collectedWaveStats[%maxnpts] = numpnts(currSortedWave)  
		collectedWaveStats[%FDestimate] = 2*DP_IQR(currSortedWaveLog)/collectedWaveStats[%maxnpts]^(1/3)		
		collectedWaveStats[%stddev] = sqrt(Variance(currSortedWaveLog))
		
		iBin = BinarySearch(currSortedWave, 0)
		if (iBin<=-2 || iBin==numpnts(currSortedWave)-1)
			minVal = DPSmallConstant	// minimum postive normal 64 bit float - it doesn't really matter since there's no positive values and nothing will be plotted
		else
			minVal = currSortedWave[iBin+1]
		endif
		collectedWaveStats[%minval] = minVal //currSortedWave[0]
		collectedWaveStats[%maxval] = currSortedWave[numpnts(currSortedWave)-1]
			
		for (i=1; i<nWaves; i+=1)
			Wave currSortedWave = sortedWaves[i]
			Duplicate /O/FREE currSortedWave, currSortedWaveLog
			currSortedWaveLog = log(currSortedWave[p])
			collectedWaveStats[%maxnpts] = max(numpnts(currSortedWave), collectedWaveStats[%maxnpts])
			collectedWaveStats[%FDestimate] = min(2*DP_IQR(currSortedWaveLog)/collectedWaveStats[%maxnpts]^(1/3), collectedWaveStats[%FDestimate])		
			collectedWaveStats[%stddev] = min(sqrt(Variance(currSortedWaveLog)), collectedWaveStats[%stddev])
			
			iBin = BinarySearch(currSortedWave, 0)
			if (iBin<=-2 || iBin==numpnts(currSortedWave)-1)
				minVal = DPSmallConstant	// minimum postive normal 64 bit float - it doesn't really matter since there's no positive values and nothing will be plotted
			else
				minVal = currSortedWave[iBin+1]
			endif
			
			collectedWaveStats[%minval] = min(collectedWaveStats[%minval], minVal)//collectedWaveStats[%minval])
			collectedWaveStats[%maxval] = max(currSortedWave[numpnts(currSortedWave)-1], collectedWaveStats[%maxval])
		endfor
	
		Wave currWave = $waveNames[0]
		
		Variable nLogBinsGuess = binInfo.nBins		// hold this constant
		Variable logBinSize
		if (binInfo.autoAdjustType & DPAdjustNBinsPlots)		// Adjust nBins
			//// an initial guess based on Freedman-Diaconis' choice
			nLogBinsGuess = floor((log(collectedWaveStats[%maxval])-log(collectedWaveStats[%minval]))/collectedWaveStats[%FDestimate])
			nLogBinsGuess = max(nLogBinsGuess, 4)
			// use the sorted waves to figure out max count.  If max count > maxBinCoun then increase the number of bins
		
			for(j=0; j<DPConstantMaxAutoIterations; j+=1)			
				Make /FREE/O/D/N=(nLogBinsGuess+1) binWave
				Make /FREE/O/N=(nLogBinsGuess, nWaves) counts
				
				logBinSize = (log(collectedWaveStats[%maxval]) - log(collectedWaveStats[%minval]))/nLogBinsGuess
	
				binWave = 10^(log(collectedWaveStats[%minval]) + p*logBinSize)
				// prevent precision or decimal->binary issues at the boundary 
				binWave[0] = collectedWaveStats[%minval]
				binWave[numpnts(binWave)-1] = collectedWaveStats[%maxval]
				
				getCounts(sortedWaves, binWave, counts)			
				maxCount = wavemax(counts)
				
				if ((maxCount <= maxBinCount && dX*maxCount >= minMaxCountWidth && dx*maxCount <= 1) || maxNBins <= nLogBinsGuess)
					if (maxNBins < nLogBinsGuess)
						nLogBinsGuess = maxNBins						
						Make /FREE/O/D/N=(nLogBinsGuess+1) binWave
						Make /FREE/O/N=(nLogBinsGuess, nWaves) counts
						logBinSize = (log(collectedWaveStats[%maxval]) - log(collectedWaveStats[%minval]))/nLogBinsGuess
	
						binWave = 10^(log(collectedWaveStats[%minval]) + p*logBinSize)
						// prevent precision or decimal->binary issues at the boundary 
						binWave[0] = collectedWaveStats[%minval]
						binWave[numpnts(binWave)-1] = collectedWaveStats[%maxval]
						
						getCounts(sortedWaves, binWave, counts)
					endif
					break
				elseif (maxCount < maxBinCount && dX*maxCount <= minMaxCountWidth &&j<DPConstantMaxAutoIterations-1)	
					nLogBinsGuess -= max(1, ceil((dX*maxCount-minMaxCountWidth)/.05))
				elseif (j<DPConstantMaxAutoIterations-1)
					nLogBinsGuess += max(1, ceil((maxCount - maxBinCount)/4))
				endif
			endfor
		endif
		if (binInfo.autoAdjustType & DPAdjustMarkerSizePlots)		// Adjust nBins	// Adjust marker size		
			Make /FREE/O/D/N=(nLogBinsGuess+1) binWave
			Make /FREE/O/N=(nLogBinsGuess, nWaves) counts
			logBinSize = (log(collectedWaveStats[%maxval]) - log(collectedWaveStats[%minval]))/nLogBinsGuess
			binWave = 10^(log(collectedWaveStats[%minval]) + p*logBinSize)
		
			// prevent precision or decimal->binary issues at the boundary 
			binWave[0] = collectedWaveStats[%minval]
			binWave[numpnts(binWave)-1] = collectedWaveStats[%maxval]
		
			getCounts(sortedWaves, binWave, counts)
				
			maxCount = wavemax(counts)
			
			markerSize = max(min(graphHtPixels/(2*binInfo.nBins)-0.5, graphWtPixels/(nWaves*2*maxCount*markerSpreadDX)-0.5), 0.5)
		endif

		binInfo.nBins = nLogBinsGuess
		Wave binInfo.binWave = binWave	// a 1D wave sized nBins+1 giving bin boundaries
		binInfo.dx = (2*markerSize+1)*nWaves/graphWtPixels*markerSpreadDX
		Wave binInfo.counts = counts		
		
	else			// normal (not log) y axis
		Wave currSortedWave = sortedWaves[0]
		collectedWaveStats[%maxnpts] = numpnts(currSortedWave)  
		collectedWaveStats[%FDestimate] = 2*DP_IQR(currSortedWave)/collectedWaveStats[%maxnpts]^(1/3)
		collectedWaveStats[%stddev] = sqrt(Variance(currSortedWave))
		collectedWaveStats[%minval] = currSortedWave[0]
		collectedWaveStats[%maxval] = currSortedWave[numpnts(currSortedWave)-1]		
			
		for (i=1; i<nWaves; i+=1)
			Wave currSortedWave = sortedWaves[i]
			collectedWaveStats[%maxnpts] = max(numpnts(currSortedWave), collectedWaveStats[%maxnpts])
			collectedWaveStats[%FDestimate] = min(2*DP_IQR(currSortedWave)/collectedWaveStats[%maxnpts]^(1/3), collectedWaveStats[%FDestimate])		
			collectedWaveStats[%stddev] = min(sqrt(Variance(currSortedWave)), collectedWaveStats[%stddev])
			collectedWaveStats[%minval] = min(currSortedWave[0], collectedWaveStats[%minval])
			collectedWaveStats[%maxval] = max(currSortedWave[numpnts(currSortedWave)-1], collectedWaveStats[%maxval])
		endfor

		if (numType(binInfo.nBins))
			binInfo.nBins = 4
		endif	 
		Variable nBinsGuess = binInfo.nBins 

		Variable binSize
		if (binInfo.autoAdjustType & DPAdjustNBinsPlots)		// Adjust nBins
			nBinsGuess = floor((collectedWaveStats[%maxval]-collectedWaveStats[%minval])/collectedWaveStats[%FDestimate])
			nBinsGuess = max(nBinsGuess, 4)		// make sure there's a min number of bins to start the guessing
		
			for(j=0; j<DPConstantMaxAutoIterations; j+=1)		
				if (numtype(nBinsGuess))
					nBinsGuess = 2
				endif
				
				Make /FREE/O/D/N=(nBinsGuess+1) binWave
				Make /FREE/O/N=(nBinsGuess, nWaves) counts
				binSize = (collectedWaveStats[%maxval] - collectedWaveStats[%minval])/nBinsGuess
	
				binWave = collectedWaveStats[%minval] + p*binSize
				// prevent precision or decimal->binary issues at the boundary 
				binWave[0] = collectedWaveStats[%minval]
				binWave[numpnts(binWave)-1] = collectedWaveStats[%maxval]
				
				getCounts(sortedWaves, binWave, counts)
				
				maxCount = wavemax(counts)
				
				if ((maxCount <= maxBinCount && dX*maxCount >= minMaxCountWidth && dx*maxCount <= 1) || maxNBins <= nBinsGuess)
					if (maxNBins < nBinsGuess)
						nBinsGuess = maxNBins						
						Make /FREE/O/D/N=(nBinsGuess+1) binWave
						Make /FREE/O/N=(nBinsGuess, nWaves) counts
						binSize = (collectedWaveStats[%maxval] - collectedWaveStats[%minval])/nBinsGuess
	
						binWave = collectedWaveStats[%minval] + p*binSize	
						// prevent precision or decimal->binary issues at the boundary 
						binWave[0] = collectedWaveStats[%minval]
						binWave[numpnts(binWave)-1] = collectedWaveStats[%maxval]
						
						getCounts(sortedWaves, binWave, counts)
					endif
					break
				elseif (maxCount <= maxBinCount && dX*maxCount <= minMaxCountWidth && j<DPConstantMaxAutoIterations-1)
					nBinsGuess -= max(1, ceil((dX*maxCount-minMaxCountWidth)/.05))
					if (nBinsGuess <= 2)
						nBinsGuess = 2
						break
					endif
				elseif (j<DPConstantMaxAutoIterations-1)
					nBinsGuess += max(1, ceil((maxCount - maxBinCount)/4))
				endif
	
			endfor
		endif
		if (binInfo.autoAdjustType & DPAdjustMarkerSizePlots)			// Adjust marker size
//			nBinsGuess = binInfo.nBins		// hold this constant
			// use the sorted waves to figure out max count.  If max count > maxBinCoun then increase the number of bins
		
			if (binInfo.usePredefinedBinsWave)
				Duplicate /FREE/O binInfo.binWave, binWave
				nBinsGuess = dimsize(binWave,0)-1
			else
				Make /FREE/O/D/N=(nBinsGuess+1) binWave
				binSize = (collectedWaveStats[%maxval] - collectedWaveStats[%minval])/nBinsGuess
				binWave = collectedWaveStats[%minval] + p*binSize
				// prevent precision or decimal->binary issues at the boundary 
				binWave[0] = collectedWaveStats[%minval]
				binWave[numpnts(binWave)-1] = collectedWaveStats[%maxval]
			endif
			Make /FREE/O/N=(nBinsGuess, nWaves) counts
			
			getCounts(sortedWaves, binWave, counts)
				
			maxCount = wavemax(counts)

			markerSize = max(min(graphHtPixels/(2*binInfo.nBins)-0.5, graphWtPixels/(nWaves*2*maxCount*markerSpreadDX)-0.5), 0.5)
		endif

		binInfo.nBins = nBinsGuess
		Wave binInfo.binWave = binWave	// a 1D wave sized nBins+1 giving bin boundaries
		binInfo.dx = (2*markerSize+1)*nWaves/graphWtPixels*markerSpreadDX
		Wave binInfo.counts = counts
	endif
End

Function getConstantBinWave(graphName, waveNames, binInfo)
	String graphName
	Wave /T/Z waveNames
	Struct binInfoStruct & binInfo
	
	//// define function variables ////
	Variable nWaves= waveExists(waveNames) ? numPnts(waveNames) : 0
	Variable i, j, k, minVal, maxVal, nPnts, iBin, currPt, maxCount, currCount, binSize
	String countWaveName

	DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
	
	//// get control variables ////
	NVAR markerSize = graphPkgDFR:markerSize
	
	Make /FREE/WAVE/N=(nWaves) sortedWaves
	Wave binInfo.sortedSourceWaves = sortedWaves
		
	Make /FREE/WAVE/N=(nWaves) sortedToSourceIndices
	Wave binInfo.sortedToSourceIndices = sortedToSourceIndices
	
	Make /FREE/N=(nWaves) iFirstNormal
	Wave binInfo.iFirstNormal = iFirstNormal
	Make /FREE/N=(nWaves) iLastNormal
	Wave binInfo.iLastNormal = iLastNormal		
	
	if (numType(binInfo.nBins))
		binInfo.nBins = 4
	endif	
		
	//// sort the input waves
	for (i=0; i<nWaves; i+=1)
		Wave currWave = $(waveNames[i])
		Duplicate /D/Free currWave, sortedCurrWave
		Make /FREE/N=(numpnts(currWave)) sortedIndices = p
		sort sortedCurrWave, sortedCurrWave, sortedIndices
				
		sortedWaves[i] = sortedCurrWave
		sortedToSourceIndices[i] = sortedIndices
		
		// find the first normal number - basically numbers greater than -Inf
		for (j=0; j<numpnts(sortedCurrWave)-1; j+=1)
			if (numtype(sortedCurrWave[j])==0)
				iFirstNormal[i]=j
				break
			endif
		endfor
		
		for (j=numpnts(sortedCurrWave)-1; j>=0; j-=1)
			if (numtype(sortedCurrWave[j])==0)
				iLastNormal[i]=j
				break
			endif
		endfor
		
		if (iFirstNormal[i]>0)
			DeletePoints 0, iFirstNormal[i], sortedCurrWave, sortedIndices
		endif
		
		if (iLastNormal[i] < numpnts(currWave)-1)
			DeletePoints iLastNormal[i]-iFirstNormal[i]+1, numpnts(currWave)-iLastNormal[i]-1, sortedCurrWave, sortedIndices
		endif
	endfor
	
	if (!binInfo.usePredefinedBinsWave)
		//// find the minimum and maximum values for all the data sets ////
		Make /D/O/Free/N=(binInfo.nBins+1) binWave
		
		Wave /Z currWave = $waveNames[0]
		if (binInfo.logScale && waveExists(currWave))
			Wave sortedCurrWave = sortedWaves[0]
				
			iBin = BinarySearch(sortedCurrWave, 0)
			if (iBin<=-2 || iBin==numpnts(sortedCurrWave)-1)
				minVal = DPSmallConstant	// minimum postive normal 64 bit float - it doesn't really matter since there's no positive values and nothing will be plotted
			else
				minVal = sortedCurrWave[iBin+1]
			endif
			maxVal = sortedCurrWave[numpnts(sortedCurrWave)-1]
			
			for (i=1; i<nWaves; i+=1)
				Wave sortedCurrWave = sortedWaves[i]
			
				iBin = BinarySearch(sortedCurrWave, 0)
				if (!(iBin<=-2 || iBin==numpnts(sortedCurrWave)-1))
					minVal = min(minVal, sortedCurrWave[iBin+1])
				endif
				
				maxVal = max(maxVal, sortedCurrWave[numpnts(sortedCurrWave)-1])
			endfor
						
			Variable logMinVal = log(minVal)
			Variable logMaxVal
			if (maxVal <= 0) /// nothing is going to get plotted, but give it a value anyway
				logMaxVal = 0
			else
				logMaxVal = log(maxVal)
			endif
			
			binSize = (logMaxVal - logMinVal)/binInfo.nBins
			binWave = 10^(logMinVal + binSize*p)
			// prevent precision or decimal->binary issues at the boundary 
			binWave[0] = minVal
			binWave[numpnts(binWave)-1] = maxVal

		elseif (waveExists(currWave))
			Wave sortedCurrWave = sortedWaves[0]
		
			minVal = sortedCurrWave[0]
			maxVal = sortedCurrWave[numpnts(sortedCurrWave)-1]	
							
			for (i=1; i<nWaves; i+=1)
				Wave sortedCurrWave = sortedWaves[i]
		
				minVal = min(sortedCurrWave[0], minVal)
				maxVal = max(sortedCurrWave[numpnts(sortedCurrWave)-1], maxVal)
			endfor	
			
			binSize = (maxVal - minVal)/binInfo.nBins
			binWave = minVal + binSize*p
			// prevent precision or decimal->binary issues at the boundary 
			binWave[0] = minVal
			binWave[numpnts(binWave)-1] = maxVal
		endif
	else
		Wave binWave = binInfo.binWave
	endif	

	////////////////////////////////////////////////////////////////////////////////	
	Make /O/Free/N=(binInfo.nBins, nWaves) counts
	
	getCounts(sortedWaves, binWave, counts)
	
	NVAR markerSpread = graphPkgDFR:markerSpread
	Variable markerSpreadDX
	switch (markerSpread)	
		case DPSpreadMarkers:
			markerSpreadDX = 1.5
			break
		case DPTightMarkers:
			markerSpreadDX=1
			break
		case DPOverlapMarkers:
			markerSpreadDX = 0.5
			break			
	endswitch

	Wave binInfo.binWave = binWave
	Wave binInfo.counts = counts
	GetWindow /Z $graphName psizeDC
	if (!V_flag)
		Variable graphHtPixels = V_Bottom - V_Top
		Variable graphWtPixels = V_Right - V_Left
	
		binInfo.dX = (2*markerSize+1)*nWaves/graphWtPixels*markerSpreadDX			
	endif
End

// fill in the counts wave according to the sortedWaves 
Function getCounts(sortedWaves, binWave, counts)
	Wave /WAVE sortedWaves
	Wave binWave, counts
	
	Variable nWaves = numpnts(sortedWaves)
	Variable i, j, k
	Variable nBins = numpnts(binWave)-1

	for (i=0; i<nWaves; i+=1)
		Wave currSortedWave = sortedWaves[i]

		Variable prevIndx = BinarySearch(currSortedWave, binWave[0])
		if (prevIndx==dimsize(currSortedWave,0)-1)		// all the points go in the first bin?
			counts[][i] = 0
			counts[0][i] = dimSize(currSortedWave,0)
			continue
		endif
		do
			if ((prevIndx >=0) && (currSortedWave[prevIndx]==binWave[0]))
				prevIndx-=1
			else
				break
			endif
		while(1)
		for (k=0; k<nBins; k+=1)	
			Variable highIndx = BinarySearch(currSortedWave, binWave[k+1])
			if (highIndx == -1)
				counts[k][i] = 0												// the current bin's upper value < the minimum wave value
			elseif (highIndx == -2)											// the current bin's upper value > the max wave value : time to take a break!
				if (prevIndx > -2)											// make sure ALL the bins aren't > than the max wave value			
					counts[k][i] = numpnts(currSortedWave) - prevIndx -1
				endif
				break
			else
				counts[k][i] = highIndx - prevIndx
				prevIndx = highIndx
			endif
		endfor
	endfor
End

Function copyControls(sourceFolder, targetFolder)
	String sourceFolder, targetFolder

	DFREF sourceDFR = $sourceFolder
	DFREF targetDFR = $targetFolder
	if (DataFolderRefStatus(targetDFR) != 1)
		NewDataFolder /O $targetFolder
		DFREF targetDFR = $targetFolder
	endif

	NVAR markerSize = sourceDFR:markerSize
	Variable /G targetDFR:markerSize = markerSize
	
	NVAR useLogScale = sourceDFR:useLogScale
	Variable /G targetDFR:useLogScale = useLogScale

	NVAR nBins = sourceDFR:nBins
	Variable /G targetDFR:nBins = nBins
	
	NVAR useTrueY = sourceDFR:useTrueY
	Variable /G targetDFR:useTrueY = useTrueY
		
	NVAR showMeanY = sourceDFR:showMeanY
	Variable /G targetDFR:showMeanY = showMeanY
	
	Wave /T selectedWaveNames = sourceDFR:selectedWaveNames
	Duplicate /O/T selectedWaveNames targetDFR:selectedWaveNames
	Wave /B/U selectedWaveSelected = sourceDFR:selectedWaveSelected
	Duplicate /O/B/U selectedWaveSelected targetDFR:selectedWaveSelected	
	
	NVAR usePredefinedBinsWave = sourceDFR:usePredefinedBinsWave
	Variable /G targetDFR:usePredefinedBinsWave = usePredefinedBinsWave
	
	SVAR binWavePath = sourceDFR:binWavePath
	String /G targetDFR:binWavePath = binWavePath

	NVAR showBins = sourceDFR:showBins
	Variable /G targetDFR:showBins = showBins
	
	NVAR markerSpread = sourceDFR:markerSpread
	Variable /G targetDFR:markerSpread = markerSpread
	
	NVAR doAutoAdjust = sourceDFR:doAutoAdjust
	Variable /G targetDFR:doAutoAdjust = doAutoAdjust

	NVAR autoAdjustType = sourceDFR:autoAdjustType
	Variable /G targetDFR:autoAdjustType = autoAdjustType
	
	NVAR showErrorBars = sourceDFR:showErrorBars
	Variable /G targetDFR:showErrorBars = showErrorBars
	
	NVAR errBarType = sourceDFR:errBarType
	Variable /G targetDFR:errBarType = errBarType	
	
	NVAR nStdFactor = sourceDFR:nStdFactor
	Variable /G targetDFR:nStdFactor = nStdFactor
End

Function /S getSDPPackageWaveName(wName)
	String wName
	
	DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
	
	String ret
	
	String baseWaveName = getUniqueScatterDotPlotName(wName)
		
	if (strlen(baseWaveName) > 23)   // base wave name is too long.  Make it smaller based on assumption that distinctive parts of names are usually at beginning or end	
		baseWaveName = baseWaveName[0,12]+baseWaveName[strlen(baseWaveName)-10,strlen(baseWaveName)-1]
	endif
		
	ret = ReplaceString("'", "counts_"+ baseWaveName, "")	
	
	Variable aStrLen = strlen(ret)
	if (aStrLen>=30)			// could break existing Scatter Dot Plots made with very long wave names
		ret = ret[0,20]+ret[22,inf]
	endif
	
	return ret
End 

Function /S getUniqueScatterDotPlotName(wName)
	String wName
	
	DFREF graphPkgDFR = WMGetScatterDotPlotGraphDFR()
	
	String leafName = ParseFilePath(0, wName, ":", 1, 0)
	String ret = 	leafName
	Wave /T/Z wRef = graphPkgDFR:selectedWaveNames
	
	if (WaveExists(wRef))
		Variable nWaves = DimSize(wRef, 0)
		Variable nMatches = 0
		Variable iWaveNameMatch = 0
		Variable i
				
		for (i=0; i<nWaves; i+=1)
			String currLeaf = ParseFilePath(0, wRef[i], ":", 1, 0)
			if (!CmpStr(currLeaf, leafName))
				nMatches += 1
				if (!CmpStr(wName, wRef[i]))
					iWaveNameMatch = i
				endif	
			endif
		endfor
		
		if (nMatches > 1)
			if (!CmpStr(leafName[strlen(leafName)-1], "'"))
				ret = leafName[0,strlen(leafName)-2] + num2str(iWaveNameMatch) + "'"
			else
				ret = leafName +num2str(iWaveNameMatch)
			endif
		endif
	endif
			
	return ret
End		


// Get the inter quartile range (75% - 25%) of multiple sorted waves
Function DP_IQR(sortedWave, [iStart, iEnd])
	Wave sortedWave
	Variable iStart, iEnd
	
	if (ParamIsDefault(iStart))
		iStart=0
	endif
	if (ParamIsDefault(iEnd))
		iEnd=DimSize(sortedWave, 0)-1
	endif
	
	Variable nVals=iEnd-iStart+1
	
	return sortedWave[iStart+floor(nVals*.75)]-sortedWave[iStart+floor(nVals*.25)]
End

Function /WAVE getCustomWaveLabelsWave(graphName)
	String graphName

	String tickLabelInfo =  StringByKey("userticks(x)", AxisInfo(graphName, "bottom"), "=", ";")
	if (strlen(tickLabelInfo))
		tickLabelInfo = ReplaceString("}",tickLabelInfo,"")
		String labelsStr = StringFromList(1,tickLabelInfo,",")
		Wave /T/Z tickWaveNames = $labelsStr
		
		return tickWaveNames
	endif
	
	return $""
End

//////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////// Dependency Update Function /////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////

// TODO: this gets updated every time there is a recompile, which can result in small changes in the graph.  This
//            is probably not a problem, but it would probably best if there was a per graph checksum and nPts count
//      	   for each wave.  updateGraph will only be called if the checksum or nPts changes.
// Used with SetFormula.  Doesn't do anything with the waves.  Will work with up to 50 waves - way more than a reasonable dot plot would contain!
Function sourceDataChangedUpdate(graphName, [a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a21,a22,a23,a24,a25,a26,a27,a28,a29,a30,a31,a32,a33,a34,a35,a36,a37,a38,a39,a40,a41,a42,a43,a44,a45,a46,a47,a48,a49,a50])
	String graphName
	Wave a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a21,a22,a23,a24,a25,a26,a27,a28,a29,a30,a31,a32,a33,a34,a35,a36,a37,a38,a39,a40,a41,a42,a43,a44,a45,a46,a47,a48,a49,a50
	
//	DFREF dfr = WMGetScatterDotPlotGraphDFR(graphName=graphName)
		
	// Make sure the graph still exists.
	String listOfGraphName = WinList(graphName, ";", "")
	if (strlen(listOfGraphName))
		updateGraph(graphName)
	endif
	
	return 1
End

//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////// Data Folder Functions /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////

Function /DF WMGetScatterDotPlotDFR()
	DFREF dfr = root:Packages:WMScatterDotPlot
	
	if (DataFolderRefStatus(dfr) != 1)
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:WMScatterDotPlot
		DFREF dfr = root:Packages:WMScatterDotPlot
	endif

	if (!exists("root:Packages:WMScatterDotPlot:ScatterDotPlotXLoc"))
		Variable/G dfr:ScatterDotPlotXLoc=200
		Variable/G dfr:ScatterDotPlotYLoc=200
		
		Variable/G dfr:ScatterDotPlotWidth=400
		Variable/G dfr:ScatterDotPlotHeight=640
		
		String /G dfr:currentGraphName=newGraphTag
	endif

	SVAR /Z globalBinWavePath= dfr:globalBinWavePath
	if (!SVAR_exists(globalBinWavePath))
		String /G dfr:globalBinWavePath = ""
	endif

	return dfr
End

Function /DF WMGetScatterDotPlotGraphDFR([graphName])
	String graphName

	DFREF dfr = WMGetScatterDotPlotDFR()
	
	if (ParamIsDefault(graphName))
		SVAR currGraphName = dfr:currentGraphName
		graphName = currGraphName
	endif
	
	DFREF ret = dfr:$graphName   													//PossiblyQuoteName(graphName)
	if (DataFolderRefStatus(ret) != 1)
		NewDataFolder /O root:Packages:WMScatterDotPlot:$graphName			//PossiblyQuoteName(graphName)
		DFREF ret = dfr:$graphName												//PossiblyQuoteName(graphName)
	endif

	Wave /T/Z wRef = ret:selectedWaveNames
	if (!waveExists(wRef))	
		Make /O/T/N=0 ret:selectedWaveNames
		Make /O/B/U/N=0 ret:selectedWaveSelected
	endif
	
	NVAR /Z markerSize = ret:markerSize
	if (!NVAR_exists(markerSize))
		Variable /G ret:markerSize = 3
	endif
	
	NVAR /Z usePredefinedBinsWave = ret:usePredefinedBinsWave
	if (!NVAR_exists(usePredefinedBinsWave))
		Variable /G ret:usePredefinedBinsWave = 0
	endif
	
	SVAR /Z binWavePath= ret:binWavePath
	if (!SVAR_exists(binWavePath))
		String /G ret:binWavePath = ""
	endif
	
	NVAR /Z useLogScale = ret:useLogScale
	if (!NVAR_exists(useLogScale))
		Variable /G ret:useLogScale = 0
	endif
	NVAR /Z nBins = ret:nBins
	if (!NVAR_exists(nBins))
		Variable /G ret:nBins = 10
	endif
	
	NVAR /Z useTrueY = ret:useTrueY
	if (!NVAR_exists(useTrueY))
		Variable /G ret:useTrueY = 0
	endif

	NVAR /Z showMeanY = ret:showMeanY
	if (!NVAR_exists(showMeanY))
		Variable /G ret:showMeanY = 0
	endif
		
	NVAR /Z setMeanYWidth = ret:setMeanYWidth
	if (!NVAR_exists(setMeanYWidth))
		Variable /G ret:setMeanYWidth = 0
	endif
	
	NVAR /Z meanYWidthPercent = ret:meanYWidthPercent
	if (!NVAR_exists(meanYWidthPercent))
		Variable /G ret:meanYWidthPercent = 50
	endif	
		
	NVAR /Z setErrBarWidth = ret:setErrBarWidth
	if (!NVAR_exists(setErrBarWidth))
		Variable /G ret:setErrBarWidth = 0
	endif
	
	NVAR /Z errBarWidthPercent = ret:errBarWidthPercent
	if (!NVAR_exists(errBarWidthPercent))
		Variable /G ret:errBarWidthPercent = 50
	endif		
		
	NVAR /Z showBins = ret:showBins
	if (!NVAR_exists(showBins))
		Variable /G ret:showBins = 0
	endif

	NVAR /Z markerSpread = ret:markerSpread
	if (!NVAR_exists(markerSpread))
		Variable /G ret:markerSpread = DPTightMarkers
	endif	
	
	NVAR /Z doAutoAdjust = ret:doAutoAdjust
	if (!NVAR_exists(doAutoAdjust))
		Variable /G ret:doAutoAdjust = 0
	endif

	NVAR /Z autoAdjustType = ret:autoAdjustType
	if (!NVAR_exists(autoAdjustType))
		Variable /G ret:autoAdjustType = DPAdjustNBinsPlots + DPAdjustMarkerSizePlots
	endif

	NVAR /Z showErrorBars = ret:showErrorBars
	if (!NVAR_exists(showErrorBars))
		Variable /G ret:showErrorBars = 0
	endif
	
	NVAR /Z nStdFactor = ret:nStdFactor
	if (!NVAR_exists(nStdFactor))
		Variable /G ret:nStdFactor = 1
	endif

	NVAR /Z errBarType = ret:errBarType
	if (!NVAR_exists(errBarType))
		Variable /G ret:errBarType = DPStdDev
	endif

	SVAR /Z errBarPosWaveName = ret:errBarPosWaveName
	if (!SVAR_exists(errBarPosWaveName))
		String /G ret:errBarPosWaveName = ""
	endif

	SVAR /Z errBarNegWaveName = ret:errBarNegWaveName
	if (!SVAR_exists(errBarNegWaveName))
		String /G ret:errBarNegWaveName = ""
	endif

	SVAR /Z errBarWaveNamesDisplay = ret:errBarWaveNamesDisplay
	if (!SVAR_exists(errBarWaveNamesDisplay))
		String /G ret:errBarWaveNamesDisplay = ""
	endif

	return ret
End

