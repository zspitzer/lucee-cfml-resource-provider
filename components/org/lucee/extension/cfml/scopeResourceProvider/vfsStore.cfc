component extends="vfsBase" {
    public any function init(struct args){
        this.args = arguments.args;
        this.store = create();
        return this;
    }

    function create(){
        logger(text="create store");
        var structType = "normal";// this.args["case-sensitive"] ? "casesensitive" : "normal"; // acf 2001
        return structNew(structType);
    }

    function exists(string path){
        return structKeyExists(this.store, arguments.path);
    }

    function set(string path, any data){
        this.store[arguments.path] = arguments.data;
    }

    function get(string path){
        logger(text="files: #structKeyList(this.store)#");
        return structFind(this.store, arguments.path, {});
    }

    function delete(string path){
        return structDelete(this.store, arguments.path);
    }

    function all(string path){ // a folder based store could use path
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
}