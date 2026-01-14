# Axis Label Escape Codes

Chapter III-2 — Annotations
III-57
The use of two backslashes in the TextBox literal string parameter is explained under Backslashes in Anno-
tation Escape Sequences on page III-58.
The full form is:
\{ formatStr, list-of-numeric-or-string-expressions }
formatStr and list-of-numeric-or-string-expressions are treated as for the printf operation. For instance, this 
example has a format string, a numeric expression and a string expression:
TextBox "\\{\"Two times PI is %1.2f, and today is %s\", 2*PI, date()}"
It produces this result:
Two times PI is 6.28, and today is Thu, April 9, 2015
You can not use any other annotation escape codes in the format string or numeric or string expressions. 
They don't work within the \{ ... } context.
Also, the format string and string expressions do not support multiline text. If you need to use multiline 
text, use the technique described in Generating Text Programmatically on page III-53.
As an aid in typing the expressions, Igor considers carriage returns between the braces to be equivalent to 
spaces. In the Add Annotation dialog, rather than typing:
\{"Two times PI is %1.2f, and today is %s",2*PI,date()}
you can type:
\{
"Two times PI is %1.2f, and today is %s",
2*PI,
date()
}
Legend Symbol Escape Codes
You can insert a legend symbol in an annotation.
The syntax for inserting a symbol in a graph is:
\s(traceName)
The syntax for inserting a symbol in a page layout is:
\s(graphName.traceName)
\s is usually used in a legend, in which symbols are created and removed automatically, but can also be 
used in tags, textboxes, and axis labels where the symbol is updated, but not automatically added or 
removed. See Legends on page III-42.
Axis Label Escape Codes
These escape codes are supported in axis labels and in axis tags:
\c
Inserts the name of the wave that controls the axis. This is the first wave graphed 
against that axis.
\E
Inserts power of 10 scaling with leading "x". This can be ambiguous and we 
recommend that you use either \U or \u.
\e
Like \E but inverts the sign of the exponent. This can be ambiguous and we 
recommend that you use either \U or \u.
\U
Inserts units with automatic prefixes
