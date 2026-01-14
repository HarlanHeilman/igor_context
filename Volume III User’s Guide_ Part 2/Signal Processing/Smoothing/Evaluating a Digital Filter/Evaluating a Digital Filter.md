# Evaluating a Digital Filter

Chapter III-9 — Signal Processing
III-314
Applying an IIR Filter to Data
Click the Apply Filter tab to see the result of applying the designed filter to a waveform.
Select the input wave in the Input to Filter listbox and click either Auto-update Filtered Output checkbox 
or the Update Output Now button. This updates a preview of the filtered result.
Click Do It to create a final output wave in the current data folder. You can set the name of the final output 
wave in the Output Name field. Here we used filteredIIRDF2:
Evaluating a Digital Filter
The graph in the Response tab of the Filter Design and Application dialog is the most direct way to evaluate 
what the filter will do to an input waveform.
You can also graph the original data and filtered data for a detailed visual comparision.
A useful technique, borrowed from electrical engineering, is to see how the filter responds to an ideal "unit 
step" waveform:
Make/O/N=256 unitStep = p >= 32
// Unit step wave for causal IIR filters
CopyScales/P yourData, unitStep
// Same sampling frequency as your data
