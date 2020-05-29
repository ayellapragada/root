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
      def self.from_db(name, record, display: MockDisplay.new, updater: MockPlayerUpdater.new)
        fac = FACTION_MAPPING[record[:code]].from_db(record)
        new(
          name: name,
          faction: fac,
          display: display,
          updater: updater
        )
      end

      def self.for(name, faction, display: MockDisplay.new, updater: MockPlayerUpdater.new)
        fac = FACTION_MAPPING[faction].new
        player = new(
          name: name,
          faction: fac,
          display: display,
          updater: updater
        )

        fac.post_initialize
        player
      end

      attr_reader :name, :faction, :display, :updater
      attr_accessor :game
      attr_writer :board, :deck, :players

      def initialize(name:, faction:, display: MockDisplay.new, updater: MockPlayerUpdater.new)
        @name = name
        @faction = faction
        @display = display
        @updater = updater

        @faction.player = self
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

      # required: self explanatory, user can not cancel
      # yield_anyway: sometimes the app needs to know if user picked none
      # i.e., picking none cancels the turn
      # give_val: sometimes we just want them to pick something,
      # nothing happens with it yet
      # info: optional info to be placed into the prompt
      def choose(key, choices, required: false, yield_anyway: false, give_val: false, info: {})
        return false if choices.empty?

        extra_keys = required ? [] : [:none]
        total_options = choices + extra_keys
        choice = pick_option(key, total_options, info: info)
        selected = total_options[choice]

        unless yield_anyway
          return false if selected == :none
        end

        res = yield(selected) if block_given?
        give_val ? selected : res
      end
    end
  end
end
