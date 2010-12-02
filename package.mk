APP_NAME:=mochiweb

UPSTREAM_GIT:=http://github.com/mochi/mochiweb.git
REVISION:=9a53dbd7b2c52eb5b9d4

CHECKOUT_DIR:=$(PACKAGE_DIR)/$(APP_NAME)-git
SOURCE_DIR:=$(CHECKOUT_DIR)/src
INCLUDE_DIR:=$(CHECKOUT_DIR)/src

$(eval $(call safe_include,$(PACKAGE_DIR)/version.mk))

VERSION:=$(MOCHIWEB_VERSION)-rmq$(GLOBAL_VERSION)-git$(COMMIT_SHORT_HASH)

define package_targets

$(CHECKOUT_DIR)/.done:
	rm -rf $(CHECKOUT_DIR)
	git clone $(UPSTREAM_GIT) $(CHECKOUT_DIR)
	cd $(CHECKOUT_DIR) && git checkout $(REVISION)
	patch -d $(CHECKOUT_DIR) -p1 < $(CHECKOUT_DIR)-12b3.patch
	touch $$@

$(SOURCE_DIR)/$(APP_NAME).app.src: $(CHECKOUT_DIR)/.done

$(CHECKOUT_DIR)/$(APP_NAME).app.orig: $(SOURCE_DIR)/$(APP_NAME).app.src
	$(CHECKOUT_DIR)/support/make_app.escript $$< $$@ "" "`cd $(SOURCE_DIR) && echo *.erl | sed 's|\.erl||g'`"

$(PACKAGE_DIR)/version.mk: $(CHECKOUT_DIR)/$(APP_NAME).app.orig
	echo COMMIT_SHORT_HASH:=`git --git-dir=$(CHECKOUT_DIR)/.git log -n 1 --format=format:"%h" HEAD` >$$@
	sed -n -e 's|^.*{vsn, *"\([^"]*\)".*$$$$|MOCHIWEB_VERSION:=\1|p' <$$< >>$$@

$(EBIN_DIR)/$(APP_NAME).app: $(CHECKOUT_DIR)/$(APP_NAME).app.orig $(PACKAGE_DIR)/version.mk
	@mkdir -p $$(@D)
	sed -e 's/{vsn, *\"[^\"]\+\"/{vsn,\"$(VERSION)\"/' <$$< >$$@

$(PACKAGE_DIR)+clean::
	rm -rf $(CHECKOUT_DIR) $(EBIN_DIR)/$(APP_NAME).app $(PACKAGE_DIR)/version.mk

endef
