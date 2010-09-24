ifdef PACKAGE_DIR
UPSTREAM_GIT:=http://github.com/mochi/mochiweb.git
REVISION:=9a53dbd7b2c52eb5b9d4

EBIN_DIR:=$(PACKAGE_DIR)/ebin
CHECKOUT_DIR:=$(PACKAGE_DIR)/mochiweb-git
SOURCE_DIR:=$(CHECKOUT_DIR)/src
INCLUDE_DIR:=$(CHECKOUT_DIR)/src

$(CHECKOUT_DIR):
	git clone $(UPSTREAM_GIT) $@
	(cd $@ && git checkout $(REVISION) && patch -p1 < $@-12b3.patch) || (rm -rf $@ && false)

$(CHECKOUT_DIR).stamp: | $(CHECKOUT_DIR)
	touch $@

$(EBIN_DIR)/mochiweb.app_MODULES:=$(patsubst %.erl,%,$(notdir $(wildcard $(SOURCE_DIR)/*.erl)))
$(EBIN_DIR)/mochiweb.app: $(SOURCE_DIR)/mochiweb.app.src | $(EBIN_DIR)
	$(CHECKOUT_DIR)/support/make_app.escript $< $@ "" "$($@_MODULES)"

$(EBIN_DIR):
	mkdir -p $@

$(PACKAGE_DIR)/clean::
	rm -rf $(CHECKOUT_DIR) $(CHECKOUT_DIR).stamp $(EBIN_DIR)/mochiweb.app

include $(CHECKOUT_DIR).stamp
endif

include ../include.mk
