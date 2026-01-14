#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version=9.01			// Shipped with Igor 9.01
#pragma IgorVersion=9.01

//*************************************************
// This procedure file contains commands to enable or disable every built-in menu item that can be
// disabled or enabled. It is not really intended to be used straight, although that is certainly possible.
// The intent is for you to use it as a source of commands to selectively disable items in the built-in
// menus. As such, you may wish to edit the file for your own uses, or copy and paste into your own
// procedure file. If you edit the file, you should make a copy and edit the copy.
//
// NOTE: These SetIgorMenuMode commands that *enable or disable* a menu ITEM (not a menu or submenu)
// are similar to the DoIgorMenu command that would *activate* the menu item.
//
// For example:
//
//	SetIgorMenuMode "Hide", "Hide All Procedure Windows", DisableItem
//
// the corresponding DoIgorMenu command is:
//
//	DoIgorMenu "Hide", "Hide All Procedure Windows"
//
//	See Also: HideIgorMenus and ShowIgorMenus.
//
//*************************************************


Function EnableDisableMenuBarMenus(Variable enable) // 0 to disable, 1 to enable
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "File", "", $Action
	SetIgorMenuMode "Edit", "", $Action
	SetIgorMenuMode "Data", "", $Action
	SetIgorMenuMode "Analysis", "", $Action
	SetIgorMenuMode "Statistics", "", $Action
	SetIgorMenuMode "Macros", "", $Action
	SetIgorMenuMode "Windows", "", $Action
	SetIgorMenuMode "Graph", "", $Action
	SetIgorMenuMode "Image", "", $Action
	SetIgorMenuMode "Table", "", $Action
	SetIgorMenuMode "Layout", "", $Action
	SetIgorMenuMode "Panel", "", $Action
	SetIgorMenuMode "Procedure", "", $Action
	SetIgorMenuMode "Notebook", "", $Action
	SetIgorMenuMode "Gizmo", "", $Action
	SetIgorMenuMode "Misc", "", $Action
	SetIgorMenuMode "Help", "", $Action
End

// Explicit commands to disable every item in the File menu
Function EnableDisableFileMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "File", "New Experiment", $Action
	SetIgorMenuMode "File", "Open Experiment", $Action
	SetIgorMenuMode "File", "Merge Experiment", $Action
	SetIgorMenuMode "File", "Save Experiment", $Action
	SetIgorMenuMode "File", "Save Experiment As", $Action
	SetIgorMenuMode "File", "Save Experiment Copy", $Action
	SetIgorMenuMode "File", "Revert Experiment", $Action
	SetIgorMenuMode "File", "Run Autosave Now", $Action
	SetIgorMenuMode "File", "Experiment Info", $Action
	SetIgorMenuMode "File", "Open File", $Action
	SetIgorMenuMode "File", "Save Window", $Action
	SetIgorMenuMode "File", "Save Window As", $Action
	SetIgorMenuMode "File", "Save Window Copy", $Action
	SetIgorMenuMode "File", "Save All Standalone Files", $Action
	SetIgorMenuMode "File", "Adopt Window", $Action
	SetIgorMenuMode "File", "Adopt All", $Action
	SetIgorMenuMode "File", "Revert Window", $Action
	SetIgorMenuMode "File", "Save Graphics", $Action
	SetIgorMenuMode "File", "Page Setup", $Action
	SetIgorMenuMode "File", "Print", $Action
	SetIgorMenuMode "File", "Print Preview", $Action
	SetIgorMenuMode "File", "Start Another Igor Pro Instance", $Action
	SetIgorMenuMode "File", "Recent Experiments", $Action
	SetIgorMenuMode "File", "Recent Files", $Action
	SetIgorMenuMode "File", "Example Experiments", $Action
	SetIgorMenuMode "File", "Exit", $Action
End

// Explicit commands to disable every item in the Open File menu
Function EnableDisableOpenFileMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Open File", "Procedure", $Action
	SetIgorMenuMode "Open File", "Notebook", $Action
	SetIgorMenuMode "Open File", "Help File", $Action
End

// Explicit commands to disable every item in the Edit menu
Function EnableDisableEditMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Edit", "Undo", $Action
	SetIgorMenuMode "Edit", "Redo", $Action
	SetIgorMenuMode "Edit", "Cut", $Action
	SetIgorMenuMode "Edit", "Copy", $Action
	SetIgorMenuMode "Edit", "Copy All Layers", $Action
	SetIgorMenuMode "Edit", "Paste", $Action
	SetIgorMenuMode "Edit", "Paste All Layers", $Action
	SetIgorMenuMode "Edit", "Insert Paste", $Action
	SetIgorMenuMode "Edit", "Insert Paste All Layers", $Action
	SetIgorMenuMode "Edit", "Clear", $Action
	SetIgorMenuMode "Edit", "Clear All Layers", $Action
	SetIgorMenuMode "Edit", "Duplicate", $Action
	SetIgorMenuMode "Edit", "Export Graphics", $Action
	SetIgorMenuMode "Edit", "Insert File", $Action
	SetIgorMenuMode "Edit", "Select All", $Action
	SetIgorMenuMode "Edit", "Find", $Action
	SetIgorMenuMode "Edit", "Find in Multiple Windows", $Action
	SetIgorMenuMode "Edit", "Find Same", $Action
	SetIgorMenuMode "Edit", "Find Same Backward", $Action
	SetIgorMenuMode "Edit", "Find Selection", $Action
	SetIgorMenuMode "Edit", "Find Selection Backward", $Action
	SetIgorMenuMode "Edit", "Use Selection for Find", $Action
	SetIgorMenuMode "Edit", "Go to Selection", $Action
	SetIgorMenuMode "Edit", "Display Selection", $Action
	SetIgorMenuMode "Edit", "Go Back", $Action
	SetIgorMenuMode "Edit", "Go Forward", $Action
	SetIgorMenuMode "Edit", "Go to Line", $Action
	SetIgorMenuMode "Edit", "Replace", $Action
	SetIgorMenuMode "Edit", "Indent Left", $Action
	SetIgorMenuMode "Edit", "Indent Left Secondary", $Action
	SetIgorMenuMode "Edit", "Indent Right", $Action
	SetIgorMenuMode "Edit", "Indent Right Secondary", $Action
	SetIgorMenuMode "Edit", "Commentize", $Action
	SetIgorMenuMode "Edit", "Decommentize", $Action
	SetIgorMenuMode "Edit", "Align Comments", $Action
	SetIgorMenuMode "Edit", "Adjust Indentation", $Action
	SetIgorMenuMode "Edit", "Insert Page Break", $Action
	SetIgorMenuMode "Edit", "Insert Command Template", $Action
	SetIgorMenuMode "Edit", "Clear Cmd Buffer", $Action
	SetIgorMenuMode "Edit", "Character", $Action
	SetIgorMenuMode "Edit", "Special Characters", $Action
