# Loading TIFF Files

Chapter II-9 — Importing and Exporting Data
II-158
When loading a PNG file, the image data is loaded into a 3D Igor RGB wave containing unsigned byte RGB 
elements in layers 0, 1, and 2. If the image file includes an alpha channel, the resulting 3D RGBA wave 
includes an alpha layer.
You can convert a 3D waves containing an RGB image into a grayscale image using the ImageTransform 
operation with the rgb2gray keyword.
Loading JPEG File
When loading a JPEG file, the image data is loaded into a 3D Igor RGB wave containing unsigned byte RGB 
elements in layers 0, 1, and 2. JPEG does not support alpha.
You can convert a 3D waves containing an RGB image into a grayscale image using the ImageTransform 
operation with the rgb2gray keyword.
Loading BMP Files
When loading a BMP file, the image data is loaded into a 3D Igor RGB wave containing unsigned byte RGB 
elements in layers 0, 1, and 2. BMP does not support alpha.
You can convert a 3D waves containing an RGB image into a grayscale image using the ImageTransform 
operation with the rgb2gray keyword.
Loading TIFF Files
A TIFF file can store one or more images in many formats. The most common formats are:
•
Bilevel
•
Grayscale
•
Palette color
•
Full color (RGB, RGBA, CMYK)
A bilevel image consists of one plane of data in which each pixel can represent black or white. Igor loads a 
bilevel image into a 2D wave.
A grayscale image consists of one plane of data in which each pixel can represent a range of intensities. Igor 
loads a grayscale image into a 2D wave.
A palette color image is like a grayscale but includes a color palette. Igor loads the grayscale image into a 
2D wave and also creates a colormap wave named with the suffix "_CMap".
RGB, RGBA, and CMYK images are loaded into 3D waves with 3 or 4 layers. Each layer stores the pixels for 
one color component.
TIFF files that contain multiple images are called TIFF stacks. There are two options for loading them:
•
Load the images into a single 3D wave.
This works with grayscale images only. Each grayscale image is loaded into a layer of the 3D output 
wave.
•
Load each image into its own wave.
This works with any kind of image. Each grayscale image is loaded into its own 2D wave. Each 
RGB, RGBA, or CMYK image is loaded into its own 3D wave.
You can specify a particular image, or range of images, to be loaded from a multi-image TIFF file. In the 
Load Image dialog, enter the zero-based index of the first image to load and the number of images to load 
from the TIFF stack.
You can display TIFF images using the NewImage operation and convert image waves into other forms 
using the ImageTransform operation.
