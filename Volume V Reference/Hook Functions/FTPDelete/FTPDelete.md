# FTPDelete

FTPDelete
V-267
FTPDelete
FTPDelete [flags] urlStr
The FTPDelete operation deletes a file or a directory from an FTP server on the Internet.
Warning:
If you delete a directory on an FTP server, all contents of that directory and any subdirectories 
are also deleted.
For background information on Igor's FTP capabilities and other important details, see File Transfer 
Protocol (FTP) on page IV-272.
FTPDelete sets V_flag to zero if the operation succeeds and to nonzero if it fails. This, in conjunction with 
the /Z flag, can be used to allow procedures to continue to execute if an FTP error occurs.
Parameters
urlStr specifies the file or directory to delete. It consists of a naming scheme (always "ftp://"), a computer 
name (e.g., "ftp.wavemetrics.com" or "38.170.234.2"), and a path (e.g., "/test/TestFile1.txt"). For example: 
"ftp://ftp.wavemetrics.com/test/TestFile1.txt"
urlStr must always end with a file name if you are deleting a file or with a directory name if you are deleting 
a directory. In the case of a directory, urlStr must not end with a slash.
To indicate that urlStr contains an absolute path, insert an extra '/' character between the computer name 
and the path. For example:
ftp://ftp.wavemetrics.com//pub/test
If you do not specify that the path in urlStr is absolute, it is interpreted as relative to the FTP user's base 
directory. Since pub is the base directory for an anonymous user at wavemetrics.com, these URLs reference 
the same directory for an anonymous user:
ftp://ftp.wavemetrics.com//pub/test
ftp://ftp.wavemetrics.com/test
Special characters such as punctuation that are used in urlStr may be incorrectly interpreted by the 
operation. If you get unexpected results and urlStr contains such characters, you can try percent-encoding 
the special characters. See Percent Encoding on page IV-268 for additional information
Flags
/D
Deletes a complete directory and all its contents. Omit /D if you are deleting a file.
/N=portNumber
Specifies the server's TCP/IP port number to use (default is 21). In almost all cases, the 
default will be correct so you won't need to use the /N flag.
/U=userNameStr
Specifies the user name to be used when logging in to the FTP server. If /U is omitted 
or if userNameStr is "", the login is done as an anonymous user. Use /U if you have 
an account on the FTP server.
/V=diagnosticMode
Determines what kind of diagnostic messages FTPDelete will display in the history 
area. diagnosticMode is a bitwise parameter, with the bits defined as follows:
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
