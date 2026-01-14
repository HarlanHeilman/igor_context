#pragma rtGlobals=3		// Use modern global access method.
#pragma version=1.16
#pragma IgorVersion=6.10

// **********************************
// Version 1.0 first release
//
// Version 1.01
//		Added support for coloring items in the list
// Version 1.02
//		Fixed bug: MakeListIntoHierarchicalList() set root: datafolder instead of restoring original
// Version 1.03
// 		Fixed errors in documentation.
// Version 1.04
//		Added functions WMHL_DeleteRowAndChildren and WMHL_ListChildRows
// Version 1.05
//		Add support for multi-column lists.
// Version 1.06
// 		Add support for user's listbox action procedure
// Version 1.07
//		Added function WMHL_ChangeItem
// Version 1.08
//		Changed the way list data is destroyed when the control is killed (most likely because the host window is killed)
//		Added setSelWaveValue optional parameter to function WMHL_ExtraColumnData.
//		Added function WMHL_GetExtraColumnSelValue.
// Version 1.09
//		Added Container Closing Notify Proc
// Version 1.10
//		Fixed bug: WMHL_ChangeItem applied to a container row that was open didn't change the paths stored for the child rows.
// Verstion 1.11
//		Check for recreation macro before killing the data folder containing the list waves, etc. If the list is contained in a window or subwindow of
//		a window that has a recreation macro, it doesn't kill the data folder.
// Version 1.12		[JW 100921]
//		Buggy line in WMHL_AddColorSupport() caused an index-out-of-range error when run under rtGlobals=3
//		Added foreColor and backColor optional inputs to WMHL_ExtraColumnData()
//		Changed WMHL_ExtraColumnData() such that unless you specify colors, it leaves the color set by WMHL_AddObject() alone.
// Version 1.13		[JW 100927]
//		Fixed bad index to ListWave in WMHL_ExtraColumnData().
//		WMHL_SetUsersListboxProc() didn't actually work: procedure name was added to structure, but modified structure 
//			wasn't written back to the user data in the listbox.
// Version 1.14		[JW 131022]
//		Fixed bug: if you removed all the rows from the list, the listwave and selwave forgot that they were multicolumn waves. So now, if you
//		remove the last row, it detects that and redimensions the waves to one-row waves, and re-initializes the waves as if MakeListIntoHierarchicalList()
//		had just been called, with the exception that it remembers any extra added columns.
// Version 1.14		[JW 131108]
//		The previous fix wasn't complete: removing the last item still removed color support.
//		Didn't bump the revision number because it's really the same issue and version 1.14 hasn't been released yet.
// Version 1.15		[JW 200422]
//		Fixed bug: WMHL_ChangeItem() would indent a top-level row because of a bug in WMHL_IndentString().
// Version 1.16		[JW 231110]
//		Fixed bug: In function WMHL_GetExtraColumnData(), value of a cell in the listbox listwave was returned using only two
//		dimension indices instead of three. A bug in Igor's wave indexing made that vulnerable to returning the wrong
//		cell or to index-out-of-range errors. The bug is fixed now, but it's bad practice to depend on silent defaults.
// **********************************

