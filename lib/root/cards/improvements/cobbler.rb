# frozen_string_literal: true

require_relative '../improvement'

module Root
  module Cards
    module Improvements
      class Cobbler < Improvement
        def initialize
          super(
            suit: :rabbit,
            name: 'Cobbler',
            craft: %i[rabbit rabbit]
          )
        end

        def type
          :cobbler
        end

        # :nocov:
        def phase
          'Start of Evening'
        end

        def body
          'May take a move'
        end
        # :nocov:

        def faction_use(faction)
          faction.make_move
        end
      end
    end
  end
end
