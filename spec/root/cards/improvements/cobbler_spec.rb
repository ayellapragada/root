# frozen_string_literal: true

RSpec.describe Root::Cards::Improvements::Cobbler do
  let(:mouse_player) { Root::Players::Computer.for('Bird', :mice) }
  let(:mouse_faction) { mouse_player.faction }
  let(:clearings) { mouse_player.board.clearings }
  let(:bird_player) { Root::Players::Computer.for('Bird', :birds) }
  let(:bird_faction) { bird_player.faction }
  let(:cat_player) { Root::Players::Computer.for('Sneak', :cats) }
  let(:cat_faction) { cat_player.faction }

  describe '#faction_use' do
    it 'allows ability to initiate one move' do
      allow(mouse_player).to receive(:pick_option).and_return(0)

      from_cl = clearings[:one]
      to_cl = clearings[:five]
      mouse_faction.place_meeple(from_cl)

      mouse_faction.improvements << described_class.new

      mouse_faction.evening
      expect(from_cl.meeples_of_type(:mice).count).to eq(0)
      expect(to_cl.meeples_of_type(:mice).count).to eq(1)
    end
  end
end
