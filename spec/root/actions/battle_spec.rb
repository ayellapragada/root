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

      player.players = players

      clearings[:five].place_meeple(faction.meeples.pop)
      clearings[:five].place_meeple(faction.meeples.pop)
      clearings[:five].place_meeple(bird_faction.meeples.pop)
      clearings[:five].place_meeple(bird_faction.meeples.pop)

      allow_any_instance_of(Root::Actions::Battle).
        to receive(:dice_roll).and_return(2, 1)

      faction.battle

      expect(clearings[:five].meeples_of_type(:cats).count).to eq(1)
      expect(clearings[:five].meeples_of_type(:birds).count).to eq(0)
    end

    context 'when defender has no meeples' do
      it 'gives an extra hit to the attackers' do
        players = Root::Players::List.new(player, mouse_player)
        player.players = players

        allow(player).to receive(:pick_option).and_return(0)

        clearings[:five].place_meeple(faction.meeples.pop)
        clearings[:five].place_token(mouse_faction.sympathy.pop)

        expect { faction.battle }
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

  describe '#ambush' do
    it 'if defender plays an ambush card, does 2 damage' do
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

      bird_faction.hand << Root::Cards::Ambush.new(suit: :fox)

      faction.battle

      expect(battle_cl.meeples_of_type(:cats).count).to eq(0)
      expect(battle_cl.meeples_of_type(:birds).count).to eq(1)
    end

    it 'can be cancelled if the attacker plays an ambush card' do
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

      bird_faction.hand << Root::Cards::Ambush.new(suit: :fox)
      faction.hand << Root::Cards::Ambush.new(suit: :bird)

      faction.battle

      expect(battle_cl.meeples_of_type(:cats).count).to eq(1)
      expect(battle_cl.meeples_of_type(:birds).count).to eq(0)
    end

    it 'ends battle immediately if all attacking warriors removed' do
      allow(player).to receive(:pick_option).and_return(0)
      allow(bird_player).to receive(:pick_option).and_return(0)

      players = Root::Players::List.new(player, bird_player)
      player.players = players

      battle_cl = clearings[:one]
      faction.place_meeple(battle_cl)
      faction.place_meeple(battle_cl)
      faction.place_sawmill(battle_cl)
      bird_faction.place_meeple(battle_cl)
      bird_faction.place_meeple(battle_cl)

      allow_any_instance_of(Root::Actions::Battle).
        to receive(:dice_roll).and_return(2, 2)

      bird_faction.hand << Root::Cards::Ambush.new(suit: :fox)

      faction.battle

      expect(battle_cl.meeples_of_type(:cats).count).to eq(0)
      expect(battle_cl.buildings_of_type(:sawmill).count).to eq(1)
      expect(battle_cl.meeples_of_type(:birds).count).to eq(2)
    end
  end

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
