# frozen_string_literal: true

module Root
  module Cards
    VALID_SUITS = %i[mouse bunny fox bird].freeze
    # This is the base card format.
    # Lots of things are going to be optional, so that's fun.
    # We got item cards
    # We got actives
    # We got passives
    # I ain't consolidating that heck no
    class Base
      attr_accessor :suit

      def initialize(suit:)
        @suit = suit
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
    end
  end
end
