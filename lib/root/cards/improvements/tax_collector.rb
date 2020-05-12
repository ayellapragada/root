# frozen_string_literal: true

require_relative '../improvement'

module Root
  module Cards
    module Improvements
      class TaxCollector < Improvement
        def initialize
          super(
            suit: :fox,
            name: 'Tax Collector',
            craft: %i[rabbit fox mouse]
          )
        end

        def type
          :tax_collector
        end

        # :nocov:
        def body
          'Daylight: May remove 1 of your warriors to draw 1'
        end
        # :nocov:

        def faction_use(faction)
          opts = options(faction)
          faction.player.choose(:f_tax_collector, opts) do |clearing|
            faction.remove_meeple(clearing)
            faction.draw_card
            faction.player.add_to_history(
              :f_tax_collector,
              clearing: clearing.priority
            )
            true
          end
        end

        def options(faction)
          faction.board.clearings_with_meeples(faction.faction_symbol)
        end

        def usable?(fac)
          !options(fac).empty?
        end
      end
    end
  end
end
