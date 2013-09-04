#!/usr/bin/env ruby
# This is free and unencumbered software released into the public domain.

# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.

# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

# For more information, please refer to <http://unlicense.org/>

require 'rubygems'
require 'date'

# Only works/needed with pristine HTML source from the MIT website.
module FixHTMLSource

  def self.chapters
    @chapters ||= BookBuilder.new.chapters
  end

  # remove unneeded navigation elements,
  # add mobi-specific pagebreaks
  def self.do
    require 'nokogiri'
    chapters.reject {|f| f == "book-Z-H-4.html"}.each do |file|
      doc = Nokogiri(File.open(file).read)

      n = doc.search(".navigation")
      #
      # This will FAIL on the source in the repo
      # because the 'navigation' elements are already removed!!
      #
      n.first.before( "<mbp:pagebreak />")
      n.remove
      File.open(file, "w") {|f| f.puts doc}
    end
  end
end

class BookBuilder
  def chapters
    @chapters ||= get_chapters
  end

  def get_chapters
    files = Dir["book-Z-H*.html"].sort_by {|name| name[/\d+/].to_i}
    files.collect { |f| f.split(/\//).last }
  end

  def navigation_points
    lines = []
    [
    [9,9],
    [13,13],
    [19,19],
    [25,25],
    [30,30],
    [36,"References"],
    [37,"List of Exercises"],
    [38,"Index"]
    ].each_with_index do |chapter, i|
      number = i + 1
      label = chapter[1].is_a?(Fixnum) ? "Chapter #{number}" : chapter[1]

      lines << "    <navPoint id='navPoint-#{number}' playOrder='#{number}'>"
      lines << "        <navLabel><text>#{label}</text></navLabel>"
      lines << "        <content src='book-Z-H-#{chapter[0]}.html'/>"
      lines << "    </navPoint>"
    end
    return lines
  end
  
  def ncx_toc
    %Q{<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE ncx PUBLIC "-//NISO//DTD ncx 2005-1//EN" "http://www.daisy.org/z3986/2005/ncx-2005-1.dtd">
<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">
<head>
<meta name="dtb:uid" content="BookId"/>
</head>
   <docTitle><text>Structure and Interpretation of Computer Programs</text></docTitle>
   <navMap>
    #{navigation_points.join("\n")}
   </navMap>
</ncx>
    }
  end
  
  def manifest_items
    item_count = 0
    chapters.inject([]) do |lines, chapter|
      item_count += 1
      lines << "          <item id='item#{item_count}' media-type='application/xhtml+xml' href='#{chapter}'></item>"
    end
  end
  
  def item_refs
    lines = []
    manifest_items.size.times { |i| lines << "          <itemref idref='item#{i + 1}'/>"}
    return lines
  end

  def opf(toc_html)
    %Q{<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="2.0" unique-identifier="BookId">
     <metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:opf="http://www.idpf.org/2007/opf">
          <dc:title>Structure and Interpretation of Computer Programs</dc:title>
          <dc:language>en-us</dc:language>
          <dc:identifier id="BookId" opf:scheme="ISBN">0262011530</dc:identifier>
          <dc:creator>Abelson and Sussman</dc:creator>
          <dc:description>Structure and Interpretation of Computer Programs, 2nd edition</dc:description>
          <dc:subject>Electronic Digital Computers -- Programming</dc:subject>
          <dc:publisher>The MIT Press</dc:publisher>
          <dc:date>#{Date.today}</dc:date>
          <x-metadata>
               <output encoding="utf-8" content-type="text/x-oeb1-document"></output>
               <EmbeddedCover>cover.jpg</EmbeddedCover>
          </x-metadata>
     </metadata>
     <manifest>
          #{manifest_items.join("\n")}
          <item id="ncx" media-type="application/x-dtbncx+xml" href="toc.ncx"></item>
     </manifest>
     <spine toc="ncx">
          #{item_refs.join("\n")}
     </spine>
     <tours></tours>
     <guide>
         <reference type="toc" title="Table of Contents" href="#{toc_html}%23chap_Temp_1"></reference>
         <reference type="start" title="Startup Page" href="book-Z-H-9.html%23start"></reference>
     </guide>
</package>
    }
  end
end


if __FILE__ == $0

  if ARGV.empty? or
     ARGV.include?("-h") or
     ARGV.include?("--help") or
     ARGV.include?("help")
	  puts "Usage: build_book.rb [build] [toc] [opf] [fix]"
	  puts "  build - Build the book"
	  puts "  toc - Generate table of contents if toc.ncx is missing"
	  puts "  opf - Generate OPF metadata file to update publication date"
	  puts "  fix - fix html source -- not necessary with the source in this repo"
	  exit 1
  end

  # ########################################################################
  # Local Input/Output file names
  # ########################################################################
  PROJECT    = File.expand_path(File.dirname(__FILE__) + "/..")
  CONTENT    = "#{PROJECT}/content"
  TOC_HTML   = "book-Z-H-4.html"
  NCX_TOC    = "toc.ncx"
  OPF        = "sicp.opf"
  LOG        = "mobi.out.txt"

  puts "entering dir: #{CONTENT}"
  Dir.chdir(CONTENT)

  bb = BookBuilder.new

  File.open(NCX_TOC, "w")    {|f| f.puts bb.ncx_toc}       if ARGV.include?("toc")
  File.open(OPF, "w")        {|f| f.puts bb.opf(TOC_HTML)} if ARGV.include?("opf")
  # ################################################################################
  # Only run 'FixHTMLSource.do' if you're working with pristine HTML source from MIT
  # The source in ../content is already 'fixed' so the 'do()' method will fail.
  # ################################################################################
  FixHTMLSource.do                                         if ARGV.include?("fix")

  if ARGV.include?("build")
    # kindlegen executable must be on your path
    cmd = "kindlegen #{OPF} -c2 -verbose > #{LOG}"
    puts "running: '#{cmd}'"
    puts "\nwriting to: #{CONTENT}/#{OPF.sub('opf', 'mobi')} . . .\n"
    `#{cmd}`
	  result = $?

    # kindlegen exitsatus 1 = warning, 0 = success, Others = error
	  if result.exitstatus == 1
		  puts "Warnings when building book, see #{CONTENT}/#{LOG} for information"
	  elsif result.exitstatus == 0
		  puts "Book built successfully!"
	  else
		  puts "Failed to build book, see #{CONTENT}/#{LOG} for information"
	  end

    exit result.exitstatus
  end

  exit 0
end
