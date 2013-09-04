#### Slight reformatting of the pages at

http://mitpress.mit.edu/sicp/full-text/book/book.html

1 - I got the source:

<pre>
      wget -r http://mitpress.mit.edu/sicp/full-text/book/book.html
</pre>

2 - used ~~hpricot~~ Nokogiri to:

* remove 'navigation' divs
* insert <code>&lt;mbp:pagebreak /&gt;</code> tags at the top of each html body to keep lines from getting split at page-breaks

3 - removed cover page 'book.html' since there's already a cover image

4 - set text-indent: 0 for <code>p</code> tags, since kindle indents about 1em by default, which deformatted the code snips ( <code>&lt;p&gt;&lt;tt&gt;</code> is used instead of <code>pre</code> )

5 - set height="2em" on div tags in 'References' section (kindle doesn't support the CSS for controlling this)

6 - added jump table to top of index

7 - built opf and ncx with ruby.  toc.ncx allows 'nav points' for the 5-way kindle knob to get you from chapter to chapter

### Notes on building the book

The old build of <code>sicp.mobi</code> in this repo seems to work fine.  But if you want or need to build it yourself, you need to:

1. generate the input <code>opf</code> xml, so your build has a current date.
2. run that input through 'kindlegen' to produce a large but functional book
3. optionally strip out the source that kindlegen includes in the output using '[kindlestrip.py](https://github.com/jefftriplett/kindlestrip)'

#### Building the Book

* install 'kindlegen' somewhere in your path.
* make sure you have Ruby 1.8.7 or later
* make sure you have the <code>Rake</code> gem
* ideally, have Python installed

<pre>
     $ cd ~/sicp-kindle
     # to build the book (compact binary)
     $ rake strip
     # or just
     $ rake

     # to just build, without stripping (no Python needed)
     $ rake build

     # to clean up the output artifacts
     $ rake clean

     # to see the available tasks
     $ rake -T

     # if you just want to see what the XML looks like,
     # generate it like this:
     $ rake artifacts/toc.ncx artifacts/sicp.opf
</pre>

When you run Rake (<code>:build</code> or <code>:strip</code> task), you'll see this for a few minutes:

<pre>
    mkdir -p artifacts
    generating artifacts/toc.ncx
    generating artifacts/sicp.opf
    running: 'kindlegen artifacts/sicp.opf -c2 -verbose > artifacts/kindlegen.log'

    writing to: artifacts/sicp.mobi . . .
</pre>

Then probably this:

<pre>
    Warnings when building book, see $HOME/sicp-kindle/content/mobi.out.txt for information
    kindlegen Exit Status: 1
</pre>

The warnings refer to unresolved links that seem to have no affect on the formatting or navigability of the book itself.

To deflate the output size by stripping out the input source that Amazon must have some reason for including, yet removes when they publish in their store anyway, the final <code>Rake</code> task <code>:strip</code> uses Paul Durrant's python script from this [GitHub repo](https://github.com/jefftriplett/kindlestrip).  So at the end, you'll see something like:


<pre>
    ./kindlestrip/kindlestrip.py artifacts/sicp.mobi artifacts/sicp-stripped.mobi

    KindleStrip v1.35.0. Written 2010-2012 by Paul Durrant and Kevin Hendricks.
    Found SRCS section number 750, and count 2
       beginning at offset 1082728 and ending at offset 1202268
       done
       Header Bytes: 53524353000000100000002f00000001
       kindlestrip/kindlestrip.py Exit Status: 0

       mv artifacts/sicp.mobi artifacts/sicp-large.mobi
       mv artifacts/sicp-stripped.mobi artifacts/sicp.mobi
</pre>

### Interested in reformatting?

If you start with pristine HTML source from MIT (see links above), there is a <code>:fix_html_source</code> task in the that uses Nokogiri as an HTML parser to add mobi pagebreaks.
You could build on that tiny amount of code to manipulate the source however you see fit.  Nokogiri is a joy to use for such work, though installation of the gem has historically been tricky depending on the state of your local <code>libxsl</code> dependencies.
Note that Nokogiri is required only at runtime in <code>FixHTMLSource</code> now, so users just building the book from the included source will never need it.

<pre>
    $ rake fix_html_source
</pre>

### TODO

* Read the damn book!
