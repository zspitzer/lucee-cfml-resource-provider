<cfscript>
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

    getTempFile("request://","tmp");
</cfscript>