# Downloading a File Via HTTP

Chapter IV-10 — Advanced Topics
IV-276
3.
Use an FTP client or web browser to verify that the directory structure of the FTP server is what you 
think it is.
4.
Using an FTP client or web browser, do the operation that you are attempting to do with Igor. This ver-
ifies that you have sufficient permissions on the server.
5.
Use /V=7 to tell the Igor operation to display status information in the history area.
6.
Try the simplest transfer you can. For example, try to download a single file that you know exists on the 
server.
7.
If you have access to the FTP server, examine the FTP server log for clues.
Hypertext Transfer Protocol (HTTP)
The FetchURL function supports simple URL requests over the Internet from web or FTP servers and to 
local files. For example, you can use FetchURL to get the source code of a web page in text form, and then 
process the text to extract specific information from the response. 
The URLRequest operation supports both simple URL requests and more complicated requests such as 
using the http POST, PUT, and DELETE methods. It also provides experimental support for using a proxy 
server.
HTTP Limitations
At this time, FetchURL and BrowseURL routines work with the HTTP protocol.
Currently not supported are features such as using network proxy servers, using the HTTP POST method 
to submit forms and upload files to a web server, and making secure network connections using the Secure 
Socket Layer (SSL) protocol.
Downloading a Web Page Via HTTP
This example uses FetchURL to download the contents of the WaveMetrics home page into a string, and 
then counts the number of times that the string "Igor" occurs in the text of the page.
Function DownloadWebPageExample()
String webPageText = FetchURL("http://www.wavemetrics.com")
if (numtype(strlen(webPageText)) == 2)
Print "There was an error while downloading the web page."
endif
Variable count, pos
do
pos = strsearch(webPageText, "Igor", pos, 2)
if (pos == -1)
break
// No more occurrences of "Igor"
else
pos += 1
count += 1
endif
while (1)
Printf "The text \"Igor\" was found %d times on the web page.\r", count
End
Downloading a File Via HTTP
This example uses FetchURL to download a file from a web server. Because FetchURL does not support 
storing the downloaded data into a file directly, we store the data in memory and then use Igor to write that 
data to a file on disk.
Though the example uses a URL that begins with http://, FetchURL also supports https://, ftp:// and file://. 
You could use the code below with a different URL to download a file from an FTP server or even to access 
a local on-disk file.
