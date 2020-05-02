# frozen_string_literal: true

module Root
  module Pieces
    # Item class mostly for the vagabondo
    class Item
      attr_reader :item

      def initialize(item)
        @item = item
        @damaged = false
        @exhausted = false
      end

      def damage
        @damaged = true
      end

      def damaged?
        @damaged
      end

      def exhaust
        @exhausted = true
      end

      def refresh
        @exhausted = false
      end

      def exhausted?
        @exhausted
      end

      def of_type(type)
        item == type
      end
    end
  end
end
