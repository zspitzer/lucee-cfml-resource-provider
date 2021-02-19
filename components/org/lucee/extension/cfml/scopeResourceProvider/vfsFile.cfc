component accessors=false {
    public any function init(schemeName, provider, filePath){
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
        // this.parent = "";
        this.lastModified = "";
        this.length = 0;
        variables.provider = arguments.provider;
    }

    public any function onMissingMethod(string name, struct args={}){
        var _args = structCount(arguments.args) == 0 ? "" : SerializeJson(arguments.args);
        if (isCustomFunction(this["_#arguments.name#"])){
            writeLog(text="CALLING #this.path# #arguments.name#(#_args#)");
            local.result = invoke(this, "_#arguments.name#", arguments.args);
            if (!isNull(local.result)){
                writeLog(text="#this.path# #arguments.name#(#_args#) RETURNED: #SerializeJson(local.result)#");
                return local.result;
            } else {
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
        //writeLog(text="#path# exists() #exists#");
        return this.exists;
    };

    public boolean function _length(){
        return this.length;
    };

    function _setBinary(byteArray){
        //if (IsDir)             throw "_setBinary: can't write content to a dir";
        if (!this.exists)
            _createFile(false);
        variables.provider.storage._add(this.path, arguments.byteArray);
        this.length = len(arguments.byteArray)
        return this.length;
    };

    function _getBinary(){
        var file = variables.provider.storage._read(this.path);
        return file;
    };

    function _LastModified(){
        return this.LastModified;
    };

    public boolean function _isAbsolute(){
        return true;
    };

    public boolean function _isDirectory(){
        //writeLog(text="#path# isDirectory() #isdir#");
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
            return variables.provider._getRealResource(this, _path);
        else
            return;
    };

    function _getParent(){
        variables.provider._getParent(this);
    };

    function _getParentResource(){
        variables.provider._getParentResource(this);
    };

    function _createFile(boolean createParentWhenNotExists){
        variables.provider._createFile(this, createParentWhenNotExists);
    };

    void function _remove(boolean force){
        variables.provider._remove(this, force);
    };

    void function _createDirectory(boolean createParentWhenNotExists){
        variables.provider._createDirectory(this, createParentWhenNotExists);
    };

    function _listResources(){
        return variables.provider._listResources(this);
    };

    function set(prop, val){
        return this[prop] = val;
    }

    function get(prop){
        writeLog(text="#structKeyList(this)#");
        return this[prop];
    }
}