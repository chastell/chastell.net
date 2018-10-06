ENV['TZ'] = 'UTC'

require 'bundler/setup'
require 'cgi'
require 'date'
require 'exifr/jpeg'
require 'fastimage'
require 'net/http'
require 'pathname'
require 'uri'
require 'yaml'

desc 'Create a new ¹⁄₁₂₅ post'
task '1/125', [:source] do |_task, args|
  source = source_from_uri(args.fetch(:source))
  newest = Date.parse(Dir['_posts/*.md'].max[/\d{4}-\d{2}-\d{2}/])
  date   = ask('date', default: [Date.today, newest + 1].max.to_s)
  title  = ask('title')
  slug   = ask('slug', default: slugify(title))
  place  = ask('place')
  path   = Pathname.new("_posts/#{date}-#{slug}.md")
  shot   = EXIFR::JPEG.new(source.to_s).date_time_original
  copy_assets slug: slug, source: source
  path.write frontmatter(place: place, shot: shot, title: title)
  sh 'gvim', path.to_s
  sh 'rake serve'
end

desc 'Recreate a ¹⁄₁₂₅ photo'
task '1/125:redo', [:source, :slug] do |_task, args|
  source = source_from_uri(args.fetch(:source))
  copy_assets slug: args.fetch(:slug), source: source
  Rake::Task[:assets].invoke
end

desc 'Build and publish to GitHub'
task publish: :assets do
  sh 'jekyll build --destination docs --strict_front_matter'
  sh 'git add -- docs'
  abort 'nothing to publish' if `git status --porcelain -- docs`.empty?
  sh 'git commit --message "rebuild"'
  sh 'git push'
  Rake::Task[:tweet_newest].invoke
end

desc 'Serve the site, rebuilding if necessary'
task serve: :assets do
  sh 'jekyll serve --future --livereload --open-url --strict_front_matter'
end

multitask assets: %i[dimensions photos samples]

slugs = FileList['_posts/????-??-??-*.md'].map { |path| path[18..-4] }.sort

task dimensions: :photos do
  dimensions = slugs.map do |slug|
    width, height = FastImage.size("1/125/photos/#{slug}.jpg")
    { slug => { 'height' => height, 'width' => width } }
  end.reduce({}, :merge)
  File.write('_data/photos.yml', YAML.dump(dimensions))
end

multitask photos:  slugs.map { |slug| "1/125/photos/#{slug}.jpg"  }
multitask samples: slugs.map { |slug| "1/125/samples/#{slug}.png" }

rule %r{^1/125/(photos|samples)/} => 'origs/%n.jpg' do |task|
  convert from: task.source, to: task.name
end

task :tweet_newest do
  path  = Pathname.glob('_posts/*.md').max
  front = path.read.split("---\n").reject(&:empty?).first
  title = YAML.load(front).fetch('title').gsub(%r{</?[a-z]+>}i, '')
  slug  = path.to_s[18..-4]
  uri   = URI.parse("https://chastell.net/1/125/#{slug}/")
  puts "waiting for #{uri}…"
  sleep 1 until Net::HTTP.get_response(uri).is_a?(Net::HTTPOK)
  photo = "1/125/photos/#{slug}.jpg"
  sh "t update -f #{photo} '¹⁄₁₂₅: #{title} #{uri} #chastellnet'"
  sh 'xdg-open https://twitter.com/chastell'
end

private

def ask(variable, default: '')
  question = variable
  question += " (#{default})" unless default.empty?
  print "#{question}? "
  response = $stdin.gets.chomp
  response.empty? ? default : response
end

def convert(from:, to:)
  opts = %w[-colorspace sRGB -define filter:support=2
            -define jpeg:fancy-upsampling=off -define png:compression-filter=5
            -define png:compression-level=9 -define png:compression-strategy=1
            -define png:exclude-chunk=all -dither none -filter triangle
            -interlace plane -posterize 136 -quality 82 -strip
            -unsharp 0.25x0.25+8+0.065]
  format = case to
           when /\.jpg$/ then %w[-thumbnail 2000000@]
           when /\.png$/ then %w[-thumbnail 125000@ -colors 6]
           end
  sh 'convert', from, *opts, *format, to
end

def copy_assets(source:, slug:)
  %w[.NEF .RAF .jpg .orig.jpg].product(['', '.xmp']).map(&:join).each do |ext|
    asset = source.sub_ext(ext)
    next unless asset.exist?
    cp asset, "origs/#{slug}#{ext.downcase}"
  end
end

def frontmatter(place:, shot:, title:)
  <<~end
    ---
    place: #{place}
    shot:  #{shot}
    title: #{title}
    ---

    …
  end
end

def slugify(title)
  title.unicode_normalize(:nfkd).gsub('&', 'and').downcase.delete('^0-9a-z -')
       .squeeze(' ').strip.tr(' ', '-')
end

def source_from_uri(uri)
  Pathname.new(CGI.unescape(URI.parse(uri).path))
end
