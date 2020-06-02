# frozen_string_literal: true

RSpec.describe Root::Game do
  describe '#initialize' do
    it 'takes players, board, and deck' do
      players = Root::Players::List.default_player_list
      board = Root::Boards::Base.new
      deck = Root::Decks::List.new

      game = Root::Game.new(
        players: players,
        board: board,
        decks: deck
      )

      expect(game.players.current_player.name).to be('Sneaky')
      expect(game.board).to be_truthy
      expect(game.decks.shared.count).to be(Root::Decks::Starter::DECK_SIZE)
    end
  end

  xdescribe '#get_current_actions' do
    it 'do things' do
      game = Root::Game.default_game(with_computers: true)
      fac = game.players.fetch_player(:cats).faction

      game.get_current_actions('SETUP', fac)
    end
  end
end
