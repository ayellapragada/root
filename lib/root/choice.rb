# frozen_string_literal: true

module Root
  # Holds choice with it's following options
  class Choice
    def initialize(key, options)
      @key = key
      @options = options
    end
  end
end
