#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma IgorVersion=9.00
#pragma version=9.00        // shipped with Igor 9
#include <Resize Controls>

strconstant selectorControlFolderBase = "root:Packages:WMSelectorControlSet"

static constant col0Pos = 15
// vertical markers
static constant row0Pos = 0
static constant row1Pos = 50
static constant row2Pos = 130

constant WMSCSBaseFontSize = 12

///// bit-wise data input formats
//////// Use bit-wise data input formats.  These constants make clear what is being checked in the code. //////////
constant WMconstSingle2DInput = 1			
constant WMconstCollection1DInput = 2
constant WMconstWaveScalingInput = 4
constant WMconstCommonWaveInput = 8
constant WMconstXyPairsInput = 16
constant WMconst2Dxy = 17
constant WMconst1Dxy = 18
constant WMconstSlaveShiftFactor = 5

///// For maintaining filter text of different types /////
constant constWildcardIndx = 0
constant constRegExpIndx = 1

///// Some string constants /////
strconstant WMSCSInForm2D = "columns in 2D wave"
strconstant WMSCSInForm1Dset = "1D waves collection"
strconstant WMSCSInFormScale = "use wave scaling"
strconstant WMSCSInFormOneWave = "one wave for all"
strconstant WMSCSInFormXY = "Wave(s) are XY pairs"
strconstant WMSCSInForm2DScale = "Y from 2D wave columns, X from wave scaling"
strconstant WMSCSInForm2D1Dset = "Y from 2D wave columns, X from set of 1D waves"
strconstant WMSCSInForm2D1D = "Y from 2D wave columns, X from a single 1D wave"
strconstant WMSCSInForm2D2D = "Y from 2D wave columns, X from 2D wave columns"
strconstant WMSCSInForm2Dxy = "X and Y from alternating columns of a single 2D wave"
strconstant WMSCSInForm1DsetScale = "Y from set of 1D waves, X from wave scaling (waveforms)"
strconstant WMSCSInForm1Dset1Dset = "Y from set of 1D waves, X from set of 1D waves (XY pairs)"
strconstant WMSCSInForm1Dset1D = "Y from set of 1D waves, X from a single 1D wave"
strconstant WMSCSInForm1Dset2D= "Y from set of 1D waves, X from 2D wave columns"
strconstant WMSCSInForm1Dsetxy = "X and Y from columns in set of 2-column waves"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////// initiate a panel ///////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Function WMSCSCreateSelectorControlSet(windowName, panelName, setName)
	String windowName, panelName, setName

	DFREF packageDFR = WMGetSCSPackageDFR(setName)
	String packageDFRString = GetDataFolder(1, packageDFR)    

	NVAR listBoxWidth = packageDFR:WMlistBoxWidth
	NVAR listBoxHeight = packageDFR:WMlistBoxHeight

	SVAR titleStr = packageDFR:titleStr
	TitleBox  $("WM"+setName+"SetSourceTitle") win=$(windowName+"#"+panelName), title=titleStr+" Input Data Format"; DelayUpdate
	TitleBox  $("WM"+setName+"SetSourceTitle") win=$(windowName+"#"+panelName), size={400, 15}, fsize=WMSCSBaseFontSize+1, fstyle=1, frame=0, pos={col0Pos, row0Pos}

	String cmd= GetIndependentModuleName()+"#WMListInputOptions(\""+setName+"\")"
	PopupMenu $("WM"+setName+"SetSourceType") win=$(windowName+"#"+panelName), title=" ", value=#cmd; DelayUpdate
	PopupMenu $("WM"+setName+"SetSourceType") win=$(windowName+"#"+panelName), Proc=WMSCSSetInputFormatPopup, pos={col0Pos-10, row0Pos+25}; DelayUpdate
	PopupMenu $("WM"+setName+"SetSourceType") win=$(windowName+"#"+panelName), size={400, 15}, fsize=WMSCSBaseFontSize+1, fstyle=1, mode=1

	TitleBox $("WM"+setName+"SelectWavesText") win=$(windowName+"#"+panelName), title=titleStr+" Waves", fixedSize=1, frame=0, pos={col0Pos, row1Pos}; DelayUpdate
	TitleBox $("WM"+setName+"SelectWavesText") win=$(windowName+"#"+panelName), size={255, 20}, fsize=WMSCSBaseFontSize+1, fstyle=1
	
	GroupBox $("WM"+setName+"FilterBox") win=$(windowName+"#"+panelName), pos={col0Pos,row1Pos+20}, size={295, 55}
	
	PopupMenu $("WM"+setName+"FilterType") win=$(windowName+"#"+panelName), pos={col0Pos+5,row1Pos+25}, size={80, 24}, fsize=WMSCSBaseFontSize+1, proc=WMSetFilterType; DelayUpdate
	PopupMenu $("WM"+setName+"FilterType") win=$(windowName+"#"+panelName), title="Filter Type", value="none;wildcard;regular expression"
	
	Button $("WM"+setName+"FilterButton") win=$(windowName+"#"+panelName),title="Filter Waves",size={110,20},Proc=WMFilterWaveNames; DelayUpdate
	Button $("WM"+setName+"FilterButton") win=$(windowName+"#"+panelName), pos={col0Pos+175,row1Pos+50}, fsize=WMSCSBaseFontSize

	SetVariable $("WM"+setName+"FilterWavesText") win=$(windowName+"#"+panelName), pos={col0Pos+5, row1Pos+50}, size={155, 20}, fsize=WMSCSBaseFontSize; DelayUpdate
	SetVariable $("WM"+setName+"FilterWavesText") win=$(windowName+"#"+panelName), value=packageDFR:waveFilterText, title=" "

	ListBox $("WM"+setName+"SetWaves") win=$(windowName+"#"+panelName),pos={col0Pos,row2Pos},size={listBoxWidth, listBoxHeight}, fsize=WMSCSBaseFontSize, mode=2; DelayUpdate
	ListBox $("WM"+setName+"SetWaves") win=$(windowName+"#"+panelName), help={"All waves fitting the current criteria appear here.  Each wave can only be selected once.  Use the \"Add\" and \"Remove\" buttons to tell batch fit to use the wave"}

	Button $("WM"+setName+"SelectAllButton") win=$(windowName+"#"+panelName),pos={col0Pos+listBoxWidth/2-150,row2Pos+listBoxHeight+5},size={75, 20}; DelayUpdate
	Button $("WM"+setName+"SelectAllButton") win=$(windowName+"#"+panelName),Proc=WMSCSSelectWavesProc, title="Add All", fsize=WMSCSBaseFontSize

	Button $("WM"+setName+"SelectButton") win=$(windowName+"#"+panelName),pos={col0Pos+listBoxWidth/2-65,row2Pos+listBoxHeight+5},size={60, 20}; DelayUpdate
	Button $("WM"+setName+"SelectButton") win=$(windowName+"#"+panelName),Proc=WMSCSSelectWavesProc, title="Add", fsize=WMSCSBaseFontSize

	Button $("WM"+setName+"DeSelectButton") win=$(windowName+"#"+panelName),pos={col0Pos+listBoxWidth/2+5,row2Pos+listBoxHeight+5},size={60, 20}; DelayUpdate
	Button $("WM"+setName+"DeSelectButton") win=$(windowName+"#"+panelName),Proc=WMSCSSelectWavesProc,title="Remove", fsize=WMSCSBaseFontSize

	Button $("WM"+setName+"DeSelectAllButton") win=$(windowName+"#"+panelName),pos={col0Pos+listBoxWidth/2+75,row2Pos+listBoxHeight+5},size={75, 20}; DelayUpdate
	Button $("WM"+setName+"DeSelectAllButton") win=$(windowName+"#"+panelName),Proc=WMSCSSelectWavesProc,title="Remove All", fsize=WMSCSBaseFontSize

	Checkbox $("WM"+setName+"AllowRepeats") win=$(windowName+"#"+panelName),pos={col0Pos+listBoxWidth/2-60,row2Pos+listBoxHeight+30},size={75, 20}; DelayUpdate
	Checkbox $("WM"+setName+"AllowRepeats") win=$(windowName+"#"+panelName),Proc=WMSCSAllowRepeatsProc,title="Allow Repeats", fsize=WMSCSBaseFontSize,variable=packageDFR:allowRepeats

	WAVE /T listOfSelectedWaves = packageDFR:listOfSelectedWaves
	WAVE /T selectSelectedWave = packageDFR:selectSelectedWave

	ListBox $("WM"+setName+"ShowWaves") win=$(windowName+"#"+panelName),pos={col0Pos,row2Pos+listBoxHeight+50},size={listBoxWidth, listBoxHeight}; DelayUpdate
	ListBox $("WM"+setName+"ShowWaves") win=$(windowName+"#"+panelName),listWave=listOfSelectedWaves,selWave=selectSelectedWave, fsize=WMSCSBaseFontSize,mode=3, widths={20, 200}; DelayUpdate
	ListBox $("WM"+setName+"ShowWaves") win=$(windowName+"#"+panelName),help={"These waves will be used in the order they appear.  Use the \"Up\" and \"Down\" buttons to re-order."}

	Button $("WM"+setName+"UpButton") win=$(windowName+"#"+panelName),pos={col0Pos+listBoxWidth+10,row2Pos+listBoxHeight*3/2+10},size={50,20}; DelayUpdate
	Button $("WM"+setName+"UpButton") win=$(windowName+"#"+panelName),title="Up",Proc=WMSCSMoveSelected, fsize=WMSCSBaseFontSize

	Button $("WM"+setName+"DownButton") win=$(windowName+"#"+panelName),pos={col0Pos+listBoxWidth+10,row2Pos+listBoxHeight*3/2+40}; DelayUpdate
	Button $("WM"+setName+"DownButton") win=$(windowName+"#"+panelName),size={50,20},title="Down",Proc=WMSCSMoveSelected, fsize=WMSCSBaseFontSize

	DefineGuide /W=$(windowName+"#"+panelName) LBsCenter = {FT, .5, FB}
	DefineGuide /W=$(windowName+"#"+panelName) LB2Top = {LBsCenter, 10}	
	DefineGuide /W=$(windowName+"#"+panelName) LB2Bottom = {FB, -5}	
	DefineGuide /W=$(windowName+"#"+panelName) LB2Center = {LB2Top, .5, FB}
	
	////////// control response to resizing ///////////

	ListBox $("WM"+setName+"SetWaves"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo)= A"!!,B)!!#@f!!#BP!!#A1z!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
	ListBox $("WM"+setName+"SetWaves"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:DuaGl9L:I5Df>[Vzzzzzzzzz"
	ListBox $("WM"+setName+"SetWaves"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ct9L<efASuU$EW?(>zzzzzzzzzzz!!!"
	ListBox $("WM"+setName+"ShowWaves"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo)= A"!!,B)!!#Be!!#BP!!#A1z!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
	ListBox $("WM"+setName+"ShowWaves"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#N3Bk1ct9L<efASuU$EW?(>zzzzzzzz"
	ListBox $("WM"+setName+"ShowWaves"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ct9L:L$Dfg)>D#aP9zzzzzzzzzzz!!!"
	Button $("WM"+setName+"SelectButton"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo)= A"!!,F-!!#BNJ,hoT!!#<Xz!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	Button $("WM"+setName+"SelectButton"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#N3Bk1ct9L<efASuU$EW?(>zzzzzzzz"
	Button $("WM"+setName+"SelectButton"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ct9L<efASuU$EW?(>zzzzzzzzzzz!!!"
	Button $("WM"+setName+"DeSelectButton"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo)= A"!!,G:!!#BNJ,hoT!!#<Xz!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	Button $("WM"+setName+"DeSelectButton"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#N3Bk1ct9L<efASuU$EW?(>zzzzzzzz"
	Button $("WM"+setName+"DeSelectButton"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ct9L<efASuU$EW?(>zzzzzzzzzzz!!!"
	Button $("WM"+setName+"SelectAllButton"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo)= A"!!,B)!!#BNJ,hp%!!#<Xz!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	Button $("WM"+setName+"SelectAllButton"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#N3Bk1ct9L<efASuU$EW?(>zzzzzzzz"
	Button $("WM"+setName+"SelectAllButton"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ct9L<efASuU$EW?(>zzzzzzzzzzz!!!"
	Button $("WM"+setName+"DeSelectAllButton"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo)= A"!!,H+!!#BNJ,hp%!!#<Xz!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	Button $("WM"+setName+"DeSelectAllButton"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#N3Bk1ct9L<efASuU$EW?(>zzzzzzzz"
	Button $("WM"+setName+"DeSelectAllButton"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ct9L<efASuU$EW?(>zzzzzzzzzzz!!!"
	SetVariable $("WM"+setName+"FilterWavesText"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo)= A"!!,BY!!#@,!!#A*!!#<Pz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	SetVariable $("WM"+setName+"FilterWavesText"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	SetVariable $("WM"+setName+"FilterWavesText"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
	Button $("WM"+setName+"FilterButton"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo)= A"!!,GN!!#@,!!#@@!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	Button $("WM"+setName+"FilterButton"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	Button $("WM"+setName+"FilterButton"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
	PopupMenu $("WM"+setName+"SetSourceType"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo)= A"!!,?X!!#=+!!#C\"J,hm.z!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
	PopupMenu $("WM"+setName+"SetSourceType"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	PopupMenu $("WM"+setName+"SetSourceType"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
	TitleBox $("WM"+setName+"SelectWavesText"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo)= A"!!,B)!!#>V!!#B9!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	TitleBox $("WM"+setName+"SelectWavesText"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	TitleBox $("WM"+setName+"SelectWavesText"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
	PopupMenu $("WM"+setName+"FilterType"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo)= A"!!,BY!!#?O!!#@b!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon\"Qzz"
	PopupMenu $("WM"+setName+"FilterType"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:Du]k<zzzzzzzzzzz"
	PopupMenu $("WM"+setName+"FilterType"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzz!!#u:Du]k<zzzzzzzzzzzzzz!!!"
	CheckBox $("WM"+setName+"AllowRepeats"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo)= A"!!,F7!!#B[!!#@*!!#<8z!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	CheckBox $("WM"+setName+"AllowRepeats"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#N3Bk1ct9L<efASuU$EW?(>zzzzzzzz"
	CheckBox $("WM"+setName+"AllowRepeats"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ct9L<efASuU$EW?(>zzzzzzzzzzz!!!"
	ListBox $("WM"+setName+"ShowWaves"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo)= A"!!,B)!!#Be!!#BP!!#A1z!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
	ListBox $("WM"+setName+"ShowWaves"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#N3Bk1ct9L<efASuU$EW?(>zzzzzzzz"
	ListBox $("WM"+setName+"ShowWaves"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ct9L:L$Dfg)>D#aP9zzzzzzzzzzz!!!"
	Button $("WM"+setName+"UpButton"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo)= A"!!,H]J,hsOJ,ho,!!#<Xz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	Button $("WM"+setName+"UpButton"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#N3Bk1ct9L:L%ASuU$EW?(>zzzzzzzz"
	Button $("WM"+setName+"UpButton"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ct9L:L%ASuU$EW?(>zzzzzzzzzzz!!!"
	Button $("WM"+setName+"DownButton"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo)= A"!!,H]J,hs^J,ho,!!#<Xz!!#o2B4uAezzzzzzzzzzzzzz!!#o2B4uAezz"
	Button $("WM"+setName+"DownButton"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#N3Bk1ct9L:L%ASuU$EW?(>zzzzzzzz"
	Button $("WM"+setName+"DownButton"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzz!!#N3Bk1ct9L:L%ASuU$EW?(>zzzzzzzzzzz!!!"
	TitleBox $("WM"+setName+"SetSourceTitle") win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo)= A"!!,B)z!!#@b!!#<@z!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
	TitleBox $("WM"+setName+"SetSourceTitle") win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:DuaGl9L:L%ASuU$EW?(>zzzzzzzz"
	TitleBox $("WM"+setName+"SetSourceTitle") win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzz!!#u:DuaGl9L:L%ASuU$EW?(>zzzzzzzzzzz!!!"
	GroupBox $("WM"+setName+"FilterBox") win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo)= A"!!,B)!!#?E!!#BMJ,ho@z!!#](Aon\"Qzzzzzzzzzzzzzz!!#](Aon#azz"
	GroupBox $("WM"+setName+"FilterBox") win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:DuaGl9L:L%ASuU$EW?(>zzzzzzzz"
	GroupBox $("WM"+setName+"FilterBox") win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzz!!#u:DuaGl9L:L%ASuU$EW?(>zzzzzzzzzzz!!!"
	TitleBox $("WM"+setName+"SetSourceText"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo)= A"!!,HQJ,ht&!!#>V!!#<Xz!!#](Aon\"Qzzzzzzzzzzzzzz!!#o2B4uAezz"
	TitleBox $("WM"+setName+"SetSourceText"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!#u:DuaGl9L:L%ASuU$EW?(>zzzzzzzz"
	TitleBox $("WM"+setName+"SetSourceText"),win=$(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzz!!#u:DuaGl9L:L%ASuU$EW?(>zzzzzzzzzzz!!!"
	
	SetWindow $(windowName+"#"+panelName),userdata(ResizeControlsInfo)= A"!!,B)!!#>F!!#C2!!#CcJ,fQLzzzzzzzzzzzzzzzzzzzz"
	SetWindow $(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzzzzzzzz"
	SetWindow $(windowName+"#"+panelName),userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzz!!!"
	SetWindow $(windowName+"#"+panelName),userdata(ResizeControlsGuides)= A"9L<efASuU$E]Zr]1/r124%qsr6>psfDf%R068Co>DKKH13r"
	SetWindow $(windowName+"#"+panelName),userdata(ResizeControlsInfoLBsCenter)= A":-hTC3_Vk]6Y1.WATBk68PV<U@<?!m7VQs@@;]Xm,?/)\\0gfksFCf?3:gn6QCa3(a@<Q4':gn6QCcbU!:dmEFF(KAR85E,T>#.mm5tj<o4&A^O8Q88W:-(0b0KVd)8OQ!%3_!(17o`,K75?nn69A(69MeM`8Q88W:-(']2*1"
	SetWindow $(windowName+"#"+panelName),userdata(ResizeControlsInfoLB2Top)= A":-hTC3_Vjq<,Z_;=%Q.J@UX@gBLZ]X:gn6QCa2nf@PL5gDKKH-FAQC`AS`So=(-8`F&6:_ASaG-=\\qOJ<HD_l4%N.F8Qnnb<'a2=0fr3-;b9q[:JNr,0eb[Z<CoSI0fhupF$jMVFCfJS7o`,K75?nc;FO8U:K'ha8P`)B0ebZ"
	SetWindow $(windowName+"#"+panelName),userdata(ResizeControlsInfoLB2Bottom)= A":-hTC3_Vjq6>psfDf%R;8PV<U@<?!m7VQs@@;]Xm,?/)\\0gfksFCf?3:gn6QCa3(a@<Q4':gn6QCcbU!:dmEFF(KAR85E,T>#.mm5tj<o4&A^O8Q88W:-(6i0KVd)8OQ!%3^uFt7o`,K75?nc;FO8U:K'ha8P`)B/N#T"
	SetWindow $(windowName+"#"+panelName),userdata(ResizeControlsInfoLB2Center)= A":-hTC3_Vjq6Y1.WATBk68PV<U@<?!m7VQs@@;]Xm,?/)\\0gfksFCf?3:gn6QCa3(a@<Q4':gn6QCcbU!:dmEFF(KAR85E,T>#.mm5tj<o4&A^O8Q88W:-(3f1-8!+8OQ!%3_Vjq<,Z_;7o`,K75?nn69A(69MeM`8Q88W:-(']2*1"
		
	SVAR folderName = packageDFR:dataFolder
	WMSCSSetFolder(folderName, setName, windowName+"#"+panelName)
	
	// use existing settings to initialize
	NVAR inputSource = packageDFR:inputSource
	if (inputSource & WMconstSingle2DInput || inputSource & WMconstCommonWaveInput)	
		ListBox $("WM"+setName+"SetWaves") win=$(windowName+"#"+panelName),mode=2
	else
		ListBox $("WM"+setName+"SetWaves") win=$(windowName+"#"+panelName),mode=3
	endif
	WMSCSUpdateInputFormat(setName, windowName+"#"+panelName, inputSource)
End

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////// get/set access functions /////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function WMSCSSetTitleStr(setName, win, titleName)
	String setName, win, titleName
	
	DFREF packageDFR = WMGetSCSPackageDFR(setName)
	
	SVAR titleStr = packageDFR:titleStr 
	titleStr =  titleName
	TitleBox  $("WM"+setName+"SetSourceTitle") win=$win, title=titleStr+" Input Data Format"
	TitleBox $("WM"+setName+"SelectWavesText") win=$win, title=titleStr+" Waves"
End

Function /S WMSCSGetInputSourceFolder(setName)
	String setName 
	
	DFREF packageDFR = WMGetSCSPackageDFR(setName)
	SVAR dataFolder = packageDFR:dataFolder
	return dataFolder
End

Function WMSCSGetNSelectedWaves(setName)
	String setName
	
	DFREF packageDFR = WMGetSCSPackageDFR(setName)
	WAVE /T listOfSelectedWaves = packageDFR:listOfSelectedWaves
	NVAR inputSource = packageDFR:inputSource
	SVAR dataFolder = packageDFR:dataFolder
	
	if (DimSize(listOfSelectedWaves,0)==0)
		return 0
	endif
	
	Variable nWaves
	if (inputSource & WMconstSingle2DInput)
		WAVE currWave = $(dataFolder + listOfSelectedWaves[0][1])
		nWaves = floor(DimSize(currWave, 1)/(1+(inputSource & WMconstXyPairsInput)/WMconstXyPairsInput))
	else
		nWaves = DimSize(listOfSelectedWaves, 0)
	endif
	
	return nWaves
End

// requires that the returnWave be already created with the /T flag
Function WMSCSGetSelectedWaveNames(setName, listOfSelectedWavesCopy)
	String setName
	Wave /T listOfSelectedWavesCopy
	
	DFREF packageDFR = WMGetSCSPackageDFR(setName)
	
	WAVE /T listOfSelectedWaves = packageDFR:listOfSelectedWaves	
	Duplicate /O/T listOfSelectedWaves listOfSelectedWavesCopy
End

// requires that the returnWave be already created with the /T flag
Function WMSCSGetBatchFolderWaveNames(setName, returnWave)
	String setName
	Wave /T returnWave

	DFREF packageDFR = WMGetSCSPackageDFR(setName)
	WAVE /T listOfWaveNames = packageDFR:listOfWaveNames

	Duplicate /O/T listOfWaveNames, returnWave
End

Function WMSCSGetSelectedWaves(setName, returnWave, [dataFolder])
	String setName
	Wave /WAVE returnWave
	String dataFolder
	
	DFREF packageDFR = WMGetSCSPackageDFR(setName)
	WAVE /T listOfSelectedWaves = packageDFR:listOfSelectedWaves
	if (ParamIsDefault(dataFolder))
		SVAR dFolder = packageDFR:dataFolder
		dataFolder = dFolder
	endif
	
	Variable i, nWaves = DimSize(listOfSelectedWaves, 0)
	
	Redimension /N=(nWaves) returnWave
	
	for (i=0; i<nWaves; i+=1)
		returnWave[i] = $(ReplaceString("::", dataFolder +":"+ PossiblyQuoteName(listOfSelectedWaves[i][1]), ":"))
	endfor
End

Function WMSCSGetInputType(setName)
	String setName
	
	DFREF packageDFR = WMGetSCSPackageDFR(setName)
	
	NVAR inputSource = packageDFR:inputSource
	return inputSource
End

Function WMSCSGetFilterSettings(setName, filterSettings)
	String setName
	Wave /T filterSettings  // to hold filterType, wildcardFilterText and grepFilterText, should already have a length of at least 3
	
	DFREF packageDFR = WMGetSCSPackageDFR(setName)
	
	SVAR filterType = packageDFR:filterType
	SVAR wildcardFilter = packageDFR:wildcardFilter
	SVAR grepFilter = packageDFR:grepFilter
	
	filterSettings[0]=filterType
	filterSettings[1]=wildcardFilter
	filterSettings[2]=grepFilter
End

Function WMSCSSetFilterSettings(setName, win, filterSettings)
	String setName, win
	Wave /Z/T filterSettings  
	
	DFREF packageDFR = WMGetSCSPackageDFR(setName)
	
	SVAR filterType = packageDFR:filterType
	SVAR wildcardFilter = packageDFR:wildcardFilter
	SVAR grepFilter = packageDFR:grepFilter
	SVAR waveFilterText = packageDFR:waveFilterText

	if (waveExists(filterSettings))	
		filterType = filterSettings[0]
		wildcardFilter = filterSettings[1]
		grepFilter = filterSettings[2]
		
		strswitch (filterType)
			case "none":
				waveFilterText = ""
				break
			case "wildcard":
				waveFilterText = wildcardFilter
				break
			case "regular expression":
				waveFilterText = grepFilter
				break
		endswitch
	else
		filterType = "none"
		waveFilterText = ""
	endif
	
	PopupMenu $("WM"+setName+"FilterType"), win=$(win), popmatch=filterType
	
	WMSCSUpdateWaveSelectList(setName, win)
End

Function WMSCSGetListBoxWidth(setName)
	String setName	
	DFREF packageDFR = WMGetSCSPackageDFR(setName)
	NVAR listBoxWidth = packageDFR:WMlistBoxWidth
	return listBoxWidth
End

Function WMSCSGetListBoxHeight(setName)
	String setName
	DFREF packageDFR = WMGetSCSPackageDFR(setName)
	NVAR listBoxHeight = packageDFR:WMlistBoxHeight
	return listBoxHeight
End

Function WMSCSSetListBoxWidth(setName, width, win)
	String setName, win
	Variable width
		
	DFREF packageDFR = WMGetSCSPackageDFR(setName)
	NVAR listBoxWidth = packageDFR:WMlistBoxWidth
	listBoxWidth = width
	
	WMSCSUpdateControlPositions(setName, win)
End

Function WMSCSSetListBoxHeight(setName, height, win)
	String setName, win
	Variable height
	
	DFREF packageDFR = WMGetSCSPackageDFR(setName)
	NVAR listBoxHeight = packageDFR:WMlistBoxHeight
	listBoxHeight = height
	
	WMSCSUpdateControlPositions(setName, win)
End

Function WMSCSUpdateControlPositions(setName, win)
	String SetName, win

	DFREF packageDFR = WMGetSCSPackageDFR(setName)
	NVAR listBoxHeight = packageDFR:WMlistBoxHeight
	NVAR listBoxWidth = packageDFR:WMlistBoxWidth
	
	PopupMenu $("WM"+setName+"SetSourceType") win=$(win), pos={col0Pos, row0Pos}
	TitleBox $("WM"+setName+"SelectWavesText") win=$(win), pos={col0Pos, row1Pos}
	PopupMenu $("WM"+setName+"FilterType") win=$(win), pos={col0Pos,row1Pos+25}
	Button $("WM"+setName+"FilterButton") win=$(win), pos={col0Pos+170,row1Pos+50}
	SetVariable $("WM"+setName+"FilterWavesText") win=$(win), pos={col0Pos, row1Pos+50}
	ListBox $("WM"+setName+"SetWaves") win=$(win),pos={col0Pos,row2Pos},size={listBoxWidth, listBoxHeight}
	Button $("WM"+setName+"SelectAllButton") win=$(win),pos={col0Pos+listBoxWidth/2-150,row2Pos+listBoxHeight+5},size={75, 20}
	Button $("WM"+setName+"SelectButton") win=$(win),pos={col0Pos+listBoxWidth/2-65,row2Pos+listBoxHeight+5}  
	Button $("WM"+setName+"DeSelectButton") win=$(win),pos={col0Pos+listBoxWidth/2+5,row2Pos+listBoxHeight+5}
	Button $("WM"+setName+"DeSelectAllButton") win=$(win),pos={col0Pos+listBoxWidth/2+75,row2Pos+listBoxHeight+5},size={75, 20}	
	Checkbox $("WM"+setName+"AllowRepeats") win=$(win),pos={col0Pos+listBoxWidth/2-60,row2Pos+listBoxHeight+30}
	ListBox $("WM"+setName+"ShowWaves") win=$(win),pos={col0Pos,row2Pos+listBoxHeight+50},size={listBoxWidth, listBoxHeight}
	Button $("WM"+setName+"UpButton") win=$(win),pos={col0Pos+listBoxWidth+10,row2Pos+listBoxHeight*3/2+10}
	Button $("WM"+setName+"DownButton") win=$(win),pos={col0Pos+listBoxWidth+10,row2Pos+listBoxHeight*3/2+40}
End

Function WMSCSSetDisableControl(setName, win, disable)
	String setName, win
	Variable disable
	
	PopupMenu $("WM"+setName+"SetSourceType") win=$(win), disable=disable
	TitleBox $("WM"+setName+"SelectWavesText") win=$(win), disable=disable
	PopupMenu $("WM"+setName+"FilterType") win=$(win), disable=disable
	Button $("WM"+setName+"FilterButton") win=$(win), disable=disable
	SetVariable $("WM"+setName+"FilterWavesText") win=$(win), disable=disable
	ListBox $("WM"+setName+"SetWaves") win=$(win), disable=0	//disable	//hidden LB on windows seem to leave artifacts
	Button $("WM"+setName+"SelectAllButton") win=$(win), disable=disable
	Button $("WM"+setName+"SelectButton") win=$(win), disable=disable
	Button $("WM"+setName+"DeSelectButton") win=$(win), disable=disable
	Button $("WM"+setName+"DeSelectAllButton") win=$(win), disable=disable
	Checkbox $("WM"+setName+"AllowRepeats") win=$(win), disable=disable
	ListBox $("WM"+setName+"ShowWaves") win=$(win), disable=0	//disable	//hidden LB on windows seem to leave artifacts
	Button $("WM"+setName+"UpButton") win=$(win), disable=disable
	Button $("WM"+setName+"DownButton") win=$(win), disable=disable
	
	//// if enabled update control able/disable based on input type
	if (!disable)
		DFREF packageDFR = WMGetSCSPackageDFR(setName)
		NVAR inputSource = packageDFR:inputSource
		WMSCSUpdateInputFormat(setName, win, inputSource)
	endif
End

Function WMSCSSetSlave(setName, win, slaveSetName, slaveWin)
	String setName, win, slaveSetName, slaveWin

	DFREF packageDFR = WMGetSCSPackageDFR(setName)
	
	NVAR inputSource = packageDFR:inputSource
	
	SVAR pkgSlaveSetName = packageDFR:slaveSetName
	pkgSlaveSetName = slaveSetName
	SVAR pkgSlaveWinName = packageDFR:slaveWinName
	pkgSlaveWinName = slaveWin
	
	WMSCSSetMaster(pkgSlaveSetName, pkgSlaveWinName, setName, win)
	
	ControlInfo /W=$(win)  $("WM"+setName+"SetSourceType")
	
	WMSCSUpdateInputFormat(slaveSetName, slaveWin, floor(convertTextToFormatVar(S_Value)/(2^WMconstSlaveShiftFactor)))
End

Function WMSCSSetMaster(setName, win, masterSetName, masterWin)
	String setName, win, masterSetName, masterWin

	DFREF packageDFR = WMGetSCSPackageDFR(setName)
	
	SVAR pkgMasterSetName = packageDFR:masterSetName
	pkgMasterSetName = masterSetName
	SVAR pkgMasterWinName = packageDFR:masterWinName
	pkgMasterWinName = masterWin
	
	KillControl /W=$(win)  $("WM"+setName+"SetSourceType")
	KillControl /W=$(win)  $("WM"+setName+"SetSourceTitle")
End

////////////////////////////////////////// setup functions /////////////////////////////////////////////
Function WMSCSInitOptions(stringListOfOptions, setName, win)
	String stringListOfOptions, setName, win
	
	DFREF packageDFR = WMGetSCSPackageDFR(setName)
	
	String /G packageDFR:inputOptionsList = stringListOfOptions	
	// Make sure the current input source is the first of the inputOptionsList
	
	String firstOption = StringFromList(0, stringListOfOptions)
	Variable format = convertTextToFormatVar(firstOption)
	Variable i, lowerMask=0
	for (i=0; i<WMconstSlaveShiftFactor;i+=1)
		lowerMask += 2^i
	endfor
	
	WMSCSUpdateInputFormat(setName, win, format & lowerMask)
End

Function WMSCSSetFolder(folderName, setName, win)
	String folderName, setName, win

	folderName = ReplaceString("::", folderName+":", ":")
	if (!DataFolderExists(folderName))
		WMSCSerrReport(errDataFolderNonExist)
		return 0
	endif

	DFREF packageDFR = WMGetSCSPackageDFR(setName)
	String packageDFRString = GetDataFolder(1, packageDFR)
	
	WAVE /T listOfWaveNames = packageDFR:listOfWaveNames
	WAVE /B selectWave = packageDFR:selectWave
	WAVE /T listOfSelectedWaves = packageDFR:listOfSelectedWaves
	WAVE /B selectSelectedWave = packageDFR:selectSelectedWave
	
	String dataFolder = StrVarOrDefault(packageDFRString+"dataFolder", folderName)
	if (cmpStr(dataFolder, folderName))
		Redimension /N=0 listOfSelectedWaves
		Redimension /N=0 selectSelectedWave 
	endif
	
	String /G packageDFR:dataFolder = folderName
	WMSCSupdateWaveSelectList(setName, win)
End

Function WMSCSSetSelected(folderName, setName, win, selWaveNames)
	String folderName, setName, win
	Wave /T/Z selWaveNames

	if (!waveExists(selWaveNames))
		Make /T/Free/N=0 selWaveNames
	endif

	DFREF packageDFR = WMGetSCSPackageDFR(setName)
	Wave /T listOfSelectedWaves = packageDFR:listOfSelectedWaves
	Wave /B selectSelectedWave = packageDFR:selectSelectedWave	
 	String listOfMissingWaveNames = ""
	String utilityStr = ""
	Variable i, curri=0, nWaves = numpnts(selWaveNames)

	Redimension /N=(nWaves, 2) listOfSelectedWaves, selectSelectedWave
	for (i=0; i<nWaves; i+=1)
		Wave /Z testExistsRef = $(ReplaceString("::", folderName+":"+PossiblyQuoteName(selWaveNames[i]), ":"))
		if (waveExists(testExistsRef)==1)
			listOfSelectedWaves[curri][1] = selWaveNames[i]
			curri+=1
		else 
			listOfMissingWaveNames += selWaveNames[i]+";"
		endif
	endfor
	Redimension /N=(curri, 2) listOfSelectedWaves, selectSelectedWave

	nWaves = DimSize(listOfSelectedWaves,0)
	for (i=0; i<nWaves; i+=1)
		listOfSelectedWaves[i][0] = num2str(i)+":"
	endfor
	
	if (strlen(listOfMissingWaveNames)>0)
		DoAlert /T="Load Batch Error: waves in batch missing in data folder" 0, listOfMissingWaveNames
	endif
End

Function WMSCSUpdateWaveSelectList(setName, win)
	String setName, win

	DFREF packageDFR = WMGetSCSPackageDFR(setName)
	String packageDFRString = GetDataFolder(1, packageDFR)
	
	SVAR dataFolder = packageDFR:dataFolder
	NVAR inputSource = packageDFR:inputSource
	
	WAVE /Z/T listOfWaveNames = packageDFR:listOfWaveNames
	WAVE /Z/B selectWave = packageDFR:selectWave
		
	String savedDataFolder = GetDataFolder(1)
	SetDataFolder packageDFR
	ControlInfo /W=$(win) $("WM"+setName+"SetWaves") 
	String selectedWaves
		
	if (V_Flag && dataFolderExists(dataFolder))
		Variable i, nFilteredWaves, currIndx=0
		Variable nWaves = CountObjects(dataFolder, 1)	
		String currStr
				
		// fill up the list of waves that satisfy dimensional criteria
		Make /FREE /T/N=(nWaves) dirWaves
		for (i=0; i<nWaves; i+=1)
			currStr=PossiblyQuoteName(GetIndexedObjName(dataFolder, 1, i))
			WAVE currWave = $(ReplaceString("::", dataFolder+":"+currStr, ":"))
			if (WMSCSWaveIsCorrectDims(currWave, inputSource))
				dirWaves[currIndx]=currStr
				currIndx+=1
			endif
		endfor
		Redimension /N=(currIndx) dirWaves
	
		SVAR grepText = packageDFR:waveFilterText
		ControlInfo /W=$(win) $("WM"+setName+"FilterType")
		String filterType = S_Value

		// now put the directory waves that satisfy dimensional criterial through the current filter
		nWaves = numpnts(dirWaves)

		strswitch (filterType)
			case "none":
				Duplicate /O/T dirWaves listOfWaveNames
				Redimension /N=(nWaves) selectWave
				break
			case "wildcard":
				Redimension /N=(nWaves) listOfWaveNames
				currIndx=0
				for (i=0; i<nWaves; i+=1)
					if (stringmatch(dirWaves[i], grepText))
						listOfWaveNames[currIndx]=dirWaves[i]
			 			currIndx += 1
					endif
				endfor
				Redimension /N=(currIndx) listOfWaveNames, selectWave
				break
			case "regular expression":
				Grep/E=grepText/Q/INDX dirWaves
				WAVE indx = W_Index
				Redimension /N=(numpnts(indx)) listOfWaveNames, selectWave
				for (i=0; i<numpnts(indx); i+=1)
					listOfWaveNames[i]=dirWaves[indx[i]]
				endfor
				break
			default:
				break
		endswitch
	
		selectWave = 0
		
		ListBox $("WM"+setName+"SetWaves") win=$(win),  listWave=listOfWaveNames, selWave=selectWave 	
		
		WMSCSUpdateControlEnableStatus(setName, win)
	endif
	SetDataFolder savedDataFolder
End

Function WMSCSWaveIsCorrectDims(aWave, inputSource)
	Wave aWave
	Variable inputSource
	
	if (inputSource & WMconstSingle2DInput && DimSize(aWave, 1) >1)
		return 1
	endif
	if (inputSource & WMconstCollection1DInput)
		if (inputSource & WMconstXyPairsInput)
			if (DimSize(aWave, 1) ==2)
				return 1
			endif
		elseif (DimSize(aWave, 1) <=1)
			return 1
		endif
	endif
	if (inputSource & WMconstCommonWaveInput && DimSize(aWave, 1) <=1)
		return 1
	endif
	
	return 0
End

////////////////////////////////////////// utility functions /////////////////////////////////////////////

Function WMSCSAllowRepeatsProc(CB_Struct) : CheckBoxControl
	STRUCT WMCheckboxAction &CB_Struct

	if (CB_Struct.eventCode==2)
		String setName = WMGetSetNameFromCtrl(CB_Struct.ctrlName, "AllowRepeats")
		DFREF packageDFR = WMGetSCSPackageDFR(setName)
	
		if (!CB_Struct.checked)
			WAVE /T listOfSelectedWaves = packageDFR:listOfSelectedWaves
			WAVE /B selectSelectedWave = packageDFR:selectSelectedWave
		
			Make /FREE /B /N=(DimSize(listOfSelectedWaves,0)) deleteIndices=0
			Variable i, j
		
			///////// find the indices to delete
			for (i=0; i<DimSize(listOfSelectedWaves,0); i = i+1)		
				for (j=i+1; j<DimSize(listOfSelectedWaves,0); )				
					if (!CmpStr(listOfSelectedWaves[i][1], listOfSelectedWaves[j][1]))
						DeletePoints j, 1, listOfSelectedWaves, selectSelectedWave
					else
						j+=1
					endif
				endfor
			endfor
			Variable nWaves = DimSize(listOfSelectedWaves,0)
			for (i=0; i<nWaves; i+=1)
				listOfSelectedWaves[i][0] = num2str(i)+":"
			endfor
		endif
	endif						
End

////// This function takes any of any of a large number of of popup texts and returns a format variable with data stored bitwise 
////// Includes possibility of getting a second (slave) format variable
Function convertTextToFormatVar(popupText)
	String popupText
	
	Variable ret=0
	
	strswitch (popupText)
		case WMSCSInForm2D:
			ret = WMconstSingle2DInput
			break
		case WMSCSInForm1Dset:
			ret = WMconstCollection1DInput
			break
		case WMSCSInFormScale:
			ret = WMconstWaveScalingInput			
			break
		case WMSCSInFormOneWave:
			ret = WMconstCommonWaveInput			
			break
		case WMSCSInFormXY:
			ret = WMconstXyPairsInput
			break			
		case WMSCSInForm2DScale:
			ret = WMconstSingle2DInput + WMconstWaveScalingInput *2^WMconstSlaveShiftFactor
			break
		case WMSCSInForm2D1Dset:
			ret = WMconstSingle2DInput + WMconstCollection1DInput *2^WMconstSlaveShiftFactor
			break
		case WMSCSInForm2D1D:
			ret = WMconstSingle2DInput + WMconstCommonWaveInput *2^WMconstSlaveShiftFactor
			break
		case WMSCSInForm2D2D:
			ret = WMconstSingle2DInput + WMconstSingle2DInput *2^WMconstSlaveShiftFactor
			break
		case WMSCSInForm2Dxy:
			ret = WMconstSingle2DInput + WMconstXyPairsInput + WMconstXyPairsInput *2^WMconstSlaveShiftFactor
			break
		case WMSCSInForm1DsetScale:
			ret = WMconstCollection1DInput + WMconstWaveScalingInput *2^WMconstSlaveShiftFactor
			break
		case WMSCSInForm1Dset1Dset:
			ret = WMconstCollection1DInput + WMconstCollection1DInput *2^WMconstSlaveShiftFactor
			break
		case WMSCSInForm1Dset1D:
			ret = WMconstCollection1DInput + WMconstCommonWaveInput *2^WMconstSlaveShiftFactor
			break
		case WMSCSInForm1Dset2D:
			ret = WMconstCollection1DInput + WMconstSingle2DInput *2^WMconstSlaveShiftFactor
			break
		case WMSCSInForm1Dsetxy:
			ret = WMconstCollection1DInput + WMconstXyPairsInput + WMconstXyPairsInput *2^WMconstSlaveShiftFactor
			break	
		default:
			break
	endswitch
	
	return ret
End

Function /S convertFormatVarToText(var)
	Variable var
	
	String ret=""
	
	switch (var)
		case WMconstSingle2DInput:
			ret = WMSCSInForm2D
			break
		case WMconstCollection1DInput:
			ret = WMSCSInForm1Dset
			break
		case WMconstWaveScalingInput:
			ret = WMSCSInFormScale			
			break
		case WMconstCommonWaveInput:
			ret = WMSCSInFormOneWave			
			break
		case WMconstXyPairsInput:
			ret = WMSCSInFormXY
			break			
		case 129://WMconstSingle2DInput + WMconstWaveScalingInput *2^WMconstSlaveShiftFactor:
			ret = WMSCSInForm2DScale
			break
		case 65://WMconstSingle2DInput + WMconstCollection1DInput *2^WMconstSlaveShiftFactor:
			ret = WMSCSInForm2D1Dset
			break
		case 257://WMconstSingle2DInput + WMconstCommonWaveInput *2^WMconstSlaveShiftFactor:
			ret = WMSCSInForm2D1D
			break
		case 33://WMconstSingle2DInput + WMconstSingle2DInput *2^WMconstSlaveShiftFactor:
			ret = WMSCSInForm2D2D
			break
		case 529://WMconstSingle2DInput + WMconstXyPairsInput + WMconstXyPairsInput *2^WMconstSlaveShiftFactor:
			ret = WMSCSInForm2Dxy
			break
		case 130://WMconstCollection1DInput + WMconstWaveScalingInput *2^WMconstSlaveShiftFactor:
			ret = WMSCSInForm1DsetScale
			break
		case 66://WMconstCollection1DInput + WMconstCollection1DInput *2^WMconstSlaveShiftFactor:
			ret = WMSCSInForm1Dset1Dset
			break
		case 258://WMconstCollection1DInput + WMconstCommonWaveInput *2^WMconstSlaveShiftFactor:
			ret = WMSCSInForm1Dset1D
			break
		case 34://WMconstCollection1DInput + WMconstSingle2DInput *2^WMconstSlaveShiftFactor:
			ret = WMSCSInForm1Dset2D
			break
		case 530://WMconstCollection1DInput + WMconstXyPairsInput + WMconstXyPairsInput *2^WMconstSlaveShiftFactor:
			ret = WMSCSInForm1Dsetxy
			break	
		default:
			break
	endswitch
	
	return ret
End

Function WMSetFilterType(PU_Struct) : PopupMenuControl
	STRUCT WMPopupAction &PU_Struct
	
	if (PU_Struct.eventCode == 2)
		String setName = WMGetSetNameFromCtrl(PU_Struct.ctrlName, "FilterType")
	
		DFREF packageDFR = WMGetSCSPackageDFR(setName)
		SVAR filterType = packageDFR:filterType
		SVAR filterStr = packageDFR:waveFilterText
	
		if (Cmpstr(PU_Struct.popStr, filterType))
			if (!CmpStr(PU_Struct.popStr, "wildcard"))
				SVAR wildcardFilter = packageDFR:wildcardFilter
				filterStr = wildcardFilter
			elseif (!CmpStr(PU_Struct.popStr, "regular expression"))
				SVAR grepFilter = packageDFR:grepFilter
				filterStr = grepFilter			
			else 
				filterStr = ""
			endif
	
			filterType = PU_Struct.popStr
			WMSCSUpdateWaveSelectList(setName, PU_struct.win)
		endif
	endif
End

Function WMFilterWaveNames(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	if (B_Struct.eventCode == 1) // mouse down
		String setName = WMGetSetNameFromCtrl(B_Struct.ctrlName, "FilterButton")    
	
		DFREF packageDFR = WMGetSCSPackageDFR(setName)

		WMSCSUpdateWaveSelectList(setName, B_struct.win)
		
		SVAR filterType = packageDFR:filterType
		SVAR filterStr = packageDFR:waveFilterText
		if (!CmpStr(filterType, "wildcard"))
			SVAR wildcardFilter = packageDFR:wildcardFilter
			wildcardFilter = filterStr
		elseif (!CmpStr(filterType, "regular expression"))
			SVAR grepFilter = packageDFR:grepFilter
			grepFilter = filterStr
		endif
	endif
End

Function WMSCSSelectWavesProc(B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	if (B_Struct.eventCode == 1) // mouse down	
		Variable i, j, doAdd, add, all, nWaves, mode, currRow, nSelectedWaves, nWaveNames, col1Width
		
		add = !stringmatch(B_Struct.ctrlName, "*DeSelect*") 
		all = stringmatch(B_Struct.ctrlName, "*All*")
	
		String setName
		if (add)
			if (all)
				setName = WMGetSetNameFromCtrl(B_Struct.ctrlName, "SelectAllButton") 
			else
				setName = WMGetSetNameFromCtrl(B_Struct.ctrlName, "SelectButton") 
			endif
		else
			if (all)
				setName = WMGetSetNameFromCtrl(B_Struct.ctrlName, "DeSelectAllButton")
			else
				setName = WMGetSetNameFromCtrl(B_Struct.ctrlName, "DeSelectButton")			
			endif
		endif
	
		DFREF packageDFR = WMGetSCSPackageDFR(setName)
		NVAR valsSourceType = packageDFR:inputSource
	
		String savedDataFolder

		if (add)
			WAVE /T listOfWaveNames = packageDFR:listOfWaveNames
			WAVE /B selectWave = packageDFR:selectWave	
			WAVE /T listOfSelectedWaves = packageDFR:listOfSelectedWaves
			WAVE /B selectSelectedWave = packageDFR:selectSelectedWave
		
			if (valsSourceType & WMconstSingle2DInput || valsSourceType & WMconstCommonWaveInput)	
				mode=2		
				savedDataFolder = GetDataFolder(1)
				SetDataFolder  packageDFR
				ControlInfo /W=$(B_Struct.win) $("WM"+setName+"SetWaves")
				currRow = V_Value
				SetDataFolder savedDataFolder
			elseif (valsSourceType & WMconstCollection1DInput)
				mode=3
			endif
		else
			WAVE /T listOfSelectedWaves = packageDFR:listOfSelectedWaves
			WAVE /B selectSelectedWave = packageDFR:selectSelectedWave
			add=0
		endif

		if (add)
			NVAR allowRepeats = packageDFR:allowRepeats
			Make /FREE /T /N=(DimSize(listOfWaveNames,0)) wavesToAdd
			if (mode==3)
				nWaves = 0
				nSelectedWaves = DimSize(listOfSelectedWaves,0)
				nWaveNames = DimSize(listOfWaveNames,0)   
				for (i=0; i<nWaveNames; i+=1)	
					if (selectWave[i] & 1 || all)
						doAdd=1
						/////// don't allow duplicates 
						if (!allowRepeats)
							for (j=0; j<nSelectedWaves; j+=1)    
								if (!cmpStr(listOfWaveNames[i], listOfSelectedWaves[j][1]))
									doAdd=0
									break
								endif
							endfor
						endif
						if (doAdd)
							wavesToAdd[nWaves]=listOfWaveNames[i]
							nWaves += 1
						endif
					endif
				endfor
			else  // controlInfo called above to get the right ListBox
				nWaves=0
				if (currRow>=0)
					wavesToAdd[0]=listOfWaveNames[currRow]
					nWaves=1
				endif
			endif
				
			Variable nCurrSWEnd = DimSize(listOfSelectedWaves,0)
			Redimension /N=(nCurrSWEnd+nWaves, 2) listOfSelectedWaves, selectSelectedWave   
			for (i=0; i<nWaves; i+=1)			
				listOfSelectedWaves[nCurrSWEnd+i][0] = num2str(nCurrSWEnd+i)+":"
				listOfSelectedWaves[nCurrSWEnd+i][1]= wavesToAdd[i]
			endfor
			
			Variable dbg2 = ceil(log(DimSize(listOfSelectedWaves,0)+.1))
			dbg2 = log(DimSize(listOfSelectedWaves,0))
						
			col1Width = 10*(max(ceil(log(nCurrSWEnd+nWaves)), 1)+1)
			ListBox $("WM"+setName+"ShowWaves") win=$(B_Struct.win), widths={col1Width, 200}     
		else    // this implementation requires that the ListBox mode setting be mode=3
			Variable startpt=-1

			nSelectedWaves = DimSize(listOfSelectedWaves,0)
			nWaveNames = DimSize(listOfWaveNames,0)   		
			for (i=0; i<nSelectedWaves; i+=1)   		
				if (selectSelectedWave[i][0] & 1 || all)
					startpt = startpt >= 0 ? startpt : i
					nWaves += 1
				endif
			endfor
			if (startpt >=0)
				DeletePoints startpt, nWaves, listOfSelectedWaves, selectSelectedWave    
			
				/////// renumber
				nSelectedWaves = DimSize(listOfSelectedWaves,0)
				for (i=0; i<nSelectedWaves; i+=1)	
					listOfSelectedWaves[i][0] = num2str(i)+":"
				endfor	
				if (DimSize(listOfSelectedWaves,0) > 0)
					Variable dbg = ceil(log(DimSize(listOfSelectedWaves,0))+1)
					dbg = log(DimSize(listOfSelectedWaves,0))
					col1Width = 10*(max(ceil(log(DimSize(listOfSelectedWaves,0))),1)+1)
					ListBox $("WM"+setName+"ShowWaves") win=$(B_Struct.win), widths={col1Width, 200}
				endif
			endif
		endif
		
		WMSCSUpdateControlEnableStatus(setName, B_Struct.win)
	endif
End

Function WMSCSSetInputFormatPopup(PU_Struct) : PopupMenuControl
	STRUCT WMPopupAction &PU_Struct
	
	if (PU_Struct.eventCode == 2)  // mouse up
		String setName = WMGetSetNameFromCtrl(PU_Struct.ctrlName, "SetSourceType")
	
		Variable format = convertTextToFormatVar(PU_Struct.popStr)

		WMSCSSetInputFormat(setName, PU_Struct.win, format)
	endif
End

Function WMSCSSetInputFormat(setName, win, format)
	String setName, win
	Variable format
	
	Variable i, lowerMask=0
	for (i=0; i<WMconstSlaveShiftFactor;i+=1)
		lowerMask += 2^i
	endfor
	
	WMSCSUpdateInputFormat(setName, win, format & lowerMask)
	
	DFREF packageDFR = WMGetSCSPackageDFR(setName)
	SVAR slaveSetName = packageDFR:slaveSetName
	SVAR slaveWinName = packageDFR:slaveWinName
	DFREF slavePackageDFR = WMGetSCSPackageDFR(slaveSetName)
	String packageDFRString = GetDataFolder(1, slavePackageDFR)
		
	String popupText = convertFormatVarToText(format)	
	PopupMenu $("WM"+setName+"SetSourceType") win=$(win), popmatch=popupText	
		
	if (strlen(slaveSetName) && DataFolderExists(packageDFRString))
		WMSCSUpdateInputFormat(slaveSetName, slaveWinName, floor(format/(2^WMconstSlaveShiftFactor)))
	endif	
End

Function WMSCSUpdateControlEnableStatus(setName, win)
	String setName, win
	
	DFREF packageDFR = WMGetSCSPackageDFR(setName)
	NVAR inputSource = packageDFR:inputSource
	Variable previousSource = inputSource
	SVAR filterType = packageDFR:filterType
	NVAR inputSource = packageDFR:inputSource

	WAVE /Z/T listOfSelectedWaves = packageDFR:listOfSelectedWaves
	WAVE /Z/B selectSelectedWave = packageDFR:selectSelectedWave

	switch (inputSource)     
		case WMconstSingle2DInput:
			SetWindow $win, hide=0
			ListBox $("WM"+setName+"SetWaves"),win=$win, mode=2, disable=0	
			Button $("WM"+setName+"DeSelectButton") win=$win, disable=0
			Button $("WM"+setName+"SelectAllButton") win=$win, disable=2
			Button $("WM"+setName+"DeSelectAllButton") win=$win, disable=0
			
			if (!waveExists(listOfSelectedWaves) || DimSize(listOfSelectedWaves,0)==0)
				Button $("WM"+setName+"SelectButton") win=$win, disable=0
			else	
				Button $("WM"+setName+"SelectButton") win=$win, disable=2
			endif
			
			break
		case WMconstCollection1DInput:
			SetWindow $win, hide=0
			ListBox $("WM"+setName+"SetWaves"),win=$win, mode=3, disable=0	
			Button $("WM"+setName+"SelectButton") win=$win, disable=0
			Button $("WM"+setName+"DeSelectButton") win=$win, disable=0
			Button $("WM"+setName+"SelectAllButton") win=$win, disable=0
			Button $("WM"+setName+"DeSelectAllButton") win=$win, disable=0
			break
		case WMconstCommonWaveInput:
			SetWindow $win, hide=0	
			ListBox $("WM"+setName+"SetWaves") win=$win, disable=0, mode=2
			Button $("WM"+setName+"DeSelectButton") win=$win, disable=0
			Button $("WM"+setName+"SelectAllButton") win=$win, disable=2
			Button $("WM"+setName+"DeSelectAllButton") win=$win, disable=0
			
			if (!waveExists(listOfSelectedWaves) || DimSize(listOfSelectedWaves,0)==0)
				Button $("WM"+setName+"SelectButton") win=$win, disable=0
			else	
				Button $("WM"+setName+"SelectButton") win=$win, disable=2
			endif
			
			break
		case WMconstWaveScalingInput:	
			SetWindow $win, hide=1
			break
		case WMconstXyPairsInput:
			SetWindow $win, hide=1
			break		
		case WMconst2Dxy:
			SetWindow $win, hide=0
			ListBox $("WM"+setName+"SetWaves"),win=$win, mode=2, disable=0
			Button $("WM"+setName+"DeSelectButton") win=$win, disable=0
			Button $("WM"+setName+"SelectAllButton") win=$win, disable=2
			Button $("WM"+setName+"DeSelectAllButton") win=$win, disable=0
			
			if (!waveExists(listOfSelectedWaves) || DimSize(listOfSelectedWaves,0)==0)
				Button $("WM"+setName+"SelectButton") win=$win, disable=0
			else	
				Button $("WM"+setName+"SelectButton") win=$win, disable=2
			endif
			
			break
		case WMconst1Dxy:
			SetWindow $win, hide=0
			ListBox $("WM"+setName+"SetWaves"),win=$win, mode=3, disable=0
			Button $("WM"+setName+"SelectButton") win=$win, disable=0
			Button $("WM"+setName+"DeSelectButton") win=$win, disable=0
			Button $("WM"+setName+"SelectAllButton") win=$win, disable=0
			Button $("WM"+setName+"DeSelectAllButton") win=$win, disable=0
		default:
			break
	endswitch
	
	strswitch (filterType)
		case "wildcard":
			SetVariable $("WM"+setName+"FilterWavesText") win=$(win), disable=0, noedit=0
			Button $("WM"+setName+"FilterButton") win=$(win), disable=0
			break
		case "regular expression":
			SetVariable $("WM"+setName+"FilterWavesText") win=$(win), disable=0, noedit=0
			Button $("WM"+setName+"FilterButton") win=$(win), disable=0
			break
		default:
			SetVariable $("WM"+setName+"FilterWavesText") win=$(win), disable=2
			Button $("WM"+setName+"FilterButton") win=$(win), disable=2
			break
	endswitch	
End

Function WMSCSUpdateInputFormat(setName, win, format)
	String setName, win
	Variable format
	
	DFREF packageDFR = WMGetSCSPackageDFR(setName)
	NVAR inputSource = packageDFR:inputSource
	Variable previousSource = inputSource
	SVAR filterType = packageDFR:filterType

	switch (format)     
		case WMconstSingle2DInput:
			SetWindow $win, hide=0
			inputSource = WMconstSingle2DInput
			break
		case WMconstCollection1DInput:
			SetWindow $win, hide=0
			inputSource = WMconstCollection1DInput
			break
		case WMconstCommonWaveInput:
			SetWindow $win, hide=0
			inputSource = WMconstCommonWaveInput		
			break
		case WMconstWaveScalingInput:
			inputSource = WMconstWaveScalingInput			
			SetWindow $win, hide=1
			break
		case WMconstXyPairsInput:
			inputSource = WMconstXyPairsInput
			SetWindow $win, hide=1
			break		
		case WMconst2Dxy:
			SetWindow $win, hide=0
			inputSource = WMconstSingle2DInput + WMconstXyPairsInput
			break
		case WMconst1Dxy:
			SetWindow $win, hide=0
			inputSource = WMconstCollection1DInput + WMconstXyPairsInput
		default:
			break
	endswitch
	
	if (previousSource != inputSource)
		WAVE /T listOfSelectedWaves = packageDFR:listOfSelectedWaves
		WAVE /B selectSelectedWave = packageDFR:selectSelectedWave	
		Redimension /N=0 listOfSelectedWaves, selectSelectedWave
	
		WMSCSUpdateWaveSelectList(setName, win)
	endif
	
	WMSCSUpdateControlEnableStatus(setName, win)
End

Function /S WMListInputOptions(setName)
	String SetName
		
	String packageFolderStr = GetDataFolder(1,  WMGetSCSPackageDFR(setName))
	
	SVAR /Z ioL = $(packageFolderStr+"inputOptionsList")
	if (!SVAR_exists(ioL))
		WMSCSErrReport(errInputOptionsUninitialized)
		return ""
	else 
		return ioL
	endif
End

Function /S WMGetSetNameFromCtrl(ctrlName, ctrlNamePostfix)
	String ctrlName, ctrlNamePostfix

	return ctrlName[2,strlen(ctrlName)-strlen(ctrlNamePostfix)-1]
End

Function WMSCSMoveSelected (B_Struct) : ButtonControl
	STRUCT WMButtonAction &B_Struct
	
	if (B_Struct.eventCode == 1) // mouse down	
		Variable direction = -1 + 2*stringmatch(B_Struct.ctrlName, "*Down*")
	
		String setName
		if (direction > 0)
			setName = WMGetSetNameFromCtrl(B_Struct.ctrlName, "DownButton")
		else
			setName = WMGetSetNameFromCtrl(B_Struct.ctrlName, "UpButton")
		endif
		
		DFREF packageDFR = WMGetSCSPackageDFR(setName)
		
		String savedDataFolder = GetDataFolder(1)
		SetDataFolder packageDFR
	
		WAVE /T listWave = packageDFR:listOfSelectedWaves
		WAVE /B selectWave = packageDFR:selectSelectedWave	
				
		Variable nWaves =DimSize(listWave, 0)	
		Variable i, j
		String utilityStr
		Variable utilityVar, indx, utility2
		
		Variable start = direction==1 ? nWaves-1 : 0
		
		Variable leadRow = -1		
		for (i=direction==1 ? nWaves-2 : 1; i<nWaves && i >=0; i-=direction)
			if (selectWave[i] & 1)
				if (leadRow==-1 || i < -direction * leadRow)
					leadRow = i+direction
				endif
				if ( !(i+direction<0 || i+direction==nWaves) && !(selectWave[i+direction] & 1))
					utilityStr = listWave[i+direction][1]
					listWave[i+direction][1] = listWave[i][1]
					listWave[i][1] = utilityStr
					utilityVar = selectWave[i+direction]
					selectWave[i+direction] = selectWave[i]
					selectWave[i] = utilityVar
				endif
			endif
		endfor
		
		ControlInfo /W=$(B_Struct.win) $("WM"+setName+"ShowWaves")	
		Variable botRow = V_startRow + V_Height/V_rowHeight
		if ((leadRow < V_startRow || leadRow > botRow) && leadRow >=0)		
			ListBox $("WM"+setName+"ShowWaves") win=$(B_Struct.win), row=max(0, ceil((leadRow-V_Height/V_rowHeight/2)))
		endif
	endif
End

//////////////////////////////////////// Error Messages //////////////////////////////////////////////
static constant errInputOptionsUninitialized = 1
static constant errDataFolderNonExist = 2

Function WMSCSErrReport(errNum)
	Variable errNum

	String errString

	switch (errNum)
		case errInputOptionsUninitialized:
			errString = "Input options have not been initialized.  Use initOptions(stringListOfOptions) prior to calling this function"
			break
		case errDataFolderNonExist:
			errString = "Warning, the source data folder does not exist"
			break
		default:
			break
	
	endswitch
	
	DoAlert /T="WMSelectorControlSet Error" 0, errString
End

//////////////////////////////////////// Package Folder //////////////////////////////////////////////

Function /DF WMGetSCSPackageDFR(setName)
	String setName

	DFREF dfr = $(selectorControlFolderBase + setName)
	if (DataFolderRefStatus(dfr) != 1)
		NewDataFolder/O root:Packages
		NewDataFolder/O $selectorControlFolderBase
		NewDataFolder/O $(selectorControlFolderBase + ":" + setName)
	endif
	DFREF dfr = $(selectorControlFolderBase + ":" + setName)
	String /G dfr:setName = setName
	WMInitSCSFolderPackageData(dfr)
	return dfr
End

Function WMInitSCSFolderPackageData(dfr)
	DFREF dfr
	
	String packageDFRString = GetDataFolder(1, dfr)

	///// data variables /////
	String localStr
	Variable localVar
	
	localStr = StrVarOrDefault(packageDFRString+"waveFilterText", "")
	String /G dfr:waveFilterText = localStr
	localStr = StrVarOrDefault(packageDFRString+"dataFolder", "")
	String /G dfr:dataFolder = localStr
	localVar = NumVarOrDefault(packageDFRString+"inputSource", WMconstSingle2DInput)
	Variable /G dfr:inputSource = localVar
	// if this set has a master set that needs to be adjusted in some circumstances.  Needed for y vs x selections
	localStr = StrVarOrDefault(packageDFRString+"masterSetName", "")
	String /G dfr:masterSetName = localStr
	// if this set has a master set that needs to be adjusted in some circumstances.  Needed for y vs x selections
	localStr = StrVarOrDefault(packageDFRString+"masterWinName", "")
	String /G dfr:masterWinName = localStr
	// if this set has a slave set that needs to be adjusted in some circumstances.  Needed for y vs x selections
	localStr = StrVarOrDefault(packageDFRString+"slaveSetName", "")
	String /G dfr:slaveSetName = localStr
	// if this set has a slave set that needs to be adjusted in some circumstances.  Needed for y vs x selections
	localStr = StrVarOrDefault(packageDFRString+"slaveWinName", "")
	String /G dfr:slaveWinName = localStr
	// if this set has a slave set that needs to be adjusted in some circumstances.  Needed for y vs x selections
	SVAR setName = dfr:setName
	
	localStr = StrVarOrDefault(packageDFRString+"titleStr", setName)
	String /G dfr:titleStr = localStr
	
	Wave /Z/T testExistsRef0 = $(packageDFRString+"listOfWaveNames")
	if (!waveExists(testExistsRef0))
		Make /T/N=0 dfr:listOfWaveNames
	endif
	Wave /Z testExistsRef1 = $(packageDFRString+"selectWave")
	if (!waveExists(testExistsRef1))
		Make /B/N=0 dfr:selectWave	
	endif
	Wave /Z/T testExistsRef0 = $(packageDFRString+"listOfSelectedWaves")
	if (!waveExists(testExistsRef0))
		Make /T/N=0 dfr:listOfSelectedWaves
	endif
	Wave /Z testExistsRef1 = $(packageDFRString+"selectSelectedWave")
	if (!waveExists(testExistsRef1))
		Make /B/N=0 dfr:selectSelectedWave
	endif
	
	localVar = NumVarOrDefault(packageDFRString+"WMlistBoxHeight", 200)
	Variable /G dfr:WMlistBoxHeight = localVar
	localVar = NumVarOrDefault(packageDFRString+"WMlistBoxWidth", 320)
	Variable /G dfr:WMlistBoxWidth = localVar
	localStr = StrVarOrDefault(packageDFRString+"filterType", "none")
	String /G dfr:filterType = localStr
	localStr = StrVarOrDefault(packageDFRString+"wildcardFilter", "*")
	String /G dfr:wildcardFilter = localStr
	localStr = StrVarOrDefault(packageDFRString+"grepFilter", "")
	String /G dfr:grepFilter = localStr
	localVar = NumVarOrDefault(packageDFRString+"allowRepeats", 0)
	Variable /G dfr:allowRepeats = localVar
End