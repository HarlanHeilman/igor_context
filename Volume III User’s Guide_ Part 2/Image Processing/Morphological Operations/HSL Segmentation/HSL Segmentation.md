# HSL Segmentation

Chapter III-11 — Image Processing
III-374
Histograms of 3D waves containing more than 3 layers can be computed by specifying the layer with the 
/P flag. For example,
Make/N=(10,20,30) ddd=gnoise(5)
ImageHistogram/P=10 ddd
Display W_ImageHist
Unwrapping Phase
Unwrapping phase in two dimensions is more complicated than in one dimension because the operation’s 
results must be independent of the unwrapping path. The path independence means that any path integral 
over a closed contour in the unwrapped domain must vanish. In many situations there are points in the 
domain around which closed contour path integrals do not vanish. Such points are called “residues”. The res-
idues are positive if a counter-clockwise path integral is positive. When unwrapping phase in two dimen-
sions, the residues are typically ±1. This suggests that whenever two opposing residues are connected by a line 
(known as a “branch cut”), any contour integral whose path does not cross the branch cut will vanish. When 
a positive and negative residues are side by side they combine to a “dipole” which may be removed because 
a path integral around the dipole also vanishes. It follows that unwrapping can be performed using paths that 
either do not encircle unbalanced residues or paths that do not cross branch cuts.
The ImageUnwrapPhase operation (see page V-433) performs 2D phase unwrapping using either a fast 
method that ignores possible residues or a slower method which locates residues and attempts to find paths 
around them. The fast method uses direct integration of the differential phases. It can lead to incorrect 
results if there are residues in the domain. The slow method first identifies all residues, draws them into an 
internal bitmap adding branch cuts and then applying repeatedly the algorithm used in ImageSeedFill to 
obtain the paths around the residues and branch cuts until all pixels have been processed. Sometimes the 
distribution of residues and branch cuts is such that the domain of the data is covered by several regions, 
each of which is completely bounded by branch cuts or the data boundary. In this case, the phase is com-
puted independently in each individual region with an offset that is based on the first processed pixel in 
that region. Note that when you use ImageUnwrapPhase using a method that computes the residues, the 
operation creates the variables V_numResidues and V_numRegions. You can also obtain a copy of the inter-
nal bitmap which could be useful for analyzing the results.
The ImageUnwrapPhase Demo in the Examples:Analysis folder provides a detailed example illustrating 
different types of residues, branch cuts and resulting unwrapped phase.
HSL Segmentation
When you work with color images you have two analogs to grayscale thresholding. The first is simple 
thresholding of the luminance of the image. To do this you need to convert the image from RGB to HSL and 
then perform the thresholding on the luminance plane. The second equivalent of thresholding is HSL seg-
mentation, where the image is subdivided into regions of HSL values that fall within a certain range. In the 
following example we segment the peppers image to locate regions corresponding to red peppers:
NewImage root:images:peppers
ImageTransform/H={330,50}/L={0,255}/S={0,255} root:images:peppers
NewImage M_HueSegment
15
10
5
0
x103 
250
200
150
100
50
0
 W_ImageHistR
 W_ImageHistG
 W_ImageHistB
