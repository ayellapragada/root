# frozen_string_literal: true

require_relative '../improvement'

module Root
  module Cards
    module Improvements
      # This is a lil tricky bugger
      class RoyalClaim < Improvement
        def initialize
          super(suit: :bird, name: 'Royal Claim', craft: %i[any any any any])
        end

        def type
          :royal_claim
        end

        # :nocov:
        def phase
          'Birdsong'
        end

        def body
          'Discard to score 1VP per ruled clearing'
        end
        # :nocov:

        def faction_use(faction)
          vps =
            faction
            .board
            .clearings_with_rule(faction.faction_symbol).count
          faction.gain_vps(vps)
          faction.discard_improvement(self)
          faction.player.add_to_history(:f_royal_claim, vps: vps)
        end

        def usable?(*)
          true
        end

        def royal_claim?
          true
        end
      end
    end
  end
end
