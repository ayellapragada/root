# frozen_string_literal: true

RSpec.describe Root::Factions::Racoons::CharacterDeck do
  describe '#generate_deck' do
    it 'creates a list of all current characters' do
      deck = Root::Factions::Racoons::CharacterDeck.new
      expect(deck.count).to be(3)
    end
  end

  describe 'remove_from_deck' do
    it 'removes the card from deck' do
      deck = Root::Factions::Racoons::CharacterDeck.new
      thief = deck.find { |c| c.name == 'Thief' }
      expect { deck.remove_from_deck(thief) }.to change { deck.count }.by(-1)
    end
  end
end
