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
     $ rake build
     # or just
     $ rake

     # to just build a large but usable book, without stripping (no Python needed)
     $ rake build_large

     # to clean up the output artifacts
     $ rake clean

     # hack/test cycle
     $ rake clean build

     # learn about Rake itself
     $ rake -h

     # to see the available tasks and their dependencies
     $ rake -T && rake -P

     # if you just want to see what the XML looks like without building,
     # generate it like this:
     $ rake artifacts/toc.ncx artifacts/sicp.opf
</pre>

When you run Rake (<code>:build</code> or <code>:strip</code> task), you'll see this for a few minutes:

<pre>
    mkdir -p artifacts
    generating 'artifacts/toc.ncx'
    generating 'artifacts/sicp.opf'
    running 'kindlegen artifacts/sicp.opf -c2 -verbose > artifacts/kindlegen.log'
        writing to directory 'artifacts'
</pre>

Then probably this:

<pre>
    kindlegen exit status: 1
        Success with warnings: see artifacts/kindlegen.log for information
    mv artifacts/sicp.mobi artifacts/sicp-large.mobi
</pre>

The warnings refer to unresolved links that have no real effect on the formatting or navigability of the book itself.  There are 2 kinds: html anchors referring back to the TOC page, and gif images.  The anchors are actually broken links that persist in the live MIT source to this day. In the Kindle book they just don't do anything, so it's not a real issue.  The gif's actually work like they should, so with respect to those Kindlegen is just crazy.

To deflate the output size by stripping out the input source that Amazon must have some reason for including, yet removes when they publish in their store anyway, the final <code>Rake</code> task uses Paul Durrant's python script from this [GitHub repo](https://github.com/jefftriplett/kindlestrip).  So at the end, you'll see something like:


<pre>
    running 'kindlestrip/kindlestrip.py artifacts/sicp.mobi artifacts/sicp-stripped.mobi'
    KindleStrip v1.35.0. Written 2010-2012 by Paul Durrant and Kevin Hendricks.
    Found SRCS section number 750, and count 2
       beginning at offset 1082728 and ending at offset 1202268
    done
    Header Bytes: 53524353000000100000002f00000001
    kindlestrip/kindlestrip.py exit status: 0

</pre>

### Kindlegen Compression Settings

According to the usage output from just

  $ kindlegen

you can say <code>-c0, -c1, -c2</code> or nothing at all.  With respect to runtime and output size, "nothing" is about the same as <code>-c1</code>. <code>-c0</code> is just 2 or 3 seconds faster than those, but an <em>ENORMOUS</em> file is produced.  Size of a house, I'm serious.  <code>-c2</code> (my default) is <em>SLOW</em> but the smallest.

You can alter the setting in the Rakefile in the <code>LARGE_BOOK</code> file task.

Here are some results from my 2010 MBP running KindleGen 2.9.

<pre>
  # No compression setting 
  $ time kindlegen artifacts/sicp.opf -verbose > artifacts/kindlegen.log
    l0m9.258s
    user0m15.597s
    sys0m1.156s
  $ ll artifacts/*.mobi
    -rw-r--r--  1 twcamper  staff  4040242 Sep  4 18:51 artifacts/sicp-large.mobi
    -rw-r--r--  1 twcamper  staff  2833465 Sep  4 18:51 artifacts/sicp.mobi

  # '-c0' compression setting -- fast, fattest
  $ time kindlegen artifacts/sicp.opf -c0 -verbose > artifacts/kindlegen.log
    real0m7.864s
    user0m12.949s
    sys0m1.207s
  $ ll artifacts/*.mobi
    -rw-r--r--  1 twcamper  staff  6816182 Sep  4 18:52 artifacts/sicp-large.mobi
    -rw-r--r--  1 twcamper  staff  5609417 Sep  4 18:52 artifacts/sicp.mobi

  # '-c1' compression setting 
  $ time kindlegen artifacts/sicp.opf -c1 -verbose > artifacts/kindlegen.log
    real0m9.245s
    user0m15.952s
    sys0m1.160s
  $ ll artifacts/*.mobi
    -rw-r--r--  1 twcamper  staff  4040078 Sep  4 18:52 artifacts/sicp-large.mobi
    -rw-r--r--  1 twcamper  staff  2833465 Sep  4 18:52 artifacts/sicp.mobi

  # '-c2' compression setting -- slowest, smallest
  $ time kindlegen artifacts/sicp.opf -c2 -verbose > artifacts/kindlegen.log
    real2m13.958s
    user3m58.323s
    sys0m1.684s
  $ ll artifacts/*.mobi
    -rw-r--r--  1 twcamper  staff  3249518 Sep  4 18:56 artifacts/sicp-large.mobi
    -rw-r--r--  1 twcamper  staff  2042629 Sep  4 18:56 artifacts/sicp.mobi
</pre>

### Interested in reformatting?

If you start with pristine HTML source from MIT (see links above), there is a <code>:fix_html_source</code> task that uses Nokogiri as an HTML parser to add mobi pagebreaks.
You could build on that tiny amount of code to manipulate the source however you see fit.  Nokogiri is a joy to use for such work, though installation of the gem has historically been tricky depending on the state of your local <code>libxsl</code> dependencies.
Note that Nokogiri is required only at runtime in <code>FixHTMLSource</code> now, so users just building the book from the included source will never need it.

<pre>
    $ rake fix_html_source
</pre>

### TODO

* revisit the height issue on the <code>References</code> page.  Modern Kindlegen might handle the problem in a standard way now.
* Read the damn book!
