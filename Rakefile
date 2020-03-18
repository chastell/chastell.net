ENV['TZ'] = 'UTC'

require 'bundler/setup'
require 'cgi'
require 'date'
require 'exifr/jpeg'
require 'fastimage'
require 'net/http'
require 'pathname'
require 'twitter'
require 'uri'
require 'yaml'

desc 'Create a new ¹⁄₁₂₅ post'
task '1/125', [:source] do |_task, args|
  source = source_from_uri(args.fetch(:source))
  newest = Date.parse(Dir['_posts/*.md'].max[/\d{4}-\d{2}-\d{2}/])
  date   = ask('date', default: [Date.today, newest + 1].max.to_s)
  title  = ask('title')
  slug   = ask('slug', default: slugify(title))
  abort "#{slug} already exists" if slugs.include?(slug)
  place  = ask('place')
  path   = Pathname.new("_posts/#{date}-#{slug}.md")
  shot   = EXIFR::JPEG.new(source.to_s).date_time_original
  copy_assets slug: slug, source: source
  path.write frontmatter(place: place, shot: shot, title: title)
  sh 'vim', path.to_s
  sh 'rake serve'
end

desc 'Add a photo to an existing ¹⁄₁₂₅ entry'
task '1/125:add', [:source, :slug] do |_task, args|
  source = source_from_uri(args.fetch(:source))
  slug   = args.fetch(:slug)
  abort "#{slug} does not exist" unless slugs.include?(slug)
  indexed_slug = "#{slug}.#{slug_index(slug) + 1}"
  copy_assets slug: indexed_slug, source: source
  multitask photos:  "1/125/photos/#{indexed_slug}.jpg"
  multitask samples: "1/125/samples/#{indexed_slug}.png"
  Rake::Task[:assets].invoke
end

desc 'Recreate a ¹⁄₁₂₅ photo'
task '1/125:redo', [:source, :slug] do |_task, args|
  source = source_from_uri(args.fetch(:source))
  slug   = args.fetch(:slug)
  abort "#{slug} does not exist" unless slugs.include?(slug)
  copy_assets slug: slug, source: source
  Rake::Task[:assets].invoke
end

desc 'Build and publish to GitHub'
task publish: :assets do
  sh 'jekyll build --destination docs --strict_front_matter'
  sh 'git add -- docs'
  abort 'nothing to publish' if `git status --porcelain -- docs`.empty?
  sh 'git commit --message "rebuild"'
  sh 'git push'
  puts 'sleeping for a bit to let GitHub Pages rebuild their cache'
  sleep 10
  sh 'git commit --allow-empty --message "refresh"'
  sh 'git push'
  Rake::Task[:tweet_newest].invoke unless ENV['DONT_TWEET']
end

desc 'Serve the site, rebuilding if necessary'
task serve: :assets do
  sh 'jekyll serve --future --host 0.0.0.0 ' \
     '--livereload --open-url --strict_front_matter'
end

multitask assets: %i[dimensions photos samples]

task dimensions: :photos do
  dimensions = slugs.map do |slug|
    extra = slug_index(slug)
    width, height = FastImage.size("1/125/photos/#{slug}.jpg")
    { slug => { 'extra' => extra, 'height' => height, 'width' => width } }
  end.reduce({}, :merge)
  File.write('_data/photos.yml', YAML.dump(dimensions))
end

origs = Pathname.glob('origs/*.jpg').map(&:basename)
multitask photos:  origs.map { |orig| "1/125/photos/#{orig}"                  }
multitask samples: origs.map { |orig| "1/125/samples/#{orig.sub_ext('.png')}" }

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
  trc    = YAML.load(Pathname('~/.trc').expand_path.read)
  t_prof = trc.dig('profiles', *trc.dig('configuration', 'default_profile'))
  config = { access_token:        t_prof.fetch('token'),
             access_token_secret: t_prof.fetch('secret'),
             consumer_key:        t_prof.fetch('consumer_key'),
             consumer_secret:     t_prof.fetch('consumer_secret') }
  client = Twitter::REST::Client.new(config)
  photos = ["1/125/photos/#{slug}.jpg"] + Dir["1/125/photos/#{slug}.*.jpg"].sort
  text   = ["¹⁄₁₂₅: #{title}", uri, '#chastellnet'].join("\n")
  puts text
  client.update_with_media text, photos.map(&File.method(:new))
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
  %w[.NEF .RAF .jpeg .jpg].product(['', '.xmp']).map(&:join).each do |ext|
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

def slug_index(slug)
  Dir["origs/#{slug}.*.jpg"].map { |pt| pt.split('.').fetch(-2).to_i }.max || 0
end

def slugs
  @slugs ||= Dir['_posts/????-??-??-*.md'].map { |path| path[18..-4] }.sort
end

def slugify(title)
  map = { '&' => 'and', 'ß' => 'ss', 'ø' => 'o', 'ł' => 'l' }
  title.unicode_normalize(:nfkd).downcase.gsub(/[#{map.keys.join}]/, map)
       .delete('^0-9a-z -').squeeze(' ').strip.tr(' ', '-')
end

def source_from_uri(uri)
  Pathname.new(CGI.unescape(URI.parse(uri).path))
end
