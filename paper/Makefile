all:
	pdflatex -halt-on-error paper
	bibtex paper
	pdflatex -halt-on-error paper
clean:
	rm *.aux *.bbl *.blg *.log
