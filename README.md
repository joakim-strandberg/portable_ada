# The cross-compiler Std library

All the source code in this repository has successfully been compiled using
the GNAT GCC compiler, LLVM-GNAT compiler and Janus/Ada compiler.
The configuration "script" std_conf_main.adb can also be executed
using the HAC Ada compiler.

## Minimal dependencies
The source code in this repository can be compiled by any Ada 2005 compiler.
From the Ada 2005 standard only "not null" access types are used.
Usually a software project has a dependency upon Make or a Bash script
or a Bat-file for configuring the project on Windows. The Std library
is configured by an application std_conf_main.adb and to execute it
one only needs the Ada compiler installed on one's system.

# Installation
To use the source code in the Std library it must first be configured
for the specific hardware on one's system. The configuration parameters
are described in the file std_conf.txt and where one specifies
the Operating System and if the hardware architecture is 32- or 64-bit.
After editing the std_conf.txt file the std_conf_main.adb application
needs to be executed.

## Configuration using the HAC compiler
Execute the command "hax std_conf_main.adb".

## Configuration using the GNAT compiler
The application needs to be built using the command
"gnatmake std_conf_main.adb" or "gprbuild std_conf.gpr" and this will
produce the executable file std_conf_gnat on Linux and std_conf_gnat.exe on
Windows.
