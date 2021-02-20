component accessors=false {
    public any function init(schemeName, provider, filePath){
        variables.debug = false;
        if (variables.debug)
            writeLog(text="create #arguments.filePath#");
        this.separator = "/";
        this.scheme= arguments.schemeName;
        this.path = arguments.filePath;
        this.depth = listLen(this.path, this.separator)-1;
        if (this.depth < 0)
            this.depth = 0;
        this.name = listLast(this.path, this.separator);
        this.isDir = false;
        this.exists = false;
        this.lastModified = "";
        this.length = 0;
        variables.provider = arguments.provider;
    }
    public any function onMissingMethod(string name, struct args={}){
        if (variables.debug)
            var _args = structCount(arguments.args) == 0 ? "" : SerializeJson(arguments.args);
        if (isCustomFunction(this["_#arguments.name#"])){
            if (variables.debug)
                writeLog(text="CALLING #this.path# #arguments.name#(#_args#)");
            local.result = invoke(this, "_#arguments.name#", arguments.args);
            if (!isNull(local.result)){
                if (variables.debug)
                    writeLog(text="#this.path# #arguments.name#(#_args#) RETURNED: #SerializeJson(local.result)#");
                return local.result;
            } else {
                if (variables.debug)
                    writeLog(text="#this.path# #arguments.name#(#_args#)");
                return;
            }
        } else {
            throw "#arguments.name# not implemented";
        }
    }

    function _getPath(){
        return this.scheme & ":/" & this.path;
    }

    function _getName(){
        return this.name;
    }

    public boolean function _exists(){
        return this.exists;
    };

    public boolean function _length(){
        return this.length;
    };

    function _setBinary(byteArray){
        if (this.isDir)
            throw "_setBinary: can't write content to a dir";
        if (!this.exists)
            _createFile(false);
        variables.provider.storage.update(this, arguments.byteArray);
    };

    function _getBinary(){
        var resource = variables.provider.storage.read(this.path);
        return resource.file;
    };

    boolean function _setLastModified(_lastModified){
        this.LastModified = _lastModified;
        return true;
    };

    function _LastModified(){
        return this.LastModified;
    };

    public boolean function _isAbsolute(){
        return true;
    };

    public boolean function _isDirectory(){
        return this.isDir;
    };

	public boolean function _isFile(){
        return !this.isDir;
    };

    public boolean function _isReadable(){
        return true;
    };

	public boolean function _isWriteable(){
        return true;
    };

    void function _setExists(_exists){
        this.exists = arguments._exists;
    };

    function _getRealResource(String _path){
        if (this.exists)
            return variables.provider.getRealResource(this, this.path & this.separator & _path);
        else
            return;
    };

    function _getParent(){
        variables.provider.getParent(this);
    };

    function _getParentResource(){
        variables.provider.getParentResource(this);
    };

    function _createFile(boolean createParentWhenNotExists){
        variables.provider.createFile(this, createParentWhenNotExists);
    };

    function _remove(boolean force){
        variables.provider.remove(this, force);
    };

    function _createDirectory(boolean createParentWhenNotExists){
        variables.provider.createDirectory(this, createParentWhenNotExists);
    };

    function _listResources(){
        return variables.provider.listResources(this);
    };
}