# frozen_string_literal: true

RSpec.describe Holt::Game do
  describe '.initialize' do
    it 'takes players, board, and deck' do
      players = Holt::Players::List.default_player_list
      board = Holt::Boards::Woodlands.new
      deck = Holt::Decks::Starter.new

      game = Holt::Game.new(players: players, board: board, deck: deck)

      expect(game.players.current_player.name).to be('Sneaky')
      expect(game.board).to be_truthy
      expect(game.deck.count).to be(54)
    end
  end

  # OOF this gon be big.
  describe '.setup' do
    it 'sets up the game idk bro' do
      game = Holt::Game.default_game
      game.setup
      expect(game.players.all? { |p| p.current_hand_size == 3 }).to be true
    end
  end
end
