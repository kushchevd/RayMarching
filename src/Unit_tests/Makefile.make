CC = g++
CCFLAGS = -c -std=c++20

all: tests

tests: mainTests.o UnitTest.o parseTest.o includeTest.o parse.o lunclude.o 
	$(CC) mainTests.o UnitTest.o parseTest.o includeTest.o parse.o lunclude.o -o tests

mainTests.o: mainTests.cpp
	$(CC) $(CCFLAGS) mainTests.cpp -o mainTests.o

UnitTest.o: UnitTest.cpp
	$(CC) $(CCFLAGS) UnitTest.cpp -o UnitTest.o

parseTest.o: parseTest.cpp
	$(CC) $(CCFLAGS) parseTest.cpp -o parseTest.o

includeTest.o: includeTest.cpp
	$(CC) $(CCFLAGS) includeTest.cpp -o includeTest.o

parse.o: ../include/parse.cpp
	$(CC) $(CCFLAGS) ../include/parse.cpp -o parse.o

lunclude.o: ../include/lunclude.cpp
	$(CC) $(CCFLAGS) ../include/lunclude.cpp -o lunclude.o	

clean:
	rm -rf *.o tests