# Applying an FIR Filter to Other Data

Chapter III-9 — Signal Processing
III-307
For an FIR filter, use an odd number of coefficients so that the the filtered output waveform is not delayed 
by a one-half sample.
Applying an FIR Filter to Data
Click the Apply Filter tab to see the result of applying the designed filter to a waveform.
Select the input wave in the Input to Filter listbox and click either Auto-update Filtered Output checkbox 
or the Update Output Now button. This updates a preview of the filtered result:
Click Do It to create a final output wave in the current data folder. You can set the name of the final output 
wave in the Output Name field. Here we used "filteredLP".
For comparision, here is the unfiltered fieldRecording:
The preview in the dialog shows that the higher-frequency elements are removed in the filtered output. An 
FFT of the filteredLP result verifies the change:
Applying an FIR Filter to Other Data
You can reuse a filter if you keep a copy of the design's output coefficients. For example:
Duplicate/O coefs, savedFIRfilter // Keep a copy of the filter design
You can apply the saved FIR filter to other data using the FilterFIR operation directly or using the Select 
Filter Coefficients Wave tab of the Filter dialog. Using the FilterFIR operation:
