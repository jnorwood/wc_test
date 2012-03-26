module wcTest;
import std.stdio;
import std.parallelism;
import std.array;
import std.datetime;
import std.ascii;

import std.stdio;
import std.datetime;
import std.regex;
import argv_expand;
import std.file;
import std.string;


import std.file;
import std.parallelism;

// Removes files or directories in parallel using taskpool.
// Doesn't follow links.
// The parallel foreach removes all regular files and links.  Any order ok.
// The parallel foreach completes all tasks before exiting.
// The following non-parallel portion removes all directories, depth first.


 void wcParallel(void function (string) fun,string[] pathnames){
	DirEntry[] des;
	foreach ( pn;pathnames){
		DirEntry de = dirEntry(pn);
		des ~= de;
	}
	wcParallel (fun, des);
}


void wcParallel (void function (string) fun,DirEntry[] des){ 

	string files[];
	foreach (DirEntry e; des){
		if (!e.isDir()){
			files ~= e.name ;
		}
	}
	// parallel foreach removes regular files and links
	foreach(fn; taskPool.parallel(files,1)) {
		fun(fn);
	}
}



void wcp1(string fn)
{
	string input = cast(string)std.file.read(fn);
	// into a matrix of doubles.
    int[string] map;
	int l_cnt;
	int c_cnt = input.length;
	int w_cnt;

	int j=0;
	int wstart;
	int inWord;

	for (; j < input.length; j++)
	{   
		char c  = input[j];

		if (c >= 'a' && c <= 'z' ||
			c >= 'A' && c <= 'Z')
		{
			if (!inWord)
			{
				wstart = j;
				inWord = 1;
				++w_cnt;
			}
		}
		else if (c >= '0' && c <= '9')
		{
		}
		else {
			if (c == '\n')
				++l_cnt;
			if (inWord)
			{   
				auto word = input[wstart .. j];
				++map[word];
				inWord = 0;
			}
		}
	}
	if (inWord)
	{   
		auto w = input[wstart .. input.length];
		++map[w];
	}

	int sval;
	string skey;
	foreach ( word1; map.keys.sort)
	{
	 	sval = map[word1];
	 	skey =  word1;
	}

}
// do nothing
//finished! time: 1 ms
void wcp_nothing(string fn)
{
	//G:\d\a7\a7\Release>a7

}

// read files
//finished! time: 31 ms
void wcp_whole_file(string fn)
{
	auto input = std.file.read(fn);
}

// read files by line ... yikes! don't want to do this
//finished! time: 485 ms
void wcp_byLine(string fn)
{
	auto f = File(fn);
	foreach(line; f.byLine(std.string.KeepTerminator.yes)){
	}
}

// read files by chunk ...!better than full input
//finished! time: 23 ms
void wcp_byChunk(string fn)
{
	auto f = File(fn);
	foreach(chunk; f.byChunk(1_000_000)){
	}
}

// read lc by chunk ...same as full input
//finished! time: 34 ms
void wcp_lcByChunk (string fn)
{
	ulong l_cnt;
	auto f = File(fn);
	foreach(chunk; f.byChunk(1_000_000)){
		foreach(c;chunk){
			if (c=='\n')
				l_cnt++;
		}
	}
}
// read dchar lc by chunk ...same  
//finished! time: 34 ms
void wcp_lcDcharByChunk(string fn)
{
	ulong l_cnt;
	auto f = File(fn);
	foreach(chunk; f.byChunk(1_000_000)){
		foreach(dchar c;chunk){
			if (c=='\n')
				l_cnt++;
		}
	}
}

// count lines with regex
//finished! time: 136 ms
void wcp_lcRegex(string fn)
{
	string input = cast(string)std.file.read(fn);
	auto rx = regex("\n");
	ulong l_cnt;
	foreach(e; splitter(input, rx))
	{
		l_cnt ++;
	}
}

// count lines with compiled ctRegex matcher
//finished! time: 97 ms
void wcp_lcCtRegex(string fn)
{
	string input = cast(string)std.file.read(fn);
	enum ctr =  ctRegex!("\n","g");
	ulong l_cnt;
	foreach(m; match(input,ctr))
	{
		l_cnt ++;
	}
}

