#pragma rtGlobals=3		// Require modern global access method.
#pragma modulename=GizmoAnnotations
#pragma IgorVersion=6.2	// Requires Gizmo released with Igor 6.2.
#pragma version=6.23		// version shipped with Igor 6.23

#include <GizmoTextures>, menus=0
#include <CustomControl Definitions>
#include <GizmoUtils>
#include <GizmoBlending>
#include <Graph Utility Procs>, version >=6.2	// for (only!) WMSetGraphSizePoints()

// Gizmo Annotations - Gizmo "annotations" are actually textured ortho quads (similar to Background Images)
// where the texture is made from a "demo" or "preview" graph named $ksGraphName (see definition below).

// August 3, 2010, Igor 6.20, JP: Initial version
// August 6, 2010, Igor 6.20, JP: Added "Gizmo Annotation from Graph" item to Graph menu, MakeEdgeTransparent works better.
// August 10, 2010, Igor 6.20, JP: Fixed bug where re-opening the panel lost the content of the first-selected annotation, made positioning faster.
// August 13, 2010, Igor 6.20, JP: Added hint pointing to editing the Preview graph to alter the annotation.
// September 26, 2011, Igor 6.22, JP: Increased minimum width to 128 to avoid problems on Windows where the min graph width is an OS setting.
// February 15, 2012, Igor 6.23, JP: If the preview graph gets closed, you can still change the annotation's color fill properties.

// ----------------------------------- Menus -----------------------------------

Menu "Graph", hideable, dynamic
	GizmoAnnotationFromGraphMenu(),/Q,MakeGraphIntoGizmoAnnotation(WinName(0,1,1))
End

Function/S GizmoAnnotationFromGraphMenu()

   String menuItem= ""    // disappearing
   String graphName= WinName(0,1,1)
   if( CmpStr(graphName,ksGraphName) != 0 )
       if( WinType(ksPanelName) == 7 )    // We need the panel to make this work
           String gizmoName= TopGizmo()
           if( strlen(gizmoName) )
               menuItem= "Gizmo Annotation from Graph"
           endif
       endif
   endif
   return menuItem
End

// returns new annotationGroupName
Function/S MakeGraphIntoGizmoAnnotation(graphName)
	String graphName
	
	String gizmoName= TopGizmo()
	if( strlen(graphName) == 0 || strlen(gizmoName) == 0 || WinType(ksPanelName) != 7 )    // I *think* we need the panel
		DoAlert 0, "Need a graph, a Gizmo window, and the Gizmo Annotations panel!"
		return ""
	endif
	
	DoWindow/F $ksPanelName	// to prevent the panel from showing some Gizmo other than the top gizmo, which would cause the wrong Gizmo to get the annotation.

	// save any current annotation
	String annotationGroupName
	GetPanelGizmoAnnotation(gizmoName, annotationGroupName)
	strswitch(annotationGroupName)
		case "_new_":
		case "Nascent":
			break
		default:
			SaveGraphAnnotationRecreation(gizmoName,annotationGroupName)
			break
	endswitch
	
	// create a new default annotation
	annotationGroupName= NewOrUpdateExistingAnnotation(gizmoName,"Nascent")
	
	// install a new GraphRecreation and fake switching to the annotation from somewhere else
	if( strlen(annotationGroupName) )
		String/G $GizmoDFVar(gizmoName,"wmAnnotationName") = annotationGroupName	// update the popup when a new annotation is created. See UpdateGizmoAnnotationPanel
		Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"annotationNeedsUpdate")= 0

		ResizeGraphForTexture(graphName)
		
		// install the graph recreation from the graph for the annotation
		// Since RestoreGraphAnnotationOrClear() is going to kill the ksGraphName graph,
		// which causes GizmoAnnotationDFVar(gizmoName,annotationGroupName,"GraphRecreation")
		// to be overwritten, we reset the graph's idea of which annotation it belongs to now:
		SetWindow $ksGraphName, userdata(GizmoAnnotationGroupName)="Nascent"
		
		// Now we can set this annotation's recreation macro without it getting overwritten.
		String/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"GraphRecreation") = WinRecreation(graphName,4)

		GetWindow $graphName wsizeDC		// pixels
		Variable graphWidth= V_right-V_Left
		Variable graphHeight= V_bottom-V_top
		Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"graphWidth")= graphWidth
		Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"graphHeight")= graphHeight

		RestoreGraphAnnotationOrClear(gizmoName,annotationGroupName)
		
		// update the Gizmo window
		AnnotationNeedsUpdate(0)
		
		// update the GUI
		UpdateGizmoAnnotationPanel()
	endif
	return annotationGroupName
End

// ----------------------------------- Panel-specific variables -----------------------------------

static StrConstant ksPanelName="GizmoAnnotationsPanel"
static StrConstant ksGraphName="GizmoAnnotationGraph"

static StrConstant ksPackagePath= "root:Packages:GizmoAnnotations"
static StrConstant ksPackageName = "GizmoAnnotations"

static StrConstant ksTextureWaveName= "annotationTexture"
static StrConstant ksTempRGBWaveName= "tmp_annotationRGB"

static StrConstant ksWidthSizesList= "128;256;512;1024;2048;"		// min graph width= 50 on Macintosh, about 120 on PC
static StrConstant ksHeightSizesList= "32;64;128;256;512;1024;2048;"	// min graph height = 20

static StrConstant ksInitialText="Double-click to edit"

Static Function/S PanelDF()
	NewDataFolder/O root:Packages
	NewDataFolder/O $ksPackagePath
	return ksPackagePath
End

Static Function/S PanelDFVar(varName)
	String varName
	
	return PanelDF()+":"+PossiblyQuoteName(varName)
End

// Set the data folder to a place where Execute can dump all kinds of variables and waves.
// Returns the old data folder.
Static Function/S SetPanelDF()

	String oldDF= GetDataFolder(1)
	NewDataFolder/O/S $PanelDF()	// DF is left pointing here to an existing or created data folder.
	return oldDF
End


// ----------------------------------- Per-Gizmo data folders and variables -----------------------------------


// the data folder may not yet exist.
// returns full path to the gizmo-specific data folder.
Static Function/S GetGizmoDF(gizmoName)
	String gizmoName

	ValidGizmoName(gizmoName)	// if "", set gizmoName to top Gizmo's name
	String df= PackagePerGizmoDFVar(gizmoName,ksPackageName,"")	// "" if no gizmo by that name, else "root:Packages:GizmoImages:PerGizmoData:dfName"
	if( strlen(df) == 0 )
		df= PanelDF()+":Defaults"	// for controls before a gizmo window has been created (or after they've all gone away)
	endif
	NewDataFolder/O $df
	return df
End

// Changes data folder to the PerGizmo data folder and returns the old data folder.
static Function/S SetGizmoDF(gizmoName)
	String gizmoName
	
	String oldDF= GetDataFolder(1)
	String df= GetGizmoDF(gizmoName)
	NewDataFolder/O/S $df
	
	return oldDF
End

// Returns the path to gizmo-specific variable, string or wave, which may not exist.
static Function/S GizmoDFVar(gizmoName,varName)
	String gizmoName,varName
	
	return GetGizmoDF(gizmoName)+":"+PossiblyQuoteName(varName)
End

// ===================== WMAnnotationGroup-related utilities ==============

//	To identify the annotation elements in Gizmo, each "annotation" object is placed in a group, with a name of "WMAnnotationGroup<number>"
//	
//		AppendToGizmo group,name=WMAnnotationGroup0
//		
//		// ************************* Group Object Start *******************
//		ModifyGizmo currentGroupObject="WMAnnotationGroup0"
//
//		<stuff here>
//
//		ModifyGizmo currentGroupObject="::"
//	
//		// ************************* Group Object End *******************
//		
//		AppendToGizmo attribute color={0,0,0,1},name=black
//	
//
// The group contains the quad and texture objects.
//
// Each Gizmo may have multiple annotations.
//

// Returns the path to the annotation-specific data folder, creating it if necessary
static Function/S GizmoAnnotationDF(gizmoName, annotationName)
	String gizmoName, annotationName
	
	String df= GetGizmoDF(gizmoName)	// root:Packages:GizmoAnnotations:PerGizmoData:GizmoData0 or root:Packages:GizmoAnnotations:Defaults
	if( strlen(annotationName) )
		df += ":" + annotationName	// root:Packages:GizmoAnnotations:PerGizmoData:GizmoData0:WMAnnotationGroup0, etc
	endif
	NewDataFolder/O $df
	return df
End

// Returns the path to annotationName-specific variable, string or wave, which may not exist.
static Function/S GizmoAnnotationDFVar(gizmoName,annotationName,varName)
	String gizmoName,annotationName,varName
	
	return GizmoAnnotationDF(gizmoName,annotationName)+":"+PossiblyQuoteName(varName)
End

