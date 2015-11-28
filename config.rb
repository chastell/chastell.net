require 'slim'

activate :blog do |blog|
  blog.permalink = ':title.html'
end

activate :directory_indexes
activate :livereload