// **********************************
//	Documentation
//
//	This procedure file provides functions to turn a listbox control into a generalized hierarchical list display.
//	You provide client code that decides what goes into the list, this procedure file manages the list.
//
//	This procedure recognizes two classes of list items (rows)- containers and non-containers. Containers are
//	displayed in the list with a disclosure triangle or box at the left.  When the user clicks the disclosure control
//	a function provided by the client code is called to handle it. Usually the function would handle it by calling
//	WMHL_AddObject() to add contained items.
//
//	At a minimum, client code must provide the Container Opened notification function.
//
//	Internally, the HierarchicalListWidget keeps track of the hierarchy using a path. When you add an item, you provide
//	a string that identifies the item and is displayed to the user as the list row text. The items can contain any characters
//	*except* for a separator character. This separator character is used by HierarchicalListWidget to maintain the
//	list hierarchy. It can be any single character that never appears in an item. The default is  ":", but you can set it
//	to any character you choose.
//
//	When you add an item, you provide both the item text and the full path for a container. The Container Opened Notification
//	includes a full path for the container item that has just opened. The proper way to set up an initial hierarchy is to add one
//	or more "root" items (containers that have no parents; in WMHL_AddObject() the  parent container string is ""). Then
//	call WMHL_OpenAContainer() on any container that you want to be open initially. This will result in the Container Opened
//	Notification calling your function with the path for the parent container.
//
//	Closing a container results in all the children of the container being deleted from the list. You must have a way to regenerate
//	the children in case the container is re-opened. Once a container is closed, you can't get any information about its children
//	because they don't exist.
//
//	The built-in function ParseFilePath() is useful for extracting pieces of the item paths. This may be necessary in your code
//	in order to interpret the item paths.
//
//	***************************
//	Function Reference
//	***************************
//
//	All the functions take two standard input parameters that identify the listbox control. These are:
//		windowname		string expression giving the name of the window (graph or control panel)
//							containing the listbox control.
//		listcontrolname		string expression giving the name of the listbox control.
//
//	***************************
//	The Functions
//	***************************
//
//	MakeListIntoHierarchicalList(windowname, listcontrolname, ContainerOpenNotifyProc, [selectionMode, pathSeparator])
//		Makes the specified listbox control into a HierarchicalListWidget.
//
//		To set the value of an optional parameter, you must use the name of the parameter. For instance, to
//		call MakeListIntoHierarchicalList() with a semi-colon as the separator character, do it like this:
//			MakeListIntoHierarchicalList("MyWindow", "MyListbox", "MyOpenNotifyProc", pathSeparator=";")
//
//		ContainerOpenNotifyProc
//							String containing the name of the function you provide to add items to a newly
//							opened container. See below for details on the format of your function.
//
//		selectionMode		optional parameter to set the selection mode. A set of constants is provided
//							for your convenience:
//								WMHL_SelectionNonContinguous
//														Allows multiple, non-contiguous selections.
//								WMHL_SelectionContinguous
//														Allows multiple selections, but they must 
//														be contiguous.
//								WMHL_SelectionSingle	Only a single item my be selected at a time.
//							WMWS_SelectionNonContinguous is the default. Only whole rows can be selected, which really
//							means that the list cells containing the item text will be selected, and not the cell containing
//							the disclosure control.
//
//		pathSeparator		optional string containing a path separator character. If you don't use this parameter, it
//							defaults to ":". If you supply a string with more than one character, only the first character is used.
//
//		userListProc		Optional string containing the name of a listbox action procedure to be called if the Hierarchical
//							List Widget action procedure doesn't want to do anything.
//
//	WMHL_SetUsersListboxProc(windowname, listcontrolname, procName)
//		Call to set your own action procedure on the listbox. Your listbox proc will be called if the Hierarchical
//		listbox action procedure is called by Igor but didn't do anything as a result. Gives you a chance to 
//		do something with the event.
//
//		Returns a string containing the name of the previous users procedure if there was one.
//
//		procName			A string containing the name of your procedure
//
//	WMHL_AddColorSupport(windowname, listcontrolname, colorWave, colorDisclosure)
// 		Call after you have called MakeListIntoHierarchicalList() and before calls such as WMHL_AddObject(). This function adds
//		necessary support for making  items in the browser colored.
//
//		colorWave			A three-column wave to define colors that you will use with WMHL_AddObject() to color items
//							added to the list. See reference documentation Listbox to learn about color support in list boxes; this
//							wave will be added to the listbox using the colorWave keyword. Note that row zero is special-
//							don't put a color there, you can't use it.
//
//							Each row specifies a color that can be used to color items. When you call WMHL_AddObject() you can
//							specify a color from this color wave for coloring the background or foreground (text) of the item. You
//							do this by specifying the row number in colorWave. See WMHL_AddObject() below.
//
//		colorDisclosure		Set to 1 if you want color in the small, leftmost column containing the disclosure control. Set to zero
//							to have that column remain white.
//
//	WMHL_AddColumns(windowname, listcontrolname, nColumnsToAdd [, labelListStr])
//		Call after calling MakeListIntoHierarchicalList() in order to add extra columns to the list. These extra columns just
//		go along for the ride- when you call WMHL_AddObject they will be blank. Your ContainerOpenNotify procedure is the
// 		logical place to add data to the extra columns (see WMHL_ExtraColumnData). When the container is closed, the extra data
// 		vaporizes. If you need it to persist, you need to store it yourself.
//
//		nColumnsToAdd		The number of columns to add.
//
//		labelListStr			A semicolon-separated list of strings that will be used to label the columns in the list.
//
//	WMHL_ExtraColumnData(windowname, listcontrolname, extraColumnNumber, theRow, dataString, makeEditable [, setSelWaveValue, foreColor, backColor]))
//		Puts data into cells of columns added by WMHL_AddColumns.
//
//		extraColumnNumber
//							zero-based column numberof the extra column containing the cell to receive the data. Note that
//							this is not the actual column number; setting extraColumnNumber to 0 will put data into the first
//							*added* column, not the first column in the list.
//
//		theRow				The zero-based row number of the cell to receive the data.
//
//		dataString		A string expression that specifies the data to be displayed in the cell.
//
//		makeEditable		Set to non-zero if you want the cell data to be editable.
//
//		setSelWaveValue	Optional parameter- overrides makeEditable. Allows you to set the selWave value for a
//							cell in an extra-data column. Use this to make a cell into a checkbox, for instance.
//							For values to use, see ListBox documentation under keyword selWave.
//
//		foreColor
//		backColor			These are optional parameters that you can use after having called WMHL_AddColorSupport(). Each
//							parameter takes a color index, that is, the row number from the colorWave specified with WMHL_AddColorSupport(). Causes
//							the background of the item's row (backColor) or the text (foreColor) to take on the color specified by
//							the correspoding row in colorWave.
//
//							Use foreColor=0 or backColor=0 to get default colors (white background, black text). Note that this means
//							any color stored in row zero of colorWave cannot be used.
//
//							Because these are optional parameters, you must use the special optional parameter syntax:
//							WMHL_GetExtraColumnData(<wname>, <listname>, <extraColumnNumber>, <theRow>, <dataString>, <makeEditable>, foreColor=<colorIndex>, backColor=<colorIndex>)
//
//	WMHL_GetExtraColumnData(windowname, listcontrolname, extraColumnNumber, theRow)
//		Returns a string containing the data from cells of columns added by WMHL_AddColumns.
//
//		extraColumnNumber
//							zero-based column numberof the extra column containing the cell to receive the data. Note that
//							this is not the actual column number; setting extraColumnNumber to 0 will put data into the first
//							*added* column, not the first column in the list.
//
//		theRow				The zero-based row number of the cell to receive the data.
//
//	WMHL_GetExtraColumnSelValue(windowname, listcontrolname, extraColumnNumber, theRow)
//		Returns the value of the selWave coresponding to a given extra data column and row. This is useful if
//		you have used an extra column as a checkbox and you want to know if it is checked, or if the cell is
//		selectable and you want to know if it is selected.
//
//		extraColumnNumber
//							zero-based column numberof the extra column containing the cell to receive the data. Note that
//							this is not the actual column number; setting extraColumnNumber to 0 will put data into the first
//							*added* column, not the first column in the list.
//
//		theRow				The zero-based row number of the cell to receive the data.
//
//	WMHL_AddObject(windowname, listcontrolname, ParentPath, ObjectName, ItsAContainer [, foreColor, backColor])
//		Add items (rows) to the hierarchical list. Items are added as children of the specified parent; the indent level of the item
//		is set by the depth of the parent's path. Typically called inside the Container Opened Notification.
//
//		ParentPath			String containing the full item path of the parent for the new item. This is a path
//							composed of the text of each parent item up to the root. If this new item should be
//							a root-level item, use "" as the parent path.
//
//		ObjectName			String containing the text (or name) of the new item. This text will be displayed in the list
//							with indentation proportional to the depth of the path. Must not contain the separator character.
//
//		ItsAContainer		Set to zero if this is a leaf item. Set to 1 if this is a container item. New container items are created
//							in a closed state. To programmatically add children to a container, use WMHL_OpenAContainer()
//							and call WMHL_AddObject() inside the Container Opened Notification function.
//
//		foreColor
//		backColor			These are optional parameters that you can use after having called WMHL_AddColorSupport(). Each
//							parameter takes a color index, that is, the row number from the colorWave specified with WMHL_AddColorSupport(). Causes
//							the background of the item's row (backColor) or the text (foreColor) to take on the color specified by
//							the correspoding row in colorWave.
//
//							If you have added columns using WMHL_AddColumns, the colors are applied to all the columns. You can override
//							this color by calling WMHL_ExtraColumnData, setting the color using the optional foreColor and backColor inputs.
//
//							Use foreColor=0 or backColor=0 to get default colors (white background, black text). Note that this means
//							any color stored in row zero of colorWave cannot be used.
//
//							Because these are optional parameters, you must use the special optional parameter syntax:
//							WMHL_AddObject(<wname>, <listname>, <path>, <text>, <0or1>, foreColor=<colorIndex>, backColor=<colorIndex>)
//
//	WMHL_DeleteRowAndChildren(windowname, listcontrolname, theRow)
//		Delete one row from the list. If that row is a container, its children will also be deleted.
//
//		theRow				The zero-based row number of the item to be deleted. If you have an item path instead of a row number,
//							get the row number using WMHL_GetRowNumberForItem()
//
//	WMHL_OpenAContainer(windowname, listcontrolname, FullItemPath)
//		Causes a container to be opened: its disclosure control is set to the open appearance, and the Container Opened Notification
//		function is called. See below for information on notification functions.
//
//		FullItemPath		The full path name of the item to be opened. The path name is composed of the item's text, preceded by the
//							text of each of its parents.
//
//	WMHL_CloseAContainer(windowname, listcontrolname, FullItemPath)
//		Causes a container to be closed: its disclosure control is set to the closed appearance, and the Container Closed Notification
//		function is called if there is one. See below for information on notification functions.
//
//		FullItemPath		The full path name of the item to be opened. The path name is composed of the item's text, preceded by the
//							text of each of its parents.
//
//	WMHL_GetItemForRowNumber(windowname, listcontrolname, theRow)
//		Returns a string containing the full path of an item given its zero-based row number in the list.
//
//		theRow				the zero-based row number of an item.
//
//	WMHL_GetRowNumberForItem(windowname, listcontrolname, theItem)
//		Returns the row number where a given item is to be found.
//
//		theItem				A string containing the full path of an item.
//
//	WMHL_ChangeItem(windowname, listcontrolname, FullItemPath, newItemName)
//		Changes the name of an item and changes the displayed string.
//		
//		FullItemPath		The full path name of the item to be opened. The path name is composed of the item's text, preceded by the
//							text of each of its parents.
//
//		newItemName		A string containing the new item name (just the name, not the path)
//
//	WMHL_RowIsContainer(windowname, listcontrolname, theRow)
//		Returns 0 or 1 depending on whether the item at a given row is a container. You can use WMHL_GetRowNumberForItem()
//		if you have an item full path instead of a row number.
//
//		theRow				the zero-based row number of an item.
//
//	WMHL_RowIsOpen(windowname, listcontrolname, theRow)
//		Returns 0 or 1 depending on whether the item at the given row is an open container. If it is not a container, zero is returned.
//
//		theRow				the zero-based row number of an item.
//
//	WMHL_GetParentItemForRow(windowname, listcontrolname, theRow)
//		Returns a string containing the full item path of the parent of the item at the given row. If the row contains a root-level item,
//		the string returned is "".
//
//		theRow				the zero-based row number of an item.
//
//	WMHL_SelectARow(windowname, listcontrolname, theRow, ClearAllSelectionsFirst)
//		Selected the given row. 
//
//		theRow				the zero-based row number of an item.
//
//		ClearAllSelectionsFirst
//							If non-zero, any rows already selected are de-selected before theRow is selected.
//							If zero, any rows already selected remain selected.
//
//	WMHL_SelectListOfRowNumbers(windowname, listcontrolname, RowList, ClearAllSelectionsFirst)
//		Selectes all rows contained in a list of row numbers.
//
//		RowList				String containing a list of row numbers to be selected, like "1;2;4;8;". Uses ";" as the list
//							separator. Numbers are interpreted using str2num().
//
//		ClearAllSelectionsFirst
//							If non-zero, any rows already selected are de-selected before theRow is selected.
//							If zero, any rows already selected remain selected.
//
//	WMHL_SelectRangeOfRowNumbers(windowname, listcontrolname, StartRow, EndRow, ClearAllSelectionsFirst)
//		Selects all rows in a range of row numbers.
//
//		StartRow			the number of the first row to be selected.
//
//		EndRow				the number of the last row to be selected.
//
//		ClearAllSelectionsFirst
//							If non-zero, any rows already selected are de-selected before theRow is selected.
//							If zero, any rows already selected remain selected.
//
//	WMHL_ClearSelection(windowname, listcontrolname)
//		De-selects any selected rows.
//
//	WMHL_SelectedObjectsList(windowname, listcontrolname[, sepstr])
//		Returns a string containing a list of the selected items. Each item in the list is represented by its complete path.
//		Be sure that the separator string used as the path separator is different from the list separator character. By default,
//		the path separator is ":" and the list separator is ";".
//
//		sepstr				Optional string containing a separator character to separate each item in the list. Defaults to ";" just
//							like standard Igor lists. If you have set the path separator to ";", you must  use this parameter to set
//							the list separator to something else.
//
//	WMHL_ListChildRows(windowname, listcontrolname, parentRow)
//		Returns a string containing a list of the row numbers of the immediate children of the a given row.
//
//		parentRow			the number of a row whose children you wish to list. If you have an item path instead of a row number,
//							you can use WMHL_GetRowNumberForItem() to get the row number.
//
//	***************************
//	Notification Functions
//	***************************
//
//	The HierarchicalListWidget code communicates with your code via call-back functions. When something happens in the list,
//	your function is called with parameters that give information about the event, allowing your code to take appropriate actions.
//	There are three notification functions: Container Opened, Container Closed, and Selection.
//
//	Your function must have the same format as documented below. If it does not, you get no error indication, your function
// 	simply doesn't get called.
//
//	Container Opened Notification
//
//		Function YourContainerOpenNotifyProc(windowname, listcontrolname, ContainerPath)
//			String HostWindow, ListControlName, ContainerPath
//		end
//
//		This function is called whenever a container item is opened. It gives you a chance to add children to the container.
//		ContainerPath is a string containing the full path of the opened container; use it in calls to WMHL_AddObject().
//
//		Note that you are required to have a Container Opened Notification function, and you must provide the name of it
//		when you call MakeListIntoHierarchicalList(). You can change it later if you want using WMHL_SetNotificationProc().
//
//	Container Closed Notification
//
//		Function YourContainerClosedNotifyProc(windowname, listcontrolname, ContainerPath)
//			String windowname, listcontrolname, ContainerPath
//	
//		end
//
//		This function is called whenever a container item is closed. It gives you a chance to do any clean-up that might
//		be necessary as a result of the children being deleted. You are not required to supply a Container Closed function.
//		ContainerPath is a string containing the full path of the just-closed container.
//
//	Container Closing Notification
//
//		Function YourContainerClosingNotifyProc(windowname, listcontrolname, ContainerPath, FirstChildRow, LastChildRow)
//			String windowname, listcontrolname, ContainerPath
//			Variable firstChildRow, lastChildRow
//	
//		end
//
//		This function is called whenever a container item is about to be closed. It gives you a chance to store information
//		from any child rows that are about to be closed and deleted. Do not use this for cleaning up data associated with children;
//		use the Container Closed Notification for that. You are not required to supply a Container Closing function.
//		ContainerPath is a string containing the full path of the just-closed container.
//		FirstChildRow, LastChildRow are the row numbers of the first and last child rows for the container being closed. If the
//		container has no children, they will be set to -1.
//
//	Selection Notification
//
//		Function WMHL_YourSelectionNotificationProc(windowname, listcontrolname, SelectedItem, EventCode)
//			String windowname, listcontrolname
//			String SelectedItem
//			Variable EventCode
//	
//		end
//
//		This function is called whenever the user changes the selection, or when the user double-clicks an item.
//
//		SelectedItem		String containing the path to a selected item. This may not be useful in a list that
//							allows multiple selections.
//
//		EventCode			A number indicating what kind of event occurred. The codes are the same as ListBox
//							control event codes. So far, these events are reported:
//								3		double click.
//								4		cell selection (mouse or arrow keys).
//								5		cell selection plus shift key.
//
//	WMHL_SetNotificationProc(windowname, listcontrolname, procname, whichNotification)
//		This function changes or sets the function to be called for a given notification.
//
//		procname			A string containing the name of your function to be called.
//
//		whichNotification	A code indicating which notification function should be set. Use these pre-defined constants:
//								WMHL_SetSelectNotificationProc
//								WMHL_SetOpenedNotificationProc
//								WMHL_SetClosedNotificationProc
//								WMHL_SetClosingNotificationProc
//
// **********************************




