component extends="vfsBase" {
    public any function init(struct args){
        this.args = arguments.args;
        this.store = create();
        return this;
    }

    function create(){
        //logger(text="create store");
        var structType = "normal";// this.args["case-sensitive"] ? "casesensitive" : "normal"; // acf 2001
        return structNew(structType);
    }

    function exists(string path){
        return structKeyExists(this.store, arguments.path);
    }

    function set(any resource, any data){
        this.store[arguments.resource.path] = arguments.data;
    }

    function get(string path){
        logger(text="files: #structKeyList(this.store)#");
        return structFind(this.store, arguments.path, {});
    }

    function getBinary(string path){
        return structFind(this.store, arguments.path, {});
    }

    function delete(any resource){
        return structDelete(this.store, arguments.resource.path);
    }

    function all(string path){ // vfsStorage providers filtering, path is ignored
        return this.store;
    }

    function count(){
        return structCount(this.store);
    }

    function clear(){
        this.store = create();
    }

    function usesFolders(){
        return false;
    }

    // https://github.com/lucee/Lucee/blob/6.0/core/src/main/java/lucee/commons/io/res/type/cfml/CFMLResource.java#L177
    // TODO not working yet, needed for DirectoryCopy, this is for files, needs to be adapted

    function getOutputStream(required string path, boolean append){
        throw "to be implemented";
        return CreateObject("java", "java.io.ObjectOutputStream").init(
            return CreateObject("java", "java.io.FileOutputStream").init(arguments.path, arguments.append);
        );
    }

    function getInputStream(required string path){
        throw "to be implemented";
        return CreateObject("java", "java.io.ObjectInputStream").init(
          return  CreateObject("java", "java.io.FileInputStream").init(arguments.path);
        );
    }
}