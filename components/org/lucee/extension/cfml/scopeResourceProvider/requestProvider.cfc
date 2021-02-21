component /*implements="resourceProvider" */ extends="vfsBase" {

    public any function init(string scheme, struct args){
        variables.scheme = arguments.scheme;
        variables.args = {
            "case-sensitive": false
        };
        StructAppend(variables.args, arguments.args); // args is a java hash map, not a cfml struct

        //if (!structKeyExists(variables.args, "case-sensitive")) // not supported yet, acf 2021
            variables.args["case-sensitive"] = false;
        variables.vfs = {};
        logger(text="init: #SerializeJson(arguments)#");
        variables.scope = variables.args;
        return this;
    }

    public any function getResource(required string path){
        // todo, storageCFC

         if (!structKeyExists(variables.vfs, variables.scheme)){
            logger(text="create vfs: #variables.scheme#");
            variables.vfs[variables.scheme] = new vfsDebugWrapper(
                new vfs(variables.scheme, variables.args),
                "vfs-#variables.scheme#"
            );
        }
        return variables.vfs[variables.scheme].getResource(arguments.path);
    }

    public boolean function isCaseSensitive(){
        return variables.args["case-sensitive"];
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