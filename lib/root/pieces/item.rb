# frozen_string_literal: true

module Root
  module Pieces
    # Item class mostly for the vagabondo
    class Item < Base
      attr_reader :item

      def initialize(item)
        @item = item
        @damaged = false
        @exhausted = false
      end

      def damage
        @damaged = true
        self
      end

      def damaged?
        @damaged
      end

      def exhaust
        @exhausted = true
        self
      end

      def refresh
        @exhausted = false
        self
      end

      def exhausted?
        @exhausted
      end

      def of_type(type)
        item == type
      end

      def points_for_removing?
        false
      end

      def format_with_status
        statuses = []
        statuses << 'E' if exhausted?
        statuses << 'D' if damaged?
        status = statuses.empty? ? '' : " (#{statuses.join})"
        "#{item.capitalize}#{status}"
      end

      # :nocov:
      def inspect
        format_with_status
      end
      # :nocov:
    end
  end
end
