---
layout: post
title:  "Jenkins Automatic Backup & Testing"
categories:
---

Backing up jenkins seems like it should be a solved problem and yet.

<!--excerpt-->

The [Jenkins User Handbook -> System Administration -> Backing-up/Restoring Jenkins](https://www.jenkins.io/doc/book/system-administration/backing-up/)  has a nice overview of everything you need to back up jenkins.

I would have assumed I could just find a script or install a plugin, but none of them did the critical thing of *testing the backup*, and a lot of them just included the master.key which the jenkins handbook specifically says don't keep in the backups.

So I had to write my own.


Current issues:
* Testing the backup consists of starting it and then checking for a 200 from the login page, so not very thorough
* Running the jenkins under test on the host controller causes issues
  * The controller reaches out to talk to some build nodes now, but I don't like it doing that when under test
  * I can change the http port, but not the build agent connection port or the SSH CLI port, so those just throw errors
  * Running in docker could solve a lot of this, but the controller doesn't have docker and I don't want to copy the master.key off the controller
* It would be cool to watch the boot logs to figure out when it's ready instead of just hardcoding a time but that's hard.
* Lots of hardcoding *everywhere*


It boils down to `backup.sh`:
```sh
tar --force-local -czpf "$tarball" \
    -C "$(dirname "$jenkinsHome")" "$(basename "$jenkinsHome")" \
        --exclude="jobs" \
        --exclude=".*" \
        --exclude="*cache" \
        --exclude="workspace" \
        --exclude="secrets/master.key" \
    -C "$(dirname "$jenkinsWar")" "$(basename "$jenkinsWar")" \
    -C "$DIR" README.md
```

and `test.sh`
```sh
tar xf "$jenkinsTarball"
cp "$jenkinsMasterKey" jenkins/secrets/master.key

# run jenkins in background
JENKINS_HOME="$(pwd)/jenkins" timeout "$((jenkinsStartupDelay+5))" java -jar "$(pwd)/jenkins.war" --httpPort=9999 &

# TODO: instead of sleep watch output and look for "Jenkins is fully up and running"
sleep $jenkinsStartupDelay

if [[ "$(curl -s -w "%{http_code}" http://localhost:9999/login -o /dev/null)" != "200" ]]; then
    echo "jenkins didn't come online"
    exit 1
fi
```
`jenkinsStartupDelay` is just a time that jenkins will probably start up in, so we run jenkins with timeout of jenkinsStartupDelay + 5 in the background, sleep for jenkinsStartupDelay seconds, then check if it's online

This is all called from a jenkins pipeline to run the backup and test on the controller, stash the tarball, unstash it on a build node with a backup hard drive, and then copy it to the backup dir and remove old backups.


---
Unrelated fun fact: If you have colon in a filename in tar, tar will think it's some kind of remote thing without `--force-local`
```
       --force-local
              Archive file is local even if it has a colon.
```
                     
