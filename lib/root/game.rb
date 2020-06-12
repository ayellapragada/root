# frozen_string_literal: true

module Root
  # Handles logic for starting and handling a game
  class Game
    def self.default_game(with_computers: false, with_humans: false)
      new(
        players: Players::List.default_player_list(with_computers, with_humans)
      )
    end

    attr_accessor :players, :board, :decks, :history, :dry_run, :actions,
                  :selected, :updater

    def initialize(
      players:,
      board: Boards::Base.new,
      decks: Decks::List.new(shared: Decks:: Starter.new),
      updater: MockGameUpdater.new
    )
      @players = players
      @board = board
      @decks = decks
      @players.each { |p| p.game = self }
      @history = []
      @updater = updater
      @updater.root_game = self
      @dry_run = false
      @actions = nil
      @selected = nil
    end

    def get_current_actions(phase, faction_sym)
      faction = players.fetch_player(faction_sym).faction
      @dry_run = true
      case phase
      when 'SETUP' then faction.get_setup_actions
      end
      @actions || ActionTree::Choice.new
    end

    def make_choice_with(phase, faction_sym, selected)
      @selected = selected
      faction = players.fetch_player(faction_sym).faction
      case phase
      when 'SETUP' then faction.get_setup_actions
      end
    end

    def factions
      players.map(&:faction)
    end

    def setup
      factions.each do |fac|
        fac.post_initialize
        fac.draw_card(3)
      end
      updater.full_game_update
    end
  end
end
