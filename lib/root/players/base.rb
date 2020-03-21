# frozen_string_literal: true

require_relative '../factions/bird'
require_relative '../factions/cat'
require_relative '../factions/mouse'
require_relative '../factions/vagabond'

FACTION_MAPPING = {
  birds: Root::Factions::Bird,
  cats: Root::Factions::Cat,
  mice: Root::Factions::Mouse,
  vagabond: Root::Factions::Vagabond
}.freeze

module Root
  module Players
    # Safe spot for all centralized player logic
    # This should only be responsible for getting / displaying output.
    class Base
      def self.for(name, faction)
        new(name: name, faction: FACTION_MAPPING[faction])
      end

      attr_reader :name, :faction, :display

      def initialize(name:, faction:)
        @name = name
        @faction = faction.new(self)
        @display = Display::Terminal.new
      end

      def current_hand_size
        faction.hand_size
      end

      def draw_card(deck)
        faction.draw_card(deck)
      end

      def victory_points
        faction.victory_points
      end

      def faction_symbol
        faction.faction_symbol
      end

      def setup(board)
        faction.setup(board: board)
      end
    end
  end
end
