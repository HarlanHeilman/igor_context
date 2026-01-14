# Histogram Example

Chapter III-7 — Analysis
III-128
The Histogram Dialog
To use the Histogram operation, choose Histogram from the Analysis menu.
To use the “Manually set bins” or “Set from destination wave” bin modes, you need to decide the range of 
data values in the source wave that you want the histogram to cover. You can do this visually by graphing the 
source wave or you can use the WaveStats operation to find the exact minimum and maximum source values.
The dialog requires that you enter the starting bin value and the bin width. If you know the starting bin 
value and the ending bin value then you need to do some arithmetic to calculate the bin width.
A line of text at the bottom of the Destination Bins box tells you the first and last values, as well as the width 
and number of bins. This information can help with trial-and-error settings.
If you use the “Manually set bins” or any of the “Auto-set” modes, Igor will set the X units of the destination 
wave to be the same as the Y units of the source wave.
If you enable the Accumulate checkbox, Histogram does not clear the destination wave but instead adds 
counts to the existing values in it. Use this to accumulate results from several histograms in one destination. 
If you want to do this, don’t use the “Auto-set bins” option since it makes no sense to change bins in mid-
stream. Instead, use the “Set from destination wave” mode. To use the Accumulate option, the destination 
wave must be double-precision or single-precision and real.
The “Bin-Centered X Values” and “Create Square Root(N) Wave” options are useful for curve fitting to a 
histogram. If you do not use Bin-Centered X Values, any X position parameter in your fit function will be 
shifted by half a bin width. The Square Root(N) Wave creates a wave that estimates the standard deviation 
of the histogram data; this is based on the fact that counting data have a Poisson distribution. The wave 
created by this option does not try to do anything special with bins having zero counts, so if you use the 
square root(N) wave to weight a curve fit, these zero-count bins will be excluded from the fit. You may need 
to replace the zeroes with some appropriate value.
The binning modes were added in Igor Pro. In earlier versions of Igor, the accumulate option had two effects:
•
Did not clear the destination wave.
•
Effectively used the “Set bins from destination wave” mode.
To maintain backward compatibility, the Histogram operation still behaves this way if the accumulate 
(“/A”) flag is used and no bin (“/B”) flag is used. This dialog always generates a bin flag. Thus, the accumu-
late flag just forces accumulation and has no effect on the binning.
You can use the Histogram operation on multidimensional waves but they are treated as though the data 
belonged to a single 1D wave. If you are working with 2D or 3D waves you may prefer to use the Image-
Histogram operation (see page V-379), which computes the histogram of one layer at a time.
Histogram Example
The following commands illustrate a simple test of the histogram operation.
SetRandomSeed 0.2
// For reproducible randomness
Make/O/N=10000 noise = gnoise(1)
// Make raw data
Make hist
// Make destination wave
Histogram/B={-3, (3 - -3)/100, 100} noise, hist
// Perform histogram
Display hist; Modify mode(hist)=1
These commands produce the following graph:
