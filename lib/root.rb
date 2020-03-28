# frozen_string_literal: true

Dir.glob('lib/**/*.rb').drop(1).each do |file|
  require file.gsub('lib/', '').gsub('.rb', '')
end

# Our big boi Root module.
# Nothing really goes in here, I guess eventually a game.start will.
module Root
end