End

// Explicit commands to disable every item in the Data menu
Function EnableDisableDataMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Data", "Load Waves", $Action
	SetIgorMenuMode "Data", "Save Waves", $Action
	SetIgorMenuMode "Data", "Make Waves", $Action
	SetIgorMenuMode "Data", "Duplicate Waves", $Action
	SetIgorMenuMode "Data", "Change Wave Scaling", $Action
	SetIgorMenuMode "Data", "Redimension Waves", $Action
	SetIgorMenuMode "Data", "Insert Points", $Action
	SetIgorMenuMode "Data", "Delete Points", $Action
	SetIgorMenuMode "Data", "Rotate Waves", $Action
	SetIgorMenuMode "Data", "Unwrap Waves", $Action
	SetIgorMenuMode "Data", "Concatenate Waves", $Action
	SetIgorMenuMode "Data", "Split Wave", $Action
	SetIgorMenuMode "Data", "Kill Waves", $Action
	SetIgorMenuMode "Data", "Rename", $Action
	SetIgorMenuMode "Data", "Data Browser", $Action
End

// Explicit commands to disable every item in the Load Waves menu
Function EnableDisableLoadWavesMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Load Waves", "Load Waves", $Action
	SetIgorMenuMode "Load Waves", "Load Igor Binary", $Action
	SetIgorMenuMode "Load Waves", "Load Igor Text", $Action
	SetIgorMenuMode "Load Waves", "Load General Text", $Action
	SetIgorMenuMode "Load Waves", "Load Delimited Text", $Action
	SetIgorMenuMode "Load Waves", "Load General Binary", $Action
	SetIgorMenuMode "Load Waves", "Load Image", $Action
	SetIgorMenuMode "Load Waves", "Load Sound", $Action
	SetIgorMenuMode "Load Waves", "Load Excel File", $Action
	SetIgorMenuMode "Load Waves", "Load JCAMP-DX File", $Action
	SetIgorMenuMode "Load Waves", "Load Matlab MAT File", $Action
End

// Explicit commands to disable every item in the Save Waves menu
Function EnableDisableSaveWavesMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Save Waves", "Save Igor Binary", $Action
	SetIgorMenuMode "Save Waves", "Save Igor Text", $Action
	SetIgorMenuMode "Save Waves", "Save General Text", $Action
	SetIgorMenuMode "Save Waves", "Save Delimited Text", $Action
	SetIgorMenuMode "Save Waves", "Save Image", $Action
End

// Explicit commands to disable every item in the Analysis menu
Function EnableDisableAnalysisMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Analysis", "Curve Fitting", $Action
	SetIgorMenuMode "Analysis", "Quick Fit", $Action
	SetIgorMenuMode "Analysis", "Transforms", $Action
	SetIgorMenuMode "Analysis", "Convolve", $Action
	SetIgorMenuMode "Analysis", "Correlate", $Action
	SetIgorMenuMode "Analysis", "Differentiate", $Action
	SetIgorMenuMode "Analysis", "Integrate", $Action
	SetIgorMenuMode "Analysis", "Smooth", $Action
	SetIgorMenuMode "Analysis", "Interpolate", $Action
	SetIgorMenuMode "Analysis", "Filter", $Action
	SetIgorMenuMode "Analysis", "Resample", $Action
	SetIgorMenuMode "Analysis", "Sort", $Action
	SetIgorMenuMode "Analysis", "Histogram", $Action
	SetIgorMenuMode "Analysis", "Compose Expression", $Action
End

// Explicit commands to disable every item in the Quick Fit menu
Function EnableDisableQuickFitMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Quick Fit", "line", $Action
	SetIgorMenuMode "Quick Fit", "poly", $Action
	SetIgorMenuMode "Quick Fit", "poly_XOffset", $Action
	SetIgorMenuMode "Quick Fit", "gauss", $Action
	SetIgorMenuMode "Quick Fit", "lor", $Action
	SetIgorMenuMode "Quick Fit", "Voigt", $Action
	SetIgorMenuMode "Quick Fit", "exp_XOffset", $Action
	SetIgorMenuMode "Quick Fit", "dblexp_XOffset", $Action
	SetIgorMenuMode "Quick Fit", "exp", $Action
	SetIgorMenuMode "Quick Fit", "dblexp", $Action
	SetIgorMenuMode "Quick Fit", "dblexp_peak", $Action
	SetIgorMenuMode "Quick Fit", "sin", $Action
	SetIgorMenuMode "Quick Fit", "HillEquation", $Action
	SetIgorMenuMode "Quick Fit", "Sigmoid", $Action
	SetIgorMenuMode "Quick Fit", "Power", $Action
	SetIgorMenuMode "Quick Fit", "LogNormal", $Action
	SetIgorMenuMode "Quick Fit", "Log", $Action
	SetIgorMenuMode "Quick Fit", "poly2D", $Action
	SetIgorMenuMode "Quick Fit", "Gauss2D", $Action
	SetIgorMenuMode "Quick Fit", "Fit Between Cursors", $Action
	SetIgorMenuMode "Quick Fit", "Error Bars For Weights", $Action
	SetIgorMenuMode "Quick Fit", "Quick Fit Textbox Prefs", $Action
End

// Explicit commands to disable every item in the poly menu
Function EnableDisablepolyMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "poly", "3", $Action
	SetIgorMenuMode "poly", "4", $Action
	SetIgorMenuMode "poly", "5", $Action
	SetIgorMenuMode "poly", "6", $Action
	SetIgorMenuMode "poly", "7", $Action
	SetIgorMenuMode "poly", "8", $Action
	SetIgorMenuMode "poly", "9", $Action
	SetIgorMenuMode "poly", "10", $Action