// Layout of SelWave and ListWave
// ListWave:
//	Plane 0: column 0: "checkboxes" for containers, column 1: names of items indented to show hierarchy
//	Plane 1: column 0: item parent paths; column 1: item names with paths
//
// Selwave:
// 	Plane 0: has to work as a standard SelWave, with codes for checkboxes and selection

// constants for selectionMode parameter
Constant WMHL_SelectionNonContinguous = 0
Constant WMHL_SelectionContinguous = 1
Constant WMHL_SelectionSingle = 2

// constants for WMHL_SetNotificationProc() for whichNotification parameter
Constant WMHL_SetSelectNotificationProc = 0
Constant WMHL_SetOpenedNotificationProc = 1
Constant WMHL_SetClosedNotificationProc = 2
Constant WMHL_SetClosingNotificationProc = 3

// constants for error codes from MakeListIntoWaveSelector()
Constant WMHL_ErrorNoError = 0
Constant WMHL_ErrorOptionStringTooLong = 1

static Constant MAX_OBJ_NAME = 31
static Constant HierarchicalListVersion = 1.08

static StrConstant WMHL_UDInfoName = "HierarchicalListInfo"

// structure used to store information about the widget as user data in the listbox control
static Structure HierarchicalListListInfo
	int16	version
	char	colorDisclosure							// used with color support
	char	folderName[MAX_OBJ_NAME+1]		// last element of path starting with root:Packages:WM_WaveSelectorList:
	char	ListWaveName[MAX_OBJ_NAME+1]		// resides in folder named by folderName
	char	SelWaveName[MAX_OBJ_NAME+1]
	char	ContainerOpenNotifyProc[2*MAX_OBJ_NAME+2]
	char	ContainerClosedNotifyProc[2*MAX_OBJ_NAME+2]
	char	SelectionNotificationProc[2*MAX_OBJ_NAME+2]
	char	pathSep[2]
	char	UsersActionProc[2*MAX_OBJ_NAME+2]
	char	ContainerClosingNotifyProc[2*MAX_OBJ_NAME+2]
