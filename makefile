FILENAME=etapa1
SCANNER=lex.yy.c

IDIR=include
CC=gcc
CFLAGS=-I$(IDIR)

ODIR=obj

LIBS=-lm

DEPS = $(SCANNER)

_OBJ = main.o lex.yy.o
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))

$(ODIR)/%.o: %.c $(DEPS)
	mkdir -p $(ODIR)
	$(CC) -c -o $@ $< $(CFLAGS)

all: $(FILENAME)

run: all
	./$(FILENAME)

$(SCANNER): scanner.l
	flex scanner.l

$(FILENAME): $(OBJ) 
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS)	

entrega: all clean
	tar cvzf $(FILENAME).tgz -X .tarignore .

.PHONY: clean

clean:
	rm -f $(ODIR)/*.o *~ core $(INCDIR)/*~
	rm -f $(FILENAME).tgz
	rm -f $(FILENAME)
	rm -f lex.yy.c