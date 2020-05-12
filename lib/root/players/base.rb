# frozen_string_literal: true

require_relative '../factions/bird'
require_relative '../factions/cat'
require_relative '../factions/mouse'
require_relative '../factions/racoon'

FACTION_MAPPING = {
  birds: Root::Factions::Bird,
  cats: Root::Factions::Cat,
  mice: Root::Factions::Mouse,
  racoon: Root::Factions::Racoon
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
      attr_writer :board, :deck, :players

      def initialize(name:, faction:)
        @name = name
        @faction = faction.new(self)
        @display = Display::Terminal.new
      end

      def board
        @board ||= game&.board || Boards::Base.new
      end

      def decks
        @decks ||= game&.decks || Decks::List.new
      end

      def deck
        @deck ||= decks.shared
      end

      def players
        @players ||= game&.players || Players::List.new(self)
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

      def setup
        faction.setup
      end

      def take_turn
        faction.take_turn
      end

      def inspect
        f = faction
        symbol = f.faction_symbol[0].upcase
        meeps = f.meeples.count.to_s.rjust(2, '0')
        builds = f.buildings.count.to_s.rjust(2, '0')
        toks = f.tokens.count.to_s.rjust(2, '0')
        "#{symbol}:H#{current_hand_size}:M#{meeps}:B#{builds}:T#{toks}"
      end

      def add_to_history(key, opts = {})
        return unless @game

        game.history << format_for_history(key, opts)
        true
      end

      def format_for_history(key, opts)
        {
          player: inspect,
          color: faction.display_color,
          key: key,
          opts: opts
        }
      end

      def choose(key, choices, required: false, yield_anyway: false, info: {})
        return if choices.empty?

        extra_keys = required ? [] : [:none]
        total_options = choices + extra_keys
        choice = pick_option(key, total_options, info: info)
        selected = total_options[choice]

        unless yield_anyway
          return false if selected == :none
        end

        yield(selected)
      end
    end
  end
end
