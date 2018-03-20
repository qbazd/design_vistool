DESIgn model visualisation tool
-------------------------------

This is a software to realtime visualisation of output of (DESIgn Ice Floe model)[http://herman.ocean.ug.edu.pl/LIGGGHTSseaice.html].

Main goal of the software is to visualize ice floes disks 50k+@30fps, this is done using GPU utilising OpenCL shaders.

Required Hardware
============

Main requirement is GPU Card, 3.2 OpenGL with 1.5 GLSL (512MB GPU ram is suficient)

Tested on:
- Nvidia Quadro FX 580
- Nvidia Quadro FX 3800

Required Software

Tested on
- Linux (Ubuntu 16.04 LTS 64bit)
- Windows 7 64bit

1. Toolchain 
Required:
- git
- dmd 64bit (dlang compiler)
- gtk 64bit runtime 3.22

1.1 DMD compiler

https://dlang.org/download.html

To build on windows64bit: `dub build --arch=x86_64`
   
2. Getting source and building
    
```lang=d
    git clone --recurse-submodules git@github.com:qbazd/design_vistool.git
    cd design_vistool
    dub build 
    dub build --arch=x86_64 #on windows 64bit version
```

3. Test environment

Test build log

```lang=d

    # dmd --version 
    DMD64 D Compiler v2.077.1
    Copyright (c) 1999-2017 by Digital Mars written by Walter Bright

    # dub --version 
    DUB version 1.5.0+32-g0e90a5c, built on Sep  6 2017

    # dub build
    Performing "debug" build using dmd for x86_64.
    derelict-util 3.0.0-beta.2: target for configuration "library" is up to date.
    derelict-gl3 2.0.0-beta.5: target for configuration "library" is up to date.
    design_io ~master: target for configuration "library" is up to date.
    gl3n 1.3.1: target for configuration "library" is up to date.
    gtk-d:gtkd 3.6.6: target for configuration "library" is up to date.
    design_vistool ~master: target for configuration "application" is up to date.
    To force a rebuild of up-to-date targets, run again with --force.
    Running ./design_vistool

```
