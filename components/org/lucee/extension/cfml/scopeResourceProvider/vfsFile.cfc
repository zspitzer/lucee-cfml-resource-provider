component accessors=false extends="vfsBase" {
    public any function init(required string scheme, required any provider, required any storage, required string filePath, struct meta={}, boolean dummy=false){
        this.separator = "/";
        this.scheme = arguments.scheme;
        this.storage = arguments.storage;
        if (structCount(arguments.meta)){
            structAppend(this, arguments.meta);
        } else {
            this.isDir = false;
            this._exists = false;
            this.dateLastModified = "";
            this.size = 0;
            this.path = arguments.filePath;
            this.depth = listLen(this.path, this.separator)-1;
            if (this.depth < 0)
                this.depth = 0;
            this.name = listLast(this.path, this.separator);
        }

        variables.provider = arguments.provider;
        // if (!arguments.dummy)             logger(text="create #arguments.filePath#");
    }

    public any function getStorage(){
        return this.storage;
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
        return this.size;
    }

    function setBinary(byteArray){
        if (this.isDir)
            throw "_setBinary: can't write content to a dir";
        if (!this._exists)
            createFile(false);
        this.storage.update(this, arguments.byteArray);
    }

    function getBinary(){
        return this.storage.readBinary(this.path);
    }

    boolean function setLastModified(required lastModified=now()){
        this.dateLastModified = arguments.lastModified;
        return true;
    }

    function LastModified(){
        return this.dateLastModified;
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
            dateLastModified: this.dateLastModified,
            isDir: this.isDir,
            size: this.size,
            _exists: this._exists
        };
    }

}