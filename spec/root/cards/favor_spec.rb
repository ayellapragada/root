# frozen_string_literal: true

RSpec.describe Root::Cards::Favor do
  let(:player) { Root::Players::Computer.for('Sneak', :mice) }
  let(:faction) { player.faction }
  let(:board) { player.board }
  let(:clearings) { board.clearings }
  let(:bird_player) { Root::Players::Computer.for('Bird', :birds) }
  let(:bird_faction) { bird_player.faction }
  let(:cat_player) { Root::Players::Computer.for('Cat', :cats) }
  let(:cat_faction) { cat_player.faction }
  let(:racoon_player) { Root::Players::Computer.for('Racoon', :racoon) }
  let(:racoon_faction) { racoon_player.faction }

  describe '#craftable?' do
    it 'does not care about board state' do
      card = Root::Cards::Favor.new(suit: :fox)
      expect(card.craftable?).to be true
    end
  end

  describe '#craft' do
    it 'is three times the suit' do
      card = Root::Cards::Favor.new(suit: :fox)

      expect(card.suit).to eq(:fox)
      expect(card.craft).to eq(%i[fox fox fox])
    end
  end

  describe '#info' do
    it 'is hopefully helpful' do
      card = Root::Cards::Favor.new(suit: :fox)
      expect(card.name).to eq('Favor of the Foxes')
      expect(card.body).to eq('Remove in fox clearing')
    end
  end

  describe '#faction_craft' do
    it 'removes all enemy pieces in all clearings of its suit' do
      players = Root::Players::List.new(player, cat_player, bird_player, racoon_player)
      player.players = players

      fox_cl1 = clearings[:one]
      fox_cl2 = clearings[:six]
      fox_cl3 = clearings[:eight]
      mouse_cl = clearings[:two]

      faction.place_meeple(fox_cl1)

      cat_faction.place_meeple(fox_cl1)
      cat_faction.place_keep(fox_cl1)
      cat_faction.place_recruiter(fox_cl3)
      cat_faction.place_meeple(mouse_cl)

      bird_faction.place_meeple(fox_cl2)
      bird_faction.place_meeple(fox_cl2)
      bird_faction.place_roost(fox_cl2)

      racoon_faction.make_item(:boots)
      racoon_faction.make_item(:boots)
      racoon_faction.make_item(:boots)
      racoon_faction.place_meeple(fox_cl3)

      card = Root::Cards::Favor.new(suit: :fox)

      expect { faction.craft_item(card) }
        .to change(faction, :victory_points)
        .by(3)
        .and change { fox_cl1.meeples_of_type(:cats).count }
        .by(-1)
        .and change { fox_cl1.tokens_of_faction(:cats).count }
        .by(-1)
        .and change { fox_cl3.buildings_of_type(:recruiter).count }
        .by(-1)
        .and change { fox_cl2.meeples_of_type(:birds).count }
        .by(-2)
        .and change { fox_cl2.buildings_of_type(:roost).count }
        .by(-1)
        .and change { racoon_faction.damaged_items.count }
        .by(3)
        .and change { fox_cl3.meeples_of_type(:racoon).count }
        .by(0)
        .and change { mouse_cl.meeples_of_type(:racoon).count }
        .by(0)
    end
  end
end
