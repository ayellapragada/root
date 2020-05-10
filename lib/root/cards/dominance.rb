# frozen_string_literal: true

require_relative './base'

module Root
  module Cards
    # Favor cards for hella nukes
    class Dominance < Base
      def initialize(suit:)
        super(suit: suit, name: 'Dominance')
      end

      # :nocov:
      def inspect
        "#{name_with_suit} | Craft: #{craft.join(', ')}"
      end
      # :nocov:

      def body
        if suit == :bird
          'Rule 2 opposite corners'
        else
          "Rule 3 clearings of #{suit} suit"
        end
      end

      def faction_craft(fac); end
    end
  end
end
