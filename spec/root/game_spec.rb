# frozen_string_literal: true

RSpec.describe Root::Game do
  describe '.initialize' do
    it 'takes players, board, and deck' do
      players = Root::Players::List.default_player_list
      board = Root::Boards::Woodlands.new
      deck = Root::Decks::Starter.new

      game = Root::Game.new(players: players, board: board, deck: deck)

      expect(game.players.current_player.name).to be('Sneaky')
      expect(game.board).to be_truthy
      expect(game.deck.count).to be(Root::Decks::Starter::DECK_SIZE)
    end
  end

  # OOF this gon be big.
  describe '.setup' do
    it 'sets up the game' do
      game = Root::Game.default_game
      human_player = game.players.fetch_player(:mice)
      allow(human_player).to receive(:pick_option).and_return(0)

      game.setup

      expect(game.players.all? { |p| p.current_hand_size == 3 }).to be true
      expect(game.players.all? { |p| p.victory_points == 0 }).to be true
    end
  end
end