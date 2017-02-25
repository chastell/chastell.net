ENV['TZ'] = 'UTC'

require 'date'
require 'exifr'
require 'pathname'

task default: :build

desc 'Create a new 1/125 post'
task '1/125', [:source] do |_task, args|
  source = Pathname.new(URI.parse(args.fetch(:source)).path)
  newest = Date.parse(Dir['source/1/125/*.md'].sort.last[/\d{4}-\d{2}-\d{2}/])
  date   = ask('date', default: [Date.today, newest + 1].max.to_s)
  title  = ask('title')
  slug   = ask('slug', default: slugify(title))
  place  = ask('place')
  path   = Pathname.new("source/1/125/#{date}-#{slug}.html.md")
  shot   = EXIFR::JPEG.new(source.to_s).date_time_original
  cp source, "photos/#{slug}.jpg"
  create_post path: path, place: place, shot: shot, title: title
  system 'gvim', path.to_s
end

desc 'Build and publish to GitHub'
task publish: :build do
  sh 'git add -- docs'
  if `git status --porcelain -- docs`.empty?
    puts 'nothing to publish'
  else
    sh 'git commit --message "rebuild"'
    sh 'git push'
  end
end

task :build do
  sh 'rake docs'
  sh 'rake assets'
end

file 'docs' => FileList['source/**/*'] do
  sh 'middleman build --build-dir=docs --no-clean'
  touch 'docs'
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
  -interlace none
  -posterize 136
  -quality 82
  -strip
  -unsharp 0.25x0.25+8+0.065
)

formats = {
  '500.jpg'    => %w(-thumbnail 500),
  '1000.jpg'   => %w(-thumbnail 1000),
  '2000.jpg'   => %w(-thumbnail 2000),
  'photo.jpg'  => %w(-thumbnail 1000000@),
  'sample.png' => %w(-thumbnail 125000@ -colors 6),
}

multitask assets: FileList['docs/1/125/*/'].product(formats.keys).map(&:join)

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

def slugify(title)
  title.downcase.delete('!%(),.:?|’…').gsub('&', 'and').tr(' ', '-')
    .squeeze('-')
end
