#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method.
#pragma moduleName=GizmoUtils
#pragma IgorVersion=7	// assumes Igor 7's built-in Gizmo, winType=17
#pragma version=7		// shipped with Igor 7

//#define DEBUGGING

//
// JP27JUN07:	version=6.02
//				Added XYZSubsetToXYZTriplet() function, rewrote WMMakeTripletDialog() to accept subrange.
//				Added memory of previous entries which are shared with XYZToTripletToXYZ.ipf's XYZToXYZTriplet() and XYZSubsetToXYZTriplet().
//
// AG03MAY07: updated WMMakeTripletWave to use Concatenate.  Also added test for cancel from DoPrompt.
// AG10SEP08 Added Exporting panel routines.
//
// JP10AUG11: version=6.2
//				Moved in public versions of generally useful routines previously duplicated in various Gizmo-related procedure files.
//				GizmoEchoExecute has slashQ optional parameter to make it easier to either echo or not echo Gizmo commands.
//				GetGizmoCoordinates() now works if the Gizmo window has a custom title, also works on Windows.
//				Revised Export panel.
//				Added Aspect Ratio menu item and action routines.
//				Fixed RestoreGizmoFixedAspect to create an ortho object if one wasn't in the display list.
//				Renamed export dialog, kills old named panel, to avoid mixing them up.
//
// JP17NOV11: version=6.23
//				Added GetGizmoPixels(gizmoName, left, top, right, bottom) and GetGizmoPoints(gizmoName, left, top, right, bottom)
//				which don't depend on the recreation macro formatting.

// JP24MAY16: version=7
//				Built-in Gizmo operation no longer requires the Execute hack, has a new winType (17)

// NOTE: WMMakeTripletDialog works only with waves in only the current data folder.
Function WMMakeTripletDialog()

	String srcx= StrVarOrDefault("root:Packages:WMMakeTriplet:srcx","")
	String srcy= StrVarOrDefault("root:Packages:WMMakeTriplet:srcy","")
	String srcz= StrVarOrDefault("root:Packages:WMMakeTriplet:srcz","")
	String outName=StrVarOrDefault("root:Packages:WMMakeTriplet:outName","myTriplet")
	Variable minX=NumVarOrDefault("root:Packages:WMMakeTriplet:minX",NaN)
	Variable maxX=NumVarOrDefault("root:Packages:WMMakeTriplet:maxX",NaN)
	Variable minY=NumVarOrDefault("root:Packages:WMMakeTriplet:minY",NaN)
	Variable maxY=NumVarOrDefault("root:Packages:WMMakeTriplet:maxY",NaN)
	Variable mktbl=NumVarOrDefault("root:Packages:WMMakeTriplet:mktbl",2)	// No
	Prompt srcx,"X-Wave",popup,WaveList("*",";","DIMS:1")
	Prompt srcy,"Y-Wave",popup,WaveList("*",";","DIMS:1")
	Prompt srcz,"Z-Wave",popup,WaveList("*",";","DIMS:1")
	Prompt outName,"Triplet Wave Name:"
	Prompt minx,"Minimum X or NaN for no min:"
	Prompt maxX,"Maximum X or NaN for no max:"
	Prompt minY,"Minimum Y or NaN for no min:"
	Prompt maxY,"Maximum Y or NaN for no max:"
	Prompt mktbl,"Put triplet wave in new table?",popup,"Yes;No"
	DoPrompt "3 Waves To Triplet XY Subset",srcx,minX,srcy,maxX,srcz,minY,outName,maxY,mkTbl
	if( V_Flag == 0 )	// continue
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:WMMakeTriplet
		String/G root:Packages:WMMakeTriplet:srcx = srcx
		String/G root:Packages:WMMakeTriplet:srcy = srcy
		String/G root:Packages:WMMakeTriplet:srcz = srcz
		String/G root:Packages:WMMakeTriplet:outName = outName
		Variable/G root:Packages:WMMakeTriplet:minX= minX
		Variable/G root:Packages:WMMakeTriplet:maxX= maxX
		Variable/G root:Packages:WMMakeTriplet:minY= minY
		Variable/G root:Packages:WMMakeTriplet:maxY= maxY
		Variable/G root:Packages:WMMakeTriplet:mktbl= mktbl

		Variable succeeded
		Wave xWave=$srcx
		Wave yWave=$srcy
		Wave zWave=$srcz
		if( numtype(minX) == 0 || numtype(maxX) == 0 || numtype(minY) == 0 || numtype(maxY) == 0 )
			succeeded= WMMakeTripletWaveSubset(xWave,yWave,zWave,outName,minX,maxX,minY,maxY)
		else
			succeeded= WMMakeTripletWave(xWave,yWave,zWave,outName)	// faster
		endif
		if( succeeded && (mktbl == 1) )
			Preferences 1
			Wave triplet=$outName
			Edit triplet
		endif
	endif
End


// The following function converts from 3 1D waves into a single triplet wave.
// Values that exceed the min or max values are excluded.
Function WMMakeTripletWaveSubset(xWave,yWave,zWave,outName,minX,maxX,minY,maxY)
	Wave xWave,yWave,zWave
	Variable minx,maxX,minY,maxY
	String outName
	if(NumPnts(xWave)!=NumPnts(yWave) || NumPnts(xWave)!=NumPnts(zWave))
		DoAlert 0, "All three waves must have the same number of points!"
		return 0
	endif
	Variable i, n= NumPnts(xWave), xOK, yOK, numOK=0
	Duplicate/O zWave, $outName
	Wave tripletWave=$outName
	Redimension/N=(n,3) tripletWave
	for(i=0; i<n; i+=1)
		xOK= 1
		if( (xWave[i] < minx) || (xWave[i] > maxX) )		// a comparison with NaN is always false
			xOK= 0
		endif
		yOK= 1
		if( (yWave[i] < minY) || (yWave[i] > maxY) )		// a comparison with NaN is always false
			yOK= 0
		endif
		if( xOK && yOK )
			tripletWave[numOK][0]=xWave[i]
			tripletWave[numOK][1]=yWave[i]
			tripletWave[numOK][2]=zWave[i]
			numOK += 1
		endif
	endfor
	Redimension/N=(numOK,3) tripletWave
	return 1
End

// The following function converts from 3 1D waves into a single triplet wave.
Function WMMakeTripletWave(xWave,yWave,zWave,outName)
	Wave xWave,yWave,zWave
	String outName
	
	if(numpnts(xWave)!=numpnts(yWave) || numpnts(xWave)!=numpnts(zWave))
		DoAlert 0, "All three waves must have the same number of points!"
		return 0
	endif
	Concatenate/O/DL {xWave,yWave,zWave},$outName
	return 1
End

//==============================================================================================
// Gizmo Export Dialog
//==============================================================================================

// 6.2: Revisions make it useful to rename the dialog from "WMGizmoExportPanel" to "WMGizmoExportPanel62"
// so as to detect old dialogs left open in experiments.

static StrConstant ksPanelName= "WMGizmoExportPanel62"

Function WM_EGPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			Variable disable= (popNum<4) ? 0 : 1
			SetVariable WM_EGAsNameSetVar,win=$ksPanelName,disable=disable
			FixAsName()
			String warning=""
			// PopupMenu WM_EGDestPop,mode=1,popvalue="Image File",value= #"\"Image File;EPS File;2D RGB Wave;Printer;Clipboard\""
			if( popNum == 2 )	// "EPS File"
				warning="\\JCEPS format will not succeed if "+TopGizmo()+"\ruses any form of transparency (alpha blending)."
			endif
			TitleBox warning,win=$ksPanelName, title=warning
			
			// output resolution factor is for only bitmap ("Image File") output
			disable= (popNum == 1) ? 0 : 1
			PopupMenu resolution,win=$ksPanelName, disable=disable
			
			disable= (popNum == 3) ? 0 : 1
			CheckBox displayRGB,win=$ksPanelName, disable=disable
			break
	endswitch

	return 0
End

Function WM_EGDoitButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
		
			// check for old dialog
			strswitch( ba.win )
				// list obsolete dialog names here
				case "WMGizmoExportPanel":
					DoAlert 0, "This Export dialog is too old. Click OK to use the new one."
					Execute/P/Q/Z "DoWindow/K "+ba.win
					Execute/P/Q/Z GetIndependentModuleName()+"#GizmoUtils#WM_GizmoExportPanel()"
					return 0
					break
			endswitch
		
			ControlInfo/W=$ksPanelName WM_EGEchoCheck
			Variable quiet= V_Value == 0

			String cmd
			cmd="ExportGizmo"
			String name=""
			ControlInfo/W=$ksPanelName WM_EGDestPop
			String format= S_Value
			ControlInfo/W=$ksPanelName WM_EGAsNameSetVar
			String fileName= S_Value
			Variable exportingWave=0
			strswitch(format)
				case "EPS File":
					cmd+=" EPS as \""+fileName+"\""
				break

				case "Image File":
					ControlInfo/W=$ksPanelName WM_EGAsNameSetVar
					cmd+=" as \""+fileName+"\""

					ControlInfo/W=$ksPanelName resolution
					Variable resolutionFactor= str2num(StringFromList(0,S_Value," "))
					String cmd2
					sprintf cmd2, "ModifyGizmo outputResFactor=%g", resolutionFactor
					GizmoEchoExecute(cmd2, slashZ=1, slashQ=quiet)
				break
				
				case "2D RGB Wave":
					ControlInfo/W=$ksPanelName WM_EGAsNameSetVar
					cmd+=" WAVE as \""+fileName+"\""
					exportingWave=1
				break
				
				case "Printer":
					cmd+=" print"
				break
				
				case "Clipboard":
					cmd+=" clip"
				break
			endswitch
			
			GizmoEchoExecute(cmd, slashZ=1, slashQ=quiet)
			
			if( exportingWave )
				ControlInfo/W=$ksPanelName	displayRGB
				if( V_Value )
					Wave/Z w= $fileName
					if( WaveExists(w) )
						NewImage w
					endif
				endif
			endif
		break
	endswitch

	return 0
End

static Function FixAsName()

	ControlInfo/W=$ksPanelName WM_EGAsNameSetVar
	String fileName= S_Value

	// Replace "Gizmo[digits]" with topGizmo name
	String expr="(.*)(Gizmo[_[:digit:]]*)(.*)"
	String stuffBefore, currentGizmoName, stuffAfter
	SplitString/E=(expr) fileName, stuffBefore, currentGizmoName, stuffAfter
	if( V_flag >= 2 )
		fileName= stuffBefore+TopGizmo()+stuffAfter
	endif

	String withoutExtension= StringFromList(0,fileName,".")
	
	ControlInfo/W=$ksPanelName WM_EGDestPop	// value= #"\"Image File;EPS File;2D RGB Wave;Printer;Clipboard\""
	strswitch( S_Value )
		case "Image File":
			if( IsMacintosh() )
				fileName= withoutExtension +".pct"
			else
				fileName= withoutExtension +".bmp"
			endif
			break
		case "EPS File":
			fileName = withoutExtension +".eps"
			break
		case "2D RGB Wave":
			fileName = withoutExtension
			break
		default:	// Printer and Clipboard don't use as "whatever"
			return 0
			break
	endswitch

	SetVariable WM_EGAsNameSetVar,win=$ksPanelName,value=_STR:fileName
	return 1
End

static Function UpdateExportPanelForTopGizmo()

	DoWindow $ksPanelName
	if( V_Flag )
		String gizmoName= TopGizmo()
		if( ValidGizmoName(gizmoName) )
			DoWindow/T $ksPanelName, "Gizmo Export ("+gizmoName+")"
			FixAsName()
		endif
	endif
End

Function GizmoExportWindowHook(s)
	STRUCT WMWinHookStruct &s
	
	strswitch( s.eventName )
		case "activate":
			UpdateExportPanelForTopGizmo()
			break
	endswitch
	
	return 0
End
	
Function WM_GizmoExportPanel()

	DoWindow/K WMGizmoExportPanel	// pre-6.2
	DoWindow/F $ksPanelName
	Variable panelExisted= V_Flag
	if( panelExisted )
		// UpdateExportPanelForTopGizmo()	// activate hook will do this.
		return 0
	endif

	NewPanel /K=1/W=(241,681,684,807)/N=$ksPanelName as "Gizmo Export"
	DefaultGuiFont/W=#/Mac popup={"_IgorMedium",12,0},all={"_IgorMedium",12,0}
	DefaultGuiFont/W=#/Win popup={"_IgorMedium",0,0},all={"_IgorMedium",0,0}

	String gizmoName= TopGizmo()
	if( ValidGizmoName(gizmoName) )
		AutoPositionWindow/M=1/R=$gizmoName $ksPanelName
	endif
	
	PopupMenu WM_EGDestPop,pos={14,20},size={173,20},proc=WM_EGPopMenuProc,title="Export Target:"
	PopupMenu WM_EGDestPop,fSize=12
	PopupMenu WM_EGDestPop,mode=1,popvalue="Image File",value= #"\"Image File;EPS File;2D RGB Wave;Printer;Clipboard\""
	Button WM_EGDoitButton,pos={17,86},size={100,20},proc=WM_EGDoitButtonProc,title="Do It"
	CheckBox WM_EGEchoCheck,pos={14,54},size={173,16},title="Echo commands to history"
	CheckBox WM_EGEchoCheck,fSize=12,value=1
	SetVariable WM_EGAsNameSetVar pos={222,20}, size={172,19},bodyWidth=150,title="As:"
	String fileName= CleanupName(TopGizmo()+"Exported",0)
	SetVariable WM_EGAsNameSetVar,fSize=12,value=_STR:fileName
	TitleBox warning,pos={201,54},size={209,24},fsize=9,title="",frame=0,fColor=(65535,0,0)
	PopupMenu resolution,pos={224,53},size={163,20},title="Output Resolution Factor:"
	PopupMenu resolution,mode=1,value= #"\"1 x;2 x;3 x;4 x;\""	// keep a space between the number and anything else in each item.
	CheckBox displayRGB,pos={218,57},size={211,16},title="Make Image Plot of 2D RGB Wave",value= 1, disable=1

	ModifyPanel fixedSize=1, noEdit=1
	SetWindow $ksPanelName hook(GizmoExport)= GizmoExportWindowHook
	UpdateExportPanelForTopGizmo()
End

//==============================================================================================
// GizmoUtils-specific data folders
//==============================================================================================

