# frozen_string_literal: true

require_relative '../improvement'

module Root
  module Cards
    module Improvements
      class StandAndDeliver < Improvement
        def initialize
          super(
            suit: :fox,
            name: 'Stand And Deliver!',
            craft: %i[mouse mouse mouse]
          )
        end

        def type
          :stand_and_deliver
        end

        # :nocov:
        def body
          'Birdsong: May take a card from player, they score 1 VPs'
        end
        # :nocov:

        def faction_use(faction)
          opts = options(faction)
          faction.player.choose(:f_take_random_card, opts) do |fac_sym|
            other_faction = faction.players.fetch_player(fac_sym).faction
            faction.take_card_from(other_faction)

            faction.player.add_to_history(
              :f_take_random_card,
              faction: fac_sym
            )
            true
          end
        end

        def options(faction)
          faction
            .other_factions
            .reject { |fac| fac.hand.empty? }
            .map(&:faction_symbol)
        end

        def usable?(fac)
          !options(fac).empty?
        end
      end
    end
  end
end
