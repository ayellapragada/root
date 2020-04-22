# frozen_string_literal: true

require_relative './ruin'
require_relative './empty_slot'

module Root
  module Grid
    # Node data structure for clearings
    class Clearing
      VALID_SUITS = %i[fox mice bunny forest].freeze

      attr_reader :priority, :suit, :slots, :ruin, :type,
                  :all_adjacents, :buildings, :tokens, :meeples

      def initialize(priority:, suit:, slots:, ruin: false, type: :clearing)
        @priority = priority
        @suit = suit
        @slots = slots
        @type = type
        create_spaces_for_pieces
        create_ruin if ruin
      end

      def create_spaces_for_pieces
        @all_adjacents = []
        @buildings = []
        @tokens = []
        @meeples = []
      end

      # Not testing because it's just a debug method, nbd.
      # :nocov:
      # This breaks sandi_meter :sweats:
      # rubocop:disable all
      def inspect
        adjacents_nodes = all_adjacents.map(&:priority).join(', ')
        building_types = buildings.map(&:type).join(', ')
        token_types = tokens.map(&:type).join(', ')
        meeple_types = meeples.map(&:faction).join(', ')

        result = [
          "Clearing ##{priority}: #{suit}",
          "All Adjacents: #{adjacents_nodes}",
          "Type: #{type}"
        ]

        result << "Buildings: #{building_types}" if buildings.any?
        result << "Tokens: #{token_types}" if tokens.any?
        result << "Meeples: #{meeple_types}" if meeples.any?

        result.join(' | ')
      end
      # rubocop:enable all
      # :nocov:

      def adjacents
        all_adjacents.select(&:clearing?)
      end

      def adjacent_forests
        all_adjacents.select(&:forest?)
      end

      def ruin?
        !!ruin
      end

      def with_spaces?
        available_slots >= 1
      end

      def available_slots
        slots - buildings.count
      end

      def add_path(other_clearing)
        return if all_adjacents.include?(other_clearing)

        all_adjacents << other_clearing
        other_clearing.add_path(self)
      end

      # This needs to check for available slots
      def create_building(building)
        return unless with_spaces?

        buildings << building
      end

      def place_token(token)
        tokens << token
      end

      def place_meeple(meeple)
        meeples << meeple
      end

      def all_pieces
        (meeples + buildings + tokens).select(&:attackable?)
      end

      def all_other_pieces(faction)
        all_pieces.reject { |piece| piece.faction == faction }
      end

      def includes_building?(type)
        buildings.any? { |building| building.type == type }
      end

      def buildings_of_type(type)
        buildings.select { |building| building.type == type }
      end

      def buildings_of_faction(faction)
        buildings.select { |building| building.faction == faction }
      end

      def includes_token?(type)
        tokens.any? { |token| token.type == type }
      end

      def tokens_of_faction(faction)
        tokens.select { |m| m.faction == faction }
      end

      def meeples_of_type(faction)
        meeples.select { |m| m.faction == faction }
      end

      def includes_meeple?(type)
        meeples.any? { |meeples| meeples.faction == type }
      end

      def buildings_with_empties
        buildings.dup.fill(EmptySlot.new, buildings.count, available_slots)
      end

      def includes_any_other_attackable_faction?(faction)
        !all_other_pieces(faction).empty?
      end

      def other_attackable_factions(faction)
        all_other_pieces(faction).map(&:faction).uniq
      end

      def forest?
        type == :forest
      end

      def clearing?
        type == :clearing
      end

      def wood?
        includes_token?(:wood)
      end

      def keep?
        includes_token?(:keep)
      end

      def sympathetic?
        includes_token?(:sympathy)
      end

      def wood
        tokens.select { |token| token.type == :wood }
      end

      def remove_wood
        piece = tokens.select { |token| token.type == :wood }.first
        tokens.delete_at(tokens.index(piece))
        piece
      end

      FACTIONS_WITHOUT_RULE = %i[racoon]

      def ruled_by
        groups = (meeples + buildings).group_by(&:faction)
        max = groups.values.map(&:count).max
        contenders =
          groups
          .select { |_fac, units| units.count == max }
          .keys
          .reject { |f| FACTIONS_WITHOUT_RULE.include?(f) }

        return :birds if contenders.include?(:birds)
        return nil if contenders.length > 1

        contenders.first
      end

      def ruled_by?(faction)
        ruled_by == faction
      end

      # Bruh what did I just do? It's 1 im going to bed
      def connected_wood(already_checked = [])
        connected = wood? ? [self] : []
        adjacents.each do |adj|
          next if already_checked.include?(adj)

          connected << adj if adj.wood? && ruled_by?(:cats)
          already_checked << adj
          connected << adj.connected_wood(already_checked) if adj.ruled_by?(:cats)
        end

        total_wood = []
        connected.flatten.uniq.each do |clearing|
          clearing.wood.count.times { total_wood << clearing }
        end
        total_wood
      end

      private

      def create_ruin
        @ruin = Ruin.new
        @buildings << @ruin
      end
    end
  end
end
