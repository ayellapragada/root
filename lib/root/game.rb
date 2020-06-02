# frozen_string_literal: true

module Root
  # Handles logic for starting and handling a game
  class Game
    def self.default_game(with_computers: false, with_humans: false)
      new(
        players: Players::List.default_player_list(with_computers, with_humans)
      )
    end

    attr_accessor :players, :board, :decks, :history

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
    end

    def get_current_actions(phase, faction)
      Choices.new.() do
        case phase
        when 'SETUP' then faction.get_setup_actions
        end
      end
    end
  end
end
