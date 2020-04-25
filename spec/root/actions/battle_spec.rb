# frozen_string_literal: true

RSpec.describe Root::Actions::Battle do
  let(:player) { Root::Players::Computer.for('Sneak', :cats) }
  let(:faction) { player.faction }
  let(:board) { player.board }
  let(:clearings) { board.clearings }
  let(:bird_player) { Root::Players::Computer.for('Bird', :birds) }
  let(:bird_faction) { bird_player.faction }
  let(:mouse_player) { Root::Players::Computer.for('Mouse', :mice) }
  let(:mouse_faction) { mouse_player.faction }

  describe 'initiate_battle_with_faction' do
    it 'rolls 2 dice and gives higher to attacker' do
      players = Root::Players::List.new(player, bird_player)
      allow(player).to receive(:pick_option).and_return(0)
      allow(bird_player).to receive(:pick_option).and_return(0)

      clearings[:five].place_meeple(faction.meeples.pop)
      clearings[:five].place_meeple(faction.meeples.pop)
      clearings[:five].place_meeple(bird_faction.meeples.pop)
      clearings[:five].place_meeple(bird_faction.meeples.pop)

      allow_any_instance_of(Root::Actions::Battle).
        to receive(:dice_roll).and_return(2, 1)

      faction.battle(players)

      expect(clearings[:five].meeples_of_type(:cats).count).to eq(1)
      expect(clearings[:five].meeples_of_type(:birds).count).to eq(0)
    end

    context 'when defender has no meeples' do
      it 'gives an extra hit to the attackers' do
        players = Root::Players::List.new(player, mouse_player)

        allow(player).to receive(:pick_option).and_return(0)

        clearings[:five].place_meeple(faction.meeples.pop)
        clearings[:five].place_token(mouse_faction.sympathy.pop)

        expect { faction.battle(players) }
          .to change(faction, :victory_points).by(1)
        expect(clearings[:five].buildings.count).to eq(0)
      end
    end
  end

  describe '#other_faction' do
    it 'returns the other faction that is not self' do
      battle = Root::Actions::Battle.new(clearings[:one], faction, mouse_faction)

      expect(battle.other_faction(faction)).to eq(mouse_faction)
      expect(battle.other_faction(mouse_faction)).to eq(faction)
    end
  end
end
