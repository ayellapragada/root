# frozen_string_literal: true

RSpec.describe Holt::Game do
  describe '.initialize' do
    it 'takes players and board' do
      players = Holt::Players::List.default_player_list
      board = Holt::Boards::Woodlands.new
      game = Holt::Game.new(players: players, board: board)

      expect(game.players.current_player.name).to be('Sneaky')
      expect(game.board).to be_truthy
    end
  end
end
