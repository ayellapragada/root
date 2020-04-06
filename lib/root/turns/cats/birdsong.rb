# frozen_string_literal: true

module Root
  module Turns
    module Cats
      # Handle birdsong
      class Birdsong < Base
        def call
          board.clearings_with(:sawmill).each do |sawmill_clearing|
            sawmill_clearing.buildings_of_type(:sawmill).count.times do
              place_wood(sawmill_clearing)
            end
          end
        end
      end
    end
  end
end
