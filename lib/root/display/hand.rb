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
        %i[name craft body].map do |field|
          hand.map do |card|
            case field
            when :name then handle_name(card)
            when :craft then handle_craft(card)
            when :body then handle_body(card)
            end
          end
        end
      end

      def handle_name(card)
        Rainbow(card.name).fg(Colors::SUIT_COLOR[card.suit])
      end

      def handle_craft(card)
        str =
          card
          .craft
          .map { |suit| Rainbow(suit.capitalize).fg(Colors::SUIT_COLOR[suit]) }
          .join(', ')
        str.empty? ? '-' : str
      end

      # Rainbow(card.body).fg(Colors::SUIT_COLOR[card.suit])
      # Is the alternative, but it might be too much annoying text.
      def handle_body(card)
        card.body
      end
    end
  end
end
