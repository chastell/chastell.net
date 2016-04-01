ENV['TZ'] = 'UTC'

require 'date'
require 'fileutils'
require 'pathname'

require 'exifr'
require 'middleman-gh-pages'

desc 'Create a new 1/125 post'
task '1/125' do
  abort 'usage: rake 1/125 path/to/photo.jpg' unless ARGV[1]
  source = Pathname.new(ARGV.fetch(1))
  abort "error: #{source} does not exist" unless source.exist?
  date  = ask('date', default: Date.today)
  title = ask('title')
  slug  = ask('slug', default: title.downcase.delete('.?’').tr(' ', '-'))
  place = ask('place')
  dir   = Pathname.new("source/1/125/#{date}-#{slug}").tap(&:mkpath)
  path  = dir.sub_ext('.md')
  photo = Photo.new(dir: dir, source: source)
  post  = Post.new(path: path, place: place, shot: photo.shot, title: title)
  photo.create
  post.create
  system(*%W(gvim #{path}))
end

namespace '1/125' do
  desc 'Recreate a 1/125 photo'
  task :photo, [:slug] do |_, args|
    abort 'usage: rake 1/125:photo[slug] path/to/photo.jpg' unless ARGV[1]
    source = Pathname.new(ARGV.fetch(1))
    abort "error: #{source} does not exist" unless source.exist?
    dir = Pathname.glob("source/1/125/*-#{args.fetch(:slug)}").first
    Photo.new(dir: dir, source: source).create
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

class Photo
  def initialize(dir:, source:)
    @full   = dir / 'full.jpg'
    @photo  = dir / 'photo.jpg'
    @sample = dir / 'sample.png'
    @source = source
  end

  def create
    FileUtils.cp source, full
    system(*%W(convert #{full} -resize 500000@ #{photo}))
    system(*%W(convert #{photo} -resize 50% -dither none -colors 6 #{sample}))
  end

  def shot
    @shot ||= EXIFR::JPEG.new(source.to_s).date_time_original
  end

  private

  attr_reader :full, :photo, :sample, :source
end

class Post
  def initialize(path:, place:, shot:, title:)
    @path  = path
    @place = place
    @shot  = shot
    @title = title
  end

  def create
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

  private

  attr_reader :path, :place, :shot, :title
end