End

// Explicit commands to disable every item in the poly_XOffset menu
Function EnableDisablepoly_XOffsetMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "poly_XOffset", "3", $Action
	SetIgorMenuMode "poly_XOffset", "4", $Action
	SetIgorMenuMode "poly_XOffset", "5", $Action
	SetIgorMenuMode "poly_XOffset", "6", $Action
	SetIgorMenuMode "poly_XOffset", "7", $Action
	SetIgorMenuMode "poly_XOffset", "8", $Action
	SetIgorMenuMode "poly_XOffset", "9", $Action
	SetIgorMenuMode "poly_XOffset", "10", $Action
End

// Explicit commands to disable every item in the poly2D menu
Function EnableDisablepoly2DMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "poly2D", "1", $Action
	SetIgorMenuMode "poly2D", "2", $Action
	SetIgorMenuMode "poly2D", "3", $Action
	SetIgorMenuMode "poly2D", "4", $Action
	SetIgorMenuMode "poly2D", "5", $Action
	SetIgorMenuMode "poly2D", "6", $Action
	SetIgorMenuMode "poly2D", "7", $Action
	SetIgorMenuMode "poly2D", "8", $Action
	SetIgorMenuMode "poly2D", "9", $Action
	SetIgorMenuMode "poly2D", "10", $Action
End

// Explicit commands to disable every item in the Transforms menu
Function EnableDisableTransformsMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Transforms", "Fourier Transforms", $Action
	SetIgorMenuMode "Transforms", "Periodogram", $Action
	SetIgorMenuMode "Transforms", "Lomb Periodogram", $Action
	SetIgorMenuMode "Transforms", "MultiTaperPSD", $Action
	SetIgorMenuMode "Transforms", "Discrete Wavelet Transform", $Action
	SetIgorMenuMode "Transforms", "Continuous Wavelet Transform", $Action
	SetIgorMenuMode "Transforms", "Wigner Transform", $Action
	SetIgorMenuMode "Transforms", "Short-Time Fourier Transform", $Action
End

// Explicit commands to disable every item in the Statistics menu
Function EnableDisableStatisticsMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Statistics", "Wave Stats", $Action
	SetIgorMenuMode "Statistics", "T-Test", $Action
	SetIgorMenuMode "Statistics", "F-Test", $Action
	SetIgorMenuMode "Statistics", "Chi Squared-Test", $Action
	SetIgorMenuMode "Statistics", "Variances Test", $Action
	SetIgorMenuMode "Statistics", "One-way ANOVA", $Action
	SetIgorMenuMode "Statistics", "Two-way ANOVA", $Action
	SetIgorMenuMode "Statistics", "Correlation Tests", $Action
	SetIgorMenuMode "Statistics", "Multi-Comparison Tests", $Action
	SetIgorMenuMode "Statistics", "Jarque-Bera Test", $Action
	SetIgorMenuMode "Statistics", "Circular Statistics Tests", $Action
	SetIgorMenuMode "Statistics", "Contingency Table Tests", $Action
	SetIgorMenuMode "Statistics", "Resampling Statistics", $Action
	SetIgorMenuMode "Statistics", "Kolmogorov-Smirnov Test", $Action
End

// Explicit commands to disable every item in the Windows menu
Function EnableDisableWindowsMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Windows", "New Graph", $Action
	SetIgorMenuMode "Windows", "New Table", $Action
	SetIgorMenuMode "Windows", "New Layout", $Action
	SetIgorMenuMode "Windows", "New", $Action
	SetIgorMenuMode "Windows", "Close", $Action
	SetIgorMenuMode "Windows", "Send To Back", $Action
	SetIgorMenuMode "Windows", "Bring To Front", $Action
	SetIgorMenuMode "Windows", "Show", $Action
	SetIgorMenuMode "Windows", "Hide", $Action
	SetIgorMenuMode "Windows", "Control", $Action
	SetIgorMenuMode "Windows", "Command Window", $Action
	SetIgorMenuMode "Windows", "Window Browser", $Action
	SetIgorMenuMode "Windows", "Show Toolbar", $Action
	SetIgorMenuMode "Windows", "Procedure Browser", $Action
	SetIgorMenuMode "Windows", "Procedure Windows", $Action
	SetIgorMenuMode "Windows", "Graphs", $Action
	SetIgorMenuMode "Windows", "Tables", $Action
	SetIgorMenuMode "Windows", "Layouts", $Action
	SetIgorMenuMode "Windows", "Gizmos", $Action
	SetIgorMenuMode "Windows", "Other Windows", $Action
	SetIgorMenuMode "Windows", "Recent Windows", $Action
	SetIgorMenuMode "Windows", "Graph Macros", $Action
	SetIgorMenuMode "Windows", "Table Macros", $Action
	SetIgorMenuMode "Windows", "Layout Macros", $Action
	SetIgorMenuMode "Windows", "Gizmo Macros", $Action
	SetIgorMenuMode "Windows", "Panel Macros", $Action
End

// Explicit commands to disable every item in the New menu
Function EnableDisableNewMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "New", "Notebook", $Action
	SetIgorMenuMode "New", "Procedure", $Action
	SetIgorMenuMode "New", "Panel", $Action
	SetIgorMenuMode "New", "Category Plot", $Action
	SetIgorMenuMode "New", "Contour Plot", $Action
	SetIgorMenuMode "New", "Image Plot", $Action
	SetIgorMenuMode "New", "Box Plot", $Action
	SetIgorMenuMode "New", "Violin Plot", $Action
	SetIgorMenuMode "New", "Gizmo Plot", $Action
End

// Explicit commands to disable every item in the Show menu
Function EnableDisableShowMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Show", "Recently Hidden Windows", $Action
	SetIgorMenuMode "Show", "Show All Graphs", $Action
	SetIgorMenuMode "Show", "Show All Tables", $Action
	SetIgorMenuMode "Show", "Show All Layouts", $Action
	SetIgorMenuMode "Show", "Show All Graphs, Tables and Layouts", $Action
	SetIgorMenuMode "Show", "Show All Gizmos", $Action
	SetIgorMenuMode "Show", "Show All Panels", $Action
	SetIgorMenuMode "Show", "Show All Notebooks", $Action
	SetIgorMenuMode "Show", "Show All XOP Windows", $Action
	SetIgorMenuMode "Show", "Show All Procedure Windows", $Action
	SetIgorMenuMode "Show", "Show All Help Windows", $Action
	SetIgorMenuMode "Show", "Show All Windows", $Action
