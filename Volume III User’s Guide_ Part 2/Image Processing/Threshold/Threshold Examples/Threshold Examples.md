# Threshold Examples

Chapter III-11 — Image Processing
III-356
example illustrates the different thresholding methods for an image of light gray blobs on a dark gray back-
ground (the “blobs” image in the IP Tutorial).
Threshold Examples 
This section shows results using various methods for automatic threshold determination.
The commands shown were executed in the demo experiment that you can open by choosing FileExam-
ple ExperimentsTutorialsImage Processing Tutorial.
// User defined method
ImageThreshold/Q/T=128 root:images:blobs
Duplicate/O M_ImageThresh UserDefined
NewImage/S=0 UserDefined; DoWindow/T kwTopWin, "User-Defined Thresholding"
// Iterated method
ImageThreshold/Q/M=1 root:images:blobs
Duplicate/O M_ImageThresh iterated
NewImage/S=0 iterated; DoWindow/T kwTopWin, "Iterated Thresholding"
// Bimodal method
ImageThreshold/Q/M=2 root:images:blobs
Duplicate/O M_ImageThresh bimodal
NewImage/S=0 bimodal; DoWindow/T kwTopWin, "Bimodal Thresholding"
// Adaptive method
ImageThreshold/Q/I/M=3 root:images:blobs
Duplicate/O M_ImageThresh adaptive
NewImage/S=0 adaptive; DoWindow/T kwTopWin, "Adaptive Thresholding"
// Fuzzy-entropy method
ImageThreshold/Q/M=4 root:images:blobs
Duplicate/O M_ImageThresh fuzzyE
NewImage/S=0 fuzzyE; DoWindow/T kwTopWin, "Fuzzy Entropy Thresholding"
// Fuzzy-M method
ImageThreshold/Q/M=5 root:images:blobs
Duplicate/O M_ImageThresh fuzzyM
User Defined
Iterated
Bimodal
Adaptive
