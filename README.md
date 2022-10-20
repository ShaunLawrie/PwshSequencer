# PwshSequencer
A REALLY rough draft PowerShell music sequencer to have a play with https://github.com/Jaykul/PSAudio  

https://user-images.githubusercontent.com/13159458/196836915-e0d87c20-4c43-4d02-8859-31988c4866ee.mp4  

This has a bunch of issues:
 - No sound sync, it's a best effort sleeping loop to run the sequencer
 - Not using a buffer to write to the scren, it's whipping around using write-host so it's very flickery
 - Full screen redrawn when restarting the sequence