End

// Explicit commands to disable every item in the Hide menu
Function EnableDisableHideMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Hide", "Recently Shown Windows", $Action
	SetIgorMenuMode "Hide", "Hide All Graphs", $Action
	SetIgorMenuMode "Hide", "Hide All Tables", $Action
	SetIgorMenuMode "Hide", "Hide All Layouts", $Action
	SetIgorMenuMode "Hide", "Hide All Graphs, Tables and Layouts", $Action
	SetIgorMenuMode "Hide", "Hide All Gizmos", $Action
	SetIgorMenuMode "Hide", "Hide All Panels", $Action
	SetIgorMenuMode "Hide", "Hide All Notebooks", $Action
	SetIgorMenuMode "Hide", "Hide All XOP Windows", $Action
	SetIgorMenuMode "Hide", "Hide All Procedure Windows", $Action
	SetIgorMenuMode "Hide", "Hide All Help Windows", $Action
	SetIgorMenuMode "Hide", "Hide All Hideable Windows", $Action
	SetIgorMenuMode "Hide", "Hide All Except Top Window", $Action
	SetIgorMenuMode "Hide", "Hide All Except Top Two Windows", $Action
	SetIgorMenuMode "Hide", "Hide All Except Top Three Windows", $Action
	SetIgorMenuMode "Hide", "Hide All Except Top Four Windows", $Action
	SetIgorMenuMode "Hide", "Hide All Except Top Five Windows", $Action
End

// Explicit commands to disable every item in the Control menu
Function EnableDisableControlMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Control", "Window Control", $Action
	SetIgorMenuMode "Control", "Tile", $Action
	SetIgorMenuMode "Control", "Stack", $Action
	SetIgorMenuMode "Control", "Tile or Stack Windows", $Action
	SetIgorMenuMode "Control", "Move to Preferred Position", $Action
	SetIgorMenuMode "Control", "Move to Full Size Position", $Action
	SetIgorMenuMode "Control", "Retrieve Window", $Action
	SetIgorMenuMode "Control", "Retrieve All Windows", $Action
	SetIgorMenuMode "Control", "Add or Remove Scrollbars", $Action
End

// Explicit commands to disable every item in the Procedure Windows menu
Function EnableDisableProcedureWindowsMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Procedure Windows", "Procedure", $Action
	SetIgorMenuMode "Procedure Windows", "Show Next", $Action
	SetIgorMenuMode "Procedure Windows", "Cycle", $Action
End

// Explicit commands to disable every item in the Graph menu
Function EnableDisableGraphMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Graph", "Append Traces to Graph", $Action
	SetIgorMenuMode "Graph", "Remove from Graph", $Action
	SetIgorMenuMode "Graph", "Append To Graph", $Action
	SetIgorMenuMode "Graph", "Modify Graph", $Action
	SetIgorMenuMode "Graph", "Graph Expansion", $Action
	SetIgorMenuMode "Graph", "Modify Trace Appearance", $Action
	SetIgorMenuMode "Graph", "Reorder Traces", $Action
	SetIgorMenuMode "Graph", "Replace Wave", $Action
	SetIgorMenuMode "Graph", "Modify Contour Appearance", $Action
	SetIgorMenuMode "Graph", "Modify Box Plot", $Action
	SetIgorMenuMode "Graph", "Modify Violin Plot", $Action
	SetIgorMenuMode "Graph", "Set Axis Range", $Action
	SetIgorMenuMode "Graph", "Autoscale Axes", $Action
	SetIgorMenuMode "Graph", "Label Axis", $Action
	SetIgorMenuMode "Graph", "Modify Axis", $Action
	SetIgorMenuMode "Graph", "Add Annotation", $Action
	SetIgorMenuMode "Graph", "Delete Annotations", $Action
	SetIgorMenuMode "Graph", "Edit Annotation", $Action
	SetIgorMenuMode "Graph", "Add Controls", $Action
	SetIgorMenuMode "Graph", "Select Control", $Action
	SetIgorMenuMode "Graph", "Show Info", $Action
	SetIgorMenuMode "Graph", "Show Tools", $Action
	SetIgorMenuMode "Graph", "Show Trace Info Tags", $Action
	SetIgorMenuMode "Graph", "Capture Graph Prefs", $Action
End

// Explicit commands to disable every item in the Append To Graph menu
Function EnableDisableAppendToGraphMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Append To Graph", "Category Plot", $Action
	SetIgorMenuMode "Append To Graph", "Contour Plot", $Action
	SetIgorMenuMode "Append To Graph", "Image Plot", $Action
	SetIgorMenuMode "Append To Graph", "Box Plot", $Action
	SetIgorMenuMode "Append To Graph", "Violin Plot", $Action
End

// Explicit commands to disable every item in the Graph Expansion menu
Function EnableDisableGraphExpansionMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Graph Expansion", "Expand Less", $Action
	SetIgorMenuMode "Graph Expansion", "Expand More", $Action
	SetIgorMenuMode "Graph Expansion", "12.5 %", $Action
	SetIgorMenuMode "Graph Expansion", "25.0 %", $Action
	SetIgorMenuMode "Graph Expansion", "50.0 %", $Action
	SetIgorMenuMode "Graph Expansion", "75.0 %", $Action
	SetIgorMenuMode "Graph Expansion", "Normal", $Action
	SetIgorMenuMode "Graph Expansion", "125.0 %", $Action
	SetIgorMenuMode "Graph Expansion", "150.0 %", $Action
	SetIgorMenuMode "Graph Expansion", "200.0 %", $Action
	SetIgorMenuMode "Graph Expansion", "300.0 %", $Action
	SetIgorMenuMode "Graph Expansion", "400.0 %", $Action
	SetIgorMenuMode "Graph Expansion", "500.0 %", $Action
	SetIgorMenuMode "Graph Expansion", "600.0 %", $Action
	SetIgorMenuMode "Graph Expansion", "700.0 %", $Action
	SetIgorMenuMode "Graph Expansion", "800.0 %", $Action
End

