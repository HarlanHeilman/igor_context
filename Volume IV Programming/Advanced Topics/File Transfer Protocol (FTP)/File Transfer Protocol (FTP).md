# File Transfer Protocol (FTP)

Chapter IV-10 — Advanced Topics
IV-272
String thisLine
Variable pos
String bookURL = ""
regExp = "(?i)a href=\".*?(\d+)\">(.+?)</a>"
for (n=0; n<numBooksToUse; n+=1)
// For each book we're going to look at, get the
// partial URL and the title/author text.
thisLine = StringFromList(n, topYesterdayHTML, "\r")
SplitString/E=regExp thisLine, bookNumStr, titleAuthor
if (V_flag != 2)
Print "Error parsing the URL and title/author information."
return 0
endif
// Remove the (###) stuff at the end of titleAuthor if it's there.
pos = strsearch(titleAuthor, "(", 0)
if (pos > 0)
titleAuthor = titleAuthor[0, pos - 1]
endif
bookNum = str2num(bookNumStr)
// Store the information about the book in the text wave.
sprintf bookURL, "%s%d/%d.txt", baseURL, bookNum, bookNum
topBooksInfo[n][0] = bookURL
topBooksInfo[n][1] = titleAuthor
endfor
// Download each book (using multiple threads if possible)
// and count the number of bytes in each.
MultiThread byteCounts = GetThePage(topBooksInfo[p][0])
// Print the results.
Print "The top four books by download from yesterday are:"
for (n=0; n<numBooksToUse; n+=1)
Printf "%s (%d bytes)\r", topBooksInfo[n][1], byteCounts[n]
endfor
End
Here is an example of what the output was when this help file was written:
The top four books by download from yesterday are:
Ulysses by James Joyce (1573044 bytes)
Alice's Adventures in Wonderland by Lewis Carroll (167529 bytes)
Piper in the Woods by Philip K. Dick (62214 bytes)
Pride and Prejudice by Jane Austen (704160 bytes)
File Transfer Protocol (FTP)
The FTPDownload, FTPUpload, FTPDelete, and FTPCreateDirectory operations support simple transfers of 
files and directories over the Internet.
Since Igor’s SaveNotebook operation can generate HTML files from notebooks, it is possible to write an Igor 
procedure that downloads data, analyzes it, graphs it, and uploads an HTML file to a directory used by a 
Web server. You can then use the BrowseURL operation to verify that everything worked as expected. For 
a demo of some of these features, choose FileExample ExperimentsFeature DemosWeb Page Demo.
