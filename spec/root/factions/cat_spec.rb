# frozen_string_literal: true

RSpec.describe Root::Factions::Cat do
  describe '#handle_faction_token_setup' do
    it 'gives faction 25 meeples, and then 6 buildings of each type' do
      player = Root::Players::Human.for('Sneak', :cats)
      cats = player.faction

      expect(cats.meeples.count).to eq(25)

      expect(cats.recruiters.count).to eq(6)
      expect(cats.sawmills.count).to eq(6)
      expect(cats.workshops.count).to eq(6)

      expect(cats.wood.count).to eq(8)
    end
  end

  describe '#setup' do
    it 'sets a keep in the corner' do
      board = Root::Boards::Base.new
      player = Root::Players::Human.for('Sneak', :cats)
      cats = player.faction
      allow(player).to receive(:pick_option).and_return(0)
      expect(board.keep_in_corner?).to be false

      player.setup(board: board)

      expect(board.keep_in_corner?).to be true
      expect(cats.keep).to be_empty
    end

    it 'sets a sawmill, recruiter, and workshop in adjacent clearing' do
      board = Root::Boards::Base.new
      player = Root::Players::Human.for('Sneak', :cats)
      cats = player.faction
      allow(player).to receive(:pick_option).and_return(0)

      player.setup(board: board)

      clearing = board.corner_with_keep
      expect(clearing_has_building(clearing, :recruiter)).to be true
      expect(clearing_has_building(clearing, :sawmill)).to be true
      expect(clearing_has_building(clearing, :workshop)).to be true
      expect(cats.recruiters.count).to be(5)
      expect(cats.sawmills.count).to be(5)
      expect(cats.workshops.count).to be(5)
    end

    it 'sets 11 warrior in all clearings except directly across' do
      board = Root::Boards::Base.new
      player = Root::Players::Human.for('Sneak', :cats)
      cats = player.faction
      allow(player).to receive(:pick_option).and_return(0)

      player.setup(board: board)

      keep_clearing = board.clearing_across_from_keep
      other_clearings = board.clearings_other_than(keep_clearing)
      expect(clearings_have_one_cat_meeple?(other_clearings)).to be true
      expect(cats.meeples.count).to eq(14)
      expect(keep_clearing.meeples.count).to eq(0)
    end
  end

  describe '#take_turn' do
    it 'goes through all phases of a turn' do
      game = Root::Game.default_game(with_computers: true)
      player = game.players.fetch_player(:cats)
      game.setup

      expect { player.faction.take_turn(board: game.board, deck: game.deck) }
        .to change(player, :inspect)
    end
  end

  describe '#birdsong' do
    it 'gives all sawmills wood' do
      board = Root::Boards::Base.new
      player = Root::Players::Computer.for('Sneak', :cats)
      player.setup(board: board)

      faction = player.faction
      expect { faction.birdsong(board) }
        .to change { faction.wood.count }
        .by(-1)
      expect(board.clearings_with(:sawmill).first.wood?).to be true
    end
  end

  describe '#evening' do
    context 'with no draw bonuses' do
      it 'draw one card' do
        board = Root::Boards::Base.new
        player = Root::Players::Computer.for('Sneak', :cats)
        deck = Root::Decks::Starter.new
        player.setup(board: board)

        faction = player.faction
        expect { faction.evening(deck) }.to change(faction, :hand_size).by(1)
      end
    end

    xcontext 'with draw bonuses' do
      it 'draw one card plus one per bonus' do
        # board = Root::Boards::Base.new
        # player = Root::Players::Computer.for('Sneak', :cats)
        # deck = Root::Decks::Starter.new
        # player.setup(board: board)

        # faction = player.faction
        # expect { faction.evening(deck) }.to change(faction, :hand_size).by(1)
      end
    end
  end

  def clearing_has_building(clearing, type)
    clearing.includes_building?(type) ||
      clearing.adjacents.one? { |adj| adj.includes_building?(type) }
  end

  def clearings_have_one_cat_meeple?(clearings)
    clearings.all? do |cl|
      cl.meeples.count == 1 && cl.meeples.first.faction == :cat
    end
  end
end
