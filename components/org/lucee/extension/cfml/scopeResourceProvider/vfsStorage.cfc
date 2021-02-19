component {
    public any function init(string scheme){
        variables.debug = false;

        this.scheme = arguments.scheme;
        this.storage = {};
        return this;
    }

    public any function onMissingMethod(string name, struct args){
        if (variables.debug)
            writeLog(text="VFSstorage #SerializeJson(arguments)#");
        if (isCustomFunction(this["_#arguments.name#"]))
            return invoke(this, "_#arguments.name#", arguments.args);
        else
            throw "#arguments.name# not implemented";
    }

    function _add(String path, any file, boolean dir){
        if (variables.debug)
            writeLog(text="VFSstorage ADD #path#");
        this.storage[arguments.path] = arguments.file;
        return;
    };
    function _remove(String path, any file){
        structDelete(this.storage, arguments.path);
    };

    function _read(String path, any file){
        if (!_exists(path)){
            throw "#path# doesn't exist";
        } else {
            return this.storage[arguments.path];
        }
    };

    public boolean function _exists(path){
        return structKeyExists(this.storage, arguments.path);
    };

}