# frozen_string_literal: true

require_relative './base'

module Root
  module Cards
    # Favor cards for hella nukes
    class Favor < Base
      attr_reader :craft

      def initialize(suit:)
        name = "Favor of the #{suit.pluralize.capitalize}"
        super(suit: suit, name: name)
        @craft = Array.new(3) { suit }
      end

      # :nocov:
      def inspect
        "#{name_with_suit} | Craft: #{craft.join(', ')}"
      end
      # :nocov:

      def body
        "Remove in #{suit} clearing"
      end

      def faction_craft(fac)
        fac.discard_card(self)
        fac.player.add_to_history(:f_favor, suit: suit.capitalize)
        fac
          .board
          .clearings_of_suit(suit)
          .each do |cl|
          pieces_removed = fac.do_big_damage(cl)
          pieces_removed.group_by(&:faction).each do |key, val|
            other_fac = fac.players.fetch_player(key).faction
            Actions::Battle.new(cl, fac, other_fac).use_for_post_battle(val)
          end
        end
      end

      def craftable?(*)
        true
      end
    end
  end
end
