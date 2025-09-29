.DEFAULT_GOAL := all

figures = fig/cstate-latencies/C_state_latencies.pdf

tikz = fig/core-layout/socket0_tikz.pdf fig/core-layout/socket1_tikz.pdf

%.pdf : %.eps
	gs -dUsePDFX3Profile=1 -dBATCH -dNOPAUSE -sProcessColorModel=DeviceCMYK -dEPSCrop -sDEVICE=pdfwrite -sOutputFile=$@ $<

%.pdf : %.tikz
	pdflatex -output-directory=$$(dirname $<) $<

fig: $(figures) $(tikz)

all: fig
	pdflatex -halt-on-error main
	bibtex main
	pdflatex -halt-on-error main
	gs -dUsePDFX3Profile=1 -dBATCH -dNOPAUSE -sProcessColorModel=DeviceCMYK -sDEVICE=pdfwrite -sOutputFile=main_pdfx.pdf main.pdf
	gs -dPDFA -dBATCH -dNOPAUSE -dUseCIEColor -sProcessColorModel=DeviceCMYK -sDEVICE=pdfwrite -dPDFACompatibilityPolicy=1 -sOutputFile=main_pdfa.pdf main.pdf

clean:
	rm *.aux *.bbl *.blg *.log *.lot *.out *.run.xml *.toc *.lof main-blx.bib || true
