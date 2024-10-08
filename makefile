FILENAME=etapa6
SCANNER=lex.yy.c
PARSER=parser.tab.c parser.tab.h parser.output

IDIR=include
CC=gcc
CFLAGS=-I$(IDIR) -g

ODIR=obj

LIBS=

DEPS = $(PARSER) $(SCANNER)

_OBJ = main.o lex.yy.o parser.tab.o ast.o types.o tables.o error.o lex_value.o iloc.o
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))

$(ODIR)/%.o: %.c $(DEPS)
	mkdir -p $(ODIR)
	$(CC) -c -o $@ $< $(CFLAGS)

all: $(FILENAME)

$(SCANNER): $(PARSER) scanner.l
	flex scanner.l

$(PARSER): parser.y
	bison -d parser.y

$(FILENAME): $(OBJ) 
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS)	

entrega: all clean
	tar cvzf $(FILENAME).tgz -X .tarignore .

test: all
	./$(FILENAME) < tests/teste3.txt > o.s
	$(CC) o.s -o programa
	./programa

.PHONY: clean

clean:
	rm -f $(ODIR)/*.o *~ core $(INCDIR)/*~
	rm -f *.tgz
	rm -f $(FILENAME)
	rm -f $(PARSER)
	rm -f $(SCANNER)
	rm -f o.s
	rm -f programa