static StrConstant ksPackageName="WMGizmo"

// Routines for temporary use only: WMGizmoDF(), WMGizmoDFVar(), SetWMGizmoDF()
Function/S WMGizmoDF()
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:WMGizmo
	return "root:Packages:WMGizmo"
End

Function/S WMGizmoDFVar(varName)
	String varName
	
	return WMGizmoDF()+":"+PossiblyQuoteName(varName)
End

// Set the data folder to a place where Execute can dump all kinds of variables and waves.
// Returns the old data folder.
Function/S SetWMGizmoDF()

	String oldDF= GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S $WMGizmoDF()	// DF is left pointing here to an existing or created data folder.
	return oldDF
End

//==============================================================================================
// GizmoUtils per-gizmo data folders
//==============================================================================================

// WMPerGizmoDFVar uses the stored data folder name ("dfName") saved in the Gizmo's WMGizmo userString.
// See PackagePerGizmoDFVar().
//
// root:Packages:WMGizmo:PerGizmoData:dfName:varName
//
// Public because GizmoOrthoZoom.ipf calls WMPerGizmoDFVar

Function/S WMPerGizmoDFVar(gizmoName,varName)
	String gizmoName,varName

	return PackagePerGizmoDFVar(gizmoName,ksPackageName,varName)
End

//==============================================================================================
// Package per-gizmo data folders
//==============================================================================================

// JP19MAR10:
// GizmoUtils-related Per-gizmo data folders are created as subfolders under 
// root:Packages:WMGizmo:PerGizmoData:dfName
// where dfName is typically the same as the gizmo window's name
// The dfName is stored in the Gizmo window using the new userString
// keywords for ModifyGizmo and GetGizmo (thanks, AG!)
//
// (The use of a dfName instead of gizmoName to located a data folder
// means that when the user renames the window you don't lose the connection
// to the corresponding data folder.)
//
// Also see PackagePerGizmoDFVar()
//

static Function/S StringNameForPackage(packageName)
	String packageName

	return packageName[0,28]+"_DF"
End

// Rather than use PackagePerGizmoDFVar directly in a package (procedure file),
// it makes sense to define and use a static routine with the packageName hard-coded:
//
//	static Function/S MyPerGizmoDFVar(gizmoName,varName)
//		String gizmoName,varName
//	
//		return PackagePerGizmoDFVar(gizmoName,"MyPackage",varName)
//	End
//
// No liberal names allowed, use CleanupName(name,0) if needed.
//
// root:Packages:packageName:PerGizmoData:dfName:varName
Function/S PackagePerGizmoDFVar(gizmoName,packageName,varName[,dfName])
	String gizmoName
	String packageName	
	String varName	// varName can be "" to return "root:Packages:packageName:PerGizmoData:dfName"
	String dfName	// optional input (usually optional. supplied only when the gizmo window no longer exists, then gizmoName is not used.)

	if( ParamIsDefault(dfName) || strlen(dfName)==0)	// "" is the same as not present.
		if( !ValidGizmoName(gizmoName) )
			return ""
		endif
		String stringName= StringNameForPackage(packageName)
		dfName= GetGizmoUserString(gizmoName,stringName)	// NOTE: can be different dfName per package and per Gizmo
		if( strlen(dfName) == 0 )
			dfName= CreateNewPackagePerGizmoDF(gizmoName,packageName)
		endif
	endif
	// In case the data folder has been deleted by mistake, we ensure it exists here
	NewDataFolder/O root:Packages
	String path= "root:Packages:"+packageName
	NewDataFolder/O $path
	path += ":PerGizmoData"
	NewDataFolder/O $path
	path += ":"+dfName
	NewDataFolder/O $path
	if( strlen(varName) )
		path += ":"+PossiblyQuoteName(varName)
	endif
	return path
End

// returns old data folder
Function/S SetPackagePerGizmoDF(gizmoName,packageName[,dfName])
	String gizmoName
	String packageName	
	String dfName	// optional input (usually optional. supplied only when the gizmo window no longer exists, then gizmoName is not used.)

	String oldDF= GetDataFolder(1)
	if( ParamIsDefault(dfName) )
		dfName=""	// PackagePerGizmoDFVar() considers "" the same as not present.
	endif
	String df= PackagePerGizmoDFVar(gizmoName,packageName,"",dfName=dfName)
	NewDataFolder/S $df
	
	return oldDF
End

// also stores the dfName in the "dataFolderName" string inside the Gizmo window's Packages group
Function/S CreateNewPackagePerGizmoDF(gizmoName,packageName)
	String gizmoName,packageName

	String oldDF= GetDataFolder(1)
	
	// Ensure that the PerGizmoData data folder hierarchy for the package exists
	NewDataFolder/O/S root:Packages
	String perGizmoRootDF= "root:Packages:"+packageName
	NewDataFolder/O $perGizmoRootDF
	perGizmoRootDF += ":PerGizmoData"
	NewDataFolder/O/S $perGizmoRootDF
	
	// Determine a unique data folder name for the named Gizmo
	String newDFName= gizmoName
	if( DataFolderExists(newDFName) )
		// here is the point where dfName becomes not the same as gizmoName.
		newDFName= CleanupName("DF_"+newDFName,0)
		newDFName= UniqueName(newDFName,11,0)
	endif
	String path= perGizmoRootDF+":"+newDFName
	NewDataFolder/O $path

	// Save the location in a Gizmo userString
	String stringName= StringNameForPackage(packageName)
	SetGizmoUserString(gizmoName, stringName, newDFName)

	// TESTING
	String dfName= GetGizmoUserString(gizmoName, stringName)
	if( CmpStr(dfName, newDFName) != 0 )
		Print "gizmo did not remember \""+newDFName+"\" properly: it came back as \""+dfName+"\"!"
	endif
	
	SetDataFolder oldDF
	return newDFName
End

Function/S GetPackagePerGizmoDFName(gizmoName, packageName)
	String gizmoName, packageName

	if( !ValidGizmoName(gizmoName) )
		return ""
	endif
	String stringName= StringNameForPackage(packageName)
	String dfName= GetGizmoUserString(gizmoName, stringName)
	return dfName
End

//==============================================================================================
// Gizmo name, states, display, object, attribute items and lists
//==============================================================================================

Function/S TopGizmo()

	String gizmoName= WinName(0,65536)	// new for Igor 7
	return gizmoName
End

// returns truth that the returned gizmoName is valid.
Function ValidGizmoName(gizmoName)
	String &gizmoName	// input and output, can be "" on input to become TopGizmo on output

	if( strlen(gizmoName) == 0 )
		gizmoName= TopGizmo()
		return strlen(gizmoName) > 0
	endif
	return WinType(gizmoName) == 17	// new for Igor 7
End

// NOTE: ModifyGizmo compile is a no-op
Function RecompileGizmo(gizmoName)
	String gizmoName

	if( !ValidGizmoName(gizmoName) )
		return 0
	endif
	ModifyGizmo/N=$gizmoName update=1
	return 1
End

Function UpdateGizmo(gizmoName,mode)
	String gizmoName
	Variable mode	// forces redraw of the Gizmo Display window.
					// mode =0:	performs a silent update mostly during idle events.
					// mode =1:	checks if any object needs updating and if so recompiles it. Otherwise checks if there was any scale or rotation change and if so redraws the display. See Recompiling for details.
					// mode =2:	forces immediate update that includes reloading all the waves, finding the minima and maxima, computing their scale factors and redrawing the associated objects.
	if( !ValidGizmoName(gizmoName) )
		return 0
	endif
	ModifyGizmo/N=$gizmoName update=mode
	return 1
End

// To get a list from a group, set the current group object before calling GizmoList() or NameIsInGizmo*():
//
//	ModifyGizmo currentGroupObject="group0"	// Use Execute if you do this in a function
//	String list=GizmoList("","objectNameList")	// top gizmo window
//	ModifyGizmo currentGroupObject="::"
//
Function/S GizmoList(gizmoName, listName)
	String gizmoName
	String listName	// one of "displayNameList", "objectNameList", or "attributeNameList", "gizmoNameList"
					// or one of "displayList", "objectList", or "attributeList"
	
	if( !ValidGizmoName(gizmoName) )
		return ""
	endif
	String list=""
	String twWaveName=""
	String oldDF= SetWMGizmoDF()
	strswitch(listName)
		case "displayNameList":
			GetGizmo/N=$gizmoName displayNameList
			list=S_DisplayNames
			break
		case "objectNameList":
			GetGizmo/N=$gizmoName objectNameList
			list=S_ObjectNames
			break
		case "attributeNameList":
			GetGizmo/N=$gizmoName attributeNameList
			list=S_AttributeNames
			break
		case "gizmoNameList":
			GetGizmo/N=$gizmoName gizmoNameList
			list=S_GizmoNames
			break
		case "displayList":
			twWaveName="TW_DisplayList"
			GetGizmo/N=$gizmoName displayList
			list=S_DisplayList
			break
		case "objectList":
			twWaveName="TW_gizmoObjectList"
			GetGizmo/N=$gizmoName objectList
			list=S_gizmoObjectList
			break
		case "attributeList":
			twWaveName="TW_AttributeList"
			GetGizmo/N=$gizmoName displayNameList
			list=S_AttributeList
			break
	endswitch
	if( strlen(twWaveName) )
		list= StripLeadingTabsInList(list)
		KillWaves/Z $twWaveName
	endif
	SetDataFolder oldDF
	return list
End


static Function/S StripLeadingTabsInList(list)
	String list
	
	String cleanedList=""
	Variable i,n=ItemsInList(list)
	for(i=0; i<n; i+=1 )
		String item= StringFromList(i,list)
		if( CmpStr(item[0],"\t") == 0 )
			item[0,0]=""
		endif
		cleanedList += item+";"
	endfor
	return cleanedList
End

// Usage: if( NameIsInGizmoDisplayList("Gizmo0", "surface0") )		// to see if surface0 is in Gizmo0's display list.
//
// To check a list in a group, set the current group object before calling NameIsInGizmo*():
//
//	ModifyGizmo currentGroupObject="group0"	// Use Execute if you do this in a function
//	Variable isInList=NameIsInGizmoDisplayList(gizmoName,"surface0")
//	ModifyGizmo currentGroupObject="::"
//
// (Requires Igor 6.2B03 or later to take the current object into account.)

Function NameIsInGizmoList(gizmoName,name,list)
	String gizmoName,name
	String list			// one of "displayItemExists", "objectItemExists", or "attributeItemExists"
	
	Variable isInList= 0
	if( ValidGizmoName(gizmoName) )
		strswitch(list)
			case "displayItemExists":
				isInList = NameIsInGizmoDisplayList(gizmoName, name)
				break
			case "objectItemExists":
				isInList = NameIsInGizmoObjectList(gizmoName, name)
				break
			case "attributeItemExists":
				isInList = NameIsInGizmoAttributeList(gizmoName, name)
				break
		endswitch
	endif
	return isInList
End

Function NameIsInGizmoDisplayList(gizmoName,name)
	String gizmoName	// name of gizmo Window
	String name			// name of object

	GetGizmo/N=$gizmoName displayItemExists=$name
	return V_Flag
End

Function NameIsInGizmoObjectList(gizmoName,name)
	String gizmoName	// name of gizmo Window
	String name			// name of object

	GetGizmo/N=$gizmoName objectItemExists=$name
	return V_Flag
End

Function NameIsInGizmoAttributeList(gizmoName,name)
	String gizmoName	// name of gizmo Window
	String name			// name of object

	GetGizmo/N=$gizmoName attributeItemExists=$name
	return V_Flag
End

Function GetDisplayIndexOfNamedObject(gizmoName,name)
	String gizmoName	// name of gizmo Window
	String name			// name of object

	if( !ValidGizmoName(gizmoName) )
		return -1
	endif
	String nameList= GizmoList(gizmoName, "displayNameList")
	Variable index= WhichListItem(UpperStr(name),UpperStr(nameList))	// ignores case, returns zero-based index
	return index
End

Function/S GetAttributeListOfNamedObject(gizmoName,name)
	String gizmoName	// name of gizmo Window
	String name			// name of object

	if( !ValidGizmoName(gizmoName) )
		return ""
	endif
	String nameList= GizmoList(gizmoName, "objectAttributeList") // all the named attributes associated with the named object.
	return nameList
End

static Function/S SkipLeadingSpaces(str)
	String str
	
	for(; strlen(str) > 0 ; )
		if( CmpStr(str[0]," ") != 0 )
			return str
		endif
		str[0,0]=""
	endfor
	return str
End

// returns truth that one of these operations was found in the display list of the root/top-level group
Function FindFirstTranslateRotateScaleOp(gizmoName, displayIndex, opName, operation)
	String gizmoName	// input
	Variable &displayIndex	// output: displayIndex of found operation
	String &opName			// output: name of found operation
	String &operation		// output: one of "translate", "rotate", or "scale"

	displayIndex= -1	// -1 means "not found"
	opName= ""
	operation= ""

	// gets the ortho from the root level of the gizmo
	//	String code= WinRecreation(gizmoName, 0)
	String code= GetGizmoGroupObjectCommands(gizmoName, "" ,removeSubgroups=1)	// "" to get only top-level commands (avoid orthos in subgroups)

	// Parse
	//	ModifyGizmo setDisplayList=3, opName=translate0, operation=translate, data={0,0,1.41}
	//	ModifyGizmo setDisplayList=5, opName=rotate1, operation=rotate, data={-135,0,1,0}
	//	ModifyGizmo setDisplayList=6, opName=scale0, operation=scale, data={0.25,0.25,0.25}
	String regexpr= "(?i)ModifyGizmo setDisplayList=[[:digit:]]+, opName=[[:alnum:]]+, operation=(translate|rotate|scale), data={"
	String matchingLines= GrepList(code, regExpr, 0,  "\r")
	Variable haveMatch= ItemsInList(matchingLines,  "\r")
	if( haveMatch )
		matchingLines= StringFromList(0, matchingLines, "\r")
		String indexAsString
		regexpr= "(?i)ModifyGizmo setDisplayList=([[:digit:]]+), opName=([[:alnum:]]+), operation=(translate|rotate|scale), data={"
		SplitString/E=(regExpr) matchingLines, indexAsString,opName,operation
		displayIndex= str2num(indexAsString)
	endif

	return haveMatch
End

