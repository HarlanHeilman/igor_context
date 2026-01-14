# popup

popup
V-755
Details
PolygonOp performs various operations on polygon paths that are defined by pairs of 1D real numeric 
waves. A path is defined by an XY pair of waves that may describe one or more closed polygons. 
Consecutive polygons are separated by a single NaN value in both path waves.
You must always specify the primary path waves. You must specify the secondary waves if you need to 
perform a binary polygon operation.
To simplify the computation the input waves are internally mapped into 32-bit signed integer arrays so that 
vertices correspond to discrete integer pairs (pixels).
To support a broad range of inputs, the operation allows you to specify how the input waves are scaled into 
integers. Scaling is isotropic; there is currently no support for anamorphic scaling. The scaling factor 
determines the number of significant figures that remain after conversion to integers. In extreme cases it is 
advisable to preprocess the polygon waves, e.g., by removing a mean offset and/or applying anamorphic 
scaling. On output, an inverse scaling is applied with no compensation for the initial truncation or 
rounding. The inverse scaling is also applied to area calculations.
Output Variables
PolygonOp sets the following output variables:
See Also
DrawPoly, FindPointsInPoly, PolygonArea
Demos
Choose FilesExample ExperimentsFeature Demos 2PolygonOp Demo.
popup 
popup menuList
The popup keyword is used with Prompt statements in Functions and Macros. It indicates that you want a 
pop-up menu instead of the normal text entry item in a DoPrompt simple input dialog (or a Macro’s missing 
parameter dialog (archaic)). menuList is a string expression containing a list of items, separated by 
semicolons, that are to appear in the pop-up menu.
Pop-up menus accept both numeric and string parameters. For numeric parameters, the number of the item 
selected is placed in the variable. Numbering starts from one. For string parameters, the selected item’s text 
is placed in the string variable.
Specifies a pair of 1D waves that define points for testing pointInPoly. The waves 
must have the same number type and the same number of points. The polygon that is 
used in the test is either the primary polygon, when the operation is PointInPoly, or 
the polygon resulting from the combination of the primary and secondary polygons 
together with the operation specified by the operation keyword. The waves must 
contain at least one point.
primaryWaves={srcXWave, srcYWave}
Specifies the primary path or paths. In case of more than one path, the paths are 
separated by a NaN in both waves. Both waves must have the same number type and 
the same number of points. The waves must contain at least 3 points. 
secondaryWaves={secondaryXWave, secondaryYWave}
Specifies a the secondary or clipping path or paths. In case of more than one path, the 
paths are separated by a NaN in both waves. Both waves must have the same number 
type and the same number of points. The waves must contain at least 3 points. 
V_flag
Zero if the operation succeeds or to a non-zero error code.
V_value
The pointInPolyResult result for a single point specified using /SPT.
V_area
The area of the resulting polygon corrected for scaling.
S_waveNames
Semicolon separated list of the names of the waves created by the operation.
