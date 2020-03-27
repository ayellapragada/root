# frozen_string_literal: true

RSpec.describe Root::Factions::Vagabonds::QuestDeck do
  describe '#initialize' do
    it 'creates a deck with cards' do
      deck = Root::Factions::Vagabonds::QuestDeck.new
      first_card = deck.first

      expect(deck.count).to be(Root::Factions::Vagabonds::QuestDeck::DECK_SIZE)
      expect(Root::Cards::VALID_SUITS.include?(first_card.suit)).to be true
    end
  end
end
