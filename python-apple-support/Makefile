
#这个是裁剪过的，去掉了OpenSSL XZ BZip2 
#
# Useful targets:
# - all             - build everything
# - macOS           - build everything for macOS
# - iOS             - build everything for iOS
# - tvOS            - build everything for tvOS
# - watchOS         - build everything for watchOS
# - OpenSSL-macOS   - build OpenSSL for macOS
# - OpenSSL-iOS     - build OpenSSL for iOS
# - OpenSSL-tvOS    - build OpenSSL for tvOS
# - OpenSSL-watchOS - build OpenSSL for watchOS
# - BZip2-macOS     - build BZip2 for macOS
# - BZip2-iOS       - build BZip2 for iOS
# - BZip2-tvOS      - build BZip2 for tvOS
# - BZip2-watchOS   - build BZip2 for watchOS
# - XZ-macOS        - build XZ for macOS
# - XZ-iOS          - build XZ for iOS
# - XZ-tvOS         - build XZ for tvOS
# - XZ-watchOS      - build XZ for watchOS
# - libFFI-iOS      - build libFFI for iOS
# - libFFI-tvOS     - build libFFI for tvOS
# - libFFI-watchOS  - build libFFI for watchOS
# - Python-macOS    - build Python for macOS
# - Python-iOS      - build Python for iOS
# - Python-tvOS     - build Python for tvOS
# - Python-watchOS  - build Python for watchOS

# Current director
PROJECT_DIR=$(shell pwd)

BUILD_NUMBER=custom

MACOSX_DEPLOYMENT_TARGET=10.8

# Version of packages that will be compiled by this meta-package
# PYTHON_VERSION is the full version number (e.g., 3.10.0b3)
# PYTHON_MICRO_VERSION is the full version number, without any alpha/beta/rc suffix. (e.g., 3.10.0)
# PYTHON_VER is the major/minor version (e.g., 3.10)
PYTHON_VERSION=3.9.6
PYTHON_MICRO_VERSION=$(shell echo $(PYTHON_VERSION) | grep -Eo "\d+\.\d+\.\d+")
PYTHON_VER=$(basename $(PYTHON_VERSION))

LIBFFI_VERSION=3.4.2

# Supported OS
OS=macOS iOS tvOS watchOS

# macOS targets
TARGETS-macOS=macosx.x86_64 macosx.arm64
PYTHON_TARGETS-macOS=macOS
CFLAGS-macOS=-mmacosx-version-min=$(MACOSX_DEPLOYMENT_TARGET)

# iOS targets
TARGETS-iOS=iphonesimulator.x86_64 iphoneos.arm64
CFLAGS-iOS=-mios-version-min=8.0 -fembed-bitcode
CFLAGS-iphoneos.arm64=
CFLAGS-iphonesimulator.x86_64=

# tvOS targets
TARGETS-tvOS=appletvsimulator.x86_64 appletvos.arm64
CFLAGS-tvOS=-mtvos-version-min=9.0 -fembed-bitcode
CFLAGS-appletvos.arm64=
CFLAGS-appletvsimulator.x86_64=
PYTHON_CONFIGURE-tvOS=ac_cv_func_sigaltstack=no

# watchOS targets
TARGETS-watchOS=watchsimulator.i386 watchos.armv7k
CFLAGS-watchOS=-mwatchos-version-min=4.0 -fembed-bitcode
CFLAGS-watchsimulator.i386=
CFLAGS-watchos.armv7k=
PYTHON_CONFIGURE-watchOS=ac_cv_func_sigaltstack=no

# override machine types for arm64
MACHINE_DETAILED-arm64=aarch64
MACHINE_SIMPLE-arm64=arm

all: $(foreach os,$(OS),$(os))

# Clean all builds
clean:
	rm -rf build dist

# Full clean - includes all downloaded products
distclean: clean
	rm -rf downloads

