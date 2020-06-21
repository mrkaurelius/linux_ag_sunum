compile:
	pandoc -s -V papersize:a4 -H disable_float.tex sunum.md --pdf-engine=xelatex -o sunum.pdf 
