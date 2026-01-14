#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma ModuleName = HClusterDendrogramProcs
#pragma Version=1.21
#include <PopupWaveSelector> version>=1.13	// 1.12 for longer name for the buttons
#include <ColorWaveEditor>
#include <Graph Utility Procs>

// Public Functions
//Function PlotDendrogram(WAVE dendroWave, WAVE datawave, String labelWavePath, Variable clusterCutVal, Variable doVertical [, Wave groupcolors])
//Function ComputeAndPlotDoubleDendrogram(Wave rawMatrix, Variable transpose, String rowsLabels, String colsLabels, String DFNameForResults, String DissMethod, String LinkMethod)
//Function/WAVE HCluster_PreprocessData(Wave vectorData, Variable preprocessType, Variable transposeData)
//Function/WAVE HCluster_CallHCluster(Wave vectorData, String basename, String outtype, String linkage, String dissMetric, String dissMatrixName, String dendroWaveName)
//Function DDendro_GraphHasDoubleDendrogram(string gname)
//Function Dendro_GraphHasSingleDendrogram(string gname)
//Function Dendro_SetCutValue(Variable cutvalue, String gname[, Variable doHorizontal])
//Function Dendro_ReorderDataMatrix(Wave inputMatrix, Wave reorderedMatrix, Wave dendrowave)
//Function Dendro_SaveClusterWave(Wave dendroW, Variable cutValue)
//Function/WAVE Dendro_MakeFreeClusterColorWave()

//Function HCluster_GetCutValueFromGraph(String gname [, Variable doVertical])
//Function/WAVE HCluster_ClusterMatrices(Wave dendroWave, Wave dataWave, Variable cutvalue [, Variable ColumnVectors])
//Function HCluster_SaveClusterMatrices(String basename, Wave dendrowave, Wave dataWave, Variable cutvalue, Variable overwriteOK [, Variable ColumnVectors])
//Function [WAVE NodeList, WAVE/T LabelledList] HCluster_ClusterListWaves(Wave dendroWave, Wave dataWave, Variable cutValue [, Variable columnVectors])
//Function HCluster_SaveClusterListWaves(String basename, Wave dendroWave, Wave dataWave, Variable cutValue, Variable overwriteOK [, Variable columnVectors])
//Function/WAVE HCluster_ClusterAverageWaves(Wave dendroWave, Wave dataWave, Variable cutvalue [, Variable ColumnVectors])
//Function HCluster_ClusterAverageAndGraph(String basename, Wave dendroWave, Wave dataWave, Variable cutvalue, Variable doGraph, Variable overwriteOK [, Variable ColumnVectors])

//Function Dendro_MakeClusteredData(String name, Variable rows, Variable nclusters)

// version 1.0 JW
//		First release with Igor 9
// version 1.1 JW
//		Added computation of average vector for each cluster
//		Added option to label the clusters with their numbers
//		These are accessed via a new button and a checkbox in the Clusters tab of the Modify Dendrogram panel
//		Now an old Modify Dendrogram panel will be detected and replaced
//		Fixed a couple of minor bugs
//		Added Help buttons to the control panels that reference a newly added help file
//		If cluster numbers are showing, moving cut line updates the labels
//		Moved Plot Log of Dissimilarity checkbox from Lines tab to Clusters tab
//		Replaced Show and Hide buttons for perpendicular labels with a checkbox
//		Added ability to save the cluster matrices when graphing the cluster averages.
// version 1.2 JW
//		Added "Vectors are Columns" checkbox in the Hierarchical Clustering and Dendrogram panel to
//			allow data organized with data vectors in the matrix columns
//		Fixed a bug in cut line mouse handling on Windows
// version 1.21 JW
//		Removed "Vectors are Columns" checkbox in favor of adding "Transpose Before Preprocessing" checkbox.
//			That means that Transpose is a preprocessing step.
//		Added ability to get the leaf labels for a dendrogram from dimension labels on the source data matrix.
//		Made most functions static, in conformance with best practices.
//		See comments above listing public functions intended for Igor programmers to use.
//		Added version update code for the Compute Hierarchical Cluster and Dendrogram panel
//		Added a "Post-Process" tab to the Modify Dendrogram panel and moved the "Graph Cluster Averages"
//			button to the new tab. Added "Make Cluster Matrices" button and "List Clusters" button to the tab.
//		Added public functions for user programming; DisplayHelpTopic "Hierarchical Clustering Package"
//		The large cluster labels now use transparency to be a little less intrusive.
//		Fixed bugs in the destruction of data folders for dendrogram graphs caused by trying to delete
//			objects that were part of dependency expressions.
//		Fixed bugs in dragging the cut line caused by issues with scaling mouse coordinates.
//		Removed some unused functions.

// TODO:
// Names for clusters?

// type = 0 for horizontal, 1 for vertical, 2 for a single dendrogram and we don't care
Constant DendroTypeH = 0
Constant DendroTypeV	 = 1
Constant DendroTypeSingle = 2

Constant DendroModPanelVersion = 1.2
Constant DendroCreatePanelVersion = 1.1

StrConstant LabelsNoneString = "_none_"
StrConstant LabelsDimLabelsString = "Dimension Labels"

Menu "Analysis", dynamic
	Submenu "Hierarchical Clustering"
		"Display Heat Map with Dendrogram", /Q, HClusterDendrogramProcs#fComputeClusterPanel()
		"Heat Map and Two-Way Dendrogram", /Q, HClusterDendrogramProcs#DisplayDoubleDendroControlPanel()
		HClusterDendrogramProcs#DendroMenu_singleItem(), /Q, HClusterDendrogramProcs#fCreateModifyDendrogramPanel(WinName(0,1), DendroTypeSingle)
		HClusterDendrogramProcs#DendroMenu_verticalItem(), /Q, HClusterDendrogramProcs#fCreateModifyDendrogramPanel(WinName(0,1), DendroTypeV)
		HClusterDendrogramProcs#DendroMenu_horizontalItem(), /Q, HClusterDendrogramProcs#fCreateModifyDendrogramPanel(WinName(0,1), DendroTypeH)
	end
end

static Function AfterCompiledHook()

	if (WinType("HCluster_ComputeClusterPanel") == 7)
		DendroCreatePanelCheckVersion()
	endif
end

static Function/S DendroMenu_singleItem()
	if (Dendro_GraphHasSingleDendrogram(WinName(0,1)))
		return "Modify Dendrogram"
	else
		return ""
	endif
end

static Function/S DendroMenu_verticalItem()
	if (DDendro_GraphHasDoubleDendrogram(WinName(0,1)))
		return "Modify Vertical Dendrogram"
	else
		return ""
	endif
end

static Function/S DendroMenu_horizontalItem()
	if (DDendro_GraphHasDoubleDendrogram(WinName(0,1)))
		return "Modify Horizontal Dendrogram"
	else
		return ""
	endif
end

// *** Dendrogram settings structure, DendrogramDrawInfo> ***
Structure DendrogramDrawInfo
	SVAR dendrogramDataWave		// Name of vector wave or distance matrix fed to HCluster operation
	SVAR dendrogramWaveName		// Name of the dendrogram wave output by HCluster
	SVAR dendrogramLabelWave		// Name of text wave containing the labels for the dendrogram leaves. Can be "" for _none_ or LabelsDimLabelsString
	NVAR doVertical					// If non-zero, the dendrogram is above the heat map. Otherwise, to the left
	NVAR dendroMargin				// Size in plot-relative coordinates of the space reserved for the dendrogram lines and labels
	NVAR logDissimilarity			// place nodes at log(dissimilarity)

	NVAR labelFontSize
	NVAR labelFontStyle
	SVAR labelFontName
	NVAR labelColorR
	NVAR labelColorG
	NVAR labelColorB
	NVAR labelColorA
	NVAR labelUseClusterColors
	NVAR labelImageBuffer				// position of label right or bottom end relative to edge of image
	NVAR labelBuffer					// space added to left or top end of labels to indicate space between leaf lines and labels
	
	// Perpendicular labels are for the side of the heat map image that is not the dendrogram side
	// We don't offer them for double dendrograms
	SVAR perpendicularLabelWave
	NVAR perpendicularLabelSide
	
	NVAR showDistanceAxis
	
	NVAR lineThick
	NVAR lineStyle
	NVAR alignEnds						// if non-zero, leaf line ends are aligned. If zero, leaf lines extend to each label
	NVAR colorClusters					// if non-zero, color clusters using the ClusterColors wave from the path...
	SVAR clusterColorWavePath		// ... here
	NVAR lineColorR
	NVAR lineColorG
	NVAR lineColorB
	NVAR lineColorA
	NVAR useClusterLineStyles		// if non-zero, line styles for the dendrogram come from the wave ClusterStyles in the dendrogram's folder
	SVAR clusterLineStyleWavePath	// path to a wave with line style numbers for each cluster
	NVAR useClusterLineSizes
	SVAR clusterLineSizeWavePath	// path to a wave with line sizes for each cluster
	
	NVAR cutValue
	NVAR drawCutLine
	
	NVAR cutLineThick
	NVAR cutLineStyle
	NVAR cutLineColorR
	NVAR cutLineColorG
	NVAR cutLineColorB
	NVAR cutLineColorA
	
	SVAR ReorderedDataWave
EndStructure

static StrConstant gInfoUD = "DendroGraphInfo"						// used in some of the Modify panels to identify what we're working on
static StrConstant DendroInfoUD ="WMDendroNodeLinesInfo"			// used in a dendrogram graph to find the info about how to draw the dendrogram. For graphs with a one dendrogram.
static StrConstant DoubleDendroUD = "DoubleDendroInfo"				// used in a double dendrogram graph to get information about how to draw the two perpendicular dendrograms
static StrConstant nodeLinesGroup ="DendroNodeLinesGroup"			// Base name for a drawing object group containing all the node lines for a given dendrogram. Depending on orientation, suffixed with "_H" or "_V". A double dendrogram has both.
static StrConstant leafLabelsGroup ="DendroLeafLabelsGroup"		// Base name for a drawing object group containing the text identifying the leaf nodes. Also suffixed with "_V" or "_H".
static StrConstant distanceAxisName = "DendroDistanceAxis"		// Name of a free axis with dissimilarity values for a dendrogram. (TODO: we need "_V" and "_H" versions of this, too)
static StrConstant cutlinerectUD = "DendroCutLineRect"				// Rectangle around the cut line used in tracking a cut line drag.
static StrConstant cutLineGroup ="DendroCutLineGroup"				// Drawing object group for the cut line. Just one object, but we need it in order to erase and redraw the cut line.
static StrConstant cutLineHookName = "DendroCutLineManager"		// Name for the user data used to manage dragging the cut line. (TODO: this needs vertical and horizontal versions, too, no doubt)

// Takes in a panel name such as might be in a control structure win member. Looks for the user data
// containing the name of a graph hosting a dendrogram
static Function/S Dendro_GetGraphNameFromUserData(String wname)
	String userdata = GetUserData(wname, "", gInfoUD)
	if (strlen(userdata) == 0)
		return ""
	endif
	return StringByKey("GRAPHNAME", userdata, "=", ";")
end

static Function Dendro_GetDendroTypeFromUserData(String wname)
	String userdata = GetUserData(wname, "", gInfoUD)
	if (strlen(userdata) == 0)
		return -1
	endif
	return NumberByKey("DENDROTYPE", userdata, "=", ";")
end

// *** Create single dendrogram panel ***
static Function fComputeClusterPanel()
	if (WinType("HCluster_ComputeClusterPanel") == 7)
		DoWindow/F HCluster_ComputeClusterPanel
	else
		String pname = "HCluster_ComputeClusterPanel"
		String fmt = "NewPanel /K=1 /N="+pname+" /W=(%s)"
		Execute WC_WindowCoordinatesSprintf(pname, fmt, 150, 50, 525, 800, 1)

		ModifyPanel/W=$pname fixedSize=1
		DoWindow/T $pname, "Hierarchical Clustering and Dendrogram"

	// First the top group: use HCluster to compute the dendrogram wave
		GroupBox HCluster_ComputeDendrogramGroup,pos={10.00,2.00},size={356.00,451.00},title="Compute Hierarchical Cluster Dendrogram"
		GroupBox HCluster_ComputeDendrogramGroup,fSize=12

		TitleBox HCluster_VectorDataTitle,pos={50.00,34.00},size={99.00,16.00},title="Select Vector Data:"
		TitleBox HCluster_VectorDataTitle,fSize=12,frame=0

		Button HCluster_VectorDataSelector,pos={76.00,53.00},size={266.00,20.00},title="Vector data"
		MakeButtonIntoWSPopupButton(pname, "HCluster_VectorDataSelector", "")
		PopupWS_MatchOptions(pname, "HCluster_VectorDataSelector", listoptions="DIMS:2,CMPLX:0,TEXT:0,WAVE:0,DF:0")

		PopupMenu HCluster_PreProcessMenu,pos={75.00,85.00},size={276.00,20.00},bodyWidth=213,title="Preprocess:"
		PopupMenu HCluster_PreProcessMenu,fSize=12
		PopupMenu HCluster_PreProcessMenu,mode=1,value= #"\"None;Mean Center;Normalize [0,1];Center and Normalize [-1, 1];Xi/SD(X);(Xi-mean)/SD(X);\""

		CheckBox HCluster_PreProcessTransposeCBox,pos={75.00,113.00},size={184.00,16.00}
		CheckBox HCluster_PreProcessTransposeCBox,title="Transpose Before Preprocessing"
		CheckBox HCluster_PreProcessTransposeCBox,value=0

		TitleBox HCluster_PreprocessedNameTitle,pos={75.00,137.00},size={154.00,16.00},title="Name for Preprocessed Data:"
		TitleBox HCluster_PreprocessedNameTitle,fSize=12,frame=0
	
		SetVariable HCluster_PreprocessName,pos={93.00,158.00},size={250.00,19.00}
		SetVariable HCluster_PreprocessName,fSize=12,value= _STR:""

		String quote = "\""
		String menuvalue = "Euclidean;SquaredEuclidean;SEuclidean;Cityblock;Chebychev;Minkowski;"
		menuvalue += "Cosine;Canberra;BrayCurtis;Hamming;Jaccard;"
		menuvalue = quote + menuvalue + quote
		PopupMenu HCluster_DissimilarityMetricMenu,pos={50.00,201.00},size={178.00,20.00},title="Dissimilarity Metric:"
		PopupMenu HCluster_DissimilarityMetricMenu,fSize=12
		PopupMenu HCluster_DissimilarityMetricMenu,mode=1,popvalue="Euclidean",value= #menuvalue

		SetVariable HCluster_SetMinkowkiP,pos={87.00,226.00},size={133.00,19.00},bodyWidth=60,title="Minkowski P:"
		SetVariable HCluster_SetMinkowkiP,fSize=12,limits={1,inf,1},value= _NUM:2

		CheckBox HCluster_CreateDissimilarityMatrix,pos={50.00,252.00},size={154.00,16.00},title="Create Dissimilarity Matrix"
		CheckBox HCluster_CreateDissimilarityMatrix,help={"Adjusts columns of the vector data to a range of -1 to 1."}
		CheckBox HCluster_CreateDissimilarityMatrix,fSize=12,value= 1
	
		TitleBox HCluster_DissMatrixNameTitle,pos={75.00,275.00},size={156.00,16.00},title="Name for Dissimilarity Matrix:"
		TitleBox HCluster_DissMatrixNameTitle,fSize=12,frame=0
	
		SetVariable HCluster_DissMatrixName,pos={93.00,296.00},size={250.00,19.00}
		SetVariable HCluster_DissMatrixName,fSize=12
		SetVariable HCluster_DissMatrixName,value= _STR:""
	
		PopupMenu HCluster_LinkageMethodMenu,pos={50.00,342.00},size={165.00,20.00},title="Linkage Method:"
		PopupMenu HCluster_LinkageMethodMenu,fSize=12
		PopupMenu HCluster_LinkageMethodMenu,mode=1,popvalue="Complete",value= #"\"Complete;Average;Single;Weighted;Centroid;Median;Ward;\""
	
		TitleBox HCluster_DendrogramNameTitle,pos={79.00,368.00},size={179.00,16.00},title="Name for Dendrogram Info Wave:"
		TitleBox HCluster_DendrogramNameTitle,fSize=12,frame=0
	
		SetVariable HCluster_DendroGramName,pos={93.00,389.00},size={250.00,19.00}
		SetVariable HCluster_DendroGramName,fSize=12
		SetVariable HCluster_DendroGramName,value= _STR:""

		Button HCluster_ComputeDendroWave,pos={120.00,423.00},size={100.00,20.00},proc=HClusterDendrogramProcs#HCluster_ComputeButtonProc,title="Compute"

		GroupBox HCluster_DisplayHeatMapDendrogram,pos={10.00,458.00},size={356.00,252},title="Display Heat Map and Dendrogram"
		GroupBox HCluster_DisplayHeatMapDendrogram,fSize=12



	// The bottom group, display a heat map with a dendrogram
		TitleBox DendroPanel_DataWaveTitle,pos={52.00,482.00},size={64.00,15.00},title="Heat Map Data Wave:"
		TitleBox DendroPanel_DataWaveTitle,fSize=12,frame=0
	
		Button DendroPanel_DataWaveSelectorButton,pos={61.00,502.00},size={225.00,25.00}
		MakeButtonIntoWSPopupButton(pname, "DendroPanel_DataWaveSelectorButton", "")
			
		TitleBox DendroPanel_DendrogramWaveTitle,pos={51.00,537},size={108.00,15.00},title="Dendrogram Wave (from HCluster Operation):"
		TitleBox DendroPanel_DendrogramWaveTitle,fSize=12,frame=0
	
		Button DendroPanel_DendroWaveSelector,pos={61.00,557},size={225.00,25.00}
		MakeButtonIntoWSPopupButton(pname, "DendroPanel_DendroWaveSelector", "")
		PopupWS_MatchOptions(pname, "DendroPanel_DendroWaveSelector", nameFilterProc="HClusterDendrogramProcs#Dendro_CreatePanel_WaveButton_FilterProc")
	
		TitleBox DendroPanel_LabelsWaveTitle,pos={51.00,591},size={74.00,15.00},title="Dendrogram Labels Wave:"
		TitleBox DendroPanel_LabelsWaveTitle,fSize=12,frame=0
	
		Button DendroPanel_LabelWaveSelector,pos={61.00,610},size={225.00,25.00}
		Button DendroPanel_LabelWaveSelector,help={"Wave containing labels for each row of your data wave"}
		MakeButtonIntoWSPopupButton(pname, "DendroPanel_LabelWaveSelector", "")
		PopupWS_AddSelectableString(pname, "DendroPanel_LabelWaveSelector", LabelsNoneString)
		PopupWS_AddSelectableString(pname, "DendroPanel_LabelWaveSelector", LabelsDimLabelsString)
		PopupWS_MatchOptions(pname, "DendroPanel_LabelWaveSelector", listoptions="TEXT:1")
		
		CheckBox DendroPanel_PlotVerticalCheckbox,pos={110.00,649},size={134.00,16.00},title="Vertical Dendrogram"
		CheckBox DendroPanel_PlotVerticalCheckbox,fSize=12,value= 0

		Button DendroPanel_DoItButton,pos={152.00,678.00},size={50.00,20.00},proc=HClusterDendrogramProcs#Dendro_CreatePanel_DoItButtonProc,title="Do It"

		Button DendroPanel_HelpButton,pos={152.00,718.00},size={50.00,20.00}
		Button DendroPanel_HelpButton,title="Help", proc = HClusterDendrogramProcs#DendroPanel_HelpButtonProc

		SetWindow $pname, UserData(DendroCreatePanelVersion) = num2str(DendroCreatePanelVersion)
		SetWindow $pname, hook(WindowCoordinatesHook)=WC_WindowCoordinatesNamedHook
		SetWindow $pname, hook(DendroCreatePanelMaintenance)=HClusterDendrogramProcs#DendroCreatePanelMaintenanceHook
	endif
end

static Function Dendro_SaveCreatePanelSettings()
	DFREF SavedDF = GetDataFolderDFR()
	SetDataFolder root:Packages:DendroGram:
	if (DataFolderExists("CreatePanelSettings"))
		KillDataFolder CreatePanelSettings
	endif
	NewDataFolder/O/S CreatePanelSettings
	String pname = "HCluster_ComputeClusterPanel"

	ControlInfo/W=$pname HCluster_VectorDataSelector
	if (V_flag)
		String/G VectorData = PopupWS_GetSelectionFullPath(pname, "HCluster_VectorDataSelector")
	endif
	ControlInfo/W=$pname HCluster_PreProcessMenu
	if (V_flag)
		Variable/G PreprocessMode = V_value
	endif
	ControlInfo/W=$pname HCluster_PreProcessTransposeCBox
	if (V_flag)
		Variable/G doPreProcessTranspose = V_value
	endif
	ControlInfo/W=$pname HCluster_PreprocessName
	if (V_flag)
		String/G preProcessName = S_value
	endif
	ControlInfo/W=$pname HCluster_DissimilarityMetricMenu
	if (V_flag)
		Variable/G DissimilarityMetricMode = V_value
	endif
	ControlInfo/W=$pname HCluster_SetMinkowkiP
	if (V_flag)
		Variable/G MinkowskiP = V_value
	endif
	ControlInfo/W=$pname HCluster_CreateDissimilarityMatrix
	if (V_flag)
		Variable/G doDissimilarityMatrix = V_value
	endif
	ControlInfo/W=$pname HCluster_DissMatrixName
	if (V_flag)
		String/G disMatrixName = S_value
	endif
	ControlInfo/W=$pname HCluster_LinkageMethodMenu
	if (V_flag)
		Variable/G linkageMethodMode = V_value
	endif
	ControlInfo/W=$pname HCluster_DendroGramName
	if (V_flag)
		String/G DendroGramName = S_value
	endif
	ControlInfo/W=$pname DendroPanel_DataWaveSelectorButton
	if (V_flag)
		String/G DataWaveSelection = PopupWS_GetSelectionFullPath(pname, "DendroPanel_DataWaveSelectorButton")
	endif
	ControlInfo/W=$pname DendroPanel_DendroWaveSelector
	if (V_flag)
		String/G DendroWaveSelection = PopupWS_GetSelectionFullPath(pname, "DendroPanel_DendroWaveSelector")
	endif
	ControlInfo/W=$pname DendroPanel_LabelWaveSelector
	if (V_flag)
		String/G LabelWaveSelection = PopupWS_GetSelectionFullPath(pname, "DendroPanel_LabelWaveSelector")
	endif
	ControlInfo/W=$pname DendroPanel_PlotVerticalCheckbox
	if (V_flag)
		Variable/G doVertical = V_value
	endif
	
	SetDataFolder savedDF
end

static Function Dendro_RestoreCreatePanelSettings()

	String pname = "HCluster_ComputeClusterPanel"
	if (WinType(pname) != 7)
		return NAN
	endif

	DFREF SavedDF = GetDataFolderDFR()
	SetDataFolder root:Packages:DendroGram:
	if (DataFolderExists("CreatePanelSettings"))
		SetDataFolder :CreatePanelSettings

		ControlInfo/W=$pname HCluster_VectorDataSelector
		if (V_flag != 0)
			SVAR/Z VectorData
			if (SVAR_Exists(VectorData))
				PopupWS_SetSelectionFullPath(pname, "HCluster_VectorDataSelector", VectorData)
			endif
		endif

		ControlInfo/W=$pname HCluster_PreProcessMenu
		if (V_flag != 0)
			NVAR/Z PreprocessMode
			if (NVAR_Exists(PreprocessMode))
				PopupMenu HCluster_PreProcessMenu, win=$pname, mode = PreprocessMode
			endif
		endif

		ControlInfo/W=$pname HCluster_PreProcessTransposeCBox
		if (V_flag != 0)
			NVAR/Z doPreProcessTranspose
			if (NVAR_Exists(doPreProcessTranspose))
				Checkbox HCluster_PreProcessTransposeCBox, win=$pname, Value = doPreProcessTranspose
			endif
		endif

		ControlInfo/W=$pname HCluster_PreprocessName
		if (V_flag != 0)
			SVAR/Z preProcessName
			if (SVAR_Exists(preProcessName))
				SetVariable HCluster_PreprocessName, win=$pname, Value = _STR:preProcessName
			endif
		endif

		ControlInfo/W=$pname HCluster_DissimilarityMetricMenu
		if (V_flag != 0)
			NVAR/Z DissimilarityMetricMode
			if (NVAR_Exists(DissimilarityMetricMode))
				PopupMenu HCluster_DissimilarityMetricMenu, win=$pname, Mode = DissimilarityMetricMode
			endif
		endif

		ControlInfo/W=$pname HCluster_SetMinkowkiP
		if (V_flag != 0)
			NVAR/Z MinkowskiP
			if (NVAR_Exists(MinkowskiP))
				SetVariable HCluster_SetMinkowkiP, win=$pname, Value = _NUM:MinkowskiP
			endif
		endif

		ControlInfo/W=$pname HCluster_CreateDissimilarityMatrix
		if (V_flag != 0)
			NVAR/Z doDissimilarityMatrix
			if (NVAR_Exists(doDissimilarityMatrix))
				Checkbox HCluster_CreateDissimilarityMatrix, win=$pname, value = doDissimilarityMatrix
			endif
		endif

		ControlInfo/W=$pname HCluster_DissMatrixName
		if (V_flag != 0)
			SVAR/Z disMatrixName
			if (SVAR_Exists(disMatrixName))
				SetVariable HCluster_DissMatrixName, win=$pname, Value = _STR:disMatrixName
			endif
		endif

		ControlInfo/W=$pname HCluster_LinkageMethodMenu
		if (V_flag != 0)
			NVAR/Z linkageMethodMode
			if (NVAR_Exists(linkageMethodMode))
				PopupMenu HCluster_LinkageMethodMenu, win=$pname, mode = linkageMethodMode
			endif
		endif

		ControlInfo/W=$pname HCluster_DendroGramName
		if (V_flag != 0)
			SVAR/Z DendroGramName
			if (SVAR_Exists(DendroGramName))
				SetVariable HCluster_DendroGramName, win=$pname, Value = _STR:DendroGramName
			endif
		endif

		ControlInfo/W=$pname DendroPanel_DataWaveSelectorButton
		if (V_flag != 0)
			SVAR/Z DataWaveSelection
			if (SVAR_Exists(DataWaveSelection))
				PopupWS_SetSelectionFullPath(pname, "DendroPanel_DataWaveSelectorButton", DataWaveSelection)
			endif
		endif

		ControlInfo/W=$pname DendroPanel_DendroWaveSelector
		if (V_flag != 0)
			SVAR/Z DendroWaveSelection
			if (SVAR_Exists(DendroWaveSelection))
				PopupWS_SetSelectionFullPath(pname, "DendroPanel_DendroWaveSelector", DendroWaveSelection)
			endif
		endif

		ControlInfo/W=$pname DendroPanel_LabelWaveSelector
		if (V_flag != 0)
			SVAR/Z LabelWaveSelection
			if (SVAR_Exists(LabelWaveSelection))
				PopupWS_SetSelectionFullPath(pname, "DendroPanel_LabelWaveSelector", LabelWaveSelection)
			endif
		endif

		ControlInfo/W=$pname DendroPanel_PlotVerticalCheckbox
		if (V_flag != 0)
			NVAR/Z doVertical
			if (NVAR_Exists(doVertical))
				Checkbox DendroPanel_PlotVerticalCheckbox, win=$pname, value = doVertical
			endif
		endif
	endif

	SetDataFolder savedDF
end

static Function DendroCreatePanelCheckVersion()

	// This recursion preventer is needed because killing and recreating a panel involves
	// activate events, and this function is called from the panel's activate event in a window hook
	NVAR/Z recursionFlag = root:Packages:DendroGram:DendroCreateRecursionFlag
	if (NVAR_Exists(recursionFlag) && recursionFlag != 0)
		return 0
	endif
	
	String versionInfo = GetUserData("HCluster_ComputeClusterPanel", "", "DendroCreatePanelVersion")
	if (strlen(versionInfo) == 0 || str2num(versionInfo) < DendroCreatePanelVersion)
		DoAlert 0, "The existing Hierarchical Clustering and Dendrogram panel was created by an older version of the Hierarchical Clustering and Dendrogram package. It will be closed and recreated."
		Dendro_SaveCreatePanelSettings();
		Variable/G root:Packages:DendroGram:DendroCreateRecursionFlag = 1
		Execute/P/Q "KillWindow HCluster_ComputeClusterPanel"
		Execute/P/Q "fComputeClusterPanel()"
		Execute/P/Q "HClusterDendrogramProcs#Dendro_RestoreCreatePanelSettings()"
		Execute/P/Q "KillVariables root:Packages:DendroGram:DendroCreateRecursionFlag"
	endif
