require 'fileutils'
require 'pathname'
require 'middleman-gh-pages'

desc 'Create a new 1/125 post'
task '1/125' do
  photo = ARGV.fetch(1) { raise 'please call with a filename' }
  print 'title? '
  title = $stdin.gets.chomp
  slug_default = title.downcase.delete('’').tr(' ', '-')
  print "slug (#{slug_default})? "
  slug = $stdin.gets.chomp
  slug = slug_default if slug.empty?
  print 'place? '
  place = $stdin.gets.chomp
  md = Pathname.new("source/1/125/#{Date.today}-#{slug}.md")
  dir = md.sub_ext('')
  dir.mkdir
  full   = dir / 'full.jpg'
  view   = dir / 'photo.jpg'
  sample = dir / 'sample.png'
  FileUtils.cp photo, full
  system(*%W(convert #{full} -resize 500000@ #{view}))
  system(*%W(convert #{view} -resize 50% -dither none -colors 6 #{sample}))
  md.write <<~end
    ---
    place: #{place}
    shot:  …
    taken: …
    title: #{title}
    ---

    …
  end
  system(*%W(gvim #{md}))
end
