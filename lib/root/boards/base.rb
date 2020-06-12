# frozen_string_literal: true

module Root
  module Boards
    # This is all base board logic.
    # This is currently only for the woodland normie one,
    # But ideally to do another map it wouldn't be that bad.
    class Base
      attr_reader :all_clearings, :items

      # :nocov:
      def self.from_db(record)
        board = new(items: record['items'])
        board.ruins_clearings.each(&:clear_ruin)

        record.delete('items')

        record.each do |clearing, values|
          cl = board.clearings[clearing.to_sym]
          values.each do |piece|
            fin = Pieces::Base.for(piece, suit: cl.suit)
            fin.class == Symbol ? cl.items << fin : cl.send(fin.piece_type.pluralize) << fin
          end
        end

        board
      end
      # :nocov:

      DIAGANOLS = { 1 => :three, 2 => :four, 3 => :one, 4 => :two }.freeze

      def initialize(generator: WoodlandsGenerator, items: nil)
        @all_clearings = generator.generate
        @items = items || ItemsGenerator.generate
      end

      def available_corners
        corners.select(&:with_spaces?)
      end

      def corners
        [clearings[:one], clearings[:two], clearings[:three], clearings[:four]]
      end

      def clearings
        all_clearings.select { |key, _| all_clearings[key].clearing? }
      end

      def forests
        all_clearings.select { |key, _| all_clearings[key].forest? }
      end

      def clearings_of_suit(suit)
        clearings.values.select { |cl| cl.suit == suit }
      end

      def place_token(token, clearing)
        clearing.place_token(token)
      end

      def create_building(building, clearing)
        clearing.create_building(building)
      end

      def place_meeple(meeple, clearing)
        clearing.place_meeple(meeple)
      end

      def corner_with_keep
        corner_with(:keep)
      end

      def corner_with_roost
        corner_with(:roost)
      end

      def ruins_clearings
        clearings
          .select { |_, clearing| clearing.includes_building?(:ruin) }
          .values
      end

      def corner_with(type)
        corners.find do |corner|
          corner.tokens.any? { |tokens| tokens.type == type } ||
            corner.buildings.any? { |building| building.type == type }
        end
      end

      def keep_in_corner?
        !!corner_with_keep
      end

      def clearings_without_keep
        clearings.values.reject(&:keep?)
      end

      def clearing_across_from_keep
        clearing_across(corner_with_keep)
      end

      def clearing_across(clearing)
        clearings[DIAGANOLS[clearing.priority]]
      end

      def clearings_other_than(other_clearing)
        clearings.values.reject { |clearing| clearing == other_clearing }
      end

      def clearings_with(type)
        clearings.select do |_, clearing|
          clearing.includes_building?(type) || clearing.includes_token?(type)
        end.values
      end

      def clearings_with_meeples(type)
        all_clearings.values.select { |clearing| clearing.includes_meeple?(type) }
      end

      def clearings_with_rule(faction)
        clearings.values.select { |clearing| clearing.ruled_by?(faction) }
      end

      def clearings_with_fewest_pieces
        clearings.values.min_by(clearings.count) do |clearing|
          clearing.all_pieces.count
        end
      end
    end
  end
end
