# frozen_string_literal: true

RSpec.describe Root::Decks::List do
  describe '.from_db' do
    it 'sets the values of all decks' do
      db_record = {
        shared: [{ name: 'Cobbler', suit: :rabbit }],
        discard: [
          { name: 'Ambush', suit: :bird },
          { name: "Smuggler's Trail", suit: :rabbit }
        ],
        lost_souls: [{ name: 'Anvil', suit: :fox }],
        dominance: [{ name: 'Dominance', suit: :bird }],
        quests: [{ name: 'Fundraising', suit: :fox }],
        active_quests: [{ name: 'Errand', suit: :fox }],
        characters: %i[ranger tinker]
      }

      decks = Root::Decks::List.from_db(db_record)
      expect(decks.shared.dominance_for(:bird)).to be_truthy
      expect(decks.shared.dominance_for(:fox)).to be nil
      expect(decks.shared.deck.count).to be(1)
      expect(decks.shared.discard.count).to be(2)
      expect(decks.shared.lost_souls.count).to be(1)
      expect(decks.quests.deck.count).to be(1)
      expect(decks.quests.active_quests.count).to be(1)
      expect(decks.characters.map(&:type)).to eq(%i[ranger tinker])
    end
  end
end