// Explicit commands to disable every item in the Add Controls To Graph menu
Function EnableDisableAddControlsToGraphMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Add Controls To Graph", "Control Bar", $Action
	SetIgorMenuMode "Add Controls To Graph", "Add Button", $Action
	SetIgorMenuMode "Add Controls To Graph", "Add Checkbox", $Action
	SetIgorMenuMode "Add Controls To Graph", "Add Popup Menu", $Action
	SetIgorMenuMode "Add Controls To Graph", "Add Value Display", $Action
	SetIgorMenuMode "Add Controls To Graph", "Add Set Variable", $Action
	SetIgorMenuMode "Add Controls To Graph", "Add Slider", $Action
	SetIgorMenuMode "Add Controls To Graph", "Add Tab", $Action
	SetIgorMenuMode "Add Controls To Graph", "Add Title Box", $Action
	SetIgorMenuMode "Add Controls To Graph", "Add Group Box", $Action
	SetIgorMenuMode "Add Controls To Graph", "Add List Box", $Action
End

// Explicit commands to disable every item in the Image menu
Function EnableDisableImageMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Image", "Modify Image Appearance", $Action
	SetIgorMenuMode "Image", "Reorder Images...", $Action
	SetIgorMenuMode "Image", "Image ROI", $Action
	SetIgorMenuMode "Image", "Image Stats", $Action
	SetIgorMenuMode "Image", "Image Threshold", $Action
	SetIgorMenuMode "Image", "Image Edge Detection", $Action
	SetIgorMenuMode "Image", "Image Morphology", $Action
	SetIgorMenuMode "Image", "Image Histogram Modification", $Action
	SetIgorMenuMode "Image", "Image Contrast", $Action
	SetIgorMenuMode "Image", "Image Range Adjustment", $Action
	SetIgorMenuMode "Image", "Convolution Filters", $Action
	SetIgorMenuMode "Image", "Line Profile", $Action
	SetIgorMenuMode "Image", "Particle Analysis", $Action
	SetIgorMenuMode "Image", "Remove Background", $Action
	SetIgorMenuMode "Image", "Rotate Image", $Action
	SetIgorMenuMode "Image", "Colorize", $Action
End

// Explicit commands to disable every item in the Table menu
Function EnableDisableTableMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Table", "Append Columns to Table", $Action
	SetIgorMenuMode "Table", "Remove Columns from Table", $Action
	SetIgorMenuMode "Table", "Table Show", $Action
	SetIgorMenuMode "Table", "Modify Columns", $Action
	SetIgorMenuMode "Table", "Autosize Columns", $Action
	SetIgorMenuMode "Table", "tableTextColorAction", $Action
	SetIgorMenuMode "Table", "Table Format", $Action
	SetIgorMenuMode "Table", "Table Digits", $Action
	SetIgorMenuMode "Table", "Table Alignment", $Action
	SetIgorMenuMode "Table", "Horizontal Index", $Action
	SetIgorMenuMode "Table", "Delay Update", $Action
	SetIgorMenuMode "Table", "Table Date Format", $Action
	SetIgorMenuMode "Table", "Table Misc Settings", $Action
	SetIgorMenuMode "Table", "Show Column Info Tags", $Action
	SetIgorMenuMode "Table", "Capture Table Prefs", $Action
End

// Explicit commands to disable every item in the Table Show menu
Function EnableDisableTableShowMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Table Show", "Entry Line Row", $Action
	SetIgorMenuMode "Table Show", "Name Row", $Action
	SetIgorMenuMode "Table Show", "Horizontal Index Row", $Action
	SetIgorMenuMode "Table Show", "Point Column", $Action
	SetIgorMenuMode "Table Show", "Horizontal Scroll Bar", $Action
	SetIgorMenuMode "Table Show", "Vertical Scroll Bar", $Action
	SetIgorMenuMode "Table Show", "Selection Highlighting", $Action
	SetIgorMenuMode "Table Show", "Insertion Cells", $Action
End

// Explicit commands to disable every item in the Table Format menu
Function EnableDisableTableFormatMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Table Format", "General", $Action
	SetIgorMenuMode "Table Format", "Integer", $Action
	SetIgorMenuMode "Table Format", "Integer with 1000's Separator", $Action
	SetIgorMenuMode "Table Format", "Decimal", $Action
	SetIgorMenuMode "Table Format", "Decimal with 1000's Separator", $Action
	SetIgorMenuMode "Table Format", "Scientific", $Action
	SetIgorMenuMode "Table Format", "Date", $Action
	SetIgorMenuMode "Table Format", "Time", $Action
	SetIgorMenuMode "Table Format", "Date and Time", $Action
	SetIgorMenuMode "Table Format", "Octal", $Action
	SetIgorMenuMode "Table Format", "Hexadecimal", $Action
	SetIgorMenuMode "Table Format", "Show Trailing Zeros", $Action
	SetIgorMenuMode "Table Format", "Show Fractional Seconds", $Action
End

// Explicit commands to disable every item in the Table Digits menu
Function EnableDisableTableDigitsMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Table Digits", "1", $Action
	SetIgorMenuMode "Table Digits", "2", $Action
	SetIgorMenuMode "Table Digits", "3", $Action
	SetIgorMenuMode "Table Digits", "4", $Action
	SetIgorMenuMode "Table Digits", "5", $Action
	SetIgorMenuMode "Table Digits", "6", $Action
	SetIgorMenuMode "Table Digits", "7", $Action
	SetIgorMenuMode "Table Digits", "8", $Action
	SetIgorMenuMode "Table Digits", "9", $Action
	SetIgorMenuMode "Table Digits", "10", $Action
	SetIgorMenuMode "Table Digits", "11", $Action
	SetIgorMenuMode "Table Digits", "12", $Action
	SetIgorMenuMode "Table Digits", "13", $Action
	SetIgorMenuMode "Table Digits", "14", $Action
	SetIgorMenuMode "Table Digits", "15", $Action
	SetIgorMenuMode "Table Digits", "16", $Action
End

// Explicit commands to disable every item in the Table Alignment menu
Function EnableDisableTableAlignmentMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Table Alignment", "Align Left", $Action
	SetIgorMenuMode "Table Alignment", "Align Center", $Action
	SetIgorMenuMode "Table Alignment", "Align Right", $Action
End

