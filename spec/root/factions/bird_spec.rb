# frozen_string_literal: true

RSpec.describe Root::Factions::Bird do
  xdescribe '.handle_faction_token_setup' do
    it 'sets up birds faction default board state' do
      player = Root::Players::Human.for('Sneak', :birds)
      faction = player.faction

      expect(faction.warriors.count).to eq(20)
      expect(faction.roosts.count).to eq(7)
      expect(faction.loyal_viziers.count).to eq(2)
      expect(faction.available_leaders.count).to eq(4)
    end
  end
end
