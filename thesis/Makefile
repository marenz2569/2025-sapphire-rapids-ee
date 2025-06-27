figures = fig/C_state_latencies.pdf

%.pdf : %.eps
	gs -dUsePDFX3Profile=1 -dBATCH -dNOPAUSE -sProcessColorModel=DeviceCMYK -dEPSCrop -sDEVICE=pdfwrite -sOutputFile=$@ $<


fig: $(figures)

all: fig
	pdflatex -halt-on-error main
	bibtex main
	pdflatex -halt-on-error main
	gs -dUsePDFX3Profile=1 -dBATCH -dNOPAUSE -sProcessColorModel=DeviceCMYK -sDEVICE=pdfwrite -sOutputFile=main_pdfx.pdf main.pdf

clean:
	rm *.aux *.bbl *.blg *.log *.lot *.out *.run.xml *.toc *.lof main-blx.bib || true