static Function/S ListOfGizmoAnnotations(gizmoName,includeNew)
	String gizmoName
	Variable includeNew
	
	String groups= SortList(GetGizmoGroupObjects(gizmoName, "", "WMAnnotationGroup*"),";",16)
	if( includeNew )
		groups += "_new_;"
	endif
	return groups
End

static Function/S UniqueGizmoAnnotationName(gizmoName)
	String gizmoName
	
	return UniqueGizmoObjectName(gizmoName,"WMAnnotationGroup0","objectItemExists")
End

// returns number of parameters successfully retrieved: 1, or 2 or on error 0 is returned.
static Function GetPanelGizmoAnnotation(gizmoName, annotationName)
	String &gizmoName, &annotationName	// outputs
	
	Variable numGot= 0
	gizmoName= ""
	annotationName= ""
	SVAR/Z gn= $PanelDFVar("topGizmo")
	if( SVAR_Exists(gn) && strlen(gn) )
		gizmoName= gn
		numGot += 1
		SVAR/Z in= $GizmoDFVar(gizmoName, "wmAnnotationName")
		if( SVAR_Exists(in) && strlen(in) )
			if( CmpStr(in,"_new_") == 0 )
				annotationName= "Nascent"	// this is the corresponding data folder name.
			else
				annotationName= in
			endif
			numGot += 1
		endif		
	endif
	return numGot
End

// ----------------- Panel and control procs -------------------------------------

Function WMGizmoAnnotationPanel() // Also see UpdateGizmoAnnotationPanel() and NewOrUpdateExistingAnnotation()

	DoWindow/F $ksPanelName
	if( V_Flag == 0 )
		NewPanel/N=$ksPanelName/W=(602,86,894,632)/K=1 as "Gizmo Annotations"
		ModifyPanel fixedSize=1, noEdit=1
		DefaultGuiFont/W=#/Mac popup={"_IgorMedium",12,0},all={"_IgorMedium",12,0}
		DefaultGuiFont/W=#/Win popup={"_IgorMedium",0,0},all={"_IgorMedium",0,0}

		// Transfer panel-specific control settings from globals (or defaults) to controls here.
	
		// NOTE: transfer control settings from annotation-specific globals (or defaults) to controls in UpdateGizmoAnnotationPanel(),
		// NOT here.
		
		String cmd

		// controls at top
		PopupMenu annotations,pos={12,15},size={223,20},proc=GizmoAnnotations#GizmoAnnotationsPopMenuProc,title="Annotation"
		PopupMenu annotations,mode=1,popvalue="_new_",value= #"GizmoAnnotations#ListOfGizmoAnnotations(\"\",1)"

		TitleBox hint,pos={155,10},size={134,26},title="\\JL\\K(65535,0,0)\\k(65535,0,0)Edit the Preview graph\\W649\rto change the Annotation"
		TitleBox hint,fSize=10,frame=0

		// Size group
		GroupBox GraphSizeGroup,pos={10,44},size={270,129},title="Size"

		PopupMenu widthPopup,pos={38,74},size={182,20},proc=GizmoAnnotations#GraphSizePopMenuProc,title="Graph Width (pixels): "
		String sizes="\""+ksWidthSizesList+"\""
		PopupMenu widthPopup,mode=1,value= #sizes

		PopupMenu heightPopup,pos={38,107},size={186,20},proc=GizmoAnnotations#GraphSizePopMenuProc,title="Graph Height (pixels): "
		sizes="\""+ksHeightSizesList+"\""
		PopupMenu heightPopup,mode=1,value= #sizes

		PopupMenu scalePop,pos={38,140},size={197,20},title="Scale Graph in Gizmo by :"
		PopupMenu scalePop,mode=3,popvalue="x 1",value= #"\"x 0.25;x 0.5;x 1;x 2;x 3;x 4;x 5\""
		PopupMenu scalePop,proc=GizmoAnnotations#GraphScalePopMenuProc

		// Position group
		GroupBox PosGroup,pos={10,183},size={270,162},title="Position"

		Make/O $PanelDFVar("orthoTickNums")= { -3, 0, 3 }	// will be updated to be the +/- Max Ortho limit
		Wave tickNums= $PanelDFVar("orthoTickNums")
		Make/T/O $PanelDFVar("leftRightTickLabels")= { "Left", "", "Right" }
		Wave/T tickLabels= $PanelDFVar("leftRightTickLabels")

		Slider annotationLeft,pos={21,214},size={172,49}
		Slider annotationLeft,fSize=10
		Slider annotationLeft,limits={tickNums[0],tickNums[2],0},value= 1.5,side= 2,vert= 0,ticks= 2
		Slider annotationLeft,userTicks={tickNums,tickLabels},proc=GizmoAnnotations#PositionSliderProc

		Make/T/O $PanelDFVar("upDownTickLabels")= { "Down", "", "Up" }
		Wave/T tickLabels= $PanelDFVar("upDownTickLabels")

		Slider annotationTop,pos={207,211},size={63,125},fSize=10
		Slider annotationTop,limits={tickNums[0],tickNums[2],0},value= 1.9,ticks= 3
		Slider annotationTop,userTicks={tickNums,tickLabels},proc=GizmoAnnotations#PositionSliderProc
	
		PopupMenu placement,pos={41,288},size={139,20},title="Placement:"
		PopupMenu placement,mode=2,popvalue="behind",value= #"\"behind;in front;\""
		PopupMenu placement,proc=GizmoAnnotations#PlacementPopMenuProc

		SetVariable orthoRangeMax,pos={41,321},size={135,16},bodyWidth=60,proc=GizmoAnnotations#OrthoRangeMaxSetVarProc,title="Position Range"
		SetVariable orthoRangeMax,fSize=10,limits={0.5,10,0.5},value= _NUM:3

		// Appearance group
		GroupBox appearanceGroup,pos={11,357},size={270,109},title="Appearance"

		CheckBox transparentCheck,pos={26,389},size={176,16},title="Make Color Transparent:"
		CheckBox transparentCheck,value= 0,proc=GizmoAnnotations#TransparentCheckProc
		
		PopupMenu transparentColorPop,pos={190,387},size={50,20},proc=GizmoAnnotations#TransparentColorPopMenuProc
		PopupMenu transparentColorPop,mode=1,popColor= (65535,65535,65535),value= #"\"*COLORPOP*\""

		SetVariable colorTolerance,pos={48,416},size={129,16},bodyWidth=50,title="Color Tolerance"
		SetVariable colorTolerance,fSize=10,limits={0,127,1},value= _NUM:0, proc=GizmoAnnotations#ColorToleranceSetVarProc

		CheckBox transparentAtEdgesOnlyCheck,pos={47,443},title="Only at Outside Edges",size={193,16}
		CheckBox transparentAtEdgesOnlyCheck,value= 0,proc=GizmoAnnotations#OnlyEdgesTransparentCheckProc

		// controls at bottom

		Button appendOrRemove,pos={87,480},size={130,20},proc=GizmoAnnotations#AddOrRemoveButtonProc,title="Remove Annotation"

		Button gizmoInfo,pos={15,513},size={80,20},title="Gizmo Info", proc=GizmoAnnotations#GizmoInfoButtonProc

		String/G $PanelDFVar("topGizmo")
		CustomControl gizmoName,pos={107,516},size={103,15},proc=GizmoAnnotations#GizmoLinkControlProc
		CustomControl gizmoName,userdata(mouseState)=  "Up",fSize=9,frame=0
		CustomControl gizmoName,value= root:Packages:GizmoAnnotations:topGizmo

		Button help,pos={227,513},size={50,20},title="Help", proc=GizmoAnnotations#GizmoHelpButtonProc

		// Set up hook
		SetWindow $ksPanelName hook(GizmoAnnotation)=GizmoAnnotations#PanelWindowHook
		String dfName= UpdateGizmoAnnotationPanel() // we're already activated, update controls from the top gizmo manually
		if( strlen(dfName) )
			String gizmoName= TopGizmo()
			if( ValidGizmoName(gizmoName) )
				AutoPositionWindow/M=0/R=$gizmoName $ksPanelName
			endif
		endif

	// else
	// the activate event from DoWindow/F will call UpdateGizmoAnnotationPanel()

	endif
End