EndStructure

Function MakeListIntoHierarchicalList(windowname, listcontrolname, ContainerOpenNotifyProc, [selectionMode, pathSeparator, userListProc])
	String windowname
	String listcontrolname
	String ContainerOpenNotifyProc
	Variable selectionMode
	String pathSeparator
	String userListProc
	
	Variable err = WMHL_ErrorNoError
	
	if (ParamIsDefault(selectionMode))
		selectionMode = WMHL_SelectionNonContinguous
	endif
	
	if (ParamIsDefault(pathSeparator))
		pathSeparator = ":"
	endif
	
	if (ParamIsDefault(userListProc))
		userListProc = ""
	endif
	
	Variable selectMode = 10
	switch (selectionMode)
		case WMHL_SelectionNonContinguous:
			selectMode = 10
			break;
		case WMHL_SelectionContinguous:
			selectMode = 7
			break;
		case WMHL_SelectionSingle:
			selectMode = 6
			break;
	endswitch
	
	STRUCT HierarchicalListListInfo ListInfo
	String userdata = GetUserData(windowname, listcontrolname, WMHL_UDInfoName)
	StructGet/S ListInfo, userdata
	if (ListInfo.version != 0)
		KillDataFolder $("root:Packages:WM_HierarchicalList:"+ListInfo.folderName)
	endif
	
	ListInfo.version = HierarchicalListVersion
	ListInfo.ContainerOpenNotifyProc = ContainerOpenNotifyProc
	ListInfo.SelectionNotificationProc = ""
	ListInfo.ContainerClosedNotifyProc = ""
	ListInfo.ContainerClosingNotifyProc = ""
	ListInfo.pathSep = pathSeparator[0]
	ListInfo.UsersActionProc = userListProc
	
	ListBox $listcontrolname, win=$windowname, proc=HierarchicalListListProc,mode=selectMode
	ListBox $listcontrolname, win=$windowname, widths={20,500},keySelectCol=1,editStyle=1
	String SaveDF = GetDataFolder(1)
	SetDataFolder root:
	Variable nRootObjects = 1		// +1 for the root folder itself
	
	NewDataFolder/O/S Packages
	NewDataFolder/O/S WM_HierarchicalList
	ListInfo.folderName = UniqueName("HierarchicalListInfo", 11, 0)
	NewDataFolder/O/S $ListInfo.folderName
	Make/T/N=(1, 2, 2) ListWave		// second layer holds full path info
	Make/N=(1, 2) SelWave
	ListWave[0][1][1] = "<uninitialized>"
	ListBox $listcontrolname, win=$windowname, listWave=ListWave, selWave=SelWave
	ListInfo.ListWaveName = "ListWave"
	ListInfo.SelWaveName = "SelWave"
	String infoStr
	StructPut/S ListInfo, infoStr
	ListBox $listcontrolname, win=$windowname, userData($WMHL_UDInfoName)=infoStr
	
	SetDataFolder SaveDF
		
//	SetWindow $hostWindow, hook(HierarchicalListWidgetHook) = WMHL_WinHook
	
	return err
end

Function/S WMHL_SetUsersListboxProc(windowname, listcontrolname, procName)
	String windowname
	String listcontrolname
	String procName
	
	STRUCT HierarchicalListListInfo ListInfo
	String oldActionProc=""
	
	if (WMHL_GetListInfo(windowname, listcontrolname, ListInfo))
		oldActionProc = ListInfo.UsersActionProc
		ListInfo.UsersActionProc = procName
		string infoStr=""
		StructPut/S ListInfo, infoStr
		ListBox $listcontrolname, win=$windowname, userData($WMHL_UDInfoName)=infoStr
	endif
	
	return oldActionProc
end

Function WMHL_AddColorSupport(windowname, listcontrolname, colorWave, colorDisclosure)
	String windowname
	String listcontrolname
	Wave colorWave
	Variable colorDisclosure
	
	STRUCT HierarchicalListListInfo ListInfo
	if (WMHL_GetListInfo(windowname, listcontrolname, ListInfo))
		Wave SelWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.SelWaveName)
		
		Redimension/N=(-1, -1, 3) SelWave
		SetDimLabel 2,2,backColors,SelWave				// define plane 1 as background colors
		SetDimLabel 2,1,foreColors,SelWave				// redefine plane 1 s foreground colors
		SelWave[][][1,2] = 0
		ListBox $listcontrolname, win=$windowname, colorWave=colorWave
		ListInfo.colorDisclosure = colorDisclosure
		string infoStr=""
		StructPut/S ListInfo, infoStr
		ListBox $listcontrolname, win=$windowname, userData($WMHL_UDInfoName)=infoStr
	endif	
end	

Function WMHL_AddColumns(windowname, listcontrolname, nColumnsToAdd [, labelListStr])
	String windowname
	String listcontrolname
	Variable nColumnsToAdd
	String labelListStr
	
	STRUCT HierarchicalListListInfo ListInfo
	if (!WMHL_GetListInfo(windowname, listcontrolname, ListInfo))
		return -1
	endif
	
	Wave SelWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.SelWaveName)
	Wave/T ListWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.ListWaveName)

	Variable firstNewCol = DimSize(ListWave, 1)
	Variable ncols = firstNewCol+nColumnsToAdd
	Redimension/N=(-1, ncols, -1) ListWave
	Redimension/N=(-1, ncols) SelWave
	
	if (!ParamIsDefault(labelListStr))
		Variable nLabels = min(ItemsInList(labelListStr), nColumnsToAdd)
		Variable i
		for (i = 0; i < nLabels; i += 1)
			SetDimLabel 1, i+firstNewCol, $(StringFromList(i, labelListStr)), ListWave
		endfor
	endif
	
	ListBox $listcontrolname, win=$windowname, userColumnResize=1
	
	return 0
end

