# frozen_string_literal: true

RSpec.describe Root::Factions::Vagabonds::Characters do
  describe '#generate_deck' do
    it 'creates a list of all current characters' do
      deck = Root::Factions::Vagabonds::Characters.new
      expect(deck.count).to be(3)
    end
  end

  describe 'remove_from_deck' do
    it 'removes the card from deck' do
      deck = Root::Factions::Vagabonds::Characters.new
      thief = deck.find { |c| c.name == :thief }
      expect { deck.remove_from_deck(thief) }.to change { deck.count }.by(-1)
    end
  end
end