// Compare to UpdateGizmoImagePanel()
//
// returns dfName (not sure why)
static Function/S UpdateGizmoAnnotationPanel()

	DoWindow $ksPanelName
	if( V_Flag == 0 )
		return ""
	endif

	String gizmoName=TopGizmo()	// can be ""
	String/G $PanelDFVar("topGizmo")= gizmoName	// for GetPanelGizmoAnnotation

	String allControls= ControlNameList(ksPanelName, ";", "*")
	allControls= RemoveFromList("gizmoName;help;", allControls)

	if( strlen(gizmoName) == 0 )
		ModifyControlList allControls, disable=1	// hide
	else
		ModifyControlList allControls, disable=0	// show
	endif
	// controls at top and bottom

	String wmAnnotationsList= ListOfGizmoAnnotations(gizmoName,0)
	Variable numAnnotations= ItemsInList(wmAnnotationsList)
	String annotationGroupName= StrVarOrDefault(GizmoDFVar(gizmoName,"wmAnnotationName"), "Nascent")	// can be "Nascent", too!
	if( CmpStr(annotationGroupName,"Nascent") == 0 )
		annotationGroupName= "_new_"	// what the popup list uses.
	endif
	if( numAnnotations )	// see if imageName is in the list (it might have been removed)
		Variable index= WhichListItem(annotationGroupName, wmAnnotationsList+"_new_;")	// -1 if not found
		if( index < 0 )
			annotationGroupName=StringFromList(numAnnotations-1,wmAnnotationsList)
		endif
	else
		annotationGroupName="_new_"
	endif

	wmAnnotationsList= ListOfGizmoAnnotations(gizmoName,1)
	Variable mode= 1+WhichListItem(annotationGroupName, wmAnnotationsList)

	String cmd= GetIndependentModuleName()+"#GizmoAnnotations#ListOfGizmoAnnotations(\"" + gizmoName + "\", 1)"
	PopupMenu annotations, win=$ksPanelName,mode=mode, popvalue=annotationGroupName, value= #cmd

	Variable isNew= CmpStr(annotationGroupName,"_new_") == 0
	if( isNew )
		Button appendOrRemove, win=$ksPanelName, title="Append Annotation"
		annotationGroupName="Nascent"	// what the data folders use.
	else
		Button appendOrRemove, win=$ksPanelName, title="Remove Annotation"
	endif

	String/G $GizmoDFVar(gizmoName,"wmAnnotationName")= annotationGroupName

	// We now have the gizmo and annotation (group) name.

	// Update the remaining controls from the global variables in GizmoAnnotationDFVar(gizmoName,annotationGroupName,varName) or the defaults

	// Size
	Variable graphWidth= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"graphWidth"),128)	// pixels
	Variable graphHeight= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"graphHeight"),32)	// pixels
	
	Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"graphWidth")= graphWidth
	Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"graphHeight")= graphHeight

	PopupMenu widthPopup,win=$ksPanelName, popmatch=num2istr(graphWidth)
	PopupMenu heightPopup,win=$ksPanelName, popmatch=num2istr(graphHeight)

	Variable scale= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"scale"),1)
	Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"scale")= scale
	String matchThis
	sprintf matchThis, "x %g", scale	// item of "x 0.25;x 0.5;x 1;x 2;x 3;x 4;x 5"
	PopupMenu scalePop, win=$ksPanelName, popMatch=matchThis

	// Position
	Variable orthoRangeMax= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"orthoRangeMax"), 3)	
	Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"orthoRangeMax")= orthoRangeMax
	SetVariable orthoRangeMax,win=$ksPanelName, variable=$GizmoAnnotationDFVar(gizmoName,annotationGroupName,"orthoRangeMax")
	
	Make/O $PanelDFVar("orthoTickNums")= { -orthoRangeMax, 0, orthoRangeMax }	// used as tick mark values for position sliders

	Variable annotationLeft= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"annotationLeft"), -1)		// x ortho: mid top-left is default position
	annotationLeft= limit(annotationLeft, -orthoRangeMax,orthoRangeMax)
	Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"annotationLeft")= annotationLeft
	Slider annotationLeft, win=$ksPanelName, limits={-orthoRangeMax,orthoRangeMax,0}
	Slider annotationLeft, win=$ksPanelName, variable=$GizmoAnnotationDFVar(gizmoName,annotationGroupName,"annotationLeft")

	Variable annotationTop= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"annotationTop"), 1)		// y ortho: -2 is the bottom, +2 is the top
	annotationTop= limit(annotationTop, -orthoRangeMax,orthoRangeMax)
	Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"annotationTop")= annotationTop
	Slider annotationTop, win=$ksPanelName, variable=$GizmoAnnotationDFVar(gizmoName,annotationGroupName,"annotationTop")
	Slider annotationTop, win=$ksPanelName, limits={-orthoRangeMax,orthoRangeMax,0}

	Variable zPosition= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"zPosition"), 1.99)				// "in front" is the default, because it won't get hidden behind something when first created
	Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"zPosition")= zPosition
	mode= zPosition < 0 ? 1 : 2	// "behind;in front;"
	PopupMenu placement,win=$ksPanelName, mode=mode

	// Appearance

	Variable checked= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentCheck"), 0)
	Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentCheck")= checked
	Checkbox transparentCheck,win=$ksPanelName, variable=$GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentCheck")
	
	Variable transparentRed= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentRed"),65535)	// these colors define white
	Variable transparentGreen= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentGreen"),65535)
	Variable transparentBlue= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentBlue"),65535)
	PopupMenu transparentColorPop,win=$ksPanelName, mode=1,popColor= (transparentRed,transparentGreen,transparentBlue)
	Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentRed")= transparentRed
	Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentGreen")= transparentGreen
	Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentBlue")= transparentBlue

	Variable colorTolerance= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"colorTolerance"), 0)
	Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"colorTolerance")= colorTolerance
	SetVariable colorTolerance,win=$ksPanelName,variable=$GizmoAnnotationDFVar(gizmoName,annotationGroupName,"colorTolerance")

	checked= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentAtEdgesOnlyCheck"), 0)
	Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentAtEdgesOnlyCheck")= checked
	Checkbox transparentAtEdgesOnlyCheck,win=$ksPanelName, variable=$GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentAtEdgesOnlyCheck")

	// this disables "Only at Outside Edges" when "Change Color to clearColor" is unchecked.
	ShowHideControls()
	
	// update the demo graph
	UpdateAnnotationGraph(gizmoName,annotationGroupName)

	String dfName= GetPackagePerGizmoDFName(gizmoName,ksPackageName)
	return dfName	// NOT the gizmoName, it's the data folder name in root:Packages:GizmoAnnotations:PerGizmoData:
End


static Function ShowHideControls()

	String gizmoName, annotationGroupName
	if( 2 == GetPanelGizmoAnnotation(gizmoName, annotationGroupName) )

		// Hint
		Variable disable= (CmpStr(annotationGroupName,"_new_") == 0 || CmpStr(annotationGroupName,"Nascent") == 0 ) ? 0 : 1
		ModifyControl/Z hint, win=$ksPanelName, disable=disable
		
		// Appearance
		Variable checked= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentCheck"), 0)
		// disable "Only at Outside Edges" if "Change Color" is unchecked.
		if( checked )
			disable= 0 
			checked= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentAtEdgesOnlyCheck"), 0)
		else
			disable= 2
		endif
		SetVariable colorTolerance,win=$ksPanelName, disable=disable
		Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentAtEdgesOnlyCheck")= checked
		Checkbox transparentAtEdgesOnlyCheck,win=$ksPanelName, disable=disable, variable=$GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentAtEdgesOnlyCheck")
	endif
End

// Panel hook
Static Function PanelWindowHook(s)
	STRUCT WMWinHookStruct &s

	Variable rval= 0
	strswitch(s.eventName)
		case "activate":
// #if 0 is useful while developing the panel so that activation doesn't alter the control just changed by the just-deactivated dialog.
#if 1
			UpdateGizmoAnnotationPanel()
#else
			Print "activate update not implemented. see PanelWindowHook()."
#endif
			break
		case "moved":
			KeepDemoGraphAlongsidePanel()
			break
		case "kill":
			Execute/P/Q/Z "DoWindow/K "+ksGraphName
			break
	endswitch

	return rval
End

static Function GizmoLinkControlProc(s)
	struct WMCustomControlAction &s
	
	String gizmoName= s.sVal
	switch(s.eventCode)
		case kCCE_mouseup:
			if( WinType(gizmoName) == 13 )
				DoWindow/F $gizmoName
			endif
			// FALL THROUGH
		case kCCE_mouseup_out:
			CustomControl $s.ctrlName, win=$s.win, userData(mouseState)="Up"
			break
		case kCCE_mousedown:	// mouse down in control
			CustomControl $s.ctrlName, win=$s.win, userData(mouseState)="Down"
			break
		case kCCE_draw:
//			Variable xc= 0
			Variable xc= (s.ctrlRect.right - s.ctrlRect.left)/2
			Variable yc= (s.ctrlRect.bottom - s.ctrlRect.top)/2
//			String str="\\JL\\K(30000,30000,30000)Gizmo Window Name:\\y-05 \\y+05"
			String str="\\JC\\y-05 \\y+05"
			Variable mouseIsDown= s.eventMod & 0x1
			String mouseState= GetUserData(s.win,s.ctrlName,"mouseState")
			if( strlen(mouseState) )
				mouseIsDown = CmpStr(mouseState,"Down") == 0
			endif
			if( mouseIsDown )
				str += "\\x+05\\y-05"	// shift down and right
			endif
			str += "\\f04\\K(0,0,65535)"
			str += gizmoName
