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
        //logger(text="VFSstorage ADD #arguments.resource.path#");

        arguments.resource.setExists(true);
        arguments.resource.name = listLast(arguments.resource.path,"/\");
        arguments.resource.setLastModified();

        //logger("vfsStorage add:  [#arguments.resource.path# dir:#arguments.resource.isDir# exists:#arguments.resource.exists()#]");

        this.storage.set(arguments.resource,{
            meta: arguments.resource.toStruct()
        });
    }

    public void function update(required any resource, required any file){
        //logger(text="vfsStorage update #arguments.resource.path#");
        arguments.resource.setLastModified();
        arguments.resource.size = len(arguments.file);
        this.storage.set(arguments.resource, {
            meta: arguments.resource.toStruct(),
            file: arguments.file
        });
    }

    public void function remove(required any resource, boolean recursive=false){
        //logger(text="vfsStorage REMOVE #arguments.resource.path# #arguments.recursive#");
        if (arguments.resource.path neq this.separator) // don't delete the root (other providers like ram:// throw an error)
            this.storage.delete(arguments.resource, arguments.recursive);
    }

    public any function read(required string path){
        var res = this.storage.get(arguments.path);
        if (structCount(res) eq 0){
            res.meta = {};
            //throw "[#arguments.path#] doesn't exist";
        } else {
           // logger("vfsStorage read:  [#res.meta.path# dir:#res.meta.isDir# exists:#res.meta._exists#]");
        }
        if (variables.debug){
            return new vfsDebugWrapper(
                new vfsFile(this.scheme, this.provider, this, arguments.path, res.meta),
                "vfsFile"
            );
        } else {
            return new vfsFile(this.scheme, this.provider, this, arguments.path, res.meta);
        }
    }

    public any function readBinary(required string path){
        var res = this.storage.getBinary(arguments.path);
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

    public numeric function usesFolders(){
        return this.storage.usesFolders();
    }

    public array function list(required any resource, boolean recurse=false, boolean anyMatch=false) localmode=true{
        local._path = arguments.resource.path;
        local.resources = [];
        local.files = this.storage.all(path=local._path, recurse=arguments.recurse);

        //logger(text="vfsStorage listResources(path:#_path#,recurse:#arguments.recurse#) [#structKeyList(local.files)#]");

        if (this.storage.usesFolders()){
            // folder based different response, no need need to recurse manually
            loop collection="#local.files#" index="local.index" item="local.file" {
                arrayAppend(resources,// new vfsDebugWrapper(
                    new vfsFile(this.scheme, this.provider, this, local.file.meta.path, local.file.meta, true)//,"vfsFile")
                );

                if (arguments.anyMatch)
                    return resources; // sort circuit when checking for children when deleting, one match is enough
               // logger(text="Listresource :[#local.file.meta.path#] #local.file.meta.name# #local.file.meta.isdir#");
            }
        } else {
            // flat file system, i.e a stuct, need to filter
            local._len = len(arguments.resource.path);
            local._depth = listLen(_path, this.separator);

            loop collection="#local.files#" index="local.index" item="local.file"{

                local.res = local.file.meta;
                local.fileFolderPath = mid(local.res.path, 1, local._len);
                if (local.res.isDir)
                    local.fullPath = res.path;
                else
                    local.fullPath = res.path & res.name;

                //local.match = false;
                if (res.depth == _depth || arguments.recurse){ // use folder depth for performance, quicker than string matching
                    if (local.fileFolderPath eq _path
                        && local.fullPath neq _path ){ // ignore itself!

                        arrayAppend(resources,// new vfsDebugWrapper(
                            new vfsFile(this.scheme, this.provider, this, res.path, res, true)//,"vfsFile")
                        );

                        if (arguments.anyMatch)
                            return resources; // sort circuit when checking for children when deleting, one match is enough
                        //local.match = true;
                    }
                }
                //logger(text="resource #local.match# folder:[#fileFolderPath# eq #_path#] path [#fullPath# neq #_path#] depth [#res.depth# == #_depth#] ");
            }
        }
        //logger(text="vfsStorage #_path# listResources [#structCount(local.files)#] returned [#arrayLen(resources)#] resources");
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

    public function getOutputStream(required string path, boolean append){
        //logger("getOutputStream" & "[#arguments.path#]");
        return this.storage.getOutputStream(arguments.path, arguments.append);
    }

    public function getInputStream(){
        //logger("getInputStream" & "[#arguments.path#]");
        return this.storage.getInputStream(arguments.path);
    }

}