end

static Function DendroCreatePanelMaintenanceHook(Struct WMWinHookStruct & s)

	strswitch(s.eventName)
		case "activate":
			Execute/P/Q "HClusterDendrogramProcs#DendroCreatePanelCheckVersion()"
			break
	endswitch
end

Static Function DendroPanel_HelpButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			DisplayHelpTopic "Hierarchical Clustering Package"
			break
	endswitch

	return 0
End


static Function HCluster_ComputeButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	if (ba.eventCode == 2)
		String selectedWaveName = PopupWS_GetSelectionFullPath(ba.win, "HCluster_VectorDataSelector")
		Wave/Z w = $selectedWaveName
		if (!WaveExists(w))
			DoAlert 0, "You need to select a wave from the \"Select Vector Data\" menu."
			return -1
		endif
		DFREF dataDFR = GetWavesDataFolderDFR(w)
		
		ControlInfo/W=$ba.win HCluster_VectorsAreColumns
		Variable transposeData = V_value
		String outputBaseName = NameOfWave(w)
		
		ControlInfo/W=$ba.win HCluster_PreProcessMenu
		Variable preprocOption = V_value-1
		ControlInfo/W=$ba.win HCluster_PreProcessTransposeCBox
		Variable doTranspose = V_value
		
		if (preprocOption > 0 || doTranspose)
			Wave preProcW = HCluster_PreprocessData(w, preprocOption, doTranspose)
			ControlInfo/W=$ba.win HCluster_PreprocessName
			String preprocessName = S_value
			if (strlen(preprocessName) == 0)
				preprocessName = outputBaseName+"_pre"+num2str(preprocOption)
			endif
			Duplicate/O preProcW, dataDFR:$preprocessName/WAVE=preProcW
		else
			Wave preProcW = w
		endif
		
		ControlInfo/W=$ba.win HCluster_DissimilarityMetricMenu
		String dissMetric = S_value
		if (CmpStr(dissMetric, "Minkowski") == 0)
			ControlInfo/W=$ba.win HCluster_SetMinkowkiP
			Variable minkowskiP = V_value
		endif

		ControlInfo/W=$ba.win HCluster_LinkageMethodMenu
		String linkage = S_value
		
		String outputType = "DendroGram"
		String dissMatrixName = ""
		ControlInfo/W=$ba.win HCluster_CreateDissimilarityMatrix
		if (V_value)
			outputType = "Both"
			ControlInfo/W=$ba.win HCluster_DissMatrixName
			dissMatrixName = S_value
			if (strlen(dissMatrixName) == 0)
				dissMatrixName = outputBaseName
				if (preprocOption > 0)
					dissMatrixName += "_pre"+num2str(preprocOption)
				endif
			dissMatrixName += "_diss"
			endif
		endif
		
		ControlInfo/W=$ba.win HCluster_DendroGramName
		String dendroName = S_value
		if (strlen(dendroName) == 0)
			dendroName = outputBaseName
			if (preprocOption > 0)
				dendroName += "_pre"+num2str(preprocOption)
			endif
			dendroName += "_dendro"
		endif
		Wave out = HCluster_CallHCluster(preProcW, outputBaseName, outputType, linkage, dissMetric, dissMatrixName, dendroName)
		
		PopupWS_SetSelectionFullPath(ba.win, "DendroPanel_DataWaveSelectorButton", GetWavesDataFolder(preProcW, 2))
		PopupWS_SetSelectionFullPath(ba.win, "DendroPanel_DendroWaveSelector", GetWavesDataFolder(out, 2))
	endif

	return 0
End

// Returns a wave reference to a free wave that is a copy of vectorData (rows are vectors), possibly transposed, and then processed by one of these options:
// 0: none (or just transpose)
// 1: mean centered, xi-mean(x)
// 2: normalized, (xi-min(x)/(max(x)-min(x)); range is [0, 1]
// 3: center and normalize, 2*(xi - mean(x))/(max(x) - min(x)); range is [-1, 1]
// 4: xi/SD(x), where SD is standard deviation
// 5: (xi-mean(x))/SD(x)
// This is the order of the items in HCluster_PreProcessMenu, but the first menu item is None, so you have to subtract one
Function/WAVE HCluster_PreprocessData(Wave vectorData, Variable preprocessType, Variable transposeData)
	if (preprocessType == 0 && !transposeData)
		return $""
	endif
	if (transposeData)
		MatrixOP/FREE inputData = vectorData^t
	else
		MatrixOP/FREE inputData = vectorData
	endif
	switch(preprocessType)
		case 0:				// transpose only
			MatrixOP/S/FREE out = inputData
			break;
		case 1:
			MatrixOP/FREE out = subtractMean(inputData, 1)
			break
		case 2:
			MatrixOP/FREE out = addCols(inputData, -minCols(inputData))
			MatrixOP/FREE range = maxCols(inputData) - minCols(inputData)
			out = out[p][q]/range[q]
			break
		case 3:
			MatrixOP/FREE out = subtractMean(inputData, 1)
			MatrixOP/FREE range = (maxCols(inputData) - minCols(inputData))/2
			out = out[p][q]/range[q]
			break
		case 4:
			MatrixOP/FREE sd = sqrt(varCols(inputData))
			Duplicate/FREE inputData, out
			out = out[p][q]/sd[q]
			break
		case 5:
			MatrixOP/FREE out = subtractMean(inputData, 1)
			MatrixOP/FREE sd = sqrt(varCols(inputData))
			out = out[p][q]/sd[q]
			break
	endswitch
	
	if (transposeData)
		CopyDimLabels/COLS=0 vectorData, out
	else
		CopyDimLabels/ROWS=0 vectorData, out
	endif
	
	return out
end

// Takes in vector data and calls HCluster operation to create a dendrogram wave and optional dissimilarity matrix
Function/WAVE HCluster_CallHCluster(Wave vectorData, String basename, String outtype, String linkage, String dissMetric, String dissMatrixName, String dendroWaveName)
	
	if (CmpStr(outtype, "BOTH") == 0 && strlen(dissMatrixName) == 0)
		dissMatrixName = basename+"_Diss"
	endif	
	if (strlen(dendroWaveName) == 0)
		dendroWaveName = basename+"_Dendro"
	endif
	if (CmpStr(outtype, "BOTH") == 0)
		HCluster/ITYP=vectors/OTYP=$outtype/LINK=$linkage/DISS=$dissMetric/DEST={$dissMatrixName, $dendroWaveName}/O vectorData
	else
		HCluster/ITYP=vectors/OTYP=$outtype/LINK=$linkage/DISS=$dissMetric/DEST=$dendroWaveName/O vectorData
	endif
	
	Wave dendroWave = $dendroWaveName
	return dendroWave
end

static Function Dendro_CreatePanel_WaveButton_FilterProc(String wname, Variable contents)
	Variable AcceptIt = 1
	Wave w = $wname
	if (WaveType(w, 1) != 1)
		AcceptIt = 0
	endif
	if (DimSize(w, 1) != 4)
		AcceptIt = 0
	endif
	
	return AcceptIt
end

static Function Dendro_CreatePanel_DoItButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			String dataWaveName = PopupWS_GetSelectionFullPath(ba.win, "DendroPanel_DataWaveSelectorButton")
			Wave/Z dataWave = $dataWaveName
			if (!WaveExists(dataWave))
				DoAlert 0, "Your Data wave was not found. Perhaps you need to select one?"
				return 0
			endif
			
			String dendroWaveName = PopupWS_GetSelectionFullPath(ba.win, "DendroPanel_DendroWaveSelector")
			Wave/Z dendroWave = $dendroWaveName
			if (!WaveExists(dendroWave))
				DoAlert 0, "Your Dendrogram wave was not found. Perhaps you need to select one?"
				return 0
			endif
			
			String labelWavePath = PopupWS_GetSelectionFullPath(ba.win, "DendroPanel_LabelWaveSelector")
			Wave/Z/T labelWave = $labelWavePath
			
			ControlInfo/W=HCluster_ComputeClusterPanel DendroPanel_PlotVerticalCheckbox
			Variable doVertical = V_value
			
			PlotDendrogram(dendroWave, datawave, labelWavePath, doVertical)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

static Function fCreateModifyDendrogramPanel(string gname, Variable dendroType)
	String panelName = gname+"#ModifyDendrogramPanel"
	if (DendroModPanel_CheckVersion(gname))
		return 0
	endif
	if (WinType(panelName) == 7)
		if (Dendro_GetDendroTypeFromUserData(panelName) == dendroType)
			return 0
		else
			KillWindow $panelName
		endif
	endif
	if (WinType(panelName) != 7)
		fModifyDendrogramPanel(gname, dendroType)
	endif
end

static StrConstant PanelSubwindows="ClustersTab;LinesTab;LabelsTab;PostProcessTab;"

Function DDendro_GraphHasDoubleDendrogram(string gname)
	if (strlen(gname) == 0 || WinType(gname) != 1)
		return 0
	endif
	String DDDIuserdata = GetUserData(gname, "", DoubleDendroUD)
	return strlen(DDDIuserdata) != 0
end

Function Dendro_GraphHasSingleDendrogram(string gname)
	if (strlen(gname) == 0)
		return 0
	endif
	String DDIuserdata = GetUserData(gname, "", DendroInfoUD)
	return strlen(DDIuserdata) != 0
end

// *** Modify Dendrogram Panel ***
static Function fModifyDendrogramPanel(string gname, Variable dendroType)
	STRUCT DendrogramDrawInfo DDI
	if (Dendro_FillStructureForGraph(gname, DDI, dendroType) < 0)
		DoAlert 0, "Request to modify a dendrogram of the wrong type"
		return -1
	endif
	Wave dwave = $DDI.dendrogramDataWave
	String DendroUserDataString = "GRAPHNAME="+gname+";"
	DendroUserDataString += "DENDROTYPE="+num2str(dendroType)+";"
	
	Wave dendroWave = $(DDI.dendrogramWaveName)
	MatrixOP/FREE distCol = Col(dendroWave, 2)
	Variable highcut, lowcut
	[lowcut, highcut] = WaveMinAndMax(distCol)

	String titleString
	switch (dendroType)
		case DendroTypeH:
			titleString = "Modify Horizontal Dendrogram"
			break;
		case DendroTypeV:
			titleString = "Modify Vertical Dendrogram"
			break;
		case DendroTypeSingle:
			titleString = "Modify Dendrogram"
			break;
	endswitch
	NewPanel/HOST=$gname/EXT=0/W=(0,0,300,570) as titleString
	RenameWindow #, ModifyDendrogramPanel
	
	SetWindow $gname#ModifyDendrogramPanel, userdata($gInfoUD)=DendroUserDataString
	String panelName = gname + "#ModifyDendrogramPanel"

	TabControl Dendro_ModPanel_TabControl, win=$panelName,pos={1.00,1.00},size={300.00,500.00},proc=HClusterDendrogramProcs#Dendro_ModPanel_TabControlProc
	TabControl Dendro_ModPanel_TabControl, win=$panelName,tabLabel(0)="Clusters"
	TabControl Dendro_ModPanel_TabControl, win=$panelName,tabLabel(1)="Lines"
	TabControl Dendro_ModPanel_TabControl, win=$panelName,tabLabel(2)="Labels"
	TabControl Dendro_ModPanel_TabControl, win=$panelName,tabLabel(3)="Post-process"
	TabControl Dendro_ModPanel_TabControl, win=$panelName,value= 0, focusRing=0
	
	PopupMenu Dendro_ModPanel_PrefsMenu,pos={41.00,524.00},size={104.00,20.00},proc=HClusterDendrogramProcs#Dendro_ModPanel_PrefsMenuProc,title="Preferences"
	PopupMenu Dendro_ModPanel_PrefsMenu,mode=0,value= #"\"Save as Preference;Apply Preferences;Revert Preferences to Default;\""

	Button Dendro_ModPanel_HelpButton,pos={216.00,524.00},size={50.00,20.00},proc=HClusterDendrogramProcs#DendroPanel_HelpButtonProc
	Button Dendro_ModPanel_HelpButton,title="Help"

	DefineGuide/W=$panelName UGV0={FR,-14},UGV1={FL,14},UGH0={FB,-79},UGH1={FT,38}

// Clusters tab ****************
	String tabname = StringFromList(0, PanelSubwindows)
	NewPanel/W=(12,33,286,466)/FG=(UGV1,UGH1,UGV0,UGH0)/HOST=$panelName
	RenameWindow #,$tabname
	String clustertabname = panelName + "#"+tabname
	SetWindow $clustertabname, userdata($gInfoUD)=DendroUserDataString
	ModifyPanel/W=$clustertabname cbRGB=(0,0,0,0), frameStyle=0
	
	SetVariable Dendro_ModPanel_SetCutValue,win=$clustertabname,pos={26.00,46},size={123.00,14.00},bodyWidth=60,title="Cut Distance:"
	SetVariable Dendro_ModPanel_SetCutValue,win=$clustertabname,help={"Set the distance at which different clusters are divided from the tree"}
	SetVariable Dendro_ModPanel_SetCutValue,win=$clustertabname,limits={lowcut, highcut, (highcut-lowcut)/20}
	Variable cval = DDI.cutValue
	SetVariable Dendro_ModPanel_SetCutValue,win=$clustertabname,value= _NUM:cval,proc=HClusterDendrogramProcs#Dendro_ModPanel_SetVariableProc
	SetVariable Dendro_ModPanel_SetCutValue,win=$clustertabname, help={"Set the distance at which different clusters are divided from the tree. Set to zero if you don't want colored lines indicating clusters."}
	
	CheckBox Dendro_ModPanel_DrawCutLineCheckbox,win=$clustertabname,pos={26.00,14.00},size={79.00,16.00},title="Draw Cut Line"
	Variable drawcut = DDI.drawCutLine
	CheckBox Dendro_ModPanel_DrawCutLineCheckbox,win=$clustertabname,value=drawcut,proc=HClusterDendrogramProcs#Dendro_ModPanel_CheckProc
	CheckBox Dendro_ModPanel_DrawCutLineCheckbox help={"Turn on this checkbox to show the cut value determining which nodes are clustered together. Clusters will be colored whether or not the cut line is drawn."}
	
	PopupMenu Dendro_ModPanel_CutLineStyle,win=$clustertabname,pos={26.00,75.00},size={217.00,20.00},title="Cut Line Style:"
	Variable cutstyle = DDI.cutLineStyle+1
	PopupMenu Dendro_ModPanel_CutLineStyle,win=$clustertabname,mode=cutstyle,value= #"\"*LINESTYLEPOP*\"",proc=HClusterDendrogramProcs#Dendro_ModPanel_PopMenuProc
	
	Variable cutthick = DDI.cutLineThick
	SetVariable Dendro_ModPanel_SetCutLineThickness,win=$clustertabname,pos={26.00,110.00},size={150.00,14.00},bodyWidth=60,title="Cut Line Thickness:"
	SetVariable Dendro_ModPanel_SetCutLineThickness,win=$clustertabname,limits={0,10,0.5},value= _NUM:cutthick,proc=HClusterDendrogramProcs#Dendro_ModPanel_SetVariableProc
	
	Variable r = DDI.cutLineColorR
	Variable g = DDI.cutLineColorG
	Variable b = DDI.cutLineColorB
	Variable a = DDI.cutLineColorA
	PopupMenu Dendro_ModPanel_CutLineColor,win=$clustertabname,pos={26.00,138.00},size={119.00,20.00},title="Cut Line Color:"
	PopupMenu Dendro_ModPanel_CutLineColor,win=$clustertabname,mode=1,popColor= (r,g,b,a),value= #"\"*COLORPOP*\"",proc=HClusterDendrogramProcs#Dendro_ModPanel_PopMenuProc
	
	CheckBox Dendro_ModPanel_AddDistanceAxis,win=$clustertabname,pos={26.00,166},size={165.00,16.00},title="Add distance axis on Dendrogram"
	CheckBox Dendro_ModPanel_AddDistanceAxis,win=$clustertabname,value=DDI.showDistanceAxis,proc=HClusterDendrogramProcs#Dendro_ModPanel_CheckProc
	CheckBox Dendro_ModPanel_AddDistanceAxis,win=$clustertabname,help={"Add an axis next to the dendrogram showing the dissimilarity values represented by the tree."}

	CheckBox Dendro_ModPanel_LogDissimilarityCheckbox,win=$clustertabname,pos={26.00,184},size={121.00,16.00}
	CheckBox Dendro_ModPanel_LogDissimilarityCheckbox,win=$clustertabname,title="Plot Log of Dissimilarity"
	CheckBox Dendro_ModPanel_LogDissimilarityCheckbox,win=$clustertabname,value= 0,proc=HClusterDendrogramProcs#Dendro_ModPanel_CheckProc

	CheckBox Dendro_ModPanel_ClusterLabels,win=$clustertabname,pos={26,201},size={106.00,16.00}, proc=HClusterDendrogramProcs#Dendro_ModPanel_ClusterLabelsCheckProc
	CheckBox Dendro_ModPanel_ClusterLabels,win=$clustertabname,title="Show Cluster Labels",value=HClusterDendrogramProcs#Dendro_hasClusterNumbers(gname, DDI.doVertical)
	CheckBox Dendro_ModPanel_ClusterLabels,win=$clustertabname,help={"Internally the clusters have numbers; those numbers appear in the lists of cluster colors, etc.\rTurn on this checkbox to display those numbers on the dendrogram."}

	CheckBox Dendro_ModPanel_ColorClustersCheck,win=$clustertabname,pos={26.00,230},size={95.00,16.00},proc=HClusterDendrogramProcs#Dendro_ModPanel_CheckProc,title="Color the clusters"
	CheckBox Dendro_ModPanel_ColorClustersCheck,win=$clustertabname,value=DDI.colorClusters
	CheckBox Dendro_ModPanel_ColorClustersCheck,win=$clustertabname,help={"Turn on this checkbox to make each cluster a different color. The Labels tab has a checkbox to color the row labels the same way."}

	Button Dendro_ModPanel_DoGroupColors,win=$clustertabname,pos={58.00,253.00},size={150.00,20.00},proc=HClusterDendrogramProcs#Dendro_ModPanel_DoGroupColorsButtonProc,title="Edit Colors..."
	Button Dendro_ModPanel_DoGroupColors,win=$clustertabname,help={"Click this button to display an editor allowing you to choose different colors for the clusters.\rIt may help to turn on the Cluster Labels checkbox below.\rYou can also right-click on a cluster to change the color."}

	CheckBox Dendro_ModPanel_ApplyColorsToLabels,win=$clustertabname,pos={59.00,281.00},size={121.00,16.00},proc=HClusterDendrogramProcs#Dendro_ModPanel_CheckProc
	CheckBox Dendro_ModPanel_ApplyColorsToLabels,win=$clustertabname,title="Apply to Labels, too",value=DDI.labelUseClusterColors

	CheckBox Dendro_ModPanel_ClusterLineStylesCheck,win=$clustertabname,pos={26.00,316.00},size={114.00,16.00},proc=HClusterDendrogramProcs#Dendro_ModPanel_CheckProc,title="Use cluster line styles"
	CheckBox Dendro_ModPanel_ClusterLineStylesCheck,win=$clustertabname,value=DDI.useClusterLineStyles
	CheckBox Dendro_ModPanel_ClusterLineStylesCheck,win=$clustertabname,help={"Turn on this checkbox to enable dashed lines for the clusters."}
	
	Button Dendro_ModPanel_EditClusterLineStylesButton,win=$clustertabname,pos={58.00,338.00},size={150.00,20.00},proc=HClusterDendrogramProcs#Dendro_ModPanel_EditLineStylesButtonProc,title="Edit Line Styles..."
	Button Dendro_ModPanel_EditClusterLineStylesButton,win=$clustertabname, help={"Click this button to display an editor allowing you to change the line styles for each cluster.\rIt may help to turn on the Cluster Labels checkbox below.\rYou can also right-click on a cluster to change the line style."}

	CheckBox Dendro_ModPanel_ClusterLineSizesCheck,win=$clustertabname,pos={26.00,374.00},size={130.00,16.00},proc=HClusterDendrogramProcs#Dendro_ModPanel_CheckProc,title="Use cluster line thickness"
	CheckBox Dendro_ModPanel_ClusterLineSizesCheck,win=$clustertabname,value=DDI.useClusterLineSizes

	Button Dendro_ModPanel_EditClusterLineSizesButton,win=$clustertabname,pos={58.00,396.00},size={150.00,20.00},proc=HClusterDendrogramProcs#Dendro_ModPanel_EditLineSizeButtonProc,title="Edit Line Thickness..."
	Button Dendro_ModPanel_EditClusterLineSizesButton,win=$clustertabname, help={"Click this button to display an editor allowing you to change the line thickness for each cluster.\rIt may help to turn on the Cluster Labels checkbox below.\rYou can also right-click on a cluster to change the line thickness."}

	SetActiveSubwindow ##
// End of Clusters tab ****************
	
// Lines tab **************
	tabname = StringFromList(1, PanelSubwindows)
	NewPanel/W=(12,33,286,466)/FG=(UGV1,UGH1,UGV0,UGH0)/HOST=$panelName
	RenameWindow #,$tabname
	String linestabName = panelName + "#"+tabname
	SetWindow $linestabName, userdata($gInfoUD)=DendroUserDataString
	ModifyPanel/W=$linestabName cbRGB=(0,0,0,0), frameStyle=0
	
	SetVariable DendroPanel_SetDendroSpace,win=$linestabname,pos={70.00,17.00},size={165.00,14.00},bodyWidth=60,title="Space for dendrogram:"
	SetVariable DendroPanel_SetDendroSpace,win=$linestabname,help={"Fraction of plot area reserved for the dendrogram and labels"}
	SetVariable DendroPanel_SetDendroSpace,win=$linestabname,limits={0,1,0.1},value= _NUM:DDI.dendroMargin,proc=HClusterDendrogramProcs#Dendro_ModPanel_SetVariableProc
	
	SetVariable DendroPanel_LabelImageMargin,win=$linestabname,pos={24.00,49.00},size={211.00,14.00},bodyWidth=60,title="Space between labels and image:"
	SetVariable DendroPanel_LabelImageMargin,win=$linestabname,help={"Fraction of plot area between the labels and the image"}
	SetVariable DendroPanel_LabelImageMargin,win=$linestabname,limits={-inf,inf,0.01},value= _NUM:DDI.labelImageBuffer,proc=HClusterDendrogramProcs#Dendro_ModPanel_SetVariableProc
	
	SetVariable DendroPanel_LineLabelSpace,win=$linestabname,pos={14.00,81.00},size={221.00,14.00},bodyWidth=60,title="Space between leaf lines and labels"
	SetVariable DendroPanel_LineLabelSpace,win=$linestabname,help={"Fraction of plot area reserved as space between the ends of the dendrogram lines and the start of the labels"}
	SetVariable DendroPanel_LineLabelSpace,win=$linestabname,limits={-inf,inf,0.01},value= _NUM:DDI.labelBuffer,proc=HClusterDendrogramProcs#Dendro_ModPanel_SetVariableProc
	
	CheckBox DendroPanel_AlignLeafLines,win=$linestabname,pos={135.00,112.00},size={100.00,16.00},title="Align leaf line ends"
	CheckBox DendroPanel_AlignLeafLines,win=$linestabname,help={"If turned on, the ends of the leaf lines are all aligned. If off, they extend to each label"}
	CheckBox DendroPanel_AlignLeafLines,win=$linestabname,value=DDI.alignEnds,proc=HClusterDendrogramProcs#Dendro_ModPanel_CheckProc
	
	PopupMenu DendroPanel_DefaultLineColor,win=$linestabname,pos={104.00,142.00},size={131.00,20.00},title="Default line color:"
	PopupMenu DendroPanel_DefaultLineColor,win=$linestabname,help={"Color of the dendrogram lines if they are not part of a cluster (see Clusters tab)"}
	r = DDI.lineColorR
	g = DDI.lineColorG
	b = DDI.lineColorB
	a = DDI.lineColorA
	PopupMenu DendroPanel_DefaultLineColor,win=$linestabname,mode=1,popColor= (r,g,b,a),value= #"\"*COLORPOP*\"",proc=HClusterDendrogramProcs#Dendro_ModPanel_PopMenuProc
	
	PopupMenu DendroPanel_LineStyle,win=$linestabname,pos={37.00,174.00},size={198.00,20.00},title="Line style:"
	PopupMenu DendroPanel_LineStyle,win=$linestabname,mode=DDI.lineStyle+1,value= #"\"*LINESTYLEPOP*\"",proc=HClusterDendrogramProcs#Dendro_ModPanel_PopMenuProc
	
	SetVariable DendroPanel_DendroLineThickness,win=$linestabname,pos={105.00,210.00},size={130.00,14.00},bodyWidth=60,title="Line thickness:"
	SetVariable DendroPanel_DendroLineThickness,win=$linestabname,value= _NUM:DDI.lineThick,proc=HClusterDendrogramProcs#Dendro_ModPanel_SetVariableProc

	SetActiveSubwindow ##
// End of Lines tab **************
	
// Labels tab ***********
	tabname = StringFromList(2, PanelSubwindows)
	NewPanel/W=(12,33,286,466)/FG=(UGV1,UGH1,UGV0,UGH0)/HOST=$panelName
	RenameWindow #,$tabname
	String labelstabName = panelName + "#"+tabname
	SetWindow $labelstabName, userdata($gInfoUD)=DendroUserDataString
	ModifyPanel/W=$labelstabName cbRGB=(0,0,0,0), frameStyle=0

	String fontname = DDI.labelFontName
	PopupMenu Dendro_ModPanel_LabelFont,win=$labelstabname,pos={31.00,24.00},size={205.00,20.00},bodyWidth=180,title="Font:"
	PopupMenu Dendro_ModPanel_LabelFont,win=$labelstabname,popvalue="default",value= #"\"default;\"+FontList(\";\")", proc=HClusterDendrogramProcs#Dendro_ModPanel_PopMenuProc
	Variable mode=1
	if (CmpStr(fontname, "default") != 0)
		Variable listitem = WhichListItem(fontname, FontList(";"))
		if (listitem >= 0)
			mode = listitem+2		// +1 for "default", +1 because menu mode is 1-based
		endif
		PopupMenu Dendro_ModPanel_LabelFont,win=$labelstabname,mode=mode
	endif
	
	Variable fsize=DDI.labelFontSize
	SetVariable Dendro_ModPanel_SetFontSize,win=$labelstabname,pos={80.00,68.00},size={107.00,14.00},bodyWidth=60,title="Font size:"
	SetVariable Dendro_ModPanel_SetFontSize,win=$labelstabname,limits={0,inf,1},value= _NUM:fsize, proc=HClusterDendrogramProcs#Dendro_ModPanel_SetVariableProc
	
	Variable fstyle=DDI.labelFontStyle
	CheckBox Dendro_ModPanel_BoldCheck,win=$labelstabname,pos={91.00,99.00},size={37.00,16.00},title="Bold"
	CheckBox Dendro_ModPanel_BoldCheck,win=$labelstabname,value=(fstyle&1), proc=HClusterDendrogramProcs#Dendro_ModPanel_CheckProc
	
	CheckBox Dendro_ModPanel_ItalicCheck,win=$labelstabname,pos={91.00,119.00},size={38.00,16.00},title="Italic"
	CheckBox Dendro_ModPanel_ItalicCheck,win=$labelstabname,value=(fstyle&2), proc=HClusterDendrogramProcs#Dendro_ModPanel_CheckProc
	
	CheckBox Dendro_ModPanel_UnderlineCheck,win=$labelstabname,pos={91.00,139.00},size={59.00,16.00},title="Underline"
	CheckBox Dendro_ModPanel_UnderlineCheck,win=$labelstabname,value=(fstyle&4), proc=HClusterDendrogramProcs#Dendro_ModPanel_CheckProc
	
	CheckBox Dendro_ModPanel_StrikethroughCheck,win=$labelstabname,pos={91.00,159.00},size={77.00,16.00},title="Strikethrough"
	CheckBox Dendro_ModPanel_StrikethroughCheck,win=$labelstabname,value=(fstyle&8), proc=HClusterDendrogramProcs#Dendro_ModPanel_CheckProc
	
	GroupBox Dendro_ModPanel_LabelColorGroup,win=$labelstabname,pos={19.00,183.00},size={237.00,89.00},title="Color"
	
	CheckBox Dendro_ModPanel_LabelsUseClusterColors,win=$labelstabname,pos={49.00,211.00},size={99.00,16.00},title="Use Cluster Colors"
	CheckBox Dendro_ModPanel_LabelsUseClusterColors,win=$labelstabname,value=DDI.labelUseClusterColors, proc=HClusterDendrogramProcs#Dendro_ModPanel_CheckProc
	
	PopupMenu Dendro_ModPanel_LabelDefaultColor,win=$labelstabname,pos={51.00,236.00},size={112.00,20.00},title="Default color:"
	r = DDI.labelColorR
	g = DDI.labelColorG
	b = DDI.labelColorB
	a = DDI.labelColorA
	PopupMenu Dendro_ModPanel_LabelDefaultColor,win=$labelstabname,mode=1,popColor=(r,g,b,a), value= #"\"*COLORPOP*\"", proc=HClusterDendrogramProcs#Dendro_ModPanel_PopMenuProc

	if (dendroType == DendroTypeSingle)
		GroupBox Dendro_ModPanel_LabelVectorComponents,win=$labelstabname,pos={19.00,293.00},size={237.00,144.00},title="Perpendicular labels"
		GroupBox Dendro_ModPanel_LabelVectorComponents,win=$labelstabname,help={"Text labels for the non-dendrogram side of the heat map image"}

		TitleBox Dendro_ModPanel_PerpLabelsSelectorTitle,win=$labelstabname,pos={40.00,322.00},size={83.00,11.00},title="Select a text wave:"
		TitleBox Dendro_ModPanel_PerpLabelsSelectorTitle,win=$labelstabname,frame=0

		Button Dendro_ModPanelPerpendicularLabelsWave,win=$labelstabname,pos={38.00,336.00},size={200.00,25.00}
		MakeButtonIntoWSPopupButton(labelstabname, "Dendro_ModPanelPerpendicularLabelsWave", "", initialSelection = DDI.perpendicularLabelWave)
		String listoptions = "DIMS:1,CMPLX:0,TEXT:1,WAVE:0,DF:0,"
		listoptions += "MINROWS:"+num2str(DimSize(dwave, 1))+","
		listoptions += "MAXROWS:"+num2str(DimSize(dwave, 1))
		PopupWS_MatchOptions(labelstabname, "Dendro_ModPanelPerpendicularLabelsWave", listoptions=listoptions)

		PopupMenu Dendro_ModPanelPerpendicularLabelsSide,win=$labelstabname,pos={41.00,368.00},size={95.00,20.00},bodyWidth=70
		PopupMenu Dendro_ModPanelPerpendicularLabelsSide,win=$labelstabname,title="Side:"
		String menustr = "HClusterDendrogramProcs#Dendro_PerpLabelsSideMenuString(\""+gname+"\", "+num2str(dendroType)+")"
		PopupMenu Dendro_ModPanelPerpendicularLabelsSide,win=$labelstabname,mode=(DDI.perpendicularLabelSide ? 2 : 1),value= #menustr

		CheckBox Dendro_ModPanel_ShowPerpLabelsCheckbox,win=$labelstabname,pos={38.00,402.00},size={136.00,16.00},proc=HClusterDendrogramProcs#Dendro_ModPanel_CheckProc
		CheckBox Dendro_ModPanel_ShowPerpLabelsCheckbox,win=$labelstabname,title="Show Perpendicular Labels"
		CheckBox Dendro_ModPanel_ShowPerpLabelsCheckbox,win=$labelstabname,value=strlen(DDI.perpendicularLabelWave)
	endif
	
	SetActiveSubwindow ##
