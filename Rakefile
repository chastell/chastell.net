ENV['TZ'] = 'UTC'

require 'date'
require 'exifr'
require 'fileutils'
require 'middleman-gh-pages'
require 'pathname'

desc 'Create a new 1/125 post'
task '1/125', [:source] do |task, args|
  source = Pathname.new(URI.parse(args.fetch(:source)).path)
  date   = ask('date', default: Date.today)
  title  = ask('title')
  slug   = ask('slug', default: slugify(title))
  place  = ask('place')
  dir    = Pathname.new("source/1/125/#{date}-#{slug}").tap(&:mkpath)
  path   = dir.sub_ext('.md')
  shot   = EXIFR::JPEG.new(source.to_s).date_time_original
  create_photo dir: dir, source: source
  create_post path: path, place: place, shot: shot, title: title
  system(*%W(gvim #{path}))
end

namespace '1/125' do
  desc 'Recreate a 1/125 photo'
  task :recreate, [:slug, :source] do |task, args|
    source = Pathname.new(URI.parse(args.fetch(:source)).path)
    dir    = Pathname.glob("source/1/125/*-#{args.fetch(:slug)}*").first
    create_photo dir: dir, source: source
  end
end

private

def ask(variable, default: nil)
  question = variable
  question += " (#{default})" if default
  print "#{question}? "
  response = $stdin.gets.chomp
  response.empty? ? default : response
end

def create_photo(dir:, source:)
  Dir.chdir(dir) do
    FileUtils.cp source, 'full.jpg'
    system 'convert full.jpg -resize 500000@ photo.jpg'
    system 'convert full.jpg -resize 125000@ -dither none -colors 6 sample.full.png'
    system 'pngcrush sample.full.png sample.png'
    FileUtils.rm 'sample.full.png'
  end
end

def create_post(path:, place:, shot:, title:)
  path.write <<~end
    ---
    place: #{place}
    shot:  #{shot}
    taken: #{shot.strftime('%B %Y')}
    title: #{title}
    ---

    …
  end
end

def slugify(title)
  title.downcase.delete('!(),.:?|’…').gsub('&', 'and').tr(' ', '-').squeeze('-')
end
