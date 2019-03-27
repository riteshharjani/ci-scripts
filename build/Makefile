all: help

define TEMPLATE =
image@${1}@${2} rebuild-image@${1}@${2}:
	@./scripts/image.sh $$@

ppctests@${1}@${2} selftests@${1}@${2} kernel@${1}@${2}: image@${1}@${2}
	@./scripts/build.sh $$@

clean@${1}@${2}:
	@./scripts/clean.sh $$@

PPCTESTS += ppctests@${1}@${2}
SELFTESTS += selftests@${1}@${2}
CLEAN += clean@${1}@${2}
KERNEL += kernel@${1}@${2}
IMAGES += image@${1}@${2}
REBUILD_IMAGES += rebuild-image@${1}@${2}
endef

DISTROS := ubuntu@18.10 ubuntu@18.04 ubuntu@16.04
SUBARCHES := ppc64le ppc64

$(foreach distro,${DISTROS}, \
	$(foreach subarch,${SUBARCHES}, \
		$(eval $(call TEMPLATE,${subarch},${distro})) \
	) \
)

clean: ${CLEAN}
kernel: ${KERNEL}
ppctests: ${PPCTESTS}
selftests: ${SELFTESTS}
images: ${IMAGES}
rebuild-images: ${REBUILD_IMAGES}

ALL_TARGETS = ${KERNEL} ${PPCTESTS} ${SELFTESTS} ${IMAGES} ${CLEAN}
.PHONY: ${ALL_TARGETS}

empty:=
space:= $(empty) $(empty)
TARGET_DISPLAY := $(subst ${space},\n  ,${ALL_TARGETS})

help:
	@echo 'Build docker images and build kernel and/or selftests inside them.'
	@echo
	@echo 'Targets are of the form:'
	@echo
	@echo '  kernel@<sub arch>@<distro & version>'
	@echo '  ppctests@<sub arch>@<distro & version>'
	@echo '  selftests@<sub arch>@<distro & version>'
	@echo '  clean@<sub arch>@<distro & version>'
	@echo
	@echo 'Valid values for sub arch are:'
	@echo '   ${SUBARCHES}'
	@echo
	@echo 'Valid values for distro & version are:'
	@echo '   ${DISTROS}'
	@echo
	@echo 'You can also run all targets of a given type with, eg:'
	@echo
	@echo ' $ make images    # build all images'
	@echo ' $ make kernel    # build all kernel variants'
	@echo ' $ make ppctests  # build all powerpc selftest variants'
	@echo ' $ make selftests # build all selftest variants'
	@echo ' $ make clean     # clean everything'
	@echo
	@echo 'All targets:'
	@echo -e '  ${TARGET_DISPLAY}'