Function WMHL_ExtraColumnData(windowname, listcontrolname, extraColumnNumber, theRow, dataString, makeEditable [, setSelWaveValue, foreColor, backColor])
	String windowname
	String listcontrolname
	Variable extraColumnNumber, theRow
	String dataString
	Variable makeEditable
	Variable setSelWaveValue
	Variable foreColor
	Variable backColor
	
	STRUCT HierarchicalListListInfo ListInfo
	if (!WMHL_GetListInfo(windowname, listcontrolname, ListInfo))
		return -1
	endif
	
	Wave SelWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.SelWaveName)
	Wave/T ListWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.ListWaveName)
	
	Variable col = extraColumnNumber+2
	ListWave[theRow][col][0] = dataString
	
	if (setSelWaveValue != 0)
		SelWave[theRow][col][0] = setSelWaveValue
	else
		if (makeEditable)
			SelWave[theRow][col][0] = 2
		else
			SelWave[theRow][col][0] = 0
		endif
	endif
	
	if (!paramIsDefault(foreColor))
		if (FindDimLabel(SelWave, 2, "foreColors") > -2)
			SelWave[theRow][col][%foreColors] = foreColor
		endif
	endif
	if (!paramIsDefault(backColor))
		if (FindDimLabel(SelWave, 2, "backColors") > -2)
			SelWave[theRow][col][%backColors] = backColor
		endif
	endif
end

Function/S WMHL_GetExtraColumnData(windowname, listcontrolname, extraColumnNumber, theRow)
	String windowname
	String listcontrolname
	Variable extraColumnNumber, theRow

	STRUCT HierarchicalListListInfo ListInfo
	if (!WMHL_GetListInfo(windowname, listcontrolname, ListInfo))
		return ""
	endif
	
	Wave/T ListWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.ListWaveName)
	
	if (theRow >= DimSize(ListWave, 0))
		return ""
	endif
	
	Variable col = extraColumnNumber+2
	
	if ( (col > DimSize(ListWave, 1)) || (col < extraColumnNumber) )
		return ""
	endif
	
	return ListWave[theRow][extraColumnNumber+2][0]
end

Function WMHL_GetExtraColumnSelValue(windowname, listcontrolname, extraColumnNumber, theRow)
	String windowname
	String listcontrolname
	Variable extraColumnNumber, theRow

	STRUCT HierarchicalListListInfo ListInfo
	if (!WMHL_GetListInfo(windowname, listcontrolname, ListInfo))
		return NaN
	endif

	Wave SelWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.SelWaveName)
	Variable col = extraColumnNumber+2
	return SelWave[theRow][col][0]
end

Function WMHL_AddObject(windowname, listcontrolname, ParentPath, ObjectName, ItsAContainer [, foreColor, backColor])
	String windowname
	String listcontrolname
	String ParentPath
	String ObjectName
	Variable ItsAContainer
	Variable foreColor, backColor
	
	STRUCT HierarchicalListListInfo ListInfo
	if (WMHL_GetListInfo(windowname, listcontrolname, ListInfo))
		WMHL_AddObjectToList(ListInfo, ParentPath, ObjectName, ItsAContainer, foreColor, backColor)
	endif
end

Function ContainerOpenNotifyProcTemplate(HostWindow, ListControlName, ContainerPath)
	String HostWindow, ListControlName, ContainerPath
	
end

Function ContainerClosedNotifyTemplate(HostWindow, ListControlName, ContainerPath, ContainerParentPath)
	String HostWindow, ListControlName, ContainerPath, ContainerParentPath
	
end

Function ContainerClosingNotifyTemplate(HostWindow, ListControlName, ContainerPath, ContainerParentPath, FirstChildRow, LastChildRow)
	String HostWindow, ListControlName, ContainerPath, ContainerParentPath
	Variable FirstChildRow, LastChildRow
	
end

Function/S WMHL_SelectedObjectsList(windowname, listcontrolname[, sepstr])
	String windowname
	String listcontrolname
	String sepstr

	if (ParamIsDefault(sepstr))
		sepstr = ";"
	endif

	STRUCT HierarchicalListListInfo ListInfo
	if (WMHL_GetListInfo(windowname, listcontrolname, ListInfo))
		return WMHL_GetSelectedObjectsList(ListInfo, sepstr)
	endif

	return ""
end
	
Function WMHL_ClearSelection(windowname, listcontrolname)
	String windowname
	String listcontrolname

	STRUCT HierarchicalListListInfo ListInfo
	if (WMHL_GetListInfo(windowname, listcontrolname, ListInfo) == 0)
		return 0
	endif
	
	Wave SelWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.SelWaveName)

	SelWave[][1][0] = 0
end

Function WMHL_OpenAContainer(windowname, listcontrolname, FullItemPath)
	String windowname
	String listcontrolname
	String FullItemPath
	
	if (strlen(FullItemPath) == 0)
		return 0
	endif
	
	STRUCT HierarchicalListListInfo ListInfo
	if (WMHL_GetListInfo(windowname, listcontrolname, ListInfo) == 0)
		return 1
	endif
	
	Wave SelWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.SelWaveName)
	Wave/T ListWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.ListWaveName)
	
	Variable nrows = DimSize(ListWave, 0)
	Variable i
	Variable lastcharpos = StrLen(FullItemPath)-1
	if (CmpStr(FullItemPath[lastcharpos], ListInfo.pathSep) == 0)
		FullItemPath = FullItemPath[0, lastcharpos-1]
	endif
	
	for (i = 0; i < nrows; i += 1)
		if ((SelWave[i][0][0] & 0x40) == 0)		// is it a disclosure triangle?
			continue
		endif
		if (CmpStr(ListWave[i][1][1], FullItemPath) == 0)
			if ( (SelWave[i][0][0] & 0x10)  == 0)
				WMHL_OpenContainer(ListInfo, i, windowname, listcontrolname)
				SelWave[i][0][0] = SelWave[i][0][0] | 0x10
			endif
			break;
		endif
	endfor
	
	return 0
end

Function WMHL_CloseAContainer(windowname, listcontrolname, FullItemPath)
	String windowname
	String listcontrolname
	String FullItemPath
	
	if (strlen(FullItemPath) == 0)
		return 0
	endif
	
	STRUCT HierarchicalListListInfo ListInfo
	if (WMHL_GetListInfo(windowname, listcontrolname, ListInfo) == 0)
		return 1
	endif
	
	Wave SelWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.SelWaveName)
	Wave/T ListWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.ListWaveName)
	
	Variable nrows = DimSize(ListWave, 0)
	Variable i
	Variable lastcharpos = StrLen(FullItemPath)-1
	if (CmpStr(FullItemPath[lastcharpos], ListInfo.pathSep) == 0)
		FullItemPath = FullItemPath[0, lastcharpos-1]
	endif
	
	for (i = 0; i < nrows; i += 1)
		if ((SelWave[i][0][0] & 0x40) == 0)		// is it a disclosure triangle?
			continue
		endif
		if (CmpStr(ListWave[i][1][1], FullItemPath) == 0)
			if ( (SelWave[i][0][0] & 0x10)  != 0)
				WMHL_CloseContainer(ListInfo, i, windowname, listcontrolname)
				SelWave[i][0][0] = 0x40
			endif
			break;
		endif
	endfor
	
	return 0
end

