# frozen_string_literal: true

require 'rainbow'

module Root
  module Display
    # Handle logic for showing the victory points
    # Either stack, or all one square?
    # Some way to handle it so it's not shifting constantly.
    class ItemsInfo
      def initialize(items)
        @items = items
      end

      def display
        ::Terminal::Table.new(
          title: 'Craftable Items',
          rows: rows
        )
      end

      def rows
        [
          show_for_two_items(:satchel),
          show_for_two_items(:boots),
          [show_for_one_item(:crossbow), show_for_one_item(:hammer)],
          show_for_two_items(:sword),
          show_for_two_items(:tea),
          show_for_two_items(:coin)
        ]
      end

      def show_for_two_items(item)
        num = items.count { |in_list| item == in_list }
        case num
        when 0 then [Rainbow(item).fg(:dimgray), Rainbow(item).fg(:dimgray)]
        when 1 then [Rainbow(item).fg(:dimgray), Rainbow(item).fg(:floralwhite)]
        else [Rainbow(item).fg(:floralwhite), Rainbow(item).fg(:floralwhite)]
        end
      end

      def show_for_one_item(item)
        color = items.include?(item) ? :floralwhite : :dimgray
        Rainbow(item).fg(color)
      end

      attr_reader :items
    end
  end
end
