#pragma rtGlobals=1		// Use modern global access method.
// <File Name Utilities>
#pragma version=4
//
// Version 4 - 02/03/2003, JP - added FolderFromPath(filePath)
// Version 3 - 06/06/2000, JP - revisions to support Windows network volume paths  like \\Server\Volume:dir:file.ext
// Version 2 - 01/31/2000, JP - added WMDirectoryExists(pathNameStr)
//			     02/22/2000, JP - added WMFileExists(filePath) and WMDeleteFile(filePathWithExtension)
//			     Now this procedure file deals with more than file names, it actually manipulates files and directories.

//
// FileExtension returns ".ext" from something like "thepathandFile.ext"
//
Function/S FileExtension(fileNameAndExt)
	String fileNameAndExt

	Variable dotPos= searchBackwards(fileNameAndExt,".")
	if (dotPos < 0 )
		return ""	// no extension found
	endif
	return fileNameAndExt[dotPos,inf]
End

//
// FileNameOnly returns "theFile" from something like "HD:folder:subfolder:theFile.ext"
//
Function/S FileNameOnly(filePath)
	String filePath

	String fileNameAndExt= RemoveFilePath(filePath)
	Variable dotPos= searchBackwards(fileNameAndExt,".")
	if (dotPos < 0 )
		dotPos = strlen(fileNameAndExt)
	endif
	return fileNameAndExt[0,dotPos-1]
End

//
// RemoveFilePath returns "theFile.ext" from something like "HD:folder:subfolder:theFile.ext"
//
// Note: this has nothing to do with symbolic path names.
//
Function/S RemoveFilePath(filePath)
	String filePath
	Variable len= strlen(FilePathOnly(filePath))
	return filePath[len,inf]
End

//
// FilePathOnly returns "HD:folder:subfolder:" from something like "HD:folder:subfolder:theFile.ext"
//
//	If filePath is something like  "\\\\Server\\Volume", then "\\\\Server\\" is returned.
//
// Note: this has nothing to do with symbolic path names.
//
Function/S FilePathOnly(filePath)	// "HD:folder1:file.ext", or "C:\folder2\file.ext"
	String filePath					//  or "\\\\Server\\Volume:dir:file.ext" or "\\\\Server\\Volume:file.ext"

	Variable slashPos= searchBackwards(filePath,"\\")	// windows folder or Server-Volume separator
	Variable colonPos= searchBackwards(filePath,":")	// Mac or lone drive letter ("C:")
	Variable pathPos= max(slashPos,colonPos)	// Choose separator closest to the end, could be -1.
	filePath= filePath[0,pathPos]			// retains last separator, removes file.ext.
	return filePath							//  If no path separator, returns "", which RemoveFilePath() relies on.
End

//
// FolderFromPath returns "subfolder" from something like "HD:folder:subfolder:theFile.ext"
//
// Note: this has nothing to do with symbolic path names.
//
Function/S FolderFromPath(filePath)
	String filePath
	
	Variable slashPos= searchBackwards(filePath,"\\")	// windows folder or Server-Volume separator
	Variable colonPos= searchBackwards(filePath,":")	// Mac or lone drive letter ("C:")
	Variable pathPos= max(slashPos,colonPos)	// Choose separator closest to the end, could be -1.
	filePath= filePath[0,pathPos-1]			// removes last separator and file.ext.
	return FileNameOnly(filePath)				// treats folder name as file, returns folder name.
End

//
// ParentFolder returns "HD:folder:" from something like "HD:folder:subfolder:theFile.ext"
//
//	If filePath is something like  "HD:theFile.ext" or "\\\\Server\\file.ext" (there is no parent folder), then "" is returned.
//	If filePath is something like  "\\\\Server\\Volume:theFile.ext", then "\\\\Server\\" is returned.
//
Function/S ParentFolder(filePath)	// "HD:folder1:file.ext", or "D:\folder2\file.ext"
	String filePath					//  or "\\\\Server\\Volume:dir:file.ext" or "\\\\Server\\Volume:file.ext"
	
	filePath= FilePathOnly(filePath)
	Variable len= strlen(filePath)
	if( len > 0 )
		if( (CmpStr(filePath[len-3],"\\") == 0) %& (CmpStr(filePath[len-2],"\\") == 0) )
			len -= 1
		endif
		filePath= FilePathOnly(filePath[0,len-2])	// remove trailing ":", "\\", or "\\\\" to force next level up
		len= strlen(filePath)
		if( len > 0 )
			filePath= FilePathOnly(filePath)
			Variable lastChar= strlen(filePath)-1
			if( (lastChar >= 0) %& (CmpStr(filePath[lastChar],":") != 0) %& (CmpStr(filePath[lastChar],"\\") != 0) )
				filePath= ""
			endif
		endif
	endif
	return filePath
End

Function searchBackwards(str,key)
	String str,key

	Variable pos= -1, lastPos
	do
		lastPos= pos
		pos= strsearch(str,key,lastPos+1)
	while (pos >= 0 )
	return lastPos
End

// Returns the full path to the directory if it exists or "" if it does not exist.
Function/S WMDirectoryExists(pathName)
	String pathName

	PathInfo $pathName
	String pathValue= S_path // there is a path value
	if( strlen(pathValue) )
		String pn= UniqueName("WMpath",12,0)
		NewPath/Q/O/Z $pn pathValue // checks the directory's actual existence
		PathInfo $pn
		pathValue= S_path // there still is a path value
		KillPath/Z $pn
	endif
	return pathValue
End

//	Returns 1 if the file exists, 0 if not. The file is NOT open upon return.
Function WMFileExists(filePath)
	String filePath	// not a symbolic path, something like: "MyDisk:subfolder:file.txt" or "C:\\MyFolder\\

	if( strlen(filePath) == 0 )
		return 0
	endif
	Variable fileNo
	Open/R/Z fileNo filePath
	if( V_Flag == 0 )	// file exists
		Close fileNo
		return 1
	else
		return 0
	endif
End


//	Deletes the file, if it exists. The file is presumed not open for read.
//	Returns 1 if the file existed, 0 if not.
Function WMDeleteFile(filePathWithExtension)
	String filePathWithExtension

	// DoWindow can delete only notebook files, so we open the file as a Notebook!
	String name= UniqueName("doomed",10,0)	// notebook name
	OpenNotebook/N=$name/V=0/Z filePathWithExtension	//  open invisibly
	Variable existed= V_Flag == 0 
	if( existed ) // file exists
		DoWindow/D/K $name
	endif
	return existed	// 1 if file existed, 0 if not.
End
