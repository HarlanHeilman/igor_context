#pragma rtGlobals=1		// Use modern global access method.
#pragma Igorversion=6.2	// Requires Igor 6.2 (Save/H)
#pragma version=6.2	// Released with Igor 6.2
#include <Execute Cmd On List>

// JP, Version 6.2 - Works with packed experiments, uses Save/H
// JP, Version 6.13 - CopyAllWavesToHome copies all waves in all data folders to "home", not just those in the current data folder.
// JP, Version 1.1 - Allows fileExtension to be "????" to match all files, regardless of extension (if any extension at all).
// JP, 1/28/99 - initial version.

Menu "Load Waves"
	"-"
	"Load All Waves In Folder..."
End

Menu "Data"
	"-"
	"Copy All Waves To Home..."
End

// LoadAllWavesInFolder - Loads all Igor Binary files or all Text files in a folder as waves.
Proc LoadAllWavesInFolder(type,naming,precision,base,overwrite,makeTable,copyToHome,otherFlags, fileExtension)
	Variable type,naming,overwrite,precision,makeTable,copyToHome,
	String base="wave",otherFlags, fileExtension="(use file type)"
	Prompt type,"data in file:",popup,"Igor Binary;Igor Text;General Text;Delimited Text;"
	Prompt naming,"assign text file wave names:",popup,"auto names using base name;from file, no name dialog;from file, name dialog;"
	Prompt precision,"precision of loaded text:",popup,"double [64 bits];single [32 bits];"
	Prompt base,"auto names start with:"
	Prompt overwrite,"overwrite existing waves?:",popup,"Yes;No;"
	Prompt makeTable,"table options:",popup,"_none_;create new table for waves;append waves to top table;"
	Prompt copyToHome,"copy Igor Binary wave(s) to home?:",popup,"yes: files not needed anymore;no: files are part of experiment"
	Prompt otherFlags,"enter any other LoadWave flags:"
	Prompt fileExtension,"file extension (ex: \".dat\"):"
	
	Silent 1;PauseUpdate
	Variable jg=0
	String fileType="TEXT"
	String fileDescr=""
	String cmd= "LoadWave"
	if( makeTable > 1 )
		cmd+="/E=2"	// always append, so multiple file loads are on same table.
	endif
	if( copyToHome==1 )
		cmd+="/H"
	endif
	if( overwrite==1 )
		cmd+="/O"
	endif
	if( type == 1 )
		fileType="IGBW"
		fileDescr="Igor Binary"
	else
	if( type == 2 )	
		cmd+="/T"
		fileDescr="Igor Text"
	else
	if( type == 3 )
		cmd+="/G"; jg=1
		fileDescr="General Text"
	else
	if( type == 4 )
		cmd+="/J"; jg=1
		fileDescr="Delimited Text"
	endif
	endif
	endif
	endif
	if( jg )	// some options apply only to /J or /G
		if( naming == 1 )		// auto base
			cmd+="/A"
			if( strlen(base) > 0 )
				cmd+= "="+base
			endif
		else					// from file
			cmd+="/W"
			if( naming == 2 )
				cmd+="/A"	// trust file contents, no dialog
			endif
		endif
		if( precision == 1 ) 	// double
			cmd+="/D"
		endif
	endif
	cmd+= otherFlags + "/P=dataFolder \"%s\""
	NewPath/O/M="select folder of "+fileDescr+" waves"  dataFolder	// dialog
	// fix up fileExtension (optional leading period or optional leading *.)
	if( CmpStr(fileExtension,"(use file type)") != 0 )
		// override fileType (but not type) to list file with given file extension
		if( CmpStr(fileExtension[0],".") == 0 )
			fileType= fileExtension
		else
			if( CmpStr(fileExtension[0,1],"*.") == 0 )
				fileType= fileExtension[1,99]
			else
				if( CmpStr(fileExtension,"????") == 0 )
					fileType= fileExtension
				else
					fileType= "." + fileExtension
				endif
			endif
		endif	
	endif

	String files= ListFilesOfType("dataFolder",type,fileType) 
	if( makeTable == 2 )
		Edit	// blank table to append to
	endif
	ExecuteCmdOnList(cmd, files)
End

// The CopyAllWavesToHome macro copies all waves in the experiment to home,
// which adopts all shared waves so that references to external files are no longer
// needed (see Sharing Versus Copying Igor Binary Files):

Function/S ListFilesOfType(dataFolderStr,type,fileTypeStr)
	String dataFolderStr
	Variable type			// popup,"Igor Binary;Igor Text;General Text;Delimited Text;"
	String fileTypeStr		// usually "TEXT" for *.txt files on Windows

	String files=""
	if( type == 1 )
		files= IndexedFile($dataFolderStr,-1,fileTypeStr)	// list of all files with matching type
	else
		if( type == 2 )	// Igor Text, either "TEXT" or "IGTX" (.txt or .itx)
			// open each TEXT or IGTX file, and if the first line is "IGOR", add it to files
			files= IgorOrTextFiles(dataFolderStr,fileTypeStr,1)		// on Windows, *.txt (or user's file type)
			if( CmpStr(fileTypeStr,"IGTX") != 0 )					// avoid listing a file twice
				files +=  IgorOrTextFiles(dataFolderStr,"IGTX",1)	// on Windows, *.itx,
			endif
		else
			files= IgorOrTextFiles(dataFolderStr,fileTypeStr,0)		// on Windows, *.txt
		endif
	endif
	return files
End

// Why the IgorOrTextFiles function is needed:
// 1.	While Igor does save Igor Text files using file type "TEXT" (*.txt),
//  	Igor is set up to automatically recognize "IGTX" (or *.itx) files as Igor Text files.
// 2.	Additionally, Igor Text files have a specific format, and can be easily distinguished
//  	from ordinary text files by reading the first line and checking that it is "IGOR\r"

Function/S IgorOrTextFiles(dataFolderStr,fileTypeStr,wantIgorText)
	String dataFolderStr,fileTypeStr
	Variable wantIgorText

	String fileNameStr,firstLineStr,files=""
	Variable refNum,i= 0,isIgorText
	do
		fileNameStr= IndexedFile($dataFolderStr,i,fileTypeStr)
		if( strlen(fileNameStr) == 0 )
			break
		endif
		Open/P=$dataFolderStr/R refNum as fileNameStr		
		FReadLine refNum, firstLineStr
		Close refNum
		isIgorText= (strlen(firstLineStr) == 5) %& (CmpStr(firstLineStr[0,3],"IGOR") == 0) // file IS Igor text!
		if( ! (isIgorText %^ wantIgorText) )
			files += fileNameStr+";"
		endif
		i+= 1
	while( 1 ) 	// exit via break
	return files
End

Proc CopyAllWavesToHome()
	Silent 1;PauseUpdate
	DoAlert 1,"This operation is not undoable.\r\rReally copy all shared waves into this experiment?"
	if( V_Flag == 1)
		String path= "root:"	// walk all data folders starting at the very top
		String cmd= "Save/H %s"	// and adopt them into this experiment
		String waveListMatchStr= "*" // all wave names
		String waveListOptionsStr= "" // all kinds of waves
		WalkDataFoldersWithWaveCmd(path, cmd, waveListMatchStr, waveListOptionsStr)
	endif
End
