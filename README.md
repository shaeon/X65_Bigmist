X65
====

The X65 is an ultimate computer for everyone interested in the venerable 65-series of 8-bit and 16-bit CPUs,
i.e. the 6502 and 65816 [*]. Specifically, we support the W65C02S and W65C816S CPU chips from Western Design Centre.
The design is fully open-source and open-hardware, and we also prefer to use just the open-source development tools
whenever possible. The X65 computer hardware is designed with modern electronics parts, but with a distinct retro feel.
The computer is backward compatible with Commander X16 (i.e. can run their ROM), but the goal is to improve
both the architecture, performance and elegance of the system.

Compared with modern powerful platforms like x86, ARM or RISC-V, the small 65-series 8-bit system has the advantage
that a person, a software programmer or electronics designer, can fully comprehend the whole system top-down
and bottom-up with all details. There are not many abstraction layers or silos hidden in supporting libraries
or big frameworks. (In fact, there are none. It is just bare metal.) 
The X65 is built for developers who may wish an escape from modern ivory computing towers and who long
for simpler times, maybe faintly remembered from their childhood, playing with commodores, amigas and spectrums.

_Interfaces_: VGA 640x480 out, Stereo sound out (FM and PSG), PS/2 keyboard and mouse, SNES controller 2x ports,
Ethernet LAN 10/100Mpbs with RJ45, SDHC card slot, power-in 5V USB-C port, In-Circuit Debugger (ICD) over the USB-C with 
PC host software in Python and supporting JTAG-like functions for the 65xx platform (CPU step, trace, memory dump & poke).

[*] note: W65C816S to be tested yet.

Project web pages: http://www.x65.eu  -> currently links to http://www.jsykora.info

----------------------------------------------------------------------------
*Warning* 

