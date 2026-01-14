# URLRequest

UpperStr
V-1053
Examples
// Unzip a file using full paths
String zipFileString = "C:Users:Fred:Documents:Test.zip"
String outputPathString = "C:Users:Fred:Documents:Extracted"
UnzipFile zipFileString, outputPathString
// Unzip a file using symbolic paths
String zipFileName = "Test.zip"
String outputFolderName = ""
// Unzip to folder specified by /POUT
UnzipFile/PIN=home/POUT=home zipFileName, outputFolderName
UpperStr 
UpperStr(str)
The UpperStr function returns a string expression in which all lower-case ASCII characters in str are 
converted to upper-case.
See Also
The LowerStr function.
URLDecode
URLDecode(inputStr)
The URLDecode function returns a percent-decoded copy of the percent-encoded string inputStr. It is 
unlikely that you will need to use this function; it is provided for completeness.
For an explanation of percent-encoding, see Percent Encoding on page IV-268.
Example
String theURL = "http://google.com?key1=35%25%20larger"
theURL = URLDecode(theURL)
Print theURL
 http://google.com?key1=35% larger
See Also
URLEncode, URLRequest, URLs on page IV-267.
URLEncode
URLEncode(inputStr)
The URLEncode function returns a percent-encoded copy of inputStr. 
Percent-encoding is useful when encoding the query part of a URL or when the URL contains special 
characters that might otherwise be misinterpreted by a web server. For an explanation of percent-encoding, 
see Percent Encoding on page IV-268.
Example
String baseURL = "http://google.com"
String key1 = "key1"
String value1 = URLEncode("35% larger")
String theURL = ""
sprintf theURL, "%s?%s=%s", baseURL, key1, value1
Print theURL
 http://google.com?key1=35%25%20larger
See Also
URLDecode, URLRequest, URLs on page IV-267.
URLRequest
URLRequest [ flags ] url=urlStr [method=methodName, headers=headersStr] 
The URLRequest operation connects to a URL using the specified method and optionally stores the 
response from the server. urlStr can point to a remote server or to a local file. The server's response is stored 
in the S_serverResponse output variable or in a file if you use the /FILE flag.
The URLRequest operation was added in Igor Pro 7.00.

URLRequest
V-1054
Keywords
The url=urlStr keyword is require. All others are optional.
Flags
url=urlStr
A string containing the URL to retrieve. See URLs on page IV-267 for details.
method=methodName
Specifies which method to use for the request. The get method is used by default.
Because methodName is a name, not a string, you must not enclose it in quotes.
Before using the post method, you should read The The HTTP POST Method on 
page V-1058 so that you know how to use the optional headers parameter.
If you use the head method, URLRequest sets the S_serverResponse output 
variable to "" because only the headers are retrieved. As with other methods, the 
headers are stored in the S_headers output variable.
headers=headersStr
Specifies a string containing additional or replacement headers to use with the 
request. This parameter is ignored unless the scheme is http or https.
The headers parameter is provided primarily for use with the post method when 
making HTTP requests and is ignored for schemes other than http/https. The 
header consists of a colon-separated key:value pair (though see the next 
paragraph for an exception). Pairs must be separated by a carriage return (\r) 
character.
Certain standard headers (such as Content-Type and User-Agent) may 
automatically be set when making the request. You can override those default 
values by using this keyword and setting a different value. If you add a header 
with no content, as in "Accept:" (there is no data on the right side of the colon), the 
internally used header is disabled. To actually add a header with no content, use 
the form "MyHeader;" (note the trailing semicolon).
Any headers specified with this keyword are sent only to the http server, not to 
the proxy server, if one is in use.
See The HTTP POST Method on page V-1058 for a detailed explanation and 
examples.
/AUTH={username, password }
Uses the specified username and password string parameters for authentication. 
Values provided here override any username and/or password provided as 
part of the URL. To specify a username but not a password, pass "" for the 
password parameter.
Note: See Safe Handling of Passwords on page IV-270 for more information on 
how to use URLRequest to prevent authentication information, such as 
passwords, from being accidentally revealed.
This table shows the valid methods for each supported scheme. Not all 
servers support all of the listed methods.
Scheme
Supported Methods
http, https
get, post, put, head, delete
ftp
get, put
file
get, put

