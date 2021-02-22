component /*implements="resource"  accessors=true */ extends="vfsBase" {

    public any function init(struct cfg){
        logger(text="#SerializeJson(arguments)#");
        this.separator = arguments.cfg.separator;
        this.cfg = arguments.cfg;
        this.scheme = arguments.cfg.scheme;
        return this;
    }

    // main entry point
    public any function getResource(required string path, required any storage, any store){

        if (structKeyExists(arguments, "store")){
            // create if we need to init the store
            if (variables.debug){
                arguments.storage = new vfsDebugWrapper(
                    new vfsStorage(this.cfg, this.separator, this, arguments.store),
                    "vfsStorage"
                );
            } else {
                arguments.storage = new vfsStorage(this.cfg, this.separator, this, arguments.store);
            }

            if (arguments.store.count() eq 0){
                // add a root directory
                if (variables.debug){
                    var root =  new vfsDebugWrapper(
                        new vfsFile(this.scheme, this, arguments.storage, this.separator),
                        "rootVFSfile"
                    );
                } else {
                    var root =  new vfsFile(this.scheme, this, arguments.storage, this.separator);
                }
                createDirectory(root, true);
            }
        }

        var _path = normalizePath(arguments.path);
        var res = arguments.storage.read(_path);
        if (structCount(res) gt 0){
            //logger(text="VFS getResource #_path#");
            return res;
        }
        //logger(text="VFS getResource DUMMY #_path#");
        if (variables.debug){
            return new vfsDebugWrapper(
                new vfsFile(this.scheme, this, arguments.storage, _path),
                "vfsFile"
            );
        } else {
            return new vfsFile(this.scheme, this, arguments.storage, _path);
        }
    }

    public void function createDirectory(required any resource, boolean createParentWhenNotExists=false){
        local.parent = getParentResource(arguments.resource, true);
        if (!local.parent.exists()){
            if (arguments.createParentWhenNotExists)
                arguments.resource.getStorage().createDirectoryPath(local.parent, this);
            else
                throw "Cannot create directory, parent directory [#local.parent.path#] doesn't exist";
        }
        arguments.resource.getStorage().createDirectoryEntry(arguments.resource);
    }

    public any function getParentResource(required any resource, boolean empty=false){
        var parentPath = getParent(arguments.resource);
        var res = arguments.resource.getStorage().read(parentPath);
        if (structCount(res) gt 0){
            //logger(text="VFS getParentResource [#parentPath#] from [#arguments.resource.path#]");
            return res;
        }
        if (arguments.empty)
            return getResource(parentPath, arguments.resource.getStorage());
        //logger(text=" VFS getParentResource [#parentPath#] from [#arguments.resource.path#] not found");
        return; // null
    }

    public string function getParent(required any resource){
        var parent = listToArray(arguments.resource.path,"/\");
        if (ArrayLen(parent) eq 0)
            return this.separator; // root
        ArrayDeleteAt(parent, ArrayLen(parent));
        return this.separator & ArrayToList(parent, this.separator);
    }


    public any function getRealResource(required any resource, String path){
        return getResource(arguments.path, arguments.resource.getStorage());
    }

    public array function listResources(required any resource, boolean recurse=false, boolean anyMatch=false){ // add short circuit for delete check
        return arguments.resource.getStorage().list(arguments.resource, arguments.recurse, arguments.anyMatch);
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
        arguments.resource.getStorage().add(arguments.resource);
    }

    public void function remove(required any resource, boolean force=false){
        var children = listResources(resource=arguments.resource, recurse=true, anyMatch=!arguments.force); // use short circuit for delete check
        local.store = arguments.resource.getStorage();
        if (arrayLen(children) gt 0 && children[1].path neq arguments.resource.path){
            if (!arguments.force){
                throw "Cannot Delete [#arguments.resource.path#], child resources found";
            }
            // recursive delete
            if (local.store.usesFolders()){
                // then need to sort, delete deepest first
                arraySort(
                    children,
                    function (e1, e2){
                        return len(e1.depth) lt len(e2.depth);
                    },
                    "asc"
                );
                local.store.remove(arguments.resource, true);
                return;
            } else {
                loop array="#children#" index="local.file" {
                    local.store.remove(local.file); // move into array for transaction??
                }
            }
        }
        local.store.remove(arguments.resource);
    }
}
