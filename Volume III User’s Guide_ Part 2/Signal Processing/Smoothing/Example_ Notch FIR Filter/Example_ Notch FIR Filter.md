# Example: Notch FIR Filter

Chapter III-9 — Signal Processing
III-310
For comparision, here is the unfiltered fieldRecording:
The preview in the dialog shows that the lower-frequency elements are removed in the filtered output.
Click Do It to create the filteredHP result of high pass filtering the fieldRecording waveform.
An FFT of the filteredHP result verifies the change:
Another way to evaluate the filtering result is to use the PlaySound operation on the original and filtered 
waveforms:
PlaySound fieldRecording
PlaySound filteredLP
PlaySound filteredHP
Example: Notch FIR Filter
A notch filter is usually employed to reject a very narrow range of frequencies that interfere with the desired 
signal. Removing the interference of 50 or 60 Hz power signals from phsyiological waveforms is one such 
use case.
Here is a synthesized waveform with a 5000 Hz sampling frequency, a 200 Hz signal, and 60 Hz interfer-
ence. The graph on the right shows it's spectral content:
Check the Notch checkbox and uncheck the Low Pass and High Pass checkboxes to create a notch-only 
filter.
