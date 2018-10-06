ENV['TZ'] = 'UTC'

require 'fastimage'
require 'pathname'
require 'yaml'

desc 'Build and publish to GitHub'
task publish: :assets do
  sh 'jekyll build --destination docs --strict_front_matter'
  sh 'git add -- docs'
  abort 'nothing to publish' if `git status --porcelain -- docs`.empty?
  sh 'git commit --message "rebuild"'
  sh 'git push'
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

private

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
