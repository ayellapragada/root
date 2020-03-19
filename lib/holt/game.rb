# frozen_string_literal: true

module Holt
  # Handles logic for starting and handling a game
  class Game
    attr_accessor :players, :board

    def initialize(players:, board:)
      @players = players
      @board = board
    end
  end
end
