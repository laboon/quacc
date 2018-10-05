#!/usr/bin/env python

import os, sys

def main():
	
	f = open(sys.argv[1], "r")
	lines = f.readlines()
	f.close()
	
	lastline = lines[len(lines)-1].split()
	f = open(sys.argv[1], "w")
	f.write(lastline[0] + " " + lastline[2])
	f.close()

if __name__ == '__main__':
	main()

