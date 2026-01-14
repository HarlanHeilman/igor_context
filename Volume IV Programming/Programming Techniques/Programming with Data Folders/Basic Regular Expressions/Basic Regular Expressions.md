# Basic Regular Expressions

Chapter IV-7 — Programming Techniques
IV-177
Print dest
End
The output from Print is:
Tuesday;Wednesday;Thursday;
GrepString
The GrepString function determines if a particular pattern exists in the input string.
The subject is the input string.
The output is 1 if the input string contains the pattern or 0 if not.
GrepString Example
Function DemoGrepString()
String subject = "123.45"
String regExp = "[0-9]+"
// Match one or more digits
Print GrepString(subject,regExp)
// True if subject contains digit(s)
End
The output from Print is: 1
SplitString
The Demo operation identifies subpatterns in the input string.
The subject is the input string.
Output is stored in one or more string output variables.
SplitString Example
Function DemoSplitString()
String subject = "Thursday, May 7, 2009"
String regExp = "([[:alpha:]]+), ([[:alpha:]]+) ([[:digit:]]+), ([[:digit:]]+)"
String dayOfWeek, month, dayOfMonth, year
SplitString /E=(regExp) subject, dayOfWeek, month, dayOfMonth, year
Print dayOfWeek, month, dayOfMonth, year
End
The output from Print is:
Thursday May 7 2009
Basic Regular Expressions
Here is a Grep command that uses "Fred" as the regular expression. "Fred" contains no metacharacters so 
this command identifies lines of text containing the literal string "Fred". It examines each line from the input 
file, afile.txt. All lines containing the pattern "Fred" are written to the output file, "FredFile.txt":
Grep/P=myPath/E="Fred" "afile.txt" as "FredFile.txt"
Character matching is case-sensitive by default. Prepending the Perl 5 modifier (?i) gives a case-insensitive 
pattern that matches upper and lower-case versions of “Fred”:
// Copy lines that contain "Fred", "fred", "FRED", "fREd", etc
Grep/P=myPath/E="(?i)fred" "afile.txt" as "AnyFredFile.txt"
To copy lines that do not match the regular expression, use the Grep /E flag with the optional reverse param-
eter set to 1 to reverse the sense of the match:
// Copy lines that do NOT contain "Fred", "fred", "fREd", etc
Grep/P=myPath/E={"(?i)fred",1} "afile.txt" as "NotFredFile.txt"
