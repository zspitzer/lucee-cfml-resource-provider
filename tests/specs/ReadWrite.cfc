component extends="testbox.system.BaseSpec"{
	function run(){
		for ( var scheme in application.testProviders ) {
			describe( "read write (#scheme#)", function(){
				var root = "#scheme#read-write\";

				it("setup(#root#)", function(){
					if (DirectoryExists(root))
						expect( DirectoryDelete(root, true) ).toBeNull();
					expect( DirectoryExists(root) ).toBe( false );
					expect( DirectoryCreate(root, true) ).toBeNull();

					f = getTempFile(root,"tmp");
					expect( FileExists(f) ).toBe(true);
					text= "hi zac";
					expect( FileWrite(f, text) ).toBeNull();
					c = FileRead(f);
					expect( c ).toBe(text);
					expect( DirectoryDelete(root, true)).toBeNull();
					expect( DirectoryExists(root) ).toBe( false );
				});
			});
		}
	}
}
