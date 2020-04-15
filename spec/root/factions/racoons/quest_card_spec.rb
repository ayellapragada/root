# frozen_string_literal: true

RSpec.describe Root::Factions::Racoons::QuestCard do
  describe '#initialize' do
    it 'has a suit and 2 cards for the item requirement' do
      card = Root::Factions::Racoons::QuestCard.new(
        suit: :fox,
        items: %i[torch tea]
      )

      expect(card.suit).to eq(:fox)
      expect(card.items).to match_array(%i[torch tea])
    end
  end
end
