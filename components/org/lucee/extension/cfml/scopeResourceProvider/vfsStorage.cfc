component extends="vfsBase" {
    public any function init(string scheme, struct args, string separator, required any provider){
        this.separator = "/";
        this.scheme = arguments.scheme;
        this.provider = arguments.provider;
        var vfsKey = "__vfs";

        if (structKeyExists(arguments.args, "storageCFC")){
            logger(text="VFSstorage INIT [#arguments.scheme#] using [#arguments.args["storageCFC"]#]");
            this.storage = CreateObject("component", arguments.args["storageCFC"]).init(arguments.args); // must implement vfsStore interface
        } else if (structKeyExists(arguments.args, "scope")){
            // TODO neeed to check and create as scope come and go, not just on the first request !!!!
            var scope="";
            switch (arguments.args.scope){
                case "session":
                    scope = getPageContext().sessionScope();
                    break;
                case "application":
                    scope = getPageContext().applicationScope();
                    break;
                case "request":
                    scope = getPageContext().requestScope();
                    break;
                case "server":
                    scope = getPageContext().serverScope();
                    break;
                case "cfml":
                    scope = this;
                    break;
                    // TODO support custom storage component
                default:
                    throw "unsupported vfs scope [#arguments.args.scope#] for scheme [#arguments.scheme#]";
            }
            logger(text="VFSstorage INIT [#arguments.scheme#] in scope [#arguments.args.scope#] as [#vfsKey#]");
            if (!structKeyExists(scope, vfsKey))
                scope[vfsKey] = new vfsStore(arguments.args); // TODO pass in cass-insenstive from args
            this.storage = scope[vfsKey];
        } else {
            throw "VFSstorage neither [scope] or [storageCFC] defined in arguments";
        }
        return this;
    }

    function add(required any resource){
        logger(text="VFSstorage ADD #arguments.resource.path#");

        arguments.resource.setExists(true);
        arguments.resource.name = listLast(arguments.resource.path,"/\");
        arguments.resource.setLastModified();

        logger("vfsStorage add:  [#arguments.resource.path# dir:#arguments.resource.isDir# exists:#arguments.resource.exists()#]");

        this.storage.set(arguments.resource.path,{
            meta: arguments.resource.toStruct()
        });
    }

    function update(required any resource, required any file){
        logger(text="vfsStorage update #arguments.resource.path#");
        arguments.resource.setLastModified();
        arguments.resource._length = len(arguments.file);
        this.storage.set(arguments.resource.path, {
            meta: arguments.resource.toStruct(),
            file: arguments.file
        });
    }

    function remove(required string path){
        if (arguments.path neq this.separator) // don't delete the root (other providers like ram:// throw an error)
            this.storage.delete(arguments.path);
    }

    function read(required string path){
        if (!exists(arguments.path)){
            throw "[#arguments.path#] doesn't exist";
        } else {
            var res = this.storage.get(arguments.path);
            logger("vfsStorage read:  [#res.meta.path# dir:#res.meta.isDir# exists:#res.meta._exists#]");
            return new vfsDebugWrapper(
                new vfsFile(this.scheme, this.provider, arguments.path, res.meta),
                "vfsFile"
            );
        }
    }

    function readBinary(required string path){
        if (!exists(arguments.path)){
            throw "[#arguments.path#] doesn't exist";
        } else {
            var res = this.storage.get(arguments.path);
            return res.file;
        }
    }

    public boolean function exists(required string path){
        return this.storage.exists(arguments.path);
    }

    public array function list(required any resource, boolean recurse=false) localmode=true{
        local._path = arguments.resource.path;
        local._len = len(arguments.resource.path);
        local._depth = listLen(_path, this.separator);
        local.resources = [];

        logger(text="vfsStorage #_path# listResources [#structKeyList(this.storage.all())#]");

        loop collection="#this.storage.all()#" index="local.index" item="local.file"{

            local.res = local.file.meta;
            local.fileParentPath = mid(res.path, 1, _len);

            if (res.path neq _path // ignore itself!
                    && fileParentPath eq _path){
                if (arguments.recurse || res.depth == _depth){
                    arrayAppend(resources, new vfsDebugWrapper(
                        new vfsFile(this.scheme, this.provider, res.path, res),
                        "vfsFile"
                    ));
                }
            } else {
                //logger(text="NO MATCH: [#resource.path# vs #_path#] listResources [#res.path# vs #local.fileParentPath#] (#_depth# vs #res.depth#)");
            }
        }
        logger(text="vfsStorage #_path# listResources [#structCount(this.storage.all())#] returned #arrayLen(resources)# resources");
        return resources;
    }

    public void function createDirectoryPath(any resource, any vfs){
        // special case, creating the root folder
        if (arguments.resource.path eq this.separator){
            createDirectoryEntry(arguments.resource);
            return;
        }
        var _path = listToArray(arguments.resource.path, this.separator);
        var newpath = [];
        for (var f = 1; f lte arrayLen(_path); f++){
            ArrayAppend(newpath, _path[f]);
            var folder = this.separator & ArrayToList(newPath, this.separator);
            ////////  how to create a resource here?
            if (!exists(folder)){
                createDirectoryEntry(arguments.vfs.getResource(folder));
            }
        }
    }

    public void function createDirectoryEntry(any resource){
        arguments.resource.IsDir = true;
        arguments.resource.setExists(true);
        arguments.resource.name = listLast(arguments.resource.path,"/\");
        arguments.resource.setLastModified();
        logger("vfsStorage createDirectoryEntry:  [#arguments.resource.path# dir:#arguments.resource.isDir# exists:#arguments.resource.exists()#, #arguments.resource._exists#]");
        add(arguments.resource);
    }
    /*
    public any function onMissingMethod(string name, struct args){
        logger(text="VFSstorage #arguments.name#(#SerializeJson(args)#)");
        if (isCustomFunction(this["_#arguments.name#"]))
            return invoke(this, "_#arguments.name#", arguments.args);
        else
           throw "#arguments.name# not implemented";
    }
    */
}