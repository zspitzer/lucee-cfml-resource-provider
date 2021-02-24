/**
* Copyright Since 2005 Ortus Solutions, Corp
* www.ortussolutions.com
**************************************************************************************
*/
component{
	this.name = "cfml_resource_provider";
	// any other application.cfc stuff goes below:
	this.sessionManagement = true;

	// any mappings go here, we create one that points to the root called test.
	this.mappings[ "/tests" ] = getDirectoryFromPath( getCurrentTemplatePath() );

	// any orm definitions go here.

	// request start
	public boolean function onRequestStart( String targetPage ){
		application.testProviders = ["c:\temp\test2\", "ram://",'temp://'];
		return true;
	}
}