# ImageGenerateROIMask

ImageGenerateROIMask
V-374
You can combine multiple XYZ datasets in one matrix by calling ImageFromXYZ multiple times with 
different input data and the same dataMatrix and countMatrix. In this case you would clear dataMatrix and 
countMatrix before the first call to ImageFromXYZ only.
What you do with the output is up to you but one technique is to divide dataMatrix by countMatrix to get 
the average and then use MatrixFilter NanZapMedian to eliminate any NaN values that result from zero 
divided by zero.
Example
Make /N=1000 /O wx=enoise(2), wy= enoise(2), wz= exp(-(wx^2+wy^2))
Make /O /N=(100,100) dataMat=0
SetScale x,-2,2,dataMat
SetScale y,-2,2,dataMat
Duplicate /O dataMat,countMat
ImageFromXYZ /AS {wx,wy,wz}, dataMat, countMat
// Execute these one at a time
NewImage dataMat
dataMat /= countMat
// Replace cumulative z value with average
MatrixFilter NanZapMedian, dataMat
// Apply median filter, zapping NaNs
See Also
SetScale, Image X and Y Coordinates on page II-388.
ImageGenerateROIMask 
ImageGenerateROIMask [/W=winName/E=e/I=i] imageInstance
The ImageGenerateROIMask operation creates a Region Of Interest (ROI) mask for use with other 
ImageXXX commands. It assumes the top (or /W specified) graph contains an image and that the user has 
drawn shapes using Igor’s drawing tools in a specific manner.
ImageGenerateROIMask creates an unsigned byte mask matrix with the same x and y dimensions and 
scaling as the specified image. The mask is initially filled with zeros. Then the drawing layer, progFront, in 
the graph is scanned for suitable fillable draw objects. The area inside each shape is filled with ones unless 
the fill mode for the shape is set to erase in which case the area is filled with zeros.
Flags
Details
To generate an ROI wave for use with most image processing operations you need to set the values of 
interior pixels to zero and exterior pixels to one using /E=1/I=0.
Suitable objects are those that can be filled (rectangles, ovals, etc.) and which are plotted in axis coordinate 
mode specified using the same axes by which the specified image instance is displayed. Objects plotted in 
plot relative mode are also used, However, this is not recommended because it will give correct results only 
if the image exactly fills the plot rectangle. If you use axis coordinate mode then you can zoom in or out as 
desired and the resulting mask will still be correct.
Note that the shapes can have their fill mode set to none. This still results in a fill of ones. This is to allow 
the drawn ROI to be visible on the graph without obscuring the image. However cutouts (fills with erase 
mode) will obscure the image.
Note also that nonfill drawing objects are ignored. You can use this fact to create callouts and other annotations.
In a future version of Igor, we may create a new drawing layer in graphs dedicated to ROIs.
The mask generated is named M_ROIMask and is generated in the current data folder.
/E=e
Changes value used for the exterior from the default zero values to e.
/I=i
Changes value used for the interior from the default one values to i.
/W=winName
Looks for the named graph window or subwindow containing appropriate image 
masks drawn by the user. If /W is omitted, ImageGenerateROIMask uses the top 
graph window or subwindow.
When identifying a subwindow with winName, see Subwindow Syntax on page III-92 
for details on forming the window hierarchy.
