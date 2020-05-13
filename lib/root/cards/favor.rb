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
        pieces_removed = []

        fac
          .board
          .clearings_of_suit(suit)
          .each { |cl| pieces_removed << fac.do_big_damage(cl) }
        fac.post_removal(pieces_removed.flatten)
        fac.player.add_to_history(:f_favor, suit: suit.capitalize)
        fac.discard_card(self)
      end

      def craftable?(*)
        true
      end
    end
  end
end
