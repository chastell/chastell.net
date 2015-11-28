require 'slim'
Slim::Engine.disable_option_validator!

activate :blog do |blog|
  blog.name      = '1/125'
  blog.permalink = '{title}.html'
  blog.prefix    = '1/125'
end

activate :directory_indexes
activate :livereload
