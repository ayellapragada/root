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

      def draw_card
        faction.draw_card.first
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

      def inspect
        f = faction
        symbol = f.faction_symbol[0].upcase
        meeps = f.meeples.count.to_s.rjust(2, '0')
        builds = f.buildings.count.to_s.rjust(2, '0')
        toks = f.tokens.count.to_s.rjust(2, '0')
        "#{symbol}:H#{current_hand_size}:M#{meeps}:B#{builds}:T#{toks}"
      end

      def add_to_history(key, opts)
        return unless @game

        game.history << format_for_history(key, opts)
      end

      def format_for_history(key, opts)
        {
          player: inspect,
          color: faction.display_color,
          key: key,
          opts: opts
        }
      end
    end
  end
end