downloads: downloads/openssl-$(OPENSSL_VERSION).tgz downloads/bzip2-$(BZIP2_VERSION).tgz downloads/xz-$(XZ_VERSION).tgz downloads/libffi-$(LIBFFI_VERSION).tgz downloads/Python-$(PYTHON_VERSION).tgz

update-patch:
	# Generate a diff from the clone of the python/cpython Github repository
	# Requireds patchutils (installable via `brew install patchutils`)
	if [ -z "$(PYTHON_REPO_DIR)" ]; then echo "\n\nPYTHON_REPO_DIR must be set to the root of your Python github checkout\n\n"; fi
	cd $(PYTHON_REPO_DIR) && git diff -D v$(PYTHON_VERSION) $(PYTHON_VER) | filterdiff -X $(PROJECT_DIR)/patch/Python/diff.exclude -p 1 --clean > $(PROJECT_DIR)/patch/Python/Python.patch

###########################################################################
# LIBFFI
###########################################################################

# Clean the LibFFI project
clean-libFFI:
	rm -rf build/*/libffi-$(LIBFFI_VERSION) \
		build/*/Support/libFFI

# Download original XZ source code archive.
downloads/libffi-$(LIBFFI_VERSION).tgz:
	mkdir -p downloads
	if [ ! -e downloads/libffi-$(LIBFFI_VERSION).tgz ]; then curl --fail -L http://github.com/libffi/libffi/releases/download/v$(LIBFFI_VERSION)/libffi-$(LIBFFI_VERSION).tar.gz -o downloads/libffi-$(LIBFFI_VERSION).tgz; fi

###########################################################################
# Python
###########################################################################

# Clean the Python project
clean-Python:
	rm -rf \
		build/*/Python-$(PYTHON_VERSION)-* \
		build/*/libpython$(PYTHON_VER).a \
		build/*/pyconfig-*.h \
		build/*/Support/Python

# Download original Python source code archive.
downloads/Python-$(PYTHON_VERSION).tgz:
	mkdir -p downloads
	if [ ! -e downloads/Python-$(PYTHON_VERSION).tgz ]; then curl -L https://www.python.org/ftp/python/$(PYTHON_MICRO_VERSION)/Python-$(PYTHON_VERSION).tgz > downloads/Python-$(PYTHON_VERSION).tgz; fi

# Some Python targets needed to identify the host build
PYTHON_DIR-macOS=build/macOS/Python-$(PYTHON_VERSION)-macOS
PYTHON_HOST=$(PYTHON_DIR-macOS)/dist/lib/libpython$(PYTHON_VER).a






# Build for specified target (from $(TARGETS))
#
# Parameters:
# - $1 - target
# - $2 - OS
define build-target
ARCH-$1=$$(subst .,,$$(suffix $1))
ifdef MACHINE_DETAILED-$$(ARCH-$1)
MACHINE_DETAILED-$1=$$(MACHINE_DETAILED-$$(ARCH-$1))
else
MACHINE_DETAILED-$1=$$(ARCH-$1)
endif
ifdef MACHINE_SIMPLE-$$(ARCH-$1)
MACHINE_SIMPLE-$1=$$(MACHINE_SIMPLE-$$(ARCH-$1))
else
MACHINE_SIMPLE-$1=$$(ARCH-$1)
endif
SDK-$1=$$(basename $1)

SDK_ROOT-$1=$$(shell xcrun --sdk $$(SDK-$1) --show-sdk-path)
CC-$1=xcrun --sdk $$(SDK-$1) clang \
	-arch $$(ARCH-$1) \
	--sysroot=$$(SDK_ROOT-$1) \
	$$(CFLAGS-$2) $$(CFLAGS-$1)
LDFLAGS-$1=-arch $$(ARCH-$1) -isysroot=$$(SDK_ROOT-$1)


LIBFFI_DIR-$1=build/$2/libffi-$(LIBFFI_VERSION)

