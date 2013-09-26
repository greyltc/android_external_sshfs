LOCAL_PATH := $(call my-dir)

# Build sshfs
include $(CLEAR_VARS)

LOCAL_SRC_FILES := sshfs.c cache.c compat/rand_r.c

LOCAL_CFLAGS :=  -DANDROID -D_FILE_OFFSET_BITS=64 -DFUSE_USE_VERSION=26

LOCAL_C_INCLUDES := \
	$(TARGET_C_INCLUDES) \
	external/fuse/include \
	external/fuse/android \
	external/glib/glib \
	external/glib/glib/glib \
	external/glib/glib/android

LOCAL_STATIC_LIBRARIES:= \
	libfuse 

LOCAL_SHARED_LIBRARIES:= \
	libglib-2.0 \
	libgthread-2.0 \
	libgobject-2.0 \
	libgmodule-2.0 \
	libcutils

LOCAL_MODULE_TAGS := optional

LOCAL_MODULE:= sshfs

LOCAL_MODULE_PATH := $(TARGET_OUT_OPTIONAL_EXECUTABLES)

include $(BUILD_EXECUTABLE)
