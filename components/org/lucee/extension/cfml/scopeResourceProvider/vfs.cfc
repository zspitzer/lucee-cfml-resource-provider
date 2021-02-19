component /*implements="resource" */ accessors=true {
    public any function init(string scheme){
        writeLog(text="#SerializeJson(arguments)#");
        this.storage = new vfsStorage(scheme);
        this.scheme = arguments.scheme;
        this.separator = "/";
        var vfs =  new vfsFile(this.scheme, this, this.separator);
        vfs._createDirectory(false);
        this.files = {
            "#this.separator#": vfs
        };
        return this;
    }

    public any function onMissingMethod(string name, struct args){
        writeLog(text="------------------VFS #SerializeJson(arguments)#");
        if (isCustomFunction(this["_#arguments.name#"]))
            return invoke(this, "_#arguments.name#", arguments.args);
        else
            throw "#arguments.name# not implemented";
    }

    function _getResource(String path){
        var _path = cleanPath(arguments.path);

        if (structKeyExists(this.files, _path)){
            writeLog(text="VFS _getResource #_path#");
            return this.files[_path];

        }
        writeLog(text="VFS _getResource DUMMY #_path#");
        return new vfsFile(this.scheme, this, _path);
    };

    function _getRealResource(resource, String path){
        return _getResource(path);
    };

    public boolean function _exists(){
        writeLog(text="VFS exists");
        return (structCount(this.files) gt 0);
    };

    public boolean function _isAbsolute(){
        return true;
    };

    function cleanPath(string _path){
        return this.separator & ArrayToList(listToArray(arguments._path,"/\"), this.separator);
    }

    function _createFile(any resource, boolean createParentWhenNotExists){
        local.parent = _getParentResource(resource, true);
        if (!local.parent.exists){
            if (arguments.createParentWhenNotExists)
                _createDirectory(local.parent, true);
            else
                throw "Cannot create file, parent directory [#local.parent.path#] doesn't exist";
        }

        writeLog(text="_createFile A");
        resource.exists = true;
        resource.IsDir = false;
        resource.name = listLast(resource.path,"/\");
        resource.LastModified = now();
        this.files[resource.path] = resource;
        writeLog(text="_createFile B");
    };

    function _createDirectory(any resource, boolean createParentWhenNotExists){
        // need to add to children...
        // todo createParentWhenNotExists

        /* URRRGGGHHH this next line throws Component [vfs] has no accessible Member with name [FILES]
        // local.parent =_getParentResource(resource, true);

        but _createDirectoryEntry works and can access this.files???

        */

        /*
        local.parent = _getParentResource(resource, true);
        if (!local.parent.exists){
            if (arguments.createParentWhenNotExists)
                _createDirectoryPath(local.parent);
            else
                throw "Cannot create directory, parent directory [#local.parent.path#] doesn't exist";
        }
        */

        _createDirectoryEntry(resource);
        /*
        resource.IsDir = true;
        resource.exists = true;
        resource.name = listLast(resource.path,"/\");
        resource.LastModified = now();
        this.files[resource.path] = resource;
        */
        return;
    };

    function _createDirectoryPath(any resource){
        writeLog(text="implemeted _createDirectoryPath");
    }

    function _createDirectoryEntry(any resource){
        resource.IsDir = true;
        resource.exists = true;
        resource.name = listLast(resource.path,"/\");
        resource.LastModified = now();
        this.files[resource.path] = resource;
        return;
    }

    void function _remove(any resource, boolean force){
        // todo recursive, check childern
        var children = _listResources(resource, true);
        if (arrayLen(children) gt 0){
            if (!arguments.force)
                throw "Cannot Delete, child resources found";
            // recursive delete
            loop array="#children#" index="local.i" item="#local.file#" {
                _removeEntry(local.file);
            }
        }
        _removeEntry(resource);
    };

    function _removeEntry(any resource){
        this.storage._remove(resource.path);
        structDelete(this.files, resource.path);
    };

    array function _listResources(any resource, boolean recurse=false){
        local._path = resource.path;
        local._len = len(resource.path);
        local._depth = listLen(local._path, "/");
        local.resources = [];

        loop collection="#this.files#" index="local.index" item="local.file"{
            local._fileParentPath = mid(local.file.path, 1, local._len);

            writeLog(text="depth #local.file.depth# == #local._depth#");
            writeLog(text="path #local.file.path# == #local._path# [#local._fileParentPath#]");

            if (local.file.path neq local._path // ignore itself!
                    && local._fileParentPath eq local._path){
                if (arguments.recurse || local.file.depth == local._depth)
                    arrayAppend(local.resources, local.file);
            //} else { writeLog(text="NO MATCH");
            }
        }
        writeLog(text="#local._path# listResources [#structKeyList(this.files)#] returned #arrayLen(local.resources)# resources");
        return local.resources;
    };

    function _getParent(any resource){
        var parent = listToArray(arguments.resource.path,"/\");
        if (ArrayLen(parent) eq 0)
            return this.separator;
        ArrayDeleteAt(parent, ArrayLen(parent));
        return this.separator & ArrayToList(parent, this.separator);
    };

    function _getParentResource(any resource, boolean empty=false){
        var parent = this._getParent(arguments.resource);
        if (structKeyExists(this.files, parent)){
            writeLog(text="_getParentResource [#parent#] from [#arguments.resource.path#]");
            return this.files[parent];
        }
        if (arguments.empty)
            return _getResource(parent);
        writeLog(text="_getParentResource [#parent#] from [#arguments.resource.path#] missingResource [#structKeyList(this.files)#]");
    };
}