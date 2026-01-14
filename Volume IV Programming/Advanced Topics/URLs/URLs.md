# URLs

Chapter IV-10 — Advanced Topics
IV-267
/START=x
Controls logging of diagnostic information for use in troubleshooting slow startup or 
crashes during startup. Allowed values for x are:
/START was added in Igor Pro 9.00.
/UNATTENDED
Suppresses certain interactions that are inconvenient for unattended operations. An 
example is the About Autosave dialog that appears when Igor is launched until the 
user clicks “Do not show this message again”.
/
/UNATTENDED was added in Igor Pro 9.00.
X
Executes the commands in the parameter. Only one parameter is allowed with /X. Use 
semicolons to separate Igor commands within the parameter.
Details
If an existing instance of Igor is running, the command is sent to the existing instance if you omit the /I flag 
and you include /X, /SN, or a path to a file. Otherwise, a new instance of Igor is launched.
Registering a License
You can register an Igor license using the /SN, /KEY, and /NAME flags. All of these flags must be present 
to successfully register a license. The optional /ORG parameter defaults to "".
These batch file commands register Igor Pro with the given serial number and license activation key:
<IGOR> /SN=1234567 /KEY="ABCD-EFGH-IJKL-MNOP-QRST-UVWX-Y" /NAME="Jack" /ORG="Acme Scientific" /QUIT
Network Communication
The following sections contain material related to the network communication and Internet-related capa-
bilities of Igor Pro:
URLs on page IV-267
Safe Handling of Passwords on page IV-270
Network Timeouts and Aborts on page IV-270
Network Connections From Multiple Threads on page IV-271
File Transfer Protocol (FTP) on page IV-272
Hypertext Transfer Protocol (HTTP) on page IV-276
URLs
URLs, or Uniform Resource Locators, are compact strings that represent a resource available via the Inter-
net. The description of the URL standard is described in RFC1738 (http://www.rfc-edi-
tor.org/rfc/rfc1738.txt) and updated in RFC3986 (http://www.rfc-editor.org/rfc/rfc3986.txt).
Each URL is composed of several different parts, most of which are optional:
<scheme>://<username>:<password>@<host>:<port>/<path>?<query>
Some examples of valid URLs are:
http://www.example.com
http://www.example.com/afolder?key1=45&key2=66
http://myusername:Passw0rD@www.example.com:8010/index.html
ftp://ftp.wavemetrics.com
0:
Regular startup.
1:
Write diagnostic information to "Igor Debug Log.txt" in the Diagnostics 
folder of the Igor Pro preferences folder.
2:
Write diagnostic information to an Igorlogging window.
