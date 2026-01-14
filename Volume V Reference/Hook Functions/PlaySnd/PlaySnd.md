# PlaySnd

PlaySnd
V-746
PlayMovieAction extract
ImageTransform rgb2gray M_MovieFrame
NewImage M_RGB2Gray
When you are finished extracting frames, use the kill keyword to close the file.
To get a full path for use with the open keyword, use the PathInfo or Open /D/R commands.
Examples
These commands show to determine the number of frames in a simple movie:
PlayMovieAction open = <full path to movie file>
PlayMovieAction gotoEnd,getTime
Variable tend= V_value
PlayMovieAction step=-1,getTime
Print "frames= ",tend/(tend-V_value)
PlayMovieAction kill
See Also
Movies on page IV-245.
The PlayMovie operation.
PlaySnd 
PlaySnd [flags] fileNameStr
Note: PlaySnd is obsolete. Use PlaySound instead.
Available only on the Macintosh.
The PlaySnd operation plays a sound from the file’s data fork, or from an 'snd ' resource.
Parameters
The file containing the sound is specified by fileNameStr and /P=pathName where pathName is the name of 
an Igor symbolic path. fileNameStr can be a full path to the file, in which case /P is not needed, a partial path 
relative to the folder associated with pathName, or the name of a file in the folder associated with pathName. 
If Igor can not determine the location of the file from fileNameStr and pathName, it displays a dialog allowing 
you to specify the file.
If you use a full or partial path for fileNameStr, see Path Separators on page III-451 for details on forming 
the path.
Flags
Details
If none of /I, /N or /R are specified, PlaySnd tries to play a sound stored in the data fork of the file. If the file 
dialog is used, only files of type 'sfil' are shown.
If any of /I, /N or /R are specified, PlaySnd tries to play a sound from an 'snd ' resource. Most programs 
store sounds in 'snd ' resources. If the file dialog is used, files of all types are shown.
If /P=pathName is omitted, then fileNameStr can take on three special values:
/I=resourceIndex
Specifies the 'snd ' resource to load by resource index, starting from 1.
/M=promptStr
Specifies a prompt if PlaySnd needs to put up a dialog to find the file.
/N=resNameStr
Specifies the resource to load by resource name.
/P=pathName
Specifies the folder to look in for the file. pathName is the name of an existing symbolic 
path.
/Q
Quiet: suppresses the insertion of 'snd ' info into the history area.
/R=resourceID
Specifies the 'snd ' resource to load by resource ID.
/Z
Does not play the sound, just checks for its existence.
“Clipboard”
Loads data from Clipboard.
“System”
Loads data from System file.
