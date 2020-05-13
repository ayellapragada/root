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
        ::Terminal::Table.new(
          rows: rows
        )
      end

      def rows
        [
          hand.map { |card| handle_name(card) },
          hand.map { |card| handle_phase(card) },
          hand.map { |card| handle_body(card) }
        ]
      end

      def handle_name(card)
        craft_text =
          card
          .craft
          .map { |suit| Rainbow(suit.capitalize).fg(Colors::SUIT_COLOR[suit]) }
          .join(', ')
        format_craft_text = craft_text.empty? ? '' : " (#{craft_text})"
        title = Rainbow(card.name).fg(Colors::SUIT_COLOR[card.suit])

        "#{title}#{format_craft_text}"
      end

      def handle_phase(card)
        card.phase
      end

      def handle_body(card)
        card.body
      end
    end
  end
end
