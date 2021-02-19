component /*implements="resource"  accessors=true */ {
    property name="files" type="struct";

    public any function init(string scheme){
        variables.debug = false;
        if (variables.debug)
            writeLog(text="#SerializeJson(arguments)#");
        this.storage = new vfsStorage(scheme);
        this.scheme = arguments.scheme;
        this.separator = "/";
        this.files = {};
        var vfs =  new vfsFile(this.scheme, this, this.separator);
        vfs._createDirectory(true);
        return this;
    }

    public any function onMissingMethod(string name, struct args){
        if (variables.debug)
            writeLog(text="------------------VFS #SerializeJson(arguments)#");
        if (isCustomFunction(this["_#arguments.name#"])){
            return invoke(this, "_#arguments.name#", arguments.args);
        } else {
            throw "#arguments.name# not implemented";
        }
    }

    public any function _getResource(String path){
        var _path = cleanPath(arguments.path);

        if (structKeyExists(this.files, _path)){
            if (variables.debug)
                writeLog(text="VFS _getResource #_path#");
            return this.files[_path];
        }
        if (variables.debug)
            writeLog(text="VFS _getResource DUMMY #_path#");
        return new vfsFile(this.scheme, this, _path);
    };

    public any function _getRealResource(resource, String path){
        return _getResource(path);
    };

    /*


    // i don't think this ever gets called?
    public boolean function _exists(){
        writeLog(text="VFS exists");
        return (structCount(this.files) gt 0);
    };

    public boolean function _isAbsolute(){
        return true;
    };
    */
    private function cleanPath(string _path){
        return this.separator & ArrayToList(listToArray(arguments._path,"/\"), this.separator);
    }

    public void function _createFile(any resource, boolean createParentWhenNotExists){
        local.parent = _getParentResource(resource, true);
        if (!local.parent.exists){
            if (arguments.createParentWhenNotExists){
                _createDirectory(local.parent, true);
            } else {
                throw "Cannot create file, parent directory [#local.parent.path#] doesn't exist";
            }
        }
        resource.exists = true;
        resource.IsDir = false;
        resource.name = listLast(resource.path,"/\");
        resource.LastModified = now();
        this.files[resource.path] = resource;
    };

    public void function _createDirectory(any resource, boolean createParentWhenNotExists){
        local.parent = _getParentResource(resource, true);
        if (!local.parent.exists){
            if (arguments.createParentWhenNotExists)
                _createDirectoryPath(local.parent);
            else
                throw "Cannot create directory, parent directory [#local.parent.path#] doesn't exist";
        }
        _createDirectoryEntry(resource);
    };

    private function _createDirectoryPath(any resource){
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
            if (!structKeyExists(this.files, folder)){
                _createDirectoryEntry(_getResource(folder));
            }
        }
    }

    private function _createDirectoryEntry(any resource){
        if (variables.debug)
            writeLog("_createDirectoryEntry:  [#resource.path#]");
        resource.IsDir = true;
        resource.exists = true;
        resource.name = listLast(resource.path,"/\");
        resource.LastModified = now();
        this.files[resource.path] = resource;
        return;
    }

    public void function _remove(any resource, boolean force){
        // todo recursive, check childern
        var children = _listResources(resource, true);
        if (arrayLen(children) gt 0){
            if (!arguments.force){
                throw "Cannot Delete, child resources found";
            }
            // recursive delete
            loop array="#children#" index="local.file" {
                _removeEntry(local.file);
            }
        }
        _removeEntry(resource);
    };

    private function _removeEntry(any resource){
        this.storage._remove(resource.path);
        structDelete(this.files, resource.path);
    };

    public array function _listResources(any resource, boolean recurse=false){
        local._path = resource.path;
        local._len = len(resource.path);
        local._depth = listLen(local._path, "/");
        local.resources = [];

        loop collection="#this.files#" index="local.index" item="local.file"{
            local._fileParentPath = mid(local.file.path, 1, local._len);

           // writeLog(text="depth #local.file.depth# == #local._depth#");
           // writeLog(text="path #local.file.path# == #local._path# [#local._fileParentPath#]");

            if (local.file.path neq local._path // ignore itself!
                    && local._fileParentPath eq local._path){
                if (arguments.recurse || local.file.depth == local._depth)
                    arrayAppend(local.resources, local.file);
            //} else { writeLog(text="NO MATCH");
            }
        }
        if (variables.debug)
            writeLog(text="#local._path# listResources [#structKeyList(this.files)#] returned #arrayLen(local.resources)# resources");
        return local.resources;
    };

    public string function _getParent(any resource){
        var parent = listToArray(arguments.resource.path,"/\");
        if (ArrayLen(parent) eq 0)
            return this.separator;
        ArrayDeleteAt(parent, ArrayLen(parent));
        return this.separator & ArrayToList(parent, this.separator);
    };

    public any function _getParentResource(any resource, boolean empty=false){
        var parent = this._getParent(arguments.resource);
        if (structKeyExists(this.files, parent)){
            if (variables.debug)
                writeLog(text="_getParentResource [#parent#] from [#arguments.resource.path#]");
            return this.files[parent];
        }
        if (arguments.empty)
            return _getResource(parent);
        if (variables.debug)
            writeLog(text="_getParentResource [#parent#] from [#arguments.resource.path#] missingResource [#structKeyList(this.files)#]");
    };
}