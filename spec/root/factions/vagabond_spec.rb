# frozen_string_literal: true

RSpec.describe Root::Factions::Vagabond do
  describe '#handle_faction_token_setup' do
    it 'sets up an empty item set' do
      vagabond = Root::Players::Human.for('Sneak', :vagabond).faction

      expect(vagabond.items).to be_empty
      expect(vagabond.damaged_items).to be_empty
      expect(vagabond.teas.count).to be(0)
      expect(vagabond.coins.count).to be(0)
      expect(vagabond.bags.count).to be(0)
    end
  end

  # THIS IS FOR LATER WE DON'T DO IT INITIALLY!
  # expect(vagabond.relationships.all?(&:neutral?)).to be true

  describe '#setup' do
    it 'selects a forest clearing to start in'
    it 'selects a leader and gets starting items'
    it 'sets up 4 ruins with item cards'
    it 'sets up the relationships with other factions to neutral'

    context 'without active quest cards' do
      it 'sets up quest cards'
    end

    context 'with active quest cards' do
      it 'does not draw new quest cards' do
      end
    end
  end
end
