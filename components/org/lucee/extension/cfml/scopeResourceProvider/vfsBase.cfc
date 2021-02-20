component {
    variables.debug = false;

    public any function init(){
        return this;
    }

    public void function logger(string text){
        if (variables.debug)
            writeLog(text=arguments.text);
    }

    public any function onMissingMethods(string name, struct args){
        writeLog(text="#arguments.name#: #SerializeJson(arguments.args)#");
        throw "#arguments.name# not implemented";
    }
}