// ignores the currentGroupObject; use pathToGroup
Function NamedObjectIsClipped(gizmoName, name [, pathToGroup])
	String gizmoName	// name of gizmo Window
	String name			// name of object
	String pathToGroup	// optional input, use "" to get only objects in the top level (the default), use "group0" to get only objects in group0

	String code
	if( ParamIsDefault(pathToGroup) )	// search the entire recreation macro? No, get only the top group
		code= GetGizmoGroupObjectCommands(gizmoName, "" ,removeSubgroups=1,removeCurrentGroupObject=1)
	else
		code= GetGizmoGroupObjectCommands(gizmoName, pathToGroup ,removeSubgroups=1,removeCurrentGroupObject=1)
	endif
	
	// ModifyGizmo modifyObject=string0 property={Clipped,0}
	Variable isClipped= 1	// the default for an object is clipped
	String propertyStr
	GizmoObjectPropertyFromLines(code, name, "clipped", propertyStr, isClipped)

	return isClipped
End

Function/S UniqueGizmoObjectName(gizmoName,name,list)
	String gizmoName	// name of gizmo Window. Use "" for top gizmo window (if any)
	String name			// name of object. if it already exists in the list, a name unique to the list is returned.
	String list			// one of "displayItemExists", "objectItemExists", or "attributeItemExists"

	String uniqueObjectName= name
	String nameNoZero= RemoveEnding(name,"0")	// so you can set name to "surface0", and get "surface0" or "surface1", instead of "surface01"
	Variable num= 0
	do
		if( !NameIsInGizmoList(gizmoName,uniqueObjectName, list) )
			return uniqueObjectName
		endif
		uniqueObjectName= CleanupName(nameNoZero[0,27]+num2istr(num),0)
		num += 1
	while( num < 999 )
	return ""	// should not get here
End

// returns truth that stringmatch understands str and that it is not just a constant string
static Function IsMatchStringExpression(str)
	String str
	
	if( strsearch(str, "*", 0) >= 0 )
		return 1
	endif
	if( strsearch(str, "!", 0) >= 0 )
		return 1
	endif
	return 0
End

// requires Gizmo window, returns resulting display list
Function/S RemoveMatchingGizmoDisplay(gizmoName,matchstringlist)
	String gizmoName
	String matchstringlist	// match expression such as "object*" or "!object" etc, or list of object names, but NOT BOTH

	String list= GizmoList(gizmoName,"displayNameList")
	Variable isMatchExpression= IsMatchStringExpression(matchstringlist)
	Variable i=0
	do
		String name= StringFromList(i,list)
		if( strlen(name) == 0 )
			break
		endif
		Variable deleteThisObject= 0
		if( isMatchExpression )
			deleteThisObject= 1 == stringmatch(name, matchstringlist)
		else
			deleteThisObject= WhichListItem(name, matchstringlist) >= 0
		endif
		if( deleteThisObject )
			RemoveFromGizmo/N=$gizmoName displayItem=$name
		endif
		i+=1
	while(1)
	
	list= GizmoList(gizmoName,"displayNameList")

	return list
End

// requires Gizmo window, returns the resulting object list
Function/S RemoveMatchingGizmoObjects(gizmoName,matchstringlist)
	String gizmoName
	String matchstringlist	// match expression such as "object*", or list of object names, but NOT BOTH

	String list= GizmoList(gizmoName,"objectNameList")
	Variable isMatchExpression= IsMatchStringExpression(matchstringlist)
	Variable i=0
	do
		String name= StringFromList(i,list)
		if( strlen(name) == 0 )
			break
		endif
		Variable deleteThisObject= 0
		if( isMatchExpression )
			deleteThisObject= 1 == stringmatch(name, matchstringlist)
		else
			deleteThisObject= WhichListItem(name, matchstringlist) >= 0
		endif
		if( deleteThisObject )
			RemoveFromGizmo/N=$gizmoName object=$name
		endif
		i+=1
	while(1)

	list= GizmoList(gizmoName,"objectNameList")

	return list
End

// requires Gizmo window, returns the resulting attribute list
Function/S RemoveMatchingGizmoAttributes(gizmoName,matchstringlist)
	String gizmoName
	String matchstringlist	// match expression such as "attribute*", or list of attribute names, but NOT BOTH

	String list= GizmoList(gizmoName,"attributeNameList")
	Variable isMatchExpression= IsMatchStringExpression(matchstringlist)
	Variable i=0
	do
		String name= StringFromList(i,list)
		if( strlen(name) == 0 )
			break
		endif
		Variable deleteThis= 0
		if( isMatchExpression )
			deleteThis= 1 == stringmatch(name, matchstringlist)
		else
			deleteThis= WhichListItem(name, matchstringlist) >= 0
		endif
		if( deleteThis )
			RemoveFromGizmo/N=$gizmoName attribute=$name
		endif
		i+=1
	while(1)

	list= GizmoList(gizmoName,"attributeNameList")	
	
	return list
End


// returns display index where the named object was moved to in the display list, or -1 if error
Function MoveObjectBeforeMainTransform(gizmoName,name)
	String gizmoName,name

	if( !ValidGizmoName(gizmoName) )
		return -1
	endif
	
	Variable objectDisplayIndex= GetDisplayIndexOfNamedObject(gizmoName,name)
	Variable haveNamedObject=  objectDisplayIndex >= 0
	if( !haveNamedObject )
		return -1
	endif

	Variable mainTransformIndex= GetDisplayIndexOfNamedObject(gizmoName,"MainTransform")
	Variable haveMainTransform=  mainTransformIndex >= 0
	
	// perhaps no change is needed
	if( haveMainTransform )
		if( objectDisplayIndex < mainTransformIndex )
			return objectDisplayIndex
		endif	
	endif
	
	String cmds= "ModifyGizmo/N="+gizmoName+" startRecMacro" 

	// either there's no MainTransform or the object isn't in the display list in the right place.
	// Regardless, since we can't actually MOVE the object, we've got to remove it from the display list and re-insert it.
	RemoveMatchingGizmoDisplay(gizmoName,name)
	if( haveMainTransform )
		mainTransformIndex= GetDisplayIndexOfNamedObject(gizmoName,"MainTransform")
	else
		cmds += ";ModifyGizmo/N="+gizmoName+" insertDisplayList=0, opName=MainTransform, operation=mainTransform"
		mainTransformIndex= 0	// not yet, but after the ModifyGizmo command executes
	endif
	cmds += ";ModifyGizmo/N="+gizmoName+" insertDisplayList="+num2istr(mainTransformIndex)+", object="+name	// insert object before the main Transform
	cmds += ";ModifyGizmo/N="+gizmoName+" endRecMacro"

	String curDF=SetWMGizmoDF()
	GizmoEchoExecute(cmds, slashZ=1, slashQ=1)
	SetDataFolder curDF

	return mainTransformIndex	// now the index where the the object is listed.
End

//==============================================================================================
// Gizmo Window routines
//==============================================================================================

Function GetGizmoCoordinates(gizmoName, left, top, right, bottom)
	String gizmoName
	Variable &left, &top, &right, &bottom	// output: these are in points, not pixels

	left=0; top=0; right=0; bottom=0
	
	if( !ValidGizmoName(gizmoName) )
		return 0
	endif
	GetWindow $gizmoName wsizeRM // points, same as MoveWindow
	left= V_Left
	top= V_top
	right= V_right
	bottom= V_bottom
	return 1
End

// 6.23
Function GetGizmoPixels(gizmoName, left, top, right, bottom)
	String gizmoName
	Variable &left, &top, &right, &bottom	// output: these are in global pixels (GetGizmo winPixels)

	if( !ValidGizmoName(gizmoName) )
		left=0; top=0; right=0; bottom=0
		return 0
	endif
	GetGizmo/N=$gizmoName winPixels
	left= V_left; top= V_top; right= V_right; bottom= V_bottom
	return 1
End

// 6.23
Function GetGizmoPoints(gizmoName, left, top, right, bottom)
	String gizmoName
	Variable &left, &top, &right, &bottom	// output: these are in global pixels (GetGizmo winPixels)

	left=0; top=0; right=0; bottom=0
	
	Variable success= GetGizmoPixels(gizmoName, left, top, right, bottom)
	
	left *= 72 / ScreenResolution
	top *= 72 / ScreenResolution
	right *= 72 / ScreenResolution
	bottom *= 72 / ScreenResolution
	return success
End

//==============================================================================================
// Gizmo recreation text routines
//==============================================================================================

// Parsing Gizmo recreation macros has it's problems,
// one of which is that the case and spacing of the commands isn't entirely consistent.
//
// For example:
// 	ModifyGizmo ModifyObject=imageSurface0 property={ CLIPPED,0}
//	ModifyGizmo modifyObject=imageSurface0 property={Clipped,0}
//	ModifyGizmo ModifyObject=pie4 property={ translate,0,0,0}
//	ModifyGizmo modifyObject=pie4 property={calcNormals,1}
//
// So using String key="ModifyGizmo ModifyObject=imageSurface0 property={ Clipped,"
//	Variable start= strsearch(lines, key,0,2)	// case insensitive
// isn't always going to work.
// Returns the zero-based line number + 1 in which the object was found in lines
Function GizmoObjectPropertyFromLines(lines, objectName, propertyName, propertyStr, propertyNum)
	String lines							//  \r-separated list of commands from WinRecreation(gizmoName,0)
	String objectName, propertyName	// inputs
	String &propertyStr		// output: stuff after "ModifyGizmo ModifyObject=imageSurface0 property={" and before the last "}", as a string
	Variable &propertyNum	// output, propertyStr as number, for multiple values this is the first value

	Variable lineNumPlusOne= 0	// failure
	propertyStr=""
	propertyNum= NaN
	
	String regExpr= "(?i)ModifyGizmo +ModifyObject="+objectName+" +property=\\{ *"+propertyName+" *,"	// leave off \\} to make calling SplitString easier
	String matchingLines= GrepList(lines, regExpr, 0,  "\r")
	String firstLine= StringFromList(0, matchingLines, "\r")
	if( strlen(firstLine) )
		lineNumPlusOne= 1+WhichListitem(firstLine, lines,"\r")
		regExpr += "(.*)\\}"
		SplitString/E=(regExpr) firstLine, propertyStr
		if( V_flag == 1 )
			propertyNum = str2num(StringFromList(0,propertyStr,","))
		endif
	endif
	return lineNumPlusOne
End

Function/S GrepGizmoRecreation(gizmoName,regExpr[,ignoreCase,onlyFirst])
	String gizmoName, regExpr
	Variable ignoreCase	// if true (the default), case is ignored. If you set this, don't start regExpr with "(?i)"
	Variable onlyFirst	// if true, returns only the first match. The default is false, which returns all matching lines

	if( !ValidGizmoName(gizmoName) )
		return ""
	endif
	if( ParamIsDefault(ignoreCase) )
		ignoreCase= 1
	endif
	if( ParamIsDefault(onlyFirst) )
		onlyFirst= 0
	endif
	if( ignoreCase )
		regExpr= "(?i)"+regExpr
	endif
	String code= WinRecreation(gizmoName, 0)
	String matchingLines= GrepList(code, regExpr, 0,  "\r")
	if( onlyFirst )
		matchingLines= StringFromList(0, matchingLines, "\r")
	endif
	return matchingLines
End


Function GizmoRecreationContains(gizmoName,str[,ignoreCase])
	String gizmoName, str
	Variable ignoreCase

	if( !ValidGizmoName(gizmoName) )
		return 0
	endif
	if( ParamIsDefault(ignoreCase) )
		ignoreCase= 1
	endif
	Variable options= ignoreCase ? 2 : 0
	String code= WinRecreation(gizmoName, 0)
	Variable start= strsearch(code,str, 0, options)
	return start+1	// so that a match at the very start isn't 0 (though it is unlikely).
End

//==============================================================================================
// Generic recreation text routines
//==============================================================================================

// returns offset to start the current line. 
// sets lineStr to the line WITHOUT the trailing \r.
Static Function GetEntireLine(code, offset, lineStr)
	String code
	Variable offset	// input: offset anywhere in current line
	String &lineStr	// output
	
	Variable lineStart= strsearch(code, "\r", offset,1)	// search backwards
	if( lineStart < 0 )
		lineStart= 0	// first line
	else
		lineStart += 1
	endif
	Variable lineEnd= strsearch(code, "\r", lineStart)
	if( lineEnd < 0 )
		lineStr= code[lineStart,strlen(code)-1]
	else
		lineStr= code[lineStart,lineEnd-1]	// no trailing \r
	endif
	
	return lineStart
End

// returns offset to start of next line, or -1 if no more lines,
// sets lineStr to the line WITHOUT the trailing \r.
Static Function GetNextLine(code, offset, lineStr)
	String code
	Variable offset	// input: offset in current line
	String &lineStr	// output
	
	Variable nextStart= SkipToNextLine(code, offset)
	if( nextStart < 0 )
		lineStr=""
	else
		Variable lineEnd= strsearch(code, "\r", nextStart)
		if( lineEnd < 0 )
			lineStr= code[nextStart,strlen(code)-1]
		else
			lineStr= code[nextStart,lineEnd-1]	// no trailing \r
		endif
	endif
	
	return nextStart
End

// returns offset to next line, or -1 if offset is in the last line of text
static Function SkipToNextLine(code, offset)
	String code	// \r or <separator> delimited text
	Variable offset	// current position, goal is to return offset to the start of the next line

	Variable codeEnd= strlen(code)-1
	if( offset >= codeEnd )
		return -1
	endif
	
	String separator= "\r"
	if( CmpStr(code[offset], separator) == 0 )
		return offset + 1
	endif
	
	Variable lineEnd= strsearch(code, separator, offset)
	if( lineEnd < 0 )
		return -1
	endif
	return lineEnd + 1
End

//==============================================================================================
// Gizmo userString routines
//==============================================================================================

Function/S GetGizmoUserString(gizmoName, userStringName)
	String gizmoName, userStringName

	if( !ValidGizmoName(gizmoName) )
		return ""
	endif
	GetGizmo/N=$gizmoName userstring=$userStringName
	return S_GizmoUserString
End

// returns previous string, if any
Function/S SetGizmoUserString(gizmoName, userStringName, userStringValue)
	String gizmoName, userStringName, userStringValue

	if( !ValidGizmoName(gizmoName) )
		return ""
	endif

	GetGizmo/N=$gizmoName userstring=$userStringName
	String oldString= S_GizmoUserString

	ModifyGizmo/N=$gizmoName userString={$userStringName,userStringValue}

	return oldString
