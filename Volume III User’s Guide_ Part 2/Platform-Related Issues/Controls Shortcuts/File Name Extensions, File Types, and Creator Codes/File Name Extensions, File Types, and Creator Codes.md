# File Name Extensions, File Types, and Creator Codes

Chapter III-15 — Platform-Related Issues
III-448
Platform-Related Issues
Igor Pro runs on Macintosh and Windows. This chapter contains information that is platform-specific and 
also information for people who use Igor on both platforms.
Windows-Specific Issues
On Windows, the name of the Igor program file must be “Igor64.exe” for the 64-bit version of Igor or 
“Igor.exe” for the 32-bit version, exactly. If you change the name, Igor extensions will not work because they 
will be unable to find Igor.
Cross-Platform File Compatibility
Version 3.1 was the first version of Igor Pro that ran on Windows as well as Macintosh.
Crossing Platforms
When crossing from one platform to another, page setups are only partially translated. Igor tries to preserve 
the page orientation and margins.
When crossing platforms, Igor attempts to do font substitution where necessary. If Igor can not determine 
an appropriate font it displays the font substitution dialog where you can choose the font.
Platform-specific picture formats are displayed as gray boxes when you attempt to display them on the 
non-native platform. Windows Metafile, Enhanced Metafile, and Windows bitmap (BMP) pictures are sup-
ported on Windows only and appear as gray boxes on Macintosh.
The EPS, PNG, JPEG, TIFF, and SVG formats are platform-independent and are displayed on both plat-
forms.
Prior to Igor Pro 9.00, PDF pictures were supported on Macintosh only and appeared as gray boxes on Win-
dows. Now Igor can display PDF pictures on both platforms.
Transferring Files Using File Transfer Programs
Some transfer programs offer the option of translating file formats as they transfer the program from one 
computer to another. This translation usually consists of replacing each carriage return character with a car-
riage return/linefeed pair (Macintosh to Windows) or vice-versa (Windows to Macintosh). This is called a 
“text mode” transfer, as opposed to a “binary mode” transfer. This translation is appropriate for plain text 
files only. In Igor, plain text notebooks, procedure files, and Igor Text data files are plain text. All other files 
are not plain text and will be corrupted if you transfer in text mode. If you get flaky results after transferring 
a file, transfer it again making sure text mode is off.
If you have a problem opening a binary file after doing a transfer, compare the number of bytes in the file 
on both computers. If they are not the same, the transfer has corrupted the file.
File Name Extensions, File Types, and Creator Codes
This table shows the file name extension and corresponding Macintosh file type for Igor Pro files:
Extension
File Type
What’s in the File
.pxp
IGsU
Packed experiment file
.pxt
IGsS
Packed experiment template (stationery)
.uxp
IGSU
Unpacked experiment file
.uxt
IGSS
Unpacked experiment template (stationery)
.ifn
WMT0
Igor formatted notebook (last character is zero)
