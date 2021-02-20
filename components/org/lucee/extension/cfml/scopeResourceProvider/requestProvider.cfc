component /*implements="resourceProvider" */ extends="vfsBase" {

    public any function init(string scheme, struct args){
        variables.scheme = arguments.scheme;
        variables.args = arguments.args;
        variables.vfs = {};
        logger(text="init: #SerializeJson(arguments)#");
        variables.scope = arguments.args["scope"]; // args is a java hash map, not a cfml struct
        return this;
    }

    public any function getResource(required string path){
         if (!structKeyExists(variables.vfs, variables.scope)){
            logger(text="create vfs: #variables.scope#");
            var newVfs = new vfs(variables.scope);
            variables.vfs[variables.scope] = new vfsDebugWrapper(
                newVfs,
                "vfs-#variables.scope#"
            );
        }
        return variables.vfs[variables.scope].getResource(arguments.path);
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