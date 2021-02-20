component /*implements="resource"  accessors=true */ extends="vfsBase" {

    public any function init(string scheme){
        logger(text="#SerializeJson(arguments)#");
        this.separator = "/";
        this.scheme = arguments.scheme;
        this.storage = new vfsDebugWrapper(
            new vfsStorage(this.scheme, this.separator, this),
            "vfsStorage"
        );
        var root =  new vfsDebugWrapper(
            new vfsFile(this.scheme, this, this.separator),
            "rootVFSfile"
        );
        createDirectory(root, true);
        return this;
    }

    public any function getResource(required string path){
        var _path = cleanPath(arguments.path);
        if (this.storage.exists(_Path)){
            logger(text="VFS getResource #_path#");
            return this.storage.read(_path);
        }
        logger(text="VFS getResource DUMMY #_path#");
        return new vfsDebugWrapper(
            new vfsFile(this.scheme, this, _path),
            "vfsFile"
        );
    }

    public any function getRealResource(required any resource, String path){
        return getResource(arguments.path);
    }

    public array function listResources(required any resource, boolean recurse=false){
        return this.storage.list(arguments.resource, arguments.recurse);
    };

    public any function getParentResource(required any resource, boolean empty=false){
        var parentPath = getParent(arguments.resource);
        if (this.storage.exists(parentPath)){
            logger(text="VFS getParentResource [#parentPath#] from [#arguments.resource.path#]");
            return this.storage.read(parentPath);
        }
        if (arguments.empty)
            return getResource(parentPath);
        logger(text=" VFS getParentResource [#parentPath#] from [#arguments.resource.path#] not found");
        return; // null
    }

    public void function createFile(required any resource, boolean createParentWhenNotExists=false){
        local.parent = getParentResource(arguments.resource, true);
        if (!local.parent.exists()){
            if (arguments.createParentWhenNotExists){
                _createDirectory(local.parent, true);
            } else {
                throw "Cannot create file, parent directory [#local.parent.path#] doesn't exist";
            }
        }
        arguments.resource.IsDir = false;
        this.storage.add(arguments.resource);
    }

    public void function createDirectory(required any resource, boolean createParentWhenNotExists=false){
        local.parent = getParentResource(arguments.resource, true);
        if (!local.parent.exists()){
            if (arguments.createParentWhenNotExists)
                this.storage.createDirectoryPath(local.parent, this);
            else
                throw "Cannot create directory, parent directory [#local.parent.path#] doesn't exist";
        }
        this.storage.createDirectoryEntry(arguments.resource);
    }

    public void function remove(required any resource, boolean force=false){
        var children = listResources(arguments.resource, true);
        if (arrayLen(children) gt 0){
            if (!arguments.force){
                throw "Cannot Delete, [#arrayLen(children)#] child resources found";
            }
            // recursive delete
            loop array="#children#" index="local.file" {
                this.storage.remove(local.file.path);
            }
        }
        this.storage.remove(arguments.resource.path);
    }

    private function cleanPath(required string _path){
        return this.separator & ArrayToList(listToArray(arguments._path,"/\"), this.separator);
    }
    public string function getParent(required any resource){
        var parent = listToArray(arguments.resource.path,"/\");
        if (ArrayLen(parent) eq 0)
            return this.separator; // root
        ArrayDeleteAt(parent, ArrayLen(parent));
        return this.separator & ArrayToList(parent, this.separator);
    };

    /*
    public any function onMissingMethod(string name, struct args){
        logger(text="------------------VFS #SerializeJson(arguments)#");
        if (isCustomFunction(this["_#arguments.name#"])){
            return invoke(this, "_#arguments.name#", arguments.args);
        } else {
            throw "#arguments.name# not implemented";
        }
    }




    // i don't think this ever gets called?
    public boolean function exists(){
        logger(text="VFS exists");
        return (structCount(this.files) gt 0);
    };

    public boolean function isAbsolute(){
        return true;
    };
    */
}