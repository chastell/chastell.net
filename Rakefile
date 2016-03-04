require 'fileutils'
require 'pathname'

require 'exifr'
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
  date_default = Date.today
  print "date (#{date_default})? "
  date = $stdin.gets.chomp
  date = date_default if date.empty?
  md = Pathname.new("source/1/125/#{date}-#{slug}.md")
  dir = md.sub_ext('')
  dir.mkdir
  full   = dir / 'full.jpg'
  view   = dir / 'photo.jpg'
  sample = dir / 'sample.png'
  FileUtils.cp photo, full
  system(*%W(convert #{full} -resize 500000@ #{view}))
  system(*%W(convert #{view} -resize 50% -dither none -colors 6 #{sample}))
  shot = EXIFR::JPEG.new(full.to_s).date_time_original
  md.write <<~end
    ---
    place: #{place}
    shot:  #{shot}
    taken: #{shot.strftime('%B %Y')}
    title: #{title}
    ---

    …
  end
  system(*%W(gvim #{md}))
end