URLRequest
V-1055
/DFIL=dataFileNameStr
Specifies a file name to use as a source of data. Typically this flag is used only 
with the put or post methods, but it is accepted with all methods. Unless 
dataFileNameStr is a full path, the /P flag must also be used. When using the post 
or put methods, one and only one of the /DFIL or /DSTR flags must be used.
When you use /DFIL and the method is anything other than put, the "Content-
Type: application/x-www-form-urlencoded" header is automatically added. If 
necessary, you can override this behavior using the headers keyword. See The 
HTTP POST Method on page V-1058 for more information.
/DSTR=dataStr
Specifies the string to use as a source of data. Typically you use this flag only 
with the put or post methods, but it is accepted with all methods. When using 
the post or put methods, one and only one of the /DFIL or /DSTR flags must be 
used.
When /DSTR is used and the method is anything other than put, the "Content-
Type: application/x-www-form-urlencoded" header is automatically added. If 
necessary, you can override this behavior using the headers keyword. See The 
HTTP POST Method on page V-1058 for more information.
/FILE=destFileNameStr
If present, URLRequest saves the server's response in a file instead of in the 
S_serverResponse output variable.
URLRequest ignores /FILE if you include the /IGN flag and the ignoreResponse 
parameter is not 0.
destFileNameStr can be a full path to the file, in which case /P=pathName is not 
needed, a partial path relative to the folder associated with pathName, or the 
name of a file in the folder associated with pathName. If the file already exists, 
URLRequest returns an error unless you include the /O flag.
If you include /O and the file already exists, the existing file is overwritten. This 
happens even in the event of an empty response or transfer error.
You should consider using the /FILE flag when you are expecting the server to 
return a large amount of data, such as when downloading a file.
/IGN[=ignoreResponse]
Ignore and do not store the server's response to the request. /IGN alone has the 
same effect as /IGN=1.
If ignore is turned on, URLRequest sets the S_serverResponse output variable 
to "", regardless of whether the server responded to the request or not. If you 
include the /FILE flag, URLRequest does not create the output file and sets 
S_fileName is set to "".
/NRED=maxNumRedirects
Specifies the maximum number of redirects that are allowed. A redirect means 
that when a certain URL is requested, the server responds telling the client to 
try a different URL. Most web browsers automatically follow server redirects, 
up to a certain limit. For security purposes, it is sometimes useful to prevent 
redirects from being followed at all.
maxNumRedirects is a number between -1 and 1000. To allow infinite 
redirection, set maxNumRedirects to -1. If you omit the /NRED flag, a moderate 
value (currently 20, but subject to change in the future) is used.
This flag is useful only when your goal is to establish a connection with a 
server and the server's response is not important. All error message codes 
and strings are still set when ignore is on.
/IGN=0:
Same as no /IGN.
/IGN=1:
Ignore server response completely. S_headers is set to "".
/IGN=2:
Ignore server response but capture the headers of the 
response. S_serverResponse is set to "" but S_headers will 
contain the headers.

URLRequest
V-1056
/O
Specifies that the file is to be overwritten when you use the /FILE flag and the 
output file already exists. If you omit /O and the file exists, URLRequest returns 
an error.
/P=pathName
Specifies the folder to use for the output file, specified by the /FILE flag, and/or 
the source data file, specified by the /DFIL flag. pathName is the name of an 
existing Igor symbolic path.
The /P flag affects both the /FILE and /DFIL flags. If you use both flags and want 
to use different directories, you must provide a full path for one or both of the 
/FILE and /DFIL flag parameters.
If the /P flag is used without one or both of the /FILE and /DFIL flags, it is 
ignored.
/PROX[={proxyURLStr, proxyUserNameStr, proxyPassStr, proxyOptions}]
NOTE: This flag is experimental and has not been extensively tested. The 
behavior of this flag may change in the future, or it may be eliminated 
entirely.
Designates a proxy server to be used when making the connection. 
proxyURLStr is either the host name or IP address of the proxy server, or a full 
URL. If a full URL is used, the scheme specifies which kind of proxy is used. 
Typically the scheme for a proxy server should be either http or socks5. If no 
scheme is provided, http is assumed. See URLs on page IV-267 for more 
information.
If the proxy server does not require authentication, or if the username and 
password for the proxy server are specified in proxyURLStr, the optional 
proxyUserNameStr and proxyPassStr parameters do not need to be provided. 
The following two examples do the same thing:
/PROX={"http://proxy.example.com:800"}
/PROX={"http://proxy.example.com:800", "", ""}
As with other URLs, you can also provide the username and password as part 
of the URL itself. The following two examples do the same thing:
/PROX={"http://proxy.example.com:800", "user", "pass"}
/PROX={"http://user:pass@proxy.example.com:800"}
proxyOptions is optional and for future use. It is currently ignored. If provided, 
you must set it to 0.
If you use the /PROX flag without any parameters, Igor attempts to get proxy 
information from the operating system's proxy configuration information. If 
Igor cannot get any proxy server information from the system, no proxy server 
is used.
See Safe Handling of Passwords on page IV-270 for more information on how 
to use URLRequest to prevent authentication information, such as passwords, 
from being accidentally revealed.
/TIME=timeoutSeconds
Forces the operation to time out after timeoutSeconds seconds if it has not 
completed by that time. If this flag is not provided, URLRequest runs until the 
server has finished sending and receiving data. For simple requests a value of 
a few seconds is appropriate. However, because uploading and/or 
downloading large amounts of data may take a long time, if timeoutSeconds is 
too small the request might be prematurely terminated. If you omit the /TIME 
flag, or if timeoutSeconds = 0, there is no timeout.
Regardless of whether or not you include /TIME, you can abort the operation 
by pressing the User Abort Key Combinations.

