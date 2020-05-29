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
      attr_accessor :suit, :name, :id, :revealed

      def initialize(suit:, name: 'Untitled', id: nil)
        @suit = suit
        @name = name
        @id = id
        @revealed = false
      end

      def craft
        []
      end

      def craftable?(*)
        false
      end

      def bird?
        suit == :bird
      end

      def ambush?
        false
      end

      def dominance?
        false
      end

      def improvement?
        false
      end

      def vizier?
        false
      end

      def royal_claim?
        false
      end

      def name_with_suit
        "#{name} (#{suit[0].upcase})"
      end

      # :nocov:
      def inspect
        name_with_suit
      end

      def phase
        ' '
      end

      def body
        ' '
      end
      # :nocov:
    end
  end
end
