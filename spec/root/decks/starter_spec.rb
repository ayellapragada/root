# frozen_string_literal: true

RSpec.describe Root::Decks::Starter do
  describe '.initialize' do
    it 'creates a deck with 54 cards' do
      deck = Root::Decks::Starter.new
      first_card = deck.first

      expect(deck.count).to be(54)
      expect(Root::Cards::VALID_SUITS.include?(first_card.suit)).to be true
    end
  end

  describe '.draw_from_top' do
    it 'draws a number of cards from the top' do
      deck = Root::Decks::Starter.new
      expect(deck.count).to be(54)

      deck.draw_from_top(3)

      expect(deck.count).to be(51)
    end
  end
end
