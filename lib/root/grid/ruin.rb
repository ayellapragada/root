# frozen_string_literal: true

require_relative '../pieces/building'
require_relative '../factions/vagabonds/vagabondable'

module Root
  module Grid
    # Node data structure for ruins
    class Ruin < Pieces::Building
      include Factions::Vagabonds::Vagabondable

      attr_accessor :items

      def initialize
        @items = []
      end

      def contains_item?
        items.any?
      end

      def attackable?
        false
      end
    end
  end
end
