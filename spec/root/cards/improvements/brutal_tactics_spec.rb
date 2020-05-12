# frozen_string_literal: true

RSpec.describe Root::Cards::Improvements::BrutalTactics do
  let(:player) { Root::Players::Computer.for('Cat', :cats) }
  let(:faction) { player.faction }
  let(:clearings) { player.board.clearings }
  let(:mouse_player) { Root::Players::Computer.for('Sneak', :mice) }
  let(:mouse_faction) { mouse_player.faction }
  let(:bird_player) { Root::Players::Computer.for('Bird', :birds) }
  let(:bird_faction) { bird_player.faction }
  let(:racoon_player) { Root::Players::Computer.for('Racoon', :racoon) }
  let(:racoon_faction) { racoon_player.faction }

  describe '#brutal_tactics' do
    it 'as attacker, may deal extra hit, give defender 1 victory point' do
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
        to receive(:dice_roll).and_return(2, 0)

      faction.improvements << Root::Cards::Improvements::BrutalTactics.new

      faction.battle

      expect(bird_faction.victory_points).to eq(1)
      expect(battle_cl.meeples_of_type(:cats).count).to eq(3)
      expect(battle_cl.meeples_of_type(:birds).count).to eq(0)
    end
  end
end
