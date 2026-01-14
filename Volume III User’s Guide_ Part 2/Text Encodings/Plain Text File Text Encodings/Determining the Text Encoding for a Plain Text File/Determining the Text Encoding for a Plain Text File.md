# Determining the Text Encoding for a Plain Text File

Chapter III-16 — Text Encodings
III-467
contain no indication of their text encoding so it can be tricky to determine the source text encoding. If Igor 
gets the source text encoding wrong, you will get errors or see incorrect characters in the text.
Starting with Igor6.3x, Igor stores text encoding information for plain text files stored in or accessed by 
experiment files. Experiment files saved before Igor6.3x do not contain text encoding information. Stand-
alone plain text files not part of an experiment file, such as Igor6 global procedure files, plain text notebook 
files and data files, also do not contain text encoding information.
Igor looks for the optional byte order mark (see Byte Order Marks on page III-471) that some programs 
write at the start of a Unicode plain text file. If present, the byte order mark unambiguously identifies the 
file as Unicode and identifies which encoding scheme (UTF-8, UTF-16 or UTF-32) the file uses.
Starting with Igor7, Igor supports a TextEncoding pragma in procedure files that looks like this:
#pragma TextEncoding = "<text encoding name>"
This is described under The TextEncoding Pragma on page IV-55. The TextEncoding pragma allows you 
to unambiguously specify the text encoding for an Igor procedure file. It is ignored by Igor6.
Starting with Igor9, the text encoding for procedure files defaults to UTF-8.
Igor must deal with a variety of circumstances including:
•
Standalone files versus experiment files
•
Pre-Igor6.3x experiment files versus experiment files from Igor6.3x and later
•
Macintosh versus Windows versus Japanese experiment files
•
Procedure files with and without a TextEncoding pragma
Because of these complications there is no simple way for Igor to determine the source text encoding for 
any given plain text file. To cope with this situation, it employs rules described in the next section.
The status bar of a plain text file's window includes a text encoding button which shows you the "file text 
encoding" - the text encoding that Igor used to convert the file's text to UTF-8. When the file is saved, Igor 
converts from UTF-8 back to the file text encoding. You can change the file text encoding by clicking the text 
encoding button to display the Text Encoding dialog.
Determining the Text Encoding for a Plain Text File
This section describes the rules that Igor uses to determine the source text encoding for a plain text file.
The rules depend on whether Override Experiment (MiscDefault Text EncodingOverride Experiment) 
is checked.
Override Experiment Unchecked
If Override Experiment is unchecked, Igor tries the following text encodings, one-after-another, until it suc-
ceeds (i.e., it is able to convert to UTF-8 without error), in this order:
Byte order mark
TextEncoding pragma if present (for procedure files only)
The specified text encoding (described below)
UTF-8 if the text contains non-ASCII characters
The default text encoding
Choose Text Encoding dialog (described below)
Note that a conversion can "succeed" without being correct. For example, Japanese can be successfully inter-
preted as MacRoman or Windows but you will get the wrong characters.
The "specified text encoding" is the explicit text encoding if present (e.g., specified by the /ENCG flag for 
the OpenNotebook operation) or the item text encoding (e.g., a text encoding stored in an experiment file 
for its built-in procedure window text).
