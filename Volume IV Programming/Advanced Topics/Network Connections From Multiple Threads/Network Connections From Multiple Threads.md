# Network Connections From Multiple Threads

Chapter IV-10 — Advanced Topics
IV-271
Network Connections From Multiple Threads
All network-related operations and functions are thread-safe, which means that they can be called from 
multiple preemptive threads at the same time. This capability can be useful when:
•
You want to retrieve information from several different URLs as quickly as possible.
•
You want to do a long download or other operation in the background to avoid tieing Igor up.
The following example illustrates the first of these cases. It uses FetchURL to retrieve a list of the most fre-
quently downloaded books from the Project Gutenberg web site. It then uses FetchURL to download the 
entire text of the top four books and prints the number of bytes in each.
ThreadSafe Function GetThePage(url)
String url
String response = FetchURL(url)
return strlen(response)
End
Function ListGutenbergTopBooks()
String topBooksURL = "http://www.gutenberg.org/browse/scores/top"
String baseURL = "http://www.gutenberg.org/files/"
// Get the contents of the page.
String response = FetchURL(topBooksURL)
Variable error = GetRTError(1)
if (error || numtype(strlen(response)) != 0)
Print "Error getting the list of most popular books."
return 0
endif
String topBooksHTML = response
// Remove all line endings.
topBooksHTML = ReplaceString("\n", topBooksHTML, "")
topBooksHTML = ReplaceString("\r", topBooksHTML, "")
// Parse the page to get the section of the page
// with the list of the most popular books from yesterday.
// This could break if the format of the web page changes.
String regExp = "(?i)<h2 id=\"books-last1\">.*?<ol>(.*?)</ol>"
String topYesterdayHTML = ""
SplitString/E=regExp topBooksHTML, topYesterdayHTML
if (V_flag != 1)
Print "Error parsing the top 100 books section."
return 0
endif 
// Replace the line endings.
topYesterdayHTML = ReplaceString("</li><li>", topYesterdayHTML, "\r")
// Create a wave to store text info about the top four books.
Variable numBooksToUse = 4
Make/O/T/N=(numBooksToUse, 2) topBooksInfo
Make/O/N=(numBooksToUse) byteCounts
Variable n
String bookNumStr
Variable bookNum
String titleAuthor
