.PHONY: format check

check:

format:
	stylua lua 
	stylua --check lua

