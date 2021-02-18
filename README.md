### Experimental Lucee CFML resource provider

This is an experiment to see if I could implement the following feature request via a cfml extension

Inspired by add session and request based ram drives https://luceeserver.atlassian.net/browse/LDEV-2914

Which I first proposed way back in 2009! https://www.bennadel.com/blog/1650-learning-coldfusion-9-the-virtual-file-system-ram-disk.htm#comments_19299

Recently I realised that Lucee supports adding Resource Providers via extensions in CFML

i.e.  eventually

`FileWrite("request://tempfile.png", imageObject );` only one implemented

`FileWrite("session://tempfile.png", imageObject );`

`FileWrite("application://tempfile.png", imageObject );`

CFML based Virtual File System

https://docs.lucee.org/guides/lucee-5/extensions.html#cfml-based-virtual-file-system
https://docs.lucee.org/guides/cookbooks/Vitural-FileSystem.html

### Plans / Ideas

Initially it would be a simple CFC stored in the relevant scope, a purely ram implementaion. When the scope is ends, so does the file system.

Mapping this to the file system would interesting too, but ideally,  it would auto cleanup, especially for `request://tempfile.tmp`, but there is no onRequestEnd and the scope listeners for Application and Sessions need to be set in `Application.cfc` i.e. `onApplicationEnd` and `onSessionEnd`

There is an old proposal *Add Hooks for Java Event Listeners* which could be useful here
https://luceeserver.atlassian.net/browse/LDEV-672

This could also be adapted/extended to do some interesting stuff like automatically creating resized version of images on save or other workflows

**PRs are very welcome!**

### Build

Using commandbox, Run `box buildExtension.cfm` to build a .lex file, then manually upload via the admin

### Bugs

The extension now installs, thanks @cfmitrah for pointing out the problem with the `MANIFEST.MF` https://luceeserver.atlassian.net/browse/LDEV-3285

But it doesn't show up as a resource provider (yet) see `listResourceProviders.cfm`

turns out cfml extension resource providers don't get installed (yet) https://luceeserver.atlassian.net/browse/LDEV-3286

**you need to manually add the following line to lucee-server.xml in the resources section**

`<resource-provider arguments="lock-timeout:10000" component="org.lucee.extension.cfml.scopeResourceProvider.requestProvider" scheme="request"/>`

There are outstanding bugs relating to resources in Lucee https://luceeserver.atlassian.net/issues/?jql=labels%20%3D%20resources

`getFileInfo()` doesn't work with resources, but `fileInfo()` does?

`DirectoryList("request://");` has a stray / character ?

### Status

Currently up and limping, but very **alpha** still, see `test.cfm`. It's kinda slow (but there's lots of debugging logging overhead)

It's not currently doing anything with scopes, it's just a single static scope like the `ram://` resources, but in cfml!

At the moment, I am using `onMissingMethod` to see just which methods need to be supported for a bare bones resource provider

All the resource provider calls are logged out to `application.log` for debugging (**some methods are called twice???**)

You need to restart lucee if you make any changes to the installed files under `\lucee-server\context\components\org\lucee\extension\cfml\scopeResourceProvider` rather than rebuilding and uploading a .lex file each time.

### Todo

- folders need to be stored as children of the `VFSfile`
- creating parent directories when they don't exist (see previous)
- delete should remove, not just mark as not existing
- delete needs to check for children when not recursive (unless force?)
- move test.cfm over to testbox. add benchmarking against the different existing VFS 

### See also

https://github.com/paulklinkenberg/lucee-azure-provider
https://markdrew.io/fun-with-mappings-and-resources-part-3-db-resources
