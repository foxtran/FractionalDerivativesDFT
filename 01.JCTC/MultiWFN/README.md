# Multiwfn compilation

Here, the dump of Multiwfn 3.8 (7-Jan-2023) is presented.
For making compilation possible not only for x86 Linux, Makefile was edited for building with GCC.

## Compilation

Compilation with supported fractional derivatives requires installed [Arb](https://arblib.org/) and [flint](https://www.flintlib.org/) libraries.
Also, BLAS and LAPACK libraries should be installed. Probably, you will need to patch Makefile for your own machine.

For Ubuntu:
```
make noGUI WITH_FD=1 OS=Ubuntu -j $(nproc)
```

For RHEL-like distros (RHEL, CentOS, Fedora, ...):
```
make noGUI WITH_FD=1 OS=RHEL -j $(nproc)
```

After compilation, `gMultiwfn_noGUI` will be created, which is used for data processing.
