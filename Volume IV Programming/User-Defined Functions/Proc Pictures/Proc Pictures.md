# Proc Pictures

Chapter IV-3 — User-Defined Functions
IV-56
If your procedure file uses non-ASCII characters then we recommend that you add a TextEncoding pragma 
as this will allow Igor to reliably interpret it regardless of the user's operating system, system locale and 
default text encoding setting.
If the procedure file is to be used in Igor7 and later only then you should use the UTF-8 text encoding, like 
this:
#pragma TextEncoding = "UTF-8"
This allows you to use any Unicode character in the file.
The following text encodings are not supported for procedure files:
UTF-16LE, UTF-16BE, UTF32-LE, UTF32-BE
If you attempt to use these in a procedure file Igor will report an error.
Igor automatically adds a TextEncoding pragma under some circumstances.
It adds a TextEncoding pragma if you set the text encoding of a procedure file by clicking the Text Encoding 
button at the bottom of the window or by choosing ProcedureText Encoding.
It adds a TextEncoding pragma if it displays the Choose Text Encoding dialog when you open a procedure 
file because it is unable to convert the text to UTF-8 without your help.
It is possible for the TextEncoding pragma to be in conflict with the text encoding used to open the file. For 
example, imagine that you open a file containing
#pragma TextEncoding = "Windows-1252"
and then you change "Windows-1252" to "UTF-8" by editing the file. You have now created a conflict where 
the text encoding used to open the file was one thing but the TextEncoding pragma is another. To resolve 
this conflict, Igor displays the Resolve Text Encoding Conflict dialog. In the dialog you can choose to make 
the file's text encoding match the TextEncoding pragma or to make the TextEncoding pragma match the 
file's text encoding. You can also cancel the dialog and manually edit the TextEncoding pragma.
For background information, see Text Encodings on page III-459.
The DefaultTab Pragma
The DefaultTab pragma allows you to set the width of a procedure file's default tabs to facilitate aligning 
comments in the file. It was added in Igor Pro 9.00 and is ignored by earlier versions of Igor. See The 
Default Tab Pragma For Procedure Files on page III-406 for details.
Unknown Pragmas
Igor ignores pragmas that it does not know about. This allows newer versions of Igor to use new pragmas 
while older versions ignore them. The downside of this change is that, if you misspell a pragma keyword, 
Igor will not warn you about it.
Proc Pictures
Proc pictures are binary PNG or JPEG images encoded as printable ASCII text in procedure files. They are 
intended for programmers who need to display pictures as part of the user interface for a procedure pack-
age. They can be used with the DrawPICT operation and with the picture keyword of the Button, Check-
Box, and CustomControl operations.
The syntax for defining and using a proc picture is illustrated in the following example:
// PNG: width= 56, height= 44
Picture MyGlobalPicture
ASCII85Begin
M,6r;%14!\!!!!.8Ou6I!!!!Y!!!!M#Qau+!5G;q_uKc;&TgHDFAm*iFE_/6AH5;7DfQssEc39jTBQ
