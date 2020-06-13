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
      def self.from_db(name, record)
        fac = FACTION_MAPPING[record[:code]].from_db(record)
        new(name: name, faction: fac)
      end

      def self.for(name, faction)
        fac = FACTION_MAPPING[faction].new
        player = new(name: name, faction: fac)

        fac.post_initialize
        player
      end

      attr_reader :name, :faction
      attr_accessor :game
      attr_writer :board, :deck, :players

      def initialize(name:, faction:)
        @name = name
        @faction = faction

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

      def dry_run?
        @dry_run ||= game&.dry_run || false
      end

      def selected
        @selected ||= game&.selected || []
      end

      def updater
        @updater ||= game&.updater || MockGameUpdater.new
      end

      def update_game
        updater.full_game_update
        true
      end

      def actions
        game&.actions
      end

      def actions=(val)
        game&.actions = val
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

      def add_to_history(key, opts = {})
        return unless @game

        game.history << format_for_history(key, opts)
        true
      end

      def format_for_history(key, opts)
        {
          player: self,
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
      def choose(key, choices, required: false, yield_anyway: false, info: {}, &block)
        return false if choices.empty?

        extra_keys = required ? [] : [:none]
        total_options = choices + extra_keys

        if dry_run?
          get_all_choices(key, total_options, yield_anyway, info, &block)
          return
        end

        choice = pick_option(key, total_options, info: info)
        selected = total_options[choice]

        unless yield_anyway
          return false if selected == :none
        end

        if block_given?
          yield(selected)
        else
          selected
        end
      end

      def get_all_choices(key, choices, yield_anyway, info)
        actions.key = key
        actions.info = info
        actions.children = choices.map do |child|
          ActionTree::Choice.new(val: child, parent: actions)
        end

        choices.each do |selected|
          unless yield_anyway
            next if selected == :none
          end

          new_action = actions.find_child(selected)
          self.actions = new_action
          yield(selected) if block_given?

          until actions.children.map(&:val) == choices
            self.actions = actions.parent
          end
        end
      end
    end
  end
end