//			SetDrawEnv textxjust=0, textyjust=1,fsize=9,fname="Geneva"
			SetDrawEnv textxjust=1, textyjust=1,fsize=9,fname="Geneva"
			DrawText xc, yc, str
			return 1
			break
	endswitch
	return 0
End



static Function GizmoAnnotationsPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr	// annotation group name

	String gizmoName= TopGizmo()
	String/G $GizmoDFVar(gizmoName,"wmAnnotationName") = popStr
	
	UpdateGizmoAnnotationPanel()
End

static Function GraphSizePopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName		// heightPopup;widthPopup;
	Variable popNum	// item of "16;32;64;128;256;512;1024;2048;"
	String popStr
	
	String gizmoName, annotationGroupName
	GetPanelGizmoAnnotation(gizmoName, annotationGroupName)

	String varName
	strswitch(ctrlName)
		case "heightPopup":
			varName= "graphHeight"
			break
		default:
			varName= "graphWidth"
			break
	endswitch
	Variable varNum= str2num(popStr)
	Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,varName)= varNum

	AnnotationNeedsUpdate(1)
End

static Function GraphScalePopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName		// scalePop
	Variable popNum	// item of "x 0.25;x 0.5;x 1;x 2;x 3;x 4;x 5"
	String popStr
	
	String gizmoName, annotationGroupName
	GetPanelGizmoAnnotation(gizmoName, annotationGroupName)

	Variable varNum= str2num(StringFromList(1,popStr," "))	// convert second word to number
	Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"scale")= varNum

	AnnotationNeedsUpdate(0)
End

static Function OrthoRangeMaxSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName	// "orthoRangeMax"
	Variable varNum
	String varStr
	String varName

	//	The SetVariable alters the variable directly, so we don't need to update the global here.
	//	String gizmoName, annotationGroupName
	//	GetPanelGizmoAnnotation(gizmoName, annotationGroupName)
	//
	//	Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,ctrlName)= varNum

	// limit the positions to the new min/max range
	Make/O $PanelDFVar("orthoTickNums")= { -varNum, 0, varNum }	// used as tick mark values for position sliders
	
	String gizmoName, annotationGroupName
	GetPanelGizmoAnnotation(gizmoName, annotationGroupName)
	
	Variable changed= 0

	Variable annotationLeft= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"annotationLeft"), 0)
	Variable clipped= limit(annotationLeft, -varNum,varNum)
	if( clipped != annotationLeft )
		changed= 1
		Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"annotationLeft")= clipped
	endif
	
	Variable annotationTop= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"annotationTop"), 0)
	clipped= limit(annotationTop, -varNum,varNum)
	if( clipped != annotationTop )
		changed= 1
		Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"annotationTop")= clipped
	endif

	// Set the sliders min/max. This is a per-annotation setting!
	Slider annotationLeft, win=$ksPanelName, limits={-varNum,varNum,0}
	Slider annotationTop, win=$ksPanelName, limits={-varNum,varNum,0}

	if( changed )
		AnnotationNeedsUpdate(0)
	endif
End

static Function PositionSliderProc(ctrlName,sliderValue,event) : SliderControl
	String ctrlName	// annotationLeft;annotationTop;
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved

	if(event %& 0x1)	// bit 0, value set
		//	The Slider alters the variable directly, so we don't need to update the global here.
		//	Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,ctrlName)= sliderValue
		String gizmoName, annotationGroupName
		GetPanelGizmoAnnotation(gizmoName, annotationGroupName)
		AdjustAnnotationCoordinates(gizmoName,annotationGroupName,updateMode=2)
	endif

	return 0
End

static Function PlacementPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName	// placement
	Variable popNum
	String popStr	// "behind;in front;"

	String gizmoName, annotationGroupName
	GetPanelGizmoAnnotation(gizmoName, annotationGroupName)

	Variable varNum= popNum == 1 ? -1.99 : 1.99
	Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"zPosition")= varNum

	AdjustAnnotationCoordinates(gizmoName,annotationGroupName,updateMode=2)
End

static Function TransparentCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName	// transparentCheck
	Variable checked

	//	The Checkbox alters the variable directly, so we don't need to update the global here.
	//	String gizmoName, annotationGroupName
	//	GetPanelGizmoAnnotation(gizmoName, annotationGroupName)
	//
	//	Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentCheck")= checked
	ShowHideControls()
	AnnotationNeedsUpdate(0)
End

// selecting the color popup checks the Make Color Transparent checkbox
static Function TransparentColorPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName	 // transparentColorPop
	Variable popNum
	String popStr

	String gizmoName, annotationGroupName
	GetPanelGizmoAnnotation(gizmoName, annotationGroupName)

	ControlInfo/W=$ksPanelName $ctrlName
	Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentRed")= V_red		// 0-65535
	Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentGreen")= V_green	// 0-65535
	Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentBlue")= V_blue		// 0-65535

	// Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentCheck")= 1
	Checkbox transparentCheck, win=$ksPanelName, value=1	// sets the global, too!
	ShowHideControls()
	AnnotationNeedsUpdate(0)
End

static Function ColorToleranceSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	//	The SetVariable alters the variable directly, so we don't need to update the global here.
	//	String gizmoName, annotationGroupName
	//	GetPanelGizmoAnnotation(gizmoName, annotationGroupName)
	//
	//	Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"colorTolerance")= varNum
	
	ControlInfo/W=$ksPanelName transparentCheck
	if( V_Value )
		AnnotationNeedsUpdate(0)
	endif
End

static Function OnlyEdgesTransparentCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName	// transparentAtEdgesOnlyCheck
	Variable checked

	//	The Checkbox alters the variable directly, so we don't need to update the global here.
	//	String gizmoName, annotationGroupName
	//	GetPanelGizmoAnnotation(gizmoName, annotationGroupName)
	//
	//	Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentAtEdgesOnlyCheck")= checked
	
	ControlInfo/W=$ksPanelName transparentCheck
	if( V_Value )
		AnnotationNeedsUpdate(0)
	endif
End

Static Function AddOrRemoveButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String gizmoName, annotationGroupName
	GetPanelGizmoAnnotation(gizmoName, annotationGroupName)		// annotationName name can be "Nascent" to mean "_new_"
	strswitch(annotationGroupName)
		case "_new_":
		case "Nascent":
			annotationGroupName= NewOrUpdateExistingAnnotation(gizmoName,annotationGroupName)	// changes from "_new_" to actual anno name
			if( strlen(annotationGroupName) )
				String/G $GizmoDFVar(gizmoName,"wmAnnotationName") = annotationGroupName	// update the popup when a new annotation is created. See UpdateGizmoAnnotationPanel
				Variable/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"annotationNeedsUpdate")= 0
			endif
			break
		case "":
			break
		default:
			RemoveMatchingGizmoObjects(gizmoName,annotationGroupName)
			String df= GizmoAnnotationDF(gizmoName,annotationGroupName)
			if( DataFolderExists(df) )
				if( CmpStr(df,GetDataFolder(1)) == 0 )	// killing the data folder we're currently in!
					SetDataFolder root:		// let's reset to root:
				endif
				KillDataFolder/Z $df
			endif
			RecompileGizmo(gizmoName)
			break
	endswitch
	UpdateGizmoAnnotationPanel()
End


Static Function GizmoInfoButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String oldDF= SetPanelDF()
	Execute/Q/Z "ModifyGizmo showInfo"
	SetDataFolder oldDF
End

Static Function GizmoHelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	String oldDF= SetPanelDF()
	DisplayHelpTopic/K=1 "Append Annotation To Gizmo"
	SetDataFolder oldDF
End

// ----------------------------------- Gizmo Annotation creation routines -----------------------------------

// NewOrUpdateExistingAnnotation works differently than AppendImageToGizmo's AddNewOrUpdateExistingImage():
//
//	AddNewOrUpdateExistingImage() always removes the image and creates a new one.
//
//	NewOrUpdateExistingAnnotation() actually only modifies an existing annotation, creating a new one if necessary.
// 
static Function/S NewOrUpdateExistingAnnotation(gizmoName,annotationGroupName)
	String gizmoName,annotationGroupName	// annotationGroupName name can be "Nascent" to mean "_new_", else it is usually something like "WMAnnotationGroup0"

	Variable annotationGroupDisplayIndex
	
	strswitch(annotationGroupName)
		case "_new_":
		case "Nascent":
			annotationGroupDisplayIndex= -1
			break
		default:
 			annotationGroupDisplayIndex= GetDisplayIndexOfNamedObject(gizmoName,annotationGroupName)	// -1 if not present
			break
	endswitch
	String srcDF= GizmoAnnotationDF(gizmoName,annotationGroupName)
	
	// Rather than just appending the annotation to the end, insert before the first scale, translate or rotate operation
	if( annotationGroupDisplayIndex == -1 )
		// unique group name
		annotationGroupName= UniqueGizmoAnnotationName(gizmoName)
		if( strlen(annotationGroupName) == 0 )
			DoAlert 0, "Could not create another annotation: too many already!"
			return ""
		endif
		// create a new data folder by copying the Nascent data folder.
		String df= GizmoAnnotationDF(gizmoName,annotationGroupName)	// creates the new, unique data folder
		KillDataFolder/Z $df	// DuplicateDataFolder requires the dest folder to be absent
		DuplicateDataFolder $srcDF, $df
		
		// create the Gizmo group and annotation quad and texture
		annotationGroupDisplayIndex= NewGizmoAnnotation(gizmoName,annotationGroupName,annotationGroupDisplayIndex)
		if( annotationGroupDisplayIndex >= 0 )
			UpdateAnnotationFromGraph(gizmoName,annotationGroupName)	// to apply the Appearance changes and apply blending in the right place
		endif
	else
		UpdateAnnotation(gizmoName,annotationGroupName,1)	// from graph and from coordinates
	endif
	
	return annotationGroupName
