# Color Table Details

Chapter II-16 — Image Plots
II-395
Color Table Ranges - Lookup Table (Gamma)
Normally the range of data values and the range of colors are linearly related or logarithmically related if 
the ModifyImage log parameter is set to 1. You can also cause the mapping to be nonlinear by specifying 
a lookup (or “gamma”) wave, as described in the next example.
Example: Using a Lookup for Advanced Color/Contrast Effects
The ModifyImage operation (see page V-635) with the lookup parameter specifies a 1D wave that modifies 
the mapping of scaled Z values into the current color table. Values in the lookup wave should range from 
0.0 to 1.0. A linear ramp from 0 to 1 would have no effect while a ramp from 1 to 0 would reverse the color-
map. Used to apply gamma correction to grayscale images or for special effects.
Make luWave=0.5*(1+sin(x/30))
Make /n=(50,50) simpleImage=x*y
NewImage simpleImage
ModifyImage simpleImage ctab= {*,*,Rainbow,0}
// After inspecting the simple image, apply the lookup:
ModifyImage simpleImage lookup=luWave
Specialized Color Tables
Some of the color tables are designed for specific uses and specific numeric ranges.
The BlackBody color table shows the color of a heated “black body”, though not the brightness of that body, 
over the temperature range of 1,000 to 10,000 K.
The Spectrum color table is designed to show the color corresponding to the wavelength of visible light as 
measured in nanometers over the range of 380 to 780 nm.
The SpectrumBlack color table does the same thing, but over the range of 355 to 830 nm. The fading to black 
is an attempt to indicate that the human eye loses the ability to perceive colors at the range extremities.
The GreenMagenta16, EOSOrangeBlue11, EOSSpectral11, dBZ14, and dBZ21 tables are designed to repre-
sent discrete levels in weather-related images, such as radar reflectivity measures of precipitation and wind 
velocity and discrete levels for geophysics applications. 
The LandAndSea, Relief, PastelsMap, and SeaLandAndFire color tables all have a sharp color transition which 
is intended to denote sea level. The LandAndSea and Relief tables have this transition at 50% of the range. You 
can put this transition at a value of 0 by setting the minimum value to the negative of the maximum value:
ModifyImage imageName, ctab={-1000,1000,LandAndSea,0}
// image plot
ColorScale/C/N=scale0 ctab={-1000,1000,LandAndSea,0}
// colorscale
The PastelsMap table has this transition at 2/3 of the range. You can put this transition at a value of 0 by 
setting the minimum value to twice the negative of the maximum value:
ModifyImage imageName, ctab={-2000,1000,PastelsMap,0}
// image plot
ColorScale/C/N=scale0 ctab={-2000,1000,PastelsMap,0}
// colorscale
This principle can be extended to the other color tables to position a specific color to a desired value. Some 
trial-and-error is to be expected.
The BlackBody, Spectrum, and SpectrumBlack color tables are based on algorithms from the Color Science 
web site:
<http://www.physics.sfasu.edu/astro/color.html>.
Color Table Details
The built-in color tables can be grouped into several categories.
