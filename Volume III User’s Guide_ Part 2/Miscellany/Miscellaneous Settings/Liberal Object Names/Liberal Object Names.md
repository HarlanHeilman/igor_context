# Liberal Object Names

Chapter III-17 — Miscellany
III-501
Object Names
Every Igor object has a name which you give to the object when you create it or which Igor automatically 
assigns. You use an object’s name to refer to it in dialogs, from commands and from Igor procedures. The 
named objects are:
In Igor Pro, the rules for naming waves and data folders are not as strict as the rules for naming all other 
objects, including string and numeric variables, which are required to have standard names. These sections 
describe the standard and liberal naming rules.
Standard Object Names
Here are the rules for standard object names:
•
May be 1 to 255 bytes in length.
Prior to Igor Pro 8.00, names were limited to 31 bytes. See Long Object Names on page III-502 for a 
discussion of issues related to names longer than 31 bytes.
•
Must start with an alphabetic character (A-Z or a-z).
•
May include ASCII alphabetic or numeric characters or the underscore character.
•
Must not conflict with other names (of operations, functions, etc.).
All names in Igor are case insensitive. wave0 and WAVE0 refer to the same wave.
Characters other than letters and numbers, including spaces and periods, are not allowed. We put this 
restriction on names so that Igor can identify them unambiguously in commands, including waveform 
arithmetic expressions.
Liberal Object Names
The rules for liberal names are the same as for standard names except that almost any character can be used 
in a liberal name. Liberal name rules are allowed for waves and data folders only.
If you are willing to expend extra effort when you use liberal names in commands and waveform arithmetic 
expressions, you can use wave and data folder names containing almost any character. If you create liberal 
names then you will need to enclose the names in single (not curly) quotation marks whenever they are 
used in commands or waveform arithmetic expressions. This is necessary to identify where the name ends. 
Liberal names have the same rules as standard names except you may use any character except control 
characters and the following:
"
'
:
;
Here is an example of the creation and use of liberal names:
Make 'wave 0';
// 'wave 0' is a liberal name
'wave 0' = p
Display 'wave 0'
Note:
Providing for liberal names requires extra effort and testing on the part of Igor programmers (see 
Programming with Liberal Names on page IV-168) so you may occasionally experience 
problems using liberal names with user-defined procedures.
Waves
Data folders
Variables (numeric and string)
Windows
Axes
Annotations
Controls
Rulers
Special characters (in notebooks)
Symbolic paths
Pictures
FIFOs
FIFO channels
XOPs
