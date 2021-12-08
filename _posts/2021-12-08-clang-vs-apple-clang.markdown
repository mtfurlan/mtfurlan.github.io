---
layout: post
title:  "Warning Flags in Clang vs Apple Clang"
categories: clang, apple
---

I found out that clang 13 supports `-Wreserved-identifier`, while clang claiming to be 13 on a coworkers mac does not.

According to a [clang contributor](https://www.reddit.com/r/cpp_questions/comments/moirt4/comment/gu43re0) apple clang is "quirky".

They seem to just randomly include random things from clang, and I cannot find any documentation on what is included.

This is trying to document how warning flags differ.

<!--excerpt-->

## Related Work
* [pkolbus/compiler-warnings](https://github.com/pkolbus/compiler-warnings/)
documents differences between clang, gcc, and [an apple repo that aproximates apple clang](https://github.com/apple/llvm-project)
> The official Xcode releases are built from an Apple-internal repository, so the exact list of compiler warning flags is not truly knowable without experimentation.
> ...the delta between apple/stable/20200108 and Xcode 12.2 is about ten flags.

* yamaya put together a table of [Xcode and clang versions](https://gist.github.com/yamaya/2924292)

* [List all versions of Command Line Tools](https://developer.apple.com/download/all/?q=llvm)
I'm not really sure how versions of the command line tools related to llvm versions in xcode, but I can definitely install different versions and get different versions of clang
filter for just releases copy listDownloads.action as curl
```
$listDownloads.action_copy_as_curl_thing | jq '.downloads[] | select(.name|test("^Command Line Tools.*Xcode [0-9]*(?:\\.[0-9]*)?$"))'
```


## Methodology:
* Take list of diagnostic flags from [clang 13.0.0](https://releases.llvm.org/13.0.0/tools/clang/docs/DiagnosticsReference.html#w-pragma-messages)
* Test each flag individually in clang 9..12 and apple clang whatever I can get my hands on
* Document where each flag was added

### Getting Apple Clang
Download Command Line Tools for Xcode X.Y from
https://developer.apple.com/download/all/?q=%22command%20line%20developer%20tools%22

```
sudo hdiutil attach Command_Line_Tools_for_Xcode_11.5.dmg
sudo installer -package /Volumes/Command\ Line\ Developer\ Tools/Command\ Line\ Tools.pkg  -target /
sudo hdiutil detach /Volumes/Command\ Line\ Developer\ Tools/
```

I can get 11.0, 11.5, 12.0, and 12.5.1 running in [docker](https://github.com/sickcodes/Docker-OSX/)
A coworker has 13.0 on a mac

### getting actual clang
someone put it in [docker](https://hub.docker.com/r/silkeh/clang)

### Testing approach
Write a sample program and compile it with every warning flag and `-Wunknown-argument` and see where it knows every warning.


