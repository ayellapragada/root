# frozen_string_literal: true

RSpec.describe Root::Decks::Starter do
  describe '#initialize' do
    it 'creates a deck with cards' do
      deck = Root::Decks::Starter.new
      first_card = deck.first

      expect(deck.count).to be(Root::Decks::Starter::DECK_SIZE)
      expect(Root::Cards::VALID_SUITS.include?(first_card.suit)).to be true
    end
  end

  describe '#draw_from_top' do
    it 'draws a number of cards from the top' do
      deck = Root::Decks::Starter.new

      deck.draw_from_top(3)

      expect(deck.count).to be(Root::Decks::Starter::DECK_SIZE - 3)
    end

    context 'when out of cards' do
      it 'reshuffles discard and adds to bottom of deck' do
        deck = described_class.new

        hand = []
        hand.concat(deck.draw_from_top(52))
        remaining_cards = deck.deck.dup

        hand[0..5].each do |card|
          deck.discard_card(card)
          hand.delete(card)
        end

        new_hand = []

        new_hand.concat(deck.draw_from_top(3))
        expect(new_hand[0..1]).to match_array(remaining_cards)
        expect(new_hand[2]).not_to be nil
        expect(remaining_cards).not_to include(new_hand[2])
        expect(deck.discard.count).to be(0)
        expect(deck.count).to be(5)
      end
    end
  end

  describe '#discard_card' do
    context 'when dominance card' do
      it 'makes available and not in discard' do
        deck = described_class.new
        card = Root::Cards::Dominance.new(suit: :fox)

        expect { deck.discard_card(card) }
          .to change { deck.discard.count }.by(0)

        expect(deck.dominance_for(:fox)).to eq(card)
      end
    end
  end
end
