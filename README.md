# Yellow River Kingdom (aka Hamurabi)
**Port of the BBC Micro "Yellow River Kingdom" game to MMBasic.**

The original version of [Yellow River Kingdom](http://bbcmicro.co.uk/game.php?id=1996&h=h)
was an edutainment title included on the BBC Micro Welcome Tape/Disc and is a variant on
the classic [Hamurabi](https://en.wikipedia.org/wiki/Hamurabi_(video_game)) game.

It is (c) BBC Soft, 1981 and written by Tom Hartley, Jerry Temple-Fry and Richard G Warner.

I like to think that every British child in the 80's and early 90's would either have played this
game or at least watched someone else play it on their school BBC Micro (aka Beeb) - often, at
least early on, there was only one Beeb per school and it was wheeled from classroom to classroom
on a special trolley along with its obligatory CUB Microtech monitor.

This version was ported to MMBasic 5.07 by Thomas Hugo Williams in 2021 starting from this source
code: http://brandy.matrixnetwork.co.uk/examples/KINGDOM.

![Screenshot 1](/resources/screenshot-1.png)
![Screenshot 2](/resources/screenshot-2.png)
![Screenshot 3](/resources/screenshot-3.png)
![Screenshot 4](/resources/screenshot-4.png)
![Screenshot 5](/resources/screenshot-5.png)
![Screenshot 6](/resources/screenshot-6.png)

Please read the [LICENSE](LICENSE) file for further details about modifying and distributing
this program.

Yellow River Kingdom for MMBasic is distributed for free but if you enjoy it then
perhaps you would like to buy me a coffee?

<a href="https://www.buymeacoffee.com/thwill"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="width:217px;"></a>

## How do I install it ?

 - Download the [latest release](https://github.com/thwill1000/mmbasic-kingdom/releases/latest)
 - Extract to a directory of your choice, e.g.
     -  CMM2: `/kingdom/`
     -  Linux: `~/mmbasic/kingdom/`
     -  PicoMite: `/kingdom/`
     -  Windows: `C:\Users\myname\mmbasic\kingdom\`

## How do I run it ?

 - On the CMM2:
     - `chdir "/kingdom"`
     - `*kingdom`
     - *The program renders the same "graphics" to both the VGA screen and serial console.*
 - On Linux using MMB4L:
     - `cd ~/mmbasic/kingdom`
     - `mmbasic kingdom`
 - On the PicoMite:
     - `chdir "/kingdom"`
     - `run "kingdom_pico"`
     - *This version outputs to the serial console only (not the PicoMite VGA display).*
 - On Windows using MMBasic for Windows:
     - Start `mmbasic.exe`
     - `chdir "C:\Users\myname\mmbasic\kingdom"`
     - `*kingdom`

## FAQ

**1. CMM2/PicoMite: How do I fix the non-ASCII characters in the serial console output ?**

These are supposed to be the "box drawing" and other graphical characters and require the correct font / character-encoding to be used by the terminal program:
 - On Windows the best display is obtained using Tera Term with the [CMM2 font](resources/CMM2f1.fon) installed.
 - On Linux the best display is obtained by setting your terminal program to the "Hebrew-IBM862" character-encoding.

**2. What is the Colour Maximite 2 ?**

The Colour Maximite 2 is a small self contained "Boot to BASIC" computer inspired by the home
computers of the early 80's such as the Tandy TRS-80, Commodore 64 and Apple II.

While the concept of the Colour Maximite 2 is borrowed from the computers of the 80's the
technology used is very much up to date.  Its CPU is an ARM Cortex-M7 32-bit RISC processor
running at 480MHz and it generates a VGA output at resolutions up to 800x600 pixels with up to
65,536 colours.

The power of the ARM processor means it is capable of running BASIC at speeds comparable to
running native machine-code on an 8-bit home computer with the additional advantage of vastly
more memory and superior graphics and audio capabilities.

More information can be found on the official Colour Maximite 2 website at
http://geoffg.net/maximite.html

**3. How do I contact the author ?**

The author can be contacted via:
 - https://github.com as user "thwill1000"
 - https://www.thebackshed.com/forum/ViewForum.php?FID=16 as user "thwill"
