component /*implements="resourceProvider" */{
    public any function init(string scheme, struct args){
        variables.scheme = arguments.scheme;
        variables.args = arguments.args;
        variables.vfs = new vfs();
        writeLog(text="init: #SerializeJson(arguments)#");
        return this;
    }
    
    public any function onMissingMethod(string name, struct args){
        writeLog(text="#arguments.name#: #SerializeJson(arguments.args)#");
        throw "#arguments.name# not implemented";
    }

    public any function getResource(String path){
        return variables.vfs.getResource(arguments.path);
    }

    public boolean function isCaseSensitive(){
        return true;
    };

	public boolean function isModeSupported(){
        return false;
    };

	public boolean function isAttributesSupported(){
        return false;
    };
}