---
layout: post
title:  "Linux MTA Email Forwarding with nullmailer"
categories: linux
---

Notifications are useful when services fail.

Sadly, they often get sent to `root@127.0.0.1`, where they don't get read because nobody sets up their mta.

[nullmailer](https://untroubled.org/nullmailer/) to the rescue.

<!--excerpt-->
So far this has only been tested on 14.04.5 LTS, Trusty Tahr which hits EOL next year.
I don't like ubuntu I don't see why they need their own init system.
I just learned systemd why do I have do do this all over again.

Anyway.


Install nullmailer, I used whatever was in the repos.

In `/etc/nullmailer/remotes` put
```
74.125.206.108 smtp --port=465 --auth-login --ssl --user=yourSendingEmail@domain.tld --pass=iWonderIfQuotesWorkForSpaces --insecure
```
The password comes from the app password thing, you need to setup two factor in the gmail account.


To test this, try running
```
echo "error" | NULLMAILER_NAME="Some Service" mail -s "issue with service" "yourReceivingEmail@domain.tld"
```
`NULLMAILER_NAME` is optional, but will set from name instead of just being from yourSendingEmail@domain.tld

That can also be used in cronjobs, or other reporting.

In `/etc/smartd.conf`, we set stuff to hopefully check `/dev/sda` for issues and report them.
```
/dev/sda -M test -s S/../.././02 -H -C 0 -U 0 -m yourReceivingEmail@domain.tld
```
This should send a test email on daemon start, and run a short test every day at 2:00.
The jury is still out as to if it sends a test email every day at 2:00.
The test should not report anything unless there are problems.

I never figured out how to set the env var `NULLMAILER_NAME`, so the from is just whatever email you're sending from, but it does report hostname in the topic.

And then finally in `/etc/default/smartmontools` uncomment `start_smartd=yes` to autostart because that's how you do it I guess?

I'll update this when I get my hands on a drive that fails smart and I can prove it works.
