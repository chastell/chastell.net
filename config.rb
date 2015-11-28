require 'slim'

activate :blog do |blog|
  blog.permalink = '{layout}/{title}.html'
  blog.sources   = '{layout}/{year}-{month}-{day}-{title}.html'
end

activate :directory_indexes
activate :livereload
