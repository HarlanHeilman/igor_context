# Applying an IIR Filter to Other Data

Chapter III-9 — Signal Processing
III-315
Duplicate/O unitStep, unitStepFiltered
FilterIIR/DIM=0/COEF=savedIIRDF1filter unitStepFiltered
Display unitStep, unitStepFiltered
The next example shows how the filter responds to an ideal "unit impulse" waveform and display it's FFT 
magnitude, as the Filter Design and Application dialog does:
Make/O/N=2048 impulse = p == 16
// Unit step wave for causal IIR filters
CopyScales/P yourData, impulse
Duplicate/O impulse, impulseFiltered
FilterIIR/CASC/DIM=0/COEF=savedIIRDF2filter impulseFiltered // DF II 
implementation needs /CASC
Display impulse, impulseFiltered
FFT/MAG/DEST=impulseFiltered_FFT impulseFiltered
// Magnitude of response
Display impulseFiltered_FFT
Display impulseFiltered_FFT
// A logarithmic axis has the same shape 
ModifyGraph log(left)=1
// as computing 20*log(response)
Applying an IIR Filter to Other Data
You can reuse a filter if you keep a copy of the design's output coefficients. For example:
Duplicate/O coefs, savedIIRfilter // Keep a copy of the filter design.
