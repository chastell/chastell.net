require 'fastimage'
require 'pathname'
require 'yaml'

desc 'Regenerate 1/125 dimension data'
task :dimensions do
  meta = Dir['1/125/photos/*.jpg'].sort.map(&Pathname.method(:new)).map do |path|
    width, height = FastImage.size(path)
    { path.basename.sub_ext('').to_s => { 'height' => height, 'width' => width } }
  end.reduce({}, :merge)
  File.write('_data/photos.yml', YAML.dump(meta))
end
