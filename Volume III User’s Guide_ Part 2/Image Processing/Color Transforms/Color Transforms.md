# Color Transforms

Chapter III-11 — Image Processing
III-352
Overview
Image processing is a broad term describing most operations that you can apply to image data which may 
be in the form of a 2D, 3D or 4D waves. Image processing may sometimes provide the appropriate analysis 
tools even if the data have nothing to do with imaging. In Chapter II-16, Image Plots, we described opera-
tions relating to the display of images. Here we concentrate on transformations, analysis operations and 
special utility tools that are available for working with images.
You can use the IP Tutorial experiment (inside the Learning Aids folder in your Igor Pro 7 folder) in parallel with 
this chapter. The experiment contains, in addition to some introductory material, the sample images and most of 
the commands that appear in this chapter. To execute the commands you can select them in the Image Processing 
help file and press Control-Enter.
For a listing of all image analysis operations, see Image Analysis on page V-4.
Image Transforms
The two basic classes of image transforms are color transforms and grayscale/value transforms. Color trans-
forms involve conversion of color information from one color space to another, conversions from color 
images to grayscale, and representing grayscale images with false color. Grayscale value transforms 
include, for example, pixel level mapping, mathematical and morphological operations.
Color Transforms
There are many standard file formats for color images. When a color image is stored as a 2D wave, it has an 
associated or implied colormap and the RGB value of every pixel is obtained by mapping values in the 2D 
wave into the colormap.
When the image is a 3D wave, each image plane corresponds to an individual red, green, or blue color com-
ponent. If the image wave is of type unsigned byte (/B/U), values in each plane are in the range [0,255]. Oth-
erwise, the range of values is [0,65535].
There are two other types of 3D image waves. The first consists of 4 layers corresponding to RGBA where 
the 'A' represents the alpha (transparency) channel. The second contains more than three planes in which 
case the planes are grayscale images that can be displayed using the command:
ModifyImage imageName plane=n
Multiple color images can be stored in a single 4D wave where each chunk corresponds to a separate RGB image.
You can find most of the tools for converting between different types of images in the ImageTransform 
operation. For example, you can convert a 2D image wave that has a colormap to a 3D RGB image wave. 
Here we create a 3-layer 3D wave named M_RGBOut from the 2D image named 'Red Rock' using RGB 
values from the colormap wave named 'Red RockCMap':
ImageTransform /C='Red RockCMap' cmap2rgb 'Red Rock'
NewImage M_RGBOut
// Resulting 3D wave is M_RGBOut
Note:
The images in the IP Tutorial experiment are not stored in the root data folder, so many of the 
commands in the tutorial experiment include data folder paths. Here the data folder paths have 
been removed for easier reading. If you want to execute the commands you see here, use the 
commands in the “IP Tutorial Help” window. See Chapter II-8, Data Folders, for more 
information about data folders.
In many situations it is necessary to dispose of color information and convert the image into grayscale. This 
usually happens when the original color image is to be processed or analyzed using grayscale operations. 
Here is an example using the RGB image which we have just generated:
ImageTransform rgb2gray M_RGBOut
NewImage M_RGB2Gray
// Display the grayscale image
