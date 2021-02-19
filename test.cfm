<cfscript>
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

    q = DirectoryList("request://");
    dump(var=q, label="DirectoryList");

    d="request://Zac";

    writeLog("-----------------------DirectoryCreate");
    dump("DirectoryCreate");
    if (!DirectoryExists(d))
        DirectoryCreate(d);

    q = DirectoryList(path="request://",listinfo="query",recurse=true);
    dump(var=q, label="DirectoryList");

    writeLog("-----------------------DirectoryDelete");
    dump("DirectoryDelete");
    DirectoryDelete(d);

    q = DirectoryList(path="request://",listinfo="query",recurse=true);
    dump(var=q, label="DirectoryList");

    d="request://";

    writeLog("--------------------getTempFile");
    f = getTempFile(d,"tmp");

    dump(var=f, label="getTempFile");
    //f = "#d##mid(f,2)#";

    writeLog("-----------------------DirectoryList");
    q = DirectoryList(path="request://",listinfo="query",recurse=true);
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

    q = DirectoryList(path="request://",listinfo="query",recurse=true);
    dump(var=q, label="DirectoryList");

    writeLog("-----------------------FileDelete");
    dump("fileDelete #f#");
    FileDelete(f);

    q = DirectoryList(path="request://",listinfo="query",recurse=true);
    dump(var=q, label="DirectoryList");

    d="request://";
    srcImg = ImageNew("",10,10);
    writeLog("-----------------------getTempFile");
    img = getTempFile(d,"tmp") & ".png";
    dump("ImageWrite #img#");
    writeLog("-----------------------ImageWrite");
    ImageWrite(srcImg, img);
    if (not FileExists(img))
        throw "ImageWrite created no file?";

    writeLog("-----------------------DirectoryList");
    q = DirectoryList(path="request://",listinfo="query",recurse=true);
    dump(var=q, label="DirectoryList");
    writelog("imageInfo");
    dump(var=imageInfo(img), expand=false, label="imageInfo");
    writelog("imageRead");
    dump(var=imageRead(img), expand=false, label="imageRead");


    d ="request://dirs";
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
    q = DirectoryList(path="request://dirs",listinfo="query",recurse=false);
    dump(var=q, label="DirectoryList");

    writeLog("-----------------------DirectoryList recurse");
    q = DirectoryList(path="request://dirs",listinfo="query",recurse=true);
    dump(var=q, label="DirectoryList");
}
</cfscript>