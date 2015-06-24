# android_external_sshfs
sftp (secure file transfer program) client that uses FUSE to mount files and directories served by any SSH server to an android client, secure enough to mount over the internet

## Overview
The code is mostly from the FUSE project's sshfs implementation, found [here](http://fuse.sourceforge.net/sshfs.html). It's been adapted to compile into the cyanogenmod android rom.

This project will allow you to *securely* mount a folder served up by an ssh server to your android device from anywhere with a network connection.  

A typical use case for this would be that you have a phone with 8GB of non-expandable storage and you want access to your 100GB music collection while you're on the go (either via cell or Wi-Fi data access). This project allows all the apps on your phone to see your entire music/movie/book/document/whatever collection as if your files were on your device (if your data connection permits it).  

This project provides (for free) the functionality promised by the currently broken and ~$2.75 app in the play store called [SSHFSAndroid](https://play.google.com/store/apps/details?id=com.chaos9k.sshfsandroid).  


## How to build and install
This module will build a single binary executable file: 'sshfs' that will be installed into /system/xbin on your device, if you follow the instructions provided.

During the installation, some glib-2.0 libraries will also be built and installed on your phone.

This was only tested under cyanogenmod cm-10.2. It'll probably work fine in other roms so long as they have FUSE support. 

However, it should be noted that there have been reports with this not working properly in CM12+ (Lollipop). If, after you build this, the sshfs directory structure disappears after opening a file, rest assured that the developer is working to find the source of the problem.

It should also be noted that this has only been tested with SuperSu. You may come across unknown issues when using a different SU app.


These steps assume:  
1. You have a working cyanogenmod or cm-based rom's build environment with the rom's source tree located in ~/android/system (see [here](http://wiki.cyanogenmod.org/w/Development) for instructions on how to get this, and consult your rom's forum thread or auther regarding its source if you have a cm-based rom)  
2. Your device's currently-installed rom is built from this tree  
3. You have successfully built the entire rom image, which makes sure all required libraries are built, and also ensures you have a *working* source tree  
4. Your device is ready to be connected via adb to your machine containing this build environment, either through wifi or USB (the adb commands in the instructions below are for connecting via USB. Tweak at your leasure)

Note: These instructions __will__ differ if you are building in a system other than a Linux distro. Mac and Windows users will need to either run a Virtual Machine for the build environment (recommended) or consult a CyanogenMod build guide that is specific to their operating system (and their operating system's release version, most likely).

To build and install onto your device, issue the following commands in your build environment:  
```
git clone https://github.com/l3iggs/android_external_sshfs.git ~/android/system/external/sshfs
git clone https://github.com/l3iggs/android_external_glib.git -b cm-10.2 ~/android/system/external/glib
adb root
adb remount
cd ~/android/system/
source build/envsetup.sh
lunch
```
Running the lunch command will prompt you to choose a device. Choose the device that your source tree supports (presumably the one you are building for).  
*!!! Your phone should be plugged in at this point !!!*  
```
cd ~/android/system/external/glib
mmp -B
cd ~/android/system/external/sshfs
mmp -B
```  
After a successful compile, you should see something like this at the end of your terminal's output:
```
Pushing: system/xbin/sshfs
5061 KB/s (125476 bytes in 0.024s)
```
If you see that, you know the binary was built and pushed successfully to your device. If you don't see that, make sure you have a proper build environment. Usually these commands will show errors pointing to missing files. If it fails to find a file in "~/android/system/vendor/..." and you have already successfully built your rom with your source tree, you most likely chose the wrong device when you ran "lunch" or you never ran it at all.

## How to use
In a shell on your android device type `sshfs -h`, you'll see:
```
usage: sshfs [user@]host:[dir] mountpoint [options]

general options:
    -o opt,[opt...]        mount options
    -h   --help            print help
    -V   --version         print version

SSHFS options:
    -p PORT                equivalent to '-o port=PORT'
    -C                     equivalent to '-o compression=yes'
    -F ssh_configfile      specifies alternative ssh configuration file
    -1                     equivalent to '-o ssh_protocol=1'
    -o reconnect           reconnect to server
    -o delay_connect       delay connection to server
    -o sshfs_sync          synchronous writes
    -o no_readahead        synchronous reads (no speculative readahead)
    -o sshfs_debug         print some debugging information
    -o cache=BOOL          enable caching {yes,no} (default: yes)
    -o cache_timeout=N     sets timeout for caches in seconds (default: 20)
    -o cache_X_timeout=N   sets timeout for {stat,dir,link} cache
    -o workaround=LIST     colon separated list of workarounds
             none             no workarounds enabled
             all              all workarounds enabled
             [no]rename       fix renaming to existing file (default: off)
             [no]nodelaysrv   set nodelay tcp flag in sshd (default: off)
             [no]truncate     fix truncate for old servers (default: off)
             [no]buflimit     fix buffer fillup bug in server (default: on)
    -o idmap=TYPE          user/group ID mapping, possible types are:
             none             no translation of the ID space (default)
             user             only translate UID of connecting user
             file             translate UIDs/GIDs contained in uidfile/gidfile
    -o uidfile=FILE        file containing username:remote_uid mappings
    -o gidfile=FILE        file containing groupname:remote_gid mappings
    -o nomap=TYPE          with idmap=file, how to handle missing mappings
             ignore           don't do any re-mapping
             error            return an error (default)
    -o ssh_command=CMD     execute CMD instead of 'ssh'
    -o ssh_protocol=N      ssh protocol to use (default: 2)
    -o sftp_server=SERV    path to sftp server or subsystem (default: sftp)
    -o directport=PORT     directly connect to PORT bypassing ssh
    -o slave               communicate over stdin and stdout bypassing network
    -o transform_symlinks  transform absolute symlinks to relative
    -o follow_symlinks     follow symlinks on the server
    -o no_check_root       don't check for existence of 'dir' on server
    -o password_stdin      read password from stdin (only for pam_mount!)
    -o SSHOPT=VAL          ssh options (see man ssh_config)
```

The following example assumes:  
1. __You already have an ssh server__ running somewhere on a machine with hostname (or IP) SERVER that you can log into as USER  
2. You have created an __empty directory__ on your device to mount to at the following location: `/data/media/0/sshfsmount`  
3. You have turned off namespace separation in your SU app, if the option exists. If you are running certain android versions and you have SuperSu (which is recommended for 4.0+), you can turn this off in SuperSu's settings. Be aware that if namespace separation is on, you will not be able to access the files outside of the app you use to initiate the connection, because namespace separation forces fuse-mounted directories to be on a per-app basis. If you change this setting, it is recommended to reboot your device before testing sshfs.

### Mounting
Make sure `/data/media/0/sshfsmount` exists and is an empty directory.  
In a shell on your android device type:  
```
su
sshfs USER@SERVER: /data/media/0/sshfsmount -o allow_other -o ro -o follow_symlinks -o StrictHostKeyChecking=no -o reconnect -o TCPKeepAlive=no
```  
Replace USER with your ssh login name and SERVER with the server hostname or IP address (note the colon after SERVER is intentional). You will be asked for your ssh password for USER.
* `-o ro` means you'll mount the files as read only (recommended to prevent file damage because this project is experimental)
* `-o allow_other` sets the permissions of the mounted files so that you can access them
* `-o follow_symlinks` enables symlinks in your ssh share to work properly
* `-o StrictHostKeyChecking=no` bypasses a prompt for a security measure used to prevent MITM attacks 
* `-o reconnect` allows for reconnection after interruption in network service 
* `-o TCPKeepAlive=no` prevents bried interruptions in network connectivity from bringing down the connection 

When the `sshfs` command completes successfully you'll be dumped back to the command line with no indication that it worked. You can verify that the mount completed properly by issuing `ls /data/media/0/sshfsmount` you should see the directory structure of your ssh home directory.  

To mount a directory on the ssh server other than your home directory, add it after the colon `USER@SERVER:/some/path/to/mount`

### Unmounting/cleanup
Any failed attempts at mounting will likely leave the mount point directory "dirty". This prevents the success of any future mount attempts. The "dirty" mountpoint can be "cleaned" by unmounting it with the following command. It's good practice to execute this command any time something goes wrong to ensure that future attempts at mounting are not foiled by a "dirty" mount point directory.
```
su
umount /data/media/0/sshfsmount
```

## Passwordless login
It's a real drag to have to enter your password every time you want to connect to your server. Especially if you're trying to automate the process. Follow these steps to setup public key authentication to log into your server without typing in a password on your device.

In a shell on your android device type:
```
su
ssh-keygen
```
Press enter at the prompts here to generate a key with no passphrase. Your public key should now be in /data/.ssh/id_rsa.pub
Now copy this key to your ssh server like this:
```
su
cat /data/.ssh/id_rsa.pub | ssh USER@SERVER "mkdir -p ~/.ssh; cat >> ~/.ssh/authorized_keys"
```
Replace USER with your ssh login name and SERVER with the server hostname or IP address  
You'll have to enter your password here one last time.  
To actually use paswordless login, you must add `-o IdentityFile=/data/.ssh/id_rsa` from now on so that your sshfs command becomes something like:
```
su
sshfs USER@SERVER: /data/media/0/sshfsmount -o allow_other -o ro -o follow_symlinks -o StrictHostKeyChecking=no -o reconnect -o TCPKeepAlive=no -o  IdentityFile=/data/.ssh/id_rsa
```
You'll no longer be prompted for a password when using sshfs. Perfect for automated mounting and unmounting. Note that you must do this for each server you with to set up passwordless login to.

## Other usage ideas
After you setup passwordless login (as described above) you can:
* Use the GScript Lite app to add a buttons to your homescreen that mount and unmount your files
* The Tasker (paid) app becomes almost essential to maintain connectivity during network state changes. Setup Tasker tasks that execute the mount command when wifi and cellular connections go up and the unmount command when they go down. My testing shows this makes the mount bulletproof.

## Limitations
* Media files mounted this way will NOT be picked up automatically by an automated media scanner (media scanning over a network connection is a bad idea anyway).
* Mounting to any arbitrary directory on your device has not been fully tested and may not always work. Mounting to /data/media/0/sshfsmount as in the example above works reliably for me, as does mounting to /data/local/sshfsmount. YMMV for mounting to other directories.
* Error message reporting doesn't work. If the sshfs command encounters any errors it will return 1 and exit silently so you're flying blind if things aren't working. sshfs prints its error messages to stderr which apparently android sends to /dev/null. I've found that `-o sshfs_debug -o debug` can cause crashes themselves (especially with paswordless login) so you best not use those either. Just don't make any mistakes and everything will be fine :^)
* Connections are not maintained when the device's IP address changes (the underlying SSH connection breaks in this case). For example when the user switches from cellular to Wi-Fi the mountpoint will become disconnected. This could potentially be solved by something like mosh: http://mosh.mit.edu/ A readily available workaround is to use the paid Tasker app to manage tne mount point as the network state changes (see above).