// End of Labels tab ***********

// Post-Process tab ***********
	tabname = StringFromList(3, PanelSubwindows)
	NewPanel/W=(12,33,286,466)/FG=(UGV1,UGH1,UGV0,UGH0)/HOST=$panelName
	RenameWindow #,$tabname
	String postprocesstabname = panelName + "#"+tabname
	SetWindow $postprocesstabname, userdata($gInfoUD)=DendroUserDataString
	ModifyPanel/W=$postprocesstabname cbRGB=(0,0,0,0), frameStyle=0

	TitleBox Dendro_ModPanel_PostProcessBaseNameTitle,win=$postprocesstabname,pos={11.00,12.00},size={167.00,16.00}
	TitleBox Dendro_ModPanel_PostProcessBaseNameTitle,win=$postprocesstabname,title="Base name for all output waves:"
	TitleBox Dendro_ModPanel_PostProcessBaseNameTitle,win=$postprocesstabname,frame=0
	
	String dwavename = NameOfWave(dwave)
	SetVariable Dendro_ModPanel_PostProcessBaseName,win=$postprocesstabname,pos={11.00,34.00},size={243.00,19.00},bodyWidth=243
	SetVariable Dendro_ModPanel_PostProcessBaseName,win=$postprocesstabname,value=_STR:dwavename
	
	CheckBox Dendro_ModPanel_PostProcess_AllowOverwrite,win=$postprocesstabname,pos={11.00,62.00},size={104.00,16.00}
	CheckBox Dendro_ModPanel_PostProcess_AllowOverwrite,win=$postprocesstabname,title="Overwrite Waves"
	CheckBox Dendro_ModPanel_PostProcess_AllowOverwrite,win=$postprocesstabname,value=0
	
	Button Dendro_ModPanel_ListClusters,win=$postprocesstabname,pos={49.00,129.00},size={170.00,20.00},proc=HClusterDendrogramProcs#Dendro_ModPanel_ListClustersButtonProc
	Button Dendro_ModPanel_ListClusters,win=$postprocesstabname,title="List Clusters"
	Button Dendro_ModPanel_ListClusters,win=$postprocesstabname,help={"Returns a wave containing lists of the data matrix rows contained within each cluster as defined by the cut line."}
	Button Dendro_ModPanel_ListClusters,win=$postprocesstabname,fSize=13
	
	Button Dendro_ModPanel_MakeClusterMatricesButton,win=$postprocesstabname,pos={49.00,180.00},size={170.00,20.00},proc=HClusterDendrogramProcs#Dendro_ModPanel_MakeClusterMatricesButtonProc
	Button Dendro_ModPanel_MakeClusterMatricesButton,win=$postprocesstabname,title="Make Cluster Matrices"
	Button Dendro_ModPanel_MakeClusterMatricesButton,win=$postprocesstabname,help={"Returns a wave containing lists of the data matrix rows contained within each cluster as defined by the cut line."}
	Button Dendro_ModPanel_MakeClusterMatricesButton,win=$postprocesstabname,fSize=13

	Button Dendro_ModPanel_ComputeClusterAveButton,win=$postprocesstabname,pos={49.00,231.00},size={170.00,20.00},proc=HClusterDendrogramProcs#Dendro_ModPanel_GraphClusterAverages
	Button Dendro_ModPanel_ComputeClusterAveButton,win=$postprocesstabname,title="Graph Cluster Averages"
	Button Dendro_ModPanel_ComputeClusterAveButton,win=$postprocesstabname,help={"Computes the average data vector for each cluster and makes a graph showing those average vectors."}
	Button Dendro_ModPanel_ComputeClusterAveButton,win=$postprocesstabname,fSize=13
	
// End of Post-Process tab ***********

	SetWindow $clustertabname, hide=0
	SetWindow $linestabname, hide=1
	SetWindow $labelstabname, hide=1
	SetWindow $postprocesstabname, hide=1
	
	SetWindow $panelName, userdata(DendroModPanelVersion)=num2str(DendroModPanelVersion)
	
	String cutlineinfo = "ISVERTICAL="+num2str(DDI.doVertical)+";"
	SetWindow $gname, userdata(MoveCutLineInfo) = cutlineinfo
	SetWindow $gname, hook($cutLineHookName) = HClusterDendrogramProcs#Dendro_ManageCutLineHook
	
	SetWindow $panelName, hook(DendroModPanelHook)=HClusterDendrogramProcs#DendroModPanelHook		// so far, just to check version number
end

static Function RestorePostProcessTabAfterVersionCheck(String gname)
	String panelname = gname + "#ModifyDendrogramPanel"
	String PPtabname = StringFromList(3, PanelSubwindows)
	String PPTabSubwin = panelname + "#" + PPtabname

	String PPbasename = GetUserData(gname, "", "RestorePPTabBaseName")
	SetVariable Dendro_ModPanel_PostProcessBaseName, win=$PPTabSubwin, value=_STR:PPbasename
	String PPoverwrite = GetUserData(gname, "", "RestorePPTabOverwrite")
	Checkbox Dendro_ModPanel_PostProcess_AllowOverwrite, win=$PPTabSubwin, value=str2num(PPoverwrite)
	String modpaneltab = GetUserData(gname, "", "RestoreModPanelTab")
	Variable tab = str2num(modpaneltab)
	TabControl Dendro_ModPanel_TabControl, win=$panelname, value=tab
	Dendro_ModPanel_SetTab(gname, tab)

	SetWindow $gname, userdata(RestorePPTabBaseName) = ""
	SetWindow $gname, userdata(RestorePPTabOverwrite) = ""
	SetWindow $gname, userdata(RestoreModPanelTab) = ""
end

// returns 1 if it found a panel and replaced it with a more modern version
static Function DendroModPanel_CheckVersion(String gname)
	String panelname = gname + "#ModifyDendrogramPanel"
	String recursionUD = GetUserData(gname, "", "ModPanelRecursionBlock")
	if (strlen(recursionUD) != 0 && str2num(recursionUD) != 0)
		return 0
	endif
	if (WinType(panelname) == 7)
		String versionstring = GetUserData(panelname, "", "DendroModPanelVersion")
		if (strlen(versionstring) == 0)
			Variable version = 0
		else
			version = str2num(versionstring)
		endif
		if (version < DendroModPanelVersion)
			String PPtabname = StringFromList(3, PanelSubwindows)
			String PPTabSubwin = panelname + "#" + PPtabname
			ControlInfo/W=$PPTabSubwin Dendro_ModPanel_PostProcessBaseName
			SetWindow $gname, userdata(RestorePPTabBaseName) = S_value
			ControlInfo/W=$PPTabSubwin Dendro_ModPanel_PostProcess_AllowOverwrite
			SetWindow $gname, userdata(RestorePPTabOverwrite) = num2str(V_value)
			ControlInfo/W=$panelname Dendro_ModPanel_TabControl
			SetWindow $gname, userdata(RestoreModPanelTab) = num2str(V_value)
			
			SetWindow $gname, userdata(ModPanelRecursionBlock) = "1"
 
			Variable dendrotype = Dendro_GetDendroTypeFromUserData(panelname)
			String cmd = "KillWindow "+panelname
			Execute/P/Q cmd
			cmd = "HClusterDendrogramProcs#fModifyDendrogramPanel(\""+gname+"\", "+num2str(dendroType)+")"
			Execute/P/Q cmd
			cmd = "HClusterDendrogramProcs#RestorePostProcessTabAfterVersionCheck(" + "\""+gname+"\")"
			Execute/P/Q cmd
			cmd = "SetWindow "+gname+", userdata(ModPanelRecursionBlock)=\"\""
			Execute/P/Q cmd
			return 1
		endif
	endif
	return 0
end

static Function DendroModPanelHook(Struct WMWinHookStruct & s)
	if (s.eventCode == 0)		// activate event
		String gname = Dendro_GetGraphNameFromUserData(s.winName)
		DendroModPanel_CheckVersion(gname)
	endif
end

static Function/S Dendro_PerpLabelsSideMenuString(String gname, Variable dendroType)
	STRUCT DendrogramDrawInfo DDI
	Dendro_FillStructureForGraph(gname, DDI, dendroType)
	
	String menustring = ""
	if (DDI.doVertical)
		menustring = "Left;Right;"
	else
		menustring = "Bottom;Top;"
	endif
	
	return menustring
end

static Function Dendro_ModPanel_HideAllSubwindows(String gname)
	Variable nwins = ItemsInList(PanelSubwindows)
	Variable i
	for (i = 0; i < nwins; i++)
		SetWindow $(gname+"#ModifyDendrogramPanel#"+StringFromList(i, PanelSubwindows)), hide=1
	endfor
end

static Function Dendro_ModPanel_ShowSubwindowForTab(String gname, Variable tab)
	String pname = StringFromList(tab, PanelSubwindows)
	SetWindow $(gname+"#ModifyDendrogramPanel#"+pname), hide=0
end

Static Function Dendro_ModPanel_SetTab(String gname, Variable tabnumber)
	Dendro_ModPanel_HideAllSubwindows(gname)
	Dendro_ModPanel_ShowSubwindowForTab(gname, tabnumber)
end

Static Function Dendro_ModPanel_TabControlProc(tca) : TabControl
	STRUCT WMTabControlAction &tca

	switch( tca.eventCode )
		case 2: // mouse up
			String gname = Dendro_GetGraphNameFromUserData(tca.win)
			Dendro_ModPanel_SetTab(gname, tca.tab)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

static Function/DF DendrogramDataFolder(String gname, Variable isVertical)
	DFREF dendroDFR
	if (DDendro_GraphHasDoubleDendrogram(gname))
		String DDDIuserdata = GetUserData(gname, "", DoubleDendroUD)
		if (strlen(DDDIuserdata) == 0)
			return dendroDFR
		endif
		String dfname = StringByKey("DATAFOLDER", DDDIuserdata, "=", ";")
		DFREF basedf = $dfname
		if (isVertical)
			DFREF dendroDFR = basedf:RowsDendroDF
		else
			DFREF dendroDFR = basedf:ColsDendroDF
		endif
	else
		String nodelinesInfo = GetUserData(gname, "", DendroInfoUD)
		String dendroDFname = StringByKey("DendroDF", nodelinesInfo, ":", "\r")
		DFREF dendroDFR = 	root:Packages:DendroGram:$dendroDFname
	endif

	return dendroDFR
end

static Function Dendro_FillStructureForGraph(String gname, STRUCT DendrogramDrawInfo & DDI, Variable dendrotype)
	if (dendrotype == DendroTypeSingle)
		DFREF dendroDFR = DendrogramDataFolder(gname, DDI.doVertical)
		if (DataFolderRefStatus(dendroDFR) == 0)		// it doesn't exist, bug!
			return -1
		endif
		structFill/SDFR=dendroDFR DDI
	else
		String DDDIuserdata = GetUserData(gname, "", DoubleDendroUD)
		if (strlen(DDDIuserdata) == 0)
			return -1		// return value is meaningless, but -1 seems like "error"
		endif
		String dfname = StringByKey("DATAFOLDER", DDDIuserdata, "=", ";")
		DFREF basedf = $dfname
		if (DataFolderRefStatus(basedf) == 0)
			return -1
		endif
		if (dendrotype == DendroTypeH)
			DFREF df = basedf:ColsDendroDF
		else
			DFREF df = basedf:RowsDendroDF
		endif
		StructFill/SDFR=df DDI
	endif
end

// sets the cutline to a new position
Function Dendro_SetCutValue(Variable cutvalue, String gname[, Variable doHorizontal])
	Variable isSingle = Dendro_GraphHasSingleDendrogram(gname)
	Variable dendroType
	if (isSingle)
		dendroType = DendroTypeSingle
	else
		if (ParamIsDefault(doHorizontal))
			dendroType = DendroTypeH
		else
			dendroType = doHorizontal ? DendroTypeH : DendroTypeV
		endif
	endif
	STRUCT DendrogramDrawInfo DDI
	Dendro_FillStructureForGraph(gname, DDI, dendroType)

	Wave dendroWave = $(DDI.dendrogramWaveName)
	MatrixOP/FREE distCol = Col(dendroWave, 2)
	Variable highcut, lowcut
	[lowcut, highcut] = WaveMinAndMax(distCol)
	
	DDI.cutvalue = min(max(lowcut, cutvalue), highcut)
	DDI.drawCutLine = 1
	
	Dendro_RedrawNodeLinesForStructure(gname, DDI)
	if (DDI.labelUseClusterColors)
		Dendro_RedrawLeafLabelsForStructure(gname, DDI)
	endif
	
	String pname = gname+"#ModifyDendrogramPanel#ClustersTab"
	if (WinType(pname) == 7)
		Variable panelDendroType = Dendro_GetDendroTypeFromUserData(pname)
		if (dendroType == panelDendroType)
			Checkbox Dendro_ModPanel_DrawCutLineCheckbox, win=$pname, value = 1
			Dendro_UpdateCutValueInPanel(gname, DDI.cutvalue)
		endif
	endif
end

// One function that causes the dendrogram lines to be redrawn with the characteristics given by the Clusters tab
static Function Dendro_ModifyClustersTab(String gname, String ctrlName)
	String pname = gname+"#ModifyDendrogramPanel#ClustersTab"
	
	Variable dendroType = Dendro_GetDendroTypeFromUserData(pname)
	STRUCT DendrogramDrawInfo DDI
	Dendro_FillStructureForGraph(gname, DDI, dendroType)
	
	Variable redraw = 1
	Variable redrawLabels = 0
	strswitch(ctrlName)
		case "Dendro_ModPanel_SetCutValue":
			ControlInfo/W=$pname Dendro_ModPanel_SetCutValue
			DDI.cutValue = V_Value
			if (DDI.labelUseClusterColors)
				redrawLabels = 1
			endif
			break
		case "Dendro_ModPanel_DrawCutLineCheckbox":
			ControlInfo/W=$pname Dendro_ModPanel_DrawCutLineCheckbox
			DDI.drawCutLine = V_value
			break
		case "Dendro_ModPanel_SetCutLineThickness":
			ControlInfo/W=$pname Dendro_ModPanel_SetCutLineThickness
			DDI.cutLineThick = V_value
			break
		case "Dendro_ModPanel_CutLineStyle":
			ControlInfo/W=$pname Dendro_ModPanel_CutLineStyle
			DDI.cutLineStyle = V_value-1
			break
		case "Dendro_ModPanel_CutLineColor":
			ControlInfo/W=$pname Dendro_ModPanel_CutLineColor
			DDI.cutLineColorR = V_Red
			DDI.cutLineColorG = V_Green
			DDI.cutLineColorB = V_Blue
			DDI.cutLineColorA = V_Alpha
			break
		case "Dendro_ModPanel_AddDistanceAxis":
			redraw = 0
			ControlInfo/W=$pname Dendro_ModPanel_AddDistanceAxis
			DDI.showDistanceAxis = V_value
			if (DDI.showDistanceAxis)
				Dendro_AddOrChangeDistanceAxis(gname, DDI);
			else
				Dendro_RemoveDistanceAxis(gname, dendroType);
			endif
			break
		case "Dendro_ModPanel_ColorClustersCheck":
			ControlInfo/W=$pname Dendro_ModPanel_ColorClustersCheck
			DDI.colorClusters = V_value
			if (DDI.colorClusters)
				DFREF dendroDFR = DendrogramDataFolder(gname, DDI.doVertical)
				if (!SVAR_Exists(DDI.clusterColorWavePath))
					String/G dendroDFR:clusterColorWavePath = ""
					SVAR DDI.clusterColorWavePath = dendroDFR:clusterColorWavePath
				endif
				Wave/Z colors = $(DDI.clusterColorWavePath)
				if (!WaveExists(colors))
					WAVE colors = Dendro_MakeDefaultClusterColorWave(dendroDFR)
					DDI.clusterColorWavePath = GetWavesDataFolder(colors, 2)
				endif
			endif
			if (DDI.labelUseClusterColors)
				redrawLabels = 1
			endif
			break
		case "Dendro_ModPanel_ApplyColorsToLabels":
			ControlInfo/W=$pname Dendro_ModPanel_ApplyColorsToLabels
			DDI.labelUseClusterColors = V_value
			redrawLabels = 1
			String labelstabName = gname+"#ModifyDendrogramPanel#"+StringFromList(2, PanelSubwindows)
			CheckBox Dendro_ModPanel_LabelsUseClusterColors,win=$labelstabname,value=DDI.labelUseClusterColors
			break
		case "Dendro_ModPanel_ClusterLineStylesCheck":
			ControlInfo/W=$pname Dendro_ModPanel_ClusterLineStylesCheck
			DDI.useClusterLineStyles = V_value
			if (DDI.useClusterLineStyles)
				DFREF dendroDFR = DendrogramDataFolder(gname, DDI.doVertical)
				if (!SVAR_Exists(DDI.clusterLineStyleWavePath))
					String/G clusterLineStyleWavePath = ""
					SVAR DDI.clusterLineStyleWavePath = df:clusterLineStyleWavePath
				endif
				Wave/Z styles = $DDI.clusterLineStyleWavePath
				if (!WaveExists(styles))
					Wave styles = Dendro_MakedefaultLineStyleWave(dendroDF)
					DDI.clusterLineStyleWavePath = GetWavesDataFolder(styles, 2)
				endif
			endif
			break
		case "Dendro_ModPanel_ClusterLineSizesCheck":
			ControlInfo/W=$pname Dendro_ModPanel_ClusterLineSizesCheck
			DDI.useClusterLineSizes = V_value
			break
		case "Dendro_ModPanel_LogDissimilarityCheckbox":
			ControlInfo/W=$pname Dendro_ModPanel_LogDissimilarityCheckbox
			DDI.logDissimilarity = V_value
			break
	endswitch
	if (redraw)
		Dendro_RedrawNodeLinesForStructure(gname, DDI)
	endif
	if (redrawLabels)
		Dendro_RedrawLeafLabelsForStructure(gname, DDI)
	endif
end

static Function Dendro_ModifyLinesTab(String gname, String ctrlname, Variable dendroType)
	STRUCT DendrogramDrawInfo DDI
	Dendro_FillStructureForGraph(gname, DDI, dendroType)
	
	String pname = gname+"#ModifyDendrogramPanel#linesTab"
	Variable redrawlabels = 0
	
	strswitch(ctrlname)
		case "DendroPanel_SetDendroSpace":
			ControlInfo/W=$pname DendroPanel_SetDendroSpace
			DDI.dendroMargin = V_value
			redrawlabels = 1
			Dendro_ChangeImageLayout(gname, DDI)
			break
		case "DendroPanel_LabelImageMargin":
			ControlInfo/W=$pname DendroPanel_LabelImageMargin
			DDI.labelImageBuffer = V_value
			Dendro_ChangeImageLayout(gname, DDI)
			redrawlabels = 1
			break
		case "DendroPanel_LineLabelSpace":
			ControlInfo/W=$pname DendroPanel_LineLabelSpace
			DDI.labelBuffer = V_value
			Dendro_ChangeImageLayout(gname, DDI)
			break
		case "DendroPanel_AlignLeafLines":
			ControlInfo/W=$pname DendroPanel_AlignLeafLines
			DDI.alignEnds = V_value
			break
		case "DendroPanel_DefaultLineColor":
			ControlInfo/W=$pname DendroPanel_DefaultLineColor
			DDI.lineColorR = V_Red
			DDI.lineColorG = V_Green
			DDI.lineColorB = V_Blue
			DDI.lineColorA = V_Alpha
			break
		case "DendroPanel_LineStyle":
			ControlInfo/W=$pname DendroPanel_LineStyle
			DDI.lineStyle = V_value-1
			break
		case "DendroPanel_DendroLineThickness":
			ControlInfo/W=$pname DendroPanel_DendroLineThickness
			DDI.lineThick = V_value
			break
	endswitch
	
	if (redrawLabels)
		Dendro_RedrawLeafLabelsForStructure(gname, DDI)
	endif
	Dendro_RedrawNodeLinesForStructure(gname, DDI)
end

static Function Dendro_ModifyLabelsTab(String gname, String ctrlname)
	String pname = gname+"#ModifyDendrogramPanel#"+StringFromList(2, PanelSubwindows)

	Variable dendroType = Dendro_GetDendroTypeFromUserData(pname)
	STRUCT DendrogramDrawInfo DDI
	Dendro_FillStructureForGraph(gname, DDI, dendroType)
	
	Variable redrawNodeLines = 1
	Variable redrawLeafLabels = 1
	strswitch(ctrlname)
		case "Dendro_ModPanel_LabelFont":
			ControlInfo/W=$pname Dendro_ModPanel_LabelFont
			DDI.labelFontName = S_value
			break
		case "Dendro_ModPanel_SetFontSize":
			ControlInfo/W=$pname Dendro_ModPanel_SetFontSize
			DDI.labelFontSize = V_value
			break
		case "Dendro_ModPanel_BoldCheck":
		case "Dendro_ModPanel_ItalicCheck":
		case "Dendro_ModPanel_UnderlineCheck":
		case "Dendro_ModPanel_StrikethroughCheck":
			Variable fstylebits = 0
			ControlInfo/W=$pname Dendro_ModPanel_BoldCheck
			if (V_value)
				fstylebits += 1
			endif
			ControlInfo/W=$pname Dendro_ModPanel_ItalicCheck
			if (V_value)
				fstylebits += 2
			endif
			ControlInfo/W=$pname Dendro_ModPanel_UnderlineCheck
			if (V_value)
				fstylebits += 4
			endif
			ControlInfo/W=$pname Dendro_ModPanel_StrikethroughCheck
			if (V_value)
				fstylebits += 16
			endif
			DDI.labelFontStyle = fstylebits
			break
		case "Dendro_ModPanel_LabelsUseClusterColors":
			ControlInfo/W=$pname Dendro_ModPanel_LabelsUseClusterColors
			DDI.labelUseClusterColors = V_value
			String clustertabname = gname+"#ModifyDendrogramPanel#"+StringFromList(0, PanelSubwindows)
			CheckBox Dendro_ModPanel_ApplyColorsToLabels,win=$clustertabname,value=DDI.labelUseClusterColors
			redrawNodeLines = 0
			break
		case "Dendro_ModPanel_LabelDefaultColor":
			ControlInfo/W=$pname Dendro_ModPanel_LabelDefaultColor
			DDI.labelColorR = V_Red
			DDI.labelColorG = V_Green
			DDI.labelColorB = V_Blue
			DDI.labelColorA = V_Alpha
			redrawNodeLines = 0
			break
		case "Dendro_ModPanel_ShowPerpLabelsCheckbox":
			ControlInfo/W=$pname Dendro_ModPanel_ShowPerpLabelsCheckbox
			if (V_value)
				// checked
				Dendro_ModPanel_TurnOnPerpendicular_Labels(pname, DDI)
			else
				// not checked
				Dendro_removePerpendicular_Labels(gname)
			endif
			break
	endswitch
	
	if (redrawLeafLabels)
		Dendro_RedrawLeafLabelsForStructure(gname, DDI)
	endif
	if (redrawNodeLines)
		Dendro_RedrawNodeLinesForStructure(gname, DDI)
	endif
end

Static Function Dendro_ModPanel_SetVariableProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			String gname = Dendro_GetGraphNameFromUserData(sva.win)
			String pname = gname+"#ModifyDendrogramPanel"
			ControlInfo/W=$pname Dendro_ModPanel_TabControl
			Variable tabnumber = V_value
			switch(tabnumber)
				case 0:
					Dendro_ModifyClustersTab(gname, sva.ctrlName)
					break
				case 1:
					Variable dendroType = Dendro_GetDendroTypeFromUserData(sva.win)
					Dendro_ModifyLinesTab(gname, sva.ctrlName, dendroType)
					break
				case 2:
					Dendro_ModifyLabelsTab(gname, sva.ctrlName)
					break
			endswitch
			break;
		case -1: // control being killed
			break
	endswitch

	return 0
End

Static Function Dendro_ModPanel_CheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			String gname = Dendro_GetGraphNameFromUserData(cba.win)
			String pname = gname+"#ModifyDendrogramPanel"
			ControlInfo/W=$pname Dendro_ModPanel_TabControl
			Variable tabnumber = V_value
			switch(tabnumber)
				case 0:
					Dendro_ModifyClustersTab(gname, cba.ctrlName)
					break
				case 1:
					Variable dendroType = Dendro_GetDendroTypeFromUserData(cba.win)
					Dendro_ModifyLinesTab(gname, cba.ctrlName, dendroType)
					break
				case 2:
					Dendro_ModifyLabelsTab(gname, cba.ctrlName)
					break
			endswitch
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Static Function Dendro_ModPanel_PopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			String gname = Dendro_GetGraphNameFromUserData(pa.win)
			String pname = gname+"#ModifyDendrogramPanel"
			ControlInfo/W=$pname Dendro_ModPanel_TabControl
			Variable tabnumber = V_value
			switch(tabnumber)
				case 0:
					Dendro_ModifyClustersTab(gname, pa.ctrlName)
					break
				case 1:
					Variable dendroType = Dendro_GetDendroTypeFromUserData(pa.win)
					Dendro_ModifyLinesTab(gname, pa.ctrlName, dendroType)
					break
				case 2:
					Dendro_ModifyLabelsTab(gname, pa.ctrlName)
					break
			endswitch
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Static Function Dendro_ModPanel_DoGroupColorsButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			String gname = Dendro_GetGraphNameFromUserData(ba.win)
			Variable dendroType = Dendro_GetDendroTypeFromUserData(ba.win)
			STRUCT DendrogramDrawInfo DDI
			Dendro_FillStructureForGraph(gname, DDI, dendroType)
			if (DDI.cutValue <= 0)
				DoAlert 0, "Cut distance is zero"
				return 0
			endif
			
			DFREF dendroDFR = DendrogramDataFolder(gname, DDI.doVertical)
			
			Wave dendroWave = $(DDI.dendrogramWaveName)
			Wave colorNumbers = Dendro_AnalyzeForClusters(dendroWave, DDI.cutvalue)
			Variable numcolors = wavemax(colorNumbers)	
			if (numcolors < 1)
				DoAlert 0, "No clusters found for cut value = " + num2str(DDI.cutValue)
				return 0
			endif
			Wave/Z colorwave = dendroDFR:ClusterColors
			if (!WaveExists(colorwave))
				Make/N=(numcolors, 3) dendroDFR:ClusterColors/WAVE=colorwave
			elseif (DimSize(colorwave, 1) < 4)
				InsertPoints/M=1/V=65535 3,1,colorwave
			endif
			
			String userdata = GetUserData(ba.win, "", gInfoUD)
			Note/K colorwave, userdata
			CWE_MakeClientColorEditor(colorwave, 0, 65535, "Cluster Colors", "Cluster Colors", "HClusterDendrogramProcs#Dendro_GroupColorEditorNotification", doAlpha=1)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

