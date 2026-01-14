# The Waves Tab

Chapter III-16 — Text Encodings
III-486
•
Converting wave text data or strings which contain binary data, not text
Although these problems should be rare, they are possible, so you should back up any data that may be 
affected before doing conversions.
The Summary Tab
The Summary tab provides an overview of what conversions the other tabs can perform.
The Waves Tab
The Waves tab lists all of the waves in the experiment that use non-UTF-8 text encodings or which appear 
to contain binary data but are not so marked.
As described under Wave Text Encodings on page III-472, each wave has separate text encoding settings 
for each of five elements: the wave name, the wave units, the wave note, the wave dimension labels, and 
the wave text content (applies to text waves only). However, for the vast majority of waves, all of these ele-
ments will use the same text encoding.
In general, waves created in Igor7 or later use UTF-8 text encoding. Such waves do not need to be converted 
to UTF-8 and do not appear in the Waves tab unless they appear to contain binary data (details below).
Waves created in Igor6 or before typically use MacRoman, Windows-1252, or Shift JIS (Japanese) text 
encodings. Such waves can be converted to UTF-8 and do appear in the Waves tab.
A wave element's text encoding may be "Unknown". This is the case for waves written by Igor versions 
prior to 6.30. If such a wave contains non-ASCII text, to convert it to UTF-8, Igor needs to know what text 
encoding to convert from. This is controlled by the text encoding pop-up menu to the right of the Convert 
Waves button. Choose a text encoding from the pop-up menu. Then hover the mouse over the Conversions 
Required column to see snippets of the wave's non-ASCII text rendered using the text encoding you chose. 
If the snippets appear incorrect, try choosing a different text encoding from the pop-up menu.
As described under Text Waves Containing Binary Data on page III-475, some text waves may be used to 
contain binary data rather than text. Such waves are created by Igor packages for specialized purposes. 
Waves that appears to contain binary but are not so marked are included in the list of waves needing con-
version. On conversion, Igor marks their text content as binary.
The Waves tab is built on the SetWaveTextEncoding operation. Because it is intended for use by experts or 
by users instructed by experts, the SetWaveTextEncoding operation does not respect the lock state of 
waves. That is, it will change waves even if they are locked using SetWaveLock. The Waves tab inherits this 
behavior and so also does not respect the lock state of waves.
The list in the Waves tab comprises five columns:
Wave: Lists the full data folder path to each wave.
Kind: Indicates if a given wave is a "home" wave, meaning that it is part of the current experiment, or a 
"shared" wave, meaning that it is stored outside of the current experiment.
A wave that is stored in a packed experiment file or in the experiment folder of an unpacked experiment is 
a home wave. Otherwise it is a shared wave. A wave that is shared may be used by multiple experiments. 
See Home Versus Shared Waves on page II-87 for background information.
Encoding: Shows the text encoding governing the wave or "Mixed" if the wave uses multiple text encodings. 
Hover the mouse over "Mixed" to see which wave elements are governed by which text encodings.
Conversions Required: Shows which wave elements contain text that can be converted to UTF-8. Hover the 
mouse over an item to see a snippet of the non-ASCII text which the wave contains. This column also iden-
tifies text waves whose data appears to be binary but which are not yet marked as binary. Before the con-
version, the column shows conversions that are required for each wave. After the conversion, it remains 
unchanged and should be understood as "conversions that were required" rather then "conversions that are 
required".
