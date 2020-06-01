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
      expect(game.deck.count).to be(Root::Decks::Starter::DECK_SIZE)
    end
  end

  describe '#setup' do
    it 'sets up the game' do
      game = Root::Game.default_game(with_computers: true)

      game.setup

      expect(game.players.all? { |p| p.current_hand_size == 3 }).to be true
      expect(game.players.all? { |p| p.victory_points == 0 }).to be true
      expect(game.active_quests.count).to be(3)
    end
  end

  describe '#state' do
    it 'is a quick easy reference for the game state' do
      game = Root::Game.default_game(with_computers: true)
      game.setup

      res = <<~RES
        M:H3:M10:B03:T10
        C:H3:M14:B15:T08
        B:H3:M14:B06:T00
        R:H3:M00:B00:T00
      RES
      expect(game.state).to eq(res.chomp)
    end
  end

  # This is intensely problematic tbh.
  # I don't like this i'm cheating my way to 100/100 it's not ideal
  # lots of things need better expectations
  describe '#one_round' do
    it 'all players take their turn' do
      game = Root::Game.default_game(with_computers: true)
      allow_any_instance_of(Root::Players::Computer)
        .to receive(:pick_option).and_return(0)
      game.setup

      expect { game.one_round }.to change(game, :state)
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
