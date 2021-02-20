component /*implements="resourceProvider" */ extends="vfsBase" {

    public any function init(string scheme, struct args){
        variables.scheme = arguments.scheme;
        variables.args = arguments.args;
        variables.vfs = {};
        variables.vfs[scheme] = new vfsDebugWrapper(
            new vfs(arguments.scheme),
            "vfs"
        );
        logger(text="init: #SerializeJson(arguments)#");
        return this;
    }

    public any function getResource(required string path){
        return variables.vfs[variables.scheme].getResource(arguments.path);
    }

    public boolean function isCaseSensitive(){
        return false;
    }

	public boolean function isModeSupported(){
        return false;
    }

	public boolean function isAttributesSupported(){
        return false;
    }

    public string function getSeparator(){
        return "/";
    }
}