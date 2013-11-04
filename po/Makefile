# the domain name for rgettext
PGOAL = booh

# ruby files to search translatable strings in
RB_FILES = ../bin/booh ../bin/booh-classifier ../lib/booh/html-merges.rb ../bin/booh-backend ../lib/booh/booh-lib.rb ../lib/booh/UndoHandler.rb $(wildcard ../data/booh/themes/*/metadata/parameters.rb)

POFILES = $(wildcard *.po)

all: $(PGOAL).pot

merge: $(PGOAL).pot
	@for n in $(POFILES); do \
		echo "Merging $$n"; \
		msgmerge "$$n" $< > "$$n"t; \
		mv -f "$$n"t "$$n"; \
	done

$(PGOAL).pot: $(RB_FILES)
	rm -f $@
	rgettext -o $@ $(RB_FILES)
	perl -pi -e 's/, , \[ or \], sorry/, \\", [ or ], sorry/' $@ 

clean:
	@rm -rf $(PGOAL).pot