# macOS builds use their own libFFI, and are compiled as a single
# universal2 build. As a result, the macOS Python build is configured
# in the `build` macro, rather than the `build-target` macro.
ifneq ($2,macOS)
LIBFFI_BUILD_DIR-$1=build_$$(SDK-$1)-$$(ARCH-$1)
PYTHON_DIR-$1=build/$2/Python-$(PYTHON_VERSION)-$1
pyconfig.h-$1=pyconfig-$$(ARCH-$1).h
PYTHON_HOST-$1=$(PYTHON_HOST)

# Build LibFFI
$$(LIBFFI_DIR-$1)/libffi.$1.a: $$(LIBFFI_DIR-$1)/darwin_common
	cd $$(LIBFFI_DIR-$1)/$$(LIBFFI_BUILD_DIR-$1) && make

	# Copy in the lib to a non-BUILD_DIR dependent location;
	# include the target in the final filename for disambiguation
	cp $$(LIBFFI_DIR-$1)/$$(LIBFFI_BUILD_DIR-$1)/.libs/libffi.a $$(LIBFFI_DIR-$1)/libffi.$1.a

# Unpack Python
$$(PYTHON_DIR-$1)/Makefile: downloads/Python-$(PYTHON_VERSION).tgz $$(PYTHON_HOST-$1)
	# Unpack target Python
	mkdir -p $$(PYTHON_DIR-$1)
	tar zxf downloads/Python-$(PYTHON_VERSION).tgz --strip-components 1 -C $$(PYTHON_DIR-$1)
	# Apply target Python patches
	cd $$(PYTHON_DIR-$1) && patch -p1 < $(PROJECT_DIR)/patch/Python/Python.patch
	# Copy in the embedded module configuration
	cat $(PROJECT_DIR)/patch/Python/Setup.embedded $(PROJECT_DIR)/patch/Python/Setup.$2 > $$(PYTHON_DIR-$1)/Modules/Setup.local
	# Configure target Python
	cd $$(PYTHON_DIR-$1) && PATH=$(PROJECT_DIR)/$(PYTHON_DIR-macOS)/dist/bin:$(PATH) ./configure \
		CC="$$(CC-$1)" LD="$$(CC-$1)" \
		--host=$$(MACHINE_DETAILED-$1)-apple-$(shell echo $2 | tr '[:upper:]' '[:lower:]') \
		--build=x86_64-apple-darwin \
		--prefix=$(PROJECT_DIR)/$$(PYTHON_DIR-$1)/dist \
		--without-doc-strings --enable-ipv6 --without-ensurepip \
		ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no \
		$$(PYTHON_CONFIGURE-$2)

# Build Python
$$(PYTHON_DIR-$1)/dist/lib/libpython$(PYTHON_VER).a: build/$2/Support/libFFI $$(PYTHON_DIR-$1)/Makefile
	# Build target Python
	cd $$(PYTHON_DIR-$1) && PATH="$(PROJECT_DIR)/$(PYTHON_DIR-macOS)/dist/bin:$(PATH)" make all install

build/$2/$$(pyconfig.h-$1): $$(PYTHON_DIR-$1)/dist/include/python$(PYTHON_VER)/pyconfig.h
	cp -f $$^ $$@

endif

endef


#
# Build for specified OS (from $(OS))
# Parameters:
# - $1 - OS
define build
$$(foreach target,$$(TARGETS-$1),$$(eval $$(call build-target,$$(target),$1)))


LIBFFI_FRAMEWORK-$1=build/$1/Support/libFFI
PYTHON_FRAMEWORK-$1=build/$1/Support/Python
PYTHON_RESOURCES-$1=$$(PYTHON_FRAMEWORK-$1)/Resources

$1: dist/Python-$(PYTHON_VER)-$1-support.$(BUILD_NUMBER).tar.gz

clean-$1:
	rm -rf build/$1

