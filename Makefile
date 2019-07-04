all : book

clean :
	rm -f index.html
	rm -f bin/sample-code-checker

test : cpptest


cpptest : test-tool
	bin/sample-code-checker book/*.md

retest : test-tool
	bin/sample-code-checker retest /tmp/sample-code-checker/*.cpp

test-tool : bin/sample-code-checker

bin/sample-code-checker : bin/sample-code-checker.cpp
	g++ -D _ISOC11_SOURCE -std=c++17 --pedantic-errors -Wall -pthread -O2 -o bin/sample-code-checker  bin/sample-code-checker.cpp

book : docs/index.html


docs/index.html : book/*.md book/style.css
	pandoc -s --toc --toc-depth=6 "--mathjax=https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/latest.js?config=TeX-MML-AM_CHTML" -o $@ -H book/style.css  book/pandoc_title_block book/*.md


index.md : book/*.md
	pandoc -s --toc --toc-depth=6 --mathjax -o $@ -H book/style.css  book/pandoc_title_block book/*.md



SLIDE_SRC := slide/*.md
SLIDE_HTML :=$(SLIDE_SRC:%.md=%.html)

slide : SLIDE_HTML

slide/%.html : slide/%.md
	pandoc -t revealjs -s --variable transition-fade -o $@ &<


.PHONY : all book clean test test-tool texttest cpptest retest slide
