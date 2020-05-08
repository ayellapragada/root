# frozen_string_literal: true

RSpec.describe Root::Factions::Racoons::Characters::Thief do
  let(:player) { Root::Players::Computer.for('Sneak', :racoon) }
  let(:faction) { player.faction }
  let(:char) { faction.character }

  describe '#torch?' do
    it 'needs an available torch' do
      faction.quick_set_character(:thief)
      expect(char.torch?).to be true

      char.f.damage_item(:torch)

      expect(char.torch?).to be false
    end
  end
end
