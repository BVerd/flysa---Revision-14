# CODE VERSION ######################################################

VERSION = 9.3.3beta

# executables to make

FLYEXECS = unfold printscore fly_sa scramble 

# FLAGS FOR -v FOR ALL EXECUTABLES ##################################
# this passes user and host name, compiler and version to the com-
# pile so it can be printed in the -v message of each executable

USRFLAG  = -DUSR=\"$(USER)\"
HOSTFLAG = -DMACHINE=\"$(HOST)\"
COMPFLAG = -DCOMPILER=\"$(CC)\"
FLAGFLAG = -DFLAGS=\"optimized\"
VERSFLAG = -DVERS=\"$(VERSION)\"

VFLAGS = $(USRFLAG) $(HOSTFLAG) $(COMPFLAG) $(FLAGFLAG) $(VERSFLAG) 

# find out about which architecture we're on and set compiler 
# accordingly

ifneq (,$(findstring linux,$(OSTYPE)))
#ifeq ($(OSTYPE),linux)

	# if running on RES then:
	# 'make deps' with gcc + openmpi
        # 'make' always with xlc + /usr/bin/mpicc

    	MPICC = /usr/bin/mpicc
	#MPICC = /gpfs/apps/OPENMPI/1.5.3/GCC/64/bin/mpicc
    	GSL_PATH = /gpfs/apps/GSL/64
    	SUNDIALS_PATH = /gpfs/apps/SUNDIALS/2.6.0/64
    	#CC = gcc
	CC = xlc
	MPIFLAGS = -DMPI
	DEBUGFLAGS = $(DEBUGFLAGS) -DMPI
	PROFILEFLAGS = $(PROFILEFLAGS) -DMPI
	FLYEXECS = unfold printscore fly_sa scramble fly_sa.mpi

endif

ifeq ($(OSTYPE),osf1)
	CC = cc
endif

# find the compiler and set corresponding flags

ifeq ($(CC),cc)
	CCFLAGS = -std1 -fast -DALPHA_DU -DNDEBUG
	DEBUGFLAGS = -std1 -O0 -g
	PROFILEFLAGS = -O2 -g1 
	LIBS = -lm -ldxml -lgsl -lgslcblas
	FLIBS = $(LIBS)
	KCC = /bin/kcc
	KFLAGS = -ckapargs=' -scalaropt=3 -optimize=5 -roundoff=3 -arl=4 '
# uncomment 2 lines below if you don't want kcc
#	KCC = $(CC)
#	KFLAGS = $(CCFLAGS)
endif

ifeq ($(CC),icc)
# lucas flags for profiling and debugging 2-6-03
# 	CCFLAGS = -O3 -DNDEBUG
    	CCFLAGS = -O3 -xW -tpp7 -ipo 
    	PRECFLAGS = -mp -prec_div -pc80 
#   	DEBUGFLAGS = -g  -inline_debug_info -O1  -xW -tpp7
    	DEBUGFLAGS = -g  -inline_debug_info -O0
#	DEBUGFLAGS = -g
#   	PROFILEFLAGS = -prof_dir profile_data -prof_gen -O2  -xW -tpp7
	PROFILEFLAGS = -p -qp -O2 -xW -tpp7
#   	USEPROFFLAGS = -prof_use  -prof_dir profile_data  -O3 -xW -tpp7 -ipo -opt_report
	LIBS = -limf -lgsl -lgslcblas
#	LIBS = -lm
	FLIBS = -limf -lgsl -lgslcblas -static
	KCC = $(CC)
	KFLAGS = $(CCFLAGS)
        export ICC = "yes"
endif

ifeq ($(CC),gcc)
	CCFLAGS = -Wall -g -m64 -O2 -std=gnu99 -DHAVE_SSE2
	LIBS = -lm -lgsl -lgslcblas -lsundials_cvode -lsundials_nvecserial
    	PROFILEFLAGS = -g -pg -O3
	LDFLAGS = -L$(GSL_PATH)/lib -L$(SUNDIALS_PATH)/lib
	FLIBS = -lm -lgsl -lgslcblas -lsundials_cvode -lsundials_nvecserial 
	KCC = $(CC)
	KFLAGS = $(CCFLAGS)
endif

ifeq ($(CC),xlc)
	CCFLAGS = -q64 -O3 -DNDEBUG -qstrict -qtune=ppc970 -qarch=ppc970 -qcache=auto -qaltivec
	DEBUGFLAGS = -q64 -Wall -g
        PROFILEFLAGS = -q64 -g -pg -O3
	LDFLAGS = -L$(GSL_PATH)/lib -L$(SUNDIALS_PATH)/lib
	LIBS = -lm -lgsl -lgslcblas -lsundials_cvode -lsundials_nvecserial
	FLIBS = -lm -lgsl -lgslcblas -lsundials_cvode -lsundials_nvecserial
	KCC = $(CC)
	KFLAGS = $(CCFLAGS)
endif

# debugging?

ifdef DEBUG
	CCFLAGS = $(DEBUGFLAGS)
	FLAGFLAG = -DFLAGS=\"debugging\"
else
	DEBUG = "Off"
endif

ifdef PROFILE
	CCFLAGS = $(PROFILEFLAGS)
	FLAGFLAG = -DFLAGS=\"profiling\"
	KCC = $(CC)
	KFLAGS =
else
	PROFILE = "Off"
endif

ifdef USEPROFILE
        CCFLAGS = $(USEPROFFLAGS)
endif

# export all variables that Makefiles in subdirs need

export INCLUDES = -I. -I../lam -I$(GSL_PATH)/include -I$(SUNDIALS_PATH)/include
export CFLAGS = $(CCFLAGS) $(INCLUDES)
export VFLAGS
export LDFLAGS
export CC
export KCC
export MPICC
export KFLAGS
export LIBS
export FLIBS
export MPIFLAGS
export FLYEXECS

#define targets

fly: lsa
	@cd fly && $(MAKE)

deps:   
	cd fly && $(MAKE) -f basic.mk Makefile

lsa:
	@cd lam && $(MAKE)

clean:
	rm -f core* *.o *.il
	rm -f */core* */*.o */*.il
	rm -f fly/unfold fly/printscore fly/scramble
	rm -f fly/fly_sa fly/fly_sa.mpi

veryclean:
	rm -f core* *.o *.il
	rm -f */core* */*.o */*.il */*.slog */*.pout */*.uout
	rm -f fly/unfold fly/printscore fly/scramble 
	rm -f fly/fly_sa fly/fly_sa.mpi
	rm -f lam/gen_deviates
	rm -f fly/Makefile
	rm -f fly/zygotic.cmp.c

help:
	@echo "make: this is the Makefile for fly code"
	@echo "      always 'make deps' first after a 'make veryclean'"
	@echo ""
	@echo "      the following targets are available:"
	@echo "      lsa:       make object files in the lam directory only"
	@echo "      fly:       compile the fly code (which is in 'fly')"
	@echo "      clean:     gets rid of cores and object files"
	@echo "      veryclean: gets rid of executables and dependencies too"
	@echo ""
	@echo "      your current settings are:"   
	@echo "      compiler:  $(CC)"
	@echo "      flags:     $(CFLAGS)"
	@echo "      debugging: $(DEBUG)"
	@echo "      profiling: $(PROFILE)"
	@echo ""