// count lines with compiled ctRegex matcher
// only returns 1
void wcp_cnt_match1 (string fn)
{
	string input = cast(string)std.file.read(fn);
	enum ctr =  ctRegex!("$","m");
	ulong l_cnt = std.algorithm.count(match(input,ctr));
}

// count lines with std.algorithm.count
//finished! time: 133 ms
void wcp_lcStdAlgoCount(string fn)
{
	string input = cast(string)std.file.read(fn);
    ulong l_cnt = std.algorithm.count(input,"\n");
}

// gets a compiler error
void wcp_bug_no_p(string fn)
{
	//enum ctr =  ctRegex!(r"\p{WhiteSpace}","m");
}

//count lines with char match, this or the one with chunks about the same
//finished! time: 34 ms
void wcp_lcChar(string fn)
{
	string input = cast(string)std.file.read(fn);
	ulong l_cnt;
	foreach(c; input)
	{
		if (c == '\n')
		l_cnt ++;
	}
}

//find words using pointers 
//finished! time: 110 ms
void wcp_wcPointer(string fn)
{
	string input = cast(string)std.file.read(fn);
	ulong w_cnt;
	char c;
	auto p = input.ptr;
	auto pe = p+input.length;
	while(p<pe)
	{
		c = *p;

		if (c >= 'a' && c <= 'z' ||
			c >= 'A' && c <= 'Z')
		{
			++w_cnt;
			auto st = p++;
			while (p<pe){
				c = *p;
				if 	(!(c >= 'a' && c <= 'z' ||
					 c >= 'A' && c <= 'Z' || 
					 c >= '0' && c <= '9'))
				{
					break;
				}
				p++;
			}
			auto wpend = p;
		}
		p++;
	}
}

// count words with compiled ctRegex matcher !way too slow
//finished! time: 1299 ms for ctRegex
//finished! time: 2608 ms for regex
void wcp_wcCtRegex (string fn)
{
	string input = cast(string)std.file.read(fn);
	enum ctr =  ctRegex!("[a-zA-Z][a-zA-Z0-9]*","g");
	ulong w_cnt;
	foreach(m; match(input,ctr))
	{
		//auto s = m.hit;
		w_cnt ++;
	}
}

void wcp_wcRegex (string fn)
{
	string input = cast(string)std.file.read(fn);
	auto ctr =  regex("[a-zA-Z][a-zA-Z0-9]*","g");
	ulong w_cnt;
	foreach(m; match(input,ctr))
	{
		//auto s = m.hit;
		w_cnt ++;
	}
}

// wc with \w  Too slow vs 110ms handcoded version, plus accepts digits in first char
//finished! time: regex 2414 ms
void wcp_wcRegex2(string fn)
{
	string input = cast(string)std.file.read(fn);
	enum ctr =  regex(r"\w+","g");
	ulong w_cnt;
	foreach(m; match(input,ctr))
	{
		auto s = m.hit;
		w_cnt ++;
	}
}

void wcpx(string fn)
{
//	enum ctr =  ctRegex!(r"\w+","g");
}


//find words with slices .. ok this is slower by a bunch
//finished! time: 153 ms
void wcp_wcSlices(string fn)
{
	string input = cast(string)std.file.read(fn);
	ulong w_cnt;
	while (!input.empty)
	{
		auto c = input[0];
  		if (c >= 'a' && c <= 'z' ||
			c >= 'A' && c <= 'Z')
		{
			++w_cnt;
			auto word = input;
 			foreach(j,char w ;input){  
				if 	(!(w >= 'a' && w <= 'z' ||
					   w >= 'A' && w <= 'Z' || 
					   w >= '0' && w <= '9'))
				{
					word = input[0..j];
					input = input[j..$]; 
					break;
				}
			}
		}
		else input = input[1..$];
	}
}
//find words with std.ascii.isAlpha and isAlphaNum .. much worse 
//finished! time: 232 ms
void wcp_wcStdAscii (string fn)
{
	string input = cast(string)std.file.read(fn);
	ulong w_cnt;
	while (!input.empty)
	{
		auto c = input[0];
  		if (std.ascii.isAlpha(c))
		{
			++w_cnt;
			auto word = input;
 			foreach(j,char w ;input){  
				if 	(!std.ascii.isAlphaNum(w))
				{
					word = input[0..j];
					input = input[j..$]; 
					break;
				}
			}
		}
		else input = input[1..$];
	}
}


