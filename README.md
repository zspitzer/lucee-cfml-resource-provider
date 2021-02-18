### Experimental Lucee CFML resource provider

This is an experiment to see if I could implement the follow feature request via a cfml extension

inspired by add session and request based ram drives https://luceeserver.atlassian.net/browse/LDEV-2914

which I first proposed in 2009! https://www.bennadel.com/blog/1650-learning-coldfusion-9-the-virtual-file-system-ram-disk.htm#comments_19299

as Lucee supports adding Resource Providers via extensions in CFML

i.e.  eventually

`FileWrite("request://tempfile.png", imageObject );` only one implemented

`FileWrite("session://tempfile.png", imageObject );`

`FileWrite("application://tempfile.png", imageObject );`

CFML based Virtual File System

https://docs.lucee.org/guides/lucee-5/extensions.html#cfml-based-virtual-file-system
https://docs.lucee.org/guides/cookbooks/Vitural-FileSystem.html

### Plans

Initially it would be a simple CFC stored in the relevant scope, a purely ram implementaion. When the scope is ends, so does the file system.

Mapping this to the file system would interesting too, but ideally,  it would auto cleanup, especially for `request://tempfile.tmp`, but there is no onRequestEnd and the scope listeners for Application and Sessions need to be set in `Application.cfc` i.e. `onApplicationEnd` and `onSessionEnd`

There is an old proposal *Add Hooks for Java Event Listeners* which could be useful here
https://luceeserver.atlassian.net/browse/LDEV-672

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

Currently working, very alpha still see `test.cfm` it's kinda slow (but there's lots of debugging logging overhead)

It's not currently using any scopes, it's a single static scope like the `ram://` resources, but in cfml!

At the moment, I am using `onMissingMethod` to see just which methods need to be supported for a bare bones resource provider

All the resource provider calls are logged out to `application.log` for debugging (**some methods are called twice???**)

You need to restart lucee if you make any changes to the installed files under `\lucee-server\context\components\org\lucee\extension\cfml\scopeResourceProvider` rather than rebuilding and uploading a .lex file

### Todo

- folders need to be stored as children of the `vfsfile`
- creating parent directories when they don't exist (see previous)
- delete should remove, not just mark as not existing
- delete needs to check for children when not recursive (unless force?)

### See also

https://github.com/paulklinkenberg/lucee-azure-provider