dist/Python-$(PYTHON_VER)-$1-support.$(BUILD_NUMBER).tar.gz: $$(LIBFFI_FRAMEWORK-$1) $$(PYTHON_FRAMEWORK-$1)
	mkdir -p dist
	echo "Python version: $(PYTHON_VERSION) " > build/$1/Support/VERSIONS
	echo "Build: $(BUILD_NUMBER)" >> build/$1/Support/VERSIONS
	echo "---------------------" >> build/$1/Support/VERSIONS
ifeq ($1,macOS)
	echo "libFFI: macOS native" >> build/$1/Support/VERSIONS
else
	echo "libFFI: $(LIBFFI_VERSION)" >> build/$1/Support/VERSIONS
endif


	# Build a "full" tarball with all content for test purposes
	tar zcvf dist/Python-$(PYTHON_VER)-$1-support.test-$(BUILD_NUMBER).tar.gz -X patch/Python/test.exclude -C build/$1/Support `ls -A build/$1/Support`
	# Build a distributable tarball
	tar zcvf $$@ -X patch/Python/release.common.exclude -X patch/Python/release.$1.exclude -C build/$1/Support `ls -A build/$1/Support`



# Build libFFI
libFFI-$1: $$(LIBFFI_FRAMEWORK-$1)

# macOS builds a single Python universal2 target; thus it needs to be
# configured in the `build` macro, not the `build-target` macro.
# macOS also uses the system-provided libFFI, so there's no need to package
# a libFFI framework for macOS.
ifeq ($1,macOS)
# Some targets that are needed for consistency between macOS and other builds,
# but are no-ops on macOS.
$$(LIBFFI_FRAMEWORK-$1):

build/$1/$$(pyconfig.h-$1):

# Unpack Python
$$(PYTHON_DIR-$1)/Makefile: downloads/Python-$(PYTHON_VERSION).tgz
	# Unpack target Python
	mkdir -p $$(PYTHON_DIR-$1)
	tar zxf downloads/Python-$(PYTHON_VERSION).tgz --strip-components 1 -C $$(PYTHON_DIR-$1)
	# Apply target Python patches
	cd $$(PYTHON_DIR-$1) && patch -p1 < $(PROJECT_DIR)/patch/Python/Python.patch
	# Copy in the embedded module configuration
	cat $(PROJECT_DIR)/patch/Python/Setup.embedded $(PROJECT_DIR)/patch/Python/Setup.$1 > $$(PYTHON_DIR-$1)/Modules/Setup.local
	# Configure target Python
	cd $$(PYTHON_DIR-$1) && MACOSX_DEPLOYMENT_TARGET=$$(MACOSX_DEPLOYMENT_TARGET) ./configure \
		--prefix=$(PROJECT_DIR)/$$(PYTHON_DIR-$1)/dist \
		--without-doc-strings --enable-ipv6 --without-ensurepip --enable-universalsdk --with-universal-archs=universal2 \
		$$(PYTHON_CONFIGURE-$1)

# Build Python
$$(PYTHON_DIR-$1)/dist/lib/libpython$(PYTHON_VER).a: build/$1/Support/libFFI $$(PYTHON_DIR-$1)/Makefile
	# Build target Python
	cd $$(PYTHON_DIR-$1) && PATH="$(PROJECT_DIR)/$(PYTHON_DIR-$1)/dist/bin:$(PATH)" make all install

else
# The LibFFI folder is shared between all architectures for the OS
LIBFFI_DIR-$1=build/$1/libffi-$(LIBFFI_VERSION)
# The Python targets are the same as they are for every other library
PYTHON_TARGETS-$1=$$(TARGETS-$1)

