# Uploading a Directory

Chapter IV-10 — Advanced Topics
IV-274
If the local path that you specify ends with a colon or backslash, FTPDownload presents a dialog asking you 
to specify the local directory because it is looking for the name of the directory to be created on the local 
hard disk.
FTPDownload presents a dialog asking you to specify the local directory in the following cases:
1.
You use the /I (interactive) flag.
2.
The parent directory specified by the local path does not exist.
3.
The specified directory (DemoFTPDownloadFolder in the example above) exists and you have not used 
the /O (overwrite) flag.
4.
FTPDownload gets an error when it tries to create the specified directory. This could happen, for exam-
ple, if you don’t have write privileges for the parent directory.
Uploading a File
The following function uploads a file to an FTP server:
Function DemoFTPUploadFile()
String url = "ftp://ftp.wavemetrics.com/pub"
String localFolder = SpecialDirPath("Desktop",0,0,0)
String localPath = localFolder + "DemoFTPUploadFile.txt"
FTPUpload/U="username"/W="password" url, localPath
End
To successfully execute this, you need a real user name and a real password.
Note:
The /O flag has no effect on the FTPUpload operation when uploading a file. FTPUpload always 
overwrites an existing server file, whether /O is used or not.
Warning: If you overwrite a server file, all previous contents of the file are obliterated.
To overwrite an existing file on the server, you must have permission to delete files on that server. The 
server administrator determines what permission a particular user has.
FTPUpload presents a dialog asking you to specify the local file in the following cases:
1.
You use the /I (interactive) flag.
2.
The local parent directory or the local file does not exist.
Uploading a Directory
The following function uploads a directory to an FTP server:
Function DemoFTPUploadDirectory()
String url = "ftp://ftp.wavemetrics.com/pub"
String localFolder = SpecialDirPath("Desktop",0,0,0)
String localPath = localFolder + "DemoFTPUploadDirectory"
FTPUpload/D/U="username"/W="password" url, localPath
End
To successfully execute this, you need a real user name and a real password. Also, the server would have 
to allow uploading directories.
Note:
FTPUpload always overwrites an existing server directory, whether /O is used or not.
Warning: If you omit /O or specify /O or /O=1, all previous contents of the directory are obliterated.
If you specify /O=2, FTPUpload performs a merge of the directory contents. This means that files 
and directories in the source overwrite files and directories on the server that have the same 
name, but files and directories on the server whose names do not conflict with those in the source 
directory are not modified.
To overwrite an existing directory on the server, you must have permission to delete directories on that 
server. The server administrator determines what permission a particular user has.
