# frozen_string_literal: true

RSpec.describe Root::Factions::Racoon do
  let(:player) { Root::Players::Computer.for('Sneak', :racoon) }
  let(:faction) { player.faction }
  let(:board) { player.board }
  let(:clearings) { board.clearings }
  let(:forests) { board.forests }
  let(:mouse_player) { Root::Players::Computer.for('Bird', :mice) }
  let(:mouse_faction) { bird_player.faction }
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

      expect(board.forests[:a].meeples_of_type(:racoon).count == 1).to be true
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

  describe '#special_info' do
    it 'returns special stats, relationships, and items' do
      game = Root::Game.default_game
      decks = game.decks
      players = game.players
      player = players.fetch_player(:racoon)
      allow(player).to receive(:pick_option).and_return(0)

      player.setup(decks: decks, players: players)
      faction = player.faction
      expect(faction.special_info(true)).to eq(
        {
          board: {
            title: "Thief | Nimble | Lone Wanderer\n0 tea(s) | 0 coin(s) | 0 satchel(s)\nAffinity: Mice: 0 | Cats: 0 | Birds: 0",
            rows:  [['No Items']]
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
          .to eq(['Satchel, Sword, Hammer (D)'])
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
          .to eq(['Satchel, Sword, Coin (E), Hammer (ED)'])
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
      it { expect(faction.formatted_relationships).to eq('No Relationships') }
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

  def build_item(type)
    Root::Cards::Item.new(suit: :fox, craft: %i[rabbit], item: type, vp: 1)
  end
end
