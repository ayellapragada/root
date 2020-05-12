# frozen_string_literal: true

RSpec.describe Root::Cards::Improvements::CommandWarren do
  let(:mouse_player) { Root::Players::Computer.for('Bird', :mice) }
  let(:mouse_faction) { mouse_player.faction }
  let(:clearings) { mouse_player.board.clearings }
  let(:bird_player) { Root::Players::Computer.for('Bird', :birds) }
  let(:bird_faction) { bird_player.faction }
  let(:cat_player) { Root::Players::Computer.for('Sneak', :cats) }
  let(:cat_faction) { cat_player.faction }

  describe '#faction_use' do
    it 'allows ability to initiate one battle' do
      allow(mouse_player).to receive(:pick_option).and_return(0)
      allow(cat_player).to receive(:pick_option).and_return(0)
      players = Root::Players::List.new(mouse_player, cat_player)
      mouse_player.players = players

      battle_cl = clearings[:one]
      mouse_faction.place_meeple(battle_cl)
      cat_faction.place_meeple(battle_cl)

      allow_any_instance_of(Root::Actions::Battle).
        to receive(:dice_roll).and_return(1, 0)

      mouse_faction.improvements << described_class.new

      mouse_faction.daylight
      expect(battle_cl.meeples_of_type(:mice).count).to eq(1)
      expect(battle_cl.meeples_of_type(:cats).count).to eq(0)
    end

    it 'does not have to, it is optional' do
      allow(mouse_player).to receive(:pick_option).and_return(1)
      allow(cat_player).to receive(:pick_option).and_return(0)
      players = Root::Players::List.new(mouse_player, cat_player)
      mouse_player.players = players

      battle_cl = clearings[:one]
      mouse_faction.place_meeple(battle_cl)
      cat_faction.place_meeple(battle_cl)

      mouse_faction.improvements << described_class.new

      mouse_faction.daylight
      expect(battle_cl.meeples_of_type(:mice).count).to eq(1)
      expect(battle_cl.meeples_of_type(:cats).count).to eq(1)
    end
  end
end
