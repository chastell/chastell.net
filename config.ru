require 'tributary'
require 'tributary/plugins/unbreak_my_art'

Encoding.default_external = 'UTF-8'

Tributary::App.configure do |config|
  config.set :author,   'Piotr Szotkowski'
  config.set :cache?,   true
  config.set :plugins,  [Tributary::Plugins::UnbreakMyArt.new]
  config.set :root,     '.'
  config.set :sitename, 'chastell.net'
end

run Tributary::App
