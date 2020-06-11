# frozen_string_literal: true

module Root
  # Handles logic for starting and handling a game
  class Game
    def self.default_game(with_computers: false, with_humans: false)
      new(
        players: Players::List.default_player_list(with_computers, with_humans)
      )
    end

    attr_accessor :players, :board, :decks, :history, :dry_run, :actions

    def initialize(
      players:,
      board: Boards::Base.new,
      decks: Decks::List.new(shared: Decks:: Starter.new)
    )
      @players = players
      @board = board
      @decks = decks
      @players.each { |p| p.game = self }
      @history = []
      @dry_run = false
      @actions = nil
    end

    def get_current_actions(phase, faction_sym)
      faction = players.fetch_player(faction_sym).faction
      @dry_run = true
      case phase
      when 'SETUP' then faction.get_setup_actions
      end
      @actions || ActionTree::Choice.new
    end
  end
end
