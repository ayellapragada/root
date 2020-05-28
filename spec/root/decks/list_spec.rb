# frozen_string_literal: true
RSpec.describe Root::Decks::List do
  describe '.from_db' do
    it 'sets the values of all decks' do
      db_record = {
        shared: %i[tea tea sword],
        discard: %i[cats cats birds mice],
        lost_souls: %i[sawmill wood cats],
        dominance: %i[], # TODO: WILL COME BACK TO LATER
        quests: %i[base sympathy],
        active_quests: %i[ruin sword],
        characters: %i[ranger tinker]
      }

      decks = Root::Decks::List.from_db(db_record)
      expect(decks).to be_truthy
    end
  end
end
