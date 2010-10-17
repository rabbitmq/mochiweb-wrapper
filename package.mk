APP_NAME:=mochiweb

UPSTREAM_GIT:=http://github.com/mochi/mochiweb.git
REVISION:=9a53dbd7b2c52eb5b9d4

EBIN_DIR:=$(PACKAGE_DIR)/ebin
CHECKOUT_DIR:=$(PACKAGE_DIR)/$(APP_NAME)-git
SOURCE_DIR:=$(CHECKOUT_DIR)/src
INCLUDE_DIR:=$(CHECKOUT_DIR)/src

$(CHECKOUT_DIR)_UPSTREAM_GIT:=$(UPSTREAM_GIT)
$(CHECKOUT_DIR)_REVISION:=$(REVISION)
$(CHECKOUT_DIR):
	git clone $($@_UPSTREAM_GIT) $@
	(cd $@ && git checkout $($@_REVISION) && patch -p1 < $@-12b3.patch) || (rm -rf $@ && false)

# we run the make_app.escript early just so that we can grab out the mochiweb version
$(CHECKOUT_DIR)/stamp: | $(CHECKOUT_DIR)
	rm -f $@
	cd $(@D) && echo COMMIT_SHORT_HASH:=$$(git log -n 1 --format=format:"%h" HEAD) > $@
	$(@D)/support/make_app.escript $(@D)/src/mochiweb.app.src $@.tmp "" ""
	echo $$(cat $@.tmp | grep {vsn | sed -e 's/^.\+{vsn, *\"/MOCHIWEB_VERSION:=/; s/\".*$$//') >> $@
	rm $@.tmp

$(PACKAGE_DIR)/clean_RM:=$(CHECKOUT_DIR) $(CHECKOUT_DIR)/stamp $(EBIN_DIR)/$(APP_NAME).app
$(PACKAGE_DIR)/clean::
	rm -rf $($@_RM)

ifneq "$(strip $(patsubst clean%,,$(patsubst %clean,,$(TESTABLEGOALS))))" ""
include $(CHECKOUT_DIR)/stamp

VERSION:=$(MOCHIWEB_VERSION)-rmq$(GLOBAL_VERSION)-git$(COMMIT_SHORT_HASH)

$(EBIN_DIR)/$(APP_NAME).app.$(VERSION)_VERSION:=$(VERSION)
$(EBIN_DIR)/$(APP_NAME).app.$(VERSION)_MAKE_APP:=$(CHECKOUT_DIR)/support/make_app.escript
$(EBIN_DIR)/$(APP_NAME).app.$(VERSION)_MODULES:=$(patsubst %.erl,%,$(notdir $(wildcard $($(PACKAGE_DIR)_SOURCE_DIR)/*.erl)))
$(EBIN_DIR)/$(APP_NAME).app.$(VERSION): $(SOURCE_DIR)/$(APP_NAME).app.src | $(EBIN_DIR)
	$($@_MAKE_APP) $< $@.tmp "" "$($@_MODULES)"
	sed -e 's/{vsn, *\"[^\"]\+\"/{vsn,\"$($@_VERSION)\"/' < $@.tmp > $@
	rm $@.tmp

$(PACKAGE_DIR)_APP:=true
endif
