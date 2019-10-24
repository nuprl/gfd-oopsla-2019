all: paper.pdf 

fast: paper.tex bib.bib pf2.sty def.tex package.tex
	pdflatex paper.tex && \
	open paper.pdf && \
	echo "done"


report: tr.tex bib.bib pf2.sty def.tex package.tex tr-common.tex tr-N.tex tr-T.tex tr-A.tex tr-N-proof.tex tr-A-proof.tex tr-NA-proof.tex tr-AT-proof.tex
	pdflatex tr.tex && \
	open tr.pdf && \
	echo "done"


paper.pdf:	paper.tex bib.bib pf2.sty def.tex package.tex
	pdflatex paper && \
	bibtex paper && \
	pdflatex paper && \
	pdflatex paper && \
	echo "done, fully" 

tr.pdf:	tr.tex bib.bib pf2.sty def.tex package.tex tr-common.tex tr-N.tex tr-A.tex tr-T.tex tr-N-proof.tex tr-T-proof.tex tr-A-proof.tex tr-NA-proof.tex tr-AT-proof.tex
	latexmk -silent --pdf $<

# builds the paper using `latexmk` to avoid re-compiling
ben:	paper.tex bib.bib cs.bib pf2.sty def.tex package.tex introduction.tex motivation.tex surface.tex semantics.tex satisfies.tex related.tex conclusion.tex
	latexmk -silent --pdf $<

tal:
	pdflatex types-as-labels.tex

clean:
	latexmk -C
