component {
    public any function init(string scheme, string separator){
        variables.debug = false;
        this.separator = "/";
        this.scheme = arguments.scheme;
        this.storage = {};
        return this;
    }

    public any function onMissingMethod(string name, struct args){
        if (variables.debug)
            writeLog(text="VFSstorage #arguments.name#(#SerializeJson(args)#)");
        if (isCustomFunction(this["_#arguments.name#"]))
            return invoke(this, "_#arguments.name#", arguments.args);
        else
            throw "#arguments.name# not implemented";
    }

    function _add(any resource){
        if (variables.debug)
            writeLog(text="VFSstorage ADD #arguments.resource.path#");

        resource.exists = true;
        resource.name = listLast(resource.path,"/\");
        resource.LastModified = now();

        //writeLog("_add:  [#resource.path# dir:#resource.isDir# exists:#resource.exists#]");

        this.storage[arguments.resource.path] = {
            resource: arguments.resource
        }
        return;
    }

    function _update(any resource, any file){
        if (variables.debug)
            writeLog(text="VFSstorage update #resource.path#");
        resource.LastModified = now();
        resource.length = len(arguments.file);
        this.storage[arguments.resource.path].file = arguments.file;
        // resource is passed by reference, should be updated in storage
        return;
    }

    function _remove(String path){
        structDelete(this.storage, arguments.path);
    }

    function _read(String path){
        if (!_exists(arguments.path)){
            throw "[#arguments.path#] doesn't exist";
        } else {
            return this.storage[arguments.path];
        }
    }

    public boolean function _exists(string path){
        return structKeyExists(this.storage, arguments.path);
    }

    public array function _list(any resource, boolean recurse=false) localmode=true{
        local._path = resource.path;
        local._len = len(resource.path);
        local._depth = listLen(_path, this.separator);
        local.resources = [];

        if (variables.debug)
            writeLog(text="#_path# listResources [#structKeyList(this.storage)#]");

        loop collection="#this.storage#" index="local.index" item="local.file"{
            local.res = local.file.resource;
            local.fileParentPath = mid(res.path, 1, _len);

            if (res.path neq _path // ignore itself!
                    && fileParentPath eq _path){
                if (arguments.recurse || res.depth == _depth)
                    arrayAppend(resources, res);
            } else {
                //writeLog(text="NO MATCH: [#resource.path# vs #_path#] listResources [#res.path# vs #local.fileParentPath#] (#_depth# vs #res.depth#)");
            }
        }
        if (variables.debug)
            writeLog(text="#_path# listResources [#structCount(this.storage)#] returned #arrayLen(resources)# resources");
        return resources;
    }

    public void function _createDirectoryPath(any resource, any vfs){
        // special case, creating the root folder
        if (resource.path eq this.separator){
            _createDirectoryEntry(resource);
            return;
        }
        var _path = listToArray(resource.path, this.separator);
        var newpath = [];
        for (var f = 1; f lte arrayLen(_path); f++){
            ArrayAppend(newpath, _path[f]);
            var folder = this.separator & ArrayToList(newPath, this.separator);
            ////////  how to create a resource here?
            if (!_exists(folder)){
                _createDirectoryEntry(vfs._getResource(folder));
            }
        }
    }

    public void function _createDirectoryEntry(any resource){
        if (variables.debug)
            writeLog("_createDirectoryEntry:  [#resource.path# dir:#resource.isDir# exists:#resource.exists#]");
        resource.IsDir = true;
        resource.exists = true;
        resource.name = listLast(resource.path,"/\");
        resource.LastModified = now();
        _add(resource);
    }
}