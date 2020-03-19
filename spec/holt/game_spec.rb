# frozen_string_literal: true

RSpec.describe Holt::Game do
  describe '#initialize' do
    it 'takes players and board' do
      players = Holt::Players::List.new(
        Holt::Players::Human.for('Akshith', :mice),
        Holt::Players::Computer.for('Hal', :cats),
        Holt::Players::Computer.for('Tron', :birds)
      )
      board = Holt::Boards::Forest.new
      game = Holt::Game.new(players: players, board: board)

      expect(game.players).to be_truthy
      expect(game.board).to be_truthy
    end
  end
end