Function WMHL_SetNotificationProc(windowname, listcontrolname, procname, whichNotification)
	String windowname
	String listcontrolname
	String procname
	Variable whichNotification
	
	STRUCT HierarchicalListListInfo ListInfo
	if (WMHL_GetListInfo(windowname, listcontrolname, ListInfo))
		switch (whichNotification)
			case WMHL_SetSelectNotificationProc:
				ListInfo.SelectionNotificationProc = procname
				break
			case WMHL_SetOpenedNotificationProc:
				ListInfo.ContainerOpenNotifyProc = procname
				break
			case WMHL_SetClosedNotificationProc:
				ListInfo.ContainerClosedNotifyProc = procname
				break
			case WMHL_SetClosingNotificationProc:
				ListInfo.ContainerClosingNotifyProc = procname
				break
		endswitch
	
		string infoStr=""
		StructPut/S ListInfo, infoStr
		ListBox $listcontrolname, win=$windowname, userData($WMHL_UDInfoName)=infoStr
	endif	
end

Function/S WMHL_GetItemForRowNumber(windowname, listcontrolname, theRow)
	String windowname
	String listcontrolname
	Variable theRow
	
	String returnString = ""
	
	STRUCT HierarchicalListListInfo ListInfo
	if (WMHL_GetListInfo(windowname, listcontrolname, ListInfo))
		Wave/T ListWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.ListWaveName)
		Variable nRows = DimSize(ListWave, 0)
		if ( (theRow >= 0) && (theRow < nRows) )
			return ListWave[theRow][1][1]
		endif
	endif
	
	return returnString
end

Function WMHL_GetRowNumberForItem(windowname, listcontrolname, theItem)
	String windowname
	String listcontrolname
	String theItem
	
	Variable returnRow = -1
	
	STRUCT HierarchicalListListInfo ListInfo
	if (WMHL_GetListInfo(windowname, listcontrolname, ListInfo))
		Wave/T ListWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.ListWaveName)
		Variable nRows = DimSize(ListWave, 0)
		Variable i
		for (i = 0; i < nRows; i += 1)
			if (CmpStr(theItem, ListWave[i][1][1]) == 0)
				returnRow = i
				break;
			endif
		endfor
	endif
	
	return returnRow
end

Function WMHL_ChangeItem(windowname, listcontrolname, theItemPath, newItemName)
	String windowname
	String listcontrolname
	String theItemPath
	String newItemName

	STRUCT HierarchicalListListInfo ListInfo
	if (WMHL_GetListInfo(windowname, listcontrolname, ListInfo))
		Wave/T ListWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.ListWaveName)
		Variable nRows = DimSize(ListWave, 0)
		Variable i
		for (i = 0; i < nRows; i += 1)
			if (CmpStr(theItemPath, ListWave[i][1][1]) == 0)
				String ParentPath = ListWave[i][0][1]
				ListWave[i][1][0] = WMHL_IndentString(ParentPath, ListInfo.pathSep) + newItemName
				String newItemPath
				if (strlen(ParentPath) == 0)
					newItemPath = newItemName
				else
					newItemPath = ParentPath+ListInfo.pathSep+newItemName
				endif
				ListWave[i][1][1] = newItemPath
				break
			endif
		endfor
		if ( WMHL_RowIsContainer(windowname, listcontrolname, i) && WMHL_RowIsOpen(windowname, listcontrolname, i) )
			Variable oldLength = strlen(theItemPath)
			Variable newLength = strlen(newItemPath)
			for (i = i + 1; i < nRows; i += 1)
				if (CmpStr((ListWave[i][0][1])[0,oldLength-1], theItemPath) == 0)
					ListWave[i][0][1] = newItemPath + (ListWave[i][0][1])[oldLength, inf]
					ListWave[i][1][1] = newItemPath + (ListWave[i][1][1])[oldLength, inf]
				else 
					break;
				endif
			endfor
		endif
	endif
end

Function WMHL_GetNumberOfRows(windowname, listcontrolname)
	String windowname
	String listcontrolname

	STRUCT HierarchicalListListInfo ListInfo
	if (WMHL_GetListInfo(windowname, listcontrolname, ListInfo))
		Wave SelWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.SelWaveName)
		return DimSize(SelWave, 0)
	endif
	
	return -1
end

Function WMHL_RowIsContainer(windowname, listcontrolname, theRow)
	String windowname
	String listcontrolname
	Variable theRow

	STRUCT HierarchicalListListInfo ListInfo
	if (WMHL_GetListInfo(windowname, listcontrolname, ListInfo))
		Wave SelWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.SelWaveName)
		return (SelWave[theRow][0][0] & 0x40) != 0
	endif
end

Function WMHL_RowIsOpen(windowname, listcontrolname, theRow)
	String windowname
	String listcontrolname
	Variable theRow

	STRUCT HierarchicalListListInfo ListInfo
	if (WMHL_GetListInfo(windowname, listcontrolname, ListInfo))
		Wave SelWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.SelWaveName)
		return ((SelWave[theRow][0][0] & 0x40) != 0) && ((SelWave[theRow][0][0] & 0x10) != 0)
	endif
end

Function/S WMHL_GetParentItemForRow(windowname, listcontrolname, theRow)
	String windowname
	String listcontrolname
	Variable theRow

	STRUCT HierarchicalListListInfo ListInfo
	if (WMHL_GetListInfo(windowname, listcontrolname, ListInfo))
		Wave/T ListWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.ListWaveName)
		return ListWave[theRow][0][1]
	endif
end

Function WMHL_SelectARow(windowname, listcontrolname, theRow, ClearAllSelectionsFirst)
	String windowname
	String listcontrolname
	Variable theRow
	Variable ClearAllSelectionsFirst

	STRUCT HierarchicalListListInfo ListInfo
	if (WMHL_GetListInfo(windowname, listcontrolname, ListInfo))
		Wave SelWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.SelWaveName)
		Variable nRows = DimSize(SelWave, 0)
		if ( (theRow < 0) || (theRow >= nRows) )
			return 0
		endif
		if (ClearAllSelectionsFirst)
			SelWave[][1][0] = 0
		endif
		SelWave[theRow][1][0] = 1
	endif
end

Function WMHL_SelectListOfRowNumbers(windowname, listcontrolname, RowList, ClearAllSelectionsFirst)
	String windowname
	String listcontrolname
	String RowList
	Variable ClearAllSelectionsFirst
	
	STRUCT HierarchicalListListInfo ListInfo
	if (WMHL_GetListInfo(windowname, listcontrolname, ListInfo))
		Wave SelWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.SelWaveName)
		if (ClearAllSelectionsFirst)
			SelWave[][1][0] = 0
		endif
		Variable nItems = ItemsInList(RowList)
		Variable i
		for (i = 0; i < nItems; i += 1)
			WMHL_SelectARow(windowname, listcontrolname, str2num(StringFromList(i, RowList)), 0)
		endfor
	endif
end

Function WMHL_SelectRangeOfRowNumbers(windowname, listcontrolname, StartRow, EndRow, ClearAllSelectionsFirst)
	String windowname
	String listcontrolname
	Variable StartRow, EndRow
	Variable ClearAllSelectionsFirst
	
	STRUCT HierarchicalListListInfo ListInfo
	if (WMHL_GetListInfo(windowname, listcontrolname, ListInfo))
		Wave SelWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.SelWaveName)
		if (ClearAllSelectionsFirst)
			SelWave[][1][0] = 0
		endif
		Variable i
		for (i = StartRow; i <= EndRow; i += 1)
			WMHL_SelectARow(windowname, listcontrolname, i, 0)
		endfor
	endif
end

