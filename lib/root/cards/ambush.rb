# frozen_string_literal: true

require_relative './base'

module Root
  module Cards
    # Favor cards for hella nukes
    class Ambush < Base
      def initialize(suit:)
        super(suit: suit, name: 'Ambush')
      end

      def ambush?
        true
      end

      def faction_play(fac); end
    end
  end
end
