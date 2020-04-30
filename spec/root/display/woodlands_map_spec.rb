# frozen_string_literal: true

RSpec.describe Root::Display::WoodlandsMap do
  describe '#display' do
    it 'renders a board' do
      game = Root::Game.default_game

      place_mice_tokens_for_display(game)
      place_racoon_token_for_display(game)
      place_cards_into_bird_decree(game)
      craft_items_for_cat(game)
      craft_items_for_racoon(game)
      game.setup
      mock_clearing_options(game)

      game.print_display = true
      expect(game.render).to be nil
    end

    describe 'when worst case scenario for breaking things' do
      it 'still does not break though' do
        game = Root::Game.with_faction_for_play(:racoon)
        player = game.players.fetch_player(:racoon)
        allow(player).to receive(:pick_option).and_return(0)

        place_cards_into_bird_decree(game)
        craft_items_for_cat(game)
        craft_so_many_items_for_cat(game)
        craft_items_for_racoon(game)
        game.setup

        game.print_display = true
        expect(game.render).to be nil
      end
    end

    describe 'vagabondo item display word fonto' do
      it 'still does not break though' do
        game = Root::Game.with_faction_for_play(:mice)
        player = game.players.fetch_player(:mice)
        allow(player).to receive(:pick_option).and_return(0)

        place_cards_into_bird_decree(game)
        craft_all_items_for_racoon(game)
        add_bunny_supporters(game)
        game.setup

        game.print_display = true
        expect(game.render).to be nil
      end
    end
  end

  def place_mice_tokens_for_display(game)
    mice = game.players.fetch_player(:mice).faction
    board = game.board
    clearing = board.clearings[:seven]

    board.place_token(mice.sympathy.pop, clearing)
    3.times { board.place_meeple(mice.meeples.pop, clearing) }
  end

  def place_cards_into_bird_decree(game)
    player = game.players.fetch_player(:birds)
    faction = player.faction

    faction.decree[:recruit] << Root::Cards::Base.new(suit: :bird)
    faction.decree[:recruit] << Root::Cards::Base.new(suit: :bird)
    faction.decree[:recruit] << Root::Cards::Base.new(suit: :bird)
    faction.decree[:recruit] << Root::Cards::Base.new(suit: :rabbit)

    faction.decree[:move] << Root::Cards::Base.new(suit: :fox)
    faction.decree[:move] << Root::Cards::Base.new(suit: :rabbit)
    faction.decree[:move] << Root::Cards::Base.new(suit: :mouse)
    faction.decree[:move] << Root::Cards::Base.new(suit: :bird)

    faction.decree[:battle] << Root::Cards::Base.new(suit: :bird)
    faction.decree[:battle] << Root::Cards::Base.new(suit: :mouse)

    faction.decree[:build] << Root::Cards::Base.new(suit: :fox)
    faction.decree[:build] << Root::Cards::Base.new(suit: :bird)
  end

  # Effectively this is just for test
  # Normally we won't have three racoons
  # Maximum we'll have 2, so we're just displaying all options
  def place_racoon_token_for_display(game)
    player = game.players.fetch_player(:racoon)
    faction = player.faction
    allow(player).to receive(:pick_option).and_return(0)
    board = game.board
    meeple = faction.meeples.first

    forest_f = board.forests[:f]
    board.place_meeple(meeple, forest_f)
    board.place_meeple(meeple, forest_f)
  end

  def craft_items_for_racoon(game)
    faction = game.players.fetch_player(:racoon).faction
    tea = Root::Cards::Item.new(suit: :fox, craft: %i[rabbit], item: :tea, vp: 2)
    sword1 = Root::Cards::Item.new(suit: :fox, craft: %i[rabbit], item: :sword, vp: 2)
    sword2 = Root::Cards::Item.new(suit: :fox, craft: %i[rabbit], item: :sword, vp: 2)
    hammer = Root::Cards::Item.new(suit: :fox, craft: %i[rabbit], item: :hammer, vp: 2)

    faction.craft_item(tea)
    faction.craft_item(sword1)
    faction.craft_item(sword2)
    faction.craft_item(hammer)
    faction.damage_item(:hammer)
    faction.exhaust_item(:sword)
  end

  def craft_all_items_for_racoon(game)
    faction = game.players.fetch_player(:racoon).faction
    coin = Root::Cards::Item.new(suit: :fox, craft: %i[rabbit], item: :coin, vp: 1)
    faction.craft_item(coin)
    %i[satchel satchel boots boots crossbow hammer sword sword tea tea coin].each do |item|
      card = Root::Cards::Item.new(suit: :fox, craft: %i[rabbit], item: item, vp: 1)
      faction.craft_item(card)
      faction.exhaust_item(item)
      faction.damage_item(item)
    end
  end

  def add_bunny_supporters(game)
    faction = game.players.fetch_player(:mice).faction
    clearings = game.board.clearings
    faction.place_base(clearings[:one])
    12.times do
      card = Root::Cards::Base.new(suit: :rabbit)
      faction.add_to_supporters([card])
    end
  end

  # rubocop:disable all
  def mock_clearing_options(game)
    board = game.board
    allow_any_instance_of(Root::Display::WoodlandsMap)
      .to receive(:clearing_options)
      .and_return(
        [
          board.clearings[:one],
          board.clearings[:eleven],
          board.forests[:e]
        ]
    )
    # rubocop:enable all
  end

  def craft_items_for_cat(game)
    coin = Root::Cards::Item.new(suit: :fox, craft: %i[rabbit], item: :coin, vp: 2)

    faction = game.players.fetch_player(:cats).faction
    faction.craft_item(coin)
  end

  def craft_so_many_items_for_cat(game)
    coin = Root::Cards::Item.new(suit: :fox, craft: %i[rabbit], item: :coin, vp: 2)
    satchel1 = Root::Cards::Item.new(suit: :fox, craft: %i[rabbit], item: :satchel, vp: 2)
    crossbow = Root::Cards::Item.new(suit: :fox, craft: %i[rabbit], item: :crossbow, vp: 2)
    boots1 = Root::Cards::Item.new(suit: :fox, craft: %i[rabbit], item: :boots, vp: 2)
    boots2 = Root::Cards::Item.new(suit: :fox, craft: %i[rabbit], item: :boots, vp: 2)
    satchel2 = Root::Cards::Item.new(suit: :fox, craft: %i[rabbit], item: :satchel, vp: 2)
    tea = Root::Cards::Item.new(suit: :fox, craft: %i[rabbit], item: :tea, vp: 2)

    faction = game.players.fetch_player(:cats).faction
    faction.craft_item(coin)
    faction.craft_item(satchel1)
    faction.craft_item(crossbow)
    faction.craft_item(boots1)
    faction.craft_item(boots2)
    faction.craft_item(satchel2)
    faction.craft_item(tea)
  end
end
