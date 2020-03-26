# frozen_string_literal: true

require_relative '../../pieces/token'

module Root
  module Factions
    module Mice
      # Main starting token for the cat.
      # Allows for things like Field Hospital and etc.
      class Sympathy < Pieces::Token
        include Miceable
      end
    end
  end
end
