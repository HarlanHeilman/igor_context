# AnnotationInfo

airyB
V-25
airyB 
airyB(x [, accuracy])
The airyB function returns the value of the Airy Bi(x) function:
where I is the modified Bessel function.
Details
See the bessI function for details on accuracy and speed of execution.
See Also
The airyBD and airyA functions.
References
Abramowitz, M., and I.A. Stegun, Handbook of Mathematical Functions, 446 pp., Dover, New York, 1972.
airyBD 
airyBD(x [, accuracy])
The airyBD function returns the value of the derivative Bi'(x) of the Airy function.
Details
See the bessI function for details on accuracy and speed of execution.
See Also
The airyB function.
alog 
alog(num)
The alog function returns 10num.
AnnotationInfo 
AnnotationInfo(winNameStr, annotationNameStr [, options])
The AnnotationInfo function returns a string containing a semicolon-separated list of information about the 
named annotation in the named graph or page layout window or subwindow.
The main purpose of AnnotationInfo is to use a tag or textbox as an input mechanism to a procedure. This 
is illustrated in the “Tags as Markers Demo” sample experiment, which includes handy utility functions 
(supplied by AnnotationInfo Procs.ipf).
Parameters
winNameStr can be "" to refer to the top graph or layout window or subwindow.
When identifying a subwindow with winNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
options is an optional parameter that controls the text formatting in the annotation output. The default value is 0.
Omit options or use 0 for options to escape the returned annotation text, which is appropriate for printing the 
output to the history or for using the text in an Execute operation.
Use 1 for options to not escape the returned annotation text because you intend to extract the text for use in 
a subsequent command such as Textbox or Tag.
Details
The string contains thirteen pieces of information. The first twelve pieces are prefaced by a keyword and 
colon and terminated with a semicolon. The last piece is the annotation text, which is prefaced with a 
keyword and a colon but is not terminated with a semicolon.
Bi(x) =
x
3 I−1/3
2
3 x3/2
⎛
⎝⎜
⎞
⎠⎟+ I1/3
2
3 x3/2
⎛
⎝⎜
⎞
⎠⎟
⎡
⎣⎢
⎤
⎦⎥,
