# Build sshfs

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

GLIB := $(TOP)/external/glib
FUSE := $(TOP)/system/core/libfuse

LOCAL_MODULE := sshfs

LOCAL_SRC_FILES := sshfs.c cache.c compat/rand_r.c

LOCAL_CFLAGS :=  -DANDROID -D_FILE_OFFSET_BITS=64 -DFUSE_USE_VERSION=26

LOCAL_C_INCLUDES := $(TARGET_C_INCLUDES) $(FUSE)/include $(GLIB) $(GLIB)/glib $(GLIB)/android

LOCAL_MODULE_TAGS := optional

LOCAL_STATIC_LIBRARIES := glib-2.0 gthread-2.0 gobject-2.0 gmodule-2.0 libfuse libcutils

include $(BUILD_EXECUTABLE)

