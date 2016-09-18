DOC=bauer_thesis
SHELL=/bin/bash

# dependences
INCLUDE_TEX= abstract.tex \
	     acknowledgement.tex \
	     intro.tex model.tex \
	     arch.tex \
	     logical.tex \
	     physical.tex \
	     mapping.tex \
	     deferred.tex \
	     resilience.tex \
	     distributed.tex \
	     garbage.tex \
	     relaxed.tex \
	     s3d.tex \
	     related.tex \
	     conclusion.tex

INCLUDE_FIGS=$(wildcard figs/*.pdf)

all: $(DOC).pdf

$(DOC).pdf: $(DOC.tex) bibliography.bib $(INCLUDE_TEX) $(INCLUDE_FIGS)

%.pdf: %.tex bibliography.bib
	pdflatex -halt-on-error $*.tex
	(if grep -q bibliography $*.tex; \
	then \
		bibtex $*; \
		pdflatex -halt-on-error $*.tex; \
	fi)
	pdflatex -halt-on-error $*.tex

%.pdf: %.tex
	pdflatex -halt-on-error $*.tex
	pdflatex -halt-on-error $*.tex

FIGS_AS_EPS := $(patsubst %.pdf,%.eps,$(wildcard figs/*.pdf))

figs/%.eps: figs/%.pdf
	pdftops -r 2400 -eps $^ $@

figs_as_eps: $(FIGS_AS_EPS)

%.dvi: %.tex bibliography.bib figs_as_eps
	pdflatex -output-format dvi -halt-on-error $*.tex
	bibtex $*
	pdflatex -output-format dvi -halt-on-error $*.tex
	pdflatex -output-format dvi -halt-on-error $*.tex

%.ps : %.dvi
	dvips $^

spelling :
	for f in *.tex; do aspell -p ./aspell.en.pws --repl=./aspell.en.prepl -c $$f; done

clean:
	rm -f *.bbl *.aux *.log *.blg *.lot *.lof *.dvi *.toc $(DOC).pdf $(DOC)-ext.pdf

