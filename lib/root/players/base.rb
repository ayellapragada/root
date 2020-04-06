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
      attr_accessor :game
      attr_writer :board, :deck

      def initialize(name:, faction:)
        @name = name
        @faction = faction.new(self)
        @display = Display::Terminal.new
      end

      def board
        @board ||= game&.board || Boards::Base.new
      end

      def deck
        @deck ||= game&.deck || Decks::Starter.new
      end

      def current_hand_size
        faction.hand_size
      end

      def draw_card(deck)
        faction.draw_card(deck).first
      end

      def victory_points
        faction.victory_points
      end

      def faction_symbol
        faction.faction_symbol
      end

      def setup(players: nil, decks: nil)
        faction.setup(
          players: players,
          characters: decks&.characters
        )
      end

      def take_turn(players: nil, active_quests: nil)
        faction.take_turn(
          players: players,
          active_quests: active_quests
        )
      end

      # This breaks sandi_meter :sweats:
      # rubocop:disable all
      def inspect
        f = faction
        "#{f.faction_symbol.upcase}::H#{current_hand_size}::M#{f.meeples.count}::B#{f.buildings.count}::T#{f.tokens.count}"
      end
      # rubocop:enable all
    end
  end
end
