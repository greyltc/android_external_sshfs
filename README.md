android_external_sshfs
======================
FUSE based ssh file system client for android devices

Overview
--------
The code is mostly from here: http://fuse.sourceforge.net/sshfs.html It's been adapted to compile into the cyanogenmod android rom 

This project will allow you to *securely* mount a folder served up by an ssh server to your android device from anywhere with a network connection.  

A typical use case for this would be that you have a phone with 8GB of non-expandable storage and you want access to your 100GB music collection while you're on the go (either via cell or wi-fi data access). This project allows all the apps on your phone to see your entire music/movie/book/document/whatever collection as if your files were on your device (if your data connection permits it).  

This project provides (for free) the functionality promised by the currently broken and ~$2.75 app in the play store called SSHFSAndroid: https://play.google.com/store/apps/details?id=com.chaos9k.sshfsandroid  


How to build and install
-------------------------
This module will build a single binary executable file: 'sshfs' that will be installed into /system/xbin on your device

This was only tested under cyanogenmod cm-10.2. It'll probably work fine in other versions of CM, but probably not with other roms (because a glib dependancy is satisfied by files in the Focal module, a CM app).  

These steps assume:
A) you have a working cyanogenmod build environment with the CM source tree located in ~/android/system   
and  
B) that your deivice is running CM built from this tree  

To build and install onto your device issue the following commands in your build environment:  
```
git clone git@github.com:l3iggs/android_external_sshfs.git ~/android/system/external/sshfs
cd ~/android/system/external/sshfs
adb root
adb remount
mmp
```  
After a successful compile, you should now see something like
```
Pushing: system/xbin/sshfs
5061 KB/s (125476 bytes in 0.024s)
```
If you see that, you know the binary was built and pushed sucessfully to your device. Otherwise, the compile failed.

How to use
----------

In a shell on your android device type:
`sshfs -h`
You'll see:
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

This example assumes __you already have a ssh server__ running somewhere on a machine with hostname SERVER that you can log into as USER  

The example will mount your home directory on your ssh server to an empty folder in the sdcard of your android device.

In a shell on your android device type:  
```
mkdir /storage/sdcard0/sshfsmount
su
sshfs USER@SERVER: /storage/sdcard0/sshfsmount -o allow_other -o ro
```  
You may be asked to authenticate the key fingerprint of SERVER, type `yes` there.  
You will be asked for your ssh password for USER.  

When the final command completes sucessfully you'll be dumped back to the command line with no output. You can verify that the mount completed properly by issuing `ls /storage/sdcard0/sshfs_mount` you should see the directory structure of your ssh home directory.  

Your home folder on your ssh server is now mounted to your android device as if the files in it were physically on your device.

Limitations
-----------
* Media files mounted this way will not be picked up automatically by an automated media scanner.
* Mounting to any arbitrary directory doesn't always work, this may be because some directories are already fuse mounts and nested fuse mounting is failing. To be safe, mount in /data/local/
* Errors are currently not being displayed anywhere (that I'm aware of). This means that if anything goes wrong with the command it simply returns 1 and dumps you back to the command line with no indication of what whent wrong.



