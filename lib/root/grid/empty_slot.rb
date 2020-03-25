# frozen_string_literal: true

require_relative '../pieces/building'

module Root
  module Grid
    # Node data structure for ruins
    class EmptySlot < Pieces::Building
      def display_color
        :ghostwhite
      end

      def display_symbol
        # 'O'
        "\u25AB"
      end
    end
  end
end
