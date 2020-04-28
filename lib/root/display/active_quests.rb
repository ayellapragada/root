# frozen_string_literal: true

require 'rainbow'

module Root
  module Display
    # Handle logic for showing the victory points
    # Either stack, or all one square?
    # Some way to handle it so it's not shifting constantly.
    class ActiveQuests
      attr_reader :quests

      def initialize(quests)
        @quests = quests
      end

      def display
        ::Terminal::Table.new(
          title: 'Active Quests',
          rows: rows
        )
      end

      def rows
        quests.map do |quest|
          item_info = quest.items.map(&:capitalize).join(', ')
          [Rainbow(item_info).fg(Colors::SUIT_COLOR[quest.suit])]
        end
      end
    end
  end
end
