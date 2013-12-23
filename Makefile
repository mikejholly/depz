all: build
	coffee -p -c index.coffee > o
	cat head o > index.js
	rm o

.PHONY: all build
