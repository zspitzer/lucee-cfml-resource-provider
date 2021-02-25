component extends="testbox.system.BaseSpec"{
	function run(){
		for ( var scheme in application.testProviders ) {
			describe( "java streams (#scheme#)", function(){
				/*
				var res = "#scheme#/javaStreams/";
				if (!DirectoryExists(res))
					expect(DirectoryCreate(res, true)).toBeNull();

				var tmp = getTempFile(res, "tmp");
				expect( FileExists(tmp) ).toBe( true );

				var img = tmp &  ".png";
				var srcImg = ImageNew("",1000,1000);
				expect( ImageWrite(srcImg, img) ).toBeNull();
				expect( FileExists(img) ).toBe( true );

				expect( IsImageFile(img) ).toBe( true );
				expect( IsImage(ImageRead(img)) ).toBe(true);

				// reset
				expect( FileWrite(img, "") ).toBeNull();
				expect( FileFile(tmp) ).toBeNull();

				expect( FileDelete(tmp) ).toBeNull();
				expect( FileDelete(img) ).toBeNull();
				expect( DirectoryDelete(res, true)).toBeNull();
				expect( DirectoryExists(res) ).toBe( false );
				*/
			});
		}
	}
}
