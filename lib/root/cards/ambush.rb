# frozen_string_literal: true

require_relative './base'

module Root
  module Cards
    # Favor cards for hella nukes
    class Ambush < Base
      def initialize(suit:)
        super(suit: suit, name: 'Ambush')
      end

      # :nocov:
      def inspect
        "#{name_with_suit} | #{body}"
      end

      def phase
        'Battle'
      end

      def body
        'Deal 2 hits on Defense'
      end
      # :nocov:

      def ambush?
        true
      end

      def faction_play(fac)
        # fac.change_to_dominance(suit)
        # fac.deck.change_dominance(suit, fac.faction_symbol)
      end
    end
  end
end
