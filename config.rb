require 'slim'
Slim::Engine.disable_option_validator!

activate :blog do |blog|
  blog.name      = '1/125'
  blog.permalink = '{title}.html'
  blog.prefix    = '1/125'
end

activate :deploy do |deploy|
  deploy.branch       = 'master'
  deploy.build_before = true
  deploy.method       = :git
end

activate :directory_indexes

configure :development do
  activate :livereload
end

ignore 'hovercraft/*'
ignore 'l+k/*'
ignore 'wycinki/*'
