<cfscript>
    d = getDirectoryFromPath(getCurrenttemplatepath());
    f = "lucee-scope-resource-provider.lex"

    lex= expandPath('#d#/../#f#');
    if (FileExists(lex))
        FileDelete(lex);

    q = directoryList(path="#d#", recurse=true, listInfo="query");
    dump(q);

    loop query=Q {
        if (q.type eq "file"
                and q.name neq "buildExtension.cfm"
                and q.directory does not contain ".git"
                and q.directory does not contain "tests"
                and q.name does not contain ".lex"){
            path = mid(q.directory, len(d));
            path = listchangeDelims(path,"/","\"); // make unix-y
            entry = "#path#/#q.name#";
            dump(var=entry, label="entryPath");

            /*
                problem on windows, cfzip adds in windows file separator \. Lucee expects unix style /

                despite the entry path being converted to be unix-y, cfzip on windows adds \

                zip://C:\work\lucee-scope-resource-provider.lex!//META-INF\MANIFEST.MF

                upload the test extension throws

                lucee.runtime.exp.ApplicationException: The Extension [C:\tmp\lucee-express-5.3.7.47\webapps\ROOT\WEB-INF\lucee\temp\lucee-scope-resource-provider.lex]
                is invalid,no Manifest file was found at [META-INF/MANIFEST.MF].

            */
            zip action="zip" source="#q.directory#\#q.name#" file="#lex#" entrypath="#entry#";

            //Compress( format="zip", source="#q.directory#\#q.name#", target="#lex#", includeBaseFolder=false);
        }
    }

    q = directoryList(path="zip://#lex#!", recurse=true, type="all");
    dump(q);
</cfscript>

