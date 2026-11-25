# Something from the Past
#
# Data/ contains the canonical, prebuilt plugin. Compile the complete PSL
# directly, archive its PEX in a plugin-named GNRL BA2, then package both.
# No ESP editing tools or game installation are required to build a release.
#
#   make            compile the PSL and build the release 7z
#   make pex        only compile the PSL
#   make package    compile, verify, and build the release 7z
#   make version    print the version derived from the nearest Git tag
#   make clean      remove build outputs and dist/
#
# Versioning is tag-driven: tag the repository (without a leading "v") to
# produce a release version. Otherwise Git's describe output is used.

SHELL := /bin/bash

NAME    := somethingfromthepast
VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null | sed 's/^v//' || echo 0.0.0)

F4SE_SCRIPTS ?= third_party/f4se/scripts
HEADERS      ?= $(BUILD)/headers
FLAGS        ?= $(HEADERS)/Institute_Papyrus_Flags.flg
SRC          := scripts/fcNCR_HandMeDown.psl
ESP          := Data/fallchildrens_ncr_armor_redux.esp

BUILD   := build
STAMP   := $(BUILD)/.stamp
TOOLS   := $(BUILD)/toolchain
SCRIPTS := $(BUILD)/scripts
STAGE   := $(BUILD)/package
BA2     := fallchildrens_ncr_armor_redux - Main.ba2
FO4TOOLS_ROOT ?= third_party/fo4tools
PYTHON := PYTHONPATH="$(abspath $(FO4TOOLS_ROOT)):$$PYTHONPATH" python3
DIST    := dist/$(NAME)-$(VERSION).7z

LOCAL_JEZEBEL := ../jezebel/bin/jezebel
JEZEBEL_VERSION ?= 0.1.0
JEZEBEL ?= $(if $(wildcard $(LOCAL_JEZEBEL)),$(LOCAL_JEZEBEL),$(TOOLS)/jezebel/jezebel)

JEZEBEL_ASSET := jezebel-$(JEZEBEL_VERSION)-linux-amd64.tar.gz
JEZEBEL_URL   := https://github.com/fallchildren/jezebel/releases/download/$(JEZEBEL_VERSION)/$(JEZEBEL_ASSET)

.PHONY: all headers pex package version clean

all: package

headers: $(FLAGS)

$(STAMP)/submodules: .gitmodules | $(STAMP)
	git submodule update --init --recursive
	@touch $@

$(STAMP):
	mkdir -p $@

$(FLAGS): $(STAMP)/submodules tools/merge_headers.py
	python3 tools/merge_headers.py $(F4SE_SCRIPTS) $(HEADERS)

pex: $(SCRIPTS)/fcNCR_HandMeDown.pex

$(SCRIPTS)/fcNCR_HandMeDown.pex: $(SRC) $(JEZEBEL) $(FLAGS)
	mkdir -p $(SCRIPTS)
	$(JEZEBEL) -q -I $(HEADERS) -f $(FLAGS) -o $(SCRIPTS) $(SRC)
	test -f $@
	test -f $(SCRIPTS)/fcNCR_HandMeDown.psc

package: pex $(ESP) $(STAMP)/submodules
	rm -rf $(STAGE) $(BUILD)/archive-input
	mkdir -p $(STAGE)/Data $(BUILD)/archive-input/Scripts
	cp $(ESP) $(STAGE)/Data/
	cp $(SCRIPTS)/fcNCR_HandMeDown.pex $(BUILD)/archive-input/Scripts/
	$(PYTHON) -m fo4tools.cli ba2 pack "$(STAGE)/Data/$(BA2)" $(BUILD)/archive-input
	$(PYTHON) tools/verify_archive.py "$(STAGE)/Data/$(BA2)" $(SCRIPTS)/fcNCR_HandMeDown.pex
	mkdir -p $(dir $(DIST))
	rm -f $(DIST)
	cd $(STAGE) && 7z a -t7z -mx=9 $(abspath $(DIST)) Data >/dev/null
	7z t $(DIST) >/dev/null
	@echo "created $(DIST)"

$(LOCAL_JEZEBEL):
	@if [ -x "$(LOCAL_JEZEBEL)" ]; then :; else \
	  echo "error: $(LOCAL_JEZEBEL) not found"; \
	  echo "       set JEZEBEL=/path/to/jezebel or JEZEBEL_VERSION=<release>"; \
	  exit 1; \
	fi

$(TOOLS)/jezebel/jezebel:
	@set -eu; \
	tmp=$$(mktemp -d); \
	trap 'rm -rf "$$tmp"' EXIT; \
	echo "downloading Jezebel $(JEZEBEL_VERSION)"; \
	curl -fsSL "$(JEZEBEL_URL)" -o "$$tmp/$(JEZEBEL_ASSET)"; \
	curl -fsSL "$(JEZEBEL_URL).sha256" -o "$$tmp/$(JEZEBEL_ASSET).sha256"; \
	(cd "$$tmp" && sha256sum -c "$(JEZEBEL_ASSET).sha256"); \
	mkdir -p "$(TOOLS)/jezebel"; \
	tar -xzf "$$tmp/$(JEZEBEL_ASSET)" -C "$(TOOLS)/jezebel"; \
	chmod +x "$@"

version:
	@echo $(VERSION)

clean:
	rm -rf $(BUILD) dist
