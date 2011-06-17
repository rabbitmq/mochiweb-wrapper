APP_NAME:=mochiweb

UPSTREAM_GIT:=http://github.com/mochi/mochiweb.git
UPSTREAM_REVISION:=9a53dbd7b2c52eb5b9d4
RETAIN_ORIGINAL_VERSION:=true
WRAPPER_PATCHES:=mochiweb-12b3.patch 10-crypto.patch

# internal.hrl is used by webmachine
UPSTREAM_INCLUDE_DIRS+=$(CLONE_DIR)/src

define package_rules

$(CLONE_DIR)/src/$(APP_NAME).app.src: $(CLONE_DIR)/.done

$(ORIGINAL_APP_FILE): $(CLONE_DIR)/src/$(APP_NAME).app.src
	@mkdir -p $$(@D)
	$(CLONE_DIR)/support/make_app.escript $$< $$@ "" ""

$(PACKAGE_DIR)+clean::
	rm -rf $(ORIGINAL_APP_FILE)

endef
