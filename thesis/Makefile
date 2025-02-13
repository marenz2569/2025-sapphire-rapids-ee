all:
	pdflatex -halt-on-error main
	bibtex main
	pdflatex -halt-on-error main
clean:
	rm *.aux *.bbl *.blg *.log
