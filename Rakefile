require 'pathname'
require 'middleman-gh-pages'

desc 'Create a new 1/125 post'
task '1/125', [:title] do |_, args|
  slug = args.title.downcase.delete('’').tr(' ', '-')
  path = Pathname.new("source/1/125/#{Date.today}-#{slug}.md")
  path.sub_ext('').mkdir
  path.write <<~end
    ---
    place: …
    shot:  …
    taken: …
    title: #{args.title}
    ---

    …
  end
  puts path
end
