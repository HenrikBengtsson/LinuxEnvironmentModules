[![Travis CI Build Status](https://travis-ci.org/HenrikBengtsson/LinuxEnvironmentModules.svg?branch=master)](https://travis-ci.org/HenrikBengtsson/LinuxEnvironmentModules/branches)


# R package: LinuxEnvironmentModules - An R API to Linux Environment Modules

...


## Example modules

The package provides a few example module files.  There are both classical Tcl-based ("Tmod") modules and Lua-based ("Lmod") modules.

```sh
$ module unuse $MODULEPATH
$ module use $PWD/inst/modulefiles/*
$ module avail

-------------- /home/hb/repositories/LinuxEnvironmentModules/inst/modulefiles/tcl ---------------
   cuda/9.1    mpi/openmpi-x86_64

------------- /home/hb/repositories/LinuxEnvironmentModules/inst/modulefiles/lmod ---------------
   r/3.5.1

Use "module spider" to find all possible modules.
Use "module keyword key1 key2 ..." to search for all possible modules matching any of the "keys".
```

### Lmod modules

An Lmod module that provides full documentation (help, whatis, ...):

```lua
$ module --raw show r
------------------------------------------------------------------------------------------
   /home/hb/repositories/LinuxEnvironmentModules/inst/modulefiles/lmod/r/3.5.1.lua:
------------------------------------------------------------------------------------------
help([[
R: The R Programming Language
]])

local name = myModuleName()
local version = myModuleVersion()
whatis("Version: " .. version)
whatis("Keywords: Programming, Statistics")
whatis("URL: https://www.r-project.org/")
whatis("Description: The R programming language. Examples: `R --version` and `Rscript --versio
n`.")

local root = os.getenv("SOFTWARE_ROOT")
local home = pathJoin(root, "R-" .. version)
prepend_path("PATH", home .. "/bin")
prepend_path("MANPATH", home .. "/share/man")
```

### Tmod modules

An Tmod module that provides a "whatis" entry:

```tcl
$ module --raw show cuda
------------------------------------------------------------------------------------------
   /home/hb/repositories/LinuxEnvironmentModules/inst/modulefiles/tcl/cuda/9.1:
------------------------------------------------------------------------------------------
#%Module 1.0

module-whatis "NVIDIA CUDA Toolkit libraries"
prepend-path  PATH               /usr/local/cuda-9.1/bin
prepend-path  LD_LIBRARY_PATH    /usr/local/cuda-9.1/lib64
setenv        CUDA_LIB_PATH      /usr/local/cuda-9.1/lib64
```


An Tmod module that without any documentation other than a source-code comment:

```tcl
$ module --raw show mpi
------------------------------------------------------------------------------------------
   .../LinuxEnvironmentModules/inst/modulefiles/tcl/mpi/openmpi-x86_64:
------------------------------------------------------------------------------------------
#%Module 1.0
#
#  OpenMPI module for use with 'environment-modules' package:
#
conflict		mpi
prepend-path 		PATH 		/usr/lib64/openmpi/bin
prepend-path 		LD_LIBRARY_PATH /usr/lib64/openmpi/lib
prepend-path		PYTHONPATH	/usr/lib64/python2.7/site-packages/openmpi
prepend-path		MANPATH		/usr/share/man/openmpi-x86_64
setenv 			MPI_BIN		/usr/lib64/openmpi/bin
setenv			MPI_SYSCONFIG	/etc/openmpi-x86_64
setenv			MPI_FORTRAN_MOD_DIR	/usr/lib64/gfortran/modules/openmpi-x86_64
setenv			MPI_INCLUDE	/usr/include/openmpi-x86_64
setenv	 		MPI_LIB		/usr/lib64/openmpi/lib
setenv			MPI_MAN		/usr/share/man/openmpi-x86_64
setenv			MPI_PYTHON_SITEARCH	/usr/lib64/python2.7/site-packages/openmpi
setenv			MPI_COMPILER	openmpi-x86_64
setenv			MPI_SUFFIX	_openmpi
setenv	 		MPI_HOME	/usr/lib64/openmpi
```


## Sesssion information

```sh
$ module --version

Modules based on Lua: Version 6.6  2016-10-13 13:28 -05:00
    by Robert McLay mclay@tacc.utexas.edu
```


## References

* Linux Environment Modules on Wikipedia: https://en.wikipedia.org/wiki/Environment_Modules_(software)
* Tmod Environment Modules on SourceForge: http://modules.sourceforge.net/
* Lmod Environment Modules on GitHub: https://github.com/TACC/Lmod
* Lmod documentation: http://lmod.readthedocs.org/
