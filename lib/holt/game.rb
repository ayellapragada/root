# frozen_string_literal: true

module Holt
  # Handles logic for starting and handling a game
  class Game
    def self.default_game
      new(
        players: Players::List.default_player_list,
        board: Boards::Woodlands.new,
        deck: Decks::Starter.new
      )
    end

    attr_accessor :players, :board, :deck

    def initialize(players:, board:, deck:)
      @players = players
      @board = board
      @deck = deck
    end

    def setup
      players.each do |player|
        3.times { player.draw_card(deck) }
      end
    end
  end
end
