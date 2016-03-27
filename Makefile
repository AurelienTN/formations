#
#  Usage:
#  make $cours.pdf
#  make $cours-handout.pdf
#  make $cours-print.pdf
#  make $cours.html
#
#  Optional:
#  make build/$cours.md
#  make build/$cours.tex
#

# Dependencies: pandoc
#               pdflatex
#               texlive-extra-utils (pdfnup)

# Definition of cours based on modules
cours=cours/list.md
# Where to get revealjs stuff
revealjsurl=http://formation.osones.com/revealjs

help: ## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

all: ## Build all pdf cours
all: openstack.pdf docker.pdf

build/Makefile:
	mkdir -p build
	sed -E 's#^(.*):(.*)#build/\1.md: $$(addprefix cours/, \2)\n\t$$(foreach module,$$^,cat $$(module) >> $$@;)#' $(cours) > build/Makefile

-include build/Makefile

build/%.tex: build/%.md
	pandoc $< -t beamer -f markdown -s -o $@ --slide-level 3 -V navigation=frame
	sed -i 's,\\{width=``.*},,' $@ # workaround
	sed -i 's,\\{height=``.*},,' $@

build/%-handout.tex: build/%.md
	pandoc $< -t beamer -f markdown -s -o $@ --slide-level 3 -V navigation=frame -V handout
	sed -i 's,\\{width=``.*},,' $@
	sed -i 's,\\{height=``.*},,' $@

%.html: build/%.md ## Build cours "%" in html/revealjs, optional argument revealjsurl=<url to revealjs>
	pandoc $< -t revealjs -f markdown -s -o $@ --slide-level 3 -V theme=osones -V navigation=frame -V revealjs-url=$(revealjsurl) -V slideNumber="true"

%.pdf: build/%.tex ## Build cours "%" in beamer/pdf
	pdflatex -output-directory build/ $<
	pdflatex -output-directory build/ $<
	mv build/$@ $@

%-print.pdf: %.pdf ## Build cours "%" in beamer/pdf, print (4 slides / page) version
	pdfnup --nup 2x2 --frame true --suffix print $<

clean: ## Remove build files
	rm -rf build/

mrproper: ## Remove build files and .html/.pdf files
mrproper: clean
	rm -f *.pdf
	rm -f *.html
