# frozen_string_literal: true

module Root
  module Errors
    # For winning the game from whatever way
    # VP / Dominance / Etc
    class WinConditionReached < StandardError
      attr_reader :winner, :type

      def initialize(winner, type)
        @winner = winner
        @type = type
      end
    end
  end
end