URLRequest
V-1057
Output Variables
URLRequest sets the following output variables:
Basic Examples
// Retrieve the contents of the WaveMetrics home page.
// Output is stored in S_serverResponse
URLRequest url="http://www.wavemetrics.com"
// Download the Windows Igor6 installer and save it as a file on the desktop.
/V=diagnosticMode
/Z[=z]
V_flag
V_flag is zero if the operation succeeds without an error or a non-zero Igor error 
code if it fails.
Note that "succeeds without an error" does not necessarily mean that the 
operation performed as you intended. For example, if you attempt to connect to 
a server that requires a username and password for authentication but you do not 
provide this information, V_flag is likely to be 0, indicating no error. You need to 
inspect the value of V_responseCode to ensure that it is what you expect.
V_responseCode
Contains the status code provided by the server.
V_responseCode is valid only if V_flag is 0, meaning that no error occured. If 
V_flag is nonzero, an error occured and V_responseCode will be 0.
Different schemes use different sets of status codes.
A list of http/https status codes and their definitions can be found at:
http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
A list of FTP status codes can be found at:
https://en.wikipedia.org/wiki/List_of_FTP_server_return_codes
S_serverResponse
Contains the server's response to the request.
S_serverResponse is set to "" if you use the /FILE flag or the /IGN=1 or /IGN=2 
flags.
We recommend that you use the /FILE flag when you expect the size of the server 
response to be large, such as when downloading a large file.
S_headers
Contains a list of all of the headers received as part of the response. Header names 
are separated from their value by a colon and pairs are separated by a carriage 
return followed by a line feed (\r\n). For schemes other than http and https, 
S_headers is set to "".
S_fileName
Contains the full Igor-style path to the output file if the /FILE flag was used. If 
there was an error saving to the specified file, or another kind of error, or if the 
/FILE flag was not used, S_fileName is set to "".
This flag is useful only when your goal is to establish a connection with a 
server and the server's response is not important. All error message codes 
Controls diagnostic messages printed in the history area of the command 
window.
/V=0:
Do not print any diagnostic messages. This is the default if you 
omit /V.
/V=1:
Prints an error message if a run time error occurs.
/V=2:
Prints full debugging information.
Suppress error generation. Use this if you want to handle errors yourself.
/Z alone has the same effect as /Z=1.
/Z=0:
Do not suppress errors. This is the default if /Z is omitted.
/Z=1:
Any errors generated by Igor do not stop execution. If there is 
an error the error code is stored in V_Flag.

URLRequest
V-1058
NewPath/O Desktop, SpecialDirPath("Desktop", 0, 0, 0)
String theURL = "http://www.wavemetrics.net/Downloads/Win/setupIgor6.exe"
URLRequest/FILE="setupIgor6.exe"/P=Desktop url=theURL
// Download a file to the desktop from an FTP server.
NewPath/O Desktop, SpecialDirPath("Desktop", 0, 0, 0)
String theURL = "ftp://ftp.wavemetrics.com/test/test.htm"
URLRequest/O/FILE="test.htm"/P=Desktop url=theURL
// Upload the same file to the FTP server.
theURL = "ftp://user:pass@ftp.wavemetrics.com/test.htm"
URLRequest/DFIL="test.htm"/P=Desktop method=put, url=theURL
Using the File Scheme
URLRequest supports the file scheme in URLs. You must provide the full path to the file as a native 
Windows-style or UNIX-style path, depending on which platform the code is running.
You must specify the schema as "file:///". Note that you must use three front slash characters (/) between the 
colon and the full file path (for most URLs you would only use two slashes).
URLRequest url="file:///C:\\Data\\Trial1\\control.ibw"
// Works on Windows only
URLRequest url="file:///Users/bob/Data/Trial1/control.ibw"
// Works on Macintosh only
URLRequest url="file:///C:\\Data\\Trial1\\control.ibw"
// Doesn't work
URLRequest url="file:///Users/bob/Data/Trial1/control.ibw"
// Doesn't work
The following example shows how to convert a full Igor file path to a native path suitable for use as a file 
URL:
String nativeFilePath
#ifdef WINDOWS
String igorFilePath = "C:Documents:myFile.txt"
nativeFilePath = ParseFilePath(5, igorFilePath, "*", 0, 0)
#endif
#ifdef MACINTOSH
String igorFilePath = "MacintoshHD:Documents:myFile.txt"
nativeFilePath = ParseFilePath(5, igorFilePath, "/", 0, 0)
// Remove the leading "/" from nativeFilePath. Otherwise,
// when we prepend "file:///" below, we'd end up with four
// slashes, which isn't allowed.
nativeFilePath = nativeFilePath[1,INF]
#endif
URLRequest url="file:///" + nativeFilePath
The HTTP POST Method
Like the HTTP GET method, the HTTP POST method can be used to transmit information to a web server. 
When using the GET method, all information must be contained within the URL itself. As an example, 
making a GET request to the URL <http://www.google.com/search?q=Igor+Pro+WaveMetrics> searches 
Google using the keywords "Igor", "Pro", and "WaveMetrics".
Unlike the GET method, the POST method allows the client to send information to the server that is not 
contained within the URL itself. This is necessary in many situations, such as when uploading a file or 
transfering a large amount of data. In addition, because the data contained in POST requests is typically not 
stored in the log files of web servers, it is more appropriate for sending data that is secure, such as login 
credentials and form submissions which might contain sensitive information.
When using the POST method, the client must encode its data using one of several methods and must tell 
the server what type of data is being sent and how it is encoded. The client does this by setting the Content-
Type header that is part of the request. The most commonly used content type is "application/x-www-form-
urlencoded". Unless you provide your own Content-Type header using the optional headers parameter, 
URLRequest will set this header for you. This is true regardless of which data source (/DSTR for string or 
/DFIL for file) you use for the POST.
Here is a simple example that uses the POST method with URL encoded data (the default Content-Type).
String theURL = "http://www.example.com/process.php"
String nameData = URLEncode("name") + "=" + URLEncode("Dan P. Ikes, Jr.")
String address = "650 E. Chicago Ave."
String addressData = URLEncode("address") + "=" + URLEncode(address)
String postData = nameData + "&" + addressData
URLRequest/DSTR=postData method=post, url=theURL
There are two things to note in this example.