This hardware project is a work-in-progress.
Some parts of the design are untested yet, and other parts may even contain known bugs to be fixed in the next revision.
See the section `Status of hardware testing' below.

----------------------------------------------------------------------------


General Project Features:
-------------------------

* The CPU is W65C02 (8-bit) or the W65C816 (16-bit). The motherboard PCB supports both assembly options 
  (note: W65C816 has not been tested so far, but is planned).
* Backward software compatibility with the [Commander X16](https://www.commanderx16.com/) computer.
  Can run unmodified CX16 ROM for testing purposes.
* Designed with components (chips) that are in production and available from normal electronics parts distributors 
  such as Mouser, Farnell, Digikey etc. We avoid obsolete parts.
* Balanced modern/retro design built around the central 65xx CPU supported by semi-ASICs (FPGAs) for system control (NORA),
  video (VERA) and audio (AURA) generation. The FPGAs are the little ones from the iCE40 series, coded in verilog.
  This approach is in line with "old masters" who designed Commodore or ZX Spectrum systems, 
  not possible without custom ASICs either (see ULA, VIC, SID, etc.).
  For sure, there is no hidden ARM or RISC-V doing heavy lifting in the background.
* Free and open-source design. DIY and hobby-builders friendly. 
  Low-cost to build even in small quantities by individual hackers.

Block Diagram
---------------

![Block Diagram](doc/pic/x65-small-blockdiagram.drawio.png)

Hardware Specification:
------------------------

* **CPU**: W65C02 or W65C816 in the QFP-44 package, running at 8MHz, supplied by 3.3V.
* **Memory**: 2MB asynchronous SRAM, common for ROM and RAM.
* **System controller** semi-ASIC, aka north-bridge, aka NORA: Lattice FPGA iCE40HX4K (TQFP-144) handles address decoding, 
  glue logic, PS/2 interfaces, in-circuit debugger and more. 
  "NORA" stands for NORth Adapter, has a similar function like the north bridge in a PC/X86 architecture.
* Two ports for **SNES-style controllers**, handled by NORA.
* Two **PS/2 ports** for keyboard and mouse, handled by NORA. (note: we reimplement CX16 arduino code in pure hardware logic in verilog.)
* **Colour video** output through VGA connector, up to 640x480 pixels. 
  Generated by [VERA FPGA](https://github.com/X16Community/vera-module): the Video Embedded Retro Adapter, in Lattice FPGA iCE40UP5K. 
  The same is used in Commander X16.
* **Stereo audio** output through 3.5mm jack port. 
  Sound comes from two sources: FM-synthesis (OPM) by YM2151 clone [IKAOPM](https://github.com/ika-musume/IKAOPM) 
  implemented in [AURA FPGA](doc/aura_ym2151.md) (iCE40UP5K),
  and Programmable Sound Generator (PSG) available in VERA FPGA. These are digitally mixed in AURA and passed to a DAC.
  Besides the output jack connector, the sound can be also heard from a small on-board mono speaker.
* **SD-card slot** supporting SDHC cards (handled by VERA FPGA).
* **LAN 10/100Mbps** Ethernet port (RJ45) implemented by [Wiznet W6100](https://www.wiznet.io/product-item/w6100/) chip, 
  with hardware-integrated TCP/IP v4/v6 stack.
* **Real-time clock* (RTC) chip with battery backup.
* **In-circuit debugger** (ICD) integrated with NORA and accessible over the device USB-C port from a host PC
  running Linux or Windows. The ICD can write all permanent (SPI-Flash) memories in the system, 
  even in a totally empty / bricked state. PC host software is written in Python and should be portable to other 
  fruitful systems besides Linux and Windows.
  Together with NORA the ICD supports JTAG-like functions like memory poke/dump, CPU stop/stepping, instruction
  trace buffer for the last 512 CPU cycles, interrupt forcing/blocking etc.
* **Power input** 5V from a standard USB Type-C device port.
  The X65 computer can be powered from a normal host-PC USB port (for development with ICD), 
  or runs standalone from a common Mains/USB phone charger with just 5V output.
* A two-PCB stacked construction: Motherboard (mo-bo) at the bottom and Video-Audio board (va-bo) at the top,
  connected by two 20-pin headers. Each board is exactly 100x100mm and conductive 2-layers. 



Photos:
--------

Overview photos (2023-05-08) - first working sample:

![Front view photo](Photos/frontview.jpg)

![Rear view photo](Photos/rearview.jpg)

Engineering testing samples, hand-assembled:

![Motherboard photo](Photos/20231208_170908-mobo-top.jpg)

![Video/Audio Board photo](Photos/20231208_170810-vabo-top.jpg)

Running Commander X16 ROM and BASIC program (compatibility testing only, not allowed in production use due to a proprietary license):

![X16 Booted](Photos/20230514_200930_ready_print.jpg)

![MAZE BASIC Program typed in](Photos/20230514_201322-mazeprog.jpg)

![MAZE BASIC Program run](Photos/20230514_201336-mazerun.jpg)




Structure of the GIT repository:
---------------------------------

* `fpga-nora' --> verilog code for the NORA FPGA on the motherboard.
* `fpga-vera' --> VERA FPGA bitstream (100% derived from https://github.com/fvdhoef/vera-module)
* `pcb' --> hardware projects in Kicad:
  - `mobo-rev01' --> Motherboard rev01
  - `vabo-rev01' --> Video/Audio board rev01
* `x65prog' --> linux software to program the on-board SPI flash memories from a host Linux PC via the USB link.
* `x65pyhost' --> python scripts for accessing/debugging the X65 from a host PC via the USB link.


Schematics in PDF:
------------------

**Revision 1:**

* [Motherboard, rev01 - PDF scm](pcb/mobo-rev01/scm-print/openX65-mobo-rev01-schematic.pdf)

* [Video/Audio board, rev01 - PDF scm](pcb/vabo-rev01/scm-prints/openX65-vabo-rev01-schematic.pdf)

* Note: Revision 1 contains many bugs that will be fixed in Revision 2!

**Revision 2:**

