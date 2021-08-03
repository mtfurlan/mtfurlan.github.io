---
layout: post
title:  "Android Bind Mounts"
categories: android
---

I require symlinks in the user portion of my android storage.
Turns out it's a lot more complex than that.
<!--excerpt-->

Current phone has internal storage only (also known as a mistake),
so this might be a bit simplified.

Actual user storage files are on an ext4 partition at `/data/media/0`
It's emulation mounted to other places, and eventually put at places like
`/storage/self` and `/sdcard` with a bunch of per-user/per-app sandboxing.
Actual explanation [on stack overflow](https://android.stackexchange.com/a/205494/36709).

Symlinks in /data/media/0 work there, but in the sdcardfs bind mounts that are
pretending to be a fat filesystem, they just show up as files.

Bind mounts work though.

So to make one directory show up in another place, what I ended up with was
```
mount --bind /data/media/0/DCIM/Camera/office_lens/ /data/media/0/Pictures/Office\ Lens
```
Turns out that only works in adb shell because that's in the global mount namespace.

Luckily, reddit user
[agnostic-apollo mentions](https://www.reddit.com/r/tasker/comments/k3br7d/mount_command_doesnt_work_on_tasker_and_android/ge259fe)
that `su --mount-master` will drop us into the global mount namespace as well.
```
su --mount-master -c "mount --bind /data/media/0/DCIM/Camera/office_lens/ '/data/media/0/Pictures/Office Lens'"
```


To bind this on boot, I tried putting it in `/data/adb/service.d/bind-mounts.sh`
[according to magisk docs](https://github.com/topjohnwu/Magisk/blob/master/docs/guides.md#boot-scripts).
Unforunately, `/data/media/0` doesn't seem to be mounted at the point that runs.

The end solution was a tasker shell task, running as root.
