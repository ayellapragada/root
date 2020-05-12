# frozen_string_literal: true

require_relative '../improvement'

module Root
  module Cards
    module Improvements
      # This is a lil tricky bugger
      class RoyalClaim < Improvement
        def initialize
          super(suit: :bird, name: 'Royal Claim', craft: %i[? ? ? ?])
        end

        def type
          :royal_claim
        end

        # :nocov:
        def body
          'Birdsong: Discard to score 1VP per ruled clearing'
        end
        # :nocov:

        def faction_use(faction)
          vps =
            faction
            .board
            .clearings_with_rule(faction.faction_symbol).count
          faction.gain_vps(vps)
          faction.discard_improvement(self)
        end

        def usable?(*)
          true
        end
      end
    end
  end
end
