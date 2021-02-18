component /*implements="resource" */{
    public any function init(){
        writeLog(text="#SerializeJson(arguments)#");
        this.files = {
            "/": new vfsFile("/").setExists(true)
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