End


//==============================================================================================
// Gizmo string object routines
//==============================================================================================

// TO DO: Make this work better with groups (currently it scans the entire window recreation macro)
Function/S GetGizmoStringValue(gizmoName, stringObjectName)
	String gizmoName, stringObjectName
	
	if( !ValidGizmoName(gizmoName) )
		return ""
	endif
	String str=""
	if( NameIsInGizmoObjectList(gizmoName,stringObjectName) )
		// parse  AppendToGizmo string="<string value>",strFont="Geneva",name=<stringObjectName>
		String regexpr= "AppendToGizmo string=.*,name="+stringObjectName
		String line= GrepGizmoRecreation(gizmoName,regExpr,onlyFirst=1)
		if( strlen(line) )
			 regexpr= "AppendToGizmo string=\"(.*)\",strFont="
			SplitString/E=(regexpr) line, str
		endif
	endif
	return str
End

//==============================================================================================
// Gizmo Execute commands routines
//==============================================================================================

static Function IsMacintosh()

	String platform= IgorInfo(2)
	return CmpStr(platform,"Macintosh") == 0
End

// Users have noticed that the Gizmo commands are never echoed to the history, so we do that now.
// You may want to change the current data folder before using this,
// because Execute will leave V_Flag and other things in the current data folder.
Function GizmoEchoExecute(commands, [slashP, slashZ, slashQ])
	String commands
	Variable slashP, slashZ, slashQ
	
	if( ParamIsDefault(slashP) )
		slashP= 0
	endif
	if( ParamIsDefault(slashZ) )
		slashZ= 0
	endif
	if( ParamIsDefault(slashQ) )
		slashQ= 0
	endif
	
	Variable i, n= ItemsInList(commands)	// ; separates commands
	for(i=0;i<n;i+=1)
		String command= StringFromList(i,commands)

		if( slashP )
			if( slashZ )
				Execute/P/Q/Z command
			else
				Execute/P/Q command
			endif
		else
			if( slashZ )
				Execute/Z/Q command
			else
				Execute/Q command
			endif
		endif
		if( !slashQ )
			String dot = "•"
			if( slashP )
				// Escape the command's quotes
				command= replaceString("\"", command, "\\\"")
				Execute/P/Q/Z "Print \""+dot+command+"\""
			else
				Print dot+command
			endif
		endif
	endfor
End


//==============================================================================================
// Gizmo Axis Ranges
//==============================================================================================

// returns 0 on error, 1 if the returned values are valid
Function GetGizmoAxisRanges(gizmoName,xmin,xmax,ymin,ymax,zmin,zmax[,getDataLimits])
	String gizmoName
	Variable &xmin,  &xmax,  &ymin,  &ymax,  &zmin,  &zmax		// outputs
	Variable getDataLimits	// optional input: if set, skip trying the userBoxLimits, and return whatever GetGizmoDataLimits returns

	if( !ValidGizmoName(gizmoName) )
		return 0
	endif
	
	if( ParamIsDefault(getDataLimits) )
		getDataLimits= 0	// try both userBoxLimits and dataLimits
	endif

	xmin=nan
	xmax=nan
	ymin=nan
	ymax=nan
	zmin=nan
	zmax=nan
	Variable valid= 0
	
	if( !getDataLimits )
		GetGizmo/N=$gizmoName userBoxLimits	// if no user limits GizmoBoxXmin, etc set to NaN by gizmo::getBoxLimits()
		valid= numType(GizmoBoxXmin)==0
	endif
	if( getDataLimits || !valid )
		GetGizmo/N=$gizmoName dataLimits
		if( !valid ) // that is, box limits aren't valid, so return data limits, instead
			xmin=GizmoXmin
			xmax=GizmoXMax
			ymin=GizmoYMin
			ymax=GizmoYMax
			zmin=GizmoZMin
			zmax=GizmoZMax
			valid= 1
		endif
	else		// numType(GizmoBoxXmin) == 0
		xmin=GizmoBoxXmin
		xmax=GizmoBoxXmax
		ymin=GizmoBoxYmin
		ymax=GizmoBoxYmax
		zmin=GizmoBoxZmin
		zmax=GizmoBoxZmax
		valid= 1
	endif
	SetDataFolder oldDF
	
	return valid
End


// returns 0 on error, 1 if the returned values are valid
Function GetGizmoAxisRange(gizmoName, planeStr, axisMin, axisMax [,getDataLimits])
	String gizmoName
	String planeStr					// "Z", "Y", or "X"
	Variable &axisMin, &axisMax		// outputs
	Variable getDataLimits			// optional input: if set, skip trying the userBoxLimits, and return whatever GetGizmoDataLimits returns

	if( ParamIsDefault(getDataLimits) )
		getDataLimits= 0	// try both userBoxLimits and dataLimits
	endif
	
	axisMin= NaN
	axisMax= NaN

	Variable xmin,  xmax,  ymin,  ymax,  zmin,  zmax		// outputs
	if( !GetGizmoAxisRanges(gizmoName,xmin,xmax,ymin,ymax,zmin,zmax,getDataLimits=getDataLimits) )
		return 0
	endif

	strswitch( planeStr )
		case "X":
			axisMin= xmin
			axisMax= xmax
			break
		case "Y":
			axisMin= ymin
			axisMax= ymax
			break
		case "Z":
			axisMin= zmin
			axisMax= zmax
			break
		default:
			return 0
	endswitch

	return 1
End

// Changes the axis values for only one axis
Function SetGizmoAxisRange(gizmoName,whichAxis,axisMin,axisMax[,echoCommands])
	String gizmoName,whichAxis
	Variable axisMin, axisMax
	Variable echoCommands	// OPTIONAL: default is false (quiet)

	Variable xmin,xmax,ymin,ymax,zmin,zmax
	Variable valid= GetGizmoAxisRanges(gizmoName,xmin,xmax,ymin,ymax,zmin,zmax)	// current user box or data range if no user box

	if( valid )
		strswitch(whichAxis)
			case "x":
				xmin= axisMin
				xmax= axisMax
				break
			case "y":
				ymin = axisMin
				ymax = axisMax
				break
			case "z":
				zmin = axisMin
				zmax = axisMax
				break
			default:
				valid= 0
				break
		endswitch
		if( valid )
			if( ParamIsDefault(echoCommands) )
				echoCommands= 0
			endif
			Variable slashQ= echoCommands ? 0 : 1
			String cmd
			sprintf cmd,"ModifyGizmo/N=%s setOuterBox={%g,%g,%g,%g,%g,%g}",gizmoName, xmin,xmax,ymin,ymax,zmin,zmax
			GizmoEchoExecute(cmd, slashZ=1, slashQ=slashQ)
		endif
	endif

	return valid
End

// gets the ortho from the root level of the gizmo
Function GetGizmoOrtho(gizmoName, left, right, bottom, top, zNear, zFar [, displayListIndex, opName])
	String gizmoName
	Variable &left, &right, &bottom, &top, &zNear, &zFar		// outputs
	Variable &displayListIndex	// OPTIONAL output: returns -1 if the ortho attribute is not in the display list
	String &opName				// OPTIONAL output

	left=-2; right=2	// defaults
	bottom=-2; top=2
	zNear=-2; zFar= 2
	
	if( !ParamIsDefault(displayListIndex) )
		displayListIndex= -1	// -1 means "not found"
	endif
	if( !ParamIsDefault(opName) )
		opName= "ortho0"
	endif
	
	if( !ValidGizmoName(gizmoName) )
		return 0
	endif

	// gets the ortho from the root level of the gizmo
	//	String code= WinRecreation(gizmoName, 0)
	String code= GetGizmoGroupObjectCommands(gizmoName, "" ,removeSubgroups=1)	// "" to get only top-level commands (avoid orthos in subgroups)

	// Parse:
	// 	ModifyGizmo setDisplayList=0, opName=myOrtho, operation=ortho, data={-1.5,1.5,-1.5,1.5,-2,2}
	String key= ", operation=ortho, data={"
	Variable start= Strsearch(code, key, 0, 2)
	if( start >= 0 )
		// get displayListIndex and opName
		String displayKey="setDisplayList="
		Variable startOfSetDisplayList= strsearch(code, displayKey, start, 3)	// search backwards
		if( startOfSetDisplayList >0 )
			String goodStuff= code[startOfSetDisplayList,start-1]	// "setDisplayList=0, opName=myOrtho,"
			Variable index
			String name
			sscanf goodStuff, "setDisplayList=%g, opName=%s", index, name
			if( !ParamIsDefault(displayListIndex) )
				displayListIndex= index
			endif
			if( !ParamIsDefault(opName) )
				opName= name
			endif
		endif
	
		start += strlen(key)	// point past data key
		key="}"
		Variable theEnd= strsearch(code,key, start)
		if( theEnd >= 0 )
			String coordinates= code[start,theEnd-1]	// omit ( and ), keeping just the numbers
			sscanf coordinates, "%g,%g,%g,%g,%g,%g", left, right, bottom, top, zNear, zFar
			return V_Flag == 6	// success
		endif
	endif
	return 0 // failure or default.
End

Function SetGizmoOrtho(gizmoName, left, right, bottom, top, zNear, zFar [, displayListIndex, opName,echoCommands])
	String gizmoName
	Variable left, right, bottom, top, zNear, zFar
	Variable displayListIndex		// OPTIONAL, default is first operation=ortho in the display list
	String opName				// OPTIONAL, default is first operation=ortho in the display list
	Variable echoCommands		// OPTIONAL: default is false (quiet)

	if( !ValidGizmoName(gizmoName) )
		return 0
	endif

	if( ParamIsDefault(displayListIndex) || ParamIsDefault(opName) )
		Variable orthoLeft, orthoRight, orthoBottom, orthoTop, orthoZNear, orthoZFar
		GetGizmoOrtho(gizmoName, orthoLeft, orthoRight, orthoBottom, orthoTop, orthoZNear, orthoZFar, displayListIndex=displayListIndex, opName=opName)
	endif

	// In order to do this right, we have to be in the root object group
	String oldGroupPath= SetGizmoCurrentGroup(gizmoName, "root")

	String verb="setDisplayList"
	if( displayListIndex < 0 )	// -1 means "not found", so using setDisplayList would remove what is already there!
		verb="InsertDisplayList"
		displayListIndex= 0	
	endif
	String cmd
	sprintf cmd, "ModifyGizmo/N=%s %s=%d, opName=%s, operation=ortho, data={%g,%g,%g,%g,%g,%g}", gizmoName, verb, displayListIndex, opName,left, right, bottom, top, zNear, zFar
	if( ParamIsDefault(echoCommands) )
		echoCommands= 0
	endif
	Variable slashQ= echoCommands ? 0 : 1
	GizmoEchoExecute(cmd, slashZ=1, slashQ=slashQ)

	SetGizmoCurrentGroup(gizmoName, oldGroupPath)

	return 1
End


// returns truth the returned values are valid
Function GetGizmoAutoscalingOptions(gizmoName,scalingOption,autoscaling)
	String gizmoName
	Variable &scalingOption	// output
	Variable &autoscaling	// output
	
//	ModifyGizmo startRecMacro
//	ModifyGizmo scalingOption=63
// 	ModifyGizmo autoscaling=1

// By default scalingOption=0.  By setting the value to 1-63 it will override any setOuterBox param.
	scalingOption= 0
// By default autoscaling=0.
	autoScaling= 0

	if( !ValidGizmoName(gizmoName) )
		return 0
	endif

	String code= WinRecreation(gizmoName, 0)

	Variable numFound= 0

	String key="ModifyGizmo scalingOption="
	Variable start= strsearch(code, key, 0, 2)
	if( start >= 0 )
		start += strlen(key)	// point past key
		Variable theEnd= strsearch(code, "\r", start)
		if( theEnd > 0 )
			scalingOption= str2num(code[start,theEnd-1])
			numFound += 1
		endif
	endif

	key="ModifyGizmo autoscaling="
	start= strsearch(code, key, 0, 2)
	if( start >= 0 )
		start += strlen(key)	// point past key
		theEnd= strsearch(code, "\r", start)
		if( theEnd > 0 )
			autoscaling= str2num(code[start,theEnd-1])
			numFound += 1
		endif
	endif
	return numFound == 2
End


//==============================================================================================
// Planes routines
//==============================================================================================

Function/S PlaneSpecToPerpendicularPlane(planeStr)
	String planeStr						// "XY", "XZ", or "YZ": the plane in which the quad or surface lies.
										// "Z", "Y", or "X" are corresponding single-letter synonyms naming the perpendicular plane.
	strswitch( planeStr )
		case "XY":
		case "YX":
			planeStr= "Z"
			break
		case "XZ":
		case "ZX":
			planeStr= "Y"
			break
		case "YZ":
		case "ZY":
			planeStr= "X"
			break
	endswitch
	
	return planeStr	// the axis to which the plane is perpendicular
End


//==============================================================================================
// Axis Cue-related routines
//==============================================================================================

