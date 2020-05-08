# frozen_string_literal: true

RSpec.describe Root::Factions::Racoons::Characters::Ranger do
  let(:player) { Root::Players::Computer.for('Sneak', :racoon) }
  let(:faction) { player.faction }
  let(:char) { faction.character }
  let(:board) { player.board }
  let(:clearings) { board.clearings }
  let(:forests) { board.forests }
  let(:mouse_player) { Root::Players::Computer.for('Bird', :mice) }
  let(:mouse_faction) { mouse_player.faction }
  let(:bird_player) { Root::Players::Computer.for('Bird', :birds) }
  let(:bird_faction) { bird_player.faction }
  let(:cat_player) { Root::Players::Computer.for('Cat', :cats) }
  let(:cat_faction) { cat_player.faction }

  before { faction.quick_set_character(:ranger) }

  describe '#special' do
    it 'repairs 3 items' do
      expect(char.can_special?).to be false

      faction.damage_item(:boots)
      faction.damage_item(:sword)
      faction.damage_item(:crossbow)

      expect(char.special_options.map(&:item)).to eq(%i[boots crossbow sword])
      expect(char.can_special?).to be true
      expect { char.special }.to change { faction.damaged_items.count }.by(-3)
    end

    context 'with more than 3 items' do
      it 'allows player to pick which items to repair' do
        faction.make_item(:tea)
        faction.make_item(:coin)

        faction.damage_item(:boots)
        faction.damage_item(:torch)
        faction.damage_item(:crossbow)
        faction.damage_item(:tea)
        faction.damage_item(:coin)

        expect { char.special }.to change { faction.damaged_items.count }.by(-3)
      end
    end
  end
end
