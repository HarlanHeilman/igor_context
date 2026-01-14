# Making a Query Via HTTP

Chapter IV-10 — Advanced Topics
IV-277
Function DownloadWebFileExample()
String url = "http://www.wavemetrics.net/IgorManual.zip"
// Based on the URL, determine what the destination
// file name should be. This will be the default in the
// Save As... dialog.
String urlStrParam = RemoveEnding(url, "/")
Variable parts = ItemsInList(urlStrParam, "/")
String destFileNameStr = StringFromList(parts - 1, urlStrParam, "/")
if (strlen(destFileNameStr) < 1)
Print "Error: Could not determine the name of the destination file."
return 0
endif
Variable refNum
Open/D/M="Save File As..."/T="????" refNum as destFileNameStr
String fullFilePath = S_fileName
if (strlen(fullFilePath) > 0) // No error and user didn't cancel in dialog.
// Open the selected file so that it can later be written to.
Open/Z/T="????" refNum as fullFilePath
if (V_flag != 0)
Print "There was an error opening the local destination file."
else
String response = FetchURL(url)
Variable error = GetRTError(1)
if (error == 0 && numtype(strlen(response)) == 0)
FBinWrite refNum, response
Close refNum
Print "The file was successfully downloaded as " + fullFilePath
else
Close refNum
DeleteFile/Z fullFilePath
// Clean up the empty file.
Print "There was an error downloading the file."
endif
endif
endif
End
Making a Query Via HTTP
Another use for HTTP requests is to get the server's response to a query. Many simple web forms use the 
HTTP GET method, which both FetchURL and URLRequest support. For example, you can simulate the 
submission of the basic Google search form using the following code.
Function WebQueryExample()
String keywords
String baseURL = "http://www.gutenberg.org/ebooks/search/"
// Prompt the user to enter search keywords.
Prompt keywords, "Enter search term"
DoPrompt "Search Gutenberg.org", keywords
if (V_flag == 1)
return -1
// User clicked cancel button
endif
// Pass the search terms through URLEncode to
// properly percent-encode them.
keywords = URLEncode(keywords)
// Build the full URL.
