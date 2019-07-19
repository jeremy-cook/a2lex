# the compiler: gcc for C program, define as g++ for C++
CC = gcc

# compiler flags:
#  -g    adds debugging information to the executable file
#  -Wall turns on most, but not all, compiler warnings
# CFLAGS  = -g -Wall

# the build target executable:
FLEX = a2lex.l
flex : $(FLEX) a2lex.tab.h a2l.h
    flex $(FLEX) -o $(FLEX).yy.c

