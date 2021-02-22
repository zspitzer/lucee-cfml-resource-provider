<cfscript>
    param name="scheme" default="request";
    param name="dump" default="true";
    if (scheme== "")
        scheme="request";

    dumpEnabled = dump;



    /*
    pc = getPageContext();
    pc.requestScope().vfs=1;
    dump(pc.requestScope());
    abort;
    */

    /*
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
        if (dumpEnabled)
            dump(argumentCollection=arguments);
    }

    setting requesttimeout=85;
    timer type="outline"{
    writeLog("-----------------------");

    doDump(var=getVFSMetaData(scheme), label="getVFSMetaData");

    nested="#scheme#://nested/is/in/berlin";

    writeLog("-----------------------DirectoryCreate");
    doDump(var="DirectoryCreate #nested# (nested)");
    if (!DirectoryExists(nested))
        DirectoryCreate(nested, true);

    loop list="query, name,path" item="listinfo" {
        loop list="true,false" item="r"{
            q = DirectoryList(path="c:\temp\test\",listinfo=listinfo,recurse=r);
            doDump(var=q, label="DirectoryList listinfo=#listinfo# (recurse=#r#) c:\temp\test\");

            q = DirectoryList(path="#scheme#://",listinfo=listinfo,recurse=true);
            doDump(var=q, label="DirectoryList listinfo=#listinfo# (recurse=#r#) #scheme#:// ");
            echo("<hr>");
        }
       // abort;
    }
    //abort;
    try {
        dump(FileInfo(nested));
    } catch(e){
        dodump("EXPECTED ERROR:" & cfcatch.message);
    }


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

    writelog("-----------------------------FileRead");
    c = FileRead(f);
    doDump(var=c, label="fileRead #f#");

    if (c neq txt)
        throw "fileRead returned [#c#] not [#txt#]";

    // get the file resource
    res = fileOpen(f);
    doDump(var=res.getResource().getClass(),expand='false', label="open file, get Resource");
    doDump(var=res.getResource().getResourceProvider(),expand='false', label="open file, get ResourceProvider");

    FileClose(res);

    doDump(var=isImageFile(f), label="isImageFile #f#");

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

    doDump(var=q, label="Create nested");
    d ="#scheme#://dirs";
    if (!DirectoryExists(d))
        DirectoryCreate(d);
    c= 1;

    writeLog("-----------------------DirectoryList");
    q = DirectoryList(path="#scheme#://",listinfo="query",recurse=true);
    doDump(var=q, label="DirectoryList after create #d#");

    FileWrite(d & "/zero.txt","zero");
    loop list="oz,uk,de,ch" item="local.i"{
        dd = d & "/" & local.i;
        if (!DirectoryExists(dd))
            DirectoryCreate(dd);
        FileWrite(dd & "/one.txt","one");
        c++;
        FileWrite(dd & "/two.txt","two");
        c++;
    }

    writeLog("-----------------------DirectoryList #d#");
    q = DirectoryList(path=d,listinfo="query",recurse=false);
    doDump(var=q, label="DirectoryList #d#");


    writeLog("-----------------------DirectoryList recurse #d#");
    q = DirectoryList(path=d,listinfo="query",recurse=true);
    doDump(var=q, label="DirectoryList #d# recurse");

    if (q.recordcount lt c)
        throw "expecting at least #c# files, only found  #q.recordcount#";

    writeLog("-----------------------DirectoryCopy recurse");
    copyDest ="#scheme#://copy";
    DirectoryCopy( source=d, destination=copyDest, recurse=true, createPath=true );

    q = DirectoryList(path="#scheme#://",listinfo="query",recurse=true);
    doDump(var=q, label="DirectoryList - all");

    purge ="#scheme#://";
    writeLog("-----------------------DirectoryDelete ALL");
    doDump(var="DirectoryDelete #purge# ALL");
    try {
        DirectoryDelete(purge, false);
    } catch (e){
        dodump("EXPECTED ERROR:" & cfcatch.message);
    }


    /*

    DirectoryDelete(purge, true);

    writeLog("-----------------------DirectoryList recurse (should be empty)");
    q = DirectoryList(path=purge,listinfo="query",recurse=true);
    doDump(var=q, label="DirectoryList (should be empty)");
    if (q.recordcount gt 0)
        throw "DirectoryList (should be empty)"
        */
}
dump(getVariable(scheme));
</cfscript>