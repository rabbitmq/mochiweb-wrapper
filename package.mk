APP_NAME:=mochiweb

UPSTREAM_GIT:=http://github.com/mochi/mochiweb.git
UPSTREAM_REVISION:=d541e9a0f36c00dcadc2e589f20e47fbf46fc76f
RETAIN_ORIGINAL_VERSION:=true
WRAPPER_PATCHES:=10-build-on-R12B-5.patch 20-MAX_RECV_BODY.patch

# internal.hrl is used by webmachine
UPSTREAM_INCLUDE_DIRS+=$(CLONE_DIR)/src

ORIGINAL_APP_FILE:=$(CLONE_DIR)/$(APP_NAME).app
DO_NOT_GENERATE_APP_FILE=true

define package_rules

$(CLONE_DIR)/src/$(APP_NAME).app.src: $(CLONE_DIR)/.done

$(ORIGINAL_APP_FILE): $(CLONE_DIR)/src/$(APP_NAME).app.src
	cp $(CLONE_DIR)/src/$(APP_NAME).app.src $(ORIGINAL_APP_FILE)

$(PACKAGE_DIR)+clean::
	rm -rf $(ORIGINAL_APP_FILE)

# This rule is run *before* the one in do_package.mk
$(PLUGINS_SRC_DIST_DIR)/$(PACKAGE_DIR)/.srcdist_done::
	cp $(CLONE_DIR)/LICENSE $(PACKAGE_DIR)/LICENSE-MIT-Mochi

endef
