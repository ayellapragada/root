# frozen_string_literal: true

require_relative '../grid/clearing'

module Holt
  module Boards
    # Handles Creates graph / grid for the forest (default) board.
    # Not going to lie this might be the only one I end up creating.
    # I haven't played the expansions much so I'm not familiar with them.
    class Woodlands
      attr_accessor :clearings

      def initialize
        @clearings = WoodlandsGenerator.generate
      end
    end
  end
end
