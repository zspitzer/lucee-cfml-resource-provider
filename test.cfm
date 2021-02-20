<cfscript>
    param name="scheme" default="request";
    /*
    pc = getPageContext();

    cfg = pc.getconfig();
    rp = cfg.getResourceProviders();

    doDump(ExtensionList().filter(function(row){ return row.name eq "ScopeResourceProvider";}));
    echo("<h1>Registered Resource Providers</h1>");
    loop array="#rp#" item="r" {
        echo("<b>#r.getScheme()#</b>");
        doDump(r.getArguments());
        echo("<hr>");
    }
    */

    function doDump(){
        //return; // ram drives return more meta data so dumps are slower, comment out to compare
        dump(argumentCollection=arguments);
    }

    setting requesttimeout=5;
    timer type="outline"{
    writeLog("-----------------------");

    doDump(var=getVFSMetaData("request"), label="getVFSMetaData");

    q = DirectoryList("#scheme#://");
    doDump(var=q, label="DirectoryList");

    nested="#scheme#://nested/is/in/berlin";

    writeLog("-----------------------DirectoryCreate");
    doDump(var="DirectoryCreate #nested# (nested)");
    if (!DirectoryExists(nested))
        DirectoryCreate(nested, true);

    q = DirectoryList(path="#scheme#://",listinfo="query",recurse=true);
    doDump(var=q, label="DirectoryList (nested)");

    d = "#scheme#://Zac";

    writeLog("-----------------------DirectoryCreate");
    doDump(var="DirectoryCreate #d#");
    if (!DirectoryExists(d))
        DirectoryCreate(d);


    q = DirectoryList(path="#scheme#://",listinfo="query",recurse=false);
    doDump(var=q, label="DirectoryList (top level, no recurse)");

    writeLog("-----------------------DirectoryDelete");
    doDump(var="DirectoryDelete #d#");
    DirectoryDelete(d);

    q = DirectoryList(path="#scheme#://",listinfo="query",recurse=true);
    doDump(var=q, label="DirectoryList");

    nest="#scheme#://nested";
    writeLog("-----------------------DirectoryDelete");
    doDump(var="DirectoryDelete #nest#");
    DirectoryDelete(nest, true);

    q = DirectoryList(path="#scheme#://",listinfo="query",recurse=true);
    doDump(var=q, label="DirectoryList (nested delete)");

    d="#scheme#://";

    writeLog("--------------------getTempFile");
    f = getTempFile(d,"tmp");

    doDump(var=f, label="getTempFile");
    //f = "#d##mid(f,2)#";

    writeLog("-----------------------DirectoryList");
    q = DirectoryList(path="#scheme#://",listinfo="query",recurse=true);
    doDump(var=q, label="DirectoryList");



    writeLog("----------------------fileWrite");
    doDump(var="fileWrite #f#");

    txt= "hi zac";

    FileWrite(f, txt);

    doDump(var=isImageFile(f), label="isImageFile #f#");
    writelog("-----------------------------FileRead");
    c = FileRead(f);
    doDump(var=c, label="fileRead #f#");

    if (c neq txt)
        throw "fileRead returned [#c#] not [#txt#]";

    writelog("-----------------------------FileInfo");
    i = FileInfo(f);
    doDump(var=i, label="FileInfo #f#");
    writelog("getFileInfo");
    try {
    i = GetFileInfo(f);
    doDump(var=i, label="getFileInfo #f#");
    } catch(e){
        doDump(var="ERROR: getFileInfo (#f#)" & cfcatch.message);
        doDump(car=cfcatch);
        abort;
    }

    q = DirectoryList(path="#scheme#://",listinfo="query",recurse=true);
    doDump(var=q, label="DirectoryList");

    writeLog("-----------------------FileDelete");
    doDump(var="fileDelete #f#");
    FileDelete(f);

    q = DirectoryList(path="#scheme#://",listinfo="query",recurse=true);
    doDump(var=q, label="DirectoryList");

    d="#scheme#://";
    srcImg = ImageNew("",10,10);
    writeLog("-----------------------getTempFile");
    img = getTempFile(d,"tmp") & ".png";
    doDump(var="ImageWrite #img#");
    writeLog("-----------------------ImageWrite");
    ImageWrite(srcImg, img);
    if (not FileExists(img))
        throw "ImageWrite created no file?";

    writeLog("-----------------------DirectoryList");
    q = DirectoryList(path="#scheme#://",listinfo="query",recurse=true);
    doDump(var=q, label="DirectoryList");
    writelog("imageInfo");
    doDump(var=imageInfo(img), expand=false, label="imageInfo");
    writelog("imageRead");
    doDump(var=imageRead(img), expand=false, label="imageRead");


    d ="#scheme#://dirs";
    if (!DirectoryExists(d))
        DirectoryCreate(d);
    FileWrite(d & "/zero.txt","zero");
    loop list="oz,uk,de,ch" item="local.i"{
        dd = d & "/" & local.i;
        if (!DirectoryExists(dd))
            DirectoryCreate(dd);
        FileWrite(dd & "/one.txt","one");
        FileWrite(dd & "/two.txt","two");
    }

    writeLog("-----------------------DirectoryList");
    q = DirectoryList(path="#scheme#://dirs",listinfo="query",recurse=false);
    doDump(var=q, label="DirectoryList");

    writeLog("-----------------------DirectoryList recurse");
    q = DirectoryList(path="#scheme#://dirs",listinfo="query",recurse=true);
    doDump(var=q, label="DirectoryList");

    writeLog("-----------------------DirectoryCopy recurse");
    copyDest ="#scheme#://copy";
    DirectoryCopy( source=d, destination=copyDest, recurse=true, createPath=true );

    q = DirectoryList(path="#scheme#://",listinfo="query",recurse=true);
    doDump(var=q, label="DirectoryList - all");
}
</cfscript>