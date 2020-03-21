# frozen_string_literal: true

RSpec.describe Root::Factions::Cat do
  describe '.handle_faction_token_setup' do
    it 'sets 25 meeples, and then 6 buildings of each type' do
      player = Root::Players::Human.for('Sneak', :cats)
      faction = player.faction

      expect(faction.meeples.count).to eq(25)

      expect(faction.recruiters.count).to eq(6)
      expect(faction.sawmills.count).to eq(6)
      expect(faction.workshops.count).to eq(6)

      expect(faction.wood.count).to eq(8)
    end
  end

  describe '.setup' do
    it 'sets a keep in the corner' do
      board = Root::Boards::Woodlands.new
      player = Root::Players::Human.for('Sneak', :cats)
      faction = player.faction
      allow(player).to receive(:pick_option).and_return(0)
      expect(board.keep_in_corner?).to be false

      player.setup(board)

      expect(board.keep_in_corner?).to be true
      expect(faction.keep).to be_empty
    end
  end
end
