# frozen_string_literal: true

RSpec.describe Root::Factions::Racoons::Relationships do
  describe '#initialize' do
    it 'sets markers for all other factions to neutral' do
      list = Root::Players::List.default_player_list
      p1 = list.fetch_player(:cats)
      others = list.except_player(p1)
      relationships = Root::Factions::Racoons::Relationships.new(others)

      expect(relationships.count).to eq(3)
      expect(relationships.all_neutral?).to be true
    end
  end
end
