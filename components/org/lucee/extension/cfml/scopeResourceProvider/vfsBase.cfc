component {
    variables.debug = false;

    public any function init(){
        return this;
    }

    public void function logger(string text){
        if (variables.debug){
            writeLog(text=arguments.text);
            // echo("<pre style='margin:0'>#arguments.text#</pre>");            flush;
        }
    }

    public any function onMissingMethods(string name, struct args){
        writeLog(text="#arguments.name#: #SerializeJson(arguments.args)#");
        throw "#arguments.name# not implemented";
    }

    private function normalizePath(required string _path){
        return this.separator & ArrayToList(listToArray(arguments._path,"/\"), this.separator);
    }
}