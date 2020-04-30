# frozen_string_literal: true

module Root
  module Cards
    VALID_SUITS = %i[mouse rabbit fox bird].freeze
    # This is the base card format.
    # Lots of things are going to be optional, so that's fun.
    # We got item cards
    # We got actives
    # We got passives
    # I ain't consolidating that heck no
    class Base
      attr_accessor :suit, :name

      def initialize(suit:, name: 'Untitled')
        @suit = suit
        @name = name
      end

      def craft
        []
      end

      def craftable?
        !craft.empty?
      end

      def bird?
        suit == :bird
      end

      def vizier?
        false
      end

      def inspect
        name
      end

      def body
        '-'
      end
    end
  end
end
