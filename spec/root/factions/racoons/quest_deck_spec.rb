# frozen_string_literal: true

RSpec.describe Root::Factions::Racoons::QuestDeck do
  describe '#initialize' do
    it 'creates a deck with cards' do
      deck = Root::Factions::Racoons::QuestDeck.new
      first_card = deck.first

      expect(deck.count).to be(Root::Factions::Racoons::QuestDeck::DECK_SIZE)
      expect(Root::Cards::VALID_SUITS.include?(first_card.suit)).to be true
    end
  end
end
