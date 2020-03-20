# frozen_string_literal: true

require_relative '../grid/clearing'

module Holt
  module Boards
    # Creates graph / grid for the forest (default) board.
    # The actual clearing creation and population really only happens once,
    # so there's no reason to clog it up in the other class.
    class WoodlandsGenerator
      attr_accessor :clearings

      DEFAULT_CLEAIRNGS_MAP = [
        { name: :one, priority: 1, suit: :fox, slots: 1 },
        { name: :two, priority: 2, suit: :mouse, slots: 2 },
        { name: :three, priority: 3, suit: :rabbit, slots: 1 },
        { name: :four, priority: 4, suit: :rabbit, slots: 1 },
        { name: :five, priority: 5, suit: :rabbit, slots: 2 },
        { name: :six, priority: 6, suit: :fox, slots: 2, ruin: true },
        { name: :seven, priority: 7, suit: :mouse, slots: 2 },
        { name: :eight, priority: 8, suit: :fox, slots: 2 },
        { name: :nine, priority: 9, suit: :mouse, slots: 2 },
        { name: :ten, priority: 10, suit: :rabbit, slots: 2, ruin: true },
        { name: :eleven, priority: 11, suit: :mouse, slots: 3, ruin: true },
        { name: :twelve, priority: 12, suit: :fox, slots: 2, ruin: true }
      ].freeze

      CLEARING_ADJACENCY_LINKS = [
        one: %i[five nine ten],
        two: %i[five six ten],
        three: %i[six seven eleven],
        four: %i[eight nine twelve],
        five: %i[one two],
        six: %i[two three eleven],
        seven: %i[three eight twelve],
        eight: %i[four seven twelve],
        nine: %i[one four twelve],
        ten: %i[one two twelve],
        eleven: %i[three six twelve],
        twelve: %i[four seven eight nine ten eleven]
      ].freeze

      def self.generate
        new.clearings
      end

      def initialize
        @clearings = {}
        populate_clearings
      end

      # Okay so this is going to be gnarly but I can't think of any other way
      # to correct populate a set of clearings. It's just 12 nodes so whatever.
      def populate_clearings
        make_all_clearings
        create_paths_for_clearings
      end

      def make_all_clearings
        DEFAULT_CLEAIRNGS_MAP.each do |c|
          clearings[c[:name]] = Grid::Clearing.new(
            priority: c[:priority],
            suit: c[:suit],
            slots: c[:slots],
            ruin: c[:ruin]
          )
        end
      end

      # Hypothetically, we could "create" links to each node as they're created,
      # as in add adjacenties in the initialize step, but the other nodes don't
      # exist yet. We could lazy load a link but that raises complexity, and
      # this seems to work.
      def create_paths_for_clearings
        CLEARING_ADJACENCY_LINKS.each do |mapping|
          mapping.each do |clearing, adjacencies|
            adjacencies.each do |adj|
              clearings[clearing].add_path(clearings[adj])
            end
          end
        end
      end
    end
  end
end
