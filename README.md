# HDGR
A proof of concept of a new graphics mode for the Apple II computer


## What do you mean new?
This creates a new software controlled graphics mode that doubles the vertical resolution of the standard DGR mode on an Apple II computer. 

The DGR mode is originally capable of 80x48 at 16 colors.  HDGR switches between _two_ DGR pages at precise times to create a resolution of 80x96 at 16 colors.

There's not really any trickery, though this does use some CPU.  And I'm not really treading any new ground as mode switching tricks go all the way back to Bob Bishop, and there are other people who've done this with other modes like Deater with lo-res and DWSJason with text (TextFunk).  But I do believe I'm the first to make this mode.  This is a fact I put in the README because I can't really share this info at dinner parties, can I?


## Implementation
This is currently an Apple IIgs only implementation.  I use the IIgs' VERTCNT registers to track the current scanline.  I also write directly to AUX bank with 16-bit long indirect instructions.

I considered using scanline interrupts via scanline control bytes (SCB), but this is a much easier implementation to start with.

_HOWEVER_ this can be implemented on a 128K Apple II with 80-columns (DGR capable).  The main difference, aside from copying the graphics data using AUX/MAIN softswitches, is that you would need to implement a new page-flipping routine that relies on some combination of VBLANK or Vapor Lock... followed by cycle perfect timings for the remainder of the screen updates.  It would not leave you much time to do anything else, but that is not why we make such things! ;)

## What is this useful for?
I would love to see someone make an 8-bit Apple II version of this.  I think it would be incredible for graphical adventure games.  

I'm a demo coder and I thought it might be useful in that world, but even on the Apple IIgs it leaves little time to re-blit the screen and doesn't seem like I'd be able to pull of 30 FPS, let alone 60 FPS.  So for now, the itch is scratched.  Another idea explored to verify the possibility.  Maybe you can take it further?

