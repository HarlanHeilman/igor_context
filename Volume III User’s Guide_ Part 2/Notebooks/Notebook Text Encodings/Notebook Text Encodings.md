# Notebook Text Encodings

Chapter III-1 — Notebooks
III-2
Overview
A notebook is a window in which you can store text and graphics, very much like a word processor docu-
ment. Typical uses for a notebook are:
•
Keeping a log of your work.
•
Generating a report.
•
Examining or editing a text file created by Igor or another program.
•
Documenting an Igor experiment.
A notebook can also be used as a worksheet in which you execute Igor commands and store text output 
from them.
Plain and Formatted Notebooks
There are two types of notebooks:
•
Plain notebooks.
•
Formatted notebooks.
Formatted notebooks can store text and graphics and are useful for reports. Plain notebooks can store text 
only. They are good for examining data files and other text files where line-wrapping and fancy formatting 
is not appropriate.
This table lists the properties of each type of notebook.
Plain text files can be opened by many programs, including virtually all word processors, spreadsheets and 
databases. The Igor formatted notebook file format is a proprietary WaveMetrics format that other applica-
tions can not open. However, you can save a formatted notebook as a Rich Text file, which is a file format 
that many word processors can open.
Igor does not store settings (font, size, style, etc.) for plain text files. When you open a file as a plain text 
notebook, these settings are determined by preferences. You can capture preferences by choosing Note-
bookCapture Notebook Prefs.
Notebook Text Encodings
Igor uses UTF-8, a form of Unicode, internally. Prior to Igor7, Igor used non-Unicode text encodings such 
as MacRoman, Windows-1252 and Shift JIS.
Property
Plain 
Formatted
Can contain graphics
No
Yes
Allows multiple paragraph formats (margins, tabs, alignment, line spacing)
No
Yes
Allows multiple text formats (fonts, text styles, text sizes, text colors)
No
Yes
Does line wrapping
No
Yes
Has rulers
No
Yes
Has headers and footers
Yes
Yes
File name extension
.txt
.ifn
Can be opened by most other programs
Yes
No
Can be exported to word processors via Rich Text file
Yes
Yes