Function WMHL_DeleteRowAndChildren(windowname, listcontrolname, theRow)
	String windowname
	String listcontrolname
	Variable theRow

	STRUCT HierarchicalListListInfo ListInfo
	if (WMHL_GetListInfo(windowname, listcontrolname, ListInfo))
		Wave SelWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.SelWaveName)
		Wave/T ListWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.ListWaveName)
		Variable lastRow = theRow
		if ( WMHL_RowIsContainer(windowname, listcontrolname, theRow) && WMHL_RowIsOpen(windowname, listcontrolname, theRow) )
			lastRow = WMHL_FindLastChild(ListInfo, theRow)
		endif
		Variable numRowsToDelete = lastRow-theRow+1
		if (numRowsToDelete == DimSize(SelWave, 0))
			// JW 131022 We are deleting all rows in the list. If we remove all the rows in the waves, they will forget that they are
			// multicolumn waves. So here we just return the list to the same state as it was in when it was new, except that if WMHL_AddColumns()
			// has been used, it will have more columns than a new list.
			Redimension/N=(1, -1, -1, -1) SelWave
			Redimension/N=(1, -1, -1, -1) ListWave
			ListWave = ""
			ListWave[0][1][1] = "<uninitialized>"
			SelWave = 0
		else
			DeletePoints/M=0 theRow, lastRow-theRow+1, SelWave, ListWave
		endif
	endif
end

// creates a list of row numbers of rows that are immediate children of the item in parentRow
Function/S WMHL_ListChildRows(windowname, listcontrolname, parentRow)
	String windowname
	String listcontrolname
	Variable parentRow
	
	String theList = ""

	STRUCT HierarchicalListListInfo ListInfo
	if (WMHL_GetListInfo(windowname, listcontrolname, ListInfo))
		Variable lastRow = parentRow
		if ( WMHL_RowIsContainer(windowname, listcontrolname, parentRow) && WMHL_RowIsOpen(windowname, listcontrolname, parentRow) )
			lastRow = WMHL_FindLastChild(ListInfo, parentRow)
		endif
		if (lastRow > parentRow)
			String parentItem = WMHL_GetItemForRowNumber(windowname, listcontrolname, parentRow)
			Variable i
			for (i = parentRow+1; i <= lastRow; i += 1)
				String childsParentItem = WMHL_GetParentItemForRow(windowname, listcontrolname, i)
				if (CmpStr(parentItem, childsParentItem) == 0)
					theList += num2str(i)+";"
				endif
			endfor
		endif
	endif
	
	return theList
end

// private functions

static Function WMHL_GetListInfo(windowname, listcontrolname, ListInfo)
	String windowname, listcontrolname
	STRUCT HierarchicalListListInfo &ListInfo

	String userdata = GetUserData(windowname, listcontrolname, WMHL_UDInfoName)
	StructGet/S ListInfo, userdata
	if (ListInfo.version == 0)
		return 0	// failure
	endif
	
	return 1		// success
end

static Function WMHL_FindRowForItemPath(ListInfo, itemPath)
	STRUCT HierarchicalListListInfo &ListInfo
	String itemPath

	Wave SelWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.SelWaveName)
	Wave/T ListWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.ListWaveName)
	Variable nRows = DimSize(SelWave, 0)

	Variable i
	for (i = 0; i < nRows; i += 1)
		if (CmpStr(ListWave[i][1][1], itemPath) == 0)
			return i
		endif
	endfor
	
	return -1
end

static Function WMHL_FindLastChild(ListInfo, parentRow)
	STRUCT HierarchicalListListInfo &ListInfo
	Variable parentRow
	
	Wave SelWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.SelWaveName)
	Wave/T ListWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.ListWaveName)
	Variable nRows = DimSize(SelWave, 0)

	if ( (SelWave[parentRow][0][0] & 0x40) == 0)		// not a container
		return -1
	endif
	String parentPath = ListWave[parentRow][1][1]
	Variable lastCharPos = strlen(parentPath)-1
	Variable i
	for (i = parentRow+1; i < nRows; i += 1)
		if (CmpStr((ListWave[i][0][1])[0,lastCharPos], parentPath) != 0)	// found a parent path that doesn't match, it must not be a child
			return i-1
		endif
	endfor
	
	return nRows-1
end

// Layout of SelWave and ListWave
// ListWave:
//	Plane 0: column 0: "checkboxes" for containers, column 1: names of items indented to show hierarchy
//	Plane 1: column 0: item parent paths; column 1: item names with paths
//
// Selwave:
// 	Plane 0: has to work as a standard SelWave, with codes for checkboxes and selection
static Function WMHL_AddObjectToList(ListInfo, ParentPath, ObjectName, ItsAContainer, foreColor, backColor)
	STRUCT HierarchicalListListInfo &ListInfo
	String ParentPath, ObjectName
	Variable ItsAContainer
	Variable foreColor, backColor

	Wave SelWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.SelWaveName)
	Wave/T ListWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.ListWaveName)
	Variable nRows = DimSize(SelWave, 0)
	Variable theRow

	if (strlen(ParentPath) == 0)
		if ( (nRows == 1) && (CmpStr(ListWave[0][1][1], "<uninitialized>") == 0) )
			nRows = 0
		else
			InsertPoints nRows, 1, SelWave, ListWave
		endif
		SelWave[nRows][0][0] = ItsAContainer ? 0x40 : 0
		SelWave[nRows][1][0] = 0
		ListWave[nRows][0][0] = ""
		ListWave[nRows][1][0] = ObjectName
		ListWave[nRows][0][1] = ""			// null parent
		ListWave[nRows][1][1] = ObjectName	// no path- it's at root level
		theRow = nRows
	else
		theRow = WMHL_FindRowForItemPath(ListInfo, ParentPath)
		theRow = WMHL_FindLastChild(ListInfo, theRow)
		if (theRow < 0)
			return 0
		endif
		theRow += 1
		InsertPoints theRow, 1, SelWave, ListWave
		SelWave[theRow][0][0] = ItsAContainer ? 0x40 : 0
		SelWave[theRow][1][0] = 0
		ListWave[theRow][0][0] = ""
		ListWave[theRow][1][0] = WMHL_IndentString(ParentPath, ListInfo.pathSep)+ObjectName
		ListWave[theRow][0][1] = ParentPath
		ListWave[theRow][1][1] = ParentPath+ListInfo.pathSep+ObjectName
	endif
	if (DimSize(SelWave, 2) > 1)
		Variable firstCol = ListInfo.colorDisclosure ? 0 : 1
		SelWave[theRow][firstCol,][%foreColors] = foreColor
		SelWave[theRow][firstCol,][%backColors] = backColor
	endif
end

static Function/S WMHL_IndentString(ParentPath, pathseparator)
	String ParentPath, pathseparator
	
	if (strlen(ParentPath) == 0)
		return ""			// no parent path means this should be a top-level item, and that means no indent
	endif
	
	String path = ParentPath+pathseparator
	Variable pos = 0
	String indentString = ""
	do
		pos = strsearch(path, pathseparator, pos)
		if (pos < 0)
			break
		endif
		indentString += "    "
		pos += 1
	while (1)
	
	return indentString
end

static Function WMHL_OpenContainer(ListInfo, DataFolderRow, windowname, controlname)
	STRUCT HierarchicalListListInfo &ListInfo
	Variable DataFolderRow		// row number in list that contains the data folder to be opened
	String windowname, controlname
	
	Wave/T ListWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.ListWaveName)
	String containerPath = ListWave[DataFolderRow][1][1]

	FUNCREF ContainerOpenNotifyProcTemplate  openfunc  = $(ListInfo.ContainerOpenNotifyProc)
	openfunc(windowname, controlname, containerPath)