End


// DO NOT REFERENCE ANY CONTROLS
// so that a dependency on the source data can update the annotation in Gizmo.
// Use GLOBAL VARIABLES, instead.
//
// A Gizmo "Annotation" is a Background ortho quad with an associated RGB texture created from a graph that's specific to the annotation.
// The graph's recreation macro is saved in string form in the annotations data folder when the annotation is created or updated.
//
//
// returns the display index of the group object, or -1 on error
static Function NewGizmoAnnotation(gizmoName,annotationGroupName,displayIndex)
	String gizmoName
	String annotationGroupName	// "WMAnnotationGroup0", etc. 
	Variable displayIndex	// for insertDisplayList

	// create a Gizmo group
	displayIndex= FindOrInsertGizmoGroupObject(gizmoName,annotationGroupName, displayIndex)
	if( displayIndex == -1 )
		return -1	// error
	endif

	// create the annotation-specific data folder
	String oldDF= GetDataFolder(1)
	SetDataFolder GizmoAnnotationDF(gizmoName, annotationGroupName)

	// create initial texture wave in the annotation-specific data folder
	// NOTE: 	UpdateAnnotationFromGraph(gizmoName,annotationGroupName) does more stuff!

	// First, create a temp RGB wave
	// Here we COULD specify the optional wantAlpha=1 and transparentRed, transparentGreen, transparentBlue
	Wave/Z tmp_rgb= CreateRGBImageOfGraph(ksGraphName,ksTempRGBWaveName)
	if( !WaveExists(tmp_rgb) )
		SetDataFolder oldDF
		return -1	// error
	endif

	// Make the demo graph as belonging to this annotation.
	// Here is where a demo graph marked "Nascent" is changed to "WMAnnotationGroup0", etc
	// when the Append Annotation button is pressed.
	SetWindow $ksGraphName, userdata(GizmoAnnotationGizmoName)=gizmoName
	SetWindow $ksGraphName, userdata(GizmoAnnotationGroupName)=annotationGroupName
	
	// Then create the texture wave from the RGB wave
	InterpolateForTexture(tmp_rgb,ksTempRGBWaveName)	// in-place interpolation to power-of-two size			
	Redimension/U/B tmp_rgb								// ensure unsigned byte, suitable for ImageTransform imageToTexture
	WAVE/Z textureWave= CreateTextureFromRGB(tmp_rgb, ksTextureWaveName)
	KillWaves/Z tmp_rgb

	SetDataFolder oldDF

	// create an ortho quad object, based on the current state of the GizmoAnnotationGraph graph
	// and the position and scale settings, position in Ortho X/Y coordinates
	Variable xLeft, xRight, yBottom, yTop, zPosition
	if( 0 == GetAnnotationCoordinates(gizmoName,annotationGroupName, xLeft, xRight, yBottom, yTop, zPosition) )
		return -1	// error
	endif

	// set the annotation group as the currentGroupObject
	String oldGroupPath= SetGizmoCurrentGroup(gizmoName, "root:"+annotationGroupName)

	String quadName= AddGizmoOrthoBackgroundQuad(gizmoName, xLeft,xRight,yBottom,yTop,zPosition,clipped=0)	// not in the display list, yet.
	if( strlen(quadName) == 0 )
		SetGizmoCurrentGroup(gizmoName, oldGroupPath)
		return -1	// error
	endif

	// append a texture object
	String textureName= AddGizmoTextureForPlane(gizmoName, textureWave, "Background")
	SetGizmoCurrentGroup(gizmoName, oldGroupPath)

	if( strlen(textureName) == 0 )
		return -1	// error
	endif
	// neither the quad nor the texture object are displayed yet,
	// which is good, because the SCoordinates and TCoordinates instituted by AddGizmoTextureForPlane()
	// are based on the entire x/y ortho range, not xLeft, xRight, etc from above.
	AdjustAnnotationCoordinates(gizmoName,annotationGroupName)	// update texture wave from ksGraphName, update ortho quad from scale and position

	// Now re-set the current
	SetGizmoCurrentGroup(gizmoName, "root:"+annotationGroupName)
	
	// Display the texture and then the quad, then clear the texture:
	String cmd
	
	// this way we don't need to use MoveObjectBeforeMainTransform
	sprintf cmd,"ModifyGizmo/N=%s insertDisplayList=0, opName=loadIdentity0, operation=loadIdentity",gizmoName
	Execute cmd
	
	// enable GL_TEXTURE_2D
	sprintf cmd,"ModifyGizmo/N=%s setDisplayList=-1, opName=enableTexture, operation=enable, data=3553",gizmoName
	Execute cmd
	
	sprintf cmd,"ModifyGizmo/N=%s setDisplayList=-1, object=%s",gizmoName,textureName
	Execute cmd

	sprintf cmd,"ModifyGizmo/N=%s setDisplayList=-1, object=%s",gizmoName,quadName
	Execute cmd

	// disable GL_TEXTURE_2D
	sprintf cmd,"ModifyGizmo/N=%s setDisplayList=-1, opName=disableTexture, operation=disable, data=3553",gizmoName
	Execute cmd

	String opName= UniqueGizmoObjectName(gizmoName,"ClearTexture0","displayItemExists")
	sprintf cmd,"ModifyGizmo/N=%s setDisplayList=-1, opName=%s, operation=ClearTexture",gizmoName,opName
	Execute cmd
	
	// restore the old current group object path
	SetGizmoCurrentGroup(gizmoName, oldGroupPath)

	SetupOrClearGizmoHook(gizmoName)
	UpdateGizmo(gizmoName,2)
	
	return displayIndex	// the annotation group's display index, not anything within the group
End

static Function UpdateAnnotation(gizmoName,annotationGroupName,updateGraphFirst)
	String gizmoName
	String annotationGroupName	// "WMAnnotationGroup0", etc. 
	Variable updateGraphFirst
	
	Variable isNew= 0
	strswitch(annotationGroupName)
		case "":
		case "_new_":
		case "Nascent":
			isNew= 1
			annotationGroupName= "Nascent"
			break
	endswitch
	if( updateGraphFirst || (WinType(ksGraphName) != 1) )
		UpdateAnnotationGraph(gizmoName,annotationGroupName)
	endif
	if( !isNew )
		UpdateAnnotationFromGraph(gizmoName,annotationGroupName)
		AdjustAnnotationCoordinates(gizmoName,annotationGroupName,updateMode=2)
	endif
End

static Function AnnotationNeedsUpdate(updateGraphFirst)
	Variable updateGraphFirst
	
	String gizmoName, annotationGroupName
	GetPanelGizmoAnnotation(gizmoName, annotationGroupName)

	UpdateAnnotation(gizmoName,annotationGroupName,updateGraphFirst)
End

static Function/S SaveGraphAnnotationRecreation(gizmoName,annotationGroupName)
	String gizmoName
	String annotationGroupName	// "WMAnnotationGroup0", etc.

	String graphRecreationStr= ""
	if( CmpStr(annotationGroupName,"_new_") != 0 && CmpStr(annotationGroupName,"Nascent") != 0 )
		graphRecreationStr= WinRecreation(ksGraphName,4)
	endif
	String/G $GizmoAnnotationDFVar(gizmoName,annotationGroupName,"GraphRecreation")= graphRecreationStr
	return graphRecreationStr
End

