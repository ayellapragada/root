# frozen_string_literal: true

RSpec.describe Root::Factions::Racoon do
  let(:player) { Root::Players::Computer.for('Sneak', :racoon) }
  let(:faction) { player.faction }
  let(:board) { player.board }
  let(:clearings) { board.clearings }
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
            title: "Thief | Nimble | Lone Wanderer\n0 tea(s) | 0 coin(s) | 0 satchel(s)\nMice: 0 | Cats: 0 | Birds: 0",
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
      it { expect(faction.formatted_items).to eq([['No Items']]) }
    end

    context 'with undamaged unexhausted items' do
      it 'renders just the name without and status' do
        faction.craft_item(build_item(:tea))
        faction.craft_item(build_item(:sword))
        expect(faction.formatted_items).to eq([['Sword, Tea']])
      end
    end

    context 'with any damaged items' do
      it 'puts on a different line than undamaged items' do
        faction.craft_item(build_item(:sword))
        faction.craft_item(build_item(:satchel))
        faction.craft_item(build_item(:hammer))

        faction.damage_item(:hammer)

        expect(faction.formatted_items)
          .to eq([['Satchel, Sword'], ['Hammer (D)']])
      end
    end
  end

  describe '#formatted_relationships' do
    context 'without relationships' do
      it { expect(faction.formatted_relationships).to eq('No Relationships') }
    end
  end

  def build_item(type)
    Root::Cards::Item.new(suit: :fox, craft: %i[bunny], item: type, vp: 1)
  end
end
