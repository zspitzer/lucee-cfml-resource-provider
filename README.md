### Experimental Lucee CFML resource provider per scope (request/session/application)

This is an experiment to see if I could implement the follow feature request via a cfml extension

add session and request based ram drives

https://luceeserver.atlassian.net/browse/LDEV-2914

as Lucee supports adding Resource Providers via extensions in CFML

I.e. 
`
FileWrite("request://tempfile.png", imageObject );

FileWrite("session://tempfile.png", imageObject );

FileWrite("application://tempfile.png", imageObject );
`

CFML based Virtual File System

https://docs.lucee.org/guides/lucee-5/extensions.html#cfml-based-virtual-file-system
https://docs.lucee.org/guides/cookbooks/Vitural-FileSystem.html

#### Plans

Initially it would be a simple CFC stored in the relevant scope, a purely ram implementaion. When the scope is ends, so does the file system.

Mapping this to the file system would interesting too, but ideally,  it would auto cleanup, especially for `request://tempfile.tmp`, but there is no onRequestEnd and the scope listeners for Application and Sessions need to be set in `Application.cfc` i.e. `onApplicationEnd` and `onSessionEnd`

There is an old proposal *Add Hooks for Java Event Listeners* which could be useful here
https://luceeserver.atlassian.net/browse/LDEV-672

#### Bugs

Building the extension on Windows doesn't work with cfzip due to a bug with paths

https://luceeserver.atlassian.net/browse/LDEV-3285

There are outstanding bugs relating to resources in Lucee
https://luceeserver.atlassian.net/issues/?jql=labels%20%3D%20resources

#### Status

Very much a work in progress

At the moment, I am exploring using `onMissingMethod` to see just which methods need to be supported for a bare bones resource provider

#### See also

https://github.com/paulklinkenberg/lucee-azure-provider
