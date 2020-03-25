# frozen_string_literal: true

module Root
  module Factions
    module Cats
      # Main starting token for the cat.
      # Allows for things like Field Hospital and etc.
      class Wood < Pieces::Token
        include Catable
      end
    end
  end
end
