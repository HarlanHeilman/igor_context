# FTP Troubleshooting

Chapter IV-10 — Advanced Topics
IV-275
If the local path that you specify ends with a colon or backslash, FTPUpload presents a dialog asking you 
to specify the local directory because it is looking for the name of the directory to be uploaded.
FTPUpload presents a dialog asking you to specify the local directory in the following cases:
1.
You use the /I (interactive) flag.
2.
The specified directory or any of its parents do not exist.
If you don’t have permission to remove and to create directories on the server, FTPUpload will fail and 
return an error.
Creating a Directory
The FTPCreateDirectory operation creates a new directory on an FTP server.
If the directory already exists on the server, the operation does nothing. This is not treated as an error, 
though the V_Flag output variable is set to -1 to indicate that the directory already existed.
If you don't have permission to create directories on the server, FTPCreateDirectory fails and returns an 
error.
Deleting a Directory
The FTPDelete operation with the /D flag deletes a directory on an FTP server.
If you don't have permission to delete directories on the server, or if the specified directory does not exist 
on the server, FTPDelete fails and returns an error.
FTP Transfer Types
The FTP protocol supports two types of transfers: image and ASCII. Image transfer is appropriate for binary 
files. ASCII transfer is appropriate for text files.
In an image transfer, also called a binary transfer, the data on the receiving end will be a replica of the data 
on the sending end. In an ASCII transfer, the receiving FTP agent changes line terminators to match the local 
convention. On Macintosh and Unix, the conventional line terminator is linefeed (LF, ASCII code 0x0A). On 
Windows, it is carriage-return plus linefeed (CR+LF, ASCII code 0x0D + ASCII code 0x0A).
If you transfer a text file using an image transfer, the file may not use the local conventional line terminator, 
but the data remains intact. Igor Pro can display text files that use any of the three conventional line termi-
nators, but some other programs, especially older programs, may display the text incorrectly.
On the other hand, if you transfer a binary file, such as an Igor experiment file, using an ASCII transfer, the 
file will almost certainly be corrupted. The receiving FTP agent will convert any byte that happens to have 
the value 0x0D to 0x0A or vice versa. If the local convention calls for CRLF, then a single byte 0x0D will be 
changed to two bytes, 0x0D0A. In either case, the file will become unusable.
FTP Troubleshooting
FTP involves a lot of hardware and software on both ends and a network in between. This provides ample 
opportunity for errors.
Here are some tips if you experience errors using the FTP operations.
1.
Use an FTP client or web browser to connect to the FTP site. This confirms that your network is operat-
ing, the FTP server is operating, and that you are using the correct URL.
2.
Use an FTP client or web browser to verify that the user name and password that you are using is correct 
or that the server allows anonymous FTP access.
Many web browser accept URLs of the form:
ftp://username:password@ftp.example.com
However the password is not transferred securely.
