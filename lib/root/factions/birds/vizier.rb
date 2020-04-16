# frozen_string_literal: true

require_relative '../../cards/base'

module Root
  module Factions
    module Birds
      # This is for the birdables
      class Vizier < Cards::Base
        include Birdable

        def initialize
          super(suit: :bird)
        end

        def vizier?
          true
        end
      end
    end
  end
end
