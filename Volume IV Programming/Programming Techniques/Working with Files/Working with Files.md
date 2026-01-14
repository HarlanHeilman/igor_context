# Working with Files

Chapter IV-7 — Programming Techniques
IV-194
\(( ( (?>[^()]+) | (?R) )* ) \)
 

the string they capture is “ab(cd)ef”, the contents of the top level parentheses. If there are more than 15 cap-
turing parentheses in a pattern, PCRE has to obtain extra memory to store data during a recursion, which 
it does by using pcre_malloc, freeing it via pcre_free afterward. If no memory can be obtained, the match 
fails with the PCRE_ERROR_NOMEMORY error.
Do not confuse the (?R) item with the condition (R), which tests for recursion. Consider this pattern, 
which matches text in angle brackets, allowing for arbitrary nesting. Only digits are allowed in nested 
brackets (that is, when recursing), whereas any characters are permitted at the outer level.
< (?: (?(R) \d++ | [^<>]*+) | (?R)) * >
In this pattern, (?(R) is the start of a conditional subpattern, with two different alternatives for the recur-
sive and nonrecursive cases. The (?R) item is the actual recursive call.
Subpatterns as Subroutines
If the syntax for a recursive subpattern reference (either by number or by name) is used outside the paren-
theses to which it refers, it operates like a subroutine in a programming language. An earlier example 
pointed out that the pattern
(sens|respons)e and \1ibility
matches “sense and sensibility” and “response and responsibility”, but not “sense and responsibility”. If 
instead the pattern
(sens|respons)e and (?1)ibility
is used, it does match “sense and responsibility” as well as the other two strings. Such references must, 
however, follow the subpattern to which they refer.
Regular Expressions References
The regular expression syntax supported by Grep, GrepString, GrepList, and Demo is based on the PCRE 
— Perl-Compatible Regular Expression Library by Philip Hazel, University of Cambridge, Cambridge, 
England. The PCRE library is a set of functions that implement regular expression pattern matching using 
the same syntax and semantics as Perl 5.
Visit <http://pcre.org/> for more information about the PCRE library. The description of regular 
expressions above is taken from the PCRE documentation.
A good introductory book on regular expressions is: Forta, Ben, Regular Expressions in 10 Minutes, Sams 
Publishing, 2004.
A good comprehensive book on regular expressions is: Friedl, Jeffrey E. F., Mastering Regular Expressions, 
2nd ed., 492 pp., O’Reilly Media, 2002.
A good web site is: http://www.regular-expressions.info
Working with Files
Here are the built-in operations that you can use to read from or write to files:
Operation
What It Does
Open
Opens an existing file for reading or writing. Can also create a new file. Can also append to 
an existing file. Returns a file reference number that you must pass to the other file operations.
Use Open/D to present a dialog that allows the user to choose a file without actually 
opening the file.
fprintf
Writes formatted text to an open file.
