# frozen_string_literal: true

require_relative './character'

module Root
  module Factions
    module Racoons
      module Characters
        # Tinker specific logic
        class Tinker < Character
          STARTING_ITEMS = %i[boots torch hammer satchel].freeze
          POWER = :day_labor

          def can_special?(*)
            torch? && !special_options.empty?
          end

          def special_options(*)
            f.deck.discard.select do |card|
              [f.current_location.suit, :bird].include?(card.suit)
            end
          end

          def special(*)
            f.player.choose(:r_c_day_labor, special_options) do |card|
              f.hand << f.deck.remove_from_discard(card)

              f.player.add_to_history(:r_c_day_labor)
            end
          end
        end
      end
    end
  end
end
