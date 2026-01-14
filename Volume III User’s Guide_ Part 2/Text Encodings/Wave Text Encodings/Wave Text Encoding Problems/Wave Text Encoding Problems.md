# Wave Text Encoding Problems

Chapter III-16 — Text Encodings
III-474
This provides a way for you to override incorrect text encoding settings when loading an experiment. 
For example, if you know that an experiment uses Japanese but you get gibberish or Unicode conver-
sion errors when loading it, you can choose Japanese as your default text encoding, select Override 
Experiment, and reload the experiment. You should restore the default text encoding to its normal 
value and turn Override Experiment off for future use.
3.
Otherwise if the text encoding for the specific element being converted is known, because it was previ-
ously set to a value other than "unknown", Igor uses it as the source text encoding.
This is the effective rule for waves created by Igor6.3x and later.
This is also the effective rule if you explicitly set a wave's text encoding settings using the SetWaveTex-
tEncoding operation.
4.
Otherwise if the experiment file text encoding is known, Igor uses it as the source text encoding.
This rule takes effect for waves created in earlier versions if the experiment was later saved from 
Igor6.3x or later. Wave text encoding settings would still be unknown but the experiment file text 
encoding would reflect the text encoding of the experiment's procedure window when it was saved. 
This will give correct results for most experiments.
5.
Otherwise Igor uses the selected default text encoding as the source text encoding.
This rule takes effect for experiments saved before Igor6.3x in which both the experiment file text 
encoding and the element-specific text encodings are unknown. This is the effective rule for experi-
ments of this vintage.
Wave Text Encoding Problems
This section describes the problems that may occur when loading a wave from an Igor binary wave file or 
from a packed experiment file.
If Igor is not able to correctly determine a wave element's text encoding and if the element contains non-
ASCII text you may see gibberish text or Igor may generate a text encoding conversion error.
If Igor is not able to correctly determine the text encoding of a wave name you will see gibberish for the 
name and Igor will be unable to find the wave when it is referenced from procedures such as experiment 
recreation procedures. This may cause errors when the experiment is loaded.
Igor’s handling of invalid text in tables is described under Editing Invalid Text on page II-259.
The SetWaveTextEncoding operation allows you to set the text encodings for one or more waves or for all 
waves in the experiment. This is especially useful for pre-IP6.3x experiments. You can run it in Igor6.3x or 
later. It is discussed below under Manually Setting Wave Text Encodings on page III-477.
If you get text encoding conversion errors when opening an experiment you can try the following:
•
Choose a different text encoding from the Default Text Encoding menu and reopen the experiment
•
Select Override Experiment in the Default Text Encoding menu so that it is checked and reopen the 
experiment
•
Manually fix the errors after opening the experiment
•
Use the SetWaveTextEncoding operation to specify the text encodings used by waves
•
For pre-IP63x experiments, open the experiment in Igor6.3x, resave it, and reopen it
After attempting to fix a text encoding problem you should restore your default text encoding to the most 
reasonable setting for your situation and turn Override Experiment off.
If you are unable to solve the problem you can send the experiment to WaveMetrics support with the fol-
lowing information:
•
What operating system you are running
