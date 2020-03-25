# frozen_string_literal: true

require_relative '../pieces/building'

module Root
  module Grid
    # Node data structure for ruins
    class Ruin < Pieces::Building
      def display_color
        :webgray
      end
    end
  end
end
