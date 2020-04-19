# frozen_string_literal: true

RSpec.describe Root::Factions::Racoon do
  describe '#handle_faction_token_setup' do
    it 'sets up an empty item set' do
      faction = Root::Players::Human.for('Sneak', :racoon).faction

      expect(faction.items).to be_empty
      expect(faction.damaged_items).to be_empty
      expect(faction.teas.count).to be(0)
      expect(faction.coins.count).to be(0)
      expect(faction.satchels.count).to be(0)
    end

    it 'sets up a single meeple' do
      faction = Root::Players::Human.for('Sneak', :racoon).faction
      expect(faction.meeples.count).to be(1)
    end
  end

  describe '#setup' do
    it 'selects a character and gets starting items' do
      game = Root::Game.default_game
      decks = game.decks
      players = game.players
      player = players.fetch_player(:racoon)
      allow(player).to receive(:pick_option).and_return(0)

      player.setup(decks: decks, players: players)
      faction = player.faction

      # the first options name, ah well.
      expect(faction.character.name).to be(:thief)
    end

    it 'selects a forest clearing to start in' do
      game = Root::Game.default_game
      board = game.board
      decks = game.decks
      players = game.players
      player = players.fetch_player(:racoon)
      allow(player).to receive(:pick_option).and_return(0)

      player.setup(decks: decks, players: players)

      expect(racoon_is_in_forest(board)).to be true
    end

    it 'sets up the relationships with other factions to neutral' do
      game = Root::Game.default_game
      decks = game.decks
      players = game.players
      player = players.fetch_player(:racoon)
      allow(player).to receive(:pick_option).and_return(0)

      player.setup(decks: decks, players: players)

      faction = player.faction
      expect(faction.relationships.all_neutral?).to be true
    end

    it 'sets up 4 ruins with item cards' do
      game = Root::Game.default_game
      board = game.board
      decks = game.decks
      players = game.players
      player = players.fetch_player(:racoon)
      allow(player).to receive(:pick_option).and_return(0)

      player.setup(decks: decks, players: players)

      expect(board.ruins.all?(&:contains_item?)).to be true
    end
  end

  def racoon_is_in_forest(board)
    board.forests.any? { |_, forest| forest.includes_meeple?(:racoon) }
  end
end
