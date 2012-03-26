module argv_expand;
import std.file;
import std.path;

// Expand path strings using wildcards, similar to unix shell.
// This is primarily intended as wildcard expansion for Window.
// This uses a form of dirEntries which does simple pattern matching for '*' and '?'
// Wildcard expansion will occur only in the baseName of the path

string[] wildArgvs(string[] args)
{
	string[] rv;
	foreach (arg; args){
		rv ~= wildArgv(arg);
	}
	return rv;
}

string[] wildArgv(string arg){
	string[] expDirs; // expanded directories from wildargv expansion on arg
	string basename = baseName(arg);
	string dirname = dirName(arg);

	// expand the wildargs for the single level.  Don't follow links
	auto dFiles = dirEntries(dirname,basename,SpanMode.shallow,false);
	foreach(d; dFiles){
		expDirs ~=  d.name;
	}
    return expDirs;
}