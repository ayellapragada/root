# frozen_string_literal: true

# Our big boi Root module.
# Nothing really goes in here, I guess eventually a game.start will.
module Root
end

Gem
  .find_files('root/**/*.rb')
  .reject { |file| file.include?('/spec/') }
  .each { |file| require file }
