# frozen_string_literal: true

require_relative './base'

module Root
  module Cards
    # Handle Crafting an Improvement
    class Improvement < Base
      attr_reader :craft, :exhausted

      def initialize(suit:, name: 'Improvement', craft:)
        super(suit: suit, name: name)
        @craft = craft
        @exhausted = false
      end

      def type
        :base
      end

      def improvement?
        true
      end

      def exhaust
        @exhausted = true
      end

      def refresh
        @exhausted = false
      end

      def faction_craft(fac)
        fac.discard_card(self)
        fac.improvements << self
        fac.player.add_to_history(:f_improvement, type: type)
      end

      def craftable?(*)
        true
      end
    end
  end
end
