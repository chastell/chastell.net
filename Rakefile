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
  Photo.new(date: date, slug: slug, source: source).create
  Post.new(date: date, place: place, slug: slug,
           source: source, title: title).create
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
  def initialize(date:, slug:, source:)
    @date   = date
    @slug   = slug
    @source = source
  end

  def create
    FileUtils.cp source, full
    system(*%W(convert #{full} -resize 500000@ #{photo}))
    system(*%W(convert #{photo} -resize 50% -dither none -colors 6 #{sample}))
  end

  private

  attr_reader :date, :slug, :source

  def dir
    @dir ||= Pathname.new("source/1/125/#{date}-#{slug}").tap(&:mkpath)
  end

  def full
    @full ||= dir / 'full.jpg'
  end

  def photo
    @photo ||= dir / 'photo.jpg'
  end

  def sample
    @sample ||= dir / 'sample.png'
  end
end

class Post
  def initialize(date:, place:, slug:, source:, title:)
    @date   = date
    @place  = place
    @slug   = slug
    @source = source
    @title  = title
  end

  def create
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

  attr_reader :date, :place, :slug, :source, :title

  def dir
    @dir ||= Pathname.new("source/1/125/#{date}-#{slug}").tap(&:mkpath)
  end

  def md
    @md ||= dir.sub_ext('.md')
  end

  def shot
    @shot ||= EXIFR::JPEG.new(source.to_s).date_time_original
  end
end
