# frozen_string_literal: true

RSpec.describe Root::Cards::Improvement do
  let(:cat_player) { Root::Players::Computer.for('Cat', :cats) }
  let(:cat_faction) { cat_player.faction }
  let(:board) { cat_player.board }
  let(:clearings) { board.clearings }

  describe '#inspect' do
    it 'Displays information about the improvement' do
      card = Root::Cards::Improvement.new(suit: :bird, craft: [:fox])
      expect(card.inspect)
        .to eq('Improvement (B) | Craft: fox, Improvement Info')
    end
  end

  describe '#faction_craft' do
    it 'puts into factions crafted improvements section' do
      allow(cat_player).to receive(:pick_option).and_return(0)

      card = Root::Cards::Improvement.new(suit: :bird, craft: [:fox])
      cat_faction.hand << card
      cat_faction.place_workshop(clearings[:one])

      cat_faction.craft_items

      expect(cat_faction.improvements).to eq([card])
    end
  end

  describe '#faction_craft' do
    it 'can not craft 2 of the same improvement' do
      allow(cat_player).to receive(:pick_option).and_return(0)

      card1 = Root::Cards::Improvement.new(suit: :bird, craft: [:fox])
      card2 = Root::Cards::Improvement.new(suit: :bird, craft: [:fox])
      cat_faction.improvements << card1

      cat_faction.hand << card2

      cat_faction.place_workshop(clearings[:eight])

      cat_faction.craft_items

      expect(cat_faction.improvements).to eq([card1])
    end
  end

  describe '#refresh' do
    it 'can not craft 2 of the same improvement' do
      allow(cat_player).to receive(:pick_option).and_return(0)
      card = Root::Cards::Improvement.new(suit: :bird, craft: [:fox])

      cat_faction.improvements << card
      expect(cat_faction.available_improvements).to eq([card])

      cat_faction.improvements.first.exhaust
      expect(cat_faction.available_improvements).to eq([])

      cat_faction.improvements.first.refresh
      expect(cat_faction.available_improvements).to eq([card])
    end
  end
end
