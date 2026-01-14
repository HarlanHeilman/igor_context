# Downloading a Directory

Chapter IV-10 — Advanced Topics
IV-273
FTP Limitations
All FTP operations run “synchronously”. This means that, if the operation executes in the main thread, Igor 
can not do anything else. However, it is possible to perform these operations using an Igor preemptive 
thread so that they execute in the background and you can continue to use Igor for other purposes. For more 
information, see Network Connections From Multiple Threads on page IV-271.
Igor does not currently provide any way for the user to browse the remote server from within Igor itself.
Igor does not provide any secure way to store passwords. Consequently, you should not use Igor for FTP 
in situations where tight security is required. See Safe Handling of Passwords on page IV-270 for an 
example of how to securely prompt the user for a password.
Igor does not provide any support for using proxy servers. Proxy servers are security devices that stand between 
the user and the Internet and permit some traffic while prohibiting other traffic. If your site uses a proxy server, 
FTP operations may fail. Your network administrator may be able to provide a solution.
Igor does not include operations for listing a server directory or changing its current directory.
Downloading a File
The following function transfers a file from an FTP server to the local hard disk:
Function DemoFTPDownload()
String url = "ftp://ftp.wavemetrics.net/welcome.msg"
String localFolder = SpecialDirPath("Desktop",0,0,0)
String localPath = localFolder + "DemoFTPDownloadFile.txt"
FTPDownload/U="anonymous"/W="password" url, localPath
End
The output directory must already exist on the local hard disk. The target file may or may not exist on the local 
hard disk. If it does not exist, the FTPDownload command creates it. If it does exist, FTPDownload asks if you 
want to overwrite it. To overwrite it without being asked, use the /O flag.
Warning: If you elect to overwrite it, all previous contents of the local target file are obliterated.
FTPDownload presents a dialog asking you to specify the local file name and location in the following cases:
1.
You use the /I (interactive) flag.
2.
The parent directory specified by the local path does not exist.
3.
The specified local file exists and you do not use the /O (overwrite) flag.
Downloading a Directory
The following function transfers a directory from an FTP server to the local hard disk:
Function DemoFTPDownloadDirectory()
String url = "ftp://ftp.wavemetrics.net/Utilities"
String localFolder = SpecialDirPath("Desktop",0,0,0)
String localPath = localFolder + "DemoFTPDownloadDirectory"
FTPDownload/D/U="anonymous"/W="password" url, localPath
End
The /D flag specifies that you are transferring a directory.
The output directory may or may not already exist on the local hard disk. If it does not exist, the FTPDownload 
command creates it. If it does exist, FTPDownload asks if you want to overwrite it. To overwrite it without 
being asked, use the /O flag.
Warning: If you elect to overwrite it, all previous contents of the local directory are obliterated.