// This routine adds either a standard axis cue (if thereis no MainTransform object in the display list),
// or a free axis cue, the one that rotates after the MainTransform.
Function GizmoAddRemoveAxisCue(gizmoName, addAxisCue [,echoCommands])
	String gizmoName
	Variable addAxisCue	// 0 to remove any existing axisCue, 1 to add one if none exists.
	Variable echoCommands // optional, defaults to false
	
	if( !ValidGizmoName(gizmoName) )
		return 0
	endif
	
	String nameOfFreeAxisCue	
	Variable displayIndex= DisplayIndexNameOfFreeAxisCue(gizmoName,nameOfFreeAxisCue)
	Variable haveFreeAxisCue= strlen(nameOfFreeAxisCue) > 0
	Variable haveNormalAxisCue= GizmoHasNormalAxisCue(gizmoName)	// ModifyGizmo showAxisCue=1
	Variable haveAxisCue = haveFreeAxisCue || haveNormalAxisCue
	Variable mainTransformIndex= GetDisplayIndexOfNamedObject(gizmoName,"MainTransform")
	Variable haveMainTransform=  mainTransformIndex >= 0
	String cmds=""
	if( addAxisCue )
		if( !haveAxisCue )
			if( haveMainTransform )
				cmds= "ModifyGizmo/N="+gizmoName+" startRecMacro" 
				cmds += ";AppendToGizmo/N="+gizmoName+" freeAxesCue={0,0,0,1},name=freeAxesCue0" 
				cmds += ";ModifyGizmo/N="+gizmoName+" insertDisplayList="+num2istr(mainTransformIndex+1)+", object=freeAxesCue0"	// insert after the main Transform
				cmds += ";ModifyGizmo/N="+gizmoName+" modifyObject=freeAxesCue0 property={clipped,0}"
				Variable haveBlack= GizmoRecreationContains(gizmoName,"AppendToGizmo attribute color={0,0,0,1},name=black")
				if( !haveBlack )
					cmds += ";AppendToGizmo/N="+gizmoName+" attribute color={0,0,0,1},name=black"
				endif
				cmds += ";ModifyGizmo/N="+gizmoName+" setObjectAttribute={freeAxesCue0,black}"
				cmds += ";ModifyGizmo/N="+gizmoName+" endRecMacro"
			else
				cmds= "ModifyGizmo/N="+gizmoName+" showAxisCue=1" 
			endif
		endif
	else
		cmds= ""
		if( haveFreeAxisCue )
			cmds += ";RemoveFromGizmo/Z/N="+gizmoName+" object="+nameOfFreeAxisCue
		endif
		if( haveNormalAxisCue )
			cmds += ";ModifyGizmo/N="+gizmoName+" showAxisCue=0"
		endif
	endif
	if( strlen(cmds) )
		String curDF=SetWMGizmoDF()
		if( ParamIsDefault(echoCommands) )
			echoCommands= 0
		endif
		Variable quiet= !echoCommands
		GizmoEchoExecute(cmds, slashZ=1, slashQ=quiet)
		GizmoEchoExecute("ModifyGizmo compile", slashZ=1, slashQ=1)
		SetDataFolder curDF
	endif
End

// returns -1 if no free axis cue is found, else the DisplayIndex of the freeAxesCue object
// the objectName is an output which is "" if no axis cue is found.
// See also GizmoHasNormalAxisCue() and GizmoHasAxisCue().
Function DisplayIndexNameOfFreeAxisCue(gizmoName,objectName)
	String gizmoName
	String &objectName	// output
	
	objectName=""
	Variable index=-1
	if( !ValidGizmoName(gizmoName) )
		return -1
	endif
//	AppendToGizmo freeAxesCue={0,0,0,1},name=freeAxesCue0
	String code= WinRecreation(gizmoName, 0)
	String key="AppendToGizmo freeAxesCue={"
	Variable start= strsearch(code, key, 0, 2)
	if( start >= 0 )
		start += strlen(key)	// point past key
		key= "},name="
		Variable theEnd= strsearch(code, key, start, 2)
		if( theEnd > 0 )
			start= theEnd + strlen(key)	// point to the name start
			theEnd= strsearch(code, "\r", start)
			if( theEnd > 0 )
				objectName= code[start,theEnd-1]
				index= GetDisplayIndexOfNamedObject(gizmoName, objectName)
			endif
		endif
	endif
	return index
End

Function GizmoHasNormalAxisCue(gizmoName)
	String gizmoName

	if( !ValidGizmoName(gizmoName) )
		return 0
	endif
	Variable haveNormalCue= GizmoRecreationContains(gizmoName,"ModifyGizmo showAxisCue=1")
	return haveNormalCue
End

Function GizmoHasAxisCue(gizmoName)
	String gizmoName
	
	if( GizmoHasNormalAxisCue(gizmoName) )
		return 1
	endif
	String objectName
	Variable freeAxisCueDisplayIndex= DisplayIndexNameOfFreeAxisCue(gizmoName,objectName)
	return freeAxisCueDisplayIndex >= 0
End


//==============================================================================================
// Surface-related routines
//==============================================================================================

Function/S GetSurfaceDataPath(gizmoName,surfaceName)
	String gizmoName
	String surfaceName	// input, name of surface if in the top level. If in a group or subgroup, use the full object path: "group0:surface0"

	// limit recreation code to the group in surfaceName's path (to group0 if surfaceName = "group0:surface0"), or to just the top level (surfaceName = "surface0")
	String inGroupPath= surfaceName
	surfaceName= GizmoGroupPathToNameAndPrefix(inGroupPath)

	String surfaceNameList="", surfaceDataPathList="", pathToSurfaceData=""
	Variable numSurfaces= GetGizmoSurfaces(gizmoName, surfaceNameList, surfaceDataPathList, inGroupPath=inGroupPath,ignoreSubgroups=1)

	if( numSurfaces )
		Variable whichOne= WhichListItem(surfaceName, surfaceNameList)
		if( whichOne >= 0 )
			pathToSurfaceData=StringFromList(whichOne, surfaceDataPathList)
		endif
	endif
	
	return pathToSurfaceData
End

Function GetGizmoSurfaces(gizmoName, surfaceNameList, surfaceDataPathList [,want2DMatrices,allow2DFlat,want3DParametrics,inGroupPath,ignoreSubgroups])
	String gizmoName
	String &surfaceNameList		// output, names are either simple names (if ignoreSubgroups is true) or paths (if ignoreSubgroups is false) to avoid confusing identically named surfaces at the top level and in a group.
	String &surfaceDataPathList	// output, full path to surface wave.
	Variable want2DMatrices		// optional input: Default is true
	Variable allow2DFlat				// optional input: Default is true
	Variable want3DParametrics		// optional input: Default is false
	String inGroupPath				// optional input: Default is "", the top-level objects.
	Variable ignoreSubgroups		// optional input: Default is false, which lists all surfaces starting at inGroupPath and in groups and subgroups. If false, the output names are full paths to the object.

	surfaceNameList=""
	surfaceDataPathList=""
	if( !ValidGizmoName(gizmoName) )
		return 0
	endif

	if( ParamIsDefault(want2DMatrices) )
		want2DMatrices= 1
	endif
	if( ParamIsDefault(allow2DFlat) )
		allow2DFlat= 1
	endif
	if( ParamIsDefault(want3DParametrics) )
		want3DParametrics= 0
	endif
	if( ParamIsDefault(inGroupPath) )
		inGroupPath= ""
	else
		inGroupPath=RemoveEnding(inGroupPath,":")	// strip any erroneously trailing ":" char.
	endif
	if( ParamIsDefault(ignoreSubgroups) )
		ignoreSubgroups= 0
	endif

	String code= GetGizmoGroupObjectCommands(gizmoName, inGroupPath ,removeSubgroups=ignoreSubgroups,removeCurrentGroupObject=1)

	String key="AppendToGizmo Surface="
	String appendSurfaceCommands= GrepList(code,key,0,"\r")
	Variable numSurfaces= ItemsInList(appendSurfaceCommands,"\r")
	if( numSurfaces == 0 )
		return 0
	endif

	// keep only the interesting lines: appended surfaces and currentGroupObject commands
	key="(AppendToGizmo Surface=)|(ModifyGizmo currentGroupObject=)"
	code= GrepList(code,key,0,"\r")

	// keep the groupPathPrefix in sync with code
	String groupPathPrefix=""
	if( strlen(inGroupPath) )
		groupPathPrefix = inGroupPath+":"
	endif
	String name
	Variable line, numLines= ItemsInList(code,"\r")
	for(line=0; line <numLines; line+=1 )
		String lineStr= StringFromList(line,code,"\r")
		// parse:
		//	AppendToGizmo Surface=root:'HALF DOME, CA-2400':'HALF DOME',name=surface0
		key="AppendToGizmo Surface="
		Variable start= strsearch(lineStr, key, 0, 2)
		if( start >= 0 )	// found a surface command
			start += strlen(key)	// point past key
			key= ",name="
			Variable theEnd= strsearch(lineStr,key, start, 2)
			if( theEnd < 0 )
				break
			endif
			String pathToData= lineStr[start,theEnd-1]	// possibly quoted path
			// we may not want both matrix and parametric surfaces
			if( (!want2DMatrices) || (!want3DParametrics) )
				Wave/Z w= $pathToData
				if( !WaveExists(w) )
					continue
				endif
				Variable is3DParametric = DimSize(w,2) >= 3	// has layers for x, y, z, presumably it also has rows and columns
				Variable is2DMatrix = !is3DParametric && DimSize(w,0) >= 2 && DimSize(w,1) >= 2
				if( !want2DMatrices && is2DMatrix )
					continue
				endif
				if( is2DMatrix && !allow2DFlat && IsFlat2DWave(w) )
					continue
				endif
				if( !want3DParametrics && is3DParametric )
					continue
				endif
				// notice that this lets through waves that somehow aren't either 2D or 3D, but that shouldn't happen.
			endif
			start= theEnd + strlen(key)	// point past key to surface object name
			theEnd= strlen(lineStr)-1	// rest of line is the surface object name
			name= lineStr[start, theEnd]
			if( !ignoreSubgroups )	// we'll need full object path name if we're parsing subgroups, too
				name= groupPathPrefix+name
			endif
			surfaceNameList += name+";"
			surfaceDataPathList += pathToData+";"	
		else
			// must be ModifyGizmo currentGroupObject command
			if( !ignoreSubgroups )
				// keep track of the groupPathPrefix
				key="ModifyGizmo currentGroupObject=\"(.*)\""
				SplitString/E=(key) lineStr, name
				strswitch(name)
					default:
						if( strlen(name) )
							groupPathPrefix += name+":"
							break
						endif
					case "":
					case "::":
						groupPathPrefix= ParseFilePath(1, groupPathPrefix,":",1,0)	//  entire input up to but not including last element, has trailing ":" unless ""
						break
				endswitch
			endif		
		endif
	endfor

	return ItemsInList(surfaceNameList)
End

static Function IsFlat2DWave(w)
	Wave w

	Variable n= numpnts(w)
	if( n < 2 )
		return 1	// 0 and 1 points waves are flat
	endif
	Variable v= w[0]
	if( v == w[n-1] && v == w[n/2] && v == w[n/4] )	// fail quickly
		ImageStats/Q/M=1 w
		return V_min == V_Max
	endif
	return 0
End

// return object name of surface whose surface data is the given wave, or "" if not found.
Function/S FindSurfaceUsingDataWave(gizmoName, surfaceWave [,inGroupPath,ignoreSubgroups] )
	String gizmoName
	Wave/Z surfaceWave
	String inGroupPath				// optional input: Default is "", the top-level objects.
	Variable ignoreSubgroups		// optional input: Default is false, which lists all surfaces starting at inGroupPath and in groups and subgroups. If false, the output names are full paths to the object.

	if( WaveExists(surfaceWave) == 0 )
		return ""
	endif
	
	if( ParamIsDefault(inGroupPath) )
		inGroupPath= ""
	else
		inGroupPath=RemoveEnding(inGroupPath,":")	// strip any erroneously trailing ":" char.
	endif
	if( ParamIsDefault(ignoreSubgroups) )
		ignoreSubgroups= 0
	endif
	
	String surfaceName= "", surfaceNameList="", surfaceDataPathList=""
	Variable numSurfaces= GetGizmoSurfaces(gizmoName, surfaceNameList, surfaceDataPathList, inGroupPath=inGroupPath, ignoreSubgroups=ignoreSubgroups)

	if( numSurfaces )
		String pathToSurfaceData= GetWavesDataFolder(surfaceWave,2)		// possibly quoted MUST BE SAME FORMAT AS GetGizmoSurfaces() returns
		Variable whichOne= WhichListItem(pathToSurfaceData, surfaceDataPathList)
		if( whichOne >= 0 )
			surfaceName=StringFromList(whichOne, surfaceNameList)
		endif
	endif
	
	return surfaceName
End