static Function/S RestoreGraphAnnotationOrClear(gizmoName,annotationGroupName)
	String gizmoName
	String annotationGroupName	// "WMAnnotationGroup0", etc.

	Variable leftPoints, topPoints, rightPoints, bottomPoints, graphWidth,graphHeight, widthPoints, heightPoints
	Variable hadGraph= WinType(ksGraphName) == 1
	if( hadGraph )
		// preserve position (only)
		GetWindow/Z $ksGraphName wsizeRM	// to get position (in points)
		leftPoints= V_left
		topPoints= V_top
	else
		GetWindow/Z $ksPanelName wsizeRM
		leftPoints= V_right+4	// position a new graph to the right of the panel
		topPoints= V_top
	endif

	DoWindow/K $ksGraphName	// causes call to SaveGraphAnnotationRecreation from hook

	String graphRecreationStr= ""
	if( CmpStr(annotationGroupName,"_new_") != 0 && CmpStr(annotationGroupName,"Nascent") != 0 )
		graphRecreationStr= StrVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"GraphRecreation"),"")
	endif
	if( strlen(graphRecreationStr) )
		String oldDF= GetDataFolder(1)
		SetDataFolder GizmoAnnotationDF(gizmoName, annotationGroupName)
		Execute/Q graphRecreationStr	// This should restore the hooks and userData, too
		DoWindow/C $ksGraphName		// When making a graph into an annotation, the window name might change
		SetDataFolder oldDF
		GetWindow/Z $ksGraphName wsizeRM	// to get new size (in points)
		widthPoints= V_right - V_left
		heightPoints= V_Bottom - V_top
		rightPoints= leftPoints + widthPoints
		bottomPoints= topPoints + heightPoints
		SetWindow $ksGraphName hook(GizmoAnnotation)=$""	// disable any saved hook during move to avoid recursion
		MoveWindow/W=$ksGraphName leftPoints, topPoints, rightPoints, bottomPoints
	else
		graphWidth= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"graphWidth"), 128)
		graphHeight= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"graphHeight"), 32)	// pixels
		widthPoints= graphWidth * (72/ScreenResolution)	// Convert pixels to points
		heightPoints= graphHeight * (72/ScreenResolution)	// Convert pixels to points
		rightPoints= leftPoints + widthPoints
		bottomPoints= topPoints + heightPoints
		Display/K=1/W=(leftPoints, topPoints, rightPoints, bottomPoints)/N=$ksGraphName as "Preview"
		ModifyGraph/W=$ksGraphName margin=-1,width=widthPoints, height=heightPoints	// fixed size, this marks the graph "dirty", so the next time it updates, the "modified" hook runs.
		Textbox/W=$ksGraphName/C/N=gizmoAnnotation/X=11.71/Y=25 ksInitialText
	endif
	SetWindow $ksGraphName hook(GizmoAnnotation)=GizmoAnnotations#GraphHook

	// Feed GetGizmoAnnotationFromGraph()
	SetWindow $ksGraphName, userdata(GizmoAnnotationGizmoName)=gizmoName
	SetWindow $ksGraphName, userdata(GizmoAnnotationGroupName)=annotationGroupName
	
	// put the panel back on top, but short-circuit the activate event hook in the meantime.
	SetWindow $ksPanelName hook(GizmoAnnotation)=$""
	HideTools/A/W=$ksPanelName
	DoWindow/B=$ksPanelName $ksGraphName
	SetWindow $ksPanelName hook(GizmoAnnotation)=GizmoAnnotations#PanelWindowHook

	return graphRecreationStr
End

static Function UpdateAnnotationGraph(gizmoName,annotationGroupName)
	String gizmoName
	String annotationGroupName	// "WMAnnotationGroup0", etc. 

	// make sure the demo graph is for this annotation, and not some other annotation
	String graphsGizmoName, graphsAnnotationGroupName
	if( GetGizmoAnnotationFromGraph(graphsGizmoName,graphsAnnotationGroupName) )
		// the graph exists and has a Gizmo annotation designation/userData
		// check whether it is the source for THIS annotation
		if( CmpStr(gizmoName,graphsGizmoName) != 0 || CmpStr(annotationGroupName,graphsAnnotationGroupName) != 0 )
			// SaveGraphAnnotationRecreation(graphsGizmoName,graphsAnnotationGroupName)	// hook function does this.
			RestoreGraphAnnotationOrClear(gizmoName,annotationGroupName) // (graph switching happens here)
		else
			if( WinType(ksPanelName) )
				HideTools/A/W=$ksPanelName	// Mac OS X bug requires this in order to work.
				DoWindow/B=$ksPanelName $ksGraphName
			endif
		endif
	else	// Preview Graph hasn't been built yet.
		RestoreGraphAnnotationOrClear(gizmoName,annotationGroupName) // (graph switching happens here)
	endif

	// if the graph was showing, now it is showing the correct annotation, though possibly with the wrong size

	Variable graphWidth= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"graphWidth"), 128)
	Variable graphHeight= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"graphHeight"), 32)	// pixels
	Variable widthPoints= graphWidth * (72/ScreenResolution)	// Convert pixels to points
	Variable heightPoints= graphHeight * (72/ScreenResolution)	// Convert pixels to points
	
	Variable leftPoints, topPoints,rightPoints, bottomPoints
	if( WinType(ksGraphName) == 1 )
		GetWindow/Z $ksGraphName wsizeRM	// maintain existing graph's position
		Variable graphWidthPoints= V_right-V_left
		Variable graphHeightPoints= V_bottom-V_top
		SetWindow $ksGraphName hook(GizmoAnnotation)=$""	// disable hook during resize to avoid recursion
		if( graphWidthPoints != widthPoints || graphHeightPoints != heightPoints )
			WMSetGraphSizePoints(ksGraphName, widthPoints, heightPoints,fixedSize=1)	// this marks the graph "dirty", so the next time it updates, the "modified" hook runs.
		else
			leftPoints= V_left
			topPoints= V_top
			rightPoints= leftPoints + widthPoints
			bottomPoints= topPoints + heightPoints
			MoveWindow/W=$ksGraphName leftPoints, topPoints, rightPoints, bottomPoints	// this doesn't mark the graph "dirty" which results in less Gizmo flashing
		endif
	else
		GetWindow/Z $ksPanelName wsizeRM
		leftPoints= V_right+4	// position a new graph to the right of the panel
		topPoints= V_top
		rightPoints= leftPoints + widthPoints
		bottomPoints= topPoints + heightPoints
		Display/K=1/W=(leftPoints, topPoints, rightPoints, bottomPoints)/N=$ksGraphName as "Preview"
		ModifyGraph/W=$ksGraphName margin=-1,width=widthPoints, height=heightPoints	// fixed size, no margins
		Textbox/W=$ksGraphName/C/N=gizmoAnnotation/X=11.71/Y=25 ksInitialText
	endif
	SetWindow $ksGraphName hook(GizmoAnnotation)=GizmoAnnotations#GraphHook

	// Feed GetGizmoAnnotationFromGraph():
	SetWindow $ksGraphName, userdata(GizmoAnnotationGizmoName)=gizmoName
	SetWindow $ksGraphName, userdata(GizmoAnnotationGroupName)=annotationGroupName
End

// keeps the graph on the right side of the panel
static Function KeepDemoGraphAlongsidePanel()

	if( WinType(ksPanelName) == 0  || WinType(ksGraphName)  == 0 )
		return -1
	endif

	String gizmoName,annotationGroupName
	if( 0 == GetGizmoAnnotationFromGraph(gizmoName,annotationGroupName) )
		return -2
	endif

	GetWindow/Z $ksPanelName wsizeRM
	Variable leftPoints= V_right+4	// position a new graph to the right of the panel
	Variable topPoints= V_top

	GetWindow/Z $ksGraphName wsizeRM	// maintain existing graph's position
	Variable rightPoints= leftPoints + V_right-V_Left
	Variable bottomPoints= topPoints + V_bottom-V_top
	SetWindow $ksGraphName hook(GizmoAnnotation)=$""	// disable hook during resize to avoid recursion
	MoveWindow/W=$ksGraphName leftPoints, topPoints, rightPoints, bottomPoints
	SetWindow $ksGraphName hook(GizmoAnnotation)=GizmoAnnotations#GraphHook

	return 0
End

static Function KeepPanelAlongsideGraph()

	if( WinType(ksPanelName) == 0  || WinType(ksGraphName)  == 0 )
		return -1
	endif

	GetWindow/Z $ksGraphName wsizeRM	// maintain existing graph's position
	Variable topPoints= V_top
	Variable rightPoints= V_Left - 4	// position the panel to the left of the moved graph

	GetWindow/Z $ksPanelName wsizeRM
	Variable widthPoints= V_right-V_left
	Variable heightPoints= V_bottom-V_top
	Variable leftPoints= rightPoints - widthPoints
	Variable bottomPoints= topPoints + heightPoints

	SetWindow $ksPanelName hook(GizmoAnnotation)=$""
	MoveWindow/W=$ksPanelName leftPoints, topPoints, rightPoints, bottomPoints
	SetWindow $ksPanelName hook(GizmoAnnotation)=GizmoAnnotations#PanelWindowHook
	return 0
End

