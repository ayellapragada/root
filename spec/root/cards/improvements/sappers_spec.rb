# frozen_string_literal: true

RSpec.describe Root::Cards::Improvements::Sappers do
  let(:player) { Root::Players::Computer.for('Sneak', :cats) }
  let(:faction) { player.faction }
  let(:board) { player.board }
  let(:clearings) { board.clearings }
  let(:bird_player) { Root::Players::Computer.for('Bird', :birds) }
  let(:bird_faction) { bird_player.faction }

  describe '#sappers' do
    it 'in battle as defender discard to deal extra hit' do
      allow(player).to receive(:pick_option).and_return(0)
      allow(bird_player).to receive(:pick_option).and_return(0)

      players = Root::Players::List.new(player, bird_player)
      player.players = players

      battle_cl = clearings[:one]
      faction.place_meeple(battle_cl)
      faction.place_meeple(battle_cl)
      faction.place_meeple(battle_cl)

      bird_faction.place_meeple(battle_cl)
      bird_faction.place_meeple(battle_cl)
      bird_faction.place_meeple(battle_cl)

      allow_any_instance_of(Root::Actions::Battle).
        to receive(:dice_roll).and_return(2, 2)

      faction.improvements << Root::Cards::Improvements::Sappers.new
      bird_faction.improvements << Root::Cards::Improvements::Sappers.new

      faction.battle

      expect(battle_cl.meeples_of_type(:cats).count).to eq(0)
      expect(battle_cl.meeples_of_type(:birds).count).to eq(1)
    end
  end
end