// GetGizmoSurfaceColors parses the color commands for the named surface.
//
//	There are three basically 3 cases to parse:
//
//	Surface Wave colors
//	AppendToGizmo Surface=root:'HALF DOME, CA-2400':'HALF DOME',name=surface0
//	ModifyGizmo ModifyObject=surface0 property={ srcMode,0}
//	ModifyGizmo ModifyObject=surface0 property={ surfaceColorType,3}
//	ModifyGizmo ModifyObject=surface0 property={ srcMode,0}
//	ModifyGizmo ModifyObject=surface0 property={ surfaceColorWave,root:'HALF DOME, CA-2400':'HALF DOME_C'}
//
//	Specific Z Range Colors
//	AppendToGizmo Surface=root:'HALF DOME, CA-2400':'HALF DOME',name=surface0
//	ModifyGizmo ModifyObject=surface0 property={ srcMode,0}
//	ModifyGizmo ModifyObject=surface0 property={ surfaceCTab,Geo}
//	ModifyGizmo ModifyObject=surface0 property={ inverseSurfaceCTAB,1}
//	ModifyGizmo ModifyObject=surface0 property={ SurfaceCTABScaling,100}
//	ModifyGizmo ModifyObject=surface0 property={ surfaceMinRGBA,1800,1,1,1,1}
//	ModifyGizmo ModifyObject=surface0 property={ surfaceMaxRGBA,2800,0,0,0,1}
//
//	Auto Z Range Colors
//	AppendToGizmo Surface=root:'HALF DOME, CA-2400':'HALF DOME',name=surface0
//	ModifyGizmo ModifyObject=surface0 property={ srcMode,0}
//	ModifyGizmo ModifyObject=surface0 property={ surfaceCTab,Rainbow256}
//	ModifyGizmo ModifyObject=surface0 property={ inverseSurfaceCTAB,1}
//	ModifyGizmo ModifyObject=surface0 property={ SurfaceCTABScaling,4}
//
//	Constant Color
//	AppendToGizmo Surface=root:'HALF DOME, CA-2400':'HALF DOME',name=surface0
//	ModifyGizmo ModifyObject=surface0 property={ srcMode,0}
//	ModifyGizmo ModifyObject=surface0 property={ surfaceColorType,2}
//	ModifyGizmo ModifyObject=surface0 property={ frontColor,1,0,0,1}
//
// Returns surfaceColorType, which can be used as truth that the color information is valid.
//	surfaceColorType	specifies how the surface is colored.
//		0:	error
//		1:	constant color surface. Use 	frontColor and backColor to specify 	the surface color.
//		2:	color from built-in color table. Use surfaceCtab to specify the color table.
//		3:	color from a color wave. Use surfaceColorWave to specify the color wave.
//
Function GetGizmoSurfaceColors(gizmoName, surfaceName, colorTableNameOrColorWavePath, reverseCTAB, zMin, minRed, minGreen, minBlue, minAlpha, zMax, maxRed, maxGreen, maxBlue,maxAlpha)
	String gizmoName	// input
	String surfaceName	// input, name of surface if in the top level. If in a group or subgroup, use the full object path: "group0:surface0"
	String &colorTableNameOrColorWavePath	// output, "" if constant color (surfaceColorType=1), color table name if color from built-in color table (2), else full path to color wave (3)
	Variable &reverseCTAB							// output
	Variable &zMin, &minRed, &minGreen, &minBlue, &minAlpha	// outputs, zMin is replaced with image min if not specified. The color components are in 0-1 range (Gizmo range)
	Variable &zMax, &maxRed, &maxGreen, &maxBlue, &maxAlpha	// outputs

	// Defaults
	colorTableNameOrColorWavePath="Rainbow"
	reverseCTAB= 0
	zMin= NaN	// not specified
	minRed= 0
	minGreen= 0
	minBlue= 0
	minAlpha= 1
	
	zMax= NaN	// not specified
	maxRed= 0
	maxGreen= 0
	maxBlue= 0
	maxAlpha= 1
	
	if( strlen(gizmoName) == 0 || strlen(surfaceName) == 0)
		return 0
	endif

	WAVE/Z w= $GetSurfaceDataPath(gizmoName,surfaceName)
	WaveStats/Q/M=1 w
	zMin= V_min
	zMax= V_max

	// limit recreation code to the group in surfaceName's path (to group0 if surfaceName = "group0:surface0"), or to just the top level (surfaceName = "surface0")
	String inGroupPath= surfaceName
	surfaceName= GizmoGroupPathToNameAndPrefix(inGroupPath)

	String code= GetGizmoGroupObjectCommands(gizmoName,inGroupPath,removeSubgroups=1,removeCurrentGroupObject=1)

	// parse code like: ModifyGizmo ModifyObject=surface0 property={ surfaceCTab,Rainbow256}

	String key="ModifyGizmo ModifyObject="+surfaceName+" property={"
	Variable start= strsearch(code, key, 0, 2)	// ignore case: sometimes it's "modifyObject"
	if( start < 0 )
		return 0
	endif

	Variable surfaceColorType= 0
	Variable frontRed, frontGreen, frontBlue, frontAlpha
	do
		// get the code after ".... property={" (which may or may not have a following space character)
		start += strlen(key)	// point past key

		Variable theEnd= strsearch(code, "}", start)
		if( theEnd < 0 )
			break
		endif
		String propertyList= code[start,theEnd-1]	// comma-separated list: surfaceColorWave,root:'HALF DOME, CA-2400':'HALF DOME_C'
		String command= StringFromList(0, propertyList, ",")
		command= SkipLeadingSpaces(command)
		String arg1= StringFromList(1, propertyList, ",")
		String arg2= StringFromList(2, propertyList, ",")
		String arg3= StringFromList(3, propertyList, ",")
		String arg4= StringFromList(4, propertyList, ",")
		String arg5= StringFromList(5, propertyList, ",")
		Variable num1= str2num(arg1)
		strswitch( command )	// case insensitive.
			case "srcMode":				// property={ srcMode,0}
				if( num1 != 0 )				// we require that the source data be a 2D matrix of z values.
					return 0
				endif
				break
			case "surfaceColorType":	// property={ surfaceColorType,3}
				surfaceColorType= num1
				switch( num1 )
					case 1:				// constant color surface
					case 2:				// color from built-in color table
					case 3:				// color from surfaceColorWave per-pixel color rgba
						break
					default:
						return 0		// error or not supported
						break
				endswitch
				break
			case "surfaceColorWave":	// property={ surfaceColorWave,root:'HALF DOME, CA-2400':'HALF DOME_C'}
				colorTableNameOrColorWavePath= arg1	// per-surface pixel color rgba.
				break
			case "surfaceCTab":			// property={ surfaceCTab,Geo}
				colorTableNameOrColorWavePath= arg1
				surfaceColorType=2		// color from built-in color table is actually the default, so the surfaceColorType command won't appear in that case.
				break
			case "SurfaceCTABScaling":	// property={ SurfaceCTABScaling,100 }
				break
			case "inverseSurfaceCTAB":	// property={ inverseSurfaceCTAB,1}
				reverseCTAB= num1
				break
			case "surfaceMinRGBA":		// property={ surfaceMinRGBA,1800,1,1,1,1}	// zMin, r, g, b, a
				zMin= num1
				minRed= str2num(arg2)
				minGreen= str2num(arg3)
				minBlue= str2num(arg4)
				minAlpha=str2num(arg5)
				break
			case "surfaceMaxRGBA":		// property={ surfaceMaxRGBA,2800,0,0,0,1}	// zMax, r, g, b, a
				zMax= num1
				maxRed= str2num(arg2)
				maxGreen= str2num(arg3)
				maxBlue= str2num(arg4)
				maxAlpha=str2num(arg5)
				break
			case "frontColor":			// property={ frontColor,1,0,0,1}	//  r, g, b, a
				frontRed= num1
				frontGreen= str2num(arg2)
				frontBlue= str2num(arg3)
				frontAlpha= str2num(arg4)
				break
		endswitch
		
		// next command
		start= strsearch(code, key, theEnd+2,2)

	while(start > 0)
	
	if( surfaceColorType == 1 )	// constant color surface
		colorTableNameOrColorWavePath=""
		minRed= frontRed
		minGreen= frontGreen
		minBlue= frontBlue
		minAlpha= frontAlpha
		
		maxRed= frontRed
		maxGreen= frontGreen
		maxBlue= frontBlue
		maxAlpha= frontAlpha
	endif

	return surfaceColorType	
End


// ============== Quad-related routines

Function GetGizmoQuads(gizmoName, quadNameList, quadCoordinatesStringList [,inGroupPath,ignoreSubgroups])
	String gizmoName
	String &quadNameList		// output, names are either simple names (if ignoreSubgroups is true) or paths (if ignoreSubgroups is false) to avoid confusing identically named surfaces at the top level and in a group.
	String &quadCoordinatesStringList	// output, quad coordinates as a string list. Each quad is separated by ";", individual coordinates for each quad are separated by ","
	String inGroupPath			// optional input: Default is "", the top-level objects. Use "group0:" to list quads in that top-level group.
	Variable ignoreSubgroups	// optional input: Default is false, which lists all surfaces starting at inGroupPath and in groups and subgroups. If false, the output names are full paths to the object.

	quadNameList=""
	quadCoordinatesStringList=""

	if( !ValidGizmoName(gizmoName) )
		return 0
	endif

	if( ParamIsDefault(inGroupPath) )
		inGroupPath= ""
	else
		inGroupPath=RemoveEnding(inGroupPath,":")	// strip any erroneously trailing ":" char.
	endif
	if( ParamIsDefault(ignoreSubgroups) )
		ignoreSubgroups= 0
	endif

	String code= GetGizmoGroupObjectCommands(gizmoName, inGroupPath ,removeSubgroups=ignoreSubgroups,removeCurrentGroupObject=1)
	String key="(?i)AppendToGizmo quad="
	String appendQuadCommands= GrepList(code,key,0,"\r")
	Variable numQuads= ItemsInList(appendQuadCommands,"\r")
	if( numQuads == 0 )
		return 0
	endif

	// keep only the interesting lines: appended quads and currentGroupObject commands
	key="(?i)(AppendToGizmo quad=)|(ModifyGizmo currentGroupObject=)"
	code= GrepList(code,key,0,"\r")

	// keep the groupPathPrefix in sync with code
	String groupPathPrefix=""
	if( strlen(inGroupPath) )
		groupPathPrefix = inGroupPath+":"
	endif
	String name
	Variable line, numLines= ItemsInList(code,"\r")
	for(line=0; line <numLines; line+=1 )
		String lineStr= StringFromList(line,code,"\r")
		// parse:
		// 	AppendToGizmo quad={-2.68445,2.33,-1.9,2.64445,2.33,-1.9,2.64445,-1.67,-1.9,-2.68445,-1.67,-1.9},name=quad0

		key="AppendToGizmo quad={"
		Variable start= strsearch(lineStr, key, 0, 2)
		if( start >= 0 )	// found a quad command
			start += strlen(key)	// point past key
			key= "},name="
			Variable theEnd= strsearch(lineStr,key, start, 2)
			if( theEnd < 0 )
				break
			endif
			String coordinates= lineStr[start,theEnd-1]	// coordinates inside {}
			start= theEnd + strlen(key)	// point past key to quad object name
			theEnd= strlen(lineStr)-1	// rest of line is the quad object name
			name= lineStr[start, theEnd]
			if( !ignoreSubgroups )	// we'll need full object path name if we're parsing subgroups, too
				name= groupPathPrefix+name
			endif
			quadNameList += name+";"
			quadCoordinatesStringList += coordinates+";"	
		else
			// must be ModifyGizmo currentGroupObject command
			if( !ignoreSubgroups )
				// keep track of the groupPathPrefix
				key="ModifyGizmo currentGroupObject=\"(.*)\""
				SplitString/E=(key) lineStr, name
				strswitch(name)
					default:
						if( strlen(name) )
							groupPathPrefix += name+":"
							break
						endif
					case "":
					case "::":
						groupPathPrefix= ParseFilePath(1, groupPathPrefix,":",1,0)	//  entire input up to but not including last element, has trailing ":" unless ""
						break
				endswitch
			endif		
		endif
	endfor

	return ItemsInList(quadNameList)
End

// Texture-related routines moved to GizmoTextures


// ============== Group-related routines

// returns leaf name from groupPath, changes groupPath to be the path component before the leaf name.
// For example: GizmoGroupPathToNameAndPrefix("group0:subgroup:surface0") returns "surface0" and sets groupPath to "group0:subgroup"
Function/S GizmoGroupPathToNameAndPrefix(groupPath)
	String &groupPath	// input and output: on return this is the path component before the leaf name.
	
	String leafName= RemoveEnding(ParseFilePath(0, groupPath,":",1,0),":")	// keep only the last element and no trailing ":"

	groupPath= RemoveEnding(ParseFilePath(1, groupPath,":",1,0),":")	//  entire input up to but not including last element and no trailing ":"

	return leafName
End

// Returns a list of group objects in the named or top Gizmo Window.
// Use inThisGroupObject  to limit which group ("" for top-level) and matchStr to limit which group names are returned.
// Subgroups are not searched, and the returned list is not sorted.
Function/S GetGizmoGroupObjects(gizmoName, inThisGroupObject, matchStr)
	String gizmoName
	String inThisGroupObject	// "" for top-level, "group0" to get (sub-)group objects inside group0, "group0:subgroup0" to get groups inside the subgroup0.
	String matchStr			// use "*" for all groups at the indicated level, use the full object name to match only one group object, use "something*" to match groups whose name starts with "something".

	if( !ValidGizmoName(gizmoName) )
		return ""
	endif
	
	String objectsNameList=""
	String code= WinRecreation(gizmoName, 0)
	
#if 0
	// parse:
	AppendToGizmo group,name=group0
	
	// ************************* Group Object Start *******************
	ModifyGizmo currentGroupObject="group0"
	AppendToGizmo string="abc",strFont="Geneva",name=string0
	ModifyGizmo modifyObject=string0 property={Clipped,0}
	AppendToGizmo group,name=group0
	
	// ************************* Group Object Start *******************
	ModifyGizmo currentGroupObject="group0"
	ModifyGizmo currentGroupObject="::"

	// ************************* Group Object End *******************
	
	ModifyGizmo currentGroupObject="::"

	// ************************* Group Object End *******************
	
	//		<more commands>
#endif
	Variable start=0
	String groupPath= ""
	do
		String key="// ************************* Group Object Start *******************\r"
		start= strsearch(code, key, start,2)
		if( start < 0 )
			break
		endif
		// found a group start
		start += strlen(key)		// point past key
		// get the group name
		key= "ModifyGizmo currentGroupObject=\""
		start= strsearch(code, key, start)
		if( start < 0 )
			break
		endif
		start += strlen(key)	// point past key
		Variable theEnd= strsearch(code,"\"", start,2)
		if( theEnd < 0 )
			break
		endif
		String groupName= code[start,theEnd-1]
		if( CmpStr(groupPath,inThisGroupObject) == 0  )
			if( stringmatch(groupName,matchStr) )
				objectsNameList += groupName+";"
			endif
		endif
		
		// now we're parsing commands within the found group
		if( strlen(groupPath) )
			groupPath += ":"
		endif
		groupPath += groupName
		
		// get code lines until either:
		//	a)	// ************************* Group Object Start *******************
		// In which case we continue the loop,
		// or
		//	b)	// ************************* Group Object End *******************
		// in which case we decrement the groupIndex
		// 
		String lineStr
		key= "// ************************* Group Object "
		start= theEnd
		Variable keyStart
		do
			start= GetNextLine(code, start, lineStr)
			if( start < 0 )	// no more lines
				return objectsNameList
			endif
			keyStart= strsearch(lineStr, key, 0,2)
		while(keyStart < 0)
		// found another Group Object comment, either the start of a new level or the end of the current one
		Variable endingKeyOffset= strsearch(lineStr, "// ************************* Group Object End *******************", 0,2)
		if( endingKeyOffset >= 0 )
			// end of group; shorten the groupPath by one element
			groupPath= RemoveEnding(ParseFilePath(1, groupPath,":",1,0),":")	//  entire input up to but not including last element and no trailing ":"
		endif
		// else, start of new group
	while(1)
	return objectsNameList
End

