# frozen_string_literal: true

require_relative '../improvement'

module Root
  module Cards
    module Improvements
      class BetterBurrowBank < Improvement
        def initialize
          super(
            suit: :rabbit,
            name: 'Better Burrow Bank',
            craft: %i[rabbit rabbit]
          )
        end

        def type
          :better_burrow_bank
        end

        # :nocov:
        def body
          'Start of Birdsong: you and another player draw a card'
        end
        # :nocov:

        def faction_use(faction)
          opts = faction.other_factions
          faction.player.choose(:f_better_burrow_bank, opts) do |other|
            faction.draw_card
            other.draw_card
          end
        end
      end
    end
  end
end