// Execute/P version of AnnotationNeedsUpdate
static Function DeferredUpdateFromGraph(gizmoName,annotationGroupName)
	String gizmoName,annotationGroupName
	
	Variable scheduledTheUpdate= 0
	if( WinType(ksGraphName) == 1 )
		String updatePending= GetUserData(ksGraphName, "", "updatePending")	// "" if no update is pending, "Yes" if the update *is* pending (Execute/P has been called)
		Variable needExecute= strlen(updatePending) == 0
		if( needExecute )
			SetWindow $ksGraphName userdata(updatePending)= "Yes"	// reset by UpdateAnnotationFromGraph()
			String cmd= GetIndependentModuleName()+"#GizmoAnnotations#AnnotationNeedsUpdate(0)"	// calls UpdateAnnotationFromGraph()
			Execute/P/Q cmd
			scheduledTheUpdate= 1
		endif
	endif
	return scheduledTheUpdate
End

Static Function GraphHook(s)
	STRUCT WMWinHookStruct &s

	Variable rval= 0
	String gizmoName, annotationGroupName

	strswitch(s.eventName)
		case "modified":
			if( GetGizmoAnnotationFromGraph(gizmoName,annotationGroupName) )
				DeferredUpdateFromGraph(gizmoName,annotationGroupName)
			endif
			break
		case "moved":
			KeepPanelAlongsideGraph()
			break
		case "kill":
			if( GetGizmoAnnotationFromGraph(gizmoName,annotationGroupName) )
				SaveGraphAnnotationRecreation(gizmoName,annotationGroupName)
			endif
			break
	endswitch

	return rval
End

// Set gizmoName and annotationGroupName from the graph's userData
// Returns truth that gizmoName and annotationGroupName were set
static Function GetGizmoAnnotationFromGraph(gizmoName,annotationGroupName)
	String &gizmoName	// OUTPUT
	String &annotationGroupName	// OUTPUT
	
	gizmoName=""
	annotationGroupName=""
	if( WinType(ksGraphName) == 1 )
		gizmoName=GetUserData(ksGraphName, "", "GizmoAnnotationGizmoName")
		annotationGroupName=GetUserData(ksGraphName, "", "GizmoAnnotationGroupName")
	endif
	return strlen(gizmoName) && strlen(annotationGroupName)
End

static Function/S UpdateAnnotationFromGraph(gizmoName,annotationGroupName)
	String gizmoName
	String annotationGroupName	// "WMAnnotationGroup0", etc. 

	if( WinType(ksGraphName) != 1 )
		//return ""	// error
		UpdateAnnotationGraph(gizmoName,annotationGroupName)	// 6.23
	endif
	SetWindow $ksGraphName userdata(updatePending)= ""	// even if we fail

	// create the annotation-specific data folder
	String oldDF= GetDataFolder(1)
	SetDataFolder GizmoAnnotationDF(gizmoName, annotationGroupName)

	// create initial texture wave in the annotation-specific data folder
	// First, create a temp RGB wave
	// specify the optional wantAlpha=1 and transparentRed, transparentGreen, transparentBlue
	Variable transparentCheck= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentCheck"),0)
	Variable transparentRed= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentRed"),65535)	// these colors define white
	Variable transparentGreen= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentGreen"),65535)
	Variable transparentBlue= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentBlue"),65535)
	transparentRed /= 257		// 257= 65535/255
	transparentGreen /= 257
	transparentBlue /= 257
	
	Variable colorTolerance= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"colorTolerance"),0)

	// if we want transparency only at the edges, don't tell CreateRGBImageOfGraph about the transparent color, just ask for alpha and we'll set it ourself
	Variable transparentAtEdgesOnlyCheck= transparentCheck && NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"transparentAtEdgesOnlyCheck"), 0)

	if( transparentAtEdgesOnlyCheck )
		Wave/Z tmp_rgb= CreateRGBImageOfGraph(ksGraphName,ksTempRGBWaveName,wantAlpha=1)
		if( WaveExists(tmp_rgb) )
			MakeEdgeTransparent(tmp_rgb,transparentRed, transparentGreen, transparentBlue, transparentError=colorTolerance)
		endif
	elseif( transparentCheck )
		Wave/Z tmp_rgb= CreateRGBImageOfGraph(ksGraphName,ksTempRGBWaveName,wantAlpha=1, transparentRed=transparentRed,transparentGreen=transparentGreen,transparentBlue=transparentBlue, transparentError=colorTolerance)
	else
		Wave/Z tmp_rgb= CreateRGBImageOfGraph(ksGraphName,ksTempRGBWaveName)
	endif
	if( !WaveExists(tmp_rgb) )
		SetDataFolder oldDF
		return ""	// error
	endif
	
	// Then create the texture wave from the RGB wave
	InterpolateForTexture(tmp_rgb,ksTempRGBWaveName)	// in-place interpolation to power-of-two size			
	Redimension/U/B tmp_rgb								// ensure unsigned byte, suitable for ImageTransform imageToTexture
	WAVE/Z textureWave= CreateTextureFromRGB(tmp_rgb, ksTextureWaveName)
	KillWaves/Z tmp_rgb
	
	// then update the texture object's width and height

	// find the texture
	// AppendToGizmo texture=WMAnnotationGroup1_txtr
	String inGroupPath= annotationGroupName+":"
	String textureNameList	// output
	Variable texturesFound= GetGizmoTextures(gizmoName, textureNameList, inGroupPath=inGroupPath,ignoreSubgroups=1)
	String textureName=StringFromList(0,textureNameList)
	if( strlen(textureName) == 0 )
		SetDataFolder oldDF
		return ""	// error
	endif

	// get the (final) texture dimensions
	Variable textureMode, texWidthPixels, texHeightPixels, layers
	String pathToRGBSourceWave
	GetTextureDimensions(textureWave, texWidthPixels, texHeightPixels, layers, textureMode, pathToRGBSourceWave)

	// set the annotation group as the currentGroupObject
	String oldGroupPath= SetGizmoCurrentGroup(gizmoName, "root:"+annotationGroupName)

	String cmd
	sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s  property={ WIDTH,%d}",gizmoName,textureName,texWidthPixels
	Execute cmd
	sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s  property={ HEIGHT,%d}",gizmoName,textureName,texHeightPixels
	Execute cmd
	
	Variable isAlpha= layers > 3
	
	if( isAlpha )
		sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s  property={ DATAFORMAT,GL_RGBA}",gizmoName,textureName	// 6408
	else
		sprintf cmd,  "ModifyGizmo/N=%s ModifyObject=%s  property={ DATAFORMAT,GL_RGB}",gizmoName,textureName
	endif
	Execute cmd

	// enable blending inside the group
	if( isAlpha )
		AddBlendingToGizmo(gizmoName=gizmoName) // requires blending to show alpha
	else
		//  unneeded alpha blending
		RemoveMatchingGizmoDisplay(gizmoName,"blendingFunction;enableBlend;")	// remove them only from the display list; that's all we need do
	endif

	SetGizmoCurrentGroup(gizmoName, oldGroupPath)

	SetDataFolder oldDF

	return GetWavesDataFolder(textureWave,2)
End

static Function MakeEdgeTransparent(rgb,transparentRed, transparentGreen, transparentBlue [, transparentError])
	Wave/Z rgb					// expected to be an RGB wave containing values with layer [][][0]=red, [][][1]=green, [][][2]=blue,  0-255
	Variable transparentRed, transparentGreen, transparentBlue	// 0-255
	Variable transparentError	// optional input, default is 0 (equality)

	if( ParamIsDefault(transparentError) )
		transparentError= 0
	endif
	
	String oldDF= GetDataFolder(1)
	SetDataFolder GetWavesDataFolder(rgb,1)
	
	Variable rows= DimSize(rgb,0)
	Variable cols= DimSize(rgb,1)

	
	Make/O/U/B/N=(rows,cols) color_error	// point scaling
	
	// matching color everywhere is set to 0
	MultiThread color_error= min(255,abs(rgb[p][q][0] - transparentRed) + abs(rgb[p][q][1] - transparentGreen) + abs(rgb[p][q][2] - transparentBlue))	// crude color distance

	// Trick: Expand the color error mask by one pixel so that filling at 0,0 "leaks" into all the edges
	InsertPoints/M=0 rows,1, color_error
	InsertPoints/M=0 0,1, color_error	// now it has rows+2 rows, where the inserted color distance = 0

	InsertPoints/M=1 cols,1, color_error
	InsertPoints/M=1 0,1, color_error	// now it has cols+2 columns, where the inserted color distance = 0

	// create M_SeedFill with transparent edges set to 0, other parts set to 255 (opaque)
	ImageSeedFill/B=255 seedX=0, seedY=0, min=0, max=transparentError+1, target=0, srcWave=color_error // creates M_SeedFill
	Wave M_SeedFill
	Redimension/N=(-1,-1,4) rgb
	MultiThread rgb[][][3]= M_SeedFill[p+1][q+1]

	KillWaves/Z M_SeedFill, color_error

	SetDataFolder oldDF
End

