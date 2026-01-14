# TagVal

TagVal
V-1022
The characters “<??>” in a tag indicate that you specified an invalid escape code or used a font that is not 
available.
Examples
Following is an example of various ways in which axis tags can be used:
Make/O jack=sin(x/8)
SetScale x,0,14e9,"y" jack
Display jack
Label bottom "\\u#2"
// turn off default axis label
ModifyGraph axOffset(bottom)=1.16667 // make room for tag (manual adustment)
Tag/N=axisTag0/F=0/A=MT/X=0.20/Y=-4.29/L=0 bottom, Nan, "\\JCTime (\\U)\r2nd line"
// Now tag a few important points
Tag/N=axisTag1/F=0/A=LB/X=1.20/Y=3.00 bottom, 0, "Big Bang"
Tag/N=axisTag2/F=0/A=MB/X=0.00/Y=2.86 bottom, 8000000000, "Earth formed"
Tag/N=axisTag3/F=0/A=RB/X=-0.80/Y=4.71 bottom, 13040000000, "Dinosaurs ruled"
See Also
TextBox, Legend, AppendText, AnnotationInfo, AnnotationList
TagVal, TagWaveRef
Annotation Escape Codes on page III-53
Label, Axis Labels on page II-318
Trace Names on page II-282, Programming With Trace Names on page IV-87
TagVal 
TagVal(code)
TagVal is a very specialized function that is only valid when called from within the text of a tag as part of 
a \{} dynamic text escape sequence. It returns a number reflecting some property of the tag and helps you 
to display information about the tagged wave. The property is selected by the code parameter:
Because TagVal returns a numeric value, the result can be formatted any way you wish using the printf 
formatting codes. In contrast, the \O codes insert preformatted text, and you don’t have control over the format.
TagVal is sometimes used in conjunction with the TagWaveRef function. For example, you might write a 
user-defined function that calculates a value as a function of a wave and a point number.
Examples
Tag wave0, 0, "Y value is \\{\"%g\",TagVal(2)}"
Tag wave0, 0, "Y value is \\{\"%g\",TagWaveRef()[TagVal(0)]}"
Tag wave0, 0, "Y value is \\OY"
These examples all produce identical results.
code 
Return Value
0
Similar to \OP, returns the tag attach point number.
1
Similar to \OX, returns the X coordinate of tag attachment in the graph. When a tag is attached to 
an XY pair of traces, the X coordinate will most likely be different than the tag’s X scaling 
attachment value specified in the Tag command.
2
Similar to \OY, returns the Y coordinate of tag attachment in the graph or the Y axis value in 
a Waterfall plot.
3
Similar to \OZ, returns the Z coordinate of tag attachment in a contour, image, or Waterfall 
plot.
4
Similar to \Ox, returns the trace x offset.
5
Similar to \Oy, returns the trace y offset.
6
Returns the X muloffset (with the not set value 0 translated to 1).
7
Returns the Y muloffset (with the not set value 0 translated to 1).
