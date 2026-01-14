#pragma rtGlobals=1		// Use modern global access method.
#pragma IgorVersion=5.0

// Procedures to make it easy to do something for each folder and/or file starting with a given folder.
// To use:
// 1) create a function like WM_WalkFoldersCallback() to be called for each folder (and optionally each file) in the folder tree.
// 2) call WM_WalkFolders(topPathName, walkFiles, recurse, 0, yourFunction, str)
//

// prototype for the callback parameter of WM_WalkFolders().
// This isn't actually used for anything other than to define the return type and parameters of the callback
// parameter for WM_WalkFolders(), but you can use it as a learning aid by executing:
// WM_WalkFolders("home", 1, 1, 0, WM_WalkFoldersCallback, "")
Function WM_WalkFoldersCallback(depth, pathName, fileIndex, numFiles, name, str)
	Variable depth			// 0 is the top directory, 1 is the next level down, etc
	String pathName		// the directory's symbolic path name. To get the full path, use PathInfo $pathName
	Variable fileIndex		// 0 is the first file in the current directory, 1 the next, etc. -1 when called for the directory.
	Variable numFiles		// the number of files in the current directory, or -1 if only directories are being walked.
	String name				// if fileIndex >= 0, the file's name. if fileIndex = -1, the directory's name.
	String str				// anything you want. Perhaps a keyword-value string or the path to a wave.
	
	// Build a prefix (a number of tabs to indicate the folder level by indentation)
	String prefix = ""
	Variable i = 0
	for(i=0; i < depth; i+=1 )
		prefix += "\t"
	endfor
	
	if( fileIndex == -1 )	// directory
		Printf "%sf: %s%s\r", prefix, name, str
	else	// file
		Printf "%s[%d/%d]: %s%s\r", prefix, fileIndex+1, numFiles, name	, str// one-based index
		// to open the file, use Open/P=$pathName refNum as name
	endif
	Variable status= 0
	
	return status	// return 0 to continue, return 1 to stop walking the directory.
End

// Calls the callback function for folders (and optionally for files) in the starting directory.
// If recurse is true, the callback function is called on enclosed subfolders, too.
// The callback routine should have the same form as WM_WalkFoldersCallback.
// Specify the name of your function for callback:
// 	WM_WalkFolders(topPathName, walkFiles, recurse, 0, yourFunction, str)
Function WM_WalkFolders(pathName, walkFiles, recurse, level, callback, str)
	String pathName	// Name of symbolic path in which to look for folders. NOT a full path like "hd:dir1:dir2". See  the NewPath operation.
	Variable walkFiles	// True to call the callback routine for files, too. False for just folders.
	Variable recurse	// True to recurse (do it for subfolders too).
	Variable level		// Recursion level. Pass 0 for the top level.
	FUNCREF WM_WalkFoldersCallback callback
	String str			// just a string passed to the callback routine. Use it for anything you like.
	
	Variable status=0
	// list files in the directory defined by pathName before walking the subdirectories
	if( walkFiles )
		String allFilesList= IndexedFile($pathName, -1, "????")	// all files, all creators
		Variable numFiles= ItemsInList(allFilesList)
		Variable fileIndex
		for( fileIndex=0; fileIndex < numFiles; fileIndex+=1 )
			String fileName = StringFromList(fileIndex, allFilesList)
			// File callback
			status=callback(level, pathName, fileIndex, numFiles, fileName, str)
			if( status == 1 )
				return status
			endif	
		endfor
	endif

	Variable dirIndex = 0
	do
		String dirName = IndexedDir($pathName, dirIndex, 0)	// just the directory name
		if (strlen(dirName) == 0)
			break							// No more folders
		endif
		// Directory callback
		status=callback(level, pathName, -1, -1, dirName, str)
		if( status == 1 )
			return status
		endif	
		if (recurse )						// Do we want to go into subfolder?
			String subFolderPathName = "tempPrintFoldersPath_" + num2istr(level+1)
			
			// Form the full path to the indexed folder from the parent's full path
			PathInfo $pathName		// S_path is full path to the parent folder
			String subFolderPath = S_path + dirName	// full path to the folder to walk
			
			NewPath/Q/O $subFolderPathName, subFolderPath
			status=WM_WalkFolders(subFolderPathName, walkFiles, recurse, level+1, callback, str)
			KillPath/Z $subFolderPathName
			if( status == 1 )
				return status
			endif
		endif
		
		dirIndex += 1
	while(1)
	return status
End
