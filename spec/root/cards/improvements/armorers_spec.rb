# frozen_string_literal: true

RSpec.describe Root::Cards::Improvements::Armorers do
  let(:player) { Root::Players::Computer.for('Sneak', :cats) }
  let(:faction) { player.faction }
  let(:board) { player.board }
  let(:clearings) { board.clearings }
  let(:bird_player) { Root::Players::Computer.for('Bird', :birds) }
  let(:bird_faction) { bird_player.faction }

  describe '#armorers' do
    it 'discard to remove rolled hits' do
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

      allow_any_instance_of(Root::Actions::Battle).
        to receive(:dice_roll).and_return(2, 2)

      faction.improvements << Root::Cards::Improvements::Armorers.new
      bird_faction.improvements << Root::Cards::Improvements::Armorers.new

      faction.battle

      expect(battle_cl.meeples_of_type(:cats).count).to eq(3)
      expect(battle_cl.meeples_of_type(:birds).count).to eq(2)
    end

    context 'when defenseless' do
      it 'does not prevent extra hits' do
        allow(player).to receive(:pick_option).and_return(0)
        allow(bird_player).to receive(:pick_option).and_return(0)

        players = Root::Players::List.new(player, bird_player)
        player.players = players

        battle_cl = clearings[:one]
        faction.place_meeple(battle_cl)
        bird_faction.place_roost(battle_cl)

        allow_any_instance_of(Root::Actions::Battle).
          to receive(:dice_roll).and_return(1, 1)

        bird_faction.improvements << Root::Cards::Improvements::Armorers.new

        faction.battle

        expect(battle_cl.meeples_of_type(:cats).count).to eq(1)
        expect(battle_cl.buildings_of_type(:roost).count).to eq(0)
      end
    end
  end
end
