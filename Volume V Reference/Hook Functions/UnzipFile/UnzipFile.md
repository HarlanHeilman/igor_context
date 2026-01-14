# UnzipFile

UnzipFile
V-1051
Details
The unwrap operation works with 1D waves only. See ImageUnwrapPhase for phase unwrapping in two 
dimensions.
Examples
If you perform an FFT on a wave, the result is a complex wave in rectangular coordinates. You can create a 
real wave that contains the phase of the result of the FFT with the command:
wave2 = imag(r2polar(wave1))
However, the rectangular to polar conversion leaves the phase information modulo 2. You can restore the 
phase information with the command:
Unwrap 2*pi, wave2
Because the first point of a wave that has been FFTed has no phase information, in this example you would 
precede the Unwrap command with the command:
wave2[0] = wave2[1]
See Also
The ImageUnwrapPhase operation and mod function.
UnzipFile
UnzipFile [ /O[=mode] /PASS=passwordStr /PIN=inputPathName /POUT=outputPathName 
/Z[=z] ] inputFileStr, outputFolderStr
The UnzipFile operation unzips a file and saves the contents of the file in the specified output directory.
Warning: If you specify /O=2 for an output directory that already exists, all previous contents of the 
directory are deleted.
The UnzipFile operation was added in Igor Pro 9.00.
Input File Parameter
inputFileStr specifies the zip file to unzip. The file name extension is not important but the file must be a zip 
file.
inputFileStr can be a full path to the file, in which case /PIN=inputPathName is not needed, a partial path 
relative to the directory associated with inputPathName, or the name of a file in the folder associated with 
inputPathName.
If you use a full or partial path for inputFileStr, see Path Separators on page III-451 for details on forming 
the path.
Output Folder Parameter
outputFolderStr specifies the directory into which the contents of the zip file will be extracted.
outputFolderStr can be a full path to the directory, in which case /POUT=outputPathName is not needed, a 
partial path relative to the directory associated with outputPathName, or an empty string in which case the 
directory specified by /POUT=outputPathName is used for the output directory.
If outputFolderStr is an empty string, the /POUT flag specifies the output directory.
If outputFolderStr is not an empty string, it must end with a directory name and not a path separator such 
as colon or backslash.
If you use a full or partial path for outputFolderStr, see Path Separators on page III-451 for details on forming 
the path.
If the output directory does not exist, it is created automatically.

UnzipFile
V-1052
Flags
Output Variables
UnzipFile sets the following output variables:
Limitations
File and directory names within a zip file that contain non-ASCII characters may not have the correct names 
after unzipping.
The created and modified timestamps of a file are reconstructed with limited range and precision. Some zip 
files store these timestamps in an alternative format that allows for greater precision and range, but the 
current unzip algorithm does not support this newer format.
/O[=mode]
/PASS=passwordStr
Specifies the password for a password-protected zip file. Only the older ZipCrypto 
"encryption" algorithm is supported, not the newer and much more secure AES-256 
algorithm.
/PIN=inputPathName
Contributes to the specification of the input zip file to be extracted. inputPathName is 
the name of an existing symbolic path. See Input File Parameter above for details.
/POUT=outputPathName
/
Contributes to the specification of the output directory into which the zip file's contents 
will be extracted. outputPathName is the name of an existing symbolic path. See Output 
Folder Parameter above for details.
/Z[=z]
V_flag
V_flag is set to zero if the operation succeeds or to a non-zero Igor error code if it fails. 
You can use V_flag along with the /Z flag to handle errors and prevent them from 
halting procedure execution.
S_outputFullPath
A string containing the full path to the output directory. If the operation fails, 
S_outputFullPath is set to "".
Controls whether the contents of the output directory are overwritten.
mode=0:
Does not overwrite. If the output directory exists and is not empty, the 
operation generates an error. This is the default behavior if you omit /O.
mode=1:
Merges the contents of the zip file with the existing contents of the 
output directory. Any existing file with the same name as a file within 
the zip file is overwritten.
Unlike /O=2, the contents of the output directory and any subdirectories 
are not deleted. If the output directory already contains files whose 
names do not conflict with files in the zip file, those files remain 
untouched.
/O=1 is the same as /O.
mode=2:
Deletes all contents of the output directory before extracting the 
contents of the zip file. Use this option if you want the contents of the 
output directory to exactly reflect the contents of the zip file.
Warning: If you specify /O=2 for an output directory that already exists, 
all previous contents of the directory are deleted.
Suppress error generation.
/Z alone has the same effect as /Z=1.
/Z=0:
Do not suppress errors. If an error occurs, Igor aborts procedure 
execution. This is the default behavior if you omit /Z.
/Z=1:
Suppress errors. Errors do not abort procedure execution. Check the 
V_Flag output variable to see if an error occurred.
