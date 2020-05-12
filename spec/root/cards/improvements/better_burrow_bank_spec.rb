# frozen_string_literal: true

RSpec.describe Root::Cards::Improvements::BetterBurrowBank do
  let(:player) { Root::Players::Computer.for('Sneak', :cats) }
  let(:faction) { player.faction }
  let(:board) { player.board }
  let(:clearings) { board.clearings }
  let(:bird_player) { Root::Players::Computer.for('Bird', :birds) }
  let(:bird_faction) { bird_player.faction }
  let(:mouse_player) { Root::Players::Computer.for('Bird', :mice) }
  let(:mouse_faction) { mouse_player.faction }

  describe '#faction_use' do
    it 'picks one other faction and both draw a card' do
      allow(player).to receive(:pick_option).and_return(0)
      players = Root::Players::List.new(player, bird_player, mouse_player)
      player.players = players

      faction.improvements << described_class.new
      expect { faction.birdsong }
        .to change(faction, :hand_size)
        .by(1)
        .and change(bird_faction, :hand_size)
        .by(1)
        .and change(mouse_faction, :hand_size)
        .by(0)
    end
  end
end
