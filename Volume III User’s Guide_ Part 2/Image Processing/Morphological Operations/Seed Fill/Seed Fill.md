# Seed Fill

Chapter III-11 — Image Processing
III-377
The second classification produces a distinct separation of the screws from the washers and nuts. It also 
illustrates the importance of selecting the best classification parameters.
You can use the ImageAnalyzeParticles operation also for the purpose of creating masks for particular par-
ticles. For example, to create a mask for particle 9 in the example above:
ImageAnalyzeParticles /L=(w_spotX[9],w_spotY[9]) mark screws
NewImage M_ParticleMarker
You can use this feature of the operation to color different classes of objects using an overlay.
Seed Fill
In some situations you may need to define segments of the image based on a contiguous region of pixels 
whose values fall within a certain range. The ImageSeedFill operation (see page V-409) helps you do just that.
NewImage mri
ImageSeedFill/B=64 seedX=132,seedY=77,min=52,max=65,target=255,srcWave=mri
AppendImage M_SeedFill
ModifyImage M_SeedFill explicit=1, eval={255,65535,65535,65535}
Here we have used the /B flag to create an overlay image but it can also be used to create an ROI wave for 
use in further processing. This example represents the simplest use of the operation. In some situations the 
criteria for a pixel’s inclusion in the filled region are not so sharp and the operation may work better if you 
use the adaptive or fuzzy algorithms. For example (Note: the command is wrapped over two lines):
ImageSeedFill/B=64/c seedX=144,seedY=83,min=60,max=150,target=255, 
srcWave=mri,adaptive=3
Note that the min and max values have been relaxed but the adaptive parameter provides alternative con-
tinuity criterion.
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
200
150
100
50
0
