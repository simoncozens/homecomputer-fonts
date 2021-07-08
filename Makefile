help:
	@echo "###"
	@echo "# Build targets for the Homecomputer fonts"
	@echo "###"
	@echo
	@echo "  make build: Builds the fonts and places them in the fonts/ directory"
	@echo "  make test:  Tests the fonts with fontbakery"
	@echo "  make proof: Creates HTML proof documents in the proof/ directory"
	@echo

.PHONY: build
build: build.stamp build-64 build-wb fix-fonts webfonts

.PHONY: build-64
build-64: Sixtyfour/sources/config.yaml Sixtyfour/sources/Sixtyfour.glyphs

.PHONY: build-wb
build-wb: Workbench/sources/config.yaml Workbench/sources/Workbench.glyphs

venv: venv/touchfile

build.stamp: venv
	. venv/bin/activate; gftools builder Sixtyfour/sources/config.yaml && touch build.stamp
	. venv/bin/activate; gftools builder Workbench/sources/config.yaml && touch build.stamp

venv/touchfile: requirements.txt
	test -d venv || python3 -m venv venv
	. venv/bin/activate; pip install -Ur requirements.txt
	touch venv/touchfile

.PHONY: test
test: venv build.stamp
	. venv/bin/activate; fontbakery check-googlefonts --html fontbakery-report.html --ghmarkdown fontbakery-report.md $(shell find fonts -type f)

.PHONY: proof
proof: venv build.stamp
	. venv/bin/activate; gftools gen-html proof $(shell find fonts/variable -type f) -o proof

.PHONY: clean
clean:
	rm -f build.stamp

.PHONY: dist-clean
dist-clean:
	rm -rf venv
	find -iname "*.pyc" -delete

# .PHONY: update-designspace
# update-designspace:
# 	# Export a designspace + UFOs from the Glyphs file
# 	fontmake -g production/SixtyfourC.glyphs $(FONTMAKE_OPTIONS) --designspace-path master_ufo/Sixtyfour.designspace --output-path temp_out/Sixtyfour.ttf
# 	fontmake -g production/WorkbenchC.glyphs $(FONTMAKE_OPTIONS) --designspace-path master_ufo/Workbench.designspace --output-path temp_out/Workbench.ttf
# 	rm -f temp_out/Sixtyfour.ttf
# 	rm -f temp_out/Workbench.ttf

.PHONY: fix-fonts
fix-fonts:
	. venv/bin/activate; python scripts/fix_varfont.py

.PHONY: webfonts
webfonts: fonts/webfonts/Sixtyfour[BLED,SCAN].woff2 fonts/webfonts/Workbench[BLED,SCAN].woff2

fonts/webfonts/Sixtyfour[BLED,SCAN].woff2: build.stamp
	. venv/bin/activate; python scripts/2woff.py fonts/variable/Sixtyfour[BLED,SCAN].ttf

fonts/webfonts/Workbench[BLED,SCAN].woff2:
	. venv/bin/activate; python scripts/2woff.py fonts/variable/Workbench[BLED,SCAN].ttf
