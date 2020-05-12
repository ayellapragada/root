# frozen_string_literal: true

require_relative './character'

module Root
  module Factions
    module Racoons
      module Characters
        # Thief Specific Logic
        class Thief < Character
          STARTING_ITEMS = %i[boots torch tea sword].freeze
          POWER = :steal

          def can_special?
            torch? && !special_options.empty?
          end

          def special_options
            f.other_factions_here.reject do |fac_sym|
              other_faction = f.players.fetch_player(fac_sym).faction
              other_faction.hand.empty?
            end
          end

          def special
            f.player.choose(:f_take_random_card, special_options) do |fac_sym|
              other_faction = f.players.fetch_player(fac_sym).faction
              f.take_card_from(other_faction)

              f.player.add_to_history(:f_take_random_card, faction: fac_sym)
            end
          end
        end
      end
    end
  end
end