end

static Function WMHL_CloseContainer(ListInfo, DataFolderRow, windowname, controlname)
	STRUCT HierarchicalListListInfo &ListInfo
	Variable DataFolderRow		// row number in list that contains the data folder to be opened	
	String windowname, controlname
	
	Wave SelWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.SelWaveName)
	Wave/T ListWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.ListWaveName)
	String containerPath = ListWave[DataFolderRow][1][1]
	String containerParentPath = ListWave[DataFolderRow][0][1]
	
	Variable theRow = WMHL_FindLastChild(ListInfo, DataFolderRow)
	if (theRow < 0)
		return 0
	endif

	Variable firstChildRow = DataFolderRow+1
	Variable lastChildRow = theRow
	FUNCREF ContainerClosingNotifyTemplate  closingfunc  = $(ListInfo.ContainerClosingNotifyProc)
	closingfunc(windowname, controlname, containerPath, containerParentPath, firstChildRow, lastChildRow)
	
	DeletePoints DataFolderRow+1, theRow-DataFolderRow, SelWave, ListWave

	FUNCREF ContainerClosedNotifyTemplate  closefunc  = $(ListInfo.ContainerClosedNotifyProc)
	closefunc(windowname, controlname, containerPath, containerParentPath)
end

//Function WMHL_WinHook(H_Struct)
//	STRUCT WMWinHookStruct &H_Struct
//	
//	Variable statusCode = 0
//	
//	STRUCT HierarchicalListListInfo ListInfo
//	String cList = ControlNameList(H_Struct.winName)
//	Variable i, j
//	Variable nItems = ItemsInList(cList)
//	for (i = 0; i < nItems; i += 1)
//		String ctrlName = StringFromList(i, cList)
//		String userdata = GetUserData(H_Struct.winName, ctrlName, WMHL_UDInfoName)
//		ListInfo.version = 0
//		StructGet/S ListInfo, userdata
//		if (ListInfo.version == 0)
//			continue
//		endif
//		
//		switch (H_Struct.eventCode)
////			case 0:							// activate
////				WS_UpdateWaveSelectorWidget(H_Struct.winName, ctrlName)
////				break;
//			case 2:							// Kill window
//				KillControl/W=$H_Struct.winName $ctrlName
//				KillDataFolder $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName)
//				break;
//		endswitch
//	endfor
//	
//	return statusCode		// 0 if nothing done, else 1
//End

Function WMHL_NotificationTemplate(HostWindow, ListControlName, SelectedItem, EventCode)
	String HostWindow, ListControlName
	String SelectedItem
	Variable EventCode
	
end

Function ListProcTemplate(LB_Struct) : ListboxControl
	STRUCT WMListboxAction &LB_Struct
	
	return 0
end

Function WMHL_KillData(rootWindow, containerWindow, folderName)
	String rootWindow, containerWindow, folderName
	
	// if a recreation macro exists, don't kill the data folder containing the list waves!
	if (Exists("ProcGlobal#"+rootWindow) == 5)
		return 0
	endif
	
	KillDataFolder $("root:Packages:WM_HierarchicalList:"+folderName)
end

Function HierarchicalListListProc(LB_Struct) : ListboxControl
	STRUCT WMListboxAction &LB_Struct
	
	STRUCT HierarchicalListListInfo ListInfo
	if (WMHL_GetListInfo(LB_Struct.win, LB_Struct.ctrlName, ListInfo) == 0)
		return 0
	endif

	Variable didSomething = 0
	
	Wave SelWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.SelWaveName)
	Wave/T ListWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.ListWaveName)
	Variable numRows = DimSize(SelWave, 0)
	
	Variable index=0
	switch(LB_Struct.eventCode)
		case -1:			// listbox being killed
			String cmd = GetIndependentModuleName()+"#WMHL_KillData(\""
			cmd += StringFromList(0, LB_Struct.win, "#")
			cmd += "\",\""
			cmd += LB_Struct.win
			cmd += "\",\""
			cmd += ListInfo.FolderName
			cmd += "\")"
			Execute/P/Q cmd
			break;
		case 1:			// mouse down
			if ( (LB_Struct.row >= 0) && (LB_Struct.row < numRows) && (LB_Struct.col == 0) )
				if (SelWave[LB_Struct.row][0][0] & 0x40)
					SelWave[LB_Struct.row][0][0] = SelWave[LB_Struct.row][0][0] & ~1
					didSomething = 1
				endif
			endif
			break;
		case 2:			// mouse up
			if ( (LB_Struct.row >= 0) && (LB_Struct.row < numRows) && (LB_Struct.col == 0) )
				if (SelWave[LB_Struct.row][0][0] & 0x40)
					if (SelWave[LB_Struct.row][0][0] & 0x10)	// if it's checked, it needs to be opened
						WMHL_OpenContainer(ListInfo, LB_Struct.row, LB_Struct.win, LB_Struct.ctrlName)
					else
						WMHL_CloseContainer(ListInfo, LB_Struct.row, LB_Struct.win, LB_Struct.ctrlName)
					endif
					didSomething = 1
				endif
			endif
			break;
		case 3:			// double-click
			if ( (LB_Struct.row >= 0) && (LB_Struct.row < numRows) && (LB_Struct.col == 1) )
				FUNCREF WMHL_NotificationTemplate notifyFunc = $(ListInfo.SelectionNotificationProc)
				notifyFunc(LB_Struct.win, LB_Struct.ctrlName, ListWave[LB_Struct.row][1][1], LB_Struct.eventCode)
				didSomething = 1
			endif
			break;
		case 4:
		case 5:
			if ( (LB_Struct.row >= 0) && (LB_Struct.row < numRows) && (LB_Struct.col == 1) )
				FUNCREF WMHL_NotificationTemplate notifyFunc = $(ListInfo.SelectionNotificationProc)
				notifyFunc(LB_Struct.win, LB_Struct.ctrlName, ListWave[LB_Struct.row][1][1], LB_Struct.eventCode)
				didSomething = 1
			endif
			break;
	endswitch
	
	if (!didSomething)
		if (strlen(ListInfo.UsersActionProc) > 0)
			FUNCREF ListProcTemplate listProc=$ListInfo.UsersActionProc
			return listProc(LB_Struct)
		endif
	endif

	return 0
end

static Function/S returnIndentString(text)
	String text
	
	String returnStr
	
	Variable space = char2num(" ")
	Variable i=0
	Variable len = StrLen(text)
	for (i = 0; i < len; i += 1)
		if (char2num(text[i]) != space)
			break;
		endif	
	endfor
	
	returnStr = PadString("", i, space)
	return returnStr
end

static Function/S WMHL_GetSelectedObjectsList(ListInfo, sepstr)
	STRUCT HierarchicalListListInfo &ListInfo
	string sepstr
	
	Wave SelWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.SelWaveName)
	Wave/T ListWave = $("root:Packages:WM_HierarchicalList:"+ListInfo.FolderName+":"+ListInfo.ListWaveName)
	
	Variable nrows = DimSize(ListWave, 0)
	Variable i
	String theList = ""
	for (i = 0; i < nrows; i += 1)
		if (SelWave[i][1][0] & 9)
			theList += ListWave[i][1][1] + sepstr
		endif
	endfor
	
	return theList
end
