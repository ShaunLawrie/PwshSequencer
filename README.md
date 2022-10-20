# PwshSequencer
A REALLY rough draft PowerShell music sequencer to have a play with https://github.com/Jaykul/PSAudio  

https://user-images.githubusercontent.com/13159458/196837255-ecb9b047-3065-4e76-b52d-97d0065103d0.mp4

This has a bunch of issues:
 - No sound sync, it's a best effort sleeping loop to run the sequencer so the sound stalls and plays unevenly
 - Not using a buffer to write to the scren, it's whipping around using write-host so it's very flickery
 - Full screen redraw happens when restarting the sequence which slows down the replay start