static Function Dendro_ModPanel_TurnOnPerpendicular_Labels(String pname, STRUCT DendrogramDrawInfo & DDI)
	String gname = Dendro_GetGraphNameFromUserData(pname)
	Variable dendroType = Dendro_GetDendroTypeFromUserData(pname)
	DDI.perpendicularLabelWave = PopupWS_GetSelectionFullPath(pname, "Dendro_ModPanelPerpendicularLabelsWave")
	Wave dwave = $DDI.dendrogramDataWave
	Wave/T/Z labelwave = $DDI.perpendicularLabelWave
	if (!WaveExists(labelwave))
		DoAlert 0, "Your label wave doesn't seem to exist"
		return 0
	endif
	if (numpnts(labelwave) != DimSize(dwave, 1))
		DoAlert 1, "The length of your label wave doesn't match the data wave in the heat map. Continue?"
		if (V_flag != 1)
			return 0
		endif
	endif
	ControlInfo/W=$(pname) Dendro_ModPanelPerpendicularLabelsSide
	DDI.perpendicularLabelSide = V_value == 1 ? 0 : 1			// first item is the "normal" side: bottom for horizontal, left for vertical. second item is right or top
	Dendro_AddPerpendicular_Labels(gname)
end

static Function Dendro_GroupColorEditorNotification(Wave w, Variable colorRange)
	String dendroInfo = note(w)
	String gname = StringByKey("GRAPHNAME", dendroInfo, "=", ";")
	Variable dendroType = NumberByKey("DENDROTYPE", dendroInfo, "=", ";")
	STRUCT DendrogramDrawInfo DDI
	Dendro_FillStructureForGraph(gname, DDI, dendroType)

	Dendro_RedrawNodeLinesForStructure(gname, DDI)
	if (DDI.labelUseClusterColors)
		Dendro_redrawLeafLabelsForStructure(gname, DDI)
	endif
end


Static Function Dendro_ModPanel_EditLineStylesButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	if (ba.eventCode == 2)
		String gname = Dendro_GetGraphNameFromUserData(ba.win)
		Variable dendroType = Dendro_GetDendroTypeFromUserData(ba.win)
		STRUCT DendrogramDrawInfo DDI
		Dendro_FillStructureForGraph(gname, DDI, dendroType)
		Wave dendroWave = $(DDI.dendrogramWaveName)
		Wave colorNumbers = Dendro_AnalyzeForClusters(dendroWave, DDI.cutvalue)
		Variable numClusters = WaveMax(colorNumbers)
		GetWindow $gname#ModifyDendrogramPanel,wsize
		Variable left = ba.winRect.left + ba.ctrlRect.left + V_left
		Variable top = ba.winRect.top + ba.ctrlRect.bottom + V_top + 20			// 20 to move it below the button
		Dendro_ModPanel_EditLineStylesPanel(gname, dendroType, left, top, numClusters)
	endif
	
	return 0
End

static Function Dendro_ModPanel_EditLineStylesPanel(String gname, Variable dendroType, Variable left, Variable top, Variable numClusters)

	DFREF dendroDFR = DendrogramDataFolder(gname, dendroType)
	Wave/Z lstyles = dendroDFR:ClusterStyles
	if (!WaveExists(lstyles))
		Make/N=17 dendroDFR:ClusterStyles/WAVE=lstyles
		lstyles = p+1
	endif
	
	Variable numstyles = numpnts(lstyles)
	
	String pname = "ModPanel_EditLStyles_"+gname
	if (WinType(pname) == 7)
		KillWindow $pname
	endif

	Variable width = 270
	Variable height = 415
	NewPanel/K=1 /W=(left,top,left+width,top+height)
	RenameWindow $S_name, $pname
	String DendroUserDataString = "GRAPHNAME="+gname+";"
	DendroUserDataString += "DENDROTYPE="+num2str(dendroType)+";"
	SetWindow $pname, userdata($gInfoUD)=DendroUserDataString
	SetWindow $pname, userdata(stylewave)=GetWavesDataFolder(lstyles, 2)
	SetWindow $pname, userdata(numstyles)=num2str(numstyles)

	TitleBox ModPanel_EditLStyles_Title,pos={27.00,11.00},size={109.00,11.00},title="Presently using "+num2str(numClusters)+" styles"
	TitleBox ModPanel_EditLStyles_Title,frame=0
	
	Variable ptop = 31, pright = 25+183
	Variable i
	for (i = 1; i <= numstyles; i++)
		String cname = "ModPanel_EditLStyles_Title"+num2str(i)
		TitleBox $cname,pos={20.00,ptop+4},size={7.00,11.00},title=(num2str(i)+":"),frame=0
		cname = "ModPanel_EditLStyles_DefCheck"+num2str(i)
		CheckBox $cname,pos={32.00,ptop+1},size={49.00,16.00},title="Default",value=(lstyles[i-1] < 0)
		cname = "ModPanel_EditLStyles_Menu"+num2str(i)
		PopupMenu $cname,win=$pname,pos={89,ptop},size={173,20.00},bodyWidth=173,title=""
		PopupMenu $cname,win=$pname,mode = lstyles[i-1]+1,value= #"\"*LINESTYLEPOP*\""
		ptop += 20
	endfor
	
	Button Dendro_ModPanelEditLStyle_OKButton,win=$pname,pos={20.00,383.00},size={75.00,20.00},proc=HClusterDendrogramProcs#Dendro_ModPanelEditLStyle_OKProc,title="OK"
	Button Dendro_ModPanelEditLStyle_CancelButton,win=$pname,pos={130.00,383.00},size={75.00,20.00},proc=HClusterDendrogramProcs#Dendro_ModPanelEditLStyle_OKProc,title="Cancel"
end

static Function Dendro_ModPanelEditLStyle_OKProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	if (ba.eventCode == 2)
		String gname = Dendro_GetGraphNameFromUserData(ba.win)
		Variable dendrotype = Dendro_GetDendroTypeFromUserData(ba.win)
		STRUCT DendrogramDrawInfo DDI
		Dendro_FillStructureForGraph(gname, DDI, dendroType)
		if (CmpStr(ba.ctrlName, "Dendro_ModPanelEditLStyle_OKButton") == 0)
			Variable numstyles = str2num(GetUserData(ba.win, "", "numstyles"))
			Wave lw = $GetUserData(ba.win, "", "stylewave")
			
			Variable i
			for (i = 1; i <= numstyles; i++)
				ControlInfo/W=$(ba.win) $("ModPanel_EditLStyles_DefCheck"+num2str(i))
				if (V_value)
					lw[i-1] = -1
				else
					ControlInfo/W=$(ba.win) $("ModPanel_EditLStyles_Menu"+num2str(i))
					lw[i-1] = V_Value-1
				endif
			endfor
			Dendro_redrawNodeLinesForStructure(gname, DDI)
		endif
		KillWindow $(ba.win)
	endif

	return 0
End

Static Function Dendro_ModPanel_EditLineSizeButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	if (ba.eventCode == 2)
		String gname = Dendro_GetGraphNameFromUserData(ba.win)
		Variable dendroType = Dendro_GetDendroTypeFromUserData(ba.win)
		STRUCT DendrogramDrawInfo DDI
		Dendro_FillStructureForGraph(gname, DDI, dendroType)
		Wave dendroWave = $(DDI.dendrogramWaveName)
		Wave colorNumbers = Dendro_AnalyzeForClusters(dendroWave, DDI.cutvalue)
		Variable numClusters = WaveMax(colorNumbers)
		GetWindow $gname#ModifyDendrogramPanel,wsize
		Variable left = ba.winRect.left + ba.ctrlRect.left + V_left
		Variable top = ba.winRect.top + ba.ctrlRect.bottom + V_top + 20			// 20 to move it below the button
		Dendro_ModPanel_EditLineSizesPanel(gname, dendroType, left, top, numClusters)
	endif
	
	return 0
End

Static Function Dendro_ModPanel_ClusterLabelsCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			String gname = Dendro_GetGraphNameFromUserData(cba.win)
			Variable dendroType = Dendro_GetDendroTypeFromUserData(cba.win)
			if (cba.checked)
				Dendro_AddClusterNumbers(gname, dendroType)
			else
				Dendro_RemoveClusterNumbers(gname, dendroType)
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

static StrConstant CLabelsGroupName = "ClusterLabels"

static Function Dendro_HasClusterNumbers(String gname, Variable doVertical)
	String groupname = CLabelsGroupName
	if (doVertical)
		groupname += "_V"
	else
		groupname += "_H"
	endif

	DrawAction/W=$(gname) GetGroup=$groupname
	return V_flag
end

static Function Dendro_DrawClusterNumber(String gname, STRUCT DendrogramDrawInfo & DDI, Variable clusternumber, Variable labelPos)
	//	print "At position",i,"got a new cluster:", currentCluster
	Variable r,g,b,a
	[r,g,b,a] = Dendro_GetAColorFromStructure(DDI, clusternumber)
	a = 25000
	if (DDI.doVertical)
		SetDrawEnv/W=$gname xcoord=bottom,ycoord=prel, fsize=72, textrgb=(r,g,b,a), textxjust=1, textyjust=1
		DrawText/W=$gname labelPos, DDI.dendroMargin/2, num2str(clusternumber)
	else
		SetDrawEnv/W=$gname xcoord=prel,ycoord=left, fsize=72, textrgb=(r,g,b,a), textyjust=1
		DrawText/W=$gname DDI.dendroMargin/2, labelPos, num2str(clusternumber)
	endif
end

static Function Dendro_AddClusterNumbers(String gname, Variable dendroType)
	STRUCT DendrogramDrawInfo DDI
	Dendro_FillStructureForGraph(gname, DDI, dendroType)

	String groupname = CLabelsGroupName
	if (DDI.doVertical)
		groupname += "_V"
	else
		groupname += "_H"
	endif

	DrawAction/W=$(gname) GetGroup=$groupname
	if (V_flag)
		DrawAction/W=$(gname) GetGroup=$groupname,delete
	endif

	Wave dendroWave = $(DDI.dendrogramWaveName)
	Wave colors = Dendro_AnalyzeForClusters(dendroWave, DDI.cutValue)
	Variable npnts = DimSize(dendroWave, 0)
	Variable i
	Variable previousNode = -(dendroWave[0][3]+1)
	Variable previousCluster = Dendro_GetClusterNumberForNodeNumber(previousNode, colors)
	Variable clusterStartPos = 0

	SetDrawEnv/W=$gname gstart, gname=$groupname

//	print "Starting with cluster",previousCluster,"at position 0"
	for (i = 1; i < npnts; i++)
		Variable node = -(dendroWave[i][3]+1)
		Variable currentCluster = Dendro_GetClusterNumberForNodeNumber(node, colors)
		if (currentCluster != previousCluster || i == npnts-1)
//			print "At position",i,"got a new cluster:", currentCluster
			Variable labelPos = (clusterStartPos + i - 1)/2
			Dendro_DrawClusterNumber(gname, DDI, previousCluster, labelPos)
			if (currentCluster != previousCluster && i == npnts-1)
				Dendro_DrawClusterNumber(gname, DDI, currentCluster, i)
			endif
			previousCluster = currentCluster
			clusterStartPos = i
		endif
	endfor

	SetDrawEnv/W=$gname gstop
end

static Function Dendro_RemoveClusterNumbers(String gname, Variable dendroType)
	STRUCT DendrogramDrawInfo DDI
	Dendro_FillStructureForGraph(gname, DDI, dendroType)

	String groupname = CLabelsGroupName
	if (DDI.doVertical)
		groupname += "_V"
	else
		groupname += "_H"
	endif

	DrawAction/W=$(gname) GetGroup=$groupname
	if (V_flag)
		DrawAction/W=$(gname) GetGroup=$groupname,delete
	endif
end

Static Function/S Dendro_ModPanelPostProcess_basename(String windowpath, String dataname)
	ControlInfo/W=$windowpath Dendro_ModPanel_PostProcessBaseName
	String basename = S_value
	if (strlen(basename) == 0)
		basename = dataname
	endif

	return basename
end

