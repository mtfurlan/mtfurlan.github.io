---
layout: post
title:  "Repartitioning a Cryptsetup&LVM Encrypted Laptop"
categories: linux, LVM, 
---

I just wanted to add a hard drive for more boot, home, and swap.
Four days later it eventually worked.
<!--excerpt-->
---
The debian installer left me a swap and a root in the same LVM VG in a luks parittion.

(recreated vaguely initial state)
```
NAME                  MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
sda                     8:0    0 223.6G  0 disk
|-sda1                  8:3    0   200M  0 part  /boot
|-sda2                  8:2    0     1K  0 part
`-sda5                  8:5    0 219.6G  0 part
  `-sda5_crypt        254:0    0 219.6G  0 crypt
    `-merida--vg-root 254:1    0 219.6G  0 lvm   /
    `-merida--vg-swap ???:?    0     4G  0 lvm   [SWAP]
```

end result, close enough to what was intended
```
NAME                  MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
sda                     8:0    0 223.6G  0 disk
|-sda2                  8:2    0     1K  0 part
|-sda3                  8:3    0   3.7G  0 part  /boot
`-sda5                  8:5    0 219.6G  0 part
  `-sda5_crypt        254:0    0 219.6G  0 crypt
    `-merida--vg-root 254:1    0 219.6G  0 lvm   /
sdb                     8:16   0 953.9G  0 disk
|-sdb1                  8:17   0 937.9G  0 part
| `-crypthome         254:3    0 937.9G  0 crypt /home
`-sdb2                  8:18   0    16G  0 part
  `-cryptswap         254:2    0    16G  0 crypt [SWAP]
```


On my first attempt I created a single luks device out of sdb, made a LVM PV, VG, and two LVs for home and swap.
Worked fine, everything was cool.
Then I tried to make it unlock the swap early enough to recover from hibernation.
Some people claim you can just setup a keyfile in already unlocked memory like
```
crypthome UUID=b9824fe9-e46a-428a-b043-8488a9ec10eb /etc/luks-keys/home_swap.luks luks
```
I couldn't make it work.

So I found
[passdev](https://cryptsetup-team.pages.debian.net/cryptsetup/README.initramfs.html#the-decrypt_derived-keyscript)
to use one encrypted device as the password to another somehow, but that was bad for data you cared about, so I needed to split up my luks on the new drive.


After deleting everything on the new drive, repartitioning, and setting up seperate luks things, I learned about
[decrypt_keyctl](https://cryptsetup-team.pages.debian.net/cryptsetup/README.keyctl.html)
which just seems better.


Then finally I just had to muddle through not being able to move sda2 which is an extended partition containing sda5 to move my free space from what used to be swap inside the original debian LVM VG to be next to the boot partition, so I got to duplicate my boot partition and delete the old one instead of just expanding it.
It lead to some exciting boots but eventually worked.

---

In the end, my `/etc/crypttab`
```
sda5_crypt UUID=b95ef56c-d73f-47f6-8653-587910112519  not_a_real_keyfile   luks,discard,keyscript=decrypt_keyctl
cryptswap UUID=b63caace-f211-452d-a4fe-5d27412f4d6b   not_a_real_keyfile   luks,discard,keyscript=decrypt_keyctl
crypthome UUID=b9824fe9-e46a-428a-b043-8488a9ec10eb   not_a_real_keyfile   luks,discard,keyscript=decrypt_keyctl
```

`/etc/initramfs-tools/conf.d/resume`
```
RESUME=/dev/mapper/cryptswap
```
Reminder to run `update-initramfs -u -k all` a few extra times, and maybe `update-grub $device` too.
