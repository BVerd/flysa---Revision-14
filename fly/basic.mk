# DO NOT CHANGE ANYTHING HERE!!! ##################################
# (unless you know *exactly* what you're doing...) 


#fly_sa objects
FOBJ = zygotic.o fly_io.o maternal.o integrate.o translate.o \
         ../lam/error.o ../lam/distributions.o ../lam/random.o ../lam/ioTools.o solvers.o score.o ../lam/dSFMT.o ../lam/dSFMT_str_state.o
# serial code
FSOBJ = moves.o fly_sa.o ../lam/lsa.o savestate.o
# parallel code
FPOBJ = moves-mpi.o fly_sa-mpi.o ../lam/lsa-mpi.o savestate-mpi.o


#printscore objects
POBJ = zygotic.o fly_io.o maternal.o integrate.o translate.o \
       ../lam/error.o ../lam/distributions.o ../lam/random.o ../lam/ioTools.o solvers.o score.o printscore.o ../lam/dSFMT.o ../lam/dSFMT_str_state.o

#unfold objects
UOBJ = zygotic.o fly_io.o maternal.o integrate.o translate.o \
	 ../lam/error.o ../lam/distributions.o ../lam/random.o ../lam/ioTools.o solvers.o score.o unfold.o ../lam/dSFMT.o ../lam/dSFMT_str_state.o

#scramble objects
SOBJ = zygotic.o fly_io.o maternal.o integrate.o translate.o \
	 ../lam/error.o ../lam/distributions.o ../lam/random.o ../lam/ioTools.o solvers.o score.o scramble.o ../lam/dSFMT.o ../lam/dSFMT_str_state.o

SOURCES = `ls *.c`

#Below here are the rules for building things

all: $(FLYEXECS)

# special cases: dependencies and flags for individual .c files

fly_sa.o: fly_sa.c
	$(CC) -c $(CFLAGS) $(VFLAGS) fly_sa.c

printscore.o: printscore.c
	$(CC) -c $(CFLAGS) $(VFLAGS) printscore.c

scramble.o: scramble.c
	$(CC) -c $(CFLAGS) $(VFLAGS) scramble.c

unfold.o: unfold.c
	$(CC) -c $(CFLAGS) $(VFLAGS) unfold.c

zygotic.o: zygotic.c
	$(CC) -c $(CFLAGS) $(KFLAGS) zygotic.c


# parallel stuff

fly_sa-mpi.o: fly_sa.c
	$(MPICC) -c -o fly_sa-mpi.o $(MPIFLAGS) $(CFLAGS) $(VFLAGS) fly_sa.c

lsa-mpi.o: ../lam/lsa.c
	$(MPICC) -c -o ../lam/lsa-mpi.o $(MPIFLAGS) $(CFLAGS) ../lam/lsa.c

moves-mpi.o: moves.c 
	$(MPICC) -c -o moves-mpi.o $(MPIFLAGS) $(CFLAGS) moves.c

savestate-mpi.o: savestate.c
	$(MPICC) -c -o savestate-mpi.o $(MPIFLAGS) $(CFLAGS) savestate.c

# executable targets: serial ...

fly_sa: $(FOBJ) $(FSOBJ)
	$(CC) -o fly_sa $(CFLAGS) $(LDFLAGS) $(FOBJ) $(FSOBJ) $(FLIBS) 

printscore: $(POBJ)
	$(CC) -o printscore $(CFLAGS) $(LDFLAGS) $(POBJ) $(LIBS) 

unfold: $(UOBJ)
	$(CC) -o unfold $(CFLAGS) $(LDFLAGS) $(UOBJ) $(LIBS) 

scramble: $(SOBJ)
	$(CC) -o scramble $(CFLAGS) $(LDFLAGS) $(SOBJ) $(LIBS) 

# ... and parallel

fly_sa.mpi: $(FOBJ) $(FPOBJ)
	$(MPICC) -o fly_sa.mpi $(CFLAGS) $(LDFLAGS) $(FOBJ) $(FPOBJ) $(FLIBS)

# ... and here are the cleanup and make deps rules

clean:
	rm -f *.o core*

Makefile: ${FRC}
	rm -f $@
	cp basic.mk $@
	echo "#Automatically generated dependencies list#" >> $@
	${CC} $(INCLUDES) -M ${SOURCES} >> $@
	chmod -w $@

