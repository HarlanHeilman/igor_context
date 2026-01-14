# ImageStats Operation

Chapter III-11 — Image Processing
III-371
As you can see from the four images, the built-in Top Hat implementation enhances the boundaries (con-
tours) of regions in the image whereas the opening or closing tophats enhance small grayscale variations.
The watershed operation locates the boundaries of watershed regions as we show below:
Make/O/N=(100,100) sample
sample=sinc(sqrt((x-50)^2+(y-50)^2)/2.5)// looks like concentric circles.
ImageTransform/O convert2Gray sample
NewImage sample
ModifyImage sample ctab= {*,*,Terrain,0}// color for better discrimination
ImageMorphology /N/L watershed sample
AppendImage M_ImageMorph
ModifyImage M_ImageMorph explicit=1, eval={0,65000,0,0}
Note that omitting the /L flag in the watershed operation may result in spurious watershed lines as the algo-
rithm follows 4-connectivity instead of 8.
Image Analysis
The distinction between image processing and image analysis is rather fine. The pure analysis operations 
are: ImageStats, line profile, histogram, hsl segmentation and particle analysis.
ImageStats Operation
You can obtain global statistics on a wave using the standard WaveStats operation (see page V-1082). The 
ImageStats operation (see page V-414) works specifically with 2D and 3D waves. The operation can define 
a completely arbitrary ROI using a standard ROI wave (see Working with ROI on page III-378). A special 
flag /M=1, speeds up the operation when you only want to know the minimum, maximum and average 
values in the ROI region, skipping over the additional computation time required to evaluate higher 
moments. This operation was designed to work in user defined adaptive algorithms.
ImageStats can also operate on a specific plane of a 3D wave using the /P flag.
250
200
150
100
50
0
200
150
100
50
0
250
200
150
100
50
0
200
150
100
50
0
Closing
Opening
100 80
60
40
20
0
100
80
60
40
20
0