// Explicit commands to disable every item in the Horizontal Index menu
Function EnableDisableHorizontalIndexMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Horizontal Index", "Horiz Index Auto", $Action
	SetIgorMenuMode "Horizontal Index", "Horiz Index Numeric", $Action
	SetIgorMenuMode "Horizontal Index", "Horiz Index Dim Labels", $Action
End

// Explicit commands to disable every item in the Layout menu
Function EnableDisableLayoutMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Layout", "Append to Layout", $Action
	SetIgorMenuMode "Layout", "Remove from Layout", $Action
	SetIgorMenuMode "Layout", "Arrange Objects", $Action
	SetIgorMenuMode "Layout", "Modify Objects", $Action
	SetIgorMenuMode "Layout", "Add Annotation", $Action
	SetIgorMenuMode "Layout", "Delete Annotations", $Action
	SetIgorMenuMode "Layout", "Edit Annotation", $Action
	SetIgorMenuMode "Layout", "Page Size", $Action
	SetIgorMenuMode "Layout", "Layout Page", $Action
	SetIgorMenuMode "Layout", "Layout Zoom", $Action
	SetIgorMenuMode "Layout", "layoutBackgroundColorAction", $Action
	SetIgorMenuMode "Layout", "Layout Align", $Action
	SetIgorMenuMode "Layout", "Make Same Width", $Action
	SetIgorMenuMode "Layout", "Make Same Height", $Action
	SetIgorMenuMode "Layout", "Make Same Width and Height", $Action
	SetIgorMenuMode "Layout", "Make Plot Areas Uniform", $Action
	SetIgorMenuMode "Layout", "Bring to Front", $Action
	SetIgorMenuMode "Layout", "Move Forward", $Action
	SetIgorMenuMode "Layout", "Send to Back", $Action
	SetIgorMenuMode "Layout", "Move Backward", $Action
	SetIgorMenuMode "Layout", "Slide Show Settings", $Action
	SetIgorMenuMode "Layout", "Capture Layout Prefs", $Action
End

// Explicit commands to disable every item in the Layout Page menu
Function EnableDisableLayoutPageMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Layout Page", "Add Page", $Action
	SetIgorMenuMode "Layout Page", "Next Page", $Action
	SetIgorMenuMode "Layout Page", "Previous Page", $Action
	SetIgorMenuMode "Layout Page", "Delete Page", $Action
End

// Explicit commands to disable every item in the Layout Zoom menu
Function EnableDisableLayoutZoomMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Layout Zoom", "Zoom In", $Action
	SetIgorMenuMode "Layout Zoom", "Zoom Out", $Action
	SetIgorMenuMode "Layout Zoom", "Other", $Action
	SetIgorMenuMode "Layout Zoom", "6.25%", $Action
	SetIgorMenuMode "Layout Zoom", "12.5%", $Action
	SetIgorMenuMode "Layout Zoom", "25%", $Action
	SetIgorMenuMode "Layout Zoom", "50%", $Action
	SetIgorMenuMode "Layout Zoom", "100%", $Action
	SetIgorMenuMode "Layout Zoom", "200%", $Action
	SetIgorMenuMode "Layout Zoom", "400%", $Action
	SetIgorMenuMode "Layout Zoom", "800%", $Action
End

// Explicit commands to disable every item in the Layout Align menu
Function EnableDisableLayoutAlignMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Layout Align", "Left Edges", $Action
	SetIgorMenuMode "Layout Align", "Horizontal Centers", $Action
	SetIgorMenuMode "Layout Align", "Right Edges", $Action
	SetIgorMenuMode "Layout Align", "Top Edges", $Action
	SetIgorMenuMode "Layout Align", "Vertical Centers", $Action
	SetIgorMenuMode "Layout Align", "Bottom Edges", $Action
End

// Explicit commands to disable every item in the Panel menu
Function EnableDisablePanelMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Panel", "Add Controls To Panel", $Action
	SetIgorMenuMode "Panel", "Select Control In Panel", $Action
	SetIgorMenuMode "Panel", "Show Info", $Action
	SetIgorMenuMode "Panel", "Show Tools", $Action
	SetIgorMenuMode "Panel", "Fixed Size", $Action
	SetIgorMenuMode "Panel", "Panel Expansion", $Action
	SetIgorMenuMode "Panel", "Capture Panel Prefs", $Action
End

// Explicit commands to disable every item in the Add Controls To Panel menu
Function EnableDisableAddControlsToPanelMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Add Controls To Panel", "Control Bar", $Action
	SetIgorMenuMode "Add Controls To Panel", "Add Button", $Action
	SetIgorMenuMode "Add Controls To Panel", "Add Checkbox", $Action
	SetIgorMenuMode "Add Controls To Panel", "Add Popup Menu", $Action
	SetIgorMenuMode "Add Controls To Panel", "Add Value Display", $Action
	SetIgorMenuMode "Add Controls To Panel", "Add Set Variable", $Action
	SetIgorMenuMode "Add Controls To Panel", "Add Slider", $Action
	SetIgorMenuMode "Add Controls To Panel", "Add Tab", $Action
	SetIgorMenuMode "Add Controls To Panel", "Add Title Box", $Action
	SetIgorMenuMode "Add Controls To Panel", "Add Group Box", $Action
	SetIgorMenuMode "Add Controls To Panel", "Add List Box", $Action
End

// Explicit commands to disable every item in the Panel Expansion menu
Function EnableDisablePanelExpansionMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Panel Expansion", "Expand Less", $Action
	SetIgorMenuMode "Panel Expansion", "Expand More", $Action
	SetIgorMenuMode "Panel Expansion", "50.0 %", $Action
	SetIgorMenuMode "Panel Expansion", "60.0 %", $Action
	SetIgorMenuMode "Panel Expansion", "75.0 %", $Action
	SetIgorMenuMode "Panel Expansion", "80.0 %", $Action
	SetIgorMenuMode "Panel Expansion", "87.5 %", $Action
	SetIgorMenuMode "Panel Expansion", "Normal", $Action
	SetIgorMenuMode "Panel Expansion", "125.0 %", $Action
	SetIgorMenuMode "Panel Expansion", "133.3 %", $Action
	SetIgorMenuMode "Panel Expansion", "150.0 %", $Action
	SetIgorMenuMode "Panel Expansion", "166.7 %", $Action
	SetIgorMenuMode "Panel Expansion", "175.0 %", $Action
	SetIgorMenuMode "Panel Expansion", "200.0 %", $Action
	SetIgorMenuMode "Panel Expansion", "250.0 %", $Action
	SetIgorMenuMode "Panel Expansion", "300.0 %", $Action
	SetIgorMenuMode "Panel Expansion", "400.0 %", $Action
	SetIgorMenuMode "Panel Expansion", "Other", $Action
	SetIgorMenuMode "Panel Expansion", "Other Default", $Action
