# frozen_string_literal: true

RSpec.describe Root::Factions::Racoon do
  let(:player) { Root::Players::Computer.for('Sneak', :racoon) }
  let(:faction) { player.faction }
  let(:board) { player.board }
  let(:clearings) { board.clearings }
  let(:forests) { board.forests }
  let(:mouse_player) { Root::Players::Computer.for('Bird', :mice) }
  let(:mouse_faction) { mouse_player.faction }
  let(:bird_player) { Root::Players::Computer.for('Bird', :birds) }
  let(:bird_faction) { bird_player.faction }
  let(:cat_player) { Root::Players::Computer.for('Cat', :cats) }
  let(:cat_faction) { cat_player.faction }

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
      characters = game.characters
      players = game.players
      player = players.fetch_player(:racoon)
      allow(player).to receive(:pick_option).and_return(0)

      player.setup(characters: characters, players: players)
      faction = player.faction

      # the first options name, ah well.
      expect(faction.character.name).to be(:thief)
      expect(faction.items.map(&:item)).to eq(%i[boots torch tea sword])
    end

    it 'selects a forest clearing to start in' do
      game = Root::Game.default_game
      board = game.board
      characters = game.characters
      players = game.players
      player = players.fetch_player(:racoon)
      allow(player).to receive(:pick_option).and_return(0)

      player.setup(characters: characters, players: players)

      expect(board.forests[:a].meeples_of_type(:racoon).count == 1).to be true
    end

    it 'sets up the relationships with other factions to neutral' do
      game = Root::Game.default_game
      characters = game.characters
      players = game.players
      player = players.fetch_player(:racoon)
      allow(player).to receive(:pick_option).and_return(0)

      player.setup(characters: characters, players: players)

      faction = player.faction
      expect(faction.relationships.all_neutral?).to be true
    end

    it 'sets up 4 ruins with item cards' do
      game = Root::Game.default_game
      board = game.board
      characters = game.characters
      players = game.players
      player = players.fetch_player(:racoon)
      allow(player).to receive(:pick_option).and_return(0)

      player.setup(characters: characters, players: players)

      expect(board.ruins.all?(&:contains_item?)).to be true
    end
  end

  describe '#special_info' do
    it 'returns special stats, relationships, and items' do
      game = Root::Game.default_game
      characters = game.characters
      players = game.players
      player = players.fetch_player(:racoon)
      allow(player).to receive(:pick_option).and_return(0)

      player.setup(characters: characters, players: players)
      faction = player.faction
      expect(faction.special_info(true)).to eq(
        {
          board: {
            title: "Thief | Nimble | Lone Wanderer\n1 tea(s) | 0 coin(s) | 0 satchel(s)\nStatus: Mice: 0 | Cats: 0 | Birds: 0",
            rows:  [['Boots, Sword, Torch']]
          }
        }
      )
    end

    context 'without a character' do
      it 'returns none correctly' do
        expect(faction.formatted_character).to eq('None')
      end
    end

    context 'with a character' do
      it 'returns character name correctly' do
        faction.quick_set_character('Thief')
        expect(faction.formatted_character).to eq('Thief')
      end
    end
  end

  describe '#formatted_items' do
    context 'when having no items' do
      it { expect(faction.formatted_items).to eq(['No Items']) }
    end

    context 'with undamaged unexhausted items' do
      it 'renders just the name without status' do
        faction.craft_item(build_item(:hammer))
        faction.craft_item(build_item(:boots))
        expect(faction.formatted_items).to eq(['Boots, Hammer'])
      end
    end

    context 'with exhausted items' do
      it 'renders just the name with the status as part of normal items' do
        faction.craft_item(build_item(:hammer))
        faction.craft_item(build_item(:boots))

        faction.exhaust_item(:boots)
        expect(faction.formatted_items).to eq(['Hammer, Boots (E)'])
      end
    end

    context 'with any damaged items' do
      it 'puts on a different line than undamaged items' do
        faction.craft_item(build_item(:sword))
        faction.craft_item(build_item(:satchel))
        faction.craft_item(build_item(:hammer))

        faction.damage_item(:hammer)

        expect(faction.formatted_items)
          .to eq(['Sword, Hammer (D)'])
      end
    end

    context 'with exhausted and damaged_items' do
      it 'shows both in status message' do
        faction.craft_item(build_item(:sword))
        faction.craft_item(build_item(:satchel))
        faction.craft_item(build_item(:coin))
        faction.craft_item(build_item(:hammer))

        faction.exhaust_item(:coin)

        faction.exhaust_item(:hammer)
        faction.damage_item(:hammer)

        expect(faction.formatted_items)
          .to eq(['Sword, Coin (E), Hammer (ED)'])
      end
    end

    context 'with way too many items' do
      it 'puts onto new lines' do
        Root::Boards::ItemsGenerator.generate.each do |item|
          faction.craft_item(build_item(item))
          faction.exhaust_item(item)
          faction.damage_item(item)
        end

        expect(faction.formatted_items.first.split("\n").count).to eq(3)
      end
    end
  end

  describe '#formatted_relationships' do
    context 'without relationships' do
      it { expect(faction.formatted_relationships).to eq('No Status') }
    end
  end

  describe '#max_hit' do
    it 'is equal to the number of undamaged swords' do
      expect(faction.max_hit).to eq(0)

      faction.craft_item(build_item(:sword))
      expect(faction.max_hit).to eq(1)

      faction.craft_item(build_item(:sword))
      expect(faction.max_hit).to eq(2)

      faction.exhaust_item(:sword)
      faction.exhaust_item(:sword)
      expect(faction.max_hit).to eq(2)

      faction.damage_item(:sword)
      expect(faction.max_hit).to eq(1)
    end
  end

  describe '#take_damage' do
    it 'lets the user pick which items to damage' do
      allow(player).to receive(:pick_option).and_return(0)
      allow(cat_player).to receive(:pick_option).and_return(0)
      cat_player.board = board

      faction.craft_item(build_item(:sword))
      faction.craft_item(build_item(:boots))
      faction.craft_item(build_item(:hammer))

      players = Root::Players::List.new(player, cat_player)

      battle_cl = clearings[:one]

      faction.place_meeple(battle_cl)
      cat_faction.place_meeple(battle_cl)
      cat_faction.place_meeple(battle_cl)

      allow_any_instance_of(Root::Actions::Battle)
        .to receive(:dice_roll).and_return(2, 0)

      expect { cat_faction.battle(players) }
        .to change { faction.damaged_items.count }
        .by(2)
    end

    context 'when no items to damage' do
      it 'just moves on' do
        allow(player).to receive(:pick_option).and_return(0)
        allow(cat_player).to receive(:pick_option).and_return(0)
        cat_player.board = board

        players = Root::Players::List.new(player, cat_player)

        battle_cl = clearings[:one]

        faction.place_meeple(battle_cl)
        cat_faction.place_meeple(battle_cl)

        allow_any_instance_of(Root::Actions::Battle)
          .to receive(:dice_roll).and_return(1, 0)

        expect { cat_faction.battle(players) }
          .to change { faction.damaged_items.count }
          .by(0)
      end
    end
  end

  describe '#refresh_items' do
    context 'with no tea' do
      it 'refreshes 3 items' do
        faction.craft_item(build_item(:hammer))
        faction.craft_item(build_item(:sword))
        faction.craft_item(build_item(:sword))

        faction.exhaust_item(:hammer)
        faction.exhaust_item(:sword)
        faction.exhaust_item(:sword)

        expect { faction.refresh_items }
          .to change { faction.exhausted_items.count }
          .by(-3)
      end
    end

    context 'with tea' do
      it 'refreshes 3 items + 2 per tea' do
        faction.craft_item(build_item(:hammer))
        faction.craft_item(build_item(:sword))
        faction.craft_item(build_item(:sword))
        faction.craft_item(build_item(:boots))
        faction.craft_item(build_item(:boots))

        faction.exhaust_item(:hammer)
        faction.exhaust_item(:sword)
        faction.exhaust_item(:sword)
        faction.exhaust_item(:boots)
        faction.exhaust_item(:boots)

        faction.craft_item(build_item(:tea))

        expect { faction.refresh_items }
          .to change { faction.exhausted_items.count }
          .by(-5)
      end
    end

    context 'when more items are exhausted than tea' do
      it 'lets player pick which ones to refresh' do
        allow(player).to receive(:pick_option).and_return(0)

        faction.craft_item(build_item(:hammer))
        faction.craft_item(build_item(:sword))
        faction.craft_item(build_item(:sword))
        faction.craft_item(build_item(:boots))
        faction.craft_item(build_item(:boots))

        faction.exhaust_item(:hammer)
        faction.exhaust_item(:sword)
        faction.exhaust_item(:sword)
        faction.exhaust_item(:boots)
        faction.exhaust_item(:boots)

        expect { faction.refresh_items }
          .to change { faction.exhausted_items.count }
          .by(-3)
      end
    end
  end

  describe '#refresh_item_options' do
    it 'selects all exhausted items even if damaged' do
      faction.craft_item(build_item(:hammer))
      faction.craft_item(build_item(:crossbow))
      faction.craft_item(build_item(:sword))
      faction.craft_item(build_item(:boots))
      faction.craft_item(build_item(:coin))

      faction.exhaust_item(:crossbow)
      faction.exhaust_item(:sword)
      faction.exhaust_item(:boots)
      faction.exhaust_item(:coin)
      faction.damage_item(:coin)

      faction.damage_item(:hammer)

      expect(faction.refresh_item_options.map(&:item))
        .to eq(%i[crossbow sword boots coin])
    end
  end

  describe '#slip_options' do
    it 'includes adjacent forests and clearings' do
      faction.place_meeple(forests[:a])

      expect(faction.slip_options).to eq(
        [
          forests[:b], forests[:c],
          clearings[:one], clearings[:two], clearings[:five], clearings[:ten]
        ]
      )
    end
  end

  describe '#slip' do
    it 'is a move that can alsp go into forests' do
      faction.place_meeple(forests[:a])
      players = Root::Players::List.new(player)
      allow(player).to receive(:pick_option).and_return(0)

      faction.slip(players)

      expect(faction.current_location).to eq(forests[:b])
    end
  end

  describe '#nimble' do
    it 'can move regardless of rule' do
      faction.place_meeple(clearings[:one])
      faction.craft_item(build_item(:boots))
      2.times { cat_faction.place_meeple(clearings[:one]) }
      2.times { cat_faction.place_meeple(clearings[:five]) }
      2.times { cat_faction.place_meeple(clearings[:nine]) }
      2.times { cat_faction.place_meeple(clearings[:ten]) }

      expect(faction.clearing_move_options(clearings[:one]))
        .to eq([clearings[:five], clearings[:nine], clearings[:ten]])
    end
  end

  describe '#can_move?' do
    it 'needs a valid boot' do
      faction.place_meeple(clearings[:one])

      faction.craft_item(build_item(:boots))

      expect(faction.can_move?).to be true
    end
  end

  describe '#can_move_to?' do
    context 'with a hostile enemy in the clearing' do
      it 'needs two boots' do
        players = Root::Players::List.new(player, cat_player)
        faction.handle_relationships(players)
        faction.relationships.make_hostile(:cats)

        from_cl = clearings[:one]
        to_cl = clearings[:five]
        faction.place_meeple(from_cl)
        cat_faction.place_meeple(to_cl)

        faction.craft_item(build_item(:boots))
        expect(faction.can_move_to?(from_cl, to_cl)).to be false

        faction.craft_item(build_item(:boots))
        expect(faction.can_move_to?(from_cl, to_cl)).to be true
      end
    end
  end

  describe '#move_options' do
    it 'takes 2 boots to move into a hostile clearing' do
      allow(player).to receive(:pick_option).and_return(0)
      players = Root::Players::List.new(player, cat_player)
      faction.handle_relationships(players)
      faction.relationships.make_hostile(:cats)

      from_cl = clearings[:one]
      faction.place_meeple(from_cl)
      cat_faction.place_meeple(clearings[:nine])
      cat_faction.place_meeple(clearings[:ten])

      faction.make_item(:boots)

      expect(faction.move_options).to eq([clearings[:five]])
    end
  end

  describe '#boots_move' do
    context 'when hostiles in enemy territory' do
      it 'exhausts an extra boots' do
        allow(player).to receive(:pick_option).and_return(0)
        players = Root::Players::List.new(player, cat_player)
        faction.handle_relationships(players)
        faction.relationships.make_hostile(:cats)

        from_cl = clearings[:one]
        faction.place_meeple(from_cl)
        cat_faction.place_meeple(clearings[:five])
        cat_faction.place_meeple(clearings[:nine])
        cat_faction.place_meeple(clearings[:ten])

        faction.make_item(:boots)
        faction.make_item(:boots)

        faction.boots_move(players)

        expect(faction.exhausted_items.count).to eq(1)
      end
    end
  end

  describe '#can_racoon_battle?' do
    it 'needs a undamaged and unexhausted sword' do
      faction.place_meeple(clearings[:one])
      cat_faction.place_meeple(clearings[:one])
      expect(faction.can_racoon_battle?).to be false

      faction.craft_item(build_item(:sword))

      expect(faction.can_racoon_battle?).to be true
    end

    context 'with damaged sword' do
      it 'can not battle' do
        faction.place_meeple(clearings[:one])
        cat_faction.place_meeple(clearings[:one])

        faction.craft_item(build_item(:sword))
        faction.exhaust_item(:sword)

        expect(faction.can_racoon_battle?).to be false
      end
    end

    context 'with exhausted sword' do
      it 'can not battle' do
        faction.place_meeple(clearings[:one])
        cat_faction.place_meeple(clearings[:one])

        faction.craft_item(build_item(:sword))
        faction.damage_item(:sword)

        expect(faction.can_racoon_battle?).to be false
      end
    end
  end

  describe '#can_explore?' do
    context 'with a torch in a clearing with a ruin' do
      it 'can explore' do
        faction.place_meeple(clearings[:ten])
        faction.make_item(:torch)

        expect(faction.can_explore?).to be true
      end
    end

    context 'without a torch in a clearing with a ruin' do
      it 'can not explore' do
        faction.place_meeple(clearings[:ten])

        expect(faction.can_explore?).to be false
      end
    end

    context 'with a torch in a clearing without a ruin' do
      it 'can not explore' do
        faction.place_meeple(clearings[:one])
        faction.make_item(:torch)

        expect(faction.can_explore?).to be false
      end
    end
  end

  describe '#explore' do
    it 'explores a ruin taking an item from it' do
      faction.place_meeple(clearings[:ten])

      expect { faction.explore }.to change(faction, :victory_points).by(1)
      expect(faction.available_items.count).to eq(1)
    end
  end

  describe '#with_item' do
    it 'exhausts an item if used' do
      allow(player).to receive(:pick_option).and_return(0)
      quests = Root::Factions::Racoons::Quests.new
      players = Root::Players::List.new(player)
      faction.place_meeple(clearings[:one])
      faction.craft_item(build_item(:boots))

      faction.daylight(players, quests)

      expect(faction.exhausted_items.map(&:item)).to eq([:boots])
    end

    it 'does not exhaust the item if action canceled' do
      allow(player).to receive(:pick_option).and_return(0, 3, 1)
      quests = Root::Factions::Racoons::Quests.new
      players = Root::Players::List.new(player)
      faction.place_meeple(clearings[:one])
      faction.craft_item(build_item(:boots))

      faction.daylight(players, quests)

      expect(faction.exhausted_items.map(&:item)).to eq([])
    end
  end

  describe '#can_strike?' do
    it 'needs a undamaged and unexhausted crossbow' do
      faction.place_meeple(clearings[:one])
      cat_faction.place_meeple(clearings[:one])
      expect(faction.can_strike?).to be false

      faction.craft_item(build_item(:crossbow))

      expect(faction.can_strike?).to be true
    end
  end

  describe '#strike' do
    it 'removes 1 piece and triggers any post battle affects' do
      allow(player).to receive(:pick_option).and_return(0)
      allow(cat_player).to receive(:pick_option).and_return(0)

      battle_cl = clearings[:seven]
      faction.place_meeple(battle_cl)
      cat_faction.place_sawmill(battle_cl)
      cat_faction.place_workshop(battle_cl)
      players = Root::Players::List.new(player, cat_player)

      expect { faction.strike(players) }
        .to change(faction, :victory_points).by(1)
      expect(battle_cl.buildings_of_type(:sawmill).count).to eq(0)
      expect(battle_cl.buildings_of_type(:workshop).count).to eq(1)
    end
  end

  describe '#craft_options' do
    it 'uses hammers' do
      faction.place_meeple(clearings[:one])
      faction.make_item(:hammer)

      card_to_craft = Root::Cards::Item.new(
        suit: :fox,
        craft: %i[fox],
        item: :tea,
        vp: 2
      )

      card_not_to_craft = Root::Cards::Item.new(
        suit: :fox,
        craft: %i[fox fox],
        item: :tea,
        vp: 2
      )

      faction.hand << card_to_craft
      faction.hand << card_not_to_craft

      expect(faction.craftable_items).to eq([card_to_craft])
    end
  end

  describe '#hammer_craft' do
    it 'exhausts hammers appropriately' do
      allow(player).to receive(:pick_option).and_return(0)
      faction.place_meeple(clearings[:one])
      faction.make_item(:hammer)

      card_to_craft = Root::Cards::Item.new(
        suit: :fox,
        craft: %i[fox],
        item: :tea,
        vp: 2
      )

      faction.hand << card_to_craft
      faction.hammer_craft

      expect(faction.victory_points).to eq(2)
      expect(faction.exhausted_items.map(&:item)).to eq([:hammer])
    end
  end

  describe '#can_repair?' do
    it 'needs a damaged weapon and hammer' do
      faction.make_item(:sword)
      faction.damage_item(:sword)

      faction.make_item(:hammer)

      expect(faction.can_repair?).to be true
    end

    context 'without hammer' do
      it 'can not repair' do
        faction.make_item(:sword)
        faction.damage_item(:sword)

        expect(faction.can_repair?).to be false
      end
    end

    context 'without damaged item' do
      it 'can not repair' do
        faction.make_item(:sword)

        faction.make_item(:hammer)

        expect(faction.can_repair?).to be false
      end
    end
  end

  describe '#repair' do
    it 'repairs an item' do
      allow(player).to receive(:pick_option).and_return(0)

      faction.make_item(:sword)
      faction.exhaust_item(:sword)
      faction.damage_item(:sword)

      faction.repair

      sword = faction.items.find { |i| i.item == :sword }
      expect(faction.damaged_items).to eq([])
      expect(faction.exhausted_items).to eq([sword])
    end
  end

  describe '#quest_options?' do
    context 'with matching items in the same clearing' do
      it 'allows to quest' do
        active_quests = build_active_quests
        faction.make_item(:sword)
        faction.make_item(:sword)
        faction.place_meeple(clearings[:one])
        expect(faction.quest_options(active_quests)).to eq([active_quests[0]])
        expect(faction.can_quest?(active_quests)).to be true
      end
    end

    context 'when not in the right clearing and has matching items' do
      it 'does not allowing questing' do
        active_quests = build_active_quests
        faction.make_item(:sword)
        faction.make_item(:sword)
        faction.place_meeple(clearings[:two])
        expect(faction.can_quest?(active_quests)).to be false
      end
    end

    context 'when in right clearing but exhausted items' do
      it 'does not allowing questing' do
        active_quests = build_active_quests
        faction.make_item(:sword)
        faction.make_item(:sword)
        faction.exhaust_item(:sword)

        faction.place_meeple(clearings[:one])
        expect(faction.can_quest?(active_quests)).to be false
      end
    end

    context 'when in right clearing but damaged items' do
      it 'does not allowing questing' do
        active_quests = build_active_quests
        faction.make_item(:sword)
        faction.make_item(:sword)
        faction.damage_item(:sword)

        faction.place_meeple(clearings[:one])
        expect(faction.can_quest?(active_quests)).to be false
      end
    end
  end

  describe '#quest' do
    it 'exhausts item, gets reward, adds to completed_quests, gets new quest' do
      allow(player).to receive(:pick_option).and_return(0)

      faction.place_meeple(clearings[:one])
      faction.make_item(:sword)
      faction.make_item(:sword)

      quests = build_quests

      expect { faction.quest(quests) }
        .to change { quests.deck.count }
        .by(-1)
        .and change { faction.completed_quests_of(:fox).count }
        .by(1)
        .and change { quests.active_quests.count }
        .by(0)
      expect(faction.exhausted_items.map(&:item)).to eq(%i[sword sword])
      expect(faction.victory_points).to eq(1)
    end
  end

  describe '#pick_reward' do
    it 'can score victory_points' do
      allow(player).to receive(:pick_option).and_return(0)

      quest = build_active_quests[0]

      expect { faction.pick_reward(quest) }
        .to change(faction, :victory_points)
        .by(1)
        .and change(faction, :hand_size)
        .by(0)
    end

    it 'can score victory_points based off of completed_quests' do
      allow(player).to receive(:pick_option).and_return(0)

      quest = build_active_quests[0]

      faction.complete_quest(quest)
      faction.complete_quest(quest)
      expect { faction.pick_reward(quest) }
        .to change(faction, :victory_points)
        .by(3)
        .and change(faction, :hand_size)
        .by(0)
    end

    it 'can draw 2 cards instead' do
      allow(player).to receive(:pick_option).and_return(1)

      quest = build_active_quests[0]

      faction.complete_quest(quest)
      faction.pick_reward(quest)

      expect { faction.pick_reward(quest) }
        .to change(faction, :hand_size)
        .by(2)
        .and change(faction, :victory_points)
        .by(0)
    end
  end

  describe '#draw_bonuses' do
    it 'is equal to number of available coins' do
      faction.make_item(:coin)
      faction.make_item(:coin)
      faction.exhaust_item(:coin)

      expect(faction.draw_bonuses).to eq(1)
    end
  end

  describe '#evening_rest' do
    it 'repairs and refreshes all items' do
      faction.place_meeple(forests[:a])

      faction.make_item(:sword)
      faction.make_item(:hammer)
      faction.make_item(:coin)

      faction.exhaust_item(:sword)
      faction.damage_item(:sword)
      faction.exhaust_item(:hammer)

      faction.evening_rest

      expect(faction.available_items.count).to eq(3)
    end
  end

  describe '#can_evening_rest?' do
    context 'when in a forest' do
      it 'can rest' do
        faction.place_meeple(forests[:a])

        expect(faction.can_evening_rest?).to be true
      end
    end

    context 'when in a clearing' do
      it 'can not rest' do
        faction.place_meeple(clearings[:one])

        expect(faction.can_evening_rest?).to be false
      end
    end
  end

  describe '#discard items' do
    context 'with more items to knapsack limit' do
      it 'requires to discard down to minimum' do
        faction.make_item(:sword)
        faction.make_item(:sword)
        faction.make_item(:sword)
        faction.make_item(:boots)
        faction.make_item(:boots)
        faction.make_item(:hammer)
        faction.make_item(:crossbow)
        faction.make_item(:torch)

        expect { faction.discard_items }
          .to change { faction.items.count }.by(-2)
      end
    end

    context 'with less or equal items to knapsack limit' do
      it 'does not change items' do
        faction.make_item(:sword)
        faction.make_item(:sword)
        faction.make_item(:sword)
        faction.make_item(:boots)
        faction.make_item(:boots)
        faction.make_item(:hammer)

        expect { faction.discard_items }
          .to change { faction.items.count }.by(0)
      end
    end

    context 'with items that do not count for knapsack limit' do
      it 'does not count them in needing to discard' do
        faction.make_item(:sword)
        faction.make_item(:sword)
        faction.make_item(:sword)
        faction.make_item(:boots)
        faction.make_item(:boots)
        faction.make_item(:hammer)

        faction.make_item(:coin)
        faction.make_item(:coin)
        faction.make_item(:tea)
        faction.make_item(:tea)

        expect { faction.discard_items }
          .to change { faction.items.count }.by(0)
      end
    end
  end

  describe '#knapsack_capacity' do
    it 'counts valid satchels' do
      faction.make_item(:satchel)
      faction.make_item(:satchel)
      faction.exhaust_item(:satchel)

      expect(faction.knapsack_capacity).to eq(8)
    end

    it 'has 6 by default' do
      faction.make_item(:satchel)
      faction.damage_item(:satchel)
      expect(faction.knapsack_capacity).to eq(6)
    end
  end

  describe '#aid_options' do
    it 'selects all other factions with pieces in the current clearing' do
      our_location = clearings[:one]
      other_location = clearings[:two]

      faction.place_meeple(our_location)
      cat_faction.place_meeple(our_location)
      bird_faction.place_roost(our_location)

      mouse_faction.place_sympathy(other_location)

      expect(faction.aid_options).to eq(%i[cats birds])
      expect(faction.can_aid?).to be false

      faction.make_item(:torch)
      expect(faction.can_aid?).to be false

      faction.hand << Root::Cards::Base.new(suit: :fox)
      expect(faction.can_aid?).to be true

      faction.exhaust_item(:torch)
      expect(faction.can_aid?).to be false
    end

    it 'needs another faction to aid' do
      our_location = clearings[:one]
      other_location = clearings[:two]

      faction.place_meeple(our_location)

      mouse_faction.place_sympathy(other_location)

      expect(faction.aid_options).to eq([])
      expect(faction.can_aid?).to be false
    end

    it 'needs a card in hand matching clearing to aid' do
      our_location = clearings[:one]

      faction.place_meeple(our_location)
      cat_faction.place_meeple(our_location)

      faction.make_item(:torch)

      expect(faction.can_aid?).to be false

      faction.hand << Root::Cards::Base.new(suit: :fox)

      expect(faction.can_aid?).to be true
    end
  end

  describe '#aid' do
    it 'picks one faction, gives them a card matching clearing, takes item' do
      allow(player).to receive(:pick_option).and_return(0)
      players = Root::Players::List.new(player, cat_player)
      faction.handle_relationships(players)
      our_location = clearings[:one]

      faction.place_meeple(our_location)
      cat_faction.place_meeple(our_location)

      cat_faction.make_item(:hammer)

      faction.make_item(:torch)
      faction.hand << Root::Cards::Base.new(suit: :fox)

      expect { faction.aid(players) }
        .to change(faction, :hand_size)
        .by(-1)
        .and change(cat_faction, :hand_size)
        .by(1)
        .and change(faction, :victory_points)
        .by(1)
        .and change { cat_faction.items.count }
        .by(-1)
        .and change { faction.items.count }
        .by(1)
        .and change { faction.exhausted_items.count }
        .by(1)

      expect(faction.relationships[:cats][:status]).to be(1)
      expect(faction.relationships[:cats][:num_aided]).to be(0)
    end
  end

  describe '#post_battle' do
    it 'makes hostile on meeple removal' do
      allow(player).to receive(:pick_option).and_return(0)
      allow_any_instance_of(Root::Actions::Battle).
        to receive(:dice_roll).and_return(1, 0)
      players = Root::Players::List.new(player, cat_player)
      faction.handle_relationships(players)

      faction.make_item(:sword)
      faction.place_meeple(clearings[:one])
      cat_faction.place_meeple(clearings[:one])

      expect { faction.battle(players) }
        .to change(faction, :victory_points).by(0)

      expect(faction.relationships.hostile?(:cats)).to be true
    end

    it 'does not make hostile on building / token removal' do
      allow(player).to receive(:pick_option).and_return(0)
      allow_any_instance_of(Root::Actions::Battle).
        to receive(:dice_roll).and_return(1, 0)
      players = Root::Players::List.new(player, cat_player)
      faction.handle_relationships(players)

      faction.make_item(:sword)
      faction.place_meeple(clearings[:one])
      cat_faction.place_sawmill(clearings[:one])

      expect(faction.relationships.hostile?(:cats)).to be false
    end

    it 'if hostile, scores extra victory point for each piece removed on your turn' do
      allow(player).to receive(:pick_option).and_return(0)
      allow_any_instance_of(Root::Actions::Battle).
        to receive(:dice_roll).and_return(3, 0)
      players = Root::Players::List.new(player, cat_player)
      faction.handle_relationships(players)

      faction.make_item(:sword)
      faction.make_item(:sword)
      faction.make_item(:sword)
      faction.place_meeple(clearings[:one])
      cat_faction.place_sawmill(clearings[:one])
      cat_faction.place_meeple(clearings[:one])
      cat_faction.place_meeple(clearings[:one])

      # 1 meeple makes hostile, 2 for sawmill, 1 for hostile on meeple
      expect { faction.battle(players) }
        .to change(faction, :victory_points).by(3)
    end

    it 'if hostile no extra points when they battle you' do
      allow(player).to receive(:pick_option).and_return(0)
      allow_any_instance_of(Root::Actions::Battle).
        to receive(:dice_roll).and_return(3, 3)
      players = Root::Players::List.new(player, cat_player)
      faction.handle_relationships(players)

      faction.make_item(:sword)
      faction.make_item(:sword)
      faction.make_item(:sword)
      faction.place_meeple(clearings[:one])
      cat_faction.place_meeple(clearings[:one])
      cat_faction.place_meeple(clearings[:one])
      cat_faction.place_meeple(clearings[:one])

      expect { cat_faction.battle(players) }
        .to change(faction, :victory_points).by(0)
    end
  end

  def build_item(type)
    Root::Cards::Item.new(suit: :fox, craft: %i[rabbit], item: type, vp: 1)
  end

  def build_quests
    Root::Factions::Racoons::Quests.new(build_active_quests)
  end

  def build_active_quests
    card = Root::Factions::Racoons::QuestCard
    [
      card.new(suit: :fox, items: %i[sword sword], name: 'Test Quest 1'),
      card.new(suit: :mouse, items: %i[crossbow hammer], name: 'Test Quest 2'),
      card.new(suit: :bunny, items: %i[torch tea], name: 'Test Quest 3')
    ]
  end
end