static Function SetupOrClearGizmoHook(gizmoName[,clearIt])
	String gizmoName
	Variable clearIt
	
	if( !ValidGizmoName(gizmoName) )
		return 0
	endif
	String func
	if( ParamIsDefault(clearIt) || !clearIt )
		func= GetIndependentModuleName()+"#GizmoAnnotations#GizmoWindowHook"
	else
		func= ""
	endif
	String cmd
	sprintf cmd,"ModifyGizmo/N=%s namedHookStr={GizmoAnnotations, \"%s\"}", gizmoName, func

	String oldDF= SetGizmoDF(gizmoName)
	Execute/Q cmd
	SetDatafolder oldDF
End

// This hook is used to detect changes in the gizmo's ortho range and window size.
static Function GizmoWindowHook(s)
	STRUCT WMGizmoHookStruct &s

	Variable checkOrtho

	strswitch( s.eventName )
		case "transformation":
			// ortho range MIGHT have changed (probably did); let's check.
			checkOrtho= 1
			break
		case "resize":
			// ortho range MIGHT have changed if "keep central box square" is enforced,
			// but for sure the window size changed, and for that
			// we need to reposition the annotation's ortho coordinates, so skip the ortho check.
			checkOrtho= 0
			break
		default:
			// unimportant events end up here
			return 0
	endswitch
	
	String gizmoName= s.winName
	Variable hookRecursionBlock= NumVarOrDefault(GizmoDFVar(gizmoName,"hookRecursionBlock"), 0)
	if( hookRecursionBlock == 0 )
		if( (checkOrtho == 0) || ChangedOrtho(gizmoName) )
			Variable/G $GizmoDFVar(gizmoName,"hookRecursionBlock")= 1
			AdjustAnnotationsForNewOrtho(gizmoName)	// also keeps texture scaling for resized Gizmo window
			Variable/G $GizmoDFVar(gizmoName,"hookRecursionBlock")=0
		endif
	endif
	return 0	 
End

static Function ChangedOrtho(gizmoName)						
	String gizmoName
	
	Variable left, right, bottom, top, zNear, zFar
	GetGizmoOrtho(gizmoName, left, right, bottom, top, zNear, zFar)

	Variable orthoLeft= NumVarOrDefault(GizmoDFVar(gizmoName,"orthoLeft"),NaN)
	Variable orthoRight= NumVarOrDefault(GizmoDFVar(gizmoName,"orthoRight"),NaN)
	Variable orthoTop= NumVarOrDefault(GizmoDFVar(gizmoName,"orthoTop"),NaN)
	Variable orthoBottom= NumVarOrDefault(GizmoDFVar(gizmoName,"orthoBottom"),NaN)
	Variable orthoZNear= NumVarOrDefault(GizmoDFVar(gizmoName,"orthoZNear"),NaN)
	Variable orthoZFar= NumVarOrDefault(GizmoDFVar(gizmoName,"orthoZFar"),NaN)
	
	Variable changed= orthoLeft != left || orthoRight != right || orthoTop != top || orthoBottom != bottom || orthoZNear != zNear || orthoZFar != zFar
	if( changed )
		Variable/G $GizmoDFVar(gizmoName,"orthoLeft")=left
		Variable/G $GizmoDFVar(gizmoName,"orthoRight")=right
		Variable/G $GizmoDFVar(gizmoName,"orthoTop")=top
		Variable/G $GizmoDFVar(gizmoName,"orthoBottom")=bottom
		Variable/G $GizmoDFVar(gizmoName,"orthoZNear")=zNear
		Variable/G $GizmoDFVar(gizmoName,"orthoZFar")=zFar
	endif
	return changed
End


// Compare to AdjustImagesForNewOrtho().
static Function AdjustAnnotationsForNewOrtho(gizmoName)
	String gizmoName
	
	String annotations= ListOfGizmoAnnotations(gizmoName,0)
	Variable i, n= ItemsInList(annotations)
	if( n >0 )
		for(i=0; i<n; i+=1 )
			String annotationGroupName= StringFromList(i,annotations)
			AdjustAnnotationCoordinates(gizmoName,annotationGroupName)
		endfor
		UpdateGizmo(gizmoName,2)
	endif
End

// Compare to AdjustImageForOrtho().

static Function AdjustAnnotationCoordinates(gizmoName,annotationGroupName[,updateMode])
	String gizmoName
	String annotationGroupName	// "WMAnnotationGroup0", etc. 
	Variable updateMode			// optional parameter to ModifyGizmo update=updateMode. Default is no call to ModifyGizmo update

	Variable xLeft, xRight, yBottom, yTop, zPosition
	if( 0 == GetAnnotationCoordinates(gizmoName,annotationGroupName, xLeft, xRight, yBottom, yTop, zPosition) )
		return 0
	endif

	// find the quad
	// AppendToGizmo quad={-1.43705,-1.4825,-1.96,-1.43705,1.3916,-1.96,1.43705,1.3916,-1.96,1.43705,-1.4825,-1.96},name=imageQuad0
	String inGroupPath= annotationGroupName+":"

	String quadNameList, quadCoordinatesStringList	// outputs
	Variable quadsFound= GetGizmoQuads(gizmoName, quadNameList, quadCoordinatesStringList, inGroupPath=inGroupPath,ignoreSubgroups=1)
	if( quadsFound < 1 )
		return 0
	endif
	String quadName=StringFromList(0,quadNameList)
	String pathToQuad= annotationGroupName+":"+quadName

	// find the texture
	// AppendToGizmo texture=WMAnnotationGroup1_txtr
	String textureNameList	// output
	Variable texturesFound= GetGizmoTextures(gizmoName, textureNameList, inGroupPath=inGroupPath,ignoreSubgroups=1)
	String textureName=StringFromList(0,textureNameList)
	String pathToTexture= annotationGroupName+":"+textureName
	
	AdjustBackgroundQuadForOrtho(gizmoName, pathToQuad, pathToTexture, xLeft, xRight, yBottom, yTop, zPosition)
	if( !ParamIsDefault(updateMode) )
		UpdateGizmo(gizmoName,updateMode)
	endif
	return 1
End

// returns 0 if error, 1 if coordinates successfully computed
static Function GetAnnotationCoordinates(gizmoName,annotationGroupName, xLeft, xRight, yBottom, yTop, zPosition)
	String gizmoName
	String annotationGroupName		// "WMAnnotationGroup0", etc.
	Variable &xLeft, &xRight, &yBottom, &yTop, &zPosition		// outputs

	String oldDF= GetDataFolder(1)
	SetDataFolder GizmoAnnotationDF(gizmoName, annotationGroupName)
	Wave/Z textureWave= $ksTextureWaveName
	SetDataFolder oldDF
	
	if( !WaveExists(textureWave) )
		return 0	// error
	endif
	
	// position in Ortho X/Y coordinates
	xLeft= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"annotationLeft"), -1)		// x ortho: mid top-left is default position
	yTop= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"annotationTop"), 1)		// y ortho: -2 is the bottom, +2 is the top
	zPosition= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"zPosition"), -1.99)		// "behind" is the default.

	// get the texture dimensions, then position and scale in ortho coordinates
	Variable textureMode, texWidthPixels, texHeightPixels, layers
	String pathToRGBSourceWave
	GetTextureDimensions(textureWave, texWidthPixels, texHeightPixels, layers, textureMode, pathToRGBSourceWave)
	
	// From here on down, I'm presuming that the x1, x2 popup code can set the scale precisely enough
	// that after all of the following calculations the texture is drawn per-pixel in the window.
	// This may need rewriting.
	
	Variable scale= NumVarOrDefault(GizmoAnnotationDFVar(gizmoName,annotationGroupName,"scale"), 1)
	texWidthPixels *= scale
	texHeightPixels *= scale
	
	// to convert pixels to ortho coordinates, we need the Gizmo window's ortho range and pixel range
	Variable orthoLeft, orthoRight, orthoBottom, orthoTop, zNear, zFar
	GetGizmoOrtho(gizmoName, orthoLeft, orthoRight, orthoBottom, orthoTop, zNear, zFar) 
	
	Variable widthOrtho = abs(orthoRight-orthoLeft)
	Variable heightOrtho= abs(orthoTop-orthoBottom)

	Variable leftPoints, topPoints, rightPoints, bottomPoints	// window coordinates
	if( 0 == GetGizmoCoordinates(gizmoName, leftPoints, topPoints, rightPoints, bottomPoints) )
		return 0	// error
	endif
	Variable windowWidthPixels= abs(rightPoints-leftPoints) * (ScreenResolution/72)	// convert points to pixels
	Variable windowHeightPixels= abs(bottomPoints-topPoints) * (ScreenResolution/72)	// convert points to pixels

	Variable quadOrthoWidth=  texWidthPixels / windowWidthPixels * widthOrtho
	Variable quadOrthoHeight=  texHeightPixels / windowHeightPixels * heightOrtho
	
	xRight= xLeft + quadOrthoWidth
	yBottom= yTop - quadOrthoHeight

	return 1
End

