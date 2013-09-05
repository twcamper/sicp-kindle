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

# Singleton to not re-init in rake tasks
def XmlGenerator(source_directory)
  @xg ||= XmlGenerator.new source_directory
end

class XmlGenerator
  def initialize(source_directory)
    @src_dir = source_directory
  end

  def chapters
    Dir["#{@src_dir}/book-Z-H*.html"].sort_by {|name| name[/\d+/].to_i}
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
      lines << "        <content src='#{@src_dir}/book-Z-H-#{chapter[0]}.html'/>"
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

  def opf
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
               <EmbeddedCover>#{@src_dir}/cover.jpg</EmbeddedCover>
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
         <reference type="toc" title="Table of Contents" href="#{@src_dir}/book-Z-H-4.html%23chap_Temp_1"></reference>
         <reference type="start" title="Startup Page" href="#{@src_dir}/book-Z-H-9.html%23start"></reference>
     </guide>
</package>
    }
  end
end
