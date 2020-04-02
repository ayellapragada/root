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
      expect(board.clearings_with(:sawmill).all?(&:wood?)).to be true
    end
  end

  xdescribe '#daylight' do
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

  # Little bit silly, but each method should reaally be tested correctly alone.
  describe '#currently_available_options' do
    context 'when able to do everything' do
      it 'has 6 options' do
        player, faction = build_player_and_faction
        player.setup
        allow(faction).to receive(:can_battle?).and_return(true)
        allow(faction).to receive(:can_move?).and_return(true)
        allow(faction).to receive(:can_build?).and_return(true)
        allow(faction).to receive(:can_recruit?).and_return(true)
        allow(faction).to receive(:can_overwork?).and_return(true)
        allow(faction).to receive(:can_discard_bird?).and_return(true)

        expect(faction.currently_available_options).to match_array(
          %i[battle march build recruit overwork discard_bird]
        )
      end
    end
  end

  # battle only if meeple somewhere with another factions piece
  describe '#battle_options' do
    it 'finds everywhere the cats can battle in' do
      player, faction = build_player_and_faction
      board = player.board
      player.setup

      c1 = board.clearings_with_meeples(:cats).select(&:with_spaces?).first
      c2 = board.clearings_with_meeples(:cats).select(&:with_spaces?).last
      board.create_building(Root::Factions::Birds::Roost.new, c1)
      board.place_token(Root::Factions::Mice::Sympathy.new, c2)

      expect(faction.battle_options).to match_array([c1, c2])
      expect(faction.can_battle?).to be true
    end
  end

  # march only if meeples with rule that aren't trapped
  describe '#move_options' do
    context 'with rule in a clearing' do
      it 'finds everywhere that can be moved from' do
        player, faction = build_player_and_faction
        clearings = player.board.clearings

        clearings[:five].place_meeple(faction.meeples.first)

        expect(faction.move_options).to eq([clearings[:five]])
        expect(faction.can_move?).to be true
      end
    end

    context 'without rule in the from or to of a clearing' do
      it 'does not have any move locations' do
        player, faction = build_player_and_faction
        clearings = player.board.clearings
        bird_faction = Root::Players::Computer.for('Hal', :birds).faction

        clearings[:five].place_meeple(faction.meeples.first)

        clearings[:five].place_meeple(bird_faction.meeples.first)
        clearings[:one].place_meeple(bird_faction.meeples.first)
        clearings[:two].place_meeple(bird_faction.meeples.first)

        expect(faction.move_options).to eq([])
        expect(faction.can_move?).to be false
      end
    end
  end

  describe '#clearing_move_options' do
    context 'when faction rules the from' do
      it 'is able to move to the other clearing' do
        player, faction = build_player_and_faction
        clearings = player.board.clearings

        clearings[:five].place_meeple(faction.meeples.first)

        expect(faction.clearing_move_options(clearings[:five]))
          .to match_array([clearings[:one], clearings[:two]])
      end
    end

    context 'when faction rules the to' do
      it 'is able to move to the other clearing' do
        player, faction = build_player_and_faction
        clearings = player.board.clearings

        bird_faction = Root::Players::Computer.for('Hal', :birds).faction
        clearings[:one].place_meeple(bird_faction.meeples.first)
        clearings[:nine].place_meeple(bird_faction.meeples.first)
        clearings[:ten].place_meeple(bird_faction.meeples.first)

        clearings[:five].place_meeple(faction.meeples.first)
        clearings[:one].place_meeple(faction.meeples.first)

        expect(faction.clearing_move_options(clearings[:one]))
          .to match_array([clearings[:five]])
      end
    end

    context 'when faction rules neither' do
      it 'is unable to move to the other clearing' do
        player, faction = build_player_and_faction
        clearings = player.board.clearings

        bird_faction = Root::Players::Computer.for('Hal', :birds).faction
        clearings[:one].place_meeple(bird_faction.meeples.first)
        clearings[:two].place_meeple(bird_faction.meeples.first)
        clearings[:five].place_meeple(bird_faction.meeples.first)

        clearings[:five].place_meeple(faction.meeples.first)

        expect(faction.clearing_move_options(clearings[:five]))
          .to match_array([])
      end
    end
  end

  describe '#march'

  describe '#overwork_options' do
    context 'without sawmills' do
      it 'does not have the ability to overwork' do
        player, faction = build_player_and_faction
        player.setup

        expect(faction.overwork_options).to be_empty
        expect(faction.can_overwork?).to be false
      end
    end

    context 'with sawmills and valid cards' do
      it 'finds all locations faction can overwork in' do
        player, faction = build_player_and_faction
        clearings = player.board.clearings

        clearings[:one].create_building(faction.sawmills[0])
        clearings[:two].create_building(faction.sawmills[1])

        faction.hand << Root::Cards::Base.new(suit: :fox)

        expect(faction.overwork_options).to eq([clearings[:one]])
        expect(faction.can_overwork?).to be true
      end
    end
  end

  describe '#overwork' do
    it 'places a wood at a workshop after discarding a card of that suit' do
      deck = Root::Decks::List.default_decks_list.shared
      player, faction = build_player_and_faction
      player.setup
      clearing = player.board.clearings_with(:sawmill).first
      faction.hand << Root::Cards::Base.new(suit: clearing.suit)

      expect { faction.overwork(deck) }
        .to change { faction.wood.count }
        .by(-1).and change { faction.hand.count }.by(-1)
      expect(clearing.wood.count).to be(1)
    end
  end

  # build only if wood and spaces you rule in you can build in
  describe '#can_build?'

  describe '#build'

  # recruit only if recruiters but not yet already recruited
  describe '#can_recruit?' do
    context 'without any recruiters' do
      it 'can not recruit' do
        player, faction = build_player_and_faction
        board = player.board

        expect(faction.can_recruit?).to be false
        board.clearings[:one].create_building(faction.recruiters.first)
        expect(faction.can_recruit?).to be true
      end
    end
  end

  describe '#recruit' do
    it 'places a meeple at every clearing with a recruiter' do
      player, faction = build_player_and_faction
      board = player.board
      player.setup

      expect(faction.can_recruit?).to be true
      expect { faction.recruit }
        .to change { faction.meeples.count }.by(-1)
      expect(board.clearings_with(:recruiter).all? { |r| r.meeples.count == 2 })
        .to be true
      expect(faction.can_recruit?).to be false
    end
  end

  describe '#can_discard_bird?' do
    context 'when bird in hand' do
      it 'discards a bird card in hand to get an extra action' do
        player, faction = build_player_and_faction

        card = Root::Cards::Base.new(suit: :bird)
        faction.hand << card
        expect(faction.can_discard_bird?).to be true
      end
    end

    context 'when no bird in hand' do
      it 'discards a bird card in hand to get an extra action' do
        player, faction = build_player_and_faction

        card = Root::Cards::Base.new(suit: :fox)
        faction.hand << card
        expect(faction.can_discard_bird?).to be false
      end
    end
  end

  describe '#discard_bird' do
    it 'discards a bird card in hand to get an extra action' do
      player, faction = build_player_and_faction
      deck = Root::Decks::List.default_decks_list.shared
      player.setup

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
      player, faction = build_player_and_faction
      allow(player).to receive(:pick_option).and_return(0)

      deck = Root::Decks::List.default_decks_list
      player.setup(decks: deck)

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
        player, faction = build_player_and_faction
        allow(player).to receive(:pick_option).and_return(0)
        player.setup

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
        _player, faction = build_player_and_faction
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
        player, faction = build_player_and_faction
        player.board = board
        allow(player).to receive(:pick_option).and_return(0)
        player.setup

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
        player, faction = build_player_and_faction
        allow(player).to receive(:pick_option).and_return(0)
        player.setup

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
        player, faction = build_player_and_faction
        deck = Root::Decks::Starter.new
        player.setup

        expect { faction.evening(deck) }.to change(faction, :hand_size).by(1)
      end
    end

    xcontext 'with draw bonuses' do
      it 'draw one card plus one per bonus' do
        # player, faction = build_player_and_faction
        # deck = Root::Decks::Starter.new
        # player.setup

        # expect { faction.evening(deck) }.to change(faction, :hand_size).by(1)
      end
    end

    xcontext 'when over 5 cards' do
      it 'discards down to 5 cards' do
        # player, faction = build_player_and_faction
        # deck = Root::Decks::Starter.new
        # player.setup

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
      cl.meeples.count == 1 && cl.meeples.first.faction == :cats
    end
  end

  def build_player_and_faction
    player = Root::Players::Computer.for('Sneak', :cats)
    [player, player.faction]
  end
end