# Unpack LibFFI and generate source & headers
$$(LIBFFI_DIR-$1)/darwin_common: downloads/libffi-$(LIBFFI_VERSION).tgz
	# Unpack sources
	mkdir -p $$(LIBFFI_DIR-$1)
	tar zxf downloads/libffi-$(LIBFFI_VERSION).tgz --strip-components 1 -C $$(LIBFFI_DIR-$1)
	# Configure the build
	cd $$(LIBFFI_DIR-$1) && python generate-darwin-source-and-headers.py --only-$(shell echo $1 | tr '[:upper:]' '[:lower:]')

$$(LIBFFI_FRAMEWORK-$1): $$(LIBFFI_DIR-$1)/libffi.a
	# Create framework directory structure
	mkdir -p $$(LIBFFI_FRAMEWORK-$1)

	# Copy the headers.
	cp -f -r $$(LIBFFI_DIR-$1)/darwin_common/include $$(LIBFFI_FRAMEWORK-$1)/Headers
	cp -f -r $$(LIBFFI_DIR-$1)/darwin_$(shell echo $1 | tr '[:upper:]' '[:lower:]')/include/* $$(LIBFFI_FRAMEWORK-$1)/Headers

	# Create the fat library
	xcrun libtool -no_warning_for_no_symbols -static \
		-o $$(LIBFFI_FRAMEWORK-$1)/libFFI.a $$^

$$(LIBFFI_DIR-$1)/libffi.a: $$(foreach target,$$(TARGETS-$1),$$(LIBFFI_DIR-$1)/libffi.$$(target).a)
	xcrun lipo -create -o $$@ $$^

endif

$1: Python-$1

Python-$1: dist/Python-$(PYTHON_VER)-$1-support.$(BUILD_NUMBER).tar.gz

# Build Python
$$(PYTHON_FRAMEWORK-$1): build/$1/libpython$(PYTHON_VER).a $$(foreach target,$$(PYTHON_TARGETS-$1),build/$1/$$(pyconfig.h-$$(target)))
	mkdir -p $$(PYTHON_RESOURCES-$1)/include/python$(PYTHON_VER)

	# Copy the headers. The headers are the same for every platform, except for pyconfig.h
	# We ship a master pyconfig.h for iOS, tvOS and watchOS that delegates to architecture
	# specific versions; on macOS, we can use the original version as-is.
	cp -f -r $$(PYTHON_DIR-$$(firstword $$(PYTHON_TARGETS-$1)))/dist/include/python$(PYTHON_VER) $$(PYTHON_FRAMEWORK-$1)/Headers
ifneq ($1,macOS)
	cp -f $$(filter %.h,$$^) $$(PYTHON_FRAMEWORK-$1)/Headers
	cp -f $(PROJECT_DIR)/patch/Python/pyconfig-$1.h $$(PYTHON_FRAMEWORK-$1)/Headers/pyconfig.h
endif
	# Copy Python.h and pyconfig.h into the resources include directory
	cp -f -r $$(PYTHON_FRAMEWORK-$1)/Headers/pyconfig*.h $$(PYTHON_RESOURCES-$1)/include/python$(PYTHON_VER)
	cp -f -r $$(PYTHON_FRAMEWORK-$1)/Headers/Python.h $$(PYTHON_RESOURCES-$1)/include/python$(PYTHON_VER)

	# Copy the standard library from the simulator build
	cp -f -r $$(PYTHON_DIR-$$(firstword $$(PYTHON_TARGETS-$1)))/dist/lib $$(PYTHON_RESOURCES-$1)

	# Copy fat library
	cp -f $$(filter %.a,$$^) $$(PYTHON_FRAMEWORK-$1)/libPython.a


# Build libpython fat library
build/$1/libpython$(PYTHON_VER).a: $$(foreach target,$$(PYTHON_TARGETS-$1),$$(PYTHON_DIR-$$(target))/dist/lib/libpython$(PYTHON_VER).a)
	# Create a fat binary for the libPython library
	mkdir -p build/$1
	xcrun lipo -create -output $$@ $$^

endef

$(foreach os,$(OS),$(eval $(call build,$(os))))