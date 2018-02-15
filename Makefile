#
# This file is part of the OutMessage.Nested Elm library and is released
# under a MIT license (see LICENSE file).
#
# Author(s) / Copyright(s): Bruno Girin, imby.bio 2018
#

#
# Variables
#

# Directories
SRC_DIR = src
NODE_MODULES = $(abspath node_modules)
NODE_BIN_DIR = $(NODE_MODULES)/.bin
ELM_STUFF = $(abspath elm_stuff)

# Build tools
ELM_MAKE = $(NODE_BIN_DIR)/elm-make
ELM_TEST = $(NODE_BIN_DIR)/elm-test
ELM_PACKAGE = $(NODE_BIN_DIR)/elm-package
JQ = jq

# Sources
ELM_SOURCE = $(SRC_DIR)/CachedRemoteData.elm

# Version
ELM_PACKAGE_JSON = $(abspath elm-package.json)
VERSION := $(shell $(JQ) --raw-output '.version' $(ELM_PACKAGE_JSON))


#
# Targets
#

all: compile

$(NODE_MODULES):
	npm install elm elm-test

compile: $(NODE_MODULES)
	$(ELM_MAKE) --yes $(ELM_SOURCE)

test: $(NODE_MODULES)
	PATH=$(PATH):$(NODE_BIN_DIR) $(ELM_TEST)

clean:
	rm -rf $(NODE_MODULES)
	rm -rf $(ELM_STUFF)


# Package management targets

bump: $(NODE_MODULES)
	$(ELM_PACKAGE) bump

tag: $(NODE_MODULES)
	git tag -a $(VERSION) -m "Release version $(VERSION)"
	git push origin $(VERSION)

publish: $(NODE_MODULES)
	$(ELM_PACKAGE) publish
