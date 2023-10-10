Emulicious
Project Homepage: https://www.emulicious.net
Discord Server: https://discord.gg/YuKjBUF
VS Code Extension: https://marketplace.visualstudio.com/items?itemName=emulicious.emulicious-debugger

This program is distributed under the attached license. See License.txt.

=================
Special Thanks
=================
PG Lomba - Visual identity design

=================
Required Runtimes
=================
Java 6 or newer:
http://www.java.com

===============
Troubleshooting
===============
There have been reports of bad performance on Windows 11. This seems to be a driver issue. You can either update your drivers or disable Hardware Acceleration.
On Windows with high-dpi screens, Windows applies some scaling which causes fonts to appear blurry. You can fix this by letting the application handle the scaling.
You can find this via right-click on Emulicious.exe -> Properties -> Compatibility -> Change High DPI Settings -> Tick the checkbox at the bottom and select Application.

====================
Commandline Commands
====================
-muted = start without sound (can still be manually enabled, see controls below)
-scale [level] = start with given zoom level
-link [address] = connects your Emulicious via link with the given address (e.g. "-link localhost" to connect to yourself)
-linkport [port] = specifies to port to use with the -link option (default is 5887, if not specified)
-fullscreen = Start provided rom in fullscreen mode
-set [key=value] = Set a property. E.g. "-set SMSFM=true"
-throttle [speed] = throttles the speed to the given value in percent
-disassemble [file] = Disassemble the provided file. If a directory is provided, all contained files are disassembled.

=================
Expressions
=================
Expressions are used in many places in the Debugger.
For explanations and examples checkout Expressions.txt.

==========
What's New
==========
To keep track on what's new check out WhatsNew.txt.
It also contains explanations of some features.