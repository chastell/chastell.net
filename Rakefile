require 'fastimage'
require 'pathname'
require 'yaml'

desc 'Regenerate 1/125 dimension data'
task :dimensions do
  paths = Dir["#{__dir__}/1/125/photos/*.jpg"].sort.map(&Pathname.method(:new))
  meta = paths.map do |path|
    slug = path.basename.sub_ext('').to_s
    width, height = FastImage.size(path)
    { slug => { 'height' => height, 'width' => width } }
  end.reduce({}, :merge)
  File.write("#{__dir__}/_data/photos.yml", YAML.dump(meta))
end
