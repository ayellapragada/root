# frozen_string_literal: true

module Root
  module Decks
    # Logic to handle a shared dominance pile for the game
    class Dominance
      include Enumerable

      attr_reader :dominance

      def initialize(dominance: [])
        @dominance = {
          bird: { card: nil, status: '-' },
          fox: { card: nil, status: '-' },
          mouse: { card: nil, status: '-' },
          rabbit: { card: nil, status: '-' }
        }
      end

      def [](key)
        dominance[key]
      end

      def []=(key, val)
        dominance[key] = val
      end

      def each
        @dominance.each do |key, val|
          yield(key, val)
        end
      end
    end
  end
end
