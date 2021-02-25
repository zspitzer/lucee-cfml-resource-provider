component extends="testbox.system.BaseSpec"{
	function run(){
		for ( var scheme in application.testProviders ) {
			describe( "Files and dirs (#scheme#)", function(){
				var root = "#scheme#files-and-dirs\";

				it("setup(#root#)", function(){
					if (DirectoryExists(root))
						expect( DirectoryDelete(root, true) ).toBeNull();
					expect( DirectoryExists(root) ).toBe( false );
					expect( DirectoryCreate(root, true) ).toBeNull();

					loop list="oz,uk,de,ch" item="local.i"{
						f = root & "/" & local.i;
						expect( DirectoryExists(f)).toBe(false);
						expect( DirectoryCreate(f, true) ).toBeNull();
						expect( FileWrite(f & "/one.txt","one") ).toBeNull();
						expect( FileWrite(f & "/two.txt","two") ).toBeNull();
					}
					expect(DirectoryList(path=root,listinfo="query",recurse=false).recordcount).toBe(4);
					expect(DirectoryList(path=root,listinfo="query",recurse=true).recordcount).toBe(12);


					expect(DirectoryCopy( source=root & "oz/", destination=root & "au/", recurse=true, createPath=true, filter="*" ) ).toBeNull();

					if (DirectoryExists(root))
						expect(DirectoryDelete(root, true)).toBeNull();
					expect( DirectoryExists(root) ).toBe( false );
				});

			});
		}
	}
}
