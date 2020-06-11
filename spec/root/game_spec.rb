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

  describe '#get_current_actions' do
    it 'do things' do
      game = Root::Game.default_game(with_computers: true)
      cat_faction = game.players.fetch_player(:cats).faction

      cat_faction.place_keep(game.board.clearings[:one])
      res = game.get_current_actions('SETUP', cat_faction).as_json
      expect(res[:key]).to eq(:c_initial_building_choice)
      expect(res[:children].count).to eq(3)

      expect(res[:children][0][:key]).to eq(:c_initial_building)
      expect(res[:children][0][:children].count).to eq(4)
      expect(res[:children][0][:val]).to eq(:recruiter)

      expect(res[:children][1][:key]).to eq(:c_initial_building)
      expect(res[:children][1][:children].count).to eq(4)
      expect(res[:children][1][:val]).to eq(:sawmill)

      expect(res[:children][2][:key]).to eq(:c_initial_building)
      expect(res[:children][2][:children].count).to eq(4)
      expect(res[:children][2][:val]).to eq(:workshop)

      expect(res[:children][0][:children][0][:children].count).to eq(0)
      expect(res[:children][0][:children][1][:children].count).to eq(0)
      expect(res[:children][0][:children][2][:children].count).to eq(0)
      expect(res[:children][0][:children][3][:children].count).to eq(0)
    end
  end
end
