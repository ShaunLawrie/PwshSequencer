# PwshSequencer
A REALLY rough draft PowerShell music sequencer to have a play with https://github.com/Jaykul/PSAudio  

This has a bunch of issues:
 - No sound sync, it's a best effort sleeping loop to run the sequencer
 - Not using a buffer to write to the scren, it's whipping around using write-host so it's very flickery
 - Full screen redrawn when restarting the sequence
