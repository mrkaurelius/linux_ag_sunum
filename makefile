compile:
	pandoc -s -V  papersize:a4 -H disable_float.tex -V geometry:margin=1in sunum.md --pdf-engine=xelatex -o sunum.pdf 