// this is usually called when it is known that the window has a group, so plodding though line-by-line is worth it.
Function/S GetGizmoGroupObjectCommands(gizmoName, inGroupPath [,removeSubgroups,removeCurrentGroupObject])
	String gizmoName
	String inGroupPath		// "group0" to get commands inside group0 at the top level, "group0:subgroup0" to get commands inside the subgroup0, "" to get only top-level commands
	Variable removeSubgroups	// OPTIONAL: if true, removes commands not in the designated group level. Default is false.
	Variable removeCurrentGroupObject	// OPTIONAL: if true, removes initial and final ModifyGizmo currentGroupObject commands. Default is false.

	if( !ValidGizmoName(gizmoName) )
		return ""
	endif
	String commands="", key, lineStr
	if( ParamIsDefault(removeSubgroups) )
		removeSubgroups= 0
	endif
	if( ParamIsDefault(removeCurrentGroupObject) )
		removeCurrentGroupObject= 0
	endif

	Variable start
	String groupPath=""
	Variable collectingLines= strlen(inGroupPath) == 0 ? 1 : 0
	String code= WinRecreation(gizmoName, 0)
	Variable finished= 0
	Variable line=0, numLines= ItemsInList(code,"\r")
	for(line=0; line <numLines; line+=1 )
		lineStr= StringFromList(line,code,"\r")
		Variable collectThisLine= collectingLines	// perhaps we'll change our mind after examining the line.

		key= "ModifyGizmo currentGroupObject=\"::\""
		start= strsearch(lineStr, key, 0,2)
		Variable foundGroupEnd= start >= 0 
		if( !foundGroupEnd )
			key= "ModifyGizmo currentGroupObject=\"\""	// top-level used to end macro, treat it like "::" since the grouping in a recreation macro is well-formed
			start= strsearch(lineStr, key, 0,2)
			foundGroupEnd= start >= 0 
		endif
		if( foundGroupEnd )	// found a group End
			// see if this is the end of the group we were called to get commands for
			if( CmpStr(groupPath,inGroupPath) == 0 )	// yep, we've been collecting commands in the given group
				finished= 1	// and now we're done (after perhaps emitting the current line)
				collectingLines= 0	// effective for next line
				collectThisLine = removeCurrentGroupObject ? 0 : 1
			endif
		else
			key= "ModifyGizmo currentGroupObject=\""
			start= strsearch(lineStr, key, 0,2)
			if( start >= 0 )	// found a group start
				// get the group name
				start += strlen(key)	// point past key
				Variable theEnd= strsearch(lineStr,"\"", start)
				String groupName= lineStr[start,theEnd-1]

				// now we're parsing commands within the found group
				if( strlen(groupPath) )
					groupPath += ":"
				endif
				groupPath += groupName
				if( CmpStr(groupPath,inGroupPath) == 0 )
					collectingLines= 1	// effective for next line
					collectThisLine = removeCurrentGroupObject ? 0 : 1
				endif
			endif
		endif

		if( collectThisLine )
			// skip blank lines; they're boring
			String stripped= replaceString("\t",lineStr,"")
			stripped=replaceString(" ",stripped,"")
			if( strlen(stripped) )
				// skip group object lines if removeSubgroups is set
				key="// ************************* Group Object "	// Start or End
				start= strsearch(lineStr, key, 0,2)
				if( (removeSubgroups  == 0) || (start < 0) )
					if( (removeSubgroups == 0) || (CmpStr(groupPath,inGroupPath) == 0) )
						commands += lineStr+"\r"
					endif
				endif
			endif
		endif
		if( finished )
			break
		endif
		if( foundGroupEnd )	// found a group End
			// do this after the command is emitted
			// end of group; shorten the groupPath by one element
			groupPath= RemoveEnding(ParseFilePath(1, groupPath,":",1,0),":")	//  entire input up to but not including last element and no trailing ":"
		endif
	endfor

	return commands
End

// Returns the display index it occupies, or -1 if some error prevented it from being created and displayed.
Function FindOrInsertGizmoGroupObject(gizmoName, groupName, groupDisplayIndex)
	String gizmoName
	String groupName			// "group0" to put a group object in the current group. (someday "group0:subgroup0" will create a group and subgroup, but not now)
	Variable groupDisplayIndex	// use InsertDisplayList with this number to put the group object into the display list, IF it is not already in the display list. Can be -1 to append

	if( !ValidGizmoName(gizmoName) )
		return -1
	endif

	String oldDF= SetWMGizmoDF()
	String cmd
	
	Variable existingDisplayIndex= -1
	if( NameIsInGizmoObjectList(gizmoName,groupName) )
		// check that it is a group object
		String groupObjects=GetGizmoGroupObjects(gizmoName, "", groupName)
		if( strlen(groupObjects) == 0 )	// not a group object!
			return -1
		endif
		// the object can exist without it being in the display list
		existingDisplayIndex= GetDisplayIndexOfNamedObject(gizmoName,groupName)
	else
		AppendToGizmo/N=$gizmoName group,name=$groupName
	endif

	if( existingDisplayIndex == -1 )
		ModifyGizmo/N=$gizmoName insertDisplayList=groupDisplayIndex,object=$groupName
		existingDisplayIndex= GetDisplayIndexOfNamedObject(gizmoName,groupName)
	endif

	SetDataFolder oldDF

	return existingDisplayIndex
End

// returns root: to ensure that it is interpreted as an absolute path.
Function/S GetGizmoCurrentGroup(gizmoName)
	String gizmoName

#ifdef TIMING
	Variable timerRefNum = startMSTimer
#endif	
	String groupPath=""	// synonym for top level
	if( ValidGizmoName(gizmoName) )
		GetGizmo/N=$gizmoName curGroup
		groupPath= S_GroupName
		if( strlen(groupPath) )
			groupPath= "root:"+groupPath	// "root:Gizmo0:Group0
		endif
	endif
#ifdef TIMING
	Print  GetRTStackInfo(1)+"() time (seconds)= ",stopMSTimer(timerRefNum)/1e6
#endif	
	return groupPath
End

// returns the path to the previous current group, or "" on error
// NOTE: Setting the current group provokes a Gizmo update, which is quite slow,
// so we change the current group only if groupPath is actually different that the current group.
Function/S SetGizmoCurrentGroup(gizmoName, groupPath)
	String gizmoName
	String groupPath	// use "group0" to set to a subgroup of the current level,
						// "root:group0" to set a group at the top level,
						// "::" to back up one level, and "" or "root" to set to the top level.
#ifdef TIMING
	Variable timerRefNum = startMSTimer
#endif	
	String oldGroupPath= ""
	if( ValidGizmoName(gizmoName) )
		oldGroupPath=GetGizmoCurrentGroup(gizmoName)
		if( DifferentGroupPaths(oldGroupPath,groupPath) )
			ModifyGizmo/N=$gizmoName currentGroupObject=groupPath
		endif
#ifdef DEBUGGING
		AssertGizmoPath(gizmoName,groupPath)
#endif
	endif
#ifdef TIMING
	Print GetRTStackInfo(1)+"() time (seconds)= ",stopMSTimer(timerRefNum)/1e6
#endif	
	return oldGroupPath
End

// shortens full group paths by removing root:
static Function/S StandardizeGroupPath(path)
	String path

	if( CmpStr(path,"root") == 0 )
		path= ""
	elseif( CmpStr(path[0,4],"root:") == 0 )
		path= path[5,strlen(path)-1]
	endif
	return path	
End

static Function DifferentGroupPaths(path1,path2)
	String path1, path2
	
	String std1= StandardizeGroupPath(path1)
	String std2= StandardizeGroupPath(path2)
	return CmpStr(std1,std2) != 0
End

static Function AssertGizmoPath(gizmoName, assertedPath)
	String gizmoName, assertedPath	// absolute path, "" is the same as root:
	
	String currentPath= GetGizmoCurrentGroup(gizmoName)
	if( DifferentGroupPaths(assertedPath,currentPath) )
		Print "\rGizmo= "+ gizmoName
		Print "Paths Differ! Desired= \""+StandardizeGroupPath(assertedPath)+"\""
		Print "\tActual= \""+StandardizeGroupPath(currentPath)+"\""
		Print "Display items in current group= "+GizmoList(gizmoName,"displayNameList")
		Print "Objects= "+GizmoList(gizmoName,"objectNameList")
		Print "Attributes= "+GizmoList(gizmoName,"attributeNameList")
	endif
End



//==============================================================================================
// Gizmo Window Aspect Ratio Hook Functions
//==============================================================================================

#ifdef MACINTOSH	// pre-defined as of 6.2 Release, not pre-defined on earlier Igors.
static Constant kMinWidthPoints= 250	// the smallest a Gizmo Window can be resized to on Mac OS X
static Constant kMinHeightPoints= 250
#else
static Constant kMinWidthPoints= 50	// the smallest a Gizmo Window can be resized to depends on the min title width
static Constant kMinHeightPoints= 10	// 0 is the actual limit on Windows, let's not get carried away.
#endif

// See GizmoOrthoZoom.ipf for Panel and menu definitionss for controlling window aspect ratio/resizing properties.

Function/S CentralBoxKeptSquareMenu(gizmoName)
	String gizmoName

	String meta=""

	ExperimentModified 1		// mark it modified, not modifed, we don't care. We just want the current modified value, which is the local V_Flag
	Variable wasModified= V_Flag

	if( !ValidGizmoName(gizmoName) )
		meta = "("	// disabled
	else
		Variable mustStaySquare= 0	// output of IsGizmoCentralBoxKeptSquare
		Variable isKeptSquare= IsGizmoCentralBoxKeptSquare(gizmoName,mustStaySquare=mustStaySquare)
		if( isKeptSquare )
			if( mustStaySquare )
				meta = "("	// disabled
			endif
			meta += "!"+num2char(18)	// checked
		endif
	endif
	ExperimentModified wasModified	// set experiment modified back

	meta= "\\M0:"+meta+":"

	return meta + "Keep Central Box Square"
End
	
Function ToggleKeepGizmoCentralBoxSquare(gizmoName)
	String gizmoName
	Variable keepCentralBoxSquare
	
	if( !ValidGizmoName(gizmoName) )
		return NaN
	endif
	
	Variable mustStaySquare= 0
	Variable isKeptSquare= IsGizmoCentralBoxKeptSquare(gizmoName,mustStaySquare=mustStaySquare)
	if( mustStaySquare && isKeptSquare )
		return 1
	endif
	isKeptSquare= !isKeptSquare
	Variable/G $WMPerGizmoDFVar(gizmoName,"keepCentralBoxSquare")= isKeptSquare
	if( isKeptSquare )
		RestoreGizmoFixedWindowAspect(gizmoName)
	endif
	return isKeptSquare
End


Function/S PreserveGizmoAspectRatioMenu(gizmoName)
	String gizmoName

	String meta="", currentRatioStr=""
	Variable windowAspectRatio	// GetGizmoAspectRatio output: the user-specified fixed window aspect ratio, or NaN if the user hasn't set a window aspect ratio
	ExperimentModified 1		// mark it modified, not modifed, we don't care. We just want the current modified value, which is the local V_Flag
	Variable wasModified= V_Flag
	Variable currentAspectRatio= GetGizmoAspectRatio(gizmoName,windowAspectRatio)
	if( currentAspectRatio )
		if( numtype(windowAspectRatio) == 0 && windowAspectRatio  > 0 )
			meta = "!"+num2char(18)	// checked
			sprintf currentRatioStr, " (%.4g)", windowAspectRatio
		else
			sprintf currentRatioStr, " (%.4g)", currentAspectRatio
		endif
	else
		meta = "("	// disabled
	endif	
	meta= "\\M0:"+meta+":"
	ExperimentModified wasModified	// set experiment modified back

	return meta + "Preserve Window Aspect Ratio"+currentRatioStr
End

Function TogglePreserveGizmoAspectRatio(gizmoName)
	String gizmoName
	
	if( !ValidGizmoName(gizmoName) )
		return 0
	endif
	Variable windowAspectRatio	// GetGizmoAspectRatio output: the user-specified fixed window aspect ratio, or NaN if the user hasn't set a window aspect ratio
	Variable currentAspectRatio= GetGizmoAspectRatio(gizmoName,windowAspectRatio)
	if( numtype(windowAspectRatio) == 0 && windowAspectRatio  > 0 )
		windowAspectRatio= NaN
	else
		windowAspectRatio= currentAspectRatio
	endif
	SetGizmoAspectRatio(gizmoName, windowAspectRatio)
End

Function/S MakeGizmoAspectRatioMenu(gizmoName,aspectWidth,aspectHeight)
	String gizmoName
	Variable aspectWidth,aspectHeight

	String meta=""
	Variable windowAspectRatio	// GetGizmoAspectRatio output: the *user-specified* fixed window aspect ratio, or NaN if the user hasn't set a window aspect ratio
	ExperimentModified 1		// mark it modified, not modifed, we don't care. We just want the current modified value, which is the local V_Flag
	Variable wasModified= V_Flag
	Variable currentWindowAspect= GetGizmoAspectRatio(gizmoName,windowAspectRatio)
	if( currentWindowAspect )
		Variable error= abs(currentWindowAspect - aspectWidth/aspectHeight)
		if( error < currentWindowAspect/200 )
			meta = "!"+num2char(18)	// checked
		endif
	else
		meta = "("	// disabled
	endif	
	meta= "\\M0:"+meta+":"
	String ratioText= "Square"
	if( aspectWidth != aspectHeight )
		sprintf ratioText, "Aspect Ratio %g x %g", aspectWidth,aspectHeight
	endif
	String menuText= meta + "Make Window "+ratioText
	ExperimentModified wasModified	// set experiment modified back
	return menuText
End

// Unlike SetGizmoAspectRatio(), this doesn't enforce "fixed aspect ratio" after setting the aspect ratio
Function MakeGizmoAspectRatio(gizmoName, windowAspectRatio)
	String gizmoName
	Variable windowAspectRatio		// width/height, use NaN to disable changing the window size to the given aspect ratio.

	if( !ValidGizmoName(gizmoName) )
		return 0
	endif

	Variable usersWindowAspectRatio	// GetGizmoAspectRatio output: the *user-specified* fixed window aspect ratio, or NaN if the user hasn't set a window aspect ratio
	GetGizmoAspectRatio(gizmoName,usersWindowAspectRatio)
	
	SetGizmoAspectRatio(gizmoName, windowAspectRatio)
	if( numtype(usersWindowAspectRatio) != 0 )
		Variable/G $WMPerGizmoDFVar(gizmoName,"windowAspectRatio")= NaN
	endif
	return 1
End

