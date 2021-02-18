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
    timer type="outline"{
    writeLog("-----------------------");

    dump(var=getVFSMetaData("request"), label="getVFSMetaData");

    q = DirectoryList("request://");
    dump(var=q, label="DirectoryList");

    d="request://Zac";

    dump("DirectoryCreate");
    if (!DirectoryExists(d))
        DirectoryCreate(d);

    q = DirectoryList(path="request://",listinfo="query",recurse=true);
    dump(var=q, label="DirectoryList");
    
    //dump("DirectoryDelete");
    //DirectoryDelete(d);
    
    q = DirectoryList(path="request://",listinfo="query",recurse=true);
    dump(var=q, label="DirectoryList");

    d="request://";

    f = getTempFile(d,"tmp");
    dump(var=f, label="getTempFile");
    //f = "#d##mid(f,2)#";

    q = DirectoryList(path="request://",listinfo="query",recurse=true);
    dump(var=q, label="DirectoryList");


    

    dump("fileWrite #f#");
    FileWrite(f, "hi zac");
    
    dump(var=isImageFile(f), label="isImageFile #f#");

    c = FileRead(f);
    dump(var=c, label="fileRead #f#");
    writelog("FileInfo");
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

    dump("fileDelete #f#");
    FileDelete(f);

    q = DirectoryList(path="request://",listinfo="query",recurse=true);
    dump(var=q, label="DirectoryList");
    
    d="request://";
    srcImg = ImageNew("",1000,1000);
    img = getTempFile(d,"tmp") & ".png";
    dump(img);
    dump("ImageWrite");
    ImageWrite(srcImg, img);
    q = DirectoryList(path="request://",listinfo="query",recurse=true);
    dump(var=q, label="DirectoryList");
    
    dump(imageInfo(img));
    dump(imageRead(img));
}
</cfscript>