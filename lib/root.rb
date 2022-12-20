# frozen_string_literal: true

# Our big boi Root module.
module Root
end

Gem
  .find_files('root/**/*.rb')
  .reject { |file| file.include?('/spec/') }
  .each { |file| require file }
