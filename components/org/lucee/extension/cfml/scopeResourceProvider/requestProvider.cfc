component /*implements="resourceProvider" */ extends="vfsBase" {

    public any function init(string scheme, struct cfg){
        arguments.cfg["usestreams"] = false; // cheeky
        this.cfg = {
            "case-sensitive": false,
            scheme: arguments.scheme,
            separator: getSeparator(),
            vfsKey: "__vfs"
        };
        StructAppend(this.cfg, arguments.cfg); // cfg is a java hash map, not a cfml struct

        //if (!structKeyExists(variables.cfg, "case-sensitive")) // not supported yet, acf 2021
            this.cfg["case-sensitive"] = false;
        if (variables.debug){
            variables.vfs = new vfsDebugWrapper(
                new vfs(this.cfg),
                "vfs-#this.cfg.scheme#"
            );
        } else {
            variables.vfs = new vfs(this.cfg);
        }
        //logger(text="init: #SerializeJson(this.cfg)#");
        return this;
    }

    public any function getResource(required string path){
        return variables.vfs.getResource(arguments.path, "", getStore());
    }

    public boolean function isCaseSensitive(){
        return this.cfg["case-sensitive"];
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

    // needs to be called per getResource as scope come and go, not just on the first request !!!!
    public any function getStore(){
        var scope="";
        /*
        var pc = getPageContext();
        local.parentPC  = pc.getParentPageContext();
        if (!isNull(local.parentPC))
            pc = local.parentPC;
        */
        switch (this.cfg.scope){
            case "session":
                throw "not yet supprted, see https://luceeserver.atlassian.net/browse/LDEV-3292";
                scope = session;
                writeLog(text="sessionId: [#scope.sessionid#]");
                break;
            case "application":
                throw "not yet supprted, see https://luceeserver.atlassian.net/browse/LDEV-3292";
                scope = application;
                writeLog(text="applicationName: [#scope.applicationName#]");
                break;
            case "request":
                throw "not yet supprted, see https://luceeserver.atlassian.net/browse/LDEV-3292";
                scope = request;
                break;
            case "server":
                scope = server;
                break;
            default:
                throw "unsupported vfs scope [#this.cfg.scope#] for scheme [#this.scheme#]";
        }

        if (!structKeyExists(scope, this.cfg.vfsKey)){
            if (structKeyExists(this.cfg, "storageCFC")){
                //logger(text="VFSstorage INIT [#this.cfg.scheme#] in scope [#this.cfg.scope#] as [#this.cfg.vfsKey#] using [#this.cfg["storageCFC"]#]");
                scope[this.cfg.vfsKey] = createObject("component", this.cfg["storageCFC"]).init(this.cfg); // must implement vfsStore interface
            } else{
                //logger(text="VFSstorage INIT [#this.cfg.scheme#] in scope [#this.cfg.scope#] as [#this.cfg.vfsKey#]");
                scope[this.cfg.vfsKey] = new vfsStore(this.cfg); // TODO pass in cass-insenstive from args
            }
            //scope["req_#pc.getRequestId()#"] = this.cfg;
            //logger(text="VFSstorage INIT Scope: #this.cfg.scope#, keys #structKeyList(scope)#");
        }
        return scope[this.cfg.vfsKey]; // all ready setup
    }

}