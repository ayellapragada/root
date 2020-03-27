# frozen_string_literal: true

module Root
  # Handles logic for starting and handling a game
  class Game
    def self.default_game
      new(
        players: Players::List.default_player_list,
        board: Boards::Woodlands.new,
        decks: Decks::List.default_decks_list
      )
    end

    attr_accessor :players, :board, :decks

    def initialize(players:, board:, decks:)
      @players = players
      @board = board
      @decks = decks
    end

    def deck
      decks.shared
    end

    def quests
      decks.quests
    end

    def setup
      players.order_by_setup_priority.each do |player|
        3.times { player.draw_card(deck) }
        player.setup(
          board: board,
          decks: decks,
          players: players
        )
      end
    end

    def render
      players.each { |player| player.render_game(self) }
    end
  end
end
