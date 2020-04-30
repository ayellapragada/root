# frozen_string_literal: true

require 'rainbow'

module Root
  module Display
    # Handle logic for showing the victory points
    # Either stack, or all one square?
    # Some way to handle it so it's not shifting constantly.
    class Hand
      attr_reader :hand

      def initialize(hand)
        @hand = hand
      end

      def display
        hand.map do |card|
          Rainbow(card.inspect).fg(Colors::SUIT_COLOR[card.suit])
        end
      end
    end
  end
end
