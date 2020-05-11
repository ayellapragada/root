# frozen_string_literal: true

RSpec.describe Root::Factions::Cat do
  let(:player) { Root::Players::Computer.for('Sneak', :cats) }
  let(:faction) { player.faction }
  let(:board) { player.board }
  let(:clearings) { board.clearings }
  let(:bird_player) { Root::Players::Computer.for('Sneak', :birds) }
  let(:bird_faction) { bird_player.faction }

  describe '#handle_faction_token_setup' do
    it 'gives faction 25 meeples, and then 6 buildings of each type' do
      expect(faction.meeples.count).to eq(25)

      expect(faction.recruiters.count).to eq(6)
      expect(faction.sawmills.count).to eq(6)
      expect(faction.workshops.count).to eq(6)

      expect(faction.wood.count).to eq(8)
    end
  end

  describe '#setup' do
    it 'sets a keep in the corner' do
      allow(player).to receive(:pick_option).and_return(0)

      expect(board.keep_in_corner?).to be false

      player.setup

      expect(board.keep_in_corner?).to be true
      expect(faction.keep).to be_empty
    end

    it 'sets a sawmill, recruiter, and workshop in adjacent clearing' do
      allow(player).to receive(:pick_option).and_return(0)

      player.setup

      clearing = board.corner_with_keep
      expect(clearing_has_building(clearing, :recruiter)).to be true
      expect(clearing_has_building(clearing, :sawmill)).to be true
      expect(clearing_has_building(clearing, :workshop)).to be true
      expect(faction.recruiters.count).to be(5)
      expect(faction.sawmills.count).to be(5)
      expect(faction.workshops.count).to be(5)
    end

    it 'sets 11 warrior in all clearings except directly across' do
      allow(player).to receive(:pick_option).and_return(0)

      player.setup

      keep_clearing = board.clearing_across_from_keep
      other_clearings = board.clearings_other_than(keep_clearing)
      expect(clearings_have_one_cat_meeple?(other_clearings)).to be true
      expect(faction.meeples.count).to eq(14)
      expect(keep_clearing.meeples.count).to eq(0)
    end
  end

  describe '#take_turn' do
    it 'goes through all phases of a turn' do
      game = Root::Game.default_game(with_computers: true)
      player = game.players.fetch_player(:cats)
      allow(player).to receive(:pick_option).and_return(0)
      game.setup

      expect { player.faction.take_turn }
        .to change(player, :inspect)
    end
  end

  describe '#birdsong' do
    it 'gives all sawmills wood' do
      faction.place_sawmill(clearings[:nine])
      faction.place_sawmill(clearings[:nine])
      faction.place_sawmill(clearings[:one])

      expect { faction.birdsong }
        .to change { faction.wood.count }
        .by(-3)
      expect(clearings[:nine].wood.count).to be(2)
      expect(clearings[:one].wood.count).to be(1)
    end

    context 'when not enough wood for all sawmills' do
      it 'selects which sawmills to place wood at' do
        allow(player).to receive(:pick_option).and_return(0)
        6.times { faction.place_wood(clearings[:one]) }
        faction.place_sawmill(clearings[:two])
        faction.place_sawmill(clearings[:three])
        faction.place_sawmill(clearings[:four])

        faction.birdsong
        expect(clearings[:two].wood.count).to eq(1)
        expect(clearings[:three].wood.count).to eq(1)
        expect(clearings[:four].wood.count).to eq(0)
      end
    end
  end

  # Little bit silly, but each method should reaally be tested correctly alone.
  describe '#daylight_options' do
    context 'when able to do everything' do
      it 'has 6 options' do
        allow(faction).to receive(:can_battle?).and_return(true)
        allow(faction).to receive(:can_move?).and_return(true)
        allow(faction).to receive(:can_build?).and_return(true)
        allow(faction).to receive(:can_recruit?).and_return(true)
        allow(faction).to receive(:can_overwork?).and_return(true)
        allow(faction).to receive(:can_discard_bird?).and_return(true)

        expect(faction.daylight_options).to match_array(
          %i[battle march build recruit overwork discard_bird]
        )
      end
    end
  end

  # battle only if meeple somewhere with another factions piece
  describe '#battle_options' do
    it 'finds everywhere the cats can battle in' do
      player.setup

      c1 = board.clearings_with_meeples(:cats).select(&:with_spaces?).first
      c2 = board.clearings_with_meeples(:cats).select(&:with_spaces?).last
      board.create_building(Root::Factions::Birds::Roost.new, c1)
      board.place_token(Root::Factions::Mice::Sympathy.new, c2)

      expect(faction.battle_options).to match_array([c1, c2])
      expect(faction.can_battle?).to be true
      expect(faction.daylight_options).to include(:battle)
    end
  end

  describe '#battle' do
    it 'removes units after battle' do
      players = Root::Players::List.new(player, bird_player)
      player.players = players
      allow(player).to receive(:pick_option).and_return(0)

      faction.place_meeple(clearings[:five])
      bird_faction.place_roost(clearings[:five])

      # We're using a defenseless building to avoid needing mocks
      # removing a cardboard piece is one VP
      expect { faction.battle }
        .to change(faction, :victory_points).by(1)
      expect(clearings[:five].buildings.count).to eq(0)
    end
  end

  describe '#move_options' do
    context 'with rule in a clearing' do
      it 'finds everywhere that can be moved from' do
        faction.place_meeple(clearings[:five])

        expect(faction.move_options).to eq([clearings[:five]])
        expect(faction.can_move?).to be true
        expect(faction.daylight_options).to include(:march)
      end
    end

    context 'without rule in the from or to of a clearing' do
      it 'does not have any move locations' do
        faction.place_meeple(clearings[:five])

        bird_faction.place_meeple(clearings[:five])
        bird_faction.place_meeple(clearings[:one])
        bird_faction.place_meeple(clearings[:two])

        expect(faction.move_options).to eq([])
        expect(faction.can_move?).to be false
        expect(faction.daylight_options).not_to include(:march)
      end
    end
  end

  describe '#clearing_move_options' do
    context 'when faction rules the from' do
      it 'is able to move to the other clearing' do
        faction.place_meeple(clearings[:five])

        expect(faction.clearing_move_options(clearings[:five]))
          .to match_array([clearings[:one], clearings[:two]])
      end
    end

    context 'when faction rules the to' do
      it 'is able to move to the other clearing' do
        bird_faction.place_meeple(clearings[:one])
        bird_faction.place_meeple(clearings[:nine])
        bird_faction.place_meeple(clearings[:ten])

        faction.place_meeple(clearings[:one])
        faction.place_meeple(clearings[:five])

        expect(faction.clearing_move_options(clearings[:one]))
          .to match_array([clearings[:five]])
      end
    end

    context 'when faction rules neither' do
      it 'is unable to move to the other clearing' do
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
    it 'faction moves any number of units from one clearing to another' do
      players = Root::Players::List.new(player, bird_player)
      player.players = players

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

    it 'does not have to move' do
      allow(player).to receive(:pick_option).and_return(1)

      faction.place_meeple(clearings[:one])

      faction.march
      expect(player.board.clearings[:one].meeples.count).to be(1)
    end
  end

  describe '#overwork_options' do
    context 'without sawmills' do
      it 'does not have the ability to overwork' do
        player.setup

        expect(faction.overwork_options).to be_empty
        expect(faction.can_overwork?).to be false
      end
    end

    context 'with sawmills and valid cards' do
      it 'finds all locations faction can overwork in' do
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
      allow(player).to receive(:pick_option).and_return(0)
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
      expect(faction.cost_for_next_building(:sawmill)).to be(0)
      expect(faction.cost_for_next_building(:recruiter)).to be(0)
      expect(faction.cost_for_next_building(:workshop)).to be(0)

      faction.place_sawmill(clearings[:one])
      faction.place_recruiter(clearings[:two])
      faction.place_workshop(clearings[:three])

      expect(faction.cost_for_next_building(:sawmill)).to be(1)
      expect(faction.cost_for_next_building(:recruiter)).to be(1)
      expect(faction.cost_for_next_building(:workshop)).to be(1)

      faction.place_sawmill(clearings[:four])
      faction.place_recruiter(clearings[:five])
      faction.place_workshop(clearings[:six])

      expect(faction.cost_for_next_building(:sawmill)).to be(2)
      expect(faction.cost_for_next_building(:recruiter)).to be(2)
      expect(faction.cost_for_next_building(:workshop)).to be(2)
    end
  end

  describe 'build_options' do
    context 'when wood is in clearing' do
      it 'can craft new building' do
        faction.place_wood(clearings[:two])
        faction.place_meeple(clearings[:two])

        expect(faction.build_options).to eq([clearings[:two]])
        expect(faction.can_build?).to be true
      end
    end

    context 'when wood is in connected clearing' do
      it 'can craft new building' do
        clearing_to_build_in = player.board.clearings[:one]
        clearing_with_wood = player.board.clearings[:five]

        faction.place_wood(clearing_with_wood)
        faction.place_meeple(clearing_with_wood)
        faction.place_meeple(clearing_to_build_in)
        # Fill up clearing with wood to force to build somewhere else
        faction.place_sawmill(clearing_with_wood)
        faction.place_sawmill(clearing_with_wood)

        expect(faction.build_options).to eq([clearing_to_build_in])
        expect(faction.can_build?).to be true
      end
    end

    context 'when wood is not connected to clearing' do
      it 'can not craft' do
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
        faction.place_sawmill(clearings[:eight])
        faction.place_sawmill(clearings[:eight])
        faction.place_recruiter(clearings[:four])
        faction.place_recruiter(clearings[:four])
        faction.place_workshop(clearings[:seven])
        faction.place_workshop(clearings[:seven])

        expect(faction.build_options).to eq([])
        expect(faction.can_build?).to be false
      end
    end
  end

  describe '#build' do
    it 'builds in valid clearing and removes wood' do
      allow(player).to receive(:pick_option).and_return(0)
      clearing = player.board.clearings[:two]

      faction.place_wood(clearing)
      faction.place_sawmill(clearing)

      faction.build

      expect(clearing.buildings.count).to be(2)
      expect(clearing.wood?).to be false
    end
  end

  describe '#build_in_clearing' do
    it 'gives player options to build in a clearing' do
      allow(player).to receive(:pick_option).and_return(0)
      clearing = player.board.clearings[:two]
      faction.place_wood(clearing)
      faction.place_sawmill(clearing)

      faction.build_in_clearing(clearing)

      expect(faction.victory_points).to be(1)
      expect(faction.sawmills.count).to be(4)
      expect(faction.wood.count).to be(8)
      expect(clearing.buildings.count).to be(2)
      expect(clearing.wood?).to be false
    end
  end

  describe '#can_recruit?' do
    context 'without any recruiters placed' do
      it 'can not recruit' do
        expect(faction.can_recruit?).to be false

        faction.place_recruiter(clearings[:one])

        expect(faction.can_recruit?).to be true
      end
    end
  end

  describe '#recruit' do
    it 'places a meeple at every clearing with a recruiter' do
      faction.place_recruiter(clearings[:nine])
      faction.place_recruiter(clearings[:nine])
      faction.place_recruiter(clearings[:one])

      expect { faction.recruit }
        .to change { faction.meeples.count }
        .by(-3)
      expect(clearings[:nine].meeples_of_type(:cats).count).to be(2)
      expect(clearings[:one].meeples_of_type(:cats).count).to be(1)
    end

    context 'when not enough warriors for all recruiters' do
      it 'allows to select where warriors go' do
        allow(player).to receive(:pick_option).and_return(0)
        23.times { faction.place_meeple(clearings[:one]) }
        faction.place_recruiter(clearings[:two])
        faction.place_recruiter(clearings[:three])
        faction.place_recruiter(clearings[:four])

        faction.recruit
        expect(clearings[:two].meeples_of_type(:cats).count).to eq(1)
        expect(clearings[:three].meeples_of_type(:cats).count).to eq(1)
        expect(clearings[:four].meeples_of_type(:cats).count).to eq(0)
      end
    end
  end

  describe '#can_discard_bird?' do
    context 'when bird in hand' do
      it 'discards a bird card in hand to get an extra action' do
        card = Root::Cards::Base.new(suit: :bird)
        faction.hand << card
        expect(faction.can_discard_bird?).to be true
      end
    end

    context 'when no bird in hand' do
      it 'discards a bird card in hand to get an extra action' do
        card = Root::Cards::Base.new(suit: :fox)
        faction.hand << card
        expect(faction.can_discard_bird?).to be false
      end
    end
  end

  describe '#discard_bird' do
    it 'discards a bird card in hand to get an extra action' do
      allow(player).to receive(:pick_option).and_return(0)

      card = Root::Cards::Base.new(suit: :bird)
      faction.hand << card

      expect { faction.discard_bird }
        .to change(faction, :remaining_actions)
        .by(1)

      expect(faction.hand).not_to include(card)
    end

    it 'is able to be cancelled' do
      allow(player).to receive(:pick_option).and_return(1)

      card = Root::Cards::Base.new(suit: :bird)
      faction.hand << card

      expect { faction.discard_bird }
        .to change(faction, :remaining_actions)
        .by(0)

      expect(faction.hand).to include(card)
    end
  end

  describe '#with_action' do
    it 'does not change remaining actions if nothing happens' do
      faction.place_meeple(clearings[:one])
      # 1. march
      # 2. none / cancel march
      # 3. none / end daylight
      allow(player).to receive(:pick_option).and_return(0, 1, 2)
      players = Root::Players::List.new(player)

      faction.daylight

      expect(faction.remaining_actions).to eq(0)
    end
  end

  describe '#craft_items' do
    it 'crafts card, removes from board and adds victory points' do
      allow(player).to receive(:pick_option).and_return(0)

      player.setup

      card_to_craft = Root::Cards::Item.new(
        suit: :fox,
        craft: %i[rabbit],
        item: :tea,
        vp: 2
      )
      card_unable_to_be_crafted = Root::Cards::Item.new(
        suit: :fox,
        craft: %i[rabbit],
        item: :coin,
        vp: 1
      )

      faction.hand << card_to_craft
      faction.hand << card_unable_to_be_crafted

      faction.craft_with_specific_timing
      expect(faction.hand).not_to include(card_to_craft)
      expect(faction.hand).to include(card_unable_to_be_crafted)
      expect(faction.victory_points).to be(2)
      expect(faction.items.map(&:item)).to include(:tea)
    end

    it 'does not have to craft items' do
      allow(player).to receive(:pick_option).and_return(1)

      faction.place_workshop(player.board.clearings[:five])

      item_card = Root::Cards::Item.new(
        suit: :fox,
        craft: %i[rabbit],
        item: :tea,
        vp: 2
      )

      faction.hand << item_card

      faction.craft_items
      expect(faction.hand).to include(item_card)
      expect(faction.victory_points).to be(0)
      expect(faction.items).not_to include(:tea)
    end
  end

  describe 'craftable_items' do
    context 'when you have item card in hand that is available' do
      it 'is craftable' do
        allow(player).to receive(:pick_option).and_return(0)
        player.setup

        card_to_craft = Root::Cards::Item.new(
          suit: :fox,
          craft: %i[rabbit],
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
        card = Root::Cards::Item.new(
          suit: :fox,
          craft: %i[rabbit],
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
        player.board = board
        allow(player).to receive(:pick_option).and_return(0)
        player.setup

        card = Root::Cards::Item.new(
          suit: :fox,
          craft: %i[rabbit],
          item: :tea,
          vp: 2
        )
        faction.hand << card

        expect(faction.craftable_items).not_to include(card)
      end
    end

    context 'when you have item card in hand different from clearing suit' do
      it 'is not craftable' do
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
        player.setup

        expect { faction.evening }.to change(faction, :hand_size).by(1)
      end
    end

    context 'with draw bonuses' do
      it 'draw one card plus one per bonus' do
        faction.place_recruiter(clearings[:two])
        faction.place_recruiter(clearings[:two])
        faction.place_recruiter(clearings[:two])

        expect { faction.evening }.to change(faction, :hand_size).by(2)
      end
    end

    context 'when over 5 cards' do
      it 'discards down to 5 cards' do
        allow(player).to receive(:pick_option).and_return(0)
        5.times { faction.hand << Root::Cards::Base.new(suit: :bird) }

        expect { faction.evening }.to change { faction.hand }
      end
    end
  end

  describe '#special_info' do
    it 'returns number of VP and draw bonuses, or else building tyoe' do
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
        {
          board: {
            title: "The Keep | Field Hospital\nNo Items",
            rows: [
              %w[Sawmills 0 1 S S S S],
              %w[Workshops 0 2 2 3 4 5],
              ['Recruiters', '0', '1', '2(+1)', 'R', 'R', 'R']
            ],
            headings: %w[Wood 0 1 2 3 3 4]
          },
        }
      )
    end
  end

  describe '#field_hospital' do
    it 'allows player to return units lost in battle to keep' do
      allow(player).to receive(:pick_option).and_return(0)
      allow(bird_player).to receive(:pick_option).and_return(0)

      faction.place_keep(clearings[:one])
      faction.place_meeple(clearings[:five])
      faction.place_meeple(clearings[:five])
      bird_faction.place_meeple(clearings[:five])
      bird_faction.place_meeple(clearings[:five])

      allow_any_instance_of(Root::Actions::Battle).
        to receive(:dice_roll).and_return(2, 1)

      faction.hand << Root::Cards::Base.new(suit: :rabbit)
      faction.initiate_battle_with_faction(clearings[:five], bird_faction)

      expect(faction.hand.count).to eq(0)
      expect(clearings[:one].meeples_of_type(:cats).count).to eq(1)
    end

    it 'allows players to say :no:' do
      allow(player).to receive(:pick_option).and_return(1)

      faction.place_keep(clearings[:one])
      faction.place_meeple(clearings[:five])
      faction.place_meeple(clearings[:five])
      bird_faction.place_meeple(clearings[:five])
      bird_faction.place_meeple(clearings[:five])

      allow_any_instance_of(Root::Actions::Battle).
        to receive(:dice_roll).and_return(2, 1)

      faction.hand << Root::Cards::Base.new(suit: :rabbit)
      faction.initiate_battle_with_faction(clearings[:five], bird_faction)

      expect(faction.hand.count).to eq(1)
      expect(clearings[:one].meeples_of_type(:cats).count).to eq(0)
    end

    it 'does not happen when no matching cards in hand' do
      faction.place_keep(clearings[:one])
      faction.place_meeple(clearings[:five])
      faction.place_meeple(clearings[:five])
      bird_faction.place_meeple(clearings[:five])
      bird_faction.place_meeple(clearings[:five])

      allow_any_instance_of(Root::Actions::Battle).
        to receive(:dice_roll).and_return(2, 1)

      faction.initiate_battle_with_faction(clearings[:five], bird_faction)

      expect(clearings[:one].meeples_of_type(:cats).count).to eq(0)
    end
  end

  describe '#victory_points=' do
    context 'when below 30 and will not be at 30' do
      it 'just bumps it up' do
        faction.victory_points = 0
        faction.victory_points += 2

        expect(faction.victory_points).to eq(2)
      end
    end

    context 'when below 30 and will go to 30 or higher' do
      it 'raises an "error" to end the game' do
        faction.victory_points = 29

        expect { faction.victory_points += 2 }
          .to raise_error(Root::Errors::WinConditionReached)
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
end
