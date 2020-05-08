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

          def can_special?(players)
            torch? && !special_options(players).empty?
          end

          def special_options(players)
            f.other_factions_here.reject do |fac_sym|
              other_faction = players.fetch_player(fac_sym).faction
              other_faction.hand.empty?
            end
          end

          def special(players)
            f.player.choose(:r_c_steal, special_options(players)) do |fac_sym|
              other_faction = players.fetch_player(fac_sym).faction
              card = other_faction.hand.sample
              f.hand << card
              other_faction.hand.delete(card)

              f.player.add_to_history(:r_c_steal, faction: fac_sym)
            end
          end
        end
      end
    end
  end
end
