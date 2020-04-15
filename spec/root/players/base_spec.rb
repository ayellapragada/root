RSpec.describe Root::Players::Base do
  describe '#board' do
    context 'when there is a game' do
      it 'uses the game from the board' do
        game = Root::Game.default_game
        player = game.players.fetch_player(:cats)

        expect(player.board).to eq(game.board)
      end
    end

    context 'when built alone' do
      it 'makes and persists its own board' do
        player = Root::Players::Computer.for('Ultron', :racoon)
        board = player.board

        expect(board).not_to be nil
        expect(player.board).to eq(board)
      end
    end
  end
end
