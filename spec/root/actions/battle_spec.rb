# frozen_string_literal: true

RSpec.describe Root::Actions::Battle do
  describe 'initiate_battle_with_faction' do
    it 'rolls 2 dice and gives higher to attacker' do
      player, faction = build_player_and_faction
      bird_player = Root::Players::Computer.for('Hal', :birds)
      players = Root::Players::List.new(player, bird_player)
      allow(player).to receive(:pick_option).and_return(0)
      allow(bird_player).to receive(:pick_option).and_return(0)
      clearings = player.board.clearings

      clearings[:five].place_meeple(faction.meeples.pop)
      clearings[:five].place_meeple(faction.meeples.pop)
      clearings[:five].place_meeple(bird_player.faction.meeples.pop)
      clearings[:five].place_meeple(bird_player.faction.meeples.pop)

      allow_any_instance_of(Root::Actions::Battle).
        to receive(:dice_roll).and_return(2, 1)

      faction.battle(players)

      expect(clearings[:five].meeples_of_type(:cats).count).to eq(1)
      expect(clearings[:five].meeples_of_type(:birds).count).to eq(0)
    end

    context 'when defender has no meeples' do
      it 'gives an extra hit to the attackers' do
        player, faction = build_player_and_faction
        mice_player = Root::Players::Computer.for('Hal', :mice)
        mice_faction = mice_player.faction
        players = Root::Players::List.new(player, mice_player)

        allow(player).to receive(:pick_option).and_return(0)
        clearings = player.board.clearings

        clearings[:five].place_meeple(faction.meeples.pop)
        clearings[:five].place_token(mice_faction.sympathy.pop)

        expect { faction.battle(players) }
          .to change(faction, :victory_points).by(1)
        expect(clearings[:five].buildings.count).to eq(0)
      end
    end
  end

  def build_player_and_faction
    player = Root::Players::Computer.for('Sneak', :cats)
    [player, player.faction]
  end
end
