ENV['TZ'] = 'UTC'

require 'date'
require 'fileutils'
require 'pathname'

require 'exifr'
require 'middleman-gh-pages'

desc 'Create a new 1/125 post'
task '1/125' do
  abort 'usage: rake 1/125 path/to/photo.jpg' unless ARGV[1]
  abort "error: #{source} does not exist" unless source.exist?
  FileUtils.cp source, full
  system(*%W(convert #{full} -resize 500000@ #{photo}))
  system(*%W(convert #{photo} -resize 50% -dither none -colors 6 #{sample}))
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

private

def ask(variable, default: nil)
  question = variable
  question += " (#{default})" if default
  print "#{question}? "
  response = $stdin.gets.chomp
  response.empty? ? default : response
end

def date
  @date ||= ask('date', default: Date.today)
end

def dir
  @dir ||= Pathname.new("source/1/125/#{date}-#{slug}").tap(&:mkdir)
end

def full
  @full ||= dir / 'full.jpg'
end

def md
  @md ||= dir.sub_ext('.md')
end

def photo
  @photo ||= dir / 'photo.jpg'
end

def place
  @place ||= ask('place')
end

def sample
  @sample ||= dir / 'sample.png'
end

def shot
  @shot ||= EXIFR::JPEG.new(source.to_s).date_time_original
end

def slug
  @slug ||= ask('slug', default: title.downcase.delete('?’').tr(' ', '-'))
end

def source
  @source ||= Pathname.new(ARGV.fetch(1))
end

def title
  @title ||= ask('title')
end
