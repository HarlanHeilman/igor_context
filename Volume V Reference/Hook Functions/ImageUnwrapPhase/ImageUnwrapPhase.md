# ImageUnwrapPhase

ImageUnwrapPhase
V-433
Examples 
If you want to insert a 2D (M x N) wave, plane0, into plane number 0 of an (M x N x 3) wave, rgbWave:
ImageTransform /P=0/D=plane0 setPlane rgbWave
If your source wave is 100 rows by 100 columns and you want to create a montage of this image use:
ImageTransform /W/N={200,200} padImage srcWaveName
Hue and Saturation Segmentation Example
Function hueSatSegment(hslW,lowH,highH,lowS,highS)
Wave hslW
Variable lowH,highH,lowS,highS
Make/D/O/N=(2,3) conditionW
conditionW={{lowH,highH},{lowS,highS},{NaN,NaN}}
ImageTransform/D=conditionW matchPlanes hslW
KillWaves/Z conditionW
End
Voronoi Tesselation Example
Make/O/N=(33,3) ddd=gnoise(4)
ImageTransform voronoi ddd
Display ddd[][1] vs ddd[][0]
ModifyGraph mode=3,marker=19,msize=1,rgb=(0,0,65535)
AppendToGraph M_VoronoiEdges[][1] vs M_VoronoiEdges[][0]
SetAxis left -15,15
SetAxis bottom -5,10
See Also
Chapter III-11, Image Processing, for many examples. In particular see: Color Transforms on page III-352, 
Handling Color on page III-379, and General Utilities: ImageTransform Operation on page III-381. The 
MatrixOp operation.
References
Born, Max, and Emil Wolf, Principles of Optics, 7th ed., Cambridge University Press, 1999.
Details about the rgb2i123 transform:
Gevers, T., and A.W.M. Smeulders, Color Based Object Recognition, Pattern Recognition, 32, 453-464, 1999.
ImageUnwrapPhase 
ImageUnwrapPhase [flags][qualityWave=qWave,] srcwave=waveName
The ImageUnwrapPhase operation unwraps the 2D phase in srcWave and stores the result in the wave 
M_UnwrappedPhase in the current data folder. srcWave must be a real valued wave of single or double 
precision. Phase is measured in cycles (units of 2).
Parameters
Flags
qualityWave=qWave
Specifies a wave, qWave, containing numbers that rate the quality of the phase 
stored in the pixels. qWave is 2D wave of the same dimensions as srcWave that can 
be any real data type and values can have an arbitrary scale. If used with /M=1 the 
quality values determine the order of phase unwrapping subject to branch cuts, 
with higher quality unwrapped first. If used with /M=2 the unwrapping is guided 
by the quality values only. This wave must not contain any NaNs or INFs.
srcwave=waveName
Specifies a real-valued SP or DP wave that may contain NaNs or INFs but is 
otherwise assumed to contain the phase modulo 1.
/E
Eliminate dipoles. Only applies to Goldstein’s method (/M=1). Dipoles are a pair of a 
positive and negative residues that are side by side. They are eliminated from the 
unwrapping process by replacing them with a branch cut. The variable 
V_numResidues contains the number of residues remaining after removal of the 
dipoles.

ImageUnwrapPhase
V-434
Details
Phase unwrapping in two dimensions is difficult because the result of the operation needs to be such that any 
path integral over a closed contour will vanish. In many practical situations, certain points in the plane have the 
property that a path integral around them is not zero. These nonzero points are residues. We use the definition 
that when a counterclockwise path integral leads to a positive value the residue is called a positive residue.
ImageUnwrapPhase uses the modified Itoh’s method by default. Phase is unwrapped with an offset equal 
to the first element that is allowed by the ROI starting at (0,0) and scanning by rows. If there are no residues 
or if you unwrap the phase using Itoh’s algorithm, then the phase is unwrapped only subject to the optional 
ROI using a seed-fill type algorithm that unwraps by growing a region outward from the seed pixel. Each 
time that the region growing is terminated by boundaries (external or due to the ROI), the algorithm returns 
to the row scanning to find a new starting point.
If there are residues and you choose Goldstein’s method, the residues are first mapped into a lookup table 
(LUT) and branch-cuts are determined between residues and boundaries. It is also possible to remove some 
residues (dipoles) using the /E flag. Phase is then unwrapped in regions bounded by branch cuts using a 
seed-fill type algorithm that does not cross branch cuts. With a quality wave, the algorithm follows the same 
seed-fill approach except that it gives priority to pixels with high quality level. The phase on the branch cuts 
themselves is subsequently calculated.
/L
/M=method
/MAX=len
Specifies the maximum length of a branch cut. Only applicable to Goldstein’s method 
(/M=1). By default this is set to the largest of rows or columns.
/Q
Suppresses messages to the history.
/R=roiWave
Specifies a region of interest (ROI). The ROI is defined by a wave of type unsigned 
byte (/B/U) that has the same number of rows and columns as waveName. The ROI 
itself is defined by entries or pixels in the roiWave with value of 1. Pixels outside the 
ROI should be set to zero. The ROI does not have to be contiguous but it is best if you 
choose a convex ROI in order to make sure that any branch cuts computed by the 
algorithm lie completely inside the ROI domain.
/REST = threshold
Sets the threshold value for evaluating a residue. The residue is evaluated by the 
equivalent of a closed path integral. If the path integral value exceeds the threshold 
value, the top-left corner of the quad is taken to be a positive residue. If the path 
integral is less than -threshold, it is a negative residue.
Saves the lookup table(LUT) used in the analysis with /M=1. This information may 
be useful in analyzing your results. The LUT is saved as a 2D unsigned byte wave 
M_PhaseLUT in the current data folder. Each entry consists of 8-bit fields:
Other bits are reserved and subject to change. See Setting Bit Parameters on page 
IV-12 for details about bit settings.
bit=0:
Positive residue.
bit=1:
Negative residue.
bit=2:
Branch cut.
bit=3:
Image boundary exclusion.
Determines the method for computing the unwrapped phase:
method =0:
Modified Itoh’s algorithm, which assumes that there are no residues 
in the phase. The phase is unwrapped in a contiguous way subject 
only to the ROI or singularities in the data (e.g., NaNs or INFs). You 
will get wrong results for the unwrapped phase if you use this 
method and your data contains residues.
method=1:
Modified Goldstein’s algorithm. Creates the variables 
V_numResidues and V_numRegions. Optional qWave can 
determine order of unwrapping around the branch cuts.
method=2:
Uses a quality map to decide the unwrapping path priority. The 
quality map is a 2D wave that has the same dimensions as the source 
wave but could have an arbitrary data type. The phase is 
unwrapped starting from the largest value in the quality map.
