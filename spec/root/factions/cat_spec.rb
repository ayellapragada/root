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
      player = Root::Players::Human.for('Sneak', :cats)
      cats = player.faction
      board = player.board
      allow(player).to receive(:pick_option).and_return(0)
      expect(board.keep_in_corner?).to be false

      player.setup

      expect(board.keep_in_corner?).to be true
      expect(cats.keep).to be_empty
    end

    it 'sets a sawmill, recruiter, and workshop in adjacent clearing' do
      player = Root::Players::Human.for('Sneak', :cats)
      cats = player.faction
      board = player.board
      allow(player).to receive(:pick_option).and_return(0)

      player.setup

      clearing = board.corner_with_keep
      expect(clearing_has_building(clearing, :recruiter)).to be true
      expect(clearing_has_building(clearing, :sawmill)).to be true
      expect(clearing_has_building(clearing, :workshop)).to be true
      expect(cats.recruiters.count).to be(5)
      expect(cats.sawmills.count).to be(5)
      expect(cats.workshops.count).to be(5)
    end

    it 'sets 11 warrior in all clearings except directly across' do
      player = Root::Players::Human.for('Sneak', :cats)
      cats = player.faction
      board = player.board
      allow(player).to receive(:pick_option).and_return(0)

      player.setup

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

      expect { player.faction.take_turn(deck: game.deck) }
        .to change(player, :inspect)
    end
  end

  describe '#birdsong' do
    it 'gives all sawmills wood' do
      player = Root::Players::Computer.for('Sneak', :cats)
      player.setup
      board = player.board

      faction = player.faction
      expect { faction.birdsong }
        .to change { faction.wood.count }
        .by(-1)
      expect(board.clearings_with(:sawmill).first.wood?).to be true
    end
  end

  describe '#daylight' do
    it 'gives player 3 actions with choices' do
      player = Root::Players::Human.for('Sneak', :cats)
      deck = Root::Decks::List.default_decks_list
      allow(player).to receive(:pick_option).and_return(0)
      player.setup
      faction = player.faction
      faction.hand << Root::Cards::Base.new(suit: :bird)
      faction.birdsong
      faction.daylight(deck)
    end
  end

  describe '#currently_available_options' do
    context 'when in its default state' do
      it 'shows 5 default options' do
        player = Root::Players::Computer.for('Sneak', :cats)
        player.setup
        faction = player.faction

        faction.birdsong
        expect(faction.currently_available_options)
          .to match_array(%i[battle march recruit build overwork])
      end
    end

    context 'when having recruited already' do
      it 'no longer shows recruit' do
        player = Root::Players::Computer.for('Sneak', :cats)
        player.setup
        faction = player.faction

        faction.birdsong
        faction.recruit

        expect(faction.currently_available_options)
          .to match_array(%i[battle march build overwork])
      end
    end

    context 'with a bird card in hand' do
      it 'shows option to discard bird card' do
        player = Root::Players::Computer.for('Sneak', :cats)
        player.setup
        faction = player.faction

        faction.hand << Root::Cards::Base.new(suit: :bird)
        faction.birdsong

        expect(faction.currently_available_options)
          .to match_array(%i[battle march recruit build overwork discard_bird])
      end
    end
  end

  describe '#battle'
  describe '#march'
  describe '#build'
  describe '#overwork'

  describe '#recruit' do
    it 'places a meeple at every clearing with a recruiter' do
      player = Root::Players::Computer.for('Sneak', :cats)
      board = player.board
      player.setup

      faction = player.faction
      expect { faction.recruit }
        .to change { faction.meeples.count }.by(-1)
      expect(board.clearings_with(:recruiter).first.meeples.count).to be(2)
    end
  end

  describe '#discard_bird' do
    it 'discards a bird card in hand to get an extra action' do
      deck = Root::Decks::List.default_decks_list.shared
      player = Root::Players::Computer.for('Sneak', :cats)
      player.setup

      faction = player.faction
      card = Root::Cards::Base.new(suit: :bird)
      faction.hand << card

      expect { faction.discard_bird(deck) }
        .to change { faction.remaining_actions }
        .by(1)

      expect(faction.hand).not_to include(card)
    end
  end

  describe '#craft_items' do
    it 'crafts card, removes from board and adds victory points' do
      deck = Root::Decks::List.default_decks_list
      player = Root::Players::Human.for('Sneak', :cats)
      allow(player).to receive(:pick_option).and_return(0)
      player.setup(decks: deck)
      faction = player.faction
      card_to_craft = Root::Cards::Item.new(
        suit: :fox,
        craft: %i[bunny],
        item: :tea,
        vp: 2
      )
      card_unable_to_be_crafted = Root::Cards::Item.new(
        suit: :fox,
        craft: %i[bunny],
        item: :coin,
        vp: 1
      )
      faction.hand << card_to_craft
      faction.hand << card_unable_to_be_crafted

      faction.craft_items(deck.shared)
      expect(faction.hand).not_to include(card_to_craft)
      expect(faction.hand).to include(card_unable_to_be_crafted)
      expect(faction.victory_points).to be(2)
      expect(faction.items).to include(:tea)
    end
  end

  describe 'craftable_items' do
    context 'when you have item card in hand that is available' do
      it 'is craftable' do
        player = Root::Players::Human.for('Sneak', :cats)
        allow(player).to receive(:pick_option).and_return(0)
        player.setup
        faction = player.faction

        card_to_craft = Root::Cards::Item.new(
          suit: :fox,
          craft: %i[bunny],
          item: :tea,
          vp: 2
        )
        faction.discard_hand
        faction.hand << card_to_craft

        expect(faction.craftable_items).to match_array([card_to_craft])
      end
    end

    context 'when you have no workshops out' do
      it 'does not allow for crafting anything' do
        player = Root::Players::Computer.for('Sneak', :cats)
        faction = player.faction
        card = Root::Cards::Item.new(
          suit: :fox,
          craft: %i[bunny],
          item: :tea,
          vp: 2
        )
        faction.hand << card
        expect(faction.craftable_items).not_to include(card)
      end
    end

    context 'when you have item card that is craftable but not available' do
      it 'is not craftable' do
        board = Root::Boards::Base.new(items: [])
        player = Root::Players::Human.for('Sneak', :cats)
        player.board = board
        allow(player).to receive(:pick_option).and_return(0)
        player.setup
        faction = player.faction

        card = Root::Cards::Item.new(
          suit: :fox,
          craft: %i[bunny],
          item: :tea,
          vp: 2
        )
        faction.hand << card

        expect(faction.craftable_items).not_to include(card)
      end
    end

    context 'when you have item card in hand different from clearing suit' do
      it 'is not craftable' do
        player = Root::Players::Human.for('Sneak', :cats)
        allow(player).to receive(:pick_option).and_return(0)
        player.setup
        faction = player.faction

        card = Root::Cards::Item.new(
          suit: :fox,
          craft: %i[fox],
          item: :tea,
          vp: 2
        )
        faction.hand << card

        expect(faction.craftable_items).not_to include(card)
      end
    end
  end

  describe '#evening' do
    context 'with no draw bonuses' do
      it 'draw one card' do
        player = Root::Players::Computer.for('Sneak', :cats)
        deck = Root::Decks::Starter.new
        player.setup

        faction = player.faction
        expect { faction.evening(deck) }.to change(faction, :hand_size).by(1)
      end
    end

    xcontext 'with draw bonuses' do
      it 'draw one card plus one per bonus' do
        # player = Root::Players::Computer.for('Sneak', :cats)
        # deck = Root::Decks::Starter.new
        # player.setup

        # faction = player.faction
        # expect { faction.evening(deck) }.to change(faction, :hand_size).by(1)
      end
    end

    xcontext 'when over 5 cards' do
      it 'discards down to 5 cards' do
        # player = Root::Players::Computer.for('Sneak', :cats)
        # deck = Root::Decks::Starter.new
        # player.setup

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
