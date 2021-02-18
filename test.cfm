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
    f = "#d##mid(f,2)#";

    dump(var=f, label="getTempFile");

    q = DirectoryList(path="request://",listinfo="query",recurse=true);
    dump(var=q, label="DirectoryList");


    

    dump("fileWrite #f#");
    FileWrite(f, "hi zac");
    
    dump(var=isImageFile(f), label="isImageFile #f#");

    c = FileRead(f);
    dump(var=c, label="fileRead #f#");

    i = FileInfo(f);
    dump(var=i, label="FileInfo #f#");

    try {
    i = GetFileInfo(f);
    dump(var=i, label="getFileInfo #f#");
    } catch(e){
        dump("ERROR: getFileInfo" & cfcatch.message);
    }

    q = DirectoryList(path="request://",listinfo="query",recurse=true);
    dump(var=q, label="DirectoryList");

    dump("fileDelete #f#");
    FileDelete(f);

    q = DirectoryList(path="request://",listinfo="query",recurse=true);
    dump(var=q, label="DirectoryList");
    }
</cfscript>