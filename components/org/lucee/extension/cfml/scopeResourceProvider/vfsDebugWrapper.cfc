component extends="vfsBase" hint="wraps a cfc, logs all function calls with args and any changes to simple properties" {
    public any function init(comp, name){

        if (!variables.debug)
            return arguments.comp;

        variables.path = arguments.name;
        variables.obj = arguments.comp;

        updateProperties(update=true); //copy the properties from the debugger object onto this one
        return this;
    }

    // there's no onMissingProperty yet https://luceeserver.atlassian.net/browse/LDEV-3260

    private void function updateProperties(boolean logChange=false, boolean update=false){
        loop collection="#variables.obj#" key="local.key" value="local.value" {
            if (structKeyExists(variables.obj, local.key) && isSimpleValue(local.value)){
                if (arguments.logChange && false
                        && structKeyExists(this, local.key)
                        && local.value neq this[local.key]){

                    if (arguments.update)
                        writelog("AFTER: #variables.path#.prop.#local.key# = [#local.value#] was [#this[local.key]#]");
                    else
                        writelog("BEFORE: #variables.path#.prop.#local.key# = [#this[local.key]#], was [#local.value#]");
                }
                if (arguments.update)
                    this[local.key] = variables.obj[local.key]; // copy the properties from object
                else
                    variables.obj[local.key] = this[local.key]; // update the debugged object with changed properties

            }
        }
        //writeLog(text="PROPERTIES #variables.path#: #SerializeJson(this)#");
    }

    public any function onMissingMethod(string name, struct args={}){
        if (!variables.debug)
            return invoke(variables.obj, arguments.name, arguments.args);
        var _args = structCount(arguments.args) == 0 ? "" : SerializeJson(arguments.args);

        if (isCustomFunction(variables.obj[arguments.name])){
            try {
                writeLog(text="CALLING #variables.path# #arguments.name#(#_args#)");
                // writeLog(text="#CallStackGet('string')#");
                updateProperties(true, false);
                local.result = invoke(variables.obj, arguments.name, arguments.args);
                updateProperties(true, true);
            } catch (e){
                // log how function was called before it errored
                writeLog(text="ERRORED: #variables.path# #arguments.name#(#_args#)");
                writeLog(text="#cfcatch.message#");
                writeLog(text="#CallStackGet('string')#");
                rethrow;
            }
            if (!isNull(local.result)){
                writeLog(text="#variables.path# #arguments.name#(#_args#) RETURNED: #SerializeJson(local.result)#");
                return local.result;
            } else {
                writeLog(text="#variables.path# #arguments.name#(#_args#)");
                return;
            }
        } else {
            throw "#arguments.name# not implemented";
        }
    }
}