End

// Explicit commands to disable every item in the Procedure menu
Function EnableDisableProcedureMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Procedure", "Text Size", $Action
	SetIgorMenuMode "Procedure", "procedureTextColorAction", $Action
	SetIgorMenuMode "Procedure", "Set Text Format", $Action
	SetIgorMenuMode "Procedure", "Document Settings", $Action
	SetIgorMenuMode "Procedure", "Info", $Action
	SetIgorMenuMode "Procedure", "Text Encoding", $Action
	SetIgorMenuMode "Procedure", "Capture Procedure Prefs", $Action
	SetIgorMenuMode "Procedure", "Enable Debugger", $Action
	SetIgorMenuMode "Procedure", "Debug On Error", $Action
	SetIgorMenuMode "Procedure", "Debug On Abort", $Action
	SetIgorMenuMode "Procedure", "NVAR SVAR WAVE Checking", $Action
	SetIgorMenuMode "Procedure", "Clear All Breakpoints", $Action
	SetIgorMenuMode "Procedure", "Compile", $Action
	SetIgorMenuMode "Procedure", "Hide All Procedures", $Action
End

// Explicit commands to disable every item in the Procedure Magnification menu
Function EnableDisableProcedureMagnificationMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Procedure Magnification", "Smaller", $Action
	SetIgorMenuMode "Procedure Magnification", "Bigger", $Action
	SetIgorMenuMode "Procedure Magnification", "Default", $Action
	SetIgorMenuMode "Procedure Magnification", "200%", $Action
	SetIgorMenuMode "Procedure Magnification", "175%", $Action
	SetIgorMenuMode "Procedure Magnification", "150%", $Action
	SetIgorMenuMode "Procedure Magnification", "125%", $Action
	SetIgorMenuMode "Procedure Magnification", "100%", $Action
	SetIgorMenuMode "Procedure Magnification", "75%", $Action
	SetIgorMenuMode "Procedure Magnification", "50%", $Action
	SetIgorMenuMode "Procedure Magnification", "Other", $Action
	SetIgorMenuMode "Procedure Magnification", "Set Default", $Action
End

// Explicit commands to disable every item in the Notebook menu
Function EnableDisableNotebookMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Notebook", "Text Size", $Action
	SetIgorMenuMode "Notebook", "Text Color", $Action
	SetIgorMenuMode "Notebook", "Set Text Format", $Action
	SetIgorMenuMode "Notebook", "Set Text Format to Ruler Default", $Action
	SetIgorMenuMode "Notebook", "Set Paragraph Spacing", $Action
	SetIgorMenuMode "Notebook", "Make Help Link", $Action
	SetIgorMenuMode "Notebook", "Syntax Color Selection", $Action
	SetIgorMenuMode "Notebook", "Document Settings", $Action
	SetIgorMenuMode "Notebook", "Hide Ruler", $Action
	SetIgorMenuMode "Notebook", "Special", $Action
	SetIgorMenuMode "Notebook", "Info", $Action
	SetIgorMenuMode "Notebook", "Text Encoding", $Action
	SetIgorMenuMode "Notebook", "Generate Commands", $Action
	SetIgorMenuMode "Notebook", "Capture Notebook Prefs", $Action
End

// Explicit commands to disable every item in the Notebook Magnification menu
Function EnableDisableNotebookMagnificationMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Notebook Magnification", "Smaller", $Action
	SetIgorMenuMode "Notebook Magnification", "Bigger", $Action
	SetIgorMenuMode "Notebook Magnification", "Default", $Action
	SetIgorMenuMode "Notebook Magnification", "200%", $Action
	SetIgorMenuMode "Notebook Magnification", "175%", $Action
	SetIgorMenuMode "Notebook Magnification", "150%", $Action
	SetIgorMenuMode "Notebook Magnification", "125%", $Action
	SetIgorMenuMode "Notebook Magnification", "100%", $Action
	SetIgorMenuMode "Notebook Magnification", "75%", $Action
	SetIgorMenuMode "Notebook Magnification", "50%", $Action
	SetIgorMenuMode "Notebook Magnification", "Other", $Action
	SetIgorMenuMode "Notebook Magnification", "Set Default", $Action
End

// Explicit commands to disable every item in the Gizmo menu
Function EnableDisableGizmoMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Gizmo", "Append Surface", $Action
	SetIgorMenuMode "Gizmo", "Append Scatter", $Action
	SetIgorMenuMode "Gizmo", "Append Path", $Action
	SetIgorMenuMode "Gizmo", "Append Ribbon", $Action
	SetIgorMenuMode "Gizmo", "Append 3D Slice", $Action
	SetIgorMenuMode "Gizmo", "Append Isosurface", $Action
	SetIgorMenuMode "Gizmo", "Append Voxelgram", $Action
	SetIgorMenuMode "Gizmo", "Append Image", $Action
	SetIgorMenuMode "Gizmo", "Axis Range", $Action
	SetIgorMenuMode "Gizmo", "Add Annotation", $Action
	SetIgorMenuMode "Gizmo", "Delete Annotations", $Action
	SetIgorMenuMode "Gizmo", "Edit Annotation", $Action
	SetIgorMenuMode "Gizmo", "Enable Transparency Blend", $Action
	SetIgorMenuMode "Gizmo", "Create Movie", $Action
	SetIgorMenuMode "Gizmo", "Show Info", $Action
	SetIgorMenuMode "Gizmo", "Show Tools", $Action
End

