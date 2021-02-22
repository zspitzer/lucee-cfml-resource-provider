component extends="vfsBase" {
    public any function init(struct args){
        this.args = arguments.args;
        this.store = create();
        this.separator = this.args.separator;
        if (structKeyExists(this.args, "dir"))
            this.dir = this.args.dir;
        else
            this.dir = getTempDirectory();
        return this;
    }

    function create(){
        //logger(text="vfsStoreFileSystem: create file store [#this.dir#]");
        //var structType = "normal";// this.args["case-sensitive"] ? "casesensitive" : "normal"; // acf 2001
        //return structNew(structType);
    }

    function exists(string path){
        var p = getPath(arguments.path);
        if (fileExists(p))
            return true;
        if (DirectoryExists(p))
            return true;
        else
            return false;
    }

    function set(any resource, any data){
        var p = getPath(arguments.resource.path);
        if (arguments.resource.isDirectory()){
            if (!DirectoryExists(p))
                DirectoryCreate(p);
        } else {
            if (structKeyExists(arguments.data, "file"))
                fileWrite(p, arguments.data.file);
            else
                fileWrite(p, ""); // ignore data, create an empty file
        }
    }

    function get(string path){
        var p = getPath(arguments.path);
        //logger("get:" & p);
        if (!exists(p)){
            if (DirectoryExists(p)){
                var st = {
                    meta: {
                        name: listlast(arguments.path, "\/"),
                        path: arguments.path,
                        depth: listLen(arguments.path,"\/") + 1,
                        dateLastModified: "",
                        isDir: true,
                        size: 0,
                        _exists: true
                    }
                };
            } else {
                return {}; // doesn't exist
            }
        } else {
            var f = getFileInfo(p);
            var st = {
                meta: {
                    name: f.name,
                    path: arguments.path,
                    depth: listLen(arguments.path,"\/") + 1,
                    dateLastModified: f.dateLastModified,
                    isDir: (f.type == "dir"),
                    size: f.size,
                    _exists: true
                }
            };
        }
        return st;
    }

    function readBinary(string path){
        return fileRead(getPath(arguments.path));
    }

    function delete(required any resource, boolean recursive=false){
        var p = getPath(arguments.resource.path);
        if (arguments.resource.isDirectory())
            DirectoryDelete(p, arguments.recursive);
        else
            FileDelete(p);
    }

    struct function all(string path=this.separator, boolean recurse=false) { // a folder based store could use path
        var q = DirectoryList(path=getPath(arguments.path),listinfo="query", recurse=arguments.recurse);
        var st ={};
        var l = len(this.dir);
        //logger("DirectoryList.all(path=#getPath(arguments.path)#, listinfo='query', recurse=#arguments.recurse#)");
        loop query="#q#"{
            local.folder = normalizePath(mid(q.directory, l));// & this.separator; //strip off the actual dir
            //logger("DirectoryList.all file [" & this.dir & "] [" & q.directory & "] [" & local.folder & "] ");
            var meta ={
                name: q.name,
                dateLastModified: q.dateLastModified,
                size: q.size,
                _exists: true
            };
            var key = normalizePath(local.folder & this.separator & q.name);
            if (q.type == "dir"){
                meta.isDir = true;
                meta.path = key;
            } else {
                meta.isDir = false;
                meta.path = local.folder;
            }
            meta.depth = listLen(meta.path,"\/")-1;
            if (meta.depth < 1)
                meta.depth = 0;

            st[key] =  {
                meta: meta
            };
        }
        return st;
    }

    function count(){
        var root = DirectoryExists(this.dir);
        //logger("Count: DirectoryExists(#this.dir#) #root#")
        return root ? 1 : 0;
    }

    function clear(){
        throw "not implemented";
        //this.store = create();
    }

    function usesFolders(){
        return true;
    }

    function getPath(required string path){
        if (arguments.path == "/" || arguments.path == "\")
            return this.dir;
        var p = this.dir & arguments.path;
        //logger(p);
        return p;
    }
}