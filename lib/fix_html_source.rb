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

# Only works/needed with pristine HTML source from the MIT website.
module FixHTMLSource

  # remove unneeded navigation elements,
  # add mobi-specific pagebreaks
  def self.do(src_dir)
    require 'nokogiri'
    XmlGenerator.new(src_dir).chapters.reject {|f| f == "book-Z-H-4.html"}.each do |file|
      doc = Nokogiri(File.open(file).read)

      n = doc.search(".navigation")
      #
      # This will FAIL on the source in the repo
      # because the 'navigation' elements are already removed, 
      # and so there won't be a 'first'
      #
      n.first.before( "<mbp:pagebreak />")
      n.remove
      File.open(file, "w") {|f| f.puts doc}
    end
  end
end
