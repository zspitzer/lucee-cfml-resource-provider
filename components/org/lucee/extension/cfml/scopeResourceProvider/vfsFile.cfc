component accessors=true {
    property name="scheme" type="string" default="";
	property name="path" type="string" default="";
    property name="name" type="string" default="";
    property name="isDir" type="boolean" default="true";
    property name="children" type="struct";
    property name="exists" type="boolean" default="false";
    property name="parent" type="any";
    property name="LastModified" type="date";    
    property name="binary" type="any" default="";
    property name="separator" type="string" default="/";

    	    
    public any function init(scheme, path, parent){
        var _path = cleanPath(arguments.path);
        writeLog(text="create #_path#");
        setPath(_path);
        setChildren({});
        setScheme(arguments.scheme)
        if (structKeyExists(arguments, "parent"))
            setParent(parent);
    }

    function cleanPath(string _path){
        return "/" & listToArray(arguments._path,"/\").toList(separator);
    }
    
    public any function onMissingMethod(string name, struct args){
        
        if (isCustomFunction(this["_#arguments.name#"])){
            local.result = invoke(this, "_#arguments.name#", arguments.args);
            if (!isNull(local.result)){
                writeLog(text="#path# #arguments.name#() #SerializeJson(arguments)# RETURNED: #SerializeJson(local.result)#");
                return local.result;
            } else {
                writeLog(text="#path# #arguments.name#() #SerializeJson(arguments)#");
                return;
            }
        } else {
            throw "#arguments.name# not implemented";
        }
    }

    function _getPath(){
        return scheme & ":/" & path;
    }

    function _getName(){
        return name;
    }

    function _getResource(String realPath){
        //writeLog(text="#arguments.realpath# _getResource()");
        return this.files[arguments.realpath];
    };  

    public boolean function _exists(){
        //writeLog(text="#path# exists() #exists#");
        return exists;
    };  

    public boolean function _length(){
        return len(binary);
    };  

    public boolean function _isAbsolute(){
        return true;
    };

    public boolean function _isDirectory(){
        //writeLog(text="#path# isDirectory() #isdir#");
        return exists && isDir;
    };

	public boolean function _isFile(){
        return exists && !isDir;
    };

    public boolean function _isReadable(){
        return true;
    };
	
	public boolean function _isWriteable(){
        return true;
    };

    function _getRealResource(String _realpath){
        var realPath = cleanPath(arguments._realpath);
        if (!structKeyExists(children, realPath)){
            children[realPath] = new vfsFile(scheme, realPath, this);
        }
        return children[realPath];
    };

    function _getParentResource(){
        return parent;
    };

    void function _createFile(boolean createParentWhenNotExists){
        // todo createParentWhenNotExists
        setExists(true);
        setIsDir(false);
        setName(listLast(path,"/\"));
        setLastModified(now());
    };

    void function _remove(boolean force){
        setExists(false);
        setIsDir(false);
        setBinary("");
        setLastModified(now());
    };

    void function _createDirectory(boolean createParentWhenNotExists){
        setIsDir(true);
        setExists(true);
        setName(listLast(path,"/\"));
        setLastModified(now());
    };

    function _setBinary(byteArray){
        binary = arguments.byteArray;
    };

    function _getBinary(){
        return binary;
    };

    function _LastModified(){
        return LastModified;
    }

    function _listResources(){
        writeLog(text="#path# listResources [#structKeyList(children)#]");
        local.files = [];
        loop collection="#children#" index="local.index" item="local.item"{
            if (local.item.exists())
                arrayAppend(local.files, local.item);
        }
        return local.files;
    };

}