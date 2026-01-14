# Percent Encoding

Chapter IV-10 — Advanced Topics
IV-268
file:///C:\\Data\\Trial1\\control.ibw (on Windows only)
file:///Users/bob/Data/Trial1/control.ibw (on Macintosh only)
For most operations and functions that take a urlStr parameter, only the scheme and host parts of the URL 
are required. See the Supported Network Schemes section for information on which schemes are sup-
ported by which operations and functions, and which port is used by default if it is not provided as part of 
the URL.
Usernames and Passwords
You can provide a username and password as part of the URL. However authentication credentials may 
not be supported by all schemes (such as file://). Some operations allow you to provide a username and 
password by using a flag, such as the /U and /W flags with FTPDownload or the /AUTH flag with URLRe-
quest.
If a URL contains a username and password in the URL and the authentication flags are also used, the 
values specified in the flags override values provided in the URL.
If you do not provide a username and password as part of the URL, and you do not use the authentication 
flags, then no authentication is attempted. An exception to this rule is that the FTP operations will login to 
the FTP server using "anonymous" as the username and a generic email address as the password.
If either the username or password contains special or reserved characters, those characters must be 
percent-encoded.
Supported Network Schemes
Different operations and functions support different schemes:
* Includes FTPUpload, FTPDownload, FTPDelete, and FTPCreateDirectory.
Percent Encoding
Percent encoding is a way to encode characters in URLs that would otherwise have a special meaning or 
could be misinterpreted by servers. For example, a space character in a URL is encoded as "%20" using a 
percent character followed by the hex code for a space in the ASCII character set.
Most URLs contain only the letters A-Z and a-z, the digits 0-9, and a few other characters such as the under-
score (_), hyphen (-), period (.), and tilde (~).
A URL may also contain "reserved characters" that may have special meaning depending on the way that 
they are used. Every URL contains the reserved characters ":" and "/" and may also contain one or more of 
the following reserved characters: !*'();@&=+$,?#[].
All operations and functions provided by Igor Pro that accept a URL string parameter expect that the URL 
has already been percent-encoded as necessary.
In most cases you don't need to worry about percent encoding because most URLs don't use reserved char-
acters except for their special meaning. If you need to use a reserved character in a way that differs from the 
character's special meaning, you must percent-encode the character. You can use the URLEncode function 
for this purpose.
Operation
Supported Schemes
Default Port
FetchURL and URLRequest
http
https
ftp
file
80
443
21
Not applicable
FTP operations*
ftp
21

Chapter IV-10 — Advanced Topics
IV-269
It is important that you not pass your entire URL to URLEncode to be encoded because that URL will not 
be understood by a server. URLEncode percent-encodes all reserved characters in the string you pass to it, 
because it cannot distinguish between reserved characters used for their special meaning and reserved 
characters used outside of their special meaning. Instead, you must pass each piece of the URL through 
URLEncode so that the final URL uses the correct syntax.
As an example, we'll use URLEncode to properly encode a URL that contains the following parts:
Without any percent-encoding, the URL is:
http://A. MacGyver:yj@!2M@www.example.com/tape/duct?discount=10%&color=red
If this URL were passed to FetchURL, the result would be an error because the URL contains several 
reserved characters that are not intended to be used in their standard way. For example, the "@" character 
indicates the separation between the username:password information and the start of the host name, but in 
this case the password itself also contains the "@" character. In addition, the "%" character is typically used 
to indicate that the next two characters represent a percent-encoded character, but in this example it is also 
part of the query. Finally, the username contains a space character. The space character is not technically a 
reserved character, but should be percent-encoded to ensure that it is handled correctly.
The following table shows the values of the parts of the URL that need to be percent-encoded by passing 
them through the URLEncode function:
The properly percent-encoded URL is:
http://A%2E%20MacGyver:yj%40%212M@www.example.com/tape/duct?discount=10%25&color=red
For keyword-value pairs that make up the query part, each keyword and value must be percent-encoded 
separately because the "=" character that separates the key from the value and the "&" character that sepa-
rates the pairs in the list must not be percent-encoded.
For more information on percent-encoding and reserved characters, see http://en.wikipedia.org/wiki/Per-
cent-encoding.
Part Name
Example
Scheme
http
Username
A. MacGyver
Password
yj@!2M
Host
www.example.com
Path
/tape/duct
Query
discount=10%&color=red
Part Name
Encoded Value
Username
A%2E%20MacGyver
Password
yj%40%212M
Host
www.example.com
Path
/tape/duct
Query
discount=10%25&color=red
