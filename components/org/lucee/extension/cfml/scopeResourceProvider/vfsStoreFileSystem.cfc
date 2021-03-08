component extends="vfsBase" {
    public any function init(struct args){
        this.args = arguments.args;
        this.separator = this.args.separator;
        if (structKeyExists(this.args, "dir"))
            this.dir = this.args.dir;
        else
            this.dir = getTempDirectory();
        // this.store = create();
        return this;
    }

    function create(){
        //logger(text="vfsStoreFileSystem: create file store [#this.dir#]");
        //var structType = "normal";// this.args["case-sensitive"] ? "casesensitive" : "normal"; // acf 2001
        //return structNew(structType);
    }

    function exists(string path, boolean asType = false){
        var p = getPath(arguments.path);
        //logger("exists:" & p & " " & arguments.path);
        if (fileExists(p))
            return arguments.asType ? "file" : true;
        if (DirectoryExists(p))
            return arguments.asType ? "dir" : true;
        else
            return arguments.asType ? "" : true;
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
        var e = exists(arguments.path, true);
        //logger("get:" & e);
        switch (e){
            case "dir":
                var st = {
                    meta: {
                        name: listlast(arguments.path, "\/"),
                        path: arguments.path,
                        depth: listLen(arguments.path,"\/") + 1,
                        dateLastModified: createDate(1970, 1, 1), // needs directoryInfo()
                        isDir: true,
                        size: 0,
                        _exists: true
                    }
                };
                break;
            case "file":
            var f = getFileInfo(p);
                logger(f.toJson());
            var st = {
                meta: {
                    name: f.name,
                    path: arguments.path,
                    depth: listLen(arguments.path,"\/") + 1,
                        dateLastModified: f.LastModified,
                        isDir: false,
                    size: f.size,
                    _exists: true
                }
            };
                break;
            default:
                //logger("get: missing" & arguments.path);
                var st = {};
                break;
        }
        return st;
    }

    function getBinary(string path){
        return {
            file: fileRead(getPath(arguments.path))
        };
    }

    function delete(required any resource, boolean recursive=false){
        var p = getPath(arguments.resource.path);
        //logger("Delete: " & p & " [#resource.path#] recursive: #recursive# isDir: #arguments.resource.isDirectory()# #directoryExists(p)#" );
        if (arguments.resource.isDirectory())
            DirectoryDelete(p, arguments.recursive);
        else
            FileDelete(p);
    }

    struct function all(string path=this.separator, boolean recurse=false) { // a folder based store could use path
        var q = DirectoryList(path=getPath(arguments.path),listinfo="query", recurse=arguments.recurse);
        var st ={};
        var l = len(this.dir)+1;
        // logger("DirectoryList.all(path=#getPath(arguments.path)#, listinfo='query', recurse=#arguments.recurse#)");
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
        // logger("zzzzz " & p & " [#arguments.path#]");
        return p;
    }
    // https://github.com/lucee/Lucee/blob/6.0/core/src/main/java/lucee/commons/io/res/type/cfml/CFMLResource.java#L177
    // TODO not working yet, needed for DirectoryCopy
    function getOutputStream(required string path, boolean append){
        return CreateObject("java", "java.io.ByteArrayOutputStream").init(
            CreateObject("java", "java.io.FileOutputStream").init(arguments.path, arguments.append)
        );
    }

    function getInputStream(required string path){
        return CreateObject("java", "java.io.ObjectInputStream").init(
            CreateObject("java", "java.io.FileInputStream").init(arguments.path)
        );
    }

}