* To be done...


Software:
-----------

The X65 is software-backwards-compatible with the Commander X16. 
It means the X65 could run unmodified CX16 ROM and programs, excluding programs depending on some of the hardware features 
in CX16 that are not supported here: cartridges, Commodore IEC port, etc.
However, the CX16 ROM is a proprietary, non-open-source and non-free, piece of software created by Commodore
and licensed to the CX16 creators. The licensees do not wish that the ROM runs on other HW than their own.
Therefore, I could not recommend running that ROM in X65 environment.

Presently it is not decided which "operating system" or "runtime shell" would be the best / easiest to port to X65.
There some existing systems, for example:

* [MEGA65 OPEN-ROMs](https://github.com/MEGA65/open-roms) (true free open-source sw),
* [FastBasic](https://github.com/dmsc/fastbasic)
* [GeckOS](http://www.6502.org/users/andre/osa/index.html)

The hardware could be assembled with either the 8-bit 65C02 CPU or the 16-bit 65C816 CPU.
I am not decided which one should be the default.
The advantage of the 16-bit 65C816 CPU is a linear 24-bit address space.
On the other hand, compiler tools support is much weaker than for 65C02.


Timeline
---------

This project started in March 2023 when I saw a prototype of Commander X16 in one of the youtube videos
of the 8-bit guy. I immediately wanted to play with it but at the time his project was not released,
the hardware could not be bought. So I decided to build one myself, based on public information available
about the CX16. At the same time I was not too pleased with the architecture and implementation
of the CX16, not satisfied with many design choices they did. The X65 tries to improve in many areas
while being software-compatible.
I had the first working boards in about May 2023. The project inevitably stalled during the summer due to the
necessity to attend other developments in the garden of my house. But as the garden falls for winter sleep,
I restarted the X65 project in the Autumn. The pace of development everyone could judge by GIT logs.
I have a daytime job with Siemens, developing PCIe PROFINET cards, and a family.
Therefore, future timeline is impossible to guarantee.
What can be seen now (December 2023) is a Revision 1 design - an engineering prototype.
Soon I want to create a Revision 2 design which would fix many errors and add few improvements.
Notably I want to add micro-SDHC slot to the bottom motherboard to function as a "hard-disk".
The existing SDHC slot on the top board would continue to work as a removable disk.
The other new feature would be a support for some kind of enclosure - maybe a stacked PCBs, 
maybe an Eurocard housing.


Status of hardware testing
----------------------------

(last update 09.12.2023):

* Motherboard ('mobo') rev01:
  * CPU W65C02, SRAM 2MB, FPGA NORA -- works OK!
  * option: CPU W65C816 -- **to be tested**.
  * original VIA -- will be removed from the design!
  * SNES controller ports -- works OK (slight change in scm).
  * RTC -- works OK!
  * USB, FTDI debugger -- works OK!
  * PS2 Keyboard -- works OK! (but the circuit will be changed to simplify)
  * PS2 Mouse -- works OK!
  * TFT LCD -- not tested, feature will be removed.
  * UART via FTDI -- not tested.
  * Power supply -- works OK, PCB layout needs improvements.

* Video/Audio board ('vabo') rev01:
  * VERA FPGA, with VGA out -- works OK!
  * S-Video/Composite out -- NTSC output is low quality, maybe VERA design problem.
  * SDC interface -- works OK! (An "SDHC" card required by X16 ROM)
  * I/O LEDS and DIP -- not tested yet.
  * AURA FPGA -- works OK! (YM2151 FM-synth replica)
  * Audio DAC -- works OK!
  * Built-in speaker -- tested, the volume control switch needs improvements.
  * 10/100 LAN -- tested partly, so far looks ok.


Contact
--------

Jaroslav Sykora,
    Personal: http://www.jsykora.info,
    GIT: https://github.com/jsyk,
    Mastodon: https://oldbytes.space/@jarda,
    Physically in the Czech Republic.
