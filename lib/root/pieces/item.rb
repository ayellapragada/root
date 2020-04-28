# frozen_string_literal: true

module Root
  module Pieces
    # Item class mostly for the vagabondo
    class Item
      attr_reader :item

      def initialize(item)
        @item = item
      end
    end
  end
end
