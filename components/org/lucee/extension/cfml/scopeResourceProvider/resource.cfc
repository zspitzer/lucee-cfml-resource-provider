// from https://gist.github.com/dajester2013/e22eb4044ed1af149741
interface {

	public boolean function isReadable();
	
	public boolean function isWriteable();

	public void function remove(boolean force);

	public boolean function exists();

	public String function getName();

	public String function getParent();

	public Resource function getParentResource();

	public Resource function getRealResource(String realpath);

	public String function getPath();

	public boolean function isAbsolute();

	public boolean function isDirectory();

	public boolean function isFile();

	public date function lastModified();

	public numeric function length();

	public Resource[] function listResources();

	public boolean function setLastModified(date time);

	public boolean function setWritable(boolean writable);

	public boolean function setReadable(boolean readable);

	public void function createFile(boolean createParentWhenNotExists);

	public void function createDirectory(boolean createParentWhenNotExists);

	public /*java.io.InputStream*/ function getInputStream();

	public /*java.io.OutputStream*/ function getOutputStream(boolean append);

	public void function setBinary(byteArray);
	
	public binary function getBinary();

	public numeric function getMode();

	public void function setMode(numeric mode);
		
}