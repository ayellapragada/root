# frozen_string_literal: true

require_relative '../factions/racoons/racoonable'

module Root
  module Pieces
    # Item class mostly for the vagabondo
    class Item < Base
      include Factions::Racoons::Racoonable

      attr_reader :item

      def initialize(item)
        @item = item
        @damaged = false
        @exhausted = false
      end

      def piece_type
        :item
      end

      def damage
        @damaged = true
        self
      end

      def repair
        @damaged = false
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
    end
  end
end
