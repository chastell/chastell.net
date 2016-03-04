require 'fileutils'
require 'pathname'

require 'exifr'
require 'middleman-gh-pages'

desc 'Create a new 1/125 post'
task '1/125' do
  photo = ARGV.fetch(1) { raise 'please call with a filename' }
  title = ask('title')
  slug  = ask('slug', default: title.downcase.delete('’').tr(' ', '-'))
  place = ask('place')
  date  = ask('date', default: Date.today)
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

def ask(variable, default: nil)
  question = variable
  question += " (#{default})" if default
  print "#{question}? "
  response = $stdin.gets.chomp
  response.empty? ? default : response
end
