# frozen_string_literal: true

RSpec.describe Root::Factions::Mouse do
  describe '#handle_faction_token_setup' do
    it 'gives faction 10 meeples, 3 bases, and 8 sympathy' do
      _player, faction = build_player_and_faction

      expect(faction.meeples.count).to eq(10)
      expect(faction.bases.count).to eq(3)
      expect(faction.sympathy.count).to eq(8)
    end
  end

  describe '#setup' do
    it 'draws 3 supporters from deck' do
      player, faction = build_player_and_faction

      expect(faction.supporters.count).to eq(0)
      player.setup

      expect(faction.supporters.count).to eq(3)
    end
  end

  def build_player_and_faction
    player = Root::Players::Computer.for('Sneak', :mice)
    [player, player.faction]
  end
end
