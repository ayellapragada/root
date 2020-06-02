# frozen_string_literal: true

require_relative './base'

module Root
  module Cards
    # Favor cards for hella nukes
    class Dominance < Base
      def initialize(suit:)
        super(suit: suit, name: 'Dominance')
      end

      def body
        if suit == :bird
          'Rule 2 opposite corners'
        else
          "Rule 3 clearings of #{suit} suit"
        end
      end

      def dominance?
        true
      end

      # if we do change to dominance, then place to side ya feel me?
      # It's not discarded, but it is gone.
      # Maybe another something something in the deck list
      def faction_play(fac)
        fac.change_to_dominance(suit)
        fac.deck.change_dominance(suit, fac.faction_symbol)
        fac.discard_card(self)
      end
    end
  end
end
