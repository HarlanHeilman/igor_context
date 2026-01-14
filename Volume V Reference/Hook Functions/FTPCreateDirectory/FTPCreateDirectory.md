# FTPCreateDirectory

FStatus
V-265
FStatus 
FStatus refNum
The FStatus operation provides file status information for a file.
Parameters
refNum is a file reference number obtained from the Open operation.
Details
FStatus supports files of any length.
FStatus sets the following variables:
The keyword-packed information string for S_info consists of a sequence of sections with the following 
form: keyword:value; You can pick a value out of a keyword-packed string using the NumberByKey and 
StringByKey functions.
Here are the keywords for S_info:
See Also
Open, FGetPos, FSetPos
FTPCreateDirectory
FTPCreateDirectory [flags] urlStr
The FTPCreateDirectory operation creates a directory on an FTP server on the Internet.
For background information on Igor's FTP capabilities and other important details, see File Transfer 
Protocol (FTP) on page IV-272.
FTPCreateDirectory sets V_flag to zero if the operation succeeds or to a non-zero error code if it fails.
If the directory specified by urlStr already exists on the server, the server contents are not touched and 
V_flag is set to -1. This is not treated as an error.
Parameters
urlStr specifies the directory to create. It consists of a naming scheme (always "ftp://"), a computer name 
(e.g., "ftp.wavemetrics.com" or "38.170.234.2"), and a path (e.g., "/test/newDirectory"). For example:
"ftp://ftp.wavemetrics.com/test/newDirectory"
urlStr must always end with a directory name, and must not end with a slash.
V_flag
Nonzero (true) if refNum is valid, in which case FStatus sets the other variables as well.
V_filePos
Current file position for the file in bytes from the start.
In Igor7 or later, if you only want to know the current file position, use FGetPos 
instead of FStatus, which is slower.
V_logEOF
Total number of bytes in the file.
S_fileName
Name of the file.
S_path
Path from the volume to the folder containing the file. For example, "hd:Folder1:Folder2:". 
This is suitable for use as an input to the NewPath operation. Note that on the Windows 
operating system Igor uses a colon between folders instead of the Windows-standard 
backslash to avoid confusion with Igor’s use of backslash to start an escape sequence (see 
Escape Sequences in Strings on page IV-14).
S_info
Keyword-packed information string.
Keyword
Type
Meaning
PATH
string
Name of the symbolic path in which the file is located. This will be empty if 
there is no such symbolic path.
WRITEABLE
number
1 if file can be written to, 0 if not.

FTPCreateDirectory
V-266
To indicate that urlStr contains an absolute path, insert an extra '/' character between the computer name 
and the path. For example:
ftp://ftp.wavemetrics.com//pub/test/newDirectory
If you do not specify that the path in urlStr is absolute, it is interpreted as relative to the FTP user's base 
directory. Since pub is the base directory for an anonymous user at wavemetrics.com, these URLs reference 
the same directory for an anonymous user:
ftp://ftp.wavemetrics.com//pub/test/newDirectory
// Absolute path
ftp://ftp.wavemetrics.com/test/newDirectory
// Relative to base directory
Special characters, such as punctuation, that are used in urlStr may be incorrectly interpreted by the 
operation. If you get unexpected results and urlStr contains such characters, you can try percent-encoding 
the special characters. See Percent Encoding on page IV-268 for additional information.
Flags
Examples
// Create a directory.
String url = "ftp://ftp.wavemetrics.com/pub/test/newDirectory"
FTPCreateDirectory url
See Also
File Transfer Protocol (FTP) on page IV-272.
FTPDelete, FTPDownload, FTPUpload, URLEncode
/N=portNumber
Specifies the server's TCP/IP port number to use (default is 21). In almost all cases, the 
default will be correct so you won't need to use the /N flag.
/U=userNameStr
Specifies the user name to be used when logging in to the FTP server. If /U is omitted 
or if userNameStr is "", the login is done as an anonymous user. Use /U if you have an 
account on the FTP server.
/V=diagnosticMode
/W=passwordStr
Specifies the password to be used when logging in to the FTP server. Use /W if you 
have an account on the FTP server.
If /W is omitted, the login is done using a default password that will work with most 
anonymous FTP servers.
See Safe Handling of Passwords on page IV-270 for information on handling 
sensitive passwords.
/Z
Errors are not fatal. Will not abort procedure execution if an error occurs.
Your procedure can inspect the V_flag variable to see if the transfer succeeded. V_flag 
will be zero if it succeeded, -1 if the specified directory already exists, or another 
nonzero value if an error occurred.
Determines what kind of diagnostic messages FTPCreateDirectory will display in 
the history area. diagnosticMode is a bitwise parameter, with the bits defined as 
follows:
The default value for diagnosticMode is 3 (show basic and error diagnostics). If you 
are having difficulties, you can try using 7 to show the commands sent to the server 
and the server's response.
See FTP Troubleshooting on page IV-275 for other troubleshooting tips.
Bit 0:
Show basic diagnostics. Currently this just displays the URL in the 
history.
Bit 1:
Show errors. This displays additional information when errors occur.
Bit 2:
Show status. This displays commands sent to the server and the server's 
response.
