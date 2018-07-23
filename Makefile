include $(THEOS)/makefiles/common.mk

ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:9.1:7.0

TWEAK_NAME = CellularUsageOrderXI
CellularUsageOrderXI_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk
ADDITIONAL_OBJCFLAGS = -fobjc-arc

after-install::
	install.exec "killall -9 Preferences"
