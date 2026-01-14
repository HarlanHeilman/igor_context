# PlayMovieAction

PlayMovieAction
V-745
PlayMovieAction 
PlayMovieAction [/A/Z] keyword [=value][, keyword [=value]]
The PlayMovieAction operation is used to extract frames from a movie file.
Flags
Keywords
Details
Operations are performed in the following order: kill, gotoBeginning, gotoEnd, frame, step, getTime, 
extract. kill overrides all other parameters.
If you want to extract a grayscale image, you can convert the RGB image into grayscale using the 
ImageTransform command as follows:
/A
Macintosh: /A is ignored.
Windows: Uses alternate deprecated technology, AVI instead of MMF.
/Z
Errors do not stop procedure execution. Use V_Flag to see if an error occurred.
extract
Extracts current frame into an 8-bit RGB image wave named M_MovieFrame. (Can be 
combined with frame=f.)
extract=e
Extracts e frames into a single multiframe wave, M_MovieChunk. This wave will have 
3 planes for RGB and will have e chunks.
e=1 is the same as plain extract.
For e>1, the current time is automatically updated.
frame=f
Moves to specified movie frame.
getID
Returns top movie ID number in V_Value. Do not use in same call with getTime.
getTime
Reads current movie time into variable V_value (in seconds).
gotoBeginning
Goes to beginning of movie.
gotoEnd
Closes the movie opened using the open keyword movie file.
kill
Closes open movie.
loop=mode
On Macintosh only, mode chooses between two extraction methods. The default, 
equivalent to loop=0, is fast but can not back up; an attempt to extract a frame 
previous to the last one extracted results in an error. The alternate method, loop=1, 
provides random access but can be very slow when reading sequential frames.
The loop keyword was added in Igor Pro 8.00. It is ignored on Windows.
open=fullPath
Opens the specifed movie file to enable frame extraction. V_Flag is set to zero if no 
error occurred and V_Value is set to the file reference number.
ref=refNum
The ref keyword is used with all PlayMovieAction commands after using the open 
keyword to access a movie file. refNum must be the file reference number returned in 
V_Value in the open step.
The ref keyword is needed only if multiple files or windows are open. You can also 
use setFrontMovie to set the active movie.
setFrontMovie= id
Sets the movie with given id as the active movie file.
Do not use setFrontMovie and getID in same call to PlayMovieAction.
start
Obsolete. Movie windows are no longer supported in Igor itself.
step=s
Moves by s frames into movie (0 is same as 1, negative values move backwards).
stop
Obsolete. Movie windows are no longer supported in Igor itself.
