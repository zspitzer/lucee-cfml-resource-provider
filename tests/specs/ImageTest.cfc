component extends="testbox.system.BaseSpec"{
	function run(){
		for ( var scheme in application.testProviders ) {
			describe( "Binary Image (#scheme#)", function(){
				var res = "#scheme#/imageTest/";
				if (!DirectoryExists(res))
					expect(DirectoryCreate(res, true)).toBeNull();

				var tmp = getTempFile(res, "tmp");
				expect( FileExists(tmp) ).toBe( true );

				var img = tmp &  ".png";
				srcImg = ImageNew("",1000,1000);
				expect( ImageWrite(srcImg, img) ).toBeNull();
				expect( FileExists(img) ).toBe( true );

				expect( IsImageFile(img) ).toBe( true );
				expect( IsImage(ImageRead(img)) ).toBe(true);

				expect( FileDelete(tmp) ).toBeNull();
				expect( FileDelete(img) ).toBeNull();
				expect( DirectoryDelete(res, true)).toBeNull();
				expect( DirectoryExists(res) ).toBe( false );
			});
		}
	}
}
