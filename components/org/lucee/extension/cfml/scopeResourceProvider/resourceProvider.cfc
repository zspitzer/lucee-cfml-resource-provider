// from https://gist.github.com/dajester2013/e22eb4044ed1af149741
interface {
	
	public ResourceProvider function init(String scheme, Struct args);

	public Resource function getResource(String path);

	public boolean function isCaseSensitive();

	public boolean function isModeSupported();

	public boolean function isAttributesSupported();
	
}