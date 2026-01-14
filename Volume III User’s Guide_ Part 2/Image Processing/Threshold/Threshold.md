# Threshold

Chapter III-11 — Image Processing
III-355
from the global histogram equalization, you can increase the number of vertical and horizontal regions that 
are processed:
ImageHistModification/A/C=100/H=20/V=20 M_paddedImage
You can now compare the global and adaptive histogram results. Note that the adaptive histogram per-
formed better (increased contrast) over most of the image. The increase in the clipping value (/C flag) gave 
rise to a minor artifact around the boundary of the head.
Threshold
The threshold operation is an important member of the level mapping class. It converts a grayscale image 
into a binary image. A binary image in Igor is usually stored as a wave of type unsigned byte. While this 
may appear to be wasteful, it has advantages in terms of both speed and in allowing you to use some bits 
of each byte for other purposes (e.g., bits can be turned on or off for binary masking). The threshold opera-
tion, in addition to producing the binary thresholded image, can also provide a correlation value which is 
a measure of the threshold quality.
You can use the ImageThreshold operation (see page V-415) either by providing a specific threshold value 
or by allowing the operation to determine the threshold value for you. There are various methods for auto-
matic threshold determination:
Iterated: Iteration over threshold levels to maximize correlation with the original image.
Bimodal: Attempts to fit a bimodal distribution to the image histogram. The threshold level is 
chosen between the two modal peaks.
Adaptive: Calculates a threshold for every pixel based on the last 8 pixels on the same scan line. It 
usually gives rise to drag lines in the direction of the scan lines. You can compensate for this artifact 
as we show in an example below.
Fuzzy Entropy: Considers the image as a fuzzy set of background and object pixels where every 
pixel may belong to a set with some probability. The algorithm obtains a threshold value by 
minimizing the fuzziness which is calculated using Shannon’s Entropy function.
Fuzzy Means: Minimizes a fuzziness measure that is based on the product of the probability that 
the pixel belongs in the object and the probability that the pixel belongs to the background.
Histogram Clusters: Determines an ideal threshold by histograming the data and representing the 
image as a set of clusters that is iteratively reduced until there are two clusters left. The threshold 
value is then set to the highest level of the lower cluster. This method is based on a paper by A.Z. 
Arifin and A. Asano (see reference below) but modified for handling images with relatively flat 
histograms. If the image histogram results in less than two clusters, it is impossible to determine a 
threshold using this method and the threshold value is set to NaN.
Variance: Determines the ideal threshold value by maximizing the total variance between the 
"object" and "background". See http://en.wikipedia.org/wiki/Otsu’s_method.
Each of the thresholding methods has its advantages and disadvantages. It is sometimes useful to try all the 
methods before you decide which method applies best to a particular class of images. The following 
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
Global
Adaptive
