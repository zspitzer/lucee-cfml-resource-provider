### Experimental Lucee CFML resource provider

This is an experiment to see if I could implement the following feature request via a cfml extension

Inspired by add session and request based ram drives https://luceeserver.atlassian.net/browse/LDEV-2914

Which I first proposed way back in 2009! https://www.bennadel.com/blog/1650-learning-coldfusion-9-the-virtual-file-system-ram-disk.htm#comments_19299

Recently I realised that Lucee supports adding Resource Providers via extensions in CFML

i.e.  eventually

`FileWrite("request://tempfile.png", imageObject );` only one implemented

`FileWrite("session://tempfile.png", imageObject );`

`FileWrite("application://tempfile.png", imageObject );`

Mailing List Discussion https://dev.lucee.org/t/experimental-cfml-based-resource-provider/7993

CFML based Virtual File Systems

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

### Status

**You need to manually add the following line to `lucee-server.xml` in the `resources` section**

#### Storage Options

You can either specifiy a `scope` or path to a `storageCFC` which implements the `vfsStore.cfc` interfaces

i.e. scope

`<resource-provider arguments="lock-timeout:10000;scope:server" component="org.lucee.extension.cfml.scopeResourceProvider.requestProvider" scheme="server"/>`

Using scopes doesn't work yet due to this bug https://luceeserver.atlassian.net/browse/LDEV-3292

<resource-provider arguments="lock-timeout:10000;scope:request" component="org.lucee.extension.cfml.scopeResourceProvider.requestProvider" scheme="request"/>
<resource-provider arguments="lock-timeout:10000;scope:application" component="org.lucee.extension.cfml.scopeResourceProvider.requestProvider" scheme="application"/>
<resource-provider arguments="lock-timeout:10000;scope:session" component="org.lucee.extension.cfml.scopeResourceProvider.requestProvider" scheme="session"/>`

i.e. storageCFC

`<resource-provider arguments="lock-timeout:10000;scope:server;storageCFC:vfsStoreFileSystem" component="org.lucee.extension.cfml.scopeResourceProvider.requestProvider" scheme="temp"/>`

you can pass in a custom dir as an argument to `vfsStoreFileSystem`, otherwise, it defaults to `dir:#getTempDirectory()#`

`<resource-provider arguments="lock-timeout:10000;scope:server;storageCFC:vfsStoreFileSystem;dir:\temp\demo" component="org.lucee.extension.cfml.scopeResourceProvider.requestProvider" scheme="temp"/>`
`<resource-provider arguments="lock-timeout:10000;storageCFC:mapped.path.to.myCoolIdea" component="org.lucee.extension.cfml.scopeResourceProvider.requestProvider" scheme="myCoolIdea"/>`

Currently up and running, now in a BETA state, see `test.cfm`. 

You need to restart Lucee if you make any changes to the installed files under `\lucee-server\context\components\org\lucee\extension\cfml\scopeResourceProvider` rather than rebuilding and uploading a .lex file each time.

### Performance

You can benchmark against the built in `ram://` VFS drive by calling `test.cfm?scheme=ram&dump=true`

This cfml resource provider is **about 75% as fast as the built in ram drive**. 

Ram drives return more metadata to `DirectoryList` which makes the `test.cfm` run slower, you can disable the dumps in `test.cfm` with `?dump=false`

At the moment, I am using `onMissingMethod` to see just which methods need to be supported for a bare bones resource provider, which is some overhead plus a fake `onMissingProperty` https://luceeserver.atlassian.net/browse/LDEV-3260

https://github.com/zspitzer/lucee-cfml-resource-provider/blob/master/components/org/lucee/extension/cfml/scopeResourceProvider/vfsDebugWrapper.cfc#L14

All the resource provider calls are logged out to `application.log` for debugging, there is a `variables.debug=boolean` in the various cfcs

### Bugs

The extension now installs, thanks @cfmitrah for pointing out the problem with the `MANIFEST.MF` https://luceeserver.atlassian.net/browse/LDEV-3285

But it doesn't show up as a resource provider (yet) see `listResourceProviders.cfm`

turns out cfml extension resource providers don't get installed (yet) https://luceeserver.atlassian.net/browse/LDEV-3286

cfml resource providers can't see the calling scopes https://luceeserver.atlassian.net/browse/LDEV-3292

There are outstanding bugs relating to resources in Lucee https://luceeserver.atlassian.net/issues/?jql=labels%20%3D%20resources

`DirectoryList("request://");` has a stray / character on windows (affects other resource providers too)

Init args passed to a cfml resource provider are a java hashmap https://luceeserver.atlassian.net/browse/LDEV-3291

### Todo

- more testing
- move test.cfm over to testbox.

### See also

https://github.com/paulklinkenberg/lucee-azure-provider
https://markdrew.io/fun-with-mappings-and-resources-part-3-db-resources
