# Logarithmic Indexed Color

Chapter II-16 — Image Plots
II-400
With a color index wave, the image wave data value is used as an X index into the color index wave to select 
the color for a given point. The resultant color depends on the data value and the X scaling of the color index 
wave.
With a color table wave, the image wave’s full range of data values, or a range that you explicitly specify, is 
mapped to the entire color table wave. The resultant color depends on the data value and the operative range 
only, not on the color table wave’s X scaling.
A trivial way to generate a color table wave is to call the ColorTab2Wave operation which creates a 3 column 
RGB wave named M_Colors, where column 0 is the red component, column 1 is green, and column 2 is blue, 
and each value is between 0 (dark), and 65535 (bright).
With a 3 column RGB color table wave, all colors are opaque. You can add a fourth column to control trans-
parency, making it an RGBA wave. The fourth column of an RGBA wave represents “alpha”, where 0 is fully 
transparent and 65535 is fully opaque.
Many color table waves are included in the Color Tables folder in the Igor Pro folder, along with a help file 
that describes them.
The syntaxes for using color table waves for image plots, contour plots, graph traces, and colorscales vary and 
are detailed in their respective commands. See ModifyImage (ctab keyword), ModifyContour (ctabFill and 
ctabLines keywords), ModifyGraph (traces) (zColor keyword) and ColorScale (ctab keyword).
See the “ColorTableWavesHelp.ihf” help file in the “Color Tables” folder of the Igor Pro folder to preview and 
load color table waves that ship with Igor Pro.
Indexed Color Details
An indexed color plot uses a 2D image wave, or a layer of a 3D or 4D wave, and a color index wave. The 
image wave data value is used as an X index into the color index wave to select the color for a given image 
rectangle. The resulting color depends on the data value and the X scaling of the color index wave.
A color index wave is a 2D RGB or RGBA wave. An RGB wave has three columns and each row contains a 
set of red, green, and blue values that range from 0 (zero intensity) to 65535 (full intensity). An RGBA wave 
has three color columns plus an alpha column whose values range from 0 (fully transparent) to 65535 (fully 
opaque).
Linear Indexed Color 
For the normal linear indexed color, Igor finds the color for a particular image data value by choosing the 
row in the color index wave whose X index corresponds to the image data value. Igor converts the image 
data value zImageValue into a row number colorIndexWaveRow using the following computation:
colorIndexWaveRow = floor(nRows*(zImageValue-xMin)/xRangeInclusive)
where,
nRows = DimSize(colorIndexWave,0)
xMin = DimOffset(colorIndexWave,0)
xRangeInclusive = (nRows-1) * DimDelta(colorIndexWave,0)
If colorIndexWaveRow exceeds the row range, then the Before First Color and After Last Color settings are 
applied.
By setting the X scaling of the color index wave, you can control how Igor maps the image data value to a 
color. This is similar to setting the First Color at Z= and Last Color at Z= values for a color table.
Logarithmic Indexed Color 
For logarithmic indexed color (the ModifyImage log parameter is set to 1), colors are mapped using the 
log(x scaling) and log(image z) values this way:
