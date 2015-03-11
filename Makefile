all: bin/gmain bin/main

FLAGS=-std=c++11 -g
SRC=$(wildcard src/*.cc)
HEAD=$(wildcard src/*.hh)

bin/main: $(SRC) $(HEAD)
	g++ -O3 $(FLAGS) $(SRC) -o bin/main

bin/gmain: $(SRC) $(HEAD)
	g++ -g $(FLAGS) $(SRC) -o bin/gmain
