component {
    public function onMissingMethod(string name, struct args){
        writeLog(SerializeJson(arguments));
        throw "#arguments.name# not implemented";
    }
}