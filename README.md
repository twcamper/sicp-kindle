#### Slight reformatting of the pages at

    http://mitpress.mit.edu/sicp/full-text/book/book.html

1 - I got the source:

<pre>
      wget -r http://mitpress.mit.edu/sicp/full-text/book/book.html
</pre>

2 - used ~~hpricot~~ Nokogiri to:
      * remove 'navigation' divs
      * insert <code><mbp:pagebreak /></code> tags at the top of each html body to keep lines from getting split at page-breaks

3 - removed cover page 'book.html' since there's already a cover image

4 - set text-indent: 0 for <code><p></code> tags, since kindle indents about 1em by default, which deformatted the code snips (<code><p><tt></code> is used instead of <code><pre></code>)

5 - set height="2em" on div tags in 'References' section (kindle doesn't support the CSS for controlling this)

6 - added jump table to top of index

7 - built opf and ncx with ruby.  toc.ncx allows 'nav points' for the 5-way kindle knob to get you from chapter to chapter

### Notes on building the book

Recent kindlegen versions (2.9 is current as of this writing) produce much larger <code>*.mobi</code> files than mobigen or older versions of kindlegen did.  Because of that I see no reason to push a more recent build to this repo.

The old build of <code>sicp.mobi</code> in this repo seems to work fine.  But if you want or need to build it yourself . . .

* install 'kindlegen' somewhere in your path.
* make sure you have Ruby 1.8.7 or later
* run one of the following (i.e., working dir does not matter):

<pre>
    ~/sicp-kindle/lib$ ./build_book.rb opf build
    ~/sicp-kindle$ ./lib/build_book.rb opf build
</pre>

The <code>opf</code> option generates the input xml, with the current date in the metadata.  The <code>build</code> option runs kindlegen to output the <code>mobi</code> file.

You'll see this for a few minutes:

<pre>
    entering dir: $HOME/sicp-kindle/content
    running: 'kindlegen sicp.opf -c2 -verbose > mobi.out.txt'

    writing to: $HOME/sicp-kindle/content/sicp.mobi . . .
</pre>

Then probably this:

<pre>
    Warnings when building book, see $HOME/sicp-kindle/content/mobi.out.txt for information
</pre>

The warnings refer to unresolved links that seem to have no affect on the formatting or navigability of the book itself.  They won't go away until someone debugs the HTML, but there doesn't seem to be any reason to.

### Interested in reformatting?

If you start with pristine HTML source from MIT (see links above), there is <code>FixHTMLSource</code> module in the script that uses Nokogiri as an HTML parser to add mobi pagebreaks.
You could build on that tiny amount of code to manipulate the source however you see fit.  Nokogiri is a joy to use for such work, though installation of the gem has historically been tricky depending on the state of your local <code>libxsl</code> dependencies.
Note that Nokogiri is required only at runtime in <code>FixHTMLSource</code> now, so most users of the script will never run into it.


### TODO

Read the damn book!