// Explicit commands to disable every item in the Misc menu
Function EnableDisableMiscMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Misc", "New Path", $Action
	SetIgorMenuMode "Misc", "Path Status", $Action
	SetIgorMenuMode "Misc", "Kill Paths", $Action
	SetIgorMenuMode "Misc", "Object Status", $Action
	SetIgorMenuMode "Misc", "Rename Objects", $Action
	SetIgorMenuMode "Misc", "Pictures", $Action
	SetIgorMenuMode "Misc", "Default Font", $Action
	SetIgorMenuMode "Misc", "Font Substitutions", $Action
	SetIgorMenuMode "Misc", "Dashed Lines", $Action
	SetIgorMenuMode "Misc", "Command/History Window", $Action
	SetIgorMenuMode "Misc", "Preferences On", $Action
	SetIgorMenuMode "Misc", "Preferences Off", $Action
	SetIgorMenuMode "Misc", "Miscellaneous Settings", $Action
	SetIgorMenuMode "Misc", "Text Encoding", $Action
End

// Explicit commands to disable every item in the Command/History Window menu
Function EnableDisableCommandHistoryWindowMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Command/History Window", "Set Text Format", $Action
	SetIgorMenuMode "Command/History Window", "Document Settings", $Action
	SetIgorMenuMode "Command/History Window", "Command/History Magnification", $Action
	SetIgorMenuMode "Command/History Window", "Capture Prefs", $Action
End

// Explicit commands to disable every item in the Command/History Magnification menu
Function EnableDisableCommandHistoryMagnificationMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Command/History Magnification", "Smaller", $Action
	SetIgorMenuMode "Command/History Magnification", "Bigger", $Action
	SetIgorMenuMode "Command/History Magnification", "Default", $Action
	SetIgorMenuMode "Command/History Magnification", "200%", $Action
	SetIgorMenuMode "Command/History Magnification", "175%", $Action
	SetIgorMenuMode "Command/History Magnification", "150%", $Action
	SetIgorMenuMode "Command/History Magnification", "125%", $Action
	SetIgorMenuMode "Command/History Magnification", "100%", $Action
	SetIgorMenuMode "Command/History Magnification", "75%", $Action
	SetIgorMenuMode "Command/History Magnification", "50%", $Action
	SetIgorMenuMode "Command/History Magnification", "Other", $Action
	SetIgorMenuMode "Command/History Magnification", "Set Default", $Action
End

// Explicit commands to disable every item in the Text Encoding menu
Function EnableDisableTextEncodingMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Text Encoding", "Default Text Encoding", $Action
	SetIgorMenuMode "Text Encoding", "Set Wave Text Encoding", $Action
	SetIgorMenuMode "Text Encoding", "Convert Global String Text Encoding", $Action
	SetIgorMenuMode "Text Encoding", "Convert to UTF-8 Text Encoding", $Action
End

// Explicit commands to disable every item in the Default Text Encoding menu
Function EnableDisableDefaultTextEncodingMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Default Text Encoding", "UTF-8", $Action
	SetIgorMenuMode "Default Text Encoding", "Western", $Action
	SetIgorMenuMode "Default Text Encoding", "MacRoman", $Action
	SetIgorMenuMode "Default Text Encoding", "Windows Latin 1 [Windows-1252]", $Action
	SetIgorMenuMode "Default Text Encoding", "Japanese [Shift_JIS]", $Action
	SetIgorMenuMode "Default Text Encoding", "Simplified Chinese", $Action
	SetIgorMenuMode "Default Text Encoding", "Traditional Chinese", $Action
	SetIgorMenuMode "Default Text Encoding", "Macintosh Korean", $Action
	SetIgorMenuMode "Default Text Encoding", "Windows Korean", $Action
	SetIgorMenuMode "Default Text Encoding", "Override Experiment", $Action
End

// Explicit commands to disable every item in the Help menu
Function EnableDisableHelpMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Help", "Getting Started", $Action
	SetIgorMenuMode "Help", "Help for Selection", $Action
	SetIgorMenuMode "Help", "Igor Help Browser", $Action
	SetIgorMenuMode "Help", "Help Topics", $Action
	SetIgorMenuMode "Help", "Shortcuts", $Action
	SetIgorMenuMode "Help", "Command Help", $Action
	SetIgorMenuMode "Help", "Search Igor Files", $Action
	SetIgorMenuMode "Help", "Manual", $Action
	SetIgorMenuMode "Help", "Support", $Action
	SetIgorMenuMode "Help", "Help Windows", $Action
	SetIgorMenuMode "Help", "Show Igor Pro Folder", $Action
	SetIgorMenuMode "Help", "Show Igor Pro User Files", $Action
	SetIgorMenuMode "Help", "Show Igor Preferences Folder", $Action
	SetIgorMenuMode "Help", "Show Igor Pro Folder And User Files", $Action
	SetIgorMenuMode "Help", "WaveMetrics Home Page", $Action
	SetIgorMenuMode "Help", "Support Web Page", $Action
	SetIgorMenuMode "Help", "WaveMetrics Forums", $Action
	SetIgorMenuMode "Help", "Contact Support", $Action
	SetIgorMenuMode "Help", "License", $Action
	SetIgorMenuMode "Help", "About Coursework License", $Action
	SetIgorMenuMode "Help", "About Igor", $Action
	SetIgorMenuMode "Help", "Updates for Igor Pro", $Action
	SetIgorMenuMode "Help", "Igor Pro Nightly Builds", $Action
	SetIgorMenuMode "Help", "System Information", $Action
	SetIgorMenuMode "Help", "About Igor Application", $Action
End

// Explicit commands to disable every item in the Help Magnification menu
Function EnableDisableHelpMagnificationMenuItems(Variable enable)
	String Action= SelectString(enable, "DisableItem", "EnableItem")

	SetIgorMenuMode "Help Magnification", "Smaller", $Action
	SetIgorMenuMode "Help Magnification", "Bigger", $Action
	SetIgorMenuMode "Help Magnification", "Default", $Action
	SetIgorMenuMode "Help Magnification", "200%", $Action
	SetIgorMenuMode "Help Magnification", "175%", $Action
	SetIgorMenuMode "Help Magnification", "150%", $Action
	SetIgorMenuMode "Help Magnification", "125%", $Action
	SetIgorMenuMode "Help Magnification", "100%", $Action
	SetIgorMenuMode "Help Magnification", "75%", $Action
	SetIgorMenuMode "Help Magnification", "50%", $Action
	SetIgorMenuMode "Help Magnification", "Other", $Action
	SetIgorMenuMode "Help Magnification", "Set Default", $Action
End