URLRequest
V-1059
First, both the key name and value string are passed through URLEncode so that any special characters can 
be percent-encoded.
Second, keys and values are separated by an equal sign ("=") and key/value pairs are separated by an 
ampersand ("&"). These characters are not passed through URLEncode because doing so would cause them 
to lose their meaning as special characters.
For more information on using the application/x-www-form-urlencoded content type, see 
http://www.w3.org/TR/html401/interact/forms.html#h-17.13.4.1
It is also possible to transmit more complicated data using the POST method, such as simulating a form that 
contains regular text fields as well as a file upload field. To do so you must set the Content-Type header 
using the headers parameter. You must also build your post data using a multi-part header. Here is an 
example:
String theURL = "http://www.example.com/process.php"
String postData = ""
// Note: The boundary is arbitrary. It needs to be
// unique enough that it is not contained within any
// of the actual data being transmitted in the post.
String boundary = "AaBbCcDd0987"
// name
postData += "--" + boundary + "\r\n"// beginning of this part
postData += "Content-Disposition: form-data; name=\"name\"\r\n"
postData += "\r\n"
postData += "Dan P. Ikes, Jr.\r\n"
// address
postData += "--" + boundary + "\r\n"
postData += "Content-Disposition: form-data; name=\"address\"\r\n"
postData += "\r\n"
postData += "650 E. Chicago Ave.\r\n"
// file
// Open the file we plan to send and store the binary
// contents of the file in a string.
Variable refNum
Open/R/Z/P=Igor refNum as "ReadMe.ihf"
FStatus refNum
Variable fileSize = V_logEOF
String fileContents = ""
fileContents = PadString(fileContents, fileSize, 0)
FBinRead refNum, fileContents
Close refNum
postData += "--" + boundary + "\r\n"
postData += "Content-Disposition: form-data; name=\"file\"; filename=\"ReadMe.ihf\"\r\n"
postData += "Content-Type: application/octet-stream\r\n"
postData += "Content-Transfer-Encoding: binary\r\n"
postData += "\r\n"
postData += fileContents + "\r\n"
postData += "--" + boundary + "--\r\n"
// end of this part
String headers
headers = "Content-Type: multipart/form-data; boundary=" + boundary
URLRequest/DSTR=postData method=post, url=theURL, headers=headers 
For more information on using the multipart/form-data content type, see 
http://www.w3.org/TR/html401/interact/forms.html#h-17.13.4.2
Handling JSON Data
JSON (JavaScript Object Notation) is a lightweight data-interchange format that is commonly used when 
interacting with websites - see https://www.json.org/json-en.html. For full read and write JSON support in 
Igor Pro, we recommend using the JSON XOP, developed by byte physics. You can download it from 
https://docs.byte-physics.de/json-xop.
See Also 
URLEncode, URLDecode, Base64Encode, Base64Decode, FetchURL, BrowseURL
Network Communication on page IV-267, URLs on page IV-267
