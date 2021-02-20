component /*implements="resource"  accessors=true */ {
    property name="files" type="struct";

    public any function init(string scheme){
        variables.debug = false;
        if (variables.debug)
            writeLog(text="#SerializeJson(arguments)#");
        this.separator = "/";
        this.storage = new vfsStorage(scheme, this.separator);
        this.scheme = arguments.scheme;

        var root =  new vfsFile(this.scheme, this, this.separator);
        _createDirectory(root, true);
        return this;
    }

    public any function _getResource(String path){
        var _path = cleanPath(arguments.path);
        if (this.storage.exists(_Path)){
            if (variables.debug)
                writeLog(text="VFS _getResource #_path#");
            return this.storage.read(_path).resource;
        }
        if (variables.debug)
            writeLog(text="VFS _getResource DUMMY #_path#");
        return new vfsFile(this.scheme, this, _path);
    }

    public any function _getRealResource(resource, String path){
        return _getResource(path);
    }

    public array function _listResources(any resource, boolean recurse=false){
        return this.storage.list(resource, recurse);
    };

    public any function _getParentResource(any resource, boolean empty=false){
        var parentPath = _getParent(arguments.resource);
        if (this.storage.exists(parentPath)){
            if (variables.debug)
                writeLog(text="_getParentResource [#parentPath#] from [#arguments.resource.path#]");
            return this.storage.read(parentPath).resource;
        }
        if (arguments.empty)
            return _getResource(parentPath);
        if (variables.debug)
            writeLog(text="_getParentResource [#parentPath#] from [#arguments.resource.path#] not found");
        return; // null
    }

    public void function _createFile(any resource, boolean createParentWhenNotExists=false){
        local.parent = _getParentResource(resource, true);
        if (!local.parent.exists){
            if (arguments.createParentWhenNotExists){
                _createDirectory(local.parent, true);
            } else {
                throw "Cannot create file, parent directory [#local.parent.path#] doesn't exist";
            }
        }
        resource.IsDir = false;
        this.storage._add(resource);
    }

    public void function _createDirectory(any resource, boolean createParentWhenNotExists=false){
        local.parent = _getParentResource(resource, true);
        if (!local.parent.exists){
            if (arguments.createParentWhenNotExists)
                this.storage.createDirectoryPath(local.parent, this);
            else
                throw "Cannot create directory, parent directory [#local.parent.path#] doesn't exist";
        }
        this.storage.createDirectoryEntry(resource);
    }

    public void function _remove(any resource, boolean force){
        var children = _listResources(resource, true);
        if (arrayLen(children) gt 0){
            if (!arguments.force){
                throw "Cannot Delete, child resources found";
            }
            // recursive delete
            loop array="#children#" index="local.file" {
                this.storage.remove(local.file.path);
            }
        }
        this.storage.remove(resource.path);
    }

    private function cleanPath(string _path){
        return this.separator & ArrayToList(listToArray(arguments._path,"/\"), this.separator);
    }
    public string function _getParent(any resource){
        var parent = listToArray(arguments.resource.path,"/\");
        if (ArrayLen(parent) eq 0)
            return this.separator; // root
        ArrayDeleteAt(parent, ArrayLen(parent));
        return this.separator & ArrayToList(parent, this.separator);
    };

    public any function onMissingMethod(string name, struct args){
        if (variables.debug)
            writeLog(text="------------------VFS #SerializeJson(arguments)#");
        if (isCustomFunction(this["_#arguments.name#"])){
            return invoke(this, "_#arguments.name#", arguments.args);
        } else {
            throw "#arguments.name# not implemented";
        }
    }

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
}