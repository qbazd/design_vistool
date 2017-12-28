1. Toolchain 

1.1 DMD compiler
	https://dlang.org/download.html
	
	One have to install: dmd, dub
    On windows64bit (dub build --arch=x86_64)
    
2. Getting source

*Build tree view:*

 - ./design_io (library repo)
 - ./design_vistool (this repo)

    GetSource and build
    
    mkdir design_vis_root
    cd design_vis_root
    git clone design_io_git_url.git
    git clone design_vistool_git_url.git
    cd design_vistool
    git submodule update --init --recursive
    dub build 
    dub build --arch=x86_64 #on windows 64bit version

3. Building

Test build log

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

