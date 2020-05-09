# frozen_string_literal: true

require_relative './base'

module Root
  module Cards
    # Favor cards for hella nukes
    class Favor < Base
      attr_reader :craft

      def initialize(suit:, name: 'Favor')
        super(suit: suit, name: name)
        @craft = Array.new(3) { suit }
      end

      # :nocov:
      def inspect
        "#{name_with_suit} | Craft: #{craft.join(', ')}"
      end
      # :nocov:

      def body
        "Remove in #{suit}"
      end

      # def faction_craft(fac, players:)
      def faction_craft(fac)
        # board
        #   .clearings_of_suit(suit)
        #   .each { |cl| fac.do_big_damage(cl, players) }
        fac.player.add_to_history(:f_favor, suit: suit.capitalize)
        fac.discard_card(self)
      end

      def craftable?(*)
        true
      end
    end
  end
end
