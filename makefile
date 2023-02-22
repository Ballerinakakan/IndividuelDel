.DEFAULT_GOAL := all

create_build_folder:
	mkdir -p build

copy_sources: create_build_folder
	@rsync -a src/ build/


# A few different compilation options are provided. Change default
# target by changing this line:
all: compile-rubber

# The default - rubber, is a bit more complex, and requires a few
# extra packages to be installed. However, it provides readable error
# messages Note: rubber has wonky support for biber, as a workaround
# we run pdflatex once, trigger a biber run, and then let rubber do
# its thing.
#
# You can trigger this manually using `$ make compile-rubber`.
compile-rubber: copy_sources
	cd build; pdflatex report.tex >pdflatex.log 2>&1 || true
	cd build; biber report >biber.log || true
	cd build; rubber --pdf report.tex

# There is also the option to use latexmk, for a more portable
# solution, but without readable error messages.
#
# You can trigger this manually using `$ make compile-latexmk`.
compile-latexmk: copy_sources
	cd build; latexmk -pdf -interaction=nonstopmode report.tex

# Use for debugging, extra output
debug: clean copy_sources
	cd build; pdflatex report.tex || true
	cd build; biber report || true
	cd build; rubber --pdf -Wall -vvv report.tex

# Continuously watch for changes
#
# Note that this will be done *in tree*!
watch:
	cd src; latexmk -pdf -pvc -interaction=nonstopmode report.tex

view: all
	@okular build/report.pdf

clean:
	rm -rf build/
