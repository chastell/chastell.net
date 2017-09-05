ENV['TZ'] = 'UTC'

require 'date'
require 'exifr/jpeg'
require 'net/http'
require 'pathname'
require 'socket'
require 'uri'
require 'yaml'

desc 'Create a new 1/125 post'
task '1/125', [:source] do |_task, args|
  source = source_from_uri(args.fetch(:source))
  newest = Date.parse(Dir['source/1/125/*.md'].max[/\d{4}-\d{2}-\d{2}/])
  date   = ask('date', default: [Date.today, newest + 1].max.to_s)
  title  = ask('title')
  slug   = ask('slug', default: slugify(title))
  place  = ask('place')
  path   = Pathname.new("source/1/125/#{date}-#{slug}.html.md")
  shot   = EXIFR::JPEG.new(source.to_s).date_time_original
  copy_assets slug: slug, source: source
  create_post path: path, place: place, shot: shot, title: title
  system 'gvim', path.to_s
  mkdir_p "source/1/125/#{slug}"
  sh 'rake serve'
end

desc 'Recreate a 1/125 photo'
task '1/125:redo', [:source, :slug] do |_task, args|
  source = source_from_uri(args.fetch(:source))
  copy_assets slug: args.fetch(:slug), source: source
  Rake::Task[:assets].invoke
end

desc 'Build and publish to GitHub'
task publish: :assets do
  sh 'middleman build'
  sh 'git add -- docs'
  abort 'nothing to publish' if `git status --porcelain -- docs`.empty?
  sh 'git commit --message "rebuild"'
  sh 'git push'
  Rake::Task[:tweet_newest].invoke
end

desc 'Serve the site, rebuilding if necessary'
task serve: :assets do
  uri = URI.parse('http://localhost:4567/1/125/')
  fork do
    sleep 0.1 until reachable?(uri)
    sh "xdg-open #{uri}"
  end
  sh 'middleman'
end

task :tweet_newest do
  path  = Pathname.glob("#{__dir__}/source/1/125/*.md").sort.last
  slug  = path.basename.to_s.split('-', 4).last.split('.').first
  photo = "#{__dir__}/source/1/125/#{slug}/photo.jpg"
  front = path.read.split("---\n").reject(&:empty?).first
  title = YAML.load(front).fetch('title').gsub(%r{</?[a-z]+>}i, '')
  uri   = URI.parse("https://chastell.net/1/125/#{slug}/")
  puts "waiting for #{uri}…"
  sleep 1 until Net::HTTP.get_response(uri).is_a?(Net::HTTPOK)
  sh "t update -f #{photo} '1/125: #{title} #{uri} #chastellnet'"
  sh 'xdg-open https://twitter.com/chastell'
end

convert_opts = %w(
  -colorspace sRGB
  -define filter:support=2
  -define jpeg:fancy-upsampling=off
  -define png:compression-filter=5
  -define png:compression-level=9
  -define png:compression-strategy=1
  -define png:exclude-chunk=all
  -dither none
  -filter triangle
  -interlace plane
  -posterize 136
  -quality 82
  -strip
  -unsharp 0.25x0.25+8+0.065
)

formats = {
  'photo.jpg'  => %w(-thumbnail 2000000@),
  'sample.png' => %w(-thumbnail 125000@ -colors 6),
}

multitask assets: FileList['source/1/125/*/'].product(formats.keys).map(&:join)

formats.each do |name, extra_opts|
  rule name => 'photos/%-1d.jpg' do |task|
    sh 'convert', task.source, *convert_opts, *extra_opts, task.name
  end
end

private

def ask(variable, default: '')
  question = variable
  question += " (#{default})" unless default.empty?
  print "#{question}? "
  response = $stdin.gets.chomp
  response.empty? ? default : response
end

def copy_assets(source:, slug:)
  %w(.jpg .RAF .RAF.xmp).each do |ext|
    cp source.sub_ext(ext), "photos/#{slug}#{ext.downcase}"
  end
end

def create_post(path:, place:, shot:, title:)
  path.write <<~end
    ---
    place: #{place}
    shot:  #{shot}
    title: #{title}
    ---

    …
  end
end

def reachable?(uri)
  TCPSocket.open(uri.host, uri.port).close
  true
rescue Errno::ECONNREFUSED
  false
end

def slugify(title)
  title.unicode_normalize(:nfkd).gsub('&', 'and').downcase.delete('^0-9a-z ')
    .squeeze(' ').strip.tr(' ', '-')
end

def source_from_uri(uri)
  Pathname.new(URI.parse(uri).path)
end
