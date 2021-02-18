component /*implements="resource" */ accessors=true{
    property name="scheme" type="string" default="";
    public any function init(string scheme){
        writeLog(text="#SerializeJson(arguments)#");
        var vfs =  new vfsFile(scheme, "/");
        vfs.setExists(true);
        this.files = {
            "/": vfs
        };
        return this;
    }
    
    public any function onMissingMethod(string name, struct args){
        writeLog(text="VFS #SerializeJson(arguments)#");
        if (isCustomFunction(this["_#arguments.name#"]))
            return invoke(this, "_#arguments.name#", arguments.args);
        else
            throw "#arguments.name# not implemented";
    }

    function _getResource(String path){
        writeLog(text="VFS _getResource #arguments.path#");
        if (arguments.path eq "/")
            return this.files["/"];
        else
            return this.files["/"]._getRealResource(arguments.path);
    };  

    public boolean function _exists(){
        writeLog(text="VFS exists");
        return (structCount(this.files) gt 0);
    };  

    public boolean function _isAbsolute(){
        return true;
    };
}