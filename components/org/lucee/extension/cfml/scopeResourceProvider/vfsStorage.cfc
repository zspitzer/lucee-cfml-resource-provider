component extends="vfsBase" {
    public any function init(string scheme, string separator){
        this.separator = "/";
        this.scheme = arguments.scheme;
        this.storage = {};
        return this;
    }

    function add(any resource){
        logger(text="VFSstorage ADD #arguments.resource.path#");

        resource.setExists(true);
        resource.name = listLast(resource.path,"/\");
        resource.setLastModified();

        logger("vfsStorage add:  [#resource.path# dir:#resource.isDir# exists:#resource.exists()#]");

        this.storage[arguments.resource.path] = {
            resource: arguments.resource
        }
        return;
    }

    function update(any resource, any file){
        logger(text="vfsStorage update #resource.path#");
        resource.setLastModified();
        resource._length = len(arguments.file);
        this.storage[arguments.resource.path].file = arguments.file;
        // resource is passed by reference, should be updated in storage
        return;
    }

    function remove(String path){
        if (arguments.path neq "/") // don't delete the root (other providers like ram:// throw an error)
            structDelete(this.storage, arguments.path);
    }

    function read(String path){
        if (!exists(arguments.path)){
            throw "[#arguments.path#] doesn't exist";
        } else {
            var res = this.storage[arguments.path];
            logger("vfsStorage read:  [#res.resource.path# dir:#res.resource.isDir# exists:#res.resource.exists()#]");
            return res;
        }
    }

    public boolean function exists(string path){
        return structKeyExists(this.storage, arguments.path);
    }

    public array function list(any resource, boolean recurse=false) localmode=true{
        local._path = resource.path;
        local._len = len(resource.path);
        local._depth = listLen(_path, this.separator);
        local.resources = [];

        logger(text="vfsStorage #_path# listResources [#structKeyList(this.storage)#]");

        loop collection="#this.storage#" index="local.index" item="local.file"{
            local.res = local.file.resource;
            local.fileParentPath = mid(res.path, 1, _len);

            if (res.path neq _path // ignore itself!
                    && fileParentPath eq _path){
                if (arguments.recurse || res.depth == _depth)
                    arrayAppend(resources, res);
            } else {
                //logger(text="NO MATCH: [#resource.path# vs #_path#] listResources [#res.path# vs #local.fileParentPath#] (#_depth# vs #res.depth#)");
            }
        }
        logger(text="vfsStorage #_path# listResources [#structCount(this.storage)#] returned #arrayLen(resources)# resources");
        return resources;
    }

    public void function createDirectoryPath(any resource, any vfs){
        // special case, creating the root folder
        if (resource.path eq this.separator){
            createDirectoryEntry(resource);
            return;
        }
        var _path = listToArray(resource.path, this.separator);
        var newpath = [];
        for (var f = 1; f lte arrayLen(_path); f++){
            ArrayAppend(newpath, _path[f]);
            var folder = this.separator & ArrayToList(newPath, this.separator);
            ////////  how to create a resource here?
            if (!exists(folder)){
                createDirectoryEntry(vfs.getResource(folder));
            }
        }
    }

    public void function createDirectoryEntry(any resource){
        resource.IsDir = true;
        resource.setExists(true);
        resource.name = listLast(resource.path,"/\");
        resource.setLastModified();
        logger("vfsStorage createDirectoryEntry:  [#resource.path# dir:#resource.isDir# exists:#resource.exists()#, #resource._exists#]");
        add(resource);
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