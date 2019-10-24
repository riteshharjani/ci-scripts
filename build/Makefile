all: help

define MAIN_TEMPLATE =
image@${1}@${2} rebuild-image@${1}@${2} pull-image@${1}@${2} push-image@${1}@${2}:
	@./scripts/image.sh $$@

kernel@${1}@${2}: image@${1}@${2}
	@./scripts/build.sh $$@

clean@${1}@${2}:
	@./scripts/clean.sh $$@

CLEAN += clean@${1}@${2}
KERNEL += kernel@${1}@${2}
IMAGES += image@${1}@${2}
PULL_IMAGES += pull-image@${1}@${2}
REBUILD_IMAGES += rebuild-image@${1}@${2}
PUSH_IMAGES += push-image@${1}@${2}
endef

define SELFTESTS_TEMPLATE =
ppctests@${1}@${2} selftests@${1}@${2}: image@${1}@${2}
	@./scripts/build.sh $$@

PPCTESTS += ppctests@${1}@${2}
SELFTESTS += selftests@${1}@${2}
endef

SELFTEST_DISTROS := ubuntu@19.10 ubuntu@19.04 ubuntu@18.10 ubuntu@18.04 ubuntu@16.04
ifeq ($(shell uname -m),x86_64)
BE_DISTROS := korg@4.6
endif
ALL_DISTROS := ${SELFTEST_DISTROS} ${BE_DISTROS}
SUBARCHES := ppc64le ppc64

$(foreach distro,${BE_DISTROS}, \
	$(eval $(call MAIN_TEMPLATE,ppc64,${distro})) \
)

$(foreach distro,${SELFTEST_DISTROS}, \
	$(foreach subarch,${SUBARCHES}, \
		$(eval $(call MAIN_TEMPLATE,${subarch},${distro})) \
	) \
	$(foreach subarch,${SUBARCHES}, \
		$(eval $(call SELFTESTS_TEMPLATE,${subarch},${distro})) \
	) \
)

clean: ${CLEAN}
kernel: ${KERNEL}
ppctests: ${PPCTESTS}
selftests: ${SELFTESTS}
images: ${IMAGES}
pull-images: ${PULL_IMAGES}
rebuild-images: ${REBUILD_IMAGES}
push-images: ${PUSH_IMAGES}

ALL_TARGETS = ${KERNEL} ${PPCTESTS} ${SELFTESTS} ${IMAGES} ${PULL_IMAGES} ${CLEAN}
.PHONY: ${ALL_TARGETS}

empty:=
space:= $(empty) $(empty)
TARGET_DISPLAY := $(subst ${space},\n  ,${ALL_TARGETS})

help:
	@echo "Build docker images and build kernel and/or selftests inside them."
	@echo
	@echo "Targets are of the form:"
	@echo
	@echo "  kernel@<sub arch>@<distro & version>"
	@echo "  ppctests@<sub arch>@<distro & version>"
	@echo "  selftests@<sub arch>@<distro & version>"
	@echo "  clean@<sub arch>@<distro & version>"
	@echo
	@echo "Valid values for sub arch are:"
	@echo "   ${SUBARCHES}"
	@echo
	@echo "Valid values for distro & version are:"
	@echo "   ${ALL_DISTROS}"
	@echo
	@echo "So for example to build the kernel on ppc64le ubuntu 18.10 you'd use"
	@echo
	@echo "  make kernel@ppc64le@ubuntu@18.10"
	@echo
	@echo "However note that not all combinations are valid, as some distros"
	@echo "can't cross build the selftests."
	@echo
	@echo "You can also run all targets of a given type with, eg:"
	@echo
	@echo " $ make images         # build all images if they don't exist"
	@echo " $ make pull-images    # pull all images from docker hub"
	@echo " $ make rebuild-images # rebuild all images"
	@echo " $ make kernel         # build all kernel variants"
	@echo " $ make ppctests       # build all powerpc selftest variants"
	@echo " $ make selftests      # build all selftest variants"
	@echo " $ make clean          # clean everything"
	@echo
	@echo "All targets:"
	@echo -e '  ${TARGET_DISPLAY}'
