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
require 'rake/clean'
require './lib/book_builder'
require './lib/fix_html_source'

PROJECT    = File.expand_path(File.dirname(__FILE__))
SRC        = "#{PROJECT}/content"  # we need the absolute path for parts of the XML
ARTIFACTS  = "artifacts"
NCX_TOC    = "#{ARTIFACTS}/toc.ncx"
OPF        = "#{ARTIFACTS}/sicp.opf"
BOOK       = "#{ARTIFACTS}/sicp.mobi"
LARGE_BOOK = "#{ARTIFACTS}/sicp-large.mobi"
STRIPPER   = "kindlestrip/kindlestrip.py"
LOG        = "#{ARTIFACTS}/kindlegen.log"

# Clean list
CLEAN.include(FileList["#{ARTIFACTS}/**", ARTIFACTS])

# Rake method to make the dir if necessary
directory(ARTIFACTS)

desc "when you just run '$ rake', '#{BOOK}' runs"
task :default => :build

desc "alias: create '#{BOOK}' with kindlestrip"
task :build => BOOK

desc "alias: create '#{LARGE_BOOK}' with kindlegen"
task :build_large => LARGE_BOOK

desc "FINAL OUTPUT: remove source from completed ebook to reduce size by 1/3"
task BOOK => LARGE_BOOK do
  cmd = "#{STRIPPER} #{LARGE_BOOK} #{BOOK}"
  puts "running '#{cmd}'"
  puts `#{cmd}`

  puts "#{STRIPPER} exit status: #{$?.exitstatus}"
  puts
end

desc "usable ebook, but bloated with input source"
file LARGE_BOOK => OPF do
  # kindlegen executable must be on your path
  # cmd = "kindlegen #{OPF} -verbose > #{LOG}"     # about the same as -c1
  cmd = "kindlegen #{OPF} -c2 -verbose > #{LOG}"    # Smallest, but SLOW!!
  puts "running '#{cmd}'"
  puts "\twriting to directory '#{ARTIFACTS}'\n"
  `#{cmd}`
  result = $?

  puts "kindlegen exit status #{result.exitstatus}:"
  # kindlegen exitstatus 1 = warning, 0 = success, Others = error
  if result.exitstatus == 0
    puts "\tBook built successfully!"
  elsif result.exitstatus == 1
    puts "\tSuccess with warnings: see #{LOG} for information"
  else
    raise "Failed to build book: see #{LOG} for information"
  end
  FileUtils.mv(BOOK, LARGE_BOOK, :verbose => true)
  puts
end

desc "OPF xml: depends on NCX T.O.C."
file OPF => NCX_TOC do
  puts "generating '#{OPF}'"
  File.open(OPF, "w") {|f| f.puts BookBuilder(SRC).opf}
end

desc "T.O.C NCX xml: depends on artifacts dir being present"
file NCX_TOC => ARTIFACTS do
  puts "generating '#{NCX_TOC}'"
  File.open(NCX_TOC, "w") {|f| f.puts BookBuilder(SRC).ncx_toc}
end

desc "fix HTML if you got new source from MIT"
task :fix_html_source do
  FixHTMLSource.do SRC
end
