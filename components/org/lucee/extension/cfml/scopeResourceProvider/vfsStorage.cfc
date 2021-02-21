component extends="vfsBase" {
    public any function init(struct cfg, string separator, required any provider, required any store){
        this.separator = "/";
        this.scheme = arguments.cfg.scheme;
        this.provider = arguments.provider;
        this.cfg = arguments.cfg;
        this.storage = arguments.store;
        return this;
    }

    public void function add(required any resource){
        logger(text="VFSstorage ADD #arguments.resource.path#");

        arguments.resource.setExists(true);
        arguments.resource.name = listLast(arguments.resource.path,"/\");
        arguments.resource.setLastModified();

        //logger("vfsStorage add:  [#arguments.resource.path# dir:#arguments.resource.isDir# exists:#arguments.resource.exists()#]");

        this.storage.set(arguments.resource.path,{
            meta: arguments.resource.toStruct()
        });
    }

    public void function update(required any resource, required any file){
        logger(text="vfsStorage update #arguments.resource.path#");
        arguments.resource.setLastModified();
        arguments.resource._length = len(arguments.file);
        this.storage.set(arguments.resource.path, {
            meta: arguments.resource.toStruct(),
            file: arguments.file
        });
    }

    public void function remove(required string path){
        if (arguments.path neq this.separator) // don't delete the root (other providers like ram:// throw an error)
            this.storage.delete(arguments.path);
    }

    public any function read(required string path){
        var res = this.storage.get(arguments.path);
        if (structCount(res) eq 0)
            res.meta = {};
            //throw "[#arguments.path#] doesn't exist";
//        } else {
            //logger("vfsStorage read:  [#res.meta.path# dir:#res.meta.isDir# exists:#res.meta._exists#]");
        return new vfsDebugWrapper(
            new vfsFile(this.scheme, this.provider, this, arguments.path, res.meta),
            "vfsFile"
        );
//        }
    }

    public any function readBinary(required string path){
        var res = this.storage.get(arguments.path);
        if (structCount(res) eq 0){
            throw "[#arguments.path#] doesn't exist";
        } else {
            return res.file;
        }
    }

    public boolean function exists(required string path){
        return this.storage.exists(arguments.path);
    }

    public numeric function count(){
        return this.storage.count();
    }

    public array function list(required any resource, boolean recurse=false, boolean anyMatch=false) localmode=true{
        local._path = arguments.resource.path;
        /* TODO check if last char is /, if not add, to avoid false matches with similiar file names
        if (right(local._path,1) neq this.separator)
            local._path = local._path;// & this.separator;
        */
        local._len = len(arguments.resource.path);
        local._depth = listLen(_path, this.separator);
        local.resources = [];

       // logger(text="vfsStorage #_path# listResources [#structKeyList(this.storage.all())#]");

        //TODO use this.storage.isFlat() ... i.e. folder based different response, need to recurse manually

        loop collection="#this.storage.all()#" index="local.index" item="local.file"{

            local.res = local.file.meta;
            local.fileParentPath = mid(res.path, 1, _len);

            if (fileParentPath eq _path
                    && res.path neq _path ){ // ignore itself!
                if (arguments.recurse || res.depth == _depth){
                    arrayAppend(resources, new vfsDebugWrapper(
                        new vfsFile(this.scheme, this.provider, this, res.path, res),
                        "vfsFile"
                    ));
                    if (arguments.anyMatch)
                        return resources; // sort circuit when checking for children when deleting, one match is enough
                }
            } else {
                //logger(text="NO MATCH: [#resource.path# vs #_path#] listResources [#res.path# vs #local.fileParentPath#] (#_depth# vs #res.depth#)");
            }
        }
       // logger(text="vfsStorage #_path# listResources [#structCount(this.storage.all())#] returned #arrayLen(resources)# resources");
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
                createDirectoryEntry(arguments.vfs.getResource(folder, this));
            }
        }
    }

    public void function createDirectoryEntry(any resource){
        arguments.resource.IsDir = true;
        arguments.resource.setExists(true);
        arguments.resource.name = listLast(arguments.resource.path,"/\");
        arguments.resource.setLastModified();
        //logger("vfsStorage createDirectoryEntry:  [#arguments.resource.path# dir:#arguments.resource.isDir# exists:#arguments.resource.exists()#, #arguments.resource._exists#]");
        add(arguments.resource);
    }

}