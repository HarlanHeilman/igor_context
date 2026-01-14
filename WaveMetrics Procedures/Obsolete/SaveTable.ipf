#pragma rtGlobals=2		// Use modern global access method.

//	SaveTableAsIgorText()
//
//	Saves the top table window as an Igor text file. Adds a menu item to the Table menu.
//
//	The data for all of the waves in the table are saved to the Igor text file,
//	followed by the commands to recreate the table.
//	
//	To recreate the table in another experiment, choose Data->Load Waves->Load Igor Text.
//	When you do this, first a data folder is created with the same name as the original
//	table. Then the waves are loaded into that data folder. Then the table is created.
//
//	The data folder hierarchy is maintained.
//
//	Known Limitations:
//		The function does not support having just the real or just the imaginary part of
//		 a complex wave in the table and will cosmetically misbehave.
//
//	History:
//		November 5, 2001: Version 1.0.

Menu "Table"
	"Save Table As Igor Text...", SaveTableAsIgorText()
End

//	PossiblyAddSuffix(name, recreationMacroStr)
//	name is an already-possibly-quoted wave named.
//	recreationMacroStr is the text of the recreation macro for the table in which the wave is displayed.
//	If the table contains just the data columns of the wave, this function returns the name unchanged.
//	If it contains both data and index columns, the suffix ".id" is added.
//	If it contains both data and dimension label columns, the suffix ".ld" is added.
//	And so on such that the returned name is suitable for an Edit or AppendToTable command.
//	This is achieved by searching the recreation macro for the name. I depends on the
//	fact that the name appears in the recreation macro in an Edit or AppendToTable command
//	before it appears in any other (e.g., ModifyTable) command.
static Function/S PossiblyAddSuffix(name, recreationMacroStr)
	String name
	String recreationMacroStr

	Variable pos = strsearch(recreationMacroStr, name, 0)
	if (pos > 0)
		pos += strlen(name)			// Skip over the name
		if (CmpStr(recreationMacroStr[pos],".") == 0)
			// We found a suffix
			String suffix = "."
			do
				pos += 1
				String next = recreationMacroStr[pos]
				strswitch(next)
					case "i":
					case "x":
					case "l":
					case "d":
						suffix += next
						break
					default:
						next = ""
				endswitch
			while(strlen(next)>0)
			name += suffix
		endif
	endif
	return name
End

//	GetDataFolderCmds(path)
//	Returns NewDataFolder commands which will set up the current data folder
//	at the time the wave is loaded back into Igor.
static Function/S GetDataFolderCmds(path)
	String path				// A full path to wave, e.g. root:FolderA:wave0
	
	String cmds = ""
	String df
	
	Variable numItems = ItemsInList(path, ":")
	if (numItems < 3)
		return ""			// The wave is in the root now and will wind up in the main data folder when it is reloaded.
	endif
	
	Variable index = 1		// 1 to skip root
	do
		df = StringFromList(index, path, ":")
		if (strlen(df) == 0)
			break
		endif
		df = PossiblyQuoteName(df)
		cmds += "X NewDataFolder/O/S " + df + "\r"
		index += 1
	while(index < numItems-1)			// Exclude the wave name at the end.
	
	return cmds
End

//	GetDataFolderBackupCmd(path)
//	Returns a SetDataFolder command which will restore the current data folder
//	to the main folder for the load.
static Function/S GetDataFolderBackupCmd(path)
	String path				// A full path to wave, e.g. root:FolderA:wave0
	
	String cmd = ""
	String df
	
	Variable numItems = ItemsInList(path, ":")
	if (numItems < 3)
		return ""			// The wave is in the root now and will wind up in the main data folder when it is reloaded.
	endif
	
	Variable index = 1		// 1 to skip root
	do
		df = StringFromList(index, path, ":")
		if (strlen(df) == 0)
			break
		endif
		cmd += ":"
		index += 1
	while(index < numItems-1)			// Exclude the wave name at the end.
	
	if (strlen(cmd) > 0)
		cmd = "X SetDataFolder " + cmd + ":" + "\r"
	endif
	
	return cmd
End

Function SaveTableAsIgorText()
	String tableName = WinName(0, 2)
	if (strlen(tableName) == 0)
		Abort "Activate a table before running SaveTableAsIgorText"
	endif

	// Ask the user to specify the file to be written.
	Variable refNum						// Dummy used for Open/D.
	Open/D refNum as tableName+".itx"	// Display a dialog to get file to create.
	if (strlen(S_fileName) == 0)			// S_fileName is created by Open.
		return -1
	endif
	String fullFilePath = S_fileName

	// Create command which will create a new data folder into which data will be loaded.
	String cmd = "IGOR\rX NewDataFolder/S " + tableName + "\r\r"
	Open refNum as fullFilePath
	FBinWrite refNum, cmd
	Close refNum
	
	// Save the waves to an Igor text file and accumulate the commands that will be needed to recreate the table.
	String recreationMacroStr = WinRecreation(tableName, 0)
	String editCmds = ""			// Will contain commands to recreate the table.
	String name, path, prevPath = ""
	String listOfWavesSaved = ""	// Used to detect name conflicts.
	Variable index = 0
	do
		Wave w = WaveRefIndexed(tableName, index, 1)
		if (!WaveExists(w))
			break					// No more waves in the table.
		endif
		path = GetWavesDataFolder(w, 2)
		if (CmpStr(path,prevPath) != 0)			// Avoid writing the same wave twice which would
			// Write commands to set the data folder into which the wave will be loaded.
			cmd = GetDataFolderCmds(path)
			Open/A refNum as fullFilePath
			FBinWrite refNum, cmd
			Close refNum

			Save/A=2/T/O $path as fullFilePath		// happen for complex and multi-dimensional waves.
			name = NameOfWave(w)
			listOfWavesSaved += name + ";"
			name = PossiblyQuoteName(name)
			name = PossiblyAddSuffix(name, recreationMacroStr)
			if (index == 0)
				sprintf cmd, "X Edit %s\r", name
			else
				sprintf cmd, "X AppendToTable %s\r", name
			endif
			Open/A refNum as fullFilePath
			FBinWrite refNum, cmd
			cmd = GetDataFolderBackupCmd(path)	// Command to backup to the main data folder.
			cmd += "\r"
			FBinWrite refNum, cmd
			Close refNum
		endif
		prevPath = path
		index += 1
	while(1)
	
	// Write style (ModifyTable) commands to the file.
	Open/A refNum as fullFilePath
	String styleCmds = WinRecreation(tableName, 1)		// This is a style macro.
	
	Variable pos1 = 0, pos2
	Variable line = 0						// Start counting line numbers.
	String text
	do
		pos2 = strsearch(styleCmds, "\r", pos1)
		if (pos2 < 0)
			break							// No more lines of text.
		endif
		text = styleCmds[pos1, pos2]		// The next line
		if (CmpStr(text[0,2], "End") == 0)
			break							// Hit EndMacro or End
		endif
		if (line > 1)						// Skip Macro and PauseUpdate lines.
			text = "X " + text				// Prepend X which is needed to execute a command in an Igor Text file.
			FBinWrite refNum, text
		endif
		line += 1
		pos1 = pos2 + 1	
	while(1)
	
	// Restore current data folder
	cmd = "X SetDataFolder ::\r"
	FBinWrite refNum, cmd
	
	Close refNum
End
