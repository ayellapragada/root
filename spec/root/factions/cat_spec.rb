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

  # A place
  # A taker
  # describe 'attr_buildings' do
  #   it 'creates methods for easy buiilding abstractions' do
  #     _player, faction = build_player_and_faction
  #     expect(faction.sawmills.count).to be(6)
  #   end
  # end

  describe 'attr_tokens'

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
      allow(player).to receive(:pick_option).and_return(0)
      game.setup

      expect { player.faction.take_turn(players: game.players) }
        .to change(player, :inspect)
    end
  end

  describe '#birdsong' do
    it 'gives all sawmills wood' do
      player, faction = build_player_and_faction
      clearings = player.board.clearings
      faction.place_building(faction.sawmills.first, clearings[:nine])
      faction.place_building(faction.sawmills.first, clearings[:nine])
      faction.place_building(faction.sawmills.first, clearings[:one])

      expect { faction.birdsong }
        .to change { faction.wood.count }
        .by(-3)
      expect(clearings[:nine].wood.count).to be(2)
      expect(clearings[:one].wood.count).to be(1)
    end
  end

  xdescribe '#daylight' do
    it 'gives player 3 actions with choices' do
      player = Root::Players::Human.for('Sneak', :cats)
      allow(player).to receive(:pick_option).and_return(0)
      player.setup
      faction = player.faction
      faction.hand << Root::Cards::Base.new(suit: :bird)
      faction.birdsong
      faction.daylight
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
      expect(faction.currently_available_options).to include(:battle)
    end
  end

  describe '#battle' do
    it 'removes units after battle' do
      player, faction = build_player_and_faction
      bird_player = Root::Players::Computer.for('Hal', :birds)
      players = Root::Players::List.new(player, bird_player)
      allow(player).to receive(:pick_option).and_return(0)
      clearings = player.board.clearings

      clearings[:five].place_meeple(faction.meeples.first)
      clearings[:five].create_building(Root::Factions::Birds::Roost.new)

      # We're using a defenseless building to avoid needing mocks
      # removing a cardboard piece is one VP
      expect { faction.battle(players) }
        .to change(faction, :victory_points).by(1)
      expect(clearings[:five].buildings.count).to eq(0)
    end
  end

  describe 'initiate_battle_with_faction' do
    it 'rolls 2 dice and gives higher to attacker' do
      player, faction = build_player_and_faction
      bird_player = Root::Players::Computer.for('Hal', :birds)
      players = Root::Players::List.new(player, bird_player)
      allow(player).to receive(:pick_option).and_return(0)
      clearings = player.board.clearings

      clearings[:five].place_meeple(faction.meeples.pop)
      clearings[:five].place_meeple(faction.meeples.pop)
      clearings[:five].place_meeple(bird_player.faction.meeples.pop)
      clearings[:five].place_meeple(bird_player.faction.meeples.pop)

      allow(faction).to receive(:dice_roll).and_return(2, 1)

      faction.battle(players)

      expect(clearings[:five].meeples_of_type(:cats).count).to eq(1)
      expect(clearings[:five].meeples_of_type(:birds).count).to eq(0)
    end

    context 'when defender has no meeples' do
      it 'gives an extra hit to the attackers' do
        player, faction = build_player_and_faction
        mice_player = Root::Players::Computer.for('Hal', :mice)
        mice_faction = mice_player.faction
        players = Root::Players::List.new(player, mice_player)

        allow(player).to receive(:pick_option).and_return(0)
        clearings = player.board.clearings

        clearings[:five].place_meeple(faction.meeples.pop)
        clearings[:five].place_token(mice_faction.sympathy.pop)

        expect { faction.battle(players) }
          .to change(faction, :victory_points).by(1)
        expect(clearings[:five].buildings.count).to eq(0)
      end
    end
  end

  describe '#move_options' do
    context 'with rule in a clearing' do
      it 'finds everywhere that can be moved from' do
        player, faction = build_player_and_faction
        clearings = player.board.clearings

        faction.place_meeple(clearings[:five])

        expect(faction.move_options).to eq([clearings[:five]])
        expect(faction.can_move?).to be true
        expect(faction.currently_available_options).to include(:march)
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
        expect(faction.currently_available_options).not_to include(:march)
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

  describe '#move' do
    it 'faction moves any number of units from one clearingto another' do
      player, faction = build_player_and_faction
      clearing = player.board.clearings[:one]
      clearing.place_meeple(faction.meeples[0])
      clearing.place_meeple(faction.meeples[1])
      allow(player).to receive(:pick_option).and_return(0)

      faction.move(clearing)

      # Okay, so this is not ideal, but the idea is that option 0 will be:
      # 1. move (1) meeple
      # 2. to first clearing which is :five
      expect(player.board.clearings[:one].meeples.count).to be(1)
      expect(player.board.clearings[:five].meeples.count).to be(1)
    end
  end

  describe '#march' do
    it 'allows faction to move twice' do
      player, faction = build_player_and_faction
      clearing = player.board.clearings[:one]
      clearing.place_meeple(faction.meeples[0])
      # BIG OOF. Basically just
      # 1. Move from clearing :one
      # 2. Move to clearing :five
      # 3. Move 1 unit
      # 4. Move from clearing :five
      # 5. Move to clearing :two, NOT clearing :one (which is 0)
      # 6. Move 1 unit
      allow(player).to receive(:pick_option).and_return(0, 0, 0, 0, 1, 0)

      faction.march
      expect(player.board.clearings[:one].meeples.count).to be(0)
      expect(player.board.clearings[:two].meeples.count).to be(1)
    end
  end

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
      player, faction = build_player_and_faction
      player.setup
      clearing = player.board.clearings_with(:sawmill).first
      faction.hand << Root::Cards::Base.new(suit: clearing.suit)

      expect { faction.overwork }
        .to change { faction.wood.count }
        .by(-1).and change { faction.hand.count }.by(-1)
      expect(clearing.wood.count).to be(1)
    end
  end

  describe '#cost_for_next_building' do
    it 'finds next wood total needed to build another building' do
      player, faction = build_player_and_faction

      expect(faction.cost_for_next_building(:sawmill)).to be(0)
      expect(faction.cost_for_next_building(:recruiter)).to be(0)
      expect(faction.cost_for_next_building(:workshop)).to be(0)

      clearings = player.board.clearings
      faction.place_building(faction.sawmills.first, clearings[:one])
      faction.place_building(faction.recruiters.first, clearings[:two])
      faction.place_building(faction.workshops.first, clearings[:three])

      expect(faction.cost_for_next_building(:sawmill)).to be(1)
      expect(faction.cost_for_next_building(:recruiter)).to be(1)
      expect(faction.cost_for_next_building(:workshop)).to be(1)

      faction.place_building(faction.sawmills.first, clearings[:four])
      faction.place_building(faction.recruiters.first, clearings[:five])
      faction.place_building(faction.workshops.first, clearings[:six])

      expect(faction.cost_for_next_building(:sawmill)).to be(2)
      expect(faction.cost_for_next_building(:recruiter)).to be(2)
      expect(faction.cost_for_next_building(:workshop)).to be(2)
    end
  end

  describe 'build_options' do
    context 'when wood is in clearing' do
      it 'can craft new building' do
        player, faction = build_player_and_faction
        clearing = player.board.clearings[:two]

        faction.place_wood(clearing)
        faction.place_meeple(clearing)

        expect(faction.build_options).to eq([clearing])
        expect(faction.can_build?).to be true
      end
    end

    context 'when wood is in connected clearing' do
      it 'can craft new building' do
        player, faction = build_player_and_faction

        clearing_to_build_in = player.board.clearings[:one]
        clearing_with_wood = player.board.clearings[:five]

        faction.place_wood(clearing_with_wood)
        faction.place_meeple(clearing_with_wood)
        faction.place_meeple(clearing_to_build_in)
        # Fill up clearing with wood to force to build somewhere else
        faction.place_building(faction.sawmills.first, clearing_with_wood)
        faction.place_building(faction.sawmills.first, clearing_with_wood)

        expect(faction.build_options).to eq([clearing_to_build_in])
        expect(faction.can_build?).to be true
      end
    end

    context 'when wood is not connected to clearing' do
      it 'can not craft' do
        player, faction = build_player_and_faction

        clearings = player.board.clearings
        clearing_to_build_in = clearings[:one]
        clearing_with_wood = clearings[:two]

        # The idea is you need 2 wood to build something,
        # and you have 2 wood, but they're not connected because of :five
        faction.place_wood(clearing_with_wood)
        faction.place_meeple(clearing_with_wood)
        faction.place_wood(clearing_to_build_in)
        faction.place_meeple(clearing_to_build_in)

        # Fill up clearing with wood to force to build somewhere else
        # Also raise the cost_for_next_building away from 1
        faction.place_building(faction.sawmills.first, clearings[:eight])
        faction.place_building(faction.sawmills.first, clearings[:eight])
        faction.place_building(faction.recruiters.first, clearings[:four])
        faction.place_building(faction.recruiters.first, clearings[:four])
        faction.place_building(faction.workshops.first, clearings[:seven])
        faction.place_building(faction.workshops.first, clearings[:seven])

        expect(faction.build_options).to eq([])
        expect(faction.can_build?).to be false
      end
    end
  end

  describe '#build' do
    it 'builds in valid clearing and removes wood' do
      player, faction = build_player_and_faction
      allow(player).to receive(:pick_option).and_return(0)
      clearing = player.board.clearings[:two]
      faction.place_wood(clearing)
      faction.place_building(faction.sawmills.first, clearing)

      faction.build

      expect(clearing.buildings.count).to be(2)
      expect(clearing.wood?).to be false
    end
  end

  describe '#build_in_clearing' do
    it 'gives player options to build in a clearing' do
      player, faction = build_player_and_faction
      allow(player).to receive(:pick_option).and_return(0)
      clearing = player.board.clearings[:two]
      faction.place_wood(clearing)
      faction.place_building(faction.sawmills.first, clearing)

      faction.build_in_clearing(clearing)

      expect(faction.victory_points).to be(1)
      expect(faction.sawmills.count).to be(4)
      expect(clearing.buildings.count).to be(2)
      expect(clearing.wood?).to be false
    end
  end

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
      clearings = player.board.clearings

      faction.place_building(faction.recruiters.first, clearings[:nine])
      faction.place_building(faction.recruiters.first, clearings[:nine])
      faction.place_building(faction.recruiters.first, clearings[:one])

      expect { faction.recruit }
        .to change { faction.meeples.count }
        .by(-3)
      expect(clearings[:nine].meeples_of_type(:cats).count).to be(2)
      expect(clearings[:one].meeples_of_type(:cats).count).to be(1)
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
    # This is slightly annoying
    # but it needs to be 2 because we use it in a method that costs 1 action
    it 'discards a bird card in hand to get an extra action' do
      player, faction = build_player_and_faction
      player.setup

      card = Root::Cards::Base.new(suit: :bird)
      faction.hand << card

      expect { faction.discard_bird }
        .to change { faction.remaining_actions }
        .by(2)

      expect(faction.hand).not_to include(card)
    end
  end

  describe '#craft_items' do
    it 'crafts card, removes from board and adds victory points' do
      player, faction = build_player_and_faction
      allow(player).to receive(:pick_option).and_return(0)

      player.setup

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

      faction.craft_items
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
        player.setup

        expect { faction.evening }.to change(faction, :hand_size).by(1)
      end
    end

    context 'with draw bonuses' do
      it 'draw one card plus one per bonus' do
        player, faction = build_player_and_faction
        clearings = player.board.clearings
        faction.place_building(faction.recruiters.first, clearings[:two])
        faction.place_building(faction.recruiters.first, clearings[:two])
        faction.place_building(faction.recruiters.first, clearings[:two])

        expect { faction.evening }.to change(faction, :hand_size).by(2)
      end
    end

    context 'when over 5 cards' do
      it 'discards down to 5 cards' do
        player, faction = build_player_and_faction
        allow(player).to receive(:pick_option).and_return(0)
        allow(player.deck)
        5.times { faction.hand << Root::Cards::Base.new(suit: :bird) }

        expect { faction.evening }.to change { faction.hand }
      end
    end
  end

  describe '#special_info' do
    it 'returns number of VP and draw bonuses, or else building tyoe' do
      player, faction = build_player_and_faction
      clearings = player.board.clearings

      faction.place_recruiter(clearings[:twelve])
      faction.place_recruiter(clearings[:twelve])
      faction.place_recruiter(clearings[:eight])

      faction.place_workshop(clearings[:eight])
      faction.place_workshop(clearings[:nine])
      faction.place_workshop(clearings[:nine])
      faction.place_workshop(clearings[:one])
      faction.place_workshop(clearings[:five])
      faction.place_workshop(clearings[:five])

      faction.place_sawmill(clearings[:seven])
      faction.place_sawmill(clearings[:seven])

      faction.place_meeple(clearings[:seven])
      faction.place_meeple(clearings[:seven])

      expect(faction.special_info(true)).to eq(
        [
          %w[Wood 0 1 2 3 3 4],
          %w[Sawmills 0 1 S S S S],
          %w[Workshops 0 2 2 3 4 5],
          ['Recruiters', '0', '1', '2 (D+1)', 'R', 'R', 'R']
        ]
      )
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
