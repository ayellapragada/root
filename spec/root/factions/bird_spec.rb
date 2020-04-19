# frozen_string_literal: true

RSpec.describe Root::Factions::Bird do
  describe '#handle_faction_token_setup' do
    it 'gives faction 20 meeples, 7 roosts, 2 loyal viziers, and 4 leaders' do
      player = Root::Players::Human.for('Sneak', :birds)
      birds = player.faction

      expect(birds.meeples.count).to eq(20)
      expect(birds.roosts.count).to eq(7)
      expect(birds.viziers.count).to eq(2)
      leaders = birds.leaders.map(&:leader)
      expect(leaders).to match_array(%i[builder charismatic commander despot])
    end
  end

  describe '#setup' do
    context 'when there is a keep on the board' do
      it 'sets up opposite to keep' do
        board = Root::Boards::Base.new
        cat_player = Root::Players::Human.for('Other', :cats)
        cat_player.board = board
        cat_faction = cat_player.faction
        allow(cat_player).to receive(:pick_option).and_return(0)
        cat_faction.build_keep

        player = Root::Players::Human.for('Sneak', :birds)
        player.board = board
        allow(player).to receive(:pick_option).and_return(0)
        player.setup

        initial_bird_clearing = board.clearing_across_from_keep
        initial_meeples = initial_bird_clearing.meeples
        expect(initial_bird_clearing.includes_building?(:roost)).to be true
        expect(has_only_six_bird_warriors(initial_meeples)).to be true
      end
    end

    context 'when there is not a keep on the board' do
      it 'sets up in a corner it chooses' do
        player = Root::Players::Human.for('Sneak', :birds)
        board = player.board
        allow(player).to receive(:pick_option).and_return(0)

        player.setup

        initial_bird_clearing = board.corner_with_roost
        initial_meeples = initial_bird_clearing.meeples
        expect(initial_bird_clearing.includes_building?(:roost)).to be true
        expect(has_only_six_bird_warriors(initial_meeples)).to be true
      end
    end

    it 'lets player picks a starting leader' do
      cat_faction = Root::Players::Computer.for('Other', :cats).faction
      cat_faction.build_keep

      player = Root::Players::Human.for('Sneak', :birds)
      allow(player).to receive(:pick_option).and_return(0)
      birds = player.faction

      expect(birds.current_leader).to be_nil
      player.setup
      expect(birds.current_leader).not_to be nil
    end

    it 'starts initial decree for player with viziers' do
      cat_faction = Root::Players::Computer.for('Other', :cats).faction
      cat_faction.build_keep

      player = Root::Players::Human.for('Sneak', :birds)
      birds = player.faction
      allow(player).to receive(:pick_option).and_return(0)
      expect(birds.decree).to be_empty

      player.setup

      expect(birds.decree.suits_in(:recruit)).to eq([:bird])
      expect(birds.decree.suits_in(:move)).to eq([:bird])
    end
  end

  describe '#change_current_leader' do
    context 'when not given a leader to switch to' do
      it 'removes current leader and picks a new one' do
        player = Root::Players::Human.for('Sneak', :birds)
        birds = player.faction
        allow(player).to receive(:pick_option).and_return(0)
        expect(birds.current_leader).to be nil

        birds.change_current_leader
        expect(birds.current_leader).not_to be nil
        old_leader = birds.current_leader
        birds.change_current_leader
        expect(birds.current_leader).not_to be old_leader
        expect(birds.used_leaders).to match_array([old_leader])
        birds.change_current_leader
        birds.change_current_leader
        expect(birds.used_leaders.count).to eq(3)
        birds.change_current_leader
        expect(birds.used_leaders.count).to eq(0)
      end
    end

    context 'when given a leader to switch to' do
      it 'switches current leader to given one' do
        birds = Root::Players::Computer.for('Sneak', :birds).faction
        expect(birds.current_leader).to be nil

        birds.change_current_leader(:despot)
        expect(birds.current_leader.leader).to eq(:despot)
        birds.change_current_leader(:builder)

        expect(birds.current_leader.leader).to eq(:builder)
        expect(birds.used_leaders.first.leader).to eq(:despot)
      end
    end
  end

  describe '#change_viziers_with_leader' do
    it 'sets the viziers into the decree based off leader' do
      birds = Root::Players::Computer.for('Sneak', :birds).faction
      birds.change_current_leader(:despot)

      birds.change_viziers_with_leader

      expect(birds.decree.suits_in_decree).to eq(
        recruit: [],
        move: [:bird],
        battle: [],
        build: [:bird]
      )
    end
  end

  describe '#take_turn' do
    xit 'goes through all phases of a turn' do
      game = Root::Game.default_game(with_computers: true)
      player = game.players.fetch_player(:birds)
      allow(player).to receive(:pick_option).and_return(0)
      game.setup

      expect { player.faction.take_turn(players: game.players) }
        .to change(player, :inspect)
    end
  end

  describe '#birdsong' do
    it 'adds a card to the decree' do
      player, faction = build_player_and_faction(:birds)
      allow(player).to receive(:pick_option).and_return(0)
      card = Root::Cards::Base.new(suit: :fox)
      faction.hand << card

      expect { faction.birdsong }
        .to change(faction.decree, :size)
        .by(1)
        .and change(faction, :hand_size)
        .by(-1)
    end

    context 'when adding two cards to the decree' do
      it 'only allows one card added to be a bird' do
        player, faction = build_player_and_faction(:birds)
        allow(player).to receive(:pick_option).and_return(0)
        card1 = Root::Cards::Base.new(suit: :bird)
        card2 = Root::Cards::Base.new(suit: :bird)
        card3 = Root::Cards::Base.new(suit: :fox)

        faction.hand << card1
        faction.hand << card2
        faction.hand << card3

        faction.birdsong

        expect(faction.decree.suits_in(:recruit)).to eq(%i[bird fox])
      end
    end

    context 'when able to add 2, but only adding 1' do
      it 'skips second step of adding to decree' do
        player, faction = build_player_and_faction(:birds)
        # Pick first card, pick recruit, then pick none
        allow(player).to receive(:pick_option).and_return(0, 0, 1)
        card1 = Root::Cards::Base.new(suit: :fox)
        card2 = Root::Cards::Base.new(suit: :mouse)
        faction.hand << card1
        faction.hand << card2

        expect { faction.birdsong }
          .to change(faction.decree, :size)
          .by(1)
          .and change(faction, :hand_size)
          .by(-1)
      end
    end

    context 'when hand is empty' do
      it 'draws a card' do
        player, faction = build_player_and_faction(:birds)
        allow(player).to receive(:pick_option).and_return(0)

        expect { faction.birdsong }.to change(faction.decree, :size).by(1)
      end
    end

    context 'when no roosts on the board' do
      it 'places roost and 3 warriors into clearing with fewest pieces' do
        player, faction = build_player_and_faction(:birds)
        cat_faction = Root::Players::Computer.for('Hal', :cats).faction
        clearings = player.board.clearings

        cat_faction.place_meeple(clearings[:one])
        cat_faction.place_meeple(clearings[:two])
        cat_faction.place_meeple(clearings[:three])

        expect { faction.birdsong }
          .to change(faction.buildings, :count)
          .by(-1)
          .and change(faction.meeples, :count)
          .by(-3)
      end
    end
  end

  describe '#evening' do
    it 'gains victory points and draws cards' do
      player, faction = build_player_and_faction(:birds)
      clearings = player.board.clearings

      faction.place_roost(clearings[:one])
      faction.place_roost(clearings[:two])
      faction.place_roost(clearings[:three])

      expect { faction.evening }
        .to change(faction, :victory_points)
        .by(2)
        .and change(faction, :hand_size)
        .by(2)
    end
  end

  context 'when in recruit' do
    it 'recruits in any valid roosts any number of times' do
      player, faction = build_player_and_faction(:birds)
      allow(player).to receive(:pick_option).and_return(0)
      clearings = player.board.clearings

      faction.place_roost(clearings[:one])
      faction.place_roost(clearings[:five])

      faction.decree[:recruit] << Root::Cards::Base.new(suit: :fox)
      faction.decree[:recruit] << Root::Cards::Base.new(suit: :fox)
      faction.decree[:recruit] << Root::Cards::Base.new(suit: :bunny)

      expect { faction.resolve_decree }
        .to change(faction.meeples, :count)
        .by(-3)
      expect(clearings[:one].meeples_of_type(:birds).count).to eq(2)
      expect(clearings[:five].meeples_of_type(:birds).count).to eq(1)
    end

    context 'when hand has a bird card' do
      it 'uses the bird card as a wild card' do
        player, faction = build_player_and_faction(:birds)
        allow(player).to receive(:pick_option).and_return(0)
        clearings = player.board.clearings

        faction.place_roost(clearings[:one])

        faction.decree[:recruit] << Root::Cards::Base.new(suit: :bird)

        faction.resolve_decree
        expect(clearings[:one].meeples_of_type(:birds).count).to eq(1)
      end
    end

    # This is for charismatic leader and recruit with 1 meeple left
    context 'when unable to recruit' do
      it 'goes into turmoil' do
        player, faction = build_player_and_faction(:birds)
        allow(player).to receive(:pick_option).and_return(0)
        clearings = player.board.clearings

        faction.place_meeple(clearings[:one])

        faction.decree[:move] << Root::Cards::Base.new(suit: :bunny)

        expect { faction.resolve_move }
          .to raise_error { Root::Factions::TurmoilError }
      end

      it 'goes into turmoil if not able to complete completely' do
        player, faction = build_player_and_faction(:birds)
        allow(player).to receive(:pick_option).and_return(0)
        clearings = player.board.clearings

        faction.place_roost(clearings[:one])
        19.times { faction.place_meeple(clearings[:one]) }
        faction.change_current_leader(:charismatic)

        faction.decree[:recruit] << Root::Cards::Base.new(suit: :fox)

        expect { faction.resolve_recruit }
          .to raise_error { Root::Factions::TurmoilError }
      end
    end

    context 'when leader is charismatic' do
      it 'recruits twice' do
        player, faction = build_player_and_faction(:birds)
        allow(player).to receive(:pick_option).and_return(0)
        clearings = player.board.clearings

        faction.place_roost(clearings[:one])

        faction.change_current_leader(:charismatic)
        faction.decree[:recruit] << Root::Cards::Base.new(suit: :fox)

        expect { faction.resolve_recruit }
          .to change(faction.meeples, :count).by(-2)
      end
    end
  end

  context 'when in move' do
    it 'must move FROM clearings matching that suit' do
      player, faction = build_player_and_faction(:birds)
      allow(player).to receive(:pick_option).and_return(0)
      clearings = player.board.clearings

      faction.place_meeple(clearings[:one])
      faction.place_meeple(clearings[:two])

      faction.decree[:move] << Root::Cards::Base.new(suit: :fox)
      faction.decree[:move] << Root::Cards::Base.new(suit: :mouse)

      faction.resolve_decree

      expect(clearings[:one].meeples_of_type(:birds).count).to eq(0)
      expect(clearings[:two].meeples_of_type(:birds).count).to eq(0)
    end
  end

  context 'when in build' do
    it 'must build in ruled clearings without a roost' do
      player, faction = build_player_and_faction(:birds)
      allow(player).to receive(:pick_option).and_return(0)
      cat_player = Root::Players::Computer.for('Other', :cats)
      cat_player.board = player.board
      cat_faction = cat_player.faction

      clearings = player.board.clearings
      faction.place_meeple(clearings[:one])
      cat_faction.place_meeple(clearings[:one])

      faction.place_meeple(clearings[:six])

      faction.decree[:build] << Root::Cards::Base.new(suit: :fox)

      faction.resolve_decree

      expect(clearings[:six].buildings_of_type(:roost).count).to eq(0)
      expect(clearings[:one].buildings_of_type(:roost).count).to eq(1)
    end

    context 'when roost is already there' do
      it 'goes into turmoil' do
        player, faction = build_player_and_faction(:birds)
        allow(player).to receive(:pick_option).and_return(0)
        clearings = player.board.clearings

        faction.place_roost(clearings[:one])

        faction.decree[:build] << Root::Cards::Base.new(suit: :fox)

        expect { faction.resolve_build }
          .to raise_error { Root::Factions::TurmoilError }
      end
    end

    context 'when out of buildings to build' do
      it 'goes into turmoil' do
        player, faction = build_player_and_faction(:birds)
        allow(player).to receive(:pick_option).and_return(0)
        clearings = player.board.clearings

        faction.place_roost(clearings[:one])
        faction.place_roost(clearings[:two])
        faction.place_roost(clearings[:two])
        faction.place_roost(clearings[:three])
        faction.place_roost(clearings[:five])
        faction.place_roost(clearings[:five])
        faction.place_roost(clearings[:six])

        faction.place_meeple(clearings[:twelve])
        faction.decree[:build] << Root::Cards::Base.new(suit: :fox)

        expect { faction.resolve_build }
          .to raise_error { Root::Factions::TurmoilError }
      end
    end
  end

  context 'when in battle' do
    it 'must battle in clearings that match the suit' do
      player, faction = build_player_and_faction(:birds)
      allow(player).to receive(:pick_option).and_return(0)
      allow_any_instance_of(Root::Actions::Battle).
        to receive(:dice_roll).and_return(2, 1)

      cat_player = Root::Players::Human.for('Other', :cats)
      cat_player.board = player.board
      cat_faction = cat_player.faction
      players = Root::Players::List.new(player, cat_player)

      clearings = player.board.clearings
      battle_cl = clearings[:one]
      faction.place_meeple(battle_cl)
      cat_faction.place_meeple(battle_cl)

      faction.place_meeple(clearings[:two])
      cat_faction.place_meeple(clearings[:two])

      faction.decree[:battle] << Root::Cards::Base.new(suit: battle_cl.suit)

      faction.resolve_decree(players)

      expect(clearings[:one].meeples.count).to eq(0)
      expect(clearings[:two].meeples.count).to eq(2)
    end

    context 'with commander as leader' do
      it 'does one extra damage as attacker' do
        player, faction = build_player_and_faction(:birds)
        allow(player).to receive(:pick_option).and_return(0)

        cat_player = Root::Players::Human.for('Other', :cats)
        cat_player.board = player.board
        cat_faction = cat_player.faction
        players = Root::Players::List.new(player, cat_player)

        clearings = player.board.clearings

        battle_cl = clearings[:one]

        faction.place_meeple(battle_cl)
        faction.place_meeple(battle_cl)
        cat_faction.place_meeple(battle_cl)
        cat_faction.place_meeple(battle_cl)

        allow_any_instance_of(Root::Actions::Battle).
          to receive(:dice_roll).and_return(1, 0)

        faction.change_current_leader(:commander)
        faction.decree[:battle] << Root::Cards::Base.new(suit: battle_cl.suit)

        faction.resolve_decree(players)

        expect(clearings[:one].meeples_of_type(:cats).count).to eq(0)
      end
    end

    context 'with despot as leader' do
      it 'score one extra point on removing building' do
        player, faction = build_player_and_faction(:birds)
        cat_player, cat_faction = build_player_and_faction(:cats)
        cat_player.board = player.board
        allow(player).to receive(:pick_option).and_return(0)
        allow(cat_player).to receive(:pick_option).and_return(0)

        players = Root::Players::List.new(player, cat_player)

        clearings = player.board.clearings

        battle_cl = clearings[:one]

        faction.place_meeple(battle_cl)
        cat_faction.place_sawmill(battle_cl)

        allow_any_instance_of(Root::Actions::Battle).
          to receive(:dice_roll).and_return(2, 0)

        faction.change_current_leader(:despot)
        faction.decree[:battle] << Root::Cards::Base.new(suit: battle_cl.suit)

        expect { faction.resolve_decree(players) }
          .to change(faction, :victory_points).by(2)
      end

      it 'score one extra point on removing token' do
        player, faction = build_player_and_faction(:birds)
        cat_player, cat_faction = build_player_and_faction(:cats)
        cat_player.board = player.board
        allow(player).to receive(:pick_option).and_return(0)
        allow(cat_player).to receive(:pick_option).and_return(0)

        players = Root::Players::List.new(player, cat_player)

        clearings = player.board.clearings

        battle_cl = clearings[:one]

        faction.place_meeple(battle_cl)
        cat_faction.place_wood(battle_cl)

        allow_any_instance_of(Root::Actions::Battle).
          to receive(:dice_roll).and_return(2, 0)

        faction.change_current_leader(:despot)
        faction.decree[:battle] << Root::Cards::Base.new(suit: battle_cl.suit)

        expect { faction.resolve_decree(players) }
          .to change(faction, :victory_points).by(2)
      end

      it 'does not score one extra point on removing meeple' do
        player, faction = build_player_and_faction(:birds)
        cat_player, cat_faction = build_player_and_faction(:cats)
        cat_player.board = player.board
        allow(player).to receive(:pick_option).and_return(0)
        allow(cat_player).to receive(:pick_option).and_return(0)

        players = Root::Players::List.new(player, cat_player)

        clearings = player.board.clearings

        battle_cl = clearings[:one]

        faction.place_meeple(battle_cl)
        cat_faction.place_meeple(battle_cl)

        allow_any_instance_of(Root::Actions::Battle).
          to receive(:dice_roll).and_return(2, 0)

        faction.change_current_leader(:despot)
        faction.decree[:battle] << Root::Cards::Base.new(suit: battle_cl.suit)

        expect { faction.resolve_decree(players) }
          .to change(faction, :victory_points).by(0)
      end
    end
  end

  describe '#turmoil!' do
    it 'reduces victory_points, clears decree, and resets leader + viziers' do
      player, faction = build_player_and_faction(:birds)
      allow(player).to receive(:pick_option).and_return(0)

      faction.victory_points = 5
      faction.decree[:recruit] << Root::Cards::Base.new(suit: :fox)
      faction.decree[:build] << Root::Cards::Base.new(suit: :bird)
      faction.decree[:build] << Root::Cards::Base.new(suit: :bird)

      expect { faction.resolve_decree }
        .to change(faction, :victory_points)
        .by(-2)
        .and change(faction, :current_leader)
        .and change(faction, :decree)
    end

    context 'when points lost is greater than current points' do
      it 'does not go below zero' do
        player, faction = build_player_and_faction(:birds)
        allow(player).to receive(:pick_option).and_return(0)

        faction.victory_points = 0
        faction.decree[:build] << Root::Cards::Base.new(suit: :bird)

        expect { faction.resolve_decree }
          .to change(faction, :victory_points)
          .by(0)
      end
    end
  end

  describe '#craft_items' do
    # DISDAIN FOR TRADE WOO
    it 'crafts card, removes from board and adds victory points' do
      player, faction = build_player_and_faction(:birds)
      allow(player).to receive(:pick_option).and_return(0)

      faction.place_roost(player.board.clearings[:one])

      card_to_craft = Root::Cards::Item.new(
        suit: :fox,
        craft: %i[fox],
        item: :tea,
        vp: 2
      )
      card_unable_to_be_crafted = Root::Cards::Item.new(
        suit: :fox,
        craft: %i[fox],
        item: :coin,
        vp: 1
      )

      faction.hand << card_to_craft
      faction.hand << card_unable_to_be_crafted

      faction.craft_items
      expect(faction.hand).not_to include(card_to_craft)
      expect(faction.hand).to include(card_unable_to_be_crafted)
      expect(faction.victory_points).to be(1)
      expect(faction.items).to include(:tea)
    end

    context 'when builder is leader' do
      it 'actually uses the items VP' do
        player, faction = build_player_and_faction(:birds)
        allow(player).to receive(:pick_option).and_return(0)

        faction.change_current_leader(:builder)
        faction.place_roost(player.board.clearings[:one])

        card_to_craft = Root::Cards::Item.new(
          suit: :fox,
          craft: %i[fox],
          item: :tea,
          vp: 2
        )
        card_unable_to_be_crafted = Root::Cards::Item.new(
          suit: :fox,
          craft: %i[fox],
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
  end

  describe '#discard_from_decree' do
    it 'discards cards to the decks discard pile' do
      player, faction = build_player_and_faction(:birds)
      allow(player).to receive(:pick_option).and_return(0)

      vizier = Root::Factions::Birds::Vizier.new
      card1 = Root::Cards::Base.new(suit: :bunny)
      card2 = Root::Cards::Base.new(suit: :bunny)
      faction.decree[:move] << card1
      faction.decree[:move] << card2
      faction.decree[:recruit] << vizier

      expect { faction.discard_from_decree }
        .to change(faction.deck.discard, :count).by(2)
      expect(faction.deck.discard).to match_array([card1, card2])
    end
  end

  describe '#special_info' do
    it 'shows the roosts board and decree' do
      player, faction = build_player_and_faction(:birds)
      clearings = player.board.clearings

      faction.decree[:move] << Root::Cards::Base.new(suit: :bunny)
      faction.decree[:move] << Root::Cards::Base.new(suit: :fox)
      faction.decree[:recruit] << Root::Cards::Base.new(suit: :mouse)
      faction.decree[:battle] << Root::Cards::Base.new(suit: :bird)

      faction.place_roost(clearings[:one])
      faction.place_roost(clearings[:five])
      faction.place_roost(clearings[:five])
      faction.items << :tea
      faction.items << :sword

      expect(faction.special_info(true)).to eq(
        board: {
          title: "Lords of the Forest | Disdain for Trade \nNo Leader | Tea, Sword",
          rows: [['Roosts', '0', '1', '2(+1)', 'R', 'R', 'R', 'R']]
        },
        decree: {
          headings: %w[Recruit Move Battle Build],
          rows: [
            ['Mouse', 'Fox', 'Bird', ''],
            ['', 'Bunny', '', '']
          ]
        },
      )
    end

    it 'shows current leader' do
      player, faction = build_player_and_faction(:birds)

      faction.change_current_leader(:despot)

      expect(faction.special_info(true)).to eq(
        board: {
          title: "Lords of the Forest | Disdain for Trade \nDespot | No items",
          rows: [%w[Roosts R R R R R R R]]
        },
        decree: {
          headings: %w[Recruit Move Battle Build],
          rows: []
        },
      )
    end
  end

  def has_only_six_bird_warriors(meeples)
    meeples.count == 6 && meeples.all? { |w| w.faction == :birds }
  end
end
