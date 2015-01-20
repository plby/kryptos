all: bin/main

FLAGS=-std=c++11 -g
SRC=$(wildcard src/*.cc)
HEAD=$(wildcard src/*.hh)

bin/main: $(SRC) $(HEAD)
	g++ $(FLAGS) $(SRC) -o bin/main
