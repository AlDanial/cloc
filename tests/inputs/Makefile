############################################################################
#
#  Program:         ARPACK
#
#  Module:          Makefile
#
#  Purpose:         Sources Makefile
#
#  Creation date:   February 22, 1996
#
#  Modified:a       September 9, 1996
#
#  Send bug reports, comments or suggestions to arpack.caam.rice.edu
#
############################################################################
#\SCCS Information: @(#) 
# FILE: Makefile   SID: 2.2   DATE OF SID: 9/24/96   RELEASE: 2
 
include ../ARmake.inc
 
############################################################################
#  To create or add to the library, enter make followed by one or
#  more of the precisions desired.  Targets sdrv, ddrv, cdrv,
#  zdrv are used to add to the library LAPACK routines needed by driver
#  programs in the EXAMPLES directory.
#
#  Some examples:
#       make single
#       make single sdrv
#       make single complex
#       make single double complex complex16
#  Alternatively, the command
#       make
#  without any arguments creates a library of all four precisions.
#  The library also contains all extra BLAS routines used by driver
#  programs in the EXAMPLES directory.
#
#  The name of the library is defined by $(ARPACKLIB) in
#  ../ARmake.inc and is created at the next higher directory level.
#
#
SOBJ  = sgeqr2.o slabad.o slacon.o slacpy.o sladiv.o slae2.o slaev2.o\
        slaexc.o slagtm.o slahqr.o slaln2.o slamch.o slange.o slanhs.o\
        slanst.o slanv2.o slaptm.o slapy2.o slapy3.o slaran.o slarf.o\
        slarfg.o slarfx.o slarnd.o slarnv.o slartg.o slaruv.o slascl.o\
        slaset.o slasr.o  slasrt.o slassq.o slasy2.o sorm2r.o ssteqr.o\
        strevc.o strexc.o strsen.o strsyl.o

DOBJ  = dgeqr2.o dlabad.o dlacon.o dlacpy.o dladiv.o dlae2.o dlaev2.o\
        dlaexc.o dlagtm.o dlahqr.o dlaln2.o dlamch.o dlange.o dlanhs.o\
        dlanst.o dlanv2.o dlaptm.o dlapy2.o dlapy3.o dlaran.o dlarf.o\
        dlarfg.o dlarfx.o dlarnd.o dlarnv.o dlartg.o dlaruv.o dlascl.o\
        dlaset.o dlasr.o  dlasrt.o dlassq.o dlasy2.o dorm2r.o dsteqr.o\
        dtrevc.o dtrexc.o dtrsen.o dtrsyl.o

IOBJ  = ilaenv.o lsame.o lsamen.o xerbla.o xlaenv.o

CIOBJ = icmax1.o 

ZIOBJ = izmax1.o

COBJ  = cgeqr2.o clacon.o clacpy.o cladiv.o clahqr.o clange.o clanhs.o\
        clarf.o  clarfg.o clarnv.o clartg.o clascl.o claset.o classq.o\
        clatrs.o cmach.o  crot.o   ctrevc.o ctrexc.o ctrsen.o ctrsyl.o\
        cunm2r.o\
        scsum1.o slabad.o sladiv.o slamch.o slapy2.o slapy3.o slaruv.o

ZOBJ  = zgeqr2.o zlacon.o zlacpy.o zladiv.o zlahqr.o zlange.o zlanhs.o\
        zlarf.o  zlarfg.o zlarnv.o zlartg.o zlascl.o zlaset.o zlassq.o\
        zlatrs.o zmach.o  zrot.o   ztrevc.o ztrexc.o ztrsen.o ztrsyl.o\
        zunm2r.o\
        dzsum1.o dlabad.o dladiv.o dlamch.o dlapy2.o dlapy3.o dlaruv.o
#
# The following LAPACK routines are not needed by ARPACK
# source code.  They are used by the drivers in EXAMPLES
# directory.
#
SDRVOBJ = sgbtf2.o sgbtrf.o sgbtrs.o sgttrf.o sgttrs.o spttrf.o spttrs.o\
          slaswp.o  

DDRVOBJ = dgbtf2.o dgbtrf.o dgbtrs.o dgttrf.o dgttrs.o dpttrf.o dpttrs.o\
          dlaswp.o

CDRVOBJ = cgbtf2.o cgbtrf.o cgbtrs.o cgttrf.o cgttrs.o claswp.o clacgv.o

ZDRVOBJ = zgbtrf.o zgbtrs.o zgbtf2.o zgttrf.o zgttrs.o zlaswp.o zlacgv.o

.SUFFIXES:      .o .F .f

.f.o:
	$(FC) $(FFLAGS) -c $<

all: single double complex complex16 sdrv ddrv cdrv zdrv
 
single: $(SOBJ) $(IOBJ)
	$(AR) $(ARFLAGS) $(ARPACKLIB) $(SOBJ) $(IOBJ)
	$(RANLIB) $(ARPACKLIB)
 
double: $(DOBJ) $(IOBJ)
	$(AR) $(ARFLAGS) $(ARPACKLIB) $(DOBJ) $(IOBJ)
	$(RANLIB) $(ARPACKLIB)

complex: $(COBJ) $(CIOBJ) $(IOBJ)
	$(AR) $(ARFLAGS) $(ARPACKLIB) $(COBJ) $(CIOBJ) $(IOBJ)
	$(RANLIB) $(ARPACKLIB)

complex16: $(ZOBJ) $(ZIOBJ) $(IOBJ)
	$(AR) $(ARFLAGS) $(ARPACKLIB) $(ZOBJ) $(ZIOBJ) $(IOBJ)
	$(RANLIB) $(ARPACKLIB) 
#
# Add routines needed by driver programs (in the EXAMPLES
# directory) to $(ARPACKLIB).
#
sdrv: $(SDRVOBJ) $(CDRVOBJ)
	$(AR) $(ARFLAGS) $(ARPACKLIB) $(SDRVOBJ) $(CDRVOBJ)
	$(RANLIB) $(ARPACKLIB)

ddrv: $(DDRVOBJ) $(ZDRVOBJ)
	$(AR) $(ARFLAGS) $(ARPACKLIB) $(DDRVOBJ) $(ZDRVOBJ)
	$(RANLIB) $(ARPACKLIB)

cdrv: $(CDRVOBJ)
	$(AR) $(ARFLAGS) $(ARPACKLIB) $(CDRVOBJ)
	$(RANLIB) $(ARPACKLIB)

zdrv: $(ZDRVOBJ)
	$(AR) $(ARFLAGS) $(ARPACKLIB) $(ZDRVOBJ)
	$(RANLIB) $(ARPACKLIB)

#  clean	- remove all object files
#
clean:
	rm -f *.o a.out core
