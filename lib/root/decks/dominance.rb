# frozen_string_literal: true

module Root
  module Decks
    # Logic to handle a shared dominance pile for the game
    class Dominance
      attr_reader :dominance

      def initialize
        @dominance = {
          bird: nil,
          fox: nil,
          mouse: nil,
          rabbit: nil
        }
      end

      def [](key)
        dominance[key]
      end

      def []=(key, val)
        dominance[key] = val
      end
    end
  end
end