Function SetGizmoAspectRatio(gizmoName, windowAspectRatio [,keepCentralBoxSquare,minWidth,minHeight,keepUsersWidth])
	String gizmoName
	Variable windowAspectRatio		// width/height, use NaN to disable changing the window size to the given aspect ratio.
	Variable keepCentralBoxSquare	// optional, default is to allow the central box to change shape as the window resizes.
									// If set along with windowAspectRatio == NaN, the ortho is reshaped to whatever window size the user drags to. 
	Variable minWidth				// optional, default is kMinWidthPoints points
	Variable minHeight				// optional, default is kMinHeightPoints points
	Variable keepUsersWidth		// optional, default is aspect ratio uses the dragged width, changes the height
									// 0 = use dragged height, change the width.
									// 1 = Aspect ratio uses the dragged width, changes the height (the height is usually either shorter than the width or the same)
	if( !ValidGizmoName(gizmoName) )
		return 0
	endif
	
	if( ParamIsDefault(keepCentralBoxSquare) )
		keepCentralBoxSquare=  IsGizmoCentralBoxKeptSquare(gizmoName)
	endif
	if( ParamIsDefault(minWidth) )
		minWidth= kMinWidthPoints
	endif
	if( ParamIsDefault(minHeight) )
		minHeight= kMinHeightPoints
	endif
	if( ParamIsDefault(keepUsersWidth) )
		keepUsersWidth= NumVarOrDefault(WMPerGizmoDFVar(gizmoName,"keepUsersWidth"), 0)
	endif					

	Variable/G $WMPerGizmoDFVar(gizmoName,"windowAspectRatio")= windowAspectRatio
	Variable/G $WMPerGizmoDFVar(gizmoName,"keepCentralBoxSquare")= keepCentralBoxSquare
	Variable/G $WMPerGizmoDFVar(gizmoName,"minWidth")= minWidth
	Variable/G $WMPerGizmoDFVar(gizmoName,"minHeight")= minHeight
	Variable/G $WMPerGizmoDFVar(gizmoName,"keepUsersWidth")= keepUsersWidth

	UpdateGizmoHookForAspectAndBox(gizmoName,usersWindowAspectRatio=windowAspectRatio,keepCentralBoxSquare=keepCentralBoxSquare)

	RestoreGizmoFixedWindowAspect(gizmoName)
	return 1
End

// Returns truth that GizmoFixedAspectNamedHook was installed.
Function UpdateGizmoHookForAspectAndBox(gizmoName[,usersWindowAspectRatio,keepCentralBoxSquare])
	String gizmoName
	Variable usersWindowAspectRatio	// optional input, the *user-specified* fixed window aspect ratio, or NaN if the user hasn't set a window aspect ratio
	Variable keepCentralBoxSquare		// optional input, true or false.

	if( ParamIsDefault(keepCentralBoxSquare) )
		 keepCentralBoxSquare= IsGizmoCentralBoxKeptSquare(gizmoName)
	endif
	
	if( ParamIsDefault(usersWindowAspectRatio) )
		GetGizmoAspectRatio(gizmoName,usersWindowAspectRatio)	// usersWindowAspectRatio is an *output*
	endif
	
	String pathToHookFunction
	if( numtype(usersWindowAspectRatio) == 0 || keepCentralBoxSquare != 0 )
		pathToHookFunction= GetIndependentModuleName()+"#GizmoUtils#GizmoFixedAspectNamedHook"
	else
		pathToHookFunction=""	// remove hook.
	endif

	String cmd
	sprintf cmd, "ModifyGizmo/N=%s namedHookStr={GizmoFixedAspectRatio,\"%s\"}", gizmoName,pathToHookFunction
	GizmoEchoExecute(cmd, slashZ=1, slashQ=1)

	return strlen(pathToHookFunction) > 0
End


Function IsGizmoCentralBoxKeptSquare(gizmoName [,mustStaySquare])
	String gizmoName
	Variable &mustStaySquare	// optional output.  If true, indicates the gizmo window should never be set to non-square central box (for now, only Pie charts have this property)
	
	if( !ParamIsDefault(mustStaySquare) )
		mustStaySquare= 0
	endif
	// Historical: 3D Pie charts always keep their central boxes square to avoid ellipsoids
	if( exists("ProcGlobal#GizmoIs3DPieChart") == 6 )	// 3D pie chart code isn't in the WMGP independent module.
		String oldDF= SetWMGizmoDF()
		Execute "Variable /G isPie=ProcGlobal#GizmoIs3DPieChart(\""+gizmoName+"\")"
		Variable isPie= NumVarOrDefault(WMGizmoDFVar("isPie"),0)
		SetDataFolder oldDF
		if( isPie )
			if( !ParamIsDefault(mustStaySquare) )
				mustStaySquare= 1
			endif
			return 1
		endif
	endif
	
	// Check the GizmoUtils setting, which we also use for the Zoom panel
	NVAR/Z keepCentralBoxSquare= $WMPerGizmoDFVar(gizmoName,"keepCentralBoxSquare")
	if( NVAR_Exists(keepCentralBoxSquare) )
		return keepCentralBoxSquare
	endif
	
	return 0
End


// returns the current window aspect ratio, or 0 if the gizmoName isn't valid (no gizmo of that name)
// Note: "aspect ratio" is the width/height
Function GetGizmoAspectRatio(gizmoName, windowAspectRatio [,keepCentralBoxSquare,minWidth,minHeight,keepUsersWidth] )
	String gizmoName	// input
	Variable &windowAspectRatio	// output: the user-specified fixed window aspect ratio, or NaN if the user hasn't set a window aspect ratio
	Variable &keepCentralBoxSquare, &minWidth, &minHeight, &keepUsersWidth// OPTIONAL outputs

	if( !ValidGizmoName(gizmoName) )
		windowAspectRatio= NaN
		return 0
	endif

	windowAspectRatio= NumVarOrDefault(WMPerGizmoDFVar(gizmoName,"windowAspectRatio"), NaN)	// width/height, 4/3 for TV, old monitors, 16/9 for widescreen

	if( !ParamIsDefault(keepCentralBoxSquare) )
		keepCentralBoxSquare= IsGizmoCentralBoxKeptSquare(gizmoName)
	endif
	if( !ParamIsDefault(minWidth) )
		minWidth= NumVarOrDefault(WMPerGizmoDFVar(gizmoName,"minWidth"), kMinWidthPoints)
	endif
	if( !ParamIsDefault(minHeight) )
		minHeight= NumVarOrDefault(WMPerGizmoDFVar(gizmoName,"minHeight"), kMinHeightPoints)
	endif
	if( !ParamIsDefault(keepUsersWidth) )
		keepUsersWidth= NumVarOrDefault(WMPerGizmoDFVar(gizmoName,"keepUsersWidth"), 0)		
	endif

	Variable left, top, right, bottom
	Variable currentAspectRatio= NaN
	if( GetGizmoCoordinates(gizmoName, left, top, right, bottom) )
		Variable width= right-left
		Variable height= bottom-top
		currentAspectRatio= width / height
	endif
	return currentAspectRatio
End
	
static Function RemoveAspectRatioSettings(gizmoName)
	String gizmoName
	
	Variable/G $WMPerGizmoDFVar(gizmoName,"windowAspectRatio")= NaN	// NaN = "Don't modify the window coordinates to keep the aspect ratio constant"
	Variable/G $WMPerGizmoDFVar(gizmoName,"keepCentralBoxSquare")= 0	// 0 = "Don't modify the ortho ranges to the same aspect ratio while maintaining the current ortho center"
	Variable/G $WMPerGizmoDFVar(gizmoName,"resizeBlock")= 0
End

static Function GizmoFixedAspectNamedHook(s)
	STRUCT WMGizmoHookStruct &s

	String gizmoName= s.winName
	String eventName= s.eventName
	
	strswitch(eventName)
		case "resize":
			Variable resizeBlock= NumVarOrDefault(WMPerGizmoDFVar(gizmoName,"resizeBlock"), 0)
			if( !resizeBlock )
				Variable/G $WMPerGizmoDFVar(gizmoName,"resizeBlock")= 1// reset by RestoreGizmoFixedWindowAspect
				Variable windowAspectRatio= NumVarOrDefault(WMPerGizmoDFVar(gizmoName,"windowAspectRatio"), NaN)
				Variable keepCentralBoxSquare= IsGizmoCentralBoxKeptSquare(gizmoName)
				if( numtype(windowAspectRatio) == 0 || keepCentralBoxSquare != 0 )
					String cmd
					sprintf cmd,  GetIndependentModuleName()+"#GizmoUtils#RestoreGizmoFixedWindowAspect(\"%s\")", gizmoName
					Execute/P/Q/Z cmd	// do this after the hook has returned
				endif
			endif
			break
		case "kill":
			Execute/P/Q/Z GetIndependentModuleName()+"#GizmoUtils#RemoveAspectRatioSettings("+gizmoName+")"
			break
	endswitch
	return 0
End

Function RestoreGizmoFixedWindowAspect(gizmoName)
	String gizmoName
	
	if( !ValidGizmoName(gizmoName) )
		return 0
	endif

	Variable windowAspectRatio= NumVarOrDefault(WMPerGizmoDFVar(gizmoName,"windowAspectRatio"), NaN)	// width/height, 4/3 for TV, old monitors, 16/9 for widescreen

	Variable left, top, right, bottom	// points
	if( GetGizmoCoordinates(gizmoName, left, top, right, bottom) )
		Variable width= right-left
		Variable height= bottom-top

		if( numtype(windowAspectRatio) == 0 && windowAspectRatio > 0 )
			Variable minWidth= NumVarOrDefault(WMPerGizmoDFVar(gizmoName,"minWidth"), kMinWidthPoints)
			Variable minHeight= NumVarOrDefault(WMPerGizmoDFVar(gizmoName,"minHeight"), kMinHeightPoints)
			Variable keepUsersWidth= NumVarOrDefault(WMPerGizmoDFVar(gizmoName,"keepUsersWidth"), 0)		
			// keepUsersWidth = 1 : Aspect ratio uses the dragged width, changes the height (the height is usually either shorter than the width or the same)
			// keepUsersWidth = 0 : use dragged height, change the width.
			if( keepUsersWidth )
				// use width, change height (the height is usually either shorter than the width or the same)
				width= max(minWidth, width)
				height= max(minHeight, width / windowAspectRatio)
			else
				// use height, change width
				height= max(minHeight, height)
				width= max(minWidth, height * windowAspectRatio)
			endif
			right= left+width
			bottom= top+height
			MoveWindow/W=$gizmoName left, top, right, bottom
		endif

		// (Possibly) update ortho
		windowAspectRatio= width/height	// after accounting for window minimum sizes, we may end up with an altered aspect ratio.
		Variable orthoLeft, orthoRight, orthoBottom, orthoTop, zNear, zFar, displayListIndex
		String opName
		GetGizmoOrtho(gizmoName, orthoLeft, orthoRight, orthoBottom, orthoTop, zNear, zFar, displayListIndex=displayListIndex, opName=opName)
	
		Variable changed= AdjustedGizmoOrtho4AspectRatio(gizmoName, orthoLeft, orthoRight, orthoBottom, orthoTop, zNear, zFar, aspectRatio=windowAspectRatio)
		// If different or no ortho display object, set new Ortho
		if( changed || (displayListIndex < 0 ) )
			SetGizmoOrtho(gizmoName, orthoLeft, orthoRight, orthoBottom, orthoTop, zNear, zFar, displayListIndex=displayListIndex, opName=opName)
		endif
	endif

	Variable/G $WMPerGizmoDFVar(gizmoName,"resizeBlock")= 0	// see GizmoFixedAspectNamedHook
End

// Just computes the new ortho if keepCentralBoxSquare is set,
// the new ortho values aren't assigned to Gizmo.
// returns truth that the new values are different.
Function AdjustedGizmoOrtho4AspectRatio(gizmoName, left, right, bottom, top, zNear, zFar [, aspectRatio, keepCentralBoxSquare, keepUsersWidth])
	String gizmoName
	Variable &left, &right, &bottom, &top, &zNear, &zFar		// inputs AND output
	Variable aspectRatio			// optional input: actual aspect ratio of the window: width/height
	Variable keepCentralBoxSquare	// optional input, default is read from IsGizmoCentralBoxKeptSquare()
	Variable keepUsersWidth	// optional input, default is read from NumVarOrDefault(WMPerGizmoDFVar(gizmoName,"keepUsersWidth"), 1)	

	if( !ValidGizmoName(gizmoName) )
		return 0
	endif
	
	if( ParamIsDefault(keepCentralBoxSquare) )
		keepCentralBoxSquare= IsGizmoCentralBoxKeptSquare(gizmoName)
	endif
	if( keepCentralBoxSquare == 0 )
		return 0	// any ortho values are fine and don't need adjusting.
	endif

	if( ParamIsDefault(keepUsersWidth) )
		keepUsersWidth= NumVarOrDefault(WMPerGizmoDFVar(gizmoName,"keepUsersWidth"), 0)	
	endif

	// recompute ortho: we need the window aspect ratio
	if( ParamIsDefault(aspectRatio) )
		Variable wleft, wtop, wright, wbottom	// points
		if( !GetGizmoCoordinates(gizmoName, wleft, wtop, wright, wbottom) )
			return 0
		endif
		aspectRatio= (wright-wleft) / (wbottom-wtop)	// window coordinates: bottom is greater than top
	endif

	if( numtype(aspectRatio) != 0  || aspectRatio <= 0 )
		return 0
	endif

	// match the ortho range to the window aspect ratio
	Variable orthoLeftRightRangeHalf= (right-left)/2
	Variable orthoUpDownRangeHalf= (top - bottom)/2	// unlike window coordinates, the ortho bottom is less than the top value, so this is positive
	// scale the orthos based on the window dimension
	if( keepUsersWidth )	
		// keep width (orthoLeftRightRangeHalf), change orthoUpDownRangeHalf proportionally
		orthoUpDownRangeHalf = orthoLeftRightRangeHalf / aspectRatio
	else
		// keep height (orthoUpDownRangeHalf), change orthoLeftRightRangeHalf proportionally
		orthoLeftRightRangeHalf= orthoUpDownRangeHalf * aspectRatio
	endif
	// keep the ortho center unchanged
	Variable orthoLeftRightCenter= (left+right)/2
	Variable newOrthoLeft= orthoLeftRightCenter - orthoLeftRightRangeHalf
	Variable newOrthoRight= orthoLeftRightCenter + orthoLeftRightRangeHalf

	Variable orthoUpDownCenter= (top+bottom)/2
	Variable newOrthoTop= orthoUpDownCenter + orthoUpDownRangeHalf
	Variable newOrthoBottom= orthoUpDownCenter - orthoUpDownRangeHalf

	Variable adjusted= (left != newOrthoLeft) || (right != newOrthoRight) || (bottom != newOrthoBottom) || (top != newOrthoTop)
	if( adjusted )
		left = newOrthoLeft
		right = newOrthoRight
		bottom = newOrthoBottom
		top = newOrthoTop
	endif
	return adjusted
End