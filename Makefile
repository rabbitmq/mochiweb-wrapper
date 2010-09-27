ifdef PACKAGE_DIR
UPSTREAM_GIT:=http://github.com/mochi/mochiweb.git
REVISION:=9a53dbd7b2c52eb5b9d4

EBIN_DIR:=$(PACKAGE_DIR)/ebin
CHECKOUT_DIR:=$(PACKAGE_DIR)/mochiweb-git
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
	cd $(@D) && echo COMMIT_DATE:=$$(date -u +"%Y%m%d" --date="$$(git log --since=$(REVISION) -n 1 --date=iso --format=format:"%cd")") > $@
	cd $(@D) && echo COMMIT_SHORT_HASH:=$$(git log --since=$($(@D)_REVISION) -n 1 --format=format:"%h") >> $@
	$(@D)/support/make_app.escript $(@D)/src/mochiweb.app.src $@.tmp "" ""
	echo $$(cat $@.tmp | grep {vsn | sed -e 's/^.\+{vsn,\"/MOCHIWEB_VERSION:=/; s/\".*$$//') >> $@
	rm $@.tmp

$(EBIN_DIR)/mochiweb.app_MAKE_APP:=$(CHECKOUT_DIR)/support/make_app.escript
$(EBIN_DIR)/mochiweb.app_MODULES:=$(patsubst %.erl,%,$(notdir $(wildcard $($(PACKAGE_DIR)_SOURCE_DIR)/*.erl)))
$(EBIN_DIR)/mochiweb.app: $(SOURCE_DIR)/mochiweb.app.src | $(EBIN_DIR)
	$($@_MAKE_APP) $< $@.tmp "" "$($@_MODULES)"
	sed -e 's/{vsn,\"[^\"]\+\"/{vsn,\"$($@_VERSION)\"/' < $@.tmp > $@
	rm $@.tmp

$(PACKAGE_DIR)/clean_RM:=$(CHECKOUT_DIR) $(CHECKOUT_DIR)/stamp $(EBIN_DIR)/mochiweb.app
$(PACKAGE_DIR)/clean::
	rm -rf $($@_RM)

ifneq "$(strip $(patsubst clean%,,$(patsubst %clean,,$(TESTABLEGOALS))))" ""
include $(CHECKOUT_DIR)/stamp

VERSION:=$(MOCHIWEB_VERSION)-rmq$(GLOBAL_VERSION)-$(COMMIT_DATE)-git$(COMMIT_SHORT_HASH)
$(EBIN_DIR)/mochiweb.app_VERSION:=$(VERSION)
endif
endif

include ../include.mk
