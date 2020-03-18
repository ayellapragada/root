# frozen_string_literal: true

module ForestCreatures
  # Handles logic for starting and handling a game
  class Game
    attr_reader :player1, :player2, :board

    def initialize(player1:, player2:, board: Board.default)
      @player1 = player1
      @player2 = player2
      @board = board
    end
  end
end
