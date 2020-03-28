# frozen_string_literal: true

RSpec.describe Root::Factions::Mouse do
  describe '#handle_faction_token_setup' do
    it 'gives faction 10 meeples, 3 bases, and 8 sympathy' do
      player = Root::Players::Human.for('Sneak', :mice)
      mice = player.faction

      expect(mice.meeples.count).to eq(10)
      expect(mice.bases.count).to eq(3)
      expect(mice.sympathy.count).to eq(8)
    end
  end

  describe '#setup' do
    it 'draws 3 supporters from deck' do
      board = Root::Boards::Base.new
      decks = Root::Decks::List.default_decks_list
      player = Root::Players::Human.for('Sneak', :mice)
      mice = player.faction

      expect(mice.supporters.count).to eq(0)
      player.setup(board: board, decks: decks)

      expect(mice.supporters.count).to eq(3)
    end
  end
end
