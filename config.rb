require 'slim'
require 'socket'
require 'uri'

Slim::Engine.disable_option_validator!

activate :blog do |blog|
  blog.name      = '1/125'
  blog.permalink = '{title}.html'
  blog.prefix    = '1/125'
end

activate :directory_indexes

configure :development do
  activate :livereload
end

helpers do
  def root_uri
    host = case config.environment
           when :development
             ip = Socket.ip_address_list.find(&:ipv4_private?).ip_address
             "#{ip}:#{config.port}"
           else
             'chastell.net'
           end
    URI.parse("http://#{host}/")
  end
end

ignore '1/125/*.jpg'
ignore 'hovercraft/*'
ignore 'l+k/*'
ignore 'wycinki/*'

page '/1/125/*', layout: '1/125'
