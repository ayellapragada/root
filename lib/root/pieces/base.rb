# frozen_string_literal: true

module Root
  module Pieces
    # Handles base logic for the square pieces.
    class Base
      def self.descendants
        ObjectSpace.each_object(Class).select { |klass| klass < self }
      end

      def self.type
        name.split('::').last.downcase.to_sym
      end

      WARRIORS = %i[cats birds mice racoon].freeze
      NEEDS_SUIT = %i[base].freeze
      ITEMS = %i[satchel boots hammer sword].freeze

      def self.for(type, suit: nil)
        type = type.to_sym
        suit = suit.to_sym if suit
        if WARRIORS.include?(type)
          Pieces::Meeple.new(type)
        elsif NEEDS_SUIT.include?(type)
          piece_list[type].new(suit: suit)
        elsif ITEMS.include?(type)
          type
        else
          piece_list[type].new
        end
      end

      def self.piece_list
        descendants.map { |kl| [kl.type, kl] }.to_h
      end

      def type
        self.class.type
      end

      def attackable?
        true
      end

      def meeple_of_type?(_type)
        false
      end

      def updater_type
        type
      end
    end
  end
end
