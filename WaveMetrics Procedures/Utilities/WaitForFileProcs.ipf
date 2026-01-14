#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.01

//*******************************************
// These procedures are useful for syncronizing with another application. If the other
// application writes a file as part of its processing, you can make sure that Igor
// waits for the other application using these procedures.
//
// DeleteFileAsNotebook() deletes a file in case it might be left over from
//		a previous invocation.
// WaitForFileToExist() simply waits for a file to exist. This might be useful if the file
// 		is nothing more than a semaphore file.
// WaitForWriteAccesToFile() will, in virtually all cases, wait for the other application
// 		to close the file, presumably after first filling the file with data.
//*******************************************

//*******************************************
//  Revision History
//
//	First version (no version marking)
//		first release
//
//	1.01
//		Fixed bug:  WaitForWriteAccesToFile() opened the file for reading to make sure the file exists, but then
//		didn't close the file.
//*******************************************

// This function implements a tricky way to delete a file from within Igor- as it turns out, if a file is open in a
// notebook window, you can delete the file using DoWindow/K/D.
Function DeleteFileAsNotebook(filePath)
	String filePath
	
	OpenNotebook/N=DeleteThisNotebook /V=0/Z filePath
	if (V_flag == 0)
		DoWindow/K/D DeleteThisNotebook
	endif
end

// This function loops until a given file exists. It determines if the file exists by opening it for reading. If the open
// succedes, then the file exists.
// parameters:
//   filePath		a string containing the *full* path to the file in question
//   initialDelay	time in seconds that the routine waits before trying to open the file the first time
//   timeout		time in seconds before giving up.
//   checkPeriod	the loop waits this long before trying again
//
// return value is zero if the file exists. If the Open takes longer than timeout seconds, the return value
// is the value of V_flag from the Open operation. On my machine, the return value is -43 if the file doesn't exist.
Function WaitForFileToExist(filePath, initialDelay, timeout, checkPeriod)
	String filePath
	Variable initialDelay	// seconds before checking for the first time
	Variable timeout		// seconds to wait before giving up (0 means wait forever)
	Variable checkPeriod	// seconds to wait between tries
	
	Variable myRef
	Variable startTime
	Sleep/S initialDelay
	Variable returnValue = 0
	
	timeout *= 60
	startTime = Ticks
	do
		Open/Z/R myRef as filePath		// open for reading- sharing the file is OK
		if (V_flag == 0)
				close myRef
			break
		endif
		if ( (timeout > 0) && (Ticks - startTime > timeout) )
			returnValue = V_flag
			break
		endif
		Sleep/S checkPeriod
	while(1)
	
	return returnValue
end

// This function loops until a given file exists and is not open by another application.
// It determines if the file exists by opening it for reading. If the open
// succedes, then the file exists. It then tries to open the file for appending (writing at the end). If another application
// has the file open, this usually prevents Igor from opening the file for writing.
//
// parameters:
//   filePath		a string containing the *full* path to the file in question
//   initialDelay	time in seconds that the routine waits before trying to open the file the first time
//   timeout		time in seconds before giving up.
//   checkPeriod	the loop waits this long before trying again
//
// return value is zero if the file exists. If the Open takes longer than timeout seconds, the return value
// is the value of V_flag from the Open operation. On my machine, the return value is -43 if the file doesn't exist.
Function WaitForWriteAccesToFile(filePath, initialDelay, timeout, checkPeriod)
	String filePath
	Variable initialDelay	// seconds before checking for the first time
	Variable timeout		// seconds to wait before giving up (0 means wait forever)
	Variable checkPeriod	// seconds to wait between tries
	
	Variable myRef
	Variable startTime
	Sleep/S initialDelay
	Variable returnValue = 0
	
	timeout *= 60
	startTime = Ticks
	do
		Open/Z/R myRef as filePath		// make sure the file exists before trying to open for writing. Otherwise, it will create the file and report success.
		if (V_flag == 0)
			close myRef					// close it because we just opened i for reading
			Open/Z/A myRef as filePath		// open for append. Write acces isn't shared (usually); Append so that the file isn't erased
				if (V_flag == 0)
					close myRef
				break
			endif
		endif
		if ( (timeout > 0) && (Ticks - startTime > timeout) )
			returnValue = V_flag
			break
		endif
		Sleep/S checkPeriod
	while(1)
	
	return returnValue
end

