CW_Reader
=========

Improvements on IK3OIL's CW reader

Check the MPLAB_7 branch for the latest version.

Francesco originally had 2 versions of the code for different
LCDs.  Many 16x1 LCDs are actually 8x2 with the two lines side
by side.  The original Hitachi controller made it cheaper to
build them that way.

The latest code is in the MPLAB_7 branch which can be selected 
from the dropdown near the top of the screen.  Francesco's
original code and much of my own work on it was done using
MPLAB 5.  There was a pretty dramatic change from MPLAB 5
to MPLAB 6.  later changes weren't so dramatic.

However, I also modified the MPLAB 7 code to use a relocatable
build since this allows much easier modification and
understanding, so the MPLAB_7 branch is pretty dramatically
different.

My major changes were:
- Use a 40 character LCD
- Add a number of Morse symbols

There were also a number of minor tweaks to the decoding
code to improve reliability.

You may view any file in the list by clicking it.  In the view,
there is a "Raw" button that allows you to download the file
without line numbers.

At the top of the file list is a "Zip" button that creates a
zip file of the current view for download.