// Testing in preparation for a parallel version of wc

int main(string[] argv)
{
	// uncomment these and rename argv in parameter list for thesting
	//string[] argv;
	//argv ~= "";
	//argv ~= r"f:\alice*.txt";

 	if (argv.length < 2){
 		writeln ("Word count and create dictionary for files.");
 		writeln ("Simple wildcard expansion in the basename of source pathnames.");
 		writeln (r"Example:  wcd d:\mySourcedir\*.d");
 		return 0;
 	}

	// the source pathnames. can be only some files
	// these can use wildcard expansion in the basename only


	string[] pathnames;
 	foreach(srcPath;  wildArgvs( argv[1..$]))
	{
		pathnames ~= srcPath;
	}

	auto sw = StopWatch(AutoStart.yes);

	sw.reset();
	wcParallel(&wcp_nothing,pathnames); 
	auto tm = sw.peek().msecs;
	writefln("finished wcp_nothing! time: %s ms", tm );


	sw.reset();
	wcParallel(&wcp_whole_file,pathnames); 
	tm = sw.peek().msecs;
	writefln("finished wcp_whole_file! time: %s ms", tm );

	sw.reset();
	wcParallel(&wcp_byLine,pathnames); 
	tm = sw.peek().msecs;
	writefln("finished wcp_byLine! time: %s ms", tm );

	sw.reset();
	wcParallel(&wcp_byChunk,pathnames); 
	tm = sw.peek().msecs;
	writefln("finished wcp_byChunk! time: %s ms", tm );

	sw.reset();
	wcParallel(&wcp_lcByChunk,pathnames); 
	tm = sw.peek().msecs;
	writefln("finished wcp_lcByChunk! time: %s ms", tm );

	sw.reset();
	wcParallel(&wcp_lcDcharByChunk,pathnames); 
	tm = sw.peek().msecs;
	writefln("finished wcp_lcDcharByChunk! time: %s ms", tm );

	
	sw.reset();
	wcParallel(&wcp_lcRegex,pathnames); 
	tm = sw.peek().msecs;
	writefln("finished wcp_lcRegex! time: %s ms", tm );

	sw.reset();
	wcParallel(&wcp_lcCtRegex,pathnames); 
	tm = sw.peek().msecs;
	writefln("finished wcp_lcCtRegex! time: %s ms", tm );

	sw.reset();
	wcParallel(&wcp_lcStdAlgoCount,pathnames); 
	tm = sw.peek().msecs;
	writefln("finished wcp_lcStdAlgoCount! time: %s ms", tm );

	sw.reset();
	wcParallel(&wcp_lcChar,pathnames); 
	tm = sw.peek().msecs;
	writefln("finished wcp_lcChar! time: %s ms", tm );

	sw.reset();
	wcParallel(&wcp_wcPointer,pathnames); 
	tm = sw.peek().msecs;
	writefln("finished wcp_wcPointer! time: %s ms", tm );


	sw.reset();
	wcParallel(&wcp_wcCtRegex,pathnames); 
	tm = sw.peek().msecs;
	writefln("finished wcp_wcCtRegex! time: %s ms", tm );

	sw.reset();
	wcParallel(&wcp_wcRegex,pathnames); 
	tm = sw.peek().msecs;
	writefln("finished wcp_wcRegex! time: %s ms", tm );

	sw.reset();
	wcParallel(&wcp_wcRegex2,pathnames); 
	tm = sw.peek().msecs;
	writefln("finished wcp_wcRegex2! time: %s ms", tm );
	
	sw.reset();
	wcParallel(&wcp_wcSlices,pathnames); 
	tm = sw.peek().msecs;
	writefln("finished wcp_wcSlices! time: %s ms", tm );

	sw.reset();
	wcParallel(&wcp_wcStdAscii,pathnames); 
	tm = sw.peek().msecs;
	writefln("finished wcp_wcStdAscii! time: %s ms", tm );
	
	return 0;
}
