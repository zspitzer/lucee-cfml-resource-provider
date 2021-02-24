component extends="testbox.system.BaseSpec"{
	function run(){
		for ( var scheme in application.testProviders ) {
			describe( "Nested Folders (#scheme#)", function(){
				var root = "#scheme#nested-folders\";
				var res ="#root#nested\is\in\berlin";
				it("setup(#root#)", function(){
					if (DirectoryExists(root))
						expect( DirectoryDelete(root, true) ).toBeNull();
					expect( DirectoryExists(root) ).toBe( false );
					expect( DirectoryCreate(root, true) ).toBeNull();

					expect(DirectoryCreate(res, true, true)).toBeNull();
					expect( DirectoryExists(res) ).toBe( true );
					expect( function(){ FileInfo(res); } ).toThrow();

					expect( DirectoryList(path=root, listinfo="query", recurse=true).recordcount ).toBe(4);
					expect( ArrayLen(DirectoryList(path=root,listinfo="path",recurse=true)) ).toBe(4);
					expect( ArrayLen(DirectoryList(path=root,listinfo="name",recurse=true)) ).toBe(4);

					expect( DirectoryList(path=root,listinfo="query",recurse=false).recordcount ).toBe(1);
					expect( ArrayLen(DirectoryList(path=root,listinfo="path",recurse=false)) ).toBe(1);
					expect( DirectoryList(path=root,listinfo="name",recurse=false) ).toBe(['nested']);

					expect( DirectoryDelete(root, true)).toBeNull();
					expect( DirectoryExists(res) ).toBe( false );
				});
			});
		}
	}
}
