#pragma rtGlobals=1
#pragma version=6.30	// Shipped with Igor 6.30

//	JP, 8/17/2012, Version 6.30 - Removed inclusion of <Strings as Lists>.
//	JP, 1/11/2010, Version 6.13 - Added WalkDataFoldersWithWaveCmd.
//	JP, 7/8/2008, Version 6.1 - Rewrote ExecuteCmdOnList to use built-in StringFromList.
//	HR, 12/19/1995, Version 1.1 - Added ExecuteCmdOnQuotedList function.

//	ExecuteCmdOnList(cmdTemplate, list)
//		Executes the specified command on each item in the list.
//		list is a semicolon-separated list of items, usually wave names.
//		cmdTemplate is an Igor command with "%s" in place of the item.
//		NOTE: %s may occur only once in cmdTemplate.
//		Example:
//			Make wave0=x, wave1=2*x; ExecuteCmdOnList("AppendToGraph %s", "wave0;wave1")
//
//		If the list consists of wave names or data folder names that may be liberal names,
//		call ExecuteCmdOnQuotedList instead of ExecuteCmdOnList.

Function ExecuteCmdOnList(cmdTemplate, list)
	String cmdTemplate
	String list
	
	String theItem								// the item to operate on
	Variable index=0
	String cmd
	
	do
		theItem= StringFromList(index,list)
		if (strlen(theItem) == 0)
			break								// ran out of items
		endif
		sprintf cmd, cmdTemplate, theItem
		Execute cmd
		index += 1
	while (1)		// loop until break above
End

// ExecuteCmdOnQuotedList(cmdTemplate, list)
//		Use this instead of ExecuteCmdOnList if the list contains wave or data folder names.
//		It creates a local copy of the list, adding single quotes for liberal names and then
//		calls ExecuteCmdOnList.
Function ExecuteCmdOnQuotedList(cmdTemplate, list)
	String cmdTemplate
	String list
	
	String quotedList = LocalPossiblyQuoteList(list, ";")
	ExecuteCmdOnList(cmdTemplate, quotedList)
End

//  LocalPossiblyQuoteList(list, separator)
//	Input is a list of names that may contain liberal names.
//	The input list is expected to be a standard separated list, like "wave0;wave1;wave2;".
//	Returns the list with liberal names quoted.
//	Example:
//		Input:		"wave0;wave 1;"
//		Output:		"wave0;'wave 1';"
static Function/S  LocalPossiblyQuoteList(list, separator)		// Added in version 6.30 of this file.
	String list
	String separator
	
	String item, outputList = ""
	Variable i= 0
	Variable items= ItemsInList(list, separator)
	do
		if (i >= items)			// no more items?
			break
		endif
		item= StringFromList(i, list, separator)
		outputList += PossiblyQuoteName(item) + separator
		i += 1
	while(1)
	return outputList
End

// WalkDataFoldersWithWaveCmd(path, cmdTemplate, waveListMatchStr, waveListOptionsStr)
//		Beginning with (data folder) path, executes the command template on matching waves
//		and then does the same in each sub data folder.
Function WalkDataFoldersWithWaveCmd(path, cmdTemplate, waveListMatchStr, waveListOptionsStr)
	String path				// to walk all data folders, pass "root:" WITH the : char. To use the current data folder, use ":" or GetDataFolder(1)
	String cmdTemplate		// %s is replaced with each wave name and the command is Executed. For example: "Save/P=home/O %s"
	String waveListMatchStr		// "*" or "wave*" or "!*x", etc. See WaveList for details.
	String waveListOptionsStr	// usually "". see WaveList's optionsStr for details.

	String savDF= GetDataFolder(1)
	SetDataFolder path

	String listOfMatchingWaves= WaveList(waveListMatchStr,";",waveListOptionsStr)
	ExecuteCmdOnQuotedList(cmdTemplate, listOfMatchingWaves)

	Variable i, numDataFolders = CountObjects(":",4)
	for(i=0; i<numDataFolders; i+=1)
		String nextPath = GetIndexedObjName(":",4,i)
		WalkDataFoldersWithWaveCmd(nextPath, cmdTemplate, waveListMatchStr, waveListOptionsStr)
	endfor

	SetDataFolder savDF
End
