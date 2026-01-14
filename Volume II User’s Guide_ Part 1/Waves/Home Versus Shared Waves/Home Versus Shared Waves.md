# Home Versus Shared Waves

Chapter II-5 — Waves
II-87
Text Wave Text Encodings
This section is of concern only if you store non-ASCII data in a text wave.
Igor interprets the bytes stored in a text wave in light of the wave’s text content text encoding setting. This 
setting will be UTF-8 for waves created in Igor7 or later and, typically, MacRoman or Windows-1252 for 
waves created in previous versions.
Igor7 and later use Unicode, in the form of UTF-8, as the working text encoding. When you access the cont 
ents of a text wave element or store text in a text wave element, Igor does whatever text encoding conver-
sion is required. For example, assume that macRomanTextWave is a wave created in Igor6 on Macintosh. 
Then:
String str = macRomanTextWave[0]
// Igor converts from MacRoman to UTF-8
str = "Area = 2r"
//  is a non-ASCII character
macRomanTextWave[0] = str
// Igor converts from UTF-8 to MacRoman
Make/O/T utf8TextWave
// New waves use UTF-8 text encoding
utf8TextWave = macRomanTextWave
// Igor converts from MacRoman to UTF-8
macRomanTextWave = utf8TextWave
// Igor converts from UTF-8 to MacRoman
For further discussion, see Text Encodings on page III-459 and Wave Text Encodings on page III-472.
Using Text Waves to Store Binary Data
While a numeric wave stores a fixed number of bytes in each element, a text wave has the ability to store a 
different number of bytes in each point. This makes text waves handy for storing a variable number of vari-
able-length blobs. This is something that an advanced Igor programmer might do in a sophisticated 
package of procedures.
If you do this, you need to mark the text wave as containing binary data. Otherwise Igor will try to interpret 
it as text, leading to errors. For details on this issue, see Text Waves Containing Binary Data on page 
III-475.
Wave Text Encoding Properties
Igor Pro 7 uses Unicode internally. Older versions of Igor used non-Unicode text encodings such as Mac-
Roman, Windows-1252 and Shift JIS.
Igor Pro 7 must convert from the old text encodings to Unicode when opening old files. It is not always pos-
sible to get this conversion right. You may get incorrect characters or receive errors when opening files con-
taining non-ASCII text.
For a discussion of these issues, see Text Encodings on page III-459 and Wave Text Encodings on page 
III-472.
Home Versus Shared Waves
A wave that is stored in a packed experiment file, or in the disk folder corresponding to its data folder for 
an unpacked experiment, is a "home" wave. Otherwise it is a "shared" wave.
Home waves are typically intended for use by their owning experiment only. Shared waves are typically 
intended for use by by multiple experiments.
When you create a wave in a packed experiment, it saved by default in the packed experiment file and is a 
home wave. It becomes a shared wave only if you explicitly save it to a standalone file.
When you create a wave in an unpacked experiment, it is saved by default in the disk folder corresponding 
to its data folder and is a home wave. For waves in root, the disk folder is the experiment folder. For waves 
in other data folders, the disk folder is a subfolder of the experiment folder. The wave becomes a shared 
wave only if you explicitly save it to a standalone file outside of its default disk folder.
