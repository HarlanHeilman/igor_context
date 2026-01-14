#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later

// This procedure file is to help you evaluate saving HDF5 packed
// experiment files with compression so you can see the effect of
// compression on experiment file size and on the time required to
// save the experiment. For instructions on using this file, execute:
//	DisplayHelpTopic "HDF5 Compression for Saving Experiment Files"

static Function/S GetElapsedTimeString(double elapsedTimeInSeconds)
	String str
	
	if (elapsedTimeInSeconds < .001)
		int microseconds = round(elapsedTimeInSeconds*1000000)
		sprintf str, "%d µs", microseconds
	else
		if (elapsedTimeInSeconds < 1)
			int milliseconds = round(elapsedTimeInSeconds*1000)
			sprintf str, "%d ms", milliseconds
		else
			sprintf str, "%.2g s", elapsedTimeInSeconds
		endif
	endif
	
	return str
End

Function TestHDF5ExperimentCompression(int minWaveElements, int gzipLevel, int shuffle)
	String fileName
	Variable timerRefNum
	
	// Save experiment copy with no compression
	fileName = "Test Save HDF5 Experiment No Compression.h5xp"
	timerRefNum = StartMSTimer
	SaveExperiment /C /F={2, "", 0} /COMP={0,0,0} /P=home as fileName
	double elapsedMicroSecondsUncompressed = StopMSTimer(timerRefNum)
	String elapsedTimeUncompressedStr = GetElapsedTimeString(elapsedMicroSecondsUncompressed / 1E6)
	GetFileFolderInfo/P=home/Q/Z fileName
	int fileSizeUncompressed = V_logEOF
	DeleteFile /P=home /Z fileName

	// Save experiment copy with compression
	sprintf fileName, "Test minWaveElements=%d, gzipLevel=%d, shuffle=%d.h5xp", minWaveElements, gzipLevel, shuffle
	timerRefNum = StartMSTimer
	SaveExperiment /C /F={2, "", 0} /COMP={minWaveElements,gzipLevel,shuffle} /P=home as fileName
	double elapsedMicroSecondsCompressed = StopMSTimer(timerRefNum)
	String elapsedTimeCompressedStr = GetElapsedTimeString(elapsedMicroSecondsCompressed / 1E6)
	GetFileFolderInfo/P=home/Q/Z fileName
	int fileSizeCompressed = V_logEOF
	DeleteFile /P=home /Z fileName
	
	double fileSizeRatio = fileSizeCompressed / fileSizeUncompressed
	double compressionRatio = 1 / fileSizeRatio
	double elapsedTimeRatio = elapsedMicroSecondsCompressed / elapsedMicroSecondsUncompressed
	
	String message
	Printf "HDF5 experiment save with minWaveElements=%d, gzipLevel=%d, shuffle=%d:\r", minWaveElements, gzipLevel, shuffle
	Printf "\t\tElapsed time uncompressed=%s, elapsed time compressed=%s, elapsed time ratio=%g\r", elapsedTimeUncompressedStr, elapsedTimeCompressedStr, elapsedTimeRatio
	Printf "\t\tFile size uncompressed=%d, file size compressed=%d, compression ratio=%g\r", fileSizeUncompressed, fileSizeCompressed, compressionRatio
End
