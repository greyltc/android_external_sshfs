android_external_sshfs
======================

One liner: FUSE based ssh file system client for android devices  

Code taken directly from here: http://fuse.sourceforge.net/sshfs.html and adapted to compile into cyanogenmod by me.  

This project will allow you to *securely* mount a folder served up by an ssh server to your android device from anywhere.  

A typical use case for this would be that you have a phone with 8GB of non-expandable storage and you want access to your 100GB music collection from anywhere (via cell data access). This project allows all the apps on your phone to see your entire music/movie/book/document/whatever collection as if your files were on your device (if your data connection permits it).  

This project provides (for free) the functionality promised by the currently broken and ~$2.75 app in the play store called SSHFSAndroid: https://play.google.com/store/apps/details?id=com.chaos9k.sshfsandroid  


How to build:
-------------
This module will build a single binary executable file: 'sshfs' that will be installed into /system/xbin  

This was only tested under cyanogenmod cm-10.2. It'll probably work fine in other versions of CM, but probably not with other roms (because of glib coming from Focal).  

Clone this repo into your cyanogenmod source tree in a folder: external/sshfs  
Building this pulls in header files and shared objects from the external/fuse module and the external/Focal module in the cyanogenmod source tree (it doesn't actually depend on Focal, that's just where I found glib, which really should be moved out of Focal)  


To build:  
```
git clone git@github.com:l3iggs/android_external_sshfs.git ~/android/system/external/sshfs
cd ~/android/system/external/sshfs
mm -B
```  
After a successful compile, you should now see something like `Install: android/system/out/target/product/flo/system/xbin/sshfs` letting you know the build was successful and the executable was copied to your output directory  
Get the binary into the /system/xbin folder on your device using your favorite method (ensuring the execute permission bit is set so you can actually run the thing once it's there)

How to use:
-----------
This example assumes __you already have a ssh server__ running somewhere on a machine with hostname SERVER that you can log into as USER  
It also obviously assumes that you have compiled this project and installed the binary it produces into your device (only tested with cyanogenmod v cm-10.2)
The example will mount your home directory on your ssh server to an empty folder on your android device.
* Initiate a shell session on your android device somehow.
 * Typically, either via `adb shell` on your computer or in a terminal emulator on your device.
* Elevate to root user (for some silly reason FUSE needs root privilages)
 * `su`
* Create an empty directory you will be mounting to (this can be anywhere you like on your android device, it just needs to be an empty directory). The following example makes a folder in the "sdcard" under Android 4.3
 * `mkdir /data/media/0/sshfs_mount`
* Mount your ssh share on your device
 * `sshfs USER@SERVER: /data/media/0/sshfs_mount -o allow_other -o ro`
 * You'll now be asked to enter your ssh password, enter it 

The -o ro option means this will be a read only mount, which is certianly safer. Don't blame me if you omit the -o ro swith and upir files are blown away!

Your home folder on your ssh server is now mounted to your android device as if the files in it were physically on your device.
