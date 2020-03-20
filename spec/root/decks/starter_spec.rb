# frozen_string_literal: true

RSpec.describe Root::Decks::Starter do
  describe '.initialize' do
    it 'creates a deck with cards' do
      deck = Root::Decks::Starter.new
      first_card = deck.first

      expect(deck.count).to be(Root::Decks::Starter::DECK_SIZE)
      expect(Root::Cards::VALID_SUITS.include?(first_card.suit)).to be true
    end
  end

  describe '.draw_from_top' do
    it 'draws a number of cards from the top' do
      deck = Root::Decks::Starter.new

      deck.draw_from_top(3)

      expect(deck.count).to be(Root::Decks::Starter::DECK_SIZE - 3)
    end
  end
end
