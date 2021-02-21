component extends="vfsBase" {
    public any function init(struct args){
        this.args = arguments.args;
        this.store = create();
        return this;
    }

    function create(){
        var structType = "normal";// this.args["case-sensitive"] ? "casesensitive" : "normal"; // acf 2001
        return StructNew(structType);
    }

    function exists(string path resource){
        return structKeyExists(this.store, arguments.path);
    }

    function set(string path resource, any data){
        this.store[arguments.path] = arguments.data;
    }

    function get(string path resource){
        return this.store[arguments.path];
    }

    function delete(string path resource){
        return structDelete(this.store, arguments.path);
    }

    function all(string path resource){
        return this.store;
    }

    function clear(string path resource){
        this.store = create();
    }
}