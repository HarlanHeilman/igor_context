# Filter Design and Application Dialog

Chapter III-9 — Signal Processing
III-302
Filter Design and Application Dialog
The Filter Design and Application dialog provides a simple user-interface for designing and applying a 
digital filter. Choose AnalysisFilter to display it:
This dialog allows you to design a subset of the Igor Filter Design Laboratory's filters. It is simpler and the 
filters are sufficient for most purposes.
Initially the Design FIR Filter tab is shown with a simple Low Pass filter pre-selected. "Design using this 
Sampling Frequency (Hz)" is set to 1 and the frequencies shown are in the default range of 0 to 0.5 Hz 
because the default design sampling frequency is 1 Hz.
To start the filter design, either:
•
Manually enter the sampling frequency or
•
Click Apply Filter and select a wave to be filtered whose sampling frequency is properly set as de-
scribed above
This fieldRecording wave was sampled at 48000 Hz:

Chapter III-9 — Signal Processing
III-303
Switch back to the Response tab to show the default Low Pass filter using the entered sampling frequency. 
The frequency range is now 0-24000 Hz:
You can use any combination of one low pass band, one high pass band, and one notch to pass or reject 
frequency components of the sampled data wave. By using both low pass and high pass bands you can 
create Band Pass and Band Stop Filters.
Before we apply a filter to fieldRecording, let's graph the original waveform:
