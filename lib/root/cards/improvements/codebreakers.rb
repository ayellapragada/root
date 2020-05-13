# frozen_string_literal: true

require_relative '../improvement'

module Root
  module Cards
    module Improvements
      class Codebreakers < Improvement
        def initialize
          super(
            suit: :mouse,
            name: 'Codebreakers',
            craft: %i[mouse]
          )
        end

        def type
          :codebreakers
        end

        # :nocov:
        def phase
          'Once during Daylight'
        end

        def body
          'May look at another players hand'
        end
        # :nocov:

        def faction_use(faction)
          opts = options(faction)
          faction.player.choose(:f_codebreakers, opts) do |other_fac|
            other_fac.show_hand(faction)
            true
          end
        end

        def options(faction)
          faction.other_factions.reject { |fac| fac.hand.empty? }
        end

        def usable?(fac)
          !options(fac).empty?
        end
      end
    end
  end
end
