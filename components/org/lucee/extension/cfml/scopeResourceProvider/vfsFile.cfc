component accessors=false extends="vfsBase" {
    public any function init(required string scheme, required any provider, required string filePath, struct meta={}){
        this.separator = "/";
        this.scheme = arguments.scheme;
        this.isDir = false;
        this._exists = false;
        this._lastModified = "";
        this._length = 0;
        this.path = arguments.filePath;

        if (structCount(arguments.meta))
            structAppend(this, arguments.meta);
        this.depth = listLen(this.path, this.separator)-1;
        if (this.depth < 0)
            this.depth = 0;
        this.name = listLast(this.path, this.separator);

        variables.provider = arguments.provider;
        logger(text="create #arguments.filePath#");
    }

    function logger(text){
        super.logger(this.path & " " & arguments.text);
    }

    function getPath(){
        return this.scheme & "://" & this.path;
    }

    function getName(){
        return this.name;
    }

    public boolean function setExists(boolean exists){
        this._exists = arguments.exists;
    }

    public boolean function exists(){
        return this._exists;
    }

    public boolean function length(){
        return this._length;
    }

    function setBinary(byteArray){
        if (this.isDir)
            throw "_setBinary: can't write content to a dir";
        if (!this._exists)
            createFile(false);
        variables.provider.storage.update(this, arguments.byteArray);
    }

    function getBinary(){
        return variables.provider.storage.readBinary(this.path);
    }

    boolean function setLastModified(required lastModified=now()){
        this._LastModified = arguments.lastModified;
        return true;
    }

    function LastModified(){
        return this._LastModified;
    }

    public boolean function isAbsolute(){
        return true;
    }

    public boolean function isDirectory(){
        return this.isDir;
    }

	public boolean function isFile(){
        return !this.isDir;
    }

    public boolean function isReadable(){
        return true;
    }

	public boolean function isWriteable(){
        return true;
    }

    void function setExists(required boolean exists){
        this._exists = arguments.exists;
    }

    function getRealResource(required string _path){
        if (this._exists)
            return variables.provider.getRealResource(this, this.path & this.separator & arguments._path);
        else
            return;
    }

    function getParent(){
        variables.provider.getParent(this);
    }

    function getParentResource(){
        variables.provider.getParentResource(this);
    }

    function createFile(boolean createParentWhenNotExists=false){
        variables.provider.createFile(this, arguments.createParentWhenNotExists);
    }

    function remove(boolean force=false){
        variables.provider.remove(this, arguments.force);
    }

    function createDirectory(boolean createParentWhenNotExists=false){
        variables.provider.createDirectory(this, arguments.createParentWhenNotExists);
    }

    function listResources(){
        return variables.provider.listResources(this);
    }

    public struct function toStruct(){
        return {
            name: this.name,
            path: this.path,
            depth: this.depth,
            _lastModified: this._lastModified,
            isDir: this.isDir,
            _length: this._length,
            _exists: this._exists
        };
    }

    /*
    public any function onMissingMethod(string name, struct args={}){
        if (!variables.debug)
            return local.result = invoke(this, "_#arguments.name#", arguments.args);

        var _args = structCount(arguments.args) == 0 ? "" : SerializeJson(arguments.args);

        if (isCustomFunction(this["_#arguments.name#"])){
            logger(text="CALLING #this.path# #arguments.name#(#_args#)");
            local.result = invoke(this, "_#arguments.name#", arguments.args);
            if (!isNull(local.result)){
                    logger(text="#this.path# #arguments.name#(#_args#) RETURNED: #SerializeJson(local.result)#");
                return local.result;
            } else {
                logger(text="#this.path# #arguments.name#(#_args#)");
                return;
            }
        } else {
            throw "#arguments.name# not implemented";
        }
    }
    */

}