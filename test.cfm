<cfscript>
    param name="scheme" default="request";
    /*
    pc = getPageContext();

    cfg = pc.getconfig();
    rp = cfg.getResourceProviders();

    dump(ExtensionList().filter(function(row){ return row.name eq "ScopeResourceProvider";}));
    echo("<h1>Registered Resource Providers</h1>");
    loop array="#rp#" item="r" {
        echo("<b>#r.getScheme()#</b>");
        dump(r.getArguments());
        echo("<hr>");
    }
    */
    setting requesttimeout=5;
    timer type="outline"{
    writeLog("-----------------------");

    dump(var=getVFSMetaData("request"), label="getVFSMetaData");

    q = DirectoryList("#scheme#://");
    dump(var=q, label="DirectoryList");

    nested="#scheme#://nested/is/in/berlin";

    writeLog("-----------------------DirectoryCreate");
    dump("DirectoryCreate #nested# (nested)");
    if (!DirectoryExists(nested))
        DirectoryCreate(nested, true);

    q = DirectoryList(path="#scheme#://",listinfo="query",recurse=true);
    dump(var=q, label="DirectoryList (nested)");

    d = "#scheme#://Zac";

    writeLog("-----------------------DirectoryCreate");
    dump("DirectoryCreate #d#");
    if (!DirectoryExists(d))
        DirectoryCreate(d);


    q = DirectoryList(path="#scheme#://",listinfo="query",recurse=false);
    dump(var=q, label="DirectoryList (top level, no recurse)");

    writeLog("-----------------------DirectoryDelete");
    dump("DirectoryDelete #d#");
    DirectoryDelete(d);

    q = DirectoryList(path="#scheme#://",listinfo="query",recurse=true);
    dump(var=q, label="DirectoryList");

    nest="#scheme#://nested";
    writeLog("-----------------------DirectoryDelete");
    dump("DirectoryDelete #nest#");
    DirectoryDelete(nest, true);

    q = DirectoryList(path="#scheme#://",listinfo="query",recurse=true);
    dump(var=q, label="DirectoryList (nested delete)");

    d="#scheme#://";

    writeLog("--------------------getTempFile");
    f = getTempFile(d,"tmp");

    dump(var=f, label="getTempFile");
    //f = "#d##mid(f,2)#";

    writeLog("-----------------------DirectoryList");
    q = DirectoryList(path="#scheme#://",listinfo="query",recurse=true);
    dump(var=q, label="DirectoryList");



    writeLog("----------------------fileWrite");
    dump("fileWrite #f#");

    txt= "hi zac";

    FileWrite(f, txt);

    dump(var=isImageFile(f), label="isImageFile #f#");
    writelog("-----------------------------FileRead");
    c = FileRead(f);
    dump(var=c, label="fileRead #f#");

    if (c neq txt)
        throw "fileRead returned [#c#] not [#txt#]";

    writelog("-----------------------------FileInfo");
    i = FileInfo(f);
    dump(var=i, label="FileInfo #f#");
    writelog("getFileInfo");
    try {
    i = GetFileInfo(f);
    dump(var=i, label="getFileInfo #f#");
    } catch(e){
        dump("ERROR: getFileInfo (#f#)" & cfcatch.message);
        dump(cfcatch);
        abort;
    }

    q = DirectoryList(path="#scheme#://",listinfo="query",recurse=true);
    dump(var=q, label="DirectoryList");

    writeLog("-----------------------FileDelete");
    dump("fileDelete #f#");
    FileDelete(f);

    q = DirectoryList(path="#scheme#://",listinfo="query",recurse=true);
    dump(var=q, label="DirectoryList");

    d="#scheme#://";
    srcImg = ImageNew("",10,10);
    writeLog("-----------------------getTempFile");
    img = getTempFile(d,"tmp") & ".png";
    dump("ImageWrite #img#");
    writeLog("-----------------------ImageWrite");
    ImageWrite(srcImg, img);
    if (not FileExists(img))
        throw "ImageWrite created no file?";

    writeLog("-----------------------DirectoryList");
    q = DirectoryList(path="#scheme#://",listinfo="query",recurse=true);
    dump(var=q, label="DirectoryList");
    writelog("imageInfo");
    dump(var=imageInfo(img), expand=false, label="imageInfo");
    writelog("imageRead");
    dump(var=imageRead(img), expand=false, label="imageRead");


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
    dump(var=q, label="DirectoryList");

    writeLog("-----------------------DirectoryList recurse");
    q = DirectoryList(path="#scheme#://dirs",listinfo="query",recurse=true);
    dump(var=q, label="DirectoryList");

    writeLog("-----------------------DirectoryCopy recurse");
    copyDest ="#scheme#://copy";
    DirectoryCopy( source=d, destination=copyDest, recurse=true, createPath=true );

    q = DirectoryList(path="#scheme#://",listinfo="query",recurse=true);
    dump(var=q, label="DirectoryList - all");
}
</cfscript>