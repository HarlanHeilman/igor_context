# Morphological Operations

Chapter III-11 — Image Processing
III-368
NewImage s2
ImageEdgeDetection/M=1/S=3 Canny, sampleEdge
Duplicate/O M_ImageEdges s3
NewImage s3
Note that the Marr detector completely misses the edge with the smoothing setting set to 1. Also, the posi-
tion of the edge moves away from the true edge with increased smoothing in the Canny detector.
Morphological Operations
Morphological operators are tools that affect the shape and boundaries of regions in the image. Starting with 
dilation and erosion, the typical morphological operation involves an image and a structure element. The struc-
ture element is normally much smaller in size than the image. Dilation consists of reflecting the structure element 
about its origin and using it in a manner similar to a convolution mask. This can be seen in the next example:
Make/B/U/N=(20,20) source=0
source[5,10][8,10]=255
// source is a filled rectangle
NewImage source
Imagemorphology /E=2 BinaryDilation source// dilation with 1x3 element
Duplicate M_ImageMorph row
NewImage row
// display the result of dialation
Imagemorphology /E=3 BinaryDilation source// dilation by 3x1 column
Duplicate M_ImageMorph col
NewImage col
// display column dilation
Imagemorphology /E=5 BinaryDilation source// dilation by a circle
NewImage M_ImageMorph
// display circle dilation
The result of erosion is the set of pixels x, y such that when the structure element is translated by that 
amount it is still contained within the set.
Make/B/U/N=(20,20) source=0
source[5,10][8,10]=255
// source is a filled rectangle
NewImage source
Imagemorphology /E=2 BinaryErosion source// erosion with 1x3 element
Duplicate M_ImageMorph row
NewImage row
// display the result of erosion
Imagemorphology /E=3 BinaryErosion source// erosion by 3x1 column
Duplicate M_ImageMorph col
NewImage col
// display column erosion
Imagemorphology /E=5 BinaryErosion source// erosion by a circle
NewImage M_ImageMorph
// display circle erosion
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
Source
Canny
Marr
15
10
5
0
15
10
5
0
15
10
5
0
15
10
5
0
15
10
5
0
15
10
5
0
15
10
5
0
15
10
5
0
Source
Col
Row
Circle

Chapter III-11 — Image Processing
III-369
We note first that erosion by a circle erased all source pixels. We get this result because the circle structure 
element is a 5x5 “circle” and there is no x, y offset such that the circle is completely inside the source. The 
row and the col images show erosion predominantly in one direction. Again, try to imagine the 1x3 struc-
ture element (in the case of the row) sliding over the source pixels to produce the erosion.
The next pair of morphological operations are the opening and closing. Functionally, opening corresponds 
to an erosion of the source image by some structure element (say E), and then dilating the result using the 
same structure element E again. In general opening has a smoothing effect that eliminates small (narrow) 
protrusions as we show in the next example:
Make/B/U/N=(20,20) source=0
source[5,12][5,14] = 255
source[6,11][13,14] = 0
source[5,8][10,10] = 0
source[10,12][10,10] = 0
source[7,10][5,5] = 0
NewImage source
ImageMorphology /E=1 opening source // open using 2x2 structure element
Duplicate M_ImageMorph OpenE1
NewImage OpenE1
ImageMorphology /E=4 opening source // open using a 3x3 structure element
NewImage M_ImageMorph
As you can see, the 2x2 structure element removed the thin connection between the top and the bottom 
regions as well as the two protrusions at the bottom. On the other hand, the two protrusions at the top were 
large enough to survive the 2x2 structure element. The third image shows the result of the 3x3 structure 
element which was large enough to eliminate all the protrusions but also the bottom region as well.
The closing operation corresponds to a dilation of the source image followed by an erosion using the same 
structure element.
Make/B/U/N=(20,20) source=0
source[5,12][5,14] = 255
source[6,11][13,14] = 0
source[5,8][10,10] = 0
source[10,12][10,10] = 0
source[7,10][5,5] = 0
NewImage source
ImageMorphology /E=4 closing source // close using 3x3 structure element
Duplicate M_ImageMorph CloseE4
NewImage CloseE4
15
10
5
0
15
10
5
0
15
10
5
0
15
10
5
0
15
10
5
0
15
10
5
0
15
10
5
0
15
10
5
0
Source
Col
Row
Circle
15
10
5
0
15
10
5
0
15
10
5
0
15
10
5
0
15
10
5
0
15
10
5
0
Source
Open 3x3
Open 2x2

Chapter III-11 — Image Processing
III-370
ImageMorphology /E=5 closing source // close using 5x5 structure element
NewImage M_ImageMorph
The center image above corresponds to a closing using a 3x3 structure element which appears to be large 
enough to close the gap between the top and bottom regions but not sufficiently large to fill the gaps between 
the top and bottom protrusions. The image on the right was created with a 5x5 “circle” structure element, 
which was evidently large enough to close the gap between the protrusions at the top but not at the bottom.
There are various definitions for the Top Hat morphological operation. Igor’s Top Hat calculates the difference 
between an eroded image and a dilated image. Other interpretations include calculating the difference between 
the image itself and its closing or opening. In the following example we illustrate some of these variations.
Duplicate root:images:mri source
ImageMorphology /E=1 tophat source
// close using 2x2 structure element
Duplicate M_ImageMorph tophat
NewImage tophat
ImageMorphology /E=1 closing source // close using 3x3 structure element
Duplicate M_ImageMorph closing
closing-=source
NewImage closing
ImageMorphology /E=1 opening source // close using 3x3 structure element
Duplicate M_ImageMorph opening
opening=source-opening
NewImage opening
15
10
5
0
15
10
5
0
15
10
5
0
15
10
5
0
15
10
5
0
15
10
5
0
Source
Open 3x3
Open 2x2
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
Source
Top Hat