static Function Dendro_ModPanel_GraphClusterAverages(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	if (ba.eventCode == 2)
		String gname = Dendro_GetGraphNameFromUserData(ba.win)
		Variable dendroType = Dendro_GetDendroTypeFromUserData(ba.win)
		STRUCT DendrogramDrawInfo DDI
		Dendro_FillStructureForGraph(gname, DDI, dendroType)
		Wave datawave = $DDI.dendrogramDataWave
		Wave dendroWave = $DDI.dendrogramWaveName
		String basename = Dendro_ModPanelPostProcess_basename(ba.win, NameOfWave(datawave))
		ControlInfo/W=$ba.win Dendro_ModPanel_PostProcess_AllowOverwrite
		Variable overwriteOK = V_value

		Dendro_ClusterAverages(DDI, gname, dendroType, basename, 1, overwriteOK)		// 1 = doGraph
	endif
	
	return 0
end

static Function [Wave nodelist, Wave colorcounts] Dendro_ClusterNodeList(Wave colornumbers, Wave dendroWave, Wave datamatrix, Variable dendroType)
	Variable ncolors = wavemax(colornumbers)
	Variable nvectors
	
	if (dendrotype == DendroTypeSingle || dendrotype == DendroTypeV)
		nvectors = DimSize(DataMatrix, 0)
	else
		nvectors = DimSize(DataMatrix, 1)
	endif
	Make/N=(nvectors, ncolors)/FREE nodelist
	Make/N=(ncolors)/FREE colorcounts = 0
	Variable i
	for (i = 0; i < nvectors; i++)
		Variable colorcol = colornumbers[i][1]-1
		nodelist[colorcounts[colorcol]][colorcol] = i+1
		colorcounts[colorcol] += 1
	endfor

	return [nodelist, colorcounts]
end

// Returns a WAVE wave with references to free wave matrices, one matrix for each cluster.
static Function/WAVE Dendro_CreateClusterMatrices(STRUCT DendrogramDrawInfo & DDI, String gname, Variable dendroType)

	Wave dendroWave = $DDI.dendrogramWaveName
	Wave datawave = $DDI.dendrogramDataWave

	Variable dataVectorDim = (dendrotype == DendroTypeSingle || dendrotype == DendroTypeV) ? 0 : 1
	
	Wave clusternumbers = Dendro_AnalyzeForClusters(dendroWave, DDI.cutValue)
	[Wave nodelist, Wave colorcounts] = Dendro_ClusterNodeList(clusternumbers, dendroWave, datawave, dendrotype)
	Variable nclusters = wavemax(clusternumbers)
	Variable npnts = DimSize(datawave, dataVectorDim)
	Variable i
	
	Make/WAVE/FREE/N=(nclusters) matrixrefs
	for (i = 0; i < nclusters; i++)
		Make/D/FREE/N=(colorcounts[i], DimSize(datawave, 1-dataVectorDim))/O matwave
		matrixrefs[i] = matwave
	endfor
	
	Make/FREE/N=(nclusters) matrixrows=0
	for (i = 0; i < npnts; i++)
		Variable node = -(dendroWave[i][3]+1)
		Variable cnumber = Dendro_GetClusterNumberForNodeNumber(node, clusternumbers)
		Wave mat = matrixrefs[cnumber-1]
		if (dataVectorDim == 0)
			mat[matrixrows[cnumber-1]][] = datawave[dendroWave[i][3]][q]
		else
			mat[matrixrows[cnumber-1]][] = datawave[q][dendroWave[i][3]]
		endif
		// Just in case we save the matrix at the end
		String oneLabel = Dendro_GetIndexedLeafLabel(dendroWave[i][3], gname, DDI)
		if (strlen(oneLabel) == 0)
			oneLabel = "Data "
			oneLabel += SelectString(dataVectorDim, "Row ", "Col ")
			oneLabel += num2str(dendroWave[i][3])
		endif
		oneLabel = CleanupName(oneLabel, 1)			// 1 = beLiberal
		SetDimLabel 0, matrixrows[cnumber-1], $oneLabel, matrixrefs[cnumber-1]
		matrixrows[cnumber-1] += 1
	endfor
	
	return matrixrefs
end

static Function Dendro_ClusterAverages(STRUCT DendrogramDrawInfo & DDI, String gname, Variable dendroType, String basename, Variable doGraph, Variable overwriteOK)
	Wave dendroWave = $DDI.dendrogramWaveName
	
	WAVE/Wave matrixRefs = Dendro_CreateClusterMatrices(DDI, gname, dendroType)
	Variable nclusters = numpnts(matrixRefs)
	String avename
	Variable i
	
	if (DoGraph)
		if (!overwriteOK)	
			for (i = 0; i < nclusters; i++)
				avename = basename + "_CAve_"+num2istr(i+1)
				Wave/Z w = $avename
				if (WaveExists(w))
					DoAlert 0, "Output waves already exist. Perhaps turn on the Overwrite checkbox."
					return -1
				endif
			endfor
		endif
		Display
		String newgname = S_name
	endif
	for (i = 0; i < nclusters; i++)
		avename = basename + "_CAve_"+num2istr(i+1)
		Wave mat = matrixRefs[i]
		MatrixOP/FREE avewave = averageCols(mat)
		Variable npnts = numpnts(avewave)
		Redimension/N=(npnts) avewave
		Duplicate/O avewave, $avename
		if (doGraph)
			Variable r,g,b,a
			[r,g,b,a] = Dendro_GetAColorFromStructure(DDI, i+1)
			AppendToGraph/W=$newgname $avename
			ModifyGraph/W=$newgname rgb($avename)=(r,g,b,a)
		endif
	endfor
	if (doGraph)
		Legend/W=$newgname
	endif
end

static Function [WAVE NodeList, WAVE/T LabelledList] Dendro_ClusterListWaves(STRUCT DendrogramDrawInfo & DDI, String gname, Variable dendroType)

	Wave dendroWave = $DDI.dendrogramWaveName
	Wave datawave = $DDI.dendrogramDataWave

	Variable i

	Variable dataVectorDim = (dendrotype == DendroTypeSingle || dendrotype == DendroTypeV) ? 0 : 1
	
	Wave clusternumbers = Dendro_AnalyzeForClusters(dendroWave, DDI.cutValue)
	Variable nclusters = wavemax(clusternumbers)
	[Wave nodelist, Wave colorcounts] = Dendro_ClusterNodeList(clusternumbers, dendroWave, datawave, dendrotype)
	Variable maxClusterNodeCount = WaveMax(colorcounts)
	
	Make/FREE/N=(maxClusterNodeCount, nclusters) ClusterNodes = NaN
	Make/FREE/T/N=(maxClusterNodeCount, nclusters) ClusterLabels = ""
		
	Make/FREE/N=(nclusters) matrixrows=0
	for (i = 0; i < DimSize(dendroWave, 0); i++)
		Variable node = -(dendroWave[i][3]+1)
		Variable cnumber = Dendro_GetClusterNumberForNodeNumber(node, clusternumbers)
		ClusterNodes[matrixrows[cnumber-1]][cnumber-1] = dendroWave[i][3]

		String oneLabel = Dendro_GetIndexedLeafLabel(dendroWave[i][3], gname, DDI)
		if (strlen(oneLabel) == 0)
			oneLabel = "Data "
			oneLabel += SelectString(dataVectorDim, "Row ", "Col ")
			oneLabel += num2str(dendroWave[i][3])
		endif
		ClusterLabels[matrixrows[cnumber-1]][cnumber-1] = onelabel

		matrixrows[cnumber-1] += 1
	endfor
	
	return [ClusterNodes, ClusterLabels]
end

static Function Dendro_ModPanel_ListClustersButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	if (ba.eventCode == 2)
		String gname = Dendro_GetGraphNameFromUserData(ba.win)
		Variable dendroType = Dendro_GetDendroTypeFromUserData(ba.win)
		STRUCT DendrogramDrawInfo DDI
		Dendro_FillStructureForGraph(gname, DDI, dendroType)
		[WAVE ClusterNodes, WAVE/T ClusterLabels] = Dendro_ClusterListWaves(DDI, gname, dendroType)
		Wave dataw = $DDI.dendrogramDataWave
		String basename = Dendro_ModPanelPostProcess_basename(ba.win, NameOfWave(dataw))

		DFREF datadf = GetWavesDataFolderDFR(dataw)
		String nodesname = basename+"_ClusterNodes"
		String labelsname = basename+"_ClusterLabels"
		ControlInfo/W=$ba.win Dendro_ModPanel_PostProcess_AllowOverwrite
		Variable overwriteOK = V_value
		WAVE/Z w = datadf:$nodesname
		WAVE/Z/T wt = datadf:$labelsname
		if ( (WaveExists(w) || WaveExists(wt)) && !overwriteOK )
			DoAlert 0, "Output waves already exist. Perhaps turn on the Overwrite checkbox."
			return -1
		endif
		Duplicate/O ClusterNodes, datadf:$nodesname
		Duplicate/O ClusterLabels, datadf:$labelsname
	endif
	
	return 0
End

static Function Dendro_ModPanel_MakeClusterMatricesButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	if ( ba.eventCode == 2 )
		String gname = Dendro_GetGraphNameFromUserData(ba.win)
		Variable dendroType = Dendro_GetDendroTypeFromUserData(ba.win)
		STRUCT DendrogramDrawInfo DDI
		Dendro_FillStructureForGraph(gname, DDI, dendroType)
		Wave dataw = $DDI.dendrogramDataWave
		String basename = Dendro_ModPanelPostProcess_basename(ba.win, NameOfWave(dataw))
		String newmatname

		WAVE/Wave matrixRefs = Dendro_CreateClusterMatrices(DDI, gname, dendroType)
		Variable i
		Variable nclusters = numpnts(matrixRefs)
		
		ControlInfo/W=$ba.win Dendro_ModPanel_PostProcess_AllowOverwrite
		Variable overwriteOK = V_value
		if (!overwriteOK)
			for (i = 0; i < nclusters; i++)
				newmatname = "M_" + basename + "_Cluster_" + num2istr(i+1)
				Wave/Z w = $newmatname
				if (WaveExists(w))
					DoAlert 0, "Output waves already exist. Perhaps turn on the Overwrite checkbox."
					return -1
				endif
			endfor
		endif
		
		for (i = 0; i < nclusters; i++)
			newmatname = "M_" + basename + "_Cluster_" + num2istr(i+1)
			Wave mat = matrixrefs[i]
			Duplicate/O mat, $newmatname
		endfor
	endif

	return 0
End

static Function/WAVE Dendro_GetOrPossiblyMakeLineSizeWave(String gname, Variable numClusters, Variable dendroType)
	STRUCT DendrogramDrawInfo DDI
	Dendro_FillStructureForGraph(gname, DDI, dendroType)
	// Check if the SVAR pointing to the wave exists
	if (SVAR_Exists(DDI.clusterLineSizeWavePath))
		// yes, try to get a wave reference
		Wave/Z lsizes = $DDI.clusterLineSizeWavePath
	else
		// no, make the global string variable and set the SVAR
		DFREF dendroDFR = DendrogramDataFolder(gname, DDI.doVertical)
		String/G dendroDFR:clusterLineSizeWavePath=""
		SVAR DDI.clusterLineSizeWavePath = dendroDF:clusterLineSizeWavePath
		// See if a wave already exists and set the path if it does
		Wave lsizes = dendroDFR:ClusterLineSizes
		if (WaveExists(lsizes))
			DDI.clusterLineSizeWavePath = GetWavesDataFolder(lsizes, 2)
		endif
	endif
	// We can get here with a null lsizes wave reference if the SVAR was set but the path doesn't point to a wave
	// That can be because the wave doesn't actually exist, or because the path doesn't point to a wave
	if (!WaveExists(lsizes))
		DFREF dendroDFR = DendrogramDataFolder(gname, DDI.doVertical)
		Wave/Z lsizes = dendroDFR:ClusterLineSizes			// try to get a reference to the expected wave
		if (!WaveExists(lsizes))
			// it doesn't exist; make a default version
			Make/N=(numClusters > 0 ? numClusters : 1) dendroDFR:ClusterLineSizes/WAVE=lsizes
			lsizes = 1
		endif
		// set the path to the new or discovered wave
		DDI.clusterLineSizeWavePath = GetWavesDataFolder(lsizes, 2)
	endif
	if (WaveExists(lsizes))
		// Now the wave exists, check it for correct size and possibly expand it
		Variable npnts = numpnts(lsizes)
		numClusters = max(npnts, numClusters)
		if (numClusters > npnts)
			Redimension/N=(numClusters) lsizes
			lsizes[npnts,] = 1
		endif
	endif
	
	return lsizes
end

static Function Dendro_ModPanel_EditLineSizesPanel(String gname, Variable dendroType, Variable left, Variable top, Variable numClusters)
	STRUCT DendrogramDrawInfo DDI
	Dendro_FillStructureForGraph(gname, DDI, dendroType)
	Wave lsizes = Dendro_GetOrPossiblyMakeLineSizeWave(gname, numClusters, dendroType)
	DFREF dendroDFR = DendrogramDataFolder(gname, DDI.doVertical)
	
	String pname = "ModPanel_EditLSizes_"+gname
	if (WinType(pname) == 7)
		KillWindow $pname
	endif

	Variable width = 217
	Variable height = 283
	NewPanel/K=1 /W=(left,top,left+width,top+height)
//	print "(",left,",",top,",",left+width,",",top+height,")"
	RenameWindow $S_name, $pname
	String DendroUserDataString = "GRAPHNAME="+gname+";"
	DendroUserDataString += "DENDROTYPE="+num2str(dendroType)+";"
	SetWindow $pname, userdata($gInfoUD)=DendroUserDataString

	Variable numsizes = numpnts(lsizes)
	Make/T/N=(numsizes)/O dendroDFR:lsizelistwave/WAVE=listw
	listw = num2str(lsizes[p])
	Make/N=(numsizes)/O dendroDFR:lsizeselwave/WAVE=selw
	selw = 2		// all editable

	TitleBox Dendro_EditLineSizes_DefaultTitle,pos={42.00,11.00},size={121.00,11.00}
	TitleBox Dendro_EditLineSizes_DefaultTitle,title="Enter -1 for default line size",frame=0

	ListBox Dendro_EditLineSizes_List,win=$pname,pos={37.00,34.00},size={151.00,131.00}
	ListBox Dendro_EditLineSizes_List,win=$pname,editStyle= 1,listwave = listw,selwave=selw
	ListBox Dendro_EditLineSizes_List,win=$pname,userdata(listwave)=GetWavesDataFolder(listw, 2)
	ListBox Dendro_EditLineSizes_List,win=$pname,userdata(selwave)=GetWavesDataFolder(selw, 2)
	 
	Button Dendro_ModPanelEditLSize_OKButton,win=$pname,pos={20.00,242.00},size={75.00,20.00},proc=HClusterDendrogramProcs#Dendro_ModPanelEditLSize_OKProc,title="OK"
	Button Dendro_ModPanelEditLStyle_CancelButton,win=$pname,pos={130.00,242.00},size={75.00,20.00},proc=HClusterDendrogramProcs#Dendro_ModPanelEditLSize_OKProc,title="Cancel"
end

static Function Dendro_ModPanelEditLSize_OKProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	if (ba.eventCode == 2)
		String gname = Dendro_GetGraphNameFromUserData(ba.win)
		Wave/T lwave = $GetUserData(ba.win, "Dendro_EditLineSizes_List", "listwave")
		Wave selwave = $GetUserData(ba.win, "Dendro_EditLineSizes_List", "selwave")
		if (CmpStr(ba.ctrlName, "Dendro_ModPanelEditLSize_OKButton") == 0)
			Variable nclusters = numpnts(lwave)
			Variable dendroType = Dendro_GetDendroTypeFromUserData(ba.win)
			STRUCT DendrogramDrawInfo DDI
			Dendro_FillStructureForGraph(gname, DDI, dendroType)
			Wave lsizes = Dendro_GetOrPossiblyMakeLineSizeWave(gname, nclusters, dendroType)
			lsizes = str2num(lwave[p])
			Dendro_redrawNodeLinesForStructure(gname, DDI)
		endif
		KillWindow $(ba.win)
		KillWaves lwave, selwave
	endif

	return 0
End

Static Function Dendro_ModPanel_PrefsMenuProc(s) : PopupMenuControl
	STRUCT WMPopupAction &s

	if (s.eventCode == 2)
		String gname = Dendro_GetGraphNameFromUserData(s.win)
		Variable dendroType = Dendro_GetDendroTypeFromUserData(s.win)
		STRUCT DendrogramDrawInfo DDI
		Dendro_FillStructureForGraph(gname, DDI, dendroType)
		
		if (strlen(gname) != 0)								// I think that can't actually happen, since we're running a panel action proc
			StrSwitch(s.popStr)
				Case "Save as Preference":
					Dendro_StoreStructureAsPrefs(DDI)
					break
				Case "Apply Preferences":
					Dendro_LoadSettingsFromPrefsIntoStruct(gname, DDI)
					Dendro_RedrawNodeLinesForStructure(gname, DDI)
					Dendro_RedrawLeafLabelsForStructure(gname, DDI)
					KillWindow $(gname+"#ModifyDendrogramPanel")
					fCreateModifyDendrogramPanel(gname, dendroType)
					break
				Case "Revert Preferences to Default":
					Dendro_SetPreferencesToDefault()
					break
			endswitch
		endif
	endif

	return 0
End

//***********************************************************************************
// Code that actually creates the heat map with dendrogram
//***********************************************************************************

// side input: 0 for the "normal" side; for a vertical dendrogram, left and for a horizontal it is bottom.
// side input of 1 means right or top. Since the heat map image is on left and bottom axes, and the labels are
// implemented as user tick waves, it is easiest to implement right or top using a truly free axis associated with
// left or bottom
static Function Dendro_AddPerpendicular_Labels(String gname)
	STRUCT DendrogramDrawInfo DDI
	Dendro_FillStructureForGraph(gname, DDI, DendroTypeSingle)
	DFREF dendroDFR = DendrogramDataFolder(gname, DDI.doVertical)
	Wave dwave = $DDI.dendrogramDataWave

	Variable npnts = DimSize(dwave, 1)
	
	Wave/T/Z labelwave = $DDI.perpendicularLabelWave
	Make/D/N=(npnts)/O dendroDFR:perpendicularLabelVals/WAVE=lvals
	Variable side = DDI.perpendicularLabelSide
	lvals = p
	string axisname = ""
	if (WaveExists(labelwave))
		if (DDI.doVertical)
			if (side)
				axisname = "PerpDendroLabels"
				NewFreeAxis/W=$gname/R/O PerpDendroLabels
				ModifyFreeAxis/W=$gname PerpDendroLabels, master=left
				CopyAxisSettingsForGraph(gname, "left", "PerpDendroLabels")
				ModifyGraph/W=$gname freePos(PerpDendroLabels)={0,kwFraction}
			else
				if (strlen(AxisInfo(gname, "PerpDendroLabels")) > 0)
					KillFreeAxis/W=$gname PerpDendroLabels
				endif
				axisname = "left"
			endif
			ModifyGraph/W=$gname axThick($axisname)=1,userticks($axisname)={lvals,labelwave}
			ModifyGraph/W=$gname noLabel($axisname)=0
		else
			if (side)
				axisname = "PerpDendroLabels"
				NewFreeAxis/W=$gname/T/O PerpDendroLabels
				ModifyFreeAxis/W=$gname PerpDendroLabels, master=bottom
				CopyAxisSettingsForGraph(gname, "bottom", "PerpDendroLabels")
				ModifyGraph/W=$gname freePos(PerpDendroLabels)={0,kwFraction}
			else
				if (strlen(AxisInfo(gname, "PerpDendroLabels")) > 0)
					KillFreeAxis/W=$gname PerpDendroLabels
				endif
				axisname = "bottom"
			endif
			ModifyGraph/W=$gname axThick($axisname)=1,userticks($axisname)={lvals,labelwave}
			ModifyGraph/W=$gname noLabel($axisname)=0
			ModifyGraph/W=$gname tkLblRot($axisname)=45
		endif
	endif
end

static Function Dendro_RemovePerpendicular_Labels(String gname)
	STRUCT DendrogramDrawInfo DDI
	Dendro_FillStructureForGraph(gname, DDI, DendroTypeSingle)

	if (strlen(AxisInfo(gname, "PerpDendroLabels")) > 0)
		KillFreeAxis/W=$gname PerpDendroLabels
	else
		if (DDI.doVertical)
			ModifyGraph/W=$gname noLabel(left)=2,axThick(left)=0
		else
			ModifyGraph/W=$gname noLabel(bottom)=2,axThick(bottom)=0
		endif
	endif
end

// Function to make fake test data
Function Dendro_MakeClusteredData(String name, Variable rows, Variable nclusters)

	Make/N=(rows, 2)/O $name/WAVE=w
	
	w[][0] = gnoise(1) + 10*sin(mod(p,nclusters))
	w[][1] = gnoise(1) + 10*cos(mod(p,nclusters))
end

static Function Dendro_PRelForPixels(String gname, Variable npixels, Variable inHorizontalDirection)
	Variable pixelsToPrel
	GetWindow $gname, psize
	if (inHorizontalDirection)
		Variable pwidth = V_right - V_left
		pixelsToPrel = 1/pwidth
	else
		Variable pheight = V_bottom - V_top
		pixelsToPrel = 1/pheight
	endif
	
	return npixels*pixelsToPrel
end

// UserData($cutlinerectUD) is a list of keyword-value pairs with up to two keywords, one for a vertical cut line and one
// for a horizontal cut line. The keywords are either "RECT_V" or "RECT_H" with keyword-value separators "=" and list
// separator ";". Each value is itself a comma-separated list of 4 coordinates for the hit rectangle for the associated cut line
// and a fifth value that is the current cut value.
static Function Dendro_PossiblyDrawCutLine(String gname, WAVE dendroWave, Variable maxLabelLenth, STRUCT DendrogramDrawInfo & DDI)
	Variable dendrotype = Dendro_typeFromStructure(gname, DDI)
	String suffix = Dendro_TypeSuffix(dendrotype)
	String userdataKey = "RECT"+suffix
	String drawgroupname = cutLineGroup+suffix
	
	SetDrawLayer/W=$(gname) UserFront
	
	DrawAction/W=$(gname) GetGroup=$drawgroupname
	if (V_flag)
		DrawAction/W=$(gname) GetGroup=$drawgroupname,delete
	endif

	if (DDI.drawCutLine)
		SetDrawEnv/W=$gname gstart, gname=$drawgroupname
		
		Duplicate/RMD=[][2,2]/FREE dendroWave, heights
		if (DDI.logDissimilarity)
			heights=log(heights)
		endif
		Variable hMin = WaveMin(heights)
		Variable hMax = WaveMax(heights)
		Variable x0 = DDI.dendroMargin - maxLabelLenth
		Variable hPosFactor = x0/(hMax - hMin)			// assumes that left-most position is at x=0

		Variable rr = DDI.cutLineColorR
		Variable gg = DDI.cutLineColorG
		Variable bb = DDI.cutLineColorB
		Variable aa = DDI.cutLineColorA
		Variable tt = DDI.cutLineThick
		Variable style = DDI.cutLineStyle
		Variable cutLinePos = x0 - hposFactor*(DDI.cutValue - hMin)
		String cutlineUserData
		SetDrawEnv/W=$gname xcoord=prel,ycoord=prel, linefgc=(rr,gg,bb,aa), linethick=tt, dash=style
		Variable rectMargin = Dendro_PRelForPixels(gname, 2, DDI.doVertical)
		if (DDI.doVertical)
			sprintf cutlineUserData, "%g,%g,%g,%g,%g,", 0, cutLinePos-rectMargin, 1, cutLinePos+rectMargin, DDI.cutValue
			DrawLine/W=$gname 0, cutLinePos, 1, cutLinePos
		else
			sprintf cutlineUserData, "%g,%g,%g,%g,%g,", cutLinePos-rectMargin, 0, cutLinePos+rectMargin, 1, DDI.cutValue
			DrawLine/W=$gname cutLinePos, 0, cutLinePos, 1
		endif
		SetDrawEnv/W=$gname gstop

		String userdata = GetUserData(gname, "", cutlinerectUD)
		userdata = RemoveByKey(userdataKey, userdata, "=", ";")
		userdata += userdataKey + "=" + cutlineUserData + ";"
		SetWindow $gname, UserData($cutlinerectUD)=userdata
	else
		userdata = GetUserData(gname, "", cutlinerectUD)
		userdata = RemoveByKey(userdataKey, userdata, "=", ";")
		SetWindow $gname, UserData($cutlinerectUD)=userData
	endif
end

// n1 and n2 are the two nodes that are connected to make the current node. If they are negative,
// they refer to original data points from datawave. The point number is abs(n1)-1.
// If they are positive, they refer to rows in the dendrogram wave and the nodePosWave, and
// the point number is n1-1.
// vposwave is the vertical position of each of the original data points.
// nodePosWave is a wave of x,y positions of the dendrogram nodes.
// curpoint is the row number within nodePosWave that we are filling in this time.
static Function Dendro_DrawNodeLines(String gname, WAVE dendroWave, WAVE labelLengths, Wave colorNumbers, STRUCT DendrogramDrawInfo & DDI)
	Duplicate/RMD=[][2,2]/FREE dendroWave, heights
	if (DDI.logDissimilarity)
		heights = log(heights)
		heights[DimSize(dendroWave, 0)-1] = 0
	endif
	Duplicate/RMD=[][3,3]/FREE dendroWave, order
	order -= 1
	Duplicate/FREE heights, vposwave
	MakeIndex order, vposwave
	
	Variable hMin = WaveMin(heights)
	Variable hMax = WaveMax(heights)
	
	Variable nlines = DimSize(dendroWave, 0)-1
	Make/N=(nlines, 2)/FREE nodePosWave		// x,y position of a node in dendroWave
	
	SetDrawLayer/W=$(gname) UserFront
	
	String nodeLinesGroupName = nodeLinesGroup + SelectString(DDI.doVertical, "_V", "_H")
	SetDrawEnv/W=$gname gstart, gname=$nodeLinesGroupName
	
	Variable x0 = DDI.dendroMargin - WaveMax(labelLengths)
	Variable hPosFactor = x0/(hMax - hMin)			// assumes that left-most position is at x=0
	
	// Check the axis limits and don't draw outside the bounds of the axis. The user
	// may have zoomed in on the graph.
	Variable axisMax, axisMin
	if (DDI.doVertical)
		GetAxis/W=$gname/Q bottom
	else
		GetAxis/W=$gname/Q left
	endif
	axisMax = V_max
	axisMin = V_min

	Variable curRow
	for (curRow = 0; curRow < nlines; curRow++)
		Variable n1 = dendroWave[curRow][0]			// first node number, 1-based, possibly negative
		Variable n2 = dendroWave[curRow][1]			// second node number, 1-based, possibly negative
		Variable pnt1 = abs(n1)-1						// actual row number in a wave somewhere
		Variable pnt2 = abs(n2)-1						// actual row number in a wave somewhere
		// Info for two lines connecting previous iteration with current nodes, if those nodes are original data.
		// x1 and x2 represent the start of the line in the distance or dissimilarity direction. That would be horizontal for DDI.doVertical=0
		// or vertical for DDI.doVertical=1
		Variable x1 = n1 < 0 ? (DDI.alignEnds ? x0 : DDI.dendroMargin - labelLengths[pnt1]) : 0;
		Variable x2 = n2 < 0 ? (DDI.alignEnds ? x0 : DDI.dendroMargin - labelLengths[pnt2]) : 0;
		// vpos1 and vpos2 represent the position of the two lines perpendicular to the distance or dissimilarity axis. That is, this is
		// the positioning of each of the labels or node lines. If DDI.doVertical=0, it is vertical or if DDI.doVertical is 1 it is horizontal
		Variable vpos1 = n1 < 0 ? vposwave[pnt1] : nodePosWave[pnt1][1]
		Variable vpos2 = n2 < 0 ? vposwave[pnt2] : nodePosWave[pnt2][1]
		// xpos1 and xpos2 are the actual starting location of the two lines, whether the previous location was a node or the leaf end of a branch.
		Variable xpos1 = n1 < 0 ? x1 : nodePosWave[pnt1][0]
		Variable xpos2 = n2 < 0 ? x2 : nodePosWave[pnt2][0]
		
		// curXPos is the position in the distance or dissimilarity direction of the end of the two lines and also of the cross-bar
		// connecting the two nodes represented by the current row in the dendrogram info wave
		Variable curXpos = x0 - hposFactor*(heights[curRow] - hMin)
		
		// nodePosWave stores the position of a node so that it can be accessed in a future iteration. This is the position on the graph
		// of a node having a positive row number in the dendrogram info wave.
		nodePosWave[curRow][1] = (vpos1 + vpos2)/2
		nodePosWave[curRow][0] = curXPos
		
		Variable cn1 = Dendro_GetClusterNumberForNodeNumber(n1, colorNumbers)
		Variable cn2 = Dendro_GetClusterNumberForNodeNumber(n2, colorNumbers)
		
		Variable rr, gg, bb, aa
		Variable lstyle = 0
		Variable lsize = DDI.lineThick
		// Draw the two lines from the previous node to the present distance position. Vertical if DDI.doVertical=1.
		if (DDI.doVertical)
			if (vpos1 > axisMin && vpos1 < axisMax)
				[rr, gg, bb, aa] = Dendro_GetAColorFromStructure(DDI, cn1)
				lstyle = Dendro_GetLineStyleFromStructure(DDI, cn1)
				lsize = Dendro_GetLineSizeFromStructure(DDI, cn1)
				SetDrawEnv/W=$gname xcoord=bottom,ycoord=prel, linefgc=(rr,gg,bb,aa), lineThick=lsize, dash=lstyle, linecap=1
				DrawLine/W=$gname vpos1, xpos1, vpos1, curXpos
			endif

			if (vpos2 > axisMin && vpos2 < axisMax)
				[rr, gg, bb, aa] = Dendro_GetAColorFromStructure(DDI, cn2)
				lstyle = Dendro_GetLineStyleFromStructure(DDI, cn2)
				lsize = Dendro_GetLineSizeFromStructure(DDI, cn2)
				SetDrawEnv/W=$gname xcoord=bottom,ycoord=prel, linefgc=(rr,gg,bb,aa), lineThick=lsize, dash=lstyle, linecap=1
				DrawLine/W=$gname vpos2, xpos2, vpos2, curXpos
			endif
		else
			if (vpos1 > axisMin && vpos1 < axisMax)
				[rr, gg, bb, aa] = Dendro_GetAColorFromStructure(DDI, cn1)
				lstyle = Dendro_GetLineStyleFromStructure(DDI, cn1)
				lsize = Dendro_GetLineSizeFromStructure(DDI, cn1)
				SetDrawEnv/W=$gname xcoord=prel,ycoord=left, linefgc=(rr,gg,bb,aa), lineThick=lsize, dash=lstyle, linecap=1
				DrawLine/W=$gname xpos1, vpos1, curXpos, vpos1
			endif

			if (vpos2 > axisMin && vpos2 < axisMax)
				[rr, gg, bb, aa] = Dendro_GetAColorFromStructure(DDI, cn2)
				lstyle = Dendro_GetLineStyleFromStructure(DDI, cn2)
				lsize = Dendro_GetLineSizeFromStructure(DDI, cn2)
				SetDrawEnv/W=$gname xcoord=prel,ycoord=left, linefgc=(rr,gg,bb,aa), lineThick=lsize, dash=lstyle, linecap=1
				DrawLine/W=$gname xpos2, vpos2, curXpos, vpos2
			endif
		endif
		
		if (cn1 != cn2)
			// If the two nodes that are being connected don't have the same color number, then the connecting line
			// is outside of the clusters and the color should be the default color
			[rr, gg, bb, aa] = Dendro_GetAColorFromStructure(DDI, 0)		// zero is the color number for nodes that aren't part of a cluster
			lstyle = Dendro_GetLineStyleFromStructure(DDI, 0)
			lsize = Dendro_GetLineSizeFromStructure(DDI, 0)
		endif
		// Draw the line that connects to two lines. If DDI.doVertical=1, it is horizontal, and the vertical position represents
		// the distance or dissimilarity value of the current node row in the dendrogram info wave
		if (vpos1 < axisMin)
			vpos1 = axisMin
		elseif (vpos1 > axisMax)
			vpos1 = axisMax
		endif
		if (vpos2 < axisMin)
			vpos2 = axisMin
		elseif (vpos2 > axisMax)
			vpos2 = axisMax
		endif
		if (vpos1 != vpos2)
			if (DDI.doVertical)
				SetDrawEnv/W=$gname xcoord=bottom,ycoord=prel, linefgc=(rr,gg,bb,aa), lineThick=lsize, dash=lstyle, linecap=1
				DrawLine/W=$gname vpos1, curXpos, vpos2, curXpos
			else
				SetDrawEnv/W=$gname xcoord=prel,ycoord=left, linefgc=(rr,gg,bb,aa), lineThick=lsize, dash=lstyle, linecap=1
				DrawLine/W=$gname curXpos, vpos1, curXpos, vpos2
			endif
		endif
	endfor

	// Draw the little "pip" that represents the trunk of the tree.
	if (nodePosWave[nlines-1][1] > axisMin && nodePosWave[nlines-1][1] < axisMax)
		if (DDI.doVertical)
			SetDrawEnv/W=$gname xcoord=bottom,ycoord=prel, linefgc=(rr,gg,bb,aa), lineThick=DDI.lineThick, dash=DDI.lineStyle, linecap=1
			DrawLine/W=$gname nodePosWave[nlines-1][1], nodePosWave[nlines-1][0], nodePosWave[nlines-1][1], -.02
		else
			SetDrawEnv/W=$gname xcoord=prel,ycoord=left, linefgc=(rr,gg,bb,aa), lineThick=DDI.lineThick, dash=DDI.lineStyle, linecap=1
			DrawLine/W=$gname nodePosWave[nlines-1][0], nodePosWave[nlines-1][1], -.02, nodePosWave[nlines-1][1]
		endif
	endif
	SetDrawEnv/W=$gname gstop
	
	Dendro_PossiblyDrawCutLine(gname, dendroWave, WaveMax(labelLengths), DDI)

end

static Function/WAVE Dendro_MeasureLabels(String gname, STRUCT DendrogramDrawInfo & DDI, Variable npoints, Variable doVertical)
	GetWindow $gname, psize
	Variable pw
	if (doVertical)
		pw = V_bottom - V_top
	else
		pw = V_right - V_left
	endif
	
	Variable maxTextWidth = 0
	Make/N=(npoints)/FREE labelLengths=0
	
	Variable fontSize = DDI.labelFontSize
	String fontName =  DDI.labelFontName
	Variable fontStyle = DDI.labelFontStyle
	
	if (Dendro_wantsLabels(DDI))
		Variable i
		for (i = 0; i < npoints; i++)
			String onelabel = Dendro_GetIndexedLeafLabel(i, gname, DDI)
			if (strlen(onelabel) == 0)
				labelLengths[i] = 0
			else
				MeasureStyledText/W=$gname/SIZE=(fontSize)/STYL=(fontStyle)/F=(fontName) onelabel
				Variable tw = V_width
				Variable th = V_height
				labelLengths[i] = tw/pw
			endif
		endfor
	endif

	return labelLengths
end

static Function Dendro_ChangeImageLayout(String gname, STRUCT DendrogramDrawInfo & DDI)
	Variable combinedSpace = DDI.dendroMargin + DDI.labelImageBuffer
	if (DDI.doVertical)
		ModifyGraph/W=$gname axisEnab(left)={0, 1-combinedSpace}
	else
		ModifyGraph/W=$gname axisEnab(bottom)={combinedSpace, 1}
	endif
	if (DDI.showDistanceAxis)
		Dendro_AddOrChangeDistanceAxis(gname, DDI)
	else
		Dendro_RemoveDistanceAxis(gname, Dendro_TypeFromStructure(gname, DDI))
	endif
end

static Function Dendro_wantsLabels(STRUCT DendrogramDrawInfo & DDI)
	Wave/T/Z labelwave = $DDI.dendrogramLabelWave
	if (WaveExists(labelwave))
		return 1
	elseif (CmpStr(DDI.dendrogramLabelWave, LabelsDimLabelsString) == 0)
		return 1
	endif
	
	return 0
end

static Function Dendro_SearchDendroWaveForIndex(Wave dendroWave, Variable index)
	FindValue/V=(index)/RMD=[][3]/T=0 dendroWave
	if (V_value == -1)
		return -1
	endif
	return V_value - DimSize(dendroWave, 0)*3		// perversely, FindValue returns the index as if the wave were 1D
end

// This replaces code that accessed the leaf labels by directly accessing the labels wave.
// That means that the code expects to pass an index that is in the order of the original data matrix,
// not the order of the reordered data.
static Function/T Dendro_GetIndexedLeafLabel(Variable index, String gname, STRUCT DendrogramDrawInfo & DDI)
	Wave/T/Z labelwave = $DDI.dendrogramLabelWave
	Wave dendrogramw = $DDI.dendrogramWaveName
	Variable isdouble = DDendro_GraphHasDoubleDendrogram(gname)

	if (WaveExists(labelwave))
		if (index < 0 || index >= numpnts(labelwave))
			return ""
		endif
		return labelwave[index]
	elseif (CmpStr(DDI.dendrogramLabelWave, LabelsDimLabelsString) == 0)
		Wave reorderedw = $DDI.ReorderedDataWave
		Variable dim = 0
		if (isdouble && DDI.doVertical==0)
			dim = 1
		endif
		Variable reorderedIndex = Dendro_SearchDendroWaveForIndex(dendrogramw, index)
		if (reorderedIndex < 0)
			return ""
		endif
		return GetDimLabel(reorderedw, dim, reorderedIndex)
	endif
	
	return ""
end

static Function Dendro_NumLabels(STRUCT DendrogramDrawInfo & DDI)
	WAVE w = $DDI.dendrogramWaveName
	
	return DimSize(w, 0)
end

static Function Dendro_DrawLeafLabels(String gname, STRUCT DendrogramDrawInfo & DDI)
	if (strlen(DDI.dendrogramLabelWave) == 0 || CmpStr(DDI.dendrogramLabelWave, LabelsNoneString) == 0)
		return 0
	endif
	
	Variable i
	string fname = DDI.labelFontName
	if (CmpStr(fname, "default") == 0)
		fname = GetDefaultFont(gname)
	endif
	Variable npnts = Dendro_numLabels(DDI)
	Wave dendroWave = $(DDI.dendrogramWaveName)
	
	Wave/Z colornumbers=$""
	if (DDI.labelUseClusterColors)
		Wave colornumbers = Dendro_AnalyzeForClusters(dendroWave, DDI.cutValue)
	endif

	// Check the axis limits and don't draw outside the bounds of the axis. The user
	// may have zoomed in on the graph.
	Variable axisMax, axisMin
	if (DDI.doVertical)
		GetAxis/W=$gname/Q bottom
	else
		GetAxis/W=$gname/Q left
	endif
	axisMax = V_max
	axisMin = V_min
	
	SetDrawLayer/W=$(gname) UserFront
	
	string labelsGroupName = leafLabelsGroup + SelectString(DDI.doVertical, "_H", "_V")
	SetDrawEnv/W=$gname gstart, gname=$labelsGroupName
	Variable r = DDI.labelColorR
	Variable g = DDI.labelColorG
	Variable b = DDI.labelColorB
	Variable a = DDI.labelColorA
	for (i = 0; i < npnts; i++)
			String leaflabel = Dendro_GetIndexedLeafLabel(dendroWave[i][3], gname, DDI)
		if (strlen(leaflabel) == 0)
			continue
		endif
		Variable vpos = i
		if (vpos > axisMin && vpos < axisMax)
			if (DDI.labelUseClusterColors)
				Variable node = -(dendroWave[i][3]+1)
				Variable cnumber = Dendro_GetClusterNumberForNodeNumber(node, colornumbers)
				[r,g,b,a] = Dendro_GetAColorFromStructure(DDI, cnumber)
			endif
			if (DDI.doVertical)
				SetDrawEnv/W=$gname xcoord=bottom,ycoord=prel,fname=fname, fsize=DDI.labelFontSize, fstyle=DDI.labelFontStyle, textrgb=(r,g,b,a), textxjust=1, textyjust=0, textrot=90	// vertical center adjusted
				DrawText/W=$gname vpos, DDI.dendroMargin-DDI.labelImageBuffer, leaflabel
			else
				SetDrawEnv/W=$gname xcoord=prel,ycoord=left,fname=fname, fsize=DDI.labelFontSize, fstyle=DDI.labelFontStyle, textrgb=(r,g,b,a), textxjust=2, textyjust=1	// vertical center adjusted
				DrawText/W=$gname DDI.dendroMargin-DDI.labelImageBuffer, vpos, leaflabel
			endif
		endif
	endfor
	SetDrawEnv/W=$gname gstop
end

static Function Dendro_CreateFormulaForLabelUpdate(String gname, DFREF dendroDF, Variable dendroType)
	SVAR labelstr = dendroDF:dendrogramLabelWave
	Wave/Z/T labelw = $labelstr
	String expressionWName = ""
	if (WaveExists(labelw))
		expressionWName = GetWavesDataFolder(labelw, 2)
	elseif (CmpStr(labelstr, LabelsDimLabelsString) == 0)
		SVAR datawstr = dendroDF:reorderedDataWave
		Wave datawave = $datawstr
		expressionWName = GetWavesDataFolder(datawave, 2)
	endif

	if (strlen(expressionWName) > 0)
		Variable/G dendroDF:updateRowLabelsVar
		NVAR updateRowLabelsVar = dendroDF:UpdateRowLabelsVar
		String formulaExpression = "HClusterDendrogramProcs#Dendro_UpdateLeafLabelsForWaveChange("
		formulaExpression += "\""+gname+"\", "
		formulaExpression += num2str(dendroType)+", "
		SVAR labelstr = dendroDF:dendrogramLabelWave
		Wave/Z/T labelw = $labelstr
		formulaExpression += expressionWName
		formulaExpression += ")"
		SetFormula updateRowLabelsVar, formulaExpression
	endif
end

static Function Dendro_UpdateLeafLabelsForWaveChange(String gname, Variable dendroType, Wave labelsWave)
	if (WinType(gname) == 1)
		STRUCT DendrogramDrawInfo DDI
		Dendro_FillStructureForGraph(gname, DDI, dendroType)
		Dendro_RedrawNodeLinesForStructure(gname, DDI)
		Dendro_RedrawLeafLabelsForStructure(gname, DDI)
	endif
end

static Function Dendro_RedrawLeafLabelsForStructure(String gname, STRUCT DendrogramDrawInfo & DDI)
	string labelsGroupName = leafLabelsGroup + SelectString(DDI.doVertical, "_H", "_V")
	DrawAction/W=$(gname) GetGroup=$labelsGroupName
	if (V_flag)
		DrawAction/W=$(gname) GetGroup=$labelsGroupName,delete
	endif

	Dendro_DrawLeafLabels(gname, DDI)
end

// type = 0 for horizontal, 1 for vertical, 2 for a single dendrogram and we don't care
static Function/S Dendro_TypeSuffix(Variable dendrotype)
	String suffix = ""
	
	switch(dendrotype)
		case DendroTypeH:
			suffix += "_H"
			break;
		case DendroTypeV:
			suffix += "_V"
			break;
		case DendroTypeSingle:
		default:
			break;
	endswitch
	
	return suffix
end

static Function/S Dendro_DistanceAxisName(Variable dendrotype)
	String axisname = distanceAxisName+Dendro_TypeSuffix(dendrotype)
	return axisname
end

static Function Dendro_DistanceAxisExists(String gname, Variable dendrotype)
	String alist = AxisList(gname)
	String searchName = Dendro_DistanceAxisName(dendrotype)
	Variable axisExists = WhichListItem(searchName, alist)
	return axisExists >= 0
end

static Function Dendro_TypeFromStructure(String gname, STRUCT DendrogramDrawInfo & DDI)
	Variable type = DendroTypeSingle
	if (DDendro_GraphHasDoubleDendrogram(gname))
		type = DDI.doVertical ? DendroTypeV : DendroTypeH
	endif
	return type
end

// It's "AddOrChange" because it can add a new axis if needed, or it will change
// the layout of an existing axis
static Function Dendro_AddOrChangeDistanceAxis(String gname, STRUCT DendrogramDrawInfo & DDI)
	if (!DDI.showDistanceAxis)
		return 0
	endif
	
	Variable dendroType = Dendro_TypeFromStructure(gname, DDI)
	Variable daxisExists = Dendro_DistanceAxisExists(gname, dendrotype)
	String axisName = Dendro_DistanceAxisName(dendrotype)
	
	Wave dendroWave = $(DDI.dendrogramWaveName)
	Wave labelLengths = Dendro_MeasureLabels(gname, DDI, DimSize(dendroWave, 0), DDI.doVertical)
	labelLengths += DDI.labelBuffer + DDI.labelImageBuffer

	Duplicate/RMD=[][2,2]/FREE dendroWave, heights	
	Variable hMin = WaveMin(heights)
	Variable hMax = WaveMax(heights)
	GetWindow $gname, psize
	Variable pwidth
	if (DDI.doVertical)
		pwidth = V_bottom - V_top
	else
		pwidth = V_right - V_left
	endif
	
	Variable x0 = DDI.dendroMargin - WaveMax(labelLengths)		// prel position of minimum height
	Variable hPosFactor = x0/(hMax - hMin)							// assumes that left-most position is at x=0
	Variable xmax = 0														// prel position of maximum height
	Variable minAxPos = x0 + hposFactor*hMin
	if (DDI.doVertical)
		if (!daxisExists)
			NewFreeAxis/L/W=$gname $axisName
		endif
		SetAxis/W=$gname $axisName, hMin, hMax
		ModifyGraph/W=$gname axisEnab($axisName)={1-x0,1}
		ModifyGraph/W=$gname freePos($axisName)={0,kwFraction}
	else
		if (!daxisExists)
			NewFreeAxis/B/W=$gname $axisName
		endif
		SetAxis/W=$gname $axisName, hMax, hMin
		ModifyGraph/W=$gname axisEnab($axisName)={0, x0}
		ModifyGraph/W=$gname freePos($axisName)={0,kwFraction}
	endif
end

static Function Dendro_RemoveDistanceAxis(String gname, Variable dendroType)
	String axisName = Dendro_DistanceAxisName(dendrotype)
	String alist = AxisList(gname)
	if (FindListItem(axisName, alist) > 0)
		KillFreeAxis/W=$gname $axisName
	endif
end

static Function [Variable rr, Variable gg, Variable bb, Variable aa] Dendro_GetAColorFromStructure(STRUCT DendrogramDrawInfo & DDI, Variable cnumber)

	Wave/Z colorwave = $(DDI.clusterColorWavePath)
	if (!WaveExists(colorwave) || dimsize(colorwave, 0) == 0 || cnumber == 0 || DDI.colorClusters == 0)
		return [DDI.lineColorR, DDI.lineColorG, DDI.lineColorB, DDI.lineColorA]
	endif
	
	cnumber -= 1
	cnumber = mod(cnumber, DimSize(colorwave, 0))
	if (colorwave[cnumber][0] == 0 && colorwave[cnumber][1] == 0 && colorwave[cnumber][2] == 0 && colorwave[cnumber][3] == 0)		// transparent black mean default color
		return [DDI.lineColorR, DDI.lineColorG, DDI.lineColorB, DDI.lineColorA]
	else
		Variable alpha = DimSize(colorwave, 1) > 3 ? colorwave[cnumber][3] : 65535
		return [colorwave[cnumber][0], colorwave[cnumber][1], colorwave[cnumber][2], alpha]
	endif
end

static Function Dendro_GetLineStyleFromStructure(STRUCT DendrogramDrawInfo & DDI, Variable clusterNumber)
	Wave/Z stylewave = $(DDI.clusterLineStyleWavePath)
	if (!WaveExists(stylewave) || DimSize(stylewave, 0)==0 || clusterNumber == 0 || DDI.useClusterLineStyles == 0)
		return DDI.lineStyle
	endif
	
	Variable cnumber = clusterNumber - 1
	
	cnumber = cnumber > DimSize(stylewave, 0) ? 0 : cnumber
	Variable style = stylewave[cnumber]
	return style < 0 ? DDI.lineStyle : style
end

static Function Dendro_GetLineSizeFromStructure(STRUCT DendrogramDrawInfo & DDI, Variable clusterNumber)
	Wave/Z linesizewave = $(DDI.clusterLineSizeWavePath)
	if (!WaveExists(linesizewave) || DimSize(linesizewave, 0)==0 || clusterNumber == 0 || DDI.useClusterLineSizes == 0)
		return DDI.lineThick
	endif
	
	Variable cnumber = clusterNumber - 1
	
	cnumber = cnumber > DimSize(linesizewave, 0) ? 0 : cnumber
	Variable size = linesizewave[cnumber]
	return size < 0 ? DDI.lineThick : size
end

// The cluster number wave has two columns: column 0 contains numbers for non-leaf nodes, column 1 contains numbers for leaf nodes.
// Cluster 0 represents non-cluster nodes. Non-zero cluster numbers represent nodes that are part of a cluster. Thus
// rows in column 0 will generally have zeroes in the bottom rows because the top (most distant) nodes are not grouped. All the leaves
// should be at distances less than the cut value.
// This is used to access cluster colors, line size, and style.
Function Dendro_GetClusterNumberForNodeNumber(Variable node, Wave colorNumbers)
		Variable cnum = 0
		if (node < 0)
			cnum = colorNumbers[abs(node)-1][1]
		else
			cnum = colorNumbers[node-1][0]
		endif
		
		return cnum
end

static Function Dendro_RedrawNodeLinesForStructure(String gname, STRUCT DendrogramDrawInfo & DDI)
		String nodeLinesGroupName = nodeLinesGroup + SelectString(DDI.doVertical, "_V", "_H")
		DrawAction/W=$(gname) GetGroup=$nodeLinesGroupName
		if (V_flag)
			DrawAction/W=$(gname) GetGroup=$nodeLinesGroupName,delete
		endif
		
		Wave dendroWave = $(DDI.dendrogramWaveName)
	
		Wave labelLengths = Dendro_MeasureLabels(gname, DDI, DimSize(dendroWave, 0), DDI.doVertical)
		Wave colorNumbers = Dendro_AnalyzeForClusters(dendroWave, DDI.cutvalue)
		labelLengths += DDI.labelBuffer + DDI.labelImageBuffer

		Dendro_DrawNodeLines(gname, dendroWave, labelLengths, colorNumbers, DDI)
end

static Function/S Dendro_axisInfoString(String gname, String axName)
	String axInfo=""
	Variable vmin, vmax, hmin, hmax
	GetAxis/W=$gname/Q $axName
	sprintf axInfo, "%g;%g;", V_min, V_max
	
	return axInfo
end

static Function Dendro_DendroMaintenanceHook(STRUCT WMWinHookStruct & s)
	STRUCT DendrogramDrawInfo DDI

	strswitch(s.eventName)
		case "resize":
			Dendro_FillStructureForGraph(s.winName, DDI, DendroTypeSingle)
			Dendro_RedrawNodeLinesForStructure(s.winName, DDI)
			Dendro_RedrawLeafLabelsForStructure(s.winName, DDI)
			break
		case "kill":
			// On Mac OS X, there is no guarantee that the graphName is the top-most window or top-most polar graph!
			Variable recreationMacroExists = GraphMacroExists(s.winName)
			if (!recreationMacroExists)
				DFREF dendroDFR = DendrogramDataFolder(s.winName, DendroTypeSingle)

				if (DataFolderRefStatus(dendroDFR) == 1)
					NVAR/Z updatevar = dendroDFR:updateRowLabelsVar
					Variable dependencyIsAProblem = NVAR_Exists(updatevar)
					// It's necessary to kill the dummy variable involved in the dependency that
					// redraws the dendrogram when the labels change. That's because in the case of
					// dimension labels used as leaf labels, the dependency is on the data matrix
					// and that dependency prevents killing the data folder.
					String DFpath = GetDataFolder(1, dendroDFR)
					if (dependencyIsAProblem)
						Execute/P/Q "KillVariables "+DFpath+"updateRowLabelsVar"
					endif
					Execute/P/Q "KillDataFolder "+DFpath
				endif
			endif
			break
		case "modified":
			// axis ranges is one of a quite large number of "modifications" that can trigger this event.
			// So test to see if the axis ranges have changed, and redraw if they have. 
			String aInfo = GetUserData(s.winName, "", "DendroAxisInfo")
			Dendro_FillStructureForGraph(s.winName, DDI, DendroTypeSingle)
			String aname = SelectString(DDI.doVertical, "left", "bottom")
			string newinfo = Dendro_axisInfoString(s.winName, aname)
			Variable doRedraw = 0
			if (strlen(aInfo) == 0 || CmpStr(aInfo, newinfo) != 0)
				doRedraw = 1
				SetWindow $s.winName, userdata(DendroAxisInfo)=newinfo
				Dendro_RedrawNodeLinesForStructure(s.winName, DDI)
				Dendro_RedrawLeafLabelsForStructure(s.winName, DDI)
			endif
			break
	endswitch
end

// Returns 1 for no suffix (single) rect, 2 for V rect, 3 for no suffix. Returns 0 for no hit.
static Function Dendro_PointIsInCutLine(String gname, Variable mouseH, Variable mouseV)
	String cutlineData = GetUserData(gname, "", cutlinerectUD)
	if (strlen(cutlineData) == 0)
		return 0
	endif	
	
	Variable isInRect = 0;

	GetWindow $gname, psize
	Variable pwidth = V_right - V_left
	Variable pheight = V_bottom - V_top
	Variable pleft = V_left
	Variable ptop = V_top
	Variable mh = (mouseH - pleft)/pwidth
	Variable mv = (mouseV - ptop)/pheight
	Variable retval = 0
	Variable i
	for(i = 0; i < 3; i++)
		String keyStr = "RECT"+Dendro_TypeSuffix(i)
		String rectData = StringByKey(keyStr, cutlineData, "=", ";")
		if (strlen(rectData) > 0)
			Variable cleft = str2num(StringFromList(0, rectData, ","))
			Variable ctop = str2num(StringFromList(1, rectData, ","))
			Variable cright = str2num(StringFromList(2, rectData, ","))
			Variable cbottom = str2num(StringFromList(3, rectData, ","))
			if (mh > cleft && mh < cright && mv > ctop && mv < cbottom)
				retval = i+1
				break
			endif
		endif
	endfor
		
	return retval
end

static Function Dendro_UpdateCutValueInPanel(String gname, Variable newCutValue)
	String panelName = gname+"#ModifyDendrogramPanel#ClustersTab"
	if (WinType(panelName) == 7)
		SetVariable Dendro_ModPanel_SetCutValue, win=$panelName, value=_NUM:newCutValue
	endif
end

static Function Dendro_MoveCutLine(String gname, Variable dendrotype, Variable deltaP_h, Variable deltaP_v, Variable origCutValue)
	STRUCT DendrogramDrawInfo DDI
	Dendro_FillStructureForGraph(gname, DDI, dendrotype)

	Variable deltaP = DDI.doVertical ? deltaP_v : deltaP_h
	if (deltaP == 0)
		return 0
	endif

	Wave/Z dendroWave = $(DDI.dendrogramWaveName)
	if (!WaveExists(dendroWave))
		return 0
	endif
	Variable maxLabelLength = 0
	Wave labelLengths = Dendro_MeasureLabels(gname, DDI, DimSize(dendroWave, 0), DDI.doVertical)
	maxLabelLength = WaveMax(labelLengths)
	
	GetWindow $gname, psize
	Variable pwidth = V_right - V_left
	Variable pheight = V_bottom - V_top
	Variable pleft = V_left
	Variable ptop = V_top
	Variable movePRel = DDI.doVertical ? deltaP/pheight : deltaP/pwidth

	Duplicate/RMD=[][2,2]/FREE dendroWave, heights
	Variable hMin = WaveMin(heights)
	Variable hMax = WaveMax(heights)
	Variable x0 = DDI.dendroMargin - maxLabelLength
	Variable hPosFactor = x0/(hMax - hMin)			// assumes that left-most position is at x=0

	Variable cutLinePos = x0 - hposFactor*(origCutValue - hMin)
	cutLinePos += movePRel
	Variable newCutVal = max(0, min(hMax, hMin - (cutLinePos - x0)/hPosFactor))
	DDI.cutValue = newCutVal
	Dendro_RedrawNodeLinesForStructure(gname, DDI)				// Also re-draws the cut line. We call this so that the line colors will change.
	if (DDI.labelUseClusterColors)
		Dendro_RedrawLeafLabelsForStructure(gname, DDI)
	endif
	Dendro_UpdateCutValueInPanel(gname, newCutVal)
	
	if (Dendro_HasClusterNumbers(gname, DDI.doVertical))
		Dendro_AddClusterNumbers(gname, dendroType)				// will pre-erase the labels, too
	endif
	
	DoUpdate
end

static Function [Variable mh, Variable mv] Dendro_scaleMouse(Variable inmh, Variable inmv)
	Variable factor = 72/ScreenResolution
	return [inmh*factor, inmv*factor]
end

static Function Dendro_ManageCutLineHook(STRUCT WMWinHookStruct & s)

	String gname = StringFromList(0, s.winName, "#")

	Variable retval = 0		// set to 1 to indicate event was handled and should not be handled internally
	String cutlinedata
	String cutlineRectData
	String cutlineinfo
	String managerData
	Variable dendrotype
	String rectData
	String keystr
	Variable mh, mv
	[mh, mv] = dendro_scaleMouse(s.mouseLoc.h, s.mouseLoc.v)

	strswitch(s.eventName)
		case "mousemoved":
			if (s.eventMod & 1)		// mouse button down?
				managerData = GetUserData(gname, "", "CutLineManagerData")
				if (strlen(managerData) > 0)
					dendrotype = str2num(StringFromList(3, managerData))
					retval = 1
					Variable startP_h = str2num(StringFromList(0, managerData))
					Variable startP_v = str2num(StringFromList(1, managerData))
					Variable startCutValue = str2num(StringFromList(2, managerData))
					Variable deltaP_h = mh - startP_h
					Variable deltaP_v = mv - startP_v
					Dendro_MoveCutLine(gname, dendrotype, deltaP_h, deltaP_v, startCutValue)
				endif
			else
				// test for the mouse pointer being inside a cutline rectangle and set the mouse cursor if it is
				// For that, we don't care about dendrotype, we test all the possibilities
				Variable isInRect = Dendro_PointIsInCutLine(s.winName, mh, mv)
				if (isInRect)
					s.doSetCursor = 1
					s.cursorCode = 8
				else
					s.doSetCursor = 0
				endif
			endif
			break
		case "mousedown":
			// isInRect is 0 for not in rect, 1 for in dendrotype single, 2 for vertical, 3 for horizontal. That is,
			// if in rect, return is dendro type + 1
			isInRect = Dendro_PointIsInCutLine(s.winName, mh, mv)
			if (isInRect)
				dendrotype = isInRect - 1
				keystr = "RECT"+Dendro_TypeSuffix(dendrotype)
				cutlineRectData = GetUserData(gname, "", cutlinerectUD)
				rectData = StringByKey(keystr, cutlineRectData, "=", ";")
				Variable cutValue = str2num(StringFromList(4, rectData, ","))				// four values for cut line rect, then the actual cut value
				sprintf cutlinedata, "%g;%g;%g;%d;", mh, mv, cutValue, dendrotype
				SetWindow $gname, userdata(CutLineManagerData) = cutlinedata
				retval = 1
			else
				// was cutlineManagerData left behind at some point (because of a bug)?
				managerData = GetUserData(gname, "", "CutLineManagerData")
				if (strlen(managerData) > 0)
					SetWindow $gname, userdata(CutLineManagerData) = ""
				endif
			endif
			break
		case "mouseup":
			managerData = GetUserData(gname, "", "CutLineManagerData")
			if (strlen(managerData) > 0)
				dendrotype = str2num(StringFromList(3, managerData))
				retval = 1
				startP_h = str2num(StringFromList(0, managerData))
				startP_v = str2num(StringFromList(1, managerData))
				startCutValue = str2num(StringFromList(2, managerData))
				deltaP_h = mh - startP_h
				deltaP_v = mv - startP_v
				Dendro_MoveCutLine(gname, dendrotype, deltaP_h, deltaP_v, startCutValue)
				SetWindow $gname, userdata(CutLineManagerData)=""
			endif
			break
		case "activate":
			DendroModPanel_CheckVersion(s.winName)
			break
	endswitch

	return retval
end

static Function Dendro_SetStructDefaults(STRUCT DendrogramDrawInfo & DDI)
	DDI.doVertical = 0
	DDI.dendroMargin = 0.48
//
	DDI.labelFontSize = 10
	DDI.labelFontStyle = 0
	DDI.labelFontName = "default"
	DDI.labelColorR = 0
	DDI.labelColorG = 0
	DDI.labelColorB = 0
	DDI.labelColorA = 65535
	DDI.labelUseClusterColors = 0
	DDI.labelImageBuffer = 0.01
	DDI.labelBuffer = 0.01
	
	DDI.perpendicularLabelWave=""
	DDI.perpendicularLabelSide=0
	
	DDI.showDistanceAxis = 0
//	
	DDI.lineThick = 1
	DDI.lineStyle = 0
	DDI.alignEnds = 0
	DDI.colorClusters = 0
	DDI.clusterColorWavePath = ""
	DDI.lineColorR = 0
	DDI.lineColorG = 0
	DDI.lineColorB = 0
	DDI.lineColorA = 65535
	DDI.useClusterLineStyles = 0
	DDI.useClusterLineSizes = 0
//	
	DDI.cutValue = 0
	DDI.drawCutLine = 0
//	
	DDI.cutLineThick = 1
	DDI.cutLineStyle = 1
	DDI.cutLineColorR = 40000
	DDI.cutLineColorG = 40000
	DDI.cutLineColorB = 40000
	DDI.cutLineColorA = 65535
end

static Constant Dendro_PackagePrefsVersion = 100
static Constant Dendro_PackagePrefsID = 1
static StrConstant Dendro_PackagePrefsName = "WM Heat Map and Dendrogram"
static StrConstant Dendro_PackagePrefsFileName = "WM Heat Map and Dendrogram Prefs"

static Structure Dendro_PrefsStructure
	uint32 version
	float dendroMargin					// Size in plot-relative coordinates of the space reserved for the dendrogram lines and labels

	float labelFontSize
	int16 labelFontStyle
	char labelFontName[400]
	uint16 labelColorR
	uint16 labelColorG
	uint16 labelColorB
	uint16 labelColorA
	uchar labelUseClusterColors
	float labelImageBuffer			// position of label right or bottom end relative to edge of image
	float labelBuffer					// space added to left or top end of labels to indicate space between leaf lines and labels
	
	float lineThick
	float lineStyle
	uchar alignEnds						// if non-zero, leaf line ends are aligned. If zero, leaf lines extend to each label
	uchar colorClusters				// if non-zero, color clusters using the ClusterColors wave in the dendrogram's folder
	uint16 lineColorR
	uint16 lineColorG
	uint16 lineColorB
	uint16 lineColorA
	uchar useClusterLineStyles		// if non-zero, line styles for the dendrogram come from the wave ClusterStyles in the dendrogram's folder
	uchar useClusterLineSizes
	
	uchar perpendicularLabelSide
	
	uchar showDistanceAxis
	
	float cutValue
	uchar drawCutLine
	
	float cutLineThick
	int16 cutLineStyle
	uint16 cutLineColorR
	uint16 cutLineColorG
	uint16 cutLineColorB
	uint16 cutLineColorA
	
	uint16 numClusterColors
	uint16 clusterColorR[20]
	uint16 clusterColorG[20]
	uint16 clusterColorB[20]
	
	uint16 numClusterStyles
	int16 clusterLineStyles[20]
	
	uint16 numClusterSizes
	int16 clusterLineSizes[20]
	
	uint32 reserved[100]
endstructure

// Use this for any graph after extracting the appropriate settings structure
static Function Dendro_StoreStructureAsPrefs(STRUCT DendrogramDrawInfo & DDI)
	Wave/Z colors = $(DDI.clusterColorWavePath)
	Wave/Z stylewave = $(DDI.clusterLineStyleWavePath)
	Wave/Z linesizewave = $(DDI.clusterLineSizeWavePath)
	Dendro_StoreSettingsAsPrefs(DDI, colors, stylewave, linesizewave)
end

static Function Dendro_StoreSettingsAsPrefs(STRUCT DendrogramDrawInfo & DDI, Wave/Z ClusterColors, Wave/Z LineStyles, Wave/Z LineSizes)
	
	Variable i
	
	STRUCT Dendro_PrefsStructure prefs
	
	prefs.version = Dendro_PackagePrefsVersion
	prefs.dendroMargin	 = DDI.dendroMargin

	prefs.labelFontSize = DDI.labelFontSize
	prefs.labelFontStyle = DDI.labelFontStyle
	prefs.labelFontName = DDI.labelFontName
	prefs.labelColorR = DDI.labelColorR
	prefs.labelColorG = DDI.labelColorG
	prefs.labelColorB = DDI.labelColorB
	prefs.labelColorA = DDI.labelColorA
	prefs.labelUseClusterColors = DDI.labelUseClusterColors
	prefs.labelImageBuffer = DDI.labelImageBuffer
	prefs.labelBuffer = DDI.labelBuffer
	
	prefs.lineThick = DDI.lineThick
	prefs.lineStyle = DDI.lineStyle
	prefs.alignEnds	 = DDI.alignEnds
	prefs.colorClusters = DDI.colorClusters
	prefs.lineColorR = DDI.lineColorR
	prefs.lineColorG = DDI.lineColorG
	prefs.lineColorB = DDI.lineColorB
	prefs.lineColorA = DDI.lineColorA
	prefs.useClusterLineStyles = DDI.useClusterLineStyles
	prefs.useClusterLineSizes = DDI.useClusterLineSizes
	
	prefs.perpendicularLabelSide = DDI.perpendicularLabelSide
	
	prefs.showDistanceAxis = DDI.showDistanceAxis
	
	prefs.cutValue = DDI.cutValue
	prefs.drawCutLine = DDI.drawCutLine
	
	prefs.cutLineThick = DDI.cutLineThick
	prefs.cutLineStyle = DDI.cutLineStyle
	prefs.cutLineColorR = DDI.cutLineColorR
	prefs.cutLineColorG = DDI.cutLineColorG
	prefs.cutLineColorB = DDI.cutLineColorB
	prefs.cutLineColorA = DDI.cutLineColorA
	
	for (i = 0; i < 20; i++)
		prefs.clusterColorR[i] = 0
		prefs.clusterColorG[i] = 0
		prefs.clusterColorB[i] = 0
	endfor
	if (WaveExists(ClusterColors))
		Variable last = min(20, DimSize(ClusterColors, 0))
		prefs.numClusterColors = last
		for (i = 0; i < last; i++)
			prefs.clusterColorR[i] = ClusterColors[i][0]
			prefs.clusterColorG[i] = ClusterColors[i][1]
			prefs.clusterColorB[i] = ClusterColors[i][2]
		endfor
	else
		prefs.numClusterColors = 0
	endif
	

	for (i = 0; i < 20; i++)
		prefs.clusterLineStyles[i] = 0
	endfor
	if (WaveExists(LineStyles))
		Variable laststyle = min(20, numpnts(LineStyles))
		prefs.numClusterStyles = laststyle
		for (i = 0; i < laststyle; i++)
			prefs.clusterLineStyles[i] = LineStyles[i]
		endfor
	else
		prefs.numClusterStyles = 0
	endif
	

	for (i = 0; i < 20; i++)
		prefs.clusterLineSizes[i] = 1
	endfor
	if (WaveExists(LineSizes))
		Variable lastsize = min(20, numpnts(LineSizes))
		prefs.numClusterSizes = lastsize
		for (i = 0; i < lastsize; i++)
			prefs.clusterLineSizes[i] = LineSizes[i]
		endfor
	else
		prefs.numClusterSizes = 0
	endif
	
	for (i = 0; i < 100; i++)
		prefs.reserved[i] = 0
	endfor
	
	SavePackagePreferences Dendro_PackagePrefsName, Dendro_PackagePrefsFileName, Dendro_PackagePrefsID, prefs
end

// Only use for single dendrogram
static Function Dendro_LoadSettingsFromPrefs(String gname)
	DFREF dendroDFR = DendrogramDataFolder(gname, DendroTypeSingle)
	
	STRUCT DendrogramDrawInfo DDI
	structFill/SDFR=dendroDFR DDI
	Dendro_LoadSettingsFromPrefsIntoStruct(gname, DDI)
end
	
static Function Dendro_LoadSettingsFromPrefsIntoStruct(String gname, STRUCT DendrogramDrawInfo & DDI)
	Variable i
	
	DFREF dendroDFR = DendrogramDataFolder(gname, DDI.doVertical)
	
	STRUCT Dendro_PrefsStructure prefs
	LoadPackagePreferences Dendro_PackagePrefsName, Dendro_PackagePrefsFileName, Dendro_PackagePrefsID, prefs
	if (V_bytesRead > 0)
		// Is there something to do with this? prefs.version
		DDI.dendroMargin	 = prefs.dendroMargin

		DDI.labelFontSize = prefs.labelFontSize
		DDI.labelFontStyle = prefs.labelFontStyle
		DDI.labelFontName = prefs.labelFontName
		DDI.labelColorR = prefs.labelColorR
		DDI.labelColorG = prefs.labelColorG
		DDI.labelColorB = prefs.labelColorB
		DDI.labelColorA = prefs.labelColorA
		DDI.labelUseClusterColors = prefs.labelUseClusterColors
		DDI.labelImageBuffer = prefs.labelImageBuffer
		DDI.labelBuffer = prefs.labelBuffer
	
		DDI.lineThick = prefs.lineThick
		DDI.lineStyle = prefs.lineStyle
		DDI.alignEnds	 = prefs.alignEnds
		DDI.colorClusters = prefs.colorClusters
		DDI.lineColorR = prefs.lineColorR
		DDI.lineColorG = prefs.lineColorG
		DDI.lineColorB = prefs.lineColorB
		DDI.lineColorA = prefs.lineColorA
		DDI.useClusterLineStyles = prefs.useClusterLineStyles
		DDI.useClusterLineSizes = prefs.useClusterLineSizes
		
		DDI.perpendicularLabelSide = prefs.perpendicularLabelSide
		
		DDI.showDistanceAxis = prefs.showDistanceAxis
	
		DDI.cutValue = prefs.cutValue
		DDI.drawCutLine = prefs.drawCutLine
	
		DDI.cutLineThick = prefs.cutLineThick
		DDI.cutLineStyle = prefs.cutLineStyle
		DDI.cutLineColorR = prefs.cutLineColorR
		DDI.cutLineColorG = prefs.cutLineColorG
		DDI.cutLineColorB = prefs.cutLineColorB
		DDI.cutLineColorA = prefs.cutLineColorA
	
		Variable numcolors = prefs.numClusterColors
		Make/N=(numcolors, 3)/O dendroDFR:ClusterColors/WAVE = colors
		DDI.clusterColorWavePath = GetWavesDataFolder(colors, 2)
		for (i = 0; i < numcolors; i++)
			colors[i][0] = prefs.clusterColorR[i]
			colors[i][1] = prefs.clusterColorG[i]
			colors[i][2] = prefs.clusterColorB[i]
		endfor
	
		Variable numstyles = prefs.numClusterStyles
		Make/N=(numstyles)/O dendroDFR:ClusterStyles/WAVE = stylewave
		DDI.clusterLineStyleWavePath = GetWavesDataFolder(stylewave, 2)
		for (i = 0; i < numstyles; i++)
			stylewave[i] = prefs.clusterLineStyles[i]
		endfor
	
		Variable numsizes = prefs.numClusterSizes
		Make/N=(numsizes)/O dendroDFR:ClusterLineSizes/WAVE = sizewave
		DDI.clusterLineSizeWavePath = GetWavesDataFolder(sizewave, 2)
		for (i = 0; i < numsizes; i++)
			sizewave[i] = prefs.clusterLineSizes[i]
		endfor
	endif
end

static Function Dendro_SetPreferencesToDefault()

	DFREF saveDF = GetDataFolderDFR()
	NewDataFolder/O/S TempDendroDF
	DFREF gDF = GetDataFolderDFR()
	
	STRUCT DendrogramDrawInfo DDI
	structFill/AC=1 DDI
	Dendro_SetStructDefaults(DDI)
	Dendro_StoreSettingsAsPrefs(DDI, $"", $"", $"")
end

static Function/S ClusterColorPopStr()
	String gname = WinName(0,1)
	if (strlen(gname) == 0)
		return ""
	endif
	String menuDefList = GetUserData(gname, "", "DENDRO_MENUDEFS")
	if (strlen(menuDefList) == 0)
		return ""
	endif
	return StringFromList(0, menuDefList)
end

static Function/S ClusterLineStylePopStr()
	String gname = WinName(0,1)
	if (strlen(gname) == 0)
		return ""
	endif
	String menuDefList = GetUserData(gname, "", "DENDRO_MENUDEFS")
	if (strlen(menuDefList) == 0)
		return ""
	endif
	return StringFromList(1, menuDefList)
end

static Function/S ClusterLineWeightPopStr()
	String gname = WinName(0,1)
	if (strlen(gname) == 0)
		return ""
	endif
	String menuDefList = GetUserData(gname, "", "DENDRO_MENUDEFS")
	if (strlen(menuDefList) == 0)
		return ""
	endif
	String lsizeStr = StringFromList(2, menuDefList)
	if (str2num(lsizeStr) < 0)
		lsizeStr = "Default"
	endif
	String menustr = "Default;0;1;2;3;4;5;6;7;8;9;10;"
	Variable lsizePos = FindListItem(lsizeStr, menustr)
	if (lsizePos < 0)
		menustr += "!"+num2char(18)+lsizeStr+";"
	else
		menustr = menustr[0,lsizePos-1]+"!"+num2char(18)+menustr[lsizePos, inf]
	endif
	return menustr
end

Menu "ClusterStylePop", dynamic, contextualMenu
	Submenu "Cluster Color"
		"Default Color"
		Submenu "Color"
			HClusterDendrogramProcs#ClusterColorPopStr()
		end
	end
	Submenu "Cluster Line Size"
		HClusterDendrogramProcs#ClusterLineWeightPopStr()
	end
	Submenu "Cluster Line Style"
		"Default Style"
		Submenu "Styles"
			HClusterDendrogramProcs#ClusterLineStylePopStr()
		end
	end
end

// returns 0 if a problem was encountered such as dendroRowNumber being out of range.
// returns 1 if everything was OK. The return value is used as the return value from a window hook function, so
// returning 1 prevents propagating a mouse click back to Igor.
static Function Dendro_DoContextualMenuForClusters(String gname, STRUCT DendrogramDrawInfo & DDI, Variable dendroType, Variable dendroRowNumber)
	Wave dendroWave = $(DDI.dendrogramWaveName)
	if (dendroRowNumber < 0 || dendroRowNumber >= DimSize(dendroWave, 0))
		return 0
	endif
	
	Variable retval = 0
	Variable doingColor = 0
	
	Wave colorNumbers = Dendro_AnalyzeForClusters(dendroWave, DDI.cutValue)
	Variable leafNumber = dendroWave[dendroRowNumber][3]
	Variable clusterNumber = colorNumbers[leafNumber][1]
	Wave/Z colorWave = $DDI.clusterColorWavePath
	Wave/Z lsizeWave = $DDI.clusterLineSizeWavePath
	Wave/Z lstyleWave = $DDI.clusterLineStyleWavePath
	if (WaveExists(colorWave) && WaveExists(lsizeWave) && WaveExists(lstyleWave))
		clusterNumber -= 1
		if (clusterNumber >= 0)
			retval = 1
			
			Variable red = colorWave[clusterNumber][0]
			Variable green = colorWave[clusterNumber][1]
			Variable blue = colorWave[clusterNumber][2]
			Variable lsize = lsizeWave[clusterNumber]
			Variable lstyle = lstyleWave[clusterNumber]
			String menudef = ""
			sprintf menudef, "*COLORPOP*(%d,%d,%d);*LINESTYLEPOP*(%d);%g;", red, green, blue, lstyle, lsize
			SetWindow $gname, UserData(DENDRO_MENUDEFS)=menudef
			PopupContextualMenu/N "ClusterStylePop"
			if (V_flag >= 0)
				switch (V_kind)
					case 10:			// color pop
						colorWave[clusterNumber][0] = V_red
						colorWave[clusterNumber][1] = V_green
						colorWave[clusterNumber][2] = V_blue
						colorWave[clusterNumber][3] = V_alpha
						if (DDI.colorClusters ==0)
							DDI.colorClusters=1
							if (WinType(gname+"#ModifyDendrogramPanel") == 7)
								CheckBox Dendro_ModPanel_ColorClustersCheck, win=$(gname+"#ModifyDendrogramPanel#ClustersTab"), value=1
							endif
						endif
						doingColor = 1
						break
					case 6:			// line style
						lstyleWave[clusterNumber] = V_flag
						if (DDI.useClusterLineStyles ==0)
							DDI.useClusterLineStyles=1
							if (WinType(gname+"#ModifyDendrogramPanel") == 7)
								CheckBox Dendro_ModPanel_ClusterLineStylesCheck, win=$(gname+"#ModifyDendrogramPanel#ClustersTab"), value=1
							endif
						endif
						break
					case 0:			// "normal" either the line size menu or the "Default Style" item in the line styles menu
						StrSwitch(S_selection)
							case "Default Style":
								lstyleWave[clusterNumber] = -1
								DDI.useClusterLineStyles = 1
								break;
							case "Default Color":
								colorWave[clusterNumber][] = 0
								DDI.colorClusters=1
								doingColor = 1
								break;
							default:
								// must be one of the line size entries
								Variable size = str2num(S_selection)
								lsizeWave[clusterNumber] = numtype(size) ? -1 : size
								if (DDI.useClusterLineSizes ==0)
									DDI.useClusterLineSizes=1
									if (WinType(gname+"#ModifyDendrogramPanel") == 7)
										CheckBox Dendro_ModPanel_ClusterLineSizesCheck, win=$(gname+"#ModifyDendrogramPanel#ClustersTab"), value=1
									endif
								endif
								break;
						endswitch
						break
				endswitch
				Dendro_RedrawNodeLinesForStructure(gname, DDI)
				Dendro_RedrawLeafLabelsForStructure(gname, DDI)
				if (doingColor)
					if (Dendro_HasClusterNumbers(gname, DDI.doVertical))
						Dendro_AddClusterNumbers(gname, dendroType)				// will pre-erase the labels, too
					endif
				endif
			endif
		endif
	endif
	
	return retval
end

static Function Dendro_GraphWindowMouseClickHook(STRUCT WMWinHookStruct & s)
	Variable retval = 0
	if (s.eventCode == 3)			// mouse down
		if (s.eventMod & 16)		// contextual click
			String gname = s.winName
			Variable clusterPos
			Variable dendroRowNumber
			if (Dendro_GraphHasSingleDendrogram(gname))
				STRUCT DendrogramDrawInfo DDI
				Dendro_FillStructureForGraph(gname, DDI, DendroTypeSingle)

				Variable valid = 0
				if (DDI.doVertical)
					clusterPos = AxisValFromPixel(gname, "bottom", s.mouseLoc.h)
					Variable vpos = AxisValFromPixel(gname, "left", s.mouseLoc.v)
					GetAxis/W=$gname/Q left
					valid = vpos > V_max
				else
					clusterPos = AxisValFromPixel(gname, "left", s.mouseLoc.v)
					Variable hpos = AxisValFromPixel(gname, "bottom", s.mouseLoc.h)
					GetAxis/W=$gname/Q bottom
					valid = hpos < V_min
				endif
				if (valid)
					dendroRowNumber = floor(clusterPos+0.5)		// 0.5 for axis range for an image pixel
					retval = Dendro_DoContextualMenuForClusters(gname, DDI, DendroTypeSingle, dendroRowNumber)
				endif
			elseif (DDendro_GraphHasDoubleDendrogram(gname))
				STRUCT DoubleDendroDrawInfo DDDI
				DDendro_FillStruct(gname, DDDI)
				GetAxis/W=$gname/Q bottom
				Variable bottommin = V_min
				Variable bottommax = V_max
				GetAxis/W=$gname/Q left
				Variable leftmin = V_min
				Variable leftmax = V_max
				Variable clusterPosBottom = AxisValFromPixel(gname, "bottom", s.mouseLoc.h)
				Variable clusterPosLeft = AxisValFromPixel(gname, "left", s.mouseLoc.v)
				Variable validLeft=0
				Variable validBottom=0
				if (clusterPosBottom > bottomMin && clusterPosBottom < bottomMax)
					validBottom = 1
				endif
				if (clusterPosLeft > leftMin && clusterPosLeft < leftMax)
					validLeft = 1
				endif
				
				if (validLeft && !validBottom)
					dendroRowNumber = floor(clusterPosLeft+0.5)		// 0.5 for axis range for an image pixel
					retval = Dendro_DoContextualMenuForClusters(gname, DDDI.colsDDI, DendroTypeH, dendroRowNumber)
				elseif (validBottom && !validLeft)
					dendroRowNumber = floor(clusterPosBottom+0.5)		// 0.5 for axis range for an image pixel
					retval = Dendro_DoContextualMenuForClusters(gname, DDDI.rowsDDI, DendroTypeV, dendroRowNumber)
				endif
			endif
		endif
	endif

	return retval
end

Function/WAVE Dendro_MakeFreeClusterColorWave()
	Make/O/N=(0,4)/FREE colors
	// Make a nice set of colors that are visually distinct, 
	// some attempt has been made to make them good for at least red-green color blindness.
	// The user can edit them if they want.
	// {0,0,0,0} means "use the default line color". That is, use the line color set by labelColorR, labelColorG, labelColorB, labelColorA

	colors[0][0] = {0,62965,37265,59110,15420,65535,17990,61680,53970,64250,0,56540,43690,65535,32896,43690,32896,65535,0,32896}
	colors[0][1] = {33410,33410,7710,6425,46260,57825,61680,12850,62965,48830,32896,48830,28270,64250,0,65535,32896,55255,0,32896}
	colors[0][2] = {51400,12336,46260,19275,19275,6425,61680,59110,15420,54484,32896,65535,10280,51400,0,50115,0,46260,32896,32896}
	colors[][3] = 65535		// alpha defaults to opaque
	
	return colors
end

// The returned wave reference needs to be used to set the clusterColorWavePath in the DendrogramDrawInfo structure.
// That means also creating the String global in the correct data folder
// That is left to the caller to allow any structure to be used
static Function/WAVE Dendro_MakeDefaultClusterColorWave(DFREF df)

	Wave freecolors = Dendro_MakeFreeClusterColorWave()
	
	Duplicate/O freecolors, df:ClusterColors/WAVE=colors
	
	return colors
end

static Function/WAVE Dendro_MakeDefaultLineStyleWave(DFREF df)
	Make/O/N=17 df:ClusterStyles/WAVE=styles
	styles = -1			// -1 means "use the overall line style setting from STRUCT DendrogramDrawInfo.lineStyle
	return styles
end

static Function/WAVE Dendro_MakeDefaultLineSizeWave(DFREF df)
	Make/O/N=17 df:ClusterLineSizes/WAVE=sizes
	sizes = -1			// -1 means "use the overall line size setting from STRUCT DendrogramDrawInfo.lineStyle
	return sizes
end

Function Dendro_ReorderDataMatrix(Wave inputMatrix, Wave reorderedMatrix, Wave dendrowave)
	reorderedMatrix = inputMatrix[dendroWave[p][3]][q]
	Variable i
	for (i = 0; i < DimSize(inputMatrix, 0); i++)
		SetDimLabel 0, i, $GetDimLabel(inputMatrix, 0, dendroWave[i][3]), reorderedMatrix
	endfor
end

// dendroWave is the dendrogram wave output by the HCluster operation.
// datawave is either a square distance matrix, or a multi-column wave 
//		in which the rows are vectors of multidimensional data. It was the input to HCluster.
// labels is a text wave with a row for each row in datawave. The contents of each cell will
//		be used to make labels for the leaves of the dendrogram.
// clusterCutVal is the distance at which you wish to make a "cut". That is, nodes at a distance
//		less than clusterCutVal that are connected to a node at a distance greater than clusterCutVal
//		are considered to be the top node of a cluster. If you provide a color wave via the groupcolors
//		optional parameter, then thos clusters will be given colors corresponding to rows in groupcolors.
//		If zero, no clusters will be found. Well, distance can't be negative!
// doVertical, if non-zero, produces a dendrogram at the top of the graph window with branches proceeding downward.
// 	If zero, the tree is on the left with branching proceeding left to right.
// groupcolors is a three-column wave of RGB values used to color clusters identified in accordance with clusterCutVal.
Function PlotDendrogram(WAVE dendroWave, WAVE datawave, String labelWavePath, Variable doVertical)

	Display
	String gname = S_name
	
	DFREF saveDF = GetDataFolderDFR()
	String DFforThisGraph = "DendrogramDF_"+NameOfWave(dendroWave)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S DendroGram
	if (DataFolderExists(DFforThisGraph))
		DFforThisGraph = UniqueName(DFforThisGraph+"_", 11, 0)
	endif
	NewDataFolder/O/S $DFforThisGraph
	DFREF gDF = GetDataFolderDFR()
	
	STRUCT DendrogramDrawInfo DDI
	structFill/AC=1 DDI
	Dendro_SetStructDefaults(DDI)
	DDI.dendrogramDataWave = GetWavesDataFolder(datawave, 2)
	DDI.dendrogramWaveName = GetWavesDataFolder(dendroWave, 2)
	DDI.dendrogramLabelWave = ""
	Wave/T/Z labels = $labelWavePath
	if (WaveExists(labels))
		DDI.dendrogramLabelWave = GetWavesDataFolder(labels, 2)
	elseif(CmpStr(labelWavePath, LabelsDimLabelsString) == 0)
		DDI.dendrogramLabelWave = LabelsDimLabelsString
	endif
	DDI.doVertical = doVertical

	String infostring = ""
	infostring += "DendroDF" + ":" + DFforThisGraph + "\r"
	SetWindow $gname, UserData($DendroInfoUD)=infostring
	
	Dendro_LoadSettingsFromPrefs(gname)
	
	WAVE colors = Dendro_MakeDefaultClusterColorWave(GetDataFolderDFR())
	DDI.clusterColorWavePath = GetWavesDataFolder(colors, 2)
	
	Wave styles = Dendro_MakeDefaultLineStyleWave(GetDataFolderDFR())
	String/G clusterLineStyleWavePath = GetWavesDataFolder(styles, 2)
	SVAR DDI.clusterLineStyleWavePath = clusterLineStyleWavePath
	
	Wave sizes = Dendro_MakeDefaultLineSizeWave(GetDataFolderDFR())
	String/G clusterLineSizeWavePath = GetWavesDataFolder(sizes, 2)
	SVAR DDI.clusterLineSizeWavePath = clusterLineStyleWavePath
	
	SetDataFolder saveDF

	Duplicate/O datawave, gDF:$(NameOfWave(datawave)+"_ordered")/WAVE=dwave
	DDI.ReorderedDataWave = GetWavesDataFolder(dwave, 2)
	Dendro_ReorderDataMatrix(datawave, dwave, dendroWave)
	AppendImage dwave
	Variable dendroSpace = DDI.dendroMargin + DDI.labelImageBuffer
	if (doVertical)
		dendroSpace = 1 - dendroSpace
		ModifyGraph/W=$gname axisEnab[left]={0, dendroSpace}
	else
	// We do a SwapXY here because Igor plots image rows along the X axis, but that means that
	// the vectors of data are arranged vertically, and we are drawing a horizontal dendrogram
		ModifyGraph/W=$gname SwapXY=1
		ModifyGraph/W=$gname axisEnab[bottom]={dendroSpace,1}
	endif
	ModifyGraph/W=$gname noLabel=2,axThick=0
	ModifyImage/W=$gname $NameOfWave(dwave) ctab={*,*,YellowHot256,0}
	
	Variable npnts = DimSize(datawave, 0)
	
	WAVE clusterNumbers = Dendro_AnalyzeForClusters(dendroWave, 0)
	
	Dendro_DrawLeafLabels(gname, DDI)
	
	DoUpdate
	
	WAVE labelLengths = Dendro_MeasureLabels(gname, DDI, DimSize(dendroWave, 0), doVertical)
	labelLengths += DDI.labelBuffer + DDI.labelImageBuffer
	
	Dendro_DrawNodeLines(gname, dendroWave, labelLengths, clusterNumbers, DDI)
	
	Dendro_CreateFormulaForLabelUpdate(gname, gDF, DendroTypeSingle)
	
	SetWindow $gname, Hook(WMDendrogramHook)=HClusterDendrogramProcs#Dendro_DendroMaintenanceHook
	SetWindow $gname, Hook(WMDendroMouseHook)=HClusterDendrogramProcs#Dendro_GraphWindowMouseClickHook
end

// Columns 0 and 1 of the dendrogram wave contain node numbers of the nodes connected to the
// node represented by the current row (currentNode) of the wave.
// Node numbers > 0 are references within the dendrogram wave, thus are group nodes.
// Node numbers < 0 are references to the vector data rows.
// Thus, if the node number is < 0, then we have gotten to a leaf node and it is time to stop recursing.
// If the node number is > 0, we are still working on a non-leaf node and we need to recursively follow
// the node until it gets to a negative node. Note that a given node (row) can have a mix of negative and
// non-negative nodes.
static Function Dendro_RecursivelyFollowNodes(Wave dendroW, Wave colornumbers, Variable colornumber, Variable currentNode)
	Variable node1 = dendroW[currentNode][0]
	Variable node2 = dendroW[currentNode][1]
	
	colorNumbers[currentNode][0] = colornumber
	if (node1 > 0)
		Dendro_RecursivelyFollowNodes(dendroW, colornumbers, colornumber, node1-1)
	else
		colornumbers[abs(node1)-1][1] = colornumber
	endif
	if (node2 > 0)
		Dendro_RecursivelyFollowNodes(dendroW, colornumbers, colornumber, node2-1)
	else
		colornumbers[abs(node2)-1][1] = colornumber
	endif
	
	return 0
end

// Returns a free wave constructed with two columns: column 0 holds cluster numbers for non-leaf nodes,
// column 1 contains cluster numbers for leaf nodes. To get the cluster number for a given node from the
// dendrogram wave columns 1 and 2, if the node number is negative, it is a leaf node. Look up row
// abs(node)-1 and find the cluster number in column 1. If the node number is positive, look it up in
// row number (node-1) and column zero. Column 0 may hold zeroes indicating a node that is not in a cluster.
// That is, a node whose distance value is larger than the cut line value. All leaf nodes should be at a
// distance that is less than the cut value, so there should be no leaf nodes that aren't in a cluster,
// though it might be a cluster with just the one leaf node.
// "color numbers" are the same as cluster numbers.
Function/WAVE Dendro_AnalyzeForClusters(Wave dendroW, Variable cutValue)
	Variable nrows = DimSize(dendroW, 0)
	Variable lastRow = nrows-2
	Make/N=(nrows,2)/FREE colornumbers=0
	
	Variable i
	Variable firstColorNode = -1
	// The "last" row contains the largest inter-node distance.
	// Here, we search from there to find the most distant node that is less than the cut value.
	// That node will be given color number zero, and then we need to track down all the nodes
	// that are connected to that node, in the direction of lesser distance (which simply means
	// going upward in the dendrogram wave rows).
	for (i = lastRow; i >= 0; i--)
		if (dendroW[i][2] < cutValue)
			firstColorNode = i
			break
		endif
	endfor
	
	// The color number wave is filled with zeroes to start with. Color numbers are > 0.
	Variable colorNumber = 1
	if (firstColorNode >= 0)
		do
			// as we move upward in the dendrogram wave, if the color number for a given row is zero,
			// it means we haven't given it a color number yet, and we should commence to follow that
			// node through the tree.
			if (colorNumbers[firstColorNode][0] == 0)
				Dendro_RecursivelyFollowNodes(dendroW, colornumbers, colorNumber, firstColorNode)
				colorNumber += 1		// found all the nodes for a given color number, increment to the next
			endif
			firstColorNode -= 1		// move upward in the dendrogram wave
		while(firstColorNode >= 0)
	endif
	
	// The recursive search above doesn't find a single node that is its own cluster.
	// That is, a single leaf node that connects to the dendrogram at a higher distance
	// value than the cut value. But they are left in the colornumbers wave column 1 as
	// zero (no cluster). So here we look for left-overs and assign them their very own
	// cluster number.
	for (i = 0; i < nrows; i++)
		if (colornumbers[i][1] == 0)
			colornumbers[i][1] = colorNumber
			colorNumber += 1
		endif
	endfor
	
	return colornumbers
end

// Creates a cluster number wave for a given cut value. Could be used to explore
// results of different cut values on clustering without altering the dendrogram graph.
Function Dendro_SaveClusterWave(Wave dendroW, Variable cutValue)
	WAVE cw = Dendro_AnalyzeForClusters(dendroW, cutValue)
	Duplicate/O cw, DendroColorWave
end

// Makes a cluster number wave reflecting the current settings for a dendrogram
// in the named graph. Works only for a graph containing a single dendrogram
// Really, this is for debugging
static Function Dendro_ExtractClusterNumbers(String gname)
	STRUCT DendrogramDrawInfo DDI
	Dendro_FillStructureForGraph(gname, DDI, DendroTypeSingle)

	Wave dendroWave = $(DDI.dendrogramWaveName)
	Wave w = Dendro_AnalyzeForClusters(dendroWave, DDI.cutValue)
	Duplicate/O w, :$(gname+"_colorNumbers")
end

// *** Double dendrogram support ***

// ************ double dendrogram **************
//
// Given a matrix with N rows and M columns, applies HCluster to the rows
// and to the columns of the matrix. Creates a reordered matrix for display
// with rows along the horizontal axis and columns along the vertical axis.
// Draws dendrogram node lines and labels for each direction on the top (rows)
// and the left (columns)

static Structure DoubleDendroDrawInfo

	STRUCT DendrogramDrawInfo rowsDDI
	STRUCT DendrogramDrawInfo colsDDI
	String DataFolderPath
	String graphName
	
endStructure

// ***** double dendrogram control panel *****
static Function DisplayDoubleDendroControlPanel()
	if (WinType("DoubleDendroControlPanel") == 7)
		DoWindow/F DoubleDendroControlPanel
	else
		fDoubleDendroControlPanel()
	endif
end

static Function fDoubleDendroControlPanel()
	String pname = "DoubleDendroControlPanel"
	String fmt = "NewPanel/K=1/N=DoubleDendroControlPanel/W=(%s)"
	Execute WC_WindowCoordinatesSprintf(pname, fmt, 150, 50, 485, 475, 1)

	ModifyPanel/W=$pname fixedSize=1
	DoWindow/T $pname "Compute Two-Way Dendrogram"
	
	TitleBox DDendro_DataMatrixMenuTitle, win=$pname,pos={37.00,20.00},size={95.00,15.00}
	TitleBox DDendro_DataMatrixMenuTitle, win=$pname,title="Raw Data Matrix:",fSize=12,frame=0
	Button DDendro_RawDataMatrix, win=$pname,pos={52.00,42.00},size={225.00,20.00},title="Data Matrix"
	MakeButtonIntoWSPopupButton(pname, "DDendro_RawDataMatrix", "")
	PopupWS_MatchOptions(pname, "DDendro_RawDataMatrix", listoptions="DIMS:2,CMPLX:0,TEXT:0,WAVE:0,DF:0")
	String fullpath = StringFromList(0, WaveList("*", ";", "DIMS:2,CMPLX:0,TEXT:0,WAVE:0,DF:0"))
	PopupWS_setSelectionFullPath(pname, "DDendro_RawDataMatrix", fullpath)

	CheckBox DDendro_Panel_TransposeCheckbox, win=$pname,pos={54.00,69.00},size={172.00,16.00}
	CheckBox DDendro_Panel_TransposeCheckbox, win=$pname,title="Transpose Data Matrix First"
	CheckBox DDendro_Panel_TransposeCheckbox, win=$pname,fSize=12,value= 0	

	TitleBox DDendro_RowsLabelsMenuTitle, win=$pname,pos={37.00,96.00},size={131.00,15.00}
	TitleBox DDendro_RowsLabelsMenuTitle, win=$pname,title="Wave With Row Labels:",fSize=12
	TitleBox DDendro_RowsLabelsMenuTitle, win=$pname,frame=0
	Button DDendro_SelectRowsLabels, win=$pname,pos={52.00,117.00},size={225.00,20.00}
	Button DDendro_SelectRowsLabels, win=$pname,title="Rows Labels"
	MakeButtonIntoWSPopupButton(pname, "DDendro_SelectRowsLabels", "")
	PopupWS_AddSelectableString(pname, "DDendro_SelectRowsLabels", LabelsNoneString)
	PopupWS_AddSelectableString(pname, "DDendro_SelectRowsLabels", LabelsDimLabelsString)
	PopupWS_MatchOptions(pname, "DDendro_SelectRowsLabels", listoptions="TEXT:1,DIMS:1")

	TitleBox DDendro_ColumnsLabelsMenuTitle, win=$pname,pos={37.00,152.00},size={150.00,15.00}
	TitleBox DDendro_ColumnsLabelsMenuTitle, win=$pname,title="Wave With Column Labels:"
	TitleBox DDendro_ColumnsLabelsMenuTitle, win=$pname,fSize=12,frame=0
	Button DDendro_SelectColumnsLabels, win=$pname,pos={52.00,173.00},size={225.00,20.00}
	Button DDendro_SelectColumnsLabels, win=$pname,title="Columns Labels"
	MakeButtonIntoWSPopupButton(pname, "DDendro_SelectColumnsLabels", "")
	PopupWS_AddSelectableString(pname, "DDendro_SelectColumnsLabels", LabelsNoneString)
	PopupWS_AddSelectableString(pname, "DDendro_SelectColumnsLabels", LabelsDimLabelsString)
	PopupWS_MatchOptions(pname, "DDendro_SelectColumnsLabels", listoptions="TEXT:1,DIMS:1")
	
	TitleBox DDendro_NameForResultsTitle, win=$pname,pos={37.00,211.00},size={169.00,15.00}
	TitleBox DDendro_NameForResultsTitle, win=$pname,title="Name for Results Data Folder:"
	TitleBox DDendro_NameForResultsTitle, win=$pname,fSize=12,frame=0
	SetVariable DDendro_ResultsDFname, win=$pname,pos={77.00,231.00},size={197.00,18.00},bodyWidth=197
	SetVariable DDendro_ResultsDFname, win=$pname,fSize=12,value= _STR:"DoubleDendro"

	TitleBox DDendro_DissimilarityMethodMenuTitle, win=$pname,pos={37.00,265.00},size={119.00,15.00}
	TitleBox DDendro_DissimilarityMethodMenuTitle, win=$pname,title="Dissimilarity Method:"
	TitleBox DDendro_DissimilarityMethodMenuTitle, win=$pname,fSize=12,frame=0
	String quote = "\""
	String menuvalue = "Euclidean;SquaredEuclidean;SEuclidean;Cityblock;Chebychev;Minkowski;"
	menuvalue += "Cosine;Canberra;BrayCurtis;Hamming;Jaccard;"
	menuvalue = quote + menuvalue + quote
	PopupMenu DDendro_DissimilarityMenu, win=$pname,pos={74.00,284.00},size={200.00,20.00},bodyWidth=200
	PopupMenu DDendro_DissimilarityMenu, win=$pname,mode=1,value= #menuvalue
	
	TitleBox DDendro_LinkageMethodMenuTitle, win=$pname,pos={37.00,320.00},size={94.00,15.00}
	TitleBox DDendro_LinkageMethodMenuTitle, win=$pname,title="Linkage Method:",fSize=12,frame=0
	PopupMenu DDendro_LinkageMenu, win=$pname,pos={74.00,339.00},size={200.00,20.00},bodyWidth=200
	PopupMenu DDendro_LinkageMenu, win=$pname,mode=2,value= #"\"Complete;Average;Single;Weighted;Centroid;Median;Ward;\""
	
	Button DDendro_ComputeAndPlotButton, win=$pname,pos={37.00,382.00},size={50.00,20.00},proc=HClusterDendrogramProcs#DDendro_ComputeAndPlotButtonProc
	Button DDendro_ComputeAndPlotButton, win=$pname,title="Do It"
	
	Button DDendro_HelpButton,pos={245.00,382.00},size={50.00,20.00},proc=HClusterDendrogramProcs#DendroPanel_HelpButtonProc
	Button DDendro_HelpButton,title="Help"

	SetWindow $pname, hook(WindowCoordsHook) = WC_WindowCoordinatesNamedHook
end

static Function DDendro_ComputeAndPlotButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			String pname = ba.win
			String dataName = PopupWS_GetSelectionFullPath(pname, "DDendro_RawDataMatrix")
			Wave/Z dataMatrix = $dataName
			if (!WaveExists(dataMatrix))
				DoAlert 0, "No selection for Raw Data Matrix"
				return -1 
			endif
			
			dataName = PopupWS_GetSelectionFullPath(pname, "DDendro_SelectRowsLabels")
			String rowsLabels = dataName
			
			dataName = PopupWS_GetSelectionFullPath(pname, "DDendro_SelectColumnsLabels")
			String colsLabels = dataName
			
			ControlInfo/W=$pname DDendro_ResultsDFname
			String resultsDFName = S_value
			if (strlen(resultsDFName) == 0)
				DoAlert 0, "Result Data Folder name is blank"
				return -1
			endif
			
			ControlInfo/W=$pname DDendro_DissimilarityMenu
			String dissMethodName = S_value
			
			ControlInfo/W=$pname DDendro_LinkageMenu
			String linkageName = S_value

			ControlInfo/W=$pname DDendro_Panel_TransposeCheckbox
			Variable doTranspose = V_Value
			ComputeAndPlotDoubleDendrogram(dataMatrix, doTranspose, rowsLabels, colsLabels, resultsDFName, dissMethodName, linkageName)
			break
	endswitch

	return 0
End

// Function to compute two hierarchical dendrograms on a single matrix, one for rows and one for columns
// Because the HCluster operation offers only to cluster on rows that represent data vectors, this requires
// calling HCluster on the original matrix, and also on the transpose of the matrix.
static Function/DF ComputeDoubleDendrogram(Wave dataMatrix, String baseWName, String DFNameForResults, String DissMethod, String LinkMethod, Variable overwrite)

	if (DataFolderExists(DFNameForResults))
		if (!overwrite)
			DFREF badDF = $""
			return badDF
		endif
	endif
	
	DFREF savedDF = GetDataFolderDFR()
	NewDataFolder/O/S $DFNameForResults
	DFREF newDF = GetDataFolderDFR()
	
	HCluster/O/LINK=$LinkMethod/DISS=$DissMethod/DEST=$(baseWName+"_RowsDendro") dataMatrix
	Wave rowsDendro = $(baseWName+"_RowsDendro")
	
	Duplicate/FREE dataMatrix, dataMatrix_T
	MatrixTranspose dataMatrix_T
	HCluster/O/LINK=$LinkMethod/DISS=$DissMethod/DEST=$(baseWName+"_ColsDendro") dataMatrix_T
	Wave colsDendro = $(baseWName+"_ColsDendro")
	
	Duplicate/O dataMatrix, $(baseWName+"_reordered")/WAVE=reordered
	reordered = dataMatrix[rowsDendro[p][3]][colsDendro[q][3]]
	
	SetDataFolder savedDF
	
	return newDF
end

static Function DDendro_DrawNodeLinesAndLabels(STRUCT DoubleDendroDrawInfo & DDDI)
	String gname = DDDI.graphName
	
	Wave dendroWave = $(DDDI.rowsDDI.dendrogramWaveName)
	Wave colorNumbers = Dendro_AnalyzeForClusters(dendroWave, DDDI.rowsDDI.cutvalue)

	Wave labelLengths = Dendro_MeasureLabels(gname, DDDI.rowsDDI, DimSize(dendroWave, 0), DDDI.rowsDDI.doVertical)
	labelLengths += DDDI.rowsDDI.labelBuffer + DDDI.rowsDDI.labelImageBuffer
	
	Dendro_DrawNodeLines(gname, dendroWave, labelLengths, colorNumbers, DDDI.rowsDDI)
	Dendro_DrawLeafLabels(gname, DDDI.rowsDDI)
	
	Wave dendroWave = $(DDDI.colsDDI.dendrogramWaveName)
	Wave colorNumbers = Dendro_AnalyzeForClusters(dendroWave, DDDI.colsDDI.cutvalue)
	Wave labelLengths = Dendro_MeasureLabels(gname, DDDI.colsDDI, DimSize(dendroWave, 0), DDDI.colsDDI.doVertical)
	labelLengths += DDDI.colsDDI.labelBuffer + DDDI.colsDDI.labelImageBuffer

	Dendro_DrawNodeLines(gname, dendroWave, labelLengths, colorNumbers, DDDI.colsDDI)
	Dendro_DrawLeafLabels(gname, DDDI.colsDDI)
end

static Function DDendro_FillStruct(String gname, STRUCT DoubleDendroDrawInfo & DDDI)
	String DDDIuserdata = GetUserData(gname, "", DoubleDendroUD)
	if (strlen(DDDIuserdata) == 0)
		return -1		// return value is meaningless, but -1 seems like "error"
	endif
	
	String dfname = StringByKey("DATAFOLDER", DDDIuserdata, "=", ";")
	DFREF basedf = $dfname
	String basename = StringByKey("BASENAME", DDDIuserdata, "=", ";")
	DDDI.graphName = gname
	
	DFREF rowsdf = basedf:RowsDendroDF
	StructFill/SDFR=rowsdf DDDI.rowsDDI
	DFREF colsdf = basedf:ColsDendroDF
	StructFill/SDFR=colsdf DDDI.colsDDI
end

static Function DDendro_RedrawNodeLinesAndLabels(String gname)
	STRUCT DoubleDendroDrawInfo DDDI
	DDendro_FillStruct(gname, DDDI)

	String nodeLinesGroupName = nodeLinesGroup + "_V"
	DrawAction/W=$(gname) GetGroup=$nodeLinesGroupName
	if (V_flag)
		DrawAction/W=$(gname) GetGroup=$nodeLinesGroupName,delete
	endif
	string labelsGroupName = leafLabelsGroup + "_V"
	DrawAction/W=$(gname) GetGroup=$labelsGroupName
	if (V_flag)
		DrawAction/W=$(gname) GetGroup=$labelsGroupName,delete
	endif

	nodeLinesGroupName = nodeLinesGroup + "_H"
	DrawAction/W=$(gname) GetGroup=$nodeLinesGroupName
	if (V_flag)
		DrawAction/W=$(gname) GetGroup=$nodeLinesGroupName,delete
	endif
	labelsGroupName = leafLabelsGroup + "_H"
	DrawAction/W=$(gname) GetGroup=$labelsGroupName
	if (V_flag)
		DrawAction/W=$(gname) GetGroup=$labelsGroupName,delete
	endif

	DDendro_DrawNodeLinesAndLabels(DDDI)
	
	return 0
end

static Function GraphMacroExists(String graphName)
	return exists("ProcGlobal#"+graphName)
End

static Function/S DDendro_axisInfoString(String gname)
	String axInfo=""
	Variable vmin, vmax, hmin, hmax
	GetAxis/W=$gname/Q left
	vmin = V_min
	vmax = V_max
	GetAxis/W=$gname/Q bottom
	hmin = V_min
	hmax = V_max
	
	sprintf axInfo, "%g;%g;%g;%g;", vmin, vmax, hmin, hmax
	
	return axInfo
end

static Function DDendro_MaintenanceHook(STRUCT WMWinHookStruct & s)

	String gname = s.winName
	strswitch(s.eventName)
		case "resize":
			DDendro_RedrawNodeLinesAndLabels(gname)
			break
		case "killvote":
			if (WinType(gname+"#ModifyDendrogramPanel") == 7)
				KillWindow $	(gname+"#ModifyDendrogramPanel")
			endif
			break
		case "kill":
			// On Mac OS X, there is no guarantee that the graphName is the top-most window or top-most double dendrogram graph!
			Variable recreationMacroExists = GraphMacroExists(gname)
			if (!recreationMacroExists)
				String DDDIuserdata = GetUserData(gname, "", DoubleDendroUD)
				if (strlen(DDDIuserdata) == 0)
					return -1		// return value is meaningless, but -1 seems like "error"
				endif

				String dfname = StringByKey("DATAFOLDER", DDDIuserdata, "=", ";")
				DFREF basedf = $dfname
				if (DataFolderRefStatus(basedf) == 1)
					// Need to delete the inner data folders first because they contain the variable updateRowLabelsVar that
					// is the dummy dependent variable for a dependency that updates the graph if the row/column labels change
					Execute/P/Q "KillDataFolder "+GetDataFolder(1, basedf)+"ColsDendroDF"		// GetDataFolder(1,...) puts ":" at the end
					Execute/P/Q "KillDataFolder "+GetDataFolder(1, basedf)+"RowsDendroDF"
					Execute/P/Q "KillDataFolder "+GetDataFolder(1, basedf)
				endif
			endif
			break
		case "modified":
			// axis ranges is one of a quite large number of "modifications" that can trigger this event.
			// So test to see if the axis ranges have changed, and redraw if they have. 
			String aInfo = GetUserData(gname, "", "DDendroAxisInfo")
			string newinfo = DDendro_axisInfoString(gname)
			Variable doRedraw = 0
			if (strlen(aInfo) == 0 || CmpStr(aInfo, newinfo) != 0)
				doRedraw = 1
				SetWindow $gname, userdata(DDendroAxisInfo)=newinfo
				DDendro_RedrawNodeLinesAndLabels(gname)
			endif
			break
	endswitch
end

Function ComputeAndPlotDoubleDendrogram(Wave rawMatrix, Variable transpose, String rowsLabels, String colsLabels, String DFNameForResults, String DissMethod, String LinkMethod)

	DFREF resultsDF = $DFNameForResults
	if (DataFolderRefStatus(resultsDF) != 0)
		DoAlert 0, "A data folder with the name "+DFNameForResults+" already exists."
		return -1
	endif
	Wave dataMatrix = rawMatrix
	if (transpose)
		Duplicate/FREE rawMatrix, tmatrix
		MatrixTranspose tmatrix
		Wave dataMatrix = tmatrix
		string temp = rowsLabels
		rowsLabels = colsLabels
		colsLabels = temp
	endif
	String baseWName = NameOfWave(rawMatrix)
	resultsDF = ComputeDoubleDendrogram(dataMatrix, baseWName, DFNameForResults, DissMethod, LinkMethod, 0)
	Wave reorderedmatrix = resultsDF:$(baseWName+"_reordered")
	Wave colsdendrowave = resultsDF:$(baseWName+"_ColsDendro")
	Wave rowsdendrowave = resultsDF:$(baseWName+"_RowsDendro")
	Variable i
	Variable originalDim = transpose ? 1 : 0
	for (i = 0; i < DimSize(dataMatrix, 0); i++)
		SetDimLabel 0, i, $GetDimLabel(rawMatrix, originalDim, rowsdendrowave[i][3]), reorderedmatrix
	endfor
	originalDim = transpose ? 0 : 1
	for (i = 0; i < DimSize(dataMatrix, 1); i++)
		SetDimLabel 1, i, $GetDimLabel(rawMatrix, originalDim, colsdendrowave[i][3]), reorderedmatrix
	endfor

	// Create substructure with data for drawing the rows dendrogram
	STRUCT DoubleDendroDrawInfo DDDI
	NewDataFolder resultsDF:RowsDendroDF
	DFREF rowsDF  = resultsDF:RowsDendroDF
	StructFill/AC=1/SDFR=rowsDF DDDI.rowsDDI
	Dendro_SetStructDefaults(DDDI.rowsDDI)
	DDDI.rowsDDI.dendrogramDataWave = GetWavesDataFolder(dataMatrix, 2)
	DDDI.rowsDDI.ReorderedDataWave = GetWavesDataFolder(reorderedmatrix, 2)
	DDDI.rowsDDI.dendrogramLabelWave = ""
	Wave/T/Z rowLabelsW = $rowsLabels
	if (WaveExists(rowLabelsW))
		DDDI.rowsDDI.dendrogramLabelWave = GetWavesDataFolder(rowLabelsW, 2)
	elseif(CmpStr(rowsLabels, LabelsDimLabelsString) == 0)
		DDDI.rowsDDI.dendrogramLabelWave = LabelsDimLabelsString
	endif
	DDDI.rowsDDI.dendrogramWaveName = GetWavesDataFolder(rowsdendrowave, 2)
	WAVE colors = Dendro_MakeDefaultClusterColorWave(rowsDF)
	DDDI.rowsDDI.clusterColorWavePath = GetWavesDataFolder(colors, 2)
	Wave styles = Dendro_MakeDefaultLineStyleWave(rowsDF)
	String/G rowsDF:clusterLineStyleWavePath = GetWavesDataFolder(styles, 2)
	SVAR DDDI.rowsDDI.clusterLineStyleWavePath = rowsDF:clusterLineStyleWavePath
	Wave sizes = Dendro_MakeDefaultLineSizeWave(rowsDF)
	String/G rowsDF:clusterLineSizeWavePath = GetWavesDataFolder(sizes, 2)
	SVAR DDDI.rowsDDI.clusterLineSizeWavePath = rowsDF:clusterLineStyleWavePath
	
	NewDataFolder resultsDF:ColsDendroDF
	DFREF colsDF  = resultsDF:ColsDendroDF
	StructFill/AC=1/SDFR=colsDF DDDI.colsDDI
	Dendro_SetStructDefaults(DDDI.colsDDI)
	DDDI.colsDDI.dendrogramDataWave = GetWavesDataFolder(dataMatrix, 2)
	DDDI.colsDDI.ReorderedDataWave = GetWavesDataFolder(reorderedmatrix, 2)
	DDDI.colsDDI.dendrogramLabelWave = ""
	Wave/T/Z colLabelsW = $colsLabels
	if (WaveExists(colLabelsW))
		DDDI.colsDDI.dendrogramLabelWave = GetWavesDataFolder(colLabelsW, 2)
	elseif(CmpStr(colsLabels, LabelsDimLabelsString) == 0)
		DDDI.colsDDI.dendrogramLabelWave = LabelsDimLabelsString
	endif
	DDDI.colsDDI.dendrogramWaveName = GetWavesDataFolder(colsdendrowave, 2)
	WAVE colors = Dendro_MakeDefaultClusterColorWave(colsDF)
	DDDI.colsDDI.clusterColorWavePath = GetWavesDataFolder(colors, 2)
	Wave styles = Dendro_MakeDefaultLineStyleWave(colsDF)
	String/G colsDF:clusterLineStyleWavePath = GetWavesDataFolder(styles, 2)
	SVAR DDDI.colsDDI.clusterLineStyleWavePath = colsDF:clusterLineStyleWavePath
	Wave sizes = Dendro_MakeDefaultLineSizeWave(colsDF)
	String/G colsDF:clusterLineSizeWavePath = GetWavesDataFolder(sizes, 2)
	SVAR DDDI.colsDDI.clusterLineSizeWavePath = colsDF:clusterLineStyleWavePath

	Display
	String gname = S_name
	DDDI.graphName = gname
	String userdata = "DATAFOLDER="+GetDataFolder(1, resultsDF)+";"
	userdata += "BASENAME="+baseWName+";"
	SetWindow $gname, UserData($DoubleDendroUD) = userdata
	AppendImage/W=$gname reorderedmatrix
	ModifyGraph/W=$gname noLabel=2,axThick=0
	ModifyImage/W=$gname $NameOfWave(reorderedmatrix) ctab={*,*,YellowHot256,0}
	
	Variable dendroSpace
	
	// Settings for the rows dendrogram, which is along the top with node lines and labels vertical
	DDDI.rowsDDI.doVertical = 1
	dendroSpace = DDDI.rowsDDI.dendroMargin + DDDI.rowsDDI.labelImageBuffer
	dendroSpace = 1 - dendroSpace
	ModifyGraph/W=$gname axisEnab[left]={0, dendroSpace}

	// Settings for the cols dendrogram, which is along the left with node lines and labels horizontal
	DDDI.colsDDI.doVertical = 0
	dendroSpace = DDDI.colsDDI.dendroMargin + DDDI.colsDDI.labelImageBuffer
	ModifyGraph/W=$gname axisEnab[bottom]={dendroSpace,1}

	DDendro_DrawNodeLinesAndLabels(DDDI)
	Dendro_CreateFormulaForLabelUpdate(gname, rowsDF, DendroTypeV)
	Dendro_CreateFormulaForLabelUpdate(gname, colsDF, DendroTypeH)
	
	SetWindow $gname, hook(DoubleDendroHook)=HClusterDendrogramProcs#DDendro_MaintenanceHook
	SetWindow $gname, Hook(WMDendroMouseHook)=HClusterDendrogramProcs#Dendro_GraphWindowMouseClickHook
end

Function HCluster_GetCutValueFromGraph(String gname [, Variable doVertical])

	Variable cutval = nan
	
	if (Dendro_GraphHasSingleDendrogram(gname))
		STRUCT DendrogramDrawInfo DDI
		Dendro_FillStructureForGraph(gname, DDI, DendroTypeSingle)
		cutval = DDI.cutValue
	elseif (DDendro_GraphHasDoubleDendrogram(gname))
		STRUCT DoubleDendroDrawInfo DDDI
		DDendro_FillStruct(gname, DDDI)
		if (doVertical)
			cutval = DDDI.rowsDDI.cutValue
		else
			cutval = DDDI.colsDDI.cutValue
		endif
	endif

	return cutval
end

// The functions here allow you to extract cluster matrices, node lists, and cluster averages without making a dendrogram graph.

Function/WAVE HCluster_ClusterMatrices(Wave dendroWave, Wave dataWave, Variable cutvalue, [Variable ColumnVectors, Wave/Z/T leafLabels])

	if (ParamIsDefault(ColumnVectors))
		ColumnVectors = 0
	endif
	if (ParamIsDefault(leafLabels))
		Wave/T/Z leafLabels = $""
	endif
	
	Variable dataVectorDim = ColumnVectors ? 1 : 0
	
	Variable nVectors = DimSize(dataWave, dataVectorDim)
	if (nVectors != DimSize(dendrowave, 0))
		DoAlert 0, "Dimension mismatch between dendrogram wave and data wave"
		return $""
	endif
	
	// This seems backward; the DendroType names reflect peculiarities of the internal workings
	// of Heatmap_and_Dendrogram.ipf. Sorry!
	Variable dendrotype = ColumnVectors ? DendroTypeH : DendroTypeV
	
	Wave clusternumbers = Dendro_AnalyzeForClusters(dendroWave, cutvalue)
	[Wave nodelist, Wave colorcounts] = Dendro_ClusterNodeList(clusternumbers, dendroWave, dataWave, dendrotype)
	Variable nclusters = wavemax(clusternumbers)
	Variable npnts = DimSize(dataWave, dataVectorDim)
	Variable i
	
	Make/WAVE/FREE/N=(nclusters) matrixrefs
	for (i = 0; i < nclusters; i++)
		Make/D/FREE/N=(colorcounts[i], DimSize(dataWave, 1-dataVectorDim))/O matwave
		matrixrefs[i] = matwave
	endfor
	
	Make/FREE/N=(nclusters) matrixrows=0
	for (i = 0; i < npnts; i++)
		Variable node = -(dendroWave[i][3]+1)
		Variable cnumber = Dendro_GetClusterNumberForNodeNumber(node, clusternumbers)
		Wave mat = matrixrefs[cnumber-1]
		if (dataVectorDim == 0)
			mat[matrixrows[cnumber-1]][] = dataWave[dendroWave[i][3]][q]
		else
			mat[matrixrows[cnumber-1]][] = dataWave[q][dendroWave[i][3]]
		endif

		String oneLabel = ""
		if (WaveExists(leafLabels))
			oneLabel = leafLabels[dendroWave[i][3]]
		else
			oneLabel = GetDimLabel(dataWave, dataVectorDim, dendroWave[i][3])
		endif
		if (strlen(oneLabel) == 0)
			oneLabel = "Data "
			oneLabel += SelectString(dataVectorDim, "Row ", "Col ")
			oneLabel += num2str(dendroWave[i][3])
		endif
		oneLabel = CleanupName(oneLabel, 1)		// 1 = beLiberal
		SetDimLabel 0, matrixrows[cnumber-1], $oneLabel, mat
		matrixrows[cnumber-1] += 1
	endfor
	
	return matrixrefs
end

Function HCluster_SaveClusterMatrices(String basename, Wave dendrowave, Wave dataWave, Variable cutvalue, Variable overwriteOK [, Variable ColumnVectors, Wave/Z/T leafLabels])

	if (ParamIsDefault(ColumnVectors))
		ColumnVectors = 0
	endif
	if (ParamIsDefault(leafLabels))
		Wave/T/Z leafLabels = $""
	endif
	
	Variable dataVectorDim = ColumnVectors ? 1 : 0
	
	Variable nVectors = DimSize(dataWave, dataVectorDim)
	if (nVectors != DimSize(dendrowave, 0))
		DoAlert 0, "Dimension mismatch between dendrogram wave and data wave"
		return -1
	endif

	Wave/WAVE matrixrefs = HCluster_ClusterMatrices(dendrowave, dataWave, cutvalue, ColumnVectors = ColumnVectors, leafLabels = leafLabels)
	Variable i
	String newmatname
	Variable nclusters = numpnts(matrixRefs)
	
	if (!overwriteOK)
		for (i = 0; i < nclusters; i++)
			newmatname = "M_" + basename + "_Cluster_" + num2istr(i+1)
			Wave/Z w = $newmatname
			if (WaveExists(w))
				DoAlert 0, "Output waves already exist. Perhaps turn on the Overwrite checkbox."
				return -1
			endif
		endfor
	endif
	
	for (i = 0; i < nclusters; i++)
		newmatname = "M_" + basename + "_Cluster_" + num2istr(i+1)
		Wave mat = matrixrefs[i]
		Duplicate/O mat, $newmatname
	endfor
end

Function [WAVE NodeList, WAVE/T LabelledList] HCluster_ClusterListWaves(Wave dendroWave, Wave dataWave, Variable cutValue [, Variable columnVectors, Wave/Z/T leafLabels, Variable oneDClusterList])

	if (ParamIsDefault(ColumnVectors))
		ColumnVectors = 0
	endif
	if (ParamIsDefault(leafLabels))
		Wave/T/Z leafLabels = $""
	endif
	if (ParamIsDefault(oneDClusterList))
		oneDClusterList = 0
	endif
	
	Variable dataVectorDim = ColumnVectors ? 1 : 0
	
	Variable nVectors = DimSize(dataWave, dataVectorDim)
	if (nVectors != DimSize(dendrowave, 0))
		DoAlert 0, "Dimension mismatch between dendrogram wave and data wave"
		return [$"", $""]
	endif

	Wave clusternumbers = Dendro_AnalyzeForClusters(dendroWave, cutValue)
	Variable nclusters = wavemax(clusternumbers)
	Variable i
	Variable node
	Variable cnumber
	String oneLabel
	
	// This seems like it's backward, but it's not; the DendroType names reflect peculiarities of the internal workings
	// of Heatmap_and_Dendrogram.ipf. Sorry!
	Variable dendrotype = ColumnVectors ? DendroTypeH : DendroTypeV
	
	Wave clusternumbers = Dendro_AnalyzeForClusters(dendroWave, cutValue)
	[Wave nodelist, Wave colorcounts] = Dendro_ClusterNodeList(clusternumbers, dendroWave, datawave, dendrotype)
	Variable maxClusterNodeCount = WaveMax(colorcounts)
	
	if (oneDClusterList)
		Make/FREE/N=(nVectors) ClusterNodes = NaN
		Make/FREE/T/N=(nVectors) ClusterLabels = ""

		for (i = 0; i < nVectors; i++)
			node = -(i+1)
			cnumber = Dendro_GetClusterNumberForNodeNumber(node, clusternumbers)
			ClusterNodes[i] = cnumber
			
			oneLabel = ""
			if (WaveExists(leafLabels))
				oneLabel = leafLabels[i]
			else
				oneLabel = GetDimLabel(dataWave, dataVectorDim, i)
			endif
			if (strlen(oneLabel) == 0)
				oneLabel = "Data "
				oneLabel += SelectString(dataVectorDim, "Row ", "Col ")
				oneLabel += num2str(dendroWave[i][3])
			endif
			ClusterLabels[i] = oneLabel
		endfor
	else
		Make/FREE/N=(maxClusterNodeCount, nclusters) ClusterNodes = NaN
		Make/FREE/T/N=(maxClusterNodeCount, nclusters) ClusterLabels = ""
		
		Make/FREE/N=(nclusters) matrixrows=0
		for (i = 0; i < DimSize(dendroWave, 0); i++)
			node = -(dendroWave[i][3]+1)
			cnumber = Dendro_GetClusterNumberForNodeNumber(node, clusternumbers)
			ClusterNodes[matrixrows[cnumber-1]][cnumber-1] = dendroWave[i][3]
	
			oneLabel = ""
			if (WaveExists(leafLabels))
				oneLabel = leafLabels[dendroWave[i][3]]
			else
				oneLabel = GetDimLabel(dataWave, dataVectorDim, dendroWave[i][3])
			endif
			if (strlen(oneLabel) == 0)
				oneLabel = "Data "
				oneLabel += SelectString(dataVectorDim, "Row ", "Col ")
				oneLabel += num2str(dendroWave[i][3])
			endif
	
			ClusterLabels[matrixrows[cnumber-1]][cnumber-1] = onelabel
	
			matrixrows[cnumber-1] += 1
		endfor
	endif
	
	return [ClusterNodes, ClusterLabels]
end

Function HCluster_SaveClusterListWaves(String basename, Wave dendroWave, Wave dataWave, Variable cutValue, Variable overwriteOK [, Variable columnVectors, Wave/Z/T leafLabels, Variable oneDClusterList])

	if (ParamIsDefault(ColumnVectors))
		ColumnVectors = 0
	endif
	if (ParamIsDefault(leafLabels))
		Wave/T/Z leafLabels = $""
	endif
	if (ParamIsDefault(oneDClusterList))
		oneDClusterList = 0
	endif
	
	Variable dataVectorDim = ColumnVectors ? 1 : 0
	
	Variable nVectors = DimSize(dataWave, dataVectorDim)
	if (nVectors != DimSize(dendrowave, 0))
		DoAlert 0, "Dimension mismatch between dendrogram wave and data wave"
		return -1
	endif

	[WAVE ClusterNodes, WAVE/T ClusterLabels] = HCluster_ClusterListWaves(dendroWave, dataWave, cutValue , columnVectors = columnVectors, leafLabels = leafLabels, oneDClusterList = oneDClusterList)
	String nodesname = basename+"_ClusterNodes"
	String labelsname = basename+"_ClusterLabels"
	WAVE/Z w = $nodesname
	WAVE/Z/T wt = $labelsname
	if ( (WaveExists(w) || WaveExists(wt)) && !overwriteOK )
		DoAlert 0, "Output waves already exist. Perhaps turn on the Overwrite checkbox."
		return -1
	endif
	Duplicate/O ClusterNodes, $nodesname
	Duplicate/O ClusterLabels, $labelsname
	
	return 0
end

Function/WAVE HCluster_ClusterAverageWaves(Wave dendroWave, Wave dataWave, Variable cutvalue [, Variable ColumnVectors])
	if (ParamIsDefault(ColumnVectors))
		ColumnVectors = 0
	endif

	WAVE/Z/wave matrixRefs = HCluster_ClusterMatrices(dendroWave, dataWave, cutvalue, ColumnVectors=ColumnVectors)
	if (!WaveExists(matrixRefs))
		return $""
	endif
	
	Variable nclusters = numpnts(matrixRefs)
	Make/N=(nclusters)/WAVE/FREE averefs
	
	Variable i
	for (i = 0; i < nclusters; i++)
		Wave mat = matrixRefs[i]
		MatrixOP/FREE avewave = averageCols(mat)
		Variable npnts = numpnts(avewave)
		Redimension/N=(npnts) avewave
		averefs[i] = avewave
	endfor
	
	return averefs
end

Function HCluster_ClusterAverageAndGraph(String basename, Wave dendroWave, Wave dataWave, Variable cutvalue, Variable doGraph, Variable overwriteOK [, Variable ColumnVectors])
	Wave/Z/WAVE averefs = HCluster_ClusterAverageWaves(dendroWave, dataWave, cutvalue, ColumnVectors = ColumnVectors)
	if (!WaveExists(averefs))
		return -1
	endif

	Variable nclusters = numpnts(averefs)
	Variable i
	String avename
	
	if (!overwriteOK)	
		for (i = 0; i < nclusters; i++)
			avename = basename + "_CAve_"+num2istr(i+1)
			Wave/Z w = $avename
			if (WaveExists(w))
				DoAlert 0, "Output waves already exist. Perhaps turn on the Overwrite checkbox."
				return -1
			endif
		endfor
	endif
	
	for (i = 0; i < nclusters; i++)
		avename = basename + "_CAve_"+num2istr(i+1)
		Duplicate/O averefs[i], $avename/WAVE = avewave
		averefs[i] = avewave
	endfor
	
	if (doGraph)
		Wave colors = Dendro_MakeFreeClusterColorWave()
		Display
		String gname = S_name
		for (i = 0; i < nclusters; i++)
			AppendToGraph/W=$gname averefs[i]
			ModifyGraph/W=$gname rgb[i]=(colors[i][0], colors[i][1], colors[i][2], colors[i][3])
		endfor
		Legend/W=$gname
	endif
	
	return 0
end
